require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well.zip"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gorge_well_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gorge_well_mm.xml"),
}

local prefabs =
{
    "collapse_small", 
    "sdf_pumpkin_gorge_well_floor", 
    "sdf_pumpkin_gorge_well_door_exit", 
    "sdf_pumpkin_gorge_well_boundary", 
    "sdf_pumpkin_gorge_well_base"
}

local function CreateVine(inst)
    --spawn well vine
    if inst.spawnedVine == false then
	inst.spawnedVine = true
	local wellVine = SpawnPrefab("sdf_pumpkin_gorge_well_vine")
	if wellVine ~= nil then
	    wellVine.Transform:SetPosition(inst.Transform:GetWorldPosition())
	    wellVine.components.follower:SetLeader(inst)
	    wellVine.typeid = 1
	end
    end
end

local function KillVine(inst)
    local followerWellVine = inst.components.leader:GetFollowersByTag("sdf_pumpkin_gorge_well_vine")
    for i, v in ipairs(followerWellVine) do

	--find  well vine
	if v ~= nil then
	    inst.spawnedVine = false
	    v.sg:GoToState("death")
	end
    end
end

local function lqT(HGli, iy)
    if iy ~= nil and iy:HasTag("player") then
    end
end

local function mP3mlD(m6SCS0, NUhYw6R4)
    if NUhYw6R4:HasTag("player") then
    elseif m6SCS0.SoundEmitter ~= nil then
    end
end

