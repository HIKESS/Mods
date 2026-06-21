local assets=
{     
    Asset("ATLAS", "images/inventoryimages/mevileyes_inner_head.xml"),
    Asset("IMAGE", "images/inventoryimages/mevileyes_inner_head.tex"),
	Asset("ANIM", "anim/mevileyes_miburo_hb.zip"),   
}

local prefabs = {}

local function CheckIfUnequipped(inst)
	if not inst.components.equippable:IsEquipped() then
		local owner = inst.components.inventoryitem.owner
		if owner and owner.components.inventory then
			owner.components.inventory:Equip(inst)
		else
			inst:Remove()
		end
		
	end
end

local function ApplyOverride(inst, owner)
    if owner ~= nil and owner.AnimState ~= nil then
        if owner.AnimState:GetBuild() == "mevileyes_miburo" then
            owner.AnimState:OverrideSymbol("swap_hat", "mevileyes_miburo_hb", "swap_hat")
			owner.AnimState:Show("HAT")
		else owner.AnimState:ClearOverrideSymbol("swap_hat")   
        end
    end
end
	
local function OnEquip(inst, owner)	
	if owner ~= nil then       
        ApplyOverride(inst, owner)       
        owner:DoTaskInTime(1, function()
            if inst.components.equippable ~= nil 
               and inst.components.equippable:IsEquipped() then
                ApplyOverride(inst, owner)
            end
        end)
    end

	inst._onskinschanged = function(owner)
		ApplyOverride(inst, owner)
	end
	
	owner:ListenForEvent("onskinschanged", inst._onskinschanged)
	
	if owner then
		local skilltreeupdater = owner.components.skilltreeupdater		
			if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_shadow_armor") then 
				inst:AddComponent("planardefense")
				inst.components.planardefense:SetBaseDefense(5) 
				inst.components.equippable.walkspeedmult = 1.05
			end
	end
	
end

local function OnUnequip(inst, owner)

	if inst._onskinschanged ~= nil then
        owner:RemoveEventCallback("onskinschanged", inst._onskinschanged)
        inst._onskinschanged = nil
    end
	
	owner.AnimState:ClearOverrideSymbol("swap_hat")   
	
	inst:DoTaskInTime(0, inst.Remove)   
end
	
local function fn()
 local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mevileyes_inner_head"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mevileyes_inner_head.xml"	
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORWOOD, TUNING.ARMORWOOD_ABSORPTION)
	
	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.ARMOR_SANITY_SHADOW_LEVEL)
    
	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
	inst:DoTaskInTime(0, CheckIfUnequipped)
	
    return inst
end

return  Prefab("common/inventory/mevileyes_inner_head", fn, assets, prefabs)	