
local assets =
{
    Asset("ANIM", "anim/gw_refactor.zip"),
    Asset("ATLAS","images/inventoryimages/gw_refactor_1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_1.tex"),
	Asset("ATLAS","images/inventoryimages/gw_refactor_2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_2.tex"),
	Asset("ATLAS","images/inventoryimages/gw_refactor_3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_3.tex"),
    Asset("ATLAS","images/inventoryimages/gw_refactor_0.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_0.tex"),

}
local prefabs = {}

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function gw_refactor_1fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

	inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork() 
	inst.entity:AddMiniMapEntity()

    inst.AnimState:SetBank("gw_refactor")
    inst.AnimState:SetBuild("gw_refactor")
    inst.AnimState:PlayAnimation("gw_refactor_1",true)

	inst:AddTag("gw_refactor")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_refactor_1.xml"
	inst.components.inventoryitem.imagename = "gw_refactor_1"

    return inst
end

local function gw_refactor_2fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

	inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork() 
	inst.entity:AddMiniMapEntity()

    inst.AnimState:SetBank("gw_refactor")
    inst.AnimState:SetBuild("gw_refactor")
    inst.AnimState:PlayAnimation("gw_refactor_2",true)

	inst:AddTag("gw_refactor")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_refactor_2.xml"
	inst.components.inventoryitem.imagename = "gw_refactor_2"

    return inst
end

local function gw_refactor_3fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

	inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork() 
	inst.entity:AddMiniMapEntity()

    inst.AnimState:SetBank("gw_refactor")
    inst.AnimState:SetBuild("gw_refactor")
    inst.AnimState:PlayAnimation("gw_refactor_3",true)

	inst:AddTag("gw_refactor")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_refactor_3.xml"
	inst.components.inventoryitem.imagename = "gw_refactor_3"

    return inst
end

local function gw_refactor_0fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", .07, 0.71)

	inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork() 
	inst.entity:AddMiniMapEntity()

    inst.AnimState:SetBank("gw_refactor")
    inst.AnimState:SetBuild("gw_refactor")
    inst.AnimState:PlayAnimation("gw_refactor_0",true)

	inst:AddTag("gw_refactor")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_refactor_0.xml"
	inst.components.inventoryitem.imagename = "gw_refactor_0"

	inst:AddComponent("tradable")

    return inst
end

----------------------------------------------------------------------
return Prefab("gw_refactor_1", gw_refactor_1fn, assets),
		Prefab("gw_refactor_2", gw_refactor_2fn, assets),
		Prefab("gw_refactor_3", gw_refactor_3fn, assets),
		Prefab("gw_refactor_0", gw_refactor_0fn, assets)