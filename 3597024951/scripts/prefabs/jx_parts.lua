local ret = {}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_"..inst.prefab, "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function MakeParts(name, data)
  local assets =
  {
    Asset("ANIM", "anim/jx_parts.zip"),
  }
  if data.equippable then
    table.insert(assets, Asset("ANIM", "anim/swap_"..name..".zip"))
  end

  local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("jx_parts")
    inst.AnimState:SetBuild("jx_parts")
    inst.AnimState:PlayAnimation(name)
    
    inst:AddTag("jx_parts")
    inst:AddTag(name)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
    if data.uses then
      inst:AddComponent("finiteuses")
      inst.components.finiteuses:SetMaxUses(data.uses)
      inst.components.finiteuses:SetUses(data.uses)
      inst.components.finiteuses:SetOnFinished(inst.Remove)
    end
    
    if data.equippable then
      inst:AddComponent("equippable")
      inst.components.equippable:SetOnEquip(onequip)
      inst.components.equippable:SetOnUnequip(onunequip)
    end
    
    if data.jx_parts then
      inst:AddComponent("jx_parts")
    end
    
    if data.extra_light then
      inst.extra_light = data.extra_light
    end
    if data.colour_num then
      inst.colour_num = data.colour_num
    end
    
    if data.recycler then
      MakeCraftingMaterialRecycler(inst, data.recycler)
    end

    MakeHauntableLaunch(inst)

    return inst
  end
  
  table.insert(ret, Prefab(name, fn, assets))
end
--         name
MakeParts("jx_parts_colour", { colour_num = 1, uses = 3, equippable = true, jx_parts = true, recycler = {gelblob_bottle = "messagebottleempty"},})
MakeParts("jx_parts_light", { extra_light = 16, })
MakeParts("jx_parts_engine", {})
MakeParts("jx_parts_music", {})
MakeParts("jx_parts_wheel", {})
MakeParts("jx_parts_camera_1", {})
MakeParts("jx_parts_camera_2", {})

return unpack(ret)