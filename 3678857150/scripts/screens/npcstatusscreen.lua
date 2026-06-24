-- ========== NPC 状态面板 Widget（HUD内嵌，显示 NPC 状态和控制按钮）==========

local PANEL_W = 340
local PANEL_H_BASE = 427
local BTN_H = 34
local BTN_SPACING = 42
local BTN_W = 130
-- 右上角控件（关闭按钮、战斗设置入口）的版式参数
-- TOP_BTN_X_OFFSET：按钮中心距面板右边的距离（数值越小越靠近右边）
-- TOP_BTN_Y_OFFSET：按钮中心距面板顶边的距离（数值越大越往下）
-- TOP_BTN_SPACING：close 与战斗按钮中心之间的水平距离
local TOP_BTN_X_OFFSET = 18
local TOP_BTN_Y_OFFSET = 38
local TOP_BTN_SPACING = 32
local SCHOLAR_FAST_REFRESH_INTERVAL = 0.1
local SCHOLAR_LOCAL_SMOOTH_INTERVAL = 0.05
local SUPPORTED_WORK_RANGE = { wormwood = true, warly = true, wes = true, winona = true, woodie = true, wortox = true, walter = true }
local SUPPORTED_SCHOLAR_RANGE = { wickerbottom = true }

local function _GetNPCTuningValue(key, default)
    local t = GLOBAL.NPC_TUNING
    if (t == nil or t[key] == nil) and GLOBAL.require ~= nil then
        local ok, mod = GLOBAL.pcall(GLOBAL.require, "npc_tuning")
        if ok and mod then
            t = mod
        end
    end
    local v = t and t[key]
    if type(v) == "number" and v > 0 then
        return v
    end
    return default
end

local function _GetRangeMax(char_type)
    local T = GLOBAL.NPC_TUNING
    if not T then return 30 end
    if char_type == "wes" then return T.WES_RANGE_MAX or 30
    elseif char_type == "winona" then return T.WINONA_RANGE_MAX or 50
    elseif char_type == "warly" then return T.COOK_RANGE_MAX or 30
    else return 30 end
end
local function _GetRangeMin(char_type)
    local T = GLOBAL.NPC_TUNING
    if not T then return 10 end
    if char_type == "wes" then return T.WES_RANGE_MIN or 10
    elseif char_type == "winona" then return T.WINONA_RANGE_MIN or 10
    elseif char_type == "warly" then return T.COOK_RANGE_MIN or 10
    else return 10 end
end

local function _NormalizeTTSVolume(value)
    value = GLOBAL.tonumber(value)
    if value == nil then return 0.5 end
    value = math.max(0, math.min(1, value))
    return math.floor(value / 0.05 + 0.5) * 0.05
end

local function _GetTTSVolume(char_type)
    local ok, volume = GLOBAL.pcall(function()
        local tts = GLOBAL.NPCFRIENDS_TTS
        if tts and tts.GetVolume then
            return tts.GetVolume(char_type)
        end
        local NT = GLOBAL.NPC_TUNING
        local volumes = NT and NT.TTS_VOLUME
        return volumes and (volumes[char_type] or volumes._default) or nil
    end)
    return _NormalizeTTSVolume(ok and volume or nil)
end

local function _FormatTTSVolume(value)
    return tostring(math.floor(_NormalizeTTSVolume(value) * 100 + 0.5)) .. "%"
end

local function _ShouldShowTTSVolume()
    local lang = nil
    if GLOBAL.rawget ~= nil then
        lang = GLOBAL.rawget(GLOBAL, "LANG")
    end
    if lang == nil then
        local ok, v = GLOBAL.pcall(function() return LANG end)
        if ok then lang = v end
    end
    return lang == "zh"
end
DSTADMIN_NPC_STATUS_PREFS = DSTADMIN_NPC_STATUS_PREFS or { show_range_by_owner = {}, show_scholar_by_owner = {}, show_fish_deposit_range_by_owner = {} }

