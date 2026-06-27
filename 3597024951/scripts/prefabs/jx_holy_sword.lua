local assets =
{
  Asset("ANIM", "anim/swap_jx_holy_sword.zip"),
}

local function StartRemoveTask(inst)
  inst:AddTag("NOCLICK")
  inst.persists = false
  if inst.colour_delay_task then
    inst.colour_delay_task:Cancel()
    inst.colour_delay_task = nil
  end
  inst.colour_delay_task = inst:DoTaskInTime(1, function()
    local life = 50
    local colour = 1
    if inst.colour_period_task then
      inst.colour_period_task:Cancel()
      inst.colour_period_task = nil
    end
    inst.colour_period_task = inst:DoPeriodicTask(FRAMES, function()
      if life > 0 then
        life = life - 1
        colour = colour - 0.02
        inst.AnimState:SetMultColour(1, 1, 1, colour)
      else
        inst:Remove()
      end
    end)
  end)
end

local function onattack(inst, attacker)--, target)
  if inst.components.weapon and inst.components.finiteuses and inst.components.finiteuses:GetUses() == 0 then
    local damage = math.max(inst.components.weapon.damage - 1, 0)
    if damage ~= inst.components.weapon.damage then
      inst.components.weapon.damage = damage
    end
  end
  
  if attacker and attacker.components.health and not attacker.components.health:IsDead()
    and inst.components.rechargeable and inst.components.rechargeable:IsCharged()
  then
    inst.components.rechargeable:Discharge(TUNING.JX_TUNING.jx_holy_sword_cd)
    attacker.components.health:DoDelta(6.8)
  end
end

local function onequip(inst, owner)
  if owner.userid and table.contains(JX_ZOUA_ENABLE, owner.userid) then --全局表 JX_ZOUA_ENABLE 在 miao/jx_holy_sword.lua 中定义
    owner.AnimState:OverrideSymbol("swap_object", "swap_jx_holy_sword", "swap_spear_2")
  else
    owner.AnimState:OverrideSymbol("swap_object", "swap_jx_holy_sword", "swap_spear")
  end
  owner.AnimState:Show("ARM_carry")
  owner.AnimState:Hide("ARM_normal")
  owner.SoundEmitter:PlaySound("jx_holy_sword/jx_holy_sword/equip", nil, TUNING.JX_TUNING.jx_holy_sword_volume)
  if owner.userid and TUNING.JX_TUNING.jx_holy_sword_ui ~= false then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Holy_Sword_Show"), owner.userid, true)
  end
end

local function onunequip(inst, owner)
  owner.AnimState:Hide("ARM_carry")
  owner.AnimState:Show("ARM_normal")
  owner.SoundEmitter:PlaySound("jx_holy_sword/jx_holy_sword/unequip", nil, TUNING.JX_TUNING.jx_holy_sword_volume)
  if owner.userid and TUNING.JX_TUNING.jx_holy_sword_ui ~= false then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Holy_Sword_Show"), owner.userid, false)
  end
  FUNCTION_JX_ZOUA_DISABLE(nil, nil, owner) --函数在 miao/jx_holy_sword.lua 中定义
  if inst.components.finiteuses and inst.components.finiteuses:GetUses() == 0 then
    inst:DoTaskInTime(0, function()
      local _owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
      if _owner then
        if _owner.components.inventory and _owner.components.inventory:FindItem(function(v) return v == inst end) then
          _owner.components.inventory:DropItem(inst)
        elseif _owner.components.container and _owner.components.container:FindItem(function(v) return v == inst end) then
          _owner.components.container:DropItem(inst)
        end
      end
      inst:StartRemoveTask()
    end)
  end
end

local function onsave(inst, data)
  if inst.components.weapon and inst.components.finiteuses and inst.components.finiteuses:GetUses() == 0 then
    data.damage = inst.components.weapon.damage
  end
end

local function onload(inst, data)
  if data and data.damage and inst.components.weapon then
    inst.components.weapon:SetDamage(data.damage)
  end
end

local function fn()
  local inst = CreateEntity()
  
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()
  
  MakeInventoryPhysics(inst)
  
  inst.AnimState:SetBank("jx_holy_sword")
  inst.AnimState:SetBuild("swap_jx_holy_sword")
  inst.AnimState:PlayAnimation("idle")
  
  inst:AddTag("sharp")
  inst:AddTag("pointy")
  inst:AddTag("weapon")
  inst:AddTag("jx_holy_sword")
  inst:AddTag("rechargeable")
  
  MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)
  
  inst.entity:SetPristine()
  
  if not TheWorld.ismastersim then
    return inst
  end
  
  inst:AddComponent("weapon")
  inst.components.weapon:SetDamage(TUNING.JX_TUNING.jx_holy_sword_weapondamage)
  inst.components.weapon:SetOnAttack(onattack)
  
  inst:AddComponent("planardamage")
  inst.components.planardamage:SetBaseDamage(TUNING.JX_TUNING.jx_holy_sword_planardamage)
  
  inst:AddComponent("finiteuses")
  inst.components.finiteuses:SetMaxUses(TUNING.JX_TUNING.jx_holy_sword_finiteuses)
  inst.components.finiteuses:SetUses(TUNING.JX_TUNING.jx_holy_sword_finiteuses)
  
  inst:AddComponent("inspectable")
  
  inst:AddComponent("inventoryitem")
  
  inst:AddComponent("equippable")
  inst.components.equippable:SetOnEquip(onequip)
  inst.components.equippable:SetOnUnequip(onunequip)
  
  inst:AddComponent("rechargeable")
  
  MakeHauntableLaunch(inst)
  
  inst.StartRemoveTask = StartRemoveTask
  
  inst.OnSave = onsave
  inst.OnLoad = onload
  
  return inst
end

return Prefab("jx_holy_sword", fn, assets)