local assets =
{
  Asset("ANIM", "anim/jx_bankatm.zip"),
}

local prefabs =
{
  "collapse_big",
  "jx_catcoin",
}

local function onhammered(inst)
  if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
    inst.components.burnable:Extinguish()
  end
  inst.components.lootdropper:DropLoot()
  
  local fx = SpawnPrefab("collapse_big")
  fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
  fx:SetMaterial("metal")
  inst:Remove()
end

local function onhit(inst)
  if not inst:HasTag("burnt") then
    if inst.components.container then
      inst.components.container:DropEverything()
    end
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
  end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
end

local function onburnt(inst)
  if inst.components.container then
    inst.components.container:DropEverything()
  end
  DefaultBurntStructureFn(inst)
end

local function OnOpen(inst, data)
  inst.AnimState:PlayAnimation("open")
  inst.AnimState:PushAnimation("idle", false)
  if data and data.doer and data.doer.userid then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Vending_Machine_Sound"), data.doer.userid, "jx_bankatm_open")
  end
end

local function OnClose(inst, doer)
  inst.AnimState:PlayAnimation("close")
  inst.AnimState:PushAnimation("idle", false)
  if doer and doer.userid then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Vending_Machine_Sound"), doer.userid, "jx_bankatm_open")
  end
end

local function StartWork(inst)
  if inst.components.container then
    inst.components.container:Close()
    inst.components.container.canbeopened = false
    inst:DoTaskInTime(1, function() inst.components.container.canbeopened = true end)
  end
  inst.AnimState:PlayAnimation("work")
  inst.AnimState:PushAnimation("idle", false)
  
  local total_stacksize = 0
  if inst.components.container then
    for i = 1, inst.components.container.numslots do
      local item = inst.components.container:GetItemInSlot(i)
      if item and not item:HasTag("jx_catcoin") then
        local stackable = item.components.stackable
        local stacksize = stackable and stackable:StackSize() or 1
        total_stacksize = total_stacksize + stacksize
      end
    end
  end
  
  local num_to_give = (total_stacksize - (total_stacksize % 5)) / 5
  if num_to_give > 0 then
    for i = 1, num_to_give do
      for j = 1, 5 do
        local item = inst.components.container:FindItem(function(v) return not v:HasTag("jx_catcoin") end)
        if item.components.stackable then
          item.components.stackable:Get():Remove()
        else
          item:Remove()
        end
      end
      local coin = SpawnPrefab("jx_catcoin")
      if coin then
        coin.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if inst.components.container then
          inst.components.container:GiveItem(coin)
        end
      end
    end
  end
  
  local x, y, z = inst.Transform:GetWorldPosition()
  local ents = TheSim:FindEntities(x, y, z, 8, { "player" })
  for _, v in ipairs(ents) do
    if v and v.userid then
      SendModRPCToClient(GetClientModRPC("JX", "JX_Vending_Machine_Sound"), v.userid, "give_coin")
    end
  end
end

local function atmfn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(1)
    
    MakeObstaclePhysics(inst, 1)
    
    inst:AddTag("structure")
    inst:AddTag("jx_bankatm")
    inst:AddTag("jx_button_container")
    
    inst.AnimState:SetBank("jx_bankatm")
    inst.AnimState:SetBuild("jx_bankatm")
    inst.AnimState:PlayAnimation("idle")
    
    inst.MiniMapEntity:SetIcon("jx_bankatm.tex")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_bankatm")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    
    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst.StartWork = StartWork
    
    return inst
end

local function coinfn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("jx_bankatm")
    inst.AnimState:SetBuild("jx_bankatm")
    inst.AnimState:PlayAnimation("coin")
    
    inst:AddTag("jx_catcoin")
    
    MakeInventoryFloatable(inst, "med", 0.05, 0.68)
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_PELLET
    
    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 5
    inst.components.tradable.rocktribute = 2 -- 蚁狮换取沙之石
    
    return inst
end

return Prefab("jx_bankatm", atmfn, assets, prefabs),
    MakePlacer("jx_bankatm_placer", "jx_bankatm", "jx_bankatm", "idle"),
    Prefab("jx_catcoin", coinfn, assets)