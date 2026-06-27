local G = GLOBAL
---------------------------------------------------------------------------------------------------------
if G.TUNING.JX_TUNING.jx_car_disable == true then return end
---------------------------
--燃油
G.FUELTYPE.GASOLINE = "GASOLINE"

----------------------------------------------------------------------------------------------------
--基础动作

--添加燃料
local jx_car_addfuel = AddAction("JX_CAR_ADDFUEL", G.STRINGS.ACTIONS.JX_ADDFUEL, function(act)
    if act.doer.components.inventory and act.invobject then
      local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
      if fuel then
        if act.target.components.fueled and act.target.components.fueled:TakeFuelItem(fuel, act.doer) then
          return true
        end
        if act.invobject ~= fuel and
			  	act.invobject == act.doer.components.inventory:GetActiveItem() and
			  	act.invobject.components.stackable and
			  	not act.invobject.components.stackable:IsFull()
		  	then
          fuel = act.invobject.components.stackable:Put(fuel)
        end
        if fuel then
				  act.doer.components.inventory:GiveItem(fuel)
        end
      end
    elseif act.doer.components.fueler then
      if act.target.components.fueled and act.target.components.fueled:TakeFuelItem(nil, act.doer) then
        return true
      end
    end
    return false
end)
jx_car_addfuel.priority = 1

