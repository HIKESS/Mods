--------------------------------------------------------------------------------------------

local STRINGS = GLOBAL.STRINGS

--------------------------------------------------------------------------------------------

local function IsPlayerNamed(inst)
	return inst.replica.named ~= nil and inst.replica.named._author_netid:value() ~= ""
end

local function GetOriginalName(name)
	return TheDictionary.GetNameUntranslation(name)
end

local function ShouldUntranslate(inst)
	return inst:HasTag("epic") and CONFIG.NAME_TRANSLATIONS.UNTRANSLATE_BOSSES
		   or not inst:HasTag("epic") and CONFIG.NAME_TRANSLATIONS.UNTRANSLATE_NOTBOSSES
end

--------------------------------------------------------------------------------------------

local function GetFormattedNameParts(name, prefab)
	if not table.contains(TheDictionary.NAMES.FORMATTED_PREFABS, prefab) then
		return nil, nil
	end
	
	local is_client = GLOBAL.TheNet:GetIsClient()
	
	local OG_STRINGS = TheDictionary.og_strings
	local item_name = is_client and (OG_STRINGS.NAMES[prefab:upper().."_SCRAPBOOK"] or OG_STRINGS.NAMES[prefab:upper()])
					  or (STRINGS.NAMES[prefab:upper().."_SCRAPBOOK"] or STRINGS.NAMES[prefab:upper()])
	local complement_name

	if item_name then
		local s, e = name:find(item_name, nil, true)
		if s and e then
			local complement = not is_client and name:sub(e + 1):gsub(TheDictionary.NAMES.OF, "", 1)
				
			if not complement or complement == "" then
				complement = name:sub(1, s - 2)				
			end
		
			if complement ~= "" and (GetPlayerWithName(complement) or item_name ~= complement) then
				complement_name = complement
			end
		end
	end
	
	return item_name, complement_name
end

function GetUntranslatedName(inst)
	local display_name = inst:GetBasicDisplayName()
	local item_name, complement_name = GetFormattedNameParts(display_name, inst.prefab)
	
	if not item_name then
		item_name = GetOriginalName(display_name) or display_name
	elseif complement_name then
		if GetPlayerWithName(complement_name) then
			complement_name = complement_name.."'s"
		else
			complement_name = TheDictionary.GetNameUntranslation(complement_name) or complement_name
		end
	
		item_name = complement_name.." "..TheDictionary.GetNameUntranslation(item_name)
	end

	if item_name then
		return item_name
	end
	
	return "???"
end

function GetFormattedNameTranslation(name, prefab)
	local item_name, complement_name = GetFormattedNameParts(name, prefab)
		
	if item_name and complement_name then
		item_name = TheDictionary.GetTranslation(item_name)
	
		if prefab == "wendy_resurrectiongrave" then
			complement_name = complement_name:gsub("'s", "")
		else
			complement_name = TheDictionary.GetTranslation(complement_name)
		end
		
		return item_name..TheDictionary.NAMES.OF..complement_name
	end
	
	return nil
end

--------------------------------------------------------------------------------------------
--// Setup Overrides
--------------------------------------------------------------------------------------------

local function ConstructAdjectivedName(inst, name, adjective)
	return name.." "..adjective
end

local oldGetBasicDisplayName = GLOBAL.EntityScript.GetBasicDisplayName
local function GetBasicDisplayName(self)
	local name = oldGetBasicDisplayName(self)
	
	if IsPlayerNamed(self) then
		return name
	end
	
	if ShouldUntranslate(self) then
		return GetUntranslatedName(name)
	end
	
	local formatted_name = GetFormattedNameTranslation(name, self.prefab)
	if formatted_name then
		return formatted_name
	end
	
	return TheDictionary.GetTranslation(name)
end

local oldGetDisplayName = GLOBAL.EntityScript.GetDisplayName
local function GetDisplayName(self)
	local name = oldGetDisplayName(self)
	
	if self.prefab ~= nil and self.prefab:find("wetgoop") and self:GetIsWet() then
		name = name:gsub("Molhada", "Muito Molhada")
	end

	return Genderer.SubGender(name, Genderer.GetGender(self))
end

