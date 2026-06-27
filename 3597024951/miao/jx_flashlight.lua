local G = GLOBAL
-------------------------
--RPC
AddClientModRPCHandler("JX", "FlashLightStartUpdatePos", function()
  local player = G.ThePlayer
  if player and player.components.player_jx_flashlight_client then
    player.components.player_jx_flashlight_client:Start()
  end
end)

AddClientModRPCHandler("JX", "FlashLightStopUpdatePos", function()
  local player = G.ThePlayer
  if player and player.components.player_jx_flashlight_client then
    player.components.player_jx_flashlight_client:Stop()
  end
end)

-----------------------
AddPlayerPostInit(function(inst)
    inst:AddComponent("player_jx_flashlight")
    if not G.TheWorld.ismastersim then
      inst:AddComponent("player_jx_flashlight_client")
      return
    end
end)
--------------------------