local assets=
{ 
    Asset("ANIM", "anim/mevileyes_helmet.zip"),
    Asset("ANIM", "anim/mevileyes_helmet_swap.zip"),

    Asset("ATLAS", "images/inventoryimages/mevileyes_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/mevileyes_helmet.tex"),
}

local prefabs = {}

local function DoRegen(inst, owner)
	local skilltreeupdater = owner and owner.components.skilltreeupdater or nil
	if owner.components.sanity ~= nil then -- and owner.components.sanity:IsInsanityMode()
		local skillbonus = skilltreeupdater and skilltreeupdater:IsActivated("mevileyes_samuraix") and TUNING.ARMOR_DREADSTONE_REGEN_SETBONUS*1.5 or 1
		local rate = 1 / Lerp(1 / TUNING.ARMOR_DREADSTONE_REGEN_MAXRATE, 1 / TUNING.ARMOR_DREADSTONE_REGEN_MINRATE, owner.components.sanity:GetPercent())
		inst.components.armor:Repair(inst.components.armor.maxcondition * rate * skillbonus)
	end
	if not inst.components.armor:IsDamaged() then
		inst.regentask:Cancel()
		inst.regentask = nil
	end
end

local function StartRegen(inst, owner)
	if inst.regentask == nil then
		inst.regentask = inst:DoPeriodicTask(TUNING.ARMOR_DREADSTONE_REGEN_PERIOD, DoRegen, nil, owner)
	end
end

local function StopRegen(inst)
	if inst.regentask ~= nil then
		inst.regentask:Cancel()
		inst.regentask = nil
	end
end

local function OnEquip(inst, owner)
	if owner.components.sanity ~= nil and inst.components.armor:IsDamaged() then
		StartRegen(inst, owner)
	else
		StopRegen(inst)
	end
	
	owner.AnimState:OverrideSymbol("swap_hat", "mevileyes_helmet_swap", "swap_hat")
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

end

local function OnUnequip(inst, owner)
	StopRegen(inst)
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
end

local function OnTakeDamage(inst, amount)
	if inst.regentask == nil and inst.components.equippable:IsEquipped() then
		local owner = inst.components.inventoryitem.owner
		if owner ~= nil and owner.components.sanity ~= nil then
			StartRegen(inst, owner)
		end
	end
end

local function CalcDapperness(inst, owner)
	local skilltreeupdater = owner and owner.components.skilltreeupdater or nil
	local insanity = owner.components.sanity ~= nil --and owner.components.sanity:IsInsanityMode()
	if skilltreeupdater and skilltreeupdater:IsActivated("mevileyes_samuraixx") then
		return (insanity and inst.regentask ~= nil and TUNING.CRAZINESS_MED or 0)* 0.5
	end
	return insanity and inst.regentask ~= nil and TUNING.CRAZINESS_MED or 0
end

local function shogun_onsetbonus_enabled(inst)
    inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMOR_VOIDCLOTH_SETBONUS_SHADOW_RESIST, "setbonus")
end

local function shogun_onsetbonus_disabled(inst)
    inst.components.damagetyperesist:RemoveResist("shadow_aligned", inst, "setbonus")
 end
	
local function fn()
 local inst = CreateEntity()
	
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("mevileyes_helmet.tex")
	
	inst:AddTag("heavyarmor")
	inst:AddTag("hat")
	inst:AddTag("shadowlevel")
	
    MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("mevileyes_helmet")  
    inst.AnimState:SetBuild("mevileyes_helmet")
    inst.AnimState:PlayAnimation("idle")	
		
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("med")
    inst.components.floater:SetVerticalOffset(0.1)

	
	if not TheWorld.ismastersim then
        return inst
    end
		
	
	inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mevileyes_helmet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mevileyes_helmet.xml"	
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORDREADSTONE*1.2, TUNING.ARMOR_DREADSTONEHAT_ABSORPTION)
	inst.components.armor.ontakedamage = OnTakeDamage
	
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)   
    
	inst:AddComponent("planardefense")
	inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_VOIDCLOTH_HAT_PLANAR_DEF)

	inst:AddComponent("damagetyperesist")
	inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.ARMOR_VOIDCLOTH_SHADOW_RESIST)

	inst:AddComponent("shadowlevel")
	inst.components.shadowlevel:SetDefaultLevel(3)

    local setbonus = inst:AddComponent("setbonus")
    setbonus:SetSetName(EQUIPMENTSETNAMES.VOIDCLOTH)
    setbonus:SetOnEnabledFn(shogun_onsetbonus_enabled)
    setbonus:SetOnDisabledFn(shogun_onsetbonus_disabled)
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable.dapperfn = CalcDapperness
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	
	MakeHauntableLaunch(inst)
    return inst
end

return  Prefab("common/inventory/mevileyes_helmet", fn, assets, prefabs)