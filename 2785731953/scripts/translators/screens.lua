--------------------------------------------------------------------------------------------

require("characterutil")

--------------------------------------------------------------------------------------------
--// Hero Names (the ones that appear when you hover over a character in char select)
--------------------------------------------------------------------------------------------
--// From "scripts/languages/loc.lua" -- No need to override the actual function as, currently, I don't plan to translate any other images.
local function GetNamesImageSuffix()
	return CONFIG.NAME_TRANSLATIONS.UNTRANSLATE_NOTBOSSES and "" or "_br"
end

local function SetHeroNameTexture_Gold(image_widget, character)
	local loc_suffix = (character == "wonkey" or character == "random") and GetNamesImageSuffix() or ""
	local hero_atlas = "images/names_gold" .. loc_suffix .. "_" .. character..".xml"
	if GLOBAL.softresolvefilepath(hero_atlas) then
		image_widget:SetTexture(hero_atlas, character..".tex")
		return true
	else
		return GLOBAL.SetHeroNameTexture_Grey(image_widget, character)
	end
end

GLOBAL.SetHeroNameTexture_Gold = SetHeroNameTexture_Gold -- // From "characterutil.lua"

--------------------------------------------------------------------------------------------
--// Morgue Names
--------------------------------------------------------------------------------------------
local function tchelper(first, rest)
	return first:upper()..rest:lower()
end

local oldGetKilledByFromMorgueRow = GLOBAL.GetKilledByFromMorgueRow
local function GetKilledByFromMorgueRow(data)
	local killed_by = oldGetKilledByFromMorgueRow(data)
	
	if data.pk then
		return killed_by
	end
	
	killed_by = killed_by:lower() -- Reset it to lower, then re-upper first letters.
	return killed_by:gsub("(%a)([%w_áâãeéêiíoóôõuúç']*)", tchelper)
end

GLOBAL.GetKilledByFromMorgueRow = GetKilledByFromMorgueRow -- // From "characterutil.lua"

--------------------------------------------------------------------------------------------
--// Early/Late Season
--------------------------------------------------------------------------------------------
AddClassPostConstruct("widgets/redux/serversaveslot", function(self)
	local oldSetSaveSlot = self.SetSaveSlot
	self.SetSaveSlot = function(self, slot)
		oldSetSaveSlot(self, slot)
		
		local str = self.day_and_season.string
		local ds, de = str:find("Dia")
		if ds and de then
			local pre = str:sub(1, ds - 2) -- "Início de Inverno"
			local pst = str:sub(ds - 1) -- " Dia {dia}"
			str = TheDictionary.GetTranslation(pre)..pst
		end
		
		self.day_and_season:SetString(str)
		
		--// Additionally translate hover for server privacy.
		self.privacy:SetHoverText(TheDictionary.GetTranslation(self.privacy.hovertext.string))
	end
end)

AddClassPostConstruct("screens/redux/serverlistingscreen", function(self)
	local oldDoFiltering = self.DoFiltering
	self.DoFiltering = function(...)
		oldDoFiltering(...)
		
		if self.view_online and self.server_playstyle.id ~= nil and #self.queryTokens <= 0 then
			self.title:SetString(TheDictionary.GetTranslation(self.title.string))
		end
	end

	local oldUpdateServerData = self.UpdateServerData
	self.UpdateServerData = function(...)
		oldUpdateServerData(...)
		self.season_description.text:SetString( TheDictionary.GetTranslation(self.season_description.text.string) )
	end
	
	self.title:SetString(TheDictionary.GetTranslation(self.title.string))
end)

--------------------------------------------------------------------------------------------
--// Main Menu News
--------------------------------------------------------------------------------------------
AddClassPostConstruct("motdmanager", function(self)
	local oldGetMotd = self.GetMotd
	self.GetMotd = function(self)
		local info, keys = oldGetMotd(self)

		for _, item in pairs(info) do
			item.data.title = TheDictionary.GetTranslation(item.data.title)
			item.data.text = TheDictionary.GetTranslation(item.data.text)
		end

		return TheDictionary.GetTranslation(info), keys
	end
end)

--------------------------------------------------------------------------------------------
--// Playstyle Picker & World Presets
--------------------------------------------------------------------------------------------
local Levels = require("map/levels")
for _, playstyle in ipairs(Levels.GetPlaystyles()) do
	local defs = Levels.GetPlaystyleDef(playstyle)
	if defs then
		defs.name = TheDictionary.GetTranslation(defs.name)
		defs.desc = TheDictionary.GetTranslation(defs.desc)
	end
end


local oldGetDataForSettingsID = Levels.GetDataForSettingsID
Levels.GetDataForSettingsID = function(level_id, ...)
	local data = oldGetDataForSettingsID(level_id, ...)
	
	if not level_id:find("CUSTOM_") then
		data.name = TheDictionary.GetTranslation(data.name)
		data.desc = TheDictionary.GetTranslation(data.desc)
		
		data.settings_name = TheDictionary.GetTranslation(data.settings_name)
		data.settings_desc = TheDictionary.GetTranslation(data.settings_desc)
	end

	return data
