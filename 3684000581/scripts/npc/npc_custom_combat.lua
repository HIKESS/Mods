-- scripts/npc/npc_custom_combat.lua

local Settings = require("npc_combat_settings")
local NPC_TUNING = require("npc_tuning")

local M = {}

local default_values = Settings.GetDefaultSettings()
local values_by_userid = {}

local function GetSubjectUserid(subject)
    if type(subject) == "string" and subject ~= "" then
        return subject
    end
    if type(subject) ~= "table" then
        return nil
    end
    -- 玩家自己
    if type(subject.userid) == "string" and subject.userid ~= "" then
        return subject.userid
    end
    -- NPC 的持久化 owner（招募时写入，存档跨上下线保留，先于 follower.leader 检查
    -- 避免上下线后 follower 还未重新挂上时 NPC 被误判为"无主"，导致读到默认设置）
    if type(subject._owner_userid) == "string" and subject._owner_userid ~= "" then
        return subject._owner_userid
    end
    if subject.owner_userid ~= nil and type(subject.owner_userid.value) == "function" then
        local ok, v = pcall(function() return subject.owner_userid:value() end)
        if ok and type(v) == "string" and v ~= "" then
            return v
        end
    end
    -- 兜底：当前实际跟随的 leader
    local follower = subject.components ~= nil and subject.components.follower or nil
    local leader = follower ~= nil and follower.leader or nil
    if leader ~= nil and type(leader.userid) == "string" and leader.userid ~= "" then
        return leader.userid
    end
    return nil
end

local function GetValues(subject)
    local userid = GetSubjectUserid(subject)
    if userid == nil then
        return default_values
    end
    return values_by_userid[userid] or default_values
end

local function EnsureValues(subject)
    local userid = GetSubjectUserid(subject)
    if userid == nil then
        return nil, nil
    end
    values_by_userid[userid] = Settings.NormalizeSettings(values_by_userid[userid] or default_values)
    return userid, values_by_userid[userid]
end

local function GetPersistentKey(userid)
    if userid == nil or userid == "" then
        return nil
    end
    return Settings.PERSIST_KEY .. "_" .. tostring(userid):gsub("[^%w_%-]", "_")
end

local function DebugLog(inst, tag, message, interval)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_COMBAT) then
        return
    end
    interval = interval or 1
    local now = (_G.GetTime ~= nil and _G.GetTime()) or 0
    if inst ~= nil then
        inst._npcfriends_combat_debug_next = inst._npcfriends_combat_debug_next or {}
        local next_time = inst._npcfriends_combat_debug_next[tag] or 0
        if now < next_time then
            return
        end
        inst._npcfriends_combat_debug_next[tag] = now + interval
    end
    print("[NPCFriends][CombatReturn][" .. tostring(tag) .. "] " .. tostring(message))
end

local function GetDebugName(ent)
    if ent == nil then
        return "nil"
    end
    return tostring(ent.prefab or "unknown") .. "#" .. tostring(ent.GUID or "?")
end

local function GetReturnLockUntil(inst)
    return inst ~= nil and inst._npcfriends_return_to_leader_until or nil
end

function M.IsReturningToLeader(inst)
    local until_time = GetReturnLockUntil(inst)
    if until_time == nil then
        return false
    end
    local now = (_G.GetTime ~= nil and _G.GetTime()) or 0
    if now >= until_time then
        inst._npcfriends_return_to_leader_until = nil
        return false
    end
    return true
end

local function IsFriendlyNPC(inst)
    return inst ~= nil
        and inst:IsValid()
        and inst:HasTag("npcfriend")
        and not inst:HasTag("npc_hostile")
        and not inst:HasTag("npc_no_ui")
end

local function ForEachFriendlyNPC(fn)
    if _G.Ents == nil then return end
    for _, ent in pairs(_G.Ents) do
        if IsFriendlyNPC(ent) then
            fn(ent)
        end
    end
end

local function RefreshExistingNPCs()
    ForEachFriendlyNPC(function(npc)
        if npc.components ~= nil and npc.components.combat ~= nil then
            if npc._npcfriends_retarget_fn ~= nil then
                npc.components.combat:SetRetargetFunction(M.GetNumber("retarget_interval", NPC_TUNING.RETARGET_INTERVAL, npc), npc._npcfriends_retarget_fn)
            end
            if npc._npcfriends_keeptarget_fn ~= nil then
                npc.components.combat:SetKeepTargetFunction(npc._npcfriends_keeptarget_fn)
            end
            if M.ShouldSuppressCombat(npc) then
                M.StopCombat(npc)
            end
        end
        if npc._is_ghost_mode then
            local ok, npc_ghost = _G.pcall(require, "npc/npc_ghost")
            if ok and npc_ghost ~= nil and npc_ghost.StartAmuletSearch ~= nil then
                npc_ghost.StartAmuletSearch(npc)
            end
        end
    end)
