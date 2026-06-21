local assets=
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_vase.zip"),
}

prefabs = {
}

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(1.3,2.8,1.3)

    inst.AnimState:SetBank("sdf_jack_of_the_green_vase")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_vase")
    inst.AnimState:PlayAnimation("idle")

    MakeObstaclePhysics(inst, .1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return  Prefab("sdf_jack_of_the_green_vase", fn, assets)