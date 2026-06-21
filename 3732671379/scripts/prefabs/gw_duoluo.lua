
local assets =
{
    Asset("ANIM", "anim/gw_duoluo.zip"),
    Asset("ANIM", "anim/swap_duoluo.zip"),
    Asset("ATLAS","images/inventoryimages/gw_duoluo.xml"),
	Asset("IMAGE","images/inventoryimages/gw_duoluo.tex"),	
}
local prefabs = {}

local cd = 7.8

----摘掉
local function UnEquip(inst, owner)
	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	if owner ~= nil and owner.components.inventory ~= nil and owner.components.inventory.isopen then
		local container = inst.components.inventoryitem:GetContainer()
		if container ~= nil then
			local slot = inst.components.inventoryitem:GetSlotNum()
			container:GiveItem(inst, slot)
		end
	end
end

----开始消耗
local function On_fueled(inst)
	if inst.components.fueled ~= nil then
		inst.components.fueled:StartConsuming()
	end
end

----停止消耗
local function Off_fueled(inst)
	if inst.components.fueled ~= nil then
		inst.components.fueled:StopConsuming()
	end
	inst.AnimState:PlayAnimation("idle",true)
end

----装备
local function onequip(inst, owner) 
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_duoluo", inst.GUID, "swap_duoluo")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_duoluo", "swap_duoluo")
	end

	On_fueled(inst)
end

----脱下
local function onunequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end

	Off_fueled(inst)
end

----续航
local function takefuel(inst)
	--[[local GetPercent = inst.components.fueled and inst.components.fueled:GetPercent()
	GetPercent = GetPercent + .1
	if GetPercent >= 1 then
		GetPercent = 1
	end
	inst.components.fueled:SetPercent(GetPercent)]]

	if not inst.components.equippable then
		inst:AddComponent("equippable")
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)
	end
end

----消耗
local function OnPickup(inst)
	On_fueled(inst)
end

----蓄力暴击
local function onattack(inst, attacker, target, periodic)
	if inst.components.rechargeable:GetTimeToCharge() <= 0 then
		if target ~= nil and target.SoundEmitter ~= nil then
			target.SoundEmitter:PlaySound("dontstarve/common/whip_large")
			local pos = Vector3(target.Transform:GetWorldPosition())
			local fx = SpawnPrefab("impact")
			fx.Transform:SetPosition(pos.x,pos.y+2,pos.z)
			fx.Transform:SetScale(1.5,2,2)
		end
	end
	inst:RemoveTag("jab")
	inst.components.rechargeable:Discharge(cd)
	inst.components.weapon:SetDamage(58.5)
	inst.components.planardamage:SetBaseDamage(10)
end

----cd控制
local function OnChargedFn(inst)
	if inst.components.rechargeable:GetTimeToCharge() > 0 then
		inst:RemoveTag("jab")
		inst.components.weapon:SetDamage(58.5)
		inst.components.planardamage:SetBaseDamage(10)
	else
		inst:AddTag("jab")
		inst.components.weapon:SetDamage(206.5)
		inst.components.planardamage:SetBaseDamage(36.5)
	end
end

----耐久
local function OnDepleted(inst)
	Off_fueled(inst)
	if inst.components.equippable and inst.components.equippable:IsEquipped() then	
		UnEquip(inst)
	end
	if inst.components.equippable then
		inst:RemoveComponent("equippable")
	end
end

local function OnSave(inst, data)
    data.naijiu = inst.components.fueled:GetPercent()
end

local function OnLoad(inst,data)
    if data ~= nil then
        if data and data.naijiu ~= nil then
			if data.naijiu <= 0 then
				if inst.components.equippable then
					inst:RemoveComponent("equippable")
				end
			end
        end
    end
end

local function onUpdate(inst,data)
	local GetPercent = inst.components.fueled and inst.components.fueled:GetPercent()
	if GetPercent > 0 then
		if not inst.components.equippable then
			inst:AddComponent("equippable")
			inst.components.equippable:SetOnEquip(onequip)
			inst.components.equippable:SetOnUnequip(onunequip)
		end
	else
		if inst.components.equippable then
			if inst.components.equippable:IsEquipped() then	
				UnEquip(inst)
			end
			inst:RemoveComponent("equippable")
		end
	end
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

	inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork() 
	inst.entity:AddMiniMapEntity()
    inst.AnimState:SetBank("gw_duoluo")
    inst.AnimState:SetBuild("gw_duoluo")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
	inst:AddTag("weapon")
	inst:AddTag("nopunch")
	inst:AddTag("jab")
	inst:AddTag("gw_weapon")
	inst:AddTag("show_broken_ui")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_duoluo.xml"
	inst.components.inventoryitem.imagename = "gw_duoluo"
	--inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("weapon")    
	inst.components.weapon:SetDamage(206.5)
	inst.components.weapon:SetOnAttack(onattack)

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(36.5)

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(480)
    inst.components.fueled:SetDepletedFn(OnDepleted)
	inst.components.fueled.fueltype = "NIGHTMARE"
	inst.components.fueled.accepting = true
	inst.components.fueled.ontakefuelfn = takefuel
	inst.components.fueled:SetUpdateFn(onUpdate)

	inst:AddTag("rechargeable")
	inst:AddComponent("rechargeable")
	inst.components.rechargeable:SetOnChargedFn(OnChargedFn)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

    return inst
end



----------------------------------------------------------------------
return Prefab("gw_duoluo", fn, assets)