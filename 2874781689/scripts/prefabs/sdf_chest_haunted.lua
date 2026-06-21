local assets=
{
    Asset("ANIM", "anim/sdf_chest_haunted.zip"),

    Asset("ATLAS", "images/map_icons/sdf_chest_haunted_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chest_haunted_mm.tex"),
}

prefabs = {
}

local sdf_chest_loot ={"sdf_energyvial"}
--sdf_energyvial

local player_chest_loot ={"bandage"}
--bandage

local function makeLoot(inst)
    local loot = sdf_chest_loot
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

	--Create Loot
	if inst.ActivePlayer ~= nil then
	    if inst.ActivePlayer.prefab ~= "sdf" then
		inst.lootchest = player_chest_loot
		inst.components.lootdropper:SetLoot(inst.lootchest)
	    end
	end
	inst.components.lootdropper:DropLoot()
    end)
    inst:DoTaskInTime(0.7, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("maxwell_smoke").Transform:SetPosition(x,_,z)
	SpawnPrefab("green_leaves").Transform:SetPosition(x,_-1,z)
    end)

    inst:DoTaskInTime(2.5, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	--SpawnPrefab("dirt_puff").Transform:SetPosition(x,_,z)

	SpawnPrefab("sdf_chest_haunted_empty").Transform:SetPosition(x,_,z)
	inst:Remove()
    end)
end

local function onpickedfn(inst, picker)
    if inst.components.pickable ~= nil then
	inst.Physics:SetActive(false)
	inst.ActivePlayer = picker
	inst.components.pickable:MakeBarren()
    end
end


local function onhammered(inst, worker)
    inst.Physics:SetActive(false)
    inst.ActivePlayer = worker
    inst.components.pickable:MakeBarren()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_haunted_mm.tex")

    inst.AnimState:SetBank("sdf_chest_haunted")
    inst.AnimState:SetBuild("sdf_chest_haunted")
    inst.AnimState:PlayAnimation("idle", true)

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("soulless")

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

    inst.ActivePlayer = nil

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
	     SpawnPrefab("sdf_chest_haunted").Transform:SetPosition(x,_,z)
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

    inst.MiniMapEntity:SetIcon("sdf_chest_haunted_mm.tex")

    inst.AnimState:SetBank("sdf_chest_haunted")
    inst.AnimState:SetBuild("sdf_chest_haunted")
    inst.AnimState:PlayAnimation("removed")

    --MakeObstaclePhysics(inst, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Haunted Chest
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_CHEST_HAUNTED_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("cycles", on_day_change)

    return inst
end

return  Prefab("sdf_chest_haunted", fn, assets),
	Prefab("sdf_chest_haunted_empty", fn2, assets)