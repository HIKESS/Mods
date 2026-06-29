local _G=GLOBAL
local TECH=_G.TECH
local CRAFTING_FILTERS=_G.CRAFTING_FILTERS
local TECH_INGREDIENT=_G.TECH_INGREDIENT

function GLOBAL.AddModPrefabCookerRecipe(cooker,recipe)
env.AddCookerRecipe(cooker,recipe)
end

local dev_mode=_G.aipGetModConfig("dev_mode")=="enabled"


local language=_G.aipGetModConfig("language")


local additional_weapon=_G.aipGetModConfig("additional_weapon")=="open"


local additional_survival=_G.aipGetModConfig("additional_survival")=="open"


local additional_dress=_G.aipGetModConfig("additional_dress")=="open"


local function rec(name,tech,filters,ingredients,placerOrConfig)
local filterNames={}
for _,filter in ipairs(filters) do
table.insert(filterNames,filter.name)
end

local config={}
if type(placerOrConfig)=="table" then
config=placerOrConfig
else
config.placer=placerOrConfig
end


if config.atlas==nil then
config.atlas="images/inventoryimages/"..name..".xml"
end

AddRecipe2(
name,
ingredients,
tech,
config,
filterNames
)

AddRecipeToFilter(name,"AIP_FILTERS")
end

local function recWeapon(...)
if not additional_weapon then
return
end

return rec(...)
end

local function recSurvival(...)
if not additional_survival then
return
end

return rec(...)
end

local function recDress(...)
if not additional_dress then
return
end

return rec(...)
end








local LANG_MAP={
english={
AIP_FILTERS="[MOD] AIP",
},
chinese={
AIP_FILTERS="*额外物品包",
},
}
local LANG=LANG_MAP[language] or LANG_MAP.english

AddRecipeFilter({
name="AIP_FILTERS",
atlas="images/inventoryimages/aip_particles_bottle.xml",
image="aip_particles_bottle.tex"
})

_G.STRINGS.UI.CRAFTING_FILTERS.AIP_FILTERS=LANG.AIP_FILTERS
















recWeapon("aip_fish_sword",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.WEAPONS },
{Ingredient("pondfish",1),Ingredient("nightmarefuel",2),Ingredient("rope",1)})


recDress("aip_horse_head",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.CLOTHING },
{Ingredient("beefalowool",5),Ingredient("boneshard",3),Ingredient("beardhair",3)})


recDress("aip_armor_gambler",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.WEAPONS,CRAFTING_FILTERS.ARMOUR },
{Ingredient("papyrus",6),Ingredient("nightmarefuel",1),Ingredient("rope",1)})


recWeapon("aip_beehave",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC,CRAFTING_FILTERS.WEAPONS },
{Ingredient("tentaclespike",1),Ingredient("stinger",10),Ingredient("nightmarefuel",2)})


recSurvival("aip_blood_package",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.RESTORATION },
{Ingredient("mosquitosack",1),Ingredient("spidergland",3),Ingredient("ash",2)})


recDress("aip_blue_glasses",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.CLOTHING },
{Ingredient("steelwool",1),Ingredient("ice",2)})


rec("aip_dou_inscription_package",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC },
{Ingredient("aip_leaf_note",2,"images/inventoryimages/aip_leaf_note.xml"),Ingredient("lightbulb",2)})


rec("aip_glass_chest",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC },
{ Ingredient("moonglass",3),Ingredient("nightmarefuel",1),Ingredient("plantmeat",1) },
"aip_glass_chest_placer")


rec("aip_igloo",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.STRUCTURES },
{Ingredient("ice",21),Ingredient("carrot",1),Ingredient("twigs",2)},
"aip_igloo_placer")


recDress("aip_joker_face",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.CLOTHING },
{Ingredient("livinglog",3),Ingredient("spidereggsack",1),Ingredient("razor",1)})


rec("aip_krampus_plus",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.CONTAINERS },
{
Ingredient("klaussackkey",1),
Ingredient("fossil_piece",2),
Ingredient("glommerwings",1),
})


