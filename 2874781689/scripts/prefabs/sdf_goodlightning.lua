local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_goodlightning.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_goodlightning.tex"),

    Asset("ANIM", "anim/sdf_goodlightning.zip"),
    Asset("ANIM", "anim/sdf_goodlightning_charged_bolt_fx.zip"),
    Asset("ANIM","anim/sdf_goodlightning_charged_crackle_fx.zip"),
}

prefabs = {
}


local function ActiveModeState(inst)
    local myContainer = inst.components.inventoryitem.owner
    if myContainer ~= nil then
	if inst.components.rechargeable:IsCharged() and myContainer.prefab == "sdf_lightning_gauntlet" then
	    myContainer:ModeStateGoodlightningToggleFn()
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

	    --Changes icon normal and baited this is anim?
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

local function embalmingHot(inst, attacker, target)
    --Skill Tree Embalming
    if attacker.prefab == "sdf" then
	if attacker.components.skilltreeupdater:IsActivated("sdf_undeath_3") then
	    --Buff effect
	    if  target.components.combat and (target.components.health and not target.components.health:IsDead()) then
		--hot buff
		if target._sdf_goodlightning_embalming_hot_bufftask ~= nil then
		    target._sdf_goodlightning_embalming_hot_bufftask:Cancel()
		end
		--hot anim
		if target._sdf_goodlightning_embalming_hot_buffFXtask ~= nil then
		    target._sdf_goodlightning_embalming_hot_buffFXtask:Cancel()
		end

		--Remove buff and anim
		target._sdf_goodlightning_embalming_hot_bufftask = target:DoTaskInTime(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_DURATION, function(i)
		    i._sdf_goodlightning_embalming_hot_buffFXtask:Cancel() i._sdf_goodlightning_embalming_hot_buffFXtask = nil
		end)

		--Add buff and anim
		target._sdf_goodlightning_embalming_hot_buffFXtask = target:DoPeriodicTask(1, function(i)
		    if target ~= nil and (target.components.health and not target.components.health:IsDead()) then
			--Ally Heal
			local totalAdjustHot = (inst.HealAmount * TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_PERCENT) / TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_DURATION
			if target:HasTag("sdf_undeath_healing") then
			    --Heal
			    target.components.health:DoDelta((totalAdjustHot * TUNING.SDF_GOODLIGHTNING_HEAL_UNDEATH_MULTI), false, "goodlightning")
			else
			    --Heal
			    target.components.health:DoDelta(totalAdjustHot, false, "goodlightning")
			end
			target._sdf_goodlightning_embalming_hot_buffFX = SpawnPrefab("spider_heal_target_fx")
			target._sdf_goodlightning_embalming_hot_buffFX.entity:SetParent(target.entity)

			if target.SoundEmitter then
			    target.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")
			end
		    end
		end)
	    end
	end
    end
end

local function removeAggro(inst, target, attacker)
    if not target:HasTag("epic") then
	local totalAdjustAggroDuration = 0

	--Skill Tree Embalming
	if attacker.prefab == "sdf" then
	    if attacker.components.skilltreeupdater:IsActivated("sdf_undeath_3") then
		totalAdjustAggroDuration = TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_AGGRO_DEBUFF_DURATION
	    end
	end

	--remove aggro debuff
	if target.components.combat.target == attacker then
	    target.components.combat:DropTarget()
	end

	if target._sdf_goodlightning_aggro_debufftask ~= nil then
	    target._sdf_goodlightning_aggro_debufftask:Cancel()
	end
	--remove aggro anim
	if target._sdf_goodlightning_aggro_debuffFXtask ~= nil then
	    target._sdf_goodlightning_aggro_debuffFXtask:Cancel()
	end

	--Remove debuff and anim
	target._sdf_goodlightning_aggro_debufftask = target:DoTaskInTime((TUNING.SDF_GOODLIGHTNING_AGGRO_DEBUFF_DURATION + totalAdjustAggroDuration), function(i)
	    i.components.combat:RemoveShouldAvoidAggro(attacker) i._sdf_goodlightning_aggro_debufftask = nil
	    i._sdf_goodlightning_aggro_debuffFXtask:Cancel() i._sdf_goodlightning_aggro_debuffFXtask = nil
	end)

	--Add debuff and anim
	target.components.combat:SetShouldAvoidAggro(attacker)
	target._sdf_goodlightning_aggro_debuffFXtask = target:DoPeriodicTask(1, function(i)
	    if target ~= nil and not target.components.health:IsDead() then
		target._sdf_goodlightning_aggro_debuffFX = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
		target._sdf_goodlightning_aggro_debuffFX.entity:SetParent(target.entity)
	    end
	end)
    end
