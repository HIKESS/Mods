
local assets =
{
    Asset("ANIM", "anim/gw_muhun.zip"),
    Asset("ANIM", "anim/swap_muhun.zip"),
	Asset("ANIM", "anim/skeleton_guishou.zip"),
    Asset("ATLAS","images/inventoryimages/gw_muhun.xml"),
	Asset("IMAGE","images/inventoryimages/gw_muhun.tex"),	
}
local prefabs = {}

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

----开始消耗
local function On_fueled(inst)
	if inst.components.fueled ~= nil then
		inst.components.fueled:StartConsuming()
	end
end

----停止消耗
local function Off_fueled(inst)
	if inst.components.fueled ~= nil then
		inst.components.fueled:StopConsuming()
	end
	inst.AnimState:PlayAnimation("idle",true)
end

----装备
local function onequip(inst, owner) 
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_muhun", inst.GUID, "swap_muhun")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_muhun", "swap_muhun")
	end

	On_fueled(inst)
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

	Off_fueled(inst)
end

----续航
local function takefuel(inst)
	--[[local GetPercent = inst.components.fueled and inst.components.fueled:GetPercent()
	GetPercent = GetPercent + .1
	if GetPercent >= 1 then
		GetPercent = 1
	end
	inst.components.fueled:SetPercent(GetPercent)]]

	if not inst.components.equippable then
		inst:AddComponent("equippable")
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)
	end
end

----消耗
local function OnPickup(inst)
	On_fueled(inst)
end

local function Useitem(inst)
	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	if not owner then
		return
	end
    inst.components.rechargeable:Discharge(5)

	local GW_MUST_TAG =  {"gw_grave"}
	local GW_NOT_TAG =  {"gw_found"}
	local ent = FindEntity(inst, 9999, nil, GW_MUST_TAG, GW_NOT_TAG)


	if ent then
		if ent:GetDistanceSqToInst(inst) < 2.5 * 2.5 then
			inst.components.talker:Say("就在这里")
			owner.sg:GoToState("dig_start")
			inst.task2 = inst:DoTaskInTime(0.6, function()
				SpawnAt("fence_rotator_fx", ent)
				ent.AnimState:SetMultColour(1, 1, 1, 1)
				ent:AddTag("gw_found")
			end)
		else
			local x,y,z = inst.Transform:GetWorldPosition()
			local angle = ent:GetAngleToPoint(x,y,z)
            local radius = -1
            local theta = (angle)*DEGREES
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            inst.task3 = inst:DoTaskInTime(1, function()
				local base = SpawnPrefab("gw_guishou")
				base.Transform:SetPosition(x+offset.x,y,z+offset.z)
				base.Transform:SetRotation(angle+90)
				base.AnimState:PlayAnimation("pre")
				inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt")
				inst.components.talker:Say("在那边")
            end)
		end
	else
		inst.components.talker:Say("什么也没有找到")
	end

	-- local HasEpic = TheSim:FindFirstEntityWithTag("Has_Epic")
	-- local epic = TheSim:FindFirstEntityWithTag("epic")
	-- if HasEpic and HasEpic:IsValid()
	-- and epic and epic:IsValid()
	-- then
	-- 	local ProbEepic = epic and HasEpic or nil
	-- 	if ProbEepic ~= nil and ProbEepic:IsValid() then

	-- 		if ProbEepic.e_epic == nil or not ProbEepic.e_epic:IsValid() then
	-- 			ProbEepic.e_epic = SpawnPrefab("e_epic_pt_fx")
	-- 			ProbEepic.e_epic.entity:SetParent(ProbEepic.entity)

	-- 			ProbEepic.e_epic:ListenForEvent("death", function()
	-- 				if ProbEepic.e_epic and ProbEepic.e_epic:IsValid() then
	-- 					ProbEepic.e_epic:Remove()
	-- 				end
	-- 			end, ProbEepic)
	-- 			ProbEepic.e_epic:ListenForEvent("onremove",function()
	-- 				if ProbEepic.e_epic and ProbEepic.e_epic:IsValid() then
	-- 					ProbEepic.e_epic:Remove()
	-- 				end
	-- 			end, ProbEepic)
	-- 		end

	-- 		local ProbEepicName = STRINGS.NAMES[string.upper(ProbEepic.prefab)] or nil
	-- 		if ProbEepicName ~= nil then
	-- 			inst.components.talker:Say("当前史诗Boss生物为\n【"..ProbEepicName.."】")
	-- 		end
	-- 		local x,y,z = ProbEepic.Transform:GetWorldPosition()
	-- 		local owner = ConsoleCommandPlayer()
	-- 		if owner and owner.player_classified ~= nil then
	-- 			owner.player_classified.revealmapspot_worldx:set(x)
	-- 			owner.player_classified.revealmapspot_worldz:set(z)
	-- 			owner:DoTaskInTime(4*FRAMES, function()
	-- 				owner.player_classified.revealmapspotevent:push()
	-- 				owner.player_classified.MapExplorer:RevealArea(x, 0, z)
	-- 			end)
	-- 		end

	-- 	end
	-- else
	-- 	inst.components.talker:Say("什么也没有发生")
	-- end

