local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_creeper.zip"),
}

local prefabs =
{
}

local brain = require("brains/sdf_pumpking_creeperbrain")


local sounds =
{
    attack = "hookline/creatures/squid/attack",
    bite = "hookline/creatures/squid/gobble",
    taunt = "hookline/creatures/squid/taunt",
    death = "hookline/creatures/squid/death",
    sleep = "hookline/creatures/squid/sleep",
    hurt = "hookline/creatures/squid/hit",
    gobble = "hookline/creatures/squid/gobble",
    spit = "hookline/creatures/squid/spit",
    swim = "turnoftides/common/together/water/swim/medium",
}

local WAKE_TO_FOLLOW_DISTANCE = 8
local SLEEP_NEAR_HOME_DISTANCE = 10
local SHARE_TARGET_DIST = 30

--Called from stategraph
local function LaunchProjectile(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("sdf_pumpking_guttedsplat")
    projectile.Transform:SetPosition(x, y, z)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.SDF_PUMPKING_CREEPER_GUTS_RANGE
    local speed = easing.linear(rangesq, 15, 1, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-35)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
end

local function shouldputoutfire(inst)
    if inst.components.timer:TimerExists("putOutFire_cooldown") then
        return false
    end

    return true
end

local function OnFindFire(inst, firePos)
    local ents = TheSim:FindEntities(firePos.x, firePos.y, firePos.z, 1, nil, nil, nil)
    for i, v in ipairs(ents) do
	if v:HasTag("campfire") or v:HasTag("wildfireprotected") then
	    return
	end
    end

    if inst:IsAsleep() then
    elseif shouldputoutfire(inst) then
        inst:PushEvent("putoutfire", { firePos = firePos })
    end
end

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    -- this will always return false at the momnent, until we decide how they should naturally sleep.
    --return false
    return not (inst.components.combat and inst.components.combat.target)
        and not (inst.components.burnable and inst.components.burnable:IsBurning())
	and not (inst.components.freezable and inst.components.freezable:IsFrozen())
        and (not inst.components.homeseeker or inst:IsNear(inst.components.homeseeker.home, SLEEP_NEAR_HOME_DISTANCE))
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function FocusTarget(inst, target)
    inst._focustarget = target
    inst:AddTag("notaunt")

    inst.components.combat:SetTarget(target)
end

local function CheckFocusTarget(inst)
    if inst._focustarget ~= nil and (not inst._focustarget:IsValid()
	or (inst._focustarget.components.health ~= nil and inst._focustarget.components.health:IsDead())
	or inst._focustarget:HasTag("playerghost")) then
	-- Our focus target isn't a good target anymore; let's clean it up.
	inst._focustarget = nil
	inst:RemoveTag("notaunt")
    end

    return inst._focustarget
end

local RETARGET_DIST = 12 --12
local RETARGET_MUST_TAGS = { "_combat", "_health", "character" }
local RETARGET_CANT_TAGS = { "DECOR", "sdf_pumpkin_king", "sdf_pumpkin_king_vine_end", "sdf_pumpking_friend", "FX", "INLIMBO", "NOCLICK", "notarget", "playerghost", "wall" }
local function Retarget(inst)
    -- Keep on our focus target if we have one, otherwise do a search.
    local ftarget = CheckFocusTarget(inst)

    if ftarget ~= nil then
        return ftarget, not inst.components.combat:TargetIs(ftarget)
    else
        return FindEntity(inst,
	    RETARGET_DIST,
	    function(guy)
		return inst.components.combat:CanTarget(guy)
	    end,
	    RETARGET_MUST_TAGS,
	    RETARGET_CANT_TAGS
	) or nil
    end
end

local KEEPTARGET_DIST = 12
local function KeepTarget(inst, target)
    local ftarget = CheckFocusTarget(inst)
    return (ftarget ~= nil and inst.components.combat:TargetIs(ftarget))
        or (inst.components.combat:CanTarget(target) and inst:IsNear(target, KEEPTARGET_DIST))
end

local MAX_TARGET_SHARES = 20 --20
local SHARE_TARGET_DIST = 15 --15
local function ShareTarget(dude)
    return dude:HasTag("sdf_pumpking_creeper")
end

local function OnAttacked(inst, data)
    local ftarget = CheckFocusTarget(inst)
    if ftarget == nil and (data.attacker ~= nil and not data.attacker:HasTag("sdf_pumpking_friend")) then
        inst.components.combat:SetTarget(data.attacker)
	inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, ShareTarget, MAX_TARGET_SHARES)
    end
end

local function WakeUp(inst)
    --unfreeze frozen
    if inst.components.freezable:IsFrozen() then
	inst.components.freezable:Thaw(TUNING.SDF_PUMPKING_CREEPER_FREEZE_TIME * 0.5)
    end
end

local function frozenState(inst)
    if inst.winterMode == true then
	if inst.components.freezable.coldness < 10 then
	    inst.components.freezable:AddColdness(15)
	end
	inst.components.freezable.damagetobreak = TUNING.SDF_PUMPKING_CREEPER_HEALTH * 0.25

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
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_CREEPER_FREEZE_TIME, frozenState)
    else

	if inst.task ~= nil then
	    inst.task:Cancel()
	    inst.task = nil
	end

	if inst.hibernatetask ~= nil then
	    inst.hibernatetask:Cancel()
	end
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_CREEPER_FREEZE_TIME, WakeUp)
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
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKING_CREEPER_FREEZE_TIME, WakeUp)
    else
	frozenState(inst)
    end
