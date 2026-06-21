GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Replace Anubis Stone Part 2
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART2"
local name = STRINGS.ACTIONHANDLER_SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART2


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.INFORMATION_ON == true then
	if act.doer.components.sdf_anubis_stone_quest:GetAnubisStonePart2FoundStatus() == true then

	    --play offering FX
	    SpawnPrefab("sanity_lower").Transform:SetPosition(act.doer.Transform:GetWorldPosition())

	    --locate and spawn reward
	    act.target:DoTaskInTime(1.1, function()

		--play offering FX
		local x,_,z=act.target.Transform:GetWorldPosition()
		SpawnPrefab("sanity_raise").Transform:SetPosition(x,_,z)

		act.target:DoTaskInTime(0.5, function()
		    if act.target.INFORMATION_ON == true then

			--Anubis Stone Part Restored
			act.target:DoTaskInTime(0.1, function()
			    local holder = act.doer ~= nil and (act.doer.components.inventory or act.doer.components.container) or nil
			    local aSPart= SpawnPrefab("sdf_anubis_stone_part2")

			    --Destory all old Anubis Stone Part
			    local oldAnubisStonePart = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_anubis_stone_part2")
			    if oldAnubisStonePart ~= nil then
				act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldAnubisStonePart)
			    end

			    act.doer.components.sdf_key_item_inventory:SetKeyItem(aSPart, act.doer)
			    if holder ~= nil then
				local slot = holder:GetItemSlot(act.invobject)
				act.invobject:Remove()
				holder:GiveItem(aSPart, slot)
			    end
			end)

			if act.doer.components.talker then
			    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART2"))
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
local component = "sdf_witch_talisman_offering_information_gargoyle_pg"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_witch_talisman_offering") and target:HasTag("sdf_information_gargoyle_5") then
	table.insert(actions, ACTIONS.SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART2)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART2, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_WITCH_TALISMAN_OFFERING_ANUBIS_STONE_PART2,state))