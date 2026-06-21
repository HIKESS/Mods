local FRAMES = GLOBAL.FRAMES
local ACTIONS = GLOBAL.ACTIONS
local State = GLOBAL.State
local EventHandler = GLOBAL.EventHandler
local ActionHandler = GLOBAL.ActionHandler
local TimeEvent = GLOBAL.TimeEvent
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local require = GLOBAL.require

local function DoMountSoundClient(inst, mount, sound)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, true)
    end
end

	local katanarnd = 1

local katana_client = State({
	name = "mtachi",
        tags = { "attack", "notalking", "abouttoattack" },

        onenter = function(inst)
		
			local buffaction = inst:GetBufferedAction()
            local cooldown = inst.replica.combat:MinAttackPeriod()
            if inst.replica.combat ~= nil then
                if inst.replica.combat:InCooldown() then
                    inst.sg:RemoveStateTag("abouttoattack")
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle", true)
                    return
                end
                inst.replica.combat:StartAttack()               
            end           
          
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local rider = inst.replica.rider
			
			inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")
            inst.components.locomotor:Stop()

            if rider ~= nil and rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSoundClient(inst, rider:GetMount(), "angry")
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 16 * FRAMES)
                end
            elseif equip ~= nil and equip:HasTag("mtachi") then				
				inst.sg.statemem.iskatana = true
							
                if  katanarnd == 1 then
					inst.AnimState:PlayAnimation("atk_pre")                	
					inst.AnimState:PushAnimation("atk", false)
					katanarnd = 2				
				elseif  katanarnd == 2 then	
					inst.sg:AddStateTag("mtachiatk")
					inst.AnimState:PlayAnimation("pickaxe_pst")					
					katanarnd = 3
				elseif katanarnd == 3 then
					
					inst.sg:AddStateTag("mtachiatk3")					
					inst.AnimState:PlayAnimation("atk_prop_pre")					
					inst.AnimState:PushAnimation("atk_prop_lag", false)
					katanarnd = 4
				elseif katanarnd == 4 then --combo 3 hit		
					inst.sg:AddStateTag("mtachiatk2")
					--inst.AnimState:PlayAnimation("scythe_loop")	
					inst.AnimState:PlayAnimation("spearjab")	
					katanarnd = 1
				else	
					inst.AnimState:PlayAnimation("atk_prop_pre")
					inst.AnimState:PushAnimation("atk", false)			
					katanarnd = 1
				end
				
				if inst.cancombo ~= nil then inst.cancombo:Cancel() end
				inst.cancombo = inst:DoTaskInTime(.7, function() katanarnd = 1 end)
					
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
				
            end			
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
                end
            end

            if cooldown > 0 then
                inst.sg:SetTimeout(cooldown)
            end
        end,

        timeline =
		{				
			TimeEvent(6.5 * FRAMES, function(inst)				
				if inst.sg.statemem.iskatana then 
					if inst.sg:HasStateTag("mtachiatk") then inst.AnimState:PlayAnimation("lunge_pst") inst.sg:RemoveStateTag("mtachiatk")end
					if inst.sg:HasStateTag("mtachiatk2") then inst.AnimState:PlayAnimation("scythe_loop") inst.sg:RemoveStateTag("mtachiatk2") end	
					if inst.sg:HasStateTag("mtachiatk3") then inst.AnimState:PlayAnimation("atk") inst.sg:RemoveStateTag("mtachiatk3")end
					inst.sg.statemem.iskatana = nil
				end
			end),
			
			TimeEvent(8 * FRAMES, function(inst) 					
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")				
			end),						
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then					
                    inst.sg:GoToState("idle")					
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()				
				if inst.sg:HasStateTag("mtachiatk") then  inst.sg:RemoveStateTag("mtachiatk") end
				if inst.sg:HasStateTag("mtachiatk2") then  inst.sg:RemoveStateTag("mtachiatk2") end
				if inst.sg:HasStateTag("mtachiatk3") then  inst.sg:RemoveStateTag("mtachiatk3") end
            end			
        end,
	}
)

AddStategraphState("wilson_client", katana_client)

local miai_client = State({
	name = "miai",
        tags = { "attack", "notalking", "abouttoattack" },

        onenter = function(inst)
          local buffaction = inst:GetBufferedAction()
            local cooldown = inst.replica.combat:MinAttackPeriod()
            if inst.replica.combat ~= nil then
                if inst.replica.combat:InCooldown() then
                    inst.sg:RemoveStateTag("abouttoattack")
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle", true)
                    return
                end
                inst.replica.combat:StartAttack()                
            end
            inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")
            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local rider = inst.replica.rider
            
            if rider ~= nil and rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSoundClient(inst, rider:GetMount(), "angry")
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 16 * FRAMES)
                end
            elseif equip ~= nil and equip:HasTag("miai") then
                				
				inst.AnimState:PlayAnimation("spearjab_pre")
				inst.AnimState:PushAnimation("lunge_pst", false)
				inst.sg.statemem.iskatana = true
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 9 * FRAMES)
                end
            end
			
           if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
                end
            end

            if cooldown > 0 then
                inst.sg:SetTimeout(cooldown)
            end
        end,

        timeline =
		{	
			TimeEvent(4 * FRAMES, function(inst) 
				if inst.sg.statemem.iskatana then						
					local equipskill = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					if equipskill and equipskill.replica.spellcaster ~= nil then
						equipskill.replica.spellcaster:CastSpell(inst)
					end
				end
			end),
			
            TimeEvent(7.5 * FRAMES, function(inst) 
				if inst.sg.statemem.iskatana then
					inst:ClearBufferedAction()					
					inst.sg:RemoveStateTag("abouttoattack")
					inst.sg.statemem.iskatana = nil
				end
			end),
			
			TimeEvent(8 * FRAMES, function(inst) 					
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")				
			end),	
			
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()				
            end			
        end,
	}
)
AddStategraphState("wilson_client", miai_client)
