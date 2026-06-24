-- scripts/npc/characters/wortox.lua
-- Wortox 基础角色模块


local NPC_TUNING = require("npc_tuning")

local function GetParam(key, fallback)
    local v = NPC_TUNING[key]
    if v == nil then
        return fallback
    end
    return v
end

local function IsInvalidOrGhost(ent)
    if not (ent and ent:IsValid()) then return true end
    if ent:HasTag("playerghost") then return true end
    if ent._is_ghost_mode then return true end
    if ent.components and ent.components.health and ent.components.health:IsDead() then return true end
    return false
end

local function IsFriendlyHealTarget(ent)
    if IsInvalidOrGhost(ent) then return false end
    if not (ent.components and ent.components.health) then return false end
    if not ent.components.health:IsHurt() then return false end
    if ent:HasTag("health_as_oldage") then return false end -- Wanda
    if ent:HasTag("npc_hostile") then return false end      -- 不治疗敌对 NPC
    return true
end

local function GetCheckInterval()
    return GetParam("WORTOX_NPC_SOUL_CHECK_INTERVAL", 10)
end
local function GetSearchRadius()
    return GetParam("WORTOX_NPC_SOUL_SEARCH_RADIUS", 20)
end
local function GetFollowTick()
    return GetParam("WORTOX_NPC_SOUL_FOLLOW_TICK", 0.25)
end
local function GetFollowTimeout()
    return GetParam("WORTOX_NPC_SOUL_FOLLOW_TIMEOUT", 6)
end
local function GetHealRange()
    return GetParam("WORTOX_NPC_SOUL_HEAL_RANGE", 15)
end
local function GetHealDelay()
    return GetParam("WORTOX_NPC_SOUL_HEAL_DELAY", 1)
end

local function GetHealAmount(target_count)
    local base = GetParam("WORTOX_NPC_SOUL_HEAL_BASE", 20)
    local loss = GetParam("WORTOX_NPC_SOUL_HEAL_LOSS_PER_TARGET", 2)
    local min_heal = GetParam("WORTOX_NPC_SOUL_HEAL_MIN", 5)
    local n = math.max(1, math.floor(target_count or 1))
    return math.max(min_heal, base - loss * (n - 1))
end

local function PauseBrainForHeal(inst)
    if inst.brain and not inst._wortox_heal_paused_brain then
        inst.brain:Stop()
        inst._wortox_heal_paused_brain = true
    end
end

local function ResumeBrainForHeal(inst)
    if inst._wortox_heal_paused_brain and inst.brain then
        inst.brain:Start()
        inst._wortox_heal_paused_brain = false
    end
end

