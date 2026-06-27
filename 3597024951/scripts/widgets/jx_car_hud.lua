local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"

local function IsMusicPause(self)
  return self.music_panel_pause.image_normal ~= "pause.tex"
end

local JX_Car_HUD = Class(Widget, function(self)
    Widget._ctor(self, "JX_Car_HUD")
    
    self.fuel_gauge = self:AddChild(UIAnim())
    self.fuel_gauge:GetAnimState():SetBank("jx_car_hud")
    self.fuel_gauge:GetAnimState():SetBuild("jx_car_hud")
    self.fuel_gauge:GetAnimState():PlayAnimation("fuel_idle6", false)
    self.fuel_gauge:SetPosition(-800, -50)
    
    self.passenger = self:AddChild(UIAnim())
    self.passenger:GetAnimState():SetBank("jx_car_hud")
    self.passenger:GetAnimState():SetBuild("jx_car_hud")
    self.passenger:GetAnimState():PlayAnimation("passenger_1", false)
    self.passenger:SetPosition(-1000, -30)
    
    self.health = self:AddChild(UIAnim())
    self.health:GetAnimState():SetBank("jx_car_hud")
    self.health:GetAnimState():SetBuild("jx_car_hud")
    self.health:GetAnimState():PlayAnimation("health", false)
    self.health:GetAnimState():SetDeltaTimeMultiplier(0)
    self.health:GetAnimState():SetPercent("health", 1)
    self.health:SetPosition(-1190, -50)
    
    self.speed = self:AddChild(UIAnim())
    self.speed:GetAnimState():SetBank("jx_car_hud")
    self.speed:GetAnimState():SetBuild("jx_car_hud")
    self.speed:GetAnimState():PlayAnimation("speed", false)
    self.speed:GetAnimState():SetDeltaTimeMultiplier(0)
    self.speed:GetAnimState():SetTime(0)
    self.speed:SetPosition(1000, 80)
    
    self.whistle = self:AddChild(ImageButton("images/jx_car_hud/whistle.xml", "whistle_normal.tex", "whistle_normal.tex", nil, "whistle_down.tex"))
    self.whistle:SetNormalScale(.7, .7, .7)
    self.whistle:SetFocusScale(.9, .9, .9)
    self.whistle:SetOnDown(function() self:OnDown_Whistle() end)
    self.whistle:SetOnClick(function() self:OnClick_Whistle() end)
    self.whistle.stopclicksound = true
    self.whistle:SetPosition(1100, 150)
    self.whistle:Hide()
    
    self.music = self:AddChild(ImageButton("images/jx_car_hud/music.xml", "music_normal.tex", "music_normal.tex", nil, "music_normal_down.tex"))
    self.music:SetNormalScale(.7, .7, .7)
    self.music:SetFocusScale(.9, .9, .9)
    self.music:SetOnClick(function() self:OnClick_Music() end)
    self.music.overrideclicksound = "dontstarve/HUD/click_object"
    self.music:SetPosition(900, 150)
    
    self.music_record_list =
    {
      "Jingxi_Jazz",
      "XunCat_Pop",
      "Wilsons_Holiday",
    }
    self.current_music_num = math.random(1, #self.music_record_list)
    self.current_music_name = self.music_record_list[self.current_music_num]
    self.music_textbutton_basepos =
    {
      {x = 80, y = 62},
      {x = 80, y = 27},
      {x = 80, y = -8},
      --{x = 80, y = -43},
    }
    
    self.music_panel = self:AddChild(UIAnim())
    self.music_panel:GetAnimState():SetBank("jx_car_hud")
    self.music_panel:GetAnimState():SetBuild("jx_car_hud")
    self.music_panel:GetAnimState():PlayAnimation("music_panel_close", false)
    self.music_panel:SetPosition(900, 410)
    self.music_panel:Hide()
        
    self.music_panel_pause = self.music_panel:AddChild(ImageButton("images/jx_car_hud/pause.xml", "resume.tex", "resume.tex", nil, "resume.tex"))
    self.music_panel_pause:SetNormalScale(.65, .65, .65)
    self.music_panel_pause:SetFocusScale(.8, .8, .8)
    self.music_panel_pause:SetOnClick(function() self:OnClick_Pause(true) end)
    self.music_panel_pause.overrideclicksound = "dontstarve/HUD/click_object"
    self.music_panel_pause:SetPosition(-150, -31)
    self.music_panel_pause:Hide()
    
    self.music_panel_record = self.music_panel:AddChild(UIAnim())
    self.music_panel_record:GetAnimState():SetBank("jx_car_record")
    self.music_panel_record:GetAnimState():SetBuild("jx_car_record")
    self.music_panel_record:GetAnimState():PlayAnimation("loop"..self.current_music_num, true)
    self.music_panel_record:GetAnimState():SetDeltaTimeMultiplier(0)
    self.music_panel_record:SetPosition(-155, 65)
    self.music_panel_record:Hide()
    
    for k, v in ipairs(self.music_record_list) do
      self["music_textbutton_"..k] = self.music_panel:AddChild(ImageButton("images/jx_car_hud/"..v..".xml", v..".tex", v..".tex", nil, v..".tex"))
      self["music_textbutton_"..k]:SetNormalScale(1, 1, 1)
      self["music_textbutton_"..k]:SetFocusScale(1.1, 1.1, 1.1)
      self["music_textbutton_"..k]:SetOnClick(function() self:OnClick_Music_TextButton(k, true) end)
      self["music_textbutton_"..k].overrideclicksound = "dontstarve/HUD/click_object"
      self["music_textbutton_"..k]:Hide()
    end
    self.inst:DoTaskInTime(0, function() self:Refresh_Text_Pos(self.current_music_num) end)
end)

function JX_Car_HUD:UpdateFuel(fuel_level)
  if fuel_level then
    self.fuel_gauge:GetAnimState():PlayAnimation("fuel_idle"..fuel_level, false)
  end
end

function JX_Car_HUD:HUDUpdatePassenger(n1, n2, n3)
  local tb1 = {n1, n2, n3}
  local tb2 = {}
  for _, v in pairs(tb1) do
    if v ~= nil then
      table.insert(tb2, v)
    end
  end
  if #tb2 > 0 then
    table.sort(tb2)
  end
  
  local anim = "passenger_1"
  for _, v in pairs(tb2) do
    anim = anim.."_"..v
  end
  self.passenger:GetAnimState():PlayAnimation(anim, false)
end

function JX_Car_HUD:UpdateSpeed(percent)
  if percent then
    self.speed:GetAnimState():SetPercent("speed", percent)
  end
end

function JX_Car_HUD:UpdateHealth(percent)
  if percent then
    self.health:GetAnimState():SetPercent("health", percent)
  end
end

function JX_Car_HUD:Update_Whistle_HUD(val)
  if val then
    self.whistle:Show()
  else
    self.whistle:Hide()
  end
end

function JX_Car_HUD:OnDown_Whistle()
  SendModRPCToServer(GetModRPC("JX", "HUDWhistle"), true)
end

function JX_Car_HUD:OnClick_Whistle()
  SendModRPCToServer(GetModRPC("JX", "HUDWhistle"), false)
end

function JX_Car_HUD:OnClick_Music()
  if self.music.image_normal == "music_normal.tex" then
    self.music:SetTextures("images/jx_car_hud/music.xml", "music_red.tex", "music_red.tex", nil, "music_red_down.tex")
    self.music_panel:Show()
    self.music_panel:GetAnimState():PlayAnimation("music_panel_open", false)
    
    self.inst:DoTaskInTime(1 * FRAMES, function()
      self.music_panel_pause:SetNormalScale(.65, .25, .65)
      self.music_panel_pause:Show()
      self.music_panel_record:SetScale(.7)
      self.music_panel_record:Show()
    end)
  
    self.inst:DoTaskInTime(2 * FRAMES, function()
      self.music_panel_pause:SetNormalScale(.65, .45, .65)
      self.music_panel_record:SetScale(.85)
      self:Refresh_Text_Pos(self.current_music_num)
    end)
  
    self.inst:DoTaskInTime(3 * FRAMES, function()
      self.music_panel_pause:SetNormalScale(.65, .65, .65)
      self.music_panel_record:SetScale(1)
    end)
  else
    self.music:SetTextures("images/jx_car_hud/music.xml", "music_normal.tex", "music_normal.tex", nil, "music_normal_down.tex")
    self.music_panel:GetAnimState():PlayAnimation("music_panel_close", false)
    self.music_panel_pause:SetNormalScale(.65, .45, .65)
    self.music_panel_record:SetScale(.85)
    for k, _ in ipairs(self.music_record_list) do
      self["music_textbutton_"..k]:Hide()
    end
    
    self.inst:DoTaskInTime(1 * FRAMES, function()
      self.music_panel_pause:SetNormalScale(.65, .25, .65)
      self.music_panel_record:SetScale(.7)
    end)
    self.inst:DoTaskInTime(2 * FRAMES, function()
      self.music_panel_pause:Hide()
      self.music_panel_pause:SetNormalScale(.65, .65, .65)
      
      self.music_panel_record:Hide()
      self.music_panel_record:SetScale(1)
    end)
  
    self.inst:DoTaskInTime(self.music_panel:GetAnimState():GetCurrentAnimationLength(),function() self.music_panel:Hide() end)
  end
end

function JX_Car_HUD:OnClick_Music_TextButton(num, rpc)
  local textbutton = num ~= nil and self["music_textbutton_"..num]
  if textbutton then
    if IsMusicPause(self) or self.current_music_num ~= num then
      self.current_music_num = num
      self.current_music_name = string.gsub(textbutton.image_normal, "%.tex$", "")
      self.music_panel_record:GetAnimState():PlayAnimation("loop"..self.current_music_num, true)
      self.music_panel_record:GetAnimState():SetDeltaTimeMultiplier(1)
      self.music_panel_pause:SetTextures("images/jx_car_hud/pause.xml", "pause.tex", "pause.tex", nil, "pause.tex")
      self:Refresh_Text_Pos(num)
      if rpc == true then
        SendModRPCToServer(GetModRPC("JX", "HUDPauseMusic"), self.current_music_name, num)
      end
    end
  end
end

function JX_Car_HUD:OnClick_Pause(rpc)
  if IsMusicPause(self) then
    self.music_panel_pause:SetTextures("images/jx_car_hud/pause.xml", "pause.tex", "pause.tex", nil, "pause.tex")
    self.music_panel_record:GetAnimState():SetDeltaTimeMultiplier(1)
    if rpc == true then
      SendModRPCToServer(GetModRPC("JX", "HUDPauseMusic"), self.current_music_name)
    end
  else
    self.music_panel_pause:SetTextures("images/jx_car_hud/pause.xml", "resume.tex", "resume.tex", nil, "resume.tex")
    self.music_panel_record:GetAnimState():SetDeltaTimeMultiplier(0)
    if rpc == true then
      SendModRPCToServer(GetModRPC("JX", "HUDPauseMusic"))
    end
  end
end

function JX_Car_HUD:Refresh_Text_Pos(num)
  for k, _ in ipairs(self.music_record_list) do
    self["music_textbutton_"..k]:Hide()
  end
  for i = 1, #self.music_textbutton_basepos do
    local real_num = num + i - 1
    if real_num > #self.music_record_list then
      real_num = real_num % #self.music_record_list
    end
    if self["music_textbutton_"..real_num] then
      self["music_textbutton_"..real_num]:SetPosition(self.music_textbutton_basepos[i].x, self.music_textbutton_basepos[i].y)
      self["music_textbutton_"..real_num]:Show()
    end
  end
end

function JX_Car_HUD:HUDOnHit()
  self.passenger:GetAnimState():SetMultColour(1, .5, .5, 1)
  if self.hit_colour_task then
    self.hit_colour_task:Cancel()
    self.hit_colour_task = nil
  end
  self.hit_colour_task = self.inst:DoTaskInTime(.4, function() self.passenger:GetAnimState():SetMultColour(1, 1, 1, 1) end)
end

function JX_Car_HUD:KillMusic()
  self.music_panel_pause:SetTextures("images/jx_car_hud/pause.xml", "resume.tex", "resume.tex", nil, "resume.tex")
  self.music_panel_record:GetAnimState():SetDeltaTimeMultiplier(0)
end

return JX_Car_HUD