local NPC_TUNING = require("npc_tuning")

local assets =
{
    Asset("ANIM", "anim/fireflies.zip"),
}

local function CancelTask(inst, name)
    if inst[name] ~= nil then
        inst[name]:Cancel()
        inst[name] = nil
    end
end

local function Clamp01(value)
    return math.max(0, math.min(1, value or 0))
end

local function RandomChannel(range)
    range = range or {}
    local min = range.min or 0
    local max = range.max or 1
    return Clamp01(min + math.random() * (max - min))
end

local function ApplyColor(inst)
    local r = inst._rainbow_r ~= nil and inst._rainbow_r:value() or 1
    local g = inst._rainbow_g ~= nil and inst._rainbow_g:value() or 1
    local b = inst._rainbow_b ~= nil and inst._rainbow_b:value() or 1
    inst.Light:SetColour(r, g, b)
    inst.AnimState:SetMultColour(r, g, b, 1)
end

local function RandomizeColor(inst)
    if not TheWorld.ismastersim then return end
    local cfg = NPC_TUNING.RAINBOW_FIREFLIES_RANDOM_COLOR or {}
    local color = #cfg > 0 and cfg[math.random(#cfg)] or nil
    inst._rainbow_r:set(color ~= nil and (color.r or 1) or RandomChannel(cfg.r))
    inst._rainbow_g:set(color ~= nil and (color.g or 1) or RandomChannel(cfg.g))
    inst._rainbow_b:set(color ~= nil and (color.b or 1) or RandomChannel(cfg.b))
    ApplyColor(inst)
end

local function SetWorkable(inst, workable)
    if TheWorld.ismastersim and inst.components.workable ~= nil then
        inst.components.workable:SetWorkable(workable)
    end
end

local function FadeTo(inst, target, seconds)
    CancelTask(inst, "_rainbow_fade_task")

    if target > 0 then
        inst.Light:Enable(true)
        ApplyColor(inst)
        if TheWorld.ismastersim then
            inst:RemoveTag("NOCLICK")
            SetWorkable(inst, true)
            if not inst.AnimState:IsCurrentAnimation("swarm_loop") then
                inst.AnimState:PlayAnimation("swarm_pre")
                inst.AnimState:PushAnimation("swarm_loop", true)
            end
        end
    end

    local from = inst._rainbow_intensity or 0
    if seconds == nil or seconds <= 0 then
        inst._rainbow_intensity = target
        inst.Light:SetIntensity(target)
        if target <= 0 then
            inst.Light:Enable(false)
            if TheWorld.ismastersim then
                inst:AddTag("NOCLICK")
                SetWorkable(inst, false)
            end
        end
        return
    end

    local elapsed = 0
    inst._rainbow_fade_task = inst:DoPeriodicTask(FRAMES, function(i)
        elapsed = elapsed + FRAMES
        local p = math.min(elapsed / seconds, 1)
        local value = from + (target - from) * p
        i._rainbow_intensity = value
        i.Light:SetIntensity(value)
        if p >= 1 then
            CancelTask(i, "_rainbow_fade_task")
            if target <= 0 then
                i.Light:Enable(false)
                if TheWorld.ismastersim then
                    i:AddTag("NOCLICK")
                    SetWorkable(i, false)
                    i.AnimState:PlayAnimation("swarm_pst")
                end
            end
        end
    end)
end

local function OnRainbowColorDirty(inst)
    ApplyColor(inst)
end

local function OnRainbowEnabledDirty(inst)
    if inst._rainbow_enabled:value() then
        FadeTo(inst, NPC_TUNING.RAINBOW_FIREFLIES_LIGHT_INTENSITY or 0.55, NPC_TUNING.RAINBOW_FIREFLIES_FADEIN_TIME or 1.5)
    else
        FadeTo(inst, 0, NPC_TUNING.RAINBOW_FIREFLIES_FADEOUT_TIME or 0.8)
    end
end

local function UpdateLight(inst)
    local enabled = TheWorld.state.isnight and (not TheWorld.ismastersim or inst.components.inventoryitem.owner == nil)
    if TheWorld.ismastersim then
        inst._rainbow_enabled:set(enabled)
    end
    if enabled then
        FadeTo(inst, NPC_TUNING.RAINBOW_FIREFLIES_LIGHT_INTENSITY or 0.55, NPC_TUNING.RAINBOW_FIREFLIES_FADEIN_TIME or 1.5)
    else
        FadeTo(inst, 0, NPC_TUNING.RAINBOW_FIREFLIES_FADEOUT_TIME or 0.8)
    end
end

local function OnDropped(inst)
    inst.components.workable:SetWorkLeft(1)
    RandomizeColor(inst)
    inst:DoTaskInTime(0, UpdateLight)
end

local function OnPutInInventory(inst)
    inst._rainbow_enabled:set(false)
    FadeTo(inst, 0, 0)
end

local function OnWorked(inst, worker)
    if worker.components.inventory ~= nil then
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
    end
end

local function GetStatus(inst)
    if inst.components.inventoryitem.owner ~= nil then
        return "HELD"
    end
end

local function OnIsNight(inst)
    inst:DoTaskInTime(0.5 + math.random(), UpdateLight)
end

local function OnRemove(inst)
    CancelTask(inst, "_rainbow_fade_task")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(NPC_TUNING.RAINBOW_FIREFLIES_LIGHT_FALLOFF or 1)
    inst.Light:SetIntensity(0)
    inst.Light:SetRadius(NPC_TUNING.RAINBOW_FIREFLIES_LIGHT_RADIUS or 1.3)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.scrapbook_anim = "swarm_loop"
    inst.scrapbook_tex = "fireflies"

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("fireflies")
    inst.AnimState:SetBuild("fireflies")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("firefly")
    inst:AddTag("cattoyairborne")
    inst:AddTag("flying")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst._rainbow_intensity = 0
    inst._rainbow_r = net_float(inst.GUID, "npc_rainbow_fireflies._rainbow_r", "rainbowcolordirty")
    inst._rainbow_g = net_float(inst.GUID, "npc_rainbow_fireflies._rainbow_g", "rainbowcolordirty")
    inst._rainbow_b = net_float(inst.GUID, "npc_rainbow_fireflies._rainbow_b", "rainbowcolordirty")
    inst._rainbow_enabled = net_bool(inst.GUID, "npc_rainbow_fireflies._rainbow_enabled", "rainbowenableddirty")

    inst.entity:SetPristine()
    inst:ListenForEvent("onremove", OnRemove)

    if not TheWorld.ismastersim then
        inst:ListenForEvent("rainbowcolordirty", OnRainbowColorDirty)
        inst:ListenForEvent("rainbowenableddirty", OnRainbowEnabledDirty)
        inst:DoTaskInTime(0, OnRainbowColorDirty)
        inst:DoTaskInTime(0, OnRainbowEnabledDirty)
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)
    inst.components.workable:SetWorkable(false)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst.components.stackable.forcedropsingle = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("fireflies")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true

    inst:AddComponent("tradable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = NPC_TUNING.RAINBOW_FIREFLIES_FUEL_VALUE or TUNING.LARGE_FUEL
    inst.components.fuel.fueltype = FUELTYPE.CAVE

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("isnight", OnIsNight)

    RandomizeColor(inst)
    UpdateLight(inst)

    return inst
end

return Prefab("npc_rainbow_fireflies", fn, assets)
