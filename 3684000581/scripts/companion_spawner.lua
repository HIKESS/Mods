-- scripts/companion_spawner.lua
-- 世界生成时一次性生成所有 NPC 伙伴

local CompanionSpawner = {}
local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")

local NPC_CHARACTERS = NPC_TUNING.NPC_CHARACTERS or { "wilson", "wathgrithr", "wendy" }
local STARTING_ITEMS = NPC_TUNING.STARTING_ITEMS or { "footballhat", "spear" }
local CHARACTER_STARTING_ITEMS = NPC_TUNING.CHARACTER_STARTING_ITEMS or {}

-- ────────────────────────────────────────────────────────────
-- 生成/读档/重建链路诊断日志（复用 NPC_TUNING.DEBUG_VISIBILITY 开关）
-- 用于排查 "开档后 NPC 不生成 / 全部消失"。关闭开关时零开销。
-- ────────────────────────────────────────────────────────────
local function DBG(fmt, ...)
    if not NPC_TUNING.DEBUG_VISIBILITY then return end
    local ok, msg = pcall(string.format, fmt, ...)
    print("[NPC_SPAWN] " .. (ok and msg or tostring(fmt)))
end

-- 扫描当前分片现存 npcfriend 数量（诊断用）
local function _CountLiveNPCs()
    local n = 0
    if Ents then
        for _, ent in pairs(Ents) do
            if ent and ent:IsValid() and ent:HasTag("npcfriend") then n = n + 1 end
        end
    end
    return n
end

-- 列出 disabled_map 里被禁用的 slot（诊断用）
local function _DisabledSlotsStr()
    local map = TheWorld and TheWorld._npc_friend_disabled
    if not map then return "nil" end
    local keys = {}
    for k in pairs(map) do table.insert(keys, tostring(k)) end
    if #keys == 0 then return "{}" end
    table.sort(keys)
    return "{" .. table.concat(keys, ",") .. "}"
end


-- 白名单查找表（启动时缓存）
local _inf_chars_set = nil
local function IsInfiniteDurabilityChar(char)
    if not _inf_chars_set then
        _inf_chars_set = {}
        local list = NPC_TUNING.INFINITE_DURABILITY_CHARS or {}
        for _, c in ipairs(list) do _inf_chars_set[c] = true end
    end
    return _inf_chars_set[char] == true
end

local _inf_armor_chars_set = nil
local function IsInfiniteArmorDurabilityChar(char)
    if not _inf_armor_chars_set then
        _inf_armor_chars_set = {}
        local list = NPC_TUNING.INFINITE_ARMOR_DURABILITY_CHARS or {}
        for _, c in ipairs(list) do _inf_armor_chars_set[c] = true end
    end
    return _inf_armor_chars_set[char] == true
end

local function CollectAllItemsAndCheckInitial(inv)
    local all_items = {}
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item then table.insert(all_items, item) end
    end
    for _, eslot in ipairs({ EQUIPSLOTS.HANDS, EQUIPSLOTS.BODY, EQUIPSLOTS.HEAD }) do
        local item = inv:GetEquippedItem(eslot)
        if item then table.insert(all_items, item) end
    end
    local has_any_initial = false
    for _, item in ipairs(all_items) do
        if item._npc_initial_tool then
            has_any_initial = true
            break
        end
    end
    return all_items, has_any_initial
end

local function HookNPCTools(npc)
    local char = npc.npc_character_type
    if not IsInfiniteDurabilityChar(char) then return end

    local tool_list = CHARACTER_STARTING_ITEMS[char] or STARTING_ITEMS
    local inv = npc.components.inventory
    if not inv or #tool_list == 0 then return end

    local all_items, has_any_initial = CollectAllItemsAndCheckInitial(inv)

    for _, item in ipairs(all_items) do
        for _, tp in ipairs(tool_list) do
            if item.prefab == tp then
                if not has_any_initial or item._npc_initial_tool then
                    item._npc_initial_tool = true
                    item._npc_tool = true
                    item:AddTag("_npc_tool")
                    if item.components.finiteuses and not item._npc_use_hooked then
                        item._npc_use_hooked = true
                        local _orig = item.components.finiteuses.Use
                        item.components.finiteuses.Use = function(self, num)
                            if self.inst._npc_tool then return end
                            _orig(self, num)
                        end
                            item.components.finiteuses:SetPercent(1)
                    end
                    if item.components.fueled and not item._npc_fueled_hooked then
                        item._npc_fueled_hooked = true
                        local _orig_delta = item.components.fueled.DoDelta
                        item.components.fueled.DoDelta = function(self, amount, ...)
                            if self.inst and self.inst._npc_tool and amount ~= nil and amount < 0 then
                                return
                            end
                            return _orig_delta(self, amount, ...)
                        end
                        item.components.fueled:SetPercent(1)
                    end
                end
                break
            end
        end
    end
end

