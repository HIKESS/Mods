-- scripts/npc/characters/wx78.lua

local NPC_TUNING = require("npc_tuning")
local npc_affinity = require("npc/npc_affinity")

local WX78 = {}

local SPIN_TOOL_PREFABS = {
    multitool_axe_pickaxe = 1,
    goldenaxe = 2,
    pickaxe = 3,
    axe = 4,
}

local function CombatLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_COMBAT then print(...) end
end

local function DebugName(ent)
    if ent == nil then return "nil" end
    return tostring(ent.prefab or ent.GUID or ent)
end

local function ActionName(action)
    return tostring(action ~= nil and (action.id or action.str or action) or "nil")
end

local function IsHostileNPC(ent)
    return ent ~= nil and ent:HasTag("npc_hostile")
end

local function IsFriendlyEntity(inst, ent)
    if ent == nil or ent == inst then return true end
    if ent:HasTag("player") or ent:HasTag("playerghost") then return true end
    if ent:HasTag("companion") or ent:HasTag("npcfriend_companion") then return true end
    if ent:HasTag("npcfriend") and not IsHostileNPC(ent) then return true end

    local leader = ent.components.follower and ent.components.follower:GetLeader()
    if leader ~= nil and leader:IsValid() then
        if leader:HasTag("player") then return true end
        if leader:HasTag("npcfriend") and not IsHostileNPC(leader) then return true end
    end

    return inst.components.combat ~= nil and inst.components.combat:IsAlly(ent)
end

function WX78.CanSpinUsingItem(item)
    if item == nil or item.components == nil or item.components.tool == nil then
        return false
    end
    return item.components.tool:CanDoAction(ACTIONS.CHOP)
        or item.components.tool:CanDoAction(ACTIONS.MINE)
end

function WX78.FindSpinTool(inst)
    local inv = inst.components.inventory
    if inv == nil then return nil end

    local equipped = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if WX78.CanSpinUsingItem(equipped) then
        return equipped
    end

    local best, best_pri = nil, math.huge
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if WX78.CanSpinUsingItem(item) and item.components.equippable ~= nil
            and item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
            local pri = SPIN_TOOL_PREFABS[item.prefab] or 99
            if pri < best_pri then
                best, best_pri = item, pri
            end
        end
    end
    return best
end

function WX78.TryEquipSpinTool(inst)
    local tool = WX78.FindSpinTool(inst)
    local inv = inst.components.inventory
    if tool ~= nil and inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= tool then
        inv:Equip(tool)
    end
    return tool
end

function WX78.CanUseSpinAttack(inst, target)
    if inst == nil or not inst:IsValid() then return false end
    if inst.npc_character_type ~= "wx78" then return false end
    if inst._is_ghost_mode or inst:HasTag("playerghost") then return false end
    if inst.sg ~= nil and inst.sg:HasAnyStateTag("prespin", "spinning") then return false end
    if target ~= nil and IsFriendlyEntity(inst, target) then return false end
    return WX78.TryEquipSpinTool(inst) ~= nil
end

function WX78.CanUseSpinWork(inst, action, target)
    if inst == nil or not inst:IsValid() then return false end
    if inst.npc_character_type ~= "wx78" then return false end
    if inst._is_ghost_mode or inst:HasTag("playerghost") then return false end
    if action ~= ACTIONS.CHOP and action ~= ACTIONS.MINE then return false end
    if target == nil or not target:IsValid() then return false end
    local workable = target.components.workable
    if workable == nil or not workable:CanBeWorked() or workable:GetWorkAction() ~= action then
        return false
    end
    return WX78.TryEquipSpinTool(inst) ~= nil
end

