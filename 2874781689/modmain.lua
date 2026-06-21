GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

-- This global table is required for compatibility with the game's skinning system.
clothing_exclude = {}

Assets = {
    Asset("IMAGE", "images/saveslot_portraits/sdf.tex"),
    Asset("ATLAS", "images/saveslot_portraits/sdf.xml"),
    Asset("IMAGE", "images/selectscreen_portraits/sdf.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/sdf.xml"),
    Asset("IMAGE", "images/selectscreen_portraits/sdf_silho.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/sdf_silho.xml"),
    Asset("IMAGE", "bigportraits/sdf.tex"),
    Asset("ATLAS", "bigportraits/sdf.xml"),
    Asset("IMAGE", "images/map_icons/sdf.tex"),
    Asset("ATLAS", "images/map_icons/sdf.xml"),
    Asset("IMAGE", "images/avatars/avatar_sdf.tex"),
    Asset("ATLAS", "images/avatars/avatar_sdf.xml"),
    Asset("IMAGE", "images/avatars/avatar_ghost_sdf.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_sdf.xml"),
    Asset( "IMAGE", "images/avatars/self_inspect_sdf.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_sdf.xml" ),

    Asset( "IMAGE", "images/names_sdf.tex" ), 
    Asset( "ATLAS", "images/names_sdf.xml" ),
    Asset( "IMAGE", "images/names_gold_sdf.tex" ),
    Asset( "ATLAS", "images/names_gold_sdf.xml" ),

    Asset("SOUNDPACKAGE", "sound/sdf.fev"),
    Asset("SOUND", "sound/sdf.fsb"),

    Asset("ATLAS", "images/inventoryimages/sdf.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf.tex"),


    Asset("ANIM", "anim/status_meter_soul.zip"),
    Asset("ANIM", "anim/status_meter_soul_fatesarrow.zip"),
    Asset("IMAGE", "images/chalice_souls/chalice_soul_100.tex"),
    Asset("ATLAS", "images/chalice_souls/chalice_soul_100.xml"),
    Asset("IMAGE", "images/chalice_souls/chalice_soul_75.tex"),
    Asset("ATLAS", "images/chalice_souls/chalice_soul_75.xml"),
    Asset("IMAGE", "images/chalice_souls/chalice_soul_50.tex"),
    Asset("ATLAS", "images/chalice_souls/chalice_soul_50.xml"),
    Asset("IMAGE", "images/chalice_souls/chalice_soul_25.tex"),
    Asset("ATLAS", "images/chalice_souls/chalice_soul_25.xml"),
    Asset("IMAGE", "images/chalice_souls/chalice_soul_0.tex"),
    Asset("ATLAS", "images/chalice_souls/chalice_soul_0.xml"),

    Asset("ANIM", "anim/status_meter_lifebottle.zip"),
    Asset("IMAGE", "images/lifebottle_fill/lifebottle_100.tex"),
    Asset("ATLAS", "images/lifebottle_fill/lifebottle_100.xml"),
    Asset("IMAGE", "images/lifebottle_fill/lifebottle_75.tex"),
    Asset("ATLAS", "images/lifebottle_fill/lifebottle_75.xml"),
    Asset("IMAGE", "images/lifebottle_fill/lifebottle_50.tex"),
    Asset("ATLAS", "images/lifebottle_fill/lifebottle_50.xml"),
    Asset("IMAGE", "images/lifebottle_fill/lifebottle_25.tex"),
    Asset("ATLAS", "images/lifebottle_fill/lifebottle_25.xml"),
    Asset("IMAGE", "images/lifebottle_fill/lifebottle_0.tex"),
    Asset("ATLAS", "images/lifebottle_fill/lifebottle_0.xml"),

    Asset("ANIM", "anim/status_meter_superarmor.zip"),
    Asset("IMAGE", "images/superarmor_icon/superarmor_icon.tex"),
    Asset("ATLAS", "images/superarmor_icon/superarmor_icon.xml"),

    Asset("IMAGE", "images/shield_slot_icon/shield_slot_icon.tex"),
    Asset("ATLAS", "images/shield_slot_icon/shield_slot_icon.xml"),

    Asset("ANIM", "anim/ui_sdf_rune_holder.zip"),
    Asset("IMAGE", "images/rune_slot_icon/rune_slot_icon.tex"),
    Asset("ATLAS", "images/rune_slot_icon/rune_slot_icon.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_time_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_time_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_moon_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_moon_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_earth_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_earth_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_star_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_star_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_chaos_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_chaos_rune.xml"),

    Asset("ANIM","anim/player_actions_speargun.zip"),
    Asset("ANIM", "anim/player_actions_sdf_bows.zip"),

    Asset("ANIM", "anim/ui_sdf_quiver.zip"),
    Asset("IMAGE", "images/inv_slot/inv_slot_standard_bolts.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_bolts.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_flaming_bolts.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_flaming_bolts.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_standard_arrows.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_arrows.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_flaming_arrows.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_flaming_arrows.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_magical_arrows.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_magical_arrows.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_standard_bullets.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_bullets.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_standard_buckshots.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_buckshots.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_standard_munitions.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_standard_munitions.xml"),

    Asset("ANIM", "anim/ui_sdf_lightning_gauntlet_capacitor.zip"),
    Asset("IMAGE", "images/inv_slot/inv_slot_lightning.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_lightning.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_goodlightning.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_goodlightning.xml"),

    Asset("ANIM", "anim/ui_sdf_anubis_stone_soulkeeper.zip"),
    Asset("IMAGE", "images/inv_slot/inv_slot_soul_helmet.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_soul_helmet.xml"),

    Asset("ANIM", "anim/ui_sdf_book_of_gallowmere_spine.zip"),
    Asset("ANIM", "anim/sdf_book_of_gallowmere_read.zip"),
    Asset("IMAGE", "images/inv_slot/inv_slot_entries_inventory.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_inventory.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_entries_friendlies.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_friendlies.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_entries_enemies.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_enemies.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_entries_bosses.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_bosses.xml"),

    Asset("ANIM", "anim/sdf_pumpking_guttedover.zip"),
    Asset("ANIM", "anim/sdf_pumpking_guttedshoot.zip"),
    Asset("ANIM", "anim/sdf_pumpking_guttedpuddle.zip"),

    Asset( "IMAGE", "images/skilltreeimages/sdf_skilltree.tex" ),
    Asset( "ATLAS", "images/skilltreeimages/sdf_skilltree.xml" ),

    --Asset( "IMAGE", "images/skilltreeimages/skill_intimidating_1.tex_i.tex" ),
    --Asset( "ATLAS", "images/skilltreeimages/skill_intimidating_1.tex_i.xml" ),
    --Asset( "IMAGE", "images/skilltree_icons.tex" ),
    --Asset( "ATLAS", "images/skilltree_icons.xml" ),

    Asset("IMAGE", "images/inventoryimages/sdf_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_victorian_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_victorian_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_gold_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gold_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_dragon_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_helmet.xml"),
    Asset("IMAGE", "images/map_icons/sdf_helmet_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_helmet_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_rune_holder.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_rune_holder.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_morten.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_morten.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_morten_baited.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_morten_baited.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chalice_hall_of_heroes_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chalice_hall_of_heroes_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chalice_runestone_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chalice_runestone_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chalice_altar_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chalice_altar_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_chalice_of_souls.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_chalice_of_souls.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chalice_of_souls_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chalice_of_souls_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_soul_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_soul_helmet.xml"),
    Asset("IMAGE", "images/map_icons/sdf_soul_helmet_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_soul_helmet_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_witch_talisman.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_witch_talisman.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_witch_talisman.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_witch_talisman.xml"),
    Asset("IMAGE", "images/map_icons/sdf_witch_talisman_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_witch_talisman_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_witch_cauldron_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_witch_cauldron_mm.xml"),


    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere.xml"),
    Asset("IMAGE", "images/map_icons/sdf_book_of_gallowmere_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_book_of_gallowmere_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_damaged.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_damaged.xml"),
    Asset("IMAGE", "images/map_icons/sdf_book_of_gallowmere_damaged_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_book_of_gallowmere_damaged_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_inventory.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_inventory.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_friendlies.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_friendlies.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_enemies.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_enemies.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_bosses.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_bosses.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_restored_vellum.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_restored_vellum.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_runestone_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_runestone_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_wooden_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_wooden_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_skull_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_skull_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_lifebottle_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_lifebottle_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_pumpkin_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_pumpkin_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_maze_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_maze_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_haunted_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_haunted_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_chest_kingdom_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_chest_kingdom_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_rock_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_rock_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_marble_pillar_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_marble_pillar_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_support_stone_pillar_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_support_stone_pillar_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_haunted_ruins_lava_pond_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_haunted_ruins_lava_pond_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_king_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_king_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_pumpking_seed_pod_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpking_seed_pod_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gourd_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gourd_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gorge_creeper_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gorge_creeper_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gorge_pondfish.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gorge_pondfish.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_dead.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_dead.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_cooked.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gorge_pondfish_cooked.xml"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gorge_pond_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gorge_pond_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_pumpkin_gorge_well_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpkin_gorge_well_mm.xml"),

    Asset( "IMAGE", "images/map_icons/sdf_statue_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_statue_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_information_gargoyle_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_information_gargoyle_mm.xml"),

    Asset("IMAGE", "images/map_icons/sdf_merchant_gargoyle_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_merchant_gargoyle_mm.xml"),
    Asset("IMAGE", "images/tabimages/sdf_merchant_gargoyle_tab.tex"),
    Asset("ATLAS", "images/tabimages/sdf_merchant_gargoyle_tab.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_shop_gargoyle.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_shop_gargoyle.xml"),
    Asset("IMAGE", "images/map_icons/sdf_shop_gargoyle_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_shop_gargoyle_mm.xml"),
    Asset("IMAGE", "images/tabimages/sdf_shop_gargoyle_tab.tex"),
    Asset("ATLAS", "images/tabimages/sdf_shop_gargoyle_tab.xml"),

    Asset("IMAGE", "images/map_icons/sdf_healthfountain_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_healthfountain_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_lifebottle.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_lifebottle.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_energyvial.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_energyvial.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_acorn_cracked.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_acorn_cracked.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_victorian_suit.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_victorian_suit.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_gold_armor.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gold_armor.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_gold_armor.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_gold_armor.xml"),
    Asset("IMAGE", "images/map_icons/sdf_gold_armor_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_gold_armor_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_dragon_potion.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_potion.xml"),
    Asset("IMAGE", "images/map_icons/sdf_dragon_potion_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_dragon_potion_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_dragon_potion_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_potion_empty.xml"),
    Asset("IMAGE", "images/map_icons/sdf_dragon_potion_empty_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_dragon_potion_empty_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_dragon_potion_dragonbreath.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_potion_dragonbreath.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_copper_shield.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_copper_shield.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_silver_shield.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_silver_shield.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_gold_shield.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gold_shield.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_gold_shield.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_gold_shield.xml"),
    Asset("IMAGE", "images/map_icons/sdf_gold_shield_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_gold_shield_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_arm.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_arm.xml"),
    Asset("ATLAS", "images/inventoryimages/sdf_victorian_arm.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_victorian_arm.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gold_arm.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_gold_arm.tex"),

    Asset("IMAGE", "images/inventoryimages/sdf_small_sword.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_small_sword.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_broad_sword.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_broad_sword.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_enchanted_sword.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_enchanted_sword.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_enchanted_sword.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_enchanted_sword.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_magic_sword.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_magic_sword.xml"),
    Asset("IMAGE", "images/map_icons/sdf_magic_sword_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_magic_sword_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_wodens_brand.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_wodens_brand.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_wodens_brand.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_wodens_brand.xml"),
    Asset("IMAGE", "images/map_icons/sdf_wodens_brand_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_wodens_brand_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_club.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_club.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_hammer.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_hammer.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_axe.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_axe.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_spade.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_spade.xml"),
    Asset("IMAGE", "images/map_icons/sdf_spade_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_spade_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_throwing_daggers.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_throwing_daggers.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_throwing_daggers.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_throwing_daggers.xml"),

    Asset("ATLAS", "images/inventoryimages/sdf_crossbow_sdf_standard_bolts.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_crossbow_sdf_standard_bolts.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_crossbow_sdf_flaming_bolts.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_crossbow_sdf_flaming_bolts.tex"),
    Asset("IMAGE", "images/inventoryimages/sdf_crossbow_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_crossbow_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_standard_bolts.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_standard_bolts.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_standard_bolts.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_standard_bolts.xml"),

    Asset("ATLAS", "images/inventoryimages/sdf_longbow_sdf_standard_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_longbow_sdf_standard_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_longbow_sdf_flaming_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_longbow_sdf_flaming_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_longbow_sdf_magical_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_longbow_sdf_magical_arrows.tex"),
    Asset("IMAGE", "images/inventoryimages/sdf_longbow_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_longbow_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_standard_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_standard_arrows.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_standard_arrows.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_standard_arrows.xml"),

    Asset("ATLAS", "images/inventoryimages/sdf_flaming_longbow_sdf_standard_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_longbow_sdf_standard_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_longbow_sdf_flaming_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_longbow_sdf_flaming_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_longbow_sdf_magical_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_longbow_sdf_magical_arrows.tex"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_longbow_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_longbow_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_arrows.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_flaming_arrows.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_flaming_arrows.xml"),

    Asset("ATLAS", "images/inventoryimages/sdf_magic_longbow_sdf_standard_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_magic_longbow_sdf_standard_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_magic_longbow_sdf_flaming_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_magic_longbow_sdf_flaming_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_magic_longbow_sdf_magical_arrows.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_magic_longbow_sdf_magical_arrows.tex"),
    Asset("IMAGE", "images/inventoryimages/sdf_magic_longbow_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_magic_longbow_empty.xml"),
    Asset("IMAGE", "images/map_icons/sdf_magic_longbow_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_magic_longbow_mm.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_magical_arrows.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_magical_arrows.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_magical_arrows.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_magical_arrows.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_spear.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_spear.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_spear.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_spear.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_lightning_gauntlet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_lightning_gauntlet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_lightning_gauntlet_lightning.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_lightning_gauntlet_lightning.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_lightning_gauntlet_goodlightning.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_lightning_gauntlet_goodlightning.xml"),
    Asset("IMAGE", "images/map_icons/sdf_lightning_gauntlet_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_lightning_gauntlet_mm.xml"),

    Asset("ANIM", "anim/sdf_lightning_shock.zip"),
    Asset("IMAGE", "images/inventoryimages/sdf_lightning.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_lightning.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_lightning.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_lightning.xml"),

    Asset("ANIM", "anim/sdf_goodlightning_shock.zip"),
    Asset("IMAGE", "images/inventoryimages/sdf_goodlightning.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_goodlightning.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_goodlightning.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_goodlightning.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_chicken_drumstick.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_chicken_drumstick.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_gallowmere_knight.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gallowmere_knight.xml"),
    Asset("IMAGE", "images/map_icons/sdf_gallowmere_knight_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_gallowmere_knight_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_king_peregrins_crown.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_king_peregrins_crown.xml"),
    Asset("IMAGE", "images/map_icons/sdf_king_peregrins_crown_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_king_peregrins_crown_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_empty.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_empty_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_empty_mm.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_necrotic_touch.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_necrotic_touch.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part1.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part1.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part2.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part2.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part3.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part3.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_part4.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_part4.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part1_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part1_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part2_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part2_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part3_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part3_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_part4_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_part4_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_giants_ocarina.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_giants_ocarina.xml"),
    Asset("IMAGE", "images/map_icons/sdf_asgard_golem_giants_ocarina_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_asgard_golem_giants_ocarina_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_optimize_data_damaged.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_optimize_data_damaged.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_a.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_a.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_c.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_c.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_gourd_seeds.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_gourd_seeds.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_bomb_seeds.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_bomb_seeds.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pumpkin_creeper_seeds.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pumpkin_creeper_seeds.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_shadow_artefact.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_shadow_artefact.xml"),
    Asset("IMAGE", "images/map_icons/sdf_shadow_artefact_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_shadow_artefact_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_shadow_talisman.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_shadow_talisman.xml"),
    Asset("IMAGE", "images/map_icons/sdf_shadow_talisman_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_shadow_talisman_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_carnival_token.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_carnival_token.xml"),
    Asset("IMAGE", "images/map_icons/sdf_carnival_token_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_carnival_token_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_time_rune.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_time_rune.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_time_rune_temp.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_time_rune_temp.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_time_rune_broken.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_time_rune_broken.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_moon_rune.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_moon_rune.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_earth_rune.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_earth_rune.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_star_rune.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_star_rune.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_chaos_rune.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_chaos_rune.xml"),

    Asset("ANIM", "anim/sdf_time_rune_gears_fx.zip"),

    Asset("IMAGE", "images/map_icons/sdf_jack_of_the_green_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_jack_of_the_green_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_jack_of_the_green_riddle_chaos_rune_fragment.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_jack_of_the_green_riddle_chaos_rune_fragment.xml"),

    Asset("IMAGE", "images/map_icons/sdf_professors_lab_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_professors_lab_mm.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_red.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_red.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_blue.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_blue.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_purple.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_purple.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_yellow.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_yellow.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_green.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_green.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_orange.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_orange.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_opal.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_opal.xml"),

    Asset("ATLAS", "images/inventoryimages/sdf_flaming_crossbow_sdf_standard_bolts.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_crossbow_sdf_standard_bolts.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_crossbow_sdf_flaming_bolts.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_crossbow_sdf_flaming_bolts.tex"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_crossbow_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_crossbow_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_flaming_bolts.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_flaming_bolts.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_flaming_bolts.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_flaming_bolts.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_pistol.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pistol.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_pistol_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_pistol_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_standard_bullets.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_standard_bullets.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_standard_bullets.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_standard_bullets.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_blunderbuss.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_blunderbuss.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_blunderbuss_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_blunderbuss_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_standard_buckshots.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_standard_buckshots.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_standard_buckshots.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_standard_buckshots.xml"),

    Asset("IMAGE", "images/inventoryimages/sdf_bombs.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_bombs.xml"),
    Asset("IMAGE", "images/techtreeimages/sdf_bombs.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_bombs.xml"),

    Asset("SOUNDPACKAGE", "sound/tf2minigun.fev"),
    Asset("SOUND", "sound/tf2minigun.fsb"),

    Asset( "ANIM", "anim/player_actions_sdf_gatling_gun.zip" ),
    Asset( "ANIM", "anim/player_walk_sdf_gatling_gun.zip" ),

    Asset( "IMAGE", "images/inventoryimages/sdf_gatling_gun.tex" ),
    Asset( "ATLAS", "images/inventoryimages/sdf_gatling_gun.xml" ),

    Asset( "IMAGE", "images/inventoryimages/sdf_standard_munitions.tex" ),
    Asset( "ATLAS", "images/inventoryimages/sdf_standard_munitions.xml" ),
    Asset("IMAGE", "images/techtreeimages/sdf_standard_munitions.tex"),
    Asset("ATLAS", "images/techtreeimages/sdf_standard_munitions.xml"),

----test
}

-------------------------------------
--Book of Gallowmere DATA and Assets
modimport("init/sdf_book_of_gallowmere_popup_assets")
GLOBAL.global("SDFTheBookOfGallowmere")
GLOBAL.SDFTheBookOfGallowmere = nil
GLOBAL.SDFTheBookOfGallowmere = require("sdf_book_of_gallowmere_Page_data")()
GLOBAL.SDFTheBookOfGallowmere:Load()
-------------------------------------

RegisterInventoryItemAtlas("images/inventoryimages/sdf_helmet.xml","sdf_helmet.tex")
RegisterInventoryItemAtlas("images/inventoryimages/sdf_arm.xml","sdf_arm.tex")
RegisterInventoryItemAtlas("images/inventoryimages/sdf_rune_holder.xml","sdf_rune_holder.tex")

AddMinimapAtlas("images/map_icons/sdf.xml")
AddMinimapAtlas("images/map_icons/sdf_helmet_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chalice_hall_of_heroes_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chalice_runestone_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chalice_altar_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chalice_of_souls_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_soul_helmet_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_witch_talisman_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_witch_cauldron_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_book_of_gallowmere_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_book_of_gallowmere_damaged_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_runestone_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_wooden_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_skull_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_lifebottle_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_pumpkin_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_maze_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_haunted_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chest_kingdom_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_rock_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_marble_pillar_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_support_stone_pillar_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_haunted_ruins_lava_pond_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_pumpkin_king_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_pumpking_seed_pod_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_pumpkin_gourd_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_pumpkin_gorge_creeper_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_pumpkin_gorge_pond_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_pumpkin_gorge_well_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_statue_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_information_gargoyle_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_merchant_gargoyle_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_shop_gargoyle_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_healthfountain_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_carnival_token_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_time_rune_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_moon_rune_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_earth_rune_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_star_rune_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chaos_rune_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chaos_rock_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_chaos_rock2_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_gold_armor_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_dragon_potion_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_dragon_potion_empty_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_gold_shield_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_magic_sword_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_wodens_brand_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_spade_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_magic_longbow_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_lightning_gauntlet_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_gallowmere_knight_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_king_peregrins_crown_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_anubis_stone_empty_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_anubis_stone_part1_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_anubis_stone_part2_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_anubis_stone_part3_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_anubis_stone_part4_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_asgard_golem_giants_ocarina_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_shadow_artefact_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_shadow_talisman_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_jack_of_the_green_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_professors_lab_mm.xml")
AddMinimapAtlas("images/map_icons/sdf_gatling_gun_mm.xml")


PrefabFiles =  {
    "sdf",
    "sdf_helmet",
    "sdf_rune_holder",
    "sdf_helmet_honor_of_gallowmere_fx",
    "sdf_morten",
    "sdf_eye_of_amon_ra_marker_fx",
    "sdf_daring_dash_dust_fx",
    "sdf_chalice_hall_of_heroes",
    "sdf_chalice_runestone",
    "sdf_chalice_altar",
    "sdf_chalice_of_souls",
    "sdf_soul_helmet",
    "sdf_witch_talisman",
    "sdf_witch_cauldron",
    "sdf_book_of_gallowmere",
    "sdf_chest_runestone",
    "sdf_chest_wooden",
    "sdf_chest_skull",
    "sdf_chest_lifebottle",
    "sdf_chest_pumpkin",
    "sdf_chest_riddle",
    "sdf_chest_maze",
    "sdf_chest_haunted",
    "sdf_chest_kingdom",
    "sdf_shadow_barrier",
    "sdf_lunar_beam_fx",
    "sdf_wall_wood",
    "sdf_wall_stone",
    "sdf_wall_stone_pillar",
    "sdf_wall_hedge_block",
    "sdf_wall_hedge_decor",
    "sdf_wall_overgrown",
    "sdf_rock",
    "sdf_marble_pillar",
    "sdf_support_pillars",
    "sdf_haunted_ruins_gate",
    "sdf_haunted_ruins_lava_pond",
    "sdf_haunted_ruins_throne",
    "sdf_statue",
    "sdf_information_gargoyle",
    "sdf_merchant_gargoyle",
    "sdf_shop_gargoyle",
    "sdf_mullock_chief_memorial",
    "sdf_healthfountain",
    "sdf_lifebottle",
    "sdf_energyvial",
    "sdf_acorn_cracked",
    "sdf_victorian_suit",
    "sdf_gold_armor",
    "sdf_dragon_potion",
    "sdf_dragon_potion_dragonbreath",
    "sdf_dragon_potion_dragonfire",
    "sdf_dragon_potion_dragonfire_fx",
    --"sdf_anubis_stone",
    "sdf_anubis_stone_necrotic_touch",
    "sdf_anubis_stone_parts",
    "sdf_copper_shield",
    "sdf_silver_shield",
    "sdf_gold_shield",
    "sdf_arm",
    "sdf_small_sword",
    "sdf_broad_sword",
    "sdf_enchanted_sword",
    "sdf_magic_sword",
    "sdf_wodens_brand",
    --"sdf_cane_stick",
    --"sdf_cane_stick_green_debuff",
    "sdf_club",
    "sdf_hammer",
    "sdf_axe",
    "sdf_spade",
    "sdf_throwing_daggers",
    "sdf_crossbow",
    "sdf_standard_bolts",
    --"sdf_flaming_crossbow",
    --"sdf_flaming_bolts",
    "sdf_longbow",
    "sdf_standard_arrows",
    "sdf_flaming_longbow",
    "sdf_flaming_arrows",
    "sdf_magic_longbow",
    "sdf_magical_arrows",
    "sdf_spear",
    "sdf_lightning_gauntlet",
    "sdf_lightning_gauntlet_fx",
    "sdf_lightning",
    "sdf_goodlightning",
    --"sdf_pistol",
    --"sdf_standard_bullets",
    --"sdf_blunderbuss",
    --"sdf_standard_buckshots",
    --"sdf_gatling_gun",
    --"sdf_standard_munitions",
    "sdf_chicken_drumstick",
    --"sdf_bombs",
    "sdf_gallowmere_knight",
    --"sdf_gallowmere_squire",
    --"sdf_king_peregrin",
    "sdf_king_peregrins_crown",
    "sdf_stone_golem",
    "sdf_lava_golem",
    "sdf_haunted_ruins_golem_cradles",
    "sdf_asgard_golem",
    "sdf_asgard_golem_lava_golem",
    "sdf_asgard_golem_giants_ocarina",
    "sdf_asgard_golem_optimize_data",
    --"sdf_pumpkin_king",
    --"sdf_pumpkin_king_plant",
    --"sdf_pumpking_miasma",
    --"sdf_pumpking_guts",
    --"sdf_pumpking_seed_pod",
    --"sdf_pumpking_seed",
    --"sdf_pumpking_creeper",
    --"sdf_pumpking_creeper_plant",
    --"sdf_pumpking_creeper_plant_spawner",
    --"sdf_pumpking_bomb",
    --"sdf_pumpking_bomb_plant",
    --"sdf_pumpking_bomb_plant_spawner",
    --"sdf_pumpking_gourd",
    --"sdf_pumpking_gourd_vine",
    --"sdf_pumpking_gourd_plant",
    --"sdf_pumpking_gourd_plant_spawner",
    --"sdf_pumpkin_creeper",
    --"sdf_pumpkin_creeper_plant",
    --"sdf_pumpkin_bomb",
    --"sdf_pumpkin_bomb_plant",
    --"sdf_pumpkin_gourd",
    --"sdf_pumpkin_gourd_vine",
    --"sdf_pumpkin_gourd_plant",
    --"sdf_pumpkin_seeds",
    --"sdf_pumpkin_gorge_creeper",
    --"sdf_pumpkin_gorge_bush",
    --"sdf_pumpkin_gorge_roots",
    --"sdf_pumpkin_gorge_plant",
    --"sdf_pumpkin_gorge_farmland",
    --"sdf_pumpkin_gorge_pondfish",
    --"sdf_pumpkin_gorge_pond",
    "sdf_pumpkin_gorge_well",
    "sdf_pumpkin_gorge_well_boundary",
    "sdf_pumpkin_gorge_well_door_exit",
    "sdf_pumpkin_gorge_well_floor",
    "sdf_pumpkin_gorge_well_glowshroom",
    "sdf_pumpkin_gorge_well_merchant_gargoyle",
    "sdf_pumpkin_gorge_well_vine",
    --"sdf_enchanted_earth_tomb",
    --"sdf_enchanted_earth_tomb_boundary",
    --"sdf_enchanted_earth_tomb_door_exit",
    --"sdf_enchanted_earth_tomb_floor",
    --"sdf_shadow_artefact",
    --"sdf_shadow_talisman",
    --"sdf_shadow_demon_tomb_altar",
    --"sdf_shadow_demonette",
    --"sdf_shadow_demonette_projectile_fx",
    "sdf_carnival_token",
    "sdf_time_rune",
    "sdf_time_rune_clock_fx",
    "sdf_time_rune_hall_of_heroes",
    "sdf_moon_rune",
    "sdf_earth_rune",
    "sdf_star_rune",
    "sdf_chaos_rune",
    "sdf_chaos_rock",
    "sdf_chaos_rock2",
    "sdf_asylum_grounds_keeper_grave",
    "sdf_asylum_grounds_keeper",
    "sdf_asylum_grounds_gate",
    "sdf_asylum_grounds_barrier",
    "sdf_jack_of_the_green",
    "sdf_jack_of_the_green_flower",
    "sdf_jack_of_the_green_vase",
    "sdf_jack_of_the_green_riddle_star",
    "sdf_jack_of_the_green_riddle_face_slab",
    "sdf_jack_of_the_green_riddle_clown",
    "sdf_jack_of_the_green_riddle_chaos_rune_crumbled",
    "sdf_jack_of_the_green_riddle_chaos_rune_fragment",
    "sdf_jack_of_the_green_riddle_moleworm",
    "sdf_jack_of_the_green_riddle_moleworm_hill",
    "sdf_jack_of_the_green_riddle_koalefant",
    "sdf_jack_of_the_green_riddle_firepit",
    "sdf_jack_of_the_green_chess_rook_spawner",
    "sdf_jack_of_the_green_chess_rook",
    "sdf_jack_of_the_green_chess_knight_spawner",
    "sdf_jack_of_the_green_chess_knight",
    "sdf_jack_of_the_green_chess_bishop_spawner",
    "sdf_jack_of_the_green_chess_bishop",
    "sdf_jack_of_the_green_chess_bishop_charge",
    --"sdf_professors_lab",
    --"sdf_professors_lab_boundary",
    --"sdf_professors_lab_door_exit",
    --"sdf_professors_lab_floor",
    --"sdf_professors_lab_lights",
    --"sdf_professors_lab_projector",
    --"sdf_professors_lab_generator",
    --"sdf_professors_lab_tesla",
    --"sdf_professors_lab_chalice",
    --"sdf_professors_lab_table",
    --"sdf_spiv",
}


--SDF Voice
local voicenames = { "death_voice", "hurt", "talk_LP", "emote", "ghost_LP", "yawn" }
    for key,sound in pairs(voicenames) do
	RemapSoundEvent("dontstarve/characters/sdf/"..sound, "sdf/characters/sdf/"..sound)
    end

--Gatling Gun Sounds
RemapSoundEvent("dontstarve/characters/tf2heavy/tf2minigun_shoot", "tf2minigun/tf2minigun/tf2minigun_shoot")
RemapSoundEvent("dontstarve/characters/tf2heavy/tf2minigun_revved", "tf2minigun/tf2minigun/tf2minigun_revved")
RemapSoundEvent("dontstarve/characters/tf2heavy/tf2minigun_rev_end", "tf2minigun/tf2minigun/tf2minigun_rev_end")
RemapSoundEvent("dontstarve/characters/tf2heavy/tf2minigun_rev_start", "tf2minigun/tf2minigun/tf2minigun_rev_start")
RemapSoundEvent("dontstarve/characters/tf2heavy/tf2minigun_empty", "tf2minigun/tf2minigun/tf2minigun_empty")
RemapSoundEvent("dontstarve/characters/tf2heavy/ricochet", "tf2minigun/tf2minigun/ricochet")


TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.SDF = {
	"sdf_helmet", "sdf_arm", "sdf_rune_holder"
}

----------------------------------------------
--tester area



----------------------------------------------

TUNING.SDF_FATES_ARROW =GetModConfigData("sdf_fates_arrow") --false
TUNING.SDF_HEALTH_MAX = 60 --60
TUNING.SDF_SOUL_VALUE = 3 --3
TUNING.SDF_SOUL_VALUE_CHANCE = 0.8 --0.8 20%
TUNING.SDF_SOUL_VALUE_PVP = 2 --2
TUNING.SDF_SOUL_VALUE_CRITTER = 1 --1
TUNING.SDF_SOUL_VALUE_EPIC = 30 --30
TUNING.SDF_SOUL_VALUE_EPIC_CHANCE = 0.6 --0.6 40%
TUNING.SDF_SOUL_VALUE_ADJUSTMENT = 0.33 --0.33
TUNING.SDF_MAX_SOUL_BONUS = 1.5 --1.5
TUNING.SDF_DAMAGE_UNARMED = 10 --10
TUNING.SDF_HELMET_BONUS_DAMAGE_TAKEN = 2 --Double Damage
TUNING.SDF_CHALICE_OF_SOUL_MAX = 20 --20 --Do not change
TUNING.SDF_SOUL_HELMET_VALUE = 5 --5
TUNING.SDF_BOOK_OF_GALLOWMERE_HUD_RESOLUTION =GetModConfigData("sdf_book_of_gallowmere_hud_resolution") --1 720,360
TUNING.SDF_BOOK_OF_GALLOWMERE_SANITY_REGEN_AMOUNT = 1 --1
TUNING.SDF_BOOK_OF_GALLOWMERE_SANITY_REGEN_TICK = 10 --10
TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_TOGGLE_COOLDOWN = 1 --1
TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_INVENTORY_TOTAL = 42 --42
TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_FRIENDLIES_TOTAL = 36 --36
TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_ENEMIES_TOTAL = 46 --46
TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_BOSSES_TOTAL = 22 --22
TUNING.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MEND = 2 --2
TUNING.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MAXSTACKCOUNT = 60 --60
TUNING.SDF_INFORMATION_GARGOYLE_UNIQUE_SPAWN_DISTANCE = 30 --30
TUNING.SDF_CHEST_WOODEN_KUL_KATURA_CHANCE = 0.9 --not added yet
TUNING.SDF_CHEST_WOODEN_REGENERATION_DAY_MAX = 15 --15
TUNING.SDF_CHEST_SKULL_AOE_DAMAGE = 300 --300
TUNING.SDF_CHEST_SKULL_SERPENT_OF_GALLOWMERE_CHANCE = 0.9 --not added yet
TUNING.SDF_CHEST_SKULL_REGENERATION_DAY_MAX = 5 --5
TUNING.SDF_CHEST_LIFEBOTTLE_REGENERATION_DAY_MAX = 10 --10
TUNING.SDF_CHEST_PUMPKIN_REGENERATION_DAY_MAX = 15 --15
TUNING.SDF_CHEST_MAZE_REGENERATION_DAY_MAX = 10 --10
TUNING.SDF_CHEST_HAUNTED_REGENERATION_DAY_MAX = 10 --10
TUNING.SDF_CHEST_KINGDOM_REGENERATION_DAY_MAX = 10 --10
TUNING.SDF_CHEST_KINGDOM_GIANTS_OCARINA_CHANCE = 0.05 --0.05
TUNING.SDF_CHEST_KINGDOM_STONE_GOLEM_RESPAWN_TICK = 10 --60
TUNING.SDF_CHEST_KINGDOM_SHADOW_BARRIER_REPEL_RADIUS = 1.3 --1.3
TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_DAMAGE_PERCENT = 0.05 --0.05
TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_DURATION = 10 --10
TUNING.SDF_HAUNTED_RUINS_LAVA_POND_LAVABATHE_DEBUFF_TICK = 1 --1
TUNING.SDF_SHOP_GARGOYLE_WORK = 5 --5
TUNING.SDF_MULLOCK_CHIEF_MEMORIAL_MOUNT_REGENERATION_DAY_MAX = 10 --10
TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX = 120 --120
TUNING.SDF_HEALTHFOUNTAIN_RECOVERY = 10 --10
TUNING.SDF_LIFEBOTTLE_BOSS_DROPS =GetModConfigData("sdf_lifebottle_boss_drops") --true
TUNING.SDF_LIFEBOTTLE_MAX = 9 --Do Not Change
TUNING.SDF_LIFEBOTTLE_HEALTH_MAX = 60 --60
TUNING.SDF_LIFEBOTTLE_RECOVERY = 60 --60
TUNING.SDF_ENERGYVIAL_RECOVERY = 30 --30
TUNING.SDF_ENERGYVIAL_MAXSTACKCOUNT = 10 --10
TUNING.SDF_PUMPKINPIE_HEALTH = 40 --40
TUNING.SDF_PUMPKINPIE_HUNGER = 75 --75
TUNING.SDF_PUMPKINPIE_SANITY = 15 --15
TUNING.SDF_ACORN_CRACKED_MAXSTACKCOUNT = 40 --40
TUNING.SDF_VICTORIAN_SUIT_DURABILITY = 4800 --4800 10days
TUNING.SDF_GOLD_ARMOR_ABSORB = 0.85 --0.85
TUNING.SDF_GOLD_ARMOR_PLANAR_DEF = 10 --10
TUNING.SDF_GOLD_ARMOR_DURABILITY = 780 --780
TUNING.SDF_SUPERARMOR_MAX = 60 --60
TUNING.SDF_SUPERARMOR_PROTECTION = 0.25 --0.25
TUNING.SDF_DRAGON_POTION_WET_RESIST = 0.5 --0.5
TUNING.SDF_DRAGON_POTION_FIRE_RESIST = 1 --1
TUNING.SDF_DRAGON_POTION_DURATION = 480 --240
TUNING.SDF_DRAGON_POTION_BREATHEFIRE_DAMAGE = 8 --8
TUNING.SDF_DRAGON_POTION_BREATHEFIRE_PLANAR_DAMAGE = 8 --8
TUNING.SDF_DRAGON_POTION_BREATHEFIRE_CONSUME_FUEL = 20 --20
TUNING.SDF_DRAGON_POTION_BREATHEFIRE_DURATION = 5 --5
TUNING.SDF_DRAGON_POTION_DRAGONFIRE_DAMAGE = 16 --16
TUNING.SDF_DRAGON_POTION_DRAGONFIRE_PLANAR_DAMAGE = 16 --16
TUNING.SDF_DRAGON_POTION_DRAGONFIRE_BREATH_HEAT = 240 --240
TUNING.SDF_DRAGON_POTION_DRAGONFIRE_BREATH_FUEL = 7.5 --7.5
TUNING.SDF_DRAGON_POTION_DRAGONFIRE_EMBER_HEAT = 30 --30
TUNING.SDF_ANUBIS_STONE_ARMOR_DEF = 0.1 --0.1
TUNING.SDF_ANUBIS_STONE_ARMOR_PLANAR_DEF = 2
TUNING.SDF_ANUBIS_STONE_NECRO_HEAL = 10 --10
TUNING.SDF_ANUBIS_STONE_NECRO_HEAL_UNDEATH_MULTI = 2 --2
TUNING.SDF_ANUBIS_STONE_REANIMATE_USAGE = 10 --10
TUNING.SDF_ANUBIS_STONE_REANIMATE_COOLDOWN = 5 --5
TUNING.SDF_ANUBIS_STONE_REANIMATE_RANGE = 12 --12
TUNING.SDF_ANUBIS_STONE_REANIMATE_AOE_RADIUS = 4.1 --4.1
TUNING.SDF_ANUBIS_STONE_NECRO_RECHARGE = 60 --60
TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE = 0.04 --0.04
TUNING.SDF_ANUBIS_STONE_SOUL_HELMET_CHANCE_EPIC = 0.25 --0.25
TUNING.SDF_ANUBIS_STONE_REGEN = 1 --1
TUNING.SDF_ANUBIS_STONE_REGEN_TICK = 6 --6
TUNING.SDF_ANUBIS_STONE_DURABILITY = 100 --100
TUNING.SDF_SHIELD_PROTECTION = 0.30 --0.30
TUNING.SDF_SHIELD_BROKEN_PROTECTION = 0.65 --0.65
TUNING.SDF_SHIELD_COOLDOWN = 5 --5
TUNING.SDF_SHIELD_COOLDOWN_ONEQUIP = 3 --3
TUNING.SDF_SHIELD_COOLDOWN_ONPARRY_REDUCTION = 0.6 --0.6
TUNING.SDF_SHIELD_PARRY_STUN_DEBUFF_DURATION = 3 --3
TUNING.SDF_SHIELD_PARRY_BONUS_DAMAGE_SCALE = 0.2 --0.2
TUNING.SDF_SHIELD_PARRY_BONUS_DAMAGE = { min=1, max=15 } --1\15
TUNING.SDF_SHIELD_PARRY_BONUS_DAMAGE_DURATION = 5 --5
TUNING.SDF_SHIELD_PARRY_ARC = 178 --178
TUNING.SDF_SHIELD_PARRY_DURATION = 1 --1 *unchangeable*
TUNING.SDF_COPPER_SHIELD_DURABILITY = 300 --150
TUNING.SDF_SILVER_SHIELD_DURABILITY = 500 --250
TUNING.SDF_GOLD_SHIELD_DURABILITY = 800 --400
TUNING.SDF_ARM_DAMAGE = 10 --10
TUNING.SDF_ARM_ATTACK_SPEED = 0.5 --0.5
TUNING.SDF_ARM_PROJECTILE_SPEED = 15 --15
TUNING.SDF_SMALL_SWORD_DAMAGE = 27.5 --27.5
TUNING.SDF_SMALL_SWORD_ATTACK_SPEED = 0.2 --0.2
TUNING.SDF_SMALL_SWORD_DURABILITY = 175 --175
TUNING.SDF_BROAD_SWORD_DAMAGE = 44.2 --44.2
TUNING.SDF_BROAD_SWORD_ATTACK_SPEED = 0.6 --0.6
TUNING.SDF_BROAD_SWORD_AOE_RANGE = 1.2 --1.2
TUNING.SDF_BROAD_SWORD_DURABILITY = 100 --100
TUNING.SDF_ENCHANTED_SWORD_DAMAGE = 44.2 --44.2
TUNING.SDF_ENCHANTED_SWORD_PLANAR_DAMAGE = 22.1 --22.1
TUNING.SDF_ENCHANTED_SWORD_ATTACK_SPEED = 0.6 --0.6
TUNING.SDF_ENCHANTED_SWORD_AOE_RANGE = 1.3 --1.3
TUNING.SDF_ENCHANTED_SWORD_DURATION = 90 --90
TUNING.SDF_MAGIC_SWORD_DAMAGE = 44.2 --44.2
TUNING.SDF_MAGIC_SWORD_PLANAR_DAMAGE = 22.1 --22.1
TUNING.SDF_MAGIC_SWORD_ATTACK_SPEED = 0.6 --0.5
TUNING.SDF_MAGIC_SWORD_AOE_RANGE = 1.4 --1.4
TUNING.SDF_MAGIC_SWORD_REGEN = 0.02 --0.02
TUNING.SDF_MAGIC_SWORD_DURABILITY = 150 --150
TUNING.SDF_WODENS_BRAND_DAMAGE = 66.6 --66.6
TUNING.SDF_WODENS_BRAND_PLANAR_DAMAGE = 33.3 --33.3
TUNING.SDF_WODENS_BRAND_ATTACK_SPEED = 0.8 --0.8
TUNING.SDF_WODENS_BRAND_PROTECTION = 0.30 --0.30
TUNING.SDF_WODENS_BRAND_BROKEN_DAMAGE = 27.5 --27.5
TUNING.SDF_WODENS_BRAND_BROKEN_ATTACK_SPEED = 1.4 --1.4
TUNING.SDF_WODENS_BRAND_BROKEN_PROTECTION = 0.65 --0.65
TUNING.SDF_WODENS_BRAND_AOE_RANGE = 1.6 --1.6
TUNING.SDF_WODENS_BRAND_SPEED_MULT = 0.9 --0.9
TUNING.SDF_WODENS_BRAND_USEDAMAGE = 1 --1
TUNING.SDF_WODENS_BRAND_COOLDOWN = 10 --10
TUNING.SDF_WODENS_BRAND_COOLDOWN_ONEQUIP = 3 --3
TUNING.SDF_WODENS_BRAND_COOLDOWN_ONPARRY_REDUCTION = 0.7 --0.7
TUNING.SDF_WODENS_BRAND_PARRY_STUN_DEBUFF_DURATION = 3 --3
TUNING.SDF_WODENS_BRAND_PARRY_BONUS_DAMAGE_SCALE = 0.4 --0.4
TUNING.SDF_WODENS_BRAND_PARRY_BONUS_DAMAGE = { min=5, max=30 } --5\30
TUNING.SDF_WODENS_BRAND_PARRY_BONUS_DAMAGE_DURATION = 5 --5
TUNING.SDF_WODENS_BRAND_PARRY_ARC = 178 --178
TUNING.SDF_WODENS_BRAND_PARRY_DURATION = 3 --3
TUNING.SDF_WODENS_BRAND_DURABILITY = 200 --200
TUNING.SDF_CANE_STICK_DAMAGE = 27.5 --27.5
TUNING.SDF_CANE_STICK_ATTACK_SPEED = 0.5 --0.5
TUNING.SDF_CANE_STICK_SPEED_MULT = 1.3 --1.3
TUNING.SDF_CANE_STICK_COOLDOWN = 3 --3
TUNING.SDF_CANE_STICK_USAGE = 1 --1
TUNING.SDF_CANE_STICK_DURABILITY = 200 --200
TUNING.SDF_CANE_STICK_PURPLE_DRAIN = 6 --6
TUNING.SDF_CANE_STICK_YELLOW_ELETRIC_DAMAGE = 4 --4
TUNING.SDF_CANE_STICK_YELLOW_ELETRIC_DAMAGE_MULTI = 3 --3
TUNING.SDF_CANE_STICK_GREEN_ROOT_DAMAGE = 2 --2
TUNING.SDF_CANE_STICK_GREEN_ROOT_TIME = 3 --3
TUNING.SDF_CANE_STICK_ORANGE_REPAIR_PERCENT_AMOUNT = 0.01 --0.01
TUNING.SDF_CANE_STICK_AURA_RECOVERY = 1 --1
TUNING.SDF_CANE_STICK_AURA_RATE = 10 --10
TUNING.SDF_CANE_STICK_AURA_RANGE = 15 --15
TUNING.SDF_CLUB_DAMAGE = 46.5 --46.5
TUNING.SDF_CLUB_AOE_DAMAGE = 0.2 --0.2 9.3
TUNING.SDF_CLUB_ATTACK_SPEED = 0.7 --0.7
TUNING.SDF_CLUB_AOE_RADIUS = 1.1 --1.1
TUNING.SDF_CLUB_WORK_MINE = 1.5 --1.5
TUNING.SDF_CLUB_WORK_HAMMER = 1.5 --1.5
TUNING.SDF_CLUB_WORK_CONSUME = 4 --4
TUNING.SDF_CLUB_WET_RESIST = 0.2 --0.2
TUNING.SDF_CLUB_ENFLAME_RANGE = 0.3 --0.3
TUNING.SDF_CLUB_ENFLAME_RETICULE_SIDE_RANGE = 3.25 --3.25
TUNING.SDF_CLUB_ENFLAME_COMBAT_CONSUME = 1 --1
TUNING.SDF_CLUB_ENFLAME_IGNITE_CONSUME = 3 --3
TUNING.SDF_CLUB_ENFLAME_FUEL = 15 --15
TUNING.SDF_CLUB_ENFLAME_DURATION = 60 --60
TUNING.SDF_CLUB_DURABILITY = 75 --75
TUNING.SDF_HAMMER_DAMAGE = 46.5 --46.5
TUNING.SDF_HAMMER_AOE_DAMAGE_MULTI = 0.2 --0.2 9.3
TUNING.SDF_HAMMER_SHOCKWAVE_DAMAGE_MULTI = 1.3 --1.3  60.4
TUNING.SDF_HAMMER_ATTACK_SPEED = 0.9 --0.9
TUNING.SDF_HAMMER_AOE_RADIUS = 1.1 --1.1
TUNING.SDF_HAMMER_SHOCKWAVE_RANGE = 2 --2
TUNING.SDF_HAMMER_SHOCKWAVE_AOE_RADIUS = 4.1 --4.1
TUNING.SDF_HAMMER_SHOCKWAVE_RETICULE_RADIUS = 0.9 --0.9
TUNING.SDF_HAMMER_SHOCKWAVE_CONSUME = 5 --5
TUNING.SDF_HAMMER_SHOCKWAVE_COOLDOWN = 10 --10
TUNING.SDF_HAMMER_WORK_MINE = 1.5 --1.5
TUNING.SDF_HAMMER_WORK_HAMMER = 1.5 --1.5
TUNING.SDF_HAMMER_SHOCKWAVE_WORK_MINE = 4.5 --4.5
TUNING.SDF_HAMMER_SHOCKWAVE_WORK_HAMMER = 4.5 --4.5
TUNING.SDF_HAMMER_WORK_CONSUME = 0.5 --0.5
TUNING.SDF_HAMMER_SHOCKWAVE_STUN_DEBUFF_DURATION = 2 --2
TUNING.SDF_HAMMER_SINKHOLE_RADIUS = 2 --2
TUNING.SDF_HAMMER_SINKHOLE_TICK = 0.1 --0.1
TUNING.SDF_HAMMER_SINKHOLE_DURATION = 2 --2
TUNING.SDF_HAMMER_SINKHOLE_MOVESPEED_DEBUFF = 0.35 --0.35
TUNING.SDF_HAMMER_SINKHOLE_MOVESPEED_DEBUFF_DURATION = 0.3 --0.3
TUNING.SDF_HAMMER_DURABILITY = 250 --250
TUNING.SDF_AXE_DAMAGE = 42 --42
TUNING.SDF_AXE_THROW_DAMAGE_MULTI = 1.3 --1.3 54.6
TUNING.SDF_AXE_ATTACK_SPEED = 0.7 --0.7
TUNING.SDF_AXE_PROJECTILE_SPEED = 15 --15
TUNING.SDF_AXE_WORK_CHOP = 1.5 --1.5
TUNING.SDF_AXE_WORK_CONSUME = 0.5 --0.5
TUNING.SDF_AXE_USAGE = 4 --4
TUNING.SDF_AXE_DURABILITY = 200 --200
TUNING.SDF_SPADE_DAMAGE = 20.4 --20.4
TUNING.SDF_SPADE_ATTACK_SPEED = 0.7 --0.7
TUNING.SDF_SPADE_WORK_CONSUME = 0.5 --0.5
TUNING.SDF_SPADE_DURABILITY = 250 --250
TUNING.SDF_THROWING_DAGGERS_DAMAGE = 23.8 --23.8
TUNING.SDF_THROWING_DAGGERS_RANGE = 7 --7
TUNING.SDF_THROWING_DAGGERS_ATTACK_SPEED = 1.2 --1.2
TUNING.SDF_THROWING_DAGGERS_PROJECTILE_SPEED = 20 --20
TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_HEMORRHAGE_DEBUFF_DURATION = 15 --15
TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_HEMORRHAGE_DEBUFF_TICK = 3 --3
TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_THROW_AMOUNT = 3 --3
TUNING.SDF_THROWING_DAGGERS_POWER_ATTACK_COOLDOWN = 10 --10
TUNING.SDF_THROWING_DAGGERS_MAXSTACKCOUNT = 40 --40
TUNING.SDF_RANGE_MELEE_ATTACK_SPEED = 1.2 --1.2
TUNING.SDF_CROSSBOW_RANGE = 10 --10
TUNING.SDF_CROSSBOW_ATTACK_SPEED = 0.1 --0.1
TUNING.SDF_CROSSBOW_USAGE = 1 --1
TUNING.SDF_CROSSBOW_POWER_ATTACK_RICHOCHET_RADIUS = 5.2 --5.2
TUNING.SDF_CROSSBOW_POWER_ATTACK_RICHOCHET_MULTI = 0.5 --0.5
TUNING.SDF_CROSSBOW_POWER_ATTACK_SHOOT_AMOUNT = 4 --4
TUNING.SDF_CROSSBOW_POWER_ATTACK_SHOOT_SPEED = 0.4 --0.4
TUNING.SDF_CROSSBOW_POWER_ATTACK_USAGE = 2 --2
TUNING.SDF_CROSSBOW_POWER_ATTACK_COOLDOWN = 10 --10
TUNING.SDF_CROSSBOW_DURABILITY = 200 --200
TUNING.SDF_STANDARD_BOLTS_DAMAGE = 8.5 --8.5
TUNING.SDF_STANDARD_BOLTS_PROJECTILE_SPEED = 25 --25
TUNING.SDF_STANDARD_BOLTS_MAXSTACKCOUNT = 60 --60
TUNING.SDF_FLAMING_CROSSBOW_RANGE = 10 --10
TUNING.SDF_FLAMING_CROSSBOW_ATTACK_SPEED =0.1 --0.1
TUNING.SDF_FLAMING_CROSSBOW_USAGE = 1 --1
TUNING.SDF_FLAMING_CROSSBOW_POWER_ATTACK_AOE_RADIUS = 1.6 --1.6
TUNING.SDF_FLAMING_CROSSBOW_POWER_ATTACK_SHOOT_AMOUNT = 4 --4
TUNING.SDF_FLAMING_CROSSBOW_POWER_ATTACK_SHOOT_SPEED = 0.4 --0.4
TUNING.SDF_FLAMING_CROSSBOW_POWER_ATTACK_USAGE = 2 --2
TUNING.SDF_FLAMING_CROSSBOW_POWER_ATTACK_COOLDOWN = 10 --10
TUNING.SDF_FLAMING_CROSSBOW_DURABILITY = 200 --200
TUNING.SDF_FLAMING_BOLTS_DAMAGE = 8.5 --8.5
TUNING.SDF_FLAMING_BOLTS_PROJECTILE_SPEED = 25 --25
TUNING.SDF_FLAMING_BOLTS_MAXSTACKCOUNT = 40 --40
TUNING.SDF_LONGBOW_RANGE = 12 --12
TUNING.SDF_LONGBOW_ATTACK_SPEED = 2.0 --0.9
TUNING.SDF_LONGBOW_USAGE = 1 --1
TUNING.SDF_LONGBOW_POWER_ATTACK_DAMAGE_MULTI = 2.2 --2.2
TUNING.SDF_LONGBOW_POWER_ATTACK_USAGE = 2 --2
TUNING.SDF_LONGBOW_POWER_ATTACK_COOLDOWN = 15 --15
TUNING.SDF_LONGBOW_DURABILITY = 200 --200
TUNING.SDF_STANDARD_ARROWS_DAMAGE = 34 --34
TUNING.SDF_STANDARD_ARROWS_PROJECTILE_SPEED = 20 --20
TUNING.SDF_STANDARD_ARROWS_MAXSTACKCOUNT = 60 --60
TUNING.SDF_FLAMING_LONGBOW_RANGE = 12 --12
TUNING.SDF_FLAMING_LONGBOW_ATTACK_SPEED = 0.9 --0.9
TUNING.SDF_FLAMING_LONGBOW_USAGE = 1 --1
TUNING.SDF_FLAMING_LONGBOW_POWER_ATTACK_DAMAGE_MULTI = 1.1 --1.1
TUNING.SDF_FLAMING_LONGBOW_POWER_ATTACK_AOE_RADIUS = 3.8 --3.8
TUNING.SDF_FLAMING_LONGBOW_POWER_ATTACK_USAGE = 2 --2
TUNING.SDF_FLAMING_LONGBOW_POWER_ATTACK_COOLDOWN = 15 --15
TUNING.SDF_FLAMING_LONGBOW_DURABILITY = 200 --200
TUNING.SDF_FLAMING_ARROWS_DAMAGE = 34 --34
TUNING.SDF_FLAMING_ARROWS_PROJECTILE_SPEED = 20 --20
TUNING.SDF_FLAMING_ARROWS_MAXSTACKCOUNT = 40 --40
TUNING.SDF_MAGIC_LONGBOW_RANGE = 12 --12
TUNING.SDF_MAGIC_LONGBOW_ATTACK_SPEED = 0.9 --0.9
TUNING.SDF_MAGIC_LONGBOW_USAGE = 1 --1
TUNING.SDF_MAGIC_LONGBOW_POWER_ATTACK_DAMAGE_MULTI = 1.2 --1.2
TUNING.SDF_MAGIC_LONGBOW_POWER_ATTACK_AOE_RADIUS = 3.8 --3.8
TUNING.SDF_MAGIC_LONGBOW_POWER_ATTACK_USAGE = 2 --2
TUNING.SDF_MAGIC_LONGBOW_POWER_ATTACK_COOLDOWN = 15 --15
TUNING.SDF_MAGIC_LONGBOW_REGEN = 0.02 --0.02
TUNING.SDF_MAGIC_LONGBOW_DURABILITY = 200 --200
TUNING.SDF_MAGICAL_ARROWS_DAMAGE = 34 --34
TUNING.SDF_MAGICAL_ARROWS_PLANAR_DAMAGE = 17 --17
TUNING.SDF_MAGICAL_ARROWS_AOE_PLANAR_DAMAGE = 17 --17
TUNING.SDF_MAGICAL_ARROWS_PROJECTILE_SPEED = 20 --20
TUNING.SDF_MAGICAL_ARROWS_MAXSTACKCOUNT = 20 --20
TUNING.SDF_SPEAR_DAMAGE = 71.4 --71.4
TUNING.SDF_SPEAR_RANGE = 15 --15
TUNING.SDF_SPEAR_ATTACK_SPEED = 3 --3
TUNING.SDF_SPEAR_PROJECTILE_SPEED = 20 --20
TUNING.SDF_SPEAR_POWER_ATTACK_DAMAGE_MULTI = 1.2 --1.2
TUNING.SDF_SPEAR_POWER_ATTACK_SUNDER_ARMOR_DEBUFF_MULTI = 1.5 --1.5
TUNING.SDF_SPEAR_POWER_ATTACK_SUNDER_ARMOR_DEBUFF_DURATION = 30 --30
TUNING.SDF_SPEAR_POWER_ATTACK_COOLDOWN = 15 --15
TUNING.SDF_SPEAR_MAXSTACKCOUNT = 20 --20
TUNING.SDF_LIGHTNING_GAUNTLET_DAMAGE = 20 --20
TUNING.SDF_LIGHTNING_GAUNTLET_ATTACK_SPEED = 0.8 --0.8
TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_ATTACK_SPEED = 2 --2
TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_RANGE = 12 --12
TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_USAGE = 1 --1
TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_USAGE = 2 --2
TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_CONSUME = 1 --1
TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_CONSUME = 5 --5
TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_COOLDOWN = 20 --20
TUNING.SDF_LIGHTNING_GAUNTLET_TOGGLE_COOLDOWN = 1 --1
TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_LIGHTNING_ROD_NEW_PERCENT = 0.1 --0.1
TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_LIGHTNING_ROD_RECHARGE_PERCENT = 0.2 --0.2
TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_PROFESSORS_LAB_NEW_TESLA_PERCENT = 0.5 --0.5
TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_PROFESSORS_LAB_RECHARGE_TESLA_PERCENT = 1 --1
TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_HOH_CHALICE_SAMPLE_PERCENT = 1 --1
TUNING.SDF_LIGHTNING_GAUNTLET_TRANSFER_COOLDOWN = 2 --2
TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_RANGE = 12 --12
TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_AOE_RADIUS = 4.1 --4.1
TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_RETICULE_RADIUS = 0.9 --0.9
TUNING.SDF_LIGHTNING_GAUNTLET_DURABILITY = 400 --400
TUNING.SDF_LIGHTNING_DAMAGE = 18 --18
TUNING.SDF_LIGHTNING_PLANAR_DAMAGE = 18 --18
TUNING.SDF_LIGHTNING_CHARGED_DAMAGE = 72 --72
TUNING.SDF_LIGHTNING_CHARGED_PLANAR_DAMAGE = 72 --72
TUNING.SDF_LIGHTNING_PROJECTILE_SPEED = 25 --25
TUNING.SDF_LIGHTNING_STATIC_PROJECTILE_SPEED = 8 --8
TUNING.SDF_LIGHTNING_STATIC_RANGE = 14 --14
TUNING.SDF_LIGHTNING_STATIC_AOE_RADIUS = 5 --5
TUNING.SDF_LIGHTNING_STATIC_MAX_SPAWN_COUNT = 1 --1
TUNING.SDF_LIGHTNING_STATIC_MAX_CHAIN_COUNT = 4 --4
TUNING.SDF_LIGHTNING_STATIC_DEBUFF_DURATION = 0.3 --0.3
TUNING.SDF_LIGHTNING_MOVESPEED_DEBUFF = 0.6 --0.6
TUNING.SDF_LIGHTNING_CHARGED_MOVESPEED_DEBUFF = 0.3 --0.3
TUNING.SDF_LIGHTNING_MOVESPEED_DEBUFF_DURATION = 3 --3
TUNING.SDF_LIGHTNING_CHARGED_MOVESPEED_DEBUFF_DURATION = 6 --6
TUNING.SDF_LIGHTNING_DURABILITY = 100 --100
TUNING.SDF_GOODLIGHTNING_HEAL = 20 --20
TUNING.SDF_GOODLIGHTNING_CHARGED_HEAL = 60 --60
TUNING.SDF_GOODLIGHTNING_SANITY_HEAL = 1 --1
TUNING.SDF_GOODLIGHTNING_CHARGED_SANITY_HEAL = 5 --5
TUNING.SDF_GOODLIGHTNING_HEAL_UNDEATH_MULTI = 2 --2
TUNING.SDF_GOODLIGHTNING_PROJECTILE_SPEED = 25 --25
TUNING.SDF_GOODLIGHTNING_STATIC_PROJECTILE_SPEED = 8 --8
TUNING.SDF_GOODLIGHTNING_STATIC_RANGE = 14 --14
TUNING.SDF_GOODLIGHTNING_STATIC_AOE_RADIUS = 5 --5
TUNING.SDF_GOODLIGHTNING_STATIC_MAX_SPAWN_COUNT = 1 --1
TUNING.SDF_GOODLIGHTNING_STATIC_MAX_CHAIN_COUNT = 4 --4
TUNING.SDF_GOODLIGHTNING_STATIC_DEBUFF_DURATION = 0.3 --0.3
TUNING.SDF_GOODLIGHTNING_AGGRO_DEBUFF_DURATION = 20 --20
TUNING.SDF_GOODLIGHTNING_CHARGED_AGGRO_DEBUFF_DURATION = 60 --60
TUNING.SDF_GOODLIGHTNING_DURABILITY = 100 --100
TUNING.SDF_PISTOL_RANGE = 10 --10
TUNING.SDF_PISTOL_ATTACK_SPEED = 0.6 --0.6
TUNING.SDF_PISTOL_USAGE = 1 --1
TUNING.SDF_PISTOL_COOLDOWN = 3 --3
TUNING.SDF_PISTOL_OVERHEAT_MAX = 3600 --3600
TUNING.SDF_PISTOL_OVERHEAT_USAGE = 0.16 --0.16
TUNING.SDF_PISTOL_OVERHEAT_COOLDOWN_RATE = 0 --0
TUNING.SDF_PISTOL_POWER_ATTACK_SHOOT_AMOUNT = 6 --6
TUNING.SDF_PISTOL_POWER_ATTACK_SHOOT_SPEED = 1.2 --0.4
TUNING.SDF_PISTOL_POWER_ATTACK_USAGE = 2 --2
TUNING.SDF_PISTOL_POWER_ATTACK_COOLDOWN = 10 --10
TUNING.SDF_PISTOL_DURABILITY = 200 --200
TUNING.SDF_STANDARD_BULLETS_DAMAGE = 17 --17
TUNING.SDF_STANDARD_BULLETS_PROJECTILE_SPEED = 40 --40
TUNING.SDF_STANDARD_BULLETS_MAXSTACKCOUNT = 40 --40
TUNING.SDF_BLUNDERBUSS_RANGE = 4 --4
TUNING.SDF_BLUNDERBUSS_ATTACK_SPEED = 4.0 --4.0
TUNING.SDF_BLUNDERBUSS_USAGE = 1 --1
TUNING.SDF_BLUNDERBUSS_BOMBARD_AOE_RANGE = 12 --12
TUNING.SDF_BLUNDERBUSS_BOMBARD_USAGE = 2 --2
TUNING.SDF_BLUNDERBUSS_BOMBARD_COOLDOWN = 15 --15
TUNING.SDF_BLUNDERBUSS_DURABILITY = 200 --200
TUNING.SDF_STANDARD_BUCKSHOTS_DAMAGE = 102 --102
TUNING.SDF_STANDARD_BUCKSHOTS_PROJECTILE_SPEED = 40 --40
TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_DAMAGE_MULTI = 0.5 --0.5
TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_RADIUS = 2.4 --2.4
TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_PROJECTILE_SPEED = 40 --40
TUNING.SDF_STANDARD_BUCKSHOTS_BOMBARD_AOE_WORK = 10 --10
TUNING.SDF_STANDARD_BUCKSHOTS_MAXSTACKCOUNT = 20 --20
TUNING.SDF_BOMBS_ATTACK_SPEED = 4.0 --4.0
TUNING.SDF_BOMBS_DAMAGE = 200 --200
TUNING.SDF_BOMBS_MAXSTACKCOUNT = 20 --20
TUNING.SDF_BOMBS_PROTECTION_TIME = 30 --30
TUNING.SDF_BOMBS_SINKHOLE_RADIUS = 2 --2
TUNING.SDF_BOMBS_SINKHOLE_TICK = 0.1 --0.1
TUNING.SDF_BOMBS_SINKHOLE_DURATION = 20 --20
TUNING.SDF_BOMBS_SINKHOLE_MOVESPEED_DEBUFF = 0.35 --0.35
TUNING.SDF_BOMBS_SINKHOLE_MOVESPEED_DEBUFF_DURATION = 0.3 --0.3
TUNING.SDF_GATLING_GUN_SPEED_MULT = 0.8 --0.8 -20%
TUNING.SDF_GATLING_GUN_USAGE = 1 --1
TUNING.SDF_GATLING_GUN_OVERHEAT_USAGE = 0.02 --0.04
TUNING.SDF_GATLING_GUN_OVERHEAT_COOLDOWN_RATE = 0.2 --0.2
TUNING.SDF_GATLING_GUN_DURABILITY = 2160 --2160
TUNING.SDF_STANDARD_MUNITIONS_DAMAGE = 14 --22
TUNING.SDF_STANDARD_MUNITIONS_WORK_DAMAGE = 0.35 --0.35
TUNING.SDF_STANDARD_MUNITIONS_PVP_DAMAGE_MULT = 0.5 --0.5
TUNING.SDF_STANDARD_MUNITIONS_PROJECTILE_SPEED = 22 --22
TUNING.SDF_STANDARD_MUNITIONS_BULLETSPREAD_INTENSITY = 0.6 --0.6
TUNING.SDF_STANDARD_MUNITIONS_MOVESPEED_DEBUFF = 0.6 --0.6
TUNING.SDF_STANDARD_MUNITIONS_DEBUFF_DURATION = 1 --1
TUNING.SDF_STANDARD_MUNITIONS_USAGE = 1 --1
TUNING.SDF_STANDARD_MUNITIONS_DURABILITY = 240 --240
TUNING.SDF_CHICKEN_DRUMSTICK_DING_TIME = 5 --5
TUNING.SDF_CHICKEN_DRUMSTICK_AOE_RADIUS = 5 --5
TUNING.SDF_CHICKEN_DRUMSTICK_AOE_HITCAP = 4 --4
TUNING.SDF_CHICKEN_DRUMSTICK_ATTACK_SPEED = 1 --1
TUNING.SDF_CHICKEN_DRUMSTICK_PROJECTILE_SPEED = 15 --15
TUNING.SDF_CHICKEN_DRUMSTICK_MAXSTACKCOUNT = 10 --10
TUNING.SDF_GALLOWMERE_KNIGHT_WEAPON = GetModConfigData("sdf_gallowmere_knight_weapon") --"sdf_small_sword"
TUNING.SDF_GALLOWMERE_KNIGHT_SHIELD = GetModConfigData("sdf_gallowmere_knight_shield") --"sdf_silver_shield"
TUNING.SDF_GALLOWMERE_KNIGHT_ATTACK = 20 --20 --Backup Damage
TUNING.SDF_GALLOWMERE_KNIGHT_ATTACK_SPEED = 3.5 --3.5
TUNING.SDF_GALLOWMERE_KNIGHT_MOVEMENT_SPEED = 7 --7
TUNING.SDF_GALLOWMERE_KNIGHT_ENERGYVIAL_CHANCE = 1 --1
TUNING.SDF_GALLOWMERE_KNIGHT_HEALTH = 120 --120
TUNING.SDF_GALLOWMERE_KNIGHT_SILVER_DEFENSE = 0.75 --0.75
TUNING.SDF_GALLOWMERE_KNIGHT_COPPER_DEFENSE = 0.50 --0.50
TUNING.SDF_GALLOWMERE_KNIGHT_DEFENSE = 0.25 --0.25 --Backup Defense
TUNING.SDF_GALLOWMERE_KNIGHT_FLAMMABILITY = 0.33 --0.33
TUNING.SDF_GALLOWMERE_KNIGHT_EXPLORE_SINKHOLE = true --true
TUNING.SDF_GALLOWMERE_SQUIRE_WEAPON = "sdf_small_sword"
TUNING.SDF_GALLOWMERE_SQUIRE_SHIELD = "sdf_copper_shield"
TUNING.SDF_GALLOWMERE_SQUIRE_ATTACK = 15 --15 --Backup Damage
TUNING.SDF_GALLOWMERE_SQUIRE_ATTACK_SPEED = 3.5 --3.5
TUNING.SDF_GALLOWMERE_SQUIRE_MOVEMENT_SPEED = 6 --6
TUNING.SDF_GALLOWMERE_SQUIRE_DECAY_HEALTH = 5 --5
TUNING.SDF_GALLOWMERE_SQUIRE_DECAY_TICK = 10 --10
TUNING.SDF_GALLOWMERE_SQUIRE_ENERGYVIAL_CHANCE = 1 --1
TUNING.SDF_GALLOWMERE_SQUIRE_HEALTH = 120 --120
TUNING.SDF_GALLOWMERE_SQUIRE_COPPER_DEFENSE = 0.50 --0.50
TUNING.SDF_GALLOWMERE_SQUIRE_DEFENSE = 0.25 --0.25 --Backup Defense
TUNING.SDF_GALLOWMERE_SQUIRE_FLAMMABILITY = 0.33 --0.33

TUNING.SDF_KING_PEREGRIN_GHOST_SPEED = 2 --2
TUNING.SDF_KING_PEREGRIN_GHOST_CHANCE = 0.05 --0.05
TUNING.SDF_KING_PEREGRIN_UNIQUE_GHOST_DISTANCE = 30 --30
TUNING.SDF_KING_PEREGRIN_GHOST_TRADE_NIGHTMAREFUEL_VALUE = 2 --2
TUNING.SDF_KING_PEREGRIN_GHOST_TRADE_HORRORFUEL_VALUE = 8 --8
TUNING.SDF_KING_PEREGRINS_CROWN_USAGE = 10 --10
TUNING.SDF_KING_PEREGRINS_CROWN_COOLDOWN = 30 --30
TUNING.SDF_KING_PEREGRINS_CROWN_AGGRO_DEBUFF_DURATION = 2 --2
TUNING.SDF_KING_PEREGRINS_CROWN_REGEN = 0.02 --0.02
TUNING.SDF_KING_PEREGRINS_CROWN_DURABILITY = 100 --100

TUNING.SDF_STONE_GOLEM_HEALTH = 9600 ---9600
TUNING.SDF_STONE_GOLEM_HEALTH_SLEEP_REGEN_AMOUNT_PERCENT = 0.25 --2400
TUNING.SDF_STONE_GOLEM_HEALTH_SHIELD_REGEN_PERCENT = 0.005 --0.005  48
TUNING.SDF_STONE_GOLEM_HEALTH_REGEN_PERIOD = 1 --1
TUNING.SDF_STONE_GOLEM_PLANAR_DEFENSE = 10 --10
TUNING.SDF_STONE_GOLEM_ATTACK_DAMAGE = 160 --160
TUNING.SDF_STONE_GOLEM_ATTACK_RANGE = 4 --4
TUNING.SDF_STONE_GOLEM_ATTACK_PERIOD = 8 --8
TUNING.SDF_STONE_GOLEM_ARMORED_WALK_SPEED = 1 --1
TUNING.SDF_STONE_GOLEM_CORE_WALK_SPEED = 1.6 --1.6
TUNING.SDF_STONE_GOLEM_SANITY_AURA = 1 --1
TUNING.SDF_STONE_GOLEM_OPTIMIZE_DATA_CHANCE = 0.1 --0.1
TUNING.SDF_STONE_GOLEM_TARGET_DIST = 20 --20 
TUNING.SDF_STONE_GOLEM_SHIELD_THRESHOLD = 3 --3 1/3 of boss health
TUNING.SDF_STONE_GOLEM_SHIELD_ABSORB = 0.95 --0.95
TUNING.SDF_STONE_GOLEM_SHIELD_DURATION = 5 --5
TUNING.SDF_STONE_GOLEM_SHIELD_PUSH_SPEED = 2 --2
TUNING.SDF_STONE_GOLEM_SHIELD_ARMORED_AVOID_PROJECTILE_ATTACKS = true --true
TUNING.SDF_STONE_GOLEM_SHIELD_CORE_AVOID_PROJECTILE_ATTACKS = false --false
TUNING.SDF_STONE_GOLEM_MAX_SCALE = 1.2 --1.2
TUNING.SDF_STONE_GOLEM_MIN_SCALE = 0.75 --0.75
TUNING.SDF_STONE_GOLEM_SPAWN_MAX_SPAWN = 1 --1
TUNING.SDF_STONE_GOLEM_SPAWN_RELEASE_TIME = 1 --10
TUNING.SDF_STONE_GOLEM_SPAWN_REGEN_TIME = 5 --5
TUNING.SDF_LAVA_GOLEM_HEALTH = 30 --30
TUNING.SDF_LAVA_GOLEM_HEALTH_REGEN_IDLE_AMOUNT = 2 --2
TUNING.SDF_LAVA_GOLEM_HEALTH_REGEN_BUSY_AMOUNT = 1 --1
TUNING.SDF_LAVA_GOLEM_HEALTH_REGEN_IDLE_THRESHOLD_TIME = 5 --5
TUNING.SDF_LAVA_GOLEM_MAX_DAMAGE_PER_HIT = 10 --10
TUNING.SDF_LAVA_GOLEM_ATTACK_DAMAGE = 5 --5
TUNING.SDF_LAVA_GOLEM_PLANAR_DAMAGE = 5 --5
TUNING.SDF_LAVA_GOLEM_ATTACK_RANGE = 30 --30
TUNING.SDF_LAVA_GOLEM_ATTACK_PERIOD = 4 --4
TUNING.SDF_LAVA_GOLEM_SANITY_AURA = 1 --1
TUNING.SDF_LAVA_GOLEM_FIRE_RESIST = 1 --1
TUNING.SDF_LAVA_GOLEM_PROJECTILE_SPEED = 10 --10
TUNING.SDF_LAVA_GOLEM_PROJECTILE_IFRAME_TIME = 1 --1
TUNING.SDF_LAVA_GOLEM_SPAWN_MAX_SPAWN = 1 --1
TUNING.SDF_LAVA_GOLEM_SPAWN_RELEASE_TIME = 1 --10 --10
TUNING.SDF_LAVA_GOLEM_SPAWN_REGEN_TIME = 5 --1920 --480*4 --needs work
TUNING.SDF_ASGARD_GOLEM_HEALTH = 2600 ---2600
TUNING.SDF_ASGARD_GOLEM_HEALTH_SLEEP_REGEN_AMOUNT_PERCENT = 0.001 --2.6
TUNING.SDF_ASGARD_GOLEM_HEALTH_SHIELD_REGEN_PERCENT = 0.016 --0.016 41.6
TUNING.SDF_ASGARD_GOLEM_HEALTH_REGEN_PERIOD = 1 --1
TUNING.SDF_ASGARD_GOLEM_PLANAR_DEFENSE = 10 --10
TUNING.SDF_ASGARD_GOLEM_ATTACK_DAMAGE = 160 --160
TUNING.SDF_ASGARD_GOLEM_ATTACK_AOE_DAMAGE = 80 --80
TUNING.SDF_ASGARD_GOLEM_ATTACK_RANGE = 4 --4
TUNING.SDF_ASGARD_GOLEM_AOE_RANGE = 1.6 --1.6
TUNING.SDF_ASGARD_GOLEM_ATTACK_PERIOD = 8 --8
TUNING.SDF_ASGARD_GOLEM_WALK_SPEED = 3 --3
TUNING.SDF_ASGARD_GOLEM_RUN_SPEED = 7 --7
TUNING.SDF_ASGARD_GOLEM_SHIELD_THRESHOLD = 3 --3 1/3 of health
TUNING.SDF_ASGARD_GOLEM_SHIELD_ABSORB = 0.95 --0.95
TUNING.SDF_ASGARD_GOLEM_SHIELD_DURATION = 10 --10
TUNING.SDF_ASGARD_GOLEM_TAUNT_PERIOD_MIN = 4 --4
TUNING.SDF_ASGARD_GOLEM_TAUNT_PERIOD_MAX = 10 --10
TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_CHANCE = 0.9 --0.9
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_HEALTH = 60 --60
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_HEALTH_DECAY_IDLE_AMOUNT = 5 --5
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_HEALTH_DECAY_BUSY_AMOUNT = 1 --1
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_HEALTH_DECAY_IDLE_THRESHOLD_TIME = 5 --5
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_MAX_DAMAGE_PER_HIT = 10 --10
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_ATTACK_DAMAGE = 5 --5
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_PLANAR_DAMAGE = 5 --5
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_ATTACK_RANGE = 30 --30
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_ATTACK_PERIOD = 0.5 --0.5
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_FIRE_RESIST = 1 --1
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_PROJECTILE_SPEED = 10 --10
TUNING.SDF_ASGARD_GOLEM_LAVA_GOLEM_PROJECTILE_IFRAME_TIME = 1 --1
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_RADIUS = 4.2 --4.2
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_GENERAL_COOLDOWN = 5 --5
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_MODE_CHANGE_COOLDOWN = 10 --10
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_TELEPORT_COOLDOWN = 10 --10
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_SPAWN_COOLDOWN = 20 --20
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_RESPAWN_COOLDOWN = 10 --10days
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_OPTIMIZE_DATA_TYPE_B_COOLDOWN = 300 --300
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_OPTIMIZE_DATA_TYPE_B_ACTIVATE_COMBAT_TIME = 15 --15
TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_OPTIMIZE_DATA_TYPE_B_ACTIVATE_HEALTH_PERCENT = 0.35 --0.35
TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_B_BARRIER_DOME_ABSORB = 1 --1
TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_B_BARRIER_DOME_RADIUS = 8 --8
TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_B_BARRIER_DOME_TICK = 1.5 --1.5
TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_TYPE_B_BARRIER_DOME_DURATION = 15 --15
TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_DECAY_TICK = 60 --60
TUNING.SDF_PUMPKIN_KING_HEALTH = 9600 --9600
TUNING.SDF_PUMPKIN_KING_HEALTH_ABSORB = 0.9 --0.9
TUNING.SDF_PUMPKIN_KING_HEALTH_ABSORB_WEAKEN = 0 --0
TUNING.SDF_PUMPKIN_KING_HEALTH_MAX_DAMAGE_TAKEN = 0.05 --0.05
TUNING.SDF_PUMPKIN_KING_PLANAR_DEFENSE = 5 --5
TUNING.SDF_PUMPKIN_KING_FIRE_DAMAGE = 3 --3
TUNING.SDF_PUMPKIN_KING_FREEZE_TIME = 10 --10
TUNING.SDF_PUMPKIN_KING_DAMAGE = 100 --100
TUNING.SDF_PUMPKIN_KING_RANGE = 12 --12
TUNING.SDF_PUMPKIN_KING_SANITY_AURA = 1 --1
TUNING.SDF_PUMPKIN_KING_GIVEUPRANGE = 22 --22
TUNING.SDF_PUMPKIN_KING_REST_TIME = 5 --5
TUNING.SDF_PUMPKIN_KING_WAKE_TIME = 4 --4
TUNING.SDF_PUMPKIN_KING_STAGE_1 = 0.9 --0.9
TUNING.SDF_PUMPKIN_KING_STAGE_2 = 0.7 --0.7
TUNING.SDF_PUMPKIN_KING_STAGE_3 = 0.4 --0.4
TUNING.SDF_PUMPKIN_KING_DEADHEADING_TIME = 30 --30
TUNING.SDF_PUMPKIN_KING_RESET_TIME = 120 --120
TUNING.SDF_PUMPKIN_KING_AGGRO_DEBUFF_DURATION = 120 --120
TUNING.SDF_PUMPKIN_KING_VINE_LIMIT = 1 --1
TUNING.SDF_PUMPKIN_KING_VINE_HEALTH_DAMAGE_PERCENT = 0.04 --0.04
TUNING.SDF_PUMPKIN_KING_VINE_END_DAMAGE = 65 --65
TUNING.SDF_PUMPKIN_KING_VINE_END_ATTACK_PERIOD = 2 --2
TUNING.SDF_PUMPKIN_KING_VINE_END_ATTACK_RANGE = 4 --4
TUNING.SDF_PUMPKIN_KING_VINE_END_INITIATE_ATTACK = 3 --3
TUNING.SDF_PUMPKIN_KING_VINE_END_CLOSEDIST = 2.5 --2.5
TUNING.SDF_PUMPKIN_KING_VINE_END_MOVEDIST = 2 --2
TUNING.SDF_PUMPKIN_KING_HUSK_SPAWN_REGEN_TICK = 15 --15
TUNING.SDF_PUMPKIN_KING_HUSK_REGEN_TICK = 5 --5
TUNING.SDF_PUMPKIN_KING_HUSK_REGEN_PERCENT = 0.016 --0.002
TUNING.SDF_PUMPKIN_KING_HUSK_WINTER_REGEN_PERCENT = 0.2 --0.2
TUNING.SDF_PUMPKIN_KING_PLANT_GROWTH_TIME = 10 --10 daylight days
TUNING.SDF_PUMPKIN_KING_SEED_MIN_RANGE = 5 --5
TUNING.SDF_PUMPKIN_KING_SEED_MAX_RANGE = 9.75 --9.75
TUNING.SDF_PUMPKIN_KING_SEED_CREEPER_COUNT = 2 --2
TUNING.SDF_PUMPKIN_KING_SEED_GOURD_COUNT = 3 --3
TUNING.SDF_PUMPKIN_KING_SEED_RANDOM_COUNT = 2 --2
TUNING.SDF_PUMPKIN_KING_SEED_COMBO_COOLDOWN = 15 --15
TUNING.SDF_PUMPKIN_KING_SEED_BOMBARDMENT_RANGE = 15 --15
TUNING.SDF_PUMPKIN_KING_SEED_BOMBARDMENT_CHANCE = 0.3 --0.3
TUNING.SDF_PUMPKIN_KING_SEED_BOMBARDMENT_COOLDOWN = 20 --20
TUNING.SDF_PUMPKIN_KING_SEED_REINFORCEMENT_CHANCE = 0.25 --0.25
TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_DAMAGE = 20 --20
TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_HEALTH_PENALTY_DAMAGE = 0.1 --0.1
TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_RADIUS = 10 --10
TUNING.SDF_PUMPKIN_KING_MIASMA_TELEGRAPH_RADIUS = 3 --3
TUNING.SDF_PUMPKIN_KING_MIASMA_TELEGRAPH_TIME = 5 --5
TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_LONG_TICK = 45 --45
TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_SHORT_TICK = 15 --15
TUNING.SDF_PUMPKIN_KING_MIASMA_AOE_COMBO_COOLDOWN = 5 --5
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_AOE_DAMAGE = 15 --15
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_AOE_RADIUS = 3.2 --3.2
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_TELEGRAPH_RADIUS = 1 --1
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_TELEGRAPH_TIME = 3 --3
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_MIN_RANGE = 4 --4
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_MAX_RANGE = 12 --12
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_COUNT_MIN = 2 --6
TUNING.SDF_PUMPKIN_KING_MIASMA_SMALL_COUNT_MAX = 6 --6
TUNING.SDF_PUMPKIN_KING_MIASMA_CHANCE = 0.35 --0.35
TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_AOE_DAMAGE	= 20 --20
TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_AOE_RADIUS	= 10 --10
TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_TELEGRAPH_RADIUS = 3 --3
TUNING.SDF_PUMPKIN_KING_MIASMA_DEATH_TELEGRAPH_TIME = 1.5 --1.5
TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_HEAT_PERCENT = -1 -- -1
TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_TEMP_REDUCTION = 5 --5
TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_PROTECTION_TIME = 20 --20
TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_ADD_COLDNESS = 1 --1
TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_ADD_WETNESS = 10 --10
TUNING.SDF_PUMPKING_SEED_POD_HEALTH = 120 --120
TUNING.SDF_PUMPKING_CREEPER_HEALTH = 180 --180
TUNING.SDF_PUMPKING_CREEPER_FIRE_DAMAGE = 3 --3
TUNING.SDF_PUMPKING_CREEPER_FREEZE_TIME = 10 --10
TUNING.SDF_PUMPKING_CREEPER_DAMAGE = 20/3 --20/3
TUNING.SDF_PUMPKING_CREEPER_TARGET_RANGE = 2 --2
TUNING.SDF_PUMPKING_CREEPER_ATTACK_RANGE = 1.5 --1.5
TUNING.SDF_PUMPKING_CREEPER_ATTACK_PERIOD = 4 --4
TUNING.SDF_PUMPKING_CREEPER_SANITY_AURA = 1 --1
TUNING.SDF_PUMPKING_CREEPER_WALKSPEED = 2 --2
TUNING.SDF_PUMPKING_CREEPER_RUNSPEED = 5 --5
TUNING.SDF_PUMPKING_CREEPER_GUTS_RANGE = 15 --15
TUNING.SDF_PUMPKING_CREEPER_GUTS_COOLDOWN = 10 --10
TUNING.SDF_PUMPKING_CREEPER_FIRE_DETECTOR_COOLDOWN = 5 --5
TUNING.SDF_PUMPKING_CREEPER_SPAWNER_REGEN_TIME = 20 --20
TUNING.SDF_PUMPKING_CREEPER_SPAWNER_RELEASE_TIME = 1 --10
TUNING.SDF_PUMPKING_CREEPER_SPAWNER_MAX_SPAWN = 1 --1
TUNING.SDF_PUMPKING_CREEPER_SPAWNER_GROWTH_TIME_MIN = 0.5 --5
TUNING.SDF_PUMPKING_CREEPER_SPAWNER_GROWTH_TIME_MAX = 1 --1
TUNING.SDF_PUMPKING_CREEPER_PLANT_GROWTH_TIME = 3 --3
TUNING.SDF_PUMPKING_BOMB_HEALTH = 100 --100
TUNING.SDF_PUMPKING_BOMB_HIBERNATE_TIME = 1 --1
TUNING.SDF_PUMPKING_BOMB_FIRE_DAMAGE = 3 --3
TUNING.SDF_PUMPKING_BOMB_FREEZE_TIME = 10 --10
TUNING.SDF_PUMPKING_BOMB_DAMAGE = 80 --80
TUNING.SDF_PUMPKING_BOMB_RADIUS = 4 --4
TUNING.SDF_PUMPKING_BOMB_FUSE_SUMMON_TIME = 5 --5
TUNING.SDF_PUMPKING_BOMB_FUSE_IGNITE_TIME = 4 --10
TUNING.SDF_PUMPKING_BOMB_FUSE_PROXY_TIME = 3 --2
TUNING.SDF_PUMPKING_BOMB_FUSE_FIRE_TIME = 1.5 --1.5
TUNING.SDF_PUMPKING_BOMB_SINKHOLE_RADIUS = 2 --2
TUNING.SDF_PUMPKING_BOMB_SINKHOLE_TICK = 0.1 --0.1
TUNING.SDF_PUMPKING_BOMB_SINKHOLE_DURATION = 60 --60
TUNING.SDF_PUMPKING_BOMB_SINKHOLE_MOVESPEED_DEBUFF = 0.35 --0.35
TUNING.SDF_PUMPKING_BOMB_SINKHOLE_MOVESPEED_DEBUFF_DURATION = 0.3 --0.3
TUNING.SDF_PUMPKING_BOMB_SPAWNER_REGEN_TIME = 20 --20
TUNING.SDF_PUMPKING_BOMB_SPAWNER_RELEASE_TIME = 1 --10
TUNING.SDF_PUMPKING_BOMB_SPAWNER_MAX_SPAWN = 1 --1
TUNING.SDF_PUMPKING_BOMB_SPAWNER_GROWTH_TIME_MIN = 0.2 --0.2
TUNING.SDF_PUMPKING_BOMB_SPAWNER_GROWTH_TIME_MAX = 0.4 --0.4
TUNING.SDF_PUMPKING_BOMB_PLANT_GROWTH_TIME = 1 --1
TUNING.SDF_PUMPKING_GOURD_HEALTH = 340 --340
TUNING.SDF_PUMPKING_GOURD_HIBERNATE_TIME = 2 --2
TUNING.SDF_PUMPKING_GOURD_FIRE_DAMAGE = 3 --3
TUNING.SDF_PUMPKING_GOURD_FREEZE_TIME = 10 --10
TUNING.SDF_PUMPKING_GOURD_VINE_HEALTH = 30 --30
TUNING.SDF_PUMPKING_GOURD_VINE_LIFE_SPAN = 30 --30
TUNING.SDF_PUMPKING_GOURD_VINE_DAMAGE = 10 --10
TUNING.SDF_PUMPKING_GOURD_VINE_ATTACK_PERIOD = 3 --3
TUNING.SDF_PUMPKING_GOURD_VINE_ATTACK_DIST = 3 --3
TUNING.SDF_PUMPKING_GOURD_VINE_STOPATTACK_DIST = 5 --5
TUNING.SDF_PUMPKING_GOURD_VINE_SANITY_AURA = 1 --1
TUNING.SDF_PUMPKING_GOURD_VINE_SPAWN_MAX = 3 --3
TUNING.SDF_PUMPKING_GOURD_VINE_SPAWN_DIST = 6--6
TUNING.SDF_PUMPKING_GOURD_VINE_SPAWN_TIME = 4 --4
TUNING.SDF_PUMPKING_GOURD_VINE_REGEN_TIME = 10 --10
TUNING.SDF_PUMPKING_GOURD_SPAWNER_REGEN_TIME = 20 --20
TUNING.SDF_PUMPKING_GOURD_SPAWNER_RELEASE_TIME = 1 --1
TUNING.SDF_PUMPKING_GOURD_SPAWNER_MAX_SPAWN = 1 --1
TUNING.SDF_PUMPKING_GOURD_SPAWNER_GROWTH_TIME_MIN = 0.3 --0.3
TUNING.SDF_PUMPKING_GOURD_SPAWNER_GROWTH_TIME_MAX = 0.6 --0.6
TUNING.SDF_PUMPKING_GOURD_PLANT_GROWTH_TIME = 2 --2
TUNING.SDF_PUMPKING_HEALTH_REGEN_AMOUNT = 5 --5
TUNING.SDF_PUMPKING_HEALTH_REGEN_IDLE_THRESHOLD_TIME = 5 --5
TUNING.SDF_PUMPKIN_CREEPER_HEALTH = 220 --220
TUNING.SDF_PUMPKIN_CREEPER_FIRE_DAMAGE = 3 --3
TUNING.SDF_PUMPKIN_CREEPER_FREEZE_TIME = 10 --10
TUNING.SDF_PUMPKIN_CREEPER_DAMAGE = 20/3 --20/3
TUNING.SDF_PUMPKIN_CREEPER_TARGET_RANGE = 2 --2
TUNING.SDF_PUMPKIN_CREEPER_ATTACK_RANGE = 1.5 --1.5
TUNING.SDF_PUMPKIN_CREEPER_ATTACK_PERIOD = 4 --4
TUNING.SDF_PUMPKIN_CREEPER_WALKSPEED = 2 --2
TUNING.SDF_PUMPKIN_CREEPER_RUNSPEED = 5 --5
TUNING.SDF_PUMPKIN_CREEPER_GUTS_RANGE = 15 --15
TUNING.SDF_PUMPKIN_CREEPER_PLANT_REGEN_TIME = 20 --20
TUNING.SDF_PUMPKIN_CREEPER_PLANT_RELEASE_TIME = 1 --1
TUNING.SDF_PUMPKIN_CREEPER_PLANT_MAX_SPAWN = 1 --1
TUNING.SDF_PUMPKIN_CREEPER_PLANT_GROWTH_TIME_MIN = 5 --5
TUNING.SDF_PUMPKIN_CREEPER_PLANT_GROWTH_TIME_MAX = 8 --8
TUNING.SDF_PUMPKIN_BOMB_HEALTH = 840 --840
TUNING.SDF_PUMPKIN_BOMB_HIBERNATE_TIME = 10 --10
TUNING.SDF_PUMPKIN_BOMB_FIRE_DAMAGE = 3 --3
TUNING.SDF_PUMPKIN_BOMB_FREEZE_TIME = 10 --10
TUNING.SDF_PUMPKIN_BOMB_DAMAGE = 120 --120
TUNING.SDF_PUMPKIN_BOMB_RADIUS = 4 --4
TUNING.SDF_PUMPKIN_BOMB_TAUNT_RADIUS = 8 --8
TUNING.SDF_PUMPKIN_BOMB_TAUNT_TICK = 20 --20
TUNING.SDF_PUMPKIN_BOMB_FUSE_IGNITE_TIME = 10 --10
TUNING.SDF_PUMPKIN_BOMB_FUSE_FIRE_TIME = 2 --2
TUNING.SDF_PUMPKIN_BOMB_PLANT_REGEN_TIME = 20 --20
TUNING.SDF_PUMPKIN_BOMB_PLANT_RELEASE_TIME = 1 --1
TUNING.SDF_PUMPKIN_BOMB_PLANT_MAX_SPAWN = 1 --1
TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MIN = 2 --2
TUNING.SDF_PUMPKIN_BOMB_PLANT_GROWTH_TIME_MAX = 4 --4
TUNING.SDF_PUMPKIN_GOURD_HEALTH = 460 --460
TUNING.SDF_PUMPKIN_GOURD_HIBERNATE_TIME = 10 --10
TUNING.SDF_PUMPKIN_GOURD_FIRE_DAMAGE = 3 --3
TUNING.SDF_PUMPKIN_GOURD_FREEZE_TIME = 10 --10
TUNING.SDF_PUMPKIN_GOURD_VINE_HEALTH = 60 --60
TUNING.SDF_PUMPKIN_GOURD_VINE_LIFE_SPAN = 120 --120
TUNING.SDF_PUMPKIN_GOURD_VINE_DAMAGE = 5 --5
TUNING.SDF_PUMPKIN_GOURD_VINE_ATTACK_PERIOD = 3 --3
TUNING.SDF_PUMPKIN_GOURD_VINE_ATTACK_DIST = 3 --3
TUNING.SDF_PUMPKIN_GOURD_VINE_STOPATTACK_DIST = 5 --5
TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_MAX = 4 --4
TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_DIST = 6 --6
TUNING.SDF_PUMPKIN_GOURD_VINE_SPAWN_TIME = 5 --5
TUNING.SDF_PUMPKIN_GOURD_VINE_REGEN_TIME = 10 --10
TUNING.SDF_PUMPKIN_GOURD_PLANT_REGEN_TIME = 20 --20
TUNING.SDF_PUMPKIN_GOURD_PLANT_RELEASE_TIME = 1 --1
TUNING.SDF_PUMPKIN_GOURD_PLANT_MAX_SPAWN = 1 --1
TUNING.SDF_PUMPKIN_GOURD_PLANT_GROWTH_TIME_MIN = 3 --3
TUNING.SDF_PUMPKIN_GOURD_PLANT_GROWTH_TIME_MAX = 6 --6
TUNING.SDF_PUMPKIN_SEEDS_FUEL = 45 --45
TUNING.SDF_PUMPKIN_SEEDS_BURNTIME = 16 --16
TUNING.SDF_PUMPKIN_SEEDS_MAXSTACKCOUNT = 10 --10
TUNING.SDF_PUMPKIN_GORGE_CREEPER_GROWTH_TIME_MIN = 4 --4
TUNING.SDF_PUMPKIN_GORGE_CREEPER_GROWTH_TIME_MAX = 6 --6
TUNING.SDF_PUMPKIN_GORGE_BUSH_GROWTH_TIME = 10 --10
TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MIN = 1 --1
TUNING.SDF_PUMPKIN_GORGE_PLANT_GROWTH_TIME_MAX = 2 --2
TUNING.SDF_PUMPKIN_GORGE_PLANT_REGROWTH_TIME_MIN = 1 --1
TUNING.SDF_PUMPKIN_GORGE_PLANT_REGROWTH_TIME_MAX = 2 --2
TUNING.SDF_PUMPKIN_GORGE_FARMLAND_DEBRIS_LOOT_CHANCE = 0.25 --0.25
TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_MAX = 6 --6
TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_DIST = 14 --14
TUNING.SDF_PUMPKIN_GORGE_FARMLAND_SPAWN_TIME = 30 --30
TUNING.SDF_PUMPKIN_GORGE_FARMLAND_REGEN_TIME = 60 --60
TUNING.SDF_PUMPKIN_GORGE_PONDFISH_COOKED_MAXSTACKCOUNT = 40 --40
TUNING.SDF_PUMPKIN_GORGE_POND_SPAWN_MAX = 4 --4
TUNING.SDF_PUMPKING_GORGE_POND_SPAWN_DIST = 6 --6
TUNING.SDF_PUMPKIN_GORGE_POND_SPAWN_TIME = 240 --240
TUNING.SDF_PUMPKIN_GORGE_POND_REGEN_TIME = 480 --480
TUNING.SDF_PUMPKING_GORGE_WELL_VINE_HEALTH = 1000 --100
TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_DAMAGE = 20 --20
TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_ATTACK_PERIOD = 3 --3
TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_ATTACK_DIST = 3 --3
TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_STOPATTACK_DIST = 5 --5
TUNING.SDF_PUMPKIN_GORGE_WELL_VINE_SANITY_AURA = 1 --1

TUNING.SDF_SHADOW_DEMONETTE_HEALTH = 100 --4800
TUNING.SDF_SHADOW_DEMONETTE_DAMAGE = 25 --25
TUNING.SDF_SHADOW_DEMONETTE_PLANAR_DAMAGE = 30 --30
TUNING.SDF_SHADOW_DEMONETTE_ATTACK_RANGE = 8 --8
TUNING.SDF_SHADOW_DEMONETTE_ATTACK_PERIOD = 4 --4
TUNING.SDF_SHADOW_DEMONETTE_WALKSPEED = 5 --5
TUNING.SDF_SHADOW_DEMONETTE_SANITY_AURA = 3 --3

TUNING.SDF_SHADOW_ARTEFACT_SANITY_AURA = 1 --1
TUNING.SDF_SHADOW_ARTEFACT_SANITY_DRAIN = 1 --1
TUNING.SDF_SHADOW_ARTEFACT_SANITY_DRAIN_TICK = 10 --10
TUNING.SDF_SHADOW_TALISMAN_DURATION = 480 --480
TUNING.SDF_SHADOW_TALISMAN_BUFF_LUNAR_VS_BONUS = 1.1 --1.1 10%
TUNING.SDF_SHADOW_TALISMAN_BUFF_LUNAR_RESIST_BONUS = 0.9 --0.9 10%
TUNING.SDF_SHADOW_TALISMAN_SANITY_AURA = 1 --1
TUNING.SDF_SHADOW_TALISMAN_SANITY_DRAIN = 2 --2
TUNING.SDF_SHADOW_TALISMAN_SANITY_ACTIVE_DRAIN = 5 --5
TUNING.SDF_SHADOW_TALISMAN_SANITY_DRAIN_TICK = 10 --10
TUNING.SDF_SHADOW_TALISMAN_IRE_SANITY_AURA = 2 --2
TUNING.SDF_SHADOW_TALISMAN_IRE_SANITY_DRAIN = 4 --4
TUNING.SDF_SHADOW_TALISMAN_IRE_SANITY_ACTIVE_DRAIN = 10 --10

TUNING.SDF_CARNIVAL_TOKEN_MAXSTACKCOUNT = 60 --60
TUNING.SDF_TIME_RUNE_HALL_OF_HEROES_REVIVE_PENALTY = 0.5 --0.5
TUNING.SDF_TIME_RUNE_HALL_OF_HEROES_REVIVE_COOLDOWN =GetModConfigData("sdf_time_rune_hall_of_heroes_revive_cooldown") --12 days
TUNING.SDF_TIME_RUNE_HALL_OF_HEROES_COOLDOWN = 60 --60
TUNING.SDF_TIME_RUNE_TELEPORT_COOLDOWN = 60 --60
TUNING.SDF_TIME_RUNE_TELEPORT_EXTRA_COOLDOWN = 30 --30
TUNING.SDF_TIME_RUNE_DODGE_CHANCE_SDF = 0.06 --0.06
TUNING.SDF_TIME_RUNE_DODGE_CHANCE_SDF_CHAOS = 0.09 --0.09
TUNING.SDF_TIME_RUNE_DODGE_CHANCE_NORMAL = 0.12 --0.12
TUNING.SDF_MOON_RUNE_GATHER_CHANCE = 0.05 --0.05
TUNING.SDF_MOON_RUNE_SHARD_DAMAGE_SDF = 6 --6
TUNING.SDF_MOON_RUNE_SHARD_DAMAGE_SDF_CHAOS = 9 --9
TUNING.SDF_MOON_RUNE_SHARD_DAMAGE_NORMAL = 12 --12
TUNING.SDF_EARTH_RUNE_GATHER_CHANCE = 0.05 --0.05
TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_SDF = 0.10 --0.10
TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_SDF_CHAOS = 0.15 --0.15
TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_NORMAL = 0.20 --0.20
TUNING.SDF_STAR_RUNE_GATHER_CHANCE = 0.05 --0.05
TUNING.SDF_STAR_RUNE_PLANAR_DEF_SDF = 4 --4
TUNING.SDF_STAR_RUNE_PLANAR_DEF_SDF_CHAOS = 6 --6
TUNING.SDF_STAR_RUNE_PLANAR_DEF_NORMAL = 8 --8
TUNING.SDF_CHAOS_ROCK_MINE = 6 --6
TUNING.SDF_CHAOS_ROCK2_SANITY_DRAIN = 20 --20
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_WEAPON = "sdf_spade"
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_ATTACK_DAMAGE = 30 --30
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_ATTACK_PERIOD = 3 --3
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_MAX_STUN_LOCKS = 6 --6
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_RUN_SPEED = 8 --8
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_WALK_SPEED = 3 --3
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_HEALTH_REGEN_AMOUNT = 10 --10
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_HEALTH_REGEN_PERIOD = 5.2 --5.2
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_HEALTH = 300 --300
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_REGEN_TIME = 1920 --480*4
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_RELEASE_TIME = 10 --10
TUNING.SDF_ASYLUM_GROUNDS_KEEPER_GRAVE_MAX_SPAWN = 1 --1
TUNING.SDF_JACK_OF_THE_GREEN_4TH_RIDDLE_RARITY = GetModConfigData("sdf_jack_of_the_green_4th_riddle_rarity") --true
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT_DURATION = 240 --120 quarter day
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT_MAXSTACKCOUNT = 10 --10
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_HEALTH = 60 --60
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_DECAY_RATE = 5 --5
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_MAX = 120 --120
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_START = 10 --10
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_DAY_RATE = 30 --30
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_DUSK_RATE = 8 --8
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_NIGHT_RATE = 1 --1
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_SANITY_INSPIRE = 15 --15
TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_SANITY_DESPAIR = 5 --5
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_SPAWN_REGEN_TIME = 1920 --480*4
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_SPAWN_RELEASE_TIME = 10 --10
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_SPAWN_MAX_SPAWN = 1 --1
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_HEALTH = 7200 --7200
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_HEALTH_REGEN_AMOUNT = 1800 --1800
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_HEALTH_REGEN_PERIOD = 5.2 --5.2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_FIRE_DAMAGE_SCALE = 2 --2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_FLAMMABILITY = 0.33 --0.33
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_ATTACK_DAMAGE = 135 --135
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_ATTACK_PERIOD = 2 --2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_RUN_SPEED = 15 --15
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_WALK_SPEED = 5 --5
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_TARGET_DIST = 7 --7
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_ROOK_SANITY_AURA = 3 --3
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_SPAWN_REGEN_TIME = 1440 --480*3
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_SPAWN_RELEASE_TIME = 10 --10
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_SPAWN_MAX_SPAWN = 1 --1
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_HEALTH = 2400 --2400
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_HEALTH_REGEN_AMOUNT = 300 --300
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_HEALTH_REGEN_PERIOD = 5.2 --5.2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_FIRE_DAMAGE_SCALE = 2 --2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_FLAMMABILITY = 0.33 --0.33
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_ATTACK_DAMAGE = 55 --55
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_ATTACK_PERIOD = 2 --2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_WALK_SPEED = 5 --5
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_TARGET_DIST = 10 --10
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_KNIGHT_SANITY_AURA = 1 --1
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_REGEN_TIME = 1440 --480*3
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_RELEASE_TIME = 10 --10
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SPAWN_MAX_SPAWN = 1 --1
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_HEALTH = 2400 --2400
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_HEALTH_REGEN_AMOUNT = 300 --300
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_HEALTH_REGEN_PERIOD = 5.2 --5.2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_FIRE_DAMAGE_SCALE = 2 --2
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_FLAMMABILITY = 0.33 --0.33
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_ATTACK_DAMAGE = 90 --90
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_ATTACK_PERIOD = 4 --4
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_ATTACK_DIST = 6 --6
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_PROJECTILE_SPEED = 25 --25
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_PROJECTILE_MOVESPEED_DEBUFF = 0.66 --0.66
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_PROJECTILE_MOVESPEED_DEBUFF_DURATION = 3 --3
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_WALK_SPEED = 0 --0
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_TARGET_DIST = 7 --7
TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_SANITY_AURA = 1 --1

TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_COOLDOWN = 3 --3
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_DURATION = 0.6  --0.6
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_HUNGER_USAGE = 2 --2
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_HUNGER_LIMITER = 0.1 --0.1
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE = 30  --30
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE_BROKEN = 5  --5
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_STUN_DEBUFF_DURATION = 3 --3
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ARMOR = 0.5  --0.5
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_SHIELD_DAMAGE_COLLIDE = 25  --25
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_SHIELD_DAMAGE_TRAMPLE = 5  --5
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_CHOP = 3  --3 5max
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_MINE = 1.5  --1.5 2max
TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_WORK_HAMMER = 0.5  --0.5 1max
TUNING.SDF_SKILLSET_BACKBONE_STEADFAST = 0.1 --0.1  total 80
TUNING.SDF_SKILLSET_BACKBONE_STEADFAST_SHIELD_DAMAGE_COLLIDE = 15 --15  total 10
TUNING.SDF_SKILLSET_BACKBONE_STEADFAST_SHIELD_DAMAGE_TRAMPLE = 3 --3  total 2
TUNING.SDF_SKILLSET_BACKBONE_GRIT = 0.6 --0.6  total 1.2
TUNING.SDF_SKILLSET_BACKBONE_GRIT_WORK_CHOP = 2 --2  total 5
TUNING.SDF_SKILLSET_BACKBONE_GRIT_WORK_MINE = 0.5 --0.5  total 2
TUNING.SDF_SKILLSET_BACKBONE_GRIT_WORK_HAMMER = 0.5 --0.5  total 1
TUNING.SDF_SKILLSET_BACKBONE_ENERGY_BONES_BONUS_PLANAR_DEF = 5 --5

TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_1 = 0.02 --0.02
TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_1 = 1 --1
TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_2 = 0.04 --0.04
TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_EPIC_2 = 2 --2
TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_PERCENT = 0.25 --0.25
TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_DURATION = 10 --10
TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_AGGRO_DEBUFF_DURATION = 10 --10
TUNING.SDF_SKILLSET_UNDEATH_CULLING = 0.1 --0.1
TUNING.SDF_SKILLSET_UNDEATH_CULLING_BONUS = 0.3 --0.3
TUNING.SDF_SKILLSET_UNDEATH_CULLING_SANITY_BONUS = 1 --1
TUNING.SDF_SKILLSET_UNDEATH_RITES_1 = 0.02 --0.02
TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_1 = 0.5 --0.5
TUNING.SDF_SKILLSET_UNDEATH_RITES_2 = 0.04 --0.04
TUNING.SDF_SKILLSET_UNDEATH_RITES_EPIC_2 = 1 --1
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_DAYS = 100 --100
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_RANGE = 10 --10
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_TIME = 30 --30 30sec
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SANITY_BONUS = 20 --20
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_MOVEMENT_SPEED_BONUS = 1.2 --1.2 20%
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_LEECH_BONUS = 0.5 --0.5
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SHADOW_VS_BONUS = 1.1 --1.1 10%
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SHADOW_RESIST_BONUS = 0.9 --0.9 10%
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_COOLDOWN_SHORT = 10 --10  10sec
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_COOLDOWN_NORMAL = 120 --180 3mins
TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_COOLDOWN_LONG = 300 --360 6mins
TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_OVERWORLD_COUNT = 5 --5
TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_CAVE_COUNT = 5 --5

TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_PROC_CHANCE = 0.05 --0.05
TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_BONUS_PLANAR_MULTI = 0.2 --0.2
TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_DEBUFF_DURATION = 10 --10
TUNING.SDF_SKILLSET_SKULL_EYE_OF_AMON_RA_DEBUFF_COOLDOWN = 5 --5
TUNING.SDF_SKILLSET_SKULL_PERCEPTION = 0.1 --0.1
TUNING.SDF_SKILLSET_SKULL_FOCUS = 0.5 --0.5
TUNING.SDF_SKILLSET_SKULL_INSIGHT_BOOK_OF_GALLOWMERE_RIDDLES = 20 --20
TUNING.SDF_SKILLSET_SKULL_MORTEN_OCEANFISHING_LURE = {
    charm = 0.4,
    reel_charm = 0.4,
    radius = 5,
    style = "special",
    timeofday = {day = 1, dusk = 1, night = 1},
    dist_max = 2,
    weather = {default = 1.0, raining = 1.0, snowing = 1.0}
}

TUNING.SDF_SKILLSET_ALLEGIANCE_GUTS = 0.5 --0.5
TUNING.SDF_SKILLSET_ALLEGIANCE_NERVES = 0.5 --0.5


TUNING.SDF_PROFESSORS_LAB_GENERATOR_MAX_FUEL_TIME = 90 --90 1.5mins
TUNING.SDF_PROFESSORS_LAB_TESLA_RESOURCE_MAX = 5 --5
TUNING.SDF_PROFESSORS_LAB_TESLA_CHARGE_RATE = 360 --360 6mins   1800 30mins
TUNING.SDF_PROFESSORS_LAB_CHALICE_RESOURCE_MAX = 300 --300

--Add FXs
local sdf_lightning_shock_fx = {
name = "sdf_lightning_shock_fx",
bank = "sdf_lightning_shock",
build = "sdf_lightning_shock",
anim = "anim",
sound = "moonstorm/common/moonstorm/spark_attack",
eightfaced = true,
autorotate = true,
fn = function(inst)
inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
inst.AnimState:SetLightOverride(1)
inst.AnimState:SetFinalOffset(1) end,
}

local sdf_goodlightning_shock_fx = {
    name = "sdf_goodlightning_shock_fx",
    bank = "sdf_goodlightning_shock",
    build = "sdf_goodlightning_shock",
    anim = "anim",
    sound = "moonstorm/common/moonstorm/spark_attack",
    eightfaced = true,
    autorotate = true,
    fn = function(inst)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(1)
	inst.AnimState:SetFinalOffset(1)
    end,
}

local sdf_time_rune_gears_fx =
{
    name = "sdf_time_rune_gears_fx",
    bank = "sdf_time_rune_gears_fx",
    build = "sdf_time_rune_gears_fx",
    anim = "anim_1",
    --sound = "dontstarve/common/fireAddFuel",
    bloom = true,
    fn = function(inst)
        inst.AnimState:SetLightOverride(1)
        inst.AnimState:PlayAnimation("anim_"..math.random(1, 3))
        inst.AnimState:SetFinalOffset(3)
    end,
}

local sdf_pumpking_gutted_splash_fx =
{
    name = "sdf_pumpking_gutted_splash_fx",
    bank = "sdf_pumpking_guttedshoot",
    build = "sdf_pumpking_guttedshoot",
    anim = "splash",
    sound = "turnoftides/common/together/water/splash/bird",
    fn = function(inst)
	inst.AnimState:SetFinalOffset(1)
    end,
}

local sdf_pumpking_gutted_puddle_land_fx =
{
    name = "sdf_pumpking_gutted_puddle_land_fx",
    bank = "sdf_pumpking_guttedpuddle",
    build = "sdf_pumpking_guttedpuddle",
    anim = "puddle_dry",
    fn = function(inst)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
    end,
}

local sdf_pumpking_gutted_puddle_water_fx =
{
    name = "sdf_pumpking_gutted_puddle_water_fx",
    bank = "sdf_pumpking_guttedpuddle",
    build = "sdf_pumpking_guttedpuddle",
    anim = "puddle_wet",
    fn = function(inst)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
    end,
}

GLOBAL.table.insert(GLOBAL.require("fx"), sdf_lightning_shock_fx)
GLOBAL.table.insert(GLOBAL.require("fx"), sdf_goodlightning_shock_fx)
GLOBAL.table.insert(GLOBAL.require("fx"), sdf_time_rune_gears_fx)
GLOBAL.table.insert(GLOBAL.require("fx"), sdf_pumpking_gutted_splash_fx)
GLOBAL.table.insert(GLOBAL.require("fx"), sdf_pumpking_gutted_puddle_land_fx)
GLOBAL.table.insert(GLOBAL.require("fx"), sdf_pumpking_gutted_puddle_water_fx)

-- Custom TechTree for the Merchant station --
local TechTree = require("techtree")
table.insert(TechTree.AVAILABLE_TECH, "SDF_MERCHANT_GARGOYLE")
table.insert(TechTree.AVAILABLE_TECH, "SDF_SPIV")

TechTree.Create = function(t)
    t = t or {}
    for i, v in ipairs(TechTree.AVAILABLE_TECH) do
        t[v] = t[v] or 0
    end
    return t
end

GLOBAL.TECH.NONE.SDF_MERCHANT_GARGOYLE = 0
GLOBAL.TECH.NONE.SDF_SPIV = 0

GLOBAL.TECH.SDF_MERCHANT_GARGOYLE_ONE = {
    SDF_MERCHANT_GARGOYLE = 1
}

GLOBAL.TECH.SDF_SPIV_ONE = {
    SDF_SPIV = 1
}

for k, v in pairs(TUNING.PROTOTYPER_TREES) do
    v.SDF_MERCHANT_GARGOYLE = 0
    v.SDF_SPIV = 0
end

TUNING.PROTOTYPER_TREES.SDF_MERCHANT_GARGOYLE_ONE = TechTree.Create({
    SDF_MERCHANT_GARGOYLE = 1
})


TUNING.PROTOTYPER_TREES.SDF_SPIV_ONE = TechTree.Create({
    SDF_SPIV = 1
})

for i, v in pairs(GLOBAL.AllRecipes) do
    if v.level.SDF_MERCHANT_GARGOYLE == nil then
        v.level.SDF_MERCHANT_GARGOYLE = 0
    end

    if v.level.SDF_SPIV == nil then
        v.level.SDF_SPIV = 0
    end
end


-- Custom Prototyper and Recipe filters --
require("recipes_filter")

AddPrototyperDef("sdf_merchant_gargoyle", {
    icon_atlas = "images/tabimages/sdf_merchant_gargoyle_tab.xml",
    icon_image = "sdf_merchant_gargoyle_tab.tex",
    is_crafting_station = true,
    action_str = "SDF_MERCHANT_GARGOYLE_STATION",
    filter_text = "Merchant Gargoyle"
})

AddPrototyperDef("sdf_shop_gargoyle", {
    icon_atlas = "images/tabimages/sdf_shop_gargoyle_tab.xml",
    icon_image = "sdf_shop_gargoyle_tab.tex",
    is_crafting_station = true,
    action_str = "SDF_SHOP_GARGOYLE_STATION",
    filter_text = "Shop Gargoyle"
})

AddPrototyperDef("sdf_pumpkin_gorge_well_merchant_gargoyle", {
    icon_atlas = "images/tabimages/sdf_shop_gargoyle_tab.xml",
    icon_image = "sdf_shop_gargoyle_tab.tex",
    is_crafting_station = true,
    action_str = "SDF_MERCHANT_GARGOYLE_STATION",
    filter_text = "Merchant Gargoyle"
})

AddPrototyperDef("sdf_spiv", {
    icon_atlas = "images/tabimages/sdf_shop_gargoyle_tab.xml",
    icon_image = "sdf_shop_gargoyle_tab.tex",
    is_crafting_station = true,
    action_str = "SDF_SPIV_STATION",
    filter_text = "The Spiv"
})

--SDF Recipes Basic and Recipes Chalice Rewards
    AddCharacterRecipe("sdf_small_sword", {
	Ingredient("twigs", 1),
	Ingredient("flint", 2),
	Ingredient("goldnugget", 1)
	}, TECH.SCIENCE_ONE, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_small_sword.xml", 
	image = "sdf_small_sword.tex",
	product = "sdf_small_sword"})

    AddCharacterRecipe("sdf_broad_sword", {
	Ingredient("sdf_small_sword", 1, "images/inventoryimages/sdf_small_sword.xml"),
	Ingredient("moonrocknugget", 3),
	Ingredient("goldnugget", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_broad_sword.xml", 
	image = "sdf_broad_sword.tex",
	product = "sdf_broad_sword"})

    AddCharacterRecipe("sdf_magic_sword", {
	Ingredient("sdf_enchanted_sword", 1, "images/inventoryimages/sdf_enchanted_sword.xml"),
	Ingredient("bluegem", 4),
	Ingredient("lightbulb", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_magic_sword.xml", 
	image = "sdf_magic_sword.tex",
	product = "sdf_magic_sword"})

    AddCharacterRecipe("sdf_club", {
	Ingredient("silk", 1),
	Ingredient("log", 1)
	}, TECH.SCIENCE_ONE, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_club.xml", 
	image = "sdf_club.tex",
	product = "sdf_club"})

    AddCharacterRecipe("sdf_hammer", {
	Ingredient("cutstone", 5),
	Ingredient("silk", 3),
	Ingredient("log", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_hammer.xml", 
	image = "sdf_hammer.tex",
	product = "sdf_hammer"})

    AddCharacterRecipe("sdf_axe", {
	Ingredient("flint", 4),
	Ingredient("silk", 1),
	Ingredient("livinglog", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_axe.xml", 
	image = "sdf_axe.tex",
	product = "sdf_axe"})

    AddCharacterRecipe("sdf_crossbow", {
	Ingredient("boards", 1),
	Ingredient("twigs", 2),
	Ingredient("gears", 1),
	Ingredient("silk", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_crossbow_sdf_standard_bolts.xml", 
	image = "sdf_crossbow_sdf_standard_bolts.tex",
	product = "sdf_crossbow"})

    AddCharacterRecipe("sdf_longbow", {
	Ingredient("driftwood_log", 3),
	Ingredient("flint", 1),
	Ingredient("silk", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_longbow_sdf_standard_arrows.xml", 
	image = "sdf_longbow_sdf_standard_arrows.tex",
	product = "sdf_longbow"})

    AddCharacterRecipe("sdf_flaming_longbow", {
	Ingredient("driftwood_log", 3),
	Ingredient("firenettles", 2),
	Ingredient("charcoal", 2),
	Ingredient("silk", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_flaming_longbow_sdf_flaming_arrows.xml", 
	image = "sdf_sdf_flaming_longbow_sdf_flaming_arrows.tex",
	product = "sdf_flaming_longbow"})

    AddCharacterRecipe("sdf_magic_longbow", {
	Ingredient("livinglog", 3),
	Ingredient("spore_tall", 2),
	Ingredient("spore_medium", 2),
	Ingredient("silk", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_magic_longbow_sdf_magical_arrows.xml", 
	image = "sdf_magic_longbow_sdf_magical_arrows.tex",
	product = "sdf_magic_longbow"})

    AddCharacterRecipe("sdf_lightning_gauntlet", {
	Ingredient("thulecite_pieces", 6),
	Ingredient("trinket_6", 1),
	Ingredient("transistor", 2),
	Ingredient("tentaclespots", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_lightning_gauntlet.xml", 
	image = "sdf_lightning_gauntlet.tex",
	product = "sdf_lightning_gauntlet"})

    AddCharacterRecipe("sdf_copper_shield", {
	Ingredient("flint", 4),
	Ingredient("pigskin", 1)
	}, TECH.SCIENCE_ONE, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_copper_shield.xml", 
	image = "sdf_copper_shield.tex",
	product = "sdf_copper_shield"})

    AddCharacterRecipe("sdf_silver_shield", {
	Ingredient("moonrocknugget", 4),
	Ingredient("pigskin", 1)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_silver_shield.xml", 
	image = "sdf_silver_shield.tex",
	product = "sdf_silver_shield"})

    AddCharacterRecipe("sdf_victorian_suit", {
	Ingredient("tentaclespots", 4),
	Ingredient("silk", 2),
	Ingredient("beardhair", 2),
	Ingredient("sewing_kit", 1)
	}, TECH.SCIENCE_TWO, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_victorian_suit.xml", 
	image = "sdf_victorian_suit.tex",
	product = "sdf_victorian_suit"})

    --[[AddCharacterRecipe("sdf_witch_talisman", {
	Ingredient("pumpkin", 1),
	Ingredient("treegrowthsolution", 1),
	Ingredient("moon_cap", 1),
	Ingredient("goldnugget", 1)
	}, TECH.MAGIC_TWO, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_witch_talisman.xml", 
	image = "sdf_witch_talisman.tex",
	product = "sdf_witch_talisman"})]]

    AddCharacterRecipe("sdf_book_of_gallowmere", {
	Ingredient("featherpencil", 1),
	Ingredient("papyrus", 4),
	Ingredient("pigskin", 1),
	Ingredient(CHARACTER_INGREDIENT.SANITY, 20)
	}, TECH.LOST, {
	numtogive = 1,
	builder_tag = "sdf_book_of_gallowmere_builder",
	atlas = "images/inventoryimages/sdf_book_of_gallowmere.xml", 
	image = "sdf_book_of_gallowmere.tex",
	product = "sdf_book_of_gallowmere"})

    AddCharacterRecipe("sdf_shop_gargoyle", {
	Ingredient("cutstone", 2),
	Ingredient("marble", 4),
	Ingredient("nightmarefuel", 4),
	Ingredient("reviver", 1)
	}, TECH.MAGIC_THREE, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_shop_gargoyle.xml", 
	image = "sdf_shop_gargoyle.tex",
	placer = "sdf_shop_gargoyle_placer"})

    --[[AddCharacterRecipe("sdf_anubis_stone", {
	Ingredient("sdf_anubis_stone_part1", 1, "images/inventoryimages/sdf_anubis_stone_part1.xml"),
	Ingredient("sdf_anubis_stone_part2", 1, "images/inventoryimages/sdf_anubis_stone_part2.xml"),
	Ingredient("sdf_anubis_stone_part3", 1, "images/inventoryimages/sdf_anubis_stone_part3.xml"),
	Ingredient("sdf_anubis_stone_part4", 1, "images/inventoryimages/sdf_anubis_stone_part4.xml"),
	}, TECH.MAGIC_THREE, {
	numtogive = 1,
	builder_tag = "sdf_builder",
	atlas = "images/inventoryimages/sdf_anubis_stone_empty.xml", 
	image = "sdf_anubis_stone_empty.tex",
	product = "sdf_anubis_stone"})]]


--Gargoyle Merchant Services and Recipes
    AddRecipe2("sdf_enchanted_sword", {
	Ingredient("sdf_broad_sword", 1, "images/inventoryimages/sdf_broad_sword.xml"),
        Ingredient("goldnugget", 4)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_enchanted_sword_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_enchanted_sword.xml",
        image = "sdf_enchanted_sword.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_gold_shield", {
	Ingredient("sdf_gold_shield", 1, "images/inventoryimages/sdf_gold_shield.xml"),
        Ingredient("goldnugget", 5)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_gold_shield_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_gold_shield.xml",
        image = "sdf_gold_shield.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_gold_armor", {
	Ingredient("sdf_gold_armor", 1, "images/inventoryimages/sdf_gold_armor.xml"),
        Ingredient("goldnugget", 4)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_gold_armor_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_gold_armor.xml",
        image = "sdf_gold_armor.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_throwing_daggers", {
        Ingredient("goldnugget", 3)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
        numtogive = 20,
        atlas = "images/techtreeimages/sdf_throwing_daggers.xml",
        image = "sdf_throwing_daggers.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_standard_bolts", {
        Ingredient("goldnugget", 1)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_standard_bolts_builder",
        numtogive = 30,
        atlas = "images/techtreeimages/sdf_standard_bolts.xml",
        image = "sdf_standard_bolts.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_standard_arrows", {
        Ingredient("goldnugget", 2)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_standard_arrows_builder",
        numtogive = 30,
        atlas = "images/techtreeimages/sdf_standard_arrows.xml",
        image = "sdf_standard_arrows.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_flaming_arrows", {
        Ingredient("goldnugget", 2)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_flaming_arrows_builder",
        numtogive = 20,
        atlas = "images/techtreeimages/sdf_flaming_arrows.xml",
        image = "sdf_flaming_arrows.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_magical_arrows", {
        Ingredient("goldnugget", 2)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_magical_arrows_builder",
        numtogive = 10,
        atlas = "images/techtreeimages/sdf_magical_arrows.xml",
        image = "sdf_magical_arrows.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_spear", {
        Ingredient("goldnugget", 3)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_spear_builder",
        numtogive = 10,
        atlas = "images/techtreeimages/sdf_spear.xml",
        image = "sdf_spear.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_lightning", {
        Ingredient("goldnugget", 5)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_lightning_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_lightning.xml",
        image = "sdf_lightning.tex"
    }, {
        "CRAFTING_STATION"
    })

    --[[AddRecipe2("sdf_goodlightning", {
        Ingredient("goldnugget", 5)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_goodlightning_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_goodlightning.xml",
        image = "sdf_goodlightning.tex"
    }, {
        "CRAFTING_STATION"
    })]]

    AddRecipe2("sdf_wodens_brand", {
        Ingredient("sdf_carnival_token", 8, "images/inventoryimages/sdf_carnival_token.xml")
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag="sdf_wodens_brand_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_wodens_brand.xml",
        image = "sdf_wodens_brand.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_witch_talisman", {
        Ingredient("goldnugget", 10)
    }, TECH.SDF_MERCHANT_GARGOYLE_ONE, {
        nounlock = true,
	builder_tag = "sdf_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_witch_talisman.xml",
        image = "sdf_witch_talisman.tex"
    }, {
        "CRAFTING_STATION"
    }) 

--The Spiv Services and Recipes
    AddRecipe2("sdf_flaming_bolts", {
        Ingredient("goldnugget", 1)
    }, TECH.SDF_SPIV_ONE, {
        nounlock = true,
	--builder_tag="sdf_flaming_bolts_builder",
        numtogive = 20,
        atlas = "images/techtreeimages/sdf_flaming_bolts.xml",
        image = "sdf_flaming_bolts.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_standard_bullets", {
        Ingredient("goldnugget", 3)
    }, TECH.SDF_SPIV_ONE, {
        nounlock = true,
	--builder_tag="sdf_standard_bullets_builder",
        numtogive = 20,
        atlas = "images/techtreeimages/sdf_standard_bullets.xml",
        image = "sdf_standard_bullets.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_standard_buckshots", {
        Ingredient("goldnugget", 3)
    }, TECH.SDF_SPIV_ONE, {
        nounlock = true,
	--builder_tag="sdf_standard_buckshots_builder",
        numtogive = 10,
        atlas = "images/techtreeimages/sdf_standard_buckshots.xml",
        image = "sdf_standard_buckshots.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_bombs", {
        Ingredient("goldnugget", 4)
    }, TECH.SDF_SPIV_ONE, {
        nounlock = true,
	--builder_tag="sdf_bombs_builder",
        numtogive = 10,
        atlas = "images/techtreeimages/sdf_bombs.xml",
        image = "sdf_bombs.tex"
    }, {
        "CRAFTING_STATION"
    })

    AddRecipe2("sdf_standard_munitions", {
        Ingredient("goldnugget", 5)
    }, TECH.SDF_SPIV_ONE, {
        nounlock = true,
	--builder_tag="sdf_standard_munitions_builder",
        numtogive = 1,
        atlas = "images/techtreeimages/sdf_standard_munitions.xml",
        image = "sdf_standard_munitions.tex"
    }, {
        "CRAFTING_STATION"
    })


-- Skilltree
local SkillTreeDefs = require("prefabs/skilltree_defs")

local OldGetSkilltreeBG = GLOBAL.GetSkilltreeBG
function GLOBAL.GetSkilltreeBG(imagename, ...)
    if imagename == "sdf_background.tex" then
        return "images/skilltreeimages/sdf_skilltree.xml"
    else
        return OldGetSkilltreeBG(imagename, ...)
    end
end

local CreateSkillTree = function()
	print("Creating a skilltree for SDF")
	local BuildSkillsData = require("prefabs/skilltree_sdf") -- Load in the skilltree

    if BuildSkillsData then
        local data = BuildSkillsData(SkillTreeDefs.FN)

        if data then
            SkillTreeDefs.CreateSkillTreeFor("sdf", data.SKILLS)
            SkillTreeDefs.SKILLTREE_ORDERS["sdf"] = data.ORDERS
	    print("Created SDF skilltree")
        end
    end
end
CreateSkillTree();


--------------------------------------------Professors Lab Sounds and Weather
local function NsoTwDs(PlwhaRKJ)
    if PlwhaRKJ and PlwhaRKJ >= 1085 and PlwhaRKJ <= 2015 then
        return true
    end
    return false
end

local urkh = GLOBAL.PlayFootstep

GLOBAL.PlayFootstep = function(xb6, yK, rHLz2GD, ...)
    if xb6 and xb6._insdfprofessorslabcamera ~= nil and xb6._insdfprofessorslabcamera:value() ~= nil then
        local BlW0RhJA = xb6.SoundEmitter
        if BlW0RhJA ~= nil then
            BlW0RhJA:PlaySound(xb6.sg ~= nil and xb6.sg:HasStateTag("running") and "dontstarve/movement/run_wagdock" or
		"dontstarve/movement/walk_wagdock"..((xb6:HasTag("smallcreature") and "_small") or (xb6:HasTag("largecreature") and
		 "_large" or "")),nil,yK or 1,rHLz2GD)
        end
    elseif xb6 and xb6._insdfpumpkingorgewellcamera ~= nil and xb6._insdfpumpkingorgewellcamera:value() ~= nil then
        local BlW0RhJA = xb6.SoundEmitter
        if BlW0RhJA ~= nil then
            BlW0RhJA:PlaySound(xb6.sg ~= nil and xb6.sg:HasStateTag("running") and "dontstarve/movement/run_marsh" or
		"dontstarve/movement/walk_marsh"..((xb6:HasTag("smallcreature") and "_small") or (xb6:HasTag("largecreature") and
		 "_large" or "")),nil,yK or 1,rHLz2GD)
        end
    else
        urkh(xb6, yK, rHLz2GD, ...)
    end
end

local zhzpBSx = GLOBAL.MakeSnowCovered

local function rHSjalVy(Uy)
    Uy.AnimState:ClearOverrideSymbol("snow", "snow", "snow")
    Uy:RemoveTag("SnowCovered")
    Uy.AnimState:Hide("snow")
end

GLOBAL.MakeSnowCovered = function(n, ...)
    zhzpBSx(n, ...)
    n:DoTaskInTime(0,function()
	if n.Transform ~= nil then
	    local TKu, M6kL, M7o_ = n.Transform:GetWorldPosition()
	    if NsoTwDs(M7o_) then
		rHSjalVy(n)
	    end
	end
    end)
end

local TjhsnP = {rain = nil, caverain = nil, snow = nil}

local t5jzEd9 = GLOBAL.EmitterManager

local JZAU2 = t5jzEd9.PostUpdate or nil

function t5jzEd9:PostUpdate(...)
    for dk2X7J7, jv in pairs(self.awakeEmitters.infiniteLifetimes) do
        if
            (dk2X7J7.prefab == "rain" or dk2X7J7.prefab == "caverain" or dk2X7J7.prefab == "snow") and
                jv.updateFunc ~= nil
         then
            if TjhsnP[dk2X7J7] == nil then
                TjhsnP[dk2X7J7] = jv.updateFunc
            end
            local MW, E2OQ, SnbfLb6 = dk2X7J7.Transform:GetWorldPosition()
            if NsoTwDs(SnbfLb6) then
                jv.updateFunc = function(...)
                end
            else
                jv.updateFunc = TjhsnP[dk2X7J7]
            end
        end
    end
    if JZAU2 ~= nil then
        JZAU2(t5jzEd9, ...)
    end
end
--------------------------------------------------------------------------------------

--------------------------------------------------
--Language Strings
modimport("scripts/speech/english/sdf_strings.lua")
--Be sure to update skilltree_sdf prefab too!

--Souls, Life Bottles, Super Armor Setup
modimport("scripts/util/sdf_widget.lua")

--Allows Hero Status Animation
modimport("scripts/actionhandler/sdf_hero_status_handler.lua")

--Shield equipment slot
modimport("scripts/actionhandler/sdf_shield_control_handler.lua")

--Allows Shield Parry
modimport("scripts/actionhandler/sdf_shield_handler.lua")

--Allows Dans Arm Toggle
modimport("scripts/actionhandler/sdf_arm_control_handler.lua")

--Allows Daring Dash Animation
modimport("scripts/actionhandler/sdf_daring_dash_control_handler.lua")
modimport("scripts/actionhandler/sdf_daring_dash_handler.lua")

--Allows Woden's Brand Parry
modimport("scripts/actionhandler/sdf_wodens_brand_handler.lua")

--Rune equipment slot
modimport("scripts/actionhandler/sdf_rune_control_handler.lua")

--Allows Rune Holder slot setups
require("util/sdf_rune_holder_functions")
modimport("scripts/actionhandler/sdf_rune_holder_handler.lua")

--Allows Quiver ammo slot setups
require("util/sdf_quiver_functions")
modimport("scripts/actionhandler/sdf_quiver_handler.lua")

--Allows Lightning Gauntlet Slot setups
require("util/sdf_lightning_gauntlet_capacitor_functions")
modimport("scripts/actionhandler/sdf_lightning_gauntlet_capacitor_handler.lua")

--Allows Anubis Stone Slot setups
require("util/sdf_anubis_stone_soulkeeper_functions")
modimport("scripts/actionhandler/sdf_anubis_stone_soulkeeper_handler.lua")

--Allows Book of Gallowmere Slot setups
require("util/sdf_book_of_gallowmere_spine_functions")

--Allows Crossbow Animation
modimport("scripts/actionhandler/sdf_crossbow_handler.lua")

--Allows Longbow Animation
modimport("scripts/actionhandler/sdf_longbow_handler.lua")

--Allows Lightning Gauntlet Animation
modimport("scripts/actionhandler/sdf_lightning_gauntlet_handler.lua")

--Allows Lightning Gauntlet Transfer
modimport("scripts/actionhandler/sdf_lightning_gauntlet_transfer.lua") --needs work?

--Allows to offer Chalice of Souls
modimport("scripts/actionhandler/sdf_runestone_offering.lua")

--Allows to offer Soul Helmet Offering
modimport("scripts/actionhandler/sdf_soul_helmet_offering_chalice_hall_of_heroes.lua")
modimport("scripts/actionhandler/sdf_soul_helmet_offering_merchant_gargoyle.lua")
modimport("scripts/actionhandler/sdf_soul_helmet_offering_shop_gargoyle.lua")

--Allows to offer Witch Talisman
modimport("scripts/actionhandler/sdf_witch_talisman_offering_chalice_altar.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_statue_sdf.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_merchant_gargoyle.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_spawn.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_hoh.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_hg.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_mcm.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_pg.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_ee.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_sdt.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_information_gargoyle_cc.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_king_peregrin.lua")
modimport("scripts/actionhandler/sdf_witch_talisman_offering_jack_of_the_green.lua")

--Allows Book of Gallowmere Animation and Reading
modimport("scripts/util/sdf_book_of_gallowmere_popup")
modimport("scripts/util/sdf_book_of_gallowmere_hud")
modimport("scripts/actionhandler/sdf_book_of_gallowmere_handler.lua")

--Allows GuttedOver effects
modimport("scripts/util/sdf_pumpking_guttedover_popup")
modimport("scripts/util/sdf_pumpking_guttedover_hud")

--Allows to offer King Peregrins Crown Lost Offering
modimport("scripts/actionhandler/sdf_king_peregrins_crown_lost_offering_king_peregrin.lua")

--Allows to offer King Peregrins Crown Offering
modimport("scripts/actionhandler/sdf_king_peregrins_crown_offering_king_peregrin.lua")

--Allows to offer Shadow Artefact Offering
modimport("scripts/actionhandler/sdf_shadow_artefact_offering_king_peregrin.lua")

--Allows to offer Shadow Talisman Offering
modimport("scripts/actionhandler/sdf_shadow_talisman_offering_king_peregrin.lua")

--Allows to imbue Dragon Potion
modimport("scripts/actionhandler/sdf_dragon_potion_imbue.lua")

--Allows Anubis Stone Necrotic Touch Animation
modimport("scripts/actionhandler/sdf_anubis_stone_necrotic_touch_handler.lua")

--Allows Asgard Golem Giants Ocarina Animation
modimport("scripts/actionhandler/sdf_asgard_golem_giants_ocarina_handler.lua")

--Allows to install Asgard Golem Optimize Data
modimport("scripts/actionhandler/sdf_asgard_golem_optimize_data_install.lua")

--Allows to gorge Wodens Brand
modimport("scripts/actionhandler/sdf_wodens_brand_gorge.lua")

--Allows Gallowmere Knight Commands
modimport("scripts/actionhandler/sdf_gallowmere_knight_command.lua")

--Allows to offer Book of Gallowmere Damaged
modimport("scripts/actionhandler/sdf_book_of_gallowmere_damaged_offering_jack_of_the_green.lua")

--Allows to offer Book of Gallowmere
modimport("scripts/actionhandler/sdf_book_of_gallowmere_offering_jack_of_the_green.lua")

--Allows to Mend Book of Gallowmere Restored With Restored Vellum
modimport("scripts/actionhandler/sdf_book_of_gallowmere_restored_vellum_mend.lua")

--Allows Player Special Combat Animations
modimport("scripts/postinits/sdf_postInits_combat_player.lua")

--Allows Custom Enity Drops and Kill Log and Pie Favorite Food
modimport("scripts/postinits/sdf_postInits_prefab.lua")

--Allows Pumpkin Gorge Well Generation
--modimport("scripts/actionhandler/sdf_pumpkin_gorge_well_enter.lua")
modimport("scripts/postinits/sdf_postInits_pumpkin_gorge_well_prefab.lua")
modimport("scripts/postinits/sdf_postInits_pumpkin_gorge_well_component.lua")
modimport("scripts/postinits/sdf_postInits_pumpkin_gorge_well_player.lua")
modimport("scripts/postcontructs/sdf_postContructs_pumpkin_gorge_well.lua")
modimport "scripts/stategraphs/SGsdf_pumpkin_gorge_well.lua"

--Allows Enchanted Earth Tomb Generation
modimport("scripts/actionhandler/sdf_enchanted_earth_tomb_enter.lua")
modimport("scripts/postinits/sdf_postInits_enchanted_earth_tomb_prefab.lua")
modimport("scripts/postinits/sdf_postInits_enchanted_earth_tomb_component.lua")
modimport("scripts/postinits/sdf_postInits_enchanted_earth_tomb_player.lua")
modimport("scripts/postcontructs/sdf_postContructs_enchanted_earth_tomb.lua")
modimport "scripts/stategraphs/SGsdf_enchanted_earth_tomb.lua"

--Allows Professors Lab Generation
modimport("scripts/actionhandler/sdf_professors_lab_enter.lua")
modimport("scripts/postinits/sdf_postInits_professors_lab_prefab.lua")
modimport("scripts/postinits/sdf_postInits_professors_lab_component.lua")
modimport("scripts/postinits/sdf_postInits_professors_lab_player.lua")
modimport("scripts/postcontructs/sdf_postContructs_professors_lab.lua")
modimport "scripts/stategraphs/SGsdf_professors_lab.lua"

--Allows Pistol Animation
modimport("scripts/actionhandler/sdf_pistol_handler.lua")

--Allows Blunderbuss Animation
modimport("scripts/actionhandler/sdf_blunderbuss_handler.lua")

--Allows Gatling Gun Animation
modimport("scripts/actionhandler/sdf_gatling_gun_control_handler.lua")
modimport("scripts/actionhandler/sdf_gatling_gun_handler.lua")
modimport("scripts/postinits/sdf_postInits_gatling_gun_prefab.lua")

--Create SDF Character
local skin_modes = {
    { 
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle", 
        scale = 0.75, 
        offset = { 0, -25 } 
    },
}
AddModCharacter("sdf", "MALE", skin_modes)