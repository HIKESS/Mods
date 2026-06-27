local assets =
{
  Asset("ANIM", "anim/jx_frog_raincoat.zip"),
}

local prefabs =
{
  "jx_frog_raincoatfx",
}

local function ShowHat(owner)
  owner.AnimState:ClearOverrideSymbol("swap_hat")
  owner.AnimState:OverrideSymbol("swap_hat", "jx_frog_raincoat", "swap_hat")
  owner.AnimState:Show("HAT")
  owner.AnimState:Show("HAIR_HAT")
  owner.AnimState:Hide("HAIR_NOHAT")
  owner.AnimState:Hide("HAIR")
  if owner.isplayer then
    owner.AnimState:Show("HEAD")
    owner.AnimState:Show("HEAD_HAT")
    owner.AnimState:Show("HEAD_HAT_NOHELM")
    owner.AnimState:Hide("HEAD_HAT_HELM")
  end
end

local function onownerequip(owner, data)
  if data and data.eslot == EQUIPSLOTS.HEAD then
    ShowHat(owner)
  end
end

local function onownerunequip(owner, data)
  if data and data.eslot == EQUIPSLOTS.HEAD then
    ShowHat(owner)
  end
end

local function onequip(inst, owner)
  owner.AnimState:OverrideSymbol("swap_body", "jx_frog_raincoat", "swap_body")
  
  if inst.components.fueled then
    inst.components.fueled:StartConsuming()
  end
  
  --棱镜幻化法杖
  if owner.components.dressup and (owner.components.dressup.itemlist[EQUIPSLOTS.HEAD] ~= nil or owner.components.dressup.itemlist[EQUIPSLOTS.BODY] ~= nil) then
    return
  end
  
  if owner.components.inventory == nil then
    return
  end
  
  ShowHat(owner)
  owner.AnimState:AddOverrideBuild("jx_frog_raincoat")
  
  local fx = SpawnPrefab("jx_frog_raincoatfx")
  if fx then
    fx.entity:SetParent(owner.entity)
    fx.Follower:FollowSymbol(owner.GUID, "swap_hat", 0, 0, 0, true, false, 0)
    owner.jx_frog_raincoatfx = fx
  end
  
  owner.jx_frog_raincoat_onownerequip = onownerequip
  owner.jx_frog_raincoat_onownerunequip = onownerunequip
  owner:ListenForEvent("equip", owner.jx_frog_raincoat_onownerequip)
  owner:ListenForEvent("unequip", owner.jx_frog_raincoat_onownerunequip)
  
  owner:PushEvent("equip_jx_frog_raincoat")
end

local function onunequip(inst, owner)
  owner.AnimState:ClearOverrideSymbol("swap_body")
  
  if inst.components.fueled then
    inst.components.fueled:StopConsuming()
  end
  
  --棱镜幻化法杖
  if owner.components.dressup and (owner.components.dressup.itemlist[EQUIPSLOTS.HEAD] ~= nil or owner.components.dressup.itemlist[EQUIPSLOTS.BODY] ~= nil) then
    return
  end
  
  owner.AnimState:ClearOverrideSymbol("swap_hat")
  owner.AnimState:ClearOverrideBuild("jx_frog_raincoat")
  
  local hat = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
  if hat and hat.components.equippable then
    if hat.components.equippable.onunequipfn then
      hat.components.equippable.onunequipfn(hat, owner)
    end
    if hat.components.equippable.onequipfn then
      hat.components.equippable.onequipfn(hat, owner)
    end
  else
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
    if owner.isplayer then
      owner.AnimState:Show("HEAD")
      owner.AnimState:Hide("HEAD_HAT")
      owner.AnimState:Hide("HEAD_HAT_NOHELM")
      owner.AnimState:Hide("HEAD_HAT_HELM")
    end
  end
  
  if owner.jx_frog_raincoatfx then
    owner.jx_frog_raincoatfx:Remove()
    owner.jx_frog_raincoatfx = nil
  end
  
  if owner.jx_frog_raincoat_onownerequip then
    owner:RemoveEventCallback("equip", owner.jx_frog_raincoat_onownerequip)
    owner:RemoveEventCallback("unequip", owner.jx_frog_raincoat_onownerunequip)
    owner.jx_frog_raincoat_onownerequip = nil
    owner.jx_frog_raincoat_onownerunequip = nil
  end
  
  owner:PushEvent("unequip_jx_frog_raincoat")
end

local function onequiptomodel(inst)
  if inst.components.fueled then
    inst.components.fueled:StopConsuming()
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("jx_frog_raincoat")
    inst.AnimState:SetBuild("jx_frog_raincoat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("waterproofer")
    inst:AddTag("jx_frog_raincoat")

    MakeInventoryFloatable(inst, "small", 0.1, 0.78)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.insulated = true
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("waterproofer")

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.RAINCOAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    MakeHauntableLaunch(inst)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

    return inst
end

local function fxfn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddFollower()
  inst.entity:AddNetwork()
  
  inst.AnimState:SetBank("jx_frog_raincoat")
  inst.AnimState:SetBuild("jx_frog_raincoat")
  inst.AnimState:PlayAnimation("hat")
  inst.AnimState:SetFinalOffset(1)
    
  inst:AddTag("FX")
  inst:AddTag("NOCLICK")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end
    
  inst.persists = false
  
  return inst
end

return Prefab("jx_frog_raincoat", fn, assets, prefabs),
  Prefab("jx_frog_raincoatfx", fxfn, assets)