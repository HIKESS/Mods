
local Lighter=Class(function(self,inst)
self.inst=inst

self.enableType=nil
end)

function Lighter:Enabled(type)
if type==self.enableType then
return
end


if self.enableType then
self.inst:RemoveTag("aip_lighter_"..self.enableType)

if not type then
self.inst:RemoveTag("aip_lighter")
end
end


self.enableType=type
if self.enableType then
self.inst:AddTag("aip_lighter_"..self.enableType)
self.inst:AddTag("aip_lighter")
end
end

function Lighter:Light(target,doer)

if
self.enableType=="hot" and
target.components.burnable~=nil and
not ((target:HasTag("fueldepleted") and not target:HasTag("burnableignorefuel")) or target:HasTag("INLIMBO"))
then
target.components.burnable:Ignite(nil,self.inst,doer)


elseif self.enableType and target:HasTag("aip_can_lighten") and target.components.aipc_type_fire then
target.components.aipc_type_fire:StartFire(self.enableType)
end

target:PushEvent("onlighterlight")
end

return Lighter
