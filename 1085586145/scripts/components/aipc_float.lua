
local Float=Class(function(self,inst)
self.inst=inst
self.targetPos=nil
self.targetInst=nil
self.speed=6
self.ySpeed=6
self.offset=Vector3(0,0,0)

self.arriveCallback=nil
end)


function Float:RotateToTarget(dest)
local angle=aipGetAngle(self.inst:GetPosition(),dest)
self.inst.Transform:SetRotation(angle)
self.inst:FacePoint(dest)
end


function Float:GoToPoint(pt)
self.targetPos=pt
self.targetInst=nil
self.arriveCallbac=nil
self.inst.Physics:Teleport(pt.x,pt.y,pt.z)

self.inst:StartUpdatingComponent(self)
end


function Float:Stop()
self.targetPos=nil
self.targetInst=nil
self.arriveCallback=nil

self.inst:StopUpdatingComponent(self)
self.inst.Physics:Stop()
end


function Float:MoveToPoint(pt,callback)
self.targetPos=pt
self.targetInst=nil
self.arriveCallback=callback
self.inst:StartUpdatingComponent(self)
end

function Float:MoveToInst(inst,callback)
self.targetPos=nil
self.targetInst=inst
self.arriveCallback=callback
self.inst:StartUpdatingComponent(self)
end

function Float:OnUpdate(dt)
local pos=self.inst:GetPosition()
local targetPos=self.targetPos or (
self.targetInst~=nil and self.targetInst:GetPosition()
)

if not targetPos then
return
end


targetPos=targetPos+self.offset


local dist=aipDist(pos,targetPos)
local speed=type(self.speed)=="function" and self.speed(self.inst,dist) or self.speed
if dist < 0.3 then
speed=0.5

if self.arriveCallback~=nil then
self.arriveCallback(self.inst)
end
end


self:RotateToTarget(targetPos)
self.inst.Physics:SetMotorVel(
speed,
(targetPos.y-pos.y)*self.ySpeed,
0
)
end

return Float