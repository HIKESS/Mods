Assets =
{
	Asset( "IMAGE", "images/names_gold_br_wonkey.tex" ),
	Asset( "ATLAS", "images/names_gold_br_wonkey.xml" ),

	Asset( "IMAGE", "images/names_gold_br_random.tex" ),
	Asset( "ATLAS", "images/names_gold_br_random.xml" ),
}

CONFIG =
{
	DEVMODE = false,--GLOBAL.KnownModIndex:IsModEnabled("traducao_cliente"), --// Toggles DEVMODE when I enable 'traducao_cliente". In this case, that would be this mod with its unpublished id.

	ANNOUNCE   = GetModConfigData("TOGGLE_ANNOUNCEMENTS"),
	--COOKBOOK   = GetModConfigData("TOGGLE_COOKBOOK"),	// deprecated
	NAMED 	   = GetModConfigData("TOGGLE_NAMED"),
	SCREENS    = GetModConfigData("TOGGLE_SCREENS"),
	SPEECH 	   = GetModConfigData("TOGGLE_SPEECH"),
	--SKILLTREES = GetModConfigData("TOGGLE_SKILLTREES"), // deprecated
	
	MODS_ENABLED = GetModConfigData("SWITCH_TRANSLATEMODS"),
	MODS = {},
	
	--PLAYER_GENDER = GetModConfigData("PREFS_PLAYERGENDER"), // Might be a thing, but right now I'd rather just keep game text directed at the player gender neutral.
	
	NAME_TRANSLATIONS =
	{
		UNTRANSLATE_NOTBOSSES = GetModConfigData("TOGGLE_NOTBOSSES"),
		UNTRANSLATE_BOSSES    = GetModConfigData("TOGGLE_BOSSES"),
		
		BLUEPRINTS = GetModConfigData("TOGGLE_BLUEPRINTS"),
	
		OLD_NAMES 			= GetModConfigData("TOGGLE_ORIGINAL"),
		OLD_NAMES_LINEBREAK = GetModConfigData("PREFS_ORIGINAL_LINEBREAK"),
	},
}

--[[GLOBAL.HB_PTBR =
{
	MOD_DEFS = {}
}

HB_PTBR = GLOBAL.HB_PTBR]]
STRINGS = GLOBAL.STRINGS

PTBR_LANGUAGE = "vanilla"

modimport("scripts/gender.lua")
modimport("scripts/dictionary.lua")
modimport("scripts/util.lua")
modimport("scripts/translation.lua")

-------------------------------------------------------------------------------
--// Execute Enabled Translators
-------------------------------------------------------------------------------
local TRANSLATORS_PATH = "scripts/translators/"
local function LoadTranslator(translator, force_enabled)
	local enabled = force_enabled or CONFIG[translator:upper()]
	
	if enabled then
		modimport(TRANSLATORS_PATH..translator..".lua")
	end
end

modimport(TRANSLATORS_PATH.."names.lua")

LoadTranslator("screens")
LoadTranslator("speech")
LoadTranslator("announce")

if not CONFIG.DEVMODE then
	return
end

GLOBAL.c_toggletranslationdevmode = function()
	CONFIG.DEVMODE = not CONFIG.DEVMODE
	
	if not CONFIG.DEVMODE then
		ToggleGenderlessWarning(false)
	end
	
	DevDebugMessage("Console: Development tools set to \""..tostring(CONFIG.DEVMODE).."\".")
end