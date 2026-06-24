-- scripts/npc/characters/wes.lua
-- Wes（韦斯）：伤害倍率 0.75（25%减伤） + 哑巴（不说话）+ 清洁工

-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")
local StructureUtil = require("npc/npc_structure_util")

-- ════════════════════════════════════════════════════════════
--  搜索植物人农场中心
-- ════════════════════════════════════════════════════════════

local function FindWormwoodFarmCenter(inst)
    return StructureUtil.FindNearestFarmCenter(inst, 200)
end

local function RefreshContainerCache(inst, center, _prefix)
    local radius = NPC_TUNING.WES_PATROL_RADIUS or 40
    inst._wes_iceboxes = StructureUtil.FindContainersInRadius(center, radius, "icebox")
    inst._wes_chests   = StructureUtil.FindContainersInRadius(center, radius, "chest")
end

local function StartFarmCenterSearch(inst)
    if inst._wes_search_task then return end  -- 防重复
    local interval = NPC_TUNING.WES_FARM_SEARCH_INTERVAL or 10
    inst._wes_search_task = inst:DoPeriodicTask(interval, function()
        if not inst:IsValid() then
            if inst._wes_search_task then
                inst._wes_search_task:Cancel()
                inst._wes_search_task = nil
            end
            return
        end
        if inst._work_paused then
            inst._wes_farm_center = nil
            inst._wes_iceboxes = nil
            inst._wes_chests = nil
            inst._wes_go_to_farm = false
            return
        end
        if inst._wes_manual_center and inst._wes_farm_center then
            RefreshContainerCache(inst, inst._wes_farm_center, "wes")
            return
        end
        local center = FindWormwoodFarmCenter(inst)
        if center then
            if inst._wes_farm_center == nil then
                inst._wes_go_to_farm = true
            end
            inst._wes_farm_center = center
            RefreshContainerCache(inst, center, "wes")
        else
            inst._wes_farm_center = nil
            inst._wes_iceboxes = nil
            inst._wes_chests = nil
        end
    end)
end

-- ════════════════════════════════════════════════════════════
--  导出模块
-- ════════════════════════════════════════════════════════════

return {
    on_apply = function(inst, stats)
    
        inst._is_wes = true
    
        if not inst._wes_search_started then
            inst._wes_search_started = true
            inst:DoTaskInTime(3, function()
                if TheWorld.state and TheWorld.state.cycles > 0 then return end
                if inst:IsValid() then
                    StartFarmCenterSearch(inst)
                end
            end)
        end
    
        if not inst._wes_balloon_task then
            local balloon_interval = NPC_TUNING.WES_BALLOON_INTERVAL or 10
            inst._wes_balloon_task = inst:DoPeriodicTask(balloon_interval, function()
                if not inst:IsValid() then return end
                if not TheWorld.ismastersim then return end
                if inst.sg and inst.sg:HasStateTag("idle")
                   and not inst.sg:HasStateTag("busy")
                   and not inst.sg:HasStateTag("doing") then
                    inst.sg:GoToState("npc_makeballoon")
                end
            end)
        end
    end,

    on_save = function(inst, data)
        if inst._wes_manual_center and inst._wes_farm_center then
            data.wes_farm_center = {
                x = inst._wes_farm_center.x,
                z = inst._wes_farm_center.z,
            }
            data.wes_manual_center = true
        end
    end,

    on_load = function(inst, data)
        if data and data.wes_farm_center then
            inst._wes_farm_center = {
                x = data.wes_farm_center.x,
                z = data.wes_farm_center.z,
            }
            inst._wes_manual_center = data.wes_manual_center or false
            inst:DoTaskInTime(5, function()
                if inst:IsValid() and inst._wes_farm_center then
                    RefreshContainerCache(inst, inst._wes_farm_center, "wes")
                end
            end)
        end
    end,
}
