

local Text=require "widgets/text"
local Widget=require "widgets/widget"


local widgetInst=CreateEntity()



local uniqueInstance=nil

local AIP_UniqueSlotInfo=Class(Widget,function(self)
Widget._ctor(self,"AIP_UniqueSlotInfo")

self.currentSlot=nil

self.text=self:AddChild(Text(UIFONT,25))
self.text:SetPosition(Vector3(0,0,0))


self.syncTask=nil

self:Hide()
self:SetClickable(false)
end)

function AIP_UniqueSlotInfo:UpdateTip(slot)
if self.currentSlot~=slot then
return
end

self:ShowTip(slot)
end

function AIP_UniqueSlotInfo:EmptyAndHide()
self.text:SetString("")
self:Hide()
end


local function getInfo(inst)


if inst.replica and inst.replica.aipSnakeOil then
local aip_info,aip_info_color=inst.replica.aipSnakeOil:GetInfo()

return aip_info,aip_info_color
end


if inst.components.aipc_info_client~=nil then
local aip_info=inst.components.aipc_info_client:Get("aip_info") or ""
local aip_info_color=inst.components.aipc_info_client:Get("aip_info_color")
return aip_info,aip_info_color
end
end

function AIP_UniqueSlotInfo:ShowTip(slot)
self.currentSlot=slot


if not slot or not slot.tile or not slot.tile.item then
return self:EmptyAndHide()
end

local inst=slot.tile.item









local aip_info,aip_info_color=getInfo(inst)

if aip_info=="" or not aip_info then
return self:EmptyAndHide()
end

if aip_info_color then
aip_info_color={ aip_info_color[1]/255,aip_info_color[2]/255,aip_info_color[3]/255,(aip_info_color[4] or 255)/255 }
else
aip_info_color=NORMAL_TEXT_COLOUR
end


self.text:SetString(aip_info)
self.text:SetColour(unpack(aip_info_color))


if self.syncTask~=nil then
self.syncTask:Cancel()
end
self.syncTask=widgetInst:DoTaskInTime(0.001,function()
if self.currentSlot~=slot then
return
end

self:Show()

local hoverer=ThePlayer.HUD.controls.hover
if hoverer then

local text1=hoverer.text
local text2=hoverer.secondarytext

local myWidth,myHeight=self.text:GetRegionSize()
local text1Width,text1Height=text1:GetRegionSize()
local text2Width,text2Height=text2:GetRegionSize()

local text1Pos=text1:GetPosition()
local textY=text1Pos.y
local myY=textY+(text1Height/2)+(myHeight/2)+10
self.text:SetPosition(Vector3(0,myY,0))
end
end)
end

function AIP_UniqueSlotInfo:HideTip(slot)
if self.currentSlot==slot then
self:Hide()
self.currentSlot=nil
end
end

function AIP_UniqueSlotInfo:OnUpdate()
local hoverer=ThePlayer.HUD.controls.hover

if not self.currentSlot or not hoverer then
return
end

local hoverPos=hoverer:GetPosition()
local myPos=self:GetPosition()
self:SetPosition(hoverPos)
end

local function registerGlobal()
if ThePlayer and not uniqueInstance then
uniqueInstance=AIP_UniqueSlotInfo()
ThePlayer.HUD.controls:AddChild(uniqueInstance)

local hoverer=ThePlayer.HUD.controls.hover
if hoverer then
local _OnUpdate=hoverer.OnUpdate
hoverer.OnUpdate=function(instance,...)
uniqueInstance:OnUpdate()
_OnUpdate(instance,...)
end
end
end
end


local AIP_SlotInfo=Class(function(self,slot)
self.slot=slot

self._OnControl=slot.OnControl
self._OnGainFocus=slot.OnGainFocus
self._OnLoseFocus=slot.OnLoseFocus
self._SetTile=slot.SetTile
self._Kill=slot.Kill

slot.SetTile=function(instance,...)
local result=self._SetTile(instance,...)
self:UpdateTip()
return result
end
slot.OnControl=function(instance,...)
local result=self._OnControl(instance,...)
self:ShowTip()
return result
end
slot.OnGainFocus=function(instance,...)
return self:OnGainFocus(instance,...)
end
slot.OnLoseFocus=function(instance,...)
return self:OnLoseFocus(instance,...)
end
slot.Kill=function(instance,...)
self:OnLoseFocus(instance,...)
return self._Kill(instance,...)
end

registerGlobal()
end)

function AIP_SlotInfo:UpdateTip()
if uniqueInstance then
uniqueInstance:UpdateTip(self.slot)
end
end

function AIP_SlotInfo:ShowTip()
if uniqueInstance then
uniqueInstance:ShowTip(self.slot)
end
end

function AIP_SlotInfo:OnGainFocus(instance,...)
self:ShowTip()
return self._OnGainFocus(instance,...)
end

function AIP_SlotInfo:OnLoseFocus(instance,...)
if uniqueInstance then
uniqueInstance:HideTip(self.slot)
end
return self._OnLoseFocus(instance,...)
end

return AIP_SlotInfo