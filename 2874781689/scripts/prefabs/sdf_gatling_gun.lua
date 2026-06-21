local assets =
{
    Asset("ATLAS", "images/inventoryimages/sdf_gatling_gun.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_gatling_gun.tex"),

    Asset("ATLAS", "images/map_icons/sdf_gatling_gun_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_gatling_gun_mm.tex"),

    Asset("ANIM", "anim/sdf_gatling_gun.zip"),
	
    --FX builds for the shooting animation
    Asset("ANIM", "anim/sdf_gatling_gun_muzzle_flash_fx.zip"),
    Asset("ANIM", "anim/sdf_gatling_gun_shell_fx.zip"),

    Asset("IMAGE", "images/inv_slot/inv_slot_standard_munitions.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_munitions.xml"),
}

local function QuiverWidgetHUDPositionFn(self, doer)
  if not TheNet:IsDedicated() then
    local hudscaleadjust = Profile:GetHUDSize()*2
    local qs_pos = INVINFO.EQUIPSLOT_hands:GetWorldPosition()

    if doer and doer.HUD and doer.HUD.controls then		
      if doer.HUD.controls.containers[self.inst].QuiverHasAnchor == nil then
        doer.HUD.controls.containers[self.inst].QuiverHasAnchor = true

        doer.HUD.controls.containers[self.inst]:SetVAnchor(ANCHOR_BOTTOM)
        doer.HUD.controls.containers[self.inst]:SetHAnchor(ANCHOR_LEFT)
      end

      if doer.HUD.controls.containers[self.inst] then
        doer.HUD.controls.containers[self.inst]:UpdatePosition(qs_pos.x, (qs_pos.y+60+hudscaleadjust))	
      end
    end
  end
end

local QUIVER_FIRST_OPEN = false --Use for first time quiver slot opens

local function onfinished(inst)
    inst.components.container:DropEverything()
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        local brokentool = SpawnPrefab("brokentool")
        brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
end

local sdf_gatling_gun_accepted_states = {
    sdf_gatling_gun_idle = true,
    sdf_gatling_gun_shoot = true,
    hit = true,
    sdf_gatling_gun_ammo_restore = true,
}

local function GatlingGunOnNewState(owner, data)
    if not owner or not owner.sg or not data or not data.statename or (data.statename and sdf_gatling_gun_accepted_states[data.statename]) then
	return
    end
	
    local inventory = owner.components.inventory ~= nil and owner.components.inventory or nil
    local handitem = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    local minigun = handitem ~= nil and handitem:HasTag("sdf_gatling_gun") and handitem or nil
	
    if owner.components.rider and owner.components.rider:IsRiding() then
	owner.components.inventory:GiveItem(minigun)
	if owner.components.talker then
	    owner.components.talker:Say(GetString(owner, "ANNOUNCE_MINIGUNRIDE_FAIL"))
	end
    elseif data.statename == "idle" and owner.components.locomotor and not owner.components.locomotor:WantsToMoveForward() then
	owner:PushEvent("sdf_gatling_gun_equip")
    end
end

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

local function AmmoLoaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	--inst.components.inventoryitem.imagename = "sdf_blunderbuss"
	--inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"

	inst.SoundEmitter:PlaySound("monkeyisland/cannon/load")
    end
end

local function AmmoUnloaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	--inst.components.inventoryitem.imagename = "sdf_blunderbuss_empty"
	--inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss_empty.xml"
    end
end

local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil then
	if data ~= nil and data.item ~= nil then

	    --Add gatling gun Anim
	    AmmoLoaded(inst)

	    data.item:PushEvent("ammoloaded", {sdf_gatling_gun = inst})
	end
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then

	--Remove gatling gun Anim
	AmmoUnloaded(inst)

	if data ~= nil and data.prev_item ~= nil then
	    data.prev_item:PushEvent("ammounloaded", {sdf_gatling_gun = inst})
	end
    end
end

