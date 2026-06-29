--------------------------------------------------------------------------------------------

local io = GLOBAL.io
local FILE_ROOT = "unsafedata/"
local FILE_PREFIX = FILE_ROOT.."ptbr_"

--[[
	NOTES FOR OTHER MODDERS
	
	TBA?...
]]

GENDERS =
{
	"masculine_s",
	"feminine_s",
	"masculine_p",
	"feminine_p"
}

local GENDERER = {
	selected_namespace = PTBR_LANGUAGE,
	loaded_lists = {},
}

--------------------------------------------------------------------------------------------

local function AutoGerenateVariantGenders()
	--// Copy gender options for alternate versions of the same item automatically.
	for prefab, _ in pairs(require("spicedfoods")) do
		local s, e = prefab:find("_spice_")
		
		local base_prefab = prefab:sub(1, s - 1)
		local base_gender, namespace = GENDERER.GetPrefabGender(base_prefab)
		if base_gender ~= 0 then
			GENDERER.AddPrefabToGender(prefab, base_gender, namespace)
		end
	end

	for crop_name, defs in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do	
		local crop_gender, namespace = GENDERER.GetPrefabGender(crop_name)
		if crop_gender ~= 0 then
			local oversized_prefab = crop_name.."_oversized"
			GENDERER.AddPrefabToGender(oversized_prefab, crop_gender, namespace)
			GENDERER.AddPrefabToGender(oversized_prefab.."_rotten", crop_gender, namespace)
			GENDERER.AddPrefabToGender(oversized_prefab.."_waxed", crop_gender, namespace)
			
			local seed_name = defs.seed
			local planted_name = GLOBAL.subfmt(STRINGS.NAMES.FARM_PLANT_SEED, {seed = STRINGS.NAMES[seed_name:upper()]})
			local planted_name_known = GLOBAL.subfmt(STRINGS.NAMES.FARM_PLANT_SEED, {seed = STRINGS.NAMES["KNOWN_"..seed_name:upper()]})
			GENDERER.AddNameToGender(planted_name, 4, namespace)
			GENDERER.AddNameToGender(planted_name_known, 4, namespace)
		end

		local plant_prefab = "farm_plant_"..crop_name
		local plant_gender, namespace = GENDERER.GetPrefabGender(plant_prefab)
		if plant_gender ~= 0 then
			GENDERER.AddPrefabToGender(plant_prefab.."_waxed", plant_gender, namespace)
		end
	end

	for prefab, _ in pairs(require("prefabs/weed_defs").WEED_DEFS) do
		local weed_gender, namespace = GENDERER.GetPrefabGender(prefab)
		if weed_gender ~= 0 then
			GENDERER.AddPrefabToGender(prefab.."_waxed", weed_gender, namespace)
		end
	end

	for prefab, _ in pairs(require("prefabs/ancienttree_defs").TREE_DEFS) do
		local tree_prefab = "ancienttree_"..prefab
		local tree_gender, namespace = GENDERER.GetPrefabGender(tree_prefab)
		if tree_gender ~= 0 then
			GENDERER.AddPrefabToGender(tree_prefab.."_waxed", tree_gender, namespace)
		end
		
		local sapling_prefab = tree_prefab.."_sapling"
		local sapling_gender, namespace = GENDERER.GetPrefabGender(sapling_prefab)
		if sapling_gender ~= 0 then
			GENDERER.AddPrefabToGender(sapling_prefab.."_waxed", sapling_gender, namespace)
		end
	end
end

--------------------------------------------------------------------------------------------

local function GetListFromFile(filename)
	local list = {}
	local file = io.open(FILE_PREFIX..filename..".txt")
	
	local rawstring = file and file:read()
	if rawstring then
		for prefab in rawstring:gmatch("([^~]+)") do
			table.insert(list, prefab)
		end
		file:close()
	end
	
	return list
end

function GENDERER.SetSelectedNamespace(namespace)
	if GENDERER.loaded_lists[namespace] == nil then
		DevDebugMessage("Selected namespace does not exist. Keeping '"..GENDERER.selected_namespace.."'.")
		return
	end

	GENDERER.selected_namespace = namespace

	DevDebugMessage("Current namespace: "..namespace)
