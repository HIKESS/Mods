-------------------
local G = GLOBAL
--------------------
--关于钢琴音
--"pianofx/pianofx/"加字母和数字为对应琴音路径，包含
--"c3", "d3", "e3", "f3", "g3", "a3", "b3", 
--"c4", "d4", "e4", "f4", "g4", "a4", "b4",
--"c5", "d5", "e5", "f5", "g5", "a5", "b5",
--"c6", "d6", "e6", "f6", "g6"
-----
if G.TUNING.JX_TUNING.ENABLE_JX_PIANO == false then return end
------
local PIANO_CHAIR_DISTANCE = 3 -- 钢琴与椅子联结距离
------------------
--临时动作 --钢琴的开关将由玩家控制面板调节
--[[
local jx_turnon_piano = AddAction("JX_TURNON_PIANO", STRINGS.ACTIONS.JX_TURNON_PIANO, function(act)
    local tar = act.target
    if tar and tar.components.machine and not tar.components.machine:IsOn() then
        tar.components.machine:TurnOn(tar)
        return true
    end
end)
jx_turnon_piano.priority = 3
jx_turnon_piano.invalid_hold_action = true

AddComponentAction("SCENE", "jx_piano", function(inst, doer, actions, right)
    if right
      and not inst:HasTag("cooldown")
      and not inst:HasTag("fueldepleted")
      and not inst:HasTag("alwayson")
      and not inst:HasTag("emergency")
      and inst:HasTag("enabled")
    then
      local inventoryitem = inst.replica.inventoryitem
      local held = inventoryitem ~= nil and inventoryitem:IsHeld()
      if inst:HasTag("groundonlymachine") and (held or (inst.components.floater ~= nil and inst.components.floater:IsFloating())) then
        return
      elseif held then
        local equippable = inst.replica.equippable
        if equippable ~= nil and not equippable:IsEquipped() then
          return
        end
      end
      table.insert(actions, inst:HasTag("turnedon") and ACTIONS.TURNOFF or ACTIONS.JX_TURNON_PIANO)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(jx_turnon_piano, "dostandingaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(jx_turnon_piano, "dostandingaction"))
]]

--开关面板动作
AddAction("JX_TURNON_PIANO", STRINGS.ACTIONS.JX_TURNON_PIANO, function(act)
    if act.doer and act.doer.userid then
      G.SendModRPCToClient(G.GetClientModRPC("JX", "JX_Piano_Turnon"), act.doer.userid, true)
      act.doer.current_control_piano = act.target -- current_control_piano 只会在这个地方修改更新，指向的是控制面板对应的钢琴，不是自由演奏对应的钢琴
      return true
    end
end)
ACTIONS.JX_TURNON_PIANO.priority = -1

AddComponentAction("SCENE", "jx_piano", function(inst, doer, actions, right)
    if right and inst:HasTag("jx_piano") and not inst:HasTag("burnt")
      and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
    then
      table.insert(actions, ACTIONS.JX_TURNON_PIANO)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.JX_TURNON_PIANO, "dostandingaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.JX_TURNON_PIANO, "dostandingaction"))
-------------------
--HUD
AddClassPostConstruct("screens/playerhud", function(self)
    local JX_Piano_HUD = require "widgets/jx_piano_hud"
    self.jx_piano_hud = self:AddChild(JX_Piano_HUD())
end)

AddModRPCHandler("JX", "JX_Piano_FreePlay", function(inst)
    if inst then
      if inst._jx_can_play_piano then
        inst._jx_can_play_piano:set(true)
      end
      
      if inst.current_control_piano and inst.current_control_piano:IsValid()
        and inst.current_control_piano.components.machine and inst.current_control_piano.components.machine:IsOn()
      then
        inst.current_control_piano.components.machine:TurnOff()
      end
      
      if inst:HasTag("sitting_on_chair") then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = G.TheSim:FindEntities(x, y, z, PIANO_CHAIR_DISTANCE, { "jx_piano" }, { "burnt" })
        for _, v in pairs(ents) do
          if v.current_player == nil then
            v.current_player = inst
            inst.current_jx_piano = v
            if inst._jx_playing_piano and inst._jx_playing_piano:value() == false then
              inst:ListenForEvent("player_despawn", inst.jx_piano_player_despawn)
              inst:ListenForEvent("death", inst.jx_piano_ondeath)
              inst._jx_playing_piano:set(true)
            end
            break
          end
        end
      else
        if inst.components.talker then
          inst.components.talker:Say(STRINGS.JX_PIANO_FINDCHAIR) --"我们找把椅子坐下来弹吧。"
        end
      end
    end
end)

AddModRPCHandler("JX", "JX_Piano_StopMusic", function(inst)
    local piano = inst and inst.current_control_piano
    if piano ~= nil and piano:IsValid()
      and piano.components.machine and piano.components.machine:IsOn()
    then
      piano.components.machine:TurnOff()
    end
end)

AddModRPCHandler("JX", "JX_Piano_PlayMusic", function(inst, name)
    if name == nil then return end
    local piano = inst and inst.current_control_piano
    if piano ~= nil and piano:IsValid() then
      piano.current_song = "jx_piano/jx_piano/"..name
      if piano.components.machine then
        piano.components.machine:TurnOff()
        piano.components.machine:TurnOn()
      end
    end
end)

AddModRPCHandler("JX", "JX_Piano_Close_Tutorial", function(inst)
    if inst and inst._jx_can_play_piano then
      inst._jx_can_play_piano:set(false)
    end
end)

AddClientModRPCHandler("JX", "JX_Piano_Turnon", function(val)
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.jx_piano_hud
    if hud then
      if hud.panel_1 then
        if val then
          hud.panel_1:Show()
        else
          hud.panel_1:Hide()
        end
      end
      if hud.panel_2 then
        hud.panel_2:Hide()
      end
      if hud.keyboard then
        hud.keyboard:Hide()
      end
      if hud.tutorial_board then
        hud.tutorial_board:Hide()
      end
      G.SendModRPCToServer(G.GetModRPC("JX", "JX_Piano_Close_Tutorial"))
    end
end)
-----------------
--上下线、死亡处理
local function ondespawn(inst)
  if inst._jx_playing_piano and inst._jx_playing_piano:value() then
    inst._jx_playing_piano:set(false)
  end
end

local function ondeath(inst)
  if inst._jx_playing_piano and inst._jx_playing_piano:value() then
    inst._jx_playing_piano:set(false)
  end
end

AddPlayerPostInit(function(inst)
    if not G.TheWorld.ismastersim then return end
    --监听器放在开始弹琴时设置
    inst.jx_piano_player_despawn = ondespawn
    inst.jx_piano_ondeath = ondeath
end)
-----------------
--按键
local piano_key_mapping =
{
  [G.KEY_2] = "c3",
  [G.KEY_3] = "d3",
  [G.KEY_4] = "e3",
  [G.KEY_5] = "f3",
  [G.KEY_6] = "g3",
  [G.KEY_7] = "a3",
  [G.KEY_8] = "b3",
  [G.KEY_W] = "c4",
  [G.KEY_E] = "d4",
  [G.KEY_R] = "e4",
  [G.KEY_T] = "f4",
  [G.KEY_Y] = "g4",
  [G.KEY_U] = "a4",
  [G.KEY_I] = "b4",
  [G.KEY_S] = "c5",
  [G.KEY_D] = "d5",
  [G.KEY_F] = "e5",
  [G.KEY_G] = "f5",
  [G.KEY_H] = "g5",
  [G.KEY_J] = "a5",
  [G.KEY_K] = "b5",
  [G.KEY_X] = "c6",
  [G.KEY_C] = "d6",
  [G.KEY_V] = "e6",
  [G.KEY_B] = "f6",
  [G.KEY_N] = "g6",
  ---
  [G.KEY_A] = "stop",
  [G.KEY_Q] = "camera",
}

AddModRPCHandler("JX", "JX_Piano_Do", function(inst, sound)
    if sound and inst and inst.current_jx_piano and inst.current_jx_piano:IsValid() then
      inst.current_jx_piano.SoundEmitter:PlaySound("pianofx/pianofx/"..sound, nil, G.TUNING.JX_TUNING.jx_piano_volume2)
      if inst.current_jx_piano.AnimState:IsCurrentAnimation("idle") then
        local rnd = math.random(0, 3)
        local anim = "idle_"..rnd
        inst.current_jx_piano.AnimState:PlayAnimation(anim)
        inst.current_jx_piano.AnimState:PushAnimation("idle")
      end
    end
end)

AddModRPCHandler("JX", "JX_Piano_Stop", function(inst)
    if inst then
      if inst.components.playercontroller then
        inst.components.playercontroller:Enable(true)
      end
      if inst._jx_playing_piano and inst._jx_playing_piano:value() then
        inst._jx_playing_piano:set(false)
      end
    end
end)

AddClientModRPCHandler("JX", "JX_Piano_OnChange", function()
    local theinput = G.TheInput
    local player = G.ThePlayer
    if not player then return end
    player:DoTaskInTime(.2,function()
      if player and player._jx_playing_piano then
        if player._jx_playing_piano:value() then
          ---
          --**我不确定这样写是否会引发一些问题，这样的写法感觉不标准
          --但它确实有作用，可以屏蔽和恢复其他模组的按键监听
          player.jx_piano_oldsaved_onkeydown = G.deepcopy(theinput.onkeydown.events)
          theinput.onkeydown.events = {}
          player.jx_piano_oldsaved_onkeyup = G.deepcopy(theinput.onkeyup.events)
          theinput.onkeyup.events = {}
          player.jx_piano_oldsaved_onkey = G.deepcopy(theinput.onkey.events)
          theinput.onkey.events = {}
          
          for key, sound in pairs(piano_key_mapping) do
            theinput:AddKeyDownHandler(key, function()
              if sound == "stop" then
                G.SendModRPCToServer(G.GetModRPC("JX", "JX_Piano_Stop"))
              elseif sound == "camera" then
                local headingtarget = G.TheCamera and G.TheCamera:GetHeadingTarget()
                if headingtarget then
                  G.TheCamera:SetContinuousHeadingTarget(headingtarget - 45, -8)
                end
              else
                if player.JX_PIANO_PLAY_ALONE then
                  G.TheFocalPoint.SoundEmitter:PlaySound("pianofx/pianofx/"..sound, nil, G.TUNING.JX_TUNING.jx_piano_volume2)
                else
                  G.SendModRPCToServer(G.GetModRPC("JX", "JX_Piano_Do"), sound)
                end
              end
            end)
          end
          
          if player.HUD and player.HUD.jx_piano_hud and player.HUD.jx_piano_hud.keyboard then
            player.HUD.jx_piano_hud.keyboard:Show()
          end
          
        else
          if player.jx_piano_oldsaved_onkeydown ~= nil then
            theinput.onkeydown.events = player.jx_piano_oldsaved_onkeydown
            player.jx_piano_oldsaved_onkeydown = nil
          end
          if player.jx_piano_oldsaved_onkeyup ~= nil then
            theinput.onkeyup.events = player.jx_piano_oldsaved_onkeyup
            player.jx_piano_oldsaved_onkeyup = nil
          end
          if player.jx_piano_oldsaved_onkey ~= nil then
            theinput.onkey.events = player.jx_piano_oldsaved_onkey
            player.jx_piano_oldsaved_onkey = nil
          end
          if player.HUD and player.HUD.jx_piano_hud and player.HUD.jx_piano_hud.keyboard then
            player.HUD.jx_piano_hud.keyboard:Hide()
          end
        end
      end
    end)
end)

local function on_jx_playing_piano(inst)
  local enable = inst._jx_playing_piano and not inst._jx_playing_piano:value()
  if enable then
    if inst.components.playercontroller then
      inst.components.playercontroller:Enable(true)
    end
    if inst.components.inventory then
      inst.components.inventory:Show()
    end
    if inst.current_jx_piano then
      if inst.current_jx_piano:IsValid() then
        inst.current_jx_piano.current_player = nil
      end
      inst.current_jx_piano = nil
      inst:RemoveEventCallback("player_despawn", inst.jx_piano_player_despawn)
      inst:RemoveEventCallback("death", inst.jx_piano_ondeath)
    end
  else
    if inst.components.playercontroller then
      inst.components.playercontroller:Enable(false)
    end
    if inst.components.inventory then
      inst.components.inventory:Hide()
    end
  end
  G.SendModRPCToClient(G.GetClientModRPC("JX", "JX_Piano_OnChange"), inst.userid)
end

AddPlayerPostInit(function(inst)
    inst._jx_can_play_piano = G.net_bool(inst.GUID, "_jx_can_play_piano") --这个网络变量由玩家的钢琴面板调控，用于坐上椅子时识别是否进入自由演奏模式
    inst._jx_playing_piano = G.net_bool(inst.GUID, "_jx_playing_piano", "_jx_playing_piano") --这个网络变量用于标识玩家当前是否正在自由演奏钢琴
    if not G.TheWorld.ismastersim then return end
    inst._jx_can_play_piano:set(false)
    inst._jx_playing_piano:set(false)
    inst:ListenForEvent("_jx_playing_piano", on_jx_playing_piano)
end)
--------------------
--聊天屏蔽
AddClassPostConstruct("screens/chatinputscreen",function(self)
    self:Hide()
    self.inst:DoTaskInTime(0,function(self)
      local player = G.ThePlayer
      if player and player._jx_playing_piano and player._jx_playing_piano:value() then
        G.TheFrontEnd:PopScreen(self)
        return
      end
      self:Show()
    end)
end)
--------------------
--制作栏屏蔽
AddClassPostConstruct("screens/playerhud",function(self)
    local old_OpenCrafting = self.OpenCrafting
    function self:OpenCrafting(...)
      if G.ThePlayer and G.ThePlayer._jx_playing_piano and G.ThePlayer._jx_playing_piano:value() then
        return
      end
      old_OpenCrafting(self, ...)
    end
end)
--------------------
--触发
AddComponentPostInit("sittable",function(self)
    local old_SetOccupier = self.SetOccupier
    function self:SetOccupier(occupier, ...)
      if occupier and occupier._jx_can_play_piano and occupier._jx_can_play_piano:value() then
        local x, y, z = occupier.Transform:GetWorldPosition()
        local ents = G.TheSim:FindEntities(x, y, z, PIANO_CHAIR_DISTANCE, { "jx_piano" }, { "burnt" })
        for _, v in pairs(ents) do
          if v.current_player == nil then
            v.current_player = occupier
            occupier.current_jx_piano = v
            if occupier._jx_playing_piano and occupier._jx_playing_piano:value() == false then
              occupier:ListenForEvent("player_despawn", occupier.jx_piano_player_despawn)
              occupier:ListenForEvent("death", occupier.jx_piano_ondeath)
              occupier._jx_playing_piano:set(true)
            end
            break
          end
        end
      end
      old_SetOccupier(self, occupier, ...)
    end
    
    local old_onremove = self._onremoveoccupier
    self._onremoveoccupier = function()
      if self.occupier and self.occupier._jx_playing_piano and self.occupier._jx_playing_piano:value() then
        self.occupier._jx_playing_piano:set(false)
      end
      old_onremove()
    end
end)
--------------------
--钢琴附近的椅子自动对准
AddPrefabPostInitAny(function(inst)
    if not G.TheWorld.ismastersim then return end
    if inst.components.sittable ~= nil and inst.Transform ~= nil then
      inst:DoTaskInTime(0, function()
        local x, y, z = inst.Transform:GetWorldPosition()
        if x == nil or y == nil or z == nil then return end
        local ents = TheSim:FindEntities(x, y, z, PIANO_CHAIR_DISTANCE, { "jx_piano" }, { "burnt" })
        if ents ~= nil and #ents <= 0 then return end
        local pos = ents[1]:GetPosition()--只选最近的一个椅子
        local angle = pos ~= nil and inst:GetAngleToPoint(pos)
        if angle == nil then return end
        inst.Transform:SetRotation(angle)
      end)
    end
end)
--------------------