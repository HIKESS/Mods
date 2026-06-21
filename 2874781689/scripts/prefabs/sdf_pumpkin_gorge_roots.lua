local assets=
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_roots.zip"),
}

prefabs = {
}


local function setrootstype(inst, typeid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid

	if inst.typeid == 0 then
	    inst.AnimState:SetBank("sdf_pumpkin_gorge_roots_1")
	else
	    inst.AnimState:SetBank("sdf_pumpkin_gorge_roots_"..inst.typeid.."")
	end
    end
end

local function onload(inst, data, newents)
    if data ~= nil and data.typeid ~= nil then
        setrootstype(inst, data.typeid)
    end
end

local function onsave(inst, data)
    data.typeid = inst.typeid
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.25)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_roots_1")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_roots")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst.typeid = 0
    setrootstype(inst, inst.typeid)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_pumpkin_gorge_roots", fn, assets)