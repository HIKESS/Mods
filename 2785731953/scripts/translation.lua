--------------------------------------------------------------------------------------------

local PT_BR = { namespace = PTBR_LANGUAGE, po_file = MODROOT.."scripts/translation/pt_br.po", gender_list = require("translation/gender_list") }

--------------------------------------------------------------------------------------------

local function HasNamesKey(path)
	for i = 1, #path do
		if path[i] == "NAMES" then
			return true
		end
	end
	
	return false
end

local function MergePOFile(filepath, id)
	LoadPOFile(GLOBAL.resolvefilepath(filepath), id)
	
	local strings = GLOBAL.LanguageTranslator.languages[id]
	for k, str_translated in pairs(strings) do
		local path = {}
		
		--// Case for when a string id has a number. E.g.: "STRINGS.MY_STRING.1"
		for p in k:gmatch("([^.]+)") do
			if p ~= "STRINGS" then
				table.insert(path, GLOBAL.tonumber(p) or p)
			end
		end

		local node = STRINGS --// String table used to create/find the string from the translator id.
		local dict_untranslated = TheDictionary.og_strings --// Empty string table that gets popullated with untranslated strings.
		for i = 1, #path - 1 do
			local key = path[i]
			
			if dict_untranslated[key] == nil then
				dict_untranslated[key] = {}
			end
			
			if node[key] == nil then
				node[key] = {}
			elseif type(node[key]) == "string" then
				--// Already found the string, so stop here.
				break
			end
			
			node = node[key]
			dict_untranslated = dict_untranslated[key]
		end

		local str_original = node[path[#path]] --// Obtain the original value in this variable before it gets replaced.
		if str_original ~= nil then
			if type(dict_untranslated) == "table" then
				dict_untranslated[path[#path]] = node[path[#path]]
			end
			
			if HasNamesKey(path) then
				TheDictionary.AddNameUntranslation(str_original, str_translated)
			end
			
			TheDictionary.AddTranslation(str_original, str_translated)
		end
		
		node[path[#path]] = str_translated
	end
	
	GLOBAL.LanguageTranslator.languages[id] = nil --// Empty the translator language table to save memory? I dunno.
	
	print("Translation Merging: Merged translation '"..id.."' successfully.")
end

--------------------------------------------------------------------------------------------

function AddTranslation(defs)
	local namespace = defs.namespace
	
	if not namespace then
		DevDebugMessage("Add Translation: Translation namespace not defined.")
		return
	end
	
	if defs.po_file then
		MergePOFile(defs.po_file, namespace)
	end
	
	if defs.main_file then
		modimport(defs.main_file)
	end

	if defs.gender_list then
		if CONFIG.DEVMODE then
			Genderer.ImportNamespaceFiles(namespace)
		else
			Genderer.LoadList(namespace, defs.gender_list)
		end
	end
	
	print("Translation: Added '"..namespace.."' translation successfully.")
end

AddTranslation(PT_BR)

--HB_PTBR.AddTranslation = AddTranslation