end

--------------------------------------------------------------------------------------------

function GENDERER.GetPrefabGender(prefab)
	for namespace, list in pairs(GENDERER.loaded_lists) do
		local gender = list.prefabs[prefab]
		if gender then
			return gender, namespace
		end
	end
	
	return nil, nil
end

function GENDERER.GetNameGender(name)
	for namespace, list in pairs(GENDERER.loaded_lists) do
		local gender = list.names[name]
		if gender then
			return gender, namespace
		end
	end
	
	return nil, nil
end

function GENDERER.GetGender(entity)
	local gender, namespace = GENDERER.GetNameGender(entity:GetBasicDisplayName()) or GENDERER.GetPrefabGender(entity.prefab)
	
	return gender or 0, namespace
end

--------------------------------------------------------------------------------------------

function GENDERER.SubGender(str, gender)
	if str == nil then
		return ""
	end

	-- Defensive: if str is not a string (e.g., a table speech structure
	-- like {default="...", emote="..."} passed by BattleCry via
	-- talker:Say), return it unchanged. Without this guard, str:find()
	-- crashes with "attempt to call method 'find' (a nil value)" because
	-- tables do not have a :find() method. See crash report at
	-- gender.lua:149 when Wagstaff attacks a Bunnyman with a cane:
	-- Combat:BattleCry passes a table speech to talker:Say, which the
	-- speech.lua translator hook forwards to SubGender.
	if type(str) ~= "string" then
		return str
	end

	if not str:find("G|") then
		return str
	end
	
	gender = gender and gender >= 0 and gender or 0
	
	local ret = ""
	local word_sets = str:split("{}")
	for i, set in ipairs(word_sets) do
		if not set:find("G|") then
			ret = ret..set
		else
			local items = set:sub(3):split(",")
			local word = items[gender + 1] or items[1]
			ret = ret..word:sub(2)
		end
	end

	return ret
end

--------------------------------------------------------------------------------------------

function GENDERER.LoadList(namespace, tab)
	GENDERER.loaded_lists[namespace] = tab
end

function GENDERER.ImportNamespaceFiles(namespace)
	local prefabs = {}
	local names = {}
	
	for i = 1, #GENDERS do
		local gender = GENDERS[i]
	
		for _, prefab in pairs(GetListFromFile(namespace.."_"..gender.."_prefabs")) do
			prefabs[prefab] = i
		end
		
		for _, name in pairs(GetListFromFile(namespace.."_"..gender.."_names")) do
			names[name] = i
		end
	end

	GENDERER.loaded_lists[namespace] = {
		prefabs = prefabs,
		names = names,
	}
end

function GENDERER.ExportNamespaceFiles(namespace)
	--// TODO: Maybe condense all genders into one file in different lines?
	--   That'd certainly make the folder less of an eyesore when I eventually have too many namespaces.

	local namespace_list = GENDERER.loaded_lists[namespace]
	if not namespace_list then
		print("Attempted to export namespace '"..namespace.."', but it doesn't exist.")
		return
	end
	
	for i = 1, #GENDERS do
		for type, tab in pairs(namespace_list) do
			local file = io.open(FILE_PREFIX..namespace.."_"..GENDERS[i].."_"..type..".txt", "w")
			if file then
				local filtered_tab = {}
				
				--// Pick all items in our list that match the id.
				for prefab, id in pairs(tab) do
					if id == i then
						table.insert(filtered_tab, prefab)
					end
				end
				
				table.sort(filtered_tab)
				
				--// Place all filtered items in a separate list.
				for i, prefab in ipairs(filtered_tab) do
					file:write(prefab.."~")
				end		
				
				file:close()
			end
		end
	end
end

--------------------------------------------------------------------------------------------