function WX78.DoSpinAttack(inst)
    if inst == nil or not inst:IsValid() or inst.components.combat == nil then
        CombatLog("[NPC_WX78][旋转攻击] 取消：实体/战斗组件无效")
        return 0
    end

    local item = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if not WX78.CanSpinUsingItem(item) then
        CombatLog("[NPC_WX78][旋转攻击] 取消：手持物不可旋转 tool=" .. DebugName(item))
        return 0
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local radius = NPC_TUNING.WX78_SPIN_RADIUS or 2.1
    local search_radius = radius + 3
    local targets_hit = 0
    local scanned, valid_candidates, friendly_skips = 0, 0, 0
    local closest_name, closest_dist
    local seen = {}
    local cant_tags = { "INLIMBO", "NOCLICK", "FX", "decor", "wall", "flight", "invisible", "notarget", "noattack" }

    for _, v in ipairs(TheSim:FindEntities(x, y, z, search_radius, { "_combat" }, cant_tags)) do
        scanned = scanned + 1
        if v ~= inst and not seen[v] and v:IsValid() and v.entity:IsVisible()
            and v.components.health ~= nil and not v.components.health:IsDead() then

            if IsFriendlyEntity(inst, v) then
                friendly_skips = friendly_skips + 1
            elseif inst.components.combat:CanTarget(v) then
                valid_candidates = valid_candidates + 1

                local dist = math.sqrt(inst:GetDistanceSqToInst(v))
                if closest_dist == nil or dist < closest_dist then
                    closest_dist = dist
                    closest_name = DebugName(v)
                end

                local physrad = v.GetPhysicsRadius ~= nil and v:GetPhysicsRadius(0) or 0
                local range = radius + physrad
                if dist < range then
                    seen[v] = true
                    if targets_hit == 0 then
                        inst.components.combat:SetTarget(v)
                        inst.components.combat:StartAttack()
                    end
                    inst.components.combat:DoAttack(v)
                    targets_hit = targets_hit + 1
                end
            end
        end
    end

    if targets_hit > 0 then
        CombatLog("[NPC_WX78][旋转攻击] 命中 count=" .. tostring(targets_hit)
            .. " radius=" .. tostring(radius)
            .. " tool=" .. DebugName(item))
    else
        local target = inst.components.combat.target
        local target_dist = target ~= nil and target:IsValid() and string.format("%.2f", math.sqrt(inst:GetDistanceSqToInst(target))) or "nil"
        CombatLog("[NPC_WX78][旋转攻击] 未命中 radius=" .. tostring(radius)
            .. " search=" .. tostring(search_radius)
            .. " scanned=" .. tostring(scanned)
            .. " valid=" .. tostring(valid_candidates)
            .. " friendly_skip=" .. tostring(friendly_skips)
            .. " combat_target=" .. DebugName(target)
            .. " target_dist=" .. target_dist
            .. " closest=" .. tostring(closest_name)
            .. " closest_dist=" .. (closest_dist ~= nil and string.format("%.2f", closest_dist) or "nil"))
    end
    return targets_hit
end

function WX78.DoSpinWork(inst, action)
    if inst == nil or not inst:IsValid() then
        CombatLog("[NPC_WX78][旋转工作] 取消：实体无效 action=" .. ActionName(action))
        return 0
    end
    if action ~= ACTIONS.CHOP and action ~= ACTIONS.MINE then
        CombatLog("[NPC_WX78][旋转工作] 取消：动作不是砍/挖 action=" .. ActionName(action))
        return 0
    end

    local item = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if not WX78.CanSpinUsingItem(item) then
        CombatLog("[NPC_WX78][旋转工作] 取消：手持物不可旋转 tool=" .. DebugName(item))
        return 0
    end
    if item.components.tool == nil or not item.components.tool:CanDoAction(action) then
        CombatLog("[NPC_WX78][旋转工作] 取消：工具不能执行动作 tool=" .. DebugName(item)
            .. " action=" .. ActionName(action))
        return 0
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local radius = NPC_TUNING.WX78_SPIN_RADIUS or 2.1
    local must_tags = action == ACTIONS.CHOP and { "CHOP_workable" } or { "MINE_workable" }
    local cant_tags = { "INLIMBO", "NOCLICK", "FX", "decor", "wall", "event_trigger", "carnivalgame_part" }
    local worked = 0
    local scanned, valid_candidates = 0, 0

    for _, v in ipairs(TheSim:FindEntities(x, y, z, radius + 3, must_tags, cant_tags)) do
        scanned = scanned + 1
        if v ~= inst and v:IsValid() and v.entity:IsVisible()
            and v.components.workable ~= nil
            and v.components.workable:CanBeWorked()
            and v.components.workable:GetWorkAction() == action then

            valid_candidates = valid_candidates + 1
            local physrad = v.GetPhysicsRadius ~= nil and v:GetPhysicsRadius(0) or 0
            local range = radius + physrad
            if inst:GetDistanceSqToInst(v) < range * range then
                if action == ACTIONS.MINE and PlayMiningFX ~= nil then
                    PlayMiningFX(inst, v)
                end
                v.components.workable:WorkedBy(inst, item.components.tool:GetEffectiveness(action) or 1)
                worked = worked + 1
            end
        end
    end

    if worked > 0 then
        CombatLog("[NPC_WX78][旋转工作] 完成 action=" .. ActionName(action)
            .. " count=" .. tostring(worked)
            .. " radius=" .. tostring(radius)
            .. " tool=" .. DebugName(item))
    else
        CombatLog("[NPC_WX78][旋转工作] 未命中 action=" .. ActionName(action)
            .. " radius=" .. tostring(radius)
            .. " scanned=" .. tostring(scanned)
            .. " valid=" .. tostring(valid_candidates)
            .. " tool=" .. DebugName(item))
    end
    return worked
