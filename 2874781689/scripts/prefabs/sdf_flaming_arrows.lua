local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_arrows.tex"),

    Asset("ANIM", "anim/sdf_flaming_arrows.zip"),
}

prefabs = {
}

local function setFire(inst, target, owner)
    if target then
	if target.components.burnable and not target.components.burnable:IsBurning() then
	    if target.components.freezable and target.components.freezable:IsFrozen() then
		target.components.freezable:Unfreeze()
	    else
		target.components.burnable:Ignite(true)
	    end

	    if target.components.freezable then
		target.components.freezable:AddColdness(-1) --Does this break ice staff?
		if target.components.freezable:IsFrozen() then
		    target.components.freezable:Unfreeze()
		end
	    end

	    if target.components.sleeper and target.components.sleeper:IsAsleep() then
		target.components.sleeper:WakeUp()
	    end

	    if target.components.combat then
		target.components.combat:SuggestTarget(owner)
	    end
	    target:PushEvent("attacked", {attacker = owner, damage = 0})
	end
    end
end

local function OnHit(inst, owner, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx then
	local follower = impactfx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	impactfx:FacePoint(inst.Transform:GetWorldPosition())
	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")
	end
    end

    --Lite on Fire
    setFire(inst,target, owner)

    --Power Attacks
    local powerAttackType = inst.components.sdf_ranged_power_attack:GetPowerAttackType()
    if powerAttackType ~= nil then
	inst.components.sdf_ranged_power_attack:GetPowerAttackSkill(inst, owner, target, powerAttackType)
    end

    inst:Remove()
end

local function onthrown(inst, data)
    --inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/poop")
    inst.AnimState:PlayAnimation("thrown")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.components.inventoryitem.pushlandedevents = false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("sdf_flaming_arrows")
    inst.AnimState:SetBuild("sdf_flaming_arrows")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("projectile")
    inst:AddTag("sdf_longbow_ammo")
    inst:AddTag("sdf_flaming_longbow_ammo")

    MakeInventoryFloatable(inst, "small", 0.3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --allows ranged power attacks
    inst:AddComponent("sdf_ranged_power_attack")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_FLAMING_ARROWS_DAMAGE)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_FLAMING_ARROWS_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(1)
    inst.components.projectile:SetLaunchOffset(Vector3(0.35, 1.2, 0))
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile.range = TUNING.SDF_FLAMING_LONGBOW_RANGE + 4
    inst.components.projectile.has_damage_set = true
    inst:ListenForEvent("onthrown", onthrown)

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_FLAMING_ARROWS_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_flaming_arrows"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_flaming_arrows.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_flaming_arrows", fn, assets)