require("stategraphs/commonstates")

local function HasMinigunEquipped(inst)
	local inv = inst.replica.inventory ~= nil and inst.replica.inventory or inst.components.inventory ~= nil and inst.components.inventory
	return inv and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("sdf_gatling_gun") and true or false
end

local function HoldsMinigun(inst)
    local inv = inst.replica.inventory ~= nil and inst.replica.inventory or inst.components.inventory ~= nil and inst.components.inventory or nil
    local handitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	
    return handitem ~= nil and handitem:HasTag("sdf_gatling_gun") and true or false
end

local function GetHeldMinigun(inst)
    local inv = inst.replica.inventory ~= nil and inst.replica.inventory or inst.components.inventory ~= nil and inst.components.inventory or nil
    local handitem = inv ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	
    if handitem ~= nil and handitem:HasTag("sdf_gatling_gun") then
	return handitem
    else
	return nil
    end
end

local function DoEquipmentFoleySounds(inst)
    local equipslots_client = inst.replica.inventory ~= nil and inst.replica.inventory:GetEquips()
    local equipslots_server = inst.components.inventory ~= nil and inst.components.inventory.equipslots
    local equipslots = equipslots_client ~= nil and equipslots_client or equipslots_server
	
    for k, v in pairs(equipslots) do
        if v.foleysound ~= nil then
            inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
        end
    end
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
    end
end

local function DoHurtSound(inst)
    if inst.hurtsoundoverride ~= nil then
	inst.SoundEmitter:PlaySound(inst.hurtsoundoverride, nil, inst.hurtsoundvolume)
    elseif not inst:HasTag("mime") then
	inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/hurt", nil, inst.hurtsoundvolume)
    end
end

local function ConfigureRunState(inst)
    if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
        inst.sg.statemem.riding = true
        inst.sg.statemem.groggy = inst:HasTag("groggy")

        local mount = inst.replica.rider:GetMount()
        inst.sg.statemem.ridingwoby = mount and mount:HasTag("woby")

    elseif inst.replica.inventory:IsHeavyLifting() then
        inst.sg.statemem.heavy = true
		inst.sg.statemem.heavy_fast = inst:HasTag("mightiness_mighty")
    elseif inst:HasTag("wereplayer") then
        inst.sg.statemem.iswere = true
        if inst:HasTag("weremoose") then
            if inst:HasTag("groggy") then
                inst.sg.statemem.moosegroggy = true
            else
                inst.sg.statemem.moose = true
            end
        elseif inst:HasTag("weregoose") then
            if inst:HasTag("groggy") then
                inst.sg.statemem.goosegroggy = true
            else
                inst.sg.statemem.goose = true
            end
        elseif inst:HasTag("groggy") then
            inst.sg.statemem.groggy = true
        else
            inst.sg.statemem.normal = true
        end
    elseif inst:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision() then
        inst.sg.statemem.sandstorm = true
    elseif inst:HasTag("groggy") then
        inst.sg.statemem.groggy = true
    elseif inst:IsCarefulWalking() then
        inst.sg.statemem.careful = true
    else
        inst.sg.statemem.normal = true
        inst.sg.statemem.normalwonkey = inst:HasTag("wonkey") or nil
    end
end

local function ReturnToCorrectFacing(inst)
    if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() or inst.components.rider and inst.components.rider:IsRiding() then
	inst.Transform:SetSixFaced()
    else
	inst.Transform:SetFourFaced()
    end
end

local sdf_gatling_gun_accepted_states = {
    sdfgatling_gun_idle = true,
    sdfgatling_gun_shoot = true,
    hit = true,
    sdf_gatling_gun_ammo_restore = true,
}

local function ShouldKeepShooting(inst)
    if inst.components.playercontroller ~= nil and
	(inst.components.playercontroller:IsAnyOfControlsPressed(GLOBAL.CONTROL_PRIMARY) or
	inst.components.playercontroller:IsAnyOfControlsPressed(GLOBAL.CONTROL_CONTROLLER_ACTION)) then
	return true
    else
	return false
    end
