local assets =
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_chess_rook.zip"),
    Asset("SOUND", "sound/chess.fsb"),
}

local prefabs = {
}

local brain = require "brains/sdf_jack_of_the_green_chess_rookbrain"

local SLEEP_DIST_FROMHOME_SQ = 1 * 1
local SLEEP_DIST_FROMTHREAT = 10
local MAX_CHASEAWAY_DIST_SQ = 10 * 10
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 10

SetSharedLootTable("rook_jack_of_the_green",
{
    {"cutgrass",            1.0},
    {"cutgrass",            1.0},
    {"cutgrass",            1.0},
    {"cutgrass",            1.0},
    {"cutgrass",            1.0},
    {"cutgrass",            1.0},
    {"nightmarefuel",    1.0},
    {"nightmarefuel",    1.0},
    {"livinglog", 1.0},
    {"livinglog", 1.0},
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
                inst:GetDistanceSqToPoint(homePos:Get()) >= TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_TARGET_DIST * TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_TARGET_DIST and
                (inst.components.follower == nil or inst.components.follower.leader == nil))
        and FindEntity(
            inst,
            TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_TARGET_DIST,
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

                if not guy:IsNear(inst, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_TARGET_DIST * CHESSFRIEND_RANGE_PERCENT) and guy:HasTag("chessfriend") then
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


local MUST_HAVE_TAGS = {"player"}
local CANT_HAVE_TAGS = {"INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 8

local function aoeBookOfGallowmereCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()
    local playerBookOfGallowmereDrops = false

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find sdf
	if v ~= nil then
	    if v.prefab == "sdf" then
		local riddleMaster = v.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleMaster()
		local bookOfGallowmereEnabled = v.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmere()
		if riddleMaster == true and bookOfGallowmereEnabled == false then
		    playerBookOfGallowmereDrops = true
		end
	    end
	end
    end
    return playerBookOfGallowmereDrops
end

local function OnDeath(inst)
    local BookOfGallowmereDrops = aoeBookOfGallowmereCheck(inst)
    if BookOfGallowmereDrops == true then
	inst.components.lootdropper:SpawnLootPrefab("sdf_book_of_gallowmere_damaged")
    end
end

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function onothercollide(inst, other)
    if not other:IsValid() or inst.recentlycharged[other] then
        return
    elseif other:HasTag("smashable") and other.components.health ~= nil then
        --other.Physics:SetCollides(false)
        other.components.health:Kill()
    elseif other.components.workable ~= nil
        and other.components.workable:CanBeWorked()
        and other.components.workable.action ~= ACTIONS.NET then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    elseif other.components.health ~= nil and not other.components.health:IsDead() then
        inst.recentlycharged[other] = true
        inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo")
        inst.components.combat:DoAttack(other, inst.weapon)
    end
end

local function oncollide(inst, other)
    if not (other ~= nil and other:IsValid() and inst:IsValid())
        or inst.recentlycharged[other]
        or other:HasTag("player")
        or Vector3(inst.Physics:GetVelocity()):LengthSq() < 42 then
        return
    end
    ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
    inst:DoTaskInTime(2 * FRAMES, onothercollide, other)
end

local function CreateWeapon(inst)
    local weapon = CreateEntity()
    --[[Non-networked entity]]
    weapon.entity:AddTransform()
    weapon:AddComponent("weapon")
    weapon.components.weapon:SetDamage(200)
    weapon.components.weapon:SetRange(0)
    weapon:AddComponent("inventoryitem")
    weapon.persists = false
    weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
    weapon:AddComponent("equippable")
    weapon:AddTag("nosteal")
    inst.components.inventory:GiveItem(weapon)
    inst.weapon = weapon
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

    MakeCharacterPhysics(inst, 50, 1.5)

    inst.DynamicShadow:SetSize(3, 1.25)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(0.66, 0.66, 0.66)

    inst.AnimState:SetBank("rook")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_chess_rook")

    inst:AddTag("monster")
    inst:AddTag("epic")
    inst:AddTag("hostile")
    inst:AddTag("chess")
    inst:AddTag("rook")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(oncollide)

    inst.soundpath = "dontstarve/creatures/rook_nightmare/"
    inst.effortsound = "dontstarve/creatures/rook_nightmare/rattle"

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("rook_jack_of_the_green")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_WALK_SPEED
    inst.components.locomotor.runspeed =  TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_RUN_SPEED

    inst:SetStateGraph("SGsdf_jack_of_the_green_chess_rook")
    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("health")
    inst.components.health.fire_damage_scale = TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_FIRE_DAMAGE_SCALE
    inst.components.health:SetMaxHealth(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_HEALTH)
    --inst.components.health:StartRegen(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_HEALTH_REGEN_AMOUNT, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_HEALTH_REGEN_PERIOD)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_ATTACK_PERIOD)

    inst:AddComponent("follower")

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_SANITY_AURA

    MakeHauntablePanic(inst)

    inst:DoTaskInTime(0, RememberKnownLocation)

    MakeLargeBurnableCharacter(inst, "swap_fire", nil, 1.4)
    inst.components.burnable.flammability = TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_FLAMMABILITY
    inst.components.propagator.acceptsheat = true

    MakeMediumFreezableCharacter(inst, "innerds")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    CreateWeapon(inst)

    return inst
end

return Prefab("sdf_jack_of_the_green_chess_rook", fn, assets)
