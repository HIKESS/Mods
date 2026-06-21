local _G = GLOBAL
local armkeybind = GetModConfigData("sdf_dans_arm_keybind")

local function IsDefaultScreen()
	return _G.ThePlayer and _G.ThePlayer ~= nil
		and _G.ThePlayer.components.playercontroller:IsEnabled()
		and _G.TheFrontEnd:GetActiveScreen().name == "HUD"
		and not _G.ThePlayer.HUD:IsChatInputScreenOpen()
		and not _G.ThePlayer.HUD:IsConsoleScreenOpen()
		and not _G.ThePlayer.HUD:IsCraftingOpen()
		and not _G.ThePlayer.HUD.writeablescreen
end
------------------------------------------------------------------------------------------------------------------------

AddModRPCHandler("sdf_dans_arm", "equiparm", function(player)
    if not player.sg:HasStateTag("busy") and not player.sg:HasStateTag("doing") then

	--Animation
	player:PushEvent("emote", { anim = "emoteXL_bonesaw", mounted = true, mountsound = "angry" })

	--Spawn Arm mid Animation
	player:DoTaskInTime(0.1, function()
	    if player.AnimState:IsCurrentAnimation("emoteXL_bonesaw") then
		player:DoTaskInTime(player.AnimState:GetCurrentAnimationLength() /2, function()
		    if player.AnimState:IsCurrentAnimation("emoteXL_bonesaw") then
			--stop animation
			player.sg:GoToState("idle", true)

			--create arm
			local newArm = SpawnPrefab("sdf_arm")
			player.components.inventory:Equip(newArm)
		    end
		end)
	    end
	end)
    end
end)

AddModRPCHandler("sdf_dans_arm", "unequiparm", function(player)
    local handsItem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local owner_Inventory = player.components.inventory

    --Can't Spawn During arm Spawn
    if not player.AnimState:IsCurrentAnimation("emoteXL_bonesaw") then

	--Remove Arm
	if owner_Inventory ~= nil then
	    owner_Inventory:Unequip(EQUIPSLOTS.HANDS)
	else
	    handsItem:Remove()
	end
    end
end)


--Arm Control Keybind
if armkeybind ~= "None" then
    local arm_keybind = _G["KEY_"..armkeybind]

    TheInput:AddKeyUpHandler(arm_keybind, function()
	if IsDefaultScreen() then
	    if ThePlayer then
		if ThePlayer.prefab == "sdf" then
		    local shieldItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		    local handsItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		    local targetHUD = TheInput:GetHUDEntityUnderMouse() or nil

		    --Check for Thrown or Shield or Targeting
		    if ThePlayer:HasTag("sdf_thrown_arm") then
			ThePlayer.components.talker:Say(GetString(ThePlayer, "ANNOUNCE_SDF_ARM_NO_EQUIP_THROWN"))
			return
		    end

		    if shieldItem then
			ThePlayer.components.talker:Say(GetString(ThePlayer, "ANNOUNCE_SDF_ARM_NO_EQUIP_SHIELD"))
			return
		    end

		    if targetHUD then
			return
		    end

		    --Check for Dans Arm or other Hand Item
		    if handsItem then
			if handsItem.prefab == "sdf_arm" then
			    SendModRPCToServer(MOD_RPC["sdf_dans_arm"]["unequiparm"])
			else
			    ThePlayer.components.talker:Say(GetString(ThePlayer, "ANNOUNCE_SDF_ARM_NO_EQUIP_HAND"))
			    return
			end
		    else
			SendModRPCToServer(MOD_RPC["sdf_dans_arm"]["equiparm"])
		    end
		end
	    end
	end
    end)
end