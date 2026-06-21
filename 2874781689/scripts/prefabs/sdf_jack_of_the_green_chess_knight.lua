local assets =
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_chess_knight.zip"),
    Asset("SOUND", "sound/chess.fsb"),
}

local prefabs = {
}

local brain = require "brains/sdf_jack_of_the_green_chess_knightbrain"

local SLEEP_DIST_FROMHOME_SQ = 1 * 1
local SLEEP_DIST_FROMTHREAT = 10
local MAX_CHASEAWAY_DIST_SQ = 10 * 10
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 10

SetSharedLootTable("knight_jack_of_the_green",
{
    {"cutgrass", 1.0},
    {"cutgrass", 1.0},
    {"cutgrass", 1.0},
    {"nightmarefuel", 1.0},
    {"purplegem", 1.0},
    {"livinglog", 1.0},
    {"livinglog", 1.0},
})


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
    return (homePos ~= nil and
            inst:GetDistanceSqToPoint(homePos:Get()) >= SLEEP_DIST_FROMHOME_SQ)
        or _BasicWakeCheck(inst)
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local CHESSFRIEND_RANGE_PERCENT = 0.5

local function Retarget(inst, range)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil

    return not (homePos ~= nil and
                inst:GetDistanceSqToPoint(homePos:Get()) >= TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_TARGET_DIST * TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_TARGET_DIST and
                (inst.components.follower == nil or inst.components.follower.leader == nil))
        and FindEntity(
            inst,
            TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_TARGET_DIST,
            function(guy)
                if myLeader == guy then
                    return false
                end
                if myLeader ~= nil and myLeader:HasTag("player") and guy:HasTag("player") then
                    return false  -- don't automatically attack other players, wait for the leader's insturctions
                end
                local theirLeader = guy.components.follower ~= nil and guy.components.follower.leader or nil
                local bothFollowingSamePlayer = myLeader ~= nil and myLeader == theirLeader and myLeader:HasTag("player")
                if bothFollowingSamePlayer or (guy:HasTag("chess") and theirLeader == nil) then
                    return false
                end

                if not guy:IsNear(inst, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_TARGET_DIST * CHESSFRIEND_RANGE_PERCENT) and guy:HasTag("chessfriend") then
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
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (inst.sg ~= nil and inst.sg:HasStateTag("running")) or (inst.components.follower ~= nil and inst.components.follower.leader ~= nil)
        or (homePos ~= nil and target:GetDistanceSqToPoint(homePos:Get()) < MAX_CHASEAWAY_DIST_SQ)
end

local function _ShareTargetFn(dude)
    return dude:HasTag("chess")
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and attacker:HasTag("chess") then
        return
    end

    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, _ShareTargetFn, MAX_TARGET_SHARES)
end

local function RememberKnownLocation(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, 0.5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("knight")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_chess_knight")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("chess")
    inst:AddTag("knight")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst.soundpath = "dontstarve/creatures/knight_nightmare/"
    --inst.effortsound = "dontstarve/creatures/knight_nightmare/rattle"

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("knight_jack_of_the_green")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_WALK_SPEED

    inst:SetStateGraph("SGsdf_jack_of_the_green_chess_knight")
    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("health")
    inst.components.health.fire_damage_scale = TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_FIRE_DAMAGE_SCALE
    inst.components.health:SetMaxHealth(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_HEALTH)
    --inst.components.health:StartRegen(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_HEALTH_REGEN_AMOUNT, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_HEALTH_REGEN_PERIOD)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_ATTACK_PERIOD)

    inst:AddComponent("follower")

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_SANITY_AURA

    MakeHauntablePanic(inst)

    inst:DoTaskInTime(0, RememberKnownLocation)

    MakeMediumBurnableCharacter(inst, "spring")
    inst.components.burnable.flammability = TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_FLAMMABILITY
    inst.components.propagator.acceptsheat = true

    MakeMediumFreezableCharacter(inst, "spring")

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("sdf_jack_of_the_green_chess_knight", fn, assets)
