local assets=
{
    Asset("ANIM", "anim/sdf_haunted_ruins_gate.zip"),
}

prefabs = {
}

local function makeobstacle(inst)
    inst.gateOpened = false
    inst.AnimState:PlayAnimation("closed")
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
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

local function gateturnon(inst, player)
    --gate reactions
    if player:HasTag("sdf_stone_golem_target") then
	player:RemoveTag("sdf_stone_golem_target")
    end
    if inst.gateOpened == false then
	clearobstacle(inst)
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function setgatetype(inst, gateopened)
    gateopened = gateopened
    if gateopened ~= inst.gateOpened then
        inst.gateOpened = gateopened
    end

    --only if gate is closed
    if inst.gateOpened == true then
	clearobstacle(inst)
    end
end

local function onload(inst, data)
    if data ~= nil and data.gateOpened ~= nil then
        inst.gateOpened = data.gateOpened
    end
end

local function onsave(inst, data)
    data.gateOpened = inst.gateOpened
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, .5)

    inst.AnimState:SetBank("sdf_haunted_ruins_gate")
    inst.AnimState:SetBuild("sdf_haunted_ruins_gate")
    inst.AnimState:PlayAnimation("closed")

    inst:AddTag("structure")
    inst:AddTag("prototyper")

    inst._pfpos = nil
    inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
    makeobstacle(inst)

    inst:DoTaskInTime(0, InitializePathFinding)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.gateOpened = false
    setgatetype(inst, inst.gateOpened)

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2,2.3)
    inst.components.playerprox:SetOnPlayerNear(gateturnon)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    --inst.OnLoad = onload
    --inst.OnSave = onsave

    return inst
end

return  Prefab("sdf_haunted_ruins_gate", fn, assets, prefabs)