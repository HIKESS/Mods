require "prefabutil"

local assets =
{
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gourd_seeds.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gourd_seeds.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_bomb_seeds.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_bomb_seeds.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_creeper_seeds.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_creeper_seeds.xml"),

    Asset("ANIM", "anim/sdf_pumpkin_seeds.zip"),
    Asset("ANIM", "anim/sdf_pumpking_gourd.zip"),
    Asset("ANIM", "anim/sdf_pumpking_creeper.zip"),
}

local SOUND_TORMENTED_SCREAM = "dontstarve/creatures/leif/livinglog_burn"

local function FuelTaken(inst, taker)
    if taker ~= nil and taker.SoundEmitter ~= nil then
        taker.SoundEmitter:PlaySound(SOUND_TORMENTED_SCREAM)
    end
end

local function allanimalscanscream(inst)
    inst.SoundEmitter:PlaySound(SOUND_TORMENTED_SCREAM)
end

local function onignite(inst)
    allanimalscanscream(inst)
end

local function ondeploy(inst, pt)
    local pumpkinPlant = SpawnPrefab(inst.seedType)
    if pumpkinPlant ~= nil then
        pumpkinPlant.Transform:SetPosition(pt:Get())

        inst.components.stackable:Get():Remove()
        PreventCharacterCollisionsWithPlacedObjects(pumpkinPlant)

	pumpkinPlant.AnimState:PlayAnimation("grow_seed")
	pumpkinPlant.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_pumpkin_seeds")
    inst.AnimState:SetBuild("sdf_pumpkin_seeds")
    inst.AnimState:PlayAnimation("writhing")

    inst.pickupsound = "vegetation_firm"

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_PUMPKIN_SEEDS_MAXSTACKCOUNT

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SDF_PUMPKIN_SEEDS_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    MakeSmallBurnable(inst, TUNING.SDF_PUMPKIN_SEEDS_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_pumpkin_gourd_seeds"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pumpkin_gourd_seeds.xml"

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    inst.seedType = "sdf_pumpkin_gourd_plant"

    inst:ListenForEvent("onignite", onignite)
    inst.incineratesound = SOUND_TORMENTED_SCREAM

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_pumpkin_seeds")
    inst.AnimState:SetBuild("sdf_pumpkin_seeds")
    inst.AnimState:PlayAnimation("unstable")

    inst.pickupsound = "vegetation_firm"

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_PUMPKIN_SEEDS_MAXSTACKCOUNT

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SDF_PUMPKIN_SEEDS_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    MakeSmallBurnable(inst, TUNING.SDF_PUMPKIN_SEEDS_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_pumpkin_bomb_seeds"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pumpkin_bomb_seeds.xml"

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    inst.seedType = "sdf_pumpkin_bomb_plant"

    inst:ListenForEvent("onignite", onignite)
    inst.incineratesound = SOUND_TORMENTED_SCREAM

    return inst
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_pumpkin_seeds")
    inst.AnimState:SetBuild("sdf_pumpkin_seeds")
    inst.AnimState:PlayAnimation("skulking")

    inst.pickupsound = "vegetation_firm"

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_PUMPKIN_SEEDS_MAXSTACKCOUNT

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SDF_PUMPKIN_SEEDS_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    MakeSmallBurnable(inst, TUNING.SDF_PUMPKIN_SEEDS_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_pumpkin_creeper_seeds"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_pumpkin_creeper_seeds.xml"

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    inst.seedType = "sdf_pumpkin_creeper_plant"

    inst:ListenForEvent("onignite", onignite)
    inst.incineratesound = SOUND_TORMENTED_SCREAM

    return inst
end

return Prefab("common/inventory/sdf_pumpkin_gourd_seeds", fn, assets),
	Prefab("common/inventory/sdf_pumpkin_bomb_seeds", fn2, assets),
	Prefab("common/inventory/sdf_pumpkin_creeper_seeds", fn3, assets),
	MakePlacer("sdf_pumpkin_gourd_seeds_placer", "sdf_pumpking_gourd", "sdf_pumpking_gourd", "idle"),
	MakePlacer("sdf_pumpkin_bomb_seeds_placer", "sdf_pumpking_gourd", "sdf_pumpking_gourd", "idle"),
	MakePlacer("sdf_pumpkin_creeper_seeds_placer", "sdf_pumpking_creeper", "sdf_pumpking_creeper", "sleep_loop")