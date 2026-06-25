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

AddPrefabPostInit("william", function(inst)
    if not GLOBAL.TheWorld or not GLOBAL.TheWorld.ismastersim then 
        return 
    end
	    
		if not inst.components.builder:KnowsRecipe(	"transistor") then
            inst.components.builder:UnlockRecipe("transistor")
        end
		if not inst.components.builder:KnowsRecipe(	"gallop_extra_a_shield_iron") then--蒸汽mod
            inst.components.builder:UnlockRecipe("gallop_extra_a_shield_iron")
        end
		if not inst.components.builder:KnowsRecipe(	"gallop_extra_a_scavenging_axe") then--蒸汽mod
            inst.components.builder:UnlockRecipe("gallop_extra_a_scavenging_axe")
        end
		if not inst.components.builder:KnowsRecipe(	"gallop_extra_a_moonchargeplasma") then--蒸汽mod
            inst.components.builder:UnlockRecipe("gallop_extra_a_moonchargeplasma")
        end
		if not inst.components.builder:KnowsRecipe(	"yoth_knightshrine") then
            inst.components.builder:UnlockRecipe("yoth_knightshrine")
        end
		if not inst.components.builder:KnowsRecipe("the_real_charles_t_horse") then
            inst.components.builder:UnlockRecipe("the_real_charles_t_horse")
        end
		if not inst.components.builder:KnowsRecipe("gear_axe") then
            inst.components.builder:UnlockRecipe("gear_axe")
        end
		if not inst.components.builder:KnowsRecipe("gear_mace") then
            inst.components.builder:UnlockRecipe("gear_mace")
        end
		if not inst.components.builder:KnowsRecipe("sparks2") then
            inst.components.builder:UnlockRecipe("sparks2")
        end
		if not inst.components.builder:KnowsRecipe("gear_hat") then
            inst.components.builder:UnlockRecipe("gear_hat")
        end
		if not inst.components.builder:KnowsRecipe("gear_mask") then
            inst.components.builder:UnlockRecipe("gear_mask")
        end
		if not inst.components.builder:KnowsRecipe("gear_armor") then
            inst.components.builder:UnlockRecipe("gear_armor")
        end
		if not inst.components.builder:KnowsRecipe("gear_helmet") then
            inst.components.builder:UnlockRecipe("gear_helmet")
        end
		if not inst.components.builder:KnowsRecipe("gear_wings") then
            inst.components.builder:UnlockRecipe("gear_wings")
        end
		if not inst.components.builder:KnowsRecipe("sentinel") then
            inst.components.builder:UnlockRecipe("sentinel")
        end
		if not inst.components.builder:KnowsRecipe("ws_03") then
            inst.components.builder:UnlockRecipe("ws_03")
        end
		if not inst.components.builder:KnowsRecipe("gear_torch") then
            inst.components.builder:UnlockRecipe("gear_torch")
        end
end)

local CLOCKWORK_PREFABS = {"knight", "bishop", "rook", "knight_nightmare", "bishop_nightmare", "rook_nightmare"}

for _, prefab in ipairs(CLOCKWORK_PREFABS) do
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end

        if inst.components.combat then
            local old_Retarget = inst.components.combat.targetfn
            inst.components.combat:SetRetargetFunction(2, function(inst)
                local target = old_Retarget and old_Retarget(inst)
                if target and target:HasTag("chessfriend") then
                    return nil
                end
                return target
            end)
        end
    end)
end

