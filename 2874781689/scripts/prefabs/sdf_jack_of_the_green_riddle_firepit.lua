require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_firepit.zip"),
}

local prefabs = {
}

local FIREPIT_ON = false --Use for pickable

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

local MUST_HAVE_TAGS_FIREPIT = {"sdf_riddle_4_firepit"}
local MUST_HAVE_TAGS_PLAYER = {"sdf_riddle_4_active"}
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local CANT_HAVE_TAGS_PLAYER = {"playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 10
local AOE_RADIUS_PLAYER = 3

local function aoeLiteSDFSolveCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()
    local playerSolvedRiddle = false

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS_PLAYER, MUST_HAVE_TAGS_PLAYER, CANT_HAVE_TAGS_PLAYER)
    for i, v in ipairs(affected_entity) do

	--find sdf solve riddle
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

local function aoeLiteFirepitCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS_FIREPIT, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find firepit
	if v ~= nil and v ~= inst then
	    if v.components.fueled then
		if v.components.fueled:IsEmpty() == false then
		    inst.components.fueled:DoDelta(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_MAX)
		    v.components.fueled:DoDelta(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_MAX)
		    v.components.fueled.accepting = false
		    return true
		end
	    end
	end
    end
    return false
end

local function onextinguish(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function ontakefuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")

    --check if other Firepit is lit
    if aoeLiteFirepitCheck(inst) == true then
	--Solve Riddle
	if aoeLiteSDFSolveCheck(inst) == true then
	    local x,_,z = inst.Transform:GetWorldPosition()
	    inst:DoTaskInTime(0, function()
		SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)
		SpawnPrefab("carnival_streamer_fx").Transform:SetPosition(x,_,z)

		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_FOUR[0], 6)
	    end)
	    inst:DoTaskInTime(6, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_FOUR[1], 4)
	    end)
	    inst:DoTaskInTime(10, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_FOUR[2], 6)
	    end)
	    inst:DoTaskInTime(16, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_SOLVE_SDF_RIDDLE_FOUR[3], 4)
	    end)
	end
    end
end

local function updatefuelrate(inst)
    if TheWorld.state.isnight then
	inst.components.fueled.rate = TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_NIGHT_RATE
    elseif TheWorld.state.isdusk then
	inst.components.fueled.rate = TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_DUSK_RATE
    else
	inst.components.fueled.rate = TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_DAY_RATE
    end
end

local function onupdatefueled(inst)
    if inst.components.burnable ~= nil and inst.components.fueled ~= nil then
        updatefuelrate(inst)
        inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
    end
end

local function onfuelchange(newsection, oldsection, inst, doer)
    if newsection <= 0 then
        inst.components.burnable:Extinguish()
    else
        if not inst.components.burnable:IsBurning() then
            updatefuelrate(inst)
            inst.components.burnable:Ignite(nil, nil, doer)
        end
        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())
    end
end

local SECTION_STATUS =
{
    [0] = "OUT",
    [1] = "EMBERS",
    [2] = "LOW",
    [3] = "NORMAL",
    [4] = "HIGH",
}
local function getstatus(inst)
    return SECTION_STATUS[inst.components.fueled:GetCurrentSection()]
end

local function OnInit(inst)
    if inst.components.burnable ~= nil then
        inst.components.burnable:FixFX()
    end
end

local function setordertype(inst, orderid)
    orderid = orderid
    if orderid ~= inst.orderid then
        inst.orderid = orderid
    end
end

local function onload(inst, data)
    if data ~= nil and data.orderid ~= nil then
        setordertype(inst, data.orderid)
    end
end

local function onsave(inst, data)
    data.orderid = inst.orderid
end

local function firepitturnoff(inst)
    if inst.FIREPIT_ON == true then
	inst.FIREPIT_ON = false
	if inst.components.fueled:IsEmpty() then
	    inst.components.fueled.accepting = false
	end
    end
end

local function firepitturnon(inst, player)
    if player.prefab == "sdf" then
	if player:HasTag("sdf_riddle_4_active") then
	    --firepit on
	    inst.FIREPIT_ON = true

	    --greet
	    inst:DoTaskInTime(0,function()
		inst.components.fueled.accepting = true
	    end)
	end
    end
end

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")

    inst.components.workable:SetWorkLeft(1000)
end

local function onhit(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst.AnimState:SetBank("sdf_jack_of_the_green_riddle_firepit")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_firepit")
    inst.AnimState:PlayAnimation("idle", false)

    MakeObstaclePhysics(inst, .3)

    inst:AddTag("sdf_riddle_4_firepit")
    inst:AddTag("campfire")
    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")

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

    inst.orderid = 0
    setordertype(inst, inst.orderid)

    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1000)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("burnable")
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0))
    inst:ListenForEvent("onextinguish", onextinguish)

    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_MAX
    inst.components.fueled.accepting = false

    inst.components.fueled:SetSections(4)
    inst.components.fueled.bonusmult = 5
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:SetUpdateFn(onupdatefueled)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_START)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2.1,2.3)
    inst.components.playerprox:SetOnPlayerNear(firepitturnon)
    inst.components.playerprox:SetOnPlayerFar(firepitturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE


    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:DoTaskInTime(0, OnInit)

    return inst
end

return Prefab("sdf_jack_of_the_green_riddle_firepit", fn, assets)