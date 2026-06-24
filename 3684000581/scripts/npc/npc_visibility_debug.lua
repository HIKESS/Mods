-- scripts/npc/npc_visibility_debug.lua
-- ════════════════════════════════════════════════════════════════════════════
-- NPC "突然消失" 诊断模块（仅在 NPC_TUNING.DEBUG_VISIBILITY = true 时启用）
-- ════════════════════════════════════════════════════════════════════════════

local NPC_TUNING = require("npc_tuning")

local M = {}

local function _enabled()
    return NPC_TUNING.DEBUG_VISIBILITY == true
end

-- 用户要求：只关心"跟随中"的 NPC。事件监听统一用此判定过滤，
-- 避免开档/远离时未招募的 NPC 触发 entitywake/entitysleep 刷屏。
local function _is_following(inst)
    return inst.components ~= nil
        and inst.components.follower ~= nil
        and inst.components.follower.leader ~= nil
end

-- ── 工具：安全读取 AnimState / 位置 ─────────────────────────────────────────
local function _safe_call(anim, method)
    if anim == nil or anim[method] == nil then return "?" end
    local ok, v = pcall(anim[method], anim)
    if not ok then return "?" end
    return v or ""
end

local function _safe_get_build(inst)
    return _safe_call(inst.AnimState, "GetBuild")
end

local function _safe_get_bank(inst)
    return _safe_call(inst.AnimState, "GetBank")
end

local function _safe_get_anim(inst)
    return _safe_call(inst.AnimState, "GetCurrentAnimation")
end

local function _safe_is_visible(inst)
    if inst.entity == nil then return nil end
    local ok, v = pcall(function() return inst.entity:IsVisible() end)
    if not ok then return nil end
    return v
end

local function _expected_appearance(inst)
    local npc_utils = require("npc/npc_utils")
    local app = npc_utils.APPEARANCE[inst.npc_character_type or ""]
                or npc_utils.APPEARANCE.npcfriend
    return app or { bank = "wilson", build = "wilson" }
end

local function _world_kind()
    if _G.TheWorld == nil then return "?" end
    if _G.TheWorld:HasTag("cave") then return "cave" end
    if _G.TheWorld:HasTag("forest") then return "forest" end
    return "?"
end

local function _pos(inst)
    if inst == nil or not inst:IsValid() then return "?" end
    local x, y, z = inst.Transform:GetWorldPosition()
    return string.format("(%.1f,%.1f,%.1f)", x, y, z)
end

local function _platform_str(ent)
    if ent == nil or not ent:IsValid() then return "nil" end
    local p = ent:GetCurrentPlatform()
    return p and tostring(p.GUID) or "nil"
end

local function _say(inst, key, msg, cd)
    inst._vis_dbg_log = inst._vis_dbg_log or {}
    local now = GetTime()
    local last = inst._vis_dbg_log[key]
    cd = cd or 1.0
    if last and (now - last) < cd then
        return
    end
    inst._vis_dbg_log[key] = now
    local prefix = string.format("[NPC_VIS][slot=%s/%s/GUID=%s]",
        tostring(inst.npc_slot_index or "?"),
        tostring(inst.npc_character_type or inst.prefab or "?"),
        tostring(inst.GUID))
    print(prefix .. " " .. msg)
end

