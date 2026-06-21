local assets =
{
	Asset( "ANIM", "anim/wiltonmod.zip" ),
	Asset( "ANIM", "anim/wiltonmod_skin1.zip" ),
	Asset( "ANIM", "anim/willhayden.zip" ),
	Asset( "ANIM", "anim/ghost_wiltonmod_build.zip" ),
}

local skins =
{
	normal_skin = "wiltonmod",
	ghost_skin = "ghost_wiltonmod_build",
}

local skins_char =
{
	normal_skin = "wiltonmod_skin1",
	ghost_skin = "ghost_wiltonmod_build",
}

local skins_scarecrow =
{
	normal_skin = "willhayden",
	ghost_skin = "ghost_wiltonmod_build",
}

local base_prefab = "wiltonmod"

local tags = {"WILTON", "CHARACTER"}

return CreatePrefabSkin("wiltonmod_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	tags = tags,
	build_name_override = "wiltonmod",
	skip_item_gen = true,
	skip_giftable_gen = true,
}),

CreatePrefabSkin("wiltonmod_skin1_none",  --ThePlayer.components.skinner:SetSkinName("stu_skin1_none")
{
	base_prefab = base_prefab, 	
	skins = skins_char,  
	assets = assets,
	bigportrait = {symbol = "wiltonmod_skin1_none.tex", build = "bigportraits/wiltonmod_skin1_none.xml"},
	skin_tags = {"WILTON", "CHARACTER", "LAVA"},
	build_name_override = "wiltonmod_skin1",  
	rarity = "HeirloomElegant",
	--skip_item_gen = true,
	--skip_giftable_gen = true,	
}),

CreatePrefabSkin("wiltonmod_scarecrow_none",
{
	base_prefab = base_prefab,
	skins = skins_scarecrow,
	assets = assets,
	bigportrait = {symbol = "wiltonmod_scarecrow_none_oval.tex", build = "bigportraits/wiltonmod_scarecrow_none.xml"},
	skin_tags = {"WILTON", "CHARACTER", "HALLOWED"},
	build_name_override = "willhayden",
	rarity = "Loyal",
})
