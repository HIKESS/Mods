local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_plant.zip"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gourd_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gourd_mm.xml"),
}

local prefabs =
{

}

local SOUND_TORMENTED_SCREAM = "dontstarve/creatures/leif/livinglog_burn"

local builds =
{
    sdf_pumpkin_bomb_plant = {
        build = "sdf_pumpkin_gorge_plant",
        bank = "sdf_pumpkin_gorge_plant",
    },
}

local function OnSpawned(inst, child)
    if inst.components.childspawner ~= nil then
	inst.components.childspawner.childreninside = 0
	inst.components.childspawner:StopSpawning()
	inst.components.growable:StopGrowing()
    end
end

local function OnChildKilled(inst, child)
    inst.AnimState:PlayAnimation("rot_to_sprout")
    inst.AnimState:PushAnimation("crop_sprout", true)

    inst:DoTaskInTime(1, function()
	inst.components.growable:SetStage(2)
	inst.Physics:SetActive(true)

	if inst.components.childspawner ~= nil then
	    inst.components.childspawner.childreninside = 1

	    if TheWorld.state.isday and not TheWorld.state.iswinter then
		inst.components.growable:StartGrowing()
	    else
		inst.components.growable:StopGrowing()
	    end
	end
    end)
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.SDF_PUMPKIN_BOMB_PLANT_RELEASE_TIME, TUNING.SDF_PUMPKIN_BOMB_PLANT_REGEN_TIME)
end

local function SetSmashed(inst)
    inst.smashed = true

    inst.AnimState:PlayAnimation("crop_rot", true)
    inst.components.growable:StopGrowing()

    --disable burnable
    if inst.components.burnable then
	inst:RemoveComponent("burnable")
    end

    inst:DoTaskInTime(GetRandomWithVariance(30, 60), function()
	inst.smashed = false
	inst.AnimState:PlayAnimation("rot_to_sprout")

	inst:DoTaskInTime(1, function()
	    inst.components.growable:SetStage(2)
	    if TheWorld.state.isday and not TheWorld.state.iswinter then
		inst.components.growable:StartGrowing()
	    end
	end)
    end)
end

local function allanimalscanscream(inst)
    inst.SoundEmitter:PlaySound(SOUND_TORMENTED_SCREAM)
end

local function onignite(inst)
    allanimalscanscream(inst)
end

local function ondig(inst, worker)

    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:DropLoot()
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("dirt_puff").Transform:SetPosition(x, y, z)
    inst.AnimState:PlayAnimation("dug")

    inst:Remove()
end

local function onhammered(inst, worker)
    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 1.5 --1.5
    local pumpkinDeathFX = SpawnPrefab("pumpkincarving_shatter_fx")
    pumpkinDeathFX.Transform:SetPosition(x,_,z)
    pumpkinDeathFX.Transform:SetScale(s,s,s)
    local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
    pumpkinDeath2FX.Transform:SetPosition(x,_,z)

    if inst.components.growable:GetStage() > 5 then
	inst.AnimState:PlayAnimation("dug")
    end

    --allow work dig
    if not inst.components.workable then
	inst:AddComponent("workable")
    end
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(ondig)

   SetSmashed(inst)
end

local function OnBurnt(inst, immediate)
    if inst.components.growable:GetStage() > 3 then
	local x,_,z=inst.Transform:GetWorldPosition()
	local s = 1.5 --1.5
	local pumpkinDeathFX = SpawnPrefab("pumpkincarving_shatter_fx")
	pumpkinDeathFX.Transform:SetPosition(x,_,z)
	pumpkinDeathFX.Transform:SetScale(s,s,s)
	local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
	pumpkinDeath2FX.Transform:SetPosition(x,_,z)

	if inst.components.growable:GetStage() > 5 then
	    inst.AnimState:PlayAnimation("dug")
	else
	    SetSmashed(inst)
	end
    else
	SetSmashed(inst)
    end
end

local function AddActionDig(inst)
    --allow work dig
    if not inst.components.workable then
	inst:AddComponent("workable")
    end
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(ondig)
end

local function AddActionHammer(inst)
    --allow work Hammer
    if not inst.components.workable then
	inst:AddComponent("workable")
    end
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)
end

