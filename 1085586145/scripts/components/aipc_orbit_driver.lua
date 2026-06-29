
local language=aipGetModConfig("language")


local LANG_MAP={
english={
EXIT="Arrow key to move. X to exit. V to switch view.",
},
chinese={
EXIT="方向键控制，X 键退出，V 键切换视角",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_MINECAR_EXIT=LANG.EXIT


local function onFlyDirty(inst)
if
inst.components.aipc_flyer_sc~=nil and
not inst.components.aipc_flyer_sc:IsFlying() and
inst.components.aipc_orbit_driver~=nil
then
inst.components.aipc_orbit_driver:TryContinue()
end
end



local function findClosestPoint(inst)
local linkList=aipFindNearEnts(inst,{ "aip_glass_orbit_point" },3)
return linkList[1]
end

local function findPoints(current,excluded)
local linkList=aipFindNearEnts(current,{ "aip_glass_orbit_link" },25)

local includedLinks=aipFilterTable(linkList,function(link)
return link.components.aipc_orbit_link~=nil and
link.components.aipc_orbit_link:Includes(current) and
not link.components.aipc_orbit_link:Includes(excluded)
end)

local orbitPointList={}

for i,link in ipairs(includedLinks) do
local anotherPoint=link.components.aipc_orbit_link:GetAnother(current)
table.insert(orbitPointList,anotherPoint)
end

return orbitPointList
end


local Driver=Class(function(self,player)
self.inst=player
self.minecar=nil
self.orbitPoint=nil
self.nextOrbitPoint=nil
self.speed=15
self.speedMulti=0.25
self.ySpeed=20

self.lastRotate=nil

self.inst:ListenForEvent("aipc_flyer_flying_dirty",onFlyDirty)


local function stopDrving()
self:AbortDrive()
end

self.inst:ListenForEvent("death",stopDrving)
self.inst:ListenForEvent("attacked",stopDrving)
self.inst:ListenForEvent("onsink",stopDrving)
end)


function Driver:IsInvalidDriver()
if
(self.inst.components.health~=nil and self.inst.components.health:IsDead())
or not self.inst:IsValid()
or self.inst:IsInLimbo()
then
return true
end

return false
end

function Driver:CanDrive()
return self:IsInvalidDriver()==false and self.minecar~=nil
end

function Driver:UseMineCar(minecar,orbitPoint)
if self:IsInvalidDriver() or minecar==nil then
return false
end

self.minecar=minecar
self.orbitPoint=orbitPoint


if self.inst.components.talker~=nil then
self.inst.components.talker:Say(
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_MINECAR_EXIT
)
end


local pt=orbitPoint:GetPosition()
self.minecar:Hide()

self.inst.Physics:Teleport(pt.x,pt.y,pt.z)
self.inst.sg:GoToState("aip_drive")
self.inst:AddTag("aip_orbit_driver")

MakeGhostPhysics(self.inst,1,.5)

self.inst.components.aipc_orbit_driver_client.isDriving:set(true)

return true
end

function Driver:isDriving()
return self.minecar~=nil
end


function Driver:TryContinue()
if self:isDriving() then
local orbitPoint=findClosestPoint(self.inst)

if orbitPoint~=nil then
self.orbitPoint=orbitPoint

local nextPoints=findPoints(orbitPoint)
if #nextPoints==1 then
self.nextOrbitPoint=nextPoints[1]

local pt=self.orbitPoint:GetPosition()
self.inst.Physics:Teleport(pt.x,pt.y,pt.z)


self.inst:StartUpdatingComponent(self)
end

else
self:AbortDrive()
end
end
end



function Driver:DriveFromPoint(angle)
self.nextOrbitPoint=nil
self.lastRotate=nil


local orbitPointList=findPoints(self.orbitPoint)


local targetPoint=nil
local minAngle=90
local srcOrbitPointPos=self.orbitPoint:GetPosition()

for i,anotherPoint in ipairs(orbitPointList) do
local toPointAngle=aipGetAngle(srcOrbitPointPos,anotherPoint:GetPosition())
local diffAngle=aipDiffAngle(angle,toPointAngle)

if diffAngle < minAngle then
minAngle=diffAngle
targetPoint=anotherPoint
end
end


if targetPoint==nil then
return
end


self.nextOrbitPoint=targetPoint

self.inst:StartUpdatingComponent(self)
end


function Driver:DriveBack(angle)
local orbitAngle=aipGetAngle(self.orbitPoint:GetPosition(),self.nextOrbitPoint:GetPosition())

if aipDiffAngle(angle,orbitAngle) > 90 then
local tmpOrbitPoint=self.nextOrbitPoint
self.nextOrbitPoint=self.orbitPoint
self.orbitPoint=tmpOrbitPoint
self.lastRotate=nil
end
end

function Driver:DriveTo(x,z,exit)
if not self:CanDrive() then
return
end


if exit then
self:AbortDrive()
return
end

local angle=aipGetAngle(Vector3(0,0,0),Vector3(x,0,z))

if self.nextOrbitPoint==nil then
self:DriveFromPoint(angle)
else
self:DriveBack(angle)
end
end

function Driver:StopDrive()
self.inst:StopUpdatingComponent(self)
self.inst.Physics:Stop()
end

function Driver:AbortDrive()
self:StopDrive()
self.inst:RemoveTag("aip_orbit_driver")
MakeCharacterPhysics(self.inst,75,.5)


if self.minecar~=nil then
self.inst.sg:GoToState("idle")

local pt=self.inst:GetPosition()
self.minecar:Show()
self.inst.Physics:Teleport(pt.x,pt.y,pt.z)
self.minecar.Physics:Teleport(pt.x,pt.y,pt.z)

self.minecar:RemoveTag("NOCLICK")
self.minecar:RemoveTag("fx")

if self.minecar.components.lootdropper~=nil then
self.minecar.components.lootdropper:FlingItem(self.minecar,pt)
end

if self.minecar.components.inventoryitem~=nil then
self.minecar.components.inventoryitem.canbepickedup=true
end


if self.minecar.components.finiteuses~=nil then
self.minecar.components.finiteuses:Use()

if self.minecar.components.finiteuses:GetUses() <=0 then
aipReplacePrefab(self.minecar,"collapse_big")
end
end
end


self.minecar=nil
self.orbitPoint=nil
self.nextOrbitPoint=nil

self.inst.components.aipc_orbit_driver_client.isDriving:set(false)
end

function Driver:OnUpdate(dt)

if
self.inst.components.aipc_flyer_sc~=nil and
self.inst.components.aipc_flyer_sc:IsFlying()
then
self:StopDrive()
return
end

local hackY=0.05
local hackOffsetY=0.1

local pos=self.inst:GetPosition()
local sourcePos=self.orbitPoint~=nil and self.orbitPoint:GetPosition() or nil


if
self.orbitPoint~=nil and
self.nextOrbitPoint==nil and
sourcePos.y > hackY
then
local targetY=sourcePos.y+hackOffsetY
self.inst.Physics:SetMotorVel(0,(targetY-pos.y)*self.ySpeed,0)
return
end


if self.orbitPoint==nil or self.nextOrbitPoint==nil then
self:StopDrive()
return
end


local targetPos=self.nextOrbitPoint:GetPosition()

local totalDist=aipDist(sourcePos,targetPos)
local currentDist=aipDist(pos,sourcePos)
local targetY=sourcePos.y+(targetPos.y-sourcePos.y)*currentDist/totalDist


if targetY > hackY then
targetY=targetY+hackOffsetY
end


local speedX=self.speed
if targetPos.y > sourcePos.y then
speedX=speedX-self.speed*self.speedMulti
elseif targetPos.y < sourcePos.y then
speedX=speedX+self.speed*self.speedMulti
end


if
self.inst.components.timer~=nil and
self.inst.components.timer:TimerExists("aip_reading_sign")
then
speedX=speedX*0.4
end


local ySpeed=(targetY-pos.y)*self.ySpeed
self.inst:ForceFacePoint(targetPos.x,0,targetPos.z)
self.inst.Physics:SetMotorVel(speedX,ySpeed,0)


local rotate=self.inst.Transform:GetRotation()
local largeTurn=false

if self.lastRotate~=nil then
local rotateDiff=rotate-self.lastRotate
rotateDiff=(rotateDiff+360+180) % 360-180
largeTurn=math.abs(rotateDiff) > 90
end


local playerPos=self.inst:GetPosition()
local dist=aipDist(playerPos,targetPos)

if dist < .2 or largeTurn then

self.minecar.Physics:Teleport(targetPos.x,targetPos.y,targetPos.z)

local points=findPoints(self.nextOrbitPoint,self.orbitPoint)
local lastRotate=self.lastRotate
self.orbitPoint=self.nextOrbitPoint
self.nextOrbitPoint=nil
self.lastRotate=nil

if #points==1 then
self.nextOrbitPoint=points[1]

local nextPoint=self.nextOrbitPoint:GetPosition()
self.inst:ForceFacePoint(nextPoint.x,0,nextPoint.z)

else

self.inst.Physics:Teleport(targetPos.x,playerPos.y,targetPos.z)
self.inst.Physics:SetMotorVel(0,ySpeed,0)

if lastRotate~=nil then
self.inst.Transform:SetRotation(lastRotate)
end


if targetPos.y <=hackY then
self:StopDrive()
return
end
end
else
self.lastRotate=rotate
end
end

return Driver