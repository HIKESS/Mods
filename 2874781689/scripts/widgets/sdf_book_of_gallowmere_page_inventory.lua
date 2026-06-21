local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
--local Text = require "widgets/text"
--local UIAnim = require "widgets/uianim"
--local TrueScrollList = require "widgets/truescrolllist" --not needed
--local Grid = require "widgets/grid" --not needed
--local Spinner = require "widgets/spinner" --not needed ?
--local TrueScrollArea = require "widgets/truescrollarea" --not needed
--local PopupDialogScreen = require "screens/popupdialog" --not needed

--local TEMPLATES = require "widgets/redux/templates"

local HUDResolution = TUNING.SDF_BOOK_OF_GALLOWMERE_HUD_RESOLUTION
local HUDHeight = 0
local HUDWidth = 0
local HUDPageButtonPos = 0
if HUDResolution == 2 then
    HUDHeight = 850
    HUDWidth = 425
    HUDPageButtonPos = 290
elseif HUDResolution == 1 then
    HUDHeight = 760
    HUDWidth = 380
    HUDPageButtonPos = 260
else
    HUDHeight = 720
    HUDWidth = 360
    HUDPageButtonPos = 250
end

local SDFBookOfGallowmerePageInventory = Class(Widget, function(self, owner)
	Widget._ctor(self, "SDFBookOfGallowmerePageInventory")

	self.page_inventory = SDFTheBookOfGallowmere.page_inventory or {  }

	self.parent_screen = owner

	self.maxPageTotal = owner.components.sdf_book_of_gallowmere_entry:GetEntryTotal() or 0
	self.currentPage = 0
	self.turningPage = false

	self.page = self:AddChild(Image("images/pageimages/"..self.page_inventory[0]..".xml", ""..self.page_inventory[0]..".tex"))
	self.page:SetSize(HUDHeight, HUDWidth) --970, 570

	self.lastPageTurner = self:AddChild(self:CreateLastPageTurner())
	self.nextPageTurner = self:AddChild(self:CreateNextPageTurner())
end)

