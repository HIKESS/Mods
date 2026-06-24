-- scripts/npc/characters/wickerbottom.lua
-- Wickerbottom: 12格背包 + 辅助效果（灭火、调温、解湿）+ 战斗技能（蜂卫、闪电）
-- 所有效果均在读书动画（npc_book）第20帧回调中执行

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")
local npc_affinity = require("npc/npc_affinity")

local function IsFriendlyNPC(target)
    return target and target:HasTag("npcfriend") and not target:HasTag("npc_hostile")
end

local BEE_RETARGET_CANT_TAGS = { "INLIMBO", "playerghost", "FX", "DECOR", "wall" }

local function IsValidBeeEnemy(target)
    if not target or not target:IsValid() then return false end
    if not target.components.health or target.components.health:IsDead() then return false end
    if target:HasTag("player") or target:HasTag("companion") or target:HasTag("npcfriend_companion") then
        return false
    end
    if IsFriendlyNPC(target) then return false end
    if target._is_ghost_mode or target:HasTag("ghost") then return false end
    return true
end

local function BeeRetargetFn(bee)
    local leader = bee._friendref
    if leader and leader:IsValid() and leader.components.combat then
        local ltarget = leader.components.combat.target
        if IsValidBeeEnemy(ltarget) then
            return ltarget
        end
    end

    local x, y, z = bee.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 16, { "_combat", "_health" }, BEE_RETARGET_CANT_TAGS)
    for _, v in ipairs(ents) do
        if v ~= bee and IsValidBeeEnemy(v) then
            if v:HasTag("npc_hostile") then
                return v
            end
            if v.components.combat and leader
               and (v.components.combat.target == leader or v.components.combat.target == bee) then
                return v
            end
        end
    end
    return nil
end

local function BeeKeepTargetFn(bee, target)
    return IsValidBeeEnemy(target) and bee:IsNear(target, 20)
end

-- ════════════════════════════════════════════════════════════
--  通用工具
-- ════════════════════════════════════════════════════════════

-- 不可打断的状态名（死亡/幽灵/冻结/变身等）
local SKIP_READ_STATES = {
    death = true, ghost_idle = true, revive_from_ghost = true,
    frozen = true, frozen_loop = true,
    weremoose_transform = true, weremoose_revert = true,
    moose_tackle_pre = true, moose_tackle_start = true,
    moose_tackle = true, moose_tackle_collide = true,
    npc_book = true,  -- 已在读书中，不重复进入
}

-- 强制进入读书状态并在动画中执行回调
-- callback(inst) 会在动画第20帧触发
local function ForceBookAction(inst, callback)
    if not inst.sg then
        callback(inst)
        return true
    end
    local cur = inst.sg.currentstate and inst.sg.currentstate.name
    if cur and SKIP_READ_STATES[cur] then return false end
    inst._on_book_action = callback
    inst.sg:GoToState("npc_book")
    return true
end

local GROW_CANT_TAGS = { "INLIMBO", "FX", "NOCLICK", "DECOR", "player", "playerghost", "npcfriend" }

local function TryGrowEntity(ent, caster)
    if ent == nil or not ent:IsValid() or ent == caster then
        return false
    end

    local changed = false
    local components = ent.components
    if components == nil then
        return false
    end

    if components.farmplanttendable ~= nil and components.farmplanttendable.TendTo ~= nil then
        _G.pcall(function()
            components.farmplanttendable:TendTo(caster)
        end)
    end

    local pickable = components.pickable
    if pickable ~= nil and pickable.CanBePicked ~= nil and not pickable:CanBePicked()
       and pickable.FinishGrowing ~= nil then
        local ok = _G.pcall(function()
            pickable:FinishGrowing()
        end)
        if ok and pickable.CanBePicked ~= nil and pickable:CanBePicked() then
            changed = true
        end
    end

    local growable = components.growable
    if growable ~= nil then
        if growable.Resume ~= nil then
            _G.pcall(function()
                growable:Resume()
            end)
        end

        local old_stage = growable.GetStage ~= nil and growable:GetStage() or nil
        local steps = NPC_TUNING.SCHOLAR_GROWTH_STEPS or 3
        for _ = 1, steps do
            if growable.DoGrowth == nil then
                break
            end
            local ok = _G.pcall(function()
                growable:DoGrowth()
            end)
            if not ok then
                break
            end
        end
        local new_stage = growable.GetStage ~= nil and growable:GetStage() or nil
        if old_stage ~= nil and new_stage ~= nil and new_stage ~= old_stage then
            changed = true
        elseif growable.DoGrowth ~= nil then
            changed = true
        end
    end

    return changed
