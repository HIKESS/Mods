require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT,
        function(inst, action)
            if action.target.prefab ~= nil then
		action.target:DoTaskInTime(0.5, function()
		    action.target:Remove()
		end)
                return "eat"
            end
        end),

    ActionHandler(ACTIONS.TOSS,
        function(inst, action)
            if not inst.sg:HasStateTag('busy') then
                inst.sg:GoToState("shoot", action.target)
            end
        end),
}

local events =
{
    EventHandler("attacked", function(inst, data)
	if inst.components.health and not inst.components.health:IsDead() then
	    if CommonHandlers.TryElectrocuteOnAttacked(inst, data) then
		return
	    elseif not inst.sg:HasAnyStateTag("attack", "electrocute") then
		inst.sg:GoToState("hit")
	    end
        end
    end),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", function(inst, data)
		if not inst.components.health:IsDead() and ((inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("electrocute")) or not inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack", data.target)
        end
    end),
    EventHandler("doink", function(inst, data)
	if not inst.components.health:IsDead() and ((inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("electrocute")) or not inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("shoot", data.target)
        end
    end),
    EventHandler("putoutfire", function(inst, data)
	if not inst.components.health:IsDead() and ((inst.sg:HasStateTag("hit") and not inst.sg:HasStateTag("electrocute")) or not inst.sg:HasStateTag("busy")) then
	    inst.sg:GoToState("shoot_putOutFire", { firePos = data.firePos })
	end
    end),
    EventHandler("spawn", function(inst)
        inst.sg:GoToState("spawn")
    end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnElectrocute(),

    -- Corpse handlers
    CommonHandlers.OnCorpseChomped(),
}

local function testExtinguish(inst)
    if inst:HasTag("swimming") and inst.components.health ~= nil and not inst.components.health:IsDead() then
        inst.components.health:Kill()
    end
end

local function UpdateRunSpeed(inst)
    inst.components.locomotor.runspeed = TUNING.SDF_PUMPKING_CREEPER_RUNSPEED
end

local function setdivelayering(inst,under)
    local dive = false
    if inst:HasTag("swimming") and under then
        dive = true
    end

    if dive and not inst.under then
        inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
        inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)
        inst.under = true
    else
        inst.AnimState:SetSortOrder(0)
        inst.AnimState:SetLayer(LAYER_WORLD)
        inst.under = nil
    end
end

local function RestorRunSpeed(inst)
    inst.components.locomotor.runspeed = TUNING.SDF_PUMPKING_CREEPER_RUNSPEED
end

local function RestoreCollidesWith(inst)
	inst.Physics:SetCollisionMask(
    	COLLISION.WORLD,
		COLLISION.OBSTACLES,
		COLLISION.SMALLOBSTACLES,
		COLLISION.CHARACTERS,
		COLLISION.GIANTS
	)
end

local function AddNoClick(inst)
    inst:AddTag("NOCLICK")
end

local function RemoveNoClick(inst)
    inst:RemoveTag("NOCLICK")
end

local function GoToIdle(inst)
    inst.sg:GoToState("idle")
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            setdivelayering(inst, false)

            inst.Physics:Stop()

            local random_roll = math.random()
            local anim = (random_roll > 0.6 and "idle")
                    or (random_roll > 0.3 and "idle2")
                    or "idle3"

            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation(anim, true)
            else
                inst.AnimState:PlayAnimation(anim, true)
            end

            inst.sg:SetTimeout(2*math.random()+.5)
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst)
               if inst.AnimState:IsCurrentAnimation("idle3") then
                    inst.SoundEmitter:PlaySound("hookline/creatures/squid/eye")
               end
            end),
            TimeEvent(21*FRAMES, function(inst)
               if inst.AnimState:IsCurrentAnimation("idle3") then
                    inst.SoundEmitter:PlaySound("hookline/creatures/squid/eye")
               end
            end),
        },

        onexit = function(inst)
        end,

        events =
        {
            EventHandler("animover", GoToIdle),
        },
    },

    State{
        name = "spawn",
		tags = { "busy", "noelectrocute" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("spawn", false)
            AddNoClick(inst)
        end,

        events =
        {
            EventHandler("animover", GoToIdle),
        },

        timeline =
        {
            TimeEvent(14*FRAMES, RemoveNoClick),
        },

        onexit = RemoveNoClick,
    },

    State{
        name = "despawn",
		tags = { "busy", "noelectrocute" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("despawn", false)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },

        timeline =
        {
            TimeEvent(12*FRAMES, AddNoClick),
        },

        onexit = RemoveNoClick,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("attack")
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            end),

            TimeEvent(10*FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.SoundEmitter:PlaySound(inst.sounds.attack)
                inst.components.locomotor:EnableGroundSpeedMultiplier(false)
                inst.Physics:SetMotorVelOverride(3,0,0)
            end),

            TimeEvent(18*FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),

            TimeEvent(26*FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.components.locomotor:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if math.random() < 0.2 then
                    inst.components.combat:SetTarget(nil)
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "shoot",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if not target then
                target = inst.components.combat.target
            end

            if target then
                inst.sg.statemem.target = target
            end

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("flee")
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.spit) end),
            TimeEvent(15*FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if target and target:IsValid() then
                    inst.sg.statemem.inkpos = target:GetPosition()
                    inst:LaunchProjectile(inst.sg.statemem.inkpos)

                    inst.components.timer:StopTimer("ink_cooldown")
                    inst.components.timer:StartTimer("ink_cooldown", TUNING.SDF_PUMPKING_CREEPER_GUTS_COOLDOWN + math.random()*3)
                end
            end),
        },

        events =
        {
            EventHandler("animover", GoToIdle),
        },
    },

    State{
        name = "shoot_putOutFire",
        tags = { "busy", "shooting" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("flee")
            inst.sg.statemem.firePos = data.firePos
        end,

        timeline =
        {
	    TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.spit) end),
            TimeEvent(15 * FRAMES, function(inst)
                inst:LaunchProjectile(inst.sg.statemem.firePos)

		inst.components.timer:StopTimer("putOutFire_cooldown")
		inst.components.timer:StartTimer("putOutFire_cooldown", TUNING.SDF_PUMPKING_CREEPER_FIRE_DETECTOR_COOLDOWN + math.random()*3)
            end),
            TimeEvent(16 * FRAMES, function(inst)
                inst.components.firedetector:DetectFire()
            end),
        },

        events =
        {
            EventHandler("animover", GoToIdle),
        },
    },

    State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("attack", false)
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.bite)
            end),
        },

        events =
        {
            EventHandler("animover", GoToIdle),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", GoToIdle),
        },
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst, norepeat)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.taunt)
            end),
        },

        events =
        {
            EventHandler("animover", GoToIdle),
        },
    },

    State{
        name = "fling",
        tags = { "busy","jumping" },

        onenter = function(inst, norepeat)
            if inst:IsOnOcean() then
                inst.fling_land = false
            else
                inst.fling_land = true
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("jump")
	    inst.AnimState:SetFrame(5)
            inst.AnimState:PushAnimation("jump_loop")

	    inst:StopBrain("SGsquid_fling")

            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.Physics:SetMotorVelOverride(10,0,0)

            inst.sg:SetTimeout(0.35)

            inst.Physics:SetCollisionMask(COLLISION.GROUND)
        end,

        onupdate = function(inst)
            if inst:IsOnOcean() then
                if inst.fling_land then
                    inst.components.amphibiouscreature:OnEnterOcean()
                    inst.fling_land = false
                end
            else
                if not inst.fling_land then
                    inst.components.amphibiouscreature:OnExitOcean()
                    inst.fling_land = true
                end
            end
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()

            RestoreCollidesWith(inst)
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
                else
                    inst.SoundEmitter:PlaySound("hookline/creatures/squid/land")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("fling_pst")
        end,
    },

    State{
        name = "fling_pst",
        tags = { "busy","jumping" },

        onenter = function(inst, norepeat)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("jump_pst")

            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.Physics:SetMotorVelOverride(10,0,0)
            inst.Physics:SetCollisionMask(COLLISION.GROUND)
        end,

        onupdate = function(inst)
            if inst:IsOnOcean() then
                if inst.fling_land then
                    inst.components.amphibiouscreature:OnEnterOcean()
                    inst.fling_land = false
                end
            else
                if not inst.fling_land then
                    inst.components.amphibiouscreature:OnExitOcean()
                    inst.fling_land = true
                end
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.fling_land = nil
                inst.components.locomotor:Stop()
                if inst:HasTag("swimming") then
                    SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
                RestoreCollidesWith(inst)
            end),
        },


        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
	    inst:RestartBrain("SGsquid_fling")
            RestoreCollidesWith(inst)
        end,

        events =
        {
            EventHandler("animover", GoToIdle),
        },
    },

    State{
        name = "winter_hibernate",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("frozen", false)
	    inst.components.talker:Say("Winter state")
	    RemoveNoClick(inst)
        end,
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.amphibiouscreature ~= nil and inst.components.amphibiouscreature.in_water then
                inst.AnimState:PlayAnimation("invisible")		
	    else
		inst.AnimState:PlayAnimation("dead")
            end
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.death)
        end,

        events =
        {
            CommonHandlers.OnCorpseDeathAnimOver(),
        },
    },

    State{
        name = "forcesleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_loop", true)
        end,
    },

    State{
        name = "frozen",
        tags = { "busy", "frozen" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("frozen", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

	    if inst.components.freezable == nil then
		inst.sg:GoToState("hit")
	    elseif inst.components.freezable:IsThawing() then
		inst.sg.statemem.thawing = true
		inst.sg:GoToState("thaw")
	    elseif not inst.components.freezable:IsFrozen() then
		inst.sg:GoToState("hit")
	    end

        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
		inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle")
	    end),
	    EventHandler("onthaw", function(inst)
		inst.sg.statemem.thawing = true
		inst.sg:GoToState("thaw")
	    end),
        },

        onexit = function(inst)
	    if not inst.sg.statemem.thawing then
		inst.AnimState:ClearOverrideSymbol("swap_frozen")
		inst.components.freezable:Unfreeze()
	    end
        end,
    },

    State{
        name = "thaw",
        tags = { "busy", "thawing" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

	    if inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
		inst.sg:GoToState("hit")
	    end
        end,

        events =
        {
	    EventHandler("unfreeze", function(inst)
		inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle")
	    end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
	    inst.components.freezable:Unfreeze()
        end,
    },

-- RUN STATES START HERE

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
        end,

        onupdate = function(inst)
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                testExtinguish(inst)
                setdivelayering(inst,true)
            end),
            TimeEvent(5 * FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    AddNoClick(inst)
                end
            end),
        },

        onexit = function(inst)
            setdivelayering(inst,false)

            RemoveNoClick(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("run")
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            setdivelayering(inst,true)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

            if inst:HasTag("swimming") then
                inst.waketask = inst:DoPeriodicTask(0.3, function()
                    local wake = SpawnPrefab("wake_small")
                    local rotation = inst.Transform:GetRotation()

                    local theta = rotation * DEGREES
                    local offset = Vector3(math.cos( theta ), 0, -math.sin( theta ))
                    local pos = Vector3(inst.Transform:GetWorldPosition()) + offset
                    wake.Transform:SetPosition(pos.x,pos.y,pos.z)

                    wake.Transform:SetRotation(rotation - 90)
                end)

                AddNoClick(inst)
            end

            UpdateRunSpeed(inst)
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                if inst:HasTag("swimming") then
                    inst.Physics:Stop()
                else
                    PlayFootstep(inst,0.2)
                end
            end),
            TimeEvent(2*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound("hookline/creatures/squid/run")
                end
            end),

            TimeEvent(4 * FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound(inst.sounds.swim)
                else
                    PlayFootstep(inst,0.2)
                end
            end),
            TimeEvent(6*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound("hookline/creatures/squid/run")
                end
            end),
            TimeEvent(7 * FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    inst.components.locomotor:RunForward()
                end
            end),
            TimeEvent(8*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound("hookline/creatures/squid/run")
                end
            end),
            TimeEvent(10*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound("hookline/creatures/squid/run")
                end
            end),
        },

        onexit = function(inst)
            if inst.waketask then
                inst.waketask:Cancel()
                inst.waketask = nil
            end

            setdivelayering(inst,false)

            RemoveNoClick(inst)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "idle" },

        onenter = function(inst)
            setdivelayering(inst,true)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("run_pst")

            if inst:HasTag("swimming") then
                AddNoClick(inst)
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                setdivelayering(inst,false)
            end),
            TimeEvent(9 * FRAMES, RemoveNoClick),
        },

        onexit = function(inst)
            setdivelayering(inst,false)
            RemoveNoClick(inst)
        end,

        events =
        {
            EventHandler("animqueueover", GoToIdle),
        },
    },
}