local function RemoveAction(inst)
    --disable work
    if inst.components.workable then
	inst:RemoveComponent("workable")
    end
end

local function AddBurnable(inst)
    --allow Burnable
    if not inst.components.burnable then
	inst:RemoveTag("burnt")

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	inst.components.burnable:SetOnBurntFn(OnBurnt)
    end
end

local function RemoveBurnable(inst)
    --disable burnable
    if inst.components.burnable then
	inst:RemoveComponent("burnable")
    end
end

local function GrowSeed(inst)
    inst.AnimState:PlayAnimation("grow_seed")
    inst.AnimState:PushAnimation("crop_seed", true)
end

local function SetSeed(inst)
    inst.AnimState:PlayAnimation("crop_seed", true)

    --allow work
    AddActionDig(inst)

    --disable burnable
    RemoveBurnable(inst)
end

local function GrowSprout(inst)
    inst.AnimState:PlayAnimation("grow_sprout")
    inst.AnimState:PushAnimation("crop_sprout", true)
end

local function SetSprout(inst)
    inst.AnimState:PlayAnimation("crop_sprout", true)

    --disable work
    RemoveAction(inst)

    --disable burnable
    RemoveBurnable(inst)
end

local function GrowSmall(inst)
    inst.AnimState:PlayAnimation("grow_small")
    inst.AnimState:PushAnimation("crop_small", true)
end

local function SetSmall(inst)
    inst.AnimState:PlayAnimation("crop_small", true)

    --allow work
    AddActionDig(inst)

    --allow fire
    AddBurnable(inst)
end

local function GrowMed(inst)
    inst.AnimState:PlayAnimation("grow_med")
    inst.AnimState:PushAnimation("crop_med", true)
end

local function SetMed(inst)
    inst.AnimState:PlayAnimation("crop_med", true)

    --allow work
    AddActionHammer(inst)

    --allow fire
    AddBurnable(inst)
end

local function GrowFull(inst)
    inst.AnimState:PlayAnimation("grow_full")
    inst.SoundEmitter:PlaySound("farming/common/farm/grow_full")

    inst.AnimState:PushAnimation("crop_full", true)
end

local function SetFull(inst)
    inst.AnimState:PlayAnimation("crop_full", true)

    --allow work
    AddActionHammer(inst)

    --allow fire
    AddBurnable(inst)
end

local function GrowOversized(inst)
    inst.AnimState:PlayAnimation("grow_oversized")
    inst.SoundEmitter:PlaySound("farming/common/farm/pumpkin/grow_oversized")

    inst.AnimState:PushAnimation("crop_oversized", true)
end

local function SetOversized(inst)
    inst.AnimState:PlayAnimation("crop_oversized", true)

    --allow work
    AddActionHammer(inst)

    --allow fire
    AddBurnable(inst)
end

local function GrowHarvest(inst)
    inst.AnimState:PlayAnimation("dug")
    inst.Physics:SetActive(false)
end

local function SetHarvest(inst)
    --disable work
    RemoveAction(inst)

    --disable burnable
    RemoveBurnable(inst)

    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 1.5 --1.5
    local pumpkinSpawnFX = SpawnPrefab("disease_puff")
    pumpkinSpawnFX.Transform:SetPosition(x,_,z)
    pumpkinSpawnFX.Transform:SetScale(s,s,s)

    inst.AnimState:PlayAnimation("picked")

    if inst.components.childspawner.childreninside >= 1 and inst.components.childspawner:CountChildrenOutside() <= 0 then
	inst.components.childspawner:StartSpawning()
    end
end

local growth_stages = {}
for build, data in pairs(builds) do
    growth_stages[build] =
    {
        {
            name = "seed",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.01, (TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.01) end,
            fn = SetSeed,
            growfn = GrowSeed,
        },
        {
            name = "sprout",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.1, (TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.1) end,
            fn = SetSprout,
            growfn = GrowSprout,
        },
        {
            name = "small",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.2, (TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.2) end,
            fn = SetSmall,
            growfn = GrowSmall,
        },
        {
            name = "med",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.3, (TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.3) end,
            fn = SetMed,
            growfn = GrowMed,
        },
        {
            name = "full",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.4, (TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.4) end,
            fn = SetFull,
            growfn = GrowFull,
        },
        {
            name = "oversized",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.5, (TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.5) end,
            fn = SetOversized,
            growfn = GrowOversized,
        },
        {
            name = "harvest",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.4, (TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.4) end,
            fn = SetHarvest,
            growfn = GrowHarvest,
        },
    }
