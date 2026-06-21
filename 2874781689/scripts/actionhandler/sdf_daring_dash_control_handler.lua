local _G = GLOBAL
local daringdashkeybind = GetModConfigData("sdf_daring_dash_keybind")
local actioninputstyle = GetModConfigData("sdf_action_input_style")

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
local function ReticuleTargetFn()
    --Cast range is 8, leave room for error (6.5 lunge)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleMouseTargetFn(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 6.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end
------------------------------------------------------------------------------------------------------------------------
local function EnableReticule(inst, enable)
    if enable then
        if inst.components.reticule == nil then
            inst:AddComponent("reticule")
            inst.components.reticule.reticuleprefab = "reticuleline"
	    inst.components.reticule.pingprefab = "reticulelineping"
            inst.components.reticule.targetfn = ReticuleTargetFn
	    inst.components.reticule.mousetargetfn = ReticuleMouseTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
	    inst.components.reticule.validcolour = { 1, .75, 0, 1 }
	    inst.components.reticule.invalidcolour = { .5, 0, 0, 1 }
	    inst.components.reticule.ease = true
	    inst.components.reticule.mouseenabled = true
            if inst.components.playercontroller ~= nil and inst == ThePlayer then
                inst.components.playercontroller:RefreshReticule()
            end
        end
    elseif inst.components.reticule ~= nil then
	--inst:DoTaskInTime(0.1, function()
        inst:RemoveComponent("reticule")
        if inst.components.playercontroller ~= nil and inst == ThePlayer then
            inst.components.playercontroller:RefreshReticule()
        end
	--end)
    end
end
---------------------------------------------------------------------------------------------


AddModRPCHandler("daring_dash", "startdaringdash", function(player)
    local shield = player.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
    if shield and 
    (not player.components.rider or not player.components.rider:IsRiding()) and
    not player:HasTag("fishing_idle") and
    not player.sg:HasStateTag("busy") and not player.sg:HasStateTag("doing")
	then

	--Tag
	player:AddTag("sdf_daring_dash_action_active")

	--Switch to shield
	player.AnimState:OverrideSymbol("lantern_overlay", "swap_"..shield.prefab, "swap_shield")
	player.AnimState:OverrideSymbol("swap_shield", "swap_"..shield.prefab, "swap_shield")
	player.AnimState:Show("ARM_carry")
	player.AnimState:Show("lantern_overlay")
	player.AnimState:Hide("ARM_normal")
	player.AnimState:HideSymbol("swap_object")

	--Skill Tree Daring Dash
	if player.prefab == "sdf" then

	    --Skill Tree Daring Dash
	    if player.components.skilltreeupdater:IsActivated("sdf_backbone_1") then
		player:SkilltreeDaringDashEnableFn()
	    end
	end

	--Remove torch like effects while guarding
	local handsItem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsItem and handsItem:HasTag("lighter") then
	    if handsItem.fires ~= nil then
		for i, fx in ipairs(handsItem.fires) do
		    fx:Remove()
		end
		handsItem.fires = nil
	    end
	end
	if handsItem and (handsItem:HasTag("lighter") or handsItem:HasTag("sdf_lightning_gauntlet")) then
	    if handsItem.fires ~= nil then
		for i, fx in ipairs(handsItem.fires) do
		    fx:Remove()
		end
		handsItem.fires = nil
	    end
	end

	--Hide cane stick Gentleman effect
	if handsItem and handsItem:HasTag("sdf_cane_stick_gentleman") then
	    if handsItem._gemSparkleFX ~= nil then
		handsItem._gemSparkleFX:Remove()
		handsItem._gemSparkleFX = nil
	    end
	end
    end
end)

AddModRPCHandler("daring_dash", "stopdaringdash", function(player)
    local shield = player.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
    if shield and 
    (not player.components.rider or not player.components.rider:IsRiding()) and
    not player:HasTag("fishing_idle") --and
    --not player.sg:HasStateTag("busy") and not player.sg:HasStateTag("doing")
	then

	--Tag
	if player:HasTag("sdf_daring_dash_action_active") then
	    player:RemoveTag("sdf_daring_dash_action_active")
	end

	--Remove Shield
	player.AnimState:ClearOverrideSymbol("lantern_overlay")
        player.AnimState:ClearOverrideSymbol("swap_shield")
	player.AnimState:Hide("LANTERN_OVERLAY")
	player.AnimState:ShowSymbol("swap_object")
	
	--Skill Tree Daring Dash
	if player.prefab == "sdf" then
	    if player.components.skilltreeupdater:IsActivated("sdf_backbone_1") then
		player:SkilltreeDaringDashRemoveFn()
		player:SkilltreeDaringDashDisableFn()
	    end
	end

	--Switch back to hand
	local handsItem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if (handsItem and handsItem.prefab ~= "sdf_dragon_potion_dragonbreath") then
	    handsItem.components.equippable.onequipfn(handsItem, player)
	else
	    player.AnimState:Hide("ARM_carry")
	    player.AnimState:Show("ARM_normal")
	end
	
	--Add torch like effects back to sdf_club
	local handsItem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsItem and handsItem.prefab == "sdf_club" and handsItem.components.burnable:IsBurning() then
	    player.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
	    if handsItem.fires == nil then
		handsItem.fires = {}

		local fx = SpawnPrefab("torchfire")
		fx.entity:SetParent(player.entity)
		fx.entity:AddFollower()
		fx.Follower:FollowSymbol(player.GUID, "swap_object", 10, -200, 0)
		fx:AttachLightTo(player)

		table.insert(handsItem.fires, fx)
	    end
	end
    end
end)


--Daring Dash Control Keybind
if daringdashkeybind ~= "None" then
    local daring_dash_keybind = _G["KEY_"..daringdashkeybind]

if actioninputstyle == true then--Dynamic Style
    TheInput:AddKeyHandler(function(key, down)
	if IsDefaultScreen() and key == daring_dash_keybind then
	    if ThePlayer then
		if ThePlayer.components.skilltreeupdater:IsActivated("sdf_backbone_1") then
		    local shieldItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		    local targetHUD = TheInput:GetHUDEntityUnderMouse() or nil

		    --Normal SDF Shields
		    if shieldItem and shieldItem:HasTag("sdf_shield") and not ThePlayer:HasTag("sdf_shield_parry_action_active") then
			if down then
			    if targetHUD == nil then
				EnableReticule(ThePlayer, true)
				SendModRPCToServer(MOD_RPC["daring_dash"]["startdaringdash"])
			    end
			else
			    --if ThePlayer:HasTag("sdf_daring_dash_action_active") then
			    EnableReticule(ThePlayer, false)
			    SendModRPCToServer(MOD_RPC["daring_dash"]["stopdaringdash"])
			end
		    --Unlocks sticky spamming of Daring Dash and Shield Parry
		    elseif shieldItem and shieldItem:HasTag("sdf_shield") and ThePlayer:HasTag("sdf_shield_parry_action_active") then
			if ThePlayer:HasTag("sdf_daring_dash_action_active") then
			    EnableReticule(ThePlayer, false)
			    if ThePlayer.sg and not ThePlayer.sg:HasStateTag("parrying") then
				shieldItem.components.aoetargeting:StopTargeting()
			    end
			    SendModRPCToServer(MOD_RPC["daring_dash"]["stopdaringdash"])
			end
		    end
		end
	    end
	end
    end)
else --Toggle Style
    TheInput:AddKeyUpHandler(daring_dash_keybind, function()
	if IsDefaultScreen() then
	    if ThePlayer then
		if ThePlayer.components.skilltreeupdater:IsActivated("sdf_backbone_1") then
		    local shieldItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		    local targetHUD = TheInput:GetHUDEntityUnderMouse() or nil

		    --Normal SDF Shields
		    if shieldItem and shieldItem:HasTag("sdf_shield") and not ThePlayer:HasTag("sdf_shield_parry_action_active") then
			if targetHUD == nil then
			    if not ThePlayer:HasTag("sdf_daring_dash_action_active") then
				EnableReticule(ThePlayer, true)
				SendModRPCToServer(MOD_RPC["daring_dash"]["startdaringdash"])
			    else
				EnableReticule(ThePlayer, false)
				SendModRPCToServer(MOD_RPC["daring_dash"]["stopdaringdash"])
			    end
			end
		    --Unlocks sticky spamming of Daring Dash and Shield Parry
		    elseif shieldItem and shieldItem:HasTag("sdf_shield") and ThePlayer:HasTag("sdf_shield_parry_action_active") then
			if ThePlayer:HasTag("sdf_daring_dash_action_active") then
			    EnableReticule(ThePlayer, false)
			    if ThePlayer.sg and not ThePlayer.sg:HasStateTag("parrying") then
				shieldItem.components.aoetargeting:StopTargeting()
			    end
			    SendModRPCToServer(MOD_RPC["daring_dash"]["stopdaringdash"])
			end
		    end
		end
	    end
	end
    end)
end
end