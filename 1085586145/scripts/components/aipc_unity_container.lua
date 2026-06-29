
local function moveItems(src,tgt)
if src.components.container~=nil and tgt.components.container~=nil then
local numslots=tgt.components.container:GetNumSlots()
for slot=1,numslots do
local srcItem=src.components.container:GetItemInSlot(slot)
local tgtItem=tgt.components.container:GetItemInSlot(slot)


if srcItem~=nil then

tgt.components.container:DropItemBySlot(slot)


src.components.container:DropItemBySlot(slot)
tgt.components.container:GiveItem(srcItem,slot,nil,true)
end
end

tgt.components.container:GetNumSlots()
end
end


local function collectItems(lureplant)
if lureplant==nil or lureplant.components.inventory==nil or #aipCommonStore().chests==0 then
return
end

local holderChest=aipCommonStore().holderChest
if holderChest==nil then

holderChest=aipCommonStore().chests[1]
aipCommonStore().holderChest=holderChest
end


local items=lureplant.components.inventory:FindItems(function(item)
return not item:HasTag("nosteal") and

(lureplant.components.shelf==nil or item~=lureplant.components.shelf.itemonshelf)
end)

for i,item in ipairs(items) do
if not holderChest.components.container:IsFull() then

lureplant.components.inventory:DropItem(item,true)
holderChest.components.container:GiveItem(item,nil,nil,true)
elseif item.components.stackable==nil then

break
else

local restCount=0
for slot=1,holderChest.components.container:GetNumSlots() do
local chestItem=holderChest.components.container:GetItemInSlot(slot)

if chestItem and chestItem.prefab==item.prefab and chestItem.skinname==item.skinname and not chestItem.components.stackable:IsFull() then
restCount=restCount+chestItem.components.stackable:RoomLeft()
end
end


if restCount > 0 then
if restCount >=item.components.stackable:StackSize() then

lureplant.components.inventory:DropItem(item,true)
holderChest.components.container:GiveItem(item)
else

local filledItem=item.components.stackable:Get(restCount)
holderChest.components.container:GiveItem(filledItem)
end
end
end
end
end


local UnityCotainer=Class(function(self,inst)
self.inst=inst
self.checkTimes=0


table.insert(aipCommonStore().chests,self.inst)


self.task=self.inst:DoPeriodicTask(2,function() self:CollectLureplant() end)


self.inst:DoTaskInTime(0.5,function()
if self.inst.components.container~=nil and not self.inst.components.container:IsEmpty() then
aipCommonStore().holderChest=self.inst
end
end)


self.inst:ListenForEvent("onremove",function()
aipTableRemove(aipCommonStore().chests,self.inst)

self:UnlockOthers()


end)
end)

function UnityCotainer:CollectLureplant()

if self.checkTimes==0 or aipCommonStore().holderChest==self.inst then

local x,y,z=self.inst.Transform:GetWorldPosition()
local lureplants=TheSim:FindEntities(x,y,z,TUNING.AIP_GLASS_CHEST_RANGE,nil,nil,{ "lureplant","eyeplant" })
for i,lureplant in ipairs(lureplants) do
collectItems(lureplant)
end

self.checkTimes=0
end

self.checkTimes=(self.checkTimes+1) % 4
end

function UnityCotainer:LockOthers()
for i,chest in ipairs(aipCommonStore().chests) do
if chest~=self.inst then
chest.components.container.canbeopened=false
chest.components.inspectable:SetDescription(STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_GLASS_CHEST_DISABLED)


moveItems(chest,self.inst)
end
end


aipCommonStore().holderChest=self.inst
aipCommonStore().chestOpened=true


self:CollectLureplant()
end

function UnityCotainer:UnlockOthers()

if aipCommonStore().holderChest==self.inst then
for i,chest in ipairs(aipCommonStore().chests) do
chest.components.container.canbeopened=true
chest.components.inspectable:SetDescription(nil)
end
end


aipCommonStore().chestOpened=false
end

return UnityCotainer