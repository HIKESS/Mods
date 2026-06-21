local assets = {
    Asset("ATLAS", "images/inventoryimages/sdf_victorian_suit.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_victorian_suit.tex"),

    Asset("ANIM", "anim/sdf_victorian_suit.zip"),
}

prefabs = {
}

local function onperish (inst, owner)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
	inst:Remove()
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "sdf_victorian_suit", "swap_body")
    if owner.prefab == "sdf" then

	--Set Bonus Gentleman SDF Only
	local handItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handItem then
	    if handItem.prefab == "sdf_cane_stick" then
		handItem:SetBonusGentlemanActivateFn()
	    end

	    --Update Arm icon and texture
	    if handItem.prefab == "sdf_arm" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_victorian_arm", "swap_sdf_victorian_arm")

		handItem.AnimState:SetBank("sdf_victorian_arm")
		handItem.AnimState:SetBuild("sdf_victorian_arm")
		handItem.components.inventoryitem.imagename = "sdf_victorian_arm"
		handItem.components.inventoryitem.atlasname = "images/inventoryimages/sdf_victorian_arm.xml"
	    end
	end


	local helmItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

	--Skill Tree Eye of Amon Ra
	if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
	    owner:MakeVictorianSuitEye()
	else
	    owner:MakeVictorianSuit()
	end


	--Check for helm
	inst:DoTaskInTime(0.1, function()
	    if helmItem then
		if helmItem.prefab == "sdf_helmet" then
		    helmItem.components.equippable.onequipfn(helmItem, owner)
		end
	    end
	end)
    else
	inst:DoTaskInTime(0.1, function()
	    local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	    if body then
		if owner.components.talker then owner.components.talker:Say(GetString(owner, "ANNOUNCE_NODANIELSUIT")) end
		    local item = owner.components.inventory:Unequip(body.components.equippable.equipslot)
		    owner.components.inventory:GiveItem(item)
		end
	    end)
    end
    if inst.components.fueled then
	inst.components.fueled:StartConsuming()
    end
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.prefab == "sdf" then

	--Set Bonus Gentleman SDF Only
	local handItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handItem then
	    if handItem.prefab == "sdf_cane_stick" then
		handItem:SetBonusGentlemanDeactivateFn()
	    end

	    --Update Arm icon and texture
	    if handItem.prefab == "sdf_arm" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_arm", "swap_sdf_arm")

		handItem.AnimState:SetBank("sdf_arm")
		handItem.AnimState:SetBuild("sdf_arm")
		handItem.components.inventoryitem.imagename = "sdf_arm"
		handItem.components.inventoryitem.atlasname = "images/inventoryimages/sdf_arm.xml"
	    end
	end


	local helmItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

	--Skill Tree Eye of Amon Ra
	if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
	    owner:MakeNormalArmorEye()
	else
	    owner:MakeNormalArmor()
	end
	
	--Check for helm
	inst:DoTaskInTime(0.1, function()
	    if helmItem then
		if helmItem.prefab == "sdf_helmet" then
		    helmItem.components.equippable.onequipfn(helmItem, owner)
		end
	    end
	end)
    end

    if inst.components.fueled then
	inst.components.fueled:StopConsuming()
    end
end

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("sdf_victorian_suit")
    inst.AnimState:SetBuild("sdf_victorian_suit")
    inst.AnimState:PlayAnimation("anim")
	
    inst:AddTag("armor")

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_victorian_suit"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_victorian_suit.xml"
    
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.SDF_VICTORIAN_SUIT_DURABILITY) --10 days
    inst.components.fueled:SetDepletedFn(onperish)
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED	
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)	

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab( "common/inventory/sdf_victorian_suit", fn, assets) 