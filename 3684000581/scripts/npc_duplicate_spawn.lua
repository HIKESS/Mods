-- scripts/npc_duplicate_spawn.lua
-- NPC 副本生成模块
--
-- 用途：在世界上已经按 NPC_CHARACTERS 配置生成完正版 NPC 之后，
-- 再额外生成一个"独立的同角色副本"。副本拥有：
--   * 独立 entity（GUID 不同）
--   * 独立 slot_index（>= DUPLICATE_SLOT_BASE，与配置 slot 永不冲突）
--   * 独立的 stategraph / brain / inventory / health / combat
--   * 与正版同套的初始装备（复用 companion_spawner.EquipNPCStartingItems）
--   * 自动被 DstAdmin 列表识别（只要带 npcfriend tag 即列出）
--   * 不被 ReconcileWorldNPCs / RelinkNPCs / disabled_map 接管
--     （reconcile/relink 只 `ipairs(NPC_CHARACTERS)`，自然忽略 >=10000 的 slot）
--
-- 默认行为：野生副本（无 owner、无 leader），用户需通过右键菜单或 DstAdmin
-- 点 Follow 才会把它招募给自己。指令分派靠 (owner+char+slot) 三元组定位，
-- 副本 slot 全局唯一，命令路由不会被混淆。
--
-- 公共 API：
--   M.SpawnDuplicate(char_name, opts) -> (npc, err)
--     opts.pos          = {x=, z=} | Vector3   显式坐标（最优先）
--     opts.near_player  = player_inst          在该玩家附近随机偏移（次优）
--     opts.find_walkable = true (默认)         用 FindWalkableOffset 防卡墙
--   M.AllocateSlot() -> number               分配下一个唯一副本 slot
--   M.IsDuplicateSlot(slot) -> boolean       slot 是否属于副本范围
--   M.IsValidCharacter(char) -> boolean      char 是否在 APPEARANCE 表中
--   M.GetSupportedCharacters() -> { char,... }   支持生成的角色名列表（已排序）
--   M.Init()                                 模块启动入口（触发计数器异步加载）
--
-- 持久化：
--   slot 计数器用 TheSim:SetPersistentString 落盘，
--   key 形如 "npcfriends_dup_slot_<session_identifier>"。
--   首次 SpawnDuplicate 时若计数器尚未异步加载完成，回退到内存默认值 +
--   实时扫描 Ents 取最大已用 slot，保证不会和已存在副本冲突。

local M = {}

local NPC_TUNING       = require("npc_tuning")
local CompanionSpawner = require("companion_spawner")
local npc_utils        = require("npc/npc_utils")

local APPEARANCE = npc_utils.APPEARANCE or {}
local DUPLICATE_SLOT_BASE = NPC_TUNING.DUPLICATE_SLOT_BASE or 10000

local _DEBUG = (NPC_TUNING.DEBUG_BEHAVIOR == true)

local function _log(fmt, ...)
    if not _DEBUG then return end
    print("[NPC_DUP] " .. string.format(fmt, ...))
end

-- ── 副本 slot 计数器（持久化） ────────────────────────────────
local _counter_loaded = false
local _counter_value  = DUPLICATE_SLOT_BASE
local _counter_load_callbacks = {}

local function _GetCounterKey()
    local session_id = _G.TheWorld and _G.TheWorld.meta and _G.TheWorld.meta.session_identifier
    if not session_id or session_id == "" then return nil end
    return "npcfriends_dup_slot_" .. tostring(session_id)
end

local function _SaveCounter()
    local key = _GetCounterKey()
    if not key or not _G.TheSim or not _G.TheSim.SetPersistentString then return end
    local ok, err = pcall(function()
        _G.TheSim:SetPersistentString(key, tostring(_counter_value), false)
    end)
    if not ok then
        print(string.format("[NPC_DUP] _SaveCounter 失败 key=%s err=%s",
            tostring(key), tostring(err)))
    end
end

local function _RunPendingCounterCallbacks()
    local cbs = _counter_load_callbacks
    _counter_load_callbacks = {}
    for _, cb in ipairs(cbs) do pcall(cb) end
end

local function _LoadCounter()
    if _counter_loaded then return end
    local key = _GetCounterKey()
    if not key or not _G.TheSim or not _G.TheSim.GetPersistentString then
        _counter_loaded = true
        _RunPendingCounterCallbacks()
        return
    end
    _G.TheSim:GetPersistentString(key, function(load_success, str)
        if load_success and type(str) == "string" and str ~= "" then
            local n = tonumber(str)
            if n and n >= DUPLICATE_SLOT_BASE then
                _counter_value = math.floor(n)
                _log("counter 加载: %d", _counter_value)
            end
        end
        _counter_loaded = true
        _RunPendingCounterCallbacks()
    end)
end

