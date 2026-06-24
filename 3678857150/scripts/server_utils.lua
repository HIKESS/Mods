-- ========== 服务端通用函数 ==========

-- 在目标玩家身上执行管理员操作（服务端调用）
function ExecuteAdminAction(target, action)
    if not target or not target.components then return end
    if action == "respawn" then
        target:PushEvent("respawnfromghost")
    elseif action == "fullrestore" then
        if target.components.health then target.components.health:SetPercent(1) end
        if target.components.hunger then target.components.hunger:SetPercent(1) end
        if target.components.sanity then target.components.sanity:SetPercent(1) end
    end
end

-- 检查物品是否为角色专属（不可拿取）
local UNTAKEABLE_PREFABS = {
    lucy = true,                -- 伍迪的Lucy斧
    abigail_flower = true,      -- 温蒂的阿比盖尔花
    bernie_inactive = true,     -- 薇洛的伯尼
    wortox_soul = true,         -- 沃拓克斯的灵魂
    lighter = true,             -- 薇洛的打火机
    waxwelljournal = true,      -- 麦斯威尔的暗影典籍
    pocketwatch_heal = true,    -- 旺达的治愈怀表
    slingshot = true,           -- 沃尔特的弹弓
    spider_whistle = true,      -- 韦伯的蜘蛛口哨
}

-- NPC 角色专属不可拿取工具（直接查表，不依赖标签 — 老档/重启后仍生效）
local NPC_CHAR_UNTAKEABLE = {
    wormwood = { farm_plow_item=true, farm_hoe=true, shovel=true, wateringcan=true, hammer=true },
    wanda = { pocketwatch_weapon=true, pocketwatch_heal=true },
    walter = { slingshot=true, spear=true },
}

function IsUntakeableItem(item)
    if not item then return false end
    -- prefab 黑名单
    if item.prefab and UNTAKEABLE_PREFABS[item.prefab] then return true end
    -- NPC 不可拿取的专属工具（标签检查 — 运行时标记）
    local ok0, r0 = GLOBAL.pcall(function() return item:HasTag("_npc_untakeable") end)
    if ok0 and r0 then return true end
    -- NPC 角色专属工具（无需标签，直接通过持有者角色类型查表 — 老档兼容）
    -- 仅保护初始工具（_npc_initial_tool），玩家给的/地上捡的同类工具不拦截
    local ok_npc, npc_char = GLOBAL.pcall(function()
        local owner = item.components and item.components.inventoryitem and item.components.inventoryitem.owner
        return owner and owner.npc_character_type
    end)
    if ok_npc and npc_char and item.prefab then
        local char_tools = NPC_CHAR_UNTAKEABLE[npc_char]
        if char_tools and char_tools[item.prefab] then
            local ok_init, is_init = GLOBAL.pcall(function() return item._npc_initial_tool end)
            if ok_init and is_init then
                return true
            end
        end
    end
    -- 标签检测
    local ok1, r1 = GLOBAL.pcall(function() return item:HasTag("personal_possession") end)
    if ok1 and r1 then return true end
    local ok2, r2 = GLOBAL.pcall(function() return item:HasTag("nosteal") end)
    if ok2 and r2 then return true end
    local ok3, r3 = GLOBAL.pcall(function()
        return item.components and item.components.inventoryitem
            and item.components.inventoryitem.owner_tag
            and item.components.inventoryitem.owner_tag ~= ""
    end)
    if ok3 and r3 then return true end
    return false
end

local function IsNPCUntakeableItem(item)
    if not item then return false end
    local ok0, r0 = GLOBAL.pcall(function() return item:HasTag("_npc_untakeable") end)
    if ok0 and r0 then return true end

    local ok_npc, npc_char = GLOBAL.pcall(function()
        local owner = item.components and item.components.inventoryitem and item.components.inventoryitem.owner
        return owner and owner.npc_character_type
    end)
    if ok_npc and npc_char and item.prefab then
        local char_tools = NPC_CHAR_UNTAKEABLE[npc_char]
        if char_tools and char_tools[item.prefab] then
            local ok_init, is_init = GLOBAL.pcall(function() return item._npc_initial_tool end)
            if ok_init and is_init then
                return true
            end
        end
    end

    return false
end

-- 从目标玩家身上取走物品（服务端调用）
-- 返回 prefab, 实际数量  或 nil
function TakeItemFromPlayer(target, slot_type, slot_key, amount)
    if not target or not target.components or not target.components.inventory then return nil, nil end
    if slot_type == "E" then return nil, nil end
    local inv = target.components.inventory
    local item = nil

    if slot_type == "I" then
        local sn = GLOBAL.tonumber(slot_key)
        if sn then item = inv.itemslots[sn] end
    elseif slot_type == "B" then
        local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
        if ok and overflow then
            local sn = GLOBAL.tonumber(slot_key)
            if sn then item = overflow.slots[sn] end
        end
    end

    if not item then return nil, nil end
    if IsUntakeableItem(item) then return nil, nil end
    local prefab = item.prefab
    local stack_size = 1
    if item.components and item.components.stackable then
        stack_size = item.components.stackable:StackSize() or 1
    end
    local take = (amount <= 0) and stack_size or math.min(amount, stack_size)

    local taken_item = nil
    if take >= stack_size then
        taken_item = inv:RemoveItem(item, true)
    else
        if item.components and item.components.stackable then
            taken_item = item.components.stackable:Get(take)
        end
    end

    return prefab, take, taken_item
