--GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})


--Enter and Leave Enchanted Earth Tomb
local ENCHANTED_EARTH_TOMB_ENTER =
    AddAction("SDF_ENCHANTED_EARTH_TOMB_ENTER",STRINGS.ACTIONHANDLER_SDF_ENCHANTED_EARTH_TOMB_ENTER,function(act)
	--Enter Enchanted Earth Tomb
	if act.doer ~= nil then
	    if act.doer.sg ~= nil then
		if act.doer.sg.currentstate.name == "sdf_enchanted_earth_tomb_in_pre" then

		    --Well Vine is dead
		    if act.target ~= nil and (act.doer.components.inventory and act.doer.components.inventory:Has("sdf_shadow_artefact", 1, true)) then
			if act.target ~= nil and act.target.components.sdf_enchanted_earth_tomb_teleporter ~= nil and act.target.components.sdf_enchanted_earth_tomb_teleporter:IsActive() then
			    act.doer.sg:GoToState("sdf_enchanted_earth_tomb_jump", {sdf_enchanted_earth_tomb_teleporter = act.target})
			    return true
			end
		    end
		    act.doer.components.talker:Say(STRINGS.ANNOUNCE_SDF_ENCHANTED_EARTH_TOMB_ACCESS_DENIED)
		end
		act.doer.sg:GoToState("idle")
	    end
	end
	return true
    end)

ENCHANTED_EARTH_TOMB_ENTER.priority = 1
ENCHANTED_EARTH_TOMB_ENTER.ghost_valid = true
ENCHANTED_EARTH_TOMB_ENTER.encumbered_valid = true

--AddAction(ENCHANTED_EARTH_TOMB_ENTER)

local type = "SCENE"
local component = "sdf_enchanted_earth_tomb_teleporter"
local testfn = function(inst, doer, target, actions)
    if inst:HasTag("sdf_enchanted_earth_tomb_teleporter") then
	table.insert(target, ACTIONS.SDF_ENCHANTED_EARTH_TOMB_ENTER)
    end
end

AddComponentAction(type, component, testfn)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.SDF_ENCHANTED_EARTH_TOMB_ENTER, "sdf_enchanted_earth_tomb_in_pre"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.SDF_ENCHANTED_EARTH_TOMB_ENTER, "sdf_enchanted_earth_tomb_in_pre"))
AddStategraphActionHandler("wilsonghost", ActionHandler(ACTIONS.SDF_ENCHANTED_EARTH_TOMB_ENTER, "sdf_enchanted_earth_tomb_in_pre"))
AddStategraphActionHandler("wilsonghost_client", ActionHandler(ACTIONS.SDF_ENCHANTED_EARTH_TOMB_ENTER, "sdf_enchanted_earth_tomb_in_pre"))