CommonStates.AddAmphibiousCreatureHopStates(states,
{ -- config
    swimming_clear_collision_frame = 9 * FRAMES,
},
nil, -- anims
{ -- timeline
    hop_pre =
    {
        TimeEvent(0, function(inst)
            if inst:HasTag("swimming") then
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end),
    },
    hop_pst = {
        TimeEvent(4 * FRAMES, function(inst)
            if inst:HasTag("swimming") then
                inst.components.locomotor:Stop()
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
                testExtinguish(inst)
            end
        end),
        TimeEvent(6 * FRAMES, function(inst)
            if not inst:HasTag("swimming") then
                inst.components.locomotor:StopMoving()
            end
        end),
        TimeEvent(9 * FRAMES, function(inst)
            setdivelayering(inst,true)
        end),
        TimeEvent(17 * FRAMES, function(inst)
            setdivelayering(inst)
        end),
    }
})

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        --TimeEvent(17 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bite) end),
    },

    waketimeline =
    {
        TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline/creatures/squid/run") end),
        TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline/creatures/squid/run") end),
        TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline/creatures/squid/run") end),
    },
})

CommonStates.AddWalkStates(states, nil, nil, nil, true)
--CommonStates.AddFrozenStates(states)
CommonStates.AddElectrocuteStates(states)
CommonStates.AddInitState(states, "idle")
CommonStates.AddCorpseStates(states,
{ -- anims
    corpse = function(inst)
        local amphibiouscreature = inst.components.amphibiouscreature
        if amphibiouscreature and amphibiouscreature.in_water then
            return "invisible"
        end
    end,
})

return StateGraph("SGsdf_pumpking_creeper", states, events, "init", actionhandlers)
