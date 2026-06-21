local _G = GLOBAL
Inv = require "widgets/inventorybar"
local actioninputstyle = GetModConfigData("sdf_action_input_style")

EQUIPSLOTS.SHIELD = "shield"

--Make shield slot
AddGlobalClassPostConstruct("widgets/inventorybar", "Inv", function(self, owner)
	self:AddEquipSlot(EQUIPSLOTS.SHIELD, "images/shield_slot_icon/shield_slot_icon.xml", "shield_slot_icon.tex",0)

    -- Fix the width of the background of the inventory bar.
    local Inv_Rebuild_Base = Inv.Rebuild
    function Inv:Rebuild()
        Inv_Rebuild_Base(self)

        local num_slots = self.owner.replica.inventory:GetNumSlots()
        local do_self_inspect = not (self.controller_build or GLOBAL.GetGameModeProperty("no_avatar_popup"))

        local total_w_default = self:CalcTotalWidth(num_slots, 3, 1)
        local total_w_real    = self:CalcTotalWidth(num_slots, #self.equipslotinfo, do_self_inspect and 1 or 0)
        local scale_default = 1.22 -- See `scripts/widgets/inventorybar.lua:261-262`.
        local scale_real = scale_default *  total_w_real / total_w_default
        self.bg:SetScale(scale_real, 1, 1)
        self.bgcover:SetScale(scale_real,1, 1)
    end

    function Inv:CalcTotalWidth(num_slots, num_equip, num_buttons)
        local W = 68
        local SEP = 12
        local INTERSEP = 28
        local num_slotintersep = math.ceil(num_slots / 5)
        local num_equipintersep = num_buttons > 0 and 1 or 0
        return (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP
    end
end)


--Shield Blocking
------------------------------------------------------------------------------------------------------------------------
local function ReticuleTargetFn()
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
            inst.components.reticule.reticuleprefab = "reticulearc"
	    inst.components.reticule.pingprefab = "reticulearcping"
            inst.components.reticule.targetfn = ReticuleTargetFn
	    inst.components.reticule.mousetargetfn = ReticuleMouseTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
	    inst.components.reticule.validcolour = { 1, .75, 0, 1 }
	    inst.components.reticule.invalidcolour = { .5, 0, 0, 1 }
	    inst.components.reticule.ease = true
	    inst.components.reticule.mouseenabled = true
	    inst.components.reticule.ispassableatallpoints = true
            if inst.components.playercontroller ~= nil and inst == ThePlayer then
                inst.components.playercontroller:RefreshReticule()
            end
        end
    elseif inst.components.reticule ~= nil then
        inst:RemoveComponent("reticule")
        if inst.components.playercontroller ~= nil and inst == ThePlayer then
            inst.components.playercontroller:RefreshReticule()
        end
    end
end
---------------------------------------------------------------------------------------------


AddModRPCHandler("SDFShield", "startblock", function(player)
    local shield = player.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)

    if shield and 
    (not player.components.rider or not player.components.rider:IsRiding()) and
    not player:HasTag("fishing_idle") and
    not player.sg:HasStateTag("busy") and not player.sg:HasStateTag("doing")
	then

	--Tag
	player:AddTag("sdf_shield_parry_action_active")

	if shield.components.rechargeable then
	   if shield.components.rechargeable:IsCharged() == false then
		return
	   end
	end

	--Switch to shield
	player.AnimState:OverrideSymbol("lantern_overlay", "swap_"..shield.prefab, "swap_shield")
	player.AnimState:OverrideSymbol("swap_shield", "swap_"..shield.prefab, "swap_shield")
	player.AnimState:Show("ARM_carry")
	player.AnimState:Show("lantern_overlay")
	player.AnimState:Hide("ARM_normal")
	player.AnimState:HideSymbol("swap_object")

        --Parry
	player:SDF_ShieldParryEnableFn()

	--Stop talking
	if player.components.talker then
	    player.components.talker:IgnoreAll()
	end

------------------------------------------------------

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

	--Hide cane stick Gentleman effect
	if handsItem and handsItem:HasTag("sdf_cane_stick_gentleman") then
	    if handsItem._gemSparkleFX ~= nil then
		handsItem._gemSparkleFX:Remove()
		handsItem._gemSparkleFX = nil
	    end
	end
    end
end)

AddModRPCHandler("SDFShield", "stopblock", function(player)
    local shield = player.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)

    if shield and 
    (not player.components.rider or not player.components.rider:IsRiding()) and
    not player:HasTag("fishing_idle") and not player.sg:HasStateTag("parrying")
    --not player.sg:HasStateTag("busy") and not player.sg:HasStateTag("doing")
	then

	--Tag
	if player:HasTag("sdf_shield_parry_action_active") then
	    player:RemoveTag("sdf_shield_parry_action_active")
	end

	--Remove Shield
	player.AnimState:ClearOverrideSymbol("lantern_overlay")
        player.AnimState:ClearOverrideSymbol("swap_shield")
	player.AnimState:Hide("LANTERN_OVERLAY")
	player.AnimState:ShowSymbol("swap_object")
	
	--stop parry
	player:SDF_ShieldParryRemoveFn()
	player:SDF_ShieldParryDisableFn()

	--start talking
	if player.components.talker then
	    player.components.talker:StopIgnoringAll()
	end

------------------------------------------------------------------------------------------------------
	--Switch back to hand
	local handsItem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsItem then
	    handsItem.components.equippable.onequipfn(handsItem, player)
	else
	    player.AnimState:Hide("ARM_carry")
	    player.AnimState:Show("ARM_normal")
	end	
    end
end)