GLOBAL.ConstructAdjectivedName = ConstructAdjectivedName      -- // From "dlcsupport_strings.lua"
GLOBAL.EntityScript.GetBasicDisplayName = GetBasicDisplayName -- // From "entityscript.lua"
GLOBAL.EntityScript.GetDisplayName = GetDisplayName 		     -- // From "entityscript.lua"

--// Remove Wetgoop's wet prefixes so my own can have an effect.
AddPrefabPostInitAny(function(inst)
	if inst.prefab:find("wetgoop") then
		inst.wet_prefix = nil
		inst.no_wet_prefix = true
	end
end)

--------------------------------------------------------------------------------------------
--// Handlers for UI adjectives. E.g.: Stale, Spoiled, Hungry, Starving, Melting, Waxed...
--------------------------------------------------------------------------------------------

local function GetNameExtension(inst)
	local extension = ""

	local old_name = ""
	if CONFIG.NAME_TRANSLATIONS.OLD_NAMES and not IsPlayerNamed(inst) then
		local name = GetUntranslatedName(inst)
		if name ~= inst:GetBasicDisplayName() then
			old_name = "("..name..")"
		end
	end
	
	local dev_extension = ""
	if CONFIG.DEVMODE then
		local gender, namespace = Genderer.GetGender(inst)
		dev_extension = "["..(GENDERS[gender] or "NO_GENDER")..(namespace and ":"..namespace or "").."]"
	end
	
	if CONFIG.NAME_TRANSLATIONS.OLD_NAMES_LINEBREAK then
		dev_extension = #dev_extension > 0 and " "..dev_extension or dev_extension
		old_name = #old_name > 0 and "\n"..old_name or old_name
	
		extension = dev_extension..old_name
	else
		dev_extension = #dev_extension > 0 and " "..dev_extension or dev_extension
		old_name = #old_name > 0 and " "..old_name or old_name
	
		extension = old_name..dev_extension
	end
	
	return extension
end

--------------------------------------------------------------------------------------------

local function GetHovererTranslation(self, str)
	if str == nil then
		return ""
	end

	local lmb = self.owner ~= nil and self.owner.components.playercontroller ~= nil and self.owner.components.playercontroller:GetLeftMouseAction()
	local target = lmb and not lmb.invobject and lmb.target
	
	if target and not ShouldUntranslate(target) then
		local gender = Genderer.GetGender(target)
		local name = target:GetDisplayName()
		local name_start, name_end = str:find(name, nil, true)
		if name_start and name_end then
			local adjective = ""
			local others = ""
			local action = lmb:GetActionString()
			local extension = GetNameExtension(target)

			local _, act_end = str:find(action, nil, true)
			if act_end and name_start - act_end > 2 then
				adjective = " "..str:sub(act_end + 2, name_start - 2)
			end
			
			others = str:sub(name_end + 1)
			
			return Genderer.SubGender(action.." "..name..adjective..others..extension, gender)
		end
		
		return Genderer.SubGender(str, gender)
	end
	
	return str
end

AddClassPostConstruct("widgets/hoverer", function(self)
	local oldOnUpdate = self.OnUpdate
	function self:OnUpdate()
		oldOnUpdate(self)
		local str = GetHovererTranslation(self, self.str)
		if str ~= nil then
			self.text:SetString(str)
			self.str = str
		end
	end
end)

--------------------------------------------------------------------------------------------

local function GetItemTileTranslation(self, str)
	if str == nil then
		return ""
	end

	local target = self.item
	if target and not ShouldUntranslate(target) then
		local name = target:GetDisplayName()
		local adjective = ""
		local commands = ""
		local extension = GetNameExtension(target)
		
		local name_start, name_end = str:find(name, nil, true, nil, true)
		if name_start and name_end then
			if name_start > 2 then
				adjective = " "..str:sub(1, name_start - 2)
			end
		
			commands = str:sub(name_end + 1)
		end
		
		return Genderer.SubGender(name..adjective..extension..commands, Genderer.GetGender(target))
	end
	
	return str
end

AddClassPostConstruct("widgets/itemtile", function(self)
	local oldGetDescriptionString = self.GetDescriptionString
	function self:GetDescriptionString()
		return GetItemTileTranslation(self, oldGetDescriptionString(self))
	end
end)