local function CollectHurtTargetsInRange(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rangesq = radius * radius
    local ret = {}

    for _, p in ipairs(AllPlayers) do
        if IsFriendlyHealTarget(p) and p:GetDistanceSqToPoint(x, y, z) <= rangesq then
            ret[#ret + 1] = p
        end
    end

    local npcs = TheSim:FindEntities(x, y, z, radius, { "npcfriend", "_health" }, { "INLIMBO", "playerghost", "npc_hostile" })
    for _, n in ipairs(npcs) do
        if n ~= inst and IsFriendlyHealTarget(n) then
            ret[#ret + 1] = n
        end
    end

    if IsFriendlyHealTarget(inst) then
        ret[#ret + 1] = inst
    end

    return ret
end

local function FindNearestHurtTargetInRange(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rangesq = radius * radius
    local best, best_dsq = nil, nil

    local function Try(ent)
        if IsFriendlyHealTarget(ent) then
            local dsq = ent:GetDistanceSqToPoint(x, y, z)
            if dsq <= rangesq and (best_dsq == nil or dsq < best_dsq) then
                best, best_dsq = ent, dsq
            end
        end
    end

    for _, p in ipairs(AllPlayers) do Try(p) end
    local npcs = TheSim:FindEntities(x, y, z, radius, { "npcfriend", "_health" }, { "INLIMBO", "playerghost", "npc_hostile" })
    for _, n in ipairs(npcs) do if n ~= inst then Try(n) end end
    Try(inst)

    return best, best_dsq
end

local function SpawnHealFX(target)
    local fx = SpawnPrefab("wortox_soul_heal_fx")
    if not fx then return end

    if target.components and target.components.combat then
        fx.entity:AddFollower():FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, -50, 0)
    else
        local x, y, z = target.Transform:GetWorldPosition()
        fx.Transform:SetPosition(x, y, z)
    end
    if fx.Setup then
        fx:Setup(target)
    end
end

local function DoSoulHealNow(inst)
    local targets = CollectHurtTargetsInRange(inst, GetHealRange())
    if #targets <= 0 then return false end

    local amount = GetHealAmount(#targets)
    for _, t in ipairs(targets) do
        if IsFriendlyHealTarget(t) then
            t.components.health:DoDelta(amount, nil, "wortox_npc_soul")
            SpawnHealFX(t)
        end
    end
    return true
end

local function SpawnGroundSoulVisual(inst)
    local soul = SpawnPrefab("wortox_soul")
    if not soul then
        return nil
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local rot = (inst.Transform:GetRotation() or 0) * DEGREES
    local drop_dist = 1.2
    local dx = math.sin(rot) * drop_dist
    local dz = math.cos(rot) * drop_dist
    local sx, sz = x + dx, z + dz
    if TheWorld and TheWorld.Map and not TheWorld.Map:IsPassableAtPoint(sx, 0, sz) then
        sx, sz = x, z
    end
    soul.Transform:SetPosition(sx, y, sz)

    if soul._task then
        soul._task:Cancel()
        soul._task = nil
    end
    return soul
end

local function EndCast(inst)
    if inst._wortox_soul_cast_task then
        inst._wortox_soul_cast_task:Cancel()
        inst._wortox_soul_cast_task = nil
    end
    if inst._wortox_soul_cast_anim_listener then
        inst:RemoveEventCallback("animover", inst._wortox_soul_cast_anim_listener)
        inst._wortox_soul_cast_anim_listener = nil
    end
    if inst._wortox_soul_visual and inst._wortox_soul_visual:IsValid() then
        inst._wortox_soul_visual:Remove()
    end
    inst._wortox_soul_visual = nil
    inst._wortox_soul_cast_anim_done = nil
    inst._wortox_soul_cast_anim_token = nil
    inst._wortox_soul_casting = nil
    inst._wortox_soul_cast_ready_time = nil
    ResumeBrainForHeal(inst)
end

local function IsCastInProgress(inst)
    return inst._wortox_soul_casting == true
end

local function CanEvaluateSoulHeal(inst)
    if IsInvalidOrGhost(inst) then return false end
    if IsCastInProgress(inst) then return false end
    return true
end

local function StopFollowTask(inst)
    if inst._wortox_soulheal_follow_task then
        inst._wortox_soulheal_follow_task:Cancel()
        inst._wortox_soulheal_follow_task = nil
    end
    inst._wortox_soulheal_target = nil
    inst._wortox_soulheal_follow_deadline = nil
    if not IsCastInProgress(inst) then
        ResumeBrainForHeal(inst)
    end
end

local function BeginSoulCast(inst)
    local now = GetTime()
    if inst._wortox_soulheal_cd_until and now < inst._wortox_soulheal_cd_until then
        return false
    end
    if IsCastInProgress(inst) then
        return false
    end
    PauseBrainForHeal(inst)
    inst.components.locomotor:Stop()
    inst._wortox_soul_casting = true
    inst._wortox_soul_cast_ready_time = now + GetHealDelay()
    inst._wortox_soulheal_cd_until = now + GetCheckInterval()
    inst._wortox_soul_cast_anim_done = false
    inst._wortox_soul_cast_anim_token = (inst._wortox_soul_cast_anim_token or 0) + 1
    local this_token = inst._wortox_soul_cast_anim_token

    if inst.sg then

        inst.sg:GoToState("emote", { anim = "pickup_pst" })
    end
    inst._wortox_soul_cast_anim_listener = function(i)
        if i._wortox_soul_casting and i._wortox_soul_cast_anim_token == this_token then
            i._wortox_soul_cast_anim_done = true
        end
    end
    inst:ListenForEvent("animover", inst._wortox_soul_cast_anim_listener)

    inst._wortox_soul_visual = SpawnGroundSoulVisual(inst)

    -- 必须满足两个条件才治疗：
    -- 1) 动画播完（busy 结束）
    -- 2) 到达治疗延迟
    inst._wortox_soul_cast_task = inst:DoPeriodicTask(0.05, function(i)
        if not (i and i:IsValid()) then
            EndCast(i)
            return
        end
        local anim_done = (i._wortox_soul_cast_anim_done == true)
        local delay_done = GetTime() >= (i._wortox_soul_cast_ready_time or 0)
        if anim_done and delay_done then
            if i._wortox_soul_visual and i._wortox_soul_visual:IsValid() then
                i._wortox_soul_visual.AnimState:PlayAnimation("idle_pst")
                i._wortox_soul_visual:ListenForEvent("animover", i._wortox_soul_visual.Remove)
                i._wortox_soul_visual = nil
            end
            DoSoulHealNow(i)
            EndCast(i)
        end
    end)

    return true
end

local function StartFollowTask(inst, target)
    StopFollowTask(inst)
    if not (target and target:IsValid()) then return end

    PauseBrainForHeal(inst)
    inst._wortox_soulheal_target = target
    inst._wortox_soulheal_follow_deadline = GetTime() + GetFollowTimeout()
    inst._wortox_soulheal_follow_task = inst:DoPeriodicTask(GetFollowTick(), function(i)
        local tgt = i._wortox_soulheal_target
        if not (i and i:IsValid() and tgt and tgt:IsValid()) then
            StopFollowTask(i)
            return
        end
        if IsCastInProgress(i) then
            return
        end
        if not IsFriendlyHealTarget(tgt) then
            StopFollowTask(i)
            return
        end
        if GetTime() >= (i._wortox_soulheal_follow_deadline or 0) then
            StopFollowTask(i)
            return
        end

        local heal_range = GetHealRange()
        local dsq = i:GetDistanceSqToInst(tgt)
        if dsq <= heal_range * heal_range then
            i.components.locomotor:Stop()
            if BeginSoulCast(i) then
                StopFollowTask(i)
            end
            return
        end

        i.components.locomotor:GoToPoint(tgt:GetPosition(), nil, true)
    end)
end

local function StartAutoSoulHealTask(inst)
    if inst._wortox_auto_soulheal_task then
        inst._wortox_auto_soulheal_task:Cancel()
        inst._wortox_auto_soulheal_task = nil
    end

    inst._wortox_auto_soulheal_task = inst:DoPeriodicTask(GetCheckInterval(), function(i)
        if not CanEvaluateSoulHeal(i) then return end

        local target, dsq = FindNearestHurtTargetInRange(i, GetSearchRadius())
        if not target then return end

        local heal_range = GetHealRange()
        if dsq and dsq <= heal_range * heal_range then
            if not BeginSoulCast(i) then
                i._wortox_soul_pending_cast = true
            end
        else
            StartFollowTask(i, target)
        end
    end, 1)

    -- 战斗中若检测命中但当前状态忙碌，短周期重试，避免“10秒窗口错过就一直不奶”
    if inst._wortox_auto_soulheal_retry_task then
        inst._wortox_auto_soulheal_retry_task:Cancel()
        inst._wortox_auto_soulheal_retry_task = nil
    end
    inst._wortox_auto_soulheal_retry_task = inst:DoPeriodicTask(0.2, function(i)
        if not i._wortox_soul_pending_cast then
            return
        end
        if not CanEvaluateSoulHeal(i) then
            return
        end
        local target, dsq = FindNearestHurtTargetInRange(i, GetSearchRadius())
        if not target then
            i._wortox_soul_pending_cast = nil
            return
        end
        local heal_range = GetHealRange()
        if dsq and dsq <= heal_range * heal_range then
            if BeginSoulCast(i) then
                i._wortox_soul_pending_cast = nil
            end
        else
            StartFollowTask(i, target)
            i._wortox_soul_pending_cast = nil
        end
    end)
end

local function StopAllTasks(inst)
    StopFollowTask(inst)
    EndCast(inst)
    if inst._wortox_auto_soulheal_task then
        inst._wortox_auto_soulheal_task:Cancel()
        inst._wortox_auto_soulheal_task = nil
    end
    if inst._wortox_auto_soulheal_retry_task then
        inst._wortox_auto_soulheal_retry_task:Cancel()
        inst._wortox_auto_soulheal_retry_task = nil
    end
    inst._wortox_soul_pending_cast = nil
    ResumeBrainForHeal(inst)
end

return {
    on_apply = function(inst, stats)
        inst._is_wortox = true
        StopAllTasks(inst)

        if not inst._wortox_onremove_listener_added then
            inst._wortox_onremove_listener_added = true
            inst:ListenForEvent("onremove", function(i)
                StopAllTasks(i)
            end)
        end
    end,

    on_save = function(inst, data)
        if inst._wortox_soulheal_cd_until then
            local remain = math.max(0, inst._wortox_soulheal_cd_until - GetTime())
            data.wortox_soulheal_cd_remain = remain
        end
    end,

    on_load = function(inst, data)
        if data then
            local check_interval = GetParam("WORTOX_NPC_SOUL_CHECK_INTERVAL", 10)
            local sane_max = math.max(30, check_interval * 3)

            -- 新格式：剩余秒数
            if data.wortox_soulheal_cd_remain then
                local remain = math.max(0, math.min(data.wortox_soulheal_cd_remain, sane_max))
                if remain > 0 then
                    inst._wortox_soulheal_cd_until = GetTime() + remain
                else
                    inst._wortox_soulheal_cd_until = nil
                end

            elseif data.wortox_soulheal_cd_until then
                local remain_old = data.wortox_soulheal_cd_until - GetTime()
                if remain_old > 0 and remain_old <= sane_max then
                    inst._wortox_soulheal_cd_until = GetTime() + remain_old
                else
                    inst._wortox_soulheal_cd_until = nil
                end
            end
        end
        StopAllTasks(inst)
    end,
}
