local assets =
{
    Asset("ANIM", "anim/sdf_stone_golem.zip"),
    Asset("SOUND", "sound/rocklobster.fsb"),
}

local prefabs ={
}

local SLEEP_DIST_FROMHOME_SQ = 1 * 1
local SLEEP_DIST_FROMTHREAT = 10 --10
local MAX_CHASEAWAY_DIST_SQ = 30 * 30 --30 * 30
local TAUNT_DIST = 16 --16
local TAUNT_PERIOD = 10 --2
local MAX_TARGET_SHARES = 15 --15
local SHARE_TARGET_DIST = 40 --40

local CHARACTER_TAGS = {"character"}
local function _BasicWakeCheck(inst)
    return (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
        or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())
        or GetClosestInstWithTag(CHARACTER_TAGS, inst, SLEEP_DIST_FROMTHREAT) ~= nil
end

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and inst:GetDistanceSqToPoint(homePos:Get()) < SLEEP_DIST_FROMHOME_SQ
        and not _BasicWakeCheck(inst)
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos ~= nil
	and inst:GetDistanceSqToPoint(homePos:Get()) >= SLEEP_DIST_FROMHOME_SQ)
        or _BasicWakeCheck(inst)
end

local function IsTauntable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
        and ((target:HasTag("shadowcreature") or (target:HasTag("hostile") and (target:HasTag("shadow_aligned")))))
end

local TAUNT_MUST_TAGS = { "_combat" }
local TAUNT_CANT_TAGS = { "INLIMBO", "player", "companion", "epic", "notaunt"}
local TAUNT_ONEOF_TAGS = { "locomotor"}

local function TauntCreatures(inst)
    if not inst.components.health:IsDead() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, y, z, TAUNT_DIST, TAUNT_MUST_TAGS, TAUNT_CANT_TAGS, TAUNT_ONEOF_TAGS)) do
            if IsTauntable(inst, v) then
                v.components.combat:SetTarget(inst)
            end
        end
    end
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "shadow_aligned", "shadow" }
local STONEGOLEMFRIEND_RANGE_PERCENT = 1

local function Retarget(inst, range)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil

    return not (homePos ~= nil and
	    inst:GetDistanceSqToPoint(homePos:Get()) >= TUNING.SDF_STONE_GOLEM_TARGET_DIST * TUNING.SDF_STONE_GOLEM_TARGET_DIST and
	    (inst.components.follower == nil or inst.components.follower.leader == nil))
        and FindEntity(
            inst,
            TUNING.SDF_STONE_GOLEM_TARGET_DIST,
            function(guy)
                if myLeader == guy then
                    return false
                end
                if myLeader ~= nil and myLeader:HasTag("player") and guy:HasTag("player") then
                    return false  -- don't automatically attack other players, wait for the leader's insturctions
                end
                local theirLeader = guy.components.follower ~= nil and guy.components.follower.leader or nil
                local bothFollowingSamePlayer = myLeader ~= nil and myLeader == theirLeader and myLeader:HasTag("player")
                if bothFollowingSamePlayer or (guy:HasTag("sdf_stone_golem_friend") and theirLeader == nil) then
                    return false
                end

                if not guy:IsNear(inst, TUNING.SDF_STONE_GOLEM_TARGET_DIST * STONEGOLEMFRIEND_RANGE_PERCENT) and guy:HasTag("sdf_stone_golem_friend") then
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

local function KeepTarget(inst, target)
    if target ~= nil and target:HasTag("player") and not target:HasTag("playerghost") and target:HasTag("sdf_stone_golem_target") then
	return true
    elseif target ~= nil and target:HasTag("player") then
	return false
    else
	local homePos = inst.components.knownlocations:GetLocation("home")
	return (inst.sg ~= nil and inst.sg:HasStateTag("running")) or (inst.components.follower ~= nil and inst.components.follower.leader ~= nil)
	    or (homePos ~= nil and target:GetDistanceSqToPoint(homePos:Get()) < MAX_CHASEAWAY_DIST_SQ)
    end
end

local function ShareTarget(dude)
    return dude:HasTag("sdf_stone_golem_friend")
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and attacker:HasTag("sdf_stone_golem_friend") then
        return
    end

    --lock on target
    if not attacker:HasTag("sdf_stone_golem_target") then
	attacker:AddTag("sdf_stone_golem_target")
    end

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, ShareTarget, MAX_TARGET_SHARES)
end

