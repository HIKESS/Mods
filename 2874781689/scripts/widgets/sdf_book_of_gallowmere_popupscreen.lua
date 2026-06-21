local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local SDFBookOfGallowmereWidget = require "util/sdf_book_of_gallowmere_widget"

local SDFBookOfGallowmerePopupScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "SDFBookOfGallowmerePopupScreen")

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0, 0, 0, 0.5)
    black:SetOnClick(function() TheFrontEnd:PopScreen() end)
    black:SetHelpTextMessage("")

    local root = self:AddChild(Widget("root"))
    root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
    root:SetPosition(0, 350) --40

    self.book = root:AddChild(SDFBookOfGallowmereWidget(self.owner))

    self.default_focus = self.book

    --SetAutopaused(true)
end)

function SDFBookOfGallowmerePopupScreen:OnDestroy()
    --SetAutopaused(false)

    --Stop Reading Tags
    if self.owner:HasTag("sdf_book_of_gallowmere_entries_inventory_read") then
	self.owner:RemoveTag("sdf_book_of_gallowmere_entries_inventory_read")
    end
    if self.owner:HasTag("sdf_book_of_gallowmere_entries_friendlies_read") then
	self.owner:RemoveTag("sdf_book_of_gallowmere_entries_friendlies_read")
    end
    if self.owner:HasTag("sdf_book_of_gallowmere_entries_enemies_read") then
	self.owner:RemoveTag("sdf_book_of_gallowmere_entries_enemies_read")
    end
    if self.owner:HasTag("sdf_book_of_gallowmere_entries_bosses_read") then
	self.owner:RemoveTag("sdf_book_of_gallowmere_entries_bosses_read")
    end

    POPUPS.SDFBOOKOFGALLOWMERE:Close(self.owner)
    SDFBookOfGallowmerePopupScreen._base.OnDestroy(self)
end

function SDFBookOfGallowmerePopupScreen:OnBecomeInactive()
    SDFBookOfGallowmerePopupScreen._base.OnBecomeInactive(self)
end

function SDFBookOfGallowmerePopupScreen:OnBecomeActive()
    SDFBookOfGallowmerePopupScreen._base.OnBecomeActive(self)
end

function SDFBookOfGallowmerePopupScreen:OnControl(control, down)
    if SDFBookOfGallowmerePopupScreen._base.OnControl(self, control, down) then
	return true
    end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
	self.owner.SoundEmitter:PlaySound("dontstarve/common/use_book")
        TheFrontEnd:PopScreen()
		
        return true
    end

	return false
end

return SDFBookOfGallowmerePopupScreen