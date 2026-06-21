local assets =
{
    Asset("ANIM", "anim/whiteamulet.zip"),
	 Asset("ANIM", "anim/torso_whitegem.zip"),
	Asset("ATLAS", "images/inventoryimages/whiteamulet.xml"),
	Asset("IMAGE", "images/inventoryimages/whiteamulet.tex"),
}
local prefabs = 
{
}
local SLOW_DURATION = 10
local SLOW_MULTIPLIER = 0.60
local function turnoffspeed(target)
	if target:IsValid() and target.components and target.components.locomotor then
		target.components.locomotor:RemoveExternalSpeedMultiplier(target, "whiteamulet_slow")
	end
	if target:IsValid() then
		target:RemoveTag("slowed")
	end
end
local function onslowhit(owner, data)
	local target = data.target
	if target and target:IsValid() and target.components and target.components.locomotor then
		target.components.locomotor:SetExternalSpeedMultiplier(target, "whiteamulet_slow", SLOW_MULTIPLIER)
		target:AddTag("slowed")
		if target._whiteamulet_task then
			target._whiteamulet_task:Cancel()
		end
		target._whiteamulet_task = target:DoTaskInTime(SLOW_DURATION, function(t)
			t._whiteamulet_task = nil
			turnoffspeed(t)
		end)
	end
end
local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "torso_whitegem", "purpleamulet")
	inst:ListenForEvent("onhitother", onslowhit, owner)
	if inst.components.fueled then
		inst.components.fueled:StartConsuming()
	end
end
local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_body")
	inst:RemoveEventCallback("onhitother", onslowhit, owner)
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
    inst.AnimState:SetBank("amulets")
    inst.AnimState:SetBuild("whiteamulet")
    inst.AnimState:PlayAnimation("blueamulet")
	MakeInventoryFloatable(inst, "med", 0.1)
    inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(TUNING.RAINCOAT_PERISHTIME * 0.3)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "whiteamulet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/whiteamulet.xml"
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
	inst.components.equippable.walkspeedmult = 1.1
    inst:AddComponent("heater")
    inst.components.heater:SetThermics(false, true)
    inst.components.heater.equippedheat = TUNING.BLUEGEM_COOLER
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	MakeHauntableLaunch(inst)
	return inst
end
return Prefab( "whiteamulet", fn, assets, prefabs)