local function _EnsureCounterLoaded(callback)
    if _counter_loaded then
        if callback then pcall(callback) end
        return
    end
    if callback then table.insert(_counter_load_callbacks, callback) end
    _LoadCounter()
end

-- ── 角色名校验 ────────────────────────────────────────────────
function M.IsValidCharacter(char_name)
    return type(char_name) == "string"
        and char_name ~= ""
        and char_name ~= "npcfriend"          -- 默认占位，禁止直接生成
        and APPEARANCE[char_name] ~= nil
end

function M.GetSupportedCharacters()
    local list = {}
    for k, _ in pairs(APPEARANCE) do
        if k ~= "npcfriend" then
            table.insert(list, k)
        end
    end
    table.sort(list)
    return list
end

-- ── slot 分配 ─────────────────────────────────────────────────
function M.IsDuplicateSlot(slot)
    return type(slot) == "number" and slot >= DUPLICATE_SLOT_BASE
end

function M.AllocateSlot()
    _counter_value = _counter_value + 1
    if _counter_value < DUPLICATE_SLOT_BASE + 1 then
        _counter_value = DUPLICATE_SLOT_BASE + 1
    end

    -- 兜底：扫描现有副本 slot，处理"计数器异步加载尚未完成"的并发窗口
    -- 以及"老存档已有副本但本进程未加载计数器"的边界情况。
    local ents = _G.Ents or {}
    for _, ent in pairs(ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend")
            and type(ent.npc_slot_index) == "number"
            and ent.npc_slot_index >= _counter_value then
            _counter_value = ent.npc_slot_index + 1
        end
    end

    _SaveCounter()
    return _counter_value
end

-- ── 位置解析 ──────────────────────────────────────────────────
local function _GetPortalXZ()
    for _, ent in pairs(_G.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("multiplayer_portal") then
            local px, _, pz = ent.Transform:GetWorldPosition()
            return px, pz
        end
    end
    return 0, 0
end

local function _ResolveSpawnPos(opts)
    opts = opts or {}
    local find_walkable = opts.find_walkable
    if find_walkable == nil then find_walkable = true end

    local base_x, base_z
    if opts.pos then
        if opts.pos.x ~= nil and opts.pos.z ~= nil then
            base_x, base_z = opts.pos.x, opts.pos.z
        end
    elseif opts.near_player and opts.near_player.Transform then
        local px, _, pz = opts.near_player.Transform:GetWorldPosition()
        base_x, base_z = px, pz
    end

    if base_x == nil or base_z == nil then
        base_x, base_z = _GetPortalXZ()
    end

    if find_walkable and _G.FindWalkableOffset and _G.Vector3 then
        local angle = math.random() * 2 * math.pi
        local dist  = 2 + math.random() * 1.5
        local off   = _G.FindWalkableOffset(_G.Vector3(base_x, 0, base_z),
                        angle, dist, 8, false, true)
        if off then
            return base_x + off.x, base_z + off.z
        end
    end

    return base_x, base_z
end

-- ── 主入口：生成副本 NPC ──────────────────────────────────────
function M.SpawnDuplicate(char_name, opts)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        return nil, "must run on master sim"
    end
    if not M.IsValidCharacter(char_name) then
        return nil, "invalid character: " .. tostring(char_name)
    end

    -- 触发计数器加载（不阻塞，第一次调用通常拿到内存默认值 + Ents 扫描兜底）
    _EnsureCounterLoaded(nil)

    local npc = _G.SpawnPrefab("npcfriend")
    if not npc then
        return nil, "SpawnPrefab(npcfriend) failed"
    end

    local x, z = _ResolveSpawnPos(opts)
    npc.Transform:SetPosition(x or 0, 0, z or 0)

    -- 顺序与 companion_spawner.SpawnNPCAtSlot 保持一致：
    --   1) SetAppearance 设外观 + 角色属性（health/damage/range/...）
    --   2) 分配 slot（必须在 SetAppearance 之后，避免 npc_visibility_debug 误报变化）
    --   3) 派发初始装备 + 工具/护甲耐久 hook
    npc:SetAppearance(char_name)

    local slot = M.AllocateSlot()
    npc.npc_slot_index = slot
    if npc.npc_slot_index_net then
        npc.npc_slot_index_net:set(slot)
    end

    if CompanionSpawner.EquipNPCStartingItems then
        CompanionSpawner.EquipNPCStartingItems(npc, char_name)
    end

    _log("已生成 char=%s slot=%d GUID=%s pos=(%.1f,%.1f)",
        char_name, slot, tostring(npc.GUID), x or 0, z or 0)

    return npc, nil
end

-- ── 模块启动 ──────────────────────────────────────────────────
-- 由 modmain 在世界 ready 后调用一次，触发计数器异步加载。
function M.Init()
    if _G.TheWorld then
        _LoadCounter()
    end
end

return M
