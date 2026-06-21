local unpack = unpack or table.unpack or GLOBAL.unpack
local Vector3 = GLOBAL.Vector3
local DEGREES = GLOBAL.DEGREES

local function results(data, ...)
    return type(data) == "function" and {data(...)}  
	or type(data) == "table" and data 
	or {data} 
end 

local function sandwich(func, ante, post)	
    return function(...)
	local results_ante = results(ante, ...)
	if #results_ante > 0 then
	    return unpack(results_ante)
	end 		
		
	local results_original = results(func, ...)
	local results_post = results(post, ...)

	if #results_post > 0 then
	    return unpack(results_post)
	end 
		
	return unpack(results_original)
    end 
end 

local function overwrite(tabula, name, ante, post, ifnil)
    if type(tabula) ~= "table" then
	return
    end 
    local old = tabula[name]
    if old == nil and ifnil ~= nil then
	old = ifnil
    end 
    tabula[name] = sandwich(old, ante, post)
end 

sdf_lightning_gauntlet_castaoe = State({
    name = "sdf_lightning_gauntlet_castaoe",
    tags = { "doing", "busy", "canrotate" },
   		

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_pre")

            --Spawn an effect on the player's location
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	    if staff ~= nil and staff.components.aoetargeting ~= nil then

		--animation
		inst.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_charged", "swap_sdf_lightning_gauntlet_charged")

		inst:DoTaskInTime(0.7, function()
		    local gauntletCheck = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		    if gauntletCheck and gauntletCheck.prefab == "sdf_lightning_gauntlet" and (gauntletCheck.ModeState == "LIGHTNING" or gauntletCheck.ModeState == "GOODLIGHTNING") then
			inst.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_transfer", "swap_sdf_lightning_gauntlet_transfer")
		    end
		end)

		--action
                local buffaction = inst:GetBufferedAction()
		if buffaction ~= nil then
		    inst.sg.statemem.targetfx = staff.components.aoetargeting:SpawnTargetFXAt(buffaction:GetDynamicActionPoint())
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end

	    --inst.SoundEmitter:PlaySound((staff ~= nil and staff.castsound) or "dontstarve_DLC001/creatures/lightninggoat/shocked_electric")

        end,

        timeline =
        {

            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_electric")
            end),

            TimeEvent(6 * FRAMES, function(inst) --5
                inst:PerformBufferedAction()
            end),

	    TimeEvent(16 * FRAMES, function(inst)
		inst.sg:RemoveStateTag("busy")
	    end),

            TimeEvent(53 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        OnRemoveCleanupTargetFX(inst)
                    end
                    inst.sg.statemem.targetfx = nil
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
})

sdf_lightning_gauntlet_castaoe_client = State({
    name = "sdf_lightning_gauntlet_castaoe",
    tags = { "doing", "busy", "canrotate" },
		server_states = { "castspell" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            --inst.AnimState:PlayAnimation("staff_pre")
            --inst.AnimState:PushAnimation("staff_lag", false)

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


sdf_lightning_gauntlet_zap = State({
    name = "sdf_lightning_gauntlet_zap",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

	inst.AnimState:PlayAnimation("punch")

	local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if staff ~= nil then

	    --animation
	    inst.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_charged", "swap_sdf_lightning_gauntlet_charged")

	    inst:DoTaskInTime(0.9, function()
		local gauntletCheck = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if gauntletCheck and gauntletCheck.prefab == "sdf_lightning_gauntlet" and (gauntletCheck.ModeState == "LIGHTNING" or gauntletCheck.ModeState == "GOODLIGHTNING") then
		    inst.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_transfer", "swap_sdf_lightning_gauntlet_transfer")
		end
	    end)
	end

        cooldown = math.max(cooldown, 15 * FRAMES) --15
        
	inst.sg:SetTimeout(cooldown)

        if inst.components.combat.target then
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end
    end,
    
    timeline=
    {
	TimeEvent(8*FRAMES, function(inst) --6
	    inst:PerformBufferedAction()
	    inst.sg:RemoveStateTag("abouttoattack")
        end),

	TimeEvent(10*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end), --maybe fix, below is needed more?
    },
    
    ontimeout = function(inst)
	inst.sg:RemoveStateTag("attack")
	inst.sg:AddStateTag("idle")
    end,

    events=
    {
        EventHandler("animqueueover", function(inst)
	    if inst.AnimState:AnimDone() then
		inst.sg:GoToState("idle")
	    end
        end),
    },

    onexit = function(inst)
	inst.components.combat:SetTarget(nil)
	if inst.sg:HasStateTag("abouttoattack") then
	    inst.components.combat:CancelAttack()
	end
    end,
})

sdf_lightning_gauntlet_zap_client = State({
    name = "sdf_lightning_gauntlet_zap",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
	local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local cooldown = 0
        inst.replica.combat:StartAttack()
        cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
        inst.components.locomotor:Stop()

	inst.AnimState:PlayAnimation("punch")

	if cooldown > 0 then
	    cooldown = math.max(cooldown, 15 * FRAMES) --15
	end

        local buffaction = inst:GetBufferedAction()
        if buffaction ~= nil then
            inst:PerformPreviewBufferedAction()
            if buffaction.target ~= nil and buffaction.target:IsValid() then
                inst:FacePoint(buffaction.target:GetPosition())
                inst.sg.statemem.attacktarget = buffaction.target
            end
        end

	if cooldown > 0 then
	    inst.sg:SetTimeout(cooldown)
	end
        
    end,
    
    timeline=
    {
       
        TimeEvent(7*FRAMES, function(inst) --6
	    inst:ClearBufferedAction()
            inst.sg:RemoveStateTag("abouttoattack")
        end),
	--TimeEvent(9*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end), --maybe fix?
    },
    
    ontimeout = function(inst)
	inst.sg:RemoveStateTag("attack")
	inst.sg:AddStateTag("idle")
    end,

    events=
    {
	EventHandler("animqueueover", function(inst)
	    if inst.AnimState:AnimDone() then
		inst.sg:GoToState("idle")
	    end
	end),
    },

    onexit = function(inst)
	if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
	    inst.replica.combat:CancelAttack()
	end
    end,
})
--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_lightning_gauntlet_castaoe)
AddStategraphState("wilson_client", sdf_lightning_gauntlet_castaoe_client)
AddStategraphState("wilson", sdf_lightning_gauntlet_zap)
AddStategraphState("wilson_client", sdf_lightning_gauntlet_zap_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------

AddStategraphPostInit('wilson', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTAOE], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_lightning_gauntlet" then 
	return "sdf_lightning_gauntlet_castaoe"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTAOE], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_lightning_gauntlet" then 
	return "sdf_lightning_gauntlet_castaoe"
    end 
    end)
end)


local originalAttack
local originalClientAttack

local function NewDestStateATTACK(inst, action)
  inst.sg.mem.localchainattack = not action.forced or nil
  local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
  if weapon and weapon:HasTag("sdf_lightning_gauntlet_zap") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and inst.components.combat ~= nil or
     weapon and weapon:HasTag("sdf_lightning_gauntlet_mend") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and inst.components.combat ~= nil then
    return "sdf_lightning_gauntlet_zap"
  else
    return originalAttack(inst, action)
  end
end

local function NewClientDestStateATTACK(inst, action)
  local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
  if weapon and weapon:HasTag("sdf_lightning_gauntlet_zap") and not inst.sg:HasStateTag("attack") and inst.replica.combat or
     weapon and weapon:HasTag("sdf_lightning_gauntlet_mend") and not inst.sg:HasStateTag("attack") and inst.replica.combat then
    return "sdf_lightning_gauntlet_zap"
  else
    return originalClientAttack(inst, action)
  end
end

AddStategraphPostInit('wilson', function(sg)
  actionhandlers = sg.actionhandlers
  for i,v in pairs(actionhandlers) do
    if v.action == ACTIONS.ATTACK then
      originalAttack = actionhandlers[i].deststate
      actionhandlers[i].deststate = NewDestStateATTACK
    end
  end
end)

AddStategraphPostInit('wilson_client', function(sg)
  actionhandlers = sg.actionhandlers
  for i,v in pairs(actionhandlers) do
    if v.action == ACTIONS.ATTACK then
      originalClientAttack = actionhandlers[i].deststate
      actionhandlers[i].deststate = NewClientDestStateATTACK
    end
  end
end)