end

-- 进入或维持持续旋转状态（被 KiteAndAttack 在闪避阶段调用）
function WX78.TryDodgeSpin(inst)
    if inst == nil or not inst:IsValid() then return false end
    if inst.npc_character_type ~= "wx78" or inst._is_ghost_mode then return false end
    if inst.components.combat == nil then return false end

    local spin_target = inst.components.combat.target or inst._wx78_dodge_spin_target
    if spin_target == nil
        or not spin_target:IsValid()
        or (spin_target.components.health ~= nil and spin_target.components.health:IsDead()) then
        return false
    end
    inst._wx78_dodge_spin_target = spin_target

    if WX78.TryEquipSpinTool(inst) == nil then
        return false
    end

    if not inst._wx78_dodge_spin_active then
        inst._wx78_dodge_spin_active = true
        CombatLog("[NPC_WX78][持续旋转] 开始 target=" .. DebugName(spin_target)
            .. " radius=" .. tostring(NPC_TUNING.WX78_SPIN_RADIUS or 2.1))
    end
    if inst.sg ~= nil
        and not inst.sg:HasStateTag("dead")
        and not inst.sg:HasStateTag("ghost") then
        local cur = inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil
        if cur ~= "wx_spin_dodge" and cur ~= "wx_spin_start" then
            inst.sg:GoToState("wx_spin_dodge", spin_target)
        end
    end
    return true
end


function WX78.ClearDodgeSpin(inst, reason)
    if inst == nil then return end
    inst._wx78_dodge_spin_active = nil
    inst._wx78_next_dodge_spin_hit = nil

    -- 死亡/灵魂态：始终退出
    if inst.components.health ~= nil and inst.components.health:IsDead() then
        inst._wx78_dodge_spin_target = nil
        if inst.sg ~= nil
            and inst.sg.currentstate ~= nil
            and inst.sg.currentstate.name == "wx_spin_dodge" then
            inst.sg:GoToState("idle")
        end
        return
    end

    if inst.sg == nil
        or inst.sg.currentstate == nil
        or inst.sg.currentstate.name ~= "wx_spin_dodge" then
        inst._wx78_dodge_spin_target = nil
        return
    end

    if reason == "dodge_complete" then
        local combat = inst.components.combat
        local target = (combat ~= nil and combat.target) or inst._wx78_dodge_spin_target
        if target ~= nil and target:IsValid() and not inst._is_ghost_mode
            and (target.components.health == nil or not target.components.health:IsDead()) then

            if inst.components.locomotor ~= nil then
                inst.components.locomotor:Stop()
            end
            CombatLog("[NPC_WX78][持续旋转] dodge 段结束但目标存活，保持旋转")
            return
        end
    end

    -- 其它情况（行为停止/目标无效）→ 强制退出
    CombatLog("[NPC_WX78][持续旋转] 退出 reason=" .. tostring(reason or "unknown"))
    inst._wx78_dodge_spin_target = nil
    inst.sg:GoToState("idle")
end

local function EnsureSpinToolEquipped(inst)
    if inst == nil or not inst:IsValid() or inst._is_ghost_mode then return end
    if inst.npc_character_type ~= "wx78" then return end
    WX78.TryEquipSpinTool(inst)
end

