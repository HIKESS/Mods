local assets=
{
    Asset("ANIM", "anim/sdf_chest_maze.zip"),

    Asset("ATLAS", "images/map_icons/sdf_chest_maze_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chest_maze_mm.tex"),
}

prefabs = {
}

local sdf_chest_maze_loot ={
{"sdf_chicken_drumstick","sdf_chicken_drumstick"},
{"trinket_31"},
{"trinket_30"},
{"trinket_29"},
{"trinket_28"},
{"trinket_16"},
{"trinket_15"}
} --chicken drumstick, silver shield,
--black knight, white knight, black rook, white rook, black biship, white biship

local function makeLoot(inst, lootid)
    local loot = sdf_chest_maze_loot[math.random(#sdf_chest_maze_loot)]
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
	SpawnPrefab("green_leaves").Transform:SetPosition(x,_-1,z)
    end)

    inst:DoTaskInTime(2.5, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	--SpawnPrefab("dirt_puff").Transform:SetPosition(x,_,z)

	--SpawnPrefab("sdf_chest_maze_empty").Transform:SetPosition(x,_,z)

	local sdf_chest_maze = SpawnPrefab("sdf_chest_maze_empty")     
	sdf_chest_maze.Transform:SetPosition(x,_,z)
	if inst.lootid == 1 then
	    sdf_chest_maze.lootid = 1
	    --sdf_chest_maze.components.lootdropper:SetLoot({"sdf_silver_shield"})
	end

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

local function onload(inst, data)
    if data ~= nil and data.lootchest ~= nil then
        inst.lootchest = data.lootchest
	inst.components.lootdropper:SetLoot(inst.lootchest)
    end
    if data ~= nil and data.lootid ~= nil then
        inst.lootid = data.lootid
	if inst.lootid == 1 then
	    inst.components.lootdropper:SetLoot({"sdf_silver_shield"})
	end
    end
end

local function onsave(inst, data)
    data.lootid = inst.lootid
    data.lootchest = inst.lootchest
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_maze_mm.tex")

    inst.AnimState:SetBank("sdf_chest_maze")
    inst.AnimState:SetBuild("sdf_chest_maze")
    inst.AnimState:PlayAnimation("idle", true)

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("soulless")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.lootid = 0
    inst.lootchest = makeLoot(inst, inst.lootid)

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
	    local sdf_chest_maze = SpawnPrefab("sdf_chest_maze")
	    sdf_chest_maze.Transform:SetPosition(x,_,z)
	    if inst.lootid == 1 then
		sdf_chest_maze.lootid = 1
		sdf_chest_maze.components.lootdropper:SetLoot({"sdf_silver_shield"})
	    end
	    inst:Remove()
	end)
    else
	inst.components.sdf_chest_regeneration:SetRegenerationCount(regenerationCount + 1)
    end
end

local function onLoad(inst, data)
    if data ~= nil and data.lootid ~= nil then
        inst.lootid = data.lootid
    end
end

local function onSave(inst, data)
    data.lootid = inst.lootid
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_maze_mm.tex")

    inst.AnimState:SetBank("sdf_chest_maze")
    inst.AnimState:SetBuild("sdf_chest_maze")
    inst.AnimState:PlayAnimation("removed")

    --MakeObstaclePhysics(inst, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Maze Chest
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_CHEST_MAZE_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("cycles", on_day_change)

    inst.OnSave = onSave
    inst.OnLoad = onLoad

    return inst
end

return  Prefab("sdf_chest_maze", fn, assets),
	Prefab("sdf_chest_maze_empty", fn2, assets)