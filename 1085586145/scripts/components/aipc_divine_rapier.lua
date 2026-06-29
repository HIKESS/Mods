

local STATUS_ROUNDING=0
local STATUS_GUARDING=1
local STATUS_ATTACKING=2
local STATUS_ATTACK_AWAY=3


local FAR_AWAY_DIST=8

local DivineRapier=Class(function(self,inst)
self.inst=inst


self.guardTarget=nil


self.attackTarget=nil


self.hitPt=nil


self.roundTime=1


self.roundDist=2


self.roundingTime=0


self.weapon=nil

self.status=STATUS_ATTACKING

self.onUse=nil


self.index=0
self.total=1
end)

function DivineRapier:GetRoundPt()

local now=GetTime()


local offsetRotate=360/self.total*self.index


local rotate=(now % self.roundTime)*(360/self.roundTime)+offsetRotate
local radius=rotate/180*PI

local pos=self.guardTarget:GetPosition()


local tgtPt=Vector3(
pos.x+math.cos(radius)*self.roundDist,
0,
pos.z+math.sin(radius)*self.roundDist
)

return tgtPt
end

function DivineRapier:Setup(guardTarget,index,total,weapon)
self.guardTarget=guardTarget
self.index=index
self.total=total
self.weapon=weapon

local tgtPt=self:GetRoundPt()
self.inst:ForceFacePoint(tgtPt.x,tgtPt.y,tgtPt.z)

self.status=STATUS_ROUNDING
self.inst:StartUpdatingComponent(self)
end

function DivineRapier:GetDamage(target)
if self.weapon~=nil and self.weapon.components.weapon~=nil then
return self.weapon.components.weapon:GetDamage(self.guardTarget,target)
end

return 17
end


function DivineRapier:GetAngleSpeed()
return 360/self.roundTime
end


function DivineRapier:GetLineSpeed()
local angleSpeed=self:GetAngleSpeed()
local rotateSpeed=angleSpeed/180*PI
return rotateSpeed*self.roundDist
end

function DivineRapier:Attack(target)
if aipCanAttack(target,self.guardTarget,true) then
self.attackTarget=target

self.status=STATUS_ATTACKING
end
end


function DivineRapier:EnsureAttackTarget()
if not aipCanAttack(self.attackTarget,self.guardTarget,true) then
local RETARGET_MUST_TAGS={ "_combat","_health" }
local RETARGET_CANT_TAGS={ "INLIMBO","player","engineering" }

local x,y,z=self.guardTarget.Transform:GetWorldPosition()
local ents=TheSim:FindEntities(
x,y,z,
16,RETARGET_MUST_TAGS,RETARGET_CANT_TAGS
)
ents=aipFilterTable(ents,function(ent)
return aipCanAttack(ent,self.guardTarget)
end)

self.attackTarget=ents[1]
end

return self.attackTarget
end


function DivineRapier:OnTargetUpdate(targetPt,dt)
local oriAngle=self.inst:GetRotation()
local tgtAngle=self.inst:GetAngleToPoint(targetPt.x,targetPt.y,targetPt.z)

local dist=aipDist(self.inst:GetPosition(),targetPt)


local angleSpeedPerSec=360/self.roundTime
if dist < FAR_AWAY_DIST/2 then
angleSpeedPerSec=angleSpeedPerSec*2
end

local angle=aipToAngle(oriAngle,tgtAngle,dt*angleSpeedPerSec)
self.inst.Transform:SetRotation(angle)


self.inst.Physics:SetMotorVel(self:GetLineSpeed()*2,0,0)


return dist
end


function DivineRapier:OnFollowUpdate(dt)
local roundPt=self:GetRoundPt()
local dist=self:OnTargetUpdate(roundPt,dt)

if dist < 3 then
self.roundingTime=0

local target=self:EnsureAttackTarget()

if target~=nil then
self.status=STATUS_ATTACKING
else
self.status=STATUS_ROUNDING
end
end
end


function DivineRapier:OnAttackUpdate(dt)
local target=self:EnsureAttackTarget()

if target then
local targetPt=target:GetPosition()
local dist=self:OnTargetUpdate(targetPt,dt)

if dist < 1 then
target.components.combat:GetAttacked(self.guardTarget,self:GetDamage(target))

if self.onUse~=nil then
self.onUse()
end

self.status=STATUS_ATTACK_AWAY
end
else
self.status=STATUS_GUARDING
end

self.hitPt=self.inst:GetPosition()
end


function DivineRapier:OnAttackAwayUpdate(dt)
local currentPos=self.inst:GetPosition()
local dist=aipDist(currentPos,self.hitPt)
local targetDist=self.attackTarget and aipDist(currentPos,self.attackTarget:GetPosition()) or 999999

if dist > FAR_AWAY_DIST and targetDist > FAR_AWAY_DIST then
self.status=STATUS_ATTACKING
end

self.inst.Physics:SetMotorVel(self:GetLineSpeed()*2,0,0)
end


function DivineRapier:OnRoundUpdate(dt)
local oriAngle=self.inst:GetRotation()

self.roundingTime=self.roundingTime+dt



if self.roundingTime > self.roundTime/2 then
local target=self:EnsureAttackTarget()
if target then
local angle=self.inst:GetAngleToPoint(target:GetPosition())
local diffAngle=aipDiffAngle(angle,oriAngle)

if diffAngle < 30 then
self.status=STATUS_ATTACKING
return
end
end
end


local currentPos=self.inst:GetPosition()
local roundPt=self:GetRoundPt()
local guardPt=self.guardTarget:GetPosition()

local dist=aipDist(currentPos,roundPt)


local angleSpeedPerSec=360/self.roundTime
angleSpeedPerSec=angleSpeedPerSec*2


self.inst:ForceFacePoint(guardPt.x,guardPt.y,guardPt.z)
local tgtAngle=self.inst:GetRotation()+90
local angle=aipToAngle(oriAngle,tgtAngle,dt*angleSpeedPerSec)
self.inst.Transform:SetRotation(angle)


local speed=dist*10
local faceAngle=self.inst:GetAngleToPoint(roundPt.x,roundPt.y,roundPt.z)
local faceX=math.cos(faceAngle/180*PI)*speed
local faceZ=-math.sin(faceAngle/180*PI)*speed


local corrected_vel_x,corrected_vel_z=VecUtil_RotateDir(faceX,faceZ,self.inst.Transform:GetRotation()*DEGREES)
self.inst.Physics:SetMotorVel(corrected_vel_x,0,corrected_vel_z)
end

function DivineRapier:OnUpdate(dt)
if self.status==STATUS_ATTACKING then
self:OnAttackUpdate(dt)
elseif self.status==STATUS_ATTACK_AWAY then
self:OnAttackAwayUpdate(dt)
elseif self.status==STATUS_GUARDING then
self:OnFollowUpdate(dt)
else
self:OnRoundUpdate(dt)
end
end

return DivineRapier