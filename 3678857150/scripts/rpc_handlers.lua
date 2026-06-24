-- ========== RPC 通信（服务端 <-> 客户端）==========
local _rawget = GLOBAL.rawget or rawget
local _rawset = GLOBAL.rawset or rawset
local _OFFLINE_EXPECT_REV = {}
local _DSTADMIN_LAST_FORCED_SAVE_AT = 0
-- 强制保存策略：
-- off  : 默认关闭，完全依赖游戏自动保存
-- on   : 启用跨 shard 离线写操作后的双端触发保存（带节流）
local _DSTADMIN_OFFLINE_FORCE_SAVE_MODE = tostring(_rawget(GLOBAL, "DSTADMIN_OFFLINE_FORCE_SAVE_MODE") or "off")

local function _BuildTargetInfo(uid, name, rev)
    if rev ~= nil then
        return tostring(uid or "") .. "|" .. tostring(name or "???") .. "|" .. tostring(rev)
    end
    return tostring(uid or "") .. "|" .. tostring(name or "???")
end
local _OFFLINE_REMOTE_REQ_AT = {}
local _ACK_RETRY_PENDING = {}
local _ACK_RETRY_SEQ = 0
local _ACK_RETRY_TASK = nil
local _ACK_RETRY_SEEN = {}
local _ACK_RETRY_MAX_TRIES = 6
local _ACK_RETRY_INTERVAL = 0.6
local _ACK_RETRY_SEEN_TTL = 180
local Widget = GLOBAL.require("widgets/widget")

local function _Dbg(msg)
    if _rawget(GLOBAL, "DSTADMIN_OFFLINE_DEBUG") == true then
        print("[DstAdminRPC] " .. tostring(msg))
    end
end

local function _AttachHudWidgetToTopRoot(hud, widget, x, y)
    if hud == nil or widget == nil then
        return nil
    end
    local root = hud.controls and hud.controls.containerroot or nil
    if root == nil then
        return nil
    end
    local w = root:AddChild(widget)
    w:SetPosition(x or 300, y or 100)
    root:MoveToFront()
    w:MoveToFront()
    return root
end

local function _IsAdmin(userid)
    for _, c in ipairs(GLOBAL.TheNet:GetClientTable() or {}) do
        if c.userid == userid and c.admin then return true end
    end
    return false
end

local function _IsOnlineByUserid(userid)
    if not userid or userid == "" then return false end
    local fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_IsOnline")
    return fn and fn(userid) or false
end

local function _GetOfflineRev(userid)
    local fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_GetRev")
    if not fn then return nil end
    return fn(userid)
end

local function _NeedOfflineShardRefresh(target_userid, items_str)
    if not target_userid or target_userid == "" then return false end
    if type(items_str) ~= "string" or items_str == "" then return true end
    local snap_fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_GetSnapshot")
    if not snap_fn then return false end
    local snap = snap_fn(target_userid)
    if not snap then return false end
    local last_shard = tostring(snap.last_shard or "")
    local ok, sid = GLOBAL.pcall(function()
        return GLOBAL.TheShard and GLOBAL.TheShard:GetShardId()
    end)
    local local_shard = (ok and sid ~= nil) and tostring(sid) or "unknown"
    if last_shard ~= "" and local_shard ~= "" and last_shard ~= local_shard then
        _Dbg("need_remote uid=" .. tostring(target_userid)
            .. " last_shard=" .. tostring(last_shard)
            .. " local_shard=" .. tostring(local_shard)
            .. " items_len=" .. tostring(#tostring(items_str or "")))
        return true
    end
    return false
end

local function _GetOfflineOwnerShard(target_userid)
    local snap_fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_GetSnapshot")
    if not snap_fn then return nil end
    local snap = snap_fn(target_userid)
    if not snap then return nil end
    local sid = tostring(snap.last_shard or "")
    if sid == "" then return nil end
    return sid
end

local function _ShouldRouteOfflineOpToOwnerShard(target_userid)
    local owner_sid = _GetOfflineOwnerShard(target_userid)
    if not owner_sid or owner_sid == "" then return true, nil end
    local ok, sid = GLOBAL.pcall(function()
        return GLOBAL.TheShard and GLOBAL.TheShard:GetShardId()
    end)
    local local_sid = (ok and sid ~= nil) and tostring(sid) or "unknown"
    return owner_sid ~= local_sid, owner_sid
end

local function _ShouldSendOfflineRemoteReq(requesting_userid, target_userid, cooldown)
    requesting_userid = tostring(requesting_userid or "")
    target_userid = tostring(target_userid or "")
    if requesting_userid == "" or target_userid == "" then return false end
    local now = (GLOBAL.GetTime and GLOBAL.GetTime()) or 0
    local key = requesting_userid .. "|" .. target_userid
    local last = _OFFLINE_REMOTE_REQ_AT[key] or 0
    if now - last < (cooldown or 0.6) then
        return false
    end
    _OFFLINE_REMOTE_REQ_AT[key] = now
    return true
end

local function _BumpOfflineRemoteReqCooldown(requesting_userid, target_userid, seconds)
    requesting_userid = tostring(requesting_userid or "")
    target_userid = tostring(target_userid or "")
    if requesting_userid == "" or target_userid == "" then return end
    local now = (GLOBAL.GetTime and GLOBAL.GetTime()) or 0
    local key = requesting_userid .. "|" .. target_userid
    _OFFLINE_REMOTE_REQ_AT[key] = now + (seconds or 0.8)
end

local function _IsInventoryPayloadEmpty(items_str)
    if type(items_str) ~= "string" or items_str == "" then return true end
    local cap, rest = items_str:match("^CAP:([^|]*)|(.*)$")
    if cap then
        return (rest == nil or rest == "")
    end
    return (items_str == "")
end

local function _SetExpectedRev(admin_userid, target_userid, rev)
    if not admin_userid or not target_userid then return end
    local admin_map = _OFFLINE_EXPECT_REV[admin_userid]
    if not admin_map then
        admin_map = {}
        _OFFLINE_EXPECT_REV[admin_userid] = admin_map
    end
    admin_map[target_userid] = GLOBAL.tonumber(rev) or nil
end

local function _GetExpectedRev(admin_userid, target_userid)
    local admin_map = _OFFLINE_EXPECT_REV[admin_userid]
    return admin_map and admin_map[target_userid] or nil
end

local function _SendOfflineInventoryToClient(admin_userid, target_userid, target_name, items_str, rev)
    if not admin_userid or not target_userid then return end
    if type(items_str) ~= "string" or items_str == "" then return end
    local r = GLOBAL.tonumber(rev)
    if r == nil then
        r = _GetOfflineRev(target_userid)
    end
    SendModRPCToClient(
        GetClientModRPC("DstAdmin", "ReceiveInventory"),
        admin_userid,
        _BuildTargetInfo(target_userid, target_name or "???", r),
        items_str
    )
end

local _MAX_STACK_CACHE = {}
local function _GetPrefabMaxStack(prefab)
    if not prefab or prefab == "" then return 1 end
    if _MAX_STACK_CACHE[prefab] ~= nil then
        return _MAX_STACK_CACHE[prefab]
    end
    local maxsize = 1
    GLOBAL.pcall(function()
        local it = GLOBAL.SpawnPrefab(prefab)
        if it then
            if it.components and it.components.stackable then
                maxsize = it.components.stackable.maxsize or 40
            end
            it:Remove()
        end
    end)
    if maxsize < 1 then maxsize = 1 end
    _MAX_STACK_CACHE[prefab] = maxsize
    return maxsize
end

local function _CountAcceptableToPlayer(player, prefab, desired)
    if not player or not player.components or not player.components.inventory then return 0 end
    local want = GLOBAL.tonumber(desired) or 0
    if not prefab or prefab == "" or want <= 0 then return 0 end
    local inv = player.components.inventory
    local maxsize = _GetPrefabMaxStack(prefab)
    local cap = 0

    for i = 1, (inv.maxslots or 0) do
        local item = inv.itemslots and inv.itemslots[i] or nil
        if item == nil then
            cap = cap + maxsize
        elseif item.prefab == prefab and item.components and item.components.stackable then
            cap = cap + math.max(0, maxsize - (item.components.stackable:StackSize() or 1))
        end
        if cap >= want then return want end
    end

    local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
    if ok and overflow then
        for i = 1, (overflow.numslots or 0) do
            local item = overflow.slots and overflow.slots[i] or nil
            if item == nil then
                cap = cap + maxsize
            elseif item.prefab == prefab and item.components and item.components.stackable then
                cap = cap + math.max(0, maxsize - (item.components.stackable:StackSize() or 1))
            end
            if cap >= want then return want end
        end
    end
    return math.max(0, cap)
end

local function _CountAcceptableToInventoryOwner(owner, item, desired)
    if not owner or not item or not owner.components or not owner.components.inventory then return 0 end
    local inv = owner.components.inventory
    local want = GLOBAL.tonumber(desired) or 0
    if want <= 0 then return 0 end

    local ok, accepted = GLOBAL.pcall(function()
        return inv:CanAcceptCount(item, want)
    end)
    if ok and accepted ~= nil then
        return math.max(0, math.min(want, GLOBAL.tonumber(accepted) or 0))
    end

    local prefab = item.prefab
    local skinname = item.skinname
    local maxsize = 1
    if item.components and item.components.stackable then
        maxsize = item.components.stackable.maxsize or 40
    end

    local cap = 0
    for i = 1, (inv.maxslots or 0) do
        local slot_item = inv.itemslots and inv.itemslots[i] or nil
        if slot_item == nil then
            local can_take = true
            GLOBAL.pcall(function()
                can_take = inv:CanTakeItemInSlot(item, i)
            end)
            if can_take then
                cap = cap + ((inv.acceptsstacks or want <= 1) and maxsize or 1)
            end
        elseif slot_item.prefab == prefab
            and slot_item.skinname == skinname
            and slot_item.components
            and slot_item.components.stackable then
            cap = cap + math.max(0, (slot_item.components.stackable.maxsize or maxsize) - (slot_item.components.stackable:StackSize() or 1))
        end
        if cap >= want then return want end
    end
    return math.max(0, math.min(want, cap))
end

local function _PeekOnlineTargetItem(target, slot_type, slot_key)
    if not target or not target.components or not target.components.inventory then return nil, 0, true end
    local inv = target.components.inventory
    local item = nil
    if slot_type == "I" then
        local sn = GLOBAL.tonumber(slot_key)
        if sn then item = inv.itemslots and inv.itemslots[sn] or nil end
    elseif slot_type == "B" then
        local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
        if ok and overflow then
            local sn = GLOBAL.tonumber(slot_key)
            if sn then item = overflow.slots and overflow.slots[sn] or nil end
        end
    else
        return nil, 0, true
    end
    if not item then return nil, 0, true end
    local c = 1
    if item.components and item.components.stackable then
        c = item.components.stackable:StackSize() or 1
    end
    local untakeable = IsUntakeableItem(item)
    return item.prefab, c, untakeable
end

local function _PeekOfflineSnapshotItem(userid, slot_type, slot_key)
    local get_inv = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_GetInventory")
    if not get_inv then return nil, 0, true end
    local _, items_str = get_inv(userid)
    if type(items_str) ~= "string" or items_str == "" then return nil, 0, true end
    local _, rest = items_str:match("^CAP:([^|]*)|(.*)$")
    rest = rest or items_str
    for entry in rest:gmatch("[^,]+") do
        local tag, sk, prefab, count, uflag = entry:match("^(.):([^:]+):([^:]+):(%d+):?(%d?):?.*$")
        if tag == slot_type and sk == tostring(slot_key) then
            return prefab, GLOBAL.tonumber(count) or 1, (uflag == "1")
        end
    end
    return nil, 0, true
end

local function _GetLocalShardId()
    local ok, sid = GLOBAL.pcall(function()
        return GLOBAL.TheShard and GLOBAL.TheShard:GetShardId()
    end)
    return (ok and sid ~= nil) and tostring(sid) or "unknown"
end

local function _NowSec()
    return (GLOBAL.GetTime and GLOBAL.GetTime()) or 0
end

local function _TrimAckSeen(now)
    now = now or _NowSec()
    for k, ts in pairs(_ACK_RETRY_SEEN) do
        if (now - (GLOBAL.tonumber(ts) or 0)) > _ACK_RETRY_SEEN_TTL then
            _ACK_RETRY_SEEN[k] = nil
        end
    end
end

local function _MakeAckReqId(tag)
    _ACK_RETRY_SEQ = (_ACK_RETRY_SEQ or 0) + 1
    return tostring(tag or "op") .. "-" .. tostring(_GetLocalShardId()) .. "-" .. tostring(_ACK_RETRY_SEQ) .. "-" .. tostring(math.floor(_NowSec() * 1000))
end

local function _EncodeReliablePayload(req_id, payload_legacy)
    return table.concat({
        "ACK1",
        tostring(req_id or ""),
        tostring(payload_legacy or ""),
    }, "|")
end

local function _DecodeReliablePayload(s)
    s = tostring(s or "")
    local req_id, payload = s:match("^ACK1|([^|]+)|(.+)$")
    if req_id and payload then
        return req_id, payload, true
    end
    return nil, s, false
end

local function _AckSeenKey(rpc_name, source_sid, req_id)
    return table.concat({
        tostring(rpc_name or ""),
        tostring(source_sid or ""),
        tostring(req_id or ""),
    }, "|")
end

local function _HasSeenReliableReq(rpc_name, source_sid, req_id)
    if not req_id or req_id == "" then return false end
    local key = _AckSeenKey(rpc_name, source_sid, req_id)
    return _ACK_RETRY_SEEN[key] ~= nil
end

local function _MarkSeenReliableReq(rpc_name, source_sid, req_id)
    if not req_id or req_id == "" then return end
    local key = _AckSeenKey(rpc_name, source_sid, req_id)
    _ACK_RETRY_SEEN[key] = _NowSec()
end

local function _SendOfflineOpAck(target_shard, req_id)
    target_shard = tostring(target_shard or "")
    if target_shard == "" then return end
    local payload = table.concat({
        target_shard,
        _GetLocalShardId(),
        tostring(req_id or ""),
    }, "|")
    GLOBAL.pcall(function()
        SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardOfflineOpAck"), nil, payload)
    end)
end

local function _EnsureAckRetryTask()
    if _ACK_RETRY_TASK ~= nil then return end
    if not GLOBAL.TheWorld then return end
    _ACK_RETRY_TASK = GLOBAL.TheWorld:DoPeriodicTask(0.5, function()
        local now = _NowSec()
        _TrimAckSeen(now)
        for req_id, rec in pairs(_ACK_RETRY_PENDING) do
            if type(rec) ~= "table" then
                _ACK_RETRY_PENDING[req_id] = nil
            elseif now >= (GLOBAL.tonumber(rec.next_retry_at) or 0) then
                local tries = (GLOBAL.tonumber(rec.tries) or 0)
                if tries >= (_ACK_RETRY_MAX_TRIES or 6) then
                    _Dbg("ack_retry giveup rpc=" .. tostring(rec.rpc_name)
                        .. " req=" .. tostring(req_id)
                        .. " target=" .. tostring(rec.target_shard)
                        .. " tries=" .. tostring(tries))
                    _ACK_RETRY_PENDING[req_id] = nil
                else
                    rec.tries = tries + 1
                    rec.next_retry_at = now + (_ACK_RETRY_INTERVAL or 0.6)
                    GLOBAL.pcall(function()
                        SendModRPCToShard(GetShardModRPC("DstAdmin", tostring(rec.rpc_name or "")), nil, tostring(rec.payload or ""))
                    end)
                    _Dbg("ack_retry resend rpc=" .. tostring(rec.rpc_name)
                        .. " req=" .. tostring(req_id)
                        .. " try=" .. tostring(rec.tries)
                        .. " target=" .. tostring(rec.target_shard))
                end
            end
        end
    end)
end

local function _SendReliableOfflineRPC(rpc_name, target_shard, legacy_payload)
    rpc_name = tostring(rpc_name or "")
    target_shard = tostring(target_shard or "")
    legacy_payload = tostring(legacy_payload or "")
    if rpc_name == "" or target_shard == "" or legacy_payload == "" then return false end
    local req_id = _MakeAckReqId(rpc_name)
    local payload = _EncodeReliablePayload(req_id, legacy_payload)
    _ACK_RETRY_PENDING[req_id] = {
        rpc_name = rpc_name,
        target_shard = target_shard,
        payload = payload,
        tries = 1,
        next_retry_at = _NowSec() + (_ACK_RETRY_INTERVAL or 0.6),
    }
    _EnsureAckRetryTask()
    GLOBAL.pcall(function()
        SendModRPCToShard(GetShardModRPC("DstAdmin", rpc_name), nil, payload)
    end)
    _Dbg("ack_retry send rpc=" .. tostring(rpc_name)
        .. " req=" .. tostring(req_id)
        .. " target=" .. tostring(target_shard))
    return true
end

local function _ForceLocalSave(reason)
    local now = (GLOBAL.GetTime and GLOBAL.GetTime()) or 0
    if now - (_DSTADMIN_LAST_FORCED_SAVE_AT or 0) < 1.0 then
        return
    end
    _DSTADMIN_LAST_FORCED_SAVE_AT = now
    if GLOBAL.TheWorld then
        GLOBAL.pcall(function()
            GLOBAL.TheWorld:PushEvent("ms_save")
        end)
        _Dbg("force_save local sid=" .. tostring(_GetLocalShardId()) .. " reason=" .. tostring(reason or ""))
    end
end

local function _NotifyShardForceSave(peer_shard, reason)
    peer_shard = tostring(peer_shard or "")
    if peer_shard == "" or peer_shard == _GetLocalShardId() then
        return
    end
    local payload = table.concat({
        peer_shard,
        _GetLocalShardId(),
        tostring(reason or ""),
    }, "|")
    GLOBAL.pcall(function()
        -- 广播并在接收端按目标 shard 过滤，兼容部分环境的定向发送限制
        SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestForceSave"), nil, payload)
    end)
end

local function _ForceSaveBothSides(peer_shard, reason)
    if _DSTADMIN_OFFLINE_FORCE_SAVE_MODE ~= "on" then
        return
    end
    _ForceLocalSave(reason)
    _NotifyShardForceSave(peer_shard, reason)
end

local function _MirrorOfflinePending(userid, give_prefab, give_count, take_prefab, take_count, admin_userid)
    local uid = tostring(userid or "")
    if uid == "" then return end
    local src = _GetLocalShardId()
    local gp = tostring(give_prefab or "")
    local gc = tostring(GLOBAL.tonumber(give_count) or 0)
    local tp = tostring(take_prefab or "")
    local tc = tostring(GLOBAL.tonumber(take_count) or 0)
    local ad = tostring(admin_userid or "")
    local data = src .. "|" .. uid .. "|" .. gp .. "|" .. gc .. "|" .. tp .. "|" .. tc .. "|" .. ad
    GLOBAL.pcall(function()
        SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardMirrorOfflinePending"), nil, data)
    end)
end

local function _SyncOfflineSnapshotToShards(userid)
    local build_fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_BuildSyncPayload")
    if not build_fn then return end
    local payload = build_fn(userid)
    if not payload or payload == "" then return end
    GLOBAL.pcall(function()
        SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardSyncOfflineSnapshot"), nil, payload)
    end)
end
_rawset(GLOBAL, "DSTADMIN_SYNC_OFFLINE_SNAPSHOT_TO_SHARDS", _SyncOfflineSnapshotToShards)

local function _RequestOfflineInventoryFromShards(admin_userid, target_userid)
    local data_off = tostring(admin_userid or "") .. "|" .. tostring(target_userid or "")
    GLOBAL.pcall(function()
        SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestOfflineInventory"), nil, data_off)
    end)
end

local function _SendOnlineInventoryWithDelay(requesting_userid, target_userid, target_name, target_inst, delay)
    if not target_inst then return end
    local d = GLOBAL.tonumber(delay) or 0.08
    GLOBAL.TheWorld:DoTaskInTime(d, function()
        if not target_inst or not target_inst.IsValid or not target_inst:IsValid() then return end
        local items_str = CollectInventory(target_inst)
        SendModRPCToClient(
            GetClientModRPC("DstAdmin", "ReceiveInventory"),
            requesting_userid,
            tostring(target_userid or "") .. "|" .. tostring(target_name or "???"),
            items_str
        )
    end)
end

-- 服务端处理：管理员请求查看某玩家物品
AddModRPCHandler("DstAdmin", "RequestInventory", function(player, target_userid)
    if not player or type(target_userid) ~= "string" then return end
    local is_admin = _IsAdmin(player.userid)
    if not is_admin and not DSTADMIN_ALLOW_VIEW_INV then return end

    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then target = p; break end
    end

    if target then
        _SetExpectedRev(player.userid, target_userid, nil)
        local target_name = target.name or "???"
        _SendOnlineInventoryWithDelay(player.userid, target_userid, target_name, target, 0.08)
    else
        -- 容错：若客户端误走在线链路，但目标实际离线且本地有快照，则自动回退到离线快照
        if (not _IsOnlineByUserid(target_userid)) and GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then
            local name, items = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
            if name and items then
                local rev = _GetOfflineRev(target_userid)
                _SetExpectedRev(player.userid, target_userid, rev)
                SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"),
                    player.userid, _BuildTargetInfo(target_userid, name, rev), items)
                return
            end
        end
        -- 在线查询专用：只走在线/跨世界在线链路，不回退离线快照
        local data_str = player.userid .. "|" .. target_userid
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestInventory"), nil, data_str)
        end)
    end
end)