end

local function DoGrowNearbyCrops(inst)
    local radius = NPC_TUNING.SCHOLAR_GROWTH_RADIUS or NPC_TUNING.SCHOLAR_CARE_RADIUS or 20
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, nil, GROW_CANT_TAGS)
    local count = 0

    for _, ent in ipairs(ents) do
        if TryGrowEntity(ent, inst) then
            count = count + 1
        end
    end

    if inst.components.talker ~= nil then
        local pool = count > 0 and NPC_SPEECH.SCHOLAR_GROWTH_SUCCESS or NPC_SPEECH.SCHOLAR_GROWTH_NONE
        local line = NPC_SPEECH.GetLine(pool, inst.npc_character_type)
        if line ~= nil then
            inst.components.talker:Say(line)
        end
    end
end

local function TriggerGrowthBook(inst)
    if inst == nil or not inst:IsValid() or inst._is_ghost_mode then
        return false
    end
    if inst.components.health ~= nil and inst.components.health:IsDead() then
        return false
    end
    return ForceBookAction(inst, DoGrowNearbyCrops)
end

-- ════════════════════════════════════════════════════════════
--  辅助效果（灭火、调温、解湿）— 被动光环
-- ════════════════════════════════════════════════════════════

local FIRE_ONEOF_TAGS = { "fire", "smolder" }
local FIRE_CANT_TAGS  = { "player", "FX", "NOCLICK", "DECOR", "INLIMBO" }

-- 玩家照明设施白名单：不灭这些（篝火、火坑、冰篝火、冰火坑）
local LIGHT_SOURCE_PREFABS = {
    campfire = true,
    firepit = true,
    coldfire = true,
    coldfirepit = true,
}

