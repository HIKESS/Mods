require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_pond.zip"),
    Asset("ANIM", "anim/sdf_pumpkin_gorge_farmland_debris.zip"),
}


local prefabs =
{

}

local VALID_TILE_TYPES =
{
    [WORLD_TILES.QUAGMIRE_SOIL] = true,
}

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_TIME, TUNING.SDF_PUMPKIN_GORGE_FARMLAND_REGEN_TIME)
end

local function OnInit(inst)
    inst.task = nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("sdf_pumpkin_gorge_resource")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sdf_pumpkin_gorge_resource_spawner")
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMinionType("sdf_pumpkin_gorge_farmland_debris")
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMinionSpawnTime({ min = TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_TIME, max = TUNING.SDF_PUMPKIN_GORGE_FARMLAND_REGEN_TIME })
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetSpawnTime(TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_TIME)
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMaxMinion(TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_MAX)
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetMaxMinionPool(TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_MAX)
    inst.components.sdf_pumpkin_gorge_resource_spawner:SetDistanceModifier(TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_DIST)
    inst.components.sdf_pumpkin_gorge_resource_spawner.validtiletypes = VALID_TILE_TYPES

    inst.dayspawn = true
    inst.task = inst:DoTaskInTime(0, OnInit)

    return inst
end


local anim_names = { "f1", "f2", "f3", "f4" }

local chance_loot =
{
	spoiled_food = 40,
	twigs = 25,
	rocks = 20,
	flint = 10,
	nitre = 5,
	sdf_pumpkin_gourd_seeds = 1,
	sdf_pumpkin_bomb_seeds = 1,
	sdf_pumpkin_creeper_seeds = 1,
}

for k, _ in pairs(chance_loot) do
    table.insert(prefabs, k)
end

local function onfinishcallback(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    SpawnPrefab("dirt_puff").Transform:SetPosition(x, y, z)

    inst:Remove()

    if math.random() < TUNING.SDF_PUMPKIN_GORGE_FARMLAND_DEBRIS_LOOT_CHANCE then
        inst.components.lootdropper:SpawnLootPrefab(weighted_random_choice(chance_loot))
    end
end

local function OnSpawnIn(inst)
    inst:Show()
    inst.AnimState:PlayAnimation(inst.animname.."_pre", false)
    inst.AnimState:PushAnimation(inst.animname, false)
end

local function onsave(inst, data)
    data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
        inst.AnimState:PlayAnimation(inst.animname)
	inst:Show()
	if inst._spawn_task ~= nil then
	    inst._spawn_task:Cancel()
	    inst._spawn_task = nil
	end
    end
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_pumpkin_gorge_farmland_debris")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_farmland_debris")
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")

    inst:Hide()

    inst:AddTag("farm_debris")
    inst:AddTag("farm_plant_killjoy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.animname = anim_names[math.random(#anim_names)]

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    inst:AddComponent("lootdropper")

    if not POPULATING then
	inst._spawn_task = inst:DoTaskInTime(0, OnSpawnIn)
    end

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab( "sdf_pumpkin_gorge_farmland", fn, assets, prefabs),
	Prefab( "sdf_pumpkin_gorge_farmland_debris", fn2, assets, prefabs)