local easing = require("easing")

local assets=
{
    Asset("ANIM", "anim/sdf_pumpkin_king_fresh.zip"),
    Asset("ANIM", "anim/sdf_pumpkin_king_ripe.zip"),
    Asset("ANIM", "anim/sdf_pumpkin_king_overripen.zip"),
    Asset("ANIM", "anim/sdf_pumpkin_king_rotten.zip"),
    Asset("ANIM", "anim/sdf_pumpkin_king_husk.zip"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_king_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_king_mm.xml"),
}

local vineassets =
{
    Asset("ANIM", "anim/sdf_pumpkin_king_vine.zip"),
    Asset("ANIM", "anim/sdf_pumpkin_king_vine_big.zip"),
}

prefabs = {
}

local function customPlayAnimation(inst,anim,loop)
    inst.AnimState:PlayAnimation(anim,loop)
end

local function customPushAnimation(inst,anim,loop)
    inst.AnimState:PushAnimation(anim,loop)
end

local function customSetRandomFrame(inst)
    local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) -1
    inst.AnimState:SetFrame(frame)
end

local function playSpawnAnimation(inst)
    inst.sg:GoToState("spawn")
end

local function playSpawnWinterAnimation(inst)
    inst.sg:GoToState("spawn_winter")
end
----------------------------------------------------------------------
local function back_onentityreplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "sdf_pumpkin_king" then
	table.insert(parent.vineHusk, inst)
    end
end

local function back_onremoveentity(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.vineHusk ~= nil then
	table.removearrayvalue(parent.vineHusk, inst)
    end
end
----------------------------------------------------------------------
local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local SEEDTARGET_MUST_TAGS = { "_combat", "_health" }
local SEEDTARGET_CANT_TAGS = { "player", "INLIMBO" }

local function FindPumpkingSeedTargets(inst, pumpkingSeedCount)
    --ring with a random gap
    local maxSeeds = pumpkingSeedCount
    local delta = (1 + math.random()) * PI / maxSeeds
    local offset = TWOPI * math.random()
    local angles = {}
    for i = 1, maxSeeds do
        table.insert(angles, i * delta + offset)
    end

    --shorten range when mobbed by NPC
    local pt = inst:GetPosition()
    local maxrange = TUNING.SDF_PUMPKIN_KING_SEED_MAX_RANGE
    for i = 1, 2 do
        local closerange = TUNING.SDF_PUMPKIN_KING_SEED_MIN_RANGE --(TUNING.SDF_PUMPKIN_KING_SEED_MIN_RANGE + maxrange) * .5
        local targets = TheSim:FindEntities(pt.x, 0, pt.z, closerange, SEEDTARGET_MUST_TAGS, SEEDTARGET_CANT_TAGS)
        if #targets < inst.components.grouptargeter.num_targets then
            break
        end
        --maxrange = closerange
    end

    local range = GetRandomMinMax(TUNING.SDF_PUMPKIN_KING_SEED_MIN_RANGE, TUNING.SDF_PUMPKIN_KING_SEED_MAX_RANGE) --maxrange)
    local targets = {}
    while #angles > 0 do
        local theta = table.remove(angles, math.random(#angles))
        local offset = FindWalkableOffset(pt, theta, range, 12, true, true, NoHoles)
        if offset ~= nil then
            offset.x = offset.x + pt.x
            offset.y = 0
            offset.z = offset.z + pt.z
            table.insert(targets, offset)
        end
    end

    return targets
end

local function SpawnPumpkingGourdSeedProjectile(inst, targets)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("sdf_pumpking_seed")
    projectile.seedType = "sdf_pumpking_gourd_plant"
    projectile.Transform:SetPosition(x, y, z)
    projectile.components.entitytracker:TrackEntity("sdf_pumpkin_king", inst)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local targetpos = table.remove(targets, 1)
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = 15
    local bigNum = 15 -- 13 + (math.random()*4)
    local speed = easing.linear(rangesq, bigNum, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)

    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnPumpkingGourdSeedProjectile, targets)
    end
end

local function SpawnPumpkingCreeperSeedProjectile(inst, targets)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("sdf_pumpking_seed")
    projectile.seedType = "sdf_pumpking_creeper_plant"
    projectile.Transform:SetPosition(x, y, z)
    projectile.components.entitytracker:TrackEntity("sdf_pumpkin_king", inst)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local targetpos = table.remove(targets, 1)
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = 15
    local bigNum = 15 -- 13 + (math.random()*4)
    local speed = easing.linear(rangesq, bigNum, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)

    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnPumpkingCreeperSeedProjectile, targets)
    end
end

local random_pumpking_seed ={
"sdf_pumpking_gourd_plant",
"sdf_pumpking_creeper_plant"
}

local function SpawnPumpkingRandomSeedProjectile(inst, targets)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("sdf_pumpking_seed")
    projectile.seedType = random_pumpking_seed[math.random(#random_pumpking_seed)]
    projectile.Transform:SetPosition(x, y, z)
    projectile.components.entitytracker:TrackEntity("sdf_pumpkin_king", inst)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local targetpos = table.remove(targets, 1)
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = 15
    local bigNum = 15 -- 13 + (math.random()*4)
    local speed = easing.linear(rangesq, bigNum, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)

    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnPumpkingRandomSeedProjectile, targets)
    end
end

local function PlantPumpkingGourdSeed(inst)
    local targets = FindPumpkingSeedTargets(inst, TUNING.SDF_PUMPKIN_KING_SEED_GOURD_COUNT)
    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnPumpkingGourdSeedProjectile, targets)
    end
