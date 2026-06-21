-- SDF_Gatling_Gun_Weapon is a component for handling gatling gun

local function UpdateRechargeMeter(inst)
    inst:PushEvent("rechargechange", {percent = inst.components.sdf_gatling_gun_weapon.cooldown})
end

local SDFGatling_Gun_Weapon = Class(function(self, inst)
    self.inst = inst
    self.projectile = "sdf_standard_munitions_proj"
    self.deviation = 2
    self.damage = TUNING.SDF_STANDARD_MUNITIONS_DAMAGE
    self.target_speed_mult = TUNING.SDF_STANDARD_MUNITIONS_MOVESPEED_DEBUFF
    self.usage = TUNING.SDF_GATLING_GUN_USAGE

    self.onrevvedupfn = nil -- (inst, data) --data--> {weapon, shooter, no_interrupt}
    self.onrevveddownfn = nil -- (inst, data) --data--> {weapon, shooter}
    self.onshootfn = nil -- self.inst, shooter

    self.cooldown = 1
    self.cooldown_max = 1
    self.cooldown_min = 0
	
    --Overheat per bullet shot
    self.overheat_usage = TUNING.SDF_GATLING_GUN_OVERHEAT_USAGE

    --Overheat cooldowns automatically per second
    self.overheat_cooldown_rate = TUNING.SDF_GATLING_GUN_OVERHEAT_COOLDOWN_RATE

    if not self.inst:HasTag("rechargeable") then
	self.inst:AddTag("rechargeable")
    end
	
    --Overheat Cooldown
    self.rechargetask = self.inst:DoPeriodicTask(1, function(inst)
	local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner ~= nil and inst.components.inventoryitem.owner
	local equipped = inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() and true or false
			
	--Cooldown only when not shooting
	if not equipped or owner == nil or equipped and owner ~= nil and owner.sg and owner.sg.currentstate.name ~= "sdfgatling_gun_shoot" then
	    local newpercent = (self.cooldown + self.overheat_cooldown_rate) < self.cooldown_max and self.cooldown + self.overheat_cooldown_rate or 			    self.cooldown_max
	    self.cooldown = newpercent
				
	    if not self:IsEmpty() and inst:HasTag("sdf_gatling_gun_empty") then
		inst:RemoveTag("sdf_gatling_gun_empty")
	    end
				
	    inst:PushEvent("rechargechange", {percent = newpercent})
	end
    end)
end)

function SDFGatling_Gun_Weapon:SetCooldownRechargeAmount(amt)
    self.overheat_cooldown_rate = amt
end

function SDFGatling_Gun_Weapon:GetCurrentCooldownValue()
    return self.cooldown
end

function SDFGatling_Gun_Weapon:SetCurrentCooldownValue(cooldown)
    self.cooldown = cooldown
	
    if not self:IsEmpty() and self.inst:HasTag("sdf_gatling_gun_empty") then
	self.inst:RemoveTag("sdf_gatling_gun_empty")
    end
	
    self.inst:PushEvent("rechargechange", {percent = cooldown})
end

function SDFGatling_Gun_Weapon:GetDamage()
    return self.damage
end

function SDFGatling_Gun_Weapon:SetDamage(value)
    self.damage = value
end

function SDFGatling_Gun_Weapon:SetOnShootFn(fn)
    self.onshootfn = fn
end

function SDFGatling_Gun_Weapon:SetOnRevvedUpFn(fn)
    self.onrevvedupfn = fn
    self.inst:ListenForEvent("revved_up", self.onrevvedupfn)
end

function SDFGatling_Gun_Weapon:SetOnRevvedDownFn(fn)
    self.onrevveddownfn = fn
	
    self.inst:ListenForEvent("revved_down", self.onrevveddownfn)
	
    local function wrapperFn(inst, data)
	local newdata = { weapon = inst, shooter = nil }
		
	if data.owner ~= nil then
	    newdata = { weapon = inst, shooter = data.owner }
	end
		
	fn(inst, newdata)
    end
    self.inst:ListenForEvent("unequipped", wrapperFn)
end

