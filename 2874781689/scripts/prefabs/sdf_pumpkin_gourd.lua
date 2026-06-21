local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_gourd.zip"),
    Asset("SOUND", "sound/plant.fsb"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gourd_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gourd_mm.xml"),
}

local prefabs ={

}

local SOUND_TORMENTED_SCREAM = "dontstarve/creatures/leif/livinglog_burn"

local brain = require "brains/sdf_pumpking_gourdbrain"

local VALID_TILE_TYPES =
{
    [WORLD_TILES.QUAGMIRE_SOIL] = true,
    [WORLD_TILES.DIRT] = true,
    [WORLD_TILES.SAVANNA] = true,
    [WORLD_TILES.GRASS] = true,
    [WORLD_TILES.FOREST] = true,
    [WORLD_TILES.MARSH] = true,

    -- CAVES
    [WORLD_TILES.CAVE] = true,
    [WORLD_TILES.FUNGUS] = true,
    [WORLD_TILES.SINKHOLE] = true,
    [WORLD_TILES.MUD] = true,
    [WORLD_TILES.FUNGUSRED] = true,
    [WORLD_TILES.FUNGUSGREEN] = true,

    --EXPANDED FLOOR TILES
    [WORLD_TILES.DECIDUOUS] = true,
}

function adjustIdleSound(inst, vol)
    inst.SoundEmitter:SetParameter("loop", "size", vol)
end

local function frozenState(inst)
    if inst.components.freezable.coldness < 10 then
	inst.components.freezable:AddColdness(15)
    end
    inst.components.freezable.damagetobreak = TUNING.SDF_PUMPKIN_GOURD_HEALTH * 0.25

    if inst.components.freezable.wearofftask ~= nil then
        inst.components.freezable.wearofftask:Cancel()
    end

    inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(false)
    inst.components.sdf_pumpking_gourd_vine_spawner:KillAllMinions()
end

local function WakeUp(inst)
    if inst.winterMode == true then
	--keep frozen
	frozenState(inst)

        --In case it's still winter when we hit this (could happen from save data)
        --inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_GOURD_FREEZE_TIME, WakeUp)
    else
	--unfreeze frozen
	if inst.components.freezable:IsFrozen() then
	    inst.components.freezable:Unfreeze()
	end

	inst.hibernatetask = nil
	inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(true)
	inst.components.sdf_pumpking_gourd_vine_spawner:StartNextSpawn()
	inst.sg:GoToState("emerge")
    end
end

local function ResumeSleep(inst, seconds)
    inst.sg:GoToState("hibernate")

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(false)
    inst.components.sdf_pumpking_gourd_vine_spawner:KillAllMinions()

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end
    inst.hibernatetask = inst:DoTaskInTime(seconds, WakeUp)
end

local function OnFrozenState(inst)
    if inst.winterMode == false then

	if inst.growth == true then
	    inst.sg:GoToState("deathvine")
	elseif not inst.components.freezable:IsFrozen() then
	    inst.sg:GoToState("death")
	end

	if inst.task ~= nil then
	    inst.task:Cancel()
	    inst.task = nil
	end

	inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(false)
	inst.components.sdf_pumpking_gourd_vine_spawner:KillAllMinions()

	if inst.hibernatetask ~= nil then
	    inst.hibernatetask:Cancel()
	end
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_GOURD_FREEZE_TIME, WakeUp)
    else
	frozenState(inst)
    end
end

local function FreshSpawn(inst)
    inst.AnimState:SetBank("sdf_pumpking_gourd")
    inst.AnimState:SetBuild("sdf_pumpking_gourd")
    inst.sg:GoToState("spawn")
    inst:AddTag("planted")

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(false)
    inst.components.sdf_pumpking_gourd_vine_spawner:KillAllMinions()

    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end
    inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_GOURD_HIBERNATE_TIME, WakeUp)
end

local function OnDeath(inst)
    if inst.hibernatetask ~= nil then
        inst.hibernatetask:Cancel()
    end

    inst:DoTaskInTime(0.5, function()
	inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livinglog_burn")
    end)
    inst:DoTaskInTime(0.7, function()
	local x,_,z=inst.Transform:GetWorldPosition()
	local s = 1.5 --1.5
	local pumpkinDeathFX = SpawnPrefab("pumpkincarving_shatter_fx")
	pumpkinDeathFX.Transform:SetPosition(x,_,z)
	pumpkinDeathFX.Transform:SetScale(s,s,s)
	local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
	pumpkinDeath2FX.Transform:SetPosition(x,_,z)

	inst.components.lootdropper:DropLoot(inst:GetPosition())

	inst:Remove()
    end)

    inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(false)
    inst.components.sdf_pumpking_gourd_vine_spawner:KillAllMinions()
end



local function OnLoad(inst, data)
    if data ~= nil and data.growth ~= nil then
	inst.growth = data.growth
    end
    if data ~= nil and data.timeuntilwake ~= nil then
	ResumeSleep(inst, math.max(0, data.timeuntilwake))
    end
    if data ~= nil and data.planted then
        inst:AddTag("planted")
    end
end

local function OnSave(inst, data)
    data.growth = inst.growth
    data.timeuntilwake = inst.hibernatetask ~= nil and math.floor(GetTaskRemaining(inst.hibernatetask)) or nil
    data.planted = inst:HasTag("planted")
end

local function OnLongUpdate(inst, dt)
    if inst.hibernatetask ~= nil then
        local t = GetTaskRemaining(inst.hibernatetask)
        inst.hibernatetask:Cancel()

        if t > dt then
            inst.hibernatetask = inst:DoTaskInTime(t - dt, WakeUp)
        else
            WakeUp(inst)
        end
    end
