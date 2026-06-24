-- scripts/npc/characters/warly.lua
-- Warly（沃利/厨师）：烹饪加速
-- ────────────────────────────────────────────────────────────
-- 烹饪加速：
-- 烹饪速度由 npc_tuning.CHARACTER_STATS.warly.cook_time_mult 配置（0.5 = 2倍速）
-- 建筑结构（4个）：
--   cookpot × 1 + icebox × 1 + treasurechest × 2
--   全部结构不可被锤/烧/右键拆卸，存档后重新应用保护
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")
local StructureUtil = require("npc/npc_structure_util")

local ProtectStructure = StructureUtil.ProtectStructure

-- key → prefab 映射（与 cheffarmbehavior.lua BUILD_SEQUENCE 一致）
local PREFAB_MAP = {
    cookpot  = "portablecookpot",
    icebox_1 = "icebox",
    chest_1  = "treasurechest", chest_2 = "treasurechest",
}

-- ────────────────────────────────────────────────────────────
-- 烹饪加速：hook 便携烹饪锅 stewer.cooktimemult
-- 单个锅 只 hook 一次（_npc_cook_hooked 防重入）
-- ────────────────────────────────────────────────────────────
local function HookCookpotSpeed(cookpot, mult)
    if not cookpot or not cookpot:IsValid() then return end
    if cookpot._npc_cook_hooked then return end
    if not cookpot.components.stewer then return end
    cookpot._npc_cook_hooked = true
    cookpot.components.stewer.cooktimemult = mult
end

-- 扫描背包中所有便携烹饪锅并加速
local function ApplyCookSpeedToInventory(inst, mult)
    local inv = inst.components.inventory
    if not inv then return end
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and item.prefab == "portablecookpot" then
            HookCookpotSpeed(item, mult)
        end
    end
end

-- ────────────────────────────────────────────────────────────
-- 监听物品进入背包：立刻对便携锅应用加速
-- ────────────────────────────────────────────────────────────
local function SetupCookingSystem(inst, stats)
    local mult = stats.cook_time_mult or 0.5

    inst:ListenForEvent("itemget", function(i, data)
        if data and data.item and data.item.prefab == "portablecookpot" then
            HookCookpotSpeed(data.item, mult)
        end
    end)

    inst:DoTaskInTime(0, function()
        if inst:IsValid() then
            ApplyCookSpeedToInventory(inst, mult)
        end
    end)
end

return {
    on_apply = function(inst, stats)
        inst._is_warly = true
        inst._chef_station = inst._chef_station or {}

        if not inst:HasTag("masterchef") then
            inst:AddTag("masterchef")
        end
        if not inst:HasTag("expertchef") then
            inst:AddTag("expertchef")
        end


        if not inst._warly_systems_setup then
            inst._warly_systems_setup = true
            SetupCookingSystem(inst, stats)
        end

        if TheWorld.state and TheWorld.state.cycles > 0 then
            inst._warly_skip_first_day = true
        end
    end,

    -- ════════════════════════════════════════════════════════════
    -- 存档：持久化大厨建筑位置（9 个结构）
    -- ════════════════════════════════════════════════════════════
    on_save = function(inst, data)
        local s = inst._chef_station
        if s and s.positions then
            local saved_positions = {}
            for key, pos in pairs(s.positions) do
                saved_positions[key] = { x = pos.x, z = pos.z }
            end
            data.chef_station = {
                built = s.built or false,
                positions = saved_positions,
            }
        end

        if inst._cooking_center then
            data.cooking_center = {
                x = inst._cooking_center.x,
                z = inst._cooking_center.z,
            }
        end
    end,

    -- ════════════════════════════════════════════════════════════
    -- 加载：恢复建筑位置 + 延迟扫描已有结构 + 重新保护
    -- ════════════════════════════════════════════════════════════
    on_load = function(inst, data)
        if data and data.cooking_center then
            inst._cooking_center = {
                x = data.cooking_center.x,
                z = data.cooking_center.z,
            }
        end

        if data and data.chef_station then
            inst._chef_station = inst._chef_station or {}
            local s = inst._chef_station
            local cs = data.chef_station

            if cs.positions then
                if cs.positions.icebox and not cs.positions.icebox_1 then
                    cs.positions.icebox_1 = cs.positions.icebox
                    cs.positions.icebox = nil
                end
                if cs.positions.chest and not cs.positions.chest_1 then
                    cs.positions.chest_1 = cs.positions.chest
                    cs.positions.chest = nil
                end
            end

            if cs.positions then
                s.positions = {}
                for key, pos in pairs(cs.positions) do
                    s.positions[key] = Vector3(pos.x, 0, pos.z)
                end
            end
            s.built = cs.built

            inst:DoTaskInTime(2, function()
                if not inst:IsValid() or not s.positions then return end

                local assigned = {}

                local function FindAt(pos, prefab)
                    return StructureUtil.FindAt(pos, prefab, 1.5, assigned)
                end

                for key, prefab in pairs(PREFAB_MAP) do
                    if s.positions[key] then
                        s[key] = FindAt(s.positions[key], prefab)
                    end
                end

                if s.cookpot and s.cookpot.components.stewer then
                    local stats = NPC_TUNING.CHARACTER_STATS and NPC_TUNING.CHARACTER_STATS.warly
                    s.cookpot.components.stewer.cooktimemult = stats and stats.cook_time_mult or 0.5
                    s.cookpot._npc_cook_hooked = true
                end

                for key, prefab in pairs(PREFAB_MAP) do
                    local ent = s[key]
                    if ent then
                        inst:ListenForEvent("onremove", function()
                            if s[key] == ent then
                                s[key] = nil
                                s.built = false
                            end
                        end, ent)
                    end
                end

                if s.built then
                    for key, _ in pairs(PREFAB_MAP) do
                        if not s[key] or not s[key]:IsValid() then
                            s.built = false
                            break
                        end
                    end
                end

            end)
        end
    end,
}
