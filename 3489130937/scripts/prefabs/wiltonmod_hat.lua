local assets =
{
    Asset("ANIM", "anim/wiltonmod_hat.zip"),
    Asset("ATLAS", "images/inventoryimages/wiltonmod_hat.xml"),
    Asset("IMAGE", "images/inventoryimages/wiltonmod_hat.tex"),
}

local function onequip(inst, owner)
    --owner.AnimState:OverrideSymbol("swap_hat", "hat_football", "swap_hat")
    --owner.AnimState:OverrideSymbol("swap_hat", "hat_skeleton", "swap_hat")
    owner.AnimState:OverrideSymbol("swap_hat", "wiltonmod_hat", "swap_hat")

    if owner:HasTag("player") then
        -- fullhelm 效果：玩家时隐藏头部与面部符号，使用 HEAD_HAT_HELM 图层表现头盔
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        owner.AnimState:Hide("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")

        owner.AnimState:HideSymbol("face")
        owner.AnimState:HideSymbol("swap_face")
        owner.AnimState:HideSymbol("beard")
        owner.AnimState:HideSymbol("cheeks")
    else
        -- 非玩家按普通帽子显示逻辑处理
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end        
end 

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")

        owner.AnimState:ShowSymbol("face")
        owner.AnimState:ShowSymbol("swap_face")
        owner.AnimState:ShowSymbol("beard")
        owner.AnimState:ShowSymbol("cheeks")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end          
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

local function turnon(inst)
    inst.TurnOn = not inst.TurnOn
    return false
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

    --inst.AnimState:SetBank("footballhat")
    --inst.AnimState:SetBuild("hat_football")
    --inst.AnimState:PlayAnimation("anim")

    --inst.AnimState:SetBank("skeletonhat")
    --inst.AnimState:SetBuild("hat_skeleton")
    --inst.AnimState:PlayAnimation("anim")

    -- 使用自定义 wiltonmod_hat 的地面动画
    inst.AnimState:SetBank("wiltonmod_hat")
    inst.AnimState:SetBuild("wiltonmod_hat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
    inst:AddTag("wiltonmod_item")

	inst:AddTag("shadowlevel")
    inst:AddTag("shadowdominance")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    -- 绑定浮水时使用的 bank/anim，避免默认使用不存在的 idle 动画
    inst.components.floater:SetBankSwapOnFloat(false, nil, { bank = "wiltonmod_hat", anim = "anim" })

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem:ChangeImageName("skeletonhat")
    inst.components.inventoryitem.imagename = "wiltonmod_hat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_hat.xml"

    --inst.components.inventoryitem.imagename = "footballhat"    
    --inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(1500, 0.9)
    inst.components.armor.keeponfinished = true

    inst:ListenForEvent("percentusedchange", function(inst, data)
        if data.percent and data.percent > 0 then
            OnRepaired(inst)
        --else
            --OnBroken(inst)
        end     
    end)    

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "wiltonmod"

    inst:AddComponent("shadowdominance")

    inst.TurnOn = true
--[[
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(turnon)
    inst.components.spellcaster.canuseontargets = false
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.quickcast = true
]]
    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(turnon)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:DoPeriodicTask(1, function(inst)
        if inst.components.equippable then
        if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.armor:GetPercent() < 0.5 then
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

return Prefab("wiltonmod_hat", fn, assets)
