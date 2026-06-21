require "prefabutil"

local assets =
{
    Asset("ATLAS", "images/map_icons/sdf_professors_lab_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_professors_lab_mm.tex"),

    Asset("ANIM", "anim/sdf_professors_lab.zip"), 
}

local prefabs = {
	"collapse_small", 
	"sdf_professors_lab_floor", 
	"sdf_professors_lab_door_exit", 
	"sdf_professors_lab_boundary", 
	"sdf_professors_lab_base"
}


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
    --if ownerid ~= nil and ownerid == 1 then
	--return
    --end

    if not TheWorld.components.sdf_professors_lab_limiter or TheWorld.components.sdf_professors_lab_limiter:IsMax() then
        return
    end

    local x, z = TheWorld.components.sdf_professors_lab_limiter:GetPosition()

    if not (x and z) then
        return
    end

    --Make Base
    local labBase = SpawnPrefab("sdf_professors_lab_base")
    labBase.Transform:SetPosition(x, 0, z)

    --Make Light
    local labLight = SpawnPrefab("sdf_professors_lab_light")
    labLight.Transform:SetPosition(x + 2.21, 0, z)

    --Make Exit Door
    local exitDoor = SpawnPrefab("sdf_professors_lab_door_exit")
    exitDoor.Transform:SetPosition(x + 7.5, 0 + 0.1, z)

    --Make Floor
    local labFloor = SpawnPrefab("sdf_professors_lab_floor")
    labFloor.Transform:SetPosition(x - 6.8, 0, z)

    --Make Wall
    local labWall = SpawnPrefab("sdf_professors_lab_wall")
    labWall.Transform:SetPosition(x, 0, z - 0.1)

    --Make Player Boundary
    exitDoor.components.sdf_professors_lab_teleporter:Target(inst)
    inst.components.sdf_professors_lab_teleporter:Target(exitDoor)
    local function createBoundary(x, z)
        local playerBoundary = SpawnPrefab("sdf_professors_lab_boundary")
        if playerBoundary ~= nil then
            playerBoundary.Physics:SetCollides(false)
            playerBoundary.Physics:Teleport(x, 0, z)
            playerBoundary.Physics:SetCollides(true)
        end
    end

    for u = -10, 10 do
        createBoundary(x - 6.8, z + u)
    end

    for Ki1 = -12, 11 do
        createBoundary(x + 8.3, z + Ki1)
    end

    local K = 0
    for zz1QI = -6.2, 6.8 do
        createBoundary(x + zz1QI, z - 11 - K)
        K = K + 0.11
    end

    local qL = 0
    for kFTAh = -6.2, 6.8 do
        createBoundary(x + kFTAh, z + 11 + qL)
        qL = qL + 0.09
    end

    --Make Wall Pillars
    local wallPillar1 = SpawnPrefab("sdf_professors_lab_wall_pillar")
    wallPillar1.Transform:SetPosition(x + 7.53, 0, z - 11.53) --12.07

    local wallPillar2 = SpawnPrefab("sdf_professors_lab_wall_pillar")
    wallPillar2.Transform:SetPosition(x + 7.53, 0, z + 11.23) --11.77
    wallPillar2.AnimState:SetScale(-1, 1, 1)
    wallPillar2.eastside = true

    local wallPillar3 = SpawnPrefab("sdf_professors_lab_wall_pillar_in")
    wallPillar3.Transform:SetPosition(x - 5.83, 0 + 0.4, z - 9.2) --10.34

    local wallPillar4 = SpawnPrefab("sdf_professors_lab_wall_pillar_in")
    wallPillar4.Transform:SetPosition(x - 5.83, 0 + 0.4, z + 9.03) --9.77
    wallPillar4.AnimState:SetScale(-1, 1, 1)
    wallPillar4.eastside = true

    --Add interaction Prefabs
    inst:DoTaskInTime(0.1,function(inst)
	local x,_,z=labBase.Transform:GetWorldPosition() --x is upndown z is leftnright

	--Make Trackend
	local trackend = SpawnPrefab("sdf_professors_lab_trackend")
	trackend.Transform:SetPosition(x +5.5,_,z)

	--Make Generator
	local generator = SpawnPrefab("sdf_professors_lab_generator")
	generator.Transform:SetPosition(x +7.3,_,z -5.5)

	--Make Tesla
	local tesla = SpawnPrefab("sdf_professors_lab_tesla")
	tesla.Transform:SetPosition(x +7,_,z +5.5)

	--Make Projector
	local projector = SpawnPrefab("sdf_professors_lab_projector")
	projector.Transform:SetPosition(x +0.2,_,z -8.2)

	--Make Projector Screen
	local projectorscreen = SpawnPrefab("sdf_professors_lab_projector_screen")
	projectorscreen.Transform:SetPosition (x -0.8,_,z -11.6) --(x -1.9,_,z -13.2)

	--Make Projector Rail
	local projectorrail1 = SpawnPrefab("sdf_professors_lab_projector_rail")
	projectorrail1.Transform:SetPosition(x +2.1,_,z -10.2)

	local projectorrail2 = SpawnPrefab("sdf_professors_lab_projector_rail")
	projectorrail2.Transform:SetPosition(x -2.7,_,z -9.7)

	--Make chem lab
	local labend = SpawnPrefab("madscience_lab")
	labend.Transform:SetPosition(x -4,_,z +8)
    end)

    TheWorld.components.sdf_professors_lab_limiter:BuildHouse()
    inst._ownerid = 1

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

local function setlabtype(inst, typeid, ownerid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid

	--Setup Professors Lab
	if typeid == 1 then
	    onbuilt(inst, ownerid)
	end
    end
end

local function onsave(inst, data)
    data._ownerid = inst._ownerid or nil
    data.typeid = inst.typeid
end

local function onload(inst, data)
    if data and data._ownerid ~= nil then
        inst._ownerid = data._ownerid

	if data ~= nil and data.typeid ~= nil then
            setlabtype(inst, data.typeid, inst._ownerid)
	end
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

    inst.MiniMapEntity:SetIcon("sdf_professors_lab_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst.AnimState:SetBank("sdf_professors_lab")
    inst.AnimState:SetBuild("sdf_professors_lab")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sdf_professors_lab_door")
    inst:AddTag("shelter")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("nonpackable")

   --MakeSnowCoveredPristine(inst)

    if not TheNet:IsDedicated() then
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

    inst:AddComponent("inspectable")

    inst:AddComponent("sdf_professors_lab_teleporter")
    inst.components.sdf_professors_lab_teleporter.onActivate = mP3mlD
    inst.components.sdf_professors_lab_teleporter.offset = 0
    inst.components.sdf_professors_lab_teleporter.travelcameratime = 1
    inst.components.sdf_professors_lab_teleporter.travelarrivetime = 0.5
    inst:ListenForEvent("doneteleporting", lqT)

    inst.typeid = 0
    --setlabtype(inst, inst.typeid)
    onbuilt(inst, inst.typeid)

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
	if inst.components.sdf_professors_lab_teleporter and inst.components.sdf_professors_lab_teleporter.targetTeleporter ~= nil then
	    local wU4wYbA9 = inst.components.sdf_professors_lab_teleporter.targetTeleporter
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

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.icon = nil
    inst:DoTaskInTime(0, showOnMap)

    return inst
end

return Prefab("sdf_professors_lab", fn, assets, prefabs)