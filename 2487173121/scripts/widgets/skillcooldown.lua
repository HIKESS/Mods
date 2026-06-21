local Widget = require "widgets/widget"
local Text = require "widgets/text"
local function GetSkillLabels()
    local KODI = (STRINGS and STRINGS.SKILLTREE and STRINGS.SKILLTREE.KODI) or {}
    local ua = TUNING and TUNING.KODI_LANGUAGE == "UKRAINIAN"
    return {
        eruption = KODI.DEMON_SHADOW_ERUPTION_TITLE or "Shadow Eruption",
        stalker  = KODI.FOX_DAY_STALKER_TITLE or "Day Stalker",
        summon   = KODI.SURVIVAL_CUNNING_3_TITLE or "Shadow Summon",
        hands    = KODI.DEMON_SHADOW_HANDS_TITLE or "Shadow Hands",
        minion   = KODI.SURVIVAL_SHADOW_MINION_TITLE or "Shadow Minion",
        leap   = (KODI.FOX_NIGHT_HUNTER_TITLE or "Night Hunter") .. (ua and " (стрибок)" or " (leap)"),
        vision = (KODI.FOX_NIGHT_HUNTER_TITLE or "Night Hunter") .. (ua and " (бачення)" or " (vision)"),
        hide   = ua and "Сховок" or "Hiding",
        mark   = ua and "Мітка" or "Mark",
    }
end
local LABEL_FONT = 15
local VALUE_FONT = 17
local GAP = 6
local VALUE_SLOT = 40
local MAX_RIGHT = 130
local _pending_value_x = 0
local function StyleLabel(txt)
    txt:SetSize(LABEL_FONT)
    txt:SetHAlign(ANCHOR_MIDDLE)
    local lw = txt:GetRegionSize() or 0
    local half = (lw + GAP + VALUE_SLOT) * 0.5
    local shift = 0
    if half > MAX_RIGHT then
        shift = MAX_RIGHT - half
    end
    local left_edge = -half + shift
    txt:SetPosition(left_edge + lw * 0.5, 0)
    _pending_value_x = left_edge + lw + GAP + VALUE_SLOT * 0.5
end
local function StyleValue(txt)
    txt:SetSize(VALUE_FONT)
    txt:SetHAlign(ANCHOR_MIDDLE)
    txt:SetPosition(_pending_value_x, 0)