end

local function PlantPumpkingCreeperSeed(inst)
    local targets = FindPumpkingSeedTargets(inst, TUNING.SDF_PUMPKIN_KING_SEED_CREEPER_COUNT)
    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnPumpkingCreeperSeedProjectile, targets)
    end
end

local function PlantPumpkingRandomSeed(inst)
    local targets = FindPumpkingSeedTargets(inst, TUNING.SDF_PUMPKIN_KING_SEED_RANDOM_COUNT)
    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnPumpkingRandomSeedProjectile, targets)
    end
end

----------------------------------------------------------------------

local function DoMiasmaAOE(inst)
    local healthPercent = inst.components.health:GetPercent()

    if healthPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_2 then
	--create miasma aoe
	local x,_,z=inst.Transform:GetWorldPosition()
	local miasmaFX = SpawnPrefab("sdf_pumpking_miasma_telegraph")
	miasmaFX.Transform:SetPosition(x,_,z)

	if inst.tired == nil or inst.tired == false then
	    inst.sg:GoToState("cast_ability")
	end
    end
end

local function StartMiasmaAOELong(inst)
    --create miasma aoe
    local x,_,z=inst.Transform:GetWorldPosition()
    local miasmaFX = SpawnPrefab("sdf_pumpking_miasma_telegraph")
    miasmaFX.Transform:SetPosition(x,_,z)

    if inst.miasmaaoetask == nil then
	inst.miasmaaoetask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_LONG_TICK, function()  DoMiasmaAOE(inst) end)
    end
end

local function StartMiasmaAOEShort(inst)
    --create miasma aoe
    local x,_,z=inst.Transform:GetWorldPosition()
    local miasmaFX = SpawnPrefab("sdf_pumpking_miasma_telegraph")
    miasmaFX.Transform:SetPosition(x,_,z)

    if inst.miasmaaoetask == nil then
	inst.miasmaaoetask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_SHORT_TICK, function()  DoMiasmaAOE(inst) end)
    else
	inst.miasmaaoetask:Cancel()
	inst.miasmaaoetask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_SHORT_TICK, function()  DoMiasmaAOE(inst) end)
    end
end

local function FindMiasmaSmallTargets(inst)
    --ring with a random gap
    local maxMiasma = math.random(TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_COUNT_MIN, TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_COUNT_MAX)
    local delta = (1 + math.random()) * PI / maxMiasma
    local offset = TWOPI * math.random()
    local angles = {}
    for i = 1, maxMiasma do
        table.insert(angles, i * delta + offset)
    end

    --shorten range when mobbed by NPC
    local pt = inst:GetPosition()
    local maxrange = TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_MAX_RANGE
    for i = 1, 2 do
        local closerange = TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_MIN_RANGE --(TUNING.SDF_PUMPKIN_KING_SEED_MIN_RANGE + maxrange) * .5
        local targets = TheSim:FindEntities(pt.x, 0, pt.z, closerange, SEEDTARGET_MUST_TAGS, SEEDTARGET_CANT_TAGS)
        if #targets < inst.components.grouptargeter.num_targets then
            break
        end
        --maxrange = closerange
    end

    local range = GetRandomMinMax(TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_MIN_RANGE, TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_MAX_RANGE) --maxrange)
    local targets = {}
    while #angles > 0 do
        local theta = table.remove(angles, math.random(#angles))
        local offset = FindWalkableOffset(pt, theta, range, 12, true, true, NoHoles)
        if offset ~= nil then
            offset.x = offset.x + pt.x
            offset.y = 0
            offset.z = offset.z + pt.z
            table.insert(targets, offset)
        end
    end

    return targets
end

local function SpawnMiasmaSmallProjectile(inst, targets)
    local x, y, z = inst.Transform:GetWorldPosition()
    local projectile = SpawnPrefab("sdf_pumpking_seed")
    projectile.seedType = "sdf_pumpking_miasma_small_telegraph"
    projectile.Transform:SetPosition(x, y, z)
    projectile.components.entitytracker:TrackEntity("sdf_pumpkin_king", inst)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local targetpos = table.remove(targets, 1)
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = 15
    local bigNum = 15 -- 13 + (math.random()*4)
    local speed = easing.linear(rangesq, bigNum, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)

    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnMiasmaSmallProjectile, targets)
    end
end

local function DoMiasmaSmall(inst)
    local targets = FindMiasmaSmallTargets(inst)
    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnMiasmaSmallProjectile, targets)

	inst:DoTaskInTime(4.3, function()
	    --create miasma small fx
	    local x,_,z=inst.Transform:GetWorldPosition()
	    local s = 3 --1.5
	    local miasmaSmallFX = SpawnPrefab("treegrowthsolution_use_fx")
	    miasmaSmallFX.Transform:SetPosition(x,_,z)
	    miasmaSmallFX.Transform:SetScale(s,s,s)
	end)
    end
end

local function DoMiasmaDeathAOE(inst)
    local x,_,z=inst.Transform:GetWorldPosition()
    local miasmaDeathFX = SpawnPrefab("sdf_pumpking_miasma_death_telegraph")
    miasmaDeathFX.Transform:SetPosition(x,_,z)
