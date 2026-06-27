local assets =
{
    Asset("ANIM", "anim/jx_icebox_2.zip"),
    Asset("ANIM", "anim/ui_jx_icebox_2_3x3.zip"),
}

local prefabs =
{
    "collapse_small",
    "jx_icebox_fx",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open", nil, .5)
    
    inst.icebox_fx_task = inst:DoTaskInTime(.2, function()
      local fx = SpawnPrefab("jx_icebox_fx")
      if fx then
        fx.AnimState:SetScale(.6, .6, .6)
        fx.entity:SetParent(inst.entity)
        inst.icebox_kitchen_fx = fx
      end
      inst.icebox_fx_task = nil
    end)
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close", nil, .5)
    
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
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.components.container:DropEverything()
    inst.AnimState:PushAnimation("closed", false)
    inst.components.container:Close()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft", nil, .5)
end

local function onitemget(inst, data)
  if data and data.item then
    if data.item:HasTag("frozen") then
      if data.item.components.perishable then
        data.item.components.perishable:StopPerishing()
      end
    end
  end
end

local function onitemlose(inst, data)
  if data and data.prev_item then
    if data.prev_item:HasTag("frozen") then
      if data.prev_item.components.perishable then
        data.prev_item.components.perishable:StartPerishing()
      end
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

    inst.MiniMapEntity:SetIcon("jx_icebox_2.tex")

    inst:AddTag("fridge")
    inst:AddTag("structure")

    inst.AnimState:SetBank("jx_icebox_2")
    inst.AnimState:SetBuild("jx_icebox_2")
    inst.AnimState:PlayAnimation("closed")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_icebox_2")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    
    if TUNING.JX_TUNING.jx_icebox_2_reverse then
      inst:AddComponent("preserver")
	    inst.components.preserver:SetPerishRateMultiplier(-1)
    end
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst:ListenForEvent("itemget", onitemget)--preserver组件与fridge标签冲突，所以额外写监听
    inst:ListenForEvent("itemlose", onitemlose)

    AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab("jx_icebox_2", fn, assets, prefabs),
    MakePlacer("jx_icebox_2_placer", "jx_icebox_2", "jx_icebox_2", "closed")
