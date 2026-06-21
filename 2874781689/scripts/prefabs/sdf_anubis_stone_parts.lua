local assets=
{
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part1.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part1.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part2.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part2.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part3.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part3.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part4.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part4.xml"),

    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part1_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part1_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part2_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part2_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part3_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part3_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part4_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part4_mm.xml"),

    Asset("ANIM", "anim/sdf_anubis_stone_parts.zip"),
}

prefabs = {
}

local function OnPutInInventory(inst, owner)
    inst:DoTaskInTime(0, function()
	if owner ~= nil then
	    if owner:HasTag("sdf") then
		if owner.components.sdf_key_item_inventory:GetKeyItem(inst.prefab) == nil then
		    owner.components.sdf_key_item_inventory:SetKeyItem(inst, owner)
		end
	    end
	end
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_anubis_stone_part1_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_anubis_stone_parts")
    inst.AnimState:SetBuild("sdf_anubis_stone_parts")
    inst.AnimState:PlayAnimation("idle_1", true)

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_anubis_stone_part1"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_part1.xml"

    MakeHauntableLaunch(inst)

    return inst
end


local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_anubis_stone_part2_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_anubis_stone_parts")
    inst.AnimState:SetBuild("sdf_anubis_stone_parts")
    inst.AnimState:PlayAnimation("idle_2", true)

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_anubis_stone_part2"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_part2.xml"

    MakeHauntableLaunch(inst)

    return inst
end


local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_anubis_stone_part3_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_anubis_stone_parts")
    inst.AnimState:SetBuild("sdf_anubis_stone_parts")
    inst.AnimState:PlayAnimation("idle_3", true)

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_anubis_stone_part3"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_part3.xml"

    MakeHauntableLaunch(inst)

    return inst
end


local function fn4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_anubis_stone_part4_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_anubis_stone_parts")
    inst.AnimState:SetBuild("sdf_anubis_stone_parts")
    inst.AnimState:PlayAnimation("idle_4", true)

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_anubis_stone_part4"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_part4.xml"

    MakeHauntableLaunch(inst)

    return inst
end
return  Prefab("common/inventory/sdf_anubis_stone_part1", fn, assets),
	Prefab("common/inventory/sdf_anubis_stone_part2", fn2, assets),
	Prefab("common/inventory/sdf_anubis_stone_part3", fn3, assets),
	Prefab("common/inventory/sdf_anubis_stone_part4", fn4, assets)