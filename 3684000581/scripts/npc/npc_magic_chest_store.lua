-- scripts/npc/npc_magic_chest_store.lua
-- NPC 麦斯威尔专用魔术箱共享存储。
-- 同 shard 内使用隐藏 pocket container；跨 shard 用快照初始化 + 操作日志同步，避免并发覆盖。

local STORE_NAME = "npc_waxwell_magic"
local STORE_PREFAB = "npc_waxwell_magic_container"
local STORE_FILE = "npcfriends_waxwell_magic_chest_store"
local SNAPSHOT_RPC = "WaxwellMagicChestSync"
local REQUEST_RPC = "WaxwellMagicChestRequest"
local OP_RPC = "WaxwellMagicChestOp"

local Store = {}
local MOD_ENV = nil
local LOADED_LOCAL = false
local LAST_SAVED_AT = 0
local OP_SEQ = 0
local APPLIED_OPS = {}
local APPLIED_OP_ORDER = {}
local MAX_APPLIED_OPS = 128
local PENDING_RECORDS = {}
local SLOT_FINGERPRINTS = {}

local function _ShardId()
    return tostring(TheShard and TheShard:GetShardId() or "unknown")
end

local function _GetMaster()
    return TheWorld and TheWorld.GetPocketDimensionContainer
        and TheWorld:GetPocketDimensionContainer(STORE_NAME)
        or nil
end

local function _ClearContainer(cont)
    if not cont then return end
    for i = cont:GetNumSlots(), 1, -1 do
        local item = cont:GetItemInSlot(i)
        if item then
            local taken = cont:RemoveItemBySlot(i)
            if taken and taken:IsValid() then
                taken:Remove()
            end
        end
    end
end

local function _ItemStackSize(item)
    return item and item.components and item.components.stackable
        and item.components.stackable:StackSize()
        or 1
end

local function _RecordStackSize(record)
    return record
        and record.data
        and record.data.stackable
        and tonumber(record.data.stackable.stack)
        or 1
end

local function _SetRecordStackSize(record, count)
    if not record then return record end
    count = math.max(1, math.floor(tonumber(count) or 1))
    record.data = record.data or {}
    if count > 1 then
        record.data.stackable = record.data.stackable or {}
        record.data.stackable.stack = count
    elseif record.data.stackable ~= nil then
        record.data.stackable.stack = nil
        if next(record.data.stackable) == nil then
            record.data.stackable = nil
        end
    end
    return record
end

local function _RecordFingerprint(record)
    if not record then return "empty" end
    return tostring(record.prefab or "")
        .. "|" .. tostring(record.skinname or "")
        .. "|" .. tostring(_RecordStackSize(record))
end

local function _ItemFingerprint(item)
    if not (item and item:IsValid()) then return "empty" end
    return tostring(item.prefab or "")
        .. "|" .. tostring(item.skinname or "")
        .. "|" .. tostring(_ItemStackSize(item))
end

local function _SlotFingerprint(cont, slot)
    return _ItemFingerprint(cont and cont:GetItemInSlot(slot) or nil)
end

local function _CopyRecordWithStack(item, count)
    if not (item and item:IsValid() and item.GetSaveRecord) then return nil end
    local record = item:GetSaveRecord()
    record.x, record.y, record.z = nil, nil, nil
    record.rx, record.ry, record.rz, record.puid = nil, nil, nil, nil
    return _SetRecordStackSize(record, count or _ItemStackSize(item))
end

local function _NewOpId()
    OP_SEQ = OP_SEQ + 1
    return _ShardId() .. ":" .. tostring(math.floor((GetTime() or 0) * 1000)) .. ":" .. tostring(OP_SEQ)
end

local function _RememberOp(opid)
    if not opid or APPLIED_OPS[opid] then
        return false
    end
    APPLIED_OPS[opid] = true
    table.insert(APPLIED_OP_ORDER, opid)
    while #APPLIED_OP_ORDER > MAX_APPLIED_OPS do
        local old = table.remove(APPLIED_OP_ORDER, 1)
        APPLIED_OPS[old] = nil
    end
    return true
end

local function _Encode(data)
    return DataDumper(data or {}, nil, false)
end

local function _Decode(str)
    if type(str) ~= "string" or str == "" then
        return nil
    end
    local ok, data = RunInSandboxSafe(str)
    return ok and data or nil
end