end

-- 将物品放入目标玩家的指定槽位
-- 同种可堆叠：尽量合并，超出上限的数量以 cursor_item（数量已减少）形式返回
-- 不同种（或同种不可堆叠）：交换，被替换的物品作为返回值
-- 返回值：需要回到管理员光标的物品实体（nil = 光标变空）
function PlaceItemInPlayerSlot(target, slot_type, slot_key, item)
    if not target or not target.components or not target.components.inventory then return item end
    if not item then return nil end
    local inv = target.components.inventory

    local container = nil
    local slot_num = nil
    local current = nil

    if slot_type == "I" then
        slot_num = GLOBAL.tonumber(slot_key)
        if not slot_num then return item end
        container = inv
        current = inv.itemslots[slot_num]
    elseif slot_type == "B" then
        local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
        if not ok or not overflow then return item end
        slot_num = GLOBAL.tonumber(slot_key)
        if not slot_num then return item end
        container = overflow
        current = overflow.slots[slot_num]
    else
        return item
    end

    if current and current.prefab == item.prefab
        and current.components and current.components.stackable
        and item.components and item.components.stackable then

        local cur_stack  = current.components.stackable
        local item_stack = item.components.stackable
        local max_size   = cur_stack.maxsize or 40
        local cur_size   = cur_stack:StackSize()
        local item_size  = item_stack:StackSize()
        local can_add    = max_size - cur_size

        if can_add <= 0 then
            return item
        elseif can_add >= item_size then
            cur_stack:SetStackSize(cur_size + item_size)
            item:Remove()
            return nil
        else
            cur_stack:SetStackSize(max_size)
            item_stack:SetStackSize(item_size - can_add)
            return item
        end
    end

    local displaced = nil
    if current then
        displaced = container:RemoveItem(current, true)
    end
    container:GiveItem(item, slot_num)
    return displaced
end

local _DSTADMIN_MAXSTACK_CACHE = {}
local function _GetPrefabMaxStack(prefab)
    if not prefab or prefab == "" then return 1 end
    if _DSTADMIN_MAXSTACK_CACHE[prefab] ~= nil then
        return _DSTADMIN_MAXSTACK_CACHE[prefab]
    end
    local maxsize = 1
    GLOBAL.pcall(function()
        local test = GLOBAL.SpawnPrefab(prefab)
        if test then
            if test.components and test.components.stackable then
                maxsize = test.components.stackable.maxsize or 40
            end
            test:Remove()
        end
    end)
    if maxsize < 1 then maxsize = 1 end
    _DSTADMIN_MAXSTACK_CACHE[prefab] = maxsize
    return maxsize
end

local function _GivePrefabCountToContainerSlots(container, slots, numslots, prefab, remain, maxsize)
    if not container or not slots or remain <= 0 then return remain end

    for _, item in pairs(slots) do
        if remain <= 0 then break end
        if item and item.prefab == prefab and item.components and item.components.stackable then
            local cur = item.components.stackable:StackSize() or 1
            local can = math.max(0, maxsize - cur)
            if can > 0 then
                local add = math.min(can, remain)
                item.components.stackable:SetStackSize(cur + add)
                remain = remain - add
            end
        end
    end

    for slot = 1, (GLOBAL.tonumber(numslots) or 0) do
        local item = slots[slot]
        if remain <= 0 then break end
        if item == nil then
            local put = math.min(remain, maxsize)
            local spawned = GLOBAL.SpawnPrefab(prefab)
            if spawned then
                if put > 1 and spawned.components and spawned.components.stackable then
                    spawned.components.stackable:SetStackSize(put)
                end
                local ok = GLOBAL.pcall(function()
                    container:GiveItem(spawned, slot)
                end)
                if ok then
                    remain = remain - put
                else
                    if spawned:IsValid() then spawned:Remove() end
                    break
                end
            else
                break
            end
        end
    end
    return remain
end

-- 按“先叠加后空槽”向玩家物品栏放入指定数量，返回 accepted, remaining
function GiveItemToPlayer(target, prefab, count)
    if not target or not target.components or not target.components.inventory then return 0, count or 0 end
    if not prefab or prefab == "" then return 0, count or 0 end
    count = GLOBAL.tonumber(count) or 1
    if count < 1 then count = 1 end

    local inv = target.components.inventory
    local remain = count
    local maxsize = _GetPrefabMaxStack(prefab)

    remain = _GivePrefabCountToContainerSlots(inv, inv.itemslots or {}, inv.maxslots or 0, prefab, remain, maxsize)

    local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
    if ok and overflow and remain > 0 then
        remain = _GivePrefabCountToContainerSlots(overflow, overflow.slots or {}, overflow.numslots or 0, prefab, remain, maxsize)
    end

    local accepted = math.max(0, count - remain)
    return accepted, remain
