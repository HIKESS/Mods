------------
--drive_idle
AddStategraphState("wilson", State{
    name = "drive_idle",
    tags = { "idle", "canrotate", "drive_valid" },
    onenter = function(inst)
      inst.AnimState:PlayAnimation("idle_loop", true)
      inst.sg:SetTimeout(1)
    end,
    ontimeout = function(inst)
      local mount = inst.components.rider and inst.components.rider:GetMount()
      if mount == nil then
        inst.sg:GoToState("idle")
        return
      end
      inst.sg:GoToState("drive_idle")
    end
})
------------
--drive_run_start
AddStategraphState("wilson", State{
    name = "drive_run_start",
    tags = { "runing", "canrotate", "drive_valid" },
    onenter = function(inst)
      inst.AnimState:PlayAnimation("run_pre")
    end,
    events =
    {
      EventHandler("animover", function(inst)
        if inst.AnimState:AnimDone() then
          inst.sg:GoToState("drive_run")
        end
      end),
    },
})
------------
--drive_run
AddStategraphState("wilson", State{
    name = "drive_run",
    tags = { "runing", "canrotate", "drive_valid" },
    onenter = function(inst)
      inst.AnimState:PlayAnimation("run_loop", true)
    end,
})
------------
--drive_run_stop
AddStategraphState("wilson", State{
    name = "drive_run_stop",
    tags = { "idle", "canrotate", "drive_valid" },
    onenter = function(inst)
      inst.AnimState:PlayAnimation("run_pst")
    end,
    events =
    {
      EventHandler("animover", function(inst)
        if inst.AnimState:AnimDone() then
          inst.sg:GoToState("drive_idle")
        end
      end),
    },
})
------------
--drive_run_reverse
AddStategraphState("wilson", State{
    name = "drive_run_reverse",
    tags = { "reverse", "canrotate", "drive_valid" },
    onenter = function(inst)
      inst.AnimState:PlayAnimation("run_reverse", true)
    end,
})
-----------
--drive_run_reverse_stop
AddStategraphState("wilson", State{
    name = "drive_run_reverse_stop",
    tags = { "idle", "canrotate", "drive_valid" },
    onenter = function(inst)
      local time
      if inst.AnimState:IsCurrentAnimation("run_reverse") then
        time = inst.AnimState:GetCurrentAnimationTime()
      end
      
      inst.AnimState:PlayAnimation("run_reverse")
      
      if time then
        inst.AnimState:SetTime(time)
      end
    end,
    events =
    {
      EventHandler("animover", function(inst)
        if inst.AnimState:AnimDone() then
          inst.sg:GoToState("drive_idle")
        end
      end),
    },
})
---------------
--mounted_idle
AddStategraphPostInit("wilson", function(sg)
    local state = sg.states["mounted_idle"]
    if state then
      local old_onenter = state.onenter
      state.onenter = function(inst, pushanim)
        local mount = inst.components.rider and inst.components.rider:GetMount()
        if mount and mount:HasTag("jx_car") then
          inst.sg:GoToState("drive_idle")
          return
        end
        old_onenter(inst, pushanim)
      end
    end
end)
-----------------
--dismount
AddStategraphPostInit("wilson", function(sg)
    local state = sg.states["dismount"]
    if state then      
      local old_onenter = state.onenter
      state.onenter = function(inst)
        local mount = inst.components.rider and inst.components.rider:GetMount()
        if mount and mount:HasTag("jx_car") then
          inst.components.locomotor:StopMoving()
          if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:RemotePausePrediction()
          end
          inst.sg:GoToState("idle")
          return
        end
        old_onenter(inst)
      end
    end
end)
-----------------------------
--talk
AddStategraphPostInit("wilson", function(sg)
    local state = sg.states["talk"]
    if state then      
      local old_onenter = state.onenter
      state.onenter = function(inst, noanim)
        local mount = inst.components.rider and inst.components.rider:GetMount()
        if mount and mount:HasTag("jx_car") then
          old_onenter(inst, true)
        else
          old_onenter(inst, noanim)
        end
      end
    end
end)
-----------------------------
--jx_spray
AddStategraphState("wilson", State{
    name = "jx_spray",
    tags = { "idle" },
    
    onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("light_fire")
      inst.AnimState:PushAnimation("light_fire_pst", false)
    end,
    
    timeline =
    {
      TimeEvent(10 * FRAMES, function(inst)
        if inst:PerformBufferedAction() then
          inst.SoundEmitter:PlaySound("qol1/wax_spray/spritz")
        end
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
})
AddStategraphState("wilson_client", State{
    name = "jx_spray",
    tags = {"idle"},
    server_states = { "jx_spray" },
    
    onenter = function(inst)
      inst.components.locomotor:Stop()
      if not inst.sg:ServerStateMatches() then
        inst.AnimState:PlayAnimation("light_fire")
      end
      
      inst:PerformPreviewBufferedAction()
      inst.sg:SetTimeout(2)
    end,
    
    onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
        if inst.entity:FlattenMovementPrediction() then
          inst.sg:GoToState("idle", "noanim")
        end
      elseif inst.bufferedaction == nil then
        inst.AnimState:PlayAnimation("light_fire_pst")
        inst.sg:GoToState("idle", true)
      end
    end,
    ontimeout = function(inst)
      inst:ClearBufferedAction()
      inst.AnimState:PlayAnimation("light_fire_pst")
      inst.sg:GoToState("idle", true)
    end,
})
------------------------------
--dolongaction
AddStategraphPostInit("wilson", function(sg)
    local state = sg.states["dolongaction"]
    if state then      
      local old_onenter = state.onenter
      state.onenter = function(inst, timeout)
        local mount = inst.components.rider and inst.components.rider:GetMount()
        if mount and mount:HasTag("jx_car") then
          inst.sg:GoToState("drive_idle")
          return
        end
        old_onenter(inst, timeout)
      end
    end
end)