end

local function OnUnFrozenState(inst)
    inst.components.health:Kill()
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .02 then
	if not inst.frozen then
            inst.frozen = true
	    inst.winterMode = true

	    --keep frozen
	    frozenState(inst)
	end
    else
	inst.frozen = false
	inst.winterMode = false
    end
end

local function TryRegenHealth(inst)
    if inst.components.health and not inst.components.health:IsDead() then
	if inst.components.health:GetPercent() >= 1 then
	    return
	end
	if inst.components.combat and ((GetTime() - inst.components.combat.laststartattacktime) > TUNING.SDF_PUMPKING_HEALTH_REGEN_IDLE_THRESHOLD_TIME)
	    and ((GetTime() - inst.components.combat.lastwasattackedtime) > TUNING.SDF_PUMPKING_HEALTH_REGEN_IDLE_THRESHOLD_TIME) then 
	    inst.components.health:DoDelta(TUNING.SDF_PUMPKING_HEALTH_REGEN_AMOUNT)
	end
    end 
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetSixFaced()

    inst:AddTag("hostile")
    inst:AddTag("veggie")
    inst:AddTag("character")
    inst:AddTag("elemental")
    inst:AddTag("scarytoprey")
    inst:AddTag("soulless")
    inst:AddTag("lifedrainable")
    inst:AddTag("NPCcanaggro")
    inst:AddTag("likewateroffducksback")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpking_creeper")

    inst.AnimState:SetBank("sdf_pumpking_creeper")
    inst.AnimState:SetBuild("sdf_pumpking_creeper")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = sounds

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.SDF_PUMPKING_CREEPER_RUNSPEED
    inst.components.locomotor.walkspeed = TUNING.SDF_PUMPKING_CREEPER_WALKSPEED
    inst.components.locomotor.skipHoldWhenFarFromHome = true

    inst:AddComponent("embarker")
    inst.components.embarker.embark_speed = inst.components.locomotor.runspeed
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetEnterWaterFn(
        function(inst)
            inst.hop_distance = inst.components.locomotor.hop_distance
            inst.components.locomotor.hop_distance = 4
            inst.DynamicShadow:Enable(false)
        end)
    inst.components.amphibiouscreature:SetExitWaterFn(
        function(inst)
            if inst.hop_distance then
                inst.components.locomotor.hop_distance = inst.hop_distance
            end
            inst.DynamicShadow:Enable(true)
        end)

    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKING_CREEPER_HEALTH)
    inst.components.health.fire_damage_scale = TUNING.SDF_PUMPKING_CREEPER_FIRE_DAMAGE

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_PUMPKING_CREEPER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_PUMPKING_CREEPER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound(inst.sounds.hurt)
    inst.components.combat:SetRange(TUNING.SDF_PUMPKING_CREEPER_TARGET_RANGE, TUNING.SDF_PUMPKING_CREEPER_ATTACK_RANGE)
    inst.components.combat:EnableAreaDamage(true)
    inst.components.combat:SetAreaDamage(TUNING.SDF_PUMPKING_CREEPER_ATTACK_RANGE, 1, function(ent, inst)
        if not ent:HasTag("sdf_pumpking_friend") then
            return true
        else
            if ent:IsValid() then
                ent.SoundEmitter:PlaySound("hookline/creatures/squid/slap")
                local x,y,z = ent.Transform:GetWorldPosition()
                local angle = inst:GetAngleToPoint(x,y,z)
                ent.Transform:SetRotation(angle)
                ent.sg:GoToState("fling")
            end
        end
    end)

    inst.components.combat.battlecryenabled = false

    inst:AddComponent("firedetector")
    inst.components.firedetector:SetOnFindFireFn(OnFindFire)
    local isemergency = inst.components.firedetector:IsEmergency()
    if not isemergency then
        local randomizedStartTime = POPULATING
        inst.components.firedetector:Activate(randomizedStartTime)
    end

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.ELEMENTAL, FOODGROUP.OMNI})
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    --inst:AddComponent("follower")
    inst:AddComponent("entitytracker")
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    inst:AddComponent("timer")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_PUMPKING_CREEPER_SANITY_AURA

    MakeHauntablePanic(inst)

    MakeTinyFreezableCharacter(inst) --, "squid_body")
    inst.components.freezable:SetResistance(3)
    MakeSmallBurnableCharacter(inst, "squid_body")

    inst:SetStateGraph("SGsdf_pumpking_creeper")
    inst:SetBrain(brain)

    inst.summoned = false
    inst.winterMode = false

    inst.LaunchProjectile = LaunchProjectile

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("freeze", OnFrozenState)
    inst:ListenForEvent("unfreeze", OnUnFrozenState)

    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)

    inst:DoPeriodicTask(2, TryRegenHealth)

    return inst
end

return Prefab("sdf_pumpking_creeper", fn, assets, prefabs)