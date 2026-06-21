require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_moleworm.zip"),
}

local prefabs ={
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst.AnimState:SetBank("mole")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_moleworm")
    inst.AnimState:PlayAnimation("mound_idle", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("sdf_jack_of_the_green_riddle_moleworm_hill")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("sdf_jack_of_the_green_riddle_moleworm_hill", fn, assets, prefabs)