AddComponentPostInit("playerspawner", function(self)
    -- 保存原始的 SpawnAtLocation 函数
    local originalSpawnAtLocation = self.SpawnAtLocation

    -- 重写 SpawnAtLocation 函数
    self.SpawnAtLocation = function(self, inst, player, x, y, z, isloading)
        -- 只处理 william 的首次生成
        if player.prefab == "william" and self:IsPlayersInitialSpawn(player) then
            -- 只在 master 层执行
            if not GLOBAL.TheWorld:HasTag("cave") then
                -- 找 knight
                local knight = nil
                for k, v in pairs(GLOBAL.Ents) do
                    if v.prefab == "knight" then
                        knight = v
                        break
                    end
                end

                -- 如果找到 knight，传送到旁边
                if knight then
                    local jx, jy, jz = knight.Transform:GetWorldPosition()
                    x, y, z = jx + 2, jy, jz + 2
                end
            end
        end

        -- 调用原始函数
        return originalSpawnAtLocation(self, inst, player, x, y, z, isloading)
    end
end)

AddPrefabPostInit("william", function(inst)
    if not GLOBAL.TheWorld or not GLOBAL.TheWorld.ismastersim then
        return
    end
end)	
	-- 设置起始物品
if TUNING and TUNING.GAMEMODE_STARTING_ITEMS and TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT then
    TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WILLIAM = TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WILLIAM or {}
    table.insert(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WILLIAM, "williamballistic_empty")
	table.insert(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WILLIAM, "gears")
end


--------------------- WILLIAM ROBOT SHOVE

