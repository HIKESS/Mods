--///////////////////////////////////////
--这是一个给手电筒用的服务器端组件
--///////////////////////////////////////

local math_sqrt, math_cos, math_sin, math_rad, math_acos, math_abs = 
      math.sqrt, math.cos, math.sin, math.rad, math.acos, math.abs

local JX_FLASHLIGHT_CONSTANTS =
{
  LIGHT =
  {
    MAX_NUM = TUNING.JX_TUNING.JX_FLASHLIGHT_LIGHTNUM,
    RADIUS = 2,
    FALLOFF = 1,
    INTENSITY = .75,
    COLOUR = { R = 180/255, G = 195/255, B = 150/255 },
    
    LIGHT_1 =  { RADIUS = 0,  THETA = 0       },
    LIGHT_2 =  { RADIUS = 2,  THETA = PI/12   },
    LIGHT_3 =  { RADIUS = 2,  THETA = -PI/12  },
    LIGHT_4 =  { RADIUS = 4,  THETA = PI/12   },
    LIGHT_5 =  { RADIUS = 4,  THETA = -PI/12  },
    LIGHT_6 =  { RADIUS = 6,  THETA = PI/12   },
    LIGHT_7 =  { RADIUS = 6,  THETA = 0       },
    LIGHT_8 =  { RADIUS = 6,  THETA = -PI/12  },
    LIGHT_9 =  { RADIUS = 8,  THETA = PI/12   },
    LIGHT_10 = { RADIUS = 8,  THETA = 0       },
    LIGHT_11 = { RADIUS = 8,  THETA = -PI/12  },
    LIGHT_12 = { RADIUS = 10, THETA = PI/12   },
    LIGHT_13 = { RADIUS = 10, THETA = 0       },
    LIGHT_14 = { RADIUS = 10, THETA = -PI/12  },
  },
  
  SLOWSPEED =  .75,
  FASTSPEED = TUNING.JX_TUNING.jx_flashlight_fastspeed ~= false and 1.25 or 1,
  
  SLOWANGLE = PI,
}

local function onison(self, ison)
  if ison then
    self.inst:AddTag("flashlight_ison")
  else
    self.inst:RemoveTag("flashlight_ison")
  end
end

local Jx_FlashLight = Class(function(self, inst)
  local CONT = JX_FLASHLIGHT_CONSTANTS
  
  self.inst = inst
  
  self.ison = false
  
  self.owner = nil
  
  self.last_pos = nil
  self.last_UpdatePosTime = nil
  self.UpdateInterval = .2
  
  self.slowspeed = JX_FLASHLIGHT_CONSTANTS.SLOWSPEED
  self.fastspeed = JX_FLASHLIGHT_CONSTANTS.FASTSPEED
  self.currentspeed = 1
  self.maxperdelta = (self.fastspeed - self.slowspeed) / ( 1.6 / self.UpdateInterval)
  
  self.lights = {}
  self.max_light = CONT.LIGHT.MAX_NUM
end,
nil,
{
  ison = onison,
})

function Jx_FlashLight:CreateLight()
  for k, v in ipairs(self.lights) do
    if v:IsValid() then
      v:Remove()
    end
    self.lights[k] = nil
  end
  
  local CONST = JX_FLASHLIGHT_CONSTANTS
  local angle = self.owner.Transform:GetRotation()
  local theta = angle ~= nil and math_rad(angle)
  local x, _, z = self.owner.Transform:GetWorldPosition()
  if theta == nil or x == nil or z == nil then return end
  
  for i = 1, self.max_light do
    local light = SpawnPrefab("jx_light")
    if light then
      if light.Light then
        light.Light:SetRadius(CONST.LIGHT.RADIUS)
        light.Light:SetFalloff(CONST.LIGHT.FALLOFF)
        light.Light:SetIntensity(CONST.LIGHT.INTENSITY)
        light.Light:SetColour(CONST.LIGHT.COLOUR.R, CONST.LIGHT.COLOUR.G, CONST.LIGHT.COLOUR.B)
      end
      
      local CONST_LIGHT = CONST.LIGHT["LIGHT_"..tostring(i)]
      local radius = CONST_LIGHT.RADIUS
      local new_theta = theta + CONST_LIGHT.THETA
      local offset_x = radius * math_cos(new_theta)
      local offset_z = -radius * math_sin(new_theta)
      local new_x = x + offset_x
      local new_z = z + offset_z
      light.Transform:SetPosition(new_x, 0, new_z)
      
      self.lights[i] = light
      
      self.inst:DoTaskInTime(0, function()
        if self.owner and self.owner.components.player_jx_flashlight then
          self.owner.components.player_jx_flashlight.lights[i]:set(light)
        end
      end)
    end
  end
end

