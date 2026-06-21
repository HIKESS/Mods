require("stategraphs/commonstates")


local events =
{
    EventHandler("death", function(inst)
	if inst.prefab == "sdf_pumpking_bomb" or inst.prefab == "sdf_pumpkin_bomb" then
	    if inst.growth == true and inst.retracted == false then
		inst.sg:GoToState("picked")
	    elseif inst.growth == true then
		inst.sg:GoToState("deathvine")
	    else
		inst.sg:GoToState("death")
	    end
	else
	    if inst.growth == true and not inst.components.freezable:IsFrozen() then
		--inst.growth = false
		inst.sg:GoToState("deathvine")
	    else
		inst.sg:GoToState("death")
	    end
	end
    end),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
	    if inst.prefab == "sdf_pumpking_bomb" or inst.prefab == "sdf_pumpkin_bomb" then
		if inst.growth == true and inst.retracted == false then
		    inst.sg:GoToState("hitout")
		elseif inst.growth == true then
		    inst.sg:GoToState("hitin")
		else
		    inst.sg:GoToState("hit_hidden")
		end
	    else
		if inst.growth == true then
		    inst.sg:GoToState("hitin")
		else
		    inst.sg:GoToState("hit_hidden")
		end
	    end
        end
    end),

    EventHandler("worked", function(inst)
	if not inst.components.health:IsDead() then
	    if inst.prefab == "sdf_pumpking_bomb" or inst.prefab == "sdf_pumpkin_bomb" then
		if inst.growth == true and inst.retracted == false then
		    inst.sg:GoToState("hitout")
		elseif inst.growth == true then
		    inst.sg:GoToState("hitin")
		else
		    inst.sg:GoToState("hit_hidden")
		end
	    else
		if inst.growth == true then
		    inst.sg:GoToState("hitin")
		else
		    inst.sg:GoToState("hit_hidden")
		end
	    end
	end
    end),
}

local states =
{
    State{
        name = "idleout",
        tags = { "idle" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_out", true)
            else
                inst.AnimState:PlayAnimation("idle_out", true)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
		    
                    inst.sg:GoToState(math.random() < .1 and "taunt" or "idleout")
                end
            end),
        },
    },

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
            inst.AnimState:PlayAnimation("idle_trans")
	    inst.growth = true

	    local x,_,z=inst.Transform:GetWorldPosition()
	    local s = 1.5 --1.5
	    local pumpkingGrowthFX = SpawnPrefab("farm_plant_happy")
	    pumpkingGrowthFX.Transform:SetPosition(x,_,z)
	    pumpkingGrowthFX.Transform:SetScale(s,s,s)

            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_emerge")

	    --pumpking bombs explode
	    if inst.summoned == true and inst.prefab == "sdf_pumpking_bomb" then
		inst:OnSummon()
	    end

	    --pumpkin bombs taunt
	    if inst.prefab == "sdf_pumpkin_bomb" then
		inst:OnTaunt()
	    end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idlein")
                end
            end),
        },
    },

    State{
        name = "hibernate",
        tags = { "idle", "hiding" },

        onenter = function(inst, playanim)

            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_hidden", true)
            else
                inst.AnimState:PlayAnimation("idle_hidden", true)
            end
        end,
    },

    State{
        name = "taunt",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("taunt", true)
            inst.sg:SetTimeout(math.random() * 4 + 2)
        end,

        ontimeout = function(inst)
	    if inst.ignited == true then
		inst.sg:GoToState("taunt")
	    else
		inst.sg:GoToState("idlein")
	    end
        end,
    },

    State{
        name = "taunt_showbait",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("taunt", true)
            inst.sg:SetTimeout(math.random() * 4 + 2)
        end,

        ontimeout = function(inst)
	    if inst.ignited == false then
		inst.sg:GoToState("hidebait")
	    else
		inst.sg:GoToState("idleout")
	    end
        end,
    },

    State{
        name = "hidebait",
        tags = { "busy", "hiding" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hide")
	    inst.retracted = true
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_close") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idlein")
                end
            end),
        },
    },

    State{
        name = "showbait",
        tags = { "busy" },

        onenter = function(inst, playanim)
            if inst.growth then
                --inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", inst.lure.prefab)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("emerge")

		inst.retracted = false
            else
                inst.sg:GoToState("idlein")
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_open") end),
        },

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
        name = "showbait_taunt",
        tags = { "busy" },

        onenter = function(inst, playanim)
            if inst.growth then
                --inst.AnimState:OverrideSymbol("swap_dried", "meat_rack_food", inst.lure.prefab)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("emerge")

		inst.retracted = false
            else
                inst.sg:GoToState("idlein")
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_open") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("taunt_showbait")
                end
            end),
        },
    },

    State{
        name = "hitin",
        tags = { "busy", "hit", "hiding" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idlein")
                end
            end),
        },
    },

    State{
        name = "hithibernate",
        tags = { "busy", "hit", "hiding" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_hidden")
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
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
	    inst.growth = false
            inst.AnimState:PlayAnimation("death_hidden")

            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_die")
        end,
    },

    State{
        name = "deathvine",
        tags = { "busy" },

        onenter = function(inst)
	    inst.growth = false
            inst.AnimState:PlayAnimation("death")

            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_die")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_retract")
        end,
    },

    State{
        name = "picked",
        tags = { "busy" },

        onenter = function(inst)
	    inst.growth = false
            inst.AnimState:PlayAnimation("pick")
	    inst.AnimState:PushAnimation("idle_hidden")

            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_die")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/lure_close")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/vine_retract")
        end,
    },

    State{
        name = "spawn",
        tags = { "busy", "hiding" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_hidden") --("grow")

	    local x,_,z=inst.Transform:GetWorldPosition()
	    SpawnPrefab("shovel_dirt").Transform:SetPosition(x,_,z)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hibernate")
                end
            end),
        },

        onexit = function(inst)
            inst:PushEvent("freshspawn")
        end,
    },
}

return StateGraph("SGsdf_pumpking_gourd", states, events, "idlein")