local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_earth_rune.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_earth_rune.tex"),

    Asset("ATLAS", "images/map_icons/sdf_earth_rune_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_earth_rune_mm.tex"),

    Asset("ANIM", "anim/sdf_earth_rune.zip"),
}

prefabs = {
}

--Special Trait Normal
local function addRuneTraitNormal(inst, owner)
    inst.components.armor:SetAbsorption(TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_NORMAL)
end

local function removeRuneTraitNormal(inst, owner)
    inst.components.armor:SetAbsorption(0)
end

local function onequip(inst, owner)
    addRuneTraitNormal(inst, owner)
end

local function onunequip(inst, owner)
    removeRuneTraitNormal(inst, owner)
end

local function OnPickupFn(inst, pickupguy)
    if pickupguy.prefab == "sdf" then

	--Resets edible if off
	if inst.components.equippable then
	    inst:RemoveComponent("equippable")
	end
    else
	if inst.components.equippable == nil then
	    inst:AddComponent("equippable")
	    inst.components.equippable.equipslot = EQUIPSLOTS.RUNE
	    inst.components.equippable:SetOnEquip(onequip)
	    inst.components.equippable:SetOnUnequip(onunequip)
	end
    end
end

local function OnLoad(inst, data)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner and owner.prefab == "sdf" then
	inst:RemoveComponent("equippable")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_earth_rune_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_earth_rune")
    inst.AnimState:SetBuild("sdf_earth_rune")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh")

    inst:AddTag("hide_percentage")
    inst:AddTag("sdf_rune")
    inst:AddTag("sdf_earth_rune")

    MakeInventoryFloatable(inst, "med", 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_earth_rune"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_earth_rune.xml"

    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(0)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.RUNE
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_earth_rune", fn, assets)