local function _full_snapshot(inst, reason)
    if not inst:IsValid() then return end

    local follower = inst.components.follower
    local leader = follower and follower.leader
    local leader_id = leader and leader:IsValid() and tostring(leader.userid or leader.GUID) or "nil"

    local rider = inst.components.rider
    local mount = rider and rider:IsRiding() and rider:GetMount() or nil

    local app = _expected_appearance(inst)
    local actual_build = _safe_get_build(inst)
    local actual_bank  = _safe_get_bank(inst)
    local build_mismatch = (actual_build ~= "" and actual_build ~= app.build
        and not inst._is_ghost_mode
        and not inst._is_weremoose
        and not inst._silvernecklace_were
        and not (rider and rider:IsRiding()))

    local dist = -1
    local lead_pos = "?"
    local lead_plat = "?"
    if leader and leader:IsValid() then
        dist = math.sqrt(inst:GetDistanceSqToInst(leader) or 0)
        lead_pos = _pos(leader)
        lead_plat = _platform_str(leader)
    end

    _say(inst, "snapshot:" .. (reason or "?"), string.format(
        "SNAPSHOT[%s] world=%s pos=%s plat=%s\n"
        .. "  build=%s (exp=%s%s) bank=%s (exp=%s) anim=%s sg=%s\n"
        .. "  limbo=%s asleep=%s visible=%s dead=%s invincible=%s\n"
        .. "  ghost=%s weremoose=%s were=%s wanda_age=%s riding=%s mount=%s\n"
        .. "  leader=%s leader_pos=%s leader_plat=%s dist=%.1f\n"
        .. "  clothing=%s clothing_uid=%s",
        reason or "?", _world_kind(), _pos(inst), _platform_str(inst),
        actual_build, app.build, build_mismatch and " !=" or "",
        actual_bank, app.bank, _safe_get_anim(inst),
        (inst.sg and inst.sg.currentstate and inst.sg.currentstate.name) or "?",
        tostring(inst:IsInLimbo()),
        tostring(inst:IsAsleep()),
        tostring(_safe_is_visible(inst)),
        tostring(inst.components.health and inst.components.health:IsDead() or false),
        tostring(inst.components.health and inst.components.health.invincible or false),
        tostring(inst._is_ghost_mode == true),
        tostring(inst._is_weremoose == true),
        tostring(inst._silvernecklace_were == true),
        tostring(inst._wanda_age_state or "-"),
        tostring(rider ~= nil and rider:IsRiding() or false),
        tostring(mount and mount.prefab or "-"),
        leader_id, lead_pos, lead_plat, dist,
        tostring(inst._npc_clothing ~= nil),
        tostring(inst._npc_clothing_userid or "-")), 0)
end

