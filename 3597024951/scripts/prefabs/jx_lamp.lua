local ret = {}

local LAMP_LIGHT_COLOUR = Vector3(180 / 255, 195 / 255, 150 / 255)

local function onlighterlight(inst)
  if inst.turnon_sound then
    inst.SoundEmitter:PlaySound(inst.turnon_sound)
  end
  inst:RemoveTag("canlight")
  inst.AnimState:PlayAnimation("idle_on", true)
  if inst.Light then
    inst.Light:Enable(true)
  end
end

local function onextinguish(inst)
  if inst.turnoff_sound then
    inst.SoundEmitter:PlaySound(inst.turnoff_sound)
  end
  inst:AddTag("canlight")
  inst.AnimState:PlayAnimation("extinguish")
  inst.AnimState:PushAnimation("idle_off", false)
  if inst.Light then
    inst.Light:Enable(false)
  end
end

local function lamp_turnoff(inst)
    if inst.Light then
      inst.Light:Enable(false)
    end
    --inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_off", nil, .7)
    if inst.components.fueled then
      inst.components.fueled:StopConsuming()
    end
    if inst.components.machine then
      inst.components.machine.ison = false
    end
    if not inst:HasTag("burnt") then
      inst.AnimState:PlayAnimation("idle_off")
    end
end

local function lamp_fuelupdate(inst)
    local fuelpercent = inst.components.fueled and inst.components.fueled:GetPercent() or nil
    if fuelpercent and inst.Light then
        inst.Light:SetIntensity(Lerp(0.4, 0.6, fuelpercent))
        inst.Light:SetRadius(Lerp(2, 4, fuelpercent))
    end
end

local function lamp_turnon(inst)
    local fueled = inst.components.fueled
    if (fueled and fueled:IsEmpty()) or inst.components.inventoryitem:IsHeld() then return end
    
    if fueled then
      fueled:StartConsuming()
    end
    if inst.Light then
      inst.Light:Enable(true)
    end
    --inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_on", nil, .7)
    if inst.components.machine then
      inst.components.machine.ison = true
    end
    if not inst:HasTag("burnt") then
      inst.AnimState:PlayAnimation("idle_on")
    end
end

local function lamp_ondropped(inst)
  if not inst.lamp_canlight then
    lamp_turnoff(inst)
    lamp_turnon(inst)
  else
    if not inst:HasTag("canlight") then
      inst.AnimState:PlayAnimation("idle_on", true)
      if inst.Light then
        inst.Light:Enable(true)
      end
    else
      inst.AnimState:PlayAnimation("idle_off", false)
      if inst.Light then
        inst.Light:Enable(false)
      end
    end
  end
end

local function onburnt(inst)
  inst:AddTag("burnt")
  inst.AnimState:PlayAnimation("burnt", true)
  if inst.components.fueled then
    inst.components.fueled:SetPercent(0)
    inst.components.fueled.accepting = false
  end
  if inst.components.machine then
    inst.components.machine.enabled = false
  end
end

local function onputonfurniture(inst)
  lamp_ondropped(inst)
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
    if inst.lamp_canlight then
      if inst:HasTag("canlight") then
        data.canlight = true
      else
        data.canlight = false
      end
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
      if inst.components.burnable and inst.components.burnable.onburnt then
        inst.components.burnable.onburnt(inst)
      end
    end
    if data.canlight ~= nil then
      if data.canlight then
        if not inst:HasTag("canlight") then
          inst:AddTag("canlight")
        end
        inst.AnimState:PlayAnimation("idle_off")
        if inst.Light then
          inst.Light:Enable(false)
        end
      else
        if inst:HasTag("canlight") then
          inst:RemoveTag("canlight")
        end
        inst.AnimState:PlayAnimation("idle_on", true)
        if inst.Light then
          inst.Light:Enable(true)
        end
      end
    end
end

local function MakeLamp(data)
  local assets =
  {
    Asset("ANIM", "anim/"..data.name..".zip"),
  }
  
  local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddFollower()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.name)
    inst.AnimState:SetBuild(data.name)
    inst.AnimState:PlayAnimation("idle_off")

    inst:AddTag("furnituredecor")
    inst:AddTag(data.name)
    if data.canlight then
      inst:AddTag("canlight")
    end

    inst.Light:SetIntensity(0.4)
    inst.Light:SetColour(LAMP_LIGHT_COLOUR.x, LAMP_LIGHT_COLOUR.y, LAMP_LIGHT_COLOUR.z)
    inst.Light:SetFalloff(0.8)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)

    MakeInventoryFloatable(inst, "small", 0.065, 0.85)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    if data.fueled then
      local fueled = inst:AddComponent("fueled")
      fueled.fueltype = FUELTYPE.CAVE
      fueled:InitializeFuelLevel(TUNING.LANTERN_LIGHTTIME)
      fueled:SetDepletedFn(lamp_turnoff)
      fueled:SetUpdateFn(lamp_fuelupdate)
      fueled:SetTakeFuelFn(lamp_turnon)
      fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
      fueled.accepting = true
    end

    --
    local furnituredecor = inst:AddComponent("furnituredecor")
    furnituredecor.onputonfurniture = onputonfurniture

    --
    inst:AddComponent("inspectable")

    --
    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetOnDroppedFn(lamp_ondropped)
    inventoryitem:SetOnPutInInventoryFn(lamp_turnoff)

    --
    if data.machine then
      local machine = inst:AddComponent("machine")
      machine.turnonfn = lamp_turnon
      machine.turnofffn = lamp_turnoff
      machine.cooldowntime = 0
    end

    --
    MakeHauntable(inst)
    --
    if data.burnable then
      MakeSmallBurnable(inst)
      inst.components.burnable:SetOnBurntFn(onburnt)
      MakeSmallPropagator(inst)
    end
    
    if data.turnon_sound then
      inst.turnon_sound = data.turnon_sound
    end
    if data.turnoff_sound then
      inst.turnoff_sound = data.turnoff_sound
    end
    
    if data.canlight then
      inst:AddComponent("jx_lamp")--挂名组件
      inst.lamp_canlight = true--固定值，标识烛台之类
      inst:ListenForEvent("onlighterlight", onlighterlight)
      inst:ListenForEvent("jx_extinguish_lamp2", onextinguish)
    end
    
    inst.OnSave = onsave
    inst.OnLoad  = onload

    return inst
  end
  
  table.insert(ret, Prefab(data.name, fn, assets))
end

MakeLamp({ name = "jx_lamp", burnable = false, fueled = true, machine = true, })--床头灯
MakeLamp({ name = "jx_lamp_2", canlight = true, turnon_sound = "dontstarve/wilson/torch_swing", turnoff_sound = "dontstarve/common/fireOut", })--烛台

return unpack(ret)