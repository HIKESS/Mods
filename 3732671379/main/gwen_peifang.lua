local ThePlayer = GLOBAL.ThePlayer
local TheInput = GLOBAL.TheInput
local SpawnPrefab = GLOBAL.SpawnPrefab

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----

----[]----配方----[]----
----新标签
----哨兵分类
local GW_SHAOBING = 
{
   name = "GW_SHAOBING", 
   atlas = "images/inventoryimages/gw_shaobing.xml",
   image = "gw_shaobing.tex",
}
AddRecipeFilter(GW_SHAOBING)

----黑雾分类
local GW_HEIWU = 
{
   name = "GW_HEIWU", 
   atlas = "images/inventoryimages/gw_heiwu.xml",
   image = "gw_heiwu.tex",
}
AddRecipeFilter(GW_HEIWU)


----剪刀
AddRecipe2(
    "gwen_jiandao",
    {
		Ingredient("razor", 1),
		Ingredient("goldnugget", 5),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gwen_jiandao.xml",
		image = "gwen_jiandao.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

----[]----套装----[]----
----女仆衣服
AddRecipe2(
    "gw_yifu_nvpu",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("gwen_golden_spatula", 1,"images/inventoryimages/gwen_golden_spatula.xml"),
		Ingredient("beefalowool", 5),
		Ingredient("silk", 10),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_yifu_nvpu.xml",
        image = "gw_yifu_nvpu.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

----女仆帽子
AddRecipe2(
    "gw_maozi_nvpu",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("goldnugget", 1),
		Ingredient("silk", 3),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_maozi_nvpu.xml",
        image = "gw_maozi_nvpu.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

------------------------------------------------------------------------
---战斗服装
AddRecipe2(
    "gw_yifu_zhandou",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("armorwood", 1),
		Ingredient("gwen_golden_spatula", 1,"images/inventoryimages/gwen_golden_spatula.xml"),
		Ingredient("bluegem", 1),
		-- Ingredient("moonglass",4),
		Ingredient("marble",4),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_yifu_zhandou.xml",
        image = "gw_yifu_zhandou.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

----战斗头冠
AddRecipe2(
    "gw_maozi_zhandou",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		-- Ingredient("flowerhat", 1),
		Ingredient("eyebrellahat", 1),
		Ingredient("gwen_golden_pot", 1,"images/inventoryimages/gwen_golden_pot.xml"),
		Ingredient("bluegem", 1),
		Ingredient("marble", 4),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_maozi_zhandou.xml",
        image = "gw_maozi_zhandou.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

AddRecipe2(
    "gw_yifu_zhandou2",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("armorruins", 1),
		Ingredient("armor_lunarplant", 1),
		Ingredient("armordreadstone", 1),
		-- Ingredient("armor_voidcloth", 1),
		Ingredient("gw_yifu_zhandou", 1,"images/inventoryimages/gw_yifu_zhandou.xml"),
		-- Ingredient("bluegem", 3),
		-- Ingredient("moonglass",5),
		Ingredient("opalpreciousgem", 1),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_yifu_zhandou2.xml",
        image = "gw_yifu_zhandou2.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

----战斗头冠
AddRecipe2(
    "gw_maozi_zhandou2",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("ruinshat", 1),
		-- Ingredient("voidclothhat", 1),
		Ingredient("lunarplanthat", 1),
		Ingredient("moonstorm_goggleshat", 1),
		Ingredient("gw_maozi_zhandou", 1,"images/inventoryimages/gw_maozi_zhandou.xml"),
		-- Ingredient("bluegem", 3),
		-- Ingredient("moonglass",5),
		Ingredient("opalpreciousgem", 1),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_maozi_zhandou2.xml",
        image = "gw_maozi_zhandou2.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)
----------------------------------------------------------------------
----大厨衣服
AddRecipe2(
    "gw_yifu_dachu",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("gwen_golden_spatula", 1,"images/inventoryimages/gwen_golden_spatula.xml"),
		Ingredient("meat", 2),
		Ingredient("manrabbit_tail", 5),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_yifu_dachu.xml",
        image = "gw_yifu_dachu.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

----大厨帽子
AddRecipe2(
    "gw_maozi_dachu",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("manrabbit_tail", 2),
		Ingredient("beefalowool", 4),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_maozi_dachu.xml",
        image = "gw_maozi_dachu.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)
----------------------------------------------------------------------
----园丁衣服
AddRecipe2(
    "gw_yifu_yuanding",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("gwen_golden_spatula", 1,"images/inventoryimages/gwen_golden_spatula.xml"),
		Ingredient("fertilizer", 2),
		Ingredient("seeds", 5),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_yifu_yuanding.xml",
        image = "gw_yifu_yuanding.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)

----园丁帽子
AddRecipe2(
    "gw_maozi_yuanding",
    {
		Ingredient("gwen_jiandao", 0, "images/inventoryimages/gwen_jiandao.xml"),
		Ingredient("plantregistryhat", 1),
		Ingredient("seeds", 2),
		Ingredient("poop", 4),
	},
    TECH.NONE,
	{
        atlas = "images/inventoryimages/gw_maozi_yuanding.xml",
        image = "gw_maozi_yuanding.tex",	
		builder_tag = "gwen",	
    },
    { "CHARACTER"}
)
----------------------------------------------------------------------
----修复套件
AddRecipe2("gw_repair", 
	{
		-- Ingredient("marble", 2),
		Ingredient("nightmarefuel", 4),
		Ingredient("silk", 8),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_repair.xml",
		image = "gw_repair.tex",
		builder_tag = "gwen",
		numtogive = 2
    },
	{"RESTORATION","CHARACTER"}
)

----------------------------------------------------------------------
----魂灯
AddRecipe2("gw_hundeng", 
	{
		Ingredient("lantern", 1),
		Ingredient("gw_soul_ball", 5,"images/inventoryimages/gw_soul_ball.xml"),
		Ingredient("goldnugget", 10),
		Ingredient("cutstone", 5),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_hundeng.xml",
		image = "gw_hundeng.tex",	
    },
	{"LIGHT"}
)
	AddRecipeToFilter("gw_hundeng","GW_HEIWU")
	
----堕落之锋
AddRecipe2("gw_duoluo", 
	{
		Ingredient("gw_soul_ball", 5,"images/inventoryimages/gw_soul_ball.xml"),
		Ingredient("dreadstone", 3),
		Ingredient("nightsword", 1),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_duoluo.xml",
		image = "gw_duoluo.tex",
    },
	{"WEAPONS"}
)
	AddRecipeToFilter("gw_duoluo","GW_HEIWU")
	
----牧魂人之铲
AddRecipe2("gw_muhun", 
	{
		Ingredient("gw_luoyang", 1,"images/inventoryimages/gw_luoyang.xml"),
		Ingredient("gw_soul_ball", 10,"images/inventoryimages/gw_soul_ball.xml"),
		Ingredient("cutstone", 5),
		Ingredient("goldenshovel", 1),
		Ingredient("goldenaxe", 1),
		Ingredient("farm_hoe", 1),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_muhun.xml",
		image = "gw_muhun.tex",
    },
	{"TOOLS"}
)
	AddRecipeToFilter("gw_muhun","GW_HEIWU")
	
----圣洁踏碎者
AddRecipe2("gw_tasui", 
	{
		Ingredient("marble", 10),
		Ingredient("moonglass", 10),
		Ingredient("goldenpickaxe", 1),
		Ingredient("hammer", 1),
		Ingredient("gw_pocheng", 1,"images/inventoryimages/gw_pocheng.xml"),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_tasui.xml",
		image = "gw_tasui.tex",
    },
	{"TOOLS"}
)
	AddRecipeToFilter("gw_tasui","GW_SHAOBING")
	
----圣洁魔杖
AddRecipe2("gw_sjmz", 
	{
		Ingredient("marble", 5),
		Ingredient("moonglass", 5),
		Ingredient("moonrocknugget", 5),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_sjmz.xml",
		image = "gw_sjmz.tex",
    },
	{"WEAPONS"}
)
	AddRecipeToFilter("gw_sjmz","GW_SHAOBING")

----------------------------------------------------------------------
----挂件
----雪花
AddRecipe2("gw_gj_xuehua1", 
	{
		Ingredient("blueamulet", 1),
		Ingredient("beefalowool", 6),
		Ingredient("ice", 10),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_xuehua1.xml",
		image = "gw_gj_xuehua1.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
	
AddRecipe2("gw_gj_xuehua2", 
	{
		Ingredient("gw_gj_xuehua1", 1, "images/inventoryimages/gw_gj_xuehua1.xml"),
		Ingredient("icehat", 1),
		Ingredient("saltrock", 10),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_xuehua2.xml",
		image = "gw_gj_xuehua2.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
	
AddRecipe2("gw_gj_xuehua3", 
	{
		Ingredient("gw_gj_xuehua2", 1, "images/inventoryimages/gw_gj_xuehua2.xml"),
		Ingredient("deerclops_eyeball", 1),
		Ingredient("beargerfur_sack", 1),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_xuehua3.xml",
		image = "gw_gj_xuehua3.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
----------------------------------------------------------------------
----星光
AddRecipe2("gw_gj_xingguang1", 
	{
		Ingredient("yellowamulet", 1),
		Ingredient("torch", 4),
		Ingredient("lightbulb", 6),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_xingguang1.xml",
		image = "gw_gj_xingguang1.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)

AddRecipe2("gw_gj_xingguang2", 
	{
		Ingredient("gw_gj_xingguang1", 1, "images/inventoryimages/gw_gj_xingguang1.xml"),
		Ingredient("lantern", 2),
		Ingredient("wormlight_lesser", 6),
		Ingredient("moonrockcrater", 4),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_xingguang2.xml",
		image = "gw_gj_xingguang2.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
	
AddRecipe2("gw_gj_xingguang3", 
	{
		Ingredient("gw_gj_xingguang2", 1, "images/inventoryimages/gw_gj_xingguang2.xml"),
		Ingredient("yellowstaff", 1),
		Ingredient("ancientfruit_nightvision", 6),
		Ingredient("security_pulse_cage", 2),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_xingguang3.xml",
		image = "gw_gj_xingguang3.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
----------------------------------------------------------------------
----哨兵
AddRecipe2("gw_gj_shaobing1", 
	{
		Ingredient("amulet", 1),
		Ingredient("gw_repair", 2, "images/inventoryimages/gw_repair.xml"),
		Ingredient("sewing_kit", 4),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_shaobing1.xml",
		image = "gw_gj_shaobing1.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
	
AddRecipe2("gw_gj_shaobing2", 
	{
		Ingredient("gw_gj_shaobing1", 1, "images/inventoryimages/gw_gj_shaobing1.xml"),
		Ingredient("lifeinjector", 4),
		Ingredient("bandage", 8),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_shaobing2.xml",
		image = "gw_gj_shaobing2.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)

AddRecipe2("gw_gj_shaobing3", 
	{
		Ingredient("gw_gj_shaobing2", 1, "images/inventoryimages/gw_gj_shaobing2.xml"),
		Ingredient("shadowheart_infused", 2),
		Ingredient("minotaurhorn", 4),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_shaobing3.xml",
		image = "gw_gj_shaobing3.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
----------------------------------------------------------------------
----羽毛
AddRecipe2("gw_gj_yumao1", 
	{
		Ingredient("feather_crow", 5),
		Ingredient("beefalowool", 5),
		Ingredient("silk", 5),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_yumao1.xml",
		image = "gw_gj_yumao1.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
	
AddRecipe2("gw_gj_yumao2", 
	{
		Ingredient("gw_gj_yumao1", 1, "images/inventoryimages/gw_gj_yumao1.xml"),
		Ingredient("feather_robin", 4),
		Ingredient("feather_robin_winter", 4),
		Ingredient("nightmarefuel", 10),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_yumao2.xml",
		image = "gw_gj_yumao2.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)

AddRecipe2("gw_gj_yumao3", 
	{
		Ingredient("gw_gj_yumao2", 1, "images/inventoryimages/gw_gj_yumao2.xml"),
		Ingredient("moonstorm_spark", 4),
		Ingredient("malbatross_feather", 10),
		Ingredient("moonglass_charged", 10),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_yumao3.xml",
		image = "gw_gj_yumao3.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)
----------------------------------------------------------------------
----智慧
AddRecipe2("gw_gj_zhihui1", 
	{
		Ingredient("trinket_6", 1),
		Ingredient("transistor", 2),
		Ingredient("goldnugget", 4),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_zhihui1.xml",
		image = "gw_gj_zhihui1.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)

AddRecipe2("gw_gj_zhihui2", 
	{
		Ingredient("gw_gj_zhihui1", 1, "images/inventoryimages/gw_gj_zhihui1.xml"),
		Ingredient("transistor", 4),
		Ingredient("moonglass", 4),
		Ingredient("trinket_6", 6),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_zhihui2.xml",
		image = "gw_gj_zhihui2.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)

AddRecipe2("gw_gj_zhihui3", 
	{
		Ingredient("gw_gj_zhihui2", 1, "images/inventoryimages/gw_gj_zhihui2.xml"),
		Ingredient("security_pulse_cage", 1),
		Ingredient("moonglass_charged", 6),
		Ingredient("trinket_6", 8),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_gj_zhihui3.xml",
		image = "gw_gj_zhihui3.tex",
		no_deconstruction = true,
		-- builder_tag = "gwen",	
    },
	-- {"CHARACTER"}
	{"CLOTHING"}
)

----------------------------------------------------------------------
----重构器
----白银
AddRecipe2("gw_refactor_1", 
	{
		Ingredient("bluegem", 2),
		Ingredient("marble", 8),
		Ingredient("moonglass", 12),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_refactor_1.xml",
		image = "gw_refactor_1.tex",
		no_deconstruction = true,
		builder_tag = "gwen",	
    },
	{"CHARACTER"}
)

----黄金
AddRecipe2("gw_refactor_2", 
	{
		-- Ingredient("moonglass_charged", 6),
		-- Ingredient("moonstorm_spark", 6),
		Ingredient("boat_bumper_crabking_kit", 2),
		Ingredient("purplegem", 4),
		Ingredient("goldnugget", 20),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_refactor_2.xml",
		image = "gw_refactor_2.tex",
		no_deconstruction = true,
		builder_tag = "gwen",	
    },
	{"CHARACTER"}
)

----棱彩碎片
AddRecipe2("gw_refactor_0", 
	{
		Ingredient("alterguardianhatshard", 1),
		-- Ingredient("moonstorm_static_item", 2),
		-- Ingredient("purebrilliance", 8),
		-- Ingredient("lunarplant_husk", 12),
		Ingredient("greenmooneye",  1),
		Ingredient("yellowmooneye", 1),
		Ingredient("orangemooneye", 1),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_refactor_0.xml",
		image = "gw_refactor_0.tex",
		no_deconstruction = true,
		builder_tag = "gwen",	
    },
	{"CHARACTER"}
)
----------------------------------------------------------------------
----炼金试剂
----废品
-- AddRecipe2("gw_alchemy_1", 
-- 	{
-- 		Ingredient("goldnugget", 2),
-- 		Ingredient("wagpunk_bits", 2),
-- 	},
-- 	TECH.NONE,
-- 	{
-- 		atlas = "images/inventoryimages/gw_alchemy_1.xml",
-- 		image = "gw_alchemy_1.tex",
-- 		no_deconstruction = true,
-- 		builder_tag = "gwen",	
--     },
-- 	{"CHARACTER"}
-- )
-- ----失调
-- AddRecipe2("gw_alchemy_2", 
-- 	{
-- 		Ingredient("bluegem", 2),
-- 		Ingredient("trinket_6", 5),
-- 		Ingredient("thulecite_pieces", 3),
-- 	},
-- 	TECH.NONE,
-- 	{
-- 		atlas = "images/inventoryimages/gw_alchemy_2.xml",
-- 		image = "gw_alchemy_2.tex",
-- 		no_deconstruction = true,
-- 		builder_tag = "gwen",	
--     },
-- 	{"CHARACTER"}
-- )
-- ----优质
-- AddRecipe2("gw_alchemy_3", 
-- 	{
-- 		Ingredient("orangegem", 4),
-- 		Ingredient("dreadstone", 4),
-- 		Ingredient("trinket_6", 10),
-- 		Ingredient("horrorfuel", 4),
-- 	},
-- 	TECH.NONE,
-- 	{
-- 		atlas = "images/inventoryimages/gw_alchemy_3.xml",
-- 		image = "gw_alchemy_3.tex",
-- 		no_deconstruction = true,
-- 		builder_tag = "gwen",	
--     },
-- 	{"CHARACTER"}
-- )
-- ----完美
-- AddRecipe2("gw_alchemy_4", 
-- 	{
-- 		Ingredient("shadowheart_infused", 2),
-- 		Ingredient("purplegem", 4),
-- 		Ingredient("voidcloth", 6),
-- 		Ingredient("dreadstone", 4),
-- 		Ingredient("walrus_tusk", 1),
-- 	},
-- 	TECH.NONE,
-- 	{
-- 		atlas = "images/inventoryimages/gw_alchemy_4.xml",
-- 		image = "gw_alchemy_4.tex",
-- 		no_deconstruction = true,
-- 		builder_tag = "gwen",	
--     },
-- 	{"CHARACTER"}
-- )
----------------------------------------------------------------------
----时光沙漏
AddRecipe2("gw_time_0", 
	{
		Ingredient("messagebottleempty", 2),
		Ingredient("moonglass", 5),
		Ingredient("goldnugget", 5),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_time_0.xml",
		image = "gw_time_0.tex",
		no_deconstruction = true,
		builder_tag = "gwen",	
    },
	{"CHARACTER"}
)

----------------------------------------------------------------------
----金铲铲和金锅锅
AddRecipe2("gwen_golden_spatula", 
	{
		Ingredient("spear", 1),
		Ingredient("goldnugget", 10),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gwen_golden_spatula.xml",
		image = "gwen_golden_spatula.tex",
		builder_tag = "gwen",	
    },
	{"CHARACTER"}
)

AddRecipe2("gwen_golden_pot", 
	{
		Ingredient("hambat", 1),
		Ingredient("goldnugget", 10),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gwen_golden_pot.xml",
		image = "gwen_golden_pot.tex",
		builder_tag = "gwen",	
    },
	{"CHARACTER"}
)

------------------------------------------------------------------------------
---墨镜
AddRecipe2("gw_mojing", 
	{
		Ingredient("rocks", 1),
		Ingredient("goldnugget", 1),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_mojing.xml",
		image = "gw_mojing.tex",
		-- builder_tag = "gwen",	
    },
	{"CLOTHING"}
)


------------------------------------------------------------------------------
---指针
AddRecipe2("gw_zhizhen", 
	{
		Ingredient("gw_soul_ball", 20,"images/inventoryimages/gw_soul_ball.xml"),
		Ingredient("dreadstone", 5),
		Ingredient("shadowheart", 1),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_zhizhen.xml",
		image = "gw_zhizhen.tex",
		builder_tag = "gwen",
    },
	{"CHARACTER"}
)


-- AddRecipe2("gwen_haojiao", 
-- 	{
-- 		Ingredient("walrus_tusk", 2),
-- 		Ingredient("horn", 1),
-- 		Ingredient("ice", 40),
-- 		Ingredient("megaflare", 1),
-- 	},
-- 	TECH.NONE,
-- 	{
-- 		atlas = "images/inventoryimages/gwen_haojiao.xml",
-- 		image = "gwen_haojiao.tex",
-- 		builder_tag = "gwen",
--     },
-- 	{"CHARACTER"}
-- )


-----------------------------------------------------------------------------------
---旅行背包
AddRecipe2("gwen_backpack", 
	{
		Ingredient("pigskin", 3),
		Ingredient("rope", 2),
		Ingredient("silk", 6),
		Ingredient("goldnugget", 3),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gwen_backpack.xml",
		image = "gwen_backpack.tex",
		builder_tag = "gwen",
    },
	{"CHARACTER"}
)


AddRecipe2("gw_luoyang", 
	{
		Ingredient("axe", 1),
		Ingredient("shovel", 1),
		Ingredient("goldnugget", 3),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_luoyang.xml",
		image = "gw_luoyang.tex",
    },
	{"TOOLS"}
)

AddRecipe2("gw_pocheng", 
	{
		Ingredient("hammer", 1),
		Ingredient("pickaxe", 1),
		Ingredient("goldnugget", 3),
	},
	TECH.NONE,
	{
		atlas = "images/inventoryimages/gw_pocheng.xml",
		image = "gw_pocheng.tex",
    },
	{"TOOLS"}
)