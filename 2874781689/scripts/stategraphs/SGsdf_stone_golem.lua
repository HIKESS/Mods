require("stategraphs/commonstates")

local function GetScalePercent(inst)
    return (inst.scale - TUNING.SDF_STONE_GOLEM_MIN_SCALE) / (TUNING.SDF_STONE_GOLEM_MAX_SCALE - TUNING.SDF_STONE_GOLEM_MIN_SCALE)
end

local function PlayLobSound(inst, sound)
    inst.SoundEmitter:PlaySoundWithParams(sound, {size=GetScalePercent(inst)})
end


local actionhandlers =
{
    ActionHandler(ACTIONS.TAKEITEM, "rocklick"),
    ActionHandler(ACTIONS.PICKUP, "rocklick"),
    ActionHandler(ACTIONS.EAT, "eat"),
}


local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleep(),
    EventHandler("gotosleep", function(inst) inst.summonCounter = 0 inst.components.health:AddRegenSource(inst, (inst.components.health:GetMaxWithPenalty() * TUNING.SDF_STONE_GOLEM_HEALTH_SLEEP_REGEN_AMOUNT_PERCENT), TUNING.SDF_STONE_GOLEM_HEALTH_REGEN_PERIOD, "sdf_stone_golem_sleep_regen") inst.sg:GoToState("sleep") end),
    EventHandler("onwakeup", function(inst) inst.components.health:RemoveRegenSource(inst, "sdf_stone_golem_sleep_regen") inst.sg:GoToState("wake") end),
    EventHandler("entershield", function(inst) inst.components.health:AddRegenSource(inst, (TUNING.SDF_STONE_GOLEM_HEALTH * TUNING.SDF_STONE_GOLEM_HEALTH_SHIELD_REGEN_PERCENT), TUNING.SDF_STONE_GOLEM_HEALTH_REGEN_PERIOD, "sdf_stone_golem_shield_regen") if inst:HasTag("sdf_stone_golem_shielded_projectile") then inst.sg:GoToState("projectile_shield_start") else inst.sg:GoToState("shield_start") end end),
    EventHandler("exitshield", function(inst) inst.components.health:RemoveRegenSource(inst, "sdf_stone_golem_shield_regen") inst.sg:GoToState("shield_end") end),
}

local function pickrandomstate(inst, choiceA, choiceB, chance)
    if math.random() >= chance then
	inst.sg:GoToState(choiceA)
    else
	inst.sg:GoToState(choiceB)
    end
end