local function onbuilt(inst, ownerid)
    if ownerid ~= nil and ownerid == 1 then
	return
    end

    if not TheWorld.components.sdf_pumpkin_gorge_well_limiter or TheWorld.components.sdf_pumpkin_gorge_well_limiter:IsMax() then
        return
    end

    local x, z = TheWorld.components.sdf_pumpkin_gorge_well_limiter:GetPosition()

    if not (x and z) then
        return
    end

    --Make Base
    local wellBase = SpawnPrefab("sdf_pumpkin_gorge_well_base")
    wellBase.Transform:SetPosition(x, 0, z)

    --Make Exit Door
    local exitDoor = SpawnPrefab("sdf_pumpkin_gorge_well_door_exit")
    exitDoor.Transform:SetPosition(x + 0.5, 0, z + 3.3) --0.2, 0, z + 3.5)

    --Make Floor
    local wellFloor = SpawnPrefab("sdf_pumpkin_gorge_well_floor")
    wellFloor.Transform:SetPosition(x - 6.8, 0, z)

    --Make Water
    local wellWater = SpawnPrefab("sdf_pumpkin_gorge_well_water")
    wellWater.Transform:SetPosition(x + 2, 0, z)

    --Make Wall
    local wellWall = SpawnPrefab("sdf_pumpkin_gorge_well_wall")
    wellWall.Transform:SetPosition(x, 0, z)

    --Make Player Boundary
    exitDoor.components.sdf_pumpkin_gorge_well_teleporter:Target(inst)
    inst.components.sdf_pumpkin_gorge_well_teleporter:Target(exitDoor)
    local function createBoundary(x, z)
        local playerBoundary = SpawnPrefab("sdf_pumpkin_gorge_well_boundary")
        if playerBoundary ~= nil then
            playerBoundary.Physics:SetCollides(false)
            playerBoundary.Physics:Teleport(x, 0, z)
            playerBoundary.Physics:SetCollides(true)
        end
    end

    --top
    createBoundary(x - 1, z - 3)
    createBoundary(x - 1.5, z - 2) --main
    createBoundary(x - 2, z - 1.25)
    createBoundary(x - 3, z - 1.25)
    createBoundary(x - 4, z - 1.25)
    createBoundary(x - 4.5, z - 1.25)
    createBoundary(x - 5, z) --main
    createBoundary(x - 4.5, z + 1.25)
    createBoundary(x - 4, z + 1.25)
    createBoundary(x - 3, z + 1.25)
    createBoundary(x - 2, z + 1.25)
    createBoundary(x - 1.5, z + 2) --main
    createBoundary(x - 1, z + 3)

    --bottom
    createBoundary(x + 5, z - 3)
    createBoundary(x + 5.5, z - 2)
    createBoundary(x + 6, z - 1)
    createBoundary(x + 6, z)
    createBoundary(x + 6, z + 1)
    createBoundary(x + 5.5, z + 2)
    createBoundary(x + 5, z + 3)

  --left
    createBoundary(x, z - 4)
    createBoundary(x + 1, z - 4.5)
    createBoundary(x + 2, z - 4.5)
    createBoundary(x + 3, z - 4.5)
    createBoundary(x + 4, z - 4)

   --right
    createBoundary(x, z + 4)
    createBoundary(x + 1, z + 4.5)
    createBoundary(x + 2, z + 4.5)
    createBoundary(x + 3, z + 4.5)
    createBoundary(x + 4, z + 4)

    --Decor
    local wellDecor1 = SpawnPrefab("sdf_pumpkin_gorge_well_decor1")
    wellDecor1.Transform:SetPosition(x - 8, 0, z - 1.7)

    local wellDecor2 = SpawnPrefab("sdf_pumpkin_gorge_well_decor2")
    wellDecor2.Transform:SetPosition(x - 0.6, 0, z - 3)

    local wellDecor3 = SpawnPrefab("sdf_pumpkin_gorge_well_decor3")
    wellDecor3.Transform:SetPosition(x - 7.5, 0, z + 1.5)

    local wellDecor4 = SpawnPrefab("sdf_pumpkin_gorge_well_decor4")
    wellDecor4.Transform:SetPosition(x - 10.7, 0, z - 4.7)

    local wellDecor5 = SpawnPrefab("sdf_pumpkin_gorge_well_decor5")
    --wellDecor5.Transform:SetPosition(x + 6, 0, z)
    wellDecor5.Transform:SetPosition(x + 5.8, 0, z)

    local wellDecor6 = SpawnPrefab("sdf_pumpkin_gorge_well_decor6")
    wellDecor6.Transform:SetPosition(x + 4.4, 0, z - 2)

    local wellDecor7 = SpawnPrefab("sdf_pumpkin_gorge_well_decor7")
    wellDecor7.Transform:SetPosition(x + 4, 0, z + 3)

    --Make glowshroom light
    local glowshroom1 = SpawnPrefab("sdf_pumpkin_gorge_well_glowshroom1")
    glowshroom1.typeid = 1
    glowshroom1.Transform:SetPosition(x + 2.3, 0, z + 4.2)

    --Make glowshroom light 2
    local glowshroom2 = SpawnPrefab("sdf_pumpkin_gorge_well_glowshroom2")
    glowshroom2.typeid = 1
    glowshroom2.Transform:SetPosition(x - 0.5, 0, z - 3.5)

    --Add interaction Prefabs
    inst:DoTaskInTime(0.1,function(inst)
	local x,_,z=wellBase.Transform:GetWorldPosition() --x is upndown z is leftnright

	--Make Hidden Chest Life Bottle 1, Energy Vial, and loot
	local chest = SpawnPrefab("sdf_chest_lifebottle1")
	chest.Transform:SetPosition(x - 3.8,_,z)

	--Make Merchant Gargoyle
	local merchant = SpawnPrefab("sdf_pumpkin_gorge_well_merchant_gargoyle")
	merchant.Transform:SetPosition(x - 0.9,_,z + 2.4)

    end)

    TheWorld.components.sdf_pumpkin_gorge_well_limiter:BuildHouse()
    inst.ownerid = 1
end

local function qW0lRiD1(Ib4, fjV1G2, Do, _, TqYJ4)
    if Ib4:HasTag("player") then
        Ib4:ScreenFade(false)
        Ib4:DoTaskInTime(1,function()
	    Ib4:SnapCamera()
	    Ib4:ScreenFade(true, 0.5)
	end)
    end
    if Ib4.Transform ~= nil then
        Ib4.Transform:SetPosition(fjV1G2, Do, _)
    end
    if TqYJ4 then
        Ib4:DoTaskInTime(0.2,function(Ib4)
	    if Ib4 and Ib4:IsValid() and Ib4:HasTag("player") and Ib4.components.health ~= nil and not Ib4.components.health:IsDead() then
		Ib4.components.health:Kill()
	    end
	end)
    end
end

