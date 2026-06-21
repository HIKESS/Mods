local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_throwing_daggers.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_throwing_daggers.tex"),

    Asset("ANIM", "anim/sdf_throwing_daggers.zip"),
    Asset("ANIM", "anim/swap_sdf_throwing_daggers.zip"),
}

prefabs = {
}

local function OnFinished(inst)
    inst.AnimState:PlayAnimation("idle")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function OnDropped(inst)
    inst.AnimState:SetBank("sdf_throwing_daggers")
    inst.AnimState:SetBuild("sdf_throwing_daggers")
    inst.AnimState:PlayAnimation("idle")
end

local function OnHit(inst, owner, target)
    if owner == target then
        OnDropped(inst)
    end
    local impactfx = SpawnPrefab("impact")
    if impactfx then
	local follower = impactfx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	impactfx:FacePoint(inst.Transform:GetWorldPosition())
    end

    --Power Attacks
    local powerAttackType = inst.components.sdf_ranged_power_attack:GetPowerAttackType()
    if powerAttackType ~= nil then
	inst.components.sdf_ranged_power_attack:GetPowerAttackSkill(inst, owner, target, powerAttackType)
    end

    inst:Remove()
end

local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:SetBank("swap_sdf_throwing_daggers")
    inst.AnimState:SetBuild("swap_sdf_throwing_daggers")
    inst.AnimState:PlayAnimation("thrown", true)
    inst.components.inventoryitem.pushlandedevents = false

    --Equip next Throwing Daggers
    local equipThrowingDaggerSlot = owner.components.inventory:GetNextAvailableSlot(inst)
    if equipThrowingDaggerSlot ~= nil then
	local equipThrowingDagger = owner.components.inventory:GetItemInSlot(equipThrowingDaggerSlot)
	if equipThrowingDagger then
	    if not owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
		owner.components.inventory:Equip(equipThrowingDagger)
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

local function createPowerAttackProjectile(inst, target, owner, amount, id)
    --ammo type
    local projectile = SpawnPrefab(inst.prefab)

    --hemorrhage
    projectile.components.sdf_ranged_power_attack:SetPowerAttackType(inst.prefab)

    --knife juggle
    local y_offset = 1
    if id == 1 and (amount == 1 or amount == 3) then --middle
	local offset = 0
	local x, y, z = owner.Transform:GetWorldPosition()
	local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
	dir = dir * offset
	projectile.Transform:SetPosition(x + dir.x, y + offset + y_offset, z + dir.z)
    elseif id == 1 and amount == 2 then --top
	local offset = -0.5
	local x, y, z = owner.Transform:GetWorldPosition()
	local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
	dir = dir * offset
	projectile.Transform:SetPosition(x + dir.x, y + offset + y_offset, z + dir.z)
    elseif id == 2 and amount == 2 then --bottom
	local offset = -0.5
	local x, y, z = owner.Transform:GetWorldPosition()
	local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
	dir = dir * offset
	projectile.Transform:SetPosition(x + dir.x, y - offset + y_offset, z + dir.z)
    elseif id == 2 and amount == 3 then --top
	local offset = -0.5
	local x, y, z = owner.Transform:GetWorldPosition()
	local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
	dir = dir * offset
	projectile.Transform:SetPosition(x + dir.x, y + offset + y_offset, z + dir.z)
    elseif id == 3 and amount == 3 then --bottom
	local offset = -0.5
	local x, y, z = owner.Transform:GetWorldPosition()
	local dir = (target:GetPosition() - Vector3(x, y, z)):Normalize()
	dir = dir * offset
	projectile.Transform:SetPosition(x + dir.x, y - offset + y_offset, z + dir.z)
    end

    projectile.components.projectile:Throw(owner, target, owner)
end

local function throwingDaggersPowerAttack(inst, target)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end
    
    if inst.components.rechargeable then
	if inst.components.rechargeable:IsCharged() then

	    --Create Projectile
	    --Ammo amount
	    local stackAmount = inst.components.stackable:StackSize()
	    if stackAmount > TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_THROW_AMOUNT then
		stackAmount = TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_THROW_AMOUNT
	    end

	    --knife juggle
	    for i = 1, stackAmount, 1 do 
		--Create Power Attack Projectile
		createPowerAttackProjectile(inst, target, owner, stackAmount, i)
	    end

	    --Cooldown
	    inst.components.rechargeable:Discharge(TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_COOLDOWN)

	    --Consume Item
	    local item = inst.components.stackable:Get(stackAmount)
	    if item ~= nil then
		item:Remove()
	    end

	    --Equip next Throwing Daggers
	    local equipThrowingDaggerSlot = owner.components.inventory:GetNextAvailableSlot(inst)
	    if equipThrowingDaggerSlot ~= nil then
		local equipThrowingDagger = owner.components.inventory:GetItemInSlot(equipThrowingDaggerSlot)
		if equipThrowingDagger then
		    if not owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
			owner.components.inventory:Equip(equipThrowingDagger)
		    end
		end
	    end
	end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_throwing_daggers", "swap_sdf_throwing_daggers")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_THROWING_DAGGERS_ATTACK_SPEED)

    --Cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_COOLDOWN)
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
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("sdf_throwing_daggers")
    inst.AnimState:SetBuild("sdf_throwing_daggers")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("projectile")
    inst:AddTag("thrown")
    inst:AddTag("sdf_throwing_daggers_throw")

    inst.spelltype = "SDF_THROWING_DAGGERS_POWER_ATTACK"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --allows ranged power attacks
    inst:AddComponent("sdf_ranged_power_attack")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_THROWING_DAGGERS_DAMAGE)
    inst.components.weapon:SetRange(TUNING.SDF_THROWING_DAGGERS_RANGE, TUNING.SDF_THROWING_DAGGERS_RANGE + 4)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_THROWING_DAGGERS_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster:SetSpellFn(throwingDaggersPowerAttack)
    inst.components.spellcaster.canuseontargets = false
    inst.components.spellcaster.canonlyuseoncombat = false

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_THROWING_DAGGERS_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_throwing_daggers"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_throwing_daggers.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_COOLDOWN)
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_throwing_daggers", fn, assets)