-- ========== NPC 附加控件构建器 ==========
-- 根据 NPC_TUNING.CHARACTER_EXTRAS 声明，为 NpcStatusScreen 动态生成
-- spinner / toggle / deposit_btn / work_range_toggle / scholar_range_toggle。
--
-- 用法（在 NpcStatusScreen 构造函数末尾）：
--   local ExtraBuilder = GLOBAL.require("ui_extras_builder")
--   self._extras = ExtraBuilder.Build(self, char_type, owner_param, data)
--
-- 然后在 _ApplyLayout / UpdateData / Kill 中调用：
--   ExtraBuilder.ApplyLayout(self._extras, work_base_y)
--   ExtraBuilder.Update(self._extras, data)
--   ExtraBuilder.Kill(self._extras)

local ExtraBuilder = {}

local BTN_W       = 130
local BTN_H       = 34
local BTN_SPACING = 42

-- ── 通用控件工厂 ──────────────────────────────────────────────────────────────

local function MakeBtn(parent, font_size)
    local btn = parent:AddChild(ImageButton(
        "images/global_redux.xml",
        "button_carny_long_normal.tex",
        "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex",
        "button_carny_long_down.tex"))
    btn:ForceImageSize(BTN_W, BTN_H)
    btn:SetFont(GLOBAL.CHATFONT)
    btn:SetTextSize(font_size or 16)
    btn.scale_on_focus = false
    return btn
end

local function MakeArrow(parent, dir)
    local is_left = (dir == "left")
    local btn = parent:AddChild(ImageButton(
        "images/ui.xml",
        is_left and "arrow2_left.tex"         or "arrow2_right.tex",
        is_left and "arrow2_left_over.tex"    or "arrow2_right_over.tex",
        is_left and "arrow_left_disabled.tex" or "arrow_right_disabled.tex",
        is_left and "arrow2_left_down.tex"    or "arrow2_right_down.tex"))
    btn:SetScale(0.2)
    btn.scale_on_focus = false
    return btn
end

local function GetTuning(key, fallback)
    if not key then return fallback end
    local NT = GLOBAL.NPC_TUNING
    return (NT and NT[key]) or fallback
end

-- ── 各 type 构建函数 ──────────────────────────────────────────────────────────
-- 每个构建函数返回一个 entry 表：
--   rows    : 占用的行数（默认 1，每行高 BTN_SPACING px）
--   layout  : function(y) — 将控件定位到指定 y 坐标
--   update  : function(data) — 根据服务端 data 更新控件状态
--   on_kill : function() — 面板销毁时清理（例如隐藏 overlay 圆圈）

-- ── work_range_toggle ─────────────────────────────────────────────────────────
-- 作用：显示/隐藏 NPC 工作范围圆圈。
-- 将 parent.work_range_toggle_btn 挂到 parent 上，使 _UpdateWorkRangeInfo 仍然可用。
local function BuildWorkRangeToggle(parent, def, owner_param)
    local btn = MakeBtn(parent)
    parent.work_range_toggle_btn = btn

    -- 从 prefs 恢复上次状态
    parent._show_work_range =
        ((DSTADMIN_NPC_STATUS_PREFS.show_range_by_owner or {})[owner_param] == true)

    local function refresh()
        local mark = parent._show_work_range and "[x]" or "[ ]"
        local ct   = parent.data and parent.data.char_type or ""
        local lk   = (ct == "wortox") and "label_show_heal_range" or "label_show_work_range"
        btn:SetText(mark .. " " .. T(lk))
    end
    refresh()

    btn:SetOnClick(function()
        parent._show_work_range = not parent._show_work_range
        DSTADMIN_NPC_STATUS_PREFS.show_range_by_owner[owner_param] =
            parent._show_work_range and true or false
        refresh()
        parent:_UpdateWorkRangeInfo(parent.data or {})
    end)

    return {
        rows   = 1,
        layout = function(y) btn:SetPosition(-75, y) end,
        update = function(_)  refresh() end,
    }
end

-- ── scholar_range_toggle ──────────────────────────────────────────────────────
-- 薇克巴顿专用：控温/灭火范围显示。
local function BuildScholarRangeToggle(parent, def, owner_param)
    local btn = MakeBtn(parent)
    parent.scholar_care_btn = btn

    parent._show_scholar_care =
        ((DSTADMIN_NPC_STATUS_PREFS.show_scholar_by_owner or {})[owner_param] == true)

    local function refresh()
        local mark = parent._show_scholar_care and "[x]" or "[ ]"
        btn:SetText(mark .. " " .. T("label_scholar_care_range"))
    end
    refresh()

    btn:SetOnClick(function()
        parent._show_scholar_care = not parent._show_scholar_care
        DSTADMIN_NPC_STATUS_PREFS.show_scholar_by_owner[owner_param] =
            parent._show_scholar_care and true or false
        refresh()
        parent:_UpdateScholarCareInfo(parent.data or {})
    end)

    return {
        rows   = 1,
        layout = function(y) btn:SetPosition(-75, y) end,
        update = function(_)  refresh() end,
    }
