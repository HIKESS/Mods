--/////////////////////////////////////////////////////////////////////////////
--2026/1/7：
--组件说明：
--这是一个给玩家用的服务器端组件，作用是在"车"上时将控制输入转化成物理速度
--使用它之前先用适当的方法检查拦截玩家的控制输入，再开始更新这个组件
--这个组件的代码中加速度是直接加到速度上，不是按照真实物理的 v = v0 + a * t
--/////////////////////////////////////////////////////////////////////////////

local math_log, math_clamp, math_abs, math_sqrt, math_cos, math_sin, math_rad, math_pow = 
      math.log, math.clamp, math.abs, math.sqrt, math.cos, math.sin, math.rad, math.pow

local JX_DRIVER_CONSTANTS = 
{
  PLAYER_MASS = 75,
  PLAYER_RADIUS = .5,
  
  STEER_STEERMULT = 4,
  STEER_REVERSEMULTIPLIER = 4,
  STEER_ADDSTEERMULT = .2,
  STEER_DECAY = .75,
  STEER_ZERO_THRESHOLD = .1,
  STEER_MARK = .5,
  
  DRIFT_DECAY = .95,
  DRIFT_ZERO_THRESHOLD = 1,
  DRIFT_PER_ROT = 2,
  DRIFT_MIN_NEEDED = 5,
  DRIFT_MAX_NEEDED = 60,
  DRIFT_PLAYSOUND_NEEDED = 40,
  
  SPEED_TOPSPEED = 14,
  SPEED_TOPSPEED_ENGINE = TUNING.JX_TUNING.jx_parts_engine,
  SPEED_REVERSE_TOPSPEED = -6,
  SPEED_ACCELMULT = .6,
  SPEED_ACCELMULT_ENGINE = .75,
  SPEED_ZERO_THRESHOLD = .1,
  SPEED_GOTOSTOP_SG_MINSPEED = 8.0,
  SPEED_GOTOREVERSESTOP_SG_MINSPEED = -4.0,
  SPEED_MARK = 13.0,
  SPEED_LOOP_SOUND = 5.0,
  
  DRAG = .1,
  DRAG_FACTOR = .2,
  
  DAMAGE_TAKEN_MULT = 1,
  
  DIST_BETWEEN_MARK = 3.45,
  
  PHYSICS_MASS = 500,
  PHYSICS_FRICTION = 1,
  PHYSICS_DAMPING = 0,
  PHYSICS_RAD = 2,
  
  HEIGHT_THRESHOLD = .1,
  
  CAMERA_UPDATE_COOLDOWN = 1,
  
  CAR_DODELTA_MULT = .1,
  BLOCKER_DAMAGE = 40,
  WORK_DAMAGE = 10,
  
  LIGHT =
  {
    START_NUM = 6,
    MAX_NUM = 16,
    RADIUS = 4.4,
    FALLOFF = 1,
    INTENSITY = .75,
    COLOUR = { R = 180/255, G = 195/255, B = 150/255 },
    
    LIGHT_1 =  { RADIUS = 0,                      THETA = 0,            },
    LIGHT_2 =  { RADIUS = 6,                      THETA = PI/6,         },
    LIGHT_3 =  { RADIUS = 6 * 2,                  THETA = PI/6,         },
    LIGHT_4 =  { RADIUS = 6 * math_sqrt(3),       THETA = 0,            },
    LIGHT_5 =  { RADIUS = 6 * 2,                  THETA = PI/6 * (-1),  },
    LIGHT_6 =  { RADIUS = 6,                      THETA = PI/6 * (-1),  },
    LIGHT_7 =  { RADIUS = 6 * 3,                  THETA = PI/6,         },
    LIGHT_8 =  { RADIUS = 6 * 4,                  THETA = PI/6,         },
    LIGHT_9 =  { RADIUS = 6 * math_sqrt(13),      THETA = .281,        },
    LIGHT_10 = { RADIUS = 6 * math_sqrt(3) * 2,   THETA = 0,            },
    LIGHT_11 = { RADIUS = 6 * math_sqrt(13),      THETA = -.281,       },
    LIGHT_12 = { RADIUS = 6 * 4,                  THETA = PI/6 * (-1),  },
    LIGHT_13 = { RADIUS = 6 * 3,                  THETA = PI/6 * (-1),  },
    LIGHT_14 = { RADIUS = 6 * math_sqrt(3) * 3/2, THETA = 0,            },
    LIGHT_15 = { RADIUS = 6 * math_sqrt(19),      THETA = .115,        },
    LIGHT_16 = { RADIUS = 6 * math_sqrt(19),      THETA = -.115,       },
  },
  
  FUEL =
  {
    {level = 1,  min = 0,    max = .1,},
    {level = 2,  min = .1,  max = .3,},
    {level = 3,  min = .3,  max = .5,},
    {level = 4,  min = .5,  max = .7,},
    {level = 5,  min = .7,  max = .9,},
    {level = 6,  min = .9,  max = 1,  },
  },
  
  PASSENGER_MAX_NUM = 3,
  PASSENGER =
  {
    --1号总是自己
    {num = 2,  min = 0,    max = 90,},
    {num = 3,  min = 180,  max = 270,},
    {num = 4,  min = 90,   max = 180,},
  },
  
  PANIC_RADIUS = 20,
  PANIC_PERIOD = 1,
  
  KNOCKBACK_SPEED = 10,
}

local function apply_panic_fx(target, fx_prefab)
	local fx = SpawnPrefab(fx_prefab)
	if fx then
		fx.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
	return fx
end

local function ActionFilter_Driver(inst, action)
  return action.jx_car_invalid ~= true and action.jx_car_valid == true
end

local function onlight_enable(self, light_enable)
  if light_enable then
    self.inst.AnimState:Show("light")
  else
    self.inst.AnimState:Hide("light")
  end
  
  local key_to_remove = {}
  for k, v in ipairs(self.light) do
    if v:IsValid() then
      if light_enable then
        if v.Light then
          v.Light:Enable(true)
        end
      else
        if v.Light then
          v.Light:Enable(false)
        end
      end
    else
      table.insert(key_to_remove, k)
    end
  end
  
  if #key_to_remove > 0 then
    for _, k in ipairs(key_to_remove) do
      self.light[k] = nil
    end
  end
end

local function oncombat_damagetakenmult(self, combat_damagetakenmult)
  if self.inst.components.combat then
    local multipliers = self.inst.components.combat.externaldamagetakenmultipliers
    local source = self.inst
    local mult = combat_damagetakenmult
    local key = "jx_car_combat_absorb"
    if mult ~= self.org_combat_damagetakenmult then
      multipliers:SetModifier(source, mult, key)
      self.inst:ListenForEvent("blocked", self._onblocked_damage)
    else
      multipliers:RemoveModifier(source, key)
      self.inst:RemoveEventCallback("blocked", self._onblocked_damage)
    end
  end
