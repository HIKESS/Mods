local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local TypeFire=Class(function(self,inst)
self.inst=inst

self.hotPrefab=nil
self.coldPrefab=nil
self.mixPrefab=nil
self.followSymbol=nil
self.followOffset=Vector3(0,0,0)
self.followOffsets={}
self.postFireFn=nil

self.extinguishTime=TUNING.YELLOWSTAFF_STAR_DURATION
self.extinguishTimer=nil


self.forever=false


self.canMix=false


self.extinguishReachTime=nil
self.fireOnInst=false


self.fire=nil
self.fireType=nil

self.onToggle=nil
end)

function TypeFire:StartExtinguishTimer(extinguishTime)
self:KillExtinguishTimer()


if self.forever then
return
end

local mergedExtinguishTime=extinguishTime or self.extinguishTime

self.extinguishTimer=self.inst:DoTaskInTime(
mergedExtinguishTime,
function()
self:StopFire()
end
)

self.extinguishReachTime=GetTime()+mergedExtinguishTime
end

function TypeFire:KillExtinguishTimer()
if self.extinguishTimer~=nil then
self.extinguishTimer:Cancel()
self.extinguishTimer=nil
self.extinguishReachTime=nil
end
end

function TypeFire:StartFire(type,target,extinguishTime,supportMix)

if not type then
return
end

self.fireOnInst=target==nil or target==self.inst

if type==self.fireType then

self:StartExtinguishTimer(extinguishTime)
return
end

local originType=self:IsBurning() and self.fireType or nil


local hasHot=type=="hot" or originType=="hot"
local hasCold=type=="cold" or originType=="cold"


self:StopFire()
self:StartExtinguishTimer(extinguishTime)

if hasHot and hasCold and self.canMix and supportMix then
type="mix"
end



target=target or self.inst
local firePrefab=self.hotPrefab
if type=="mix" then
firePrefab=self.mixPrefab
elseif type=="cold" then
firePrefab=self.coldPrefab
end


local offset=self.followOffsets[type] or self.followOffset

local fx=SpawnPrefab(firePrefab)
fx.entity:SetParent(target.entity)
fx.entity:AddFollower()
fx.Follower:FollowSymbol(
target.GUID,self.followSymbol,
offset.x,offset.y,offset.z
)

if self.postFireFn~=nil then
self.postFireFn(self.inst,fx,type)
end

self.fire=fx
self.fireType=type

if self.onToggle~=nil then
self.onToggle(self.inst,type)
end
end

function TypeFire:StopFire()
self:KillExtinguishTimer()

if self.fire~=nil then
self.fire:Remove()
self.fire=nil

if self.onToggle~=nil then
self.onToggle(self.inst,nil)
end
end

self.fireType=nil
end

function TypeFire:IsBurning()
return self.fire~=nil
end

function TypeFire:GetType()
return self:IsBurning() and self.fireType or nil
end


function TypeFire:OnRemoveFromEntity()
self:StopFire()
end
TypeFire.OnRemoveEntity=TypeFire.OnRemoveFromEntity



function TypeFire:OnSave()
if self.fireType and self.fireOnInst and (self.extinguishReachTime or self.forever) then
local leftTime=(self.extinguishReachTime or 1)-GetTime()
return {
fireType=self.fireType,
leftTime=math.max(23,leftTime)
}
end
end


function TypeFire:OnLoad(data)
if data~=nil and data.fireType~=nil then
self:StartFire(data.fireType,nil,data.leftTime or 1)
end
end

return TypeFire
