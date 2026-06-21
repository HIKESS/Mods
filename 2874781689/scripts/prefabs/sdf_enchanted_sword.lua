local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_enchanted_sword.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_enchanted_sword.tex"),

    Asset("ANIM", "anim/sdf_enchanted_sword.zip"),
    Asset("ANIM", "anim/swap_sdf_enchanted_sword.zip"),
}

prefabs = {
}

local function onperish (inst, owner)
    --Spawns in inventory
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
    local broadSword = SpawnPrefab("sdf_broad_sword")
    if holder ~= nil then
	holder:Equip(broadSword)
	inst:Remove()
    end
end

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
end

local function enchantmentFX(inst, player)
    inst._fx = SpawnPrefab("spider_heal_target_fx")
    inst._fx.entity:SetParent(inst.entity)
end

local function OnAttackFn(inst, attacker, target)
    --Swingfx
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/swipe")

    --Random Animation
    local random=math.random()
    if random<0.1 then --jab
	if not inst:HasTag("sdf_jabweapon") then
	    inst:AddTag("sdf_jabweapon")
	end
	if inst:HasTag("sdf_propweapon") then
	    inst:RemoveTag("sdf_propweapon")
	end
    elseif random<0.3 then --slash
	if not inst:HasTag("sdf_propweapon") then
	    inst:AddTag("sdf_propweapon")
	end
	if inst:HasTag("sdf_jabweapon") then
	    inst:RemoveTag("sdf_jabweapon")
	end
    else --normal
	if inst:HasTag("sdf_propweapon") then
	    inst:RemoveTag("sdf_propweapon")
	end
	if inst:HasTag("sdf_jabweapon") then
	    inst:RemoveTag("sdf_jabweapon")
	end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_enchanted_sword", "swap_sdf_enchanted_sword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    inst.Light:Enable(true)
    owner.components.combat:SetAttackPeriod(TUNING.SDF_ENCHANTED_SWORD_ATTACK_SPEED)
    owner.components.combat:SetAreaDamage(TUNING.SDF_ENCHANTED_SWORD_AOE_RANGE, 0.33)

    if inst.components.fueled then
	inst.components.fueled:StartConsuming()
    end

    --Add EnchantmentFX
    inst.enchantmentFXtask = inst:DoPeriodicTask(3, function() enchantmentFX(inst, owner) end)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst.Light:Enable(false)
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    owner.components.combat.areahitrange = nil

    if inst.components.fueled then
	inst.components.fueled:StopConsuming()
    end

    --Remove EnchantmentFX
    if inst.enchantmentFXtask ~= nil then
	inst.enchantmentFXtask:Cancel()
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddLight()
    inst.Light:SetRadius(0.45)
    inst.Light:SetFalloff(1.0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(245/255,206/255,39/255)	

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_enchanted_sword")
    inst.AnimState:SetBuild("sdf_enchanted_sword")
    inst.AnimState:PlayAnimation("idle")	

    inst:AddTag("sharp")
    inst:AddTag("weapon")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_ENCHANTED_SWORD_DAMAGE)
    inst.components.weapon:SetOnAttack(OnAttackFn)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_ENCHANTED_SWORD_PLANAR_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_enchanted_sword"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_enchanted_sword.xml"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.SDF_ENCHANTED_SWORD_DURATION * 1.3)
    inst.components.fueled:SetDepletedFn(onperish)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.enchantmentFXtask = nil

    return inst
end

return  Prefab("common/inventory/sdf_enchanted_sword", fn, assets)