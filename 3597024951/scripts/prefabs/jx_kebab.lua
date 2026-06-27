local assets =
{
    Asset("ANIM", "anim/jx_kebab.zip"),
}

local function UpdateDamage(inst)
    if inst.components.perishable and inst.components.weapon then
        local dmg = 34 * inst.components.perishable:GetPercent() + 17
        inst.components.weapon:SetDamage(dmg)
    end
end

local function OnLoad(inst)--, data)
    UpdateDamage(inst)
end

local function onequip(inst, owner)
    UpdateDamage(inst)
    owner.AnimState:OverrideSymbol("swap_object", "jx_kebab", "swap_spear")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    UpdateDamage(inst)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("jx_kebab")
    inst.AnimState:SetBuild("jx_kebab")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("show_spoilage")
    inst:AddTag("icebox_valid")
    inst:AddTag("weapon")
    inst:AddTag("jab")

    local swap_data = {sym_build = "jx_kebab", bank = "jx_kebab"}
    MakeInventoryFloatable(inst, "med", nil, {1.0, 0.5, 1.0}, true, -13, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW) -- 15天
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(51)
    inst.components.weapon:SetRange(1)
    inst.components.weapon:SetOnAttack(UpdateDamage)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
    inst.OnLoad = OnLoad
    
    return inst
end

return Prefab("jx_kebab", fn, assets)