end

local function onextra_light(self)--, extra_light)
  self:CreateLight()
  self:Update_Light()
end

local function onengine_parts(self, engine_parts)
  if engine_parts then
    self.accelmult = JX_DRIVER_CONSTANTS.SPEED_ACCELMULT_ENGINE
    self.topspeed = JX_DRIVER_CONSTANTS.SPEED_TOPSPEED_ENGINE
  else
    self.accelmult = JX_DRIVER_CONSTANTS.SPEED_ACCELMULT
    self.topspeed = JX_DRIVER_CONSTANTS.SPEED_TOPSPEED
  end
end

local function onwheel_parts(self, wheel_parts)
  self.mouse_move_disable = wheel_parts
  if self.inst.userid then
    SendModRPCToClient(GetClientModRPC("JX", "playercontroller_wheel_parts"), self.inst.userid, wheel_parts)
  end
end

local Jx_Driver = Class(function(self, inst)
  self.inst = inst
  
  --变量
  self.keydown_left = 0       --按键按下情况
  self.keydown_right = 0      --按键...
  self.keydown_up = 0         --按键...
  self.keydown_down = 0       --按键...
  self.keydown_space = 0      --按键...
  self.addsteer = 0           -- 转向增量
  self.steer = 0              -- 当前转向角度
  self.drift_rot = 0          -- 漂移积累角度
  self.accel = 0              -- 加速度
  self.speed = 0              -- 当前合速度
  self.vel_x = 0              -- 速度前向分量
  self.vel_z = 0              -- 速度侧向分量
  self.collision = 0          -- 碰撞系数
  self.loop_sound = false     -- 行车噪音
  self.hud_hit_colour = false -- 撞击识别
  
  local CONT = JX_DRIVER_CONSTANTS
  
  ----------
  --组件常量
  ----------
  self.addsteermult =               CONT.STEER_ADDSTEERMULT                -- 转向增量倍率 控制addsteer
  self.steermult =                  CONT.STEER_STEERMULT                   -- 转向总倍率 控制steer
  self.reversesteermult =           CONT.STEER_REVERSEMULTIPLIER           -- 倒车转向总倍率
  self.steerdecay =                 CONT.STEER_DECAY                       -- 转向角度自然衰减速率
  self.steerzerothreshold =         CONT.STEER_ZERO_THRESHOLD              -- 转向角度归零阈值
  self.steermark =                  CONT.STEER_MARK                        -- 生成车辙的转向角度阈值
  self.drift_decay =                CONT.DRIFT_DECAY                       -- 漂移积累角衰减速率
  self.driftzerothreshold =         CONT.DRIFT_ZERO_THRESHOLD              -- 应用漂移积累角的最小阈值
  self.drift_per_rot =              CONT.DRIFT_PER_ROT                     -- 单次漂移增加的转向角
  self.drift_min_needed =           CONT.DRIFT_MIN_NEEDED                  -- 漂移最低临界角
  self.drift_max_needed =           CONT.DRIFT_MAX_NEEDED                  -- 漂移最大临界角
  self.drift_playsound_needed =     CONT.DRIFT_PLAYSOUND_NEEDED            -- 漂移音效临界角
  self.topspeed =                   CONT.SPEED_TOPSPEED                    -- 最高速度
  self.reversespeed =               CONT.SPEED_REVERSE_TOPSPEED            -- 倒车最高速度
  self.accelmult =                  CONT.SPEED_ACCELMULT                   -- 加速倍数
  self.speedzerothreshold =         CONT.SPEED_ZERO_THRESHOLD              -- 速度归零阈值
  self.speedloopsound =             CONT.SPEED_LOOP_SOUND                  -- 行车噪音速度阈值
  self.stopsgspeed =                CONT.SPEED_GOTOSTOP_SG_MINSPEED        -- 进入停车sg的速度阈值
  self.reversesgspeed =             CONT.SPEED_GOTOREVERSESTOP_SG_MINSPEED -- 进入倒车停车sg的速度阈值
  self.speedmark =                  CONT.SPEED_MARK                        -- 生成车辙的速度阈值
  self.drag =                       CONT.DRAG                              -- 阻力
  self.drag_factor =                CONT.DRAG_FACTOR                       -- 阻力对速度的响应倍率
  self.org_combat_damagetakenmult = CONT.DAMAGE_TAKEN_MULT                 -- 减伤系数
  self.heightthreshold =            CONT.HEIGHT_THRESHOLD                  -- Y轴限高阈值  
  self.dist_between_mark =          CONT.DIST_BETWEEN_MARK                 -- 车辙的前后最小间距
  self.car_dodelta_mult =           CONT.CAR_DODELTA_MULT                  -- 车受伤倍率系数
  self.blocker_damage =             CONT.BLOCKER_DAMAGE                    -- 撞到障碍物损伤 不受car_dodelta_mult影响
  self.work_damage =                CONT.WORK_DAMAGE                       -- 作业时损伤 不受car_dodelta_mult影响
  self.panic_radius =               CONT.PANIC_RADIUS                      -- 鸣笛惊吓半径
  self.panic_period =               CONT.PANIC_PERIOD                      -- 鸣笛惊吓搜索间隔
  self.knockback_speed =            CONT.KNOCKBACK_SPEED                   -- 跳车击退临界速度
  
  --------------
  --物理组件常量
  --------------
  self.mass =          CONT.PHYSICS_MASS      -- 质量
  self.friction =      CONT.PHYSICS_FRICTION  -- 摩擦
  self.damping =       CONT.PHYSICS_DAMPING   -- 阻尼
  self.rad =           CONT.PHYSICS_RAD       -- 碰撞半径
  self.player_mass =   CONT.PLAYER_MASS       -- 玩家原始物理质量
  self.player_radius = CONT.PLAYER_RADIUS     -- 玩家原始物理半径
  
  --光源实体
  self.light = {}
  self.light_enable = false             -- 光源开关
  self.max_light = CONT.LIGHT.START_NUM -- 初始光源数量 常量
  self._onworldstatechange = function() self:Update_Light() end
  
  --车辆
  self.car = nil
  
  --相机
  self.camera_last_update_time = nil
  self.camera_update_cooldown = CONT.CAMERA_UPDATE_COOLDOWN -- 相机RPC发送间隔
  self.camera_follow_mode = false                           -- 实时跟随视角模式
  self.camera_auto_mode = false                             -- 自动对齐相机模式
  
  --乘客
  self.passenger = {}
  self.max_passenger = CONT.PASSENGER_MAX_NUM -- 最大乘客数量
  
  --减伤回调
  self._onblocked_damage = function(player, data) self:OnBlockedDamage(player, data) end
  self.combat_damagetakenmult = self.org_combat_damagetakenmult 
  
  --碰撞回调
  self.recently_collision = {}
  self._collision_callback = function(inst, other) self:OnCollision(inst, other) end
  
  --碰撞扩展
  self.collision_expansion = nil
  
  --配件
  self.mouse_move_disable = false         -- 解锁鼠标控制方向
  self.mark_always_enable = false         -- 常驻车辙
  self.extra_light = self.max_light       -- 光源扩展
  self.engine_parts = false               -- 引擎配件
  self.music_parts = false                -- 车载音箱
  
  --油量
  self.fuel_level = 1
  
  local pos = Point(0, 0, 0)
  self.pos = pos
  self.last_pos = pos
  self.last_mark_pos = pos
  
  self.inst:DoTaskInTime(0, function() 
    self:InitializePosition()
  end)
end,
nil,
{
  light_enable = onlight_enable,
  combat_damagetakenmult = oncombat_damagetakenmult,
  extra_light = onextra_light,
  engine_parts = onengine_parts,
  wheel_parts = onwheel_parts,
})

