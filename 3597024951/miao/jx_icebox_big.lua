AddClientModRPCHandler("JX", "JX_Icebox_PlaySound", function(sound)
    local player = GLOBAL.ThePlayer
    if player and sound then
      player.SoundEmitter:PlaySound("jx_icebox_big/jx_icebox_big/"..sound)
    end
end)