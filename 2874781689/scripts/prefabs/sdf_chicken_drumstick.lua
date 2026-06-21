local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_chicken_drumstick.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_chicken_drumstick.tex"),

    Asset("ANIM", "anim/sdf_chicken_drumstick.zip"),
    Asset("ANIM", "anim/swap_sdf_chicken_drumstick.zip"),
}

prefabs = {
}

local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 8.5, 6.5, -.25 do
	pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
	if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
	    return pos
	end
    end
    return pos
end

local function OnHitWater(inst, attacker, target)
    SpawnPrefab("sdf_chicken_drumstick_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/dropwood")
    inst:Remove()
end

local function onthrown(inst)
    inst.AnimState:SetBank("swap_sdf_chicken_drumstick")
    inst.AnimState:SetBuild("swap_sdf_chicken_drumstick")
    inst.AnimState:PlayAnimation("thrown")
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_chicken_drumstick", "swap_sdf_chicken_drumstick")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_CHICKEN_DRUMSTICK_ATTACK_SPEED)

    inst:RemoveTag("special_action_toss")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)

    inst:AddTag("special_action_toss")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("sdf_chicken_drumstick")
    inst.AnimState:SetBuild("sdf_chicken_drumstick")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("projectile")
    inst:AddTag("meat")
    inst:AddTag("special_action_toss")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetAllowWaterFn
    inst.components.reticule.ease = true

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHitWater)

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_CHICKEN_DRUMSTICK_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_chicken_drumstick"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_chicken_drumstick.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    MakeHauntableLaunch(inst)

    return inst
end

local function OnDing(inst, target)
    if target ~= nil then
	local turkeyMeal = SpawnPrefab("turkeydinner")
	turkeyMeal.Transform:SetPosition(target.Transform:GetWorldPosition())

	local despawnPoof = SpawnPrefab("die_fx")
	despawnPoof.Transform:SetPosition(target.Transform:GetWorldPosition())
	target:Remove()
    end
end

local MUST_HAVE_TAGS = {"_combat","_health" }
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO","companion", "epic", "ghost", "structure", "wall"}
local AOE_RADIUS = TUNING.SDF_CHICKEN_DRUMSTICK_AOE_RADIUS
local AOE_HITCAP = TUNING.SDF_CHICKEN_DRUMSTICK_AOE_HITCAP

local function aoeCheck(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local affected_entity = TheSim:FindEntities(x, y, z, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--aoe Chicken
	if v.entity:IsVisible() then
	    OnDing(inst, v)
	end
	if i >= AOE_HITCAP then return end
    end
end

local function OnExplodeFn(inst)
    inst:DoTaskInTime(TUNING.SDF_CHICKEN_DRUMSTICK_DING_TIME, function()
	aoeCheck(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl1_ding")
	inst:DoTaskInTime(0.1, function()

	    local despawnPoof = SpawnPrefab("treegrowthsolution_use_fx")
	    despawnPoof.Transform:SetPosition(inst.Transform:GetWorldPosition())
	    inst:Remove()
	end)
    end)
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_chicken_drumstick")
    inst.AnimState:SetBuild("sdf_chicken_drumstick")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0.1, OnExplodeFn(inst))

    return inst
end

return  Prefab("common/inventory/sdf_chicken_drumstick", fn, assets),
	Prefab("common/inventory/sdf_chicken_drumstick_fx", fn2, assets)