function Jx_Driver:InitializePosition()
  local pos = self.inst:GetPosition()
  self.pos = pos
  self.last_pos = pos
  self.last_mark_pos = pos
end

function Jx_Driver:GetCar()
  return self.car
end

-- 延迟补偿
function Jx_Driver:MovementPrediction(val)
  if self.inst.userid then
    SendModRPCToClient(GetClientModRPC("JX", "MovementPrediction"), self.inst.userid, val)
  end
end

function Jx_Driver:CreateLight()
  if self.pos == nil or self:GetCar() == nil then
    return
  end
  
  for k, v in ipairs(self.light) do
    if v:IsValid() then
      v:Remove()
    end
    self.light[k] = nil
  end
  
  local CONST = JX_DRIVER_CONSTANTS
  local theta = math_rad(self.inst.Transform:GetRotation())
  
  for i = 1, self.extra_light do
    local light = SpawnPrefab("jx_light")
    if light then
      if light.Light then
        light.Light:SetRadius(CONST.LIGHT.RADIUS)
        light.Light:SetFalloff(CONST.LIGHT.FALLOFF)
        light.Light:SetIntensity(CONST.LIGHT.INTENSITY)
        light.Light:SetColour(CONST.LIGHT.COLOUR.R, CONST.LIGHT.COLOUR.G, CONST.LIGHT.COLOUR.B)
        light.Light:Enable(false)
      end
      
      local CONST_LIGHT = CONST.LIGHT["LIGHT_"..tostring(i)]
      local radius = CONST_LIGHT.RADIUS
      local new_theta = theta + CONST_LIGHT.THETA
      local offset_x = radius * math_cos(new_theta)
      local offset_z = -radius * math_sin(new_theta)
      local new_x = self.pos.x + offset_x
      local new_z = self.pos.z + offset_z
      light.Transform:SetPosition(new_x, 0, new_z)
      
      self.light[i] = light
    end
  end
end

function Jx_Driver:EnableLight(enable)
  self.light_enable = enable
end

function Jx_Driver:Update_Light()
  local mount = self.inst.components.rider and self.inst.components.rider:GetMount()
  if mount and mount:HasTag("jx_car") then
    if TheWorld.state.isday then
      self:EnableLight(false)
    else
      self:EnableLight(true)
      self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/turn_on_light")
    end
  else
    self:EnableLight(false)
  end
end

-- Update_Light 用来更新光源开和关
-- Update_Light_Position 用来更新光源位置
function Jx_Driver:Update_Light_Position()
  local CONST = JX_DRIVER_CONSTANTS
  local theta = math_rad(self.inst.Transform:GetRotation())
  local invalid_light
  
  for i = 1, #self.light do
    local CONST_LIGHT = CONST.LIGHT["LIGHT_"..tostring(i)]
    local radius = CONST_LIGHT.RADIUS
    local new_theta = theta + CONST_LIGHT.THETA
    local offset_x = radius * math_cos(new_theta)
    local offset_z = -radius * math_sin(new_theta)
    local new_x = self.pos.x + offset_x
    local new_z = self.pos.z + offset_z
    if self.light[i] and self.light[i]:IsValid() then
      self.light[i].Transform:SetPosition(new_x, 0, new_z)
    else
      invalid_light = true
    end
  end
  
  if invalid_light then
    self:CreateLight()
  end
end

function Jx_Driver:ResetState()
  self.addsteer = 0
  self.steer = 0
  self.accel = 0
  self.speed = 0
  self.collision = 0
  
  self.recently_collision = {}
  
  self.inst.SoundEmitter:KillSound("car_loop_sound")
  self.inst.SoundEmitter:KillSound("jx_car_whistle")
  self.inst.SoundEmitter:KillSound("jx_car_music")
  if self.inst.userid then
    SendModRPCToClient(GetClientModRPC("JX", "HUDKillMusic"), self.inst.userid)
  end
  
  self:Update_Light()
  self:UpdateSpeed()
end

function Jx_Driver:UpdatePhysics(val)
  if self.collision_expansion and self.collision_expansion:IsValid() then
    self.collision_expansion:Remove()
    self.collision_expansion = nil
  end
  
  local phys = self.inst.Physics
  if phys == nil then return end
  phys:SetMotorVel(0, 0, 0)
  
  if val then
    local collision_expansion = SpawnPrefab("jx_car_physics_collision")
    if collision_expansion then
      collision_expansion.owner = self.inst
      
      local exp_phy = collision_expansion.Physics
      exp_phy:SetMass(self.mass)
      exp_phy:SetFriction(self.friction)
      exp_phy:SetDamping(self.damping)
      
      self.collision_expansion = collision_expansion
      --"碰撞拓展(collision_expansion)"是一个跟随车辆的无形实体，主要与地面的物品(inventoryitem)发生碰撞
    end
    
    phys:SetMass(self.mass)
    phys:SetFriction(self.friction)
    phys:SetDamping(self.damping)
    phys:SetCapsule(self.rad, 1)
    phys:SetCollisionCallback(self._collision_callback)
    
  else
    ChangeToCharacterPhysics(self.inst, self.player_mass, self.player_radius)
    phys:SetCollisionCallback(nil)
  end
end