end

-----------------------------------------------------------------------------------------
--Gatling Gun Walking
local function SG_MinigunWalking_ServerAndClient_PostInit(sg)

    --run_start
    local _run_start_onenter = sg.states["run_start"].onenter
    sg.states["run_start"].onenter = function(inst, ...)
	if HoldsMinigun(inst) then
	    ConfigureRunState(inst)
	    if inst.sg.statemem.normalwonkey and inst.components.locomotor:GetTimeMoving() >= TUNING.WONKEY_TIME_TO_RUN then
		inst.sg:GoToState("run_monkey") --resuming after brief stop from changing directions
		return
	    end
	    inst.components.locomotor:RunForward()
	    inst.AnimState:PlayAnimation("walk_tf2minigun_pre", false)
	    --inst.AnimState:PlayAnimation("walk_sdfgatlinggun_pre", false)

	    if inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
		inst.SoundEmitter:KillSound("tf2minigun_rev_start")
	    end
			
	    --goose footsteps should always be light
	    inst.sg.mem.footsteps = (inst.sg.statemem.goose or inst.sg.statemem.goosegroggy) and 4 or 0
	else
	    _run_start_onenter(inst, ...)
	end
    end
	
    --run
    local _run_onenter = sg.states["run"].onenter
    sg.states["run"].onenter = function(inst, ...)
	if HoldsMinigun(inst) then
	    ConfigureRunState(inst)
            inst.components.locomotor:RunForward()

            if not inst.AnimState:IsCurrentAnimation("walk_tf2minigun_loop") then
                inst.AnimState:PlayAnimation("walk_tf2minigun_loop", true)
                --inst.AnimState:PlayAnimation("walk_sdfgatlinggun_loop", true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
	else
	    _run_onenter(inst, ...)
	end
    end
	
    --run_stop
    local _run_stop_onenter = sg.states["run_stop"].onenter
    sg.states["run_stop"].onenter = function(inst, ...)
	if HoldsMinigun(inst) then
	    ConfigureRunState(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("walk_tf2minigun_pst")
            --inst.AnimState:PlayAnimation("walk_sdfgatlinggun_pst")

            if inst.sg.statemem.moose or inst.sg.statemem.moosegroggy then
                PlayMooseFootstep(inst, .6, true)
                DoFoleySounds(inst)
            end
	else
	    _run_stop_onenter(inst, ...)
	end
    end
	
    local _event_animover = sg.states["run_stop"].events["animover"].fn
    sg.states["run_stop"].events["animover"].fn = function(inst, ...)
	if HoldsMinigun(inst) then
	    if inst.AnimState:AnimDone() then
		inst.sg:GoToState("sdfgatling_gun_idle", true)
	    end
	else
	    _event_animover(inst, ...)
	end
    end
end
--------------------------------------------WILSON SG ACTIONHANDLER FOR WALK OVERRIDE---------------------------------------------------------------------------
AddStategraphPostInit("wilson", SG_MinigunWalking_ServerAndClient_PostInit)
AddStategraphPostInit("wilson_client", SG_MinigunWalking_ServerAndClient_PostInit)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Gatling Gun Equip
local function SGwilson_Events_PostInit(sg)
    if sg.events["equip"] ~= nil then
	local _EventHandlerEquip = sg.events["equip"].fn
	sg.events["equip"].fn = function(inst, data)
	    if data.item == nil or not data.item:HasTag("sdf_gatling_gun") then
		_EventHandlerEquip(inst, data)
		return
	    end
			
	    if (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling")) and not inst:HasTag("wereplayer") then
		inst.sg:GoToState("sdfgatling_gun_idle")
	    end
	end
    end
end
AddStategraphPostInit("wilson", SGwilson_Events_PostInit)

local eventHandlerTF2Equip = EventHandler("sdf_gatling_gun_equip", function(inst, data)
    if not inst.components.health:IsDead() then
	inst.sg:GoToState("sdfgatling_gun_idle", false)
    end
end)
AddStategraphEvent("wilson", eventHandlerTF2Equip)

local eventHandlerTF2Idle = EventHandler("tf2heavygotoidle", function(inst, data)
    if not inst.components.health:IsDead() then
	inst.sg:GoToState("idle")
    end
end)
AddStategraphEvent("wilson", eventHandlerTF2Idle)

--Gatling Gun Unequip
local function Unequip_Minigun(inst, drop)
    if inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
	local handitem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handitem:HasTag("sdf_gatling_gun") then
	    if drop then
		inst.components.inventory:DropItem(handitem, true)
	    else
		inst.components.inventory:GiveItem(handitem)
	    end
	end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Gatling Gun Shooting
local sdfgatling_gun_idle = State{
	name = "sdfgatling_gun_idle",
	tags = { "doing", "canrotate" },

	onenter = function(inst, skip_equip_anim)
	    inst.components.locomotor:Stop()
	    inst.components.locomotor:Clear()

	    inst.sg.statemem.ignoresandstorm = true
		
	    inst.Transform:SetEightFaced()

	    local minigun = GetHeldMinigun(inst)
	    if minigun == nil then
		inst.sg:GoToState("idle")
		return
	    end

	    local minigun_assets = minigun ~= nil and minigun.components.sdf_gatling_gun_weapon_asset_wrangler or nil
		
	    if inst.components.rider:IsRiding() then
		inst.sg:GoToState("mounted_idle")
		return
	    end

	    if minigun_assets ~= nil then
		if inst.sg.laststate == nil or inst.sg.laststate.name ~= "sdfgatling_gun_shoot" then

		    inst.AnimState:PlayAnimation(minigun_assets:GetRevvedAnim(), false)
		    local len = inst.AnimState:GetCurrentAnimationLength()
		    inst.AnimState:SetTime(len)
		else
		    inst.AnimState:PlayAnimation(minigun_assets:GetRevvedAnim(), false)

		    --Stop Rev Start Sound
		    if inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
			inst.SoundEmitter:KillSound("tf2minigun_rev_start")
		    end

		    --Play Rev End Sound
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_rev_end") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetRevEndSound(), "tf2minigun_rev_end")
		    end
		end
	    end
		
	    if inst:HasTag("sdf_gatling_gun_shooting") then
		inst:RemoveTag("sdf_gatling_gun_shooting")
	    end
	end,
	
	timeline =
	{
	    TimeEvent(6 * FRAMES, function(inst)
		--Stop Rev End Sound
		if inst.SoundEmitter:PlayingSound("tf2minigun_rev_end") then --test
		    inst.SoundEmitter:KillSound("tf2minigun_rev_end")
		end
			
		local minigun = GetHeldMinigun(inst)
		local minigun_assets = minigun ~= nil and minigun.components.sdf_gatling_gun_weapon_asset_wrangler or nil
			
		local was_shooting = inst.sg.laststate ~= nil and inst.sg.laststate.name ~= nil and inst.sg.laststate.name == "sdfgatling_gun_shoot"
		local was_hit = inst.sg.laststate ~= nil and inst.sg.laststate.name ~= nil and inst.sg.laststate.name == "hit"
			
		if minigun ~= nil and not was_shooting and not was_hit then
		    minigun:PushEvent("revved_up", {weapon = minigun, shooter = inst, no_interrupt = false}) -- handled in sdf_gatling_gun_weapon.lua
		elseif minigun ~= nil and not was_shooting and was_hit then
		    minigun:PushEvent("revved_up", {weapon = minigun, shooter = inst, no_interrupt = true})
		end
	    end),
	},

	events =
	{
	    EventHandler("unequip", function(inst, data)
		if data ~= nil and data.item ~= nil and data.item:HasTag("sdf_gatling_gun") then
		    if not inst.components.locomotor:WantsToMoveForward() then
			--Stop Rev Start Sound
			if inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
			    inst.SoundEmitter:KillSound("tf2minigun_rev_start")
			end
		    end
			
		    ReturnToCorrectFacing(inst)

		    inst.sg:GoToState("idle")
		end
	    end),
	},

	-- NOTE: This actually does not always get executed on exiting the state (e.g. not executed when unequipping the gun)
	onexit = function(inst)
	    local buffaction = inst:GetBufferedAction()
	    local wants_to_shoot = buffaction ~= nil and buffaction.action ~= nil and buffaction.action == ACTIONS.SDFGATLING_GUN_SHOOT and true or false
	    local is_being_attacked = inst.components.combat ~= nil and inst.components.combat:GetLastAttackedTime() == GLOBAL.GetTime()
	
	    local minigun = GetHeldMinigun(inst)
	    if minigun ~= nil and not wants_to_shoot and not is_being_attacked then
		minigun:PushEvent("revved_down", {weapon = minigun, shooter = inst}) -- handled in sdf_gatling_gun_weapon.lua
	    end
	
	    ReturnToCorrectFacing(inst)
	    --inst.SoundEmitter:KillSound("tf2minigun_revved")
	end
}

local sdfgatling_gun_idle_client = State{
	name = "sdfgatling_gun_idle",
	tags = { "doing", "canrotate" },

	onenter = function(inst, skip_equip_anim)
	    inst.components.locomotor:Stop()
	    inst.components.locomotor:Clear()
		
	    inst.Transform:SetEightFaced()

	    local minigun = GetHeldMinigun(inst)
	    if minigun == nil then
		inst.sg:GoToState("idle")
	    end
	    local minigun_assets = minigun.components.sdf_gatling_gun_weapon_asset_wrangler
		
	    if inst.sg.laststate == nil or inst.sg.laststate.name ~= "sdfgatling_gun_shoot" then

		inst.AnimState:PlayAnimation(minigun_assets:GetRevvedAnim(), false)
		local len = inst.AnimState:GetCurrentAnimationLength()
		inst.AnimState:SetTime(len)
			
	    else
		inst.AnimState:PlayAnimation(minigun_assets:GetRevvedAnim(), false)

		--Stop Rev Start Sound
		if inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
		    inst.SoundEmitter:KillSound("tf2minigun_rev_start")
		end

		--Play Rev End Sound
		if not inst.SoundEmitter:PlayingSound("tf2minigun_rev_end") then
		    inst.SoundEmitter:PlaySound(minigun_assets:GetRevEndSound(), "tf2minigun_rev_end")
		end
	    end

	    inst.entity:SetIsPredictingMovement(false)

	    if inst:HasTag("sdf_gatling_gun_shooting") then
		inst:RemoveTag("sdf_gatling_gun_shooting")
	    end
	end,

	ontimeout = function(inst)
	    ReturnToCorrectFacing(inst)
	    --inst.SoundEmitter:KillSound("tf2minigun_revved")
	    inst.entity:SetIsPredictingMovement(true)
	end,

	onexit = function(inst)
	    ReturnToCorrectFacing(inst)
	    --inst.SoundEmitter:KillSound("tf2minigun_revved")
	    inst.entity:SetIsPredictingMovement(true)
	end
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
local sdfgatling_gun_shoot = State{
	name = "sdfgatling_gun_shoot",
	tags = { "doing", "busy", "canrotate" },

	onenter = function(inst, data)
	    inst.components.locomotor:Stop()
	    inst.components.locomotor:Clear()
		
	    inst.sg.statemem.action = inst:GetBufferedAction()
		
	    inst.Transform:SetEightFaced()
		
	    local buffaction = inst:GetBufferedAction()
	    local target = buffaction ~= nil and buffaction.target or nil
	    local pos = buffaction ~= nil and buffaction.pos or nil
		
	    if target ~= nil and target:IsValid() then
		inst:ForceFacePoint(target.Transform:GetWorldPosition())
	    elseif pos ~= nil then
		inst:ForceFacePoint(buffaction:GetActionPoint():Get())
	    end

	    inst.sg.statemem.ignoresandstorm = true

	    local holds_minigun = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("sdf_gatling_gun") or false
	    if holds_minigun then
		local minigun = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local minigun_assets = minigun.components.sdf_gatling_gun_weapon_asset_wrangler
			
		if minigun.components.sdf_gatling_gun_weapon and minigun.components.sdf_gatling_gun_weapon:IsEmpty() then

		    --Shoot start up
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetRevStartSound(), "tf2minigun_rev_start")
		    end

		    --Shoot Empty Sound
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_empty") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetShootingEmptySound(), "tf2minigun_shoot")
		    end
		    inst.AnimState:PlayAnimation(minigun_assets:GetShootingEmptyAnim(), false)
		elseif minigun.components.sdf_gatling_gun_weapon and minigun.components.sdf_gatling_gun_weapon:GetGatlingGunAmmo() == nil then

		    --Shoot start up
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetRevStartSound(), "tf2minigun_rev_start")
		    end

		    --Shoot Empty Sound
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_empty") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetShootingEmptySound(), "tf2minigun_shoot")
		    end
		    inst.AnimState:PlayAnimation(minigun_assets:GetShootingEmptyAnim(), false)
		else
		    --Shoot start up
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetRevStartSound(), "tf2minigun_rev_start")
		    end

		    --Shoot Empty Sound
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_shoot") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetShootingSound(), "tf2minigun_shoot")
		    end
		    inst.AnimState:PlayAnimation(minigun_assets:GetShootingAnim(), false)
		end
		if not inst:HasTag("sdf_gatling_gun_shooting") then
		    inst:AddTag("sdf_gatling_gun_shooting")
		end
	    else
		--Gatling Gun Durability Breaks
		if inst:HasTag("sdf_gatling_gun_shooting") then
		    inst:RemoveTag("sdf_gatling_gun_shooting")
		end
		inst.sg:GoToState("idle")
	    end
	end,

	timeline =
	{
	    TimeEvent(3 * FRAMES, function(inst)
		local minigun = GetHeldMinigun(inst)
		local was_minigun_idle = inst.sg.laststate ~= nil and inst.sg.laststate.name ~= nil and inst.sg.laststate.name == "sdfgatling_gun_idle"
		local was_shooting = inst.sg.laststate ~= nil and inst.sg.laststate.name ~= nil and inst.sg.laststate.name == "sdfgatling_gun_shoot"
		local was_hit = inst.sg.laststate ~= nil and inst.sg.laststate.name ~= nil and inst.sg.laststate.name == "hit"
			
		if minigun ~= nil and not was_minigun_idle and not was_shooting and not was_hit then
		    minigun:PushEvent("revved_up", {weapon = minigun, shooter = inst, no_interrupt = false}) -- handled in sdf_gatling_gun_weapon.lua
		elseif minigun ~= nil and not was_minigun_idle and not was_shooting and was_hit then
		    minigun:PushEvent("revved_up", {weapon = minigun, shooter = inst, no_interrupt = true})
		end
	    end),
	
	    TimeEvent(4 * FRAMES, function(inst)
		local buffaction = inst:GetBufferedAction()
		local buffaction_pos = nil
		local buffaction_target = nil
			
		if buffaction then
		    buffaction_pos = buffaction:GetActionPoint() 
		    buffaction_target = buffaction.target
		    inst:PerformBufferedAction()
		end
			
		if ShouldKeepShooting(inst) and (inst.sg.statemem.action ~= nil or buffaction_pos ~= nil or buffaction_target ~= nil) then
		    local minigun = inst.replica ~= nil and inst.replica.inventory ~= nil
			and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil
			and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("sdf_gatling_gun")
			and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			or inst.components.inventory ~= nil
			and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil
			and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("sdf_gatling_gun")
			and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
				
		    local input_pos = nil
		    local statemem_action = inst.sg.statemem ~= nil and inst.sg.statemem.action ~= nil and inst.sg.statemem.action or nil
				
		    if statemem_action ~= nil and statemem_action.target == nil then
			input_pos = statemem_action:GetActionPoint()
		    elseif statemem_action ~= nil and statemem_action.target ~= nil and statemem_action.target.Transform ~= nil then
			input_pos = GLOBAL.Vector3(statemem_action.target.Transform:GetWorldPosition())
		    elseif buffaction_pos ~= nil then
			input_pos = input_pos
		    elseif buffaction_target ~= nil and buffaction_target.Transform ~= nil then
			input_pos = GLOBAL.Vector3(buffaction_target.Transform:GetWorldPosition())
		    end
				
		    if input_pos == nil then
			inst.sg:GoToState("sdfgatling_gun_idle")
			return
		    end
				
		    local using_mouse = inst.components.playercontroller ~= nil and inst.components.playercontroller:UsingMouse()		
		    if using_mouse then
			local left_click_action = nil
					
			if inst.components.playercontroller ~= nil then
			    left_click_action = inst.components.playercontroller:GetLeftMouseAction()
			end
					
			--Aiming override for the host (no caves enabled)
			if left_click_action ~= nil and inst.sdf_gatling_gun_cached_aiming_point == nil then
			    if left_click_action.target ~= nil and left_click_action.target.Transform ~= nil then
				local left_click_target_pos = GLOBAL.Vector3(left_click_action.target.Transform:GetWorldPosition())
				if left_click_target_pos ~= nil and left_click_target_pos.x ~= nil then
				    input_pos = left_click_target_pos
				    inst:ForceFacePoint(left_click_target_pos.x, left_click_target_pos.y, left_click_target_pos.z)
				end
			    else
				local action_point = left_click_action:GetActionPoint()
				if action_point ~= nil and action_point.x ~= nil then
				    input_pos = action_point
				    inst:ForceFacePoint(action_point.x, action_point.y, action_point.z)
				end
			    end
						
			--Aiming override for clients
			elseif inst.sdf_gatling_gun_cached_aiming_point ~= nil then
			    input_pos = inst.sdf_gatling_gun_cached_aiming_point
			    inst.sdf_gatling_gun_cached_aiming_point = nil
			    inst:ForceFacePoint(input_pos.x, input_pos.y, input_pos.z)
			end
		    end
				
		    local can_shoot = inst:GetDistanceSqToPoint(input_pos.x, input_pos.y, input_pos.z) >= 1.25 and using_mouse

		    if (minigun and can_shoot) or (minigun and not using_mouse) then
			inst:ClearBufferedAction()
			local new_action = GLOBAL.BufferedAction(inst, nil, ACTIONS.SDFGATLING_GUN_SHOOT, minigun, input_pos)
			inst:PushBufferedAction(new_action)
		    else
			inst.sg:GoToState("sdfgatling_gun_idle")
		    end
		end
	    end),
		
	    TimeEvent(5 * FRAMES, function(inst)
		inst.sg:RemoveStateTag("busy")
	    end),
	},
	
	events =
	{
	    EventHandler("animover", function(inst, data)
		if inst.AnimState:AnimDone() then --and not ShouldKeepShooting(inst)
		    inst.sg:GoToState("sdfgatling_gun_idle")
		end
	    end),
		
	    EventHandler("unequip", function(inst, data)
		inst.sg:GoToState("idle")
	    end),
		
	    EventHandler("newstate", function(inst, data)
		if data and data.statename and not sdf_gatling_gun_accepted_states[data.statename] then
		    Unequip_Minigun(inst, false)
		end
	    end),
	},

	onexit = function(inst)
	    ReturnToCorrectFacing(inst)
	    inst.SoundEmitter:KillSound("tf2minigun_shoot")
		
	    local is_being_attacked = inst.components.combat ~= nil and inst.components.combat:GetLastAttackedTime() == GLOBAL.GetTime()
	    local wants_to_move_forward = inst.components.locomotor ~= nil and inst.components.locomotor:WantsToMoveForward() and true or false
	
	    local minigun = GetHeldMinigun(inst)
	    if minigun ~= nil and not is_being_attacked and wants_to_move_forward then
		minigun:PushEvent("revved_down", {weapon = minigun, shooter = inst}) -- handled in sdf_gatling_gun_weapon.lua
	    end
	end
}

local sdfgatling_gun_shoot_client = State{
	name = "sdfgatling_gun_shoot",
	tags = { "doing", "canrotate" }, -- "busy", <-- This tag on client was a baaad idea...

	onenter = function(inst, data)
	    inst.components.locomotor:Stop()
	    inst.entity:SetIsPredictingMovement(false)
		
	    inst.Transform:SetEightFaced()
		
	    local minigun = GetHeldMinigun(inst)
	    if minigun == nil then
		inst.sg:GoToState("idle")
	    end
	    local minigun_assets = minigun.components.sdf_gatling_gun_weapon_asset_wrangler
		
	    if not inst:HasTag("sdf_gatling_gun_shooting") then
		inst:AddTag("sdf_gatling_gun_shooting")
	    end
		
	    --Sound here is not needed, handled on Server.
	    --[[local inv = inst.replica.inventory ~= nil and inst.replica.inventory
	    if inv and inv:GetEquippedItem(EQUIPSLOTS.HANDS) and inv:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("sdf_gatling_gun") then
		local minigun = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
		if minigun:HasTag("sdf_gatling_gun_empty") then
		    --Shoot start up
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetRevStartSound(), "tf2minigun_rev_start")
		    end

		    --Shoot Empty Sound
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_empty") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetShootingEmptySound(), "tf2minigun_shoot")
		    end
		else
		    --Shoot start up
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetRevStartSound(), "tf2minigun_rev_start")
		    end

		    --Shoot Sound
		    if not inst.SoundEmitter:PlayingSound("tf2minigun_shoot") then
			inst.SoundEmitter:PlaySound(minigun_assets:GetShootingSound(), "tf2minigun_shoot")
		    end
		end
	    end]]

	    local buffaction = inst:GetBufferedAction()
	    if buffaction ~= nil and buffaction.pos ~= nil then
		inst:ForceFacePoint(buffaction:GetActionPoint():Get())
	    end
	end,
	
	timeline =
	{
	    TimeEvent(4 * FRAMES, function(inst)
		if inst.minigun_aim_task_client == nil then
		    inst.minigun_aim_task_client = inst:DoPeriodicTask(.1, function(inst)
			if inst == nil or inst.components == nil or inst.components.sdf_gatling_gun_weapon_aiming_helper == nil or inst.components.sdf_gatling_gun_weapon_aiming_helper.vector3_point == nil then
			    return
			end
			local vector3_point = inst.components.sdf_gatling_gun_weapon_aiming_helper.vector3_point
			if vector3_point ~= nil and vector3_point.x ~= nil then
			    inst:ForceFacePoint(vector3_point.x, vector3_point.y, vector3_point.z)
			end
		    end)
		end
			
		inst:PerformPreviewBufferedAction()
	    end),
	},
	
	ontimeout = function(inst)
	    ReturnToCorrectFacing(inst)
	    inst.SoundEmitter:KillSound("tf2minigun_shoot")
	    inst.entity:SetIsPredictingMovement(true)
	end,

	onexit = function(inst)
	    if inst.minigun_aim_task_client ~= nil then
		inst.minigun_aim_task_client:Cancel()
		inst.minigun_aim_task_client = nil
	    end
	
	    ReturnToCorrectFacing(inst)
	    inst.SoundEmitter:KillSound("tf2minigun_shoot")
	    inst.entity:SetIsPredictingMovement(true)
	end
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
local sdfgatling_gun_unequip = State{
	name = "sdfgatling_gun_item_in",
	tags = { "idle", "nodangle" },

	onenter = function(inst)
	    inst.components.locomotor:StopMoving()

	    if inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
		inst.SoundEmitter:KillSound("tf2minigun_rev_start")
	    end
		
	    local buffaction = inst:GetBufferedAction()
	    if buffaction then
		inst:PerformBufferedAction()
	    end
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
	    if inst.sg.statemem.followfx ~= nil then
		for i, v in ipairs(inst.sg.statemem.followfx) do
		    v:Remove()
		end
	    end
	end,
}

