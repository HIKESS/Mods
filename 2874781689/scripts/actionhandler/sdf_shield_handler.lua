local Vector3 = GLOBAL.Vector3
local DEGREES = GLOBAL.DEGREES

local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function DoTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/talk_LP", "talk")
        return true
    end
end

local function StopTalkSound(inst, instant)
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end

local function CancelTalk_Override(inst, instant)
    if inst.sg.statemem.talktask ~= nil then
	inst.sg.statemem.talktask:Cancel()
	inst.sg.statemem.talktask = nil
	StopTalkSound(inst, instant)
    end
end

local function OnTalk_Override(inst)
    CancelTalk_Override(inst, true)
    if DoTalkSound(inst) then
	inst.sg.statemem.talktask = inst:DoTaskInTime(1.5 + math.random() * .5, CancelTalk_Override)
    end
    return true
end

local function OnDoneTalking_Override(inst)
    CancelTalk_Override(inst)
    return true
end

local function checkHandActions(player)
    local hands = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hands then
	if not hands.components.aoetargeting then
	    return true
	else
	    return false
	end
    end
    return true
end

local function checkClientHandActions(player)
    local hands = player.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hands then
	if not hands.components.aoetargeting then
	    return true
	else
	    return false
	end
    end
    return true
end

local function IsWeaponEquipped(inst, weapon)
    return weapon ~= nil
        and weapon.components.equippable ~= nil
        and weapon.components.equippable:IsEquipped()
        and weapon.components.inventoryitem ~= nil
        and weapon.components.inventoryitem:IsHeldBy(inst)
end

local function cancelParry(inst)
    local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
    if shield then
	shield.components.aoetargeting:StopTargeting()

	--Remove Bonus Armor
	shield.BonusArmor = 0

    end

    --stop parry
    inst:DoTaskInTime(0.05, function()
	inst:SDF_ShieldParryRemoveFn()
	inst:SDF_ShieldParryDisableFn()
    end)

    --start talking
    if inst.components.talker then
	inst.components.talker:StopIgnoringAll()
    end

    --animation restore
    inst.AnimState:ClearOverrideSymbol("lantern_overlay")
    inst.AnimState:ClearOverrideSymbol("swap_shield")
    inst.AnimState:Hide("LANTERN_OVERLAY")
    inst.AnimState:ShowSymbol("swap_object")

    --Switch back to hand
    local handsItem =  inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if handsItem then
	handsItem.components.equippable.onequipfn(handsItem, inst)
    else
	inst.AnimState:Hide("ARM_carry")
	inst.AnimState:Show("ARM_normal")
    end

    --Add torch like effects back to sdf_club
    if handsItem and handsItem.prefab == "sdf_club" and handsItem.components.burnable:IsBurning() then
	inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
	if handsItem.fires == nil then
	    handsItem.fires = {}

	    local fx = SpawnPrefab("torchfire")
	    fx.entity:SetParent(inst.entity)
	    fx.entity:AddFollower()
	    fx.Follower:FollowSymbol(inst.GUID, "swap_object", 10, -200, 0)
	    fx:AttachLightTo(inst)

	    table.insert(handsItem.fires, fx)
	end
    end
end

