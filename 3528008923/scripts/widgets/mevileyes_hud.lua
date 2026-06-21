
--------------------------------------
-----[copyright © 2021 by DoMayZ]-----
--------------------------------------

local Widget = require "widgets/widget"
local Text = require "widgets/text" 
local UIAnim = require "widgets/uianim"  
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"  
local Button = require "widgets/button"
local hudsize = .45
local textsize = 1

local mevileyes_hud = Class(Widget, function(self) 
    Widget._ctor(self, "mevileyes_hud") 
    local owner = ThePlayer

    self.ui_skill1 = self:AddChild(Image("images/skill/evilskill1.xml", "evilskill1.tex" ))
    self.ui_skill1:SetScale(hudsize)
    self.ui_skill1:SetPosition(-80, 0)

    self.ui_skill2 = self:AddChild(Image("images/skill/evilskill2.xml", "evilskill2.tex" ))
    self.ui_skill2:SetScale(hudsize)
    self.ui_skill2:SetPosition(-30, 0) 

    self.ui_skill3 = self:AddChild(Image("images/skill/evilskill3.xml", "evilskill3.tex" ))
    self.ui_skill3:SetScale(hudsize)
    self.ui_skill3:SetPosition(20, 0)
	
	self.ui_skill4 = self:AddChild(Image("images/skill/evilskill4.xml", "evilskill4.tex" ))
    self.ui_skill4:SetScale(hudsize)
    self.ui_skill4:SetPosition(-80, 55)
	
	self.ui_skill5 = self:AddChild(Image("images/skill/evilskill5.xml", "evilskill5.tex" ))
    self.ui_skill5:SetScale(hudsize)
    self.ui_skill5:SetPosition(-30, 55)
	
	self.ui_skill6 = self:AddChild(Image("images/skill/evilskill6.xml", "evilskill6.tex" ))
    self.ui_skill6:SetScale(hudsize)
    self.ui_skill6:SetPosition(20, 55)
	
	self.ui_skill7 = self:AddChild(Image("images/skill/evilskill7.xml", "evilskill7.tex" ))
    self.ui_skill7:SetScale(hudsize)
    self.ui_skill7:SetPosition(70, -55)
	
	self.ui_evilskillsp = self:AddChild(Image("images/skill/evilskillsp.xml", "evilskillsp.tex" ))
    self.ui_evilskillsp:SetScale(hudsize)
    self.ui_evilskillsp:SetPosition(-130, -55)
	
    self.ui_evilwave = self:AddChild(Image("images/skill/evilwave.xml", "evilwave.tex" ))
    self.ui_evilwave:SetScale(hudsize)
    self.ui_evilwave:SetPosition(-80, -55)
	
    self.ui_evilwarp = self:AddChild(Image("images/skill/evilwarp.xml", "evilwarp.tex" ))
    self.ui_evilwarp:SetScale(hudsize)
    self.ui_evilwarp:SetPosition(-30, -55)
	
	self.ui_evilcurse = self:AddChild(Image("images/skill/evilcurse.xml", "evilcurse.tex" ))
    self.ui_evilcurse:SetScale(hudsize)
    self.ui_evilcurse:SetPosition(20, -55)

    self.ui_skill1_text = self:AddChild(Text(BODYTEXTFONT, 26,""))
    self.ui_skill1_text:SetScale(textsize)
    self.ui_skill1_text:SetPosition(-86, 8)
    self.ui_skill1_text:SetColour({255/255, 255/255, 255/255, 1})

    self.ui_skill2_text = self:AddChild(Text(BODYTEXTFONT, 26,""))
    self.ui_skill2_text:SetScale(textsize)
    self.ui_skill2_text:SetPosition(-36, 8)
    self.ui_skill2_text:SetColour({255/255, 255/255, 255/255, 1})

    self.ui_skill3_text = self:AddChild(Text(BODYTEXTFONT, 26,""))
    self.ui_skill3_text:SetScale(textsize)
    self.ui_skill3_text:SetPosition(14, 8)
    self.ui_skill3_text:SetColour({ 255/255, 255/255, 255/255, 1})
	
	self.ui_skill4_text = self:AddChild(Text(BODYTEXTFONT, 26,""))
    self.ui_skill4_text:SetScale(textsize)
    self.ui_skill4_text:SetPosition(-86, 62)
    self.ui_skill4_text:SetColour({ 255/255, 255/255, 255/255, 1})
	
	self.ui_skill5_text = self:AddChild(Text(BODYTEXTFONT, 26,""))
    self.ui_skill5_text:SetScale(textsize)
    self.ui_skill5_text:SetPosition(-36, 62)
    self.ui_skill5_text:SetColour({ 255/255, 255/255, 255/255, 1})
	
	self.ui_skill6_text = self:AddChild(Text(BODYTEXTFONT, 26,""))
    self.ui_skill6_text:SetScale(textsize)
    self.ui_skill6_text:SetPosition(14, 62)
    self.ui_skill6_text:SetColour({ 255/255, 255/255, 255/255, 1})
	
	self.ui_skill7_text = self:AddChild(Text(BODYTEXTFONT, 26,""))
    self.ui_skill7_text:SetScale(textsize)
    self.ui_skill7_text:SetPosition(64, -48)
    self.ui_skill7_text:SetColour({ 255/255, 255/255, 255/255, 1})
	
    self.ui_evilskillsp_text = self:AddChild(Text(BODYTEXTFONT, 26,"")) 
    self.ui_evilskillsp_text:SetScale(textsize)
    self.ui_evilskillsp_text:SetPosition(-136, -48)
    self.ui_evilskillsp_text:SetColour({ 255/255, 255/255, 255/255, 1 })
	
    self.ui_evilwave_text = self:AddChild(Text(BODYTEXTFONT, 26,"")) 
    self.ui_evilwave_text:SetScale(textsize)
    self.ui_evilwave_text:SetPosition(-86, -48)
    self.ui_evilwave_text:SetColour({ 255/255, 255/255, 255/255, 1 })
	
    self.ui_evilwarp_text = self:AddChild(Text(BODYTEXTFONT, 26,"")) 
    self.ui_evilwarp_text:SetScale(textsize)
    self.ui_evilwarp_text:SetPosition(-36, -48)
    self.ui_evilwarp_text:SetColour({ 255/255, 255/255, 255/255, 1 })           

	self.ui_evilcurse_text = self:AddChild(Text(BODYTEXTFONT, 26,"")) 
    self.ui_evilcurse_text:SetScale(textsize)
    self.ui_evilcurse_text:SetPosition(14, -48)
    self.ui_evilcurse_text:SetColour({ 255/255, 255/255, 255/255, 1 })
	
	self.ui_mindpower_text = self:AddChild(Text(BODYTEXTFONT, 26,"")) 
    self.ui_mindpower_text:SetScale(textsize)
    self.ui_mindpower_text:SetPosition(-36, -88)
    self.ui_mindpower_text:SetColour({ 255/255, 255/255, 255/255, 1 })
	
    if owner.prefab == "mevileyes" then
         self:StartUpdating()
        else
            self:Hide()
    end
end)

