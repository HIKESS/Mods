-- npc_hostile_spawn.lua
-- NPCFriends 敌对NPC生成模块
-- 从 modmain.lua 提取的敌对韦伯/沃特生成逻辑、蜘蛛协助、死亡CD等


local HostileSpawn = {}

--------------------------------------------------------------------------
-- 调试日志
--------------------------------------------------------------------------
local function _WebberEquipDbg(fmt, ...)
    local NPC_TUNING_REF = require("npc_tuning")
    if not (NPC_TUNING_REF and NPC_TUNING_REF.HOSTILE_WEBBER_EQUIP_DEBUG) then
        return
    end
    local prefix = "[WebberEquipDbg] "
    print(prefix .. string.format(fmt, ...))
end

--------------------------------------------------------------------------
-- 韦伯（Webber）相关
--------------------------------------------------------------------------

local function HasAnyWebberAlive()
    for _, ent in pairs(_G.Ents) do
        if ent and ent:IsValid()
           and ent:HasTag("npcfriend")
           and ent.npc_character_type == "webber" then
            return true
        end
    end
    return false
end

local function GetWebberRespawnCdUntil()
    local world = _G.TheWorld
    return (world and world._webber_respawn_cd_until) or 0
end

local function SpawnHostileWebberNearDen(den, attacker)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return nil end
    if HasAnyWebberAlive() then return nil end

    local npc = _G.SpawnPrefab("npcfriend")
    if not npc then return nil end

    local x, y, z = den.Transform:GetWorldPosition()
    local map = _G.TheWorld.Map
    local spawn_x, spawn_z = x, z
    local off = _G.FindValidPositionByFan(math.random() * 2 * (_G.PI or math.pi), 2.5, 12, function(offset)
        local tx = x + offset.x
        local tz = z + offset.z
        return map:IsPassableAtPoint(tx, 0, tz)
            and not map:IsPointNearHole(_G.Vector3(tx, 0, tz))
    end)
    if off then
        spawn_x = x + off.x
        spawn_z = z + off.z
    end
    npc.Transform:SetPosition(spawn_x, 0, spawn_z)
    npc._webber_home_x = spawn_x
    npc._webber_home_z = spawn_z
    npc:SetAppearance("webber")
    if npc.sg and npc.sg:HasState("idle") then
        npc.sg:GoToState("idle")
    end

    local NPC_TUNING_REF = require("npc_tuning")
    if npc.components and npc.components.inventory then
        local items = (NPC_TUNING_REF.CHARACTER_STARTING_ITEMS and NPC_TUNING_REF.CHARACTER_STARTING_ITEMS.webber)
            or NPC_TUNING_REF.STARTING_ITEMS
            or {}
        for _, prefab_name in ipairs(items) do
            local item = _G.SpawnPrefab(prefab_name)
            if item then
                npc.components.inventory:GiveItem(item)
            end
        end
        local function ForceEquipWebberStartupGear(inst)
            if not (inst and inst:IsValid() and inst.components and inst.components.inventory) then
                return false
            end
            local inv2 = inst.components.inventory
            local need_retry = false
            _WebberEquipDbg("tick guid=%s begin", tostring(inst.GUID))
            for _, target_prefab in ipairs({ "orangestaff", "krampus_sack" }) do
                local target_item = nil
                for slot_i = 1, inv2.maxslots do
                    local it = inv2:GetItemInSlot(slot_i)
                    if it and it.prefab == target_prefab then
                        target_item = it
                        break
                    end
                end
                if target_item == nil and target_prefab == "krampus_sack" and not inst._webber_spawned_krampus_sack then
                    local bag = _G.SpawnPrefab("krampus_sack")
                    if bag then
                        inst._webber_spawned_krampus_sack = true
                        inv2:GiveItem(bag)
                        target_item = bag
                        _WebberEquipDbg("spawned krampus_sack guid=%s", tostring(inst.GUID))
                    end
                end
                if target_item and target_item.components and target_item.components.equippable then
                    local eslot = target_item.components.equippable.equipslot
                    local equipped = eslot and inv2:GetEquippedItem(eslot) or nil
                    _WebberEquipDbg(
                        "check guid=%s target=%s slot=%s equipped=%s",
                        tostring(inst.GUID),
                        tostring(target_prefab),
                        tostring(eslot),
                        tostring(equipped and equipped.prefab or "nil")
                    )
                    if equipped ~= target_item then
                        inv2:Equip(target_item)
                        need_retry = true
                        local equipped_after = eslot and inv2:GetEquippedItem(eslot) or nil
                        _WebberEquipDbg(
                            "equip guid=%s target=%s result=%s",
                            tostring(inst.GUID),
                            tostring(target_prefab),
                            tostring(equipped_after and equipped_after.prefab or "nil")
                        )
                    end
                elseif target_item then
                    need_retry = true
                    _WebberEquipDbg("target=%s has no equippable guid=%s", tostring(target_prefab), tostring(inst.GUID))
                else
                    _WebberEquipDbg("target=%s not found guid=%s", tostring(target_prefab), tostring(inst.GUID))
                end
            end
            if inst.sg and inst.sg:HasState("idle") then
                inst.sg:GoToState("idle")
            end
            _WebberEquipDbg("tick guid=%s end need_retry=%s", tostring(inst.GUID), tostring(need_retry))
            return need_retry
        end

        ForceEquipWebberStartupGear(npc)
        local tries = 0
        npc._webber_force_equip_task = npc:DoPeriodicTask(0.25, function(i)
            tries = tries + 1
            local need_retry = ForceEquipWebberStartupGear(i)
            _WebberEquipDbg("periodic guid=%s tries=%d need_retry=%s", tostring(i.GUID), tries, tostring(need_retry))
            if (not need_retry) or tries >= 20 or not i:IsValid() then
                if i._webber_force_equip_task then
                    i._webber_force_equip_task:Cancel()
                    i._webber_force_equip_task = nil
                end
                _WebberEquipDbg("periodic stop guid=%s tries=%d", tostring(i.GUID), tries)
            end
        end)
        npc:ListenForEvent("onremove", function(i)
            if i._webber_force_equip_task then
                i._webber_force_equip_task:Cancel()
                i._webber_force_equip_task = nil
            end
        end)
    end

    if attacker and attacker:IsValid()
       and npc.components and npc.components.combat
       and npc.components.combat:CanTarget(attacker) then
        npc.components.combat:SetTarget(attacker)
    end
    return npc