function Jx_Driver:Update_Collision_Expansion_Pos()
  local need_tele
  local exp = self.collision_expansion
  local now_time
  
  if exp and exp:IsValid() then
    if self.speed == 0 and not self.mouse_move_disable then
      need_tele = true
    else
      now_time = GetTime()
      local last_time = exp.last_teleport_time
      if last_time == nil or now_time - last_time > .3 then
        need_tele = true
      end
    end
    
    if need_tele then
      exp.last_teleport_time = now_time or GetTime()
      exp.Physics:Teleport(self.pos.x, self.pos.y, self.pos.z)
    end
  end
end

function Jx_Driver:UpdateRainimmunity(target, source, val)
  if source == nil or target == nil then return end
  if val then
    if not target.components.rainimmunity then
      target:AddComponent("rainimmunity")
    end
    target.components.rainimmunity:AddSource(source)
  else
    if target.components.rainimmunity then
      target.components.rainimmunity:RemoveSource(source)
    end
  end
end

function Jx_Driver:UpdateActionFilter(player, push)
  if player ~= nil and push ~= nil then
    local isdriver = player == self.inst
    if player.userid then
      SendModRPCToClient(GetClientModRPC("JX", "ActionFilter_Car"), player.userid, push, isdriver)
    end
  end
end

function Jx_Driver:StartDrive(data)
  --在"prefabs/jx_car"中有一个 newstate 事件监听，也很重要
  self.inst.AnimState:SetBank("wilsonjxdrive")
  if data and data.target then
    if data.target.ApplyBuildOverrides then
      data.target:ApplyBuildOverrides(self.inst.AnimState)
    end
    if data.target.jx_last_rotation then
      self.inst.Transform:SetRotation(data.target.jx_last_rotation)
      data.target.jx_last_rotation = nil
    end
  end
  self.inst.Transform:SetEightFaced()
  self.inst.sg:GoToState("drive_idle")
  
  self:UpdatePhysics(true)
  
  self:UpdateActionFilter(self.inst, true)
  
  self:ResetState()
  
  self.inst:WatchWorldState("isnight", self._onworldstatechange)
  self.inst:WatchWorldState("isday", self._onworldstatechange)
  self.inst:WatchWorldState("isdusk", self._onworldstatechange)
    
  local car = self.inst.components.rider and self.inst.components.rider:GetMount()
  if car ~= nil then
    self.car = car
    if car.components.fueled then
      car.components.fueled:StartConsuming()
    end
    if car.components.jx_rideable then
      car.components.jx_rideable.driver = self.inst
    end
  end
  
  self:ApplyParts()
  
  self:ShowHUD(self.inst)
  
  self:UpdateHealth()
  
  self:UpdateFuel()
  self:StartUpdateFuel()
  
  self:UpdateRainimmunity(self.inst, self.car, true)
  
  self:MovementPrediction(false)
  
  if self.inst.userid then
    SendModRPCToClient(GetClientModRPC("JX", "CameraSetOffset"), self.inst.userid, 0, 5, 0)
    self.inst:DoTaskInTime(2 * FRAMES, function()
      if self.camera_follow_mode then
        SendModRPCToClient(GetClientModRPC("JX", "CameraClientSide"), self.inst.userid, true)
      else
        SendModRPCToClient(GetClientModRPC("JX", "CameraSetHeadingTarget"), self.inst.userid)
      end
    end)
    
    SendModRPCToClient(GetClientModRPC("JX", "JX_Car_AddKeyHandle"), self.inst.userid)
  end
  
  self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/ignite")
  self.inst:AddTag("NOPLAYFOOTSTEP")
  if self.inst._jx_car_isdriving then
    self.inst._jx_car_isdriving:set(true)
  end
  
  self.inst:StartUpdatingComponent(self)
  
  self.inst:DoTaskInTime(1, function()
    if self.car and self.car.components.fueled and self.car.components.fueled:GetPercent() <= 0 then
      if self.inst.components.talker then
        self.inst.components.talker:Say(STRINGS.NO_CAR_FUEL)
      end
    end
  end)
end

--不可以直接使用这个方法，最好在 dismounted 的事件监听函数中进行调用
function Jx_Driver:StopDrive(data)
  if self.inst._jx_car_isdriving then
    self.inst._jx_car_isdriving:set(false)
  end
  if data and data.target then
    data.target.jx_last_rotation = data.target.Transform:GetRotation()
  end
  
  if self.speed > self.knockback_speed then
    local car = self.car
    local speed = self.speed
    local damage = speed * 2
    self.inst:DoTaskInTime(0,function()
      if self.inst.components.combat then
        self.inst.components.combat:GetAttacked(self.inst, damage)
      end
      self.inst:PushEvent("knockback", { forcelanded = true, })
      if car and car:IsValid() and car.sg then
        car.sg:GoToState("slide", { speed = speed })
      end
    end)
  end
  
  self.inst:StopUpdatingComponent(self)
  
  self:UpdateActionFilter(self.inst, false)
  
  self:RemoveAllPassenger()
  
  self:StopUpdateFuel()
  
  self:HideHUD(self.inst)
  
  self:OnStopDrive_Teleport_Pos()
  
  self:UpdatePhysics(false)
  
  self:UpdateRainimmunity(self.inst, self.car, false)
  
  self:ResetState()
  
  self.inst:StopWatchingWorldState("isnight", self._onworldstatechange)
  self.inst:StopWatchingWorldState("isday", self._onworldstatechange)
  self.inst:StopWatchingWorldState("isdusk", self._onworldstatechange)
  
  for _, v in ipairs(self.light) do
    if v:IsValid() then
      v:Remove()
    end
  end
  self.light = {}
  self:EnableLight(false)
  
  if self.car then
    if self.car.components.fueled then
      self.car.components.fueled:StopConsuming()
    end
    if self.car.components.jx_rideable then
      self.car.components.jx_rideable.driver = nil
    end
    self.car = nil
  end
  
  if self.inst.userid then
    SendModRPCToClient(GetClientModRPC("JX", "CameraSetOffset"), self.inst.userid)
    if self.camera_follow_mode then
      SendModRPCToClient(GetClientModRPC("JX", "CameraClientSide"), self.inst.userid, false)
    else
      local angle = self.inst:GetRotation()
      local snapped = math.floor((angle + 22.5) / 45) * 45
      local camera_angle = (180 - snapped) % 360
      self.inst:DoTaskInTime(2 * FRAMES,function() SendModRPCToClient(GetClientModRPC("JX", "CameraSetHeadingTarget"), self.inst.userid, camera_angle) end)
    end
  end
  
  self:ApplyParts()
  
  self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/lock")
  self.inst:RemoveTag("NOPLAYFOOTSTEP")
  if self.inst._jx_car_isdriving then
    self.inst._jx_car_isdriving:set(false)
  end
  
  self:MovementPrediction(true)
end

