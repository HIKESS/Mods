local assets =
{
    Asset("ANIM", "anim/wiltonmod_armor.zip"),
    Asset("ATLAS", "images/inventoryimages/wiltonmod_armor.xml"),
    Asset("IMAGE", "images/inventoryimages/wiltonmod_armor.tex"),
}

local function onequip(inst, owner)
    --owner.AnimState:OverrideSymbol("swap_body", "wiltonmod_armor", "swap_body")
    owner.AnimState:OverrideSymbol("swap_body", "wiltonmod_armor", "swap_body")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local GetUseTable = {
    nightmarefuel = 0.2,
}

local function CanTakeItem(inst, ammo, giver)
    return GetUseTable[ammo.prefab] ~= nil and inst.components.armor:GetPercent() < 1
end

local function OnGetItemFromPlayer(inst, giver, item)  
    if item and GetUseTable[item.prefab] ~= nil and inst.components.armor:GetPercent() < 1 then
        local rapair_amount = inst.components.armor.maxcondition * GetUseTable[item.prefab]
        inst.components.armor:Repair(rapair_amount)

        inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")  
    end      
end

local function SetupComponents(inst)
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "wiltonmod"
end

local function DisableComponents(inst)
    inst:RemoveComponent("equippable")
end

local function OnBroken(inst)
    if inst.components.equippable ~= nil then
        DisableComponents(inst)
        inst:AddTag("broken")
    end
end

local function OnRepaired(inst)
    if inst.components.equippable == nil then
        SetupComponents(inst)
        inst:RemoveTag("broken")
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --inst.AnimState:SetBank("wiltonmod_armor")
    --inst.AnimState:SetBuild("wiltonmod_armor")
    --inst.AnimState:PlayAnimation("anim_90s")

    inst.AnimState:SetBank("wiltonmod_armor")
    inst.AnimState:SetBuild("wiltonmod_armor")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("grass")
    inst:AddTag("wiltonmod_item")
    inst:AddTag("wiltonmod_armor")

    inst.foleysound = "dontstarve/movement/foley/bone"

    MakeInventoryPhysics(inst)
    local swap_data = { bank = "wiltonmod_armor", anim = "anim" }
    -- 为护甲设置浮水动画数据，保证在水面/地面时使用 anim_90s 动画
    MakeInventoryFloatable(inst, "small", 0.2, 0.80, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem:ChangeImageName("armorskeleton")
    inst.components.inventoryitem.imagename = "wiltonmod_armor"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_armor.xml"
    --inst.components.inventoryitem.imagename = "armorgrass"    
    --inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(1500, 0)
    inst.components.armor.keeponfinished = true

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(40)

    inst:ListenForEvent("percentusedchange", function(inst, data)
        if data.percent and data.percent > 0 then
            OnRepaired(inst)
        --else
            --OnBroken(inst)
        end     
    end) 

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "wiltonmod"

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:DoPeriodicTask(1, function(inst)
        if inst.components.equippable then
        if inst.components.equippable:IsEquipped() and inst.components.armor:GetPercent() < 0.5 then
            local owner = inst.components.inventoryitem.owner
            inst.components.equippable.dapperness = 0
            inst.components.armor:Repair(20/60)
        else
            inst.components.equippable.dapperness = 0  
        end
        end	
    end)

    MakeForgeRepairable(inst, FORGEMATERIALS.VOIDCLOTH, OnBroken, OnRepaired)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wiltonmod_armor", fn, assets)
