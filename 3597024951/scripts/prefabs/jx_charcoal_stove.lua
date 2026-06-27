local assets =
{
    Asset("ANIM", "anim/jx_charcoal_stove.zip"),
}

local prefabs = 
{
  "charcoal",
  "collapse_small",
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
    return
  end
  
  if inst.components.container then
    local log = inst.components.container:FindItem(function(v) return v.prefab == "log" end)
    if log == nil then
      return
    end
    
    inst.components.container:Close()
    inst.components.container.canbeopened = false
  end
  
  inst.SoundEmitter:PlaySound("jx_charcoal_stove/jx_charcoal_stove/workloop", "loop")
  
  if inst.components.timer then
    if inst.components.timer:TimerExists("cd") then
      inst.components.timer:StopTimer("cd")
    end
    inst.components.timer:StartTimer("cd", 5)
  end
end

local function ontimerdone(inst, data)
  if data and data.name == "cd" then
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    inst.AnimState:PlayAnimation("workover")
    inst.AnimState:PushAnimation("idle", false)
    
    if inst.components.container then
      for _, v in pairs(inst.components.container.slots) do
        if v and v.prefab == "log" then
          local stacksize = v.components.stackable and v.components.stackable:StackSize() or 1
          inst.components.container:RemoveItem(v, true):Remove()
          for i = 1, stacksize do
            local charcoal = SpawnPrefab("charcoal")
            if charcoal then
              inst.components.container:GiveItem(charcoal)
            end
          end
        end
      end
      
      inst.components.container.canbeopened = true
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
    
    inst.MiniMapEntity:SetIcon("jx_charcoal_stove.tex")
    
    inst:AddTag("structure")
    inst:AddTag("jx_charcoal_stove")
    inst:AddTag("jx_button_container")
    
    inst.AnimState:SetBank("jx_charcoal_stove")
    inst.AnimState:SetBuild("jx_charcoal_stove")
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
    inst.components.container:WidgetSetup("jx_charcoal_stove")
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

return Prefab( "jx_charcoal_stove", fn, assets, prefabs),
		MakePlacer( "jx_charcoal_stove_placer", "jx_charcoal_stove", "jx_charcoal_stove", "idle" )