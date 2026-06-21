local assets =
{
    Asset("ATLAS","images/inventoryimages/sdf_blunderbuss.xml"),
    Asset("ATLAS","images/inventoryimages/sdf_blunderbuss_empty.xml"),

    Asset("ANIM", "anim/sdf_blunderbuss.zip"),
    Asset("ANIM", "anim/swap_sdf_blunderbuss.zip"),
    Asset( "ANIM", "anim/sdf_blunderbuss_fx.zip" ),

    Asset("IMAGE", "images/inv_slot/inv_slot_standard_buckshots.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_buckshots.xml"),
}

prefabs = {
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

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
    --Has ammo
    if inst.components.container:Has("sdf_standard_buckshots", 1) then
	inst.components.inventoryitem.imagename = "sdf_blunderbuss"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"
    end
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    for r = 5, 0, -.25 do
	pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(0, 0, 0)
	if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
	    return pos
	end
    end
    return pos
end

local function resourceCost(inst, owner, usage)
    if inst.components.finiteuses then
	inst.components.finiteuses:Use(usage)
    end
end

local function OnProjectileLaunched(inst, attacker, target)
    if inst.components.container ~= nil then
	local ammo_stack = inst.components.container:GetItemInSlot(1)
	local item = inst.components.container:RemoveItem(ammo_stack, false)
	if item ~= nil then
	    if item == ammo_stack then
		item:PushEvent("ammounloaded", {sdf_blunderbuss = inst})
	    end
	    item:Remove()
	end
    end

    --resource cost
    resourceCost(inst, attacker, TUNING.SDF_BLUNDERBUSS_USAGE)

end

local function OnCharged(inst)
    local quiverammo = inst.components.container:GetItemInSlot(1)
    if quiverammo ~= nil and quiverammo:HasTag("sdf_blunderbuss_ammo") then
	inst.components.aoetargeting:SetEnabled(true)
    end
end

local function OnDischarged(inst)
    inst.components.aoetargeting:SetEnabled(false)
end

local function learnBombardSpell(inst, doer, pos)

    --Check cooldown
    if not inst.components.rechargeable:IsCharged() then
	if doer.components.talker then
	    doer.components.talker:Say(GetString(doer, "ANNOUNCE_ANUBISSTONENOENERGY"))
	end
	return
    end

    --Create Projectile
    local quiverammo = inst.components.container:GetItemInSlot(1)
    if quiverammo ~= nil and quiverammo:HasTag("sdf_blunderbuss_ammo") then

	--Bombard
	local bombardProj = SpawnPrefab(""..quiverammo.prefab.."_bombard_projectile")

	--throw
	local x, y, z = inst.Transform:GetWorldPosition()
	bombardProj.Transform:SetPosition(x, y, z)
	bombardProj.components.complexprojectile:Launch(pos, doer, inst)

	--fx
	ShakeAllCameras(CAMERASHAKE.FULL, .2, .04, .1, inst, 10)
	
	local cloudpuff = SpawnPrefab("sdf_blunderbuss_fx")
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local angle = (inst:GetAngleToPoint(pos) -90)*DEGREES
	local DIST = 1.5
	local offset = Vector3(DIST * math.cos( angle+(PI/2) ), 0, -DIST * math.sin( angle+(PI/2) ))
	cloudpuff.Transform:SetPosition(pt.x+offset.x,2,pt.z+offset.z)

	--Consume Item
	local item = inst.components.container:RemoveItem(quiverammo, false)
	if item ~= nil then
	    if item == quiverammo then
		item:PushEvent("ammounloaded", {sdf_blunderbuss = inst})
	    end
	    item:Remove()
	end

	--Cooldown
	inst.components.rechargeable:Discharge(TUNING.SDF_BLUNDERBUSS_BOMBARD_COOLDOWN)

	--Resource Cost
	resourceCost(inst, doer, TUNING.SDF_BLUNDERBUSS_BOMBARD_USAGE)
    end
end

local function AmmoLoaded(inst, ammo)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	inst.components.inventoryitem.imagename = "sdf_blunderbuss"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_blunderbuss", "swap_range") --loaded
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(TUNING.SDF_BLUNDERBUSS_RANGE, TUNING.SDF_BLUNDERBUSS_RANGE + 4)
	owner.components.combat:SetAttackPeriod(TUNING.SDF_BLUNDERBUSS_ATTACK_SPEED)
	inst.SoundEmitter:PlaySound("monkeyisland/cannon/load")

	--Range Attacks
	inst:AddTag("sdf_blunderbuss_shoot")
	inst.components.finiteuses.ignorecombatdurabilityloss = true

	--Bombard
	inst.components.aoetargeting:SetEnabled(true)
    end
end

local function AmmoUnloaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	inst.components.inventoryitem.imagename = "sdf_blunderbuss_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss_empty.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_blunderbuss", "swap_melee") --empty
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(0)
	owner.components.combat:SetAttackPeriod(TUNING.SDF_RANGE_MELEE_ATTACK_SPEED)

	--Melee attacks
	inst:RemoveTag("sdf_blunderbuss_shoot")
	inst.components.finiteuses.ignorecombatdurabilityloss = false

	--Bombard
	inst.components.aoetargeting:SetEnabled(false)
    end