NpcStatusScreen = GLOBAL.Class(Widget, function(self, data, owner_param)
    Widget._ctor(self, "NpcStatusWidget")

    self.owner_param = owner_param or ""
    self.data = data or {}
    self._last_btn_click_time = 0 -- 上次按钮点击时间，用于乐观更新保护
    self._show_work_range = DSTADMIN_NPC_STATUS_PREFS.show_range_by_owner[self.owner_param] == true
    self._show_scholar_care = DSTADMIN_NPC_STATUS_PREFS.show_scholar_by_owner[self.owner_param] == true
    DSTADMIN_NPC_STATUS_PREFS.show_scholar_growth_by_owner = DSTADMIN_NPC_STATUS_PREFS.show_scholar_growth_by_owner or {}
    self._show_scholar_growth = DSTADMIN_NPC_STATUS_PREFS.show_scholar_growth_by_owner[self.owner_param] == true
    DSTADMIN_NPC_STATUS_PREFS.show_fish_deposit_range_by_owner = DSTADMIN_NPC_STATUS_PREFS.show_fish_deposit_range_by_owner or {}
    self._show_fish_deposit_range = DSTADMIN_NPC_STATUS_PREFS.show_fish_deposit_range_by_owner[self.owner_param] == true
    DSTADMIN_NPC_STATUS_PREFS.show_wormwood_crop_deposit_range_by_owner = DSTADMIN_NPC_STATUS_PREFS.show_wormwood_crop_deposit_range_by_owner or {}
    DSTADMIN_NPC_STATUS_PREFS.show_wormwood_trash_deposit_range_by_owner = DSTADMIN_NPC_STATUS_PREFS.show_wormwood_trash_deposit_range_by_owner or {}
    self._show_wormwood_crop_deposit_range = DSTADMIN_NPC_STATUS_PREFS.show_wormwood_crop_deposit_range_by_owner[self.owner_param] == true
    self._show_wormwood_trash_deposit_range = DSTADMIN_NPC_STATUS_PREFS.show_wormwood_trash_deposit_range_by_owner[self.owner_param] == true
    self._fast_refresh_tasks = {}
    self._scholar_local_follow_task = nil
    self._scholar_track_inst = nil
    self._scholar_next_resolve_time = 0

    self.panel_bg = self:AddChild(Image("images/scoreboard.xml", "scoreboard_frame.tex"))

    self.close_btn = self:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    self.close_btn:SetScale(0.5)
    self.close_btn:SetOnClick(function()
        local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
        if hud then
            hud._dstadmin_ui_suppress = hud._dstadmin_ui_suppress or {}
            hud._dstadmin_ui_suppress.npc_until = (GLOBAL.GetTime() or 0) + 0.8
            hud._dstadmin_ui_suppress.npc_owner_param = self.owner_param
        end
        if hud then hud._npc_status_widget = nil end
        self:Kill()
    end)

    -- 战斗设置入口按钮（与关闭按钮并排，位于面板右上角）
    self.combat_btn = self:AddChild(TextButton())
    self.combat_btn:SetFont(GLOBAL.BUTTONFONT)
    self.combat_btn:SetTextSize(24)
    self.combat_btn:SetText("R")
    self.combat_btn:SetTextColour(1, 0.85, 0.4, 1)
    self.combat_btn:SetTextFocusColour(1, 1, 1, 1)
    self.combat_btn:SetHoverText(T("btn_combat_settings_tip"), { offset_y = -28 })
    self.combat_btn:SetOnClick(function()
        local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
        if hud and hud.ToggleNPCCombatSettingsScreen then
            hud:ToggleNPCCombatSettingsScreen()
        end
    end)
    self.combat_btn:Hide() -- 临时隐藏 R 入口；恢复显示时删除本行

    local char_type = (data and data.char_type) or "wilson"
    self.badge = self:AddChild(PlayerBadge(char_type, { 1, 1, 1, 1 }, false, 0))
    self.badge:SetScale(0.7)

    self.title = self:AddChild(Text(GLOBAL.TITLEFONT, 28, "NPC"))
    self.title:SetColour(1, 0.8, 0.3, 1)

    -- 图标复用原版衣柜界面的角色头像图标
    self.skin_btn = self:AddChild(ImageButton("images/button_icons.xml", "player_info.tex"))
    self.skin_btn:SetScale(0.1375)
    self.skin_btn.scale_on_focus = false
    self.skin_btn:SetImageNormalColour(1, 0.85, 0.4, 1)
    self.skin_btn:SetImageFocusColour(1, 1, 1, 1)
    self.skin_btn:SetHoverText(T("btn_npc_skin_tip"), { offset_y = -28 })
    self.skin_btn:SetOnClick(function()
        if not (NpcSkinPopup and GLOBAL.TheFrontEnd) then return end
        local char_prefab = (self.data and self.data.char_type) or "wilson"
        local initial_skins = self.data and self.data.npc_skins or nil
        GLOBAL.pcall(function()
            GLOBAL.TheFrontEnd:PushScreen(
                NpcSkinPopup(self.owner_param, char_prefab, GLOBAL.ThePlayer, GLOBAL.Profile, initial_skins))
        end)
    end)

    self.sep1 = self:AddChild(Image("images/global.xml", "square.tex"))
    self.sep1:SetSize(PANEL_W - 60, 2)
    self.sep1:SetTint(0.5, 0.5, 0.5, 0.5)

    self.follower_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_follower") .. ":"))
    self.follower_label:SetColour(1, 1, 1, 1)
    self.follower_value = self:AddChild(Text(GLOBAL.UIFONT, 22, ""))
    self.follower_value:SetColour(1, 1, 1, 1)

    self.sep_follower = self:AddChild(Image("images/global.xml", "square.tex"))
    self.sep_follower:SetSize(PANEL_W - 60, 2)
    self.sep_follower:SetTint(0.5, 0.5, 0.5, 0.5)

    self.hu_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_hunger") .. ":"))
    self.hu_label:SetColour(1, 1, 1, 1)
    self.hu_value = self:AddChild(Text(GLOBAL.UIFONT, 22, ""))
    self.hu_value:SetColour(1, 1, 1, 1)

    self.hp_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_health") .. ":"))
    self.hp_label:SetColour(1, 1, 1, 1)
    self.hp_value = self:AddChild(Text(GLOBAL.UIFONT, 22, ""))
    self.hp_value:SetColour(1, 1, 1, 1)

    -- 好感度（替换原精神值行）：标签 + 数值 + 右侧好感度图标按键
    self.affinity_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_affinity") .. ":"))
    self.affinity_label:SetColour(1, 1, 1, 1)
    self.affinity_value = self:AddChild(Text(GLOBAL.UIFONT, 22, ""))
    self.affinity_value:SetColour(1, 1, 1, 1)

    -- 好感度图标按键（爱心图标）：点击后隐藏状态面板，在原位置打开好感度介绍界面
    self.affinity_btn = self:AddChild(ImageButton("images/crafting_menu.xml", "favorite_checked.tex"))
    self.affinity_btn:ForceImageSize(26, 26)
    self.affinity_btn.scale_on_focus = false
    self.affinity_btn:SetImageNormalColour(1, 0.62, 0.7, 1)
    self.affinity_btn:SetImageFocusColour(1, 0.9, 0.92, 1)
    self.affinity_btn:SetHoverText(T("btn_npc_affinity_tip"), { offset_y = -28 })
    self.affinity_btn:SetOnClick(function()
        self:_OpenAffinityScreen()
    end)
    do
        local aff = GLOBAL.NPC_AFFINITY
        if aff and aff.IsEnabled and not aff.IsEnabled() then
            self.affinity_btn:Hide()
        end
    end

    self.sep2 = self:AddChild(Image("images/global.xml", "square.tex"))
    self.sep2:SetSize(PANEL_W - 60, 2)
    self.sep2:SetTint(0.5, 0.5, 0.5, 0.5)

    self.follow_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.follow_btn:ForceImageSize(BTN_W, BTN_H)
    self.follow_btn:SetText(T("btn_follow"))
    self.follow_btn:SetFont(GLOBAL.CHATFONT)
    self.follow_btn:SetTextSize(18)
    self.follow_btn.scale_on_focus = false
    self.follow_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        self._follow_optimistic_state = true
        self._follow_optimistic_until = self._last_btn_click_time + 0.8
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"), "Follow|" .. self.owner_param)
        end)
        self.data.is_following = true
        self.follow_btn:Disable()
        self.unfollow_btn:Enable()
        self:_ApplyOptimisticAbilityState("Follow")
        self:_RequestDelayedRefresh(0.15)
    end)

    self.unfollow_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.unfollow_btn:ForceImageSize(BTN_W, BTN_H)
    self.unfollow_btn:SetText(T("btn_unfollow"))
    self.unfollow_btn:SetFont(GLOBAL.CHATFONT)
    self.unfollow_btn:SetTextSize(18)
    self.unfollow_btn.scale_on_focus = false
    self.unfollow_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        self._follow_optimistic_state = false
        self._follow_optimistic_until = self._last_btn_click_time + 0.8
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"), "Unfollow|" .. self.owner_param)
        end)
        self.data.is_following = false
        self.follow_btn:Enable()
        self.unfollow_btn:Disable()
        self:_RequestDelayedRefresh(0.15)
    end)

    self.ability_btns = {}
    self.ability_container = self:AddChild(Widget("ability_container"))

    -- 功能键下方：显示工作范围（勾选）
    self.work_range_toggle_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.work_range_toggle_btn:ForceImageSize(BTN_W, BTN_H)
    self.work_range_toggle_btn:SetFont(GLOBAL.CHATFONT)
    self.work_range_toggle_btn:SetTextSize(16)
    self.work_range_toggle_btn.scale_on_focus = false
    self.work_range_toggle_btn:SetOnClick(function()
        self._show_work_range = not self._show_work_range
        DSTADMIN_NPC_STATUS_PREFS.show_range_by_owner[self.owner_param] = self._show_work_range and true or false
        self:_RefreshWorkRangeToggleText()
        self:_UpdateWorkRangeInfo(self.data or {})
    end)
    self:_RefreshWorkRangeToggleText()

    -- 维斯/薇诺娜专用：是否执行容器归类整理
    self._collect_organize_enabled = true
    self.collect_organize_toggle_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.collect_organize_toggle_btn:ForceImageSize(BTN_W, BTN_H)
    self.collect_organize_toggle_btn:SetFont(GLOBAL.CHATFONT)
    self.collect_organize_toggle_btn:SetTextSize(16)
    self.collect_organize_toggle_btn.scale_on_focus = false
    self.collect_organize_toggle_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        self._collect_organize_enabled = not (self._collect_organize_enabled == true)
        self:_RefreshCollectOrganizeToggleText()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                "ToggleCollectOrganize|" .. self.owner_param)
        end)
        self:_RequestDelayedRefresh()
    end)
    self.collect_organize_toggle_btn:Hide()
    self:_RefreshCollectOrganizeToggleText()

    -- 薇克巴顿专用：控温灭火范围显示按钮（只读）
    self.scholar_care_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.scholar_care_btn:ForceImageSize(BTN_W, BTN_H)
    self.scholar_care_btn:SetFont(GLOBAL.CHATFONT)
    self.scholar_care_btn:SetTextSize(16)
    self.scholar_care_btn.scale_on_focus = false
    self.scholar_care_btn:SetOnClick(function()
        self._show_scholar_care = not self._show_scholar_care
        DSTADMIN_NPC_STATUS_PREFS.show_scholar_by_owner[self.owner_param] = self._show_scholar_care and true or false
        self:_RefreshScholarCareToggleText()
        self:_UpdateScholarCareInfo(self.data or {})
    end)
    self:_RefreshScholarCareToggleText()

    -- 薇克巴顿专用：催熟作物范围显示按钮（只读）
    self.scholar_growth_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.scholar_growth_btn:ForceImageSize(BTN_W, BTN_H)
    self.scholar_growth_btn:SetFont(GLOBAL.CHATFONT)
    self.scholar_growth_btn:SetTextSize(16)
    self.scholar_growth_btn.scale_on_focus = false
    self.scholar_growth_btn:SetOnClick(function()
        self._show_scholar_growth = not self._show_scholar_growth
        DSTADMIN_NPC_STATUS_PREFS.show_scholar_growth_by_owner[self.owner_param] = self._show_scholar_growth and true or false
        self:_RefreshScholarGrowthToggleText()
        self:_UpdateScholarGrowthInfo(self.data or {})
    end)
    self:_RefreshScholarGrowthToggleText()

    -- ── 吴迪专用：砍树尺寸过滤（小/中/大），点击切换状态后通过 NPCCommand RPC 同步到服务端 ──
    -- 客户端只显示 data.chop_filter 同步过来的状态；点击立即乐观更新本地状态以避免延迟
    self._chop_filter = { small = true, medium = true, big = true }
    local function _MakeChopFilterButton(key, label_key)
        local btn = self:AddChild(ImageButton("images/global_redux.xml",
            "button_carny_long_normal.tex", "button_carny_long_hover.tex",
            "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
        btn:ForceImageSize(BTN_W, BTN_H)
        btn:SetFont(GLOBAL.CHATFONT)
        btn:SetTextSize(16)
        btn.scale_on_focus = false
        btn._chop_filter_key = key
        btn._chop_filter_label_key = label_key
        btn:SetOnClick(function()
            self._last_btn_click_time = GLOBAL.GetTime()
            local cur = self._chop_filter[key] ~= false
            self._chop_filter[key] = not cur
            self:_RefreshChopFilterText(btn)
            local cmd_map = {
                small  = "ToggleChopFilterSmall",
                medium = "ToggleChopFilterMedium",
                big    = "ToggleChopFilterBig",
            }
            local cmd = cmd_map[key]
            if cmd then
                GLOBAL.pcall(function()
                    SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                        cmd .. "|" .. self.owner_param)
                end)
            end
        end)
        btn:Hide()
        return btn
    end
    self.chop_big_btn    = _MakeChopFilterButton("big",    "label_chop_big")
    self.chop_medium_btn = _MakeChopFilterButton("medium", "label_chop_medium")
    self.chop_small_btn  = _MakeChopFilterButton("small",  "label_chop_small")

    -- 吴迪专用：挖树根开关（默认 OFF）
    self._dig_stump = false
    self.dig_stump_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.dig_stump_btn:ForceImageSize(BTN_W, BTN_H)
    self.dig_stump_btn:SetFont(GLOBAL.CHATFONT)
    self.dig_stump_btn:SetTextSize(16)
    self.dig_stump_btn.scale_on_focus = false
    self.dig_stump_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        self._dig_stump = not (self._dig_stump == true)
        self:_RefreshDigStumpText()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                "ToggleDigStump|" .. self.owner_param)
        end)
    end)
    self.dig_stump_btn:Hide()

    -- 吴迪专用：砍多枝树开关（默认 ON）
    self._chop_twiggy = true
    self.chop_twiggy_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.chop_twiggy_btn:ForceImageSize(BTN_W, BTN_H)
    self.chop_twiggy_btn:SetFont(GLOBAL.CHATFONT)
    self.chop_twiggy_btn:SetTextSize(16)
    self.chop_twiggy_btn.scale_on_focus = false
    self.chop_twiggy_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        self._chop_twiggy = not (self._chop_twiggy ~= false)
        self:_RefreshChopTwiggyText()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                "ToggleChopTwiggy|" .. self.owner_param)
        end)
    end)
    self.chop_twiggy_btn:Hide()

    -- 厨师专用：最大同食物数量 Spinner
    self._cook_max_value = (GLOBAL.NPC_TUNING and GLOBAL.NPC_TUNING.COOK_SAME_DISH_MAX) or 8

    self.cook_max_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_cook_max_dish") .. ":"))
    self.cook_max_label:SetColour(1, 1, 1, 1)

    self.cook_max_left_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_left.tex", "arrow2_left_over.tex",
        "arrow_left_disabled.tex", "arrow2_left_down.tex"))
    self.cook_max_left_btn:SetScale(0.2)
    self.cook_max_left_btn.scale_on_focus = false
    self.cook_max_left_btn:SetOnClick(function()
        self:_ChangeCookMax(-1)
    end)

    self.cook_max_value_text = self:AddChild(Text(GLOBAL.UIFONT, 22, tostring(self._cook_max_value)))
    self.cook_max_value_text:SetColour(1, 1, 1, 1)

    self.cook_max_right_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_right.tex", "arrow2_right_over.tex",
        "arrow_right_disabled.tex", "arrow2_right_down.tex"))
    self.cook_max_right_btn:SetScale(0.2)
    self.cook_max_right_btn.scale_on_focus = false
    self.cook_max_right_btn:SetOnClick(function()
        self:_ChangeCookMax(1)
    end)

    -- 整理范围 Spinner（wes/winona 共享）
    self._organize_range_value = 30
    GLOBAL.pcall(function()
        local NT = GLOBAL.NPC_TUNING
        if NT then
            if (data and data.char_type == "winona") then
                self._organize_range_value = NT.WINONA_PATROL_RADIUS or 50
            else
                self._organize_range_value = NT.WES_PATROL_RADIUS or 30
            end
        end
    end)

    self.organize_range_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_organize_range") .. ":"))
    self.organize_range_label:SetColour(1, 1, 1, 1)

    self.organize_range_left_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_left.tex", "arrow2_left_over.tex",
        "arrow_left_disabled.tex", "arrow2_left_down.tex"))
    self.organize_range_left_btn:SetScale(0.2)
    self.organize_range_left_btn.scale_on_focus = false
    self.organize_range_left_btn:SetOnClick(function()
        self:_ChangeOrganizeRange(-1)
    end)

    self.organize_range_value_text = self:AddChild(Text(GLOBAL.UIFONT, 22, tostring(self._organize_range_value)))
    self.organize_range_value_text:SetColour(1, 1, 1, 1)

    self.organize_range_right_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_right.tex", "arrow2_right_over.tex",
        "arrow_right_disabled.tex", "arrow2_right_down.tex"))
    self.organize_range_right_btn:SetScale(0.2)
    self.organize_range_right_btn.scale_on_focus = false
    self.organize_range_right_btn:SetOnClick(function()
        self:_ChangeOrganizeRange(1)
    end)

    -- 钓鱼最大次数控件（Wilson 专用）
    self._fish_max_value = (GLOBAL.NPC_TUNING and GLOBAL.NPC_TUNING.FISHING_MAX_CATCH) or 3

    self.fish_max_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_fish_max_catch") .. ":"))
    self.fish_max_label:SetColour(1, 1, 1, 1)

    self.fish_max_left_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_left.tex", "arrow2_left_over.tex",
        "arrow_left_disabled.tex", "arrow2_left_down.tex"))
    self.fish_max_left_btn:SetScale(0.2)
    self.fish_max_left_btn.scale_on_focus = false
    self.fish_max_left_btn:SetOnClick(function()
        self:_ChangeFishMax(-1)
    end)

    self.fish_max_value_text = self:AddChild(Text(GLOBAL.UIFONT, 22, tostring(self._fish_max_value)))
    self.fish_max_value_text:SetColour(1, 1, 1, 1)

    self.fish_max_right_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_right.tex", "arrow2_right_over.tex",
        "arrow_right_disabled.tex", "arrow2_right_down.tex"))
    self.fish_max_right_btn:SetScale(0.2)
    self.fish_max_right_btn.scale_on_focus = false
    self.fish_max_right_btn:SetOnClick(function()
        self:_ChangeFishMax(1)
    end)

    -- 钓鱼存放点按钮（Wilson 专用）
    self.fish_deposit_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.fish_deposit_btn:ForceImageSize(BTN_W, BTN_H)
    self.fish_deposit_btn:SetFont(GLOBAL.BUTTONFONT)
    self.fish_deposit_btn:SetTextSize(16)
    self.fish_deposit_btn.scale_on_focus = false
    self.fish_deposit_btn:SetText(T("btn_fish_deposit"))
    self.fish_deposit_btn:SetOnClick(function()
        local UiModes = GLOBAL.require("npc_ui_modes")
        if UiModes and UiModes.StartFishDepositMode then
            UiModes.StartFishDepositMode(self.owner_param)
        end
    end)
    self.fish_deposit_btn:Hide()

    -- 钓鱼存放点范围显示按钮（Wilson 专用）
    self.fish_deposit_range_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.fish_deposit_range_btn:ForceImageSize(BTN_W, BTN_H)
    self.fish_deposit_range_btn:SetFont(GLOBAL.CHATFONT)
    self.fish_deposit_range_btn:SetTextSize(16)
    self.fish_deposit_range_btn.scale_on_focus = false
    self.fish_deposit_range_btn:SetOnClick(function()
        self._show_fish_deposit_range = not self._show_fish_deposit_range
        DSTADMIN_NPC_STATUS_PREFS.show_fish_deposit_range_by_owner[self.owner_param] = self._show_fish_deposit_range and true or false
        self:_RefreshFishDepositRangeText()
        self:_UpdateFishDepositRange(self.data or {})
    end)
    self:_RefreshFishDepositRangeText()
    self.fish_deposit_range_btn:Hide()

    self.wilson_npc_locations_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wilson_npc_locations_btn:ForceImageSize(BTN_W, BTN_H)
    self.wilson_npc_locations_btn:SetFont(GLOBAL.CHATFONT)
    self.wilson_npc_locations_btn:SetTextSize(16)
    self.wilson_npc_locations_btn.scale_on_focus = false
    self.wilson_npc_locations_btn:SetText(T("btn_wilson_show_npc_locations"))
    self.wilson_npc_locations_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                "WilsonShowNPCLocations|" .. self.owner_param)
        end)
        self:_RequestDelayedRefresh()
    end)
    self.wilson_npc_locations_btn:Hide()

    self.wilson_unlock_transmute_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wilson_unlock_transmute_btn:ForceImageSize(BTN_W, BTN_H)
    self.wilson_unlock_transmute_btn:SetFont(GLOBAL.CHATFONT)
    self.wilson_unlock_transmute_btn:SetTextSize(16)
    self.wilson_unlock_transmute_btn.scale_on_focus = false
    self.wilson_unlock_transmute_btn:SetText(T("btn_wilson_unlock_transmute"))
    self.wilson_unlock_transmute_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                "UnlockWilsonTransmuteTech|" .. self.owner_param)
        end)
        self:_RequestDelayedRefresh()
    end)
    self.wilson_unlock_transmute_btn:Hide()

    self.wilson_purebrilliance_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wilson_purebrilliance_btn:ForceImageSize(BTN_W, BTN_H)
    self.wilson_purebrilliance_btn:SetFont(GLOBAL.CHATFONT)
    self.wilson_purebrilliance_btn:SetTextSize(16)
    self.wilson_purebrilliance_btn.scale_on_focus = false
    self.wilson_purebrilliance_btn:SetText(T("btn_wilson_purebrilliance"))
    self.wilson_purebrilliance_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                "WilsonCraftPureBrilliance|" .. self.owner_param)
        end)
        self:_RequestDelayedRefresh()
    end)
    self.wilson_purebrilliance_btn:Hide()

    self.wilson_horrorfuel_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wilson_horrorfuel_btn:ForceImageSize(BTN_W, BTN_H)
    self.wilson_horrorfuel_btn:SetFont(GLOBAL.CHATFONT)
    self.wilson_horrorfuel_btn:SetTextSize(16)
    self.wilson_horrorfuel_btn.scale_on_focus = false
    self.wilson_horrorfuel_btn:SetText(T("btn_wilson_horrorfuel"))
    self.wilson_horrorfuel_btn:SetOnClick(function()
        self._last_btn_click_time = GLOBAL.GetTime()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"),
                "WilsonCraftHorrorfuel|" .. self.owner_param)
        end)
        self:_RequestDelayedRefresh()
    end)
    self.wilson_horrorfuel_btn:Hide()

    -- 植物人作物存放点按钮
    self.wormwood_crop_deposit_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wormwood_crop_deposit_btn:ForceImageSize(BTN_W, BTN_H)
    self.wormwood_crop_deposit_btn:SetFont(GLOBAL.BUTTONFONT)
    self.wormwood_crop_deposit_btn:SetTextSize(16)
    self.wormwood_crop_deposit_btn.scale_on_focus = false
    self.wormwood_crop_deposit_btn:SetText(T("btn_wormwood_crop_deposit"))
    self.wormwood_crop_deposit_btn:SetOnClick(function()
        local UiModes = GLOBAL.require("npc_ui_modes")
        if UiModes and UiModes.StartWormwoodCropDepositMode then
            UiModes.StartWormwoodCropDepositMode(self.owner_param)
        end
    end)
    self.wormwood_crop_deposit_btn:Hide()

    self.wormwood_crop_deposit_range_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wormwood_crop_deposit_range_btn:ForceImageSize(BTN_W, BTN_H)
    self.wormwood_crop_deposit_range_btn:SetFont(GLOBAL.CHATFONT)
    self.wormwood_crop_deposit_range_btn:SetTextSize(16)
    self.wormwood_crop_deposit_range_btn.scale_on_focus = false
    self.wormwood_crop_deposit_range_btn:SetOnClick(function()
        self._show_wormwood_crop_deposit_range = not self._show_wormwood_crop_deposit_range
        DSTADMIN_NPC_STATUS_PREFS.show_wormwood_crop_deposit_range_by_owner[self.owner_param] = self._show_wormwood_crop_deposit_range and true or false
        self:_RefreshWormwoodCropDepositRangeText()
        self:_UpdateWormwoodCropDepositRange(self.data or {})
    end)
    self:_RefreshWormwoodCropDepositRangeText()
    self.wormwood_crop_deposit_range_btn:Hide()

    -- 植物人垃圾存放点按钮
    self.wormwood_trash_deposit_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wormwood_trash_deposit_btn:ForceImageSize(BTN_W, BTN_H)
    self.wormwood_trash_deposit_btn:SetFont(GLOBAL.BUTTONFONT)
    self.wormwood_trash_deposit_btn:SetTextSize(16)
    self.wormwood_trash_deposit_btn.scale_on_focus = false
    self.wormwood_trash_deposit_btn:SetText(T("btn_wormwood_trash_deposit"))
    self.wormwood_trash_deposit_btn:SetOnClick(function()
        local UiModes = GLOBAL.require("npc_ui_modes")
        if UiModes and UiModes.StartWormwoodTrashDepositMode then
            UiModes.StartWormwoodTrashDepositMode(self.owner_param)
        end
    end)
    self.wormwood_trash_deposit_btn:Hide()

    self.wormwood_trash_deposit_range_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.wormwood_trash_deposit_range_btn:ForceImageSize(BTN_W, BTN_H)
    self.wormwood_trash_deposit_range_btn:SetFont(GLOBAL.CHATFONT)
    self.wormwood_trash_deposit_range_btn:SetTextSize(16)
    self.wormwood_trash_deposit_range_btn.scale_on_focus = false
    self.wormwood_trash_deposit_range_btn:SetOnClick(function()
        self._show_wormwood_trash_deposit_range = not self._show_wormwood_trash_deposit_range
        DSTADMIN_NPC_STATUS_PREFS.show_wormwood_trash_deposit_range_by_owner[self.owner_param] = self._show_wormwood_trash_deposit_range and true or false
        self:_RefreshWormwoodTrashDepositRangeText()
        self:_UpdateWormwoodTrashDepositRange(self.data or {})
    end)
    self:_RefreshWormwoodTrashDepositRangeText()
    self.wormwood_trash_deposit_range_btn:Hide()

    -- 温蒂海钓最大捕获数 Spinner
    self._ocean_fish_max_value = (GLOBAL.NPC_TUNING and GLOBAL.NPC_TUNING.OCEAN_FISHING_MAX_CATCH) or 5

    self.ocean_fish_max_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_ocean_fish_max_catch") .. ":"))
    self.ocean_fish_max_label:SetColour(1, 1, 1, 1)

    self.ocean_fish_max_left_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_left.tex", "arrow2_left_over.tex",
        "arrow_left_disabled.tex", "arrow2_left_down.tex"))
    self.ocean_fish_max_left_btn:SetScale(0.2)
    self.ocean_fish_max_left_btn.scale_on_focus = false
    self.ocean_fish_max_left_btn:SetOnClick(function()
        self:_ChangeOceanFishMax(-1)
    end)

    self.ocean_fish_max_value_text = self:AddChild(Text(GLOBAL.UIFONT, 22, tostring(self._ocean_fish_max_value)))
    self.ocean_fish_max_value_text:SetColour(1, 1, 1, 1)

    self.ocean_fish_max_right_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_right.tex", "arrow2_right_over.tex",
        "arrow_right_disabled.tex", "arrow2_right_down.tex"))
    self.ocean_fish_max_right_btn:SetScale(0.2)
    self.ocean_fish_max_right_btn.scale_on_focus = false
    self.ocean_fish_max_right_btn:SetOnClick(function()
        self:_ChangeOceanFishMax(1)
    end)

    -- 温蒂海钓存放点按钮
    self.ocean_fish_deposit_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.ocean_fish_deposit_btn:ForceImageSize(BTN_W, BTN_H)
    self.ocean_fish_deposit_btn:SetFont(GLOBAL.BUTTONFONT)
    self.ocean_fish_deposit_btn:SetTextSize(16)
    self.ocean_fish_deposit_btn.scale_on_focus = false
    self.ocean_fish_deposit_btn:SetText(T("btn_ocean_fish_deposit"))
    self.ocean_fish_deposit_btn:SetOnClick(function()
        local UiModes = GLOBAL.require("npc_ui_modes")
        if UiModes and UiModes.StartOceanFishDepositMode then
            UiModes.StartOceanFishDepositMode(self.owner_param)
        end
    end)
    self.ocean_fish_deposit_btn:Hide()

    -- 温蒂海钓存放点范围显示按钮
    DSTADMIN_NPC_STATUS_PREFS.show_ocean_fish_deposit_range_by_owner = DSTADMIN_NPC_STATUS_PREFS.show_ocean_fish_deposit_range_by_owner or {}
    self._show_ocean_fish_deposit_range = DSTADMIN_NPC_STATUS_PREFS.show_ocean_fish_deposit_range_by_owner[self.owner_param] == true
    self.ocean_fish_deposit_range_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.ocean_fish_deposit_range_btn:ForceImageSize(BTN_W, BTN_H)
    self.ocean_fish_deposit_range_btn:SetFont(GLOBAL.CHATFONT)
    self.ocean_fish_deposit_range_btn:SetTextSize(16)
    self.ocean_fish_deposit_range_btn.scale_on_focus = false
    self.ocean_fish_deposit_range_btn:SetOnClick(function()
        self._show_ocean_fish_deposit_range = not self._show_ocean_fish_deposit_range
        DSTADMIN_NPC_STATUS_PREFS.show_ocean_fish_deposit_range_by_owner[self.owner_param] = self._show_ocean_fish_deposit_range and true or false
        self:_RefreshOceanFishDepositRangeText()
        self:_UpdateOceanFishDepositRange(self.data or {})
    end)
    self:_RefreshOceanFishDepositRangeText()
    self.ocean_fish_deposit_range_btn:Hide()

    -- 温蒂海钓杀鱼开关按钮
    self._ocean_fish_murder_enabled = false -- 由 _UpdateOceanFishMurder 从服务端同步实际值
    self.ocean_fish_murder_btn = self:AddChild(ImageButton("images/global_redux.xml",
        "button_carny_long_normal.tex", "button_carny_long_hover.tex",
        "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
    self.ocean_fish_murder_btn:ForceImageSize(BTN_W, BTN_H)
    self.ocean_fish_murder_btn:SetFont(GLOBAL.CHATFONT)
    self.ocean_fish_murder_btn:SetTextSize(16)
    self.ocean_fish_murder_btn.scale_on_focus = false
    self.ocean_fish_murder_btn:SetOnClick(function()
        self._ocean_fish_murder_enabled = not self._ocean_fish_murder_enabled
        self:_RefreshOceanFishMurderText()
        GLOBAL.pcall(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "SetOceanFishMurderEnabled"),
                self._ocean_fish_murder_enabled and "true" or "false")
        end)
    end)
    self:_RefreshOceanFishMurderText()
    self.ocean_fish_murder_btn:Hide()

    -- 通用：NPC TTS 音量 Spinner（所有角色显示，固定排在面板最底部）
    self._tts_volume_value = _GetTTSVolume((data and data.char_type) or "wilson")

    self.tts_volume_label = self:AddChild(Text(GLOBAL.UIFONT, 22, T("label_tts_volume") .. ":"))
    self.tts_volume_label:SetColour(1, 1, 1, 1)

    self.tts_volume_left_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_left.tex", "arrow2_left_over.tex",
        "arrow_left_disabled.tex", "arrow2_left_down.tex"))
    self.tts_volume_left_btn:SetScale(0.2)
    self.tts_volume_left_btn.scale_on_focus = false
    self.tts_volume_left_btn:SetOnClick(function()
        self:_ChangeTTSVolume(-0.1)
    end)

    self.tts_volume_value_text = self:AddChild(Text(GLOBAL.UIFONT, 22, _FormatTTSVolume(self._tts_volume_value)))
    self.tts_volume_value_text:SetColour(1, 1, 1, 1)

    self.tts_volume_right_btn = self:AddChild(ImageButton("images/ui.xml",
        "arrow2_right.tex", "arrow2_right_over.tex",
        "arrow_right_disabled.tex", "arrow2_right_down.tex"))
    self.tts_volume_right_btn:SetScale(0.2)
    self.tts_volume_right_btn.scale_on_focus = false
    self.tts_volume_right_btn:SetOnClick(function()
        self:_ChangeTTSVolume(0.1)
    end)

    self:UpdateData(data)

    self.auto_refresh_task = GLOBAL.ThePlayer:DoPeriodicTask(2, function()
        if not self._killed then
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCStatus"), self.owner_param)
            end)
        end
    end)

    local _base_kill = self.Kill
    self.Kill = function(s)
        s._killed = true
        if s.auto_refresh_task then
            s.auto_refresh_task:Cancel()
            s.auto_refresh_task = nil
        end
        if s._fast_refresh_tasks then
            for _, task in pairs(s._fast_refresh_tasks) do
                if task then task:Cancel() end
            end
            s._fast_refresh_tasks = {}
        end
        if s._scholar_local_follow_task then
            s._scholar_local_follow_task:Cancel()
            s._scholar_local_follow_task = nil
        end
        s._scholar_track_inst = nil
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(s.owner_param) -- 兼容旧 key（迁移清理）
            DSTADMIN_RANGE_OVERLAY.Hide(s:_WorkRangeOverlayKey())
            DSTADMIN_RANGE_OVERLAY.Hide(s:_ScholarOverlayKey())
            DSTADMIN_RANGE_OVERLAY.Hide(s:_ScholarGrowthOverlayKey())
            DSTADMIN_RANGE_OVERLAY.Hide(s:_FishDepositRangeKey())
            DSTADMIN_RANGE_OVERLAY.Hide(s:_WormwoodCropDepositRangeKey())
            DSTADMIN_RANGE_OVERLAY.Hide(s:_WormwoodTrashDepositRangeKey())
            DSTADMIN_RANGE_OVERLAY.Hide(s:_OceanFishDepositRangeKey())
        end
        if _base_kill then _base_kill(s) end
    end
