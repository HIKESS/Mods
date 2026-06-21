local SDFBook_of_Gallowmere_Page_Data = Class(function(self)
    self.page_inventory = {}
    self.page_friendlies = {}
    self.page_enemies = {}
    self.page_bosses = {}
end)

function SDFBook_of_Gallowmere_Page_Data:GetPageInventoryData()
    self.page_inventory ={

	[0] = "sdf_book_of_gallowmere_page_inventory_blank",
	[1] = "sdf_book_of_gallowmere_page_inventory_dans_helmet_and_arm",
	[2] = "sdf_book_of_gallowmere_page_inventory_souls_and_chalice_of_souls",
	[3] = "sdf_book_of_gallowmere_page_inventory_life_bottle_and_energy_vial",

	[4] = "sdf_book_of_gallowmere_page_inventory_copper_and_silver_shield",
	[5] = "sdf_book_of_gallowmere_page_inventory_gold_shield",

	[6] = "sdf_book_of_gallowmere_page_inventory_small_sword",
	[7] = "sdf_book_of_gallowmere_page_inventory_broad_and_enchanted_sword",
	[8] = "sdf_book_of_gallowmere_page_inventory_magic_sword",
	[9] = "sdf_book_of_gallowmere_page_inventory_wodens_brand",
	[10] = "sdf_book_of_gallowmere_page_inventory_club",
	[11] = "sdf_book_of_gallowmere_page_inventory_hammer",
	[12] = "sdf_book_of_gallowmere_page_inventory_axe",
	[13] = "sdf_book_of_gallowmere_page_inventory_cane_stick",
	[14] = "sdf_book_of_gallowmere_page_inventory_spade",

	[15] = "sdf_book_of_gallowmere_page_inventory_throwing_daggers",
	[16] = "sdf_book_of_gallowmere_page_inventory_crossbow_and_standard_bolts",
	[17] = "sdf_book_of_gallowmere_page_inventory_flaming_crossbow_and_flaming_bolts",
	[18] = "sdf_book_of_gallowmere_page_inventory_longbow_and_standard_arrows",
	[19] = "sdf_book_of_gallowmere_page_inventory_flaming_longbow_and_flaming_arrows",
	[20] = "sdf_book_of_gallowmere_page_inventory_magic_longbow_and_magical_arrows",
	[21] = "sdf_book_of_gallowmere_page_inventory_spear",
	[22] = "sdf_book_of_gallowmere_page_inventory_pistol_and_standard_bullets",
	[23] = "sdf_book_of_gallowmere_page_inventory_blunderbuss_and_standard_shots",
	[24] = "sdf_book_of_gallowmere_page_inventory_lightning_gauntlet",
	[25] = "sdf_book_of_gallowmere_page_inventory_lightning_and_goodlightning",
	[26] = "sdf_book_of_gallowmere_page_inventory_gatling_gun_and_standard_munitions",

	[27] = "sdf_book_of_gallowmere_page_inventory_bombs",
	[28] = "sdf_book_of_gallowmere_page_inventory_chicken_drumstick",

	[29] = "sdf_book_of_gallowmere_page_inventory_victorian_suit",
	[30] = "sdf_book_of_gallowmere_page_inventory_dragon_potion",
	[31] = "sdf_book_of_gallowmere_page_inventory_gold_armor",

	[32] = "sdf_book_of_gallowmere_page_inventory_rune_holder_and_runes",

	[33] = "sdf_book_of_gallowmere_page_inventory_soul_helmet",
	[34] = "sdf_book_of_gallowmere_page_inventory_witch_talisman",
	[35] = "sdf_book_of_gallowmere_page_inventory_trampled_and_restored_vellum_of_the_book_of_gallowmere",
	[36] = "sdf_book_of_gallowmere_page_inventory_book_of_gallowmere",
	[37] = "sdf_book_of_gallowmere_page_inventory_king_peregrins_crown",
	[38] = "sdf_book_of_gallowmere_page_inventory_eye_of_amon_ra",
	[39] = "sdf_book_of_gallowmere_page_inventory_anubis_stone_parts",
	[40] = "sdf_book_of_gallowmere_page_inventory_anubis_stone",
	[41] = "sdf_book_of_gallowmere_page_inventory_shadow_artefact_and_shadow_talisman",
	[42] = "sdf_book_of_gallowmere_page_inventory_carnival_token",
    }
    return self.page_inventory
end

