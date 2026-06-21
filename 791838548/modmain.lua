local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local RECIPETABS = GLOBAL.RECIPETABS
local TimeEvent = GLOBAL.TimeEvent
local FRAMES = GLOBAL.FRAMES
local EventHandler = GLOBAL.EventHandler
local ActionHandler = GLOBAL.ActionHandler
local ACTIONS = GLOBAL.ACTIONS
local State = GLOBAL.State

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
	
	Asset("IMAGE", "images/minimap/esentry.tex"),
    Asset("ATLAS", "images/minimap/esentry.xml"),
	Asset("IMAGE", "images/minimap/esentry_2.tex"),
    Asset("ATLAS", "images/minimap/esentry_2.xml"),
	Asset("IMAGE", "images/minimap/esentry_3.tex"),
    Asset("ATLAS", "images/minimap/esentry_3.xml"),
    Asset("IMAGE", "images/minimap/dispenser.tex"),
    Asset("ATLAS", "images/minimap/dispenser.xml"),
    Asset("IMAGE", "images/minimap/eteleporter.tex"),
    Asset("ATLAS", "images/minimap/eteleporter.xml"),
	Asset("IMAGE", "images/minimap/eteleporterentrance.tex"),
    Asset("ATLAS", "images/minimap/eteleporterentrance.xml"),
	Asset("IMAGE", "images/minimap/eteleporterexit.tex"),
    Asset("ATLAS", "images/minimap/eteleporterexit.xml"),
	Asset( "IMAGE", "images/minimap/engineer.tex" ),
    Asset( "ATLAS", "images/minimap/engineer.xml" ),

    Asset("IMAGE", "images/engineeritemimages.tex"),
    Asset("ATLAS", "images/engineeritemimages.xml"),
    Asset("ATLAS_BUILD", "images/engineeritemimages.xml", 256),

--	Asset("ATLAS", "images/hud/engietab.xml" ),
--	Asset("IMAGE", "images/hud/engietab.tex"),

	Asset( "IMAGE", "images/crafting_menu_avatars/avatar_engineer.tex" ),
    Asset( "ATLAS", "images/crafting_menu_avatars/avatar_engineer.xml" ),

	Asset( "ANIM", "anim/emote_rancho.zip" ),
	Asset( "ANIM", "anim/player_idles_engineer.zip" ),
}

local _G = GLOBAL
local PREFAB_SKINS = _G.PREFAB_SKINS
local PREFAB_SKINS_IDS = _G.PREFAB_SKINS_IDS
local SKIN_AFFINITY_INFO = GLOBAL.require("skin_affinity_info")
GLOBAL.PREFAB_SKINS["engineer"] = {"engineer_none"}
GLOBAL.PREFAB_SKINS_IDS["engineer"] = {["engineer_none"] = 1}

local ITEMS = {
    "scrap",
    "destructionpda",
    "tf2wrench",
    "ehardhat",
    "gibus",
    "esentry_item",
	"esentry",
	"dispenser",
	"eteleporter",
	"eteleporter_exit",
	"buildinglocked",
}
for _, item in ipairs(ITEMS) do
	RegisterInventoryItemAtlas(GLOBAL.resolvefilepath("images/engineeritemimages.xml"), item..".tex")
end
GLOBAL.ENGINEERITEMIMAGES = MODROOT.."images/engineeritemimages.xml"

modimport("scripts/strings.lua")

TUNING.ENGIE_DISPENSERMAX = GetModConfigData("dispenseramount")
TUNING.ENGIE_TELEPORTERMAX = GetModConfigData("teleporteramount")
TUNING.ENGIE_SENTRYMAX = GetModConfigData("sentryamount")

TUNING.ENGIE_BUILDINGMAX = GetModConfigData("buildinglimit")
TUNING.ENGIE_SENTRYLIMIT = GetModConfigData("sentrylimit")
TUNING.ENGIE_DISPENSERLIMIT = GetModConfigData("dispenserlimit")
TUNING.ENGIE_TELEPORTERLIMIT = GetModConfigData("teleporterlimit")