local sdfgatling_gun_unequip_client = State{
	name = "sdfgatling_gun_item_in",
	tags = { "doing", "busy" },

	onenter = function(inst)
	    inst.components.locomotor:StopMoving()

	    if inst.SoundEmitter:PlayingSound("tf2minigun_rev_start") then
		inst.SoundEmitter:KillSound("tf2minigun_rev_start")
	    end
		
	    inst:PerformPreviewBufferedAction()
	    inst.sg:SetTimeout(1)
	end,

	timeline =
	{
	    TimeEvent(4 * FRAMES, function(inst)
		inst.sg:RemoveStateTag("busy")
	    end),
	},

	onupdate = function(inst)
	    if inst:HasTag("doing") then
		if inst.entity:FlattenMovementPrediction() then
		    inst.sg:GoToState("idle", "noanim")
		end
	    elseif inst.bufferedaction == nil then
		    inst.sg:GoToState("idle", true)
	    end
	end,

	ontimeout = function(inst)
	    inst:ClearBufferedAction()
	    inst.sg:GoToState("idle", true)
	end,
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
AddStategraphPostInit("wilson", function(self)

    local hit_onenter = self.states.hit.onenter
    self.states.hit.onenter = function(inst, ...)
	if HasMinigunEquipped(inst) and inst.sg.laststate ~= nil and
	    (inst.sg.laststate.name == "sdfgatling_gun_shoot" or 
	    inst.sg.laststate.name == "sdfgatling_gun_idle") then
				
	    DoHurtSound(inst)
				
	    if inst.sg.laststate.name == "sdfgatling_gun_shoot" then
		inst.sg:GoToState("sdfgatling_gun_shoot")
	    else
		inst.sg:GoToState("sdfgatling_gun_idle", true)
	    end
				
	    return
	else 
	    return hit_onenter(inst, ...) 
	end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SG_SDFGatling_Gun_Server_PostInit(sg)
    sg.states["sdfgatling_gun_idle"] = sdfgatling_gun_idle
    sg.states["sdfgatling_gun_shoot"] = sdfgatling_gun_shoot
    sg.states["sdfgatling_gun_item_in"] = sdfgatling_gun_unequip
end

local function SG_SDFGatling_Gun_Client_PostInit(sg)
    sg.states["sdfgatling_gun_idle"] = sdfgatling_gun_idle_client
    sg.states["sdfgatling_gun_shoot"] = sdfgatling_gun_shoot_client
    sg.states["sdfgatling_gun_item_in"] = sdfgatling_gun_unequip_client
end

AddStategraphState("SGwilson", sdfgatling_gun_idle)
AddStategraphState("SGwilson", sdfgatling_gun_shoot)
AddStategraphState("SGwilson", sdfgatling_gun_unequip)
AddStategraphPostInit("wilson", SG_SDFGatling_Gun_Server_PostInit)

AddStategraphState("SGwilson_client", sdfgatling_gun_idle_client)
AddStategraphState("SGwilson_client", sdfgatling_gun_shoot_client)
AddStategraphState("SGwilson_client", sdfgatling_gun_unequip_client)
AddStategraphPostInit("wilson_client", SG_SDFGatling_Gun_Client_PostInit)