end
----------------------------------------------------------------------
--Called from stategraph
local function LaunchBombardment(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("sdf_pumpking_seed")
    projectile.seedType = "sdf_pumpking_bomb_plant"
    projectile.Transform:SetPosition(x, y, z)
    projectile.components.entitytracker:TrackEntity("sdf_pumpkin_king", inst)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.SDF_PUMPKIN_KING_SEED_BOMBARDMENT_RANGE
    local speed = easing.linear(rangesq, 15, 1, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-35)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
end

local function DoBombardment(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SDF_PUMPKIN_KING_SEED_BOMBARDMENT_RANGE)
    for i, v in ipairs(ents) do
	if v:HasTag("sdf_pumpking_friend") or v:HasTag("bird") then
	elseif v.components.health ~= nil and not v.components.health:IsDead() and v.components.combat ~= nil then
	    if v:HasTag("player") then
		local targetpos = Vector3(v.Transform:GetWorldPosition())
		LaunchBombardment(inst, targetpos) --targetpos)
	    end
	end
    end
end
----------------------------------------------------------------------
local FIND_PLAYER_MUST_HAVE_TAGS = {"player"}
local FIND_PLAYER_CANT_HAVE_TAGS = {"playerghost", "INLIMBO"}
local FIND_PLAYER_POD_AOE_RADIUS = 15 --15
local function DoDeadheading(inst)
    local hasPlayer = false
    if inst.activeBattle == true then

	--look for players
	local tx, ty, tz = inst.Transform:GetWorldPosition()
	local affected_entity = TheSim:FindEntities(tx, ty, tz, FIND_PLAYER_POD_AOE_RADIUS, FIND_PLAYER_MUST_HAVE_TAGS, FIND_PLAYER_CANT_HAVE_TAGS)
	for i, v in ipairs(affected_entity) do

	    --find players
	    if v ~= nil then
		hasPlayer = true
	    end
	end

	--no players
	if hasPlayer == false then
	    if inst.deadheadingCounter >= 3 then
		if inst.components.follower:GetLeader() ~= nil then
		    local leader = inst.components.follower:GetLeader()
		    leader:reActivateSeedPodsRest()
		end
	    else
		inst.deadheadingCounter = inst.deadheadingCounter + 1
	    end
	else
	    inst.deadheadingCounter = 0
	end
    end
end

local function setHealthStage(inst)
    inst.AnimState:SetBank(inst.healthstage)
    inst.AnimState:SetBuild(inst.healthstage)
end

local function getHealthStageLoad(inst)
    local healthPercent = inst.components.health:GetPercent()

    --get stage anim
    if healthPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_3 then
	inst.healthstage = "sdf_pumpkin_king_rotten"
    elseif healthPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_2 then
	inst.healthstage = "sdf_pumpkin_king_overripen"
    elseif healthPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_1 then
	inst.healthstage = "sdf_pumpkin_king_ripe"
    elseif healthPercent > TUNING.SDF_PUMPKIN_KING_STAGE_1 then
	inst.healthstage = "sdf_pumpkin_king_fresh"
    end

    --set stage anim
    setHealthStage(inst)
end

local function getHealthStageDelta(inst, newPercent)

    --get stage anim
    if newPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_3 then 
	inst.healthstage = "sdf_pumpkin_king_rotten"

	--que phase 3
	if inst.phaseCount == 2 and inst.phaseReady == false then
	    inst.phaseReady = true
	    inst.components.health:SetAbsorptionAmount(1) --can no longer take damage
	end
    elseif newPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_2 then 
	inst.healthstage = "sdf_pumpkin_king_overripen"

	--que phase 2
	if inst.phaseCount == 1 and inst.phaseReady == false then
	    inst.phaseReady = true
	    inst.components.health:SetAbsorptionAmount(1) --can no longer take damage
	end
    elseif newPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_1 then 
	inst.healthstage = "sdf_pumpkin_king_ripe"

	--que phase 1
	if inst.phaseCount == 0 and inst.phaseReady == false then
	    inst.phaseReady = true
	    inst.components.health:SetAbsorptionAmount(1) --can no longer take damage
	end
    elseif newPercent > TUNING.SDF_PUMPKIN_KING_STAGE_1 then 
	inst.healthstage = "sdf_pumpkin_king_fresh"
    end

    --set stage anim
    setHealthStage(inst)
end

local function OnHealthDelta(inst, data)
    if data.newpercent ~= nil then
	getHealthStageDelta(inst, data.newpercent)
    end
end

local function OnDeath(inst)
    --create miasma death aoe
    inst:DoMiasmaDeathAOE()

    --remove vines
    inst:killvines()
    inst:killhusk()
  
    if inst.waketask then
        inst.waketask:Cancel()
        inst.waketask = nil
    end
    if inst.resttask then
        inst.resttask:Cancel()
        inst.resttask = nil
    end
    if inst.DeadheadingTask ~= nil then
	inst.DeadheadingTask:Cancel()
	inst.DeadheadingTask = nil
    end
    if inst.miasmaaoetask then
        inst.miasmaaoetask:Cancel()
        inst.miasmaaoetask = nil
    end    

    if inst.components.follower:GetLeader() ~= nil then
	local leader = inst.components.follower:GetLeader()
	leader:corpseKing()
    end
end

local function OnRemove(inst)
    inst:killvines()
    --inst:killhusk()
end

local function vineremoved(inst,vine,killed)
    for i,localvine in ipairs(inst.vines)do
        if localvine == vine then
            table.remove(inst.vines,i)
            if not killed then
                inst.vinelimit = inst.vinelimit + 1
            end
	    break
        end
    end
end

local function OnWakeTask(inst)
    inst.waketask = nil
    inst.wake = nil
    inst.tired = nil

    if inst.phaseReady == true then
	inst.phaseReady = false

	if inst.components.follower:GetLeader() ~= nil then
	    local leader = inst.components.follower:GetLeader()
	    leader:reActivateSeedPods()
	end
    else
	inst.vinelimit = TUNING.SDF_PUMPKIN_KING_VINE_LIMIT --TUNING.SDF_PUMPKIN_KING_VINE_LIMIT - inst.phaseCount
	inst.sg:GoToState("attack")
    end