end

local function createStaticProjectile(inst, victim, attacker, target, staticHeal, staticChainCount, isAlly)
    if victim ~= nil then
	local staticProj = SpawnPrefab("sdf_goodlightning_static")
	staticProj.HealAmount = staticHeal
	staticProj.ChainCounter = staticChainCount
	staticProj.AllyChain = isAlly
	staticProj.Transform:SetPosition(target.Transform:GetWorldPosition())
	staticProj.components.projectile:Throw(attacker, victim)
    end
end

local GOODLIGHTNING_STATIC_NOTAGS_VANILLA = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible"
}
local GOODLIGHTNING_STATIC_NOTAGS_PVP = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"playerghost", "corpse"
}

local function aoeStaticCheck(inst,attacker,target, staticHeal, staticChainCounter, isAlly)
    if staticChainCounter <= 0 then
	return
    end
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local SPAWN_COUNTER = 0

    --Check Ally Heal
    for _, ent in pairs(TheSim:FindEntities(tx, ty, tz, TUNING.SDF_GOODLIGHTNING_STATIC_AOE_RADIUS, nil, 
    TheNet:GetPVPEnabled() and GOODLIGHTNING_STATIC_NOTAGS_PVP or GOODLIGHTNING_STATIC_NOTAGS_VANILLA)) do

	--ally aoe Static Spawn
	if isAlly == true then
	    if ent ~= target and ent ~= attacker and ent:IsValid() and (not ent:IsInLimbo()) and ent.components.combat then
		--Check Ally Heal
		if attacker.components.combat:CanTarget(ent) and (attacker.components.combat:IsAlly(ent) or ent:HasTag("player")) then
		    if ent.components.combat and (ent.components.health and not ent.components.health:IsDead()) and not ent._sdf_goodlightning_static_debufftask then
			SPAWN_COUNTER = SPAWN_COUNTER + 1
			local CHAIN_COUNTER = staticChainCounter - 1
			local totalAdjustHeal = TUNING.SDF_GOODLIGHTNING_HEAL / (TUNING.SDF_GOODLIGHTNING_STATIC_MAX_CHAIN_COUNT + 1)
			createStaticProjectile(inst, ent, attacker, target, (staticHeal - totalAdjustHeal), CHAIN_COUNTER, isAlly)
		    end
		end
	    end
	    if SPAWN_COUNTER >= TUNING.SDF_GOODLIGHTNING_STATIC_MAX_SPAWN_COUNT then
		return
	    end
	else
	    --Hostile aoe Static Spawn
	    if ent ~= target and ent ~= attacker and ent:IsValid() and (not ent:IsInLimbo()) and ent.components.combat then
		if attacker.components.combat:CanTarget(ent) and not attacker.components.combat:IsAlly(ent) and ent.components.combat and (ent.components.health and not ent.components.health:IsDead()) and not ent._sdf_goodlightning_static_debufftask then
		    SPAWN_COUNTER = SPAWN_COUNTER + 1
		    local CHAIN_COUNTER = staticChainCounter - 1
		    local totalAdjustHeal = TUNING.SDF_GOODLIGHTNING_HEAL / (TUNING.SDF_GOODLIGHTNING_STATIC_MAX_CHAIN_COUNT + 1)
		    createStaticProjectile(inst, ent, attacker, target, (staticHeal - totalAdjustHeal), CHAIN_COUNTER, isAlly)
		end
	    end
	    if SPAWN_COUNTER >= TUNING.SDF_GOODLIGHTNING_STATIC_MAX_SPAWN_COUNT then
		return
	    end
	end
    end
end

local function OnPreHit(inst, attacker, target)
    if attacker.components.combat:CanTarget(target) and (attacker.components.combat:IsAlly(target) or target:HasTag("player")) then
	inst.AllyChain = true
    end
    --create Static
    aoeStaticCheck(inst,attacker,target, inst.HealAmount, inst.ChainCounter, inst.AllyChain)
