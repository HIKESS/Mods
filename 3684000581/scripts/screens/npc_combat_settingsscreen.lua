local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local TEMPLATES = require("widgets/redux/templates")
local Settings = require("npc_combat_settings")
local RangeOverlay = require("npc_range_overlay")

local ROW_H = 30
local HEADER_H = 28
local PANEL_W = 900
local COL_LEFT_X = -240
local COL_RIGHT_X = 240

local function IsChinese()
    local strings = STRINGS
    local ui = strings ~= nil and strings.UI or nil
    local mainscreen = ui ~= nil and ui.MAINSCREEN or nil
    local play = mainscreen ~= nil and mainscreen.PLAY or nil
    return type(play) == "string" and play:match("[\228-\233]") ~= nil
end

local function LocalText(zh, en)
    return IsChinese() and zh or en
end

local function FormatValue(def, value)
    if def.type == "bool" then
        return value and "ON" or "OFF"
    end
    if def.type == "number" then
        local n = tonumber(value) or 0
        if def.percent then
            return tostring(math.floor(n * 100 + 0.5)) .. "%"
        end
        if math.abs(n - math.floor(n + 0.5)) < 0.001 then
            return tostring(math.floor(n + 0.5))
        end
        return string.format("%.1f", n)
    end
    if def.type == "enum" then
        return Settings.GetOptionLabel(def, value)
    end
    return tostring(value or "")
end

local function CountVisibleRows(values)
    local rows = 1
    local current_group = nil
    for _, def in ipairs(Settings.DEFS) do
        if def.key ~= "auto_combat_enabled" and Settings.IsVisibleInUI(def, values) then
            if def.group ~= current_group then
                rows = rows + 1
                current_group = def.group
            end
            rows = rows + 1
        end
    end
    return rows
end

local NPCCombatSettingsScreen = Class(Screen, function(self, owner, payload)
    Screen._ctor(self, "NPCCombatSettingsScreen")

    self.owner = owner
    self.values = Settings.Decode(payload or "")
    self.items = {}

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.root = self:AddChild(TEMPLATES.ScreenRoot("root"))

    self:_Rebuild()
end)

function NPCCombatSettingsScreen:_SendSetting(key, value)
    if SendModRPCToServer ~= nil and GetModRPC ~= nil then
        SendModRPCToServer(GetModRPC("NPCFriends", "SetCombatSetting"), key .. "|" .. tostring(value))
    end
end

function NPCCombatSettingsScreen:_SetLocal(key, value)
    if Settings.NormalizeValue(key, value) == nil then return end
    self.values[key] = Settings.NormalizeValue(key, value)
    self.values = Settings.NormalizeSettings(self.values)
    if key == "max_leader_dist_in_combat" then
        RangeOverlay.ShowAroundPlayer("npcfriends_combat_return_range", self.values[key], 3, "blue", 0.9)
    elseif key == "auto_revive_amulet_range" then
        RangeOverlay.ShowAroundNearestGhostNPC("npcfriends_amulet_revive_range", self.values[key], 3, "yellow", 0.9)
    elseif key == "auto_revive_amulet_enabled" and self.values[key] == true then
        RangeOverlay.ShowAroundNearestGhostNPC("npcfriends_amulet_revive_range", self.values.auto_revive_amulet_range or 25, 3, "yellow", 0.9)
    end
    self:_SendSetting(key, self.values[key])
    self:_Rebuild()
end

function NPCCombatSettingsScreen:_Reset()
    self.values = Settings.GetDefaultSettings()
    if SendModRPCToServer ~= nil and GetModRPC ~= nil then
        SendModRPCToServer(GetModRPC("NPCFriends", "ResetCombatSettings"), "")
    end
    self:_Rebuild()
end

function NPCCombatSettingsScreen:_NextEnum(def)
    local cur = tostring(self.values[def.key] or def.default)
    local opts = def.options or {}
    local idx = 1
    for i, opt in ipairs(opts) do
        if Settings.GetOptionValue(opt) == cur then
            idx = i + 1
            break
        end
    end
    if idx > #opts then idx = 1 end
    self:_SetLocal(def.key, Settings.GetOptionValue(opts[idx]) or def.default)
