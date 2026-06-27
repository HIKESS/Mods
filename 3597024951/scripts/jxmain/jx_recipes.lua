local G = GLOBAL

local require = G.require
require("recipe")

local TECH = G.TECH
local Ingredient = G.Ingredient
local CRAFTING_FILTERS = G.CRAFTING_FILTERS
local TUNING = G.TUNING
local Enable_Car = TUNING.JX_TUNING.jx_car_disable ~= true
local Enable_Sort = TUNING.JX_TUNING.jx_recipes_sort == true
local Enable_Island = TUNING.JX_TUNING.jx_island_switch == true

local _cactus_meat =            Enable_Island and "needlespear" or "cactus_meat"         --仙人掌尖刺-仙人掌肉
local _marble =                 Enable_Island and "limestonenugget" or "marble"          --石灰岩-大理石
local _coontail =               Enable_Island and "pierrot_fish" or "coontail"           --小丑鱼-猫尾
local _bearger_fur =            Enable_Island and "shark_gills" or "bearger_fur"         --鲨鱼腮-熊皮
local _beefalowool =            Enable_Island and "palmleaf" or "beefalowool"            --椰树叶-牛毛
local _manrabbit_tail =         Enable_Island and "crab" or "manrabbit_tail"             --兔蟹-兔毛
local _goose_feather =          Enable_Island and "doydoyfeather" or "goose_feather"     --渡渡鸟羽毛-麋鹿鹅羽毛
local _deerclops_eyeball =      Enable_Island and "tigereye" or "deerclops_eyeball"      --虎鲨之眼-巨鹿眼球
local _tentaclespots =          Enable_Island and "snakeskin" or "tentaclespots"         --蛇皮-触手皮
local _lightninggoathorn =      Enable_Island and "ox_horn" or "lightninggoathorn"       --水牛角-伏特羊角
local _wormlight =              Enable_Island and "rainbowjellyfish_dead" or "wormlight" --死彩虹水母-发光浆果
local _lightbulb =              Enable_Island and "bioluminescence" or "lightbulb"       --荧光生物-荧光果
local _dragon_scales =          Enable_Island and "dragoonheart" or "dragon_scales"      --龙心-龙鳞
local _slurper_pelt =           Enable_Island and "snakeskin" or "slurper_pelt"          --蛇皮-啜食者皮
local _slurtle_shellpieces =    Enable_Island and "coral" or "slurtle_shellpieces"       --珊瑚-外壳碎片
local _waterballoon =           Enable_Island and "hail_ice" or "waterballoon"           --冰雹-水球
local _dreadstone =             Enable_Island and "obsidian" or "dreadstone"             --黑曜石-绝望石
local _batbat =                 Enable_Island and "cutlass" or "batbat"                  --剑鱼短剑-蝙蝠棒
local _batwing =                Enable_Island and "petals_evil" or "batwing"             --深色花瓣-蝙蝠翅膀
local _succulent_picked =       Enable_Island and "petals" or "succulent_picked"         --花瓣-多肉植物
local _oceanfish_medium_8_inv = Enable_Island and "bluegem" or "oceanfish_medium_8_inv"  --蓝宝石-冰鲷鱼
local _lantern =                Enable_Island and "bottlelantern" or "lantern"           --水瓶提灯-提灯
local _saltrock =               Enable_Island and "coral" or "saltrock"                  --珊瑚-盐晶
local _rainhat =                Enable_Island and "snakeskinhat" or "rainhat"            --蛇皮帽-雨帽
local _raincoat =               Enable_Island and "armor_snakeskin" or "raincoat"        --蛇皮夹克-雨衣

local function Sort(recipe_name, recipe_reference, filter, after)
  if not Enable_Sort then return end
  local recipes = CRAFTING_FILTERS[filter].recipes
  local recipe_name_index
  local recipe_reference_index
  for i = #recipes, 1, -1 do
    if recipes[i] == recipe_name then
      recipe_name_index = i
    elseif recipes[i] == recipe_reference then
      recipe_reference_index = i + (after and 1 or 0)
    end
    if recipe_name_index and recipe_reference_index then
      if recipe_name_index >= recipe_reference_index then
        table.remove(recipes, recipe_name_index)
        table.insert(recipes, recipe_reference_index, recipe_name)
      else
        table.insert(recipes, recipe_reference_index, recipe_name)
        table.remove(recipes, recipe_name_index)
      end
      break
    end
  end
end


AddRecipeFilter({name = "JXTAB", atlas = "images/jx_tab.xml", image = "jx_tab.tex"}, 23)
if Enable_Car then
  AddRecipeFilter({name = "JXCARTAB", atlas = "images/jx_car_tab.xml", image = "jx_car_tab.tex"}, 24)
end

-- 女仆雕塑
AddRecipe2("chesspiece_jx_builder",
    {
        Ingredient(G.TECH_INGREDIENT.SCULPTING, 2),
        Ingredient("rocks", 2),
    },
    TECH.SCULPTING_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image="chesspiece_jx.tex",
        nounlock = true,
        actionstr = "SCULPTING",
    }
)

