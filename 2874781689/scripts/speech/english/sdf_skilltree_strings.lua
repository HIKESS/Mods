--This is where Daniel's Skill Tree Titles and Descriptions go!

SKILLTREE = {
    SDF = {
	SDF_BACKBONE_LOCK_1_DESC = "Find and defeat the Varg.",

        SDF_BACKBONE_1_TITLE = "The Daring Dash",
        SDF_BACKBONE_1_DESC = "Gain the abilty to perform the [Daring Dash]!\n Dealing ["..TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE.."] Damage to charged targets.",

        SDF_BACKBONE_2_TITLE = "Steadfast",
        SDF_BACKBONE_2_DESC = "Shield Damage Reduction is much more reinforced.\n Daring Dash is much more resistant to hitting obstacles.",

        SDF_BACKBONE_3_TITLE = "Grit",
        SDF_BACKBONE_3_DESC = "Duration of Daring Dash lasts a lot longer.\n Daring Dash breaks resources much quicker.",

	SDF_BACKBONE_LOCK_2_DESC = "Earn a place in the [Hall of Heroes].",
	SDF_BACKBONE_LOCK_3_DESC = "Offer all 20 [Chalice of Souls] to the [Hall of Heroes].",

        SDF_BACKBONE_4_TITLE = "Valor",
        SDF_BACKBONE_4_DESC = "Don Super Armour! Claim the Golden Armor from Dan's Statue at the [Hall of Heroes] early.",

	SDF_BACKBONE_LOCK_4_DESC = "Find and defeat the Bearger.",

        SDF_BACKBONE_5_TITLE = "Energy Bones",
        SDF_BACKBONE_5_DESC = "Bone marrow is now energized gaining +["..TUNING.SDF_SKILLSET_BACKBONE_ENERGY_BONES_BONUS_PLANAR_DEF.."] Planar Defense!",


        SDF_UNDEATH_1_TITLE = "Embalming I",
        SDF_UNDEATH_1_DESC = "Slain foes now have a ["..(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_1 * 100).."%] chance to drop an Energy Vial.\n Epic foes will always drop ["..(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_1).."] Energy Vial upon defeat.",

        SDF_UNDEATH_2_TITLE = "Embalming II",
        SDF_UNDEATH_2_DESC = "Chance of slain foes dropping an Energy Vial increased to ["..(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_2 * 100).."%].\n Epic foes will always drop ["..(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_2).."] Energy Vials upon defeat.",

        SDF_UNDEATH_3_TITLE = "Embalming III",
        SDF_UNDEATH_3_DESC = "[Goodlightning] additionally restores ["..(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_PERCENT * 100).."%] of healing over ["..(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_DURATION).."] seconds.\n Calming effect on Non Epic foes last longer by ["..(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_AGGRO_DEBUFF_DURATION).."] seconds.",

        SDF_UNDEATH_4_TITLE = "Culling",
        SDF_UNDEATH_4_DESC = "Felled foes have a ["..(TUNING.SDF_SKILLSET_UNDEATH_CULLING * 100).."%] chance to grant ["..(TUNING.SDF_SKILLSET_UNDEATH_CULLING_BONUS * 100).."%] additional Souls.\n Bravery increases from successful kills which restores ["..TUNING.SDF_SKILLSET_UNDEATH_CULLING_SANITY_BONUS.."] Sanity.",

        SDF_UNDEATH_5_TITLE = "Rites I",
        SDF_UNDEATH_5_DESC = "Vanquished foes now have a ["..(TUNING.SDF_SKILLSET_UNDEATH_RITES_1 * 100).."%] chance to drop a Soul Helmet.\n Epic foes have a ["..(TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_1 * 100).."%] chance dropping a Soul Helmet upon defeat.",

        SDF_UNDEATH_6_TITLE = "Rites II",
        SDF_UNDEATH_6_DESC = "Chance of vanquished foes dropping a Soul Helmet increased to ["..(TUNING.SDF_SKILLSET_UNDEATH_RITES_2 * 100).."%].\n Epic foes have a ["..(TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_2 * 100).."%] chance dropping a Soul Helmet upon defeat.",

        SDF_UNDEATH_7_TITLE = "Rites III",
        SDF_UNDEATH_7_DESC = "[Anubis Stone] now Summons a permanent [Knight of Gallowmere].\n Soul Helmet drop passive also stacks with [Rites II] totaling to ["..((TUNING.SDF_SKILLSET_UNDEATH_RITES_2 * 100) + (TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE * 100)).."%].",

	SDF_UNDEATH_LOCK_1_DESC = "Find and defeat the Scrappy Werepig. -Coming Soon-",

        SDF_UNDEATH_8_TITLE = "The Professor's Lab",
	SDF_UNDEATH_8_DESC = "Gain access to [Professor Hamilton Kift's Lab]!\n Construct new age weapons and monstrous creations,\n by researching the power of the [Chalice of Souls].",

	SDF_UNDEATH_LOCK_2_DESC = "Find and defeat the Twins of Terror, Crystal Deerclops,\n Possessed Varg, and Armored Bearger.",

        SDF_UNDEATH_9_TITLE = "The Freakshow",
	SDF_UNDEATH_9_DESC = "Rumor has it that a Fabled Sword is held by the imps of the [Merchant Gargoyle],\n and can be obtained by anyone skilled enough to complete all of the boss trials.",

	SDF_UNDEATH_LOCK_3_DESC = "Successfully survive for "..TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_DAYS.." days in [Fate's Arrow] Mode.",

        SDF_UNDEATH_10_TITLE = "For The Honor Of Gallowmere",
	SDF_UNDEATH_10_DESC = "[Dan's Helmet] Gains the ability to boost ["..(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SANITY_BONUS).."] Sanity to Others!\n Allies gain ["..((TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_MOVEMENT_SPEED_BONUS * 100) - 100).."%] Movement Speed and Attacks heal ["..(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_LEECH_BONUS).."] Health.\nAllies take ["..((-TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SHADOW_RESIST_BONUS * 100) + 100).."%] less damage and deal ["..((TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SHADOW_VS_BONUS * 100) - 100).."%] bonus damage to Shadow-aligned creatures.",

	SDF_UNDEATH_LOCK_4_DESC = "Successfully collect "..TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_CAVE_COUNT.." [Chalice of Souls] from a\n [Chalice of Souls Altar] found in the Caves.",

	SDF_UNDEATH_LOCK_5_DESC = "Successfully collect "..TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_OVERWORLD_COUNT.." [Chalice of Souls] from a\n [Chalice of Souls Altar] found on the Overworld.",

        SDF_UNDEATH_11_TITLE = "Time Dilation Runesmith",
	SDF_UNDEATH_11_DESC = "Visit the [Hall of Heroes] to claim the ever-shifting [Time Rune]!\n Used to quickly travel back to the [Hall of Heroes] for a short duration.\nRecharges after collecting a [Chalice of Souls] from an [Chalice of Souls Altar].",

	SDF_SKULL_LOCK_1_DESC = "Find and defeat the Eye of Terror.",

        SDF_SKULL_1_TITLE = "The Eye of Amon Ra",
        SDF_SKULL_1_DESC = "Socket a gift left behind by Princess Kiya, the [Eye of Amon Ra]!\n Dealing damage has a ["..(TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_PROC_CHANCE * 100).."%] chance to expose a foes weakness,\nnext attack deals ["..(TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_BONUS_PLANAR_MULTI * 100).."%] bonus Planar Damage on marked target.",

        SDF_SKULL_2_TITLE = "Focus",
        SDF_SKULL_2_DESC = "Able to deal much more Planar Damage to an exposed target.",

        SDF_SKULL_3_TITLE = "Perception",
        SDF_SKULL_3_DESC = "Chance to expose a Weakness much more offen.",

	SDF_SKULL_LOCK_2_DESC = "Solve "..TUNING.SDF_SKILLSET_SKULL_INSIGHT_BOOK_OF_GALLOWMERE_RIDDLES.." Jack of the Green: [Book of Gallowmere] Riddles",
	SDF_SKULL_LOCK_3_DESC = "Completely Restore all Entries of the [Book of Gallowmere].",

        SDF_SKULL_4_TITLE = "Insight",
        SDF_SKULL_4_DESC = "Become well-versed! Craft a restored [Book of Gallowere] early.",

	SDF_SKULL_LOCK_4_DESC = "Find and defeat the Deerclops.",

        SDF_SKULL_5_TITLE = "Morten the Earthworm",
        SDF_SKULL_5_DESC = "Call upon [Morten] to help 'Tackle' Ocean Fishing!",


	SDF_ALLEGIANCE_LOCK_1_DESC = "Learn 12 skills to unlock.",

	SDF_ALLEGIANCE_LOCK_2_DESC = "Find and defeat the Ancient Fuelweaver.",
	SDF_ALLEGIANCE_LOCK_3_DESC = "Find and defeat the Celestial Champion.",

	SDF_ALLEGIANCE_LOCK_4_DESC = "Have no lunar affinity.",
	SDF_ALLEGIANCE_LOCK_5_DESC = "Have no shadow affinity.",

        SDF_ALLEGIANCE_SHADOW_TITLE = "Guts",
        SDF_ALLEGIANCE_SHADOW_DESC = "Fountain of Rejuvenation now restores ["..(TUNING.SDF_SKILLSET_ALLEGIANCE_GUTS * 100).."%] more health.",

        SDF_ALLEGIANCE_LUNAR_TITLE = "Nerves",
        SDF_ALLEGIANCE_LUNAR_DESC = "Reduce all negative Sanity effects by ["..(TUNING.SDF_SKILLSET_ALLEGIANCE_NERVES * 100).."%].",
    },
}