local function HookNPCArmorDurability(npc)
    local char = npc.npc_character_type
    if not IsInfiniteArmorDurabilityChar(char) then return end

    local item_list = CHARACTER_STARTING_ITEMS[char] or STARTING_ITEMS
    local inv = npc.components.inventory
    if not inv or #item_list == 0 then return end

    local all_items, has_any_initial = CollectAllItemsAndCheckInitial(inv)

    for _, item in ipairs(all_items) do
        for _, tp in ipairs(item_list) do
            if item.prefab == tp and item.components and item.components.armor then
                if not has_any_initial or item._npc_initial_tool then
                    item._npc_initial_tool = true
                    item._npc_armor = true
                    item:AddTag("_npc_armor")

                    if item.components.armor.SetPercent then
                        item.components.armor:SetPercent(1)
                    end

                    if item.components.armor.TakeDamage and not item._npc_armor_hooked then
                        item._npc_armor_hooked = true
                        local _orig = item.components.armor.TakeDamage
                        item.components.armor.TakeDamage = function(self, damage_amount, ...)
                            if self.inst and self.inst._npc_armor then
                                return 0
                            end
                            return _orig(self, damage_amount, ...)
                        end
                    end

                    if item.components.finiteuses and not item._npc_armor_use_hooked then
                        item._npc_armor_use_hooked = true
                        local _orig_use = item.components.finiteuses.Use
                        item.components.finiteuses.Use = function(self, num)
                            if self.inst and self.inst._npc_armor then return end
                            _orig_use(self, num)
                        end
                        item.components.finiteuses:SetPercent(1)
                    end
                end
                break
            end
        end
    end
end


local UNTAKEABLE_NPC_TOOLS = NPC_TUNING.UNTAKEABLE_NPC_TOOLS or {}

local function MarkUntakeableTools(npc)
    local char = npc.npc_character_type
    local untakeable_list = UNTAKEABLE_NPC_TOOLS[char]
    if not untakeable_list or #untakeable_list == 0 then return end

    local inv = npc.components.inventory
    if not inv then return end

    local allow_take = NPC_TUNING.DEBUG_ALLOW_TAKE_NPC_TOOLS
    local all_items, has_any_initial = CollectAllItemsAndCheckInitial(inv)

    for _, item in ipairs(all_items) do
        for _, tp in ipairs(untakeable_list) do
            if item.prefab == tp then
                if allow_take then
                    if item:HasTag("_npc_untakeable") then
                        item:RemoveTag("_npc_untakeable")
                    end
                else
                    if item._npc_initial_tool or not has_any_initial then
                        item._npc_initial_tool = true
                        item:AddTag("_npc_untakeable")
                    end
                end
                break
            end
        end
    end
end

-- 暴露给控制台调用：c_npcfriends_refresh_untakeable()
_G.c_npcfriends_refresh_untakeable = function()
    if not _G.TheSim or not _G.Ents then
        print("[NPCFriends] 世界未就绪")
        return
    end
    local count = 0
    for _, ent in pairs(_G.Ents) do
        if ent:IsValid() and ent.npc_character_type then
            MarkUntakeableTools(ent)
            count = count + 1
        end
    end
    local mode = NPC_TUNING.DEBUG_ALLOW_TAKE_NPC_TOOLS and "允许拿取" or "禁止拿取"
    print(string.format("[NPCFriends] 已刷新 %d 个 NPC，当前模式：%s", count, mode))
end


local function ParseNPCEntry(entry)
    local char_name, spawn_mode, explicit_enabled
    if type(entry) == "table" then
        char_name = entry.char or "wilson"
        spawn_mode = entry.spawn or "portal"
        explicit_enabled = entry.enabled
    else
        char_name = entry
        spawn_mode = "portal"
        explicit_enabled = nil
    end

    local is_enabled
    if explicit_enabled ~= nil then
        is_enabled = explicit_enabled
    elseif NPC_TUNING.IsCharEnabled then
        is_enabled = NPC_TUNING.IsCharEnabled(char_name)
    else
        is_enabled = true
    end

    return char_name, spawn_mode, is_enabled
end