function mevileyes_hud:OnUpdate(dt)
   local owner = ThePlayer
   self.ui_skill1_text:SetString(""..owner._skill1:value().."")
   self.ui_skill2_text:SetString(""..owner._skill2:value().."")
   self.ui_skill3_text:SetString(""..owner._skill3:value().."")
   self.ui_skill4_text:SetString(""..owner._skill4:value().."")
   self.ui_skill5_text:SetString(""..owner._skill5:value().."")
   self.ui_skill6_text:SetString(""..owner._skill6:value().."")
   self.ui_skill7_text:SetString(""..owner._skill7:value().."")
   self.ui_evilskillsp_text:SetString(""..owner._evilskillsp:value().."")
   self.ui_evilwarp_text:SetString(""..owner._evilwarp:value().."")
   self.ui_evilwave_text:SetString(""..owner._evilwave:value().."")
   self.ui_evilcurse_text:SetString(""..owner._evilcurse:value().."")
   
   self.ui_mindpower_text:SetString("󰀈:"..owner._mindpower:value().."/"..(TUNING.MEVILEYES.MAXMIND+owner._kenjutsulevel:value()).." ".."󰀍:"..owner._kenjutsulevel:value().." "..owner._kenjutsuexp:value().."/"..(TUNING.MEVILEYES.MAXEXP*owner._kenjutsulevel:value()).."")
  
   if owner._mindpower:value() and owner._kenjutsulevel:value() < 10  then
        self.ui_mindpower_text:Show()
	else  self.ui_mindpower_text:SetString("󰀈:"..owner._mindpower:value().."/"..(TUNING.MEVILEYES.MAXMIND+owner._kenjutsulevel:value()))
			self.ui_mindpower_text:Show()
    end

	if owner._skill1:value() ~= 0 then
        self.ui_skill1_text:Show()
        self.ui_skill1:Show()
     else
          self.ui_skill1_text:Hide()
          self.ui_skill1:Hide()
    end
     if owner._skill2:value() ~= 0 then
        self.ui_skill2_text:Show()
        self.ui_skill2:Show()
     else
          self.ui_skill2_text:Hide()
          self.ui_skill2:Hide()
    end
     if owner._skill3:value() ~= 0 then
        self.ui_skill3_text:Show()
        self.ui_skill3:Show()
     else
          self.ui_skill3_text:Hide()
          self.ui_skill3:Hide()
    end
	if owner._skill4:value() ~= 0 then
        self.ui_skill4_text:Show()
        self.ui_skill4:Show()
     else
          self.ui_skill4_text:Hide()
          self.ui_skill4:Hide()
    end
	if owner._skill5:value() ~= 0 then
        self.ui_skill5_text:Show()
        self.ui_skill5:Show()
     else
          self.ui_skill5_text:Hide()
          self.ui_skill5:Hide()
    end
	if owner._skill6:value() ~= 0 then
        self.ui_skill6_text:Show()
        self.ui_skill6:Show()
     else
          self.ui_skill6_text:Hide()
          self.ui_skill6:Hide()
    end
	if owner._skill7:value() ~= 0 then
        self.ui_skill7_text:Show()
        self.ui_skill7:Show()
     else
          self.ui_skill7_text:Hide()
          self.ui_skill7:Hide()
    end
	
	if owner._evilskillsp:value() ~= 0 then
        self.ui_evilskillsp_text:Show()
        self.ui_evilskillsp:Show()
     else
          self.ui_evilskillsp_text:Hide()
          self.ui_evilskillsp:Hide()
    end
	
	if owner._evilwave:value() ~= 0 then
        self.ui_evilwave_text:Show()
        self.ui_evilwave:Show()
     else
          self.ui_evilwave_text:Hide()
          self.ui_evilwave:Show()
    end
    if owner._evilwarp:value() ~= 0 then
        self.ui_evilwarp_text:Show()
        self.ui_evilwarp:Show()
     else
          self.ui_evilwarp_text:Hide()
          self.ui_evilwarp:Show()
    end
    
	if owner._evilcurse:value() ~= 0 then
        self.ui_evilcurse_text:Show()
        self.ui_evilcurse:Show()
     else
          self.ui_evilcurse_text:Hide()
          self.ui_evilcurse:Hide()
    end
end

function mevileyes_hud:OnControl (control, down)
  if control == CONTROL_ACCEPT then
    if down then
      self:StartDrag()
    else
      self:EndDrag()
    end
  end
end

function mevileyes_hud:SetDragPosition(x, y, z)
  local pos
  if type(x) == "number" then
    pos = Vector3(x, y, z)
  else
    pos = x
  end
  self:SetPosition(pos + self.dragPosDiff)
end

function mevileyes_hud:StartDrag()
  if not self.followhandler then
    local mousepos = TheInput:GetScreenPosition()
    self.dragPosDiff = self:GetPosition() - mousepos
    self.followhandler = TheInput:AddMoveHandler(function(x,y) self:SetDragPosition(x,y) end)
    self:SetDragPosition(mousepos)
  end
end

function mevileyes_hud:EndDrag()
  if self.followhandler then
    self.followhandler:Remove()
  end
  self.followhandler = nil
  self.dragPosDiff = nil
end

return mevileyes_hud