local function ExtinguishFires(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local fires = TheSim:FindEntities(x, y, z, radius, nil, FIRE_CANT_TAGS, FIRE_ONEOF_TAGS)
    local count = 0
    for _, ent in ipairs(fires) do
        if ent.components.burnable and not LIGHT_SOURCE_PREFABS[ent.prefab] then
            ent.components.burnable:Extinguish(true, 0)
            count = count + 1
        end
    end
    return count
end

local function CareForPlayers(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, radius, true)
    local temp_target    = NPC_TUNING.SCHOLAR_TEMP_TARGET    or 35
    local temp_threshold = NPC_TUNING.SCHOLAR_TEMP_THRESHOLD or 20
    local helped_temp = false
    local helped_dry  = false

    for _, player in pairs(players) do
        if player.components.temperature then
            local cur = player.components.temperature:GetCurrent()
            if math.abs(cur - temp_target) > temp_threshold then
                player.components.temperature:SetTemperature(temp_target)
                if player.SoundEmitter then
                    player.SoundEmitter:PlaySound("dontstarve/HUD/health_up")
                end
                helped_temp = true
            end
        end

        local moist_threshold = NPC_TUNING.SCHOLAR_MOISTURE_THRESHOLD or 30
        if player.components.moisture and player.components.moisture:GetMoisture() > moist_threshold then
            player.components.moisture:SetMoistureLevel(0)
            if player.components.inventory then
                local items = player.components.inventory:ReferenceAllItems()
                for _, item in ipairs(items) do
                    if item.components.inventoryitem then
                        item.components.inventoryitem:DryMoisture()
                    end
                end
            end
            if player.SoundEmitter then
                player.SoundEmitter:PlaySound("dontstarve/HUD/health_up")
            end
            helped_dry = true
        end
    end
    return helped_temp, helped_dry
end

-- 被动辅助定期检查
local function ScholarCareCheck(inst)
    if inst._is_ghost_mode or not inst:IsValid() then return end
    if inst:IsInLimbo() then return end

    local radius = NPC_TUNING.SCHOLAR_CARE_RADIUS or 20

    -- 好感度门控：好感度 >= scholar_extinguish（30）解锁自动灭火；>= scholar_care（50）解锁自动控温 / 除湿
    local can_extinguish = npc_affinity.MeetsThreshold(inst, "scholar_extinguish")
    local can_care = npc_affinity.MeetsThreshold(inst, "scholar_care")
    if not can_extinguish and not can_care then return end

    -- 检测是否有需要处理的火焰（排除照明设施）
    local x, y, z = inst.Transform:GetWorldPosition()
    local has_fires = false
    if can_extinguish then
        local fire_ents = TheSim:FindEntities(x, y, z, radius, nil, FIRE_CANT_TAGS, FIRE_ONEOF_TAGS)
        for _, ent in ipairs(fire_ents) do
            if not LIGHT_SOURCE_PREFABS[ent.prefab] then
                has_fires = true
                break
            end
        end
    end

    local need_temp, need_dry = false, false
    if can_care and not has_fires then
        local temp_target    = NPC_TUNING.SCHOLAR_TEMP_TARGET    or 35
        local temp_threshold = NPC_TUNING.SCHOLAR_TEMP_THRESHOLD or 20
        local moist_threshold = NPC_TUNING.SCHOLAR_MOISTURE_THRESHOLD or 30
        local players = FindPlayersInRange(x, y, z, radius, true)
        for _, player in pairs(players) do
            if not need_temp and player.components.temperature then
                local cur = player.components.temperature:GetCurrent()
                if math.abs(cur - temp_target) > temp_threshold then
                    need_temp = true
                end
            end
            if not need_dry and player.components.moisture
               and player.components.moisture:GetMoisture() > moist_threshold then
                need_dry = true
            end
        end
    end

    if not has_fires and not need_temp and not need_dry then return end

    ForceBookAction(inst, function(i)
        local now = GetTime()
        local cd  = NPC_TUNING.SCHOLAR_CARE_SAY_CD or 2
        local can_say = i.components.talker
                    and (not i._scholar_care_last_say or now - i._scholar_care_last_say > cd)

        if can_extinguish then
            local fire_count = ExtinguishFires(i, radius)
            if fire_count > 0 then
                if can_say then
                    i._scholar_care_last_say = now
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.SCHOLAR_EXTINGUISH, i.npc_character_type)
                    if line then i.components.talker:Say(line) end
                end
                return
            end
        end

        if not can_care then return end
        local helped_temp, helped_dry = CareForPlayers(i, radius)
        if helped_temp and can_say then
            i._scholar_care_last_say = now
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.SCHOLAR_TEMPERATURE, i.npc_character_type)
            if line then i.components.talker:Say(line) end
        elseif helped_dry and can_say then
            i._scholar_care_last_say = now
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.SCHOLAR_DRY, i.npc_character_type)
            if line then i.components.talker:Say(line) end
        end
    end)
end

-- ════════════════════════════════════════════════════════════
--  战斗技能 — 蜂卫召唤
-- ════════════════════════════════════════════════════════════

local function CleanupBees(inst)
    if not inst._scholar_bees then return end
    local alive = {}
    for _, bee in ipairs(inst._scholar_bees) do
        if bee:IsValid() and bee.components.health and not bee.components.health:IsDead() then
            table.insert(alive, bee)
        end
    end
    inst._scholar_bees = alive
end

