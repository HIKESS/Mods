-- scripts/npc/npc_inventory_util.lua
-- NPC 背包物品管理工具


local NPC_TUNING = require("npc_tuning")
local ItemClassify = require("npc/npc_item_classify")

-- DEBUG 开关
local DEBUG_BEHAVIOR = NPC_TUNING.DEBUG_BEHAVIOR
local function _dbg(...) if DEBUG_BEHAVIOR then print(...) end end

-- 种植调试日志函数
local function FarmLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        print("[种植调试]", ...)
    end
end

local InvUtil = {}

-- ═══════════════════════════════════════════════════════════
--  冰箱存储失败计数（prefab 级别，连续 N 次失败后自动降级到箱子）
-- ═══════════════════════════════════════════════════════════

local function _RecordIceboxFail(inst, prefab)
    if not inst._icebox_store_fails then
        inst._icebox_store_fails = {}
    end
    local prev = inst._icebox_store_fails[prefab] or 0
    inst._icebox_store_fails[prefab] = prev + 1
end

--- 清除冰箱存储失败记录（成功存入时调用）
local function _ClearIceboxFail(inst, prefab)
    if inst._icebox_store_fails then
        inst._icebox_store_fails[prefab] = nil
    end
end

local function _IsIceboxBlacklisted(inst, prefab)
    if not inst._icebox_store_fails then return false end
    local max = NPC_TUNING.ICEBOX_STORE_FAIL_MAX or 2
    return (inst._icebox_store_fails[prefab] or 0) >= max
end

local function _ResetIceboxBlacklist(inst)
    if not inst._icebox_store_fails then return false end
    local max = NPC_TUNING.ICEBOX_STORE_FAIL_MAX or 2
    local had_entries = false
    for prefab, count in pairs(inst._icebox_store_fails) do
        if count >= max then
            had_entries = true
            break
        end
    end
    if had_entries then
        inst._icebox_store_fails = {}
        _dbg("[黑名单重置] 冰箱有空位,清除所有冰箱存放黑名单")
        return true
    end
    return false
end