local function WilliamRobotShove(inst, target)
    if target and inst and not target:HasAnyTag("wixieshoved", "shadow", "shadowcreature", "shadowminion", 
        "stalkerminion", "shadowchesspiece", "eyeplant", "bowlingpin")
        and target.components and target.components.locomotor then
        
        SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(target.Transform:GetWorldPosition())

        target:AddTag("wixieshoved")
        target:PushEvent("wixieshoved")

        local x, y, z = inst.Transform:GetWorldPosition()

        for i = 1, 50 do
            inst:DoTaskInTime((i - 1) / 50, function(inst)
                local tx, ty, tz = target.Transform:GetWorldPosition()
                    
                if tx ~= nil then
                    local EXCLUDE_TAGS = {"player", "playerghost", "ghost", "shadow", "shadowminion", "noauradamage", "INLIMBO", "notarget", "noattack", "invisible", "wixieshoved"}
                        
                    if i == 1 then
                        target.components.locomotor:SetExternalSpeedMultiplier(target, "wixieshoved", .01)
                    end

                    local ents = TheSim:FindEntities(tx, ty, tz, 1.5 + target:GetPhysicsRadius(0), {"_combat"}, EXCLUDE_TAGS)

                    for iv, v in ipairs(ents) do
                        if v ~= target and v.components.locomotor then
                            v:PushEvent("wixieshoved")

                            local giantdamagereduction = target:HasTag("epic") and 2 or target:HasTag("smallcreature") and .5 or 1

                            if v.components.combat ~= nil and v.components.freezable == nil or not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) then
                                v.components.combat:GetAttacked(nil, 10 * giantdamagereduction)
                                v.components.combat:SuggestTarget(inst)
                            end

                            SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(v.Transform:GetWorldPosition())

                            v:AddTag("wixieshoved")

                            for iv2 = 1, 50 do
                                inst:DoTaskInTime((iv2 - 1) / 50, function(inst)
                                    if v ~= nil and v.Transform:GetWorldPosition() and target ~= nil and tx ~= nil then
                                        if iv2 == 1 then
                                            v.components.locomotor:SetExternalSpeedMultiplier(v, "wixieshoved", .01)
                                        end

                                        local px, py, pz = v.Transform:GetWorldPosition()
                                        local rad_collision = -math.rad(v:GetAngleToPoint(tx, ty, tz))
                                        local velx_collision = math.cos(rad_collision)
                                        local velz_collision = -math.sin(rad_collision)

                                        local targetreduction = target:HasTag("epic") and 1 or target:HasTag("smallcreature") and 3 or 2
                                        local vreduction = v:HasTag("epic") and 3 or v:HasTag("smallcreature") and 1 or 2
                                        local finalreduction = targetreduction + vreduction

                                        if px ~= nil then
                                            local vx, vy, vz = px + ((((5 / (iv2 + 1)) * velx_collision) / finalreduction)), py, pz + ((((5 / (iv2 + 1)) * velz_collision) / finalreduction))

                                            local ground_collision = GLOBAL.TheWorld.Map:IsPassableAtPoint(vx, vy, vz)
                                            local boat_collision = GLOBAL.TheWorld.Map:GetPlatformAtPoint(vx, vz)
                                            local ocean_collision = GLOBAL.TheWorld.Map:IsOceanAtPoint(vx, vy, vz)

                                            if not (v.sg ~= nil and (v.sg:HasStateTag("swimming") or v.sg:HasStateTag("invisible"))) then
                                                if v ~= nil and v.components.locomotor ~= nil and vx ~= nil and (ground_collision or boat_collision or ocean_collision and v.components.locomotor:CanPathfindOnWater() or v.components.tiletracker ~= nil and not v:HasTag("whale")) then
                                                    v.Transform:SetPosition(vx, vy, vz)
                                                end
                                            end
                                        end
                                    end

                                    if iv2 >= 50 then
                                        v:RemoveTag("wixieshoved")
                                        if v.components.locomotor then
                                            v.components.locomotor:RemoveExternalSpeedMultiplier(v, "wixieshoved")
                                        end
                                    end
                                end)
                            end
                        end
                    end

                    local scale = .5 - (i / 40)
                    if scale > 0 then
                        if not target:HasTag("flying") and target.sg ~= nil and not target.sg:HasStateTag("flight") and not target:HasTag("aquatic") then
                            local dirtpuff = SpawnPrefab("dirt_puff")
                            dirtpuff.Transform:SetPosition(target.Transform:GetWorldPosition())
                            dirtpuff.Transform:SetScale(scale, scale, scale)
                        end
                    end

                    local rad = math.rad(inst:GetAngleToPoint(tx, ty, tz))
                    local velx = math.cos(rad)
                    local velz = -math.sin(rad)

                    local giantreduction = target:HasTag("epic") and 1.5 or target:HasTag("smallcreature") and .8 or 1
                    local dx, dy, dz = tx + ((((3 / (i + 2)) * velx) / giantreduction)), ty, tz + ((((3 / (i + 2)) * velz) / giantreduction))
                    local ground_target = GLOBAL.TheWorld.Map:IsPassableAtPoint(dx, dy, dz)
                    local boat_target = GLOBAL.TheWorld.Map:GetPlatformAtPoint(dx, dz)
                    local ocean_target = GLOBAL.TheWorld.Map:IsOceanAtPoint(dx, dy, dz)

                    if not (target.sg ~= nil and (target.sg:HasStateTag("swimming") or target.sg:HasStateTag("invisible"))) then
                        if target ~= nil and target.components.locomotor ~= nil and dx ~= nil and (ground_target or boat_target or ocean_target and target.components.locomotor:CanPathfindOnWater() or target.components.tiletracker ~= nil and not target:HasTag("whale")) then
                            target.Transform:SetPosition(dx, dy, dz)
                        end
                    end
                end

                if i >= 50 then
                    target:RemoveTag("wixieshoved")
                    if target.components.locomotor then
                        target.components.locomotor:RemoveExternalSpeedMultiplier(target, "wixieshoved")
                    end
                end
            end)
        end
    end
end

local function OnRobotAttackOther(inst, data)
    if data and data.target then
        WilliamRobotShove(inst, data.target)
    end
end

AddPrefabPostInit("williambuster", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    inst:ListenForEvent("onattackother", OnRobotAttackOther)
end)

AddPrefabPostInit("williambrute", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    inst:ListenForEvent("onattackother", OnRobotAttackOther)
end)

AddComponentPostInit("healer", function(self)
    local old_Heal = self.Heal
    self.Heal = function(self, target, ...)
        if self.inst:HasTag("williamhealer") then
            if not (target:HasTag("williamhealable") or target:HasTag("chess")) then
                return false
            end
        end
        return old_Heal and old_Heal(self, target, ...)
    end
end)