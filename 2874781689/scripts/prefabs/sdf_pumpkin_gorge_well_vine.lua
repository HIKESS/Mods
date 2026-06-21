local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_vine.zip"),

    Asset("SOUND", "sound/tentacle.fsb"),
}

local prefabs = {
}

local function IsAlive(guy)
    return not guy.components.health:IsDead()
end

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "playerghost", "sdf_pumpking_friend", "prey", "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "animal" }
local function retargetfn(inst)
    return FindEntity(inst,
            TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_ATTACK_DIST,
            IsAlive,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS
        )
end

local function ShouldKeepTarget(inst, target)
    if inst.components.freezable and inst.components.freezable:IsFrozen() then
	return false
    end

    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)

        return distsq < TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_STOPATTACK_DIST * TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_STOPATTACK_DIST
    else
	inst.sg:GoToState("retract")
        return false
    end
end

local function onnewcombattarget(inst, data)
    if inst.components.freezable and inst.components.freezable:IsFrozen() then
	return
    end

    if data.target and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("hit") then --and not inst.components.health:IsDead() then
	inst.sg:GoToState("emerge")
    end
end

local function OnHit(inst, attacker, damage)
    if attacker.components.combat and not attacker:HasTag("player") and math.random() > 0.5 then
        attacker.components.combat:SetTarget(nil)
    end
end

local function WakeUp(inst)
    --unfreeze frozen
    if inst.components.freezable:IsFrozen() then
	inst.components.freezable:Thaw(TUNING.SDF_PUMPKIN_KING_FREEZE_TIME * 0.5)
    end
end

local function frozenState(inst)
    if inst.winterMode == true then
	if inst.components.freezable.coldness < 10 then
	    inst.components.freezable:AddColdness(15)
	end

	if inst.components.freezable.wearofftask ~= nil then
            inst.components.freezable.wearofftask:Cancel()
	end

	if inst.task ~= nil then
	    inst.task:Cancel()
	    inst.task = nil
	end

	if inst.hibernatetask ~= nil then
	    inst.hibernatetask:Cancel()
	end
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_FREEZE_TIME, frozenState)
    else

	if inst.task ~= nil then
	    inst.task:Cancel()
	    inst.task = nil
	end

	if inst.hibernatetask ~= nil then
	    inst.hibernatetask:Cancel()
	end
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_FREEZE_TIME, WakeUp)
    end
end

local function OnFrozenState(inst)
    if inst.winterMode == false then

	if inst.task ~= nil then
	    inst.task:Cancel()
	    inst.task = nil
	end

	if inst.hibernatetask ~= nil then
	    inst.hibernatetask:Cancel()
	end
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_FREEZE_TIME, WakeUp)
    else
	frozenState(inst)
    end
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .03 then
	if not inst.frozen then
            inst.frozen = true
	    inst.winterMode = true

	    --keep frozen
	    frozenState(inst)
	end
    else
	if inst.frozen == true then
	    inst.frozen = false
	    inst.winterMode = false
	end
    end
end

local function onSave(inst, data)
    data.typeid = inst.typeid
end

local function OnLoad(inst, data)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end
end

local function OnInit(inst)
    if inst.typeid == 0 then
	inst:Remove()
    else
	inst.task = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local VINE_SCALE = 1
    inst.Transform:SetScale(VINE_SCALE, VINE_SCALE, VINE_SCALE)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_well_vine")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_vine")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("fx")
    inst:AddTag("NOCLICK")
    inst:AddTag("soulless")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_gorge_well_vine")
    inst:AddTag("sdf_pumpkin_gorge_well_vine_withered")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKIN_KING_HEALTH * TUNING.SDF_PUMPKIN_KING_VINE_HEALTH_DAMAGE_PERCENT)
    inst.components.health:SetMinHealth(1)
    inst.components.health:SetInvincible(true)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(1, .5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    inst.components.combat:SetOnHit(OnHit)

    MakeLargeFreezableCharacter(inst)

    inst:AddComponent("follower")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_SANITY_AURA

    inst.typeid = 0
    inst.activeMode = true
    inst.retracted = true
    inst.winterMode = false

    inst.sleeptask = nil

    inst:ListenForEvent("newcombattarget", onnewcombattarget)

    inst:SetStateGraph("SGsdf_pumpkin_gorge_well_vine")

    inst.persists = false

    inst:ListenForEvent("freeze", OnFrozenState)

    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)

    --inst.task = inst:DoTaskInTime(0, OnInit)

    --inst.OnLoad = OnLoad
    --inst.OnSave = onSave

    return inst
end

return Prefab("sdf_pumpkin_gorge_well_vine", fn, assets, prefabs)