require "prefabutil"

local prefabs =
{
    "collapse_big",
}

local assets =
{
    Asset("ANIM", "anim/jx_furnace.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
    Asset("MINIMAP_IMAGE", "jx_furnace"),
}

local function onworkfinished(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onworked(inst)
    if inst.components.machine.ison then
      inst.AnimState:PlayAnimation("hit_on")
    else
      inst.AnimState:PlayAnimation("hit_off")
    end

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_on")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop", .7)
end

local function onsave(inst, data)
    if inst.components.machine.ison then
      data.turnon = true
    end
end

local function onload(inst, data)
    if data then
      if data.turnon then
        inst.components.machine:TurnOn()
      else
        inst.components.machine:TurnOff()
      end
    end
end

local function _CanBeOpened(inst)
    inst.components.container.canbeopened = true
end

local function OnIncinerateItems(inst)
    inst.AnimState:PlayAnimation("incinerate")
    inst.AnimState:PushAnimation("incinerate")
    inst.AnimState:PushAnimation("idle_on", false)

    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")

    inst.components.container:Close()
    inst.components.container.canbeopened = false

    inst:DoTaskInTime(FRAMES * 10, _CanBeOpened)
end

local function ShouldIncinerateItem(inst, item)
    local incinerate = true

    --[[if item.prefab == "winter_food4" then
        incinerate = false]]
    if item:HasTag("irreplaceable") then
        incinerate = false
    elseif item.components.container ~= nil and not item.components.container:IsEmpty() then
        incinerate = false
    end

    return incinerate
end

local function turnon(inst)
  if inst.Light then
    inst.Light:Enable(true)
  end
  inst.AnimState:PlayAnimation("idle_on")
  
  inst.SoundEmitter:PlaySound("jx_sound_1/jx_sound_1/furnace_on")
  inst.SoundEmitter:KillSound("loop")
  inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop", .7)
  if not inst:HasTag("cooker") then
    inst:AddTag("cooker")
  end
  if not inst:HasTag("snowstorm_protection_high") then
    inst:AddTag("snowstorm_protection_high")
  end
  
  inst.components.machine.ison = true
  if inst.components.heater then
    inst.components.heater.heat = 115
  end
  if inst.components.container then
    inst.components.container.canbeopened = true
  end
end

local function turnoff(inst)
  if inst.Light then
    inst.Light:Enable(false)
  end
  inst.AnimState:PlayAnimation("idle_off")
  inst.SoundEmitter:PlaySound("jx_sound_1/jx_sound_1/furnace_off")
  inst.SoundEmitter:KillSound("loop")
  if inst:HasTag("cooker") then
    inst:RemoveTag("cooker")
  end
  if inst:HasTag("snowstorm_protection_high") then
    inst:RemoveTag("snowstorm_protection_high")
  end
  
  inst.components.machine.ison = false
  if inst.components.heater then
    inst.components.heater.heat = 0
  end
  if inst.components.container then
    inst.components.container.canbeopened = false
  end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

	  inst:SetDeploySmartRadius(1.25)
    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("jx_furnace.tex")

    inst.Light:Enable(true)
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(.33)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    inst.AnimState:SetBank("jx_furnace")
    inst.AnimState:SetBuild("jx_furnace")
    inst.AnimState:PlayAnimation("idle_on")

    inst:AddTag("structure")
    inst:AddTag("HASHEATER")
    inst:AddTag("snowpileblocker") --不妥协

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onworkfinished)
    inst.components.workable:SetOnWorkCallback(onworked)

    -----------------------
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("jx_furnace")

    -----------------------
    inst:AddComponent("incinerator")
    inst.components.incinerator:SetOnIncinerateFn(OnIncinerateItems)
    inst.components.incinerator:SetShouldIncinerateItemFn(ShouldIncinerateItem)

    -----------------------
    inst:AddComponent("cooker")
    inst:AddComponent("lootdropper")

    -----------------------
    inst:AddComponent("inspectable")
    -----------------------
    inst:AddComponent("heater")
    inst.components.heater.heat = 115
    --------------------------
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0
    inst.components.machine.ison = true

    -----------------------
    --MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    inst:DoPeriodicTask(5, function(inst)
      local x, y, z = inst.Transform:GetWorldPosition()
      local snow = TheSim:FindEntities(x, y, z, 8, { "snowpile" })
      for _, v in ipairs(snow) do
        if v.components.workable ~= nil then
          v.components.workable:Destroy(inst)
        end
      end
    end, 0)
    
    return inst
end

return Prefab("jx_furnace", fn, assets, prefabs),
       MakePlacer("jx_furnace_placer", "jx_furnace", "jx_furnace", "idle_off")