-- scripts/npc/npc_container_merge.lua
-- 跨容器堆叠合并：在多个冰箱/箱子之间，将同类物品并入「已有未满堆叠」的目标容器。
-- 复用 InvUtil.FindContainerWithMergeableStack + ItemClassify，供 NPC 跨容器合并等行为调用。
-- 设计原则：不重复实现 ChefFarm 的完整 PlanOrganize；仅做「单次可合并移动」的规划。

local ItemClassify = require "npc/npc_item_classify"
local InvUtil      = require "npc/npc_inventory_util"

local Merge = {}

--- @param mode string  "fridge" = 仅 icebox 类； "chest" = chest + icebox 类（木箱里常放食物）
local function CategoryAllowed(cat, mode)
    if cat == "tool" or cat == "delete" or cat == "ground" or cat == "ignore" then
        return false
    end
    if mode == "fridge" then return cat == "icebox" end
    if mode == "chest" then return cat == "chest" or cat == "icebox" end
    return false
end

--- @param containers table  容器实体列表
--- @param inst entity       NPC（分类用）
--- @param mode string       "fridge" | "chest"
--- @return table|nil  { src, dst, slot, prefab }
local function FindMoveInContainers(containers, inst, mode)
    if not containers or #containers < 2 then return nil end
    for _, src in ipairs(containers) do
        if src and src:IsValid() and src.components.container then
            local cont = src.components.container
            for slot = 1, cont:GetNumSlots() do
                local item = cont:GetItemInSlot(slot)
                if item and item:IsValid() and item.components.stackable then
                    local cat = ItemClassify.GetCategory(item, inst)
                    if CategoryAllowed(cat, mode) then
                        local others = {}
                        for _, c in ipairs(containers) do
                            if c and c ~= src and c:IsValid() then
                                table.insert(others, c)
                            end
                        end
                        local target = InvUtil.FindContainerWithMergeableStack(
                            { [item.prefab] = true }, others)
                        if target then
                            return {
                                src    = src,
                                dst    = target,
                                slot   = slot,
                                prefab = item.prefab,
                            }
                        end
                    end
                end
            end
        end
    end
    return nil
end

--- 规划一次跨箱合并（先冰箱之间、再木箱之间）。
--- @param iceboxes table
--- @param chests table
--- @param inst entity
--- @return table|nil
function Merge.FindNextMergeMove(iceboxes, chests, inst)
    local ib = iceboxes or {}
    local ch = chests or {}
    local m = FindMoveInContainers(ib, inst, "fridge")
    if m then return m end
    return FindMoveInContainers(ch, inst, "chest")
end

return Merge
