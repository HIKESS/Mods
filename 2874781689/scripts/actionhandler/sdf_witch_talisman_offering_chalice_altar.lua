GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Reset Chalice Altar
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WITCH_TALISMAN_OFFERING_CHALICE_ALTAR"
local name = STRINGS.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_CHALICE_ALTAR


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.ALTAR_DISABLED == true then
	local chaliceLock = act.doer.components.sdf_chalice_id_lock:GetLock()
	local altarLock = act.doer.components.sdf_chalice_id_lock:GetAltarLock()
	local key = act.target.components.sdf_chalice_id_key:GetKey()

	if key == 0 then
	    return false
	end

	--Altar unlocking
	if act.doer.components.sdf_chalice_id_lock:CheckLock(chaliceLock,key) == false and act.doer.components.sdf_chalice_id_lock:CheckLock(altarLock,key) == true then

	    --play offering FX
    	    SpawnPrefab("sanity_lower").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

	    --locate and spawn reward
    	    act.target:DoTaskInTime(1.1, function()
		if act.target.ALTAR_DISABLED == true then
		    local altarLock = act.doer.components.sdf_chalice_id_lock:GetAltarLock()
		    local key = act.target.components.sdf_chalice_id_key:GetKey()

		    --play offering FX
		    local x,_,z=act.target.Transform:GetWorldPosition()
		    SpawnPrefab("sanity_raise").Transform:SetPosition(x,_,z)

		    --Reset Altar lock
		    act.doer.components.sdf_chalice_id_lock:RemoveLock(altarLock,key)
		    act.target.components.inspectable:SetDescription("A cup that is filled with ones heroism!\n"..(key).."th Altar.")

		    if act.doer.components.talker then
			act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_WITCH_TALISMAN_OFFERING_CHALICE_ALTAR"))
		    end

		    --check for souls
		    local chaliceFilledPercent = act.doer.components.sdf_souls:GetPercent()
		    if chaliceFilledPercent >= 1 then
			act.target.ALTAR_DISABLED = false
			act.target.ALTAR_CHALICEFILLED = true
			act.target.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)
			act.target.AnimState:PushAnimation("filled", true)
			SpawnPrefab("attune_out_fx").Transform:SetPosition(x,_,z)
		    else
			act.target.AnimState:PushAnimation("idle", true)
		    end

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
local component = "sdf_witch_talisman_offering_chalice_altar"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_witch_talisman_offering") and target:HasTag("sdf_chalice_altar") then
	table.insert(actions, ACTIONS.SDF_WITCH_TALISMAN_OFFERING_CHALICE_ALTAR)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_CHALICE_ALTAR, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_CHALICE_ALTAR,state))