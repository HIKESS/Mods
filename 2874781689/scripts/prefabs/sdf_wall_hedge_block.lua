require "prefabutil"

local assets=
{
    Asset("ANIM", "anim/sdf_wall_hedge_block.zip"),
}

prefabs = {
}

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

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function makeobstacle(inst)
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)
end

local anims =
{
    { threshold = 0, anim = "broken" },
    { threshold = 0.4, anim = "onequarter" },
    { threshold = 0.5, anim = "half" },
    { threshold = 0.99, anim = "threequarter" },
    { threshold = 1, anim = { "fullA"} },
}

local function resolveanimtoplay(inst, percent)
    for i, v in ipairs(anims) do
        if percent <= v.threshold then
            if type(v.anim) == "table" then
                -- get a stable animation, by basing it on world position
                local x, y, z = inst.Transform:GetWorldPosition()
                local x = math.floor(x)
                local z = math.floor(z)
                local q1 = #v.anim + 1
                local q2 = #v.anim + 4
                local t = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #v.anim + 1
                return v.anim[t]
            else
                return v.anim
            end
        end
    end
end

local function onhealthchange(inst, old_percent, new_percent)
    local anim_to_play = resolveanimtoplay(inst, new_percent)
    if new_percent > 0 then
        if old_percent <= 0 then
            makeobstacle(inst)
        end
        inst.AnimState:PlayAnimation(anim_to_play.."_hit")
        inst.AnimState:PushAnimation(anim_to_play, false)
    else
        if old_percent > 0 then
            clearobstacle(inst)
        end
        inst.AnimState:PlayAnimation(anim_to_play)
    end
end

local function keeptargetfn()
    return false
end

local function onload(inst,data)
    if inst.components.health:IsDead() then
        clearobstacle(inst)
    end

    if data and data.gridnudge then
        local function normalize(coord)

            local temp = coord%0.5
            coord = coord + 0.5 - temp

            if  coord%1 == 0 then
                coord = coord -0.5
            end

            return coord
        end

        local pt = Vector3(inst.Transform:GetWorldPosition())
        pt.x = normalize(pt.x)
        pt.z = normalize(pt.z)
        inst.Transform:SetPosition(pt.x,pt.y,pt.z)
    end
end

local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local function onhammered(inst, worker)
    --local num_loots = math.max(1, math.floor(3 * inst.components.health:GetPercent()))
    --for i = 1, num_loots do
	--inst.components.lootdropper:SpawnLootPrefab("cutgrass")
    --end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("straw")

    inst.components.workable:SetWorkLeft(1000)
end

local function onhit(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_straw")

    local healthpercent = inst.components.health:GetPercent()
    if healthpercent > 0 then
	local anim_to_play = resolveanimtoplay(inst, healthpercent)
	inst.AnimState:PlayAnimation(anim_to_play.."_hit")
	inst.AnimState:PushAnimation(anim_to_play, false)
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetEightFaced()

    MakeObstaclePhysics(inst, .5)
    inst.Physics:SetDontRemoveOnSleep(true)
    
    --inst:AddTag("wall")
    inst:AddTag("noauradamage")

    inst.AnimState:SetBank("sdf_wall_hedge_block")
    inst.AnimState:SetBuild("sdf_wall_hedge_block")
    inst.AnimState:PlayAnimation("half")

    --MakeSnowCoveredPristine(inst)

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

    inst:AddComponent("lootdropper")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HAYWALL_HEALTH)
    inst.components.health:SetCurrentHealth(TUNING.HAYWALL_HEALTH * .5)
    inst.components.health.ondelta = onhealthchange
    inst.components.health.nofadeout = true
    inst.components.health.canheal = false
    inst.components.health:SetAbsorptionAmount(1) --1

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1000)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("inspectable")

    --MakeSnowCovered(inst)

    --inst.OnLoad = onload

    return inst
end

return  Prefab("sdf_wall_hedge_block", fn, assets)