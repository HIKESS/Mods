local assets = {
    Asset("ANIM", "anim/mark.zip"),
}
local function PlayMarkAnimation(inst)
    inst.AnimState:PlayAnimation("markers", true)
end
local function PlayEndAnimation(inst)
    inst.AnimState:PlayAnimation("end_markers", false)
    inst:ListenForEvent("animover", function()
        inst:Remove()
    end)
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("mark")
    inst.AnimState:SetBuild("mark")
    inst.AnimState:PlayAnimation("markers", true)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetScale(3, 3, 3)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")
    inst.PlayMarkAnimation = PlayMarkAnimation
    inst.PlayEndAnimation = PlayEndAnimation
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    return inst
end
return Prefab("mark_indicator", fn, assets)
