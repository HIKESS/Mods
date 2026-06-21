local assets =
{
    Asset("ANIM", "anim/gwen_golden_spatula.zip"),     ---金铲铲的
    Asset("ANIM", "anim/swap_gwen_golden_spatula.zip"),

    Asset("ANIM", "anim/gwen_golden_pot.zip"),     ---金锅锅的
    Asset("ANIM", "anim/swap_gwen_golden_pot.zip"),

    Asset("IMAGE", "images/inventoryimages/gwen_golden_spatula.tex"),
    Asset("ATLAS", "images/inventoryimages/gwen_golden_spatula.xml"),
    Asset("IMAGE", "images/inventoryimages/gwen_golden_pot.tex"),
    Asset("ATLAS", "images/inventoryimages/gwen_golden_pot.xml"),
}

local function chan_onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_gwen_golden_spatula", inst.GUID, "swap_gwen_golden_spatula")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_gwen_golden_spatula", "swap_gwen_golden_spatula")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function chan_onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end


local function guo_onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_gwen_golden_pot", inst.GUID, "swap_gwen_golden_pot")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_gwen_golden_pot", "swap_gwen_golden_pot")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function guo_onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end




local function chan_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gwen_golden_spatula")
    inst.AnimState:SetBuild("gwen_golden_spatula")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("gwen_gold_tool")

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gwen_golden_spatula"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gwen_golden_spatula.xml"



    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(chan_onequip)
    inst.components.equippable:SetOnUnequip(chan_onunequip)
    inst.components.equippable.walkspeedmult = 1.25

    MakeHauntableLaunch(inst)

    return inst
end

local function guo_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gwen_golden_pot")
    inst.AnimState:SetBuild("gwen_golden_pot")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("gwen_gold_tool")

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(51)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gwen_golden_pot"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gwen_golden_pot.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(guo_onequip)
    inst.components.equippable:SetOnUnequip(guo_onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("gwen_golden_spatula", chan_fn, assets),
    Prefab("gwen_golden_pot", guo_fn, assets)