function Jx_Driver:OnStopDrive_Teleport_Pos()
  local angle = self.car and self.car:GetRotation()
  if angle then
    local pos = self.pos
    local radius = self.car.Physics:GetRadius()
    local theta = math.rad(angle + 300)
    local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
    local newpos = pos + offset
    self.inst.Physics:Teleport(newpos.x, newpos.y, newpos.z)
    self.car.Physics:Teleport(pos.x, pos.y, pos.z)
  end
end

function Jx_Driver:ApplyParts()
  local comp = self.car and self.car.components.jx_rideable
  if comp then
    self.combat_damagetakenmult = comp.combat_damagetakenmult
    self.extra_light = comp.extra_light
    self.engine_parts = comp.engine_parts
    self.music_parts = comp.music_parts
    self.wheel_parts = comp.wheel_parts
    self.camera_follow_mode = comp.camera_follow_mode
    self.camera_auto_mode = comp.camera_auto_mode
  else
    self.combat_damagetakenmult = self.org_combat_damagetakenmult
    self.extra_light = self.max_light
    self.engine_parts = false
    self.music_parts = false
    self.wheel_parts = false
    self.camera_follow_mode = false
    self.camera_auto_mode = false
  end
end

function Jx_Driver:UpdateHealth(hit)
  if self.car and self.car.components.jx_rideable then
    local percent = self.car.components.jx_rideable:GetPercent()
    if self.inst.userid then
      SendModRPCToClient(GetClientModRPC("JX", "HUDUpdateHealth"), self.inst.userid, percent)
    end
    if #self.passenger > 0 then
      for _, v in ipairs(self.passenger) do
        if v.userid then
          SendModRPCToClient(GetClientModRPC("JX", "HUDUpdateHealth"), v.userid, percent)
        end
      end
    end
  end
  
  if hit then
    if self.inst.userid then
      SendModRPCToClient(GetClientModRPC("JX", "HUDOnHit"), self.inst.userid)
    end
    if #self.passenger > 0 then
      for _, v in ipairs(self.passenger) do
        if v.userid then
          SendModRPCToClient(GetClientModRPC("JX", "HUDOnHit"), v.userid)
        end
      end
    end
  end
end

function Jx_Driver:OnBlockedDamage(player, data)
  local sound_mult = math.random() * .5 + .5
  self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/hit", nil, sound_mult)
  
  if self.car and self.car.components.jx_rideable then
    local damage = 0
    if data.original_damage and data.original_damage > 0 then
      damage = damage + data.original_damage
    else
      if data.damage then
        damage = damage + data.damage
      end
      if data.spdamage then
        damage = damage + data.spdamage
      end
    end
    self.car.components.jx_rideable:DoDelta(-damage)
    
    self:UpdateHealth(true)
  end
end

function Jx_Driver:Drive()
  local l, r, u, d = self.keydown_left, self.keydown_right, self.keydown_up, self.keydown_down
  self.addsteer = math_clamp(r - l, -1, 1) * self.addsteermult
  self.accel = math_clamp(u - d, -1, 1) * self.accelmult
  
  self:Do_Drift()
  self:ApplyDriftDecay()
end

function Jx_Driver:Do_Drift()
  if self.keydown_space == 0 or (self.keydown_left == 0 and self.keydown_right == 0) then
    return
  end
  if self.car == nil or self.speed < 0
    or math_abs(self.drift_rot) < self.drift_min_needed
    or math_abs(self.drift_rot) > self.drift_max_needed
  then
    return
  end
  
  local per_rot = self.drift_per_rot
  if self.steer < 0 then
    per_rot = -per_rot
  end
  
  self.inst.Transform:SetRotation(self.inst.Transform:GetRotation() + per_rot)
  
  local old_drift_rot = self.drift_rot
  local new_drift_rot = self.drift_rot + per_rot
  
  if math_abs(old_drift_rot) < self.drift_playsound_needed and math_abs(new_drift_rot) > self.drift_playsound_needed then
    self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/stop")
  end
  
  self.drift_rot = new_drift_rot
end

function Jx_Driver:ApplyDriftDecay()
  if math_abs(self.drift_rot) > self.driftzerothreshold then
    self.drift_rot = self.drift_rot * self.drift_decay
  else
    self.drift_rot = 0
  end
end

function Jx_Driver:ApplyDrag()
  local drag = math_log(1 - self.drag)
  local drag_factor = self.drag_factor
  self.accel = self.accel + drag * self.speed * drag_factor
end

function Jx_Driver:UpdateSpeed()
  if math_abs(self.drift_rot) > self.driftzerothreshold then
    local rot = math_rad(self.drift_rot)
    self.vel_x = self.speed * math_cos(rot)
    self.vel_z = self.speed * math_sin(rot)
  else
    self.vel_x = self.speed
    self.vel_z = 0
  end
  
  self.vel_x = self.vel_x + self.accel
  local new_speed = math_sqrt(self.vel_x * self.vel_x + self.vel_z * self.vel_z)
  if self.vel_x < 0 then
    new_speed = -new_speed
  end
  self.speed = math_clamp(new_speed, self.reversespeed, self.topspeed)
  
  if math_abs(self.speed) < self.speedzerothreshold then
    self.speed = 0
  end
  
  local percent = self.speed / JX_DRIVER_CONSTANTS.SPEED_TOPSPEED_ENGINE --如果有比这个速度还要大的引擎，这个地方需要修改
  if self.inst.userid then
    SendModRPCToClient(GetClientModRPC("JX", "HUDUpdateSpeed"), self.inst.userid, percent)
  end
  if #self.passenger > 0 then
    for _, v in ipairs(self.passenger) do
      if v.userid then
        SendModRPCToClient(GetClientModRPC("JX", "HUDUpdateSpeed"), v.userid, percent)
      end
    end
  end
  
  if self.speed > self.speedloopsound then
    if not self.loop_sound then
      self.loop_sound = true
      self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/loop2", "car_loop_sound", 1 * TUNING.JX_TUNING.jx_car_drivenoise)
    end
  elseif self.speed < self.reversesgspeed then
    if not self.loop_sound then
      self.loop_sound = true
      self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/loop2", "car_loop_sound", .7 * TUNING.JX_TUNING.jx_car_drivenoise)
    end
  elseif self.loop_sound then
    self.loop_sound = false
    self.inst.SoundEmitter:KillSound("car_loop_sound")
  end
end

