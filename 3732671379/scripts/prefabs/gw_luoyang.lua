local assets =
{
	Asset("ANIM", "anim/gw_luoyang.zip"),
    Asset("ANIM", "anim/swap_luoyang.zip"),
	Asset("ATLAS","images/inventoryimages/gw_luoyang.xml"),
	Asset("IMAGE","images/inventoryimages/gw_luoyang.tex"),	
}

local function onequip(inst, owner) 
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")

	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil then
		owner:PushEvent("equipskinneditem", inst:GetSkinName())
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_luoyang", inst.GUID, "swap_luoyang")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_luoyang", "swap_luoyang")
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
end

local function Lightning_OnDischarged(inst)
	
end

local function Lightning_OnCharged(inst)
	inst.components.useableitem:StopUsingItem()
end

local function OnFinished(inst)
	if inst.components.finiteuses:GetUses() <= 0 then
        inst:Remove()
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
    inst.AnimState:SetBank("gw_luoyang")
    inst.AnimState:SetBuild("gw_luoyang")
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
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_luoyang.xml"
	inst.components.inventoryitem.imagename = "gw_luoyang"
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("weapon")    
	inst.components.weapon:SetDamage(10)

    inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(150)
	inst.components.finiteuses:SetUses(150)
	inst.components.finiteuses:SetOnFinished(OnFinished)
	inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1)
	inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)

	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.DIG,1.3)
	inst.components.tool:SetAction(ACTIONS.CHOP, 1.3)

    inst:AddComponent("farmtiller")

	inst:AddComponent("useableitem")
	inst.components.useableitem:SetOnUseFn(Useitem)

	inst:AddTag("rechargeable")
	inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(Lightning_OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(Lightning_OnCharged)

    return inst
end

return Prefab("gw_luoyang", fn, assets)