-- scripts/npc/characters/wormwood.lua

local FarmManager  = require("npc/npc_farm_manager")
local BuildManager = require("npc/npc_build_manager")
local SGNPCCommon  = require("stategraphs/sg_npc_common")
local NPC_TUNING   = require("npc_tuning")
local BloomFx      = require("npc/npc_wormwood_bloom_fx")

-- ════════════════════════════════════════════════════════════
--  通用农场能力初始化（任何 NPC 都可调用）
-- ════════════════════════════════════════════════════════════
-- @param inst   NPC 实体
-- @param config 配置表 {
--     search_min       = 搜索最小距离（格），
--     search_max       = 搜索最大距离（格），
--     force_oversized  = 是否强制巨大植物，
--     ignore_season    = 是否无视季节限制，
--     farm_center      = 农场中心坐标 {x=, z=}，
--     search_radius    = 工作范围半径（格），
--     storage_target   = 搬运目标（容器实体或坐标），
-- }
-- @return FarmManager 实例
local function InitFarmCapability(inst, config)
    if inst._farmer then return inst._farmer end
    
    config = config or {}
    inst._farmer = FarmManager(inst, config)
    
    if config.farm_center then
        inst._farmer:SetFarmCenter(config.farm_center, config.search_radius)
    end
    
    if config.storage_target then
        inst._farmer:SetStorageTarget(config.storage_target)
    end
    
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        print("[种植调试] InitFarmCapability: NPC=" .. tostring(inst.prefab) .. " farmer已初始化")
    end
    
    return inst._farmer
end

return {
    on_apply = function(inst, stats)
        if inst.components.talker and TALKINGFONT_WORMWOOD then
            inst.components.talker.font = TALKINGFONT_WORMWOOD
        end

        inst._is_wormwood = true

        inst:AddTag("plantkin")

        if not inst._farmer then
            InitFarmCapability(inst, {
                search_min = 15,
                search_max = 80,           -- 新档密林环境需要更大搜索范围
                use_plantkin = true,
                force_oversized = true,   -- 植物人专属: 始终巨大植物
                ignore_season = true,     -- 植物人专属: 无季节限制
            })
        end

        if not inst._builder then
            inst._builder = BuildManager(inst, {})
        end

        BloomFx.Start(inst)

        inst:DoTaskInTime(3, function()
            if TheWorld.state and TheWorld.state.cycles > 0 then return end
            local leader = inst.components.follower and inst.components.follower.leader
            if inst:IsValid()
               and leader == nil
               and not inst._work_paused
               and inst._farmer
               and not inst._farmer.farm_center then
                inst._farmer:FindFarmArea()
            end
        end)
    end,

    on_save = function(inst, data)
        if inst._farmer then
            data.farmer = inst._farmer:OnSave()
        end
        if inst._builder then
            data.builder = inst._builder:OnSave()
        end
        local inv = inst.components.inventory
        if inv then
            local counts = {}
            local has_any = false
            local all_items = {}
            for i = 1, inv.maxslots do
                local item = inv:GetItemInSlot(i)
                if item then table.insert(all_items, item) end
            end
            for _, eslot in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.BODY, EQUIPSLOTS.HEAD }) do
                local item = inv:GetEquippedItem(eslot)
                if item then table.insert(all_items, item) end
            end
            for _, item in ipairs(all_items) do
                if item._npc_initial_tool then
                    counts[item.prefab] = (counts[item.prefab] or 0) + 1
                    has_any = true
                end
            end
            if has_any then
                data.initial_tools = counts
            end
        end
    end,

    on_load = function(inst, data)
        if data and data.farmer then
            if not inst._farmer then
                InitFarmCapability(inst, {
                    search_min = 15,
                    search_max = 80,
                    use_plantkin = true,
                    force_oversized = true,
                    ignore_season = true,
                })
            end
            inst._farmer:OnLoad(data.farmer)
        end
        if data and data.builder then
            if not inst._builder then
                inst._builder = BuildManager(inst, {})
            end
            inst._builder:OnLoad(data.builder)
        end
        if data and data.initial_tools then
            local inv = inst.components.inventory
            if inv then
                local remaining = {}
                for k, v in pairs(data.initial_tools) do remaining[k] = v end
                local all_items = {}
                for i = 1, inv.maxslots do
                    local item = inv:GetItemInSlot(i)
                    if item then table.insert(all_items, item) end
                end
                for _, eslot in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.BODY, EQUIPSLOTS.HEAD }) do
                    local item = inv:GetEquippedItem(eslot)
                    if item then table.insert(all_items, item) end
                end
                for _, item in ipairs(all_items) do
                    if remaining[item.prefab] and remaining[item.prefab] > 0 then
                        item._npc_initial_tool = true
                        remaining[item.prefab] = remaining[item.prefab] - 1
                    end
                end
            end
        end
        inst:DoTaskInTime(1.5, function()
            if inst:IsValid() then
                SGNPCCommon.UpdateHeavyLiftingSpeed(inst)
            end
        end)
    end,
}
