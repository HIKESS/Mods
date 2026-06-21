local Image = require "widgets/image"
local Widget = require "widgets/widget"
local BookOfGallowmerePageInventory = require "widgets/sdf_book_of_gallowmere_page_inventory"
local BookOfGallowmerePageFriendlies = require "widgets/sdf_book_of_gallowmere_page_friendlies"
local BookOfGallowmerePageEnemies = require "widgets/sdf_book_of_gallowmere_page_enemies"
local BookOfGallowmerePageBosses = require "widgets/sdf_book_of_gallowmere_page_bosses"

require("util")

local HUDResolution = TUNING.SDF_BOOK_OF_GALLOWMERE_HUD_RESOLUTION
local HUDHeight = 0
local HUDWidth = 0
local HUDPos = 0
if HUDResolution == 2 then --970 485
    HUDHeight = 850
    HUDWidth = 425
    HUDPos = -20
elseif HUDResolution == 1 then
    HUDHeight = 760
    HUDWidth = 380
    HUDPos = -05
else
    HUDHeight = 720
    HUDWidth = 360
end

local SDFBookOfGallowmereWidget = Class(Widget, function(self, owner)
    Widget._ctor(self, "SDFBookOfGallowmereWidget")

    self.root = self:AddChild(Widget("root"))

    local book_background = self.root:AddChild(Image("images/pageimages/sdf_book_of_gallowmere_page_blank.xml", "sdf_book_of_gallowmere_page_blank.tex"))
    book_background:SetSize(HUDHeight, HUDWidth)
    book_background:SetPosition(0, HUDPos)

    if owner:HasTag("sdf_book_of_gallowmere_entries_inventory_read") then
	local page = book_background:AddChild(BookOfGallowmerePageInventory(owner))
    elseif owner:HasTag("sdf_book_of_gallowmere_entries_friendlies_read") then
	local page = book_background:AddChild(BookOfGallowmerePageFriendlies(owner))
    elseif owner:HasTag("sdf_book_of_gallowmere_entries_enemies_read") then
	local page = book_background:AddChild(BookOfGallowmerePageEnemies(owner))
    elseif owner:HasTag("sdf_book_of_gallowmere_entries_bosses_read") then
	local page = book_background:AddChild(BookOfGallowmerePageBosses(owner))
    else
	POPUPS.SDFBOOKOFGALLOWMERE:Close(owner)
    end
end)

return SDFBookOfGallowmereWidget