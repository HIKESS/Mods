local assets =
{
    Asset("ANIM", "anim/jx_honey_box.zip"),
    Asset("ANIM", "anim/ui_jx_storage_basket_4x4.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open"..inst.current_state)
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close"..inst.current_state)
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
      inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit"..inst.current_state)
    inst.AnimState:PushAnimation("closed"..inst.current_state, false)
    if inst.components.container then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed"..inst.current_state, false)
end

local function onitemget(inst)--, data)
  if not inst:HasTag("burnt") and inst.current_state == "_nohoney" then
    inst.current_state = ""
    if inst.components.container ~= nil then
      local openers = inst.components.container:GetOpeners()
      if #openers > 0 then
        inst.AnimState:PlayAnimation("idle_open"..inst.current_state)
      else
        inst.AnimState:PlayAnimation("idle"..inst.current_state)
      end
    end
  end
end

local function onitemlose(inst)--, data)
  if not inst:HasTag("burnt") and inst.current_state ~= "_nohoney" and
    inst.components.container ~= nil and inst.components.container:IsEmpty()
  then
    inst.current_state = "_nohoney"
    if inst.components.container ~= nil then
      local openers = inst.components.container:GetOpeners()
      if #openers > 0 then
        inst.AnimState:PlayAnimation("idle_open"..inst.current_state)
      else
        inst.AnimState:PlayAnimation("idle"..inst.current_state)
      end
    end
  end
end

local function onburnt(inst)
  if inst.components.container then
    inst.components.container:DropEverything()
  end
  DefaultBurntStructureFn(inst)
end

local function onsave(inst, data)
  if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
    data.burnt = true
  else
    data.current_state = inst.current_state
  end
end

local function onload(inst, data)
  if data then
    if data.burnt then
      inst.components.burnable.onburnt(inst)
    elseif data.current_state then
      inst.current_state = data.current_state
      inst.AnimState:PlayAnimation("closed"..inst.current_state)
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

	  inst:SetDeploySmartRadius(0.75)
    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("jx_honey_box.tex")

    inst:AddTag("structure")

    inst.AnimState:SetBank("jx_honey_box")
    inst.AnimState:SetBuild("jx_honey_box")
    inst.AnimState:PlayAnimation("closed_nohoney")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_honey_box")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    
    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(TUNING.JX_TUNING.jx_honey_box_preserver)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst.current_state = "_nohoney"
    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)

    AddHauntableDropItemOrWork(inst)
    
    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("jx_honey_box", fn, assets, prefabs),
    MakePlacer("jx_honey_box_placer", "jx_honey_box", "jx_honey_box", "closed")
