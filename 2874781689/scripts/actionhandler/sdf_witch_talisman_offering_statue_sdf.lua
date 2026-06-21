GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Replace Gold Armor
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WITCH_TALISMAN_OFFERING_GOLD_ARMOR"
local name = STRINGS.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_GOLD_ARMOR


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.STATUE_ACTIVATE == true then
	local heroEnabled = act.doer.components.sdf_chalice_id_lock:CheckHeroStatus()
	if heroEnabled == true then

	    --play offering FX
    	    SpawnPrefab("sanity_lower").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

	    --locate and spawn reward
    	    act.target:DoTaskInTime(1.1, function()

		--play offering FX
		local x,_,z=act.target.Transform:GetWorldPosition()
		SpawnPrefab("sanity_raise").Transform:SetPosition(x,_,z)

		act.target:DoTaskInTime(0.5, function()
		    --do fx
		    SpawnPrefab("fx_book_light_upgraded").Transform:SetPosition(act.target.Transform:GetWorldPosition())
		    SpawnPrefab("fx_book_light_upgraded").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

		    --Gold Armor Restored
		    act.target:DoTaskInTime(1.5, function()
			if act.target.STATUE_ACTIVATE == true then
			    local x,_,z = act.doer.Transform:GetWorldPosition()
			    SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)

			    act.target:DoTaskInTime(0.4, function()
				SpawnPrefab("spawn_fx_medium_static").Transform:SetPosition(x,_,z)

				act.target:DoTaskInTime(0.6, function()

				    --Equip Gold Armor
				    local doer_Inventory = act.doer.components.inventory
				    local bodySlot = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
				    if bodySlot then
					act.target:DoTaskInTime(0.1, function()
					    doer_Inventory:DropItem(bodySlot)
					    doer_Inventory:GiveItem(bodySlot)

					    local bodySlot = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
					    if bodySlot == nil then
						local goldArmor_id = math.random()
						local goldArmor = SpawnPrefab("sdf_gold_armor")
						goldArmor.components.armor:SetPercent(0.2)
						goldArmor.components.sdf_superarmor:DoDelta(-TUNING.SDF_SUPERARMOR_MAX, false, "sdf_gold_armor")
						act.doer.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)
						goldArmor.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)

						--Destory all old Gold Armor
						local oldGoldArmor = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_armor")
						if oldGoldArmor ~= nil then
						    act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldArmor)
						end

						--create ID
						act.doer.components.sdf_key_item_inventory:SetKeyItem(goldArmor, act.doer)
						doer_Inventory:Equip(goldArmor)
					    end
					end)
				    else
					act.target:DoTaskInTime(0.1, function()
					    local goldArmor_id = math.random()
					    local goldArmor = SpawnPrefab("sdf_gold_armor")
					    goldArmor.components.armor:SetPercent(0.2)
					    goldArmor.components.sdf_superarmor:DoDelta(-TUNING.SDF_SUPERARMOR_MAX, false, "sdf_gold_armor")
					    act.doer.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)
					    goldArmor.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)

					    --Destory all old Gold Armor
					    local oldGoldArmor = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_armor")
					    if oldGoldArmor ~= nil then
						act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldArmor)
					    end

					    --create ID
					    act.doer.components.sdf_key_item_inventory:SetKeyItem(goldArmor, act.doer)
					    doer_Inventory:Equip(goldArmor)
					end)
				    end

				    if act.doer.components.talker then
					act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_WITCH_TALISMAN_OFFERING_GOLD_ARMOR"))
				    end

				    act.target.STATUE_ACTIVATE = false
				    --Remove witch talisman
				    act.invobject:Remove()
				end)
			    end)
			end
		    end)
		end)
	    end)
	    return true
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_witch_talisman_offering_statue_sdf"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_witch_talisman_offering") and target:HasTag("sdf_statue_sdf") then
	table.insert(actions, ACTIONS.SDF_WITCH_TALISMAN_OFFERING_GOLD_ARMOR)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_GOLD_ARMOR, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_GOLD_ARMOR,state))