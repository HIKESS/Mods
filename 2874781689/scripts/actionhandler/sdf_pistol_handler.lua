local unpack = unpack or table.unpack or GLOBAL.unpack
local FRAMES = GLOBAL.FRAMES
local TimeEvent = GLOBAL.TimeEvent
local EventHandler = GLOBAL.EventHandler
local State = GLOBAL.State
local SpawnPrefab = GLOBAL.SpawnPrefab
local Vector3 = GLOBAL.Vector3
local DEGREES = GLOBAL.DEGREES
local PI = GLOBAL.PI

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

local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

sdf_pistol_knockback = State({
    name = "sdf_pistol_knockback",
    tags = { "knockback", "busy", "nopredict", "nomorph", "nodangle", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

	    --inst.AnimState:PlayAnimation("buck_pst")
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
	    --FrameEvent(10, function(inst)
		--inst.sg:RemoveStateTag("nointerrupt")
		--inst.sg:RemoveStateTag("jumping")
	    --end),
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

sdf_pistol_shoot = State({
    name = "sdf_pistol_shoot",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

        inst.AnimState:PlayAnimation("speargun")

        cooldown = math.max(cooldown, 12 * FRAMES)

        if inst.components.combat.target then
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end
    end,
    
    timeline=
    {
       
        TimeEvent(12*FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            --inst.components.combat:DoAttack()
	    inst:PerformBufferedAction()

	    --inst.SoundEmitter:PlaySound("meta5/walter/ammo_gunpowder_shoot")

            if inst.components.combat:GetWeapon() and inst.components.combat:GetWeapon():HasTag("sdf_pistol") and inst.components.combat.target ~= nil then
                local cloud = SpawnPrefab("sdf_blunderbuss_fx")
		cloud.AnimState:SetScale(0.5, 0.5, 0.5)
                local pt = Vector3(inst.Transform:GetWorldPosition())

                local angle = (inst:GetAngleToPoint(inst.components.combat.target.Transform:GetWorldPosition()) -90)*DEGREES

                local DIST = 1.5
                local offset = Vector3(DIST * math.cos( angle+(PI/2) ), 0, -DIST * math.sin( angle+(PI/2) ))

                cloud.Transform:SetPosition(pt.x+offset.x,1.5,pt.z+offset.z)
            end

	    inst.sg:GoToState("sdf_pistol_knockback")
        end),
        TimeEvent(20*FRAMES, function(inst)
	    inst.sg:RemoveStateTag("attack")
	end),
    },

    events=
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
	inst.components.combat:SetTarget(nil)
	if inst.sg:HasStateTag("abouttoattack") then
	    inst.components.combat:CancelAttack()
	end
    end,
})

sdf_pistol_shoot_client = State({
    name = "sdf_pistol_shoot",
    tags = {"busy", "nointerrupt", "attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
        local cooldown = 0
        inst.replica.combat:StartAttack()
        cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("speargun")

        local buffaction = inst:GetBufferedAction()
        if buffaction ~= nil then
            inst:PerformPreviewBufferedAction()
            if buffaction.target ~= nil and buffaction.target:IsValid() then
                inst:FacePoint(buffaction.target:GetPosition())
                inst.sg.statemem.attacktarget = buffaction.target
            end
        end
        if cooldown > 0 then
            cooldown = math.max(cooldown, 12 * FRAMES)
        end
        
    end,
    
    timeline=
    {
       
        TimeEvent(12*FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")

        end),
        TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
    },
    
    events=
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
	if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
	    inst.replica.combat:CancelAttack()
	end
    end,
})

sdf_pistol_shoot_castspell = State({
    name = "sdf_pistol_shoot_castspell",
    tags = {"attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES

        inst.AnimState:PlayAnimation("speargun")
	inst:DoTaskInTime(0.4, function()
	    inst.AnimState:PlayAnimation("speargun")
	end)
	inst:DoTaskInTime(0.6, function()
	    inst.AnimState:PlayAnimation("speargun")
	end)

	inst:DoTaskInTime(0.3, function()
	    local pistol = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	    end
	end)
	inst:DoTaskInTime(0.4, function()
	    local pistol = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		local quiverammoReload = pistol.components.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_pistol_ammo") then
		    inst.SoundEmitter:PlaySound("meta5/walter/ammo_gunpowder_shoot")
		    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
		end
	    end
	end)

	inst:DoTaskInTime(0.5, function()
	    local pistol = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	    end
	end)
	inst:DoTaskInTime(0.6, function()
	    local pistol = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		local quiverammoReload = pistol.components.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_pistol_ammo") then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
		end
	    end
	end)

	inst:DoTaskInTime(0.7, function()
	    local pistol = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	    end
	end)
	inst:DoTaskInTime(0.8, function()
	    local pistol = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		local quiverammoReload = pistol.components.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_pistol_ammo") then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
		end
	    end
	end)

        cooldown = math.max(cooldown, 12 * FRAMES)

        if inst.components.combat.target then
            if inst.components.combat.target and inst.components.combat.target:IsValid() then
                inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
            end
        end
    end,
    
    timeline=
    {
       
        TimeEvent(12*FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            --inst.components.combat:DoAttack()
	    inst:PerformBufferedAction()

	    --inst.SoundEmitter:PlaySound("meta5/walter/ammo_gunpowder_shoot")

            if inst.components.combat:GetWeapon() and inst.components.combat:GetWeapon():HasTag("sdf_pistol") and inst.components.combat.target ~= nil then
                local cloud = SpawnPrefab("sdf_blunderbuss_fx")
		cloud.AnimState:SetScale(0.5, 0.5, 0.5)
                local pt = Vector3(inst.Transform:GetWorldPosition())

                local angle = (inst:GetAngleToPoint(inst.components.combat.target.Transform:GetWorldPosition()) -90)*DEGREES

                local DIST = 1.5
                local offset = Vector3(DIST * math.cos( angle+(PI/2) ), 0, -DIST * math.sin( angle+(PI/2) ))

                cloud.Transform:SetPosition(pt.x+offset.x,1.5,pt.z+offset.z)
            end

	    inst.sg:GoToState("sdf_pistol_knockback")
        end),
        TimeEvent(20*FRAMES, function(inst)
	    inst.sg:RemoveStateTag("attack")
	end),
    },

    events=
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
	inst.components.combat:SetTarget(nil)
	if inst.sg:HasStateTag("abouttoattack") then
	    inst.components.combat:CancelAttack()
	end
    end,
})

sdf_pistol_shoot_castspell_client = State({
    name = "sdf_pistol_shoot_castspell",
    tags = {"busy", "nointerrupt", "attack", "notalking", "abouttoattack"},
    
    onenter = function(inst)
	local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local cooldown = 0
        inst.replica.combat:StartAttack()
        cooldown = inst.replica.combat:MinAttackPeriod() + .5 * FRAMES
        inst.components.locomotor:Stop()

        inst.AnimState:PlayAnimation("speargun")
	inst:DoTaskInTime(0.4, function()
	    inst.AnimState:PlayAnimation("speargun")
	end)
	inst:DoTaskInTime(0.6, function()
	    inst.AnimState:PlayAnimation("speargun")
	end)

	inst:DoTaskInTime(0.3, function()
	    local pistol = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	    end
	end)
	inst:DoTaskInTime(0.4, function()
	    local pistol = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		local quiverammoReload = pistol.replica.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_pistol_ammo") then
		    inst.SoundEmitter:PlaySound("meta5/walter/ammo_gunpowder_shoot")
		    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
		end
	    end
	end)

	inst:DoTaskInTime(0.5, function()
	    local pistol = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	    end
	end)
	inst:DoTaskInTime(0.6, function()
	    local pistol = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		local quiverammoReload = pistol.replica.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_pistol_ammo") then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
		end
	    end
	end)

	inst:DoTaskInTime(0.7, function()
	    local pistol = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol_empty", "swap_sdf_pistol_empty")
	    end
	end)
	inst:DoTaskInTime(0.8, function()
	    local pistol = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if pistol and pistol:HasTag("sdf_pistol_shoot") then
		local quiverammoReload = pistol.replica.container:GetItemInSlot(1)
		if quiverammoReload ~= nil and quiverammoReload:HasTag("sdf_pistol_ammo") then
		    inst.AnimState:OverrideSymbol("swap_object", "swap_sdf_pistol", "swap_sdf_pistol")
		end
	    end
	end)

        local buffaction = inst:GetBufferedAction()
        if buffaction ~= nil then
            inst:PerformPreviewBufferedAction()
            if buffaction.target ~= nil and buffaction.target:IsValid() then
                inst:FacePoint(buffaction.target:GetPosition())
                inst.sg.statemem.attacktarget = buffaction.target
            end
        end
        if cooldown > 0 then
            cooldown = math.max(cooldown, 12 * FRAMES)
        end
        
    end,
    
    timeline=
    {
       
        TimeEvent(12*FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")

        end),
        TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
    },
    
    events=
    {
        EventHandler("animover", function(inst)
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
	if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
	    inst.replica.combat:CancelAttack()
	end
    end,
})

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
AddStategraphState("wilson", sdf_pistol_knockback)
AddStategraphState("wilson", sdf_pistol_shoot)
AddStategraphState("wilson_client", sdf_pistol_shoot_client)
AddStategraphState("wilson", sdf_pistol_shoot_castspell)
AddStategraphState("wilson_client", sdf_pistol_shoot_castspell_client)

--------------------------------------------WILSON SG ACTIONHANDLER FOR ATTACK OVERRIDE---------------------------------------------------------------------------
local originalAttack
local originalClientAttack

local function NewDestStateATTACK(inst, action)
  inst.sg.mem.localchainattack = not action.forced or nil
  local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
  if weapon and weapon:HasTag("sdf_pistol_shoot") and not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and inst.components.combat ~= nil then
    return "sdf_pistol_shoot"
  else
    return originalAttack(inst, action)
  end
end

local function NewClientDestStateATTACK(inst, action)
  local weapon = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
  if weapon and weapon:HasTag("sdf_pistol_shoot") and not inst.sg:HasStateTag("attack") and inst.replica.combat then
    return "sdf_pistol_shoot"
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
    if action.invobject and action.invobject:HasTag("sdf_pistol_shoot") then 
	return "sdf_pistol_shoot_castspell"
    end 
    end)
end)

AddStategraphPostInit('wilson_client', function(self)
    overwrite(self.actionhandlers[ACTIONS.CASTSPELL], "deststate", function(inst, action)
    if action.invobject and action.invobject:HasTag("sdf_pistol_shoot") then 
	return "sdf_pistol_shoot_castspell"
    end 
    end)
end)