local Screen=require "widgets/screen"
local Widget=require "widgets/widget"
local Text=require "widgets/text"
local TextEdit=require "widgets/textedit"
local Menu=require "widgets/menu"
local UIAnim=require "widgets/uianim"
local ImageButton=require "widgets/imagebutton"

local function onselect(doer,widget,totemId,triggerTotemId)
if not widget.isopen then
return
end

if totemId==triggerTotemId then

if doer.components.talker then
doer.components.talker:Say(STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_FLY_TOTEM_CURRENT)
end
else
aipRPC("aipFlyToTotem",triggerTotemId,totemId)
end

doer.HUD:CloseAIPDestination()
end

local function oncancel(doer,widget)
if not widget.isopen then
return
end

doer.HUD:CloseAIPDestination()
end

local DestinationScreen=Class(Screen,function(self,owner,triggerTotemId)
Screen._ctor(self,"AIP_DestinationScreen")

self.owner=owner

self.triggerTotemId=triggerTotemId

self.totemNames={}
self.totemIds={}

self.isopen=false


ThePlayer.aipOnTotemFetch=function(names,ids)
self.totemNames=names
self.totemIds=ids

self:RenderDestinations()

ThePlayer.aipOnTotemFetch=nil
end

aipRPC("aipGetFlyTotemNames")


self._scrnw,self._scrnh=TheSim:GetScreenSize()

self:SetScaleMode(SCALEMODE_PROPORTIONAL)
self:SetMaxPropUpscale(MAX_HUD_SCALE)
self:SetPosition(0,0,0)
self:SetVAnchor(ANCHOR_MIDDLE)
self:SetHAnchor(ANCHOR_MIDDLE)

self.scalingroot=self:AddChild(Widget("writeablewidgetscalingroot"))
self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
self.inst:ListenForEvent("continuefrompause",function()
if self.isopen then
self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
end
end,TheWorld)
self.inst:ListenForEvent("refreshhudsize",function(hud,scale)
if self.isopen then
self.scalingroot:SetScale(scale)
end
end,owner.HUD.inst)

self.root=self.scalingroot:AddChild(Widget("writeablewidgetroot"))
local scale=0.8
self.root:SetScale(scale,scale,scale)


self.black=self.root:AddChild(Image("images/global.xml","square.tex"))
self.black:SetVRegPoint(ANCHOR_MIDDLE)
self.black:SetHRegPoint(ANCHOR_MIDDLE)
self.black:SetVAnchor(ANCHOR_MIDDLE)
self.black:SetHAnchor(ANCHOR_MIDDLE)
self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
self.black:SetTint(0,0,0,0)
self.black.OnMouseButton=function() oncancel(self.owner,self) end


self.bganim=self.root:AddChild(UIAnim())
self.bganim:SetScale(1,1,1)
self.bgimage=self.root:AddChild(Image())
self.bganim:SetScale(1,1,1)

self.bganim:GetAnimState():SetBank("ui_board_5x3")
self.bganim:GetAnimState():SetBuild("ui_board_5x3")


self.page=0
self:RenderDestinations()


self.root:SetPosition(0,150,0)

self.isopen=true
self:Show()

if self.bgimage.texture then
self.bgimage:Show()
else
self.bganim:GetAnimState():PlayAnimation("open")
end
end)

function DestinationScreen:OffsetPage(offset)
self.page=self.page+offset
self:RenderDestinations()
end

local PageSize=10
function DestinationScreen:RenderDestinations()
local startIndex=(self.page)*PageSize
local names=aipTableSlice(self.totemNames,startIndex+1,PageSize)
self.destLeft={}
self.destRight={}


if self.destLeftMenu~=nil then
self.destLeftMenu:Kill()
self.destRightMenu:Kill()
self.menu:Kill()
end


for i=1,PageSize/2 do
local idx=startIndex+i
if self.totemNames[idx]~=nil then
table.insert(self.destLeft,{
text=self.totemNames[idx] or '-',
cb=function()
onselect(self.owner,self,self.totemIds[idx],self.triggerTotemId)
end,
})
end
end

self.destLeftMenu=self.root:AddChild(Menu(self.destLeft,-55,false,"carny_long"))
self.destLeftMenu:SetTextSize(35)
self.destLeftMenu:SetPosition(-118,130,0)


for i=PageSize/2+1,PageSize do
local idx=startIndex+i
if self.totemNames[idx]~=nil then
table.insert(self.destRight,{
text=self.totemNames[idx] or "-",
cb=function()
onselect(self.owner,self,self.totemIds[idx],self.triggerTotemId)
end,
})
end
end

self.destRightMenu=self.root:AddChild(Menu(self.destRight,-55,false,"carny_long"))
self.destRightMenu:SetTextSize(35)
self.destRightMenu:SetPosition(118,130,0)


self.buttons={}

table.insert(self.buttons,{ text=STRINGS.UI.HELP.PREVPAGE,cb=function()
self:OffsetPage(-1)
end,control=CONTROL_CANCEL })

table.insert(self.buttons,{ text=STRINGS.SIGNS.MENU.CANCEL,cb=function() oncancel(self.owner,self) end,control=CONTROL_CANCEL })

table.insert(self.buttons,{ text=STRINGS.UI.HELP.NEXTPAGE,cb=function()
self:OffsetPage(1)
end,control=CONTROL_CANCEL })


local menuoffset=Vector3(6,-160,0)
if TheInput:ControllerAttached() then
local spacing=150
self.menu=self.root:AddChild(Menu(self.buttons,spacing,true,"none"))
self.menu:SetTextSize(40)
local w=self.menu:AutoSpaceByText(15)
self.menu:SetPosition(menuoffset.x-.5*w,menuoffset.y,menuoffset.z)
else
local spacing=110
self.menu=self.root:AddChild(Menu(self.buttons,spacing,true,"small"))
self.menu:SetTextSize(35)
self.menu:SetPosition(menuoffset.x-.5*spacing*(#self.buttons-1),menuoffset.y,menuoffset.z)
end


if self.page==0 then
self.menu:DisableItem(1)
end
if self.page+1 >=math.ceil(#self.totemNames/PageSize) then
self.menu:DisableItem(3)
end
end

function DestinationScreen:Close()
if self.isopen then
if self.bgimage.texture then
self.bgimage:Hide()
else
self.bganim:GetAnimState():PlayAnimation("close")
end

self.black:Kill()
self.menu:Kill()
self.destLeftMenu:Kill()
self.destRightMenu:Kill()

self.isopen=false

self.inst:DoTaskInTime(.3,function() TheFrontEnd:PopScreen(self) end)
end
end

return DestinationScreen