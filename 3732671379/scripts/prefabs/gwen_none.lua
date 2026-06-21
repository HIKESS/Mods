local assets =
{
	Asset( "ANIM", "anim/Gwen.zip" ),
	Asset( "ANIM", "anim/ghost_gwen_build.zip" ),
}

local skins =
{
	normal_skin = "Gwen",
	ghost_skin = "ghost_gwen_build",
}

local base_prefab = "gwen"

local tags = {"BASE" ,"ESCTEMPLATE", "CHARACTER"}

return CreatePrefabSkin("gwen_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	skin_tags = tags,
	
	build_name_override = "gwen",
	rarity = "Character",
})