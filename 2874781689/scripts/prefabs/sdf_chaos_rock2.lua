local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_chaos_rock2_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chaos_rock2_mm.tex"),

    Asset("ANIM", "anim/sdf_chaos_rock2.zip"),
}

prefabs = {
}

local function setrocktype(inst, typeid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid
    end
end

local function onload(inst, data, newents)
    if data ~= nil and data.typeid ~= nil then
        setrocktype(inst, data.typeid)
    end
end

local function onsave(inst, data)
    data.typeid = inst.typeid
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chaos_rock2_mm.tex")

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("sdf_chaos_rock2")
    inst.AnimState:SetBuild("sdf_chaos_rock2")
    inst.AnimState:PlayAnimation("low")

    inst:AddTag("sdf_chaos_rock_engraft")
    inst:AddTag("sdf_chaos_rock2")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.typeid = 0
    setrocktype(inst, inst.typeid)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_chaos_rock2", fn, assets)