local XP_CONFIG = {}
XP_CONFIG.BY_PREFAB = {
    stalker_atrium = 10,
    celestial_champion = 8,
    toadstool = 6,
    toadstool_dark = 10,
    klaus = 6,
    eyeofterror = 8,
    twinofterror1 = 8,
    twinofterror2 = 8,
    daywalker = 10,
    daywalker2 = 10,
    deerclops = 5,
    bearger = 5,
    moose = 5,
    dragonfly = 5,
    antlion = 5,
    crawlinghorror = 2,
    terrorbeak = 2,
    oceanhorror = 2,
    nightmarebeak = 2,
    crawlingnightmare = 2,
    ruinsnightmare = 2,
    minotaur = 5,
    shadow_rook = 3,
    shadow_knight = 3,
    shadow_bishop = 3,
    skeleton_player = 2,
    ghost = 1,
    krampus = 2,
}
XP_CONFIG.BY_TAG = {
    {tag = "shadowcreature",    xp = 2},
    {tag = "shadow",            xp = 1},
    {tag = "nightmare",         xp = 2},
    {tag = "epic",              xp = 5},
}
XP_CONFIG.EXCLUDED_TAGS = {
    "player",
    "companion",
    "abigail",
    "wall",
    "structure",
    "FX",
}
function XP_CONFIG.GetXPForVictim(victim)
    if not victim then
        return 0
    end
    for _, tag in ipairs(XP_CONFIG.EXCLUDED_TAGS) do
        if victim:HasTag(tag) then
            return 0
        end
    end
    local prefab = victim.prefab
    if prefab and XP_CONFIG.BY_PREFAB[prefab] ~= nil then
        return XP_CONFIG.BY_PREFAB[prefab]
    end
    for _, entry in ipairs(XP_CONFIG.BY_TAG) do
        if victim:HasTag(entry.tag) then
            return entry.xp
        end
    end
    return 0
end
return XP_CONFIG
