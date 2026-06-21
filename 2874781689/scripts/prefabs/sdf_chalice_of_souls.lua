local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_chalice_of_souls.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_chalice_of_souls.tex"),

    Asset("ATLAS", "images/map_icons/sdf_chalice_of_souls_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chalice_of_souls_mm.tex"),

    Asset("ANIM", "anim/sdf_chalice_of_souls.zip"),
}

prefabs = {
}

local function onload(inst, data)
    inst.keyID = inst.components.sdf_chalice_id_key:GetKey()
    if inst.keyID > 0 then
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
	inst.components.inspectable:SetDescription("Many dispatched souls swirl about...\n Collected from the "..(inst.keyID).."th Altar.")
    end
end


local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chalice_of_souls_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_chalice_of_souls")
    inst.AnimState:SetBuild("sdf_chalice_of_souls")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("sdf_chalice_of_souls")

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows trading with merchant_runestone
    inst:AddComponent("sdf_runestone_offering")

    --Assigns unlocking key for chalice collecting
    inst:AddComponent("sdf_chalice_id_key")
    inst.keyID = inst.components.sdf_chalice_id_key:GetKey()

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_chalice_of_souls"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_chalice_of_souls.xml"

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload

    return inst
end

return  Prefab("common/inventory/sdf_chalice_of_souls", fn, assets, prefabs)