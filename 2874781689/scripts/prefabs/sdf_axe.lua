local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_axe.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_axe.tex"),

    Asset("ANIM", "anim/sdf_axe.zip"),
    Asset("ANIM", "anim/swap_sdf_axe.zip"),
}

prefabs = {
}

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
end

local function onattacked(inst, owner, target)
    --Swingfx
    inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/bag_swing")
end

local function axeThrow(inst, target)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end
    
    --Create thrown axe
    local axeDurability = inst.components.finiteuses:GetUses()
    local projectile = SpawnPrefab("sdf_axe_thrown")
    projectile.Transform:SetPosition(owner.Transform:GetWorldPosition())
    projectile.components.projectile:Throw(owner, target)
    projectile.components.finiteuses:SetUses(axeDurability)

    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_axe", "swap_sdf_axe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_AXE_ATTACK_SPEED)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_axe")
    inst.AnimState:SetBuild("sdf_axe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("tool")

    inst.spelltype = "SDF_AXE_THROW"

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_AXE_DAMAGE)
    inst.components.weapon.onattack = onattacked

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.SDF_AXE_WORK_CHOP)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.quickcast = true
    inst.components.spellcaster:SetSpellFn(axeThrow)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseoncombat = true

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_AXE_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_AXE_DURABILITY)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, TUNING.SDF_AXE_WORK_CONSUME)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_axe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_axe.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end


local function CreateNewAxe(inst)
    local axeDurability = inst.components.finiteuses:GetUses()

    local newAxe = SpawnPrefab("sdf_axe")
    newAxe.components.finiteuses:SetUses(axeDurability)
    return newAxe
end

local function OnFinished(inst, owner)
    local brokentool = SpawnPrefab("brokentool")
    brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition() )
    inst:Remove()
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.components.inventoryitem.pushlandedevents = true
    inst:PushEvent("on_landed")

    local newAxe = CreateNewAxe(inst)
    newAxe.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
end

local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.components.inventoryitem.pushlandedevents = false
end

local function OnCaught(inst, catcher)
    if catcher ~= nil and catcher.components.inventory ~= nil and catcher.components.inventory.isopen then
        if not catcher.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
            catcher.components.inventory:Equip(CreateNewAxe(inst))
        else
            catcher.components.inventory:GiveItem(CreateNewAxe(inst))
        end
	inst:Remove()
        catcher:PushEvent("catch")
    end
end

local function ReturnToOwner(inst, owner)
    if owner ~= nil and not (inst.components.finiteuses ~= nil and inst.components.finiteuses:GetUses() < 1) then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_return")
        inst.components.projectile:Throw(owner, owner)
    end
end

local function OnHit(inst, owner, target)

    --Damage Axe
    inst.components.finiteuses:Use(TUNING.SDF_AXE_USAGE)

    --After target hit
    if inst.components.finiteuses:GetUses() <= 0 then
	OnFinished(inst, owner)
    else
	if owner == target or owner:HasTag("playerghost") then
	    OnDropped(inst)
	else
	    ReturnToOwner(inst, owner)
	end
    end

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

    inst.AnimState:SetBank("swap_sdf_axe")
    inst.AnimState:SetBuild("swap_sdf_axe")
    inst.AnimState:PlayAnimation("thrown", true)
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("projectile")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_AXE_DAMAGE * TUNING.SDF_AXE_THROW_DAMAGE_MULTI)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_AXE_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_AXE_DURABILITY)
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_AXE_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(true)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetOnCaughtFn(OnCaught)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    return inst
end

return  Prefab("common/inventory/sdf_axe", fn, assets),
	Prefab( "sdf_axe_thrown", thrownfn, assets)