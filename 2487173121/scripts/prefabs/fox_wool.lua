local assets=
{
	Asset("ANIM", "anim/fox_wool.zip"),
    Asset("ATLAS", "images/inventoryimages/fox_wool.xml"),
	Asset("IMAGE", "images/inventoryimages/fox_wool.tex"),
}
local prefabs = 
{
}	
local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("fox_wool")
    inst.AnimState:SetBuild("fox_wool")
    inst.AnimState:PlayAnimation("idle")
	MakeInventoryFloatable(inst, "small", 0.1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "fox_wool"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/fox_wool.xml"
    inst:AddComponent("inspectable")
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 40
    return inst
end
return Prefab( "common/inventory/fox_wool", fn, assets)