end

-- 收集指定玩家的物品（服务端通用函数）
-- 返回格式：
--   "CAP:maxslots:equip1,equip2,...:bp_slots|E:key:prefab:1:0,I:slot:prefab:count:flag,B:slot:prefab:count:flag,..."
--   各字段含义：
--     CAP 段  - maxslots=物品栏格数, equip列表=装备槽名, bp_slots=背包格数
--     物品段  - 类型(E/I/B) : 槽位键 : prefab名 : 堆叠数 : 是否专属(1=不可拿取) : 图标名 : 图标atlas
function CollectInventory(target)
    local parts = {}
    local cap_str = "0::0"
    if target and target.components and target.components.inventory then
        local inv = target.components.inventory
        local maxslots = inv.maxslots or 15

        local equip_names = {}
        local is_npc_target = target:HasTag("npcfriend")
        if GLOBAL.EQUIPSLOTS then
            for _, v in pairs(GLOBAL.EQUIPSLOTS) do
                local name = tostring(v)
                -- NPC 过滤掉 beard 装备槽（仅NPC生效，玩家保持默认）
                if not (is_npc_target and name == "beard") then
                    table.insert(equip_names, name)
                end
            end
        end
        table.sort(equip_names)

        local bp_slots = 0
        local ok2, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
        if ok2 and overflow then
            bp_slots = overflow.numslots or 0
        end

        cap_str = tostring(maxslots) .. ":" .. table.concat(equip_names, ",") .. ":" .. tostring(bp_slots)

        local function GetIconFields(item)
            local invitem = item ~= nil and item.components ~= nil and item.components.inventoryitem or nil
            local image = invitem ~= nil and invitem.imagename or nil
            local atlas = invitem ~= nil and invitem.atlasname or nil
            return tostring(image or item.prefab or ""), tostring(atlas or "")
        end

        local function AddItemPart(tag, key, item, count)
            local flag = (is_npc_target and IsNPCUntakeableItem(item) or IsUntakeableItem(item)) and 1 or 0
            local image, atlas = GetIconFields(item)
            table.insert(parts,
                tag .. ":" .. tostring(key)
                .. ":" .. (item.prefab or "unknown")
                .. ":" .. tostring(count)
                .. ":" .. tostring(flag)
                .. ":" .. image
                .. ":" .. atlas)
        end

        for k, item in pairs(inv.equipslots or {}) do
            if item and not (is_npc_target and tostring(k) == "beard") then
                AddItemPart("E", k, item, 1)
            end
        end
        for k, item in pairs(inv.itemslots or {}) do
            if item then
                local c = 1
                if item.components and item.components.stackable then
                    c = item.components.stackable:StackSize() or 1
                end
                AddItemPart("I", k, item, c)
            end
        end
        if ok2 and overflow then
            for k, item in pairs(overflow.slots or {}) do
                if item then
                    local c = 1
                    if item.components and item.components.stackable then
                        c = item.components.stackable:StackSize() or 1
                    end
                    AddItemPart("B", k, item, c)
                end
            end
        end
    end
    return "CAP:" .. cap_str .. "|" .. table.concat(parts, ",")
end

-- 收集指定玩家的三维属性（服务端通用函数）
-- 返回 hp, hu, sa, is_ghost
function CollectStats(target)
    local hp, hu, sa = "--", "--", "--"
    local is_ghost = false
    if target and target.components then
        GLOBAL.pcall(function()
            is_ghost = target:HasTag("playerghost")
        end)
        GLOBAL.pcall(function()
            if target.components.health then
                hp = tostring(math.floor(target.components.health.currenthealth or 0))
            end
        end)
        GLOBAL.pcall(function()
            if target.components.hunger then
                hu = tostring(math.floor(target.components.hunger.current or 0))
            end
        end)
        GLOBAL.pcall(function()
            if target.components.sanity then
                sa = tostring(math.floor(target.components.sanity.current or 0))
            end
        end)
    end
    return hp, hu, sa, is_ghost
end

-- ========== NPC 伙伴工具函数 ==========

-- 从 "OWNER_USERID:CHAR_TYPE" 格式中提取纯 owner_userid（权限检查用）
function GetNPCOwnerUserid(param)
    if not param then return nil end
    local uid = param:match("^([^:]+)")
    return uid or param
end

