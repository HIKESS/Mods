local assets=
{
    Asset("ANIM", "anim/sdf_chest_maze.zip"),

    Asset("ATLAS", "images/map_icons/sdf_chest_maze_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chest_maze_mm.tex"),
}

prefabs = {
}


local function makebarrenfn(inst)
    if inst.components.workable then
	inst:RemoveComponent("workable")
    end

    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("removed", true)

    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(x,_,z)
    inst:DoTaskInTime(0.5, function()
	inst.components.lootdropper:DropLoot()
    end)
    inst:DoTaskInTime(0.7, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("maxwell_smoke").Transform:SetPosition(x,_,z)
    end)

    inst:DoTaskInTime(2.5, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("dirt_puff").Transform:SetPosition(x,_,z)
	inst:Remove()
    end)
end

local function onpickedfn(inst, picker)
    if inst.components.pickable ~= nil then
	inst.Physics:SetActive(false)
	inst.components.pickable:MakeBarren()
    end
end


local function onhammered(inst, worker)
    inst.Physics:SetActive(false)
    inst.components.pickable:MakeBarren()
end

local function onsave(inst, data)
    data.lootchest = inst.lootchest
end

local function onload(inst, data)
    if data ~= nil and data.lootchest ~= nil then
        inst.lootchest = data.lootchest
	inst.components.lootdropper:SetLoot(inst.lootchest)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_maze_mm.tex")

    inst.AnimState:SetBank("sdf_chest_maze")
    inst.AnimState:SetBuild("sdf_chest_maze")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("soulless")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.lootchest = {"goldnugget"}

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(inst.lootchest)

    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("", 0, 0)
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.jostlepick = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)


    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return  Prefab("sdf_chest_riddle", fn, assets)