-- 景熹家居指南书
AddRecipe2("jx_wiki_book",
    {
        Ingredient("papyrus", 2),
        Ingredient("featherpencil", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_wiki_book.tex",
    },
    {"JXTAB"}
)

-- 巴西木盆栽
AddRecipe2("jx_potted",
    {
        Ingredient("petals", 1),
        Ingredient("log", 2),
        Ingredient("twigs", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted.tex",
        placer = "jx_potted_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 竹篮向日葵盆栽
AddRecipe2("jx_potted_sunflower",
    {
        Ingredient("petals", 3),
        Ingredient("twigs", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_sunflower.tex",
        placer = "jx_potted_sunflower_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 樱花酢浆草盆栽
AddRecipe2("jx_potted_cherry",
    {
        Ingredient("petals", 2),
        Ingredient("log", 1),
        Ingredient("twigs", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_cherry.tex",
        placer = "jx_potted_cherry_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 纯真花语盆栽
AddRecipe2("jx_potted_rose",
    {
        Ingredient("petals", 2),
        Ingredient("twigs", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_rose.tex",
        placer = "jx_potted_rose_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 经典仙人球盆栽
AddRecipe2("jx_potted_cactus",
    {
        Ingredient(_cactus_meat, 1),
        Ingredient("petals", 1),
        Ingredient("twigs", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_cactus.tex",
        placer = "jx_potted_cactus_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 哥伦比亚红掌盆栽
AddRecipe2("jx_potted_anthurium",
    {
        Ingredient("petals", 4),
        Ingredient("cutstone", 1),
        Ingredient("twigs", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_anthurium.tex",
        placer = "jx_potted_anthurium_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 欧式虎皮兰盆栽
AddRecipe2("jx_potted_snakeplant",
    {
        Ingredient("petals", 6),
        Ingredient("twigs", 1),
        Ingredient("cutstone", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_snakeplant.tex",
        placer = "jx_potted_snakeplant_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 威尔士水仙花盆栽
AddRecipe2("jx_potted_narcissus",
    {
        Ingredient("petals", 4),
        Ingredient("twigs", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_narcissus.tex",
        placer = "jx_potted_narcissus_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 栀子花盆栽
AddRecipe2("jx_potted_gardenia",
    {
        Ingredient("petals", 4),
        Ingredient("twigs", 1),
        Ingredient("cutgrass", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_gardenia.tex",
        placer = "jx_potted_gardenia_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 传统龟背竹盆栽
AddRecipe2("jx_potted_monstera",
    {
        Ingredient("petals", 3),
        Ingredient("twigs", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_monstera.tex",
        placer = "jx_potted_monstera_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 豆瓣绿盆栽
AddRecipe2("jx_green_palm",
    {
        Ingredient("petals", 3),
        Ingredient("twigs", 1),
        Ingredient("cutgrass", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_green_palm.tex",
        placer = "jx_green_palm_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 香格里拉玫瑰盆栽
AddRecipe2("jx_red_rose_potted",
    {
        Ingredient("petals", 4),
        Ingredient("twigs", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_red_rose_potted.tex",
        placer = "jx_red_rose_potted_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 卡罗拉玫瑰白瓷盆栽
AddRecipe2("jx_rose_big_potted",
    {
        Ingredient(_marble, 3),
        Ingredient("petals", 6),
        Ingredient("goldnugget", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rose_big_potted.tex",
        placer = "jx_rose_big_potted_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 欧式金边吊兰盆栽
AddRecipe2("jx_chlorophytum_comosum_potted",
    {
        Ingredient(_marble, 3),
        Ingredient("petals", 8),
        Ingredient("goldnugget", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chlorophytum_comosum_potted.tex",
        placer = "jx_chlorophytum_comosum_potted_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 香水百合盆栽
AddRecipe2("jx_perfume_potted",
    {
        Ingredient(_marble, 2),
        Ingredient("petals", 6),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_perfume_potted.tex",
        placer = "jx_perfume_potted_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 金钻绿公主盆栽
AddRecipe2("jx_princess_potted",
    {
        Ingredient(_marble, 2),
        Ingredient(_succulent_picked, 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_princess_potted.tex",
        placer = "jx_princess_potted_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 欧式浆果盆栽
AddRecipe2("jx_potted_berry",
    {
        Ingredient("dug_berrybush", 1),
        Ingredient("cutstone", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_berry.tex",
        placer = "jx_potted_berry_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 墨西哥仙人掌盆栽
AddRecipe2("jx_potted_mexico",
    {
        Ingredient(_cactus_meat, 2),
        Ingredient("cutstone", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_potted_mexico.tex",
        placer = "jx_potted_mexico_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 藤编花篮秋水仙
AddRecipe2("jx_colchicum",
    {
        Ingredient("rope", 2),
        Ingredient("petals", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_colchicum.tex",
    },
    {"JXTAB"}
)

-- 橘猫
AddRecipe2("jx_xuncat",
    {
        Ingredient(_coontail, 1),
        Ingredient("papyrus", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_xuncat.tex",
        placer = "jx_xuncat_placer",
        min_spacing = 0.9
    },
    {"JXTAB"}
)

-- 法棍面包
local jx_baguette_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_baguette",
    {
        Ingredient("berries_cooked", 1),
        Ingredient("honey", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_baguette.tex",
    },
    jx_baguette_filter
)
Sort("jx_baguette", "hambat", "WEAPONS", true)

-- 格鲁吉亚烤肉串
local jx_kebab_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_kebab",
    {
        Ingredient("meat", 1),
        Ingredient("berries", 1),
        Ingredient("twigs", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_kebab.tex",
    },
    jx_kebab_filter
)
Sort("jx_kebab", "jx_baguette", "WEAPONS", true)

-- 手工编织菜篮
local jx_basket_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_basket",
    {
        Ingredient("silk", 4),
        Ingredient("boards", 2),
        Ingredient("rope", 8),
        Ingredient("petals", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_basket.tex",
    },
    jx_basket_filter
)
Sort("jx_basket", "treasurechest", "CONTAINERS", false)

-- 向日葵草帽
local jx_hat_sunflower_filter = Enable_Sort and {"JXTAB", "CLOTHING"} or {"JXTAB"}
AddRecipe2("jx_hat_sunflower",
    {
        Ingredient("rope", 4),
        Ingredient("petals", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_sunflower.tex",
    },
    jx_hat_sunflower_filter
)
Sort("jx_hat_sunflower", "strawhat", "CLOTHING", true)

-- 墨西哥帽
local jx_hat_mexico_filter = Enable_Sort and {"JXTAB", "CLOTHING"} or {"JXTAB"}
AddRecipe2("jx_hat_mexico",
    {
        Ingredient("strawhat", 1),
        Ingredient("petals", 1),
        Ingredient("berries", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_mexico.tex",
    },
    jx_hat_mexico_filter
)
Sort("jx_hat_mexico", "jx_hat_sunflower", "CLOTHING", true)

-- 白玫瑰蕾丝礼帽
local jx_hat_white_rose_filter = Enable_Sort and {"JXTAB", "CLOTHING"} or {"JXTAB"}
AddRecipe2("jx_hat_white_rose",
    {
        Ingredient("petals", 1),
        Ingredient("rope", 1),
        Ingredient("silk", 1),
        Ingredient("pigskin", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_white_rose.tex",
    },
    jx_hat_white_rose_filter
)
Sort("jx_hat_white_rose", "jx_hat_mexico", "CLOTHING", true)

-- 黑蔷薇格纹赫本帽
local jx_hat_hepburn_filter = Enable_Sort and {"JXTAB", "CLOTHING"} or {"JXTAB"}
AddRecipe2("jx_hat_hepburn",
    {
        Ingredient("pigskin", 1),
        Ingredient("feather_crow", 2),
        Ingredient("petals_evil", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_hepburn.tex",
    },
    jx_hat_hepburn_filter
)
Sort("jx_hat_hepburn", "jx_hat_white_rose", "CLOTHING", true)

-- 煎蛋泡面帽
local jx_hat_noodles_filter = Enable_Sort and {"JXTAB", "CLOTHING"} or {"JXTAB"}
AddRecipe2("jx_hat_noodles",
    {
        Ingredient("bird_egg", 2),
        Ingredient("papyrus", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_noodles.tex",
    },
    jx_hat_noodles_filter
)
Sort("jx_hat_noodles", "jx_hat_hepburn", "CLOTHING", true)

-- 驯鹿针织绒帽
local jx_hat_reindeer_filter = Enable_Sort and {"JXTAB", "CLOTHING", "WINTER"} or {"JXTAB"}
AddRecipe2("jx_hat_reindeer",
    {
        Ingredient(_beefalowool, 12),
        Ingredient("silk", 6),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_reindeer.tex",
    },
    jx_hat_reindeer_filter
)
Sort("jx_hat_reindeer", "jx_hat_noodles", "CLOTHING", true)
Sort("jx_hat_reindeer", "beefalohat", "WINTER", false)

-- 蛙蛙雨衣
local jx_frog_raincoat_filter = Enable_Sort and {"JXTAB", "CLOTHING", "RAIN"} or {"JXTAB"}
AddRecipe2("jx_frog_raincoat",
    {
        Ingredient(_raincoat, 1),
        Ingredient(_rainhat, 1),
        Ingredient("rope", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_frog_raincoat.tex",
    },
    jx_frog_raincoat_filter
)
Sort("jx_frog_raincoat", "raincoat", "CLOTHING", true)
Sort("jx_frog_raincoat", "raincoat", "RAIN", true)

-- 洛丽塔敏敏熊便当包
local jx_pack_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_pack",
    {
        Ingredient("silk", 6),
        Ingredient(_beefalowool, 3),
        Ingredient(_bearger_fur, 1),
        Ingredient("rope", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_pack.tex",
    },
    jx_pack_filter
)
Sort("jx_pack", "icepack", "CONTAINERS", true)

-- 洛丽塔野餐兔背包
local jx_backpack_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_backpack",
    {
        Ingredient(_manrabbit_tail, 3),
        Ingredient("cutgrass", 3),
        Ingredient("twigs", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_backpack.tex",
    },
    jx_backpack_filter
)
Sort("jx_backpack", "backpack", "CONTAINERS", true)

-- 波奈特垂耳兔背包
local jx_backpack_2_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_backpack_2",
    {
        Ingredient(_manrabbit_tail, 3),
        Ingredient("cutgrass", 3),
        Ingredient("twigs", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_backpack_2.tex",
    },
    jx_backpack_2_filter
)
Sort("jx_backpack_2", "jx_backpack", "CONTAINERS", true)

-- 焦糖茶会猫背包
local jx_backpack_3_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_backpack_3",
    {
        Ingredient(_coontail, 6),
        Ingredient("beardhair", 2),
        Ingredient(_bearger_fur, 1),
        Ingredient("sewing_kit", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_backpack_3.tex",
    },
    jx_backpack_3_filter
)
Sort("jx_backpack_3", "jx_backpack_2", "CONTAINERS", true)

-- 小浣熊有有玩偶包
local jx_backpack_4_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_backpack_4",
    {
        Ingredient(_bearger_fur, 1),
        Ingredient("silk", 2),
        Ingredient("transistor", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_backpack_4.tex",
    },
    jx_backpack_4_filter
)
Sort("jx_backpack_4", "jx_backpack_3", "CONTAINERS", true)

-- 荷包蛋小鸡背包
local jx_backpack_5_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_backpack_5",
    {
        Ingredient("bird_egg", 1),
        Ingredient("cutgrass", 4),
        Ingredient("twigs", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_backpack_5.tex",
    },
    jx_backpack_5_filter
)
Sort("jx_backpack_5", "jx_backpack_4", "CONTAINERS", true)

-- 波西米亚露营帐篷
local jx_portabletent_item_filter = Enable_Sort and {"JXTAB", "STRUCTURES"} or {"JXTAB"}
AddRecipe2("jx_portabletent_item",
    {
        Ingredient("bedroll_straw", 1),
        Ingredient("rope", 4),
        Ingredient(_lantern, 1),
        Ingredient("twigs", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_portabletent_item.tex",
    },
    jx_portabletent_item_filter
)
Sort("jx_portabletent_item", "tent", "STRUCTURES", true)
Sort("jx_portabletent_item", "tent", "RESTORATION", true)

-- 野营锅具
local jx_portable_cook_pot_item_filter = Enable_Sort and {"JXTAB", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_portable_cook_pot_item",
    {
        Ingredient("goldnugget", 2),
        Ingredient("charcoal", 6),
        Ingredient("twigs", 6)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_portable_cook_pot_item.tex",
    },
    jx_portable_cook_pot_item_filter
)
Sort("jx_portable_cook_pot_item", "cookpot", "COOKING", false)

-- 狸猫陶土砂锅
local jx_portable_cook_pot_2_item_filter = Enable_Sort and {"JXTAB", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_portable_cook_pot_2_item",
    {
        Ingredient("goldnugget", 2),
        Ingredient("charcoal", 6),
        Ingredient("twigs", 6)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_portable_cook_pot_2_item.tex",
    },
    jx_portable_cook_pot_2_item_filter
)
Sort("jx_portable_cook_pot_2_item", "jx_portable_cook_pot_item", "COOKING", true)

-- 复古电视机
AddRecipe2("jx_tv",
    {
        Ingredient("transistor", 3),
        Ingredient("cutstone", 2),
        Ingredient("boards", 2),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_tv.tex",
        placer = "jx_tv_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 古典转盘电话机
local jx_phonograph_filter = Enable_Sort and {"JXTAB", "RESTORATION"} or {"JXTAB"}
AddRecipe2("jx_phonograph",
    {
        Ingredient("transistor", 1),
        Ingredient("goldnugget", 1),
        Ingredient("nightmarefuel", 1),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_phonograph.tex",
    },
    jx_phonograph_filter
)
Sort("jx_phonograph", "amulet", "RESTORATION", true)

-- 复古传统电风扇
local jx_fan_filter = Enable_Sort and {"JXTAB", "SUMMER"} or {"JXTAB"}
AddRecipe2("jx_fan",
    {
        Ingredient(_goose_feather, 3),
        Ingredient("transistor", 2),
        Ingredient("gears", 2),
        Ingredient("goldnugget", 8),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_fan.tex",
    },
    jx_fan_filter
)
Sort("jx_fan", "featherfan", "SUMMER", true)

-- 磁带录音机
local jx_tapeplayer_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_tapeplayer",
    {
        Ingredient("transistor", 1),
        Ingredient("goldnugget", 1),
        Ingredient("gears", 1),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_tapeplayer.tex",
    },
    jx_tapeplayer_filter
)
Sort("jx_tapeplayer", "phonograph", "DECOR", true)

-- 复古电冰箱
local jx_icebox_filter = Enable_Sort and {"JXTAB", "CONTAINERS", "COOKING"} or {"JXTAB"}
local jx_icebox_recipe = TUNING.JX_TUNING.jx_icebox_recipe and
{
  Ingredient("goldnugget", 2),
  Ingredient("gears", 1),
  Ingredient("cutstone", 1),
} or
{
  Ingredient("goldnugget", 2),
  Ingredient("gears", 1),
  Ingredient("transistor", 1),
  Ingredient("cutstone", 2),
}
AddRecipe2("jx_icebox",
    jx_icebox_recipe,
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_icebox.tex",
        placer = "jx_icebox_placer",
        min_spacing = 1.5
    },
    jx_icebox_filter
)
Sort("jx_icebox", "icebox", "CONTAINERS", true)
Sort("jx_icebox", "icebox", "COOKING", true)

-- 沉睡熊小冰箱
local jx_icebox_2_filter = Enable_Sort and {"JXTAB", "CONTAINERS", "COOKING"} or {"JXTAB"}
local jx_icebox_2_recipe = TUNING.JX_TUNING.jx_icebox_2_recipe and
{
  Ingredient("goldnugget", 2),
  Ingredient("gears", 1),
  Ingredient("cutstone", 1),
} or
{
  Ingredient("gears", 2),
  Ingredient("goldnugget", 6),
  Ingredient("cutstone", 3),
  Ingredient("petals", 1),
}
AddRecipe2("jx_icebox_2",
    jx_icebox_2_recipe,
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_icebox_2.tex",
        placer = "jx_icebox_2_placer",
        min_spacing = 1.5
    },
    jx_icebox_2_filter
)
Sort("jx_icebox_2", "jx_icebox", "CONTAINERS", true)
Sort("jx_icebox_2", "jx_icebox", "COOKING", true)

-- 北极熊冰柜
local jx_icebox_big_filter = Enable_Sort and {"JXTAB", "CONTAINERS", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_icebox_big",
    {
      Ingredient("gears", 3),
      Ingredient("cutstone", 2),
      Ingredient("transistor", 2),
      Ingredient("ice", 10),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_icebox_big.tex",
        placer = "jx_icebox_big_placer",
        min_spacing = 2
    },
    jx_icebox_big_filter
)
Sort("jx_icebox_big", "jx_icebox_2", "CONTAINERS", true)
Sort("jx_icebox_big", "jx_icebox_2", "COOKING", true)

-- 欧罗巴制冰机
local jx_icemaker_filter = Enable_Sort and {"JXTAB", "SUMMER"} or {"JXTAB"}
local jx_icemaker_recipe = TUNING.JX_TUNING.jx_icemaker_recipe and
{
  Ingredient("transistor", 8),
  Ingredient(_waterballoon, 2),
  Ingredient(_oceanfish_medium_8_inv, 1),
} or
{
  Ingredient("transistor", 8),
  Ingredient(_waterballoon, 2),
  Ingredient(_oceanfish_medium_8_inv, 1),
  Ingredient(_deerclops_eyeball, 1),
}
AddRecipe2("jx_icemaker",
    jx_icemaker_recipe,
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_icemaker.tex",
        placer = "jx_icemaker_placer",
        min_spacing = 1.5
    },
    jx_icemaker_filter
)
Sort("jx_icemaker", "icehat", "SUMMER", true)

-- 复古电煮锅
local jx_cookpot_filter = Enable_Sort and {"JXTAB", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_cookpot",
    {
        Ingredient("charcoal", 3),
        Ingredient("transistor", 1),
        Ingredient("cutstone", 1)
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_cookpot.tex",
        placer = "jx_cookpot_placer",
        min_spacing = 2
    },
    jx_cookpot_filter
)
Sort("jx_cookpot", "cookpot", "COOKING", true)

-- 复古橡木高压锅
local jx_cookpot_2_filter = Enable_Sort and {"JXTAB", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_cookpot_2",
    {
        Ingredient("charcoal", 4),
        Ingredient("transistor", 1),
        Ingredient("cutstone", 1)
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_cookpot_2.tex",
        placer = "jx_cookpot_2_placer",
        min_spacing = 2
    },
    jx_cookpot_2_filter
)
Sort("jx_cookpot_2", "cookpot", "COOKING", true)

-- 青铜镶边烤箱
local jx_oven_filter = Enable_Sort and {"JXTAB", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_oven",
    {
        Ingredient(_marble, 2),
        Ingredient("log", 1),
        Ingredient("transistor", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_oven.tex",
        placer = "jx_oven_placer",
        min_spacing = 1
    },
    jx_oven_filter
)
Sort("jx_oven", "jx_cookpot", "COOKING", true)

-- 复古烤面包机
local jx_toaster_filter = Enable_Sort and {"JXTAB", "WINTER", "SUMMER"} or {"JXTAB"}
AddRecipe2("jx_toaster",
    {
        Ingredient("heatrock", 2),
        Ingredient("cutstone", 2),
        Ingredient("flint", 2),
        Ingredient("bird_egg", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_toaster5.tex",
    },
    jx_toaster_filter
)
Sort("jx_toaster", "heatrock", "WINTER", true)
Sort("jx_toaster", "heatrock", "SUMMER", true)

-- 红宝石复古缝纫机
local jx_sewingmachine_filter = Enable_Sort and {"JXTAB", "CLOTHING"} or {"JXTAB"}
AddRecipe2("jx_sewingmachine",
    {
        Ingredient("boards", 2),
        Ingredient("redgem", 1),
        Ingredient("silk", 4),
        Ingredient("houndstooth", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_sewingmachine.tex",
        placer = "jx_sewingmachine_placer",
        min_spacing = 1
    },
    jx_sewingmachine_filter
)
Sort("jx_sewingmachine", "sewing_kit", "CLOTHING", true)

-- 乌尔诺斯的拆解机
local jx_disassembler_filter = Enable_Sort and {"JXTAB", "CLOTHING"} or {"JXTAB"}
AddRecipe2("jx_disassembler",
    {
        Ingredient("greengem", 2),
        Ingredient("gears", 2),
        Ingredient("goldnugget", 2),
        Ingredient("nightmarefuel", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_disassembler.tex",
        placer = "jx_disassembler_placer",
        min_spacing = 1
    },
    jx_disassembler_filter
)
Sort("jx_disassembler", "jx_sewingmachine", "CLOTHING", true)

-- 安德伍德罐头机
local jx_canner_filter = Enable_Sort and {"JXTAB", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_canner",
    {
        Ingredient("charcoal", 3),
        Ingredient("cutstone", 1),
        Ingredient("rope", 1),
        Ingredient("gears", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_canner.tex",
        placer = "jx_canner_placer",
        min_spacing = 1
    },
    jx_canner_filter
)
Sort("jx_canner", "meatrack", "COOKING", true)

-- 饮料售卖机
AddRecipe2("jx_vending_machine",
    {
        Ingredient("gears", 3),
        Ingredient("transistor", 3),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_vending_machine.tex",
        placer = "jx_vending_machine_placer",
        min_spacing = 2
    },
    {"JXTAB"}
)

-- 猫猫币提款机
AddRecipe2("jx_bankatm",
    {
        Ingredient("gears", 3),
        Ingredient("transistor", 3),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_bankatm.tex",
        placer = "jx_bankatm_placer",
        min_spacing = 2
    },
    {"JXTAB"}
)

-- 别墅门牌信箱
local jx_mailbox_filter = Enable_Sort and {"JXTAB", "STRUCTURES"} or {"JXTAB"}
AddRecipe2("jx_mailbox",
    {
        Ingredient("cutstone", 1),
        Ingredient("petals", 3),
        Ingredient("goldnugget", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_mailbox.tex",
        placer = "jx_mailbox_placer",
        min_spacing = 1.5
    },
    jx_mailbox_filter
)
Sort("jx_mailbox", "arrowsign_post", "STRUCTURES", true)

-- 普罗旺斯格纹方桌
local jx_table_3_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_table_3",
    {
        Ingredient("boards", 4),
        Ingredient("rope", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_3.tex",
        placer = "jx_table_3_placer",
        min_spacing = 1
    },
    jx_table_3_filter
)
Sort("jx_table_3", "stone_table_square", "DECOR", true)

-- 普罗旺斯格纹椅子
local jx_chair_2_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_chair_2",
    {
        Ingredient("boards", 1),
        Ingredient("rope", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chair_2.tex",
        placer = "jx_chair_2_placer",
        min_spacing = 1.5
    },
    jx_chair_2_filter
)
Sort("jx_chair_2", "jx_table_3", "DECOR", true)

-- 古堡回廊展示桌
local jx_table_6_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_table_6",
    {
        Ingredient("goldnugget", 3),
        Ingredient("boards", 2),
        Ingredient("pigskin", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_6.tex",
        placer = "jx_table_6_placer",
        min_spacing = 1.5
    },
    jx_table_6_filter
)
Sort("jx_table_6", "trophyscale_oversizedveggies", "DECOR", true)

-- 佛罗伦萨实木餐桌
local jx_table_2_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_table_2",
    {
        Ingredient("boards", 5),
        Ingredient("petals", 1),
        Ingredient("goldnugget", 3),
        Ingredient("silk", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_2.tex",
        placer = "jx_table_2_placer",
        min_spacing = 1
    },
    jx_table_2_filter
)
Sort("jx_table_2", "jx_chair_2", "DECOR", true)

-- 佛罗伦萨小皮凳
local jx_chair_1_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_chair_1",
    {
        Ingredient("log", 3),
        Ingredient("rope", 1),
        Ingredient("goldnugget", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chair_1.tex",
        placer = "jx_chair_1_placer",
        min_spacing = 1
    },
    jx_chair_1_filter
)
Sort("jx_chair_1", "jx_table_2", "DECOR", true)

-- 布洛涅蕾丝真皮沙发
local jx_sofa_1_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_sofa_1",
    {
        Ingredient("boards", 2),
        Ingredient("pigskin", 1),
        Ingredient("silk", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_sofa_1.tex",
        placer = "jx_sofa_1_placer",
        min_spacing = 1.5
    },
    jx_sofa_1_filter
)
Sort("jx_sofa_1", "wood_chair", "DECOR", false)

-- 布洛涅蕾丝组合沙发
local jx_sofa_2_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_sofa_2",
    {
        Ingredient("boards", 2),
        Ingredient("pigskin", 1),
        Ingredient("silk", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_sofa_2.tex",
        placer = "jx_sofa_2_placer",
        min_spacing = 1.5
    },
    jx_sofa_2_filter
)
Sort("jx_sofa_2", "jx_sofa_1", "DECOR", true)

-- 布洛涅蕾丝餐桌
local jx_table_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_table",
    {
        Ingredient("boards", 2),
        Ingredient("pigskin", 1),
        Ingredient("rope", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table.tex",
        placer = "jx_table_placer",
        min_spacing = 1.5
    },
    jx_table_filter
)
Sort("jx_table", "jx_sofa_2", "DECOR", true)

-- 蔷薇红雕花真皮沙发
local jx_sofa_3_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_sofa_3",
    {
        Ingredient("pigskin", 3),
        Ingredient("rope", 2),
        Ingredient("boards", 2),
        Ingredient("silk", 3),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_sofa_3.tex",
        placer = "jx_sofa_3_placer",
        min_spacing = 1.5
    },
    jx_sofa_3_filter
)
Sort("jx_sofa_3", "jx_table", "DECOR", true)

-- 蔷薇红真皮摇椅
local jx_chair_3_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_chair_3",
    {
        Ingredient("pigskin", 3),
        Ingredient("boards", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chair_3.tex",
        placer = "jx_chair_3_placer",
        min_spacing = 1.5
    },
    jx_chair_3_filter
)
Sort("jx_chair_3", "jx_sofa_3", "DECOR", true)

-- 蔷薇红雕花餐桌
local jx_table_4_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_table_4",
    {
        Ingredient("boards", 4),
        Ingredient("rope", 4),
        Ingredient("silk", 3),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_4.tex",
        placer = "jx_table_4_placer",
        min_spacing = 1.5
    },
    jx_table_4_filter
)
Sort("jx_table_4", "jx_chair_3", "DECOR", true)

-- 复古枫叶木盒
local jx_chest_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
local jx_chest_recipe = TUNING.JX_TUNING.jx_chest_recipe and
{
  Ingredient("boards", 4),
  Ingredient("goldnugget", 2),
} or
{
  Ingredient("boards", 2),
  Ingredient("goldnugget", 1),
}
AddRecipe2("jx_chest",
    jx_chest_recipe,
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chest.tex",
        placer = "jx_chest_placer",
        min_spacing = 1
    },
    jx_chest_filter
)
Sort("jx_chest", "treasurechest", "CONTAINERS", true)

-- 祖母绿宝石箱
local jx_chest_2_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
local jx_chest_2_recipe = TUNING.JX_TUNING.jx_chest_2_recipe and
{
  Ingredient("boards", 4),
  Ingredient("goldnugget", 2),
} or
{
  Ingredient("boards", 2),
  Ingredient("goldnugget", 1),
}
AddRecipe2("jx_chest_2",
    jx_chest_2_recipe,
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chest_2.tex",
        placer = "jx_chest_2_placer",
        min_spacing = 1
    },
    jx_chest_2_filter
)
Sort("jx_chest_2", "jx_chest", "CONTAINERS", true)

-- 温莎古典无窗餐柜
local jx_bookcase_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_bookcase",
    {
        Ingredient("boards", 6),
        Ingredient("rope", 3),
        Ingredient("redgem", 1),
        Ingredient("goldnugget", 6),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_bookcase.tex",
        placer = "jx_bookcase_placer",
        min_spacing = 1
    },
    jx_bookcase_filter
)
Sort("jx_bookcase", "jx_table_6", "DECOR", true)

-- 洛可可雕花玻璃柜
local jx_cabinet_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_cabinet",
    {
        Ingredient("boards", 6),
        Ingredient("goldnugget", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_cabinet.tex",
        placer = "jx_cabinet_placer",
        min_spacing = 1
    },
    jx_cabinet_filter
)
Sort("jx_cabinet", "jx_bookcase", "DECOR", true)

-- 欧式实木梳妆台
local jx_table_5_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_table_5",
    {
        Ingredient("redgem", 1),
        Ingredient("boards", 4),
        Ingredient("rope", 2),
        Ingredient(_beefalowool, 3),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_5.tex",
        placer = "jx_table_5_placer",
        min_spacing = 1
    },
    jx_table_5_filter
)
Sort("jx_table_5", "wardrobe", "DECOR", true)

-- 黑金燕尾服人台
local jx_dress_form_m_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_dress_form_m",
    {
        Ingredient(_beefalowool, 3),
        Ingredient("goldnugget", 2),
        Ingredient("silk", 2),
        Ingredient("boards", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_dress_form_m.tex",
        placer = "jx_dress_form_m_placer",
        min_spacing = 1
    },
    jx_dress_form_m_filter
)
Sort("jx_dress_form_m", "beefalo_groomer", "DECOR", true)

-- 哥特洛丽塔人台
local jx_dress_form_w_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_dress_form_w",
    {
        Ingredient(_beefalowool, 1),
        Ingredient("goldnugget", 2),
        Ingredient("silk", 4),
        Ingredient("boards", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_dress_form_w.tex",
        placer = "jx_dress_form_w_placer",
        min_spacing = 1
    },
    jx_dress_form_w_filter
)
Sort("jx_dress_form_w", "jx_dress_form_m", "DECOR", true)

-- 蔷薇镶边大衣柜
local jx_wardrobe_filter = Enable_Sort and {"JXTAB", "DECOR", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_wardrobe",
    {
        Ingredient("boards", 6),
        Ingredient("goldnugget", 3),
        Ingredient("cutgrass", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_wardrobe.tex",
        placer = "jx_wardrobe_placer",
        min_spacing = 1
    },
    jx_wardrobe_filter
)
Sort("jx_wardrobe", "wardrobe", "DECOR", true)
Sort("jx_wardrobe", "fish_box", "CONTAINERS", true)

-- 洛可可海缸柜
local jx_fish_tank_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_fish_tank",
    {
        Ingredient("goldnugget", 5),
        Ingredient("boards", 6),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_fish_tank.tex",
        placer = "jx_fish_tank_placer",
        min_spacing = 1
    },
    jx_fish_tank_filter
)
Sort("jx_fish_tank", "fish_box", "CONTAINERS", true)

-- 巴洛克圆顶床
local jx_tent_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "RESTORATION"} or {"JXTAB"}
AddRecipe2("jx_tent",
    {
        Ingredient("silk", 4),
        Ingredient("twigs", 2),
        Ingredient("rope", 3)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_tent.tex",
        placer = "jx_tent_placer",
        -- min_spacing = 1
    },
    jx_tent_filter
)
Sort("jx_tent", "tent", "STRUCTURES", true)
Sort("jx_tent", "tent", "RESTORATION", true)

-- 波西米亚编织吊床
local jx_hanging_bed_filter = Enable_Sort and {"JXTAB", "STRUCTURES"} or {"JXTAB"}
AddRecipe2("jx_hanging_bed",
    {
        Ingredient("log", 4),
        Ingredient("rope", 4),
        Ingredient("silk", 6),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hanging_bed.tex",
        placer = "jx_hanging_bed_placer",
        min_spacing = 2
    },
    jx_hanging_bed_filter
)
Sort("jx_hanging_bed", "jx_portabletent_item", "STRUCTURES", true)

-- 复古橡木腌制桶
local jx_pickling_barrel_filter = Enable_Sort and {"JXTAB", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_pickling_barrel",
    {
        Ingredient("boards", 6),
        Ingredient("goldnugget", 1),
        Ingredient(_saltrock, 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_pickling_barrel.tex",
        placer = "jx_pickling_barrel_placer",
        min_spacing = 1
    },
    jx_pickling_barrel_filter
)
Sort("jx_pickling_barrel", "jx_canner", "COOKING", false)

-- 切斯特狗屋
AddRecipe2("jx_chester_house",
    {
        Ingredient("houndstooth", 1),
        Ingredient("boards", 2),
        Ingredient("cutstone", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chester_house.tex",
        placer = "jx_chester_house_placer",
        min_spacing = 2
    },
    {"JXTAB"}
)

-- 格鲁姆的树屋
AddRecipe2("jx_glommer_house",
    {
        Ingredient("petals", 2),
        Ingredient("pinecone", 1),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_glommer_house.tex",
        placer = "jx_glommer_house_placer",
        min_spacing = 2
    },
    {"JXTAB"}
)

-- 橡木猫爬架
AddRecipe2("jx_cat_tree",
    {
        Ingredient("boards", 2),
        Ingredient("rope", 3),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_cat_tree.tex",
        placer = "jx_cat_tree_placer",
        min_spacing = 2
    },
    {"JXTAB"}
)

-- 巴洛克鎏金浴缸
local jx_bathtub_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "RESTORATION"} or {"JXTAB"}
AddRecipe2("jx_bathtub",
    {
        Ingredient(_marble, 3),
        Ingredient("cutstone", 2),
        Ingredient("goldnugget", 8),
        Ingredient(_tentaclespots, 3),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_bathtub.tex",
        placer = "jx_bathtub_placer",
        min_spacing = 1
    },
    jx_bathtub_filter
)
Sort("jx_bathtub", "jx_tent", "STRUCTURES", true)
Sort("jx_bathtub", "jx_tent", "RESTORATION", true)

-- 巴洛克鎏金立柱洗手池
AddRecipe2("jx_table_7",
    {
        Ingredient(_marble, 8),
        Ingredient("goldnugget", 8),
        Ingredient("wateringcan", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_7.tex",
        placer = "jx_table_7_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 巴洛克鎏金马桶
AddRecipe2("jx_chair_4",
    {
        Ingredient(_marble, 1),
        Ingredient("goldnugget", 5),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_chair_4.tex",
        placer = "jx_chair_4_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 经典红色马桶吸
local jx_toilet_suction_filter = Enable_Sort and {"JXTAB", "TOOLS"} or {"JXTAB"}
AddRecipe2("jx_toilet_suction",
    {
        Ingredient("flint", 2),
        Ingredient("pigskin", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_toilet_suction.tex",
    },
    jx_toilet_suction_filter
)
Sort("jx_toilet_suction", "reskin_tool", "TOOLS", false)

-- 经典镶边洗衣机
AddRecipe2("jx_washer",
    {
        --Ingredient("yellowgem", 1),
        Ingredient("goldnugget", 8),
        Ingredient(_marble, 2),
        Ingredient("transistor", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_washer.tex",
        placer = "jx_washer_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 皇家贝希斯三角钢琴
local jx_piano_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_piano",
    {
        Ingredient("gears", 3),
        Ingredient("boards", 6),
        Ingredient("onemanband", 1)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_piano.tex",
        placer = "jx_piano_placer",
        min_spacing = 4
    },
    jx_piano_filter
)
Sort("jx_piano", "endtable", "DECOR", true)

-- 复古金管萨克斯
AddRecipe2("jx_saxophone",
    {
        Ingredient("boards", 1),
        Ingredient("goldnugget", 4),
        Ingredient("flint", 1)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_saxophone.tex",
        placer = "jx_saxophone_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 宫廷幽弦大提琴
AddRecipe2("jx_cello",
    {
        Ingredient("boards", 4),
        Ingredient("goldnugget", 2),
        Ingredient("silk", 5)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_cello.tex",
        placer = "jx_cello_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 贵族古典竖琴
AddRecipe2("jx_harp",
    {
        Ingredient("boards", 4),
        Ingredient("goldnugget", 2),
        Ingredient("silk", 5)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_harp.tex",
        placer = "jx_harp_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 停止走动的座钟
AddRecipe2("jx_mantel_clock",
    {
        Ingredient("goldnugget", 2),
        Ingredient(_marble, 3),
        Ingredient("rope", 2)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_mantel_clock.tex",
        placer = "jx_mantel_clock_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 卷纹柱饰石砌壁炉
local jx_table_8_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_table_8",
    {
        Ingredient("cutstone", 6),
        Ingredient("petals", 2),
        Ingredient("papyrus", 1),
        Ingredient("goldnugget", 6),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_8.tex",
        placer = "jx_table_8_placer",
        min_spacing = 2.5
    },
    jx_table_8_filter
)
Sort("jx_table_8", "firepit", "LIGHT", true)

-- 雕花三臂欧式烛台
local jx_lamp_2_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_lamp_2",
    {
        Ingredient("goldnugget", 8),
        Ingredient("nightmarefuel", 2),
        Ingredient(_lightninggoathorn, 1),
        Ingredient(_wormlight, 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_lamp_2.tex",
    },
    jx_lamp_2_filter
)
Sort("jx_lamp_2", "nightstick", "LIGHT", true)

-- 复古缀饰床头灯
local jx_lamp_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_lamp",
    {
        Ingredient(_lightbulb, 1),
        Ingredient("twigs", 2),
        Ingredient("transistor", 1),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_lamp.tex",
    },
    jx_lamp_filter
)
Sort("jx_lamp", "decor_lamp", "DECOR", true)

-- 哥特式宫廷道路灯
local jx_mushroom_light_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_mushroom_light",
    {
        Ingredient("boards", 1),
        Ingredient("cutstone", 2),
        Ingredient("transistor", 1),
        Ingredient(_lightbulb, 8),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_mushroom_light.tex",
        placer = "jx_mushroom_light_placer",
        min_spacing = 1
    },
    jx_mushroom_light_filter
)
Sort("jx_mushroom_light", "mushroom_light2", "LIGHT", true)

-- 蔷薇红实木室内灯
local jx_mushroom_light_2_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_mushroom_light_2",
    {
        Ingredient("boards", 2),
        Ingredient("cutstone", 2),
        Ingredient("transistor", 2),
        Ingredient(_lightbulb, 8),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_mushroom_light_2.tex",
        placer = "jx_mushroom_light_2_placer",
        min_spacing = 1
    },
    jx_mushroom_light_2_filter
)
Sort("jx_mushroom_light_2", "jx_mushroom_light", "LIGHT", true)

-- 诺伊堡绿色煤油暖炉
local jx_furnace_filter = Enable_Sort and {"JXTAB", "LIGHT", "COOKING"} or {"JXTAB"}
AddRecipe2("jx_furnace",
    {
        Ingredient("charcoal", 8),
        Ingredient("goldnugget", 8),
        Ingredient("rope", 3),
        Ingredient(_dragon_scales, 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_furnace.tex",
        placer = "jx_furnace_placer",
        min_spacing = 1
    },
    jx_furnace_filter
)
Sort("jx_furnace", "dragonflyfurnace", "LIGHT", true)
Sort("jx_furnace", "dragonflyfurnace", "COOKING", true)

-- 欧式铸铁炭炉
local jx_charcoal_stove_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_charcoal_stove",
    {
        Ingredient("cutstone", 2),
        Ingredient("goldnugget", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_charcoal_stove.tex",
        placer = "jx_charcoal_stove_placer",
        min_spacing = 1
    },
    jx_charcoal_stove_filter
)
Sort("jx_charcoal_stove", "fish_box", "CONTAINERS", true)

-- 女仆的蕾丝地毯包
local jx_rug_bag_filter = Enable_Sort and {"JXTAB", "DECOR", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_rug_bag",
    {
        Ingredient(_slurper_pelt, 2),
        Ingredient("silk", 8),
        Ingredient(_dragon_scales, 1),
        Ingredient(_beefalowool, 8),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_bag.tex",
    },
    jx_rug_bag_filter
)
Sort("jx_rug_bag", "turf_road", "DECOR", false)
Sort("jx_rug_bag", "jx_basket", "CONTAINERS", true)

-- 维也纳丝绒椭圆毯
local jx_rug_oval_item_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_rug_oval_item",
    {
        Ingredient(_beefalowool, 2),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_oval_item.tex",
    },
    jx_rug_oval_item_filter
)
Sort("jx_rug_oval_item", "sewing_mannequin", "DECOR", true)

-- 森林之歌方形布毯
local jx_rug_forest_item_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_rug_forest_item",
    {
        Ingredient(_beefalowool, 2),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_forest_item.tex",
    },
    jx_rug_forest_item_filter
)
Sort("jx_rug_forest_item", "jx_rug_oval_item", "DECOR", true)

-- 奥布松丝绸挂毯
local jx_rug_aubusson_item_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_rug_aubusson_item",
    {
        Ingredient("silk", 1),
        Ingredient(_beefalowool, 1),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_aubusson_item.tex",
    },
    jx_rug_aubusson_item_filter
)
Sort("jx_rug_aubusson_item", "jx_rug_forest_item", "DECOR", true)

-- 传统平织方格地毯
local jx_rug_tradition_item_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_rug_tradition_item",
    {
        Ingredient(_beefalowool, 2),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_tradition_item.tex",
    },
    jx_rug_tradition_item_filter
)
Sort("jx_rug_tradition_item", "jx_rug_aubusson_item", "DECOR", true)

-- 萨瓦纳瑞手工地毯
local jx_rug_savannah_item_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_rug_savannah_item",
    {
        Ingredient(_beefalowool, 3),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_savannah_item.tex",
    },
    jx_rug_savannah_item_filter
)
Sort("jx_rug_savannah_item", "jx_rug_tradition_item", "DECOR", true)

-- 印第安图腾三角毯
local jx_rug_triangle_item_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_rug_triangle_item",
    {
        Ingredient(_beefalowool, 2),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_triangle_item.tex",
    },
    jx_rug_triangle_item_filter
)
Sort("jx_rug_triangle_item", "jx_rug_savannah_item", "DECOR", true)

-- 普拉托尼正圆地毯
local jx_rug_platoni_item_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_rug_platoni_item",
    {
        Ingredient(_beefalowool, 2),
        Ingredient("silk", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rug_platoni_item.tex",
    },
    jx_rug_platoni_item_filter
)
Sort("jx_rug_platoni_item", "jx_rug_triangle_item", "DECOR", true)

-- 花岗岩拼花瓷砖
local turf_granite_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("turf_granite",
    {
        Ingredient(_beefalowool, 3),
        Ingredient("boards", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "turf_granite.tex",
        numtogive = 6
    },
    turf_granite_filter
)
Sort("turf_granite", "turf_carpetfloor2", "DECOR", true)

-- 复古几何纹红棕地毯
local turf_reddish_brown_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("turf_reddish_brown",
    {
        Ingredient(_beefalowool, 1),
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "turf_reddish_brown.tex",
        numtogive = 6
    },
    turf_reddish_brown_filter
)
Sort("turf_reddish_brown", "turf_granite", "DECOR", true)

-- 棕韵织章回廊地毯
local turf_corridor_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("turf_corridor",
    {
        Ingredient(_beefalowool, 2),
        Ingredient("goldnugget", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "turf_corridor.tex",
        numtogive = 6
    },
    turf_corridor_filter
)
Sort("turf_corridor", "turf_reddish_brown", "DECOR", true)

-- 复古棋盘浴室瓷砖
local turf_bath_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("turf_bath",
    {
        Ingredient(_marble, 1),
        Ingredient("flint", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "turf_bath.tex",
        numtogive = 6
    },
    turf_bath_filter
)
Sort("turf_bath", "turf_corridor", "DECOR", true)

-- 宫廷实木地板
local turf_jx_wood_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("turf_jx_wood",
    {
        Ingredient("boards", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "turf_jx_wood.tex",
        numtogive = 6
    },
    turf_jx_wood_filter
)
Sort("turf_jx_wood", "turf_bath", "DECOR", true)

-- 庭院步道方砖
local turf_jx_courtyard_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("turf_jx_courtyard",
    {
        Ingredient("cutstone", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "turf_jx_courtyard.tex",
        numtogive = 6
    },
    turf_jx_courtyard_filter
)
Sort("turf_jx_courtyard", "turf_jx_wood", "DECOR", true)

-- 古典纹章顶饰石墙
local wall_jx_stone_item_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "DECOR"} or {"JXTAB"}
AddRecipe2("wall_jx_stone_item",
    {
        Ingredient("cutstone", 1),
        Ingredient("flint", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "wall_jx_stone_item.tex",
        numtogive = 8,
    },
    wall_jx_stone_item_filter
)
Sort("wall_jx_stone_item", "wall_stone_item", "STRUCTURES", true)
Sort("wall_jx_stone_item", "wall_stone_item", "DECOR", true)

-- 古典罗马柱栏杆
local jx_fence_item_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_fence_item",
    {
        Ingredient("cutstone", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_fence.tex",
        numtogive = 6,
    },
    jx_fence_item_filter
)
Sort("jx_fence_item", "fence_item", "STRUCTURES", true)
Sort("jx_fence_item", "fence_item", "DECOR", true)

-- 爱奥尼花束圆柱
local wall_jx_stone_2_item_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "DECOR"} or {"JXTAB"}
AddRecipe2("wall_jx_stone_2_item",
    {
        Ingredient("cutstone", 2),
        Ingredient("petals", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "wall_jx_stone_2_item.tex",
        numtogive = 8,
    },
    wall_jx_stone_2_item_filter
)
Sort("wall_jx_stone_2_item", "wall_jx_stone_item", "STRUCTURES", true)
Sort("wall_jx_stone_2_item", "wall_jx_stone_item", "DECOR", true)

-- 爱奥尼双柱栅栏
local jx_fence_2_item_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_fence_2_item",
    {
        Ingredient("cutstone", 1),
        Ingredient("petals", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_fence_2.tex",
        numtogive = 6,
    },
    jx_fence_2_item_filter
)
Sort("jx_fence_2_item", "jx_fence_item", "STRUCTURES", true)
Sort("jx_fence_2_item", "jx_fence_item", "DECOR", true)

-- 古堡哥特式石墙
local wall_jx_stone_3_item_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "DECOR"} or {"JXTAB"}
AddRecipe2("wall_jx_stone_3_item",
    {
        Ingredient("cutstone", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "wall_jx_stone_3_item.tex",
        numtogive = 8,
    },
    wall_jx_stone_3_item_filter
)
Sort("wall_jx_stone_3_item", "wall_jx_stone_2_item", "STRUCTURES", true)
Sort("wall_jx_stone_3_item", "wall_jx_stone_2_item", "DECOR", true)

-- 庄园常青树篱
local wall_jx_straw_1_item_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "DECOR"} or {"JXTAB"}
AddRecipe2("wall_jx_straw_1_item",
    {
        Ingredient("cutgrass", 8),
        Ingredient("nitre", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "wall_jx_straw_1_item.tex",
        numtogive = 8,
    },
    wall_jx_straw_1_item_filter
)
Sort("wall_jx_straw_1_item", "wall_jx_stone_3_item", "STRUCTURES", true)
Sort("wall_jx_straw_1_item", "wall_jx_stone_3_item", "DECOR", true)

-- 维利安庄园喷泉
local jx_fountain_filter = Enable_Sort and {"JXTAB", "DECOR"} or {"JXTAB"}
AddRecipe2("jx_fountain",
    {
        Ingredient("cutstone", 10),
        Ingredient("bluegem", 1),
        Ingredient(_slurtle_shellpieces, 6),
        Ingredient("goldnugget", 10),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_fountain.tex",
        placer = "jx_fountain_placer",
        min_spacing = 1
    },
    jx_fountain_filter
)
Sort("jx_fountain", "decor_portraitframe", "DECOR", true)

-- 庄园贵族纹水井
local jx_well_filter = Enable_Sort and {"JXTAB", "GARDENING"} or {"JXTAB"}
AddRecipe2("jx_well",
    {
        Ingredient("cutstone", 8),
        Ingredient("boards", 6),
        Ingredient("goldnugget", 8),
        Ingredient("rope", 6),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_well.tex",
        placer = "jx_well_placer",
        min_spacing = 1
    },
    jx_well_filter
)
Sort("jx_well", "compostingbin", "GARDENING", true)

-- 乡村农具架
local jx_farm_tools_container_filter = Enable_Sort and {"JXTAB", "GARDENING", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_farm_tools_container",
    {
        Ingredient("log", 8),
        Ingredient("rope", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_farm_tools_container.tex",
        placer = "jx_farm_tools_container_placer",
        min_spacing = 1
    },
    jx_farm_tools_container_filter
)
Sort("jx_farm_tools_container", "farm_hoe", "GARDENING", false)
Sort("jx_farm_tools_container", "jx_wardrobe", "CONTAINERS", true)

-- 宫廷风花茶壶
local jx_wateringcan_filter = Enable_Sort and {"JXTAB", "GARDENING"} or {"JXTAB"}
AddRecipe2("jx_wateringcan",
    {
        Ingredient(_marble, 1),
        Ingredient("petals", 1),
        Ingredient("rope", 1),
        Ingredient("flint", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_wateringcan.tex",
    },
    jx_wateringcan_filter
)
Sort("jx_wateringcan", "premiumwateringcan", "GARDENING", true)

-- 恩利尔的战锄
local jx_war_hoe_filter = Enable_Sort and {"JXTAB", "GARDENING"} or {"JXTAB"}
AddRecipe2("jx_war_hoe",
    {
        Ingredient("goldnugget", 2),
        Ingredient(_marble, 2),
        Ingredient("log", 1),
        Ingredient("rope", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_war_hoe.tex",
    },
    jx_war_hoe_filter
)
Sort("jx_war_hoe", "golden_farm_hoe", "GARDENING", true)

-- 复古亚历山大地窖
local jx_cellar_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_cellar",
    {
        Ingredient("cutstone", 12),
        Ingredient("goldnugget", 12),
        Ingredient("boards", 12),
        Ingredient(_saltrock, 12),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_cellar.tex",
        placer = "jx_cellar_placer",
        min_spacing = 3
    },
    jx_cellar_filter
)
Sort("jx_cellar", "saltbox", "CONTAINERS", true)

-- 庄园琥珀蜜箱
local jx_honey_box_filter = Enable_Sort and {"JXTAB", "CONTAINERS", "GARDENING"} or {"JXTAB"}
AddRecipe2("jx_honey_box",
    {
        Ingredient("cutstone", 5),
        Ingredient("boards", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_honey_box.tex",
        placer = "jx_honey_box_placer",
        min_spacing = 1.5
    },
    jx_honey_box_filter
)
Sort("jx_honey_box", "jx_cellar", "CONTAINERS", true)
Sort("jx_honey_box", "beebox", "GARDENING", true)

-- 田园藤编收纳筐
local jx_storage_basket_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_storage_basket",
    {
        Ingredient("rope", 6),
        Ingredient("petals", 2),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_storage_basket.tex",
        placer = "jx_storage_basket_placer",
        min_spacing = 1.5
    },
    jx_storage_basket_filter
)
Sort("jx_storage_basket", "treasurechest", "CONTAINERS", false)

-- 田园干草车
local jx_hay_cart_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_hay_cart",
    {
        Ingredient("boards", 6),
        Ingredient("rope", 3),
        Ingredient("flint", 4),
        Ingredient("goldnugget", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hay_cart.tex",
        placer = "jx_hay_cart_placer",
        min_spacing = 1
    },
    jx_hay_cart_filter
)
Sort("jx_hay_cart", "dragonflychest", "CONTAINERS", true)

-- 庄园手推车
local jx_handcart_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_handcart",
    {
        Ingredient("boards", 8),
        Ingredient("rope", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_handcart.tex",
        placer = "jx_handcart_placer",
        min_spacing = 1
    },
    jx_handcart_filter
)
Sort("jx_handcart", "jx_hay_cart", "CONTAINERS", true)

-- 庄园木柴箱
local jx_wood_bin_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_wood_bin",
    {
        Ingredient("boards", 6),
        Ingredient("rope", 3),
        Ingredient("goldnugget", 4),
        Ingredient("cutstone", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_wood_bin.tex",
        placer = "jx_wood_bin_placer",
        min_spacing = 1
    },
    jx_wood_bin_filter
)
Sort("jx_wood_bin", "jx_handcart", "CONTAINERS", true)

-- 庄园石料箱
local jx_rock_bin_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_rock_bin",
    {
        Ingredient("cutstone", 8),
        Ingredient("boards", 5),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_rock_bin.tex",
        placer = "jx_rock_bin_placer",
        min_spacing = 1
    },
    jx_rock_bin_filter
)
Sort("jx_rock_bin", "jx_wood_bin", "CONTAINERS", true)

-- 复古室外消防栓
local jx_fireplug_filter = Enable_Sort and {"JXTAB", "STRUCTURES", "SUMMER"} or {"JXTAB"}
AddRecipe2("jx_fireplug",
    {
        Ingredient(_marble, 3),
        Ingredient(_waterballoon, 2),
        Ingredient("wateringcan", 1)
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_fireplug.tex",
        placer = "jx_fireplug_placer",
        min_spacing = 1
    },
    jx_fireplug_filter
)
Sort("jx_fireplug", "firesuppressor", "STRUCTURES", true)
Sort("jx_fireplug", "firesuppressor", "SUMMER", true)

-- 法式铸铁平底锅
local jx_pan_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_pan",
    {
        Ingredient("flint", 3),
        Ingredient("twigs", 1),
    },
    TECH.NONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_pan.tex",
    },
    jx_pan_filter
)
Sort("jx_pan", "spear", "WEAPONS", false)

-- 老式深厚的铁锅
local jx_hat_iron_pan_filter = Enable_Sort and {"JXTAB", "ARMOUR"} or {"JXTAB"}
AddRecipe2("jx_hat_iron_pan",
    {
        Ingredient("cutstone", 1),
        Ingredient("log", 2),
    },
    TECH.NONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_iron_pan.tex",
    },
    jx_hat_iron_pan_filter
)
Sort("jx_hat_iron_pan", "footballhat", "ARMOUR", false)

-- 复古蓝宝石西餐刀
local jx_weapon_2_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_weapon_2",
    {
        Ingredient("bluegem", 1),
        Ingredient("goldnugget", 5),
        Ingredient("flint", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_weapon_2.tex",
    },
    jx_weapon_2_filter
)
Sort("jx_weapon_2", "fence_rotator", "WEAPONS", false)

-- 复古红宝石西餐叉
local jx_weapon_1_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_weapon_1",
    {
        Ingredient("redgem", 1),
        Ingredient("goldnugget", 5),
        Ingredient("flint", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_weapon_1.tex",
    },
    jx_weapon_1_filter
)
Sort("jx_weapon_1", "jx_weapon_2", "WEAPONS", true)

-- 复古绿宝石西餐勺
local jx_weapon_3_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_weapon_3",
    {
        Ingredient("greengem", 1),
        Ingredient("goldnugget", 5),
        Ingredient("flint", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_weapon_3.tex",
    },
    jx_weapon_3_filter
)
Sort("jx_weapon_3", "jx_weapon_1", "WEAPONS", true)

-- 复古黄宝石锅铲
local jx_weapon_5_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_weapon_5",
    {
        Ingredient("yellowgem", 1),
        Ingredient("goldnugget", 5),
        Ingredient("flint", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_weapon_5.tex",
    },
    jx_weapon_5_filter
)
Sort("jx_weapon_5", "jx_weapon_3", "WEAPONS", true)

-- 查理夫人的葡萄酒
local jx_weapon_4_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_weapon_4",
    {
        Ingredient("purplegem", 1),
        Ingredient("ice", 5),
        Ingredient("log", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_weapon_4.tex",
    },
    jx_weapon_4_filter
)
Sort("jx_weapon_4", "jx_weapon_5", "WEAPONS", true)

-- 厨房洗碗池
AddRecipe2("jx_table_9",
    {
        Ingredient("boards", 2),
        Ingredient("cutstone", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_table_9.tex",
        placer = "jx_table_9_placer",
        min_spacing = 1
    },
    {"JXTAB"}
)

-- 垃圾桶
local jx_trash_can_filter = Enable_Sort and {"JXTAB", "CONTAINERS"} or {"JXTAB"}
AddRecipe2("jx_trash_can",
    {
        Ingredient("cutstone", 1),
        Ingredient("ash", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_trash_can.tex",
        placer = "jx_trash_can_placer",
        min_spacing = 1
    },
    jx_trash_can_filter
)
Sort("jx_trash_can", "giftwrap", "CONTAINERS", true)

--米勒的手电筒
local jx_flashlight_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_flashlight",
    {
        Ingredient("gears", 1),
        Ingredient("transistor", 2),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_flashlight.tex",
    },
    jx_flashlight_filter
)
Sort("jx_flashlight", "lantern", "LIGHT", false)

--配套电池
local jx_battery1_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_battery1",
    {
        Ingredient(_wormlight, 1),
        Ingredient("nitre", 1),
        Ingredient("charcoal", 1),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_battery1.tex",
    },
    jx_battery1_filter
)
Sort("jx_battery1", "jx_flashlight", "LIGHT", true)

-- 宝石玫瑰夜巡灯
local jx_lantern_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_lantern",
    {
        Ingredient("redgem", 1),
        Ingredient(_lightbulb, 2),
        Ingredient("petals", 2),
        Ingredient("goldnugget", 3),
    },
    TECH.SCIENCE_ONE,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_lantern.tex",
    },
    jx_lantern_filter
)
Sort("jx_lantern", "lantern", "LIGHT", true)

-- 古堡繁星提灯
local jx_lantern_2_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_lantern_2",
    {
        Ingredient("bluegem", 1),
        Ingredient("goldnugget", 1),
        Ingredient(_lightbulb, 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_lantern_2.tex",
    },
    jx_lantern_2_filter
)
Sort("jx_lantern_2", "jx_lantern", "LIGHT", true)

-- 德古拉伯爵提灯
local jx_lantern_3_filter = Enable_Sort and {"JXTAB", "LIGHT"} or {"JXTAB"}
AddRecipe2("jx_lantern_3",
    {
        Ingredient(_dreadstone, 1),
        --Ingredient("nightmarefuel", 2),
        Ingredient(_batwing, 1),
        Ingredient("feather_crow", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_lantern_3.tex",
    },
    jx_lantern_3_filter
)
Sort("jx_lantern_3", "jx_lantern_2", "LIGHT", true)

-- 齐格鲁德的圣剑
local jx_holy_sword_filter = Enable_Sort and {"JXTAB", "WEAPONS"} or {"JXTAB"}
AddRecipe2("jx_holy_sword",
    {
        Ingredient(_batbat, 1),
        Ingredient("redgem", 1),
        Ingredient(_dreadstone, 2),
        Ingredient("goldnugget", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_holy_sword.tex",
    },
    jx_holy_sword_filter
)
Sort("jx_holy_sword", "nightsword", "WEAPONS", true)

-- 齐格鲁德的战盔
local jx_hat_sigurd_filter = Enable_Sort and {"JXTAB", "ARMOUR"} or {"JXTAB"}
AddRecipe2("jx_hat_sigurd",
    {
        Ingredient("reviver", 1),
        Ingredient("redgem", 1),
        Ingredient(_dreadstone, 2),
        Ingredient("goldnugget", 4),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_sigurd.tex",
    },
    jx_hat_sigurd_filter
)
Sort("jx_hat_sigurd", "dreadstonehat", "ARMOUR", true)

----------
if Enable_Car then
-- 复古甲壳虫汽车
local jx_car_recipe = TUNING.JX_TUNING.jx_car_recipe and
{
  Ingredient("gears", 10),
  Ingredient("wagpunk_bits", 20),
  Ingredient("trinket_6", 8),
} or
{
  Ingredient("gears", 10),
  Ingredient("wagpunk_bits", 20),
  Ingredient("security_pulse_cage_full", 1),
  Ingredient("trinket_6", 8),
}
AddRecipe2("jx_car",
    jx_car_recipe,
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_car.tex",
        placer = "jx_car_placer",
        min_spacing = 7
    },
    {"JXCARTAB"}
)

-- 95号无铅汽油
AddRecipe2("jx_gasoline",
    {
        Ingredient("gelblob_bottle", 3),
        Ingredient("nitre", 10),
        Ingredient("charcoal", 10),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_gasoline.tex",
    },
    {"JXCARTAB"}
)

-- 汽车钥匙
AddRecipe2("jx_car_key",
    {
        Ingredient("goldnugget", 1),
        Ingredient("flint", 1),
        Ingredient("deer_antler2", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_car_key.tex",
    },
    {"JXCARTAB"}
)

-- 喷漆钢罐
AddRecipe2("jx_parts_colour",
    {
        Ingredient("dreadstone", 1),
        Ingredient("horrorfuel", 1),
        Ingredient("gelblob_bottle", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_parts_colour.tex",
    },
    {"JXCARTAB"}
)

-- 夜间超速
AddRecipe2("jx_parts_light",
    {
        Ingredient("trinket_6", 2),
        Ingredient("transistor", 1),
        Ingredient("moonglass_charged", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_parts_light.tex",
    },
    {"JXCARTAB"}
)

-- 车载音箱
AddRecipe2("jx_parts_music",
    {
        Ingredient("phonograph", 1),
        Ingredient("record", 1),
        Ingredient("transistor", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_parts_music.tex",
    },
    {"JXCARTAB"}
)

-- 精密内燃机
AddRecipe2("jx_parts_engine",
    {
        Ingredient("thulecite_pieces", 8),
        Ingredient("gears", 8),
        Ingredient("goldnugget", 8),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_parts_engine.tex",
    },
    {"JXCARTAB"}
)

-- 方向盘
AddRecipe2("jx_parts_wheel",
    {
        Ingredient("steelwool", 2),
        Ingredient("livinglog", 2),
        Ingredient("voidcloth", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_parts_wheel.tex",
    },
    {"JXCARTAB"}
)

-- 实时跟随摄像头
AddRecipe2("jx_parts_camera_1",
    {
        Ingredient("boards", 2),
        Ingredient("moonglass", 2),
        Ingredient("trinket_6", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_parts_camera_1.tex",
    },
    {"JXCARTAB"}
)

-- 自动对齐摄像头
AddRecipe2("jx_parts_camera_2",
    {
        Ingredient("boards", 2),
        Ingredient("moonglass", 2),
        Ingredient("trinket_6", 2),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_parts_camera_2.tex",
    },
    {"JXCARTAB"}
)

-- 摩托车头盔
AddRecipe2("jx_hat_motorcycle",
    {
        Ingredient("footballhat", 1),
        Ingredient("papyrus", 1),
    },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/inventoryimages/jx_inventoryimages1.xml",
        image = "jx_hat_motorcycle.tex",
    },
    {"JXCARTAB"}
)

end