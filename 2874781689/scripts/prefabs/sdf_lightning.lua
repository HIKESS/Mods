local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_lightning.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_lightning.tex"),

    Asset("ANIM", "anim/sdf_lightning.zip"),
    Asset("ANIM", "anim/sdf_lightning_charged_bolt_fx.zip"),
    Asset("ANIM","anim/sdf_lightning_charged_crackle_fx.zip"),
}

prefabs = {
}


local function ActiveModeState(inst)
    local myContainer = inst.components.inventoryitem.owner
    if myContainer ~= nil then
	if inst.components.rechargeable:IsCharged() and myContainer.prefab == "sdf_lightning_gauntlet" then
	    myContainer:ModeStateLightningToggleFn()
	    inst.SoundEmitter:PlaySound("meta4/winbot/dropoff")
	    inst.components.rechargeable:Discharge(TUNING.SDF_LIGHTNING_GAUNTLET_TOGGLE_COOLDOWN)
	end
    end
end

local function OnToggle(inst)
    inst:AddComponent("toggleableitem")
    inst.components.toggleableitem:SetOnToggleFn(ActiveModeState)
end

local function OnPutInInventory(inst, owner)
    inst:DoTaskInTime(0.1, function()
	if owner ~= nil then

	    --removes toggle
	    if not owner:HasTag("sdf_lightning_gauntlet") then
		if inst.components.toggleableitem then
		    inst:RemoveComponent("toggleableitem")
		end
	   end
	else
	    if inst.components.toggleableitem then
		inst:RemoveComponent("toggleableitem")
	    end
	end
    end)
end

local function createStaticProjectile(inst, victim, attacker, target, staticDamage, staticPlanarDamage, staticChainCount)
    if victim ~= nil then
	local staticProj = SpawnPrefab("sdf_lightning_static")
	staticProj.components.weapon:SetDamage(staticDamage)
	staticProj.components.planardamage:SetBaseDamage(staticPlanarDamage)
	staticProj.ChainCounter = staticChainCount
	staticProj.Transform:SetPosition(target.Transform:GetWorldPosition())
	staticProj.components.projectile:Throw(attacker, victim)
    end
end

local LIGHTNING_STATIC_NOTAGS_VANILLA = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"abigail", "companion", "shadowminion", "player"
}
local LIGHTNING_STATIC_NOTAGS_PVP = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"playerghost", "corpse"
}

local function aoeStaticCheck(inst,attacker,target, staticDamage, staticPlanarDamage, staticChainCounter)
    if staticChainCounter <= 0 then
	return
    end
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local SPAWN_COUNTER = 0
    for _, ent in pairs(TheSim:FindEntities(tx, ty, tz, TUNING.SDF_LIGHTNING_STATIC_AOE_RADIUS, nil, 
    TheNet:GetPVPEnabled() and LIGHTNING_STATIC_NOTAGS_PVP or LIGHTNING_STATIC_NOTAGS_VANILLA)) do

	--aoe Static Spawn
	if ent ~= target and ent ~= attacker and ent:IsValid() and (not ent:IsInLimbo()) and ent.components.combat then
	    if attacker.components.combat:CanTarget(ent) and not attacker.components.combat:IsAlly(ent) and ent.components.combat and (ent.components.health and not ent.components.health:IsDead()) and not ent._sdf_lightning_static_debufftask then
		SPAWN_COUNTER = SPAWN_COUNTER + 1
		local CHAIN_COUNTER = staticChainCounter - 1
		local totalAdjustDamage = TUNING.SDF_LIGHTNING_DAMAGE / (TUNING.SDF_LIGHTNING_STATIC_MAX_CHAIN_COUNT + 1)
		local totalAdjustPlanarDamage = TUNING.SDF_LIGHTNING_PLANAR_DAMAGE / (TUNING.SDF_LIGHTNING_STATIC_MAX_CHAIN_COUNT + 1)
		createStaticProjectile(inst, ent, attacker, target, (staticDamage - totalAdjustDamage), (staticPlanarDamage - totalAdjustPlanarDamage), CHAIN_COUNTER)
	    end
	end
	if SPAWN_COUNTER >= TUNING.SDF_LIGHTNING_STATIC_MAX_SPAWN_COUNT then
	    return
	end
    end
