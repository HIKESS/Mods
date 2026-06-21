local assets =
{ 
    Asset("ANIM", "anim/gibus.zip"),
    Asset("ANIM", "anim/gibus_swap.zip"),
}

local prefabs = 
{}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "gibus_swap", "swap_hat")	
	
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
        
        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
			owner.AnimState:Show("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end
	
	if inst.components.fueled then
		inst.components.fueled:StartConsuming()
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
			owner.AnimState:Hide("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end
	
	if inst.components.fueled then
		inst.components.fueled:StopConsuming()
	end
end
	
local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gibus")
    inst.AnimState:SetBuild("gibus")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")

    if not TheWorld.ismastersim then
	    return inst
    end

	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.EARMUFF_PERISHTIME)
    inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)
	
	inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_BEEHAT, TUNING.ARMOR_BEEHAT_ABSORPTION)
    inst.components.armor:SetTags({"ghost"})
	
    inst.entity:SetPristine()
    inst:AddComponent("inspectable")
    inst:AddComponent("equippable")
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = ENGINEERITEMIMAGES
--    inst.components.inventoryitem.imagename = "gibus"
--    inst.components.inventoryitem.atlasname = "images/inventoryimages/gibus.xml"

	if CurrentRelease.GreaterOrEqualTo("R08_ROT_TURNOFTIDES") then
	MakeInventoryFloatable(inst, "med", 0.1, 0.65)
	end

	MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/gibus", fn, assets, prefabs)