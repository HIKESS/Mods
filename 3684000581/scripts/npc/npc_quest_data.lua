-- scripts/npc/npc_quest_data.lua
-- 猪人公主任务数据模块
-- 所有任务内容（目标、奖励、对话）集中在此文件，方便后续添加和修改
-- ════════════════════════════════════════════════════════════

local QuestData = {}

-- 语言检测
local function IsChinese()
    local strings = STRINGS
    local ui = strings ~= nil and strings.UI or nil
    local mainscreen = ui ~= nil and ui.MAINSCREEN or nil
    local play = mainscreen ~= nil and mainscreen.PLAY or nil
    return type(play) == "string" and play:match("[\228-\233]") ~= nil
end

local function L(zh, en)
    return IsChinese() and zh or en
end

-- ════════════════════════════════════════════════════════════
--  任务定义表
--  每个任务包含：
--    id            - 唯一标识符
--    name          - 任务名称
--    desc          - 任务描述（详情页显示）
--    objectives    - 目标列表 { {prefab="xxx", count=N}, ... }
--    rewards       - 固定奖励列表 { {prefab="xxx", count=N}, ... }
--    random_count  - 从随机奖励池抽取的数量（0=不抽）
-- ════════════════════════════════════════════════════════════

QuestData.DEFS = {

    {
        id         = "quest_collect_meat",
        name       = L("收集肉类", "Collect Meat"),
        desc       = L(
            "本公主正在筹备一场盛大的宴会，需要新鲜的肉类！\n勇敢的冒险家，帮我收集些生肉回来吧~",
            "Wilba prepareth a grand feast and needeth fresh meat!\nPrithee, brave one — wouldst thou gather some raw meat?"
        ),
        objectives = {
            { prefab = "meat", count = 4, label = L("生肉", "Raw Meat") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 6, label = L("金块", "Gold Nugget") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_berries",
        name       = L("采集浆果", "Gather Berries"),
        desc       = L(
            "本公主想做些浆果派分给臣民们品尝~\n冒险家，帮我去野地采些浆果回来吧！",
            "Wilba wisheth to bake berry pies for mine subjects!\nWouldst thou gather some berries, kind adventurer?"
        ),
        objectives = {
            { prefab = "berries", count = 5, label = L("浆果", "Berries") },
        },
        rewards    = {
        },
        random_count = 1,
    },

    {
        id         = "quest_kill_spiders",
        name       = L("清除蛛害", "Clear Spider Infestation"),
        desc       = L(
            "可恶的蜘蛛在镇子附近越聚越多，臣民们都很害怕！\n勇敢的冒险家，帮我消灭它们！",
            "Foul spiders plague mine village and frighten mine subjects!\nBrave one, wilt thou slay them for Wilba?"
        ),
        objectives = {
            { prefab = "spider", count = 5, label = L("蜘蛛", "Spider"), is_kill = true },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 5, label = L("金块", "Gold Nugget") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_logs",
        name       = L("采集木材", "Gather Logs"),
        desc       = L(
            "镇子要扩建新房了，木材不够用！\n帮吾去砍些原木回来吧，冒险家~",
            "Mine town expandeth and we needeth wood!\nWouldst thou gather logs for Wilba, good adventurer?"
        ),
        objectives = {
            { prefab = "log", count = 10, label = L("原木", "Logs") },
        },
        rewards    = {
            --{ prefab = "boards", count = 4, label = L("木板", "Boards") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_rocks",
        name       = L("采石任务", "Quarry Stone"),
        desc       = L(
            "城墙年久失修，本公主需要石料来加固。\n帮吾采些石头来吧~",
            "Mine walls crumble and needeth repair!\nPrithee, bring Wilba some stone~"
        ),
        objectives = {
            { prefab = "rocks", count = 10, label = L("石头", "Rocks") },
        },
        rewards    = {
            --{ prefab = "cutstone", count = 3, label = L("石砖", "Cut Stone") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_gold",
        name       = L("淘金热", "Gold Rush"),
        desc       = L(
            "本公主想给宫殿添些金闪闪的饰物！\n去矿场帮吾采些金块回来吧~",
            "Mine palace need'st golden adornments!\nPrithee, bring Wilba gold from the mines~"
        ),
        objectives = {
            { prefab = "goldnugget", count = 6, label = L("金块", "Gold Nuggets") },
        },
        rewards    = {
        },
        random_count = 1,
    },

    {
        id         = "quest_craft_tools",
        name       = L("工匠精神", "Craftsmanship"),
        desc       = L(
            "镇上的工匠病倒了，工具短缺得很。\n冒险家，帮吾做些斧头和镐子给臣民们吧！",
            "Mine craftsman hath fallen ill and tools run short!\nCanst thou craft axes and pickaxes for mine subjects?"
        ),
        objectives = {
            { prefab = "axe",      count = 3, label = L("斧头", "Axe") },
            { prefab = "pickaxe",  count = 3, label = L("镐子", "Pickaxe") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 4, label = L("金块", "Gold Nugget") },
        },
        random_count = 3,
    },

    {
        id         = "quest_collect_feathers",
        name       = L("收集羽毛", "Collect Feathers"),
        desc       = L(
            "本公主想要一顶漂亮的羽毛帽！\n帮吾收集些乌鸦羽毛吧，这会让吾很高兴的~",
            "Wilba desireth a splendid feather hat!\nPrithee, bring mine snout some crow feathers~"
        ),
        objectives = {
            { prefab = "feather_crow", count = 3, label = L("乌鸦羽毛", "Crow Feather") },
        },
        rewards    = {
            --{ prefab = "feather_crow", count = 2,  label = L("乌鸦羽毛", "Crow Feather") },
        },
        random_count = 1,
    },

    {
        id         = "quest_cook_dish",
        name       = L("烹饪大师", "Master Chef"),
        desc       = L(
            "听闻你的厨艺很厉害嘛！本公主好久没吃到肉丸了，\n帮吾做一份吧~",
            "Word reacheth Wilba of thy cooking prowess!\nI hath not tasted meatballs in ages — maketh one for Wilba, prithee!"
        ),
        objectives = {
            { prefab = "meatballs", count = 1, label = L("肉丸", "Meatballs") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 5,  label = L("金块", "Gold Nugget") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_gems",
        name       = L("宝石猎人", "Gem Hunter"),
        desc       = L(
            "本公主的皇冠上缺了颗红宝石...\n去地下洞穴帮吾寻来一颗吧！这可不是件容易的事~",
            "Mine crown lacketh a ruby...\nVenture into the caves and claim one for thy princess! Naught an easy task, is't?"
        ),
        objectives = {
            { prefab = "redgem", count = 1, label = L("红宝石", "Red Gem") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 10, label = L("金块", "Gold Nugget") },
        },
        random_count = 2,
    },

    {
        id         = "quest_collect_lanterns",
        name       = L("宫廷照明", "Palace Illumination"),
        desc       = L(
            "宫殿的长廊夜里太暗了，侍卫们总绊倒。\n去收集些提灯来点亮吾的居所吧~",
            "Mine palace halls grow dark at eve, and guards oft stumble.\nPrithee, gather lanterns to light Wilba’s domain~"
        ),
        objectives = {
            { prefab = "lantern", count = 1, label = L("提灯", "Lantern") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 6, label = L("金块", "Gold Nugget") },
            --{ prefab = "oinc",       count = 15, label = L("猪币", "Oinc") },
        },
        random_count = 1,
    },


    {
        id         = "quest_collect_thulecite",
        name       = L("远古秘银", "Ancient Thulecite"),
        desc       = L(
            "本公主想为皇家宝库添置些稀世珍宝。\n地底的发光石头正是吾所需，去寻些来吧！",
            "Wilba seeketh rare treasures for the royal vault!\nThe glowing stone of the deep shall suffice — bring it hither!"
        ),
        objectives = {
            { prefab = "thulecite", count = 1, label = L("铥矿", "Thulecite") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 10, label = L("金块", "Gold Nugget") },
            --{ prefab = "purplegem",  count = 1,  label = L("紫宝石", "Purple Gem") },
        },
        random_count = 2,
    },

    {
        id         = "quest_collect_guano",
        name       = L("皇家花肥", "Royal Fertilizer"),
        desc       = L(
            "御花园的玫瑰最近蔫了，园丁说缺些好肥料。\n去收集些蝙蝠粪便吧，虽然臭，但很管用~",
            "Mine royal roses droop, and the gardener cryeth for good soil.\nFetch bat guano — foul it smell, but ’tis most potent!"
        ),
        objectives = {
            { prefab = "batguano", count = 4, label = L("蝙蝠粪", "Bat Guano") },
        },
        rewards    = {
            --{ prefab = "seeds", count = 10, label = L("种子", "Seeds") },
            --{ prefab = "oinc",  count = 8,  label = L("猪币", "Oinc") },
        },
        random_count = 1,
    },

    {
        id         = "quest_kill_merms",
        name       = L("肃清鱼人", "Merm Purge"),
        desc       = L(
            "沼泽的鱼人最近越界骚扰商旅了！\n吾的王城不容侵犯，去把它们赶走或消灭！",
            "Mermen encroach upon trade routes and menace Wilba’s merchants!\nDrive them back, or send them to the deep — the crown tolerates no theft!"
        ),
        objectives = {
            { prefab = "merm", count = 1, label = L("鱼人", "Merm"), is_kill = true },
        },
        rewards    = {
            --{ prefab = "fish",       count = 5, label = L("鱼", "Fish") },
            --{ prefab = "goldnugget", count = 8, label = L("金块", "Gold Nugget") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_honey",
        name       = L("蜜糖盛宴", "Honeyed Feast"),
        desc       = L(
            "下午茶时间到了，可御厨说蜂蜜罐空了！\n去蜂箱旁取些新鲜蜂蜜来，要快哦~",
            "Tis tea time, yet the royal larder lacketh honey!\nHaste to the hives, sweet adventurer, and bring Wilba the nectar~"
        ),
        objectives = {
            { prefab = "honey", count = 4, label = L("蜂蜜", "Honey") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 5, label = L("金块", "Gold Nugget") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_nightmarefuel",
        name       = L("暗影炼金", "Shadow Alchemy"),
        desc       = L(
            "宫廷学者在进行古老的仪式，急需暗影燃料。\n这任务有点危险，但报酬绝对丰厚~",
            "The court scholar performeth an ancient rite and cryeth for shadow’s breath!\n’Tis perilous work, yet the princess’s reward shall be most generous~"
        ),
        objectives = {
            { prefab = "nightmarefuel", count = 3, label = L("噩梦燃料", "Nightmare Fuel") },
        },
        rewards    = {
            --{ prefab = "purplegem",  count = 1, label = L("紫宝石", "Purple Gem") },
            --{ prefab = "goldnugget", count = 8, label = L("金块", "Gold Nugget") },
        },
        random_count = 1,
    },

    {
        id         = "quest_collect_papyrus",
        name       = L("皇家文书", "Royal Decrees"),
        desc       = L(
            "新的法令需要颁布，可羊皮纸不够了。\n去芦苇荡收集些莎草纸吧，本公主等着呢~",
            "New decrees await the royal seal, yet papyrus runneth dry!\nGather reeds from the marsh, that Wilba’s word may be written and shared!"
        ),
        objectives = {
            { prefab = "papyrus", count = 3, label = L("莎草纸", "Papyrus") },
        },
        rewards    = {
            --{ prefab = "goldnugget", count = 6, label = L("金块", "Gold Nugget") },
        },
        random_count = 1,
    },

        {
            id         = "quest_help_wilson_experiment",
            name       = L("帮帮那个书呆子", "Help the Bookish One"),
            desc       = L(
                "本公主的顾问威尔逊又在捣鼓他的试管了，他说需要一些金块来做什么“导电路实验”。\n虽然本公主不太懂，但看在他帮本公主修过镜子的份上，你帮他去挖些金块吧～",
                "The princess's advisor Wilson is tinkering with his test tubes again. He claimeth he needeth gold for some 'conductivity experiment.'\nThe princess doth not understand, but he once fixed her mirror. Prithee, mine the gold for him~"
            ),
            objectives = {
                { prefab = "goldnugget", count = 8, label = L("金块", "Gold Nugget") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_comfort_wendy",
            name       = L("给少女送花", "Bring Flowers to the Girl"),
            desc       = L(
                "温蒂那个小姑娘总是一副哀伤的样子，本公主看着心里也不舒服。\n去采一束漂亮的花送给她吧，希望她的脸色能比花好看一点。",
                "Wendy the maiden ever weareth a sorrowful face, and 'tis heavy on the princess's heart.\nGather a bouquet of pretty flowers for her, that her cheek may rival the blossom's hue."
            ),
            objectives = {
                { prefab = "petals", count = 5, label = L("花瓣", "Petals") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_spar_with_wathgrithr",
            name       = L("女武神的挑战", "The Valkyrie's Challenge"),
            desc       = L(
                "那个嗓门很大的女武神薇格弗德说本公主太娇弱，要你替本公主去跟她切磋！\n去收集些木甲和长矛交给本公主的勇士吧～（本公主才不会亲自上阵呢）",
                "The loud-throated Valkyrie Wigfrid sayeth the princess is too delicate. She would have thee spar in Wilba's stead!\nGather wood armor and spears for the princess's champion～ (The princess shall not dirty her own hooves.)"
            ),
            objectives = {
                { prefab = "armorwood", count = 1, label = L("木甲", "Wood Armor") },
                { prefab = "spear",     count = 1, label = L("长矛", "Spear") },
            },
            rewards = {},
            random_count = 2,
        },
    
        {
            id         = "quest_feed_wolfgang",
            name       = L("大胃王的烦恼", "The Big Eater's Trouble"),
            desc       = L(
                "沃尔夫冈那个大个子总是喊饿，吵得本公主没法午睡。\n去给他做一份大肉汤，让他安静下来！",
                "Wolfgang the giant ever cryeth hunger, and his belly's roar disturbeth the princess's nap.\nPrepare for him a hearty meat stew, that he may fall silent!"
            ),
            objectives = {
                { prefab = "meaty_stew", count = 1, label = L("大肉汤", "Meaty Stew") },
            },
            rewards = {},
            random_count = 1,
        },
 
        {
            id         = "quest_borrow_book_from_wickerbottom",
            name       = L("借本书来读读", "Borrow a Book"),
            desc       = L(
                "本公主最近想学点知识，免得被薇克巴顿老奶奶笑话。\n但她的书从来不外借，你去帮她整理书架，作为交换，请她借一本《宝石鉴赏指南》给本公主～",
                "The princess lately wisheth to learn, lest Wickerbottom the elder mock her ignorance.\nHer books are never lent. Prithee, organize her shelves, and in return beg the tome 'A Guide to Gem Appreciation' for Wilba～"
            ),
            objectives = {
                { prefab = "papyrus", count = 2, label = L("莎草纸", "Papyrus") },  -- 用来整理书架
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_calm_willow",
            name       = L("别放火烧了本公主的宫殿", "Do Not Burn My Palace"),
            desc       = L(
                "那个叫薇洛的女孩总盯着本公主的烛台流口水，本公主很害怕她哪天一高兴就把宫殿点了！\n你去给她弄些可燃的木头，让她去远处烧着玩，离本公主的绸缎窗帘远一点！",
                "Willow ever eyeth the princess's candelabra with a hungry gleam, and Wilba feareth she may set the palace ablaze!\nBring her wood and kindling, that she may burn it far from the princess's silk drapes!"
            ),
            objectives = {
                { prefab = "log", count = 20, label = L("木头", "Log") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_collect_meat_for_webber",
            name       = L("给蜘蛛男孩的加餐", "Extra Meal for the Spider Boy"),
            desc       = L(
                "韦伯那孩子总说吃不饱，本公主虽然有点怕蜘蛛，但看他可怜。\n去猎些怪物肉回来，让他吃个够，别在本公主面前晃来晃去了。",
                "Webber the spider-child ever complaineth of hunger. Though the princess feareth his legs, she pitieth him.\nHunt monster meat for him, that he may feast and cease his creeping before the princess's eyes."
            ),
            objectives = {
                { prefab = "monstermeat", count = 3, label = L("怪物肉", "Monster Meat") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_fish_for_wurt",
            name       = L("给鱼人妹妹的礼物", "A Gift for the Fish Girl"),
            desc       = L(
                "沃特那个小鱼人虽然说话难听，但她帮本公主赶走过讨厌的蚊子。\n本公主要回礼！去钓几条鱼给她，要新鲜的，不要让本公主丢脸。",
                "Wurt the merm speaketh rudely, yet she once chased away the buzzing flies for the princess.\nThe princess repayeth kindness! Catch fresh fish for her, lest Wilba lose face."
            ),
            objectives = {
                { prefab = "fish", count = 3, label = L("鱼", "Fish") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_heal_wortox",
            name       = L("胆小恶魔受伤了", "The Timid Imp Is Hurt"),
            desc       = L(
                "沃托克斯那个爱说冷笑话的家伙居然受伤了，他说被蜜蜂蛰了。\n本公主虽然觉得好笑，但还是帮他找些蜂蜜药膏吧。",
                "Wortox the jester hath been stung by bees! The princess findeth it amusing, yet she is not without mercy.\nSeek honey poultice for his wounds."
            ),
            objectives = {
                { prefab = "honey", count = 2, label = L("蜂蜜", "Honey") },
                { prefab = "ash",   count = 2, label = L("灰烬", "Ash") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_fix_wandas_watch",
            name       = L("帮旺达修表", "Fix Wanda's Watch"),
            desc       = L(
                "旺达那个老太婆（嘘，别让她听见）说她的怀表坏了，急需齿轮和零件。\n本公主虽然不懂时间，但你可以去翻翻齿轮怪，找些零件给她。",
                "Wanda the time-worn lady (shh, speak not aloud) hath broken her pocket watch. She needeth gears and parts.\nThe princess knoweth naught of time, but thou mayst search the clockwork beasts for her."
            ),
            objectives = {
                { prefab = "gears", count = 1, label = L("齿轮", "Gears") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_entertain_wes",
            name       = L("给哑剧演员的颜料", "Paints for the Mime"),
            desc       = L(
                "韦斯那个不说话的家伙今天比划着想要颜料，说要画一张本公主的肖像！\n这还差不多，你去收集些蝴蝶翅膀和木炭，给他做颜料。本公主要看看他画得如何。",
                "Wes the silent mime today gestured for paint, saying he would paint the princess's portrait!\nThat is more like it! Gather butterfly wings and charcoal to make pigments. The princess shall judge his work."
            ),
            objectives = {
                { prefab = "butterflywings", count = 6, label = L("蝴蝶翅膀", "Butterfly Wings") },
                { prefab = "charcoal",       count = 4, label = L("木炭", "Charcoal") },
            },
            rewards = {},
            random_count = 3,
        },
    
        {
            id         = "quest_share_wood_with_woodie",
            name       = L("分享木材给伐木工", "Share Lumber with the Lumberjack"),
            desc       = L(
                "伍迪那个老实人说斧头钝了，需要好木头做新的手柄。\n本公主的仓库里存了不少原木，你拿一些给他吧，就说本公主赏他的。",
                "Woodie the honest lumberjack said his axe is dull and needeth good wood for a new handle.\nThe princess hath logs in store. Deliver some to him, and say they are a gift from Wilba."
            ),
            objectives = {
                { prefab = "log", count = 12, label = L("原木", "Log") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_taste_warlys_dish",
            name       = L("品鉴沃利的新菜", "Taste Warly's New Dish"),
            desc       = L(
                "大厨沃利做了道怪怪的菜，非要本公主点评。本公主才不要当试毒的小白鼠呢！\n你去替他尝一尝，然后告诉他“还不错”，让本公主清静清静。",
                "Chef Warly hath concocted a strange dish and biddeth the princess taste it. The princess refuseth to be a poison-tester!\nThou shalt try it for her, then tell him 'not bad', that he may leave Wilba in peace."
            ),
            objectives = {
                { prefab = "ratatouille", count = 1, label = L("蔬菜杂烩", "Ratatouille") },
            },
            rewards = {},
            random_count = 1,
        },
    
        -- ── 更多收集类任务（公主日常）────────────────────────────
    
        {
            id         = "quest_collect_marble",
            name       = L("大理石雕塑", "Marble Statue"),
            desc       = L(
                "本公主想在花园里立一座自己的雕像，需要上等大理石！\n去矿场敲些大理石回来吧，要完整的，别磕坏了～",
                "The princess desireth a statue of herself in the garden, of finest marble!\nQuarry marble from the caves, and let it be unblemished～"
            ),
            objectives = {
                { prefab = "marble", count = 6, label = L("大理石", "Marble") },
            },
            rewards = {},
            random_count = 2,
        },
    
        {
            id         = "quest_collect_silk",
            name       = L("皇家丝绸", "Royal Silk"),
            desc       = L(
                "本公主的睡衣该换新了，需要丝绸！\n去收集些蜘蛛丝回来，让裁缝给本公主织一匹最柔软的绸缎。",
                "The princess's nightgown weareth thin. Silk is needed!\nGather spider silk for the royal tailor to weave the softest cloth."
            ),
            objectives = {
                { prefab = "silk", count = 5, label = L("蜘蛛丝", "Silk") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_collect_ice",
            name       = L("夏日冷饮", "Summer Refreshment"),
            desc       = L(
                "天太热了，本公主要喝冰镇果汁！\n去切点冰块回来，动作要快，不然本公主就要中暑了～",
                "The summer heat is cruel! The princess demandeth chilled juice!\nHew ice from the glacier, quick, lest Wilba wilt～"
            ),
            objectives = {
                { prefab = "ice", count = 5, label = L("冰块", "Ice") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_collect_lightbulb",
            name       = L("萤火虫灯笼", "Firefly Lantern"),
            desc       = L(
                "本公主的卧室太暗了，需要几盏萤火虫灯笼。\n去地下采些荧光果回来吧，亮闪闪的才配得上本公主。",
                "The princess's bedchamber is too dark. She needeth firefly lanterns!\nPluck glow berries from the caves, that their shimmer may match Wilba's radiance."
            ),
            objectives = {
                { prefab = "lightbulb", count = 8, label = L("荧光果", "Light Bulb") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_collect_cactus_flower",
            name       = L("沙漠玫瑰", "Desert Rose"),
            desc       = L(
                "听说沙漠里的仙人掌会开花，本公主要用它们编花环！\n去摘些仙人掌花回来，小心刺！本公主的蹄子娇贵得很。",
                "Word reacheth Wilba that desert cacti bloom. The princess would weave a garland!\nGather cactus flowers, mind the thorns! The princess's hooves are delicate."
            ),
            objectives = {
                { prefab = "cactus_flower", count = 6, label = L("仙人掌花", "Cactus Flower") },
            },
            rewards = {},
            random_count = 2,
        },
    
        -- ── 击杀类任务（保卫王国）────────────────────────────────
    
        {
            id         = "quest_kill_hounds",
            name       = L("驱逐猎犬", "Drive Off Hounds"),
            desc       = L(
                "该死的猎犬总是半夜在城外嚎叫，吵得本公主睡不好美容觉！\n去消灭它们，拿些狗牙回来，本公主要做成项链。",
                "Accursed hounds howl outside the walls and ruin the princess's beauty sleep!\nSlay them and bring back teeth. Wilba shall make a necklace."
            ),
            objectives = {
                { prefab = "hound", count = 2, label = L("猎犬", "Hound"), is_kill = true },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_kill_tentacles",
            name       = L("沼泽除害", "Swamp Pest Control"),
            desc       = L(
                "沼泽的触手怪总是偷袭本公主的臣民，是可忍孰不可忍！\n去砍掉它们的触手，拿些斑点触手皮回来当门帘。",
                "The tentacles in the swamp ever ambush the princess's subjects. 'Tis intolerable!\nCut down their appendages and bring back spotted tentacle hides for curtains."
            ),
            objectives = {
                { prefab = "tentacle", count = 4, label = L("触手怪", "Tentacle"), is_kill = true },
            },
            rewards = {},
            random_count = 3,
        },

        {
            id         = "quest_craft_crown",
            name       = L("打造新王冠", "Forge a New Crown"),
            desc       = L(
                "本公主的旧王冠看腻了，想要一顶全新的、镶满宝石的华丽王冠！\n去收集金块和红宝石，找铁匠打造一顶吧～",
                "The princess tireth of her old crown. She desireth a new one, studded with gems!\nGather gold and rubies for the blacksmith to forge."
            ),
            objectives = {
                { prefab = "goldnugget", count = 12, label = L("金块", "Gold Nugget") },
                { prefab = "redgem",     count = 2,  label = L("红宝石", "Red Gem") },
            },
            rewards = {},
            random_count = 2,
        },
    
        {
            id         = "quest_craft_umbrella",
            name       = L("皇家遮阳伞", "Royal Parasol"),
            desc       = L(
                "太阳太大，会晒伤本公主娇嫩的皮肤。\n去收集些猪皮，给本公主做一把华美的遮阳伞！",
                "The sun is too harsh and would burn the princess's tender skin.\nGather pig skins and silk to craft a magnificent parasol for Wilba!"
            ),
            objectives = {
                { prefab = "pigskin", count = 1, label = L("猪皮", "Pig Skin") },
            },
            rewards = {},
            random_count = 1,
        },
    
        {
            id         = "quest_craft_lantern",
            name       = L("宫廷灯笼", "Court Lantern"),
            desc       = L(
                "本公主的晚宴需要一些浪漫的灯光。\n帮吾做几盏提灯，要金边的那种！",
                "The princess's banquet needeth romantic lighting.\nMake for her several lanterns, with golden rims!"
            ),
            objectives = {
                { prefab = "lantern", count = 2, label = L("提灯", "Lantern") },
            },
            rewards = {},
            random_count = 2,
        },
    
        {
            id         = "quest_craft_sewingkit",
            name       = L("缝补礼服", "Mend the Gown"),
            desc       = L(
                "本公主最喜欢的晚礼服被树枝刮破了，心痛！\n做一套缝纫包来，本公主要亲自缝补（或者你帮我缝）。",
                "The princess's favorite evening gown hath been torn by a branch! Heartbreak!\nMake a sewing kit that Wilba (or thou) may mend it."
            ),
            objectives = {
                { prefab = "sewing_kit", count = 1, label = L("缝纫包", "Sewing Kit") },
            },
            rewards = {},
            random_count = 1,
        },
    
    
        {
            id         = "quest_explore_ruins",
            name       = L("远古遗迹探险", "Ancient Ruins Expedition"),
            desc       = L(
                "本公主听说地下有远古文明的宝藏，有闪闪发光的铥矿和宝石！\n你去冒险一趟，把那些亮晶晶的东西给本公主带回来！",
                "The princess hath heard of buried treasure in the ancient ruins: gleaming thulecite and gems!\nUndertake this adventure and bring back the shinies for Wilba!"
            ),
            objectives = {
                { prefab = "thulecite", count = 1, label = L("铥矿", "Thulecite") },
                { prefab = "purplegem", count = 1, label = L("紫宝石", "Purple Gem") },
            },
            rewards = {},
            random_count = 3,
        },
    
        {
            id         = "quest_visit_moon_island",
            name       = L("月亮岛之旅", "Journey to the Moon Island"),
            desc       = L(
                "月亮碎片落下来，变成了一个小岛！本公主要那里的月亮宝石做装饰。\n造一艘船，去岛上挖些月亮宝石回来！",
                "Fragments of the moon have fallen to form an isle! The princess desireth moon gems from that place.\nBuild a boat and sail there to mine moon rocks for Wilba!"
            ),
            objectives = {
                { prefab = "moonrocknugget", count = 2, label = L("月岩", "Moon Rock") },
            },
            rewards = {},
            random_count = 1,
        },
        {
            id         = "quest_collect_beardhair",
            name       = L("皇家胡须原料", "Royal Beard Hair"),
            desc       = L(
                "本公主的祖母留了一把长胡子，想要一顶胡须假发来怀念她。\n威尔逊那家伙不肯剃胡子，你去帮本公主收集些胡子吧——可以从兔子身上找，或者…把威尔逊绑起来？",
                "The princess's grandmother kept a long beard, and she desireth a wig to remember her.\nWilson will not shave his beard. Prithee, gather beard hair for Wilba — from rabbits, or... tie Wilson down?"
            ),
            objectives = {
                { prefab = "beardhair", count = 6, label = L("胡须", "Beard Hair") },
            },
            rewards = {},
            random_count = 1,
        },

        {
            id         = "quest_craft_footballhat",
            name       = L("猪皮头盔", "Pigskin Helmet"),
            desc       = L(
                "本公主的皇家卫队需要统一装备，猪皮帽既结实又威风！\n去收集猪皮和绳子，让铁匠打几顶出来。",
                "The princess's royal guard needeth uniform gear. A pigskin helmet is sturdy and fearsome!\nGather pig skins and rope, and have the smith craft several."
            ),
            objectives = {
                { prefab = "pigskin", count = 1, label = L("猪皮", "Pig Skin") },
                { prefab = "rope",    count = 1, label = L("绳子", "Rope") },
            },
            rewards = {},
            random_count = 2,
        },
        -- ── 击杀 BOSS 任务（春季：麋鹿鹅）──────────────────────

    {
        id         = "quest_kill_moosegoose",
        name       = L("春季祸害：麋鹿鹅", "Spring Menace"),
        desc       = L(
            "每年春天那只大鹅都来本公主的池塘边孵蛋，还赶走本宫要观赏的天鹅！\n去教训它一顿，最好把它赶走，拿它的羽毛回来做扇子。",
            "Every spring that giant goose cometh to the princess's pond to nest, chasing away the swans!\nTeach it a lesson. Drive it off, and bring its feathers back for a fan."
        ),
        objectives = {
            { prefab = "moosegoose", count = 1, label = L("麋鹿鹅", "Moose/Goose"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },

     -- ── 击杀 BOSS 任务（夏季：蚁狮）────────────────────────

    {
        id         = "quest_kill_antlion",
        name       = L("夏季祸害：蚁狮", "Summer Menace"),
        desc       = L(
            "那只地下的蚁狮一到夏天就发脾气，把本公主的花园砸得坑坑洼洼！连池塘里的水都干涸了！\n快去沙漠里找到它的巢穴，把它教训一顿，让它别再乱砸了！",
            "That underground antlion throweth tantrums every summer, cratering the princess's garden and drying up her pond!\nHaste to its lair in the desert and teach it a lesson, that it may cease its destruction!"
        ),
        objectives = {
            { prefab = "antlion", count = 1, label = L("蚁狮", "Antlion"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },

    -- ── 击杀 BOSS 任务（秋季：熊獾）────────────────────────

    {
        id         = "quest_kill_bearger",
        name       = L("秋季捣蛋鬼", "Autumn Pest"),
        desc       = L(
            "那只大熊獾一到秋天就翻本公主的垃圾桶，还偷吃蜂蜜！\n它皮糙肉厚，但本公主相信你的实力。去把它打趴下，毛皮留下做地毯。",
            "That great bearger rummageth through the princess's trash every autumn and stealeth her honey!\nIts hide is thick, but the princess believeth in thy might. Knock it down and bring its fur for a rug."
        ),
        objectives = {
            { prefab = "bearger", count = 1, label = L("熊獾", "Bearger"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },

    -- ── 击杀 BOSS 任务（冬季：巨鹿）────────────────────────

    {
        id         = "quest_kill_deerclops",
        name       = L("冬季灾星", "Winter Calamity"),
        desc       = L(
            "那只独眼巨鹿每次来都要踩坏本公主的雕像，还把冰渣甩到本宫窗上！\n你带人去把它眼睛挖出来，本公主要镶在权杖上。",
            "That one-eyed giant deer ever crushes the princess's statues when it cometh, and splattereth ice upon her window!\nTake a party and gouge out its eye. The princess shall set it in her scepter."
        ),
        objectives = {
            { prefab = "deerclops", count = 1, label = L("巨鹿", "Deerclops"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },

    -- ── 击杀 BOSS 任务（蜂后）──────────────────────────────

    {
        id         = "quest_kill_beequeen",
        name       = L("蜂后", "Bee Queen"),
        desc       = L(
            "蜂后带着她的工蜂占据了本公主最喜欢的野花园！本公主的臣民都不敢去采蜜了。\n你去端了那个蜂窝，把蜂后打败，拿些蜂王浆回来，本公主想尝尝～",
            "The Bee Queen and her workers have seized the princess's favorite wildflower garden! Her subjects dare not gather honey anymore.\nDestroy that hive and defeat the queen. Bring back royal jelly, for the princess would taste it～"
        ),
        objectives = {
            { prefab = "beequeen", count = 1, label = L("蜂后", "Bee Queen"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },
        -- ── 击杀 BOSS 任务（龙蝇）────────────────────────────

    {
        id         = "quest_kill_dragonfly",
        name       = L("龙蝇", " Dragonfly"),
        desc       = L(
            "本公主听说沙漠岩浆池里住着一只巨大龙蝇，浑身冒着火焰，连它身边的小虫子都凶得很！\n本公主的探险队想靠近那儿的矿石都做不到。勇士啊，替本公主去把那大虫子收拾了！它的鳞片可是上等的防火材料～",
            "The princess hath heard of a great dragonfly dwelling in the desert magma pools, wreathed in flame, its minions most ferocious!\nThe princess's expedition cannot even approach the ore there. Brave one, slay that great insect for Wilba! Its scales are finest fireproof material～"
        ),
        objectives = {
            { prefab = "dragonfly", count = 1, label = L("龙蝇", "Dragonfly"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },

    {
        id         = "quest_kill_webber",
        name       = L("讨伐蜘蛛韦伯", "Hunt the Spider Webber"),
        desc       = L(
            "韦伯那个蜘蛛最近在蜘蛛巢附近作乱，吓得本公主的臣民不敢出门！\n冒险家，去收拾他一顿，让他知道猪人镇不是好惹的！\n\n※ 韦伯在玩家攻击2级或3级蜘蛛巢时有概率出现",
            "Webber, the spider-child, maketh mischief near the spider dens and terrifieth mine subjects!\nBrave one, teach him a lesson — show him Pig Town is not to be trifled with!\n\n※ Webber may appear when attacking a tier-2 or tier-3 spider den"
        ),
        objectives = {
            { prefab = "npcfriend", _npc_char_type = "webber", count = 1, label = L("韦伯", "Webber"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },

    {
        id         = "quest_kill_wurt",
        name       = L("教训鱼人沃特", "Subdue the Merm Wurt"),
        desc       = L(
            "沃特那个鱼人在鱼人房子旁边晃悠，还对本公主出言不逊！\n去给她点教训，让她知道这儿谁说了算！\n\n※ 沃特在鱼人房子附近出现",
            "Wurt, the insolent merm , doth loiter near the merm houses and speaketh rudely to the princess!\nPrithee, remind her who ruleth these lands!\n\n※ Wurt appears near merm houses"
        ),
        objectives = {
            { prefab = "npcfriend", _npc_char_type = "wurt", count = 1, label = L("沃特", "Wurt"), is_kill = true },
        },
        rewards = {},
        random_count = 3,
    },


    {
        id         = "quest_for_wilson_meat",
        name       = L("威尔逊的实验加餐", "Wilson's Lab Snacks"),
        desc       = L(
            "威尔逊又在实验室念叨，说什么对照组得「有鸡有肉」才靠谱——本公主听得云里雾里，反正就是要肉。\n你去弄几块新鲜生肉来，别拿怪物肉凑数；他要是吃坏了肚子，本公主可饶不了你。",
            "Wilson muttereth in his laboratory that control groups need 'meat and substance' to be valid — the princess understandeth meat, not science.\nBring fresh raw meat, no monster flesh; if he falls ill, thou shalt answer to Wilba."
        ),
        objectives = {
            { prefab = "meat", count = 3, label = L("生肉", "Raw Meat") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wendy_flowers",
        name       = L("温蒂的小花开导", "Flowers for Wendy"),
        desc       = L(
            "温蒂这两天老一个人小声嘀咕，听着跟远处鸟叫似的，咕咕嘎嘎没完，怪让人心疼的。\n本公主想给她扎束花——你去采些花瓣，颜色鲜亮些，让她心情也能跟着亮一点。",
            "Wendy hath whispered to herself for days, soft as distant birds — the princess's heart heaveth.\nGather bright petals for a bouquet, that her spirits may lift a little."
        ),
        objectives = {
            { prefab = "petals", count = 6, label = L("花瓣", "Petals") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wathgrithr_gold",
        name       = L("女武神的金边战利品", "Gold for the Valkyrie"),
        desc       = L(
            "薇格弗德嚷嚷说盔甲不镶金就不威风，嗓门大得本公主耳朵发麻。\n本公主懒得跟她比音量——你去挖些金块，说是战利品也好、封口费也罢，让她别在宫殿门口练战吼了。",
            "Wigfrid declareth her armor must have gold or it lacketh glory, shouting loud enough to shake the palace.\nMine gold nuggets for her — call it spoils or hush money, so she may cease her drills at the gates."
        ),
        objectives = {
            { prefab = "goldnugget", count = 5, label = L("金块", "Gold Nugget") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wolfgang_meat",
        name       = L("喂饱大个子", "Feed the Strongman"),
        desc       = L(
            "沃尔夫冈又在喊饿，说是「家人还没开饭，胃先抗议了」——本公主只听懂后半句：很吵。\n你去弄些大肉来，让他填饱就行，别让他再盯着本公主的午点流口水。",
            "Wolfgang roareth hunger again — the princess heareth only that it is loud.\nBring raw meat, fill his belly, and keep his eyes off the royal luncheon."
        ),
        objectives = {
            { prefab = "meat", count = 6, label = L("生肉", "Raw Meat") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wormwood_seeds",
        name       = L("小树人的花园计划", "Wormwood's Garden Plan"),
        desc       = L(
            "小树人指着御花园说，要种得「绝绝子」好看——本公主不懂他一个词里怎么有三个绝，但懂种子。\n你去弄些种子来，帮他把土铺好；别踩到本公主刚修好的花坛边。",
            "Wormwood pointed at the royal garden and said it must look 'absolutely perfect' — three words the princess doth not grasp, but seeds she understandeth.\nBring seeds, and mind the flowerbed edges the princess hath just trimmed."
        ),
        objectives = {
            { prefab = "seeds", count = 5, label = L("种子", "Seeds") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_waxwell_fuel",
        name       = L("麦斯威尔的暗影原料", "Maxwell's Shadow Supplies"),
        desc       = L(
            "麦斯威尔跟影子仆从嘀咕了一宿，仆从们吓得直哆嗦，本公主看着都替他们汗流浃背。\n他说缺噩梦燃料做实验——听着就不正经，但镇上总要太平。你去弄些来，离本公主的枕头远点放。",
            "Maxwell whispered to his shadows all night; the servants trembled, and the princess sweated for them.\nHe needeth nightmare fuel — dubious, yet peace matters. Fetch some, and place it far from the royal pillows."
        ),
        objectives = {
            { prefab = "nightmarefuel", count = 2, label = L("噩梦燃料", "Nightmare Fuel") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_willow_charcoal",
        name       = L("薇洛的城外篝火许可", "Willow's Outdoor Fire Permit"),
        desc       = L(
            "薇洛看本公主宫殿的眼神，总像在掂量哪儿点得着。本公主跟她谈妥了：城外你爱怎么烧怎么烧，木炭拿去。\n只要别冲本公主的帘子笑，也别问「这帘子 city 不 city」——本公主只想要个安稳午觉。",
            "Willow eyeth the palace as though measuring what might burn. The princess hath bargained: burn what thou wilt outside the walls, and take charcoal.\nTouch not the silk drapes, ask not if they are 'flammable chic' — the princess desireth only her nap."
        ),
        objectives = {
            { prefab = "charcoal", count = 6, label = L("木炭", "Charcoal") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wickerbottom_papyrus",
        name       = L("老奶奶的书架急救", "Wickerbottom's Shelf Rescue"),
        desc       = L(
            "薇克巴顿说书架快要「知识超载」，少莎草纸不行，语气跟本公主欠她似的。\n本公主虽然不爱被她教训，但书真倒了也是麻烦——你去弄些莎草纸，顺便告诉她：本公主的美貌不需要脚注。",
            "Wickerbottom claimeth her shelves suffer 'knowledge overload' and demandeth papyrus, as though the princess owed her.\nBring papyrus lest the tomes fall — and tell her Wilba's beauty needeth no footnotes."
        ),
        objectives = {
            { prefab = "papyrus", count = 1, label = L("莎草纸", "Papyrus") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wortox_honey",
        name       = L("沃托克斯的赔礼蜂蜜", "Wortox's Apology Honey"),
        desc       = L(
            "沃托克斯被蜜蜂追得满镇跑，本公主差点没忍住笑——他自己还说绷不住了。\n现在他要拿蜂蜜去赔礼，你去弄些来，让他把嘴管住，别见谁就抛冷笑话。",
            "Wortox fled bees through the town; the princess nearly laughed — he swore he could not hold it in.\nHe now seeketh honey to make amends. Fetch some, that he may cease his jests upon every soul."
        ),
        objectives = {
            { prefab = "honey", count = 2, label = L("蜂蜜", "Honey") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wanda_gold",
        name       = L("旺达的修表金料", "Gold for Wanda's Watch"),
        desc       = L(
            "旺达抱着怀表叹气：「真的假的，又慢半拍。」本公主听得都替她累。\n她说修表还缺金块——你去弄些来，手脚轻点，别碰那些叮当响的小零件。",
            "Wanda sighed over her pocket watch: 'Truly, it laggeth again.' The princess tireth just listening.\nShe needeth gold for repairs — bring nuggets, tread softly, touch not the tinkling parts."
        ),
        objectives = {
            { prefab = "goldnugget", count = 4, label = L("金块", "Gold Nugget") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_walter_trailmix",
        name       = L("沃尔特的路上干粮", "Walter's Trail Snacks"),
        desc       = L(
            "沃尔特带着修狗回来，张口就是一段「对猪弹琴」的冒险故事——本公主没听懂，只听懂他半路饿坏了。\n你去弄些什锦干果，让他下次出门自己掂着，别讲完故事就来蹭御厨房。",
            "Walter returned with his pup and launched a tale of 'legendary' adventure — the princess caught only that he starved midway.\nBring trail mix, that he may carry his own rations and spare the royal pantry."
        ),
        objectives = {
            { prefab = "trailmix", count = 1, label = L("什锦干果", "Trail Mix") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wonkey_banana",
        name       = L("猴子的三日和平条约", "The Monkey's Three-Day Truce"),
        desc       = L(
            "那只猴子盯着本公主的银器，眼睛眨得跟报信似的。他说只要香蕉就老实三天——本公主将信将疑。\n你去寻些洞穴香蕉来，盯紧他，别让他顺手牵羊王冠上的装饰。",
            "The monkey eyed the royal silver, blinking like an alarm. He vowed three days' peace for bananas — the princess doubteth, yet trieth.\nFetch cave bananas, and watch he doth not pluck gems from the crown."
        ),
        objectives = {
            { prefab = "cave_banana", count = 2, label = L("洞穴香蕉", "Cave Banana") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wes_paint",
        name       = L("韦斯的肖像颜料", "Wes's Portrait Supplies"),
        desc       = L(
            "韦斯比划着要为本公主画像，上次画成火柴人，本公主真是哭笑不得。\n你去弄些木炭和蝴蝶翅膀当颜料——画成啥样本公主都认了，别再比划一半跑路。",
            "Wes gestured he would paint the princess — last time, a stick figure. The princess laughed and wept.\nBring charcoal and butterfly wings for pigment; whatever the result, let him not flee mid-stroke."
        ),
        objectives = {
            { prefab = "charcoal",       count = 3, label = L("木炭", "Charcoal") },
            { prefab = "butterflywings", count = 1, label = L("蝴蝶翅膀", "Butterfly Wings") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_winona_boards",
        name       = L("薇诺娜的工坊木板", "Winona's Workshop Lumber"),
        desc       = L(
            "薇诺娜说工坊缺木板，再拖下去就要摸鱼了——本公主不懂这词，但懂催工。\n你去弄些木板来，让她把那些吱呀响的设备修好，别半夜吵本公主睡觉。",
            "Winona claimeth the workshop lacketh boards and work shall 'coast to a halt' — new words, yet the princess understandeth delay.\nBring boards, that she may fix her squealing machines and spare the royal sleep."
        ),
        objectives = {
            { prefab = "boards", count = 2, label = L("木板", "Boards") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_warly_potato",
        name       = L("沃利的新菜试锅", "Warly's Test Potatoes"),
        desc       = L(
            "沃利又研发新菜，非要本公主第一个尝。本公主宁可你替他试——你去弄几个土豆，让他先在小锅里折腾。\n别端一整锅来吓侍卫，本公主只想安安静静喝下午茶。",
            "Warly hath devised a new dish and would have the princess taste it first. The princess preferreth thee as taster — bring potatoes for his small pot.\nLet him not march a cauldron past the guards; the princess desireth only her tea."
        ),
        objectives = {
            { prefab = "potato", count = 4, label = L("土豆", "Potato") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_wx78_gears",
        name       = L("WX-78的美学升级", "WX-78's Aesthetic Upgrade"),
        desc       = L(
            "WX-78先说本公主的皇冠「有机低效」，气得本公主差点回嘴；转头又说要齿轮升级「审美模块」。\n呵，你去弄些齿轮，看看这铁罐头能不能学会夸人一句。",
            "WX-78 called the crown 'organically inefficient' — the princess nearly replied in kind; then demanded gears for an 'aesthetic module.'\nFetch gears, and see if the tin can learn one compliment."
        ),
        objectives = {
            { prefab = "gears", count = 1, label = L("齿轮", "Gears") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_for_woodie_logs",
        name       = L("伍迪的斧柄急救", "Woodie's Axe Handle Rescue"),
        desc       = L(
            "伍迪说斧柄裂了，再劈下去手上要「芭比Q」——本公主听得懂，就是会烫手。\n你去弄些原木，让他离本公主的木雕远一点劈；修好了再来谢恩。",
            "Woodie said his axe haft cracked — another chop would 'barbecue' his hands. The princess understandeth: pain.\nBring logs for repair, and bid him chop far from the princess's carvings."
        ),
        objectives = {
            { prefab = "log", count = 8, label = L("原木", "Logs") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_lore_winter_ice_cellar",
        name       = L("冬夜冰窖", "The Winter Ice Cellar"),
        desc       = L(
            "昨夜北风一过，护城河结了一层薄冰，老臣说巨鹿的脚步声曾在镇外响起。\n本公主不怕它踩坏雕像——怕的是臣民过冬没存粮、没存冰。去采些冰块放进冰窖，等长夜来了，御厨还能给老人煮一碗热汤。",
            "Last night the north wind froze the moat, and elders swear Deerclops's tread echoed beyond the walls.\nThe princess feareth not crushed statues, but empty larders in the long cold. Gather ice for the cellar, that the cooks may yet warm the aged when winter deepens."
        ),
        objectives = {
            { prefab = "ice", count = 8, label = L("冰块", "Ice") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_lore_cave_farm_light",
        name       = L("洞窟农人的灯", "Lights for the Cave Farmers"),
        desc       = L(
            "镇东有几户人家把蘑菇种在地洞里，说那里长得快，可没有光，人待久了心里发慌。\n本公主听过荧光果的传闻——地下长出的那点绿光，像星星掉进土里。去采些荧光果，替他们把路照亮，别让黑暗把希望也收走了。",
            "East of town, families grow mushrooms below, where crops thrive yet hearts grow fearful without light.\nThe princess hath heard of glow berries — green stars fallen into soil. Gather them, light their paths, and let not the dark take hope as well."
        ),
        objectives = {
            { prefab = "lightbulb", count = 6, label = L("荧光果", "Light Bulb") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_lore_beefalo_cloak",
        name       = L("野牛群的暖夜", "Warmth from the Beefalo Herds"),
        desc       = L(
            "迁徙的野牛群昨夜从荒原经过，蹄声震得城墙灰都落下来。侍卫长说，若没有牛毛御寒，守夜的臣民熬不过霜晨。\n本公主记得小时候，祖母用野牛毛给吾缝过披肩。你去寻些牛毛来，让守夜人也能裹上一点旧日的温暖。",
            "A beefalo herd crossed the wastes last night, hooves shaking dust from the walls. The captain saith without wool, the night watch shall perish at frost dawn.\nThe princess remembereth her grandmother's cloak of beefalo fur. Bring wool, that the watchers may know such warmth again."
        ),
        objectives = {
            { prefab = "beefalowool", count = 3, label = L("牛毛", "Beefalo Wool") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_lore_swamp_merchant_memorial",
        name       = L("沼泽商路的纪念", "Memorial on the Swamp Road"),
        desc       = L(
            "半月前走沼泽商路的那队人，再没回来。只在岸边找到破篮子和一点触手皮。\n本公主要在桥头立一块小碑，让后人记得：沼泽会吃人，也会留下教训。去取些触手皮与芦苇，臣民会把它扎成花圈，祭在路口。",
            "A caravan took the swamp road a fortnight past and never returned — only a broken basket and scraps of tentacle hide upon the shore.\nThe princess shall raise a small stone at the bridge, that all remember: the marsh taketh, and teacheth. Bring tentacle spots and reeds for the wreath upon the crossing."
        ),
        objectives = {
            { prefab = "tentaclespots", count = 2, label = L("触手皮", "Tentacle Spots") },
            { prefab = "cutreeds",      count = 4, label = L("芦苇", "Reeds") },
        },
        rewards = {},
        random_count = 2,
    },


    {
        id         = "quest_absurd_royal_soil",
        name       = L("御土采购计划", "The Royal Soil Programme"),
        desc       = L(
            "占星师昨夜观星，说本公主的玫瑰缺一种「大地呼吸过的金色微粒」。\n臣民小声说那就是粪便——荒谬！在本公主这里，它叫御土。",
            "The court astrologer swore the roses lacked 'golden grains breathed by the earth.'\nPeasants whisper 'tis dung — preposterous! In Wilba's realm it is Royal Soil. "
        ),
        objectives = {
            { prefab = "poop", count = 5, label = L("御土", "Royal Soil") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_absurd_butter_omen",
        name       = L("黄油神谕", "The Butter Omen"),
        desc       = L(
            "本公主梦见一只蝴蝶在牛背上滑冰，醒来就悟了：王国缺一块黄油。\n书上说黄油极难出现，那正好——若你真能弄来一块，说明天意站在本公主这边；若没有，说明天意迟到了，你再去弄一块。",
            "Wilba dreamt a butterfly skated upon a cow, and awoke enlightened: the realm lacketh butter.\nThey say butter is rare — perfect. Shouldst thou bring one, fate favoureth the princess; if not, fate is late, and thou shalt fetch one anyway."
        ),
        objectives = {
            { prefab = "butter", count = 1, label = L("黄油", "Butter") },
        },
        rewards = {},
        random_count = 2,
    },

    {
        id         = "quest_absurd_monster_afternoon_tea",
        name       = L("怪物肉下午茶", "Monster Meat Afternoon Tea"),
        desc       = L(
            "本公主要在凉亭办一场「优雅」茶会：越难吃，越显得我们有勇气。\n怪物肉当主菜，蜂蜜当漱口水——你别问逻辑，问就是艺术。去弄些怪物肉，记得别烹熟，生猛才抽象。",
            "The princess shall host a tea of 'reverse elegance': the worse it tasteth, the braver we seem.\nMonster meat for mains, honey to rinse — ask not the logic, 'tis art. Bring raw monster flesh; cooked is far too comprehensible."
        ),
        objectives = {
            { prefab = "monstermeat", count = 3, label = L("怪物肉", "Monster Meat") },
        },
        rewards = {},
        random_count = 1,
    },

    {
        id         = "quest_absurd_frog_bounce_theory",
        name       = L("蛙腿弹跳学说", "The Frog Leg Bounce Theory"),
        desc       = L(
            "宫廷学者提出学说：吃蛙腿不会变青蛙，但会忍不住单脚跳。\n本公主打算在阅兵式上验证——你先去弄些蛙腿，别问为什么不用腿，问就是学术严谨。若跳不起来，那就是你吃得不够。",
            "Court scholars propose: frog legs turn thee not into a frog, yet compel one-legged hopping.\nThe princess shall test this at the parade — fetch frog legs. Ask not why not whole frogs; 'tis scientific rigour. If thou hoppest not, thou didst not eat enough."
        ),
        objectives = {
            { prefab = "froglegs", count = 4, label = L("蛙腿", "Frog Legs") },
        },
        rewards = {},
        random_count = 1,
    },

    -- ── 特殊任务：帮薇洛打造打火机 ─────────────────────────────
    {
        id         = "quest_craft_lighter_for_willow",
        name       = L("给薇洛制作一个打火机", "Forge a Lighter for Willow"),
        desc       = L(
            "那个叫薇洛的丫头又在嘟囔她的打火机了，听说给她打火机之后实力会提升。\n你弄一颗红宝石来，本公主让工匠给她打造一个打火机——拿去给她，好让她安静点，别老盯着本公主的烛台。",
            "Willow the girl muttereth again about her lighter — and 'tis said her power groweth once she beareth one.\nBring a single red gem, and Wilba shall have the smith forge her a lighter — give it to her, that she may quiet down and cease eyeing the royal candelabra."
        ),
        objectives = {
            { prefab = "redgem", count = 1, label = L("红宝石", "Red Gem") },
        },
        rewards = {
            { prefab = "lighter", count = 1, label = L("打火机", "Lighter") },
        },
        random_count = 0,
        special = "willow_lighter",
    },

}

-- ════════════════════════════════════════════════════════════
--  随机奖励池
--  每日任务刷新时，根据 quest.random_count 从此池抽取额外奖励
--  权重越高越常见，不写 weight 默认 10
-- ════════════════════════════════════════════════════════════

QuestData.RANDOM_REWARDS = {


    { prefab = "poop",       count = 1, weight = 5,  label_cn = "粪便",     label_en = "Poop" },
    { prefab = "walrus_tusk",count = 1, weight = 5,  label_cn = "海象牙",   label_en = "Walrus Tusk" },
    { prefab = "redgem",     count = 1, weight = 5,  label_cn = "红宝石",   label_en = "Red Gem" },
    { prefab = "bluegem",    count = 1, weight = 5,  label_cn = "蓝宝石",   label_en = "Blue Gem" },
    { prefab = "purplegem",  count = 1, weight = 5,  label_cn = "紫宝石",   label_en = "Purple Gem" },
    { prefab = "yellowgem",  count = 1, weight = 5,  label_cn = "黄宝石",   label_en = "Yellow Gem" },
    { prefab = "orangegem",  count = 1, weight = 5,  label_cn = "橙宝石",   label_en = "Orange Gem" },
    { prefab = "greengem",   count = 1, weight = 5,  label_cn = "绿宝石",   label_en = "Green Gem" },
    { prefab = "thulecite",  count = 1, weight = 5,  label_cn = "铥矿石",   label_en = "Thulecite" }, 
    { prefab = "dreadstone", count = 1, weight = 5,  label_cn = "绝望石",   label_en = "Dreadstone" }, 
    { prefab = "purebrilliance", count = 1, weight = 5,  label_cn = "纯粹辉煌",   label_en = "Pure Brilliance" },
    { prefab = "amulet",     count = 1, weight = 5,  label_cn = "重生护符", label_en = "LifeGivingAmulet" },
    { prefab = "lightninggoathorn", count = 1, weight = 5,  label_cn = "伏特羊角", label_en = "Lightning Goat Horn" },
    { prefab = "goatmilk", count = 1, weight = 5,  label_cn = "电羊奶", label_en = "Goat Milk" },
    { prefab = "butter", count = 1, weight = 5,  label_cn = "黄油", label_en = "Butter" },
    { prefab = "ruinshat", count = 1, weight = 5,  label_cn = "铥矿皇冠", label_en = "Thulecite Crown" },
    { prefab = "horrorfuel", count = 1, weight = 5,  label_cn = "纯粹恐惧", label_en = "Pure Horror" },
    { prefab = "milkywhites", count = 1, weight = 5,  label_cn = "乳白物", label_en = "Milky Whites" },
    { prefab = "royal_jelly", count = 1, weight = 5,  label_cn = "蜂王浆", label_en = "Royal Jelly" },
    { prefab = "staff_tornado", count = 1, weight = 5,  label_cn = "天气风向标", label_en = "Staff of Tornado" },
    { prefab = "icestaff", count = 1, weight = 5,  label_cn = "冰法杖", label_en = "Ice Staff" },
    { prefab = "blowdart_sleep", count = 5, weight = 5,  label_cn = "催眠吹箭", label_en = "Sleep Blowdart" },
    { prefab = "blowdart_yellow", count = 5, weight = 5,  label_cn = "雷电吹箭", label_en = "Yellow Blowdart" },

    { prefab = "jungletreeseed",       count = 1, weight = 5, label_cn = "丛林树种子",   label_en = "Jungle Tree Seed" },
    { prefab = "teatree_nut",          count = 1, weight = 5, label_cn = "茶树果",       label_en = "Tea Tree Nut" },
    { prefab = "clawpalmtree_sapling", count = 1, weight = 5, label_cn = "爪棕榈树苗",   label_en = "Claw Palm Sapling" },

    { prefab = "npc_heart", count = 1, weight = 5,  label_cn = "生命", label_en = "Heart" },
    { prefab = "npc_sword", count = 1, weight = 5,  label_cn = "战意", label_en = "Sword" },

    { prefab = "turf_pigruins",                count = 4, weight = 5, label_cn = "猪人遗迹地皮",       label_en = "Pig Ruins Turf" },
    { prefab = "turf_rainforest",              count = 4, weight = 5, label_cn = "雨林地皮",           label_en = "Rainforest Turf" },
    { prefab = "turf_deeprainforest",          count = 4, weight = 5, label_cn = "深雨林地皮",         label_en = "Deep Rainforest Turf" },
    { prefab = "turf_lawn",                    count = 4, weight = 5, label_cn = "草坪地皮",           label_en = "Lawn Turf" },
    { prefab = "turf_gasjungle",               count = 4, weight = 5, label_cn = "毒气丛林地皮",       label_en = "Gas Jungle Turf" },
    { prefab = "turf_moss",                    count = 4, weight = 5, label_cn = "苔藓地皮",           label_en = "Moss Turf" },
    { prefab = "turf_fields",                  count = 4, weight = 5, label_cn = "农田地皮",           label_en = "Fields Turf" },
    { prefab = "turf_foundation",              count = 4, weight = 5, label_cn = "基石地皮",           label_en = "Foundation Turf" },
    { prefab = "turf_cobbleroad",              count = 4, weight = 5, label_cn = "鹅卵石路地皮",       label_en = "Cobblestone Road Turf" },
    { prefab = "turf_painted",                 count = 4, weight = 5, label_cn = "彩绘地皮",           label_en = "Painted Turf" },
    { prefab = "turf_plains",                  count = 4, weight = 5, label_cn = "平原地皮",           label_en = "Plains Turf" },
    { prefab = "turf_beard_hair",              count = 4, weight = 5, label_cn = "胡须地毯地皮",       label_en = "Beard Hair Rug Turf" },
    { prefab = "turf_deeprainforest_nocanopy", count = 4, weight = 5, label_cn = "深雨林(无树冠)地皮", label_en = "Deep Rainforest (No Canopy) Turf" },



}

--- 从随机奖励池加权抽取一个奖励
--- @return {prefab, count, label}
function QuestData.DrawRandomReward()
    local pool = QuestData.RANDOM_REWARDS
    local total_weight = 0
    for _, r in ipairs(pool) do
        total_weight = total_weight + (r.weight or 10)
    end
    local roll = math.random() * total_weight
    local cumulative = 0
    for _, r in ipairs(pool) do
        cumulative = cumulative + (r.weight or 10)
        if roll <= cumulative then
            return { prefab = r.prefab, count = r.count, label = L(r.label_cn, r.label_en) }
        end
    end
    return { prefab = "goldnugget", count = 1, label = L("金块", "Gold Nugget") }
end

-- ════════════════════════════════════════════════════════════
--  工具函数
-- ════════════════════════════════════════════════════════════

--- 根据ID获取任务定义
function QuestData.GetDef(quest_id)
    for _, def in ipairs(QuestData.DEFS) do
        if def.id == quest_id then
            return def
        end
    end
    return nil
end

--- 获取所有任务ID列表
function QuestData.GetAllIds()
    local ids = {}
    for _, def in ipairs(QuestData.DEFS) do
        ids[#ids + 1] = def.id
    end
    return ids
end

--- 随机选取N个不重复的任务
function QuestData.GetRandomQuests(count, exclude_ids)
    exclude_ids = exclude_ids or {}
    local exclude_set = {}
    for _, id in ipairs(exclude_ids) do
        exclude_set[id] = true
    end

    local pool = {}
    for _, def in ipairs(QuestData.DEFS) do
        -- special 任务（如薇洛打火机）不进普通随机池，由管理器按条件注入
        if not exclude_set[def.id] and not def.special then
            pool[#pool + 1] = def
        end
    end

    -- 随机洗牌
    for i = #pool, 2, -1 do
        local j = math.random(i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    -- 取前N个
    local result = {}
    for i = 1, math.min(count or 3, #pool) do
        result[#result + 1] = pool[i]
    end
    return result
end

return QuestData