---------------------------------------------------------------------------------------------------------------
sdf_shield_parry_idle = State({
        name = "sdf_shield_parry_idle",
        tags = { "notalking", "parrying", "nomorph" },

        onenter = function(inst, data)
            inst.sg.statemem.isshield = data ~= nil and data.isshield

            inst.components.locomotor:Stop()

            if data ~= nil and data.duration ~= nil then
                if data.duration > 0 then

		    --Skill Tree Steadfast
		    if inst.prefab == "sdf" then
			local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)

			if shield then
			    --Skill Tree Steadfast
			    if inst.components.skilltreeupdater:IsActivated("sdf_backbone_2") then
				if shield.BonusArmor then
				    shield.BonusArmor = TUNING.SDF_SKILLSET_BACKBONE_STEADFAST
				end
			    end
			end
		    end

                    inst.sg.statemem.task = inst:DoTaskInTime(data.duration, function(inst)
                        inst.sg.statemem.task = nil
                        inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
			--cancelParry(inst) --added
                        inst.sg:GoToState("idle", true)
                    end)
                else
                    inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
		    --cancelParry(inst) --added
                    inst.sg:GoToState("idle", true)
                    return
                end
            end

            if not inst.AnimState:IsCurrentAnimation("parry_loop") then
                inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_loop" or "parry_loop", true)
            end

            --Transferred over from parry_pre so it doesn't cut off abrubtly
            inst.sg.statemem.talktask = data ~= nil and data.talktask or nil

            if data ~= nil and (data.pauseframes or 0) > 0 then
                inst.sg:AddStateTag("busy")
                inst.sg:AddStateTag("pausepredict")

                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction(data.pauseframes <= 7 and data.pauseframes or nil)
                end
                inst.sg:SetTimeout(data.pauseframes * FRAMES)
            else
                inst.sg:AddStateTag("idle")
            end
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("pausepredict")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
	    EventHandler("ontalk", OnTalk_Override),
	    EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("unequip", function(inst, data)
                if not inst.sg:HasStateTag("idle") then
                    -- We need to handle this because the default unequip
                    -- handler is ignored while we are in a "busy" state.
		    --cancelParry(inst) --added

		    --local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		    --if data.item ~= nil then
		    if data.item ~= nil and data.item:IsValid() then
			inst.sg:GoToState("tool_slip", data.item)
		    else
			inst.sg:GoToState("toolbroke")
		    end
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.task ~= nil then
                inst.sg.statemem.task:Cancel()
                inst.sg.statemem.task = nil
            end
	    CancelTalk_Override(inst)
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
		cancelParry(inst) --added --maybe
            end
        end,
})
---------------------------------------------------------------------------------------------------------------
sdf_shield_parry_knockback = State({
    name = "sdf_shield_parry_knockback",
    tags = { "knockback", "busy", "nopredict", "nomorph", "nodangle", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

	    inst.AnimState:PlayAnimation("buck_pst")
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
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
		local x,_,z=inst.Transform:GetWorldPosition()
                local knockbackDust = SpawnPrefab("plant_dug_small_fx").Transform:SetPosition(x,_-0.5,z)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
		    inst.sg:RemoveStateTag("pinned")
		    inst.sg:RemoveStateTag("knockback")
		    inst.sg:RemoveStateTag("busy")
		    inst.sg:RemoveStateTag("nomorph")
		    inst.sg:RemoveStateTag("nointerrupt")
		    inst.sg:RemoveStateTag("jumping")
                    inst.sg:GoToState("idle")
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
})
------------------------------------------------------------------------------------------------------------
sdf_shield_parry_pre = State({
        name = "sdf_shield_parry_pre",
        tags = { "preparrying", "busy", "nomorph" },

	onenter = function(inst)
	    local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)

            inst.sg.statemem.isshield = inst.bufferedaction ~= nil and shield ~= nil and shield:HasTag("sdf_shield")

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pre"  or "parry_pre")
            inst.AnimState:PushAnimation(inst.sg.statemem.isshield and "shieldparry_loop" or "parry_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            --V2C: using animover results in a slight hang on last frame of parry_pre

	    --Needed Vars
	    local duration = TUNING.SDF_SHIELD_PARRY_DURATION

	    inst.sg:AddStateTag("parrying")
	    inst.sg.statemem.parrytime = duration
	    inst.sg.statemem.item = shield
	    if shield ~= nil then

		--Start Cooldown
		if shield.components.rechargeable then
		    shield.components.rechargeable:Discharge(TUNING.SDF_SHIELD_COOLDOWN)
		end

		--Parry Defense
		inst.components.combat.redirectdamagefn = function(inst, attacker, damage, weapon, stimuli)
		    return IsWeaponEquipped(inst, shield)
		    and shield.components.parryweapon ~= nil
		    and shield.components.parryweapon:TryParry(inst, attacker, damage, weapon, stimuli)
		    and shield
		    or nil
		end
	    end
            --V2C: using EventHandler will result in a frame delay, but we want this to trigger
            --     immediately during PerformBufferedAction()
           --inst:ListenForEvent("combat_parry", oncombatparry)
            inst:PerformBufferedAction()
            --inst:RemoveEventCallback("combat_parry", oncombatparry)
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil and
                    inst.sg.statemem.item.components.parryweapon ~= nil and
                    inst.sg.statemem.item:IsValid() then
                    --This is purely for stategraph animation sfx, can actually be bypassed!
                    inst.sg.statemem.item.components.parryweapon:OnPreParry(inst)
                end
            end),
        },

        events =
        {
	    EventHandler("ontalk", OnTalk_Override),
	    EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("unequip", function(inst, data)
                -- We need to handle this because the default unequip
                -- handler is ignored while we are in a "busy" state.
		--cancelParry(inst) --added
		local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		if shield then
		    inst.sg:GoToState(GetUnequipState(inst, data))
		end
            end),
        },

        ontimeout = function(inst)
            if inst.sg:HasStateTag("parrying") then
                inst.sg.statemem.parrying = true
                --Transfer talk task to parry_idle state
                local talktask = inst.sg.statemem.talktask
                inst.sg.statemem.talktask = nil
                inst.sg:GoToState("sdf_shield_parry_idle", { duration = inst.sg.statemem.parrytime, pauseframes = 30, talktask = talktask, isshield = inst.sg.statemem.isshield })
            else
                inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
		--cancelParry(inst) --added
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
	    CancelTalk_Override(inst)
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
		cancelParry(inst) --added
            end
        end,
})

