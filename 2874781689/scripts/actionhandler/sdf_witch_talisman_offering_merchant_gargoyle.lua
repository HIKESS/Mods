GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Replace Gold Shield
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WITCH_TALISMAN_OFFERING_GOLD_SHIELD"
local name = STRINGS.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_GOLD_SHIELD


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.MERCHANT_ON == true then
	local usedChaliceCount = act.doer.components.sdf_chalice_counter:GetUsedChaliceCount()
	if usedChaliceCount > 10 then

	    --play offering FX
    	    SpawnPrefab("sanity_lower").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

	    --locate and spawn reward
    	    act.target:DoTaskInTime(1.1, function()

		--play offering FX
		local x,_,z=act.target.Transform:GetWorldPosition()
		SpawnPrefab("sanity_raise").Transform:SetPosition(x,_,z)

		act.target:DoTaskInTime(0.5, function()
		    if act.target.MERCHANT_ON == true then

			--Gold Shield Restored
			local doer_Inventory = act.doer.components.inventory
			local shieldSlot = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
			if shieldSlot then
			    act.target:DoTaskInTime(0.1, function()
				doer_Inventory:DropItem(shieldSlot)
				doer_Inventory:GiveItem(shieldSlot)

				local shieldSlot = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
				if shieldSlot == nil then

				    --Destory all old Gold Shield
				    local oldGoldShield = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_shield")
				    if oldGoldShield ~= nil then
					act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldShield)
				    end

				    local goldShield= SpawnPrefab("sdf_gold_shield")
				    goldShield.components.armor:SetPercent(0.2)
				    if goldShield ~= nil then
					--create ID
					act.doer.components.sdf_key_item_inventory:SetKeyItem(goldShield, act.doer)
					doer_Inventory:Equip(goldShield)
				    end
				end
			    end)
			else
			    act.target:DoTaskInTime(0.1, function()

				--Destory all old Gold Shield
				local oldGoldShield = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_shield")
				if oldGoldShield ~= nil then
				    act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldShield)
				end

				local goldShield= SpawnPrefab("sdf_gold_shield")
				goldShield.components.armor:SetPercent(0.2)
				if goldShield ~= nil then
				    --create ID
				    act.doer.components.sdf_key_item_inventory:SetKeyItem(goldShield, act.doer)
				    doer_Inventory:Equip(goldShield)
				end
			    end)
			end

			if act.doer.components.talker then
			    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_WITCH_TALISMAN_OFFERING_GOLD_SHIELD"))
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
local component = "sdf_witch_talisman_offering_merchant_gargoyle"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_witch_talisman_offering") and target:HasTag("sdf_merchant_gargoyle") then
	table.insert(actions, ACTIONS.SDF_WITCH_TALISMAN_OFFERING_GOLD_SHIELD)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_GOLD_SHIELD, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_GOLD_SHIELD,state))