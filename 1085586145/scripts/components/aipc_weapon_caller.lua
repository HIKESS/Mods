
local WeaponCaller=Class(function(self,inst)
self.inst=inst
self.weaponBox=nil

self.inst:ListenForEvent("aipUnequipItem",function(inst,data)
if data then
self:TryCall(data.item)
end
end)
end)

function WeaponCaller:Bind(target)
self.weaponBox=target
end

function WeaponCaller:TryCall(item)
if not item then
return
end

local prefab=item.prefab


self.inst:DoTaskInTime(0.1,function()

if item:IsValid() then
return
end


if
not self.inst.components.inventory or
self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
then
return
end


if not self.weaponBox then
return
end


local boxItem=self.weaponBox.components.container:FindItem(function(boxItem)
return boxItem.prefab==prefab
end)


if not boxItem then
return
end


self.weaponBox.AnimState:PlayAnimation("launch")
self.weaponBox.AnimState:PushAnimation("idle")

aipSpawnPrefab(self.weaponBox,"aip_weapon_box_fx")
aipSpawnPrefab(self.inst,"aip_weapon_box_fx").AnimState:PlayAnimation("end")

self.weaponBox.components.container:DropItem(boxItem)
self.inst.components.inventory:Equip(boxItem)
end)
end

return WeaponCaller