-- 服务端处理：离线玩家物品查询（与在线查询链路彻底分离）
AddModRPCHandler("DstAdmin", "RequestOfflineInventory", function(player, target_userid)
    if not player or type(target_userid) ~= "string" then return end
    local is_admin = _IsAdmin(player.userid)
    if not is_admin and not DSTADMIN_ALLOW_VIEW_INV then
        return
    end
    if not GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then
        return
    end

    local name, items = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
    if name and items then
        local rev = _GetOfflineRev(target_userid)
        _SetExpectedRev(player.userid, target_userid, rev)
        local need_remote = _NeedOfflineShardRefresh(target_userid, items)
        _Dbg("req_offline_inv uid=" .. tostring(target_userid)
            .. " admin=" .. tostring(player.userid)
            .. " rev=" .. tostring(rev)
            .. " need_remote=" .. tostring(need_remote))
        if need_remote then
            if _ShouldSendOfflineRemoteReq(player.userid, target_userid, 0.5) then
                local data_off = player.userid .. "|" .. target_userid
                GLOBAL.pcall(function()
                    SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestOfflineInventory"), nil, data_off)
                end)
            end
            return
        end
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid, _BuildTargetInfo(target_userid, name, rev), items)
        return
    end

    local data_off = player.userid .. "|" .. target_userid
    GLOBAL.pcall(function()
        SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestOfflineInventory"), nil, data_off)
    end)
end)

-- Shard RPC：其他世界收到请求，查找并返回物品
AddShardModRPCHandler("DstAdmin", "ShardRequestInventory", function(shard_id, data_str)
    local requesting_userid, target_userid = tostring(data_str or ""):match("^([^|]+)|(.+)$")
    if not requesting_userid or not target_userid then return end
    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then target = p; break end
    end
    if not target then return end
    local target_name = target.name or "???"
    local items_str = CollectInventory(target)
    local resp_str = requesting_userid .. "|" .. target_userid .. "|" .. target_name .. "|" .. items_str
    GLOBAL.TheWorld:DoTaskInTime(0, function()
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardInventoryResponse"), shard_id, resp_str)
        end)
    end)
end)

-- Shard RPC：离线快照查询（跨世界）
AddShardModRPCHandler("DstAdmin", "ShardRequestOfflineInventory", function(shard_id, data_str)
    local requesting_userid, target_userid = tostring(data_str or ""):match("^([^|]+)|(.+)$")
    if not requesting_userid or not target_userid then return end
    if _IsOnlineByUserid(target_userid) then return end
    if not GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then return end
    local target_name, items_str = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
    local rev = _GetOfflineRev(target_userid)
    if not target_name or not items_str then return end
    _Dbg("shard_offline_inv reply uid=" .. tostring(target_userid)
        .. " to=" .. tostring(requesting_userid)
        .. " items_len=" .. tostring(#tostring(items_str or "")))
    local resp_str = requesting_userid .. "|" .. target_userid .. "|" .. target_name .. "|" .. tostring(rev or 0) .. "|" .. items_str
    GLOBAL.TheWorld:DoTaskInTime(0, function()
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardInventoryResponse"), shard_id, resp_str)
        end)
    end)
end)

-- Shard RPC：镜像离线待处理队列到其他世界（保证上下洞重启后也能结算）
-- data_str: src_shard|userid|give_prefab|give_count|take_prefab|take_count|admin_userid
AddShardModRPCHandler("DstAdmin", "ShardMirrorOfflinePending", function(shard_id, data_str)
    local s = tostring(data_str or "")
    local src_shard, userid, give_prefab, give_count_str, take_prefab, take_count_str, admin_userid =
        s:match("^([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|(.+)$")
    if not userid or userid == "" then return end
    if tostring(src_shard or "") == _GetLocalShardId() then return end
    local append_fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_AppendPending")
    if not append_fn then return end
    local gc = GLOBAL.tonumber(give_count_str) or 0
    local tc = GLOBAL.tonumber(take_count_str) or 0
    append_fn(userid, give_prefab, gc, take_prefab, tc, admin_userid)
end)

-- Shard RPC：同步离线玩家快照（地下/地上统一）
AddShardModRPCHandler("DstAdmin", "ShardSyncOfflineSnapshot", function(shard_id, payload)
    local apply_fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_ApplySyncPayload")
    if not apply_fn then return end
    local ok = apply_fn(payload)
    _Dbg("shard_sync_snapshot applied=" .. tostring(ok))
end)

-- Shard RPC：请求目标 shard 触发一次存档（跨 shard 离线改动后缩小不一致窗口）
-- payload: target_shard|source_shard|reason
AddShardModRPCHandler("DstAdmin", "ShardRequestForceSave", function(shard_id, payload)
    local s = tostring(payload or "")
    local target_shard, source_shard, reason = s:match("^([^|]*)|([^|]*)|(.*)$")
    if not target_shard or target_shard == "" then return end
    if target_shard ~= _GetLocalShardId() then return end
    _ForceLocalSave("peer_from=" .. tostring(source_shard or "") .. " reason=" .. tostring(reason or ""))
end)

-- Shard RPC：离线跨 shard 操作 ACK（用于重试停止）
-- payload: target_shard|source_shard|req_id
AddShardModRPCHandler("DstAdmin", "ShardOfflineOpAck", function(shard_id, payload)
    local s = tostring(payload or "")
    local target_shard, source_shard, req_id = s:match("^([^|]*)|([^|]*)|(.+)$")
    if not target_shard or target_shard == "" then return end
    if target_shard ~= _GetLocalShardId() then return end
    if not req_id or req_id == "" then return end
    local rec = _ACK_RETRY_PENDING[req_id]
    if rec ~= nil then
        _ACK_RETRY_PENDING[req_id] = nil
        _Dbg("ack_retry acked req=" .. tostring(req_id)
            .. " rpc=" .. tostring(rec.rpc_name)
            .. " from=" .. tostring(source_shard or ""))
    end
end)

-- Shard RPC：收到其他世界的物品数据，转发给客户端
AddShardModRPCHandler("DstAdmin", "ShardInventoryResponse", function(shard_id, resp_str)
    local s = tostring(resp_str or "")
    local p1 = s:find("|", 1, true)
    if not p1 then return end
    local requesting_userid = s:sub(1, p1 - 1)
    local rest = s:sub(p1 + 1)
    local p2 = rest:find("|", 1, true)
    if not p2 then return end
    local target_userid = rest:sub(1, p2 - 1)
    local rest2 = rest:sub(p2 + 1)
    local p3 = rest2:find("|", 1, true)
    if not p3 then return end
    local target_name = rest2:sub(1, p3 - 1)
    local tail = rest2:sub(p3 + 1)
    local target_info = target_userid .. "|" .. target_name
    local p4 = tail:find("|", 1, true)
    local items_str = tail
    if p4 then
        local maybe_rev = tail:sub(1, p4 - 1)
        if maybe_rev:match("^%d+$") then
            target_info = _BuildTargetInfo(target_userid, target_name, GLOBAL.tonumber(maybe_rev))
            items_str = tail:sub(p4 + 1)
        end
    end
    GLOBAL.pcall(function()
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), requesting_userid, target_info, items_str)
    end)
