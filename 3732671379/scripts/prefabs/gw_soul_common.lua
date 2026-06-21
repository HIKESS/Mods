local fns

local function DoHeal(inst)
    local damagetargets = {}
    local damagetargetscount = 0
    local x, y, z = inst.Transform:GetWorldPosition()
    local rangesq = TUNING.WORTOX_SOULHEAL_RANGE + (inst.soul_heal_range_modifier or 0)
    rangesq = rangesq * rangesq
    for i, v in ipairs(AllPlayers) do
        if not (v.components.health:IsDead() or v:HasTag("playerghost")) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < rangesq then
            table.insert(damagetargets, v)
            damagetargetscount = damagetargetscount + 1
        end
    end
    
    if damagetargetscount > 0 then
        local damage_amt = 5
        for i = 1, damagetargetscount do
            local v = damagetargets[i]
            v.components.health:DoDelta(-damage_amt, nil, inst.prefab)
            if v.components.combat then
                local fx = SpawnPrefab("halloween_firepuff_cold_2")
                fx.entity:AddFollower():FollowSymbol(v.GUID, v.components.combat.hiteffectsymbol, 0, -10, 0)
                -- fx:Setup(v)
            end
        end
    end
end

local function HasSoul(victim)
	return (	(victim.components.combat ~= nil and victim.components.health ~= nil) or
				victim.components.murderable ~= nil
			)
		and not victim:HasAnyTag(SOULLESS_TARGET_TAGS)
end

local function GetNumSouls(victim)
    if victim and victim:IsValid() and victim.components.health then
        local maxhealth = victim.components.health.maxhealth
        
        if maxhealth >= 2000 then
            local baseSouls = 1
            local extraSouls = math.floor((maxhealth - 2000) / 500)
            local totalSouls = baseSouls + extraSouls
            return math.min(totalSouls, 10)
        else
            if math.random() <= 0.5 then
                return 1
            else
                return 0
            end
        end
    end
    return 0
end

local function ShouldSpawnSoul(victim)
    if victim and victim:IsValid() and victim.components.health then
        local maxhealth = victim.components.health.maxhealth
        
        if maxhealth >= 2000 then
            return true
        else
            return math.random() <= 0.5
        end
    end
    return false
end

local function SpawnSoulAt(x, y, z, victim, marksource)
    local fx = SpawnPrefab("gw_soul_ball")
    if marksource then
        fx._soulsource = victim and victim._soulsource or nil
    end
    fx.Transform:SetPosition(x, y, z)
    fx:Setup(victim)
    
end


local function SpawnSoulsAt(victim, numsouls)
    if not ShouldSpawnSoul(victim) then
        return
    end
    
    local actualNumSouls = numsouls or GetNumSouls(victim)
    
    if actualNumSouls <= 0 then
        return
    end
    
    local x, y, z = victim.Transform:GetWorldPosition()
    if actualNumSouls == 2 then
        local theta = math.random() * TWOPI
        local radius = .4 + math.random() * .1
        fns.SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim, true)
        theta = GetRandomWithVariance(theta + PI, PI / 15)
        fns.SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim, false) -- NOTES(JBK): Only one guarantee.
    else
        fns.SpawnSoulAt(x, y, z, victim, true)
        if actualNumSouls > 1 then
            local extraSouls = actualNumSouls - 1
            local theta0 = math.random() * TWOPI
            local dtheta = TWOPI / extraSouls
            local thetavar = dtheta / 10
            local theta, radius
            for i = 1, extraSouls do
                theta = GetRandomWithVariance(theta0 + dtheta * i, thetavar)
                radius = 1.6 + math.random() * .4
                fns.SpawnSoulAt(x + math.cos(theta) * radius, 0, z - math.sin(theta) * radius, victim, false) -- NOTES(JBK): Only one guarantee.
            end
        end
    end
end

fns = {
    DoHeal = DoHeal,
    HasSoul = HasSoul,
    GetNumSouls = GetNumSouls,
    ShouldSpawnSoul = ShouldSpawnSoul,
    SpawnSoulAt = SpawnSoulAt,
    SpawnSoulsAt = SpawnSoulsAt,
}

return fns