TUNING.ENGIE_DMGDEBUFF = GetModConfigData("engiedmgdebuff")
TUNING.ENGIE_SCIENCEBONUS = GetModConfigData("engiesciencebonus")
TUNING.ENGIE_BUILDINGLOSS = GetModConfigData("Building_SD")
TUNING.TOOLBOX_SPEED_MULT = GetModConfigData("toolbox_penalty")
TUNING.TF2WRENCH_DAMAGE = GetModConfigData("tf2wrenchdmg")
TUNING.TF2WRENCH_USES = GetModConfigData("tf2wrenchuses")
TUNING.ARMOR_HARDHAT_ABSORPTION = GetModConfigData("hardhatabsorb")
TUNING.ARMOR_EHARDHAT = GetModConfigData("ehardhatdura")
TUNING.PDA_AMOUNT = GetModConfigData("pda_ingredientpercent")

TUNING.DISP_RANGE = GetModConfigData("disprange")
TUNING.DISP_HEALING = GetModConfigData("dispenserhealingrate")

GLOBAL.SENTRY_RANGE = GetModConfigData("Sentry_Range")
GLOBAL.SENTRY_DAMAGE = GetModConfigData("Sentry_Damage")
GLOBAL.SENTRY_ROF = GetModConfigData("Sentry_ROF")
GLOBAL.SENTRY_HEALTH = GetModConfigData("Sentry_Health")
GLOBAL.SENTRY_FF = GetModConfigData("sentry_ff")
GLOBAL.SENTRY_FF_WALL = GetModConfigData("sentry_ff_wall")
TUNING.SENTRY_ROCKET_DAMAGE = GetModConfigData("sentry_rocketdamage")
TUNING.SENTRY_WRENCH_HEAL = GetModConfigData("sentry_healinghit")

