-- In this file: Miscellaneous edits to prefabs, components, widgets, etc.

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
local TUNING = GLOBAL.TUNING
local CHARACTER_INGREDIENT = GLOBAL.CHARACTER_INGREDIENT
local CHARACTER_INGREDIENT_SEG = GLOBAL.CHARACTER_INGREDIENT_SEG
local AllRecipes = GLOBAL.AllRecipes
local SpawnPrefab = GLOBAL.SpawnPrefab
local ACTIONS = GLOBAL.ACTIONS
local RemovePhysicsColliders = GLOBAL.RemovePhysicsColliders
local FRAMES = GLOBAL.FRAMES
local ActionHandler = GLOBAL.ActionHandler
local EventHandler = GLOBAL.EventHandler
local State = GLOBAL.State
local TimeEvent = GLOBAL.TimeEvent
local GetValidRecipe = GLOBAL.GetValidRecipe
local FOODTYPE = GLOBAL.FOODTYPE
local GetGameModeProperty = GLOBAL.GetGameModeProperty
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local PREFAB_SKINS = GLOBAL.PREFAB_SKINS
local PREFAB_SKINS_IDS = GLOBAL.PREFAB_SKINS_IDS
local SKIN_AFFINITY_INFO = GLOBAL.require("skin_affinity_info")
local Vector3 = GLOBAL.Vector3
local Lerp = GLOBAL.Lerp
local DEGREES = GLOBAL.DEGREES

local GetFrameSymbolForRarity = GLOBAL.GetFrameSymbolForRarity

local reskintool_item_tags = {
	wiltonmod_shoot = 1,
	wiltonmod_shoot_skin = 2,
	wiltonmod_boneheart = 3,
	wiltonmod_boneheart_skin = 4,
	wiltonmod_sharpbone = 5,
	wiltonmod_sharpbone_skin = 6,
	wiltonmod_sharpbone_stonesword = 15,
	wiltonmod_staff3 = 7,
	wiltonmod_staff3_skin = 8,
	wiltonmod_staff1 = 9,
	wiltonmod_staff1_skin = 10,
	wiltonmod_staff2 = 11,
	wiltonmod_staff2_skin = 12,
	wiltonmod_bonehammer = 13,
	wiltonmod_bonehammer_skin = 14,
}

local reskintool_item_prefab = {	
	"wiltonmod_shoot_skin",
	"wiltonmod_shoot",
	"wiltonmod_boneheart_skin",
	"wiltonmod_boneheart",
	"wiltonmod_sharpbone_skin",
	"wiltonmod_sharpbone_stonesword",
	"wiltonmod_staff3_skin",
	"wiltonmod_staff3",
	"wiltonmod_staff1_skin",
	"wiltonmod_staff1",
	"wiltonmod_staff2_skin",
	"wiltonmod_staff2",
	"wiltonmod_bonehammer_skin",
	"wiltonmod_bonehammer",
	[15] = "wiltonmod_sharpbone",
}

AddPrefabPostInit("reskin_tool", function(inst)
    if not TheWorld.ismastersim then
         return inst
    end

    if inst.components.spellcaster.spell then  

    local can_cast_fn_old = inst.components.spellcaster.can_cast_fn
    inst.components.spellcaster:SetCanCastFn(function(doer, target, pos, ...)
        if target and reskintool_item_tags[target.prefab] then
            return true
        end

        if target and target.prefab == "wiltonmod_pet" then
            return true
        end

        if can_cast_fn_old ~= nil then
            return can_cast_fn_old(doer, target, pos, ...)
        end
    end)

    local spell_old = inst.components.spellcaster.spell
    inst.components.spellcaster:SetSpellFn(function(tool, target, pos, ...)
        if target and target.prefab == "wiltonmod_pet" and target.SetPetScarecrow ~= nil then

            local fx_prefab = "explode_reskin"
            local skin_fx = SKIN_FX_PREFAB[inst:GetSkinName()]
            if skin_fx ~= nil and skin_fx[1] ~= nil then
            fx_prefab = skin_fx[1]
            end
            local fx = SpawnPrefab(fx_prefab)
            local x, y, z = target.Transform:GetWorldPosition()
            if fx then
                fx.Transform:SetPosition(x, 0, z)
            end

            local enable = not target.pet_isscarecrow
            target:SetPetScarecrow(enable)

            return true
        end

        if target and reskintool_item_tags[target.prefab] then

            local fx_prefab = "explode_reskin"
            local skin_fx = SKIN_FX_PREFAB[inst:GetSkinName()]
            if skin_fx ~= nil and skin_fx[1] ~= nil then
            fx_prefab = skin_fx[1]
            end
            local fx = SpawnPrefab(fx_prefab)
            local x, y, z = target.Transform:GetWorldPosition()
            if fx then
                fx.Transform:SetPosition(x, 0, z)
            end

            local chain = SpawnPrefab(reskintool_item_prefab[reskintool_item_tags[target.prefab]])
            if chain then  
            	chain.Transform:SetPosition(x, 0, z)

            	if target.components.stackable ~= nil and chain.components.stackable ~= nil then
            		chain.components.stackable:SetStackSize(target.components.stackable:StackSize())
            	end

            	if target.components.finiteuses ~= nil and chain.components.finiteuses ~= nil then
            		chain.components.finiteuses:SetPercent(target.components.finiteuses:GetPercent())
            	end

                target:Remove()
            end 

            return true
        end

        if spell_old ~= nil then
            return spell_old(tool, target, pos, ...)
        end
    end)
    end
end)


local PREFAB_SKINS = GLOBAL.PREFAB_SKINS
local PREFAB_SKINS_IDS = GLOBAL.PREFAB_SKINS_IDS  
local SKIN_AFFINITY_INFO = GLOBAL.require("skin_affinity_info")

modimport("scripts/util/wiltonmod_skin_api.lua")

SKIN_AFFINITY_INFO.wiltonmod = { "wiltonmod_skin1_none", "wiltonmod_scarecrow_none" }

PREFAB_SKINS_IDS = {}
for prefab,skins in pairs(PREFAB_SKINS) do
    PREFAB_SKINS_IDS[prefab] = {}
    for k,v in pairs(skins) do
          PREFAB_SKINS_IDS[prefab][v] = k
    end
end

AddSkinnableCharacter("wiltonmod") 
