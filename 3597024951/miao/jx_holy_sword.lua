-------------------------
local G = GLOBAL
----------------------------
--可以走a的玩家 userid 表
G.JX_ZOUA_ENABLE = {}

--用于游戏中途添加走a名单
G.FUNCTION_JX_ZOUA_ENABLE = function(name, userid, player)
  if name == nil and userid == nil and player == nil then
    return
  end
  for _, p in ipairs(G.AllPlayers) do
    if (p == player or p.name == name or p.userid == userid)
      and p.jx_zoua_onattackother ~= nil
      and not table.contains(G.JX_ZOUA_ENABLE, p.userid)
    then
      table.insert(G.JX_ZOUA_ENABLE, p.userid)
      p:ListenForEvent("onattackother", p.jx_zoua_onattackother)
      break
    end
  end
end

--用于游戏中途移除走a名单
G.FUNCTION_JX_ZOUA_DISABLE = function(name, userid, player)
  if name == nil and userid == nil and player == nil then
    return
  end
  for i, p in ipairs(G.AllPlayers) do
    if (p == player or p.name == name or p.userid == userid)
      and p.jx_zoua_onattackother ~= nil
      and table.contains(G.JX_ZOUA_ENABLE, p.userid)
    then
      table.remove(G.JX_ZOUA_ENABLE, i)
      p:RemoveEventCallback("onattackother", p.jx_zoua_onattackother)
      break
    end
  end
end

--[[
控制台示例
FUNCTION_JX_ZOUA_DISABLE("驯猫糕手")
FUNCTION_JX_ZOUA_ENABLE("驯猫糕手")
FUNCTION_JX_ZOUA_DISABLE(nil, "KU_gBRagGHP")
FUNCTION_JX_ZOUA_ENABLE(nil, "KU_gBRagGHP")
]]

------------
local function onattackother(inst, data)
  if inst.userid and table.contains(G.JX_ZOUA_ENABLE, inst.userid) then
    local weapon = inst.components.combat and inst.components.combat:GetWeapon()
    if data == nil or data.weapon == nil 
      or weapon == nil or weapon ~= data.weapon
    then
      return
    end
    if data.weapon.prefab == "pocketwatch_weapon"
      and G.JX_ZOUA_POCKETWATCH_ENABLE == true
    then--警钟实际上是检查a
      if inst.sg and inst.sg:HasStateTag("attack") then
        local item
        for _, v in pairs(inst.components.inventory.itemslots) do
          if v and v.prefab == "nightmarefuel" then
            item = v
            break
          end
        end
        if item and item.components.inspectable
          and inst.components.inventory and inst.components.talker
        then
          inst.sg:GoToState("idle")
          local desc = item.components.inspectable:GetDescription(inst)
          inst.components.talker:Say(desc)
        end
      end
    elseif inst.components.locomotor then
      local radius = .17
      local x, y, z = inst.Transform:GetWorldPosition()
      local rnd = math.random(2) == 1 and 80 or -80
      local theta = (inst.Transform:GetRotation() + rnd) * G.DEGREES
      local x1 = x + radius * math.cos(theta)
      local z1 = z - radius * math.sin(theta)
      inst.components.locomotor:GoToPoint(G.Vector3(x1, y, z1))
      inst:DoTaskInTime(2 * FRAMES, function()
        if inst.sg and inst.sg:HasStateTag("moving") then
          inst.sg:GoToState("idle")
        end
      end)
    end
  else
    inst:RemoveEventCallback("onattackother", inst.jx_zoua_onattackother)
  end
end

AddPlayerPostInit(function(inst)
    if not G.TheWorld.ismastersim then return end
    inst.jx_zoua_onattackother = onattackother
end)
----------------------------------------
--HUD
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"

local function OnClickButton()
  local button = G.ThePlayer and G.ThePlayer.HUD and G.ThePlayer.HUD.jx_holy_sword_button
  if button == nil then return end
  local enable = button.image_normal == "jx_holy_sword_button_off.tex"
  local name = enable and "jx_holy_sword_button_on" or "jx_holy_sword_button_off"
  button:SetTextures("images/jx_holy_sword_hud/"..name..".xml", name..".tex", name..".tex", nil, name..".tex")
  G.SendModRPCToServer(G.GetModRPC("JX", "JX_Holy_Sword_Button"), enable)
  G.ThePlayer:EnableMovementPrediction(not enable)
