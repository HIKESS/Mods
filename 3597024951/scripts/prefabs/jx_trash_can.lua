local assets =
{
	Asset("ANIM", "anim/jx_trash_can.zip"),
}

local prefabs =
{
  "collapse_small",
  "jx_trash_can_container",
}

local function onhammered(inst)
  inst.components.lootdropper:DropLoot()
  if inst.components.container ~= nil then
    inst.components.container:DropEverything()
  end
  local fx = SpawnPrefab("collapse_small")
  fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
  fx:SetMaterial("metal")
  inst:Remove()
end

local function onhit(inst)
  if inst.components.container ~= nil then
    inst.components.container:DropEverything()
    inst.components.container:Close()
  end
end

local function UpdateSlot(inst)
  if inst.components.container and inst.components.container:HasItemWithTag("spoiledfood", 1) then
    inst.AnimState:Show("can2")
  else
    inst.AnimState:Hide("can2")
  end
end

local function onopen(inst)
  UpdateSlot(inst)
  inst.AnimState:Hide("can3")
end

local function onclose(inst)
  UpdateSlot(inst)
  inst.AnimState:Show("can3")
end

local function onnear(inst, player)
  if player == nil then
    return
  end
  if player.jx_trash_jan_container == nil or not player.jx_trash_jan_container:IsValid() then
    player.jx_trash_jan_container = SpawnPrefab("jx_trash_can_container")
    if player.jx_trash_jan_container then
      player.jx_trash_jan_container.entity:SetParent(player.entity)
    end
  end
  if player.userid then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Trash_Can_Button"), player.userid, true)
  end
end

local function onfar(inst, player)
  if player == nil then
    return
  end
  if player.jx_trash_jan_container and player.jx_trash_jan_container:IsValid() then
    player.jx_trash_jan_container:Remove()
    player.jx_trash_jan_container = nil
  end
  if player.userid then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Trash_Can_Button"), player.userid, false)
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("jx_trash_can.tex")

    inst:SetDeploySmartRadius(0.5)

    inst:AddTag("structure")

    inst.AnimState:SetBank("jx_trash_can")
    inst.AnimState:SetBuild("jx_trash_can")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_trash_can")
    inst.components.container:EnableInfiniteStackSize(true)
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst:ListenForEvent("itemget", UpdateSlot)
    inst:ListenForEvent("itemlose", UpdateSlot)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(10)
    
    --[[inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(27, 28)
    inst.components.playerprox:Schedule(3)
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)]]
    
    UpdateSlot(inst)

    return inst
end

local function containerfn()
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_trash_can_container")
    inst.components.container.onclosefn = onclose
    
    return inst
end

return Prefab("jx_trash_can", fn, assets, prefabs),
    MakePlacer("jx_trash_can_placer", "jx_trash_can", "jx_trash_can", "idle"),
    Prefab("jx_trash_can_container", containerfn)