
local assets =
{
    Asset("ANIM", "anim/gw_tasui.zip"),
    Asset("ANIM", "anim/swap_tasui.zip"),
    Asset("ATLAS","images/inventoryimages/gw_tasui.xml"),
	Asset("IMAGE","images/inventoryimages/gw_tasui.tex"),	
}
local prefabs = {}

local cd = 30
local use = 5

----摘掉
local function UnEquip(inst, owner)
	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	if owner ~= nil and owner.components.inventory ~= nil and owner.components.inventory.isopen then
		local container = inst.components.inventoryitem:GetContainer()
		if container ~= nil then
			local slot = inst.components.inventoryitem:GetSlotNum()
			container:GiveItem(inst, slot)
		end
	end
 end

----修理
local function gwxiufu(inst, item, doer)
	local itemnum = item.components.stackable.stacksize or 1
	if inst.components.finiteuses and inst.components.finiteuses:GetPercent() >= 1 then 
		inst.components.talker:Say("武器无需修理")
	else
		if inst.components.finiteuses then
			inst.components.finiteuses:Use(-100)
			if inst.components.finiteuses:GetPercent() >= 1 then
				inst.components.finiteuses:SetPercent(1)
			end
		end

		inst.components.talker:Say("武器已修理")
		doer.sg:GoToState("mine")
		local fx = SpawnPrefab("crab_king_shine")
		fx.entity:SetParent(doer.entity)
		fx.Transform:SetPosition(0, 1.6, 0)
        if itemnum > 1 then
            item.components.stackable:Get(1)
        else
            item:Remove()
        end		
	end 

	if not inst.components.equippable then
		inst:AddComponent("equippable")
	end
	return true
end

----装备
local function onequip(inst, owner) 
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_tasui", inst.GUID, "swap_tasui")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_tasui", "swap_tasui")
	end
end

----脱下
local function onunequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("unequipskinneditem", inst:GetSkinName())
	end
end

----技能
local function Useitem(inst)
	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	inst.components.useableitem:StopUsingItem()
	if inst.components.rechargeable:GetTimeToCharge() > 0 then
		inst.components.talker:Say("技能cd中")
	elseif inst.components.finiteuses:GetUses() <= use then
		inst.components.talker:Say("武器耐久不足")
	elseif owner ~= nil then

		----棱彩重构
		if inst.components.gwen_refactor and inst.components.gwen_refactor:Getgw_Permanent() == 1 then
			cd = 3
		else
			cd = 10
		end

		inst.components.rechargeable:Discharge(cd)
		inst.components.finiteuses:Use(use)
		----跳跃动作
		if owner.sg and owner.sg:HasState("hit") and not owner.sg:HasStateTag("noouthit") and not owner.sg:HasStateTag("flight") and owner.components.health and not owner.components.health:IsDead() and not owner:HasTag("playerghost") then
			if owner.components.rider ~= nil and owner.components.rider:IsRiding() then
				return
			else
				owner.sg:GoToState("helmsplitter")
			end
		end

		inst:DoTaskInTime(.6,function()
			local pos = Vector3(inst.Transform:GetWorldPosition())
			local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 5.2, nil, E_EXCLUDE)
			for k,v in pairs(ents) do
				inst:DoTaskInTime(.6,function()
					if v ~= nil and((v:HasTag("plant")
					or v:HasTag("tree")
					or v:HasTag("stump")
					or v:HasTag("heavy")
					or v:HasTag("boulder")
					or v:HasTag("frozen")
					or v:HasTag("gargoyle")
					or v:HasTag("seastack")
					or v:HasTag("cavedweller")
					or v:HasTag("statue")
					or v.prefab == "saltstack"
					or v.prefab == "wobster_den"
					or v.prefab == "farm_soil_debris"
					or v.prefab == "scorched_skeleton" or v.prefab == "skeleton_player" or v.prefab == "skeleton"
					or v.prefab == "chessjunk1" or v.prefab == "chessjunk2" or v.prefab == "chessjunk3"
					or v.prefab == "marbletree")
					or v.prefab == "rock_avocado_fruit"
					)
					and not v:HasTag("farm_plant")
					and owner ~= nil
					and v.components.workable ~= nil then
						v.components.workable:Destroy(owner)
					end
				end)
				inst:DoTaskInTime(0.75,function()
					if v ~= nil and((v:HasTag("plant")
					or v:HasTag("tree")
					or v:HasTag("stump")
					or v:HasTag("heavy")
					or v:HasTag("boulder")
					or v:HasTag("frozen")
					or v:HasTag("gargoyle")
					or v:HasTag("seastack")
					or v:HasTag("cavedweller")
					or v:HasTag("statue")
					or v.prefab == "saltstack"
					or v.prefab == "wobster_den"
					or v.prefab == "farm_soil_debris"
					or v.prefab == "scorched_skeleton" or v.prefab == "skeleton_player" or v.prefab == "skeleton"
					or v.prefab == "chessjunk1" or v.prefab == "chessjunk2" or v.prefab == "chessjunk3"
					or v.prefab == "marbletree")
					or v.prefab == "rock_avocado_fruit"
					)
					and not v:HasTag("farm_plant")
					and owner ~= nil
					and v.components.workable ~= nil then
						v.components.workable:Destroy(owner)
					end
				end)
			end
			----摧毁树木特效
			for i = 1 , 3 do
				inst:DoTaskInTime(i * .14,function()
					local pt = inst:GetPosition()
					local num = 9	
					for k = 0, num - 1 do
						local rad = i * 1.2
						local angle = k * 2 * PI / num
						local pos = pt + Vector3(rad * math.cos(angle), 0, rad * math.sin(angle))
						local fx = SpawnPrefab("groundpound_fx")
						fx.Transform:SetPosition(pos:Get())
						fx.Transform:SetScale(.66,.66,.66)
					end
				end)
			end

			----光圈特效
			local fx = SpawnPrefab("firering_fx")
			fx.entity:AddFollower()
			fx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -150, 0)
			fx.Transform:SetScale(.8,.8,.8)
		end)
	end
	return false
end

----耐久
local function OnFinished(inst)
	if inst.components.finiteuses:GetUses() <= 0 then
		if inst.components.equippable then
			inst:RemoveComponent("equippable")
		end
		UnEquip(inst)
	else
		if not inst.components.equippable then
			inst:AddComponent("equippable")
		end
	end
end
--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--[]--
local function fn()
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
    inst.AnimState:SetBank("gw_tasui")
    inst.AnimState:SetBuild("gw_tasui")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
	inst:AddTag("nopunch")
	inst:AddTag("gw_weapon")
	inst:AddTag("show_broken_ui")

	inst:AddComponent("talker")
	inst.components.talker.fontsize = 28
	inst.components.talker.offset = Vector3(0, 100, 0)
	inst.components.talker.colour = Vector3(1, .7, .7, 1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_tasui.xml"
	inst.components.inventoryitem.imagename = "gw_tasui"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddTag("rechargeable")
	inst:AddComponent("rechargeable")
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(600)
	inst.components.finiteuses:SetUses(600)
	inst.components.finiteuses:SetOnFinished(OnFinished)
	inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
	inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, 1)
	
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.MINE,1.5)
	inst.components.tool:SetAction(ACTIONS.HAMMER, 1.5)
	inst.components.tool:EnableToughWork(true)

    inst:AddComponent("farmtiller")

	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(Useitem)
	
	inst.gwxiufu = gwxiufu

    return inst
end



----------------------------------------------------------------------
return Prefab("gw_tasui", fn, assets)