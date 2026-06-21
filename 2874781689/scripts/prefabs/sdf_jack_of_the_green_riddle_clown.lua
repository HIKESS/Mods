local assets=
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_clown.zip"),
}

prefabs = {
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

local MUST_HAVE_TAGS_PARTY = {"sdf_riddle_2_faceslab"}
local MUST_HAVE_TAGS = {"sdf_riddle_2_smile"}
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 5

local function aoeFaceslabCheck(inst,target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS_PARTY, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find faceslabs
	if v ~= nil then
	    v:TurnSignParty()
	end
    end
end

----

local function aoeSmileCheck(inst,target)
    local smilescount = 0
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find faceslabs with smiles
	if v ~= nil then
	    smilescount = smilescount + 1
	end
    end

    if smilescount >= 5 then
	return true
    else
	return false
    end
end

----
local function resetFX(inst)
    --cancel timer
    inst.resettask:Cancel()

    --rotate clown to sad
    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("green_leaves").Transform:SetPosition(x,_,z)
    SpawnPrefab("planar_resist_fx").Transform:SetPosition(x,_,z)
    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x,_,z)
    inst.AnimState:PlayAnimation("sad")
    inst.faceid = 0
end

local function startreset(inst)
    inst.resettask = inst:DoTaskInTime(inst.timerid, resetFX)
end

----
local function turnSign(inst, picker)
    if inst.faceid == 1 then
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("green_leaves").Transform:SetPosition(x,_,z)
	SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)
	SpawnPrefab("carnival_streamer_fx").Transform:SetPosition(x,_,z)
	inst.AnimState:PlayAnimation("dance")
	--inst.AnimState:PushAnimation("happy", true)

	--Clown Song
	inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	inst:DoTaskInTime(0.5, function()
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	end)
	inst:DoTaskInTime(1.5, function()
	    SpawnPrefab("green_leaves").Transform:SetPosition(x,_,z)
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	    inst.AnimState:PlayAnimation("dance")
	end)
	inst:DoTaskInTime(2.2, function()
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	end)
	inst:DoTaskInTime(2.8, function()
	    SpawnPrefab("green_leaves").Transform:SetPosition(x,_,z)
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	    inst.AnimState:PlayAnimation("dance")
	end)
	inst:DoTaskInTime(4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	end)
	inst:DoTaskInTime(5, function()
	    SpawnPrefab("green_leaves").Transform:SetPosition(x,_,z)
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	    inst.AnimState:PlayAnimation("dance")
	    inst.AnimState:PushAnimation("happy", true)
	end)
	inst:DoTaskInTime(6.2, function()
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
	end)

	--Riddle 2 Solved
	local riddleLock = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLock()
	local riddleKey = checkSDFActiveTags(inst, picker)
	picker.components.sdf_jack_of_the_green_riddle_quest:SetRiddleSolvedIdLock(riddleLock,riddleKey)

	inst:DoTaskInTime(6.5, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_TWO[0], 4)
	end)
	inst:DoTaskInTime(10.5, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_TWO[1], 4)
	end)
	inst:DoTaskInTime(14.5, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_TWO[2], 6)
	end)

	--Start Timer
	inst.resettask = inst:DoTaskInTime(0, startreset)

	--turn all signs to smile
	aoeFaceslabCheck(inst,picker)
    end
    if inst.faceid >= 2 then
	--Clown sound
	inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
    end
end

local function ongrow(inst)
    --inst.AnimState:PlayAnimation("frown")
    --inst.Physics:SetActive(true)
end

local function makebarrenfn(inst)
    --inst.AnimState:PlayAnimation("hidden")
    --inst.Physics:SetActive(false)
end

local function onpickedfn(inst, picker)
    if inst.components.pickable ~= nil then
	--hit effect
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("planar_resist_fx").Transform:SetPosition(x,_,z)

	if picker.prefab == "sdf" then
	    if picker:HasTag("sdf_riddle_2_active") then
		--stop interaction after riddle solved
		local riddleLock = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLock()
		local riddleKey = checkSDFActiveTags(inst, picker)
		
		if picker.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleSolvedIdLock(riddleLock,riddleKey) == false then
		    --check faceslabs
		    if aoeSmileCheck(inst,picker) then
			SpawnPrefab("planar_hit_fx").Transform:SetPosition(x,_,z)
			inst.faceid = inst.faceid + 1
			turnSign(inst, picker)
		    end
		end
	    end
	end
    end
end

local function settimertype(inst, timerid)
    timerid = timerid
    if timerid ~= inst.timerid then
        inst.timerid = timerid
    end

    --Setup timers
    if inst.timerid > 0 then
	inst:AddComponent("pickable")
	inst.components.pickable:SetUp("", 0, 0)
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makebarrenfn = makebarrenfn
    end
end

local function onload(inst, data)
    if data ~= nil and data.timerid ~= nil then
        settimertype(inst, data.timerid)
    end
end

local function onsave(inst, data)
    data.timerid = inst.timerid
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst.AnimState:SetBank("sdf_jack_of_the_green_riddle_clown")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_clown")
    inst.AnimState:PlayAnimation("sad")

    MakeObstaclePhysics(inst, .2)

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

    inst.faceid = 0
    inst.timerid = 0
    settimertype(inst, inst.timerid)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst.resettask = nil

    return inst
end

return  Prefab("sdf_jack_of_the_green_riddle_clown", fn, assets)