end)

-- ========== NPC 伙伴物品查询 ==========

local function _ParseNPCUIRequestParam(param)
    if type(param) ~= "string" or param == "" then
        return nil, nil
    end
    local guid_s, owner_param = param:match("^(%d+)|(.+)$")
    if guid_s and owner_param then
        return GLOBAL.tonumber(guid_s), owner_param
    end
    return nil, param
end

local function FindNPCForUIRequest(owner_param)
    local req_guid, pure_owner_param = _ParseNPCUIRequestParam(owner_param)
    if req_guid then
        local ent = GLOBAL.Ents and GLOBAL.Ents[req_guid] or nil
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            return ent
        end
    end
    if type(pure_owner_param) ~= "string" or pure_owner_param == "" then return nil end
    local parts = {}
    for seg in pure_owner_param:gmatch("[^:]+") do
        parts[#parts + 1] = seg
    end
    local owner_userid = parts[1]
    local char_type = parts[2]
    local slot_index = GLOBAL.tonumber(parts[3])
    if owner_userid == "_" then
        owner_userid = nil
    end

    for _, ent in pairs(GLOBAL.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            if char_type and char_type ~= "" and ent.npc_character_type ~= char_type then
                -- 指定了角色类型则必须匹配
            else
                local slot_ok = (slot_index == nil) or (ent.npc_slot_index == slot_index)
                if slot_ok then
                    if owner_userid == nil then
                        return ent
                    end
                    local leader = ent.components and ent.components.follower and ent.components.follower.leader or nil
                    local ent_owner = ent.owner_userid and ent.owner_userid:value() or nil
                    if (leader and leader.userid == owner_userid)
                        or (ent_owner and ent_owner ~= "" and ent_owner == owner_userid) then
                        return ent
                    end
                end
            end
        end
    end

    -- 备选：主匹配失败后，尝试按 char_type + slot_index 匹配无主NPC
    if char_type and char_type ~= "" then
        for _, ent in pairs(GLOBAL.Ents or {}) do
            if ent and ent:IsValid() and ent:HasTag("npcfriend")
               and ent.npc_character_type == char_type then
                local slot_ok = (slot_index == nil) or (ent.npc_slot_index == slot_index)
                local ent_owner = ent.owner_userid and ent.owner_userid:value() or nil
                if slot_ok and (not ent_owner or ent_owner == "") then
                    return ent
                end
            end
        end
    end

    -- 最终备选：纯按 char_type + slot_index 匹配，忽略 owner（覆盖 owner 双向变化）
    if char_type and char_type ~= "" then
        for _, ent in pairs(GLOBAL.Ents or {}) do
            if ent and ent:IsValid() and ent:HasTag("npcfriend")
               and ent.npc_character_type == char_type then
                local slot_ok = (slot_index == nil) or (ent.npc_slot_index == slot_index)
                if slot_ok then
                    return ent
                end
            end
        end
    end

    return nil
end

-- 服务端处理：玩家请求查看 NPC 伙伴物品（所有玩家均可）
-- owner_userid：NPC 所属玩家的 userid
AddModRPCHandler("DstAdmin", "RequestNPCInventory", function(player, owner_userid)
    if not player or type(owner_userid) ~= "string" then return end

    local npc = FindNPCForUIRequest(owner_userid)
    if npc then
        if npc:HasTag("npc_hostile") or npc:HasTag("npc_no_ui") then
            return
        end
        local _, owner_param = _ParseNPCUIRequestParam(owner_userid)
        local items_str = CollectInventory(npc)
        -- 使用 "npc:OWNER_PARAM" 作为虚拟 target_userid，客户端凭此路由后续操作
        local virtual_id = "npc:" .. (owner_param or owner_userid)
        -- 显示角色名而非通用"NPC伙伴"
        local char_name = npc.npc_character_type or "NPC"
        local display = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char_name)]) or char_name
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
            virtual_id .. "|" .. display, items_str)
    end
end)

-- ========== NPC 幽灵复活 ==========

-- 服务端处理：玩家手持告密的心复活NPC幽灵
AddModRPCHandler("DstAdmin", "ReviveNPCGhost", function(player, owner_param)
    if not player or type(owner_param) ~= "string" then return end

    local inv = player.components and player.components.inventory
    if not inv then return end
    local active_item = inv:GetActiveItem()
    if not active_item or not active_item:HasTag("reviver") then return end

    local npc = FindNPCForOwner(owner_param)
    if not npc then return end

    if not npc._is_ghost_mode then return end

    inv:SetActiveItem(nil)
    if active_item:IsValid() then
        active_item:Remove()
    end

    local npc_ghost = GLOBAL.require("npc/npc_ghost")
    npc_ghost.ReviveFromGhost(npc)
end)

-- ========== NPC 伙伴状态查询 ==========

-- 服务端处理：玩家请求查看自己的 NPC 伙伴状态属性
AddModRPCHandler("DstAdmin", "RequestNPCStatus", function(player, owner_param)
    if not player or type(owner_param) ~= "string" then return end

    local npc = FindNPCForUIRequest(owner_param)
    if not npc then return end
    if npc:HasTag("npc_hostile") or npc:HasTag("npc_no_ui") then return end

    -- 所有玩家都可查看任意 NPC 状态（已移除权限检查）

    local status_str = CollectNPCStatus(npc)
    local char_name = npc.npc_character_type or "NPC"
    local display_name = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char_name)]) or char_name

    -- 发送给客户端: "owner_param|display_name|status_str"
    local _, pure_owner_param = _ParseNPCUIRequestParam(owner_param)
    SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveNPCStatus"),
        player.userid, (pure_owner_param or owner_param) .. "|" .. display_name .. "|" .. status_str)
end)

-- ========== 跨世界三维属性查询 ==========

-- 服务端处理：管理员请求远程玩家三维属性
AddModRPCHandler("DstAdmin", "RequestRemoteStats", function(player, remote_uids_str)
    if not player or type(remote_uids_str) ~= "string" then return end
    local is_admin = false
    for _, c in ipairs(GLOBAL.TheNet:GetClientTable() or {}) do
        if c.userid == player.userid and c.admin then is_admin = true; break end
    end
    if not is_admin then return end

    local local_results = {}
    local remote_list = {}
    for uid in remote_uids_str:gmatch("[^,]+") do
        local found = false
        for _, p in ipairs(GLOBAL.AllPlayers or {}) do
            if p and p.userid == uid then
                local hp, hu, sa, is_ghost = CollectStats(p)
                table.insert(local_results, uid .. ":" .. hp .. ":" .. hu .. ":" .. sa .. ":" .. (is_ghost and "1" or "0"))
                found = true; break
            end
        end
        if not found then table.insert(remote_list, uid) end
    end

    if #local_results > 0 then
        GLOBAL.pcall(function()
            SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveStats"), player.userid, table.concat(local_results, ","))
        end)
    end

    if #remote_list > 0 then
        local data_str = player.userid .. "|" .. table.concat(remote_list, ",")
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestStats"), nil, data_str)
        end)
    end
end)

-- Shard RPC：其他世界收到三维查询请求
AddShardModRPCHandler("DstAdmin", "ShardRequestStats", function(shard_id, data_str)
    local requesting_userid, uids_str = tostring(data_str or ""):match("^([^|]+)|(.+)$")
    if not requesting_userid or not uids_str then return end

    local results = {}
    for uid in uids_str:gmatch("[^,]+") do
        for _, p in ipairs(GLOBAL.AllPlayers or {}) do
            if p and p.userid == uid then
                local hp, hu, sa, is_ghost = CollectStats(p)
                table.insert(results, uid .. ":" .. hp .. ":" .. hu .. ":" .. sa .. ":" .. (is_ghost and "1" or "0"))
                break
            end
        end
    end

    if #results > 0 then
        local resp_str = requesting_userid .. "|" .. table.concat(results, ",")
        GLOBAL.TheWorld:DoTaskInTime(0, function()
            GLOBAL.pcall(function()
                SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardStatsResponse"), shard_id, resp_str)
            end)
        end)
    end
end)

-- Shard RPC：收到三维查询响应，转发给客户端
AddShardModRPCHandler("DstAdmin", "ShardStatsResponse", function(shard_id, resp_str)
    local s = tostring(resp_str or "")
    local p1 = s:find("|", 1, true)
    if not p1 then return end
    local requesting_userid = s:sub(1, p1 - 1)
    local stats_str = s:sub(p1 + 1)
    GLOBAL.pcall(function()
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveStats"), requesting_userid, stats_str)
    end)
end)

-- ========== 离线玩家列表 ==========
AddModRPCHandler("DstAdmin", "RequestOfflinePlayers", function(player)
    if not player then return end
    if not _IsAdmin(player.userid) then return end
    if not GLOBAL.DSTADMIN_OFFLINE_STORE_GetListSerialized then return end
    local payload = GLOBAL.DSTADMIN_OFFLINE_STORE_GetListSerialized(true)
    SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveOfflinePlayers"), player.userid, payload or "")
end)

-- ========== NPC 列表 ==========
local function _BuildNPCListPayload()
    local list = {}
    for _, ent in pairs(GLOBAL.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            local guid = GLOBAL.tonumber(ent.GUID) or 0
            local char = tostring(ent.npc_character_type or "npc")
            local slot = GLOBAL.tonumber(ent.npc_slot_index) or 0
            local owner = nil
            if ent.owner_userid and ent.owner_userid.value then
                owner = ent.owner_userid:value()
            end
            if (not owner or owner == "") and ent.components and ent.components.follower and ent.components.follower.leader then
                owner = ent.components.follower.leader.userid
            end
            if not owner or owner == "" then
                owner = "_"
            end
            local owner_param = tostring(owner) .. ":" .. char .. ":" .. tostring(slot)
            local display = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char)]) or char
            local is_ghost = (ent._is_ghost_mode == true) and "1" or "0"
            local is_hostile = ent:HasTag("npc_hostile") and "1" or "0"
            table.insert(list, {
                key = tostring(display) .. "|" .. tostring(owner_param) .. "|" .. tostring(guid),
                line = table.concat({
                    tostring(guid),
                    tostring(owner_param),
                    tostring(display),
                    tostring(char),
                    is_ghost,
                    is_hostile,
                }, "\t"),
            })
        end
    end
    table.sort(list, function(a, b) return a.key < b.key end)
    local lines = {}
    for _, v in ipairs(list) do
        table.insert(lines, v.line)
    end
    return table.concat(lines, "\n")
end

AddModRPCHandler("DstAdmin", "RequestNPCPlayers", function(player)
    if not player then return end
    if not _IsAdmin(player.userid) then return end
    local has_npcfriends = (GLOBAL.ACTIONS and GLOBAL.ACTIONS.NPC_GREET ~= nil) or (GLOBAL.NPCFRIENDS ~= nil)
    if not has_npcfriends then
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveNPCPlayers"), player.userid, "")
        return
    end
    local payload = _BuildNPCListPayload()
    SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveNPCPlayers"), player.userid, payload or "")
end)

-- ========== 跨世界管理员操作（复活/全满）==========

-- 服务端处理：管理员对玩家执行操作
AddModRPCHandler("DstAdmin", "AdminAction", function(player, params_str)
    if not player or type(params_str) ~= "string" then return end
    local is_admin = false
    for _, c in ipairs(GLOBAL.TheNet:GetClientTable() or {}) do
        if c.userid == player.userid and c.admin then is_admin = true; break end
    end
    if not is_admin then return end

    local action, target_userid = params_str:match("^([^|]+)|(.+)$")
    if not action or not target_userid then return end

    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then target = p; break end
    end

    if target then
        ExecuteAdminAction(target, action)
    else
        -- 跨世界广播
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminAction"), nil, action .. "|" .. target_userid)
        end)
    end
end)

-- Shard RPC：其他世界收到管理员操作请求
AddShardModRPCHandler("DstAdmin", "ShardAdminAction", function(shard_id, data_str)
    local action, target_userid = tostring(data_str or ""):match("^([^|]+)|(.+)$")
    if not action or not target_userid then return end
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then
            ExecuteAdminAction(p, action)
            return
        end
    end
end)

-- ========== 物品拿取/给予 RPC ==========