end

local function OnHit(inst, owner, target)
    local rangeWeapon = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if rangeWeapon ~= nil and rangeWeapon.components.finiteuses then
	rangeWeapon.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_USAGE)
    end

    --Random Animation
    local electricutefx = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
    if electricutefx then
	if target:HasTag("largecreature") or target:HasTag("epic") then
	    inst.AnimState:SetScale(1.2,1.2)
	end

	local follower = electricutefx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	electricutefx:FacePoint(inst.Transform:GetWorldPosition())

	--electricute fx
	local goodlightningShockFX = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
	if goodlightningShockFX then
	    goodlightningShockFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
	local goodlightningHealFX = SpawnPrefab("spider_heal_target_fx")
	if goodlightningHealFX then
	    goodlightningHealFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--Heal Target
	if  target.components.combat and target.components.health and not target.components.health:IsDead() then

	    --Ally
	    if target ~= owner and  (owner.components.combat:IsAlly(target) or target:HasTag("player")) then
		--Ally Heal
		if target:HasTag("sdf_undeath_healing") then
		    --Heal
		    target.components.health:DoDelta((TUNING.SDF_GOODLIGHTNING_HEAL * TUNING.SDF_GOODLIGHTNING_HEAL_UNDEATH_MULTI), false, "goodlightning")

		    --Add Ally Hot
		    embalmingHot(inst, owner, target)
		else
		    --Heal
		    target.components.health:DoDelta(TUNING.SDF_GOODLIGHTNING_HEAL, false, "goodlightning")

		    --Sanity Heal
		    if target.components.sanity then
			target.components.sanity:DoDelta(TUNING.SDF_GOODLIGHTNING_SANITY_HEAL)
		    end

		    --Add Ally Hot
		    embalmingHot(inst, owner, target)
		end
	    elseif (target ~= owner and not owner.components.combat:IsAlly(target)) or (target ~= owner and not target:HasTag("player")) then
		--Hostile Heal
		target.components.health:DoDelta(TUNING.SDF_GOODLIGHTNING_HEAL, false, "goodlightning")

		--Remove aggro
		removeAggro(inst, target, owner)
	    end
	end

	--Damage Caster
	if owner.components.combat and owner.components.health and not owner.components.health:IsDead() then
	    owner.components.health:DoDelta(-TUNING.SDF_GOODLIGHTNING_HEAL, false, "goodlightning")
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

    inst.AnimState:SetBank("sdf_goodlightning")
    inst.AnimState:SetBuild("sdf_goodlightning")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	


    inst:AddTag("projectile")
    inst:AddTag("sdf_lightning_gauntlet_goodlightning_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_GOODLIGHTNING_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_GOODLIGHTNING_DURABILITY)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_GOODLIGHTNING_PROJECTILE_SPEED)
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
    inst.components.inventoryitem.imagename = "sdf_goodlightning"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_goodlightning.xml"

    inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)

    inst.HealAmount = TUNING.SDF_GOODLIGHTNING_HEAL
    inst.ChainCounter = TUNING.SDF_GOODLIGHTNING_STATIC_MAX_CHAIN_COUNT
    inst.AllyChain = false

    inst.OnToggleFn = function() OnToggle(inst) end

    return inst
end

--Static
local function StaticOnPreHit(inst, attacker, target)
    --create Static
    aoeStaticCheck(inst,attacker,target, inst.HealAmount, inst.ChainCounter, inst.AllyChain) --inst.components.planardamage.basedamage, inst.ChainCounter)
end

