local assets= {
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
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_RELEASE_TIME, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_REGEN_TIME)
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

local function spawnerturnoff(inst, player)
    if inst.components.childspawner.childrenoutside ~= nil then --if inst.components.childspawner:CountChildrenOutside() > 0 then
	for k,v in pairs(inst.components.childspawner.childrenoutside) do
	    if v and v:IsValid() then
		v.components.health:StartRegen(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_HEALTH_REGEN_AMOUNT, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_HEALTH_REGEN_PERIOD)
            end
	end
    end
end

local function spawnerturnon(inst, player)
    if inst.components.childspawner.childrenoutside ~= nil then  --if inst.components.childspawner:CountChildrenOutside() > 0 then
	for k,v in pairs(inst.components.childspawner.childrenoutside) do
	    if v and v:IsValid() then
		v.components.health:StartRegen(0, 60)
            end
	end
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
    inst:AddTag("prototyper")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "sdf_jack_of_the_green_chess_bishop"
    inst.components.childspawner:SetSpawnedFn(OnSpawned)
    inst.components.childspawner:SetGoHomeFn(OnGoHome)

    inst.components.childspawner:SetRegenPeriod(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_MAX_SPAWN)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_RELEASE_TIME, true)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_REGEN_TIME, true)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_TARGET_DIST, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_TARGET_DIST +.5)
    inst.components.playerprox:SetOnPlayerNear(spawnerturnon)
    inst.components.playerprox:SetOnPlayerFar(spawnerturnoff)

    inst:WatchWorldState("isday", OnIsDay)
    StartSpawning(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return  Prefab("sdf_jack_of_the_green_chess_bishop_spawner", fn, assets)