rec("aip_nectar_maker",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.RESTORATION,CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.CONTAINERS },
{Ingredient("boards",4),Ingredient("goldnugget",3),Ingredient("rope",2)},
"aip_nectar_maker_placer")


recSurvival("aip_plaster",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.RESTORATION },
{Ingredient("ash",1),Ingredient("poop",1),Ingredient("cutgrass",1)})


rec("aip_woodener",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC,CRAFTING_FILTERS.CONTAINERS },
{Ingredient("goldnugget",5),Ingredient("livinglog",2),Ingredient("boards",3)},
"aip_woodener_placer")


recWeapon("aip_xinyue_hoe",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{Ingredient("golden_farm_hoe",1),Ingredient("frozen_heart",1,"images/inventoryimages/frozen_heart.xml"),Ingredient("boneshard",5)})


rec("dark_observer",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC },
{Ingredient("livinglog",5),Ingredient("nightmarefuel",5),Ingredient("frozen_heart",1,"images/inventoryimages/frozen_heart.xml")},
"dark_observer_placer")


rec("incinerator",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.LIGHT },
{Ingredient("rocks",5),Ingredient("twigs",2),Ingredient("ash",1)},
"incinerator_placer")


recWeapon("popcorngun",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.WEAPONS },
{Ingredient("corn",2),Ingredient("houndstooth",4),Ingredient("silk",3)})


recWeapon("aip_jump_paper",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.WEAPONS },
{Ingredient("aip_veggie_wheat",1,"images/inventoryimages/aip_veggie_wheat.xml"),Ingredient("boomerang",1),Ingredient("papyrus",1)})


recWeapon("aip_blowdart",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.WEAPONS },
{Ingredient("aip_veggie_wheat",1,"images/inventoryimages/aip_veggie_wheat.xml"),Ingredient("goldnugget",2),Ingredient("rope",1)})



rec("chesspiece_aip_moon_builder",TECH.SCULPTING_ONE,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{Ingredient(TECH_INGREDIENT.SCULPTING,2),Ingredient("moonrocknugget",9),Ingredient("frozen_heart",1,"images/inventoryimages/frozen_heart.xml")},
{ nounlock=true,actionstr="SCULPTING",atlas="images/inventoryimages/chesspiece_aip_moon.xml",image="chesspiece_aip_moon.tex" })


rec("chesspiece_aip_doujiang_builder",TECH.SCULPTING_ONE,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{Ingredient(TECH_INGREDIENT.SCULPTING,2),Ingredient("plantmeat_cooked",1),Ingredient("pinecone",1)},
{ nounlock=true,actionstr="SCULPTING",atlas="images/inventoryimages/chesspiece_aip_doujiang.xml",image="chesspiece_aip_doujiang.tex" })


rec("chesspiece_aip_deer_builder",TECH.SCULPTING_ONE,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{Ingredient(TECH_INGREDIENT.SCULPTING,2),Ingredient("boneshard",2),Ingredient("beardhair",1)},
{ nounlock=true,actionstr="SCULPTING",atlas="images/inventoryimages/chesspiece_aip_deer.xml",image="chesspiece_aip_deer.tex" })



rec("aip_score_ball",TECH.LOST,{ CRAFTING_FILTERS.TOOLS },
{ Ingredient("pigskin",1),Ingredient("silk",1),Ingredient("cutgrass",6) })


rec("aip_fake_fly_totem",TECH.LOST,{ CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.MAGIC },
{ Ingredient("boards",1),Ingredient("rope",1),Ingredient("nightmarefuel",1) },
"aip_fake_fly_totem_placer")


rec("aip_fly_totem",TECH.LOST,{ CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.MAGIC },
{ Ingredient(_G.CHARACTER_INGREDIENT.SANITY,35) },
"aip_fly_totem_placer")


rec("aip_olden_tea",TECH.LOST,{ CRAFTING_FILTERS.RESTORATION },
{ Ingredient("messagebottleempty",1),Ingredient("sweettea",1),Ingredient("cutreeds",3) })


rec("aip_shell_stone",TECH.LOST,{ CRAFTING_FILTERS.TOOLS },
{ Ingredient("cookiecuttershell",1),Ingredient("moonrocknugget",1) })


