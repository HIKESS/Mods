-- SDFGatling_Gun_Weapon_Projectile is a component for handling gatling gun projectiles

local SDFGatling_Gun_Weapon_Projectile = Class(function(self, inst)
    self.inst = inst
	
    self.shooter_player = nil -- shooter_player is set by SDFGatling_Gun_Weapon component
    self.shooter_minigun = nil -- shooter_minigun is set by SDFGatling_Gun_Weapon component
	
    self.scanned_targets = {} -- k:entity, v:boolean - to exclude already scanned targets for later checks
    self.target_filters = {} -- k:string, v:function - functions (with boolean return type) to filter if entities can be targetted (shot by bullet; actual damage calculation is done by SDFGatling_Gun_Weapon_Target component)
	
    self.scan_range = 1.25
	

    self.excluded_target_tags = {"INLIMBO"}

    --What the Munitions can hit
    self.included_target_tags = {"insect", "smallcreature", "tentacle", "SDF_Totem_Target", "SDF_Floating_Target", "tentacle_pillar_arm", "animal",
	"monster", "epic", "hostile", "CHOP_workable", "MINE_workable", "HAMMER_workable", "structure", "pickable", "beehive", "playerskeleton",
	"character", "player", "bush", "SDF_Generic_Target", "_combat"}
	
    --Perform first, smaller scan immediately on spawn
    self.inst:DoTaskInTime(0, function(inst)
	if not inst.components.sdf_gatling_gun_weapon_projectile then
	    return
	end
		
	local pt = inst:GetPosition()
	local smaller_scan_range = self.scan_range * .8
	local entities = TheSim:FindEntities(pt.x, pt.y, pt.z, smaller_scan_range, nil, self.excluded_target_tags, self.included_target_tags)
	for i,entity in ipairs(entities) do
	    inst.components.sdf_gatling_gun_weapon_projectile:ScanAndPushShotIfValid(entity)
	end
    end)
	
    --Long-running scan task
    self.scan_task = self.inst:DoPeriodicTask(.1, function(inst)
	if not inst.components.sdf_gatling_gun_weapon_projectile then
	    return
	end
		
	local pt = inst:GetPosition()
	local entities = TheSim:FindEntities(pt.x, pt.y, pt.z, self.scan_range, nil, self.excluded_target_tags, self.included_target_tags)
	for i,entity in ipairs(entities) do
	    inst.components.sdf_gatling_gun_weapon_projectile:ScanAndPushShotIfValid(entity)
	end
    end)
end)

function SDFGatling_Gun_Weapon_Projectile:DeleteSelf()
    if self.scan_task ~= nil then
	self.scan_task:Cancel()
	self.scan_task = nil
    end
    self.inst:DoTaskInTime(0, self.inst.Remove)
end

function SDFGatling_Gun_Weapon_Projectile:PushShotOnTarget(entity)
    if not entity.components.sdf_gatling_gun_weapon_target then
	entity:AddComponent("sdf_gatling_gun_weapon_target")
    end
    entity.components.sdf_gatling_gun_weapon_target:GetShot(self.inst, self.shooter_player, self.shooter_minigun)
end

function SDFGatling_Gun_Weapon_Projectile:AddTargetFilter(filtername, filter)
    if type(filtername) ~= "string" or type(filter) ~= "function" then
	return
    end
    self.target_filters[filtername] = filter
end

function SDFGatling_Gun_Weapon_Projectile:AddScannedTarget(entity)
    if type(entity) ~= "table" then
	return
    end
    self.scanned_targets[entity] = true
end

function SDFGatling_Gun_Weapon_Projectile:WasTargetAlreadyScanned(entity)
    return self.scanned_targets[entity] ~= nil and self.scanned_targets[entity] == true or false
end

function SDFGatling_Gun_Weapon_Projectile:ScanTargetForValidity(entity)
    if entity == nil then
	return false
    end
	
    if self:WasTargetAlreadyScanned(entity) then
	return false
    end

    self:AddScannedTarget(entity)
	
    if not entity:IsValid() then
	return false
    end
	
    for fnname,fn in pairs(self.target_filters) do
	if fn(entity) == true then
	    return true
	end
    end
	
    return false
end

function SDFGatling_Gun_Weapon_Projectile:ScanAndPushShotIfValid(entity)
    if self:ScanTargetForValidity(entity) then
	self:PushShotOnTarget(entity)
    end
end

return SDFGatling_Gun_Weapon_Projectile