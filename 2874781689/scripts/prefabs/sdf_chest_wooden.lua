local assets=
{
    Asset("ANIM", "anim/sdf_chest_wooden.zip"),

    Asset("ATLAS", "images/map_icons/sdf_chest_wooden_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chest_wooden_mm.tex"),
}

prefabs = {
}

local sdf_chest_wooden_loot ={
{"sdf_club"},
{"sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers","sdf_throwing_daggers"},
{"sdf_copper_shield"}
} --club,throwing daggers,copper shield

local function makeLoot(inst)
    local rngLoot = math.random()
    local loot = sdf_chest_wooden_loot[math.random(#sdf_chest_wooden_loot)]
    if rngLoot > TUNING.SDF_CHEST_WOODEN_KUL_KATURA_CHANCE then
	loot = {"goldnugget"} --KUL_KATURA spawn
    end
    return loot
end

local function makebarrenfn(inst)
    if inst.components.workable then
	inst:RemoveComponent("workable")
    end

    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("removed", true)

    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("round_puff_fx_sm").Transform:SetPosition(x,_,z)
    inst:DoTaskInTime(0.5, function()
	inst.components.lootdropper:DropLoot()
    end)
    inst:DoTaskInTime(0.7, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("maxwell_smoke").Transform:SetPosition(x,_,z)
    end)

    inst:DoTaskInTime(2.5, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	--SpawnPrefab("dirt_puff").Transform:SetPosition(x,_,z)

	SpawnPrefab("sdf_chest_wooden_empty").Transform:SetPosition(x,_,z)
	inst:Remove()
    end)
end

local function onpickedfn(inst, picker)
    if inst.components.pickable ~= nil then
	inst.Physics:SetActive(false)
	inst.components.pickable:MakeBarren()
    end
end


local function onhammered(inst, worker)
    inst.Physics:SetActive(false)
    inst.components.pickable:MakeBarren()
end

local function onsave(inst, data)
    data.lootchest = inst.lootchest
end

local function onload(inst, data)
    if data ~= nil and data.lootchest ~= nil then
        inst.lootchest = data.lootchest
	inst.components.lootdropper:SetLoot(inst.lootchest)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_wooden_mm.tex")

    inst.AnimState:SetBank("sdf_chest_wooden")
    inst.AnimState:SetBuild("sdf_chest_wooden")
    inst.AnimState:PlayAnimation("idle", true)

    MakeObstaclePhysics(inst, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.lootchest = makeLoot(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(inst.lootchest)

    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("", 0, 0)
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.jostlepick = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function on_day_change(inst)
    local regenerationCount = inst.components.sdf_chest_regeneration:GetRegenerationCount()
    local regenerationCountMax = inst.components.sdf_chest_regeneration:GetMaxRegenerationCount()

    if regenerationCount >= regenerationCountMax then
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("halloween_moonpuff").Transform:SetPosition(x,_,z)
	inst:DoTaskInTime(0.5, function()
	    local x,_,z = inst.Transform:GetWorldPosition()
	     SpawnPrefab("sdf_chest_wooden").Transform:SetPosition(x,_,z)
	    inst:Remove()
	end)
    else
	inst.components.sdf_chest_regeneration:SetRegenerationCount(regenerationCount + 1)
    end
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_wooden_mm.tex")

    inst.AnimState:SetBank("sdf_chest_wooden")
    inst.AnimState:SetBuild("sdf_chest_wooden")
    inst.AnimState:PlayAnimation("removed")

    --MakeObstaclePhysics(inst, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Wooden Chest
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_CHEST_WOODEN_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("cycles", on_day_change)

    return inst
end

return  Prefab("sdf_chest_wooden", fn, assets),
	Prefab("sdf_chest_wooden_empty", fn2, assets)