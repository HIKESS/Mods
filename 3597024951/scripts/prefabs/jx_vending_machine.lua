local ret = {}

local assets =
{
    Asset("ANIM", "anim/jx_vending_machine.zip"),
}

local prefabs = 
{
  "jx_drink_cola",
  "jx_drink_tea",
  "jx_drink_coffee",
  "collapse_big",
}

local function Update_Light(inst)
  if inst:HasTag("burnt") then
    return
  end
  if TheWorld.state.isday then
    inst.Light:Enable(false)
  else
    inst.Light:Enable(true)
  end
end

local function ShowOrHideSwapDrink(inst, num, isshow, isout)
  if isout then
    if isshow then
      local symbol = num <= 4 and "drink_tea" or num <= 8 and "drink_coffee" or "drink_cola"
      local rnd = math.random(1, 3)
      inst.AnimState:OverrideSymbol("swap_drink_out"..rnd, "jx_vending_machine", symbol)
      inst.AnimState:ShowSymbol("swap_drink_out"..rnd)
    else
      for i = 1, 3 do
        inst.AnimState:ClearOverrideSymbol("swap_drink_out"..i)
      end
      inst.AnimState:HideSymbol("swap_drink_out"..num)
    end
  else
    if isshow then
      inst.AnimState:ShowSymbol("swap_drink"..num)
    else
      inst.AnimState:HideSymbol("swap_drink"..num)
    end
  end
end

local function onhammered(inst)--, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    
    inst.components.lootdropper:DropLoot()
    
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst)--, worker)
  if not inst:HasTag("burnt") then
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
  end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
end

local function onburnt(inst)
  if inst.components.timer and inst.components.timer:TimerExists("cd") then
    inst.components.timer:StopTimer("cd")
  end
  DefaultBurntStructureFn(inst)
end

local function ontimerdone(inst, data)
  if data and data.name == "cd" then
    local num_idex = math.random(1, #inst.swap_drink_hidepool)
    if num_idex then
      ShowOrHideSwapDrink(inst, inst.swap_drink_hidepool[num_idex], true, false)
      table.remove(inst.swap_drink_hidepool, num_idex)
    end
    if #inst.swap_drink_hidepool > 0 then
      inst.components.timer:StartTimer("cd", inst.AddDrinkTimerCd)
    end
  end
end

local function ShouldAcceptItem(inst, item, giver)
  if inst:HasTag("burnt") then
    return false
  elseif inst.ShowOutDrinkTask ~= nil then
    if giver and giver.components.talker then
      giver.components.talker:Say(STRINGS.CHARACTERS.WURT.ACTIONFAIL.CHANGEIN.INUSE)--"得等等……"
    end
    return false
  elseif not (item and item:HasTag("jx_catcoin")) then
    if giver and giver.components.talker then
      giver.components.talker:Say(STRINGS.NEED_CATCOIN)--"它收猫猫币。"
    end
    return false
  elseif #inst.swap_drink_hidepool >= 12 then
    if giver then
      if giver.components.talker then
        giver.components.talker:Say(STRINGS.JX_VENDING_MACHINE_NO_DRINKS)--"没货了，下次再来看看吧。"
      end
      if inst.pickproduct and inst.components.pickable then
        inst.components.pickable:Pick(giver)
      end
    end
    return false
  end
  return true
end

local function DoSound(inst, sound_name)
  local x, y, z = inst.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, y, z, 8, { "player" })
  for _, v in ipairs(ents) do
    if v and v.userid then
      SendModRPCToClient(GetClientModRPC("JX", "JX_Vending_Machine_Sound"), v.userid, sound_name)
    end
  end
end

