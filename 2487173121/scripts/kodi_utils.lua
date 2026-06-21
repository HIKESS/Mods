local KodiUtils = {}
function KodiUtils.IsValidEntity(ent)
    return ent ~= nil and ent:IsValid()
end
function KodiUtils.IsAlive(ent)
    if not KodiUtils.IsValidEntity(ent) then
        return false
    end
    if ent:HasTag("playerghost") or ent:HasTag("dead") then
        return false
    end
    if ent.components and ent.components.health then
        return not ent.components.health:IsDead()
    end
    return true
end
function KodiUtils.IsValidTarget(ent)
    if not KodiUtils.IsValidEntity(ent) then
        return false
    end
    if ent:HasTag("FX") or ent:HasTag("NOCLICK") or ent:HasTag("DECOR") then
        return false
    end
    if ent:HasTag("INLIMBO") or ent:HasTag("invisible") then
        return false
    end
    return true
end
function KodiUtils.IsValidCombatTarget(ent, attacker)
    if not KodiUtils.IsValidTarget(ent) then
        return false
    end
    if not KodiUtils.IsAlive(ent) then
        return false
    end
    if ent:HasTag("wall") or ent:HasTag("structure") then
        return false
    end
    if not ent.components or not ent.components.health then
        return false
    end
    return true
end
function KodiUtils.HasComponent(inst, component_name)
    return inst ~= nil and inst.components ~= nil and inst.components[component_name] ~= nil
end
function KodiUtils.GetComponent(inst, component_name)
    if KodiUtils.HasComponent(inst, component_name) then
        return inst.components[component_name]
    end
    return nil
end
function KodiUtils.CallComponent(inst, component_name, method_name, ...)
    local comp = KodiUtils.GetComponent(inst, component_name)
    if comp and comp[method_name] then
        return comp[method_name](comp, ...)
    end
    return nil
end
function KodiUtils.SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return false, "Not a function"
    end
    local status, result = pcall(fn, ...)
    return status, result
end
function KodiUtils.SafeCallOrDefault(fn, default, ...)
    local status, result = KodiUtils.SafeCall(fn, ...)
    if status then
        return result
    end
    return default
end
function KodiUtils.HasAnyTag(inst, tags)
    if not KodiUtils.IsValidEntity(inst) then
        return false
    end
    for _, tag in ipairs(tags) do
        if inst:HasTag(tag) then
            return true
        end
    end
    return false
end
function KodiUtils.HasAllTags(inst, tags)
    if not KodiUtils.IsValidEntity(inst) then
        return false
    end
    for _, tag in ipairs(tags) do
        if not inst:HasTag(tag) then
            return false
        end
    end
    return true
end
function KodiUtils.IsKodi(inst)
    return KodiUtils.IsValidEntity(inst) and inst.prefab == "kodi"
end
function KodiUtils.IsFoxForm(inst)
    return KodiUtils.IsKodi(inst) and inst:HasTag("NotDemon")
end
function KodiUtils.IsDemonForm(inst)
    return KodiUtils.IsKodi(inst) and not inst:HasTag("NotDemon")
end
function KodiUtils.HasSkill(inst, skill_tag)
    return KodiUtils.IsKodi(inst) and inst:HasTag(skill_tag)
end
function KodiUtils.CanUseAbility(inst)
    if not KodiUtils.IsKodi(inst) then
        return false
    end
    if not KodiUtils.IsAlive(inst) then
        return false
    end
    if inst.sg and inst.sg:HasStateTag("busy") then
        return false
    end
    return true
end
function KodiUtils.DistSq(ent1, ent2)
    if not KodiUtils.IsValidEntity(ent1) or not KodiUtils.IsValidEntity(ent2) then
        return math.huge
    end
    local x1, y1, z1 = ent1.Transform:GetWorldPosition()
    local x2, y2, z2 = ent2.Transform:GetWorldPosition()
    return (x2 - x1) * (x2 - x1) + (z2 - z1) * (z2 - z1)
end
function KodiUtils.Dist(ent1, ent2)
    return math.sqrt(KodiUtils.DistSq(ent1, ent2))
end
function KodiUtils.InRange(ent1, ent2, range)
    return KodiUtils.DistSq(ent1, ent2) <= range * range
end
function KodiUtils.IsMasterSim()
    return TheWorld ~= nil and TheWorld.ismastersim == true
end
function KodiUtils.GetWorldPhase()
    if TheWorld and TheWorld.state then
        return TheWorld.state.phase
    end
    return nil
end
function KodiUtils.IsNight()
    local phase = KodiUtils.GetWorldPhase()
    return phase == "night"
end
function KodiUtils.IsNightOrDusk()
    local phase = KodiUtils.GetWorldPhase()
    return phase == "night" or phase == "dusk"
end
function KodiUtils.IsCave()
    return TheWorld ~= nil and TheWorld:HasTag("cave")
end
function KodiUtils.IsPassableAt(x, y, z)
    if TheWorld and TheWorld.Map then
        return TheWorld.Map:IsPassableAtPoint(x, y, z)
    end
    return false
end
function KodiUtils.GetHounded()
    if TheWorld and TheWorld.components then
        return TheWorld.components.hounded
    end
    return nil
end
function KodiUtils.IsHoundWarning()
    local hounded = KodiUtils.GetHounded()
    if hounded then
        return hounded:GetWarning() or hounded:GetAttacking()
    end
    return false
end
KodiUtils.DEBUG = {
    ENABLED = false,
    SKILLS = false,
    TRANSFORM = false,
    COMBAT = false,
    NETWORK = false,
    TARGETING = false,
    SKILLTREE = false,
    ENERGY = false,
    MINIONS = false,
}
function KodiUtils.DebugLog(category, message, ...)
    if not KodiUtils.DEBUG.ENABLED then return end
    if category and not KodiUtils.DEBUG[category] then return end
    local formatted = string.format("[Kodi/%s] " .. message, category or "DEBUG", ...)
end
function KodiUtils.IsDebugEnabled(category)
    return KodiUtils.DEBUG.ENABLED and (not category or KodiUtils.DEBUG[category])
end
function KodiUtils.SetDebug(category, enabled)
    if category then
        KodiUtils.DEBUG[category] = enabled
    else
        KodiUtils.DEBUG.ENABLED = enabled
    end
end
function KodiUtils.InitDebugFromTuning(TUNING)
    if TUNING.KODI_DEBUG then
        KodiUtils.DEBUG.ENABLED = true
    end
    if TUNING.KODI_DEBUG_SKILLTREE then
        KodiUtils.DEBUG.ENABLED = true
        KodiUtils.DEBUG.SKILLTREE = true
    end
    if TUNING.KODI_DEBUG_TARGETING then
        KodiUtils.DEBUG.ENABLED = true
        KodiUtils.DEBUG.TARGETING = true
    end
    if TUNING.KODI_DEBUG_TRANSFORM then
        KodiUtils.DEBUG.ENABLED = true
        KodiUtils.DEBUG.TRANSFORM = true
    end
    if TUNING.KODI_DEBUG_COMBAT then
        KodiUtils.DEBUG.ENABLED = true
        KodiUtils.DEBUG.COMBAT = true
    end
end
return KodiUtils
