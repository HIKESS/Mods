local assets =
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_koalefant.zip"),
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_koalefant_actions.zip"),
    Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs = {
}

local function checkSDFActiveTags(inst, sdf)
    if sdf:HasTag("sdf_riddle_1_active") then
	return 1
    elseif sdf:HasTag("sdf_riddle_2_active") then
	return 2
    elseif sdf:HasTag("sdf_riddle_3_active") then
	return 3
    elseif sdf:HasTag("sdf_riddle_4_active") then
	return 4
    end
	return 0
end

local function GetPoints(pt)
    local points = {}
    local radius = 0.5
    for i = 1, 2 do
        local theta = 0     
        local circ = 2*PI*radius
        local numPoints = math.ceil(circ * 0.25)
        for p = 1, numPoints do
            if not points[i] then
                points[i] = {}
            end
            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local point = pt + offset
            table.insert(points[i], point)
            theta = theta - (2*PI/numPoints)
        end
        radius = radius + 1.5
    end
    return points
end

local function aoeGroundPound(inst)
    local aoeRing = SpawnPrefab("groundpoundring_fx")
    aoeRing.Transform:SetPosition(inst.Transform:GetWorldPosition())
    aoeRing.Transform:SetScale(0.6,0.6,0.6)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
    local points = GetPoints(inst:GetPosition())
    for k,v in ipairs(points) do
	for j,x in ipairs(v) do
	    inst:DoTaskInTime(0.2 * (k-1), function()
		local aoeGroundPound = SpawnPrefab("groundpound_fx")
		aoeGroundPound.Transform:SetPosition(x:Get())
		aoeGroundPound.Transform:SetScale(0.4,0.4,0.4)
	    end)
	end
    end
end

local MUST_HAVE_TAGS_MOLE = {"sdf_riddle_3_moleworm"}
local MUST_HAVE_TAGS_BARRIER = {"sdf_asylum_grounds_barrier"}
local MUST_HAVE_TAGS_PLAYER = {"sdf_riddle_3_active"}
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local CANT_HAVE_TAGS_PLAYER = {"playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 4
local AOE_RADIUS_PLAYER = 15

local function aoeGroundPoundMolewormCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS_MOLE, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find moleworm
	if v ~= nil then
	    v.components.health:DoDelta(-(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_HEALTH), true, "crushed")
	end
    end
end

local function aoeGroundPoundBarrierCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS_BARRIER, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find asylum grounds barrier
	if v ~= nil then
	    v:ClearObstacle()
	end
    end
end

local function aoeGroundPoundPlayerCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()
    local playerSolvedRiddle = false

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS_PLAYER, MUST_HAVE_TAGS_PLAYER, CANT_HAVE_TAGS_PLAYER)
    for i, v in ipairs(affected_entity) do

	--find sdf
	if v ~= nil then
	    --stop interaction after riddle solved
	    local riddleLock = v.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLock()
	    local riddleKey = checkSDFActiveTags(inst, v)

	    if v.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleSolvedIdLock(riddleLock,riddleKey) == false then
		--solve riddle
		v.components.sdf_jack_of_the_green_riddle_quest:SetRiddleSolvedIdLock(riddleLock,riddleKey)
		playerSolvedRiddle = true
	    end
	end
    end
    return playerSolvedRiddle
end

local function koalefantstomp(inst)
    inst.SCARED = true
    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("green_leaves").Transform:SetPosition(x,_,z)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/koalefant/angry")
    inst.AnimState:PlayAnimation("surprise")
    inst.AnimState:PushAnimation("shake", true)

    --Ground Pound
    inst:DoTaskInTime(0.8, function()
	aoeGroundPound(inst)
	aoeGroundPoundMolewormCheck(inst)
	aoeGroundPoundBarrierCheck(inst)
    end)    

    inst:DoTaskInTime(1.5, function()
	inst.AnimState:PushAnimation("alert_idle", true)

	--Riddle 3 Solved Check
	if aoeGroundPoundPlayerCheck(inst) == true then
	    inst:DoTaskInTime(2, function()
		SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)
		SpawnPrefab("carnival_streamer_fx").Transform:SetPosition(x,_,z)

		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_THREE[0], 4)
	    end)
	    inst:DoTaskInTime(6, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_THREE[1], 6)
	    end)
	    inst:DoTaskInTime(12, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_THREE[2], 4)
	    end)
	    inst:DoTaskInTime(16, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_THREE[3], 6)
	    end)
	    inst:DoTaskInTime(22, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_THREE[4], 4)
	    end)
	end

    end)
    inst:DoTaskInTime(30, function()
	inst.SCARED = false
	inst.sg:GoToState("idle")
    end)
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    --inst.Transform:SetSixFaced()
    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst.AnimState:SetBank("koalefant")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_koalefant")
    inst.AnimState:PlayAnimation("idle_loop", true)

    MakeObstaclePhysics(inst, 1)

    inst:AddTag("sdf_riddle_3_koalefant")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.6, 0.58, 0.58, 0)
	inst.components.talker.offset = Vector3(0, -600, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SCARED = false

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:SetStateGraph("SGsdf_jack_of_the_green_riddle_koalefant")

    inst.KoalefantStomp = function() koalefantstomp(inst) end

    return inst
end

return Prefab("sdf_jack_of_the_green_riddle_koalefant", fn, assets)