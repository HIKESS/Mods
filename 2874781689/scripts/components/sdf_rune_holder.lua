local SDFRune_Holder = Class(function (self,inst)
    self.inst=inst
    self.rune_time_enabled = false
    self.rune_moon_enabled = false
    self.rune_earth_enabled = false
    self.rune_star_enabled = false
    self.rune_chaos_enabled = false
    self.rune_moon_source = {"moonglass_rock"}
    self.rune_earth_source = {"stalagmite", "stalagmite_full", "stalagmite_tall", "stalagmite_tall_full"}
    self.rune_star_source = {"rock_moon"}
    self.rune_chaos_source = {"sdf_chaos_rock"}
end)


function SDFRune_Holder:CheckRuneStatus(runeType)
    if runeType == "sdf_time_rune" then
	return self.rune_time_enabled
    end
    if runeType == "sdf_moon_rune" then
	return self.rune_moon_enabled
    end
    if runeType == "sdf_earth_rune" then
	return self.rune_earth_enabled
    end
    if runeType == "sdf_star_rune" then
	return self.rune_star_enabled
    end
    if runeType == "sdf_chaos_rune" then
	return self.rune_chaos_enabled
    end
end

function SDFRune_Holder:EnableRuneStatus(runeType)
    if runeType == "sdf_time_rune" then
	self.rune_time_enabled = true
    end
    if runeType == "sdf_moon_rune" then
	self.rune_moon_enabled = true
    end
    if runeType == "sdf_earth_rune" then
	self.rune_earth_enabled = true
    end
    if runeType == "sdf_star_rune" then
	self.rune_star_enabled = true
    end
    if runeType == "sdf_chaos_rune" then
	self.rune_chaos_enabled = true
    end
end

function SDFRune_Holder:CanGatherRunes()
    if self.rune_moon_enabled == false or self.rune_earth_enabled == false or self.rune_star_enabled == false or self.rune_chaos_enabled == false then
	return true
    end
    return false
end

function SDFRune_Holder:CheckRuneSource(target, source)
    for k, v in pairs(source) do
	if target.prefab == v then
	    return true
	end
    end
    return false
end

function SDFRune_Holder:GetRuneMoonSource()
    return self.rune_moon_source
end

function SDFRune_Holder:GetRuneEarthSource()
    return self.rune_earth_source
end

function SDFRune_Holder:GetRuneStarSource()
    return self.rune_star_source
end

function SDFRune_Holder:GetRuneChaosSource()
    return self.rune_chaos_source
end

function SDFRune_Holder:CreateRune(player, target, runeType)
    local x, y, z = target.Transform:GetWorldPosition()
    local angle

    y = 4.5
    if player ~= nil and player:IsValid() then
	angle = 180 - player:GetAngleToPoint(x, 0, z)
    else
	local down = TheCamera:GetDownVec()
	angle = math.atan2(down.z, down.x) / DEGREES
    end

    --create rune
    local rune = SpawnPrefab(runeType)
    rune.Transform:SetPosition(x, y, z)

    --launch rune
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    rune.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

function SDFRune_Holder:OnSave()
    return{
	    rune_time_enabled=self.rune_time_enabled,
	    rune_moon_enabled=self.rune_moon_enabled,
	    rune_earth_enabled=self.rune_earth_enabled,
	    rune_star_enabled=self.rune_star_enabled,
	    rune_chaos_enabled=self.rune_chaos_enabled,
    }
end

function SDFRune_Holder:OnLoad(data)
    if data.rune_time_enabled ~= nil and self.rune_time_enabled ~= data.rune_time_enabled then
	self.rune_time_enabled = data.rune_time_enabled or false
    end
    if data.rune_moon_enabled ~= nil and self.rune_moon_enabled ~= data.rune_moon_enabled then
	self.rune_moon_enabled = data.rune_moon_enabled or false
    end
    if data.rune_earth_enabled ~= nil and self.rune_earth_enabled ~= data.rune_earth_enabled then
	self.rune_earth_enabled = data.rune_earth_enabled or false
    end
    if data.rune_star_enabled ~= nil and self.rune_star_enabled ~= data.rune_star_enabled then
	self.rune_star_enabled = data.rune_star_enabled or false
    end
    if data.rune_chaos_enabled ~= nil and self.rune_chaos_enabled ~= data.rune_chaos_enabled then
	self.rune_chaos_enabled = data.rune_chaos_enabled or false
    end
end

return SDFRune_Holder