
local assets =
{
    Asset("ANIM", "anim/gw_repair.zip"),
    Asset("ATLAS","images/inventoryimages/gw_repair.xml"),
	Asset("IMAGE","images/inventoryimages/gw_repair.tex"),
	Asset("ATLAS","images/inventoryimages/gw_gift.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gift.tex"),
	Asset("ATLAS","images/inventoryimages/gw_level_up.xml"),
	Asset("IMAGE","images/inventoryimages/gw_level_up.tex"),
	Asset("ATLAS","images/inventoryimages/gw_level_down.xml"),
	Asset("IMAGE","images/inventoryimages/gw_level_down.tex"),
	Asset("ATLAS","images/inventoryimages/gw_candy.xml"),
	Asset("IMAGE","images/inventoryimages/gw_candy.tex"),
	Asset("ATLAS","images/inventoryimages/gw_time_0.xml"),
	Asset("IMAGE","images/inventoryimages/gw_time_0.tex"),
	Asset("ATLAS","images/inventoryimages/gw_time_1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_time_1.tex"),
}
local prefabs = {}

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----修补道具
local function gw_repairfn()
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
    inst.AnimState:SetBank("gw_prop")
    inst.AnimState:SetBuild("gw_repair")
    inst.AnimState:PlayAnimation("gw_repair",true)

	inst:AddTag("gw_tool")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_repair.xml"
	inst.components.inventoryitem.imagename = "gw_repair"

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
----礼品盒
local gw_gift = {
    gw_refactor_1 = .15,
    gw_gj_shaobing1 = .15,
    gw_gj_xingguang1 = .15,
    gw_gj_yumao1 = .15,
    gw_gj_zhihui1 = .15,
    gw_candy = .1,
	gw_gj_xuehua1 = .55,
}

local function gw_dakai(inst, owner)
	if owner and owner.components.inventory ~= nil and owner.components.inventory.isopen then
		owner.components.inventory:GiveItem(SpawnPrefab(weighted_random_choice(gw_gift)))
	end
	if owner.components.talker then
		owner.components.talker:Say("难道只有格温的白丝小jio才能算是礼物吗？！")
	end
	local pos = Vector3(owner.Transform:GetWorldPosition())
	local fx = SpawnPrefab("carnivalgame_shooting_projectile_fx")
	fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	fx.Transform:SetScale(1.3,1.3,1.3)
	fx:ListenForEvent("animover", fx.Remove)
	inst:Remove()
	return true
end

local function gw_giftfn()
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
    inst.AnimState:SetBank("gw_prop")
    inst.AnimState:SetBuild("gw_repair")
    inst.AnimState:PlayAnimation("gw_gift",true)

	inst:AddTag("gw_tool")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_gift.xml"
	inst.components.inventoryitem.imagename = "gw_gift"
	
	inst.gw_dakai = gw_dakai

    return inst
end
--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function oneaten(inst, eater)
    if eater:HasTag("player") and eater.components.talker then
		if eater.prefab ~= "gwen" then
			if inst.prefab == "gw_level_up" then
				eater.components.talker:Say("甜甜的糖果还是给格温小姐吃吧")
			elseif inst.prefab == "gw_level_down" then
				eater.components.talker:Say("酸酸的糖果还是给格温小姐吃吧")
			elseif inst.prefab == "gw_candy" then
				eater.components.talker:Say("酸酸甜甜的软糖还是给格温小姐吃吧")
			end
		else
			if inst.prefab == "gw_level_up" then
				if eater.components.gwen_competence then
					eater.components.gwen_competence:Incr_gwen_Level(1)
					eater.components.gwen_competence:Reset_gwen_Exp()
					local fx = SpawnPrefab("fx_book_light_upgraded")
					fx.entity:SetParent(eater.entity)
					fx.Transform:SetPosition(0, 0, 0)
					fx:ListenForEvent("animover", fx.Remove)
					eater.components.talker:Say("好甜~\n(当前等级Lv"..eater.components.gwen_competence:Get_gwen_Level()..")")
				end
				if eater.components.gwen_shengai then
					eater.components.gwen_shengai:DoDelta(80)
				end
			elseif inst.prefab == "gw_level_down" then
				if eater.components.gwen_competence and eater.components.gwen_competence:Get_gwen_Level() > 1 then
					eater.components.gwen_competence:Incr_gwen_Level(-1)
					eater.components.gwen_competence:Reset_gwen_Exp()
					local fx = SpawnPrefab("wanda_attack_shadowweapon_old_fx")
					fx.entity:SetParent(eater.entity)
					fx.Transform:SetPosition(0, 1, 0)
					fx:ListenForEvent("animover", fx.Remove)
					eater.components.talker:Say("好酸！\n(当前等级Lv"..eater.components.gwen_competence:Get_gwen_Level()..")")
				end
				if eater.components.gwen_shengai then
					eater.components.gwen_shengai:DoDelta(-80)
				end
			elseif inst.prefab == "gw_candy" then
				if eater.components.gwen_competence and eater.components.gwen_competence:Get_gwen_Level() <= 5 then
					eater.components.gwen_competence:Set_gwen_Level(5)
					eater.components.gwen_competence:Reset_gwen_Exp()
					eater.components.talker:Say("酸酸甜甜的软糖~")
					local pos = Vector3(eater.Transform:GetWorldPosition())
					local fx = SpawnPrefab("carnivalgame_shooting_projectile_fx")
					fx.Transform:SetPosition(pos.x, pos.y, pos.z)
					fx.Transform:SetScale(1.3,1.3,1.3)
					fx:ListenForEvent("animover", fx.Remove)
				else
					eater.components.talker:Say("现在吃就没什么用啦~")
				end
				if eater.components.gwen_shengai then
					eater.components.gwen_shengai:DoDelta(80)
				end
			end
			eater:PushEvent("gw_level")
		end
    end