function Jx_Driver:ApplySteer(rot)
  if self.addsteer ~= 0 then
    self.steer = math_clamp(self.steer + self.addsteer, -1, 1)
    
    local rotation_change = self.steer * self.steermult * self.speed / 30
    
    if self.speed < 0 then
      rotation_change = rotation_change * self.reversesteermult
    end
    
    self.drift_rot = self.drift_rot + rotation_change
    
    self.inst.Transform:SetRotation(rot + rotation_change)
    if self.collision_expansion and self.collision_expansion:IsValid() then
      self.collision_expansion.Transform:SetRotation(rot + rotation_change)
    else
      self:UpdatePhysics(true)
    end
  end
end

function Jx_Driver:UpdateSG()
  if self.inst.sg then
    if self.inst.sg:HasAnyStateTag("dead", "dismounting") then
      return
    end
    
    local is_runing = self.inst.sg:HasStateTag("runing")
    local is_reverse = self.inst.sg:HasStateTag("reverse")
    
    if math_abs(self.accel) ~= 0 then
      if self.accel > 0 then
        if not is_runing then
          self.inst.sg:GoToState("drive_run_start")
        end
      else
        if not is_reverse then
          
          if is_runing then--将要刹车
            self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/stop")
          end
          
          self.inst.sg:GoToState("drive_run_reverse")
        end
      end
    else
      if is_runing and self.speed < self.stopsgspeed then
        self.inst.sg:GoToState("drive_run_stop")
      elseif is_reverse and self.speed > self.reversesgspeed then
        self.inst.sg:GoToState("drive_run_reverse_stop")
      end
    end
  end
end

function Jx_Driver:UpdateCamera()
  --在 self.camera_follow_mode 模式下
  --通过RPC来通知客户端更新相机的方法并不是很流畅，也浪费网络
  --现在通过名为 CameraClientSide 的RPC来通知一次，之后由客户端自己更新相机
  
  --if self.camera_follow_mode then
  --  if self.inst.userid then
  --    SendModRPCToClient(GetClientModRPC("JX", "CameraSetHeadingTarget"), self.inst.userid)
  --  end
  --elseif self.camera_auto_mode then
  if self.camera_auto_mode then
    if self.steer ~= 0 then
      return
    end
    local current_time = GetTime()
    local last_time = self.camera_last_update_time
    if last_time == nil or current_time - last_time > self.camera_update_cooldown then
      self.camera_last_update_time = current_time
      --SendModRPCToClient(GetClientModRPC("JX", "CameraSetContinuousHeadingTarget"), self.inst.userid) --不会再使用这个RPC
      local angle = (180 - self.inst:GetRotation()) % 360
      if self.inst.userid then
        SendModRPCToClient(GetClientModRPC("JX", "CameraSetHeadingTarget"), self.inst.userid, angle)
      end
    end
  end
end

function Jx_Driver:NoFuel()
  return self.car and self.car.components.fueled and self.car.components.fueled:GetPercent() <= 0
end

function Jx_Driver:UpdateFuel(isforce)
  if self.car and self.car.components.fueled then
    local fuel_level
    local current_percent = self.car.components.fueled:GetPercent()
    for _, v in ipairs(JX_DRIVER_CONSTANTS.FUEL) do
      if current_percent >= v.min and current_percent <= v.max then
        fuel_level = v.level
      end
    end
    if fuel_level and (isforce or fuel_level ~= self.fuel_level) then
      self.fuel_level = fuel_level
      if self.inst.userid then
        SendModRPCToClient(GetClientModRPC("JX", "HUDUpdateFuel"), self.inst.userid, fuel_level)
      end
      if #self.passenger > 0 then
        for _, v in ipairs(self.passenger) do
          if v.userid then
            SendModRPCToClient(GetClientModRPC("JX", "HUDUpdateFuel"), v.userid, fuel_level)
          end
        end
      end
    end
  end
end

function Jx_Driver:StartUpdateFuel()
  self:StopUpdateFuel()
  self.inst.jx_driver_updatefuel_task = self.inst:DoPeriodicTask(1,function() self:UpdateFuel() end)
end

function Jx_Driver:StopUpdateFuel()
  if self.inst.jx_driver_updatefuel_task ~= nil then
    self.inst.jx_driver_updatefuel_task:Cancel()
    self.inst.jx_driver_updatefuel_task = nil
  end
end

function Jx_Driver:ShowHUD(player)
  if player and player.userid then
    if player == self.inst then
      SendModRPCToClient(GetClientModRPC("JX", "HUDShowJXCarHUD"), player.userid, true)
    else
      SendModRPCToClient(GetClientModRPC("JX", "HUDShowJXCarHUD"), player.userid, false)
    end
  end
end

function Jx_Driver:HideHUD(player)
  if player and player.userid then
    SendModRPCToClient(GetClientModRPC("JX", "HUDHideJXCarHUD"), player.userid)
  end
end

function Jx_Driver:IsFullPassenger()
  return #self.passenger >= self.max_passenger
end

function Jx_Driver:AddPassenger(passenger, seat_num)
  if self:IsFullPassenger() or self:GetCar() == nil then
    return false
  end
  if passenger then
    local num = seat_num or nil
    if num == nil then
      local angle_1 = self.inst:GetRotation()
      local angle_2 = self.inst:GetAngleToPoint(passenger:GetPosition())
      local angle = (angle_2 - angle_1) % 360
      for _, v in ipairs(JX_DRIVER_CONSTANTS.PASSENGER) do
        if angle >= v.min and angle <= v.max then
          num = v.num
          break
        end
      end
    end
    if num == nil then
      return false
    end
    
    if #self.passenger > 0 then
      for _, v in ipairs(self.passenger) do
        if v.jx_driver_seat_num and v.jx_driver_seat_num == num then
          return false
        end
      end
    end
    
    if passenger.components.locomotor then
      passenger.components.locomotor:Stop()
    end
    
    passenger.jx_driver_seat_num = num
    passenger.jx_driver_as_passenger = self.inst
    passenger:ListenForEvent("player_despawn", passenger.jx_car_player_despawn)
    passenger:ListenForEvent("death", passenger.jx_car_ondeath)
    
    table.insert(self.passenger, passenger)
    passenger:AddTag("NOPLAYFOOTSTEP")
    passenger:AddTag("NOCLICK")
    passenger.AnimState:SetMultColour(1, 1, 1, 0)
    passenger.Physics:SetActive(false)
    passenger.DynamicShadow:Enable(false)
    
    self:UpdateActionFilter(passenger, true)
    self:UpdateRainimmunity(passenger, self.car, true)
    self:ShowHUD(passenger)
    self:Update_Passenger_HUD()
    self:Update_Passenger_CombatDamgeTakenMult(passenger, true)
    self:UpdateHealth()
    self:UpdateFuel(true)
    
    return true
  end
end

