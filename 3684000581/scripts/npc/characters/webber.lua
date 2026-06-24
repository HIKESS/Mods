-- scripts/npc/characters/webber.lua
-- Webber（敌对NPC）：
-- 1) 对玩家/NPC/召唤物均为敌对
-- 2) 禁止招募（移除喂食入口）
-- 3) 禁用左键/右键NPC UI（通过 npc_no_ui 标签给外部模块判断）

local hostile_combat = require("npc/npc_hostile_combat")
local NPC_TUNING = require("npc_tuning")
local WEBBER_GHOST_LOOT = require("npc/webber_ghost_loot")
local DropWebberGhostLoot

local function IsValidAssistAttacker(attacker)
    if not attacker or not attacker:IsValid() then return false end
    if attacker:HasTag("playerghost") then return false end
    if attacker:HasTag("spider") then return false end
    if attacker.components and attacker.components.health and attacker.components.health:IsDead() then return false end
    return true
end

local function CallNearbySpidersAssistWebber(inst, attacker)
    if not IsValidAssistAttacker(attacker) then return end
    local x, y, z = inst.Transform:GetWorldPosition()
    local spiders = TheSim:FindEntities(x, y, z, 20, { "spider", "_combat" }, { "INLIMBO", "playerghost" })
    for _, s in ipairs(spiders) do
        if s ~= inst and s:IsValid()
           and s.components and s.components.combat
           and s.components.combat:CanTarget(attacker) then
            s.components.combat:SetTarget(attacker)
        end
    end
end

local function StartWebberGhostDespawn(inst)
    if not inst or not inst:IsValid() then return end
    if not inst._is_webber then return end
    if not inst._is_ghost_mode then return end
    if inst._webber_ghost_despawn_task then
        inst._webber_ghost_despawn_task:Cancel()
        inst._webber_ghost_despawn_task = nil
    end

    local delay = NPC_TUNING.HOSTILE_WEBBER_GHOST_DESPAWN_DELAY or 5
    inst._webber_ghost_despawn_task = inst:DoTaskInTime(delay, function(i)
        i._webber_ghost_despawn_task = nil
        if not i:IsValid() or not i._is_ghost_mode then return end
        if i.sg and i.sg:HasState("ghost_despawn") then
            i.sg:GoToState("ghost_despawn")
        else
            i.AnimState:PlayAnimation("dissipate")
            i.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt", nil, nil, true)
            i:DoTaskInTime(1.5, function(i2)
                if i2:IsValid() and i2._is_ghost_mode then
                    i2:Remove()
                end
            end)
        end
    end)
end

local function EnsureWebberGhostFlow(inst)
    if not inst or not inst:IsValid() then return end
    local tries = 0
    local function _TryStart(i)
        if not i or not i:IsValid() then return end
        if i._is_ghost_mode then
            DropWebberGhostLoot(i)
            StartWebberGhostDespawn(i)
            return
        end
        tries = tries + 1
        if tries < 30 then
            i:DoTaskInTime(0.1, _TryStart)
        end
    end
    _TryStart(inst)
end

local function PickWeightedPrefab(items)
    return hostile_combat.PickWeightedPrefab(items)
end

local function SpawnLootAt(inst, prefab)
    return hostile_combat.SpawnLootAt(inst, prefab)
end

DropWebberGhostLoot = function(inst)
    if not inst or not inst:IsValid() then return end
    if not inst._is_webber then return end
    if not TheWorld or not TheWorld.ismastersim then return end
    if inst._webber_ghost_loot_dropped then return end

    local mode = WEBBER_GHOST_LOOT and WEBBER_GHOST_LOOT.MODE or "flat_weighted"
    local dropped_any = false

    if mode == "group_chance" and WEBBER_GHOST_LOOT and type(WEBBER_GHOST_LOOT.GROUP_ROLLS) == "table" then
        for _, group in ipairs(WEBBER_GHOST_LOOT.GROUP_ROLLS) do
            local chance = (type(group) == "table" and tonumber(group.chance)) or 0
            if chance > 0 and math.random() <= chance then
                local pick = (type(group) == "table" and tonumber(group.pick)) or 1
                pick = math.max(1, math.floor(pick))
                local gitems = (type(group) == "table" and group.items) or nil
                for i = 1, pick do
                    local prefab = PickWeightedPrefab(gitems)
                    if SpawnLootAt(inst, prefab) then
                        dropped_any = true
                    end
                end
            end
        end
        inst._webber_ghost_loot_dropped = true
        return
    end

    local items = WEBBER_GHOST_LOOT and WEBBER_GHOST_LOOT.ITEMS or nil
    if type(items) ~= "table" or #items == 0 then
        inst._webber_ghost_loot_dropped = true
        return
    end

    local min_count = tonumber(NPC_TUNING.HOSTILE_WEBBER_GHOST_LOOT_MIN) or 1
    local max_count = tonumber(NPC_TUNING.HOSTILE_WEBBER_GHOST_LOOT_MAX) or 2
    min_count = math.floor(min_count)
    max_count = math.floor(max_count)
    if min_count < 0 then min_count = 0 end
    if max_count < 0 then max_count = 0 end
    if max_count < min_count then
        min_count, max_count = max_count, min_count
    end

    local count = (max_count > min_count) and math.random(min_count, max_count) or min_count
    if count <= 0 then
        inst._webber_ghost_loot_dropped = true
        return
    end

    for i = 1, count do
        local prefab = PickWeightedPrefab(items)
        if SpawnLootAt(inst, prefab) then
            dropped_any = true
        end
    end

    inst._webber_ghost_loot_dropped = true
