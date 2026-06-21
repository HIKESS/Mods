--- 威尔顿模组的合成配方与物品皮肤配置。
-- 这里注册所有与角色相关的物品配方，并为部分物品开启皮肤功能，以供合成面板选择。
-- 注意：只负责静态数据（配方/皮肤映射），不包含具体物品行为逻辑。

Recipe("boneshard_wilton", {Ingredient(CHARACTER_INGREDIENT.HEALTH, 20)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages.xml", 
"boneshard.tex", nil, "boneshard")

Recipe("fossil_piece", {Ingredient("boneshard", 2), Ingredient("nightmarefuel", 2), Ingredient("rocks", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages.xml", 
"fossil_piece.tex")

Recipe("skeleton", {Ingredient("boneshard", 2)},  --Ingredient("boneshard", 2), 
RECIPETABS.TOWN, TECH.NONE, "skeleton_placer", 1, nil, nil, "wiltonmod",
"images/inventoryimages/sturdyskeleton.xml", "sturdyskeleton.tex") 

Recipe("wilton_resurrectiongrave", {Ingredient("marble", 2), Ingredient("nightmarefuel", 4)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true, placer = "wilton_resurrectiongrave_placer", builder_skill = "wiltonmod_skill2_3"}, nil, nil, 1, "wiltonmod",
nil,
"dug_gravestone.tex")

Recipe("wiltonmod_boneheart", {Ingredient("boneshard", 2), Ingredient(CHARACTER_INGREDIENT.HEALTH, 40)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_boneheart.xml", 
"wiltonmod_boneheart.tex")

Recipe("wiltonmod_bonepaste", {Ingredient("boneshard", 1), Ingredient("spidergland", 1), Ingredient("spoiled_food", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_bonepaste.xml", 
"wiltonmod_bonepaste.tex")

Recipe("wiltonmod_shoot", {Ingredient("boneshard", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 5, "wiltonmod",
"images/inventoryimages/wiltonmod_shoot.xml", 
"wiltonmod_shoot.tex")

Recipe("wiltonmod_sharpbone", {Ingredient("boneshard", 6), Ingredient("rope", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_sharpbone.xml", 
"wiltonmod_sharpbone.tex")

Recipe("wiltonmod_bonehammer", {Ingredient("boneshard", 4), Ingredient("fossil_piece", 2), Ingredient("rope", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_bonehammer.xml", 
"wiltonmod_bonehammer.tex")

Recipe("wiltonmod_staff1", {Ingredient("wiltonmod_boneheart", 1, "images/inventoryimages/wiltonmod_boneheart.xml", false, "wiltonmod_boneheart.tex"), Ingredient("purplegem", 1), Ingredient("boneshard", 4), Ingredient("fossil_piece", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true, builder_skill = "wiltonmod_skill2_2"}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_staff1.xml", 
"wiltonmod_staff1.tex")

Recipe("wiltonmod_staff2", {Ingredient("wiltonmod_staff1", 1, "images/inventoryimages/wiltonmod_staff1.xml", false, "wiltonmod_staff1.tex"), Ingredient("dreadstone", 6), Ingredient("horrorfuel", 4), Ingredient("voidcloth", 8)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod_shadow_aligned",
"images/inventoryimages/wiltonmod_staff2.xml", 
"wiltonmod_staff2.tex")

Recipe("wiltonmod_staff3", {Ingredient("wiltonmod_staff1", 1, "images/inventoryimages/wiltonmod_staff1.xml", false, "wiltonmod_staff1.tex"), Ingredient("moonrocknugget", 6), Ingredient("purebrilliance", 4), Ingredient("lunarplant_husk", 8)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod_lunar_aligned",
"images/inventoryimages/wiltonmod_staff3.xml", 
"wiltonmod_staff3.tex")

Recipe("wiltonmod_hat", {Ingredient("skeletonhat", 1), Ingredient("dreadstone", 4), Ingredient("horrorfuel", 4), Ingredient("voidcloth", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true, builder_skill = "wiltonmod_skill2_12"}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_hat.xml", 
"wiltonmod_hat.tex")

Recipe("wiltonmod_armor", {Ingredient("armorskeleton", 1), Ingredient("dreadstone", 6), Ingredient("horrorfuel", 6), Ingredient("voidcloth", 3)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true, builder_skill = "wiltonmod_skill2_15"}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_armor.xml", 
"wiltonmod_armor.tex")

Recipe("wiltonmod_pack", {Ingredient("goldnugget", 20), Ingredient("boards", 6), Ingredient("pigskin", 4), Ingredient("rope", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_pack.xml", 
"wiltonmod_pack.tex")

Recipe("wiltonmod_chest", {Ingredient("boneshard", 6), Ingredient("boards", 2)},
RECIPETABS.TOWN, TECH.NONE, "wiltonmod_chest_placer", 1, nil, nil, "wiltonmod",
"images/inventoryimages/wiltonmod_chest.xml", "wiltonmod_chest.tex")

Recipe("undead_armory", {
    Ingredient("cutstone", 4),
    Ingredient("boards", 4),
    Ingredient("boneshard", 12),
    Ingredient("marble", 4),
}, RECIPETABS.TOWN, TECH.NONE,
{no_deconstruction = true, placer = "undead_armory_placer", builder_skill = "wiltonmod_skill2_4"}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/undead_armory_icon.xml", "undead_armory_icon.tex") 

--- 载入通用物品皮肤 API，对合成面板与建造逻辑做统一扩展。
-- 该工具会读取下方 PREFAB_SKINS 与 AllRecipes 标记，为物品提供皮肤下拉选择。
modimport("scripts/util/item_skin_api.lua")  

--- 为 `wiltonmod_boneheart` 与 `wiltonmod_shoot` 注册可用皮肤列表。
-- 与 Hornet 的皮肤系统约定一致，名称需在 Atlas 与 prefab 中一一对应。
-- 额外：将威尔顿复生墓碑接入官方 gravestone 皮肤池，使其可被重塑权杖等官方皮肤逻辑识别。
GLOBAL.PREFAB_SKINS.wilton_resurrectiongrave = GLOBAL.PREFAB_SKINS.gravestone

GLOBAL.PREFAB_SKINS.wiltonmod_boneheart =
{
	"wiltonmod_boneheart_skin"
}

GLOBAL.PREFAB_SKINS.wiltonmod_shoot =  --添加皮肤
{
	"wiltonmod_shoot_skin"
}

GLOBAL.PREFAB_SKINS.wiltonmod_sharpbone =
{
	"wiltonmod_sharpbone_skin",
	"wiltonmod_sharpbone_stonesword"
}

GLOBAL.PREFAB_SKINS.wiltonmod_bonehammer =
{
	"wiltonmod_bonehammer_skin"
}

GLOBAL.PREFAB_SKINS.skeleton =
{
	"scarecrow2"
}

GLOBAL.PREFAB_SKINS.wiltonmod_staff1 =
{
	"wiltonmod_staff1_skin"
}

GLOBAL.PREFAB_SKINS.wiltonmod_staff2 =
{
	"wiltonmod_staff2_skin"
}

GLOBAL.PREFAB_SKINS.wiltonmod_staff3 =
{
	"wiltonmod_staff3_skin"
}

GLOBAL.PREFAB_SKINS_IDS = {}
for prefab,skins in pairs(GLOBAL.PREFAB_SKINS) do
	GLOBAL.PREFAB_SKINS_IDS[prefab] = {}
	for k,v in pairs(skins) do
		GLOBAL.PREFAB_SKINS_IDS[prefab][v] = k
	end
end

--- 重新声明 `wiltonmod_boneheart` 与 `wiltonmod_shoot` 配方，并开启 skinnable 标记。
-- 第一段配方声明用于基础合成，本段与 item_skin_api.lua 协同，为其附加皮肤选择功能。
Recipe("wiltonmod_boneheart", {Ingredient("boneshard", 2), Ingredient(CHARACTER_INGREDIENT.HEALTH, 40)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "wiltonmod",
"images/inventoryimages/wiltonmod_boneheart.xml", 
"wiltonmod_boneheart.tex")

AllRecipes["wiltonmod_boneheart"].skinnable = true

Recipe("wiltonmod_shoot", {Ingredient("boneshard", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 5, "wiltonmod",
"images/inventoryimages/wiltonmod_shoot.xml", 
"wiltonmod_shoot.tex")

AllRecipes["wiltonmod_shoot"].skinnable = true

AllRecipes["wiltonmod_sharpbone"].skinnable = true

AllRecipes["wiltonmod_bonehammer"].skinnable = true

AllRecipes["wiltonmod_staff1"].skinnable = true

AllRecipes["wiltonmod_staff2"].skinnable = true

AllRecipes["wiltonmod_staff3"].skinnable = true

AllRecipes["skeleton"].skinnable = true