local function OnGetItemFromPlayer(inst, giver, item)
  if giver and inst.pickproduct and inst.components.pickable then
    inst.components.pickable:Pick(giver)
  end
  if item:HasTag("jx_catcoin") then
    DoSound(inst, "give_coin")
    local enable_num_pool = {}
    for i = 1, 12 do
      local num = i
      if not table.contains(inst.swap_drink_hidepool, num) then
        table.insert(enable_num_pool, num)
      end
    end
    if #enable_num_pool > 0 then
      local num_idex = math.random(1, #enable_num_pool)
      local num = enable_num_pool[num_idex]
      ShowOrHideSwapDrink(inst, num, false, false)
      table.insert(inst.swap_drink_hidepool, num)
      if inst.components.timer and not inst.components.timer:TimerExists("cd") then
        inst.components.timer:StartTimer("cd", inst.AddDrinkTimerCd)
      end
      inst.ShowOutDrinkTask = inst:DoTaskInTime(.5, function()
        for i = 1, 3 do
          ShowOrHideSwapDrink(inst, i, false, true)
        end
        ShowOrHideSwapDrink(inst, num, true, true)
        if inst.components.pickable then
          inst.components.pickable.canbepicked = true
          inst.components.pickable.numtoharvest = 1
          inst.pickproduct = (num <= 4 and "jx_drink_tea") or (num <= 8 and "jx_drink_coffee") or "jx_drink_cola"
        end
        inst.ShowOutDrinkTask = nil
        DoSound(inst, "drop_drink")
      end)
    end
  end
end

local function onpicked(inst, picker)
  if inst.pickproduct == nil or picker == nil or picker.components.inventory == nil then
    return
  end
  local product = SpawnPrefab(inst.pickproduct)
  if product then
    picker.components.inventory:GiveItem(product)
    inst.pickproduct = nil
    inst.components.pickable.canbepicked = false
    inst.components.pickable.numtoharvest = 0
  end
  for i = 1, 3 do
    ShowOrHideSwapDrink(inst, i, false, true)
  end
end

local function OnSave(inst, data)
  if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
    data.burnt = true
  elseif #inst.swap_drink_hidepool > 0 then
    data.swap_drink_hidepool = shallowcopy(inst.swap_drink_hidepool)
  end
end

local function OnLoad(inst, data)
  if data then
    if data.burnt then
      inst.components.burnable.onburnt(inst)
    elseif data.swap_drink_hidepool then
      inst.swap_drink_hidepool = shallowcopy(data.swap_drink_hidepool)
      for _, v in ipairs(inst.swap_drink_hidepool) do
        ShowOrHideSwapDrink(inst, v, false, false)
      end
    end
  end
end

local function OnInit(inst)
  for i = 1, 4 do
    inst.AnimState:OverrideSymbol("swap_drink"..i, "jx_vending_machine", "drink_tea")
  end
  for i = 5, 8 do
    inst.AnimState:OverrideSymbol("swap_drink"..i, "jx_vending_machine", "drink_coffee")
  end
  for i = 9, 12 do
    inst.AnimState:OverrideSymbol("swap_drink"..i, "jx_vending_machine", "drink_cola")
  end
  inst.swap_drink_hidepool = {}
  
  inst:DoTaskInTime(3, function()
    if #inst.swap_drink_hidepool > 0 and inst.components.timer and not inst.components.timer:TimerExists("cd") then
      inst.components.timer:StartTimer("cd", inst.AddDrinkTimerCd)
    end
  end)
end

local function machinefn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(1)
    MakeObstaclePhysics(inst, 1)
    
    inst.MiniMapEntity:SetIcon("jx_vending_machine.tex")
    
    inst.Light:SetRadius(1.25)
    inst.Light:SetFalloff(.85)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(180/255, 195/255, 150/255)
    inst.Light:Enable(false)
    
    inst:AddTag("structure")
    inst:AddTag("jx_vending_machine")
    
    inst.AnimState:SetBank("jx_vending_machine")
    inst.AnimState:SetBuild("jx_vending_machine")
    inst.AnimState:PlayAnimation("idle")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
  	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	  inst.components.workable:SetWorkLeft(4)
	  inst.components.workable:SetOnFinishCallback(onhammered)
	  inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    inst.AddDrinkTimerCd = 120
    
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader:SetOnAccept(OnGetItemFromPlayer)
    
    inst:AddComponent("pickable")
    inst.components.pickable.canbepicked = false
    inst.components.pickable.numtoharvest = 0
    inst.components.pickable:SetOnPickedFn(onpicked)
    --inst.pickproduct = nil
    
    inst:ListenForEvent( "onbuilt", onbuilt)
    
    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst:WatchWorldState("isnight", Update_Light)
    inst:WatchWorldState("isday", Update_Light)
    Update_Light(inst)
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    
    OnInit(inst)
    
    return inst
end

table.insert(ret, Prefab( "jx_vending_machine", machinefn, assets, prefabs))
table.insert(ret, MakePlacer("jx_vending_machine_placer", "jx_vending_machine", "jx_vending_machine", "idle"))

---
local function MakeDrink(prefab_name)
  local function drinkfn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("jx_vending_machine")
    inst.AnimState:SetBuild("jx_vending_machine")
    inst.AnimState:PlayAnimation(prefab_name)
    
    inst:AddTag("jx_drinks")
    inst:AddTag("icebox_valid")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
      return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
    
    inst:AddComponent("jx_drink")
    
    inst:AddComponent("temperature")
    inst.components.temperature.maxtemp = 4
    inst.components.temperature.mintemp = 0
    inst.components.temperature.current = 3
    
    MakeHauntableLaunch(inst)
    
    return inst
  end
  
  table.insert(ret, Prefab(prefab_name, drinkfn, assets))
end

MakeDrink("jx_drink_cola")
MakeDrink("jx_drink_tea")
MakeDrink("jx_drink_coffee")

---
local function Buff_OnKill(inst)
  inst.components.debuff:Stop()
end

local function Common_Buff_OnAttached(inst, target)
  inst.entity:SetParent(target.entity)
  inst.Transform:SetPosition(0, 0, 0)
  
  inst:ListenForEvent("death", function()
    inst.components.debuff:Stop()
  end, target)
  
  inst.bufftask = inst:DoTaskInTime(inst.bufftime, Buff_OnKill)
end

local function Buff_Cola_OnAttached(inst, target)
  Common_Buff_OnAttached(inst, target)
  if target ~= nil and target:IsValid() then
    if target.components.talker then
      target.components.talker:Say(STRINGS.JX_DRINKS_BUFF_ONATTACHED)
    end
    if target.components.temperature then
      local tem = target.components.temperature:GetCurrent()
      if tem < 15 then
        return
      elseif tem < 35 then
        tem = 35
      end
      target.components.temperature:SetTemperature(tem - 20)
    end
  end
end

local function Buff_Cola_OnDetached(inst, target)
  inst:Remove()
end

local function Buff_Tea_OnAttached(inst, target)
  Common_Buff_OnAttached(inst, target)
  if target ~= nil and target:IsValid() then
    if target.components.talker then
      target.components.talker:Say(STRINGS.JX_DRINKS_BUFF_ONATTACHED)
    end
    if target.buff_jx_drink_tea_task == nil then
      target.buff_jx_drink_tea_task = target:DoPeriodicTask(2, function()
        if target.components.sanity then
          target.components.sanity:DoDelta(2)
        end
      end)
    end
  end
end

local function Buff_Tea_OnDetached(inst, target)
  if target ~= nil and target:IsValid() then
    if target.components.talker then
      target.components.talker:Say(STRINGS.JX_DRINKS_BUFF_ONDETACHED)
    end
    if target.buff_jx_drink_tea_task then
      target.buff_jx_drink_tea_task:Cancel()
      target.buff_jx_drink_tea_task = nil
    end
  end
  inst:Remove()
end

local function Buff_Coffee_OnAttached(inst, target)
  Common_Buff_OnAttached(inst, target)
  if target ~= nil and target:IsValid() then
    if target.components.talker then
      target.components.talker:Say(STRINGS.JX_DRINKS_BUFF_ONATTACHED)
    end
    if target.components.locomotor then
      target.components.locomotor:SetExternalSpeedMultiplier(inst, "jx_drink_coffee", 1.2)
    end
    if target.components.sanity then
      target.components.sanity:DoDelta(-2)
    end
  end
end

local function Buff_Coffee_OnDetached(inst, target)
  if target ~= nil and target:IsValid() then
    if target.components.talker then
      target.components.talker:Say(STRINGS.JX_DRINKS_BUFF_ONDETACHED)
    end
    if target.components.locomotor then
      target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "jx_drink_coffee")
    end
  end
  inst:Remove()
