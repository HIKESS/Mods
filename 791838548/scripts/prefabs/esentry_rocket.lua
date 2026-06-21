local assets =
{}

local SENTRYROCKET_RADIUS = TUNING.CANNONBALL_RADIUS
local SENTRYROCKET_DAMAGE = 100/4
local SENTRYROCKET_SPLASH_RADIUS = 3
local SENTRYROCKET_SPLASH_DAMAGE_PERCENT = TUNING.CANNONBALL_SPLASH_DAMAGE_PERCENT -- 60% of SENTRYROCKET_DAMAGE

local MUST_ONE_OF_TAGS = { "_combat", "_health" }
local AREAATTACK_EXCLUDETAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "player", "companion", "wall", "largecreature" }

local function HasFriendlyLeader(inst, target)
    local target_leader = (target.components.follower ~= nil) and target.components.follower.leader or nil
    
    if target_leader ~= nil then

        if target_leader.components.inventoryitem then
            target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        end

        local PVP_enabled = TheNet:GetPVPEnabled()
        return (target_leader ~= nil 
                and (target_leader:HasTag("player") 
                and not PVP_enabled)) or
                (target.components.domesticatable and target.components.domesticatable:IsDomesticated() 
                and not PVP_enabled) or
                (target.components.saltlicker and target.components.saltlicker.salted
                and not PVP_enabled)
    end

    return false
end

local function CanDamage(inst, target)
    if target.components.minigame_participator ~= nil or target.components.combat == nil then
		return false
	end

    if target:HasTag("player") and not TheNet:GetPVPEnabled() then
        return false
    end

    if target:HasTag("playerghost") and not target:HasTag("INLIMBO") then
        return false
    end

    if target:HasTag("monster") and not TheNet:GetPVPEnabled() and 
       ((target.components.follower and target.components.follower.leader ~= nil and 
         target.components.follower.leader:HasTag("player")) or target.bedazzled) then
        return false
    end

    if HasFriendlyLeader(inst, target) then
        return false
    end

    return true
end

local function OnHit(inst, attacker, target)

    -- Do splash damage upon hitting the ground
	inst.components.combat:DoAreaAttack(inst, SENTRYROCKET_SPLASH_RADIUS, nil, nil, nil, AREAATTACK_EXCLUDETAGS)

    -- Landed on the ocean
    if inst:IsOnOcean() then
        SpawnPrefab("crab_king_waterspout").Transform:SetPosition(inst.Transform:GetWorldPosition())
    -- Landed on ground
    else
        SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		SpawnPrefab("impact").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

	if inst.pufftask then
		inst.pufftask:Cancel()
		inst.pufftask = nil
	end

    inst:Remove()
end

local function OnUpdateProjectile(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, 0, z, SENTRYROCKET_RADIUS, nil, nil, MUST_ONE_OF_TAGS) -- Set y to zero to look for objects on the ground
    for i, target in ipairs(targets) do

    if target ~= nil and target ~= inst.components.complexprojectile.attacker then
		if CanDamage(inst, target) then
            -- Do damage to entities with health
            if target.components.combat then
                target.components.combat:GetAttacked(inst, SENTRYROCKET_DAMAGE, nil)
				OnHit(inst)-- We don't want rockets to pass through, destroy on impact
            end

            -- Remove and do splash damage if it hits a wall
            if target:HasTag("wall") and target.components.health then
                if not target.components.health:IsDead() then
					if not SENTRY_FF_WALL == "noff" then
						inst.components.combat:DoAreaAttack(inst, SENTRYROCKET_SPLASH_RADIUS, nil, nil, nil, { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "player", "companion", "largecreature" })
						SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
					end
                    inst:Remove()
                    return
                end
            end
        end
    end

	end
end

local function OnThrown(inst)
    inst.pufftask = inst:DoPeriodicTask(0, function(inst)
    	local x, y, z = inst.Transform:GetWorldPosition()
    	local fx = SpawnPrefab("dirt_puff")
	fx.Transform:SetScale(.5, .5, .5)
    fx.Transform:SetPosition(x, y+1.35, z)
	fx.persists = false
    end)
	--[[
    inst:DoTaskInTime(10, function(inst)
        SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
        SpawnPrefab("impact").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.pufftask:Cancel()
	inst.pufftask = nil
    inst:Remove()
    end)--]]
end

local function fn(isinventoryitem)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLight()
	
    if isinventoryitem then
        MakeInventoryPhysics(inst)
    else
        inst.entity:AddPhysics()
        inst.Physics:SetMass(1)
        inst.Physics:SetFriction(0)
        inst.Physics:SetDamping(0)
        inst.Physics:SetRestitution(0)
		inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
		inst.Physics:CollidesWith(COLLISION.GIANTS)
        inst.Physics:SetSphere(SENTRYROCKET_RADIUS)
		inst.Physics:SetCollisionCallback(OnHit)
    end

    inst.Transform:SetTwoFaced()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.AnimState:SetBank("projectile")
    inst.AnimState:SetBuild("staff_projectile")
    inst.AnimState:PlayAnimation("fire_spin_loop", true)

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(237/255, 237/255, 209/255)

--[[    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(1)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetLaunchOffset(Vector3(math.random(-2,2), math.random(0,1), 0))--]]

	inst:AddComponent("locomotor")
	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1.4, 0))
	inst.components.complexprojectile.usehigharc = false
    inst.components.complexprojectile:SetOnLaunch(OnThrown)
	inst.components.complexprojectile:SetOnHit(OnHit)
	inst.components.complexprojectile:SetOnUpdate(OnUpdateProjectile)
	
	inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(SENTRYROCKET_DAMAGE)
    inst.components.combat:SetAreaDamage(SENTRYROCKET_SPLASH_RADIUS, SENTRYROCKET_SPLASH_DAMAGE_PERCENT)

    inst.persists = false

    return inst
end

return Prefab("esentry_rocket", fn, assets)