-- ────────────────────────────────────────────────────────────
-- 辅助：在世界实体中查找指定 slot 的 NPC
-- ────────────────────────────────────────────────────────────
local function FindExistingNPC(char_type, slot_index)
    local slot_only_match = nil   
    local type_fallback   = nil   
    for _, ent in pairs(Ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            if ent.npc_slot_index == slot_index then
                if ent.npc_character_type == char_type then
                    return ent  
                elseif slot_only_match == nil then
                    slot_only_match = ent  
                end
            elseif ent.npc_slot_index == nil
                    and ent.npc_character_type == char_type
                    and type_fallback == nil then
                type_fallback = ent 
            end
        end
    end
    return slot_only_match or type_fallback
end

-- ────────────────────────────────────────────────────────────
-- 辅助：在世界各地找随机陆地点
-- ────────────────────────────────────────────────────────────
local function FindRandomWorldLandPositions(count)
    local positions = {}
    local map = TheWorld.Map
    local nodes = TheWorld.topology and TheWorld.topology.nodes
    if not nodes or #nodes == 0 then
        return positions
    end

    local portal_x, portal_z = 0, 0
    for _, ent in pairs(Ents) do
        if ent and ent:IsValid() and ent:HasTag("multiplayer_portal") then
            local px, _, pz = ent.Transform:GetWorldPosition()
            portal_x, portal_z = px, pz
            break
        end
    end

    local candidates = {}
    local stat_above_ground = 0   -- 在陆地上的节点数
    local stat_far_enough = 0     -- 距大门>50格的节点数
    local stat_not_island = 0     -- 排除岛屿后的节点数

    local ISLAND_TAGS = {
        "island",      -- 月岛等
        "lunacyarea",  -- 月岛区域
        "hermit",     
    }
    local function IsIslandNode(node)
        if node.tags then
            for _, tag in ipairs(node.tags) do
                local lower = string.lower(tag)
                for _, island_tag in ipairs(ISLAND_TAGS) do
                    if string.find(lower, island_tag) then return true end
                end
            end
        end
        return false
    end

    for _, node in ipairs(nodes) do
        local nx, nz = node.x, node.y  -- topology 的 y 对应世界 z
        if nx and nz and map:IsAboveGroundAtPoint(nx, 0, nz) then
            stat_above_ground = stat_above_ground + 1
            local dx, dz = nx - portal_x, nz - portal_z
            if dx * dx + dz * dz > 50 * 50 then
                stat_far_enough = stat_far_enough + 1
                if not IsIslandNode(node) then
                    stat_not_island = stat_not_island + 1
                    table.insert(candidates, { x = nx, z = nz })
                end
            end
        end
    end

    for _, c in ipairs(candidates) do
        local dx, dz = c.x - portal_x, c.z - portal_z
        c.dist = math.sqrt(dx * dx + dz * dz)
    end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)

    local segment_size = #candidates / count
    local selected = {}      -- 数组：存储选中的 { idx, seg } 表
    local used_idx  = {}     -- 哈希表：去重用，{[k]=true}
    for seg = 1, count do
        local seg_start = math.floor((seg - 1) * segment_size) + 1
        local seg_end   = math.floor(seg * segment_size)
        if seg_end < seg_start then seg_end = seg_start end
        local seg_indices = {}
        for k = seg_start, seg_end do table.insert(seg_indices, k) end
        for k = #seg_indices, 2, -1 do
            local j = math.random(k)
            seg_indices[k], seg_indices[j] = seg_indices[j], seg_indices[k]
        end
        for _, k in ipairs(seg_indices) do
            if not used_idx[k] then
                table.insert(selected, { idx = k, seg = seg })
                used_idx[k] = true
                break
            end
        end
    end

    local stat_adjust_fail = 0
    for _, sel in ipairs(selected) do
        local c = candidates[sel.idx]
        if c then
            local fx, fz = c.x, c.z
            if not map:IsPassableAtPoint(fx, 0, fz) then
                local origin = Vector3(fx, 0, fz)
                local offset = FindWalkableOffset(origin, math.random() * 2 * math.pi, 12, 24, false, true)
                            or FindWalkableOffset(origin, math.random() * 2 * math.pi, 24, 32, false, true)
                            or FindWalkableOffset(origin, math.random() * 2 * math.pi, 36, 48, false, true)
                if offset then
                    fx, fz = fx + offset.x, fz + offset.z
                else
                    stat_adjust_fail = stat_adjust_fail + 1
                    fx = nil
                end
            end
            if fx then
                table.insert(positions, { x = fx, z = fz })
            end
        end
        -- c 为 nil 时（候选点索引越界）直接跳过
    end

    if #positions < count then
        for i = 1, #candidates do
            if #positions >= count then break end
            if not used_idx[i] then
                local c = candidates[i]
                local fx, fz = c.x, c.z
                if not map:IsPassableAtPoint(fx, 0, fz) then
                    local origin = Vector3(fx, 0, fz)
                    local offset = FindWalkableOffset(origin, math.random() * 2 * math.pi, 12, 24, false, true)
                                or FindWalkableOffset(origin, math.random() * 2 * math.pi, 24, 32, false, true)
                                or FindWalkableOffset(origin, math.random() * 2 * math.pi, 36, 48, false, true)
                    if offset then
                        fx, fz = fx + offset.x, fz + offset.z
                    else
                        stat_adjust_fail = stat_adjust_fail + 1
                        fx = nil
                    end
                end
                if fx then
                    table.insert(positions, { x = fx, z = fz })
                end
            end
        end
    end

    return positions
end

-- ────────────────────────────────────────────────────────────
-- 世界级持久化：
--   注意 TheWorld 在 DST 多人版上 inst.persists = false（见 prefabs/world.lua），
--   它的 OnSave/OnLoad 不会被引擎调用。`_npc_spawned` 之所以可用，是因为
--   npcfriend 实体自己会被存档、读档时由 SpawnWorldNPCs 的扫描分支重置标志。
--   `_npc_friend_disabled` 是纯数据快照、没有活实体，必须改用 TheSim:SetPersistentString
--   持久化，并用 session_identifier 隔离不同存档（与 npc_magic_chest_store 一致风格）。
-- ────────────────────────────────────────────────────────────
local _world_hooks_done = false
local _disabled_loaded = false
local _disabled_load_callbacks = {}

local function _GetDisabledKey()
    local session_id = TheWorld and TheWorld.meta and TheWorld.meta.session_identifier
    if not session_id or session_id == "" then return nil end
    return "npcfriends_npc_disabled_" .. tostring(session_id)
end

local function _SaveDisabledMap()
    local key = _GetDisabledKey()
    if not key or not TheSim or not TheSim.SetPersistentString then return end
    local map = (TheWorld and TheWorld._npc_friend_disabled) or {}

    for slot, rec in pairs(map) do
        local ok, err = pcall(DataDumper, rec, nil, false)
        if not ok then
            print(string.format(
                "[NPCFriends] _SaveDisabledMap: slot=%s 单条编码失败 err=%s",
                tostring(slot), tostring(err)))
        end
    end

    local ok, err = pcall(function()
        TheSim:SetPersistentString(key, DataDumper(map, nil, false), false)
    end)
    if not ok then
        print(string.format(
            "[NPCFriends] _SaveDisabledMap: 整张表落盘失败 key=%s err=%s",
            tostring(key), tostring(err)))
    end
end

local function _GetInitKey()
    local session_id = TheWorld and TheWorld.meta and TheWorld.meta.session_identifier
    if not session_id or session_id == "" then return nil end
    return "npcfriends_world_initialized_" .. tostring(session_id)
end

local function _SaveInitFlag()
    local key = _GetInitKey()
    if not key or not TheSim or not TheSim.SetPersistentString then return end
    local ok, err = pcall(function()
        TheSim:SetPersistentString(key, "1", false)
    end)
    if not ok then
        print(string.format(
            "[NPCFriends] _SaveInitFlag: 落盘失败 key=%s err=%s",
            tostring(key), tostring(err)))
    end