-- 服务端处理：管理员拿取目标玩家物品
-- params_str: target_userid|slot_type|slot_key|amount
AddModRPCHandler("DstAdmin", "AdminTakeItem", function(player, params_str)
    if not player or type(params_str) ~= "string" then return end
    local is_admin = _IsAdmin(player.userid)
    local target_userid, slot_type, slot_key, amt_str, mode, prefab_hint, count_hint_str, offline_flag =
        params_str:match("^([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)$")
    if not target_userid then
        target_userid, slot_type, slot_key, amt_str, mode =
            params_str:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.+)$")
    end
    if not target_userid then
        target_userid, slot_type, slot_key, amt_str =
            params_str:match("^([^|]+)|([^|]+)|([^|]+)|(.+)$")
    end
    mode = mode or ""
    prefab_hint = prefab_hint or ""
    local count_hint = GLOBAL.tonumber(count_hint_str) or 0
    local is_offline_request = (offline_flag == "1")
    if not target_userid or not slot_type or not slot_key then
        return
    end
    local amount = GLOBAL.tonumber(amt_str) or 0
    local to_inventory = (mode == "bag")
    _Dbg("take_req admin=" .. tostring(player.userid)
        .. " target=" .. tostring(target_userid)
        .. " slot=" .. tostring(slot_type) .. ":" .. tostring(slot_key)
        .. " amount=" .. tostring(amount)
        .. " mode=" .. tostring(mode)
        .. " offline_flag=" .. tostring(is_offline_request))

    if target_userid:sub(1, 4) == "npc:" then
        local owner_param = target_userid:sub(5)
        local npc = FindNPCForOwner(owner_param)
        if npc then
            if to_inventory then
                local want = count_hint
                local prefab = prefab_hint
                if (prefab == "" or want <= 0) and npc.components and npc.components.inventory then
                    local inv = npc.components.inventory
                    local item = nil
                    if slot_type == "E" then
                        item = inv.equipslots and inv.equipslots[slot_key] or nil
                    elseif slot_type == "I" then
                        local sn = GLOBAL.tonumber(slot_key)
                        item = sn and inv.itemslots and inv.itemslots[sn] or nil
                    end
                    if item then
                        prefab = item.prefab or prefab
                        want = (item.components and item.components.stackable and item.components.stackable:StackSize()) or 1
                    end
                end
                if prefab ~= "" and want > 0 then
                    local cap = _CountAcceptableToPlayer(player, prefab, want)
                    if cap <= 0 then
                        local items_str = CollectInventory(npc)
                        local char_name = npc.npc_character_type or "NPC"
                        local display = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char_name)]) or char_name
                        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
                            target_userid .. "|" .. display, items_str)
                        return
                    end
                    amount = math.min((amount <= 0) and want or amount, cap)
                end
            end
            local prefab, count, taken_item = TakeItemFromNPC(npc, slot_type, slot_key, amount)
            if taken_item then
                local is_container = taken_item.components and taken_item.components.container ~= nil
                if is_container then

                    GLOBAL.pcall(function()
                        local ii = taken_item.components and taken_item.components.inventoryitem
                        if ii then
                            ii.owner = npc
                            ii:OnDropped(true)
                        end
                    end)
                elseif player.components and player.components.inventory then
                    if to_inventory or player.components.inventory:GetActiveItem() then
                        player.components.inventory:GiveItem(taken_item)
                    else
                        player.components.inventory:GiveActiveItem(taken_item)
                    end
                end
            end
            local items_str = CollectInventory(npc)
            local char_name = npc.npc_character_type or "NPC"
            local display = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char_name)]) or char_name
            SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
                target_userid .. "|" .. display, items_str)
        end
        return
    end

    -- 非 NPC 操作：非管理员且配置未允许普通成员拿取，拒绝请求
    if not is_admin and not DSTADMIN_ALLOW_TAKE_GIVE then
        return
    end

    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then target = p; break end
    end
    if not target and not is_offline_request then
        local has_local = GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal and GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal(target_userid)
        if has_local and not _IsOnlineByUserid(target_userid) then
            is_offline_request = true
            _Dbg("take_req auto_offline target=" .. tostring(target_userid))
        end
    end

    if target then
        if to_inventory then
            local prefab0, stack0, blocked = _PeekOnlineTargetItem(target, slot_type, slot_key)
            if blocked or not prefab0 then
                return
            end
            local want = (amount <= 0) and stack0 or math.min(amount, stack0)
            local cap = _CountAcceptableToPlayer(player, prefab0, want)
            if cap <= 0 then
                local target_name = target.name or "???"
                local items_str = CollectInventory(target)
                SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid, target_userid .. "|" .. target_name, items_str)
                return
            end
            amount = math.min(want, cap)
        end
        local prefab, count, taken_item = TakeItemFromPlayer(target, slot_type, slot_key, amount)
        if taken_item and player.components and player.components.inventory then
            if to_inventory or player.components.inventory:GetActiveItem() then
                player.components.inventory:GiveItem(taken_item)
            else
                player.components.inventory:GiveActiveItem(taken_item)
            end
        end
        local target_name = target.name or "???"
        _SendOnlineInventoryWithDelay(player.userid, target_userid, target_name, target, 0.08)
    else
        if is_offline_request and GLOBAL.DSTADMIN_OFFLINE_STORE_TakeFromSnapshot then
            local route_remote, owner_sid = _ShouldRouteOfflineOpToOwnerShard(target_userid)
            _Dbg("take_offline route_remote=" .. tostring(route_remote)
                .. " owner_sid=" .. tostring(owner_sid))
            if route_remote then
                local has_local = GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal and GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal(target_userid)
                if not has_local then
                    if owner_sid and owner_sid ~= "" then
                        local data_off = owner_sid .. "|" .. player.userid .. "|" .. target_userid .. "|" .. slot_type .. "|" .. slot_key .. "|" .. tostring(amount) .. "|" .. tostring(mode)
                        _SendReliableOfflineRPC("ShardOfflineTakeItem", owner_sid, data_off)
                    else
                        _RequestOfflineInventoryFromShards(player.userid, target_userid)
                    end
                    return
                else
                    _Dbg("take_offline route_remote_but_use_local_snapshot uid=" .. tostring(target_userid))
                end
            end
            if to_inventory then
                local prefab0, stack0, blocked = _PeekOfflineSnapshotItem(target_userid, slot_type, slot_key)
                if blocked or not prefab0 then
                    if GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then
                        local tn, is = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
                        if tn and is then
                            _SendOfflineInventoryToClient(player.userid, target_userid, tn, is)
                        end
                    end
                    return
                end
                local want = (amount <= 0) and stack0 or math.min(amount, stack0)
                local cap = _CountAcceptableToPlayer(player, prefab0, want)
                if cap <= 0 then
                    if GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then
                        local tn, is = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
                        if tn and is then
                            _SendOfflineInventoryToClient(player.userid, target_userid, tn, is)
                        end
                    end
                    return
                end
                amount = math.min(want, cap)
            end
            local expected_rev = _GetExpectedRev(player.userid, target_userid)
            if expected_rev == nil then
                expected_rev = _GetOfflineRev(target_userid)
                _SetExpectedRev(player.userid, target_userid, expected_rev)
                _Dbg("take_offline expected_rev_missing set_to=" .. tostring(expected_rev))
                if expected_rev == nil then
                    if GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then
                        local tn, is = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
                        if tn and is then
                            _SendOfflineInventoryToClient(player.userid, target_userid, tn, is)
                        end
                    end
                    return
                end
            end
            local prefab, count, target_name, items_str, new_rev, is_stale =
                GLOBAL.DSTADMIN_OFFLINE_STORE_TakeFromSnapshot(target_userid, slot_type, slot_key, amount, player.userid, expected_rev)
            if is_stale then
                _SetExpectedRev(player.userid, target_userid, new_rev)
                if items_str and target_name then
                    SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid, _BuildTargetInfo(target_userid, target_name, new_rev), items_str)
                end
                return
            end
            _SetExpectedRev(player.userid, target_userid, new_rev)
            if prefab and count and count > 0 and player.components and player.components.inventory then
                local item = GLOBAL.SpawnPrefab(prefab)
                if item then
                    if count > 1 and item.components and item.components.stackable then
                        item.components.stackable:SetStackSize(count)
                    end
                    if to_inventory or player.components.inventory:GetActiveItem() then
                        player.components.inventory:GiveItem(item)
                    else
                        player.components.inventory:GiveActiveItem(item)
                    end
                end
                _MirrorOfflinePending(target_userid, "", 0, prefab, count, player.userid)
            end
            if items_str and target_name then
                _SyncOfflineSnapshotToShards(target_userid)
                _BumpOfflineRemoteReqCooldown(player.userid, target_userid, 1.0)
                _ForceSaveBothSides(owner_sid, "offline_take_local")
                SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid, _BuildTargetInfo(target_userid, target_name, new_rev), items_str)
                return
            end
            _RequestOfflineInventoryFromShards(player.userid, target_userid)
            return
        end
        -- 跨世界在线目标：Shift+左键“直接入背包”按本地可叠加容量限流，叠满后再拦截
        if to_inventory then
            if prefab_hint == "" or count_hint <= 0 then
                local data_req = player.userid .. "|" .. target_userid
                GLOBAL.pcall(function()
                    SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestInventory"), nil, data_req)
                end)
                return
            end
            local want = (amount <= 0) and count_hint or math.min(amount, count_hint)
            local cap = _CountAcceptableToPlayer(player, prefab_hint, want)
            if cap <= 0 then
                local data_req = player.userid .. "|" .. target_userid
                GLOBAL.pcall(function()
                    SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardRequestInventory"), nil, data_req)
                end)
                return
            end
            amount = math.min(want, cap)
        end
        -- 跨世界广播
        local data = player.userid .. "|" .. target_userid .. "|" .. slot_type .. "|" .. slot_key .. "|" .. tostring(amount) .. "|" .. tostring(mode)
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminTakeItem"), nil, data)
        end)
    end
end)

-- Shard RPC：其他世界收到拿取请求
-- data_str: admin_userid|target_userid|slot_type|slot_key|amount|mode
AddShardModRPCHandler("DstAdmin", "ShardAdminTakeItem", function(shard_id, data_str)
    local s = tostring(data_str or "")
    local admin_userid, target_userid, slot_type, slot_key, amt_str, mode =
        s:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.*)$")
    if not admin_userid then
        admin_userid, target_userid, slot_type, slot_key, amt_str = s:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.+)$")
        mode = ""
    end
    if not admin_userid or not target_userid then return end
    local amount = GLOBAL.tonumber(amt_str) or 0

    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then
            local prefab, count, taken_item = TakeItemFromPlayer(p, slot_type, slot_key, amount)
            if taken_item then
                if taken_item:IsValid() then
                    local x, y, z = p.Transform:GetWorldPosition()
                    taken_item.Transform:SetPosition(x, y, z)
                end
                taken_item:Remove()  -- 销毁跨世界实体（无法直接传输，由响应端重建）
            end
            if prefab and count and count > 0 then
                local resp = admin_userid .. "|" .. prefab .. "|" .. tostring(count) .. "|" .. tostring(mode or "")
                GLOBAL.TheWorld:DoTaskInTime(0, function()
                    GLOBAL.pcall(function()
                        SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminTakeItemResponse"), shard_id, resp)
                    end)
                end)
            end
            GLOBAL.TheWorld:DoTaskInTime(0.08, function()
                if not p or (p.IsValid and not p:IsValid()) then return end
                local target_name = p.name or "???"
                local items_str = CollectInventory(p)
                local inv_resp = admin_userid .. "|" .. target_userid .. "|" .. target_name .. "|" .. items_str
                GLOBAL.pcall(function()
                    SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardInventoryResponse"), shard_id, inv_resp)
                end)
            end)
            return
        end
    end
end)

-- Shard RPC：离线快照拿取（跨世界）
-- data_str: owner_sid|admin_userid|target_userid|slot_type|slot_key|amount|mode
AddShardModRPCHandler("DstAdmin", "ShardOfflineTakeItem", function(shard_id, data_str)
    local source_sid = tostring(shard_id or "")
    local req_id, legacy_payload, is_reliable = _DecodeReliablePayload(data_str)
    if is_reliable and _HasSeenReliableReq("ShardOfflineTakeItem", source_sid, req_id) then
        _SendOfflineOpAck(source_sid, req_id)
        return
    end
    local s = tostring(legacy_payload or data_str or "")
    local owner_sid, admin_userid, target_userid, slot_type, slot_key, amt_str, mode =
        s:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.*)$")
    if not owner_sid then return end
    if not admin_userid or not target_userid then return end
    if not owner_sid or owner_sid == "" then return end
    if owner_sid ~= _GetLocalShardId() then return end
    if is_reliable then
        _MarkSeenReliableReq("ShardOfflineTakeItem", source_sid, req_id)
    end
    if _IsOnlineByUserid(target_userid) then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    if not GLOBAL.DSTADMIN_OFFLINE_STORE_TakeFromSnapshot then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    local amount = GLOBAL.tonumber(amt_str) or 0
    local prefab, count, target_name, items_str, new_rev =
        GLOBAL.DSTADMIN_OFFLINE_STORE_TakeFromSnapshot(target_userid, slot_type, slot_key, amount, admin_userid)
    if prefab and count and count > 0 then
        _MirrorOfflinePending(target_userid, "", 0, prefab, count, admin_userid)
        local resp = admin_userid .. "|" .. prefab .. "|" .. tostring(count) .. "|" .. tostring(mode or "")
        GLOBAL.TheWorld:DoTaskInTime(0, function()
            GLOBAL.pcall(function()
                SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminTakeItemResponse"), shard_id, resp)
            end)
        end)
    end
    if target_name and items_str then
        local inv_resp = admin_userid .. "|" .. target_userid .. "|" .. target_name .. "|" .. tostring(new_rev or 0) .. "|" .. items_str
        GLOBAL.TheWorld:DoTaskInTime(0, function()
            GLOBAL.pcall(function()
                SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardInventoryResponse"), shard_id, inv_resp)
            end)
        end)
    end
    if prefab and count and count > 0 then
        _ForceSaveBothSides(tostring(shard_id or ""), "offline_take_remote")
    end
    if is_reliable then
        _SendOfflineOpAck(source_sid, req_id)
    end
end)

-- Shard RPC：管理员世界收到跨世界拿取的物品数据，生成给管理员
-- data_str: admin_userid|prefab|count|mode
AddShardModRPCHandler("DstAdmin", "ShardAdminTakeItemResponse", function(shard_id, data_str)
    local s = tostring(data_str or "")
    local admin_userid, prefab, count_str, mode = s:match("^([^|]+)|([^|]+)|([^|]+)|(.*)$")
    if not admin_userid then
        admin_userid, prefab, count_str = s:match("^([^|]+)|([^|]+)|(.+)$")
        mode = ""
    end
    if not admin_userid or not prefab then return end
    local count = GLOBAL.tonumber(count_str) or 1
    local to_inventory = (mode == "bag")
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == admin_userid and p.components and p.components.inventory then
            local item = GLOBAL.SpawnPrefab(prefab)
            if item then
                if count > 1 and item.components and item.components.stackable then
                    item.components.stackable:SetStackSize(count)
                end
                if to_inventory or p.components.inventory:GetActiveItem() then
                    p.components.inventory:GiveItem(item)
                else
                    p.components.inventory:GiveActiveItem(item)
                end
            end
            return
        end
    end
end)