end

local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil then
	if data ~= nil and data.item ~= nil then
	    inst.components.weapon:SetProjectile(data.item.prefab)

	    --Add blunderbuss Anim and Attack Speed
	    AmmoLoaded(inst, data.item.prefab)

	    data.item:PushEvent("ammoloaded", {sdf_blunderbuss = inst})
	end
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then
	inst.components.weapon:SetProjectile(nil)

	--Remove blunderbuss Anim and Attack Speed
	AmmoUnloaded(inst)

	if data ~= nil and data.prev_item ~= nil then
	    data.prev_item:PushEvent("ammounloaded", {sdf_blunderbuss = inst})
	end
    end
end

local function onequip(inst, owner)
    --Update Animation and AmmoLoad
    local quiverammo = inst.components.container:GetItemInSlot(1)
    if quiverammo ~= nil and quiverammo:HasTag("sdf_blunderbuss_ammo") then
	inst.components.weapon:SetProjectile(quiverammo.prefab)

	inst.components.inventoryitem.imagename = "sdf_blunderbuss"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_blunderbuss", "swap_range") --loaded
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(TUNING.SDF_BLUNDERBUSS_RANGE, TUNING.SDF_BLUNDERBUSS_RANGE + 4)
	owner.components.combat:SetAttackPeriod(TUNING.SDF_BLUNDERBUSS_ATTACK_SPEED)

	--Bombard
	inst.components.aoetargeting:SetEnabled(true)	

    else
	inst.components.inventoryitem.imagename = "sdf_blunderbuss_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss_empty.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_blunderbuss", "swap_melee") --empty
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(0)
	owner.components.combat:SetAttackPeriod(0.6)

	--Melee attacks
	inst:RemoveTag("sdf_blunderbuss_shoot")
	inst.components.finiteuses.ignorecombatdurabilityloss = false

    end

    --Open Quiver
    if not inst.components.container:IsOpen() and QUIVER_FIRST_OPEN == false then
	inst:DoTaskInTime(0.1, function(inst) 
	    inst.components.container:Open(owner)
	    QUIVER_FIRST_OPEN = true
	end)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst.components.weapon:SetRange(0)
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)

    --Close Quiver
    if inst.components.container ~= nil then
	inst.components.container:Close(owner)
	QUIVER_FIRST_OPEN = false
    end
end

local function onload(inst, data)
    --Has ammo
    local quiverammo = inst.components.container:GetItemInSlot(1)
    if quiverammo ~= nil and quiverammo:HasTag("sdf_blunderbuss_ammo") then
	inst.components.inventoryitem.imagename = "sdf_blunderbuss"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_blunderbuss")
    inst.AnimState:SetBuild("sdf_blunderbuss")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("rangedweapon")
    inst:AddTag("weapon")
    inst:AddTag"allow_action_on_impassable"
    inst:AddTag("sdf_blunderbuss")
    inst:AddTag("sdf_blunderbuss_shoot")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting:SetRange(TUNING.SDF_BLUNDERBUSS_BOMBARD_AOE_RANGE)
    
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoesmall"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoesmallping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting:SetRange(TUNING.SDF_BLUNDERBUSS_BOMBARD_AOE_RANGE)

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

    inst.components.aoetargeting:SetEnabled(false)

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(learnBombardSpell)
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetRange(0)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)
    inst.components.weapon:SetProjectileOffset(1)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_BLUNDERBUSS_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_BLUNDERBUSS_DURABILITY)
    inst.components.finiteuses.ignorecombatdurabilityloss = true
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sdf_blunderbuss")
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    local origOpen = inst.components.container.Open
    inst.components.container.Open = function(self, doer)
	origOpen(self, doer)
	QuiverWidgetHUDPositionFn(self, doer)
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_blunderbuss"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_blunderbuss.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_BLUNDERBUSS_BOMBARD_COOLDOWN)
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload

    return inst
end

local function onSleep(inst)
    inst:Remove()
end 

local function SetAnim(inst)
    inst.AnimState:PlayAnimation("poofanim", false)
    local x, y, z = inst.Transform:GetWorldPosition()

    local map = GetWorld().Map

    local tx, ty = map:GetTileXYAtPoint(x, y, z)

    local left = map:IsLand(map:GetTile(tx, ty)) and map:IsWater(map:GetTile(tx, ty))
end

local function fn2(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    anim:SetBuild("cloud_puff_soft")
    anim:SetBank("splash_clouds_drop")
    anim:PlayAnimation("idle_sink")

    inst:AddTag( "FX" )
    inst:AddTag( "NOCLICK" )
    if not TheWorld.ismastersim then
        return inst
    end
    inst.OnEntitySleep = onSleep

    inst:ListenForEvent( "animover", function(inst) inst:Remove() end )
    inst.persists = false

    return inst
end

return Prefab("common/inventory/sdf_blunderbuss", fn, assets),
	Prefab("sdf_blunderbuss_fx", fn2, assets)