end)

-- 按钮点击后延迟请求一次完整状态，加速关联按钮刷新
function NpcStatusScreen:_RequestDelayedRefresh(delay)
    if GLOBAL.ThePlayer and not self._killed then
        if self._delayed_refresh_task then
            self._delayed_refresh_task:Cancel()
            self._delayed_refresh_task = nil
        end
        self._delayed_refresh_task = GLOBAL.ThePlayer:DoTaskInTime(delay or 0.5, function()
            self._delayed_refresh_task = nil
            if not self._killed then
                GLOBAL.pcall(function()
                    SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCStatus"), self.owner_param)
                end)
            end
        end)
    end
end

-- 通用高速刷新管理
function NpcStatusScreen:_SetFastRefresh(key, enabled, interval)
    if not key or key == "" then return end
    self._fast_refresh_tasks = self._fast_refresh_tasks or {}
    if enabled then
        if self._fast_refresh_tasks[key] == nil then
            self._fast_refresh_tasks[key] = GLOBAL.ThePlayer:DoPeriodicTask(interval or SCHOLAR_FAST_REFRESH_INTERVAL, function()
                if not self._killed then
                    GLOBAL.pcall(function()
                        SendModRPCToServer(GetModRPC("DstAdmin", "RequestNPCStatus"), self.owner_param)
                    end)
                end
            end)
        end
    else
        if self._fast_refresh_tasks[key] ~= nil then
            self._fast_refresh_tasks[key]:Cancel()
            self._fast_refresh_tasks[key] = nil
        end
    end
