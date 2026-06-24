-- scripts/npc/npc_woby_ride.lua
-- NPC 沃尔特/沃比骑乘、变身、死亡锁的唯一控制模块。

local NPC_TUNING = require("npc_tuning")

local M = {}

local MOUNT_MAX_DIST = 2
local IDLE_DISMOUNT_TIME = 3
local MOUNT_ATTEMPT_TIMEOUT = 6
local MOUNT_RETRY_COOLDOWN = 4

local STATE_SMALL = "small_follow"
local STATE_GROWING = "growing"
local STATE_BIG_WAIT = "big_wait_mount"
local STATE_MOUNTED = "mounted"
local STATE_SHRINKING = "shrinking"
local STATE_DISABLED = "disabled"

local function Log(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_WALTER then
        print("[沃尔特调试]", ...)
    end
end

local function IsWalter(inst)
    return inst ~= nil and inst.npc_character_type == "walter"
end

local function IsWalterUnavailable(inst)
    if inst == nil or not inst:IsValid() then
        return true
    end
    if inst._is_ghost_mode or inst._npc_woby_ride_disabled then
        return true
    end
    if inst.components ~= nil
        and inst.components.health ~= nil
        and inst.components.health:IsDead() then
        return true
    end
    if inst.sg ~= nil then
        if inst.sg:HasStateTag("dead") or inst.sg:HasStateTag("ghost") then
            return true
        end
        local state = inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil
        return state == "death"
            or state == "corpse"
            or state == "ghost_idle"
            or state == "ghost_despawn"
            or state == "revive_from_ghost"
    end
    return false
end

local function SetState(inst, state, reason)
    if inst._npc_woby_state == state then
        return
    end
    local old = inst._npc_woby_state or "nil"
    inst._npc_woby_state = state
    inst._npc_woby_state_time = GetTime()
    inst._npc_woby_idle_started = nil
    -- 跟随触发时先上骑再跟随；战斗触发时不抢战斗/跟随走位。
    inst._npc_woby_mount_priority = reason ~= "combat_target"
        and (state == STATE_GROWING or state == STATE_BIG_WAIT)
    Log("Woby状态", old .. " -> " .. state, "reason=" .. tostring(reason))
end

function M.EnsureWoby(inst)
    if not IsWalter(inst) or not TheWorld.ismastersim then
        return nil
    end

    if inst._npc_woby ~= nil and inst._npc_woby:IsValid() then
        if inst._npc_woby.SetLeader ~= nil then
            inst._npc_woby:SetLeader(inst)
        end
        return inst._npc_woby
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local woby = SpawnPrefab("npc_woby")
    if woby == nil then
        Log("生成 NPC Woby 失败")
        return nil
    end

    woby.Transform:SetPosition(x + 1.5, y, z + 1.5)
    if woby.SetLeader ~= nil then
        woby:SetLeader(inst)
    elseif woby.components ~= nil and woby.components.follower ~= nil then
        woby.components.follower:SetLeader(inst)
    end

    inst._npc_woby = woby
    SetState(inst, STATE_SMALL, "spawn")
    Log("生成 NPC Woby 并跟随沃尔特")
    return woby
end

function M.RemoveWoby(inst)
    if inst._npc_woby ~= nil and inst._npc_woby:IsValid() then
        inst._npc_woby:Remove()
    end
    inst._npc_woby = nil
end

function M.IsRidingWoby(inst)
    local rider = inst ~= nil and inst.components ~= nil and inst.components.rider or nil
    local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
    return mount ~= nil and mount:HasTag("npc_woby"), mount
end

function M.SyncMountedMeleeDamage(inst)
    local riding, mount = M.IsRidingWoby(inst)
    if not riding or mount.components == nil or mount.components.combat == nil then
        return
    end

    local damage = nil
    local inv = inst.components ~= nil and inst.components.inventory or nil
    local weapon = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if weapon ~= nil
        and weapon.prefab ~= "slingshot"
        and weapon.components ~= nil
        and weapon.components.weapon ~= nil then
        damage = weapon.components.weapon:GetDamage(inst)
    end

    if damage == nil then
        damage = inst.components ~= nil
            and inst.components.combat ~= nil
            and inst.components.combat.defaultdamage
            or 0
    end

    mount.components.combat:SetDefaultDamage(damage or 0)
end

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
end

local function IsStoryMountLocked(inst)
    if not inst._npc_walter_story_lock_mount then
        return false
    end
    local storyteller = inst.components ~= nil and inst.components.storyteller or nil
    local sg_state = inst.sg ~= nil and inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil
    local lock_until = inst._npc_walter_story_lock_until or 0
    local active = inst._walter_auto_story_enabled == true
        and TheWorld.state.isnight
        and (
            (storyteller ~= nil and storyteller:IsTellingStory())
            or sg_state == "npc_woby_dismount"
            or sg_state == "dostorytelling"
            or GetTime() < lock_until
        )
    if not active then
        inst._npc_walter_story_lock_mount = nil
        inst._npc_walter_story_lock_until = nil
    end
    return active
end

local function GetDecision(inst, leader)
    if IsWalterUnavailable(inst) then
        return false, false, "walter_unavailable", nil, nil
    end
    if leader == nil or not leader:IsValid() then
        return false, false, "no_leader", nil, nil
    end
    if IsStoryMountLocked(inst) then
        return false, false, "walter_story", nil, nil
    end

    local target = inst.components.combat ~= nil and inst.components.combat.target or nil
    if (target == nil or not target:IsValid())
        and inst._npc_woby_pending_combat_target ~= nil
        and inst._npc_woby_pending_combat_target:IsValid() then
        target = inst._npc_woby_pending_combat_target
    end
    if target ~= nil and target:IsValid() then
        -- 战斗中未骑乘时不自动变大，避免沃尔特边打边触发沃比变大/缩小循环。
        -- 如果已经骑在沃比上，则保持大形态直到战斗结束后再按待机逻辑下骑。
        local riding = M.IsRidingWoby(inst)
        return false, riding, "combat_target", nil, target
    end

    local base = NPC_TUNING.WALTER_NPC_WOBY_FOLLOW_MAX_DIST or NPC_TUNING.FOLLOW_MAX or 8
    local grow_dist = base + 1.5
    local keep_dist = math.max(MOUNT_MAX_DIST, base - 1)
    local dist = math.sqrt(inst:GetDistanceSqToInst(leader))

    if dist > grow_dist then
        return true, true, "leader_far", dist, nil
    end
    if dist > keep_dist then
        return false, true, "leader_mid", dist, nil
    end
    return false, false, "idle_in_range", dist, nil
end

local function MoveToMountRange(inst, woby)
    local locomotor = inst.components ~= nil and inst.components.locomotor or nil
    if locomotor == nil or woby == nil or not woby:IsValid() then
        return
    end
    local x, y, z = woby.Transform:GetWorldPosition()
    locomotor:GoToPoint(Point(x, y, z), nil, true)
end

local function HoldCombatForMount(inst, target)
    if target ~= nil and target:IsValid() then
        inst._npc_woby_pending_combat_target = target
    end
    if inst.components ~= nil and inst.components.combat ~= nil then
        inst.components.combat:CancelAttack()
        inst.components.combat:SetTarget(nil)
    end
end

local function RestoreCombatAfterMount(inst)
    local target = inst._npc_woby_pending_combat_target
    inst._npc_woby_pending_combat_target = nil
    if target ~= nil
        and target:IsValid()
        and inst.components ~= nil
        and inst.components.combat ~= nil then
        inst.components.combat:SetTarget(target)
    end
end

local function StartShrink(inst, woby, reason)
    inst._npc_woby_pending_combat_target = nil
    if woby == nil or not woby:IsValid() then
        SetState(inst, STATE_SMALL, reason)
        return
    end
    if not woby._npc_woby_big and not woby._npc_woby_transforming then
        SetState(inst, STATE_SMALL, reason)
        return
    end

    SetState(inst, STATE_SHRINKING, reason)
    if woby.ForceSmall ~= nil then
        woby:ForceSmall(function()
            if inst:IsValid() and not IsWalterUnavailable(inst) then
                SetState(inst, STATE_SMALL, reason)
            end
        end)
    end
end

local function StartAnimatedDismount(inst, woby, reason)
    if inst.sg ~= nil and inst.sg:HasStateTag("dismounting") then
        return
    end
    if inst.sg ~= nil and not IsWalterUnavailable(inst) then
        inst._npc_woby_after_dismount = function(npc, mount)
            StartShrink(npc, mount or woby, reason)
        end
        inst.sg:GoToState("npc_woby_dismount")
        Log("沃尔特下骑 NPC Woby")
    elseif inst.components.rider ~= nil and inst.components.rider:IsRiding() then
        local mount = inst.components.rider:ActualDismount()
        StartShrink(inst, mount or woby, reason)
    else
        StartShrink(inst, woby, reason)
    end
end

local function TryMount(inst, woby)
    if woby == nil or not woby:IsValid()
        or inst == nil or not inst:IsValid()
        or inst.components.rider == nil
        or inst.components.rider:IsRiding()
        or woby.components.rideable == nil
        or woby.components.rideable:IsBeingRidden()
        or woby._npc_woby_transforming
        or not woby._npc_woby_big
        or inst:GetDistanceSqToInst(woby) > MOUNT_MAX_DIST * MOUNT_MAX_DIST then
        return false
    end

    inst.components.rider:Mount(woby, true)
    inst._walter_woby_dismounted_idle = nil
    if inst.sg ~= nil and not IsWalterUnavailable(inst) then
        inst.sg:GoToState("npc_woby_mount")
    end
    M.SyncMountedMeleeDamage(inst)
    RestoreCombatAfterMount(inst)
    SetState(inst, STATE_MOUNTED, "mounted")
    Log("沃尔特骑上 NPC Woby")
    return true
end

function M.DisableForDeath(inst)
    if not IsWalter(inst) then
        return
    end

    inst._npc_woby_ride_disabled = true
    if inst.components ~= nil and inst.components.locomotor ~= nil then
        inst.components.locomotor:StopMoving()
        inst.components.locomotor:Stop()
    end
    if inst.components ~= nil and inst.components.combat ~= nil then
        inst.components.combat:SetTarget(nil)
        inst.components.combat:CancelAttack()
    end

    local riding, mount = M.IsRidingWoby(inst)
    local woby = riding and mount or inst._npc_woby
    if riding and inst.components.rider ~= nil then
        woby = inst.components.rider:ActualDismount() or woby
        Log("Woby死亡/幽灵强制下骑")
    end

    if woby ~= nil and woby:IsValid() then
        woby._npc_woby_mount_disabled = true
        if woby.SetLeader ~= nil then
            woby:SetLeader(inst)
        elseif woby.components ~= nil and woby.components.follower ~= nil then
            woby.components.follower:SetLeader(inst)
        end
        if woby.ForceSmall ~= nil then
            woby:ForceSmall()
        end
    end

    SetState(inst, STATE_DISABLED, "death_or_ghost")
end

function M.EnableAfterRevive(inst)
    if not IsWalter(inst) then
        return
    end
    inst._npc_woby_ride_disabled = nil
    if inst._npc_woby ~= nil and inst._npc_woby:IsValid() then
        inst._npc_woby._npc_woby_mount_disabled = nil
        if inst._npc_woby.SetLeader ~= nil then
            inst._npc_woby:SetLeader(inst)
        end
    end
    SetState(inst, STATE_SMALL, "revived")
end

function M.UpdateFollowRide(inst)
    if not IsWalter(inst) or inst.components == nil then
        return
    end

    local woby = inst._npc_woby
    if woby == nil or not woby:IsValid() then
        woby = M.EnsureWoby(inst)
    end
    if woby == nil or not woby:IsValid() then
        return
    end

    if IsWalterUnavailable(inst) then
        if inst._npc_woby_state ~= STATE_DISABLED then
            M.DisableForDeath(inst)
        end
        return
    end

    if woby._npc_woby_mount_disabled then
        woby._npc_woby_mount_disabled = nil
    end

    local leader = GetLeader(inst)
    if leader == nil or not leader:IsValid() then
        local riding = M.IsRidingWoby(inst)
        if riding and inst.components.rider ~= nil then
            StartAnimatedDismount(inst, woby, "no_leader")
        else
            StartShrink(inst, woby, "no_leader")
        end
        return
    end

    local should_grow, should_keep_big, reason, dist, target = GetDecision(inst, leader)
    local state = inst._npc_woby_state or STATE_SMALL

    if state == STATE_DISABLED then
        SetState(inst, STATE_SMALL, "enabled")
        state = STATE_SMALL
    end

    local now = GetTime()
    local retry_time = inst._npc_woby_retry_after or 0

    if state == STATE_SMALL then
        if should_grow and now >= retry_time then
            if reason ~= "combat_target" then
                HoldCombatForMount(inst, target)
            end
            SetState(inst, STATE_GROWING, reason)
            woby:ForceBig(function(big_woby)
                if inst:IsValid()
                    and big_woby ~= nil
                    and big_woby:IsValid()
                    and inst._npc_woby_state == STATE_GROWING
                    and not IsWalterUnavailable(inst) then
                    SetState(inst, STATE_BIG_WAIT, reason)
                    inst._npc_woby_mount_attempt_started = GetTime()
                end
            end)
        end
        return
    end

    if state == STATE_GROWING then
        if reason ~= "combat_target" then
            HoldCombatForMount(inst, target)
        end
        if not should_keep_big then
            StartShrink(inst, woby, reason)
        end
        return
    end

    if state == STATE_BIG_WAIT then
        if not should_keep_big then
            StartShrink(inst, woby, reason)
            return
        end
        if reason ~= "combat_target" then
            HoldCombatForMount(inst, target)
        end
        if TryMount(inst, woby) then
            return
        end
        if reason == "combat_target" then
            local started = inst._npc_woby_mount_attempt_started or now
            if now - started >= MOUNT_ATTEMPT_TIMEOUT then
                inst._npc_woby_retry_after = now + MOUNT_RETRY_COOLDOWN
                StartShrink(inst, woby, "mount_timeout")
            end
            return
        end
        MoveToMountRange(inst, woby)
        local started = inst._npc_woby_mount_attempt_started or now
        if now - started >= MOUNT_ATTEMPT_TIMEOUT then
            inst._npc_woby_retry_after = now + MOUNT_RETRY_COOLDOWN
            StartShrink(inst, woby, "mount_timeout")
        end
        return
    end

    if state == STATE_MOUNTED then
        local riding, mount = M.IsRidingWoby(inst)
        if not riding then
            StartShrink(inst, woby, "lost_mount")
            return
        end
        if should_keep_big then
            inst._npc_woby_idle_started = nil
            return
        end
        inst._npc_woby_idle_started = inst._npc_woby_idle_started or now
        if now - inst._npc_woby_idle_started >= IDLE_DISMOUNT_TIME then
            StartAnimatedDismount(inst, mount or woby, reason)
        end
        return
    end

    if state == STATE_SHRINKING then
        if not woby._npc_woby_transforming and not woby._npc_woby_big then
            SetState(inst, STATE_SMALL, "shrink_done")
        end
    end
end

return M
