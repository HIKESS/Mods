local assets =
{
  Asset("ANIM", "anim/jx_gasoline.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_gasoline")
    inst.AnimState:SetBuild("jx_gasoline")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("jx_gasoline")
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fueltype = FUELTYPE.GASOLINE
    inst.components.fuel.fuelvalue = 480 * 5
    
    MakeCraftingMaterialRecycler(inst, { gelblob_bottle = "messagebottleempty" })
    
    return inst
end

return Prefab("jx_gasoline", fn, assets)