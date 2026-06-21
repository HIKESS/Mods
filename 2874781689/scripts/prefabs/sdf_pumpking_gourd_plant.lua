local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_plant.zip"),
}

local prefabs =
{

}

local builds =
{
    sdf_pumpking_gourd_plant = {
        build = "sdf_pumpkin_gorge_plant",
        bank = "sdf_pumpkin_gorge_plant",
    },
}

local function SetSmashed(inst)
    inst.smashed = true

    inst.AnimState:PlayAnimation("crop_rot", true)
    inst.components.growable:StopGrowing()

    --disable work
    if inst.components.workable then
	inst:RemoveComponent("workable")
    end

    --disable burnable
    if inst.components.burnable then
	inst:RemoveComponent("burnable")
    end

    inst:DoTaskInTime(GetRandomWithVariance(30, 60), function()
	inst.smashed = false
	inst.AnimState:PlayAnimation("rot_to_sprout")

	inst:DoTaskInTime(1, function()
	    inst.components.growable:SetStage(2)
	    inst.components.growable:StartGrowing()
	end)
    end)
end

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
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

	inst:DoTaskInTime(0.1,function()
	    inst:Remove()
	end)
    end

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

	    inst:DoTaskInTime(0.1,function()
		inst:Remove()
	    end)
	else
	    SetSmashed(inst)
	end
    else
	SetSmashed(inst)
    end
end

local function AddAction(inst)
    --allow work
    if not inst.components.workable then
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)
    end
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

    --disable work
    RemoveAction(inst)

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

    --disable work
    RemoveAction(inst)

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
    AddAction(inst)

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
    AddAction(inst)

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
    AddAction(inst)

    --allow fire
    AddBurnable(inst)
end

local function GrowHarvest(inst)
    inst.AnimState:PlayAnimation("dug")
end

local function SetHarvest(inst)
    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 1.5 --1.5
    local pumpkinSpawnFX = SpawnPrefab("disease_puff")
    pumpkinSpawnFX.Transform:SetPosition(x,_,z)
    pumpkinSpawnFX.Transform:SetScale(s,s,s)

    local pumpkingGourd = SpawnPrefab("sdf_pumpking_gourd")
    if pumpkingGourd ~= nil then
	pumpkingGourd.Transform:SetPosition(inst.Transform:GetWorldPosition())
	pumpkingGourd.persists = false
    end

    inst:Remove()
end

local growth_stages = {}
for build, data in pairs(builds) do
    growth_stages[build] =
    {
        {
            name = "seed",
            time = function(inst) return TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME end,
            fn = SetSeed,
            growfn = GrowSeed,
        },
        {
            name = "sprout",
            time = function(inst) return TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME end,
            fn = SetSprout,
            growfn = GrowSprout,
        },
        {
            name = "small",
            time = function(inst) return TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME end,
            fn = SetSmall,
            growfn = GrowSmall,
        },
        {
            name = "med",
            time = function(inst) return TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME end,
            fn = SetMed,
            growfn = GrowMed,
        },
        {
            name = "full",
            time = function(inst) return TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME end,
            fn = SetFull,
            growfn = GrowFull,
        },
        {
            name = "oversized",
            time = function(inst) return TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME end,
            fn = SetOversized,
            growfn = GrowOversized,
        },
        {
            name = "harvest",
            time = function(inst) return TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME end,
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
end

local function OnInit(inst)
    inst.task = nil
end

local function GetGrowthStages(inst)
    return growth_stages[inst.build] or growth_stages["sdf_pumpking_gourd_plant"]
end

local function GetBuild(inst)
    return builds[inst.build] or builds["sdf_pumpking_gourd_plant"]
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2)
    inst:SetPhysicsRadiusOverride(.25)
    MakeObstaclePhysics(inst, 0.25)

    inst.build = "sdf_pumpking_gourd_plant"

    local scale = 0.7
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBuild(GetBuild(inst).build)
    inst.AnimState:SetBank(GetBuild(inst).bank)

    inst:AddTag("sdf_pumpking_gourd_plant")

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

    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("entitytracker")

    inst.smashed = false
    inst.persists = false

    MakeHauntableIgnite(inst)

    inst.task = inst:DoTaskInTime(0, OnInit)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("sdf_pumpking_gourd_plant", fn, assets, prefabs)