end

function M.GetSettings(subject)
    return Settings.NormalizeSettings(GetValues(subject))
end

function M.Encode(subject)
    return Settings.Encode(GetValues(subject))
end

function M.ApplyEncoded(subject, data)
    local userid = GetSubjectUserid(subject)
    if userid == nil then
        return M.GetSettings(subject)
    end
    values_by_userid[userid] = Settings.Decode(data)
    RefreshExistingNPCs()
    return M.GetSettings(userid)
end

function M.SetValue(subject, key, value)
    local normalized = Settings.NormalizeValue(key, value)
    if normalized == nil then
        return false
    end
    local _, values = EnsureValues(subject)
    if values == nil then
        return false
    end
    values[key] = normalized
    values_by_userid[GetSubjectUserid(subject)] = Settings.NormalizeSettings(values)
    RefreshExistingNPCs()
    return true
end

function M.Reset(subject)
    local userid = GetSubjectUserid(subject)
    if userid ~= nil then
        values_by_userid[userid] = Settings.GetDefaultSettings()
    end
    RefreshExistingNPCs()
end

function M.GetValue(key, subject)
    local def = Settings.DEFS_BY_KEY[key]
    if def == nil then
        return nil
    end
    local values = GetValues(subject)
    if key ~= "auto_combat_enabled" and values.auto_combat_enabled == true then
        return def.default
    end
    return values[key]
end

function M.IsAutoCombatEnabled(subject)
    return GetValues(subject).auto_combat_enabled == true
end

function M.IsCustomMode(subject)
    return GetValues(subject).auto_combat_enabled ~= true
end

function M.IsEnabled(key, subject)
    return M.GetValue(key, subject) == true
end

-- 镜像跟随玩家攻击：自动战斗关闭 + 自定义开关开启时生效
function M.IsMirrorLeaderEnabled(subject)
    return M.IsCustomMode(subject) and M.GetValue("mirror_leader_combat", subject) == true
end

function M.ShouldSuppressCombat(inst)
    if not IsFriendlyNPC(inst) then
        return false
    end
    return M.IsReturningToLeader(inst)
        or (M.IsCustomMode(inst) and M.GetValue("stop_attack", inst) == true)
end

-- 镜像模式下：assist_leader 视为强制开启（合并语义到镜像功能里），
--             供 npc_combat.Retarget 的 leader 目标分支正常运转
function M.IsLeaderAssistEnabled(subject)
    if M.IsMirrorLeaderEnabled(subject) then
        return true
    end
    return not M.IsCustomMode(subject) or M.GetValue("assist_leader", subject) == true
end

-- 镜像模式下：互助逻辑禁用，避免抢走玩家目标
function M.IsNPCAssistEnabled(subject)
    if M.IsMirrorLeaderEnabled(subject) then
        return false
    end
    return not M.IsCustomMode(subject) or M.GetValue("assist_npcs", subject) == true
end

function M.IsAutoEquipEnabled(subject)
    return not M.IsCustomMode(subject) or M.GetValue("auto_equip_combat", subject) == true
end

function M.IsHealRetreatEnabled(subject)
    return not M.IsCustomMode(subject) or M.GetValue("auto_heal_retreat", subject) == true
end

-- 镜像模式下：闪避走位强制关闭，由 MirrorLeaderCombat 节点接管走位
function M.IsKiteEnabled(subject)
    if M.IsMirrorLeaderEnabled(subject) then
        return false
    end
    return not M.IsCustomMode(subject) or M.GetValue("kite_enabled", subject) == true
end

function M.GetNumber(key, fallback, subject)
    local value = M.GetValue(key, subject)
    return tonumber(value) or fallback
end

function M.GetString(key, fallback, subject)
    local value = M.GetValue(key, subject)
    if value == nil then
        return fallback
    end
    return tostring(value)
end

function M.StopCombat(inst)
    if inst == nil or not inst:IsValid() then return end
    if inst.components ~= nil and inst.components.combat ~= nil then
        inst.components.combat:SetTarget(nil)
        inst.components.combat:CancelAttack()
    end
    if inst.components ~= nil and inst.components.locomotor ~= nil then
        inst.components.locomotor:Stop()
    end
    if not inst:HasTag("notarget") then
        inst:AddTag("notarget")
    end
end

function M.StopAllFriendlyCombat(subject)
    local userid = GetSubjectUserid(subject)
    ForEachFriendlyNPC(function(npc)
        if userid == nil or GetSubjectUserid(npc) == userid then
            M.StopCombat(npc)
        end
    end)
end