end
local SkillCooldown = Class(Widget, function(self, owner)
    Widget._ctor(self, "SkillCooldown")
    self.owner = owner
    local L = GetSkillLabels()
    self.row1 = self:AddChild(Widget("Row1"))
    self.row1:SetPosition(0, 0)
    self.row1_key = self.row1:AddChild(Text(BODYTEXTFONT, 22))
    self.row1_key:SetColour(0.8, 0.8, 0.8, 1)
    self.row1_key:SetString(L.eruption .. ": G")
    StyleLabel(self.row1_key)
    self.row1_text = self.row1:AddChild(Text(BODYTEXTFONT, 22))
    self.row1_text:SetColour(1, 1, 1, 1)
    self.row1_text:SetString("")
    StyleValue(self.row1_text)
    self.row1:Hide()
    self.row2 = self:AddChild(Widget("Row2"))
    self.row2:SetPosition(0, 0)
    self.row2_key = self.row2:AddChild(Text(BODYTEXTFONT, 22))
    self.row2_key:SetColour(0.8, 0.8, 0.8, 1)
    self.row2_key:SetString(L.stalker .. ": V")
    StyleLabel(self.row2_key)
    self.row2_text = self.row2:AddChild(Text(BODYTEXTFONT, 22))
    self.row2_text:SetColour(1, 1, 1, 1)
    self.row2_text:SetString("")
    StyleValue(self.row2_text)
    self.row2:Hide()
    self.row3 = self:AddChild(Widget("Row3"))
    self.row3:SetPosition(0, -24)
    self.row3_key = self.row3:AddChild(Text(BODYTEXTFONT, 20))
    self.row3_key:SetColour(0.7, 0.7, 0.9, 1)
    self.row3_key:SetString(L.hide .. ":")
    StyleLabel(self.row3_key)
    self.row3_text = self.row3:AddChild(Text(BODYTEXTFONT, 20))
    self.row3_text:SetColour(1, 1, 1, 1)
    self.row3_text:SetString("")
    StyleValue(self.row3_text)
    self.row3:Hide()
    self.row4 = self:AddChild(Widget("Row4"))
    self.row4:SetPosition(0, 0)
    self.row4_key = self.row4:AddChild(Text(BODYTEXTFONT, 22))
    self.row4_key:SetColour(0.6, 0.4, 0.8, 1)
    self.row4_key:SetString(L.leap .. ":")
    StyleLabel(self.row4_key)
    self.row4_text = self.row4:AddChild(Text(BODYTEXTFONT, 22))
    self.row4_text:SetColour(1, 1, 1, 1)
    self.row4_text:SetString("")
    StyleValue(self.row4_text)
    self.row4:Hide()
    self.row5 = self:AddChild(Widget("Row5"))
    self.row5:SetPosition(0, 0)
    self.row5_key = self.row5:AddChild(Text(BODYTEXTFONT, 22))
    self.row5_key:SetColour(0.4, 0.3, 0.5, 1)
    self.row5_key:SetString(L.summon .. ": J")
    StyleLabel(self.row5_key)
    self.row5_text = self.row5:AddChild(Text(BODYTEXTFONT, 22))
    self.row5_text:SetColour(1, 1, 1, 1)
    self.row5_text:SetString("")
    StyleValue(self.row5_text)
    self.row5:Hide()
    self.row_hands = self:AddChild(Widget("RowHands"))
    self.row_hands:SetPosition(0, 0)
    self.row_hands_key = self.row_hands:AddChild(Text(BODYTEXTFONT, 22))
    self.row_hands_key:SetColour(0.3, 0.2, 0.4, 1)
    self.row_hands_key:SetString(L.hands .. ": MMB")
    StyleLabel(self.row_hands_key)
    self.row_hands_text = self.row_hands:AddChild(Text(BODYTEXTFONT, 22))
    self.row_hands_text:SetColour(1, 1, 1, 1)
    self.row_hands_text:SetString("")
    StyleValue(self.row_hands_text)
    self.row_hands:Hide()
    self.minion_rows = {}
    for i = 1, 3 do
        local row = self:AddChild(Widget("MinionRow" .. i))
        row:SetPosition(0, 0)
        row.key = row:AddChild(Text(BODYTEXTFONT, 20))
        row.key:SetColour(0.4, 0.2, 0.5, 1)
        row.key:SetString(L.minion .. " " .. i .. ":")
        StyleLabel(row.key)
        row.text = row:AddChild(Text(BODYTEXTFONT, 20))
        row.text:SetColour(1, 1, 1, 1)
        row.text:SetString("")
        StyleValue(row.text)
        row:Hide()
        self.minion_rows[i] = row
    end
    self.row6 = self:AddChild(Widget("Row6"))
    self.row6:SetPosition(0, 0)
    self.row6_key = self.row6:AddChild(Text(BODYTEXTFONT, 22))
    self.row6_key:SetColour(0.5, 0.4, 0.8, 1)
    self.row6_key:SetString(L.vision .. ": V")
    StyleLabel(self.row6_key)
    self.row6_text = self.row6:AddChild(Text(BODYTEXTFONT, 22))
    self.row6_text:SetColour(1, 1, 1, 1)
    self.row6_text:SetString("")
    StyleValue(self.row6_text)
    self.row6:Hide()
    self.mark_rows = {}
    for i = 1, 3 do
        local row = self:AddChild(Widget("MarkRow" .. i))
        row:SetPosition(0, -24 * i)
        row.key = row:AddChild(Text(BODYTEXTFONT, 20))
        row.key:SetColour(0.8, 0.3, 0.3, 1)
        row.key:SetString(L.mark .. " " .. i .. ":")
        StyleLabel(row.key)
        row.text = row:AddChild(Text(BODYTEXTFONT, 20))
        row.text:SetColour(1, 1, 1, 1)
        row.text:SetString("")
        StyleValue(row.text)
        row:Hide()
        self.mark_rows[i] = row
    end
    self:Hide()
    self:StartUpdating()
end)
function SkillCooldown:OnUpdate(dt)
    if not self.owner or not self.owner:IsValid() then return end
    local show_widget = false
    local is_demon = not self.owner:HasTag("NotDemon")
    local is_fox = self.owner:HasTag("NotDemon")
    local has_eruption = self.owner:HasTag("kodi_shadow_eruption")
    if has_eruption and is_demon then
        self.row1:Show()
        show_widget = true
        local cooldown = 0
        if self.owner.GetShadowEruptionCooldown then
            cooldown = self.owner:GetShadowEruptionCooldown()
        end
        if cooldown > 0 then
            self.row1_text:SetString(string.format("%.0f", math.ceil(cooldown)))
            self.row1_text:SetColour(1, 0.4, 0.4, 1)
        else
            self.row1_text:SetString("OK")
            self.row1_text:SetColour(0.4, 1, 0.4, 1)
        end
    else
        self.row1:Hide()
    end
    local has_day_stalker = self.owner:HasTag("kodi_day_stalker")
    local in_stealth = self.owner:HasTag("kodi_stealth")
    local is_hiding = self.owner:HasTag("kodi_hiding")
    if has_day_stalker and is_fox then
        self.row2:Show()
        show_widget = true
        if is_hiding then
            self.row2_text:SetString("OK")
            self.row2_text:SetColour(0.4, 1, 0.4, 1)
        elseif in_stealth then
            local fade_remaining = -1
            if self.owner.GetDayStalkerFadeRemaining then
                fade_remaining = self.owner:GetDayStalkerFadeRemaining()
            end
            if fade_remaining > 0 then
                self.row2_text:SetString(string.format("%.1f", fade_remaining))
                self.row2_text:SetColour(1, 0.7, 0.3, 1)
            else
                self.row2_text:SetString("OK")
                self.row2_text:SetColour(0.4, 1, 0.4, 1)
            end
        else
            self.row2_text:SetString("OK")
            self.row2_text:SetColour(0.6, 0.8, 1, 1)
        end
    else
        self.row2:Hide()
    end
    if has_day_stalker and is_fox and is_hiding then
        self.row3:Show()
        show_widget = true
        self._hide_elapsed = (self._hide_elapsed or 0) + (dt or 0)
        local hide_timeout = 20
        local hide_remaining = math.max(0, hide_timeout - self._hide_elapsed)
        if hide_remaining > 0 then
            self.row3_text:SetString(string.format("%.0f", math.ceil(hide_remaining)))
            if hide_remaining > 10 then
                self.row3_text:SetColour(0.4, 1, 0.4, 1)
            elseif hide_remaining > 5 then
                self.row3_text:SetColour(1, 1, 0.3, 1)
            else
                self.row3_text:SetColour(1, 0.4, 0.4, 1)
            end
        else
            self.row3_text:SetString("0")
            self.row3_text:SetColour(1, 0.4, 0.4, 1)
        end
    else
        self.row3:Hide()
        self._hide_elapsed = nil
    end
    local has_shadow_summon = self.owner:HasTag("kodi_shadow_summon")
    if has_shadow_summon then
        self.row5:Show()
        show_widget = true
        local summon_cooldown = 0
        if self.owner.GetShadowSummonCooldown then
            summon_cooldown = self.owner:GetShadowSummonCooldown()
        end
        if summon_cooldown > 0 then
            self.row5_text:SetString(string.format("%.0f", math.ceil(summon_cooldown)))
            self.row5_text:SetColour(1, 0.4, 0.4, 1)
        else
            self.row5_text:SetString("OK")
            self.row5_text:SetColour(0.4, 1, 0.4, 1)
        end
    else
        self.row5:Hide()
    end
    local has_shadow_hands = self.owner:HasTag("kodi_shadow_hands")
    if has_shadow_hands and is_demon then
        self.row_hands:Show()
        show_widget = true
        local hands_cooldown = 0
        if self.owner.GetShadowHandsCooldown then
            hands_cooldown = self.owner:GetShadowHandsCooldown()
        end
        if hands_cooldown > 0 then
            self.row_hands_text:SetString(string.format("%.0f", math.ceil(hands_cooldown)))
            self.row_hands_text:SetColour(1, 0.4, 0.4, 1)
        else
            self.row_hands_text:SetString("OK")
            self.row_hands_text:SetColour(0.4, 1, 0.4, 1)
        end
    else
        self.row_hands:Hide()
    end
    local has_night_hunter = self.owner:HasTag("kodi_night_hunter")
    local mark_count = 0
    if self.owner.GetNightHunterMarkCount then
        mark_count = self.owner:GetNightHunterMarkCount()
    end
    if has_night_hunter and is_fox then
        self.row4:Show()
        show_widget = true
        local leap_cooldown = 0
        if self.owner.GetNightHunterLeapCooldown then
            leap_cooldown = self.owner:GetNightHunterLeapCooldown()
        end
        if leap_cooldown > 0 then
            self.row4_text:SetString(string.format("%.0f", math.ceil(leap_cooldown)))
            self.row4_text:SetColour(1, 0.4, 0.4, 1)
        else
            self.row4_text:SetString("OK")
            self.row4_text:SetColour(0.4, 1, 0.4, 1)
        end
        for i = 1, 3 do
            if i <= mark_count then
                self.mark_rows[i]:Show()
                local mark_time = 30
                if self.owner.GetNightHunterMarkTimeRemainingByIndex then
                    mark_time = self.owner:GetNightHunterMarkTimeRemainingByIndex(i)
                end
                if mark_time > 0 then
                    self.mark_rows[i].text:SetString(string.format("%.0fs", math.ceil(mark_time)))
                    if mark_time > 15 then
                        self.mark_rows[i].text:SetColour(0.4, 1, 0.4, 1)
                    elseif mark_time > 7 then
                        self.mark_rows[i].text:SetColour(1, 1, 0.3, 1)
                    else
                        self.mark_rows[i].text:SetColour(1, 0.4, 0.4, 1)
                    end
                else
                    self.mark_rows[i].text:SetString("0s")
                    self.mark_rows[i].text:SetColour(1, 0.4, 0.4, 1)
                end
            else
                self.mark_rows[i]:Hide()
            end
        end
    else
        self.row4:Hide()
        for i = 1, 3 do
            self.mark_rows[i]:Hide()
        end
    end
    local has_shadow_minion_skill = self.owner:HasTag("kodi_shadow_minion")
    local minion_times = {}
    if has_shadow_minion_skill and self.owner.GetShadowMinionTimesRemaining then
        minion_times = self.owner:GetShadowMinionTimesRemaining()
    end
    for i = 1, 3 do
        if i <= #minion_times and minion_times[i] > 0 then
            self.minion_rows[i]:Show()
            show_widget = true
            local t = minion_times[i]
            if t > 60 then
                local mins = math.floor(t / 60)
                local secs = math.floor(t % 60)
                self.minion_rows[i].text:SetString(string.format("%d:%02d", mins, secs))
            else
                self.minion_rows[i].text:SetString(string.format("%.0fs", math.ceil(t)))
            end
            if t > 60 then
                self.minion_rows[i].text:SetColour(0.4, 1, 0.4, 1)
            elseif t > 30 then
                self.minion_rows[i].text:SetColour(1, 1, 0.3, 1)
            else
                self.minion_rows[i].text:SetColour(1, 0.4, 0.4, 1)
            end
        else
            self.minion_rows[i]:Hide()
        end
    end
    local night_vision_active = self.owner._night_hunter_vision_active
    if has_night_hunter and is_fox and night_vision_active then
        self.row6:Show()
        show_widget = true
        local time_remaining = 0
        if self.owner.GetNightVisionTimeRemaining then
            time_remaining = self.owner:GetNightVisionTimeRemaining()
        end
        if time_remaining > 0 then
            if time_remaining > 60 then
                local mins = math.floor(time_remaining / 60)
                local secs = math.floor(time_remaining % 60)
                self.row6_text:SetString(string.format("%d:%02d", mins, secs))
            else
                self.row6_text:SetString(string.format("%.0fs", math.ceil(time_remaining)))
            end
            if time_remaining > 30 then
                self.row6_text:SetColour(0.6, 0.5, 1, 1)
            elseif time_remaining > 10 then
                self.row6_text:SetColour(1, 1, 0.3, 1)
            else
                self.row6_text:SetColour(1, 0.4, 0.4, 1)
            end
        else
            self.row6_text:SetString("0s")
            self.row6_text:SetColour(1, 0.4, 0.4, 1)
        end
    else
        self.row6:Hide()
    end
    local y_offset = 0
    local row_height = 22
    local small_row_height = 20
    local all_rows = { self.row1, self.row2, self.row3, self.row5, self.row_hands, self.row4, self.row6 }
    for _, row in ipairs(all_rows) do
        if row.shown then
            row:SetPosition(0, y_offset)
            y_offset = y_offset - row_height
        end
    end
    for i = 1, 3 do
        if self.minion_rows[i].shown then
            self.minion_rows[i]:SetPosition(0, y_offset)
            y_offset = y_offset - small_row_height
        end
    end
    for i = 1, 3 do
        if self.mark_rows[i].shown then
            self.mark_rows[i]:SetPosition(0, y_offset)
            y_offset = y_offset - small_row_height
        end
    end
    if show_widget then
        self:Show()
    else
        self:Hide()
    end
end
return SkillCooldown
