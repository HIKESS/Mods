local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_standard_bolts.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_standard_bolts.tex"),

    Asset("ANIM", "anim/sdf_standard_bolts.zip"),
}

prefabs = {
}

local function OnHit(inst, owner, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx then
	local follower = impactfx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	impactfx:FacePoint(inst.Transform:GetWorldPosition())
	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/rock")
	end
    end

    --Power Attacks
    local powerAttackType = inst.components.sdf_ranged_power_attack:GetPowerAttackType()
    if powerAttackType ~= nil then
	inst.components.sdf_ranged_power_attack:GetPowerAttackSkill(inst, owner, target, powerAttackType)
    end

    inst:Remove()
end

local function onthrown(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/poop")
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

    inst.AnimState:SetBank("sdf_standard_bolts")
    inst.AnimState:SetBuild("sdf_standard_bolts")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("projectile")
    inst:AddTag("sdf_crossbow_ammo")

    MakeInventoryFloatable(inst, "small", 0.3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --allows ranged power attacks
    inst:AddComponent("sdf_ranged_power_attack")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_STANDARD_BOLTS_DAMAGE)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_STANDARD_BOLTS_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(0.5)
    inst.components.projectile:SetLaunchOffset(Vector3(0.35, 0.6, 0))
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile.range = TUNING.SDF_CROSSBOW_RANGE + 4
    inst.components.projectile.has_damage_set = true
    inst:ListenForEvent("onthrown", onthrown)

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_STANDARD_BOLTS_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_standard_bolts"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_standard_bolts.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_standard_bolts", fn, assets)