function SDFGatling_Gun_Weapon:GetShooter()
    local inv = self.inst ~= nil and self.inst.components ~= nil and self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem or nil
    local owner = inv ~= nil and inv:IsHeld() and inv:GetGrandOwner() or nil
    local equipped = self.inst ~= nil and self.inst.components ~= nil and self.inst.components.equippable ~= nil and self.inst.components.equippable:IsEquipped() and true or false
	
    if owner ~= nil and equipped then
	return owner
    else
	return nil
    end
end

function SDFGatling_Gun_Weapon:GetGatlingGunAmmo()
    local shooter = self:GetShooter()
    local owner_inv = shooter ~= nil and (shooter.components.inventory ~= nil and shooter.components.inventory or shooter.replica.inventory ~= nil and shooter.replica.inventory) or nil
    local hand_item = owner_inv ~= nil and owner_inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and owner_inv:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    local ammo = hand_item ~= nil and hand_item:HasTag("sdf_gatling_gun") and hand_item.components.container:GetItemInSlot(1) or nil
	
    if shooter ~= nil and ammo ~= nil and ammo:HasTag("sdf_gatling_gun_ammo") then
	return ammo
    else
	return nil
    end
end

function SDFGatling_Gun_Weapon:ConsumeAmmo(amount)
    local to_consume = self.overheat_usage
    local new_percent = (self.cooldown - to_consume) > self.cooldown_min and self.cooldown - to_consume or self.cooldown_min

    local owner = self:GetShooter()
    local ammo = self:GetGatlingGunAmmo()

    --Consume Standard Munitions
    if ammo ~= nil then
	--ammo.components.finiteuses:Use(TUNING.SDF_STANDARD_MUNITIONS_USAGE)
	ammo:PushEvent("sdf_gatling_gun_consume_ammo", {gatlingGun = self.inst, shooter = owner})
    end

    --Apply Overheat
    self.cooldown = new_percent
    self.inst:PushEvent("rechargechange", {percent = new_percent})

    --Damage Gatling Gun
    self.inst.components.finiteuses:Use(amount)

    --Custom on overheat fn
    if self.cooldown < self.overheat_usage then
	if not self.inst:HasTag("sdf_gatling_gun_empty") then
	    self.inst:AddTag("sdf_gatling_gun_empty")
	end
    end
end

local function getdistancemult(distance)
    local dist_mult = distance < 16 and 0.95 or 1
    dist_mult = distance < 10 and 0.9 or dist_mult
    dist_mult = distance < 6.5 and 0.8 or dist_mult
    dist_mult = distance < 5 and 0.7 or dist_mult
    dist_mult = distance < 4 and 0.6 or dist_mult
    dist_mult = distance < 3 and 0.4 or dist_mult
    dist_mult = distance < 2 and 0.25 or dist_mult
    dist_mult = distance < 1 and 0.12 or dist_mult
    dist_mult = distance < 0.05 and 0.09 or dist_mult
    return dist_mult
end

local function SetDeviatedDirection(proj, dest, deviation)
    local direction = (dest - proj:GetPosition()):GetNormalized()
    local angle = (math.acos(direction:Dot(Vector3(1, 0, 0)))) / DEGREES
    proj.Transform:SetRotation(angle)

    local distance = proj:GetDistanceSqToPoint(dest.x, dest.y, dest.z)
    local percent = distance / 2000
    local deviation_recalc = RoundBiasedUp((deviation * percent), 2) * 10
	
    -- Manipulate the deviation if we are really close to the player...
    deviation_recalc = deviation_recalc <= 0.5 and deviation_recalc > 0.1 and 0.6 or deviation_recalc
    deviation_recalc = deviation_recalc == 0.1 and 0.55 or deviation_recalc
    deviation_recalc = deviation_recalc <= 0.1 and deviation_recalc > 0.05 and 0.51 or deviation_recalc
    deviation_recalc = deviation_recalc <= 0.05 and 0.505 or deviation_recalc
	
    local rand_1 = 0
    local rand_2 = 0
	
    rand_1 = math.random(-deviation_recalc, deviation_recalc)
    rand_2 = math.random(-deviation_recalc, deviation_recalc)
		
    if rand_1 == 0 then
	local dist_mult = getdistancemult(distance)
	if math.random() > 0.5 then
	    rand_1 = deviation_recalc * dist_mult
	else
	    rand_1 = -deviation_recalc * dist_mult
	end
			
	if math.random() > 0.5 then
	    rand_1 = rand_1 * 0.5
	end
    end
		
    if rand_2 == 0 then
	local dist_mult = getdistancemult(distance)
	if math.random() > 0.5 then
	    rand_2 = deviation_recalc * dist_mult
	else
	    rand_2 = -deviation_recalc * dist_mult
	end
			
	if math.random() > 0.5 then
	    rand_2 = rand_2 * 0.5
	end
    end
	
    local x = dest.x + (rand_1 * TUNING.SDF_STANDARD_MUNITIONS_BULLETSPREAD_INTENSITY)
    local z = dest.z + (rand_2 * TUNING.SDF_STANDARD_MUNITIONS_BULLETSPREAD_INTENSITY)
	
    proj:FacePoint(x, dest.y, z)