end

local oldGetNameForID = Levels.GetNameForID
Levels.GetNameForID = function(...)
	return TheDictionary.GetTranslation( oldGetNameForID(...)) 
end

local oldGetDescForID = Levels.GetDescForID
Levels.GetDescForID = function(...)	
	return TheDictionary.GetTranslation( oldGetDescForID(...) )
end

local oldGetList = Levels.GetList
Levels.GetList = function(...)	
	local ret = oldGetList(...)
	
	for k, v in pairs(ret) do
		if not v.data:find("CUSTOM_") then
			v.text = TheDictionary.GetTranslation(v.text)
		end
	end

	return ret
end

--------------------------------------------------------------------------------------------
--// Cave Picker
--------------------------------------------------------------------------------------------
local CAVESTRING = STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[string.upper(GLOBAL.SERVER_LEVEL_LOCATIONS[2])]
AddClassPostConstruct("screens/redux/caveselectscreen", function(self)
	for _, child in pairs(self.style_grid.children) do
		for id, widget in pairs(child.children) do
			if id.name == "style_caves" then
				widget.button:SetText(GLOBAL.subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_NAME_CAVE, {server=CAVESTRING}))
				widget.settings_desc = GLOBAL.subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_DESC_CAVE,{server=CAVESTRING})
			elseif id.name == "style_nocaves" then
				widget.button:SetText(GLOBAL.subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_NAME_NOCAVE, {server=CAVESTRING}))
				widget.settings_desc = GLOBAL.subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_DESC_NOCAVE,{server=CAVESTRING})
			end
		end
	end
	
	self.headertext:SetString(GLOBAL.subfmt(STRINGS.UI.SERVERCREATIONSCREEN.USECAVES_TITLE,{server=CAVESTRING}))
end)

--------------------------------------------------------------------------------------------
--// Server Creation/Details
--------------------------------------------------------------------------------------------
local Customize = require("map/customize")
Customize.ITEM_EXPORTS.grouplabel = function(item)
	return TheDictionary.GetTranslation(item.group.text)
end

Customize.ITEM_EXPORTS.options = function(item, location)
	local options = GLOBAL.FunctionOrValue(item.desc or item.group.desc, location)
	for _, option in ipairs(options) do
		if option.text ~= "Together" then
			option.text = TheDictionary.GetTranslation(option.text)
		end
	end
	
	return options
end

AddClassPostConstruct("widgets/redux/serversettingstab", function(self)
	for _, option in ipairs(self.privacy_type.buttons.options) do
		option.text = TheDictionary.GetTranslation(option.text)
	end
end)

--[[ WIP
--// Translate mods enabled through server creation.
--// This is for mods that have "modservercreationmain" and "modworldgenmain" files.
local ModManager = GLOBAL.ModManager
local oldFrontendLoadMod = ModManager.FrontendLoadMod
local function FrontendLoadMod(self, modname)
    oldFrontendLoadMod(self, modname)

	local mod_data = GLOBAL.HB_PTBR.MOD_DEFS[modname]
	
	print(mod_data)
	if mod_data ~= nil then
		AddTranslation(mod_data)
	end
end

ModManager.FrontendLoadMod = FrontendLoadMod --// From "mods.lua"]]

--------------------------------------------------------------------------------------------
--// Options Menu
--------------------------------------------------------------------------------------------
AddClassPostConstruct("screens/redux/optionsscreen", function(self)
	for k, v in pairs(self) do
		if type(v) == "table" and v.name == "SPINNER" then
			for _, option in pairs(v.options) do
				option.text = TheDictionary.GetTranslation(option.text)
			end
			
			if v.options[v.selectedIndex] ~= nil then
				v:UpdateText(v.options[v.selectedIndex].text)
			end
		end
	end
end)

--------------------------------------------------------------------------------------------
--// Cookbook
--------------------------------------------------------------------------------------------
local function DoFoodSideEffectTranslation(food_table)
	for _, food in pairs(food_table) do
		if food.oneat_desc ~= nil then
			food.oneat_desc = TheDictionary.GetTranslation(food.oneat_desc)
		end
	end
end

local PREPAREDFOODS_FILES = { require("preparedfoods"), require("preparednonfoods"), require("preparedfoods_warly") }
for i, v in ipairs(PREPAREDFOODS_FILES) do
	DoFoodSideEffectTranslation(v)
end

--------------------------------------------------------------------------------------------
--// Skill Trees
--------------------------------------------------------------------------------------------
local function DoTreeTranslation(tree)
	for _, def in pairs(tree) do
		if def ~= nil then
			if def.title ~= nil then
				def.title = TheDictionary.GetTranslation(def.title)
				
			end
			
			if def.desc ~= nil then
				def.desc = TheDictionary.GetTranslation(def.desc)
			end
		end
	end
end

local skills = require("prefabs/skilltree_defs")
local characters = GLOBAL.DST_CHARACTERLIST
for i, chr in ipairs(characters) do
	local tree = skills.SKILLTREE_DEFS[chr]
	if tree ~= nil then
		DoTreeTranslation(tree)
	end
end