local assets =
{
    Asset("ANIM", "anim/swap_wiltonmod_sharpbone.zip"),
    Asset("ANIM", "anim/broken_bone_spear.zip"),
    Asset("ANIM", "anim/broken_bone_spear_swap.zip"),
    Asset("ANIM", "anim/stonesword.zip"),
    Asset("ANIM", "anim/stonesword_swap.zip"),

    Asset("ATLAS", "images/inventoryimages/wiltonmod_sharpbone.xml"),
    Asset("ATLAS", "images/inventoryimages/wiltonmod_sharpbone_skin.xml"),
    Asset("ATLAS", "images/inventoryimages/wiltonmod_sharpbone_stonesword.xml"),
}

local function onattack(inst, attacker, target)
    inst.atk_time = inst.atk_time + 1

    if inst.atk_time >= 3 then
        inst.atk_time = 0
        inst:AddTag("multithruster")
    else
        inst:RemoveTag("multithruster")  
    end
end    

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_wiltonmod_sharpbone", "swap_wiltonmod_sharpbone")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onequip_skin(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "broken_bone_spear_swap", "broken_bone_spear_swap")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onequip_stonesword(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "stonesword_swap", "stonesword_swap")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnThrust(inst, doer, target)
    if doer and target and target.components.combat and inst.thrust_time <= 2 then 
        doer.components.combat:DoAttack(target)

        inst.atk_time = 0
        inst:RemoveTag("multithruster")

        inst.thrust_time = inst.thrust_time + 1
    end             
end

local GetUseTable = {
    boneshard = 75,
}

local function CanTakeItem(inst, ammo, giver)
    return GetUseTable[ammo.prefab] ~= nil and inst.components.finiteuses:GetPercent() < 1
end

local function OnGetItemFromPlayer(inst, giver, item)  
    if item and GetUseTable[item.prefab] ~= nil and inst.components.finiteuses:GetPercent() < 1 then
        local rapair_amount = GetUseTable[item.prefab] or 80
        inst.components.finiteuses:Repair(rapair_amount)

        inst.SoundEmitter:PlaySound("aqol/new_test/rock")    
    end      
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("swap_wiltonmod_sharpbone")
    inst.AnimState:SetBuild("swap_wiltonmod_sharpbone")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")
    inst:AddTag("jab")
    inst:AddTag("wiltonmod_item")
    inst:AddTag("wiltonmod_sharpbone_weapon")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.atk_time = 0
    inst.thrust_time = 0

    inst:AddComponent("weapon")
    -- 尖骨头本体伤害从 TUNING 读取，支持配置调整。
    inst.components.weapon:SetDamage(TUNING.WILTON_SHARPBONE_DAMAGE or 45)
    inst.components.weapon:SetRange(1.5)
    inst.components.weapon:SetOnAttack(onattack) 

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(400)
    inst.components.finiteuses:SetUses(400)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_sharpbone"    
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_sharpbone.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("mach_multithruster")
    inst.components.multithruster = inst.components.mach_multithruster
    inst.components.multithruster:SetThrustfn(OnThrust)
    inst:RegisterComponentActions("multithruster")

    MakeHauntableLaunch(inst)

    return inst
end

local function skin()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("broken_bone_spear")
    inst.AnimState:SetBuild("broken_bone_spear")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")
    inst:AddTag("jab")
    inst:AddTag("wiltonmod_item")
    inst:AddTag("wiltonmod_sharpbone_weapon")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.atk_time = 0
    inst.thrust_time = 0

    inst:AddComponent("weapon")
    -- 皮肤版尖骨头共享同一份可配置伤害。
    inst.components.weapon:SetDamage(TUNING.WILTON_SHARPBONE_DAMAGE or 45)
    inst.components.weapon:SetRange(1.5)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(400)
    inst.components.finiteuses:SetUses(400)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_sharpbone_skin"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_sharpbone_skin.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip_skin)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("mach_multithruster")
    inst.components.multithruster = inst.components.mach_multithruster
    inst.components.multithruster:SetThrustfn(OnThrust)
    inst:RegisterComponentActions("multithruster")

    MakeHauntableLaunch(inst)

    return inst
end

local function stonesword_skin()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("stonesword")
    inst.AnimState:SetBuild("stonesword")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")
    inst:AddTag("jab")
    inst:AddTag("wiltonmod_item")
    inst:AddTag("wiltonmod_sharpbone_weapon")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.atk_time = 0
    inst.thrust_time = 0

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(45)
    inst.components.weapon:SetRange(1.5)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(400)
    inst.components.finiteuses:SetUses(400)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_sharpbone_stonesword"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_sharpbone_stonesword.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip_stonesword)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("mach_multithruster")
    inst.components.multithruster = inst.components.mach_multithruster
    inst.components.multithruster:SetThrustfn(OnThrust)
    inst:RegisterComponentActions("multithruster")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wiltonmod_sharpbone", fn, assets),
       Prefab("wiltonmod_sharpbone_skin", skin, assets),  
       Prefab("wiltonmod_sharpbone_stonesword", stonesword_skin, assets)