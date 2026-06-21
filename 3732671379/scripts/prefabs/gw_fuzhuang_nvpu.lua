local assets =
{
    Asset("ANIM", "anim/gw_yifu_nvpu.zip"),
	Asset("ATLAS", "images/inventoryimages/gw_yifu_nvpu.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_yifu_nvpu.tex"),

    Asset("ANIM", "anim/gw_maozi_nvpu.zip"),
	Asset("ATLAS", "images/inventoryimages/gw_maozi_nvpu.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_maozi_nvpu.tex"),
}

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----衣服
local function OnBlocked(owner, data) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local SHADOWCREATURE_MUST_TAGS = { "shadowcreature", "_combat", "locomotor" }
local SHADOWCREATURE_CANT_TAGS = { "INLIMBO", "notaunt" }
local function OnReadFn(inst, book)
    if inst.components.sanity:IsInsane() then
        
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 16, SHADOWCREATURE_MUST_TAGS, SHADOWCREATURE_CANT_TAGS)

        if #ents < TUNING.BOOK_MAX_SHADOWCREATURES then
            TheWorld.components.shadowcreaturespawner:SpawnShadowCreature(inst)
        end
    end
end

local function onequip_yifu(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "gw_yifu_nvpu", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)

	if owner and owner.components.inventory then
		for k,v in pairs(owner.components.inventory.equipslots) do
			if v and v.prefab == "gw_maozi_nvpu" then
				if not owner:HasTag("bookbuilder") then
				    owner:AddTag("bookbuilder")
					owner.gw_taozhuang_nvpu = true
				end
				if not owner:HasTag("reader") then
					owner:AddTag("reader")
				end
				if owner.components.reader == nil then
					owner:AddComponent("reader")
    				owner.components.reader:SetOnReadFn(OnReadFn)
				end
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

	owner.gw_taozhuang_nvpu = nil

	if owner:HasTag("bookbuilder") then
		owner:RemoveTag("bookbuilder")
	end

	if owner:HasTag("reader") then
		owner:RemoveTag("reader")
	end
	
	if owner.components.reader ~= nil then
		owner:RemoveComponent("reader")
	end

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

    inst.AnimState:SetBank("gw_yifu_nvpu")
    inst.AnimState:SetBuild("gw_yifu_nvpu")
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
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_yifu_nvpu.xml"
    
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

local function onequip_maozi(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_hat", "gw_maozi_nvpu", "swap_hat")
	owner.AnimState:Show("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	owner.AnimState:Show("HEAD")
	owner.AnimState:Hide("HEAD_HAIR")
	
	if owner and owner.components.inventory then
		for k,v in pairs(owner.components.inventory.equipslots) do
			if v and v.prefab == "gw_yifu_nvpu" then
				if not owner:HasTag("bookbuilder") then
				    owner:AddTag("bookbuilder")
					owner.gw_taozhuang_nvpu = true
				end
				if not owner:HasTag("reader") then
					owner:AddTag("reader")
				end
				if owner.components.reader == nil then
					owner:AddComponent("reader")
    				owner.components.reader:SetOnReadFn(OnReadFn)
				end
			end
		end
	end

	if inst.components.fueled ~= nil and owner:HasTag("player") then
		inst.components.fueled:StartConsuming()
	end
end

local function onunequip_maozi(inst, owner)
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")

	owner.gw_taozhuang_nvpu = nil

	if owner:HasTag("bookbuilder") then
		owner:RemoveTag("bookbuilder")
	end

	if owner:HasTag("reader") then
		owner:RemoveTag("reader")
	end

	if owner.components.reader ~= nil then
		owner:RemoveComponent("reader")
	end

	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAT")
	end


	if inst.components.fueled ~= nil then
		inst.components.fueled:StopConsuming()
	end
end


local function gw_maozifn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .15, 0.71)

    inst.AnimState:SetBank("gw_maozi_nvpu")
    inst.AnimState:SetBuild("gw_maozi_nvpu")
    inst.AnimState:PlayAnimation("anim")

	inst:AddTag("hat")
	inst:AddTag("hide")
	inst:AddTag("gw_fuzhuang")
	inst:AddTag("show_broken_ui")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_maozi_nvpu.xml"

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

    inst:AddComponent("tradable")

	MakeHauntableLaunchAndPerish(inst)

    return inst
end 


----------------------------------------------------------------------
return Prefab("gw_yifu_nvpu", gw_yifufn, assets),
		Prefab("gw_maozi_nvpu", gw_maozifn, assets)