-- !!This file is only used by Mods in Menu!!

local _G = GLOBAL
local PREFAB_SKINS = _G.PREFAB_SKINS
local PREFAB_SKINS_IDS = _G.PREFAB_SKINS_IDS
local SKIN_AFFINITY_INFO = GLOBAL.require("skin_affinity_info")

PrefabFiles = {
	"scrap",
	"engineer",
	"engineer_skins",
	"esentry",
	"dispenser",
	"eteleporter",
	"eteleporter_exit",
	"tf2wrench",
	"gibus",
	"ehardhat",
	"esentry_bullet",
	"esentry_rocket",
	"destructionpda",
}

Assets = {
    Asset( "IMAGE", "bigportraits/engineer.tex" ),
    Asset( "ATLAS", "bigportraits/engineer.xml" ),
	Asset( "IMAGE", "bigportraits/engineer_none.tex" ),
    Asset( "ATLAS", "bigportraits/engineer_none.xml" ),
	--Skins
	Asset( "IMAGE", "bigportraits/engineer_blu.tex" ),
    Asset( "ATLAS", "bigportraits/engineer_blu.xml" ),
	Asset( "IMAGE", "bigportraits/engineer_formal.tex" ),
    Asset( "ATLAS", "bigportraits/engineer_formal.xml" ),
	Asset( "IMAGE", "bigportraits/engineer_survivor.tex" ),
    Asset( "ATLAS", "bigportraits/engineer_survivor.xml" ),
	Asset( "IMAGE", "bigportraits/engineer_shadow.tex" ),
    Asset( "ATLAS", "bigportraits/engineer_shadow.xml" ),
	Asset( "IMAGE", "bigportraits/engineer_rose.tex" ),
    Asset( "ATLAS", "bigportraits/engineer_rose.xml" ),
	--
    Asset( "IMAGE", "images/avatars/avatar_engineer.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_engineer.xml" ),
    Asset( "IMAGE", "images/avatars/avatar_ghost_engineer.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_engineer.xml" ),
    Asset( "IMAGE", "images/avatars/self_inspect_engineer.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_engineer.xml" ),
	
    Asset( "IMAGE", "images/names_engineer.tex" ),
    Asset( "ATLAS", "images/names_engineer.xml" ),
	Asset( "IMAGE", "images/names_gold_engineer.tex" ),
    Asset( "ATLAS", "images/names_gold_engineer.xml" ),

	Asset( "IMAGE", "images/saveslot_portraits/engineer.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/engineer.xml" ),
}

modimport("scripts/strings.lua")

--
TUNING.ENGINEER_HEALTH = GetModConfigData("engineer_health")--125
TUNING.ENGINEER_HUNGER = GetModConfigData("engineer_hunger")--150
TUNING.ENGINEER_SANITY = GetModConfigData("engineer_sanity")--200
if GetModConfigData("starting_scrap") == "y" then
	TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.ENGINEER = { "tf2wrench",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap"
	}
elseif GetModConfigData("starting_scrap") == "z" then
		TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.ENGINEER = { "tf2wrench", "destructionpda",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap",
	"scrap"
	}
else
	TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.ENGINEER = { "tf2wrench" }
end

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["tf2wrench"] = 
{
    atlas = "images/engineeritemimages.xml",
    image = "tf2wrench.tex",
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["scrap"] = 
{
    atlas = "images/engineeritemimages.xml",
    image = "scrap.tex",
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["destructionpda"] = 
{
    atlas = "images/engineeritemimages.xml",
    image = "destructionpda.tex",
}
--
--Skins api
modimport("scripts/skins_api")

SKIN_AFFINITY_INFO.engineer = {
	"engineer_blu",
	"engineer_rose",
	"engineer_shadow",
	"engineer_formal",
	"engineer_survivor",
}

PREFAB_SKINS["engineer"] = {
	"engineer_none", 
	"engineer_blu",
	"engineer_rose",
	"engineer_shadow",
	"engineer_formal",
	"engineer_survivor",
}

PREFAB_SKINS_IDS = {}
for prefab,skins in pairs(PREFAB_SKINS) do
    PREFAB_SKINS_IDS[prefab] = {}
    for k,v in pairs(skins) do
      	  PREFAB_SKINS_IDS[prefab][v] = k
    end
end

AddSkinnableCharacter("engineer")
--
--
AddModCharacter("engineer", "MALE")