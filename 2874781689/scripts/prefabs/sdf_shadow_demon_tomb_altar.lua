local assets =
{
    Asset("ANIM", "anim/sdf_shadow_demon_tomb_altar.zip"),
}

local prefabs =
{
}

local function OnSave(inst, data)
    data.typeid = inst.typeid
end

local function OnLoad(inst, data)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end
end

local function OnInit(inst)
    --if inst.typeid == 0 then
	--inst:Remove()
    --else
	inst.task = nil

	--spawn altarFX
	if inst.spawnedAltarFX == false then
	    inst.spawnedAltarFX = true
	    local altarFX = SpawnPrefab("sdf_shadow_demon_tomb_altarfx")
	    if altarFX ~= nil then
		local x,_,z=inst.Transform:GetWorldPosition()
		altarFX.Transform:SetPosition(x,_-2,z)
		altarFX.components.follower:SetLeader(inst)
		altarFX.typeid = 1
	    end
	end
    --end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1.3, 6) --1.5, 6
    inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("shelter")
    inst:AddTag("blocker")
    inst:AddTag("structure")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("nonpackable")
    inst:AddTag("sdf_shadow_demon_tomb_altar")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("leader")

    inst.typeid = 0
    inst.spawnedAltarFX = false

    inst.task = inst:DoTaskInTime(0, OnInit)

    --inst.OnSave = OnSave
    --inst.OnLoad = OnLoad

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    local s = 1.5 --0.8
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_shadow_demon_tomb_altar")
    inst.AnimState:SetBuild("sdf_shadow_demon_tomb_altar")
    inst.AnimState:PlayAnimation("idle_off")

    inst.DynamicShadow:SetSize(2, 2)

    inst:AddTag("sdf_shadow_demon_tomb_altarFX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("follower")

    inst.typeid = 0

    inst.persists = false
    --inst.task = inst:DoTaskInTime(0, OnInit)

    --inst.OnSave = OnSave
    --inst.OnLoad = OnLoad

    return inst
end

return Prefab("sdf_shadow_demon_tomb_altar", fn, assets, prefabs),
	Prefab("sdf_shadow_demon_tomb_altarfx", fn2, assets, prefabs)