-- 跳劈
local LEAP_AOE_CANT_TAGS = { "INLIMBO", "NOCLICK", "FX", "decor", "wall", "flight", "invisible", "notarget", "noattack" }
local LEAP_ELECTRIC_SOURCE = "wx78_leap"

function WX78.IsLeaping(inst)
    return inst ~= nil and inst.sg ~= nil and inst.sg:HasStateTag("wx_leaping")
end

function WX78.CanUseLeap(inst, target)
    if inst == nil or not inst:IsValid() then return false end
    if inst.npc_character_type ~= "wx78" then return false end
    -- 好感度门控：好感度 >= leap 门槛（10）才能使用跳劈
    if not npc_affinity.MeetsThreshold(inst, "leap") then return false end
    if inst._is_ghost_mode or inst:HasTag("playerghost") then return false end
    if NPC_TUNING.WX78_LEAP_ENABLED == false then return false end
    if inst.components.combat == nil then return false end
    if inst.sg == nil then return false end

    if inst._wx78_next_leap ~= nil and GetTime() < inst._wx78_next_leap then return false end

    if inst.sg:HasStateTag("wx_leaping") then return false end
    if inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("spinning") then return false end
    if inst.sg:HasAnyStateTag("dead", "ghost", "knockout", "sleeping", "waking", "frozen", "electrocute") then return false end

    if target == nil or not target:IsValid() then return false end
    if target.components.health ~= nil and target.components.health:IsDead() then return false end
    if IsFriendlyEntity(inst, target) then return false end
    if not inst.components.combat:CanTarget(target) then return false end

    local dist = math.sqrt(inst:GetDistanceSqToInst(target))
    local min_dist = NPC_TUNING.WX78_LEAP_MIN_DIST or 2
    local trigger = NPC_TUNING.WX78_LEAP_TRIGGER_RANGE or 8
    if dist < min_dist or dist > trigger then return false end

    return true
end

function WX78.ResolveLeapPos(inst, target)
    local tx, _, tz = target.Transform:GetWorldPosition()
    local mx, _, mz = inst.Transform:GetWorldPosition()
    local dx, dz = tx - mx, tz - mz
    local dist = math.sqrt(dx * dx + dz * dz)
    local max_dist = NPC_TUNING.WX78_LEAP_MAX_DIST or 10

    local pos
    if dist <= max_dist or dist <= 0.01 then
        pos = Vector3(tx, 0, tz)
    else
        local k = max_dist / dist
        pos = Vector3(mx + dx * k, 0, mz + dz * k)
    end

    local map = TheWorld ~= nil and TheWorld.Map or nil
    if map ~= nil and (not map:IsPassableAtPoint(pos.x, 0, pos.z) or map:IsGroundTargetBlocked(pos)) then
        local nd = dist > 0.01 and dist or 1
        local nx, nz = dx / nd, dz / nd
        local start_r = math.min(dist, max_dist)
        for r = start_r, 0, -0.5 do
            local px, pz = mx + nx * r, mz + nz * r
            if map:IsPassableAtPoint(px, 0, pz) and not map:IsGroundTargetBlocked(Vector3(px, 0, pz)) then
                pos = Vector3(px, 0, pz)
                break
            end
        end
    end
    return pos
end

