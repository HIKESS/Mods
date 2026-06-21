local KodiTests = {}
KodiTests.results = {}
KodiTests.passed = 0
KodiTests.failed = 0
local function assert_true(condition, message)
    if not condition then
        KodiTests.failed = KodiTests.failed + 1
        return false
    end
    KodiTests.passed = KodiTests.passed + 1
    return true
end
local function assert_equal(expected, actual, message)
    if expected ~= actual then
        KodiTests.failed = KodiTests.failed + 1
        return false
    end
    KodiTests.passed = KodiTests.passed + 1
    return true
end
local function assert_range(value, min, max, message)
    if value < min or value > max then
        KodiTests.failed = KodiTests.failed + 1
        return false
    end
    KodiTests.passed = KodiTests.passed + 1
    return true
end
local function assert_not_nil(value, message)
    if value == nil then
        KodiTests.failed = KodiTests.failed + 1
        return false
    end
    KodiTests.passed = KodiTests.passed + 1
    return true
end
local function get_kodi()
    local player = ThePlayer or ConsoleCommandPlayer()
    if player and player.prefab == "kodi" then
        return player
    end
    return nil
end
local function test_section(name)
end
local function print_summary()
    if KodiTests.failed == 0 then
    else
    end
end
function KodiTests.test_tuning()
    test_section("TUNING Constants")
    assert_not_nil(TUNING.KODI_MAX_HP, "KODI_MAX_HP should be defined")
    assert_not_nil(TUNING.KODI_MAX_SANITY, "KODI_MAX_SANITY should be defined")
    assert_not_nil(TUNING.KODI_MAX_HUNGER, "KODI_MAX_HUNGER should be defined")
    assert_not_nil(TUNING.KODI_DAMAGEMULT, "KODI_DAMAGEMULT should be defined")
    assert_not_nil(TUNING.KODI_SPEED, "KODI_SPEED should be defined")
    assert_not_nil(TUNING.KODI_DAMAGEBLOCK, "KODI_DAMAGEBLOCK should be defined")
    assert_not_nil(TUNING.KODI_SPEEDTRANSFORM, "KODI_SPEEDTRANSFORM should be defined")
    assert_not_nil(TUNING.KODI_DAMAGETRANSFORM, "KODI_DAMAGETRANSFORM should be defined")
    assert_not_nil(TUNING.KODI_DEMONIC_MAX, "KODI_DEMONIC_MAX should be defined")
    assert_not_nil(TUNING.KODI_TRANSFORM_DURATION, "KODI_TRANSFORM_DURATION should be defined")
    assert_not_nil(TUNING.KODI_DEMONIC_DRAIN_RATE, "KODI_DEMONIC_DRAIN_RATE should be defined")
    assert_not_nil(TUNING.KODI_SHADOW_DASH_MAX_RANGE, "KODI_SHADOW_DASH_MAX_RANGE should be defined")
    assert_not_nil(TUNING.KODI_SHADOW_DASH_ENERGY_PER_TILE, "KODI_SHADOW_DASH_ENERGY_PER_TILE should be defined")
    assert_not_nil(TUNING.KODI_SHADOW_DASH_MIN_ENERGY, "KODI_SHADOW_DASH_MIN_ENERGY should be defined")
    assert_range(TUNING.KODI_MAX_HP, 50, 300, "KODI_MAX_HP reasonable range")
    assert_range(TUNING.KODI_DAMAGEMULT, 0.5, 2.0, "KODI_DAMAGEMULT reasonable range")
    assert_range(TUNING.KODI_SPEED, 0.8, 1.5, "KODI_SPEED reasonable range")
end
function KodiTests.test_shadow_dash_cost()
    test_section("Shadow Dash Energy Cost")
    local ShadowDash = require("skills/shadow_dash")
    local min_cost = ShadowDash.CalculateEnergyCost(1)
    assert_equal(TUNING.KODI_SHADOW_DASH_MIN_ENERGY, min_cost, "Short dash should use MIN_ENERGY")
    local far_cost = ShadowDash.CalculateEnergyCost(20)
    local expected = math.floor(20 * TUNING.KODI_SHADOW_DASH_ENERGY_PER_TILE)
    assert_equal(expected, far_cost, "Far dash should scale with distance")
    local max_cost = ShadowDash.CalculateEnergyCost(TUNING.KODI_SHADOW_DASH_MAX_RANGE)
    assert_range(max_cost, 10, 100, "Max range cost should be reasonable")
end
function KodiTests.test_shadow_dash_position()
    test_section("Shadow Dash Position Validation")
    local ShadowDash = require("skills/shadow_dash")
    if not TheWorld or not TheWorld.Map then
        return
    end
    local kodi = get_kodi()
    if not kodi then return end
    local x, y, z = kodi.Transform:GetWorldPosition()
    local valid, reason = ShadowDash.IsValidPosition(x, z)
    assert_true(valid, "Current position should be valid")
    local oob_valid, oob_reason = ShadowDash.IsValidPosition(99999, 99999)
    assert_true(not oob_valid, "Out of bounds should be invalid")
end
function KodiTests.test_transform_state()
    test_section("Transformation State")
    local kodi = get_kodi()
    if not kodi then return end
    assert_not_nil(kodi.GetDemonicPercent, "GetDemonicPercent should exist")
    local is_fox = kodi:HasTag("NotDemon")
    local is_demon = not is_fox
    local percent = kodi:GetDemonicPercent()
    assert_range(percent, 0, 1, "Demonic percent should be 0-1")
    assert_not_nil(kodi.TransformKodi, "TransformKodi should exist")
