local assets =
{
	Asset("ANIM", "anim/jx_glommer_house.zip"),
}

local prefabs =
{
  "collapse_small",
  "glommerfuel",
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
      if f.is_diarrhea then
        inst.is_diarrhea = true
      end
      f:RemoveFromScene()
      if f.components.brain ~= nil then
        BrainManager:Hibernate(f)
      end
      if f.components.periodicspawner ~= nil then
        f.components.periodicspawner:Stop()
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
    
    if inst.components.timer then
      inst.components.timer:StopTimer("cd")
      local cd = math.random(960, 1920) -- 2 ~ 4 天
      inst.components.timer:StartTimer("cd", cd)
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
      if f.components.periodicspawner ~= nil then
        f.components.periodicspawner:Start()
      end
    end
    
    if not data.noanim then
      inst.AnimState:PlayAnimation("out")
      inst.AnimState:PushAnimation("idle", false)
    end
    
    if inst.components.timer then
      inst.components.timer:StopTimer("cd")
    end
  end
end

local function ontimerdone(inst, data)
  if data and data.name == "cd" then
    local old_glommerfuel
    local old_medal_glommer_essence
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4)
    
    for _, v in ipairs(ents) do
      if v and v.prefab == "glommerfuel" and
        v.components.inventoryitem and v.components.inventoryitem:GetGrandOwner() == nil and
        v.components.stackable and not v.components.stackable:IsFull()
      then
        old_glommerfuel = v
        break
      end
    end
    for _, v in ipairs(ents) do
      if v and v.prefab == "medal_glommer_essence" and -- 能力勋章格罗姆精华
        v.components.inventoryitem and v.components.inventoryitem:GetGrandOwner() == nil and
        v.components.stackable and not v.components.stackable:IsFull()
      then
        old_medal_glommer_essence = v
        break
      end
    end
    
    if old_glommerfuel then
      old_glommerfuel.components.stackable:SetStackSize(old_glommerfuel.components.stackable:StackSize() + 1)
    else
      local glommerfuel = SpawnPrefab("glommerfuel")
      if glommerfuel then
        glommerfuel.Transform:SetPosition(x, y, z)
        if glommerfuel.components.inventoryitem then
          glommerfuel.components.inventoryitem:OnDropped(true)
        end
      end
    end
    
    local medal_glommer_essence_numtospawn = inst.is_diarrhea and math.random(3, 4) or 1
    inst.is_diarrhea = nil
    for i = 1, medal_glommer_essence_numtospawn do
      if old_medal_glommer_essence and not old_medal_glommer_essence.components.stackable:IsFull() then
        old_medal_glommer_essence.components.stackable:SetStackSize(old_medal_glommer_essence.components.stackable:StackSize() + 1)
      else
        local medal_glommer_essence = SpawnPrefab("medal_glommer_essence")
        if medal_glommer_essence then
          medal_glommer_essence.Transform:SetPosition(x, y, z)
          if medal_glommer_essence.components.inventoryitem then
            medal_glommer_essence.components.inventoryitem:OnDropped(true)
          end
        end
      end
    end
    
    local cd = math.random(960, 1920) -- 2 ~ 4 天
    inst.components.timer:StartTimer("cd", cd)
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

local function OnSave(inst, data)
  if inst.is_diarrhea then
    data.is_diarrhea = true
  end
end

local function OnLoad(inst, data)
  if data and data.is_diarrhea then
    inst.is_diarrhea = true
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    
    inst.MiniMapEntity:SetIcon("jx_glommer_house.tex")
    
    inst:SetDeploySmartRadius(1)
    
    inst:AddTag("structure")
    inst:AddTag("jx_glommer_house")
    
    inst.AnimState:SetBank("jx_glommer_house")
    inst.AnimState:SetBuild("jx_glommer_house")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_glommer_house")
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    MakeSmallBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst:ListenForEvent("itemget", onitemget)
    inst:ListenForEvent("itemlose", onitemlose)
    
    inst:DoTaskInTime(1, oninit)
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    
    return inst
end

return Prefab("jx_glommer_house", fn, assets, prefabs),
    MakePlacer("jx_glommer_house_placer", "jx_glommer_house", "jx_glommer_house", "idle")