end

function HostileSpawn.TrySpawnWebberFromSpiderDen(den, attacker)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not den or not den:IsValid() then return end
    if den.components.health and den.components.health:IsDead() then return end
    local NPCFRIENDS = rawget(_G, "NPCFRIENDS")
    if not (NPCFRIENDS and NPCFRIENDS.npc_webber ~= false) then return end
    local NPC_TUNING_REF = require("npc_tuning")
    local den_stage = (den.data and den.data.stage) or (den.components.growable and den.components.growable.GetStage and den.components.growable:GetStage()) or 1
    local min_stage = NPC_TUNING_REF.HOSTILE_WEBBER_DEN_MIN_STAGE or 2
    local max_stage = NPC_TUNING_REF.HOSTILE_WEBBER_DEN_MAX_STAGE or 3
    if den_stage < min_stage or den_stage > max_stage then
        return
    end
    if NPC_TUNING_REF.HOSTILE_WEBBER_DEN_SURFACE_ONLY and _G.TheWorld:HasTag("cave") then
        return
    end
    if HasAnyWebberAlive() then return end

    local now = _G.GetTime()
    local world_cd_until = GetWebberRespawnCdUntil()
    if now < world_cd_until then
        return
    end
    if den._webber_spawn_cd and now < den._webber_spawn_cd then
        return
    end
    den._webber_spawn_cd = now + 0.35 -- 同一击可能触发多个事件，做去重

    local chance = NPC_TUNING_REF.HOSTILE_WEBBER_DEN_SPAWN_CHANCE
    if chance == nil then chance = 1 end
    chance = math.max(0, math.min(1, chance))
    if math.random() <= chance then
        SpawnHostileWebberNearDen(den, attacker)
    end
end

--------------------------------------------------------------------------
-- 沃特（Wurt）相关
--------------------------------------------------------------------------

local function GetWurtRespawnCdUntil()
    local world = _G.TheWorld
    return (world and world._wurt_respawn_cd_until) or 0
end

