GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Reset Jack of the Green
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WITCH_TALISMAN_OFFERING_JACK_OF_THE_GREEN"
local name = STRINGS.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_JACK_OF_THE_GREEN


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.JACK_ON == true then	

	local currentShadowRiddleID = act.target.components.sdf_jack_of_the_green_riddle_shadow:GetCurrentRiddle()

	--Check if riddle is resettable
	if currentShadowRiddleID ~= 0 then

	    --play offering FX
    	    SpawnPrefab("sanity_lower").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

	    --locate and reset riddle
    	    act.target:DoTaskInTime(1.1, function()
		if act.target.JACK_ON == true then
		    local previousShadowRiddleID = act.target.components.sdf_jack_of_the_green_riddle_shadow:GetPreviousRiddle()

		    --play offering FX
		    local x,_,z=act.target.Transform:GetWorldPosition()
		    SpawnPrefab("sanity_raise").Transform:SetPosition(x,_,z)

		    --Set Previous shadow riddle id
		    act.target.components.sdf_jack_of_the_green_riddle_shadow:SetPreviousRiddle(currentShadowRiddleID)

		    --Set current shadow riddle id
		    act.target.components.sdf_jack_of_the_green_riddle_shadow:SetCurrentRiddle(0)

		    --Jack talks
		    act.target.talked = true
		    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")

		    if act.target.components.talker then
			act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_BEMUSED, 6)
		    end

		    act.target:TalkedWitchTalismanFn()

		    --Remove witch talisman
		    act.invobject:Remove()
		end
	    end)
	    return true
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_witch_talisman_offering_jack_of_the_green"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_witch_talisman_offering") and target:HasTag("sdf_jack_of_the_green") then
	table.insert(actions, ACTIONS.SDF_WITCH_TALISMAN_OFFERING_JACK_OF_THE_GREEN)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_JACK_OF_THE_GREEN, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_JACK_OF_THE_GREEN,state))