--------------------------------------------------------------------------------------------
AddModRPCHandler("SDFShield", "stopblockother", function(player)
	--Tag
	if player:HasTag("sdf_shield_parry_action_active") then
	    player:RemoveTag("sdf_shield_parry_action_active")
	end

	--Remove Shield
	player.AnimState:ClearOverrideSymbol("lantern_overlay")
        player.AnimState:ClearOverrideSymbol("swap_shield")
	player.AnimState:Hide("LANTERN_OVERLAY")

	--stop parry
	player:SDF_ShieldParryRemoveFn()
	player:SDF_ShieldParryDisableFn()

	--Switch back to hand
	local handsItem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsItem then
	    handsItem.components.equippable.onequipfn(handsItem, player)
	else
	    player.AnimState:Hide("ARM_carry")
	    player.AnimState:Show("ARM_normal")
	end	
end)
--------------------------------------------------------------------------------------------

local function checkHandActions(player)
    local hands = player.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hands then
	if not hands.components.aoetargeting then
	    return true
	else
	    return false
	end
    end
    return true
end

local function checkRightActions(player)
    local actionRight = player.components.playercontroller:GetRightMouseAction()
    if actionRight == nil then
	return true
    end

    --check for action bypasses
    if actionRight and actionRight.action then
	if actionRight.action == ACTIONS.LOOKAT then
	    return true
	end
	return false
    end
    return false
end

--Shield Control Keybind
if actioninputstyle == true then--Dynamic Style
    TheInput:AddControlHandler(CONTROL_SECONDARY, function(down)
	if ThePlayer then
	    local shieldItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	    --local targetMouse = TheInput:GetWorldEntityUnderMouse() or nil
	    --local targetHUD = TheInput:GetHUDEntityUnderMouse() or nil
	    local canActionRight = checkRightActions(ThePlayer)

	    --Normal SDF Shields
	    if checkHandActions(ThePlayer) and shieldItem and shieldItem:HasTag("sdf_shield") and not ThePlayer:HasTag("sdf_daring_dash_action_active") then
		if down then
		    if canActionRight == true then --or (targetMouse ~= nil and targetMouse:HasTag("_combat")) or (targetMouse == nil and targetHUD == nil) then
			--check cooldown
			if shieldItem:HasTag("sdf_shield_parry") then
			    EnableReticule(ThePlayer, true)
			    shieldItem.components.aoetargeting:StartTargeting()
			end
			SendModRPCToServer(MOD_RPC["SDFShield"]["startblock"])
		    end
		else
		    --check cooldown
		    if shieldItem:HasTag("sdf_shield_parry") then
			EnableReticule(ThePlayer, false)
			if ThePlayer.sg and not ThePlayer.sg:HasStateTag("parrying") then
			    shieldItem.components.aoetargeting:StopTargeting()
			end
		    end
		    SendModRPCToServer(MOD_RPC["SDFShield"]["stopblock"])
		end
	    elseif checkHandActions(ThePlayer) then
		if not down then
		    if ThePlayer:HasTag("sdf_shield_parry_action_active") then
			EnableReticule(ThePlayer, false)
			ThePlayer:SDF_ShieldParryRemoveFn()
			ThePlayer:SDF_ShieldParryDisableFn()
			SendModRPCToServer(MOD_RPC["SDFShield"]["stopblockother"])
		    end
		end
	    end
	end
    end)
else
    TheInput:AddControlHandler(CONTROL_SECONDARY, function(down)
	if ThePlayer then
	    local shieldItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	    local targetMouse = TheInput:GetWorldEntityUnderMouse() or nil
	    local targetHUD = TheInput:GetHUDEntityUnderMouse() or nil
	    local canActionRight = checkRightActions(ThePlayer)

	    --Normal SDF Shields
	    if checkHandActions(ThePlayer) and shieldItem and shieldItem:HasTag("sdf_shield") and not ThePlayer:HasTag("sdf_daring_dash_action_active") and not (hands and hands.components.aoespell) then
		if not down then
		    if canActionRight == true and targetHUD == nil then --(targetMouse == nil or targetHUD == nil) then
			if not ThePlayer:HasTag("sdf_shield_parry_action_active") then
			    --check cooldown
			    if shieldItem:HasTag("sdf_shield_parry") then
				EnableReticule(ThePlayer, true)
				shieldItem.components.aoetargeting:StartTargeting()
			    end
			    SendModRPCToServer(MOD_RPC["SDFShield"]["startblock"])
			else
			    --check cooldown
			    if shieldItem:HasTag("sdf_shield_parry") then
				EnableReticule(ThePlayer, false)
				if ThePlayer.sg and not ThePlayer.sg:HasStateTag("parrying") then
				    shieldItem.components.aoetargeting:StopTargeting()
				end
			    end
			    SendModRPCToServer(MOD_RPC["SDFShield"]["stopblock"])
			end
		    else
			if ThePlayer:HasTag("sdf_shield_parry_action_active") then
			    --check cooldown
			    if shieldItem:HasTag("sdf_shield_parry") then
				EnableReticule(ThePlayer, false)
				if ThePlayer.sg and not ThePlayer.sg:HasStateTag("parrying") then
				    shieldItem.components.aoetargeting:StopTargeting()
				end
			    end
			    SendModRPCToServer(MOD_RPC["SDFShield"]["stopblock"])
			end
		    end
		end
	    elseif checkHandActions(ThePlayer) then
		if not down then
		    if ThePlayer:HasTag("sdf_shield_parry_action_active") then
			EnableReticule(ThePlayer, false)
			ThePlayer:SDF_ShieldParryRemoveFn()
			ThePlayer:SDF_ShieldParryDisableFn()
			SendModRPCToServer(MOD_RPC["SDFShield"]["stopblockother"])
		    end
		end
	    end
	end
    end)
end