function WX78.DoLeapAOE(inst, pos)
    if inst == nil or not inst:IsValid() or inst.components.combat == nil then return 0 end
    pos = pos or inst:GetPosition()
    local x, y, z = pos.x, 0, pos.z
    local radius        = NPC_TUNING.WX78_LEAP_RADIUS or 4
    local damage        = NPC_TUNING.WX78_LEAP_DAMAGE or 30

    local groundfx = SpawnPrefab("npc_wx78_leap_fx")
    if groundfx ~= nil then
        groundfx.Transform:SetPosition(x, 0, z)
        local s = NPC_TUNING.WX78_LEAP_FX_SCALE or (radius * 0.375)
        groundfx.AnimState:SetScale(s, s)
    end

    local electric      = NPC_TUNING.WX78_LEAP_ELECTRIC ~= false   -- 默认带电
    local friendly_fire = NPC_TUNING.WX78_LEAP_FRIENDLY_FIRE == true -- 默认不误伤友军
    local stimuli       = electric and "electric" or nil

    if electric then
        if inst.components.electricattacks == nil then
            inst:AddComponent("electricattacks")
        end
        inst.components.electricattacks:AddSource(LEAP_ELECTRIC_SOURCE)
        if inst._wx78_leap_electric_task ~= nil then
            inst._wx78_leap_electric_task:Cancel()
        end
        inst._wx78_leap_electric_task = inst:DoTaskInTime(0.2, function(i)
            i._wx78_leap_electric_task = nil
            if i.components.electricattacks ~= nil then
                i.components.electricattacks:RemoveSource(LEAP_ELECTRIC_SOURCE)
            end
        end)
    end

    local hit, friendly_skips, seen = 0, 0, {}
    for _, v in ipairs(TheSim:FindEntities(x, y, z, radius + 3, { "_combat" }, LEAP_AOE_CANT_TAGS)) do
        if v ~= inst and not seen[v] and v:IsValid() and v.entity:IsVisible()
            and v.components.combat ~= nil
            and v.components.health ~= nil and not v.components.health:IsDead() then

            if (not friendly_fire) and IsFriendlyEntity(inst, v) then
                friendly_skips = friendly_skips + 1
            elseif inst.components.combat:CanTarget(v) then
                local physrad = v.GetPhysicsRadius ~= nil and v:GetPhysicsRadius(0) or 0
                local range = radius + physrad
                if v:GetDistanceSqToPoint(x, y, z) < range * range then
                    seen[v] = true
                    v.components.combat:GetAttacked(inst, damage, nil, stimuli)
                    -- 电击命中火花（原版电击武器同款，OnAttack 里走的就是这个）
                    if electric and SpawnElectricHitSparks ~= nil then
                        SpawnElectricHitSparks(inst, v, true)
                    end
                    hit = hit + 1
                end
            end
        end
    end

    CombatLog("[NPC_WX78][锻锤跳劈] 落地结算 命中=" .. tostring(hit)
        .. " 友军跳过=" .. tostring(friendly_skips)
        .. " 半径=" .. tostring(radius)
        .. " 伤害=" .. tostring(damage)
        .. " 电击=" .. tostring(electric))
    return hit
end

function WX78.TryLeap(inst, target)
    if inst == nil or not inst:IsValid() then return false end
    target = target or (inst.components.combat ~= nil and inst.components.combat.target) or nil
    if not WX78.CanUseLeap(inst, target) then return false end

    local pos = WX78.ResolveLeapPos(inst, target)
    if pos == nil then return false end

    inst._wx78_next_leap = GetTime() + (NPC_TUNING.WX78_LEAP_COOLDOWN or 15)
    inst._wx78_dodge_spin_active = nil

    CombatLog("[NPC_WX78][锻锤跳劈] 触发 target=" .. DebugName(target)
        .. " landing=(" .. string.format("%.1f,%.1f", pos.x, pos.z) .. ")")
    inst.sg:GoToState("wx_leap_start", { target = target, pos = pos })
    return true
end

-- ════════════════════════════════════════════════════════════
-- 旋转工作阻塞
-- ════════════════════════════════════════════════════════════
function WX78.IsSpinWorkBlocked(inst)
    return inst ~= nil and inst._wx78_spin_work_blocked == true
end

function WX78.ClearSpinWorkBlock(inst, reason)
    if inst == nil or not inst._wx78_spin_work_blocked then return end
    inst._wx78_spin_work_blocked = nil
    inst._wx78_leader_was_idle = nil
    CombatLog("[NPC_WX78][旋转阻塞] 清除 reason=" .. tostring(reason or "unknown"))
end

local function PollSpinWorkBlock(inst)
    if inst == nil or not inst:IsValid() or not inst._wx78_spin_work_blocked then
        return
    end
    local follower = inst.components.follower
    local leader = follower ~= nil and follower.leader or nil
    if leader == nil or not leader:IsValid() or leader.sg == nil then
        return
    end
    local is_working = leader.sg:HasAnyStateTag("chopping", "mining")
    if not inst._wx78_leader_was_idle then
        if not is_working then
            inst._wx78_leader_was_idle = true
        end
    elseif is_working then
        WX78.ClearSpinWorkBlock(inst, "leader_resumed_work")
    end
end

