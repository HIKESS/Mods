-- npc_wx78_leap_fx.lua
-- WX-78 NPC 跳劈落地电流范围特效


local assets =
{
    Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    inst.AnimState:PlayAnimation("crackle_projection")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(1.5, 1.5)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(2, inst.Remove)

    return inst
end

return Prefab("npc_wx78_leap_fx", fn, assets)
