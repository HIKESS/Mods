local assets=
{
	Asset("ANIM", "anim/darkcrystal.zip"),
    Asset("ATLAS", "images/inventoryimages/darkcrystal.xml"),
	Asset("IMAGE", "images/inventoryimages/darkcrystal.tex"),
}
local prefabs = 
{
}	
    local function Sparkle(inst)
        if not inst.AnimState:IsCurrentAnimation("sparkle") then
            inst.AnimState:PlayAnimation("sparkle")
            inst.AnimState:PushAnimation("idle", true)
        end
        inst:DoTaskInTime(4 + math.random(), Sparkle)
    end
local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("darkcrystal")
    inst.AnimState:SetBuild("darkcrystal")
    inst.AnimState:PlayAnimation("idle")
	MakeInventoryFloatable(inst, "small", 0.1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "darkcrystal"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/darkcrystal.xml"
    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst:AddComponent("tradable")
    inst:DoTaskInTime(1, Sparkle)
    return inst
end
return Prefab( "common/inventory/darkcrystal", fn, assets)