function GENDERER.RemoveFromNamespace(thing, namespace, type)
	if not type then
		print("Failed to remove from namespace: no type given.")
		return
	end
	
	namespace = namespace or GENDERER.selected_namespace	
	local namespace_list = GENDERER.loaded_lists[namespace]
	if not namespace_list then
		print("Attempted to remove '"..thing.."' from namespace '"..namespace.."', but it doesn't exist.")
		return
	end
	
	namespace_list = namespace_list[type]
	if not namespace_list then
		print("'"..type.."' does not exist as a key in '"..namespace.."' namespace.")
		return
	end
	
	if namespace_list[thing] ~= nil then
		namespace_list[thing] = nil
		GENDERER.ExportNamespaceFiles(namespace)
		
		DevDebugMessage("Removed '"..thing.."' from '"..namespace.."'.")
	end
end

function GENDERER.RemoveFromAllNamespaces(prefab, type)
	for namespace, _ in pairs(GENDERER.loaded_lists) do
		GENDERER.RemoveFromNamespace(prefab, namespace, type)
		GENDERER.ExportNamespaceFiles(namespace)
	end
end

--------------------------------------------------------------------------------------------

function GENDERER.AddToGender(id, gender, namespace, type)
	if not type then
		print("Failed to remove from namespace: no type given.")
		return
	end
	
	namespace = namespace or GENDERER.selected_namespace	
	local namespace_list = GENDERER.loaded_lists[namespace]
	if not namespace_list then
		print("Attempted to remove '"..id.."' from namespace '"..namespace.."', but it doesn't exist.")
		return
	end
	
	namespace_list = namespace_list[type]
	if not namespace_list then
		print("'"..type.."' does not exist as a key in '"..namespace.."' namespace.")
		return
	end
	
	if namespace_list[id] ~= gender then
		GENDERER.RemoveFromAllNamespaces(thing, type)
		
		namespace_list[id] = gender
		GENDERER.ExportNamespaceFiles(namespace)
		
		DevDebugMessage("Added '"..id.."' to '"..namespace.."' as a "..GENDERS[gender].." noun.")
	end
end

function GENDERER.AddPrefabToGender(prefab, gender, namespace)
	GENDERER.AddToGender(prefab, gender, namespace, "prefabs")
end

function GENDERER.AddNameToGender(name, gender, namespace)
	GENDERER.AddToGender(name, gender, namespace, "names")
end

--------------------------------------------------------------------------------------------

Genderer = GENDERER

--------------------------------------------------------------------------------------------
--// DEVELOPER MODE
--------------------------------------------------------------------------------------------

if not CONFIG.DEVMODE then
	return
end

local TheInput = GLOBAL.TheInput

local WARNING_MESSAGE = "A {name} ({prefab}) nearby has not been given a gender yet!"
local WARNING_CANT_TAGS = { "NOCLICK", "FX", "DECOR" }
local warning_task = nil
local warnings = {}
local gendering_enabled = false

local function OnWarningTick()
	local player = GLOBAL.ThePlayer
	if player == nil then
		return
	end
	
	for k, v in pairs(warnings) do
		warnings[k] = math.max(v - 1, 0)
	end
	
	local x, y, z = player.Transform:GetWorldPosition()
	local ents = GLOBAL.TheSim:FindEntities(x, y, z, 12, nil, WARNING_CANT_TAGS)
	for i, v in ipairs(ents) do
		if v.prefab ~= nil then
			local name = v:GetBasicDisplayName()
		
			if #name > 0 and name ~= "MISSING NAME"	--// Only check for things that actually have displayed names.
			and (warnings[v.prefab] == nil or warnings[v.prefab] <= 0)
			and GENDERER.GetGender(v) == 0 then
				local message = GLOBAL.subfmt(WARNING_MESSAGE, { name = v:GetBasicDisplayName(), prefab = v.prefab })
				DevDebugMessage(message)
			
				warnings[v.prefab] = 30
			end
		end
	end
end

function ToggleGenderlessWarning(enabled)
	if enabled and warning == nil then
		warning_task = GLOBAL.scheduler:ExecutePeriodic(1, OnWarningTick)
	elseif enabled == false and warning_task ~= nil then
		warning_task:Cancel()
		warning_task = nil
	end
