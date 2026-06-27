local assets =
{
    Asset("ANIM", "anim/jx_cellar.zip"),
    Asset("ANIM", "anim/ui_jx_cellar_5x5.zip"),
}

local prefabs =
{
  "collapse_big",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("idle_open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("idle_close")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
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
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle_close", false)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_close", false)
end

local function UpdatePreserve(inst)
  if inst.components.container == nil then return end
  local valid_slot = 0
  for _, v in pairs(inst.components.container.slots) do
    if v and (v.prefab == "saltrock" or v.prefab == "coral") then -- coral 是海难珊瑚
      valid_slot = valid_slot + 1
    end
  end
  valid_slot = math.min(valid_slot, TUNING.JX_TUNING.jx_cellar_maxsaltrock)
  if inst.components.preserver then
    inst.components.preserver:SetPerishRateMultiplier(.5 - valid_slot / 35 * .5)
  end
end

local function onitemget(inst, data)
  if data and data.item and (data.item.prefab == "saltrock" or data.item.prefab == "coral") then
    UpdatePreserve(inst)
  end
end

local function onitemlose(inst, data)
  if data and data.prev_item and (data.prev_item.prefab == "saltrock" or data.prev_item.prefab == "coral") then
    UpdatePreserve(inst)
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    
	  inst:SetDeploySmartRadius(1.5)
    MakeObstaclePhysics(inst, 1)
    
    inst.MiniMapEntity:SetIcon("jx_cellar.tex")
    
    inst:AddTag("structure")

    inst.AnimState:SetBank("jx_cellar")
    inst.AnimState:SetBuild("jx_cellar")
    inst.AnimState:PlayAnimation("idle_close")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_cellar")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    
    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(.5)
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)

    AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab("jx_cellar", fn, assets, prefabs),
    MakePlacer("jx_cellar_placer", "jx_cellar", "jx_cellar", "idle_close")