local function onequip(inst, owner)
    --Update Animation and AmmoLoad
    if inst.components.container:Has("sdf_standard_munitions", 1) then
	--inst.components.inventoryitem.imagename = "sdf_blunderbuss"
	--inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:OverrideSymbol("swap_minigun", "sdf_gatling_gun", "swap_minigun")
	owner.AnimState:OverrideSymbol("minigun_muzzle_flash", "sdf_gatling_gun_muzzle_flash_fx", "minigun_muzzle_flash")
	owner.AnimState:OverrideSymbol("minigun_shell", "sdf_gatling_gun_shell_fx", "minigun_shell")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

	owner:ListenForEvent("newstate", GatlingGunOnNewState)

	owner:AddTag("has_sdf_gatling_gun")

	if owner.components.inventory and owner.components.inventory.activeitem ~= nil then
	    if not owner.components.inventory:IsFull() and inst.components.inventoryitem.cangoincontainer then
		owner.components.inventory:GiveItem(owner.components.inventory.activeitem)
		owner.components.inventory:SetActiveItem(nil)
	    else
		owner.components.inventory:DropActiveItem()
	    end
	end
    else
	--inst.components.inventoryitem.imagename = "sdf_blunderbuss_empty"
	--inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss_empty.xml"
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:OverrideSymbol("swap_minigun", "sdf_gatling_gun", "swap_minigun")
	owner.AnimState:OverrideSymbol("minigun_muzzle_flash", "sdf_gatling_gun_muzzle_flash_fx", "minigun_muzzle_flash")
	owner.AnimState:OverrideSymbol("minigun_shell", "sdf_gatling_gun_shell_fx", "minigun_shell")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

	owner:ListenForEvent("newstate", GatlingGunOnNewState)

	owner:AddTag("has_sdf_gatling_gun")

	if owner.components.inventory and owner.components.inventory.activeitem ~= nil then
	    if not owner.components.inventory:IsFull() and inst.components.inventoryitem.cangoincontainer then
		owner.components.inventory:GiveItem(owner.components.inventory.activeitem)
		owner.components.inventory:SetActiveItem(nil)
	    else
		owner.components.inventory:DropActiveItem()
	    end
	end
    end

    --Open Quiver
    local hasDragonPotion = false
    local armorItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if armorItem and armorItem.prefab == "sdf_dragon_potion" then hasDragonPotion = true end
    if not inst.components.container:IsOpen() and QUIVER_FIRST_OPEN == false and hasDragonPotion == false then
	inst:DoTaskInTime(0.1, function(inst) 
	    inst.components.container:Open(owner)
	    QUIVER_FIRST_OPEN = true
	end)
    end

    --Clear Shield slot 2Hander
    --local owner_Inventory = owner.components.inventory
    --local shieldSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
    --if shieldSlot then
	--inst:DoTaskInTime(0.1, function()
	    --owner_Inventory:DropItem(shieldSlot)
	    --owner_Inventory:GiveItem(shieldSlot)
	--end)
    --end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_minigun")
    owner.AnimState:ClearOverrideSymbol("minigun_muzzle_flash")
    owner.AnimState:ClearOverrideSymbol("minigun_shell")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner:RemoveEventCallback("newstate", GatlingGunOnNewState)

    owner:RemoveTag("has_sdf_gatling_gun")

    --Close Quiver
    if inst.components.container ~= nil then
	inst.components.container:Close(owner)
	QUIVER_FIRST_OPEN = false
    end
end



local function onload(inst, data)
    --Has ammo
    if inst.components.container:Has("sdf_standard_munitions", 1) then
	--inst.components.inventoryitem.imagename = "sdf_blunderbuss"
	--inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_gatling_gun_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_gatling_gun")
    inst.AnimState:SetBuild("sdf_gatling_gun")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetRayTestOnBB(true)

    inst.AnimState:SetScale(1.3, 1.3, 1.3)

    inst:AddTag("sdf_gatling_gun")
    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelongmulti"
    inst.components.aoetargeting.reticule.pingprefab="reticulelongmultiping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetEnabled(true)

    inst.projectiledelay = 1 * FRAMES
	
    --Sounds
    inst:AddComponent("sdf_gatling_gun_weapon_asset_wrangler")
	
    inst:DoPeriodicTask(.1, function(inst)
	if inst.replica.equippable and not inst.replica.equippable:IsEquipped() then
	    inst.components.aoetargeting:StopTargeting()
	end
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:DoTaskInTime(0, function(inst)
	    local origReplicaOpen = inst.replica.container.Open
	    inst.replica.container.Open = function(self, doer)
		origReplicaOpen(self, doer)
		QuiverWidgetHUDPositionFn(self, doer)
	    end
	end)
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_GATLING_GUN_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_GATLING_GUN_DURABILITY)
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sdf_gatling_gun")
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    local origOpen = inst.components.container.Open
    inst.components.container.Open = function(self, doer)
	origOpen(self, doer)
	QuiverWidgetHUDPositionFn(self, doer)
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_gatling_gun"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_gatling_gun.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.SDF_GATLING_GUN_SPEED_MULT

    inst:AddComponent("sdf_gatling_gun_weapon")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/sdf_gatling_gun", fn, assets)