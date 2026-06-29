
local Screen=require "widgets/screen"
local Widget=require "widgets/widget"
local Text=require "widgets/text"
local TextEdit=require "widgets/textedit"
local Menu=require "widgets/menu"
local UIAnim=require "widgets/uianim"
local ImageButton=require "widgets/imagebutton"

local TEMPLATES=require "widgets/templates"

local function closeScreen(owner)
owner.HUD:CloseAIPAutoConfigWidget()
end

local AutoConfigWidget=Class(Screen,function(self,owner,inst,config)
Screen._ctor(self,"AIP_AutoConfigWidget")

self.aipOwner=owner
self.aipInst=inst
self.aipConfig=config

self.isopen=false

self._scrnw,self._scrnh=TheSim:GetScreenSize()
self:SetScaleMode(SCALEMODE_PROPORTIONAL)
self:SetMaxPropUpscale(MAX_HUD_SCALE)
self:SetPosition(0,0,0)
self:SetVAnchor(ANCHOR_MIDDLE)
self:SetHAnchor(ANCHOR_MIDDLE)


self.scalingroot=self:AddChild(Widget("aipConfigWidgetScalingRoot"))
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


self.root=self.scalingroot:AddChild(Widget("aipConfigWidgetRoot"))
self.root:SetScale(.6,.6,.6)


self.black=self.root:AddChild(Image("images/global.xml","square.tex"))
self.black:SetVRegPoint(ANCHOR_MIDDLE)
self.black:SetHRegPoint(ANCHOR_MIDDLE)
self.black:SetVAnchor(ANCHOR_MIDDLE)
self.black:SetHAnchor(ANCHOR_MIDDLE)
self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
self.black:SetTint(0,0,0,0.3)
self.black.OnMouseButton=function() closeScreen(owner) end


self.bg=self.root:AddChild(TEMPLATES.CurlyWindow(600,600,1,1,68,-40))
self.bg.fill=self.bg:AddChild(Image("images/fepanel_fills.xml","panel_fill_tiny.tex"))
self.bg.fill:SetScale(1.65,1.85)
self.bg.fill:SetPosition(8,12)


self.buttons={}
table.insert(self.buttons,{ text=config.cancelbtn.text,cb=function() closeScreen(owner) end,control=config.cancelbtn.control })
table.insert(self.buttons,{ text=config.acceptbtn.text,cb=function() aipPrint("Close window!!!") end,control=config.acceptbtn.control })

local menuoffset=Vector3(0,0,0)
local spacing=110
self.menu=self.root:AddChild(Menu(self.buttons,spacing,true,"small"))
self.menu:SetTextSize(35)
self.menu:SetPosition(menuoffset.x-.5*spacing*(#self.buttons-1),menuoffset.y-260,menuoffset.z)


--self.checkbox_parent:AddChild(Text(CHATFONT,30,STRINGS.UI.SERVERLISTINGSCREEN.SHOW_MOD_WARNING))


--self.isopen=true
--self:Show()
end)

function AutoConfigWidget:Close()
if self.isopen then
self.isopen=false

self.black:Kill()
self.inst:DoTaskInTime(.1,function() TheFrontEnd:PopScreen(self) end)
end
end

return AutoConfigWidget