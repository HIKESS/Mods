--//////////////////////////////////////////
--这是一个给玩家用的服务器端与客户端双端组件
--主要作用是将手持者屏幕上的服务器端光源隐藏
--手持者屏幕上只显示客户端光源
--//////////////////////////////////////////

local Player_Jx_FlashLight = Class(function(self, inst)
    self.inst = inst
    
    self.lights = {}
    for i = 1, TUNING.JX_TUNING.JX_FLASHLIGHT_LIGHTNUM do
      local idx = i
      self.lights[idx] = net_entity(inst.GUID, "jx_flashlight_light_"..idx, "jx_flashlight_dirty_"..idx)
      if not TheWorld.ismastersim then
        self.inst:ListenForEvent("jx_flashlight_dirty_"..idx, function()
          if ThePlayer and self.inst ~= ThePlayer then
            return
          end
          local target = self.lights[idx]:value()
          if target and target.Light then
            target.Light:Enable(false)
          end
        end)
      end
    end
end)

return Player_Jx_FlashLight