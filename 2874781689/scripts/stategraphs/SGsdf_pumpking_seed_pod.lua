require("stategraphs/commonstates")

local events =
{
    EventHandler("death", function(inst)
	if inst:HasTag("sdf_pumpking_seed_pod_ripe") then
	    inst.sg:GoToState("death")
	end
    end),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
	    if inst:HasTag("sdf_pumpking_seed_pod_ripe_winter") then 
		inst.sg:GoToState("hitout_frozen")
	    elseif inst:HasTag("sdf_pumpking_seed_pod_ripe") then
		inst.sg:GoToState("hitout")
	    end
        end
    end),
}

local states =
{

    State{
        name = "idlein",
        tags = { "idle", "hiding", "vine" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },

    State{
        name = "emerge",
        tags = { "idle", "hiding" },

        onenter = function(inst, playanim)
            inst.AnimState:PlayAnimation("emerge")

	    local x,_,z=inst.Transform:GetWorldPosition()
	    local s = 1.5 --1.5
	    local pumpkingGrowthFX = SpawnPrefab("farm_plant_happy")
	    pumpkingGrowthFX.Transform:SetPosition(x,_,z)
	    pumpkingGrowthFX.Transform:SetScale(s,s,s)

            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_emerge")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("taunt")
                end
            end),
        },
    },

    State{
        name = "hibernate",
        tags = { "idle", "hiding" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
	    inst.AnimState:PlayAnimation("idle", true)
        end,
    },

    State{
        name = "taunt",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
	    if inst:HasTag("sdf_pumpking_seed_pod_ripe_winter") then
		inst.sg:GoToState("hibernate")
	    else
		inst.AnimState:PlayAnimation("taunt", true)
	    end
        end,
    },

    State{
        name = "hithibernate",
        tags = { "busy", "hit", "hiding" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hibernate")
                end
            end),
        },
    },

    State{
        name = "hitout",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_out")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("taunt")
                end
            end),
        },
    },

    State{
        name = "hitout_frozen",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_out")

	    if inst:HasTag("sdf_pumpking_seed_pod_ripe_winter") then
		local fx = SpawnPrefab("shatter")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx.components.shatterfx:SetLevel(2)
	    end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hithibernate")
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")

            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_die")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_retract")
        end,
    },

}

return StateGraph("SGsdf_pumpking_seed_pod", states, events, "idlein")