AddComponentAction("USEITEM", "fuel", function(inst, doer, target, actions, right)
    if target:HasTag("jx_car") and inst:HasTag("jx_gasoline") then
      table.insert(actions, jx_car_addfuel)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_car_addfuel, "dostandingaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_car_addfuel, "dostandingaction"))
---
--驾驶
local jx_drive = AddAction("JX_DRIVE", G.STRINGS.ACTIONS.JX_DRIVE, function(act)
  if act.target.components.rideable == nil 
    or not act.target.components.rideable.canride
    or act.target.components.rideable:IsBeingRidden()
  then
    return false
  elseif act.doer.components.inventory and not act.doer.components.inventory:HasItemWithTag("jx_car_key", 1) then
    act.doer:DoTaskInTime(0, function()
      if act.doer.components.talker then
        act.doer.components.talker:Say(G.STRINGS.NO_CAR_KEY)
      end
    end)
    return false
  end
  act.doer.components.rider:Mount(act.target)
  return true
end)
jx_drive.priority = 2
jx_drive.rmb = true
jx_drive.encumbered_valid = true

AddComponentAction("SCENE", "jx_rideable", function(inst, doer, actions, right)
    if right and inst:HasTag("rideable") then
      local rider = doer.replica.rider
      if rider ~= nil and not rider:IsRiding() then
        table.insert(actions, jx_drive)
      end
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_drive, "doshortaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_drive, "doshortaction"))
---
--喷漆罐
local jx_car_colour = AddAction("JX_CAR_COLOUR", G.STRINGS.ACTIONS.JX_CAR_COLOUR, function(act)
    if act.target and act.target.components.jx_rideable then
      if act.target.components.jx_rideable.colour ~= 0 then
        if act.doer then
          act.doer:DoTaskInTime(0, function()
            if act.doer.components.talker then
              act.doer.components.talker:Say(G.STRINGS.NEED_NOT_COLOUR)
            end
          end)
        end
        return false
      else
        if act.invobject and act.invobject.colour_num then
          act.target.components.jx_rideable:DoColour(act.invobject.colour_num, false)
          if act.invobject.components.finiteuses then
            act.invobject.components.finiteuses:Use(1)
          end
        end
        return true
      end
    end
    return false
end)
jx_car_colour.priority = 2

AddComponentAction("USEITEM", "jx_parts", function(inst, doer, target, actions, right)
    if target:HasTag("jx_car") and inst:HasTag("jx_parts_colour") then
      table.insert(actions, jx_car_colour)
    end
end)
AddComponentAction("EQUIPPED", "jx_parts", function(inst, doer, target, actions, right)
    if target:HasTag("jx_car") and inst:HasTag("jx_parts_colour") then
      table.insert(actions, jx_car_colour)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_car_colour, "jx_spray"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_car_colour, "jx_spray"))
---
--修理
local jx_car_repair = AddAction("JX_CAR_REPAIR", G.STRINGS.ACTIONS.JX_CAR_REPAIR, function(act)
    if act.invobject and act.doer and act.target and act.target.components.jx_rideable then
      if act.target.components.jx_rideable:GetPercent() >= 1 then
        act.doer:DoTaskInTime(0, function()
          if act.doer.components.talker then
            act.doer.components.talker:Say(G.STRINGS.NEED_NOT_REPAIR)
          end
        end)
        return false
      elseif act.invobject.prefab then
        local val = (act.invobject.prefab == "gears" and G.TUNING.JX_TUNING.jx_gears_repair) or
          (act.invobject.prefab == "wagpunkbits_kit" and G.TUNING.JX_TUNING.jx_wagpunkbitskit_repair) or 0
        act.target.components.jx_rideable:DoDelta(val)
        if act.invobject.components.stackable then
          act.invobject.components.stackable:Get():Remove()
        else
          act.invobject:Remove()
        end
        act.doer.SoundEmitter:PlaySound("qol1/collector_robot/repair", nil, .7)
        return true
      end
    end
    return false
end)
jx_car_repair.priority = 2

AddComponentAction("USEITEM", "jx_car_repair", function(inst, doer, target, actions, right)
    if target:HasTag("jx_car") and (inst.prefab == "gears" or inst.prefab == "wagpunkbits_kit") then
      table.insert(actions, jx_car_repair)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_car_repair, "dolongaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_car_repair, "dolongaction"))

for _, v in ipairs({"gears", "wagpunkbits_kit"}) do
  AddPrefabPostInit(v, function(inst)
      if not G.TheWorld.ismastersim then return end
      inst:AddComponent("jx_car_repair")
  end)
end
---
--动作过滤器
G.ACTIONS.DISMOUNT.jx_car_valid = true

local function ActionFilter_Driver(inst, action)
  return action.jx_car_valid == true
end

local function ActionFilter_Passenger(inst, action)
  return action.mount_valid == true
end

AddClientModRPCHandler("JX", "ActionFilter_Car", function(push, isdriver)
    local actpicker = G.ThePlayer and G.ThePlayer.components.playeractionpicker
    if actpicker == nil then return end
    
    local fn = isdriver and ActionFilter_Driver or ActionFilter_Passenger
    
    if push == true then
      actpicker:PushActionFilter(fn, 21)
    else
      actpicker:PopActionFilter(fn)
    end
end)

---------------------------------------------------------------------------------------------------------
local function onmount1(inst, data)
  if data and data.target and data.target:HasTag("jx_car") and inst.components.jx_driver then
    inst.components.jx_driver:StartDrive(data)
  end
end

local function ondismount1(inst, data)
  if data and data.target and data.target:HasTag("jx_car") and inst.components.jx_driver then
    inst.components.jx_driver:StopDrive(data)
  end
end

AddPlayerPostInit(function(inst)
    inst._jx_car_isdriving = G.net_bool(inst.GUID, "_jx_car_isdriving")
    if not G.TheWorld.ismastersim then return end
    inst._jx_car_isdriving:set(false)
    inst:AddComponent("jx_driver")
    inst:ListenForEvent("mounted", onmount1)
    inst:ListenForEvent("dismounted", ondismount1)
end)

---------------------------------------------------------------------------------------------------------
--相机
AddClientModRPCHandler("JX", "CameraSetOffset", function(x, y, z)
    if G.TheCamera then
      if x and y and z then
        G.TheCamera:SetOffset(Vector3(x, y, z))
      else
        G.TheCamera:SetDefaultOffset()
      end
    end
end)

AddClientModRPCHandler("JX", "CameraSetHeadingTarget", function(angle)
    if G.TheCamera and G.ThePlayer then
      if angle then
        G.TheCamera:SetHeadingTarget(angle)
      else
        G.TheCamera:SetHeadingTarget((180 - G.ThePlayer.Transform:GetRotation()) % 360)
      end
    end
end)

AddClientModRPCHandler("JX", "CameraClientSide", function(enable)
    local camera = G.ThePlayer and G.ThePlayer.components.jx_driver_camera
    if camera then
      if enable == nil or enable == false then
        camera:Disable()
      else
        camera:Enable()
      end
    end
end)

--[[ --不会再使用这个RPC
AddClientModRPCHandler("JX", "CameraSetContinuousHeadingTarget", function()
    if G.TheCamera == nil or G.TheCamera.headingdelta ~= nil or math.abs(G.DiffAngle(G.TheCamera.heading, G.TheCamera.headingtarget)) > .5 then
      return
    end
    if G.ThePlayer then
      local target_rot = (180 - G.ThePlayer.Transform:GetRotation()) % 360
      local current_rot = G.TheCamera.heading % 360
      local diffrot = G.DiffAngle(current_rot, target_rot)
      local delta
      if diffrot > 0 then
        local diff = (target_rot - current_rot) % 360
        delta = diff > 180 and -1 or 1
        if diffrot < 5 then
          delta = delta * math.sqrt(diffrot / 5)
        end
      end
      if delta then
        G.TheCamera:SetContinuousHeadingTarget(target_rot, delta)
      end
    end
end)
]]

AddPlayerPostInit(function(inst)
    if not G.TheWorld.ismastersim then
      inst:AddComponent("jx_driver_camera")
    end
end)

------------------------------------------------------------------------------------------------
--延迟补偿
AddClientModRPCHandler("JX", "MovementPrediction", function(val)
    if G.ThePlayer == nil then 
      return 
    end
    
    local playercontroller = G.ThePlayer.components.playercontroller
    if playercontroller then
      if playercontroller:CanLocomote() then
        playercontroller.locomotor:Stop()
      else
        playercontroller:RemoteStopWalking()
      end
    end
    
    if val then
      G.ThePlayer:EnableMovementPrediction(true)
      G.Profile:SetMovementPredictionEnabled(true)
    else
      G.ThePlayer:EnableMovementPrediction(false)
      G.Profile:SetMovementPredictionEnabled(false)
    end
end)

---------------------------------------------------------------------------------------------------------------------------------
--控制输入

--运动
local drivingscreens = { HUD = true, }

local OnUpdate_old = G.TheInput.OnUpdate
G.TheInput.OnUpdate = function(self, ...)
	OnUpdate_old(self, ...)

	local player, sim, fend = G.ThePlayer, G.TheSim, G.TheFrontEnd

	if not (fend and fend:GetActiveScreen()
		and drivingscreens[fend:GetActiveScreen().name] and sim
		and player and player.replica 
    and player.replica.rider 
    and player.replica.rider:GetMount() ~= nil 
    and player.replica.rider:GetMount():HasTag("jx_car"))
	then
		return
	end
  
  --2026/5/3
  --对运动方式改写，不能频繁使用RPC，改用按键监听
	--[[local LEFT, RIGHT, UP, DOWN =
		G.CONTROL_MOVE_LEFT, G.CONTROL_MOVE_RIGHT,
		G.CONTROL_MOVE_UP, G.CONTROL_MOVE_DOWN

	local l, r, u, d =
		sim:GetAnalogControl(LEFT), sim:GetAnalogControl(RIGHT),
		sim:GetAnalogControl(UP), sim:GetAnalogControl(DOWN)

	if l + r + u + d ~= 0 then
		G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), l, r, u, d)
	end]]
