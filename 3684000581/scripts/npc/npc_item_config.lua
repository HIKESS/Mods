-- ════════════════════════════════════════════════════════════════════
-- npc_item_config.lua — NPC 物品分类配置表
-- ════════════════════════════════════════════════════════════════════
--
-- 使用说明：
--   1. 每行格式：  prefab名 = true,   -- 中文注释
--   2. 把一行从一个表剪切到另一个表即可调整该物品的分类
--   3. 未出现在任何表中的物品 → 自动归入【箱子】（兜底）
--   4. ICEBOX_TAGS 是标签兜底：物品匹配任意一个标签即归入冰箱
--      （只对不在 DELETE/GROUND/CHEST/ICEBOX 中的物品生效）
--
-- 分类优先级（从高到低）：
--   NPC工具 > DELETE > GROUND > CHEST > ICEBOX > IGNORE > ICEBOX_TAGS > 箱子兜底
--
-- 香料食物（spiced foods）说明：
--   例如 meatballs_spice_garlic、honeyham_spice_chili 等
--   这些是游戏动态生成的，无法逐个列出（共 400+ 种）
--   它们都带有 "preparedfood" 标签，会被 ICEBOX_TAGS 自动捕获
--
-- ════════════════════════════════════════════════════════════════════

return {

-- ══════════════════════════════════════════════════════════════
--  【DELETE — 直接删除】完全无用的物品，拾取后立即删除
-- ══════════════════════════════════════════════════════════════

DELETE = {

	spoiled_fish                = true,   -- 腐烂鱼
    spoiled_fish_small          = true,   -- 腐烂小鱼
    wetgoop                     = true,   -- 湿糊糊（烹饪失败品）
    rot                         = true,   -- 腐烂物（rot 别名，无用直接删）
},

-- ══════════════════════════════════════════════════════════════
--  【GROUND — 地面集中堆放】有微量用途的废物，丢到指定位置
-- ══════════════════════════════════════════════════════════════

GROUND = { 
    rottenegg                   = true,   -- 臭蛋

        -- ── 通用种子 ──
    seeds                       = true,   -- 随机种子
    -- ── 农场种子（15种） ──
    carrot_seeds                = true,   -- 胡萝卜种子
    corn_seeds                  = true,   -- 玉米种子
    potato_seeds                = true,   -- 土豆种子
    tomato_seeds                = true,   -- 番茄种子
    asparagus_seeds             = true,   -- 芦笋种子
    pepper_seeds                = true,   -- 辣椒种子
    onion_seeds                 = true,   -- 洋葱种子
    garlic_seeds                = true,   -- 大蒜种子
    pumpkin_seeds               = true,   -- 南瓜种子
    eggplant_seeds              = true,   -- 茄子种子
    watermelon_seeds            = true,   -- 西瓜种子
    pomegranate_seeds           = true,   -- 石榴种子
    dragonfruit_seeds           = true,   -- 火龙果种子
    durian_seeds                = true,   -- 榴莲种子
    acorn_cooked                = true,   -- 熟橡子
    seeds_cooked                = true,   -- 熟种子
    balloon                     = true,   -- 气球

},

-- ══════════════════════════════════════════════════════════════
--  【ICEBOX — 存入冰箱】需要保鲜的食物
--  烹饪锅料理由 ICEBOX_TAGS("preparedfood") 自动捕获
--    若想把某个料理改存箱子，把它加到 CHEST 表即可（优先级更高）
-- ══════════════════════════════════════════════════════════════

ICEBOX = {

    -- ── 大肉 ──
    meat                        = true,   -- 生大肉
    cookedmeat                  = true,   -- 熟大肉
    meat_dried                  = true,   -- 肉干

    -- ── 叶肉 ──
    plantmeat                   = true,   -- 生叶肉
    plantmeat_cooked            = true,   -- 熟叶肉
    -- ── 小肉 ──
    smallmeat                   = true,   -- 生小肉
    cookedsmallmeat             = true,   -- 熟小肉
    smallmeat_dried             = true,   -- 小肉干

    -- ── 怪物肉 ──
    monstermeat                 = true,   -- 生怪物肉
    cookedmonstermeat           = true,   -- 熟怪物肉
    monstermeat_dried           = true,   -- 怪物肉干

    -- ── 鸡腿 ──
    drumstick                   = true,   -- 生鸡腿
    drumstick_cooked            = true,   -- 熟鸡腿

    -- ── 蛙腿 ──
    froglegs                    = true,   -- 生蛙腿
    froglegs_cooked             = true,   -- 熟蛙腿

    -- ── 蝙蝠翅膀 ──
    batwing                     = true,   -- 生蝙蝠翅膀
    batwing_cooked              = true,   -- 熟蝙蝠翅膀

    -- ── 蝙蝠鼻 ──
    batnose                     = true,   -- 生蝙蝠鼻
    batnose_cooked              = true,   -- 熟蝙蝠鼻


    -- ── 人肉（特殊） ──
    humanmeat                   = true,   -- 生人肉
    humanmeat_cooked            = true,   -- 熟人肉
    humanmeat_dried             = true,   -- 人肉干

    -- ── 鱼肉（大） ──
    fishmeat                    = true,   -- 生鱼肉
    fishmeat_cooked             = true,   -- 熟鱼肉
    fishmeat_dried              = true,   -- 鱼干

    -- ── 鱼肉（小） ──
    fishmeat_small              = true,   -- 生小鱼肉
    fishmeat_small_cooked       = true,   -- 熟小鱼肉
    fishmeat_small_dried        = true,   -- 小鱼干

    -- ── 鱼（活 / 池塘） ──
    --fish                        = true,   -- 活鱼（池塘鱼）
    fish_cooked                 = true,   -- 烤鱼

    -- ── 鳗鱼 ──
    --eel                         = true,   -- 生鳗鱼
    eel_cooked                  = true,   -- 熟鳗鱼

    -- ── 藤壶 ──
    barnacle                    = true,   -- 生藤壶
    barnacle_cooked             = true,   -- 熟藤壶

    -- ── 蛋类 ──
    bird_egg                    = true,   -- 鸟蛋
    bird_egg_cooked             = true,   -- 熟鸟蛋
    egg                         = true,   -- 蛋（兼容旧版prefab）
    egg_cooked                  = true,   -- 熟蛋（兼容旧版prefab）
    --tallbirdegg                 = true,   -- 高脚鸟蛋
    tallbirdegg_cooked          = true,   -- 熟高脚鸟蛋

    -- ── 蜂蜜 / 乳制品 ──
    honey                       = true,   -- 蜂蜜
    royal_jelly                 = true,   -- 蜂王浆
    butter                      = true,   -- 黄油
    goatmilk                    = true,   -- 羊奶

    -- ── 浆果 ──
    berries                     = true,   -- 浆果
    berries_cooked              = true,   -- 熟浆果
    berries_juicy               = true,   -- 多汁浆果
    berries_juicy_cooked        = true,   -- 熟多汁浆果

    -- ── 无花果 ──
    fig                         = true,   -- 无花果
    fig_cooked                  = true,   -- 熟无花果

    -- ── 洞穴香蕉 ──
    cave_banana                 = true,   -- 洞穴香蕉
    cave_banana_cooked          = true,   -- 熟洞穴香蕉

    -- ── 仙人掌 ──
    cactus_meat                 = true,   -- 仙人掌果肉
    cactus_meat_cooked          = true,   -- 熟仙人掌果肉
    cactus_flower               = true,   -- 仙人掌花

    -- ── 蘑菇帽 ──
    red_cap                     = true,   -- 红蘑菇
    red_cap_cooked              = true,   -- 熟红蘑菇
    green_cap                   = true,   -- 绿蘑菇
    green_cap_cooked            = true,   -- 熟绿蘑菇
    blue_cap                    = true,   -- 蓝蘑菇
    blue_cap_cooked             = true,   -- 熟蓝蘑菇
    moon_cap                    = true,   -- 月蘑菇
    moon_cap_cooked             = true,   -- 熟月蘑菇

    -- ── 海带 ──
    kelp                        = true,   -- 海带
    kelp_cooked                 = true,   -- 熟海带
    kelp_dried                  = true,   -- 干海带

    -- ── 蝴蝶翅膀 ──
    butterflywings              = true,   -- 蝴蝶翅膀
    moonbutterflywings          = true,   -- 月蝴蝶翅膀

    -- ── 其他食物 ──
    
    lightbulb                   = true,   -- 荧光果
	trunk_summer                = true,   -- 象鼻
	trunk_winter                = true,   -- 冬象鼻
	trunk_cooked                = true,   -- 象鼻排
    -- ────────────────────────────────────────────────────
    --  以下为烹饪锅料理（都带 "preparedfood" 标签）
    --  即使不列在这里，ICEBOX_TAGS 也会自动捕获
    --  列出是为了方便你把某道菜改存到箱子
    -- ────────────────────────────────────────────────────

    -- ── 标准烹饪锅料理 ──
    butterflymuffin             = true,   -- 蝶花松饼
    frogglebunwich              = true,   -- 青蛙三明治
    taffy                       = true,   -- 太妃糖
    pumpkincookie               = true,   -- 南瓜饼干
    stuffedeggplant             = true,   -- 酿茄子
    fishsticks                  = true,   -- 鱼条
    honeynuggets                = true,   -- 蜜汁肉块
    honeyham                    = true,   -- 蜜汁火腿
    dragonpie                   = true,   -- 龙果派
    kabobs                      = true,   -- 烤肉串
    mandrakesoup                = true,   -- 曼德拉草汤
    baconeggs                   = true,   -- 培根蛋
    meatballs                   = true,   -- 肉丸
    bonestew                    = true,   -- 骨汤
    perogies                    = true,   -- 饺子
    turkeydinner                = true,   -- 火鸡大餐
    ratatouille                 = true,   -- 蔬菜杂烩
    jammypreserves              = true,   -- 果酱
    fruitmedley                 = true,   -- 水果拼盘
    fishtacos                   = true,   -- 鱼肉卷饼
    waffles                     = true,   -- 华夫饼

    unagi                       = true,   -- 鳗鱼饭
    flowersalad                 = true,   -- 花沙拉
    icecream                    = true,   -- 冰淇淋
    watermelonicle              = true,   -- 西瓜棒冰
    trailmix                    = true,   -- 登山混合物
    hotchili                    = true,   -- 辣椒炖肉
    guacamole                   = true,   -- 鳄梨酱
    
    potatotornado               = true,   -- 土豆龙卷风
    mashedpotatoes              = true,   -- 土豆泥
    asparagussoup               = true,   -- 芦笋汤
    vegstinger                  = true,   -- 蔬菜鸡尾酒
    bananapop                   = true,   -- 香蕉棒冰
    frozenbananadaiquiri        = true,   -- 冰冻香蕉代基里
    bananajuice                 = true,   -- 香蕉果汁
    ceviche                     = true,   -- 酸橘汁腌鱼
    salsa                       = true,   -- 莎莎酱
    pepperpopper                = true,   -- 辣椒夫
    californiaroll              = true,   -- 加州卷
    seafoodgumbo                = true,   -- 海鲜浓汤
    surfnturf                   = true,   -- 海陆大餐
    lobsterbisque               = true,   -- 龙虾浓汤
    lobsterdinner               = true,   -- 龙虾大餐
    barnaclepita                = true,   -- 藤壶皮塔饼
    barnaclesushi               = true,   -- 藤壶寿司
    barnaclinguine              = true,   -- 藤壶意大利面
    barnaclestuffedfishhead     = true,   -- 藤壶塞鱼头
    leafloaf                    = true,   -- 叶面包
    leafymeatburger             = true,   -- 多叶肉汉堡
    leafymeatsouffle            = true,   -- 多叶肉舒芙蕾
    meatysalad                  = true,   -- 肉质沙拉
    shroomcake                  = true,   -- 蘑菇蛋糕
    sweettea                    = true,   -- 甜茶
    yotr_food2                  = true,   -- 月饼
    yotr_food3                  = true,   -- 月冻
    koalefig_trunk              = true,   -- 考拉象鼻
    figatoni                    = true,   -- 无花果面
    figkabab                    = true,   -- 无花果烤肉串
    frognewton                  = true,   -- 青蛙牛顿饼
    bunnystew                   = true,   -- 兔肉炖菜
    justeggs                    = true,   -- 纯蛋料理
    veggieomlet                 = true,   -- 蔬菜煎蛋
    talleggs                    = true,   -- 高脚鸟蛋料理
    beefalofeed                 = true,   -- 皮弗娄牛饲料
    beefalotreat                = true,   -- 皮弗娄牛零食
    shroombait                  = true,   -- 蘑菇催眠饵
    teatree_nut                 = true,   -- 茶树果
    -- ── Warly 大厨专属料理 ──
    nightmarepie                = true,   -- 噩梦派（交换生命/理智）
    voltgoatjelly               = true,   -- 伏特羊凝胶（电击攻击）
    glowberrymousse             = true,   -- 发光浆果慕斯（发光效果）
    frogfishbowl                = true,   -- 青蛙鱼缸（防潮）
    dragonchilisalad            = true,   -- 龙辣椒沙拉（持续加热）
    gazpacho                    = true,   -- 西班牙冷汤（持续降温）
    potatosouffle               = true,   -- 土豆舒芙蕾
    monstertartare              = true,   -- 怪物鞑靼
    freshfruitcrepes            = true,   -- 新鲜水果薄饼
    bonesoup                    = true,   -- 骨汤（Warly版）
    moqueca                     = true,   -- 莫基卡（巴西炖菜）

    -- ── 冬季盛宴料理 ──
    berrysauce                  = true,   -- 浆果酱
    bibingka                    = true,   -- 比宾卡
    cabbagerolls                = true,   -- 卷心菜卷
    festivefish                 = true,   -- 节日鱼
    gravy                       = true,   -- 肉汁
    latkes                      = true,   -- 土豆煎饼
    lutefisk                    = true,   -- 鳕鱼干
    mulleddrink                 = true,   -- 热饮
    panettone                   = true,   -- 潘妮托尼
    pavlova                     = true,   -- 巴甫洛娃
    pickledherring              = true,   -- 腌鲱鱼
    polishcookie                = true,   -- 波兰饼干
    pumpkinpie                  = true,   -- 南瓜派
    roastturkey                 = true,   -- 烤火鸡
    stuffing                    = true,   -- 馅料
    sweetpotato                 = true,   -- 甘薯
    tamales                     = true,   -- 玉米粽
    tourtiere                   = true,   -- 肉馅饼
	
	
	    ice                         = true,   -- 冰
		
    -- ── 原始作物 — 生（14种） ──
    carrot                      = true,   -- 胡萝卜
    corn                        = true,   -- 玉米
    potato                      = true,   -- 土豆
    tomato                      = true,   -- 番茄
    asparagus                   = true,   -- 芦笋
    pepper                      = true,   -- 辣椒
    onion                       = true,   -- 洋葱
    garlic                      = true,   -- 大蒜
    pumpkin                     = true,   -- 南瓜
    eggplant                    = true,   -- 茄子
    watermelon                  = true,   -- 西瓜
    pomegranate                 = true,   -- 石榴
    dragonfruit                 = true,   -- 火龙果
    durian                      = true,   -- 榴莲

    -- ── 原始作物 — 熟（火烤，14种） ──
    carrot_cooked               = true,   -- 熟胡萝卜
    corn_cooked                 = true,   -- 熟玉米
    potato_cooked               = true,   -- 熟土豆
    tomato_cooked               = true,   -- 熟番茄
    asparagus_cooked            = true,   -- 熟芦笋
    pepper_cooked               = true,   -- 熟辣椒
    onion_cooked                = true,   -- 熟洋葱
    garlic_cooked               = true,   -- 熟大蒜
    pumpkin_cooked              = true,   -- 熟南瓜
    eggplant_cooked             = true,   -- 熟茄子
    watermelon_cooked           = true,   -- 熟西瓜
    pomegranate_cooked          = true,   -- 熟石榴
    dragonfruit_cooked          = true,   -- 熟火龙果
    durian_cooked               = true,   -- 熟榴莲

    -- ── 原始作物 — 干燥 ──
    carrot_dried                = true,   -- 胡萝卜干
    eggplant_dried              = true,   -- 茄子干
    asparagus_dried             = true,   -- 芦笋干
},

-- ══════════════════════════════════════════════════════════════
--  【CHEST — 存入箱子】不需要保鲜的物品
--  此表优先级高于 ICEBOX 和 ICEBOX_TAGS
--    所以农产品放在这里不会被冰箱标签"抢走"
-- ══════════════════════════════════════════════════════════════

CHEST = {
	
	-- ── 腐烂物（阈值控制，可做肥料） ──
	spoiled_food                = true,   -- 腐烂物（冰箱中移到箱子，超5组删除）
	
	-- ── 补充 ──
	honeycomb                   = true,   -- 蜂巢蜜（非食物，冰箱拒收）
	jellybean                   = true,   -- 彩虹糖豆
	deerclops_eyeball           = true,   -- 巨鹿眼球
	horn						= true,   -- 牛角
	fossil_piece				= true,   -- 化石碎片
	beardhair					= true,   -- 胡须
	goose_feather				= true,   -- 麋鹿鹅羽毛
	waxpaper					= true,   -- 蜡纸
	transistor					= true,   -- 电子元件
	walrus_tusk					= true,   -- 海象牙
	lightninggoathorn			= true,   -- 伏特羊角
	beefalowool					= true,   -- 牛毛
	manrabbit_tail				= true,   -- 兔绒
	shroom_skin					= true,   -- 蘑菇片
	dragon_scales				= true,   -- 鳞片
	bearger_fur					= true,   -- 熊皮
	poop						= true,   -- 粪肥
	guano						= true,   -- 鸟粪
	horrorfuel					= true,   -- 纯粹恐惧
	purebrilliance				= true,   -- 纯粹辉煌
	saltrock					= true,   -- 盐晶
	ash                         = true,   -- 灰烬（燃烧残留物）
	townportaltalisman			= true,   -- 沙之石
	acorn                       = true,   -- 橡子（可食用、会腐烂）
    driftwood_log               = true,   -- 浮木
    glommerfuel                 = true,   -- 格洛默黏液（可食用）
    mandrake                    = true,   -- 曼德拉草
	cutreeds                    = true,   -- 采下的芦苇
	dreadstone                  = true,   -- 绝望石
	minotaurhorn                = true,   -- 守护者之角
    powcake                     = true,   -- 粉糕（不会腐烂）

    -- ── Mod 物品（树种子 / NPC道具 / 地皮）──
    jungletreeseed              = true,   -- 丛林树种子
    
    clawpalmtree_sapling        = true,   -- 爪棕榈树苗
    npc_heart                   = true,   -- 生命
    npc_sword                   = true,   -- 战意
    turf_pigruins                = true,   -- 猪人遗迹地皮
    turf_rainforest              = true,   -- 雨林地皮
    turf_deeprainforest          = true,   -- 深雨林地皮
    turf_lawn                    = true,   -- 草坪地皮
    turf_gasjungle               = true,   -- 毒气丛林地皮
    turf_moss                    = true,   -- 苔藓地皮
    turf_fields                  = true,   -- 农田地皮
    turf_foundation              = true,   -- 基石地皮
    turf_cobbleroad              = true,   -- 鹅卵石路地皮
    turf_painted                 = true,   -- 彩绘地皮
    turf_plains                  = true,   -- 平原地皮
    turf_beard_hair              = true,   -- 胡须地毯地皮
    turf_deeprainforest_nocanopy = true,   -- 深雨林(无树冠)地皮

    -- ── 木材类 ──
    log                         = true,   -- 原木
    boards                      = true,   -- 木板
    charcoal                    = true,   -- 木炭
    livinglog                   = true,   -- 活木
    twigs                       = true,   -- 树枝
    driftwood_piece             = true,   -- 浮木片

    -- ── 石头 / 矿物 ──
    rocks                       = true,   -- 岩石
    flint                       = true,   -- 燧石
    nitre                       = true,   -- 硝石
    cutstone                    = true,   -- 切割石
    marble                      = true,   -- 大理石
    goldnugget                  = true,   -- 金块
    moonrocknugget              = true,   -- 月岩块
    moonglass                   = true,   -- 月玻璃
    thulecite                   = true,   -- 铥矿石
    thulecite_pieces            = true,   -- 铥矿碎片

    -- ── 宝石 ──
    redgem                      = true,   -- 红宝石
    bluegem                     = true,   -- 蓝宝石
    greengem                    = true,   -- 绿宝石
    orangegem                   = true,   -- 橙宝石
    yellowgem                   = true,   -- 黄宝石
    purplegem                   = true,   -- 紫宝石
    opalpreciousgem             = true,   -- 蛋白石

    -- ── 布料 / 有机材料 ──
    silk                        = true,   -- 蜘蛛丝
    rope                        = true,   -- 绳子
    papyrus                     = true,   -- 纸莎草
    beeswax                     = true,   -- 蜂蜡
    cutgrass                    = true,   -- 割草
    petals                      = true,   -- 花瓣
    petals_evil                 = true,   -- 噩梦花瓣
    foliage                     = true,   -- 树叶

    -- ── 动物掉落物 ──
    pigskin                     = true,   -- 猪皮
    houndstooth                 = true,   -- 猎犬牙
    stinger                     = true,   -- 蜂刺
    spidergland                 = true,   -- 蜘蛛腺
    spidereggsack               = true,   -- 蜘蛛卵囊
    tentaclespots               = true,   -- 触手皮
    slurtle_shellpieces         = true,   -- 蛞蝓壳碎片
    slurtleslime                = true,   -- 蛞蝓黏液
    mosquitosack                = true,   -- 蚊子血袋


    -- ── 羽毛 ──
    feather_crow                = true,   -- 乌鸦羽毛
    feather_robin               = true,   -- 知更鸟羽毛
    feather_robin_winter        = true,   -- 冬季知更鸟羽毛
    feather_canary              = true,   -- 金丝雀羽毛

    -- ── 特殊材料 ──
    nightmarefuel               = true,   -- 噩梦燃料
    gears                       = true,   -- 齿轮
    boneshard                   = true,   -- 骨头碎片


    -- ── 树种子 ──
    pinecone                    = true,   -- 松果
    twiggy_nut                  = true,   -- 树枝树种子
    palmcone_seed               = true,   -- 棕榈树种子

    -- ── 可挖掘植物根 ──
    dug_sapling                 = true,   -- 挖出的树苗
    dug_grass                   = true,   -- 挖出的草丛
    dug_berrybush               = true,   -- 挖出的浆果丛
    dug_berrybush2              = true,   -- 挖出的多汁浆果丛
    dug_marsh_bush              = true,   -- 挖出的沼泽灌木
},

-- ══════════════════════════════════════════════════════════════
--  【IGNORE — 显式忽略】NPC 完全无视的物品，不拾取、不存储、不管
--  用于排除被 ICEBOX_TAGS 标签兜底误匹配的物品
-- ══════════════════════════════════════════════════════════════

IGNORE = {
    heatrock                    = true,   -- 暖石：玩家自行管理，NPC不碰
},

-- ══════════════════════════════════════════════════════════════
--  【ICEBOX_TAGS — 冰箱标签兜底】
--  物品不在以上任何表中、但匹配以下任意标签 → 存入冰箱
--  主要用于自动捕获所有烹饪锅料理和有 icebox_valid 的物品
-- ══════════════════════════════════════════════════════════════

ICEBOX_TAGS = {
    "preparedfood",     -- 所有烹饪锅料理（肉丸、蜜汁火腿、龙果派 …）
    "icebox_valid",     -- DST 原版冰箱白名单标签
},

}
