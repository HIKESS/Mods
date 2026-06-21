local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_shadow_artefact.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_shadow_artefact.tex"),

    Asset("ATLAS", "images/map_icons/sdf_shadow_artefact_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_shadow_artefact_mm.tex"),

    Asset("ANIM", "anim/sdf_shadow_artefact.zip"),
}

prefabs = {
}

local function sanityDrain(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	if owner:HasTag("player") and not owner:HasTag("playerghost") then
	    if owner.components.sanity then
		owner.components.sanity:DoDelta(-TUNING.SDF_SHADOW_ARTEFACT_SANITY_DRAIN)
	    end
	end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddLight()
    inst.Light:SetRadius(0.25)
    inst.Light:SetFalloff(1.0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(40/255,40/255,250/255)	

    inst.MiniMapEntity:SetIcon("sdf_shadow_artefact_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_shadow_artefact")
    inst.AnimState:SetBuild("sdf_shadow_artefact")
    inst.AnimState:PlayAnimation("idle",true)

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows offering with King Peregrins Ghost
    inst:AddComponent("sdf_shadow_artefact_offering_king_peregrin")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_shadow_artefact"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_shadow_artefact.xml"

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SDF_SHADOW_ARTEFACT_SANITY_AURA

    inst.sanityDraintask = inst:DoPeriodicTask(TUNING.SDF_SHADOW_ARTEFACT_SANITY_DRAIN_TICK, function() sanityDrain(inst) end)

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_shadow_artefact", fn, assets)