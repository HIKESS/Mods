local assets = 
{
    Asset("ANIM", "anim/sdf_time_rune_clock_fx.zip"),

}
local MAX_LIGHT_FRAME = 14

local function goAway(inst)
    inst.AnimState:PlayAnimation("despawn")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function OnUpdateLight(inst, dframes)
    local done
    if inst._islighton:value() then
        local frame = inst._lightframe:value() + dframes * (inst.lightupdaterate or 1)
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes*3
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    inst.Light:SetRadius(3.3 * inst._lightframe:value() / MAX_LIGHT_FRAME)

    if done then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddLight()
    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetFalloff(1.5)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)

    inst.Transform:SetScale(-0.8,0.8,0.8)

    inst.AnimState:SetBank("sdf_time_rune_clock_fx")
    inst.AnimState:SetBuild("sdf_time_rune_clock_fx")
    inst.AnimState:PlayAnimation("spawn")
    inst.AnimState:PushAnimation("idle",true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    --inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")
    inst:AddTag("sdf_time_rune_clock_fx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)
        return inst
    end

    inst._lightframe = net_smallbyte(inst.GUID, "portalwatch._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "portalwatch._islighton", "lightdirty")
    inst._lighttask = nil
    inst._islighton:set(true)
    inst.OnLightDirty = OnLightDirty

    OnLightDirty(inst)

    inst.goAwayFn = function() goAway(inst) end

    inst.persists = false

    return inst
end

return Prefab("sdf_time_rune_clock_fx",fn,assets)