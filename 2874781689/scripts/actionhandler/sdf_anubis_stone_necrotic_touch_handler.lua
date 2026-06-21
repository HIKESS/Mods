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

sdf_anubis_stone_necrotic_touch_castaoe = State({
    name = "sdf_anubis_stone_necrotic_touch_castaoe",
    tags = { "doing", "busy", "canrotate" },
   		

        onenter = function(inst)

	    --animation
	    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_anubis_stone", "swap_sdf_anubis_stone")

	    inst:DoTaskInTime(2, function()
		local gauntletCheck = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if gauntletCheck and gauntletCheck.prefab == "sdf_anubis_stone_necrotic_touch" then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_anubis_stone_necrotic_touch", "swap_sdf_anubis_stone_necrotic_touch")
		end
	    end)

	    inst.sg:GoToState("castspell")
        end,

        timeline =
        {
        },

        events =
        {
        },

        onexit = function(inst)
        end,
})

sdf_anubis_stone_necrotic_touch_castaoe_client = State({
    name = "sdf_anubis_stone_necrotic_touch_castaoe",
    tags = { "doing", "busy", "canrotate" },
		server_states = { "castspell" },

        onenter = function(inst)
	    inst.sg:GoToState("castspell")
        end,

        onupdate = function(inst)
        end,

        ontimeout = function(inst)
        end,
})

sdf_anubis_stone_necrotic_touch_castspell = State({
    name = "sdf_anubis_stone_necrotic_touch_castspell",
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

sdf_anubis_stone_necrotic_touch_castspell_client = State({
    name = "sdf_anubis_stone_necrotic_touch_castspell",
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
AddStategraphState("wilson", sdf_anubis_stone_necrotic_touch_castaoe)
AddStategraphState("wilson_client", sdf_anubis_stone_necrotic_touch_castaoe_client)
AddStategraphState("wilson", sdf_anubis_stone_necrotic_touch_castspell)
AddStategraphState("wilson_client", sdf_anubis_stone_necrotic_touch_castspell_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------

AddStategraphPostInit('wilson', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTAOE], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_anubis_stone_necrotic_touch" then 
	return "sdf_anubis_stone_necrotic_touch_castaoe"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTAOE], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_anubis_stone_necrotic_touch" then 
	return "sdf_anubis_stone_necrotic_touch_castaoe"
    end 
    end)
end)

AddStategraphPostInit('wilson', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTSPELL], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_anubis_stone_necrotic_touch" then 
	return "sdf_anubis_stone_necrotic_touch_castspell"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTSPELL], "deststate", function(inst, action)
    if action.invobject and action.invobject.prefab == "sdf_anubis_stone_necrotic_touch" then 
	return "sdf_anubis_stone_necrotic_touch_castspell"
    end 
    end)
end)