end

local function OnRestTask(inst)
    inst.resttask = nil

    if not inst.components.health:IsDead() then
	inst.sg:GoToState("tired_wake")

	if inst.waketask ~= nil then
	    inst.waketask:Cancel()
	end
	inst.waketask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_WAKE_TIME, OnWakeTask)
    end
end
-----------------------------------------------------------------------
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
	inst.components.freezable.damagetobreak = TUNING.SDF_PUMPKIN_KING_HEALTH * 0.04

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
    if not inst.tired or inst.wake then
	inst.wake = nil
	inst.tired = nil
	inst:killvines()
    end

    if inst.winterMode == false then

	if inst.task ~= nil then
	    inst.task:Cancel()
	    inst.task = nil
	end

	if inst.hibernatetask ~= nil then
	   inst.hibernatetask:Cancel()
	end
	inst.hibernatetask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_CREEPER_FREEZE_TIME, WakeUp)
    else
	frozenState(inst)
    end
end
----------------------------------------------------------------------- 
local function createHuskSpawn(inst)
    if inst.husk == nil then
	local husk = SpawnPrefab("sdf_pumpkin_king_husk")
	husk.AnimState:SetFinalOffset(-1)
	inst.husk = husk
	table.insert(inst.vineHusk, husk)
	husk.entity:SetParent(inst.entity)
	husk.AnimState:PlayAnimation("spawn_short")
	husk.AnimState:PushAnimation("idle_short", true)
    end

    if inst.components.health ~= nil and not inst.components.health:IsDead() then
	inst:AddTag("huskRegen")
	inst:AddTag("retaliates")
    end
end

local function createHusk(inst)
    local husk = SpawnPrefab("sdf_pumpkin_king_husk")
    husk.AnimState:SetFinalOffset(-1)
    inst.husk = husk
    table.insert(inst.vineHusk, husk)
    husk.entity:SetParent(inst.entity)
    husk.AnimState:PlayAnimation("spawn_short")
    husk.AnimState:PushAnimation("idle_short", true)

    if inst.components.health ~= nil and not inst.components.health:IsDead() then
	inst:AddTag("huskRegen")
	inst.tired = true
	--inst:RemoveTag("retaliates")

	inst.deadheadingCounter = 0
	inst.phaseCount = inst.phaseCount + 1

	if inst.waketask ~= nil then
	    inst.waketask:Cancel()
	    inst.waketask = nil
	end
	if inst.resttask ~= nil then
	    inst.resttask:Cancel()
	    inst.resttask = nil
	end
	if inst.DeadheadingTask ~= nil then
	    inst.DeadheadingTask:Cancel()
	    inst.DeadheadingTask = nil
	end

	--Miasma start
	if inst.phaseCount == 2 then
	    inst:StartMiasmaAOELong()
	elseif inst.phaseCount == 3 then
	    inst:StartMiasmaAOEShort()
	end

	inst.sg:GoToState("husk_regen")
    end
end

local function createHuskRest(inst)
    if inst.husk == nil then
	local husk = SpawnPrefab("sdf_pumpkin_king_husk")
	husk.AnimState:SetFinalOffset(-1)
	inst.husk = husk
	table.insert(inst.vineHusk, husk)

	husk.entity:SetParent(inst.entity)
	husk.AnimState:PlayAnimation("spawn_short")
	husk.AnimState:PushAnimation("idle_short", true)
    end

    if inst.components.health ~= nil and not inst.components.health:IsDead() then
	inst:AddTag("huskRegen")
	inst.tired = true
	--inst:RemoveTag("retaliates")

	inst.deadheadingCounter = 0

	if inst.waketask ~= nil then
	    inst.waketask:Cancel()
	    inst.waketask = nil
	end
	if inst.resttask ~= nil then
	    inst.resttask:Cancel()
	    inst.resttask = nil
	end
	if inst.DeadheadingTask ~= nil then
	    inst.DeadheadingTask:Cancel()
	    inst.DeadheadingTask = nil
	end

	inst.sg:GoToState("rest")
    end
end

local function createHuskReset(inst)
    if inst.husk == nil then
	local husk = SpawnPrefab("sdf_pumpkin_king_husk")
	husk.AnimState:SetFinalOffset(-1)
	inst.husk = husk
	table.insert(inst.vineHusk, husk)

	husk.entity:SetParent(inst.entity)
	husk.AnimState:PlayAnimation("spawn_short")
	husk.AnimState:PushAnimation("idle_short", true)
    end

    if inst.components.health ~= nil and not inst.components.health:IsDead() then
	inst:AddTag("huskRegen")
	inst.tired = true
	--inst:RemoveTag("retaliates")

	inst.activeBattle = false
	inst.deadheadingCounter = 0
	inst.phaseCount = 0
	inst.phaseReady = false

	if inst.waketask ~= nil then
	    inst.waketask:Cancel()
	    inst.waketask = nil
	end
	if inst.resttask ~= nil then
	    inst.resttask:Cancel()
	    inst.resttask = nil
	end
	if inst.DeadheadingTask ~= nil then
	    inst.DeadheadingTask:Cancel()
	    inst.DeadheadingTask = nil
	end

	inst:DoMiasmaDeathAOE()

	inst.sg:GoToState("rest")
    end
end

