local assets=
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_star.zip"),
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

local function ongrow(inst)
    --inst.AnimState:PlayAnimation("idle")
    --inst.Physics:SetActive(true)
end

local function makebarrenfn(inst)
    --inst.AnimState:PlayAnimation("hidden")
    --inst.Physics:SetActive(false)
end

local function onpickedfn(inst, picker)
    if inst.components.pickable ~= nil then
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
	--need to add sound effect
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("green_leaves").Transform:SetPosition(x,_,z)

	if picker.prefab == "sdf" then
	    if picker:HasTag("sdf_riddle_1_active") then
		local lock = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleOneLock()
		local key = inst.starid
		
		if picker.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleOneLock(lock,key) == false then
		    --found star
		    picker.components.sdf_jack_of_the_green_riddle_quest:SetRiddleOneLock(lock,key)
		    SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)

		    inst:DoTaskInTime(0.1, function()
			--Annouce Found Star
			local lockUpdated = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleOneLock()
			local starCounter = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleOneStarsFound(lockUpdated)

			inst.components.talker:Say(starCounter.." of 5 ".. STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SDF_RIDDLE_ONE_STAR_FOUND, 4)
			if starCounter == 5 then
			    SpawnPrefab("carnival_streamer_fx").Transform:SetPosition(x,_,z)
			    --Riddle 1 Solved
			    local riddleLock = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLock()
			    local riddleKey = checkSDFActiveTags(inst, picker)
			    picker.components.sdf_jack_of_the_green_riddle_quest:SetRiddleSolvedIdLock(riddleLock,riddleKey)

			    inst:DoTaskInTime(4, function()
				inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
				inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_ONE[0], 4)
			    end)
			    inst:DoTaskInTime(8, function()
				inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
				inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_ONE[1], 6)
			    end)
			    inst:DoTaskInTime(12, function()
				inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
				inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_ONE[2], 4)
			    end)
			end
		    end)
		end
	    end
	end
    end
end

local function setstartype(inst, starid)
    starid = starid
    if starid ~= inst.starid then
        inst.starid = starid
    end

    --Setup stars
    if inst.starid > 0 then
	inst:AddComponent("pickable")
	inst.components.pickable:SetUp("", 0, 0)
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makebarrenfn = makebarrenfn
	inst.components.pickable.jostlepick = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.starid ~= nil then
        setstartype(inst, data.starid)
    end
end

local function onsave(inst, data)
    data.starid = inst.starid
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(0.6, 0.6, 0.6)

    inst.AnimState:SetBank("sdf_jack_of_the_green_riddle_star")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_star")
    inst.AnimState:PlayAnimation("idle")

    MakeObstaclePhysics(inst, .1)

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

    inst.starid = 0
    setstartype(inst, inst.starid)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_jack_of_the_green_riddle_star", fn, assets)