end

local function OnPreHit(inst, attacker, target)
    --create Static
    aoeStaticCheck(inst,attacker,target, inst.components.weapon.damage, inst.components.planardamage.basedamage, inst.ChainCounter)
end

local function OnHit(inst, owner, target)
    local rangeWeapon = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if rangeWeapon ~= nil and rangeWeapon.components.finiteuses then
	rangeWeapon.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_USAGE)
    end

    --Random Animation
    local electricutefx = SpawnPrefab("sdf_lightning_charged_electricute_fx")
    if electricutefx then
	if target:HasTag("largecreature") or target:HasTag("epic") then
	    inst.AnimState:SetScale(1.2,1.2)
	end

	local follower = electricutefx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	electricutefx:FacePoint(inst.Transform:GetWorldPosition())

	--electrocute fx
        if target:HasTag("player") and not target.sg:HasStateTag("dead") then
	    target.sg:GoToState("electrocute")
	end

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--Debuff effect
	local debuffkey = inst.prefab
	if target ~= nil and target:IsValid() and target.components.locomotor ~= nil then
	    --slowing debuff
	    if target._sdf_lightning_charged_movespeed_debufftask ~= nil then
		target._sdf_lightning_charged_movespeed_debufftask:Cancel()
	    end
	    --slowing anim
	    if target._sdf_lightning_movespeed_debuffFXtask ~= nil then
		target._sdf_lightning_movespeed_debuffFXtask:Cancel()
	    end

	    --Remove debuff and anim
	    target._sdf_lightning_charged_movespeed_debufftask = target:DoTaskInTime(TUNING.SDF_LIGHTNING_MOVESPEED_DEBUFF_DURATION, function(i)
		i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_lightning_charged_movespeed_debufftask = nil
		i._sdf_lightning_movespeed_debuffFXtask:Cancel() i._sdf_lightning_movespeed_debuffFXtask = nil
	    end)

	    --Add debuff and anim
	    target.components.locomotor:SetExternalSpeedMultiplier(target, debuffkey, TUNING.SDF_LIGHTNING_MOVESPEED_DEBUFF)
	    target._sdf_lightning_movespeed_debuffFXtask = target:DoPeriodicTask(1, function(i)
		if target ~= nil and not target.components.health:IsDead() then
		    target._sdf_lightning_movespeed_debuffFX = SpawnPrefab("sdf_lightning_charged_electricute_fx")
		    target._sdf_lightning_movespeed_debuffFX.entity:SetParent(target.entity)
		end
	    end)
	end
    end

    inst:Remove()
end

local function OnThrown(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_electric")
    inst.AnimState:PlayAnimation("static", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.components.inventoryitem.pushlandedevents = false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("sdf_lightning")
    inst.AnimState:SetBuild("sdf_lightning")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    inst:AddTag("weapon")
    inst:AddTag("projectile")
    inst:AddTag("sdf_lightning_gauntlet_lightning_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_LIGHTNING_DAMAGE)
    inst.components.weapon:SetElectric()

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_LIGHTNING_PLANAR_DAMAGE)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_LIGHTNING_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_LIGHTNING_DURABILITY)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_LIGHTNING_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(1)
    inst.components.projectile:SetLaunchOffset(Vector3(0.35, 0.5, 0))
    inst.components.projectile:SetOnPreHitFn(OnPreHit)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile.range = TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_RANGE + 4
    inst.components.projectile.has_damage_set = true
    inst:ListenForEvent("onthrown", OnThrown)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_lightning"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning.xml"

    inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)

    inst.ChainCounter = TUNING.SDF_LIGHTNING_STATIC_MAX_CHAIN_COUNT
    inst.OnToggleFn = function() OnToggle(inst) end

    return inst
end

--Static
local function StaticOnPreHit(inst, attacker, target)
    --create Static
    aoeStaticCheck(inst,attacker,target, inst.components.weapon.damage, inst.components.planardamage.basedamage, inst.ChainCounter)
end

