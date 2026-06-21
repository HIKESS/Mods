local SDFRanged_Power_Attack = Class(function (self,inst)
    self.inst=inst
    self.powerAttackType=nil
end)


function SDFRanged_Power_Attack:SetPowerAttackType(type)
    self.powerAttackType=type
end

function SDFRanged_Power_Attack:GetPowerAttackType()
     return self.powerAttackType
end
----

local THROWING_DAGGERS_HEMORRHAGE_RANDOM ={
"minotaur_blood1", "minotaur_blood2", "minotaur_blood3"
} --random blood effect

function SDFRanged_Power_Attack:PowerAttackThrowingDaggers(inst,owner,target)
    --hemorrhage
    if target ~= nil and target:IsValid() then
	--hemorrhage debuff
	if target._sdf_throwing_daggers_hemorrhage_debufftask ~= nil then
	    target._sdf_throwing_daggers_hemorrhage_debufftask:Cancel()
	end
	--hemorrhage anim
	if target._sdf_throwing_daggers_hemorrhage_debuffFXtask ~= nil then
	    target._sdf_throwing_daggers_hemorrhage_debuffFXtask:Cancel()
	end

	--Remove debuff and anim
	target._sdf_throwing_daggers_hemorrhage_debufftask = target:DoTaskInTime(TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_HEMORRHAGE_DEBUFF_DURATION, function(i)
	    i._sdf_throwing_daggers_hemorrhage_debufftask = nil
	    i._sdf_throwing_daggers_hemorrhage_debuffFXtask:Cancel() i._sdf_throwing_daggers_hemorrhage_debuffFXtask = nil
	end)

	--Add debuff and anim
	target._sdf_throwing_daggers_hemorrhage_debuffFXtask = target:DoPeriodicTask(TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_HEMORRHAGE_DEBUFF_TICK, function(i)
	    if target ~= nil and not target.components.health:IsDead() then
		target.components.health:DoDelta(-(TUNING.SDF_THROWING_DAGGERS_DAMAGE / (TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_HEMORRHAGE_DEBUFF_DURATION / TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_HEMORRHAGE_DEBUFF_TICK)), false, "hemorrhage")
		local hemorrhageRandom = THROWING_DAGGERS_HEMORRHAGE_RANDOM[math.random(#THROWING_DAGGERS_HEMORRHAGE_RANDOM)]
		local hemorrhageFX = SpawnPrefab(hemorrhageRandom)
		if hemorrhageFX then
		    local x,_,z = target.Transform:GetWorldPosition()
		    hemorrhageFX.Transform:SetPosition(x,_,z)
		    hemorrhageFX.Transform:SetScale(0.6,0.6,0.6)
		end
	    end
	end)
    end
end
----

local CROSSBOW_MUST_HAVE_TAGS = nil
local CROSSBOW_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local CROSSBOW_AOE_RADIUS = TUNING.SDF_CROSSBOW_POWER_ATTACK_RICHOCHET_RADIUS

local function aoeCrossbowRicochetCheck(inst,owner,target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, CROSSBOW_AOE_RADIUS, CROSSBOW_MUST_HAVE_TAGS, CROSSBOW_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--aoe ricochet
	if v ~= target and v ~= owner and v:IsValid() and (not v:IsInLimbo()) and v.components.combat then
	    --if not (v.components.follower and v.components.follower.leader and v.components.follower.leader == owner) then
	    if owner.components.combat:CanTarget(v) and not owner.components.combat:IsAlly(v) and v.components.combat and (v.components.health and not v.components.health:IsDead()) then
		--ammo type
		local projectile = SpawnPrefab(inst.prefab)

		--power down
		--Extra Damage
		if projectile.components.weapon then
		    projectile.components.weapon:SetDamage(projectile.components.weapon.damage * TUNING.SDF_CROSSBOW_POWER_ATTACK_RICHOCHET_MULTI)
		end
		--Extra Planar Damage
		if projectile.components.planardamage then
		    projectile.components.planardamage:SetBaseDamage(projectile.components.weapon.damage * TUNING.SDF_CROSSBOW_POWER_ATTACK_RICHOCHET_MULTI)
		end

		--throw
		local offset = 1
		local x, y, z = target.Transform:GetWorldPosition()
		local dir = (v:GetPosition() - Vector3(x, y, z)):Normalize()
		dir = dir * offset
		projectile.Transform:SetPosition(x + dir.x, y, z + dir.z)
		projectile.components.projectile:Throw(owner, v, owner)

		return
	    end
	end
    end
end

function SDFRanged_Power_Attack:PowerAttackCrossbow(inst,owner,target)
    --ricochet
    if target:HasTag("structure") or target:HasTag("epic") or target:HasTag("largecreature") then
	aoeCrossbowRicochetCheck(inst,owner,target)
    end
end
----

local function aoeFire(inst, target, owner)
    if target then
	if target.components.burnable and not target.components.burnable:IsBurning() then
	    if target.components.freezable and target.components.freezable:IsFrozen() then
		target.components.freezable:Unfreeze()
	    else
		target.components.burnable:Ignite(true)
	    end

	    if target.components.freezable then
		target.components.freezable:AddColdness(-1) --Does this break ice staff?
		if target.components.freezable:IsFrozen() then
		    target.components.freezable:Unfreeze()
		end
	    end

	    if target.components.sleeper and target.components.sleeper:IsAsleep() then
		target.components.sleeper:WakeUp()
	    end

	    if target.components.combat then
		target.components.combat:SuggestTarget(owner)
	    end
	    target:PushEvent("attacked", {attacker = owner, damage = 0})
	end
    end
end

local FLAMING_CROSSBOW_MUST_HAVE_TAGS = nil
local FLAMING_CROSSBOW_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local FLAMING_CROSSBOW_AOE_RADIUS = TUNING.SDF_FLAMING_CROSSBOW_POWER_ATTACK_AOE_RADIUS

local function aoeCrossbowFireCheck(inst,owner,target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, FLAMING_CROSSBOW_AOE_RADIUS, FLAMING_CROSSBOW_MUST_HAVE_TAGS, FLAMING_CROSSBOW_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--aoe Fire
	if target ~= owner and target.entity:IsVisible() then
	    if not (v.components.follower and v.components.follower.leader and v.components.follower.leader == owner) then
		aoeFire(inst, v, owner)
	    end
	end
    end
end

function SDFRanged_Power_Attack:PowerAttackFlamingCrossbow(inst,owner,target)
    --aoeSplashFX
    local fireSplashFX = SpawnPrefab("firesplash_fx")
    if fireSplashFX then
	local x,_,z = target.Transform:GetWorldPosition()
	fireSplashFX.Transform:SetPosition(x,_,z)
	fireSplashFX.Transform:SetScale(0.6,0.6,0.6)
    end
    if target.SoundEmitter then
	target.SoundEmitter:PlaySound("dontstarve/common/fireOut")
    end

    --aoe Fire
    aoeCrossbowFireCheck(inst,owner,target)

    --ricochet
    if target:HasTag("structure") or target:HasTag("epic") or target:HasTag("largecreature") then
	aoeCrossbowRicochetCheck(inst,owner,target)
    end
end
----

function SDFRanged_Power_Attack:PowerAttackLongbow(inst,owner,target)
    --impactFX
    local impactFX = SpawnPrefab("voidcloth_boomerang_impact_fx")
    if impactFX then
	local x,_,z = target.Transform:GetWorldPosition()
	impactFX.Transform:SetPosition(x,_,z)
	impactFX.Transform:SetScale(0.8,0.8,0.8)
    end
    --if target.SoundEmitter then
	--target.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/slow")
    --end
end
----

local FLAMING_LONGBOW_MUST_HAVE_TAGS = nil
local FLAMING_LONGBOW_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local FLAMING_LONGBOW_AOE_RADIUS = TUNING.SDF_FLAMING_LONGBOW_POWER_ATTACK_AOE_RADIUS

local function aoeLongbowFireCheck(inst,owner,target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, FLAMING_LONGBOW_AOE_RADIUS, FLAMING_LONGBOW_MUST_HAVE_TAGS, FLAMING_LONGBOW_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--aoe Fire
	if target ~= owner and target.entity:IsVisible() then
	    if not (v.components.follower and v.components.follower.leader and v.components.follower.leader == owner) then
		aoeFire(inst, v, owner)
	    end
	end
    end
end

function SDFRanged_Power_Attack:PowerAttackFlamingLongbow(inst,owner,target)
    --aoeSplashFX
    local fireSplashFX = SpawnPrefab("firesplash_fx")
    if fireSplashFX then
	local x,_,z = target.Transform:GetWorldPosition()
	fireSplashFX.Transform:SetPosition(x,_,z)
	fireSplashFX.Transform:SetScale(1.6,1.6,1.6)
    end
    if target.SoundEmitter then
	target.SoundEmitter:PlaySound("dontstarve/common/fireOut")
    end

    --aoe Fire
    aoeLongbowFireCheck(inst,owner,target)
end
----

local function calculateMiasmaDamage(inst, affected_entity, owner)
    if affected_entity.components.health then
        local ae_combat = affected_entity.components.combat
	local planarDamageAdjusted = 0

	--Damage
	if inst.components.weapon then
	    planarDamageAdjusted = (planarDamageAdjusted + inst.components.weapon.damage)
	end
	--Planar Damage
	if inst.components.planardamage then
	    planarDamageAdjusted = (planarDamageAdjusted + inst.components.planardamage:GetBaseDamage())
	end

	--Deal Planar Damage
        if ae_combat then
	    ae_combat:GetAttacked(owner, 0, inst, nil, {planarDamageAdjusted})
        else
            affected_entity.components.health:DoDelta(-planarDamageAdjusted, nil, inst.prefab, nil, owner)
        end
    end
end

local MAGIC_LONGBOW_MUST_HAVE_TAGS = nil
local MAGIC_LONGBOW_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local MAGIC_LONGBOW_AOE_RADIUS = TUNING.SDF_MAGIC_LONGBOW_POWER_ATTACK_AOE_RADIUS

local function aoeMiasmaCheck(inst,owner,target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, MAGIC_LONGBOW_AOE_RADIUS, MAGIC_LONGBOW_MUST_HAVE_TAGS, MAGIC_LONGBOW_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--aoe Damage
	if target ~= owner and target ~= v and target.entity:IsVisible() then
	    if not (v.components.follower and v.components.follower.leader and v.components.follower.leader == owner) then
		calculateMiasmaDamage(inst,v, owner)
	    end
	end
    end
end

function SDFRanged_Power_Attack:PowerAttackMagicLongbow(inst,owner,target)
    --aoeSplashFX
    local miasmaSplashFX = SpawnPrefab("moonpulse2_fx")
    if miasmaSplashFX then
	local x,_,z = target.Transform:GetWorldPosition()
	miasmaSplashFX.Transform:SetPosition(x,_,z)
	miasmaSplashFX.Transform:SetScale(0.6,0.6,0.6)
    end
    if target.SoundEmitter then
	target.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/slow")
    end

    --aoe Damge
    aoeMiasmaCheck(inst,owner,target)
end
----

function SDFRanged_Power_Attack:PowerAttackSpear(inst,owner,target)
    --sunder armor
    if target ~= nil and target:IsValid() then
	--sunder armor debuff
	if target._sdf_spear_sunder_armor_debufftask ~= nil then
	    target._sdf_spear_sunder_armor_debufftask:Cancel()
	end
	--sunder armor anim
	if target._sdf_spear_sunder_armor_debuffFX ~= nil then
	    target._sdf_spear_sunder_armor_debuffFX:goAwayFn()
	end

	--Remove debuff and anim
	target._sdf_spear_sunder_armor_debufftask = target:DoTaskInTime(TUNING.SDF_SPEAR_POWER_ATTACK_SUNDER_ARMOR_DEBUFF_DURATION, function(i)
	    i.components.combat.externaldamagetakenmultipliers:RemoveModifier(i, "sdf_spear_sunder_armor_debuff") i._sdf_spear_sunder_armor_debufftask = nil
	    i._sdf_spear_sunder_armor_debuffFX:goAwayFn()
	end)

	--Add debuff and anim
	if target ~= nil and target.components.combat and not target.components.health:IsDead() then
	    target.components.combat.externaldamagetakenmultipliers:SetModifier(target, TUNING.SDF_SPEAR_POWER_ATTACK_SUNDER_ARMOR_DEBUFF_MULTI, "sdf_spear_sunder_armor_debuff")
	    target._sdf_spear_sunder_armor_debuffFX = SpawnPrefab("sdf_spear_sunder_armor_debuff")
	    target:AddChild(target._sdf_spear_sunder_armor_debuffFX)
	    local scale = 0.5
	    target._sdf_spear_sunder_armor_debuffFX.Transform:SetScale(scale, scale, scale)
	end
    end
end
----


----

function SDFRanged_Power_Attack:GetPowerAttackSkill(inst, owner, target, type)
    if type == "sdf_throwing_daggers" then
	self:PowerAttackThrowingDaggers(inst,owner,target)
    end
    if type == "sdf_crossbow" then
	self:PowerAttackCrossbow(inst,owner,target)
    end
    if type == "sdf_flaming_crossbow" then
	self:PowerAttackFlamingCrossbow(inst,owner,target)
    end
    if type == "sdf_longbow" then
	self:PowerAttackLongbow(inst,owner,target)
    end
    if type == "sdf_flaming_longbow" then
	self:PowerAttackFlamingLongbow(inst,owner,target)
    end
    if type == "sdf_magic_longbow" then
	self:PowerAttackMagicLongbow(inst,owner,target)
    end
    if type == "sdf_spear" then
	self:PowerAttackSpear(inst,owner,target)
    end
end
----

return SDFRanged_Power_Attack