function SDFBook_of_Gallowmere_Page_Data:GetPageFriendliesData()
    self.page_friendlies ={

	[0] = "sdf_book_of_gallowmere_page_friendlies_blank",
	[1] = "sdf_book_of_gallowmere_page_friendlies_sir_daniel_wigginbottom_fortesque",
	[2] = "sdf_book_of_gallowmere_page_friendlies_sir_daniel_fortesque",
	[3] = "sdf_book_of_gallowmere_page_friendlies_morten_the_earthworm",
	[4] = "sdf_book_of_gallowmere_page_friendlies_princess_kiya",
	[5] = "sdf_book_of_gallowmere_page_friendlies_professor_hamilton_kift",

	[6] = "sdf_book_of_gallowmere_page_friendlies_mr_option",
	[7] = "sdf_book_of_gallowmere_page_friendlies_winston_chapelmount",
	[8] = "sdf_book_of_gallowmere_page_friendlies_information_gargoyles",
	[9] = "sdf_book_of_gallowmere_page_friendlies_merchant_and_shop_gargoyles",
	[10] = "sdf_book_of_gallowmere_page_friendlies_the_spiv",

	[11] = "sdf_book_of_gallowmere_page_friendlies_the_heroes",
	[12] = "sdf_book_of_gallowmere_page_friendlies_canny_tim",
	[13] = "sdf_book_of_gallowmere_page_friendlies_stanyer_iron_hewer",
	[14] = "sdf_book_of_gallowmere_page_friendlies_bloodmonath_skull_cleaver",
	[15] = "sdf_book_of_gallowmere_page_friendlies_woden_the_mighty",
	[16] = "sdf_book_of_gallowmere_page_friendlies_karl_sturnguard",
	[17] = "sdf_book_of_gallowmere_page_friendlies_dirk_streadfast",
	[18] = "sdf_book_of_gallowmere_page_friendlies_ravenhooves_the_archer",
	[19] = "sdf_book_of_gallowmere_page_friendlies_imanzi_shongama",
	[20] = "sdf_book_of_gallowmere_page_friendlies_megwynne_stormbinder",

	[21] = "sdf_book_of_gallowmere_page_friendlies_king_peregrin",
	[22] = "sdf_book_of_gallowmere_page_friendlies_knight_and_squire_of_gallowmere",
	[23] = "sdf_book_of_gallowmere_page_friendlies_mr_organ",
	[24] = "sdf_book_of_gallowmere_page_friendlies_the_town_mayor",
	[25] = "sdf_book_of_gallowmere_page_friendlies_captive_farmers",
	[26] = "sdf_book_of_gallowmere_page_friendlies_chickens",

	[27] = "sdf_book_of_gallowmere_page_friendlies_pumpkin_witch",
	[28] = "sdf_book_of_gallowmere_page_friendlies_forest_witch",
	[29] = "sdf_book_of_gallowmere_page_friendlies_jack_of_the_green",

	[30] = "sdf_book_of_gallowmere_page_friendlies_kul_katura",
	[31] = "sdf_book_of_gallowmere_page_friendlies_fairies",
	[32] = "sdf_book_of_gallowmere_page_friendlies_elephant_dragons",
	[33] = "sdf_book_of_gallowmere_page_friendlies_vulture",

	[34] = "sdf_book_of_gallowmere_page_friendlies_mullock_king",
	[35] = "sdf_book_of_gallowmere_page_friendlies_mullocks",
	[36] = "sdf_book_of_gallowmere_page_friendlies_mr_apple",
    }
    return self.page_friendlies
end

