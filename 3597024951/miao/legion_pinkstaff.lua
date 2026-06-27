local function RemoveReindeerFx(inst)
  if inst.jx_hat_reindeer_fx_pool then
    for _, v in pairs(inst.jx_hat_reindeer_fx_pool) do
      if v and v:IsValid() then
        v:Remove()
      end
    end
    inst.jx_hat_reindeer_fx_pool = nil
  end
end
local function CreateReindeerFX(inst)
  local fx_pool = inst.jx_hat_reindeer_fx_pool
  if fx_pool == nil then
    fx_pool = {}
    local function CreateFX()
      local fx = SpawnPrefab("jx_hat_reindeer_fx")
      table.insert(fx_pool, fx)
      return fx
    end
    CreateFX():Start({ owner = inst, x = -43, y = -21, scale = false, symbolnum = 1, num = 1 })
    CreateFX():Start({ owner = inst, x = -75, y = -12, scale = true, symbolnum = 0, num = 2 })
    CreateFX():Start({ owner = inst, x = 73, y = -12, scale = false, symbolnum = 0, num = 3 })
    CreateFX():Start({ owner = inst, x = -85, y = -12, scale = false, symbolnum = 2, num = 3 })
    CreateFX():Start({ owner = inst, x = 64, y = -12, scale = false, symbolnum = 2, num = 2 })
    inst.jx_hat_reindeer_fx_pool = fx_pool
  end
end

local function ShowHat(inst)
  inst.AnimState:ClearOverrideSymbol("swap_hat")
  inst.AnimState:OverrideSymbol("swap_hat", "jx_frog_raincoat", "swap_hat")
  inst.AnimState:Show("HAT")
  inst.AnimState:Show("HAIR_HAT")
  inst.AnimState:Hide("HAIR_NOHAT")
  inst.AnimState:Hide("HAIR")
  if inst.isplayer then
    inst.AnimState:Show("HEAD")
    inst.AnimState:Show("HEAD_HAT")
    inst.AnimState:Show("HEAD_HAT_NOHELM")
    inst.AnimState:Hide("HEAD_HAT_HELM")
  end
end
local function onownerequip(inst, data)
  if data and data.eslot == EQUIPSLOTS.HEAD then
    ShowHat(inst)
  end
end
local function onownerunequip(inst, data)
  if data and data.eslot == EQUIPSLOTS.HEAD then
    ShowHat(inst)
  end
end

local dressup_dd_mod = 
{
  jx_hat_reindeer =
  {
    isnoskin = true,
    buildfile = "jx_hat_reindeer",
    buildsymbol = "swap_hat",
    equipfn = function(inst)--, item, cpt)
      inst:DoTaskInTime(0, function()
        CreateReindeerFX(inst)
      end)
    end,
    unequipfn = function(inst)--, item, cpt)
      RemoveReindeerFx(inst)
    end,
  },
  jx_frog_raincoat =
  {
    isnoskin = true,
    buildfile = "jx_frog_raincoat",
    buildsymbol = "swap_body",
    equipfn = function(inst)--, item, cpt)
      ShowHat(inst)
      inst.AnimState:AddOverrideBuild("jx_frog_raincoat")
      local fx = SpawnPrefab("jx_frog_raincoatfx")
      if fx then
        fx.entity:SetParent(inst.entity)
        fx.Follower:FollowSymbol(inst.GUID, "swap_hat", 0, 0, 0, true, false, 0)
        inst.jx_frog_raincoatfx = fx
      end
      inst.jx_frog_raincoat_onownerequip = onownerequip
      inst.jx_frog_raincoat_onownerunequip = onownerunequip
      inst:ListenForEvent("equip", inst.jx_frog_raincoat_onownerequip)
      inst:ListenForEvent("unequip", inst.jx_frog_raincoat_onownerunequip)
      inst:PushEvent("equip_jx_frog_raincoat")
    end,
    unequipfn = function(inst)--, item, cpt)
      inst.AnimState:ClearOverrideSymbol("swap_hat")
      inst.AnimState:ClearOverrideBuild("jx_frog_raincoat")
      local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
      if hat and hat.components.equippable and hat.components.equippable.onequipfn then
        hat.components.equippable.onequipfn(hat, inst)
      else
        inst.AnimState:Hide("HAT")
        inst.AnimState:Hide("HAIR_HAT")
        inst.AnimState:Show("HAIR_NOHAT")
        inst.AnimState:Show("HAIR")
        if inst.isplayer then
          inst.AnimState:Show("HEAD")
          inst.AnimState:Hide("HEAD_HAT")
          inst.AnimState:Hide("HEAD_HAT_NOHELM")
          inst.AnimState:Hide("HEAD_HAT_HELM")
        end
      end
      if inst.jx_frog_raincoatfx then
        inst.jx_frog_raincoatfx:Remove()
        inst.jx_frog_raincoatfx = nil
      end
      if inst.jx_frog_raincoat_onownerequip then
        inst:RemoveEventCallback("equip", inst.jx_frog_raincoat_onownerequip)
        inst:RemoveEventCallback("unequip", inst.jx_frog_raincoat_onownerunequip)
        inst.jx_frog_raincoat_onownerequip = nil
        inst.jx_frog_raincoat_onownerunequip = nil
      end
      inst:PushEvent("unequip_jx_frog_raincoat")
    end,
  }
}

local mod_hat = 
{
  "jx_hat_iron_pan",
  "jx_hat_white_rose",
  "jx_hat_sunflower",
  "jx_hat_mexico",
  "jx_hat_sigurd",
  "jx_hat_hepburn",
  "jx_hat_noodles",
}
for _, v in ipairs(mod_hat) do
  dressup_dd_mod[v] =
  {
    isnoskin = true,
    buildfile = v,
    buildsymbol = "swap_hat",
  }
end

local mod_backpack =
{
  jx_backpack = "jx_backpack_build",
  jx_backpack_2 = "jx_backpack_build2",
  jx_backpack_3 = "jx_backpack_build3",
  jx_backpack_4 = "jx_backpack_build4",
  jx_backpack_5 = "jx_backpack_build5",
}
for k, v in pairs(mod_backpack) do
  dressup_dd_mod[k] =
  {
    isnoskin = true,
    buildfile = v,
    buildsymbol = "swap_body",
  }
end

if GLOBAL.rawget(GLOBAL, "DRESSUP_DATA_LEGION") then
  for k, v in pairs(dressup_dd_mod) do
    GLOBAL.DRESSUP_DATA_LEGION[k] = v
  end
else
  GLOBAL.DRESSUP_DATA_LEGION = dressup_dd_mod
end
dressup_dd_mod = nil

AddPrefabPostInit("pinkstaff", function(inst)
    if not GLOBAL.TheWorld.ismastersim then return end
    if inst.components.spellcaster then
      local old_spell = inst.components.spellcaster.spell
      inst.components.spellcaster.spell = function(inst, target, pos, doer, ...)
        local onunequipfn
        local onequipfn
        local body_item
        if doer and doer.components.inventory then
          local _body_item = doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
          if _body_item and _body_item:HasTag("jx_frog_raincoat") then
            onunequipfn = _body_item.components.equippable.onunequipfn
            onequipfn = _body_item.components.equippable.onequipfn
            body_item = _body_item
          end
        end
        if onunequipfn then
          onunequipfn(body_item, doer)
        end
        if old_spell then
          old_spell(inst, target, pos, doer, ...)
        end
        if target ~= nil and target ~= doer then
          if onequipfn then
            onequipfn(body_item, doer)
          end
        end
      end
    end
end)