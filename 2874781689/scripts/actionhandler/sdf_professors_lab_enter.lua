--GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})


--Enter and Leave Professors Lab
local PROFESSORS_LAB_ENTER =
    AddAction("SDF_PROFESSORS_LAB_ENTER",STRINGS.ACTIONHANDLER_SDF_PROFESSORS_LAB_ENTER,function(act)
	--Enter Professors Lab
	if act.doer ~= nil then
	    if act.doer.sg ~= nil then
		if act.doer.prefab == "sdf" and act.doer.sg.currentstate.name == "sdf_professors_lab_in_pre" then

		    --Skill Tree Professors Lab
		    --if act.doer.components.skilltreeupdater:IsActivated("sdf_undeath_8") then
			if act.target ~= nil and act.target.components.sdf_professors_lab_teleporter ~= nil and act.target.components.sdf_professors_lab_teleporter:IsActive() then
			    act.doer.sg:GoToState("sdf_professors_lab_jump", {sdf_professors_lab_teleporter = act.target})
			    return true
			end
		    --end
		    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_PROFESSORS_LAB_ACCESS_DENIED"))
		end
		act.doer.sg:GoToState("idle")
	    end
	end
	return true
    end)

PROFESSORS_LAB_ENTER.priority = 1
PROFESSORS_LAB_ENTER.ghost_valid = true
PROFESSORS_LAB_ENTER.encumbered_valid = true

--AddAction(PROFESSORS_LAB_ENTER)

local type = "SCENE"
local component = "sdf_professors_lab_teleporter"
local testfn = function(inst, doer, target, actions)
    if inst:HasTag("sdf_professors_lab_teleporter") and doer:HasTag("sdf") then
	table.insert(target, ACTIONS.SDF_PROFESSORS_LAB_ENTER)
    end
end

AddComponentAction(type, component, testfn)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.SDF_PROFESSORS_LAB_ENTER, "sdf_professors_lab_in_pre"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.SDF_PROFESSORS_LAB_ENTER, "sdf_professors_lab_in_pre"))
AddStategraphActionHandler("wilsonghost", ActionHandler(ACTIONS.SDF_PROFESSORS_LAB_ENTER, "sdf_professors_lab_in_pre"))
AddStategraphActionHandler("wilsonghost_client", ActionHandler(ACTIONS.SDF_PROFESSORS_LAB_ENTER, "sdf_professors_lab_in_pre"))