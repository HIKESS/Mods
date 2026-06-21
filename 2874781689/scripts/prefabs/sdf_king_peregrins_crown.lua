local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_king_peregrins_crown.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_king_peregrins_crown.tex"),

    Asset("ATLAS", "images/map_icons/sdf_king_peregrins_crown_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_king_peregrins_crown_mm.tex"),

    Asset("ANIM", "anim/sdf_king_peregrins_crown.zip"),
}

prefabs = {
}

local function crownRegen(inst)
    local currentDurability = inst.components.finiteuses:GetPercent()
    if currentDurability < 1 then
	inst.components.finiteuses:SetPercent(currentDurability + TUNING.SDF_KING_PEREGRINS_CROWN_REGEN)
    end
end

local function OnCharged(inst)
    inst.components.spellcaster.canusefrominventory = true
end

local function OnDischarged(inst)
    inst.components.spellcaster.canusefrominventory = false
end

local function crownCallToArms(inst, target)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil or owner.prefab ~= "sdf" then
        return
    end

    local currentDurability = inst.components.finiteuses:GetUses()
    if currentDurability >= TUNING.SDF_KING_PEREGRINS_CROWN_USAGE then
	owner:PushEvent("sdf_king_peregrins_crown_calltoarms")

	--Apply Cooldown
	inst.components.rechargeable:Discharge(TUNING.SDF_KING_PEREGRINS_CROWN_COOLDOWN)

	--Resource Cost
	inst.components.finiteuses:Use(TUNING.SDF_KING_PEREGRINS_CROWN_USAGE)
    end
end

local function OnPickupFn(inst, pickupguy)
    if pickupguy.prefab == "sdf" then

	--Resets spellcaster if off
	if inst.components.spellcaster == nil then
	    inst:AddComponent("spellcaster")
	end
	inst.components.spellcaster:SetSpellFn(crownCallToArms)
	inst.components.spellcaster.canusefrominventory = true
    else
	inst:RemoveComponent("spellcaster")
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_king_peregrins_crown_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.spelltype = "SDF_KING_PEREGRINS_CROWN_CALLTOARMS"

    inst.AnimState:SetBank("sdf_king_peregrins_crown")
    inst.AnimState:SetBuild("sdf_king_peregrins_crown")
    inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    MakeInventoryFloatable(inst, "med", 0.25)

    --inst:AddTag("mermbuffcast")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    --Allows offering King Peregrins Ghost
    inst:AddComponent("sdf_king_peregrins_crown_offering_king_peregrin")

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(crownCallToArms)
    inst.components.spellcaster.canusefrominventory = true

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_KING_PEREGRINS_CROWN_DURABILITY)
    inst.components.finiteuses.SetUses = function(self,val)
	self.current = val
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	if self.current <= 0 then
	end
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_king_peregrins_crown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_king_peregrins_crown.xml"

    MakeHauntableLaunch(inst)

    inst.crownRegentask = inst:DoPeriodicTask(30, function() crownRegen(inst) end)

    return inst
end

local function OnPutInInventory(inst, owner)
    inst:DoTaskInTime(0, function()
	if owner ~= nil then
	    if owner:HasTag("sdf") then
		if owner.components.sdf_key_item_inventory:GetKeyItem("sdf_king_peregrins_crown_lost") == nil then
		    owner.components.sdf_key_item_inventory:SetKeyItem(inst, owner)
		end
	    end
	end
    end)
end

local function fn2()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_king_peregrins_crown_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_king_peregrins_crown")
    inst.AnimState:SetBuild("sdf_king_peregrins_crown")
    inst.AnimState:PlayAnimation("idle",true)
    --inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    MakeInventoryFloatable(inst, "med", 0.25)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    --Allows spawning King Peregrins Ghost and trade
    inst:AddComponent("sdf_king_peregrins_crown_lost_offering_king_peregrin")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_king_peregrins_crown"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_king_peregrins_crown.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_king_peregrins_crown", fn, assets, prefabs),
	Prefab("common/inventory/sdf_king_peregrins_crown_lost", fn2, assets, prefabs)