GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Install Asgard Golem Optimize Data
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL"
local name = STRINGS.ACTIONHANDLER_SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL


local fn = function(act)

    if act.target.prefab == "sdf_asgard_golem" then

	--Asgard Golem Optimize Data Type A
	if act.invobject.prefab == "sdf_asgard_golem_optimize_data_type_a" then
	    local ODInstalled = act.target.components.sdf_asgard_golem_optimize_data:GetODTypeAInstalled()
	    --Already Installed
	    if ODInstalled == true then
		if act.doer.components.talker then
		    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_ASGARDGOLEMOPTIMIZEDATAINSTALLFAIL"),4)
		end
		return false
	    end

	    --Install Data FX
	    local x,_,z=act.target.Transform:GetWorldPosition()
	    SpawnPrefab("wx78_big_spark").Transform:SetPosition(x,_ - 1,z)
	    act.target.SoundEmitter:PlaySound("WX_rework/module/insert")

	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL, 4)
	    act.target.sg:GoToState("rocklick")

	    --Install Data FX
	    act.target.components.sdf_asgard_golem_optimize_data:SetODTypeAInstalled()

	    --Remove data item
	    act.invobject:Remove()

	    return true
	end

	--Asgard Golem Optimize Data Type C
	if act.invobject.prefab == "sdf_asgard_golem_optimize_data_type_c" then
	    local ODInstalled = act.target.components.sdf_asgard_golem_optimize_data:GetODTypeCInstalled()
	    --Already Installed
	    if ODInstalled == true then
		if act.doer.components.talker then
		    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_ASGARDGOLEMOPTIMIZEDATAINSTALLFAIL"),4)
		end
		return false
	    end

	    --Install Data FX
	    local x,_,z=act.target.Transform:GetWorldPosition()
	    SpawnPrefab("wx78_big_spark").Transform:SetPosition(x,_ - 1,z)
	    act.target.SoundEmitter:PlaySound("WX_rework/module/insert")

	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL, 4)
	    act.target.sg:GoToState("rocklick")

	    --Install Data FX
	    act.target.components.sdf_asgard_golem_optimize_data:SetODTypeCInstalled()

	    --Remove data item
	    act.invobject:Remove()

	    return true
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_asgard_golem_optimize_data_install"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_asgard_golem_optimize_data_install") then
	table.insert(actions, ACTIONS.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_INSTALL,state))