function SDFBookOfGallowmerePageInventory:CreateLastPageTurnerAnimation(newPageNumber)
	--Stop fast animation
	self.turningPage = true

	--fade out
	self.inst:DoTaskInTime(0.05, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(0.1, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(0.15, function()
	    self.page:SetFadeAlpha(0, true)
	end)

	--turn Page
	self.inst:DoTaskInTime(0.3, function()
	    self.page:SetFadeAlpha(1, true)
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_7.xml", "sdf_book_of_gallowmere_page_turn_7.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	    self.parent_screen.SoundEmitter:PlaySound("dontstarve/common/use_book")
	end)
	self.inst:DoTaskInTime(0.4, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_6.xml", "sdf_book_of_gallowmere_page_turn_6.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.5, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_5.xml", "sdf_book_of_gallowmere_page_turn_5.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.6, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_4.xml", "sdf_book_of_gallowmere_page_turn_4.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.7, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_3.xml", "sdf_book_of_gallowmere_page_turn_3.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.8, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_2.xml", "sdf_book_of_gallowmere_page_turn_2.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.9, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_1.xml", "sdf_book_of_gallowmere_page_turn_1.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)

	--fade in
	self.inst:DoTaskInTime(1, function()
	    self.page:SetFadeAlpha(0, true)
	    self.page:SetTexture("images/pageimages/"..self.page_inventory[newPageNumber]..".xml", ""..self.page_inventory[newPageNumber]..".tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(1.15, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(1.2, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(1.25, function()
	    self.page:SetFadeAlpha(1, true)
	    self.turningPage = false
	end)
end

function SDFBookOfGallowmerePageInventory:CreateLastPageTurnerEndAnimation(newPageNumber)
	--Stop fast animation
	self.turningPage = true

	--fade out
	self.inst:DoTaskInTime(0.05, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(0.1, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(0.15, function()
	    self.page:SetFadeAlpha(0, true)
	end)

	--turn Page
	self.inst:DoTaskInTime(0.3, function()
	    self.page:SetFadeAlpha(1, true)
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_7.xml", "sdf_book_of_gallowmere_page_turn_7.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	    self.parent_screen.SoundEmitter:PlaySound("dontstarve/common/use_book")
	end)
	self.inst:DoTaskInTime(0.35, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_6.xml", "sdf_book_of_gallowmere_page_turn_6.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.4, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_5.xml", "sdf_book_of_gallowmere_page_turn_5.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.45, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_4.xml", "sdf_book_of_gallowmere_page_turn_4.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.5, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_3.xml", "sdf_book_of_gallowmere_page_turn_3.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.55, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_2.xml", "sdf_book_of_gallowmere_page_turn_2.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.6, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_1.xml", "sdf_book_of_gallowmere_page_turn_1.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.65, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_7.xml", "sdf_book_of_gallowmere_page_turn_7.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	    self.parent_screen.SoundEmitter:PlaySound("dontstarve/common/use_book")
	end)
	self.inst:DoTaskInTime(0.7, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_6.xml", "sdf_book_of_gallowmere_page_turn_6.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.75, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_5.xml", "sdf_book_of_gallowmere_page_turn_5.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.8, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_4.xml", "sdf_book_of_gallowmere_page_turn_4.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.85, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_3.xml", "sdf_book_of_gallowmere_page_turn_3.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.9, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_2.xml", "sdf_book_of_gallowmere_page_turn_2.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.95, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_1.xml", "sdf_book_of_gallowmere_page_turn_1.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)

	--fade in
	self.inst:DoTaskInTime(1.1, function()
	    self.page:SetFadeAlpha(0, true)
	    self.page:SetTexture("images/pageimages/"..self.page_inventory[newPageNumber]..".xml", ""..self.page_inventory[newPageNumber]..".tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(1.25, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(1.3, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(1.35, function()
	    self.page:SetFadeAlpha(1, true)
	    self.turningPage = false
	end)
end

function SDFBookOfGallowmerePageInventory:CreateNextPageTurnerAnimation(newPageNumber)
	--Stop fast animation
	self.turningPage = true

	--fade out
	self.inst:DoTaskInTime(0.05, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(0.1, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(0.15, function()
	    self.page:SetFadeAlpha(0, true)
	end)

	--turn Page
	self.inst:DoTaskInTime(0.3, function()
	    self.page:SetFadeAlpha(1, true)
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_1.xml", "sdf_book_of_gallowmere_page_turn_1.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	    self.parent_screen.SoundEmitter:PlaySound("dontstarve/common/use_book")
	end)
	self.inst:DoTaskInTime(0.4, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_2.xml", "sdf_book_of_gallowmere_page_turn_2.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.5, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_3.xml", "sdf_book_of_gallowmere_page_turn_3.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.6, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_4.xml", "sdf_book_of_gallowmere_page_turn_4.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.7, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_5.xml", "sdf_book_of_gallowmere_page_turn_5.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.8, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_6.xml", "sdf_book_of_gallowmere_page_turn_6.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.9, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_7.xml", "sdf_book_of_gallowmere_page_turn_7.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)

	--fade in
	self.inst:DoTaskInTime(1, function()
	    self.page:SetFadeAlpha(0, true)
	    self.page:SetTexture("images/pageimages/"..self.page_inventory[newPageNumber]..".xml", ""..self.page_inventory[newPageNumber]..".tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(1.15, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(1.2, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(1.25, function()
	    self.page:SetFadeAlpha(1, true)
	    self.turningPage = false
	end)
end

function SDFBookOfGallowmerePageInventory:CreateNextPageTurnerEndAnimation(newPageNumber)
	--Stop fast animation
	self.turningPage = true

	--fade out
	self.inst:DoTaskInTime(0.05, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(0.1, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(0.15, function()
	    self.page:SetFadeAlpha(0, true)
	end)

	--turn Page
	self.inst:DoTaskInTime(0.3, function()
	    self.page:SetFadeAlpha(1, true)
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_1.xml", "sdf_book_of_gallowmere_page_turn_1.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	    self.parent_screen.SoundEmitter:PlaySound("dontstarve/common/use_book")
	end)
	self.inst:DoTaskInTime(0.35, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_2.xml", "sdf_book_of_gallowmere_page_turn_2.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.4, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_3.xml", "sdf_book_of_gallowmere_page_turn_3.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.45, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_4.xml", "sdf_book_of_gallowmere_page_turn_4.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.5, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_5.xml", "sdf_book_of_gallowmere_page_turn_5.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.55, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_6.xml", "sdf_book_of_gallowmere_page_turn_6.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.6, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_7.xml", "sdf_book_of_gallowmere_page_turn_7.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.65, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_1.xml", "sdf_book_of_gallowmere_page_turn_1.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	    self.parent_screen.SoundEmitter:PlaySound("dontstarve/common/use_book")
	end)
	self.inst:DoTaskInTime(0.7, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_2.xml", "sdf_book_of_gallowmere_page_turn_2.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.75, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_3.xml", "sdf_book_of_gallowmere_page_turn_3.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.8, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_4.xml", "sdf_book_of_gallowmere_page_turn_4.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.85, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_5.xml", "sdf_book_of_gallowmere_page_turn_5.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.9, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_6.xml", "sdf_book_of_gallowmere_page_turn_6.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(0.95, function()
	    self.page:SetTexture("images/pageimages/sdf_book_of_gallowmere_page_turn_7.xml", "sdf_book_of_gallowmere_page_turn_7.tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)

	--fade in
	self.inst:DoTaskInTime(1.1, function()
	    self.page:SetFadeAlpha(0, true)
	    self.page:SetTexture("images/pageimages/"..self.page_inventory[newPageNumber]..".xml", ""..self.page_inventory[newPageNumber]..".tex")
	    self.page:SetSize(HUDHeight, HUDWidth)
	end)
	self.inst:DoTaskInTime(1.25, function()
	    self.page:SetFadeAlpha(0.33, true)
	end)
	self.inst:DoTaskInTime(1.3, function()
	    self.page:SetFadeAlpha(0.66, true)
	end)
	self.inst:DoTaskInTime(1.35, function()
	    self.page:SetFadeAlpha(1, true)
	    self.turningPage = false
	end)
end

function SDFBookOfGallowmerePageInventory:CreateLastPageTurner()
	local lastPageTurner = ImageButton("images/pageimages/sdf_book_of_gallowmere_last_page_turner.xml", "sdf_book_of_gallowmere_last_page_turner.tex")
	lastPageTurner:SetPosition(-HUDPageButtonPos, 0)
	lastPageTurner:SetScale(0.8, 0.8) --0.8

	lastPageTurner:SetOnClick(function()
	    local lastPageNumber = self.currentPage - 1

	    if self.maxPageTotal == 0 or self.turningPage == true then
		return
	    end

	    if lastPageNumber >= 0 then
		if self.page_inventory[lastPageNumber] ~= nil then
		    self:CreateLastPageTurnerAnimation(lastPageNumber)
		    self.currentPage = lastPageNumber
		end
	    else
		if self.page_inventory[self.maxPageTotal] ~= nil then
		    self:CreateNextPageTurnerEndAnimation(self.maxPageTotal)
		    self.currentPage = self.maxPageTotal
		end
	    end
	end)
	return lastPageTurner
end

function SDFBookOfGallowmerePageInventory:CreateNextPageTurner()
	local nextPageTurner = ImageButton("images/pageimages/sdf_book_of_gallowmere_next_page_turner.xml", "sdf_book_of_gallowmere_next_page_turner.tex")
	nextPageTurner:SetPosition(HUDPageButtonPos, 0)
	nextPageTurner:SetScale(0.8, 0.8)

	nextPageTurner:SetOnClick(function()
	    local nextPageNumber = self.currentPage + 1

	    if self.maxPageTotal == 0 or self.turningPage == true then
		return
	    end

	    if nextPageNumber <= self.maxPageTotal then
		if self.page_inventory[nextPageNumber] ~= nil then
		    self:CreateNextPageTurnerAnimation(nextPageNumber)
		    self.currentPage = nextPageNumber
		end
	    else
		self:CreateLastPageTurnerEndAnimation(0)
		self.currentPage = 0 
	    end
	end)
	return nextPageTurner
end

return SDFBookOfGallowmerePageInventory