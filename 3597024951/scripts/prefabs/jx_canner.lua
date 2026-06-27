local assets =
{
    Asset("ANIM", "anim/jx_canner.zip"),
}

local prefabs = 
{
  "jx_can0",
  "jx_can1",
  "jx_can2",
  "collapse_small",
  "sand_puff",
}

local function OnOpen(inst)
  inst.AnimState:PlayAnimation("open")
  inst.AnimState:PushAnimation("idle_open", false)
end

local function OnClose(inst)
  inst.AnimState:PlayAnimation("close")
  inst.AnimState:PushAnimation("idle", false)
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    
    inst.components.lootdropper:DropLoot()
    
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst)--, worker)
  if not inst:HasTag("burnt") then
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)
    if inst.components.container ~= nil then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
    if inst.components.timer and inst.components.timer:TimerExists("cd") then
      inst.components.timer:StopTimer("cd")
    end
  end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", false)
	--inst.SoundEmitter:PlaySound()
end

local function onburnt(inst)
  if inst.components.container then
    inst.components.container:DropEverything()
  end
  if inst.components.timer and inst.components.timer:TimerExists("cd") then
    inst.components.timer:StopTimer("cd")
  end
  DefaultBurntStructureFn(inst)
end

local function StartWork(inst)
  if inst:HasTag("burnt") then
    return false
  end
  
  if inst.components.container then
    local rocks = inst.components.container:FindItem(function(v) return v.prefab == "rocks" end)
    local others = inst.components.container:FindItem(function(v) return v.prefab ~= "rocks" end)
    if rocks == nil or others == nil then
      return false
    end
    
    inst.components.container:Close()
    inst.components.container.canbeopened = false
  end
  
  inst.SoundEmitter:PlaySound("jx_canner/jx_canner/canner_loop", "loop")
  
  if inst.components.timer then
    if inst.components.timer:TimerExists("cd") then
      inst.components.timer:StopTimer("cd")
    end
    inst.components.timer:StartTimer("cd", TUNING.JX_TUNING.jx_canner_worktime)
  end
  
  return true
end

local function ontimerdone(inst, data)
  if data and data.name == "cd" then
    inst.SoundEmitter:KillSound("loop")
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("close")
    inst.AnimState:PushAnimation("idle", false)
    
    if inst.components.container then
      local rocks = inst.components.container:FindItem(function(v) return v.prefab == "rocks" end)
      local others = inst.components.container:FindItem(function(v) return v.prefab ~= "rocks" end)
      if rocks == nil or others == nil then
        return
      end
      
      local can_item
      local can_prefab
      if others.prefab == "kelp_dried" then -- 干海带叶
        can_prefab = "jx_can0"
      elseif others.prefab == "meat_dried" then -- 肉干类
        can_prefab = "jx_can1"
      elseif others.prefab == "fishmeat_dried" then -- 鱼干类
        can_prefab = "jx_can2"
      end
      if can_prefab then
        can_item = SpawnPrefab(can_prefab)
      end
      if can_item then
        if others.components.perishable then
          can_item.product_percent = others.components.perishable:GetPercent()
        end
        local pos = inst:GetPosition()
        local rnd_x = math.random(-10, 10) / 10
        local rnd_z = math.random(-10, 10) / 10
        can_item.Transform:SetPosition(pos.x + rnd_x, pos.y, pos.z + rnd_z)
        can_item.components.inventoryitem:OnDropped(true)
        can_item:DoTaskInTime(1, function()
          if can_item.components.stackable == nil then
            return
          end
          local x, y, z = can_item.Transform:GetWorldPosition()
          local ents = TheSim:FindEntities(x, y, z, 10, {"jx_can", "_stackable"}, {"INLIMBO", "NOCLICK"})
          for _, v in ipairs(ents) do
            if v and v ~= can_item and v.prefab == can_item.prefab and
              v.components.inventoryitem and v.components.inventoryitem:GetGrandOwner() == nil and
              v.components.stackable and not v.components.stackable:IsFull()
            then
              SpawnPrefab("sand_puff").Transform:SetPosition(v.Transform:GetWorldPosition())
              can_item.components.stackable:Put(v)
            end
          end
        end)
        inst.components.container:RemoveItem(others):Remove()
        inst.components.container:RemoveItem(rocks):Remove()
      end
      
      if not StartWork(inst) then
        inst.components.container.canbeopened = true
      end
    end
  end
end

local function OnSave(inst, data)
  if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
    data.burnt = true
  end
end

local function OnLoad(inst, data)
  if data and data.burnt then
    inst.components.burnable.onburnt(inst)
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
    MakeObstaclePhysics(inst, .5)
    
    inst.MiniMapEntity:SetIcon("jx_canner.tex")
    
    inst:AddTag("structure")
    inst:AddTag("jx_canner")
    inst:AddTag("jx_button_container")
    
    inst.AnimState:SetBank("jx_canner")
    inst.AnimState:SetBuild("jx_canner")
    inst.AnimState:PlayAnimation("idle")
    
    inst.entity:SetPristine()
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
  	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	  inst.components.workable:SetWorkLeft(4)
	  inst.components.workable:SetOnFinishCallback(onhammered)
	  inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_canner")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
        
    inst:ListenForEvent( "onbuilt", onbuilt)
    
    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeMediumPropagator(inst)
    
    inst.StartWork = StartWork
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    
    return inst
end

return Prefab( "jx_canner", fn, assets, prefabs),
		MakePlacer( "jx_canner_placer", "jx_canner", "jx_canner", "idle" )