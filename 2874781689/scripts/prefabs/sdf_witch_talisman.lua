local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_witch_talisman.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_witch_talisman.tex"),

    Asset("ATLAS", "images/map_icons/sdf_witch_talisman_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_witch_talisman_mm.tex"),

    Asset("ANIM", "anim/sdf_witch_talisman.zip"),
}

prefabs = {
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_witch_talisman_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_witch_talisman")
    inst.AnimState:SetBuild("sdf_witch_talisman")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows reseting chalice altars, Sdf statue, merchant gargoyle, Information gargoyle, Jack of the green
    inst:AddComponent("sdf_witch_talisman_offering_chalice_altar")
    inst:AddComponent("sdf_witch_talisman_offering_statue_sdf")
    inst:AddComponent("sdf_witch_talisman_offering_merchant_gargoyle")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_spawn")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_hoh")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_hg")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_mcm")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_pg")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_ee")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_sdt")
    inst:AddComponent("sdf_witch_talisman_offering_information_gargoyle_cc")
    inst:AddComponent("sdf_witch_talisman_offering_king_peregrin")
    inst:AddComponent("sdf_witch_talisman_offering_jack_of_the_green")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_witch_talisman"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_witch_talisman.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_witch_talisman", fn, assets)