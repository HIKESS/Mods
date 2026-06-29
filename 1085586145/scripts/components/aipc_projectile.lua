
local Projectile=Class(function(self,inst)
self.inst=inst
self.target=nil
self.targetPos=nil
self.speed=6
self.onFinish=nil
end)


function Projectile:GoToTarget(target,callback)
self.target=target
self.targetPos=self.target:GetPosition()

self.onFinish=callback

self:Start()
end


function Projectile:GoToPoint(targetPos,callback)
self.target=nil
self.targetPos=targetPos

self.onFinish=callback

self:Start()
end


function Projectile:Start()
self.inst:StartUpdatingComponent(self)
self.inst.Physics:SetMotorVel(self.speed,0,0)
end


function Projectile:RotateToTarget(dest)
local angle=aipGetAngle(self.inst:GetPosition(),dest)
self.inst.Transform:SetRotation(angle)
self.inst:FacePoint(dest)
end

function Projectile:OnFinish()
self.inst:StopUpdatingComponent(self)
self.inst.Physics:SetMotorVel(0,0,0)

if self.onFinish~=nil then
self.onFinish(self.inst,self.target or self.targetPos)
end

if self.inst.OnFinish~=nil then
self.inst.OnFinish(self.inst)
end

self.inst:Remove()
end

function Projectile:OnUpdate(dt)
if self.target~=nil and (not self.target:IsValid() or self.target:IsInLimbo()) then

self:OnFinish()
return
elseif self.target~=nil then

self.targetPos=self.target:GetPosition()
end

self:RotateToTarget(self.targetPos)

if aipDist(self.inst:GetPosition(),self.targetPos) < 0.3 then
self:OnFinish()
end
end

return Projectile