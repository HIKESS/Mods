local Jx_Driver_Camera = Class(function(self, inst)
  self.inst = inst
  
  self.enabled = false
  self.inst:DoTaskInTime(0, function() 
    self:SaveCamera()
  end)
end)

function Jx_Driver_Camera:Enable()
  if not self.enabled then
    self.enabled = true
    self.inst:StartUpdatingComponent(self)
  end
end

function Jx_Driver_Camera:Disable()
  if self.enabled then
    self.enabled = false
    self.inst:StopUpdatingComponent(self)
    
    local angle = self.inst:GetRotation()
    local snapped = math.floor((angle + 22.5) / 45) * 45
    local camera_angle = (180 - snapped) % 360
    TheCamera:SetHeadingTarget(camera_angle)
  end
end

function Jx_Driver_Camera:SaveCamera()
  self.camera_fov = TheCamera.fov
end

function Jx_Driver_Camera:LoadCamera()
  TheCamera.fov = self.camera_fov
end

function Jx_Driver_Camera:OnUpdate(dt)
  if not ThePlayer or not TheCamera then
    return
  end
  TheCamera:SetHeadingTarget((180 - ThePlayer.Transform:GetRotation()) % 360)
end

return Jx_Driver_Camera