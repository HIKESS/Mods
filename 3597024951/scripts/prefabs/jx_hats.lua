local ret = {}

local tuning = TUNING.JX_TUNING

local function RemoveReindeerFx(owner)
  if owner.jx_hat_reindeer_fx_pool then
    for _, v in pairs(owner.jx_hat_reindeer_fx_pool) do
      if v and v:IsValid() then
        v:Remove()
      end
    end
    owner.jx_hat_reindeer_fx_pool = nil
  end
end

local function CreateReindeerFX(owner)
  local fx_pool = owner.jx_hat_reindeer_fx_pool
  if fx_pool == nil then
    fx_pool = {}
    local function CreateFX()
      local fx = SpawnPrefab("jx_hat_reindeer_fx")
      table.insert(fx_pool, fx)
      return fx
    end
    CreateFX():Start({ owner = owner, x = -43, y = -21, scale = false, symbolnum = 1, num = 1 })
    CreateFX():Start({ owner = owner, x = -75, y = -12, scale = true, symbolnum = 0, num = 2 })
    CreateFX():Start({ owner = owner, x = 73, y = -12, scale = false, symbolnum = 0, num = 3 })
    CreateFX():Start({ owner = owner, x = -85, y = -12, scale = false, symbolnum = 2, num = 3 })
    CreateFX():Start({ owner = owner, x = 64, y = -12, scale = false, symbolnum = 2, num = 2 })
    owner.jx_hat_reindeer_fx_pool = fx_pool
  end
end

local function onequip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_hat", inst.prefab, "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
    if owner.isplayer then
      owner.AnimState:Hide("HEAD")
      owner.AnimState:Show("HEAD_HAT")
			owner.AnimState:Show("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
    end
    
    if inst.components.fueled ~= nil then
			inst.components.fueled:StartConsuming()
		end
    
    if inst:HasTag("jx_hat_reindeer") then
      owner:DoTaskInTime(0, function()
        if (owner.components.inventory and owner.components.inventory:EquipHasTag("jx_frog_raincoat")) or
          (owner.components.dressup and owner.components.dressup.itemlist[EQUIPSLOTS.HEAD] ~= nil) -- 棱镜幻化法杖
        then
          return
        end
        CreateReindeerFX(owner)
        owner:ListenForEvent("equip_jx_frog_raincoat", RemoveReindeerFx)
        owner:ListenForEvent("unequip_jx_frog_raincoat", CreateReindeerFX)
      end)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("headbase_hat")    
    owner.AnimState:ClearOverrideSymbol("swap_hat")
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
    
    if inst.components.fueled ~= nil then
      inst.components.fueled:StopConsuming()
    end
    
    if inst:HasTag("jx_hat_reindeer") and owner.jx_hat_reindeer_fx_pool then
      RemoveReindeerFx(owner)
      owner:RemoveEventCallback("equip_jx_frog_raincoat", RemoveReindeerFx)
      owner:RemoveEventCallback("unequip_jx_frog_raincoat", CreateReindeerFX)
    end
end

local function onequiptomodel(inst, owner)
    if inst.components.fueled ~= nil then
      inst.components.fueled:StopConsuming()
    end
end

local function ontakedamage_iron_pan(inst, damage_amount)
  local owner = inst.components.inventoryitem:GetGrandOwner()
  if owner and owner.SoundEmitter then
    owner.SoundEmitter:PlaySound("daywalker/pillar/pickaxe_hit_unbreakable")
  end
end

local function MakeHat(prefab_name, tradable, armor_amount, armor_absorb_percent, waterproofer_percent, insulator_percent, fueled_maxfuel, fuel_fuelvalue, planardefense, dapperness)
  local assets =
  {
    Asset("ANIM", "anim/"..prefab_name..".zip"),
  }
  local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(prefab_name)
    inst.AnimState:SetBuild(prefab_name)
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("hat")
    if prefab_name == "jx_hat_reindeer" then
      inst:AddTag("jx_hat_reindeer")
    end
    
    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    
    if tradable then
      inst:AddComponent("tradable")
    end
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)
    if dapperness then
      inst.components.equippable.dapperness = dapperness
    end
    
    if armor_amount then
      inst:AddComponent("armor")
      inst.components.armor:InitCondition(armor_amount, armor_absorb_percent)
      if prefab_name == "jx_hat_iron_pan" then
        inst.components.armor.ontakedamage = ontakedamage_iron_pan
      end
    end
    
    if waterproofer_percent then
      inst:AddComponent("waterproofer")
      inst.components.waterproofer:SetEffectiveness(waterproofer_percent)
    end
    
    local _insulator_percent = insulator_percent
    if _insulator_percent then
      inst:AddComponent("insulator")
      if _insulator_percent < 0 then
        _insulator_percent = - _insulator_percent
        inst.components.insulator:SetSummer()
      end
      inst.components.insulator:SetInsulation(_insulator_percent)
    end
    
    if fueled_maxfuel then
      inst:AddComponent("fueled")
      inst.components.fueled.fueltype = FUELTYPE.USAGE
      inst.components.fueled:InitializeFuelLevel(fueled_maxfuel)
      inst.components.fueled:SetDepletedFn(inst.Remove)
    end
    
    if fuel_fuelvalue then
      inst:AddComponent("fuel")
      inst.components.fuel.fuelvalue = fuel_fuelvalue
    end
    
    if planardefense then
      inst:AddComponent("planardefense")
	  	inst.components.planardefense:SetBaseDefense(planardefense)
    end

    MakeHauntableLaunch(inst)

    return inst
  end
  
  if prefab_name == "jx_hat_reindeer" then
    table.insert(ret, Prefab(prefab_name, fn, assets, { "jx_hat_reindeer_fx" }))
  else
    table.insert(ret, Prefab(prefab_name, fn, assets))
  end
