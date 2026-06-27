local assets =
{
    Asset("ANIM", "anim/jx_car.zip"),
    Asset("ANIM", "anim/jx_car_2.zip"),
}

local prefabs =
{
    "collapse_big",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("jx_sound_5/jx_sound_5/open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("jx_sound_5/jx_sound_5/close")
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
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("closed", false)
    if inst.components.container then
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
end

local function ontakefuel(inst)
  inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/add_fuel")
end

local function OnNewState(inst, data)
  if inst.components.health and not inst.components.health:IsDead() then
    local current_time = GetTime()
    local last_time = inst.last_state_change_time
    local cool_down_time = .1
    if last_time == nil or current_time - last_time > cool_down_time then
	    if not inst.sg:HasAnyStateTag("drive_valid", "dead", "running", "dismounting") then
        inst.last_state_change_time = current_time
        inst.sg:GoToState("drive_idle")
	    end
    end
  end
end

local function OnRiderChanged(inst, data)
  if data then
    if data.newrider then
      data.newrider:ListenForEvent("newstate", OnNewState)
    elseif data.oldrider then
      data.oldrider:RemoveEventCallback("newstate", OnNewState)
    end
  end
end

local function OnGetItem(inst, data)
  if data and data.item and data.slot and data.slot >= inst.parts_start_slot then
    local item = data.item 
    local jx_rideable = inst.components.jx_rideable
    if jx_rideable == nil then return end
    
    if item:HasTag("jx_parts_light") then
      if item.extra_light then jx_rideable.extra_light = item.extra_light end
    elseif item:HasTag("jx_parts_engine") then
      jx_rideable.engine_parts = true
    elseif item:HasTag("jx_parts_music") then
      jx_rideable.music_parts = true
    elseif item:HasTag("jx_parts_wheel") then
      jx_rideable.wheel_parts = true
    elseif item:HasTag("jx_parts_camera_1") then
      jx_rideable.camera_follow_mode = true
    elseif item:HasTag("jx_parts_camera_2") then
      jx_rideable.camera_auto_mode = true
    end
    
  end
end

local function OnLoseItem(inst, data)
  if data and data.prev_item and data.slot and data.slot >= inst.parts_start_slot then
    local item = data.prev_item 
    local jx_rideable = inst.components.jx_rideable
    local container = inst.components.container
    
    if container then
      if item:HasTag("jx_parts_light") then
        local own_any_other_light = false
        for i = inst.parts_start_slot, container:GetNumSlots() do
          if container:GetItemInSlot(i) ~= nil and container:GetItemInSlot(i):HasTag("jx_parts_light") then
            own_any_other_light = true
            break
          end
        end
        if not own_any_other_light then
          if jx_rideable and jx_rideable.org_extra_light then
            jx_rideable.extra_light = jx_rideable.org_extra_light
          end
        end
        
      elseif item:HasTag("jx_parts_engine") then
        local own_any_other_engine = false
        for i = inst.parts_start_slot, container:GetNumSlots() do
          if container:GetItemInSlot(i) ~= nil and container:GetItemInSlot(i):HasTag("jx_parts_engine") then
            own_any_other_engine = true
            break
          end
        end
        if not own_any_other_engine then
          if jx_rideable then
            jx_rideable.engine_parts = false
          end
        end
        
      elseif item:HasTag("jx_parts_music") then
        local own_any_other_music = false
        for i = inst.parts_start_slot, container:GetNumSlots() do
          if container:GetItemInSlot(i) ~= nil and container:GetItemInSlot(i):HasTag("jx_parts_music") then
            own_any_other_music = true
            break
          end
        end
        if not own_any_other_music then
          if jx_rideable then
            jx_rideable.music_parts = false
          end
        end
        
      elseif item:HasTag("jx_parts_wheel") then
        local own_any_other_wheel = false
        for i = inst.parts_start_slot, container:GetNumSlots() do
          if container:GetItemInSlot(i) ~= nil and container:GetItemInSlot(i):HasTag("jx_parts_wheel") then
            own_any_other_wheel = true
            break
          end
        end
        if not own_any_other_wheel then
          if jx_rideable then
            jx_rideable.wheel_parts = false
          end
        end
      
      elseif item:HasTag("jx_parts_camera_1") then
        local own_any_other_camera_1 = false
        for i = inst.parts_start_slot, container:GetNumSlots() do
          if container:GetItemInSlot(i) ~= nil and container:GetItemInSlot(i):HasTag("jx_parts_camera_1") then
            own_any_other_camera_1 = true
            break
          end
        end
        if not own_any_other_camera_1 then
          if jx_rideable then
            jx_rideable.camera_follow_mode = false
          end
        end
      
      elseif item:HasTag("jx_parts_camera_2") then
        local own_any_other_camera_2 = false
        for i = inst.parts_start_slot, container:GetNumSlots() do
          if container:GetItemInSlot(i) ~= nil and container:GetItemInSlot(i):HasTag("jx_parts_camera_2") then
            own_any_other_camera_2 = true
            break
          end
        end
        if not own_any_other_camera_2 then
          if jx_rideable then
            jx_rideable.camera_auto_mode = false
          end
        end
      end
    end
  end
end

local function ClearBuildOverrides(inst, animstate)
  if animstate == nil then return end
  local build = inst.AnimState:GetBuild()
  if animstate ~= inst.AnimState then
    animstate:ClearOverrideBuild(build)
  end
end

local function ApplyBuildOverrides(inst, animstate)
  if animstate == nil then return end
  local build = inst.AnimState:GetBuild()
  if animstate ~= inst.AnimState then
    animstate:AddOverrideBuild(build)
  else
    animstate:SetBuild(build)
  end
end

local function OnSave(inst, data)
  if inst.components.jx_rideable.colour ~= 0 then
    data.colour = inst.components.jx_rideable.colour
  end
end

local function OnLoad(inst, data)
  if data.colour then
    inst.components.jx_rideable:DoColour(data.colour, true)
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	  inst:SetDeploySmartRadius(3.5)
    MakeCharacterPhysics(inst, 500, 3)

    inst.MiniMapEntity:SetIcon("jx_car.tex")

    inst:AddTag("structure")
    inst:AddTag("jx_car")
    
    inst:AddTag("rideable")

    inst.AnimState:SetBank("jx_car")
    inst.AnimState:SetBuild("jx_car")
    inst.AnimState:PlayAnimation("closed")
    
    inst.Transform:SetEightFaced()

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_car")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    
    if TUNING.JX_TUNING.jx_car_disable ~= true then
      inst:AddComponent("rideable")
      inst.components.rideable.canride = true
    end
    
    inst:AddComponent("jx_rideable")
    inst.components.jx_rideable:SetMaxHealth(TUNING.JX_TUNING.jx_car_health)
    
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.GASOLINE
    inst.components.fueled:InitializeFuelLevel(480 * 5)
    inst.components.fueled:SetPercent(0)
    inst.components.fueled.accepting = true
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
        
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 8.0

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("savedrotation")
    inst.components.savedrotation.dodelayedpostpassapply = true

    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst:ListenForEvent("riderchanged", OnRiderChanged)
    
    inst.parts_start_slot = 31 --如果修改，容器的定义也要一起修改
    inst:ListenForEvent("itemget", OnGetItem)
    inst:ListenForEvent("itemlose", OnLoseItem)
    
    AddHauntableDropItemOrWork(inst)
    
    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides

    inst.jx_last_rotation = nil
    inst:DoTaskInTime(0,function() inst.jx_last_rotation = inst.Transform:GetRotation() end)
    
    inst:SetStateGraph("SGjx_car")
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("jx_car", fn, assets, prefabs),
    MakePlacer("jx_car_placer", "jx_car", "jx_car", "closed", nil, nil, nil, nil, 285, "eight")
