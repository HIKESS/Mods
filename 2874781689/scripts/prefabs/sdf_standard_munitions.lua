local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_standard_munitions.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_standard_munitions.tex"),

    Asset("ANIM", "anim/sdf_standard_munitions.zip"),
}

prefabs = {
}

local function onfinished(inst)
    inst:DoTaskInTime(0.1, function()
	inst:Remove()
    end)
end

local function OnConsumeAmmo(inst)
    inst.components.finiteuses:Use(TUNING.SDF_STANDARD_MUNITIONS_USAGE)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_standard_munitions")
    inst.AnimState:SetBuild("sdf_standard_munitions")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sdf_gatling_gun_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_STANDARD_MUNITIONS_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_STANDARD_MUNITIONS_DURABILITY)
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_standard_munitions"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_standard_munitions.xml"

    MakeHauntableLaunch(inst)

    inst:ListenForEvent("sdf_gatling_gun_consume_ammo", OnConsumeAmmo)

    return inst
end

--Munition Projectile
local function TargetFilter(entity)
    if SDFGatling_Gun_IsValidGatlingGunTarget(entity) then
	if SDFGatling_Gun_IsBossEnemy(entity) or SDFGatling_Gun_IsLivingCreature(entity) then
	    return (entity.components.health == nil or not entity.components.health:IsDead()) and entity.components.combat ~= nil and entity.components.combat:CanBeAttacked() and true or false
			
	elseif entity.components.pickable ~= nil then
	    return entity:HasTag("blocker") and true or false
			
	elseif entity.components.combat ~= nil then
	    return entity.components.combat:CanBeAttacked() and true or false
			
	else
	    return true
	end
    end
    return false
end

local function TargetStructureFilter(entity)
    return entity:HasTag("structure") and entity:HasTag("blocker") and true or false
end

local function TargetPickableFilter(entity)
    return entity.components.pickable ~= nil and entity:HasTag("blocker") and true or false
end

local function projectile_fn(ammo)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("sdf_standard_munitions")
    inst.AnimState:SetBuild("sdf_standard_munitions")
    inst.AnimState:PlayAnimation("thrown", true)

    inst:AddTag("NOCLICK")
    inst:AddTag("projectile")
    inst:AddTag("sdf_gatling_gun_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
	
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_STANDARD_MUNITIONS_PROJECTILE_SPEED)
    inst.components.projectile:SetHoming(false)

    inst:AddComponent("sdf_gatling_gun_weapon_projectile")
    inst.components.sdf_gatling_gun_weapon_projectile:AddTargetFilter("TargetFilter", TargetFilter)
    inst.components.sdf_gatling_gun_weapon_projectile:AddTargetFilter("TargetStructureFilter", TargetStructureFilter)
    inst.components.sdf_gatling_gun_weapon_projectile:AddTargetFilter("TargetPickableFilter", TargetPickableFilter)
	
    --Projectile Despawn
    inst:DoTaskInTime(.9, function(inst)
	inst.AnimState:PlayAnimation("bullet_drop", false)
    end)
	
    inst:ListenForEvent("animover", function(inst)
	if inst.AnimState:AnimDone() and not inst.AnimState:IsCurrentAnimation("bullet_drop") then
	    if inst.components.sdf_gatling_gun_weapon_projectile ~= nil then
		inst.components.sdf_gatling_gun_weapon_projectile:DeleteSelf()
	    else
		inst:Remove()
	    end
	end
    end)

    inst:DoTaskInTime(3, function(inst)
	if inst ~= nil then
	    if inst.components.sdf_gatling_gun_weapon_projectile ~= nil then
		inst.components.sdf_gatling_gun_weapon_projectile:DeleteSelf()
	    else
		inst:Remove()
	    end
	end
    end)

    return inst
end

return  Prefab("common/inventory/sdf_standard_munitions", fn, assets),
	Prefab("sdf_standard_munitions_proj", projectile_fn, assets, prefabs)