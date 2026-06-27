local assets =
{
  Asset("ANIM", "anim/jx_flashlight.zip"),
  Asset("ANIM", "anim/swap_jx_flashlight.zip"),
  Asset("ANIM", "anim/ui_cookpot_1x2.zip"),
}

local prefabs =
{
  "jx_battery1",
}

local function onequip(inst, owner)
  local battery = inst.components.container:FindItem(function(v) return v:HasTag("jx_battery") end)
  if battery then
    if battery.components.fueled then
      battery.components.fueled:StartConsuming()
    end
    if inst.components.jx_flashlight and not inst.components.jx_flashlight.ison then
      inst.components.jx_flashlight:Start(owner)
    end
  else
    owner:DoTaskInTime(1, function()
      local battery = inst:IsValid() and inst.components.container:FindItem(function(v) return v:HasTag("jx_battery") end)
      if battery == nil and (owner.components.health and owner.components.health:IsDead()) and owner.components.talker then
        owner.components.talker:Say(STRINGS.JX_FLASHLIGHT_NOBATTERY)
      end
    end)
  end
  if inst.components.container then
    inst.components.container:Open(owner)
  end
  owner.AnimState:OverrideSymbol("swap_object", "jx_flashlight", "flashlight")
  owner.AnimState:OverrideSymbol("swap_object1", "swap_jx_flashlight", "flashlight")
end

local function onunequip(inst, owner)
  local battery = inst.components.container:FindItem(function(v) return v:HasTag("jx_battery") end)
  if battery and battery.components.fueled then
    battery.components.fueled:StopConsuming()
  end
  if inst.components.jx_flashlight and inst.components.jx_flashlight.ison then
    inst.components.jx_flashlight:Stop()
  end
  if inst.components.container then
    inst.components.container:Close()
  end
end

local function onequiptomodelfn(inst, owner)
  owner:DoTaskInTime(0, function()
    if owner and owner:IsValid() and owner.components.inventory ~= nil then
      owner.components.inventory:DropItem(inst, nil, true)
    end
  end)
end

local function onitemget(inst, data)
  if data and data.item
    and data.item:HasTag("jx_battery")
    and data.item.components.fueled ~= nil
  then
    if not (inst.components.equippable and inst.components.equippable:IsEquipped()) then
      return
    end
    data.item.components.fueled:StartConsuming()
    if inst.components.jx_flashlight and not inst.components.jx_flashlight.ison then
      inst.components.jx_flashlight:Start()
    end
    
    local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
    if owner and not (owner.components.rider and owner.components.rider:IsRiding()) then
      if owner:HasTag("player") and owner.sg then
        if owner.sg:HasStateTag("moving") then
          owner.sg:GoToState("run_start_jx_flashlight")
        elseif owner.sg:HasStateTag("idle") then
          owner.sg:GoToState("idle")
        end
      end
    end
  end
end

local function onitemlose(inst, data)
  if data and data.prev_item
    and data.prev_item:HasTag("jx_battery")
    and data.prev_item.components.fueled ~= nil
  then
    if not (inst.components.equippable and inst.components.equippable:IsEquipped()) then
      return
    end
    data.prev_item.components.fueled:StopConsuming()
    inst:DoTaskInTime(.1, function()
      local battery = inst.components.container:FindItem(function(v) return v:HasTag("jx_battery") end)
      if battery == nil and inst.components.jx_flashlight and inst.components.jx_flashlight.ison then
        inst.components.jx_flashlight:Stop()
      end
    end)
    
    local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner()
    if owner and not (owner.components.rider and owner.components.rider:IsRiding()) then
      if owner:HasTag("player") and owner.sg then
        if owner.sg:HasAnyStateTag("moving", "idle") then
          owner.sg:GoToState("idle")
        end
      end
    end
  end
end

local function onbuilt(inst)--, builder)
  if inst.components.container then
    local battery = SpawnPrefab("jx_battery1")
    if battery then
      inst.components.container:GiveItem(battery)
    end
  end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_flashlight")
    inst.AnimState:SetBuild("jx_flashlight")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("jx_flashlight")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
      return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodelfn)
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_flashlight")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    
    inst:AddComponent("jx_flashlight")
    
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)
    inst.OnBuiltFn = onbuilt
    
    return inst
end

return Prefab("jx_flashlight", fn, assets, prefabs)