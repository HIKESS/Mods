local prefabs = {}



table.insert(prefabs, CreatePrefabSkin("william_none", 
{
	base_prefab = "william",
	build_name_override = "william",
	skins = { ghost_skin = "ghost_william_build", mighty_skin = "william_insane", wimpy_skin = "william_scuff", normal_skin = "william", },
	assets = {
	Asset( "ANIM", "anim/william.zip" ),
	Asset( "ANIM", "anim/william_neutron.zip" ),
	Asset( "ANIM", "anim/wil.zip" ),
	Asset( "ANIM", "anim/wx90.zip" ),
	Asset( "ANIM", "anim/reaper_robotw90.zip" ),
	Asset( "ANIM", "anim/bbrute_robotw90.zip" ),
	Asset( "ANIM", "anim/william_insane.zip" ),
	Asset( "ANIM", "anim/william_scuff.zip" ),
	Asset( "ANIM", "anim/ghost_william_build.zip" ),
	},
	skin_tags = { "BASE", "WILLIAM", },
	rarity = "Character",
	torso_tuck = "untucked",
	skip_item_gen = true,
	skip_giftable_gen = true,
}))


table.insert(prefabs, CreatePrefabSkin("william_shadow", 
{
	base_prefab = "william",
	build_name_override = "william",
	skins = { ghost_skin = "ghost_william_build", mighty_skin = "william_neutron_insane", wimpy_skin = "william_neutron_scuff", normal_skin = "william_neutron", },
	assets = {
	Asset( "ANIM", "anim/william_neutron.zip" ),
	Asset( "ANIM", "anim/william_neutron_insane.zip" ),
	Asset( "ANIM", "anim/william_neutron_scuff.zip" ),
	Asset( "ANIM", "anim/ghost_william_build.zip" ),
	},
	skin_tags = { "BASE", "WILLIAM", "SHADOW" },
	torso_tuck = "untucked",
	rarity = "ModMade",
	skip_item_gen = true,
	skip_giftable_gen = true,
}))

return unpack(prefabs)