end

local function Lightning_OnDischarged(inst)
	
end

local function Lightning_OnCharged(inst)
	inst.components.useableitem:StopUsingItem()
end

----耐久
local function OnDepleted(inst)
	if inst.components.equippable and inst.components.equippable:IsEquipped() then	
		UnEquip(inst)
	end
	if inst.components.equippable then
		inst:RemoveComponent("equippable")
	end
end

local function OnSave(inst, data)
    data.naijiu = inst.components.fueled:GetPercent()
end

local function OnLoad(inst,data)
    if data ~= nil then
        if data and data.naijiu ~= nil then
			if data.naijiu <= 0 then
				if inst.components.equippable then
					inst:RemoveComponent("equippable")
				end
			end
        end
    end
end

local function onUpdate(inst,data)
	local GetPercent = inst.components.fueled and inst.components.fueled:GetPercent()
	if GetPercent > 0 then
		if not inst.components.equippable then
			inst:AddComponent("equippable")
			inst.components.equippable:SetOnEquip(onequip)
			inst.components.equippable:SetOnUnequip(onunequip)
		end
	else
		if inst.components.equippable then
			if inst.components.equippable:IsEquipped() then	
				UnEquip(inst)
			end
			inst:RemoveComponent("equippable")
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
    inst.AnimState:SetBank("gw_muhun")
    inst.AnimState:SetBuild("gw_muhun")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
	inst:AddTag("weapon")
	inst:AddTag("nopunch")
	inst:AddTag("gw_weapon")
	inst:AddTag("show_broken_ui")

	inst:AddComponent("talker")
	inst.components.talker.fontsize = 32
	inst.components.talker.offset = Vector3(0, -440, 0)
	inst.components.talker.colour = Vector3(.1, .8, 1, 1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_muhun.xml"
	inst.components.inventoryitem.imagename = "gw_muhun"
	--inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("weapon")    
	inst.components.weapon:SetDamage(10)

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(1200)
    inst.components.fueled:SetDepletedFn(OnDepleted)
	inst.components.fueled.fueltype = "NIGHTMARE"
	inst.components.fueled.accepting = true
	inst.components.fueled.ontakefuelfn = takefuel
	inst.components.fueled:SetUpdateFn(onUpdate)

	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.DIG,1.5)
	inst.components.tool:SetAction(ACTIONS.CHOP,1.5)

    inst:AddComponent("farmtiller")

	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(Useitem)

	inst:AddTag("rechargeable")
	inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(Lightning_OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(Lightning_OnCharged)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

    return inst
end


local function fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("skeleton_guishou")
    inst.AnimState:SetBuild("skeleton_guishou")
	inst.AnimState:PlayAnimation("pre",false)
	inst.AnimState:PlayAnimation("idle",true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.Transform:SetScale(1.25, 1, 1.25)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(1)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


	inst:AddComponent("timer")
	inst.components.timer:StartTimer("ontime", 30)
	inst:ListenForEvent("timerdone",inst.Remove)

    inst.persists = false

    return inst
end



----------------------------------------------------------------------
return Prefab("gw_muhun", fn, assets),
Prefab("gw_guishou", fx_fn, assets)