local function createHuskWinter(inst)
    if inst.husk == nil then
	local husk = SpawnPrefab("sdf_pumpkin_king_husk")
	husk.AnimState:SetFinalOffset(-1)
	inst.husk = husk
	table.insert(inst.vineHusk, husk)

	husk.entity:SetParent(inst.entity)
	husk.AnimState:PlayAnimation("spawn_short")
	husk.AnimState:PushAnimation("idle_short", true)
    end

    --add frost
    if inst.husk ~= nil then
	inst.husk.components.colouradder:PushColour("frost", 82 / 255, 115 / 255, 124 / 255, 0)
    end

    if inst.components.health ~= nil and not inst.components.health:IsDead() then
	inst:AddTag("huskRegen")
	inst.tired = true
	--inst:RemoveTag("retaliates")

	inst.activeBattle = false
	inst.deadheadingCounter = 0
	inst.phaseCount = 0
	inst.phaseReady = false
	--inst.winterMode = true

	--add frost
	frozenState(inst)

	local x,_,z=inst.Transform:GetWorldPosition()
	local s = 1.5 --1.5
	local pumpkingFrostFX = SpawnPrefab("crab_king_icefx") --fx_ice_pop
	if pumpkingFrostFX ~= nil then
	    pumpkingFrostFX.Transform:SetPosition(x,_ +1,z)
	    pumpkingFrostFX.Transform:SetScale(s,s,s)
	end

	if inst.waketask ~= nil then
	    inst.waketask:Cancel()
	    inst.waketask = nil
	end
	if inst.resttask ~= nil then
	    inst.resttask:Cancel()
	    inst.resttask = nil
	end
	if inst.DeadheadingTask ~= nil then
	    inst.DeadheadingTask:Cancel()
	    inst.DeadheadingTask = nil
	end

	inst:DoMiasmaDeathAOE()

	inst.sg:GoToState("husk_regen_winter")
    end
end

local function killhusk(inst)
    for i,localhusk in ipairs(inst.vineHusk)do
        if localhusk:IsValid() then
	    localhusk.AnimState:PlayAnimation("death_short")
            localhusk.components.health:Kill()
        end
    end
    inst.husk = nil

    if inst.components.health ~= nil and not inst.components.health:IsDead() then
	inst.sg:GoToState("husk_regen_pst")
    end
end
----------------------------------------------------------------------

local function vinekilled(inst,vine) --add husk here too
    if inst.winterMode == true or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) then
	return
    end

    for i,localvine in ipairs(inst.vines)do
        if localvine == vine then
            vineremoved(inst,vine, true)
            if inst.vinelimit <= 0 and #inst.vines <= 0 then
                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("tired_pre")
                end
		if inst.waketask ~= nil then
		    inst.waketask:Cancel()
		    inst.waketask = nil
		end
		if inst.resttask ~= nil then
		    inst.resttask:Cancel()
		end
		inst.resttask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_REST_TIME + (math.random()*1), OnRestTask)
            end
        end
    end  
end

local function killvines(inst)
    for i,localvine in ipairs(inst.vines)do
        if localvine:IsValid() then
            localvine.components.health:Kill()
        end
    end
end

local function OnAttacked(inst,data)
    if data.attacker then
        if (
                not inst.components.combat.target 
                or (inst.components.combat.target ~= data.attacker and not inst.components.timer:TimerExists("targetswitched"))
            ) 
            and not data.attacker.components.complexprojectile
            and not data.attacker.components.projectile then

	    inst.components.timer:StopTimer("targetswitched")
            inst.components.timer:StartTimer("targetswitched",20)
            inst.components.combat:SetTarget(data.attacker)
        end

	--phase 3 ability
	if inst.components.health ~= nil and not inst.components.health:IsDead() then
	    local healthPercent = inst.components.health:GetPercent()
	    if healthPercent <= TUNING.SDF_PUMPKIN_KING_STAGE_3 then

		--Miasma start
		if inst.phaseCount >= 3 then
		    local miasmaRng = math.random()
		    if miasmaRng <= TUNING.SDF_PUMPKIN_KING_MIASMA_CHANCE then

			inst:DoMiasmaSmall()
		    end
		 end
	    end
	end
    end
end

local function vine_addcoldness(vine, ...)
    local inst = vine.parentplant
    if inst ~= nil and inst:IsValid() then
	inst.components.freezable:AddColdness(...)
	return true
    end
    return false
end