TUNING.ETELEPORT_PENALTY = GetModConfigData("eteleport_penalty")

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
--    image = "tf2wrench.tex",
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["scrap"] = 
{
    atlas = "images/engineeritemimages.xml",
--    image = "scrap.tex",
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["destructionpda"] = 
{
    atlas = "images/engineeritemimages.xml",
--    image = "destructionpda.tex",
}

TUNING.ENGINEER_HEALTH = GetModConfigData("engineer_health")--125
TUNING.ENGINEER_HUNGER = GetModConfigData("engineer_hunger")--150
TUNING.ENGINEER_SANITY = GetModConfigData("engineer_sanity")--200

if GLOBAL.TheNet:GetServerGameMode() == "lavaarena" then
TUNING.LAVAARENA_STARTING_HEALTH.ENGINEER = GetModConfigData("engineer_health")
TUNING.GAMEMODE_STARTING_ITEMS.LAVAARENA.ENGINEER = { "bacontome", "forge_woodarmor" }
end

-- Recipes ------------------------------
--Scrap
local recipe_difficulty = GetModConfigData("Scrap_Difficulty")
if recipe_difficulty == "default" then
--local scrap = AddRecipe("scrap", {Ingredient("flint", 2), Ingredient("twigs", 2)}, engietab, GLOBAL.TECH.NONE, nil, nil, nil, 5, "engie", "images/inventoryimages/scrap.xml", "scrap.tex")
AddRecipe2("scrap", 				{Ingredient("flint", 2), Ingredient("twigs", 2)},				GLOBAL.TECH.NONE,				{builder_tag="engie", numtogive = 5, atlas = "images/engineeritemimages.xml", image = "scrap.tex"},				{"CHARACTER", "REFINE"})

elseif recipe_difficulty == "easy" then 
AddRecipe2("scrap", 				{Ingredient("flint", 1), Ingredient("twigs", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engie", numtogive = 5, atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "REFINE"})
elseif recipe_difficulty == "easier" then 
AddRecipe2("scrap", 				{Ingredient("flint", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engie", numtogive = 5, atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "REFINE"})
elseif recipe_difficulty == "hard" then 
AddRecipe2("scrap", 				{Ingredient("flint", 3), Ingredient("twigs", 3), Ingredient("goldnugget", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engie", numtogive = 5, atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "REFINE"})
elseif recipe_difficulty == "harder" then 
AddRecipe2("scrap", 				{Ingredient("flint", 4), Ingredient("twigs", 4), Ingredient("transistor", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engie", numtogive = 5, atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "REFINE"})
end

--Hard Hat
local recipe_difficulty = GetModConfigData("EHat_Difficulty")
if recipe_difficulty == "default" then
--local ehardhat = AddRecipe("ehardhat", {Ingredient("scrap", 4, "images/inventoryimages/scrap.xml"), Ingredient("goldnugget", 2)}, engietab, GLOBAL.TECH.NONE, nil, nil, nil, nil, "engie", "images/inventoryimages/ehardhat.xml", "ehardhat.tex")
AddRecipe2("ehardhat", 				{Ingredient("scrap", 5, "images/engineeritemimages.xml"), Ingredient("goldnugget", 2)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "ARMOUR"})

elseif recipe_difficulty == "easy" then 
AddRecipe2("ehardhat", 				{Ingredient("scrap", 1, "images/engineeritemimages.xml"), Ingredient("goldnugget", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "ARMOUR"})
elseif recipe_difficulty == "hard" then 
AddRecipe2("ehardhat", 				{Ingredient("scrap", 6, "images/engineeritemimages.xml"), Ingredient("goldnugget", 3)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "ARMOUR"})
elseif recipe_difficulty == "harder" then 
AddRecipe2("ehardhat", 				{Ingredient("scrap", 10, "images/engineeritemimages.xml"), Ingredient("goldnugget", 4), Ingredient("strawhat", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "ARMOUR"})
end

--Wrench
local recipe_difficulty = GetModConfigData("tf2Wrench_Difficulty")
if recipe_difficulty == "default" then
--local tf2wrench = AddRecipe("tf2wrench", {Ingredient("scrap", 5, "images/inventoryimages/scrap.xml"), Ingredient("twigs", 2), Ingredient("goldnugget", 1)}, engietab, GLOBAL.TECH.NONE, nil, nil, nil, nil, "engie", "images/inventoryimages/tf2wrench.xml", "tf2wrench.tex")
AddRecipe2("tf2wrench", 				{Ingredient("scrap", 5, "images/engineeritemimages.xml"), Ingredient("twigs", 3)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "TOOLS"})

elseif recipe_difficulty == "easy" then 
AddRecipe2("tf2wrench", 				{Ingredient("scrap", 3, "images/engineeritemimages.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "TOOLS"})
elseif recipe_difficulty == "hard" then 
AddRecipe2("tf2wrench", 				{Ingredient("scrap", 10, "images/engineeritemimages.xml"), Ingredient("twigs", 5), Ingredient("goldnugget", 2)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "TOOLS"})
elseif recipe_difficulty == "harder" then 
AddRecipe2("tf2wrench", 				{Ingredient("scrap", 15, "images/engineeritemimages.xml"), Ingredient("twigs", 10), Ingredient("gears", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "TOOLS"})
end

--Sentry
local recipe_difficulty = GetModConfigData("Sentry_Difficulty")
if recipe_difficulty == "default" then
--local esentry_item = AddRecipe("esentry", {Ingredient("scrap", 20, "images/inventoryimages/scrap.xml"), Ingredient("gears", 3)}, engietab, GLOBAL.TECH.SCIENCE_ONE, nil, nil, nil, nil, "engieturret", "images/inventoryimages/esentry.xml", "esentry.tex")
AddRecipe2("esentry", 				{Ingredient("scrap", 20, "images/engineeritemimages.xml"), Ingredient("gears", 3)},				GLOBAL.TECH.SCIENCE_ONE,				{builder_tag="engieturret", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "WEAPONS", "STRUCTURES"})

elseif recipe_difficulty == "hard" then
AddRecipe2("esentry", 				{Ingredient("scrap", 30, "images/engineeritemimages.xml"), Ingredient("gears", 5), Ingredient("transistor",5)},				GLOBAL.TECH.SCIENCE_ONE,				{builder_tag="engieturret", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "WEAPONS", "STRUCTURES"})
elseif recipe_difficulty == "harder" then
AddRecipe2("esentry", 				{Ingredient("scrap", 40, "images/engineeritemimages.xml"), Ingredient("gears", 6), Ingredient("gunpowder",5)},				GLOBAL.TECH.SCIENCE_TWO,				{builder_tag="engieturret", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "WEAPONS", "STRUCTURES"})
elseif recipe_difficulty == "easy" then
AddRecipe2("esentry", 				{Ingredient("scrap", 10, "images/engineeritemimages.xml"), Ingredient("gears", 1)},				GLOBAL.TECH.NONE,				{builder_tag="engieturret", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "WEAPONS", "STRUCTURES"})
end

----------------Dud recipes for locking limits
GLOBAL.STRINGS.NAMES.ESENTRY_DUMMY = "Sentry Gun"
GLOBAL.STRINGS.RECIPE_DESC.ESENTRY_DUMMY = "Too Many Sentries Already Built!"
--local esentry_dummy = AddRecipe("esentry_dummy", {Ingredient("esentry", 0, "images/inventoryimages/esentry.xml")}, engietab, GLOBAL.TECH.SCIENCE_ONE, nil, nil, nil, nil, "engiesentrydummy", "images/inventoryimages/buildinglocked.xml", "buildinglocked.tex")
AddRecipe2("esentry_dummy", 				{Ingredient("esentry", 0, "images/engineeritemimages.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engiesentrydummy", atlas = "images/engineeritemimages.xml", image = "buildinglocked.tex"},				{"CHARACTER"})

--Dispenser
local recipe_difficulty = GetModConfigData("Dispenser_Difficulty")
if recipe_difficulty == "default" then
--local dispenser_item = AddRecipe("dispenser", {Ingredient("scrap", 15, "images/inventoryimages/scrap.xml"), Ingredient("redgem", 3)}, engietab, GLOBAL.TECH.SCIENCE_TWO, nil, nil, nil, nil, "engiedis", "images/inventoryimages/dispenser.xml", "dispenser.tex")
AddRecipe2("dispenser", 				{Ingredient("scrap", 15, "images/engineeritemimages.xml"), Ingredient("redgem", 3)},				GLOBAL.TECH.SCIENCE_TWO,				{builder_tag="engiedis", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "RESTORATION", "STRUCTURES"})

elseif recipe_difficulty == "hard" then
AddRecipe2("dispenser", 				{Ingredient("scrap", 25, "images/engineeritemimages.xml"), Ingredient("redgem", 5), Ingredient("transistor",5)},				GLOBAL.TECH.SCIENCE_TWO,				{builder_tag="engiedis", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "RESTORATION", "STRUCTURES"})
elseif recipe_difficulty == "harder" then
AddRecipe2("dispenser", 				{Ingredient("scrap", 35, "images/engineeritemimages.xml"), Ingredient("redgem", 10), Ingredient("gears",5)},				GLOBAL.TECH.SCIENCE_TWO,				{builder_tag="engiedis", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "RESTORATION", "STRUCTURES"})
elseif recipe_difficulty == "easy" then
AddRecipe2("dispenser", 				{Ingredient("scrap", 10, "images/engineeritemimages.xml"), Ingredient("redgem", 1)},				GLOBAL.TECH.SCIENCE_ONE,				{builder_tag="engiedis", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "RESTORATION", "STRUCTURES"})
end

GLOBAL.STRINGS.NAMES.DISPENSER_DUMMY = "Dispenser"
GLOBAL.STRINGS.RECIPE_DESC.DISPENSER_DUMMY = "Too Many Dispensers Already Built!"
--local dispenser_dummy = AddRecipe("dispenser_dummy", {Ingredient("dispenser", 0, "images/inventoryimages/dispenser.xml")}, engietab, GLOBAL.TECH.SCIENCE_ONE, nil, nil, nil, nil, "engiedispenserdummy", "images/inventoryimages/buildinglocked.xml", "buildinglocked.tex")
AddRecipe2("dispenser_dummy", 				{Ingredient("dispenser", 0, "images/engineeritemimages.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engiedispenserdummy", atlas = "images/engineeritemimages.xml", image = "buildinglocked.tex"},				{"CHARACTER"})

--Teleporter
local recipe_difficulty = GetModConfigData("Teleporter_Difficulty")
if recipe_difficulty == "default" then
--local eteleporter_item = AddRecipe("eteleporter", {Ingredient("scrap", 15, "images/inventoryimages/scrap.xml"), Ingredient("nightmarefuel", 10)}, engietab, GLOBAL.TECH.MAGIC_TWO, nil, nil, nil, nil, "engietelenter", "images/inventoryimages/eteleporter.xml", "eteleporter.tex")
AddRecipe2("eteleporter", 				{Ingredient("scrap", 15, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 10)},				GLOBAL.TECH.MAGIC_TWO,				{builder_tag="engietelenter", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})

elseif recipe_difficulty == "hard" then
AddRecipe2("eteleporter", 				{Ingredient("scrap", 25, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 12), Ingredient("marble",5)},				GLOBAL.TECH.MAGIC_TWO,				{builder_tag="engietelenter", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})
elseif recipe_difficulty == "harder" then
AddRecipe2("eteleporter", 				{Ingredient("scrap", 30, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 15), Ingredient("orangegem",1)},				GLOBAL.TECH.MAGIC_TWO,				{builder_tag="engietelenter", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})
elseif recipe_difficulty == "easy" then
AddRecipe2("eteleporter", 				{Ingredient("scrap", 10, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 5)},				GLOBAL.TECH.SCIENCE_TWO,				{builder_tag="engietelenter", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})
end

--Exit
local recipe_difficulty = GetModConfigData("Teleporter_Difficulty")
if recipe_difficulty == "default" then
--local eteleporter_exit_item = AddRecipe("eteleporter_exit", {Ingredient("scrap", 15, "images/inventoryimages/scrap.xml"), Ingredient("nightmarefuel", 10)}, engietab, GLOBAL.TECH.MAGIC_TWO, nil, nil, nil, nil, "engietelexit", "images/inventoryimages/eteleporter.xml", "eteleporter.tex")
AddRecipe2("eteleporter_exit", 				{Ingredient("scrap", 15, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 10)},				GLOBAL.TECH.MAGIC_TWO,				{builder_tag="engietelexit", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})

elseif recipe_difficulty == "hard" then
AddRecipe2("eteleporter_exit", 				{Ingredient("scrap", 25, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 12), Ingredient("marble",5)},				GLOBAL.TECH.MAGIC_TWO,				{builder_tag="engietelexit", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})
elseif recipe_difficulty == "harder" then
AddRecipe2("eteleporter_exit", 				{Ingredient("scrap", 30, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 15), Ingredient("orangegem",1)},				GLOBAL.TECH.MAGIC_TWO,				{builder_tag="engietelexit", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})
elseif recipe_difficulty == "easy" then
AddRecipe2("eteleporter_exit", 				{Ingredient("scrap", 10, "images/engineeritemimages.xml"), Ingredient("nightmarefuel", 5)},				GLOBAL.TECH.SCIENCE_TWO,				{builder_tag="engietelexit", atlas = "images/engineeritemimages.xml"},				{"CHARACTER", "MAGIC", "STRUCTURES"})
end


GLOBAL.STRINGS.NAMES.ETELEPORTER_DUMMY = "Teleporter Entrance"
GLOBAL.STRINGS.RECIPE_DESC.ETELEPORTER_DUMMY = "Too Many Entrances Already Built!"
--local eteleporter_dummy = AddRecipe("eteleporter_dummy", {Ingredient("eteleporter", 0, "images/inventoryimages/eteleporter.xml")}, engietab, GLOBAL.TECH.SCIENCE_ONE, nil, nil, nil, nil, "engietelenterdummy", "images/inventoryimages/buildinglocked.xml", "buildinglocked.tex")
AddRecipe2("eteleporter_dummy", 				{Ingredient("eteleporter", 0, "images/engineeritemimages.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engietelenterdummy", atlas = "images/engineeritemimages.xml", image = "buildinglocked.tex"},				{"CHARACTER"})

GLOBAL.STRINGS.NAMES.ETELEPORTER_EXIT_DUMMY = "Teleporter Exit"
GLOBAL.STRINGS.RECIPE_DESC.ETELEPORTER_EXIT_DUMMY = "Too Many Exits Already Built!"
--local eteleporter_exit_dummy = AddRecipe("eteleporter_exit_dummy", {Ingredient("eteleporter_exit", 0, "images/inventoryimages/eteleporter_exit.xml")}, engietab, GLOBAL.TECH.SCIENCE_ONE, nil, nil, nil, nil, "engietelexitdummy", "images/inventoryimages/buildinglocked.xml", "buildinglocked.tex")
AddRecipe2("eteleporter_exit_dummy", 				{Ingredient("eteleporter_exit", 0, "images/engineeritemimages.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engietelexitdummy", atlas = "images/engineeritemimages.xml", image = "buildinglocked.tex"},				{"CHARACTER"})


--Gibus
-- Craftable for everyone for all your Gibus needs.
--local gibus = AddRecipe("gibus", {Ingredient("silk", 2), Ingredient("charcoal", 2)}, GLOBAL.RECIPETABS.DRESS, GLOBAL.TECH.SCIENCE_NONE, nil, nil, nil, nil, nil, "images/inventoryimages/gibus.xml")
AddRecipe2("gibus", 				{Ingredient("silk", 2), Ingredient("charcoal", 2)},				GLOBAL.TECH.NONE,				{atlas = "images/engineeritemimages.xml"},				{"CLOTHING"})

--Deconstruction PDA
--AddRecipe2("destructionpda", 				{Ingredient("scrap", 10, "images/inventoryimages/scrap.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/inventoryimages/destructionpda.xml", image = "destructionpda.tex"},				{"CHARACTER"})
local recipe_difficulty = GetModConfigData("pda_Difficulty")
if recipe_difficulty == "default" then
AddRecipe2("destructionpda", 				{Ingredient("scrap", 15, "images/engineeritemimages.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER"})

elseif recipe_difficulty == "easy" then 
AddRecipe2("destructionpda", 				{Ingredient("scrap", 5, "images/engineeritemimages.xml")},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER"})
elseif recipe_difficulty == "hard" then 
AddRecipe2("destructionpda", 				{Ingredient("scrap", 20, "images/engineeritemimages.xml"), Ingredient("gears", 2)},				GLOBAL.TECH.NONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER"})
elseif recipe_difficulty == "harder" then 
AddRecipe2("destructionpda", 				{Ingredient("scrap", 25, "images/engineeritemimages.xml"), Ingredient("gears", 5), Ingredient("gunpowder", 3)},				GLOBAL.TECH.ONE,				{builder_tag="engie", atlas = "images/engineeritemimages.xml"},				{"CHARACTER"})
end

GLOBAL.MATERIALS.SCRAP = "SCRAP"
local scrap = {"scrap", }


-- PostInit ------------------------------

if GetModConfigData("sentryh_regen") == "y" then
AddPrefabPostInit("esentry", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst.components.health:StartRegen(20, 1)
	end
end)
end

if GetModConfigData("building_upgradeable") == "n" then
function MachinePostInit(inst)
    if GLOBAL.TheWorld.ismastersim then
		inst:AddTag("NOLEVEL")
    end
end

AddPrefabPostInit("esentry", MachinePostInit)
AddPrefabPostInit("dispenser", MachinePostInit)
end

-- Actions ------------------------------

local ENGIETELEPORT = AddAction("ENGIETELEPORT", "Enter", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.engieteleporter and act.target:HasTag("eteleporter_enter") then
		act.target.components.engieteleporter.boundEntrance = act.target
		act.target.components.engieteleporter:TeleportAction(act.doer)
		if act.doer.components.sanity and not act.doer:HasTag("engie") then
            act.doer.components.sanity:DoDelta(-TUNING.ETELEPORT_PENALTY)
	    end
		return true
	end
end)
--ENGIETELEPORT.ghost_valid = true
ENGIETELEPORT.encumbered_valid = true
ENGIETELEPORT.mount_valid = true

local ENGIEWORKABLE = GLOBAL.Action()
ENGIEWORKABLE.id = "ENGIEWORKABLE"
ENGIEWORKABLE.str = {
    GENERIC = "Repair",
    DISPENSER = "Refuel",
	SENTRY = "Reload",
	SENTRY_LVL = "Reload/Upgrade",
	DISPENSER_LVL = "Refuel/Upgrade",
}
ENGIEWORKABLE.strfn = function(act)
	if act.target ~= nil then
		if act.target.prefab == "esentry" and act.target:HasTag("lvl3") then
			return "SENTRY"
		elseif act.target.prefab == "esentry" and not act.target:HasTag("lvl3") then
			return "SENTRY_LVL"
		elseif act.target.prefab == "dispenser" and act.target:HasTag("lvl3") then
			return "DISPENSER"
		elseif act.target.prefab == "dispenser" and not act.target:HasTag("lvl3") then
			return "DISPENSER_LVL"
		--elseif act.target.components.health ~= nil and act.target.components.health.currenthealth ~= act.target.components.health.maxhealth then
		--	return "GENERIC"
		end
	end
end

ENGIEWORKABLE.fn = function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.engieworkable then
		act.target.components.workable:WorkedBy(act.doer, 0)
		return true
	end
end
AddAction(ENGIEWORKABLE)
--[[
AddAction("ENGIEWORKABLE", "Repair/Reload", function(act)
	if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and act.target.components.engieworkable then
		act.target.components.workable:WorkedBy(act.doer, 0)
		return true
	end
end)--]]

GLOBAL.ACTIONS.PICKUP.oldfn = GLOBAL.ACTIONS.PICKUP.fn --Cheat to make non-engineers not able to toss them about
GLOBAL.ACTIONS.PICKUP.fn = function(act)
	if act.doer ~= nil and act.target ~= nil then
	if act.target:HasTag("ebuild") and not act.doer:HasTag("engie") then
		return false, "RESTRICTION"
	elseif act.target.dispenserID and act.target.dispenserID ~= act.doer.engieID and act.doer:HasTag("engie") then
		return false, "RESTRICTION_ENGINEER"
	elseif act.target.turretID and act.target.turretID ~= act.doer.engieID and act.doer:HasTag("engie") then
		return false, "RESTRICTION_ENGINEER"
	elseif act.target.telenterID and act.target.telenterID ~= act.doer.engieID and act.doer:HasTag("engie") then
		return false, "RESTRICTION_ENGINEER"
	elseif act.target.telexitID and act.target.telexitID ~= act.doer.engieID and act.doer:HasTag("engie") then
		return false, "RESTRICTION_ENGINEER"
	else
		return GLOBAL.ACTIONS.PICKUP.oldfn(act) 
	end
	end
end

-- Component actions ---------------------

AddComponentAction("SCENE", "engieteleporter", function(inst, doer, actions, right)
	if inst:HasTag("eteleporter_enter") then
		table.insert(actions, GLOBAL.ACTIONS.ENGIETELEPORT)
	end
end)

AddComponentAction("SCENE", "engieworkable", function(inst, doer, actions, right)
	if (inst:HasTag("ebuild_wrenchable") and doer.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS) ~= nil and doer.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS).prefab == "tf2wrench") then
		    table.insert(actions, GLOBAL.ACTIONS.ENGIEWORKABLE)
	end
end)

-- Stategraph ----------------------------

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENGIETELEPORT, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENGIETELEPORT, "doshortaction"))

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENGIEWORKABLE, --Workaround for previous hammer conflicts ect
        function(inst)
            if inst:HasTag("beaver") then
                return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
            end
            return not inst.sg:HasStateTag("prehammer")
                and (inst.sg:HasStateTag("hammering") and
                    "hammer" or
                    "hammer_start")
                or nil
end))

AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENGIEWORKABLE,
        function(inst)
            if inst:HasTag("beaver") then
                return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
            end
            return not inst.sg:HasStateTag("prehammer") and "hammer_start" or nil
end))

function EngieSGPostInit(inst)
	local _castspell_actionhandler = inst.actionhandlers[GLOBAL.ACTIONS.CASTSPELL].deststate
	inst.actionhandlers[GLOBAL.ACTIONS.CASTSPELL].deststate = function(inst, action, ...)
		return action.invobject ~= nil
            and ( (action.invobject:HasTag("engiepda") and "engiepdacastspell")
				or _castspell_actionhandler(inst, action, ...)
				)
	end
end
AddStategraphPostInit("wilson", EngieSGPostInit)
AddStategraphPostInit("wilson_client", EngieSGPostInit)

AddStategraphState("wilson",
    State{
        name = "engiepdacastspell",
        tags = { "doing", "busy", "canrotate"  },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("pocketwatch_portal", false)

            inst.components.locomotor:Stop()

            local watch = inst.bufferedaction ~= nil and inst.bufferedaction.invobject
			if watch ~= nil then
		        inst.AnimState:OverrideSymbol("watchprop", watch.AnimState:GetBuild(), "pdaprop")
			end

        end,

        timeline =
        {
            TimeEvent(18 * FRAMES, function(inst)
				if not inst:PerformBufferedAction() then
	                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
				else
	                inst.SoundEmitter:PlaySound("yotb_2021/common/heel_click")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
		            inst.AnimState:PlayAnimation("useitem_pst", false)
					inst.sg:GoToState("idle", true)
                end
            end),
        },        
    }
)

AddStategraphState("wilson_client",
    State{
        name = "engiepdacastspell",
        tags = { "doing", "busy", "canrotate"  },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("useitem_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(2)
        end,   

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    }
)

-- Emotes ----------------------------
local ranchocommands = { "ranchorelaxo", "relaxo", "engineer" }

GLOBAL.AddModUserCommand("ranchorelaxo", "rancho", {
	aliases = ranchocommands,
	prettyname = function(command) return "engineer emote" end,
	desc = function() return "Perform an emote!" end,
	permission = "USER",
	params = {},
	emote = true,
	slash = true,
	usermenu = false,
	servermenu = false,
	vote = false,
    serverfn = function(params, caller)
		local player = GLOBAL.UserToPlayer(caller.userid)
		if player ~= nil and player.prefab == "engineer" then
				player:PushEvent("emote", { anim = { "pre_rancho", "loop_rancho" }, loop = true })
		end
    end,
    localfn = function(params, caller)
		local player = GLOBAL.UserToPlayer(caller.userid)
		if player ~= nil and player.prefab == "engineer" then
				player:PushEvent("emote", { anim = { "pre_rancho", "loop_rancho" }, loop = true })
		end
	end,
})

local kazotskycommands = { "kazotsky", "kazotsky kick", "woowee" }
GLOBAL.AddModUserCommand("kazotsky", "kazotskykick", {
	aliases = kazotskycommands,
	prettyname = function(command) return "engineer emote" end,
	desc = function() return "Perform an emote!" end,
	permission = "USER",
	params = {},
	emote = true,
	slash = true,
	usermenu = false,
	servermenu = false,
	vote = false,
    serverfn = function(params, caller)
		local player = GLOBAL.UserToPlayer(caller.userid)
		if player ~= nil and player.prefab == "engineer" then
				player:PushEvent("emote", { anim = { "kazotsky_pre", "kazotsky_quick_loop" }, loop = true })
		end
    end,
    localfn = function(params, caller)
		local player = GLOBAL.UserToPlayer(caller.userid)
		if player ~= nil and player.prefab == "engineer" then
				player:PushEvent("emote", { anim = { "kazotsky_pre", "kazotsky_quick_loop" }, loop = true })
		end
	end,
})
--
AddMinimapAtlas("images/minimap/engineer.xml")
AddMinimapAtlas("images/minimap/esentry.xml")
AddMinimapAtlas("images/minimap/esentry_2.xml")
AddMinimapAtlas("images/minimap/esentry_3.xml")
AddMinimapAtlas("images/minimap/dispenser.xml")
AddMinimapAtlas("images/minimap/eteleporterentrance.xml")
AddMinimapAtlas("images/minimap/eteleporterexit.xml")
--
AddModCharacter("engineer", "MALE")