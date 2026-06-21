local assets =
{
	Asset("ANIM", "anim/sdf_professors_lab_light.zip"),
}

local prefabs = {
}

local function DoTurnOffSound(inst)
    inst._soundtask = nil
    inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_off")
end

local function PlayTurnOffSound(inst)
    if inst._soundtask == nil and inst:GetTimeAlive() > 0 then
        inst._soundtask = inst:DoTaskInTime(0, DoTurnOffSound)
    end
end

local function PlayTurnOnSound(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    elseif not POPULATING then
        inst._light.SoundEmitter:PlaySound("dontstarve/wilson/lantern_on")
    end
end

local function onremovelight(light)
    light._light._light = nil
end

local function turnon(inst)
    if inst._light == nil then
	inst._light = SpawnPrefab("sdf_professors_lab_light_light")
	inst._light._light = inst
	inst:ListenForEvent("onremove", onremovelight, inst._light)
            PlayTurnOnSound(inst)
    end
    inst._light.entity:SetParent(inst.entity)
end

local function turnoff(inst)
    if inst._light ~= nil then
        inst._light:Remove()
        PlayTurnOffSound(inst)
    end
end

local function OnLightWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_LP", "loop")
    end
end

local function OnLightSleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function makeLight()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddLight()
    inst.Light:SetRadius(8) --8
    inst.Light:SetFalloff(0.4) --0.4
    inst.Light:SetIntensity(0.9) --0.9
    inst.Light:SetColour(251 / 255, 248 / 255, 103 / 255)

    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    inst.persists = false

   if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function OnLightWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_LP", "loop")
    end
end

local function OnLightSleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnRemove(inst)
    if inst._light ~= nil then
        inst._light:Remove()
    end
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
end

local function updatelight(inst, phase)
    if TheWorld.state.isnight then
        if inst._light == nil and inst._isPowered == true then
	    inst.AnimState:PlayAnimation("light")
            turnon(inst) --inst._light:Show()
        end
    else
        if inst._light ~= nil and inst._isPowered == true then
	    inst.AnimState:PlayAnimation("idle_on")
            turnoff(inst) --inst._light:Hide()
        end
    end
end

local function OnIsNight(inst)
    inst:DoTaskInTime(2 + math.random(), updatelight)
end

local function makePowered(inst)
    inst.AnimState:PlayAnimation("idle_on")
    inst._isPowered = true
    OnLightWake(inst)
    updatelight(inst)
end

local function makeUnpowered(inst)
    inst.AnimState:PlayAnimation("idle_off")
    turnoff(inst) --inst._light:Hide()
    inst._isPowered = false
    OnLightSleep(inst)
    --updatelight(inst, TheWorld.state.phase)
end

local function setPowered(inst)
    if inst._isPowered == true then
	makePowered(inst)
    end
end

local function onsave(inst, data)
    data._isPowered = inst._isPowered
end

local function onload(inst, data)
    if data and data._isPowered ~= nil then
        inst._isPowered = data._isPowered
	setPowered(inst)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(1.1, 1.1, 1.1) --1.4

    inst.AnimState:SetBank("sdf_professors_lab_light")
    inst.AnimState:SetBuild("sdf_professors_lab_light")
    inst.AnimState:PlayAnimation("idle_off")

    inst:AddTag("NOBLOCK")
    inst:AddTag("waterproofer")
    inst:AddTag("nonpackable")
    inst:AddTag("sdf_professors_lab_generator_powered")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("inspectable")

    inst._light = nil

    inst._isPowered = false
    inst.SdfProfessorsLabPoweredFn = function() makePowered(inst) end
    inst.SdfProfessorsLabUnpoweredFn = function() makeUnpowered(inst) end

    inst:WatchWorldState("isnight", OnIsNight)
    inst.OnRemoveEntity = OnRemove

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("sdf_professors_lab_light", fn, assets), Prefab("sdf_professors_lab_light_light", makeLight)