local scepterData={
icon_atlas="images/inventoryimages/aip_dou_tech.xml",
icon_image="aip_dou_tech.tex",
is_crafting_station=true,
action_str="SCULPTING",
filter_text=_G.STRINGS.UI.CRAFTING_STATION_FILTERS.SCULPTING,
}

env.AddPrototyperDef("aip_dou_scepter",scepterData)
env.AddPrototyperDef("aip_dou_empower_scepter",scepterData)
env.AddPrototyperDef("aip_dou_huge_scepter",scepterData)


local inscriptions=require("utils/aip_scepter_util").inscriptions
for name,info in pairs(inscriptions) do
rec(name,TECH.AIP_DOU_SCEPTER,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.MAGIC },
info.recipes,{ nounlock=true })
end


env.AddPrototyperDef("aip_dou_totem",{
icon_atlas="images/inventoryimages/aip_totem_tech.xml",
icon_image="aip_totem_tech.tex",
is_crafting_station=true,
action_str="SCULPTING",
filter_text=_G.STRINGS.UI.CRAFTING_STATION_FILTERS.SCULPTING,
})


rec(
"aip_shadow_transfer",TECH.AIP_DOU_TOTEM,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.TOOLS,CRAFTING_FILTERS.MAGIC },
{ Ingredient("moonglass",2),Ingredient("moonrocknugget",2),Ingredient("aip_22_fish",1,"images/inventoryimages/aip_22_fish.xml") },
{ nounlock=true })


recWeapon(
"aip_track_tool",TECH.AIP_DOU_TOTEM,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.TOOLS,CRAFTING_FILTERS.MAGIC },
{ Ingredient("moonglass",6),Ingredient("moonrocknugget",3),Ingredient("transistor",1) },
{ nounlock=true })


rec(
"aip_glass_minecar",TECH.AIP_DOU_TOTEM,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.TOOLS,CRAFTING_FILTERS.MAGIC },
{ Ingredient("moonglass",5),Ingredient("goldnugget",4) },
{ nounlock=true })


recWeapon(
"aip_divine_rapier",TECH.AIP_DOU_TOTEM,{ CRAFTING_FILTERS.WEAPONS,CRAFTING_FILTERS.MAGIC,},
{
Ingredient("aip_oldone_hand",1,"images/inventoryimages/aip_oldone_hand.xml"),
Ingredient("aip_living_friendship",1,"images/inventoryimages/aip_living_friendship.xml"),
},
{ nounlock=true })



rec("chesspiece_aip_mouth_builder",TECH.LOST,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{ Ingredient(TECH_INGREDIENT.SCULPTING,2),Ingredient("aip_oldone_plant_broken",1,"images/inventoryimages/aip_oldone_plant_broken.xml") },
{ nounlock=true,atlas="images/inventoryimages/chesspiece_aip_mouth.xml",image="chesspiece_aip_mouth.tex" })


rec("chesspiece_aip_octupus_builder",TECH.LOST,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{ Ingredient(_G.TECH_INGREDIENT.SCULPTING,2),Ingredient("aip_oldone_plant_broken",1,"images/inventoryimages/aip_oldone_plant_broken.xml") },
{ nounlock=true,atlas="images/inventoryimages/chesspiece_aip_octupus.xml",image="chesspiece_aip_octupus.tex" })


rec("chesspiece_aip_fish_builder",TECH.LOST,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{ Ingredient(_G.TECH_INGREDIENT.SCULPTING,2),Ingredient("aip_oldone_plant_broken",1,"images/inventoryimages/aip_oldone_plant_broken.xml") },
{ nounlock=true,atlas="images/inventoryimages/chesspiece_aip_fish.xml",image="chesspiece_aip_fish.tex" })


rec("chesspiece_aip_nana_builder",TECH.LOST,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{ Ingredient(_G.TECH_INGREDIENT.SCULPTING,2),Ingredient("aip_oldone_plant_broken",1,"images/inventoryimages/aip_oldone_plant_broken.xml") },
{ nounlock=true,atlas="images/inventoryimages/chesspiece_aip_nana.xml",image="chesspiece_aip_nana.tex" })