end

local oldGetAnalogControlValue = G.TheInput.GetAnalogControlValue
G.TheInput.GetAnalogControlValue = function(self, control, ...)
	return G.ThePlayer and G.ThePlayer.replica
    and G.ThePlayer.replica.rider
    and G.ThePlayer.replica.rider:GetMount() ~= nil
    and G.ThePlayer.replica.rider:GetMount():HasTag("jx_car") and 0
		or oldGetAnalogControlValue(self, control, ...)
end

AddModRPCHandler("JX", "Drive", function(inst, key, num)
    if inst.components.jx_driver then
      inst.components.jx_driver[key] = num
    end
end)

AddClientModRPCHandler("JX", "JX_Car_AddKeyHandle", function()--只对开过车的玩家添加按键监听
    local theinput = G.TheInput
    local player = G.ThePlayer
    if not theinput or not player then
      return
    end
    if player._jx_car_keydown_exsist then
      return
    end
    player._jx_car_keydown_exsist = true
    
    -- KEY_W
    theinput:AddKeyDownHandler(G.KEY_W, function()
      if not player._jx_car_keydown_up then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_up", 1)
        player._jx_car_keydown_up = true
      end
    end)
    theinput:AddKeyUpHandler(G.KEY_W, function()
      if player._jx_car_keydown_up then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_up", 0)
        player._jx_car_keydown_up = false
      end
    end)
    
    -- KEY_A
    theinput:AddKeyDownHandler(G.KEY_A, function()
      if not player._jx_car_keydown_left then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_left", 1)
        player._jx_car_keydown_left = true
      end
    end)
    theinput:AddKeyUpHandler(G.KEY_A, function()
      if player._jx_car_keydown_left then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_left", 0)
        player._jx_car_keydown_left = false
      end
    end)
    
    -- KEY_S
    theinput:AddKeyDownHandler(G.KEY_S, function()
      if not player._jx_car_keydown_down then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_down", 1)
        player._jx_car_keydown_down = true
      end
    end)
    theinput:AddKeyUpHandler(G.KEY_S, function()
      if player._jx_car_keydown_down then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_down", 0)
        player._jx_car_keydown_down = false
      end
    end)
    
    -- KEY_D
    theinput:AddKeyDownHandler(G.KEY_D, function()
      if not player._jx_car_keydown_right then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_right", 1)
        player._jx_car_keydown_right = true
      end
    end)
    theinput:AddKeyUpHandler(G.KEY_D, function()
      if player._jx_car_keydown_right then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_right", 0)
        player._jx_car_keydown_right = false
      end
    end)
    
    -- KEY_SPACE
    theinput:AddKeyDownHandler(G.KEY_SPACE, function()
      if not player._jx_car_keydown_space then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_space", 1)
        player._jx_car_keydown_space = true
      end
    end)
    theinput:AddKeyUpHandler(G.KEY_SPACE, function()
      if player._jx_car_keydown_space then
        G.SendModRPCToServer(G.GetModRPC("JX", "Drive"), "keydown_space", 0)
        player._jx_car_keydown_space = false
      end
    end)
end)
---
--配件适配
AddClientModRPCHandler("JX", "playercontroller_wheel_parts", function(val)
    if G.ThePlayer and G.ThePlayer.components.playercontroller then
      G.ThePlayer.components.playercontroller.jx_car_wheel_parts = val
    end
end)