local function ConfigureFriendlyBee(inst, bee)
    bee._friendid = "npc_wickerbottom"
    bee:RemoveTag("hostile")
    if not bee:HasTag("NOBLOCK") then bee:AddTag("NOBLOCK") end
    if not bee:HasTag("companion") then bee:AddTag("companion") end
    if not bee:HasTag("npcfriend_companion") then bee:AddTag("npcfriend_companion") end
    bee._friendref = inst

    if bee.components.combat and not bee._npc_settarget_wrapped then
        bee._npc_settarget_wrapped = true
        local _orig_SetTarget = bee.components.combat.SetTarget
        bee.components.combat.SetTarget = function(self, target)
            if target and target:HasTag("player") then return end
            return _orig_SetTarget(self, target)
        end
        bee.components.combat:SetRetargetFunction(1, BeeRetargetFn)
        bee.components.combat:SetKeepTargetFunction(BeeKeepTargetFn)
    end

    if bee.components.follower then
        bee.components.follower:SetLeader(inst)
    end

    bee:ListenForEvent("onremove", function()
        CleanupBees(inst)
    end)

    if bee._lifetime_task then
        bee._lifetime_task:Cancel()
    end
    local lifetime = NPC_TUNING.SCHOLAR_BEE_LIFETIME or 120
    bee._lifetime_task = bee:DoTaskInTime(lifetime, function()
        if bee:IsValid() and bee.components.health
           and not bee.components.health:IsDead() then
            bee.components.health:Kill()
        end
    end)

    if bee._leash_task then
        bee._leash_task:Cancel()
    end
    local leash_dist_sq = 40 * 40
    bee._leash_task = bee:DoPeriodicTask(5, function()
        if not bee:IsValid() or not inst:IsValid() then return end
        if bee.components.health and bee.components.health:IsDead() then return end
        local bx, _, bz = bee.Transform:GetWorldPosition()
        local ix, _, iz = inst.Transform:GetWorldPosition()
        if (bx - ix) * (bx - ix) + (bz - iz) * (bz - iz) > leash_dist_sq then
            bee.components.health:Kill()
        end
    end)
end

local function DoSummonBees(inst)
    local count = NPC_TUNING.SCHOLAR_BEE_COUNT or 6
    local max   = NPC_TUNING.SCHOLAR_BEE_MAX   or 16

    CleanupBees(inst)
    local current = inst._scholar_bees and #inst._scholar_bees or 0
    local to_spawn = math.min(count, max - current)
    if to_spawn <= 0 then return end

    local x, y, z = inst.Transform:GetWorldPosition()
    local radius = 2
    local delta = (2 * math.pi) / to_spawn

    for i = 1, to_spawn do
        inst:DoTaskInTime(0.15 * i, function()
            if not inst:IsValid() then return end
            local angle = (i - 1) * delta
            local px = x + radius * math.cos(angle)
            local pz = z + radius * math.sin(angle)

            local bee = SpawnPrefab("beeguard")
            if bee then
                bee.Transform:SetPosition(px, 0, pz)
                local poof = SpawnPrefab("bee_poof_big")
                if poof then poof.Transform:SetPosition(px, 0, pz) end

                table.insert(inst._scholar_bees, bee)
                ConfigureFriendlyBee(inst, bee)

                local target = inst.components.combat and inst.components.combat.target
                if target and target:IsValid() and bee.components.combat then
                    bee.components.combat:SetTarget(target)
                end
            end
        end)
    end

    -- 台词
    if inst.components.talker then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.SCHOLAR_BEE_SUMMON, inst.npc_character_type)
        if line then inst.components.talker:Say(line) end
    end
end

-- ════════════════════════════════════════════════════════════
--  战斗技能 — 闪电
-- ════════════════════════════════════════════════════════════

local LIGHTNING_CANT_TAGS = { "INLIMBO", "FX", "NOCLICK", "DECOR", "playerghost" }

-- 对单个实体施加闪电效果（区分友方/敌方）
local function ApplyLightningToEntity(ent, caster)
    if not ent:IsValid() or ent == caster then return end
    if not ent.components.health or ent.components.health:IsDead() then return end

    local is_friendly = ent:HasTag("player") or IsFriendlyNPC(ent)
    local dmg
    if ent:HasTag("npc_hostile") then
        dmg = NPC_TUNING.SCHOLAR_LIGHTNING_HOSTILE_DMG or 5
    elseif is_friendly then
        dmg = NPC_TUNING.SCHOLAR_LIGHTNING_FRIENDLY_DMG or 0.1
    else
        local base = NPC_TUNING.SCHOLAR_LIGHTNING_DAMAGE or 10
        local wet_mult = (TUNING.ELECTRIC_WET_DAMAGE_MULT or 1)
                       * (ent.GetWetMultiplier and ent:GetWetMultiplier() or 0)
        dmg = base + wet_mult * base
    end

    ent.components.health:DoDelta(-dmg, false, "lightning")

    if ent.sg then
        local use_electrocute = ent.sg:HasState("electrocute")
                                and not ent:HasTag("weremoose")
                                and not ent.sg:HasAnyStateTag("dead", "noelectrocute")
        if use_electrocute then
            ent.sg:GoToState("electrocute")
        elseif ent.sg:HasState("hit")
           and not ent.sg:HasAnyStateTag("dead", "nointerrupt") then
            ent.sg:GoToState("hit")
        end
    end