local function StaticOnHit(inst, owner, target)

    --Random Animation
    local shockfx = SpawnPrefab("sdf_lightning_shock_fx")
    if shockfx then
	if target:HasTag("largecreature") or target:HasTag("epic") then
	    inst.AnimState:SetScale(1.2,1.2)
	end

	local follower = shockfx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	shockfx:FacePoint(inst.Transform:GetWorldPosition())

	--electrocute FX
        if target:HasTag("player") and not target.sg:HasStateTag("dead") then
	    target.sg:GoToState("electrocute")
	end

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--Debuff effect
	local debuffkey = inst.prefab
	if target ~= nil and target:IsValid() and target.components.locomotor ~= nil then

	    --static cooldown
	    if target._sdf_lightning_static_debufftask ~= nil then
		target._sdf_lightning_static_debufftask:Cancel()
	    end
	    --slowing debuff
	    if target._sdf_lightning_charged_movespeed_debufftask ~= nil then
		target._sdf_lightning_charged_movespeed_debufftask:Cancel()
	    end
	    --slowing anim
	    if target._sdf_lightning_movespeed_debuffFXtask ~= nil then
		target._sdf_lightning_movespeed_debuffFXtask:Cancel()
	    end

	    --Remove staticdebuff
	    target._sdf_lightning_static_debufftask = target:DoTaskInTime(TUNING.SDF_LIGHTNING_STATIC_DEBUFF_DURATION, function(i)
		i._sdf_lightning_static_debufftask = nil
	    end)
	    --Remove debuff and anim
	    target._sdf_lightning_charged_movespeed_debufftask = target:DoTaskInTime(TUNING.SDF_LIGHTNING_MOVESPEED_DEBUFF_DURATION, function(i)
		i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_lightning_charged_movespeed_debufftask = nil
		i._sdf_lightning_movespeed_debuffFXtask:Cancel() i._sdf_lightning_movespeed_debuffFXtask = nil
	    end)

	    --Add debuff and anim
	    target.components.locomotor:SetExternalSpeedMultiplier(target, debuffkey, TUNING.SDF_LIGHTNING_MOVESPEED_DEBUFF)
	    target._sdf_lightning_movespeed_debuffFXtask = target:DoPeriodicTask(1, function(i)
		if target ~= nil and not target.components.health:IsDead() then
		    target._sdf_lightning_movespeed_debuffFX = SpawnPrefab("sdf_lightning_charged_electricute_fx")
		    target._sdf_lightning_movespeed_debuffFX.entity:SetParent(target.entity)
		end
	    end)
	end
    end

    inst:Remove()
end

local function StaticOnThrown(inst, data)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function lightningStaticfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_lightning")
    inst.AnimState:SetBuild("sdf_lightning")
    inst.AnimState:PlayAnimation("static", true)

    inst:AddTag("projectile")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetElectric()

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(0)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_LIGHTNING_STATIC_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(1)
    inst.components.projectile:SetLaunchOffset(Vector3(0.35, 0.5, 0))
    inst.components.projectile:SetOnPreHitFn(StaticOnPreHit)
    inst.components.projectile:SetOnHitFn(StaticOnHit)
    inst.components.projectile.range = TUNING.SDF_LIGHTNING_STATIC_RANGE + 4
    inst.components.projectile.has_damage_set = true
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst:ListenForEvent("onthrown", StaticOnThrown)

    inst.ChainCounter = 0

    inst.persits = false

    return inst
end


--FX
local LIGHTNING_MAX_DIST_SQ = 140*140

local function StartFX(inst)
    for i, v in ipairs(AllPlayers) do
	local distSq = v:GetDistanceSqToInst(inst)
	local k = math.max(0, math.min(1, distSq / LIGHTNING_MAX_DIST_SQ))
	local intensity = -(k-1)*(k-1)*(k-1)

	if intensity > 0 then
	    v:ScreenFlash(intensity <= 0.05 and 0.05 or intensity)
	    v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 3)
	end
    end
end

local function lightningChargedfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(2, 2, 2)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBank("sdf_lightning_charged_bolt_fx")
    inst.AnimState:SetBuild("sdf_lightning_charged_bolt_fx")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, StartFX) -- so we can use the position to affect the screen flash

    inst.persists = false
    inst:DoTaskInTime(0.5, inst.Remove)

    return inst
