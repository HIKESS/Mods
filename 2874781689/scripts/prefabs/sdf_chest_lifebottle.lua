local assets=
{
    Asset("ANIM", "anim/sdf_chest_lifebottle.zip"),

    Asset("ATLAS", "images/map_icons/sdf_chest_lifebottle_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chest_lifebottle_mm.tex"),
}

prefabs = {
}

local pumpkin_gorge_sdf_chest_loot ={
{"pumpkinpie"},
{"sdf_energyvial","sdf_energyvial"}
} --random pumpkin goods

local pumpkin_gorge_player_chest_loot ={
{"pumpkincookie"},
{"bandage","bandage"}
} --random chess trinkets

local asylum_grounds_sdf_chest_loot ={
{"sdf_chicken_drumstick","sdf_chicken_drumstick"},
{"trinket_31"},
{"trinket_30"},
{"trinket_29"},
{"trinket_28"},
{"trinket_16"},
{"trinket_15"}
} --random chess trinkets, drumsticks

local function makePumpkinGorgeLoot(inst)
    local loot = pumpkin_gorge_sdf_chest_loot[math.random(#pumpkin_gorge_sdf_chest_loot)]
    return loot
end

local function makePumpkinGorgePlayerLoot(inst)
    local loot = pumpkin_gorge_player_chest_loot[math.random(#pumpkin_gorge_player_chest_loot)]
    return loot
end

local function makeAsylumGroundsLoot(inst)
    local loot = asylum_grounds_sdf_chest_loot[math.random(#asylum_grounds_sdf_chest_loot)]
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
	    if inst.ActivePlayer.prefab == "sdf" then
		if inst.ActivePlayer.components.sdf_lifebottle_holder:GetLifebottleFoundStatusPumpkinGorge() == false then
		    inst.ActivePlayer.components.sdf_lifebottle_holder:SetLifebottleFoundStatusPumpkinGorge()
		    inst.lootchest = {"sdf_lifebottle"}
		    inst.components.lootdropper:SetLoot(inst.lootchest)
		else
		    inst.lootchest = makePumpkinGorgeLoot(inst)
		    inst.components.lootdropper:SetLoot(inst.lootchest)
		end
	    else
		inst.lootchest = makePumpkinGorgePlayerLoot(inst)
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
	inst:Remove()

	SpawnPrefab("sdf_chest_lifebottle1_empty").Transform:SetPosition(x,_,z)

    end)
end

local function makebarrenfn3(inst)
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
	    if inst.ActivePlayer.prefab == "sdf" then
		if inst.ActivePlayer.components.sdf_lifebottle_holder:GetLifebottleFoundStatusAsylumGrounds() == false then
		    inst.ActivePlayer.components.sdf_lifebottle_holder:SetLifebottleFoundStatusAsylumGrounds()
		    inst.lootchest = {"sdf_lifebottle"}
		    inst.components.lootdropper:SetLoot(inst.lootchest)
		else
		    inst.lootchest = makeAsylumGroundsLoot(inst)
		    inst.components.lootdropper:SetLoot(inst.lootchest)
		end
	    else
		inst.lootchest = makeAsylumGroundsLoot(inst)
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

	SpawnPrefab("sdf_chest_lifebottle2_empty").Transform:SetPosition(x,_,z)
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

local function onload(inst, data)
    if data ~= nil and data.lootchest ~= nil then
        inst.lootchest = data.lootchest
	inst.components.lootdropper:SetLoot(inst.lootchest)
    end
end

local function onsave(inst, data)
    data.lootchest = inst.lootchest
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_lifebottle_mm.tex")

    inst.AnimState:SetBank("sdf_chest_lifebottle")
    inst.AnimState:SetBuild("sdf_chest_lifebottle")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("soulless")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.lootchest = makePumpkinGorgeLoot(inst)

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

    --inst.OnSave = onsave
    --inst.OnLoad = onload

    return inst
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_lifebottle_mm.tex")

    inst.AnimState:SetBank("sdf_chest_lifebottle")
    inst.AnimState:SetBuild("sdf_chest_lifebottle")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    MakeObstaclePhysics(inst, .5)

    inst:AddTag("soulless")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.lootchest = makeAsylumGroundsLoot(inst)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(inst.lootchest)

    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("", 0, 0)
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makebarrenfn = makebarrenfn3
    inst.components.pickable.jostlepick = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.ActivePlayer = nil

    --inst.OnSave = onsave
    --inst.OnLoad = onload

    return inst
end

local function on_day_changefn(inst)
    local regenerationCount = inst.components.sdf_chest_regeneration:GetRegenerationCount()
    local regenerationCountMax = inst.components.sdf_chest_regeneration:GetMaxRegenerationCount()

    if regenerationCount >= regenerationCountMax then
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("halloween_moonpuff").Transform:SetPosition(x,_,z)
	inst:DoTaskInTime(0.5, function()
	    local x,_,z = inst.Transform:GetWorldPosition()
	     SpawnPrefab("sdf_chest_lifebottle1").Transform:SetPosition(x,_,z)
	    inst:Remove()
	end)
    else
	inst.components.sdf_chest_regeneration:SetRegenerationCount(regenerationCount + 1)
    end
end

local function on_day_changefn4(inst)
    local regenerationCount = inst.components.sdf_chest_regeneration:GetRegenerationCount()
    local regenerationCountMax = inst.components.sdf_chest_regeneration:GetMaxRegenerationCount()

    if regenerationCount >= regenerationCountMax then
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("halloween_moonpuff").Transform:SetPosition(x,_,z)
	inst:DoTaskInTime(0.5, function()
	    local x,_,z = inst.Transform:GetWorldPosition()
	     SpawnPrefab("sdf_chest_lifebottle2").Transform:SetPosition(x,_,z)
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

    inst.MiniMapEntity:SetIcon("sdf_chest_lifebottle_mm.tex")

    inst.AnimState:SetBank("sdf_chest_lifebottle")
    inst.AnimState:SetBuild("sdf_chest_lifebottle")
    inst.AnimState:PlayAnimation("removed")

    --MakeObstaclePhysics(inst, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Lifebottle Chest
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_CHEST_LIFEBOTTLE_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("cycles", on_day_changefn)

    return inst
end

local function fn4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chest_lifebottle_mm.tex")

    inst.AnimState:SetBank("sdf_chest_lifebottle")
    inst.AnimState:SetBuild("sdf_chest_lifebottle")
    inst.AnimState:PlayAnimation("removed")

    --MakeObstaclePhysics(inst, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows regeneration of Obscusred Chest
    inst:AddComponent("sdf_chest_regeneration")
    inst.components.sdf_chest_regeneration:SetMaxRegenerationCount(TUNING.SDF_CHEST_LIFEBOTTLE_REGENERATION_DAY_MAX)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("cycles", on_day_changefn4)

    return inst
end

return  Prefab("sdf_chest_lifebottle1", fn, assets),
	Prefab("sdf_chest_lifebottle1_empty", fn2, assets),
	Prefab("sdf_chest_lifebottle2", fn3, assets),
	Prefab("sdf_chest_lifebottle2_empty", fn4, assets)