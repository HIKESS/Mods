local dev_mode=aipGetModConfig("dev_mode")=="enabled"














local abilities={
painful=20,
vampire=10,
week=10,
blood=10,
repair=10,
free=10,
back=10,
slow=10,
}



local function OnIsDay(inst,isday)
if
isday and
inst.components.aipc_snakeoil~=nil and
inst.components.aipc_snakeoil.ability=="repair"
then
if inst.components.finiteuses~=nil then

local ptg=inst.components.finiteuses:GetPercent()
inst.components.finiteuses:SetPercent(
math.min(1,ptg+0.05)
)
elseif inst.components.perishable~=nil then

local ptg=inst.components.perishable:GetPercent()
inst.components.perishable:SetPercent(
math.min(1,ptg+0.05)
)
end
end
end

local function OnEquipped(inst,data)

if
data and data.owner and
data.owner.components.locomotor and
inst.components.aipc_snakeoil~=nil and
inst.components.aipc_snakeoil.ability=="free"
then
local multi=dev_mode and 3 or 1.25
data.owner.components.locomotor:SetExternalSpeedMultiplier(inst,"aipc_snakeoil_free",multi)
end
end

local function OnUnequipped(inst,data)

if data and data.owner and data.owner.components.locomotor then
data.owner.components.locomotor:RemoveExternalSpeedMultiplier(inst,"aipc_snakeoil_free")
end
end


local SnakeOil=Class(function(self,inst)
self.inst=inst
self.owner=nil
self.lock=0

self.ability=""

self.inst:WatchWorldState("isday",OnIsDay)
self.inst:ListenForEvent("equipped",OnEquipped)
self.inst:ListenForEvent("unequipped",OnUnequipped)

self.inst:AddTag("aip_snakeoil_target")
end)


function SnakeOil:SyncAbility()
if self.inst.replica.aipc_snakeoil then
self.inst.replica.aipc_snakeoil:Sync(self.ability)
end
end


function SnakeOil:RandomAbility()
self.ability=aipRandomLoot(abilities)

if dev_mode then
self.ability="painful"
end


self:SyncAbility()

return self.ability
end



aipBufferRegister("aip_snakeoil_week",{
name="week",
showFX=true,

startFn=function(source,inst,info)
if inst.components.combat~=nil then
inst.components.combat:aipMultiDamages("aip_snakeoil_week",-0.5)
end
end,

endFn=function(source,inst)
if inst.components.combat~=nil then
inst.components.combat:aipMultiDamages("aip_snakeoil_week",nil)
end
end
})


aipBufferRegister("aip_snakeoil_blood",{
name="blood",
showFX=false,

fn=function(source,inst,info)
if inst.components.health~=nil and info.tickTime % 2==0 then
inst.components.health:DoDelta(-5)
end
end,
})


aipBufferRegister("aip_snakeoil_slow",{
name="slow",
showFX=true,

startFn=function(source,inst,info)
if inst.components.locomotor~=nil then
inst.components.locomotor:SetExternalSpeedMultiplier(inst,"aip_snakeoil_slow",0.5)
end
end,

endFn=function(source,inst)
if inst.components.locomotor~=nil then
inst.components.locomotor:RemoveExternalSpeedMultiplier(inst,"aip_snakeoil_slow")
end
end
})


function SnakeOil:OnWeaponAttack(attacker,target,projectile)
local now=GetTime()

if not target or now-self.lock < 0.1 then
return
end


self.lock=now

if self.ability=="painful" then
if target.components.combat then
target.components.combat:GetAttacked(attacker,10)
end

elseif self.ability=="vampire" then
if attacker.components.health then
attacker.components.health:DoDelta(5)
end

elseif self.ability=="week" then
aipBufferPatch(attacker,target,"aip_snakeoil_week",10)

elseif self.ability=="blood" then
aipBufferPatch(attacker,target,"aip_snakeoil_blood",11)

elseif self.ability=="back" and target.Physics then
local attackerPT=attacker:GetPosition()
local angle=aipGetAngle(attackerPT,target:GetPosition())
local tgtPT=aipAngleDist(attackerPT,angle,3)


target.Physics:Stop()
target.Physics:Teleport(tgtPT:Get())

elseif self.ability=="slow" then
aipBufferPatch(attacker,target,"aip_snakeoil_slow",5)
end
end


function SnakeOil:OnSave()
return {
ability=self.ability,
}
end

function SnakeOil:OnLoad(data)
if data.ability then
self.ability=data.ability
self:SyncAbility()
end
end

return SnakeOil