function Jx_FlashLight:Start(owner)
  local _owner = owner ~= nil and owner:HasTag("player") and owner or nil
  if _owner == nil then
    _owner = self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner()
    if not (_owner and _owner:HasTag("player")) then
      self:Stop()
      return
    end
  end
  
  self.ison = true
  
  self.owner = _owner
  self.last_pos = _owner:GetPosition()
  
  self:CreateLight()
  self.inst:DoTaskInTime(0, function()
    if self.owner and self.owner.userid then
      SendModRPCToClient(GetClientModRPC("JX", "FlashLightStartUpdatePos"), self.owner.userid)
    end
  end)
  
  if self.owner.components.locomotor then
    self.owner.components.locomotor:StartStrafing()
  end
  
  if not (self.owner.components.rider and self.owner.components.rider:IsRiding()) and
    self.owner.sg and self.owner.sg:HasStateTag("moving")
  then
    self.owner.sg:GoToState("run_start_jx_flashlight")
  end
  
  self.inst:StartUpdatingComponent(self)
end

function Jx_FlashLight:RemoveLight()
  for _, v in ipairs(self.lights) do
    if v:IsValid() then
      v:Remove()
    end
  end
  self.lights = {}
end

function Jx_FlashLight:ClearState()
  self:RemoveLight()
  if self.owner == nil then return end
  if self.owner.userid then
    SendModRPCToClient(GetClientModRPC("JX", "FlashLightStopUpdatePos"), self.owner.userid)
  end
  for i = 1, self.max_light do
    if self.owner.components.player_jx_flashlight then
      self.owner.components.player_jx_flashlight.lights[i]:set(nil)
    end
  end
  if self.owner.components.locomotor then
    self.owner.components.locomotor:StopStrafing()
    self.owner.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "jx_flashlight")
  end
  
  self.owner = nil
  self.last_pos = nil
end

function Jx_FlashLight:Stop()
  self.ison = false
  self.inst:StopUpdatingComponent(self)
  if self.owner and not (self.owner.components.rider and self.owner.components.rider:IsRiding()) and
    self.owner.sg and self.owner.sg:HasStateTag("moving")
  then
    self.owner.sg:GoToState("idle")
  end
  self:ClearState()
end

local function Iswithinangle(position, forward, width, testPos)
	local testVec = testPos - position
	testVec = testVec:GetNormalized()
	forward = forward:GetNormalized()
	local testAngle = math_acos(testVec:Dot(forward))
	if math_abs(testAngle) <= .5 * math_abs(width) then
		return true
	else
		return false
	end
end

function Jx_FlashLight:UpdateSpeedMult(pos, rotation)
  if pos ~= nil and self.last_pos ~= nil and self.last_pos ~= pos then
    if self.owner.components.locomotor then
      local facing = Vector3(math_cos(-rotation / RADIANS), 0, math_sin(-rotation / RADIANS))
      if Iswithinangle(pos, -facing, JX_FLASHLIGHT_CONSTANTS.SLOWANGLE, self.last_pos) then
        if self.fastspeed - self.currentspeed <= self.maxperdelta then
          self.currentspeed = self.fastspeed
        elseif self.currentspeed ~= self.fastspeed then
          self.currentspeed = self.currentspeed + self.maxperdelta
        end
      else
        if self.currentspeed - self.slowspeed <= self.maxperdelta then
          self.currentspeed = self.slowspeed
        elseif self.currentspeed ~= self.slowspeed then
          self.currentspeed = self.currentspeed - self.maxperdelta
        end
      end
      self.owner.components.locomotor:SetExternalSpeedMultiplier(self.inst, "jx_flashlight", self.currentspeed)
    end
    self.last_pos = nil
  end
end

function Jx_FlashLight:UpdateLightPosition(pos, rotation)
  local CONST = JX_FLASHLIGHT_CONSTANTS
  local theta = math_rad(rotation)
  local invalid_light
  
  for i = 1, #self.lights do
    local CONST_LIGHT = CONST.LIGHT["LIGHT_"..tostring(i)]
    local radius = CONST_LIGHT.RADIUS
    local new_theta = theta + CONST_LIGHT.THETA
    local offset_x = radius * math_cos(new_theta)
    local offset_z = -radius * math_sin(new_theta)
    local new_x = pos.x + offset_x
    local new_z = pos.z + offset_z
    if self.lights[i] and self.lights[i]:IsValid() then
      self.lights[i].Transform:SetPosition(new_x, 0, new_z)
    else
      invalid_light = true
    end
  end
  
  if invalid_light then
    self:CreateLight()
  end
end

function Jx_FlashLight:UpdatePos(pos)
  local nowtime = GetTime()
  if self.last_UpdatePosTime ~= nil and nowtime - self.last_UpdatePosTime < self.UpdateInterval then
    return
  end
  self.last_UpdatePosTime = nowtime
  self.last_pos = pos
end

function Jx_FlashLight:OnUpdate()
  if self.owner then
    local pos = self.owner:GetPosition()
    local rotation = self.owner.Transform:GetRotation()
    if pos == nil or rotation == nil then return end
    self:UpdateSpeedMult(pos, rotation)
    self:UpdateLightPosition(pos, rotation)
    self:UpdatePos(pos)
  end
end

return Jx_FlashLight