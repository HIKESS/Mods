
local assets =
{
    Asset("ANIM", "anim/gw_alchemy.zip"),
    Asset("ATLAS","images/inventoryimages/gw_alchemy_1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_1.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy_2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_2.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy_3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy_4.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_4.tex"),

}
local prefabs = {}

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function gw_alchemy_1fn()
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

    inst.AnimState:SetBank("gw_alchemy")
    inst.AnimState:SetBuild("gw_alchemy")
    inst.AnimState:PlayAnimation("gw_alchemy_1",true)

	inst:AddTag("gw_alchemy")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_alchemy_1.xml"
	inst.components.inventoryitem.imagename = "gw_alchemy_1"

    return inst
end

local function gw_alchemy_2fn()
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

    inst.AnimState:SetBank("gw_alchemy")
    inst.AnimState:SetBuild("gw_alchemy")
    inst.AnimState:PlayAnimation("gw_alchemy_2",true)

	inst:AddTag("gw_alchemy")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_alchemy_2.xml"
	inst.components.inventoryitem.imagename = "gw_alchemy_2"

    return inst
end

local function gw_alchemy_3fn()
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

    inst.AnimState:SetBank("gw_alchemy")
    inst.AnimState:SetBuild("gw_alchemy")
    inst.AnimState:PlayAnimation("gw_alchemy_3",true)

	inst:AddTag("gw_alchemy")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_alchemy_3.xml"
	inst.components.inventoryitem.imagename = "gw_alchemy_3"

    return inst
end

local function gw_alchemy_4fn()
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

    inst.AnimState:SetBank("gw_alchemy")
    inst.AnimState:SetBuild("gw_alchemy")
    inst.AnimState:PlayAnimation("gw_alchemy_4",true)

	inst:AddTag("gw_alchemy")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_alchemy_4.xml"
	inst.components.inventoryitem.imagename = "gw_alchemy_4"

	inst:AddComponent("tradable")

    return inst
end

----------------------------------------------------------------------
return Prefab("gw_alchemy_1", gw_alchemy_1fn, assets),
		Prefab("gw_alchemy_2", gw_alchemy_2fn, assets),
		Prefab("gw_alchemy_3", gw_alchemy_3fn, assets),
		Prefab("gw_alchemy_4", gw_alchemy_4fn, assets)