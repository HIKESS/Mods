local foldername=KnownModIndex:GetModActualName(TUNING.ZOMBIEJ_ADDTIONAL_PACKAGE)

local Empty=Class(function()
end)


local additional_building=aipGetModConfig("additional_building")
if additional_building~="open" then
return Empty
end


local additional_food=aipGetModConfig("additional_food")
if additional_food~="open" then
return Empty
end

local ShadowFollower=Class(function(self,inst)
self.inst=inst


inst:DoTaskInTime(0,function()
local x,y,z=inst.Transform:GetWorldPosition()


self.vest=SpawnPrefab("dark_observer_vest")
self.vest.Transform:SetPosition(x,y,z)
self.vest.MiniMapEntity:SetEnabled(false)
self.vest.__hasMaster=true


self.icon=SpawnPrefab("globalmapicon")
self.icon.MiniMapEntity:SetPriority(10)
self.icon.MiniMapEntity:SetRestriction("player")
self.icon.MiniMapEntity:SetIcon("dark_observer_vest.tex")
self.icon.Transform:SetPosition(x,y,z)
self.icon.MiniMapEntity:SetEnabled(false)


inst:DoPeriodicTask(1,function()
self:RefreshIcon()
end)
end)

inst:ListenForEvent("onremove",function()
self:OnRemoveFromEntity()
end)
end)


function ShadowFollower:RefreshIcon()
if TheWorld.components.world_common_store:isShadowFollowing() then

local x,y,z=self.inst.Transform:GetWorldPosition()

if self.vest then
self.vest.MiniMapEntity:SetEnabled(true)
self.vest.Transform:SetPosition(x,y,z)
end
if self.icon then
self.icon.MiniMapEntity:SetEnabled(true)
self.icon.Transform:SetPosition(x,y,z)
end
else

if self.vest then
self.vest.MiniMapEntity:SetEnabled(false)
end
if self.icon then
self.icon.MiniMapEntity:SetEnabled(false)
end
end
end


function ShadowFollower:OnRemoveFromEntity()

if self.vest then
self.vest:Remove()
end
if self.icon then
self.icon:Remove()
end
end

function ShadowFollower:OnSave()
local data={}
return data
end

function ShadowFollower:OnLoad(data)
end

return ShadowFollower