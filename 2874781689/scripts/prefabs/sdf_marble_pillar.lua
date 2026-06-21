local assets =
{
    Asset("ATLAS", "images/map_icons/sdf_marble_pillar_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_marble_pillar_mm.tex"),

    Asset("ANIM", "anim/sdf_marble_pillar.zip"),
}

local prefabs ={
}

local function onworked(inst, worker, workleft)
    SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
    inst.components.workable:SetWorkLeft(1000)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_marble_pillar_mm.tex")

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("sdf_marble_pillar")
    inst.AnimState:SetBuild("sdf_marble_pillar")
    inst.AnimState:PlayAnimation("full")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("workable")

    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(1000)
    inst.components.workable:SetOnWorkCallback(onworked)

    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    return inst
end

return Prefab("sdf_marble_pillar", fn, assets, prefabs)