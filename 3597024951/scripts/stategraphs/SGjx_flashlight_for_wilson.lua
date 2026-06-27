local function DoEquipmentFoleySounds(inst)
  if inst.components.inventory then
    for _, v in pairs(inst.components.inventory.equipslots) do
      if v.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
      end
    end
  elseif inst.replica.inventory then
    for _, v in pairs(inst.replica.inventory:GetEquips()) do
      if v.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
      end
    end
  end
end

local function DoFoleySounds(inst)
  DoEquipmentFoleySounds(inst)
	if inst.foleyoverridefn and inst:foleyoverridefn(nil, true) then
		return
	elseif inst.foleysound then
    inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
  end
end

local DoRunSounds = function(inst)
  if inst.sg.mem.footsteps > 3 then
    PlayFootstep(inst, .6, true)
  else
    inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
    PlayFootstep(inst, 1, true)
  end
end

AddStategraphState("wilson", --run_start_jx_flashlight
    State{
        name = "run_start_jx_flashlight",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            inst.sg.mem.footsteps = 0
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("jx_flashlight_walk_pre")
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,
        
        timeline =
        {
          TimeEvent(4 * FRAMES, function(inst)
            if inst.sg.statemem.normal then
              PlayFootstep(inst, nil, true)
              DoFoleySounds(inst)
            end
          end),
        },

        events =
        {
          EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
              inst.sg:GoToState("run_jx_flashlight")
            end
          end),
        },
    }
)

AddStategraphState("wilson", --run_jx_flashlight
    State{
        name = "run_jx_flashlight",
        tags = { "moving", "running", "canrotate", "autopredict", "overridelocomote" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("channelcast_oh_walk") then
              inst.AnimState:PlayAnimation("jx_flashlight_walk", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,
        
        timeline =
        {
          TimeEvent(1 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
          end),
          TimeEvent(12 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
          end),
        },
        
        events =
        {
          EventHandler("locomote", function(inst, data)
            if inst.sg:HasStateTag("overridelocomote") then
              local is_moving = inst.sg:HasStateTag("moving")
              local should_move = inst.components.locomotor:WantsToMoveForward()
              if is_moving and not should_move then
                if inst:HasTag("acting") then
                  inst.sg:GoToState("acting_run_stop")
                else
                  inst.sg:GoToState("run_stop_jx_flashlight")
                end
              end
            end
          end),
        },
        
        ontimeout = function(inst)
          if inst.components.inventory and inst.components.inventory:EquipHasTag("flashlight_ison") then
            inst.sg:GoToState("run_jx_flashlight")
          else
            inst.sg:GoToState("run_stop_jx_flashlight")
          end
        end,
    }
)

AddStategraphState("wilson", --run_stop_jx_flashlight
    State{
        name = "run_stop_jx_flashlight",
        tags = { "canrotate", "idle", "autopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jx_flashlight_idle", true)
        end,
        
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

AddStategraphState("wilson_client", --run_start_jx_flashlight
    State{
        name = "run_start_jx_flashlight",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
          inst.sg.mem.footsteps = 0
          inst.components.locomotor:RunForward()
          inst.AnimState:PlayAnimation("jx_flashlight_walk_pre")
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,
        
        timeline =
        {
          TimeEvent(4 * FRAMES, function(inst)
            if inst.sg.statemem.normal then
              PlayFootstep(inst, nil, true)
              DoFoleySounds(inst)
            end
          end),
        },
        
        events =
        {
          EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
              inst.sg:GoToState("run_jx_flashlight")
            end
          end),
        },
    }
)

AddStategraphState("wilson_client", --run_jx_flashlight
    State{
        name = "run_jx_flashlight",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
          inst.components.locomotor:RunForward()
          if not inst.AnimState:IsCurrentAnimation("channelcast_oh_walk") then
            inst.AnimState:PlayAnimation("jx_flashlight_walk", true)
          end
          inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,
        
        onupdate = function(inst)
          inst.components.locomotor:RunForward()
        end,
        
        timeline =
        {
          TimeEvent(1 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
          end),
          TimeEvent(12 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
          end),
        },
        
        ontimeout = function(inst)
          if inst.replica.inventory and inst.replica.inventory:EquipHasTag("flashlight_ison") then
            inst.sg:GoToState("run_jx_flashlight")
          else
            inst.sg:GoToState("run_stop_jx_flashlight")
          end
        end,
    }
)

AddStategraphState("wilson_client", --run_stop_jx_flashlight
    State{
        name = "run_stop_jx_flashlight",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jx_flashlight_idle", true)
        end,
        
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

---
local RunList = { "run_start", "run", "run_stop" }
for _, v in ipairs(RunList) do
  AddStategraphPostInit("wilson", function(sg)
    local state = sg.states[v]
    if state then
      local old_onenter = state.onenter
      state.onenter = function(inst, ...)
        if (inst.components.inventory and inst.components.inventory:EquipHasTag("flashlight_ison")) and
          not (inst.components.rider and inst.components.rider:IsRiding())
        then
          inst.sg:GoToState(v.."_jx_flashlight")
        else
          old_onenter(inst, ...)
        end
      end
    end
  end)
  AddStategraphPostInit("wilson_client", function(sg)
    local state = sg.states[v]
    if state then
      local old_onenter = state.onenter
      state.onenter = function(inst, ...)
        if inst.replica.inventory and inst.replica.inventory:EquipHasTag("flashlight_ison") and
          not (inst.replica.rider and inst.replica.rider:IsRiding())
        then
          inst.sg:GoToState(v.."_jx_flashlight")
        else
          old_onenter(inst, ...)
        end
      end
    end
  end)
end

AddStategraphPostInit("wilson", function(sg)
    local state = sg.states["idle"]
    if state then
      local old_onenter = state.onenter
      state.onenter = function(inst, pushanim, ...)
        old_onenter(inst, pushanim, ...)
        if inst.components.inventory and inst.components.inventory:EquipHasTag("flashlight_ison") and
          not (inst.components.rider and inst.components.rider:IsRiding())
        then
          if inst.AnimState:IsCurrentAnimation("idle_loop") then
            inst.AnimState:PlayAnimation("jx_flashlight_idle", true)
          end
        end
      end
      local old_ontimeout = state.ontimeout
      state.ontimeout = function(inst, ...)
        if inst.components.inventory and inst.components.inventory:EquipHasTag("flashlight_ison") then
          inst.sg:GoToState("idle")
        else
          old_ontimeout(inst, ...)
        end
      end
    end
end)

AddStategraphPostInit("wilson_client", function(sg)
    local state = sg.states["idle"]
    if state then
      local old_onenter = state.onenter
      state.onenter = function(inst, pushanim, ...)
        old_onenter(inst, pushanim, ...)
        if inst.replica.inventory and inst.replica.inventory:EquipHasTag("flashlight_ison") and
          not (inst.replica.rider and inst.replica.rider:IsRiding())
        then
          if inst.AnimState:IsCurrentAnimation("idle_loop") then
            inst.AnimState:PlayAnimation("jx_flashlight_idle", true)
          end
        end
      end
      local old_ontimeout = state.ontimeout
      state.ontimeout = function(inst, ...)
        if inst.replica.inventory and inst.replica.inventory:EquipHasTag("flashlight_ison") then
          inst.sg:GoToState("idle")
        else
          old_ontimeout(inst, ...)
        end
      end
    end
end)