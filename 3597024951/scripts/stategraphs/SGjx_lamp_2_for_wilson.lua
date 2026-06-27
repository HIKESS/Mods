AddStategraphState("wilson",
  State{
    name = "jx_extinguish_lamp2",
    tags = { "doing", "busy", },
    onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("action_uniqueitem_pre")
      inst.AnimState:PushAnimation("whistle", false)
    end,
    timeline =
    {
      TimeEvent(20 * FRAMES, function(inst)
          if inst:PerformBufferedAction() then
            --inst.SoundEmitter:PlaySound(inst.sg.statemem.sound or "dontstarve/common/together/houndwhistle")
          else
					  inst.sg.statemem.action_failed = true
					  inst.AnimState:SetFrame(35)
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
      EventHandler("animqueueover", function(inst)
          if inst.AnimState:AnimDone() then
            inst.sg:GoToState("idle")
          end
      end),
    },
  }
)

AddStategraphState("wilson_client",
  State{
    name = "jx_extinguish_lamp2",
    tags = { "doing", "busy", },
    server_states = { "jx_extinguish_lamp2" },
    onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("action_uniqueitem_pre")
      inst.AnimState:PushAnimation("whistle", false)

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