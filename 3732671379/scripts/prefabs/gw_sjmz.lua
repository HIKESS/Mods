
local assets =
{
    Asset("ANIM", "anim/gw_sjmz.zip"),
    Asset("ANIM", "anim/swap_sjmz.zip"),
    Asset("ATLAS","images/inventoryimages/gw_sjmz.xml"),
	Asset("IMAGE","images/inventoryimages/gw_sjmz.tex"),
	Asset("ANIM", "anim/brilliance_projectile_fx.zip"),	
}


local prefabs = {}

local cd = 30
local use = 30


local SPEED = 25 ----初始速度
local BOUNCE_RANGE = 12
local BOUNCE_SPEED = 25 ----弹射速度

local tanshe = 4

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
			inst.components.finiteuses:Use(-50)
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
		owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_sjmz", inst.GUID, "swap_sjmz")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_sjmz", "swap_sjmz")
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

local function OnAttack(inst, attacker, target, skipsanity)
	if not target:IsValid() then
		return
	end

	if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
		target.components.sleeper:WakeUp()
	end
	if target.components.combat ~= nil then
		target.components.combat:SuggestTarget(attacker)
	end
	target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
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
    inst.AnimState:SetBank("gw_sjmz")
    inst.AnimState:SetBuild("gw_sjmz")
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
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gw_sjmz.xml"
	inst.components.inventoryitem.imagename = "gw_sjmz"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(200)
	inst.components.finiteuses:SetUses(200)
	inst.components.finiteuses:SetOnFinished(OnFinished)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(10)
	inst.components.weapon:SetRange(8, 10)
	inst.components.weapon:SetOnAttack(OnAttack)
	inst.components.weapon:SetProjectile("sjmz_fx")

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(5)

	inst.gwxiufu = gwxiufu

    return inst
end
----------------------------------------------------------------------
----弹射物
local function PlayAnimAndRemove(inst, anim)
	inst.AnimState:PlayAnimation(anim)
	if not inst.removing then
		inst.removing = true
		inst:ListenForEvent("animover", inst.Remove)
	end
end

local function OnThrown(inst, owner, target, attacker)
	inst.owner = owner
	if inst.bounces == nil then
		inst.bounces = tanshe
		--local hat = attacker ~= nil and attacker.components.inventory ~= nil and attacker.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
		--inst.bounces = hat ~= nil and hat.prefab == "lunarplanthat" and TUNING.STAFF_LUNARPLANT_SETBONUS_BOUNCES or TUNING.STAFF_LUNARPLANT_BOUNCES
		inst.initial_hostile = target ~= nil and target:IsValid() and target:HasTag("hostile")
	end
end

local BOUNCE_MUST_TAGS = { "_combat" }
local BOUNCE_NO_TAGS = { "INLIMBO", "wall", "notarget", "player", "companion", "flight", "invisible", "noattack", "hiding" }

local function TryBounce(inst, x, z, attacker, target)
	if attacker.components.combat == nil or not attacker:IsValid() then
		inst:Remove()
		return
	end
	local newtarget, newrecentindex, newhostile
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, BOUNCE_RANGE, BOUNCE_MUST_TAGS, BOUNCE_NO_TAGS)) do
		if v ~= target and v.entity:IsVisible() and
			not (v.components.health ~= nil and v.components.health:IsDead()) and
			attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v)
			then
			local vhostile = v:HasTag("hostile")
			local vrecentindex
			if inst.recenttargets ~= nil then
				for i1, v1 in ipairs(inst.recenttargets) do
					if v == v1 then
						vrecentindex = i1
						break
					end
				end
			end
			if inst.initial_hostile and not vhostile and vrecentindex == nil and v.components.locomotor == nil then
				--attack was initiated against a hostile target
				--skip if non-hostile, can't move, and has never been targeted
			elseif newtarget == nil then
				newtarget = v
				newrecentindex = vrecentindex
				newhostile = vhostile
			elseif vhostile and not newhostile then
				newtarget = v
				newrecentindex = vrecentindex
				newhostile = vhostile
			elseif vhostile or not newhostile then
				if vrecentindex == nil then
					if newrecentindex ~= nil or (newtarget.prefab ~= target.prefab and v.prefab == target.prefab) then
						newtarget = v
						newrecentindex = vrecentindex
						newhostile = vhostile
					end
				elseif newrecentindex ~= nil and vrecentindex < newrecentindex then
					newtarget = v
					newrecentindex = vrecentindex
					newhostile = vhostile
				end
			end
		end
	end

	if newtarget ~= nil then
		inst.Physics:Teleport(x, 0, z)
		inst:Show()
		inst.components.projectile:SetSpeed(BOUNCE_SPEED)
		if inst.recenttargets ~= nil then
			if newrecentindex ~= nil then
				table.remove(inst.recenttargets, newrecentindex)
			end
			table.insert(inst.recenttargets, target)
		else
			inst.recenttargets = { target }
		end
		inst.components.projectile:SetBounced(true)
		inst.components.projectile.overridestartpos = Vector3(x, 0, z)
		inst.components.projectile:Throw(inst.owner, newtarget, attacker)
	else
		inst:Remove()
	end
end

local function OnHit(inst, attacker, target)
	local blast = SpawnPrefab("brilliance_projectile_blast_fx")
	local x, y, z
	if target:IsValid() then
		local radius = target:GetPhysicsRadius(0) + .2
		local angle = (inst.Transform:GetRotation() + 180) * DEGREES
		x, y, z = target.Transform:GetWorldPosition()
		x = x + math.cos(angle) * radius + GetRandomMinMax(-.2, .2)
		y = GetRandomMinMax(.1, .3)
		z = z - math.sin(angle) * radius + GetRandomMinMax(-.2, .2)
		blast:PushFlash(target)
	else
		x, y, z = inst.Transform:GetWorldPosition()
	end
	blast.Transform:SetPosition(x, y, z)

	if inst.bounces ~= nil and inst.bounces > 1 and attacker ~= nil and attacker.components.combat ~= nil and attacker:IsValid() then
		inst.bounces = inst.bounces - 1
		inst.Physics:Stop()
		inst:Hide()
		inst:DoTaskInTime(.1, TryBounce, x, z, attacker, target)
	else
		inst:Remove()
	end
end

local function OnMiss(inst, attacker, target)
	if not inst.AnimState:IsCurrentAnimation("disappear") then
		PlayAnimAndRemove(inst, "disappear")
	end
end

local function fxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("brilliance_projectile_fx")
	inst.AnimState:SetBuild("brilliance_projectile_fx")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetSymbolMultColour("light_bar", 1, 1, 1, .5)
	inst.AnimState:SetSymbolBloom("light_bar")
	inst.AnimState:SetSymbolBloom("glow")
	inst.AnimState:SetLightOverride(.5)

	inst:AddTag("projectile")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(SPEED)
	inst.components.projectile:SetRange(25)
	inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile:SetOnHitFn(OnHit)
	inst.components.projectile:SetOnMissFn(OnMiss)

	inst.persists = false

	return inst
end

----------------------------------------------------------------------
return Prefab("gw_sjmz", fn, assets),
		Prefab("sjmz_fx", fxfn, assets)