end

function NPCCombatSettingsScreen:_AddRow(def, y, xoff)
    xoff = xoff or 0

    local enabled = Settings.IsControlEnabled(def, self.values)
    
    local label_colour = enabled and { 1, 1, 1, 1 } or { 0.5, 0.5, 0.5, 1 }
    local value_colour = enabled and { 1, 1, 1, 1 } or { 0.45, 0.45, 0.45, 1 }

    local label = self.panel:AddChild(Text(UIFONT, 22, Settings.GetLabel(def)))
    label:SetHAlign(ANCHOR_LEFT)
    label:SetRegionSize(190, ROW_H)
    label:SetPosition(xoff - 145, y)
    label:SetColour(unpack(label_colour))
    table.insert(self.items, label)

    local value = self.values[def.key]
    local value_text = self.panel:AddChild(Text(UIFONT, 22, FormatValue(def, value)))
    value_text:SetRegionSize(85, ROW_H)
    value_text:SetPosition(xoff + 10, y)
    value_text:SetColour(unpack(value_colour))
    table.insert(self.items, value_text)

    
    local function MakeAction(action_fn)
        return function()
            if not Settings.IsControlEnabled(def, self.values) then
                return
            end
            action_fn()
        end
    end

    local function ApplyEnabledState(btn)
        if btn == nil then return end
        if not enabled then
            if type(btn.Disable) == "function" then
                btn:Disable()
            end
            if type(btn.SetClickable) == "function" then
                btn:SetClickable(false)
            end
        end
    end

    if def.type == "bool" then
        local btn = self.panel:AddChild(TEMPLATES.StandardButton(MakeAction(function()
            self:_SetLocal(def.key, not self.values[def.key])
        end), LocalText("切换", "Toggle"), { 100, 28 }))
        btn:SetPosition(xoff + 130, y)
        ApplyEnabledState(btn)
        table.insert(self.items, btn)
    elseif def.type == "number" then
        local minus = self.panel:AddChild(TEMPLATES.StandardButton(MakeAction(function()
            self:_SetLocal(def.key, (tonumber(self.values[def.key]) or def.default) - (def.step or 1))
        end), "-", { 42, 28 }))
        minus:SetPosition(xoff + 105, y)
        ApplyEnabledState(minus)
        table.insert(self.items, minus)

        local plus = self.panel:AddChild(TEMPLATES.StandardButton(MakeAction(function()
            self:_SetLocal(def.key, (tonumber(self.values[def.key]) or def.default) + (def.step or 1))
        end), "+", { 42, 28 }))
        plus:SetPosition(xoff + 155, y)
        ApplyEnabledState(plus)
        table.insert(self.items, plus)
    elseif def.type == "enum" then
        local btn = self.panel:AddChild(TEMPLATES.StandardButton(MakeAction(function()
            self:_NextEnum(def)
        end), LocalText("下一个", "Next"), { 100, 28 }))
        btn:SetPosition(xoff + 130, y)
        ApplyEnabledState(btn)
        table.insert(self.items, btn)
    end
end

