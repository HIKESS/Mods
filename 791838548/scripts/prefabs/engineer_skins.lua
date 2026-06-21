local prefabs = {}

table.insert(prefabs, CreatePrefabSkin("engineer_none",
{
	base_prefab = "engineer",
	build_name_override = "engineer",
	type = "base",
	rarity = "Character",
	rarity_modifier = "CharacterModifier",
	skins = {
		normal_skin = "engineer",
		ghost_skin = "ghost_engineer_build",
	},
	assets = {
		Asset( "ANIM", "anim/engineer.zip" ),
		Asset( "ANIM", "anim/ghost_engineer_build.zip" ),
	},
	skin_tags = { "BASE", "ENGINEER", },
--	has_leg_boot = true,
	skip_item_gen = true,
	skip_giftable_gen = true,
}))

table.insert(prefabs, CreatePrefabSkin("engineer_blu",
{
	base_prefab = "engineer",
	build_name_override = "engineer_blu",
	type = "base",
	rarity = "Distinguished",
	rarity_modifier = "Woven",
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "ENGINEER", "BLU"},
	skins = {
		normal_skin = "engineer_blu",
		ghost_skin = "ghost_engineer_build",
	},

	assets = {
		Asset( "ANIM", "anim/engineer_blu.zip" ),
		Asset( "ANIM", "anim/ghost_engineer_build.zip" ),
	},

}))
--2020
table.insert(prefabs, CreatePrefabSkin("engineer_rose",
{
	base_prefab = "engineer",
	build_name_override = "engineer_rose",
	type = "base",
	rarity = "Elegant",
	rarity_modifier = "Woven",
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "ENGINEER", "ROSE"},
	skins = {
		normal_skin = "engineer_rose",
		ghost_skin = "ghost_engineer_build",
	},

	assets = {
		Asset( "ANIM", "anim/engineer_rose.zip" ),
		Asset( "ANIM", "anim/ghost_engineer_build.zip" ),
	},

}))
--2017
table.insert(prefabs, CreatePrefabSkin("engineer_shadow",
{
	base_prefab = "engineer",
	build_name_override = "engineer_shadow",
	type = "base",
	rarity = "HeirloomElegant",
	rarity_modifier = "Woven",
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "ENGINEER", "SHADOW"},
	legs_cuff_size = { engineer_shadow = 5, },
	skins = {
		normal_skin = "engineer_shadow",
		ghost_skin = "ghost_engineer_build",
	},

	assets = {
		Asset( "ANIM", "anim/engineer_shadow.zip" ),
		Asset( "ANIM", "anim/ghost_engineer_build.zip" ),
	},

}))
table.insert(prefabs, CreatePrefabSkin("engineer_formal",
{
	base_prefab = "engineer",
	build_name_override = "engineer_formal",
	type = "base",
	rarity = "HeirloomElegant",
	rarity_modifier = "Woven",
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "ENGINEER", "FORMAL"},
	skins = {
		normal_skin = "engineer_formal",
		ghost_skin = "ghost_engineer_build",
	},

	assets = {
		Asset( "ANIM", "anim/engineer_formal.zip" ),
		Asset( "ANIM", "anim/ghost_engineer_build.zip" ),
	},

}))
table.insert(prefabs, CreatePrefabSkin("engineer_survivor",
{
	base_prefab = "engineer",
	build_name_override = "engineer_survivor",
	type = "base",
	rarity = "HeirloomElegant",
	rarity_modifier = "Woven",
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "ENGINEER", "SURVIVOR"},
	skins = {
		normal_skin = "engineer_survivor",
		ghost_skin = "ghost_engineer_build",
	},

	assets = {
		Asset( "ANIM", "anim/engineer_survivor.zip" ),
		Asset( "ANIM", "anim/ghost_engineer_build.zip" ),
	},

}))
--
return unpack(prefabs)