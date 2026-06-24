-- scripts/npc/characters/wurt.lua
-- 敌对 Wurt：
-- 1) 敌对/禁招募/禁UI
-- 2) 鱼人阵营标签（merm）
-- 3) 死亡后进入灵魂并自动消散
-- 4) 幽灵掉落（独立配置表）

local hostile_combat = require("npc/npc_hostile_combat")
local NPC_TUNING = require("npc_tuning")
local WURT_GHOST_LOOT = require("npc/wurt_ghost_loot")

local function PickWeightedPrefab(items)
    return hostile_combat.PickWeightedPrefab(items)
end

local function SpawnLootAt(inst, prefab)
    return hostile_combat.SpawnLootAt(inst, prefab)
end

local function DropWurtGhostLoot(inst)
    if not inst or not inst:IsValid() then return end
    if not inst._is_wurt then return end
    if not (TheWorld and TheWorld.ismastersim) then return end
    if inst._wurt_ghost_loot_dropped then return end

    local mode = WURT_GHOST_LOOT and WURT_GHOST_LOOT.MODE or "flat_weighted"
    if mode == "group_chance" and WURT_GHOST_LOOT and type(WURT_GHOST_LOOT.GROUP_ROLLS) == "table" then
        for _, group in ipairs(WURT_GHOST_LOOT.GROUP_ROLLS) do
            local chance = (type(group) == "table" and tonumber(group.chance)) or 0
            if chance > 0 and math.random() <= chance then
                local pick = (type(group) == "table" and tonumber(group.pick)) or 1
                pick = math.max(1, math.floor(pick))
                local gitems = (type(group) == "table" and group.items) or nil
                for _ = 1, pick do
                    local prefab = PickWeightedPrefab(gitems)
                    SpawnLootAt(inst, prefab)
                end
            end
        end
        inst._wurt_ghost_loot_dropped = true
        return
    end

    local items = WURT_GHOST_LOOT and WURT_GHOST_LOOT.ITEMS or nil
    if type(items) ~= "table" or #items == 0 then
        inst._wurt_ghost_loot_dropped = true
        return
    end
    local min_count = tonumber(NPC_TUNING.HOSTILE_WURT_GHOST_LOOT_MIN) or 1
    local max_count = tonumber(NPC_TUNING.HOSTILE_WURT_GHOST_LOOT_MAX) or 2
    min_count = math.max(0, math.floor(min_count))
    max_count = math.max(0, math.floor(max_count))
    if max_count < min_count then min_count, max_count = max_count, min_count end
    local count = (max_count > min_count) and math.random(min_count, max_count) or min_count
    for _ = 1, count do
        local prefab = PickWeightedPrefab(items)
        SpawnLootAt(inst, prefab)
    end
    inst._wurt_ghost_loot_dropped = true
end

