local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"

local JX_Piano_HUD = Class(Widget, function(self)
    Widget._ctor(self, "JX_Piano_HUD")
    
    local w, h = TheSim:GetScreenSize()
    local sw, sh = w/2560, h/1440
    
    self.panel_1 = self:AddChild(Image("images/jx_piano_hud/jx_piano_panel_1.xml", "jx_piano_panel_1.tex", "jx_piano_panel_1.tex"))
    self.panel_1:SetPosition(800*sw, 800*sh)
    self.panel_1:SetScale(sw, sh, 1)
    self.panel_1:Hide()
    
    self.panel_1_button_1 = self.panel_1:AddChild(TextButton("panel_1_button_1"))
    self.panel_1_button_1:SetText(STRINGS.UI.JX_PIANO_CLOSE) -- "关闭"
    self.panel_1_button_1:SetPosition(-2, -63)
    self.panel_1_button_1:SetOnClick(function() self:OnClick_Panel_1_Button_1() end)
    
    self.panel_1_button_2 = self.panel_1:AddChild(TextButton("panel_1_button_2"))
    self.panel_1_button_2:SetText(STRINGS.UI.JX_PIANO_APPRECIATE) -- "鉴赏模式"
    self.panel_1_button_2:SetTextSize(35)
    self.panel_1_button_2:SetPosition(-88, -2)
    self.panel_1_button_2:SetOnClick(function() self:OnClick_Panel_1_Button_2() end)
    
    self.panel_1_button_3 = self.panel_1:AddChild(TextButton("panel_1_button_3"))
    self.panel_1_button_3:SetText(STRINGS.UI.JX_PIANO_FREEPLAY) -- "自由演奏"
    self.panel_1_button_3:SetTextSize(35)
    self.panel_1_button_3:SetPosition(88, -2)
    self.panel_1_button_3:SetOnClick(function() self:OnClick_Panel_1_Button_3() end)
    
    ---
    self.panel_2 = self:AddChild(Image("images/jx_piano_hud/jx_piano_panel_2.xml", "jx_piano_panel_2.tex", "jx_piano_panel_2.tex"))
    self.panel_2:SetPosition(799*sw, 800*sh)
    self.panel_2:SetScale(sw, sh, 1)
    self.panel_2:Hide()
    
    self.panel_2_button_1 = self.panel_2:AddChild(TextButton("panel_2_button_1"))
    self.panel_2_button_1:SetText(STRINGS.UI.JX_PIANO_BACK) -- "返回"
    self.panel_2_button_1:SetPosition(-120, 65)
    self.panel_2_button_1:SetOnClick(function() self:OnClick_Panel_2_Button_1() end)
    
    self.panel_2_button_2 = self.panel_2:AddChild(TextButton("panel_2_button_2"))
    self.panel_2_button_2:SetText(STRINGS.UI.JX_PIANO_STOP_MUSIC) -- "停止播放"
    self.panel_2_button_2:SetPosition(-2, 65)
    self.panel_2_button_2:SetOnClick(function() self:OnClick_Panel_2_Button_2() end)
    
    self.panel_2_button_3 = self.panel_2:AddChild(TextButton("panel_2_button_3"))
    self.panel_2_button_3:SetText(STRINGS.UI.JX_PIANO_RANDOM) -- "随机"
    self.panel_2_button_3:SetPosition(116, 65)
    self.panel_2_button_3:SetOnClick(function() self:OnClick_Panel_2_Button_3() end)
    
    self.panel_2_button_4 = self.panel_2:AddChild(ImageButton("images/crafting_menu.xml", "scrollbar_arrow_down_hl.tex", "scrollbar_arrow_down_hl.tex", nil, "scrollbar_arrow_down_hl.tex"))
    self.panel_2_button_4:SetNormalScale(.5, .5, .5)
    self.panel_2_button_4:SetFocusScale(.7, .7, .7)
    self.panel_2_button_4:SetPosition(150, -30)
    self.panel_2_button_4:SetOnClick(function() self:OnClick_Panel_2_Button_4() end)
    
    self.panel_2_button_5 = self.panel_2:AddChild(ImageButton("images/crafting_menu.xml", "scrollbar_arrow_up_hl.tex", "scrollbar_arrow_up_hl.tex", nil, "scrollbar_arrow_up_hl.tex"))
    self.panel_2_button_5:SetNormalScale(.5, .5, .5)
    self.panel_2_button_5:SetFocusScale(.7, .7, .7)
    self.panel_2_button_5:SetPosition(150, 10)
    self.panel_2_button_5:SetOnClick(function() self:OnClick_Panel_2_Button_5() end)
    
    ---
    self.music_record_list =
    {
      "CANNO",                 --卡农
      "LE_CYGNE",              --天鹅
      "NOCTURNE",              --小夜曲
      "THE_BLUE_DANUBE",       --蓝色多瑙河
      "MINUET",                --D大调小步舞曲
      "PATHETIQUE_SONATA",     --悲怆奏鸣曲
      --"MOONLIGHT_SONATA",      --月光奏鸣曲
      "FROHLICHER_LANDMANN",   --快乐的农夫
      "LITTLE_STAR",           --小星星
      "COUNTRYSIDE_AFTERNOON", --田园午后
      "MAID_HEART",            --女仆的心事
      "CAT_MORNING",           --猫先生的早晨
    }
    self.current_music_num = 1
    self.music_textbutton_basepos =
    {
      {x = 10, y = 38},
      {x = 10, y = 6},
      {x = 10, y = -26},
      {x = 10, y = -58},
    }
    
    for k, v in ipairs(self.music_record_list) do
      local button = self.panel_2:AddChild(TextButton("music_textbutton_"..k))
      local _, h = button.text:GetRegionSize()
      button.text:SetRegionSize(200, h + 8)
      button.text:SetHAlign(ANCHOR_LEFT)
      button:SetText(STRINGS.JX_PIANO_MUSIC[v])
      button:SetOnClick(function() self:OnClick_Music_TextButton(k) end)
      button.ongainfocus = function()
        button.text:SetRegionSize(400, h + 8)--为了匹配英文文本长度
        local _, y = button.text:GetPositionXYZ()
        button.text:SetPosition(100, y)
      end
      button.onlosefocus = function()
        button.text:SetRegionSize(200, h + 8)
        local _, y = button.text:GetPositionXYZ()
        button.text:SetPosition(0, y)
      end
      button:Hide()
      self["music_textbutton_"..k] = button
    end
    self.inst:DoTaskInTime(0, function() self:Refresh_Text_Pos(self.current_music_num) end)
    
    ---
    self.tutorial_board = self:AddChild(Image("images/jx_piano_hud/jx_piano_tutorial_board.xml", "jx_piano_tutorial_board.tex", "jx_piano_tutorial_board.tex"))
    self.tutorial_board:SetPosition(700*sw, 900*sh)
    self.tutorial_board:SetScale(sw, sh, 1)
    self.tutorial_board:Hide()
    
    self.tutorial_text = self.tutorial_board:AddChild(Text(DEFAULTFONT, 30, STRINGS.JX_PIANO_TUTORIAL_TEXT, {.9, .8, .6, 1}))
    self.tutorial_text:SetPosition(0, 0)
    
    self.tutorial_text_button_1 = self.tutorial_board:AddChild(TextButton("tutorial_text_button_1"))
    self.tutorial_text_button_1:SetText(STRINGS.UI.JX_PIANO_CLOSE) -- "关闭"
    self.tutorial_text_button_1:SetPosition(0, -112)
    self.tutorial_text_button_1:SetOnClick(function() self:OnClick_Tutorial_Text_Button_1() end)
    
    ---
    self.keyboard = self:AddChild(Image("images/jx_piano_hud/jx_piano_key.xml", "jx_piano_key.tex", "jx_piano_key.tex"))
    self.keyboard:SetPosition(700*sw, 430*sh)
    self.keyboard:SetScale(sw, sh, 1)
    self.keyboard:Hide()
    
    self.keysound = self.keyboard:AddChild(ImageButton("images/scoreboard.xml", "chat.tex", "chat.tex", nil, "chat.tex"))
    self.keysound:SetNormalScale(1, 1, 1)
    self.keysound:SetFocusScale(1.1, 1.1, 1.1)
    self.keysound:SetPosition(-400, 320)
    self.keysound:SetOnClick(function()
      local mute = self.keysound.image_normal == "mute.tex"
      local name = mute and "chat" or "mute"
      local text = mute and STRINGS.JX_PIANO_CHAT or STRINGS.JX_PIANO_MUTE --"公开音频"和"私人音频"
      self.keysound:SetTextures("images/scoreboard.xml", name..".tex", name..".tex", nil, name..".tex")
      self.keysound_text:SetString(text)
      if ThePlayer then
        if mute then
          ThePlayer.JX_PIANO_PLAY_ALONE = false
        else
          ThePlayer.JX_PIANO_PLAY_ALONE = true
        end
      end
    end)
    
    self.keysound_text = self.keysound:AddChild(Text(DEFAULTFONT, 30, STRINGS.JX_PIANO_CHAT))
    self.keysound_text:SetPosition(0, 80)
    ---
end)

