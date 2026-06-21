local assets =
{
    Asset("ATLAS","images/inventoryimages/sdf_pistol.xml"),
    Asset("ATLAS","images/inventoryimages/sdf_pistol_empty.xml"),

    Asset("ANIM", "anim/sdf_pistol.zip"),
    Asset("ANIM", "anim/swap_sdf_pistol.zip"),
    Asset("ANIM", "anim/swap_sdf_pistol_empty.zip"),

    Asset("IMAGE", "images/inv_slot/inv_slot_standard_bullets.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_bullets.xml"),
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
    if inst.components.container:Has("sdf_standard_bullets", 1) then
	inst.components.inventoryitem.imagename = "sdf_pistol"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pistol.xml"
    end
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
		item:PushEvent("ammounloaded", {sdf_pistol = inst})
	    end
	    item:Remove()
	end

	--Apply Cooldown
	local to_consume = inst.overheat_usage
	local new_percent = (inst.cooldown - to_consume) > inst.cooldown_min and inst.cooldown - to_consume or inst.cooldown_min

	inst.cooldown = new_percent
	inst:PushEvent("rechargechange", {percent = new_percent})

	--Custom on overheat fn
	if (inst.cooldown < inst.overheat_usage) or inst.components.container:GetItemInSlot(1) == nil then
	    inst.components.rechargeable:Discharge(TUNING.SDF_PISTOL_COOLDOWN)
	end
    end

    --resource cost
    resourceCost(inst, attacker, TUNING.SDF_PISTOL_USAGE)
end

local function setSpellCastToggle(inst, toggle)
    inst.components.spellcaster.canuseontargets = toggle
    inst.components.spellcaster.canonlyuseoncombat = toggle
end

local function createPowerAttackProjectile(inst, ammo, target, owner)
    --ammo type
    local projectile = SpawnPrefab(ammo.prefab)

    --NA
    --projectile.components.sdf_ranged_power_attack:SetPowerAttackType(inst.prefab)

    --throw
    local offset = 1.5
    local x, y, z = owner.Transform:GetWorldPosition()
    local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
    dir = dir * offset
    projectile.Transform:SetPosition(x + dir.x, y, z + dir.z)
    projectile.components.projectile:Throw(owner, target, owner)
end

local function pistolPowerAttack(inst, target)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end
    
    if inst.components.rechargeable then
	if inst.components.rechargeable:IsCharged() then

	    --Create Projectile
	    local quiverammo = inst.components.container:GetItemInSlot(1)
	    if quiverammo ~= nil and quiverammo:HasTag("sdf_pistol_ammo") then

		--Ammo amount
		local stackAmount = quiverammo.components.stackable:StackSize()
		if stackAmount > TUNING.SDF_PISTOL_POWER_ATTACK_SHOOT_AMOUNT then
		    stackAmount = TUNING.SDF_PISTOL_POWER_ATTACK_SHOOT_AMOUNT
		end

		--Quick Draw
		for i = 1, stackAmount, 1 do 
		    inst:DoTaskInTime(((i + TUNING.SDF_PISTOL_POWER_ATTACK_SHOOT_SPEED) / 10), function()

			if inst.cooldown > inst.overheat_usage and inst.components.container:GetItemInSlot(1) ~= nil then --(inst.cooldown - inst.overheat_usage) >= 0 then
			    --Create Power Attack Projectile
			    createPowerAttackProjectile(inst, quiverammo, target, owner)

			    --Consume Item
			    local item = inst.components.container:RemoveItem(quiverammo, false)
			    if item ~= nil then
				if item == quiverammo then
				    item:PushEvent("ammounloaded", {sdf_pistol = inst})
				end
				item:Remove()
			    end

			    --Apply Cooldown
			    local to_consume = inst.overheat_usage
			    local new_percent = (inst.cooldown - to_consume) > inst.cooldown_min and inst.cooldown - to_consume or inst.cooldown_min

			    inst.cooldown = new_percent
			    inst:PushEvent("rechargechange", {percent = new_percent})

			    --Custom on overheat fn
			    if (inst.cooldown < inst.overheat_usage) or inst.components.container:GetItemInSlot(1) == nil then

				inst.cooldown = 0
				inst:PushEvent("rechargechange", {percent = inst.cooldown})

				--Cooldown
				inst.components.rechargeable:Discharge(TUNING.SDF_PISTOL_POWER_ATTACK_COOLDOWN)
			    end
			end
		    end)
		end

		--Resource Cost
		resourceCost(inst, owner, TUNING.SDF_PISTOL_POWER_ATTACK_USAGE)
	    end
	end
    end
end

local function AmmoLoaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	inst.components.inventoryitem.imagename = "sdf_pistol"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pistol.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(TUNING.SDF_PISTOL_RANGE, TUNING.SDF_PISTOL_RANGE + 4)
	owner.components.combat:SetAttackPeriod(TUNING.SDF_PISTOL_ATTACK_SPEED)

	--Range Attacks
	inst:AddTag("sdf_pistol_shoot")
	inst.components.finiteuses.ignorecombatdurabilityloss = true

	--Range Power Attack
	setSpellCastToggle(inst, true)

    end
end

local function AmmoUnloaded(inst, ammo)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	inst.components.inventoryitem.imagename = "sdf_pistol_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pistol_empty.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(0)
	owner.components.combat:SetAttackPeriod(TUNING.SDF_RANGE_MELEE_ATTACK_SPEED)

	--Melee attacks
	inst:RemoveTag("sdf_pistol_shoot")
	inst.components.finiteuses.ignorecombatdurabilityloss = false

	--Range Power Attack
	setSpellCastToggle(inst, false)

    end
end

local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil then
	if data ~= nil and data.item ~= nil then
	    inst.components.weapon:SetProjectile(data.item.prefab)

	    --Add pistol Holding Anim and Attack Speed
	    AmmoLoaded(inst, data.item.prefab)

	    data.item:PushEvent("ammoloaded", {sdf_pistol = inst})
	end
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then
	inst.components.weapon:SetProjectile(nil)

	--Remove pistol Holding Anim and Attack Speed
	AmmoUnloaded(inst)

	if data ~= nil and data.prev_item ~= nil then
	    data.prev_item:PushEvent("ammounloaded", {sdf_pistol = inst})
	end

	--Reset Overheat
	inst.cooldown = inst.cooldown_max
	inst:PushEvent("rechargechange", {percent = inst.cooldown})
    end
end

local function OnCharged(inst)
    local quiverammo = inst.components.container:GetItemInSlot(1)
    if quiverammo ~= nil and quiverammo:HasTag("sdf_pistol_ammo") then
	inst.components.weapon:SetProjectile(quiverammo.prefab)
	inst.components.weapon:SetRange(TUNING.SDF_PISTOL_RANGE, TUNING.SDF_PISTOL_RANGE + 4)

	local owner = inst.components.inventoryitem:GetGrandOwner()
	if owner ~= nil then
	    owner.components.combat:SetAttackPeriod(TUNING.SDF_PISTOL_ATTACK_SPEED)
	end

	--Range Attacks
	inst:AddTag("sdf_pistol_shoot")
	inst.components.finiteuses.ignorecombatdurabilityloss = true

	--Range Power Attack
	setSpellCastToggle(inst, true)
    end

    --Reset Overheat
    inst.cooldown = inst.cooldown_max
    inst.components.rechargeable:SetChargeTime(3600)
    --inst:PushEvent("rechargechange", {percent = inst.cooldown})
end

local function OnDischarged(inst)
    if inst.components.weapon ~= nil then
	inst.components.weapon:SetProjectile(nil)
	inst.components.weapon:SetRange(0)
    end

    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	owner.components.combat:SetAttackPeriod(TUNING.SDF_RANGE_MELEE_ATTACK_SPEED)
    end

    --Melee attacks
    inst:RemoveTag("sdf_pistol_shoot")
    inst.components.finiteuses.ignorecombatdurabilityloss = false

    --Range Power Attack
    setSpellCastToggle(inst, false)
end

local function onequip(inst, owner)
    --Update Animation and AmmoLoad
    local quiverammo = inst.components.container:GetItemInSlot(1)
    if quiverammo ~= nil and quiverammo:HasTag("sdf_pistol_ammo") then
	inst.components.inventoryitem.imagename = "sdf_pistol"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pistol.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(TUNING.SDF_PISTOL_RANGE, TUNING.SDF_PISTOL_RANGE + 4)
	owner.components.combat:SetAttackPeriod(TUNING.SDF_PISTOL_ATTACK_SPEED)

	--Range Power Attack
	setSpellCastToggle(inst, true)

    else
	inst.components.inventoryitem.imagename = "sdf_pistol_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pistol_empty.xml"
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	inst.components.weapon:SetRange(0)
	owner.components.combat:SetAttackPeriod(0.6)

	--Melee attacks
	inst:RemoveTag("sdf_pistol_shoot")
	inst.components.finiteuses.ignorecombatdurabilityloss = false

	--Range Power Attack
	setSpellCastToggle(inst, false)

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
    if quiverammo ~= nil and quiverammo:HasTag("sdf_pistol_ammo") then
	inst.components.inventoryitem.imagename = "sdf_pistol"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pistol.xml"
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_pistol")
    inst.AnimState:SetBuild("sdf_pistol")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("rangedweapon")
    inst:AddTag("weapon")
    inst:AddTag("rechargeable")
    inst:AddTag("sdf_pistol")
    inst:AddTag("sdf_pistol_shoot")

    inst.spelltype = "SDF_PISTOL_POWER_ATTACK"

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

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetRange(0)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)
    inst.components.weapon:SetProjectileOffset(1)

    inst:AddComponent("spellcaster")
    --inst.components.spellcaster.quickcast = true
    inst.components.spellcaster:SetSpellFn(pistolPowerAttack)
    inst.components.spellcaster.canuseontargets = false
    inst.components.spellcaster.canonlyuseoncombat = false

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_PISTOL_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_PISTOL_DURABILITY)
    inst.components.finiteuses.ignorecombatdurabilityloss = true
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sdf_pistol")
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
    inst.components.inventoryitem.imagename = "sdf_pistol_empty"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pistol_empty.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_PISTOL_OVERHEAT_MAX)
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst.cooldown = 1
    inst.cooldown_max = 1
    inst.cooldown_min = 0
    inst.overheat_usage = TUNING.SDF_PISTOL_OVERHEAT_USAGE
    inst.overheat_cooldown_rate = TUNING.SDF_PISTOL_OVERHEAT_COOLDOWN_RATE

    return inst
end

return Prefab("common/inventory/sdf_pistol", fn, assets)