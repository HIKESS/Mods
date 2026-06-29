
local Point=Class(function(self,inst)
self.inst=inst


self.minecar=nil
self.fakeMinecar=nil


self.hasMinecar=net_bool(inst.GUID,"aipc_orbit_point_car","aipc_orbit_point_car_dirty")

if TheWorld.ismastersim then
self.hasMinecar:set(false)
end


if TheWorld.ismastersim then
self.inst:DoTaskInTime(0.1,function()
local minecars=aipFindNearEnts(self.inst,{"aip_glass_minecar"},0.5)
local minecar=minecars[1]
if minecar~=nil then
self:SetMineCar(minecar)
end
end)
end
end)

function disableMinecar(minecar)

if minecar.components.inventoryitem~=nil then
minecar.components.inventoryitem:RemoveFromOwner(true)
minecar.components.inventoryitem.canbepickedup=false
end


minecar:AddTag("NOCLICK")
minecar:AddTag("fx")
end


function Point:SetMineCar(inst)
if self.minecar~=nil or inst==nil then
return
end

self.minecar=inst
self.fakeMinecar=SpawnPrefab(self.minecar.prefab)
self.fakeMinecar.persists=false
self.hasMinecar:set(true)

disableMinecar(self.minecar)
disableMinecar(self.fakeMinecar)


local pt=self.inst:GetPosition()
self.minecar.Physics:Teleport(pt.x,pt.y,pt.z)
self.minecar:Hide()

self.inst:AddChild(self.fakeMinecar)
end


function Point:CanDrive()
return self.hasMinecar:value()
end

function Point:RemoveMineCar()
if self.minecar~=nil then
self.inst:RemoveChild(self.fakeMinecar)
self.minecar=nil
self.hasMinecar:set(false)

self.fakeMinecar:Remove()
end
end


function Point:Drive(doer)
if self.minecar~=nil and doer and doer.components.aipc_orbit_driver~=nil then
local canTake=doer.components.aipc_orbit_driver:UseMineCar(self.minecar,self.inst)

if canTake then
self:RemoveMineCar()
end
end
end


function Point:OnRemoveEntity()
if not self.minecar then
return
end


local pt=self.inst:GetPosition()
self.inst:RemoveChild(self.minecar)
self.minecar.Physics:Teleport(pt.x,pt.y,pt.z)


if self.minecar.components.inventoryitem~=nil then
self.minecar.components.inventoryitem.canbepickedup=true
end


self.minecar:RemoveTag("NOCLICK")
self.minecar:RemoveTag("fx")
self.minecar:Show()

if self.minecar.components.lootdropper~=nil then
self.minecar.components.lootdropper:FlingItem(self.minecar,pt)
end
end

Point.OnRemoveFromEntity=Point.OnRemoveEntity

return Point