--[[local function setlabtype(inst, typeid, ownerid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid

	--Setup Professors Lab
	if typeid == 1 then
	    onbuilt(inst, ownerid)
	end
    end
end]]

local function OnSave(inst, data)
    data.typeid = inst.typeid
    data.ownerid = inst.ownerid
end

local function OnLoad(inst, data)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end

    if data and data.ownerid ~= nil then
        inst.ownerid = data.ownerid
    end
end

local function OnInit(inst)
    if inst.typeid == 0 then
	inst:Remove()
    else
	inst.task = nil
	onbuilt(inst, inst.ownerid)
    end
end

local function showOnMap(inst)
    if inst.icon == nil then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon:TrackEntity(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_pumpkin_gorge_well_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    MakeObstaclePhysics(inst, 1.5, 6) --1.5, 6
    inst.Physics:SetDontRemoveOnSleep(true)

    local s = 0.8 --0.8
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_pumpkin_gorge_well")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sdf_pumpkin_gorge_well_door")
    inst:AddTag("shelter")
    inst:AddTag("blocker")
    inst:AddTag("structure")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("nonpackable")
    inst:AddTag("sdf_pumpking_asset")
    inst:AddTag("sdf_pumpkin_gorge_well")

    if not TheNet:IsDedicated() then
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("leader")
    inst:AddComponent("follower")

    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

    inst:AddComponent("inspectable")

    inst:AddComponent("sdf_pumpkin_gorge_well_teleporter")
    inst.components.sdf_pumpkin_gorge_well_teleporter.onActivate = mP3mlD
    inst.components.sdf_pumpkin_gorge_well_teleporter.offset = 0
    inst.components.sdf_pumpkin_gorge_well_teleporter.travelcameratime = 1
    inst.components.sdf_pumpkin_gorge_well_teleporter.travelarrivetime = 0.5
    inst:ListenForEvent("doneteleporting", lqT)

    inst.icon = nil
    inst.typeid = 0
    inst.ownerid = 0

    inst.spawnedVine = false

    inst.CreateVine = CreateVine
    inst.KillVine = KillVine

    inst:ListenForEvent("onremove",function(inst)
	local RfsnisO, lvW2ga, T7RKP = inst.Transform:GetWorldPosition()
	if not RfsnisO then
	    for _L6Bs, SH in pairs(Ents) do
		if SH:HasTag("multiplayer_portal") then
		    RfsnisO, lvW2ga, T7RKP = SH.Transform:GetWorldPosition()
		end
	    end
	end
	if not RfsnisO then
	    RfsnisO, lvW2ga, T7RKP = 0, 0, 0
	end
	if inst.components.sdf_pumpkin_gorge_well_teleporter and inst.components.sdf_pumpkin_gorge_well_teleporter.targetTeleporter ~= nil then
	    local wU4wYbA9 = inst.components.sdf_pumpkin_gorge_well_teleporter.targetTeleporter
	    local fFeQcIM, JEHSHPh3, bb = wU4wYbA9.Transform:GetWorldPosition()
	    local o5e6fP = TheSim:FindEntities(fFeQcIM, 0, bb, 20, nil, {"INLIMBO"})
	    for iq7ol, eMV in ipairs(o5e6fP) do
		if eMV:HasTag("player") or eMV:HasTag("irreplaceable") or eMV.components.health ~= nil then
		    qW0lRiD1(eMV, RfsnisO, lvW2ga, T7RKP, true)
		elseif eMV.components.workable ~= nil then
		    eMV.components.workable:Destroy(eMV)
		elseif eMV.components.perishable ~= nil then
		    eMV.components.perishable:LongUpdate(10000)
		elseif eMV.components.finiteuses ~= nil then
		    eMV.components.finiteuses:Use(10000)
		elseif eMV.components.fueled ~= nil then
		    eMV.components.fueled:DoUpdate(10000)
		end
	    end
	    TheWorld:DoTaskInTime(0.5,function(WDTNkTD)
		local Oejsws = TheSim:FindEntities(fFeQcIM, 0, bb, 20)
		for CkD73N0, PlwhaRKJ in ipairs(Oejsws) do
		    if PlwhaRKJ and PlwhaRKJ.components.inventoryitem ~= nil then
			qW0lRiD1(PlwhaRKJ, RfsnisO, lvW2ga, T7RKP)
		    else
			PlwhaRKJ:Remove()
		    end
		end
	    end)
	end
    end)

    inst.task = inst:DoTaskInTime(0, OnInit)
    inst:DoTaskInTime(0, showOnMap)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return  Prefab("sdf_pumpkin_gorge_well", fn, assets, prefabs)