rec("chesspiece_aip_empty_builder",TECH.LOST,{ CRAFTING_FILTERS.CRAFTING_STATION,CRAFTING_FILTERS.DECOR },
{ Ingredient(_G.TECH_INGREDIENT.SCULPTING,2),Ingredient("aip_oldone_plant_broken",1,"images/inventoryimages/aip_oldone_plant_broken.xml") },
{ nounlock=true,atlas="images/inventoryimages/chesspiece_aip_empty.xml",image="chesspiece_aip_empty.tex" })


recWeapon("aip_oldone_durian",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.WEAPONS },
{ Ingredient("durian",1),Ingredient("aip_oldone_plant_full",1,"images/inventoryimages/aip_oldone_plant_full.xml"),})


rec("aip_oldone_thestral_watcher_item",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC },
{
Ingredient("beefalowool",2),
Ingredient("aip_oldone_thestral_fur",1,"images/inventoryimages/aip_oldone_thestral_fur.xml"),
},{
atlas="images/inventoryimages/aip_oldone_thestral_watcher.xml",
image="aip_oldone_thestral_watcher.tex",
})


rec("aip_garbage_dump",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.STRUCTURES },
{
Ingredient("aip_oldone_plant_broken",2,"images/inventoryimages/aip_oldone_plant_broken.xml"),
Ingredient("spoiled_food",1),
Ingredient("powcake",1)
},
"aip_garbage_dump_placer")


rec("aip_oldone_heal",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.RESTORATION },
{
Ingredient("aip_oldone_plant_full",1,"images/inventoryimages/aip_oldone_plant_full.xml"),
Ingredient("cutreeds",2),
Ingredient("seeds",1),
})


recDress("aip_monkey_face",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.CLOTHING },
{
Ingredient("aip_oldone_plant_broken",2,"images/inventoryimages/aip_oldone_plant_broken.xml"),
Ingredient("aip_bezoar",1,"images/inventoryimages/aip_bezoar.xml"),
Ingredient("nightmarefuel",1),
})


rec("aip_bezoar_cursed",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC },
{
Ingredient("aip_bezoar",1,"images/inventoryimages/aip_bezoar.xml"),
Ingredient("cursed_monkey_token",1,nil,nil,"cursed_beads1.tex"),
},{ nounlock=true })


recDress("aip_armor_balrog",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.ARMOUR },
{
Ingredient("armordragonfly",1),
Ingredient("aip_jump_paper",3,"images/inventoryimages/aip_jump_paper.xml"),
})


rec("aip_ghost_fire",TECH.LOST,{ CRAFTING_FILTERS.LIGHT },
{
Ingredient("aip_oldone_meat",1,"images/inventoryimages/aip_oldone_meat.xml"),
Ingredient("nightmarefuel",1),
})


rec("aip_teleport_scroll",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.MAGIC },
{
Ingredient("aip_oldone_plant_broken",1,"images/inventoryimages/aip_oldone_plant_broken.xml"),
Ingredient("nightmarefuel",1),
Ingredient("papyrus",1),
})


rec("aip_gholdengo",TECH.LOST,{ CRAFTING_FILTERS.WEAPONS },
{
Ingredient("aip_oldone_meat",1,"images/inventoryimages/aip_oldone_meat.xml"),
Ingredient("goldnugget",99),
})


recSurvival("aip_amulet_egg",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.CLOTHING },
{Ingredient("bird_egg",1),Ingredient("rope",1),Ingredient("charcoal",1)})



rec("aip_particles_bottle",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{ Ingredient("messagebottleempty",1),Ingredient("transistor",1),})


rec("aip_particles_vest_entangled",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
Ingredient("heatrock",2),
},
{ atlas="images/inventoryimages/aip_particles_entangled_blue.xml",image="aip_particles_entangled_blue.tex" })



rec("aip_particles_echo",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
Ingredient("heatrock",1),Ingredient("thulecite",1),
})


rec("aip_particles_heart",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
Ingredient("heatrock",1),Ingredient("reviver",1),
})


