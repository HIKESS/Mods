-----------------------------------------------------------------------
--// NOTE: This file is loaded before any translations are imported, meaning that the STRINGS table is fully in the base game
--   language.
--// This mod works best if the game is set to English in the options menu.

local DICTIONARY =
{
	ids = {}, --// Used to retrieve translated name from string ID.

	translations =
	{
		news = require("translation/mainmenunews"),
	
		generic =
		{
			--// The entries here are manual fixes.
			["Cast:"] = "Elenco:",
				
			--// Screen Fixes
			-- ServerListingScreen
			--["Servidores de Survival"]     = "Servidores de Sobrevivência",
			["Servidores de Infinito"]	   = "Servidores Infinitos",
			["Servidores de Descontraído"] = "Servidores Descontraídos",
			["Servidores de Selvageria"]   = "Servidores Selvagens",
			["Servidores de Qualquer"]     = "Qualquer Servidor",
			--["Servidores de Blecaute"] = "Servidores de Blecaute",
			
			-- Not exactly fixes. More so a way to make the strings feel a bit more natural.
			["Fim de Outono"]	    = "Fim do Outono",
			["Início de Outono"]	= "Início do Outono",
			["Fim de Inverno"]	    = "Fim do Inverno",
			["Início de Inverno"]   = "Início do Inverno",
			["Fim de Primavera"]	= "Fim da Primavera",
			["Início de Primavera"] = "Início da Primavera",
			["Fim de Verão"]		= "Fim do Verão",
			["Início de Verão"] 	= "Início do Verão",
			
			-- ServerCreationScreen
			["Long Day"] = "Dia Longo",
			["Long Dusk"] = "Tarde Longa",
			["Long Night"] = "Noite Longa",
			
			["No Day"] = "Sem Dia",
			["No Dusk"] = "Sem Tarde",
			["No Night"] = "Sem Noite",
			
			["Only Day"] = "Somente Dia",
			["Only Dusk"] = "Somente Tarde",
			["Only Night"] = "Somente Noite",
		},
	},
	
	og_strings = {},
	
	name_untranslations = {},
	
	--// Constants
	NAMES =
	{
		OF = " de ",
	
		FORMATTED_PREFABS = --// Names I need to reassemble to translate.
		{
			"blueprint",
			"sketch",
			"tacklesketch",
			"cookingrecipecard",
			"wendy_resurrectiongrave",
			"wx78_backupbody", -- Redundant, but allows the untranslated name to show.
		},
	},
	
	ANNOUNCE = {
		REPLACE = --// Strings matched with and replaced in an announcement string.
		{
			["The Eye of Terror turns its gaze toward "] = "O Olho do Terror olha para ",
			["The Twins turn their gaze toward "] = "Os Gêmeos olham para ",
		},
		
		--// Using vanilla genders here to avoid issues with modded characters.
		REZ_ANNOUNCEMENT =
		{
			DEFAULT = "voltou à vida graças a",
			MALE    = "foi revivido por",
			FEMALE  = "foi revivida por",
			ROBOT   = "foi revivido por",
		},
		
		DEATH_ANNOUNCEMENT_1 =
		{
			DEFAULT = "morreu por",
			MALE 	= "foi morto por",
			FEMALE	= "foi morta por",
			ROBOT	= "foi morto por",
		},
	},
	
	--SCREENS = {},
	
	SPEECH =
	{
		REPLACE =
		{
			["Weight: "] = "Peso: ",
			["Harvested on day: "] = "Colhido no dia: ",
		},
	},
	
	--TRANSLATED_STRINGS = GLOBAL.LanguageTranslator.languages[PTBR_LANGUAGE],
}

-----------------------------------------------------------------------

function DICTIONARY.GetId(str_id)
	return DICTIONARY.ids[str_id] or "UNKNOWN_STRING"
end

function DICTIONARY.AddId(str_id, translated)
	DICTIONARY.ids[str_id] = translated
end

function DICTIONARY.HasId(str_id)
	return DICTIONARY.ids[str_id] ~= nil
end

-----------------------------------------------------------------------

local function MakeTranslation(tab, str1, str2)
	str1 = tostring(str1)
	str2 = tostring(str2)

	local lines_str1 = str1:split("\n")
	local lines_str2 = str2:split("\n")
	
	if #lines_str1 == #lines_str2 then
		for i = 1, #lines_str1 do		
			tab[lines_str1[i]] = lines_str2[i]
		end
	end
	
	tab[str1] = str2
end

function DICTIONARY.GetNameUntranslation(str)
	local tab = DICTIONARY.name_untranslations
	return tab and tab[str]
end

function DICTIONARY.AddNameUntranslation(original, translated)
	MakeTranslation(DICTIONARY.name_untranslations, translated, original)
end

-----------------------------------------------------------------------

function DICTIONARY.HasTranslation(str, type)
	local tab = DICTIONARY.translations[type or "generic"]
	return tab and tab[str] ~= nil
end

function DICTIONARY.GetTranslation(str, type)
	if type then
		local tab = DICTIONARY.translations[type]
		return tab and tab[str] or str or ""
	end
	
	for _, translations in pairs(DICTIONARY.translations) do
		local ret = translations[str]
		if ret ~= nil then
			return ret
		end
	end
	
	return str or ""
end

function DICTIONARY.AddTranslation(original, translated, type)
	local translation = DICTIONARY.translations[type or "generic"]
	MakeTranslation(translation, original, translated)
end

function DICTIONARY.RemoveTranslation(original, type)
	original = tostring(original)

	local lines_og = original:split("\n")
	
	local translation = DICTIONARY.translations[type or "generic"]
	for i = 1, #lines_og do
		translation[lines_og[i]] = nil
	end
	
	translation[original] = nil
end

-----------------------------------------------------------------------

TheDictionary = DICTIONARY
--HB_PTBR.TheDictionary = TheDictionary

if CONFIG.DEVMODE then
	GLOBAL.DICT = TheDictionary
end