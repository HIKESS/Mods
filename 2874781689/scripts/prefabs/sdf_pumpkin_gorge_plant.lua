local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_plant.zip"),
}

local prefabs =
{

}

local builds =
{
    sdf_pumpkin_gorge_plant = {
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
	    inst.components.growable:SetStage(1)
	    if TheWorld.state.isday and not TheWorld.state.iswinter then
		inst.components.growable:StartGrowing()
	    end
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

    SetSmashed(inst)

    local rotAmountMin = 1
    local rotAmountMax = inst.components.growable:GetStage() - 3
    if rotAmountMax <= 0 then
	rotAmountMax = 1
    end
    local rotAmount = math.random(rotAmountMin, rotAmountMax)

    inst:DoTaskInTime(0.1,function()
	local x, y, z = inst.Transform:GetWorldPosition()
	y = 1.5

	local angle
	if worker ~= nil and worker:IsValid() then
	    angle = 180 - worker:GetAngleToPoint(x, 0, z)
	else
	    local down = TheCamera:GetDownVec()
	    angle = math.atan2(down.z, down.x) / DEGREES
	end

	for k = 1, (rotAmount) do
	    local rot = SpawnPrefab("spoiled_food")
	    rot.Transform:SetPosition(x, y, z)
	    launchitem(rot, angle)
	end
    end)
end

local function OnBurnt(inst, immediate)
    if inst.components.growable:GetStage() > 2 then
	local x,_,z=inst.Transform:GetWorldPosition()
	local s = 1.5 --1.5
	local pumpkinDeathFX = SpawnPrefab("pumpkincarving_shatter_fx")
	pumpkinDeathFX.Transform:SetPosition(x,_,z)
	pumpkinDeathFX.Transform:SetScale(s,s,s)
	local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
	pumpkinDeath2FX.Transform:SetPosition(x,_,z)

	local rotAmountMin = 1
	local rotAmountMax = inst.components.growable:GetStage() - 2
	if rotAmountMax <= 0 then
	    rotAmountMax = 1
	end
	local rotAmount = math.random(rotAmountMin, rotAmountMax)

	inst:DoTaskInTime(0.1,function()
	    local x, y, z = inst.Transform:GetWorldPosition()
	    y = 1.5

	    local angle
	    local down = TheCamera:GetDownVec()
	    angle = math.atan2(down.z, down.x) / DEGREES

	    for k = 1, (rotAmount) do
		local rot = SpawnPrefab("spoiled_food")
		rot.Transform:SetPosition(x, y, z)
		launchitem(rot, angle)
	    end
	end)
    end
    SetSmashed(inst)
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

local function GrowSprout(inst)
    inst.AnimState:PlayAnimation("rot_to_sprout")
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

local function GrowRot(inst)
    inst.AnimState:PlayAnimation("grow_rot_oversized")
    inst.SoundEmitter:PlaySound("farming/common/farm/rot") --"dontstarve/farming/common/farm/rot")

    inst.AnimState:PushAnimation("crop_rot_oversized", true)
end

local function SetRot(inst)
    inst.AnimState:PlayAnimation("crop_rot_oversized", true)

    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 1.0 --1.0
    local pumpkinSpawnFX = SpawnPrefab("disease_puff")
    pumpkinSpawnFX.Transform:SetPosition(x,_,z)
    pumpkinSpawnFX.Transform:SetScale(s,s,s)

    --allow work
    AddAction(inst)

    --allow fire
    AddBurnable(inst)
end

local growth_stages = {}
for build, data in pairs(builds) do
    growth_stages[build] =
    {
        {
            name = "sprout",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.2, (TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.2) end,
            fn = SetSprout,
            growfn = GrowSprout,
        },
        {
            name = "small",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.3, (TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.3) end,
            fn = SetSmall,
            growfn = GrowSmall,
        },
        {
            name = "med",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.4, (TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.4) end,
            fn = SetMed,
            growfn = GrowMed,
        },
        {
            name = "full",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.5, (TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.5) end,
            fn = SetFull,
            growfn = GrowFull,
        },
        {
            name = "oversized",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.6, (TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.6) end,
            fn = SetOversized,
            growfn = GrowOversized,
        },
        {
            name = "rot",
            time = function(inst) return GetRandomMinMax((TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MIN*TUNING.TOTAL_DAY_TIME) * 0.5, (TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MAX*TUNING.TOTAL_DAY_TIME) * 0.5) end,
            fn = SetRot,
            growfn = GrowRot,
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

	if inst.smashed == false then

	    inst.components.growable:StartGrowing()
	end
    elseif inst.frozen == nil then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")
	inst.AnimState:Resume()

	if inst.smashed == false then
	    inst.components.growable:StartGrowing()
	end
    end
end

local function OnIsDay(inst, isday)
    if isday ~= inst.dayspawn then
	inst.components.growable:StopGrowing()
    elseif not TheWorld.state.iswinter then
	if inst.smashed == false then
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

local function OnHaunt(inst)
    if inst.smashed == false then
	inst.components.growable:DoGrowth(true)
    end
end

local function GetGrowthStages(inst)
    return growth_stages[inst.build] or growth_stages["sdf_pumpkin_gorge_plant"]
end

local function GetBuild(inst)
    return builds[inst.build] or builds["sdf_pumpkin_gorge_plant"]
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.15)

    inst.build = "sdf_pumpkin_gorge_plant"

    inst.scaleSmallRng = math.random()
    inst.scaleBigRng = math.random()
    if inst.scaleSmallRng > 0.2 then inst.scaleSmallRng = 0.2 end
    if inst.scaleBigRng > 0.2 then inst.scaleBigRng = 0.2 end
    inst.Transform:SetScale(0.6 + (inst.scaleSmallRng - inst.scaleBigRng), 0.6 + (inst.scaleSmallRng - inst.scaleBigRng), 0.6 + (inst.scaleSmallRng - inst.scaleBigRng))

    inst.AnimState:SetBuild(GetBuild(inst).build)
    inst.AnimState:SetBank(GetBuild(inst).bank)

    inst:AddTag("sdf_pumpkin_gorge_plant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("growable")
    inst.components.growable.stages = GetGrowthStages(inst)
    inst.components.growable:SetStage(math.random(1, 6))
    inst.components.growable.loopstages = true
    inst.components.growable:StartGrowing()

    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("colouradder")

    inst.smashed = false
    inst.dayspawn = true

    inst:AddComponent("hauntable")
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.task = inst:DoTaskInTime(0, OnInit)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("sdf_pumpkin_gorge_plant", fn, assets, prefabs)
