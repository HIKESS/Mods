require("stategraphs/commonstates")

local function FixupWorkerCarry(inst, swap)
    if swap ~= nil  then
		if inst.sg.mem.swaptool == swap then
			return false
		end
		inst.sg.mem.swaptool = swap
		if swap == nil then
            inst.AnimState:ClearOverrideSymbol("swap_object")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
        else
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
            inst.AnimState:OverrideSymbol("swap_object", swap, swap)
        end
		return true
    else
        inst.AnimState:Hide("swap_arm_carry")
    end
end

local function DetachFX(fx)
	fx.Transform:SetPosition(fx.Transform:GetWorldPosition())
	fx.entity:SetParent(nil)
end

local function DoDespawnFX(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local fx1 = SpawnPrefab("shadow_despawn")
	local fx2 = SpawnPrefab("shadow_glob_fx")
	fx2.AnimState:SetScale(math.random() < .5 and -1.3 or 1.3, 1.3, 1.3)
	local platform = inst:GetCurrentPlatform()
	if platform ~= nil then
		fx1.entity:SetParent(platform.entity)
		fx2.entity:SetParent(platform.entity)
		fx1:ListenForEvent("onremove", function() DetachFX(fx1) end, platform)
		x, y, z = platform.entity:WorldToLocalSpace(x, y, z)
	end
	fx1.Transform:SetPosition(x, y, z)
	fx2.Transform:SetPosition(x, y, z)
end

local function TrySplashFX(inst, size)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		SpawnPrefab("ocean_splash_"..(size or "med")..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
		return true
	end
end

local function TryStepSplash(inst)
	local t = GetTime()
	if (inst.sg.mem.laststepsplash == nil or inst.sg.mem.laststepsplash + .1 < t) and TrySplashFX(inst) then
		inst.sg.mem.laststepsplash = t
	end
end

local function DoSound(inst, sound)
	inst.SoundEmitter:PlaySound(sound)
end

local function NotBlocked(pt)
	return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function TryRepeatAction(inst, buffaction, right)
	if buffaction ~= nil and
		buffaction:IsValid() and
		buffaction.target ~= nil and
		buffaction.target.components.workable ~= nil and
		buffaction.target.components.workable:CanBeWorked() and
		buffaction.target:IsActionValid(buffaction.action, right)
		then
		local otheraction = inst:GetBufferedAction()
		if otheraction == nil or (
			otheraction.target == buffaction.target and
			otheraction.action == buffaction.action
		) then
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			inst:PushBufferedAction(buffaction)
			return true
		end
	end
	return false
end

local actionhandlers =
{
    ActionHandler(ACTIONS.CHOP,
        function(inst)
			if FixupWorkerCarry(inst, "swap_muhun") then
				return "item_out_chop"
			elseif not inst.sg:HasStateTag("prechop") then
                return inst.sg:HasStateTag("chopping")
                    and "chop"
                    or "chop_start"
            end
        end),
    ActionHandler(ACTIONS.MINE,
        function(inst)
			if FixupWorkerCarry(inst, "swap_tasui") then
				return "item_out_mine"
			elseif not inst.sg:HasStateTag("premine") then
                return inst.sg:HasStateTag("mining")
                    and "mine"
                    or "mine_start"
            end
        end),
    ActionHandler(ACTIONS.DIG,
        function(inst)
			if FixupWorkerCarry(inst, "swap_muhun") then
				return "item_out_dig"
			elseif not inst.sg:HasStateTag("predig") then
                return inst.sg:HasStateTag("digging")
                    and "dig"
                    or "dig_start"
            end
        end),
    ActionHandler(ACTIONS.GIVE, "give"),
    ActionHandler(ACTIONS.GIVEALLTOPLAYER, "give"),
    ActionHandler(ACTIONS.DROP, "give"),
    ActionHandler(ACTIONS.PICKUP, "take"),
    ActionHandler(ACTIONS.CHECKTRAP, "take"),
    ActionHandler(ACTIONS.PICK,
		function(inst, action)
			return action.target ~= nil
				and (action.target.components.pickable ~= nil and (
						(action.target.components.pickable.jostlepick and "doshortaction") or
						(action.target.components.pickable.quickpick and "doshortaction") or
						"dolongaction"
					)) or
					(action.target.components.searchable ~= nil and (
						(action.target.components.searchable.jostlesearch and "doshortaction") or
						(action.target.components.searchable.quicksearch and "doshortaction") or
						"dolongaction"
					))
				or nil
		end),
}

local events =
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnDeath(),
	EventHandler("attacked", function(inst, data)
		if not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
			if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
                inst.sg:GoToState("pinned_hit")
			else 
				inst.sg:GoToState("hit")
			end 
		end
	end),
    EventHandler("pinned",
        function(inst, data)
            if inst.components.health ~= nil and not inst.components.health:IsDead() and inst.components.pinnable ~= nil then
                if inst.components.pinnable.canbepinned then
                    inst.sg:GoToState("pinned_pre", data)
                elseif inst.components.pinnable:IsStuck() then
                    inst.components.pinnable:Unstick()
                end
            end
        end),
    EventHandler("freeze",
        function(inst)
            if inst.components.health ~= nil and not inst.components.health:IsDead() then
                inst.sg:GoToState("frozen")
            end
        end),
}

local states =
{
	State{
		name = "spawn",
		tags = { "busy", "noattack", "temp_invincible" },

		onenter = function(inst, mult)
			inst.Physics:Stop()
			ToggleOffCharacterCollisions(inst)
			inst.AnimState:PlayAnimation("minion_spawn")
			mult = mult or (0.8 + math.random() * 0.2)
			inst.AnimState:SetDeltaTimeMultiplier(mult)

			mult = 1 / mult
			inst.sg.statemem.tasks =
			{
                inst:DoTaskInTime(0 * FRAMES * mult, DoSound, "maxwell_rework/shadow_worker/spawn"),
				inst:DoTaskInTime(0 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(20 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(44 * FRAMES * mult, TrySplashFX, "small"),
			}
			inst.sg:SetTimeout(70 * FRAMES * mult)
		end,

		ontimeout = function(inst)
			inst.sg:AddStateTag("caninterrupt")
			ToggleOnCharacterCollisions(inst)
			inst.AnimState:SetDeltaTimeMultiplier(1)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.spawn then
				ToggleOnCharacterCollisions(inst)
				inst.AnimState:SetDeltaTimeMultiplier(1)
			end
			for i, v in ipairs(inst.sg.statemem.tasks) do
				v:Cancel()
			end
		end,
	},

	State{
		name = "quickspawn",

		onenter = function(inst)
			SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst.sg:GoToState("idle")
		end,
	},

	State{
		name = "quickdespawn",

		onenter = function(inst)
			DoDespawnFX(inst)
			if inst.sg.mem.laststepsplash ~= GetTime() then
				TrySplashFX(inst)
			end
			inst:Remove()
		end,
	},

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },

        timeline =
        {
			TimeEvent(1 * FRAMES, TryStepSplash),
			TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
        },
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("run_loop") then
                inst.AnimState:PlayAnimation("run_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
			TimeEvent(5 * FRAMES, TryStepSplash),
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
				inst.sg.mem.laststepsplash = GetTime()
            end),
			TimeEvent(13 * FRAMES, TryStepSplash),
            TimeEvent(15 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
				inst.sg.mem.laststepsplash = GetTime()
            end),
        },

        ontimeout = function(inst)
			inst.sg.statemem.running = true
            inst.sg:GoToState("run")
        end,

		onexit = function(inst)
			if not inst.sg.statemem.running then
				TryStepSplash(inst)
			end
		end,
    },

    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,

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
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("death")
        end,

		timeline =
		{
			TimeEvent(13 * FRAMES, TrySplashFX),
			TimeEvent(38 * FRAMES, TrySplashFX),
		},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					DoDespawnFX(inst)
					TrySplashFX(inst)
                    inst:Remove()
                end
            end),
        },
    },

    State{
        name = "take",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle") 
                end
            end),
        },
    },

    State{
        name = "give",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events=
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
        tags = {"busy"},

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
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
        name = "chop_start",
        tags = {"prechop", "working"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("chop")
                end
            end),
        },
    },

    State{
        name = "chop",
        tags = {"prechop", "chopping", "working"},

        onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("chop_loop")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(14 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prechop")
				TryRepeatAction(inst, inst.sg.statemem.action)
            end),
            TimeEvent(16*FRAMES, function(inst)
                inst.sg:RemoveStateTag("chopping")
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

    State{
        name = "mine_start",
        tags = {"premine", "working"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mine")
                end
            end),
        },
    },

    State{
        name = "mine",
        tags = {"premine", "mining", "working"},

        onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
				if inst.sg.statemem.action ~= nil then
					PlayMiningFX(inst, inst.sg.statemem.action.target)
					inst.sg.statemem.recoilstate = "mine_recoil"
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(14 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("premine")
				TryRepeatAction(inst, inst.sg.statemem.action)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

	State{
		name = "mine_recoil",
		tags = { "busy", "recoil" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()

			inst.AnimState:PlayAnimation("pickaxe_recoil")
			if data ~= nil and data.target ~= nil and data.target:IsValid() then
                local pos = data.target:GetPosition()

                if data.target.recoil_effect_offset then
                    pos = pos + data.target.recoil_effect_offset
                end
                
				SpawnPrefab("impact").Transform:SetPosition(pos:Get())
			end
			inst.Physics:SetMotorVelOverride(-6, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speed ~= nil then
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
			end
		end,

		timeline =
		{
			FrameEvent(4, function(inst)
				inst.sg.statemem.speed = -3
			end),
			FrameEvent(17, function(inst)
				inst.sg.statemem.speed = nil
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),
			FrameEvent(23, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(30, function(inst)
				inst.sg:GoToState("idle", true)
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

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
		end,
	},

    State{
        name = "dig_start",
        tags = {"predig", "working"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("dig")
                end
            end),
        },
    },

    State{
        name = "dig",
        tags = {"predig", "digging", "working"},

        onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("shovel_loop")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
            end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("predig")
				TryRepeatAction(inst, inst.sg.statemem.action, true)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "dolongaction",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst, timeout)
            if timeout == nil then
                timeout = 1
            elseif timeout > 1 then
                inst.sg:AddStateTag("slowaction")
            end
            inst.sg:SetTimeout(timeout)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
					inst.bufferedaction.target:PushEvent("startlongaction", inst)
                end
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("build_pst")
            inst:PerformBufferedAction()
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
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "doshortaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("pickup")
			inst.AnimState:PushAnimation("pickup_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(6 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

	State{
		name = "disappear",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },

		onenter = function(inst, attacker)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			ToggleOffCharacterCollisions(inst)
			inst.AnimState:PlayAnimation("disappear")
			if attacker ~= nil and attacker:IsValid() then
				inst.sg.statemem.attackerpos = attacker:GetPosition()
			end
			TrySplashFX(inst, "small")
			inst.components.combat:SetTarget(nil)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local theta =
						inst.sg.statemem.attackerpos ~= nil and
						inst:GetAngleToPoint(inst.sg.statemem.attackerpos) or
						inst.Transform:GetRotation()

					theta = (theta + 165 + math.random() * 30) * DEGREES

					local pos = inst:GetPosition()
					pos.y = 0

					local offs =
						FindWalkableOffset(pos, theta, 4 + math.random(), 8, false, true, NotBlocked, true, true) or
						FindWalkableOffset(pos, theta, 2 + math.random(), 6, false, true, NotBlocked, true, true)

					if offs ~= nil then
						pos.x = pos.x + offs.x
						pos.z = pos.z + offs.z
					end
					inst.Physics:Teleport(pos:Get())
					if inst.sg.statemem.attackerpos ~= nil then
						inst:ForceFacePoint(inst.sg.statemem.attackerpos)
					end

					inst.sg.statemem.appearing = true
					inst.sg:GoToState("appear")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.appearing then
				ToggleOnCharacterCollisions(inst)
			end
		end,
	},

	State{
		name = "appear",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			ToggleOffCharacterCollisions(inst)
			inst.AnimState:PlayAnimation("appear")
		end,

		timeline =
		{
			TimeEvent(9 * FRAMES, function(inst)
				TrySplashFX(inst, "small")
			end),
			TimeEvent(11 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("temp_invincible")
				inst.sg:RemoveStateTag("phasing")
				ToggleOnCharacterCollisions(inst)
			end),
			TimeEvent(13 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
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

		onexit = ToggleOnCharacterCollisions,
	},

	State{
		name = "item_out_chop",
		onenter = function(inst) inst.sg:GoToState("item_out", "chop") end,
	},

	State{
		name = "item_out_mine",
		onenter = function(inst) inst.sg:GoToState("item_out", "mine") end,
	},

	State{
		name = "item_out_dig",
		onenter = function(inst) inst.sg:GoToState("item_out", "dig") end,
	},

	State{
		name = "item_out_atk",
		tags = { "working" ,"busy"},

		onenter = function(inst, action)
			inst.AnimState:Show("ARM_carry")
			inst.AnimState:Hide("ARM_normal")
			inst.AnimState:OverrideSymbol("swap_object", "swap_duoluo", "swap_duoluo")
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("item_out")
		end,

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
		name = "item_out",
		tags = { "working" },

		onenter = function(inst, action)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("item_out")
			if action ~= nil then
				inst.sg:AddStateTag("pre"..action)
				inst.sg.statemem.action = action
				inst.sg:SetTimeout(9 * FRAMES)
			else
				inst.sg:RemoveStateTag("working")
				inst.sg:AddStateTag("idle")
			end
		end,

		ontimeout = function(inst)
			inst.sg:GoToState(inst.sg.statemem.action.."_start")
		end,

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
        name = "pinned_pre",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
                inst.components.freezable:Unfreeze()
            end
            if inst.components.pinnable == nil or not inst.components.pinnable:IsStuck() then
                inst.sg:GoToState("breakfree")
                return
            end
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_goosplat", inst.components.pinnable.goo_build or "goo", "swap_goosplat")
            inst.AnimState:PlayAnimation("hit")

        end,

        events =
        {
            EventHandler("onunpin", function(inst, data)
                inst.sg:GoToState("breakfree")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.isstillpinned = true
                    inst.sg:GoToState("pinned")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_goosplat")
        end,
    },

    State{
        name = "pinned",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            if inst.components.pinnable == nil or not inst.components.pinnable:IsStuck() then
                inst.sg:GoToState("breakfree")
                return
            end

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("distress_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_playerstruggle", "struggling")

        end,

        events =
        {
            EventHandler("onunpin", function(inst, data)
                inst.sg:GoToState("breakfree")
            end),
        },

    },

    State{
        name = "pinned_hit",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit_goo")

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")

        end,

        events =
        {
            EventHandler("onunpin", function(inst, data)
                inst.sg:GoToState("breakfree")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.isstillpinned = true
                    inst.sg:GoToState("pinned")
                end
            end),
        },

    },

    State{
        name = "breakfree",
        tags = { "busy", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("distress_pst")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_playerunstuck")

        end,

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

CommonStates.AddFrozenStates(states)

return StateGraph("gw_shadow", states, events, "spawn", actionhandlers)