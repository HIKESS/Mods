local assets=
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_face_slab.zip"),
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

----
local function resetfullFX(inst)
    --cancel timer
    inst.resettask:Cancel()

    --rotate face slab to frown
    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("planar_resist_fx").Transform:SetPosition(x,_,z)
    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x,_,z)
    inst.AnimState:PlayAnimation("frown")
    inst.faceid = 0 
end

local function resetpartyFX(inst)
    if inst:HasTag("sdf_riddle_2_smile") then
	inst:RemoveTag("sdf_riddle_2_smile")
    end
    --cancel timer
    inst.resettask:Cancel()

    --rotate face slab to smileside
    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("planar_resist_fx").Transform:SetPosition(x,_,z)
    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x,_,z)
    inst.AnimState:PlayAnimation("smileside")
    inst.faceid = 3 

   --full reset
   inst.resettask = inst:DoTaskInTime(1, resetfullFX)
end

local function resetFX(inst)
    if inst:HasTag("sdf_riddle_2_smile") then
	inst:RemoveTag("sdf_riddle_2_smile")
    end
    --cancel timer
    inst.resettask:Cancel()

    --rotate face slab to smileside
    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("planar_resist_fx").Transform:SetPosition(x,_,z)
    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x,_,z)
    inst.AnimState:PlayAnimation("smileside")
    inst.faceid = 3 
end

local function startpartyreset(inst, timer)
    inst.resettask = inst:DoTaskInTime(timer, resetpartyFX)
end

local function startreset(inst)
    inst.resettask = inst:DoTaskInTime(inst.timerid, resetFX)
end

----
local function turnsignparty(inst, timer)
    --cancel timer
    if inst.resettask ~= nil then
	inst.resettask:Cancel()
    end

    inst:AddTag("sdf_riddle_2_smile")

    --rotate face slab to smile
    local x,_,z = inst.Transform:GetWorldPosition()
    SpawnPrefab("planar_resist_fx").Transform:SetPosition(x,_,z)
    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x,_,z)
    SpawnPrefab("carnival_streamer_fx").Transform:SetPosition(x,_,z)
    inst.AnimState:PlayAnimation("smile")
    inst.faceid = 2

    --Start Timer
    inst.resettask = inst:DoTaskInTime(0, startpartyreset(inst, timer))
end

local function turnSign(inst, picker)
    if inst.faceid == 1 then
	inst.AnimState:PlayAnimation("frownside")
    end
    if inst.faceid == 2 then
	inst.AnimState:PlayAnimation("smile")
	inst:AddTag("sdf_riddle_2_smile")

	--Start Timer
	inst.resettask = inst:DoTaskInTime(0, startreset)
    end
    if inst.faceid == 3 then
	inst.AnimState:PlayAnimation("smileside")
	if inst:HasTag("sdf_riddle_2_smile") then
	    inst:RemoveTag("sdf_riddle_2_smile")
	end

	--cancel timer
	if inst.resettask ~= nil then
	    inst.resettask:Cancel()
	end
    end
    if inst.faceid >= 4 then
	inst.faceid = 0
	inst.AnimState:PlayAnimation("frown")
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
		    --Turn sign
		    SpawnPrefab("planar_hit_fx").Transform:SetPosition(x,_,z)
		    inst.faceid = inst.faceid + 1
		    turnSign(inst, picker)
		end
	    end
	end
    end
end

local function setordertype(inst, orderid, timerid)
    orderid = orderid
    if orderid ~= inst.orderid then
        inst.orderid = orderid
    end

    timerid = timerid
    if timerid ~= inst.timerid then
        inst.timerid = timerid
    end

    --Setup orders
    if inst.orderid > 0 then
	inst:AddComponent("pickable")
	inst.components.pickable:SetUp("", 0, 0)
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makebarrenfn = makebarrenfn
	inst.components.pickable.jostlepick = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.orderid ~= nil and data.timerid ~= nil then
        setordertype(inst, data.orderid, data.timerid)
    end
end

local function onsave(inst, data)
    data.orderid = inst.orderid
    data.timerid = inst.timerid
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(0.8, 0.8, 0.8)

    inst.AnimState:SetBank("sdf_jack_of_the_green_riddle_face_slab")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_face_slab")
    inst.AnimState:PlayAnimation("frown")

    MakeObstaclePhysics(inst, .1)

    inst:AddTag("sdf_riddle_2_faceslab")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.faceid = 0
    inst.orderid = 0
    inst.timerid = 0
    setordertype(inst, inst.orderid, inst.timerid)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.TurnSignParty = function() turnsignparty(inst, 30) end

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst.resettask = nil

    return inst
end

return  Prefab("sdf_jack_of_the_green_riddle_face_slab", fn, assets)