local assets =
{
    Asset("ANIM", "anim/jx_war_hoe.zip"),
}

local prefabs =
{
    "farm_soil",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "jx_war_hoe", "swap_quagmire_hoe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onfiniteusesfinished(inst)
    if inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner ~= nil then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", { tool = inst })
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("jx_war_hoe")
    inst.AnimState:SetBuild("jx_war_hoe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "med", 0.05, {0.8, 0.4, 0.8})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.JX_TUNING.jx_war_hoe_finiteuses)
    inst.components.finiteuses:SetUses(TUNING.JX_TUNING.jx_war_hoe_finiteuses)
    inst.components.finiteuses:SetOnFinished(onfiniteusesfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.TILL, 1)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    
    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.JX_TUNING.jx_war_hoe_planardamage)

    inst:AddInherentAction(ACTIONS.TILL)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("farmtiller")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)
    
    inst.components.floater:SetBankSwapOnFloat(true, -7, {bank  = "jx_war_hoe", sym_build = "jx_war_hoe", sym_name = "swap_quagmire_hoe"})

    return inst
end

return Prefab("jx_war_hoe", fn, assets, prefabs)