local loot = { "trinket_6", "cutstone", "cutstone", "rocks", "rocks", "flint", "flint" }
local CHEST_KINGDOM_MUST_HAVE_TAGS = {"sdf_chest_kingdom_locked"}
local CHEST_KINGDOM_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local CHEST_KINGDOM_AOE_RADIUS = 50
local function OnDeath(inst)

    --loots
    if inst.prefab == "sdf_stone_golem_armored" then
	local lootRng = math.random()
	if TUNING.SDF_STONE_GOLEM_OPTIMIZE_DATA_CHANCE >= lootRng then
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_type_a", 1)
	else
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_damaged", 1)
	end
    end
    if inst.prefab == "sdf_stone_golem_core" then
	local lootRng = math.random()
	if TUNING.SDF_STONE_GOLEM_OPTIMIZE_DATA_CHANCE >= lootRng then
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_type_c", 1)
	else
	    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_optimize_data_damaged", 1)
	end
    end

    --adjust kingdom chest lock
    local tx, ty, tz = inst.Transform:GetWorldPosition()
    local affected_entity = TheSim:FindEntities(tx, ty, tz, CHEST_KINGDOM_AOE_RADIUS, CHEST_KINGDOM_MUST_HAVE_TAGS,CHEST_KINGDOM_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find chest kingdom
	if v ~= nil then
	    if inst.prefab == "sdf_stone_golem_armored" then --and v.armoredLocked == true then
		v.armoredLocked = false
	    end
	    if inst.prefab == "sdf_stone_golem_core" then --and v.coreLocked == true then
		v.coreLocked = false
	    end
	end
    end

    return true
end

local function checkCanSummon(inst)
    if inst.prefab == "sdf_stone_golem_armored" and inst.summonCounter >= 1 then
	return true
    end

    return false
end

local LAVA_GOLEM_MUST_HAVE_TAGS = {"sdf_lava_golem_cradle"}
local LAVA_GOLEM_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local LAVA_GOLEM_AOE_RADIUS = 50

local function onSummonLavaGolem(inst)
    if checkCanSummon(inst) then
	local summonLocations = inst.summonCounter
	if summonLocations > 3 then
	    summonLocations = 3
	end

	local tx, ty, tz = inst.Transform:GetWorldPosition()

	local affected_entity = TheSim:FindEntities(tx, ty, tz, LAVA_GOLEM_AOE_RADIUS, LAVA_GOLEM_MUST_HAVE_TAGS, LAVA_GOLEM_CANT_HAVE_TAGS)
	for i, v in ipairs(affected_entity) do

	    --find lava golem cradle spots
	    if v ~= nil then

		--make lava golem
		if v.typeid <= summonLocations then
		    if v.components.childspawner then
			if v.components.childspawner.numchildrenoutside == 0 then
			    v:CreateGolemFn()
			end
		    end
		end
	    end
	end
	return false
    end
end

local function OnStopPushing(inst)
    --inst.Physics:Stop()
end

local function OnStartPushing(inst, doer)
    inst.Transform:SetRotation(doer:GetAngleToPoint(inst.Transform:GetWorldPosition()))
end

local ANIM_RADIUS =  1.42 --0.95
local PHYSICS_RADIUS = 1.5 --1.5
local function ConfigurePushingDist(inst)
    local anim_r = ANIM_RADIUS or 0
    local phys_r = PHYSICS_RADIUS or 0
    inst.components.pushable:SetTargetDist(anim_r + 0.2)
    inst.components.pushable:SetMinDist(math.max(anim_r - 0.2, phys_r + 0.05))
    inst.components.pushable:SetMaxDist(anim_r + 1)
end

local function onAddPushable(inst)
    if not inst.components.pushable then
	inst:AddComponent("pushable")
	inst.components.pushable:SetOnStartPushingFn(OnStartPushing)
	inst.components.pushable:SetOnStopPushingFn(OnStopPushing)
	inst.components.pushable:SetPushingSpeed(TUNING.SDF_STONE_GOLEM_SHIELD_PUSH_SPEED)
	ConfigurePushingDist(inst)
    end
end

local function onRemovePushable(inst)
    if inst.components.pushable then
	inst:RemoveComponent("pushable")
    end
end

local function onsave(inst, data)
    data.summonCounter = inst.summonCounter
end

local function onload(inst, data)
    if data then
	if data.summonCounter ~= nil then
            inst.summonCounter = data.summonCounter
	end
    end
    inst.taunttask:Cancel()
    inst.taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, TauntCreatures, math.random() * TAUNT_PERIOD)
end

