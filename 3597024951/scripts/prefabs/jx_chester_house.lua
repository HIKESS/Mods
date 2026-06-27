local assets =
{
	Asset("ANIM", "anim/jx_chester_house.zip"),
}

local prefabs =
{
  "collapse_small",
}

local function onhammered(inst, worker)
  if inst.components.burnable and inst.components.burnable:IsBurning() then
    inst.components.burnable:Extinguish()
  end
  inst.components.lootdropper:DropLoot()
  if inst.components.container then
    inst.components.container:DropEverything()
  end
  local fx = SpawnPrefab("collapse_small")
  fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
  fx:SetMaterial("wood")
  inst:Remove()
end

local function onhit(inst)--, worker)
  if not inst:HasTag("burnt") then
    if inst.components.container then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
  end
end

local function onburnt(inst)
	if inst.components.container then
    inst.components.container:DropEverything()
	end
	DefaultBurntStructureFn(inst)
end

local function onbuilt(inst)
  inst.AnimState:PlayAnimation("place")
  inst.AnimState:PushAnimation("idle", false)
end

local function onitemget(inst, data)
  if data and data.item and data.item.components.leader then
    local followers = {}
    for k in pairs(data.item.components.leader.followers) do
      table.insert(followers, k)
    end
    for _, f in ipairs(followers) do
      f:RemoveFromScene()
      if f.components.brain ~= nil then
        BrainManager:Hibernate(f)
      end
      if f.SoundEmitter ~= nil then
        f.SoundEmitter:KillAllSounds()
      end
      local pos = inst:GetPosition()
      local rnd_x = math.random(-10, 10) / 10
      local rnd_z = math.random(-10, 10) / 10
      if f.Physics then
        f.Physics:Teleport(pos.x + rnd_x, pos.y, pos.z + rnd_z)
      elseif f.Transform then
        f.Transform:SetPosition(pos.x + rnd_x, pos.y, pos.z + rnd_z)
      end
    end
    
    if not data.noanim then
      inst.AnimState:PlayAnimation("enter")
      inst.AnimState:PushAnimation("idle_closed", false)
    end
  end
end

local function onitemlose(inst, data)
  if data and data.prev_item and data.prev_item.components.leader then
    local followers = {}
    for k in pairs(data.prev_item.components.leader.followers) do
      table.insert(followers, k)
    end
    for _, f in ipairs(followers) do
      f:ReturnToScene()
      if f.components.brain ~= nil then
        BrainManager:Wake(f)
      end
    end
    
    if not data.noanim then
      inst.AnimState:PlayAnimation("out")
      inst.AnimState:PushAnimation("idle", false)
    end
  end
end

local function oninit(inst)
  if not inst:HasTag("burnt") and inst.components.container and not inst.components.container:IsEmpty() then
    for k, v in pairs(inst.components.container.slots) do
      if v then
        onitemlose(inst, { prev_item = v , noanim = true})
        onitemget(inst, { item = v , noanim = true})
        inst.AnimState:PlayAnimation("idle_closed")
      end
    end
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    
    inst.MiniMapEntity:SetIcon("jx_chester_house.tex")
    
    inst:SetDeploySmartRadius(1)
    
    inst:AddTag("structure")
    inst:AddTag("jx_chester_house")
    
    inst.AnimState:SetBank("jx_chester_house")
    inst.AnimState:SetBuild("jx_chester_house")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_chester_house")
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeSmallBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)
    
    inst:DoTaskInTime(1, oninit)
    
    return inst
end

return Prefab("jx_chester_house", fn, assets, prefabs),
    MakePlacer("jx_chester_house_placer", "jx_chester_house", "jx_chester_house", "idle")