end

--------------------------------------------------------------------------------------------

local function SetPrefabGender(prefab, gender)
	if not gendering_enabled then
		DevDebugMessage("Gendering is disabled. Please enabled it to alter genders.")		
	elseif GLOBAL.Prefabs[prefab] then
		GENDERER.AddPrefabToGender(prefab, gender)
		AutoGerenateVariantGenders()
	else
		DevDebugMessage("\""..prefab.."\" is not a valid prefab.")
	end
end

local function SetNameGender(name, gender)
	if not gendering_enabled then
		DevDebugMessage("Gendering is disabled. Please enabled it to alter genders.")		
	else
		GENDERER.AddNameToGender(name, gender)
	end
end

local function SetHoveredEntityGender(gender)
	local target = TheInput:GetWorldEntityUnderMouse()
	if target ~= nil then
		local prefab = target.prefab
		local name = target:GetBasicDisplayName()
	
		if GLOBAL.TheSim:IsKeyDown(401) and name ~= nil then
			SetNameGender(name, gender)
		elseif target.prefab ~= nil then
			SetPrefabGender(prefab, gender)
		end
	end
end

-- Add to gender keys. (1-4, top row)
TheInput:AddKeyUpHandler(49, function() SetHoveredEntityGender(1) end)
TheInput:AddKeyUpHandler(50, function() SetHoveredEntityGender(2) end)
TheInput:AddKeyUpHandler(51, function() SetHoveredEntityGender(3) end)
TheInput:AddKeyUpHandler(52, function() SetHoveredEntityGender(4) end)

--------------------------------------------------------------------------------------------

-- Toggle gendering. (F10)
TheInput:AddKeyUpHandler(291, function()
	gendering_enabled = not gendering_enabled
	ToggleGenderlessWarning(gendering_enabled)
	DevDebugMessage("Gendering keys "..(gendering_enabled and "enabled" or "disabled")..". Current namespace: "..GENDERER.selected_namespace)
end)

--------------------------------------------------------------------------------------------

GLOBAL.GENDERER = Genderer

--------------------------------------------------------------------------------------------

function GLOBAL.c_addprefabtogender(prefab, gender)
	SetPrefabGender(prefab, gender)
end

function GLOBAL.c_addnametogender(name, gender)
	SetNameGender(name, gender)
end

function GLOBAL.c_settranslationnamespace(namespace)
	GENDERER.SetSelectedNamespace(namespace)
end

function GLOBAL.c_compilegenderlists()		
	for namespace, _ in pairs(GENDERER.loaded_lists) do
		local prefabs_list = {}
		local names_list = {}
		
		for _, gender in ipairs(GENDERS) do
			prefabs = GetListFromFile(namespace.."_"..gender.."_prefabs")
			names = GetListFromFile(namespace.."_"..gender.."_names")
			
			for _, prefab in ipairs(prefabs) do
				table.insert(prefabs_list, prefab)
			end
			
			for _, name in ipairs(names) do
				table.insert(names_list, name)
			end
		end
		
		table.sort(prefabs_list)
		table.sort(names_list)
		
		local compiled_file = io.open(FILE_PREFIX.."compiled_"..namespace..".txt", "w")
		
		compiled_file:write("local gender_list =\n{\n	prefabs =\n	{\n")
		for i, prefab in ipairs(prefabs_list) do
			compiled_file:write("		"..prefab.." = "..GENDERER.loaded_lists[namespace].prefabs[prefab]..","..(i < #prefabs_list and "\n" or ""))
		end
		
		compiled_file:write("\n	},\n\n	names =\n	{\n")
		for i, name in ipairs(names_list) do
			compiled_file:write("		[\""..name.."\"] = "..GENDERER.loaded_lists[namespace].names[name]..","..(i < #names_list and "\n" or ""))
		end
		
		compiled_file:write("\n	},\n}\n\nreturn gender_list")
		compiled_file:close()
		
		print("File for '"..namespace.."' namespace compiled successfully.")
	end
end