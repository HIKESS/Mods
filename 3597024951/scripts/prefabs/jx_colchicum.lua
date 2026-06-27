local assets =
{
    Asset("ANIM", "anim/jx_colchicum.zip"),
}

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_colchicum")
    inst.AnimState:SetBuild("jx_colchicum")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("jx_colchicum")
    inst:AddTag("furnituredecor")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("furnituredecor")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    
    return inst
end

return Prefab("jx_colchicum", fn, assets)