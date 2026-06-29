local fly_totem=aipGetModConfig("fly_totem")
local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local function ActionButton(inst,force_target)
return
end

local function FlyActionFilter(inst,action)
return false
end


local function DoTalk(inst,str)
if inst.components.talker then
inst.components.talker:Say(str)
end
end


local function IsNearDanger(inst)

local hounded=TheWorld.components.hounded
if hounded~=nil and (hounded:GetWarning() or hounded:GetAttacking()) then
return true
end


local burnable=inst.components.burnable
if burnable~=nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
return true
end


return FindEntity(
inst,
10,
function(target)
return (
target.components.combat~=nil and
target.components.combat.target==inst and
target.prefab~="shadowtentacle"
) or (
target:HasTag("monster") and not target:HasTag("player")
)
end,
nil,
nil,
{ "monster","_combat" })~=nil
end



local Flyer=Class(function(self,inst)
self.inst=inst
self.target=nil
self.targetPos=nil

self.speed=dev_mode and 10 or 25
self.maxSpeed=dev_mode and 30 or 100
self.speedUpRange=300
self.oriDistance=0
self.lastDistance=0

self.height=1

self.color={}


self.syncSpeed=net_float(inst.GUID,"aipc_flyer_height")
self.isFlying=net_bool(inst.GUID,"aipc_flyer_flying","aipc_flyer_flying_dirty")

if TheWorld.ismastersim then
self.syncSpeed:set(0)
self.isFlying:set(false)
end

self.inst:ListenForEvent("aipc_flyer_flying_dirty",function()

if self.inst==ThePlayer then
if self:IsFlying() then
TheCamera:SetFlyView(true)
self.inst:StartUpdatingComponent(self)
else
TheCamera:SetFlyView(false)
self.inst:StopUpdatingComponent(self)
end
end
end)
end)

function Flyer:IsFlying()
return self.isFlying:value()
end

function Flyer:RotateToTarget(dest)



self.inst:ForceFacePoint(dest.x,0,dest.z)
end

function Flyer:FlyTo(target)
local instPos=self.inst:GetPosition()
self.target=target
self.targetPos=aipGetSpawnPoint(target:GetPosition(),0.1)


if self.targetPos==nil then
self.targetPos=target:GetPosition()
end

self.oriDistance=instPos:Dist(self.targetPos)
self.lastDistance=self.oriDistance


if fly_totem=='teleport' or fly_totem=='fly' then
if IsNearDanger(self.inst) then
DoTalk(self.inst,STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_FLY_TOTEM_IN_DANGER)
return
end
end


if self.inst.components.sanity and self.inst.components.sanity.current < 10 then
DoTalk(self.inst,STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_FLY_TOTEM_CRAZY)
return
end



local effect=SpawnPrefab("aip_eagle_effect")
effect.Transform:SetPosition(self.inst.Transform:GetWorldPosition())


if self.inst.components.sanity then
self.inst.components.sanity:DoDelta(-10)
end


if fly_totem=='teleport' or fly_totem=='teleport_anyway' then
self.inst.Transform:SetPosition(self.targetPos.x,self.targetPos.y,self.targetPos.z)
return
end


RemovePhysicsColliders(self.inst)
self.inst.Physics:Stop()
self.inst.Physics:SetVel(0,0,0)
self.inst.Physics:SetMotorVel(0,0,0)


if self.inst.components.drownable then
self.inst.components.drownable.enabled=false
end


if self.inst.components.playercontroller~=nil then
self.inst.components.playercontroller.actionbuttonoverride=ActionButton
self.inst.components.playercontroller:Enable(false)
end

if self.inst.components.playeractionpicker~=nil then
self.inst.components.playeractionpicker:PushActionFilter(FlyActionFilter,999)
end


self.color[1],self.color[2],self.color[3],self.color[4]=self.inst.AnimState:GetMultColour()
self.inst.AnimState:SetMultColour(0,0,0,0)
self.inst.DynamicShadow:Enable(false)


self.inst:StartUpdatingComponent(self)

self.isFlying:set(true)
end

function Flyer:End(target)
self.inst:StopUpdatingComponent(self)

if self.inst.components.drownable then
self.inst.components.drownable.enabled=true
end

if self.inst.components.playercontroller~=nil then
self.inst.components.playercontroller.actionbuttonoverride=nil
self.inst.components.playercontroller:Enable(true)
end

if self.inst.components.playeractionpicker~=nil then
self.inst.components.playeractionpicker:PopActionFilter(FlyActionFilter,999)
end

if self.inst.components.locomotor then
self.inst.components.locomotor:Stop()
end


local r,g,b=self.inst.AnimState:GetMultColour()
self.inst.AnimState:SetMultColour(
self.color[1] or 1,
self.color[2] or 1,
self.color[3] or 1,
self.color[4] or 1
)
self.inst.DynamicShadow:Enable(true)


local effect=aipSpawnPrefab(self.inst,"aip_shadow_wrapper")
effect.DoShow()

self.inst.Physics:SetMotorVel(0,-5,0)


self.inst:DoTaskInTime(1,function()
ChangeToCharacterPhysics(self.inst)
end)

self.isFlying:set(false)
end



function Flyer:OnServerUpdate(dt)
if self.target==nil or (self.inst.components.health and self.inst.components.health:IsDead()) then

self:End()
else

RemovePhysicsColliders(self.inst)


local instPos=self.inst:GetPosition()
local pos=self.targetPos


self:RotateToTarget(pos)
local speed=self.speed

local distance=instPos:Dist(pos)
local passedDist=self.oriDistance-distance

if self.oriDistance > self.speedUpRange*2 then


if passedDist < self.speedUpRange then

speed=Remap(passedDist,0,self.speedUpRange,self.speed,self.maxSpeed)
elseif distance > self.speedUpRange then

speed=self.maxSpeed
else

speed=Remap(distance,0,self.speedUpRange,self.speed,self.maxSpeed)
end
else

local halfDistance=self.oriDistance/2
if passedDist < halfDistance then

speed=Remap(passedDist,0,self.speedUpRange,self.speed,self.maxSpeed)
else

speed=Remap(distance,0,self.speedUpRange,self.speed,self.maxSpeed)
end
end

local ySpeed=(self.height-instPos.y)*10+1
self.syncSpeed:set(speed)

self.inst.Physics:SetMotorVel(speed,ySpeed,0)

if
distance < 2 or
(distance < 8 and self.lastDistance < distance)
then
self:End()
else
self:RotateToTarget(pos)
end

self.lastDistance=distance
end
end



function Flyer:OnClientUpdate(dt)
if self:IsFlying() then
local x,y,z=self.inst.Transform:GetWorldPosition()

for i=1,3 do
local effect=SpawnPrefab("aip_fly_totem_effect")
effect.Transform:SetScale(0.5,0.5,0.5)
effect.Transform:SetPosition(
x+.5-math.random()*1,
y+.5-math.random()*1,
z+.5-math.random()*1
)
end
end
end

function Flyer:OnUpdate(dt)
if TheWorld.ismastersim then
self:OnServerUpdate(dt)
end

if not TheNet:IsDedicated() then
self:OnClientUpdate(dt)
end
end

return Flyer