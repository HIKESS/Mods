local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_chaos_rock_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chaos_rock_mm.tex"),

    Asset("ANIM", "anim/sdf_chaos_rock.zip"),
}

prefabs = {
}

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt.x, pt.y, pt.z)

	--create Chaos Rock2
        local chaosRock2 = SpawnPrefab("sdf_chaos_rock2")
	chaosRock2.Transform:SetPosition(inst.Transform:GetWorldPosition())

	--Remove
	inst:Remove()
    else
        inst.AnimState:PlayAnimation(
            (workleft < TUNING.SDF_CHAOS_ROCK_MINE / 3 and "low") or
            (workleft < TUNING.SDF_CHAOS_ROCK_MINE * 2 / 3 and "med") or
            "full"
        )
    end
end

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

    inst.MiniMapEntity:SetIcon("sdf_chaos_rock_mm.tex")

    local s = 0.8
    inst.Transform:SetScale(s,s,s)

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("sdf_chaos_rock")
    inst.AnimState:SetBuild("sdf_chaos_rock")
    inst.AnimState:PlayAnimation("full")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.typeid = 0
    setrocktype(inst, inst.typeid)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.SDF_CHAOS_ROCK_MINE)
    inst.components.workable:SetOnWorkCallback(OnWork)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_chaos_rock", fn, assets)