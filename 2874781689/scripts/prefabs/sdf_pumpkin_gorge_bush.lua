local assets=
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_bush.zip"),
}


local prefabs =
{

}

local function makeobstacle(inst)
    inst.bushGrowth = true
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)

    if inst.components.workable then
	inst.components.workable:SetWorkLeft(10)
    end

    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
    inst.bushGrowth = false

    inst.AnimState:PlayAnimation("disappear")
    inst.AnimState:PushAnimation("empty")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/fall/leaf_rustle")

    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)

    inst.regrowthtask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_GORGE_BUSH_GROWTH_TIME, makeobstacle)
end

local function OnBurnt(inst, immediate)
    inst.bushGrowth = false

    if inst:HasTag("burnt") then
	inst.AnimState:PlayAnimation("idle_dead")
    else
	inst:AddTag("burnt")
	inst.AnimState:PlayAnimation("burnt")
	inst.AnimState:PushAnimation("idle_dead")
    end

    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)

    inst.regrowthtask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_GORGE_BUSH_GROWTH_TIME, makeobstacle)
end

local function OnIsPathFindingDirty(inst)
    if inst:GetCurrentPlatform() == nil then
        local wall_x, wall_y, wall_z = inst.Transform:GetWorldPosition()
        if inst._ispathfinding:value() then
            if inst._pfpos == nil then
                inst._pfpos = Point(wall_x, wall_y, wall_z)
                TheWorld.Pathfinder:AddWall(wall_x, wall_y, wall_z)
            end
        elseif inst._pfpos ~= nil then
            TheWorld.Pathfinder:RemoveWall(wall_x, wall_y, wall_z)
            inst._pfpos = nil
        end
    end
end


local function workcallback(inst, worker, workleft)
    if not (worker ~= nil and worker:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_mushroom")
    end
    if workleft > 0 then
        inst.AnimState:PlayAnimation("chop")
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function workfinishcallback(inst)--, worker)
    clearobstacle(inst)
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function setbushgrowth(inst, bushgrowth)
    bushgrowth = bushgrowth
    if bushgrowth ~= inst.bushGrowth then
        inst.bushGrowth = bushgrowth
    end

    if inst.bushGrowth == false then
	clearobstacle(inst)
    end
end

local function onload(inst, data)
    if data ~= nil and data.bushGrowth ~= nil then
        inst.bushGrowth = data.bushGrowth
	setbushgrowth(inst, inst.bushGrowth)
    end
end

local function onsave(inst, data)
    data.bushGrowth = inst.bushGrowth
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel > .02 then
        if not inst.frozen then
            inst.frozen = true
            if inst.regrowthtask ~= nil then
		inst.regrowthtask:Cancel()
		inst.regrowthtask = nil
	    end
        end
    elseif inst.frozen then
        inst.frozen = false
	setbushgrowth(inst, inst.bushGrowth)
    elseif inst.frozen == nil then
        inst.frozen = false
	setbushgrowth(inst, inst.bushGrowth)
    end
end

local function OnIsDay(inst, isday)
    if isday ~= inst.dayspawn then
	if inst.regrowthtask ~= nil then
	    inst.regrowthtask:Cancel()
	     inst.regrowthtask = nil
	end
    elseif not TheWorld.state.iswinter then
	setbushgrowth(inst, inst.bushGrowth)
    end
end
local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("isday", OnIsDay)
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnIsDay(inst, TheWorld.state.isday)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_bush")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_bush")
    inst.AnimState:PlayAnimation("idle",true)

    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddTag("sdf_pumpkin_gorge")
    inst:AddTag("plant")

    inst._pfpos = nil
    inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
    makeobstacle(inst)
    --Delay this because makeobstacle sets pathfinding on by default
    --but we don't to handle it until after our position is set
    inst:DoTaskInTime(0, InitializePathFinding)

    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst.bushGrowth = true
    setbushgrowth(inst, inst.bushGrowth)

    --inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(10)
    inst.components.workable:SetOnWorkCallback(workcallback)
    inst.components.workable:SetOnFinishCallback(workfinishcallback)

    MakeMediumBurnable(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    MakeSmallPropagator(inst)

    inst.dayspawn = true
    inst.regrowthtask = nil

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.task = inst:DoTaskInTime(0, OnInit)
    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return Prefab("sdf_pumpkin_gorge_bush", fn, assets, prefabs)