end

local function Buff_Common_OnExtended(inst, target)
  if target and target:IsValid() and target.components.talker then
    target.components.talker:Say(STRINGS.JX_DRINKS_BUFF_ONATTACHED)
  end
  if inst.bufftask ~= nil then
    inst.bufftask:Cancel()
    inst.bufftask = inst:DoTaskInTime(inst.bufftime, Buff_OnKill)
  end
end

local function Buff_Coffee_OnExtended(inst, target)
  Buff_Common_OnExtended(inst, target)
  if target and target:IsValid() and target.components.sanity then
    target.components.sanity:DoDelta(-2)
  end
end

local function MakeBuff(buff_name, bufftime)
  local function bufffn()
    local inst = CreateEntity()
    
    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddTransform()
    
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")
    
    inst.bufftime = bufftime
    
    inst:AddComponent("debuff")
    if buff_name == "buff_jx_drink_cola" then
      inst.components.debuff:SetAttachedFn(Buff_Cola_OnAttached)
      inst.components.debuff:SetDetachedFn(Buff_Cola_OnDetached)
      inst.components.debuff:SetExtendedFn(Buff_Common_OnExtended)
    elseif buff_name == "buff_jx_drink_tea" then
      inst.components.debuff:SetAttachedFn(Buff_Tea_OnAttached)
      inst.components.debuff:SetDetachedFn(Buff_Tea_OnDetached)
      inst.components.debuff:SetExtendedFn(Buff_Common_OnExtended)
    elseif buff_name == "buff_jx_drink_coffee" then
      inst.components.debuff:SetAttachedFn(Buff_Coffee_OnAttached)
      inst.components.debuff:SetDetachedFn(Buff_Coffee_OnDetached)
      inst.components.debuff:SetExtendedFn(Buff_Coffee_OnExtended)
    end
    inst.components.debuff.keepondespawn = true

    return inst
  end
  
  table.insert(ret, Prefab(buff_name, bufffn))
end

MakeBuff("buff_jx_drink_cola", .1)
MakeBuff("buff_jx_drink_tea", 30)
MakeBuff("buff_jx_drink_coffee", 120)

return unpack(ret)