end

local function _LoadInitFlagThen(cb)
    local key = _GetInitKey()
    if not key or not TheSim or not TheSim.GetPersistentString then
        if cb then cb() end
        return
    end
    TheSim:GetPersistentString(key, function(load_success, str)
        if load_success and type(str) == "string" and str ~= "" then
            if TheWorld then TheWorld._npc_world_initialized = true end
        end
        if cb then cb() end
    end)
end

local function _RunPendingDisabledCallbacks()
    local cbs = _disabled_load_callbacks
    _disabled_load_callbacks = {}
    for _, cb in ipairs(cbs) do
        pcall(cb)
    end
end

local function _LoadDisabledMap()
    if _disabled_loaded then return end
    local key = _GetDisabledKey()
    if not key or not TheSim or not TheSim.GetPersistentString then
        if TheWorld then TheWorld._npc_friend_disabled = TheWorld._npc_friend_disabled or {} end
        _disabled_loaded = true
        _RunPendingDisabledCallbacks()
        return
    end
    TheSim:GetPersistentString(key, function(load_success, str)
        local map = nil
        local parse_err = nil
        if load_success and type(str) == "string" and str ~= "" then
            local ok, data = RunInSandboxSafe(str)
            if ok and type(data) == "table" then
                map = data
            else
                parse_err = tostring(data)
            end
        end
        if TheWorld then
            TheWorld._npc_friend_disabled = map or {}
        end
        if parse_err then
            print(string.format(
                "[NPCFriends] _LoadDisabledMap: 解析失败 key=%s err=%s",
                tostring(key), parse_err))
        end
        _LoadInitFlagThen(function()
            _disabled_loaded = true
            _RunPendingDisabledCallbacks()
        end)
    end)
end

local function _EnsureDisabledMapLoaded(callback)
    if _disabled_loaded then
        if callback then pcall(callback) end
        return
    end
    if callback then
        table.insert(_disabled_load_callbacks, callback)
    end
    _LoadDisabledMap()
end

local function SetupWorldPersistence()
    if _world_hooks_done or not TheWorld then return end
    _world_hooks_done = true

    local _onsave = TheWorld.OnSave
    TheWorld.OnSave = function(self, data)
        if _onsave then _onsave(self, data) end
        if self._npc_spawned then
            data.npc_friends_spawned = true
        end
    end
    local _onload = TheWorld.OnLoad
    TheWorld.OnLoad = function(self, data, newents)
        if _onload then _onload(self, data, newents) end
        if data and data.npc_friends_spawned then
            self._npc_spawned = true
        end
    end

    _LoadDisabledMap()
end

-- ────────────────────────────────────────────────────────────
-- 辅助：获取大门（出生点）位置
-- ────────────────────────────────────────────────────────────
local function GetPortalPosition()
    for _, ent in pairs(Ents) do
        if ent and ent:IsValid() and ent:HasTag("multiplayer_portal") then
            return ent:GetPosition()
        end
    end
    return Vector3(0, 0, 0)
end

