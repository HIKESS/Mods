
local assets =
{
    Asset("ANIM", "anim/gw_gj.zip"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xingguang1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xingguang1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xingguang2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xingguang2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xingguang3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xingguang3.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xuehua1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xuehua1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xuehua2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xuehua2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xuehua3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xuehua3.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_shaobing1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_shaobing1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_shaobing2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_shaobing2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_shaobing3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_shaobing3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_gj_yumao1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_yumao1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_yumao2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_yumao2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_yumao3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_yumao3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_gj_zhihui1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_zhihui1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_zhihui2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_zhihui2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_zhihui3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_zhihui3.tex"),
}
local prefabs = {}

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----星光
local function gw_gj_xingguang1fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_xingguang1",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_xingguang1.xml"
	inst.components.inventoryitem.imagename = "gw_gj_xingguang1"

    return inst
end

local function gw_gj_xingguang2fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_xingguang2",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_xingguang2.xml"
	inst.components.inventoryitem.imagename = "gw_gj_xingguang2"

    return inst
end

local function gw_gj_xingguang3fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_xingguang3",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_xingguang3.xml"
	inst.components.inventoryitem.imagename = "gw_gj_xingguang3"

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----雪花
local function gw_gj_xuehua1fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_xuehua1",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_xuehua1.xml"
	inst.components.inventoryitem.imagename = "gw_gj_xuehua1"

    return inst
end

local function gw_gj_xuehua2fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_xuehua2",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_xuehua2.xml"
	inst.components.inventoryitem.imagename = "gw_gj_xuehua2"

    return inst
end

local function gw_gj_xuehua3fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_xuehua3",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_xuehua3.xml"
	inst.components.inventoryitem.imagename = "gw_gj_xuehua3"

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----哨兵
local function gw_gj_shaobing1fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_shaobing1",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_shaobing1.xml"
	inst.components.inventoryitem.imagename = "gw_gj_shaobing1"

    return inst
end

local function gw_gj_shaobing2fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_shaobing2",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_shaobing2.xml"
	inst.components.inventoryitem.imagename = "gw_gj_shaobing2"

    return inst
end

local function gw_gj_shaobing3fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_shaobing3",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_shaobing3.xml"
	inst.components.inventoryitem.imagename = "gw_gj_shaobing3"

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----羽毛
local function gw_gj_yumao1fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_yumao1",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_yumao1.xml"
	inst.components.inventoryitem.imagename = "gw_gj_yumao1"

    return inst
end

local function gw_gj_yumao2fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_yumao2",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_yumao2.xml"
	inst.components.inventoryitem.imagename = "gw_gj_yumao2"

    return inst
end

local function gw_gj_yumao3fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_yumao3",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_yumao3.xml"
	inst.components.inventoryitem.imagename = "gw_gj_yumao3"

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----智慧
local function gw_gj_zhihui1fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_zhihui1",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_zhihui1.xml"
	inst.components.inventoryitem.imagename = "gw_gj_zhihui1"

    return inst
end

local function gw_gj_zhihui2fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_zhihui2",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_zhihui2.xml"
	inst.components.inventoryitem.imagename = "gw_gj_zhihui2"

    return inst
end

local function gw_gj_zhihui3fn()
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

    inst.AnimState:SetBank("gw_gj")
    inst.AnimState:SetBuild("gw_gj")
    inst.AnimState:PlayAnimation("gw_gj_zhihui3",true)

	inst:AddTag("gw_guajian")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gj_zhihui3.xml"
	inst.components.inventoryitem.imagename = "gw_gj_zhihui3"

    return inst
end


----------------------------------------------------------------------
return Prefab("gw_gj_xingguang1", gw_gj_xingguang1fn, assets),
		Prefab("gw_gj_xingguang2", gw_gj_xingguang2fn, assets),
		Prefab("gw_gj_xingguang3", gw_gj_xingguang3fn, assets),

		Prefab("gw_gj_xuehua1", gw_gj_xuehua1fn, assets),
		Prefab("gw_gj_xuehua2", gw_gj_xuehua2fn, assets),
		Prefab("gw_gj_xuehua3", gw_gj_xuehua3fn, assets),

		Prefab("gw_gj_shaobing1", gw_gj_shaobing1fn, assets),
		Prefab("gw_gj_shaobing2", gw_gj_shaobing2fn, assets),
		Prefab("gw_gj_shaobing3", gw_gj_shaobing3fn, assets),
		
		Prefab("gw_gj_yumao1", gw_gj_yumao1fn, assets),
		Prefab("gw_gj_yumao2", gw_gj_yumao2fn, assets),
		Prefab("gw_gj_yumao3", gw_gj_yumao3fn, assets),

		Prefab("gw_gj_zhihui1", gw_gj_zhihui1fn, assets),
		Prefab("gw_gj_zhihui2", gw_gj_zhihui2fn, assets),
		Prefab("gw_gj_zhihui3", gw_gj_zhihui3fn, assets)
		