local function _FindPlayerInventoryItemByGUID(player, guid)
    if not player or not player.components or not player.components.inventory then return nil, nil, nil end
    local inv = player.components.inventory

    for slot, item in pairs(inv.itemslots or {}) do
        if item ~= nil and item.GUID == guid then
            return item, inv, slot
        end
    end

    local ok, overflow = GLOBAL.pcall(function()
        return inv:GetOverflowContainer()
    end)
    if ok and overflow ~= nil then
        for slot, item in pairs(overflow.slots or {}) do
            if item ~= nil and item.GUID == guid then
                return item, overflow, slot
            end
        end
    end

    return nil, nil, nil
end

AddModRPCHandler("DstAdmin", "AdminGivePlayerSlotToNPC", function(player, payload)
    if not player or type(payload) ~= "string" then return end
    local target_userid, guid_str = payload:match("^(.-)|(%d+)$")
    if not target_userid or target_userid:sub(1, 4) ~= "npc:" then return end

    local npc = FindNPCForOwner(target_userid:sub(5))
    if not npc or not npc.components or not npc.components.inventory then return end
    if npc._is_ghost_mode or npc:HasTag("ghost") or (npc.components.health and npc.components.health:IsDead()) then
        return
    end

    local guid = GLOBAL.tonumber(guid_str)
    local item, source_container, source_slot = _FindPlayerInventoryItemByGUID(player, guid)
    if not item or not source_container then return end

    local count = 1
    if item.components and item.components.stackable then
        count = item.components.stackable:StackSize() or 1
    end

    local accepted = _CountAcceptableToInventoryOwner(npc, item, count)
    if accepted <= 0 then return end

    local give_item = item
    if accepted < count then
        if not (item.components and item.components.stackable) then return end
        give_item = item.components.stackable:Get(accepted)
    else
        give_item = source_container:RemoveItem(item, true)
    end
    if not give_item then return end

    local ok, gave = GLOBAL.pcall(function()
        return npc.components.inventory:GiveItem(give_item)
    end)
    if not ok or gave == false then
        if give_item ~= item and give_item:IsValid() and item:IsValid()
            and item.components and item.components.stackable then
            item.components.stackable:Put(give_item)
        elseif give_item == item and give_item:IsValid() then
            GLOBAL.pcall(function()
                source_container:GiveItem(give_item, source_slot)
            end)
        end
        return
    end

    local items_str = CollectInventory(npc)
    local char_name = npc.npc_character_type or "NPC"
    local display = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char_name)]) or char_name
    SendModRPCToClient(GetClientModRPC("DstAdmin", "PlayNPCQuickStoreSound"), player.userid, "")
    SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
        target_userid .. "|" .. display, items_str)
end)

-- 服务端处理：管理员将手上物品给予目标玩家（从光标拿）
AddModRPCHandler("DstAdmin", "AdminGiveFromCursor", function(player, target_info)
    if not player or type(target_info) ~= "string" then return end
    local target_userid, offline_flag = target_info:match("^([^|]+)|([^|]*)$")
    if not target_userid then target_userid = target_info end
    local is_offline_request = (offline_flag == "1")
    local is_admin = _IsAdmin(player.userid)

    local inv = player.components and player.components.inventory
    if not inv then return end
    local cursor_item = inv:GetActiveItem()
    if not cursor_item then return end

    -- NPC 伙伴给予（所有玩家均可）— 必须在管理员检查之前
    if target_userid:sub(1, 4) == "npc:" then
        local owner_param = target_userid:sub(5)
        local npc = FindNPCForOwner(owner_param)
        if npc and npc.components and npc.components.inventory then
            if npc._is_ghost_mode or npc:HasTag("ghost") or (npc.components.health and npc.components.health:IsDead()) then
                return
            end
            local count = 1
            if cursor_item.components and cursor_item.components.stackable then
                count = cursor_item.components.stackable:StackSize() or 1
            end
            local accepted = _CountAcceptableToInventoryOwner(npc, cursor_item, count)
            if accepted <= 0 then return end

            local give_item = cursor_item
            if accepted < count then
                if not (cursor_item.components and cursor_item.components.stackable) then return end
                give_item = cursor_item.components.stackable:Get(accepted)
            else
                inv:SetActiveItem(nil)
            end

            local ok, gave = GLOBAL.pcall(function()
                return npc.components.inventory:GiveItem(give_item)
            end)
            if not ok or gave == false then
                if give_item ~= cursor_item and give_item:IsValid() and cursor_item:IsValid()
                    and cursor_item.components and cursor_item.components.stackable then
                    cursor_item.components.stackable:Put(give_item)
                elseif give_item == cursor_item then
                    GLOBAL.pcall(function() inv:GiveActiveItem(cursor_item) end)
                end
            end
            local items_str = CollectInventory(npc)
            local char_name = npc.npc_character_type or "NPC"
            local display = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char_name)]) or char_name
            SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
                target_userid .. "|" .. display, items_str)
        end
        return
    end

    -- 非 NPC 操作：非管理员且配置未允许普通成员存放，拒绝请求
    if not is_admin and not DSTADMIN_ALLOW_TAKE_GIVE then
        return
    end

    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then target = p; break end
    end
    if not target and not is_offline_request then
        local has_local = GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal and GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal(target_userid)
        if has_local and not _IsOnlineByUserid(target_userid) then
            is_offline_request = true
            _Dbg("give_stack auto_offline target=" .. tostring(target_userid))
        end
    end

    if target then
        local prefab = cursor_item.prefab
        local count = 1
        if cursor_item.components and cursor_item.components.stackable then
            count = cursor_item.components.stackable:StackSize() or 1
        end
        local accepted = 0
        accepted = select(1, GiveItemToPlayer(target, prefab, count)) or 0
        if accepted > 0 then
            if accepted >= count then
                inv:SetActiveItem(nil)
                if cursor_item:IsValid() then cursor_item:Remove() end
            else
                if cursor_item.components and cursor_item.components.stackable then
                    cursor_item.components.stackable:SetStackSize(count - accepted)
                end
            end
        end
        local target_name = target.name or "???"
        local items_str = CollectInventory(target)
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid, target_userid .. "|" .. target_name, items_str)
    else
        if is_offline_request and GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSnapshot then
            local prefab = cursor_item.prefab
            local count = 1
            if cursor_item.components and cursor_item.components.stackable then
                count = cursor_item.components.stackable:StackSize() or 1
            end
            local route_remote, owner_sid = _ShouldRouteOfflineOpToOwnerShard(target_userid)
            if route_remote then
                local has_local = GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal and GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal(target_userid)
                if not has_local then
                    if owner_sid and owner_sid ~= "" then
                        local data_off = owner_sid .. "|" .. player.userid .. "|" .. target_userid .. "|" .. prefab .. "|" .. tostring(count)
                        _SendReliableOfflineRPC("ShardOfflineGiveItem", owner_sid, data_off)
                    else
                        _RequestOfflineInventoryFromShards(player.userid, target_userid)
                    end
                    return
                else
                    _Dbg("give_stack route_remote_but_use_local_snapshot uid=" .. tostring(target_userid))
                end
            end
            local expected_rev = _GetExpectedRev(player.userid, target_userid)
            if expected_rev == nil then
                expected_rev = _GetOfflineRev(target_userid)
                _SetExpectedRev(player.userid, target_userid, expected_rev)
                _Dbg("give_stack expected_rev_missing set_to=" .. tostring(expected_rev))
                if expected_rev == nil then
                    if GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then
                        local tn, is = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
                        if tn and is then
                            _SendOfflineInventoryToClient(player.userid, target_userid, tn, is)
                        end
                    end
                    return
                end
            end
            local ok_local, target_name, items_str, new_rev, is_stale =
                GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSnapshot(target_userid, prefab, count, player.userid, expected_rev)
            _SetExpectedRev(player.userid, target_userid, new_rev)
            if is_stale then
                if items_str and target_name then
                    SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
                        _BuildTargetInfo(target_userid, (target_name or "???"), new_rev), items_str or "CAP:15:body,hands,head:0|")
                end
                return
            end
            if ok_local then
                inv:SetActiveItem(nil)
                if cursor_item:IsValid() then
                    local x, y, z = player.Transform:GetWorldPosition()
                    cursor_item.Transform:SetPosition(x, y, z)
                    cursor_item:Remove()
                end
                _MirrorOfflinePending(target_userid, prefab, count, "", 0, player.userid)
                _SyncOfflineSnapshotToShards(target_userid)
                _BumpOfflineRemoteReqCooldown(player.userid, target_userid, 1.0)
                _ForceSaveBothSides(owner_sid, "offline_give_stack_local")
                SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid, _BuildTargetInfo(target_userid, (target_name or "???"), new_rev), items_str or "CAP:15:body,hands,head:0|")
                return
            end
            local has_local = GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal and GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal(target_userid)
            if has_local then
                return
            end
            _RequestOfflineInventoryFromShards(player.userid, target_userid)
            return
        end
        -- 跨世界：快速整组转移（目标世界先计算可接收数量，再回传管理员世界扣减光标）
        local prefab = cursor_item.prefab
        local count = 1
        if cursor_item.components and cursor_item.components.stackable then
            count = cursor_item.components.stackable:StackSize() or 1
        end
        local data = player.userid .. "|" .. target_userid .. "|" .. prefab .. "|" .. tostring(count)
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminGiveItem"), nil, data)
        end)
    end
end)

-- 服务端处理：管理员将光标物品放入目标玩家指定格子（有物品则交换回管理员光标）
-- params: target_userid|slot_type|slot_key
AddModRPCHandler("DstAdmin", "AdminGiveToSlot", function(player, params_str)
    if not player or type(params_str) ~= "string" then return end
    local is_admin = _IsAdmin(player.userid)
    local target_userid, slot_type, slot_key, offline_flag = params_str:match("^([^|]+)|([^|]+)|([^|]+)|([^|]*)$")
    if not target_userid then
        target_userid, slot_type, slot_key = params_str:match("^([^|]+)|([^|]+)|(.+)$")
    end
    local is_offline_request = (offline_flag == "1")
    if not target_userid or not slot_type or not slot_key then
        return
    end

    local inv = player.components and player.components.inventory
    if not inv then return end
    local cursor_item = inv:GetActiveItem()
    if not cursor_item then return end

    -- NPC 伙伴放入指定槽（支持装备槽 E，所有玩家均可）— 必须在管理员检查之前
    if target_userid:sub(1, 4) == "npc:" then
        local owner_param = target_userid:sub(5)
        local npc = FindNPCForOwner(owner_param)
        if npc then
            local cursor_item_ref = cursor_item
            local displaced = nil
            GLOBAL.pcall(function()
                displaced = PlaceItemInNPCSlot(npc, slot_type, slot_key, cursor_item_ref)
            end)
            if displaced ~= cursor_item_ref then
                inv:SetActiveItem(nil)
                if displaced then
                    GLOBAL.pcall(function() inv:GiveActiveItem(displaced) end)
                end
            end
            local items_str = CollectInventory(npc)
            local char_name = npc.npc_character_type or "NPC"
            local display = (GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES[string.upper(char_name)]) or char_name
            SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
                target_userid .. "|" .. display, items_str)
        end
        return
    end

    -- 非 NPC 操作：非管理员且配置未允许普通成员存放，拒绝请求
    if not is_admin and not DSTADMIN_ALLOW_TAKE_GIVE then
        return
    end

    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then target = p; break end
    end
    if not target and not is_offline_request then
        local has_local = GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal and GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal(target_userid)
        if has_local and not _IsOnlineByUserid(target_userid) then
            is_offline_request = true
            _Dbg("give_slot auto_offline target=" .. tostring(target_userid))
        end
    end

    if target then
        local cursor_item_ref = cursor_item
        local displaced = nil
        GLOBAL.pcall(function()
            displaced = PlaceItemInPlayerSlot(target, slot_type, slot_key, cursor_item_ref)
        end)

        if displaced ~= cursor_item_ref then
            inv:SetActiveItem(nil)
            if displaced then
                GLOBAL.pcall(function() inv:GiveActiveItem(displaced) end)
            end
        end
        local target_name = target.name or "???"
        local items_str = CollectInventory(target)
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid, target_userid .. "|" .. target_name, items_str)
    else
        if is_offline_request and GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSlot then
            local prefab = cursor_item.prefab
            local count = 1
            if cursor_item.components and cursor_item.components.stackable then
                count = cursor_item.components.stackable:StackSize() or 1
            end
            local route_remote, owner_sid = _ShouldRouteOfflineOpToOwnerShard(target_userid)
            if route_remote then
                local has_local = GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal and GLOBAL.DSTADMIN_OFFLINE_STORE_HasLocal(target_userid)
                if not has_local then
                    if owner_sid and owner_sid ~= "" then
                        local data_off = owner_sid .. "|" .. player.userid .. "|" .. target_userid .. "|" .. slot_type .. "|" .. slot_key .. "|" .. prefab .. "|" .. tostring(count)
                        _SendReliableOfflineRPC("ShardOfflineGiveToSlot", owner_sid, data_off)
                    else
                        _RequestOfflineInventoryFromShards(player.userid, target_userid)
                    end
                    return
                else
                    _Dbg("give_slot route_remote_but_use_local_snapshot uid=" .. tostring(target_userid))
                end
            end
            local expected_rev = _GetExpectedRev(player.userid, target_userid)
            if expected_rev == nil then
                expected_rev = _GetOfflineRev(target_userid)
                _SetExpectedRev(player.userid, target_userid, expected_rev)
                _Dbg("give_slot expected_rev_missing set_to=" .. tostring(expected_rev))
                if expected_rev == nil then
                    if GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory then
                        local tn, is = GLOBAL.DSTADMIN_OFFLINE_STORE_GetInventory(target_userid)
                        if tn and is then
                            _SendOfflineInventoryToClient(player.userid, target_userid, tn, is)
                        end
                    end
                    return
                end
            end
            local result_type, result_extra, target_name, items_str, new_rev, is_stale =
                GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSlot(target_userid, slot_type, slot_key, prefab, count, player.userid, expected_rev)
            _SetExpectedRev(player.userid, target_userid, new_rev)
            if result_type ~= nil then
                if is_stale or result_type == "STALE" then
                    SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
                        _BuildTargetInfo(target_userid, (target_name or "???"), new_rev), items_str or "CAP:15:body,hands,head:0|")
                    return
                end
                local changed = false
                if result_type == "CL" then
                    inv:SetActiveItem(nil)
                    if cursor_item:IsValid() then cursor_item:Remove() end
                    _MirrorOfflinePending(target_userid, prefab, count, "", 0, player.userid)
                    changed = true
                elseif result_type == "PT" then
                    local remain = GLOBAL.tonumber(result_extra) or 0
                    local applied = math.max(0, count - remain)
                    if applied > 0 then
                        _MirrorOfflinePending(target_userid, prefab, applied, "", 0, player.userid)
                        changed = true
                    end
                    if cursor_item.components and cursor_item.components.stackable then
                        if remain > 0 then
                            cursor_item.components.stackable:SetStackSize(remain)
                        else
                            inv:SetActiveItem(nil)
                            if cursor_item:IsValid() then cursor_item:Remove() end
                        end
                    end
                elseif result_type == "SW" then
                    local disp_prefab, disp_count_str = tostring(result_extra or ""):match("^([^:]+):(.+)$")
                    local disp_count = GLOBAL.tonumber(disp_count_str) or 1
                    _MirrorOfflinePending(target_userid, prefab, count, disp_prefab, disp_count, player.userid)
                    changed = true
                    inv:SetActiveItem(nil)
                    if cursor_item:IsValid() then cursor_item:Remove() end
                    if disp_prefab then
                        local spawned = GLOBAL.SpawnPrefab(disp_prefab)
                        if spawned then
                            if disp_count > 1 and spawned.components and spawned.components.stackable then
                                spawned.components.stackable:SetStackSize(disp_count)
                            end
                            inv:GiveActiveItem(spawned)
                        end
                    end
                end
                if changed then
                    _SyncOfflineSnapshotToShards(target_userid)
                    _BumpOfflineRemoteReqCooldown(player.userid, target_userid, 1.0)
                    _ForceSaveBothSides(owner_sid, "offline_give_slot_local")
                end
                SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), player.userid,
                    _BuildTargetInfo(target_userid, (target_name or "???"), new_rev), items_str or "CAP:15:body,hands,head:0|")
                return
            end
            _RequestOfflineInventoryFromShards(player.userid, target_userid)
            return
        end
        local prefab = cursor_item.prefab
        local count = 1
        if cursor_item.components and cursor_item.components.stackable then
            count = cursor_item.components.stackable:StackSize() or 1
        end
        local data = player.userid .. "|" .. target_userid .. "|" .. slot_type .. "|" .. slot_key .. "|" .. prefab .. "|" .. tostring(count)
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminGiveToSlot"), nil, data)
        end)
    end
