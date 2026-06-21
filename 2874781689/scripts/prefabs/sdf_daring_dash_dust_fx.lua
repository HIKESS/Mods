local assets =
{
    Asset("ANIM", "anim/sdf_daring_dash_dust.zip"),
}

local prefs = {
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local scale = 0.4
    inst.AnimState:SetScale(scale, scale)

    inst.AnimState:SetBank("sdf_daring_dash_dust")
    inst.AnimState:SetBuild("sdf_daring_dash_dust")
    inst.AnimState:PlayAnimation("anim", true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:DoTaskInTime(0.7, inst.Remove)

    return inst
end

return Prefab("sdf_daring_dash_dust_fx", fn, assets)