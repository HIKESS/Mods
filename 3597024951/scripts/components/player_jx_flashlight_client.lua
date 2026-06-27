--///////////////////////////////////////////////////
--这是一个给玩家用的客户端组件
--主要作用是：
--创建本地的手电筒光源视觉特效（克服延迟补偿）
--////////////////////////////////////////////////////

local JX_FLASHLIGHT_CONSTANTS =
{
  --这个表与 jx_flashlight 组件中的同名表保持一致
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
}

local function CreateLight()
    local inst = CreateEntity()
    inst.persists = false
    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst:AddTag("FX")
    return inst
end

local Player_Jx_FlashLight_Client = Class(function(self, inst)
  self.inst = inst
  self.light = {}
  self.max_light = JX_FLASHLIGHT_CONSTANTS.LIGHT.MAX_NUM
end)

function Player_Jx_FlashLight_Client:CreateLight()
  for k, v in ipairs(self.light) do
    if v:IsValid() then
      v:Remove()
    end
    self.light[k] = nil
  end
  
  local CONST = JX_FLASHLIGHT_CONSTANTS
  local theta = math.rad(self.inst.Transform:GetRotation())
  local x, _, z = self.inst.Transform:GetWorldPosition()
  
  for i = 1, self.max_light do
    local light = CreateLight()
    if light then
      light.Light:SetRadius(CONST.LIGHT.RADIUS)
      light.Light:SetFalloff(CONST.LIGHT.FALLOFF)
      light.Light:SetIntensity(CONST.LIGHT.INTENSITY)
      light.Light:SetColour(CONST.LIGHT.COLOUR.R, CONST.LIGHT.COLOUR.G, CONST.LIGHT.COLOUR.B)
      
      local CONST_LIGHT = CONST.LIGHT["LIGHT_"..tostring(i)]
      local radius = CONST_LIGHT.RADIUS
      local new_theta = theta + CONST_LIGHT.THETA
      local offset_x = radius * math.cos(new_theta)
      local offset_z = -radius * math.sin(new_theta)
      local new_x = x + offset_x
      local new_z = z + offset_z
      light.Transform:SetPosition(new_x, 0, new_z)
      
      self.light[i] = light
    end
  end
end

function Player_Jx_FlashLight_Client:RemoveLight()
  for _, v in pairs(self.light) do
    if v:IsValid() then
      v:Remove()
    end
  end
  self.light = {}
end

function Player_Jx_FlashLight_Client:Start()
  self:CreateLight()
  self.inst:StartUpdatingComponent(self)
end

function Player_Jx_FlashLight_Client:Stop()
  self.inst:StopUpdatingComponent(self)
  self:RemoveLight()
end

function Player_Jx_FlashLight_Client:UpdateLightPosition(pos, rotation)
  local CONST = JX_FLASHLIGHT_CONSTANTS
  local theta = math.rad(rotation)
  if theta == nil or pos == nil then return end
  
  local invalid_light
  for i = 1, #self.light do
    local CONST_LIGHT = CONST.LIGHT["LIGHT_"..tostring(i)]
    local radius = CONST_LIGHT.RADIUS
    local new_theta = theta + CONST_LIGHT.THETA
    local offset_x = radius * math.cos(new_theta)
    local offset_z = -radius * math.sin(new_theta)
    local new_x = pos.x + offset_x
    local new_z = pos.z + offset_z
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

function Player_Jx_FlashLight_Client:OnUpdate()
  local pos = self.inst:GetPosition()
  local rotation = self.inst.Transform:GetRotation()
  if pos == nil or rotation == nil then return end
  self:UpdateLightPosition(pos, rotation)
end

return Player_Jx_FlashLight_Client