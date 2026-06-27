local assets =
{
    Asset("ANIM", "anim/jx_pickling_barrel.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("saltydog/common/saltbox/open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("saltydog/common/saltbox/close")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
      inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    if inst.components.container then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
    inst.AnimState:PushAnimation("closed", false)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("saltydog/common/saltbox/place")
end

local function UpdateSlot(inst)
  if inst:HasTag("burnt") or inst.components.container == nil then return end
  local shouldshow
  for _, v in pairs(inst.components.container.slots) do
    if v and not v:HasTag("dryable") then
      shouldshow = true
      break
    end
  end
  if shouldshow then
    inst.AnimState:Show("body3")
  else
    inst.AnimState:Hide("body3")
  end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
      inst.components.burnable.onburnt(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

  	inst:SetDeploySmartRadius(0.5)

    inst:AddTag("saltbox")
    inst:AddTag("rainimmunity")
    inst:AddTag("structure")

    inst.AnimState:SetBank("jx_pickling_barrel")
    inst.AnimState:SetBuild("jx_pickling_barrel")
    inst.AnimState:PlayAnimation("closed")
    inst.AnimState:Hide("body3")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_pickling_barrel")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst:ListenForEvent("itemget", UpdateSlot)
    inst:ListenForEvent("itemlose", UpdateSlot)
    
    inst:AddComponent("dryingrack")
    inst.components.dryingrack:EnableDrying()
    
    inst:AddComponent("rainimmunity")
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    
    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    
    AddHauntableDropItemOrWork(inst)
    
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("jx_pickling_barrel", fn, assets, prefabs),
    MakePlacer("jx_pickling_barrel_placer", "jx_pickling_barrel", "jx_pickling_barrel", "closed")