
local Driver=Class(function(self,player)
self.inst=player

self.isDriving=net_bool(self.inst.GUID,"aipc_orbit_driving","aipc_orbit_driving_dirty")
if TheWorld.ismastersim then
self.isDriving:set(false)
end

self.inst:ListenForEvent("aipc_orbit_driving_dirty",function()

if self.inst==ThePlayer then
if not self.isDriving:value() then
TheCamera:SetFlyView(false,"driver")
end
end
end)
end)

return Driver