local assets =
{
    Asset("ANIM", "anim/sdf_rock.zip"),
    Asset("ATLAS", "images/map_icons/sdf_rock_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_rock_mm.tex"),
}


local prefabs = 
{

}

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt.x, pt.y, pt.z)

        if inst.showCloudFXwhenRemoved then
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(pt.x, pt.y, pt.z)
        end

	if not inst.doNotRemoveOnWorkDone then
	    inst:Remove()
	end
    else
	inst.components.workable:SetWorkLeft(1000)
    end
end

local function setrocktype(inst, typeid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid

	--Setup Model
	inst.AnimState:PlayAnimation(typeid)
    else
	--Setup Model
	inst.AnimState:PlayAnimation(typeid)
    end
end

local function onload(inst, data)
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
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_rock_mm.tex")

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("sdf_rock")
    inst.AnimState:SetBuild("sdf_rock")

    MakeSnowCoveredPristine(inst)

    inst:AddTag("boulder")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(1000)
    inst.components.workable:SetOnWorkCallback(OnWork)

    inst.typeid = "full"
    setrocktype(inst, inst.typeid)

    inst:AddComponent("inspectable")

    MakeSnowCovered(inst)

    MakeHauntableWork(inst)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end


return Prefab("sdf_rock", fn, assets, prefabs)