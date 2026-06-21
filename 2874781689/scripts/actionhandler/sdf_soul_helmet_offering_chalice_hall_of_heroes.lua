GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Spawn Gallowmere Knight
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_SOUL_HELMET_OFFERING"
local name = STRINGS.ACTIONHANDLER_SDF_SOUL_HELMET_OFFERING


local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local MUST_HAVE_TAGS = {"sdf_runestone_offering"}
--local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 3

local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.CHALICEFILLED == true then

	--play offering FX
	local x,_,z=act.target.Transform:GetWorldPosition()
	SpawnPrefab("monkey_deform_pre_fx").Transform:SetPosition(x,_,z)
	act.target.SoundEmitter:PlaySound("monkeyisland/wonkycurse/curse_fx")

	--Lost Soul Saved
	act.target:DoTaskInTime(1.3, function()
	    if act.target.CHALICEFILLED == true then

		if act.doer.components.talker then
		    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_SOUL_HELMET_OFFERING_SAVED"),4)
		end

		--create Reward FX
		local x,_,z = act.target.Transform:GetWorldPosition()
		local affected_entity = TheSim:FindEntities(x,_,z, AOE_RADIUS, MUST_HAVE_TAGS)
		for i, v in ipairs(affected_entity) do

		    --find spawn spot
		    if v ~= nil then
			local fx, fy, fz = v.Transform:GetWorldPosition()

			--make FX
			SpawnPrefab("sdf_goodlightning_charged_bolt_fx").Transform:SetPosition(fx, fy, fz)
			SpawnPrefab("sdf_goodlightning_shock_fx").Transform:SetPosition(fx, fy, fz)

			--Spawn Knight of Gallowmere Reward
			local gallowmereKnight = SpawnPrefab("sdf_gallowmere_knight")
			gallowmereKnight.Transform:SetPosition(fx, fy, fz)
			gallowmereKnight.components.bloomer:PushBloom("Healthy", "shaders/anim.ksh", 50)

			--graveSpawn
			gallowmereKnight.AnimState:PlayAnimation("grave_spawn")

			--follow
			gallowmereKnight:DoTaskInTime(3.6, function()
			    if act.doer and not (act.doer.components.health and act.doer.components.health:IsDead()) then
				gallowmereKnight.components.sdf_gallowmere_knight_tactics:TurnOn(act.doer)
				gallowmereKnight:RemoveTag("sdf_gallowmere_knight_command_stay")
				gallowmereKnight:AddTag("sdf_gallowmere_knight_command_follow")
			    end
			end)
		
			--Remove soul helmet
			act.invobject:Remove()
		    end
		end
	    end
	end)
	return true
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_soul_helmet_offering_chalice_hall_of_heroes"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_soul_helmet_offering") and target:HasTag("sdf_chalice_hall_of_heroes") then
	table.insert(actions, ACTIONS.SDF_SOUL_HELMET_OFFERING)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_SOUL_HELMET_OFFERING, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_SOUL_HELMET_OFFERING,state))