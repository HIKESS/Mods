local assets =
{
    Asset("ANIM", "anim/sdf_lightning_shock.zip"),
    Asset("ANIM", "anim/sdf_goodlightning_shock.zip"),
}

local prefabs =
{
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local s = 0.4
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("sdf_lightning_shock")
    inst.AnimState:SetBuild("sdf_lightning_shock")
    inst.AnimState:PlayAnimation("anim", true)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(FINALOFFSET_MAX)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local s = 0.4
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("sdf_goodlightning_shock")
    inst.AnimState:SetBuild("sdf_goodlightning_shock")
    inst.AnimState:PlayAnimation("anim", true)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(FINALOFFSET_MAX)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("sdf_lightning_gauntlet_lightning_fx", fn, assets),
	Prefab("sdf_lightning_gauntlet_goodlightning_fx", fn2, assets)