local function _UpdateSlotFingerprints(cont)
    SLOT_FINGERPRINTS = {}
    if not cont then return end
    for slot = 1, cont:GetNumSlots() do
        SLOT_FINGERPRINTS[slot] = _SlotFingerprint(cont, slot)
    end
end

local function _AttachStackListener(inst, item)
    if not (inst and item and item:IsValid() and item.components and item.components.stackable) then return end
    if item._npc_waxwell_magic_stack_listener ~= nil then return end
    item._npc_waxwell_magic_stack_listener = function(stack_item, data)
        Store.OnStackSizeChanged(inst, stack_item, data)
    end
    inst:ListenForEvent("stacksizechange", item._npc_waxwell_magic_stack_listener, item)
end

local function _AttachAllStackListeners(inst)
    local cont = inst and inst.components and inst.components.container or nil
    if not cont then return end
    for slot = 1, cont:GetNumSlots() do
        _AttachStackListener(inst, cont:GetItemInSlot(slot))
    end
end

local function _SendShardPayload(rpc_name, payload)
    local send = MOD_ENV and MOD_ENV.SendModRPCToShard or SendModRPCToShard
    local getrpc = MOD_ENV and MOD_ENV.GetShardModRPC or GetShardModRPC
    if not (TheWorld and TheWorld.ismastersim and send and getrpc) then return end
    send(getrpc("NPCFriends", rpc_name), nil, _Encode(payload))
end

local function _MakeItemFromRecord(record)
    if not record then return nil end
    return SpawnSaveRecord(record, {})
end

local function _TryGiveRecord(cont, record, preferred_slot)
    if not (cont and record) then return false end
    local item = _MakeItemFromRecord(record)
    if not item then return false end
    local ok = false
    if preferred_slot ~= nil then
        ok = cont:GiveItem(item, preferred_slot, nil, false)
    end
    if not ok then
        ok = cont:GiveItem(item, nil, nil, false)
    end
    if not ok and item:IsValid() then
        item:Remove()
    end
    return ok
end

local function _FlushPending(cont)
    if not cont or #PENDING_RECORDS == 0 then return end
    local remaining = {}
    for _, record in ipairs(PENDING_RECORDS) do
        if not _TryGiveRecord(cont, record, nil) then
            table.insert(remaining, record)
        end
    end
    PENDING_RECORDS = remaining
end

local function _QueuePending(record)
    if record ~= nil then
        table.insert(PENDING_RECORDS, record)
    end
end

local function _MergePending(records)
    if type(records) ~= "table" then return end
    for _, record in ipairs(records) do
        _QueuePending(record)
    end
end

local function _SaveAndRefresh(cont)
    local inst = cont and cont.inst or nil
    if inst then
        inst._npc_magic_chest_applying_remote = true
    end
    _FlushPending(cont)
    if inst then
        inst._npc_magic_chest_applying_remote = false
    end
    _UpdateSlotFingerprints(cont)
    Store.SaveLocal()
end

local function _BroadcastOp(op)
    if not op then return end
    op.version = 1
    op.id = op.id or _NewOpId()
    op.shard = _ShardId()
    op.time = GetTime and GetTime() or 0
    _RememberOp(op.id)
    _SendShardPayload(OP_RPC, op)
end

local function _SlotMatches(cont, slot, expected_fp)
    if expected_fp == nil then return true end
    return _SlotFingerprint(cont, slot) == expected_fp
end

local function _RemoveMatchingSlot(cont, slot, expected_fp)
    if not (cont and slot and _SlotMatches(cont, slot, expected_fp)) then
        return false
    end
    local item = cont:RemoveItemBySlot(slot)
    if item and item:IsValid() then
        item:Remove()
        return true
    end
    return false
end

local function _RemoveStackCount(cont, slot, prefab, count, expected_fp)
    if not (cont and slot and prefab and count and count > 0) then
        return false
    end
    if expected_fp ~= nil and not _SlotMatches(cont, slot, expected_fp) then
        return false
    end
    local item = cont:GetItemInSlot(slot)
    if item == nil or item.prefab ~= prefab then
        return false
    end
    if item.components.stackable ~= nil and item.components.stackable:StackSize() > count then
        local taken = item.components.stackable:Get(count)
        if taken and taken:IsValid() then
            taken:Remove()
        end
        return true
    end
    local taken = cont:RemoveItemBySlot(slot)
    if taken and taken:IsValid() then
        taken:Remove()
        return true
    end
    return false
end