-- 根据所有者 userid 和可选角色类型/slot编号在当前 shard 查找 npcfriend 实体（服务端）
-- param 支持三种格式：
--   "OWNER_USERID"                       — 兼容旧调用，返回第一个匹配的 NPC
--   "OWNER_USERID:CHAR_TYPE"             — 按角色类型匹配
--   "OWNER_USERID:CHAR_TYPE:SLOT_INDEX"  — 精确匹配（支持同角色多个实例）
-- 三层优先级：owner精确匹配 > owner+char_type匹配 > 无owner的type/slot匹配
function FindNPCForOwner(param)
    if not param then return nil end
    -- 拆分为最多 3 段
    local parts = {}
    for seg in param:gmatch("[^:]+") do
        parts[#parts + 1] = seg
    end
    local owner_userid = parts[1]
    local char_type    = parts[2]  -- 可能为 nil
    local slot_index   = GLOBAL.tonumber(parts[3])  -- 可能为 nil

    local owner_fallback = nil  -- owner匹配但无精确slot的后备
    local type_fallback = nil   -- 仅char_type+slot匹配的后备（无owner匹配）
    
    for _, ent in pairs(GLOBAL.Ents or {}) do
        if ent and ent:IsValid() then
            local ok, has_tag = GLOBAL.pcall(function() return ent:HasTag("npcfriend") end)
            if ok and has_tag then
                -- 检查 leader 匹配（跟随中的 NPC）
                local ok2, leader = GLOBAL.pcall(function()
                    return ent.components.follower and ent.components.follower.leader
                end)
                local leader_match = ok2 and leader and leader.userid == owner_userid
                
                -- 检查 owner_userid 网络变量匹配（未跟随的 NPC 也保持 owner_userid）
                local ent_owner = nil
                GLOBAL.pcall(function()
                    ent_owner = ent.owner_userid and ent.owner_userid:value()
                end)
                local owner_match = ent_owner and ent_owner ~= "" and ent_owner == owner_userid
                
                if leader_match or owner_match then
                    -- 优先级1：owner匹配 + slot精确匹配
                    if slot_index and ent.npc_slot_index == slot_index then
                        return ent
                    end
                    -- 优先级2：owner匹配 + char_type匹配
                    if char_type and char_type ~= "" then
                        if ent.npc_character_type == char_type and owner_fallback == nil then
                            owner_fallback = ent
                        end
                    elseif owner_fallback == nil then
                        owner_fallback = ent  -- 无筛选条件，返回第一个
                    end
                else
                    -- 无owner匹配时，尝试 char_type + slot_index 匹配
                    if slot_index and ent.npc_slot_index == slot_index then
                        if char_type and char_type ~= "" and ent.npc_character_type == char_type then
                            type_fallback = ent  -- char_type + slot都匹配
                        elseif type_fallback == nil then
                            type_fallback = ent  -- 仅slot匹配
                        end
                    elseif char_type and char_type ~= "" and ent.npc_character_type == char_type then
                        if type_fallback == nil then
                            type_fallback = ent  -- 仅char_type匹配
                        end
                    end
                end
            end
        end
    end
    
    -- 返回优先级：owner精确匹配 > 无owner的type匹配
    return owner_fallback or type_fallback
end

-- 从 NPC 身上取走物品（服务端，支持装备槽 E、物品栏 I、背包 B）
-- 返回 prefab, count, taken_item  或  nil, nil, nil
function TakeItemFromNPC(npc, slot_type, slot_key, amount)
    if not npc or not npc.components or not npc.components.inventory then
        return nil, nil, nil
    end
    local inv = npc.components.inventory

    if slot_type == "E" then
        local item = inv.equipslots and inv.equipslots[slot_key]
        if not item then return nil, nil, nil end
        if IsNPCUntakeableItem(item) then return nil, nil, nil end
        GLOBAL.pcall(function()
            inv.equipslots[slot_key] = nil
            if item.components and item.components.inventoryitem then
                item.components.inventoryitem.owner = nil
            end
            npc:PushEvent("unequip", {item = item, eslot = slot_key})
        end)
        return item.prefab, 1, item
    elseif slot_type == "I" then
        local sn = GLOBAL.tonumber(slot_key)
        if not sn then return nil, nil, nil end
        local item = inv.itemslots[sn]
        if not item then return nil, nil, nil end
        if IsNPCUntakeableItem(item) then return nil, nil, nil end
        local prefab = item.prefab
        local stack_size = 1
        if item.components and item.components.stackable then
            stack_size = item.components.stackable:StackSize() or 1
        end
        local take = (amount <= 0) and stack_size or math.min(amount, stack_size)
        local taken_item = nil
        if take >= stack_size then
            taken_item = inv:RemoveItem(item, true)
        else
            if item.components and item.components.stackable then
                taken_item = item.components.stackable:Get(take)
            end
        end
        return prefab, take, taken_item
    elseif slot_type == "B" then
        local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
        if not ok or not overflow then return nil, nil, nil end
        local sn = GLOBAL.tonumber(slot_key)
        if not sn then return nil, nil, nil end
        local item = overflow.slots and overflow.slots[sn] or nil
        if not item then return nil, nil, nil end
        if IsNPCUntakeableItem(item) then return nil, nil, nil end
        local prefab = item.prefab
        local stack_size = 1
        if item.components and item.components.stackable then
            stack_size = item.components.stackable:StackSize() or 1
        end
        local take = (amount <= 0) and stack_size or math.min(amount, stack_size)
        local taken_item = nil
        if take >= stack_size then
            taken_item = overflow:RemoveItem(item, true)
        else
            if item.components and item.components.stackable then
                taken_item = item.components.stackable:Get(take)
            end
        end
        return prefab, take, taken_item
    end
    return nil, nil, nil
end

-- 将物品放入 NPC 的指定槽位（服务端，支持装备槽 E、物品栏 I、背包 B）
-- 返回值：需要回到管理员光标的物品（nil = 光标变空）
function PlaceItemInNPCSlot(npc, slot_type, slot_key, item)
    if not npc or not npc.components or not npc.components.inventory then
        return item
    end
    if not item then return nil end
    local inv = npc.components.inventory

    if slot_type == "E" then
        if not item.components or not item.components.equippable then
            return item  -- 物品不可装备，拒绝放入
        end
        if tostring(item.components.equippable.equipslot) ~= tostring(slot_key) then
            return item  -- 装备槽位不匹配，拒绝放入
        end
        local current = inv.equipslots and inv.equipslots[slot_key]
        if current and IsNPCUntakeableItem(current) then
            return item
        end
        local displaced = nil
        GLOBAL.pcall(function()
            if current then
                inv.equipslots[slot_key] = nil
                if current.components and current.components.inventoryitem then
                    current.components.inventoryitem.owner = nil
                end
                npc:PushEvent("unequip", {item = current, eslot = slot_key})
                displaced = current
            end
            inv.equipslots[slot_key] = item
            if item.components and item.components.inventoryitem then
                item.components.inventoryitem.owner = npc
            end
            npc:PushEvent("equip", {item = item, eslot = slot_key})
        end)
        return displaced
    elseif slot_type == "I" then
        local slot_num = GLOBAL.tonumber(slot_key)
        if not slot_num then return item end
        local current = inv.itemslots[slot_num]
        if current and IsNPCUntakeableItem(current) then
            return item
        end
        if current and current.prefab == item.prefab
            and current.components and current.components.stackable
            and item.components and item.components.stackable then
            local cur_stack  = current.components.stackable
            local item_stack = item.components.stackable
            local max_size   = cur_stack.maxsize or 40
            local cur_size   = cur_stack:StackSize()
            local item_size  = item_stack:StackSize()
            local can_add    = max_size - cur_size
            if can_add <= 0 then return item end
            if can_add >= item_size then
                cur_stack:SetStackSize(cur_size + item_size)
                item:Remove()
                return nil
            else
                cur_stack:SetStackSize(max_size)
                item_stack:SetStackSize(item_size - can_add)
                return item
            end
        end
        local displaced = nil
        if current then
            displaced = inv:RemoveItem(current, true)
        end
        inv:GiveItem(item, slot_num)
        return displaced
    elseif slot_type == "B" then
        local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
        if not ok or not overflow then return item end
        local slot_num = GLOBAL.tonumber(slot_key)
        if not slot_num then return item end
        local current = overflow.slots and overflow.slots[slot_num] or nil
        if current and IsNPCUntakeableItem(current) then
            return item
        end
        if current and current.prefab == item.prefab
            and current.components and current.components.stackable
            and item.components and item.components.stackable then
            local cur_stack  = current.components.stackable
            local item_stack = item.components.stackable
            local max_size   = cur_stack.maxsize or 40
            local cur_size   = cur_stack:StackSize()
            local item_size  = item_stack:StackSize()
            local can_add    = max_size - cur_size
            if can_add <= 0 then return item end
            if can_add >= item_size then
                cur_stack:SetStackSize(cur_size + item_size)
                item:Remove()
                return nil
            else
                cur_stack:SetStackSize(max_size)
                item_stack:SetStackSize(item_size - can_add)
                return item
            end
        end
        local displaced = nil
        if current then
            displaced = overflow:RemoveItem(current, true)
        end
        overflow:GiveItem(item, slot_num)
        return displaced
    end
    return item
end

-- ========== NPC 状态收集函数 ==========

-- 收集指定 NPC 的状态信息（服务端通用函数）
-- 返回格式：
-- "char_type|hp_cur:hp_max|hu_cur:hu_max|sa_cur:sa_max|is_following|leader_name|abilities_str|work_enabled|work_range|work_center"
-- work_center: "x:z" 或 "none"
function CollectNPCStatus(npc)
    if not npc or not npc.components then return "" end

    -- 角色类型
    local char_type = npc.npc_character_type or "wilson"

    -- 健康值
    local hp_cur, hp_max = 0, 0
    GLOBAL.pcall(function()
        if npc.components.health then
            hp_cur = math.floor(npc.components.health.currenthealth or 0)
            hp_max = math.floor(npc.components.health.maxhealth or 0)
        end
    end)

    -- 饱食度
    local hu_cur, hu_max = 0, 0
    GLOBAL.pcall(function()
        if npc.components.hunger then
            hu_cur = math.floor(npc.components.hunger.current or 0)
            hu_max = math.floor(npc.components.hunger.max or 0)
        elseif npc._wolfgang_hunger and npc._wolfgang_max_hunger then
            hu_cur = math.floor(npc._wolfgang_hunger or 0)
            hu_max = math.floor(npc._wolfgang_max_hunger or 0)
        end
    end)

    -- 精神值（可能不存在）
    local sa_cur, sa_max = 0, 0
    GLOBAL.pcall(function()
        if npc.components.sanity then
            sa_cur = math.floor(npc.components.sanity.current or 0)
            sa_max = math.floor(npc.components.sanity.max or 0)
        end
    end)

    -- 跟随状态
    local is_following = false
    GLOBAL.pcall(function()
        is_following = npc.components.follower and npc.components.follower.leader ~= nil
    end)

    -- 跟随者名称
    local leader_name = ""
    GLOBAL.pcall(function()
        if npc.components.follower and npc.components.follower.leader then
            local leader = npc.components.follower.leader
            leader_name = leader.name or "???"
        end
    end)
    leader_name = (leader_name ~= "" and leader_name) or "none"

    -- 角色专属能力
    local abilities_str = ""
    GLOBAL.pcall(function()
        local NPC_TUNING = GLOBAL.NPC_TUNING
        if NPC_TUNING and NPC_TUNING.CHARACTER_ABILITIES then
            local char_abilities = NPC_TUNING.CHARACTER_ABILITIES[char_type]
            if char_abilities then
                local ability_parts = {}
                for _, ability in ipairs(char_abilities) do
                    local active = true -- 无 checker 的能力默认可用（制造/放置类）
                    local label_key = ability.label_key
                    if ability.id == "walter_auto_story" then
                        label_key = npc._walter_auto_story_enabled and "btn_walter_auto_story_on" or "btn_walter_auto_story_off"
                    end
                    if NPC_TUNING.ABILITY_STATE_CHECKERS and NPC_TUNING.ABILITY_STATE_CHECKERS[ability.id] then
                        active = false
                        GLOBAL.pcall(function()
                            active = NPC_TUNING.ABILITY_STATE_CHECKERS[ability.id](npc) == true
                        end)
                    end
                    GLOBAL.pcall(function()
                        local aff = GLOBAL.NPC_AFFINITY
                        if aff and aff.CommandUnlocked and not aff.CommandUnlocked(npc, ability.command) then
                            active = false
                        end
                    end)
                    -- 灰按键原因（仅"在此处工作"类按键）：affinity=好感度不足，working=正在工作中。
                    local reason = ""
                    if not active and (ability.id == "cook_here" or ability.id == "farm_here") then
                        local aff_ok = true
                        GLOBAL.pcall(function()
                            local aff = GLOBAL.NPC_AFFINITY
                            if aff and aff.CommandUnlocked then
                                aff_ok = aff.CommandUnlocked(npc, ability.command) and true or false
                            end
                        end)
                        reason = aff_ok and "working" or "affinity"
                    end
                    table.insert(ability_parts, ability.id .. ":" .. (active and "1" or "0") .. ":" .. label_key .. ":" .. ability.command .. ":" .. reason)
                end
                abilities_str = table.concat(ability_parts, ",")
            end
        end
    end)
    if abilities_str == "" then
        abilities_str = "none"
    end

    -- 工作范围状态（模块化：按角色类型映射，不耦合 UI）
    local work_enabled = false
    local work_range = 0
    local work_center = nil -- {x=, z=}
    GLOBAL.pcall(function()
        local NPC_TUNING = GLOBAL.NPC_TUNING
        if not NPC_TUNING then return end
        if char_type == "wormwood" then
            work_range = NPC_TUNING.FARM_WEED_CHECK_RANGE or 15
            if npc._farmer and npc._farmer.farm_center then
                work_enabled = true
                work_center = npc._farmer.farm_center
            end
        elseif char_type == "warly" then
            work_range = NPC_TUNING.FARM_WORK_RADIUS or 17
            if npc._cooking_center then
                work_enabled = true
                work_center = npc._cooking_center
            end
        elseif char_type == "wes" then
            work_range = NPC_TUNING.WES_PATROL_RADIUS or 40
            if npc._wes_farm_center then
                work_enabled = true
                work_center = npc._wes_farm_center
            end
        elseif char_type == "winona" then
            work_range = NPC_TUNING.WINONA_PATROL_RADIUS or 40
            if npc._winona_farm_center then
                work_enabled = true
                work_center = npc._winona_farm_center
            end
        elseif char_type == "woodie" then
            work_range = NPC_TUNING.CHOP_SEE_DIST or 30
            if npc._woodie_chop_center then
                work_enabled = true
                work_center = npc._woodie_chop_center
            end
        elseif char_type == "wilson" then
            work_range = NPC_TUNING.FISHING_DEPOSIT_RADIUS or 12
            if npc._fishing_deposit_pos then
                work_enabled = true
                work_center = npc._fishing_deposit_pos
            elseif npc._fishing_center then
                work_enabled = true
                work_center = npc._fishing_center
            end
        elseif char_type == "wickerbottom" then
            -- 薇克巴顿：范围以角色当前位置为中心，随角色移动实时更新
            work_range = NPC_TUNING.SCHOLAR_CARE_RADIUS or 20
            local x, _, z = npc.Transform:GetWorldPosition()
            work_enabled = work_range > 0
            work_center = { x = x, z = z }
        elseif char_type == "wortox" then
            -- 沃拓克斯：回血搜索半径，中心为角色当前位置
            work_range = NPC_TUNING.WORTOX_NPC_SOUL_SEARCH_RADIUS or 20
            local x, _, z = npc.Transform:GetWorldPosition()
            work_enabled = work_range > 0
            work_center = { x = x, z = z }
        elseif char_type == "walter" then
            -- 沃尔特：自动讲故事搜索篝火范围，中心为角色当前位置
            work_range = NPC_TUNING.WALTER_STORY_FIRE_SEARCH_RADIUS or 20
            local x, _, z = npc.Transform:GetWorldPosition()
            work_enabled = work_range > 0
            work_center = { x = x, z = z }
        end
    end)
    local center_str = "none"
    if work_center and work_center.x and work_center.z then
        center_str = string.format("%.1f:%.1f", work_center.x, work_center.z)
    end

    local result = char_type
        .. "|" .. tostring(hp_cur) .. ":" .. tostring(hp_max)
        .. "|" .. tostring(hu_cur) .. ":" .. tostring(hu_max)
        .. "|" .. tostring(sa_cur) .. ":" .. tostring(sa_max)
        .. "|" .. (is_following and "1" or "0")
        .. "|" .. leader_name
        .. "|" .. abilities_str
        .. "|" .. (work_enabled and "1" or "0")
        .. "|" .. tostring(work_range)
        .. "|" .. center_str

    -- 厨师专用扩展字段：最大同食物数量（仅 warly，供 DstAdmin 面板同步）
    if char_type == "warly" then
        local cook_max = 8
        GLOBAL.pcall(function()
            local NT = GLOBAL.NPC_TUNING
            if NT and NT.COOK_SAME_DISH_MAX then
                cook_max = math.floor(NT.COOK_SAME_DISH_MAX)
            end
        end)
        result = result .. "|" .. tostring(cook_max)
    end

    -- Wilson 专用扩展字段：最大钓鱼次数（仅 wilson，供 DstAdmin 面板同步）
    if char_type == "wilson" then
        local fish_max = 3
        GLOBAL.pcall(function()
            local NT = GLOBAL.NPC_TUNING
            if NT and NT.FISHING_MAX_CATCH then
                fish_max = math.floor(NT.FISHING_MAX_CATCH)
            end
        end)
        result = result .. "|" .. tostring(fish_max)

        local fish_deposit_x, fish_deposit_z = 0, 0
        GLOBAL.pcall(function()
            local NT = GLOBAL.NPC_TUNING
            if NT and NT.FISHING_DEPOSIT_POS then
                fish_deposit_x = NT.FISHING_DEPOSIT_POS.x or 0
                fish_deposit_z = NT.FISHING_DEPOSIT_POS.z or 0
            end
        end)
        result = result .. "|" .. tostring(fish_deposit_x) .. "|" .. tostring(fish_deposit_z)
    end

    -- 温蒂专用扩展字段：海钓最大捕获次数 + 存放点坐标
    if char_type == "wendy" then
        local ocean_fish_max = 5
        GLOBAL.pcall(function()
            local NT = GLOBAL.NPC_TUNING
            if NT and NT.OCEAN_FISHING_MAX_CATCH then
                ocean_fish_max = math.floor(NT.OCEAN_FISHING_MAX_CATCH)
            end
        end)
        result = result .. "|" .. tostring(ocean_fish_max)

        local odx, odz = 0, 0
        GLOBAL.pcall(function()
            local NT = GLOBAL.NPC_TUNING
            if NT and NT.OCEAN_FISHING_DEPOSIT_POS then
                odx = NT.OCEAN_FISHING_DEPOSIT_POS.x or 0
                odz = NT.OCEAN_FISHING_DEPOSIT_POS.z or 0
            end
        end)
        result = result .. "|" .. tostring(odx) .. "|" .. tostring(odz)

        -- 温蒂专用：杀鱼开关状态
        local ocean_fish_murder = true
        GLOBAL.pcall(function()
            local NT = GLOBAL.NPC_TUNING
            if NT and NT.OCEAN_FISHING_MURDER_FISH ~= nil then
                ocean_fish_murder = NT.OCEAN_FISHING_MURDER_FISH == true
            end
        end)
        result = result .. "|" .. (ocean_fish_murder and "1" or "0")
    end

    -- 植物人专用扩展字段：作物存放点 + 垃圾存放点
    if char_type == "wormwood" then
        local crop_x, crop_z = 0, 0
        local trash_x, trash_z = 0, 0
        GLOBAL.pcall(function()
            if npc._farmer and npc._farmer.GetStoragePoint then
                local p = npc._farmer:GetStoragePoint()
                if p then
                    crop_x = p.x or 0
                    crop_z = p.z or 0
                end
            end
            if npc._farmer and npc._farmer.GetTrashDropPoint then
                local p = npc._farmer:GetTrashDropPoint()
                if p then
                    trash_x = p.x or 0
                    trash_z = p.z or 0
                end
            end
        end)
        result = result .. "|" .. tostring(crop_x) .. "|" .. tostring(crop_z)
        result = result .. "|" .. tostring(trash_x) .. "|" .. tostring(trash_z)
    end

    -- 吴迪专用扩展字段：
    --   parts[13]: 砍树尺寸过滤（small:medium:big，各 0/1）
    --   parts[14]: 挖树根开关（0/1）
    --   parts[15]: 砍多枝树开关（0/1）
    if char_type == "woodie" then
        local f_small, f_medium, f_big = 1, 1, 1
        local dig_stump = 0
        local chop_twiggy = 1
        GLOBAL.pcall(function()
            local cf = npc._woodie_chop_filter
            if cf then
                f_small  = (cf.small  ~= false) and 1 or 0
                f_medium = (cf.medium ~= false) and 1 or 0
                f_big    = (cf.big    ~= false) and 1 or 0
            end
            if npc._woodie_dig_stump == true then
                dig_stump = 1
            end
            if npc._woodie_chop_twiggy == false then
                chop_twiggy = 0
            end
        end)
        result = result .. "|" .. tostring(f_small) .. ":" .. tostring(f_medium) .. ":" .. tostring(f_big)
        result = result .. "|" .. tostring(dig_stump)
        result = result .. "|" .. tostring(chop_twiggy)
    end

    -- wes/winona 共享：整理范围（供 DstAdmin 面板同步）
    local ORGANIZE_RANGE_MAP = {
        wes    = { key = "WES_PATROL_RADIUS",    default = 30 },
        winona = { key = "WINONA_PATROL_RADIUS", default = 50 },
        warly  = { key = "FARM_WORK_RADIUS",     default = 17 },
    }
    local org_cfg = ORGANIZE_RANGE_MAP[char_type]
    if org_cfg then
        local organize_range = org_cfg.default
        GLOBAL.pcall(function()
            local NT = GLOBAL.NPC_TUNING
            if NT and NT[org_cfg.key] then
                organize_range = math.floor(NT[org_cfg.key])
            end
        end)
        result = result .. "|" .. tostring(organize_range)
        if char_type == "wes" or char_type == "winona" then
            local organize_enabled = true
            GLOBAL.pcall(function()
                organize_enabled = npc._collect_organize_disabled ~= true
            end)
            result = result .. "|" .. (organize_enabled and "1" or "0")
        end
    end

    local tts_volume = 0.5
    GLOBAL.pcall(function()
        local tts = GLOBAL.NPCFRIENDS_TTS
        if tts and tts.GetVolume then
            tts_volume = tts.GetVolume(char_type)
            return
        end
        local NT = GLOBAL.NPC_TUNING
        local volume_table = NT and NT.TTS_VOLUME
        if volume_table then
            tts_volume = volume_table[char_type] or volume_table._default or tts_volume
        end
    end)
    result = result .. "|ttsvol=" .. string.format("%.2f", GLOBAL.tonumber(tts_volume) or 0.5)

    local affinity_cur, affinity_max = 0, 400
    GLOBAL.pcall(function()
        affinity_cur = math.floor(npc._npc_affinity or 0)
        local npc_affinity = GLOBAL.NPC_AFFINITY
        if npc_affinity and npc_affinity.MAX_AFFINITY then
            affinity_max = math.floor(npc_affinity.MAX_AFFINITY)
        end
    end)
    result = result .. "|affinity=" .. tostring(affinity_cur) .. ":" .. tostring(affinity_max)

    GLOBAL.pcall(function()
        local clothing = npc._npc_clothing
        if type(clothing) ~= "table" then return end
        local fields = { base = "skinbase", body = "skinbody", hand = "skinhand", legs = "skinlegs", feet = "skinfeet" }
        for slot, key in pairs(fields) do
            local v = clothing[slot]
            if type(v) == "string" and v ~= "" then
                result = result .. "|" .. key .. "=" .. v
            end
        end
    end)

    return result
end
