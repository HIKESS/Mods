-- ========== NPC 换肤界面  ==========
-- 客户端选皮肤 → 把 5 个皮肤名通过 RPC 发给服务端 → 服务端 npc_skin.ApplyNPCClothing

local SCREEN_OFFSET = -.38 * GLOBAL.RESOLUTION_X

local function _IsUsingController()
    return GLOBAL.TheInput:ControllerAttached() and not GLOBAL.TheFrontEnd.tracking_mouse
end

NpcSkinPopup = GLOBAL.Class(Screen, function(self, owner_param, char_prefab, doer, profile, initial_skins)
    Screen._ctor(self, "NpcSkinPopup")

    local LoadoutSelect = GLOBAL.require("widgets/redux/loadoutselect")
    local Menu = GLOBAL.require("widgets/menu")
    local STRINGS = GLOBAL.STRINGS

    self.owner_param = owner_param
    self.char_prefab = char_prefab
    self.doer = doer
    self.profile = profile

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.proot:SetHAnchor(GLOBAL.ANCHOR_MIDDLE)
    self.proot:SetScaleMode(GLOBAL.SCALEMODE_PROPORTIONAL)

    self.root = self.proot:AddChild(Widget("root"))
    self.root:SetPosition(-GLOBAL.RESOLUTION_X / 2, -GLOBAL.RESOLUTION_Y / 2, 0)

    local bg = self.proot:AddChild(Image("images/bg_redux_wardrobe_bg.xml", "wardrobe_bg.tex"))
    bg:SetScale(.8)
    bg:SetPosition(-200, 0)
    bg:SetTint(1, 1, 1, .76)

    self.initial_skins = initial_skins or {}

    self.loadout = self.proot:AddChild(
        LoadoutSelect(profile, char_prefab, nil, true, nil, true, self.initial_skins))
    self.loadout:SetDefaultMenuOption()

    local offline = not GLOBAL.TheInventory:HasSupportForOfflineSkins() and not GLOBAL.TheNet:IsOnlineMode()

    local buttons = {}
    if offline then
        table.insert(buttons, { text = STRINGS.UI.POPUPDIALOG.OK, cb = function() self:Close() end })
    else
        table.insert(buttons, { text = STRINGS.UI.WARDROBE_POPUP.CANCEL, cb = function() self:Cancel() end })
        table.insert(buttons, { text = STRINGS.UI.WARDROBE_POPUP.SET, cb = function() self:Close(true) end })
    end

    local spacing = 70
    self.menu = self.proot:AddChild(Menu(buttons, spacing, false, "carny_long", nil, 30))

    self.loadout:SetPosition(-306, 0)
    self.menu:SetPosition(493, -260, 0)

    if _IsUsingController() then
        self.menu:Hide()
        self.menu:Disable()
    end

    self.default_focus = self.loadout

    GLOBAL.TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)

    self:DoFocusHookups()

    GLOBAL.SetAutopaused(true)
end)

function NpcSkinPopup:OnDestroy()
    GLOBAL.SetAutopaused(false)
    GLOBAL.TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)
    self._base.OnDestroy(self)
end

function NpcSkinPopup:OnBecomeActive()
    self._base.OnBecomeActive(self)
    if self.loadout and self.loadout.subscreener then
        for _, sub_screen in pairs(self.loadout.subscreener.sub_screens) do
            sub_screen:RefreshInventory()
        end
    end
    if _IsUsingController() then
        self.default_focus:SetFocus()
    end
end

function NpcSkinPopup:DoFocusHookups()
    self.menu:SetFocusChangeDir(GLOBAL.MOVE_LEFT, self.loadout)
    self.loadout:SetFocusChangeDir(GLOBAL.MOVE_RIGHT, self.menu)
end

function NpcSkinPopup:OnControl(control, down)
    if NpcSkinPopup._base.OnControl(self, control, down) then return true end

    if control == GLOBAL.CONTROL_CANCEL and not down then
        self:Cancel()
        GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    elseif control == GLOBAL.CONTROL_MENU_START and not down then
        self:Close(true)
        GLOBAL.TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function NpcSkinPopup:Cancel()
    self:Reset()
    self:Close()
end

function NpcSkinPopup:Reset()
    self.loadout.selected_skins = self.initial_skins
end

function NpcSkinPopup:Close(apply_skins)
    if not apply_skins then
        GLOBAL.TheFrontEnd:PopScreen(self)
        return
    end

    local skins = self.loadout.selected_skins or {}

    local data = {}
    if GLOBAL.TheInventory:HasSupportForOfflineSkins() or GLOBAL.TheNet:IsOnlineMode() then
        data = skins
    end

    local default_base = (self.loadout.currentcharacter or self.char_prefab) .. "_none"
    if not data.base or data.base == self.loadout.currentcharacter or data.base == ""
        or not GLOBAL.TheInventory:CheckOwnership(data.base) then
        data.base = default_base
    end
    if not GLOBAL.IsValidClothing(data.body) or not GLOBAL.TheInventory:CheckOwnership(data.body) then data.body = "" end
    if not GLOBAL.IsValidClothing(data.hand) or not GLOBAL.TheInventory:CheckOwnership(data.hand) then data.hand = "" end
    if not GLOBAL.IsValidClothing(data.legs) or not GLOBAL.TheInventory:CheckOwnership(data.legs) then data.legs = "" end
    if not GLOBAL.IsValidClothing(data.feet) or not GLOBAL.TheInventory:CheckOwnership(data.feet) then data.feet = "" end

    local payload = table.concat({
        self.owner_param,
        data.base or "",
        data.body or "",
        data.hand or "",
        data.legs or "",
        data.feet or "",
    }, "|")

    GLOBAL.pcall(function()
        SendModRPCToServer(GetModRPC("NPCFriends", "SetNPCClothing"), payload)
    end)

    if self.profile then
        self.profile:SetCollectionTimestamp(self:GetTimestamp())
    end

    GLOBAL.TheFrontEnd:PopScreen(self)
end

function NpcSkinPopup:GetTimestamp()
    local templist = GLOBAL.TheInventory:GetFullInventory()
    local timestamp = 0
    for _, v in ipairs(templist) do
        if v.modified_time > timestamp then
            timestamp = v.modified_time
        end
    end
    return timestamp
end

function NpcSkinPopup:GetHelpText()
    local controller_id = GLOBAL.TheInput:GetControllerID()
    local t = {}
    table.insert(t, GLOBAL.TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CANCEL) .. " " .. GLOBAL.STRINGS.UI.HELP.CANCEL)
    table.insert(t, GLOBAL.TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_MENU_START) .. " " .. GLOBAL.STRINGS.UI.WARDROBE_POPUP.SET)
    return table.concat(t, "  ")
end
