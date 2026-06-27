local assets =
{
    Asset("ANIM", "anim/jx_wiki_book.zip"),
}

local function onteach(inst, doer)
  if doer and doer.userid then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Wiki"), doer.userid)
    return true
  end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_wiki_book")
    inst.AnimState:SetBuild("jx_wiki_book")
    inst.AnimState:PlayAnimation("idle")
        
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("erasablepaper")
    inst.components.erasablepaper:SetStackSize(2)
    
    inst:AddComponent("scrapbookable")
    inst.components.scrapbookable:SetOnTeachFn(onteach)
    
    return inst
end

return Prefab("jx_wiki_book", fn, assets)