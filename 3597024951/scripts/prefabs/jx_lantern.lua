local rets = {}

local prefabs =
{
  "lanternlight",
}
  
local function DoTurnOffSound(inst, owner)
    inst._soundtask = nil
    (owner ~= nil and owner:IsValid() and owner.SoundEmitter or inst.SoundEmitter):PlaySound("dontstarve/wilson/lantern_off")
end

local function PlayTurnOffSound(inst)
    if inst._soundtask == nil and inst:GetTimeAlive() > 0 then
        inst._soundtask = inst:DoTaskInTime(0, DoTurnOffSound, inst.components.inventoryitem.owner)
    end
end

local function PlayTurnOnSound(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    elseif not POPULATING then
        inst._light.SoundEmitter:PlaySound("dontstarve/wilson/lantern_on")
    end
end

local function fuelupdate(inst)
    if inst._light ~= nil then
        local fuelpercent = inst.components.fueled:GetPercent()
        inst._light.Light:SetIntensity(Lerp(.4, .6, fuelpercent))
        inst._light.Light:SetRadius(Lerp(3, 5, fuelpercent))
        inst._light.Light:SetFalloff(.9)
    end
end

local function onremovelight(light)
    light._lantern._light = nil
end

local function stoptrackingowner(inst)
    if inst._owner ~= nil then
        inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
        inst._owner = nil
    end
end

local function starttrackingowner(inst, owner)
    if owner ~= inst._owner then
        stoptrackingowner(inst)
        if owner ~= nil and owner.components.inventory ~= nil then
            inst._owner = owner
            inst:ListenForEvent("equip", inst._onownerequip, owner)
        end
    end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        inst.components.fueled:StartConsuming()

        local owner = inst.components.inventoryitem.owner

        if inst._light == nil then
            inst._light = SpawnPrefab("lanternlight")
            inst._light._lantern = inst
            inst:ListenForEvent("onremove", onremovelight, inst._light)
            fuelupdate(inst)
            PlayTurnOnSound(inst)
        end
        inst._light.entity:SetParent((owner or inst).entity)

        inst.AnimState:PlayAnimation("idle_on", true)

        if owner ~= nil and inst.components.equippable:IsEquipped() then
            owner.AnimState:Show("LANTERN_OVERLAY")
        end

        inst.components.machine.ison = true
        inst:PushEvent("lantern_on")
    end
end

local function turnoff(inst)
    stoptrackingowner(inst)

    inst.components.fueled:StopConsuming()

    if inst._light ~= nil then
        inst._light:Remove()
        PlayTurnOffSound(inst)
    end

    inst.AnimState:PlayAnimation("idle_off")

    if inst.components.equippable:IsEquipped() then
        inst.components.inventoryitem.owner.AnimState:Hide("LANTERN_OVERLAY")
    end

    inst.components.machine.ison = false
    inst:PushEvent("lantern_off")
end

local function OnRemove(inst)
    if inst._light ~= nil then
        inst._light:Remove()
    end
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function onequip(inst, owner)
    local name = inst.prefab
    owner.AnimState:OverrideSymbol("swap_object", "swap_"..name, "swap_lantern")
    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_"..name, "lantern_overlay")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.fueled:IsEmpty() then
        owner.AnimState:Hide("LANTERN_OVERLAY")
    else
        owner.AnimState:Show("LANTERN_OVERLAY")
        turnon(inst)
        
        if inst.should_own_lanternfx then
          local jx_lantern_fx = SpawnPrefab("jx_lantern_playerfx")
          if jx_lantern_fx then
            jx_lantern_fx.entity:SetParent(owner.entity)
            jx_lantern_fx.Follower:FollowSymbol(owner.GUID, "swap_object", 100, 30, 0)
            jx_lantern_fx.fx_parent = owner
            owner._jx_lantern_fx = jx_lantern_fx
          end
        end
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:Hide("LANTERN_OVERLAY")

    if inst.components.machine.ison then
        starttrackingowner(inst, owner)
    end
    
    if owner._jx_lantern_fx and owner._jx_lantern_fx:IsValid() then
      owner._jx_lantern_fx:Remove()
      owner._jx_lantern_fx = nil
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.machine.ison then
        starttrackingowner(inst, owner)
    end

    turnoff(inst)
end

local function nofuel(inst)
    if inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner ~= nil then
        local data =
        {
            prefab = inst.prefab,
            equipslot = inst.components.equippable.equipslot,
        }
        turnoff(inst)
        inst.components.inventoryitem.owner:PushEvent("torchranout", data)
    else
        turnoff(inst)
    end
end

local function ontakefuel(inst)
    if inst.components.equippable:IsEquipped() then
        turnon(inst)
    end
end

local function onattack(inst, attacker)--, target)
  if attacker and attacker.components.health and not attacker.components.health:IsDead()
    and inst.components.rechargeable and inst.components.rechargeable:IsCharged()
  then
    inst.components.rechargeable:Discharge(TUNING.JX_TUNING.jx_lantern_3_cd)
    attacker.components.health:DoDelta(6.8)
  end
