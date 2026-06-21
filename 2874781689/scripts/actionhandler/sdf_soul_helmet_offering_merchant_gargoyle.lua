GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Trade for Gold at Merchant and Shop Gargoyle
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_SOUL_HELMET_OFFERING_GREED"
local name = STRINGS.ACTIONHANDLER_SDF_SOUL_HELMET_OFFERING_GREED


local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local fn = function(act)
    if act.doer.prefab == "sdf" and act.target.MERCHANT_ON == true then

	--play offering FX
	local x,_,z=act.target.Transform:GetWorldPosition()
	SpawnPrefab("monkey_deform_pre_fx").Transform:SetPosition(x,_-1,z)
	act.target.SoundEmitter:PlaySound("monkeyisland/wonkycurse/curse_fx")

	--Lost Soul Forsaken
	act.target:DoTaskInTime(1.3, function()
	    if act.target.MERCHANT_ON == true then

		if act.doer.components.talker then
		    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_SOUL_HELMET_OFFERING_FORSAKEN"),4)
		end

		--create Reward FX
		local x,_,z = act.target.Transform:GetWorldPosition()
		SpawnPrefab("sdf_goodlightning_charged_bolt_fx").Transform:SetPosition(x,_,z)
		SpawnPrefab("sdf_goodlightning_shock_fx").Transform:SetPosition(x,_,z)

		--give gold nuggets
		local x, y, z = act.target.Transform:GetWorldPosition()
		y = 4.5

		local angle
		if act.doer ~= nil and act.doer:IsValid() then
		    angle = 180 - act.doer:GetAngleToPoint(x, 0, z)
		else
		    local down = TheCamera:GetDownVec()
		    angle = math.atan2(down.z, down.x) / DEGREES
		end

		for k = 1, (TUNING.SDF_SOUL_HELMET_VALUE - 2) do
		    local nug = SpawnPrefab("goldnugget")
		    nug.Transform:SetPosition(x, y, z)
		    launchitem(nug, angle)
		end

		--Remove soul helmet
		act.invobject:Remove()
	    end
	end)
	return true
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_soul_helmet_offering_merchant_gargoyle"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_soul_helmet_offering") and target:HasTag("sdf_merchant_gargoyle") then
	table.insert(actions, ACTIONS.SDF_SOUL_HELMET_OFFERING_GREED)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_SOUL_HELMET_OFFERING_GREED, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_SOUL_HELMET_OFFERING_GREED,state))