AddComponentPostInit("locomotor",function(self)
    local old_WantsToMoveForward = self.WantsToMoveForward
    function self:WantsToMoveForward()
      if self.inst 
        and self.inst.components.jx_driver 
        and self.inst.components.jx_driver:GetCar() ~= nil
        and self.inst.components.jx_driver.mouse_move_disable
        or self.jx_driver_seat_num ~= nil
      then
        return false
      end
      return old_WantsToMoveForward(self)
    end
end)
---
--按键屏蔽
AddComponentPostInit("playercontroller",function(self)
    self.jx_car_wheel_parts = false
    
    local oldGetAttackTarget = self.GetAttackTarget
    function self:GetAttackTarget(...)
      local rider = self.inst.replica.rider
      if rider and rider:GetMount() ~= nil and rider:GetMount():HasTag("jx_car") then
        return
      end
      return oldGetAttackTarget(self, ...)
    end
    
    local old_OnLeftClick = self.OnLeftClick
    function self:OnLeftClick(down, ...)
      local is_aoe_targeting = self.IsAOETargeting and self:IsAOETargeting() or false
      
      if down and (self.placer_recipe == nil or self.placer == nil) and not is_aoe_targeting then
        local act = self:GetLeftMouseAction() or G.BufferedAction(self.inst, nil, G.ACTIONS.WALKTO, nil, G.TheInput:GetWorldPosition())
        local entity_under_mouse = G.TheInput:GetWorldEntityUnderMouse()
        
        local driving = false
        if self.inst.replica.rider then
          local mount = self.inst.replica.rider:GetMount()
          if mount and mount:HasTag("jx_car") then
            driving = true
          end
        end
        
        if not self.jx_car_wheel_parts and driving and act.action == G.ACTIONS.WALKTO and act.target == nil
          and (entity_under_mouse == nil or entity_under_mouse == self.inst)
        then
          return
        end
      end
      
      return old_OnLeftClick(self, down, ...)
    end
    
    local old_DoActionButton = self.DoActionButton
    function self:DoActionButton(...)
      local rider = self.ismastersim and self.inst.components.rider or self.inst.replica.rider
      if rider and rider:GetMount() ~= nil and rider:GetMount():HasTag("jx_car") then
        return
      end
      old_DoActionButton(self, ...)
    end
end)
--------------------------------------------------------------------------------------------------------
--自动关闭容器距离
AddComponentPostInit("container",function(self)
    local old_OnUpdate = self.OnUpdate
    function self:OnUpdate(dt, ...)
      if self.inst:HasTag("jx_car") then
        if self.opencount == 0 then
          self.inst:StopUpdatingComponent(self)
        else
          for opener, _ in pairs(self.openlist) do
            local mount = opener.components.rider and opener.components.rider:GetMount() or nil
            if mount or not (opener:IsValid() and opener:IsNear(self.inst, G.CONTAINER_AUTOCLOSE_DISTANCE * 5/3) and G.CanEntitySeeTarget(opener, self.inst)) then
              self:Close(opener)
            end
          end
        end
      else
        old_OnUpdate(self, dt, ...)
      end
    end
end)
--------------------------------------------------------------------------------------------------------
--拦截脚步声
local old_PlayFootstep = G.PlayFootstep
G.PlayFootstep = function(inst, volume, ispredicted, ...)
  if inst:HasTag("NOPLAYFOOTSTEP") then return end
  return old_PlayFootstep(inst, volume, ispredicted, ...)