local function PeriodicTick(inst)
    if not _enabled() then return end
    if not inst:IsValid() then return end

    local follower = inst.components.follower
    local leader = follower and follower.leader
    if leader == nil then
        if inst._vis_dbg_had_leader then
            _say(inst, "leader_lost", "follower.leader 变为 nil（招募关系断开/未恢复）", 0)
            inst._vis_dbg_had_leader = false
        end
        return
    end
    if not inst._vis_dbg_had_leader then
        inst._vis_dbg_had_leader = true
    end

    local app = _expected_appearance(inst)

    local build = _safe_get_build(inst)
    if inst._vis_dbg_build ~= build then
        local mismatch_note = ""
        if build ~= "" and build ~= app.build
            and not inst._is_ghost_mode
            and not inst._is_weremoose
            and not inst._silvernecklace_were then
            mismatch_note = string.format(" !=expected(%s)", tostring(app.build))
        end
        _say(inst, "build_change", string.format(
            "build 变化: %s -> %s%s",
            tostring(inst._vis_dbg_build or "init"), tostring(build), mismatch_note), 0)
        inst._vis_dbg_build = build
    end

    if build == "" or build == "?" then
        _say(inst, "build_empty", string.format(
            "★ build 读取为空！char=%s expect=%s sg=%s pos=%s"
            .. "  → 玩家会看到 \"白模/透明\"。常见原因：服装/皮肤 build 资源未加载、"
            .. "SetBuild 给了一个不存在的 build 名（wanda/wurt/wortox/wilba 等带 _NPC 后缀的 build 资源缺失）",
            tostring(inst.npc_character_type), tostring(app.build),
            (inst.sg and inst.sg.currentstate and inst.sg.currentstate.name) or "?",
            _pos(inst)), 5)
    end

    local bank = _safe_get_bank(inst)
    if inst._vis_dbg_bank ~= bank then
        _say(inst, "bank_change", string.format(
            "bank 变化: %s -> %s exp=%s",
            tostring(inst._vis_dbg_bank or "init"), tostring(bank), tostring(app.bank)), 0)
        inst._vis_dbg_bank = bank
    end

    local in_limbo = inst:IsInLimbo()
    if inst._vis_dbg_limbo ~= in_limbo then
        _say(inst, "limbo_change", string.format(
            "IsInLimbo: %s -> %s   (true 时实体从场景移除，玩家完全看不到！) pos=%s",
            tostring(inst._vis_dbg_limbo == nil and "init" or inst._vis_dbg_limbo),
            tostring(in_limbo), _pos(inst)), 0)
        inst._vis_dbg_limbo = in_limbo
    end

    local asleep = inst:IsAsleep()
    if inst._vis_dbg_asleep ~= asleep then
        _say(inst, "asleep_change", string.format(
            "IsAsleep: %s -> %s   (asleep=true 时 NPC 不再 tick，可能看起来 \"卡在原地\") pos=%s",
            tostring(inst._vis_dbg_asleep == nil and "init" or inst._vis_dbg_asleep),
            tostring(asleep), _pos(inst)), 0)
        inst._vis_dbg_asleep = asleep
    end

    local visible = _safe_is_visible(inst)
    if visible == nil then visible = true end
    if inst._vis_dbg_visible ~= visible then
        _say(inst, "visible_change", string.format(
            "Entity.Visible: %s -> %s   (false 表示 Hide() 生效，rift portal/oceanfishing 流程会暂时 Hide)",
            tostring(inst._vis_dbg_visible == nil and "init" or inst._vis_dbg_visible),
            tostring(visible)), 0)
        inst._vis_dbg_visible = visible
    end

    local ghost = inst._is_ghost_mode == true
    if inst._vis_dbg_ghost ~= ghost then
        _say(inst, "ghost_change", string.format(
            "_is_ghost_mode: %s -> %s   (true=切到 ghost_build，玩家会看到灵魂外观)",
            tostring(inst._vis_dbg_ghost == nil and "init" or inst._vis_dbg_ghost),
            tostring(ghost)), 0)
        inst._vis_dbg_ghost = ghost
    end

    local moose = inst._is_weremoose == true
    if inst._vis_dbg_moose ~= moose then
        _say(inst, "moose_change", string.format(
            "_is_weremoose: %s -> %s   (true=切到 weremoose_build，玩家会看到鹿人外观)",
            tostring(inst._vis_dbg_moose == nil and "init" or inst._vis_dbg_moose),
            tostring(moose)), 0)
        inst._vis_dbg_moose = moose
    end

    local were = inst._silvernecklace_were == true
    if inst._vis_dbg_were ~= were then
        _say(inst, "were_change", string.format(
            "_silvernecklace_were: %s -> %s   (true=切到 werewilba，玩家会看到狼猪外观)",
            tostring(inst._vis_dbg_were == nil and "init" or inst._vis_dbg_were),
            tostring(were)), 0)
        inst._vis_dbg_were = were
    end

    if inst.npc_character_type == "wanda" then
        local age = inst._wanda_age_state or "?"
        if inst._vis_dbg_age ~= age then
            _say(inst, "wanda_age_change", string.format(
                "_wanda_age_state: %s -> %s   (build 在 wanda_NPC/wanda_old_NPC/wanda_young_NPC 间切换)",
                tostring(inst._vis_dbg_age or "init"), tostring(age)), 0)
            inst._vis_dbg_age = age
        end
    end

    local rider = inst.components.rider
    local riding = rider ~= nil and rider:IsRiding()
    if inst._vis_dbg_riding ~= riding then
        local mount = riding and rider:GetMount() or nil
        _say(inst, "ride_change", string.format(
            "Riding: %s -> %s mount=%s   (骑乘时 bank/build 会切换为坐骑外观)",
            tostring(inst._vis_dbg_riding == nil and "init" or inst._vis_dbg_riding),
            tostring(riding), mount and tostring(mount.prefab) or "-"), 0)
        inst._vis_dbg_riding = riding
    end

    local world = _world_kind()
    if inst._vis_dbg_world ~= world then
        _say(inst, "world_change", string.format(
            "world: %s -> %s   (跨分片：NPC 若未跟随迁移会卡在原分片)",
            tostring(inst._vis_dbg_world or "init"), tostring(world)), 0)
        inst._vis_dbg_world = world
    end

    if leader:IsValid() then
        local dist = math.sqrt(inst:GetDistanceSqToInst(leader) or 0)
        local far_threshold = NPC_TUNING.DEBUG_VISIBILITY_FAR_DIST or 60
        local far = dist > far_threshold
        if inst._vis_dbg_far ~= far then
            _say(inst, "far_from_leader", string.format(
                "距 leader: %.1f → %s (阈值=%d) my_pos=%s leader_pos=%s"
                .. "  (>50 通常会触发 TryTeleportToLeader 瞬移；若一直瞬移失败说明位置不可达)",
                dist, far and "远" or "近", far_threshold,
                _pos(inst), _pos(leader)), 0)
            inst._vis_dbg_far = far
        end

        local my_p = inst:GetCurrentPlatform()
        local le_p = leader:GetCurrentPlatform()
        local cross = (my_p ~= le_p)
        if inst._vis_dbg_cross_plat ~= cross then
            _say(inst, "cross_platform", string.format(
                "跨平台: %s my_plat=%s leader_plat=%s   (cross=true 时 NPC 在船外/玩家在船上)",
                tostring(cross),
                my_p and tostring(my_p.GUID) or "nil",
                le_p and tostring(le_p.GUID) or "nil"), 0)
            inst._vis_dbg_cross_plat = cross
        end
    end

    local sg_name = (inst.sg and inst.sg.currentstate and inst.sg.currentstate.name) or "?"
    if inst._vis_dbg_sg ~= sg_name then
        local SUSPECT = {
            ["npc_rift_arrive"] = "跨分片到达，被 Hide() 1.5s",
            ["npc_rift_arrive_wanda"] = "旺达跨分片到达",
            ["hop_pre"] = "准备跳船",
            ["hop_loop"] = "跳船中",
            ["hop_pst"] = "跳船完成",
            ["mounted"] = "骑乘中",
            ["doshortaction"] = "短动作",
            ["ghost_idle"] = "灵魂待机",
            ["death"] = "死亡动画",
            ["corpse"] = "尸体",
            ["revive_from_ghost"] = "灵魂复活",
            ["weremoose_transform"] = "变鹿人",
            ["weremoose_revert"] = "鹿人还原",
            ["transform_werewilba"] = "变狼猪",
            ["transform_wilba"] = "狼猪还原",
            ["becomeolder_wanda"] = "旺达变老",
            ["becomeyounger_wanda"] = "旺达变年轻",
        }
        local hint = SUSPECT[sg_name] or SUSPECT[inst._vis_dbg_sg or ""]
        if hint then
            _say(inst, "sg_change", string.format(
                "SG: %s -> %s   (注: %s)",
                tostring(inst._vis_dbg_sg or "init"), tostring(sg_name), hint), 0)
        end
        inst._vis_dbg_sg = sg_name
    end

    local slot = inst.npc_slot_index
    if inst._vis_dbg_slot ~= slot then
        _say(inst, "slot_change", string.format(
            "npc_slot_index: %s -> %s",
            tostring(inst._vis_dbg_slot == nil and "init" or inst._vis_dbg_slot),
            tostring(slot)), 0)
        inst._vis_dbg_slot = slot
    end
    local char = inst.npc_character_type
    if inst._vis_dbg_char ~= char then
        _say(inst, "char_change", string.format(
            "npc_character_type: %s -> %s exp_build=%s",
            tostring(inst._vis_dbg_char == nil and "init" or inst._vis_dbg_char),
            tostring(char), tostring(app.build)), 0)
        inst._vis_dbg_char = char
    end

    local _, y, _ = inst.Transform:GetWorldPosition()
    local y_high = (y or 0) > 1.0
    if inst._vis_dbg_yhigh ~= y_high then
        _say(inst, "y_change", string.format(
            "Y 高度: %s -> %s y=%.2f   (y>1 表示在跳跃/跨船/被掀飞)",
            tostring(inst._vis_dbg_yhigh == nil and "init" or inst._vis_dbg_yhigh),
            tostring(y_high), y or 0), 0)
        inst._vis_dbg_yhigh = y_high
    end