end

--------------------------------------------------------------------------

local function OnLightWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_LP", "loop")
    end
end

local function OnLightSleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

-------------------------------------------------------------------------

local function MakeLantern(name, lanternfx, restorehealth, maxfuel)
  local assets =
  {
    Asset("ANIM", "anim/"..name..".zip"),
    Asset("ANIM", "anim/swap_"..name..".zip"),
  }
  
  local _prefabs = {}
  for _, v in ipairs(prefabs) do
    table.insert(_prefabs, v)
  end
  if name == "jx_lantern" then
    table.insert(_prefabs, "jx_lantern_playerfx")
  end
  
  local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(name)
    inst.AnimState:SetBuild(name)
    inst.AnimState:PlayAnimation("idle_off")
    inst.AnimState:SetScale(.85, .85, .85)

    inst:AddTag("light")
    inst:AddTag("jx_lantern")
    if restorehealth then
      inst:AddTag("rechargeable")
    end

    MakeInventoryFloatable(inst, "med", 0.2, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.should_own_lanternfx = lanternfx

    inst:AddComponent("inspectable")

    local inventoryitem = inst:AddComponent("inventoryitem")
    inventoryitem:SetOnDroppedFn(ondropped)
    inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("equippable")

    local fueled = inst:AddComponent("fueled")

    local machine = inst:AddComponent("machine")
    machine.turnonfn = turnon
    machine.turnofffn = turnoff
    machine.cooldowntime = 0

    fueled.fueltype = FUELTYPE.CAVE
    fueled:InitializeFuelLevel(maxfuel)
    fueled:SetDepletedFn(nofuel)
    fueled:SetUpdateFn(fuelupdate)
    fueled:SetTakeFuelFn(ontakefuel)
    fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    fueled.accepting = true

    inst._light = nil

    MakeHauntableLaunch(inst)

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst.OnRemoveEntity = OnRemove

    inst._onownerequip = function(owner, data)
        if data.item ~= inst and
            (   data.eslot == EQUIPSLOTS.HANDS or
                (data.eslot == EQUIPSLOTS.BODY and data.item:HasTag("heavy"))
            ) then
            turnoff(inst)
        end
    end
    
    if restorehealth then
      inst:AddComponent("rechargeable")
      inst:AddComponent("weapon")
      inst.components.weapon:SetOnAttack(onattack)
    end

    return inst
  end
  
  table.insert(rets, Prefab(name, fn, assets, _prefabs))
end

--           name,          lanternfx, restorehealth, maxfuel
MakeLantern("jx_lantern",   true,       false,        TUNING.JX_TUNING.jx_lantern_fuel * 480  )
MakeLantern("jx_lantern_2", false,      false,        TUNING.JX_TUNING.jx_lantern_2_fuel * 480)
MakeLantern("jx_lantern_3", false,      true,         TUNING.JX_TUNING.jx_lantern_3_fuel * 480)

return unpack(rets)