-- Clientside component for storing assets of Gatling Gun
local SDFGatling_Gun_Weapon_Asset_Wrangler = Class(function(self, inst)
    self.inst = inst
	
	self.anims = {
		--["equip"] = "sdfgatlinggun_equip",
		--["revved"] = "sdfgatlinggun_shoot_pre",
		--["shooting"] = "sdfgatlinggun_shoot",
		--["shooting_empty"] = "sdfgatlinggun_shoot_empty",

		["equip"] = "tf2minigun_equip",
		["revved"] = "tf2minigun_shoot_pre",
		["shooting"] = "tf2minigun_shoot",
		["shooting_empty"] = "tf2minigun_shoot_empty",
	}
	
	self.sounds = {
		["rev_start"] = "dontstarve/characters/tf2heavy/tf2minigun_rev_start",
		["revved"] = "dontstarve/characters/tf2heavy/tf2minigun_revved",
		["rev_end"] = "dontstarve/characters/tf2heavy/tf2minigun_rev_end",
		["shooting"] = "dontstarve/characters/tf2heavy/tf2minigun_shoot",
		["shooting_empty"] = "dontstarve/characters/tf2heavy/tf2minigun_empty",
	}
end)

-- Setters
function SDFGatling_Gun_Weapon_Asset_Wrangler:SetAnimTable(animTable)
	self.anims = animTable
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:SetSoundTable(soundTable)
	self.sounds = soundTable
end

-- Animations
function SDFGatling_Gun_Weapon_Asset_Wrangler:GetEquipAnim()
	return self.anims["equip"]
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:GetRevvedAnim()
	return self.anims["revved"]
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:GetShootingAnim()
	return self.anims["shooting"]
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:GetShootingEmptyAnim()
	return self.anims["shooting_empty"]
end

-- Sounds
function SDFGatling_Gun_Weapon_Asset_Wrangler:GetRevStartSound()
	return self.sounds["rev_start"]
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:GetRevvedSound()
	return self.sounds["revved"]
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:GetRevEndSound()
	return self.sounds["rev_end"]
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:GetShootingSound()
	return self.sounds["shooting"]
end

function SDFGatling_Gun_Weapon_Asset_Wrangler:GetShootingEmptySound()
	return self.sounds["shooting_empty"]
end


return SDFGatling_Gun_Weapon_Asset_Wrangler