function InvUtil.HasTrash(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    -- 先标记同类工具中多余的（>2 把时），让其参与垃圾流程
    if NPC_TUNING.MarkExcessTools then NPC_TUNING.MarkExcessTools(inst) end
    local trash_count = 0
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        -- farm_plow_item 是犁地消耗品，即使非初始工具也不应被当垃圾丢弃
        if item and not NPC_TUNING.IsNPCTool(item, inst)
           and item.prefab ~= "farm_plow_item" then
            trash_count = trash_count + 1
        end
    end
    if trash_count > 0 then
        FarmLog("HasTrash: 发现 " .. trash_count .. " 种非工具物品")
    end
    return trash_count > 0
end


function InvUtil.GetTrashItems(inst)
    local items = {}
    local total = 0
    local inv = inst.components.inventory
    if not inv then return items, 0, 0 end
    -- 与 HasTrash 保持一致：先标记多余的同类工具
    if NPC_TUNING.MarkExcessTools then NPC_TUNING.MarkExcessTools(inst) end
    -- 倒序收集：后续 DropItem 移除不影响已遍历的槽位
    for i = inv.maxslots, 1, -1 do
        local item = inv:GetItemInSlot(i)
        -- farm_plow_item 是犁地消耗品，即使非初始工具也不应被当垃圾丢弃
        if item and not NPC_TUNING.IsNPCTool(item, inst)
           and item.prefab ~= "farm_plow_item" then
            -- 调试：被当作垃圾的工具（hammer/shovel 等）打印警告
            if NPC_TUNING.DEBUG_FARMING and (item.prefab == "hammer" or item.prefab == "shovel"
                or item.prefab == "farm_hoe" or item.prefab == "wateringcan" or item.prefab == "spear") then
                print(string.format("[种植调试][Trash] !!! 工具被识别为垃圾: %s GUID=%s _npc_excess=%s _npc_tool=%s _npc_initial=%s tag_npctool=%s",
                    item.prefab, tostring(item.GUID or "?"),
                    tostring(item._npc_excess), tostring(item._npc_tool),
                    tostring(item._npc_initial_tool), tostring(item:HasTag("_npc_tool"))))
            end
            table.insert(items, item)
            local stack = item.components.stackable
                and item.components.stackable:StackSize() or 1
            total = total + stack
        end
    end
    return items, #items, total
end


-- ═══════════════════════════════════════════════════════════
--  删 (Drop) — 受控丢弃，绕过 NPC 安全覆盖
-- ═══════════════════════════════════════════════════════════

local NPC_DROP_COOLDOWN = 60

local function _ForceDrop(inst, item, pos)
    local _drop = inst._orig_DropItem
    if not _drop then
        FarmLog("_ForceDrop: 失败 - 无 _orig_DropItem")
        return nil
    end
    FarmLog("_ForceDrop: 丢弃物品 " .. tostring(item and item.prefab or "nil") .. 
            " 到位置=(" .. string.format("%.1f", pos and pos.x or 0) .. ", " .. 
            string.format("%.1f", pos and pos.z or 0) .. ")")

    local inv = inst.components.inventory
    local result = _drop(inv, item, true, false, pos)
    -- 标记物品为NPC丢弃，防止立即重新捡起
    if result and result:IsValid() then
        result._npc_dropped_time = GetTime()
        result._npc_dropped_by = inst
        FarmLog("_ForceDrop: 成功，已标记 _npc_dropped_time=" .. string.format("%.1f", result._npc_dropped_time))
    end
    return result
end

--- 公用丢弃方法：强制将物品从背包丢到地面
--- 优先使用 DropItem，失败则手动 RemoveItem+SetPosition 兜底

function InvUtil.ForceDropItem(inst, item, pos)
    if not item or not item:IsValid() then return nil end
    local inv = inst.components.inventory
    if not inv then return nil end
    local p = pos or Vector3(inst.Transform:GetWorldPosition())
    -- 尝试 DropItem
    local result = _ForceDrop(inst, item, p)
    if not result then
        -- 兜底：手动移除 + 设置位置
        local item_prefab = item.prefab or "unknown"
        result = inv:RemoveItem(item, true)
        if result then
            if not result:IsValid() then
                print("[警告] ForceDropItem: RemoveItem后物品已失效: " .. tostring(item_prefab))
                result = nil
            else
                result.Transform:SetPosition(p.x, 0, p.z)
                -- 兜底路径也打标记，防止立即重新捡起
                result._npc_dropped_time = GetTime()
                result._npc_dropped_by = inst
            end
        end
    end
    if result then
        result.prevcontainer = nil
        result.prevslot = nil
    end
    return result
end


function InvUtil.DropTrashAt(inst, pos)
    local items, count, total = InvUtil.GetTrashItems(inst)
    if count == 0 then
        return 0, 0
    end

    local drop_pos = pos or Vector3(inst.Transform:GetWorldPosition())
    FarmLog("DropTrashAt: 准备丢弃 " .. count .. " 种物品, 目标位置=(" .. 
            string.format("%.1f", drop_pos.x) .. ", " .. string.format("%.1f", drop_pos.z) .. ")")
    local dropped = 0
    local dropped_total = 0

    for _, item in ipairs(items) do
        local stack = item.components.stackable
            and item.components.stackable:StackSize() or 1
        local result = _ForceDrop(inst, item, drop_pos)
        if result then
            dropped = dropped + 1
            dropped_total = dropped_total + stack
        end
    end

    return dropped, dropped_total
end


function InvUtil.DropHeavyAt(inst, pos)
    local inv = inst.components.inventory
    if not inv then return false end
    local body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
    if not body or not body:HasTag("heavy") then
        return false
    end

    local drop_pos = pos or Vector3(inst.Transform:GetWorldPosition())
    FarmLog("DropHeavyAt: 准备放下重物 " .. tostring(body.prefab) .. ", 目标位置=(" .. 
            string.format("%.1f", drop_pos.x) .. ", " .. string.format("%.1f", drop_pos.z) .. ")")
    local result = _ForceDrop(inst, body, drop_pos)
    if result then
        FarmLog("DropHeavyAt: 成功放下重物")
        return true
    end
    FarmLog("DropHeavyAt: 放下重物失败")
    return false
end

-- ═══════════════════════════════════════════════════════════
--  存 (Store) — 将背包物品存入容器（箱子/冰箱）
-- ═══════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════
--  智能存储 (SmartStore)
--  icebox→冰箱，chest→箱子，ground→地面堆放，delete→删除
-- ═══════════════════════════════════════════════════════════


local function _StoreItemsInContainers(inst, items, containers, track_icebox)
    if #items == 0 or #containers == 0 then return 0, #items end
    local inv = inst.components.inventory
    if not inv then return 0, #items end
    local stored = 0
    for _, item in ipairs(items) do
        if not item:IsValid() then
            stored = stored + 1
        else
            if track_icebox and _IsIceboxBlacklisted(inst, item.prefab) then
            else
                local placed = false
                for _, c in ipairs(containers) do
                    if c and c:IsValid() and c.components.container then
                        local item_prefab = item.prefab or "unknown"
                        local taken = inv:RemoveItem(item, true)
                        if taken then
                            if not taken:IsValid() then
                                print("[警告] _StoreItemsInContainers: RemoveItem后物品已失效: " .. tostring(item_prefab))
                                break
                            end
                            local ok = c.components.container:GiveItem(taken, nil, nil, false)
                            if ok then
                                placed = true
                                stored = stored + 1
                                if track_icebox then
                                    _ClearIceboxFail(inst, taken.prefab)
                                end
                                break
                            else
                                if taken:IsValid() then
                                    inv:GiveItem(taken)
                                    if track_icebox then
                                        _RecordIceboxFail(inst, taken.prefab)
                                    end
                                else
                                    print("[警告] _StoreItemsInContainers: 物品传输中丢失: " .. tostring(item_prefab))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return stored, #items - stored
end


function InvUtil.HandleGroundAndDelete(inst, ground_items, delete_items, dump_pos)
    local inv = inst.components.inventory
    if not inv then return end

    if ground_items and #ground_items > 0 then
        local pos = dump_pos or Vector3(inst.Transform:GetWorldPosition())
        for _, item in ipairs(ground_items) do
            if item:IsValid() then
                local item_prefab = item.prefab or "unknown"
                local result = _ForceDrop(inst, item, pos)
                if not result then
                    local taken = inv:RemoveItem(item, true)
                    if taken then
                        if taken:IsValid() then
                            taken.Transform:SetPosition(pos.x, 0, pos.z)
                            taken._npc_dropped_time = GetTime()
                            taken._npc_dropped_by = inst
                        else
                            print("[警告] HandleGroundAndDelete: RemoveItem后物品已失效: " .. tostring(item_prefab))
                        end
                    end
                end
            end
        end
    end

    if delete_items and #delete_items > 0 then
        for _, item in ipairs(delete_items) do
            if item:IsValid() then
                local item_prefab = item.prefab or "unknown"
                local taken = inv:RemoveItem(item, true)
                if taken then
                    if taken:IsValid() then
                        taken:Remove()
                    else
                        print("[警告] HandleGroundAndDelete: RemoveItem后物品已失效: " .. tostring(item_prefab))
                    end
                end
            end
        end
    end
end


function InvUtil.SmartStore(inst, iceboxes, chests, dump_pos)
    if DEBUG_BEHAVIOR then
        local ib_strs, ch_strs = {}, {}
        for _, c in ipairs(iceboxes or {}) do table.insert(ib_strs, (c.prefab or "?") .. "(" .. tostring(c) .. ")") end
        for _, c in ipairs(chests or {}) do table.insert(ch_strs, (c.prefab or "?") .. "(" .. tostring(c) .. ")") end
        print("[NPC_DEBUG] SmartStore - iceboxes:[", table.concat(ib_strs, ", "), "] chests:[", table.concat(ch_strs, ", "), "]")
    end
    local cats = ItemClassify.CategorizeInventory(inst)
    local result = { icebox_stored = 0, icebox_remaining = 0,
                     chest_stored = 0, chest_remaining = 0,
                     ground_dropped = 0, deleted = 0 }

    if #cats.icebox > 0 then
        local s, r = _StoreItemsInContainers(inst, cats.icebox, iceboxes, true)
        result.icebox_stored = s
        if r > 0 then
            local remaining = {}
            local inv = inst.components.inventory
            if inv then
                for i = inv.maxslots, 1, -1 do
                    local item = inv:GetItemInSlot(i)
                    if item and ItemClassify.IsIceboxItem(item) then
                        table.insert(remaining, item)
                    end
                end
            end
            if #remaining > 0 then
                local s2, r2 = _StoreItemsInContainers(inst, remaining, chests)
                result.icebox_stored = result.icebox_stored + s2
                result.icebox_remaining = r2
            end
        end
    end

    if #cats.chest > 0 then
        local s, r = _StoreItemsInContainers(inst, cats.chest, chests)
        result.chest_stored = s
        result.chest_remaining = r
    end

    InvUtil.HandleGroundAndDelete(inst, cats.ground, cats.delete, dump_pos)
    result.ground_dropped = #cats.ground
    result.deleted = #cats.delete

    return result
end


function InvUtil.SmartStoreInSingleContainer(inst, container, dump_pos)
    if not container or not container:IsValid() or not container.components.container then
        return
    end
    if DEBUG_BEHAVIOR then
        print("[NPC_DEBUG] SmartStoreInSingleContainer - container:", container.prefab or "?",
              "chest=", tostring(container:HasTag("chest")),
              "fridge=", tostring(container:HasTag("fridge")),
              "backpack=", tostring(container:HasTag("backpack")),
              "_npc_structure=", tostring(container:HasTag("_npc_structure")))
    end
    local cats = ItemClassify.CategorizeInventory(inst)
    local inv = inst.components.inventory
    if not inv then return end

    local is_icebox = (container.prefab == "icebox")
    local target_items = is_icebox and cats.icebox or cats.chest
    local container_name = container.prefab or "?"
    local is_full = container.components.container:IsFull()

    local target_names = {}
    for _, it in ipairs(target_items) do
        if it:IsValid() then table.insert(target_names, it.prefab) end
    end
    local all_inv = {}
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item then
            local cat = ItemClassify.GetCategory(item, inst)
            table.insert(all_inv, item.prefab .. "→" .. cat)
        end
    end
    _dbg(string.format("[存放] 打开 %s (已满=%s): 要存 [%s], 背包: [%s]",
        container_name, tostring(is_full),
        table.concat(target_names, ", "),
        table.concat(all_inv, ", ")))

    local stored_count = 0
    local failed_names = {}
    for _, item in ipairs(target_items) do
        if item:IsValid() then
            if is_icebox and _IsIceboxBlacklisted(inst, item.prefab) then
                table.insert(failed_names, item.prefab .. "(blacklist)")
            else
                local item_prefab = item.prefab or "unknown"
                local taken = inv:RemoveItem(item, true)
                if taken then
                    if not taken:IsValid() then
                        print("[警告] SmartStoreInSingleContainer: RemoveItem后物品已失效: " .. tostring(item_prefab))
                    else
                        if container.components.container:GiveItem(taken, nil, nil, false) then
                            stored_count = stored_count + 1
                            if is_icebox then _ClearIceboxFail(inst, taken.prefab) end
                        else
                            if taken:IsValid() then
                                inv:GiveItem(taken)
                                if is_icebox then _RecordIceboxFail(inst, taken.prefab) end
                                table.insert(failed_names, taken.prefab .. "(rejected)")
                            else
                                print("[警告] SmartStoreInSingleContainer: 物品传输中丢失: " .. tostring(item_prefab))
                            end
                        end
                    end
                end
            end
        end
    end

    local overflow_count = 0
    if not is_icebox then
        for _, item in ipairs(cats.icebox) do
            if item:IsValid() then
                local item_prefab = item.prefab or "unknown"
                local taken = inv:RemoveItem(item, true)
                if taken then
                    if not taken:IsValid() then
                        print("[警告] SmartStoreInSingleContainer(溢出): RemoveItem后物品已失效: " .. tostring(item_prefab))
                    elseif container.components.container:GiveItem(taken, nil, nil, false) then
                        overflow_count = overflow_count + 1
                    else
                        if taken:IsValid() then
                            inv:GiveItem(taken)
                        else
                            print("[警告] SmartStoreInSingleContainer(溢出): 物品传输中丢失: " .. tostring(item_prefab))
                        end
                    end
                end
            end
        end
    end

    -- 诊断日志：结果
    local result = string.format("[存放] 结果: 成功=%d, 溢出=%d", stored_count, overflow_count)
    if #failed_names > 0 then
        result = result .. ", 失败=[" .. table.concat(failed_names, ", ") .. "]"
    end
    _dbg(result)

    -- ground / delete 始终就地处理
    InvUtil.HandleGroundAndDelete(inst, cats.ground, cats.delete, dump_pos)
end

--- 检查背包中是否有可处理的非工具物品（icebox/chest/ground/delete）
--- "ignore" 类物品不会触发存放/丢弃流程
function InvUtil.HasNonToolItems(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item then
            local cat = ItemClassify.GetCategory(item, inst)
            if cat ~= "tool" and cat ~= "ignore" then
                if DEBUG_BEHAVIOR then
                    print("[NPC_DEBUG] HasNonToolItems - found:", item.prefab, "cat=", cat, "=> true")
                end
                return true
            end
        end
    end
    if DEBUG_BEHAVIOR then
        print("[NPC_DEBUG] HasNonToolItems => false")
    end
    return false
end


function InvUtil.CountNonToolItems(inst)
    local inv = inst.components.inventory
    if not inv then return 0 end
    local count = 0
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item then
            local cat = ItemClassify.GetCategory(item, inst)
            if cat ~= "tool" and cat ~= "ignore" then
                count = count + 1
            end
        end
    end
    return count
end


function InvUtil.HasInventorySpace(inst)
    local inv = inst and inst.components and inst.components.inventory
    if not inv then return false end
    local function IsUsableSlot(item)
        if not item then
            return true
        end
        -- ignore 物品可被丢弃腾出空间
        local cat = ItemClassify.GetCategory(item, inst)
        return cat == "ignore"
    end
    for i = 1, inv.maxslots do
        if IsUsableSlot(inv:GetItemInSlot(i)) then return true end
    end
    local overflow = inv.GetOverflowContainer and inv:GetOverflowContainer() or nil
    if overflow and overflow.slots then
        for i = 1, (overflow.numslots or 0) do
            if IsUsableSlot(overflow.slots[i]) then return true end
        end
    end
    return false
end


-- ═══════════════════════════════════════════════════════════
--  智能容器选择（优先堆叠已有物品，节省格子）
-- ═══════════════════════════════════════════════════════════

function InvUtil.FindBestContainer(inv_prefabs, containers, test_item)
    if not containers or #containers == 0 then return nil end

    -- 阶段1：找有匹配「未满堆叠」的容器（匹配种类越多越优先）
    local best, best_matches = nil, 0
    for _, c in ipairs(containers) do
        if c and c:IsValid() and c.components.container then
            local matches = 0
            for i = 1, c.components.container:GetNumSlots() do
                local slot = c.components.container:GetItemInSlot(i)
                if slot and inv_prefabs[slot.prefab]
                   and slot.components.stackable
                   and not slot.components.stackable:IsFull() then
                    matches = matches + 1
                end
            end
            if matches > best_matches then
                best, best_matches = c, matches
            end
        end
    end
    if best then
        return best
    end

    -- 阶段2：退而求其次，任意有空位的容器（增加 itemtestfn 验证）
    for _, c in ipairs(containers) do
        if c and c:IsValid() and c.components.container
           and not c.components.container:IsFull() then
            -- 如果有测试物品，验证容器是否接受
            if test_item and test_item:IsValid() then
                local cont = c.components.container
                -- 使用 CanTakeItemInSlot 检查是否有槽位能放入
                local can_accept = false
                for i = 1, cont:GetNumSlots() do
                    if cont:CanTakeItemInSlot(test_item, i) then
                        can_accept = true
                        break
                    end
                end
                if can_accept then
                    return c
                end
            else
                return c
            end
        end
    end

    return nil
end

--- 检查容器是否有可用空间（空槽位 或 未满堆叠）
--- 比 IsFull() 更准确：物理满但有堆叠空间时返回 true
function InvUtil.ContainerHasSpace(container)
    if not container or not container:IsValid() or not container.components.container then
        return false
    end
    local cont = container.components.container
    if not cont:IsFull() then return true end  -- 有空槽
    for i = 1, cont:GetNumSlots() do
        local item = cont:GetItemInSlot(i)
        if item and item.components.stackable and not item.components.stackable:IsFull() then
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
--  诊断 (Diagnostic)
-- ═══════════════════════════════════════════════════════════

InvUtil.IsIceboxBlacklisted   = _IsIceboxBlacklisted
InvUtil.ClearIceboxFail       = _ClearIceboxFail


-- ═══════════════════════════════════════════════════════════
--  统一遍历：口袋 + 已装备背包(overflow) 里的所有物品
-- ═══════════════════════════════════════════════════════════

function InvUtil.ForEachCarriedItem(inst, fn)
    local inv = inst and inst.components and inst.components.inventory
    if not inv then return end
    -- 1) 口袋槽位
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item ~= nil and fn(item) then return end
    end
    -- 2) 已装备背包(overflow) 里的物品
    local overflow = inv.GetOverflowContainer and inv:GetOverflowContainer() or nil
    if overflow ~= nil and overflow.slots then
        for i = 1, (overflow.numslots or 0) do
            local item = overflow.slots[i]
            if item ~= nil and fn(item) then return end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  按 prefab 查找背包物品（从 healandretreat/kiteandattack 提取）
