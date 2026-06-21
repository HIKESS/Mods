require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_pond.zip"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gorge_pond_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gorge_pond_mm.xml"),
}


local prefabs =
{

}

local VALID_TILE_TYPES =
{
    [WORLD_TILES.MARSH] = true,
    [WORLD_TILES.DIRT] = true,
}

local function SlipperyRate(inst, target)
    local speed = target.Physics and target.Physics:GetMotorSpeed() or 0
    if speed > TUNING.WILSON_RUN_SPEED then
        return 50
    end

    return 5
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .04 then
        if not inst.frozen then
            inst.frozen = true

            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/winter/pondfreeze")

	    inst.components.sdf_pumpkin_gorge_resource_spawner.shouldspawn = false

            inst.components.watersource.available = false
            local slipperyfeettarget = inst:AddComponent("slipperyfeettarget")
            slipperyfeettarget:SetSlipperyRate(SlipperyRate)
        end
    elseif inst.frozen then
        inst.frozen = false

        inst.AnimState:PlayAnimation("idle", true)

	inst.components.sdf_pumpkin_gorge_resource_spawner.shouldspawn = true
	inst.components.sdf_pumpkin_gorge_resource_spawner:StartNextSpawn()

        inst.components.watersource.available = true
        inst:RemoveComponent("slipperyfeettarget")
    elseif inst.frozen == nil then
        inst.frozen = false

        inst.AnimState:PlayAnimation("idle", true)

	inst.components.sdf_pumpkin_gorge_resource_spawner.shouldspawn = true
	inst.components.sdf_pumpkin_gorge_resource_spawner:StartNextSpawn()

        inst.components.watersource.available = true
        inst:RemoveComponent("slipperyfeettarget")
    elseif inst.frozen == false then

        inst.AnimState:PlayAnimation("idle", true)

	inst.components.sdf_pumpkin_gorge_resource_spawner.shouldspawn = true
	inst.components.sdf_pumpkin_gorge_resource_spawner:StartNextSpawn()

        inst.components.watersource.available = true
        inst:RemoveComponent("slipperyfeettarget")
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SDF_PUMPKIN_GORGE_POND_SPAWN_TIME, TUNING.SDF_PUMPKIN_GORGE_POND_REGEN_TIME)
end

local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_pumpkin_gorge_pond_mm.tex")

    local s = 1.95 --1.9
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBuild("sdf_pumpkin_gorge_pond")
    inst.AnimState:SetBank("sdf_pumpkin_gorge_pond")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    -- From watersource component
    inst:AddTag("watersource")
    inst:AddTag("pond")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")
    inst:AddTag("sdf_pumpkin_gorge_resource")
    inst:AddTag("sdf_pumpkin_gorge_pond")

    inst.no_wet_prefix = true

    inst:SetDeploySmartRadius(4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sdf_pumpkin_gorge_resource_spawner")
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMinionType("sdf_pumpkin_gorge_pondfish")
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetSpawnTime(TUNING.SDF_PUMPKIN_GORGE_POND_SPAWN_TIME)
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMinionSpawnTime({ min = TUNING.SDF_PUMPKIN_GORGE_POND_SPAWN_TIME, max = TUNING.SDF_PUMPKIN_GORGE_POND_REGEN_TIME })
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMaxMinion(TUNING.SDF_PUMPKIN_GORGE_POND_SPAWN_MAX)
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMaxMinionPool(TUNING.SDF_PUMPKIN_GORGE_POND_SPAWN_MAX)
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetDistanceModifier(TUNING.SDF_PUMPKING_GORGE_POND_SPAWN_DIST)
    inst.components.sdf_pumpkin_gorge_resource_spawner.validtiletypes = VALID_TILE_TYPES

    inst:AddComponent("inspectable")

    inst:AddComponent("watersource")

    inst.dayspawn = true
    inst.task = inst:DoTaskInTime(0, OnInit)

    return inst
end

return Prefab( "sdf_pumpkin_gorge_pond", fn, assets, prefabs)