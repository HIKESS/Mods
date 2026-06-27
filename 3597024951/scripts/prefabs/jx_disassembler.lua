local assets =
{
    Asset("ANIM", "anim/jx_disassembler.zip"),
}

local prefabs =
{
    "collapse_big",
}

local function onopen(inst)
  inst.AnimState:PlayAnimation("open")
end

local function onclose(inst)
  if not inst.isworking then
    inst.AnimState:PlayAnimation("idle")
  end
end

local function onhammered(inst)
  inst.components.lootdropper:DropLoot(nil, {"gears", "goldnugget", "nightmarefuel"})
  local fx = SpawnPrefab("collapse_big")
  fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
  fx:SetMaterial("metal")
  inst:Remove()
end

local function onhit(inst)
  if inst.components.container then
    inst.components.container:DropEverything()
  end
  inst.AnimState:PlayAnimation("hit")
  if inst.isworking then
    inst.AnimState:PushAnimation("working", true)
  else
    inst.AnimState:PushAnimation("idle", false)
  end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
end

local function onfinished(inst)
  inst:AddTag("NOCLICK")
  local life = 48
  local color = 1
  inst.colortask = inst:DoPeriodicTask(FRAMES,function()
    if life >= 1 then
      inst.AnimState:SetMultColour(1, 1, 1, color)
      life = life - 1
      color = color - 0.02
    else
      if inst.colortask then
        inst.colortask:Cancel()
        inst.colortask = nil
      end
      inst:Remove()
    end
  end)
end

local function Start(inst)
  inst.isworking = true
  inst.SoundEmitter:PlaySound("jx_sound_7/jx_sound_7/jx_sound_7", "loop")
  inst.AnimState:PlayAnimation("working", true)
  if inst.components.timer then
    inst.components.timer:StartTimer("cd", TUNING.JX_TUNING.jx_disassembler_worktime)
  end
  if inst.components.container then
    inst.components.container:Close()
    inst.components.container.canbeopened = false
  end
end

local function Done(inst)
  inst.isworking = false
  inst.SoundEmitter:KillSound("loop")
  inst.AnimState:PlayAnimation("open")
  inst.AnimState:PushAnimation("idle", false)
  
  if inst.components.container then
    inst.components.container.canbeopened = true
  end
  
  if not (inst.inneritem and inst.inneritem:IsValid()) then return end
  
  local recipe = AllRecipes[inst.inneritem.prefab]
  if recipe == nil or FunctionOrValue(recipe.no_deconstruction, inst.inneritem) then
    return
  end
    
  for i, v in ipairs(recipe.ingredients) do
    if string.sub(v.type, -3) ~= "gem" or string.sub(v.type, -11, -4) == "precious" then
      local amt = v.amount == 0 and 0 or math.max(1, v.amount)
      for _ = 1, amt do
        local loot = SpawnPrefab(v.type)
        if loot and loot.Transform then
          local x, y, z = inst.Transform:GetWorldPosition()
          if loot.components.inventoryitem then
            loot.Transform:SetPosition(x, y, z)
            loot.components.inventoryitem:OnDropped(true)
          else
            local rnd = math.random(-10, 10) / 10
            loot.Transform:SetPosition(x + rnd, y, z + rnd)
          end
        end
      end
    end
  end
  
  if inst.inneritem.components.inventory ~= nil then
    inst.inneritem.components.inventory:DropEverything()
  end
  
  if inst.inneritem.components.container ~= nil then
    inst.inneritem.components.container:DropEverything(nil, true)
  end
  
  if inst.inneritem.components.spawner ~= nil and inst.inneritem.components.spawner:IsOccupied() then
    inst.inneritem.components.spawner:ReleaseChild()
  end
  
  if inst.inneritem.components.occupiable ~= nil and inst.inneritem.components.occupiable:IsOccupied() then
    local _item = inst.inneritem.components.occupiable:Harvest()
    if _item ~= nil then
      _item.Transform:SetPosition(inst.inneritem.Transform:GetWorldPosition())
      _item.components.inventoryitem:OnDropped()
    end
  end
  
  if inst.inneritem.components.trap ~= nil then
    inst.inneritem.components.trap:Harvest()
  end
  
  if inst.inneritem.components.dryer ~= nil then
    inst.inneritem.components.dryer:DropItem()
  end
  
  if inst.inneritem.components.harvestable ~= nil then
    inst.inneritem.components.harvestable:Harvest()
  end
  
  if inst.inneritem.components.stewer ~= nil then
    inst.inneritem.components.stewer:Harvest()
  end
  
  if inst.inneritem.components.constructionsite ~= nil then
    inst.inneritem.components.constructionsite:DropAllMaterials()
  end
  
  if inst.inneritem.components.inventoryitemholder ~= nil then
    inst.inneritem.components.inventoryitemholder:TakeItem()
  end
  
  local giver = ((inst.giver ~= nil and inst.giver:IsValid()) and inst.giver) or inst
  inst.inneritem:PushEvent("ondeconstructstructure", giver)
  
  if not inst.inneritem.no_delete_on_deconstruct then
    if inst.inneritem.components.stackable ~= nil then
      inst.inneritem.components.stackable:Get():Remove()
    else
      inst.inneritem:Remove()
    end
  end
  
  inst.inneritem = nil
  
  if inst.components.finiteuses then
    inst.components.finiteuses:Use(1)
  end
end

local function ontimerdone(inst, data)
  if data and data.name == "cd" then
    Done(inst)
  end
end

local function onsave(inst, data)
    if inst.isworking then
      data.isworking = true
    end
end

local function onload(inst, data)
    if data and data.isworking then
      Start(inst)
    end
end

local function OnGetItem(inst, item, giver)
  if item == nil then
    return false
  elseif item.components.itemmimic then
    if giver then
      giver.SoundEmitter:PlaySound("dontstarve/creatures/monkey/poopsplat")
    end
    item.components.itemmimic:TurnEvil(giver)
    return false
  else
    local recipe = AllRecipes[item.prefab]
    if recipe == nil or FunctionOrValue(recipe.no_deconstruction, item) then
      return false
    end
    inst.inneritem = item
    inst.giver = giver
    Start(inst)
    return true
  end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(1)
    
    MakeObstaclePhysics(inst, .5)
    
    inst:AddTag("structure")
    inst:AddTag("jx_disassembler")
    
    inst.AnimState:SetBank("jx_disassembler")
    inst.AnimState:SetBuild("jx_disassembler")
    inst.AnimState:PlayAnimation("idle")
        
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("lootdropper")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_disassembler")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.JX_TUNING.jx_disassembler_finiteuses)
    inst.components.finiteuses:SetUses(TUNING.JX_TUNING.jx_disassembler_finiteuses)
    inst.components.finiteuses:SetOnFinished(onfinished)
    
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    
    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    inst.OnGetItem = OnGetItem
    
    return inst
end

return Prefab("jx_disassembler", fn, assets, prefabs),
    MakePlacer("jx_disassembler_placer", "jx_disassembler", "jx_disassembler", "idle")