local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_standard_buckshots.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_standard_buckshots.tex"),

    Asset("ANIM", "anim/sdf_standard_buckshots.zip"),
}

prefabs = {
}

local function OnHit(inst, owner, target)
    local x,_,z=target.Transform:GetWorldPosition()
    local hitFx = SpawnPrefab("cannonball_used").Transform:SetPosition(x,_,z)

    local impactfx = SpawnPrefab("impact")
    if impactfx then
	local follower = impactfx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	--impactfx:FacePoint(inst.Transform:GetWorldPosition())
        if owner ~= nil and owner:IsValid() then
            impactfx:FacePoint(owner.Transform:GetWorldPosition())
        end
	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("monkeyisland/cannon/hit")
	end
    end

    inst:Remove()
end

local function OnThrown(inst, data)
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

    inst.AnimState:SetBank("sdf_standard_buckshots")
    inst.AnimState:SetBuild("sdf_standard_buckshots")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("weapon")
    inst:AddTag("projectile")
    inst:AddTag("sdf_blunderbuss_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --allows ranged power attacks
    inst:AddComponent("sdf_ranged_power_attack")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_STANDARD_BUCKSHOTS_DAMAGE)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_STANDARD_BUCKSHOTS_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(1)
    inst.components.projectile:SetLaunchOffset(Vector3(0.35, 1, 0))
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile.range = TUNING.SDF_BLUNDERBUSS_RANGE + 4
    inst.components.projectile.has_damage_set = true

    inst:ListenForEvent("onthrown", OnThrown)

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_STANDARD_BUCKSHOTS_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_standard_buckshots"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_standard_buckshots.xml"

    MakeHauntableLaunch(inst)

    return inst
end

local NOTAGS_VANILLA = {"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", "abigail", "wall", "companion", "shadowminion", "player"}
local NOTAGS_PVP = {"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", "playerghost", "corpse"}
local WORK_ACTIONS = {[ACTIONS.CHOP] = true, [ACTIONS.MINE] = true, [ACTIONS.HAMMER] = true}

local function OnHitBombard(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()--target.Transform:GetWorldPosition()
    local weapon = inst.components.complexprojectile.owningweapon 
		
    for _, ent in pairs(TheSim:FindEntities(x, y, z, TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_RADIUS, nil, TheNet:GetPVPEnabled() and NOTAGS_PVP or NOTAGS_VANILLA)) do
	if ent.components.workable and ent.components.workable:CanBeWorked() and WORK_ACTIONS[ent.components.workable:GetWorkAction()] then
		
	    if (not TheNet:GetPVPEnabled()) and ent:HasAnyTag{"structure", "oceantrawler"} then 
		ent.components.workable:WorkedBy(attacker or inst, 0)
	    else 
		ent.components.workable:WorkedBy(attacker or inst, TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_WORK)
	    end 
	end 
		
	if ent:IsValid() and (not ent:IsInLimbo()) and ent.components.combat then 
	    ent.components.combat:GetAttacked(attacker, (TUNING.SDF_STANDARD_BUCKSHOTS_DAMAGE * TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_DAMAGE_MULTI), weapon)
	end 
    end
	
    local explode_small = SpawnPrefab("explode_small")
    explode_small.Transform:SetPosition(x, y, z)
	
    local impact = SpawnPrefab("impact")
    impact.Transform:SetPosition(x, y, z)
    impact:FacePoint(attacker.Transform:GetWorldPosition())
	
    inst:Remove()		
end 

local function OnLaunchBombard(inst, data)
    inst.AnimState:PlayAnimation("thrown")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function fn2()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
	
    inst.AnimState:SetBank("sdf_standard_buckshots")
    inst.AnimState:SetBuild("sdf_standard_buckshots")
    inst.AnimState:PlayAnimation("idle")
	
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetDontRemoveOnSleep(true) 
	
    inst:AddTag"projectile"
    inst:AddTag"sharp"
	
    if not TheWorld.ismastersim then 
	return inst 
    end 
	
    inst:AddComponent"complexprojectile"
    inst.components.complexprojectile:SetOnLaunch(OnLaunchBombard)
    inst.components.complexprojectile.onhitfn = OnHitBombard
    inst.components.complexprojectile:SetHorizontalSpeed(TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_PROJECTILE_SPEED)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(1.2, 0.5, -1))
    inst.components.complexprojectile.usehigharc = true
    inst.components.complexprojectile:SetGravity(-100)

    inst.persists = false
	
    return inst
end

return  Prefab("common/inventory/sdf_standard_buckshots", fn, assets),
	Prefab("sdf_standard_buckshots_bombard_projectile", fn2, assets)