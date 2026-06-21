local assets =
{
    Asset("ANIM", "anim/sdf_lava_golem.zip"),
    Asset("ANIM", "anim/sdf_lava_golem_fireball.zip"),
}

local prefabs = {

}

local MAX_TARGET_SHARES = 15 --15
local SHARE_TARGET_DIST = 40 --40

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "shadow_aligned", "shadow" }
local STONEGOLEMFRIEND_RANGE_PERCENT = 1

local function retargetfn(inst, range)
    return FindEntity(
            inst,
            TUNING.SDF_LAVA_GOLEM_ATTACK_RANGE,
            function(guy)
                if not guy:IsNear(inst, TUNING.SDF_LAVA_GOLEM_ATTACK_RANGE * STONEGOLEMFRIEND_RANGE_PERCENT) and guy:HasTag("sdf_stone_golem_friend") then
                    return false
                end

		if not guy:HasTag("sdf_stone_golem_target") then
		    return false
		end
                return inst.components.combat:CanTarget(guy)
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS
        )
        or nil
end

local function keeptargetfn(inst, target)
    if target ~= nil and target:HasTag("player") and not target:HasTag("playerghost") and target:HasTag("sdf_stone_golem_target") then
	return true
    elseif target ~= nil and target:HasTag("player") then
	return false
    end
end

local function ShareTarget(dude)
    return dude:HasTag("sdf_stone_golem_friend")
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and attacker:HasTag("sdf_stone_golem") then
        return
    end

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, ShareTarget, MAX_TARGET_SHARES)
end

local function TryRegenHealth(inst)
    if inst.components.health and not inst.components.health:IsDead() then
	if inst.components.combat and ((GetTime() - inst.components.combat.laststartattacktime) > TUNING.SDF_LAVA_GOLEM_HEALTH_REGEN_IDLE_THRESHOLD_TIME)
	    and ((GetTime() - inst.components.combat.lastwasattackedtime) > TUNING.SDF_LAVA_GOLEM_HEALTH_REGEN_IDLE_THRESHOLD_TIME) then 
	    inst.components.health:DoDelta(-TUNING.SDF_LAVA_GOLEM_HEALTH_REGEN_IDLE_AMOUNT)
	else
	    inst.components.health:DoDelta(TUNING.SDF_LAVA_GOLEM_HEALTH_REGEN_BUSY_AMOUNT)
	end
    end 
end

local function OnInit(inst)
    retargetfn(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetRadius(2 + 2)
    inst.Light:SetColour(1, 0.55, 0)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    MakeCharacterPhysics(inst, 50, 0.7)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sdf_lava_golem")
    inst.AnimState:SetBuild("sdf_lava_golem")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("fireimmune")
    inst:AddTag("flying")
    inst:AddTag("notraptrigger")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("scarytoprey")
    inst:AddTag("hostile")
    inst:AddTag("character")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("crazy")
    inst:AddTag("sdf_stone_golem_friend")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_LAVA_GOLEM_HEALTH)
    inst.components.health:SetMaxDamageTakenPerHit(TUNING.SDF_LAVA_GOLEM_MAX_DAMAGE_PER_HIT)
    inst.components.health.externalfiredamagemultipliers:SetModifier(inst, 1 - TUNING.SDF_LAVA_GOLEM_FIRE_RESIST)
    --inst.components.health.fire_damage_scale = 0

    inst:AddComponent("planarentity")
		
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_LAVA_GOLEM_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_LAVA_GOLEM_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, retargetfn)
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)
    inst.components.combat:SetRange(TUNING.SDF_LAVA_GOLEM_ATTACK_RANGE)
	
    local SuggestTarget = inst.components.combat.SuggestTarget
    inst.components.combat.SuggestTarget = function(self, target, ...)
	if target and target:IsNear(self.inst, self.attackrange + 2) then 
	    return SuggestTarget(self, target, ...)
	end 
    end

    inst:AddComponent("inventory")
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("follower")
    inst.components.follower.neverexpire = true
    inst.components.follower.keepdeadleader = true

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_LAVA_GOLEM_SANITY_AURA

    inst:SetStateGraph("SGsdf_lava_golem")
    inst:SetBrain(require "brains/sdf_lava_golembrain")

    inst:DoPeriodicTask(1, TryRegenHealth)

    inst:ListenForEvent("attacked", OnAttacked)

    ------------------------------
    local weapon = CreateEntity()
    weapon.entity:AddTransform()
    MakeInventoryPhysics(weapon)
	
    weapon:AddComponent("weapon")
    weapon.components.weapon:SetDamage(0)
    weapon.components.weapon:SetRange(TUNING.SDF_LAVA_GOLEM_ATTACK_RANGE, TUNING.SDF_LAVA_GOLEM_ATTACK_RANGE + 2)
    weapon.components.weapon:SetProjectile("sdf_lava_golem_fireball")

    weapon:AddComponent("inventoryitem")
    weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)

    weapon:AddComponent("equippable")
	
    weapon.persists = false
	
    inst.weapon = weapon
    inst.components.inventory:Equip(inst.weapon)
    ------------------------------

    inst.persists = true

    inst.task = inst:DoTaskInTime(0, OnInit)

    return inst
end

local function OnPreHit(inst, attacker, target)
    if target._sdf_lava_golem_fireball_debufftask ~= nil and target:HasTag("player") then
	inst.components.weapon:SetDamage(0)
	inst.components.planardamage:SetBaseDamage(0)
	inst.components.projectile.has_damage_set = false
    end
end

local function OnHit(inst, owner, target)
    if target ~= nil and target:IsValid() and target:HasTag("player") then
	if target._sdf_lava_golem_fireball_debufftask == nil then
	    target._sdf_lava_golem_fireball_debufftask = target:DoTaskInTime(TUNING.SDF_LAVA_GOLEM_PROJECTILE_IFRAME_TIME, function(i)
		i._sdf_lava_golem_fireball_debufftask = nil
	    end)
	end
    end

    inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover", inst.Remove)
end

local function OnMiss(inst) 
    inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover", inst.Remove)
end



local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.entity:AddLight()

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(0.3) --0.6
    inst.Light:SetRadius(2) --4
    inst.Light:SetColour(1, 0.55, 0)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.Transform:SetScale(0.6, 0.6, 0.6)

    inst.AnimState:SetBank("sdf_lava_golem_fireball")
    inst.AnimState:SetBuild("sdf_lava_golem_fireball")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetMultColour(1, 0.7, 0.7, 1)
    inst.AnimState:SetFinalOffset(-1)

    inst.Transform:SetTwoFaced()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("weapon")
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_LAVA_GOLEM_ATTACK_DAMAGE)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_LAVA_GOLEM_PLANAR_DAMAGE)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_LAVA_GOLEM_PROJECTILE_SPEED)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(0.5)
    inst.components.projectile:SetOnPreHitFn(OnPreHit)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetLaunchOffset(Vector3(2, 0.3, 2))
    inst.components.projectile.has_damage_set = true

    inst:DoTaskInTime(2, OnMiss)

    return inst
end

return Prefab("sdf_lava_golem", fn, assets, prefabs), 
	Prefab("sdf_lava_golem_fireball", fn2, assets, prefabs)