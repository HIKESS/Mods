local prefabs = {}
table.insert(prefabs, CreatePrefabSkin("mevileyes_none", 
{
	base_prefab = "mevileyes", 
	build_name_override = "mevileyes",
	
	type = "base",
	rarity = "Character",
	
	skin_tags = { "BASE", "MEVILEYES", },
	skins = {
		normal_skin = "mevileyes",     		
		ghost_skin = "ghost_mevileyes_build",
	},
	assets = {
		Asset( "ANIM", "anim/mevileyes.zip" ), 
		Asset( "ANIM", "anim/ghost_mevileyes_build.zip" ),
	},

}))

table.insert(prefabs, CreatePrefabSkin("ms_mevileyes_miko", 
{
	base_prefab = "mevileyes",
	build_name_override = "mevileyes_miko",
	torso_untuck_builds = { "mevileyes_miko", },
	type = "base",
	rarity = "ModMade", 
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "MEVILEYES",}, 
	skins = {
		normal_skin = "mevileyes_miko", 
		ghost_skin = "ghost_mevileyes_build", 
	},

	assets = {
		Asset( "ANIM", "anim/mevileyes_miko.zip" ),		
		Asset( "ANIM", "anim/ghost_mevileyes_build.zip" ),
	},
}))

table.insert(prefabs, CreatePrefabSkin("ms_mevileyes_maid", 
{
	base_prefab = "mevileyes",
	build_name_override = "mevileyes_maid",
	type = "base",
	rarity = "ModMade", 
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "MEVILEYES", "VICTORIAN"}, 
	skins = {
		normal_skin = "mevileyes_maid", 
		ghost_skin = "ghost_mevileyes_build", 
	},

	assets = {
		Asset( "ANIM", "anim/mevileyes_maid.zip" ),		
		Asset( "ANIM", "anim/ghost_mevileyes_build.zip" ),
	},
}))

table.insert(prefabs, CreatePrefabSkin("ms_mevileyes_wafuku", 
{
	base_prefab = "mevileyes",
	build_name_override = "mevileyes_wafuku",
	torso_untuck_builds = { "mevileyes_wafuku", },
	type = "base",
	rarity = "ModMade", 
	skip_item_gen = true,
	skip_giftable_gen = true,
	
	skin_tags = { "BASE", "MEVILEYES",}, 
	skins = {
		normal_skin = "mevileyes_wafuku", 
		ghost_skin = "ghost_mevileyes_build",		
	},

	assets = {
		Asset( "ANIM", "anim/mevileyes_wafuku.zip" ),		
		Asset( "ANIM", "anim/ghost_mevileyes_build.zip" ),
	},
}))

table.insert(prefabs, CreatePrefabSkin("ms_mevileyes_black", 
{
	base_prefab = "mevileyes",
	build_name_override = "mevileyes_black",
	type = "base",
	rarity = "ModMade", 
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "MEVILEYES", "SURVIVOR"}, 
	skins = {
		normal_skin = "mevileyes_black", 
		ghost_skin = "ghost_mevileyes_build",		
	},

	assets = {
		Asset( "ANIM", "anim/mevileyes_black.zip" ),		
		Asset( "ANIM", "anim/ghost_mevileyes_build.zip" ),
	},
}))

table.insert(prefabs, CreatePrefabSkin("ms_mevileyes_thai", 
{
	base_prefab = "mevileyes",
	build_name_override = "mevileyes_thai",
	torso_untuck_builds = { "mevileyes_thai", },
	type = "base",
	rarity = "Character", 
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "MEVILEYES",}, 
	skins = {
		normal_skin = "mevileyes_thai", 
		ghost_skin = "ghost_mevileyes_build",		
	},

	assets = {
		Asset( "ANIM", "anim/mevileyes_thai.zip" ),		
		Asset( "ANIM", "anim/ghost_mevileyes_build.zip" ),
	},
}))

table.insert(prefabs, CreatePrefabSkin("ms_mevileyes_miburo", 
{
	base_prefab = "mevileyes",
	build_name_override = "mevileyes_miburo",
	torso_untuck_builds = { "mevileyes_miburo", },
	type = "base",
	rarity = "Character", 
	skip_item_gen = true,
	skip_giftable_gen = true,
	skin_tags = { "BASE", "MEVILEYES",}, 
	skins = {
		normal_skin = "mevileyes_miburo", 
		ghost_skin = "ghost_mevileyes_build",		
	},

	assets = {
		Asset( "ANIM", "anim/mevileyes_miburo.zip" ),		
		Asset( "ANIM", "anim/ghost_mevileyes_build.zip" ),
	},
}))

return unpack(prefabs)