end

-- ── spinner ───────────────────────────────────────────────────────────────────
-- 通用数值调节器：[标签]  ←  数值  →
-- def 字段：
--   label_key, data_key, rpc_name
--   min / min_tuning  — 最小值或从 NPC_TUNING 读取
--   max / max_tuning  — 最大值
--   default / default_tuning — 初始值
--   rpc_prefix_char   — true 时发 RPC 前缀 "char_type|value"（用于 SetOrganizeRange）
local function BuildSpinner(parent, def, owner_param)
    local label     = parent:AddChild(Text(GLOBAL.UIFONT, 22, T(def.label_key) .. ":"))
    label:SetColour(1, 1, 1, 1)
    local left_btn  = MakeArrow(parent, "left")
    local val_text  = parent:AddChild(Text(GLOBAL.UIFONT, 22, ""))
    val_text:SetColour(1, 1, 1, 1)
    local right_btn = MakeArrow(parent, "right")

    local cur = def.default or GetTuning(def.default_tuning,
                    def.min   or GetTuning(def.min_tuning, 1))
    val_text:SetString(tostring(cur))

    local function apply(v)
        local lo = def.min or GetTuning(def.min_tuning, 1)
        local hi = def.max or GetTuning(def.max_tuning, 99)
        cur = math.max(lo, math.min(hi, v))
        val_text:SetString(tostring(cur))
        GLOBAL.pcall(function()
            local rpc_val = tostring(cur)
            if def.rpc_prefix_char then
                local ct = (parent.data and parent.data.char_type) or ""
                rpc_val  = ct .. "|" .. rpc_val
            end
            SendModRPCToServer(GetModRPC("NPCFriends", def.rpc_name), rpc_val)
        end)
    end

    left_btn:SetOnClick(function()  apply(cur - 1) end)
    right_btn:SetOnClick(function() apply(cur + 1) end)

    return {
        rows   = 1,
        layout = function(y)
            label:SetPosition(-75, y)
            left_btn:SetPosition(35,  y)
            val_text:SetPosition(68,  y)
            right_btn:SetPosition(100, y)
        end,
        update = function(d)
            local sv = d and d[def.data_key]
            if sv ~= nil then
                local v = GLOBAL.tonumber(sv)
                if v then
                    cur = v
                    val_text:SetString(tostring(cur))
                end
            end
        end,
    }
end

-- ── deposit_btn ───────────────────────────────────────────────────────────────
-- 双按钮行：[设置存放点]  [显示范围 [x]]
-- def 字段：
--   label_key, mode_fn, has_pos_key
--   range_label_key, range_x_key, range_z_key, range_radius, range_color
--   prefs_key — 用于 DSTADMIN_NPC_STATUS_PREFS 的 key 名称
local function BuildDepositBtn(parent, def, owner_param, initial_data)
    local set_btn   = MakeBtn(parent)
    set_btn:SetFont(GLOBAL.BUTTONFONT)
    local range_btn = MakeBtn(parent)

    -- 初始化 prefs 存储
    local prefs_tbl = def.prefs_key .. "_by_owner"
    DSTADMIN_NPC_STATUS_PREFS[prefs_tbl] =
        DSTADMIN_NPC_STATUS_PREFS[prefs_tbl] or {}
    local show_key    = "_show_" .. def.prefs_key
    parent[show_key]  = DSTADMIN_NPC_STATUS_PREFS[prefs_tbl][owner_param] == true
    local overlay_key = def.prefs_key .. "_" .. (owner_param or "")

    local function refresh_set(d)
        local has = d and d[def.has_pos_key] and d[def.has_pos_key] ~= 0
        set_btn:SetText(T(def.label_key) .. (has and " \226\156\147" or ""))
    end

    local function refresh_range()
        local mark = parent[show_key] and "[x]" or "[ ]"
        range_btn:SetText(mark .. " " .. T(def.range_label_key))
    end

    local function update_overlay(d)
        if not DSTADMIN_RANGE_OVERLAY then return end
        local x = d and d[def.range_x_key]
        local z = d and d[def.range_z_key]
        if parent[show_key] and x and x ~= 0 then
            DSTADMIN_RANGE_OVERLAY.Show(overlay_key, x, z,
                def.range_radius or 12, def.range_color or "green")
        else
            DSTADMIN_RANGE_OVERLAY.Hide(overlay_key)
        end
    end

    refresh_set(initial_data)
    refresh_range()

    set_btn:SetOnClick(function()
        GLOBAL.pcall(function()
            local UiModes = GLOBAL.require("npc_ui_modes")
            if UiModes and UiModes[def.mode_fn] then
                UiModes[def.mode_fn](owner_param)
            end
        end)
    end)

    range_btn:SetOnClick(function()
        parent[show_key] = not parent[show_key]
        DSTADMIN_NPC_STATUS_PREFS[prefs_tbl][owner_param] =
            parent[show_key] and true or false
        refresh_range()
        update_overlay(parent.data or {})
    end)

    return {
        rows      = 1,
        overlay_key = overlay_key,
        layout    = function(y)
            set_btn:SetPosition(-75, y)
            range_btn:SetPosition(75, y)
        end,
        update    = function(d)
            refresh_set(d)
            update_overlay(d)
        end,
    }