local PATHCAPS = { ignorecreep = false }

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    --inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)
    MakeCharacterPhysics(inst, 1000, 1) --200
 
    --MakeCharacterPhysics(inst, inst.physicsradiusoverride, 1) --200

    local s = 1.2
    inst.Transform:SetScale(s,s,s)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sdf_stone_golem")
    inst.AnimState:SetBuild("sdf_stone_golem")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:SetMultColour(unpack({ 255/255, 102/255, 102/255, 1 })) --red 255/255, 153/255, 153/255
    inst.DynamicShadow:SetSize(1.75, 1.75)

    inst:AddTag("epic")
    inst:AddTag("largecreature")
    inst:AddTag("hostile")
    inst:AddTag("character")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("crazy")
    inst:AddTag("sdf_stone_golem")
    inst:AddTag("sdf_stone_golem_friend")
    inst:AddTag("sdf_haunted_ruins_lava_pond_weakness")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = PATHCAPS
    inst.components.locomotor.walkspeed = TUNING.SDF_STONE_GOLEM_ARMORED_WALK_SPEED

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_STONE_GOLEM_HEALTH)

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(TUNING.SDF_STONE_GOLEM_PLANAR_DEFENSE)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_STONE_GOLEM_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_STONE_GOLEM_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SDF_STONE_GOLEM_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("timer")

    inst:AddComponent("follower")
    inst:AddComponent("inventory")
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_STONE_GOLEM_SANITY_AURA

    MakeHauntablePanic(inst)

    inst:SetStateGraph("SGsdf_stone_golem")
    inst:SetBrain(require "brains/sdf_stone_golembrain")

    inst.damageUntilShield = (TUNING.SDF_STONE_GOLEM_HEALTH / TUNING.SDF_STONE_GOLEM_SHIELD_THRESHOLD)
    inst.avoidProjectileAttacks = TUNING.SDF_STONE_GOLEM_SHIELD_ARMORED_AVOID_PROJECTILE_ATTACKS
    inst.shieldTime = TUNING.SDF_STONE_GOLEM_SHIELD_DURATION
    inst.summonCounter = 0
    inst.scale = TUNING.SDF_STONE_GOLEM_MAX_SCALE

    inst.AddPushableFn = function() onAddPushable(inst) end
    inst.RemovePushableFn = function() onRemovePushable(inst) end
    inst.SummonLavaGolemFn = function() onSummonLavaGolem(inst) end

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    inst.taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, TauntCreatures, 0)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    --inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)
    --MakeCharacterPhysics(inst, inst.physicsradiusoverride, 1) --200

    MakeCharacterPhysics(inst, 1000, 1) --200

    local s = 1.2
    inst.Transform:SetScale(s,s,s)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sdf_stone_golem")
    inst.AnimState:SetBuild("sdf_stone_golem")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:SetMultColour(unpack({ 102/255, 179/255, 255/255, 1 })) --blue 153/255, 204/255, 255/255
    inst.DynamicShadow:SetSize(1.75, 1.75)

    inst:AddTag("epic")
    inst:AddTag("largecreature")
    inst:AddTag("hostile")
    inst:AddTag("character")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("crazy")
    inst:AddTag("sdf_stone_golem")
    inst:AddTag("sdf_stone_golem_friend")
    inst:AddTag("sdf_haunted_ruins_lava_pond_weakness")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = PATHCAPS
    inst.components.locomotor.walkspeed = TUNING.SDF_STONE_GOLEM_CORE_WALK_SPEED

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_STONE_GOLEM_HEALTH)

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(TUNING.SDF_STONE_GOLEM_PLANAR_DEFENSE)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_STONE_GOLEM_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_STONE_GOLEM_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SDF_STONE_GOLEM_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("timer")

    inst:AddComponent("follower")
    inst:AddComponent("inventory")
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_STONE_GOLEM_SANITY_AURA

    MakeHauntablePanic(inst)

    inst:SetStateGraph("SGsdf_stone_golem")
    inst:SetBrain(require "brains/sdf_stone_golembrain")

    inst.damageUntilShield = (TUNING.SDF_STONE_GOLEM_HEALTH / TUNING.SDF_STONE_GOLEM_SHIELD_THRESHOLD)
    inst.avoidProjectileAttacks = TUNING.SDF_STONE_GOLEM_SHIELD_CORE_AVOID_PROJECTILE_ATTACKS
    inst.shieldTime = (((TUNING.SDF_STONE_GOLEM_HEALTH / TUNING.SDF_STONE_GOLEM_SHIELD_THRESHOLD) / (TUNING.SDF_STONE_GOLEM_HEALTH * TUNING.SDF_STONE_GOLEM_HEALTH_SHIELD_REGEN_PERCENT)) + TUNING.SDF_STONE_GOLEM_SHIELD_DURATION)
    --inst.shieldTime = (((TUNING.SDF_STONE_GOLEM_HEALTH / TUNING.SDF_STONE_GOLEM_SHIELD_THRESHOLD) / TUNING.SDF_STONE_GOLEM_HEALTH_SHIELD_REGEN_AMOUNT) + TUNING.SDF_STONE_GOLEM_SHIELD_DURATION)
    inst.scale = TUNING.SDF_STONE_GOLEM_MAX_SCALE
    inst.summonCounter = 0

    inst.AddPushableFn = function() onAddPushable(inst) end
    inst.RemovePushableFn = function() onRemovePushable(inst) end
    inst.SummonLavaGolemFn = function() onSummonLavaGolem(inst) end

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    inst.taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, TauntCreatures, 0)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("sdf_stone_golem_armored", fn, assets, prefabs),
	Prefab("sdf_stone_golem_core", fn2, assets, prefabs)