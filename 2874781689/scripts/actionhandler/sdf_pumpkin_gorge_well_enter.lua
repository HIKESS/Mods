--GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})


--Enter and Leave Pumpkin Gorge Well
local PUMPKIN_GORGE_WELL_ENTER =
    AddAction("SDF_PUMPKIN_GORGE_WELL_ENTER",STRINGS.ACTIONHANDLER_SDF_PUMPKIN_GORGE_WELL_ENTER,function(act)
	--Enter Pumpkin Gorge Well
	if act.doer ~= nil then
	    if act.doer.sg ~= nil then
		if act.doer.sg.currentstate.name == "sdf_pumpkin_gorge_well_in_pre" then

		    --Well Vine is dead
		    if act.target ~= nil and (act.target.spawnedVine ~= nil and act.target.spawnedVine == false) or act.target:HasTag("sdf_pumpkin_gorge_well_door_exit") then
			if act.target ~= nil and act.target.components.sdf_pumpkin_gorge_well_teleporter ~= nil and act.target.components.sdf_pumpkin_gorge_well_teleporter:IsActive() then
			    act.doer.sg:GoToState("sdf_pumpkin_gorge_well_jump", {sdf_pumpkin_gorge_well_teleporter = act.target})
			    return true
			end
		    end
		    act.doer.components.talker:Say(STRINGS.ANNOUNCE_SDF_PUMPKIN_GORGE_WELL_ACCESS_DENIED)
		end
		act.doer.sg:GoToState("idle")
	    end
	end
	return true
    end)

PUMPKIN_GORGE_WELL_ENTER.priority = 1
PUMPKIN_GORGE_WELL_ENTER.ghost_valid = true
PUMPKIN_GORGE_WELL_ENTER.encumbered_valid = true

--AddAction(PUMPKIN_GORGE_WELL_ENTER)

local type = "SCENE"
local component = "sdf_pumpkin_gorge_well_teleporter"
local testfn = function(inst, doer, target, actions)
    if inst:HasTag("sdf_pumpkin_gorge_well_teleporter") then
	table.insert(target, ACTIONS.SDF_PUMPKIN_GORGE_WELL_ENTER)
    end
end

AddComponentAction(type, component, testfn)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.SDF_PUMPKIN_GORGE_WELL_ENTER, "sdf_pumpkin_gorge_well_in_pre"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.SDF_PUMPKIN_GORGE_WELL_ENTER, "sdf_pumpkin_gorge_well_in_pre"))
AddStategraphActionHandler("wilsonghost", ActionHandler(ACTIONS.SDF_PUMPKIN_GORGE_WELL_ENTER, "sdf_pumpkin_gorge_well_in_pre"))
AddStategraphActionHandler("wilsonghost_client", ActionHandler(ACTIONS.SDF_PUMPKIN_GORGE_WELL_ENTER, "sdf_pumpkin_gorge_well_in_pre"))