end

-- ── toggle ────────────────────────────────────────────────────────────────────
-- 单按钮开关，状态由服务端同步。
-- def 字段：label_key_on, label_key_off, data_key, rpc_name
local function BuildToggle(parent, def, owner_param)
    local btn     = MakeBtn(parent)
    local enabled = false

    local function refresh()
        btn:SetText(T(enabled and def.label_key_on or def.label_key_off))
    end
    refresh()

    btn:SetOnClick(function()
        enabled = not enabled
        refresh()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", def.rpc_name),
                enabled and "true" or "false")
        end)
    end)

    return {
        rows   = 1,
        layout = function(y) btn:SetPosition(-75, y) end,
        update = function(d)
            if d and d[def.data_key] ~= nil then
                enabled = d[def.data_key] == true
                refresh()
            end
        end,
    }
end

-- ── 类型分发表 ────────────────────────────────────────────────────────────────

local BUILDERS = {
    work_range_toggle    = BuildWorkRangeToggle,
    scholar_range_toggle = BuildScholarRangeToggle,
    spinner              = BuildSpinner,
    deposit_btn          = BuildDepositBtn,
    toggle               = BuildToggle,
}

-- ═══════════════════════════════════════════════════════════════
--  公共 API
-- ═══════════════════════════════════════════════════════════════

-- Build(parent, char_type, owner_param, initial_data)
--   → 返回 built 列表，传入后续 API 使用。
--   副作用：对需要的类型会向 parent 设置命名字段
--   （如 parent.work_range_toggle_btn），使现有方法仍可正常工作。
function ExtraBuilder.Build(parent, char_type, owner_param, initial_data)
    local NT   = GLOBAL.NPC_TUNING
    local defs = (NT and NT.CHARACTER_EXTRAS and NT.CHARACTER_EXTRAS[char_type]) or {}
    local built = { _overlay_keys = {} }

    for _, def in ipairs(defs) do
        local fn = BUILDERS[def.type]
        if fn then
            local ok, entry = GLOBAL.pcall(fn, parent, def, owner_param, initial_data)
            if ok and entry then
                table.insert(built, entry)
                if entry.overlay_key then
                    table.insert(built._overlay_keys, entry.overlay_key)
                end
            end
        end
    end

    return built
end

-- CountRows(built) → 所有 extra 占用的总行数（用于面板高度计算）
function ExtraBuilder.CountRows(built)
    local n = 0
    for _, e in ipairs(built) do
        n = n + (e.rows or 1)
    end
    return n
end

-- ApplyLayout(built, start_y) → 从 start_y 开始向下依次定位每个 extra
function ExtraBuilder.ApplyLayout(built, start_y)
    local y = start_y
    for _, e in ipairs(built) do
        e.layout(y)
        y = y - BTN_SPACING * (e.rows or 1)
    end
end

-- Update(built, data) → 用服务端 data 刷新所有 extra 的显示
function ExtraBuilder.Update(built, data)
    for _, e in ipairs(built) do
        GLOBAL.pcall(e.update, data)
    end
end

-- Kill(built) → 面板销毁时隐藏所有 overlay 圆圈
function ExtraBuilder.Kill(built)
    if not DSTADMIN_RANGE_OVERLAY then return end
    for _, key in ipairs(built._overlay_keys or {}) do
        DSTADMIN_RANGE_OVERLAY.Hide(key)
    end
end

return ExtraBuilder