local function StaticOnHit(inst, owner, target)

    --Random Animation
    local electricutefx = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
    if electricutefx then
	if target:HasTag("largecreature") or target:HasTag("epic") then
	    inst.AnimState:SetScale(1.2,1.2)
	end

	local follower = electricutefx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	electricutefx:FacePoint(inst.Transform:GetWorldPosition())

	--electricute fx
	local goodlightningShockFX = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
	if goodlightningShockFX then
	    goodlightningShockFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
	local goodlightningHealFX = SpawnPrefab("spider_heal_target_fx")
	if goodlightningHealFX then
	    goodlightningHealFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--Heal Target
	if  target.components.combat and target.components.health and not target.components.health:IsDead() then

	    --Ally
	    if target ~= owner and  (owner.components.combat:IsAlly(target) or target:HasTag("player")) then
		--Ally Heal
		if target:HasTag("sdf_undeath_healing") then
		    --Heal
		    target.components.health:DoDelta((inst.HealAmount * TUNING.SDF_GOODLIGHTNING_HEAL_UNDEATH_MULTI), false, "goodlightning")

		    --Add Ally Hot
		    embalmingHot(inst, owner, target)
		else
		    --Heal
		    target.components.health:DoDelta(inst.HealAmount, false, "goodlightning")

		    --Sanity Heal
		    if target.components.sanity then
			target.components.sanity:DoDelta(TUNING.SDF_GOODLIGHTNING_SANITY_HEAL)
		    end

		    --Add Ally Hot
		    embalmingHot(inst, owner, target)
		end
	    elseif (target ~= owner and not owner.components.combat:IsAlly(target)) or (target ~= owner and not target:HasTag("player")) then
		--Hostile Heal
		target.components.health:DoDelta(inst.HealAmount, false, "goodlightning")

		--Remove aggro
		removeAggro(inst, target, owner)
	    end
	end

	--Debuff effect
	if target ~= nil and target:IsValid() and target.components.locomotor ~= nil then

	    --static cooldown
	    if target._sdf_goodlightning_static_debufftask ~= nil then
		target._sdf_goodlightning_static_debufftask:Cancel()
	    end

	    --Remove staticdebuff
	    target._sdf_goodlightning_static_debufftask = target:DoTaskInTime(TUNING.SDF_GOODLIGHTNING_STATIC_DEBUFF_DURATION, function(i)
		i._sdf_goodlightning_static_debufftask = nil
	    end)
	end
    end

    inst:Remove()
end

local function StaticOnThrown(inst, data)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function goodlightningStaticfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_goodlightning")
    inst.AnimState:SetBuild("sdf_goodlightning")
    inst.AnimState:PlayAnimation("static", true)

    inst:AddTag("projectile")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_GOODLIGHTNING_STATIC_PROJECTILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(1)
    inst.components.projectile:SetLaunchOffset(Vector3(0.35, 0.5, 0))
    inst.components.projectile:SetOnPreHitFn(StaticOnPreHit)
    inst.components.projectile:SetOnHitFn(StaticOnHit)
    inst.components.projectile.range = TUNING.SDF_GOODLIGHTNING_STATIC_RANGE + 4
    inst.components.projectile.has_damage_set = true
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst:ListenForEvent("onthrown", StaticOnThrown)

    inst.HealAmount = 0
    inst.ChainCounter = 0
    inst.AllyChain = false

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

local function goodlightningChargedfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetScale(2, 2, 2)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBank("sdf_goodlightning_charged_bolt_fx")
    inst.AnimState:SetBuild("sdf_goodlightning_charged_bolt_fx")
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

local function goodlightningChargedfn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_goodlightning_charged_crackle_fx")
    inst.AnimState:SetBuild("sdf_goodlightning_charged_crackle_fx")
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


local function goodlightningChargedfn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_goodlightning_charged_crackle_fx")
    inst.AnimState:SetBuild("sdf_goodlightning_charged_crackle_fx")
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

    inst.persists = false
    inst:ListenForEvent("animover",inst.Remove)

    return inst
end


local function goodlightningChargedfn4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_goodlightning_charged_crackle_fx")
    inst.AnimState:SetBuild("sdf_goodlightning_charged_crackle_fx")
    inst.AnimState:PlayAnimation("crackle_loop")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetScale(0.5,0.5)

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

return  Prefab("common/inventory/sdf_goodlightning", fn, assets),
	Prefab( "sdf_goodlightning_static", goodlightningStaticfn, assets),
	Prefab( "sdf_goodlightning_charged_bolt_fx", goodlightningChargedfn, assets),
	Prefab("sdf_goodlightning_charged_crackle_fx",goodlightningChargedfn2, assets),
	Prefab("sdf_goodlightning_charged_cracklebase_fx",goodlightningChargedfn3, assets),
	Prefab("sdf_goodlightning_charged_electricute_fx",goodlightningChargedfn4, assets)