end

-- ───────────────────────────────────────────────────────────────────────────
-- 控制台命令：c_npcfriends_vis_snapshot([reason])
--   立即打印所有 "跟随中" NPC 的完整状态快照，绕过冷却。
--   玩家上报 "NPC 消失了" 时，请第一时间用 c_npcfriends_vis_snapshot() 抓现场。
-- ───────────────────────────────────────────────────────────────────────────
_G.c_npcfriends_vis_snapshot = function(reason)
    if not _G.Ents then
        print("[NPC_VIS] 世界未就绪")
        return
    end
    reason = reason or "manual"
    local count = 0
    local total = 0
    for _, ent in pairs(_G.Ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            total = total + 1
            if ent.components and ent.components.follower
                and ent.components.follower.leader ~= nil then
                count = count + 1
                ent._vis_dbg_log = ent._vis_dbg_log or {}
                ent._vis_dbg_log["snapshot:" .. reason] = 0  -- 清冷却
                _full_snapshot(ent, reason)
            end
        end
    end
    print(string.format("[NPC_VIS] 快照完成：%d 个跟随中 NPC / %d 个 npcfriend 总数",
        count, total))
end

-- ───────────────────────────────────────────────────────────────────────────
-- 控制台命令：c_npcfriends_list()
--   清点【当前分片】里所有 npcfriend 实体（不论是否跟随），按 slot 排序逐个列出，
--   并对照 NPC_TUNING.NPC_CHARACTERS 配置，报告"应在却缺失"的 slot。
--   用于验证 "开档后 NPC 是否都在 / 少了哪几只"。
--   ⚠ 跨分片：洞穴和地面是不同进程，本命令只统计你当前所在分片的 NPC。
-- ───────────────────────────────────────────────────────────────────────────
_G.c_npcfriends_list = function()
    if not _G.Ents then
        print("[NPC_VIS] 世界未就绪")
        return
    end

    -- 1) 收集当前分片存在的 npcfriend，按 slot 归类（同 slot 可能异常重复）
    local by_slot = {}
    local no_slot = {}
    local total = 0
    for _, ent in pairs(_G.Ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            total = total + 1
            local s = ent.npc_slot_index
            if s == nil then
                table.insert(no_slot, ent)
            else
                by_slot[s] = by_slot[s] or {}
                table.insert(by_slot[s], ent)
            end
        end
    end

    local world = _world_kind()
    print(string.format(
        "════ [NPC_VIS] NPC 清点 (分片=%s, 共 %d 只 npcfriend 实体) ════",
        world, total))

    -- 世界级生成标记（排查 "开档后一个 NPC 都没有" 的关键状态）
    if _G.TheWorld then
        local tw = _G.TheWorld
        local disabled = tw._npc_friend_disabled
        local dis_keys = {}
        if type(disabled) == "table" then
            for k in pairs(disabled) do table.insert(dis_keys, tostring(k)) end
        end
        table.sort(dis_keys)
        print(string.format(
            "  世界标记: _npc_spawned=%s _npc_world_initialized=%s _npc_reconcile_done=%s disabled_slots=%s",
            tostring(tw._npc_spawned),
            tostring(tw._npc_world_initialized),
            tostring(tw._npc_reconcile_done),
            (#dis_keys > 0) and ("{" .. table.concat(dis_keys, ",") .. "}") or "{}"))
        print("  （若 _npc_world_initialized=true 但实体数=0：磁盘初始化标记已落盘、"
            .. "但实体未随存档保存，且 reconcile 停用 → 不会再补号，这是\"强关后 NPC 消失\"的典型现场）")
    end

    -- 实体明细描述
    local function describe(ent)
        local follower = ent.components and ent.components.follower
        local leader = follower and follower.leader
        local leader_id = (leader and leader:IsValid())
            and tostring(leader.userid or leader.GUID) or "nil"
        return string.format(
            "GUID=%s pos=%s following=%s leader=%s ghost=%s limbo=%s asleep=%s build=%s",
            tostring(ent.GUID),
            _pos(ent),
            tostring(leader ~= nil),
            leader_id,
            tostring(ent._is_ghost_mode == true),
            tostring(ent:IsInLimbo()),
            tostring(ent:IsAsleep()),
            tostring(_safe_get_build(ent)))
    end

    -- 解析单个配置条目 → char_name, spawn_mode, 配置是否启用
    local function parse_cfg(entry)
        local char_name, spawn_mode, explicit_enabled
        if type(entry) == "table" then
            char_name = entry.char or "wilson"
            spawn_mode = entry.spawn or "portal"
            explicit_enabled = entry.enabled
        else
            char_name = entry
            spawn_mode = "portal"
        end
        local enabled
        if explicit_enabled ~= nil then
            enabled = explicit_enabled                       -- 配置表里写死 enabled=false
        elseif NPC_TUNING.IsCharEnabled then
            enabled = NPC_TUNING.IsCharEnabled(char_name)    -- modconfig / DstAdmin 实时开关
        else
            enabled = true
        end
        return char_name, spawn_mode, enabled
    end

    -- 2) 完整花名册：逐 slot 同时显示【配置开关】与【世界里在不在】
    local cfg = NPC_TUNING.NPC_CHARACTERS
    local cfg_slot_count = type(cfg) == "table" and #cfg or 0
    local missing_enabled = {}   -- 配置开启却找不到（疑似 bug / 在别的分片）
    local present_disabled = {}  -- 配置关闭却仍在世界（残留）

    if type(cfg) == "table" then
        for i, entry in ipairs(cfg) do
            local char_name, spawn_mode, enabled = parse_cfg(entry)
            local list = by_slot[i]
            local cfg_tag = enabled and "配置=ON " or "配置=OFF"
            if list and #list >= 1 then
                local extra = (#list > 1) and string.format(" ⚠×%d", #list) or ""
                print(string.format("  slot=%-3d %-8s %-12s 世界=在%s  %s",
                    i, char_name, cfg_tag, extra, describe(list[1])))
                for k = 2, #list do
                    print("           （同 slot 重复）" .. describe(list[k]))
                end
                if not enabled then
                    table.insert(present_disabled, string.format("slot=%d(%s)", i, char_name))
                end
            else
                if enabled then
                    print(string.format("  slot=%-3d %-8s %-12s 世界=缺失✘  spawn=%s",
                        i, char_name, cfg_tag, spawn_mode))
                    table.insert(missing_enabled, string.format("slot=%d(%s,spawn=%s)", i, char_name, spawn_mode))
                else
                    print(string.format("  slot=%-3d %-8s %-12s 世界=不在(配置已关，正常)",
                        i, char_name, cfg_tag))
                end
            end
        end
    end

    -- 3) 配置范围之外却存在的实体（slot 超出 / 无 slot），单独列出
    local slot_keys = {}
    for s in pairs(by_slot) do
        if s > cfg_slot_count then table.insert(slot_keys, s) end
    end
    table.sort(slot_keys)
    for _, s in ipairs(slot_keys) do
        for _, ent in ipairs(by_slot[s]) do
            print(string.format("  slot=%-3d (超出配置范围) char=%s %s",
                s, tostring(ent.npc_character_type or "?"), describe(ent)))
        end
    end
    for _, ent in ipairs(no_slot) do
        print(string.format("  slot=?   char=%s %s   (无 slot：可能仍在 OnLoad 早期或生成异常)",
            tostring(ent.npc_character_type or "?"), describe(ent)))
    end

    -- 4) 结论汇总
    --    spawn="world" 的 NPC 只在地面(forest)生成；跟随玩家下洞穴的才会迁移过来。
    if #missing_enabled > 0 then
        print(string.format("  ✘ 配置开启但当前分片缺失 %d 个: %s",
            #missing_enabled, table.concat(missing_enabled, ", ")))
        print("    （应跟随你的：可能未随分片迁移/读档丢失；"
            .. "spawn=world 且你在洞穴里：属正常，它们在地面分片）")
    else
        print("  ✔ 配置开启的 slot 在当前分片均有对应实体")
    end
    if #present_disabled > 0 then
        print(string.format("  ⚠ 配置已关闭却仍存在 %d 个（残留实体）: %s",
            #present_disabled, table.concat(present_disabled, ", ")))
    end
    print("════════════════════════════════════════════════════════")
end


function M.Install(inst)
    if inst == nil or inst._vis_dbg_installed then return end
    inst._vis_dbg_installed = true

    local tick = NPC_TUNING.DEBUG_VISIBILITY_TICK or 1.0
    inst._vis_dbg_task = inst:DoPeriodicTask(tick, PeriodicTick)

    inst:ListenForEvent("startfollowing", function(i, data)
        if not _enabled() then return end
        local leader = data and data.leader or (i.components.follower and i.components.follower.leader)
        _say(i, "evt_startfollow", string.format(
            "★ startfollowing leader=%s",
            leader and tostring(leader.userid or leader.GUID) or "nil"), 0)
        _full_snapshot(i, "startfollowing")
    end)

    inst:ListenForEvent("stopfollowing", function(i)
        if not _enabled() then return end
        _say(i, "evt_stopfollow",
            "★ stopfollowing (招募关系断开；NPC 仍在世界，但不会跟随玩家了)", 0)
        _full_snapshot(i, "stopfollowing")
    end)

    inst:ListenForEvent("entitysleep", function(i)
        if not _enabled() or not _is_following(i) then return end
        _say(i, "evt_sleep",
            "entitysleep (entity 进入睡眠，远离任何玩家，brain/tasks 暂停)", 0)
    end)

    inst:ListenForEvent("entitywake", function(i)
        if not _enabled() or not _is_following(i) then return end
        _say(i, "evt_wake", "entitywake (entity 苏醒)", 0)
    end)

    inst:ListenForEvent("npc_pre_migration", function(i)
        if not _enabled() or not _is_following(i) then return end
        _full_snapshot(i, "pre_migration (即将跨分片或被 reconcile 禁用)")
    end)

    inst:ListenForEvent("death", function(i)
        if not _enabled() or not _is_following(i) then return end
        _say(i, "evt_death", "★ death 事件 (即将切到 ghost 外观)", 0)
    end)

    inst:ListenForEvent("onremove", function(i)
        if _enabled() and _is_following(i) then
            _say(i, "evt_remove", string.format(
                "★ onremove pos=%s ghost=%s limbo=%s sg=%s"
                .. "  (实体被销毁，若不是跨分片/reconcile 主动 Remove，可能是 bug)",
                _pos(i),
                tostring(i._is_ghost_mode),
                tostring(i:IsInLimbo()),
                (i.sg and i.sg.currentstate and i.sg.currentstate.name) or "?"), 0)
        end
        if i._vis_dbg_task ~= nil then
            i._vis_dbg_task:Cancel()
            i._vis_dbg_task = nil
        end
    end)

    -- install 时 leader 通常还未赋值（RelinkNPCs 稍后才 SetLeader），
    -- 故仅对"已在跟随"的 NPC 打 install 快照；其余由随后的 startfollowing 事件补打，
    -- 避免开档时一次性刷出全部未招募 NPC 的快照。
    if _enabled() and _is_following(inst) then
        _full_snapshot(inst, "install")
    end
end

return M
