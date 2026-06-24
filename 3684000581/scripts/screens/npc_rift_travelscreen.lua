local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local TEMPLATES = require("widgets/redux/templates")

local PANEL_W = 560
local PANEL_H = 540
local LIST_BTN_W = 420
local LIST_BTN_H = 36

local NPCRiftTravelScreen = Class(Screen, function(self, owner, source_guid, payload)
    Screen._ctor(self, "NPCRiftTravelScreen")

    self.owner = owner
    self.source_guid = tonumber(source_guid) or 0
    self.rows = {}

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.root = self:AddChild(TEMPLATES.ScreenRoot("root"))
    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0.35)
    self.black.OnMouseButton = function() self:Close() return true end

    self.panel = self.root:AddChild(TEMPLATES.RectangleWindow(PANEL_W, PANEL_H))
    self.panel:SetPosition(0, 20)

    self.title = self.panel:AddChild(Text(BODYTEXTFONT, 32, "Rift Travel"))
    self.title:SetPosition(0, 220)

    self.close_btn = self.panel:AddChild(TEMPLATES.StandardButton(function() self:Close() end, "Close", { 120, 42 }))
    self.close_btn:SetPosition(0, -220)

    self:_ParsePayload(payload or "")
    self:_PrintDebugSize()
    self:_BuildRows()
end)

function NPCRiftTravelScreen:_PrintDebugSize()
    local screen_w, screen_h = 0, 0
    if TheSim ~= nil and TheSim.GetScreenSize ~= nil then
        screen_w, screen_h = TheSim:GetScreenSize()
    end
    print(string.format(
        "[NPC_RIFT_TRAVEL_UI] open panel=%dx%d panel_pos=(0,20) list_btn=%dx%d rows=%d screen=%dx%d max_hud_scale=%s",
        PANEL_W,
        PANEL_H,
        LIST_BTN_W,
        LIST_BTN_H,
        #self.rows,
        tonumber(screen_w) or 0,
        tonumber(screen_h) or 0,
        tostring(MAX_HUD_SCALE)
    ))
end

function NPCRiftTravelScreen:_ParsePayload(payload)
    for line in string.gmatch(payload, "[^\n]+") do
        local guid_s, name, x_s, z_s = line:match("^(%d+)\t([^\t]*)\t([%-%.%d]+)\t([%-%.%d]+)$")
        if guid_s ~= nil then
            table.insert(self.rows, {
                guid = tonumber(guid_s) or 0,
                name = (name ~= nil and name ~= "" and name) or "Unnamed Rift",
                x = tonumber(x_s) or 0,
                z = tonumber(z_s) or 0,
            })
        end
    end
end

function NPCRiftTravelScreen:_BuildRows()
    self.items = {}
    for i, row in ipairs(self.rows) do
        local y = 160 - (i - 1) * 46
        if y < -170 then
            break
        end

        local btn = self.panel:AddChild(TEMPLATES.StandardButton(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "RiftTeleport"), string.format("%d|%d", self.source_guid, row.guid))
            self:Close()
        end, row.name, { LIST_BTN_W, LIST_BTN_H }))
        btn:SetPosition(0, y)
        table.insert(self.items, btn)

        local coord = self.panel:AddChild(Text(UIFONT, 18, string.format("(%.1f, %.1f)", row.x, row.z)))
        coord:SetPosition(0, y - 18)
        coord:SetColour(0.8, 0.8, 0.8, 1)
        table.insert(self.items, coord)
    end
end

function NPCRiftTravelScreen:Close()
    if self.owner ~= nil and self.owner.HUD ~= nil and self.owner.HUD._npc_rift_travel_screen == self then
        self.owner.HUD._npc_rift_travel_screen = nil
    end
    TheFrontEnd:PopScreen(self)
end

function NPCRiftTravelScreen:OnControl(control, down)
    if NPCRiftTravelScreen._base.OnControl(self, control, down) then
        return true
    end
    if not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
end

return NPCRiftTravelScreen