end)

-- Shard RPC：其他世界收到给予请求
-- data_str: admin_userid|target_userid|prefab|count
AddShardModRPCHandler("DstAdmin", "ShardAdminGiveItem", function(shard_id, data_str)
    local admin_userid, target_userid, prefab, count_str = tostring(data_str or ""):match("^([^|]+)|([^|]+)|([^|]+)|(.+)$")
    if not admin_userid or not target_userid or not prefab then return end
    local count = GLOBAL.tonumber(count_str) or 1
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then
            local accepted = select(1, GiveItemToPlayer(p, prefab, count)) or 0
            local give_resp = admin_userid .. "|" .. prefab .. "|" .. tostring(accepted)
            GLOBAL.TheWorld:DoTaskInTime(0, function()
                GLOBAL.pcall(function()
                    SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminGiveItemResponse"), shard_id, give_resp)
                end)
            end)
            GLOBAL.TheWorld:DoTaskInTime(0.08, function()
                if not p or (p.IsValid and not p:IsValid()) then return end
                local target_name = p.name or "???"
                local items_str = CollectInventory(p)
                local inv_resp = admin_userid .. "|" .. target_userid .. "|" .. target_name .. "|" .. items_str
                GLOBAL.pcall(function()
                    SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardInventoryResponse"), shard_id, inv_resp)
                end)
            end)
            return
        end
    end
end)

-- Shard RPC：管理员世界收到跨世界“快速整组转移”结果，按实际放入数量扣减光标
-- data_str: admin_userid|prefab|accepted
AddShardModRPCHandler("DstAdmin", "ShardAdminGiveItemResponse", function(shard_id, data_str)
    local admin_userid, prefab, accepted_str = tostring(data_str or ""):match("^([^|]+)|([^|]+)|(.+)$")
    if not admin_userid or not prefab then return end
    local accepted = GLOBAL.tonumber(accepted_str) or 0
    if accepted <= 0 then return end
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == admin_userid and p.components and p.components.inventory then
            local inv = p.components.inventory
            local cursor = inv:GetActiveItem()
            if not cursor or cursor.prefab ~= prefab then return end
            local cur_count = 1
            if cursor.components and cursor.components.stackable then
                cur_count = cursor.components.stackable:StackSize() or 1
            end
            local used = math.min(cur_count, accepted)
            if used >= cur_count then
                inv:SetActiveItem(nil)
                if cursor:IsValid() then cursor:Remove() end
            else
                if cursor.components and cursor.components.stackable then
                    cursor.components.stackable:SetStackSize(cur_count - used)
                end
            end
            return
        end
    end
end)

-- Shard RPC：离线快照给予（跨世界）
-- data_str: owner_sid|admin_userid|target_userid|prefab|count
AddShardModRPCHandler("DstAdmin", "ShardOfflineGiveItem", function(shard_id, data_str)
    local source_sid = tostring(shard_id or "")
    local req_id, legacy_payload, is_reliable = _DecodeReliablePayload(data_str)
    if is_reliable and _HasSeenReliableReq("ShardOfflineGiveItem", source_sid, req_id) then
        _SendOfflineOpAck(source_sid, req_id)
        return
    end
    local owner_sid, admin_userid, target_userid, prefab, count_str = tostring(legacy_payload or data_str or ""):match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.+)$")
    if not admin_userid or not target_userid or not prefab then return end
    if not owner_sid or owner_sid == "" then return end
    if owner_sid ~= _GetLocalShardId() then return end
    if is_reliable then
        _MarkSeenReliableReq("ShardOfflineGiveItem", source_sid, req_id)
    end
    if _IsOnlineByUserid(target_userid) then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    if not GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSnapshot then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    local count = GLOBAL.tonumber(count_str) or 1
    local ok_local, target_name, items_str, new_rev = GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSnapshot(target_userid, prefab, count, admin_userid)
    if not ok_local then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    _MirrorOfflinePending(target_userid, prefab, count, "", 0, admin_userid)
    local inv_resp = admin_userid .. "|" .. target_userid .. "|" .. (target_name or "???") .. "|" .. tostring(new_rev or 0) .. "|" .. (items_str or "CAP:15:body,hands,head:0|")
    GLOBAL.TheWorld:DoTaskInTime(0, function()
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardInventoryResponse"), shard_id, inv_resp)
        end)
    end)
    _ForceSaveBothSides(tostring(shard_id or ""), "offline_give_stack_remote")
    if is_reliable then
        _SendOfflineOpAck(source_sid, req_id)
    end
end)

-- Shard RPC：指定格子放入/交换（目标世界处理）
-- data_str: admin_userid|target_userid|slot_type|slot_key|cursor_prefab|cursor_count
AddShardModRPCHandler("DstAdmin", "ShardAdminGiveToSlot", function(shard_id, data_str)
    local s = tostring(data_str or "")
    local admin_userid, target_userid, slot_type, slot_key, cursor_prefab, cursor_count_str =
        s:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.+)$")
    if not admin_userid or not cursor_prefab then return end
    local cursor_count = GLOBAL.tonumber(cursor_count_str) or 1

    local target = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == target_userid then target = p; break end
    end
    if not target then return end

    local inv = target.components and target.components.inventory
    if not inv then return end
    local container = nil
    local slot_num  = nil
    local current   = nil

    if slot_type == "I" then
        slot_num = GLOBAL.tonumber(slot_key)
        if not slot_num then return end
        container = inv
        current   = inv.itemslots[slot_num]
    elseif slot_type == "B" then
        local ok, overflow = GLOBAL.pcall(function() return inv:GetOverflowContainer() end)
        if not ok or not overflow then return end
        slot_num  = GLOBAL.tonumber(slot_key)
        if not slot_num then return end
        container = overflow
        current   = overflow.slots[slot_num]
    else
        return
    end

    local result_type  = "NC"
    local result_extra = ""

    if current and current.prefab == cursor_prefab
        and current.components and current.components.stackable then
        local cur_stack = current.components.stackable
        local max_size  = cur_stack.maxsize or 40
        local cur_size  = cur_stack:StackSize()
        local can_add   = max_size - cur_size

        if can_add <= 0 then
            result_type = "NC"
        elseif can_add >= cursor_count then
            cur_stack:SetStackSize(cur_size + cursor_count)
            result_type = "CL"
        else
            cur_stack:SetStackSize(max_size)
            result_type  = "PT"
            result_extra = tostring(cursor_count - can_add)
        end
    else
        local disp_prefab = nil
        local disp_count  = 0

        if current then
            disp_prefab = current.prefab
            disp_count  = 1
            if current.components and current.components.stackable then
                disp_count = current.components.stackable:StackSize() or 1
            end
            GLOBAL.pcall(function() container:RemoveItem(current, true) end)
            GLOBAL.pcall(function() current:Remove() end)
        end

        GLOBAL.pcall(function()
            local new_item = GLOBAL.SpawnPrefab(cursor_prefab)
            if new_item then
                if cursor_count > 1 and new_item.components and new_item.components.stackable then
                    new_item.components.stackable:SetStackSize(cursor_count)
                end
                container:GiveItem(new_item, slot_num)
            end
        end)

        if disp_prefab then
            result_type  = "SW"
            result_extra = disp_prefab .. ":" .. tostring(disp_count)
        else
            result_type = "CL"
        end
    end

    GLOBAL.TheWorld:DoTaskInTime(0.08, function()
        if not target or (target.IsValid and not target:IsValid()) then return end
        local target_name = target.name or "???"
        local items_str   = CollectInventory(target)
        local resp = admin_userid .. "|" .. target_userid .. "|" .. target_name
                  .. "|" .. result_type .. "|" .. result_extra .. "|" .. items_str
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminGiveToSlotResponse"), shard_id, resp)
        end)
    end)
end)

-- Shard RPC：离线快照指定格子放入/交换（跨世界）
-- data_str: owner_sid|admin_userid|target_userid|slot_type|slot_key|cursor_prefab|cursor_count
AddShardModRPCHandler("DstAdmin", "ShardOfflineGiveToSlot", function(shard_id, data_str)
    local source_sid = tostring(shard_id or "")
    local req_id, legacy_payload, is_reliable = _DecodeReliablePayload(data_str)
    if is_reliable and _HasSeenReliableReq("ShardOfflineGiveToSlot", source_sid, req_id) then
        _SendOfflineOpAck(source_sid, req_id)
        return
    end
    local s = tostring(legacy_payload or data_str or "")
    local owner_sid, admin_userid, target_userid, slot_type, slot_key, cursor_prefab, cursor_count_str =
        s:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|(.+)$")
    if not admin_userid or not target_userid or not cursor_prefab then return end
    if not owner_sid or owner_sid == "" then return end
    if owner_sid ~= _GetLocalShardId() then return end
    if is_reliable then
        _MarkSeenReliableReq("ShardOfflineGiveToSlot", source_sid, req_id)
    end
    if _IsOnlineByUserid(target_userid) then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    if not GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSlot then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    local cursor_count = GLOBAL.tonumber(cursor_count_str) or 1

    local result_type, result_extra, target_name, inventory_str, new_rev =
        GLOBAL.DSTADMIN_OFFLINE_STORE_GiveToSlot(target_userid, slot_type, slot_key, cursor_prefab, cursor_count, admin_userid)
    if not result_type then
        if is_reliable then _SendOfflineOpAck(source_sid, req_id) end
        return
    end
    if result_type == "CL" then
        _MirrorOfflinePending(target_userid, cursor_prefab, cursor_count, "", 0, admin_userid)
    elseif result_type == "PT" then
        local remain = GLOBAL.tonumber(result_extra) or 0
        local applied = math.max(0, cursor_count - remain)
        if applied > 0 then
            _MirrorOfflinePending(target_userid, cursor_prefab, applied, "", 0, admin_userid)
        end
    elseif result_type == "SW" then
        local disp_prefab, disp_count_str = tostring(result_extra or ""):match("^([^:]+):(.+)$")
        local disp_count = GLOBAL.tonumber(disp_count_str) or 1
        _MirrorOfflinePending(target_userid, cursor_prefab, cursor_count, disp_prefab, disp_count, admin_userid)
    end
    local resp = admin_userid .. "|" .. target_userid .. "|" .. (target_name or "???")
              .. "|" .. result_type .. "|" .. (result_extra or "") .. "|" .. tostring(new_rev or 0) .. "|" .. (inventory_str or "CAP:15:body,hands,head:0|")
    GLOBAL.TheWorld:DoTaskInTime(0, function()
        GLOBAL.pcall(function()
            SendModRPCToShard(GetShardModRPC("DstAdmin", "ShardAdminGiveToSlotResponse"), shard_id, resp)
        end)
    end)
    if result_type == "CL" or result_type == "PT" or result_type == "SW" then
        _ForceSaveBothSides(tostring(shard_id or ""), "offline_give_slot_remote")
    end
    if is_reliable then
        _SendOfflineOpAck(source_sid, req_id)
    end
end)

