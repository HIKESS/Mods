local assets =
{
    Asset("ANIM", "anim/jx_car_key.zip"),
}

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_car_key")
    inst.AnimState:SetBuild("jx_car_key")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("jx_car_key")
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab("jx_car_key", fn, assets)