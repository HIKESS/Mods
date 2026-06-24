-- scripts/npc/characters/winona.lua
-- Winona（薇诺娜）

local NPC_TUNING = require("npc_tuning")
local StructureUtil = require("npc/npc_structure_util")

local function FindWormwoodFarmCenter(inst)
    return StructureUtil.FindNearestFarmCenter(inst, 200)
end

local function RefreshContainerCache(inst, center)
    local radius = NPC_TUNING.WINONA_PATROL_RADIUS or 40
    inst._winona_iceboxes = StructureUtil.FindContainersInRadius(center, radius, "icebox")
    inst._winona_chests   = StructureUtil.FindContainersInRadius(center, radius, "chest")
end

local function StartFarmCenterSearch(inst)
    if inst._winona_search_task then return end
    local interval = NPC_TUNING.WINONA_FARM_SEARCH_INTERVAL or 10
    inst._winona_search_task = inst:DoPeriodicTask(interval, function()
        if not inst:IsValid() then
            if inst._winona_search_task then
                inst._winona_search_task:Cancel()
                inst._winona_search_task = nil
            end
            return
        end
        if inst._work_paused then
            inst._winona_farm_center = nil
            inst._winona_iceboxes = nil
            inst._winona_chests = nil
            inst._winona_go_to_farm = false
            return
        end

        if inst._winona_manual_center and inst._winona_farm_center then
            RefreshContainerCache(inst, inst._winona_farm_center)
            return
        end

        -- 关闭自动接管：不主动搜索植物人农场中心，仅允许手动 CleanHere 触发
        if NPC_TUNING.WINONA_AUTO_FIND_FARM_CENTER ~= true then
            inst._winona_farm_center = nil
            inst._winona_iceboxes = nil
            inst._winona_chests = nil
            inst._winona_go_to_farm = false
            return
        end

        local center = FindWormwoodFarmCenter(inst)
        if center then
            if inst._winona_farm_center == nil then
                inst._winona_go_to_farm = true
            end
            inst._winona_farm_center = center
            RefreshContainerCache(inst, center)
        else
            inst._winona_farm_center = nil
            inst._winona_iceboxes = nil
            inst._winona_chests = nil
        end
    end)
end

return {
    on_apply = function(inst, stats)
        inst._is_winona = true
        if not inst._winona_search_started then
            inst._winona_search_started = true
            inst:DoTaskInTime(3, function()
                if inst:IsValid() then
                    StartFarmCenterSearch(inst)
                end
            end)
        end
    end,

    on_save = function(inst, data)
        if inst._winona_manual_center and inst._winona_farm_center then
            data.winona_farm_center = {
                x = inst._winona_farm_center.x,
                z = inst._winona_farm_center.z,
            }
            data.winona_manual_center = true
        end
    end,

    on_load = function(inst, data)
        if data and data.winona_farm_center then
            inst._winona_farm_center = {
                x = data.winona_farm_center.x,
                z = data.winona_farm_center.z,
            }
            inst._winona_manual_center = data.winona_manual_center or false
            inst:DoTaskInTime(5, function()
                if inst:IsValid() and inst._winona_farm_center then
                    RefreshContainerCache(inst, inst._winona_farm_center)
                end
            end)
        end
    end,
}