end

AddClassPostConstruct("screens/playerhud", function(self)
    local w, h = G.TheSim:GetScreenSize()
    local sw, sh = w/2560, h/1440
    
    local default = "jx_holy_sword_button_off"
    self.jx_holy_sword_button = self:AddChild(ImageButton("images/jx_holy_sword_hud/"..default..".xml", default..".tex", default..".tex", nil, default..".tex"))
    self.jx_holy_sword_button:SetNormalScale(1.5*sw, 1.5*sw, 1.5*sw)
    self.jx_holy_sword_button:SetFocusScale(1.65*sw, 1.65*sw, 1.65*sw)
    self.jx_holy_sword_button:SetOnGainFocus(function() self.jx_holy_sword_button_text:Show() end)
    self.jx_holy_sword_button:SetOnLoseFocus(function() self.jx_holy_sword_button_text:Hide() end)
    self.jx_holy_sword_button:SetOnClick(OnClickButton)
    self.jx_holy_sword_button.stopclicksound = true
    self.jx_holy_sword_button:SetPosition(200*sw, 150*sh)
    self.jx_holy_sword_button:Hide()
    
    self.jx_holy_sword_button_text = self.jx_holy_sword_button:AddChild(Text(DEFAULTFONT, 30, STRINGS.JX_HOLY_SWORD_TEXT, {.9, .8, .6, 1}))
    self.jx_holy_sword_button_text:SetScale(1.5*sw)
    self.jx_holy_sword_button_text:SetPosition(3*sw, 50*sh)
    self.jx_holy_sword_button_text:Hide()
end)

AddClientModRPCHandler("JX", "JX_Holy_Sword_Show", function(val)
    local hud = G.ThePlayer and G.ThePlayer.HUD
    local button = hud and hud.jx_holy_sword_button
    if button == nil then return end
    
    local w, h = G.TheSim:GetScreenSize()
    local sw, sh = w/2560, h/1440
    
    if val then
      local time_delay = .2
      local time_anim = 1
      local scale_from = 1.7
      local scale_to = 1
      local pos_from = Vector3(600*sw, 400*sh, 0)
      local pos_to = Vector3(200*sw, 150*sh, 0)
      button:SetScale(scale_from)
      button:SetPosition(pos_from)
      button:Show()
      if hud.holy_sword_delay_task then
        hud.holy_sword_delay_task:Cancel()
        hud.holy_sword_delay_task = nil
      end
      hud.holy_sword_delay_task = hud.inst:DoTaskInTime(time_delay, function()
        button:ScaleTo(scale_from, scale_to, time_anim)
        button:MoveTo(pos_from, pos_to, time_anim)
      end)
      
      local enable = button.image_normal == "jx_holy_sword_button_on.tex"
      G.SendModRPCToServer(G.GetModRPC("JX", "JX_Holy_Sword_Button"), enable)
      G.ThePlayer:EnableMovementPrediction(not enable)
      
    else
      button:Hide()
      G.ThePlayer:EnableMovementPrediction(true)
    end
end)

AddModRPCHandler("JX", "JX_Holy_Sword_Button", function(inst, enable)
  if enable then
    G.FUNCTION_JX_ZOUA_ENABLE(nil, nil, inst)
    if inst and inst.components.inventory and inst.components.inventory:EquipHasTag("jx_holy_sword") then
      inst.AnimState:ClearOverrideSymbol("swap_object")
      inst.AnimState:OverrideSymbol("swap_object", "swap_jx_holy_sword", "swap_spear_2")
    end
  else
    G.FUNCTION_JX_ZOUA_DISABLE(nil, nil, inst)
    if inst and inst.components.inventory and inst.components.inventory:EquipHasTag("jx_holy_sword") then
      inst.AnimState:ClearOverrideSymbol("swap_object")
      inst.AnimState:OverrideSymbol("swap_object", "swap_jx_holy_sword", "swap_spear")
    end
  end
end)