GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Give Lost Crown
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_KING_PEREGRINS_CROWN_OFFERING_KING_PEREGRIN"
local name = STRINGS.ACTIONHANDLER_SDF_KING_PEREGRINS_CROWN_OFFERING_KING_PEREGRIN

local fn = function(act)

    if act.doer.prefab == "sdf" then
	if act.doer.components.sdf_king_peregrin_quest:GetCrownOfferedStatus() == true then

	    --King talks
	    act.target:AddTag("questing")
	    act.target.talked_paused = true
	    act.target.talked = true
	    if act.target.talkingtask ~= nil then
		 act.target.talkingtask:Cancel()
	    end

	    act.target.sg:GoToState("idle_to_sad", true)
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_HINT_CROWN_SDF, 6)

	    --king takes leave
	    act.target:DoTaskInTime(6, function()
		act.target:RemoveTag("questing")
		act.target.talked_paused = false
		act.target.talked = false
		act.target:starttalking()
	    end)

	    return true
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_king_peregrins_crown_offering_king_peregrin"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_king_peregrins_crown_offering") and target:HasTag("sdf_king_peregrin") then
	table.insert(actions, ACTIONS.SDF_KING_PEREGRINS_CROWN_OFFERING_KING_PEREGRIN)
    end
end

AddComponentAction(type, component, testfn)

local state = "give"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_KING_PEREGRINS_CROWN_OFFERING_KING_PEREGRIN, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_KING_PEREGRINS_CROWN_OFFERING_KING_PEREGRIN,state))