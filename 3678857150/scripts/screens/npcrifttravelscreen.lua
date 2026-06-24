
local G = GLOBAL
local Screen = GLOBAL.require("widgets/screen")
local Widget = GLOBAL.require("widgets/widget")
local Text = GLOBAL.require("widgets/text")
local Image = GLOBAL.require("widgets/image")
local ImageButton = GLOBAL.require("widgets/imagebutton")
local TEMPLATES = GLOBAL.require("widgets/redux/templates")

local function _IsChinese()
    local lang = nil
    if GLOBAL.rawget ~= nil then
        lang = GLOBAL.rawget(GLOBAL, "LANG")
    else
        local ok_lang, v_lang = GLOBAL.pcall(function() return GLOBAL.LANG end)
        if ok_lang then
            lang = v_lang
        end
    end
    if lang ~= nil then
        return tostring(lang) == "zh"
    end
    local ok, val = GLOBAL.pcall(function() return GLOBAL.STRINGS.UI.MAINSCREEN.PLAY end)
    return ok and type(val) == "string" and val:match("[\228-\233]") ~= nil
end

local _zh = _IsChinese()

local function _PrettyWorldName(worldid)
    local s = string.lower(tostring(worldid or ""))
    if s == "unknown" or s == "" then
        return _zh and "世界" or "World"
    end
    if s == "0" then
        return _zh and "地面" or "Master"
    end
    if s == "1" then
        return _zh and "地下" or "Caves"
    end
    if string.find(s, "cave", 1, true) then
        return _zh and "地下" or "Caves"
    end
    if string.find(s, "master", 1, true)
        or string.find(s, "forest", 1, true)
        or string.find(s, "surface", 1, true)
        or s == "1" then
        return _zh and "地面" or "Master"
    end
    return tostring(worldid)
end