end
---------------------------------------------------------------------------------------------------------
--HUD
AddClientModRPCHandler("JX", "HUDShowJXCarHUD", function(val)
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then
      hud:Show()
      hud:Update_Whistle_HUD(val)
    end
end)

AddClientModRPCHandler("JX", "HUDHideJXCarHUD", function()
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:Hide() end
end)

AddClientModRPCHandler("JX", "HUDUpdateFuel", function(fuel_level)
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:UpdateFuel(fuel_level) end
end)

AddClientModRPCHandler("JX", "HUDUpdateSpeed", function(percent)
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:UpdateSpeed(percent) end
end)

AddClientModRPCHandler("JX", "HUDOnHit", function()
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:HUDOnHit() end
end)

AddClientModRPCHandler("JX", "HUDKillMusic", function()
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:KillMusic() end
end)

AddClientModRPCHandler("JX", "HUDTextButton", function(num)
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:OnClick_Music_TextButton(num) end
end)

AddClientModRPCHandler("JX", "HUDPauseMusic", function()
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:OnClick_Pause() end
end)

AddClientModRPCHandler("JX", "HUDUpdateHealth", function(percent)
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:UpdateHealth(percent) end
end)

AddModRPCHandler("JX", "HUDWhistle", function(inst, val)
    if inst and inst.components.jx_driver then
      inst.components.jx_driver:DoWhistle(val)
    end
end)

AddModRPCHandler("JX", "HUDPauseMusic", function(inst, music, num)
    local target
    if inst.components.jx_driver and inst.components.jx_driver:GetCar() ~= nil then
      target = inst
    elseif inst and inst.jx_driver_as_passenger ~= nil then
      target = inst.jx_driver_as_passenger
    end
        
    local jx_driver = target and target.components.jx_driver
    if jx_driver == nil then return end
    
    local allplayer = {target,}
    for _, v in ipairs(jx_driver.passenger) do
      table.insert(allplayer, v)
    end
    
    if jx_driver and jx_driver.music_parts == false then
      if inst.components.talker then
        inst.components.talker:Say(G.STRINGS.NO_MUSIC_PARTS)
      end
      for _, v in ipairs(allplayer) do
        G.SendModRPCToClient(G.GetClientModRPC("JX", "HUDKillMusic"), v.userid)
      end
      return
    end
    
    if target.SoundEmitter then
      target.SoundEmitter:KillSound("jx_car_music")
      if music then
        target.SoundEmitter:PlaySound("jx_car_music/jx_car_music/"..music, "jx_car_music")
        for _, v in ipairs(allplayer) do
          if v ~= inst then--RPC的发送者的hud已由客户端完成更新
            G.SendModRPCToClient(G.GetClientModRPC("JX", "HUDTextButton"), v.userid, num)
          end
        end
      else
        for _, v in ipairs(allplayer) do
          if v ~= inst then--RPC的发送者的hud已由客户端完成更新
            G.SendModRPCToClient(G.GetClientModRPC("JX", "HUDPauseMusic"), v.userid)
          end
        end
      end
    end
end)

