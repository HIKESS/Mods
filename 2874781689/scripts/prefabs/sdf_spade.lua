local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_spade.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_spade.tex"),

    Asset("ATLAS", "images/map_icons/sdf_spade_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_spade_mm.tex"),

    Asset("ANIM", "anim/sdf_spade.zip"),
    Asset("ANIM", "anim/swap_sdf_spade.zip"),
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

local function OnAttackFn(inst, attacker, target)
    --Swingfx
    inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/bag_swing")

    --Random Animation
    local random=math.random()
    if random<0.2 then --jab
	if not inst:HasTag("sdf_jabweapon") then
	    inst:AddTag("sdf_jabweapon")
	end
    else --normal
	if inst:HasTag("sdf_jabweapon") then
	    inst:RemoveTag("sdf_jabweapon")
	end
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_spade", "swap_shovel")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_SPADE_ATTACK_SPEED)
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
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_spade_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_spade")
    inst.AnimState:SetBuild("sdf_spade")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("tool")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_SPADE_DAMAGE)
    inst.components.weapon:SetOnAttack(OnAttackFn)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_SPADE_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_SPADE_DURABILITY)
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.DIG, TUNING.SDF_SPADE_WORK_CONSUME)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)

    inst:AddInherentAction(ACTIONS.DIG)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_spade"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_spade.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_spade", fn, assets)