end

local function ExtendHibernation(inst)
    --hibernate if you aren't already
    if inst.sg.currentstate.name ~= "hibernate" then
        OnFrozenState(inst)
    else
        --it's already hibernating & it's still winter. Make it sleep for longer!
	--keep frozen
	frozenState(inst)

        if inst.hibernatetask ~= nil then
            inst.hibernatetask:Cancel()
        end
        inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_GOURD_FREEZE_TIME, WakeUp)
    end
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .02 then
	if not inst.frozen then
            inst.frozen = true
	    inst.winterMode = true

	    --keep frozen
	    frozenState(inst)

	    if inst.growth == true then
		inst.sg:GoToState("deathvine")
	    elseif not inst.components.freezable:IsFrozen() then
		inst.sg:GoToState("death")
	    end

	    if inst.wintertask == nil then
		inst.wintertask = inst:DoPeriodicTask(30, ExtendHibernation)
		ExtendHibernation(inst)
	    end
	end
    elseif inst.wintertask ~= nil then
	inst.frozen = false
	inst.winterMode = false

        inst.wintertask:Cancel()
        inst.wintertask = nil
	ExtendHibernation(inst)
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_central_idle", "loop")
    adjustIdleSound(inst, inst.components.sdf_pumpking_gourd_vine_spawner.numminions / inst.components.sdf_pumpking_gourd_vine_spawner.maxminions)
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnStartFireDamage(inst)
    inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(false)
    inst.components.sdf_pumpking_gourd_vine_spawner:KillAllMinions()
end

local function OnStopFireDamage(inst)
    if inst.hibernatetask == nil and not (inst.components.health:IsDead() or TheWorld.state.iswinter) then
        inst.components.sdf_pumpking_gourd_vine_spawner:SetCanSpawn(true)
        inst.components.sdf_pumpking_gourd_vine_spawner:StartNextSpawn()
    end
end

local function OnMinionChange(inst)
    if not inst:IsAsleep() then
        adjustIdleSound(inst, inst.components.sdf_pumpking_gourd_vine_spawner.numminions / inst.components.sdf_pumpking_gourd_vine_spawner.maxminions)
    end
end

local function OnHaunt(inst)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    return true
end

local function OnWorkFinished(inst, worker)
    if not inst.components.health:IsDead() then
	inst.components.health:Kill()
    end
end

local function allanimalscanscream(inst)
    inst.SoundEmitter:PlaySound(SOUND_TORMENTED_SCREAM)
end

local function onignite(inst)
    allanimalscanscream(inst)
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
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_pumpkin_gourd_mm.tex")

    inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2)
    inst:SetPhysicsRadiusOverride(.7)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst:AddTag("veggie")
    --inst:AddTag("smallcreature")
    inst:AddTag("character")
    inst:AddTag("companion")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("lifedrainable")
    inst:AddTag("NPCcanaggro")
    inst:AddTag("NPC_workable")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_gourd")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sdf_pumpking_gourd_vine_spawner")
    inst.components.sdf_pumpking_gourd_vine_spawner:SetMinionType("sdf_pumpkin_gourd_vine")
    inst.components.sdf_pumpking_gourd_vine_spawner:SetMinionSpawnTime({ min = TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_TIME, max = TUNING.SDF_PUMPKIN_GOURD_VINE_REGEN_TIME })
    inst.components.sdf_pumpking_gourd_vine_spawner:SetSpawnTime(TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_TIME)
    inst.components.sdf_pumpking_gourd_vine_spawner:SetMaxMinion(TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_MAX)
    inst.components.sdf_pumpking_gourd_vine_spawner:SetMaxMinionPool(TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_MAX)
    inst.components.sdf_pumpking_gourd_vine_spawner:SetDistanceModifier(TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_DIST)
    inst.components.sdf_pumpking_gourd_vine_spawner.validtiletypes = VALID_TILE_TYPES

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKIN_GOURD_HEALTH)
    inst.components.health.fire_damage_scale = TUNING.SDF_PUMPKIN_GOURD_FIRE_DAMAGE

    inst:AddComponent("combat")
    inst:ListenForEvent("death", OnDeath)

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"plantmeat"})

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(nil)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    MakeSmallFreezableCharacter(inst)
    inst.components.freezable:SetResistance(3)

    inst:SetStateGraph("SGsdf_pumpking_gourd")
    inst:SetBrain(brain)

    inst.growth = false
    inst.summoned = false
    inst.winterMode = false

    inst:ListenForEvent("startfiredamage", OnStartFireDamage)
    inst:ListenForEvent("stopfiredamage", OnStopFireDamage)
    inst:ListenForEvent("freeze", OnFrozenState)
    inst:ListenForEvent("minionchange", OnMinionChange)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(3)
    burnable:SetBurnTime(10)
    burnable.canlight = false
    burnable:AddBurnFX("fire", Vector3(0, 0, 0))

    MakeSmallPropagator(inst)

    MakeHauntableIgnite(inst, TUNING.HAUNT_CHANCE_OCCASIONAL)
    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst:ListenForEvent("onignite", onignite)
    inst.incineratesound = SOUND_TORMENTED_SCREAM

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    inst.OnLongUpdate = OnLongUpdate

    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)

    inst:DoTaskInTime(0, FreshSpawn)
    inst:DoPeriodicTask(2, TryRegenHealth)

    return inst
end

return Prefab("sdf_pumpkin_gourd", fn, assets, prefabs)