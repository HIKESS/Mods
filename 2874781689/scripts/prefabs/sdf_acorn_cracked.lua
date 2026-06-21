local assets =
{
    Asset("ATLAS", "images/inventoryimages/sdf_acorn_cracked.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_acorn_cracked.tex"),

    Asset("ANIM", "anim/sdf_acorn_cracked.zip"),
}

local prefabs ={
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_acorn_cracked")
    inst.AnimState:SetBuild("sdf_acorn_cracked")
    inst.AnimState:PlayAnimation("idle")


    inst:AddTag("show_spoilage")
    inst:AddTag("treeseed")
    inst:AddTag("cookable")

    MakeInventoryFloatable(inst, "small", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("cookable")
    inst.components.cookable.product = "acorn_cooked"

    inst:AddComponent("tradable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.foodtype = FOODTYPE.SEEDS
    inst.components.edible.secondaryfoodtype = FOODTYPE.ROUGHAGE

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_ACORN_CRACKED_MAXSTACKCOUNT

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_acorn_cracked"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_acorn_cracked.xml"

    inst:AddComponent("forcecompostable")
    inst.components.forcecompostable.brown = true

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/sdf_acorn_cracked", fn, assets)