local assets =
{
	Asset("ANIM", "anim/wiltonmod_bloodpump.zip"),
	Asset("ANIM", "anim/boneheart.zip"),

	Asset("ATLAS", "images/inventoryimages/wiltonmod_boneheart.xml"),    
	Asset("IMAGE", "images/inventoryimages/wiltonmod_boneheart.tex"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_boneheart_skin.xml"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", 0.1, 0.75)

	inst:AddTag("wiltonmod_item")
	inst:AddTag("wiltonmod_boneheart")

	inst.AnimState:SetBank("boneheart")
	inst.AnimState:SetBuild("boneheart")
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "wiltonmod_boneheart"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_boneheart.xml"

	inst:AddComponent("inspectable")

	inst:AddComponent("tradable")

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)

	return inst
end

-- 皮肤版本的骨心，使用 bloodpump 动画与独立的物品图标。
local function skin()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "med", 0.1, 0.75)

	inst:AddTag("wiltonmod_item")
	inst:AddTag("wiltonmod_boneheart")

	inst.AnimState:SetBank("bloodpump")
	inst.AnimState:SetBuild("bloodpump")
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "wiltonmod_boneheart_skin"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_boneheart_skin.xml"

	inst:AddComponent("inspectable")
	inst:AddComponent("tradable")
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)

	return inst
end

return Prefab("wiltonmod_boneheart", fn, assets),
	   Prefab("wiltonmod_boneheart_skin", skin, assets)