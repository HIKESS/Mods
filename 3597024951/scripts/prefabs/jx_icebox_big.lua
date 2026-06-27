local assets =
{
    Asset("ANIM", "anim/jx_icebox_big.zip"),
    Asset("ANIM", "anim/ui_jx_icebox_big_5x4.zip"),
}

local prefabs =
{
    "collapse_big",
    "jx_icebox_fx_2",
}

local function onopen(inst, data)
    inst.AnimState:PlayAnimation("open"..inst.ContainerState)
    --inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
    
    inst.icebox_fx_task = inst:DoTaskInTime(.2, function()
      local fx = SpawnPrefab("jx_icebox_fx_2")
      if fx then
        fx.AnimState:SetScale(1.3, 1.3, 1.3)
        fx.entity:SetParent(inst.entity)
        inst.icebox_kitchen_fx = fx
      end
      inst.icebox_fx_task = nil
    end)
    
    if data and data.doer and data.doer.userid then
      SendModRPCToClient(GetClientModRPC("JX", "JX_Icebox_PlaySound"), data.doer.userid, "open")
    end
end

local function onclose(inst, doer)
    inst.AnimState:PlayAnimation("close"..inst.ContainerState)
    --inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close")
    
    if inst.icebox_fx_task then
      inst.icebox_fx_task:Cancel()
      inst.icebox_fx_task = nil
    end
    if inst.icebox_kitchen_fx then
      if inst.icebox_kitchen_fx:IsValid() then
        inst.icebox_kitchen_fx:Kill()
      end
      inst.icebox_kitchen_fx = nil
    end
    
    if doer and doer.userid then
      SendModRPCToClient(GetClientModRPC("JX", "JX_Icebox_PlaySound"), doer.userid, "close")
    end
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
      inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.container then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
    inst.AnimState:PlayAnimation("hit_empty")
    inst.AnimState:PushAnimation("idle_empty", false)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_empty", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
end

local function UpdateAnim(inst)--, data)
  if inst.components.container == nil then
    return "_none"
  end
  if inst.components.container then
    local valid_slot = 0
    for _, v in pairs(inst.components.container.slots) do
      if v and not v:HasTag("heatrock") then
        valid_slot = valid_slot + 1
      end
    end
    --local line = math.random(4, 10)
    local line = 1
    if valid_slot >= line then
      return "_full"
    else
      return "_empty"
    end
  end
end

local function onitemget(inst)--, data)
  local old_state = inst.ContainerState
  local new_state = UpdateAnim(inst)
  if old_state == "_empty" and new_state == "_full" then
    inst.ContainerState = new_state
    if inst.components.container and inst.components.container:IsOpen() then
      inst.AnimState:PlayAnimation("open_full")
    else
      inst.AnimState:PlayAnimation("idle_full")
    end
  end
end

local function onitemlose(inst)--, data)
  if inst.components.container == nil then return end
  local old_state = inst.ContainerState
  local new_state = UpdateAnim(inst)
  if old_state == "_full" and new_state == "_empty" then
    inst.ContainerState = new_state
    if inst.components.container and inst.components.container:IsOpen() then
      inst.AnimState:PlayAnimation("open_empty")
    else
      inst.AnimState:PlayAnimation("idle_empty")
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

	  inst:SetDeploySmartRadius(1)
    MakeObstaclePhysics(inst, .9)

    inst.MiniMapEntity:SetIcon("jx_icebox_big.tex")

    inst:AddTag("fridge")
    inst:AddTag("structure")

    inst.AnimState:SetBank("jx_icebox_big")
    inst.AnimState:SetBuild("jx_icebox_big")
    inst.AnimState:PlayAnimation("idle_empty")

    --inst.SoundEmitter:PlaySound("dontstarve/common/ice_box_LP", "idlesound")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_icebox_big")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    if TUNING.JX_TUNING.jx_icebox_big_reverse then
      inst:AddComponent("preserver")
	    inst.components.preserver:SetPerishRateMultiplier(-1)
    end

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)
    
    AddHauntableDropItemOrWork(inst)
    
    inst.ContainerState = "_empty"

    return inst
end

return Prefab("jx_icebox_big", fn, assets, prefabs),
    MakePlacer("jx_icebox_big_placer", "jx_icebox_big", "jx_icebox_big", "idle_empty")
