local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_arm.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_arm.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_victorian_arm.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_victorian_arm.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gold_arm.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_gold_arm.tex"),

    Asset("ANIM", "anim/sdf_arm.zip"),
    Asset("ANIM", "anim/sdf_victorian_arm.zip"),
    Asset("ANIM", "anim/sdf_gold_arm.zip"),

    Asset("ANIM", "anim/swap_sdf_arm.zip"),
    Asset("ANIM", "anim/swap_sdf_victorian_arm.zip"),
    Asset("ANIM", "anim/swap_sdf_gold_arm.zip"),

    Asset("ANIM", "anim/swap_sdf_arm_thrown.zip"),
    Asset("ANIM", "anim/swap_sdf_victorian_arm_thrown.zip"),
    Asset("ANIM", "anim/swap_sdf_gold_arm_thrown.zip"),
}

prefabs = {
}
local function OnDropped(inst)
    inst.components.inventoryitem.cangoincontainer = false

    inst:DoTaskInTime(2, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("lucy_transform_fx").Transform:SetPosition(x,_,z)
	inst:Remove()
    end)
end

local function OnPickupFn(inst, picker)
    if picker.prefab ~= "sdf" then

	--Remove Arm
	inst:DoTaskInTime(0.1, function()
	    local myContainer = inst.components.inventoryitem:GetContainer()
	    if myContainer ~= nil then
		myContainer:DropItem(inst)
	    else
		inst:Remove()
	    end
	end)
    end
end

local function armThrow(inst, target)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end
    
    --Create thrown arm
    local projectile = SpawnPrefab("sdf_arm_thrown")

    --Create correct arm skin
    if owner.prefab == "sdf" then
	local bodyItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	if bodyItem and bodyItem.prefab == "sdf_victorian_suit" then
	    inst.AnimState:SetBank("sdf_victorian_arm")
	    inst.AnimState:SetBuild("sdf_victorian_arm")
	    projectile.AnimState:SetBank("swap_sdf_victorian_arm_thrown")
	    projectile.AnimState:SetBuild("swap_sdf_victorian_arm_thrown")
	elseif bodyItem and bodyItem.prefab == "sdf_gold_armor" then
	    inst.AnimState:SetBank("sdf_gold_arm")
	    inst.AnimState:SetBuild("sdf_gold_arm")
	    projectile.AnimState:SetBank("swap_sdf_gold_arm_thrown")
	    projectile.AnimState:SetBuild("swap_sdf_gold_arm_thrown")
	end
    end


    --Continue throw arm
    projectile.Transform:SetPosition(owner.Transform:GetWorldPosition())
    projectile.components.projectile:Throw(owner, target)

    --Add Thrown Tag
    owner:AddTag("sdf_thrown_arm")

    inst:Remove()
end

local function onequip(inst, owner)
    if owner.prefab == "sdf" then
	local bodyItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	if bodyItem and bodyItem.prefab == "sdf_victorian_suit" then
	    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_victorian_arm", "swap_sdf_victorian_arm")

	    inst.AnimState:SetBank("sdf_victorian_arm")
	    inst.AnimState:SetBuild("sdf_victorian_arm")
	    inst.components.inventoryitem.imagename = "sdf_victorian_arm"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_victorian_arm.xml"
	elseif bodyItem and bodyItem.prefab == "sdf_gold_armor" then
	    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_gold_arm", "swap_sdf_gold_arm")

	    inst.AnimState:SetBank("sdf_gold_arm")
	    inst.AnimState:SetBuild("sdf_gold_arm")
	    inst.components.inventoryitem.imagename = "sdf_gold_arm"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_gold_arm.xml"
	else
	    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_arm", "swap_sdf_arm")

	    inst.AnimState:SetBank("sdf_arm")
	    inst.AnimState:SetBuild("sdf_arm")
	    inst.components.inventoryitem.imagename = "sdf_arm"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_arm.xml"
	end

	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	owner.components.combat:SetAttackPeriod(TUNING.SDF_ARM_ATTACK_SPEED)
    else
	--Stops others from wearing
	inst:DoTaskInTime(0.1, function()
	local hand = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if hand then
		if owner.components.talker then
		    owner.components.talker:Say(GetString(owner, "ANNOUNCE_NODANIELARM"))
		end
		local item = owner.components.inventory:Unequip(EQUIPSLOTS.HANDS)
	    end
	end)
    end
