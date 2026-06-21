local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_magic_sword.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_magic_sword.tex"),

    Asset("ATLAS", "images/map_icons/sdf_magic_sword_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_magic_sword_mm.tex"),

    Asset("ANIM", "anim/sdf_magic_sword.zip"),
    Asset("ANIM", "anim/swap_sdf_magic_sword.zip"),
}

prefabs = {
}

local function onfinished(inst, owner)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        local brokentool = SpawnPrefab("brokentool")
        brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
end

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
end

local function magicSwordRegen(inst)
    local currentDurability = inst.components.finiteuses:GetPercent()
    if currentDurability < 1 then
	inst.components.finiteuses:SetPercent(currentDurability + TUNING.SDF_MAGIC_SWORD_REGEN)
    end
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
    elseif random<0.4 then --slash
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
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_magic_sword", "swap_sdf_magic_sword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    inst.Light:Enable(true)
    owner.components.combat:SetAttackPeriod(TUNING.SDF_MAGIC_SWORD_ATTACK_SPEED)
    owner.components.combat:SetAreaDamage(TUNING.SDF_MAGIC_SWORD_AOE_RANGE, 0.33)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst.Light:Enable(false)
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    owner.components.combat.areahitrange = nil
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddLight()
    inst.Light:SetRadius(0.45)
    inst.Light:SetFalloff(1.0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(40/255,40/255,250/255)	

    inst.MiniMapEntity:SetIcon("sdf_magic_sword_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_magic_sword")
    inst.AnimState:SetBuild("sdf_magic_sword")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_MAGIC_SWORD_DAMAGE)
    inst.components.weapon:SetOnAttack(OnAttackFn)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_MAGIC_SWORD_PLANAR_DAMAGE)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_MAGIC_SWORD_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_MAGIC_SWORD_DURABILITY)
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_magic_sword"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_magic_sword.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.magicSwordRegentask = inst:DoPeriodicTask(30, function() magicSwordRegen(inst) end)

    return inst
end

return  Prefab("common/inventory/sdf_magic_sword", fn, assets)