local function _ApplyAdd(cont, op)
    if not (cont and op and op.record) then return false end
    if op.before_fp ~= nil and not _SlotMatches(cont, op.slot, op.before_fp) then
        if not _TryGiveRecord(cont, op.record, nil) then
            _QueuePending(op.record)
        end
        return true
    end
    if not _TryGiveRecord(cont, op.record, op.slot) then
        _QueuePending(op.record)
    end
    return true
end

local function _ApplyRemoteOp(op)
    if not (op and op.id and op.shard ~= _ShardId()) then return end
    if not _RememberOp(op.id) then return end
    local master = Store.EnsureWorldContainer()
    local cont = master and master.components and master.components.container or nil
    if not cont then return end

    master._npc_magic_chest_applying_remote = true
    if op.type == "add" then
        _ApplyAdd(cont, op)
    elseif op.type == "remove" then
        _RemoveMatchingSlot(cont, op.slot, op.before_fp)
    elseif op.type == "stack_remove" then
        _RemoveStackCount(cont, op.slot, op.prefab, tonumber(op.count) or 0, op.before_fp)
    end
    master._npc_magic_chest_applying_remote = false
    _SaveAndRefresh(cont)
end

function Store.EnsureWorldContainer()
    if not (TheWorld and TheWorld.ismastersim) then return nil end
    local existing = _GetMaster()
    if existing and existing:IsValid() then
        return existing
    end
    local inst = SpawnPrefab(STORE_PREFAB)
    if inst and TheWorld.SetPocketDimensionContainer then
        TheWorld:SetPocketDimensionContainer(STORE_NAME, inst)
    end
    return inst
end

function Store.GetWorldContainer()
    return Store.EnsureWorldContainer()
end

function Store.ApplyData(data)
    local master = Store.EnsureWorldContainer()
    local cont = master and master.components and master.components.container or nil
    if not cont or type(data) ~= "table" then
        return false
    end
    if master then
        master._npc_magic_chest_applying_remote = true
    end
    _ClearContainer(cont)
    cont:OnLoad(data, {})
    if master then
        master._npc_magic_chest_applying_remote = false
    end
    _AttachAllStackListeners(master)
    if master then
        master._npc_magic_chest_applying_remote = true
    end
    _FlushPending(cont)
    if master then
        master._npc_magic_chest_applying_remote = false
    end
    _UpdateSlotFingerprints(cont)
    return true
end

function Store.GetData()
    local master = Store.EnsureWorldContainer()
    local cont = master and master.components and master.components.container or nil
    if not cont then
        return { items = {} }
    end
    local data = cont:OnSave()
    return data or { items = {} }
end

function Store.SaveLocal()
    if not (TheWorld and TheWorld.ismastersim and TheSim) then return end
    LAST_SAVED_AT = math.max(os.time(), LAST_SAVED_AT)
    local payload = {
        version = 1,
        shard = _ShardId(),
        saved_at = LAST_SAVED_AT,
        data = Store.GetData(),
        pending = PENDING_RECORDS,
    }
    TheSim:SetPersistentString(STORE_FILE, _Encode(payload), false)
end

function Store.LoadLocal(callback)
    if not (TheWorld and TheWorld.ismastersim and TheSim) then
        if callback then callback(false) end
        return
    end
    TheSim:GetPersistentString(STORE_FILE, function(load_success, str)
        if load_success then
            local payload = _Decode(str)
            if payload and payload.data then
                LAST_SAVED_AT = tonumber(payload.saved_at) or LAST_SAVED_AT
                PENDING_RECORDS = type(payload.pending) == "table" and payload.pending or {}
                Store.ApplyData(payload.data)
            end
        end
        LOADED_LOCAL = true
        if callback then callback(load_success == true) end
    end)
end

function Store.Broadcast()
    local saved_at = math.max(os.time(), LAST_SAVED_AT)
    local payload = {
        version = 1,
        shard = _ShardId(),
        saved_at = saved_at,
        data = Store.GetData(),
        pending = PENDING_RECORDS,
    }
    _SendShardPayload(SNAPSHOT_RPC, payload)
end

function Store.SaveAndBroadcast()
    Store.SaveLocal()
end

function Store.RequestPeerSync()
    local send = MOD_ENV and MOD_ENV.SendModRPCToShard or SendModRPCToShard
    local getrpc = MOD_ENV and MOD_ENV.GetShardModRPC or GetShardModRPC
    if not (TheWorld and TheWorld.ismastersim and send and getrpc) then return end
    send(getrpc("NPCFriends", REQUEST_RPC), nil, _ShardId())
end