end

function NpcStatusScreen:_SetScholarFastRefresh(enabled)
    self:_SetFastRefresh("scholar_care", enabled, SCHOLAR_FAST_REFRESH_INTERVAL)
end

function NpcStatusScreen:_WorkRangeOverlayKey()
    return (self.owner_param or "") .. "#work"
end

function NpcStatusScreen:_ScholarOverlayKey()
    return (self.owner_param or "") .. "#scholar"
end

function NpcStatusScreen:_ScholarGrowthOverlayKey()
    return (self.owner_param or "") .. "#scholar_growth"
end

local function _ParseOwnerParam(owner_param)
    if type(owner_param) ~= "string" then return nil, nil, nil end
    local p1, p2, p3 = owner_param:match("^([^:]+):([^:]+):([^:]+)$")
    if p1 and p2 and p3 then
        return p1, p2, GLOBAL.tonumber(p3)
    end
    return nil, nil, nil
end

function NpcStatusScreen:_ResolveScholarTrackInst()
    if self._scholar_track_inst and self._scholar_track_inst:IsValid() then
        return self._scholar_track_inst
    end
    local now = GLOBAL.GetTime and GLOBAL.GetTime() or 0
    if now < (self._scholar_next_resolve_time or 0) then
        return nil
    end
    self._scholar_next_resolve_time = now + 0.5

    local owner_userid, char_type, slot_index = _ParseOwnerParam(self.owner_param)
    local ents = GLOBAL.Ents or {}
    local fallback = nil
    for _, ent in pairs(ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            local ent_char = ent.npc_character_net and ent.npc_character_net:value() or ""
            local ent_owner = ent.owner_userid and ent.owner_userid:value() or ""
            local ent_slot = ent.npc_slot_index_net and ent.npc_slot_index_net:value() or nil
            if owner_userid and ent_owner == owner_userid and ent_char == (char_type or "") then
                if slot_index ~= nil and ent_slot == slot_index then
                    self._scholar_track_inst = ent
                    return ent
                end
                fallback = fallback or ent
            end
        end
    end
    self._scholar_track_inst = fallback
    return fallback
end

function NpcStatusScreen:_SetScholarLocalFollow(enabled)
    if enabled then
        if self._scholar_local_follow_task == nil then
            self._scholar_local_follow_task = GLOBAL.ThePlayer:DoPeriodicTask(SCHOLAR_LOCAL_SMOOTH_INTERVAL, function()
                if self._killed or (not self._show_scholar_care and not self._show_scholar_growth) then return end
                if not self.data or self.data.char_type ~= "wickerbottom" then return end
                local range_val = GLOBAL.tonumber(self.data.work_range) or 0
                if range_val <= 0 then return end
                local inst = self:_ResolveScholarTrackInst()
                if inst and inst:IsValid() then
                    local x, _, z = inst.Transform:GetWorldPosition()
                    if DSTADMIN_RANGE_OVERLAY then
                        DSTADMIN_RANGE_OVERLAY.Move(self:_ScholarOverlayKey(), x, z)
                        DSTADMIN_RANGE_OVERLAY.Move(self:_ScholarGrowthOverlayKey(), x, z)
                    end
                else
                    self._scholar_track_inst = nil
                end
            end)
        end
    else
        if self._scholar_local_follow_task ~= nil then
            self._scholar_local_follow_task:Cancel()
            self._scholar_local_follow_task = nil
        end
        self._scholar_track_inst = nil
    end
end

function NpcStatusScreen:_GetAbilityRows(data)
    local abilities = (data and data.abilities) or {}
    if data and data.char_type == "wilson" then
        local visible_count = 0
        local has_locations = false
        for _, ability in ipairs(abilities) do
            if ability.command == "WilsonShowNPCLocations" then
                has_locations = true
            elseif ability.command ~= "UnlockWilsonTransmuteTech"
               and ability.command ~= "WilsonCraftPureBrilliance"
               and ability.command ~= "WilsonCraftHorrorfuel" then
                visible_count = visible_count + 1
            end
        end
        local rows = visible_count > 0 and math.ceil(visible_count / 2) or 0
        return rows + (has_locations and 1 or 0)
    end
    local n = #abilities
    if n <= 0 then return 0 end
    return math.ceil(n / 2)
end

function NpcStatusScreen:_NeedWorkInfo(data)
    return data and SUPPORTED_WORK_RANGE[data.char_type] == true
end

function NpcStatusScreen:_IsWorkRangeInline(data)
    return data and data.char_type == "walter"
end

function NpcStatusScreen:_NeedScholarInfo(data)
    return data and SUPPORTED_SCHOLAR_RANGE[data.char_type] == true
end

function NpcStatusScreen:_ComputePanelHeight(data)
    local rows = self:_GetAbilityRows(data)
    local extra_rows = math.max(0, rows - 1)
    local extra_work = (self:_NeedWorkInfo(data) and not self:_IsWorkRangeInline(data)) and BTN_SPACING or 0
    local extra_scholar = self:_NeedScholarInfo(data) and BTN_SPACING or 0
    local extra_cook = self:_NeedCookSpinner(data) and BTN_SPACING or 0
    local extra_fish = self:_NeedFishSpinner(data) and BTN_SPACING or 0
    local extra_organize = self:_NeedOrganizeSpinner(data) and BTN_SPACING or 0
    local extra_fish_deposit = self:_NeedFishDeposit(data) and BTN_SPACING or 0
    local extra_wormwood_crop_deposit = self:_NeedWormwoodCropDeposit(data) and BTN_SPACING or 0
    local extra_wormwood_trash_deposit = self:_NeedWormwoodTrashDeposit(data) and BTN_SPACING or 0
    local extra_wilson_transmute = self:_NeedWilsonTransmute(data) and BTN_SPACING or 0
    local extra_ocean_fish = self:_NeedOceanFishSpinner(data) and BTN_SPACING or 0
    local extra_ocean_fish_deposit = self:_NeedOceanFishDeposit(data) and BTN_SPACING or 0
    local extra_ocean_fish_murder = self:_NeedOceanFishMurder(data) and BTN_SPACING or 0
    local extra_tts_volume = _ShouldShowTTSVolume() and BTN_SPACING or 0
    -- 吴迪砍树过滤：第一行复用「显示工作范围」右侧空位（不算高度），
    -- 第二行多出一整行：小树 / 中树
    local extra_chop_filter = self:_NeedChopFilter(data) and BTN_SPACING or 0
    -- 吴迪挖树根开关：再多出一行
    local extra_dig_stump = self:_NeedDigStump(data) and BTN_SPACING or 0
    return PANEL_H_BASE + extra_rows * BTN_SPACING + extra_work + extra_scholar + extra_cook + extra_fish + extra_organize
        + extra_fish_deposit + extra_wilson_transmute + extra_wormwood_crop_deposit + extra_wormwood_trash_deposit
        + extra_ocean_fish + extra_ocean_fish_deposit + extra_ocean_fish_murder
        + extra_chop_filter + extra_dig_stump + extra_tts_volume
end

function NpcStatusScreen:_ApplyLayout(data)
    local panel_h = self:_ComputePanelHeight(data)
    self.panel_bg:ScaleToSize(PANEL_W, panel_h)
    self.close_btn:SetPosition(PANEL_W / 2 - TOP_BTN_X_OFFSET, panel_h / 2 - TOP_BTN_Y_OFFSET)
    self.combat_btn:SetPosition(PANEL_W / 2 - TOP_BTN_X_OFFSET - TOP_BTN_SPACING, panel_h / 2 - TOP_BTN_Y_OFFSET)

    local title_y = panel_h / 2 - 70
    self.badge:SetPosition(-80, title_y - 2)
    self.title:SetPosition(50, title_y)
    self.sep1:SetPosition(0, title_y - 35)

    local attr_start_y = title_y - 70
    local attr_spacing = 32
    local stats_offset = 15
    self.follower_label:SetPosition(-80, attr_start_y + 10)
    self.follower_value:SetPosition(50, attr_start_y + 10)
    self.sep_follower:SetPosition(0, attr_start_y - 16)
    self.hu_label:SetPosition(-80, attr_start_y - attr_spacing - stats_offset)
    self.hu_value:SetPosition(50, attr_start_y - attr_spacing - stats_offset)
    -- 精神值/健康值对调后：第二行显示健康值
    self.hp_label:SetPosition(-80, attr_start_y - attr_spacing * 2 - stats_offset)
    self.hp_value:SetPosition(50, attr_start_y - attr_spacing * 2 - stats_offset)
    -- 第三行（原精神值位置）显示好感度，右侧放好感度图标按键
    local affinity_row_y = attr_start_y - attr_spacing * 3 - stats_offset
    self.affinity_label:SetPosition(-80, affinity_row_y)
    self.affinity_value:SetPosition(50, affinity_row_y)
    self.affinity_btn:SetPosition(120, affinity_row_y)
    self.sep2:SetPosition(0, attr_start_y - attr_spacing * 3 - stats_offset - 25)

    local btn_start_y = attr_start_y - attr_spacing * 3 - stats_offset - 60
    self.follow_btn:SetPosition(-75, btn_start_y)
    self.unfollow_btn:SetPosition(75, btn_start_y)
    self.ability_container:SetPosition(0, btn_start_y - BTN_SPACING)

    local rows = self:_GetAbilityRows(data)
    -- 与能力按钮保持同一网格间距，避免视觉跳行
    local work_base_y = (btn_start_y - BTN_SPACING) - (rows * BTN_SPACING)
    local work_is_inline = self:_IsWorkRangeInline(data)
    if work_is_inline then
        self.work_range_toggle_btn:SetPosition(75, btn_start_y - BTN_SPACING)
    else
        self.work_range_toggle_btn:SetPosition(-75, work_base_y)
    end
    self.collect_organize_toggle_btn:SetPosition(75, work_base_y)
    local scholar_base_y = work_base_y - (self:_NeedWorkInfo(data) and not work_is_inline and BTN_SPACING or 0)
    self.scholar_care_btn:SetPosition(-75, scholar_base_y)
    self.scholar_growth_btn:SetPosition(75, scholar_base_y)

    -- 吴迪砍树尺寸过滤：
    --   第一行：左 = 显示工作范围（已在 work_base_y），右 = [x] 大树（含老树）
    --   第二行：左 = [x] 中树，右 = [x] 小树
    if self:_NeedChopFilter(data) then
        self.chop_big_btn:SetPosition(75, work_base_y)
        self.chop_medium_btn:SetPosition(-75, work_base_y - BTN_SPACING)
        self.chop_small_btn:SetPosition(75, work_base_y - BTN_SPACING)
    end

    -- 吴迪第三行：左 = 砍多枝树，右 = 挖树根
    if self:_NeedChopTwiggy(data) then
        self.chop_twiggy_btn:SetPosition(-75, work_base_y - BTN_SPACING * 2)
    end
    if self:_NeedDigStump(data) then
        self.dig_stump_btn:SetPosition(75, work_base_y - BTN_SPACING * 2)
    end

    -- 其他控制行：按顺序往下排，避免角色专属按钮重叠
    local cursor_y = work_base_y - (self:_NeedWorkInfo(data) and not work_is_inline and BTN_SPACING or 0)
    if self:_NeedScholarInfo(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    if self:_NeedChopFilter(data) then
        -- 砍树过滤多出第二行（中/小树），把后续控件再下推一格
        cursor_y = cursor_y - BTN_SPACING
    end
    if self:_NeedDigStump(data) then
        -- 挖树根再多一行
        cursor_y = cursor_y - BTN_SPACING
    end

    -- 厨师 Spinner
    local cook_spinner_y = cursor_y
    if self:_NeedCookSpinner(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.cook_max_label:SetPosition(-75, cook_spinner_y)
    self.cook_max_left_btn:SetPosition(35, cook_spinner_y)
    self.cook_max_value_text:SetPosition(68, cook_spinner_y)
    self.cook_max_right_btn:SetPosition(100, cook_spinner_y)

    -- 整理范围 Spinner
    local organize_spinner_y = cursor_y
    if self:_NeedOrganizeSpinner(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.organize_range_label:SetPosition(-75, organize_spinner_y)
    self.organize_range_left_btn:SetPosition(35, organize_spinner_y)
    self.organize_range_value_text:SetPosition(68, organize_spinner_y)
    self.organize_range_right_btn:SetPosition(100, organize_spinner_y)

    local wilson_locations_ability_y = nil
    if data and data.char_type == "wilson" and data.abilities then
        for i, ability in ipairs(data.abilities) do
            if ability.command == "WilsonShowNPCLocations" then
                local row = math.floor((i - 1) / 2)
                wilson_locations_ability_y = (btn_start_y - BTN_SPACING) - row * BTN_SPACING
                break
            end
        end
    end

    -- 钓鱼存放点
    local fish_deposit_y = cursor_y
    if self:_NeedFishDeposit(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    local fish_deposit_layout_y = wilson_locations_ability_y or fish_deposit_y
    self.fish_deposit_btn:SetPosition(-75, fish_deposit_layout_y)
    self.fish_deposit_range_btn:SetPosition(75, fish_deposit_layout_y)
    self.wilson_npc_locations_btn:SetPosition(-75, fish_deposit_y)

    if self:_NeedWilsonTransmute(data) then
        local craft_y = fish_deposit_y - BTN_SPACING
        self.wilson_unlock_transmute_btn:SetPosition(75, fish_deposit_y)
        self.wilson_purebrilliance_btn:SetPosition(-75, craft_y)
        self.wilson_horrorfuel_btn:SetPosition(75, craft_y)
        cursor_y = cursor_y - BTN_SPACING
    end

    -- 植物人作物存放点（左按钮 + 右显示范围）
    local wormwood_crop_deposit_y = cursor_y
    if self:_NeedWormwoodCropDeposit(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.wormwood_crop_deposit_btn:SetPosition(-75, wormwood_crop_deposit_y)
    self.wormwood_crop_deposit_range_btn:SetPosition(75, wormwood_crop_deposit_y)

    -- 植物人垃圾存放点（左按钮 + 右显示范围）
    local wormwood_trash_deposit_y = cursor_y
    if self:_NeedWormwoodTrashDeposit(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.wormwood_trash_deposit_btn:SetPosition(-75, wormwood_trash_deposit_y)
    self.wormwood_trash_deposit_range_btn:SetPosition(75, wormwood_trash_deposit_y)

    -- 钓鱼次数 Spinner 定位
    local fish_spinner_y = cursor_y
    if self:_NeedFishSpinner(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.fish_max_label:SetPosition(-75, fish_spinner_y)
    self.fish_max_left_btn:SetPosition(35, fish_spinner_y)
    self.fish_max_value_text:SetPosition(68, fish_spinner_y)
    self.fish_max_right_btn:SetPosition(100, fish_spinner_y)

    -- 温蒂海钓存放点按钮定位（在钓鱼 Spinner 下方）
    local ocean_fish_deposit_y = cursor_y
    if self:_NeedOceanFishDeposit(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.ocean_fish_deposit_btn:SetPosition(-75, ocean_fish_deposit_y)
    self.ocean_fish_deposit_range_btn:SetPosition(75, ocean_fish_deposit_y)

    -- 温蒂海钓杀鱼开关按钮定位（在海钓存放点下方）
    local ocean_fish_murder_y = cursor_y
    if self:_NeedOceanFishMurder(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.ocean_fish_murder_btn:SetPosition(-75, ocean_fish_murder_y)

    -- 温蒂海钓次数 Spinner 定位（在杀鱼开关下方）
    local ocean_fish_spinner_y = cursor_y
    if self:_NeedOceanFishSpinner(data) then
        cursor_y = cursor_y - BTN_SPACING
    end
    self.ocean_fish_max_label:SetPosition(-75, ocean_fish_spinner_y)
    self.ocean_fish_max_left_btn:SetPosition(35, ocean_fish_spinner_y)
    self.ocean_fish_max_value_text:SetPosition(68, ocean_fish_spinner_y)
    self.ocean_fish_max_right_btn:SetPosition(100, ocean_fish_spinner_y)

    -- 通用 TTS 音量：所有角色都放在当前布局的最后一行
    if _ShouldShowTTSVolume() then
        local tts_volume_y = cursor_y
        self.tts_volume_label:SetPosition(-75, tts_volume_y)
        self.tts_volume_left_btn:SetPosition(35, tts_volume_y)
        self.tts_volume_value_text:SetPosition(68, tts_volume_y)
        self.tts_volume_right_btn:SetPosition(100, tts_volume_y)
    end
end

-- 把换肤按钮放到 NPC 名字右侧（同一行，间距约 5px）
function NpcStatusScreen:_PositionSkinButton()
    if not self.skin_btn then return end
    local pos = self.title:GetPosition()
    local GAP = 40            -- 距面板右边的间距
    local btn_half = 4        -- player_info.tex 缩放后半宽估值
    -- 靠近面板背景右边，仍与名字保持同一行
    self.skin_btn:SetPosition(PANEL_W / 2 - GAP - btn_half, pos.y)
end

function NpcStatusScreen:_RefreshWorkRangeToggleText()
    local mark = self._show_work_range and "[x]" or "[ ]"
    local label_key = "label_show_work_range"
    if self.data and self.data.char_type == "wortox" then
        label_key = "label_show_heal_range"
    elseif self.data and self.data.char_type == "walter" then
        label_key = "label_walter_campfire_search_range"
    end
    self.work_range_toggle_btn:SetText(mark .. " " .. T(label_key))
end

function NpcStatusScreen:_NeedCollectOrganizeToggle(data)
    return data and (data.char_type == "wes" or data.char_type == "winona")
end

function NpcStatusScreen:_RefreshCollectOrganizeToggleText()
    local key = self._collect_organize_enabled == false and "btn_collect_organize_off" or "btn_collect_organize_on"
    self.collect_organize_toggle_btn:SetText(T(key))
end

function NpcStatusScreen:_RefreshScholarCareToggleText()
    local mark = self._show_scholar_care and "[x]" or "[ ]"
    self.scholar_care_btn:SetText(mark .. " " .. T("label_scholar_care_range"))
end

function NpcStatusScreen:_RefreshScholarGrowthToggleText()
    local mark = self._show_scholar_growth and "[x]" or "[ ]"
    self.scholar_growth_btn:SetText(mark .. " " .. T("label_scholar_growth_range"))
end

function NpcStatusScreen:_NeedChopFilter(data)
    return data and data.char_type == "woodie"
end

function NpcStatusScreen:_RefreshChopFilterText(btn)
    if not btn then return end
    local key = btn._chop_filter_key
    local label_key = btn._chop_filter_label_key
    local checked = self._chop_filter and (self._chop_filter[key] ~= false)
    local mark = checked and "[x]" or "[ ]"
    btn:SetText(mark .. " " .. T(label_key))
end

function NpcStatusScreen:_RefreshAllChopFilterText()
    self:_RefreshChopFilterText(self.chop_small_btn)
    self:_RefreshChopFilterText(self.chop_medium_btn)
    self:_RefreshChopFilterText(self.chop_big_btn)
end

function NpcStatusScreen:_UpdateChopFilter(data)
    local show = self:_NeedChopFilter(data)
    if not show then
        if self.chop_small_btn  then self.chop_small_btn:Hide()  end
        if self.chop_medium_btn then self.chop_medium_btn:Hide() end
        if self.chop_big_btn    then self.chop_big_btn:Hide()    end
        return
    end

    -- 服务端权威状态：只有不在乐观更新保护期才同步
    local now = GLOBAL.GetTime()
    local in_protection = (now - (self._last_btn_click_time or 0)) <= 1.5
    if data.chop_filter and not in_protection then
        self._chop_filter = {
            small  = data.chop_filter.small  ~= false,
            medium = data.chop_filter.medium ~= false,
            big    = data.chop_filter.big    ~= false,
        }
    end

    self.chop_small_btn:Show()
    self.chop_medium_btn:Show()
    self.chop_big_btn:Show()
    self:_RefreshAllChopFilterText()
end

function NpcStatusScreen:_NeedDigStump(data)
    return data and data.char_type == "woodie"
end

function NpcStatusScreen:_RefreshDigStumpText()
    if not self.dig_stump_btn then return end
    local mark = (self._dig_stump == true) and "[x]" or "[ ]"
    self.dig_stump_btn:SetText(mark .. " " .. T("label_dig_stump"))
end

function NpcStatusScreen:_UpdateDigStump(data)
    local show = self:_NeedDigStump(data)
    if not show then
        if self.dig_stump_btn then self.dig_stump_btn:Hide() end
        return
    end

    -- 服务端权威状态同步（保护期内不覆盖乐观更新）
    local now = GLOBAL.GetTime()
    local in_protection = (now - (self._last_btn_click_time or 0)) <= 1.5
    if data.dig_stump ~= nil and not in_protection then
        self._dig_stump = data.dig_stump == true
    end

    self.dig_stump_btn:Show()
    self:_RefreshDigStumpText()
end

function NpcStatusScreen:_NeedChopTwiggy(data)
    return data and data.char_type == "woodie"
end

function NpcStatusScreen:_RefreshChopTwiggyText()
    if not self.chop_twiggy_btn then return end
    local mark = (self._chop_twiggy ~= false) and "[x]" or "[ ]"
    self.chop_twiggy_btn:SetText(mark .. " " .. T("label_chop_twiggy"))
end

function NpcStatusScreen:_UpdateChopTwiggy(data)
    local show = self:_NeedChopTwiggy(data)
    if not show then
        if self.chop_twiggy_btn then self.chop_twiggy_btn:Hide() end
        return
    end

    local now = GLOBAL.GetTime()
    local in_protection = (now - (self._last_btn_click_time or 0)) <= 1.5
    if data.chop_twiggy ~= nil and not in_protection then
        self._chop_twiggy = data.chop_twiggy ~= false
    end

    self.chop_twiggy_btn:Show()
    self:_RefreshChopTwiggyText()
end

function NpcStatusScreen:_NeedOrganizeSpinner(data)
    return data and (data.char_type == "wes" or data.char_type == "winona" or data.char_type == "warly")
end

function NpcStatusScreen:_NeedCookSpinner(data)
    return data and data.char_type == "warly"
end

function NpcStatusScreen:_NeedFishSpinner(data)
    return data and data.char_type == "wilson"
end

function NpcStatusScreen:_NeedFishDeposit(data)
    return data and data.char_type == "wilson"
end

function NpcStatusScreen:_NeedWilsonNPCLocations(data)
    return data and data.char_type == "wilson"
end

function NpcStatusScreen:_NeedWilsonTransmute(data)
    return data and data.char_type == "wilson"
end

function NpcStatusScreen:_GetWilsonNPCLocationsAbility(data)
    if not (data and data.abilities) then return nil end
    for _, ability in ipairs(data.abilities) do
        if ability.command == "WilsonShowNPCLocations" then
            return ability
        end
    end
    return nil
end

function NpcStatusScreen:_GetAbilityByCommand(data, command)
    if not (data and data.abilities and command) then return nil end
    for _, ability in ipairs(data.abilities) do
        if ability.command == command then
            return ability
        end
    end
    return nil
end

function NpcStatusScreen:_NeedWormwoodCropDeposit(data)
    return data and data.char_type == "wormwood"
end

function NpcStatusScreen:_NeedWormwoodTrashDeposit(data)
    return data and data.char_type == "wormwood"
end

function NpcStatusScreen:_NeedOceanFishSpinner(data)
    return data and data.char_type == "wendy"
end

function NpcStatusScreen:_NeedOceanFishDeposit(data)
    return data and data.char_type == "wendy"
end

function NpcStatusScreen:_NeedOceanFishMurder(data)
    return data and data.char_type == "wendy"
end

function NpcStatusScreen:_FishDepositRangeKey()
    return "fish_deposit_" .. (self.owner_param or "default")
end

function NpcStatusScreen:_RefreshFishDepositRangeText()
    local mark = self._show_fish_deposit_range and "[x]" or "[ ]"
    self.fish_deposit_range_btn:SetText(mark .. " " .. T("label_show_fish_range"))
end

function NpcStatusScreen:_UpdateFishDepositRange(data)
    if not self:_NeedFishDeposit(data) then
        self.fish_deposit_range_btn:Hide()
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_FishDepositRangeKey())
        end
        return
    end
    self.fish_deposit_range_btn:Show()
    self:_RefreshFishDepositRangeText()
    if DSTADMIN_RANGE_OVERLAY then
        if self._show_fish_deposit_range
           and data.fishing_deposit_x and data.fishing_deposit_x ~= 0
           and data.fishing_deposit_z and data.fishing_deposit_z ~= 0 then
            DSTADMIN_RANGE_OVERLAY.Show(
                self:_FishDepositRangeKey(),
                data.fishing_deposit_x, data.fishing_deposit_z, 12, "green")
        else
            DSTADMIN_RANGE_OVERLAY.Hide(self:_FishDepositRangeKey())
        end
    end
end

function NpcStatusScreen:_WormwoodCropDepositRangeKey()
    return "wormwood_crop_deposit_" .. (self.owner_param or "default")
end

function NpcStatusScreen:_WormwoodTrashDepositRangeKey()
    return "wormwood_trash_deposit_" .. (self.owner_param or "default")
end

function NpcStatusScreen:_RefreshWormwoodCropDepositRangeText()
    local mark = self._show_wormwood_crop_deposit_range and "[x]" or "[ ]"
    self.wormwood_crop_deposit_range_btn:SetText(mark .. " " .. T("label_show_wormwood_crop_range"))
end

function NpcStatusScreen:_RefreshWormwoodTrashDepositRangeText()
    local mark = self._show_wormwood_trash_deposit_range and "[x]" or "[ ]"
    self.wormwood_trash_deposit_range_btn:SetText(mark .. " " .. T("label_show_wormwood_trash_range"))
end

function NpcStatusScreen:_UpdateWormwoodCropDepositRange(data)
    if not self:_NeedWormwoodCropDeposit(data) then
        self.wormwood_crop_deposit_range_btn:Hide()
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_WormwoodCropDepositRangeKey())
        end
        return
    end
    self.wormwood_crop_deposit_range_btn:Show()
    self:_RefreshWormwoodCropDepositRangeText()
    if DSTADMIN_RANGE_OVERLAY then
        local r = _GetNPCTuningValue("WORMWOOD_CROP_DEPOSIT_RADIUS", 12)
        if self._show_wormwood_crop_deposit_range
           and data.wormwood_crop_deposit_x and data.wormwood_crop_deposit_x ~= 0
           and data.wormwood_crop_deposit_z and data.wormwood_crop_deposit_z ~= 0 then
            DSTADMIN_RANGE_OVERLAY.Show(
                self:_WormwoodCropDepositRangeKey(),
                data.wormwood_crop_deposit_x, data.wormwood_crop_deposit_z, r, "green")
        else
            DSTADMIN_RANGE_OVERLAY.Hide(self:_WormwoodCropDepositRangeKey())
        end
    end
end

function NpcStatusScreen:_UpdateWormwoodTrashDepositRange(data)
    if not self:_NeedWormwoodTrashDeposit(data) then
        self.wormwood_trash_deposit_range_btn:Hide()
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_WormwoodTrashDepositRangeKey())
        end
        return
    end
    self.wormwood_trash_deposit_range_btn:Show()
    self:_RefreshWormwoodTrashDepositRangeText()
    if DSTADMIN_RANGE_OVERLAY then
        local r = _GetNPCTuningValue("WORMWOOD_TRASH_DEPOSIT_RADIUS", 12)
        if self._show_wormwood_trash_deposit_range
           and data.wormwood_trash_deposit_x and data.wormwood_trash_deposit_x ~= 0
           and data.wormwood_trash_deposit_z and data.wormwood_trash_deposit_z ~= 0 then
            DSTADMIN_RANGE_OVERLAY.Show(
                self:_WormwoodTrashDepositRangeKey(),
                data.wormwood_trash_deposit_x, data.wormwood_trash_deposit_z, r, "green")
        else
            DSTADMIN_RANGE_OVERLAY.Hide(self:_WormwoodTrashDepositRangeKey())
        end
    end
end

function NpcStatusScreen:_ChangeCookMax(delta)
    local val = (self._cook_max_value or 8) + delta
    val = math.max(1, math.min(99, val))
    self._cook_max_value = val
    self.cook_max_value_text:SetString(tostring(val))
    GLOBAL.pcall(function()
        SendModRPCToServer(GetModRPC("NPCFriends", "SetCookSameDishMax"), tostring(val))
    end)
end

function NpcStatusScreen:_ChangeOrganizeRange(delta)
    local char_type = self.data and self.data.char_type or "wes"
    local max_range = _GetRangeMax(char_type)
    local min_range = _GetRangeMin(char_type)
    local val = (self._organize_range_value or min_range) + delta
    val = math.max(min_range, math.min(max_range, val))
    self._organize_range_value = val
    self.organize_range_value_text:SetString(tostring(val))
    GLOBAL.pcall(function()
        SendModRPCToServer(GetModRPC("NPCFriends", "SetOrganizeRange"),
            char_type .. "|" .. tostring(val))
    end)
    -- 乐观更新范围圆
    if self.data then
        self.data.work_range = val
        self:_UpdateWorkRangeInfo(self.data)
    end
end

function NpcStatusScreen:_ChangeFishMax(delta)
    local val = (self._fish_max_value or 3) + delta
    local NT = GLOBAL.NPC_TUNING
    local min_val = (NT and NT.FISHING_MAX_CATCH_MIN) or 1
    local max_val = (NT and NT.FISHING_MAX_CATCH_MAX) or 9
    val = math.max(min_val, math.min(max_val, val))
    self._fish_max_value = val
    self.fish_max_value_text:SetString(tostring(val))
    GLOBAL.pcall(function()
        SendModRPCToServer(GetModRPC("NPCFriends", "SetFishingMaxCatch"), tostring(val))
    end)
end

function NpcStatusScreen:_UpdateOrganizeSpinner(data)
    if not self:_NeedOrganizeSpinner(data) then
        self.organize_range_label:Hide()
        self.organize_range_left_btn:Hide()
        self.organize_range_value_text:Hide()
        self.organize_range_right_btn:Hide()
        return
    end
    self.organize_range_label:Show()
    self.organize_range_left_btn:Show()
    self.organize_range_value_text:Show()
    self.organize_range_right_btn:Show()
    if data.organize_range then
        self._organize_range_value = GLOBAL.tonumber(data.organize_range) or self._organize_range_value
        self.organize_range_value_text:SetString(tostring(self._organize_range_value))
    end
end

function NpcStatusScreen:_UpdateCookSpinner(data)
    if not self:_NeedCookSpinner(data) then
        self.cook_max_label:Hide()
        self.cook_max_left_btn:Hide()
        self.cook_max_value_text:Hide()
        self.cook_max_right_btn:Hide()
        return
    end
    self.cook_max_label:Show()
    self.cook_max_left_btn:Show()
    self.cook_max_value_text:Show()
    self.cook_max_right_btn:Show()
    if data.cook_same_dish_max then
        self._cook_max_value = GLOBAL.tonumber(data.cook_same_dish_max) or self._cook_max_value
        self.cook_max_value_text:SetString(tostring(self._cook_max_value))
    end
end

function NpcStatusScreen:_UpdateFishDeposit(data)
    if not self:_NeedFishDeposit(data) then
        self.fish_deposit_btn:Hide()
        return
    end
    self.fish_deposit_btn:Show()
    if data.fishing_deposit_x and data.fishing_deposit_x ~= 0 then
        self.fish_deposit_btn:SetText(T("btn_fish_deposit") .. " \226\156\147")
    else
        self.fish_deposit_btn:SetText(T("btn_fish_deposit"))
    end
end

function NpcStatusScreen:_UpdateWilsonNPCLocations(data)
    local ability = self:_GetWilsonNPCLocationsAbility(data)
    if not (self:_NeedWilsonNPCLocations(data) and ability) then
        self.wilson_npc_locations_btn:Hide()
        return
    end
    self.wilson_npc_locations_btn:Show()
    self.wilson_npc_locations_btn:SetText(T(ability.label_key) or ability.id or T("btn_wilson_show_npc_locations"))
    if ability.active then
        self.wilson_npc_locations_btn:Enable()
    else
        self.wilson_npc_locations_btn:Disable()
    end
end

function NpcStatusScreen:_UpdateWilsonTransmute(data)
    if not self:_NeedWilsonTransmute(data) then
        self.wilson_unlock_transmute_btn:Hide()
        self.wilson_purebrilliance_btn:Hide()
        self.wilson_horrorfuel_btn:Hide()
        return
    end

    local unlock = self:_GetAbilityByCommand(data, "UnlockWilsonTransmuteTech")
    local pure = self:_GetAbilityByCommand(data, "WilsonCraftPureBrilliance")
    local horror = self:_GetAbilityByCommand(data, "WilsonCraftHorrorfuel")

    local aff = GLOBAL.NPC_AFFINITY
    local affinity_off = aff and aff.IsEnabled and not aff.IsEnabled()
    if not affinity_off then
        unlock = nil
    end

    local function Apply(btn, ability, fallback_key)
        if ability == nil then
            btn:Hide()
            return
        end
        btn:Show()
        btn:SetText(T(ability.label_key) or T(fallback_key) or ability.id)
        if ability.active then
            btn:Enable()
        else
            btn:Disable()
        end
    end

    Apply(self.wilson_unlock_transmute_btn, unlock, "btn_wilson_unlock_transmute")
    Apply(self.wilson_purebrilliance_btn, pure, "btn_wilson_purebrilliance")
    Apply(self.wilson_horrorfuel_btn, horror, "btn_wilson_horrorfuel")
end

function NpcStatusScreen:_UpdateWormwoodCropDeposit(data)
    if not self:_NeedWormwoodCropDeposit(data) then
        self.wormwood_crop_deposit_btn:Hide()
        self.wormwood_crop_deposit_range_btn:Hide()
        return
    end
    self.wormwood_crop_deposit_btn:Show()
    if data.wormwood_crop_deposit_x and data.wormwood_crop_deposit_x ~= 0 then
        self.wormwood_crop_deposit_btn:SetText(T("btn_wormwood_crop_deposit") .. " \226\156\147")
    else
        self.wormwood_crop_deposit_btn:SetText(T("btn_wormwood_crop_deposit"))
    end
end

function NpcStatusScreen:_UpdateWormwoodTrashDeposit(data)
    if not self:_NeedWormwoodTrashDeposit(data) then
        self.wormwood_trash_deposit_btn:Hide()
        self.wormwood_trash_deposit_range_btn:Hide()
        return
    end
    self.wormwood_trash_deposit_btn:Show()
    if data.wormwood_trash_deposit_x and data.wormwood_trash_deposit_x ~= 0 then
        self.wormwood_trash_deposit_btn:SetText(T("btn_wormwood_trash_deposit") .. " \226\156\147")
    else
        self.wormwood_trash_deposit_btn:SetText(T("btn_wormwood_trash_deposit"))
    end
end

function NpcStatusScreen:_UpdateFishSpinner(data)
    if not self:_NeedFishSpinner(data) then
        self.fish_max_label:Hide()
        self.fish_max_left_btn:Hide()
        self.fish_max_value_text:Hide()
        self.fish_max_right_btn:Hide()
        return
    end
    self.fish_max_label:Show()
    self.fish_max_left_btn:Show()
    self.fish_max_value_text:Show()
    self.fish_max_right_btn:Show()
    if data.fishing_max_catch then
        self._fish_max_value = GLOBAL.tonumber(data.fishing_max_catch) or self._fish_max_value
        self.fish_max_value_text:SetString(tostring(self._fish_max_value))
    end
end


function NpcStatusScreen:_OceanFishDepositRangeKey()
    return "ocean_fish_deposit_" .. (self.owner_param or "default")
end

function NpcStatusScreen:_RefreshOceanFishDepositRangeText()
    local mark = self._show_ocean_fish_deposit_range and "[x]" or "[ ]"
    self.ocean_fish_deposit_range_btn:SetText(mark .. " " .. T("label_show_ocean_fish_range"))
end

function NpcStatusScreen:_ChangeOceanFishMax(delta)
    local NT = GLOBAL.NPC_TUNING
    local min_val = (NT and NT.OCEAN_FISHING_MAX_CATCH_MIN) or 1
    local max_val = (NT and NT.OCEAN_FISHING_MAX_CATCH_MAX) or 10
    local val = (self._ocean_fish_max_value or 5) + delta
    val = math.max(min_val, math.min(max_val, val))
    self._ocean_fish_max_value = val
    self.ocean_fish_max_value_text:SetString(tostring(val))
    GLOBAL.pcall(function()
        SendModRPCToServer(GetModRPC("NPCFriends", "SetOceanFishingMaxCatch"), tostring(val))
    end)
end

function NpcStatusScreen:_UpdateOceanFishSpinner(data)
    if not self:_NeedOceanFishSpinner(data) then
        self.ocean_fish_max_label:Hide()
        self.ocean_fish_max_left_btn:Hide()
        self.ocean_fish_max_value_text:Hide()
        self.ocean_fish_max_right_btn:Hide()
        return
    end
    self.ocean_fish_max_label:Show()
    self.ocean_fish_max_left_btn:Show()
    self.ocean_fish_max_value_text:Show()
    self.ocean_fish_max_right_btn:Show()
    if data.ocean_fishing_max_catch then
        self._ocean_fish_max_value = GLOBAL.tonumber(data.ocean_fishing_max_catch) or self._ocean_fish_max_value
        self.ocean_fish_max_value_text:SetString(tostring(self._ocean_fish_max_value))
    end
end

function NpcStatusScreen:_ChangeTTSVolume(delta)
    local char_type = self.data and self.data.char_type or "wilson"
    local val = _NormalizeTTSVolume((self._tts_volume_value or _GetTTSVolume(char_type)) + delta)
    self._tts_volume_value = val
    self.tts_volume_value_text:SetString(_FormatTTSVolume(val))
    GLOBAL.pcall(function()
        local NT = GLOBAL.NPC_TUNING
        if NT and NT.TTS_VOLUME and NT.TTS_VOLUME[char_type] ~= nil then
            NT.TTS_VOLUME[char_type] = val
        end
        SendModRPCToServer(GetModRPC("NPCFriends", "SetTTSVolume"),
            char_type .. "|" .. string.format("%.2f", val))
    end)
end

function NpcStatusScreen:_UpdateTTSVolume(data)
    if not (self.tts_volume_label and self.tts_volume_left_btn and self.tts_volume_value_text and self.tts_volume_right_btn) then
        return
    end
    if not _ShouldShowTTSVolume() then
        self.tts_volume_label:Hide()
        self.tts_volume_left_btn:Hide()
        self.tts_volume_value_text:Hide()
        self.tts_volume_right_btn:Hide()
        return
    end
    self.tts_volume_label:Show()
    self.tts_volume_left_btn:Show()
    self.tts_volume_value_text:Show()
    self.tts_volume_right_btn:Show()
    local volume = data and data.tts_volume
    if volume == nil then
        volume = _GetTTSVolume(data and data.char_type or "wilson")
    end
    self._tts_volume_value = _NormalizeTTSVolume(volume)
    self.tts_volume_value_text:SetString(_FormatTTSVolume(self._tts_volume_value))
end

function NpcStatusScreen:_UpdateOceanFishDeposit(data)
    if not self:_NeedOceanFishDeposit(data) then
        self.ocean_fish_deposit_btn:Hide()
        return
    end
    self.ocean_fish_deposit_btn:Show()
    if data.ocean_fishing_deposit_x and data.ocean_fishing_deposit_x ~= 0 then
        self.ocean_fish_deposit_btn:SetText(T("btn_ocean_fish_deposit") .. " \226\156\147")
    else
        self.ocean_fish_deposit_btn:SetText(T("btn_ocean_fish_deposit"))
    end
end

function NpcStatusScreen:_RefreshOceanFishMurderText()
    if self.ocean_fish_murder_btn then
        if self._ocean_fish_murder_enabled then
            self.ocean_fish_murder_btn:SetText(T("btn_ocean_fish_murder_on"))
        else
            self.ocean_fish_murder_btn:SetText(T("btn_ocean_fish_murder_off"))
        end
    end
end

function NpcStatusScreen:_UpdateOceanFishMurder(data)
    if not self:_NeedOceanFishMurder(data) then
        self.ocean_fish_murder_btn:Hide()
        return
    end
    self.ocean_fish_murder_btn:Show()
    if data.ocean_fishing_murder_fish ~= nil then
        self._ocean_fish_murder_enabled = data.ocean_fishing_murder_fish == true
    end
    self:_RefreshOceanFishMurderText()
end

function NpcStatusScreen:_UpdateOceanFishDepositRange(data)
    if not self:_NeedOceanFishDeposit(data) then
        self.ocean_fish_deposit_range_btn:Hide()
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_OceanFishDepositRangeKey())
        end
        return
    end
    self.ocean_fish_deposit_range_btn:Show()
    self:_RefreshOceanFishDepositRangeText()
    if DSTADMIN_RANGE_OVERLAY then
        if self._show_ocean_fish_deposit_range
           and data.ocean_fishing_deposit_x and data.ocean_fishing_deposit_x ~= 0
           and data.ocean_fishing_deposit_z and data.ocean_fishing_deposit_z ~= 0 then
            DSTADMIN_RANGE_OVERLAY.Show(
                self:_OceanFishDepositRangeKey(),
                data.ocean_fishing_deposit_x, data.ocean_fishing_deposit_z, 12, "green")
        else
            DSTADMIN_RANGE_OVERLAY.Hide(self:_OceanFishDepositRangeKey())
        end
    end
end


function NpcStatusScreen:_SetAbilityStateByCommand(cmd, active)
    if not self.data or not self.data.abilities then return end
    for _, ability in ipairs(self.data.abilities) do
        if ability.command == cmd then
            ability.active = active and true or false
        end
    end
end

function NpcStatusScreen:_SetAbilityButtonStateByCommand(cmd, active)
    if not self.ability_btn_by_command then return end
    local btn = self.ability_btn_by_command[cmd]
    if not btn then return end
    if active then
        btn:Enable()
    else
        btn:Disable()
    end
end

-- 灰按键悬停原因：仅"在此处工作"类按键。affinity=好感度不足；working=正在工作中。
function NpcStatusScreen:_ApplyAbilityHoverReason(btn, ability)
    if not btn or not ability then return end
    local reason = ability.reason
    if (not ability.active) and reason and reason ~= "" then
        local tip_key = (reason == "affinity") and "btn_work_locked_affinity" or "btn_work_busy"
        btn:SetHoverText(T(tip_key), { offset_y = -28 })
    else
        btn:ClearHoverText()
    end
end

function NpcStatusScreen:_ApplyOptimisticAbilityState(cmd)
    local work_cmds = {
        FarmHere = true,
        CookHere = true,
        CleanHere = true,
        ChopHere = true,
        FishHere = true,
        OceanFishHere = true,
    }

    if cmd == "StopWork" then
        for c, _ in pairs(work_cmds) do
            self:_SetAbilityStateByCommand(c, true)
            self:_SetAbilityButtonStateByCommand(c, true)
        end
        self:_SetAbilityStateByCommand("StopWork", false)
        self:_SetAbilityButtonStateByCommand("StopWork", false)
        return
    end

    -- Follow 也会清除所有工作状态（服务端 ClearAllWorkCenters）
    if cmd == "Follow" then
        for c, _ in pairs(work_cmds) do
            self:_SetAbilityStateByCommand(c, true)
            self:_SetAbilityButtonStateByCommand(c, true)
        end
        self:_SetAbilityStateByCommand("StopWork", false)
        self:_SetAbilityButtonStateByCommand("StopWork", false)
        return
    end

    if work_cmds[cmd] then
        self:_SetAbilityStateByCommand(cmd, false)
        self:_SetAbilityButtonStateByCommand(cmd, false)
        self:_SetAbilityStateByCommand("StopWork", true)
        self:_SetAbilityButtonStateByCommand("StopWork", true)
    end
end

function NpcStatusScreen:_UpdateWorkRangeInfo(data)
    local show = self:_NeedWorkInfo(data)
    if not show then
        self.work_range_toggle_btn:Hide()
        self.collect_organize_toggle_btn:Hide()
        self:_SetFastRefresh("work_range", false)
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_WorkRangeOverlayKey())
        end
        return
    end

    self.work_range_toggle_btn:Show()
    self:_RefreshWorkRangeToggleText()
    if self:_NeedCollectOrganizeToggle(data) then
        if data.collect_organize_enabled ~= nil then
            self._collect_organize_enabled = data.collect_organize_enabled == true
        end
        self.collect_organize_toggle_btn:Show()
        self:_RefreshCollectOrganizeToggleText()
    else
        self.collect_organize_toggle_btn:Hide()
    end
    local is_wortox = data and data.char_type == "wortox"
    local is_walter = data and data.char_type == "walter"
    local dynamic_center = is_wortox or is_walter
    self:_SetFastRefresh("work_range", dynamic_center and self._show_work_range == true, dynamic_center and 0.2 or nil)

    local enabled = data.work_enabled == true
    local range_val = GLOBAL.tonumber(data.work_range) or 0
    if DSTADMIN_RANGE_OVERLAY then
        if self._show_work_range and enabled and range_val > 0 and data.work_center_x and data.work_center_z then
            DSTADMIN_RANGE_OVERLAY.Show(self:_WorkRangeOverlayKey(), data.work_center_x, data.work_center_z, range_val, "green")
        else
            DSTADMIN_RANGE_OVERLAY.Hide(self:_WorkRangeOverlayKey())
        end
    end
end

function NpcStatusScreen:_UpdateScholarCareInfo(data)
    if not self:_NeedScholarInfo(data) then
        self.scholar_care_btn:Hide()
        self:_SetScholarFastRefresh(false)
        self:_SetScholarLocalFollow(false)
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_ScholarOverlayKey())
        end
        return
    end

    local range_val = GLOBAL.tonumber(data.work_range) or 0
    if range_val > 0 then
        self.scholar_care_btn:Show()
        self.scholar_care_btn:Enable()
        self:_RefreshScholarCareToggleText()
        self:_SetScholarFastRefresh(self._show_scholar_care == true)
        self:_SetScholarLocalFollow(self._show_scholar_care == true or self._show_scholar_growth == true)
        if DSTADMIN_RANGE_OVERLAY then
            if self._show_scholar_care and data.work_center_x and data.work_center_z then
                DSTADMIN_RANGE_OVERLAY.Show(self:_ScholarOverlayKey(), data.work_center_x, data.work_center_z, range_val, "green")
            else
                DSTADMIN_RANGE_OVERLAY.Hide(self:_ScholarOverlayKey())
            end
        end
    else
        self.scholar_care_btn:Hide()
        self:_SetScholarFastRefresh(false)
        self:_SetScholarLocalFollow(self._show_scholar_growth == true)
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_ScholarOverlayKey())
        end
    end
end

function NpcStatusScreen:_UpdateScholarGrowthInfo(data)
    if not self:_NeedScholarInfo(data) then
        self.scholar_growth_btn:Hide()
        self:_SetScholarLocalFollow(self._show_scholar_care == true)
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_ScholarGrowthOverlayKey())
        end
        return
    end

    local range_val = _GetNPCTuningValue("SCHOLAR_GROWTH_RADIUS", 20)
    if range_val > 0 then
        self.scholar_growth_btn:Show()
        self.scholar_growth_btn:Enable()
        self:_RefreshScholarGrowthToggleText()
        self:_SetScholarLocalFollow(self._show_scholar_care == true or self._show_scholar_growth == true)
        if DSTADMIN_RANGE_OVERLAY then
            if self._show_scholar_growth and data.work_center_x and data.work_center_z then
                DSTADMIN_RANGE_OVERLAY.Show(self:_ScholarGrowthOverlayKey(), data.work_center_x, data.work_center_z, range_val, "yellow")
            else
                DSTADMIN_RANGE_OVERLAY.Hide(self:_ScholarGrowthOverlayKey())
            end
        end
    else
        self.scholar_growth_btn:Hide()
        self:_SetScholarLocalFollow(self._show_scholar_care == true)
        if DSTADMIN_RANGE_OVERLAY then
            DSTADMIN_RANGE_OVERLAY.Hide(self:_ScholarGrowthOverlayKey())
        end
    end
end

function NpcStatusScreen:_IsFollowUnlocked(data)
    data = data or self.data or {}
    local aff = GLOBAL.NPC_AFFINITY
    if aff and aff.IsEnabled and not aff.IsEnabled() then return true end
    if not aff or not aff.GetThreshold then return true end
    local threshold = aff.GetThreshold(data.char_type, "follow")
    if threshold == nil then return true end
    return (data.affinity_cur or 0) >= threshold
end

function NpcStatusScreen:_OpenAffinityScreen()
    if not NpcAffinityScreen then return end
    local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
    local root = hud and hud.controls and hud.controls.containerroot or nil
    if not root then return end
    if hud._npc_affinity_open then return end
    hud._npc_affinity_open = true
    self:Hide()
    local widget = NpcAffinityScreen(self.data, self.owner_param)
    hud._npc_affinity_widget = widget
    root:AddChild(widget)
    widget:SetPosition(300, 100)
    root:MoveToFront()
    widget:MoveToFront()
end

function NpcStatusScreen:UpdateData(data)
    if not data then return end
    self.data = data

    self:_ApplyLayout(data)

    local display_name = data.display_name or data.char_type or "NPC"
    self.title:SetString(GLOBAL.tostring(display_name))
    self:_PositionSkinButton()

    local follower_str = (data.leader_name and data.leader_name ~= "") and data.leader_name or "N/A"
    self.follower_value:SetString(follower_str)

    local hp_str = (data.hp_cur and data.hp_max) and (GLOBAL.tostring(data.hp_cur) .. "/" .. GLOBAL.tostring(data.hp_max)) or "N/A"
    local hu_str = (data.hu_cur and data.hu_max and data.hu_max > 0) and (GLOBAL.tostring(data.hu_cur) .. "/" .. GLOBAL.tostring(data.hu_max)) or "N/A"
    local affinity_str = GLOBAL.tostring(data.affinity_cur or 0) .. "/" .. GLOBAL.tostring(data.affinity_max or 400)
    self.hu_value:SetString(hu_str)
    self.hp_value:SetString(hp_str)
    self.affinity_value:SetString(affinity_str)

    local now = GLOBAL.GetTime()
    local is_following = data.is_following
    if self._follow_optimistic_until and now <= self._follow_optimistic_until
       and self._follow_optimistic_state ~= nil then
        is_following = self._follow_optimistic_state
    else
        self._follow_optimistic_state = nil
        self._follow_optimistic_until = nil
    end
    if is_following then
        self.follow_btn:Disable()
        self.unfollow_btn:Enable()
    else
        -- 好感度门控：好感度未达跟随门槛时，跟随按钮保持灰色禁用
        if self:_IsFollowUnlocked(data) then
            self.follow_btn:Enable()
        else
            self.follow_btn:Disable()
        end
        self.unfollow_btn:Disable()
    end

    local in_protection = (now - (self._last_btn_click_time or 0)) <= 3
    if not in_protection then
        for _, btn in ipairs(self.ability_btns) do
            btn:Kill()
        end
        self.ability_btns = {}
        self.ability_btn_by_command = {}

        local abilities = data.abilities or {}
        for i, ability in ipairs(abilities) do
            local is_wilson_custom = data.char_type == "wilson"
                and (ability.command == "WilsonShowNPCLocations"
                    or ability.command == "UnlockWilsonTransmuteTech"
                    or ability.command == "WilsonCraftPureBrilliance"
                    or ability.command == "WilsonCraftHorrorfuel")
            if is_wilson_custom then
                -- 这些按钮在布局上单独放置，不放入通用 ability 网格。
            else
            local btn = self.ability_container:AddChild(ImageButton("images/global_redux.xml",
                "button_carny_long_normal.tex", "button_carny_long_hover.tex",
                "button_carny_long_disabled.tex", "button_carny_long_down.tex"))
            btn:ForceImageSize(BTN_W, BTN_H)
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            if data.char_type == "walter" and i > 1 then
                local shifted = i - 2
                col = shifted % 2
                row = math.floor(shifted / 2) + 1
            end
            btn:SetPosition(col == 0 and -75 or 75, -row * BTN_SPACING)
            btn:SetText(T(ability.label_key) or ability.id)
            btn:SetFont(GLOBAL.CHATFONT)
            btn:SetTextSize(18)
            btn.scale_on_focus = false
            if ability.active then btn:Enable() else btn:Disable() end
            self:_ApplyAbilityHoverReason(btn, ability)

            local cmd = ability.command
            btn:SetOnClick(function()
                self._last_btn_click_time = GLOBAL.GetTime()
                GLOBAL.pcall(function()
                    SendModRPCToServer(GetModRPC("NPCFriends", "NPCCommand"), cmd .. "|" .. self.owner_param)
                end)
                if cmd == "ToggleWalterAutoStory" then
                    local enabled = ability.label_key ~= "btn_walter_auto_story_on"
                    ability.label_key = enabled and "btn_walter_auto_story_on" or "btn_walter_auto_story_off"
                    btn:SetText(T(ability.label_key) or ability.id)
                end
                self:_ApplyOptimisticAbilityState(cmd)
                if cmd == "FarmHere" or cmd == "CookHere" or cmd == "CleanHere" or cmd == "ChopHere" or cmd == "FishHere" or cmd == "StopWork" then
                    self.data.is_following = false
                    if self.follow_btn then self.follow_btn:Enable() end
                    if self.unfollow_btn then self.unfollow_btn:Disable() end
                end
                self:_RequestDelayedRefresh()
            end)
            table.insert(self.ability_btns, btn)
            self.ability_btn_by_command[cmd] = btn
            end
        end
    else
        -- 保护期内：不重建按钮，只增量更新现有按钮的 Enable/Disable
        local abilities = data.abilities or {}
        for _, ability in ipairs(abilities) do
            local cmd = ability.command
            if cmd and self.ability_btn_by_command and self.ability_btn_by_command[cmd] then
                local btn = self.ability_btn_by_command[cmd]
                if ability.active then
                    btn:Enable()
                else
                    btn:Disable()
                end
                self:_ApplyAbilityHoverReason(btn, ability)
            end
        end
    end

    self:_UpdateWorkRangeInfo(data)
    self:_UpdateScholarCareInfo(data)
    self:_UpdateScholarGrowthInfo(data)
    self:_UpdateChopFilter(data)
    self:_UpdateDigStump(data)
    self:_UpdateChopTwiggy(data)
    self:_UpdateOrganizeSpinner(data)
    self:_UpdateCookSpinner(data)
    self:_UpdateFishDeposit(data)
    self:_UpdateFishDepositRange(data)
    self:_UpdateWilsonNPCLocations(data)
    self:_UpdateWilsonTransmute(data)
    self:_UpdateWormwoodCropDeposit(data)
    self:_UpdateWormwoodCropDepositRange(data)
    self:_UpdateWormwoodTrashDeposit(data)
    self:_UpdateWormwoodTrashDepositRange(data)
    self:_UpdateFishSpinner(data)
    self:_UpdateOceanFishDeposit(data)
    self:_UpdateOceanFishDepositRange(data)
    self:_UpdateOceanFishMurder(data)
    self:_UpdateOceanFishSpinner(data)
    self:_UpdateTTSVolume(data)
end
