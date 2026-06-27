local assets =
{
    Asset("ANIM", "anim/jx_piano.zip"),
    Asset("ANIM", "anim/jx_piano_burnt.zip"),
}

local prefabs =
{
  "collapse_big",
}

local list =
{
  "c3", "d3", "e3", "f3", "g3", "a3", "b3",
  "c4", "d4", "e4", "f4", "g4", "a4", "b4",
  "c5", "d5", "e5", "f5", "g5", "a5", "b5",
  "c6", "d6", "e6", "f6", "g6"
}
local list_length = #list

local song = "jx_piano/jx_piano/RANDOM" --默认随机

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
      inst.AnimState:PlayAnimation("hit")
      inst.AnimState:PushAnimation("idle")
      
      local sound = "pianofx/pianofx/"..list[math.random(1, list_length)]
      inst.SoundEmitter:PlaySound(sound, nil, .4)
      
      if inst.components.machine and inst.components.machine:IsOn() then
        inst.components.machine:TurnOff()
      end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
    
    local sound = "pianofx/pianofx/"..list[math.random(1, list_length)]
    inst:DoTaskInTime(.5, function() inst.SoundEmitter:PlaySound(sound, nil, .6) end)
end

local function onburnt(inst)
  DefaultBurntStructureFn(inst)
  inst.AnimState:SetBuild("jx_piano_burnt")
  inst.AnimState:PlayAnimation("idle")
  inst.AnimState:Hide("fx_icon")
  
  local player = inst.current_player
  if player and player:IsValid() and player._jx_playing_piano ~= nil then
    player._jx_playing_piano:set(false)
    inst.current_player = nil
  end
end

local function onanimover(inst)
  if not inst:HasTag("burnt") then
    local rnd = math.random(0, 3)
    local anim = "idle_"..rnd
    inst.AnimState:PlayAnimation(anim)
  else
    inst:RemoveEventCallback("animover", inst.onanimover)
    inst.AnimState:PlayAnimation("idle")
  end
end

local function turnon(inst)
  inst.components.machine.ison = true
  inst.SoundEmitter:PlaySound(inst.current_song, "song", TUNING.JX_TUNING.jx_piano_volume1)
  local rnd = math.random(0, 3)
  local anim = "idle_"..rnd
  --inst.AnimState:PlayAnimation(anim)
  inst:DoTaskInTime(2, function() inst.AnimState:PlayAnimation(anim) end)
  inst:ListenForEvent("animover", inst.onanimover)
end

local function turnoff(inst)
  inst.components.machine.ison = false
  inst.SoundEmitter:KillSound("song")
  inst:RemoveEventCallback("animover", inst.onanimover)
  inst.AnimState:PlayAnimation("idle")
end

local function onfar(inst, player)
  if player and player.userid then
    SendModRPCToClient(GetClientModRPC("JX", "JX_Piano_Turnon"), player.userid, false)
  end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
      data.burnt = true
    else
      data.current_song = inst.current_song
    end
end

local function onremove(inst)
  local player = inst.current_player
  if player and player:IsValid() and player._jx_playing_piano ~= nil then
    player._jx_playing_piano:set(false)
    inst.current_player = nil
  end
end

local function onload(inst, data)
    if data then
      if data.burnt then
        inst.components.burnable.onburnt(inst)
      else
        if data.current_song then
          inst.current_song = data.current_song
        end
        inst:DoTaskInTime(0, function()
          if inst.components.machine and inst.components.machine:IsOn() then
            inst.components.machine:TurnOff()
            inst.components.machine:TurnOn() --刷新使用上次保存的歌
          end
        end)
      end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	  inst:SetDeploySmartRadius(2)
    MakeObstaclePhysics(inst, 1)
    
    inst.Transform:SetFourFaced()
    
    inst:AddTag("structure")
    inst:AddTag("jx_piano")
    inst:AddTag("rotatableobject")

    inst.AnimState:SetBank("jx_piano")
    inst.AnimState:SetBuild("jx_piano")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(10)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0
    inst.components.machine.ison = false
    inst.components.machine.enabled = false
    
    inst:AddComponent("jx_piano")
    
    inst:AddComponent("savedrotation")
    inst.components.savedrotation.dodelayedpostpassapply = true
    
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2, 6)
    inst.components.playerprox:SetOnPlayerFar(onfar)
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    
    MakeLargeBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeLargePropagator(inst)
    
    --inst.current_player = nil
    inst.current_song = song
    
    inst:ListenForEvent("onbuilt", onbuilt)
    
    inst.onanimover = onanimover
    
    inst:ListenForEvent("onremove", onremove)
  
    inst.OnSave = onsave
    inst.OnLoad = onload
    
    return inst
end

return Prefab("jx_piano", fn, assets, prefabs),
    MakePlacer("jx_piano_placer", "jx_piano", "jx_piano", "placer", nil, nil, nil, nil, 15, "four")