--浴缸
---
local G = GLOBAL
---
local jx_bath = AddAction("JX_BATH", G.STRINGS.ACTIONS.BATH--[["泡澡"]], function(act)
    if act.target and act.target.components.jx_bath and act.target.components.jx_bath.current_player == nil then
      act.target:PushEvent("onstartbath", { player = act.doer })
      return true
    else
      return false
    end
end)

AddComponentAction("SCENE", "jx_bath", function(inst, doer, actions, right)
    if inst:HasTag("jx_bathtub") and not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
      table.insert(actions, G.ACTIONS.JX_BATH)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_bath, "jx_bath"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_bath, "jx_bath"))
-----------
local function ondespawn(inst)
  if inst.sg:HasStateTag("bath") then
    inst:ClearBufferedAction()
  end
  if inst.bathtub ~= nil then
    inst.bathtub.components.jx_bath:OnPlayerDespawn()
    inst.bathtub = nil
  end
end

AddPlayerPostInit(function(inst)
    if not G.TheWorld.ismastersim then return end
    inst:ListenForEvent("player_despawn", ondespawn)
end)