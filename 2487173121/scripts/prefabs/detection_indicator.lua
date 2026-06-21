local assets = {
    Asset("ANIM", "anim/detection_indicators.zip"),
}
local function SetStatus(inst, status)
    if status == "alert" then
        inst.AnimState:PlayAnimation("Detected", true)
    elseif status == "danger" then
        inst.AnimState:PlayAnimation("Suspects", true)
    else
        inst.AnimState:PlayAnimation("Not_detected", true)
    end
    inst._current_status = status
end
local function SetCountdown(inst, countdown)
    inst._countdown = countdown
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("detection")
    inst.AnimState:SetBuild("detection_indicators")
    inst.AnimState:PlayAnimation("Not_detected", true)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetScale(0.4, 0.4, 0.4)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")
    inst.SetStatus = SetStatus
    inst.SetCountdown = SetCountdown
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    return inst
end
return Prefab("detection_indicator", fn, assets)