local function StartWurtGhostDespawn(inst)
    if not inst or not inst:IsValid() then return end
    if not inst._is_wurt then return end
    if not inst._is_ghost_mode then return end
    if inst._wurt_ghost_despawn_task then
        inst._wurt_ghost_despawn_task:Cancel()
        inst._wurt_ghost_despawn_task = nil
    end

    local delay = NPC_TUNING.HOSTILE_WURT_GHOST_DESPAWN_DELAY
        or NPC_TUNING.HOSTILE_WEBBER_GHOST_DESPAWN_DELAY
        or 8
    inst._wurt_ghost_despawn_task = inst:DoTaskInTime(delay, function(i)
        i._wurt_ghost_despawn_task = nil
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

local function EnsureWurtGhostFlow(inst)
    if not inst or not inst:IsValid() then return end
    -- Cancel any previous polling task
    if inst._wurt_ghost_poll_task then
        inst._wurt_ghost_poll_task:Cancel()
        inst._wurt_ghost_poll_task = nil
    end
    local tries = 0
    local function _TryStart(i)
        i._wurt_ghost_poll_task = nil
        if not i or not i:IsValid() then return end
        if i._is_ghost_mode then
            DropWurtGhostLoot(i)
            StartWurtGhostDespawn(i)
            return
        end
        tries = tries + 1
        if tries < 30 then
            i._wurt_ghost_poll_task = i:DoTaskInTime(0.1, _TryStart)
        end
    end
    _TryStart(inst)
end

local function CancelWurtGhostDespawn(inst)
    if inst and inst._wurt_ghost_despawn_task then
        inst._wurt_ghost_despawn_task:Cancel()
        inst._wurt_ghost_despawn_task = nil
    end
end

return {
    on_apply = function(inst, stats)
        local function ForceHostileFlags(i)
            if not i or not i:IsValid() then return end
            i._is_wurt = true
            i._is_hostile_npc = true
            if not i:HasTag("npc_hostile") then i:AddTag("npc_hostile") end
            if not i:HasTag("npc_no_ui") then i:AddTag("npc_no_ui") end
            if not i:HasTag("merm") then i:AddTag("merm") end
            
            if not i._is_ghost_mode then
                if i:HasTag("companion") then i:RemoveTag("companion") end
                if i:HasTag("notarget") then i:RemoveTag("notarget") end
                if i:HasTag("handfed") then i:RemoveTag("handfed") end
                if i:HasTag("fedbyall") then i:RemoveTag("fedbyall") end
                if i:HasTag("OMNI_eater") then i:RemoveTag("OMNI_eater") end
                i.inherentsceneaction = nil
                i.inherentscenealtaction = nil
                if i.components and i.components.follower then
                    i.components.follower:SetLeader(nil)
                end
                i._owner_userid = nil
                if i.owner_userid then
                    i.owner_userid:set("")
                end
            end
        end

        inst._is_wurt = true
        inst._is_hostile_npc = true

        if not inst:HasTag("npc_hostile") then
            inst:AddTag("npc_hostile")
        end
        if not inst:HasTag("npc_no_ui") then
            inst:AddTag("npc_no_ui")
        end
        if not inst:HasTag("merm") then
            inst:AddTag("merm")
        end
        if inst:HasTag("companion") then
            inst:RemoveTag("companion")
        end
        if inst:HasTag("notarget") then
            inst:RemoveTag("notarget")
        end

        if inst:HasTag("handfed") then
            inst:RemoveTag("handfed")
        end
        if inst:HasTag("fedbyall") then
            inst:RemoveTag("fedbyall")
        end
        if inst:HasTag("OMNI_eater") then
            inst:RemoveTag("OMNI_eater")
        end
        inst.inherentsceneaction = nil
        inst.inherentscenealtaction = nil

        if inst.components and inst.components.follower then
            inst.components.follower:SetLeader(nil)
        end
        inst._owner_userid = nil
        if inst.owner_userid then
            inst.owner_userid:set("")
        end

        
        if inst._wurt_hostile_guard_task then
            inst._wurt_hostile_guard_task:Cancel()
            inst._wurt_hostile_guard_task = nil
        end
        local tries = 0
        ForceHostileFlags(inst)
        inst._wurt_hostile_guard_task = inst:DoPeriodicTask(0.25, function(i)
            tries = tries + 1
            ForceHostileFlags(i)
            if tries >= 20 or not i:IsValid() then
                if i._wurt_hostile_guard_task then
                    i._wurt_hostile_guard_task:Cancel()
                    i._wurt_hostile_guard_task = nil
                end
            end
        end)

        hostile_combat.Attach(inst)

        if not inst._wurt_death_listener_added then
            inst._wurt_death_listener_added = true
            inst:ListenForEvent("death", function(i)
                if i._wurt_death_flow_task then
                    i._wurt_death_flow_task:Cancel()
                    i._wurt_death_flow_task = nil
                end
                i._wurt_death_flow_task = i:DoTaskInTime(0, function(i2)
                    i2._wurt_death_flow_task = nil
                    if not i2:IsValid() then return end
                    EnsureWurtGhostFlow(i2)
                end)
            end)
        end
        if not inst._wurt_onremove_listener_added then
            inst._wurt_onremove_listener_added = true
            inst:ListenForEvent("onremove", function(i)
                CancelWurtGhostDespawn(i)
                if i._wurt_hostile_guard_task then
                    i._wurt_hostile_guard_task:Cancel()
                    i._wurt_hostile_guard_task = nil
                end
                if i._wurt_death_flow_task then
                    i._wurt_death_flow_task:Cancel()
                    i._wurt_death_flow_task = nil
                end
                if i._wurt_ghost_poll_task then
                    i._wurt_ghost_poll_task:Cancel()
                    i._wurt_ghost_poll_task = nil
                end
            end)
        end
    end,

    on_save = function(inst, data)
        if inst._wurt_home_x ~= nil and inst._wurt_home_z ~= nil then
            data.wurt_home_x = inst._wurt_home_x
            data.wurt_home_z = inst._wurt_home_z
        end
    end,

    on_load = function(inst, data)
        
        if data and data.wurt_home_x ~= nil and data.wurt_home_z ~= nil then
            inst._wurt_home_x = data.wurt_home_x
            inst._wurt_home_z = data.wurt_home_z
        end
        if not inst._is_ghost_mode then
            if inst:HasTag("companion") then inst:RemoveTag("companion") end
            if inst:HasTag("notarget") then inst:RemoveTag("notarget") end
        end
        if not inst:HasTag("npc_hostile") then inst:AddTag("npc_hostile") end
        if not inst:HasTag("npc_no_ui") then inst:AddTag("npc_no_ui") end
        if not inst:HasTag("merm") then inst:AddTag("merm") end
        if inst._is_ghost_mode then
            StartWurtGhostDespawn(inst)
        else
            CancelWurtGhostDespawn(inst)
        end
    end,
}
