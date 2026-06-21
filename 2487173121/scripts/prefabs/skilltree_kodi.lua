local COL1_X = -214
local COL2_X = -62
local COL3_X = 66
local COL4_X = 204
local TOP_Y = 176
local STEP_Y = 38
local STEP_X = 38
local HEALTH_BONUS_PERCENT = 0.15
local SPEED_BONUS_MULT = 1.02
local NIGHT_SPEED_BONUS = 1.03
local COLD_INSULATION_BONUS = 60
local FREEZE_RESIST_BONUS = 3
local function GetHealthBonus()
    local base_hp = TUNING.KODI_MAX_HP or TUNING.KODI_HEALTH or 150
    return math.floor(base_hp * HEALTH_BONUS_PERCENT)
end
local ORDERS =
{
    {"kodi_fox",        { COL1_X + 18, TOP_Y + 30 }},
    {"kodi_demon",      { COL2_X,      TOP_Y + 30 }},
    {"kodi_survival",   { COL3_X + 18, TOP_Y + 30 }},
    {"kodi_allegiance", { COL4_X,      TOP_Y + 30 }},
}
local BACKGROUND_SETTINGS = {}
local function BuildSkillsData(SkillTreeFns)
    local KODI = STRINGS.SKILLTREE and STRINGS.SKILLTREE.KODI or {}
    local skills = {
        kodi_fox_speed_1 = {
            title = KODI.FOX_SPEED_1_TITLE or "Swift Fox I",
            desc = KODI.FOX_SPEED_1_DESC or "Increases movement speed by 2%.",
            icon = "fast_fox",
            pos = {COL1_X, TOP_Y},
            group = "kodi_fox",
            tags = {"fox", "fox_main"},
            root = true,
            defaultfocus = true,
            connects = {"kodi_fox_speed_2"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_speed_1")
                if inst.components.locomotor then
                    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_skill_speed_1", SPEED_BONUS_MULT)
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_speed_1")
                if inst.components.locomotor then
                    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_skill_speed_1")
                end
            end,
        },
        kodi_fox_speed_2 = {
            title = KODI.FOX_SPEED_2_TITLE or "Swift Fox II",
            desc = KODI.FOX_SPEED_2_DESC or "Increases movement speed by additional 2%.",
            icon = "fast_fox2",
            pos = {COL1_X, TOP_Y - STEP_Y},
            group = "kodi_fox",
            tags = {"fox", "fox_main"},
            connects = {"kodi_fox_speed_3"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_speed_2")
                if inst.components.locomotor then
                    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_skill_speed_2", SPEED_BONUS_MULT)
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_speed_2")
                if inst.components.locomotor then
                    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_skill_speed_2")
                end
            end,
        },
        kodi_fox_speed_3 = {
            title = KODI.FOX_SPEED_3_TITLE or "Swift Fox III",
            desc = KODI.FOX_SPEED_3_DESC or "Increases movement speed by additional 2%. +3% bonus speed at night.",
            icon = "fast_fox3",
            pos = {COL1_X, TOP_Y - STEP_Y * 2},
            group = "kodi_fox",
            tags = {"fox", "fox_main"},
            connects = {"kodi_fox_lock"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_speed_3")
                if inst.components.locomotor then
                    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_skill_speed_3", SPEED_BONUS_MULT)
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_speed_3")
                if inst.components.locomotor then
                    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_skill_speed_3")
                    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_skill_speed_night")
                end
            end,
        },
        kodi_fox_cold_1 = {
            title = KODI.FOX_COLD_1_TITLE or "Winter Coat I",
            desc = KODI.FOX_COLD_1_DESC or "Fur provides +60 cold insulation.",
            icon = "fluffy_fur",
            pos = {COL1_X + STEP_X, TOP_Y},
            group = "kodi_fox",
            tags = {"fox", "fox_main"},
            root = true,
            connects = {"kodi_fox_cold_2"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_cold_1")
                if inst.components.temperature then
                    inst.components.temperature.inherentinsulation = (inst.components.temperature.inherentinsulation or 0) + COLD_INSULATION_BONUS
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_cold_1")
                if inst.components.temperature then
                    inst.components.temperature.inherentinsulation = (inst.components.temperature.inherentinsulation or COLD_INSULATION_BONUS) - COLD_INSULATION_BONUS
                end
            end,
        },
        kodi_fox_cold_2 = {
            title = KODI.FOX_COLD_2_TITLE or "Winter Coat II",
            desc = KODI.FOX_COLD_2_DESC or "Fur provides additional +60 cold insulation.",
            icon = "fluffy_fur2",
            pos = {COL1_X + STEP_X, TOP_Y - STEP_Y},
            group = "kodi_fox",
            tags = {"fox", "fox_main"},
            connects = {"kodi_fox_cold_3"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_cold_2")
                if inst.components.temperature then
                    inst.components.temperature.inherentinsulation = (inst.components.temperature.inherentinsulation or 0) + COLD_INSULATION_BONUS
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_cold_2")
                if inst.components.temperature then
                    inst.components.temperature.inherentinsulation = (inst.components.temperature.inherentinsulation or COLD_INSULATION_BONUS) - COLD_INSULATION_BONUS
                end
            end,
        },
        kodi_fox_cold_3 = {
            title = KODI.FOX_COLD_3_TITLE or "Winter Coat III",
            desc = KODI.FOX_COLD_3_DESC or "+60 cold insulation. High freeze resistance. 50% water resistance.",
            icon = "fluffy_fur3",
            pos = {COL1_X + STEP_X, TOP_Y - STEP_Y * 2},
            group = "kodi_fox",
            tags = {"fox", "fox_main"},
            connects = {"kodi_fox_lock"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_cold_3")
                if inst.components.temperature then
                    inst.components.temperature.inherentinsulation = (inst.components.temperature.inherentinsulation or 0) + COLD_INSULATION_BONUS
                end
                if inst.components.freezable then
                    inst.components.freezable:SetResistance(inst.components.freezable.resistance + FREEZE_RESIST_BONUS)
                end
                if inst.components.moisture then
                    inst._kodi_original_moisture_rate = inst.components.moisture.maxMoistureRate
                    inst.components.moisture.maxMoistureRate = inst.components.moisture.maxMoistureRate * 0.5
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_cold_3")
                if inst.components.temperature then
                    inst.components.temperature.inherentinsulation = (inst.components.temperature.inherentinsulation or COLD_INSULATION_BONUS) - COLD_INSULATION_BONUS
                end
                if inst.components.freezable then
                    inst.components.freezable:SetResistance(math.max(1, inst.components.freezable.resistance - FREEZE_RESIST_BONUS))
                end
                if inst.components.moisture and inst._kodi_original_moisture_rate then
                    inst.components.moisture.maxMoistureRate = inst._kodi_original_moisture_rate
                    inst._kodi_original_moisture_rate = nil
                end
            end,
        },
        kodi_fox_lock = {
            desc = KODI.FOX_LOCK_DESC or "Requires 3 Fox skills.",
            pos = {COL1_X + 18, 55 + STEP_Y / 3},
            group = "kodi_fox",
            tags = {"fox", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local fox_main_count = SkillTreeFns.CountTags(prefabname, "fox_main", activatedskills)
                return fox_main_count >= 3
            end,
            connects = {"kodi_fox_lock_day_excl", "kodi_fox_lock_night_excl"},
        },
        kodi_fox_lock_day_excl = {
            desc = KODI.FOX_LOCK_NIGHT_DESC or "Cannot be Night Hunter.",
            pos = {COL1_X - 4, 35 + STEP_Y / 3},
            group = "kodi_fox",
            tags = {"fox", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local night_hunter_count = SkillTreeFns.CountTags(prefabname, "night_hunter", activatedskills)
                if night_hunter_count == 0 then
                    return true
                end
            end,
            connects = {"kodi_fox_day_stalker"},
        },
        kodi_fox_lock_night_excl = {
            desc = KODI.FOX_LOCK_DAY_DESC or "Cannot be Day Stalker.",
            pos = {COL1_X + STEP_X + 4, 35 + STEP_Y / 3},
            group = "kodi_fox",
            tags = {"fox", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local day_stalker_count = SkillTreeFns.CountTags(prefabname, "day_stalker", activatedskills)
                if day_stalker_count == 0 then
                    return true
                end
            end,
            connects = {"kodi_fox_night_hunter"},
        },
        kodi_fox_day_stalker = {
            title = KODI.FOX_DAY_STALKER_TITLE or "Day Stalker",
            desc = KODI.FOX_DAY_STALKER_DESC or "Stealth mode: slow walk, semi-transparent, hide behind trees. Pounce for TRIPLE damage. [Excludes Night Hunter]",
            icon = "day_stalker",
            pos = {COL1_X - 4, 15},
            group = "kodi_fox",
            tags = {"fox", "day_stalker"},
            locks = {"kodi_fox_lock", "kodi_fox_lock_day_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_day_stalker")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_day_stalker")
            end,
        },
        kodi_fox_night_hunter = {
            title = KODI.FOX_NIGHT_HUNTER_TITLE or "Night Hunter",
            desc = KODI.FOX_NIGHT_HUNTER_DESC or "Mark up to 3 targets, night vision, shadow leap. Day: x1.1 damage. Night: x2.5 damage, +range. Marked targets share damage. [Excludes Day Stalker]",
            icon = "hight_hunter",
            pos = {COL1_X + STEP_X + 4, 15},
            group = "kodi_fox",
            tags = {"fox", "night_hunter"},
            locks = {"kodi_fox_lock", "kodi_fox_lock_night_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_night_hunter")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_night_hunter")
            end,
        },
        kodi_demon_duration_1 = {
            title = KODI.DEMON_DURATION_1_TITLE or "Demonic Endurance I",
            desc = KODI.DEMON_DURATION_1_DESC or "Demon form lasts 10% longer. Attacks cause fear. Shadow Dash damages enemies in path.",
            icon = "demonic_endurance",
            pos = {COL2_X, TOP_Y},
            group = "kodi_demon",
            tags = {"demon"},
            root = true,
            connects = {"kodi_demon_duration_2", "kodi_demon_damage_1", "kodi_demon_dash_1"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_duration_1")
                inst:AddTag("kodi_fear_attack")
                inst:AddTag("kodi_dash_damage")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_duration_1")
                inst:RemoveTag("kodi_fear_attack")
                inst:RemoveTag("kodi_dash_damage")
            end,
        },
        kodi_demon_duration_2 = {
            title = KODI.DEMON_DURATION_2_TITLE or "Demonic Endurance II",
            desc = KODI.DEMON_DURATION_2_DESC or "Demon form lasts 20% longer.",
            icon = "demonic_endurance2",
            pos = {COL2_X, TOP_Y - 54},
            group = "kodi_demon",
            tags = {"demon"},
            connects = {"kodi_demon_duration_3"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_duration_2")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_duration_2")
            end,
        },
        kodi_demon_duration_3 = {
            title = KODI.DEMON_DURATION_3_TITLE or "Demonic Endurance III",
            desc = KODI.DEMON_DURATION_3_DESC or "Demon form lasts 30% longer. Kills extend duration.",
            icon = "demonic_endurance3",
            pos = {COL2_X, TOP_Y - 54 - STEP_Y},
            group = "kodi_demon",
            tags = {"demon"},
            connects = {"kodi_demon_mastery"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_duration_3")
                inst:AddTag("kodi_kill_extend")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_duration_3")
                inst:RemoveTag("kodi_kill_extend")
            end,
        },
        kodi_demon_mastery = {
            title = KODI.DEMON_MASTERY_TITLE or "Demonic Mastery",
            desc = KODI.DEMON_MASTERY_DESC or "No sanity loss in demon form.",
            icon = "demonic_mastery",
            pos = {COL2_X, TOP_Y - 54 - STEP_Y * 2},
            group = "kodi_demon",
            tags = {"demon"},
            connects = {"kodi_demon_lock_hands_excl", "kodi_demon_lock_eruption_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_demon_mastery")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_demon_mastery")
            end,
        },
        kodi_demon_lock_hands_excl = {
            desc = KODI.DEMON_LOCK_ERUPTION_DESC or "Cannot have Shadow Eruption.\nRequires: 6 Demon skills.",
            pos = {COL2_X - STEP_X, TOP_Y - 54 - STEP_Y * 2},
            group = "kodi_demon",
            tags = {"demon", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local eruption_count = SkillTreeFns.CountTags(prefabname, "shadow_eruption", activatedskills)
                if eruption_count == 0 then
                    local demon_count = SkillTreeFns.CountTags(prefabname, "demon", activatedskills)
                    return demon_count >= 6
                end
            end,
            connects = {"kodi_demon_shadow_hands"},
        },
        kodi_demon_lock_eruption_excl = {
            desc = KODI.DEMON_LOCK_HANDS_DESC or "Cannot have Shadow Hands.\nRequires: 6 Demon skills.",
            pos = {COL2_X + STEP_X, TOP_Y - 54 - STEP_Y * 2},
            group = "kodi_demon",
            tags = {"demon", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local hands_count = SkillTreeFns.CountTags(prefabname, "shadow_hands", activatedskills)
                if hands_count == 0 then
                    local demon_count = SkillTreeFns.CountTags(prefabname, "demon", activatedskills)
                    return demon_count >= 6
                end
            end,
            connects = {"kodi_demon_shadow_eruption"},
        },
        kodi_demon_damage_1 = {
            title = KODI.DEMON_DAMAGE_1_TITLE or "Dark Power I",
            desc = KODI.DEMON_DAMAGE_1_DESC or "Demon form deals +10% damage.",
            icon = "the_power_of_darkness",
            pos = {COL2_X - STEP_X, TOP_Y - 54},
            group = "kodi_demon",
            tags = {"demon"},
            connects = {"kodi_demon_damage_2"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_damage_1")
                if inst.RefreshDemonBonuses then
                    inst:RefreshDemonBonuses()
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_damage_1")
            end,
        },
        kodi_demon_damage_2 = {
            title = KODI.DEMON_DAMAGE_2_TITLE or "Dark Power II",
            desc = KODI.DEMON_DAMAGE_2_DESC or "Demon form deals +15% damage.",
            icon = "the_power_of_darkness2",
            pos = {COL2_X - STEP_X, TOP_Y - 54 - STEP_Y},
            group = "kodi_demon",
            tags = {"demon"},
            connects = {"kodi_demon_lock_hands_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_damage_2")
                if inst.RefreshDemonBonuses then
                    inst:RefreshDemonBonuses()
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_damage_2")
            end,
        },
        kodi_demon_dash_1 = {
            title = KODI.DEMON_DASH_1_TITLE or "Shadow Step I",
            desc = KODI.DEMON_DASH_1_DESC or "Shadow Dash range increased.",
            icon = "shadow_step",
            pos = {COL2_X + STEP_X, TOP_Y - 54},
            group = "kodi_demon",
            tags = {"demon"},
            connects = {"kodi_demon_dash_2"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_dash_1")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_dash_1")
            end,
        },
        kodi_demon_dash_2 = {
            title = KODI.DEMON_DASH_2_TITLE or "Shadow Step II",
            desc = KODI.DEMON_DASH_2_DESC or "Shadow Dash cooldown reduced.",
            icon = "shadow_step2",
            pos = {COL2_X + STEP_X, TOP_Y - 54 - STEP_Y},
            group = "kodi_demon",
            tags = {"demon"},
            connects = {"kodi_demon_lock_eruption_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_dash_2")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_dash_2")
            end,
        },
        kodi_demon_shadow_hands = {
            title = KODI.DEMON_SHADOW_HANDS_TITLE or "Shadow Hands",
            desc = KODI.DEMON_SHADOW_HANDS_DESC or "Channel shadow hands to attack distant targets (15-20 tiles). Kodi cannot move while channeling. [Excludes Shadow Eruption]",
            icon = "shadow_hands",
            pos = {COL2_X - STEP_X, TOP_Y - 54 - STEP_Y * 3},
            group = "kodi_demon",
            tags = {"demon", "shadow_hands"},
            locks = {"kodi_demon_lock_hands_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_shadow_hands")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_shadow_hands")
            end,
        },
        kodi_demon_shadow_eruption = {
            title = KODI.DEMON_SHADOW_ERUPTION_TITLE or "Shadow Eruption",
            desc = KODI.DEMON_SHADOW_ERUPTION_DESC or "Release shadow wave. Enemies in radius are frozen 2 sec, take 2 hits, ignite with black flame (10 sec DoT). [Excludes Shadow Hands]",
            icon = "shadow_eruption",
            pos = {COL2_X + STEP_X, TOP_Y - 54 - STEP_Y * 3},
            group = "kodi_demon",
            tags = {"demon", "shadow_eruption"},
            locks = {"kodi_demon_lock_eruption_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_shadow_eruption")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_shadow_eruption")
            end,
        },
        kodi_survival_scavenger_1 = {
            title = KODI.SURVIVAL_SCAVENGER_1_TITLE or "Predator's Instinct",
            desc = KODI.SURVIVAL_SCAVENGER_1_DESC or "Eat raw meat without penalties. Hunts end on 3rd track instead of 6-12.",
            icon = "scavenger",
            pos = {COL3_X, TOP_Y},
            group = "kodi_survival",
            tags = {"survival", "survival_main"},
            root = true,
            connects = {"kodi_survival_scavenger_2"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_scavenger_1")
                inst:AddTag("kodi_food_sense")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_scavenger_1")
                inst:RemoveTag("kodi_food_sense")
            end,
        },
        kodi_survival_scavenger_2 = {
            title = KODI.SURVIVAL_SCAVENGER_2_TITLE or "Scavenger's Nose II",
            desc = KODI.SURVIVAL_SCAVENGER_2_DESC or "+25% meat from killed creatures.",
            icon = "scavenger2",
            pos = {COL3_X, TOP_Y - STEP_Y},
            group = "kodi_survival",
            tags = {"survival", "survival_main"},
            connects = {"kodi_survival_scavenger_3"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_scavenger_2")
                inst:AddTag("kodi_extra_meat")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_scavenger_2")
                inst:RemoveTag("kodi_extra_meat")
            end,
        },
        kodi_survival_scavenger_3 = {
            title = KODI.SURVIVAL_SCAVENGER_3_TITLE or "Scavenger's Nose III",
            desc = KODI.SURVIVAL_SCAVENGER_3_DESC or "Can eat spoiled food without sanity penalty.",
            icon = "scavenger3",
            pos = {COL3_X, TOP_Y - STEP_Y * 2},
            group = "kodi_survival",
            tags = {"survival", "survival_main"},
            connects = {"kodi_survival_lock"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_scavenger_3")
                inst:AddTag("kodi_eat_spoiled")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_scavenger_3")
                inst:RemoveTag("kodi_eat_spoiled")
            end,
        },
        kodi_survival_cunning_1 = {
            title = KODI.SURVIVAL_CUNNING_1_TITLE or "Last Stand",
            desc = KODI.SURVIVAL_CUNNING_1_DESC or "Survive a lethal blow with 1 HP. Recharges each day.",
            icon = "the_last_frontier",
            pos = {COL3_X + STEP_X, TOP_Y},
            group = "kodi_survival",
            tags = {"survival", "survival_main"},
            root = true,
            connects = {"kodi_survival_cunning_2"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_cunning_1")
                inst:AddTag("kodi_last_stand")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_cunning_1")
                inst:RemoveTag("kodi_last_stand")
            end,
        },
        kodi_survival_cunning_2 = {
            title = KODI.SURVIVAL_CUNNING_2_TITLE or "Evasion",
            desc = KODI.SURVIVAL_CUNNING_2_DESC or "15% chance to dodge attacks completely.",
            icon = "avoidance",
            pos = {COL3_X + STEP_X, TOP_Y - STEP_Y},
            group = "kodi_survival",
            tags = {"survival", "survival_main"},
            connects = {"kodi_survival_cunning_3"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_cunning_2")
                inst:AddTag("kodi_dodge")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_cunning_2")
                inst:RemoveTag("kodi_dodge")
            end,
        },
        kodi_survival_cunning_3 = {
            title = KODI.SURVIVAL_CUNNING_3_TITLE or "Shadow Summon",
            desc = KODI.SURVIVAL_CUNNING_3_DESC or "Press [J] to summon shadow terrorbeaks. Costs 20 energy + 10 HP. Press [J] again to dismiss. Demon form empowers shadows but drains energy faster.",
            icon = "summoning_the_shadows",
            pos = {COL3_X + STEP_X, TOP_Y - STEP_Y * 2},
            group = "kodi_survival",
            tags = {"survival", "survival_main"},
            connects = {"kodi_survival_lock"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_cunning_3")
                inst:AddTag("kodi_shadow_summon")
                if not inst.components.petleash then
                    inst:AddComponent("petleash")
                end
                inst.components.petleash:SetMaxPets(2)
                inst.components.petleash:SetOnSpawnFn(function(owner, pet)
                    if pet.SetOwner then
                        pet:SetOwner(owner)
                    end
                    if pet.UpdateForOwnerForm then
                        local is_demon = owner and not owner:HasTag("NotDemon")
                        pet:UpdateForOwnerForm(is_demon)
                    end
                end)
                inst.components.petleash:SetOnDespawnFn(function(owner, pet)
                    if pet:IsValid() then
                        local x, y, z = pet.Transform:GetWorldPosition()
                        local fx = SpawnPrefab("shadow_despawn")
                        if fx then
                            fx.Transform:SetPosition(x, y, z)
                        end
                        pet:Remove()
                    end
                end)
                if not inst.components.leader then
                    inst:AddComponent("leader")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_cunning_3")
                inst:RemoveTag("kodi_shadow_summon")
                if inst.components.petleash then
                    inst.components.petleash:DespawnAllPets()
                end
                inst._shadow_summon_extra_drain = false
            end,
        },
        kodi_survival_lock = {
            desc = KODI.SURVIVAL_LOCK_DESC or "Requires 3 Survival skills.",
            pos = {COL3_X + 18, 55 + STEP_Y / 3},
            group = "kodi_survival",
            tags = {"survival", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local survival_main_count = SkillTreeFns.CountTags(prefabname, "survival_main", activatedskills)
                return survival_main_count >= 3
            end,
            connects = {"kodi_survival_lock_cache_excl", "kodi_survival_lock_minion_excl"},
        },
        kodi_survival_lock_cache_excl = {
            desc = KODI.SURVIVAL_LOCK_MINION_DESC or "Cannot have Shadow Minion.",
            pos = {COL3_X - 4, 35 + STEP_Y / 3},
            group = "kodi_survival",
            tags = {"survival", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local minion_count = SkillTreeFns.CountTags(prefabname, "shadow_minion", activatedskills)
                if minion_count == 0 then
                    return true
                end
            end,
            connects = {"kodi_survival_shadow_cache"},
        },
        kodi_survival_lock_minion_excl = {
            desc = KODI.SURVIVAL_LOCK_CACHE_DESC or "Cannot have Shadow Cache.",
            pos = {COL3_X + STEP_X + 4, 35 + STEP_Y / 3},
            group = "kodi_survival",
            tags = {"survival", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local cache_count = SkillTreeFns.CountTags(prefabname, "shadow_cache", activatedskills)
                if cache_count == 0 then
                    return true
                end
            end,
            connects = {"kodi_survival_shadow_minion"},
        },
        kodi_survival_shadow_cache = {
            title = KODI.SURVIVAL_SHADOW_CACHE_TITLE or "Shadow Cache",
            desc = KODI.SURVIVAL_SHADOW_CACHE_DESC or "Press [H] to open shadow portal. 9 slots (3x3) that persist through death. Costs 5 energy + 10 sanity. 10s cooldown.",
            icon = "shadow_hideout",
            pos = {COL3_X - 4, 15},
            group = "kodi_survival",
            tags = {"survival", "shadow_cache"},
            locks = {"kodi_survival_lock", "kodi_survival_lock_cache_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_shadow_cache")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_shadow_cache")
            end,
        },
        kodi_survival_shadow_minion = {
            title = KODI.SURVIVAL_SHADOW_MINION_TITLE or "Shadow Minion",
            desc = KODI.SURVIVAL_SHADOW_MINION_DESC or "Press [H] to open shadow creature menu. Press [K] to quick-summon favorite. Fights for you, explodes on death. 2min cooldown.",
            icon = "shadowy_skunk",
            pos = {COL3_X + STEP_X + 4, 15},
            group = "kodi_survival",
            tags = {"survival", "shadow_minion"},
            locks = {"kodi_survival_lock", "kodi_survival_lock_minion_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("kodi_shadow_minion")
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("kodi_shadow_minion")
            end,
        },
        kodi_allegiance_lock_1 = {
            desc = KODI.ALLEGIANCE_LOCK_1_DESC or "Requires 12 total skills to unlock.",
            pos = {COL4_X + 2, TOP_Y},
            group = "kodi_allegiance",
            tags = {"allegiance", "lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local total_skills = SkillTreeFns.CountSkills(prefabname, activatedskills)
                return total_skills >= 12
            end,
            connects = {"kodi_allegiance_lock_shadow", "kodi_allegiance_lock_lunar"},
        },
        kodi_allegiance_lock_shadow = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_2_DESC or "Defeat the Ancient Fuelweaver.",
            pos = {COL4_X - 22 + 2, TOP_Y - 50 + 2},
            group = "kodi_allegiance",
            tags = {"allegiance", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                if readonly then
                    return "question"
                end
                local fuelweaver_killed = TheGenericKV:GetKV("fuelweaver_killed")
                return fuelweaver_killed == "1"
            end,
            connects = {"kodi_allegiance_lock_shadow_excl"},
        },
        kodi_allegiance_lock_shadow_excl = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_4_DESC or "Cannot have Lunar allegiance.",
            pos = {COL4_X - 22 + 2, TOP_Y - 100 + 8},
            group = "kodi_allegiance",
            tags = {"allegiance", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local lunar_count = SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills)
                if lunar_count == 0 then
                    return true
                end
            end,
            connects = {"kodi_allegiance_shadow"},
        },
        kodi_allegiance_shadow = {
            title = KODI.ALLEGIANCE_SHADOW_TITLE or "Shadow Allegiance",
            desc = KODI.ALLEGIANCE_SHADOW_DESC or "Aligned with shadow. +25% shadow resist, +10% vs lunar enemies.",
            icon = "shadow_affinity",
            pos = {COL4_X - 22 + 2, TOP_Y - 110 - STEP_Y + 10},
            group = "kodi_allegiance",
            tags = {"allegiance", "shadow", "shadow_favor"},
            locks = {"kodi_allegiance_lock_1", "kodi_allegiance_lock_shadow", "kodi_allegiance_lock_shadow_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                inst:AddTag("kodi_shadow_allegiance")
                if inst.components.damagetyperesist then
                    inst.components.damagetyperesist:AddResist("shadow_aligned", inst, 0.25, "kodi_allegiance_shadow")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                inst:RemoveTag("kodi_shadow_allegiance")
                if inst.components.damagetyperesist then
                    inst.components.damagetyperesist:RemoveResist("shadow_aligned", inst, "kodi_allegiance_shadow")
                end
            end,
        },
        kodi_allegiance_lock_lunar = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_3_DESC or "Defeat the Celestial Champion.",
            pos = {COL4_X + 22 + 2, TOP_Y - 50 + 2},
            group = "kodi_allegiance",
            tags = {"allegiance", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                if readonly then
                    return "question"
                end
                local celestial_killed = TheGenericKV:GetKV("celestialchampion_killed")
                return celestial_killed == "1"
            end,
            connects = {"kodi_allegiance_lock_lunar_excl"},
        },
        kodi_allegiance_lock_lunar_excl = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_5_DESC or "Cannot have Shadow allegiance.",
            pos = {COL4_X + 22 + 2, TOP_Y - 100 + 8},
            group = "kodi_allegiance",
            tags = {"allegiance", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                local shadow_count = SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills)
                if shadow_count == 0 then
                    return true
                end
            end,
            connects = {"kodi_allegiance_lunar"},
        },
        kodi_allegiance_lunar = {
            title = KODI.ALLEGIANCE_LUNAR_TITLE or "Lunar Allegiance",
            desc = KODI.ALLEGIANCE_LUNAR_DESC or "Aligned with lunar. +25% lunar resist, +10% vs shadow enemies.",
            icon = "lunar_affinity",
            pos = {COL4_X + 22 + 2, TOP_Y - 110 - STEP_Y + 10},
            group = "kodi_allegiance",
            tags = {"allegiance", "lunar", "lunar_favor"},
            locks = {"kodi_allegiance_lock_1", "kodi_allegiance_lock_lunar", "kodi_allegiance_lock_lunar_excl"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                inst:AddTag("kodi_lunar_allegiance")
                if inst.components.damagetyperesist then
                    inst.components.damagetyperesist:AddResist("lunar_aligned", inst, 0.25, "kodi_allegiance_lunar")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")
                inst:RemoveTag("kodi_lunar_allegiance")
                if inst.components.damagetyperesist then
                    inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "kodi_allegiance_lunar")
                end
            end,
        },
    }
    return {
        SKILLS = skills,
        ORDERS = ORDERS,
        BACKGROUND_SETTINGS = BACKGROUND_SETTINGS,
    }
end
return BuildSkillsData
