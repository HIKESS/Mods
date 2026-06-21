local assets =
{
    Asset("ANIM", "anim/tf2scrap.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tf2scrap")
    inst.AnimState:SetBuild("tf2scrap")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "metal"

    inst:AddTag("molebait")

	MakeInventoryFloatable(inst, "med", nil, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
--    inst.components.inventoryitem.imagename = "scrap"
    inst.components.inventoryitem.atlasname = ENGINEERITEMIMAGES
--    inst:AddComponent("tradable")

    inst:AddComponent("bait")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.SCRAP
    inst.components.repairer.workrepairvalue = 20

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("scrap", fn, assets)