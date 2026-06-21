-- SDFGatling_Gun_Weapon_Target handles being shot by the Gatling Gun

local SDFGatling_Gun_Weapon_Target = Class(function(self, inst)
    self.inst = inst
    self.last_shooter = nil
    self.last_bullet = nil
    self.minigun = nil
    self.clear_counter = 0
end)

local minigun_actions = {
    [ACTIONS.CHOP] = true,
    [ACTIONS.MINE] = true,
    [ACTIONS.HAMMER] = true,
}

local destroyableStructures = {
    pigtorch = true,
    pighead = true,
    mermhead = true,
    skeleton = true,
    skeleton_player = true,
    scorched_skeleton = true,
}

local function ImpactFx(inst, target)
    if target ~= nil and target:IsValid() and target.Transform ~= nil then
	local impactfx = SpawnPrefab("impact")
		
	if impactfx == nil then
	    return
	end
		
	if target.components.combat then
	    local follower = impactfx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
			
	    local shooter_player = inst.components.sdf_gatling_gun_weapon_projectile ~= nil and inst.components.sdf_gatling_gun_weapon_projectile.shooter_player ~= nil and inst.components.sdf_gatling_gun_weapon_projectile.shooter_player or nil	
	    if shooter_player ~= nil and shooter_player:IsValid() then
		impactfx:FacePoint(shooter_player.Transform:GetWorldPosition())
	    end

	else
	    impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
	    impactfx.Transform:SetScale(target.Transform:GetScale())
	end

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/characters/tf2heavy/ricochet")
	end
    end
end

--Prefabs excluded from being affected by the Munitions, Still shocks hit FX.
local excludes = {
    rock_limpet = true,
    limpetrock = true,
}

--Prefabs for which Munitions do not apply damage as the player. Creature will hit itself in that case.
local neutral_attacker = {
    jellyfish = true,
    rainbowjellyfish = true,
    rainbowjellyfish_planted = true,
    jellyfish_planted = true,
    kraken_jellyfish = true,
}

function SDFGatling_Gun_Weapon_Target:GetShot(bullet, shooter, minigun)
    --Apply Damage to Target
    local inst = self.inst
    local is_player_or_follower = inst:HasTag("player") or inst:HasTag("companion") or inst.components.follower ~= nil and inst.components.follower.leader ~= nil and inst.components.follower.leader:HasTag("player")
    local is_pvp = TheNet:GetPVPEnabled()
    local unaffected_by_bullets = not (inst.components.combat or inst.components.workable or inst.components.pickable)
	
    if minigun ~= nil and minigun.components.sdf_gatling_gun_weapon ~= nil then
	self.minigun = minigun
    end
	
    if inst == shooter then
	bullet:Remove()
	return
    else
	ImpactFx(bullet, inst)
    end
	
    if not is_pvp and is_player_or_follower or inst.prefab ~= nil and excludes[inst.prefab] or unaffected_by_bullets then
	bullet:Remove()
	return
    end
	
    if inst.components.combat ~= nil then
	local dmg = minigun ~= nil and minigun.components.sdf_gatling_gun_weapon ~= nil and minigun.components.sdf_gatling_gun_weapon:GetDamage() or 0
	local targets_target = inst.components.combat.target
		
	if targets_target == nil or targets_target ~= shooter then
	    if not is_player_or_follower then
		if inst.prefab ~= nil and neutral_attacker[inst.prefab] then
		    inst.components.combat:GetAttacked(inst, dmg, bullet)
		else
		    inst.components.combat:GetAttacked(shooter, dmg, bullet)
		end
	    else
		if inst.prefab ~= nil and neutral_attacker[inst.prefab] then
		    inst.components.combat:GetAttacked(inst, (dmg * TUNING.SDF_STANDARD_MUNITIONS_PVP_DAMAGE_MULT), bullet)
		else
		    inst.components.combat:GetAttacked(shooter, (dmg * TUNING.SDF_STANDARD_MUNITIONS_PVP_DAMAGE_MULT), bullet)
		end
	    end
	else
	    if inst.components.health and not inst.components.health.invincible then
		if not is_player_or_follower then
		    if inst.prefab ~= nil and neutral_attacker[inst.prefab] then
			inst.components.health:DoDelta(-dmg, false, "minigunned", false, inst, false )
		    else
			inst.components.health:DoDelta(-dmg, false, "minigunned", false, shooter, false)
		    end
		else
		    if inst.prefab ~= nil and neutral_attacker[inst.prefab] then
			inst.components.health:DoDelta(-(dmg * TUNING.SDF_STANDARD_MUNITIONS_PVP_DAMAGE_MULT), false, "minigunned", false, shooter, false)
		    else
			inst.components.health:DoDelta(-(dmg * TUNING.SDF_STANDARD_MUNITIONS_PVP_DAMAGE_MULT), false, "minigunned", false, inst, false)
		    end
		end
	    end
	end
    end
	
    --Work The Target
    if inst.components.workable ~= nil and inst.components.workable:CanBeWorked() and ((is_pvp and inst:HasTag("structure") or inst.prefab ~= nil and destroyableStructures[inst.prefab]) or (not is_pvp and not inst:HasTag("structure") or is_pvp) and minigun_actions[inst.components.workable:GetWorkAction()]) then
	local is_chop = inst.components.workable:GetWorkAction() == ACTIONS.CHOP
	if not is_chop or is_chop and self.inst.components.workable.workleft > 1 then
	    if inst:HasTag("structure") then
		inst.components.workable:WorkedBy(shooter, (TUNING.SDF_STANDARD_MUNITIONS_WORK_DAMAGE * TUNING.SDF_STANDARD_MUNITIONS_PVP_DAMAGE_MULT))
	    else
		inst.components.workable:WorkedBy(shooter, TUNING.SDF_STANDARD_MUNITIONS_WORK_DAMAGE)
	    end
	else
	    inst.components.workable:WorkedBy(shooter, 1)
	end
    end
	
    --Pick The Target --ADD a NOT LIST CHECK
    if inst.components.pickable and inst.components.pickable:CanBePicked() and inst.components.lootdropper then
	local num = inst.components.pickable.numtoharvest or 1
	local pt = inst:GetPosition()
	pt.y = pt.y + (inst.components.pickable.dropheight or 0)
	for i = 1, num do
	    inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product, pt)
	end
	inst.components.pickable:MakeEmpty()
    end

    --Apply the slowdown
    local debuffkey = bullet.prefab
    if inst.components.locomotor ~= nil then
	--slowing effect
	local movespeed_debuff = minigun ~= nil and minigun.components.sdf_gatling_gun_weapon ~= nil and minigun.components.sdf_gatling_gun_weapon.target_speed_mult or 1
	if inst._sdf_standard_munitions_movespeed_debufftask ~= nil then
	    inst._sdf_standard_munitions_movespeed_debufftask:Cancel()
	end
	inst._sdf_standard_munitions_movespeed_debufftask = inst:DoTaskInTime(TUNING.SDF_STANDARD_MUNITIONS_DEBUFF_DURATION, function(i) i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_standard_munitions_movespeed_debufftask = nil end)

	inst.components.locomotor:SetExternalSpeedMultiplier(inst, debuffkey, movespeed_debuff)
    end
	
    --Remove Munitions
    bullet:Remove()
end

return SDFGatling_Gun_Weapon_Target