AddClassPostConstruct("widgets/controls", function(self)
    self.inst:DoTaskInTime(0,function()
        local JX_Car_HUD = require "widgets/jx_car_hud"
        self.jx_car_hud = self.bottom_root:AddChild(JX_Car_HUD())
        
        self.jx_car_hud:SetVAnchor(G.ANCHOR_BOTTOM)
        self.jx_car_hud:SetHAnchor(G.ANCHOR_MIDDLE)
        self.jx_car_hud:SetPosition(0, 100)
        
        local ssx, ssy = G.TheSim:GetScreenSize()
        local current_xy = ssx / ssy
        
        local bw, bh = 2560, 1440
        local base_wh = bw / bh
        local scale = ssy / bh
        
        if current_xy > base_wh then
          scale = scale * (base_wh / current_xy)
        end
        
        self.jx_car_hud:SetScale(scale, scale)
        self.jx_car_hud:Hide()
    end)
end)
---------------------------------------------------------------------------------------------------------
--乘客系统

AddClientModRPCHandler("JX", "HUDUpdatePassenger", function(n1, n2, n3)--根据汽车实际乘客数选定参数数量
    local hud = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.controls and G.ThePlayer.HUD.controls.jx_car_hud
    if hud then hud:HUDUpdatePassenger(n1, n2, n3) end
end)

local jx_passenger = AddAction("JX_PASSENGER", G.STRINGS.ACTIONS.JX_PASSENGER, function(act)
  if act.target then
    local comp = act.target.components.jx_driver
    if comp:IsOneOfThePassengers(act.doer) then
      comp:RemovePassenger(nil, act.doer)
      return true
    elseif comp:IsFullPassenger() then
      act.doer:DoTaskInTime(0,function()
        if act.doer.components.talker then
          act.doer.components.talker:Say(G.STRINGS.PASSENGERFAIL.ISFULL)
        end
      end)
    elseif comp:AddPassenger(act.doer) then
      return true
    else
      act.doer:DoTaskInTime(0,function()
        if act.doer.components.talker then
          act.doer.components.talker:Say(G.STRINGS.PASSENGERFAIL.CANNOTSUCCESS)
        end
      end)
    end
  end
  return false
end)
jx_passenger.rmb = true
jx_passenger.mount_valid = true

AddComponentAction("SCENE", "jx_driver", function(inst, doer, actions, right)
    if right and inst._jx_car_isdriving ~= nil and inst._jx_car_isdriving:value()
      and doer._jx_car_isdriving ~= nil and not doer._jx_car_isdriving:value()
    then
      local rider = doer.replica.rider
      if rider and not rider:IsRiding() then
        table.insert(actions, jx_passenger)
      end
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_passenger, "doshortaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_passenger, "doshortaction"))
---
--下线、死亡处理
local function ondespawn(inst)
  local player = inst.jx_driver_as_passenger
  if player and player:IsValid()
    and player.components.jx_driver
  then
    player.components.jx_driver:RemovePassenger(nil, inst)
  end
end

local function ondeath(inst)
  local player = inst.jx_driver_as_passenger
  if player and player:IsValid()
    and player.components.jx_driver
  then
    player.components.jx_driver:RemovePassenger(nil, inst)
  end
end

AddPlayerPostInit(function(inst)
    if not G.TheWorld.ismastersim then return end
    inst.jx_car_player_despawn = ondespawn
    inst.jx_car_ondeath = ondeath
    --监听器放在jx_driver组件里
end)
---------------------------------------------------------------------------------------------------------