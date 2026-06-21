local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local NineSlice = require "widgets/nineslice"
local ShadowMinionPool = require "skills/shadow_minion_pool"
local KODI_MODNAME = ShadowMinionPool.MODNAME or "Kodi"
local MENU_WIDTH = 540
local MENU_HEIGHT = 600
local ROW_HEIGHT = 60
local VISIBLE_ROWS = 5
local FONT_SIZE = 28
local SMALL_FONT_SIZE = 22
local TITLE_FONT_SIZE = 34
local COLORS = {
    title = {0.9, 0.8, 1, 1},
    text_normal = {0.95, 0.9, 1, 1},
    text_locked = {0.5, 0.45, 0.55, 1},
    text_selected = {1, 0.95, 0.7, 1},
    info_text = {0.8, 0.75, 0.9, 1},
    count_text = {0.7, 0.6, 0.85, 1},
    unlocked = {0.4, 0.9, 0.4, 1},
    locked = {0.9, 0.4, 0.4, 1},
}
local ShadowMinionMenu = Class(Widget, function(self, owner)
    Widget._ctor(self, "ShadowMinionMenu")
    self.owner = owner
    self.selected_index = 1
    self.scroll_offset = 0
    self.all_creatures = {}
    self.is_open = false
    self:SetPosition(0, 0)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)
    self:CreateBackground()
    self:CreateHeader()
    self:CreateCreatureList()
    self:CreateScrollButtons()
    self:CreateFooter()
    self:Hide()
end)
function ShadowMinionMenu:CreateBackground()
    self.bg_fill = self:AddChild(Image("images/global.xml", "square.tex"))
    self.bg_fill:SetSize(MENU_WIDTH - 20, MENU_HEIGHT - 20)
    self.bg_fill:SetTint(0.12, 0.1, 0.15, 0.95)
    self.panel = self:AddChild(NineSlice("images/dialogcurly_9slice.xml"))
    self.panel:SetSize(MENU_WIDTH, MENU_HEIGHT)
end
function ShadowMinionMenu:CreateHeader()
    self.header = self:AddChild(Widget("header"))
    self.header:SetPosition(0, MENU_HEIGHT/2 - 45)
    local title_text = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.TITLE or "Shadow Creatures"
    self.title = self.header:AddChild(Text(HEADERFONT, TITLE_FONT_SIZE, title_text))
    self.title:SetColour(unpack(COLORS.title))
    self.close_btn = self.header:AddChild(ImageButton(
        "images/global.xml",
        "square.tex",
        "square.tex",
        "square.tex"
    ))
    self.close_btn:SetPosition(MENU_WIDTH/2 - 35, 5)
    self.close_btn:SetScale(0.55)
    self.close_btn:SetImageNormalColour(0.4, 0.2, 0.25, 0.9)
    self.close_btn:SetImageFocusColour(0.7, 0.3, 0.35, 1)
    self.close_btn:SetOnClick(function()
        self:Close()
    end)
    self.close_btn_text = self.close_btn:AddChild(Text(HEADERFONT, 30, "X"))
    self.close_btn_text:SetColour(1, 0.9, 0.9, 1)
end
function ShadowMinionMenu:CreateCreatureList()
    self.list_container = self:AddChild(Widget("list_container"))
    self.list_container:SetPosition(0, 120)
    self.rows = {}
end
function ShadowMinionMenu:RefreshCreatureList()
    for _, row in ipairs(self.rows) do
        row:Kill()
    end
    self.rows = {}
    self.all_creatures = ShadowMinionPool.GetAllCreaturesForUIClient(self.owner)
    table.sort(self.all_creatures, function(a, b)
        if a.is_favorite and not b.is_favorite then
            return true
        elseif not a.is_favorite and b.is_favorite then
            return false
        end
        if a.unlocked and not b.unlocked then
            return true
        elseif not a.unlocked and b.unlocked then
            return false
        end
        return a.name < b.name
    end)
    self:RefreshVisibleRows()
