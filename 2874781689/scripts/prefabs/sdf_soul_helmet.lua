local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_soul_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_soul_helmet.tex"),

    Asset("ATLAS", "images/map_icons/sdf_soul_helmet_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_soul_helmet_mm.tex"),

    Asset("ANIM", "anim/sdf_soul_helmet.zip"),
}

prefabs = {
}

local function OnDropped(inst)
    inst.typeid = 0
end

local function OnPickupFn(inst, picker)
    if inst.typeid == 0 then
	inst.typeid = 1
	inst:DoTaskInTime(0.1, function()
	    if picker and picker.components.inventory then

		--Check Hands
		local bodyItem = picker.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if bodyItem and bodyItem.prefab == "sdf_anubis_stone" and (bodyItem.components.container and not bodyItem.components.container:IsFull()) then
		    --Inventory
		    local soulHelmItem = SpawnPrefab("sdf_soul_helmet")
		    soulHelmItem.typeid = 1
		    bodyItem.components.container:GiveItem(soulHelmItem)
		    inst:Remove()
		elseif picker.components.inventory:FindItem(function(item) return (item.prefab == "sdf_anubis_stone" and  (item.components.container and not item.components.container:IsFull()))end) then
		    --Inventory
		    local soulKeeperContainer = picker.components.inventory:FindItem(function(item) return (item.prefab=="sdf_anubis_stone" and  (item.components.container and not item.components.container:IsFull()))end)
		    local soulHelmItem = SpawnPrefab("sdf_soul_helmet")
		    soulHelmItem.typeid = 1
		    soulKeeperContainer.components.container:GiveItem(soulHelmItem)
		    inst:Remove()
		end
	    end
	end)
    end
end

local function onload(inst, data, newents)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end
end

local function onsave(inst, data)
    data.typeid = inst.typeid
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_soul_helmet_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_soul_helmet")
    inst.AnimState:SetBuild("sdf_soul_helmet")
    inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    MakeInventoryFloatable(inst, "med", 0.25)

    inst:AddTag("sdf_soul_helmet_soul")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows save or forsake Lost Soul
    inst:AddComponent("sdf_soul_helmet_offering_chalice_hall_of_heroes")
    inst:AddComponent("sdf_soul_helmet_offering_merchant_gargoyle")
    inst:AddComponent("sdf_soul_helmet_offering_shop_gargoyle")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_soul_helmet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_soul_helmet.xml"

    inst.typeid = 0

    inst.OnLoad = onload
    inst.OnSave = onsave

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_soul_helmet", fn, assets)