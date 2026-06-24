-- ========== NPC 好感度介绍面板 Widget（HUD内嵌，固定宽、内容自适应高）==========


local AFF_PANEL_W = 360
local AFF_MARGIN_TOP = 56     -- 标题区到面板顶边的距离
local AFF_MARGIN_BOTTOM = 64  -- 返回按钮区到面板底边的距离
local ROW_GAIN_H = 30         -- 好感度提升方式每行高度
local ROW_UNLOCK_H = 42       -- 解锁内容每行高度
local SECTION_GAP = 20        -- 区块间距

local COLOR_PINK = { 1, 0.62, 0.7, 1 }
local COLOR_WHITE = { 1, 1, 1, 1 }
local COLOR_UNLOCKED = { 0.55, 0.9, 0.55, 1 }
local COLOR_LOCKED = { 0.75, 0.75, 0.75, 1 }  -- 未解锁状态（略亮于 0.6，深色底上更易读）
local COLOR_HEADER = { 1, 0.82, 0.4, 1 }
local COLOR_WARN = { 1, 0.5, 0.45, 1 }
local ROW_DEATH_H = 26       

local function unpack_or(t)
    return t[1], t[2], t[3], t[4]
end

local AFFINITY_INTRO = {
    wilson = {
        gains = {
            { label_key = "affinity_gain_baconeggs",  delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 0,   label_key = "affinity_unlock_follow" },
            { threshold = 10,  label_key = "affinity_unlock_show_npc" },
            { threshold = 100, label_key = "affinity_unlock_fishing" },
            { threshold = 300, label_key = "affinity_unlock_craft" },
        },
    },
    wathgrithr = {
        gains = {
            { label_key = "affinity_gain_turkeydinner", delta = 10 },
            { label_key = "affinity_gain_meat", delta = 1 },
        },
        unlocks = {
            { threshold = 1,   label_key = "affinity_unlock_follow" },
            { threshold = 30,  label_key = "affinity_unlock_wathgrithr_spear" },
            { threshold = 50,  label_key = "affinity_unlock_wathgrithr_helmet" },
            { threshold = 300, label_key = "affinity_unlock_battle_song" },
        },
    },
    wortox = {
        gains = {
            { label_key = "affinity_gain_pomegranate", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,   label_key = "affinity_unlock_follow" },
            { threshold = 100, label_key = "affinity_unlock_wortox_heal" },
        },
    },
    waxwell = {
        gains = {
            { label_key = "affinity_gain_lobsterdinner", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,   label_key = "affinity_unlock_follow" },
            { threshold = 30,  label_key = "affinity_unlock_waxwell_chest" },
            { threshold = 50,  label_key = "affinity_unlock_waxwell_protector" },
            { threshold = 200, label_key = "affinity_unlock_waxwell_prison" },
        },
    },
    wickerbottom = {
        gains = {
            { label_key = "affinity_gain_surfnturf", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,   label_key = "affinity_unlock_follow" },
            { threshold = 30,  label_key = "affinity_unlock_scholar_extinguish" },
            { threshold = 50,  label_key = "affinity_unlock_scholar_care" },
            { threshold = 100, label_key = "affinity_unlock_scholar_grow" },
        },
    },
    warly = {
        gains = {
            { label_key = "affinity_gain_prepared_food", delta = 5 },
            { label_key = "affinity_gain_ingredient_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,  label_key = "affinity_unlock_follow" },
            { threshold = 6, label_key = "affinity_unlock_work_here" },
        },
    },
    wormwood = {
        gains = {
            { label_key = "affinity_gain_seed_food", delta = 3 },
            { label_key = "affinity_gain_other_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,  label_key = "affinity_unlock_follow" },
            { threshold = 6, label_key = "affinity_unlock_work_here" },
        },
    },
    willow = {
        gains = {
            { label_key = "affinity_gain_hotchili", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = { { threshold = 1, label_key = "affinity_unlock_follow" } },
    },
    wx78 = {
        gains = {
            { label_key = "affinity_gain_butterflymuffin", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,  label_key = "affinity_unlock_follow" },
            { threshold = 10, label_key = "affinity_unlock_wx78_leap" },
        },
    },
    wolfgang = {
        gains = {
            { label_key = "affinity_gain_potato_cooked", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = { { threshold = 1, label_key = "affinity_unlock_follow" } },
    },
    wanda = {
        gains = {
            { label_key = "affinity_gain_taffy", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,  label_key = "affinity_unlock_follow" },
            { threshold = 10, label_key = "affinity_unlock_wanda_rift" },
        },
    },
    wendy = {
        gains = {
            { label_key = "affinity_gain_bananapop", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,  label_key = "affinity_unlock_follow" },
            { threshold = 50, label_key = "affinity_unlock_ocean_fishing" },
        },
    },
    winona = {
        gains = {
            { label_key = "affinity_gain_vegstinger", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,   label_key = "affinity_unlock_follow" },
            { threshold = 1,   label_key = "affinity_unlock_clean_here" },
            { threshold = 100, label_key = "affinity_unlock_winona_craft" },
        },
    },
    wes = {
        gains = {
            { label_key = "affinity_gain_freshfruitcrepes", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1, label_key = "affinity_unlock_follow" },
            { threshold = 1, label_key = "affinity_unlock_clean_here" },
        },
    },
    wilba = {
        gains = {
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,  label_key = "affinity_unlock_follow" },
            { threshold = 10, label_key = "affinity_unlock_wilba_quest" },
        },
    },
    walter = {
        gains = {
            { label_key = "affinity_gain_trailmix", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,   label_key = "affinity_unlock_follow" },
            { threshold = 1,   label_key = "affinity_unlock_walter_autostory" },
            { threshold = 100, label_key = "affinity_unlock_walter_craft" },
        },
    },
    woodie = {
        gains = {
            { label_key = "affinity_gain_honeynuggets", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,  label_key = "affinity_unlock_follow" },
            { threshold = 10, label_key = "affinity_unlock_woodie_chop" },
        },
    },
    wonkey = {
        gains = {
            { label_key = "affinity_gain_cave_banana", delta = 10 },
            { label_key = "affinity_gain_normal_food", delta = 1 },
        },
        unlocks = {
            { threshold = 1,   label_key = "affinity_unlock_follow" },
            { threshold = 50,  label_key = "affinity_unlock_wonkey_monkeytail" },
            { threshold = 100, label_key = "affinity_unlock_wonkey_bananabush" },
            { threshold = 200, label_key = "affinity_unlock_wonkey_ancienttree" },
        },
    },
}

local function GetIntro(char_type)
    return AFFINITY_INTRO[char_type or ""]
end

local function GetAffinityMax(data)
    return (data and data.affinity_max) or 400
end

NpcAffinityScreen = GLOBAL.Class(Widget, function(self, data, owner_param)
    Widget._ctor(self, "NpcAffinityWidget")

    self.owner_param = owner_param or ""
    self.data = data or {}
    local char_type = self.data.char_type or "wilson"
    self.intro = GetIntro(char_type)

    self.panel_bg = self:AddChild(Image("images/scoreboard.xml", "scoreboard_frame.tex"))

    self.back_btn = self:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    self.back_btn:SetScale(0.5)
    self.back_btn:SetHoverText(T("btn_affinity_close"), { offset_y = -28 })
    self.back_btn:SetOnClick(function() self:_CloseAll() end)

    -- 标题（角色名 + 好感度）
    self.title = self:AddChild(Text(GLOBAL.TITLEFONT, 28, ""))
    self.title:SetColour(unpack_or(COLOR_PINK))

    -- 好感度进度：数值文本 + 进度条
    self.progress_text = self:AddChild(Text(GLOBAL.UIFONT, 24, ""))
    self.progress_text:SetColour(unpack_or(COLOR_WHITE))
    self.bar_bg = self:AddChild(Image("images/global.xml", "square.tex"))
    self.bar_bg:SetTint(0.2, 0.2, 0.2, 0.8)
    self.bar_fill = self:AddChild(Image("images/global.xml", "square.tex"))
    self.bar_fill:SetTint(unpack_or(COLOR_PINK))

    -- 死亡惩罚说明（所有 NPC 通用，固定显示）
    self.death_note = self:AddChild(Text(GLOBAL.CHATFONT, 20, ""))
    self.death_note:SetColour(unpack_or(COLOR_WARN))

    -- 好感度提升方式 区块
    self.gain_header = self:AddChild(Text(GLOBAL.UIFONT, 22, T("affinity_section_gain")))
    self.gain_header:SetColour(unpack_or(COLOR_HEADER))
    self.gain_rows = {}
    if self.intro and self.intro.gains then
        for _, g in ipairs(self.intro.gains) do
            local row = self:AddChild(Text(GLOBAL.CHATFONT, 20, ""))
            row:SetColour(unpack_or(COLOR_WHITE))
            row._delta = g.delta
            row._label_key = g.label_key
            table.insert(self.gain_rows, row)
        end
    end

    -- 解锁内容 区块
    self.unlock_header = self:AddChild(Text(GLOBAL.UIFONT, 22, T("affinity_section_unlock")))
    self.unlock_header:SetColour(unpack_or(COLOR_HEADER))
    self.unlock_rows = {}
    if self.intro and self.intro.unlocks then
        for _, u in ipairs(self.intro.unlocks) do
            local desc = self:AddChild(Text(GLOBAL.CHATFONT, 20, ""))
            desc:SetColour(unpack_or(COLOR_WHITE))
            local status = self:AddChild(Text(GLOBAL.CHATFONT, 18, ""))
            status:SetColour(unpack_or(COLOR_LOCKED))
            table.insert(self.unlock_rows, {
                threshold = u.threshold,
                label_key = u.label_key,
                desc = desc,
                status = status,
            })
        end
    end

    -- 无配置角色：占位提示
    self.empty_text = self:AddChild(Text(GLOBAL.CHATFONT, 20, T("affinity_no_intro")))
    self.empty_text:SetColour(unpack_or(COLOR_LOCKED))

    -- 底部返回按钮
    self.back_text_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.back_text_btn:ForceImageSize(150, 40)
    self.back_text_btn:SetText(T("btn_affinity_back"))
    self.back_text_btn:SetFont(GLOBAL.CHATFONT)
    self.back_text_btn:SetTextSize(22)
    self.back_text_btn.scale_on_focus = false
    self.back_text_btn:SetOnClick(function() self:_Close() end)

    self:_ApplyLayout()
    self:UpdateData(self.data)
end)

function NpcAffinityScreen:_ComputeHeight()
    local content_h = 0
    content_h = content_h + 36              -- 标题
    content_h = content_h + 46              -- 进度（文本 + 进度条）
    content_h = content_h + ROW_DEATH_H     -- 死亡惩罚说明（通用）
    content_h = content_h + SECTION_GAP
    if self.intro then
        content_h = content_h + 28          -- 提升方式标题
        content_h = content_h + (#self.gain_rows) * ROW_GAIN_H
        content_h = content_h + SECTION_GAP
        content_h = content_h + 28          -- 解锁内容标题
        content_h = content_h + (#self.unlock_rows) * ROW_UNLOCK_H
    else
        content_h = content_h + 40          -- 占位提示
    end
    return AFF_MARGIN_TOP + content_h + AFF_MARGIN_BOTTOM
end

function NpcAffinityScreen:_ApplyLayout()
    local panel_h = self:_ComputeHeight()
    self.panel_bg:ScaleToSize(AFF_PANEL_W, panel_h)
    self.back_btn:SetPosition(AFF_PANEL_W / 2 - 18, panel_h / 2 - 36)

    local top = panel_h / 2
    local y = top - AFF_MARGIN_TOP

    self.title:SetPosition(0, y)
    y = y - 36

    self.progress_text:SetPosition(0, y)
    y = y - 24
    local bar_w = AFF_PANEL_W - 70
    self.bar_bg:SetSize(bar_w, 14)
    self.bar_bg:SetPosition(0, y)
    self._bar_w = bar_w
    self._bar_y = y
    self.bar_fill:SetPosition(0, y)
    y = y - 22

    -- 死亡惩罚说明（通用，左对齐）
    self.death_note:SetPosition(0, y)
    self.death_note:SetRegionSize(AFF_PANEL_W - 60, ROW_DEATH_H)
    self.death_note:SetHAlign(GLOBAL.ANCHOR_LEFT)
    y = y - ROW_DEATH_H - SECTION_GAP

    if self.intro then
        self.empty_text:Hide()

        local header_w = AFF_PANEL_W - 60
        local row_w = AFF_PANEL_W - 72

        self.gain_header:SetPosition(0, y)
        self.gain_header:SetRegionSize(header_w, 24)
        self.gain_header:SetHAlign(GLOBAL.ANCHOR_LEFT)
        y = y - 28
        for _, row in ipairs(self.gain_rows) do
            row:SetPosition(0, y)
            row:SetRegionSize(row_w, ROW_GAIN_H)
            row:SetHAlign(GLOBAL.ANCHOR_LEFT)
            y = y - ROW_GAIN_H
        end
        y = y - SECTION_GAP

        self.unlock_header:SetPosition(0, y)
        self.unlock_header:SetRegionSize(header_w, 24)
        self.unlock_header:SetHAlign(GLOBAL.ANCHOR_LEFT)
        y = y - 28
        for _, row in ipairs(self.unlock_rows) do
            row.desc:SetPosition(0, y + 8)
            row.desc:SetRegionSize(row_w, 22)
            row.desc:SetHAlign(GLOBAL.ANCHOR_LEFT)
            row.status:SetPosition(0, y - 12)
            row.status:SetRegionSize(row_w, 20)
            row.status:SetHAlign(GLOBAL.ANCHOR_LEFT)
            y = y - ROW_UNLOCK_H
        end
    else
        self.gain_header:Hide()
        self.unlock_header:Hide()
        self.empty_text:SetPosition(0, y - 20)
    end

    self.back_text_btn:SetPosition(0, -panel_h / 2 + 36)
end

function NpcAffinityScreen:UpdateData(data)
    if data then self.data = data end
    data = self.data or {}

    local display_name = data.display_name or data.char_type or "NPC"
    self.title:SetString(GLOBAL.tostring(display_name) .. " - " .. T("label_affinity"))

    local cur = data.affinity_cur or 0
    local maxv = GetAffinityMax(data)
    self.progress_text:SetString(T("label_affinity") .. ": " .. GLOBAL.tostring(cur) .. "/" .. GLOBAL.tostring(maxv))

    -- 死亡惩罚说明（所有 NPC 通用）：扣点数取自好感度模块常量
    local death_penalty = 10
    local aff_mod = GLOBAL.NPC_AFFINITY
    if aff_mod and aff_mod.DEATH_PENALTY then
        death_penalty = aff_mod.DEATH_PENALTY
    end
    self.death_note:SetString(string.format(T("affinity_death_note"), death_penalty))

    -- 进度条填充：左对齐增长
    local frac = 0
    if maxv > 0 then frac = math.max(0, math.min(1, cur / maxv)) end
    local bar_w = self._bar_w or (AFF_PANEL_W - 70)
    local fill_w = math.max(1, bar_w * frac)
    self.bar_fill:SetSize(fill_w, 14)
    self.bar_fill:SetPosition(-bar_w / 2 + fill_w / 2, self._bar_y or 0)

    for _, row in ipairs(self.gain_rows) do
        local sign = (row._delta or 0) >= 0 and "+" or ""
        row:SetString(T(row._label_key) .. "   " .. sign .. GLOBAL.tostring(row._delta))
    end

    for _, row in ipairs(self.unlock_rows) do
        local unlocked = cur >= (row.threshold or 0)
        row.desc:SetString(T(row.label_key))
        if unlocked then
            row.status:SetColour(unpack_or(COLOR_UNLOCKED))
            row.status:SetString(T("affinity_status_unlocked")
                .. "  (" .. T("label_affinity") .. " >= " .. GLOBAL.tostring(row.threshold) .. ")")
        else
            row.status:SetColour(unpack_or(COLOR_LOCKED))
            local need = math.max(0, (row.threshold or 0) - cur)
            row.status:SetString(T("affinity_status_locked")
                .. "  (" .. T("label_affinity") .. " >= " .. GLOBAL.tostring(row.threshold)
                .. ", " .. string.format(T("affinity_status_need"), need) .. ")")
        end
    end
end

-- 返回：关闭介绍界面并重新显示状态面板
function NpcAffinityScreen:_Close()
    local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
    if hud then
        hud._npc_affinity_open = nil
        hud._npc_affinity_widget = nil
        if hud._npc_status_widget and not hud._npc_status_widget._killed then
            hud._npc_status_widget:Show()
            hud._npc_status_widget:MoveToFront()
        end
    end
    self:Kill()
end

-- 关闭：关闭整个 NPC 面板（介绍界面 + 底层状态面板都关闭，不返回状态界面）
function NpcAffinityScreen:_CloseAll()
    local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
    if hud then
        hud._npc_affinity_open = nil
        hud._npc_affinity_widget = nil
        if hud._npc_status_widget and not hud._npc_status_widget._killed then
            -- 抑制短时间内自动刷新重开，行为对齐状态面板自身的关闭按钮
            hud._dstadmin_ui_suppress = hud._dstadmin_ui_suppress or {}
            hud._dstadmin_ui_suppress.npc_until = (GLOBAL.GetTime() or 0) + 0.8
            hud._dstadmin_ui_suppress.npc_owner_param = self.owner_param
            hud._npc_status_widget:Kill()
        end
        hud._npc_status_widget = nil
    end
    self:Kill()
end
