local G = GLOBAL

local ImageButton = require "widgets/imagebutton"

AddModRPCHandler("JX", "JX_Trash_Can_Button", function(inst)
    local cont = inst.jx_trash_jan_container
    if cont and cont:IsValid() and cont.components.container then
      if cont.components.container:IsOpen() then
        cont.components.container:Close()
      else
        cont.components.container:Open(inst)
      end
    end
end)

AddClassPostConstruct("screens/playerhud", function(self)
    local w, h = G.TheSim:GetScreenSize()
    local sw, sh = w/2560, h/1440
    local imagename = "jx_trash_can_button"
    self.jx_trash_can_button = self:AddChild(ImageButton("images/jx_trash_can_hud/"..imagename..".xml", imagename..".tex", imagename..".tex", nil, imagename..".tex"))
    self.jx_trash_can_button:SetNormalScale(1*sw, 1*sw, 1*sw)
    self.jx_trash_can_button:SetFocusScale(1.1*sw, 1.1*sw, 1.1*sw)
    self.jx_trash_can_button:SetPosition(2470 * sw, 230 * sh)
    self.jx_trash_can_button:SetOnDown(function()
      G.SendModRPCToServer(G.GetModRPC("JX", "JX_Trash_Can_Button"))
    end)
    self.jx_trash_can_button:Hide()
end)

AddClientModRPCHandler("JX", "JX_Trash_Can_Button", function(show)
    local player = G.ThePlayer
    if player == nil or player.HUD == nil or player.HUD.jx_trash_can_button == nil then
      return
    end
    if show then
      player.HUD.jx_trash_can_button:Show()
    else
      player.HUD.jx_trash_can_button:Hide()
    end
end)