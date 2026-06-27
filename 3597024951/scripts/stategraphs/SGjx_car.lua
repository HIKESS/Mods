local function GetDoColourTimeline()
  local do_colour_timeline = {}
  local time_start_1 = 1
  local time_length_1 = 15
  local time_setbuild = 16 -- time_start_1 + time_length_1
  local time_start_2 = 30
  local time_length_2 = 15
  
  for i = time_start_1, time_start_1 + time_length_1 - 1 do
    table.insert(do_colour_timeline,
      FrameEvent(i, function(inst)
        local addcolour = inst.sg.statemem.addcolour
        inst.sg.statemem.addcolour = inst.sg.statemem.addcolour + 1 / time_length_1
        inst.AnimState:SetAddColour(addcolour, addcolour, addcolour, 0)
      end)
    )
  end
  
  table.insert(do_colour_timeline, 
    FrameEvent(time_setbuild, function(inst)
      inst.AnimState:SetBuild("jx_car_2")
    end)
  )
  
  for i = time_start_2, time_start_2 + time_length_2 - 1 do
    table.insert(do_colour_timeline,
      FrameEvent(i, function(inst)
        local addcolour = inst.sg.statemem.addcolour
        inst.sg.statemem.addcolour = inst.sg.statemem.addcolour - 1 / time_length_2
        inst.AnimState:SetAddColour(addcolour, addcolour, addcolour, 0)
      end)
    )
  end
  
  return do_colour_timeline
end

local actionhandlers = {}

local events = 
{
}

local states=
{
  State{
    name = "idle",
    tags = {"idle", "canrotate"},
    
    onenter = function(inst)
      inst.components.locomotor:StopMoving()
      inst.AnimState:PlayAnimation("closed", false)
    end,
  },
  
  State{
    name = "slide",
    tags = {"idle", "canrotate"},
    
    onenter = function(inst, data)
      inst.AnimState:PlayAnimation("closed", false)
      inst.sg.statemem.speed = data and data.speed or 0
      inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
    end,
    
    timeline =
    {
      FrameEvent(10, function(inst)
        inst.sg.statemem.speed = inst.sg.statemem.speed * .4
        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
      end),
      FrameEvent(20, function(inst)
        inst.sg.statemem.speed = inst.sg.statemem.speed * .4
        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
      end),
      FrameEvent(30, function(inst)
        inst.sg.statemem.speed = inst.sg.statemem.speed * .4
        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
      end),
      FrameEvent(40, function(inst)
        inst.sg.statemem.speed = inst.sg.statemem.speed * .4
        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)         
      end),
      FrameEvent(50, function(inst)
        inst.Physics:Stop()
        inst.sg:GoToState("idle")
      end),
    },
    
    onexit = function(inst)
      inst.Physics:Stop()
    end,
  },
  
  State{
    name = "do_colour",
    tags = {"idle", "canrotate"},
    
    onenter = function(inst)
      inst:AddTag("NOCLICK")
      inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
      
      inst.components.locomotor:StopMoving()
      inst.components.rideable.canride = false
      
      inst.sg.statemem.addcolour = 0
      
      inst.sg:SetTimeout(46 * FRAMES)
    end,
    
    ontimeout = function(inst)
      inst.sg:GoToState("idle")
    end,
    
    timeline = GetDoColourTimeline(),
    
    onexit = function(inst)
      inst:RemoveTag("NOCLICK")
      inst.AnimState:ClearBloomEffectHandle()
      inst.AnimState:SetAddColour(0, 0, 0, 0)
      inst.components.rideable.canride = true
    end,
  },
}

return StateGraph("jx_car", states, events, "idle", actionhandlers)