local assets =
{
    Asset("ANIM", "anim/jx_icebox.zip"),
    Asset("ANIM", "anim/jx_icebox_snow_build.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
    Asset("ANIM", "anim/ui_boat_ancient_4x4.zip"),
}

local prefabs =
{
    "collapse_small",
    "jx_icebox_fx",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
    
    inst.icebox_fx_task = inst:DoTaskInTime(.2, function()
      local fx = SpawnPrefab("jx_icebox_fx")
      if fx then
        fx.AnimState:SetScale(1.15, 1.15, 1.15)
        fx.entity:SetParent(inst.entity)
        inst.icebox_kitchen_fx = fx
      end
      inst.icebox_fx_task = nil
    end)
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close")
    
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
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
end

local function OnSnowCovered(inst, issnowcovered)
  if issnowcovered then
    inst.AnimState:SetBuild("jx_icebox_snow_build")
  else
    inst.AnimState:SetBuild("jx_icebox")
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	  inst:SetDeploySmartRadius(0.75) --recipe min_spacing/2

    inst.MiniMapEntity:SetIcon("jx_icebox.tex")

    inst:AddTag("fridge")
    inst:AddTag("structure")

    inst.AnimState:SetBank("jx_icebox")
    inst.AnimState:SetBuild("jx_icebox")
    inst.AnimState:PlayAnimation("closed")

    inst.SoundEmitter:PlaySound("dontstarve/common/ice_box_LP", "idlesound")

    --MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:WatchWorldState("issnowcovered", OnSnowCovered)
    if TheWorld.state.issnowcovered then
      OnSnowCovered(inst, true)
    end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_icebox")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    if TUNING.JX_TUNING.jx_icebox_reverse then
      inst:AddComponent("preserver")
	    inst.components.preserver:SetPerishRateMultiplier(-1)
    end

    inst:ListenForEvent("onbuilt", onbuilt)
    --MakeSnowCovered(inst)

    AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab("jx_icebox", fn, assets, prefabs),
    MakePlacer("jx_icebox_placer", "jx_icebox", "jx_icebox", "closed")