--两种移除方法，num(座位号)或者passenger(实体)任意参数都可以
function Jx_Driver:RemovePassenger(num, passenger)
  local real_passenger
  
  if num and not passenger then
    for k, v in ipairs(self.passenger) do
      if v and v.jx_driver_seat_num and v.jx_driver_seat_num == num then
        real_passenger = v
        table.remove(self.passenger, k)
        break
      end
    end
  elseif num and passenger then
    for k, v in ipairs(self.passenger) do
      if v and v.jx_driver_seat_num and v.jx_driver_seat_num == num and v == passenger then
        real_passenger = v
        table.remove(self.passenger, k)
        break
      end
    end
  elseif not num and passenger then
    for k, v in ipairs(self.passenger) do
      if v and v == passenger then
        real_passenger = v
        table.remove(self.passenger, k)
        break
      end
    end
  end
  
  if real_passenger and real_passenger:IsValid() then
    real_passenger:RemoveTag("NOPLAYFOOTSTEP")
    real_passenger:RemoveTag("NOCLICK")
    real_passenger.AnimState:SetMultColour(1, 1, 1, 1)
    real_passenger.Physics:SetActive(true)
    real_passenger.DynamicShadow:Enable(true)
    
    if real_passenger.jx_driver_seat_num then
      local num = real_passenger.jx_driver_seat_num
      local pos = self.inst:GetPosition()
      local radius = self.car and self.car.Physics and self.car.Physics:GetRadius() or 3
      local angle = self.inst:GetRotation()
      local theta, offset, newpos
      
      --如果扩展最大乘客数量，这个地方需要优化，取决于车辆的形状
      if num == 2 then
        theta = math_rad(angle + 60)
      elseif num == 4 then
        theta = math_rad(angle + 120)
      elseif num == 3 then
        theta = math_rad(angle + 240)
      end
      
      if theta then
        offset = Vector3(radius * math_cos(theta), 0, -radius * math_sin(theta))
        newpos = pos + offset
        real_passenger.Physics:Teleport(newpos.x, newpos.y, newpos.z)
      end
      
      real_passenger.jx_driver_seat_num = nil
      real_passenger.jx_driver_as_passenger = nil
      real_passenger:RemoveEventCallback("player_despawn", real_passenger.jx_car_player_despawn)
      real_passenger:RemoveEventCallback("death", real_passenger.jx_car_ondeath)
    end
    
    self:UpdateActionFilter(real_passenger, false)
    self:UpdateRainimmunity(real_passenger, self.car, false)
    self:Update_Passenger_CombatDamgeTakenMult(real_passenger, false)
    self:HideHUD(real_passenger)
    
    if self.speed > self.knockback_speed then
      local damage = self.speed * 2
      if real_passenger.components.combat then
        real_passenger.components.combat:GetAttacked(self.inst, damage)
      end
      real_passenger:PushEvent("knockback", { forcelanded = true, })
    end
  end
  
  self:Update_Passenger_HUD()
end

function Jx_Driver:RemoveAllPassenger()
  while #self.passenger > 0 do
    self:RemovePassenger(nil, self.passenger[1])
  end
end

function Jx_Driver:IsOneOfThePassengers(player)
  if player then
    for _, v in ipairs(self.passenger) do
      if v and v == player then
        return true
      end
    end
  end
  return false
end

function Jx_Driver:Update_Passenger_Pos()
  if #self.passenger > 0 then
    for k, v in ipairs(self.passenger) do
      if v:IsValid() then
        if v.components.health and not v.components.health:IsDead() then
          v.Transform:SetPosition(self.pos.x, self.pos.y, self.pos.z)
          
          local r, g, b ,i = v.AnimState:GetMultColour()
          if i ~= 0 then
            v.AnimState:SetMultColour(r, g, b, 0)
          end
          
        else
          self:RemovePassenger(nil, v)
        end
      end
    end
  end
end

function Jx_Driver:Update_Passenger_HUD()
  local seat_num_table = {}
  for _, v in ipairs(self.passenger) do
    if v.jx_driver_seat_num then
      table.insert(seat_num_table, v.jx_driver_seat_num)
    end
  end
  local n1, n2, n3 = seat_num_table[1], seat_num_table[2], seat_num_table[3]--根据汽车实际最大乘客数选定参数数量
  
  if self.inst.userid then
    SendModRPCToClient(GetClientModRPC("JX", "HUDUpdatePassenger"), self.inst.userid, n1, n2, n3)
  end
  if #self.passenger > 0 then
    for _, v in ipairs(self.passenger) do
      if v.userid then
        SendModRPCToClient(GetClientModRPC("JX", "HUDUpdatePassenger"), v.userid, n1, n2, n3)
      end
    end
  end
end

function Jx_Driver:Update_Passenger_CombatDamgeTakenMult(passenger, enable)
  if passenger and passenger.components.combat then
    local multipliers = passenger.components.combat.externaldamagetakenmultipliers
    local source = self.inst
    local mult = self.combat_damagetakenmult
    local key = "jx_car_combat_absorb"
    if enable then
      multipliers:SetModifier(source, mult, key)
      passenger:ListenForEvent("blocked", self._onblocked_damage)
    else
      multipliers:RemoveModifier(source, key)
      passenger:RemoveEventCallback("blocked", self._onblocked_damage)
    end
  end
end

function Jx_Driver:CreateMark(rot)
  if self.mark_always_enable == true or self.speed > self.speedmark then
    local runing = self.inst.sg and self.inst.sg:HasStateTag("runing")
    local dist = (self.pos - self.last_mark_pos):Length()
    if runing and dist >= self.dist_between_mark then
      for i = 1, 2 do
        local radius = self.rad / 2
        local angle = rot - self.drift_rot + 90 * math_pow((-1), i)
        local theta = math_rad(angle)
        local mark = SpawnPrefab("jx_car_mark")
        if mark then
          if math_abs(self.steer) < self.steermark then
            mark.AnimState:SetMultColour(1, 1, 1, .7)
          end
          mark.Transform:SetPosition(self.pos.x + radius * math_cos(theta), 0, self.pos.z - radius * math_sin(theta))
          mark.Transform:SetRotation(rot - self.drift_rot + 90)
        end
      end
      self.last_mark_pos = self.pos
    end
  end
end

function Jx_Driver:CleanupState()
  self.addsteer = 0
  self.accel = 0
  
  if math_abs(self.steer) < self.steerzerothreshold then
    self.steer = 0
  else
    if self.steer * self.addsteer < 0 then
      self.steer = self.steer * self.steerdecay * 0.5
    else
      self.steer = self.steer * self.steerdecay
    end
  end
end

