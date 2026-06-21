GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})
 
local unpack = unpack or table.unpack or GLOBAL.unpack
local Vector3 = GLOBAL.Vector3
local DEGREES = GLOBAL.DEGREES

local function results(data, ...)
    return type(data) == "function" and {data(...)}  
	or type(data) == "table" and data 
	or {data} 
end 

local function sandwich(func, ante, post)	
    return function(...)
	local results_ante = results(ante, ...)
	if #results_ante > 0 then
	    return unpack(results_ante)
	end 		
		
	local results_original = results(func, ...)
	local results_post = results(post, ...)

	if #results_post > 0 then
	    return unpack(results_post)
	end 
		
	return unpack(results_original)
    end 
end 

local function overwrite(tabula, name, ante, post, ifnil)
    if type(tabula) ~= "table" then
	return
    end 
    local old = tabula[name]
    if old == nil and ifnil ~= nil then
	old = ifnil
    end 
    tabula[name] = sandwich(old, ante, post)
end 

--------------------------------------------------------------------------------------------------------------------------

--Stay Command
local SDF_GALLOWMERE_KNIGHT_COMMAND_STAY =
    AddAction("SDF_GALLOWMERE_KNIGHT_COMMAND_STAY",STRINGS.ACTIONHANDLER_SDF_GALLOWMERE_KNIGHT_COMMAND_STAY,function(act)

	if act.target and act.target.components.sdf_gallowmere_knight_command then
	    if act.target.components.sdf_gallowmere_knight_unteleportable == nil then
		act.target:AddComponent("sdf_gallowmere_knight_unteleportable")
	    end
	    act.target.components.sdf_gallowmere_knight_tactics:TurnOff()
	    act.target:AddTag("sdf_gallowmere_knight_command_stay")
	    act.target:RemoveTag("sdf_gallowmere_knight_command_follow")
 
	    return true
	end
end)

SDF_GALLOWMERE_KNIGHT_COMMAND_STAY.invalid_hold_action = true
SDF_GALLOWMERE_KNIGHT_COMMAND_STAY.rmb = true
SDF_GALLOWMERE_KNIGHT_COMMAND_STAY.distance = 1.5

local state = "doshortaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_GALLOWMERE_KNIGHT_COMMAND_STAY, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_GALLOWMERE_KNIGHT_COMMAND_STAY,state))


--Follow Command
local SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW =
    AddAction("SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW",STRINGS.ACTIONHANDLER_SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW,function(act)

	if act.target and act.target.components.sdf_gallowmere_knight_command then
	    act.target:RemoveComponent("sdf_gallowmere_knight_unteleportable")

	    act.target.components.sdf_gallowmere_knight_tactics:TurnOn(act.doer)
	    act.target:RemoveTag("sdf_gallowmere_knight_command_stay")
	    act.target:AddTag("sdf_gallowmere_knight_command_follow")
	    return true
	end
end)

SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW.invalid_hold_action = true
SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW.rmb = true
SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW.distance = 1.5

local state = "doshortaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_GALLOWMERE_KNIGHT_COMMAND_FOLLOW,state))

----------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------

--Combat Targeting
local function SDFGallowmereKnightCombatPostInit(inst)
    if not GLOBAL.TheWorld.ismastersim then return end  	
    local combat = inst.components.combat

    -- override combat:GetAttacked
    local old_GetAttacked = combat.GetAttacked
    function combat:GetAttacked(attacker, damage, weapon, stimuli)
	--if attacker and attacker:HasTag("player") then return true end --Disable player damage to GKnight
	if attacker and attacker.components.combat and attacker.components.combat.playerdamagepercent then
	    damage = damage and damage * attacker.components.combat.playerdamagepercent or nil
	end
	return old_GetAttacked(self, attacker, damage, weapon, stimuli)
    end

    -- override combat:SetTarget
    local old_SetTarget = combat.SetTarget
    function combat:SetTarget(target)
    	if target and (target:HasTag("player") or target:HasTag("summonedbyplayer") or target:HasTag("abigail") or target:HasTag("shadowminion") or target:HasTag("wall")) then return end
        return old_SetTarget(self, target) -- call original function
    end
end
AddPrefabPostInit("sdf_gallowmere_knight", SDFGallowmereKnightCombatPostInit)
AddPrefabPostInit("sdf_gallowmere_squire", SDFGallowmereKnightCombatPostInit)

--Combat No Attack
local function SDFGallowmereKnightDoesntTarget(inst)
    inst:AddTag("structure")
end
AddPrefabPostInit("slurtlehole", SDFGallowmereKnightDoesntTarget)


--Combat Calling For Help
local function SDFGallowmereKnightOnAttackedHelp(inst, data)
    if not inst:IsValid() or not inst.components.combat then return end

    inst.components.combat:ShareTarget(data.attacker, 65, function(dude)
        return dude:HasTag("summonedbyplayer") and not dude.components.health:IsDead() and not dude:HasTag("player")
    end, 10)
end


--Explores Caves
local function SDFGallowmereKnightExploreSinkhole(inst)
    if not GLOBAL.TheWorld.ismastersim then
	return
    end   

    inst:ListenForEvent("attacked",SDFGallowmereKnightOnAttackedHelp)
    if not inst.components.sdf_gallowmere_knight_beckon then
	inst:AddComponent("sdf_gallowmere_knight_beckon")
    end
    inst.components.sdf_gallowmere_knight_beckon:AddPrefabToList("sdf_gallowmere_knight")
    inst.components.sdf_gallowmere_knight_beckon:AddPrefabToList("sdf_gallowmere_squire")
end
AddPlayerPostInit(SDFGallowmereKnightExploreSinkhole)