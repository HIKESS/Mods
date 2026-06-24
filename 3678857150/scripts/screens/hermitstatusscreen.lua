-- 寄居蟹老奶奶状态面板（独立于 NPCFriends 状态栏）

local PANEL_W = 290
local PANEL_H = 360

HermitStatusScreen = GLOBAL.Class(Widget, function(self, data)
    Widget._ctor(self, "HermitStatusWidget")

    self.data = data or {}
    self.guid = tostring(self.data.guid or "")

    self.panel_bg = self:AddChild(Image("images/scoreboard.xml", "scoreboard_frame.tex"))
    self.panel_bg:ScaleToSize(PANEL_W, PANEL_H)

    self.close_btn = self:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    self.close_btn:SetScale(0.5)
    self.close_btn:SetPosition(PANEL_W / 2 - 25, PANEL_H / 2 - 25)
    self.close_btn:SetOnClick(function()
        local hud = GLOBAL.ThePlayer and GLOBAL.ThePlayer.HUD
        if hud then hud._hermit_status_widget = nil end
        self:Kill()
    end)

    self.title = self:AddChild(Text(GLOBAL.TITLEFONT, 28, T("title_hermit_status")))
    self.title:SetColour(1, 0.8, 0.3, 1)
    self.title:SetPosition(0, PANEL_H / 2 - 50)

    self.sep1 = self:AddChild(Image("images/global.xml", "square.tex"))
    self.sep1:SetSize(PANEL_W - 60, 2)
    self.sep1:SetTint(0.5, 0.5, 0.5, 0.5)
    self.sep1:SetPosition(0, PANEL_H / 2 - 82)

    self.rows = {}
    local row_defs = {
        { key = "friend_level", label = "label_hermit_friend_level" },
        { key = "friend_stage", label = "label_hermit_friend_stage" },
        { key = "tasks", label = "label_hermit_tasks" },
        { key = "shop_level", label = "label_hermit_shop_level" },
        { key = "pearl_given", label = "label_hermit_pearl_given" },
        { key = "cracked_pearl", label = "label_hermit_cracked_pearl" },
        { key = "high_friend", label = "label_hermit_high_friend" },
    }

    local start_y = PANEL_H / 2 - 120
    for i, def in ipairs(row_defs) do
        local y = start_y - (i - 1) * 28
        local label = self:AddChild(Text(GLOBAL.UIFONT, 21, T(def.label) .. ":"))
        label:SetColour(1, 1, 1, 1)
        label:SetHAlign(GLOBAL.ANCHOR_LEFT)
        label:SetRegionSize(150, 26)
        label:SetPosition(-42, y)

        local value = self:AddChild(Text(GLOBAL.UIFONT, 21, ""))
        value:SetColour(1, 1, 1, 1)
        value:SetHAlign(GLOBAL.ANCHOR_LEFT)
        value:SetRegionSize(70, 26)
        value:SetPosition(102, y)

        self.rows[def.key] = value
    end

    self.auto_refresh_task = GLOBAL.ThePlayer:DoPeriodicTask(2, function()
        if not self._killed and self.guid ~= "" then
            GLOBAL.pcall(function()
                SendModRPCToServer(GetModRPC("DstAdmin", "RequestHermitStatus"), self.guid)
            end)
        end
    end)

    self:UpdateData(self.data)
end)

local function BoolText(value)
    return value and T("status_yes") or T("status_no")
end

function HermitStatusScreen:UpdateData(data)
    if data == nil then return end
    self.data = data
    self.guid = tostring(data.guid or self.guid or "")

    self.title:SetString(tostring(data.display_name or T("title_hermit_status")))
    self.rows.friend_level:SetString(tostring(data.friend_level or 0) .. "/" .. tostring(data.friend_max_level or 0))
    self.rows.friend_stage:SetString(tostring(data.friend_stage or "LOW"))
    self.rows.tasks:SetString(tostring(data.tasks_completed or 0) .. "/" .. tostring(data.tasks_total or 0))
    self.rows.shop_level:SetString(tostring(data.shop_level or 0))
    self.rows.pearl_given:SetString(BoolText(data.pearl_given == true))
    self.rows.cracked_pearl:SetString(BoolText(data.cracked_pearl == true))
    self.rows.high_friend:SetString(BoolText(data.high_friend == true))
end

function HermitStatusScreen:Kill()
    self._killed = true
    if self.auto_refresh_task ~= nil then
        self.auto_refresh_task:Cancel()
        self.auto_refresh_task = nil
    end
    Widget.Kill(self)
end
