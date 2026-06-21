local assets =
{
    Asset("ANIM", "anim/sdf_eye_of_amon_ra_marker_logo.zip"),
    Asset("ANIM", "anim/sdf_eye_of_amon_ra_marker_swirl.zip"),
    Asset("ANIM", "anim/sdf_eye_of_amon_ra_marker_consume.zip"),
}

local item_prefabs = {
}

--local procAnimBank = {"anim1", "anim2", "anim3"}

--local function goProc(inst)
    --inst.AnimState:SetBank("sdf_eye_of_amon_ra_marker_consume")
    --inst.AnimState:SetBuild("sdf_eye_of_amon_ra_marker_consume")
    --inst.AnimState:PlayAnimation(procAnimBank[math.random(#procAnimBank)])
    --inst:ListenForEvent("animover", function() inst:Remove() end)
--end

local function goAway(inst)
    inst.AnimState:PlayAnimation("marker_fx_pst")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("sdf_eye_of_amon_ra_marker_logo")
    inst.AnimState:SetBuild("sdf_eye_of_amon_ra_marker_logo")
    inst.AnimState:PlayAnimation("marker_fx_loop",true)

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    --inst:AddTag("FX")
    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.entity:SetPristine()

    inst.entity:SetCanSleep(false)
    inst.persists = false

    --inst.goProcFn = function() goProc(inst) end
    inst.goAwayFn = function() goAway(inst) end

    return inst
end
---------------------------------------------------

local function fn2()
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

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end
---------------------------------------------------

local consumeProcAnimBank = {"anim1", "anim2", "anim3"}

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("sdf_eye_of_amon_ra_marker_consume")
    inst.AnimState:SetBuild("sdf_eye_of_amon_ra_marker_consume")
    inst.AnimState:PlayAnimation(consumeProcAnimBank[math.random(#consumeProcAnimBank)])

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end
---------------------------------------------------

return Prefab("sdf_eye_of_amon_ra_marker_logo_fx", fn, assets),
	Prefab("sdf_eye_of_amon_ra_marker_swirl_fx", fn2, assets),
	Prefab("sdf_eye_of_amon_ra_marker_consume_fx", fn3, assets)