function WX78.SetSpinWorkBlock(inst, reason)
    if inst == nil or not inst:IsValid() then return end
    if inst.npc_character_type ~= "wx78" then return end
    inst._wx78_spin_work_blocked = true
    inst._wx78_leader_was_idle = nil
    CombatLog("[NPC_WX78][旋转阻塞] 启用 reason=" .. tostring(reason or "unknown")
        .. " 等待玩家停下→重新砍/挖触发恢复")
    if inst._wx78_spin_block_poll_task == nil then
        inst._wx78_spin_block_poll_task = inst:DoPeriodicTask(0.25, function(self)
            PollSpinWorkBlock(self)
            if not self._wx78_spin_work_blocked and self._wx78_spin_block_poll_task ~= nil then
                self._wx78_spin_block_poll_task:Cancel()
                self._wx78_spin_block_poll_task = nil
            end
        end)
    end
end

-- 漏电短路特效（间隔在 8~20 秒之间随机）
local BODY_SPARK_MIN = 8
local BODY_SPARK_MAX = 20

local function NextSparkInterval()
    return BODY_SPARK_MIN + math.random() * (BODY_SPARK_MAX - BODY_SPARK_MIN)
end

local function ScheduleBodySpark(inst)
    inst._wx78_body_spark_task = inst:DoTaskInTime(NextSparkInterval(), function(i)
        i._wx78_body_spark_task = nil
        if not (i._is_ghost_mode or i:HasTag("playerghost")
            or (i.components.health ~= nil and i.components.health:IsDead())) then
            local x, y, z = i.Transform:GetWorldPosition()
            SpawnPrefab("sparks").Transform:SetPosition(
                x + (math.random() - 0.5) * 0.5,
                y + 1 + math.random() * 1.5,
                z + (math.random() - 0.5) * 0.5)
        end
        ScheduleBodySpark(i)
    end)
end

function WX78.StartBodySparkFx(inst)
    if inst == nil or inst._wx78_body_spark_task ~= nil then return end
    ScheduleBodySpark(inst)
end

return {
    on_death = function(inst)
        WX78.ClearDodgeSpin(inst, "death")
        WX78.ClearSpinWorkBlock(inst, "death")
        if inst._wx78_spin_block_poll_task ~= nil then
            inst._wx78_spin_block_poll_task:Cancel()
            inst._wx78_spin_block_poll_task = nil
        end
        return false
    end,

    on_apply = function(inst)
        inst._is_wx78 = true
        inst:AddTag("soulless")
        if inst.AnimState ~= nil then
            inst.AnimState:AddOverrideBuild("player_wx78_actions")
            inst.AnimState:AddOverrideBuild("player_attack_leap")  
        end

        inst:DoTaskInTime(0.5, EnsureSpinToolEquipped)
        WX78.StartBodySparkFx(inst)
        if not inst._wx78_spin_events_inited then
            inst._wx78_spin_events_inited = true
            inst:ListenForEvent("newcombattarget", EnsureSpinToolEquipped)
            inst:ListenForEvent("attacked", EnsureSpinToolEquipped)
        end
    end,

    CanSpinUsingItem = WX78.CanSpinUsingItem,
    FindSpinTool = WX78.FindSpinTool,
    TryEquipSpinTool = WX78.TryEquipSpinTool,
    CanUseSpinAttack = WX78.CanUseSpinAttack,
    DoSpinAttack = WX78.DoSpinAttack,
    CanUseSpinWork = WX78.CanUseSpinWork,
    DoSpinWork = WX78.DoSpinWork,
    TryDodgeSpin = WX78.TryDodgeSpin,
    ClearDodgeSpin = WX78.ClearDodgeSpin,
    IsLeaping = WX78.IsLeaping,
    CanUseLeap = WX78.CanUseLeap,
    ResolveLeapPos = WX78.ResolveLeapPos,
    DoLeapAOE = WX78.DoLeapAOE,
    TryLeap = WX78.TryLeap,
    IsSpinWorkBlocked = WX78.IsSpinWorkBlocked,
    SetSpinWorkBlock = WX78.SetSpinWorkBlock,
    ClearSpinWorkBlock = WX78.ClearSpinWorkBlock,
    StartBodySparkFx = WX78.StartBodySparkFx,
}