end

local function CancelWebberGhostDespawn(inst)
    if inst and inst._webber_ghost_despawn_task then
        inst._webber_ghost_despawn_task:Cancel()
        inst._webber_ghost_despawn_task = nil
    end
end

local function ClearWebberHomeAnchor(inst)
    inst._webber_home_x = nil
    inst._webber_home_z = nil
end

return {
    on_apply = function(inst, stats)
        inst._is_webber = true
        inst._is_hostile_npc = true

        if not inst:HasTag("npc_hostile") then
            inst:AddTag("npc_hostile")
        end
        -- 敌对韦伯不应保留“同伴”身份，否则可能被玩家侧逻辑视为不可主动攻击
        if inst:HasTag("companion") then
            inst:RemoveTag("companion")
        end
        if not inst:HasTag("spiderqueen") then
            inst:AddTag("spiderqueen")
        end
        -- 蜘蛛同类识别：避免蜘蛛将韦伯当敌人
        if not inst:HasTag("spiderwhisperer") then
            inst:AddTag("spiderwhisperer")
        end
        if not inst:HasTag("spiderdisguise") then
            inst:AddTag("spiderdisguise")
        end
        if not inst:HasTag("npc_no_ui") then
            inst:AddTag("npc_no_ui")
        end
        inst.inherentsceneaction = nil
        inst.inherentscenealtaction = nil

        -- 敌对单位必须可被锁定
        if inst:HasTag("notarget") then
            inst:RemoveTag("notarget")
        end

        -- 禁止通过喂食动作招募（保留 eater 组件供系统兼容）
        if inst:HasTag("handfed") then
            inst:RemoveTag("handfed")
        end
        if inst:HasTag("fedbyall") then
            inst:RemoveTag("fedbyall")
        end
        if inst:HasTag("OMNI_eater") then
            inst:RemoveTag("OMNI_eater")
        end

        if inst.components and inst.components.follower then
            inst.components.follower:SetLeader(nil)
        end
        inst._owner_userid = nil
        if inst.owner_userid then
            inst.owner_userid:set("")
        end

        -- 韦伯视作蜘蛛阵营：忽略蜘蛛网地皮减速（仅对韦伯生效）
        if inst.components and inst.components.locomotor then
            inst.components.locomotor:SetTriggersCreep(false)
            local caps = inst.components.locomotor.pathcaps or {}
            if caps.ignorecreep ~= true then
                caps.ignorecreep = true
                inst.components.locomotor.pathcaps = caps
            end
        end

        hostile_combat.Attach(inst)

        if not inst._webber_death_listener_added then
            inst._webber_death_listener_added = true
            inst:ListenForEvent("death", function(i)
                -- 死亡后立即清除追击锚点；下次重生/重刷再写入新锚点
                ClearWebberHomeAnchor(i)
                i:DoTaskInTime(0, function(i2)
                    EnsureWebberGhostFlow(i2)
                end)
            end)
        end
        if not inst._webber_attacked_assist_listener_added then
            inst._webber_attacked_assist_listener_added = true
            inst:ListenForEvent("attacked", function(i, data)
                if i._is_ghost_mode then return end
                local attacker = data and data.attacker or nil
                CallNearbySpidersAssistWebber(i, attacker)
            end)
        end
        if not inst._webber_onremove_listener_added then
            inst._webber_onremove_listener_added = true
            inst:ListenForEvent("onremove", function(i)
                CancelWebberGhostDespawn(i)
            end)
        end
    end,

    on_save = function(inst, data)
        if inst._webber_home_x ~= nil and inst._webber_home_z ~= nil then
            data.webber_home_x = inst._webber_home_x
            data.webber_home_z = inst._webber_home_z
        end
    end,

    on_load = function(inst, data)
        if data and data.webber_home_x ~= nil and data.webber_home_z ~= nil then
            inst._webber_home_x = data.webber_home_x
            inst._webber_home_z = data.webber_home_z
        end
        if inst._is_ghost_mode then
            StartWebberGhostDespawn(inst)
        else
            CancelWebberGhostDespawn(inst)
        end
    end,
}
