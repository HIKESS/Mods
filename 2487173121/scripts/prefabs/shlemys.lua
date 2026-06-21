local assets =
{ 
    Asset("ANIM", "anim/shlemys.zip"),
    Asset("ANIM", "anim/swap_shlemys.zip"), 
    Asset("ATLAS", "images/inventoryimages/shlemys.xml"),
    Asset("IMAGE", "images/inventoryimages/shlemys.tex"),
}
local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", "swap_shlemys", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end
end
local function OnUnequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("shlemys")
    inst.AnimState:SetBuild("shlemys")
    inst.AnimState:PlayAnimation("idle")
	MakeInventoryFloatable(inst, "med", 0.1)
    inst:AddTag("hat")
	inst:AddTag("waterproofer")
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "shlemys"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/shlemys.xml"
	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0.40)
	MakeHauntableLaunch(inst)
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(460, 0.8)
    return inst
end
return Prefab( "common/inventory/shlemys", fn, assets)