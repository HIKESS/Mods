
local PLANTS_RANGE = 1
local MAX_PLANTS = 18
local PLANTFX_TAGS = { "wormwood_plant_fx", "npc_wormwood_plant_fx" }
local POLLEN_VARIATIONS = { 1, 2, 3, 4, 5 }
local PLANT_VARIATIONS = { 1, 2, 3, 4 }

local function ShufflePool(pool)
    local copy = {}
    for i, v in ipairs(pool) do copy[i] = v end
    for i = #copy, 1, -1 do
        local j = math.random(i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    return copy
end

local function BloomFxBlocked(inst)
    return inst._is_ghost_mode
        or not inst.entity:IsVisible()
        or (inst.components.health and inst.components.health:IsDead())
end

local function PickFromPool(pool)
    local rnd = math.random()
    local idx = math.clamp(math.ceil(rnd * rnd * #pool), 1, #pool)
    local val = pool[idx]
    table.insert(pool, table.remove(pool, idx))
    return val
end

local function SpawnPollenFxLocal(inst, rnd)
    if TheNet:IsDedicated() or inst == nil or not inst:IsValid() then
        return
    end
    local fx = CreateEntity()
    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    fx.entity:SetCanSleep(false)
    fx.persists = false
    fx.entity:AddTransform()
    fx.entity:AddAnimState()
    fx.AnimState:SetBank("wormwood_pollen_fx")
    fx.AnimState:SetBuild("wormwood_pollen_fx")
    fx.AnimState:PlayAnimation("pollen" .. tostring(rnd))
    fx.AnimState:SetFinalOffset(2)
    fx:ListenForEvent("animover", fx.Remove)
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function PollenTick(inst)
    if BloomFxBlocked(inst) then return end
    if inst.sg and (
        inst.sg:HasStateTag("nomorph")
        or inst.sg:HasStateTag("silentmorph")
        or inst.sg:HasStateTag("ghostbuild")
    ) then
        return
    end
    local rnd = PickFromPool(inst._wormwood_pollen_pool)
    if inst.npc_wormwood_pollen then
        inst.npc_wormwood_pollen:set_local(0)
        inst.npc_wormwood_pollen:set(rnd)
    else
        SpawnPollenFxLocal(inst, rnd)
    end
end

local function PlantTick(inst)
    if BloomFxBlocked(inst) or inst:GetCurrentPlatform() then return end

    local x, y, z = inst.Transform:GetWorldPosition()
    if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, PLANTFX_TAGS) >= MAX_PLANTS then
        return
    end

    local map = TheWorld.Map
    local pt = Vector3(0, 0, 0)
    local offset = FindValidPositionByFan(
        math.random() * TWOPI,
        math.random() * PLANTS_RANGE,
        3,
        function(off)
            pt.x = x + off.x
            pt.z = z + off.z
            return map:CanPlantAtPoint(pt.x, 0, pt.z)
                and #TheSim:FindEntities(pt.x, 0, pt.z, .5, PLANTFX_TAGS) < 3
                and map:IsDeployPointClear(pt, nil, .5)
                and not map:IsPointNearHole(pt, .4)
        end
    )
    if not offset then return end

    local plant = SpawnPrefab("npc_wormwood_plant_fx")
    if plant == nil then return end
    plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
    plant:SetVariation(PickFromPool(inst._wormwood_plant_pool))
end

local function Start(inst)
    if not inst or inst._wormwood_bloom_fx_on then return end
    inst._wormwood_bloom_fx_on = true
    inst.fullbloom = true
    inst._wormwood_pollen_pool = inst._wormwood_pollen_pool or ShufflePool(POLLEN_VARIATIONS)
    inst._wormwood_plant_pool = inst._wormwood_plant_pool or ShufflePool(PLANT_VARIATIONS)
    if not inst._wormwood_pollentask then
        inst._wormwood_pollentask = inst:DoPeriodicTask(.7, PollenTick)
    end
    if not inst._wormwood_planttask then
        inst._wormwood_planttask = inst:DoPeriodicTask(.25, PlantTick)
    end
end

local function Stop(inst)
    if not inst then return end
    inst._wormwood_bloom_fx_on = nil
    inst.fullbloom = nil
    if inst._wormwood_pollentask then
        inst._wormwood_pollentask:Cancel()
        inst._wormwood_pollentask = nil
    end
    if inst._wormwood_planttask then
        inst._wormwood_planttask:Cancel()
        inst._wormwood_planttask = nil
    end
end

local function InitClient(inst)
    if inst._wormwood_bloom_client or inst.npc_wormwood_pollen == nil then return end
    inst._wormwood_bloom_client = true
    inst:ListenForEvent("npcwormwoodpollendirty", function()
        local v = inst.npc_wormwood_pollen:value()
        if v > 0 then
            SpawnPollenFxLocal(inst, v)
        end
    end)
end

return {
    Start = Start,
    Stop = Stop,
    InitClient = InitClient,
}