end

local function lightningChargedfn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_lightning_charged_crackle_fx")
    inst.AnimState:SetBuild("sdf_lightning_charged_crackle_fx")
    inst.AnimState:PlayAnimation("crackle_hit")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst.persists = false
    inst:DoTaskInTime(0.65, inst.Remove)

    return inst
end


local NOTAGS_VANILLA = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"abigail", "companion", "shadowminion", "player"
}
local NOTAGS_PVP = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"playerghost", "corpse"
}


local function ChargedOnAttackFn(inst, attacker, target)
    --Random Animation
    local electricutefx = SpawnPrefab("sdf_lightning_charged_electricute_fx")
    if electricutefx then
	if target:HasTag("largecreature") or target:HasTag("epic") then
	    inst.AnimState:SetScale(1.2,1.2)
	end

	local follower = electricutefx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	electricutefx:FacePoint(inst.Transform:GetWorldPosition())

	--electrocute FX
        if target:HasTag("player") and not target.sg:HasStateTag("dead") then
	    target.sg:GoToState("electrocute")
	end

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--Debuff effect
	local debuffkey = inst.prefab
	if target ~= nil and target:IsValid() and target.components.locomotor ~= nil then
	    --slowing debuff
	    if target._sdf_lightning_charged_movespeed_debufftask ~= nil then
		target._sdf_lightning_charged_movespeed_debufftask:Cancel()
	    end
	    --slowing anim
	    if target._sdf_lightning_movespeed_debuffFXtask ~= nil then
		target._sdf_lightning_movespeed_debuffFXtask:Cancel()
	    end

	    --Remove debuff and anim
	    target._sdf_lightning_charged_movespeed_debufftask = target:DoTaskInTime(TUNING.SDF_LIGHTNING_CHARGED_MOVESPEED_DEBUFF_DURATION, function(i)
		i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_lightning_charged_movespeed_debufftask = nil
		i._sdf_lightning_movespeed_debuffFXtask:Cancel() i._sdf_lightning_movespeed_debuffFXtask = nil
	    end)

	    --Add debuff and anim
	    target.components.locomotor:SetExternalSpeedMultiplier(target, debuffkey, TUNING.SDF_LIGHTNING_CHARGED_MOVESPEED_DEBUFF)
	    target._sdf_lightning_movespeed_debuffFXtask = target:DoPeriodicTask(1, function(i)
		if target ~= nil and not target.components.health:IsDead() then
		    target._sdf_lightning_movespeed_debuffFX = SpawnPrefab("sdf_lightning_charged_electricute_fx")
		    target._sdf_lightning_movespeed_debuffFX.entity:SetParent(target.entity)
		end
	    end)
	end
    end
end
	

local function lightningChargedfn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_lightning_charged_crackle_fx")
    inst.AnimState:SetBuild("sdf_lightning_charged_crackle_fx")
    inst.AnimState:PlayAnimation("crackle_projection")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(1.5,1.5)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_LIGHTNING_CHARGED_DAMAGE)
    inst.components.weapon:SetElectric()
    inst.components.weapon:SetOnAttack(ChargedOnAttackFn)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_LIGHTNING_CHARGED_PLANAR_DAMAGE)

    inst.persists = false
    inst:ListenForEvent("animover",inst.Remove)

    return inst
end

local function lightningChargedfn4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_lightning_charged_crackle_fx")
    inst.AnimState:SetBuild("sdf_lightning_charged_crackle_fx")
    inst.AnimState:PlayAnimation("crackle_loop", true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetScale(0.6,0.6)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover",inst.Remove)

    return inst
end

return  Prefab("common/inventory/sdf_lightning", fn, assets),
	Prefab( "sdf_lightning_static", lightningStaticfn, assets),
	Prefab( "sdf_lightning_charged_bolt_fx", lightningChargedfn, assets),
	Prefab("sdf_lightning_charged_crackle_fx",lightningChargedfn2, assets),
	Prefab("sdf_lightning_charged_cracklebase_fx",lightningChargedfn3, assets),
	Prefab("sdf_lightning_charged_electricute_fx",lightningChargedfn4, assets)