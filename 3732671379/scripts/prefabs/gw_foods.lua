
local assets =
{
	Asset("ANIM", "anim/gw_foods.zip"),
	Asset("IMAGE", "images/inventoryimages/gw_dangao.tex"),
	Asset("ATLAS", "images/inventoryimages/gw_dangao.xml"),
	
}

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function oneaten_dangao(inst, eater)
    if eater:HasTag("player") then
		if eater.components.gwen_shengai then
			eater.components.gwen_shengai:DoDelta(20)
		end
    end
end

----水果蛋糕
local function gw_dangaofn()
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
	inst.AnimState:SetBank("gw_dangao")
	inst.AnimState:SetBuild("gw_foods")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("cookable")
    inst:AddTag("catfood")
	inst:AddTag("pondfish")
	inst:AddTag("preparedfood")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_dangao.xml"
	inst.components.inventoryitem.imagename = "gw_dangao"

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
	inst.components.edible.healthvalue = 20
	inst.components.edible.hungervalue = 40
	inst.components.edible.sanityvalue = 10
    inst.components.edible.foodtype = FOODTYPE.GOODIES
	inst.components.edible:SetOnEatenFn(oneaten_dangao)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.TOTAL_DAY_TIME*10)
    inst.components.perishable:StartPerishing()
	inst.components.perishable.ignorewentness = true
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

----------------------------------------------------------------------
return Prefab("gw_dangao", gw_dangaofn, assets)