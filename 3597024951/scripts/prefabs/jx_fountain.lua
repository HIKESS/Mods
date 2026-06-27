local assets =
{
    Asset("ANIM", "anim/jx_fountain.zip"),
}

local prefabs =
{
  "collapse_big",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.issummer then
      return
    else
      inst.AnimState:PlayAnimation("flow_pst")
      inst.AnimState:PushAnimation("off")
      inst.SoundEmitter:KillSound("loop")
      if inst.reflow_task then
        inst.reflow_task:Cancel()
        inst.reflow_task = nil
      end
      inst.reflow_task = inst:DoTaskInTime(2, function()
        if not inst.issummer then
          inst.AnimState:PlayAnimation("flow_pre")
          inst.AnimState:PushAnimation("flow_loop", true)
          inst.SoundEmitter:PlaySound("jx_flowing_water/flowing_water/water", "loop")
        end
      end)
    end
end

local function OnIsSummer(inst, issummer, noanim)
    inst.issummer = issummer
    if issummer then
      if noanim then
        inst.AnimState:PlayAnimation("off")
      else
        inst.AnimState:PlayAnimation("flow_pst")
        inst.AnimState:PushAnimation("off")
      end
      inst.SoundEmitter:KillSound("loop")
      if inst.components.watersource ~= nil then
        inst:RemoveComponent("watersource")
      end
    else
      inst.AnimState:PlayAnimation("flow_pre")
      inst.AnimState:PushAnimation("flow_loop", true)
      inst.SoundEmitter:PlaySound("jx_flowing_water/flowing_water/water", "loop")
      if inst.components.watersource == nil then
        inst:AddComponent("watersource")
      end
    end
end

local function GetDescription(inst)
  if inst.issummer then
    return STRINGS.JX_FOUNTAIN_INSUMMER
  else
    return STRINGS.CHARACTERS.GENERIC.DESCRIBE.JX_FOUNTAIN
  end
end

local function StartSpawnColorTask(inst)
  local life = 50
  local color = 0.02
  inst.spawn_colortask = inst:DoPeriodicTask(FRAMES,function()
    if life >= 1 then
      inst.AnimState:SetMultColour(1, 1, 1, color)
      life = life - 1
      color = color + 0.02
    else
      if inst.spawn_colortask then
        inst.spawn_colortask:Cancel()
        inst.spawn_colortask = nil
      end
      inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
  end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	  inst:SetDeploySmartRadius(0.5)
    MakeObstaclePhysics(inst, 1)
    
    inst.MiniMapEntity:SetIcon("jx_fountain.tex")

    inst:AddTag("structure")
    inst:AddTag("jx_fountain")

    inst.AnimState:SetBank("jx_fountain")
    inst.AnimState:SetBuild("jx_fountain")
    inst.AnimState:PlayAnimation("flow_loop", true)
    inst.AnimState:SetScale(.75, .75, .75)
    inst.AnimState:SetMultColour(1, 1, 1, 0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = GetDescription

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("watersource")
    
    inst:WatchWorldState("issummer", OnIsSummer)
    OnIsSummer(inst, TheWorld.state.issummer, true)
    
    inst:ListenForEvent("onbuilt", StartSpawnColorTask)
    
    inst:DoTaskInTime(.1, function()
      if inst.spawn_colortask == nil then
        inst.AnimState:SetMultColour(1, 1, 1, 1)
      end
    end)
    
    return inst
end

return Prefab("jx_fountain", fn, assets, prefabs),
    MakePlacer("jx_fountain_placer", "jx_fountain", "jx_fountain", "off", nil, nil, nil, .75)