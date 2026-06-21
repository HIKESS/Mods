local assets =
{
    --Asset("ATLAS", "images/map_icons/sdf_haunted_ruins_lava_pond_mm.xml"),
    --Asset("IMAGE", "images/map_icons/sdf_haunted_ruins_lava_pond_mm.tex"),

    Asset("ANIM", "anim/sdf_haunted_ruins_throne.zip"),
}

prefabs = {
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    --inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    --inst.MiniMapEntity:SetIcon("sdf_haunted_ruins_lava_pond_mm.tex")
    --inst.MiniMapEntity:SetPriority(1)

    inst:SetDeploySmartRadius(0.875) --recipe min_spacing/2
    MakeObstaclePhysics(inst, 0.25)

    inst.Transform:SetFourFaced()

    local s = 1.4 --1.4
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBuild("sdf_haunted_ruins_throne")
    inst.AnimState:SetBank("sdf_haunted_ruins_throne")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:Hide("back_over")

    inst:AddTag("structure")
    inst:AddTag("faced_chair")
    inst:AddTag("rotatableobject")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("sittable")

    inst:AddComponent("savedrotation")
    inst.components.savedrotation.dodelayedpostpassapply = true

    return inst
end

return  Prefab("sdf_haunted_ruins_throne", fn, assets, prefabs)