function Store.ReceiveSync(payload_str)
    local payload = _Decode(payload_str)
    if not payload or payload.shard == _ShardId() or not payload.data then
        return
    end
    local saved_at = tonumber(payload.saved_at) or 0
    if saved_at < LAST_SAVED_AT then
        return
    end
    LAST_SAVED_AT = saved_at
    _MergePending(payload.pending)
    Store.ApplyData(payload.data)
    Store.SaveLocal()
end

function Store.ReceiveOp(payload_str)
    _ApplyRemoteOp(_Decode(payload_str))
end

function Store.ReceiveRequest(source_shard)
    if not source_shard or source_shard == "" or source_shard == _ShardId() then
        return
    end
    if not LOADED_LOCAL then
        Store.LoadLocal(function()
            Store.Broadcast()
        end)
        return
    end
    Store.Broadcast()
end

function Store.RegisterShardRPC(env)
    MOD_ENV = env or MOD_ENV
    local add = MOD_ENV and MOD_ENV.AddShardModRPCHandler or AddShardModRPCHandler
    if add == nil then return end
    add("NPCFriends", SNAPSHOT_RPC, function(_, payload)
        Store.ReceiveSync(payload)
    end)
    add("NPCFriends", REQUEST_RPC, function(shard_id, _)
        Store.ReceiveRequest(tostring(shard_id or ""))
    end)
    add("NPCFriends", OP_RPC, function(_, payload)
        Store.ReceiveOp(payload)
    end)
end

function Store.OnItemGet(inst, data)
    if inst == nil or inst._npc_magic_chest_applying_remote then return end
    local cont = inst.components and inst.components.container or nil
    if not (cont and data and data.item and data.slot) then return end
    _AttachStackListener(inst, data.item)
    local before_fp = SLOT_FINGERPRINTS[data.slot] or "empty"
    local record = _CopyRecordWithStack(data.item)
    if record == nil then return end
    _UpdateSlotFingerprints(cont)
    _BroadcastOp({
        type = "add",
        slot = data.slot,
        before_fp = before_fp,
        after_fp = SLOT_FINGERPRINTS[data.slot],
        record = record,
    })
    _SaveAndRefresh(cont)
end

function Store.OnItemLose(inst, data)
    if inst == nil or inst._npc_magic_chest_applying_remote then return end
    local cont = inst.components and inst.components.container or nil
    if not (cont and data and data.slot) then return end
    local before_fp = SLOT_FINGERPRINTS[data.slot]
    _UpdateSlotFingerprints(cont)
    _BroadcastOp({
        type = "remove",
        slot = data.slot,
        before_fp = before_fp,
        after_fp = SLOT_FINGERPRINTS[data.slot] or "empty",
    })
    _SaveAndRefresh(cont)
end

function Store.OnStackSizeChanged(inst, item, data)
    if inst == nil or inst._npc_magic_chest_applying_remote then return end
    local cont = inst.components and inst.components.container or nil
    local slot = cont and cont:GetItemSlot(item) or nil
    if not (cont and slot and item and data) then return end
    local old_size = tonumber(data.oldstacksize) or _ItemStackSize(item)
    local new_size = tonumber(data.stacksize) or _ItemStackSize(item)
    local delta = new_size - old_size
    if delta == 0 then return end
    local before_fp = tostring(item.prefab or "") .. "|" .. tostring(item.skinname or "") .. "|" .. tostring(old_size)
    _UpdateSlotFingerprints(cont)
    if delta > 0 then
        local record = _CopyRecordWithStack(item, delta)
        if record == nil then return end
        _BroadcastOp({
            type = "add",
            slot = slot,
            before_fp = before_fp,
            after_fp = SLOT_FINGERPRINTS[slot],
            record = record,
        })
    else
        _BroadcastOp({
            type = "stack_remove",
            slot = slot,
            before_fp = before_fp,
            after_fp = SLOT_FINGERPRINTS[slot],
            prefab = item.prefab,
            count = -delta,
        })
    end
    _SaveAndRefresh(cont)
end

function Store.RegisterContainer(inst)
    if not (inst and inst.components and inst.components.container) then return end
    inst:ListenForEvent("itemget", Store.OnItemGet)
    inst:ListenForEvent("itemlose", Store.OnItemLose)
    _AttachAllStackListeners(inst)
    _UpdateSlotFingerprints(inst.components.container)
end

Store.STORE_NAME = STORE_NAME
Store.STORE_PREFAB = STORE_PREFAB

return Store
