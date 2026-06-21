local assets =
{
    Asset("ANIM", "anim/sdf_asylum_grounds_keeper.zip"),
}

local prefabs =
{

}


SetSharedLootTable("asylum_grounds_keeper",
{
    {"cutgrass", 0.300},
    {"rocks", 0.300},
    {"boneshard", 0.2},
    {"sdf_spade", 0.03},
})

local sounds = {
    attack = "dontstarve/characters/wurt/merm/warrior/attack",
    hit = "dontstarve/characters/wurt/merm/warrior/hit",
    death = "dontstarve/characters/wurt/merm/warrior/death",
    talk = "dontstarve/characters/wurt/merm/warrior/talk",
    buff = "dontstarve/characters/wurt/merm/warrior/yell",
}


local MAX_TARGET_SHARES = 4
local SHARE_TARGET_DIST = 5

local SLIGHTDELAY = 1

local function FindInvaderFn(guy, inst)
    if guy:HasTag("NPC_contestant") then
        return nil
    end
    return (guy:HasTag("character") and not (guy:HasTag("sdf_asylum_grounds_keeper")))
end

local function RetargetFn(inst)
    if inst:HasTag("NPC_contestant") then
        return nil
    end

    local defend_dist = 5
    local defenseTarget = inst
    local home = inst.components.homeseeker and inst.components.homeseeker.home

    if home and inst:GetDistanceSqToInst(home) < defend_dist * defend_dist then
        defenseTarget = home
    end

    return FindEntity(defenseTarget or inst, SpringCombatMod(10), FindInvaderFn)
end

local function KeepTargetFn(inst, target)
    local defend_dist = 5
    local home = inst.components.homeseeker and inst.components.homeseeker.home

    if home then
        return home:GetDistanceSqToInst(target) < defend_dist*defend_dist
               and home:GetDistanceSqToInst(inst) < defend_dist*defend_dist
    end

    return inst.components.combat:CanTarget(target)
end

local DECIDROOTTARGET_MUST_TAGS = { "_combat", "_health", "sdf_asylum_grounds_keeper" }
local DECIDROOTTARGET_CANT_TAGS = { "INLIMBO" }

local function OnAttackedByDecidRoot(inst, attacker)
    local share_target_dist = 5
    local max_target_shares = 4

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SpringCombatMod(share_target_dist) * .5, DECIDROOTTARGET_MUST_TAGS, DECIDROOTTARGET_CANT_TAGS)
    local num_helpers = 0

    for i, v in ipairs(ents) do
        if v ~= inst and not v.components.health:IsDead() then
            num_helpers = num_helpers + 1
            if num_helpers >= max_target_shares then
                break
            end
        end
    end
end

local function IsNonPlayerMerm(this)
    return this:HasTag("sdf_asylum_grounds_keeper") and not this:HasTag("player")
end

local function OnAttacked(inst, data)

    local attacker = data and data.attacker

    if attacker and attacker.prefab == "deciduous_root" and attacker.owner ~= nil then
        OnAttackedByDecidRoot(inst, attacker.owner)
    elseif attacker and attacker.prefab ~= "deciduous_root" and inst.components.combat:CanTarget(attacker) then

        local share_target_dist = 5
        local max_target_shares = 4

        inst.components.combat:SetTarget(attacker)

        if inst.components.combat:HasTarget() then
            local home = inst.components.homeseeker and inst.components.homeseeker.home
            if home and home.components.childspawner and inst:GetDistanceSqToInst(home) <= share_target_dist*share_target_dist then
                max_target_shares = max_target_shares - home.components.childspawner.childreninside
                home.components.childspawner:ReleaseAllChildren(attacker)
            end
        end
        inst.components.combat:ShareTarget(attacker, share_target_dist, IsNonPlayerMerm, max_target_shares)
    end
end


local function ShouldSleep(inst)
    return NocturnalSleepTest(inst)
end

local function ShouldWakeUp(inst)
    return NocturnalWakeTest(inst)
end

local function OnTimerDone(inst, data)
    if data.name == "facetime" then
        inst.components.timer:StartTimer("dontfacetime", 10)
    end
end

local function OnRanHome(inst)
    if inst:IsValid() then
        inst.runhometask = nil

        local home = inst.components.homeseeker and inst.components.homeseeker:GetHome() or nil
        if home ~= nil and home.components.childspawner ~= nil then
            home.components.childspawner:GoHome(inst)
        end
    end
end

local function CancelRunHomeTask(inst)
    if inst.runhometask ~= nil then
        inst.runhometask:Cancel()
        inst.runhometask = nil
    end
end

local function OnEntitySleepMerm(inst)
    CancelRunHomeTask(inst) -- Cancel it here in case behaviour changes due to components.

    local hometraveltime = inst.components.homeseeker and inst.components.homeseeker:GetHomeDirectTravelTime() or nil
    if hometraveltime == nil then
        return -- There's no home to go back to!
    end

    inst.runhometask = inst:DoTaskInTime(hometraveltime, OnRanHome)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.sounds = sounds

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("sdf_asylum_grounds_keeper")

    inst.AnimState:Hide("ARM_carry_up")
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("sdf_asylum_grounds_keeper")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.SDF_ASYLUM_GROUNDS_KEEPER_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.SDF_ASYLUM_GROUNDS_KEEPER_WALK_SPEED

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_HEALTH)
    inst.components.health:StartRegen(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_HEALTH_REGEN_AMOUNT, TUNING.SDF_ASYLUM_GROUNDS_KEEPER_HEALTH_REGEN_PERIOD)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_ATTACK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_ATTACK_PERIOD + math.random())
    inst.components.combat:SetRange(1, 1)
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("asylum_grounds_keeper")

    inst:AddComponent("inventory")
    inst.components.inventory:DisableDropOnDeath()

    if inst.components.inventory:HasAnyEquipment() == false then
	inst.asylumGroundsKeeperWeapon = SpawnPrefab(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_WEAPON)
	inst.asylumGroundsKeeperWeapon.persists = false
	if inst.asylumGroundsKeeperWeapon ~= nil then
	    inst.components.inventory:Equip(inst.asylumGroundsKeeperWeapon)
	else
	    inst:DoTaskInTime(0.1, function()
		inst.asylumGroundsKeeperWeapon:Remove()
	   end)
	end
    else
	inst.components.inventory:DestroyContents()
	inst.asylumGroundsKeeperWeapon = SpawnPrefab(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_WEAPON)
	inst.asylumGroundsKeeperWeapon.persists = false
	if inst.asylumGroundsKeeperWeapon ~= nil then
	    inst.components.inventory:Equip(inst.asylumGroundsKeeperWeapon)
	else
	    inst:DoTaskInTime(0.1, function()
		inst.asylumGroundsKeeperWeapon:Remove()
	   end)
	end
    end

    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetNocturnal(true)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:AddComponent("timer")

    inst:SetStateGraph("SGsdf_asylum_grounds_keeper")
    local asylum_grounds_keeperbrain = require "brains/sdf_asylum_grounds_keeperbrain"
    inst:SetBrain(asylum_grounds_keeperbrain)

    MakeHauntablePanic(inst)

    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("entitysleep", OnEntitySleepMerm)
    inst:ListenForEvent("entitywake", CancelRunHomeTask)

    return inst
end

return  Prefab("sdf_asylum_grounds_keeper", fn, assets)