end

local function ShootProjectile(attacker, pt, proj, deviation, shooter, minigun)
    local proj = SpawnPrefab(proj)
    if proj ~= nil and proj.components.projectile ~= nil then
	local atk = attacker:GetPosition()
	local y_offset = 0.5

	local dir = (Vector3(pt.x, pt.y, pt.z) - attacker:GetPosition()):Normalize()
	dir = dir * 1.1
	proj.Transform:SetPosition(atk.x + dir.x, atk.y + y_offset, atk.z + dir.z)
		
	proj.components.sdf_gatling_gun_weapon_projectile.shooter_player = shooter
	proj.components.sdf_gatling_gun_weapon_projectile.shooter_minigun = minigun
		
	proj.Physics:ClearCollidesWith(COLLISION.LIMITS)
	SetDeviatedDirection(proj, pt, deviation)
	proj.Physics:SetMotorVel(21, 0, 0)	
    end
end

function SDFGatling_Gun_Weapon:Shoot(pt, target, shooter)
    --Overheated
    if self.cooldown < self.overheat_usage then
	if not self.inst:HasTag("sdf_gatling_gun_empty") then
	    self.inst:AddTag("sdf_gatling_gun_empty")
	end
	return false
    end

    --Out of Munitions
    if self:GetGatlingGunAmmo() == nil then
	if not self.inst:HasTag("sdf_gatling_gun_empty") then
	    self.inst:AddTag("sdf_gatling_gun_empty")
	end
	return false
    end

    --Shoot Gatling Gun
    if pt then
	ShootProjectile(self.inst, pt, self.projectile, self.deviation, shooter, self.inst)
    elseif target then
	local point = target:GetPosition()
	ShootProjectile(self.inst, point, self.projectile, self.deviation, shooter, self.inst)
    end

    --Consume Standard Munitions/ Apply Overheat/ Damage Gatling Gun.
    self:ConsumeAmmo(self.usage)
	
    if self.onshootfn ~= nil then
	self.onshootfn(self.inst, shooter)
    end
end

function SDFGatling_Gun_Weapon:IsFull()
    return self.cooldown >= self.cooldown_max
end

-- Automatic weapon is "empty" if it does not have enough charge to fire a single bullet
function SDFGatling_Gun_Weapon:IsEmpty()
    return self.cooldown < self.overheat_usage
end

function SDFGatling_Gun_Weapon:LongUpdate(dt)
    local new_cd = self.cooldown + (self.overheat_cooldown_rate * dt)
    if new_cd > self.cooldown_max then
	new_cd = self.cooldown_max
    end
    self.cooldown = new_cd
    self.inst:PushEvent("rechargechange", {percent = new_cd})
end

function SDFGatling_Gun_Weapon:OnSave()
    return {
	cooldown = self.cooldown,
    }
end

function SDFGatling_Gun_Weapon:OnLoad(data)
    if data then
	if data.cooldown then
	    self.cooldown = data.cooldown
	end
    end
end

return SDFGatling_Gun_Weapon