local PLANT_MUST = {"sdf_pumpkin_king"}
local TARGET_MUST_TAGS = { "_combat", "character" }
local TARGET_CANT_TAGS = { "INLIMBO","sdf_pumpkin_king", "sdf_pumpkin_king_vine_end", "sdf_pumpking_friend" }
local function Retarget(inst)
    if not inst.no_targeting then
        local target = FindEntity(
            inst,
            TUNING.SDF_PUMPKIN_KING_RANGE,
            function(guy)
                local total = 0
                local x,y,z = inst.Transform:GetWorldPosition()

                if inst.tired then
                    return nil
                end

                local plants = TheSim:FindEntities(x,y,z, 15, PLANT_MUST)
                for i, plant in ipairs(plants)do
                    if plant ~= inst then
                        if plant.components.combat.target and plant.components.combat.target == guy then
                            total = total +1
                        end
                    end
                end
                if total < 3 then
                    return inst.components.combat:CanTarget(guy)
                end
            end,
            TARGET_MUST_TAGS,
            TARGET_CANT_TAGS
        )

        if inst.vinelimit > 0 then --husk stop here
            if target and ( not inst.components.freezable or not inst.components.freezable:IsFrozen()) then

                local pos = inst:GetPosition()

                local theta = math.random()*TWOPI
                local radius = TUNING.SDF_PUMPKIN_KING_VINE_END_MOVEDIST
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                pos = pos + offset

                if TheWorld.Map:IsVisualGroundAtPoint(pos.x,pos.y,pos.z) then

                    local vine = SpawnPrefab("sdf_pumpkin_king_vine_end")
                    vine.Transform:SetPosition(pos.x,pos.y,pos.z)
                    vine.Transform:SetRotation(inst:GetAngleToPoint(pos.x, pos.y, pos.z))
		    vine.components.freezable:SetRedirectFn(vine_addcoldness)
                    vine.sg:RemoveStateTag("nub")
                    if inst.tintcolor then
                        vine.AnimState:SetMultColour(inst.tintcolor, inst.tintcolor, inst.tintcolor, 1)
                        vine.tintcolor = inst.tintcolor
                    end

		    inst.components.colouradder:AttachChild(vine)

                    vine.parentplant = inst
                    table.insert(inst.vines,vine)
                    inst.vinelimit = inst.vinelimit -1
                    inst:DoTaskInTime(0,function() vine:ChooseAction() end)

                    return target
                end
            end
        end
    end
end

local function keeptargetfn(inst, target)
   return target ~= nil
        and target:GetDistanceSqToInst(inst) < TUNING.SDF_PUMPKIN_KING_GIVEUPRANGE * TUNING.SDF_PUMPKIN_KING_GIVEUPRANGE
        and target.components.combat ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and not (inst.components.follower ~= nil and
                (inst.components.follower.leader == target or inst.components.follower:IsLeaderSame(target)))
end

local function OnLoad(inst, data)
    if data ~= nil and data.healcount then
        inst.healcount = data.healcount
    end
    getHealthStageLoad(inst)
end

local function OnSave(inst, data)
    data.healcount = inst.healcount
    --data.spawnedKing_id = inst.spawnedKing_id -- duplication bug fix, when a game starts.
end

local function OnLoadPostPass(inst)
    --if inst.components.entitytracker:GetEntity("targetplant") then
        --inst:infest(inst.components.entitytracker:GetEntity("targetplant"),true)
    --end
end

local function OnInit(inst)
    if inst.typeid == 0 then
	inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
     
    inst.MiniMapEntity:SetIcon("sdf_pumpkin_king_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeObstaclePhysics(inst, .8)
    inst:SetPhysicsRadiusOverride(.4)

    local s = 1.5
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_pumpkin_king_fresh")
    inst.AnimState:SetBuild("sdf_pumpkin_king_fresh")
    inst.AnimState:PlayAnimation("idle_med", true)
    inst.AnimState:SetFinalOffset(1)

    inst.customPlayAnimation = customPlayAnimation
    inst.customPushAnimation = customPushAnimation
    inst.customSetRandomFrame = customSetRandomFrame

    inst:AddTag("epic")
    inst:AddTag("largecreature")
    inst:AddTag("hostile")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_king")

    inst.vineHusk = {}
    inst.husk = nil

    inst.entity:SetPristine()

    inst.targetsize = "med"

    if not TheWorld.ismastersim then
        return inst
    end

    inst:customSetRandomFrame()

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKIN_KING_HEALTH)
    inst.components.health:SetAbsorptionAmount(1)
    --inst.components.health:SetMaxDamageTakenPerHit(TUNING.SDF_PUMPKIN_KING_HEALTH * TUNING.SDF_PUMPKIN_KING_HEALTH_MAX_DAMAGE_TAKEN)
    inst.components.health.fire_damage_scale = TUNING.SDF_PUMPKIN_KING_FIRE_DAMAGE

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(TUNING.SDF_PUMPKIN_KING_PLANAR_DEFENSE)

    inst:AddComponent("combat")
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)
    inst.components.combat:SetDefaultDamage(TUNING.SDF_PUMPKIN_KING_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("follower")

    inst:AddComponent("entitytracker")
    inst:AddComponent("grouptargeter")

    inst:AddComponent("colouradder")
    inst:AddComponent("timer")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_PUMPKIN_KING_SANITY_AURA

    inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("freeze", OnFrozenState) --OnFreeze)
    inst:ListenForEvent("onremove",OnRemove)
    inst:ListenForEvent("attacked",OnAttacked)

    inst.typeid = 0
    inst.healthstage = "sdf_pumpkin_king_fresh"
    inst.phaseCount = 0
    inst.phaseReady = false
    inst.activeBattle = false
    inst.deadheadingCounter = 0
    inst.winterMode = false

    inst.createHuskSpawn = createHuskSpawn
    inst.createHusk = createHusk 
    inst.createHuskRest = createHuskRest
    inst.createHuskReset = createHuskReset
    inst.createHuskWinter = createHuskWinter
    inst.killhusk = killhusk

    inst.vines = {}
    inst.vinekilled = vinekilled
    inst.vineremoved = vineremoved
    inst.killvines = killvines
    inst.vinelimit = TUNING.SDF_PUMPKIN_KING_VINE_LIMIT

    inst.PlantPumpkingGourdSeed = PlantPumpkingGourdSeed
    inst.PlantPumpkingCreeperSeed = PlantPumpkingCreeperSeed
    inst.PlantPumpkingRandomSeed = PlantPumpkingRandomSeed

    inst.miasmaaoetask = nil
    inst.StartMiasmaAOELong = StartMiasmaAOELong
    inst.StartMiasmaAOEShort = StartMiasmaAOEShort
    inst.DoMiasmaSmall = DoMiasmaSmall
    inst.DoMiasmaDeathAOE = DoMiasmaDeathAOE
    inst.DoBombardment = DoBombardment

    inst.playSpawnAnimation = playSpawnAnimation
    inst.playSpawnWinterAnimation = playSpawnWinterAnimation

    inst.DoDeadheading = DoDeadheading
    inst.DeadheadingTask = nil

    --inst.OnLoad = OnLoad
    --inst.OnSave = OnSave
    --inst.OnLoadPostPass = OnLoadPostPass

    MakeMediumFreezableCharacter(inst)
    inst.components.freezable:SetResistance(6)
    MakeLargeBurnableCharacter(inst,"follow_gestalt_fx")

    inst:SetStateGraph("SGsdf_pumpkin_king")

    inst.persists = false
    inst.task = inst:DoTaskInTime(0, OnInit)

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    local s = 1.3 --0.9
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_pumpkin_king_husk")
    inst.AnimState:SetBuild("sdf_pumpkin_king_husk")
    inst.AnimState:PlayAnimation("idle_short", true)

    inst:AddTag("fx")
    inst:AddTag("NOCLICK")
    inst:AddTag("soulless")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_king_husk")

    inst.OnRemovedEntity = back_onremoveentity

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst.OnEntityReplicated = back_onentityreplicated
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKING_SEED_POD_HEALTH)
    inst.components.health:SetMinHealth(1)

    inst:AddComponent("colouradder")

    inst.persists = false

    return inst