function M.ShouldBreakForCombatReturn(inst)
    if not M.IsCustomMode(inst) then
        DebugLog(inst, "return_check_default", string.format("npc=%s custom=false", GetDebugName(inst)), 5)
        return false
    end
    if not IsFriendlyNPC(inst) then
        return false
    end
    local follower = inst.components ~= nil and inst.components.follower or nil
    local leader = follower ~= nil and follower.leader or nil
    if leader == nil or not leader:IsValid() then
        DebugLog(inst, "return_check_no_leader", string.format("npc=%s leader=nil custom=true", GetDebugName(inst)), 3)
        return false
    end
    local dist = M.GetNumber("max_leader_dist_in_combat", NPC_TUNING.KITE_MAX_LEADER_DIST or 18, inst)
    local dsq = inst:GetDistanceSqToInst(leader)
    local trigger = dsq >= dist * dist
    if trigger then
        DebugLog(inst, "return_check_trigger", string.format(
            "npc=%s leader=%s userid=%s cur=%.2f limit=%.2f dsq=%.2f",
            GetDebugName(inst),
            GetDebugName(leader),
            tostring(leader.userid),
            math.sqrt(dsq),
            dist,
            dsq
        ), 0.5)
    end
    return trigger
end

M.ShouldBreakForForceFollow = M.ShouldBreakForCombatReturn

function M.CanEngageTarget(inst, target)
    if not M.IsCustomMode(inst) then
        return true
    end
    if not IsFriendlyNPC(inst) then
        return true
    end
    if target == nil or not target:IsValid() then
        return false
    end
    local follower = inst.components ~= nil and inst.components.follower or nil
    local leader = follower ~= nil and follower.leader or nil
    if leader == nil or not leader:IsValid() then
        return true
    end
    local dist = M.GetNumber("max_leader_dist_in_combat", NPC_TUNING.KITE_MAX_LEADER_DIST or 18, inst)
    local target_dsq = target:GetDistanceSqToInst(leader)
    local can_engage = target_dsq < dist * dist
    if not can_engage then
        DebugLog(inst, "target_outside_return_radius", string.format(
            "npc=%s leader=%s target=%s userid=%s target_dist=%.2f limit=%.2f target_dsq=%.2f",
            GetDebugName(inst),
            GetDebugName(leader),
            GetDebugName(target),
            tostring(leader.userid),
            math.sqrt(target_dsq),
            dist,
            target_dsq
        ), 0.5)
    end
    return can_engage
end

