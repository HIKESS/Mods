--烛台
---
local G = GLOBAL
---
local jx_extinguish_lamp2 = AddAction("JX_EXTINGUISH_LAMP", G.STRINGS.ACTIONS.EXTINGUISH_LAMP2--[["吹灭"]], function(act)
    if act.target then
      act.target:PushEvent("jx_extinguish_lamp2")
      return true
    end
end)
jx_extinguish_lamp2.priority = 2

AddComponentAction("SCENE", "jx_lamp", function(inst, doer, actions, right)
    if inst:HasTag("jx_lamp_2") and not inst:HasTag("canlight") and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
      table.insert(actions, G.ACTIONS.JX_EXTINGUISH_LAMP)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_extinguish_lamp2, "jx_extinguish_lamp2"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_extinguish_lamp2, "jx_extinguish_lamp2"))