end

--1,            2,        3,             4,                  5,                     6,                 7,              8,              9              10
--prefab_name, tradable, armor_amount, armor_absorb_percent, waterproofer_percent, insulator_percent, fueled_maxfuel, fuel_fuelvalue, planardefense, dapperness
MakeHat("jx_hat_iron_pan", true, tuning.jx_hat_iron_pan_armoramount, tuning.jx_hat_iron_pan_armorabsorb, tuning.jx_hat_iron_pan_waterproofer, nil, nil, nil, nil, nil)
MakeHat("jx_hat_white_rose", true, tuning.jx_hat_white_rose_armoramount, tuning.jx_hat_white_rose_armorabsorb, tuning.jx_hat_white_rose_waterproofer, tuning.jx_hat_white_rose_insulator, nil, nil, nil, nil)
MakeHat("jx_hat_sunflower", true, nil, nil, tuning.jx_hat_sunflower_waterproofer, -tuning.jx_hat_sunflower_insulator, 2400, 180, nil, nil)
MakeHat("jx_hat_mexico", true, nil, nil, tuning.jx_hat_mexico_waterproofer, -tuning.jx_hat_mexico_insulator, 2400, 180, nil, nil)
MakeHat("jx_hat_sigurd", true, tuning.jx_hat_sigurd_armoramount, tuning.jx_hat_sigurd_armorabsorb, tuning.jx_hat_sigurd_waterproofer, nil, nil, nil, tuning.jx_hat_sigurd_planardefense, nil)
MakeHat("jx_hat_hepburn", true, nil, nil, tuning.jx_hat_hepburn_waterproofer, -tuning.jx_hat_hepburn_insulator, 2400, nil, nil, TUNING.DAPPERNESS_SMALL)
MakeHat("jx_hat_reindeer", true, nil, nil, nil, tuning.jx_hat_reindeer_insulator, 7200, nil, nil, TUNING.DAPPERNESS_SMALL)
MakeHat("jx_hat_noodles", true, nil, nil, .2, nil, 1200, nil, nil, TUNING.DAPPERNESS_MED)
MakeHat("jx_hat_motorcycle", true, nil, nil, .5, nil, nil, nil, nil, nil)

return unpack(ret)