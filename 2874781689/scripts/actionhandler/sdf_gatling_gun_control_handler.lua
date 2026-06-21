local c_rep = require("components/combat_replica")
local _CanTarget = c_rep.CanTarget

local function ShouldKeepShooting(player)
    if player.components.playercontroller ~= nil and
	(player.components.playercontroller:IsAnyOfControlsPressed(GLOBAL.CONTROL_PRIMARY) or
	player.components.playercontroller:IsAnyOfControlsPressed(GLOBAL.CONTROL_CONTROLLER_ACTION)) then
	return true
    else
	return false
    end
end

local function SetGatlingGunAimPosition(player, pos_x, pos_y, pos_z)
    if player ~= nil and pos_x ~= nil then
	player.sdf_gatling_gun_cached_aiming_point = GLOBAL.Vector3(pos_x, pos_y, pos_z)
    end
end

c_rep.CanTarget = function(self, target)
    if self.inst:HasTag("has_sdf_gatling_gun") then
	return false
    else
	return _CanTarget(self, target)
    end
end

local function CannotExamine(inst)
    return false
end

--Gatling Gun Target Checks
local function isalive(ent)
    local health = ent.replica.health ~= nil and ent.replica.health or ent.components.health ~= nil and ent.components.health or nil
    return health ~= nil and not health:IsDead() and true or false
end

local function isplayerfollower(ent)
    local follower = ent.replica.follower ~= nil and ent.replica.follower or ent.components.follower ~= nil and ent.components.follower or nil
    return follower ~= nil and follower:GetLeader() ~= nil and follower:GetLeader():HasTag("player") and true or false
end

local function isphysicalobject(ent)
    return ent.Physics ~= nil and ent.Physics:GetRadius() > 0 and true or false
end

function GLOBAL.SDFGatling_Gun_IsBossEnemy(ent) --TF2IsBossEnemy(ent)
    return ent:HasTag("epic") and isalive(ent) and true or false
end

function GLOBAL.SDFGatling_Gun_IsLivingCreature(ent)
    return not isplayerfollower(ent) and isalive(ent) and
	(ent:HasTag("animal")
	or ent:HasTag("character")
	or ent:HasTag("monster")
	or ent:HasTag("insect")
	or ent:HasTag("smallcreature")
	or ent:HasTag("bird")
	or ent:HasTag("hostile"))
end

function GLOBAL.SDFGatling_Gun_IsValidGatlingGunTarget(ent)
    if GLOBAL.SDFGatling_Gun_IsBossEnemy(ent) or GLOBAL.SDFGatling_Gun_IsLivingCreature(ent) then
	return true
    end
	
    if ent:HasTag("SDF_Totem_Target") or ent:HasTag("SDF_Floating_Target") then
	return true
    elseif ent:HasTag("CHOP_workable") or ent:HasTag("MINE_workable") or (ent:HasTag("HAMMER_workable") and not ent:HasTag("structure")) then
	return true
    elseif ent:HasTag("pickable") and isphysicalobject(ent) then
	return true
    elseif ent:HasTag("beehive") or ent:HasTag("playerskeleton") or ent.prefab ~= nil and (ent.prefab == "skeleton" or ent.prefab == "scorched_skeleton") then
	return true
    elseif GLOBAL.TheNet:GetPVPEnabled() == true and ent:HasTag("structure") then
	return true
    end
	
    return false
end

--Disable highlighting on player
local function HighlightPostInit(self)
    local _Highlight = self.Highlight
    self.Highlight = function(self, r, g, b, ...)
	if GLOBAL.ThePlayer ~= nil and GLOBAL.ThePlayer:HasTag("has_sdf_gatling_gun") then
	    self:UnHighlight()
	    return
	end
	return _Highlight(self, r, g, b, ...)
    end
end
AddComponentPostInit("highlight", HighlightPostInit)

local function ReticuleUpdateColourPostInit(reticule)
    local _UpdateColour = reticule.UpdateColour
    reticule.UpdateColour = function(self, ...)
	if self.is_tfminigun then
	    self.reticule.AnimState:SetMultColour(self.currentcolour[1], self.currentcolour[2], self.currentcolour[3], self.currentcolour[4])
	else
	    _UpdateColour(self, ...)
	end
    end