function M.ReturnToLeader(inst, reason, blocked_target)
    if not IsFriendlyNPC(inst) then
        DebugLog(inst, "return_fail_not_friendly", string.format("npc=%s", GetDebugName(inst)), 3)
        return false
    end
    -- 镜像模式：走位由 MirrorLeaderCombat 行为节点管，不触发"回队锁"
    if M.IsMirrorLeaderEnabled(inst) then
        DebugLog(inst, "return_skip_mirror", string.format(
            "reason=%s npc=%s",
            tostring(reason or "unknown"),
            GetDebugName(inst)
        ), 1)
        return false
    end
    local follower = inst.components ~= nil and inst.components.follower or nil
    local leader = follower ~= nil and follower.leader or nil
    local loco = inst.components ~= nil and inst.components.locomotor or nil
    if leader == nil or not leader:IsValid() or loco == nil then
        DebugLog(inst, "return_fail_missing_data", string.format(
            "npc=%s leader=%s has_loco=%s",
            GetDebugName(inst),
            GetDebugName(leader),
            tostring(loco ~= nil)
        ), 1)
        return false
    end

    local lx, ly, lz = leader.Transform:GetWorldPosition()
    local ix, _, iz = inst.Transform:GetWorldPosition()
    local dx, dz = ix - lx, iz - lz
    local len = math.sqrt(dx * dx + dz * dz)
    local target_dist = M.GetNumber("follow_target", NPC_TUNING.FOLLOW_TARGET or 3, inst)
    local return_dist = M.GetNumber("max_leader_dist_in_combat", NPC_TUNING.KITE_MAX_LEADER_DIST or 18, inst)
    inst._npcfriends_return_blocked_target = blocked_target

    local function IsBlockedTargetOutside()
        local target = inst._npcfriends_return_blocked_target
        if target == nil or not target:IsValid() then
            return false
        end
        if leader == nil or not leader:IsValid() then
            return false
        end
        return target:GetDistanceSqToInst(leader) >= return_dist * return_dist
    end

    local function ClearCombat()
        if inst.components.combat ~= nil then
            inst.components.combat:SetTarget(nil)
            inst.components.combat:CancelAttack()
        end
        if not inst:HasTag("notarget") then
            inst:AddTag("notarget")
            inst._npcfriends_return_added_notarget = true
        end
    end

    local function StopReturnLock(done_reason)
        inst._npcfriends_return_to_leader_until = nil
        if inst._npcfriends_return_task ~= nil then
            inst._npcfriends_return_task:Cancel()
            inst._npcfriends_return_task = nil
        end
        if inst._npcfriends_return_added_notarget and inst:HasTag("notarget") then
            inst:RemoveTag("notarget")
        end
        inst._npcfriends_return_added_notarget = nil
        inst._npcfriends_return_blocked_target = nil
        DebugLog(inst, "return_done", string.format(
            "reason=%s npc=%s leader=%s",
            tostring(done_reason or "unknown"),
            GetDebugName(inst),
            GetDebugName(leader)
        ), 0.1)
    end

    local function MoveTowardLeader(log_move)
        if not inst:IsValid() then
            StopReturnLock("npc_invalid")
            return false
        end
        if leader == nil or not leader:IsValid() or loco == nil then
            StopReturnLock("missing_leader_or_loco")
            return false
        end
        ClearCombat()
        local clx, cly, clz = leader.Transform:GetWorldPosition()
        local cix, _, ciz = inst.Transform:GetWorldPosition()
        local cdx, cdz = cix - clx, ciz - clz
        local clen = math.sqrt(cdx * cdx + cdz * cdz)
        if clen <= target_dist + 0.5 then
            loco:Stop()
            if IsBlockedTargetOutside() then
                DebugLog(inst, "return_hold", string.format(
                    "reason=%s npc=%s leader=%s blocked=%s cur=%.2f target_dist=%.2f limit=%.2f",
                    tostring(reason or "unknown"),
                    GetDebugName(inst),
                    GetDebugName(leader),
                    GetDebugName(inst._npcfriends_return_blocked_target),
                    clen,
                    math.sqrt(inst._npcfriends_return_blocked_target:GetDistanceSqToInst(leader)),
                    return_dist
                ), 0.5)
                return true
            end
            StopReturnLock("arrived")
            return false
        end
        local tx, tz = clx, clz
        if clen > 0.001 and target_dist > 0 then
            tx = clx + cdx / clen * target_dist
            tz = clz + cdz / clen * target_dist
        end
        local point = (_G.Point ~= nil and _G.Point(tx, cly, tz))
            or (_G.Vector3 ~= nil and _G.Vector3(tx, cly, tz))
        if point ~= nil then
            loco:GoToPoint(point, nil, true)
            if log_move then
                DebugLog(inst, "return_gotopoint", string.format(
                    "reason=%s npc=%s leader=%s userid=%s cur=%.2f return_limit=%.2f follow_target=%.2f npc_pos=(%.1f,%.1f) leader_pos=(%.1f,%.1f) goto=(%.1f,%.1f)",
                    tostring(reason or "unknown"),
                    GetDebugName(inst),
                    GetDebugName(leader),
                    tostring(leader.userid),
                    clen,
                    return_dist,
                    target_dist,
                    cix,
                    ciz,
                    clx,
                    clz,
                    tx,
                    tz
                ), 0.5)
            end
            return true
        end
        DebugLog(inst, "return_fail_no_point", string.format(
            "npc=%s leader=%s cur=%.2f",
            GetDebugName(inst),
            GetDebugName(leader),
            clen
        ), 1)
        return false
    end

    ClearCombat()
    inst._npcfriends_return_to_leader_until = ((_G.GetTime ~= nil and _G.GetTime()) or 0) + 4
    if inst._npcfriends_return_task == nil then
        inst._npcfriends_return_task = inst:DoPeriodicTask(0.2, function()
            if not M.IsReturningToLeader(inst) then
                StopReturnLock("timeout")
                return
            end
            MoveTowardLeader(false)
        end)
    end

    MoveTowardLeader(true)
    return true
end

function M.SavePersistent(subject)
    if _G.TheSim == nil or _G.TheSim.SetPersistentString == nil then
        return
    end
    local key = GetPersistentKey(GetSubjectUserid(subject))
    if key == nil then
        return
    end
    _G.pcall(function()
        _G.TheSim:SetPersistentString(key, M.Encode(subject), false)
    end)
end

function M.LoadPersistent(subject, callback)
    if _G.TheSim == nil or _G.TheSim.GetPersistentString == nil then
        if callback ~= nil then callback(false) end
        return
    end
    local userid = GetSubjectUserid(subject)
    local key = GetPersistentKey(userid)
    if key == nil then
        if callback ~= nil then callback(false) end
        return
    end
    _G.TheSim:GetPersistentString(key, function(load_success, data)
        if load_success and type(data) == "string" and data ~= "" then
            M.ApplyEncoded(userid, data)
            if M.GetValue("stop_attack", userid) == true then
                M.StopAllFriendlyCombat(userid)
            end
        end
        if callback ~= nil then callback(load_success == true) end
    end, false)
end

return M
