local assets=
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_flower.zip"),
}

prefabs = {
}


local function setflowertype(inst, typeid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid

	--Setup Model
	if inst.typeid == 2 then
	    inst.AnimState:PlayAnimation("idle_0")
	    inst:AddTag("sdf_jack_of_the_green_flower_chest")
	else
	    inst.AnimState:PlayAnimation("idle_"..typeid.."")
	end
    end
end

local function onload(inst, data, newents)
    if data ~= nil and data.typeid ~= nil then
        setflowertype(inst, data.typeid)
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

     
    inst.AnimState:SetBank("sdf_jack_of_the_green_flower")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_flower")
    inst.AnimState:PlayAnimation("idle_0")
    inst.AnimState:SetRayTestOnBB(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.typeid = 0
    setflowertype(inst, inst.typeid)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_jack_of_the_green_flower", fn, assets)