function JX_Piano_HUD:OnClick_Panel_1_Button_1()
  self.panel_1:Hide()
end

function JX_Piano_HUD:OnClick_Panel_1_Button_2()
  self.panel_1:Hide()
  self.panel_2:Show()
end

function JX_Piano_HUD:OnClick_Panel_1_Button_3()
  self.panel_1:Hide()
  self.tutorial_board:Show()
  SendModRPCToServer(GetModRPC("JX", "JX_Piano_FreePlay"))
end

function JX_Piano_HUD:OnClick_Panel_2_Button_1()
  self.panel_2:Hide()
  self.panel_1:Show()
end

function JX_Piano_HUD:OnClick_Panel_2_Button_2()
  SendModRPCToServer(GetModRPC("JX", "JX_Piano_StopMusic"))
end

function JX_Piano_HUD:OnClick_Panel_2_Button_3()
  SendModRPCToServer(GetModRPC("JX", "JX_Piano_PlayMusic"), "RANDOM")
end

function JX_Piano_HUD:OnClick_Panel_2_Button_4()
  self.current_music_num = self.current_music_num + 4
  if self.current_music_num > #self.music_record_list then
    self.current_music_num = self.current_music_num % #self.music_record_list
  end
  self:Refresh_Text_Pos(self.current_music_num)
end

function JX_Piano_HUD:OnClick_Panel_2_Button_5()
  self.current_music_num = self.current_music_num - 4
  if self.current_music_num < 1 then
    self.current_music_num = self.current_music_num + #self.music_record_list
  end
  self:Refresh_Text_Pos(self.current_music_num)
end

function JX_Piano_HUD:OnClick_Music_TextButton(num)
  local textbutton = num ~= nil and self["music_textbutton_"..num]
  if textbutton then
    self.current_music_num = num
    local name = self.music_record_list[num]
    if name then
      self:Refresh_Text_Pos(num)
      SendModRPCToServer(GetModRPC("JX", "JX_Piano_PlayMusic"), name)
    end
  end
end

function JX_Piano_HUD:OnClick_Tutorial_Text_Button_1()
  self.tutorial_board:Hide()
  SendModRPCToServer(GetModRPC("JX", "JX_Piano_Close_Tutorial"))
end

function JX_Piano_HUD:Refresh_Text_Pos(num)
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

return JX_Piano_HUD