AddStategraphState("wilson",
  State{
    name = "jx_drink",
    tags = { "doing", "busy", },
    onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("jx_drink")
      inst.sg.statemem.action = inst:GetBufferedAction()
      if inst.sg.statemem.action ~= nil then
        local invobject = inst.sg.statemem.action.invobject
        local symbol = "actions_"..invobject.prefab:sub(4)
        inst.AnimState:OverrideSymbol("ghostly_elixirs_swap", "jx_vending_machine", symbol)
      end
    end,
    timeline =
    {
      TimeEvent(9 * FRAMES, function(inst)
          if not inst:PerformBufferedAction() then
					  inst.sg.statemem.action_failed = true
					  inst.sg:GoToState("idle")
          end
      end),
			TimeEvent(27 * FRAMES, function(inst)
			  	if inst.sg.statemem.action_failed then
				  	inst.sg:RemoveStateTag("busy")
			  	end
			end),
			TimeEvent(30 * FRAMES, function(inst)
			  	inst.sg:RemoveStateTag("busy")
			end),
    },
    events =
    {
      EventHandler("animover", function(inst)
          if inst.AnimState:AnimDone() then
            inst.sg:GoToState("idle")
          end
      end),
    },
  }
)

AddStategraphState("wilson_client",
  State{
    name = "jx_drink",
    tags = { "doing", "busy", },
    server_states = { "jx_drink" },
    onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("jx_drink")
      inst:PerformPreviewBufferedAction()
      inst.sg:SetTimeout(2)
    end,
    onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
        if inst.entity:FlattenMovementPrediction() then
          inst.sg:GoToState("idle", "noanim")
        end
      elseif inst.bufferedaction == nil then
        inst.sg:GoToState("idle", true)
      end
    end,
    ontimeout = function(inst)
      inst:ClearBufferedAction()
      inst.sg:GoToState("idle", true)
    end,
  }
)