-- Shard RPC：结果回传至管理员世界，更新光标和 UI
-- resp: admin_userid|target_userid|target_name|result_type|result_extra|offline_rev|inventory_str
AddShardModRPCHandler("DstAdmin", "ShardAdminGiveToSlotResponse", function(shard_id, resp_str)
    local s = tostring(resp_str or "")
    -- 按顺序拆前6段，第7段 inventory_str 可含 |
    local parts = {}
    local pos = 1
    for _ = 1, 6 do
        local p = s:find("|", pos, true)
        if not p then return end
        table.insert(parts, s:sub(pos, p - 1))
        pos = p + 1
    end
    table.insert(parts, s:sub(pos))

    local admin_userid  = parts[1]
    local target_userid = parts[2]
    local target_name   = parts[3]
    local result_type   = parts[4]
    local result_extra  = parts[5]
    local offline_rev   = GLOBAL.tonumber(parts[6])
    local inventory_str = parts[7]

    local admin = nil
    for _, p in ipairs(GLOBAL.AllPlayers or {}) do
        if p and p.userid == admin_userid then admin = p; break end
    end
    if admin then
        local inv = admin.components and admin.components.inventory
        if inv then
            local cursor = inv:GetActiveItem()
            if result_type == "CL" then
                GLOBAL.pcall(function()
                    if cursor then
                        inv:SetActiveItem(nil)
                        cursor:Remove()
                    end
                end)
            elseif result_type == "PT" then
                local remaining = GLOBAL.tonumber(result_extra) or 0
                GLOBAL.pcall(function()
                    if cursor and cursor.components and cursor.components.stackable then
                        if remaining > 0 then
                            cursor.components.stackable:SetStackSize(remaining)
                        else
                            inv:SetActiveItem(nil)
                            cursor:Remove()
                        end
                    end
                end)
            elseif result_type == "SW" then
                local disp_prefab, disp_count_str = result_extra:match("^([^:]+):(.+)$")
                GLOBAL.pcall(function()
                    if cursor then
                        inv:SetActiveItem(nil)
                        cursor:Remove()
                    end
                end)
                if disp_prefab then
                    GLOBAL.pcall(function()
                        local disp_count = GLOBAL.tonumber(disp_count_str) or 1
                        local spawned = GLOBAL.SpawnPrefab(disp_prefab)
                        if spawned then
                            if disp_count > 1 and spawned.components and spawned.components.stackable then
                                spawned.components.stackable:SetStackSize(disp_count)
                            end
                            inv:GiveActiveItem(spawned)
                        end
                    end)
                end
            end
        end
    end

    GLOBAL.pcall(function()
        SendModRPCToClient(GetClientModRPC("DstAdmin", "ReceiveInventory"), admin_userid,
            _BuildTargetInfo(target_userid, target_name, offline_rev), inventory_str)
    end)
end)

