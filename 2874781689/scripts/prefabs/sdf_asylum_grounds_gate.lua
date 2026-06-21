local assets=
{
    Asset("ANIM", "anim/sdf_asylum_grounds_gate.zip"),
}

prefabs = {
}

local function makeobstacle(inst)
    inst.AnimState:PlayAnimation("closed")
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
    if inst.components.playerprox ~= nil then
	inst:RemoveComponent("playerprox")
    end

    inst.gateOpened = true
    inst.AnimState:PlayAnimation("opened")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/gate/open")
    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)
end

local function OnIsPathFindingDirty(inst)
    if inst:GetCurrentPlatform() == nil then
        local wall_x, wall_y, wall_z = inst.Transform:GetWorldPosition()
        if inst._ispathfinding:value() then
            if inst._pfpos == nil then
                inst._pfpos = Point(wall_x, wall_y, wall_z)
                TheWorld.Pathfinder:AddWall(wall_x, wall_y, wall_z)
            end
        elseif inst._pfpos ~= nil then
            TheWorld.Pathfinder:RemoveWall(wall_x, wall_y, wall_z)
            inst._pfpos = nil
        end
    end
end

---------------------------------------------------
--Listeners

---------------------------------------------------

local function gateturnon(inst, player)
    --gate reactions
    if player.prefab == "sdf" then
	if player:HasTag("sdf_riddle_1_active") and inst.gateid == 2 and inst.gateOpened == false
	or player:HasTag("sdf_riddle_3_active") and inst.gateid == 4 and inst.gateOpened == false 
	or player.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleMaster() == true and inst.gateid > 0 and inst.gateOpened == false then
	    clearobstacle(inst)
	end
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function setgatetype(inst, gateid, gateopened)
    gateopened = gateopened
    if gateopened ~= inst.gateOpened then
        inst.gateOpened = gateopened
    end

    gateid = gateid
    if gateid ~= inst.gateid then
        inst.gateid = gateid
    end

    --Setup gate listeners
    if inst.gateid == 1 then
	clearobstacle(inst)
    end

    --only if gate is closed
    if inst.gateOpened == false then
	if inst.gateid > 1 then
	    inst:AddComponent("playerprox")
	    inst.components.playerprox:SetDist(3,3.3)
	    inst.components.playerprox:SetOnPlayerNear(gateturnon)
	end
    else
	clearobstacle(inst)
    end
end

local function onload(inst, data)
    if data ~= nil and data.gateOpened ~= nil then
        inst.gateOpened = data.gateOpened
    end
    if data ~= nil and data.gateid ~= nil then
        setgatetype(inst, data.gateid, inst.gateOpened)
    end
end

local function onsave(inst, data)
    data.gateid = inst.gateid
    data.gateOpened = inst.gateOpened
end


local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, .5)

    inst.AnimState:SetBank("sdf_asylum_grounds_gate")
    inst.AnimState:SetBuild("sdf_asylum_grounds_gate")
    inst.AnimState:PlayAnimation("closed")

    inst:AddTag("structure")
    inst:AddTag("prototyper")

    inst._pfpos = nil
    inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
    makeobstacle(inst)
    --Delay this because makeobstacle sets pathfinding on by default
    --but we don't to handle it until after our position is set
    inst:DoTaskInTime(0, InitializePathFinding)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.gateid = 0
    inst.gateOpened = false
    setgatetype(inst, inst.gateid, inst.gateOpened)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_asylum_grounds_gate", fn, assets, prefabs)