end
AddComponentPostInit("reticule", ReticuleUpdateColourPostInit)
------------------------------------------------------------------------------------------------------------------------
local function ReticuleTargetFn()
    return Vector3(GLOBAL.ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
	
    if GLOBAL.TheInput:GetHUDEntityUnderMouse() ~= nil and reticule.previous_rotation ~= nil then
	return
    end
	
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
	
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
    reticule.previous_rotation = rot
end

local function ReticuleMouseTargetFn(inst, mousepos)
    local mouseover = GLOBAL.TheInput:GetWorldEntityUnderMouse()
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
------------------------------------------------------------------------------------------------------------------------
local function EnableReticule(inst, enable)
    local inv = inst.replica.inventory ~= nil and inst.replica.inventory or inst.components.inventory ~= nil and inst.components.inventory
    local minigun = inv and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("sdf_gatling_gun") and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if minigun and enable then
	if inst.components.playercontroller ~= nil and inst == GLOBAL.ThePlayer then
	    minigun.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
	    minigun.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
	    minigun.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
	    minigun.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
	    minigun.components.aoetargeting:StartTargeting()

	    --Remove Player Examine
	    if not TheWorld.ismastersim then
		inst.CanExamine = CannotExamine
	    end
	end
    else
	local _reticule = inst.components.playercontroller ~= nil and inst.components.playercontroller.reticule ~= nil and inst.components.playercontroller.reticule or nil
	local valid_reticule = _reticule ~= nil and _reticule.inst ~= nil and _reticule.inst.components.aoetargeting ~= nil and true or false
        if minigun and valid_reticule and inst == GLOBAL.ThePlayer then
	    inst.components.playercontroller.reticule.inst.components.aoetargeting:StopTargeting()
        end

	--Restore Player Examine
	if not TheWorld.ismastersim then
	    inst.CanExamine = nil
	end
    end
end
---------------------------------------------------------------------------------------------


AddModRPCHandler("SDFGatlingGun", "GatlingGunAiming_RPC", SetGatlingGunAimPosition)
---------------------------------------------------------------------------------------------


AddPlayerPostInit(function(inst)
    --Enable Reticule Control
    inst:DoPeriodicTask(.1, function(inst)
	if inst.replica.inventory ~= nil and inst.replica.inventory:EquipHasTag("sdf_gatling_gun") or inst.components.inventory ~= nil and inst.components.inventory:EquipHasTag("sdf_gatling_gun") then
	    EnableReticule(inst, true)
	else
	    EnableReticule(inst, false)
	end
    end)

    --Allows Gatling Gun Turning.
    inst:AddComponent("sdf_gatling_gun_weapon_aiming_helper")
	
    if GLOBAL.TheWorld.ismastersim then
	if inst.components.sdf_gatling_gun_weapon_aiming_helper ~= nil then
	    inst:RemoveComponent("sdf_gatling_gun_weapon_aiming_helper")
	end
    end
end)

local function PlayerControllerPostInit(playercontroller)
    local _IsAOETargeting = playercontroller.IsAOETargeting
    playercontroller.IsAOETargeting = function(self, ...)
	if self.inst:HasTag("has_sdf_gatling_gun") then
	    return false
	else
	    return _IsAOETargeting(self, ...)
	end	
    end
	
    local _HasAOETargeting= playercontroller.HasAOETargeting
    playercontroller.HasAOETargeting = function(self, ...)
	if self.inst:HasTag("has_sdf_gatling_gun") then
	    return false
	else
	    return _HasAOETargeting(self, ...)
	end
    end
end
AddComponentPostInit("playercontroller", PlayerControllerPostInit)

--Disable other actions while holding a gatling gun
local function PlayerControllerActionButtonPostInit(playercontroller)
    local _DoActionButton = playercontroller.DoActionButton
    playercontroller.DoActionButton = function(self, ...)
	
	if self.inst:HasTag("has_sdf_gatling_gun") then
	    return 
	end
		
	return _DoActionButton(self, ...)
    end
	
    local _OnRemoteActionButton = playercontroller.OnRemoteActionButton
    playercontroller.OnRemoteActionButton = function(self, actioncode, target, isreleased, noforce, mod_name, ...)
	
	if self.inst:HasTag("has_sdf_gatling_gun") then
	    return
	end
		
	return _OnRemoteActionButton(self, actioncode, target, isreleased, noforce, mod_name, ...)
    end
end
AddComponentPostInit("playercontroller", PlayerControllerActionButtonPostInit)


--"Shoot" action while hovering over ocean
local function LeftClickShooter(inst, target, position)
    local inv = inst ~= nil and (inst.replica ~= nil and inst.replica.inventory ~= nil and inst.replica.inventory or inst.components ~= nil and inst.components.inventory ~= nil and inst.components.inventory) or nil
	
    if position ~= nil and inv ~= nil and inv:GetActiveItem() ~= nil and inv:GetActiveItem():HasTag("sdf_gatling_gun") then
	if target == nil then
	    return inst.components.playeractionpicker:SortActionList({ ACTIONS.DROP }, position, inv:GetActiveItem())
	elseif inst ~= nil and target ~= nil and target == inst then
	    return inst.components.playeractionpicker:SortActionList({ ACTIONS.EQUIP }, position, inv:GetActiveItem())
	end
    end

    if inst ~= nil and position ~= nil and (inv == nil or inv ~= nil and inv:GetActiveItem() == nil) then
	local dist = inst:GetDistanceSqToPoint(position.x, position.y, position.z)
	if dist >= 1.25 then
	    return inst.components.playeractionpicker:SortActionList({ ACTIONS.SDFGATLING_GUN_SHOOT }, position)
	end
    end
	
    return {}, true
end

--"Unequip" action appearing when hovering over entities
local function RightClickUnequipper(inst, target, useitem)
    local inv = inst ~= nil and (inst.replica ~= nil and inst.replica.inventory ~= nil and inst.replica.inventory or inst.components ~= nil and inst.components.inventory ~= nil and inst.components.inventory) or nil

    if inv ~= nil and inv:GetActiveItem() ~= nil and (inv:GetActiveItem().replica ~= nil and inv:GetActiveItem().replica.equippable ~= nil or inv:GetActiveItem().components ~= nil and inv:GetActiveItem().components.equippable ~= nil) then
	return {}
    end

    if inst ~= nil and target ~= nil and target ~= inst and (inv == nil or inv ~= nil and inv:GetActiveItem() == nil) then
	return inst.components.playeractionpicker:SortActionList({ ACTIONS.SDFGATLING_GUN_UNEQUIP }, target)
    end
	
    return {}, true
end

---------------------------------------------------------------------------------------------
--Setup Action Control
AddPlayerPostInit(function(inst)
    inst.sdf_gatling_gun_equip_state = "unequipped"
    inst.sdf_gatling_gun_equip_state_tracker_task = nil
	
    inst:DoTaskInTime(1, function(inst)
	if inst.sdf_gatling_gun_equip_state_tracker_task ~= nil then
	    return
	end
		
	inst.sdf_gatling_gun_equip_state_tracker_task = inst:DoPeriodicTask(.1, function(inst)
	    local inv = inst ~= nil and inst.replica ~= nil and inst.replica.inventory ~= nil and inst.replica.inventory or inst ~= nil and inst.components ~= nil and inst.components.inventory ~= nil and inst.components.inventory or nil
	    local handitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	    local holds_minigun = handitem ~= nil and handitem:HasTag("sdf_gatling_gun") or false
			
	    if inst.sdf_gatling_gun_equip_state == "unequipped" and holds_minigun and inst.components.playeractionpicker ~= nil then
		inst.components.playeractionpicker.leftclickoverride = LeftClickShooter
		inst.components.playeractionpicker.rightclickoverride = RightClickUnequipper
		inst.sdf_gatling_gun_equip_state = "equipped"
				
	    elseif inst.sdf_gatling_gun_equip_state == "equipped" and not holds_minigun and inst.components.playeractionpicker ~= nil then
		inst.components.playeractionpicker.leftclickoverride = nil
		inst.components.playeractionpicker.rightclickoverride = nil
		inst.sdf_gatling_gun_equip_state = "unequipped"
	    end
	end)
    end)
end)

---------------------------------------------------------------------------------------------
--Gatling Gun Actions
--Shoot Action
STRINGS.ACTIONS.SDFGATLING_GUN_SHOOT = {
    GENERIC = "Shoot",
    KEEPSHOOTING = "Keep shooting",
}

local function ReturnTrue()
    return true
end

local SDFGATLING_GUN_SHOOT = GLOBAL.Action({ priority = 10, distance = 99, is_relative_to_platform = true, disable_platform_hopping = true, customarrivecheck = ReturnTrue })	
SDFGATLING_GUN_SHOOT.str = STRINGS.ACTIONHANDLER_SDF_GATLING_GUN_BARRAGE
SDFGATLING_GUN_SHOOT.id = "SDFGATLING_GUN_SHOOT"
SDFGATLING_GUN_SHOOT.strfn = function(act)
    return act.doer ~= nil and act.doer:HasTag("sdf_gatling_gun_shooting") and "KEEPSHOOTING" or nil
end

SDFGATLING_GUN_SHOOT.fn = function(act)
    local tar = act.target
    local act_pos = act:GetActionPoint()
	
    if act_pos and act.doer and act.invobject and act.invobject.components.sdf_gatling_gun_weapon then
	act.invobject.components.sdf_gatling_gun_weapon:Shoot(act_pos, nil, act.doer) -- point, target, shooter
	return true
		
    elseif tar and act.doer then
        local gun = act.doer.components.inventory
	    and act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil
	    and act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("sdf_gatling_gun")
	    and act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			
	if gun and gun.components.sdf_gatling_gun_weapon then
	    gun.components.sdf_gatling_gun_weapon:Shoot(nil, tar, act.doer) -- point, target, shooter
	end
	return true
    end
	
    local inv = act.doer ~= nil and act.doer.replica.inventory ~= nil and act.doer.replica.inventory or act.doer.components.inventory ~= nil and act.doer.components.inventory or nil
    local handitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    local holds_minigun = handitem ~= nil and handitem:HasTag("sdf_gatling_gun") or false
	
    if act_pos ~= nil and holds_minigun then
	return true
    end

end
AddAction(SDFGATLING_GUN_SHOOT)

AddComponentAction("POINT", "sdf_gatling_gun_weapon", function(inst, doer, pos, actions, right)
    if not right and (doer:HasTag("has_sdf_gatling_gun") or doer.replica.inventory and doer.replica.inventory:EquipHasTag("sdf_gatling_gun")) then
        local dist = doer:GetDistanceSqToPoint(pos.x, pos.y, pos.z)
	local not_riding = doer.replica.rider and not doer.replica.rider:IsRiding()
	if dist >= 1.25 and not_riding then --1.1
	    table.insert(actions, ACTIONS.SDFGATLING_GUN_SHOOT)
	end
    end
end)

AddComponentAction("EQUIPPED", "sdf_gatling_gun_weapon", function(inst, doer, target, actions, right)
    if not right and (doer:HasTag("has_sdf_gatling_gun") or doer.replica.inventory and doer.replica.inventory:EquipHasTag("sdf_gatling_gun")) and target and target ~= doer then
	local not_riding = doer.replica.rider and not doer.replica.rider:IsRiding()
	if not_riding then
	    table.insert(actions, ACTIONS.SDFGATLING_GUN_SHOOT)
	end
    end
end)

local sdfgatling_gun_shoot_handler = ActionHandler(ACTIONS.SDFGATLING_GUN_SHOOT, "sdfgatling_gun_shoot")
AddStategraphActionHandler("wilson", sdfgatling_gun_shoot_handler)

local sdfgatling_gun_shoot_handler_client = ActionHandler(ACTIONS.SDFGATLING_GUN_SHOOT, "sdfgatling_gun_shoot")
AddStategraphActionHandler("wilson_client", sdfgatling_gun_shoot_handler_client)


--Unequip Action
local SDFGATLING_GUN_UNEQUIP = GLOBAL.Action({ priority = 9, distance = 99, instant = true })	
SDFGATLING_GUN_UNEQUIP.str = "Unequip"
SDFGATLING_GUN_UNEQUIP.id = "SDFGATLING_GUN_UNEQUIP"

SDFGATLING_GUN_UNEQUIP.fn = function(act)
    if act.doer.components.inventory then
	local minigun = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if minigun then
	    act.doer.components.inventory:GiveItem(minigun)
	end
    end
    return true
end
AddAction(SDFGATLING_GUN_UNEQUIP)

AddComponentAction("POINT", "equippable", function(inst, doer, pos, actions, right)
    if right and (doer:HasTag("has_sdf_gatling_gun") or doer.replica.inventory and doer.replica.inventory:EquipHasTag("sdf_gatling_gun")) then
        table.insert(actions, ACTIONS.SDFGATLING_GUN_UNEQUIP)
    end
end)

AddComponentAction("EQUIPPED", "equippable", function(inst, doer, target, actions, right)
    if right and (doer:HasTag("has_sdf_gatling_gun") or doer.replica.inventory and doer.replica.inventory:EquipHasTag("sdf_gatling_gun")) then
        table.insert(actions, ACTIONS.SDFGATLING_GUN_UNEQUIP)
    end
end)

local sdfgatling_gun_unequip_handler = ActionHandler(ACTIONS.SDFGATLING_GUN_UNEQUIP, function(inst)
    if inst.AnimState then
	inst.AnimState:ClearOverrideSymbol("swap_object")
    end
    return "sdfgatling_gun_item_in"
end)
AddStategraphActionHandler("wilson", sdfgatling_gun_unequip_handler)

local sdfgatling_gun_unequip_handler_client = ActionHandler(ACTIONS.SDFGATLING_GUN_UNEQUIP, function(inst)
    if inst.AnimState then
	inst.AnimState:ClearOverrideSymbol("swap_object")
    end
    return "sdfgatling_gun_item_in"
end)
AddStategraphActionHandler("wilson_client", sdfgatling_gun_unequip_handler_client)