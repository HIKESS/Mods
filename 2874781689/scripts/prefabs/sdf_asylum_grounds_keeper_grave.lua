local assets=
{
    Asset("ANIM", "anim/sdf_asylum_grounds_keeper_grave.zip"),
}

prefabs = {
}

local function StartSpawning(inst)
    inst.components.childspawner:StartSpawning()
end

local function StopSpawning(inst)
    inst.components.childspawner:StopSpawning()
end

local function OnSpawned(inst, child)
    if TheWorld.state.isday and
	inst.components.childspawner ~= nil and
	inst.components.childspawner:CountChildrenOutside() >= 1 and
	child.components.combat.target == nil then
	StopSpawning(inst)
    end
end

local function OnGoHome(inst, child)
    if inst.components.childspawner ~= nil and
	inst.components.childspawner:CountChildrenOutside() < 1 then
	StartSpawning(inst)
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_RELEASE_TIME, TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_REGEN_TIME)
end

local function OnIsDay(inst, isday)
    if isday then
        StopSpawning(inst)
    else
	inst.components.childspawner:ReleaseAllChildren()
        StartSpawning(inst)
    end
end

local function OnHaunt(inst, haunter)
    return true
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_asylum_grounds_keeper_grave")
    inst.AnimState:SetBuild("sdf_asylum_grounds_keeper_grave")
    inst.AnimState:PlayAnimation("idle")

    --MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "sdf_asylum_grounds_keeper"
    inst.components.childspawner:SetSpawnedFn(OnSpawned)
    inst.components.childspawner:SetGoHomeFn(OnGoHome)

    inst.components.childspawner:SetRegenPeriod(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_MAX_SPAWN)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_RELEASE_TIME, true)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_REGEN_TIME, true)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("isday", OnIsDay)

    StartSpawning(inst)

    --MakeSnowCovered(inst)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return  Prefab("sdf_asylum_grounds_keeper_grave", fn, assets)