NPCRiftTravelScreen = GLOBAL.Class(Screen, function(self, owner, source_guid, payload)
    Screen._ctor(self, "NPCRiftTravelScreen")

    self.owner = owner
    self.source_guid = GLOBAL.tonumber(source_guid) or 0
    self.rows = {}

    self:SetScaleMode(G.SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(G.MAX_HUD_SCALE)
    self:SetVAnchor(G.ANCHOR_MIDDLE)
    self:SetHAnchor(G.ANCHOR_MIDDLE)

    self.root = self:AddChild(TEMPLATES.ScreenRoot("root"))
    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(G.ANCHOR_MIDDLE)
    self.black:SetHRegPoint(G.ANCHOR_MIDDLE)
    self.black:SetVAnchor(G.ANCHOR_MIDDLE)
    self.black:SetHAnchor(G.ANCHOR_MIDDLE)
    self.black:SetScaleMode(G.SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0.35)
    self.black.OnMouseButton = function() self:Close() return true end

    self:_ParsePayload(payload or "")
    local row_count = #self.rows
    local show_rows = math.max(1, math.min(row_count, 8))

    local max_len = 0
    for _, r in ipairs(self.rows) do
        local txt = string.format("[%s] %s", _PrettyWorldName(r.worldid), tostring(r.name or ""))
        if string.len(txt) > max_len then
            max_len = string.len(txt)
        end
    end

    local panel_w = 200
    local panel_h = math.max(190, math.min(620, 130 + show_rows * 40))
    self._btn_w = 180
    self._panel_h = panel_h
    self._panel_w = panel_w

    self.panel = self.root:AddChild(TEMPLATES.RectangleWindow(panel_w, panel_h))
    self.panel:SetScale(1, 1)
    self.panel:SetPosition(0, 20)

    self.title = self.panel:AddChild(Text(G.BODYTEXTFONT, 32, _zh and "裂缝传送" or "Rift Travel"))
    self.title:SetPosition(0, panel_h * 0.5 - 34)

    self.close_btn = self.panel:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    self.close_btn:SetScale(0.5)
    local close_x = -panel_w * 0.5 + 235
    local close_y = panel_h * 0.5 - 10
    self.close_btn:SetPosition(close_x, close_y)
    self.close_btn:SetOnClick(function() self:Close() end)

    local delete_btn_bottom_pad = 24
    local delete_gap_scale = 2 / 3 
    self.delete_btn = self.panel:AddChild(TEMPLATES.StandardButton(function()
        if self.source_guid ~= nil and self.source_guid > 0 then
            SendModRPCToServer(GetModRPC("NPCFriends", "RiftDeleteCurrent"), tostring(self.source_guid))
        end
        self:Close()
    end, _zh and "删除当前点" or "Delete Current", { self._btn_w, 32 }))
    self.delete_btn:SetPosition(0, -panel_h * 0.5 + delete_btn_bottom_pad + (18 * (1 - delete_gap_scale)))

    self:_BuildRows()
end)

function NPCRiftTravelScreen:_ParsePayload(payload)
    for line in string.gmatch(payload, "[^\n]+") do
        local worldid, worldlabel, name, x_s, z_s = line:match("^([^\t]+)\t([^\t]+)\t([^\t]*)\t([%-%.%d]+)\t([%-%.%d]+)$")
        if worldid ~= nil then
            table.insert(self.rows, {
                worldid = tostring(worldid),
                worldlabel = tostring(worldlabel),
                name = (name ~= nil and name ~= "" and name) or (_zh and "未命名记忆点" or "Unnamed Rift"),
                x = GLOBAL.tonumber(x_s) or 0,
                z = GLOBAL.tonumber(z_s) or 0,
            })
        else
            local worldid2, name2, x2, z2 = line:match("^([^\t]+)\t([^\t]*)\t([%-%.%d]+)\t([%-%.%d]+)$")
            if worldid2 ~= nil then
                table.insert(self.rows, {
                    worldid = tostring(worldid2),
                    worldlabel = tostring(worldid2),
                    name = (name2 ~= nil and name2 ~= "" and name2) or (_zh and "未命名记忆点" or "Unnamed Rift"),
                    x = GLOBAL.tonumber(x2) or 0,
                    z = GLOBAL.tonumber(z2) or 0,
                })
            end
        end
    end
end

function NPCRiftTravelScreen:_BuildRows()
    if self.scroll_list ~= nil then
        self.scroll_list:Kill()
        self.scroll_list = nil
    end

    local list_data = {}
    for i, row in ipairs(self.rows) do
        list_data[i] = row
    end

    local visible_rows = math.max(1, math.min(#list_data, 8))
    local row_h = 38

    local function ItemCtor(context, index)
        local w = Widget("rift_item_" .. tostring(index))
        w.btn = w:AddChild(TEMPLATES.StandardButton(function() end, "", { self._btn_w, 34 }))
        w.btn:SetPosition(0, 0)
        w:SetOnGainFocus(function()
            if self.scroll_list then self.scroll_list:OnWidgetFocus(w) end
        end)
        return w
    end

    local function ItemApply(context, widget, data, index)
        if not data then
            widget:Hide()
            return
        end
        widget:Show()
        local world_name = _PrettyWorldName(data.worldlabel or data.worldid)
        local label = string.format("[%s] %s", world_name, data.name)
        if string.len(label) > 52 then
            label = string.sub(label, 1, 51) .. "…"
        end
        widget.btn:SetText(label)
        widget.btn:SetOnClick(function()
            SendModRPCToServer(GetModRPC("NPCFriends", "RiftTeleport"), string.format("%d|%s|%.2f|%.2f", self.source_guid, tostring(data.worldid or "unknown"), data.x or 0, data.z or 0))
            self:Close()
        end)
    end

    self.scroll_list = self.panel:AddChild(TEMPLATES.ScrollingGrid(list_data, {
        context = {},
        widget_width = self._btn_w + 16,
        widget_height = row_h,
        num_visible_rows = visible_rows,
        num_columns = 1,
        item_ctor_fn = ItemCtor,
        apply_fn = ItemApply,
        scrollbar_offset = 12,
        scrollbar_height_offset = -40,
        peek_percent = 0,
        allow_bottom_empty_row = true,
    }))
    self.scroll_list:SetPosition(0, 18)
end

function NPCRiftTravelScreen:Close()
    if self.owner ~= nil and self.owner.HUD ~= nil and self.owner.HUD._npc_rift_travel_screen == self then
        self.owner.HUD._npc_rift_travel_screen = nil
    end
    G.TheFrontEnd:PopScreen(self)
end

function NPCRiftTravelScreen:OnControl(control, down)
    if NPCRiftTravelScreen._base.OnControl(self, control, down) then
        return true
    end
    if not down and control == G.CONTROL_CANCEL then
        self:Close()
        return true
    end
end

AddClassPostConstruct("screens/playerhud", function(self)
    self.ShowNPCRiftTravelScreen = function(_, source_guid, payload)
        if self._npc_rift_travel_screen ~= nil then
            self._npc_rift_travel_screen:Close()
            self._npc_rift_travel_screen = nil
        end
        self._npc_rift_travel_screen = NPCRiftTravelScreen(self.owner, source_guid, payload)
        self:OpenScreenUnderPause(self._npc_rift_travel_screen)
    end
end)
