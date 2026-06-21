local assets=
{
    Asset("ANIM", "anim/sdf_chest_kingdom.zip"),

    Asset("ATLAS", "images/map_icons/sdf_chest_kingdom_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chest_kingdom_mm.tex"),
}

prefabs = {
}

local sdf_chest_loot ={
{"bluegem"}, {"redgem"}, {"purplegem"}, {"yellowgem"}, {"greengem"}, {"orangegem"}
} --random gem

local function makeLoot(inst)
    local loot = sdf_chest_loot[math.random(#sdf_chest_loot)]
    return loot
end

local function StopLight(inst)
    inst._stoplighttask = nil
    inst.Light:Enable(false)
    if inst._staffstar == nil then
        inst.AnimState:ClearBloomEffectHandle()
    end
end

local function StopFX(inst)
    if inst._fxpulse ~= nil then
        inst._fxpulse:KillFX()
        inst._fxpulse = nil
    end
    if inst._fxfront ~= nil or inst._fxback ~= nil then
        if inst._fxback ~= nil then
            inst._fxfront:KillFX()
            inst._fxfront = nil
        end
        if inst._fxback ~= nil then
            inst._fxback:KillFX()
            inst._fxback = nil
        end
        if inst._stoplighttask ~= nil then
            inst._stoplighttask:Cancel()
        end
        inst._stoplighttask = inst:DoTaskInTime(9 * FRAMES, StopLight)
    end
    if inst._startlighttask ~= nil then
        inst._startlighttask:Cancel()
        inst._startlighttask = nil
    end
end

local function StartLight(inst)
    inst._startlighttask = nil
    inst.Light:Enable(true)
    if inst._staffstar == nil then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function StartFX(inst)
    if inst._fxfront == nil or inst._fxback == nil then
        local x, y, z = inst.Transform:GetWorldPosition()

        if inst._fxpulse ~= nil then
            inst._fxpulse:Remove()
        end
        inst._fxpulse = SpawnPrefab("sdf_lunar_beam_pulse")
        inst._fxpulse.Transform:SetPosition(x, y, z)

        if inst._fxfront ~= nil then
            inst._fxfront:Remove()
        end
        inst._fxfront = SpawnPrefab("sdf_lunar_beam_front")
        inst._fxfront.Transform:SetPosition(x, y, z)

        if inst._fxback ~= nil then
            inst._fxback:Remove()
        end
        inst._fxback = SpawnPrefab("sdf_lunar_beam_back")
        inst._fxback.Transform:SetPosition(x, y, z)

        if inst._startlighttask ~= nil then
            inst._startlighttask:Cancel()
        end
        inst._startlighttask = inst:DoTaskInTime(3 * FRAMES, StartLight)
    end
    if inst._stoplighttask ~= nil then
        inst._stoplighttask:Cancel()
        inst._stoplighttask = nil
    end
end

local function OnRemoveEntity(inst)
    if inst._fxpulse ~= nil then
        inst._fxpulse:Remove()
        inst._fxpulse = nil
    end
    if inst._fxfront ~= nil then
        inst._fxfront:Remove()
        inst._fxfront = nil
    end
    if inst._fxback ~= nil then
        inst._fxback:Remove()
        inst._fxback = nil
    end
end

local CHECK_STONE_GOLEM_TARGET_PLAYER_MUST_HAVE_TAGS = {"player", "sdf_stone_golem_target"}
local CHECK_STONE_GOLEM_TARGET_PLAYER_CANT_HAVE_TAGS = {"playerghost", "INLIMBO", "companion", "ghost"}
local CHECK_STONE_GOLEM_TARGET_PLAYER_AOE_RADIUS = 50
local function aoeStoneGolemTargetPlayerCheck(inst, clearStatus)
    local tx, ty, tz = inst.Transform:GetWorldPosition()
    local targettedPlayers = 0
    local affected_entity = TheSim:FindEntities(tx, ty, tz, CHECK_STONE_GOLEM_TARGET_PLAYER_AOE_RADIUS, CHECK_STONE_GOLEM_TARGET_PLAYER_MUST_HAVE_TAGS, CHECK_STONE_GOLEM_TARGET_PLAYER_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find players targetted
	if v ~= nil then

	    --remove target tag
	    if clearStatus == true then
		v:RemoveTag("sdf_stone_golem_target")
	    end
	    targettedPlayers = targettedPlayers + 1
	end
    end

    --players targetted
    if targettedPlayers > 0 then
	return false
    end
    return true
end

local function makebarrenfn(inst)
    if inst.components.workable then
	inst:RemoveComponent("workable")
    end

    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("removed", true)

    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(x,_,z)
    inst:DoTaskInTime(0.5, function()

	--Create Loot
	if inst.ActivePlayer ~= nil then
	    if inst.ActivePlayer.prefab == "sdf" then
		if inst.ActivePlayer.components.sdf_king_peregrin_quest:GetCrownFoundStatus() == false then
		    inst.ActivePlayer.components.sdf_king_peregrin_quest:SetCrownFoundStatus()
		    inst.lootchest = {"sdf_king_peregrins_crown_lost"}
		    inst.components.lootdropper:SetLoot(inst.lootchest)
		else
		    inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_giants_ocarina", TUNING.SDF_CHEST_KINGDOM_GIANTS_OCARINA_CHANCE)
		end
	    else
		inst.components.lootdropper:AddChanceLoot("sdf_asgard_golem_giants_ocarina", TUNING.SDF_CHEST_KINGDOM_GIANTS_OCARINA_CHANCE)
	    end
	end
	inst.components.lootdropper:DropLoot()
    end)
    inst:DoTaskInTime(0.7, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("maxwell_smoke").Transform:SetPosition(x,_,z)
	SpawnPrefab("green_leaves").Transform:SetPosition(x,_-1,z)
    end)

    inst:DoTaskInTime(2.5, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	--SpawnPrefab("dirt_puff").Transform:SetPosition(x,_,z)

	SpawnPrefab("sdf_chest_kingdom_empty").Transform:SetPosition(x,_,z)
	inst:Remove()
    end)
end

local function onpickedfn(inst, picker)
    if inst.components.pickable ~= nil then
	inst.Physics:SetActive(false)
	inst.ActivePlayer = picker

	--check if locked
	if inst.isLocked == false then

	    --remove target players
	    aoeStoneGolemTargetPlayerCheck(inst, true)

	    StopFX(inst)
	    inst.components.pickable:MakeBarren()
	else
	    --aggro player
	    if not picker:HasTag("sdf_stone_golem_target") then
		picker:AddTag("sdf_stone_golem_target")
	    end
	end
    end
end

local function onhammered(inst, worker)
    inst.Physics:SetActive(false)
    inst.ActivePlayer = worker

    --check if locked
    if inst.isLocked == false then

	--remove target players
	aoeStoneGolemTargetPlayerCheck(inst, true)

	StopFX(inst)
	inst.components.pickable:MakeBarren()
    else

	--aggro player
	if not worker:HasTag("sdf_stone_golem_target") then
	    worker:AddTag("sdf_stone_golem_target")
	end
    end
end

local SPAWN_STONE_GOLEM_MUST_HAVE_TAGS = {"sdf_stone_golem_cradle"}
local SPAWN_STONE_GOLEM_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local SPAWN_STONE_GOLEM_AOE_RADIUS = 50
local function aoeStoneGolemCradleSpotCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, SPAWN_STONE_GOLEM_AOE_RADIUS, SPAWN_STONE_GOLEM_MUST_HAVE_TAGS, SPAWN_STONE_GOLEM_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find stone golem cradle spots
	if v ~= nil then

	    --make stone golem
	    if v.components.childspawner then
		if v.components.childspawner.numchildrenoutside == 0 then
		    v:CreateGolemFn()
		end
	    end
	end
    end
    return false
end

local function spawnstoneGolem(inst)
    if aoeStoneGolemTargetPlayerCheck(inst, false) == true then
	--reset locks
	inst.armoredLocked = true
	inst.coreLocked = true

	--respawn stone golems
	aoeStoneGolemCradleSpotCheck(inst)
    end
end

local function onUnlockChest(inst)
    --remove locked tag
    if inst:HasTag("sdf_chest_kingdom_locked") then
	inst:RemoveTag("sdf_chest_kingdom_locked")
    end

    --stop shadow barrier
    if inst.shadowbarriertask ~= nil then
	inst.shadowbarriertask:Cancel()
	inst.shadowbarriertask = nil
    end

    --stop spawning
    if inst.spawnstonegolemtask ~= nil then
	inst.spawnstonegolemtask:Cancel()
	inst.spawnstonegolemtask = nil
    end

    --create light
    StartFX(inst)
end

local CLEARED_STONE_GOLEM_MUST_HAVE_TAGS = {"sdf_stone_golem"}
local CLEARED_STONE_GOLEM_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local CLEARED_STONE_GOLEM_AOE_RADIUS = 50
local function aoeStoneGolemClearedCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, CLEARED_STONE_GOLEM_AOE_RADIUS, CLEARED_STONE_GOLEM_MUST_HAVE_TAGS, CLEARED_STONE_GOLEM_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find stone golems
	if v ~= nil then
	    return false
	end
    end
    return true
end

local function makeShadowBarrier(inst)
    --create a shadow barrier
    local shadowBarrier = SpawnPrefab("sdf_shadow_barrier")
    shadowBarrier.entity:SetParent(inst.entity)
    local scale = 0.6
    shadowBarrier.AnimState:SetScale(scale, scale, scale)
    shadowBarrier.repel_radius = TUNING.SDF_CHEST_KINGDOM_SHADOW_BARRIER_REPEL_RADIUS

    --check locks
    if inst.armoredLocked == false and inst.coreLocked == false then
	if aoeStoneGolemClearedCheck(inst) == true then

	    --unlock chest
	    inst.isLocked = false
	    onUnlockChest(inst)
	end
    end

    --continue shadow barrier
    if inst.isLocked == true then
	inst.shadowbarriertask = inst:DoTaskInTime(2, makeShadowBarrier)
    end
end

local function startShadowBarrier(inst)
    inst.shadowbarriertask = inst:DoTaskInTime(math.random(2, 5), makeShadowBarrier)
end

local function updateLock(inst)
    if inst.isLocked == true then
	if not inst:HasTag("sdf_chest_kingdom_locked") then
	    inst:AddTag("sdf_chest_kingdom_locked")
	end

	--create shadow barrier
	inst.shadowbarriertask = inst:DoTaskInTime(0, startShadowBarrier)

	--start spawning
	inst.spawnstonegolemtask = inst:DoPeriodicTask(TUNING.SDF_CHEST_KINGDOM_STONE_GOLEM_RESPAWN_TICK, spawnstoneGolem)
    else
	onUnlockChest(inst)
    end
end

local function onload(inst, data)
    if data ~= nil and data.isLocked ~= nil then
        inst.isLocked = data.isLocked
	updateLock(inst)
    end
end

local function onsave(inst, data)
    data.isLocked = inst.isLocked
end

local function showOnMap(inst)
    if inst.icon == nil then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon:TrackEntity(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_kingdom_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst.AnimState:SetBank("sdf_chest_kingdom")
    inst.AnimState:SetBuild("sdf_chest_kingdom")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    inst.Light:SetRadius(2)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(.75)
    inst.Light:SetColour(128 / 255, 128 / 255, 255 / 255)
    inst.Light:Enable(false)

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("soulless")
    inst:AddTag("sdf_chest_kingdom")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.lootchest = makeLoot(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(inst.lootchest)

    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("", 0, 0)
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.jostlepick = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.ActivePlayer = nil
    inst.isLocked = true
    inst.armoredLocked = true
    inst.coreLocked = true

    updateLock(inst)

    inst._fxpulse = nil
    inst._fxfront = nil
    inst._fxback = nil
    inst._startlighttask = nil
    inst._stoplighttask = nil
    inst.OnRemoveEntity = OnRemoveEntity

    inst:DoTaskInTime(0, showOnMap)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function on_day_change(inst)
    local regenerationCount = inst.components.sdf_chest_regeneration:GetRegenerationCount()
    local regenerationCountMax = inst.components.sdf_chest_regeneration:GetMaxRegenerationCount()

    if regenerationCount >= regenerationCountMax then
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("halloween_moonpuff").Transform:SetPosition(x,_,z)
	inst:DoTaskInTime(0.5, function()
	    local x,_,z = inst.Transform:GetWorldPosition()
	    SpawnPrefab("sdf_chest_kingdom").Transform:SetPosition(x,_,z)

	    inst:Remove()
	end)
    else
	inst.components.sdf_chest_regeneration:SetRegenerationCount(regenerationCount + 1)
    end
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_kingdom_mm.tex")

    inst.AnimState:SetBank("sdf_chest_kingdom")
    inst.AnimState:SetBuild("sdf_chest_kingdom")
    inst.AnimState:PlayAnimation("removed")
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    --MakeObstaclePhysics(inst, .5)

    inst:AddTag("sdf_chest_kingdom")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Kingdom Chest
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_CHEST_KINGDOM_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("cycles", on_day_change)

    return inst
end

return  Prefab("sdf_chest_kingdom", fn, assets),
	Prefab("sdf_chest_kingdom_empty", fn2, assets)