-- ────────────────────────────────────────────────────────────
-- 辅助：按 slot/spawn_mode 计算落地坐标（不创建实体）
-- ────────────────────────────────────────────────────────────
local function ComputeSpawnPosition(i, char_name, spawn_mode, world_pos, portal_pos)
    local pos = portal_pos or GetPortalPosition()
    local spawn_x, spawn_z

    if spawn_mode == "world" then
        if world_pos then
            spawn_x, spawn_z = world_pos.x, world_pos.z
        else
            local retry = FindRandomWorldLandPositions(1)
            if retry and retry[1] then
                spawn_x, spawn_z = retry[1].x, retry[1].z
            else
                local angle = math.random() * 2 * math.pi
                local dist  = math.random(80, 150)
                local off   = FindWalkableOffset(pos, angle, dist, 32, false, true)
                if off then
                    spawn_x, spawn_z = pos.x + off.x, pos.z + off.z
                else
                    local angle2 = math.random() * 2 * math.pi
                    local dist2  = math.random(30, 50)
                    local off2   = FindWalkableOffset(pos, angle2, dist2, 16, false, true)
                    if off2 then
                        spawn_x, spawn_z = pos.x + off2.x, pos.z + off2.z
                    else
                        spawn_x, spawn_z = pos.x + dist2 * math.cos(angle2), pos.z + dist2 * math.sin(angle2)
                    end
                end
            end
        end
    else
        local base_angle = (i - 1) * (2 * math.pi / #NPC_CHARACTERS)
        local dist = math.random(
            NPC_TUNING.SPAWN_OFFSET_MIN or 10,
            NPC_TUNING.SPAWN_OFFSET_MAX or 15)

        if char_name == "wormwood" then
            local farm_pos = nil
            local best_tillable = 0
            for a = 1, 8 do
                local angle = (a - 1) * (2 * math.pi / 8)
                local try_dist = math.random(10, 20)
                local tx = pos.x + try_dist * math.cos(angle)
                local tz = pos.z + try_dist * math.sin(angle)
                if TheWorld.Map:IsPassableAtPoint(tx, 0, tz) then
                    local tillable = 0
                    local spacing = NPC_TUNING.FARM_GRID_SPACING or 1.3
                    for row = -1, 1 do
                        for col = -1, 1 do
                            local sx = tx + col * spacing
                            local sz = tz + row * spacing
                            if TheWorld.Map:CanTillSoilAtPoint(sx, 0, sz, true) then
                                tillable = tillable + 1
                            end
                        end
                    end
                    if tillable > best_tillable then
                        best_tillable = tillable
                        farm_pos = { x = tx, z = tz }
                    end
                end
            end
            if farm_pos and best_tillable >= 6 then
                spawn_x, spawn_z = farm_pos.x, farm_pos.z
            else
                spawn_x = pos.x + dist * math.cos(base_angle)
                spawn_z = pos.z + dist * math.sin(base_angle)
            end
        else
            spawn_x = pos.x + dist * math.cos(base_angle)
            spawn_z = pos.z + dist * math.sin(base_angle)
        end
        if not TheWorld.Map:IsPassableAtPoint(spawn_x, 0, spawn_z) then
            local walk_offset = FindWalkableOffset(pos, base_angle, dist, 16, false, true)
            if walk_offset then
                spawn_x, spawn_z = pos.x + walk_offset.x, pos.z + walk_offset.z
            else
                spawn_x, spawn_z = pos.x, pos.z
            end
        end
    end

    return spawn_x, spawn_z
end

-- ────────────────────────────────────────────────────────────
-- 辅助：给一只新生 NPC 派发初始物品 + 钩子
-- ────────────────────────────────────────────────────────────
local function EquipNPCStartingItems(npc, char_name)
    if not npc.components.inventory then return end

    local items = CHARACTER_STARTING_ITEMS[char_name] or STARTING_ITEMS
    local silv_item = nil
    for _, item_prefab in ipairs(items) do
        local item = SpawnPrefab(item_prefab)
        if item then
            npc.components.inventory:GiveItem(item)
            if char_name == "wilba" and item_prefab == "silvernecklace" then
                silv_item = item
            end
        end
    end
    HookNPCTools(npc)
    HookNPCArmorDurability(npc)
    MarkUntakeableTools(npc)
    if silv_item then
        npc:DoTaskInTime(0, function(inst)
            if not inst:IsValid() then return end
            if not silv_item:IsValid() then return end
            local inv = inst.components.inventory
            if not inv then return end
            if inv:GetEquippedItem(EQUIPSLOTS.BODY) == silv_item then return end
            inv:Equip(silv_item)
        end)
    end
end

-- ────────────────────────────────────────────────────────────
-- 辅助：在指定 slot 创建并装备一只新 NPC
-- ────────────────────────────────────────────────────────────
local function SpawnNPCAtSlot(i, char_name, spawn_mode, world_pos, portal_pos)
    local npc = SpawnPrefab("npcfriend")
    if not npc then return nil end

    local spawn_x, spawn_z = ComputeSpawnPosition(i, char_name, spawn_mode, world_pos, portal_pos)
    npc.Transform:SetPosition(spawn_x, 0, spawn_z)

    npc:SetAppearance(char_name)
    npc.npc_slot_index = i
    if npc.npc_slot_index_net then
        npc.npc_slot_index_net:set(i)
    end

    EquipNPCStartingItems(npc, char_name)
    return npc
end

-- 供 npc_duplicate_spawn 等外部模块复用：给一只已经 SetAppearance 的 NPC
-- 派发初始物品并挂上工具/护甲耐久 hook。
CompanionSpawner.EquipNPCStartingItems = EquipNPCStartingItems

-- ────────────────────────────────────────────────────────────
-- 世界级一次性生成：仅在地面世界首次创建时调用
-- ────────────────────────────────────────────────────────────
local function SpawnWorldNPCs()
    DBG("SpawnWorldNPCs 进入: _npc_spawned=%s _npc_world_initialized=%s forest=%s live_npc=%d disabled=%s",
        tostring(TheWorld._npc_spawned), tostring(TheWorld._npc_world_initialized),
        tostring(TheWorld:HasTag("forest")), _CountLiveNPCs(), _DisabledSlotsStr())
    if TheWorld._npc_spawned then
        DBG("SpawnWorldNPCs 提前返回: 本次会话已 _npc_spawned=true（不会再生成）")
        return
    end
    if not TheWorld:HasTag("forest") then
        DBG("SpawnWorldNPCs 提前返回: 当前分片非 forest（地面），配置 NPC 只在地面生成")
        return
    end

    -- 本存档已生成过（持久化标记）：直接收尾，永不再生成，从根上杜绝重复
    if TheWorld._npc_world_initialized then
        TheWorld._npc_spawned = true
        DBG("★ SpawnWorldNPCs 提前返回: _npc_world_initialized=true（磁盘标记说本档已初始化过）"
            .. " → 不再生成任何配置 NPC！当前分片现存 npcfriend=%d"
            .. "（若此时世界里 NPC 缺失，说明实体未随存档保存，但初始化标记已落盘，"
            .. "且 reconcile 已停用，故无法补号——这通常就是\"强关后只剩个别 NPC\"的根因）",
            _CountLiveNPCs())
        return
    end

    -- 旧档兼容：无标记但世界已有 npcfriend 或存在禁用快照 → 视为老世界，补写标记、不重生
    local has_existing = false
    for _, ent in pairs(Ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            has_existing = true
            break
        end
    end
    if has_existing or (TheWorld._npc_friend_disabled and next(TheWorld._npc_friend_disabled)) then
        TheWorld._npc_spawned = true
        TheWorld._npc_world_initialized = true
        _SaveInitFlag()
        DBG("SpawnWorldNPCs 提前返回: 老世界兼容路径（has_existing=%s disabled=%s）→ 补写初始化标记、不重生",
            tostring(has_existing), _DisabledSlotsStr())
        return
    end

    local pos = GetPortalPosition()

    local world_count = 0
    for _, entry in ipairs(NPC_CHARACTERS) do
        local _, mode, enabled = ParseNPCEntry(entry)
        if enabled and mode == "world" then world_count = world_count + 1 end
    end
    local world_positions = (world_count > 0) and FindRandomWorldLandPositions(world_count) or nil
    local world_pos_idx = 0

    local spawned_count = 0
    for i, entry in ipairs(NPC_CHARACTERS) do
        local char_name, spawn_mode, is_enabled = ParseNPCEntry(entry)
        if is_enabled then
            local wp = nil
            if spawn_mode == "world" and world_positions then
                world_pos_idx = world_pos_idx + 1
                wp = world_positions[world_pos_idx]
            end
            local npc = SpawnNPCAtSlot(i, char_name, spawn_mode, wp, pos)
            if npc then spawned_count = spawned_count + 1 end
            DBG("  SpawnWorldNPCs 生成 slot=%d char=%s spawn=%s 结果=%s",
                i, tostring(char_name), tostring(spawn_mode), npc and "OK" or "失败")
        else
            DBG("  SpawnWorldNPCs 跳过 slot=%d char=%s（配置未启用）", i, tostring(char_name))
        end
    end

    TheWorld._npc_spawned = true
    TheWorld._npc_first_spawn = true
    TheWorld._npc_world_initialized = true
    _SaveInitFlag()
    DBG("★ SpawnWorldNPCs 首次生成完成: 共生成 %d 只，已落盘初始化标记", spawned_count)
end

-- ────────────────────────────────────────────────────────────
-- 老存档配置同步：按状态表对齐 modconfig 与世界中的 NPC
-- ────────────────────────────────────────────────────────────
local function ReconcileWorldNPCs()
    if not TheWorld then return end
    if not TheWorld:HasTag("forest") then return end
    if TheWorld._npc_reconcile_done then return end
    if not TheWorld._npc_spawned then return end -- 首次开档由 SpawnWorldNPCs 处理
    TheWorld._npc_reconcile_done = true

    TheWorld._npc_friend_disabled = TheWorld._npc_friend_disabled or {}
    local disabled_map = TheWorld._npc_friend_disabled

    local existing_by_slot = {}
    for _, ent in pairs(Ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") and ent.npc_slot_index then
            existing_by_slot[ent.npc_slot_index] = ent
        end
    end

    local need_world_count = 0
    for i, entry in ipairs(NPC_CHARACTERS) do
        local _, spawn_mode, is_enabled = ParseNPCEntry(entry)
        if is_enabled and spawn_mode == "world"
           and not existing_by_slot[i] and not disabled_map[i] then
            need_world_count = need_world_count + 1
        end
    end
    local world_positions = (need_world_count > 0)
        and FindRandomWorldLandPositions(need_world_count) or nil
    local world_pos_idx = 0
    local portal_pos = GetPortalPosition()

    for i, entry in ipairs(NPC_CHARACTERS) do
        local char_name, spawn_mode, is_enabled = ParseNPCEntry(entry)
        local existing = existing_by_slot[i]
        local snapshot = disabled_map[i]

        if is_enabled then
            if existing then
                -- nothing to do
            elseif snapshot then
                disabled_map[i] = nil
                local ok, npc = pcall(SpawnSaveRecord, snapshot, nil)
                if ok and npc and npc:IsValid() then
                    HookNPCTools(npc)
                    HookNPCArmorDurability(npc)
                    MarkUntakeableTools(npc)
                    if npc.components.follower then
                        npc.components.follower:SetLeader(nil)
                    end
                    npc._owner_userid = nil
                    if npc.owner_userid then
                        npc.owner_userid:set("")
                    end
                    npc._work_paused = true
                    if npc.components.knownlocations then
                        npc.components.knownlocations:RememberLocation("home", npc:GetPosition())
                    end
                    if npc.components.combat then
                        npc.components.combat:SetTarget(nil)
                    end
                else
                    print(string.format("[NPCFriends] reconcile: 启用 slot=%d char=%s 快照恢复失败 err=%s", i, tostring(char_name), tostring(npc)))
                end
            else
                local wp = nil
                if spawn_mode == "world" and world_positions then
                    world_pos_idx = world_pos_idx + 1
                    wp = world_positions[world_pos_idx]
                end
                SpawnNPCAtSlot(i, char_name, spawn_mode, wp, portal_pos)
            end
        else
            if existing then
                existing:PushEvent("npc_pre_migration")
                if existing.components.combat then
                    existing.components.combat:SetTarget(nil)
                end
                if existing.components.follower then
                    existing.components.follower:SetLeader(nil)
                end
                local ok, rec = pcall(function() return existing:GetSaveRecord() end)
                if ok and rec then
                    disabled_map[i] = rec
                else
                    print(string.format(
                        "[NPCFriends] reconcile: 禁用 slot=%d char=%s GetSaveRecord 失败 err=%s",
                        i, tostring(char_name), tostring(rec)))
                end
                existing:Remove()
            end
        end
    end

    _SaveDisabledMap()
end

-- ────────────────────────────────────────────────────────────
-- 内部：重连/复活时重新链接已有 NPC（不生成新 NPC）
-- ────────────────────────────────────────────────────────────
local function RelinkNPCs(player)
    if player:HasTag("playerghost") then
        DBG("RelinkNPCs 跳过: 玩家是 ghost")
        return
    end

    DBG("RelinkNPCs 进入: player=%s 当前分片现存 npcfriend=%d",
        tostring(player.userid), _CountLiveNPCs())

    local relinked = 0
    for i, entry in ipairs(NPC_CHARACTERS) do
        local char_name, _, _ = ParseNPCEntry(entry)
        local existing = FindExistingNPC(char_name, i)
        if existing == nil then
            DBG("  RelinkNPCs slot=%d char=%s: 未找到对应实体", i, tostring(char_name))
        else
            local owner = existing._owner_userid
            local match = owner ~= nil and owner == player.userid
            DBG("  RelinkNPCs slot=%d char=%s: 找到 GUID=%s owner=%s 归本玩家=%s",
                i, tostring(char_name), tostring(existing.GUID),
                tostring(owner), tostring(match))
            if match then relinked = relinked + 1 end
        end

        if existing then
            if existing.npc_slot_index == nil then
                existing.npc_slot_index = i
                if existing.npc_slot_index_net then
                    existing.npc_slot_index_net:set(i)
                end
            end
            local actual_char = existing.npc_character_type or "?"
            if actual_char ~= char_name then
            end
            if existing._owner_userid and existing._owner_userid == player.userid then
                if existing.components.follower then
                    existing.components.follower:SetLeader(player)
                end
                if existing.owner_userid then
                    existing.owner_userid:set(player.userid or "")
                end
                if player.components.leader == nil then
                    player:AddComponent("leader")
                end
            end
            HookNPCTools(existing)
            HookNPCArmorDurability(existing)
            MarkUntakeableTools(existing)
        end
    end
    DBG("RelinkNPCs 完成: 归属本玩家并重新跟随 %d 只", relinked)
end

-- ────────────────────────────────────────────────────────────
-- 跨 shard 迁移：玩家上地面/下洞穴时，跟随中的 NPC 随之转移
-- ────────────────────────────────────────────────────────────
local function SetupMigrationHooks(player)

    local _ondespawn = player.OnDespawn
    player.OnDespawn = function(self, migrationdata)
        if migrationdata ~= nil then
            local saves = {}
            for _, ent in pairs(Ents) do
                if ent and ent:IsValid() and ent:HasTag("npcfriend")
                   and ent.components.follower
                   and ent.components.follower.leader == self then
                    ent:PushEvent("npc_pre_migration")
                    table.insert(saves, (ent:GetSaveRecord()))
                    ent:Remove()
                end
            end
            DBG("OnDespawn(迁移): 打包跟随中 NPC=%d 准备跨分片", #saves)
            if #saves > 0 then
                self._npc_friend_saves = saves
                if self._npc_rift_arrive_fx_pending then
                    self._npc_friend_rift_pending = true
                    self._npc_rift_arrive_fx_pending = nil
                end
            end
        else
            for _, ent in pairs(Ents) do
                if ent and ent:IsValid() and ent:HasTag("npcfriend")
                   and ent.components.follower
                   and ent.components.follower.leader == self then
                    ent.components.follower:SetLeader(nil)
                    ent._owner_userid = nil
                    if ent.owner_userid then
                        ent.owner_userid:set("")
                    end
                    ent._work_paused = true
                    if ent.components.knownlocations then
                        ent.components.knownlocations:RememberLocation("home", ent:GetPosition())
                    end
                    if ent.components.combat then
                        ent.components.combat:SetTarget(nil)
                    end
                end
            end
            self._npc_friend_saves = nil
        end
        if _ondespawn then _ondespawn(self, migrationdata) end
    end

    local _onsave = player.OnSave
    player.OnSave = function(self, data)
        local ret
        if _onsave then ret = _onsave(self, data) end
        if self._npc_friend_saves and #self._npc_friend_saves > 0 then
            data.npc_friend_saves = self._npc_friend_saves
            self._npc_friend_saves = nil  
            if self._npc_friend_rift_pending then
                data.npc_friend_rift = true
                self._npc_friend_rift_pending = nil
            end
        end
        return ret
    end


    local _onload = player.OnLoad
    player.OnLoad = function(self, data, newents)
        if _onload then _onload(self, data, newents) end
        if data and data.npc_friend_saves then
            self._npc_friend_pending = data.npc_friend_saves
            DBG("玩家 OnLoad: 读到跨分片携带的 NPC 存档 %d 只（将由 SpawnPendingNPCs 恢复）",
                #data.npc_friend_saves)
            if data.npc_friend_rift then
                self._npc_friend_rift_pending = true
            end
        else
            DBG("玩家 OnLoad: 无 npc_friend_saves（本次不是携带 NPC 的跨分片读档）")
        end
    end
end

-- ────────────────────────────────────────────────────────────
-- 延迟恢复：从 _npc_friend_pending 重建 NPC
-- ────────────────────────────────────────────────────────────
local function SpawnPendingNPCs(player)
    if not player._npc_friend_pending then
        DBG("SpawnPendingNPCs: 无 _npc_friend_pending（本次不是跨分片迁移恢复）")
        return
    end
    local saves = player._npc_friend_pending
    player._npc_friend_pending = nil

    local is_rift = player._npc_friend_rift_pending == true
    player._npc_friend_rift_pending = nil

    DBG("★ SpawnPendingNPCs 进入: 待恢复迁移 NPC=%d is_rift=%s", #saves, tostring(is_rift))

    local px, py, pz = player.Transform:GetWorldPosition()

    local restored = 0
    for _, record in ipairs(saves) do
        local ok, npc = pcall(SpawnSaveRecord, record, nil)
        DBG("  SpawnPendingNPCs 恢复一只: ok=%s char=%s", tostring(ok),
            tostring(ok and npc and npc.npc_character_type or "?"))
        if ok and npc then restored = restored + 1 end
        if ok and npc then
            HookNPCTools(npc)
            HookNPCArmorDurability(npc)
            MarkUntakeableTools(npc)
            if player.components.leader == nil then
                player:AddComponent("leader")
            end
            if npc.components.follower then
                npc.components.follower:SetLeader(player)
            end
            npc._owner_userid = player.userid
            if npc.owner_userid then
                npc.owner_userid:set(player.userid or "")
            end

            local is_ghost = npc._is_ghost_mode == true

            if is_rift and not is_ghost then
                local ang = math.random() * 2 * math.pi
                local dist = 3 + math.random()
                local ox = px + math.cos(ang) * dist
                local oz = pz + math.sin(ang) * dist
                local off = FindWalkableOffset(Vector3(px, 0, pz), ang, dist, 8, false, true)
                if off then ox = px + off.x; oz = pz + off.z end
                npc.Transform:SetPosition(ox, 0, oz)
                npc:Hide()
                npc.AnimState:SetMultColour(1, 1, 1, 0)
                if npc.DynamicShadow then npc.DynamicShadow:Enable(false) end
                if npc.Light then npc.Light:Enable(false) end
                if npc.components and npc.components.talker then
                    npc.components.talker:ShutUp()
                    _G.TheNet:Talker("", npc.entity, 0)
                    if not npc._npc_rift_orig_say then
                        npc._npc_rift_orig_say = npc.components.talker.Say
                        npc.components.talker.Say = function() end
                    end
                    if not npc._npc_rift_orig_chatter then
                        npc._npc_rift_orig_chatter = npc.components.talker.Chatter
                        npc.components.talker.Chatter = function() end
                    end
                end

                local is_wanda = npc.npc_character_type == "wanda"
                npc:DoTaskInTime(1.5, function(n)
                    if n == nil or not n:IsValid() then return end
                    local fx = SpawnPrefab("pocketwatch_portal_exit_fx")
                    if fx then
                        local nx, _, nz = n.Transform:GetWorldPosition()
                        fx.Transform:SetPosition(nx, 4, nz)
                    end
                    n:DoTaskInTime(0.05, function(nn)
                        if nn == nil or not nn:IsValid() then return end
                        if nn.components and nn.components.talker then
                            if nn._npc_rift_orig_say then
                                nn.components.talker.Say = nn._npc_rift_orig_say
                                nn._npc_rift_orig_say = nil
                            end
                            if nn._npc_rift_orig_chatter then
                                nn.components.talker.Chatter = nn._npc_rift_orig_chatter
                                nn._npc_rift_orig_chatter = nil
                            end
                        end
                        if nn.sg ~= nil then
                            nn:PushEvent("npc_rift_arrive", { is_wanda = is_wanda })
                        else
                            nn:Show()
                            nn.AnimState:SetMultColour(1, 1, 1, 1)
                            if nn.DynamicShadow then nn.DynamicShadow:Enable(true) end
                            if nn.Light then nn.Light:Enable(true) end
                        end
                    end)
                end)
            else
                npc.Transform:SetPosition(px, py, pz)
            end
        end
    end
    DBG("★ SpawnPendingNPCs 完成: 成功恢复 %d/%d 只", restored, #saves)
end

-- ────────────────────────────────────────────────────────────
-- 公开：注册玩家事件（由 modmain 的 AddPlayerPostInit 调用）
-- ────────────────────────────────────────────────────────────
function CompanionSpawner.RegisterPlayer(player)
    SetupWorldPersistence()

    SetupMigrationHooks(player)

    player:ListenForEvent("respawnfromghost", function(p)
        RelinkNPCs(p)
    end)

    player:DoTaskInTime(0, function(p)
        if not (p and p:IsValid()) then return end
        if not p._npc_friend_rift_pending then return end
        local _player_hide_task = p:DoPeriodicTask(0.1, function(pp)
            if not (pp and pp:IsValid()) then return end
            pp:Hide()
            pp.AnimState:SetMultColour(0, 0, 0, 0)
            if pp.DynamicShadow then pp.DynamicShadow:Enable(false) end
            if pp.components.playercontroller then
                pp.components.playercontroller:Enable(false)
            end
        end)
        p:DoTaskInTime(2, function(pp)
            if not (pp and pp:IsValid()) then return end
            if _player_hide_task then
                _player_hide_task:Cancel()
                _player_hide_task = nil
            end
            pp.AnimState:SetMultColour(1, 1, 1, 1)
            if pp.sg then
                pp.sg:GoToState("pocketwatch_portal_land")
            end
        end)
    end)

    player:DoTaskInTime(1, function()
        if not player:IsValid() then return end
        DBG("════ RegisterPlayer 流程开始 player=%s 分片=%s 现存 npcfriend=%d ════",
            tostring(player.userid),
            (TheWorld and TheWorld:HasTag("cave")) and "cave" or "forest",
            _CountLiveNPCs())
        SpawnPendingNPCs(player)
        _EnsureDisabledMapLoaded(function()
            if not player:IsValid() then return end
            DBG("磁盘标记加载完成: _npc_world_initialized=%s disabled=%s",
                tostring(TheWorld and TheWorld._npc_world_initialized), _DisabledSlotsStr())
            SpawnWorldNPCs()
            -- 已停用 reconcile：配置 NPC 只在【创建新世界】时由 SpawnWorldNPCs 生成一次，
            -- 之后任何时候都不再补号/对齐配置，彻底杜绝跨分片重复（详见 modinfo 角色开关说明）。
            -- ReconcileWorldNPCs()
            RelinkNPCs(player)
            DBG("════ RegisterPlayer 流程结束: 当前分片现存 npcfriend=%d ════",
                _CountLiveNPCs())
        end)
    end)

    if TheWorld:HasTag("forest") then
        player:DoTaskInTime(2, function()
            if player:IsValid() and TheWorld._npc_first_spawn then
                TheWorld._npc_first_spawn = nil
                local msg = NPC_SPEECH.WELCOME or "NPC: Hello friend, I'm waiting for you somewhere in the world!"
                TheNet:Announce(msg)
            end
        end)
    end
end

return CompanionSpawner
