local STRINGS = GLOBAL.STRINGS
local require = GLOBAL.require
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
GetWorld = GLOBAL.GetWorld
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
Action = GLOBAL.Action
local TheSim = GLOBAL.TheSim
local Vector3 = GLOBAL.Vector3
local ACTIONS = GLOBAL.ACTIONS
local containers = GLOBAL.require "containers"
require("recipe")
require "class"
local FRAMES = GLOBAL.FRAMES
FRAMES = GLOBAL.FRAMES
local TimeEvent = GLOBAL.TimeEvent
TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
EventHandler = GLOBAL.EventHandler
localEQUIPSLOTS = GLOBAL.EQUIPSLOTS
EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local SpawnPrefab = GLOBAL.SpawnPrefab
SpawnPrefab = GLOBAL.SpawnPrefab

Assets = {

    Asset("ANIM", "anim/william.zip"),

    Asset( "IMAGE", "images/saveslot_portraits/william.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/william.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/william.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/william.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/william_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/william_silho.xml" ),

    Asset( "IMAGE", "bigportraits/william.tex" ),
    Asset( "ATLAS", "bigportraits/william.xml" ),

	Asset( "ATLAS", "images/inventoryimages/williamgadget.xml" ),
	Asset( "IMAGE", "images/inventoryimages/williamgadget.tex" ),

	Asset( "ATLAS", "images/inventoryimages/williambutler_builder.xml" ),
	Asset( "IMAGE", "images/inventoryimages/williambutler_builder.tex" ),

	Asset( "ATLAS", "images/inventoryimages/williambuster_builder.xml" ),
	Asset( "IMAGE", "images/inventoryimages/williambuster_builder.tex" ),

	Asset( "ATLAS", "images/inventoryimages/williambrute_builder.xml" ),
	Asset( "IMAGE", "images/inventoryimages/williambrute_builder.tex" ),

	Asset( "ATLAS", "images/inventoryimages/williamballistic_empty.xml" ),
	Asset( "IMAGE", "images/inventoryimages/williamballistic_empty.tex" ),

	Asset( "IMAGE", "images/map_icons/william.tex" ),
	Asset( "ATLAS", "images/map_icons/william.xml" ),

	Asset( "IMAGE", "images/map_icons/williambrute.tex" ),
	Asset( "ATLAS", "images/map_icons/williambrute.xml" ),
	
	Asset( "IMAGE", "images/map_icons/williambuster.tex" ),
	Asset( "ATLAS", "images/map_icons/williambuster.xml" ),

	Asset( "IMAGE", "images/map_icons/williamballistic.tex" ),
	Asset( "ATLAS", "images/map_icons/williamballistic.xml" ),

	Asset( "IMAGE", "images/map_icons/williambutler.tex" ),
	Asset( "ATLAS", "images/map_icons/williambutler.xml" ),

	Asset( "IMAGE", "images/avatars/avatar_william.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_william.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_william.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_william.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_william.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_william.xml" ),
	
	Asset( "IMAGE", "images/names_william.tex" ),
    Asset( "ATLAS", "images/names_william.xml" ),

	Asset( "IMAGE", "images/names_gold_william.tex" ),
    Asset( "ATLAS", "images/names_gold_william.xml" ),
	
    Asset( "IMAGE", "bigportraits/william_none.tex" ),
    Asset( "ATLAS", "bigportraits/william_none.xml" ),

    Asset("ATLAS", "images/tabs/williamtab.xml"),
        Asset("IMAGE", "images/tabs/williamtab.tex"),

    Asset("SOUNDPACKAGE", "sound/william.fev"),
    Asset("SOUND", "sound/william.fsb"),

    Asset("SOUNDPACKAGE", "sound/tiddle_stranger.fev"),
    Asset("SOUND", "sound/tiddle_stranger.fsb"),

}

PrefabFiles = {
	"william",
	"william_skins",
	"williamgadget",
	"william_buster",
	"william_brute",
	"william_ballistic",
	"william_butler",
	"william_charge",
	"william_charged_fx",
	"william_mistake",
	"tiddlestranger_william",
}


   --------------------- INVENTORY IMAGE SETUP

    local inventoryitems = {
	    "williamgadget",
	    "williambuster_builder",
	    "williambutler_builder",
	    "williamballistic_builder",
	    "williambrute_builder",
    }

    for _, item in pairs(inventoryitems) do 
	RegisterInventoryItemAtlas("images/inventoryimages/"..item..".xml", item..".tex")
    end


	--------------------- SOUND SETUP

	local williamsounds = {
	    "talk_LP", "ghost_LP",
	    "hurt", "death_voice", "sinking",
	    "emote", "pose", "carol", "eye_rub_vo", "yawn",
	}
	for _,sound in pairs(williamsounds) do
	    RemapSoundEvent( "dontstarve/characters/william/"..sound, "william/characters/william/"..sound )
	end

	   RemapSoundEvent( "dontstarve/characters/tiddle_stranger/talk_LP", "tiddle_stranger/characters/tiddle_stranger/talk_LP" )
	   RemapSoundEvent( "dontstarve/characters/tiddle_stranger/talk_end", "tiddle_stranger/characters/tiddle_stranger/talk_end" )


	    --------------------- MINIMAP ICON SETUP

	    local minimapicons = {
	    "william",
	    "williambuster",
	    "williambutler",
	    "williamballistic",
	    "williambrute",
	    }

	    for _,image in pairs(minimapicons) do
	    	AddMinimapAtlas("images/map_icons/"..image..".xml")
	    end


		--------------------- IMPORTS SETUP
 
		modimport('imports/william_tuning.lua')
		modimport('imports/william_strings.lua')
		--modimport('imports/william_postinits.lua')
		modimport('imports/william_acts.lua')
		modimport('imports/william_widgets.lua')
		modimport('imports/william_recipes.lua')
		modimport('imports/william_states.lua')


		    --------------------- WILLIAM SETUP

		    AddModCharacter("william", "MALE")


AddPrefabPostInit("forest", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
	return inst
    end
    inst:AddComponent("tiddlestrangerspawner_william")
end)
