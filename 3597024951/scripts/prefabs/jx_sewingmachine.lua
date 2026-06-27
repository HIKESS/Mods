local assets =
{
    Asset("ANIM", "anim/jx_sewingmachine.zip"),
    Asset("MINIMAP_IMAGE", "jx_sewingmachine"),
}

local prefabs =
{
    "collapse_small",
}

local sound = 
{
  close = "yotb_2021/common/sewing_machine/close",
  open = "yotb_2021/common/sewing_machine/open",
  place = "yotb_2021/common/sewing_machine/place",
  sewing = "yotb_2021/common/sewing_machine/LP",
  stop = "yotb_2021/common/sewing_machine/stop",
  done = "yotb_2021/common/sewing_machine/done",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
      inst.SoundEmitter:PlaySound(sound.close)
      inst.AnimState:PlayAnimation("hit")
      inst.AnimState:PushAnimation("idle", false)
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        if not inst.components.yotb_sewer:IsSewing() then
            inst.AnimState:PlayAnimation("close")
            inst.AnimState:PushAnimation("idle_closed", false)

            inst.SoundEmitter:KillSound("snd")
        end

        inst.SoundEmitter:PlaySound(sound.close)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound(sound.place)
end

local function OnStartSewing(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("active_pre")
        inst.AnimState:PushAnimation("active_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound(sound.sewing, "snd")
    end
end

local function OnDoneSewing(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("active_post")
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound(sound.stop)
        inst.SoundEmitter:PlaySound(sound.done)
    end
end

local function onfinished(inst)
  inst:AddTag("NOCLICK")
  local life = 48
  local color = 1
  inst.colortask = inst:DoPeriodicTask(FRAMES,function()
    if life >= 1 then
      inst.AnimState:SetMultColour(1, 1, 1, color)
      life = life - 1
      color = color - 0.02
    else
      if inst.colortask then
        inst.colortask:Cancel()
        inst.colortask = nil
      end
      inst:Remove()
    end
  end)
end

local function onburnt(inst)
  if inst.components.inventory then
    inst.components.inventory:DropEverything()
  end
  DefaultBurntStructureFn(inst)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
      inst.components.burnable.onburnt(inst)
    else
      local item = inst.components.inventory:GetItemInSlot(1)
      if item then
        inst.components.trader.onaccept(inst, nil, item)
      end
    end
end

local function ShouldAcceptItem(inst, item, giver)
  if item == nil then
    return
  elseif item.prefab == "silk" then
    if TUNING.JX_TUNING.jx_sewingmachine_silk == false then
      return false
    end
    if inst.components.finiteuses and inst.components.finiteuses:GetPercent() >= 1 then
      if giver and giver.components.talker then
        giver.components.talker:Say(STRINGS.CHARACTERS.WILLOW.ACTIONFAIL.STORE.GENERIC)--"已经满了。"
      end
      return false
    else
      return true
    end
  elseif not item:HasTag("needssewing") then
    if giver and giver.components.talker then
      giver.components.talker:Say(STRINGS.NEED_NOT_SEWING)--"不需要缝补。"
    end
    return false
  elseif inst.components.inventory:IsFull() then
    if giver and giver.components.talker then
      giver.components.talker:Say(STRINGS.CHARACTERS.WURT.ACTIONFAIL.CHANGEIN.INUSE)--"得等等……"
    end
    return false
  end
  return not inst:HasTag("burnt")
end

local function OnGetItemFromPlayer(inst, giver, item)
  if item.prefab == "silk" then
    if inst.components.finiteuses then
      inst.components.finiteuses:Repair(1)
    end
    inst.AnimState:PlayAnimation("active_post")
    inst.AnimState:PushAnimation("active_post", false)
    inst.AnimState:PushAnimation("idle", false)
    item:Remove()
  else
    OnStartSewing(inst)
    inst:DoTaskInTime(5, function()
      if item.components.fueled then
        item.components.fueled:SetPercent(1)
      end
      if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
      end
      if inst.components.inventory then
        inst.components.inventory:DropEverything()
      end
      OnDoneSewing(inst)
    end)
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

    inst.MiniMapEntity:SetIcon("jx_sewingmachine.tex")

    inst:AddTag("structure")
    inst:AddTag("jx_sewingmachine")
    inst:AddTag("trader")
    inst:AddTag("alltrader")

    inst.AnimState:SetBank("jx_sewingmachine")
    inst.AnimState:SetBuild("jx_sewingmachine")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.JX_TUNING.jx_sewingmachine_finiteuses)
    inst.components.finiteuses:SetUses(TUNING.JX_TUNING.jx_sewingmachine_finiteuses)
    inst.components.finiteuses:SetOnFinished(onfinished)
    
    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1
    
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader:SetOnAccept(OnGetItemFromPlayer)
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("onbuilt", onbuilt)

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeSmallPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("jx_sewingmachine", fn, assets, prefabs),
    MakePlacer("jx_sewingmachine_placer", "jx_sewingmachine", "jx_sewingmachine", "placer")