rec("aip_particles_morning",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
Ingredient("heatrock",1),Ingredient("red_cap",1),
})


rec("aip_particles_dusk",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
Ingredient("heatrock",1),Ingredient("green_cap",1),
})


rec("aip_particles_night",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
Ingredient("heatrock",1),Ingredient("blue_cap",1),
})





rec("aip_tricky_thrower",TECH.MAGIC_TWO,{ CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.MAGIC },
{ Ingredient("pumpkin_lantern",1),Ingredient("aip_oldone_deer_eye_fruit",1,"images/inventoryimages/aip_oldone_deer_eye_fruit.xml"),},
"aip_tricky_thrower_placer")


rec("aip_showcase",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.RESTORATION,CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.CONTAINERS },
{Ingredient("cutstone",2),Ingredient("ash",1)},
"aip_showcase_placer")


rec("aip_showcase_ice",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.RESTORATION,CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.CONTAINERS },
{Ingredient("ice",8),Ingredient("saltrock",1)},
"aip_showcase_ice_placer")


rec("aip_weapon_box",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.CONTAINERS,CRAFTING_FILTERS.STRUCTURES },
{
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
Ingredient("aip_oldone_plant_full",6,"images/inventoryimages/aip_oldone_plant_full.xml"),
Ingredient("purebrilliance",1)
},"aip_weapon_box_placer")



rec("aip_fig_salve",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.RESTORATION },
{Ingredient("fig",1),Ingredient("aip_leaf_note",2,"images/inventoryimages/aip_leaf_note.xml")})


rec("aip_pet_catcher",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_veggie_wheat",1,"images/inventoryimages/aip_veggie_wheat.xml"),
Ingredient("pomegranate",1),
Ingredient("lightbulb",1),
})


rec("aip_pet_trigger",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("moonrocknugget",1),
Ingredient("flint",1),
})


rec("aip_cozy_nest",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.DECOR },
{
Ingredient("beefalowool",2),
Ingredient("silk",2),
Ingredient("petals",4),
},"aip_cozy_nest_placer")


rec("aip_grandfather_clock",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.STRUCTURES,CRAFTING_FILTERS.DECOR },
{
Ingredient("boards",4),
Ingredient("goldnugget",2),
Ingredient("aip_particles_bottle_charged",1,"images/inventoryimages/aip_particles_bottle_charged.xml"),
},"aip_grandfather_clock_placer")


rec("aip_pet_box",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("papyrus",2),
Ingredient("silk",1),
})


rec("aip_pet_fudge",TECH.SCIENCE_ONE,{ CRAFTING_FILTERS.TOOLS },
{
Ingredient("aip_veggie_wheat",1,"images/inventoryimages/aip_veggie_wheat.xml"),
Ingredient("monstermeat_dried",1),
})



rec("aip_lantern",TECH.SCIENCE_TWO,{ CRAFTING_FILTERS.LIGHT,CRAFTING_FILTERS.DECOR },
{
Ingredient("papyrus",2),
Ingredient("silk",2),
Ingredient("lightbulb",1),
})


rec("aip_lantern_stand",TECH.SCIENCE_TWO,{
CRAFTING_FILTERS.LIGHT,
CRAFTING_FILTERS.CONTAINERS,
CRAFTING_FILTERS.STRUCTURES,
CRAFTING_FILTERS.DECOR,
},{
Ingredient("phlegm",1),
Ingredient("boards",2),
Ingredient("rope",2),
},"aip_lantern_stand_placer")



rec("aip_torch",TECH.LOST,{ CRAFTING_FILTERS.LIGHT },
{ Ingredient("driftwood_log",1),Ingredient("gunpowder",1),Ingredient("ash",1) })


rec("aip_torch_stand_final",TECH.LOST,{ CRAFTING_FILTERS.LIGHT,CRAFTING_FILTERS.CONTAINERS,CRAFTING_FILTERS.STRUCTURES },
{
Ingredient("canary",1),
Ingredient("feather_robin",1),
Ingredient("purebrilliance",1)
},"aip_torch_stand_final_placer")
























































