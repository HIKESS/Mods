local assets =
{
    Asset("ANIM", "anim/jx_baguette.zip"),
}

local function UpdateDamage(inst)
  if inst.components.perishable and inst.components.weapon then
    local percent = inst.components.perishable:GetPercent()
    local dmg = 34 * (1 - percent) + 34
    inst.components.weapon:SetDamage(dmg)
  end
end

local function oneaten(inst, eater)
  if eater and eater.components.talker then
    eater.components.talker:Say(STRINGS.CHARACTERS.GENERIC.ANNOUNCE_EAT.GENERIC) -- "好吃！"
  end
end

local function ChangeToEdible(inst, ediblevalue, additem)
  inst:AddTag("jx_baguette_edible")
  
  if inst.components.edible == nil then
    inst:AddComponent("edible")
  end
  local additem_edible = additem and additem.components.edible
  inst.components.edible.healthvalue = (ediblevalue and ediblevalue.healthvalue) or (additem_edible and (additem_edible.healthvalue + 4)) or 10
  inst.components.edible.hungervalue = (ediblevalue and ediblevalue.hungervalue) or (additem_edible and (additem_edible.hungervalue + 22.5)) or 60
  inst.components.edible.sanityvalue = (ediblevalue and ediblevalue.sanityvalue) or (additem_edible and (additem_edible.sanityvalue + 10)) or 10
  inst.components.edible:SetOnEatenFn(oneaten)
  
  if inst.components.equippable ~= nil then
    if inst.components.equippable:IsEquipped() then
      local owner = inst.components.inventoryitem.owner
      if owner ~= nil and owner.components.inventory ~= nil then
        local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
        if item ~= nil then
          owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
        end
      end
    end
    inst:RemoveComponent("equippable")
    inst:RemoveComponent("weapon")
  end
  
  if inst.components.perishable then
    inst.components.perishable:SetPercent(1)
  end
end

local function onequip(inst, owner)
  UpdateDamage(inst)
  owner.AnimState:OverrideSymbol("swap_object", "jx_baguette", "swap_spear")
  owner.AnimState:Show("ARM_carry")
  owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
  UpdateDamage(inst)
  owner.AnimState:Hide("ARM_carry")
  owner.AnimState:Show("ARM_normal")
end

local function GetDescription(inst)
  return inst:HasTag("jx_baguette_edible") and STRINGS.CHARACTERS.GENERIC.DESCRIBE.JX_BAGUETTE_EDIBLE or nil
end

local function OnSave(inst, data)
  if inst.components.edible then
    data.ediblevalue =
    {
      healthvalue = inst.components.edible.healthvalue,
      hungervalue = inst.components.edible.hungervalue,
      sanityvalue = inst.components.edible.sanityvalue
    }
  end
end

local function OnLoad(inst, data)
  UpdateDamage(inst)
  if data and data.ediblevalue then
    inst:ChangeToEdible(data.ediblevalue)
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("jx_baguette")
    inst.AnimState:SetBuild("jx_baguette")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("show_spoilage")
    inst:AddTag("icebox_valid")
    inst:AddTag("weapon")
    inst:AddTag("jx_baguette")
    
    local swap_data = {sym_build = "jx_baguette", bank = "jx_baguette"}
    MakeInventoryFloatable(inst, "med", nil, {1.0, 0.5, 1.0}, true, -13, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW) -- 15天
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)
    inst.components.weapon:SetOnAttack(UpdateDamage)

    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = GetDescription

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
        
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    
    inst.ChangeToEdible = ChangeToEdible
    
    inst:DoPeriodicTask(20, UpdateDamage)

    return inst
end

return Prefab("jx_baguette", fn, assets)