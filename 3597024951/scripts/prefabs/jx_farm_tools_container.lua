local assets =
{
    Asset("ANIM", "anim/jx_farm_tools_container.zip"),
    Asset("ANIM", "anim/ui_jx_hay_cart_4x4.zip"),
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
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
    
    if inst.components.container ~= nil then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
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

local function UpdateSlot(inst)
  local dig
  local hammer
  local wateringcan
  local farmtiller
  local fertilizer
  for _, v in pairs(inst.components.container.slots) do
    if v then
      if v:HasTag(ACTIONS.DIG.id.."_tool") then
        dig = true
      end
      if v:HasTag(ACTIONS.HAMMER.id.."_tool") then
        hammer = true
      end
      if v:HasTag("wateringcan") then
        wateringcan = true
      end
      if v.components.farmtiller then
        farmtiller = true
      end
      if v.components.fertilizer then
        fertilizer = true
      end
    end
  end
  if dig then
    inst.AnimState:Show("tool0")
  else
    inst.AnimState:Hide("tool0")
  end
  if hammer then
    inst.AnimState:Show("tool2")
  else
    inst.AnimState:Hide("tool2")
  end
  if wateringcan then
    inst.AnimState:Show("tool4")
  else
    inst.AnimState:Hide("tool4")
  end
  if farmtiller then
    inst.AnimState:Show("tool1")
  else
    inst.AnimState:Hide("tool1")
  end
  if fertilizer then
    inst.AnimState:Show("tool3")
  else
    inst.AnimState:Hide("tool3")
  end
end

local function onitemget(inst, data)
  if inst:HasTag("burnt") or inst.components.container == nil then return end
  UpdateSlot(inst)
end

local function onitemlose(inst, data)
  if inst:HasTag("burnt") or inst.components.container == nil then return end
  UpdateSlot(inst)
end

local function OnInit(inst)
  for i = 0, 4 do
    inst.AnimState:Hide("tool"..i)
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
    
    inst.MiniMapEntity:SetIcon("jx_farm_tools_container.tex")
    
    inst:AddTag("structure")
    
    inst.AnimState:SetBank("jx_farm_tools_container")
    inst.AnimState:SetBuild("jx_farm_tools_container")
    inst.AnimState:PlayAnimation("idle")
    
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
    inst.components.container:WidgetSetup("jx_farm_tools_container") 
    
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)
    
    MakeHauntable(inst)
    
    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    OnInit(inst)
    
    return inst
end


return Prefab("jx_farm_tools_container", fn, assets, prefabs),
  MakePlacer("jx_farm_tools_container_placer", "jx_farm_tools_container", "jx_farm_tools_container", "placer")