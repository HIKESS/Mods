require("stategraphs/commonstates")

local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function ToggleOffPhysicsExceptWorld(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:SetCollisionMask(COLLISION.WORLD)
end

local actionhandlers =
{    

}

local events = 
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),

    EventHandler("locomote", function(inst) 
        if not inst.sg:HasStateTag("busy") then   
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("run_start")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),
    EventHandler("doattack", function(inst, data)
	if inst.components.health and not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
	    local altattackchance = math.random(1,10)
	    if altattackchance <= 1 then --2
		inst.sg:GoToState("attackCrit")
	    elseif altattackchance > 1 and altattackchance <= 4 then --2,5
		inst.sg:GoToState("attackMulti")
	    elseif altattackchance > 4 then --5
		inst.sg:GoToState("attack")
	    end
	end
    end),

    EventHandler("knockback", function(inst, data)
	if not inst.components.health:IsDead() then
	    inst.sg:GoToState(data.forcelanded or "knockback", data)
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)    
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)

	    --Extra animations
	    inst:DoTaskInTime(0.1, function()
		if inst.components.sdf_gallowmere_knight_command and inst.components.combat and inst.components.health then
		    --Stance Equipment
		    if not inst.components.combat:InCooldown() and inst.components.combat.target == nil and not inst.components.health:IsDead() then
			inst.equipfn(inst, inst.components.sdf_gallowmere_knight_command:CurrentStance())
		    end

		    --Victory Quotes
		    if inst.components.combat.target == nil and not inst.components.health:IsDead() then
			if inst.target_tagged ~= nil or inst.epic_tagged ~= nil then
			    if inst.target_tagged ~= nil and inst.target_tagged.components.health and inst.target_tagged.components.health:IsDead() then
				inst.victorykillfn(inst)
			    elseif inst.epic_tagged ~= nil and inst.epic_tagged.components.health and inst.epic_tagged.components.health:IsDead() then
				inst.victorykillfn(inst)
			    else
				inst.target_tagged = nil
				inst.epic_tagged = nil
			    end
			end
		    end
		end
	    end)
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst)
	    inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
            inst.sg.mem.foosteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
        
        timeline=
        {        
            TimeEvent(4*FRAMES, function(inst)
            end),
        },        
        
    },

    State{
        
        name = "funnyidle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
	    if inst.components.temperature:GetCurrent() < 5 then
		inst.AnimState:PlayAnimation("idle_shiver_pre")
		inst.AnimState:PushAnimation("idle_shiver_loop")
		inst.AnimState:PushAnimation("idle_shiver_pst", false)
	    elseif inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/rabbit/beardscream")    
            else
                inst.AnimState:PlayAnimation("idle_inaction")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
        
    },
    

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
            
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,
      
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
    },
    
    State{
    
        name = "run_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
        
    },
	
    State{
        name = "talk",
        tags = {"idle", "talking", "busy"},
        
        onenter = function(inst, noanim)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dial_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/characters/wilson/talk_LP", "talk")
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("talk")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    }, 	
	
    State{
        name = "happy",
        tags = {"idle", "talking", "busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("staff") 
	    inst.SoundEmitter:PlaySound("dontstarve/characters/wilson/talk_LP", "talk")
        end,
		
	onexit = function(inst)
            inst.SoundEmitter:KillSound("talk")
        end,
		
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
	    --equip sword
	    inst.equipfn(inst, inst.items["SWORD"])

	    --set normal damage
	    inst.components.combat:SetDefaultDamage(inst.weaponfn)

	    inst.components.combat:StartAttack()

	    inst.Physics:Stop()
	    inst.AnimState:PlayAnimation("atk")
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
		--equip shield
		inst.equipfn(inst, inst.items["SHIELD"])

		inst.sg:GoToState("idle") 
	    end),
        },
    },	
	
    State{
        name = "attackCrit",
        tags = {"attack", "busy"},
        onenter = function(inst)
	    --equip sword
	    inst.equipfn(inst, inst.items["SWORD"])

	    inst.components.combat:StartAttack()

	    inst.AnimState:PlayAnimation("pickaxe_loop")
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) 
                inst.components.combat:DoAttack()
		inst.components.combat:DoAttack()
                inst.sg:RemoveStateTag("premine") 
            end),           
        },
        
        events=
        {
	    EventHandler("animover", function(inst)
		--equip shield
		inst.equipfn(inst, inst.items["SHIELD"])

		inst.sg:GoToState("idle") 
	    end),
        },       
    },
	
    State{ 
	name = "attackMulti",
        tags = {"attack", "busy"},
		
        onenter = function(inst)
	    --equip sword
	    inst.equipfn(inst, inst.items["SWORD"])

	    --set multi hit damage
	    inst.components.combat:SetDefaultDamage(inst.weaponfn/1.5)

	    inst.Physics:Stop()
	    inst.AnimState:PlayAnimation("chop_pre")  	
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attackMultiend") end),
        },
    },
    
    State{
        name = "attackMultiend",
        tags = {"attack", "busy"},
        onenter = function(inst)
	    inst.AnimState:PlayAnimation("chop_loop")
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) 
		inst.components.combat:DoAttack()
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
		local restart = math.random(1,3)
		if restart == 1 and inst.components.combat.target ~= nil then
		    inst.sg:GoToState("attackMulti") 
		else		
		    --equip shield
		    inst.equipfn(inst, inst.items["SHIELD"])

		    inst.sg:GoToState("idle") 
		end
	    end),
        },       
    },
	
    State{
        name = "death",
        tags = {"busy"},
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/death") 
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
    },
   
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst:InterruptBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")        
            inst.AnimState:PlayAnimation("hit")    
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        }, 
        
        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },        
               
    },

    State{
        name = "stunned",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst:InterruptBufferedAction()
            inst:ClearBufferedAction()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_sanity_pre")
            inst.AnimState:PushAnimation("idle_sanity_loop", true)
            inst.sg:SetTimeout(5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    
    State{
        name = "frozen",
        tags = {"busy", "frozen"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("idle_shiver_loop")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
        end,
        
        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
        
        events=
        {   
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),        
        },
    },

    State{
        name = "thaw",
        tags = {"busy", "thawing"},
        
        onenter = function(inst) 
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("idle_inaction_sanity", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,

        events =
        {   
            EventHandler("unfreeze", function(inst)
                if inst.sg.sg.states.hit then
                    inst.sg:GoToState("hit")
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },
	
    State{
	name = "frozen",
	tags = {"busy"},
		
        onenter = function(inst)
            inst.AnimState:PlayAnimation("frozen")
            inst.Physics:Stop()
        end,
    },

    State{
        name = "knockback",
		tags = { "knockback", "busy", "nopredict", "nomorph", "nodangle", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

	    inst.AnimState:PlayAnimation("bucked")

            if data ~= nil then
                if data.disablecollision then
		    ToggleOffPhysicsExceptWorld(inst)
                end
                
                if data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
                    inst.sg.statemem.speed = (data.strengthmult or 1) * 12 * k
                    inst.sg.statemem.dspeed = 0
                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                    end
                end
            end

	    if not inst.sg.statemem.isphysicstoggle then
		local x, y, z = inst.Transform:GetWorldPosition()
		inst.sg.statemem.ispassableatpt = GetActionPassableTestFnAt(x, y, z)
		if inst.sg.statemem.ispassableatpt(x, y, z, true) then
		    inst.sg.statemem.safepos = Vector3(x, y, z)
		elseif data ~= nil and data.knocker ~= nil and data.knocker:IsValid() and data.knocker:IsOnPassablePoint(true) then
		    local x1, y1, z1 = data.knocker.Transform:GetWorldPosition()
		    local radius = data.knocker:GetPhysicsRadius(0) - inst:GetPhysicsRadius(0)
		    if radius > 0 then
			local dx = x - x1
			local dz = z - z1
			local dist = radius / math.sqrt(dx * dx + dz * dz)
			x = x1 + dx * dist
			z = z1 + dz * dist
			if inst.sg.statemem.ispassableatpt(x, 0, z, true) then
			    x1, z1 = x, z
			end
		    end
		    inst.sg.statemem.safepos = Vector3(x1, 0, z1)
		end
	    end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .075
                    inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end

	    local safepos = inst.sg.statemem.safepos
	    if safepos ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		if inst.sg.statemem.ispassableatpt(x, y, z, true) then
		    safepos.x, safepos.y, safepos.z = x, y, z
		elseif inst.sg.statemem.landed then
		    local mass = inst.Physics:GetMass()
		    if mass > 0 then
			inst.sg.statemem.restoremass = mass
			inst.Physics:SetMass(99999)
		    end
		    inst.Physics:Teleport(safepos.x, 0, safepos.z)
		    inst.sg.statemem.safepos = nil
		end
	    end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
	    FrameEvent(10, function(inst)
		inst.sg.statemem.landed = true
		inst.sg:RemoveStateTag("nointerrupt")
		inst.sg:RemoveStateTag("jumping")
	    end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("knockback_pst")
                end
            end),
        },

        onexit = function(inst)
	    if inst.sg.statemem.restoremass ~= nil then
		inst.Physics:SetMass(inst.sg.statemem.restoremass)
	    end
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "knockback_pst",
        tags = { "knockback", "busy", "nomorph", "nodangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("buck_pst")
        end,

        timeline =
        {
            TimeEvent(27 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("knockback")
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nomorph")
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
    },

}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
	    TimeEvent(0*FRAMES, PlayFootstep ),
	    TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
	runtimeline = {
	    TimeEvent(0*FRAMES, PlayFootstep ),
	   TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"})
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddVoidFallStates(states)

CommonStates.AddFrozenStates(states)

return StateGraph("SGsdf_gallowmere_knight", states, events, "idle", actionhandlers)