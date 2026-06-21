local assets = {
    Asset("ANIM", "anim/sdf_professors_lab_projector.zip"),
}

local function makePowered(inst)
    if inst.prefab == "sdf_professors_lab_projector" then
	inst.AnimState:PlayAnimation("projector_on")
	inst._isPowered = true
    end
    if inst.prefab == "sdf_professors_lab_projector_screen" then
	inst.AnimState:PlayAnimation("screen_on")
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_ON)
	inst._isPowered = true
    end
end

local function makeUnpowered(inst)
    if inst.prefab == "sdf_professors_lab_projector" then
	inst.AnimState:PlayAnimation("projector_off")
	inst._isPowered = false
    end
    if inst.prefab == "sdf_professors_lab_projector_screen" then
	inst.AnimState:PlayAnimation("screen_off")
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_OFF)
	inst._isPowered = false
    end
end

local function setPowered(inst)
    if inst._isPowered == true then
	makePowered(inst)
    end
end

local function onsave(inst, data)
    data._isPowered = inst._isPowered
end

local function onload(inst, data)
    if data and data._isPowered ~= nil then
        inst._isPowered = data._isPowered
	setPowered(inst)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.AnimState:SetBank("sdf_professors_lab_projector")
    inst.AnimState:SetBuild("sdf_professors_lab_projector")
    inst.AnimState:PlayAnimation("projector_off")

    inst:AddTag("NOBLOCK")
    inst:AddTag("nonpackable")
    inst:AddTag("sdf_professors_lab_generator_powered")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst._isPowered = false
    inst.SdfProfessorsLabPoweredFn = function() makePowered(inst) end
    inst.SdfProfessorsLabUnpoweredFn = function() makeUnpowered(inst) end

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end


local function updateProjectorScreen(inst)
    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_OFF)
    --inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_ON)
end

local SCREEN_ON = false

local function talkingFX(inst)
    if inst.SCREEN_ON == true and inst._isPowered == true and inst.mapviewer ~= nil then

	--Get Chalice Altar Lock
	local altarLock = inst.mapviewer.components.sdf_chalice_id_lock:GetAltarLock()

	--make a list
	local activeChaliceAltars = {}
	for i, v in ipairs(altarLock) do
	    if v == false then
		table.insert(activeChaliceAltars, i)
	    end
	end

	--Make Chalice Altar Key
	local key = 0
	if next(activeChaliceAltars) == nil then
	else
	    key = activeChaliceAltars[math.random(#activeChaliceAltars)]
	end
	
	--check if continued reading map.
	if next(activeChaliceAltars) == nil then
	    inst.mapviewer.components.talker:Say(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_LOCATIONS[0], 6)
	    if inst.talkingtask ~= nil then
		inst.talkingtask:Cancel()
		inst.mapviewer = nil
		inst.mapcounter = 0
	    end
	elseif inst.mapcounter == 0 then
	    --Say a location of a Chalice Altar
	    inst.mapviewer.components.talker:Say(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_LOCATIONS[key], 6)
	    inst.mapcounter = 1
	    inst.talkingtask = inst:DoTaskInTime(math.random(10, 12), talkingFX)
	else
	    --Adding Continue
	    inst.mapviewer.components.talker:Say(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_CONTINUE[math.random(#STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_CONTINUE)], 6)

	    inst:DoTaskInTime(6, function()
		if inst.mapviewer ~= nil then
		    --Say a location of a Chalice Altar
		    inst.mapviewer.components.talker:Say(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_LOCATIONS[key], 6)

		    inst.talkingtask = inst:DoTaskInTime(math.random(10, 12), talkingFX)
		else
		    inst.talkingtask:Cancel()
		    inst.mapviewer = nil
		    inst.mapcounter = 0
		end
	    end)
	end
    elseif inst.talkingtask ~= nil then
	inst.talkingtask:Cancel()
	inst.mapviewer = nil
	inst.mapcounter = 0
    end
end

local function starttalking(inst)
    inst.talkingtask = inst:DoTaskInTime(math.random(10, 12), talkingFX)
end

local function screenturnoff(inst)
    if inst.SCREEN_ON == true then
	inst.SCREEN_ON = false
	inst.mapviewer = nil
	inst.mapcounter = 0
	if inst.talkingtask ~= nil then
	    inst.talkingtask:Cancel()
	end
    end
end

local function screenturnon(inst, player)
    if player.prefab == "sdf" and inst._isPowered == true then

	--screen on
	inst.SCREEN_ON = true
	inst.mapviewer = player

	--greet
	inst:DoTaskInTime(0.7,function()
	    if inst.talked == false and inst.mapviewer ~= nil then
		inst.mapviewer.components.talker:Say(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_GREETINGS[math.random(#STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PROJECTOR_SCREEN_GREETINGS)], 6)
		inst.talked = true
		inst:DoTaskInTime(20, function(inst)
		    inst.talked = false
		end)
	    end

	    if inst.SCREEN_ON == true then	
		inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst))
	    end
	end)
    end
end

local function fn2()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.Transform:SetScale(3.5, 3.5, 3.5)

    inst.AnimState:SetBank("sdf_professors_lab_projector")
    inst.AnimState:SetBuild("sdf_professors_lab_projector")
    inst.AnimState:PlayAnimation("screen_off")

    inst:AddTag("structure")
    inst:AddTag("prototyper")
    inst:AddTag("NOBLOCK")
    inst:AddTag("nonpackable")
    inst:AddTag("sdf_professors_lab_generator_powered")

    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(1, 1, 0, 0)
	inst.components.talker.offset = Vector3(0, 0, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2.3,2.5) --(2.1,2.3)
    inst.components.playerprox:SetOnPlayerNear(screenturnon)
    inst.components.playerprox:SetOnPlayerFar(screenturnoff)

    updateProjectorScreen(inst)

    inst._isPowered = false
    inst.SdfProfessorsLabPoweredFn = function() makePowered(inst) end
    inst.SdfProfessorsLabUnpoweredFn = function() makeUnpowered(inst) end

    inst.mapviewer = nil
    inst.mapcounter = 0
    inst.talked = false
    inst.talkingtask = nil

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function fn3()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.Transform:SetScale(3, 2.7, 3)

    inst.AnimState:SetBank("sdf_professors_lab_projector")
    inst.AnimState:SetBuild("sdf_professors_lab_projector")
    inst.AnimState:PlayAnimation("rail")

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("sdf_professors_lab_projector", fn, assets), Prefab("sdf_professors_lab_projector_screen", fn2, assets),
	Prefab("sdf_professors_lab_projector_rail", fn3, assets)