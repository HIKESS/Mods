local assets =
{
    Asset("ANIM", "anim/sdf_eye_of_amon_ra_marker_swirl.zip"),
}

local prefs = {
}

local function goAway(inst)
    inst.AnimState:PlayAnimation("spawn_fx")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("fused_shadeling")
    inst.AnimState:SetBuild("sdf_eye_of_amon_ra_marker_swirl")
    inst.AnimState:PlayAnimation("spawn_fx", true)

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    --inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.entity:SetPristine()

    inst.entity:SetCanSleep(false)
    inst.persists = false

    --inst:ListenForEvent("animover", inst.Remove)
    inst.goAwayFn = function() goAway(inst) end

    return inst
end

return Prefab("sdf_helmet_honor_of_gallowmere_fx", fn, assets)