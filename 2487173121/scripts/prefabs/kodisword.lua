local assets =
{
    Asset("ANIM", "anim/kodisword.zip"),
    Asset("ANIM", "anim/swap_kodisword.zip"),
    Asset("ATLAS", "images/inventoryimages/kodisword.xml"),
    Asset("IMAGE", "images/inventoryimages/kodisword.tex"),
}
local SECOND_FORM_ENABLED = false
local DAMAGE_KODI = 51
local DAMAGE_DEMON = 60
local DAMAGE_OTHER = 42
local MAX_USES = 400
local FORM_TINT = {
    fox = { 1.0, 1.0, 1.0 },
    demon = { 0.7, 0.5, 1.0 },
}
local function IsOwnerDemon(owner)
    return owner and owner:HasTag("kodi") and not owner:HasTag("NotDemon")
end
local function IsOwnerKodi(owner)
    return owner and owner:HasTag("kodi")
end
local function UpdateVisuals(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    local r, g, b = 1, 1, 1
    if SECOND_FORM_ENABLED and IsOwnerKodi(owner) and IsOwnerDemon(owner) then
        local form_tint = FORM_TINT.demon
        r, g, b = form_tint[1], form_tint[2], form_tint[3]
    end
    inst.AnimState:SetMultColour(r, g, b, 1)
    if owner and owner.AnimState then
        owner.AnimState:SetSymbolMultColour("swap_object", r, g, b, 1)
    end
end
local function UpdateStats(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    local damage
    if IsOwnerKodi(owner) then
        if SECOND_FORM_ENABLED and IsOwnerDemon(owner) then
            damage = DAMAGE_DEMON
        else
            damage = DAMAGE_KODI
        end
    else
        damage = DAMAGE_OTHER
    end
    inst.components.weapon:SetDamage(damage)
    UpdateVisuals(inst)
end
local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_kodisword", "swap_kodisword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if SECOND_FORM_ENABLED and IsOwnerKodi(owner) then
        inst._form_listener = function()
            UpdateStats(inst)
        end
        inst:ListenForEvent("kodi_form_changed", inst._form_listener, owner)
    end
    UpdateStats(inst)
end
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:SetSymbolMultColour("swap_object", 1, 1, 1, 1)
    if inst._form_listener then
        inst:RemoveEventCallback("kodi_form_changed", inst._form_listener, owner)
        inst._form_listener = nil
    end
    UpdateVisuals(inst)
end
local function GetDescription(inst, viewer)
    local is_kodi = viewer and viewer:HasTag("kodi")
    if SECOND_FORM_ENABLED and is_kodi then
        local is_demon = not viewer:HasTag("NotDemon")
        if is_demon then
            return "Demon Form: " .. DAMAGE_DEMON .. " damage"
        else
            return "Fox Form: " .. DAMAGE_KODI .. " damage"
        end
    end
    if is_kodi then
        return "Damage: " .. DAMAGE_KODI
    else
        return "Damage: " .. DAMAGE_OTHER
    end
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("kodisword.tex")
    inst.AnimState:SetBank("kodisword")
    inst.AnimState:SetBuild("kodisword")
    inst.AnimState:PlayAnimation("idle")
    local swap_data = {sym_build = "swap_kodisword"}
    MakeInventoryFloatable(inst, "med", 0.05, {0.85, 0.45, 0.85}, true, 1, swap_data)
    inst:AddTag("sharp")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(DAMAGE_OTHER)
    inst:AddComponent("inspectable")
    inst.components.inspectable.getspecialdescription = GetDescription
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(MAX_USES)
    inst.components.finiteuses:SetUses(MAX_USES)
    inst.components.finiteuses:SetConsumption(ACTIONS.ATTACK, 1)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "kodisword"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/kodisword.xml"
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    MakeHauntableLaunch(inst)
    return inst
end
return Prefab("kodisword", fn, assets)
