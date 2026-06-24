-- scripts/npc/npc_platform_debug.lua
-- ════════════════════════════════════════════════════════════════════════════
-- 平台跟随 / 上船跳船 诊断模块（仅在 NPC_TUNING.DEBUG_PLATFORM_HOP = true 时启用）
--
-- 关注点：
--   1) NPC 当前 platform / leader platform 变化（玩家上船、NPC 上船）
--   2) Follow 节点判定结果（是否 APPROACH、距离、是否跨平台）
--   3) locomotor 跳船扫描结果（是否在边缘、前方平台、距离）
--   4) StartHopping 实际触发
--
-- 设计要点：
--   - 仅 hook 单个 NPC 实体，不替换全局组件方法（避免影响其他实体）
--   - 所有日志走状态变化判定 + 冷却限流，避免每帧刷屏
--   - 关闭开关时几乎零开销
-- ════════════════════════════════════════════════════════════════════════════

local NPC_TUNING = require("npc_tuning")

local M = {}

local function _enabled()
    return NPC_TUNING.DEBUG_PLATFORM_HOP == true
end

local function _platform_id(p)
    if p == nil then return "nil" end
    return tostring(p.GUID or p)
end

local function _pos2(inst)
    if inst == nil or not inst:IsValid() then return "?" end
    local x, _, z = inst.Transform:GetWorldPosition()
    return string.format("(%.1f,%.1f)", x, z)
end

local function _leader(inst)
    return inst.components.follower and inst.components.follower.leader or nil
end

local function _say(inst, key, msg, cd)
    -- 状态变化或冷却到期才打印
    inst._plat_dbg_log = inst._plat_dbg_log or {}
    local now = GetTime()
    local last = inst._plat_dbg_log[key]
    cd = cd or 1.0
    if last and (now - last) < cd then
        return
    end
    inst._plat_dbg_log[key] = now
    print(string.format("[NPC_PLAT][%s] %s", tostring(inst.npc_character_type or inst.prefab or "?"), msg))
end

-- ───────────────────────────────────────────────────────────────────────────
-- 周期性扫描：仅记录“关键变化”
-- ───────────────────────────────────────────────────────────────────────────
local function PeriodicTick(inst)
    if not _enabled() then return end
    if not inst:IsValid() then return end

    local leader = _leader(inst)
    local my_p = inst:GetCurrentPlatform()
    local le_p = leader and leader:IsValid() and leader:GetCurrentPlatform() or nil

    -- 平台变化打印
    local my_key = _platform_id(my_p)
    if inst._plat_dbg_my ~= my_key then
        _say(inst, "my_platform", string.format("NPC平台变化: %s -> %s pos=%s",
            tostring(inst._plat_dbg_my or "init"), my_key, _pos2(inst)), 0)
        inst._plat_dbg_my = my_key
    end

    if leader then
        local le_key = _platform_id(le_p)
        if inst._plat_dbg_leader ~= le_key then
            _say(inst, "leader_platform", string.format("Leader平台变化: %s -> %s leader_pos=%s",
                tostring(inst._plat_dbg_leader or "init"), le_key, _pos2(leader)), 0)
            inst._plat_dbg_leader = le_key
        end
    end

    -- 跨平台时持续提示（10s 一次，提醒当前还在跨平台）
    if leader and my_p ~= le_p then
        local d2 = inst:GetDistanceSqToInst(leader) or 0
        local loco = inst.components.locomotor
        local hop_ok = loco and (loco.allow_platform_hopping == true) or false
        local sg_name = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name or "?"
        local ba = inst:GetBufferedAction()
        local ba_name = ba and ba.action and ba.action.id or "nil"
        _say(inst, "cross_platform", string.format(
            "跨平台跟随中: dist=%.1f hop_enabled=%s sg=%s ba=%s",
            math.sqrt(d2), tostring(hop_ok), sg_name, tostring(ba_name)), 10)
    end
end

