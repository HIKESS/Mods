local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_carnival_token.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_carnival_token.tex"),

    Asset("ATLAS", "images/map_icons/sdf_carnival_token_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_carnival_token_mm.tex"),

    Asset("ANIM", "anim/sdf_carnival_token.zip"),
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

    inst.MiniMapEntity:SetIcon("sdf_carnival_token_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_carnival_token")
    inst.AnimState:SetBuild("sdf_carnival_token")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_carnival_token"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_carnival_token.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_CARNIVAL_TOKEN_MAXSTACKCOUNT

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_carnival_token", fn, assets)