end

local function OnSave(inst, data)
    if inst.smashed == true then
	data.smashed = true
    else
	data.smashed = false
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.smashed ~= nil then
	if data.smashed == true then
	    inst.smashed = true
	    SetSmashed(inst)
	end
    end

    if inst.components.growable:GetStage() >= 7 then
	inst.Physics:SetActive(false)
    end
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .01 then
        if not inst.frozen then
            inst.frozen = true

	    --add frost
	    inst.components.colouradder:PushColour("frost", 82 / 255, 115 / 255, 124 / 255, 0)
	    inst.AnimState:Pause()

            inst.components.growable:StopGrowing()
	end
    elseif inst.frozen then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")
	inst.AnimState:Resume()

	if inst.smashed == false and inst.components.childspawner.childreninside >= 1 then
	    inst.components.growable:StartGrowing()
	end
    elseif inst.frozen == nil then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")
	inst.AnimState:Resume()

	if inst.smashed == false and inst.components.childspawner.childreninside >= 1 then
	    inst.components.growable:StartGrowing()
	end
    elseif inst.frozen == false then

	--remove frost
	inst.components.colouradder:PopColour("frost")
	inst.AnimState:Resume()

	if inst.smashed == false and inst.components.childspawner.childreninside >= 1 then
	    inst.components.growable:StartGrowing()
	end
    end
end

local function OnIsDay(inst, isday)
    if isday ~= inst.dayspawn then
	inst.components.growable:StopGrowing()
    elseif not TheWorld.state.iswinter then
	if inst.smashed == false and inst.components.childspawner.childreninside >= 1 then
	    inst.components.growable:StartGrowing()
	end
    end
end

local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("isday", OnIsDay)
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnIsDay(inst, TheWorld.state.isday)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function GetGrowthStages(inst)
    return growth_stages[inst.build] or growth_stages["sdf_pumpkin_bomb_plant"]
end

local function GetBuild(inst)
    return builds[inst.build] or builds["sdf_pumpkin_bomb_plant"]
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_pumpkin_gourd_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2)
    inst:SetPhysicsRadiusOverride(.25)
    MakeObstaclePhysics(inst, 0.25)

    inst.build = "sdf_pumpkin_bomb_plant"

    --local scale = 1
    --inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBuild(GetBuild(inst).build)
    inst.AnimState:SetBank(GetBuild(inst).bank)

    inst:AddTag("sdf_pumpkin_plant")
    inst:AddTag("sdf_pumpkin_bomb_plant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("growable")
    inst.components.growable.growoffscreen = true
    inst.components.growable.stages = GetGrowthStages(inst)
    inst.components.growable:SetStage(1)
    inst.components.growable.loopstages = false
    inst.components.growable:StartGrowing()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"sdf_pumpkin_bomb_seeds"})

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "sdf_pumpkin_bomb"
    inst.components.childspawner.spawnradius = 0
    inst.components.childspawner:StopSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(OnSpawned)
    inst.components.childspawner:SetOnChildKilledFn(OnChildKilled)

    inst.components.childspawner:SetRegenPeriod(TUNING.SDF_PUMPKIN_BOMB_PLANT_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SDF_PUMPKIN_BOMB_PLANT_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.SDF_PUMPKIN_BOMB_PLANT_MAX_SPAWN)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SDF_PUMPKIN_BOMB_PLANT_RELEASE_TIME, true)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SDF_PUMPKIN_BOMB_PLANT_REGEN_TIME, true)

    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("colouradder")

    inst.smashed = false
    inst.dayspawn = true

    inst:AddComponent("hauntable")
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY

    inst:ListenForEvent("onignite", onignite)
    inst.incineratesound = SOUND_TORMENTED_SCREAM

    inst.task = inst:DoTaskInTime(0, OnInit)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("sdf_pumpkin_bomb_plant", fn, assets, prefabs)
