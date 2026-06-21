local assets=
{
	Asset("ANIM", "anim/whitegem.zip"),
    Asset("ATLAS", "images/inventoryimages/whitegem.xml"),
	Asset("IMAGE", "images/inventoryimages/whitegem.tex"),
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
    inst.AnimState:SetBank("whitegem")
    inst.AnimState:SetBuild("whitegem")
    inst.AnimState:PlayAnimation("idle")
	MakeInventoryFloatable(inst, "small", 0.1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "whitegem"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/whitegem.xml"
    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst:DoTaskInTime(1, Sparkle)
    return inst
end
return Prefab( "common/inventory/whitegem", fn, assets)