end

local LIGHTNING_TARGET_MUST = { "_health" }
local LIGHTNING_TARGET_CANT = { "INLIMBO", "FX", "NOCLICK", "DECOR", "playerghost", "wall", "structure", "abigail", "shadowminion", "npc_bernie", "npcfriend_companion" }

local function DoCastLightning(inst)
    local num = NPC_TUNING.SCHOLAR_LIGHTNING_COUNT or 16
    local target = inst.components.combat and inst.components.combat.target
    local pt
    if target and target:IsValid() then
        pt = target:GetPosition()
    else
        pt = inst:GetPosition()
    end

    local search_radius = NPC_TUNING.SCHOLAR_LIGHTNING_RADIUS or 15
    local candidates = TheSim:FindEntities(pt.x, pt.y, pt.z, search_radius,
        LIGHTNING_TARGET_MUST, LIGHTNING_TARGET_CANT)
    -- 过滤无效目标
    local valid = {}
    for _, ent in ipairs(candidates) do
        if ent ~= inst and ent:IsValid()
           and ent.components.health and not ent.components.health:IsDead() then
            table.insert(valid, ent)
        end
    end

    inst:StartThread(function()
        for k = 0, num - 1 do
            local chosen = nil
            for attempt = 1, 3 do
                if #valid <= 0 then break end
                local idx = math.random(#valid)
                local v = valid[idx]
                if v:IsValid() and not v.components.health:IsDead() then
                    chosen = v
                    break
                else
                    table.remove(valid, idx)
                end
            end

            if chosen then
                local pos = chosen:GetPosition()
                SpawnPrefab("lightning").Transform:SetPosition(pos:Get())
                ApplyLightningToEntity(chosen, inst)
            else
                local rad = math.random(3, 15)
                local angle = math.random() * 2 * math.pi
                local pos = pt + Vector3(rad * math.cos(angle), 0, rad * math.sin(angle))
                SpawnPrefab("lightning").Transform:SetPosition(pos:Get())
            end

            Sleep(.3 + math.random() * .2)
        end
    end)

    -- 台词
    if inst.components.talker then
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.SCHOLAR_LIGHTNING, inst.npc_character_type)
        if line then inst.components.talker:Say(line) end
    end
end

-- ════════════════════════════════════════════════════════════
--  被纵火报复 —— 薇洛点火后读书劫一道闪电
-- ════════════════════════════════════════════════════════════

local function ScholarRetaliateArson(inst, arsonist)
    if not inst:IsValid() or inst._is_ghost_mode then return end
    if not arsonist or not arsonist:IsValid() then return end

    inst:DoTaskInTime(1.5, function()
        if not inst:IsValid() or inst._is_ghost_mode then return end
        if not arsonist:IsValid() then return end

        if inst.components.health then
            inst.components.health.takingfiredamage = false
        end

        ForceBookAction(inst, function(caster)
            if not arsonist:IsValid() then return end

            local pos = arsonist:GetPosition()
            SpawnPrefab("lightning").Transform:SetPosition(pos:Get())
            ApplyLightningToEntity(arsonist, caster)

            if caster.components.talker then
                local line = NPC_SPEECH.GetLine(NPC_SPEECH.SCHOLAR_ARSON_RETALIATE, caster.npc_character_type)
                if line then caster.components.talker:Say(line) end
            end

            arsonist:DoTaskInTime(1, function()
                if arsonist:IsValid() and arsonist.components.talker then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.ARSON_ELECTROCUTED, arsonist.npc_character_type)
                    if line then arsonist.components.talker:Say(line) end
                end
            end)
        end)
    end)
end

-- ════════════════════════════════════════════════════════════
--  战斗技能定期检查
-- ════════════════════════════════════════════════════════════