sdf_shield_parry_pre_client = State({
    name = "sdf_shield_parry_pre",
    tags = { "preparrying", "busy" },
	    server_states = { "sdf_shield_parry_pre", "sdf_shield_parry_idle" },

    onenter = function(inst)
	    local shield = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
            inst.sg.statemem.isshield = inst.bufferedaction ~= nil and shield ~= nil and shield:HasTag("sdf_shield")
 
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pre"  or "parry_pre")
            inst.AnimState:PushAnimation(inst.sg.statemem.isshield and "shieldparry_loop" or "parry_pre", true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
	    if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
            inst.sg:GoToState("idle", true)
        end,
})


--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_shield_parry_idle)
AddStategraphState("wilson", sdf_shield_parry_knockback)

AddStategraphState("wilson", sdf_shield_parry_pre)
AddStategraphState("wilson_client", sdf_shield_parry_pre_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
local originalParry
local originalClientParry

local function NewDestStatePARRY(inst, action)
  inst.sg.mem.localchainattack = not action.forced or nil
  local shield = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD) or nil
  if checkHandActions(inst) and shield and shield:HasTag("sdf_shield_parry") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("sdf_daring_dash_pre") and inst.components.combat ~= nil then
    return "sdf_shield_parry_pre"
  else
    return originalParry(inst, action)
  end
end

local function NewClientDestStatePARRY(inst, action)
  local shield = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD) or nil
  if checkClientHandActions(inst) and shield and shield:HasTag("sdf_shield_parry") and not inst.sg:HasStateTag("attack") and inst.replica.combat then
    return "sdf_shield_parry_pre"
  else
    return originalClientParry(inst, action)
  end
end

AddStategraphPostInit('wilson', function(sg)
  actionhandlers = sg.actionhandlers
  for i,v in pairs(actionhandlers) do
    if v.action == ACTIONS.CASTAOE then
      originalParry = actionhandlers[i].deststate
      actionhandlers[i].deststate = NewDestStatePARRY
    end
  end
end)

AddStategraphPostInit('wilson_client', function(sg)
  actionhandlers = sg.actionhandlers
  for i,v in pairs(actionhandlers) do
    if v.action == ACTIONS.CASTAOE then
      originalClientParry = actionhandlers[i].deststate
      actionhandlers[i].deststate = NewClientDestStatePARRY
    end
  end
end)