-- ───────────────────────────────────────────────────────────────────────────
-- Hook locomotor 跳船 API（StartHopping 与 ScanForPlatform）
-- 仅在该 NPC 实例上覆盖方法（不污染其他实体），关闭开关时也安全
-- ───────────────────────────────────────────────────────────────────────────
local function HookLocomotor(inst)
    local loco = inst.components.locomotor
    if loco == nil or loco._plat_dbg_hooked then return end
    loco._plat_dbg_hooked = true

    local _orig_StartHopping = loco.StartHopping
    function loco:StartHopping(x, z, target_platform, ...)
        if _enabled() then
            local mx, _, mz = self.inst.Transform:GetWorldPosition()
            local d = math.sqrt((x - mx) * (x - mx) + (z - mz) * (z - mz))
            local tp = _platform_id(target_platform)
            print(string.format("[NPC_PLAT][%s] StartHopping -> target_platform=%s dist=%.1f from=%s to=(%.1f,%.1f)",
                tostring(self.inst.npc_character_type or self.inst.prefab or "?"),
                tp, d, _pos2(self.inst), x, z))
        end
        return _orig_StartHopping(self, x, z, target_platform, ...)
    end

    -- 周期采样 ScanForPlatform 失败原因（每 1s 限流）
    local _orig_ScanForPlatform = loco.ScanForPlatform
    function loco:ScanForPlatform(my_platform, target_x, target_z, hop_distance, ...)
        local can_hop, px, pz, found_platform, blocked = _orig_ScanForPlatform(self, my_platform, target_x, target_z, hop_distance, ...)
        if _enabled() and self.inst._plat_dbg_log then
            local now = GetTime()
            local last = self.inst._plat_dbg_log["scan"] or 0
            if (now - last) > 1.0 then
                self.inst._plat_dbg_log["scan"] = now
                local mx, _, mz = self.inst.Transform:GetWorldPosition()
                local dx, dz = target_x - mx, target_z - mz
                local d = math.sqrt(dx * dx + dz * dz)
                print(string.format("[NPC_PLAT][%s] Scan: from=%s to=(%.1f,%.1f) hop_dist=%.1f my=%s found=%s can_hop=%s blocked=%s",
                    tostring(self.inst.npc_character_type or self.inst.prefab or "?"),
                    _pos2(self.inst), target_x, target_z, hop_distance,
                    _platform_id(my_platform), _platform_id(found_platform),
                    tostring(can_hop), tostring(blocked)))
            end
        end
        return can_hop, px, pz, found_platform, blocked
    end
end

-- ───────────────────────────────────────────────────────────────────────────
-- Hook Follow 节点：每秒采样一次状态/距离/动作
-- 通过 brain post-init 的方式无侵入注入：在 NPC tick 时读取行为树根，
-- 找到 Follow 节点并采样其内部 status/action（不修改节点实现）。
-- ───────────────────────────────────────────────────────────────────────────
local function FindFollowNodeRecursive(node, depth)
    if node == nil or depth == nil or depth > 8 then return nil end
    if node.name == "Follow" then return node end
    local children = node.children
    if children then
        for _, c in ipairs(children) do
            local r = FindFollowNodeRecursive(c, depth + 1)
            if r then return r end
        end
    end
    -- 包装节点常用的 inner/node
    if node.node then
        return FindFollowNodeRecursive(node.node, depth + 1)
    end
    return nil
end

local function SampleFollowNode(inst)
    if not _enabled() then return end
    if not inst:IsValid() then return end
    local brain = inst.brain
    if brain == nil or brain.bt == nil then return end
    local follow = inst._plat_dbg_follow_node
    if follow == nil then
        follow = FindFollowNodeRecursive(brain.bt.root, 1)
        if follow == nil then return end
        inst._plat_dbg_follow_node = follow
    end

    local status = follow.status or "?"
    local action = follow.action or "?"
    local key = string.format("Follow:%s/%s", tostring(status), tostring(action))
    if inst._plat_dbg_follow_state ~= key then
        local leader = _leader(inst)
        local d = leader and math.sqrt(inst:GetDistanceSqToInst(leader)) or -1
        print(string.format("[NPC_PLAT][%s] Follow状态: %s -> %s dist=%.1f",
            tostring(inst.npc_character_type or inst.prefab or "?"),
            tostring(inst._plat_dbg_follow_state or "init"), key, d))
        inst._plat_dbg_follow_state = key
    end
end

