GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Replace Dans Helmet
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WITCH_TALISMAN_OFFERING_HELMET"
local name = STRINGS.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_HELMET


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.INFORMATION_ON == true then
	if TUNING.SDF_FATES_ARROW == false then

	    --play offering FX
	    SpawnPrefab("sanity_lower").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

	    --locate and spawn reward
	    act.target:DoTaskInTime(1.1, function()

		--play offering FX
		local x,_,z=act.target.Transform:GetWorldPosition()
		SpawnPrefab("sanity_raise").Transform:SetPosition(x,_,z)

		act.target:DoTaskInTime(0.5, function()
		    if act.target.INFORMATION_ON == true then

			--Helmet Restored
			local doer_Inventory = act.doer.components.inventory
			local helmSlot = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			if helmSlot then
			    act.target:DoTaskInTime(0.1, function()
				doer_Inventory:DropItem(helmSlot)
				doer_Inventory:GiveItem(helmSlot)

				local helmSlot = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
				if helmSlot == nil then

				    --Destory all old Helmets
				    local oldHelmet = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_helmet")
				    if oldHelmet ~= nil then
					act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldHelmet)
				    end

				    local danHelm= SpawnPrefab("sdf_helmet")
				    if danHelm ~= nil then
					--create ID
					act.doer.components.sdf_key_item_inventory:SetKeyItem(danHelm, act.doer)
					doer_Inventory:Equip(danHelm)
				    end
				end
			    end)
			else
			    act.target:DoTaskInTime(0.1, function()

				--Destory all old Helmets
				oldHelmet = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_helmet")
				if oldHelmet ~= nil then
				    act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldHelmet, act.doer)
				end

				local danHelm= SpawnPrefab("sdf_helmet")
				if danHelm ~= nil then
				    --create ID
				    act.doer.components.sdf_key_item_inventory:SetKeyItem(danHelm, act.doer)
				    doer_Inventory:Equip(danHelm)
				end
			    end)
			end

			if act.doer.components.talker then
			    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_WITCH_TALISMAN_OFFERING_HELMET"))
			end

			--Remove witch talisman
			act.invobject:Remove()
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
local component = "sdf_witch_talisman_offering_information_gargoyle_spawn"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_witch_talisman_offering") and target:HasTag("sdf_information_gargoyle_0") then
	table.insert(actions, ACTIONS.SDF_WITCH_TALISMAN_OFFERING_HELMET)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_HELMET, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_HELMET,state))