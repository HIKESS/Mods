local assets =
{
	Asset( "ANIM", "anim/kodi.zip" ),
	Asset( "ANIM", "anim/ghost_kodi_build.zip" ),
}
local skins =
{
	normal_skin = "kodi",
	ghost_skin = "ghost_kodi_build",
}
return CreatePrefabSkin("kodi_none",
{
	base_prefab = "kodi",
	type = "base",
	assets = assets,
	skins = skins,
	skin_tags = {"KODI", "CHARACTER", "BASE"},
	build_name_override = "kodi",
	rarity = "Character",
})