end

----升级糖
local function gw_level_upfn()
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
    inst.AnimState:SetBank("gw_prop")
    inst.AnimState:SetBuild("gw_repair")
    inst.AnimState:PlayAnimation("gw_lvup")

	inst:AddTag("gw_tool")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_level_up.xml"
	inst.components.inventoryitem.imagename = "gw_level_up"

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
	inst.components.edible.healthvalue = 10
	inst.components.edible.hungervalue = 10
	inst.components.edible.sanityvalue = 10
	inst.components.edible:SetOnEatenFn(oneaten)
    inst.components.edible.foodtype = FOODTYPE.GOODIES

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    return inst
end

----降级糖
local function gw_level_downfn()
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
    inst.AnimState:SetBank("gw_prop")
    inst.AnimState:SetBuild("gw_repair")
    inst.AnimState:PlayAnimation("gw_lvdown")

	inst:AddTag("gw_tool")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_level_down.xml"
	inst.components.inventoryitem.imagename = "gw_level_down"

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
	inst.components.edible.healthvalue = 10
	inst.components.edible.hungervalue = 10
	inst.components.edible.sanityvalue = 10
	inst.components.edible:SetOnEatenFn(oneaten)
    inst.components.edible.foodtype = FOODTYPE.GOODIES

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    return inst
end

----5级糖
local function gw_candyfn()
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
    inst.AnimState:SetBank("gw_prop")
    inst.AnimState:SetBuild("gw_repair")
    inst.AnimState:PlayAnimation("gw_candy")

	inst:AddTag("gw_tool")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_candy.xml"
	inst.components.inventoryitem.imagename = "gw_candy"

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
	inst.components.edible.healthvalue = 10
	inst.components.edible.hungervalue = 10
	inst.components.edible.sanityvalue = 10
	inst.components.edible:SetOnEatenFn(oneaten)
    inst.components.edible.foodtype = FOODTYPE.GOODIES

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    return inst
end

--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function gw_state(inst)
	if inst.gw_state == 1 then
		inst:AddTag("gw_state")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_time_1.xml"
		inst.components.inventoryitem.imagename = "gw_time_1"
		inst.AnimState:PlayAnimation("gw_time_1",true)
		inst.components.named:SetName("填满的时光沙漏\nLv."..inst.gw_Level.." Exp."..inst.gw_Exp)
	else
		inst:RemoveTag("gw_state")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_time_0.xml"
		inst.components.inventoryitem.imagename = "gw_time_0"
		inst.AnimState:PlayAnimation("gw_time_0",true)
	end
end

----时光沙漏
local function gw_time(inst, owner)
	if inst:HasTag("gw_state") then
		inst:Remove ()
		if owner.components.gwen_competence then
			owner.components.gwen_competence:Set_gwen_Level(inst.gw_Level)
			owner.components.gwen_competence:Set_gwen_Exp(inst.gw_Exp)
			owner.components.talker:Say("在这里,一丝一缕织就的记忆,只属于我自己")
		end
	else
		if owner.components.gwen_competence then
			inst.gw_state = 1
			inst.gw_Level = owner.components.gwen_competence:Get_gwen_Level()
			inst.gw_Exp = owner.components.gwen_competence:Get_gwen_Exp()
			owner.components.gwen_competence:Reset_gwen_Level()
			owner.components.gwen_competence:Reset_gwen_Exp()
			inst.components.talker:Say("这一切比梦还美好,而且还是真的…我永远不会忘记")
			gw_state(inst)
		end
	end
	owner.AnimState:PlayAnimation("deform_pre")
	owner:PushEvent("gw_level")
end

local function OnSave(inst, data)
	data.gw_state = inst.gw_state
	data.gw_Level = inst.gw_Level
	data.gw_Exp = inst.gw_Exp
end

local function OnPreLoad(inst,data)
    if data ~= nil then
		if data and data.gw_state ~= nil then
			inst.gw_state = data.gw_state
		end
		if data and data.gw_Level ~= nil then
			inst.gw_Level = data.gw_Level
		end
		if data and data.gw_Exp ~= nil then
			inst.gw_Exp = data.gw_Exp
		end
	end
	gw_state(inst)
end

local function gw_timefn()
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
    inst.AnimState:SetBank("gw_prop")
    inst.AnimState:SetBuild("gw_repair")
    inst.AnimState:PlayAnimation("gw_time_0",true)

	inst:AddTag("gw_tool")

	inst:AddComponent("talker")
	inst.components.talker.fontsize = 28
	inst.components.talker.offset = Vector3(0, -324, 0)
	inst.components.talker.colour = Vector3(1, .7, .7, 1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

	inst.gw_state = 0
	inst.gw_Level = 1
	inst.gw_Exp = 0

	inst.OnSave = OnSave
	inst.OnPreLoad = OnPreLoad

	inst:AddComponent("named")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_time_0.xml"
	inst.components.inventoryitem.imagename = "gw_time_0"
	
	inst.gw_time = gw_time

    return inst
end

----------------------------------------------------------------------
return Prefab("gw_repair", gw_repairfn, assets),
		Prefab("gw_gift", gw_giftfn, assets),
		Prefab("gw_level_up", gw_level_upfn, assets),
		Prefab("gw_level_down", gw_level_downfn, assets),
		Prefab("gw_candy", gw_candyfn, assets),
		Prefab("gw_time_0", gw_timefn, assets)