-- ═══════════════════════════════════════════════════════════

function InvUtil.FindItemByPrefab(inst, prefab)
    local inv = inst.components.inventory
    if not inv then return nil end
    -- 先检查手持装备
    local hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hands and hands.prefab == prefab then return hands end
    -- 遍历口袋 + 已装备背包
    local found = nil
    InvUtil.ForEachCarriedItem(inst, function(item)
        if item.prefab == prefab then
            found = item
            return true
        end
    end)
    return found
end

-- ═══════════════════════════════════════════════════════════
--  查找背包中最高伤害的武器（从 healandretreat/kiteandattack 提取）
-- ═══════════════════════════════════════════════════════════

function InvUtil.FindBestWeapon(inst)
    local inv = inst.components.inventory
    if not inv then return nil end
    local best, best_dmg = nil, 0
    -- 检查已装备的武器
    local equipped = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equipped ~= nil and equipped.components.weapon ~= nil then
        best = equipped
        best_dmg = equipped.components.weapon:GetDamage(inst) or 0
    end
    -- 遍历口袋 + 已装备背包，找伤害更高的武器
    InvUtil.ForEachCarriedItem(inst, function(item)
        if item.components.weapon ~= nil
           and item.components.equippable ~= nil
           and item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
            local dmg = item.components.weapon:GetDamage(inst) or 0
            if dmg > best_dmg then
                best, best_dmg = item, dmg
            end
        end
    end)
    return best
end

-- ═══════════════════════════════════════════════════════════
--  安全删除指定 prefab 的物品（从 npc_cooking_behavior 提取）
-- ═══════════════════════════════════════════════════════════

function InvUtil.DeleteItemByPrefab(inst, prefab)
    local inv = inst.components.inventory
    if not inv then return false end
    local food = inv:FindItem(function(item)
        return item.prefab == prefab
    end)
    if food then
        inv:RemoveItem(food)
        food:Remove()
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
--  检查是否有可存储物品（从 farmingbehavior 提取）
-- ═══════════════════════════════════════════════════════════

function InvUtil.HasStorableItems(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and not NPC_TUNING.IsNPCTool(item, inst) then
            local cat = ItemClassify.GetCategory(item, inst)
            if cat == "icebox" or cat == "chest" then return true end
        end
    end
    return false
end


return InvUtil