local states =
{

    State{
	name = "idle_tendril",
	tags = {"idle", "canrotate"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_tendrils")
            else
                inst.AnimState:PlayAnimation("idle_tendrils")
            end

        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/idle") end),
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/idle") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},

    State{
        name = "eat",
        tags = {"idle"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_tendrils")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(8*FRAMES, function(inst)
                    inst:PerformBufferedAction()
                    PlayLobSound(inst, "dontstarve/creatures/rocklobster/idle")
                end),
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },



    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/taunt")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "rocklick",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("rocklick_pre")
            inst.AnimState:PushAnimation("rocklick_loop")
            inst.AnimState:PushAnimation("rocklick_pst", false)
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/attack") end),
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(25*FRAMES, function(inst) inst:PerformBufferedAction() end ),
            TimeEvent(35*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State{
        name = "projectile_shield_start",
        tags = {"busy", "hiding"},

        onenter = function(inst)

	    if not inst:HasTag("sdf_stone_golem_shielded") then
		inst:AddTag("sdf_stone_golem_shielded")
		inst.AnimState:PlayAnimation("hide")
	    end

            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/hide")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("shield") end ),
        },
    },

    State{
        name = "shield_start",
        tags = {"busy", "hiding"},

        onenter = function(inst)

	    --summon lava golems -Armored and Asgard Only-
	    if inst.prefab == "sdf_stone_golem_armored" and not inst:HasTag("sdf_stone_golem_shielded_projectile") then
		if inst.summonCounter < 3 then
		    inst.summonCounter = inst.summonCounter + 1
		end
		inst:SummonLavaGolemFn()
	    end

	    if not inst:HasTag("sdf_stone_golem_shielded") then
		inst:AddTag("sdf_stone_golem_shielded")
		inst.AnimState:PlayAnimation("hide")
	    end

            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
            PlayLobSound(inst, "dontstarve/creatures/rocklobster/hide")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("shield") end ),
        },
    },

    State{
        name = "shield",
        tags = {"busy", "hiding"},

        onenter = function(inst)

            --Becomes pushable and burnable
	    inst:AddPushableFn()
            inst.components.health:SetAbsorptionAmount(TUNING.SDF_STONE_GOLEM_SHIELD_ABSORB)
            inst.AnimState:PlayAnimation("hide_loop")
            inst.sg:SetTimeout(3)
        end,

        onexit = function(inst)
	    inst:RemovePushableFn()
            inst.components.health:SetAbsorptionAmount(0)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("shield")

        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/sleep") end),
        },


    },

    State{
        name = "shield_end",
        tags = {"busy", "hiding"},

        onenter = function(inst)

	    if inst:HasTag("sdf_stone_golem_shielded_projectile") then
		inst:RemoveTag("sdf_stone_golem_shielded_projectile")
	    end

	    if inst:HasTag("sdf_stone_golem_shielded_broken") then
		inst:RemoveTag("sdf_stone_golem_shielded_broken")
	    end

	    if inst:HasTag("sdf_stone_golem_shielded") then
		inst:RemoveTag("sdf_stone_golem_shielded")
		inst.AnimState:PlayAnimation("unhide")
	    end

            PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("atk")
            inst.components.combat:StartAttack()

            --V2C: Cached to force the target to be the same one later in the timeline
            --     e.g. combat:DoAttack(inst.sg.statemem.target)
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/attack") end),
            TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap_small") end),
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/attack_whoosh") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/clawsnap") end),
            TimeEvent(20*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(25*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
            TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
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

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local hitanim = "hit"   
            if inst:HasTag("hiding") then
                hitanim = "hide_hit"    
            end

            inst.AnimState:PlayAnimation(hitanim)

            inst._last_hitreact_time = GetTime()
        end,

        timeline = {
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/hurt") end),
            TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
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

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("death")

            --if not inst.shadowthrall_parasite_hosted_death or not TheWorld.components.shadowparasitemanager then
                RemovePhysicsColliders(inst)
                inst.components.lootdropper:DropLoot(inst:GetPosition())
            --end 
        end,

        events =
        {
            EventHandler("animover", function(inst)
                --if inst.shadowthrall_parasite_hosted_death and TheWorld.components.shadowparasitemanager then
                    --TheWorld.components.shadowparasitemanager:ReviveHosted(inst)
                --end
            end),
        },

        timeline = {
            TimeEvent(0*FRAMES, function(inst)
                PlayLobSound(inst, "dontstarve/creatures/rocklobster/death")
                PlayLobSound(inst, "dontstarve/creatures/rocklobster/explode")
            end),
        },
       
    },

    State{
        name = "parasite_revive",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("parasite_death_pst")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },      

}

CommonStates.AddWalkStates(states,
{
    starttimeline =  {
        TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
    },
	walktimeline = {
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(15*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
        TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/footstep") end),
    },
    endtimeline = {
        TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
    },
})

CommonStates.AddSleepStates(states,
{
    starttimeline = {
        TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
    },
    sleeptimeline = {
        TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/sleep") end),
        TimeEvent(20*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),

    },
    endtimeline ={
        TimeEvent(0*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
        },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddIdle(states, "idle_tendril", nil ,
{
    TimeEvent(5*FRAMES, function(inst) PlayLobSound(inst, "dontstarve/creatures/rocklobster/foley") end),
    TimeEvent(30*FRAMES, function(inst) PlayLobSound(inst,"dontstarve/creatures/rocklobster/foley") end),
})

return StateGraph("SGsdf_stone_golem", states, events, "idle", actionhandlers)
