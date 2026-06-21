local assets =
{
    Asset("ANIM", "anim/gw_yifu_yuanding.zip"),
	Asset("ATLAS", "images/inventoryimages/gw_yifu_yuanding.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_yifu_yuanding.tex"),

    Asset("ANIM", "anim/gw_maozi_yuanding.zip"),
	Asset("ATLAS", "images/inventoryimages/gw_maozi_yuanding.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_maozi_yuanding.tex"),
}

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----衣服
local function OnBlocked(owner, data) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip_yifu(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "gw_yifu_yuanding", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)

	if owner and owner.components.inventory then
		for k,v in pairs(owner.components.inventory.equipslots) do
			if v and v.prefab == "gw_maozi_yuanding" then
				if not owner:HasTag("plantkin") then
					owner:AddTag("plantkin")
					owner.gw_taozhuang_yuanding_plantkin = true
				end
				owner.gw_taozhuang_yuanding = true
			end
		end
	end

	if inst.components.fueled ~= nil and owner:HasTag("player") then
		inst.components.fueled:StartConsuming()
	end
end

local function onunequip_yifu(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)

	if owner.gw_taozhuang_yuanding_plantkin ~= nil then
		owner.gw_taozhuang_yuanding_plantkin = nil
		owner:RemoveTag("plantkin")
	end
	owner.gw_taozhuang_yuanding = nil

	if inst.components.fueled ~= nil then
		inst.components.fueled:StopConsuming()
	end
end

local function gw_yifufn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .15, 0.71)

    inst.AnimState:SetBank("gw_yifu_yuanding")
    inst.AnimState:SetBuild("gw_yifu_yuanding")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("gw_fuzhuang")
	inst:AddTag("show_broken_ui")

    inst.foleysound = "dontstarve/movement/foley/logarmour"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_yifu_yuanding.xml"
    
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BELLY or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip_yifu)
    inst.components.equippable:SetOnUnequip(onunequip_yifu)
	inst.components.equippable.walkspeedmult = 1.1

	inst:AddComponent("insulator") 
    inst.components.insulator:SetInsulation(180)
	inst.components.insulator:SetWinter()

	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
	inst.components.fueled:SetDepletedFn(inst.Remove)

	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.6)

    MakeHauntableLaunch(inst)

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----帽子
local function stopusingplantregistry(inst, data)
	local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
	if hat ~= nil and data.statename ~= "plantregistry_open" then
		hat.components.useableitem:StopUsingItem()
	end
end

local function onequip_maozi(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_hat", "gw_maozi_yuanding", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
		owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAT")
	end

	if owner and owner.components.inventory then
		for k,v in pairs(owner.components.inventory.equipslots) do
			if v and v.prefab == "gw_yifu_yuanding" then
				if not owner:HasTag("plantkin") then
					owner:AddTag("plantkin")
					owner.gw_taozhuang_yuanding_plantkin = true
				end
				owner.gw_taozhuang_yuanding = true
			end
		end
	end

	inst:ListenForEvent("newstate", stopusingplantregistry, owner)

	if inst.components.fueled ~= nil and owner:HasTag("player") then
		inst.components.fueled:StartConsuming()
	end
end

local function onunequip_maozi(inst, owner)
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	if owner.gw_taozhuang_yuanding_plantkin ~= nil then
		owner.gw_taozhuang_yuanding_plantkin = nil
		owner:RemoveTag("plantkin")
	end
	owner.gw_taozhuang_yuanding = nil

	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAT")
	end

	inst:RemoveEventCallback("newstate", stopusingplantregistry, owner)

	if inst.components.fueled ~= nil then
		inst.components.fueled:StopConsuming()
	end
end

local function plantregistry_onuse(inst)
	local owner = inst.components.inventoryitem.owner
	if owner then
		if not CanEntitySeeTarget(owner, inst) then return false end
		owner.sg:GoToState("plantregistry_open")
		owner:ShowPopUp(POPUPS.PLANTREGISTRY, true)
	end
end


local function gw_maozifn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .15, 0.71)

    inst.AnimState:SetBank("gw_maozi_yuanding")
    inst.AnimState:SetBuild("gw_maozi_yuanding")
    inst.AnimState:PlayAnimation("anim")

	inst:AddTag("hat")
	inst:AddTag("hide")
	inst:AddTag("gw_fuzhuang")
	inst:AddTag("show_broken_ui")
	inst:AddTag("plantinspector")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_maozi_yuanding.xml"

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnUnequip(onunequip_maozi)
	inst.components.equippable:SetOnEquip(onequip_maozi)
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.USAGE
	inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
	inst.components.fueled:SetDepletedFn(inst.Remove)

	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.4)

	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(plantregistry_onuse)

    inst:AddComponent("tradable")

	MakeHauntableLaunchAndPerish(inst)

    return inst
end 


----------------------------------------------------------------------
return Prefab("gw_yifu_yuanding", gw_yifufn, assets),
		Prefab("gw_maozi_yuanding", gw_maozifn, assets)