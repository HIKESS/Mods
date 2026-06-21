require("prefabutil")

local assets = {
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_glowshroom1.zip"),
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_glowshroom2.zip"),
}

local prefabs =
{
}

local function IsLightOn(inst)
    return inst.Light:IsEnabled()
end

local light_str =
{
    {radius = 1.25, falloff = .95, intensity = 0.75},
    {radius = 1.82, falloff = .85, intensity = 0.75},
}

local dispersal_light_str =
{
    {radius = 1.15, falloff = .95, intensity = 0.75},
    {radius = 1.72, falloff = .85, intensity = 0.75},
}

local sounds_1 =
{
    toggle = "dontstarve/common/together/mushroom_lamp/lantern_2_on",
    colour = "dontstarve/common/together/mushroom_lamp/change_colour",
    craft = "dontstarve/common/together/mushroom_lamp/craft_2",
}

local function ClearSoundQueue(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    end
end

local function OnQueuedSound(inst, soundname)
    inst._soundtask = nil
    inst.SoundEmitter:PlaySound(soundname)
end

local function QueueSound(inst, delay, soundname)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
    inst._soundtask = inst:DoTaskInTime(delay, OnQueuedSound, soundname)
end

local function dispersal(inst)
    local sound = sounds_1

    inst.AnimState:PlayAnimation("dispersal")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound(sound.toggle)
    QueueSound(inst, 13 * FRAMES, sound.colour)

    inst.Light:SetRadius(dispersal_light_str[inst.brightness].radius)
    inst.Light:SetFalloff(dispersal_light_str[inst.brightness].falloff)
    inst.Light:SetIntensity(dispersal_light_str[inst.brightness].intensity)

    inst:DoTaskInTime(0.5,function()
	inst.Light:SetRadius(light_str[inst.brightness].radius)
	inst.Light:SetFalloff(light_str[inst.brightness].falloff)
	inst.Light:SetIntensity(light_str[inst.brightness].intensity)
    end)

    local num = math.random(10)
    inst.glowshroomDispersalTask = inst:DoTaskInTime(math.random() * 10 + num * 2, dispersal)
end

local function UpdateLightState(inst)
    ClearSoundQueue(inst)

    local sound = sounds_1
    local was_on = IsLightOn(inst)

    inst.Light:SetRadius(light_str[inst.brightness].radius)
    inst.Light:SetFalloff(light_str[inst.brightness].falloff)
    inst.Light:SetIntensity(light_str[inst.brightness].intensity)

    if not was_on then
	inst.Light:Enable(true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end

    if POPULATING then
	inst.AnimState:PlayAnimation("idle")
    else
	inst.AnimState:PlayAnimation("dispersal")
	inst.AnimState:PushAnimation("idle", false)
	inst.SoundEmitter:PlaySound(sound.toggle)
	QueueSound(inst, 13 * FRAMES, sound.colour)

	inst:DoTaskInTime(0.5,function()
	    inst.Light:SetRadius(light_str[inst.brightness].radius)
 	    inst.Light:SetFalloff(light_str[inst.brightness].falloff)
	    inst.Light:SetIntensity(light_str[inst.brightness].intensity)
	end)
    end

    local num = math.random(10)
    inst.glowshroomDispersalTask = inst:DoTaskInTime(math.random() * 10 + num * 2, dispersal)
end

local function OnSave(inst, data)
    data.typeid = inst.typeid
end

local function OnLoad(inst, data)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end
end

local function OnInit(inst)
    if inst.typeid == 0 then
	inst:Remove()
    else
	ClearSoundQueue(inst)
	inst.SoundEmitter:PlaySound(sounds_1.craft)
	UpdateLightState(inst)
    end
end

local function MakeMushroomLight(name, flip, light)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

	local scale = 1
        inst.Transform:SetScale(scale, scale, scale)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetMultColour(.7, .7, .7, 1)

	if flip == true then
	    inst.AnimState:SetScale(-1,1)
	end

        inst.Light:SetColour(.65, .65, .5)
        inst.Light:Enable(false)

        inst:AddTag("lamp")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

	inst.typeid = 0
	inst.brightness = light
	inst.glowshroomDispersalTask = nil
	inst.task = inst:DoTaskInTime(0, OnInit)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeMushroomLight("sdf_pumpkin_gorge_well_glowshroom1", false, 1), MakeMushroomLight("sdf_pumpkin_gorge_well_glowshroom2", true, 2)