function SDFBook_of_Gallowmere_Page_Data:GetPageEnemiesData()
    self.page_enemies ={

	[0] = "sdf_book_of_gallowmere_page_enemies_blank",
	[1] = "sdf_book_of_gallowmere_page_enemies_zombies",
	[2] = "sdf_book_of_gallowmere_page_enemies_severed_hands",
	[3] = "sdf_book_of_gallowmere_page_enemies_boulder_gargoyles",
	[4] = "sdf_book_of_gallowmere_page_enemies_headless_zombies",
	[5] = "sdf_book_of_gallowmere_page_enemies_imps",
	[6] = "sdf_book_of_gallowmere_page_enemies_graveyard_wolves",

	[7] = "sdf_book_of_gallowmere_page_enemies_scarecrows",
	[8] = "sdf_book_of_gallowmere_page_enemies_mad_farmers",
	[9] = "sdf_book_of_gallowmere_page_enemies_mecha_farmers",
	[10] = "sdf_book_of_gallowmere_page_enemies_corn_killers",
	[11] = "sdf_book_of_gallowmere_page_enemies_bats",

	[12] = "sdf_book_of_gallowmere_page_enemies_bearded_ladies",

	[13] = "sdf_book_of_gallowmere_page_enemies_pumpkin_plants",
	[14] = "sdf_book_of_gallowmere_page_enemies_pumpkin_bombs",
	[15] = "sdf_book_of_gallowmere_page_enemies_rats",

	[16] = "sdf_book_of_gallowmere_page_enemies_townspeople",
	[17] = "sdf_book_of_gallowmere_page_enemies_boiler_guards",

	[18] = "sdf_book_of_gallowmere_page_enemies_mad_monks",
	[19] = "sdf_book_of_gallowmere_page_enemies_hedges",
	[20] = "sdf_book_of_gallowmere_page_enemies_head_bangers",

	[21] = "sdf_book_of_gallowmere_page_enemies_dragon_toads",
	[22] = "sdf_book_of_gallowmere_page_enemies_poisonous_plants",
	[23] = "sdf_book_of_gallowmere_page_enemies_shadow_demons",

	[24] = "sdf_book_of_gallowmere_page_enemies_vampire_girls",
	[25] = "sdf_book_of_gallowmere_page_enemies_renfields",

	[26] = "sdf_book_of_gallowmere_page_enemies_ants",
	[27] = "sdf_book_of_gallowmere_page_enemies_armored_knights",
	[28] = "sdf_book_of_gallowmere_page_enemies_tentacles",
	[29] = "sdf_book_of_gallowmere_page_enemies_mud_knights",
	[30] = "sdf_book_of_gallowmere_page_enemies_ghouls",

	[31] = "sdf_book_of_gallowmere_page_enemies_fish_monsters",
	[32] = "sdf_book_of_gallowmere_page_enemies_watchers",
	[33] = "sdf_book_of_gallowmere_page_enemies_guardians_of_mellowmede",
	[34] = "sdf_book_of_gallowmere_page_enemies_rhinotaurs",

	[35] = "sdf_book_of_gallowmere_page_enemies_the_condemned",
	[36] = "sdf_book_of_gallowmere_page_enemies_mummies",
	[37] = "sdf_book_of_gallowmere_page_enemies_serpent_of_gallowmere",

	[38] = "sdf_book_of_gallowmere_page_enemies_mace_knights",
	[39] = "sdf_book_of_gallowmere_page_enemies_stone_golems",
	[40] = "sdf_book_of_gallowmere_page_enemies_jabberwocky",

	[41] = "sdf_book_of_gallowmere_page_enemies_pirate_crew",
	[42] = "sdf_book_of_gallowmere_page_enemies_pirate_officers",
	[43] = "sdf_book_of_gallowmere_page_enemies_peelers",
	[44] = "sdf_book_of_gallowmere_page_enemies_flying_clocks",

	[45] = "sdf_book_of_gallowmere_page_enemies_fazguls",
	[46] = "sdf_book_of_gallowmere_page_enemies_octomators",
    }
    return self.page_enemies
end

function SDFBook_of_Gallowmere_Page_Data:GetPageBossesData()
    self.page_bosses ={

	[0] = "sdf_book_of_gallowmere_page_bosses_blank",
	[1] = "sdf_book_of_gallowmere_page_bosses_zarok",
	[2] = "sdf_book_of_gallowmere_page_bosses_lord_palethorn_of_shoreditch",
	[3] = "sdf_book_of_gallowmere_page_bosses_dogman",
	[4] = "sdf_book_of_gallowmere_page_bosses_mander",

	[5] = "sdf_book_of_gallowmere_page_bosses_stained_glass_demon",
	[6] = "sdf_book_of_gallowmere_page_bosses_tyrannosaurus_wrecks",
	[7] = "sdf_book_of_gallowmere_page_bosses_guardians_of_the_graveyard",
	[8] = "sdf_book_of_gallowmere_page_bosses_standard_elephantbot",
	[9] = "sdf_book_of_gallowmere_page_bosses_deluxe_standard_elephantbot",
	[10] = "sdf_book_of_gallowmere_page_bosses_pumpkin_king",
	[11] = "sdf_book_of_gallowmere_page_bosses_dragon_bird",
	[12] = "sdf_book_of_gallowmere_page_bosses_demonettes",
	[13] = "sdf_book_of_gallowmere_page_bosses_the_count",
	[14] = "sdf_book_of_gallowmere_page_bosses_queen_ant",
	[15] = "sdf_book_of_gallowmere_page_bosses_mean_old_dragon",
	[16] = "sdf_book_of_gallowmere_page_bosses_iron_slugger",
	[17] = "sdf_book_of_gallowmere_page_bosses_ghost_ship_captain",

	[18] = "sdf_book_of_gallowmere_page_bosses_lord_kardok",
	[19] = "sdf_book_of_gallowmere_page_bosses_the_ripper",
	[20] = "sdf_book_of_gallowmere_page_bosses_zarok_beast_transformation",
	[21] = "sdf_book_of_gallowmere_page_bosses_the_demon",
	[22] = "sdf_book_of_gallowmere_page_bosses_queenzilla",
    }
    return self.page_bosses
end

function SDFBook_of_Gallowmere_Page_Data:Save(force_save)
    --if force_save then
	--local str = json.encode({ discovered_mobs = self.discovered_mobs, learned_mobs = self.learned_mobs })
	--TheSim:SetPersistentString("bestiary", str, false) -- Basically a carbon copy of cookbooks saving/loading
    --end
end

function SDFBook_of_Gallowmere_Page_Data:Load()
    self.page_inventory = self:GetPageInventoryData()
    self.page_friendlies = self:GetPageFriendliesData()
    self.page_enemies = self:GetPageEnemiesData()
    self.page_bosses = self:GetPageBossesData()
end

return SDFBook_of_Gallowmere_Page_Data