end

local function OnWeakVineAttacked(inst)
    if inst.headplant ~= nil and inst.headplant:IsValid() then
	local parent = inst.headplant.parentplant
	if parent ~= nil and parent:IsValid() and parent.components.freezable:IsFrozen() then
	    parent.components.freezable:Unfreeze()
	end
    end
end

local function makeweak(inst, headplant)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKIN_KING_HEALTH * TUNING.SDF_PUMPKIN_KING_VINE_HEALTH_DAMAGE_PERCENT)
    inst.components.health.redirect = function(target, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
        if inst.headplant and inst.headplant:IsValid() then
            inst.headplant.indirectdamage = inst.GUID
            local result = inst.headplant.components.health:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
            if not inst.headplant.components.health:IsDead() then
                inst.headplant.indirectdamage = nil
            end
            return result
        end
    end
    inst:AddComponent("combat")

    inst:ListenForEvent("attacked", OnWeakVineAttacked)

    if headplant ~= nil then
	local target = headplant.components.combat.target
	if target ~= nil then
	    inst.components.combat:SetTarget(target)
	end
	inst:ListenForEvent("newcombattarget", function(headplant, data)
	    inst.components.combat:SetTarget(data.target)
	end, headplant)
	inst:ListenForEvent("droppedtarget", function(headplant, data)
	    inst.components.combat:DropTarget()
	end, headplant)
    end

    inst:AddTag("weakvine")
    inst.AnimState:SetBank("sdf_pumpkin_king_vine_big")
    inst.AnimState:SetBuild("sdf_pumpkin_king_vine_big")

    inst:RemoveTag("fx")
    inst:RemoveTag("NOCLICK")
    inst:AddTag("hostile")
    inst:AddTag("sdf_pumpkin_king_vine_segment")
end

local function vine_onremoveentity(inst)
    if inst.headplant ~= nil and inst.headplant.tails ~= nil then
	table.removearrayvalue(inst.headplant.tails, inst)
    end
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_pumpkin_king_vine")
    inst.AnimState:SetBuild("sdf_pumpkin_king_vine")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetFinalOffset(1)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetScale(1.2,1.2,1.2)

    inst:AddTag("fx")
    inst:AddTag("NOCLICK")
    inst:AddTag("soulless")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_king_vine_segment")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("colouradder")

    MakeMediumFreezableCharacter(inst)
    inst.components.freezable:SetResistance(6)
    MakeMediumBurnableCharacter(inst)

    inst.persists = false
    inst.makeweak = makeweak

    inst:SetStateGraph("SGsdf_pumpkin_king_vine")

    inst.OnRemoveEntity = vine_onremoveentity

    return inst
end


local function ChooseAction(inst)
    inst.target = inst.parentplant and inst.parentplant.components.combat.target
    if inst.target then
        inst.components.combat:SetTarget(inst.target)
    end
    
    if inst.mode == "retreat" then
    elseif not inst.target or not inst.target:IsValid() or not inst.target.components.health or inst.target.components.health:IsDead() then
        inst.target = nil
        inst.mode = "return"
    elseif inst.mode ~= "avoid" then
        inst.mode = "attack"
    end

    if inst.target and inst.mode == "attack" then
        local dist = inst:GetDistanceSqToInst(inst.target)
        if dist < TUNING.SDF_PUMPKIN_KING_VINE_END_INITIATE_ATTACK * TUNING.SDF_PUMPKIN_KING_VINE_END_INITIATE_ATTACK then
            if not inst.components.timer:TimerExists("attack_cooldown") then
                inst:PushEvent("doattack")
            end
        else
            local pos = Vector3(inst.target.Transform:GetWorldPosition())
            local theta = inst:GetAngleToPoint(pos)*DEGREES
            local radius = math.sqrt(dist) - TUNING.SDF_PUMPKIN_KING_VINE_END_CLOSEDIST
            local ITERATIONS = 5
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local newpos = Vector3(inst.Transform:GetWorldPosition())
            local onwater = false

            for i = 1, ITERATIONS do
                local testpos = newpos + offset * (i / ITERATIONS)
                if not TheWorld.Map:IsVisualGroundAtPoint(testpos.x, testpos.y, testpos.z) then
                    onwater = true
                    break
                end
            end

            newpos = newpos + offset

            dist = inst:GetDistanceSqToPoint(newpos)
            local moveback = nil
            for i,nub in ipairs(inst.tails)do
                local nubdist = nub:GetDistanceSqToPoint(newpos)
                if nubdist < dist then
                    dist = nubdist
                    moveback = true
                    break
                end
            end
            if moveback and not onwater then
                inst:PushEvent("moveback")
            else
                if #inst.tails < 7 and not onwater then
                    inst:PushEvent("moveforward", {newpos=newpos})
                else
                    inst:PushEvent("emerge")
                end
            end
        end
    elseif inst.mode == "avoid" then
            local pos = Vector3(inst.Transform:GetWorldPosition())
            local theta = (inst:GetAngleToPoint(pos)*DEGREES) - PI
            local radius = 4 * TUNING.SDF_PUMPKIN_KING_VINE_END_MOVEDIST
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local newpos = pos + offset
            local dist = inst:GetDistanceSqToPoint(newpos)
            local moveback = nil

            for i,nub in ipairs(inst.tails)do
                local nubdist = nub:GetDistanceSqToPoint(newpos)
                if nubdist < dist then
                    dist = nubdist
                    moveback = true
                    break
                end
            end
            if moveback then
                inst:PushEvent("moveback")
            else
                if #inst.tails < 7 then
                    inst:PushEvent("moveforward", {newpos=newpos})
                else
                    inst:PushEvent("emerge")
                end
            end
    elseif inst.mode == "return" or inst.mode == "retreat" then
        inst:PushEvent("moveback")
    end
end

local function removetail(inst)
    if #inst.tails > 0 then
        local time = 0
        for i=#inst.tails,1,-1 do
            time = time + 0.1
            local tail = inst.tails[i]
            if not tail.errodetask then
                if tail:HasTag("weakvine") and inst.indirectdamage == tail.GUID then
                    tail.sg:GoToState("death")
                end
		if tail.components.combat ~= nil then
		    tail:AddTag("NOCLICK")
		    tail:AddTag("notarget")
		end
                tail.errodetask = tail:DoTaskInTime(time,ErodeAway)
            end
        end
    end
end

local function setweakstate(inst, weak )
    if weak then
        inst:AddTag("weakvine")
        inst.AnimState:SetBank("sdf_pumpkin_king_vine_big")
        inst.AnimState:SetBuild("sdf_pumpkin_king_vine_big")
    else
        inst:RemoveTag("weakvine")
        inst.AnimState:SetBank("sdf_pumpkin_king_vine")
        inst.AnimState:SetBuild("sdf_pumpkin_king_vine")
    end
end

local function fn4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("plant")
    inst:AddTag("hostile")
    inst:AddTag("soulless")
    inst:AddTag("NPCcanaggro")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_king_vine_end")

    inst.AnimState:SetBank("sdf_pumpkin_king_vine")
    inst.AnimState:SetBuild("sdf_pumpkin_king_vine")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetFinalOffset(1)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetScale(1.2,1.2,1.2)

    inst.AnimState:SetMultColour(unpack({ 1, 1, 1, 1 })) --normal color
 
    inst.customPlayAnimation = customPlayAnimation
    inst.customPushAnimation = customPushAnimation

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKIN_KING_HEALTH * TUNING.SDF_PUMPKIN_KING_VINE_HEALTH_DAMAGE_PERCENT)
    inst.components.health.fire_damage_scale = TUNING.SDF_PUMPKIN_KING_FIRE_DAMAGE

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_PUMPKIN_KING_VINE_END_DAMAGE)

    inst:AddComponent("colouradder")
    inst:AddComponent("timer")

    inst:AddComponent("inspectable")

    inst.tails = {}
    inst.mode = "attack"
    inst.ChooseAction = ChooseAction
    inst.persists = false
    inst.setweakstate = setweakstate
    inst:ListenForEvent("attacked", function()
	if inst.mode == "attack" then
            inst.mode = "avoid"
            inst:DoTaskInTime(math.random()*3 + 1, function()
                inst.mode = "attack"
            end)
        end
	if inst.parentplant ~= nil and inst.parentplant:IsValid() and inst.parentplant.components.freezable:IsFrozen() then
	    inst.parentplant.components.freezable:Unfreeze()
	end
    end)
    inst:ListenForEvent("timerdone", function(inst,data)
        if data.name == "idletimer" then
            inst.mode = "retreat"
        end
    end)
    inst:ListenForEvent("death", function() 
        removetail(inst)
        if inst.parentplant and inst.parentplant:IsValid() then
            inst.parentplant:vinekilled(inst)
        end
    end)
    inst:ListenForEvent("onremove", function() 
        removetail(inst)
        if inst.parentplant and inst.parentplant:IsValid() then
            inst.parentplant:vineremoved(inst)
        end
    end)

    MakeMediumFreezableCharacter(inst)
    inst.components.freezable:SetResistance(6)
    MakeMediumBurnableCharacter(inst)

    inst:SetStateGraph("SGsdf_pumpkin_king_vine")

    return inst
end

return  Prefab("sdf_pumpkin_king", fn, assets, prefabs),
	Prefab("sdf_pumpkin_king_husk",fn2, assets, prefabs),
	Prefab("sdf_pumpkin_king_vine", fn3, vineassets, prefabs),
	Prefab("sdf_pumpkin_king_vine_end", fn4, vineassets, prefabs)