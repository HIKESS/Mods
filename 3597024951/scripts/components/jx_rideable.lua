local Jx_Rideable = Class(function(self, inst)
    self.inst = inst
    
    self.driver = nil
    
    self.maxhealth = 2000
    self.currenthealth = self.maxhealth
    self.invincible = false
    
    self.combat_damagetakenmult = 0
    
    self.org_extra_light = 6
    self.extra_light = self.org_extra_light
    
    self.colour = 0 --0为初始，1为改装
    
    self.engine_parts = false
    
    self.music_parts = false
    
    self.wheel_parts = false
    
    self.camera_follow_mode = false
    self.camera_auto_mode = false
end)

function Jx_Rideable:OnSave()
  return { health = self.currenthealth }
end

function Jx_Rideable:OnLoad(data)
  if data and data.health ~= nil then
    self:SetVal(data.health)
  end
end

function Jx_Rideable:Explosion(pos, noloot)
  local real_pos = pos or self.inst:GetPosition()
  local fx = SpawnPrefab("jx_car_explosion")
  if fx then
    fx.Transform:SetPosition(pos:Get())
  end
  
  local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 5, {"player"})
  for _, v in pairs(ents) do
    if v.components.health and not v.components.health:IsDead() then
      v:PushEvent("knockback", { knocker = self.inst, radius = 5, })
      if v.components.combat then
        v.components.combat:GetAttacked(nil, 100)
      end
    end
  end
  
  if self.inst.components.container then
    self.inst.components.container:DropEverything()
  end
  
  self.inst.AnimState:SetMultColour(1, 1, 1, 0)
  self.inst:DoTaskInTime(2 * FRAMES,function()
    if self.inst:IsValid() then
      if noloot ~= true and self.inst.components.workable then
        self.inst.components.workable:Destroy(self.inst)
      else
        self.inst:Remove()
      end
    end
  end)
end

function Jx_Rideable:SetMaxHealth(amount)
  self.maxhealth = amount
  self.currenthealth = amount
end

function Jx_Rideable:SetVal(val)
  local old_health = self.currenthealth
  local max_health = self.maxhealth
  
  if val > max_health then
    val = max_health
  end
  
  self.currenthealth = val
  
  if old_health > 0 and self.currenthealth <= 0 then
    if self.driver and self.driver.components.jx_driver then
      self.driver.components.jx_driver:Explosion()
    else
      self:Explosion(self.inst:GetPosition())
    end
  end
end

function Jx_Rideable:GetPercent()
  return self.currenthealth / self.maxhealth
end

function Jx_Rideable:SetPercent(percent)
  self:SetVal(self.maxhealth * percent)
  self:DoDelta(0)
end

function Jx_Rideable:DoDelta(amount)
  if amount < 0 and self.invincible then
    return
  end
  
  local old_percent = self:GetPercent()
  
  self:SetVal(self.currenthealth + amount)
  
  local jx_driver_comp = self.driver and self.driver.components.jx_driver
  if jx_driver_comp then
    local hit = amount < 0
    jx_driver_comp:UpdateHealth(hit)
  end
    
  --self.inst:PushEvent("jx_car_healthdelta", { oldpercent = old_percent, newpercent = self:GetPercent() })
end

function Jx_Rideable:DoColour(val, noanim)
  self.colour = val or self.colour
  if self.colour == 1 then
    if noanim then
      self.inst.AnimState:SetBuild("jx_car_2")
    else
      self.inst.sg:GoToState("do_colour")
    end
  end
end

return Jx_Rideable