end
function ShadowMinionMenu:RefreshVisibleRows()
    for _, row in ipairs(self.rows) do
        row:Kill()
    end
    self.rows = {}
    local start_y = 20
    local visible_count = 0
    for i = self.scroll_offset + 1, math.min(self.scroll_offset + VISIBLE_ROWS, #self.all_creatures) do
        local creature = self.all_creatures[i]
        if creature then
            visible_count = visible_count + 1
            local row = self:CreateCreatureRow(creature, i)
            row:SetPosition(0, start_y - (visible_count * ROW_HEIGHT))
            table.insert(self.rows, row)
        end
    end
    self:UpdateScrollButtons()
    self:UpdateSelection()
end
function ShadowMinionMenu:CreateCreatureRow(creature, index)
    local row = self.list_container:AddChild(Widget("row_" .. index))
    row.creature_data = creature
    row.index = index
    row.highlight = row:AddChild(Image("images/global_redux.xml", "option_highlight.tex"))
    row.highlight:SetScale(0.9, 0.4)
    row.highlight:SetTint(0.5, 0.3, 0.7, 0.6)
    row.highlight:Hide()
    local star_atlas = "images/global_redux.xml"
    local star_tex = creature.is_favorite and "star_checked.tex" or "star_uncheck.tex"
    row.star = row:AddChild(ImageButton(
        star_atlas,
        star_tex,
        star_tex,
        star_tex
    ))
    row.star:SetPosition(-MENU_WIDTH/2 + 85, 0)
    row.star:SetScale(1.0)
    if creature.is_favorite then
        row.star:SetImageNormalColour(1, 0.9, 0.3, 1)
        row.star:SetImageFocusColour(1, 1, 0.5, 1)
    else
        row.star:SetImageNormalColour(0.5, 0.4, 0.6, 1)
        row.star:SetImageFocusColour(0.8, 0.7, 0.9, 1)
    end
    if creature.unlocked then
        row.star:SetOnClick(function()
            SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowPoolFavorite"], creature.id)
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        end)
    else
        row.star:Disable()
        row.star:SetImageNormalColour(0.3, 0.25, 0.35, 0.5)
    end
    row.name = row:AddChild(Text(HEADERFONT, FONT_SIZE, creature.name))
    row.name:SetPosition(0, 0)
    if creature.unlocked then
        row.name:SetColour(unpack(COLORS.text_normal))
    else
        row.name:SetColour(unpack(COLORS.text_locked))
    end
    local status_atlas = "images/skilltree.xml"
    local status_tex = creature.unlocked and "unlocked.tex" or "locked.tex"
    row.status_icon = row:AddChild(Image(status_atlas, status_tex))
    row.status_icon:SetPosition(MENU_WIDTH/2 - 85, 0)
    row.status_icon:SetScale(0.8)
    if creature.unlocked then
        row.status_icon:SetTint(unpack(COLORS.unlocked))
    else
        row.status_icon:SetTint(unpack(COLORS.locked))
    end
    local click_width = (MENU_WIDTH - 80) / 64
    local click_height = (ROW_HEIGHT - 10) / 64
    row.focus_catcher = row:AddChild(ImageButton("images/global.xml", "square.tex"))
    row.focus_catcher:SetScale(click_width, click_height, 1)
    row.focus_catcher:SetImageNormalColour(0, 0, 0, 0)
    row.focus_catcher:SetImageFocusColour(0, 0, 0, 0)
    row.focus_catcher:SetImageDisabledColour(0, 0, 0, 0)
    row.focus_catcher:MoveToFront()
    row.star:MoveToFront()
    if creature.unlocked then
        row.focus_catcher:SetOnClick(function()
            self.selected_index = index
            self:UpdateSelection()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        end)
        row.focus_catcher:SetOnGainFocus(function()
            row.highlight:Show()
            row.highlight:SetTint(0.6, 0.4, 0.8, 0.5)
        end)
        row.focus_catcher:SetOnLoseFocus(function()
            if self.selected_index == index then
                row.highlight:Show()
                row.highlight:SetTint(0.5, 0.3, 0.7, 0.6)
            else
                row.highlight:Hide()
            end
        end)
    end
    return row
end
function ShadowMinionMenu:UpdateSelection()
    for _, row in ipairs(self.rows) do
        if row.creature_data.unlocked then
            if row.index == self.selected_index then
                row.highlight:Show()
                row.highlight:SetTint(0.5, 0.3, 0.7, 0.6)
                row.name:SetColour(unpack(COLORS.text_selected))
            else
                row.highlight:Hide()
                row.name:SetColour(unpack(COLORS.text_normal))
            end
        end
    end
    self:UpdateFooter()
end
function ShadowMinionMenu:CreateScrollButtons()
    self.scroll_container = self:AddChild(Widget("scroll_container"))
    self.scroll_container:SetPosition(MENU_WIDTH/2 - 35, 70)
    self.scroll_up_btn = self.scroll_container:AddChild(ImageButton(
        "images/global.xml",
        "square.tex",
        "square.tex",
        "square.tex"
    ))
    self.scroll_up_btn:SetPosition(0, 25)
    self.scroll_up_btn:SetScale(0.6)
    self.scroll_up_btn:SetImageNormalColour(0, 0, 0, 0)
    self.scroll_up_btn:SetImageFocusColour(0, 0, 0, 0)
    self.scroll_up_btn:SetImageDisabledColour(0, 0, 0, 0)
    self.scroll_up_btn:SetOnClick(function()
        self:ScrollUp()
    end)
    self.scroll_up_text = self.scroll_up_btn:AddChild(Text(HEADERFONT, 36, "▲"))
    self.scroll_up_text:SetColour(0.8, 0.7, 0.9, 1)
    self.scroll_down_btn = self.scroll_container:AddChild(ImageButton(
        "images/global.xml",
        "square.tex",
        "square.tex",
        "square.tex"
    ))
    self.scroll_down_btn:SetPosition(0, -25)
    self.scroll_down_btn:SetScale(0.6)
    self.scroll_down_btn:SetImageNormalColour(0, 0, 0, 0)
    self.scroll_down_btn:SetImageFocusColour(0, 0, 0, 0)
    self.scroll_down_btn:SetImageDisabledColour(0, 0, 0, 0)
    self.scroll_down_btn:SetOnClick(function()
        self:ScrollDown()
    end)
    self.scroll_down_text = self.scroll_down_btn:AddChild(Text(HEADERFONT, 36, "▼"))
    self.scroll_down_text:SetColour(0.8, 0.7, 0.9, 1)
    self.scroll_indicator = self.scroll_container:AddChild(Text(BODYTEXTFONT, 20, ""))
    self.scroll_indicator:SetPosition(0, 0)
    self.scroll_indicator:SetColour(0.7, 0.6, 0.8, 1)
    self.scroll_container:MoveToFront()
end
function ShadowMinionMenu:UpdateScrollButtons()
    local total = #self.all_creatures
    local max_offset = math.max(0, total - VISIBLE_ROWS)
    if self.scroll_offset <= 0 then
        self.scroll_up_btn:Disable()
        if self.scroll_up_text then
            self.scroll_up_text:SetColour(0.4, 0.35, 0.45, 0.5)
        end
    else
        self.scroll_up_btn:Enable()
        if self.scroll_up_text then
            self.scroll_up_text:SetColour(0.8, 0.7, 0.9, 1)
        end
    end
    if self.scroll_offset >= max_offset then
        self.scroll_down_btn:Disable()
        if self.scroll_down_text then
            self.scroll_down_text:SetColour(0.4, 0.35, 0.45, 0.5)
        end
    else
        self.scroll_down_btn:Enable()
        if self.scroll_down_text then
            self.scroll_down_text:SetColour(0.8, 0.7, 0.9, 1)
        end
    end
    local current_page = math.floor(self.scroll_offset / VISIBLE_ROWS) + 1
    local total_pages = math.ceil(total / VISIBLE_ROWS)
    self.scroll_indicator:SetString(string.format("%d/%d", current_page, total_pages))
end
function ShadowMinionMenu:ScrollUp()
    if self.scroll_offset > 0 then
        self.scroll_offset = self.scroll_offset - 1
        self:RefreshVisibleRows()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end
function ShadowMinionMenu:ScrollDown()
    local max_offset = math.max(0, #self.all_creatures - VISIBLE_ROWS)
    if self.scroll_offset < max_offset then
        self.scroll_offset = self.scroll_offset + 1
        self:RefreshVisibleRows()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end
function ShadowMinionMenu:CreateFooter()
    self.footer = self:AddChild(Widget("footer"))
    self.footer:SetPosition(0, -MENU_HEIGHT/2 - 20)
    self.info_text = self.footer:AddChild(Text(BODYTEXTFONT, SMALL_FONT_SIZE, ""))
    self.info_text:SetPosition(0, 95)
    self.info_text:SetColour(unpack(COLORS.info_text))
    self.count_text = self.footer:AddChild(Text(BODYTEXTFONT, SMALL_FONT_SIZE - 2, ""))
    self.count_text:SetPosition(0, 70)
    self.count_text:SetColour(unpack(COLORS.count_text))
    self.summon_btn = self.footer:AddChild(ImageButton(
        "images/ui.xml",
        "button_large.tex",
        "button_large_over.tex",
        "button_large_disabled.tex",
        "button_large_disabled.tex",
        "button_large_onclick.tex"
    ))
    self.summon_btn:SetPosition(0, 25)
    self.summon_btn:SetScale(0.8)
    local summon_text = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.SUMMON or "Summon"
    self.summon_btn:SetText(summon_text)
    self.summon_btn:SetFont(HEADERFONT)
    self.summon_btn:SetTextSize(26)
    self.summon_btn:SetTextColour(0.9, 0.8, 1, 1)
    self.summon_btn:SetTextFocusColour(1, 1, 1, 1)
    self.summon_btn:SetTextDisabledColour(0.5, 0.45, 0.55, 1)
    self.summon_btn:SetOnClick(function() self:OnSummonClicked() end)
end
function ShadowMinionMenu:UpdateFooter()
    local selected = self:GetSelectedCreature()
    if selected and selected.unlocked then
        local req_text = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.REQUIRED or "Required: %s"
        self.info_text:SetString(string.format(req_text, selected.required_item_name))
        self.summon_btn:Enable()
    else
        local locked_text = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.LOCKED or "Kill to unlock"
        self.info_text:SetString(locked_text)
        self.summon_btn:Disable()
    end
    local current = ShadowMinionPool.GetActiveMinionsCountClient(self.owner)
    local max = ShadowMinionPool.MAX_MINIONS
    local count_format = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.MINION_COUNT or "Minions: %d/%d"
    self.count_text:SetString(string.format(count_format, current, max))
end
function ShadowMinionMenu:GetSelectedCreature()
    if self.all_creatures[self.selected_index] then
        return self.all_creatures[self.selected_index]
    end
    return nil
end
function ShadowMinionMenu:OnSummonClicked()
    local selected = self:GetSelectedCreature()
    if not selected or not selected.unlocked then
        return
    end
    local now = GetTime()
    if self.owner._last_summon_rpc_time and now - self.owner._last_summon_rpc_time < 2 then
        return
    end
    self.owner._last_summon_rpc_time = now
    SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowPoolSummon"], selected.id)
    TheFrontEnd:GetSound():PlaySound("dontstarve/common/together/shadow_summon")
end
function ShadowMinionMenu:OnSummonClicked_OLD()
    local selected = self:GetSelectedCreature()
    if not selected or not selected.unlocked then
        return
    end
    local success, result = ShadowMinionPool.TrySummon(self.owner, selected.id)
    if success then
        self:RefreshCreatureList()
        TheFrontEnd:GetSound():PlaySound("dontstarve/common/together/shadow_summon")
    else
        if self.owner.components.talker then
            local msg = ""
            if result == "NO_ITEMS" then
                local template = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.NO_ITEMS or
                    "Need %s on the ground!"
                msg = string.format(template, selected.required_item_name)
            elseif result == "MAX_MINIONS" then
                msg = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.MAX_REACHED or
                    "Maximum minions reached!"
            else
                msg = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.CANNOT_SUMMON or
                    "Cannot summon!"
            end
            self.owner.components.talker:Say(msg, 2, true)
        end
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative")
    end
end
function ShadowMinionMenu:TrySummonFavorite()
    local pool_data = self.owner._shadow_pool_client
    local favorite_id = pool_data and pool_data.favorite
    if not favorite_id then
        local msg = STRINGS.SHADOW_MINION_POOL and STRINGS.SHADOW_MINION_POOL.NO_FAVORITE or
            "No favorite selected!"
        if self.owner.components.talker then
            self.owner.components.talker:Say(msg, 2, true)
        end
        return false
    end
    local now = GetTime()
    if self.owner._last_summon_rpc_time and now - self.owner._last_summon_rpc_time < 2 then
        return false
    end
    self.owner._last_summon_rpc_time = now
    SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowPoolSummon"], favorite_id)
    TheFrontEnd:GetSound():PlaySound("dontstarve/common/together/shadow_summon")
    return true
end
function ShadowMinionMenu:NavigateUp()
    if self.selected_index > 1 then
        self.selected_index = self.selected_index - 1
        while self.selected_index > 1 and
              self.all_creatures[self.selected_index] and
              not self.all_creatures[self.selected_index].unlocked do
            self.selected_index = self.selected_index - 1
        end
        if self.selected_index <= self.scroll_offset then
            self.scroll_offset = self.selected_index - 1
            self:RefreshVisibleRows()
        else
            self:UpdateSelection()
        end
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end
function ShadowMinionMenu:NavigateDown()
    if self.selected_index < #self.all_creatures then
        self.selected_index = self.selected_index + 1
        while self.selected_index < #self.all_creatures and
              self.all_creatures[self.selected_index] and
              not self.all_creatures[self.selected_index].unlocked do
            self.selected_index = self.selected_index + 1
        end
        if self.selected_index > self.scroll_offset + VISIBLE_ROWS then
            self.scroll_offset = self.selected_index - VISIBLE_ROWS
            self:RefreshVisibleRows()
        else
            self:UpdateSelection()
        end
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end
function ShadowMinionMenu:ToggleFavoriteSelected()
    local selected = self:GetSelectedCreature()
    if selected and selected.unlocked then
        SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowPoolFavorite"], selected.id)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end
function ShadowMinionMenu:Open()
    if self.is_open then return end
    self.is_open = true
    self:Show()
    self:MoveToFront()
    if TheCamera and TheCamera.SetControllable then
        TheCamera:SetControllable(false)
    end
    if TheInput then
        self._scroll_handler = TheInput:AddControlHandler(CONTROL_SCROLLBACK, function(down)
            if self.is_open and down then
                self:ScrollUp()
                return true
            end
        end)
        self._scroll_fwd_handler = TheInput:AddControlHandler(CONTROL_SCROLLFWD, function(down)
            if self.is_open and down then
                self:ScrollDown()
                return true
            end
        end)
    end
    self.scroll_offset = 0
    SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowPoolSync"])
    self:RefreshCreatureList()
    for i, creature in ipairs(self.all_creatures) do
        if creature.unlocked then
            self.selected_index = i
            break
        end
    end
    self:UpdateSelection()
    self:SetFocus()
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
end
function ShadowMinionMenu:Close()
    if not self.is_open then return end
    self.is_open = false
    self:Hide()
    self:ClearFocus()
    if TheCamera and TheCamera.SetControllable then
        TheCamera:SetControllable(true)
    end
    if self._scroll_handler then
        self._scroll_handler:Remove()
        self._scroll_handler = nil
    end
    if self._scroll_fwd_handler then
        self._scroll_fwd_handler:Remove()
        self._scroll_fwd_handler = nil
    end
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close")
end
function ShadowMinionMenu:Toggle()
    if self.is_open then
        self:Close()
    else
        self:Open()
    end
end
function ShadowMinionMenu:IsOpen()
    return self.is_open
end
function ShadowMinionMenu:OnRawKey(key, down)
    if not self.is_open then return false end
    if down then
        if key == KEY_W or key == KEY_UP then
            self:NavigateUp()
            return true
        elseif key == KEY_S or key == KEY_DOWN then
            self:NavigateDown()
            return true
        elseif key == KEY_K then
            self:OnSummonClicked()
            return true
        elseif key == KEY_F then
            self:ToggleFavoriteSelected()
            return true
        elseif key == KEY_H or key == KEY_ESCAPE then
            self:Close()
            return true
        end
    end
    return false
end
function ShadowMinionMenu:OnMouseButton(button, down, x, y)
    return false
end
function ShadowMinionMenu:OnControl(control, down)
    if not self.is_open then return false end
    if control == CONTROL_SCROLLBACK then
        if down then
            self:ScrollUp()
        end
        return true
    elseif control == CONTROL_SCROLLFWD then
        if down then
            self:ScrollDown()
        end
        return true
    elseif control == CONTROL_CANCEL then
        if down then
            self:Close()
        end
        return true
    end
    return ShadowMinionMenu._base.OnControl(self, control, down)
end
return ShadowMinionMenu
