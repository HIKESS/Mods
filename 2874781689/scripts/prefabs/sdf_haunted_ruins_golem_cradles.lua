local assets= {
}

prefabs = {
}


local function onCreateGolem(inst)
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StartRegen()
end

local function OnSpawnedGolem(inst, child)
    if child ~= nil then
	local x, y, z = child.Transform:GetWorldPosition()
	child.Transform:SetPosition(x, y, z)
	child.components.knownlocations:RememberLocation("spawnpoint", Vector3(x, 0, z))
    end
    inst.components.childspawner:StopSpawning()
    inst.components.childspawner:StopRegen()
end

local function OnPreLoadStoneGolem(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SDF_STONE_GOLEM_SPAWN_RELEASE_TIME, TUNING.SDF_STONE_GOLEM_SPAWN_REGEN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("sdf_stone_golem_cradle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "sdf_stone_golem_armored"
    inst.components.childspawner:SetMaxChildren(TUNING.SDF_STONE_GOLEM_SPAWN_MAX_SPAWN)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SDF_STONE_GOLEM_SPAWN_RELEASE_TIME)
    inst.components.childspawner:SetRegenPeriod(TUNING.SDF_STONE_GOLEM_SPAWN_REGEN_TIME)
    inst.components.childspawner:StopSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(OnSpawnedGolem)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SDF_STONE_GOLEM_SPAWN_RELEASE_TIME, true)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SDF_STONE_GOLEM_SPAWN_REGEN_TIME, true)

    inst.CreateGolemFn = function() onCreateGolem(inst) end

    inst.OnPreLoad = OnPreLoadStoneGolem

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("sdf_stone_golem_cradle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "sdf_stone_golem_core"
    inst.components.childspawner:SetMaxChildren(TUNING.SDF_STONE_GOLEM_SPAWN_MAX_SPAWN)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SDF_STONE_GOLEM_SPAWN_RELEASE_TIME)
    inst.components.childspawner:SetRegenPeriod(TUNING.SDF_STONE_GOLEM_SPAWN_REGEN_TIME)
    inst.components.childspawner:StopSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(OnSpawnedGolem)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SDF_STONE_GOLEM_SPAWN_RELEASE_TIME, true)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SDF_STONE_GOLEM_SPAWN_REGEN_TIME, true)

    inst.CreateGolemFn = function() onCreateGolem(inst) end

    inst.OnPreLoad = OnPreLoadStoneGolem

    return inst
end

local function OnPreLoadLavaGolem(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SDF_LAVA_GOLEM_SPAWN_RELEASE_TIME, TUNING.SDF_LAVA_GOLEM_SPAWN_REGEN_TIME)
end

local function onload(inst, data)
    if data then
	if data ~= nil and data.typeid ~= nil then
            inst.typeid = data.typeid
	end
    end
end

local function onsave(inst, data)
    data.typeid = inst.typeid
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("sdf_lava_golem_cradle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "sdf_lava_golem"
    inst.components.childspawner:SetMaxChildren(TUNING.SDF_LAVA_GOLEM_SPAWN_MAX_SPAWN)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SDF_LAVA_GOLEM_SPAWN_RELEASE_TIME)
    inst.components.childspawner:SetRegenPeriod(TUNING.SDF_LAVA_GOLEM_SPAWN_REGEN_TIME)
    inst.components.childspawner:StopSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(OnSpawnedGolem)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SDF_LAVA_GOLEM_SPAWN_RELEASE_TIME, true)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SDF_LAVA_GOLEM_SPAWN_REGEN_TIME, true)

    inst.typeid = 0
    inst.CreateGolemFn = function() onCreateGolem(inst) end

    inst.OnPreLoad = OnPreLoadLavaGolem
    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_stone_golem_armored_cradle", fn, assets),
	Prefab("sdf_stone_golem_core_cradle", fn2, assets),
	Prefab("sdf_lava_golem_cradle", fn3, assets)