-- ───────────────────────────────────────────────────────────────────────────
-- Public Init
-- ───────────────────────────────────────────────────────────────────────────
function M.Install(inst)
    if inst == nil or inst._plat_dbg_installed then return end
    inst._plat_dbg_installed = true

    HookLocomotor(inst)

    -- 监听 NPC 自身的 onhop / cancelhop 事件
    -- 修复后应能在 NPC 走到岸边时看到 onhop 触发并进入 hop_pre 状态
    inst:ListenForEvent("onhop", function(i, data)
        if not _enabled() then return end
        local sg_name = i.sg and i.sg.currentstate and i.sg.currentstate.name or "?"
        local has_embarker = i.components.embarker ~= nil
        print(string.format("[NPC_PLAT][%s] onhop 事件: sg=%s embarker=%s pos=%s",
            tostring(i.npc_character_type or i.prefab or "?"),
            sg_name, tostring(has_embarker), _pos2(i)))
    end)
    inst:ListenForEvent("cancelhop", function(i)
        if not _enabled() then return end
        print(string.format("[NPC_PLAT][%s] cancelhop 事件 pos=%s",
            tostring(i.npc_character_type or i.prefab or "?"), _pos2(i)))
    end)

    if _enabled() then
        local has_embarker = inst.components.embarker ~= nil
        local sg_has_hop = inst.sg ~= nil and inst.sg.sg ~= nil
            and inst.sg.sg.states ~= nil and inst.sg.sg.states["hop_pre"] ~= nil
        print(string.format("[NPC_PLAT][%s] Install 已挂载, GUID=%s pos=%s embarker=%s hop_states=%s",
            tostring(inst.npc_character_type or inst.prefab or "?"),
            tostring(inst.GUID), _pos2(inst),
            tostring(has_embarker), tostring(sg_has_hop)))
    end

    -- 周期采样：0.5s 平台/Follow 状态，关闭开关时每次都直接 return
    inst._plat_dbg_task = inst:DoPeriodicTask(0.5, function(i)
        if not _enabled() then return end
        PeriodicTick(i)
        SampleFollowNode(i)
        -- leader 可能在加载时已经注册（startfollowing 事件不会重发），
        -- 因此每次采样时兜底确认 leader 也已挂载诊断
        local leader = _leader(i)
        if leader and not leader._plat_dbg_leader_installed then
            M.InstallOnLeader(leader)
        end
    end)

    inst:ListenForEvent("onremove", function(i)
        if i._plat_dbg_task ~= nil then
            i._plat_dbg_task:Cancel()
            i._plat_dbg_task = nil
        end
    end)
end

-- ───────────────────────────────────────────────────────────────────────────
-- 玩家侧诊断：只挂在 leader 上，监听 starthop / 平台切换
-- ───────────────────────────────────────────────────────────────────────────
function M.InstallOnLeader(player)
    if not _enabled() then return end
    if player == nil or player._plat_dbg_leader_installed then return end
    player._plat_dbg_leader_installed = true

    player:ListenForEvent("onhopstart", function(p, data)
        if not _enabled() then return end
        local mx, _, mz = p.Transform:GetWorldPosition()
        local tx, tz = (data and data.target_x) or 0, (data and data.target_z) or 0
        print(string.format("[NPC_PLAT][LEADER:%s] onhopstart from=(%.1f,%.1f) to=(%.1f,%.1f) dist=%.1f",
            tostring(p.userid or p.prefab or "?"), mx, mz, tx, tz,
            math.sqrt((tx - mx) ^ 2 + (tz - mz) ^ 2)))
    end)

    player:ListenForEvent("onhopcomplete", function(p)
        if not _enabled() then return end
        local plat = p:GetCurrentPlatform()
        print(string.format("[NPC_PLAT][LEADER:%s] onhopcomplete platform=%s pos=%s",
            tostring(p.userid or p.prefab or "?"), _platform_id(plat), _pos2(p)))
    end)

    player:ListenForEvent("got_on_platform", function(p, plat)
        if not _enabled() then return end
        print(string.format("[NPC_PLAT][LEADER:%s] got_on_platform platform=%s",
            tostring(p.userid or p.prefab or "?"), _platform_id(plat)))
    end)

    player:ListenForEvent("got_off_platform", function(p, plat)
        if not _enabled() then return end
        print(string.format("[NPC_PLAT][LEADER:%s] got_off_platform platform=%s",
            tostring(p.userid or p.prefab or "?"), _platform_id(plat)))
    end)
end

return M