AddClientModRPCHandler("DstAdmin", "ReceiveInventory", function(target_info, items_str)
    local target_userid, target_name, offline_rev
    local is_offline_snapshot = false
    if type(target_info) == "string" then
        local p = target_info:find("|", 1, true)
        if p then
            target_userid = target_info:sub(1, p - 1)
            local rest = target_info:sub(p + 1)
            local p2 = rest:find("|", 1, true)
            if p2 then
                target_name = rest:sub(1, p2 - 1)
                offline_rev = GLOBAL.tonumber(rest:sub(p2 + 1))
                is_offline_snapshot = (offline_rev ~= nil)
            else
                target_name = rest
            end
        else
            target_userid = ""
            target_name = target_info
        end
    else
        target_userid = ""
        target_name = "???"
    end


    local _now_az = (GLOBAL.GetTime and GLOBAL.GetTime()) or 0
    local allow_bp_zero = false
    if target_userid and target_userid:sub(1, 4) == "npc:" then
        local az = _rawget(GLOBAL, "DSTADMIN_ALLOW_BP_ZERO")
        if type(az) == "table" and az[target_userid] and _now_az < az[target_userid] then
            allow_bp_zero = true
        end
    end

    if not is_offline_snapshot and type(items_str) == "string" and target_userid and target_userid ~= "" then
        local cache = _rawget(GLOBAL, "DSTADMIN_ONLINE_INV_CACHE")
        if type(cache) ~= "table" then
            cache = {}
            _rawset(GLOBAL, "DSTADMIN_ONLINE_INV_CACHE", cache)
        end
        local now = (GLOBAL.GetTime and GLOBAL.GetTime()) or 0
        local cap_part = items_str:match("^CAP:([^|]*)|")
        local bp_slots = nil
        if cap_part then
            local _, _, bs = cap_part:match("^(%d+):([^:]*):(%d+)$")
            bp_slots = GLOBAL.tonumber(bs) or 0
        end
        local prev = cache[target_userid]
        if not allow_bp_zero and bp_slots ~= nil and bp_slots <= 0 and prev and (prev.bp_slots or 0) > 0 and (now - (prev.t or 0)) < 1.2 then
            return
        end
        cache[target_userid] = {
            t = now,
            bp_slots = bp_slots or 0,
        }
    end

    if target_userid and target_userid ~= "" and offline_rev ~= nil then
        local rev_map = _rawget(GLOBAL, "DSTADMIN_OFFLINE_REV_CACHE")
        if type(rev_map) ~= "table" then
            rev_map = {}
            _rawset(GLOBAL, "DSTADMIN_OFFLINE_REV_CACHE", rev_map)
        end
        local last = GLOBAL.tonumber(rev_map[target_userid]) or -1
        if offline_rev < last then
            return
        end
        if offline_rev > last then
            rev_map[target_userid] = offline_rev
        end
    end

    local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
    local sup = nil
    if hud then
        hud._dstadmin_ui_suppress = hud._dstadmin_ui_suppress or {}
        sup = hud._dstadmin_ui_suppress
    end
    if sup then
        local now = GLOBAL.GetTime and GLOBAL.GetTime() or 0
        if sup.item_until and now < sup.item_until then
            if (sup.item_target_userid or "") == "" or sup.item_target_userid == (target_userid or "") then
                return
            end
        end
    end

    local equips, invitems, backpack = {}, {}, {}
    local cap_info = {inv_maxslots = 15, equip_slots = {"body", "hands", "head"}, bp_numslots = 0}

    local actual_items_str = items_str or ""
    if type(items_str) == "string" then
        local cap_part, rest = items_str:match("^CAP:([^|]*)|(.*)$")
        if cap_part then
            actual_items_str = rest or ""
            local ms, es, bs = cap_part:match("^(%d+):([^:]*):(%d+)$")
            if ms then cap_info.inv_maxslots = GLOBAL.tonumber(ms) or 15 end
            if bs then cap_info.bp_numslots = GLOBAL.tonumber(bs) or 0 end
            if es and es ~= "" then
                cap_info.equip_slots = {}
                for s in es:gmatch("[^,]+") do
                    table.insert(cap_info.equip_slots, s)
                end
            end
        end
    end

    if not is_offline_snapshot and target_userid and target_userid ~= "" then
        local cap_cache = _rawget(GLOBAL, "DSTADMIN_ONLINE_CAP_STICKY")
        if type(cap_cache) ~= "table" then
            cap_cache = {}
            _rawset(GLOBAL, "DSTADMIN_ONLINE_CAP_STICKY", cap_cache)
        end
        local prev = cap_cache[target_userid]
        local function _CloneArray(arr)
            local out = {}
            for i = 1, #(arr or {}) do out[i] = arr[i] end
            return out
        end
        local function _Contains(arr, v)
            for i = 1, #(arr or {}) do
                if arr[i] == v then return true end
            end
            return false
        end
        local function _IsSubset(sub, sup)
            for i = 1, #(sub or {}) do
                if not _Contains(sup, sub[i]) then return false end
            end
            return true
        end
        if cap_info.bp_numslots and cap_info.bp_numslots > 0 then
            cap_cache[target_userid] = {
                bp_numslots = cap_info.bp_numslots,
                equip_slots = _CloneArray(cap_info.equip_slots),
            }
        elseif not allow_bp_zero and prev and (prev.bp_numslots or 0) > 0 then
            cap_info.bp_numslots = prev.bp_numslots
            if (not cap_info.equip_slots or #cap_info.equip_slots == 0) and prev.equip_slots then
                cap_info.equip_slots = _CloneArray(prev.equip_slots)
            end
        end

        if prev and prev.equip_slots and #prev.equip_slots > 0 then
            local cur = cap_info.equip_slots or {}
            if not _IsSubset(prev.equip_slots, cur) then
                cap_info.equip_slots = _CloneArray(prev.equip_slots)
            end
        end
        cap_cache[target_userid] = cap_cache[target_userid] or {}
        cap_cache[target_userid].equip_slots = _CloneArray(cap_info.equip_slots or {})
        cap_cache[target_userid].bp_numslots = cap_info.bp_numslots or 0
    end

    if allow_bp_zero and (cap_info.bp_numslots or 0) <= 0 then
        local az = _rawget(GLOBAL, "DSTADMIN_ALLOW_BP_ZERO")
        if type(az) == "table" then az[target_userid] = nil end
    end

    if type(actual_items_str) == "string" and actual_items_str ~= "" then
        for entry in actual_items_str:gmatch("[^,]+") do
            local tag, slot_key, prefab, count, uflag, image, atlas = entry:match("^(.):([^:]+):([^:]+):(%d+):?(%d?):?([^:]*):?(.*)$")
            if prefab then
                local display_name = prefab
                if GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES then
                    display_name = GLOBAL.STRINGS.NAMES[string.upper(prefab)] or prefab
                end
                local item = {
                    prefab = prefab,
                    name = display_name,
                    count = GLOBAL.tonumber(count) or 1,
                    slot_key = slot_key,
                    slot_type = tag,
                    untakeable = (uflag == "1"),
                    image = image ~= "" and image or nil,
                    atlas = atlas ~= "" and atlas or nil,
                }
                if tag == "E" then
                    table.insert(equips, item)
                elseif tag == "B" then
                    table.insert(backpack, item)
                else
                    table.insert(invitems, item)
                end
            end
        end
    end

    GLOBAL.pcall(function()
        local fe = GLOBAL.TheFrontEnd
        for i = #fe.screenstack, 1, -1 do
            if fe.screenstack[i] and fe.screenstack[i].name == "AdminPanelScreen" then
                fe:PopScreen(fe.screenstack[i])
                break
            end
        end
    end)

    if hud and hud.controls and hud.controls.containerroot then
        if hud._npc_status_widget then
            local old_owner = hud._npc_status_widget.owner_param
            if sup then
                sup.npc_until = (GLOBAL.GetTime() or 0) + 0.8
                sup.npc_owner_param = old_owner
            end
            hud._npc_status_widget:Kill()
            hud._npc_status_widget = nil
        end
        if hud.dst_admin_itemview then
            hud.dst_admin_itemview:Kill()
            hud.dst_admin_itemview = nil
        end
        local widget = ItemViewScreen(
            equips, invitems, backpack,
            GLOBAL.tostring(target_name or "???"),
            GLOBAL.tostring(target_userid or ""),
            cap_info,
            is_offline_snapshot
        )
        hud.dst_admin_itemview = widget
        _AttachHudWidgetToTopRoot(hud, widget, 300, 100)
    end
end)

AddClientModRPCHandler("DstAdmin", "PlayNPCQuickStoreSound", function()
    GLOBAL.pcall(function()
        local emitter = GLOBAL.TheFocalPoint and GLOBAL.TheFocalPoint.SoundEmitter
        if emitter ~= nil then
            emitter:PlaySound("dontstarve/HUD/click_move")
        end
    end)
end)

-- 客户端处理：接收远程玩家三维属性，更新管理员面板
AddClientModRPCHandler("DstAdmin", "ReceiveStats", function(stats_str)
    if type(stats_str) ~= "string" or stats_str == "" then return end
    local screen = nil
    GLOBAL.pcall(function()
        local fe = GLOBAL.TheFrontEnd
        for i = #fe.screenstack, 1, -1 do
            if fe.screenstack[i] and fe.screenstack[i].name == "AdminPanelScreen" then
                screen = fe.screenstack[i]
                break
            end
        end
    end)
    if not screen or not screen.stat_refs then return end

    -- 解析 "userid:hp:hu:sa:ghost,userid:hp:hu:sa:ghost,..."
    for entry in stats_str:gmatch("[^,]+") do
        local uid, hp, hu, sa, ghost_flag = entry:match("^([^:]+):([^:]+):([^:]+):([^:]+):?(%d?)$")
        if uid and screen.stat_refs[uid] then
            local is_ghost = (ghost_flag == "1")

            if is_ghost then
                screen.stat_refs[uid]:SetString(T("status_ghost"))
                screen.stat_refs[uid]:SetColour(0.6, 0.6, 0.9, 1)
            else
                local stat_str = (hp or "--") .. "/" .. (hu or "--") .. "/" .. (sa or "--")
                screen.stat_refs[uid]:SetString(stat_str)
                screen.stat_refs[uid]:SetColour(1, 1, 1, 1)
            end

            if screen.badge_refs and screen.badge_refs[uid] then
                local bdata = screen.badge_refs[uid]
                if bdata.widget then bdata.widget:Kill() end
                local flags = is_ghost and 1 or 0
                local new_badge = bdata.parent:AddChild(PlayerBadge(bdata.prefab, bdata.colour, false, flags))
                new_badge:SetScale(0.65)
                new_badge:SetPosition(-440, 0)
                bdata.widget = new_badge
            end

            if screen.respawn_refs and screen.respawn_refs[uid] then
                local allow_hp_revive = true
                if GLOBAL.rawget ~= nil then
                    allow_hp_revive = GLOBAL.rawget(GLOBAL, "DSTADMIN_ALLOW_ADMIN_HP_REVIVE") ~= false
                else
                    local ok_cfg, cfg = GLOBAL.pcall(function() return GLOBAL.DSTADMIN_ALLOW_ADMIN_HP_REVIVE end)
                    allow_hp_revive = (ok_cfg and cfg ~= false)
                end
                if not allow_hp_revive then
                    screen.respawn_refs[uid]:Disable()
                elseif is_ghost then
                    screen.respawn_refs[uid]:Enable()
                else
                    screen.respawn_refs[uid]:Disable()
                end
            end
        end
    end
end)

-- 客户端处理：接收离线玩家列表
AddClientModRPCHandler("DstAdmin", "ReceiveOfflinePlayers", function(payload)
    local records = {}
    local parse_fn = _rawget(GLOBAL, "DSTADMIN_OFFLINE_STORE_ParseListSerialized")
    if parse_fn then
        records = parse_fn(payload or "")
    end
    _rawset(GLOBAL, "DSTADMIN_OFFLINE_CLIENT_CACHE", records or {})

    local screen = nil
    GLOBAL.pcall(function()
        local fe = GLOBAL.TheFrontEnd
        for i = #fe.screenstack, 1, -1 do
            if fe.screenstack[i] and fe.screenstack[i].name == "AdminPanelScreen" then
                screen = fe.screenstack[i]
                break
            end
        end
    end)
    if screen and screen.SetOfflineRecords then
        screen:SetOfflineRecords(_rawget(GLOBAL, "DSTADMIN_OFFLINE_CLIENT_CACHE") or {})
    end
end)

-- 客户端处理：接收 NPC 列表
AddClientModRPCHandler("DstAdmin", "ReceiveNPCPlayers", function(payload)
    local records = {}
    local s = tostring(payload or "")
    if s ~= "" then
        for line in s:gmatch("[^\n]+") do
            local seg = {}
            for p in line:gmatch("[^\t]+") do
                seg[#seg + 1] = p
            end
            if #seg >= 6 then
                local guid = GLOBAL.tonumber(seg[1]) or 0
                local owner_param = tostring(seg[2] or "")
                local name = tostring(seg[3] or "NPC")
                local prefab = tostring(seg[4] or "npc")
                local is_ghost = tostring(seg[5] or "0") == "1"
                local is_hostile = tostring(seg[6] or "0") == "1"
                local uid = "npc:" .. owner_param .. ":" .. tostring(guid)
                table.insert(records, {
                    userid = uid,
                    name = name,
                    prefab = prefab,
                    userflags = is_ghost and 1 or 0,
                    _npc = true,
                    _owner_param = owner_param,
                    _guid = guid,
                    _ghost = is_ghost,
                    _hostile = is_hostile,
                })
            end
        end
    end
    _rawset(GLOBAL, "DSTADMIN_NPC_CLIENT_CACHE", records)

    local screen = nil
    GLOBAL.pcall(function()
        local fe = GLOBAL.TheFrontEnd
        for i = #fe.screenstack, 1, -1 do
            if fe.screenstack[i] and fe.screenstack[i].name == "AdminPanelScreen" then
                screen = fe.screenstack[i]
                break
            end
        end
    end)
    if screen and screen.SetNPCRecords then
        screen:SetNPCRecords(_rawget(GLOBAL, "DSTADMIN_NPC_CLIENT_CACHE") or {})
    end
end)

-- 客户端处理：接收 NPC 状态数据，创建或更新状态面板
-- data_str 格式:
-- "owner_param|display_name|char_type|hp_cur:hp_max|hu_cur:hu_max|sa_cur:sa_max|is_following|leader_name|abilities_str|work_enabled|work_range|work_center"
AddClientModRPCHandler("DstAdmin", "ReceiveNPCStatus", function(data_str)
    if type(data_str) ~= "string" or data_str == "" then return end

    local parts = {}
    for seg in data_str:gmatch("[^|]+") do
        table.insert(parts, seg)
    end
    -- 老版本可能缺少后缀字段，保持向后兼容（至少 8 段）
    if #parts < 8 then return end

    local owner_param = parts[1]
    local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
    local sup = nil
    if hud then
        hud._dstadmin_ui_suppress = hud._dstadmin_ui_suppress or {}
        sup = hud._dstadmin_ui_suppress
    end
    if sup then
        local now = GLOBAL.GetTime and GLOBAL.GetTime() or 0
        if sup.npc_until and now < sup.npc_until then
            if (sup.npc_owner_param or "") == "" or sup.npc_owner_param == owner_param then
                return
            end
        end
    end

    local display_name = parts[2]
    local char_type = parts[3]

    local hp_cur, hp_max = 0, 0
    if parts[4] then
        hp_cur, hp_max = parts[4]:match("^(%d+):(%d+)$")
        hp_cur = GLOBAL.tonumber(hp_cur) or 0
        hp_max = GLOBAL.tonumber(hp_max) or 0
    end

    local hu_cur, hu_max = 0, 0
    if parts[5] then
        hu_cur, hu_max = parts[5]:match("^(%d+):(%d+)$")
        hu_cur = GLOBAL.tonumber(hu_cur) or 0
        hu_max = GLOBAL.tonumber(hu_max) or 0
    end

    local sa_cur, sa_max = 0, 0
    if parts[6] then
        sa_cur, sa_max = parts[6]:match("^(%d+):(%d+)$")
        sa_cur = GLOBAL.tonumber(sa_cur) or 0
        sa_max = GLOBAL.tonumber(sa_max) or 0
    end

    local is_following = (parts[7] == "1")

    local leader_name = parts[8] or "none"
    if leader_name == "none" then leader_name = "" end

    -- 格式: "ability_id:active:label_key:command[:reason],..."
    local abilities = {}
    if parts[9] and parts[9] ~= "" then
        for entry in parts[9]:gmatch("[^,]+") do
            local id, active_str, label_key, command, reason = entry:match("^([^:]+):([^:]+):([^:]+):([^:]+):?(.*)$")
            if id then
                table.insert(abilities, {
                    id = id,
                    active = (active_str == "1"),
                    label_key = label_key,
                    command = command,
                    reason = reason or "",
                })
            end
        end
    end

    local work_enabled = (parts[10] == "1")
    local work_range = GLOBAL.tonumber(parts[11]) or 0
    local work_center_x, work_center_z = nil, nil
    if parts[12] and parts[12] ~= "" and parts[12] ~= "none" then
        local cx, cz = parts[12]:match("^([%-]?%d+%.?%d*):([%-]?%d+%.?%d*)$")
        work_center_x = GLOBAL.tonumber(cx)
        work_center_z = GLOBAL.tonumber(cz)
    end

    -- 厨师专用：最大同食物数量（parts[13]，仅 warly）
    local cook_same_dish_max = nil
    if parts[13] then
        cook_same_dish_max = GLOBAL.tonumber(parts[13])
    end
    -- Wilson 专用：最大钓鱼次数（parts[13]，仅 wilson）
    local fishing_max_catch = nil
    if parts[13] and char_type == "wilson" then
        fishing_max_catch = GLOBAL.tonumber(parts[13])
    end
    -- Wilson 专用：钓鱼存放点坐标（parts[14]、parts[15]，仅 wilson）
    local fishing_deposit_x = nil
    local fishing_deposit_z = nil
    if char_type == "wilson" then
        if parts[14] then fishing_deposit_x = GLOBAL.tonumber(parts[14]) or 0 end
        if parts[15] then fishing_deposit_z = GLOBAL.tonumber(parts[15]) or 0 end
    end
    -- 温蒂专用：海钓最大捕获次数（parts[13]，仅 wendy）
    local ocean_fishing_max_catch = nil
    if parts[13] and char_type == "wendy" then
        ocean_fishing_max_catch = GLOBAL.tonumber(parts[13])
    end
    -- 温蒂专用：海钓存放点坐标（parts[14]、parts[15]，仅 wendy）
    local ocean_fishing_deposit_x = nil
    local ocean_fishing_deposit_z = nil
    if char_type == "wendy" then
        if parts[14] then ocean_fishing_deposit_x = GLOBAL.tonumber(parts[14]) or 0 end
        if parts[15] then ocean_fishing_deposit_z = GLOBAL.tonumber(parts[15]) or 0 end
    end
    -- 温蒂专用：杀鱼开关状态（parts[16]，仅 wendy）
    local ocean_fishing_murder_fish = nil
    if char_type == "wendy" and parts[16] then
        ocean_fishing_murder_fish = (parts[16] == "1")
    end
    -- 植物人专用：作物存放点 + 垃圾存放点
    local wormwood_crop_deposit_x = nil
    local wormwood_crop_deposit_z = nil
    local wormwood_trash_deposit_x = nil
    local wormwood_trash_deposit_z = nil
    if char_type == "wormwood" then
        if parts[13] then wormwood_crop_deposit_x = GLOBAL.tonumber(parts[13]) or 0 end
        if parts[14] then wormwood_crop_deposit_z = GLOBAL.tonumber(parts[14]) or 0 end
        if parts[15] then wormwood_trash_deposit_x = GLOBAL.tonumber(parts[15]) or 0 end
        if parts[16] then wormwood_trash_deposit_z = GLOBAL.tonumber(parts[16]) or 0 end
    end
    -- wes/winona/warly 共享：整理范围
    -- warly: parts[14]（因为 parts[13] 是 cook_same_dish_max）
    -- wes/winona: parts[13]
    local organize_range = nil
    if char_type == "warly" and parts[14] then
        organize_range = GLOBAL.tonumber(parts[14])
    elseif (char_type == "wes" or char_type == "winona") and parts[13] then
        organize_range = GLOBAL.tonumber(parts[13])
    end
    local collect_organize_enabled = nil
    if (char_type == "wes" or char_type == "winona") and parts[14] then
        collect_organize_enabled = (parts[14] == "1")
    end

    -- 吴迪专用：砍树尺寸过滤（parts[13]，格式 "1:1:1" → small:medium:big）
    --           + 挖树根开关（parts[14]，0/1）
    --           + 砍多枝树开关（parts[15]，0/1）
    local chop_filter = nil
    local dig_stump = nil
    local chop_twiggy = nil
    if char_type == "woodie" then
        if parts[13] then
            local s, m, b = parts[13]:match("^([01]):([01]):([01])$")
            if s and m and b then
                chop_filter = {
                    small  = (s == "1"),
                    medium = (m == "1"),
                    big    = (b == "1"),
                }
            end
        end
        if parts[14] then
            dig_stump = (parts[14] == "1")
        end
        if parts[15] then
            chop_twiggy = (parts[15] == "1")
        end
    end
    local tts_volume = nil
    -- NPC 当前皮肤（key=value 后缀，供换衣界面回显）
    local npc_skins = nil
    -- 好感度（key=value 后缀，cur:max）
    local affinity_cur, affinity_max = 0, 400
    for i = 13, #parts do
        local seg = parts[i]
        if seg then
            local vol = seg:match("^ttsvol=(.+)$")
            local aff = seg:match("^affinity=(.+)$")
            if vol then
                tts_volume = GLOBAL.tonumber(vol)
            elseif aff then
                local ac, am = aff:match("^(%-?%d+):(%-?%d+)$")
                affinity_cur = GLOBAL.tonumber(ac) or 0
                affinity_max = GLOBAL.tonumber(am) or 400
            else
                local skey, sval = seg:match("^(skin%a+)=(.+)$")
                if skey then
                    npc_skins = npc_skins or {}
                    if     skey == "skinbase" then npc_skins.base = sval
                    elseif skey == "skinbody" then npc_skins.body = sval
                    elseif skey == "skinhand" then npc_skins.hand = sval
                    elseif skey == "skinlegs" then npc_skins.legs = sval
                    elseif skey == "skinfeet" then npc_skins.feet = sval
                    end
                end
            end
        end
    end
    local data = {
        char_type = char_type,
        display_name = display_name,
        hp_cur = hp_cur, hp_max = hp_max,
        hu_cur = hu_cur, hu_max = hu_max,
        sa_cur = sa_cur, sa_max = sa_max,
        is_following = is_following,
        leader_name = leader_name,
        abilities = abilities,
        work_enabled = work_enabled,
        work_range = work_range,
        work_center_x = work_center_x,
        work_center_z = work_center_z,
        cook_same_dish_max = cook_same_dish_max,
        fishing_max_catch = fishing_max_catch,
        fishing_deposit_x = fishing_deposit_x,
        fishing_deposit_z = fishing_deposit_z,
        ocean_fishing_max_catch = ocean_fishing_max_catch,
        ocean_fishing_deposit_x = ocean_fishing_deposit_x,
        ocean_fishing_deposit_z = ocean_fishing_deposit_z,
        ocean_fishing_murder_fish = ocean_fishing_murder_fish,
        wormwood_crop_deposit_x = wormwood_crop_deposit_x,
        wormwood_crop_deposit_z = wormwood_crop_deposit_z,
        wormwood_trash_deposit_x = wormwood_trash_deposit_x,
        wormwood_trash_deposit_z = wormwood_trash_deposit_z,
        organize_range = organize_range,
        collect_organize_enabled = collect_organize_enabled,
        chop_filter = chop_filter,
        dig_stump = dig_stump,
        chop_twiggy = chop_twiggy,
        tts_volume = tts_volume,
        npc_skins = npc_skins,
        affinity_cur = affinity_cur,
        affinity_max = affinity_max,
    }

    -- 好感度介绍界面打开时：仅刷新数值，保持状态面板隐藏，避免重建/覆盖介绍界面
    if hud and hud._npc_affinity_open then
        if hud._npc_affinity_widget and hud._npc_affinity_widget.owner_param == owner_param
            and hud._npc_affinity_widget.UpdateData then
            hud._npc_affinity_widget:UpdateData(data)
        end
        if hud._npc_status_widget and hud._npc_status_widget.owner_param == owner_param then
            if hud._npc_status_widget.UpdateData then
                hud._npc_status_widget:UpdateData(data)
            end
            hud._npc_status_widget:Hide()
        end
        return
    end

    if hud and hud.controls and hud.controls.containerroot then
        if hud.dst_admin_itemview then
            local old_target = hud.dst_admin_itemview.target_userid
            if sup then
                sup.item_until = (GLOBAL.GetTime() or 0) + 0.8
                sup.item_target_userid = old_target or ""
            end
            hud.dst_admin_itemview:Kill()
            hud.dst_admin_itemview = nil
        end
        if hud._npc_status_widget and hud._npc_status_widget.owner_param == owner_param then
            hud._npc_status_widget:UpdateData(data)
        else
            if hud._npc_status_widget then
                hud._npc_status_widget:Kill()
                hud._npc_status_widget = nil
            end
            local widget = NpcStatusScreen(data, owner_param)
            hud._npc_status_widget = widget
            _AttachHudWidgetToTopRoot(hud, widget, 300, 100)
        end
    end
end)