function Jx_Driver:Explosion(noloot)
  if self.car == nil then
    return
  end
  
  local car = self.car
  local pos = car:GetPosition()
  local passengers = {}
  for _, v in ipairs(self.passenger) do
    table.insert(passengers, v)
  end
  
  if self.inst.components.rider then
    self.inst.components.rider:Dismount()
  end
  
  car:DoTaskInTime(2 * FRAMES,function()
    if car.components.jx_rideable then
      car.components.jx_rideable:Explosion(pos, noloot)
    end
  end)
end

function Jx_Driver:DoWhistle(val)
  self.inst.SoundEmitter:KillSound("jx_car_whistle")
  if self.inst.jx_car_whistle_panic_task ~= nil then
    self.inst.jx_car_whistle_panic_task:Cancel()
    self.inst.jx_car_whistle_panic_task = nil
  end
  
  if val then
    self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/whistle", "jx_car_whistle")
    self.inst.jx_car_whistle_panic_task = self.inst:DoPeriodicTask(self.panic_period, function()
      local SCARE_MUST_TAGS = {"_combat", "_health"}
      local SCARE_CANT_TAGS = { "balloon", "butterfly", "companion", "epic", "groundspike", "INLIMBO", "smashable", "structure", "wall"}
      local ents = TheSim:FindEntities(self.pos.x, 0, self.pos.z, self.panic_radius, SCARE_MUST_TAGS, SCARE_CANT_TAGS)
      for _, v in ipairs(ents) do
        if v.components.hauntable and v.components.hauntable.panicable then
          v.components.hauntable:Panic(7)
          v:DoTaskInTime(0.25 * math.random(), apply_panic_fx, "battlesong_instant_panic_fx")
        end
   	  end
    end, 0)
  end
end

function Jx_Driver:EnsureOnGround(y)
  if y > self.heightthreshold then
    self.pos.y = 0
    return true
  end
  return false
end

function Jx_Driver:OnCollision(inst, other)  
  if other ~= nil and other:IsValid() and other.Physics and
    Vector3(inst.Physics:GetVelocity()):LengthSq() >= 3 and
    not self.recently_collision[other]
  then
    inst:DoTaskInTime(2 * FRAMES, function()
      self:_OnDelayedCollision(other)
    end)
  end
end

function Jx_Driver:_OnDelayedCollision(other)
  if not self.inst:IsValid() or not other:IsValid() then
    return
  end
  
  if self.recently_collision[other] then
    return
  end
  
  self.recently_collision[other] = true
  
  local collision_strength = 0
  if other:HasTag("blocker") then
    collision_strength = .5
  else
    local other_mass = other.Physics:GetMass()
    local car_mass = self.mass
    collision_strength = math_clamp(other_mass / car_mass, 0, .5)
  end
  
  self.collision = collision_strength
  
  self:_OnBlockerCollision(other)
  
  self:_OnCreatureCollision(other)
  
  self:_OnObjectCollision(other)
  
  if self.hud_hit_colour then
    self.hud_hit_colour = false
  end
  
  self.inst:DoTaskInTime(1, function()
    if self.recently_collision then
      self.recently_collision[other] = nil
    end
  end)
end

function Jx_Driver:_OnBlockerCollision(other)
  if other:HasTag("blocker") then
    self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/hit")
    
    if self.car and self.car.components.jx_rideable then
      self.car.components.jx_rideable:DoDelta(-self.blocker_damage)
    end
    
    self.hud_hit_colour = true
  end
end

function Jx_Driver:_OnCreatureCollision(other)
  if other and other.components.combat 
    and other.components.health and not other.components.health:IsDead()
    and self.speed > 5 
  then
    local attacker = self.inst
    local damage = self.speed * 10
    if self.speed > 15 then
      damage = damage * 1.5
    end
    damage = damage * TUNING.JX_TUNING.jx_car_damagemult
    if other.components.domesticatable and other.components.domesticatable:GetDomestication() > 0 then
      other.components.combat:GetAttacked(nil, damage)
    else
      other.components.combat:GetAttacked(attacker, damage)
    end
    
    if self.car and self.car.components.jx_rideable then
      self.car.components.jx_rideable:DoDelta(-damage * self.car_dodelta_mult)
    end
        
    local base = .7
    local sound_mult = math_clamp(damage / (self.topspeed * 15) * (1- base) + base, base, 1)
    self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/hit", nil, sound_mult)
    
    self.hud_hit_colour = true
  end
end

function Jx_Driver:_OnObjectCollision(other)
  if other and other.components.workable and
    other.components.workable:CanBeWorked() and
    other.components.workable.action ~= ACTIONS.NET
  then
    if self.speed > 8 then
      other.components.workable:Destroy(self.inst)
      if other:HasTag("tree") then
        --local sound_mult = .7
        --local stage = other.components.growable and other.components.growable:GetStage()
        --if stage ~= nil then
        --  sound_mult = math_clamp(sound_mult + (1 - sound_mult) * stage / 3, sound_mult, 1)
        --end
        --self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/hit", nil, sound_mult)
        self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/hit")
      elseif other:HasTag("rock") then
        self.inst.SoundEmitter:PlaySound("jx_sound_6/jx_sound_6/hit")
      end
    else
      other.components.workable:WorkedBy(self.inst, 1)
    end
    
    if self.car and self.car.components.jx_rideable then
      self.car.components.jx_rideable:DoDelta(-self.work_damage)
    end
        
    self.hud_hit_colour = true
  end
end

function Jx_Driver:OnUpdate(dt)
  local x, y, z = self.inst.Transform:GetWorldPosition()
  
  self.pos = Point(x, y, z)
  
  self:Update_Collision_Expansion_Pos()
  
  self:Update_Passenger_Pos()
  
  self:Update_Light_Position()
  
  self:UpdateCamera()
  
  if self:NoFuel() then
    self:CleanupState()
    return
  end
  
  self:Drive()
  
  self:UpdateSG()
    
  if self.collision > 0 then
    self.speed = self.speed * (1 - self.collision)
    self.collision = 0
  end
  
  self:ApplyDrag()
  
  self:UpdateSpeed()
  
  local rot = self.inst.Transform:GetRotation()
  
  self:ApplySteer(rot)
  self.last_pos = Point(x, y, z)
  
  self:CreateMark(rot)
  
  local needs_teleport = self:EnsureOnGround(y)
    
  local phys = self.inst.Physics
  if phys then
    if needs_teleport then
      phys:Teleport(self.pos.x, self.pos.y, self.pos.z)
    end
    
    phys:SetMotorVel(self.vel_x, 0, self.vel_z)
    if self.collision_expansion and self.collision_expansion:IsValid() then
      self.collision_expansion.Physics:SetMotorVel(self.vel_x, 0, self.vel_z)
    end
  end
  
  self:CleanupState()
end

return Jx_Driver