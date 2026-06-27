local prefabs =
{
    "collapse_small",
}

local function IsLightOn(inst)
    return inst.Light:IsEnabled()
end

local function onworkfinished(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

local function Update_Light(inst)
  if inst:HasTag("burnt") then
    return
  end
  if TheWorld.state.isday then
    inst:DoTaskInTime(3, function()
      if inst.components.machine and inst.components.machine.ison then
        inst.components.machine:TurnOff()
        inst.auto_light = true
      end
    end)
  else
    if inst.auto_light then
      if inst.components.machine and not inst.components.machine.ison then
        inst.components.machine:TurnOn()
      end
    end
  end
end

local function onworked(inst, worker, workleft)
    if workleft > 0 and not inst:HasTag("burnt") then
      inst.AnimState:PlayAnimation(IsLightOn(inst) and "hit_on" or "hit")
      inst.AnimState:PushAnimation(IsLightOn(inst) and "idle_on" or "idle", false)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("turn_on")
    inst.AnimState:PushAnimation("idle_on", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/lightning_rod_craft", nil, .4)
    inst.auto_light = true
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    else
      if inst.auto_light then
        data.auto_light = true
      end
    end
end

local function onload(inst, data)
    if data ~= nil then
      if data.burnt then
        inst.components.burnable.onburnt(inst)
      else
        if data.auto_light then
          inst:DoTaskInTime(0, function() inst.auto_light = true end)
        end
      end
    end
end

local function turnon(inst)
  if not inst.auto_light then
    inst.auto_light = true
  end
  if inst.Light then
    inst.Light:Enable(true)
  end
  inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroom_lamp/lantern_2_on", nil, .7)
  if inst.components.machine then
    inst.components.machine.ison = true
  end
  if not inst:HasTag("burnt") then
    inst.AnimState:PlayAnimation("turn_on")
    inst.AnimState:PushAnimation("idle_on", false)
  end
end

local function turnoff(inst)
  if inst.auto_light then
    inst.auto_light = false
  end
  if inst.Light then
    inst.Light:Enable(false)
  end
  inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroom_lamp/lantern_2_on", nil, .7)
  if inst.components.machine then
    inst.components.machine.ison = false
  end
  if not inst:HasTag("burnt") then
    inst.AnimState:PlayAnimation("turn_off")
    inst.AnimState:PushAnimation("idle", false)
  end
end

local function onburnt(inst)
  inst:AddTag("burnt")
  inst.AnimState:PlayAnimation("burnt", true)
  if inst.Light then
    inst.Light:Enable(false)
  end
  if inst.components.machine then
    inst.components.machine.enabled = false
  end
end

local function MakeMushroomLight(name, onlywhite, physics_rad)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

	    	inst:SetDeploySmartRadius(0.5)

        MakeObstaclePhysics(inst, physics_rad)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle_on")

        inst.Light:SetColour(.65, .65, .5)
        inst.Light:SetRadius(5.5)
        inst.Light:SetFalloff(.85)
        inst.Light:SetIntensity(.75)
        inst.Light:Enable(true)

        inst:AddTag("structure")
        inst:AddTag("lamp")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.onlywhite = onlywhite

        MakeSmallBurnable(inst, nil, nil, true)
        inst.components.burnable:SetOnBurntFn(onburnt)
        MakeSmallPropagator(inst)
        MakeHauntableWork(inst)

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onworkfinished)
        inst.components.workable:SetOnWorkCallback(onworked)
        
        inst:AddComponent("machine")
        inst.components.machine.turnonfn = turnon
        inst.components.machine.turnofffn = turnoff
        inst.components.machine.cooldowntime = 0
        inst.components.machine.ison = true

        inst:AddComponent("inspectable")

        inst:AddComponent("lootdropper")

        inst:ListenForEvent("onbuilt", onbuilt)
        
        inst:WatchWorldState("isnight", Update_Light)
        inst:WatchWorldState("isday", Update_Light)
        --inst:WatchWorldState("isdusk", Update_Light)
        Update_Light(inst)

        inst.OnSave = onsave
        inst.OnLoad = onload
        
        inst.auto_light = false --用于 Update_Light 函数的识别

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeMushroomLight("jx_mushroom_light", false, .25),
  MakePlacer("jx_mushroom_light_placer", "jx_mushroom_light", "jx_mushroom_light", "idle"),
  MakeMushroomLight("jx_mushroom_light_2", false, .25),
  MakePlacer("jx_mushroom_light_2_placer", "jx_mushroom_light_2", "jx_mushroom_light_2", "idle")