local function ScholarCombatCheck(inst)
    if inst._is_ghost_mode or not inst:IsValid() then return end
    if inst:IsInLimbo() then return end

    local target = inst.components.combat and inst.components.combat.target
    if not target or not target:IsValid() then return end

    if inst._on_book_action then return end

    local now = GetTime()

    CleanupBees(inst)
    local bee_max = NPC_TUNING.SCHOLAR_BEE_MAX or 16
    local bee_current = inst._scholar_bees and #inst._scholar_bees or 0
    local bee_cd = NPC_TUNING.SCHOLAR_BEE_COOLDOWN or 60

    if bee_current < bee_max
       and (not inst._scholar_bee_time or now - inst._scholar_bee_time >= bee_cd) then
        inst._scholar_bee_time = now
        ForceBookAction(inst, function(i) DoSummonBees(i) end)
        return
    end

    local lightning_cd = NPC_TUNING.SCHOLAR_LIGHTNING_CD or 30
    if not inst._scholar_lightning_time or now - inst._scholar_lightning_time >= lightning_cd then
        inst._scholar_lightning_time = now
        ForceBookAction(inst, function(i) DoCastLightning(i) end)
    end
end

-- ════════════════════════════════════════════════════════════
--  定期任务管理
-- ════════════════════════════════════════════════════════════

local function StartScholarTasks(inst)
    if not inst._scholar_care_task then
        inst._scholar_care_task = inst:DoPeriodicTask(
            NPC_TUNING.SCHOLAR_CARE_INTERVAL or 5,
            ScholarCareCheck)
    end
    if not inst._scholar_combat_task then
        inst._scholar_combat_task = inst:DoPeriodicTask(
            NPC_TUNING.SCHOLAR_COMBAT_INTERVAL or 3,
            ScholarCombatCheck)
    end
end

local function StopScholarTasks(inst)
    if inst._scholar_care_task then
        inst._scholar_care_task:Cancel()
        inst._scholar_care_task = nil
    end
    if inst._scholar_combat_task then
        inst._scholar_combat_task:Cancel()
        inst._scholar_combat_task = nil
    end
end

-- ════════════════════════════════════════════════════════════
--  导出模块
-- ════════════════════════════════════════════════════════════

return {
    on_apply = function(inst, stats)
        inst._is_wickerbottom = true
        inst._scholar_bees = {}
        inst._scholar_growth_cast_count = math.max(0, math.floor(tonumber(inst._scholar_growth_cast_count) or 0))
        inst.DoWickerbottomGrowCrops = TriggerGrowthBook

        StartScholarTasks(inst)

        inst:ListenForEvent("arson_fire_applied", function(i, data)
            if data and data.arsonist then
                ScholarRetaliateArson(i, data.arsonist)
            end
        end)

        inst:ListenForEvent("npc_pre_migration", function(i)
            StopScholarTasks(i)
        end)

        if not inst._wickerbottom_remove_listener then
            inst._wickerbottom_remove_listener = true
            inst:ListenForEvent("onremove", function()
                StopScholarTasks(inst)
            end)
        end
    end,

    on_save = function(inst, data)
        local count = math.max(0, math.floor(tonumber(inst._scholar_growth_cast_count) or 0))
        if count > 0 then
            data.scholar_growth_cast_count = count
        end
    end,

    on_death = function(inst)
        StopScholarTasks(inst)
        return false  
    end,

    restart_scholar_tasks = function(inst)
        inst._scholar_bees = inst._scholar_bees or {}
        StartScholarTasks(inst)
    end,

    on_load = function(inst, data)
        inst._scholar_bees = inst._scholar_bees or {}
        inst._scholar_growth_cast_count = math.max(0, math.floor(tonumber(data and data.scholar_growth_cast_count) or 0))
        StartScholarTasks(inst)

        inst:DoTaskInTime(1, function()
            if not inst:IsValid() then return end
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 40,
                { "npcfriend_companion" }, { "INLIMBO" })
            for _, bee in ipairs(ents) do
                if bee.prefab == "beeguard" and bee:IsValid()
                   and bee.components.health and not bee.components.health:IsDead() then
                    table.insert(inst._scholar_bees, bee)
                    ConfigureFriendlyBee(inst, bee)
                end
            end
        end)
    end,
}
