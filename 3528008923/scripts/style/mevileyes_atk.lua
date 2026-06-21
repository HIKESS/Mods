local FRAMES = GLOBAL.FRAMES
local ACTIONS = GLOBAL.ACTIONS
local State = GLOBAL.State
local EventHandler = GLOBAL.EventHandler
local ActionHandler = GLOBAL.ActionHandler
local TimeEvent = GLOBAL.TimeEvent
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local require = GLOBAL.require


local function DoMountSound(inst, mount, sound, ispredicted)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, ispredicted)
    end
end

	local katanarnd = 1
local mtachi = State({
        name = "mtachi",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" }, --
        onenter = function(inst)
			if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
			
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period -- + .5 * FRAMES 
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                cooldown = math.max(cooldown, 16 * FRAMES)
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
				elseif  katanarnd == 3 then --heavy					
					inst.sg:AddStateTag("mtachiatk3")
					inst.AnimState:PlayAnimation("atk_prop_pre")					
					inst.AnimState:PushAnimation("atk_prop_lag", false)
					katanarnd = 4
				elseif katanarnd == 4 then -- combo 3 hit
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
				
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                cooldown = math.max(cooldown, 13 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)			
           if target ~= nil then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                    inst.sg.statemem.retarget = target
                end
            end
        end,

        timeline =
        {							
			TimeEvent(6.5 * FRAMES, function(inst)
                if inst.sg.statemem.iskatana then 
					if inst.sg:HasStateTag("mtachiatk") then inst.AnimState:PlayAnimation("lunge_pst") inst.sg:RemoveStateTag("mtachiatk")end
					if inst.sg:HasStateTag("mtachiatk2")  then
						inst.components.combat:DoAttack(inst.sg.statemem.target)
						inst.AnimState:PlayAnimation("scythe_loop")
						inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
						inst.sg:RemoveStateTag("mtachiatk2")						
					end
					if inst.sg:HasStateTag("mtachiatk3") then inst.AnimState:PlayAnimation("atk") inst.sg:RemoveStateTag("mtachiatk3")end
					inst.sg.statemem.iskatana = nil
                end
            end),
			
			TimeEvent(8 * FRAMES, function(inst)				
					inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")	
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()				
				if inst.sg:HasStateTag("mtachiatk") then inst.sg:RemoveStateTag("mtachiatk") end		
				if inst.sg:HasStateTag("mtachiatk2") then inst.sg:RemoveStateTag("mtachiatk2") end
				if inst.sg:HasStateTag("mtachiatk3") then inst.sg:RemoveStateTag("mtachiatk3") end
            end			
        end,
    }
)

AddStategraphState("wilson", mtachi)

local miai = State({
        name = "miai",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" }, -- 

        onenter = function(inst)
			
			if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
			
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			inst.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period --+ .5 * FRAMES
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                cooldown = math.max(cooldown, 16 * FRAMES)
            elseif equip ~= nil and equip:HasTag("miai") then			                
				inst.sg.statemem.iskatana = true				
				inst.AnimState:PlayAnimation("spearjab_pre")
				inst.AnimState:PushAnimation("lunge_pst", false)	
                inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe")
                cooldown = math.max(cooldown, 9 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)			
            if target ~= nil then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
					inst.sg.statemem.retarget = target
                end
            end
        end,

        timeline =
        {   
			TimeEvent(4 * FRAMES, function(inst) 
				if inst.sg.statemem.iskatana then                    
					local equipskill = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					if equipskill and equipskill.components.spellcaster ~= nil then
						equipskill.components.spellcaster:CastSpell(inst)						
					end				
				end
            end),
			
            TimeEvent(7.5 * FRAMES, function(inst) 
				if inst.sg.statemem.iskatana then
                    inst:PerformBufferedAction()
					inst.components.combat:DoAttack(inst.sg.statemem.target)
					inst.sg:RemoveStateTag("abouttoattack")
					inst.sg.statemem.iskatana = nil
				end
            end),
			
			TimeEvent(8 * FRAMES, function(inst)				
					inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")	
            end),	
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()				
            end			
        end,
    }
)

AddStategraphState("wilson", miai)
