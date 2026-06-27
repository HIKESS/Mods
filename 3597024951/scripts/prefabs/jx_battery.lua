local assets =
{
    Asset("ANIM", "anim/jx_battery.zip"),
}

local function ChangeBattery(flashlight, newbattery)
  if flashlight:HasTag("jx_flashlight") and flashlight.components.container then
    local oldbattery = flashlight.components.container:FindItem(function(v) return v:HasTag("jx_battery") end)
    if oldbattery then
      flashlight.components.container:RemoveItem(oldbattery)
      flashlight.components.container:GiveItem(newbattery)
      return true
    end
  end
  return false
end

local function onfueledupdate(inst)
  local nowtime = GetTime()
  if inst.lastfueledupdatetime == nil or nowtime - inst.lastfueledupdatetime > 1 then
    local success
    local battery2 = SpawnPrefab("jx_battery2")
    if battery2 then
      local flashlight = inst.components.inventoryitem and inst.components.inventoryitem.owner
      if flashlight then
        success = ChangeBattery(flashlight, battery2)
      else
        local player = inst.components.inventoryitem:GetGrandOwner()
        if player and player.components.inventory then
          flashlight = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
          if flashlight then
            success = ChangeBattery(flashlight, battery2)
          end
        end
      end
    end
    
    if success then
      inst:Remove()
    else
      if battery2 and battery2:IsValid() then
        battery2:Remove()
      end
      inst.lastfueledupdatetime = nowtime
    end
  end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_battery")
    inst.AnimState:SetBuild("jx_battery")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("jx_battery")
    inst:AddTag("hide_percentage")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(480)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:SetUpdateFn(onfueledupdate)
    --inst.lastfueledupdatetime = nil
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    
    return inst
end

local function fn2()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_battery")
    inst.AnimState:SetBuild("jx_battery")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("jx_battery")
    
    inst.pickupsound = "NONE"
    inst:DoTaskInTime(.5, function() inst.pickupsound = nil end)
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(480)
    inst.components.fueled:SetPercent(.99)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    
    return inst
end

return Prefab("jx_battery1", fn, assets),
  Prefab("jx_battery2", fn2, assets)