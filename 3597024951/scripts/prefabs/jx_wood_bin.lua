local assets =
{
    Asset("ANIM", "anim/jx_wood_bin.zip"),
    Asset("ANIM", "anim/ui_jx_hay_cart_5x5.zip"),
}

local prefabs = 
{
  "collapse_big",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
      inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
  if not inst:HasTag("burnt") then
    inst.AnimState:PlayAnimation("hit_"..inst.current_state)
    inst.AnimState:PushAnimation("idle_"..inst.current_state, false)
    
    if inst.components.container ~= nil then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
  end
end

local function onbuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle_"..inst.current_state, false)
end

local function onburnt(inst)
  if inst.components.container then
    inst.components.container:DropEverything()
  end
  DefaultBurntStructureFn(inst)
end

local function UpdateSlot(inst)
  if inst:HasTag("burnt") or inst.components.container == nil then return end
  local log_valid_slot = 0
  local boards_valid_slot = 0
  for _, v in pairs(inst.components.container.slots) do
    if v and (v.prefab == "log" or v.prefab == "livinglog") then
      log_valid_slot = log_valid_slot + 1
    elseif v and v.prefab == "boards" then
      boards_valid_slot = boards_valid_slot + 1
    end
  end
  local log_rnd = 1--math.random(5, 7)
  local boards_num = 1--math.random(5, 7)
  if log_valid_slot >= log_rnd and boards_valid_slot >= boards_num then
    inst.current_state = "full_3"
  elseif log_valid_slot >= log_rnd and boards_valid_slot < boards_num then
    inst.current_state = "full_2"
  elseif log_valid_slot < log_rnd and boards_valid_slot >= boards_num then
    inst.current_state = "full_1"
  else
    inst.current_state = "empty"
  end
end

local function onitemget(inst)--, data)
  if inst:HasTag("burnt") or inst.components.container == nil then return end
  local old_state = inst.current_state
  UpdateSlot(inst)
  if old_state == "empty" or inst.current_state == "full_3" then
    inst.AnimState:PlayAnimation("idle_"..inst.current_state)
  end
end

local function onitemlose(inst)--, data)
  if inst:HasTag("burnt") or inst.components.container == nil then return end
  local old_state = inst.current_state
  UpdateSlot(inst)
  if old_state == "full_3" or inst.current_state == "empty" then
    inst.AnimState:PlayAnimation("idle_"..inst.current_state)
  end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
      if inst.components.burnable then
        inst.components.burnable.onburnt(inst)
      end
    end
end

local function fn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    
    inst:SetDeploySmartRadius(.5)
    MakeObstaclePhysics(inst, 1)
    
    inst.MiniMapEntity:SetIcon("jx_wood_bin.tex")
    
    inst:AddTag("structure")
    
    inst.AnimState:SetBank("jx_wood_bin")
    inst.AnimState:SetBuild("jx_wood_bin")
    inst.AnimState:PlayAnimation("idle_empty")
    
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
    inst.components.container:WidgetSetup("jx_wood_bin") 
    
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)
    
    MakeHauntable(inst)
    
    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst.current_state = "empty"
    
    inst:DoTaskInTime(.1, function() UpdateSlot(inst) end)
    
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    return inst
end

return Prefab("jx_wood_bin", fn, assets, prefabs),
  MakePlacer("jx_wood_bin_placer", "jx_wood_bin", "jx_wood_bin", "idle_empty")