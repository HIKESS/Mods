local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_gourd_vine.zip"),

    Asset("SOUND", "sound/tentacle.fsb"),
}

local prefabs = {
}

local function Emerge(inst)
    if inst.retracted then
        inst.retracted = false
        inst:PushEvent("emerge")
    end
end

local function Retract(inst)
    if not inst.retracted then
        inst.retracted = true
        inst:PushEvent("retract")
    end
end

local function OnFullRetreat(inst)
    if inst:IsAsleep() then
        inst:Remove()
    else
        inst.retreat = true
    end
end

local function IsAlive(guy)
    return not guy.components.health:IsDead()
end

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "playerghost", "sdf_pumpking_friend", "prey", "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "animal" }
local function retargetfn(inst)
    return FindEntity(inst,
            TUNING.SDF_PUMPKING_GOURD_VINE_ATTACK_DIST,
            IsAlive,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS
        )
end

local function ShouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)

        return distsq < TUNING.SDF_PUMPKING_GOURD_VINE_STOPATTACK_DIST * TUNING.SDF_PUMPKING_GOURD_VINE_STOPATTACK_DIST
    else
	Retract(inst)
        return false
    end
end

local function onnewcombattarget(inst, data)
    if data.target and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("hit") and not inst.components.health:IsDead() then
	Emerge(inst)
    end
end

local function OnHit(inst, attacker, damage)
    if attacker.components.combat and not attacker:HasTag("player") and math.random() > 0.5 then
        attacker.components.combat:SetTarget(nil)
        if inst.components.health.currenthealth and inst.components.health.currenthealth < 0 then
            inst.components.health:DoDelta(damage*.6, false, attacker)
        end
    end
end

local function CustomOnHaunt(inst, haunter)
    if math.random() < TUNING.HAUNT_CHANCE_HALF and
        not inst.components.health:IsDead() then
        inst.components.health:Kill()
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddPhysics()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Physics:SetCylinder(.6, 2)

    local VINE_SCALE = .95
    inst.Transform:SetScale(VINE_SCALE, VINE_SCALE, VINE_SCALE)

    inst.AnimState:SetBank("sdf_pumpking_gourd_vine")
    inst.AnimState:SetScale(VINE_SCALE, VINE_SCALE)
    inst.AnimState:SetBuild("sdf_pumpking_gourd_vine")
    inst.AnimState:PlayAnimation("breach_pre")

    inst:AddTag("hostile")
    inst:AddTag("character")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("NPCcanaggro")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpking_gourd_vine")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKING_GOURD_VINE_HEALTH)
    inst.components.health.fire_damage_scale = TUNING.SDF_PUMPKING_GOURD_FIRE_DAMAGE

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.SDF_PUMPKING_GOURD_VINE_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.SDF_PUMPKING_GOURD_VINE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_PUMPKING_GOURD_VINE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(1, .5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    inst.components.combat:SetOnHit(OnHit)

    MakeLargeFreezableCharacter(inst)

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_PUMPKING_GOURD_VINE_SANITY_AURA

    AddHauntableCustomReaction(inst, CustomOnHaunt)

    inst.lifeSpan = TUNING.SDF_PUMPKING_GOURD_VINE_LIFE_SPAN
    inst.retracted = true
    inst.Emerge = Emerge
    inst.Retract = Retract

    inst.sleeptask = nil
    inst.persists = false

    inst:ListenForEvent("newcombattarget", onnewcombattarget)
    inst:ListenForEvent("full_retreat", OnFullRetreat)

    inst:SetStateGraph("SGsdf_pumpking_gourd_vine")

    return inst
end

return Prefab("sdf_pumpking_gourd_vine", fn, assets, prefabs)