end

local function onunequip(inst, owner)
    if owner.prefab == "sdf" then
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)

	--Remove Arm with FX
	inst:DoTaskInTime(0.1, function()
	    if owner:HasTag("sdf_thrown_arm") then
		inst:Remove()
	    else

		--FX
		owner.sdf_arm_fx = SpawnPrefab("sleepbomb_burst")
		owner.sdf_arm_fx.entity:SetParent(owner.entity)

		owner:DoTaskInTime(1,function()
		    if owner.sdf_arm_fx ~= nil then
			owner.sdf_arm_fx = nil
		    end
		end)

		inst:Remove()
	    end
	end)
    else
	--Remove Arm
	inst:DoTaskInTime(0.1, function()
	    local myContainer = inst.components.inventoryitem:GetContainer()
	    if myContainer ~= nil then
		myContainer:DropItem(inst)
	    else
		inst:Remove()
	    end
	end)
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_arm")
    inst.AnimState:SetBuild("sdf_arm")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("sdf_two_handed")

    inst.spelltype = "SDF_ARM_THROW"

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_ARM_DAMAGE)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster:SetSpellFn(armThrow)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseoncombat = true

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst.components.inventoryitem.imagename = "sdf_arm"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_arm.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.persists = false

    return inst
end

local function CreateNewArm(inst)
    local newArm = SpawnPrefab("sdf_arm")
    return newArm
end

local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.components.inventoryitem.pushlandedevents = false
end

local function OnCaught(inst, catcher)
    if catcher ~= nil and catcher.components.inventory ~= nil and catcher.components.inventory.isopen then
        if not catcher.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and not catcher.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD) then
            catcher.components.inventory:Equip(CreateNewArm(inst))
        end
	inst:Remove()

	--Remove Thrown Tag
	if catcher:HasTag("sdf_thrown_arm") then
	    catcher:RemoveTag("sdf_thrown_arm")
	end
        catcher:PushEvent("catch")
    end
end

local function ReturnToOwner(inst, owner)
    if owner ~= nil then
	if owner.components.catcher then
	    owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_return")
	    inst.components.projectile:Throw(owner, owner)
	end
    end
end

local function OnHit(inst, owner, target)
    --After target hit
    --if owner == target or owner:HasTag("playerghost") then
	--OnDropped(inst)
    --else
	--inst.AnimState:PlayAnimation("thrown", true)
	ReturnToOwner(inst, owner)
    --end

    if target ~= nil and target:IsValid() and target.components.combat then
        local impactfx = SpawnPrefab("impact")
        if impactfx ~= nil then
            local follower = impactfx.entity:AddFollower()
            follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
            impactfx:FacePoint(inst.Transform:GetWorldPosition())
        end
    end
end

local function OnMiss(inst, owner, target)
    if owner == target then
        OnDropped(inst)
    else
        ReturnToOwner(inst, owner)
    end
end

local function thrownfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("swap_sdf_arm_thrown")
    inst.AnimState:SetBuild("swap_sdf_arm_thrown")
    inst.AnimState:PlayAnimation("thrown", true)
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("weapon")
    inst:AddTag("projectile")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_ARM_DAMAGE / 2)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_ARM_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(true)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetOnCaughtFn(OnCaught)
    local oldhit = inst.components.projectile.Hit
    function inst.components.projectile:Hit(target)
	if target == self.owner and target.components.catcher then
	    if not target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and not target.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD) then
		target:PushEvent("catch", {projectile = self.inst})
		self.inst:PushEvent("caught", {catcher = target})
		self:Catch(target)
		target.components.catcher:StopWatching(self.inst)
	    else

		--Remove Thrown Tag
		if target:HasTag("sdf_thrown_arm") then
		    target:RemoveTag("sdf_thrown_arm")
		end

		self.inst:Remove()
		target:PushEvent("catch")
	    end
	else
	    oldhit(self, target)
	end
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst.persists = false

    return inst
end

return  Prefab("common/inventory/sdf_arm", fn, assets),
	Prefab( "sdf_arm_thrown", thrownfn, assets)