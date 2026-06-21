-- TODO
--  Attack idle state needs to check to see if it attack
--      move newcombat event handling to stategraph
--
require("stategraphs/commonstates")

local EMERGE_MIN = 10
local EMERGE_MIN2 = EMERGE_MIN*EMERGE_MIN
local EMERGE_MAX = 15
local EMERGE_MAX2 = EMERGE_MAX*EMERGE_MAX

local events =
{
    EventHandler("attacked", function(inst)
        if not (inst.components.health:IsDead() or
	    inst.sg:HasStateTag("hit") or
	    inst.sg:HasStateTag("attack")) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("newcombattarget", function(inst)
        if inst.components.combat:HasTarget() and inst.sg:HasStateTag("attack_idle") then
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("emerge", function(inst)
        --V2C: This tag is only on the idle state, so
        --     that is why there was no "busy" check.
        if inst.sg:HasStateTag("retracted") then
            inst.sg:GoToState("emerge")
        end
    end),
    EventHandler("retract", function(inst)
        --V2C: This tag is only on the idle state, so
        --     that is why there was no "busy" check.
        if inst.sg:HasStateTag("emerged") then
            inst.sg:GoToState("retract")
        end
    end),
    CommonHandlers.OnFreeze(),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "retracted" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("breach_pre")
            inst.AnimState:PushAnimation("breach_loop", true)
        end,

        ontimeout = function(inst)
            --[[if inst.components.playerprox:IsPlayerClose() then
                inst:Emerge()
            end]]
        end,

        onexit = function(inst)
            --inst.sg.statemem.task:Cancel()
        end,
    },

    State{
        name = "attack_idle",
        tags = { "attack_idle", "emerged" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_idle")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.9, .1))
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.combat.target then
                    inst.sg:GoToState("attack")
                else
                    inst.sg:GoToState("retract")
                end
                --[[inst.sg:GoToState(
                    (inst.retracted and "retract") or
                    (inst.components.combat:HasTarget() and "attack") or
                    "attack_idle"
                )]]
            end),
        },
    },

    State{
        name = "emerge",
        tags = { "emerge" },

        onenter = function(inst)
	    inst.retracted = false
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.9, .1))
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_emerge")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.combat.target then
                    inst.sg:GoToState("attack")
                else
                    inst.sg:GoToState("retract")
                end
                --[[inst.sg:GoToState(
                    (inst.retracted and "retract") or
                    (inst.components.combat:HasTarget() and "attack") or
                    "attack_idle"
                )]]
            end),
        },
    },

    State{
        name = "attack",
        tags = { "attack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk_loop")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(1, .05))
            inst.components.combat:StartAttack()
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_attack") end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_attack") end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.combat.target then
                    inst.sg:GoToState("attack")
                else
                    inst.sg:GoToState("retract")
                end
                --[[inst.sg:GoToState(
                    (inst.retracted and "retract") or
                    (inst.components.combat:HasTarget() and "attack") or
                    "attack_idle"
                )]]
            end),
        },
    },

    State{
        name = "retract",
        tags = { "retract" },

        onenter = function(inst)
	    inst.retracted = true
            inst.AnimState:PlayAnimation("atk_pst")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(1, .05))
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/smalltentacle_disappear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
		inst.sg:GoToState(inst.retracted and "idle" or "emerge")
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
	    if inst.components.freezable:IsFrozen() then
		inst.components.freezable:Unfreeze()
	    end

            inst.AnimState:PlayAnimation("death")
            inst.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(.8, .2))
        end,

        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_splat_arm") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentapiller_hurt_VO")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("attack_idle")
            end),
        },
    },

    State{
        name = "frozen",
        tags = { "busy", "frozen" },

        onenter = function(inst)
	    inst.retracted = false
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("frozen", true)
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
		inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "retract") --"idle")
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
		inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "retract") --"idle")
	    end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
	    inst.components.freezable:Unfreeze()
        end,
    },
}

--CommonStates.AddFrozenStates(states)

return StateGraph("sdf_pumpkin_gorge_well_vine", states, events, "idle")
