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

sdf_longbow_shoot = State({
    name = "sdf_longbow_shoot",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

        inst.AnimState:PlayAnimation("bow_attack_old")
	inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")

	local longbowType = equip.prefab
	local longbowAmmoType = nil
	local quiverammo = equip.components.container:GetItemInSlot(1)
	if quiverammo ~= nil and quiverammo:HasTag("sdf_longbow_ammo") then
	    longbowAmmoType = quiverammo.prefab
	end

	inst:DoTaskInTime(0.3, function()
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_drawn_"..longbowAmmoType.."", "swap_"..longbowType.."_drawn")
	end)
	inst:DoTaskInTime(0.4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_empty", "swap_"..longbowType.."_empty")
	end)
	inst:DoTaskInTime(0.8, function()
	    local longbow = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if longbow and longbow:HasTag("sdf_longbow_shoot") then
		local longbowTypeReload = longbow.prefab
		local longbowAmmoTypeReload = nil
		local quiverammoReload = longbow.components.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_longbow_ammo") then
		    longbowAmmoTypeReload = quiverammoReload.prefab
		end

		if longbowAmmoTypeReload ~= nil then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowTypeReload.."_"..longbowAmmoTypeReload.."", "swap_"..longbowTypeReload.."")
		end
	    end
	end)

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

sdf_longbow_shoot_client = State({
    name = "sdf_longbow_shoot",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
	local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local cooldown = 0
        inst.replica.combat:StartAttack()
        cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("bow_attack_old")
	inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")

	local longbowType = equip.prefab
	local longbowAmmoType = nil
	local quiverammo = equip.replica.container:GetItemInSlot(1)
	if quiverammo ~= nil and quiverammo:HasTag("sdf_longbow_ammo") then
	    longbowAmmoType = quiverammo.prefab
	end

	inst:DoTaskInTime(0.3, function()
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_drawn_"..longbowAmmoType.."", "swap_"..longbowType.."_drawn")
	end)
	inst:DoTaskInTime(0.4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_empty", "swap_"..longbowType.."_empty")
	end)
	inst:DoTaskInTime(0.8, function()
	    local longbow = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if longbow and longbow:HasTag("sdf_longbow_shoot") then
		local longbowTypeReload = longbow.prefab
		local longbowAmmoTypeReload = nil
		local quiverammoReload = longbow.replica.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_longbow_ammo") then
		    longbowAmmoTypeReload = quiverammoReload.prefab
		end

		if longbowAmmoTypeReload ~= nil then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowTypeReload.."_"..longbowAmmoTypeReload.."", "swap_"..longbowTypeReload.."")
		end
	    end
	end)

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

sdf_longbow_shoot_castspell = State({
    name = "sdf_longbow_shoot_castspell",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

        inst.AnimState:PlayAnimation("bow_attack_old")
	inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")

	local longbowType = equip.prefab
	local longbowAmmoType = nil
	local quiverammo = equip.components.container:GetItemInSlot(1)
	if quiverammo ~= nil and quiverammo:HasTag("sdf_longbow_ammo") then
	    longbowAmmoType = quiverammo.prefab
	end

	inst:DoTaskInTime(0.3, function()
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_drawn_"..longbowAmmoType.."", "swap_"..longbowType.."_drawn")
	end)
	inst:DoTaskInTime(0.4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_empty", "swap_"..longbowType.."_empty")
	end)
	inst:DoTaskInTime(0.8, function()
	    local longbow = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if longbow and longbow:HasTag("sdf_longbow_shoot") then
		local longbowTypeReload = longbow.prefab
		local longbowAmmoTypeReload = nil
		local quiverammoReload = longbow.components.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_longbow_ammo") then
		    longbowAmmoTypeReload = quiverammoReload.prefab
		end

		if longbowAmmoTypeReload ~= nil then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowTypeReload.."_"..longbowAmmoTypeReload.."", "swap_"..longbowTypeReload.."")
		end
	    end
	end)

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

sdf_longbow_shoot_castspell_client = State({
    name = "sdf_longbow_shoot_castspell",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
	local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local cooldown = 0
        inst.replica.combat:StartAttack()
        cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("bow_attack_old")
	inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")

	local longbowType = equip.prefab
	local longbowAmmoType = nil
	local quiverammo = equip.replica.container:GetItemInSlot(1)
	if quiverammo ~= nil and quiverammo:HasTag("sdf_longbow_ammo") then
	    longbowAmmoType = quiverammo.prefab
	end

	inst:DoTaskInTime(0.3, function()
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_drawn_"..longbowAmmoType.."", "swap_"..longbowType.."_drawn")
	end)
	inst:DoTaskInTime(0.4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
	    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowType.."_empty", "swap_"..longbowType.."_empty")
	end)
	inst:DoTaskInTime(0.8, function()
	    local longbow = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if longbow and longbow:HasTag("sdf_longbow_shoot") then
		local longbowTypeReload = longbow.prefab
		local longbowAmmoTypeReload = nil
		local quiverammoReload = longbow.replica.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_longbow_ammo") then
		    longbowAmmoTypeReload = quiverammoReload.prefab
		end

		if longbowAmmoTypeReload ~= nil then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_"..longbowTypeReload.."_"..longbowAmmoTypeReload.."", "swap_"..longbowTypeReload.."")
		end
	    end
	end)

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
AddStategraphState("wilson", sdf_longbow_shoot)
AddStategraphState("wilson_client", sdf_longbow_shoot_client)
AddStategraphState("wilson", sdf_longbow_shoot_castspell)
AddStategraphState("wilson_client", sdf_longbow_shoot_castspell_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
local originalAttack
local originalClientAttack

local function NewDestStateATTACK(inst, action)
  inst.sg.mem.localchainattack = not action.forced or nil
  local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
  if weapon and weapon:HasTag("sdf_longbow_shoot") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and inst.components.combat ~= nil then
    return "sdf_longbow_shoot"
  else
    return originalAttack(inst, action)
  end
end

local function NewClientDestStateATTACK(inst, action)
  local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
  if weapon and weapon:HasTag("sdf_longbow_shoot") and not inst.sg:HasStateTag("attack") and inst.replica.combat then
    return "sdf_longbow_shoot"
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

AddStategraphPostInit('wilson', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTSPELL], "deststate", function(inst, action)
    if action.invobject and action.invobject:HasTag("sdf_longbow_shoot") then 
	return "sdf_longbow_shoot_castspell"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTSPELL], "deststate", function(inst, action)
    if action.invobject and action.invobject:HasTag("sdf_longbow_shoot") then 
	return "sdf_longbow_shoot_castspell"
    end 
    end)
end)