end
function KodiTests.test_transform_stats()
    test_section("Transformation Stats")
    local kodi = get_kodi()
    if not kodi then return end
    if kodi.components.health then
        local max_hp = kodi.components.health.maxhealth
        assert_equal(TUNING.KODI_MAX_HP, max_hp, "Max HP should match TUNING")
    end
    if kodi.components.sanity then
        local max_sanity = kodi.components.sanity.max
        assert_equal(TUNING.KODI_MAX_SANITY, max_sanity, "Max Sanity should match TUNING")
    end
    if kodi.components.hunger then
        local max_hunger = kodi.components.hunger.max
        assert_equal(TUNING.KODI_MAX_HUNGER, max_hunger, "Max Hunger should match TUNING")
    end
end
function KodiTests.test_skill_thresholds()
    test_section("Skill Tree Thresholds")
    assert_not_nil(TUNING.KODI_SKILL_THRESHOLDS, "KODI_SKILL_THRESHOLDS should exist")
    local thresholds = TUNING.KODI_SKILL_THRESHOLDS
    assert_true(#thresholds >= 10, "Should have at least 10 skill levels")
    local total = 0
    for i, threshold in ipairs(thresholds) do
        assert_true(threshold > 0, string.format("Threshold %d should be positive", i))
        total = total + threshold
    end
end
function KodiTests.test_skill_tags()
    test_section("Skill Tags")
    local kodi = get_kodi()
    if not kodi then return end
    local skill_tags = {
        "kodi_shadow_dash",
        "kodi_night_hunter",
        "kodi_day_stalker",
        "kodi_shadow_eruption",
        "kodi_shadow_cache",
        "kodi_shadow_summon",
    }
    for _, tag in ipairs(skill_tags) do
        local has = kodi:HasTag(tag)
    end
end
function KodiTests.test_night_hunter()
    test_section("Night Hunter")
    local kodi = get_kodi()
    if not kodi then return end
    if not kodi:HasTag("kodi_night_hunter") then
        return
    end
    assert_not_nil(kodi.MarkNightHunterTarget, "MarkNightHunterTarget should exist")
    assert_not_nil(kodi.LeapToMarkedTarget, "LeapToMarkedTarget should exist")
    assert_not_nil(kodi.ToggleNightHunterVision, "ToggleNightHunterVision should exist")
    if kodi.GetNightHunterLeapCooldown then
        local cooldown = kodi:GetNightHunterLeapCooldown()
        assert_range(cooldown, 0, 60, "Leap cooldown should be reasonable")
    end
end
function KodiTests.test_day_stalker()
    test_section("Day Stalker")
    local kodi = get_kodi()
    if not kodi then return end
    if not kodi:HasTag("kodi_day_stalker") then
        return
    end
    assert_not_nil(kodi.EnterDayStalkerStealth, "EnterDayStalkerStealth should exist")
    assert_not_nil(kodi.ExitDayStalkerStealth, "ExitDayStalkerStealth should exist")
    assert_not_nil(kodi.ToggleDayStalkerStealth, "ToggleDayStalkerStealth should exist")
    assert_not_nil(kodi.DayStalkerLeap, "DayStalkerLeap should exist")
    local in_stealth = kodi._day_stalker_stealth or false
end
function KodiTests.test_kodi_utils()
    test_section("KodiUtils")
    local KodiUtils = require("kodi_utils")
    local kodi = get_kodi()
    if kodi then
        assert_true(KodiUtils.IsValidEntity(kodi), "Kodi should be valid entity")
        assert_true(KodiUtils.IsKodi(kodi), "Should detect Kodi")
        assert_true(KodiUtils.IsAlive(kodi), "Kodi should be alive")
    end
    assert_true(not KodiUtils.IsValidEntity(nil), "nil should not be valid")
    assert_true(not KodiUtils.IsKodi(nil), "nil should not be Kodi")
    local phase = KodiUtils.GetWorldPhase()
    local is_master = KodiUtils.IsMasterSim()
end
function KodiTests.test_netvars()
    test_section("Network Variables")
    local kodi = get_kodi()
    if not kodi then return end
    assert_not_nil(kodi.demonic_energy, "demonic_energy netvar should exist")
    if kodi._night_hunter_marks_count then
    end
end
function KodiTests.run(test_name)
    KodiTests.passed = 0
    KodiTests.failed = 0
    local fn = KodiTests["test_" .. test_name]
    if fn then
        local success, err = pcall(fn)
        if not success then
            KodiTests.failed = KodiTests.failed + 1
        end
        print_summary()
    else
        for name, _ in pairs(KodiTests) do
            if name:sub(1, 5) == "test_" then
            end
        end
    end
end
function KodiTests.run_all()
    KodiTests.passed = 0
    KodiTests.failed = 0
    local tests = {
        "tuning",
        "shadow_dash_cost",
        "shadow_dash_position",
        "transform_state",
        "transform_stats",
        "skill_thresholds",
        "skill_tags",
        "night_hunter",
        "day_stalker",
        "kodi_utils",
        "netvars",
    }
    for _, test_name in ipairs(tests) do
        local fn = KodiTests["test_" .. test_name]
        if fn then
            local success, err = pcall(fn)
            if not success then
                KodiTests.failed = KodiTests.failed + 1
            end
        end
    end
    print_summary()
end
return KodiTests
