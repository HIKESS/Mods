local G = GLOBAL

local jx_drink = AddAction("JX_DRINK", G.STRINGS.ACTIONS.JX_DRINK, function(act)
    local targ = act.target or act.invobject
    if act.doer ~= nil and targ ~= nil and targ:HasTag("jx_drinks") then
      if act.doer.userid then
        local sound_name = (targ.prefab == "jx_drink_cola" and "cola") or (targ.prefab == "jx_drink_coffee" and "coffee") or "tea"
        SendModRPCToClient(GetClientModRPC("JX", "JX_Drinks_Sound"), act.doer.userid, sound_name)
      end
      act.doer:AddDebuff("buff_"..targ.prefab, "buff_"..targ.prefab)
      if targ.components.stackable then
        targ.components.stackable:Get():Remove()
      else
        targ:Remove()
      end
      return true
    end
    return false
end)
jx_drink.rmb = true
jx_drink.mount_valid = true

AddComponentAction("INVENTORY", "jx_drink", function(inst, doer, actions, right)
    table.insert(actions, jx_drink)
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_drink, "jx_drink"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_drink, "jx_drink"))

AddClientModRPCHandler("JX", "JX_Vending_Machine_Sound", function(sound_name)
    if sound_name == "jx_bankatm_open" then
      G.TheFocalPoint.SoundEmitter:PlaySound("jx_bankatm_open/jx_bankatm_open/jx_bankatm_open")
    else
      G.TheFocalPoint.SoundEmitter:PlaySound("jx_sound_8/jx_sound_8/"..sound_name)
    end
end)

AddClientModRPCHandler("JX", "JX_Drinks_Sound", function(sound_name)
    G.TheFocalPoint.SoundEmitter:PlaySound("jx_sound_9/jx_sound_9/"..sound_name)
end)