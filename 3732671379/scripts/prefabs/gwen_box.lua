local assets = {
    Asset("ATLAS", "images/inventoryimages/gwen_beibao.xml"),
	Asset("IMAGE", "images/inventoryimages/gwen_beibao.tex"),	
	Asset("ANIM", "anim/gwenbeibao.zip"),
}



local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med", .07, 0.71)

    inst.AnimState:SetBank("gwenbeibao")
    inst.AnimState:SetBuild("gwenbeibao")
    inst.AnimState:PlayAnimation("idle", true)
    inst:AddTag("gwen_box") 

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst)
            inst.replica.container:WidgetSetup("gwen_box")
        end
        return inst
    end

    -- 物品组件
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gwen_beibao.xml"
	inst.components.inventoryitem.imagename = "gwen_beibao"

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("gwen_box") 
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("inspectable")

    return inst
end

return Prefab("gwen_box", fn, assets)