function NPCCombatSettingsScreen:_Rebuild()
    if self.panel ~= nil then
        self.panel:Kill()
        self.panel = nil
    end

    local rows = CountVisibleRows(self.values)
    local layout_rows = rows
    if self.values.auto_combat_enabled ~= true then
        layout_rows = math.ceil((rows - 1) / 2) + 1
    end
    local panel_h = math.max(210, math.min(940, 130 + rows * ROW_H))
    panel_h = math.max(210, math.min(940, 130 + layout_rows * ROW_H))
    self.panel_h = panel_h
    self.panel = self.root:AddChild(TEMPLATES.RectangleWindow(PANEL_W, panel_h))
    self.panel:SetPosition(0, 10)

    self.title = self.panel:AddChild(Text(BODYTEXTFONT, 32, LocalText("NPC战斗设置（测试版未开放）", "NPC Combat Settings (Test Build - Not Released)")))
    self.title:SetPosition(0, panel_h * 0.5 - 36)

    self.items = {}
    local y = panel_h * 0.5 - 76

    self:_AddRow(Settings.DEFS_BY_KEY.auto_combat_enabled, y, 0)
    y = y - ROW_H

    if self.values.auto_combat_enabled == true then
        local note = self.panel:AddChild(Text(UIFONT, 20, LocalText("当前使用原本自动战斗逻辑。关闭自动战斗后可调整下方参数。", "Original automatic combat is active. Disable it to edit custom parameters.")))
        note:SetRegionSize(PANEL_W - 80, 60)
        note:SetPosition(0, y - 20)
        note:SetColour(0.8, 0.8, 0.8, 1)
        table.insert(self.items, note)
    else
        local group_labels = {}
        for _, group in ipairs(Settings.GROUPS) do
            group_labels[group.id] = IsChinese() and group.label_zh or group.label_en
        end

        local entries = {}
        local current_group = nil
        for _, def in ipairs(Settings.DEFS) do
            if def.key ~= "auto_combat_enabled" and Settings.IsVisibleInUI(def, self.values) then
                if def.group ~= current_group then
                    current_group = def.group
                    entries[#entries + 1] = { type = "header", group = current_group }
                end
                entries[#entries + 1] = { type = "def", def = def }
            end
        end

        local max_rows = math.ceil(#entries / 2)
        local col = 1
        local row = 0
        for _, entry in ipairs(entries) do
            if row >= max_rows then
                col = 2
                row = 0
            end
            local xoff = col == 1 and COL_LEFT_X or COL_RIGHT_X
            local cy = y - row * ROW_H
            if entry.type == "header" then
                local header = self.panel:AddChild(Text(BODYTEXTFONT, 24, group_labels[entry.group] or entry.group))
                header:SetPosition(xoff, cy - 4)
                header:SetRegionSize(320, HEADER_H)
                header:SetHAlign(ANCHOR_MIDDLE)
                header:SetColour(1, 0.86, 0.55, 1)
                table.insert(self.items, header)
            else
                self:_AddRow(entry.def, cy, xoff)
            end
            row = row + 1
        end
    end

    if self.values.show_advanced_settings == true then
        self.reset_btn = self.panel:AddChild(TEMPLATES.StandardButton(function() self:_Reset() end, LocalText("恢复默认", "Reset"), { 130, 36 }))
        self.reset_btn:SetPosition(-80, -panel_h * 0.5 + 34)

        self.basic_btn = self.panel:AddChild(TEMPLATES.StandardButton(function() self:_SetLocal("show_advanced_settings", false) end, LocalText("返回基础界面", "Basic UI"), { 150, 36 }))
        self.basic_btn:SetPosition(80, -panel_h * 0.5 + 34)
    else
        self.reset_btn = self.panel:AddChild(TEMPLATES.StandardButton(function() self:_Reset() end, LocalText("恢复默认", "Reset"), { 130, 36 }))
        self.reset_btn:SetPosition(-85, -panel_h * 0.5 + 34)

        self.close_btn = self.panel:AddChild(TEMPLATES.StandardButton(function() self:Close() end, LocalText("关闭", "Close"), { 130, 36 }))
        self.close_btn:SetPosition(85, -panel_h * 0.5 + 34)
    end
end

function NPCCombatSettingsScreen:ApplyPayload(payload)
    self.values = Settings.Decode(payload or "")
    self:_Rebuild()
end

function NPCCombatSettingsScreen:Close()
    if self.owner ~= nil and self.owner.HUD ~= nil and self.owner.HUD._npc_combat_settings_screen == self then
        self.owner.HUD._npc_combat_settings_screen = nil
    end
    if self._npcfriends_attached_to_hud then
        self:Kill()
    else
        TheFrontEnd:PopScreen(self)
    end
end

function NPCCombatSettingsScreen:OnControl(control, down)
    if NPCCombatSettingsScreen._base.OnControl(self, control, down) then
        return true
    end
    if not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
end

return NPCCombatSettingsScreen
