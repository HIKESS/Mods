local function SetStartBathState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:AddImmunity("bath")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:IgnoreAll("bath")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Disable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(false)
        inst.components.playercontroller:Enable(false)
    end
    inst:OnSleepIn()
    inst.components.inventory:Hide()
    inst:PushEvent("ms_closepopups")
    inst:ShowActions(false)
end

local function SetStopBathState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:RemoveImmunity("bath")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("bath")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Enable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(true)
        inst.components.playercontroller:Enable(true)
    end
    inst:OnWakeUp()
    inst.components.inventory:Show()
    inst:ShowActions(true)
end

AddStategraphState("wilson",
  State{
    name = "jx_bath",
    tags = { "bath", "busy", "noattack", },
    onenter = function(inst)
      inst.AnimState:PlayAnimation("pickup")
      inst.sg:SetTimeout(6 * FRAMES)
      SetStartBathState(inst)
    end,
    ontimeout = function(inst)
      local bufferedaction = inst:GetBufferedAction()
      if bufferedaction == nil then
        inst.AnimState:PlayAnimation("pickup_pst")
        inst.sg:GoToState("idle", true)
        return
      end
      local bathtub = bufferedaction.target
      if bathtub == nil or not bathtub:HasTag("jx_bathtub") or bathtub:HasTag("hasplayer") then
        inst:PushEvent("performaction", { action = inst.bufferedaction })
        inst:ClearBufferedAction()
        inst.AnimState:PlayAnimation("pickup_pst")
        inst.sg:GoToState("idle", true)
      else
        inst.bathtub = bathtub
        inst:PerformBufferedAction()
        --inst.components.health:SetInvincible(true)
        inst:Hide()
        if inst.Physics ~= nil then
          inst.Physics:Teleport(inst.Transform:GetWorldPosition())
        end
        if inst.DynamicShadow ~= nil then
          inst.DynamicShadow:Enable(false)
        end
        inst.sg:RemoveStateTag("busy")
        if inst.components.playercontroller ~= nil then
          inst.components.playercontroller:Enable(true)
        end
      end
    end,
    onexit = function(inst)
      --inst.components.health:SetInvincible(false)
      inst:Show()
      if inst.DynamicShadow ~= nil then
        inst.DynamicShadow:Enable(true)
      end
      if inst.bathtub ~= nil then
        SetStopBathState(inst)
        inst.bathtub:PushEvent("onstopbath", { player = inst})
        inst.bathtub = nil
      else
        SetStopBathState(inst)
      end
    end,
  }
)
AddStategraphState("wilson_client",
  State{
    name = "jx_bath",
    tags = { "bath", "busy", "noattack", },
    server_states = { "jx_bath" },
    onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("pickup")
      inst.AnimState:PushAnimation("pickup_lag", false)

      inst:PerformPreviewBufferedAction()
      inst.sg:SetTimeout(2)
    end,
    onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
        if inst.entity:FlattenMovementPrediction() then
          inst.sg:GoToState("idle", "noanim")
        end
      elseif inst.bufferedaction == nil then
        inst.AnimState:PlayAnimation("pickup_pst")
        inst.sg:GoToState("idle", true)
      end
    end,
    ontimeout = function(inst)
      inst:ClearBufferedAction()
      inst.AnimState:PlayAnimation("pickup_pst")
      inst.sg:GoToState("idle", true)
    end,
  }
)