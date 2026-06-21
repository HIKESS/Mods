local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_spear.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_spear.tex"),

    Asset("ANIM", "anim/sdf_spear.zip"),
    Asset("ANIM", "anim/swap_sdf_spear.zip"),

    Asset("ANIM", "anim/sdf_spear_sunder_armor.zip"),
}

prefabs = {
}

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
end

local function OnHit(inst, owner, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx then
	local follower = impactfx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	impactfx:FacePoint(inst.Transform:GetWorldPosition())
	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/shadow_attack")
	end
    end

    --Power Attacks
    local powerAttackType = inst.components.sdf_ranged_power_attack:GetPowerAttackType()
    if powerAttackType ~= nil then
	inst.components.sdf_ranged_power_attack:GetPowerAttackSkill(inst, owner, target, powerAttackType)
    end

    inst:Remove()
end

local function OnThrown(inst, owner, target)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bugnet", nil, nil, true)
    inst.AnimState:PlayAnimation("thrown")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.components.inventoryitem.pushlandedevents = false

    --Equip next spear
    local equipSpearSlot = owner.components.inventory:GetNextAvailableSlot(inst)
    if equipSpearSlot ~= nil then
	local equipSpear = owner.components.inventory:GetItemInSlot(equipSpearSlot)
	if equipSpear then
	    if not owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
		owner.components.inventory:Equip(equipSpear)
	    end
	end
    end
end

local function setSpellCastToggle(inst, toggle)
    inst.components.spellcaster.canuseontargets = toggle
    inst.components.spellcaster.canonlyuseoncombat = toggle
end

local function OnCharged(inst)
    setSpellCastToggle(inst, true)
end

local function OnDischarged(inst)
    setSpellCastToggle(inst, false)
end

local function createPowerAttackProjectile(inst, target, owner)
    --ammo type
    local projectile = SpawnPrefab(inst.prefab)

    --power up
    --Extra Damage
    if projectile.components.weapon then
	projectile.components.weapon:SetDamage(projectile.components.weapon.damage * TUNING.SDF_SPEAR_POWER_ATTACK_DAMAGE_MULTI)
    end
    --Extra Planar Damage
    if projectile.components.planardamage then
	projectile.components.planardamage:SetBaseDamage(projectile.components.weapon.damage * TUNING.SDF_SPEAR_POWER_ATTACK_DAMAGE_MULTI)
    end
    --sunder armor
    projectile.components.sdf_ranged_power_attack:SetPowerAttackType(inst.prefab)

    --throw
    local y_offset = 1
    local offset = 0
    local x, y, z = owner.Transform:GetWorldPosition()
    local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
    dir = dir * offset
    projectile.Transform:SetPosition(x + dir.x, y + offset + y_offset, z + dir.z)
    projectile.components.projectile:Throw(owner, target, owner)
end

local function spearPowerAttack(inst, target)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end
    
    if inst.components.rechargeable then
	if inst.components.rechargeable:IsCharged() then

	    --Create Projectile
	    --Create Power Attack Projectile
	    createPowerAttackProjectile(inst, target, owner)

	    --Cooldown
	    inst.components.rechargeable:Discharge(TUNING.SDF_SPEAR_POWER_ATTACK_COOLDOWN)

	    --Consume Item
	    local item = inst.components.stackable:Get(1)
	    if item ~= nil then
		item:Remove()
	    end

	    --Equip next spear
	    local equipSpearSlot = owner.components.inventory:GetNextAvailableSlot(inst)
	    if equipSpearSlot ~= nil then
		local equipSpear = owner.components.inventory:GetItemInSlot(equipSpearSlot)
		if equipSpear then
		    if not owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
			owner.components.inventory:Equip(equipSpear)
		    end
		end
	    end
	end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_spear", "swap_sdf_spear")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_SPEAR_ATTACK_SPEED)

    --Cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_SPEAR_POWER_ATTACK_COOLDOWN)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_spear")
    inst.AnimState:SetBuild("sdf_spear")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("rangedweapon")
    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("thrown")
    inst:AddTag("sdf_spear_throw")

    inst.spelltype = "SDF_SPEAR_POWER_ATTACK"

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --allows ranged power attacks
    inst:AddComponent("sdf_ranged_power_attack")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_SPEAR_DAMAGE)
    inst.components.weapon:SetRange(TUNING.SDF_SPEAR_RANGE, TUNING.SDF_SPEAR_RANGE + 4)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_SPEAR_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile.range = TUNING.SDF_SPEAR_RANGE + 4
    inst.components.projectile.has_damage_set = true

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster:SetSpellFn(spearPowerAttack)
    inst.components.spellcaster.canuseontargets = false
    inst.components.spellcaster.canonlyuseoncombat = false

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_SPEAR_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_spear"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_spear.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_SPEAR_POWER_ATTACK_COOLDOWN)
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    MakeHauntableLaunch(inst)

    return inst
end

local function goAway(inst)
    inst.AnimState:PushAnimation("pst")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("sdf_spear_sunder_armor")
    inst.AnimState:SetBuild("sdf_spear_sunder_armor")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop", true)

    inst.entity:SetPristine()

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.goAwayFn = function() goAway(inst) end

    return inst
end

return  Prefab("common/inventory/sdf_spear", fn, assets),
	Prefab("sdf_spear_sunder_armor_debuff", fn2, assets)