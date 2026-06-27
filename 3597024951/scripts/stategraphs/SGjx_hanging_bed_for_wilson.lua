AddStategraphState("wilson",
    State{
        name = "jx_hanging_bed",
        tags = { "jx_hanging_bed" },

        onenter = function(inst)
          inst.AnimState:PlayAnimation("pickup")
          inst.AnimState:PushAnimation("pickup_pst", false)
        end,
        
        timeline = 
        {
          TimeEvent(FRAMES * 6, function(inst)
            if inst:PerformBufferedAction() then
              inst.AnimState:PlayAnimation("jx_hanging_bed", true)
              if inst.components.inventory then
                inst.components.inventory:Hide()
              end
              inst:ShowActions(false)
            else
              inst.sg:GoToState("idle")
            end
          end),
        },
        
        onexit = function(inst)
          if inst.components.inventory then
            inst.components.inventory:Show()
          end
          inst:ShowActions(true)
          
          local r, g, b, a = inst.AnimState:GetMultColour()
          local dc = .1
          local color = 0
          inst.AnimState:SetMultColour(r, g, b, 0)
          inst:DoTaskInTime(0, function()
            if not inst.sg:HasAnyStateTag("busy") then
              inst.AnimState:SetMultColour(r, g, b, color)
              local life = (a - color) / dc
              if inst.jx_hanging_bed_colortask then
                inst.jx_hanging_bed_colortask:Cancel()
                inst.jx_hanging_bed_colortask = nil
              end
              inst.jx_hanging_bed_colortask = inst:DoPeriodicTask(FRAMES, function()
                if life >= 1 then
                  life = life - 1
                  color = color + dc
                  inst.AnimState:SetMultColour(r, g, b, color)
                else
                  if inst.jx_hanging_bed_colortask then
                    inst.jx_hanging_bed_colortask:Cancel()
                    inst.jx_hanging_bed_colortask = nil
                  end
                  inst.AnimState:SetMultColour(r, g, b, a)
                end
              end)
            else
              inst.AnimState:SetMultColour(r, g, b, a)
            end
          end)
        end,
    }
)

AddStategraphState("wilson_client",
    State{
        name = "jx_hanging_bed",
        tags = { "jx_hanging_bed" },
        server_states = { "jx_hanging_bed" },

        onenter = function(inst)
          inst.AnimState:PlayAnimation("pickup")
          inst.AnimState:PushAnimation("pickup_pst", false)
          inst:PerformPreviewBufferedAction()
        end,
        
        timeline = 
        {
          TimeEvent(FRAMES * 6, function(inst)
            inst.AnimState:PlayAnimation("jx_hanging_bed", true)
          end),
        },
        
        onupdate = function(inst)
		    	if not inst.sg:ServerStateMatches() then
            inst.sg:GoToState("idle")
          end
        end,
    }
)