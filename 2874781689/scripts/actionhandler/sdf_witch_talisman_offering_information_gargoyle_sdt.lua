GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Replace Shadow Talisman
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WITCH_TALISMAN_OFFERING_SHADOW_TALISMAN"
local name = STRINGS.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_SHADOW_TALISMAN


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.INFORMATION_ON == true then
	if act.doer.components.sdf_king_peregrin_quest:GetShadowTalismanFoundStatus() == true then

	    --play offering FX
	    SpawnPrefab("sanity_lower").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

	    --locate and spawn reward
	    act.target:DoTaskInTime(1.1, function()

		--play offering FX
		local x,_,z=act.target.Transform:GetWorldPosition()
		SpawnPrefab("sanity_raise").Transform:SetPosition(x,_,z)

		act.target:DoTaskInTime(0.5, function()
		    if act.target.INFORMATION_ON == true then

			--Shadow Talisman Restored
			act.target:DoTaskInTime(0.1, function()
			    local holder = act.doer ~= nil and (act.doer.components.inventory or act.doer.components.container) or nil
			    local shadowTalisman= SpawnPrefab("sdf_shadow_talisman")

			    --Destory all old Helmets
			    local oldShadowTalisman = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_shadow_talisman")
			    if oldShadowTalisman ~= nil then
				act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldShadowTalisman)
			    end

			    act.doer.components.sdf_key_item_inventory:SetKeyItem(shadowTalisman, act.doer)
			    if holder ~= nil then
				local slot = holder:GetItemSlot(act.invobject)
				act.invobject:Remove()
				holder:GiveItem(shadowTalisman, slot)
			    end
			end)

			if act.doer.components.talker then
			    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_WITCH_TALISMAN_OFFERING_SHADOW_TALISMAN"))
			end
		    end
		end)
	    end)
	    return true
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_witch_talisman_offering_information_gargoyle_sdt"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_witch_talisman_offering") and target:HasTag("sdf_information_gargoyle_7") then
	table.insert(actions, ACTIONS.SDF_WITCH_TALISMAN_OFFERING_SHADOW_TALISMAN)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_SHADOW_TALISMAN, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_SHADOW_TALISMAN,state))