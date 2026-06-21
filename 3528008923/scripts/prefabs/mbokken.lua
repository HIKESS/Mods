local assets=
{
    Asset("ANIM", "anim/mbokken.zip"),   
    Asset("ANIM", "anim/swap_mbokken.zip"),
    
    Asset("ATLAS", "images/inventoryimages/mbokken.xml"),
    Asset("IMAGE", "images/inventoryimages/mbokken.tex"),	
}

local function OnEquip(inst, owner)	
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	owner.AnimState:OverrideSymbol("swap_object", "swap_mbokken", "swap_object")
	
	if owner and owner.katanauser then owner.kenjutsurate = 1 end

end
  
local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	if owner and owner.kenjutsurate then owner.kenjutsurate = nil end
end

local function SpawnIaislash(owner, target)	
	local x,y,z = target.Transform:GetWorldPosition()	
	local fx = SpawnPrefab("mevileyes_iaislash_fx")
		
	fx.Transform:SetPosition(x,1,z)			
	fx.Transform:SetRotation(owner.Transform:GetRotation())
end

local function onattack(inst, owner, target)
	if owner.components.rider:IsRiding() then return end
			
	if not inst.hitfx and owner.katanauser then
		SpawnIaislash(owner, target) 
		inst.hitfx = inst:DoTaskInTime(0.2, function() inst.hitfx = nil end)
	end	
end

local function fn()  
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()	
    
    MakeInventoryPhysics(inst)  
      
    inst.AnimState:SetBank("mbokken")
    inst.AnimState:SetBuild("mbokken")
    inst.AnimState:PlayAnimation("anim")
    
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
	inst.entity:SetPristine()
	inst:AddTag("mtachi")
	
    if not TheWorld.ismastersim then
        return inst
    end      

    inst:AddComponent("weapon")	
	inst.components.weapon:SetDamage(15)
	inst.components.weapon:SetOnAttack(onattack)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(150)
    inst.components.finiteuses:SetUses(150)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
	
    inst:AddComponent("inspectable")    
    inst:AddComponent("inventoryitem")
	
    inst.components.inventoryitem.imagename = "mbokken"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mbokken.xml"	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )	
	
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_FUEL

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)		
	MakeSmallPropagator(inst)
	
	MakeHauntableLaunch(inst)		
    return inst
end

return  Prefab("common/inventory/mbokken", fn, assets) 