local Widget=require "widgets/widget"
local Image=require "widgets/image"

local Scroller=Class(Widget,function(self,x,y,width,height)
Widget._ctor(self,"AIPScroller")

self.control_up=CONTROL_SCROLLBACK
self.control_down=CONTROL_SCROLLFWD
self.scrollUp=false
self.controlDT=0
self.scrollBound=0
self.visualHeight=height
self.started=false


self.black=self:AddChild(Image("images/global.xml","square.tex"))
local bw,bh=self.black:GetSize()
self.black:SetScale(width/bw,height/bh)
self.black:SetPosition(width/2,-height/2)
self.black:SetTint(0,0,0,.01)


self.holder=self:AddChild(Widget("contentRoot"))
self.holder:Hide()

self:SetScissor(x,y,width,height)

return self
end)

function Scroller:PathChild(node)
return self.holder:AddChild(node)
end

function Scroller:SetScrollBound(scrollBound)
self.scrollBound=scrollBound

self:StartUpdating()
end


function Scroller:Offset(val)
local x,y,z=self.holder:GetPosition():Get()

local nextY=y+val
nextY=math.min(nextY,self.scrollBound-self.visualHeight)
nextY=math.max(nextY,0)

self.holder:SetPosition(x,nextY,z)
end

local SCROLL_SCALE=0.05
local SCROLL_OFFSET=200

function Scroller:OnUpdate(dt)

if self.started==false then
self.started=true
self.holder:Show()
end


local enabled=self:IsEnabled()
local focused=self.focus

local up=TheInput:IsControlPressed(self.control_up)
local down=TheInput:IsControlPressed(self.control_down)


if (up or down) and (enabled and focused) then
self.controlDT=self.controlDT+dt
self.scrollUp=up
end


if self.controlDT >=0 then
local multi=self.controlDT/SCROLL_SCALE
self.controlDT=0

self:Offset(multi*(self.scrollUp and-SCROLL_OFFSET or SCROLL_OFFSET))
end
end

return Scroller