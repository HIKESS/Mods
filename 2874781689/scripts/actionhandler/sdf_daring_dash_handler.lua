local Vector3 = GLOBAL.Vector3
local DEGREES = GLOBAL.DEGREES

local animation_Pre = "run_pre"
local animation_Loop = "run_loop"
local animation_Stop = "run_pst"
local animation_Impact = "hit_spike_heavy"

local function removeDaringDashStatus(inst)
    if inst:HasTag("sdf_shield_daring_dash_active") then
	inst:RemoveTag("sdf_shield_daring_dash_active")
    end

    if inst:HasTag("sdf_daring_dash_action_active") then
	inst:RemoveTag("sdf_daring_dash_action_active")
    end

    --Remove Daring Dash Trail
    if inst.sg.statemem.trailtask ~= nil then
	inst.sg.statemem.trailtask:Cancel()
	inst.sg.statemem.trailtask = nil
    end
end

local function DoEquipmentFoleySounds(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.foleysound ~= nil then
            inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
        end
    end
end

local function PlayMooseFootstep(inst, volume, ispredicted)
    DoEquipmentFoleySounds(inst)

    --moose footstep always full volume
    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep", nil, nil, ispredicted)
    PlayFootstep(inst, volume, ispredicted)
end
---------------------------------------------------------------------------------------------------------------
local function EnableReticule(inst, enable)
    if enable then
        if inst.components.reticule == nil then
            inst:AddComponent("reticule")
            inst.components.reticule.reticuleprefab = "reticuleline"
	    inst.components.reticule.pingprefab = "reticulelineping"
            inst.components.reticule.targetfn = ReticuleTargetFn
	    inst.components.reticule.mousetargetfn = ReticuleMouseTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
	    inst.components.reticule.validcolour = { 1, .75, 0, 1 }
	    inst.components.reticule.invalidcolour = { .5, 0, 0, 1 }
	    inst.components.reticule.ease = true
	    inst.components.reticule.mouseenabled = true
            if inst.components.playercontroller ~= nil and inst == ThePlayer then
                inst.components.playercontroller:RefreshReticule()
            end
        end
    elseif inst.components.reticule ~= nil then
	--inst:DoTaskInTime(0.1, function()
        inst:RemoveComponent("reticule")
        if inst.components.playercontroller ~= nil and inst == ThePlayer then
            inst.components.playercontroller:RefreshReticule()
        end
	--end)
    end
end
---------------------------------------------------------------------------------------------------------------
sdf_daring_dash_stop = State({
        name = "sdf_daring_dash_stop",
        tags = { "busy", "nopredict", "nomorph", "nointerrupt" },

	onenter = function(inst)
            inst.AnimState:PlayAnimation(animation_Stop)
            inst.sg.statemem.speed = 12
            inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            PlayMooseFootstep(inst)

	    --Slide FX
	    local x,y,z = inst.Transform:GetWorldPosition()
	    local daring_dash_preFX = SpawnPrefab("slide_puff").Transform:SetPosition(x,y,z)
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/slide")

	    removeDaringDashStatus(inst)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed > .1 then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                inst.sg.statemem.speed = inst.sg.statemem.speed * .75
            elseif inst.sg.statemem.speed > 0 then
                inst.Physics:Stop()
                inst.sg.statemem.speed = 0
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
            end),
            TimeEvent(22 * FRAMES, function(inst)
		removeDaringDashStatus(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
		    removeDaringDashStatus(inst)

		    --Remove Daring Dash Protection
		    local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		    if shield then
			shield.DaringDashArmor = 0
			shield.components.armor:SetAbsorption(0)
			inst.sg:GoToState("idle")
		    else
			inst.sg:GoToState("hit")
		    end
                end
            end),
        },

        onexit = function(inst)
	    removeDaringDashStatus(inst)
            inst.Physics:Stop()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
})
---------------------------------------------------------------------------------------------------------------
sdf_daring_dash_collide = State({
        name = "sdf_daring_dash_collide",
        tags = { "busy", "nopredict", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation(animation_Impact)

	    --Slide FX
	    local x,y,z = inst.Transform:GetWorldPosition()
	    local daring_dash_preFX = SpawnPrefab("slide_puff").Transform:SetPosition(x,y,z)

	    removeDaringDashStatus(inst)
        end,

        timeline =
        {
            TimeEvent(8.5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
            end),
            TimeEvent(35 * FRAMES, function(inst)
		removeDaringDashStatus(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
		    removeDaringDashStatus(inst)

		    --Remove Daring Dash Protection
		    local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		    if shield then
			shield.DaringDashArmor = 0
			shield.components.armor:SetAbsorption(0)
			inst.sg:GoToState("idle")
		    else
			inst.sg:GoToState("hit")
		    end
                end
            end),
        },

        onexit = function(inst)
	    removeDaringDashStatus(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
})
---------------------------------------------------------------------------------------------------------------
sdf_daring_dash = State({
        name = "sdf_daring_dash",
		tags = { "busy", "nopredict", "nomorph", "nointerrupt", "overridelocomote" },

        onenter = function(inst, data)
            inst.sg.statemem.targets = data ~= nil and data.targets or nil
            inst.sg.statemem.edgecount = data ~= nil and data.edgecount or 0
	    inst.sg.statemem.daringDashCount = data ~= nil and data.daringDashCount or 0
	    inst.sg.statemem.hungry = data ~= nil and data.hungry or false
            inst.sg.statemem.trailtask = data ~= nil and data.trail or nil
            inst.sg.statemem.loop = data ~= nil and data.loop or 0

            if not inst.AnimState:IsCurrentAnimation(animation_Loop) then
                inst.AnimState:PlayAnimation(animation_Loop, true)
            end

	    --Skill Tree Grit
	    if inst.components.skilltreeupdater:IsActivated("sdf_backbone_3") then
		inst.sg.statemem.daringDashCount = TUNING.SDF_SKILLSET_BACKBONE_GRIT
	    end

            inst.sg:SetTimeout(
                inst.sg.statemem.loop > 0 and
                inst.AnimState:GetCurrentAnimationLength()
            )
        end,

        events =
        {
	    --maybe need this
            EventHandler("locomote", function(inst, data)
		    if data ~= nil and data.remoteoverridelocomote then
			removeDaringDashStatus(inst)
			inst.sg.statemem.stopping = true
			inst.sg:GoToState("sdf_daring_dash_stop")
		    end
		    return true
            end),
        },

        timeline =
        {
            TimeEvent(1 * FRAMES, PlayMooseFootstep),
            TimeEvent(4 * FRAMES, PlayMooseFootstep),
            TimeEvent(10 * FRAMES, PlayMooseFootstep),
        },

        onupdate = function(inst)
            if inst.components.tackler ~= nil then
		local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
                if inst.components.tackler:CheckCollision(inst.sg.statemem.targets) then
		    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("sdf_daring_dash_collide")
		    return
		elseif shield then
		    if shield.components.rechargeable then
			local dashDuration = shield.components.rechargeable:GetTimeToCharge()
			if inst.sg.statemem.daringDashCount == nil then
			    inst.sg.statemem.daringDashCount = 0
			end
			hungry = inst.sg.statemem.hungry
			if (TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_COOLDOWN - dashDuration) >= (TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_DURATION + inst.sg.statemem.daringDashCount) then
			    inst.sg.statemem.stopping = true
			    inst.sg:GoToState("sdf_daring_dash_stop")
			    return
			end
		    end
                elseif not inst.components.tackler:CheckEdge() then
                    inst.sg.statemem.edgecount = 0
                elseif inst.sg.statemem.edgecount < 3 then
                    inst.sg.statemem.edgecount = inst.sg.statemem.edgecount + 1
                else
                    inst.sg.statemem.stopping = true
		    inst.sg:GoToState("sdf_daring_dash_stop")
		    return
                end
            end

	    if inst.sg.statemem.cancancel and inst.HUD ~= nil then
		local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
		if math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)) >= deadzone or
		    math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)) >= deadzone
		then
		    inst.sg.statemem.stopping = true
		    inst.sg:GoToState("sdf_daring_dash_stop")
		end
	    end
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.loop > 0 then
                inst.sg.statemem.tackling = true
                inst.sg:GoToState("sdf_daring_dash", {
		    targets = inst.sg.statemem.targets,
                    edgecount = inst.sg.statemem.edgecount,
		    daringDashCount = inst.sg.statemem.daringDashCount,
		    hungry = inst.sg.statemem.hungry,
                    trail = inst.sg.statemem.trailtask,
                    loop = inst.sg.statemem.loop - 1,
		    cancancel = inst.sg.statemem.cancancel == true,
                })
            else
                inst.sg.statemem.stopping = true
		inst.sg:GoToState("sdf_daring_dash_stop")
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.tackling then
		inst.player_classified.busyremoteoverridelocomote:set(false)
                if inst.sg.statemem.trailtask ~= nil then
                    inst.sg.statemem.trailtask:Cancel()
                    inst.sg.statemem.trailtask = nil
                end
                inst.Physics:Stop()
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
		if not inst.sg.statemem.stopping and inst.components.playercontroller ~= nil then
		    inst.components.playercontroller:Enable(true)
                end
            end
        end,
})
---------------------------------------------------------------------------------------------------------------
sdf_daring_dash_start = State({
        name = "sdf_daring_dash_start",
        tags = { "busy", "nopredict", "nomorph", "nointerrupt" },

        onenter = function(inst)

	    --Must have Shield
	    local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	    if shield then
		if shield.components.rechargeable and not shield.components.rechargeable:IsCharged() then
		    removeDaringDashStatus(inst)
		    inst.components.talker:Say(GetString(inst, "ANNOUNCE_SDF_DARING_DASH_COOLDOWN"))
		    inst.sg:GoToState("idle")
		elseif (inst.components.hunger ~= nil and inst.components.hunger:GetPercent() <= TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_HUNGER_LIMITER) then
			inst.AnimState:PlayAnimation("hungry")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
			inst.sg.statemem.hungry = true
		else

		    --Start FX
		    local x,y,z = inst.Transform:GetWorldPosition()    
		    inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/whoosh")

		    --Start cooldown
		    if shield.components.rechargeable then
			shield.components.rechargeable:Discharge(TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_COOLDOWN)
		    end

		    --Hunger Usage
		    if inst.components.hunger and inst.components.health then
			if not inst.components.health:IsInvincible() then
			    inst.components.hunger.current = (inst.components.hunger.current - TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_HUNGER_USAGE)
			end
		    end

		    inst.components.locomotor:Stop()
		    inst.sg.statemem.tackling = true
		    inst.AnimState:PlayAnimation(animation_Pre)
		    inst.Physics:SetMotorVel(12, 0, 0)
		    inst.Physics:ClearCollisionMask()
		    inst.Physics:CollidesWith(COLLISION.WORLD)
		    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
		    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
		    inst.Physics:CollidesWith(COLLISION.GIANTS)
		    inst.sg.statemem.targets = {}
		    inst.sg.statemem.edgecount = 0
		    inst.sg.statemem.daringDashCount = 0
		    inst.sg.statemem.hungry = false

		    --Remove Daring Dash Trail
		    if inst.sg.statemem.trailtask ~= nil then
			inst.sg.statemem.trailtask:Cancel()
			inst.sg.statemem.trailtask = nil
		    else
			inst.sg.statemem.trailtask = nil
		    end

		    --Skill Tree Daring Dash and Grit
		    if inst.prefab == "sdf" then

			--Skill Tree Daring Dash
			inst:AddTag("sdf_shield_daring_dash_active")

			--Add Daring Dash Armor
			if shield.DaringDashArmor then
			    shield.DaringDashArmor = TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ARMOR
			end

			if inst.components.skilltreeupdater:IsActivated("sdf_backbone_3") then
			    inst.sg.statemem.daringDashCount = TUNING.SDF_SKILLSET_BACKBONE_GRIT
			end

			--Add Daring Dash Protection
			local shieldDurability = shield.components.armor.condition --For Gold Shield
			if shieldDurability > 0 then
			    shield.components.armor:SetAbsorption(1)
			end
		    end

		    inst.sg.statemem.trailtask = inst:DoPeriodicTask(0, function(inst, data)
			if data.delay > 0 then
			    data.delay = data.delay - 1
			else
			    data.delay = math.random(4, 6)
			    local x, y, z = inst.Transform:GetWorldPosition()
			    local angle = inst.Transform:GetRotation() * DEGREES
			    local fx = SpawnPrefab("plant_dug_small_fx")
			    fx.Transform:SetPosition(x - math.cos(angle) * 1.6, 0, z + math.sin(angle) * 1.6)
			    if math.random() < .5 then
				fx.AnimState:SetScale(-1, 1)
			    end
			    local scale = .8 + math.random() * .5
			    fx.Transform:SetScale(scale, scale, scale)

			    --Daring Dash Dust
			    local DDTfx = SpawnPrefab("sdf_daring_dash_dust_fx")
			    DDTfx.Transform:SetPosition(x - math.cos(angle) * 1.6, 0.7, z + math.sin(angle) * 1.6)
			end
		    end,
		    nil,
		    { delay = 0 })
		end
	    else
		inst.sg.statemem.stopping = true
		removeDaringDashStatus(inst)
		inst.sg:GoToState("idle")
	    end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, PlayMooseFootstep),
        },

        onupdate = function(inst)
            if inst.components.tackler ~= nil and inst.sg.statemem.hungry == false then
		local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
                if inst.components.tackler:CheckCollision(inst.sg.statemem.targets) then
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("sdf_daring_dash_collide")
		    return
		elseif shield then
		    if shield.components.rechargeable then
			local dashDuration = shield.components.rechargeable:GetTimeToCharge()
			if inst.sg.statemem.daringDashCount == nil then
			    inst.sg.statemem.daringDashCount = 0
			end
			hungry = inst.sg.statemem.hungry
			if (TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_COOLDOWN - dashDuration) >= (TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_DURATION + inst.sg.statemem.daringDashCount) then
			    inst.sg.statemem.stopping = true
			    inst.sg:GoToState("sdf_daring_dash_stop")
			    return
			end
		    end
                elseif not inst.components.tackler:CheckEdge() then
                    inst.sg.statemem.edgecount = 0
                elseif inst.sg.statemem.edgecount < 3 then
                    inst.sg.statemem.edgecount = inst.sg.statemem.edgecount + 1
                else
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("sdf_daring_dash_stop")
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
		    if inst.sg.statemem.hungry == true then
			removeDaringDashStatus(inst)
			inst.sg:GoToState("idle")
		    else
			inst.sg.statemem.tackling = true
			inst.sg:GoToState("sdf_daring_dash", {
                            targets = inst.sg.statemem.targets,
                            edgecount = inst.sg.statemem.edgecount,
			    daringDashCount = inst.sg.statemem.daringDashCount,
			    hungry = inst.sg.statemem.hungry,
                            trail = inst.sg.statemem.trailtask,
                            loop = 3,
			})
		    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.tackling then
                if inst.sg.statemem.trailtask ~= nil then
                    inst.sg.statemem.trailtask:Cancel()
                    inst.sg.statemem.trailtask = nil
                end
                inst.Physics:Stop()
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                if not inst.sg.statemem.stopping and inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
            end
        end,
})
------------------------------------------------------------------------------------------------------------
sdf_daring_dash_pre = State({
    name = "sdf_daring_dash_pre",
    tags = { "busy" },
    
        onenter = function(inst)
	    --EnableReticule(inst, false)
	    --local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	    --if shield ~= nil then
		
	    --end

	    inst.components.locomotor:Stop()

	    inst.AnimState:PlayAnimation(animation_Pre)

	    --Off allows early stops
	    --if inst.components.playercontroller ~= nil then
		--inst.components.playercontroller:Enable(false)
	    --end

	    inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() - FRAMES)
        end,

        ontimeout = function(inst)
	    inst:PerformBufferedAction()
            if inst.sg.currentstate.name == "sdf_daring_dash_pre" then
                --action failed, do it anyway!
                --repro: action target entity is removed
                --inst.sg.statemem.tackling = true
                inst.sg:GoToState("sdf_daring_dash_start")
            end
        end,

        --[[onexit = function(inst)
            if not inst.sg.statemem.tackling and inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,]]
})

