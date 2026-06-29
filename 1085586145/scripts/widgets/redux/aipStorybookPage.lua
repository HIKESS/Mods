local Widget=require "widgets/widget"
local Image=require "widgets/image"
local ImageButton=require "widgets/imagebutton"
local UIAnim=require "widgets/uianim"
local Text=require "widgets/text"
local Grid=require "widgets/grid"
local Spinner=require "widgets/spinner"
local Menu=require "widgets/menu"
local TrueScrollList=require "widgets/truescrolllist"

local TEMPLATES=require "widgets/redux/templates"
local Scroller=require "widgets/redux/aipScroller"

require("util")


local language=aipGetModConfig("language")



local LANG_MAP={
chinese="aipStory/chinese",
default="aipStory/english",
}

local langPath=LANG_MAP[language] or LANG_MAP["default"]
local docs=require(langPath)


local CookbookPageCrockPot=Class(Widget,function(self,parent_screen,category)
Widget._ctor(self,"CookbookPageCrockPot")

self.parent_screen=parent_screen
self.category=category or "storybook"

self:InitLayout()

return self
end)


local TOP_OFFSET=275
local MENU_LEFT=-380
local MENU_TOP_OFFSET=25
local MENU_TOP_OFFSET_UNIT=10
local MENU_LEFT_OFFSET=110
local MENU_ITEM_HEIGHT=55

local DESC_LEFT=-240
local DESC_OFFSET=30
local DESC_CONTENT_WIDTH=710
local DESC_CONTENT_HEIGHT=580

function CookbookPageCrockPot:InitLayout()

local scale=0.8
self.root=self:AddChild(Widget("contentRoot"))
self.root:SetScale(scale,scale,scale)


local menuList={}
for i,info in pairs(docs) do
table.insert(menuList,{text=info.name,cb=function()
self:CreateDesc(i)
end})
end


self.menuScroller=self.root:AddChild(Scroller(
0,-DESC_CONTENT_HEIGHT,
MENU_LEFT_OFFSET*2+MENU_TOP_OFFSET_UNIT,DESC_CONTENT_HEIGHT+MENU_TOP_OFFSET_UNIT
))
self.menuScroller:SetPosition(
MENU_LEFT-MENU_LEFT_OFFSET,
TOP_OFFSET,0)
self.menuScroller:SetScrollBound(MENU_ITEM_HEIGHT*#menuList+MENU_TOP_OFFSET_UNIT*2)

local leftMenu=self.menuScroller:PathChild(Menu(menuList,-MENU_ITEM_HEIGHT,false,"carny_long"))
leftMenu:SetTextSize(35)
leftMenu:SetPosition(MENU_LEFT_OFFSET,-MENU_TOP_OFFSET,0)






self:CreateDesc(1)
end

local IMG_MAX_WIDTH=128

function CookbookPageCrockPot:CreateDesc(index)
if self.currentIndex==index then
return
end

if self.descHolder~=nil then
self.descHolder:Kill()
end

local descList=docs[index].desc
self.currentIndex=index


self.descHolder=self.root:AddChild(Scroller(
0,-DESC_CONTENT_HEIGHT,DESC_CONTENT_WIDTH,DESC_CONTENT_HEIGHT+5
))
self.descHolder:SetPosition(DESC_LEFT,TOP_OFFSET,0)






local top=0

for i,descInfo in ipairs(descList) do
local contentHeight=0

if type(descInfo)=="string" or descInfo.type=="txt" then
local descObj=type(descInfo)=="string" and {text=descInfo} or descInfo

local text=self.descHolder:PathChild(Text(UIFONT,35))
text:SetHAlign(ANCHOR_LEFT)
text:SetMultilineTruncatedString(descObj.text,14,DESC_CONTENT_WIDTH,200)

if descObj.color then
text:SetColour(
descObj.color[1]/255,
descObj.color[2]/255,
descObj.color[3]/255,
(descObj.color[4] or 255)/255
)
end

local TW,TH=text:GetRegionSize()
text:SetPosition(TW/2,top-TH/2)
contentHeight=TH

elseif descInfo.type=="img" then
local atlas=descInfo.atlas
local image=descInfo.image
local name=descInfo.name

if name~=nil then
if softresolvefilepath("images/aipStory/"..name..".xml")~=nil then
atlas="images/aipStory/"..name..".xml"
elseif softresolvefilepath("images/inventoryimages/"..name..".xml")~=nil then
atlas="images/inventoryimages/"..name..".xml"
end

image=name..".tex"
end

local img=self.descHolder:PathChild(Image(atlas,image))

local w,h=img:GetSize()
local scale=1

if descInfo.scale~=nil then
scale=descInfo.scale
elseif w > IMG_MAX_WIDTH then
scale=IMG_MAX_WIDTH/w
end


img:SetScale(scale,scale)
w=w*scale
h=h*scale

img:SetPosition(DESC_CONTENT_WIDTH/2,top-h/2)
contentHeight=h

elseif descInfo.type=="anim" then
local anim=self.descHolder:PathChild(UIAnim())
anim:GetAnimState():SetBuild(descInfo.build)
anim:GetAnimState():SetBankAndPlayAnimation(
descInfo.bank or descInfo.build,
descInfo.anim or "idle",
descInfo.loop~=false
)
if descInfo.opacity~=nil then
anim:GetAnimState():SetMultColour(1,1,1,descInfo.opacity)
elseif descInfo.colors~=nil then
anim:GetAnimState():SetMultColour(
descInfo.colors[1],
descInfo.colors[2],
descInfo.colors[3],
descInfo.colors[4]
)
end

anim:SetScale(descInfo.scale or 1)

anim:SetPosition(
DESC_CONTENT_WIDTH/2+(descInfo.left or 0),
top-descInfo.height+(descInfo.top or 0)
)
contentHeight=descInfo.height
end

top=top-contentHeight-DESC_OFFSET
end


self.descHolder:SetScrollBound(-top)
end

return CookbookPageCrockPot
