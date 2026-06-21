local assets=
{ 
    
    Asset("ATLAS", "images/inventoryimages/mevileyes_inner_armor.xml"),
    Asset("IMAGE", "images/inventoryimages/mevileyes_inner_armor.tex"),
	Asset("ANIM", "anim/mevileyes_miko_robe.zip"),

}

local prefabs = {}

local function voidcloth_applyitembuff(inst, item, stacks)
	if item.components.planardamage ~= nil then
		if stacks > 0 then
			local bonus = Remap(stacks, 0, TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_MAX_HITS, 0, TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_MAX)
			item.components.planardamage:AddBonus(inst, bonus, "voidclothhat_rampingbuff")
		else
			item.components.planardamage:RemoveBonus(inst, "voidclothhat_rampingbuff")
		end
	end
end

local function voidcloth_setbuffitem(inst, item)
	if inst.buff_item ~= item then
		if inst.buff_item ~= nil then
			voidcloth_applyitembuff(inst, inst.buff_item, 0)
		end
		inst.buff_item = item
		if item ~= nil then
			voidcloth_applyitembuff(inst, item, inst.buff_stacks)
		end
	end
end

local function voidcloth_resetbuff(inst)
	if inst.decaystacktask ~= nil then
		inst.decaystacktask:Cancel()
		inst.decaystacktask = nil
	end

	inst.buff_stacks = 0
	if inst.buff_item ~= nil then
		voidcloth_applyitembuff(inst, inst.buff_item, 0)
	end
	
end

local function voidcloth_onattackother(inst)	
	if inst.buff_item == nil then
		return
	end

	if inst.decaystacktask ~= nil then
		inst.decaystacktask:Cancel()
	end
	inst.decaystacktask = inst:DoTaskInTime(TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_DECAY_TIME, voidcloth_resetbuff)

	if inst.buff_stacks < TUNING.ARMOR_VOIDCLOTH_SETBONUS_PLANARDAMAGE_MAX_HITS then
		inst.buff_stacks = inst.buff_stacks + 1
		if inst.buff_item ~= nil then
			voidcloth_applyitembuff(inst, inst.buff_item, inst.buff_stacks)
		end
	end

end

local function voidcloth_setbuffowner(inst, owner)
	if inst._owner ~= owner then
		if inst._owner ~= nil then
			inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
			inst:RemoveEventCallback("unequip", inst._onownerunequip, inst._owner)
			inst:RemoveEventCallback("attacked", inst._onattacked, inst._owner)
			inst:RemoveEventCallback("onattackother", inst._onattackother, inst._owner)
			inst._onownerunequip = nil
			inst._onattacked = nil
			inst._onattackother = nil

			voidcloth_setbuffitem(inst, nil)
			voidcloth_resetbuff(inst)
			inst.buff_stacks = nil
		end
		inst._owner = owner
		if owner ~= nil then
			inst._onownerequip = function(owner, data)
			
				if data ~= nil and data.eslot == EQUIPSLOTS.HANDS then
					if data.item ~= nil and data.item.components.planardamage ~= nil and (data.item:HasTag("shadow_item") or data.item:HasTag("netra_item"))then
						voidcloth_setbuffitem(inst, data.item)
					else
						voidcloth_setbuffitem(inst, nil)
					end
				end
			end
			inst._onownerunequip = function(owner, data)
				if data ~= nil and data.eslot == EQUIPSLOTS.HANDS then
					voidcloth_setbuffitem(inst, nil)
				end
			end
			inst._onattacked = function(owner)
				voidcloth_resetbuff(inst)
			end
			inst._onattackother = function(owner)
				voidcloth_onattackother(inst)
			end
			inst:ListenForEvent("equip", inst._onownerequip, owner)
			inst:ListenForEvent("unequip", inst._onownerunequip, owner)
			inst:ListenForEvent("attacked", inst._onattacked, owner)
			inst:ListenForEvent("onattackother", inst._onattackother, owner)

			inst.buff_stacks = 0
			local weapon = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if weapon ~= nil and weapon.components.planardamage ~= nil and (weapon:HasTag("shadow_item") or weapon:HasTag("netra_item")) then
				voidcloth_setbuffitem(inst, weapon)
			end
		end
	end
end

local function ApplyOverride(inst, owner)
    if owner ~= nil and owner.AnimState ~= nil then
        if owner.AnimState:GetBuild() == "mevileyes_miko" then
            owner.AnimState:OverrideSymbol("swap_body", "mevileyes_miko_robe", "swap_body")
        else owner.AnimState:ClearOverrideSymbol("swap_body")
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
	
	if owner.unlockdeathaura then	
		voidcloth_setbuffowner(inst, owner)	
	end
	
	inst._onskinschanged = function(owner)
		ApplyOverride(inst, owner)
	end
	
	owner:ListenForEvent("onskinschanged", inst._onskinschanged)
	
    if owner ~= nil then
        local skilltreeupdater = owner.components.skilltreeupdater
        if skilltreeupdater and skilltreeupdater:IsActivated("mevileyes_shadow_armor") then
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
	
	owner.AnimState:ClearOverrideSymbol("swap_body")
	
	if owner.unlockdeathaura then
		voidcloth_setbuffowner(inst, nil)
	end
	
	inst:DoTaskInTime(0, inst.Remove)
end

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
    inst.components.inventoryitem.imagename = "mevileyes_inner_armor"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mevileyes_inner_armor.xml"	
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORWOOD, TUNING.ARMOR_SANITY_ABSORPTION)
    
	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(TUNING.ARMOR_SANITY_SHADOW_LEVEL)
	
	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
		
	inst:DoTaskInTime(0, CheckIfUnequipped)
	
    return inst
end

return  Prefab("common/inventory/mevileyes_inner_armor", fn, assets, prefabs)	