local function GetAllWurts()
    local ret = {}
    for _, ent in pairs(_G.Ents) do
        if ent and ent:IsValid()
           and ent:HasTag("npcfriend")
           and ent.npc_character_type == "wurt" then
            ret[#ret + 1] = ent
        end
    end
    return ret
end

local function FindRandomMermHouse()
    local houses = {}
    for _, ent in pairs(_G.Ents) do
        if ent and ent:IsValid()
           and (ent.prefab == "mermhouse" or ent.prefab == "mermhouse_crafted") then
            houses[#houses + 1] = ent
        end
    end
    if #houses <= 0 then return nil end
    return houses[math.random(#houses)]
end

local function SpawnHostileWurtNearMermHouse(house)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return nil end
    if not house or not house:IsValid() then return nil end

    local npc = _G.SpawnPrefab("npcfriend")
    if not npc then return nil end

    local x, y, z = house.Transform:GetWorldPosition()
    local map = _G.TheWorld.Map
    local spawn_x, spawn_z = x, z
    local off = _G.FindValidPositionByFan(math.random() * 2 * (_G.PI or math.pi), 2.5, 12, function(offset)
        local tx = x + offset.x
        local tz = z + offset.z
        return map:IsPassableAtPoint(tx, 0, tz)
            and not map:IsPointNearHole(_G.Vector3(tx, 0, tz))
    end)
    if off then
        spawn_x = x + off.x
        spawn_z = z + off.z
    end

    npc.Transform:SetPosition(spawn_x, 0, spawn_z)
    npc:SetAppearance("wurt")
    if npc.sg and npc.sg:HasState("idle") then
        npc.sg:GoToState("idle")
    end

    npc._wurt_home_x = spawn_x
    npc._wurt_home_z = spawn_z
    npc._wurt_from_house_spawn = true

    local NPC_TUNING_REF = require("npc_tuning")
    if npc.components and npc.components.inventory then
        local items = (NPC_TUNING_REF.CHARACTER_STARTING_ITEMS and NPC_TUNING_REF.CHARACTER_STARTING_ITEMS.wurt)
            or NPC_TUNING_REF.STARTING_ITEMS
            or {}
        for _, prefab_name in ipairs(items) do
            local item = _G.SpawnPrefab(prefab_name)
            if item then
                npc.components.inventory:GiveItem(item)
            end
        end

        local function ForceEquipWurtStartupGear(inst)
            if not (inst and inst:IsValid() and inst.components and inst.components.inventory) then
                return false
            end
            local inv = inst.components.inventory
            local bag = nil
            for slot_i = 1, inv.maxslots do
                local it = inv:GetItemInSlot(slot_i)
                if it and it.prefab == "icepack" then
                    bag = it
                    break
                end
            end
            if bag == nil and not inst._wurt_spawned_icepack then
                local spawned = _G.SpawnPrefab("icepack")
                if spawned then
                    inst._wurt_spawned_icepack = true
                    inv:GiveItem(spawned)
                    bag = spawned
                end
            end
            if not (bag and bag.components and bag.components.equippable) then
                return true
            end
            local eslot = bag.components.equippable.equipslot
            local equipped = eslot and inv:GetEquippedItem(eslot) or nil
            if equipped ~= bag then
                inv:Equip(bag)
                return true
            end
            if inst.sg and inst.sg:HasState("idle") then
                inst.sg:GoToState("idle")
            end
            return false
        end

        ForceEquipWurtStartupGear(npc)
        local tries = 0
        npc._wurt_force_equip_task = npc:DoPeriodicTask(0.25, function(i)
            tries = tries + 1
            local need_retry = ForceEquipWurtStartupGear(i)
            if (not need_retry) or tries >= 20 or not i:IsValid() then
                if i._wurt_force_equip_task then
                    i._wurt_force_equip_task:Cancel()
                    i._wurt_force_equip_task = nil
                end
            end
        end)
        npc:ListenForEvent("onremove", function(i)
            if i._wurt_force_equip_task then
                i._wurt_force_equip_task:Cancel()
                i._wurt_force_equip_task = nil
            end
        end)
    end
    return npc
end

function HostileSpawn.EnsureSingleWurtAndRespawn()
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if _G.TheWorld:HasTag("cave") then return end
    local NPCFRIENDS = rawget(_G, "NPCFRIENDS")
    if not (NPCFRIENDS and NPCFRIENDS.npc_wurt ~= false) then
        for _, w in ipairs(GetAllWurts()) do
            if w and w:IsValid() then
                w:Remove()
            end
        end
        return
    end

    local all = GetAllWurts()
    local has_house_wurt = false
    for _, w in ipairs(all) do
        if w._wurt_from_house_spawn then
            has_house_wurt = true
            break
        end
    end
    if #all > 0 and not has_house_wurt then
        for _, w in ipairs(all) do
            if w:IsValid() then w:Remove() end
        end
        all = {}
    end
    if #all > 1 then
        local keep = nil
        for _, w in ipairs(all) do
            if w._wurt_from_house_spawn then
                keep = w
                break
            end
        end
        keep = keep or all[1]
        for _, w in ipairs(all) do
            if w ~= keep and w:IsValid() then
                w:Remove()
            end
        end
        all = { keep }
    end

    if #all >= 1 then
        return
    end

    local now = _G.GetTime()
    if now < GetWurtRespawnCdUntil() then
        return
    end

    local NPC_TUNING_REF = require("npc_tuning")
    local chance = NPC_TUNING_REF.HOSTILE_WURT_HOUSE_SPAWN_CHANCE
    if chance == nil then chance = 1 end
    chance = math.max(0, math.min(1, chance))
    if math.random() > chance then
        return
    end

    local house = FindRandomMermHouse()
    if not house then
        return
    end
    SpawnHostileWurtNearMermHouse(house)
end

--------------------------------------------------------------------------
-- 蜘蛛受击 -> 附近敌对韦伯协同反击（同类联动）
--------------------------------------------------------------------------

local function IsValidWebberAssistAttacker(attacker)
    if not attacker or not attacker:IsValid() then return false end
    if attacker:HasTag("playerghost") then return false end
    if attacker:HasTag("spider") then return false end
    if attacker.components and attacker.components.health and attacker.components.health:IsDead() then return false end
    return true
end

local function OnSpiderAttackedForWebberAssist(spider, data)
    local attacker = data and data.attacker or nil
    if not IsValidWebberAssistAttacker(attacker) then return end
    local x, y, z = spider.Transform:GetWorldPosition()
    local webbers = _G.TheSim:FindEntities(x, y, z, 20, {"npcfriend", "npc_hostile", "_combat"}, {"INLIMBO", "playerghost"})
    for _, w in ipairs(webbers) do
        if w:IsValid()
           and w.npc_character_type == "webber"
           and not w._is_ghost_mode
           and w.components and w.components.combat
           and w.components.combat:CanTarget(attacker) then
            w.components.combat:SetTarget(attacker)
        end
    end
end

function HostileSpawn.HookSpiderWebberAssist(inst)
    if not _G.TheWorld.ismastersim then return end
    if inst._npcfriends_webber_spider_hooked then return end
    inst._npcfriends_webber_spider_hooked = true
    inst:ListenForEvent("attacked", OnSpiderAttackedForWebberAssist)
end

--------------------------------------------------------------------------
-- NPC死亡 → 设置重生冷却
--------------------------------------------------------------------------

function HostileSpawn.OnNPCDeath(inst)
    local NPC_TUNING_REF = require("npc_tuning")
    if inst.npc_character_type == "webber" then
        local cd = NPC_TUNING_REF.HOSTILE_WEBBER_RESPAWN_CD or 60
        _G.TheWorld._webber_respawn_cd_until = _G.GetTime() + math.max(0, cd)
        return
    end
    if inst.npc_character_type == "wurt" then
        local cd = NPC_TUNING_REF.HOSTILE_WURT_RESPAWN_CD or 30
        _G.TheWorld._wurt_respawn_cd_until = _G.GetTime() + math.max(0, cd)
        return
    end
end

--------------------------------------------------------------------------
-- 世界存档/加载：持久化重生冷却
--------------------------------------------------------------------------

function HostileSpawn.OnWorldSave(world, data)
    data = data or {}
    local remain = math.max(0, (world._webber_respawn_cd_until or 0) - _G.GetTime())
    data.npcfriends_webber_respawn_cd_remaining = remain
    local wurt_remain = math.max(0, (world._wurt_respawn_cd_until or 0) - _G.GetTime())
    data.npcfriends_wurt_respawn_cd_remaining = wurt_remain
end

function HostileSpawn.OnWorldLoad(world, data)
    if data and data.npcfriends_webber_respawn_cd_remaining then
        world._webber_respawn_cd_until = _G.GetTime() + math.max(0, data.npcfriends_webber_respawn_cd_remaining)
    end
    if data and data.npcfriends_wurt_respawn_cd_remaining then
        world._wurt_respawn_cd_until = _G.GetTime() + math.max(0, data.npcfriends_wurt_respawn_cd_remaining)
    end
end

return HostileSpawn