sdf_daring_dash_pre_client = State({
    name = "sdf_daring_dash_pre",
    tags = { "busy" },
	    server_states = { "sdf_daring_dash_pre", "sdf_daring_dash_start", "sdf_daring_dash" },

    onenter = function(inst)
	inst.components.locomotor:Stop()

	--inst.AnimState:PlayAnimation("animation_Pre")
	--inst.AnimState:PushAnimation("lunge_lag", false)

	inst:PerformPreviewBufferedAction()

	inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
	    if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
		    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
})


--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_daring_dash_stop)
AddStategraphState("wilson", sdf_daring_dash_collide)
AddStategraphState("wilson", sdf_daring_dash)
AddStategraphState("wilson", sdf_daring_dash_start)

AddStategraphState("wilson", sdf_daring_dash_pre)
AddStategraphState("wilson_client", sdf_daring_dash_pre_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
local originalTackle
local originalClientTackle

local function NewDestStateTACKLE(inst, action)
  inst.sg.mem.localchainattack = not action.forced or nil
  local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD) or nil
  if shield and shield:HasTag("sdf_shield_daring_dash") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("sdf_daring_dash_pre") and inst.components.combat ~= nil then
    return "sdf_daring_dash_pre"
  else
    return originalTackle(inst, action)
  end
end

local function NewClientDestStateTACKLE(inst, action)
  local shield = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD) or nil
  if shield and shield:HasTag("sdf_shield_daring_dash") and not inst.sg:HasStateTag("attack") and inst.replica.combat then
    return "sdf_daring_dash_pre"
  else
    return originalClientTackle(inst, action)
  end
end

AddStategraphPostInit('wilson', function(sg)
  actionhandlers = sg.actionhandlers
  for i,v in pairs(actionhandlers) do
    if v.action == ACTIONS.TACKLE then
      originalTackle = actionhandlers[i].deststate
      actionhandlers[i].deststate = NewDestStateTACKLE
    end
  end
end)

AddStategraphPostInit('wilson_client', function(sg)
  actionhandlers = sg.actionhandlers
  for i,v in pairs(actionhandlers) do
    if v.action == ACTIONS.TACKLE then
      originalClientTackle = actionhandlers[i].deststate
      actionhandlers[i].deststate = NewClientDestStateTACKLE
    end
  end
end)