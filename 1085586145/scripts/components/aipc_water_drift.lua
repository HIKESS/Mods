local DEFAULT_SPEED=10
local MIN_SPEED=6
local SLOW_SEC_OCEAN=DEFAULT_SPEED*0.25
local SLOW_SEC_LAND=DEFAULT_SPEED*0.5
local MAX_DAMAGE=50


local Drift=Class(function(self,inst)
self.inst=inst
end)

function Drift:Launch(pos,doer)
aipRemove(self.inst)

local piece=aipSpawnPrefab(doer,"aip_oldone_stone_piece",nil,1)
if piece.components.aipc_water_drift~=nil then
piece.components.aipc_water_drift:Throw(pos,doer)
end
end


function Drift:RotateToTarget(dest)
local angle=aipGetAngle(self.inst:GetPosition(),dest)
self.inst.Transform:SetRotation(angle)
self.inst:FacePoint(dest)
end


function Drift:Throw(pos,doer)
self.doer=doer
self.playSpeed=1
self:RotateToTarget(pos)
local dist=aipDist(doer:GetPosition(),pos)
local maxDist=3
local mergedDist=math.min(dist,maxDist)
self.speed=Remap(mergedDist,
0,maxDist,
MIN_SPEED,DEFAULT_SPEED)
self.inst:StartUpdatingComponent(self)
end

function Drift:OnUpdate(dt)

local pos=self.inst:GetPosition()
local slowSec=TheWorld.Map:IsOceanAtPoint(pos.x,pos.y,pos.z,false) and SLOW_SEC_OCEAN or SLOW_SEC_LAND

local slowOffset=dt*slowSec
self.speed=self.speed-slowOffset

self.inst.Physics:SetMotorVel(
self.speed,
0,
0
)


local speedPTG=self.speed/DEFAULT_SPEED
local playSpeed=1
if speedPTG <=0.2 then
playSpeed=2
elseif speedPTG <=0.5 then
playSpeed=1.5
end

if playSpeed~=self.playSpeed then
self.playSpeed=playSpeed
self.inst.AnimState:SetDeltaTimeMultiplier(playSpeed)
end


local ents=TheSim:FindEntities(
pos.x,0,pos.z,
0.6,
{ "_combat","_health" },
{ "INLIMBO","NOCLICK","ghost" }
)
ents=aipFilterTable(ents,function(ent)
return ent~=self.doer
end)

if #ents > 0 then
local damage=(DEFAULT_SPEED-self.speed)/DEFAULT_SPEED*MAX_DAMAGE

for i,v in ipairs(ents) do
if
v.components.combat~=nil and
v.components.health~=nil and
not v.components.health:IsDead()
then
v.components.combat:GetAttacked(self.doer,damage)
end
end
end


if self.speed <=0 or #ents > 0 then
self.inst:StopUpdatingComponent(self)


local ents=aipFindNearEnts(self.inst,{"aip_oldone_lotus"},20)
for i,ent in ipairs(ents) do
if ent._aipCheckDrift~=nil then
ent._aipCheckDrift(ent,self.inst,self.doer)
end
end


aipReplacePrefab(self.inst,"collapse_small")
end
end

return Drift