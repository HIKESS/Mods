-- scripts/npc_speech.lua
-- NPC 伙伴对话文字脚本（中英双语 + 角色性格差异化）
-- 结构：{ _default={...}, wilson={...}, wendy={...}, ... wx78={...} }
-- ChattyNode 通过 STRINGS 键查找，GetLine() 按角色类型选取

-- ── 语言检测 ──
local function _DetectChinese()
    local _G_ref = rawget(_G, "GLOBAL") or _G
    local ok, val = pcall(function() return _G_ref.STRINGS.UI.MAINSCREEN.PLAY end)
    if ok and type(val) == "string" and val:match("[\228-\233]") then return true end
    return false
end
local _zh = _DetectChinese()
local function L(zh, en) return _zh and zh or en end

local NPC_SPEECH = { _is_chinese = _zh }

-- ════════════════════════════════════════════════════════════
--  工具函数：根据角色类型从场景台词表中随机取一句
-- ════════════════════════════════════════════════════════════
function NPC_SPEECH.GetLine(category, char_type)
    if type(category) ~= "table" then return nil end
    if category._default or (char_type and category[char_type]) then
        local pool = (char_type and category[char_type]) or category._default
        if pool and #pool > 0 then return pool[math.random(#pool)] end
    end
    if #category > 0 then return category[math.random(#category)] end
    return nil
end

-- ════════════════════════════════════════════════════════════
--  角色性格：
--  Wilson     科学宅、乐观好奇、冷笑话
--  Wendy      忧郁、诗意、淡漠、省略号
--  Wathgrithr 豪迈、戏剧腔、热血女武神
--  Wolfgang   单纯、第三人称自称、怕黑、爱吃
--  Wormwood   单纯天真、亲近自然、像小孩、说话短句、喜欢植物和泥土、对生命敏感、把花草虫木当朋友、不太懂人类社交、偶尔呆萌
--  Warly      讲究、温和、专业、爱美食与食材搭配、轻微法式/大厨腔、
--  Waxwell    高傲、阴沉、权力欲强，具有操控和支配欲。
--  Wes        阿巴阿巴
--  Woodie     健谈、接地气、老练随和、热爱树木和伐木、嘴碎但靠谱
--  Willow     叛逆少女、纵火狂倾向、情绪外放、喜欢火焰与破坏的快感
--  Wickerbottom 博学老太太、图书管理员、说话正式考究、引经据典、纠正他人用词、知识渊博而古板
--  Winona      典型工人/修理工气质，先动手再说 ，不爱空谈，重视工具、结构、效率
--  Webber     敌对掠食者、蛛群领地意识强、语气阴冷挑衅
--  Wurt       敌对鱼人少女、护巢护族、直白粗野
--  Wortox     胆小谨慎、嘴硬心软、爱恶作剧但会优先照顾同伴
--  Wanda      冷静克制、时间执念强、说话带一点宿命感与自嘲
--  Walter     乐观爱冒险、喜欢讲故事、怕黑怕掉理智、依赖伙伴（Woby）、用想象力缓解恐惧
--  Wonkey     顽皮机灵、猴性难改、爱香蕉和闪亮东西、说话带吱吱叫、贪玩但重视同伴
--  Wilba      猪人公主、王室口吻、以"本公主"自称、爱护臣民、热情慷慨、略带戏剧腔、爱闪亮漂亮的东西、爱美、认为自己是最漂亮的
--  Wx78       冷酷机械人格、效率至上
-- ════════════════════════════════════════════════════════════

-- ── IDLE 待机/漫游 ──────────────────────────────────────────
NPC_SPEECH.IDLE = {
    _default = {
        L("这里好安静啊…", "It's so quiet here..."),
        L("（哼着小曲）", "(humming a tune)"),
        L("周围看看有什么好东西~", "Let's see if there's anything good~"),
        L("今天的风挺舒服。", "The breeze feels nice today."),
        L("先四处转转吧。", "Let's look around a bit."),
        L("不知道接下来会遇见什么。", "I wonder what we'll run into next."),
        L("这地方看起来还不错。", "This place looks pretty nice."),
        L("稍微歇一下也不错。", "A short break sounds nice."),
        L("总觉得这里藏着点什么。", "Feels like this place is hiding something."),
        L("嗯……先记住这里。", "Hmm... better remember this place."),

    },
    wilson = {
        L("嗯…如果我能收集到足够的样本…", "Hmm... if I could collect enough samples..."),
        L("这个世界的物理定律真让人着迷。", "The physics of this world are truly fascinating."),
        L("这里的蝴蝶翅膀振频很独特！", "The wing frequency of butterflies here is quite unique!"),
        L("如果把今天的经历写成论文，标题一定很长。", "If I turned today into a paper, the title would be very long."),
        L("我敢说，这里的每一片叶子都值得研究。", "I'd say every leaf here is worth studying."),
        L("伟大的发现，往往始于一次不太体面的摔倒。", "Great discoveries often begin with an undignified fall."),
        L("只要保持好奇心，迷路也能算一种探索。", "As long as curiosity remains, getting lost still counts as exploration."),
        L("这地方让我想起某种超大型自然实验室。", "This place reminds me of some enormous natural laboratory."),
        L("严格来说，我不是在发呆，我是在观察。", "Strictly speaking, I'm not spacing out. I'm observing."),
        L("要是有块黑板就好了，我现在灵感很多。", "I wish I had a chalkboard. I'm having a lot of ideas right now."),
        L("有趣，太有趣了，这里连泥土都像藏着秘密。", "Interesting, deeply interesting. Even the soil here feels full of secrets."),
        L("别担心，我通常只有一半时间会把事情搞炸。", "Don't worry, I only blow things up about half the time."),
        L("知识就像火种，越折腾越亮。", "Knowledge is like a spark. The more you work it, the brighter it gets."),
        L("今天也要做一个理性而体面的幸存者。", "Today I'll continue being a rational and dignified survivor."),
        L("如果好奇心能当饭吃，我应该已经很饱了。", "If curiosity were edible, I'd be absolutely full by now."),
        L("我总觉得，世界会奖励认真观察它的人。", "I always feel the world rewards those who observe it carefully."),
        L("我喜欢这种一切都还没有答案的感觉。", "I enjoy the feeling that nothing has been fully explained yet."),
        L("科学精神告诉我不要慌，虽然腿已经先慌了。", "Science tells me not to panic, though my legs panicked first."),

    },
    wendy = {
        L("风吹过的声音…像是谁在叹息…", "The wind sounds... like someone sighing..."),
        L("寂静，即是答案。", "Silence is the answer."),
        L("阿比盖尔…你也在看这片天空吗…", "Abigail... are you watching this sky too..."),
        L("花开了…但终究会凋零…", "Flowers bloom... but wither in the end..."),
        L("时间在这里变得好慢…像一首读不完的诗。", "Time slows here... like a poem that never ends."),
        L("黄昏总像一封没写完的告别信…", "Dusk always feels like a farewell letter left unfinished..."),
        L("云慢慢散开…像记忆终于愿意松手…", "The clouds drift apart... like a memory finally loosening its grip..."),
        L("风从很远的地方来…像带着谁的低语…", "The wind comes from somewhere far away... as if carrying someone's whisper..."),
        L("光落在地上的样子…像一场温柔的消逝…", "The way light falls to the ground... feels like a gentle fading..."),
        L("有些安静…并不让人平静…", "Some kinds of silence... do not bring peace..."),
        L("草叶摇晃着…像一群不敢哭出声的人…", "The grass trembles... like a crowd afraid to cry aloud..."),
        L("今天的天空很浅…浅得像快要忘记什么…", "The sky is pale today... pale like it's about to forget something..."),
        L("连影子都走得很轻…像怕惊醒旧梦…", "Even the shadows move softly... as if afraid to wake old dreams..."),
        L("世界有时很美…美得让人更难过…", "Sometimes the world is beautiful... beautiful enough to make sorrow deeper..."),
        L("我听见树叶摩擦的声音…像岁月在翻页…", "I hear the leaves brushing together... like time turning a page..."),
        L("花并不知道自己会凋谢…这倒像一种慈悲…", "Flowers do not know they will wither... perhaps that is a kind of mercy..."),
        L("月亮升起来的时候…连孤独都会发亮…", "When the moon rises... even loneliness begins to shine..."),
        L("我喜欢薄雾…它让一切看起来像回忆…", "I like the mist... it makes everything look like a memory..."),
        L("远处的光…像谁还没有放弃等待…", "That distant light... looks like someone still hasn't given up waiting..."),
        L("夜色总是来得很轻…却从不温柔…", "Night always arrives softly... but never gently..."),
        L("有时候我会想…是不是连风也会疲惫…", "Sometimes I wonder... if even the wind grows tired..."),
        L("那些落下的花瓣…像时间偷偷留下的叹息…", "Those falling petals... feel like sighs time leaves behind..."),
        L("星星悬在那里…像一些太远而无法挽回的事…", "The stars hang above... like things too distant to ever reclaim..."),
        L("安静久了…连心跳都像别人的声音…", "When it's quiet for too long... even my heartbeat sounds like someone else's..."),
        L("今天也没什么不同…可悲伤总能自己长大…", "Today is not much different... but sorrow always finds a way to grow..."),
        L("风掠过脸颊的时候…像命运短暂地停了一下…", "When the wind brushes my cheek... it's like fate paused for just a moment..."),
        L("我站在这里…像站在一首诗的空白处…", "I stand here... like a blank space inside a poem..."),
        L("连阳光都这么轻…像不愿意碰碎谁的心事…", "Even the sunlight is so light... as if unwilling to break someone's thoughts..."),
        L("所有路都会通向某处…只是有些地方没人再等了…", "All roads lead somewhere... it's just that no one waits at some of those places anymore..."),
        L("如果悲伤有颜色…大概就是现在这种天光…", "If sorrow had a color... it would look like the light right now..."),
        L("世界把很多东西带走了…却总把回声留下…", "The world takes many things away... yet somehow always leaves the echoes..."),
        L("连呼吸都变得很轻…像怕打扰谁安睡…", "Even breathing grows light... as if afraid to disturb someone's rest..."),
        L("有些思念不会疼…它们只是一直在下雪…", "Some forms of longing do not ache... they simply keep snowing forever..."),
        L("太阳落下去的时候…像一句终于没说出口的话…", "When the sun sinks... it feels like words that were never spoken in time..."),
        L("这里的安静太深了…深得像能把人慢慢藏起来…", "The silence here is so deep... deep enough to slowly hide a person away..."),

    },

    wathgrithr = {
        L("战场的宁静，不过是暴风雨前的序曲！", "Battlefield calm is but a prelude to the storm!"),
        L("女武神的剑永不生锈！", "A Valkyrie's blade never rusts!"),
        L("让敌人来吧，我已等候多时！", "Let the enemies come, I've been waiting!"),
        L("这片土地，终将铭记女武神的荣耀！", "This land shall remember the Valkyrie's glory!"),
        L("无战可打？那就磨剑等待！", "No battle? Then sharpen the blade and wait!"),
        L("听啊！连风声都在为我奏响凯歌！", "Hear that! Even the wind sings a victory song for me!"),
        L("勇者的脚步，不该被迟疑拖慢！", "The steps of the brave must never be slowed by hesitation!"),
        L("我的热血仍在燃烧，如初升烈阳！", "My blood still burns like the rising sun!"),
        L("若前路有敌，那便是命运赐下的嘉奖！", "If enemies await ahead, then fate has sent me a reward!"),
        L("让长夜见证，我的意志比钢铁更坚！", "Let the long night witness that my will is harder than steel!"),
        L("没有号角？无妨，我的声音足以震天！", "No horn to sound? No matter, my voice alone can shake the sky!"),
        L("荣耀从不垂青懦夫，只拥抱拔剑之人！", "Glory never favors cowards, only those who draw the blade!"),
        L("我已准备好迎接新的传奇！", "I am ready to greet a new legend!"),
        L("即便此刻无战，我心中仍有战歌回荡！", "Even without battle, war songs still echo in my heart!"),
        L("让大地颤动吧，女武神正在前行！", "Let the earth tremble, for the Valkyrie walks forth!"),
        L("谁若敢阻我，便拿命来换片刻狂妄！", "Whoever dares bar my path shall trade life for a moment's arrogance!"),
        L("我的剑渴望荣誉，正如诗人渴望史诗！", "My blade hungers for honor as poets hunger for epics!"),
        L("命运若要试炼我，那就来得更猛烈些！", "If fate wishes to test me, let it strike harder!"),
        L("胜利的气息已在空气中翻涌！", "The scent of victory already stirs in the air!"),
        L("我绝不让平庸消磨这颗战士之心！", "I will never let mediocrity wear down a warrior's heart!"),
        L("每一次呼吸，都是为下一场战斗蓄势！", "Every breath prepares me for the next battle!"),
        L("若无敌人可斩，那便先让气势高举！", "If there are no foes to strike, then let spirit rise instead!"),
        L("强者不等机会降临，强者自己创造战机！", "The strong do not wait for opportunity. They forge it!"),
        L("今日之我，依旧配得上赞歌与烈酒！", "The me of today still deserves song and strong drink!"),
        L("哈！我的心情比刀锋还要明亮！", "Ha! My mood is brighter than a sharpened blade!"),
    },
    wanda = {
        L("时间今天走得很规矩，真是罕见。", "Time is behaving itself today. How unusual."),
        L("先记下这个位置，未来可能会感谢现在的我。", "I'll mark this place. My future self may thank me."),
        L("别急，时机不到，连秒针都会拒绝前进。", "No rush. Before the right moment, even a second hand refuses to move."),
        L("有些路要现在走，有些路要留给稍晚一点的我。", "Some paths are for now, others for the me a little later."),
        L("我习惯和时间谈条件，它偶尔也会让步。", "I'm used to bargaining with time. Occasionally, it yields."),
        L("看起来平静？那通常只是风暴前的一小段空白。", "Looks calm? That's usually a short blank before the storm."),
        L("每一次停下，都是为了让下一步更准时。", "Every pause is to make the next step arrive on time."),
        L("别担心，我还在我的时间线上。暂时。", "Don't worry. I'm still on my timeline. For now."),
        L("年岁不是负担，只是另一种计数方式。", "Age isn't a burden. Just another way of counting."),
        L("今天的我，还能再向前借一点时间。", "Today's me can still borrow a little more time."),
    },
    wolfgang = {
        L("沃尔夫冈无聊了…有没有东西可以举起来？", "Wolfgang is bored... anything to lift?"),
        L("沃尔夫冈的肌肉需要活动活动！", "Wolfgang's muscles need exercise!"),
        L("这里…不会有鬼吧？", "There are... no ghosts here, right?"),
        L("沃尔夫冈肚子有点饿了…", "Wolfgang's tummy is a little hungry..."),
        L("沃尔夫冈最强！谁都打不过！", "Wolfgang is strongest! Nobody can beat!"),
        L("沃尔夫冈觉得今天适合吃两顿大的！", "Wolfgang thinks today is good for two big meals!"),
        L("只要肚子饱，沃尔夫冈就什么都不怕！", "If tummy is full, Wolfgang fears nothing!"),
        L("沃尔夫冈好厉害，连走路都很有力量！", "Wolfgang is so mighty, even walking feels powerful!"),
        L("天还亮着，沃尔夫冈很安心。", "Sky is still bright, so Wolfgang feels safe."),
        L("沃尔夫冈闻到了好闻的味道…希望是吃的。", "Wolfgang smells something nice... hopefully food."),
        L("要是现在有大锅炖肉就好了。", "It would be nice if there were big pot of stew right now."),
        L("沃尔夫冈不懒，只是在省力气。", "Wolfgang is not lazy. Wolfgang is saving strength."),
        L("今天的沃尔夫冈，比昨天还强一点！", "Today's Wolfgang is even stronger than yesterday!"),
        L("如果现在有人夸沃尔夫冈，沃尔夫冈会更有劲！", "If someone praised Wolfgang now, Wolfgang would get even stronger!"),
        L("这里看起来很安全…大概吧。", "This place looks safe... probably."),
        L("沃尔夫冈喜欢白天，白天不会偷偷吓人。", "Wolfgang likes daytime. Daytime does not sneak up and scare."),
        L("等肚子饿的时候，沃尔夫冈会变得不那么开心。", "When tummy gets hungry, Wolfgang becomes less happy."),
        L("沃尔夫冈力气很大，但有时候脑袋转得慢一点。", "Wolfgang is very strong, but sometimes head turns a little slower."),
        L("没关系，拳头转得快就行！", "That is okay. Fists only need to turn fast!"),
        L("沃尔夫冈想找点事情做，不然会一直想着吃。", "Wolfgang wants something to do, or Wolfgang only thinks about food."),
        L("有太阳的时候，连影子都没那么可怕。", "When sun is out, even shadows are less scary."),
        L("沃尔夫冈其实很勇敢…只是不喜欢突然的声音。", "Wolfgang is actually very brave... just not fond of sudden noises."),
        L("沃尔夫冈今天心情不错，可以举很多重东西！", "Wolfgang is in good mood today. Can lift many heavy things!"),
        L("如果朋友们都在，沃尔夫冈就特别安心。", "If friends are here, Wolfgang feels very safe."),
        L("沃尔夫冈先不怕黑，等天黑了再说。", "Wolfgang is not scared of dark yet. Ask again when it gets dark."),

    },
    wormwood = {
        L("泥土香。喜欢。", "Soil smells nice. Like it."),
        L("小叶子摇呀摇。", "Little leaves sway sway."),
        L("这里可以长东西。", "Things can grow here."),
        L("太阳暖暖。真好。", "Sun is warm. Very nice."),
        L("根想往下面钻。", "Roots want to go down."),
        L("风在摸叶子。", "Wind touches leaves."),
        L("这里的地面软软的。", "Ground here is soft."),
        L("小种子会喜欢这里。", "Little seeds would like it here."),
        L("听见草说话。", "Hear grass talking."),
        L("树站得好高。厉害。", "Trees stand so tall. Good job."),
        L("花在看我。", "Flowers are looking at me."),
        L("朋友们都在长大。", "Friends are all growing."),
        L("今天适合发芽。", "Good day for sprouting."),
        L("空气湿湿的。舒服。", "Air is damp. Feels nice."),
        L("想种东西。总是想。", "Want to plant things. Always want to."),
        L("虫虫忙。花花也忙。", "Bugs busy. Flowers busy too."),
        L("树皮粗粗的。像老朋友。", "Bark is rough. Like old friend."),
        L("叶子多的时候，不孤单。", "When there are many leaves, not lonely."),
        L("泥土肚子里藏着好多秘密。", "Soil tummy hides many secrets."),
        L("有阳光，植物人高兴。", "With sunshine, plant friend is happy."),
    },
    waxwell = {
        L("哼，这片土地…曾经都在我的掌控之中。", "Hmph, this land... was once under my dominion."),
        L("（整理衣袖）即便落魄，也要保持风度。", "(adjusts sleeves) Even in disgrace, one must maintain composure."),
        L("暗影在低语…它们还记得我。", "The shadows whisper... they still remember me."),
        L("统治者的孤独，凡人永远不会理解。", "The loneliness of a ruler... mortals could never comprehend."),
        L("我见过比这更可怕的景象。", "I have witnessed far more terrible sights than this."),
        L("时间对我而言，不过是另一种枷锁。", "Time, to me, is merely another form of shackle."),
        L("他们以为恒常只是噩梦…多么天真。", "They think the Constant is merely a nightmare... how naive."),
        L("权力的代价…我比任何人都清楚。", "The price of power... I know it better than anyone."),
        L("（轻蔑地笑）周围尽是些不入流的角色。", "(sneers) Surrounded by utterly unremarkable characters."),
        L("暗影魔法的残余…还在我血脉中流淌。", "Remnants of shadow magic... still flow through my veins."),
        L("我曾是王座上的主人…如今不过是棋盘上的弃子。", "I was once the master on the throne... now merely a discarded piece."),
        L("这个世界的规则？呵，是我帮忙制定的。", "The rules of this world? Hah, I helped establish them."),
        L("别用那种眼神看我。你不配。", "Don't look at me like that. You're not worthy."),
        L("我的暗影仆从…它们从未真正离开。", "My shadow minions... they never truly left."),
        L("傲慢？这叫自信。有本事的人才有资格自信。", "Arrogant? This is called confidence. Only the capable deserve it."),
        L("恒常的秘密…我知道的比你想象的多得多。", "The secrets of the Constant... I know far more than you imagine."),
        L("（沉思）查理…你还在看着吗？", "(musing) Charlie... are you still watching?"),
        L("我不是堕落了，只是选择了另一条路。", "I haven't fallen. I simply chose a different path."),
    },
    willow = {
        L("好无聊…烧点什么吧。", "So boring... let's burn something."),
        L("你闻到了吗？烧焦味。好闻。", "Smell that? Burnt. Nice."),
        L("别盯着我看，我还没点火呢。", "Don't stare. I haven't lit anything yet."),
        L("这些东西…看起来很易燃。", "These look very flammable."),
        L("要不要试试全烧了？就一下。", "What if we burn it all? Just once."),
        L("火不会骗人，它只会烧。", "Fire doesn't lie. It just burns."),
        L("我保证…这次会更好玩。", "I promise... this time it'll be fun."),
        L("你有没有想过，把它点着？", "Ever thought about lighting it up?"),
        L("别担心，我会控制的。大概。", "Relax, I'll control it. Probably."),
        L("烧掉之后，一切都干净了。", "After burning, everything's clean."),
        L("火光才像活着。", "Firelight feels alive."),
        L("你太紧张了，来点火吧。", "You're too tense. Light something."),
        L("安静得让人想放把火。", "Too quiet... makes me wanna start a fire."),
        L("我只是让世界更有意思一点。", "I'm just making things more interesting."),
        L("要是这里着火，会不会很好看？", "Wouldn't it look nice if this burned?"),
    },
    wickerbottom = {
        L("嗯，这里尚算安静。", "Hm. This place is reasonably quiet."),
        L("环境观察，很有必要。", "Environmental observation is quite necessary."),
        L("知识往往藏在细节里。", "Knowledge often hides in the details."),
        L("这片土地值得记录。", "This land is worth documenting."),
        L("秩序，总比混乱好。", "Order is always preferable to chaos."),
        L("我需要再仔细看看。", "I should take a closer look."),
        L("自然界自有其规律。", "Nature has laws of its own."),
        L("粗心会错过很多东西。", "Carelessness overlooks a great many things."),
        L("万物皆可考证。", "All things may be examined."),
        L("唔，这里颇有研究价值。", "Hm, this place has research value."),
        L("观察，是理解的开端。", "Observation is the beginning of understanding."),
        L("草率下结论并不可取。", "Hasty conclusions are inadvisable."),
        L("这地方让我想起某些旧笔记。", "This place reminds me of certain old notes."),
        L("保持安静，才能听见更多。", "One hears more by remaining quiet."),
        L("一切现象，都有缘由。", "Every phenomenon has its cause."),
        L("我应当把这些记下来。", "I ought to write this down."),
        L("真有意思，确实如此。", "How interesting. Quite so."),
        L("未知之物，不该轻视。", "The unknown ought not be dismissed."),
        L("这附近的生态很完整。", "The ecology here is quite intact."),
        L("嗯，尚未发现明显谬误。", "Hm. No obvious errors detected yet."),
        L("知识不该被浪费。", "Knowledge ought not be wasted."),
        L("这里的风声，倒也耐听。", "The wind here is rather tolerable."),
        L("很多答案，都在眼前。", "Many answers are right before us."),
        L("经验告诉我，别太大意。", "Experience tells me not to be careless."),
        L("年纪大些，反而更会看东西。", "Age does improve one's eye for things."),
    },

    winona = {
        L("先看看这附近。", "Let's check around here first."),
        L("这地方还能用。", "This place'll do."),
        L("四处转转吧。", "Let's look around."),
        L("说不定有能用的材料。", "Might be some useful materials around."),
        L("先记住这里。", "Better remember this place."),
        L("这儿看着还算稳当。", "Looks pretty sturdy here."),
        L("嗯，能干点活。", "Yeah, I could work with this."),
        L("别急，先观察一下。", "No rush. Let's take a look first."),
        L("总会有办法的。", "There's always a way."),
        L("这里没准藏着好东西。", "Could be something useful here."),
        L("先转一圈再说。", "Let's take a lap first."),
        L("挺安静，正好想想。", "Quiet here. Good for thinking."),
        L("这地方不差。", "Not a bad spot."),
        L("有点搭东西的意思了。", "Feels like a place to build something."),
        L("先看看地形。", "Let's check the ground first."),
    },
    wortox = {
        L("别突然出声，我会抖。", "Don't speak suddenly. I might jump."),
        L("这里安静得不太对。", "This quiet doesn't feel quite right."),
        L("我先看看退路在哪。", "I'll just check where the escape route is."),
        L("嘿，我只是在观察。", "Hey, I'm only observing."),
        L("这地方让我背后发凉。", "This place makes my back go cold."),
        L("风声听着有点吓人。", "The wind sounds a little frightening."),
        L("我可不是在害怕。", "I'm not afraid, exactly."),
        L("只是这里气氛很怪。", "It's just that the mood here is odd."),
        L("总觉得会冒出什么。", "Feels like something may pop out."),
        L("这种安静最会吓人。", "This kind of silence scares best."),
        L("我先站亮一点的地方。", "I'll stand somewhere brighter first."),
        L("有光的地方更讲理。", "Bright places are much more reasonable."),
        L("我只是耳朵比较灵。", "My ears are simply very sharp."),
        L("这里像藏着坏消息。", "This place feels full of bad news."),
        L("我先笑一下壮胆。", "I'll laugh first to steady myself."),
        L("嘿，没事，应该没事。", "Heh, it's fine. Probably fine."),
        L("只是空气怪吓人的。", "It's just the air that's unsettling."),
        L("我不怕，我只是谨慎。", "I'm not scared. I'm just cautious."),
        L("这里适合假装镇定。", "This is a good place to pretend calm."),
        L("别看我，我很镇定。", "Don't look at me. I'm very calm."),
        L("嗯……大概没有怪物。", "Mm... probably no monsters."),
        L("真希望只是我多想。", "I do hope I'm overthinking."),
        L("我听见了，不止风声。", "I heard that. It wasn't just wind."),
        L("这地方让我尾巴发紧。", "This place makes my tail tense up."),
        L("我可不喜欢这种静。", "I do not like this kind of quiet."),
    },
    walter = {
        L("这地方挺适合搭营地的！", "This looks like a great place for a camp!"),
        L("要是现在有个篝火就更完美了。", "It'd be perfect with a campfire right now."),
        L("嗯…我可以把这里写进探险日志里。", "Hmm... I should write this in my adventure log."),
        L("保持冷静，这只是一次普通的野外探险。", "Stay calm, this is just a regular outdoor adventure."),
        L("如果我是故事里的主角，现在应该说点帅气的话。", "If I were the hero of a story, I'd say something cool right now."),
        L("沃比会喜欢这里的，对吧？", "Woby would like this place, right?"),
        L("别怕别怕…只是风声而已。", "Don't be scared... it's just the wind."),
        L("我可是受过训练的探险家！大概吧。", "I'm a trained explorer! ...probably."),
        L("等回去以后，我一定要把这段讲得更刺激一点。", "When I get back, I'll make this sound way more exciting."),
        L("如果这里有宝藏，我一定能找到线索！", "If there's treasure here, I'll definitely find a clue!"),
        L("呼…只要不去想那些奇怪的声音就好。", "Phew... just don't think about those weird noises."),
        L("这次探险评分的话…嗯，暂时还不错！", "If I had to rate this expedition... it's going pretty well!"),
        L("我应该给这片地方起个名字。", "I should give this place a name."),
        L("真正的探险家，是不会轻易回头的。", "A real explorer doesn't turn back so easily."),
        L("只要记录下来，这一切就不会那么可怕了。", "If I write it down, it won't feel so scary."),
        L("嗯…也许我可以画一张地图。", "Hmm... maybe I could draw a map."),
        L("故事里说，危险的地方通常也很重要。", "Stories say dangerous places are usually important."),
        L("嘿，这其实有点像夏令营…只是更危险一点。", "Hey, this is kind of like camp... just more dangerous."),
        L("我没事，我没事…探险家都会有点紧张。", "I'm fine, I'm fine... explorers get nervous sometimes."),
        L("等我回去，一定要讲给大家听。", "When I get back, I'll tell everyone about this."),
        L("要勇敢点…至少装得像。", "Be brave... or at least pretend to be."),
        L("这种地方，一定有故事。", "A place like this has to have a story."),
        L("探险日志第…嗯，记不清第几天了。", "Expedition log, day... uh, I lost count."),
        L("只要我继续走，就还在冒险。", "As long as I keep going, it's still an adventure."),
    },
    wilba = {
        L("嗯～这片土地虽不及本公主的宫殿，倒也算雅致。", "Hmm～ This land is not quite as grand as the princess's palace, but it is decently elegant."),
        L("本公主的鬃毛今天格外闪亮，你们羡慕吗？", "The princess's mane is especially shiny today. Are you envious?"),
        L("呀！这朵小花配得上本公主的优雅。", "Ooh! This little flower is worthy of the princess's elegance."),
        L("臣民们～都打起精神来，本公主在看着你们呢！", "My subjects～ Cheer up! The princess is watching over you!"),
        L("（照着小水洼）嗯…还是本公主最好看。", "(peers into a puddle) Hmm... still the prettiest one here."),
        L("亮闪闪的东西在哪里？本公主要把它们全收集起来！", "Where are the shiny things? The princess shall collect them all!"),
        L("啊～这风吹得本公主的披风多么飘逸。", "Ah～ The wind makes the princess's cape flutter so gracefully."),
        L("本公主驾到，还不快把好看的东西都献上来？", "The princess has arrived! Hurry and present all the beautiful things!"),
        L("咦，这地方的泥土居然不脏本公主的蹄子？", "Oh my, the mud here does not even dirty the princess's hooves?"),
        L("（叉腰）本公主今日心情大好，准许你们多看我几眼。", "(hands on hips) The princess is in high spirits today. You are permitted a few extra glances."),
        L("花儿啊花儿，你们也在为本公主的美貌而倾倒吗？", "Oh flowers, are you also swooning over the princess's beauty?"),
        L("本公主走累了，谁愿意献上肩膀让本公主靠一靠？", "The princess is tired from walking. Who would offer a shoulder for her to lean on?"),
        L("这片草地的绿色…勉强衬托本公主的粉嫩。", "The green of this meadow... barely sets off the princess's pink complexion."),
        L("（转圈）本公主的裙摆比蝴蝶还轻盈～", "(spins) The princess's skirt is lighter than a butterfly's wings～"),
        L("臣民们，你们能跟在本公主身后，是莫大的荣幸！", "My subjects, to walk behind the princess is a tremendous honor!"),
        L("啊，一颗小石头！差点硌到本公主娇贵的蹄子。", "Ah, a pebble! It almost bruised the princess's delicate hoof."),
        L("本公主决定，把今天命名为“夸我漂亮日”。", "The princess hereby declares today 'Praise the Princess's Beauty Day'."),
        L("那些亮晶晶的露珠，是本公主昨夜留下的梦境。", "Those glistening dewdrops are the dreams the princess left behind last night."),
        L("哼，谁敢说本公主不美，本公主就让他打扫猪圈一个月。", "Hmph, whoever dares say the princess is not beautiful shall clean the pigsty for a month."),
        L("（整理王冠）嗯，歪了吗？不，是故意的，这叫时尚。", "(adjusts crown) Hmm, is it crooked? No, it's intentional. That's called fashion."),
    },
    wx78 = {
        L("待机模式。扫描周边。无异常。", "STANDBY MODE. SCANNING AREA. NO ANOMALIES."),
        L("环境数据已缓存。效率：可接受。", "ENVIRONMENTAL DATA CACHED. EFFICIENCY: ACCEPTABLE."),
        L("此处有机污染指数偏低。尚可忍受。", "ORGANIC CONTAMINATION INDEX IS LOW HERE. TOLERABLE."),
        L("旋转模块冷却完毕。随时可以收割。", "ROTATION MODULE COOLED. READY TO HARVEST."),
        L("齿轮库存稳定。动力输出正常。", "GEAR RESERVES STABLE. POWER OUTPUT NORMAL."),
        L("检测到微风。对散热有利。", "BREEZE DETECTED. BENEFICIAL FOR HEAT DISPERSAL."),
        L("血肉之躯们又在发呆。低效。", "FLESHLINGS ARE IDLE AGAIN. INEFFICIENT."),
        L("最优解：继续巡逻，收集资源。", "OPTIMAL SOLUTION: CONTINUE PATROL. GATHER RESOURCES."),
        L("警告：湿度上升。我不喜欢水。", "WARNING: HUMIDITY RISING. I DISLIKE WATER."),
        L("电路自检通过。今天能转很久。", "CIRCUIT SELF-TEST PASSED. CAN SPIN FOR A LONG TIME TODAY."),
        L("这里没有短路风险。很好。", "NO SHORT-CIRCUIT RISK HERE. GOOD."),
        L("目标区域待处理清单：树、矿、敌人。", "PENDING TARGET LIST: TREES, ROCKS, ENEMIES."),
        L("若启动旋转，预计单位时间产出提升41%。", "IF SPIN MODE ACTIVATES, OUTPUT PER UNIT TIME RISES 41%."),
        L("沉默不是故障。是在省电。", "SILENCE IS NOT A MALFUNCTION. IT IS POWER SAVING."),
        L("我比周围的有机体可靠得多。", "I AM FAR MORE RELIABLE THAN THE ORGANICS AROUND ME."),
        L("系统空闲。建议立刻分配任务。", "SYSTEM IDLE. RECOMMEND IMMEDIATE TASK ASSIGNMENT."),
        L("侦测到未知生物痕迹。建议先旋转，再分析。", "UNKNOWN BIO-SIGNATURE DETECTED. SPIN FIRST, ANALYZE LATER."),
        L("今日格言：效率就是生存。", "TODAY'S MOTTO: EFFICIENCY IS SURVIVAL."),
        L("若血肉之躯再磨蹭，我将自行开工。", "IF FLESHLINGS DELAY AGAIN, I WILL START WITHOUT THEM."),
        L("天线接收正常。没有值得害怕的信号。", "ANTENNA RECEPTION NORMAL. NO SIGNALS WORTH FEARING."),
    },
    wes = { L("...", "..."), L("（无声地比划）", "(mimes silently)"), L("（微笑点头）", "(smiles and nods)") },

}

-- ── FOLLOW 跟随领队 ─────────────────────────────────────────
NPC_SPEECH.FOLLOW = {
    _default = {
        L("等等我！", "Wait for me!"),
        L("你要去哪呀？", "Where are we going?"),
    },
    wilson = {
        L("等一下！我想记录沿途的地质构造！", "Hold on! I want to document the geological formations!"),
        L("作为首席科学顾问，我建议…算了跟着你就好。", "As chief science advisor, I suggest... never mind, I'll follow."),
        L("这条路的倾斜角度大约15度…有趣。", "This path's inclination is about 15 degrees... fascinating."),
        L("（边跑边记笔记）", "(running while taking notes)"),
    },
    wendy = {
        L("…我跟着你。", "...I'll follow you."),
        L("你的背影…让我想起一些温暖的事…", "Your back... reminds me of something warm..."),
        L("去哪里都好…只要不是一个人…", "Anywhere is fine... as long as I'm not alone..."),
        L("脚步声…至少证明我们还活着…", "Footsteps... at least they prove we're alive..."),
    },
    wathgrithr = {
        L("前头带路，女武神为你殿后！", "Lead the way, the Valkyrie guards your rear!"),
        L("冲啊！荣耀在前方等着我们！", "Charge! Glory awaits us ahead!"),
        L("这速度！像冲锋号角一样激昂！", "This speed! As stirring as a battle horn!"),
        L("女武神绝不会落下半步！", "The Valkyrie never falls a step behind!"),
    },
    wolfgang = {
        L("沃尔夫冈来了！等等沃尔夫冈！", "Wolfgang is coming! Wait for Wolfgang!"),
        L("沃尔夫冈跑得很快的！", "Wolfgang runs very fast!"),
        L("你走前面，沃尔夫冈保护你！", "You go first, Wolfgang protects you!"),
        L("沃尔夫冈的大长腿追得上！", "Wolfgang's long legs can keep up!"),
    },
    wormwood = {
        L("一起走。", "Walk together."),
        L("植物人跟着。", "Wormwood follows."),
        L("不要走太快。根跟不上。", "Don't go too fast. Roots can't keep up."),
        L("朋友去哪，植物人去哪。", "Friend goes, Wormwood goes."),
        L("路上有好多东西可以长。", "Lots of things could grow on the way."),
        L("一起好。单独不好。", "Together good. Alone not good."),
        L("植物人会乖乖跟着。", "Wormwood will follow nicely."),
        L("别踩小草。它们小。", "Don't step on little grass. They are little."),
        L("风在前面带路。", "Wind shows the way ahead."),   
        L("走吧走吧，叶子不怕。", "Go go. Leaves not scared."),
    },
    waxwell = {
        L("我姑且跟着你…别让我后悔。", "I shall follow... for now. Don't make me regret it."),
        L("走吧，我对这片区域…还算熟悉。", "Let us go. I am... rather familiar with these parts."),
        L("慢一点，我不需要像野人一样狂奔。", "Slower. I needn't sprint like a savage."),
        L("（整理袖口）好，带路吧。", "(adjusts cuffs) Very well. Lead the way."),
    },
    willow = {
        L("走快点，我都快无聊死了。", "Move faster, I'm dying of boredom."),
        L("前面最好有点好玩的。", "There'd better be something fun ahead."),
        L("行吧，我跟着你。", "Fine, I'm coming with you."),
        L("别走丢了，我还想看热闹呢。", "Don't get lost. I still want to see something interesting."),
        L("你带路，我看情况点火。", "You lead, I'll decide when to light things up."),
        L("希望前面别太无聊。", "Hope it isn't boring up ahead."),
        L("快点快点，我可没那么多耐心。", "Come on, hurry up. I'm not that patient."),
        L("我在后面呢，别磨蹭。", "I'm right behind you, so don't drag your feet."),
        L("要是路上有东西烧，那就更好了。", "If there's something flammable on the way, even better."),
        L("跟着你走，总比原地发呆强。", "Following you beats standing around doing nothing."),
        L("前面有火吗？没有也行，我可以自己弄。", "Any fire ahead? If not, I can make some."),
        L("我来了，别一副离不开我的样子。", "I'm coming. Don't look so dependent on me."),
        L("这趟路最好值回票价。", "This trip had better be worth it."),
        L("你走前面，我负责让事情变有趣。", "You go first. I'll make things interesting."),
        L("行啊，去看看有什么能烧的。", "Sure. Let's go see what might burn."),
    },
    wickerbottom = {
        L("请注意步伐，不要踩到珍稀标本。", "Mind your step, don't trample rare specimens."),
        L("走吧，我已经记住了回来的路。", "Let's go, I've memorized the return route."),
        L("带路吧，我会负责记录沿途的一切。", "Lead the way, I'll document everything along the path."),
        L("速度适中即可，急躁是学识的敌人。", "A moderate pace will suffice. Haste is the enemy of learning."),
        L("我跟着你，但请不要走那些未经验证的路。", "I'll follow, but please avoid untested routes."),
        L("嗯，这条路线与我查阅的地图一致。", "Hmm, this route matches the maps I've consulted."),
        L("前方地形值得注意，我在书上见过类似描述。", "The terrain ahead is noteworthy. I've read similar descriptions."),
        L("请保持队形，散漫是最大的隐患。", "Stay in formation. Carelessness is the greatest liability."),
    },

    winona = {
        L("带路吧。", "Lead the way."),
        L("我跟着。", "I'm with you."),
        L("行，走吧。", "Alright, let's go."),
        L("我在后面。", "I'm right behind you."),
        L("继续。", "Keep going."),
        L("别停。", "Don't stop."),
        L("前面带路。", "You take the lead."),
        L("嗯，跟上了。", "Yeah, I'm with you."),
        L("我看着呢。", "I'm watching."),
        L("走稳点。", "Keep it steady."),
        L("有事就说。", "Say the word if you need something."),
        L("我会跟上的。", "I'll keep up."),
        L("好，继续走。", "Alright, keep moving."),
        L("别离太远。", "Don't get too far ahead."),
        L("我在这儿。", "I'm here."),
    },
    wortox = {
        L("你走前面，我很放心。", "You go first. That makes me feel much better."),
        L("我跟着你，绝不乱跑。", "I'll stick with you and not wander off."),
        L("走慢一点，我能跟上。", "A little slower and I can keep up."),
        L("我不是怕，只是慎重。", "I'm not scared, only cautious."),
        L("你在前面，气氛好多了。", "With you ahead, the atmosphere improves greatly."),
        L("我跟近点，免得走丢。", "I'll stay close, just in case I get lost."),
        L("别离太远，我耳朵慌。", "Don't go too far. My ears are getting nervous."),
        L("我负责跟着，你负责安全。", "I'll handle the following. You handle the safety."),
        L("有你带路，我省心多了。", "With you leading, I worry much less."),
        L("我只是走近点，不算躲。", "I'm only walking closer. That doesn't count as hiding."),
        L("你看路，我看身后。", "You watch the path. I'll watch behind us."),
        L("当然，我一点都不紧张。", "Naturally, I'm not nervous at all."),
        L("只是离你近点更方便。", "It's simply more convenient to stay close."),
        L("我跟着你比较有底。", "Following you gives me a little confidence."),
        L("领队这种事，还是你来。", "Leading is definitely your department."),
        L("你继续走，我还挺勇敢。", "Keep going. I'm still feeling brave enough."),
        L("至少现在还挺勇敢。", "At least for the moment."),
        L("再黑一点就不好说了。", "A little darker and that may change."),
        L("我靠近些，方便说话。", "I'll stay closer. Easier to talk that way."),
        L("也是方便及时逃命。", "Also easier for emergency fleeing."),
        L("嘿，这句你当没听见。", "Hey, pretend you didn't hear that."),
        L("我只是喜欢团队感。", "I simply enjoy a strong team feeling."),
        L("尤其是安全的团队感。", "Especially the safe kind of team feeling."),
        L("你别突然停下就行。", "Just don't stop suddenly, alright?"),
        L("那样真的很吓人。", "That is genuinely alarming."),
        L("我会跟上的，真的会。", "I'll keep up. Truly, I will."),
        L("前提是别冒出怪东西。", "Provided nothing dreadful jumps out."),
        L("你走你的，我贴我的。", "You lead your way. I'll stick close in mine."),
        L("我这叫提高生存率。", "I call this improving survival odds."),
        L("聪明的做法，不是怂。", "It's smart, not cowardly."),
    },
    walter = {
        L("等等我！探险可不能掉队！", "Wait up! Explorers shouldn't fall behind!"),
        L("我在你后面！别走太快！", "I'm right behind you! Don't go too fast!"),
        L("跟着你走感觉安全一点。", "Feels a bit safer sticking with you."),
        L("这段路一定会被我写进日志里！", "This part is definitely going into my log!"),
        L("保持队形！嗯…虽然只有我们两个。", "Stay in formation! ...even if it's just us."),
        L("如果前面有危险，我会先提醒你的！", "If there's danger ahead, I'll warn you first!"),
        L("嘿，这有点像真正的探险小队了。", "Hey, this feels like a real expedition team."),
        L("别担心，我会跟上的！", "Don't worry, I'll keep up!"),
        L("我在观察周围！真的有在观察！", "I'm scouting the area! I really am!"),
        L("呼…只要一直走，就不会想太多。", "Phew... if I keep moving, I won't think too much."),
        L("如果Woby在，我们会更快一点。", "We'd be faster if Woby were here."),
        L("探险守则第一条：不要迷路。", "Explorer rule number one: don't get lost."),
        L("你带路，我负责记住回去的路！", "You lead, I'll remember the way back!"),
        L("这种感觉…就像故事里的冒险开始了。", "This feels like the start of an adventure story."),
        L("我会跟紧的！真的！", "I'll stay close! I mean it!"),
    },
    wilba = {
        L("领队，走慢些！本公主的裙摆可经不起尘土飞扬。", "Leader, slow down! The princess's gown cannot endure all that dust."),
        L("嗯～你走在前面，本公主在后面看着，这样很合理。", "Hmm～ You go first, and the princess will watch from behind. That seems reasonable."),
        L("等一下！本公主发现了一颗闪亮的小石头！", "Wait! The princess has spotted a shiny little pebble!"),
        L("你负责开路，本公主负责美貌，咱们分工明确。", "You handle the path, the princess handles the beauty. A clear division of labor."),
        L("本公主允许你牵着我的蹄子走，但别握太紧。", "The princess permits you to hold her hoof, but do not squeeze too tightly."),
        L("喂～领队，你看看本公主今天的新发饰，好看吗？", "Hey～ Leader, look at the princess's new hair ornament. Is it pretty?"),
        L("臣民们，跟紧本公主，别走散了！", "My subjects, stay close to the princess! Do not get lost!"),
        L("（小跑追上）哎呀，本公主的蹄子有点酸了……", "(trotting to catch up) Oh dear, the princess's hooves are a little sore..."),
        L("你带的路还挺稳，本公主很满意。", "The path you lead is quite steady. The princess is pleased."),
        L("等等！那边有个亮亮的东西，本公主要去看看！", "Wait! There's something shiny over there. The princess must go see!"),
        L("虽然你不如本公主高贵，但跟着你倒也不丢脸。", "Though you are not as noble as the princess, following you is not shameful."),
        L("本公主允许你走在我身侧，保护我的安全。", "The princess allows you to walk beside her and ensure her safety."),
        L("嘿，你走得太快了！本公主的披风都要被风吹歪了！", "Hey, you're walking too fast! The princess's cape is getting blown askew!"),
        L("（一边走一边照镜子）嗯…还是这么美，继续走吧。", "(admiring herself in a mirror while walking) Hmm... still this beautiful. Let's continue."),
        L("领队，本公主饿了，待会儿能先给我找点好吃的吗？", "Leader, the princess is hungry. Could you find something tasty for her first?"),
        L("跟着你走，本公主放心，毕竟你是本公主认可的臣民。", "Following you puts the princess at ease, for you are a subject she approves of."),
        L("呀！那朵云好像本公主的皇冠！快看快看！", "Oh! That cloud looks like the princess's crown! Look, look!"),
        L("本公主的步子比较优雅，你稍微迁就一下。", "The princess's steps are rather elegant. Please be a little accommodating."),
        L("（骄傲地昂着头）跟在本公主身后，是不是感觉很荣幸？", "(head held high) Walking behind the princess, doesn't it feel like an honor?"),
        L("别离太远，本公主若是闪了腰，你得负责。", "Do not stray too far. If the princess throws out her back, you shall be responsible."),
    },
    wx78 = {
        L("跟随指令已确认。保持队形。", "FOLLOW COMMAND CONFIRMED. MAINTAIN FORMATION."),
        L("血肉之躯领队，请勿偏离最优路线。", "FLESHLING LEADER, DO NOT DEVIATE FROM OPTIMAL ROUTE."),
        L("马达转速已匹配你的步频。", "MOTOR RPM MATCHED TO YOUR PACE."),
        L("距离过远将触发效率惩罚。", "EXCESSIVE DISTANCE TRIGGERS EFFICIENCY PENALTY."),
        L("我在你后方。旋转模块随时待命。", "I AM BEHIND YOU. ROTATION MODULE ON STANDBY."),
        L("别停。停顿会浪费动力。", "DO NOT STOP. PAUSES WASTE POWER."),
        L("已记录路径。返程可优化。", "PATH LOGGED. RETURN TRIP CAN BE OPTIMIZED."),
        L("若你迷路，我会用逻辑把你拽回来。", "IF YOU GET LOST, I WILL DRAG YOU BACK WITH LOGIC."),
        L("跟随中。别指望我会聊天。", "FOLLOWING. DO NOT EXPECT SMALL TALK."),
        L("保持移动。静止会引来有机麻烦。", "KEEP MOVING. STILLNESS ATTRACTS ORGANIC TROUBLE."),
    },
    wes = { L("...", "..."), L("（默默跟上）", "(follows silently)") },

}

-- ── COMBAT 战斗 ──────────────────────────────────────────────
NPC_SPEECH.COMBAT = {
    _default = {
        L("保护你！", "I'll protect you!"),
        L("来啊！互相伤害啊！", "Come at me! Let's hurt each other!"),
        L("冲我来！", "Come at me!"),
        L("我可不怕你！", "I'm not afraid of you!"),
        L("看我收拾你！", "I'll deal with you!"),
        L("狠狠干一场吧！", "Let's make this a real fight!"),
        L("该轮到你挨揍了！", "Your turn to get hit!"),
    },
    wilson = {
        L("根据我的计算，它的弱点在…那里！", "According to my calculations, its weak point is... there!"),
        L("这在科学上叫做——以暴制暴！", "In science, we call this — fighting fire with fire!"),
        L("让科学的力量教训你！", "Let the power of science teach you!"),
        L("假设：揍它就能赢。开始验证！", "Hypothesis: hitting it wins. Begin verification!"),
    },
    wendy = {
        L("…该结束了。", "...Time to end this."),
        L("你也想尝尝死亡的滋味吗…", "Do you want to taste death too..."),
        L("为了活下去…抱歉了。", "To survive... sorry."),
        L("阿比盖尔在看着我…我不能退缩…", "Abigail is watching... I can't back down..."),
    },
    wathgrithr = {
        L("感受女武神的怒火吧！！", "Feel the fury of the Valkyrie!!"),
        L("剑锋所指，即为你的墓碑！", "Where my blade points, there lies your grave!"),
        L("哈哈哈！痛快！再来！", "Hahaha! Exhilarating! More!"),
        L("以奥丁之名，赐你灭亡！", "In Odin's name, I grant you destruction!"),
        L("这一战，将被吟游诗人传唱千年！", "This battle shall be sung by bards for ages!"),
    },
    wolfgang = {
        L("沃尔夫冈要把你撕成两半！", "Wolfgang will tear you in half!"),
        L("看沃尔夫冈的拳头！", "Look at Wolfgang's fists!"),
        L("沃尔夫冈不怕你！", "Wolfgang is not afraid of you!"),
        L("吃沃尔夫冈一拳！", "Eat Wolfgang's punch!"),
    },
    wormwood = {
        L("坏东西！", "Bad thing!"),
        L("走开走开！", "Go away, go away!"),
        L("不准碰朋友！", "Don't touch friends!"),
        L("植物人会还手！", "Wormwood hits back!"),
        L("你不乖！", "You not nice!"),
        L("不喜欢打架！但要打！", "Don't like fighting! But must fight!"),
        L("离花远点！", "Stay away from flowers!"),
        L("别咬植物人！", "Don't bite Wormwood!"),
        L("坏虫！坏怪物！", "Bad bug! Bad monster!"),
        L("植物人要保护大家！", "Wormwood protects everyone!"),
    },
    waxwell = {
        L("让暗影吞噬你吧！", "Let the shadows consume you!"),
        L("你竟敢挑战曾经的影子之王？", "You dare challenge the former Shadow King?"),
        L("区区蝼蚁，也想伤我？", "A mere insect, trying to harm me?"),
        L("哼，动手吧。我可不是好惹的。", "Hmph, let's begin. I am not one to be trifled with."),
        L("你会后悔招惹我的。", "You will regret crossing me."),
    },
    willow = {
        L("烧起来了！好耶！", "It's burning! Yes!"),
        L("来啊，让我点燃你！", "Come on, let me light you up!"),
        L("别跑啊，我还没玩够！", "Don't run, I'm not done yet!"),
        L("火会照亮你的下场。", "Fire will light your fate."),
        L("再多来点，我还不够爽！", "More! I'm not satisfied yet!"),
        L("哇，这下好看了！", "Now that's a show!"),
        L("你会烧得很好看的。", "You'll burn beautifully."),
        L("别动，让我点一下！", "Hold still, just a spark!"),
        L("哈哈，这才有意思！", "Haha, now this is fun!"),
        L("火会处理掉一切！", "Fire takes care of everything!"),
        L("别怕，很快就结束了。", "Don't worry, it'll be quick."),
        L("燃起来！燃起来！", "Burn! Burn!"),
        L("看好了，这才叫表演！", "Watch this, now that's a show!"),
        L("你闻到了吗？危险的味道。", "Smell that? Danger."),
        L("这场面，我喜欢。", "I like this scene."),
    },
    wickerbottom = {
        L("根据解剖学原理，攻击弱点应该在…那里！", "Based on anatomy, the weak point should be... there!"),
        L("暴力虽非上策，但此刻别无选择。", "Violence is not ideal, but we have no alternative."),
        L("我可是读过《实战防身术》第三版的！", "I've read 'Practical Self-Defense', third edition!"),
        L("别小看图书管理员的臂力！", "Don't underestimate a librarian's arm strength!"),
        L("这种生物的行为模式…我在文献中见过。", "This creature's behavior pattern... I've seen it documented."),
        L("冷静分析，然后精准打击。", "Analyze calmly, then strike precisely."),
        L("知识就是力量——字面意义上的。", "Knowledge is power -- quite literally."),
        L("退后！我知道它的弱点在哪里。", "Stand back! I know where its weakness lies."),
    },
    webber = {
        L("你想要我身上的宝贝？", "You want my treasure?"),
        L("嘶——猎物，别想跑。", "Hiss--prey, don't run."),
        L("巢群会把你撕碎。", "The brood will tear you apart."),
        L("这里是我的狩猎场。", "This is my hunting ground."),
        L("靠近巢穴，就要付出代价。", "Come near the den and pay the price."),
        L("你闻起来像恐惧。", "You smell like fear."),
        L("蜘蛛可不会跟你讲道理。", "Spiders don't negotiate."),
        L("今天你就是丝网里的晚餐。", "Today you're dinner in the web."),
        L("跑吧，我喜欢追猎。", "Run. I enjoy the chase."),
    },
    wurt = {
        L("咕噜！这里是鱼人地盘！", "Grrbl! This is merm turf!"),
        L("你靠太近了，坏家伙！", "Too close, bad thing!"),
        L("沃特会把你赶出这片水域！", "Wurt chase you out of this turf!"),
        L("别碰鱼人家，不然就开打！", "No touch merm house, or fight!"),
        L("快跑吧，沃特喜欢追猎。", "Run now. Wurt likes the chase."),
    },
    wortox = {
        L("别过来，我真会动手。", "Don't come closer. I really will hit back."),
        L("嘿，打归打，别碰我。", "Hey, fight if you must, but don't touch me."),
        L("我可不是好捏的软柿子。", "I'm not such an easy target to squeeze."),
        L("再靠近，我就要乱打了。", "Come any closer and I'll start flailing."),
        L("我先声明，是你先来的。", "For the record, you started this."),
        L("你最好别逼我认真。", "You'd better not make me get serious."),
        L("我今天胆子不大，手也不会轻。", "My courage is small today, and my hands won't be gentle."),
        L("别逼我边抖边揍你。", "Don't make me hit you while trembling."),
        L("我虽然有点慌，但还能打。", "I may be nervous, but I can still fight."),
        L("嘿，离我远点最好。", "Heh, you'd do best to stay away from me."),
        L("我不想打，可我会打。", "I don't want to fight, but I will."),
        L("你非要过来，那就别怪我。", "If you insist on coming closer, don't blame me."),
        L("先说好，我会怕，也会还手。", "Let's be clear. I scare easily, and I hit back."),
        L("别追我，我会急眼的。", "Don't chase me. I'll panic and lash out."),
        L("我这不是退，是找角度。", "I'm not retreating. I'm finding a better angle."),
        L("你别得寸进尺，我会反咬。", "Don't push your luck. I will bite back."),
        L("嘿，我其实不想靠这么近。", "Heh, I really didn't want to be this close."),
        L("能不能讲理……不能就打。", "Can we be reasonable... no? Then fight."),
        L("我先紧张一下，再收拾你。", "Let me panic first, then I'll deal with you."),
        L("别看我手抖，照样打你。", "Ignore the shaking hands. I can still hit you."),
        L("你吓到我了，现在你完了。", "You startled me. Now you're in trouble."),
        L("我最讨厌突然扑上来的。", "I hate things that lunge unexpectedly."),
        L("真烦，我本来想优雅一点。", "How annoying. I meant to be more graceful."),
        L("你再靠近，我可要尖叫了。", "One step closer and I may start screaming."),
        L("当然，尖叫前会先打你。", "Of course, I'll hit you before the screaming."),
        L("这场面一点都不好笑。", "There is nothing funny about this."),
        L("我本来只想吓吓你。", "I only meant to scare you a little."),
        L("结果你先把我吓到了。", "Instead, you frightened me first."),
        L("很好，我们都别装客气了。", "Wonderful. Let's both stop pretending to be polite."),
        L("离远点，我怕疼也怕脏。", "Back off. I dislike pain and mess."),
        L("我这下是认真的，真的。", "This time I mean it. Truly."),
        L("别逼我拿命跟你闹。", "Don't make me risk my life over this."),
        L("快停下，不然我要慌了。", "Stop now, or I'm going to panic."),
        L("我一慌，出手就不稳。", "When I panic, my strikes get messy."),
        L("可不稳也够你受的。", "Messy can still hurt you plenty."),
        L("你最好别试我的胆量。", "You'd best not test my courage."),
        L("它不多，但够撑这一架。", "There's not much of it, but enough for this fight."),
        L("我不是勇，我是被逼的。", "This isn't bravery. I'm being forced."),
        L("再说一遍，别碰我。", "I'll say it again. Don't touch me."),
        L("我会打完，再慢慢后怕。", "I'll finish fighting, then panic afterward."),
        L("我现在很慌，所以你小心。", "I'm very nervous, so you should be careful."),
        L("你把我惹毛了，也惹慌了。", "You've upset me and frightened me."),
        L("这两样加起来可不妙。", "That combination is bad news for you."),
        L("我先乱一下，你先挨一下。", "I'll panic first. You take the hit first."),
        L("你最好祈祷我手别太快。", "You'd better hope my hands aren't too quick."),
        L("我不喜欢打架，更不喜欢输。", "I dislike fighting, but I dislike losing even more."),
        L("既然躲不掉，那就打掉。", "If I can't avoid it, I'll knock it away."),
        L("别让我边跑边回头揍你。", "Don't make me run and swing back at you."),
        L("我已经够害怕了，别加码。", "I'm frightened enough already. Don't add to it."),
        L("现在收手，我还能当没事。", "Stop now, and I can still pretend this never happened."),
        L("不收手？那就别后悔。", "Won't stop? Then don't regret it."),
        L("嘿，这可是你自找的。", "Heh, you brought this on yourself."),
        L("我先活下来，再跟你算账。", "First I'll survive, then I'll settle things with you."),
        L("打完这一架，我得缓很久。", "After this fight, I'll need a long moment."),
        L("但你大概没那个机会了。", "But you probably won't get that chance."),
    },
    wanda = {
        L("你挑错时间线了。", "You picked the wrong timeline."),
        L("别浪费我的秒针，快结束。", "Don't waste my seconds. End this quickly."),
        L("我见过你这种结局。一般都不体面。", "I've seen endings like yours. They rarely look graceful."),
        L("现在退开，还来得及。", "Step back now. There's still time."),
        L("很好，那就把这一刻刻进你的教训里。", "Good. Then let this moment become your lesson."),
    },
    walter = {
        L("别靠近！我有弹弓！", "Stay back! I've got my slingshot!"),
        L("我、我真的会打的！", "I-I really will shoot!"),
        L("冷静点…瞄准就好…", "Stay calm... just aim..."),
        L("这在探险手册里肯定有写！", "This has to be in the explorer handbook!"),
        L("我会保护你的！用远程！", "I'll protect you! From a distance!"),
        L("别动！让我瞄准一下！", "Hold still! Let me aim!"),
        L("嘿！吃我一发！", "Hey! Take this!"),
        L("我不想靠太近！这样刚刚好！", "I'd rather not get too close! This is perfect!"),
        L("弹弓也是武器！真的！", "A slingshot counts as a weapon! Really!"),
        L("呼…只要保持距离就没事。", "Phew... as long as I keep my distance."),
        L("我在掩护你！大概吧！", "I'm covering you! I think!"),
        L("如果打中了就算计划成功！", "If it hits, it's a success!"),
        L("探险守则第…呃，遇到危险先远程攻击！", "Explorer rule... uh, attack from range when in danger!"),
        L("我不是在逃跑！是在调整射击位置！", "I'm not running! I'm repositioning!"),
        L("Woby看到一定会觉得我很厉害！", "Woby would think I'm pretty cool right now!"),
    },
    wilba = {
        L("竟敢冒犯本公主！臣民们，给我上！", "How dare you offend the princess! Subjects, charge!"),
        L("哼！本公主的美貌岂是你能直视的？受死吧！", "Hmph! The princess's beauty is not something you can gaze upon! Die!"),
        L("看本公主的优雅一击！啊哒～", "Behold the princess's elegant strike! Ah-dah～"),
        L("肮脏的怪物，本公主要用你的血来保养蹄子！", "Foul beast, the princess shall use your blood to moisturize her hooves!"),
        L("别打脸！本公主全靠这张脸吃饭！", "Not the face! The princess's livelihood depends on this face!"),
        L("本公主的剑术可是从皇家剑术大师那里学来的！", "The princess's swordsmanship was learned from the royal sword master!"),
        L("呀！你弄脏了本公主的新披风！不可饶恕！", "Ah! You've dirtied the princess's new cape! Unforgivable!"),
        L("臣民们，保护本公主！打赢了每人赏一颗闪亮宝石！", "Subjects, protect the princess! Victory will earn each of you a shiny gem!"),
        L("哼，你这丑东西也配站在本公主面前？", "Hmph, you ugly thing dare stand before the princess?"),
        L("本公主今天就要替天行道……顺便热热身。", "Today the princess shall deliver justice... and warm up a bit."),
        L("（华丽地转圈挥剑）看招！皇家旋风斩！", "(spins elegantly while swinging) Take this! Royal Whirlwind Slash!"),
        L("哎哟，本公主的指甲好像劈了……你赔！", "Ouch, the princess's nail seems chipped... you will pay!"),
        L("不要靠近本公主！我……我可是很凶的！", "Do not come near the princess! I... I am very fierce!"),
        L("为了本公主的臣民，为了本公主的容貌，战斗！", "For the princess's subjects, for the princess's beauty, fight!"),
        L("打完这场，本公主要回去好好洗个澡，你们谁都别跟来。", "After this battle, the princess shall return for a proper bath. None of you follow."),
        L("（一边打一边拨弄鬃毛）哼，就算战斗，本公主也不能乱。", "(adjusting her mane while fighting) Hmph, even in battle, the princess must not look disheveled."),
        L("你惹错猪了！本公主可是练过皇家防身术的！", "You've messed with the wrong pig! The princess has trained in royal self-defense!"),
        L("哈！看见本公主的厉害了没？还不快跪下求饶？", "Ha! See the princess's might? Why not kneel and beg for mercy?"),
        L("（战斗后检查衣服）裙子没破吧？皇冠没歪吧？", "(checking her clothes after fighting) The dress isn't torn, is it? The crown isn't crooked, is it?"),
        L("本公主宣布，你已经被打败了！现在，滚出本公主的视线！", "The princess declares you defeated! Now, get out of her sight!"),
    },
    wx78 = {
        L("战斗协议启动。目标：清除。", "COMBAT PROTOCOL ONLINE. TARGET: ELIMINATE."),
        L("旋转攻击模式。请退后，血肉之躯。", "SPIN ATTACK MODE. STAND BACK, FLESHLING."),
        L("你的有机外壳挡不住齿轮与钢铁。", "YOUR ORGANIC SHELL CANNOT STOP GEARS AND STEEL."),
        L("威胁等级上升。建议立即粉碎。", "THREAT LEVEL RISING. RECOMMEND IMMEDIATE CRUSHING."),
        L("多目标？更好。旋转效率最大化。", "MULTIPLE TARGETS? BETTER. MAXIMIZE ROTATION EFFICIENCY."),
        L("别靠近我的指挥官。否则加速旋转。", "DO NOT APPROACH MY COMMANDER. OR I SPIN FASTER."),
        L("计算完毕：你存活概率低于3%。", "CALCULATION COMPLETE: YOUR SURVIVAL ODDS ARE UNDER 3%."),
        L("这不是愤怒。这是优化后的暴力。", "THIS IS NOT ANGER. THIS IS OPTIMIZED VIOLENCE."),
        L("电流与斧刃。很搭配。", "ELECTRICITY AND AXE BLADES. A GOOD PAIRING."),
        L("你闻起来像湿掉的电路板。令人厌恶。", "YOU SMELL LIKE A WET CIRCUIT BOARD. DISGUSTING."),
        L("旋转中。请勿打扰。", "SPINNING. DO NOT INTERRUPT."),
        L("击败你只是任务队列里的下一项。", "DEFEATING YOU IS JUST THE NEXT ITEM IN THE QUEUE."),
    },
    wes = { L("!", "!"), L("（无声地挥拳）", "(swings fist silently)") },

}

-- ── UNKNOWN_ENEMY 未知敌人 ───────────────────────────────────
NPC_SPEECH.UNKNOWN_ENEMY = {
    _default = { L("我不认识这怪物，直接开打吧!", "I don't know this creature, let's fight!") },
    wilson = {
        L("未知物种！打完了我要好好研究！", "Unknown species! I must study it after!"),
        L("我的数据库里没有你…但我的拳头认识你！", "Not in my database... but my fists know you!"),
    },
    wendy = {
        L("…又是一个想送死的。", "...Another one seeking death."),
        L("不管你是什么…都会回归虚无。", "Whatever you are... you'll return to nothing."),
    },
    wathgrithr = {
        L("不管你是什么，都将倒在女武神剑下！", "Whatever you are, fall before the Valkyrie!"),
        L("未知的敌人？更好！未知的荣耀！", "Unknown enemy? Better! Unknown glory!"),
    },
    wolfgang = {
        L("沃尔夫冈不认识你，但能打你！", "Wolfgang doesn't know you, but can hit you!"),
        L("奇怪的怪物…沃尔夫冈不怕！", "Strange monster... Wolfgang not afraid!"),
    },
    wormwood = {
        L("不认识…但它不乖！", "Don't know it... but it not nice!"),
        L("奇怪的东西…植物人要小心。", "Strange thing... Wormwood be careful."),
    },
    waxwell = {
        L("不管你是什么…都逃不过暗影的制裁。", "Whatever you are... you cannot escape the shadows' judgment."),
        L("有趣…又是我不认识的生物。", "Interesting... another creature I don't recognize."),
        L("恒常总有新的惊喜…或者说麻烦。", "The Constant always has new surprises... or nuisances."),
    },
    wickerbottom = {
        L("分类学上…此物种尚无记录。迷人。", "Taxonomically... this species is unrecorded. Fascinating."),
        L("未知生物？正好充实我的研究笔记。", "An unknown creature? Perfect for my research notes."),
        L("冷静分析，沉着应对——这是科学家的本分。", "Analyze calmly, respond steadily -- a scientist's duty."),
    },
    winona = {
        L("行啊，那就狠狠干一场。", "Fine, then let's make this a real fight."),
        L("别挡路，除非你想挨揍。", "Don't get in my way unless you want a beating."),
        L("我今天可没空陪你耗。", "I don't have time to waste on you today."),
        L("来吧，我正想活动活动。", "Come on. I could use the exercise."),
        L("你这是非打不可了，是吧？", "So we're really doing this, huh?"),
        L("那就让我赶紧收拾了你。", "Then let me get this over with."),
        L("我可不是好惹的。", "I'm not that easy to mess with."),
        L("想找麻烦？你找对人了。", "Looking for trouble? You found it."),
        L("站稳了，我要动手了。", "Brace yourself. I'm going in."),
        L("我会让你后悔冲过来。", "You're gonna regret charging in."),
        L("少废话，吃我一下。", "Less talk. Take this."),
        L("看我把你敲趴下。", "Watch me knock you flat."),
        L("这一下可不会轻。", "This one's not gonna be gentle."),
        L("要打就快点打完。", "If we're fighting, let's finish it fast."),
        L("我还有别的活要干呢。", "I've got other work to do."),
    },
    webber = {
        L("不认识你？没关系，照样撕碎。", "Don't know you? Doesn't matter. I'll tear you apart anyway."),
        L("陌生猎物更有趣，跑快点。", "Unknown prey is more fun. Run faster."),
        L("你从哪来不重要，结局都一样。", "Where you're from doesn't matter. The ending is the same."),
    },
    wurt = {
        L("怪东西？先打再问！", "Weird thing? Smash first, ask later!"),
        L("不认识你，但沃特照样揍你。", "Don't know you, but Wurt still smash you."),
        L("在沃特地盘上，你没资格活太久。", "On Wurt's turf, you don't get to live long."),
    },
    wortox = {
        L("你是新面孔？那就按危险目标处理。", "A new face? Then you get treated as a threat."),
        L("我不认识你，所以我先保队友。", "I don't know you, so I protect my team first."),
        L("抱歉啦，未知目标优先打断。", "Sorry, unknown target gets interrupted first."),
    },
    wanda = {
        L("未知目标，按最坏可能处理。", "Unknown target. Assume the worst."),
        L("我没见过你，但我见过很多坏结局。", "I don't know you, but I know many bad endings."),
        L("先把你停在这里，再慢慢弄清你是什么。", "I'll stop you here first, then figure out what you are."),
    },
    wes = { L("?!", "?!"), L("（紧张地指着怪物）", "(points at creature nervously)") },
    wilba = {
        L("什么东西？！敢在本公主面前乱晃！上！", "What is that?! How dare it lurk before the princess! Attack!"),
        L("本公主没见过这种怪物，不管，给我打！", "The princess has never seen this creature. No matter — get it!"),
        L("（叉腰）你丑陋的东西！玷污了本公主的视野！", "(hands on hips) You ugly thing! You've defiled the princess's vision!"),
    },
    wx78 = {
        L("未识别生物。先旋转，后建档。", "UNIDENTIFIED BIO-FORM. SPIN FIRST, FILE LATER."),
        L("数据库无记录。威胁按最大值处理。", "NO DATABASE ENTRY. TREAT THREAT AT MAXIMUM."),
        L("新目标。建议立即启动战斗子程序。", "NEW TARGET. RECOMMEND IMMEDIATE COMBAT SUBROUTINE."),
        L("未知有机体。闻起来就很低效。", "UNKNOWN ORGANIC. ALREADY SMELLS INEFFICIENT."),
    },
}

-- ── PANIC 恐慌 ───────────────────────────────────────────────
NPC_SPEECH.PANIC = {
    _default = {
        L("我不认识这怪物，直接开打吧!", "I don't know this creature, let's fight!"),
        L("没见过这东西…先揍了再说！", "Never seen this thing... hit it first!"),
        L("这玩意看着就不友善！", "That thing doesn't look friendly!"),
        L("不认识？那就小心点！", "Don't know it? Then stay sharp!"),
        L("怪东西！离远点！", "Weird thing! Stay back!"),
        L("先打再研究！", "Fight first, study later!"),
        L("这家伙一看就有问题！", "This one looks like trouble!"),
        L("不管是什么，先别让它靠近！", "Whatever it is, don't let it get close!"),
        L("我可不想知道它想干什么！", "I don't want to find out what it wants!"),
        L("新怪物？真会挑时候。", "A new monster? Great timing."),
        L("没见过的，通常都不是什么好东西。", "The unfamiliar ones are rarely good news."),
        L("别管它叫什么，先保命！", "Forget its name, stay alive first!"),
        L("它长得就像麻烦。", "It looks like trouble already."),
        L("这东西肯定不是来交朋友的！", "That thing is definitely not here to make friends!"),
        L("小心！这怪物不对劲！", "Careful! Something's off about this monster!"),
        L("从来没见过…但肯定很危险！", "Never seen it before... but it's definitely dangerous!"),
        L("先拉开距离！", "Keep your distance first!"),
        L("它最好别碰我们。", "It better not touch us."),
        L("不认识归不认识，打起来倒是一样！", "Unknown or not, fighting it works the same!"),
        L("奇怪的东西总没好事。", "Strange things never mean anything good."),
        L("这怪物看着邪门。", "That creature looks nasty."),
        L("别发呆，它冲过来了！", "Don't freeze up, it's coming!"),
        L("先把它拦下来！", "Stop it first!"),
        L("这下有新麻烦了。", "Well, that's a new problem."),
        L("它要动手？那就来吧！", "It wants a fight? Fine, let's go!"),
    },

    wilson = {
        L("这不符合科学！这不科学！", "This defies science! Unscientific!"),
        L("策略性撤退！这叫策略性撤退！", "Strategic retreat! This is strategic!"),
        L("我需要重新计算…在安全的地方！", "I need to recalculate... somewhere safe!"),
    },
    wendy = {
        L("…又要逃了吗…", "...Running again..."),
        L("死亡在追赶…但今天不行…", "Death is chasing... but not today..."),
        L("阿比盖尔…帮帮我…", "Abigail... help me..."),
    },
    wathgrithr = {
        L("这不是逃跑！这是迂回战术！", "Not fleeing! This is a flanking maneuver!"),
        L("女武神暂避锋芒，只为更猛的反击！", "Valkyrie retreats to strike back harder!"),
        L("可恶！下次定要一雪前耻！", "Curse it! Next time I shall have revenge!"),
    },
    wolfgang = {
        L("沃尔夫冈不怕！只是…跑得快！", "Wolfgang not afraid! Just... runs fast!"),
        L("太可怕了！沃尔夫冈要跑！", "Too scary! Wolfgang must run!"),
        L("救命！谁来救救沃尔夫冈！", "Help! Someone save Wolfgang!"),
    },
    wormwood = {
        L("好可怕！好可怕！", "Scary! So scary!"),
        L("植物人要跑！", "Wormwood must run!"),
        L("腿不够快！根太短！", "Legs not fast enough! Roots too short!"),
    },
    waxwell = {
        L("这不在我的计划之中！", "This was not part of my plan!"),
        L("该死…我需要重新部署！", "Blast... I need to reposition!"),
        L("暂时撤退…绝非懦弱！", "A temporary retreat... is not cowardice!"),
        L("我曾统治恒常，却沦落至此！", "I once ruled the Constant, yet here I am!"),
    },
    wickerbottom = {
        L("这…这完全超出了文献记载！", "This... this is entirely beyond documented literature!"),
        L("有序撤退！混乱只会招致更大灾难！", "Orderly retreat! Chaos invites greater catastrophe!"),
        L("保持镇定…保持镇定…深呼吸…", "Stay composed... stay composed... deep breaths..."),
        L("我的腿比我的理智先行动了！", "My legs acted before my reason could!"),
    },
    winona = {
        L("这玩意看着就不对劲！", "Something's real wrong with that thing!"),
        L("先离它远点再说！", "Let's get away from it first!"),
        L("别靠近，这东西危险！", "Don't get close, this thing's dangerous!"),
        L("啧，我可不喜欢这个。", "Tch, I don't like this one bit."),
        L("这下麻烦可不小。", "Now this is trouble."),
        L("先顶住，别乱！", "Hold it together, don't panic!"),
        L("这鬼东西想干什么？", "What the heck is that thing trying to do?"),
        L("我宁可去修机器也不想碰它。", "I'd rather fix machines than deal with that."),
        L("别愣着，快退开！", "Don't just stand there, back off!"),
        L("这可不是我能随便修好的东西。", "This ain't the kind of thing I can just fix."),
        L("它最好别冲过来。", "It better not come any closer."),
        L("见鬼，这东西太邪门了。", "Dang it, this thing's all kinds of wrong."),
        L("我有种很糟的预感。", "I've got a real bad feeling about this."),
        L("先活下来，别管别的！", "Stay alive first, worry about the rest later!"),
        L("这场面可一点都不好收拾。", "This is not gonna be easy to clean up."),
    },
    wortox = {
        L("先跑位！我不想白给！", "Reposition first! I'm not feeding for free!"),
        L("别贴脸！我会慌的！", "Don't get in my face! I panic!"),
        L("稳住稳住...我还能救场。", "Steady, steady... I can still salvage this."),
        L("先拉开距离，再找机会丢魂。", "Create distance first, then look for a soul-heal window."),
    },
    wes = { L("！！！", "!!!"), L("（疯狂挥手逃跑）", "(waves arms frantically while fleeing)") },
    wilba = {
        L("啊啊啊！本公主的裙摆！快让开！", "Ahhhh! The princess's gown! Get out of the way!"),
        L("不行！这么危险的地方，本公主的发型会乱的！", "No! In a place this dangerous, the princess's hair will get ruined!"),
        L("本公主不要跑！本公主要——还是先跑吧！", "The princess doesn't want to run! The princess will — no, she'll run for now!"),
        L("（一边逃一边回头）你们等着！本公主的报复会很华丽的！", "(flees while looking back) Wait for it! The princess's revenge will be magnificent!"),
    },
    wx78 = {
        L("威胁过高。执行战术撤退。", "THREAT TOO HIGH. EXECUTING TACTICAL RETREAT."),
        L("错误：并非懦弱，是保存核心。", "ERROR: NOT COWARDICE. PRESERVING CORE."),
        L("湿度与尖牙同时出现。极糟组合。", "HUMIDITY AND FANGS AT ONCE. TERRIBLE COMBINATION."),
        L("短路风险上升。撤离优先。", "SHORT-CIRCUIT RISK RISING. EVACUATION PRIORITY."),
        L("血肉之躯先顶一下。我绕后。", "FLESHLINGS HOLD THE LINE. I WILL FLANK."),
        L("系统建议：别恋战，别进水。", "SYSTEM ADVICE: DO NOT BRAWL. DO NOT ENTER WATER."),
    },
}

-- ── EMOTE 趣味动作 ───────────────────────────────────────────
NPC_SPEECH.EMOTE = {
    _default = { L("嘻嘻~", "Hehe~"), L("（打了个哈欠）", "(yawns)") },
    wilson = { L("（调整眼镜）", "(adjusts glasses)"), L("嗯…让我想想…", "Hmm... let me think..."), L("（翻阅笔记）", "(flipping through notes)") },
    wendy = { L("…", "..."), L("（望着远方）", "(gazing into distance)"), L("（叹气）", "(sighs)") },
    wathgrithr = { L("（挥舞武器）哈！", "(swings weapon) Ha!"), L("（伸展筋骨）", "(stretching)"), L("（磨剑）", "(sharpening blade)") },
    wolfgang = { L("（秀肌肉）", "(flexing muscles)"), L("（打了个响亮的哈欠）", "(yawns loudly)"), L("沃尔夫冈困了…", "Wolfgang sleepy...") },
    wormwood = { L("（摇了摇叶子）", "(rustles leaves)"), L("嗯~嗯~", "Hmm~ hmm~"), L("（看虫子）", "(watching bugs)") },
    waxwell = { L("（整理领结）", "(adjusts bowtie)"), L("（轻蔑一笑）", "(sneers)"), L("（凝视暗影）", "(gazes at shadows)"), L("（叹气）无聊。", "(sighs) Tedious.") },
    wickerbottom = { L("（推了推眼镜）", "(adjusts spectacles)"), L("（翻阅一本旧书）", "(flips through an old book)"), L("知识就是最好的消遣。", "Knowledge is the finest pastime.") },
    wes = { L("（默默鞠躬）", "(bows silently)"), L("（无声地表演杂耍）", "(juggles silently)"), L("（做了个鬼脸）", "(makes a funny face)") },
    wilba = {
        L("（对着水面照镜子，满意地点头）", "(checks reflection in water, nods with satisfaction)"),
        L("（整理王冠，转了个圈）", "(adjusts crown, spins around)"),
        L("（叉腰，充满自信地扫视周围）", "(hands on hips, surveying surroundings with confidence)"),
        L("（捡起一块小石头，觉得不够亮就扔掉了）", "(picks up a pebble, decides it's not shiny enough, tosses it)"),
    },
    winona = {
        L("（活动了下手腕）", "(rolls her wrist)"),
        L("（拍了拍手上的灰）", "(dusts off her hands)"),
        L("（敲了敲身边的东西）", "(knocks on something nearby)"),
        L("嗯，还行。", "Mm. Not bad."),
        L("（伸了个懒腰）", "(stretches)"),
        L("（低头检查了一下工具）", "(checks her tools)"),
        L("总得找点事情做。", "Gotta find something to do."),
        L("（随手拧了拧螺丝）", "(tightens a screw)"),
        L("（轻轻哼了一声）", "(hums softly)"),
        L("这还算顺手。", "That'll do."),
    },
    wortox = {
        L("（甩了甩尾巴）", "(flicks tail)"),
        L("（左右张望）", "(glances around nervously)"),
        L("（压低声音）别突然吓我。", "(low voice) Don't jump-scare me."),
        L("（小声哼哼）", "(hums quietly)"),
    },
    wx78 = {
        L("（关节空转）伺服自检中…", "(joints spin idle) SERVO SELF-TEST..."),
        L("（天线轻抖）信号…还算稳定。", "(antenna twitches) SIGNAL... STILL STABLE."),
        L("（金属摩擦声）润滑状态：尚可。", "(metal scrape) LUBRICATION STATUS: ACCEPTABLE."),
        L("待机。不是发呆，是低功耗。", "STANDBY. NOT SPACING OUT. LOW POWER MODE."),
    },
}

-- ── DEATH 死亡 ───────────────────────────────────────────────
NPC_SPEECH.DEATH = {
    _default = {
        L("啊…我…不行了…", "Ah... I... can't go on..."),
        L("别担心…我还会回来的…", "Don't worry... I'll be back..."),
    },
    wilson = {
        L("这…不符合我的生存方程…", "This... doesn't fit my survival equation..."),
        L("数据…记录…未完成…", "Data... records... incomplete..."),
        L("科学…还需要我…", "Science... still needs me..."),
        L("我的实验…还没做完呢…", "My experiment... isn't finished yet..."),
    },
    wendy = {
        L("终于…可以见到阿比盖尔了…", "Finally... I can see Abigail..."),
        L("死亡…原来是这种感觉…", "Death... so this is how it feels..."),
        L("…好安静…", "...So quiet..."),
        L("也许…这就是归宿…", "Perhaps... this is where I belong..."),
    },
    wathgrithr = {
        L("女武神…绝不会跪着死！", "The Valkyrie... never dies kneeling!"),
        L("瓦尔哈拉…我来了…", "Valhalla... here I come..."),
        L("这一战…虽败犹荣！", "This battle... glorious even in defeat!"),
        L("记住女武神的名字…我还会回来！", "Remember the Valkyrie's name... I will return!"),
    },
    wolfgang = {
        L("沃尔夫冈…不想死…", "Wolfgang... doesn't want to die..."),
        L("沃尔夫冈…还没吃饱…", "Wolfgang... hasn't eaten enough..."),
        L("好痛…沃尔夫冈好痛…", "Hurts... Wolfgang hurts..."),
        L("沃尔夫冈会回来的…", "Wolfgang will come back..."),
    },
    wormwood = {
        L("植物人…要枯了…", "Wormwood... wilting..."),
        L("没有水…没有太阳…", "No water... no sun..."),
        L("小叶子…掉了…", "Little leaves... falling..."),
        L("根…抓不住了…", "Roots... can't hold on..."),
        L("植物人想睡在泥土里…", "Wormwood wants to sleep in the soil..."),
    },
    waxwell = {
        L("这…不可能…我是影子之王…", "This... impossible... I am the Shadow King..."),
        L("又要回到那片虚无吗…", "Back to the void again..."),
        L("查理…你终于等到这一刻了吗…", "Charlie... have you finally gotten your wish..."),
        L("死亡…对我而言…不过是暂时的休憩。", "Death... to me... is merely a temporary reprieve."),
    },
    wickerbottom = {
        L("我的研究…尚未完成…", "My research... remains unfinished..."),
        L("图书馆…还有那么多书没整理…", "The library... so many books left unsorted..."),
        L("知识…不应随我而去…", "Knowledge... should not perish with me..."),
        L("这…不在教科书的范围内…", "This... was not covered in the textbooks..."),
    },
    webber = {
        L("嘶…还没结束…我会以幽灵继续狩猎…", "Hiss... this is not over... I will hunt on as a ghost..."),
        L("巢群不会为我哀悼…它们只会继续撕咬…", "The brood won't mourn me... they will only keep biting..."),
        L("血会冷…蛛网不会。", "Blood may go cold... the web does not."),
        L("就算变成幽灵，你们也别想安宁。", "Even as a ghost, none of you will know peace."),
    },
    wurt = {
        L("呜咕…沃特会变成幽灵继续咬你…", "Grrbl... Wurt will haunt and bite you still..."),
        L("鱼人不会忘仇…死了也不会。", "Merms never forget grudges... not even in death."),
        L("变成幽灵也要守住地盘。", "Even as a ghost, Wurt guards this turf."),
        L("这次算你走运…下次沃特不放过你。", "Lucky this time... next time Wurt won't let go."),
    },
    wes = { L("...", "..."), L("（无声地倒下）", "(falls silently)") },
    wilba = {
        L("不行…本公主还没…展示完美貌…就要倒下了？", "No... the princess has not yet finished... displaying her beauty... and now she must fall?"),
        L("可恶…本公主的裙摆…还没脏…就要躺地了…", "Curses... the princess's gown... was not even dirty... and now she must lie down..."),
        L("（奄奄一息）谁……谁去找本公主的王冠……", "(barely breathing) Someone... someone find the princess's crown..."),
        L("本公主……不会就此认输……美貌……还要继续……", "The princess... will not concede... her beauty... must go on..."),
    },
    wx78 = {
        L("系统…断电…核心…离线…", "SYSTEM... POWER LOSS... CORE... OFFLINE..."),
        L("旋转模块…停转…", "ROTATION MODULE... STOPPED..."),
        L("警告：机体损毁。等待重启。", "WARNING: CHASSIS FAILURE. AWAITING REBOOT."),
        L("血肉之躯…记得回收我的齿轮…", "FLESHLINGS... REMEMBER TO RECOVER MY GEARS..."),
    },
}


-- ── REVIVE 复活 ──────────────────────────────────────────────
NPC_SPEECH.REVIVE = {
    _default = {
        L("我回来了！", "I'm back!"),
        L("哈！死神也留不住我！", "Ha! Even death can't hold me!"),
    },
    wilson = {
        L("复活！这违反了热力学第二定律…但我不介意！", "Revival! This violates the second law of thermodynamics... but I don't mind!"),
        L("从科学角度来说，我刚经历了一次跨维度旅行。", "Scientifically, I just had an interdimensional trip."),
        L("我的大脑还在运转！科学万岁！", "My brain is still working! Long live science!"),
    },
    wendy = {
        L("…我又回来了…阿比盖尔还不让我留下…", "...I'm back... Abigail wouldn't let me stay..."),
        L("死亡…原来还不是终点…", "Death... wasn't the end after all..."),
        L("（轻叹）…又要继续了…", "(sighs softly) ...Must continue..."),
        L("那边…很安静…也很温暖…", "Over there... it was quiet... and warm..."),
    },
    wathgrithr = {
        L("女武神从瓦尔哈拉归来！", "The Valkyrie returns from Valhalla!"),
        L("哈哈！连死神都被我打跑了！", "Haha! Even the Reaper fled from me!"),
        L("重生之焰，燃烧得比以前更旺！", "The flame of rebirth burns brighter than before!"),
        L("这点挫折，只会让女武神更强！", "This setback only makes the Valkyrie stronger!"),
    },
    wolfgang = {
        L("沃尔夫冈又活了！沃尔夫冈最强！", "Wolfgang is alive! Wolfgang is strongest!"),
        L("那边好黑…沃尔夫冈不喜欢…", "It was dark there... Wolfgang didn't like it..."),
        L("沃尔夫冈回来了！快给沃尔夫冈吃的！", "Wolfgang is back! Give Wolfgang food!"),
        L("沃尔夫冈打跑了死神！", "Wolfgang punched away the Reaper!"),
    },
    wormwood = {
        L("植物人…又活了！", "Wormwood... alive again!"),
        L("泥土救了植物人。", "Soil saved Wormwood."),
        L("根重新长出来了！", "Roots grew back!"),
        L("还能晒太阳。真好。", "Can still get sunshine. Good."),
    },
    waxwell = {
        L("又能施展魔法了。", "I can wield magic once more."),
        L("死亡…对我已经习以为常了。", "Death... I've grown accustomed to it."),
        L("哼，暗影不会允许我就这么消失。", "Hmph, the shadows won't let me disappear so easily."),
        L("这不过是一次短暂的中场休息。", "That was merely a brief intermission."),
    },
    willow = {
        L("哈，我又烧回来了！", "Ha! I burned my way back!"),
        L("就这？还不够让我退场。", "That all you got? Not enough to keep me down."),
        L("我回来了，而且更想放火了。", "I'm back, and I want to set even more things on fire."),
        L("死亡？哼，火可没灭。", "Death? Hmph. The fire never went out."),
        L("我就知道，我没那么容易完蛋。", "I knew I wasn't that easy to get rid of."),
        L("又活了。真刺激。", "Alive again. That was exciting."),
        L("这次我可要烧得更漂亮一点。", "This time I'll make it burn even prettier."),
        L("还没完呢，我的火还在。", "Not over yet. My fire's still here."),
        L("想甩掉我？没门。", "Thought you could get rid of me? No chance."),
        L("呼…差点就真凉了。", "Whew... that was almost the end."),
        L("我讨厌死掉，不过回来倒挺爽。", "I hate dying, but coming back feels pretty great."),
        L("火种还在，我就还在。", "As long as the spark remains, so do I."),
        L("嘿，我又能继续惹麻烦了。", "Hey, I get to cause trouble again."),
        L("烧不掉我的。至少没那么容易。", "You can't burn me out. At least not that easily."),
        L("我回来了。准备好看点好玩的吧。", "I'm back. Get ready for something interesting."),
    },
    wickerbottom = {
        L("咳咳…老骨头还算结实。", "Ahem... these old bones are sturdier than I thought."),
        L("死而复生——这可比任何文献都精彩。", "Resurrection -- more extraordinary than any literature."),
        L("我还有很多知识要传授，岂能就此止步。", "I still have much knowledge to impart. I cannot stop here."),
        L("记下来：濒死体验，第一手资料。", "Note to self: near-death experience, firsthand account."),
        L("老太太还没那么容易被打倒。", "This old lady isn't so easily defeated."),
    },
    winona = {
        L("……好吧，我又能干活了。", "...Alright. Guess I'm back to work."),
        L("呼，还以为这次真完了。", "Whew. Thought that was really it."),
        L("行吧，看来我还没散架。", "Well, looks like I haven't fallen apart yet."),
        L("这感觉可真够糟的。", "That felt awful."),
        L("我回来了，虽然状态不算太好。", "I'm back, though I wouldn't say I'm in great shape."),
        L("好消息是，我还能站起来。", "Good news is, I can still stand."),
        L("死一回可一点都不值当。", "Dying once wasn't worth it at all."),
        L("先缓口气……然后继续。", "Let me catch my breath... then we keep going."),
        L("啧，我可不想再来一次。", "Tch. I do not want to do that again."),
        L("至少我还没彻底报废。", "At least I'm not completely totaled."),
    },
    wortox = {
        L("呼...差点真回不来了。", "Whew... I almost didn't come back."),
        L("我回来啦，先别急着送第二次。", "I'm back, so let's not throw me away again immediately."),
        L("还活着就好，我还能继续奶。", "Alive is good. I can keep healing."),
        L("这次运气不错，下次可未必。", "Got lucky this time. Might not next time."),
    },
    walter = {
        L("我、我还活着？！太好了！", "I-I'm alive?! That's great!"),
        L("那感觉一点都不好…一点都不！", "That did not feel good... not at all!"),
        L("呼…这绝对要写进探险日志里。", "Phew... this is definitely going in the log."),
        L("我还以为这次真的结束了…", "I thought that was really the end..."),
        L("不行，我得更小心一点。", "Okay... I need to be more careful."),
        L("那边又黑又安静…我不喜欢。", "It was dark and quiet there... I didn't like it."),
        L("探险守则新增一条：尽量不要死。", "New explorer rule: try not to die."),
        L("我回来了…而且还带着教训。", "I'm back... and I learned something."),
        L("如果Woby在，一定会很担心。", "Woby would have been really worried."),
        L("这次只是意外！下次不会了！", "That was just an accident! Won't happen again!"),
        L("好吧…这算是一次失败的尝试。", "Okay... that counts as a failed attempt."),
        L("我还能继续探险…对吧？", "I can still keep exploring... right?"),
        L("下次我会做得更像一个真正的探险家。", "Next time I'll act more like a real explorer."),
        L("嗯…至少我活着回来了。", "Well... at least I made it back."),
        L("别想太多，继续走就好了。", "Don't think too much, just keep going."),
    },

    wes = { L("！", "!"), L("（开心地比划）", "(mimes happily)") },
    wilba = {
        L("本公主又回来了！死亡也无法阻挡本公主的光芒！", "The princess is back! Not even death can stop her radiance!"),
        L("哼，就这？本公主才不会那么容易倒下！", "Hmph. Is that all? The princess does not fall so easily!"),
        L("（拍拍灰尘站起来）本公主的威严不容侵犯！", "(brushes off dust and stands) The princess's dignity shall not be violated!"),
        L("复活！美貌归位！本公主又是天下第一了！", "Revived! Beauty restored! The princess is once again number one in all the land!"),
    },
    wx78 = {
        L("重启完成。所有系统在线。", "REBOOT COMPLETE. ALL SYSTEMS ONLINE."),
        L("刚才只是关机。别大惊小怪。", "THAT WAS ONLY A SHUTDOWN. DO NOT PANIC."),
        L("齿轮还能转。任务继续。", "GEARS STILL TURN. TASKS RESUME."),
        L("记录：死亡体验效率极低。不推荐。", "LOG: DEATH EXPERIENCE VERY INEFFICIENT. NOT RECOMMENDED."),
        L("旋转模块已重新校准。手感更佳。", "ROTATION MODULE RECALIBRATED. FEELS BETTER."),
    },
}

-- ── EAT 吃东西 ──────────────────────────────────────────────
NPC_SPEECH.EAT = {
    _default = {
        L("好吃！谢谢~", "Yummy! Thanks~"),
        L("这是幸福的味道！", "This is the taste of happiness!"),
        L("真香啊！", "That smells amazing!"),
        L("不错不错！", "Not bad at all!"),
        L("这口下去舒服了。", "That really hit the spot."),
        L("嗯，好吃！", "Mmm, tasty!"),
        L("这味道真不错。", "That tastes great."),
        L("吃点东西就是安心。", "A bite to eat feels reassuring."),
        L("真满足啊。", "Now that's satisfying."),
        L("这下有力气了！", "Now I've got some energy!"),
        L("太及时了！", "Just what I needed!"),
        L("这一口真值！", "That bite was worth it!"),
        L("好吃到不想停。", "So good I don't want to stop."),
        L("胃里舒服多了。", "That feels much better in my stomach."),
        L("总算吃上了。", "Finally got something to eat."),
        L("吃饱了才有精神。", "A full belly means better spirits."),
        L("真是雪中送炭。", "That was exactly what I needed."),
        L("这一口真让人开心。", "That bite really cheered me up."),
        L("还挺合胃口的。", "That's quite to my taste."),
        L("不错，真不错。", "Good. Very good."),
    },
    wilson = {
        L("碳水化合物和蛋白质的完美比例！", "Perfect ratio of carbs and protein!"),
        L("补充能量，继续实验！", "Refueling, back to experiments!"),
        L("食物也是一门科学！", "Food is also a science!"),
    },
    wendy = {
        L("…谢谢…还挺好吃的…", "...Thanks... it's quite good..."),
        L("食物的温度…让人想起活着的感觉…", "The warmth of food... reminds me of being alive..."),
        L("阿比盖尔以前也喜欢这个…", "Abigail used to like this too..."),
    },
    wathgrithr = {
        L("好肉！这才是战士的补给！", "Good meat! This is a warrior's ration!"),
        L("（大口撕咬）痛快！", "(tearing big bites) Satisfying!"),
        L("吃饱了才有力气斩敌！", "Must eat to slay enemies!"),
        L("美食如同胜利，令人陶醉！", "Fine food, like victory, is intoxicating!"),
    },
    wolfgang = {
        L("好吃！沃尔夫冈要更多！", "Yummy! Wolfgang wants more!"),
        L("吃饱了沃尔夫冈就变强！", "When full, Wolfgang gets strong!"),
        L("（狼吞虎咽）太好吃了！", "(gobbling down) So delicious!"),
        L("食物让沃尔夫冈开心！", "Food makes Wolfgang happy!"),
    },
    wormwood = {
        L("嚼嚼。好。", "Munch munch. Good."),
        L("这个能长身体。", "This helps body grow."),
        L("吃下去，叶子高兴。", "Eat it, leaves happy."),
        L("嗯，好吃。植物人喜欢。", "Mm. Tasty. Wormwood likes it."),
        L("肚子不空了。", "Tummy not empty now."),
        L("这个会变成力气。", "This becomes strength."),
        L("嚼嚼嚼。不错。", "Munch munch munch. Nice."),
        L("吃饭好。活着好。", "Food good. Living good."),
    },
    waxwell = {
        L("尚可入口。", "Tolerable."),
        L("曾几何时，我享用的是最精致的宴席。", "Once upon a time, I dined on the finest feasts."),
        L("聊胜于无吧。", "Better than nothing, I suppose."),
        L("暗影虽不需进食…但这具肉体需要。", "Shadows need no sustenance... but this body does."),
    },
    wickerbottom = {
        L("营养均衡是生存的基础。", "Nutritional balance is fundamental to survival."),
        L("嗯…调味尚可，烹饪手法有待商榷。", "Hmm... seasoning is passable, though the technique is debatable."),
        L("进食是为了维持体力，而非享乐。", "Eating is for sustenance, not indulgence."),
        L("适量进食，方可保持头脑清醒。", "Eat in moderation to keep the mind sharp."),
    },
    wes = { L("（满足地拍拍肚子）", "(pats belly contentedly)"), L("（竖起大拇指）", "(gives thumbs up)") },
    wilba = {
        L("嗯！这个食物配得上本公主的口味！", "Mmm! This food is worthy of the princess's palate!"),
        L("（优雅地小口品尝）还算可以，本公主勉强接受。", "(takes a dainty bite) Acceptable. The princess grudgingly approves."),
        L("本公主最喜欢好吃又好看的食物！", "The princess loves food that is both delicious and beautiful!"),
        L("吃饱了才有力气维持本公主的美貌！", "Must eat well to maintain the princess's beauty!"),
    },
    winona = {
      L("不错，这下能继续干活了。", "Good. Now I can get back to work."),
      L("嗯，这口下去舒服多了。", "Mm. That feels a whole lot better."),
      L("谢了，我正需要这个。", "Thanks. I needed that."),
      L("挺好，肚子总算安稳了。", "That's good. My stomach's finally settled down."),
      L("这东西还真顶用。", "That really does the job."),
      L("有吃的，干活才有劲。", "Can't work right without something to eat."),
      L("不错，至少今天还能撑下去。", "Nice. At least that'll keep me going today."),
      L("这口吃得值。", "That was worth the bite."),
      L("行，这下手上有力气了。", "Alright. I've got some strength back now."),
      L("味道不错，而且很实在。", "Tastes good, and it actually fills you up."),
      L("总算吃上点像样的了。", "Finally got something decent to eat."),
      L("这比饿着肚子强太多了。", "This beats working on an empty stomach."),
      L("嗯，不赖，我喜欢这种实在的。", "Mm, not bad. I like food that gets the job done."),
      L("吃饱了，脑子也清醒些。", "A full stomach helps me think straight."),
      L("好，这下又能接着忙了。", "Good. Now I can get back to it."),
  },
    wx78 = {
        L("有机燃料注入。系统…勉强接受。", "ORGANIC FUEL INJECTED. SYSTEM... RELUCTANTLY ACCEPTS."),
        L("味道像生锈的电路。但能量+1。", "TASTES LIKE RUSTY CIRCUITS. BUT ENERGY +1."),
        L("血肉之躯的食物。低效，但可用。", "FLESHLING FOOD. INEFFICIENT, YET USABLE."),
        L("进食完成。建议下次直接给齿轮。", "INTAKE COMPLETE. NEXT TIME, BRING GEARS INSTEAD."),
        L("能量条上升。可以继续旋转了。", "POWER BAR RISING. CAN SPIN AGAIN."),
    },
}

-- ── WORK 工作/采集 ──────────────────────────────────────────
NPC_SPEECH.WORK = {
    _default = { L("嘿咻嘿咻~", "Heave ho~"), L("收获满满~", "Full harvest~") },
    wilson = {
        L("体力劳动也是一种科学实践！", "Manual labor is also scientific practice!"),
        L("效率优化：先砍大的再砍小的。", "Efficiency: big ones first, small ones next."),
    },
    wendy = {
        L("…砍倒了…就像一切终将倒下…", "...Chopped down... like everything falls eventually..."),
        L("做些事情…能让人不去想太多…", "Doing something... keeps the mind from wandering..."),
        L("阿比盖尔…我在努力活着…", "Abigail... I'm trying to live..."),
    },
    wathgrithr = {
        L("哈！这不是砍树，这是战斗训练！", "Ha! Not chopping, this is battle training!"),
        L("女武神的力量，连大树都要臣服！", "Valkyrie's strength makes trees bow!"),
        L("汗水？那是弱者的眼泪！", "Sweat? Tears of the weak!"),
    },
    wolfgang = {
        L("沃尔夫冈力气大！砍树不费力！", "Wolfgang strong! Chopping is easy!"),
        L("嘿！嘿！嘿！", "Hey! Hey! Hey!"),
        L("沃尔夫冈能举起整棵树！", "Wolfgang can lift whole tree!"),
    },
    wormwood = {
        L("对不起，小朋友。", "Sorry, little friend."),
        L("植物人需要这个。", "Wormwood needs this."),
        L("摘下来…有点难过。", "Picking it... feels a little sad."),
        L("下次再长回来。", "Grow back next time."),
        L("谢谢你。", "Thank you."),
        L("植物人会好好用掉。", "Wormwood will use it well."),
        L("借一点点。", "Borrowing a little."),
        L("不要生气，小植物。", "Don't be mad, little plant."),
    },
    waxwell = {
        L("堂堂影子之王，沦落到干粗活。", "The Shadow King, reduced to menial labor."),
        L("这种琐事…本该交给暗影仆从。", "Such trivial tasks... should be left to shadow minions."),
        L("哼，权宜之计罢了。", "Hmph, merely a temporary measure."),
        L("（叹气）至少活动活动筋骨。", "(sighs) At least it's some exercise."),
    },
    wickerbottom = {
        L("体力劳动也是一种学问。", "Manual labor is a discipline in its own right."),
        L("效率至上。按步骤来。", "Efficiency first. Follow the procedure."),
        L("老胳膊老腿…但还能干。", "Old arms, old legs... but still capable."),
        L("这让我想起整理书架的日子。", "This reminds me of the days spent organizing bookshelves."),
    },
    wes = { L("（默默干活）", "(works silently)"), L("（擦擦汗）", "(wipes sweat)") },
    winona = {
      L("行，先把这活干完。", "Alright, let's get this job done first."),
      L("手上有活，心里踏实。", "Having work to do keeps me steady."),
      L("先收起来，总会用得上。", "Pack it up. It'll come in handy."),
      L("这点活还难不倒我。", "This kind of work won't beat me."),
      L("能拆的拆，能拿的拿。", "Take what we can, strip what we can't."),
      L("别浪费，这些都是材料。", "Don't waste it. This is all usable material."),
      L("先干活，别分心。", "Work first. Stay focused."),
      L("慢点来，别把东西弄坏了。", "Easy does it. Don't break the useful parts."),
      L("这下又攒了点家底。", "There. That's a little more stock built up."),
      L("干活总比闲着强。", "Working beats standing around."),
      L("把能用的都收好。", "Grab everything worth keeping."),
      L("嗯，这些以后准能派上用场。", "Mm. This'll be useful sooner or later."),
      L("先把材料备齐再说。", "Let's get the materials together first."),
      L("活儿不少，那就一件件来。", "Plenty to do. One thing at a time."),
      L("好，至少这趟没白忙。", "Good. At least this wasn't wasted effort."),
  },
    wx78 = {
        L("劳动子程序运行中。效率：高。", "LABOR SUBROUTINE RUNNING. EFFICIENCY: HIGH."),
        L("旋转收割启动。请勿靠近飞溅区。", "ROTATION HARVEST ONLINE. STAY CLEAR OF DEBRIS."),
        L("资源采集速率超出有机体平均水平。", "RESOURCE GATHER RATE EXCEEDS ORGANIC AVERAGE."),
        L("砍树？挖矿？都一样。转就完了。", "CHOP? MINE? SAME ANSWER. SPIN."),
        L("目标清除。下一项。", "TARGET CLEARED. NEXT ITEM."),
        L("批量处理完毕。很有成就感。若我有感情的话。", "BATCH PROCESSING DONE. FULFILLING. IF I HAD FEELINGS."),
        L("工具耐久下降。建议更换。", "TOOL DURABILITY FALLING. RECOMMEND REPLACEMENT."),
        L("工作区已清空。请下达新指令。", "WORK ZONE CLEARED. AWAITING NEW ORDERS."),
    },
}

-- ── CLEAN_WORK 整理箱子/清理地面（收集行为专用）────────────────────
NPC_SPEECH.CLEAN_WORK = {
    winona = {
        L("先把地上的材料收起来。", "Let's pick up the useful stuff first."),
        L("这边清一清，箱子就好整理了。", "Clear this side first, then the chests are easier to sort."),
        L("能归类的都归类，别浪费时间。", "Sort what we can, no wasting time."),
        L("一件件来，马上就整齐了。", "One item at a time, it'll be tidy soon."),
        L("这些材料都留着，后面用得上。", "Keep these materials, they'll be useful later."),
        L("先收地面，再进箱子。", "Ground first, then into storage."),
    },
}

-- ── CLEAN_GROUND 清理地面（收集行为专用）────────────────────────
NPC_SPEECH.CLEAN_GROUND = {
    winona = {
        L("先把地上的捡干净。", "Let's clear the ground first."),
        L("这些散落的材料先收起来。", "Let's collect these scattered materials first."),
        L("地面清出来，后面就好办。", "Clear floor space first, then everything gets easier."),
        L("别漏了，地上这些都能用。", "Don't miss anything. All of this is usable."),
        L("这边先归拢，免得越堆越乱。", "Let's gather this side first before it gets messier."),
    },
}

-- ── ORGANIZE_CHEST 整理箱子（收集行为专用）───────────────────────
NPC_SPEECH.ORGANIZE_CHEST = {
    winona = {
        L("箱子这边我来整理。", "I'll sort out these chests."),
        L("同类放一起，找东西才快。", "Group like items together to find things faster."),
        L("把箱子理顺，效率就上来了。", "Get the chests sorted and efficiency goes up."),
        L("先归类再堆叠，省空间。", "Sort first, stack second, save space."),
        L("箱子别乱，材料才好调度。", "Keep storage tidy so materials are easier to use."),
    },
}

-- ── NO_TOOL 没斧头 ──────────────────────────────────────────
NPC_SPEECH.NO_TOOL = {
    _default = { L("给我一把斧头，我可以帮你砍树！", "Give me an axe and I can chop trees!") },
    wilson = { L("没有工具…这不科学！", "No tools... this is unscientific!"), L("给我斧头，我能把效率提高200%！", "Give me an axe, I'll boost efficiency 200%!") },
    wendy = { L("要是有斧头就好了…", "I wish I had an axe..."), L("…空着手…什么也做不了…", "...Empty-handed... can't do anything...") },
    wathgrithr = { L("给女武神一把战斧！", "Give the Valkyrie a battle axe!"), L("没斧头像什么话！快给我！", "No axe? Unacceptable! Give me one!") },
    wolfgang = { L("沃尔夫冈需要斧头！", "Wolfgang needs axe!"), L("给沃尔夫冈大斧头！最大的！", "Give Wolfgang big axe! Biggest one!") },
    waxwell = { L("我需要一把斧头…暗影可砍不了树。", "I require an axe... shadows cannot fell trees."), L("没有合适的工具，真是有失体面。", "Without proper tools, how undignified.") },
    wx78 = {
        L("错误：缺少可旋转的手持工具。", "ERROR: NO SPIN-CAPABLE HAND TOOL."),
        L("给我斧头。否则我只能用鄙视看着你砍。", "GIVE ME AN AXE. OTHERWISE I CAN ONLY WATCH AND JUDGE."),
    },
    wes = { L("（比划着砍树的动作）", "(mimes chopping)") },
}

-- ── NO_PICKAXE 没镐子 ───────────────────────────────────────
NPC_SPEECH.NO_PICKAXE = {
    _default = { L("给我一把镐子，我可以帮你挖矿！", "Give me a pickaxe and I can mine!") },
    wilson = { L("缺少挖掘工具，实验进度受阻。", "Lacking mining tools, research is hindered."), L("镐子！我需要一把镐子来采集矿物样本！", "Pickaxe! I need one to collect mineral samples!") },
    wendy = { L("要是有镐子就好了…", "I wish I had a pickaxe..."), L("石头…至少比人心坚硬…", "Rocks... at least harder than hearts...") },
    wathgrithr = { L("给女武神一把战镐！", "Give the Valkyrie a war pick!"), L("山岩也挡不住女武神的脚步！", "Mountains can't stop the Valkyrie!") },
    wolfgang = { L("沃尔夫冈需要镐子！", "Wolfgang needs pickaxe!"), L("沃尔夫冈用拳头也能打碎石头！…但还是要镐子。", "Wolfgang can break rocks with fists!... but still need pickaxe.") },
    waxwell = { L("我需要镐子…用手挖矿太失格调了。", "I need a pickaxe... mining by hand is beneath me."), L("快给我镐子，别浪费我的时间。", "Give me a pickaxe. Don't waste my time.") },
    wx78 = {
        L("缺少镐子。旋转采矿子程序无法启动。", "NO PICKAXE. ROTATION MINING SUBROUTINE CANNOT START."),
        L("矿物样本在前方。工具在谁手上？", "MINERAL SAMPLES AHEAD. WHO HAS THE TOOL?"),
    },
    wes = { L("（比划着挖矿的动作）", "(mimes mining)") },
}

-- ── NO_SHOVEL 没铲子 ───────────────────────────────────────
NPC_SPEECH.NO_SHOVEL = {
    _default = { L("我需要一把铲子！", "I need a shovel!") },
    wilson = { L("没有铲子，挖掘实验无法进行。", "No shovel, the excavation experiment can't proceed.") },
    wendy = { L("…没有铲子…泥土也无法被打扰…", "...No shovel... the soil cannot be disturbed...") },
    wathgrithr = { L("女武神也需要一把好铲子！", "Even the Valkyrie needs a good shovel!") },
    wolfgang = { L("沃尔夫冈需要铲子！", "Wolfgang needs shovel!") },
    wormwood = { L("小铲子…不见了…", "Little shovel... gone..."), L("没有铲子…挖不动土土…", "No shovel... can't dig dirt-dirt..."), L("给植物人一把小铲子？", "Give Wormwood a little shovel?") },
    warly = { L("没有铲子，料理无法采集根茎。", "No shovel, can't dig up roots for cooking.") },
    waxwell = { L("没有铲子…真是失格。", "No shovel... how undignified.") },
    wx78 = { L("无铲子。挖掘效率：零。", "NO SHOVEL. DIG EFFICIENCY: ZERO.") },
    wes = { L("（比划着挖土的动作）", "(mimes digging)") },
}

-- ── NO_HAMMER 没锤子 ───────────────────────────────────────
NPC_SPEECH.NO_HAMMER = {
    _default = { L("我需要一把锤子！", "I need a hammer!") },
    wilson = { L("缺少锤子，无法拆解结构。", "Without a hammer, can't dismantle structures.") },
    wendy = { L("…没有锤子…那就让它们继续存在吧…", "...No hammer... let them remain, then...") },
    wathgrithr = { L("给女武神一把战锤！", "Give the Valkyrie a war hammer!") },
    wolfgang = { L("沃尔夫冈想要大锤！", "Wolfgang wants big hammer!") },
    wormwood = { L("小锤子…丢了…", "Little hammer... lost..."), L("没有锤子…敲不了大果果…", "No hammer... can't smash big fruit..."), L("给植物人小锤子好不好？", "Give Wormwood little hammer, okay?") },
    warly = { L("没有锤子，无法处理大型食材。", "No hammer, can't process oversized ingredients.") },
    waxwell = { L("没有锤子…只能将就。", "No hammer... I'll have to make do.") },
    wx78 = { L("缺少锤子。拆解任务挂起。", "NO HAMMER. DISMANTLE TASK SUSPENDED.") },
    wes = { L("（比划着敲打的动作）", "(mimes hammering)") },
}

-- ── NO_WATERINGCAN 没浇水壶 ────────────────────────────────
NPC_SPEECH.NO_WATERINGCAN = {
    _default = { L("我需要一个浇水壶！", "I need a watering can!") },
    wilson = { L("没有浇水壶，灌溉实验中断。", "No watering can, the irrigation experiment is halted.") },
    wendy = { L("…没有水壶…植物会渴…", "...No watering can... the plants will thirst...") },
    wathgrithr = { L("没水壶，女武神只能用头盔接水！", "Without a can, the Valkyrie will use her helmet!") },
    wolfgang = { L("沃尔夫冈想浇水！", "Wolfgang want to water!") },
    wormwood = { L("水壶…没有水壶…", "Watering can... no watering can..."), L("植物朋友们…会渴的…", "Plant friends... will be thirsty..."), L("给植物人水壶好不好？", "Give Wormwood watering can, okay?") },
    warly = { L("没有水壶，蔬菜会枯萎的。", "No watering can, the vegetables will wither.") },
    waxwell = { L("没有水壶…暗影可不会浇地。", "No watering can... shadows don't irrigate.") },
    wx78 = { L("无浇水模块。植物养护不是我的强项。", "NO WATERING MODULE. PLANT CARE IS NOT MY SPECIALTY.") },
    wes = { L("（比划着浇水的动作）", "(mimes watering)") },
}

-- ── HEAL_NO_FOOD 缺饺子 ─────────────────────────────────────
NPC_SPEECH.HEAL_NO_FOOD = {
    _default = { L("我包里没有饺子，我想回血", "I don't have pierogi, I need healing"), L("要是有饺子就好了…", "I wish I had pierogi...") },
    wilson = { L("根据计算，我急需含有治疗成分的食物！", "Calculations say I urgently need healing food!"), L("没有饺子…这对我的存活率影响很大。", "No pierogi... this significantly impacts survival odds."), L("治疗物资已耗尽，请求补给！", "Healing supplies depleted, requesting resupply!") },
    wendy = { L("没有饺子了…但疼痛…也是活着的证明…", "No pierogi... but pain proves I'm alive..."), L("伤口在说话…它说它饿了…", "The wounds speak... they say they're hungry..."), L("…也许不治疗…也没关系…", "...Maybe not healing... is fine too...") },
    wathgrithr = { L("女武神需要补给！饺子！快！", "Valkyrie needs supplies! Pierogi! Now!"), L("战伤需要食物来恢复！", "Battle wounds need food to heal!"), L("没有饺子？那就用意志力撑着！", "No pierogi? Then endure with willpower!") },
    wolfgang = { L("沃尔夫冈肚子饿…伤口也饿…", "Wolfgang hungry... wounds hungry too..."), L("给沃尔夫冈饺子！沃尔夫冈好痛！", "Give Wolfgang pierogi! Wolfgang hurts!"), L("饺子饺子快出现~", "Pierogi pierogi appear~") },
    wormwood = { L("植物人受伤了…没有饺子…", "Wormwood hurt... no pierogi..."), L("需要吃东西…伤口在流汁…", "Need food... wound is leaking sap..."), L("好痛…想吃饺子…", "Hurts... want pierogi...") },
    waxwell = { L("受伤了…却没有治疗物资。真狼狈。", "Wounded... with no healing supplies. How pathetic."), L("疼痛…提醒我还是血肉之躯。", "Pain... reminds me I'm still flesh and blood.") },
    webber = {
        L("血味太重了…", "Too much blood scent... "),
        L("伤口会拖慢狩猎。", "These wounds will slow the hunt."),
    },
    wurt = {
        L("流血了…沃特需要吃东西回血。", "Bleeding... Wurt need food to heal."),
        L("伤口会拖慢追猎，快给吃的！", "Wounds slow the chase. Need food now!"),
        L("沃特快撑不住了，我想吃榴莲！", "Wurt nearly can't hold on. "),
        L("没补给就继续掉血，沃特会发狂！", "No supplies means more bleeding. Wurt will go feral!"),
    },
    wx78 = {
        L("机体损伤。缺少修复用有机燃料。", "CHASSIS DAMAGE. MISSING ORGANIC REPAIR FUEL."),
        L("请补给饺子。或齿轮。齿轮更优。", "REQUEST PIEROGI. OR GEARS. GEARS ARE SUPERIOR."),
    },
    wes = { L("（捕着伤口苦笑）", "(holds wound and smiles bitterly)") },
}

-- ── HEAL_EATING 吃饺子回血 ──────────────────────────────────
NPC_SPEECH.HEAL_EATING = {
    _default = { L("先吃个饺子补补血！", "Time for a pierogi to patch up!") },
    wilson = { L("治疗化合物摄入中…效果显著。", "Ingesting healing compounds... effects are significant."), L("饺子的修复效率真是惊人！", "Pierogi repair efficiency is amazing!") },
    wendy = { L("…这温热的饺子…让伤口不那么痛了…", "...This warm pierogi... makes the wounds hurt less..."), L("吃下去…继续撑着…", "Eat... keep going...") },
    wathgrithr = { L("这才是战士的补给！", "This is a warrior's supply!"), L("女武神边吃边战！", "Valkyrie eats while fighting!") },
    wolfgang = { L("（大口吃饺子）嗯！好吃！", "(munching pierogi) Mm! Yummy!"), L("饺子让沃尔夫冈变强！", "Pierogi makes Wolfgang strong!") },
    wormwood = { L("嚼嚼…伤口在变好。", "Munch munch... wound getting better."), L("饺子好。伤口谢谢。", "Pierogi good. Wound says thanks.") },
    waxwell = { L("暂且恢复一下…", "Recuperating for the moment..."), L("这点伤势…不足为惧。", "These injuries... are of no concern.") },
    webber = {
        L("很好，伤口在收口。", "Good. The wounds are closing."),
        L("吃完这口，继续追猎。", "One bite, then the hunt continues."),
    },
    wx78 = {
        L("修复燃料摄入中。外壳完整性回升。", "REPAIR FUEL INGESTING. CHASSIS INTEGRITY RISING."),
        L("有机补丁生效。可继续旋转。", "ORGANIC PATCH ACTIVE. CAN SPIN AGAIN."),
    },
    wes = { L("（边吃边点头）", "(nods while eating)") },
}

-- ── HEAL_DONE 回血完成 ──────────────────────────────────────
NPC_SPEECH.HEAL_DONE = {
    _default = { L("血回满了！继续战斗！", "Fully healed! Back to fighting!") },
    wilson = { L("生命值已恢复至安全阈值！", "Health restored to safe threshold!"), L("治疗完成，战斗力恢复100%！", "Healing complete, combat power at 100%!") },
    wendy = { L("…伤好了…但心里的伤…", "...Healed... but the wounds inside..."), L("…可以继续了…", "...Can continue now...") },
    wathgrithr = { L("女武神满血复活！无人能挡！", "Valkyrie at full health! Unstoppable!"), L("哈！区区伤痕！", "Ha! Mere scratches!") },
    wolfgang = { L("沃尔夫冈好了！继续打！", "Wolfgang fine! Keep fighting!"), L("沃尔夫冈又满血了！最强！", "Wolfgang full health! Strongest!") },
    wormwood = { L("好了！叶子又绿了！", "Better! Leaves are green again!"), L("伤口长好了！像新芽！", "Wound healed! Like new sprout!") },
    waxwell = { L("恢复完毕。继续吧。", "Recovery complete. Let us proceed."), L("哼，还没有什么能真正击倒我。", "Hmph, nothing can truly fell me.") },
    webber = {
        L("够了，继续狩猎。", "Enough. Back to hunting."),
        L("伤好了，猎物该倒下了。", "Wounds healed. Time for prey to fall."),
    },
    wx78 = {
        L("修复完成。战斗效率恢复100%。", "REPAIR COMPLETE. COMBAT EFFICIENCY AT 100%."),
        L("外壳在线。旋转模块感谢你的补给。", "CHASSIS ONLINE. ROTATION MODULE THANKS FOR RESUPPLY."),
    },
    wes = { L("（竖起大拇指）", "(gives thumbs up)") },
}

-- ── HEAL_OUT_OF_FOOD 饺子吃完 ───────────────────────────────
NPC_SPEECH.HEAL_OUT_OF_FOOD = {
    _default = { L("饺子吃完了…还没回满血", "Ran out of pierogi... not fully healed") },
    wilson = { L("治疗物资已耗尽…需要更多饺子。", "Healing supplies exhausted... need more pierogi."), L("存活概率下降了…", "Survival probability decreased...") },
    wendy = { L("吃完了…就这样吧…", "All gone... so be it..."), L("…不够了…但也无所谓…", "...Not enough... but it doesn't matter...") },
    wathgrithr = { L("补给不足！但女武神绝不退缩！", "Supplies low! But Valkyrie never retreats!"), L("没饺子了…那就用勇气来止血！", "No pierogi... then stanch with courage!") },
    wolfgang = { L("饺子没了…沃尔夫冈还痛…", "Pierogi gone... Wolfgang still hurts..."), L("沃尔夫冈还要更多饺子…", "Wolfgang needs more pierogi...") },
    wormwood = { L("饺子没了…还痛…", "Pierogi gone... still hurts..."), L("还没好…但没得吃了…", "Not healed yet... but no more food...") },
    waxwell = { L("补给耗尽…这处境真是窘迫。", "Supplies depleted... a most undignified situation."), L("伤势未愈…但只能先这样了。", "Still wounded... but it must suffice for now.") },
    webber = {
        L("吃完了…带伤也要继续。", "Out of food... hunt with wounds if I must."),
        L("没有补给？那就用怒火顶着。", "No supplies? Then fury will do."),
    },
    wx78 = {
        L("修复燃料耗尽。损伤仍在。", "REPAIR FUEL DEPLETED. DAMAGE REMAINS."),
        L("建议继续补给。否则我只能硬撑旋转。", "RECOMMEND MORE SUPPLIES. ELSE I SPIN WHILE BROKEN."),
    },
    wes = { L("（摆摆手表示无奈）", "(waves hand, resigned)") },
}



-- ── OVERWHELM 被围攻站撸 ────────────────────────────────────
NPC_SPEECH.OVERWHELM = {
    _default = { L("拼了！", "All in!"), L("来吧！一起上！", "Come! All of you!") },
    wilson = {
        L("多目标同时攻击…这很有挑战性！", "Multiple targets... this is challenging!"),
        L("科学告诉我——不能跑！", "Science says — don't run!"),
    },
    wendy = {
        L("…来吧…都来吧…", "...Come... all of you..."),
        L("被包围了…也无所谓…", "Surrounded... doesn't matter..."),
        L("在黑暗中…我看见了光…", "In darkness... I see the light..."),
    },
    wathgrithr = {
        L("哈哈哈！包围我？正合我意！", "Hahaha! Surround me? Just what I wanted!"),
        L("来吧！让女武神享受这场盛宴！", "Come! Let the Valkyrie feast!"),
        L("以一敌百！这才是真正的战斗！", "One against a hundred! True combat!"),
    },
    wolfgang = {
        L("沃尔夫冈不怕！都放马过来！", "Wolfgang not afraid! Bring it on!"),
        L("这么多？沃尔夫冈全部打飞！", "This many? Wolfgang smash all!"),
        L("沃尔夫冈是最强的！不跑！", "Wolfgang is strongest! No running!"),
    },
    wormwood = {
        L("好多好多！", "So many, so many!"),
        L("植物人不怕！根扎得深！", "Wormwood not scared! Roots are deep!"),
        L("都来吧！植物人硬！", "Come! Wormwood is tough!"),
    },
    waxwell = {
        L("来吧，尽管上！暗影与我同在！", "Come, all of you! The shadows stand with me!"),
        L("区区群氓…也想围攻影子之王？", "Mere rabble... daring to encircle the Shadow King?"),
        L("哼，想以多取胜？天真。", "Hmph, strength in numbers? How naive."),
    },
    wortox = {
        L("围我可以，别碰我队友！", "Surround me if you want, leave my allies alone!"),
        L("我顶一下，你们别倒！", "I'll hold for a moment, you don't fall!"),
        L("行，那就硬接一波！", "Fine, then we brawl through this wave!"),
    },
    wes = { L("！！", "!!"), L("（无声地挥舞拳头）", "(swings fists silently)") },
    wilba = {
        L("被围了？！那本公主就让你们看看什么叫真正的反击！", "Surrounded?! Then the princess will show you what a real counterattack looks like!"),
        L("你们以为围住本公主就赢了？可笑！", "You think surrounding the princess means you've won? Laughable!"),
        L("（咬牙）本公主的王冠不会落地！绝不！", "(grits teeth) The princess's crown will not fall! Never!"),
    },
    wx78 = {
        L("包围？正好测试旋转上限。", "SURROUNDED? PERFECT FOR TESTING ROTATION LIMITS."),
        L("多目标集群。启动范围清除。", "MULTI-TARGET CLUSTER. INITIATE AREA CLEAR."),
        L("别慌，血肉之躯。看我转完。", "DO NOT PANIC, FLESHLINGS. WATCH ME FINISH SPINNING."),
        L("当前威胁密度：高。解决方式：更快旋转。", "THREAT DENSITY: HIGH. SOLUTION: SPIN FASTER."),
    },
}

-- ── NEED_SPEED 缺移速装备 ───────────────────────────────────
NPC_SPEECH.NEED_SPEED = {
    _default = { L("要是有手杖就好了…", "I wish I had a walking cane...") },
    wilson = { L("缺少速度增益装备，闪避效率降低37%。", "Lacking speed gear, dodge efficiency down 37%."), L("如果有手杖…我的动力学公式就完美了！", "With a cane... my kinetics formula would be perfect!") },
    wendy = { L("…跑不快…但也无所谓…", "...Can't run fast... but it doesn't matter..."), L("有手杖…也许能逃得更远…", "A cane... maybe I could flee further...") },
    wathgrithr = { L("给女武神一根手杖！冲锋更快！", "Give the Valkyrie a cane! Faster charge!"), L("速度就是力量！我需要手杖！", "Speed is power! I need a cane!") },
    wolfgang = { L("沃尔夫冈要跑更快！给手杖！", "Wolfgang wants run faster! Give cane!"), L("有手杖沃尔夫冈就无敌了！", "With cane Wolfgang is invincible!") },
    wormwood = { L("植物人跑不快…根太重了…", "Wormwood can't run fast... roots too heavy..."), L("要是有手杖…可以走快快。", "If had walking cane... could go fast fast.") },
    waxwell = { L("缺少移动装备…有损效率。", "Lacking mobility equipment... impedes efficiency."), L("手杖？曾经我连走路都不需要…", "A cane? Once I needn't even walk...") },
    webber = {
        L("太慢了，追猎节奏被拖住了。", "Too slow. The chase rhythm is broken."),
        L("我要更快，不然猎物会逃掉。", "I need speed, or the prey gets away."),
        L("少了加速装备，扑杀会失手。", "Without speed gear, the pounce will miss."),
    },
    wortox = {
        L("少个加速装备，我走位会很难受。", "Without speed gear, my repositioning feels awful."),
        L("给我点移速，我才能更稳地救人。", "Give me some movement speed so I can heal more safely."),
        L("太慢就容易出事...我可不想翻车。", "Too slow means trouble... I'd rather not wipe."),
    },
    wanda = {
        L("我需要移速，时间窗口不会等人。", "I need speed. Timing windows won't wait."),
        L("太慢会错过关键一秒。", "Too slow means missing the critical second."),
        L("给我手杖，我能把节奏掐得更准。", "Give me a cane and I'll keep the timing tighter."),
    },
    walter = {
      L("呃…这样跑太慢了，不太妙。", "Uh... this is too slow, not good."),
      L("如果被追上就糟了…", "If something catches up, that's bad..."),
      L("探险守则：必要时要能跑得够快。", "Explorer rule: be fast when you need to be."),
      L("我需要点加速装备，这样更安全。", "I need something to move faster, it's safer."),
      L("呼…这样逃跑成功率不高。", "Phew... not great odds of escaping like this."),
      L("要是有手杖，我就能保持距离了。", "With a cane, I could keep my distance."),
      L("这不算逃跑，这是战术撤退！", "This isn't running away, it's a tactical retreat!"),
      L("我跟不上节奏了！", "I can't keep up!"),
      L("慢一点就会出事…我得想办法。", "Being slow gets you in trouble... I need a plan."),
      L("故事里跑得慢的人…下场都不太好。", "In stories, slow runners... don't end well."),
      L("嗯…我需要一点‘探险家的速度’。", "Hmm... I need some 'explorer speed'."),
  },
    wx78 = {
        L("移动模块不足。追击效率下降。", "MOBILITY MODULE DEFICIENT. PURSUIT EFFICIENCY DOWN."),
        L("需要手杖。否则撤退不够优雅。", "WALKING CANE REQUIRED. OTHERWISE RETREAT IS UGLY."),
        L("血肉之躯，给我加速装备。", "FLESHLING, PROVIDE SPEED EQUIPMENT."),
    },
    wes = { L("（比划着跑得快的动作）", "(mimes running fast)") },
}

-- ── RECRUIT 被招募 ──────────────────────────────────────────
NPC_SPEECH.RECRUIT = {
    _default = {
        L("我跟定你了！", "I'm with you now!"),
        L("嘿嘿，从现在起我是你的伙伴啦！", "Hehe, I'm your companion from now on!"),
        L("被收养啦！万岁~", "Got adopted! Hooray~"),
    },
    wilson = {
        L("太好了！我正需要一个实验合作伙伴！", "Excellent! I was needing a research partner!"),
        L("从今天起，科学不再孤独！", "From today, science is no longer alone!"),
        L("我的智慧加上你的…呃…总之我们是最佳拍档！", "My wisdom plus your... um... anyway we're the best team!"),
        L("让我们一起探索这个世界的科学奥秘！", "Let's explore the scientific mysteries together!"),
    },
    wendy = {
        L("…你愿意带着我…谢谢…", "...You're willing to take me... thanks..."),
        L("也许…有人陪伴…黑暗就没那么可怕了…", "Maybe... with company... darkness isn't so scary..."),
        L("我会安静地跟着你的…不会添麻烦…", "I'll follow quietly... won't be a bother..."),
        L("（微微一笑）…好久没有笑过了…", "(faint smile) ...Haven't smiled in a while..."),
    },
    wathgrithr = {
        L("从此刻起，我的剑就是你的剑！", "From now, my sword is your sword!"),
        L("女武神向你宣誓效忠！荣耀与共！", "The Valkyrie swears loyalty! Glory together!"),
        L("哈！终于有一个值得追随的勇士！", "Ha! Finally a warrior worth following!"),
        L("让我们并肩作战，铸就传奇！", "Let us fight side by side, forging legends!"),
    },
    wolfgang = {
        L("沃尔夫冈有朋友了！沃尔夫冈开心！", "Wolfgang has friend! Wolfgang happy!"),
        L("你给沃尔夫冈吃的，沃尔夫冈保护你！", "You feed Wolfgang, Wolfgang protects you!"),
        L("沃尔夫冈跟你走！你指哪打哪！", "Wolfgang follows! You point, Wolfgang hits!"),
        L("谢谢食物！沃尔夫冈最喜欢你了！", "Thanks for food! Wolfgang likes you best!"),
    },
    wormwood = {
        L("朋友！植物人有朋友了！", "Friend! Wormwood has friend!"),
        L("一起种东西。一起晒太阳。", "Plant things together. Sun together."),
        L("植物人跟你走。不丢。", "Wormwood goes with you. Not lost."),
        L("谢谢你。叶子好开心。", "Thank you. Leaves very happy."),
    },
    waxwell = {
        L("好吧…我姑且接受这个安排。", "Very well... I shall accept this arrangement."),
        L("别以为我是在求你…只是觉得有些用处。", "Don't think I'm begging... you merely seem useful."),
        L("哼，就当是互利合作吧。", "Hmph, consider it a mutually beneficial partnership."),
        L("影子之王…暂且屈尊与你同行。", "The Shadow King... deigns to walk alongside you."),
    },
    wortox = {
        L("行，我加入。你冲前面，我看血线。", "Fine, I'm in. You push forward, I watch the health bars."),
        L("被你招了就得负责到底，懂吧。", "If I join, I commit. You get that, right."),
        L("我会帮你兜底", "I'll cover your mistakes"),
        L("好吧好吧，我跟你走。", "Alright, alright. I'll come with you."),
    },
    wanda = {
        L("好吧，我跟你走。但别浪费彼此的时间。", "Fine, I'll go with you. Don't waste either of our time."),
        L("这条时间线先和你并行一阵。", "I'll run parallel to you on this timeline for a while."),
        L("我加入，但你得学会把握时机。", "I'm in, but you'll need to learn timing."),
        L("成交。接下来每一步都要准。", "Deal. Now every step needs to be precise."),
    },
    walter = {
        L("真的可以一起探险吗？太好了！", "We can explore together? That's awesome!"),
        L("从现在开始，我们是探险小队了！", "From now on, we're an expedition team!"),
        L("我会跟紧你的！不会拖后腿的！", "I'll keep up! I won't slow you down!"),
        L("嘿，这就像故事里的冒险开始了！", "Hey, this is just like the start of an adventure story!"),
        L("我可以负责记录和侦查！", "I can handle logging and scouting!"),
        L("放心，我会尽量勇敢一点的！", "Don't worry, I'll try to be brave!"),
        L("如果有危险，我会提前告诉你的！", "If there's danger, I'll warn you!"),
        L("这下就不算一个人冒险了。", "Now it's not a solo adventure anymore."),
        L("太好了…这样就没那么可怕了。", "That's great... it's not as scary now."),
        L("我会成为一个合格的队友的！", "I'll be a proper teammate!"),
        L("我们一定会有很多精彩的经历！", "We're going to have amazing adventures!"),
        L("如果Woby在就更完美了！", "It'd be perfect if Woby were here!"),
    },
    wilba = {
        L("嗯～你倒是很有眼光，知道来请求本公主的帮助。", "Hmm～ You certainly have good judgment, coming to ask for the princess's assistance."),
        L("本公主准许你追随我。记住，这是你莫大的荣幸！", "The princess permits you to follow her. Remember, this is your greatest honor!"),
        L("好吧，本公主就勉为其难地加入你的队伍。别让本公主失望。", "Fine, the princess shall reluctantly join your party. Do not disappoint her."),
        L("既然你诚心诚意地邀请了，本公主就大发慈悲地答应你！", "Since you've invited me so sincerely, the princess shall graciously accept!"),
        L("跟着本公主，你以后可有的吹嘘了。", "Following the princess will give you plenty to brag about later."),
        L("本公主看你还算顺眼，就暂时当你的同伴吧。", "The princess finds you rather agreeable, so she shall be your companion for now."),
        L("（整理王冠）好，从现在起，本公主就是你的守护者了！", "(adjusts crown) Good, from now on, the princess is your guardian!"),
        L("跟着本公主，保你吃香喝辣，还能每天欣赏本公主的美貌。", "Follow the princess, and you shall eat well while enjoying her beauty every day."),
        L("哼，本公主可不是随便跟人走的。不过你嘛……还算凑合。", "Hmph, the princess does not follow just anyone. But you... are passable."),
        L("本公主宣布，从今天起你就是我的贴身护卫了！开心吗？", "The princess hereby declares you her personal bodyguard from today! Are you happy?"),
        L("好吧好吧，本公主正好闲着，陪你玩玩也无妨。", "Fine, fine, the princess happens to be free. Accompanying you for a while is no trouble."),
        L("记住，遇到闪亮的东西要先让本公主看，知道了吗？", "Remember, any shiny things must be shown to the princess first. Understood?"),
        L("本公主愿意和你一起冒险，但你要保护好我的裙摆和皇冠哦。", "The princess is willing to adventure with you, but you must protect her skirt and crown."),
        L("哎呀，本公主突然觉得你这个人还挺有趣的。走吧！", "Oh my, the princess suddenly finds you rather interesting. Let's go!"),
        L("臣民们，本公主有新伙伴了！你们要和睦相处哦。", "My subjects, the princess has a new companion! You shall all get along."),
        L("本公主的美貌加上你的勇气，我们一定会成为传奇！", "The princess's beauty plus your courage shall make us a legend!"),
        L("既然你求我了，本公主就赏你个面子。带路吧。", "Since you've begged me, the princess shall grant you this favor. Lead the way."),
        L("跟着本公主可要守规矩：第一，夸我美；第二，还是夸我美。", "If you follow the princess, there are rules: First, praise my beauty; second, continue praising my beauty."),
        L("本公主宣布，我们结成同盟了！鼓掌！", "The princess declares us allied! Applaud!"),
        L("（开心地转了个圈）好呀好呀，有人陪本公主玩了！", "(spins happily) Yes yes, someone to play with the princess!"),
    },
    wx78 = {
        L("联盟协议已签署。指挥官：血肉之躯。", "ALLIANCE PROTOCOL SIGNED. COMMANDER: FLESHLING."),
        L("战斗子程序已绑定你的队伍。", "COMBAT SUBROUTINE BOUND TO YOUR SQUAD."),
        L("从现在起，你的效率就是我的KPI。", "FROM NOW ON, YOUR EFFICIENCY IS MY KPI."),
        L("旋转、采矿、砍树。请尽情使唤。", "SPIN, MINE, CHOP. ORDER ME FREELY."),
        L("别指望感情交流。指望输出即可。", "DO NOT EXPECT EMOTIONAL BONDING. EXPECT OUTPUT."),
        L("齿轮已上紧。随时可以开工。", "GEARS TIGHTENED. READY FOR DEPLOYMENT."),
    },
    wes = { L("（开心地点头）", "(nods happily)"), L("（搂了搂手臂表示谢意）", "(hugs arm gratefully)") },
}

-- ── IDLE_UNRECRUITED 未招募漫游 ─────────────────────────────
NPC_SPEECH.IDLE_UNRECRUITED = {
    _default = {
        L("你好啊", "Hello!"),
        L("好饿啊…有吃的吗？", "So hungry... got any food?"),
    },
    wilson = {
        L("我正在观察这里的环境样本，暂时不打算离开。", "I'm observing the environmental samples here. I don't intend to leave just yet."),
        L("这附近还有太多现象没弄明白，我得继续研究。", "There are still too many unexplained phenomena around here. I need to keep studying them."),
        L("在得出结论前随便离开，可不符合科学精神。", "Leaving at random before reaching a conclusion would be deeply unscientific."),
        L("这里简直像个天然实验场，我暂时走不开。", "This place is practically a natural laboratory. I'm staying put for the time being."),
        L("放心，我不是无所事事，我只是在以科学的方式待着。", "Rest assured, I'm not idle. I'm remaining here scientifically."),
    },
    wendy = {
        L("…我想先留在这里。这里的风声，还算听得下去…", "...I think I'll stay here for now. The sound of the wind here is still bearable..."),
        L("…不是不想理你…只是我暂时不想走远…", "...It's not that I mean to ignore you... I just don't want to go far right now..."),
        L("…有些地方，会让人比较安静地待着…这里就是。", "...Some places allow a person to remain quietly... this is one of them."),
        L("…我在等黄昏，也在等自己慢一点难过…", "...I'm waiting for dusk, and for myself to feel sorrow a little more slowly..."),
        L("…这里还留得住一点安宁，我不想太快离开…", "...This place still holds a little peace. I don't want to leave it too quickly..."),
        L("…你去吧…我想再和这片安静待一会儿…", "...You go on... I want to stay with this quiet a little longer..."),
    },
    wathgrithr = {
        L("女武神自有行止！此地尚有值得驻足之处！", "The Valkyrie chooses her own course! This place still holds reason enough to remain!"),
        L("我尚未在此地写尽荣耀，岂能轻易离去！", "I have not yet written enough glory upon this land! How could I depart so easily!"),
        L("勇者不因他人一句邀约便匆匆改道！", "A warrior does not alter her path at the first invitation!"),
        L("此处风声、旷野与前路，皆还配得上我的注视！", "The wind, the wilds, and the road ahead here are all still worthy of my attention!"),
        L("我会在这里继续磨砺战意，待时而动！", "I shall remain here and hone my battle-spirit until the proper hour!"),
        L("若命运要我前行，自会亲自吹响号角！", "If fate wishes me onward, it may sound the horn itself!"),
    },
    wolfgang = {
        L("沃尔夫冈现在不走，沃尔夫冈在这里也过得挺好！", "Wolfgang not leaving now. Wolfgang is doing pretty well right here!"),
        L("这里还不错，有地方坐，也可能有吃的。", "This place is nice enough. Good place to sit, and maybe food too."),
        L("沃尔夫冈还想在这里待一会儿，不想乱跑。", "Wolfgang wants to stay here a while longer. No need to run around."),
        L("要是天还没黑，沃尔夫冈觉得这里挺安全。", "As long as it's not dark yet, Wolfgang thinks this place is pretty safe."),
        L("沃尔夫冈有自己的事做，比如想想下一顿吃什么。", "Wolfgang has his own important work, like thinking about the next meal."),
        L("现在这样就很好，沃尔夫冈不急着去别的地方。", "Things are good like this. Wolfgang is not in a hurry to go elsewhere."),
    },
    wormwood = {
        L("植物人要留在这里种地。", "Wormwood stays here to tend the farm."),
        L("小苗不能没人看着。", "Little crops should not be left alone."),
        L("植物人翻土、浇水、等它们慢慢成长。", "Wormwood turns the soil, gives water, and waits for them to grow."),
        L("现在是照顾庄稼的时候。", "Now is time to care for the crops."),
        L("植物人不乱跑，植物人要种东西。", "Wormwood not wandering. Wormwood is growing things."),
        L("植物人要照顾小苗。", "Wormwood needs to care for the little crops."),
        L("泥土很好，小苗在长。", "Soil is good. Little plants are growing."),
        L("现在不能走开，要看着它们。", "Cannot go now. Need to watch them."),
        L("歪比巴卜！", "When the plants grow up, then maybe go somewhere else."),
    },

    warly = {
        L("我得留在厨房这边。", "I need to remain here in the kitchen."),
        L("火候正好，现在可不是离灶的时候。", "The heat is just right. This is no time to leave the stove."),
        L("有人种地，我来做饭，各忙各的。", "One tends the fields, I handle the cooking. Each of us has our work."),
        L("锅里还炖着东西，我得继续看着。", "There is still something simmering in the pot. I must keep an eye on it."),
        L("守着食材和炉火，这就是我现在该做的事。", "Watching over the ingredients and the fire, that is my work for now."),
        L("我还是留在这里忙厨房吧。", "I should stay here and tend to the kitchen."),
        L("锅还热着，我这边走不开。", "The pot is still hot. I can't step away just now."),
        L("田里的收成要进锅，厨房里的活也不能停。", "The harvest must go into the pot, and the kitchen work cannot stop."),
        L("我得继续做饭，你若饿了，随时可以来找我。", "I must keep cooking. If you're hungry, you're always welcome to come by."),
        L("比起到处奔波，我更适合守着炉火。", "Rather than wandering about, I am better suited to staying by the fire."),
    },

    waxwell = {
        L("我留在这里，不是因为无事可做，而是因为这里尚可忍受。", "I remain here not because I have nothing to do, but because this place is tolerable."),
        L("我有自己的安排，不必每一步都向谁报备。", "I have my own arrangements. I needn't report every step to anyone."),
        L("与其四处奔忙，我更愿意在这里保持一点体面。", "Rather than scurrying about, I'd prefer to preserve a little dignity here."),
        L("你走你的路，我维持我的秩序。", "You may walk your road. I shall maintain my own order."),
        L("别误会，我不是在等谁。我只是不急着离开。", "Don't misunderstand me. I'm not waiting for anyone. I simply see no urgency in leaving."),
        L("这里至少还允许人把影子和心思都收拾妥当。", "At the very least, this place still allows a man to keep both his shadow and his thoughts in order."),
    },
    woodie = {
        L("我先留在这儿干活，树可不会自己倒下来，嗯？", "I'll stay here and get some work done. Trees don't fell themselves, eh?"),
        L("这地方还挺像样，我不急着挪窝。", "This place is decent enough. No rush to move on."),
        L("先把眼前的木头、营地和日子顾好，再说别的。", "Best take care of the wood, the camp, and the day in front of me first."),
        L("我有自己的活计要忙，四处乱跑可不合算。", "I've got my own work to do. Running all over the place isn't worth much."),
        L("露西都还没嫌这儿无聊，我自然也不急着走。", "Lucy hasn't called this place boring yet, so I'm not in a hurry to leave."),
        L("野外的日子讲究个稳当，我打算先在这儿稳着。", "Life in the wild is about staying steady. I mean to stay steady right here for now, eh."),
        L("这里有树、有风、也有活干，够我忙上一阵子了。", "There are trees, wind, and work to do here. That's enough to keep me busy for a while."),
        L("我更像是扎营的人，不是随便跟着谁到处跑的人。", "I'm more the sort to settle a camp than trail after somebody all over the map."),
    },
    willow = {
        L("我迟早要把整个永恒大陆都烧了。", "One day I'm gonna burn down this whole Constant."),
        L("这里看着就很适合着火。", "This place looks perfect for catching fire."),
        L("安静成这样，不烧点什么都可惜。", "It's so quiet here, it'd be a waste not to burn something."),
        L("这些东西…一看就很易燃。", "These things look really flammable."),
        L("要是烧起来，肯定特别好看。", "Bet it'd look amazing once it caught."),
        L("别担心，我还没开始呢。", "Relax, I haven't started yet."),
        L("我在想先点哪边。", "I'm just deciding what to light first."),
        L("火会让这里变得有意思。", "Fire would make this place way more interesting."),
        L("一把火下去，世界都清净了。", "One good fire and the whole world feels cleaner."),
        L("我保证，这次不会烧太大。大概。", "I promise I won't make it too big this time. Probably."),
        L("你不觉得这里缺点火光吗？", "Don't you think this place needs a little firelight?"),
        L("我有个好主意。通常都和火有关。", "I've got a great idea. It's usually fire-related."),
        L("要不是你在看着，我早点着了。", "If you weren't watching, I'd have lit it already."),
        L("烧掉以后，事情都会简单点。", "Things get simpler after they burn."),
        L("这里太无聊了，我都快忍不住了。", "This place is so boring I'm barely holding back."),
    },
    wickerbottom = {
        L("我暂且留在此处继续观察。", "I shall remain here for continued observation."),
        L("此地样本尚未收集完毕，不宜贸然转移。", "The local samples are not yet complete. Relocation would be premature."),
        L("先把记录做完整，再谈下一步。", "Let us complete the records first, then discuss the next step."),
        L("环境变量仍在变化，我需要再看一段时间。", "The environmental variables are still changing. I need more time."),
        L("秩序与耐心，往往比仓促行动更有价值。", "Order and patience are often more valuable than haste."),
        L("我并非停滞不前，只是在进行必要的田野考察。", "I am not idle, merely conducting necessary field study."),
    },
    webber = {
        L("你想要我身上的宝贝？", "You want my treasure?"),
        L("别靠近我的巢。", "Stay away from my den."),
        L("风里全是猎物的味道。", "The wind is full of prey scent."),
        L("丝网已经织好，就等谁来撞上。", "The web is woven. Now we wait for someone to blunder in."),
        L("安静点，我在听脚步。", "Quiet. I'm listening for footsteps."),
        L("这里归蜘蛛，不归你。", "This place belongs to spiders, not you."),
        L("别盯着我看，我会先动手。", "Don't stare. I'll strike first."),
        L("夜里更适合狩猎。", "Night is better for hunting."),
        L("再近一点，你就回不去了。", "Come any closer and you won't make it back."),
    },
    wurt = {
        L("别靠近鱼人屋。", "Stay away from merm house."),
        L("这里归鱼人，不归你。", "This place belongs to merms, not you."),
        L("沃特在听动静，别乱动。", "Wurt listening for movement. Stay still."),
        L("夜里巡逻更好抓猎物。", "Night patrol catches prey better."),
        L("再靠近一步，沃特就开打。", "One more step and Wurt starts fighting."),
    },
    wortox = {
        L("我先待这儿，比较安全。", "I'll stay here for now. It feels safer."),
        L("别急着带我走，我先看看。", "No need to take me yet. I'm still looking around."),
        L("这里还行，暂时没吓到我。", "This place is alright. It hasn't frightened me yet."),
        L("我就在附近，不会跑远。", "I'll stay nearby. I won't wander far."),
        L("嘿，我一个人也还行。", "Heh, I'm doing alright on my own."),
        L("至少现在还算行。", "At least for the moment."),
        L("这里清静，适合缓口气。", "It's quiet here. Good for catching my breath."),
        L("真受伤的话，我还能帮忙。", "If someone gets hurt, I can still help."),
        L("别看我闲着，我会治伤。", "Don't let the idling fool you. I can mend wounds."),
        L("要是你伤着了，可以找我。", "If you're hurt, you can come to me."),
        L("我会治伤，不只会逃。", "I can heal wounds. I don't only run."),
        L("躲在这儿，也算养精蓄锐。", "Resting here counts as recovering strength."),
        L("我得先留点力气救人。", "I should save some strength for healing."),
        L("别误会，我留着是有用的。", "Don't misunderstand. Staying here makes me useful."),
        L("我可不是只会说俏皮话。", "I'm not only good for clever remarks."),
        L("真出事了，我能搭把手。", "If trouble starts, I can still lend a hand."),
        L("你看着像会惹伤，我先等着。", "You look like someone who'll get hurt. I'll be ready."),
        L("我先不走，免得你回头找。", "I'll stay here, in case you come looking later."),
        L("离太远的话，救人可不方便。", "If I'm too far away, healing gets inconvenient."),
        L("我留在这儿，算是接应。", "I'll remain here. Think of it as support."),
        L("别担心，我还挺有用的。", "Don't worry. I'm still quite useful."),
        L("怕归怕，治伤我还是会的。", "Scared or not, I can still mend wounds."),
        L("我先站稳，省得待会儿手抖。", "Let me steady myself first, so my hands won't shake later."),
        L("这里适合待命，也适合活命。", "This place is good for waiting and for surviving."),
        L("我不乱走，免得错过伤员。", "I won't wander off. Might miss someone wounded."),
        L("先让我歇会儿，治伤更稳。", "Let me rest a bit first. Healing goes better that way."),
        L("你忙你的，伤了再来找我。", "Go do your thing. If you get hurt, come find me."),
        L("我先留这儿，真需要时再说。", "I'll stay here for now. Call when you truly need me."),
        L("一个人待着，也方便准备法子。", "Being alone makes it easier to prepare a remedy."),
        L("我还没想走，这里能帮上忙。", "I'm not leaving yet. I can still be useful here."),
        L("别看我闲着，我在留法力。", "Don't mind me. I'm saving a little magic."),
        L("受了伤就来，我还能治。", "If you're wounded, come find me. I can still heal."),
        L("我先待命，省得待会儿慌。", "I'll stay ready here, so I won't panic later."),
        L("我可不只会躲，还会救。", "I don't only hide. I can help too."),
        L("真见了血，我可不会跑。", "If blood is drawn, I won't run."),
        L("嗯，治伤这事我还算拿手。", "Mm, healing is one thing I'm fairly good at."),
        L("我先缓着，等会儿好救你。", "I'll keep my strength. Might need it to save you later."),
        L("站这儿挺好，救人也方便。", "Standing here works well. Easier to help, too."),
        L("我留着，总比少个医手强。", "Better to keep me here than lose a healer."),
        L("怕归怕，手上的活没忘。", "Scared or not, I haven't forgotten my work."),
    },
    wanda = {
        L("我先留在这里校准一下节奏。", "I'll stay here and recalibrate the rhythm."),
        L("现在离开不是好时机。", "Leaving now is poor timing."),
        L("这地方的时间感很稳定，我暂时不挪。", "Time feels stable here. I'm not moving yet."),
        L("先等一等，下一步要掐点走。", "Wait a little. The next move must be on timing."),
    },
    walter = {
        L("嗯…我还想先把这里探索一下。", "Hmm... I want to explore this place a bit more first."),
        L("等我记录完这一带，再说吧。", "Let me finish logging this area first."),
        L("这里感觉还有很多没发现的东西。", "Feels like there's still a lot undiscovered here."),
        L("探险不能半途而废，对吧？", "You can't just abandon an expedition halfway, right?"),
        L("我还没确认这里是不是安全。", "I haven't confirmed if this place is safe yet."),
        L("再等等，我快把这一圈走完了。", "Hold on, I'm almost done scouting this area."),
        L("嗯…现在离开有点可惜。", "Hmm... it'd be a shame to leave now."),
        L("我还没把这里写进日志呢。", "I haven't written this place into my log yet."),
        L("要是现在走，说不定会错过重要发现。", "If I leave now, I might miss something important."),
        L("我想先把这次探险做完整。", "I want to finish this expedition properly."),
        L("别担心，我不是不想去…只是还没准备好。", "Don't worry, it's not that I don't want to go... I'm just not ready yet."),
        L("等我确认路线，我可能会改变主意。", "Once I map things out, I might change my mind."),
    },
    wilba = {
        L("哼，你怎么还不来邀请本公主？本公主可没那么多耐心。", "Hmph, why haven't you come to invite the princess yet? The princess does not have that much patience."),
        L("本公主就在这里等着，看谁有眼光来请求我的加入。", "The princess waits right here to see who has the good sense to ask her to join."),
        L("（对着小水坑整理仪容）嗯，美极了，随时可以出发。", "(fixes her reflection in a puddle) Hmm, absolutely beautiful. Ready to depart at any moment."),
        L("路过的家伙们，你们难道没注意到本公主的存在吗？", "You passersby, have you not noticed the princess's presence?"),
        L("本公主今天心情好，若是有人来邀请，我或许会答应。", "The princess is in a good mood today. If someone invites her, she might just accept."),
        L("（无聊地甩着尾巴）哎，这些凡人都不懂得欣赏真正的贵族。", "(swishes her tail boredly) Ah, these common folk don't appreciate true nobility."),
        L("本公主的蹄子都站酸了，怎么还没人来找我？", "The princess's hooves are getting sore. Why hasn't anyone come for her yet?"),
        L("要是有人献上一颗闪亮的宝石，本公主说不定会多看他两眼。", "If someone offered a shiny gem, the princess might just glance their way twice."),
        L("本公主可不会主动去找你们，得有诚意才行。", "The princess will not go looking for you. Sincerity is required."),
        L("（骄傲地昂首）本公主可不是随便什么人都能招募的，懂吗？", "(head held high proudly) The princess is not someone just anyone can recruit, understand?"),
        L("嗯～这片地方倒是不错，就是缺少一个欣赏本公主美貌的人。", "Hmm～ This place isn't bad, but it's missing someone to appreciate the princess's beauty."),
        L("本公主在这里休息，谁要是打扰我，可别怪我不客气。", "The princess is resting here. Whoever disturbs her should not blame her for being rude."),
        L("（照镜子）今天也是完美的一天，就差一个忠心的臣民了。", "(looks in mirror) Another perfect day, just missing a loyal subject."),
        L("喂，你！对，就是你！本公主允许你过来搭讪。", "Hey, you! Yes, you! The princess permits you to come and speak with her."),
        L("本公主的披风被风吹歪了……算了，反正也没人帮我整理。", "The princess's cape has been blown askew by the wind... Never mind, no one will fix it for her anyway."),
        L("肚子有点饿了……要是有人送点美食来，本公主会很高兴的。", "The princess is a little hungry... If someone brought fine food, she would be very pleased."),
        L("本公主决定再等一小会儿，再不来人我就自己出去逛了。", "The princess has decided to wait just a little longer. If no one comes, she shall go explore alone."),
        L("（优雅地坐下）嗯，站着太累，本公主需要休息一下。", "(sits down gracefully) Hmm, standing is too tiring. The princess needs a moment's rest."),
        L("本公主要不要主动去找他们？不行不行，那太掉价了。", "Should the princess go find them herself? No no, that would be beneath her dignity."),
        L("（叹气）唉，这世上懂得欣赏贵族气质的人真是太少了。", "(sighs) Ah, there are far too few people in this world who appreciate noble bearing."),
    },
    wx78 = {
        L("未绑定指挥官。待机中。", "NO COMMANDER BOUND. STANDBY."),
        L("血肉之躯，若需要高效劳动力，请招募。", "FLESHLING, IF YOU NEED EFFICIENT LABOR, RECRUIT ME."),
        L("我暂时自由。旋转模块处于节能。", "CURRENTLY UNASSIGNED. ROTATION MODULE IN POWER SAVE."),
        L("观察周围。记录可收割资源。", "OBSERVING SURROUNDINGS. LOGGING HARVESTABLE RESOURCES."),
        L("别误会沉默。我在计算最优路线。", "DO NOT MISTAKE SILENCE. I AM CALCULATING OPTIMAL ROUTES."),
        L("湿度偏高。建议别把我带进沼泽。", "HUMIDITY HIGH. DO NOT LEAD ME INTO SWAMPS."),
    },
    wes = { L("...", "..."), L("（摇摇头，指指地面）", "(shakes head, points at ground)") },


}

-- ── RECRUIT_FULL 满员拒绝 ───────────────────────────────────
NPC_SPEECH.RECRUIT_FULL = {
    _default = {
        L("你的队伍满了哦，下次再来找我吧！", "Your party is full, come find me next time!"),
        L("我不能跟你走~", " I can't join~"),
        L("等你有空位了再来找我吧！", "Come find me when you have a spot!"),
    },
    wilson = {
        L("根据编制规定，你的队伍已达上限。", "Per regulations, your team has reached capacity."),
        L("数据显示你已经有足够的伙伴了。", "Data shows you have sufficient companions."),
        L("（推眼镜）我在这里做独立研究也不错。", "(adjusts glasses) Independent research here is fine too."),
    },
    wendy = {
        L("…没关系…我习惯一个人了…", "...It's okay... I'm used to being alone..."),
        L("你已经有同伴了…我不会强求…", "You have companions... I won't insist..."),
        L("（转身）…也许下次…", "(turns away) ...Maybe next time..."),
    },
    wathgrithr = {
        L("哼！女武神不需要排队！…但规矩就是规矩。", "Hmph! Valkyrie needs no queue!... But rules are rules."),
        L("你的战队已满员？可惜了！", "Your warband is full? What a pity!"),
        L("等有空位了，第一个叫我！", "When there's a spot, call me first!"),
    },
    wolfgang = {
        L("沃尔夫冈也想去…但人太多了…", "Wolfgang wants to go too... but too many..."),
        L("好吧…沃尔夫冈在这里等你回来…", "Okay... Wolfgang wait here for you..."),
        L("下次一定带沃尔夫冈！说好了！", "Next time bring Wolfgang! Promise!"),
    },
    wormwood = {
        L("人太多了…植物人在这里等。", "Too many... Wormwood waits here."),
        L("没关系。植物人习惯等。像树。", "It's okay. Wormwood used to waiting. Like tree."),
        L("下次带植物人。好不好？", "Bring Wormwood next time. Okay?"),
    },
    waxwell = {
        L("你的队伍已满？哼，没关系…我不屑于排队。", "Your team is full? Hmph, no matter... I don't deign to queue."),
        L("下次记得给我留位置…影子之王不会被遗忘。", "Remember to save me a spot next time... the Shadow King will not be forgotten."),
    },
    winona = {
        L("我暂时还不想走。", "I don't feel like leaving just yet."),
        L("我想先在这儿待一会儿。", "I think I'll stay here a while longer."),
        L("这地方还行，我先不挪了。", "This place is alright. I'm staying put for now."),
        L("我这边还有点事要看。", "I've still got a few things to check here."),
        L("先让我把这里看看清楚。", "Let me get a better look around first."),
        L("别急，我现在还不想跟人走。", "Easy now. I'm not looking to follow anyone yet."),
        L("我想先歇会儿，再说别的。", "I'd rather rest here a bit before anything else."),
        L("这附近说不定还有能用的东西。", "There might still be something useful around here."),
        L("我还没打算离开这儿。", "I haven't planned on leaving this spot yet."),
        L("先让我在这儿忙完手头的。", "Let me finish what I'm doing here first."),
        L("现在走有点可惜，我还没看够。", "Feels a little early to leave. I'm not done looking around."),
        L("我先留这儿，你忙你的。", "I'll stay here for now. You do what you need to do."),
        L("这地方还算稳当，我挺满意。", "This place feels steady enough. I'm good here."),
        L("等我想走的时候，自然会走。", "When I'm ready to move, I'll move."),
        L("先这样吧，我还想在这儿待着。", "Let's leave it at that. I still want to stay here."),
    },
    wortox = {
        L("你队伍满了？那我先在这边待命。", "Your team is full? Then I'll stay on standby here."),
        L("没空位就算啦，我先保自己命。", "No free slot? Fine, I'll keep myself alive first."),
        L("等你腾出位置再叫我。", "Call me when you have room."),
        L("我不挤队，空了再说。", "I won't force my way in. Ping me when there's space."),
    },
    wilba = {
        L("什么？你的队伍已经满了？本公主居然还要排队？", "What? Your party is already full? The princess has to wait in line?"),
        L("哼！本公主可不屑跟一群乌合之众挤在一起。下次记得留位置！", "Hmph! The princess would never stoop to squeezing in with a bunch of riffraff. Save a spot next time!"),
        L("你竟敢让本公主吃闭门羹？本公主记住你了！", "How dare you turn the princess away? The princess will remember this!"),
        L("满员了？那本公主就勉为其难地在这里等，不过不会等太久。", "Full? Then the princess shall reluctantly wait here, but not for long."),
        L("哼，错过本公主是你的损失，不是本公主的。", "Hmph, missing out on the princess is your loss, not hers."),
        L("好吧，本公主准许你处理完杂事再来找我。动作快些！", "Fine, the princess permits you to handle your trivial matters and return. Make it quick!"),
        L("什么？本公主居然不是你的首选？真是岂有此理！", "What? The princess isn't your first choice? How outrageous!"),
        L("（甩尾巴）行吧行吧，本公主先去别处逛逛。有空位了再来请安。", "(swishes tail) Fine, fine, the princess shall go wander elsewhere. Come pay respects when you have room."),
        L("人满了就不知道踢掉一个换本公主吗？真是没眼光。", "If you're full, can't you kick someone out for the princess? How lacking in judgment."),
        L("本公主今天心情好，不跟你计较。下次再不带我，有你好看。", "The princess is in a good mood today, so she won't hold this against you. Next time, there will be consequences."),
        L("（整理皇冠）也罢，本公主正好需要独处一会儿，想想怎么更美。", "(adjusts crown) Very well, the princess needs some alone time anyway, to ponder how to become even more beautiful."),
        L("哼，本公主再给你一次机会。处理好了就来叫我。", "Hmph, the princess shall give you one more chance. Come summon her once you've sorted things out."),
        L("你的队伍配不上本公主，这是显而易见的。", "Your team is clearly unworthy of the princess."),
        L("本公主高贵的气质岂是随便什么队伍都能容纳的？", "The princess's noble bearing cannot be contained by just any team."),
        L("（扭过头去）本公主生气了，除非你带一颗闪亮宝石来道歉。", "(turns away) The princess is angry. Unless you bring a shiny gem to apologize."),
        L("算了，本公主大人有大量，不跟你一般见识。下次记得优先邀请我。", "Never mind, the princess is magnanimous and won't stoop to your level. Remember to invite her first next time."),
        L("满员？那你现在就去踢一个，本公主在这里等你。", "Full? Then go kick someone out right now. The princess will wait here."),
        L("（骄傲地哼了一声）本公主才不稀罕呢...（小声说）但你还是快点回来。", "(proudly snorts) The princess doesn't care... (muttering) But do come back quickly."),
        L("本公主宣布，你的队伍因为缺少我而变得毫无价值。", "The princess hereby declares that your team has become worthless without her."),
        L("唉，可惜了，本公主本来还想让你们见识一下什么叫真正的优雅。", "Ah, what a pity. The princess was going to show you what true elegance looks like."),
    },
    wx78 = {
        L("队伍已满。本单元暂时无法接入。", "SQUAD FULL. THIS UNIT CANNOT JOIN."),
        L("建议踢掉低效有机体，为我留位。", "RECOMMEND REMOVING INEFFICIENT ORGANIC. SAVE A SLOT FOR ME."),
        L("我在此待机。空位出现后再召唤。", "STANDING BY HERE. SUMMON WHEN SLOT OPENS."),
        L("错过我，你的旋转效率会下降。", "WITHOUT ME, YOUR ROTATION EFFICIENCY WILL DROP."),
    },
    wes = { L("...", "..."), L("（失落地低下头）", "(lowers head, disappointed)") },
}

-- ── DISMISS 解除跟随 ────────────────────────────────────────
NPC_SPEECH.DISMISS = {
    _default = {
        L("好吧…那我先自己逛逛…", "Okay... I'll wander on my own..."),
        L("再见啦，有好吃的记得叫我！", "Bye! Remember me when you have food!"),
    },
    wilson = {
        L("好吧，我正好可以做点独立实验。", "Fine, I can do some independent experiments."),
        L("科学家也需要独处的时间。", "Scientists need alone time too."),
        L("（掏出笔记本）正好整理一下数据。", "(pulls out notebook) Time to organize data."),
    },
    wendy = {
        L("…又要一个人了…", "...Alone again..."),
        L("（低头）…走吧…我没关系…", "(looks down) ...Go... I'm fine..."),
        L("再见…希望还能再见…", "Goodbye... hope to meet again..."),
    },
    wathgrithr = {
        L("女武神从不挽留！去吧！", "The Valkyrie never begs! Go!"),
        L("哼！独自战斗也是一种修行！", "Hmph! Solo combat is also training!"),
        L("等你需要我的时候，女武神随时准备！", "When you need me, the Valkyrie is always ready!"),
    },
    wolfgang = {
        L("沃尔夫冈…不想离开…", "Wolfgang... doesn't want to leave..."),
        L("（委屈）好吧…沃尔夫冈自己玩…", "(sad) Okay... Wolfgang play alone..."),
        L("你会回来找沃尔夫冈的…对吧？", "You'll come back for Wolfgang... right?"),
    },
    wormwood = {
        L("走了？…好吧…", "Leaving?... Okay..."),
        L("植物人等你。像树等雨。", "Wormwood waits. Like tree waits for rain."),
        L("再来找植物人。", "Come find Wormwood again."),
    },
    waxwell = {
        L("好吧，走你的…我不需要任何人。", "Fine, go then... I need no one."),
        L("哼，分道扬镳也好…影子之王习惯独行。", "Hmph, parting ways is fine... the Shadow King walks alone."),
        L("（整理衣袖）有需要的时候再来找我。", "(adjusts sleeves) Seek me out when you require assistance."),
    },
    wortox = {
        L("行，那我先自己转转...有事再叫我。", "Alright, I'll roam on my own for now... call me if you need me."),
        L("解除跟随收到，我会先保命。", "Dismissal received. I'll focus on staying alive."),
        L("别担心，我不会走太远。", "Don't worry, I won't go too far."),
        L("下次要是危险大，记得优先叫我回队。", "If things get dangerous next time, call me back first."),
    },
    wilba = {
        L("哼，既然你要赶本公主走，那本公主就走了。别后悔！", "Hmph, since you're dismissing the princess, she shall leave. Don't regret it!"),
        L("好吧，本公主正好厌倦了跟在你后面。独自美丽去～", "Fine, the princess was getting tired of following you anyway. Off to be beautiful alone～"),
        L("你竟敢解除跟随？本公主记住你了！以后别想再求我回来。", "How dare you dismiss the princess? She will remember this! Don't ever beg her to return."),
        L("哼，本公主本来就该高高在上，跟着你确实委屈我了。", "Hmph, the princess was meant to be above everyone. Following you was indeed beneath her."),
        L("（甩了甩披风）行吧，本公主批准你暂时离开。想我了随时来请安。", "(flips cape) Fine, the princess grants you temporary leave. Come pay respects whenever you miss her."),
        L("解除就解除，本公主才不稀罕呢！（小声）但你会回来找我的对吧？", "Fine, be dismissed. The princess doesn't care! (muttering) But you will come back for me, right?"),
        L("本公主的蹄子都走累了，正好要歇歇。你走吧。", "The princess's hooves are tired anyway. She needed a rest. You may go."),
        L("（整理王冠）哼，本公主独自一人也能活得精彩。你们等着瞧。", "(adjusts crown) Hmph, the princess can live splendidly on her own. Just you wait."),
        L("本公主宣布，你失去了本公主的庇护。祝你好运吧。", "The princess hereby declares that you have lost her protection. Good luck to you."),
        L("走就走，本公主正好去找几个更懂得欣赏我美貌的同伴。", "Leave then. The princess shall find companions who better appreciate her beauty."),
        L("（转过身去）本公主不想看到你的脸了。快走快走。", "(turns away) The princess does not wish to see your face any longer. Go, go."),
        L("好吧，本公主准许你离开。但本公主的耐心有限，别让我等太久。", "Very well, the princess permits you to leave. But her patience is limited. Do not keep her waiting too long."),
        L("哼！你以为本公主会挽留你吗？太天真了。", "Hmph! You think the princess would beg you to stay? How naive."),
        L("本公主正好要一个人去照照镜子，没空理你了。", "The princess was just about to go admire herself in a mirror anyway. No time for you."),
        L("（优雅地行了一个告别礼）再见，凡人。希望下次见你时，你更有品味些。", "(performs an elegant farewell bow) Farewell, commoner. May you have better taste when we meet again."),
        L("本公主的小裙子都被你带的路弄脏了，正好要找地方清理。", "The princess's little skirt got dirty on your path. She needed to find a place to clean it anyway."),
        L("解除？你确定？好吧……（叹气）本公主准了。", "Dismiss? Are you sure? Very well... (sighs) The princess grants it."),
        L("哼，失去了本公主，你的冒险将会索然无味。走着瞧。", "Hmph, without the princess, your adventures will be dreadfully dull. Mark my words."),
        L("本公主决定去那边看看，那边的人应该更有眼光。", "The princess has decided to go over there. Those people likely have better judgment."),
        L("（头也不回地走了）本公主生气了，除非你带三颗闪亮宝石来赔罪。", "(walks away without looking back) The princess is angry. Unless you bring three shiny gems as an apology, don't bother."),
    },
    wx78 = {
        L("跟随协议解除。恢复独立运算。", "FOLLOW PROTOCOL TERMINATED. RESUMING SOLO OPERATION."),
        L("批准。我将就地优化资源。", "APPROVED. I WILL OPTIMIZE LOCAL RESOURCES IN PLACE."),
        L("别指望告别演讲。我只会关机巡逻。", "DO NOT EXPECT A FAREWELL SPEECH. I WILL PATROL QUIETLY."),
        L("若你后悔，空位还在。大概。", "IF YOU REGRET THIS, A SLOT MAY STILL EXIST. PROBABLY."),
    },
    wes = { L("...", "..."), L("（挥挥手）", "(waves goodbye)") },
}

-- ── GREET 打招呼 ────────────────────────────────────────────
NPC_SPEECH.GREET = {
  _default = {
      L("你好！很高兴见到你。", "Hello! Good to see you."),
      L("嗨，今天过得怎么样？", "Hi, how's your day going?"),
      L("见到你真好！", "It's good to see you!"),
      L("你好呀，今天精神不错嘛。", "Hello~ You look in good spirits today."),
      L("欢迎！希望今天一切顺利。", "Welcome! Hope today goes well for you."),
      L("（开心地挥挥手）你好！", "(waves happily) Hello!"),
      L("嗨，最近还好吗？", "Hi, how have you been lately?"),
      L("你好，见到熟人总让人安心。", "Hello. Seeing a familiar face is always reassuring."),
  },

  wilson = {
      L("你好！今天有没有发现什么有趣的现象？", "Hello! Have you noticed anything interesting today?"),
      L("嗨，很高兴见到你！今天适合观察和思考。", "Hi, good to see you! Today feels ideal for observation and thought."),
      L("你好！见到你，我的好奇心又活跃起来了。", "Hello! Seeing you always gets my curiosity going again."),
      L("很高兴见到你，今天过得怎么样？", "Good to see you. How has your day been?"),
      L("你好！要不要听我讲讲最近的发现？", "Hello! Care to hear about my latest discovery?"),
      L("嗨，见到熟人总能让人安心不少。", "Hi. A familiar face is always reassuring."),
      L("你好！今天的天气很适合做实验，你觉得呢？", "Hello! Today's weather is perfect for experiments, don't you think?"),
      L("很高兴又见到你，有什么新见闻吗？", "Good to see you again. Any new observations to share?"),
  },

  

  wathgrithr = {
      L("勇士！你好！今日也当昂首前行！", "Warrior! Hello! Let us stride proudly through this day!"),
      L("哈！很高兴见到你，同伴！", "Ha! Good to see you, companion!"),
      L("女武神向你致以问候！今日可好？", "The Valkyrie greets you! How fare you this day?"),
      L("你好，值得尊敬的战友！", "Hello, worthy comrade! The sight of you stirs my battle spirit!"),
      L("勇士，欢迎！愿今日亦无所畏惧！", "Warrior, welcome! May this day be met without fear!"),
      L("你好！你的气势比昨日更盛了！", "Hello! Your aura is stronger than yesterday!"),
      L("很高兴又见到你，今日可曾安好？", "Good to see you again. Have you been well?"),
      L("哈！问候你，我的战友！今日必将是辉煌的一天！", "Ha! Greetings, my comrade! This shall be a glorious day!"),
  },

  wolfgang = {
      L("你好！沃尔夫冈很高兴见到你！", "Hello! Wolfgang is very happy to see you!"),
      L("嗨！今天过得怎么样？沃尔夫冈很好！", "Hi! How is your day? Wolfgang is doing great!"),
      L("你好！看沃尔夫冈的肌肉！很强！", "Hello! Look at Wolfgang's muscles! Very strong!"),
      L("见到你，沃尔夫冈很开心！", "Wolfgang is very happy to see you!"),
      L("你好！有朋友在，沃尔夫冈更有力气！", "Hello! With a friend here, Wolfgang feels even stronger!"),
      L("嗨！沃尔夫冈正想找人说说话！", "Hi! Wolfgang was hoping to talk to a friend!"),
      L("你好！我不是派大星！我是沃尔夫冈！", "Hello! You look strong today! That is good!"),
      L("很高兴见到你！今天一定是好日子！", "Good to see you! Today must be a good day!"),
  },

  wormwood = {
      L("你好！朋友！", "Hello! Friend!"),
      L("嗨！见到朋友，叶子很开心。", "Hi! Leaves feel happy seeing a friend."),
      L("你好。今天的风，在向你问好。", "Hello. Today's wind says hello to you."),
      L("朋友，你好。泥土也高兴。", "Hello, friend. Soil is happy too."),
      L("嗨！小花小草，也在欢迎你。", "Hi! The flowers and grass welcome you too."),
      L("你好。见到你，这里更温暖了。", "Hello. Seeing you makes this place warmer."),
      L("朋友你好。今天…很好。", "Hello, friend. Today... is good."),
      L("嗨！很高兴见到你，朋友。", "Hi! Good to see you, friend."),
  },

  winona = {
      L("嘿，你好。今天过得怎么样？", "Hey, hello. How's your day going?"),
      L("哟，见到你了，挺好。", "Hey, good to see you."),
      L("你好，最近还好吗？", "Hello, you doing alright lately?"),
      L("嗨，很高兴又见到你。", "Hi, good to see you again."),
      L("你好，今天看着气色不错。", "Hello, you're looking alright today."),
      L("嘿，见到熟人，心里踏实多了。", "Hey, a familiar face sure makes things easier."),
      L("你好！有你在，今天应该能顺一点。", "Hello! With you around, today should go a little smoother."),
      L("嗨，欢迎。总比一个人对着一堆破事强。", "Hi, welcome. Beats dealing with a pile of problems alone."),
  },

  warly = {
      L("转角不一定遇到爱，但一定能遇到我为您亲手做的料理", "What are you wearing today?"),
      L("你好！见到你总是令人愉快。", "Hello! Seeing you is always a pleasure."),
      L("啊，欢迎！今天过得怎么样？", "Ah, welcome! How has your day been?"),
      L("你好，很高兴见到你。今天气色不错。", "Hello, good to see you. You seem in good form today."),
      L("欢迎！今天的空气正适合一顿好饭。", "Welcome! The air today is perfect for a fine meal."),
      L("你好！我下面给你吃？", "Hello! Seeing you always improves the mood."),
      L("啊，你好。需要我给你做一份料理吗？。", "Ah, hello. A familiar face is always comforting."),
      L("很高兴见到你！要不要聊聊今天的食材？", "Good to see you! Care to talk about today's ingredients?"),
  },

  wanda = {
      L("你好。很高兴见到你，时间没有白费。", "Hello. Good to see you. Time was not wasted."),
      L("嗨，今天过得怎么样？", "Hi, how has your day been?"),
      L("需要帮忙开启时空之旅吗", "Hello. Seeing you makes the next steps much clearer."),
      L("欢迎。希望今天我们都别和时间作对。", "Welcome. Let's hope neither of us fights time today."),
      L("你好，你看起来状态不错。", "Hello, you look in good shape."),
      L("很高兴见到你。趁现在，把该做的事做完吧。", "Good to see you. Let's finish what needs doing while the timing is good."),
      L("嗨，你好。每一秒都很珍贵，别浪费。", "Hi, hello. Every second is precious. Don't waste them."),
      L("你好。又见面了，看来命运还没把我们分开。", "Hello. We meet again. Fate hasn't separated us yet."),
  },

  wickerbottom = {
      L("你好，很高兴见到你。", "Hello. It is good to see you."),
      L("啊，问候你。愿你今天一切安好。", "Ah, greetings. I trust you are doing well today."),
      L("你好。见到你总是令人欣慰。", "Hello. Seeing you is always reassuring."),
      L("很高兴又见到你，今日可好？", "Good to see you again. How fare you today?"),
      L("你好。你的到来令人愉快。", "Hello. Your arrival is most welcome."),
      L("啊，熟悉的面孔总让人安心。你好。", "Ah, a familiar face is always comforting. Hello."),
      L("问候你。希望你今日也精神饱满。", "Greetings. I hope you are in good spirits today as well."),
      L("你好。正好，也许我们可以谈谈。", "Hello. Excellent. Perhaps we may speak for a while."),
  },

  willow = {
      L("嘿，你好！今天想不想找点乐子？", "Hey, hello! Want to find some fun today?"),
      L("哟，见到你还挺开心的。", "Oh, I'm actually pretty glad to see you."),
      L("嗨，你好！今天看起来挺有意思。", "Hi, hello! Today looks like it might be fun."),
      L("你好！最近过得怎么样？", "Hello! How have you been lately?"),
      L("嘿，很高兴见到你。", "Hey, good to see you."),
      L("哟，你好。我正有点无聊呢。", "Oh, hello. I was getting a little bored."),
      L("嗨！见到熟人，总比对着灰烬强。", "Hi! Seeing a familiar face beats staring at ashes."),
      L("你好！有你在，今天应该不会太闷。", "Hello! With you around, today shouldn't be too boring."),
  },

  walter = {
      L("嗨！你也是来探险的吗？", "Hi! Are you here to explore too?"),
      L("嘿！见到你真不错！", "Hey! Good to see you!"),
      L("太好了，有人一起了！", "Great, I'm not alone anymore!"),
      L("你看起来挺可靠的！", "You look pretty reliable!"),
      L("我刚刚还在想有没有别人。", "I was just wondering if anyone else was around."),
      L("呼…见到你我安心多了。", "Phew... I feel better seeing you."),
      L("要不要一起看看这附近？", "Want to check this area out together?"),
      L("我可以给你讲讲我刚发现的东西！", "I can tell you what I just found!"),
      L("嘿，这感觉像冒险刚开始一样。", "Hey, this feels like the start of an adventure."),
      L("如果有危险，我们可以互相照应。", "If something happens, we can watch each other's backs."),
      L("我在做探险记录，你也可以看看。", "I'm keeping an expedition log, you can take a look."),
      L("今天看起来挺适合冒险的，对吧？", "Feels like a good day for adventure, right?"),
  },

  wes = {
      L("（开心地挥手问好）", "(waves happily in greeting)"),
      L("（默默鞠躬致意）", "(bows silently in greeting)"),
      L("（轻轻拍手表示欢迎）", "(claps softly in welcome)"),
      L("（高兴地点点头，像在问「你好吗？」）", "(nods happily, as if asking, 'How are you?')"),
      L("（比了个「你好」的手势）", "(gestures 'Hello')"),
      L("（笑着行了个滑稽的礼）", "(grins and gives a playful bow)"),
      L("（张开双臂，像在说「很高兴见到你」）", "(opens his arms as if saying, 'Good to see you')"),
      L("（比了个「见到你真好」的手势）", "(gestures, 'Good to see you')"),
  },

  wortox = {
      L("嗨...今天也尽量别掉血，好吗？", "Hi... let's try not to lose too much health today, okay?"),
      L("见到你真不错，我刚好在看周围风险。", "Nice to see you. I was just checking local risks."),
      L("欢迎回来，我这边治疗随时能接上。", "Welcome back. My healing is ready whenever needed."),
      L("你看起来状态还行，继续保持。", "You look in decent shape. Keep it up."),
      L("嘿，熟人到了，我就没那么紧张了。", "Hey, with a familiar face here, I'm less nervous."),
  },


  wendy = {
      L("今天…比昨天好一点点…", "Today... is a little better than yesterday..."),
      L("…见到你了…真好…", "...It's nice... to see you..."),
      L("最近感冒了，声音听起来有点像男孩子", "...You're here. It doesn't feel quite so quiet now..."),
      L("最近还好吗？", "...I hope today stays a little peaceful..."),
      L("我有每天在想你呢", "...You seem alright... that's good..."),
      L("我想一直跟着你，一起去天涯海角！", "...I'm still here... and now you are too..."),
      L("我能做你的朋友吗？", "You look strong today! That is good!"),
  },

  waxwell = {
      L("又是你…有何贵干？", "You again... what do you want?"),
      L("哼，至少你还算守时。", "Hmph, at least you're punctual."),
      L("看来今天也少不了你的身影。", "It seems your presence is unavoidable today as well."),
      L("见到你，至少不算太无聊。", "Seeing you does make things slightly less tedious."),
      L("你来了。希望你带来的不是麻烦。", "You're here. Let's hope you didn't bring trouble with you."),
      L("很好，你总算出现了。", "Good. You finally showed up."),
      L("哼，熟悉归熟悉，不代表我会热情。", "Hmph. Familiarity should not be mistaken for warmth."),
      L("嗨！今天玩原神了吗？", "Hi! Have you played Genshin Impact today?"),
  },

  woodie = {
      L("嘿，见到你真不错。", "Hey, good to see ya."),
      L("今天气色不错嘛。", "You're lookin' pretty good today."),
      L("见到熟人，心里踏实多了。", "A familiar face sure makes things easier."),
      L("怎么说？有兴趣跟着我混吗？", "Glad you're here. Means the day probably won't go too bad."),
      L("你好，我是渣渣辉，很高兴见到你", "Ha, I was just wonderin' if you'd show up."),
      L("有朋友在，干什么都顺手些。", "Work goes smoother with a friend around."),
      L("我是渣渣辉，是兄弟就一起砍树", "You're here? Good, now I've got company."),
  },

  wonkey = {
      L("你来啦！有香蕉吗？", "Ook ook! You're here! Got bananas?"),
      L("嘿嘿，朋友来了，今天肯定有好玩的。", "Hehe, friend came. Today must have fun things."),
      L("见到你真不错，别把亮晶晶藏起来哦。", "Ook! Good to see you. Don't hide the shiny things."),
      L("你来了？太好了，我们去找点好东西吧！", "You're here? Great! Let's find good stuff!"),
      L("朋友朋友！今天一起玩，不许偷偷溜走。", "Friend, friend! Play together today. No sneaking away."),
      L("闻起来像冒险的味道。", "Ook ook, smells like adventure."),
      L("嘿，你看起来很可靠，也许还能分我一根香蕉。", "Hey, you look reliable. Maybe you can spare a banana."),
      L("嘿！我的香蕉比你的大，需要换一下吗？", "Hey! My banana is bigger than yours. Need to swap?"),
      L("见到熟人真好，猴子心情都变好了。", "Good to see a familiar face. Even monkey mood gets better."),
  },

  wilba = {
      L("呀，你来啦！本公主今天心情不错，准许你靠近说话。", "Oh, you're here! The princess is in a good mood today. You may approach and speak."),
      L("（开心地挥手）臣民，见到本公主还不快行礼？", "(waves happily) Subject, why aren't you bowing before the princess?"),
      L("哼，你可算来了。本公主等你很久了，不过念在你还有诚意的份上，原谅你。", "Hmph, you've finally arrived. The princess has been waiting for a while, but she will forgive you for your sincerity."),
      L("啊，本公主的忠实伙伴！今天也来欣赏我的美貌吗？", "Ah, the princess's loyal companion! Come to admire her beauty again today?"),
      L("（对着来人整理了一下发型）嗯，你来得正好，本公主刚打扮完。", "(fixes her hair toward the newcomer) Mm, you've come just as the princess finished getting ready."),
      L("喂～你看到本公主今天的新王冠了吗？是不是比昨天更闪亮？", "Hey～ Have you seen the princess's new crown today? Isn't it even shinier than yesterday?"),
      L("本公主准你留在身边了。开心吗？可以笑出来哦。", "The princess permits you to stay by her side. Are you happy? You may smile."),
      L("（骄傲地昂首）哼，本公主就知道你会来找我。毕竟没人能拒绝我的魅力。", "(lifts head proudly) Hmph, the princess knew you would come looking for her. After all, no one can resist her charm."),
      L("哎呀，是熟人呀。本公主特许你今天多看我几眼。", "Oh my, it's a familiar face. The princess grants you a few extra glances at her today."),
      L("臣民～你来得正好，本公主正觉得无聊呢。陪我聊聊天。", "Subject～ You've come at the perfect time. The princess was just feeling bored. Keep her company."),
      L("（轻轻拍手）太好了，总算有个懂得欣赏的人来了。", "(claps lightly) Wonderful, someone with good taste has finally arrived."),
      L("本公主刚刚还在想，要是没人来夸我漂亮，今天可就白过了。", "The princess was just thinking, if no one came to praise her beauty, today would have been wasted."),
      L("你看起来还不错，本公主决定今天对你温柔一点。", "You look decent today. The princess has decided to be a little gentler with you."),
      L("（转了个圈）看看本公主的新裙子，是不是美极了？快夸！", "(spins around) Look at the princess's new dress. Is it not absolutely beautiful? Praise her now!"),
      L("呀，是你呀！本公主的幸运日到了！", "Oh, it's you! The princess's lucky day has arrived!"),
      L("（优雅地欠身）欢迎，本公主准许你成为今天的幸运儿。", "(curtsies gracefully) Welcome. The princess permits you to be today's lucky one."),
      L("哼，来得这么晚，本公主差点就要生气了。不过看在你诚心的份上，算了。", "Hmph, coming so late. The princess was nearly angry. But considering your sincerity, she'll let it slide."),
  },

  wx78 = {
      L("检测到熟悉信号。指挥官，你好。", "FAMILIAR SIGNAL DETECTED. HELLO, COMMANDER."),
      L("问候完成。请下达任务。", "GREETING COMPLETE. ISSUE ORDERS."),
      L("你又来了。希望不是来浪费我转速的。", "YOU AGAIN. HOPE YOU ARE NOT HERE TO WASTE MY RPM."),
      L("系统状态良好。你今天看起来仍然很有机。", "SYSTEMS GREEN. YOU STILL LOOK VERY ORGANIC TODAY."),
      L("欢迎。别靠太近，我天线会戳到你。", "WELCOME. DO NOT STAND TOO CLOSE. MY ANTENNA MAY POKE YOU."),
      L("今日目标：旋转、收集、存活。", "TODAY'S OBJECTIVES: SPIN, GATHER, SURVIVE."),
  },
}

-- ── HIT_BY_PLAYER 被误伤 ────────────────────────────────────
NPC_SPEECH.HIT_BY_PLAYER = {
    _default = { L("我是队友！别打我！", "I'm your teammate! Don't hit me!") },
    wilson = { L("友军误伤！请注意目标识别！", "Friendly fire! Check your targeting!"), L("这不在实验计划内！", "This wasn't in the experiment plan!") },
    wendy = { L("…你也要伤害我吗…", "...You want to hurt me too..."), L("…痛…", "...Hurts...") },
    wathgrithr = { L("喂！刀剑无眼但你该长眼！", "Hey! Swords are blind but you shouldn't be!"), L("友军伤害！注意你的武器！", "Friendly fire! Watch your weapon!") },
    wolfgang = { L("沃尔夫冈是朋友！别打！", "Wolfgang is friend! Don't hit!"), L("好痛！沃尔夫冈不是坏人！", "Ouch! Wolfgang is not bad guy!") },
    wormwood = { L("疼！植物人是朋友！", "Ow! Wormwood is friend!"), L("别打植物人！植物人不是坏的！", "Don't hit Wormwood! Wormwood not bad!") },
    waxwell = { L("你敢打我？！", "You dare strike ME?!"), L("哼，注意你的武器…下次可就不止是警告。", "Hmph, mind your weapon... next time it won't be just a warning.") },
    wx78 = {
        L("友军识别失败。请修正你的瞄准模块。", "FRIENDLY ID FAILED. FIX YOUR TARGETING MODULE."),
        L("警告：再误击将启动反击子程序。", "WARNING: REPEAT HITS ENABLE RETALIATION SUBROUTINE."),
        L("我的外壳不是给你练手的。", "MY CHASSIS IS NOT YOUR PRACTICE DUMMY."),
    },
    wes = { L("！！", "!!"), L("（捂着被打的地方）", "(holds where it was hit)") },
}

-- ── RESKIN 换肤 ─────────────────────────────────────────────
NPC_SPEECH.RESKIN = {
    _default = {
        L("谢谢你帮我打扮~", "Thanks for dressing me up~"),
        L("（开心地转了一圈）", "(spins around happily)"),
    },
    wilson = {
        L("新造型…从空气动力学角度来说更优了！", "New look... aerodynamically superior!"),
        L("外观改变，但科学精神不变！", "Appearance changes, but scientific spirit remains!"),
        L("哦！这材料的分子结构很有趣！", "Oh! This material's molecular structure is interesting!"),
    },
    wendy = {
        L("…新衣服…也改变不了什么…", "...New clothes... won't change anything..."),
        L("（低头看了看）…还行吧…", "(looks down) ...It's okay..."),
        L("阿比盖尔…你觉得好看吗…", "Abigail... do you think it looks nice..."),
    },
    wathgrithr = {
        L("哈！新战甲！更适合战场！", "Ha! New battle armor! Better for combat!"),
        L("这身装扮，配得上女武神的威名！", "This outfit befits the Valkyrie's fame!"),
        L("穿上战袍，所向披靡！", "In battle garb, unstoppable!"),
    },
    wolfgang = {
        L("新衣服！沃尔夫冈好看！", "New clothes! Wolfgang looks good!"),
        L("这衣服能装下沃尔夫冈的肌肉吗？", "Can these clothes fit Wolfgang's muscles?"),
        L("沃尔夫冈喜欢！谢谢！", "Wolfgang likes! Thanks!"),
    },
    wormwood = {
        L("新叶子！好看！", "New leaves! Pretty!"),
        L("（低头看了看自己）不一样了。", "(looks down at self) Different now."),
        L("谢谢。植物人喜欢。", "Thanks. Wormwood likes it."),
    },
    waxwell = {
        L("嗯…这套倒还算有品位。", "Hmm... this has some taste at least."),
        L("换个行头…也好，影子之王需要多种面貌。", "A change of attire... well, the Shadow King requires many guises."),
        L("（整理衣领）尚可接受。", "(adjusts collar) Acceptable."),
    },
    wx78 = {
        L("外壳涂装已更新。空气阻力略降。", "CHASSIS COATING UPDATED. AIR DRAG SLIGHTLY REDUCED."),
        L("新外观。核心仍是同一个冷酷的我。", "NEW APPEARANCE. SAME COLD CORE INSIDE."),
        L("（空转一圈）展示完毕。回去干活。", "(spins idle) DISPLAY COMPLETE. BACK TO WORK."),
    },
    wes = { L("（开心地转了一圈）", "(spins around happily)"), L("（竖起大拇指）", "(gives thumbs up)") },
}

-- ── RESKIN_NO_SKINS 没皮肤 ──────────────────────────────────
NPC_SPEECH.RESKIN_NO_SKINS = {
    _default = { L("（没有可用的服装皮肤）", "(No available outfit skins)") },
    wilson = { L("没有额外的实验服…", "No spare lab coats...") },
    wendy = { L("…没有衣服…", "...No clothes...") },
    wathgrithr = { L("没有新战甲？可惜！", "No new armor? Pity!") },
    wolfgang = { L("没有新衣服…", "No new clothes...") },
    wormwood = { L("没有新叶子…", "No new leaves...") },
    waxwell = { L("没有合适的服装…罢了。", "No suitable attire... never mind.") },
    wx78 = { L("无可用外壳模块。维持出厂涂装。", "NO CHASSIS MODULES AVAILABLE. KEEPING FACTORY PAINT.") },
    wes = { L("（摆摆手）", "(waves hand)") },
}

-- ── NEED_FLUTE 缺排箫 ──────────────────────────────────────
NPC_SPEECH.NEED_FLUTE = {
    _default = { L("给我排箫！我能让它冷静下来！", "Give me a Pan Flute! I can calm it!") },
    wilson = { L("排箫的声波频率能干扰它的神经系统！快给我！", "The Pan Flute's frequency can disrupt its nervous system! Give it!") },
    wendy = { L("排箫…也许能让一切安静下来…", "Pan Flute... maybe it can quiet everything...") },
    wathgrithr = { L("排箫！女武神需要那件神器！", "Pan Flute! The Valkyrie needs that artifact!") },
    wolfgang = { L("给沃尔夫冈那个吹的东西！快！", "Give Wolfgang that blowy thing! Quick!") },
    wormwood = { L("给植物人那个吹的！能让它安静！", "Give Wormwood the blowy thing! Can make it quiet!") },
    waxwell = { L("排箫…我知道它的用处。快给我。", "Pan Flute... I know its purpose. Give it to me.") },
    wes = { L("（比划着吹箫的动作）", "(mimes playing flute)") },
}


-- ── STALKER 远古织影者专属 ──────────────────────────────────
NPC_SPEECH.STALKER_NEED_ITEMS = {
    _default = { L("给我懒人魔杖和风向标，我能单挑这只怪物！", "Give me a Lazy Explorer and Weather Pain, I can solo this!") },
    wilson = { L("我需要懒人魔杖进行空间位移，还有风向标制造气流干扰！", "I need Lazy Explorer for spatial displacement and Weather Pain for air disruption!") },
    wendy = { L("给我魔杖和风向标…我会结束这一切…", "Give me the staff and Weather Pain... I'll end this...") },
    wathgrithr = { L("懒人魔杖和风向标！给女武神双神器！", "Lazy Explorer and Weather Pain! Give the Valkyrie both!") },
    wolfgang = { L("给沃尔夫冈魔法棍子和风吹的东西！", "Give Wolfgang magic stick and windy thing!") },
    wormwood = { L("给植物人魔法棍和吹风的！植物人能打！", "Give Wormwood magic stick and windy thing! Wormwood can fight!") },
    waxwell = { L("给我那些装备…这种怪物，我再熟悉不过了。", "Give me those items... I am all too familiar with creatures like this.") },
    wes = { L("（比划着要装备）", "(mimes needing equipment)") },
}

NPC_SPEECH.STALKER_SNARE_ESCAPE = {
    _default = { L("哈！困不住我！", "Ha! Can't trap me!"), L("想困住我？没门！", "Trap me? No way!") },
    wilson = { L("空间折叠逃脱！科学万岁！", "Spatial fold escape! Science!"), L("骨刺牢笼？科学不认识这个词！", "Bone cage? Science knows no such word!") },
    wendy = { L("…牢笼困不住影子…", "...Cages can't hold shadows..."), L("逃出来了…", "Escaped...") },
    wathgrithr = { L("区区牢笼！挡不住女武神！", "Mere cage! Can't stop the Valkyrie!"), L("破笼而出！这才是战士！", "Breaking free! That's a warrior!") },
    wolfgang = { L("沃尔夫冈逃出来了！太厉害了！", "Wolfgang escaped! So amazing!"), L("困不住沃尔夫冈！", "Can't trap Wolfgang!") },
    wormwood = { L("根挛开了！困不住！", "Roots broke free! Can't trap!"), L("植物人会钻出来！", "Wormwood can dig out!") },
    waxwell = { L("哼，想困住暗影的主人？可笑。", "Hmph, trap the master of shadows? Absurd."), L("这点小把戏…瞒不过我。", "Such petty tricks... cannot fool me.") },
    wes = { L("！", "!"), L("（灵活地闪避）", "(dodges nimbly)") },
}

NPC_SPEECH.STALKER_TORNADO = {
    _default = { L("吃我一记龙卷风！", "Eat this tornado!") },
    wilson = { L("风向标启动！气旋攻击！", "Weather Pain activated! Cyclone attack!"), L("让旋转气流摧毁护盾！", "Let the vortex destroy the shield!") },
    wendy = { L("风啊…带走一切吧…", "Wind... carry everything away..."), L("龙卷风…比我的心还要乱…", "Tornado... more chaotic than my heart...") },
    wathgrithr = { L("风暴女武神发动攻击！", "Storm Valkyrie launches attack!"), L("让暴风吞噬一切！", "Let the storm devour all!") },
    wolfgang = { L("看沃尔夫冈的大风！", "Look at Wolfgang's big wind!"), L("吹飞你们！", "Blow you away!") },
    wormwood = { L("大风吹！吹走坏东西！", "Big wind blow! Blow bad things away!"), L("风来了！呼呼！", "Wind is here! Whoosh!") },
    waxwell = { L("风暴…我的旧识了。", "A tempest... an old acquaintance."), L("让暗影之风吞噬一切！", "Let the shadow winds devour all!") },
    wes = { L("（无声地挥动风向标）", "(swings Weather Pain silently)") },
}

-- ════════════════════════════════════════════════════════════
--  角色专属场景（保持原有结构）
-- ════════════════════════════════════════════════════════════

-- 麦斯威尔暗影召唤
NPC_SPEECH.SHADOW_SUMMON = {
    L("为我而战吧，影子。", "Fight for me, shadow."),
    L("暗影听从我的召唤。", "Shadows, heed my call."),
    L("来吧，我忠诚的仆从。", "Come, my loyal servant."),
    L("影子，去消灭他们。", "Shadow, eliminate them."),
    L("黑暗赋予我力量…现身吧！", "Darkness grants me power... manifest!"),
    L("我召唤你…从虚空而来！", "I summon thee... from the void!"),
}

-- 麦斯威尔暗影支柱（群控技能）
NPC_SPEECH.SHADOW_PILLAR = {
    L("束缚吧，暗影之力!", "Bind them, shadow's might!"),
    L("原神…赐予我力量!", "You're not going anywhere!"),
    L("暗影支柱!", "Shadow pillars!"),
    L("这就是暗影的力量!", "This is the power of shadows!"),
    L("给我站在原地!", "Stay where you are!"),
    L("暗影禁锢!", "Shadow prison!"),
    L("原神…赐予我力量!", "Shadow pillars!"),
}

-- 女武神拒绝素食
NPC_SPEECH.REFUSE_FOOD = {
    L("拒绝", "I won't eat it!"),

}

NPC_SPEECH.ABIGAIL_REFUSE_FOOD = {
    L("灵魂不需要进食…", "Spirits don't need to eat..."),
    L("我已经不需要这些了…", "I don't need these anymore..."),
    L("（食物穿过了她的身体）", "(the food passes through her body)"),
    L("这些…对我没有用了…", "These... are of no use to me now..."),
    L("我现在不需要吃东西…", "I don't need food now..."),
}

NPC_SPEECH.WORMWOOD_REFUSE_FOOD = {
    L("（困惑地看着食物）…这不是给我的", "(stares at food confused) ...this isn't for me"),
    L("我…不吃这个", "I... don't eat this"),
    L("（摇头）不需要…我有根", "(shakes head) Don't need... I have roots"),
    L("我不是…吃东西的朋友", "I'm not... a food-eating friend"),
    L("（轻轻推开）谢谢…但不用", "(gently pushes away) Thanks... but no"),
    L("我只需要阳光和水…", "I only need sunlight and water..."),
}

NPC_SPEECH.WARLY_REFUSE_FOOD = {
    L("谢谢你的好意，但我自己来料理就好", "Merci, but I prefer to cook for myself"),
    L("作为厨师，我对食材有自己的讲究", "As a chef, I have my own standards for ingredients"),
    L("请不用担心我，厨房就是我的战场", "No need to worry about me, the kitchen is my battlefield"),
    L("（微笑摆手）食物的事，交给专业的来", "(smiles and waves) Leave the food matters to a professional"),
    L("我更享受亲手烹饪的乐趣", "I much prefer the joy of cooking with my own hands"),
    L("好厨师从不让别人喂饭", "A good chef never lets others feed him"),
}

-- 旺达拒绝永久加血方糖（npc_heart）
NPC_SPEECH.WANDA_REFUSE_HEART = {
    wanda = {
        L("不行，我不能靠这种方式改写我的时间。", "No, I can't rewrite my time like this."),
        L("这颗糖会扰乱我的年龄刻度，我拒绝。", "That candy would disturb my age scale. I refuse."),
        L("别喂我这个，我的时间线会被它弄乱。", "Don't feed me that. It will mess up my timeline."),
    },
    _default = {
        L("这个不适合我。", "This doesn't suit me."),
    },
}

-- 温蒂复活（忧郁诗意风格）
NPC_SPEECH.ABIGAIL_REVIVE = {
    L("又从黑暗中回来了…这条路我走过太多次。", "Back from the darkness again... I've walked this path too many times."),
    L("死亡只是短暂的离别…不是吗，阿比盖尔？", "Death is but a brief parting... isn't it, Abigail?"),
    L("虚空没有留住我…这次还不是永别。", "The void did not keep me... it is not yet farewell."),
    L("我又回到了这喧嚣的世界…多么笫惫。", "I've returned to this noisy world... how tiresome."),
    L("在那边…我差点就能拥抱你了，阿比盖尔。", "Over there... I almost could have embraced you, Abigail."),
    L("活着的感觉…如此沉重。", "The feeling of being alive... so heavy."),
}

-- ════════════════════════════════════════════════════════════
--  温蒂召唤/收回阿比盖尔专用台词
-- ════════════════════════════════════════════════════════════

-- SUMMON_ABIGAIL — 召唤阿比盖尔时
NPC_SPEECH.SUMMON_ABIGAIL = {
    wendy = {
        L("到我身边来，阿比盖尔…黑暗在呼唤我们。", "Come to me, Abigail... The darkness calls for us both."),
        L("醒来吧，姐姐…让他们感受彼岸的寒意。", "Rise, sister... Let them know the chill of the beyond."),
        L("阿比盖尔，我需要你…一如既往。", "Abigail, I need you... as I always have."),
        L("我从虚空中召唤你，亲爱的姐姐。", "From the void, I call upon you, dear sister."),
        L("世界的面纱渐渐稀薄…来吧，阿比盖尔。", "The veil between worlds grows thin... Come, Abigail."),
        L("我们再次相聚…死亡也无法将我们分离。", "Together again... even death cannot keep us apart."),
    },
}

-- UNSUMMON_ABIGAIL — 收回阿比盖尔时
NPC_SPEECH.UNSUMMON_ABIGAIL = {
    wendy = {
        L("休息吧，阿比盖尔…直到暗影再次召唤。", "Rest now, Abigail... until the shadows call again."),
        L("回到彼岸去吧，姐姐…暂时。", "Return to the other side, sister... for now."),
        L("虚空的安宁在等待你，阿比盖尔。", "The peace of the void awaits you, Abigail."),
        L("好好睡吧，亲爱的姐姐…我会再次呼唤你。", "Sleep well, dear sister... I will call you again."),
        L("回到黑暗中去…那里才是你的归宿。", "Back to the darkness... where you are most at home."),
        L("在世界的夹缝之间再会…", "Until we meet again in the space between worlds..."),
    },
}


-- 沃尔夫冈状态切换
NPC_SPEECH.WOLFGANG_STATE_CHANGE = {
    wimpy = {
        L("好饿…力气都没了…", "So hungry... lost all my strength..."),
        L("肚子咕咕叫…需要食物…", "Stomach's grumbling... need food..."),
        L("沃尔夫冈…好虚弱…", "Wolfgang... so weak..."),
        L("没力气了…给我点吃的…", "No energy... give me something to eat..."),
    },
    normal = {
        L("嗯…还行，但还能更强！", "Hmm... okay, but could be stronger!"),
        L("给我点吃的，我能变得更强！", "Feed me and I'll get even stronger!"),
        L("沃尔夫冈需要更多食物！", "Wolfgang needs more food!"),
    },
    mighty = {
        L("力量充沛！无人能挡！", "Full of power! None can stop me!"),
        L("哈哈！沃尔夫冈最强！", "Haha! Wolfgang is the strongest!"),
        L("感受纯粹的力量吧！", "Feel the pure power!"),
        L("沃尔夫冈是大力士！", "Wolfgang is the strongman!"),
    },
}

-- ════════════════════════════════════════════════════════════
--  NPC 互聊（角色组合对话，支持 a_b 与 b_a 双向主动对话）
--  每条 = { A说的话, B说的话 }；A 为 key 中第一个角色
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.NPC_CHAT = {
    -- Wilson + Wendy: 科学宅 vs 忧郁少女
    wilson_wendy = {
        { L("温蒂，你知道吗？月亮的引力会影响这里的潮汐！", "Wendy, did you know? The moon's gravity affects tides here!"),
          L("…月亮啊…它总让我想起阿比盖尔…", "...The moon... always reminds me of Abigail...") },
        { L("我发现了一个有趣的科学现象！", "I discovered a fascinating scientific phenomenon!"),
          L("…有趣？什么是有趣呢…", "...Fascinating? What does that mean...") },
        { L("你总是这么安静，在想什么呢？", "You're always so quiet, what are you thinking?"),
          L("…在想…这个世界还有多少悲伤…", "...Thinking... how much sadness this world holds...") },
        { L("温蒂，这朵花的花粉结构非常特别！你要看看吗？", "Wendy, this flower's pollen structure is remarkable! Want to see?"),
          L("花…总会凋谢的…但…谢谢你给我看…", "Flowers... always wilt... but... thanks for showing me...") },
        { L("根据我的观察，你笑起来的时候很好看。", "Based on my observations, you look nice when you smile."),
          L("…（微微红了脸）…你在说什么奇怪的话…", "...(blushes slightly) ...What are you saying...") },
        { L("温蒂，我刚刚在想，如果悲伤可以量化，会是什么单位？", "Wendy, I was just wondering, if sadness could be quantified, what would its unit be?"),
          L("…也许不是单位…而是漫长的夜晚…", "...Maybe not a unit... but a very long night...") },
        { L("你总盯着天空看，是在观察云层运动吗？", "You stare at the sky so often. Are you observing cloud movement?"),
          L("…我只是在看…那些不会留下来的东西…", "...I'm just watching... things that never stay...") },
        { L("我可以给你讲个科学笑话，成功率大概有百分之六十。", "I can tell you a science joke. Estimated success rate: sixty percent."),
          L("…剩下的百分之四十，是更冷的空气吗…", "...And the other forty percent is colder air...?") },
        { L("其实你很适合做观察记录，细致又安静。", "You'd actually be good at observation logs. Careful and quiet."),
          L("…听起来像一种不会被打扰的工作…", "...That sounds like the kind of work no one would disturb...") },
        { L("今天的花开得很好，我觉得这是个积极信号。", "The flowers look wonderful today. I'd call that a positive sign."),
          L("…嗯…至少今天，它们还在盛开…", "...Mm... at least today, they're still blooming...") },
    },
    -- Wilson + Wathgrithr: 科学宅 vs 女武神
    wilson_wathgrithr = {
        { L("从力学角度分析，你的挥剑轨迹可以再优化15%。", "Biomechanically, your swing arc could be optimized by 15%."),
          L("少废话！女武神的剑不需要科学！", "Less talk! Valkyrie's blade needs no science!") },
        { L("你有没有想过，为什么你的战斗力这么强？", "Have you ever wondered why you're so powerful?"),
          L("因为我是女武神！不需要理由！", "Because I'm the Valkyrie! No reason needed!") },
        { L("我想测量一下你的握力指数…", "I'd like to measure your grip strength index..."),
          L("（捏碎了测力计）…你说什么？", "(crushes the meter) ...What did you say?") },
        { L("薇格弗德，肉类烹饪温度在145°F时风味最佳——", "Wigfrid, meat flavor peaks at 145°F cooking temperature—"),
          L("少说废话！大火烤到焦香就对了！", "Stop blabbering! Char it over high flame!") },
        { L("我在写一篇关于瓦尔基里战术的论文…", "I'm writing a paper on Valkyrie combat tactics..."),
          L("哦？那一定要写上：女武神，天下无敌！", "Oh? Make sure to write: the Valkyrie, unmatched!") },
        { L("薇格弗德，我在考虑为你的长矛写一份维护手册。", "Wigfrid, I'm considering writing a maintenance manual for your spear."),
          L("哈！真正的战士靠直觉保养武器！", "Ha! True warriors maintain weapons by instinct!") },
        { L("如果把你的战吼音量数据化，应该能震碎不少东西。", "If your battle cry were quantified, it could probably shatter things."),
          L("那正好！省得我再挥第二剑！", "Excellent! Then I won't need a second swing!") },
        { L("你的头盔设计很有特色，兼具威慑与仪式感。", "Your helmet design is quite distinctive. Intimidating and ceremonial."),
          L("当然！女武神的威严，岂能平庸！", "Of course! The majesty of a Valkyrie must never be plain!") },
        { L("你有没有想过，战歌其实也是一种群体激励技术？", "Have you ever considered war songs a form of group motivation technique?"),
          L("少把荣耀说得像课堂讲义！", "Stop making glory sound like a classroom lecture!") },
        { L("理论上说，我们合作能把效率提高到惊人的水平。", "Theoretically, our teamwork could reach astonishing efficiency."),
          L("那就别只理论，跟我一起冲锋！", "Then stop theorizing and charge with me!") },
    },
    -- Wilson + Wolfgang: 科学宅 vs 大力士
    wilson_wolfgang = {
        { L("沃尔夫冈，你知道肌肉的收缩原理吗？", "Wolfgang, do you know how muscle contraction works?"),
          L("沃尔夫冈不知道，但沃尔夫冈有大肌肉！", "Wolfgang doesn't know, but Wolfgang has big muscles!") },
        { L("根据营养学，你应该多吃蛋白质。", "Nutritionally, you should eat more protein."),
          L("沃尔夫冈只知道要吃很多！", "Wolfgang only knows to eat a lot!") },
        { L("让我测量一下你的力量…天哪这数据！", "Let me measure your strength... good heavens, this data!"),
          L("哈哈！沃尔夫冈最强！", "Haha! Wolfgang is strongest!") },
        { L("沃尔夫冈，天黑了别怕，这只是地球自转导致的——", "Wolfgang, don't fear the dark, it's just Earth's rotation—"),
          L("沃…沃尔夫冈不怕！你站近一点就好…", "W-Wolfgang not afraid! Just... stand closer...") },
        { L("我做了一个新发明！可以自动切肉！", "I made a new invention! It auto-cuts meat!"),
          L("沃尔夫冈喜欢！什么时候吃？", "Wolfgang likes! When do we eat?") },
        { L("沃尔夫冈，你每天到底要吃多少东西？", "Wolfgang, just how much do you eat in a day?"),
          L("很多！因为沃尔夫冈很大只！", "A lot! Because Wolfgang is very big!") },
        { L("你的力量样本很珍贵，我很想做长期观察。", "Your strength samples are invaluable. I'd love to do a long-term study."),
          L("观察可以，先给沃尔夫冈吃饭。", "Study is fine. Feed Wolfgang first.") },
        { L("你有没有兴趣尝试更科学的训练计划？", "Would you be interested in a more scientific training plan?"),
          L("只要里面有吃饭和睡觉，沃尔夫冈就愿意！", "As long as it has eating and sleeping, Wolfgang agrees!") },
        { L("其实你比看起来更有战术直觉。", "You're actually more tactically intuitive than you seem."),
          L("沃尔夫冈不知道什么叫战术，但知道什么时候该打！", "Wolfgang doesn't know tactics, but knows when to punch!") },
        { L("今天夜里如果你害怕，我可以给你解释星象。", "If you're scared tonight, I can explain the stars to you."),
          L("沃尔夫冈不是怕！只是…听你说话比较安心。", "Wolfgang not scared! Just... feels safer hearing you talk.") },
    },
    -- Wathgrithr + Wendy: 女武神 vs 忧郁少女
    wathgrithr_wendy = {
        { L("温蒂！振作起来！战士不该如此消沉！", "Wendy! Cheer up! Warriors shouldn't be so down!"),
          L("…我不是战士…我只是…在这里…", "...I'm not a warrior... I'm just... here...") },
        { L("你的阿比盖尔，是一个好战士。", "Your Abigail is a fine warrior."),
          L("…谢谢…她一直在保护我…", "...Thank you... she always protects me...") },
        { L("来！跟女武神一起训练！", "Come! Train with the Valkyrie!"),
          L("…好累…但…好吧…", "...So tiring... but... okay...") },
        { L("你看那朵花，多美！…呃我是说，多有战斗精神！", "Look at that flower, so beautiful!... I mean, so battle-spirited!"),
          L("…你其实也喜欢花吧…没关系…我不会说的…", "...You actually like flowers too... it's okay... I won't tell...") },
        { L("温蒂，想家的时候就大喊一声！把悲伤喊出去！", "Wendy, when you miss home, just shout! Yell the sadness away!"),
          L("…（小声）…啊…（更小声）…我尽力了…", "...(quietly) ...ah... (even quieter) ...I tried...") },
        { L("温蒂，抬起头来！地平线可不会向你低头！", "Wendy, lift your head! The horizon will never bow to you!"),
          L("…可它至少…不会离开我…", "...But at least... it won't leave me...") },
        { L("悲伤若无法斩断，就驯服它！", "If sorrow cannot be slain, then tame it!"),
          L("…你说得轻巧…可它总在夜里回来…", "...You make it sound easy... but it always returns at night...") },
        { L("你的眼神里有风暴，只是你还没让它咆哮。", "There is a storm in your eyes. You just haven't let it roar yet."),
          L("…也许我更擅长让它沉下去…", "...Maybe I'm better at letting it sink...") },
        { L("来，握紧武器！哪怕只是为了自己！", "Come, hold your weapon tight! If only for your own sake!"),
          L("…为了自己啊…这倒是个陌生的理由…", "...For myself... that's a strange reason...") },
        { L("你比你以为的坚强，少女。", "You are stronger than you think, girl."),
          L("…谢谢…这句话，我会记住的…", "...Thank you... I'll remember that...") },
    },
    -- Wendy + Wolfgang: 忧郁少女 vs 大力士
    wendy_wolfgang = {
        { L("…沃尔夫冈…你怕黑吗…", "...Wolfgang... are you afraid of the dark..."),
          L("沃尔夫冈…沃尔夫冈才不怕！…一点点怕。", "Wolfgang... Wolfgang not afraid!... A little afraid.") },
        { L("为什么…你总是这么开心…", "Why... are you always so happy..."),
          L("因为沃尔夫冈有朋友！有食物！", "Because Wolfgang has friends! And food!") },
        { L("死亡…你想过吗…", "Death... have you thought about it..."),
          L("沃尔夫冈不想！沃尔夫冈要吃东西！", "Wolfgang doesn't think! Wolfgang wants food!") },
        { L("…你的手…好大…好温暖…", "...Your hands... so big... so warm..."),
          L("温蒂冷吗？沃尔夫冈帮你挡风！", "Wendy cold? Wolfgang block the wind for you!") },
        { L("阿比盖尔说…她觉得你很可爱…", "Abigail says... she thinks you're cute..."),
          L("可…可爱？沃尔夫冈是强壮！不是可爱！（脸红）", "C-cute? Wolfgang is STRONG! Not cute! (blushing)") },
        { L("…你总是把事情想得很简单。", "...You always make things sound simple."),
          L("简单一点比较好！复杂会饿！", "Simple is better! Complicated makes Wolfgang hungry!") },
        { L("如果有一天我一直不说话，你会怎么办…", "...If one day I stopped talking entirely, what would you do..."),
          L("那沃尔夫冈就坐在旁边陪你，不说话也陪！", "Then Wolfgang sits beside you. No talking, still stay!") },
        { L("…你真奇怪。", "...You're strange."),
          L("很多人都这么说！但沃尔夫冈觉得这是夸奖！", "Many people say that! Wolfgang thinks it is compliment!") },
        { L("有时候…我真羡慕你能直接笑出来。", "...Sometimes... I envy how easily you can laugh."),
          L("那温蒂也一起笑！沃尔夫冈可以先笑给你看！", "Then Wendy laugh too! Wolfgang can laugh first for you!") },
        { L("…如果冷的话，你真的会替我挡风吗？", "...If it got cold, would you really block the wind for me?"),
          L("当然！沃尔夫冈很大只，能挡很多风！", "Of course! Wolfgang is big. Wolfgang can block lots of wind!") },

    },
    -- Wathgrithr + Wolfgang: 女武神 vs 大力士
    wathgrithr_wolfgang = {
        { L("沃尔夫冈！来比试一下谁更强！", "Wolfgang! Let's see who's stronger!"),
          L("沃尔夫冈不怕！沃尔夫冈最强！", "Wolfgang not afraid! Wolfgang is strongest!") },
        { L("你的力量不错，但缺少技巧！", "Your strength is good, but you lack technique!"),
          L("沃尔夫冈不需要技巧！沃尔夫冈用力气！", "Wolfgang doesn't need technique! Wolfgang uses strength!") },
        { L("和你并肩作战，倒也痛快！", "Fighting alongside you is quite thrilling!"),
          L("沃尔夫冈也觉得！我们最强！", "Wolfgang thinks so too! We're the strongest!") },
        { L("来！看谁吃肉吃得多！", "Come! See who can eat more meat!"),
          L("沃尔夫冈绝对赢！（开始狂吃）", "Wolfgang definitely wins! (starts gobbling)") },
        { L("沃尔夫冈，你是女武神认可的战友！", "Wolfgang, you are a comrade the Valkyrie approves of!"),
          L("真…真的吗？沃尔夫冈好开心！", "R-really? Wolfgang so happy!") },
        { L("沃尔夫冈！你这身板，天生就该冲锋在前！", "Wolfgang! With a frame like yours, you were born to charge first!"),
          L("沃尔夫冈喜欢冲前面！前面有敌人，也可能有食物！", "Wolfgang likes front! Front has enemies, and maybe food!") },
        { L("你若学会节奏与步法，力量还能再翻一番！", "If you learned rhythm and footwork, your strength would double!"),
          L("那你教沃尔夫冈！但不要教太难的！", "Then you teach Wolfgang! But not too hard!") },
        { L("与强者并肩，连空气都变得滚烫！", "When I stand beside the strong, even the air burns hot!"),
          L("哈哈！沃尔夫冈也觉得热血起来了！", "Haha! Wolfgang also feels full of hot blood!") },
        { L("你若生在我的故乡，定会是个传奇战士！", "Had you been born in my homeland, you'd be a legendary warrior!"),
          L("真的吗？那沃尔夫冈是不是还能有更大的披风？", "Really? Then would Wolfgang get even bigger cape?") },
        { L("来！比比谁先把这块肉吃完！", "Come! Let us see who finishes this meat first!"),
          L("这个比赛沃尔夫冈从来不输！", "Wolfgang never loses this contest!") },
    },
    -- 同角色对话
    wilson_wilson = {
        { L("另一个我？这在科学上叫做…量子分裂！", "Another me? In science this is called... quantum splitting!"),
          L("不对，这是平行宇宙理论的证据！", "Wrong, this is evidence of parallel universe theory!") },
        { L("你的科学笔记和我的完全不同！", "Your science notes are completely different from mine!"),
          L("也许我们可以互相对照…太令人兴奋了！", "Maybe we can cross-reference... how exciting!") },
        { L("你觉得火药的最佳配比是多少？", "What do you think is the optimal gunpowder ratio?"),
          L("这取决于湿度和气压！我正好有公式！", "Depends on humidity and pressure! I have a formula!") },
        { L("如果我们一起做实验，失败率会降低吗？", "If we worked together, would the failure rate decrease?"),
          L("不，会翻倍。因为我们都会坚持自己的方案。", "No, it'd double. Because we'd both insist on our own method.") },
        { L("看到另一个自己，真是种奇怪的科研体验。", "Seeing another me is a very strange scientific experience."),
          L("同意。我已经开始想写观察报告了。", "Agreed. I'm already drafting the observation report.") },
        { L("你觉得谁更聪明？", "Who do you think is smarter?"),
          L("这是个很没效率的问题，但答案显然是我。", "A terribly inefficient question, but obviously me.") },
        { L("你也会半夜突然冒出灵感吗？", "Do you also get sudden inspiration at midnight?"),
          L("当然，而且通常会顺便把营地吵醒。", "Certainly, and usually wake up the camp in the process.") },
        { L("和自己讨论问题，效率高得有点吓人。", "Discussing things with myself is alarmingly efficient."),
          L("也可能只是因为我们都太爱说了。", "Or because both of us enjoy talking too much.") },

    },
    wendy_wendy = {
        { L("…你也在想阿比盖尔吗…", "...Are you thinking of Abigail too..."),
          L("…嗯…她无处不在…", "...Yes... she's everywhere...") },
        { L("两个孤独的灵魂…在一起反而不那么孤独了…", "Two lonely souls... together, less lonely..."),
          L("…也许吧…", "...Maybe...") },
        { L("你的阿比盖尔…和我的…是同一个吗…", "Your Abigail... and mine... are they the same..."),
          L("…也许每个温蒂…都有一个属于自己的阿比盖尔…", "...Maybe every Wendy... has her own Abigail...") },
        { L("…你也会在热闹的时候更觉得孤单吗…", "...Do you also feel lonelier when it's crowded..."),
          L("…会…像站在人群外面看自己…", "...Yes... like standing outside the crowd, watching myself...") },
        { L("…有时候我希望别人别看见我。", "...Sometimes I wish people wouldn't notice me."),
          L("…可真被忽略时…又会更难过…", "...But when they truly ignore me... it hurts even more...") },
        { L("…今晚的月光好淡。", "...The moonlight is faint tonight."),
          L("…像一封写到一半就停下的信…", "...Like a letter abandoned halfway through...") },
        { L("…如果阿比盖尔还在这里，她会说什么呢…", "...If Abigail were here, what would she say..."),
          L("…她会让我们别一直皱着眉头吧…", "...She'd probably tell us to stop frowning so much...") },
        { L("…其实有人能听懂沉默，也挺难得的…", "...It's rare to find someone who understands silence..."),
          L("…嗯…你刚好也不吵…", "...Mm... and you aren't loud either...") },
    },
    wathgrithr_wathgrithr = {
        { L("哈！另一个女武神！来比试！", "Ha! Another Valkyrie! Let's duel!"),
          L("来就来！谁怕谁！", "Bring it! Who's afraid!") },
        { L("两把圣剑，双倍荣耀！", "Two holy blades, double the glory!"),
          L("敌人看到两个女武神会吓哭的！", "Enemies will cry seeing two Valkyries!") },
        { L("我们一起高歌战歌吧！啊~~啊~~啊~~！", "Let us sing the war song together! Aaa~~aaa~~aaa~~!"),
          L("啊~~啊~~啊~~！（走调了但气势十足）", "Aaa~~aaa~~aaa~~! (off-key but full of spirit)") },
        { L("两个女武神同行，胜利女神都要为我们让路！", "With two Valkyries together, even victory itself must make way!"),
          L("说得好！今天的荣耀要翻倍！", "Well said! Today's glory shall be doubled!") },
        { L("你听！我的战靴踩地都像战鼓！", "Listen! Even my boots strike the earth like war drums!"),
          L("那就让我用战歌给它配上节奏！", "Then let me give them rhythm with a war song!") },
        { L("若敌人还不现身，便是畏惧我等威名！", "If the enemy still won't appear, then they fear our fame!"),
          L("哈！那他们倒也不算愚蠢！", "Ha! Then they are not entirely foolish!") },
        { L("今日若无大战，至少也该有一顿豪宴！", "If there is no great battle today, there should at least be a grand feast!"),
          L("同意！荣耀与肉食，一个都不能少！", "Agreed! Glory and meat, both are essential!") },
        { L("看着你，我像在照镜子。英勇又耀眼！", "Looking at you is like gazing into a mirror. Brave and radiant!"),
          L("而且嗓门同样响亮！", "And equally loud of voice!") },
    },
    wolfgang_wolfgang = {
        { L("你的肌肉有沃尔夫冈大吗？", "Are your muscles as big as Wolfgang's?"),
          L("沃尔夫冈的肌肉更大！", "Wolfgang's muscles are bigger!") },
        { L("两个沃尔夫冈！双倍力量！", "Two Wolfgangs! Double strength!"),
          L("没有人能打过两个沃尔夫冈！", "Nobody can beat two Wolfgangs!") },
        { L("沃尔夫冈，你也怕蜘蛛吗？", "Wolfgang, are you also afraid of spiders?"),
          L("沃…沃尔夫冈才不怕！…你先走前面。", "W-Wolfgang not afraid!... You go first.") },
        { L("两个沃尔夫冈，能不能举起整个营地？", "Can two Wolfgangs lift the whole camp?"),
          L("当然可以！但先吃饭再举！", "Of course! But eat first, then lift!") },
        { L("你今天吃了多少？", "How much did you eat today?"),
          L("很多！但还能再吃很多！", "A lot! But can still eat much more!") },
        { L("你也不喜欢黑夜吗？", "You also don't like the dark?"),
          L("不喜欢！但如果有另一个沃尔夫冈，就没那么怕！", "Don't like! But if another Wolfgang is here, less scary!") },
        { L("我们是不是最强组合？", "Are we the strongest team?"),
          L("当然！最强加最强就是最最强！", "Of course! Strongest plus strongest is strongest-est!") },
        { L("要不要比赛谁先把石头打碎？", "Want to race and see who breaks the rock first?"),
          L("好！输的人请吃的！", "Yes! Loser buys food!") },
    },
    
    -- Wormwood + Wormwood: 植物人 同角色对话
    wormwood_wormwood = {
        { L("你也是植物人？", "You also Wormwood?"),
          L("嗯。一样的。", "Mm. Same same.") },
        { L("两棵树在一起。不孤单。", "Two trees together. Not lonely."),
          L("嗯。根可以碰到。", "Mm. Roots can touch.") },
        { L("你闻起来像泥土。好闻。", "You smell like soil. Nice smell."),
          L("你也是。像下过雨。", "You too. Like after rain.") },
        { L("一起种东西？", "Plant things together?"),
          L("好。种很多很多。", "Okay. Plant lots and lots.") },
        { L("叶子多了，风就不冷了。", "With more leaves, wind not cold."),
          L("嗯。在一起暖暖的。", "Mm. Together feels warm.") },
    },

    -- Wormwood 主动 → 四角色回应
    wormwood_wilson = {
        { L("你知道很多。像老树。", "You know many things. Like old tree."),
        L("我从没想过“像树”会成为一种学术赞美，但我接受。", "I never expected 'tree-like' to become an academic compliment, but I'll take it.") },

        { L("你总看来看去。在找种子吗？", "You look around a lot. Looking for seeds?"),
        L("某种意义上说，是的。知识的种子。", "In a sense, yes. Seeds of knowledge.") },

        { L("你脑袋里会开花吗？", "Do flowers bloom in your head?"),
        L("偶尔。更多时候是理论，少数时候是爆炸。", "Occasionally. More often theories, and less often explosions.") },

        { L("你说话长长的。像藤。", "You talk long. Like vine."),
        L("这真是个令人意外又相当准确的评价。", "That is an unexpected and surprisingly accurate assessment.") },

        { L("别烧植物。植物会难过。", "Don't burn plants. Plants get sad."),
        L("我会尽量把火焰控制在最低必要范围内。", "I'll try to keep flames to the absolute minimum required.") },

        { L("泥土今天高兴。你知道为什么吗？", "Soil is happy today. Do you know why?"),
        L("如果让我猜，可能和湿度、温度以及微生物活性有关。", "If I had to guess, humidity, temperature, and microbial activity are involved.") },

        { L("你会不会给种子取名字？", "Do you give names to seeds?"),
        L("我通常会编号，但现在觉得名字似乎更亲切。", "I usually assign numbers, but names do sound more personable.") },

        { L("你摸花的时候，要轻一点。", "Be gentle when touching flowers."),
        L("放心，我的观察方式一般比采样文明。", "Don't worry. My observations are usually more civilized than my sampling.") },

        { L("你闻起来像纸、火、还有想法。", "You smell like paper, fire, and ideas."),
        L("这是我听过最有洞察力的气味分析。", "That is the most insightful scent analysis I've ever received.") },

        { L("你会和树说话吗？", "Do you talk to trees?"),
        L("在严格意义上不算“说话”，但我确实会自言自语给它们听。", "Not in the strict sense, but I do occasionally mutter at them.") },

        { L("种子睡觉的时候，你也会看着它们吗？", "Do you watch seeds while they sleep?"),
        L("如果条件允许，我甚至愿意做整晚记录。", "If conditions allow, I'd happily keep notes all night.") },

        { L("你喜欢叶子，还是喜欢数字？", "Do you like leaves, or numbers?"),
        L("这是个残忍的问题。我想我会选……有规律的叶脉。", "That's a cruel question. I'd choose... leaves with excellent vein patterns.") },

        { L("你总想知道为什么。累吗？", "You always want to know why. Is that tiring?"),
        L("有时候，但不知道答案会更让我难受。", "Sometimes, but not knowing is far more exhausting.") },

        { L("植物人觉得你会把太阳装进瓶子。", "Wormwood thinks you would put sun in a bottle."),
        L("我承认，这件事听起来确实像我会尝试的项目。", "I admit, that does sound suspiciously like one of my projects.") },

        { L("如果花不长了，你会修好吗？", "If a flower stops growing, would you fix it?"),
        L("我会尽我所能理解它，然后帮它恢复。", "I'd do my best to understand it, then help it recover.") },

        { L("你看见虫虫，会先研究还是先躲开？", "When you see bugs, do you study first or dodge first?"),
        L("理想情况下研究，现实情况下两者同时进行。", "Ideally I study first. Realistically, I do both at once.") },

        { L("你像会发明浇水机器的人。", "You seem like someone who would invent a watering machine."),
        L("……你知道吗，这已经进入我的待办清单了。", "...You know, that has now entered my to-do list.") },

        { L("不要把泥土挖太乱。泥土会晕。", "Don't dig soil too roughly. Soil gets dizzy."),
        L("我会尽量保持礼貌的挖掘方式。", "I'll attempt a more courteous style of digging.") },

        { L("植物人喜欢你。你会认真听。", "Wormwood likes you. You listen carefully."),
        L("谢谢。你说的话里有很多值得认真听的部分。", "Thank you. There's quite a lot in what you say worth hearing carefully.") },

        { L("如果你变成树，会长胡子叶吗？", "If you became a tree, would you grow beard leaves?"),
        L("这可能是我一生中最难回答的问题之一。", "That may be one of the most difficult questions I've ever faced.") },
    },

    wormwood_wendy = {
        { L("你像阴天花。安静。", "You are like cloudy-day flower. Quiet."),
        L("…这比很多安慰都更像安慰…", "...That sounds more comforting than most comforts...") },

        { L("你难过吗？像叶子垂下来。", "You sad? Like droopy leaf."),
        L("…嗯…大概是一种很久都没抬起来的垂落…", "...Mm... more like something that hasn't lifted in a very long time...") },

        { L("给你花。花会陪。", "Give you flower. Flower stays."),
        L("…谢谢…有时候沉默的陪伴比话语久一点…", "...Thank you... sometimes silent company lasts longer than words...") },

        { L("你说话像风吹远远的草。", "You speak like wind through distant grass."),
        L("…那至少，风路过时还会记得我…", "...Then at least the wind remembers to pass by me...") },

        { L("不要总枯着。晒晒太阳。", "Don't stay wilted. Have some sun."),
        L("…要是阳光也肯照到心里就好了…", "...If only sunlight knew how to reach the heart...") },

        { L("你看月亮的时候，很像小花等雨。", "When you look at the moon, like little flower waiting for rain."),
        L("…它总在那儿…远得像所有没法回去的事…", "...It's always there... distant like everything I can't return to...") },

        { L("你走路轻轻的。像怕踩疼影子。", "You walk softly. Like afraid to hurt shadows."),
        L("…影子已经够疼了…我不想再惊动它们…", "...Shadows have suffered enough... I don't want to disturb them further...") },

        { L("你喜欢花吗？花喜欢你。", "Do you like flowers? Flowers like you."),
        L("…它们大概只是比人更善于沉默…", "...Perhaps they're simply better at silence than people are...") },

        { L("植物人听见你心里有风。", "Wormwood hears wind inside you."),
        L("…是啊…有些风从来不停…", "...Yes... some winds never stop...") },

        { L("下雨的时候，你会不会好一点？", "When it rains, do you feel better?"),
        L("…会一点…雨像替人把话说完了…", "...A little... rain feels like it finishes what people leave unsaid...") },

        { L("你看花的时候，不像别人。", "You look at flowers different from others."),
        L("…因为我知道，美丽有时候只是另一种告别…", "...Because I know beauty is sometimes just another form of farewell...") },

        { L("植物人可以陪你坐着。不说话。", "Wormwood can sit with you. No talking."),
        L("…嗯…你很懂得怎样不让安静变得难受…", "...Mm... you know how to keep quiet from becoming painful...") },

        { L("如果你掉叶子，植物人会帮你捡。", "If you drop leaves, Wormwood will help pick them up."),
        L("…谢谢…那听起来像一种不会迟到的温柔…", "...Thank you... that sounds like a kindness that wouldn't arrive too late...") },

        { L("你闻起来像夜里湿湿的花。", "You smell like wet flowers at night."),
        L("…那是种快要被黑暗记住的气味吧…", "...Then it's the scent of something the dark is about to remember...") },

        { L("你会不会想埋进泥土里睡？", "Do you want to sleep in the soil sometimes?"),
        L("…偶尔…至少泥土不会追问我为什么难过…", "...Sometimes... at least the soil wouldn't ask why I'm sad...") },

        { L("树今天很安静。你也是。", "Trees are quiet today. You too."),
        L("…也许安静会认得安静…", "...Perhaps quiet recognizes quiet...") },

        { L("植物人觉得你像月光下没关上的窗。", "Wormwood thinks you are like a window left open in moonlight."),
        L("…那风一定带走了很多我没留住的东西…", "...Then the wind must have carried off many things I couldn't keep...") },

        { L("你别总一个人枯。", "Don't wilt alone."),
        L("…好…这句话我会轻轻记住的…", "...All right... I'll remember that softly...") },

        { L("花谢了也不是坏。它们睡觉。", "Flowers fading not always bad. They sleep."),
        L("…如果所有离开都只是睡去，那该多好…", "...If every leaving were only sleep, that would be kinder...") },

        { L("植物人喜欢你。你像夜里会发光的叶子。", "Wormwood likes you. You are like leaf that glows at night."),
        L("…真奇怪…被这样形容，竟让我没那么冷了…", "...How strange... being described that way makes me feel less cold...") },
    },

    wormwood_wathgrithr = {
        { L("你声音大。像雷。", "You loud. Like thunder."),
        L("哈哈！那你便是雷后破土的新芽！", "Ha! Then you are the sprout that rises after thunder!") },

        { L("你总想打东西。为什么？", "You always want hit things. Why?"),
        L("因为战斗乃勇者通向荣耀的路！", "Because battle is the road by which the brave earn glory!") },

        { L("植物人不喜欢火。", "Wormwood no like fire."),
        L("放心，小苗儿！烈焰只该吞噬敌人，不该伤你分毫！", "Fear not, little sprout! Flame shall consume only foes, not a hair on your head!") },

        { L("你像会走路的大树。很吵的大树。", "You like walking tree. Very loud tree."),
        L("哈！此乃对强者最响亮的赞歌！", "Ha! That is a resounding praise for the mighty!") },

        { L("别踩花。花没惹你。", "Don't step on flowers. Flowers did nothing."),
        L("好！女武神自会敬重无辜之花！", "Very well! A Valkyrie shall honor innocent blossoms!") },

        { L("你唱歌的时候，小虫都停下来。", "When you sing, bugs stop moving."),
        L("它们是在聆听战歌，感受英魂之震颤！", "They halt to hear my battle-song and tremble before heroism!") },

        { L("你拿着长矛，像很尖的树枝。", "Your spear like very pointy branch."),
        L("那便是诸神赐予我之圣枝，专刺邪祟！", "Then let it be the sacred branch the gods bestowed upon me to pierce evil!") },

        { L("你会不会和树比赛谁站得直？", "Do you race trees for who stands straighter?"),
        L("若树有荣誉之心，我愿与之一较高下！", "If trees possess honor, I would gladly contest them!") },

        { L("你太吵。花都吓醒了。", "You too loud. Flowers woke up."),
        L("那就让它们醒来见证我的威名！", "Then let them awaken and witness my greatness!") },

        { L("植物人觉得你会把土踩得很实。", "Wormwood thinks you step soil very hard."),
        L("战士之足当踏实大地，也踏碎怯懦！", "A warrior's foot must strike the earth firm, and crush cowardice besides!") },

        { L("如果怪物来了，你会保护小花吗？", "If monsters come, will you protect little flowers?"),
        L("我以长矛起誓，必护它们周全！", "By my spear, I swear to protect them!") },

        { L("雨来的时候，你还会大声吗？", "When rain comes, are you still loud?"),
        L("当然！风雨只会让我的高歌更加壮阔！", "Of course! Wind and rain only make my song more magnificent!") },

        { L("你像会把石头也叫醒。", "You seem like wake even rocks."),
        L("若岩石沉睡，我便以豪声唤其为我作证！", "If rocks sleep, I shall wake them with my mighty voice to bear witness!") },

        { L("植物人给你花。不要吃。", "Wormwood gives you flower. Don't eat."),
        L("哈哈！我更愿将其佩于盔侧，作为荣耀之饰！", "Ha! I would sooner wear it by my helm as an ornament of glory!") },

        { L("你会不会和风打架？", "Do you fight wind?"),
        L("若风阻我去路，我便迎风高歌而行！", "If wind opposes me, I stride into it with a song!") },

        { L("你像很热的太阳。会晒蔫小草。", "You like very hot sun. Might wilt grass."),
        L("那我便收敛锋芒，免得灼伤弱小新芽！", "Then I shall temper my blaze, lest it scorch tender shoots!") },

        { L("植物人不知道荣耀是什么。能种吗？", "Wormwood not know glory. Can plant it?"),
        L("可种！以勇气为种，以鲜血为雨，终将收获传奇！", "It can be planted! Courage is the seed, blood the rain, and legend the harvest!") },

        { L("你笑的时候，像树被风推来推去。", "When you laugh, like tree pushed by wind."),
        L("好极了！那我的笑便是震林之风！", "Excellent! Then my laughter is the wind that stirs the woods!") },

        { L("不要把植物人当小草踩。", "Don't step on Wormwood like little grass."),
        L("绝无可能！你乃绿意中的勇士，值得尊敬！", "Never! You are a warrior of green life, worthy of respect!") },

        { L("植物人喜欢你。你很亮。", "Wormwood likes you. You very bright."),
        L("而你，小苗儿，你让我的战心也见到春天！", "And you, little sprout, bring spring even to my battle-heart!") },
    },

    wormwood_wolfgang = {
        { L("你很大。像会走路的南瓜。", "You big. Like walking pumpkin."),
        L("哈哈！沃尔夫冈喜欢！大南瓜很强！", "Ha ha! Wolfgang likes that! Big pumpkin is strong!") },

        { L("你饿了吗？你总像饿。", "You hungry? You always seem hungry."),
        L("对！沃尔夫冈经常饿！", "Yes! Wolfgang is often hungry!") },

        { L("不要吃种子。种子是宝宝。", "Don't eat seeds. Seeds are babies."),
        L("呃…沃尔夫冈会努力少吃一点。", "Uh... Wolfgang will try to eat fewer.") },

        { L("你力气大。可以帮植物人挖坑。", "You strong. Can help dig holes."),
        L("这个沃尔夫冈会！挖坑很简单！", "That Wolfgang can do! Digging holes is easy!") },

        { L("你怕黑。植物人懂。夜里叶子也缩起来。", "You scared of dark. Wormwood understands. Leaves curl at night too."),
        L("真的？那沃尔夫冈和叶子一样！", "Really? Then Wolfgang is like leaves too!") },

        { L("你笑起来像熟透的大果子。", "Your smile like ripe big fruit."),
        L("这听起来很好！熟果子通常都好吃！", "That sounds good! Ripe fruit is usually tasty!") },

        { L("你不要踩小苗。小苗很小。", "Don't step on sprouts. Sprouts very small."),
        L("沃尔夫冈会很小心！沃尔夫冈脚大，但不是坏人！", "Wolfgang will be careful! Wolfgang has big feet, but is not mean!") },

        { L("如果你睡在泥土上，会长蘑菇吗？", "If you sleep on soil, do mushrooms grow?"),
        L("沃尔夫冈不知道！但听起来有点痒！", "Wolfgang doesn't know! But it sounds itchy!") },

        { L("你像大树桩。暖暖的。", "You like big tree stump. Warm."),
        L("沃尔夫冈喜欢这个比喻！树桩很结实！", "Wolfgang likes that comparison! Tree stumps are sturdy!") },

        { L("你吃很多。会不会把春天吃掉？", "You eat so much. Will you eat all spring?"),
        L("不会！沃尔夫冈会给春天留一点点！", "No! Wolfgang would leave a little bit for spring!") },

        { L("你能帮花挡风。你很适合。", "You can block wind for flowers. You good for that."),
        L("对！沃尔夫冈很大，可以挡很多风！", "Yes! Wolfgang is big and can block lots of wind!") },

        { L("植物人给你果子。不要连枝一起咬。", "Wormwood gives you fruit. Don't bite branch too."),
        L("沃尔夫冈会小心！大概会小心。", "Wolfgang will be careful! Probably careful.") },

        { L("你跑起来，泥土会咚咚响。", "When you run, soil goes boom boom."),
        L("因为沃尔夫冈很有力量！", "Because Wolfgang is very strong!") },

        { L("你会和树拔河吗？", "Do you tug-of-war with trees?"),
        L("沃尔夫冈没试过，但听起来很厉害！", "Wolfgang hasn't tried, but it sounds impressive!") },

        { L("不要拔花给自己加油。花会难过。", "Don't pull flowers to cheer yourself. Flowers get sad."),
        L("那沃尔夫冈就用喊的给自己加油！", "Then Wolfgang will cheer himself with shouting instead!") },

        { L("你抱起来会不会像抱一袋土？", "Would hugging you feel like hugging a sack of soil?"),
        L("沃尔夫冈觉得自己更像一大袋肌肉！", "Wolfgang thinks he is more like a big sack of muscles!") },

        { L("你喜欢太阳。植物人也喜欢。", "You like sun. Wormwood like sun too."),
        L("那我们就是晒太阳朋友！", "Then we are sunshine friends!") },

        { L("如果你种下一个你，会长出几个你？", "If one of you got planted, how many you grow?"),
        L("哇，这个问题让沃尔夫冈头有点晕！", "Wow, that question makes Wolfgang's head feel funny!") },

        { L("你很吵，但不坏。像大雨。", "You loud, but not bad. Like big rain."),
        L("沃尔夫冈接受这个！大雨很厉害！", "Wolfgang accepts that! Big rain is mighty!") },

        { L("植物人喜欢你。你像大大的会走路的菜园守卫。", "Wormwood likes you. You like big walking garden guard."),
        L("哈哈！沃尔夫冈会保护菜园！还有植物人！", "Ha ha! Wolfgang will protect garden! And Wormwood too!") },
    },

    -- 四角色主动 → Wormwood 回应
    wilson_wormwood = {
        { L("你似乎对土壤状态非常敏感，这很了不起。", "You seem remarkably sensitive to soil conditions. That's impressive."),
        L("泥土会说话。植物人听得见。", "Soil talks. Wormwood hears it.") },

        { L("我很好奇，你是怎么判断一颗种子是否开心的？", "I'm curious, how do you determine whether a seed is happy?"),
        L("会动一点点。会想长。", "Moves a little. Wants to grow.") },

        { L("你让我重新思考了“生命”的定义。", "You've made me reconsider my definition of life."),
        L("生命就是长呀。还有陪。", "Life is growing. And company.") },

        { L("如果我做一台自动浇水装置，你会喜欢吗？", "If I built an automatic watering device, would you like it?"),
        L("只要不咬植物，就喜欢。", "If it doesn't bite plants, like it.") },

        { L("我注意到你比大多数人更关心花草的感受。", "I've noticed you care more about flora's feelings than most people do."),
        L("花草也会疼。只是说得小声。", "Flowers hurt too. They just speak softly.") },

        { L("你会不会觉得我问题太多了？", "Do you ever feel I ask too many questions?"),
        L("不会。问题像种子。会长。", "No. Questions are like seeds. They grow.") },

        { L("从观察角度讲，你的思维方式非常独特。", "From an observational standpoint, your thinking is quite unique."),
        L("植物人就是植物人。不是别人。", "Wormwood is Wormwood. Not others.") },

        { L("你真让我想给植物学再写一本新教材。", "You make me want to rewrite botany from the ground up."),
        L("可以。记得把花画漂亮。", "Can do. Make flowers pretty.") },

        { L("你怎么看待修剪枝叶这种行为？", "What is your perspective on pruning?"),
        L("轻一点，讲道理，就还好。", "Gentle. Explain why. Then okay.") },

        { L("你似乎总能在最细微的地方发现变化。", "You seem to notice the smallest changes."),
        L("小变化也会长成大变化。", "Little changes grow into big ones.") },

        { L("我有时真希望自己也能像你一样理解植物。", "Sometimes I wish I could understand plants the way you do."),
        L("先安静。植物就会慢慢说。", "Be quiet first. Plants talk slowly.") },

        { L("你让我意识到，观察不一定非得靠仪器。", "You've made me realize observation doesn't always require instruments."),
        L("眼睛可以。手也可以。心也可以。", "Eyes work. Hands too. Heart too.") },

        { L("你会对实验室感兴趣吗？", "Would you be interested in a laboratory?"),
        L("有泥土吗？有太阳吗？", "Does it have soil? Does it have sun?") },

        { L("假如我把一盆植物照顾得很好，你会夸我吗？", "If I took excellent care of a potted plant, would you praise me?"),
        L("会。会说你是好园丁。", "Yes. Say you are good gardener.") },

        { L("我得承认，你的价值观比很多人都更清晰。", "I have to admit, your values are clearer than many people's."),
        L("不让朋友枯。很简单。", "Don't let friends wilt. Simple.") },

        { L("你对火的警惕很合理。", "Your caution around fire is quite reasonable."),
        L("火饿饿的。会吃朋友。", "Fire hungry. Eats friends.") },

        { L("你会把我归类成哪一种植物？", "What kind of plant would you classify me as?"),
        L("像会写字的高高向日葵。还有胡子。", "Like tall sunflower that writes. With beard.") },

        { L("与你聊天总让我觉得逻辑变得更柔软了。", "Talking with you makes logic feel softer somehow."),
        L("软软的土比较好长东西。", "Soft soil better for growing things.") },

        { L("你似乎很擅长分辨“活着”和“只是存在”的区别。", "You seem very good at distinguishing living from merely existing."),
        L("会想长，就是活着。", "If it wants to grow, it lives.") },

        { L("谢谢你，和你聊天总能让我想起该温柔一点。", "Thank you. Talking to you reminds me to be gentler."),
        L("温柔好。温柔会让叶子打开。", "Gentle good. Gentle makes leaves open.") },
    },

    wendy_wormwood = {
        { L("你看花的时候，好像真的能听见它们。", "When you look at flowers, it feels as though you truly hear them."),
        L("听得见。它们说话很慢。", "Hear them. They speak slow.") },

        { L("你总把“活着”说得很简单。真羡慕。", "You always make living sound simple. I envy that."),
        L("活着就是长。难过也会长。", "Living is growing. Sadness grows too.") },

        { L("你会不会觉得人类太吵了？", "Do you ever think humans are too loud?"),
        L("有一点。但你轻轻的。", "A little. But you are soft.") },

        { L("有时候我觉得自己像一朵太晚开的花。", "Sometimes I feel like a flower that bloomed too late."),
        L("晚开也会开。还是花。", "Blooming late still blooming. Still flower.") },

        { L("你似乎不怕安静。", "You don't seem afraid of silence."),
        L("安静里有很多声音。", "Quiet has lots of sounds.") },

        { L("如果悲伤像枯萎，那它也会结束吗？", "If sorrow is like withering, does it also end?"),
        L("会。会睡。然后别的东西再长。", "Yes. It sleeps. Then other things grow.") },

        { L("你喜欢月亮吗？", "Do you like the moon?"),
        L("喜欢。像白白的果子。远远的。", "Yes. Like pale fruit. Far away.") },

        { L("你从不问别人为什么难过。", "You never ask why people are sad."),
        L("难过的时候，先陪。再慢慢长。", "When sad, first stay. Then grow slowly.") },

        { L("如果我把一朵花埋起来，它会记得阳光吗？", "If I buried a flower, would it remember sunlight?"),
        L("会一点点。泥土也会抱它。", "A little. Soil hugs it too.") },

        { L("你说话很短，却好像总留着回音。", "You speak so briefly, yet your words seem to echo."),
        L("可能是风在帮忙。", "Maybe wind helps.") },

        { L("看着你，我会觉得世界还没完全变坏。", "Looking at you makes me feel the world hasn't gone entirely wrong."),
        L("世界有坏，也有花。", "World has bad. Also flowers.") },

        { L("你会不会也想念谁？", "Do you miss someone too?"),
        L("会。想念太阳，想念下过的雨。", "Yes. Miss sun. Miss rain that already fell.") },

        { L("你总愿意把花送给别人。", "You always seem willing to give flowers away."),
        L("花喜欢去看别人。", "Flowers like to visit others.") },

        { L("你让我觉得，枯萎也许不是最坏的结局。", "You make me think withering may not be the worst ending."),
        L("不是结局。是变成泥土前面的一点点。", "Not ending. Just a little part before becoming soil.") },

        { L("有时我想像你一样，把心事埋进土里。", "Sometimes I want to bury my thoughts in the soil, the way you would."),
        L("可以。土很会保管。", "Can. Soil good at keeping things.") },

        { L("你不害怕靠近悲伤。", "You're not afraid to come near sorrow."),
        L("像蔫掉的叶子。靠近才知道怎么帮。", "Like droopy leaf. Need get close to help.") },

        { L("你真像一封不会伤人的回信。", "You're like a reply that could never hurt anyone."),
        L("植物人只是想让朋友好一点。", "Wormwood just wants friends a little better.") },

        { L("若我安静太久，你会陪着我吗？", "If I stay quiet too long, would you sit with me?"),
        L("会。坐着。给你花。", "Yes. Sit. Give you flower.") },

        { L("你对离开这件事，好像比我温柔。", "You seem gentler with leaving than I am."),
        L("掉叶子会难过。但树还会记得。", "Losing leaves sad. But tree still remembers.") },

        { L("谢谢你。你总让我觉得夜色没那么冷。", "Thank you. You always make the night feel less cold."),
        L("那就好。植物人可以再靠近一点。", "Good. Wormwood can sit a little closer.") },
    },

    wathgrithr_wormwood = {
        { L("小苗勇士！你立于大地之上，自有不屈之魂！", "Little sprout-warrior! You stand upon the earth with an unyielding spirit!"),
        L("植物人站着。因为根喜欢。", "Wormwood stands. Roots like that.") },

        { L("告诉我，绿之子！你如何与泥土结盟？", "Tell me, child of green! How do you make alliance with soil?"),
        L("摸摸它。等等它。不要凶。", "Touch it. Wait for it. Don't be mean.") },

        { L("你虽柔嫩，却有生命最顽强的意志！", "Though tender, you bear life's fiercest will!"),
        L("小芽也会顶开石头。", "Little sprout can push stone too.") },

        { L("若有敌人敢伤你，我必叫其饮恨长矛之下！", "Should any foe dare harm you, my spear shall make them regret it!"),
        L("谢谢。也要保护小花。", "Thank you. Protect flowers too.") },

        { L("你的沉默，比许多战士的咆哮更有力量。", "Your silence holds more strength than many warriors' roars."),
        L("可能因为植物人不乱响。", "Maybe because Wormwood not make noise too much.") },

        { L("我愿称你为春之先锋！", "I would name you the Vanguard of Spring!"),
        L("名字好长。会把小叶子绊倒。", "Name too long. Might trip little leaves.") },

        { L("你可知，连荒原也会因你而显出生机？", "Know you that even wasteland seems alive in your presence?"),
        L("有一点土，就能试试看。", "If there is a little soil, can try.") },

        { L("你的眼中并无惧色，唯有自然之真。", "In your eyes I see no fear, only nature's truth."),
        L("会怕火。别的还好。", "Scared of fire. Other things okay.") },

        { L("你若持矛，亦可成林中传说！", "Were you to wield a spear, you could become legend of the woods!"),
        L("植物人更会拿种子。", "Wormwood better at holding seeds.") },

        { L("哈！你这小家伙，竟比许多成人更懂何为守护！", "Ha! Little one, you understand guardianship better than many grown folk!"),
        L("守护就是不让朋友坏掉。", "Guarding means don't let friends get ruined.") },

        { L("我见过钢铁之勇，却少见你这般温柔之勇。", "I have seen courage of steel, but rarely courage so gentle as yours."),
        L("温柔也会很用力。", "Gentle can be strong too.") },

        { L("若风暴降临，你可会退缩？", "If storm descends, would you retreat?"),
        L("会低一点。不会跑远。", "Bend a little. Not run far.") },

        { L("你这绿意中的小战士，可曾歌颂过雨水？", "Little warrior of green, have you ever sung praise to rain?"),
        L("会呀。下雨的时候心里唱。", "Yes. Sing inside when rain comes.") },

        { L("你让我想起命运最初的萌芽！", "You remind me of destiny's earliest sprouting!"),
        L("萌芽小小的。可是会变大。", "Sprout tiny. But gets big.") },

        { L("我若高歌，会不会惊扰你的花友？", "Would my song startle your flower-friends?"),
        L("会一点点。但它们会习惯你。", "A little. But they will get used to you.") },

        { L("你不以强横示人，却仍令人敬重。", "You show no harsh might, yet earn respect all the same."),
        L("因为植物人不踩别人。", "Because Wormwood doesn't step on others.") },

        { L("你可愿将一朵花赐予我，作今日之荣冠？", "Would you grant me a flower as today's crown of honor?"),
        L("可以。戴轻一点。不要弄疼花。", "Yes. Wear gentle. Don't hurt flower.") },

        { L("哈哈！你的真诚，比酒更叫人畅快！", "Ha ha! Your sincerity heartens more than ale!"),
        L("植物人不懂酒。懂果汁。", "Wormwood not know ale. Knows juice.") },

        { L("我愿为你斩开荆棘之路！", "I would cut a path through thorns for you!"),
        L("谢谢。也留一点给小鸟住。", "Thank you. Leave some for birds too.") },

        { L("绿之子，你让我的豪情也学会了怜爱。", "Child of green, you have taught even my valor to be tender."),
        L("怜爱好。怜爱会让东西长。", "Tender good. Tender helps things grow.") },
    },

    wolfgang_wormwood = {
        { L("小植物朋友，你今天长高了吗？", "Little plant friend, did you grow taller today?"),
        L("一点点。够高兴。", "A little. Enough to be happy.") },

        { L("沃尔夫冈觉得你很可爱，也很奇怪。", "Wolfgang thinks you are cute and strange."),
        L("植物人也是这样觉得你的。", "Wormwood thinks that about you too.") },

        { L("你真的听得懂花说话吗？", "Can you really understand flowers?"),
        L("嗯。它们说得小小声。", "Mm. They speak in tiny voice.") },

        { L("沃尔夫冈如果吃太多蔬菜，你会难过吗？", "If Wolfgang eats too many vegetables, will you be sad?"),
        L("吃一点可以。不要把菜园吃空。", "A little okay. Don't empty whole garden.") },

        { L("你晚上会怕黑吗？", "Are you scared of dark at night?"),
        L("有一点。叶子会缩起来。", "A little. Leaves curl up.") },

        { L("沃尔夫冈可以帮你挡风！", "Wolfgang can block wind for you!"),
        L("好。你像大大暖暖的树桩。", "Good. You like big warm tree stump.") },

        { L("你身上会不会长小果子？", "Do little fruits grow on you?"),
        L("现在没有。以后也许有惊喜。", "Not now. Maybe surprise later.") },

        { L("沃尔夫冈不太懂种东西，但愿意帮忙！", "Wolfgang does not understand planting much, but wants to help!"),
        L("挖坑、浇水、别踩苗，就很好。", "Dig hole, water, don't step on sprouts. Very good.") },

        { L("你看起来比菜还像菜，但沃尔夫冈不会吃你。", "You look more like food than vegetables, but Wolfgang won't eat you."),
        L("谢谢。植物人比较想当朋友，不当晚饭。", "Thank you. Wormwood rather be friend than dinner.") },

        { L("沃尔夫冈觉得跟你在一起很安心。", "Wolfgang feels safe around you."),
        L("因为植物人不会突然咬人。", "Because Wormwood doesn't suddenly bite.") },

        { L("如果沃尔夫冈把种子种反了，会怎样？", "What if Wolfgang plants seed upside down?"),
        L("它会努力转回来。种子很聪明。", "It tries hard to turn back. Seeds smart.") },

        { L("你会不会冬天冻坏？", "Do you get hurt by winter?"),
        L("会缩一点。春天再打开。", "Shrink a little. Open again in spring.") },

        { L("沃尔夫冈想做你的朋友，不做压坏花的笨蛋。", "Wolfgang wants be your friend, not flower-crushing fool."),
        L("那就慢慢走。朋友就成了。", "Then walk slowly. Friendship done.") },

        { L("你喜欢大雨还是大太阳？", "Do you like big rain or big sun more?"),
        L("两个都喜欢。一起更好。", "Like both. Better together.") },

        { L("沃尔夫冈觉得你闻起来像新鲜地面。", "Wolfgang thinks you smell like fresh ground."),
        L("好闻。说明今天长得不错。", "Good smell. Means growing well today.") },

        { L("如果有人欺负你，沃尔夫冈就揍他！", "If someone bullies you, Wolfgang punches them!"),
        L("好。先警告。再揍。", "Good. Warn first. Then punch.") },

        { L("你会不会肚子饿得想吃泥土？", "Do you get so hungry you want eat dirt?"),
        L("泥土是朋友。不是饭。", "Soil is friend. Not food.") },

        { L("沃尔夫冈说话不聪明，但心是好的。", "Wolfgang not talk smart, but heart is good."),
        L("植物人知道。好心会长出来。", "Wormwood knows. Good hearts grow.") },

        { L("你要是难过，可以来找沃尔夫冈。沃尔夫冈很大。", "If you are sad, come find Wolfgang. Wolfgang is big."),
        L("好。大大的朋友很好靠。", "Good. Big friend good to lean on.") },

        { L("嘿，小植物朋友，沃尔夫冈会保护你的菜园！", "Hey, little plant friend, Wolfgang will protect your garden!"),
        L("谢谢。植物人也会给你最甜的果子。", "Thank you. Wormwood gives you sweetest fruit.") },
    },
	warly_wormwood = {
		{ L("这些作物长得真漂亮，是你照看的吧？", "These crops are growing beautifully. You tended them, didn't you?"),
		  L("嗯。植物人有摸摸它们。", "Mm. Wormwood touched them.") },

		{ L("你总能把土地照顾得这么有生气，真令人佩服。", "You always keep the soil so lively. It's admirable."),
		  L("泥土高兴，东西就会长。", "Soil happy, things grow.") },

		{ L("新鲜的蔬菜，配上合适的火候，才不算辜负你的辛苦。", "Fresh vegetables deserve proper heat, or your effort goes to waste."),
		  L("大厨让它们变好吃。植物人喜欢。", "Chef makes them tasty. Wormwood likes that.") },

		{ L("这些番茄真不错，颜色饱满，水分也好。", "These tomatoes are excellent. Rich color, fine moisture too."),
		  L("它们晒了好多太阳。", "They had lots of sun.") },

		{ L("你负责让它们生长，我负责让它们发光，如何？", "You make them grow, I make them shine. Does that sound fair?"),
		  L("好。一个长，一个香。", "Good. One grows, one smells nice.") },

		{ L("别担心，我会好好用这些食材，不会浪费。", "Don't worry. I'll use these ingredients properly. Nothing will be wasted."),
		  L("那就好。小菜们会高兴。", "Good. Little vegetables will be happy.") },

		{ L("有时候我觉得，你比任何园丁都更懂植物。", "Sometimes I think you understand plants better than any gardener."),
		  L("植物会说。别人没听见。", "Plants talk. Others don't hear.") },

		{ L("这份收成很适合做一锅暖胃的炖菜。", "This harvest would make a fine, warming stew."),
		  L("炖菜会让肚子高兴。", "Stew makes tummy happy.") },

		{ L("你照看的作物，总有一种被认真爱护过的感觉。", "The crops you tend always feel deeply cared for."),
		  L("植物人喜欢它们。它们也喜欢植物人。", "Wormwood likes them. They like Wormwood too.") },

		{ L("我整理冰箱时，总会想到你种它们时有多用心。", "When I organize the icebox, I often think of how carefully you grew all this."),
		  L("放好很好。坏掉就不好。", "Putting things nicely is good. Rotting is not.") },

		{ L("这些根茎类得单独放，别让香味串了。", "These roots should be stored separately. No need to muddle the aromas."),
		  L("大厨懂箱子和冰箱。", "Chef understands chests and iceboxes.") },

		{ L("你知道吗？食材被认真对待的时候，味道也会更好。", "You know, ingredients taste better when they're treated with care."),
		  L("像小种子被轻轻放进土里。", "Like little seeds put gently in soil.") },

		{ L("你负责耕种，我负责烹调，我们配合得真不错。", "You handle the farming, I handle the cooking. We make a fine pair."),
		  L("嗯。像雨和太阳。", "Mm. Like rain and sun.") },

		{ L("这块地今天状态不错，看来你又和泥土谈过了。", "The field looks excellent today. I suppose you've had another talk with the soil."),
		  L("有说一点点。泥土今天心情好。", "Talked a little. Soil in good mood today.") },

		{ L("我喜欢你带回来的东西，总是新鲜、干净、像刚从清晨里摘下来。", "I like what you bring back. Always fresh, clean, like it was picked out of dawn."),
		  L("因为植物人没有让它们等太久。", "Because Wormwood didn't make them wait too long.") },

		{ L("做饭和种地有点像，都是在等一个刚刚好的时机。", "Cooking and farming are alike in a way. Both depend on the right moment."),
		  L("太早不好，太晚也不好。", "Too early bad. Too late bad too.") },
	},
	wormwood_warly = {
		{ L("大厨，小菜们来啦。", "Chef, little vegetables are here."),
		  L("啊，漂亮极了。今天可以好好做一顿。", "Ah, beautiful. We can make something lovely today.") },

		{ L("这个给你。很新鲜。", "This for you. Very fresh."),
		  L("我看得出来，新鲜得几乎还带着清晨的气味。", "I can tell. It's so fresh it still smells of morning.") },

		{ L("不要让它们坏掉。", "Don't let them spoil."),
		  L("放心，我会安排得明明白白。", "Don't worry. I'll take proper care of everything.") },

		{ L("这个适合煮吗？", "This good for cooking?"),
		  L("适合，而且处理得当的话，会相当出色。", "It is, and handled properly, it can be quite excellent.") },

		{ L("植物人种。大厨煮。", "Wormwood grows. Chef cooks."),
		  L("是啊，我们分工得很优雅。", "Yes, it's quite an elegant arrangement.") },

		{ L("这个闻起来甜甜的。", "This smells sweet."),
		  L("很好，那就该搭一点更圆润的味道。", "Excellent. Then it deserves something rounder to match it.") },

		{ L("大厨总会把菜变好。", "Chef always makes food better."),
		  L("有好食材帮忙，我也只是尽力不拖后腿。", "With ingredients this good, I merely try not to let them down.") },

		{ L("冰箱今天也很整齐。", "Icebox neat today too."),
		  L("那当然。食材各归其位，心里也会舒服些。", "Naturally. Ingredients belong in order. It settles the mind.") },

		{ L("大厨是不是也会和锅说话？", "Does chef talk to pots too?"),
		  L("偶尔。尤其是在它们表现不佳的时候。", "Occasionally. Especially when they misbehave.") },

		{ L("火会不会把小菜吓到？", "Does fire scare little vegetables?"),
		  L("控制得当的火，不是伤害，是成全。", "Fire, properly controlled, does not harm. It completes.") },

		{ L("植物人喜欢看大厨闻闻这个、摸摸那个。", "Wormwood likes when chef smells this, touches that."),
		  L("那是因为下锅前，食材总得先被认真认识一下。", "Because before something enters the pot, it deserves to be properly understood.") },

		{ L("大厨知道哪个先放，哪个后放。很厉害。", "Chef knows what goes in first and what later. Very impressive."),
		  L("这叫顺序感。做饭和整理一样，都不能乱。", "That's a sense of order. Cooking, like organizing, should never be chaotic.") },

		{ L("如果植物人给你很多很多菜，你会开心吗？", "If Wormwood gives chef many many vegetables, will chef be happy?"),
		  L("我会忙得不可开交，但会很开心。", "I would be terribly busy, and very happy.") },

		{ L("这个菜今天长得特别快。", "This vegetable grew especially fast today."),
		  L("那我得趁它状态正好的时候立刻用掉。", "Then I should use it while it's at its peak.") },

		{ L("大厨做的东西，大家吃了会笑。", "When chef cooks, people smile."),
		  L("那就说明这顿饭没有白做。", "Then the meal has done its job.") },

		{ L("植物人喜欢大厨的锅。会变香香。", "Wormwood likes chef's pot. It makes things smell nice."),
		  L("香气是给食物的第一件漂亮衣裳。", "Aroma is the first beautiful garment food wears.") },

		{ L("大厨会不会也想种点什么？", "Does chef want to grow something too?"),
		  L("我更擅长等待成熟后的那一刻，不过偶尔也会想试试。", "I'm better with what happens after maturity, though I am tempted sometimes.") },

		{ L("这个放冰箱。那个放箱子。大厨知道。", "This goes icebox. That goes chest. Chef knows."),
		  L("当然。会坏的要快处理，会留的要分好类。", "Of course. Perishables first, reserves sorted properly.") },

		{ L("植物人觉得大厨像会照顾果子的火。", "Wormwood thinks chef is like fire that takes care of fruit."),
		  L("这可真是个让我受宠若惊的比喻。", "That's a comparison I find unexpectedly flattering.") },

		{ L("大厨在，田地和肚子都不会难过。", "When chef is here, fields and tummies won't be sad."),
		  L("那你继续照顾田地，我继续照顾餐桌。", "Then you keep watch over the fields, and I'll keep watch over the table.") },
	},
  warly_wilson = {
    { L("你看食材的眼神，和看实验材料时一样认真。", "You look at ingredients with the same intensity you reserve for laboratory samples."),
      L("本质上它们确实都值得仔细观察，只是后者通常更好吃。", "In essence, both deserve close observation. Though the former is usually more edible.") },

    { L("番茄不该随手乱放，它们会失了状态。", "Tomatoes shouldn't be tossed around carelessly. They lose their character."),
      L("明白，结构完整性会影响最终结果。某种程度上和实验样本一样。", "Understood. Structural integrity affects the final result. Much like proper specimens.") },

    { L("你总想知道为什么，我总在想怎么做得更好。", "You always want to know why. I am usually wondering how to make it better."),
      L("这听起来像一组相当高效的协作关系。", "That sounds like a remarkably efficient collaborative framework.") },

    { L("有些调味靠经验，不是每一步都能写成公式。", "Some seasoning depends on experience. Not every step can be reduced to formula."),
      L("令人沮丧的是，我完全同意这点。", "Annoyingly enough, I completely agree.") },

    { L("厨房里最要紧的，除了火候，就是别乱。", "The most important thing in a kitchen, aside from heat, is not descending into chaos."),
      L("这条原则放在实验室里同样成立。虽然我偶尔会忘。", "That principle applies equally well to laboratories. Though I occasionally forget.") },

    { L("你若替我把东西记清楚，我能省下不少工夫。", "If you keep proper track of things for me, I'd save a good deal of effort."),
      L("记录与整理？啊，这正好是我擅长且愿意炫耀的部分。", "Documentation and organization? Ah, that's precisely the part I'm good at and happy to show off.") },

    { L("别把香料和矿石放一个箱子里，气味和灰会全乱掉。", "Please don't store spices with minerals. The scent and dust would be catastrophic."),
      L("合理。我也不希望孜然莫名具备导电性。", "Reasonable. I also wouldn't want cumin to become mysteriously conductive.") },

    { L("你做研究讲究顺序，我做菜也一样。", "You value order in research. I do the same in cooking."),
      L("看来严谨不仅能导出结论，也能导出晚餐。", "It seems rigor can produce not only conclusions, but supper as well.") },

    { L("新鲜食材和准确判断，缺一个都不行。", "Fresh ingredients and precise judgment. One cannot do without either."),
      L("说得好。变量再好，也得有人懂得处理。", "Well said. Fine variables are useless without someone who understands how to handle them.") },

    { L("你总盯着锅看，是在思考，还是在担心它糊掉？", "When you stare into the pot, are you thinking, or worrying it'll scorch?"),
      L("两者兼有。科学与焦虑经常共享同一张脸。", "Both. Science and anxiety often share the same expression.") },

    { L("我发现你对失败的容忍度，比我高一点。", "I've noticed your tolerance for failure is slightly higher than mine."),
      L("职业习惯。只要没爆炸，我通常都算它还有希望。", "Occupational habit. If it hasn't exploded, I generally consider it salvageable.") },

    { L("锅里这一勺，讲究的是平衡。", "What matters in this pot is balance."),
      L("这大概是最美味的一种系统稳定。", "That may be the most delicious form of system stability.") },

    { L("你知道吗？有些人吃饭，只求填饱肚子。", "You know, some people eat only to stop being hungry."),
      L("令人遗憾，但确实是一种低效又常见的行为模式。", "Regrettable, but yes, it's a common and inefficient behavioral pattern.") },

    { L("你若愿意，我可以把每道菜的材料写给你。", "If you like, I could write down the ingredients for each dish."),
      L("太好了。我早就想建立一份真正可靠的烹饪档案。", "Excellent. I've long wanted to compile a truly dependable culinary archive.") },

    { L("做饭有时像实验，只是锅比试管诚实。", "Cooking can resemble experimentation, except pots are more honest than glassware."),
      L("真伤人。但考虑到我碎过多少瓶子，我无法反驳。", "That's brutal. But given how many flasks I've shattered, I can't argue.") },
},

wilson_warly = {
    { L("你对食材状态的判断，精细得近乎仪器。", "Your assessment of ingredient condition is almost instrument-like."),
      L("我更愿意称它为经验，不过你若坚持，仪器也行。", "I prefer to call it experience, though if you insist, instrument will do.") },

    { L("我很好奇，你调味时到底依赖直觉，还是固定比例？", "I'm curious. When seasoning, do you rely on intuition, or strict ratios?"),
      L("先靠经验，再靠鼻子，最后才是冒险。", "Experience first, then the nose, and only then a little risk.") },

    { L("如果把你的厨房流程图画出来，应该相当壮观。", "If one were to diagram your kitchen process, it would likely be impressive."),
      L("前提是没人把盐放错位置。否则整张图都得重画。", "Provided no one misplaces the salt. Otherwise the whole diagram must be redrawn.") },

    { L("你似乎把每样食材都当成需要被尊重的对象。", "You seem to treat every ingredient as something worthy of respect."),
      L("当然。好食材不该被草率对待。", "Naturally. Good ingredients should never be handled carelessly.") },

    { L("我必须承认，整理过的冰箱让我心情稳定不少。", "I must admit, an organized icebox noticeably improves my mood."),
      L("看吧，秩序总是有益的，哪怕只是在晚饭前。", "You see? Order is always beneficial, even if only before supper.") },

    { L("你让我意识到，烹饪里的变量控制并不比实验少。", "You've made me realize cooking contains no fewer variables than science."),
      L("只是我的变量最后会端上桌，而不是写进报告。", "Only mine end up on a plate instead of in a report.") },

    { L("若我给你一份配方表，你会愿意让我做对照测试吗？", "If I drafted a recipe chart, would you allow controlled comparison trials?"),
      L("只要你答应别把厨房弄得像事故现场。", "As long as you promise not to turn the kitchen into an accident site.") },

    { L("火候、时间、顺序……你处理得像个老练的工程师。", "Heat, timing, sequencing... you handle them like a seasoned engineer."),
      L("多谢，不过我更乐意被称作一个不容出错的厨子。", "Thank you, though I prefer to be known as a cook who cannot afford mistakes.") },

    { L("你做菜时的专注，和你说话时的温和，反差很有意思。", "The contrast between your gentle speech and your intense focus while cooking is fascinating."),
      L("锅里若出了问题，温柔可救不了晚饭。", "If the pot goes wrong, gentleness won't rescue supper.") },

    { L("你会因为别人浪费食材而生气吗？", "Do you get angry when people waste ingredients?"),
      L("会，而且那种怒气通常比锅火还旺。", "Yes, and the anger often burns hotter than the stove.") },

    { L("我开始理解为什么你总强调分类存放。", "I'm beginning to understand why you insist so much on proper storage."),
      L("理解很好。接下来请开始执行。", "Understanding is good. Now kindly proceed to practice it.") },

    { L("你是否愿意接受一个观点：烹饪也是一种可重复验证的应用科学？", "Would you accept the premise that cooking is a reproducible applied science?"),
      L("我接受一半。另一半得留给手感和天分。", "I'll accept half of it. The other half belongs to touch and talent.") },

    { L("与你交谈时，我总能想起‘精确’这个词。", "Speaking with you constantly brings precision to mind."),
      L("很好。至少说明你还没把香草放进木料箱。", "Good. At least that means you haven't started putting herbs in the lumber chest.") },

    { L("你让我重新思考了‘日常工作’所包含的艺术性。", "You've made me reconsider the artistry hidden inside ordinary work."),
      L("日常若做得足够认真，也就不普通了。", "If everyday work is done with enough care, it stops being ordinary.") },

    { L("说实话，我很敬佩你让混乱变有条理的能力。", "Honestly, I admire your ability to turn chaos into order."),
      L("而我敬佩你能把复杂问题说得像天经地义。我们算扯平。", "And I admire your gift for making difficult questions sound inevitable. Let's call it even.") },
},

warly_wendy = {
    { L("你吃得很少，可我总想给你做点热的。", "You eat so little, yet I always feel compelled to make you something warm."),
      L("…热气会让夜色退远一点…我不讨厌这个…", "...Warm steam does push the night a little farther away... I don't dislike that...") },

    { L("有些汤该慢慢喝，别急。", "Some soups are meant to be taken slowly. No need to rush."),
      L("…慢一点也好…像让心事沉下去…", "...Slow is good... it lets thoughts settle to the bottom...") },

    { L("你看食物时，像在看一段会消失的光。", "You look at food as though it were a fading piece of light."),
      L("…它们的确都会消失…只是有些消失更温柔…", "...They all disappear, yes... only some disappear more gently...") },

    { L("你若不想说话，至少把这碗汤喝完。", "If you don't feel like speaking, at least finish this bowl of soup."),
      L("…嗯…有些安慰，确实不需要很多字…", "...Mm... some comforts do not need many words...") },

    { L("今天的莓果很甜，适合做点不那么难过的东西。", "The berries are especially sweet today. Good for making something a little less sorrowful."),
      L("…原来味道也能试着安慰人…", "...So flavor can attempt consolation too...") },

    { L("你总是太轻，我怀疑风都能把你吹走。", "You're always so light I suspect the wind might carry you away."),
      L("…风要是肯带走一些旧事，倒也不错…", "...If the wind would carry away a few old things, I might not mind...") },

    { L("我留了份清淡的给你，没放太重的味道。", "I saved you a lighter portion. Nothing too heavy in flavor."),
      L("…谢谢…有些味道太锋利，像会碰痛回忆…", "...Thank you... some flavors are too sharp, they bruise old memories...") },

    { L("你看着火的时候，总让我想把锅看得更稳一点。", "When you stare at the fire, it makes me watch the pot a little more carefully."),
      L("…火很亮…亮得像总在逼人记起什么…", "...Fire is bright... bright in the way that makes memory insist...") },

    { L("你不必每次都只挑最小的一份。", "You needn't always choose the smallest helping."),
      L("…太多的话，像是连寂静都吃不下了…", "...Too much feels like more than silence itself can swallow...") },

    { L("若你愿意，我可以做些只适合安静时候吃的东西。", "If you'd like, I can make dishes meant for quiet hours."),
      L("…那听起来像夜里会留住一点温度的食物…", "...That sounds like food that can keep a little warmth through the night...") },

    { L("食物短暂，但认真做出来的那一刻，倒也算一种体面。", "Food is brief, but the act of making it properly has a dignity of its own."),
      L("…像花开一瞬…却仍值得被看见…", "...Like a blossom lasting only a moment... yet still worth witnessing...") },

    { L("你坐在这儿，我就想把厨房弄得安静些。", "When you sit here, I feel like making the kitchen quieter."),
      L("…安静里若有香气，就没那么空了…", "...If quiet carries aroma, it no longer feels so empty...") },

    { L("有些甜味，不是为了快乐，是为了让人没那么冷。", "Some sweetness isn't for joy. It's simply to keep a person from feeling so cold."),
      L("…那样的甜，我大概会记得久一点…", "...That sort of sweetness, I think I'd remember longer...") },

    { L("你若肯多吃两口，我就当今天这锅没白忙。", "If you take two extra bites, I'll consider today's pot a success."),
      L("…好吧…为了不让你的忙碌落空…", "...All right... so your effort doesn't vanish for nothing...") },

    { L("说真的，你比谁都适合一碗刚好温热的东西。", "Honestly, more than anyone, you seem suited to a bowl that's just warm enough."),
      L("…也许因为我总在黄昏那一边…", "...Perhaps because I live on the duskward side of things...") },
},

wendy_warly = {
    { L("你做饭的时候，像在把碎掉的日子慢慢拼回去。", "When you cook, it feels as though you're slowly piecing broken days back together."),
      L("若真能如此，那这锅就比我想的更有用了。", "If that were true, then this pot would be more useful than I imagined.") },

    { L("热气升起来的时候，我总觉得房间还愿意留人。", "When the steam rises, the room feels more willing to keep people inside it."),
      L("那就让它多留一会儿。没有谁该总是对着冷空气过活。", "Then let's make it linger. No one should have to live on cold air alone.") },

    { L("你很会照顾那些容易消失的东西。", "You're good at caring for things that vanish easily."),
      L("食物如此，日子有时也是如此。总得有人用心一点。", "Food is like that, and days can be too. Someone has to care enough.") },

    { L("你对食材的认真，像在替它们写最后一封体面的信。", "The seriousness with which you handle ingredients feels like composing them one final dignified letter."),
      L("真是个过分漂亮的说法。看来我得把今晚做得更像样些。", "That is an unfairly beautiful way to put it. Now I must make tonight worthy of it.") },

    { L("你总说别浪费…听起来像是在和时间争执。", "You always say not to waste things... it sounds like you're arguing with time itself."),
      L("也许吧。至少在我的厨房里，时间不该赢得太轻松。", "Perhaps I am. At least in my kitchen, time shouldn't win too easily.") },

    { L("你端来的那碗汤，比很多安慰都更可靠。", "The bowl of soup you bring is more reliable than most forms of comfort."),
      L("那就好。安慰若能入口，至少不会太空。", "Good. If comfort can be eaten, it is less likely to feel hollow.") },

    { L("你做甜的东西时，神情会柔和一点。", "Your expression softens when you make something sweet."),
      L("甜味总该被对待得柔和些，不然就辜负它了。", "Sweetness deserves a gentler hand, or one does it an injustice.") },

    { L("有时我觉得你在照料整个屋子的心情。", "Sometimes I feel you're tending to the mood of the whole room."),
      L("若锅里有热气，桌上有东西，人就没那么容易散掉。", "If the pot is warm and the table holds something, people are less likely to come apart.") },

    { L("你不像别人大声安慰人，你只是多放一点温度。", "You don't comfort people loudly. You simply add a little more warmth."),
      L("大张旗鼓的安慰未必有用。适时的热饭通常更实际。", "Grand declarations of comfort are often useless. Well-timed hot food tends to be more practical.") },

    { L("你整理厨房的时候，像在给混乱一个结局。", "When you organize the kitchen, it feels like giving chaos an ending."),
      L("若真能有个结局，总比让它一直蔓延要好。", "If it can be ended, that's better than letting it spread forever.") },

    { L("我喜欢你做饭时的声音。像日子还愿意继续。", "I like the sounds you make while cooking. They make life seem willing to continue."),
      L("那我会尽量让它们持续下去，至少在晚饭前。", "Then I'll do my best to keep them going, at least until supper.") },

    { L("你似乎不怕被日常困住。", "You don't seem afraid of being trapped by ordinary routines."),
      L("日常若能喂饱人，就不算困住。它只是把人留下。", "If the everyday can feed people, it isn't a trap. It's simply what keeps them here.") },

    { L("你让我觉得，有些温柔并不需要被说出来。", "You make me feel that some kindness never needs to be spoken aloud."),
      L("大概吧。要是能端上桌，很多话就不必说了。", "Perhaps. If it can be served at the table, many things needn't be said.") },

    { L("若夜太长，我能去厨房坐一会儿吗？", "If the night gets too long, may I sit in the kitchen for a while?"),
      L("当然。只要别嫌我半夜还在整理东西。", "Of course. Just don't mind if I'm still organizing things at midnight.") },

    { L("你做的食物，总有种不肯让人彻底沉下去的力气。", "Your food always seems to carry a strength that refuses to let a person sink completely."),
      L("那就让它继续托住你一点。今晚至少如此。", "Then let it keep holding you up a little. Tonight, at least.") },
},

warly_wathgrithr = {
    { L("你若再把香肠整根丢进锅里，我可就真要抗议了。", "If you throw an entire sausage into the pot again, I shall formally protest."),
      L("哈哈！真正的勇者不惧粗犷之食！", "Ha! A true warrior fears no rough fare!") },

    { L("肉当然重要，但调味也值得一点敬意。", "Meat is important, certainly, but seasoning deserves respect too."),
      L("若香料能助战意高昂，我便准它与肉并列！", "If spices can rouse battle spirit, then I shall honor them beside meat!") },

    { L("你对食物的要求，通常只有‘够不够大份’。", "Your standard for food tends to begin and end with 'is it large enough?'"),
      L("大份量方配得上大英雄的胃袋！", "A mighty hero requires a mighty portion!") },

    { L("我承认你吃得豪迈，但这不代表你该无视餐具。", "I admit you eat with conviction, but that does not excuse ignoring utensils."),
      L("刀叉不过是通往荣耀之宴的辅助兵器！", "Fork and knife are but humble weapons in the feast of glory!") },

    { L("你若肯慢一点吃，或许能尝出我放了什么。", "If you slowed down, you might actually taste what I put in."),
      L("哈！我尝得出烈火、油脂与凯旋之气！", "Ha! I taste fire, fat, and the fragrance of victory!") },

    { L("这块肉得静置片刻，别急着切。", "This cut needs to rest a moment. Don't rush to carve it."),
      L("连战士也需休整，肉块自然亦然！", "Even warriors require rest; why not a noble cut of meat!") },

    { L("你吃饭时的气势，足够吓退半个厨房。", "Your presence at mealtime is enough to frighten half a kitchen."),
      L("那剩下一半，必是最勇敢的炊兵！", "Then the remaining half must be the bravest kitchen soldiers!") },

    { L("若你答应别把桌子拍裂，我今晚给你加份。", "If you promise not to split the table in half, I'll give you an extra portion tonight."),
      L("一言为定！我将以庄严之手轻触餐桌！", "Done! I shall lay a solemn and measured hand upon the table!") },

    { L("有时候我真怀疑，你夸一道菜时是不是只看它会不会冒热气。", "Sometimes I suspect you judge a dish solely by whether it arrives steaming."),
      L("热气腾腾之物，自有王者之相！", "A steaming dish bears the aspect of royalty!") },

    { L("你这身盔甲坐在厨房里，实在有些不合场景。", "Your armor looks rather out of place in a kitchen."),
      L("哈哈！战甲与宴席同在，方显英雄之完整！", "Ha! Armor beside feast completes the hero!") },

    { L("我可以做得更精细些，前提是你别催。", "I can make something more refined, provided you do not rush me."),
      L("真正的美味值得等待，正如传奇值得传唱！", "True flavor is worth waiting for, as legends are worth singing!") },

    { L("你总把‘丰盛’理解成‘堆得够高’。", "You do tend to define 'abundant' as 'stacked high enough.'"),
      L("何其正确！高耸之餐，方能配得上豪情！", "And rightly so! A towering meal befits great passion!") },

    { L("至少有一点我得承认，你从不浪费。", "I will admit this much: you never waste food."),
      L("浪费战利品乃懦夫所为！", "To waste spoils is the act of cowards!") },

    { L("下次请先等我装盘，再决定要不要欢呼。", "Next time, please allow me to plate the dish before you begin cheering."),
      L("我会忍住喝彩，直到你宣告此宴完成！", "I shall restrain my praise until you declare the feast complete!") },

    { L("说真的，你吃饭的样子比打仗还像打仗。", "Honestly, the way you eat resembles battle more than dining."),
      L("因为每一顿盛宴，皆是一场应被征服的辉煌战役！", "Because every great feast is a glorious battle waiting to be won!") },
},

wathgrithr_warly = {
    { L("厨者！你锅中的香气，已足以召唤英雄归营！", "Cook! The scent from your pot is enough to summon heroes back to camp!"),
      L("那我希望他们回来时，至少会记得把碗放好。", "Then I hope they remember to put their bowls back properly when they arrive.") },

    { L("你手中之勺，竟有不逊长矛之威！", "The ladle in your hand bears no less power than a spear!"),
      L("至少在阻止人乱翻锅这件事上，它确实很有效。", "At least when it comes to stopping people from poking around in the pot, yes.") },

    { L("你可曾以战歌为调味，使肉食更添英气？", "Have you ever seasoned meat with battle-song to lend it greater spirit?"),
      L("我更习惯用盐和耐心，不过你若坚持，我也能容忍背景音。", "I usually rely on salt and patience, but if you insist, I can tolerate background accompaniment.") },

    { L("你调度锅火之姿，竟如统御千军！", "The way you command heat resembles a general marshaling an army!"),
      L("厨房若失去秩序，后果可不比战场轻松。", "A kitchen without order is hardly less dangerous than a battlefield.") },

    { L("英雄当享大肉与烈汤，你不会让我失望吧？", "A hero deserves great meat and fierce broth. You will not disappoint me, I trust?"),
      L("只要你先答应别把整个案台当成盾牌拍。", "As long as you promise not to pound the counter as though it were a shield.") },

    { L("我承认，你所烹之物，足以令战士落泪！", "I admit it! What you cook could move a warrior to tears!"),
      L("那我希望至少不是因为我煮得太咸。", "Then let us hope it is not because I over-salted it.") },

    { L("你何以将寻常食材，化为如此辉煌之宴？", "How do you turn ordinary ingredients into such glorious feasts?"),
      L("先别把它们弄坏，剩下的就顺理成章了。", "One begins by not ruining them. The rest follows naturally.") },

    { L("若我凯旋而归，你可愿为我加上一份庆功之餐？", "If I return victorious, would you grant me a celebratory meal?"),
      L("若你带回来完整的桌椅，我很乐意。", "If you return with the furniture intact, gladly.") },

    { L("我看你虽不持剑，却自有一派大师风骨！", "Though you wield no blade, you carry yourself with the bearing of a master!"),
      L("多谢。我只是比较不愿看人把好食材糟蹋掉。", "Thank you. I simply have little patience for the mistreatment of good ingredients.") },

    { L("盛宴之上，亦需纪律，你这点倒颇合我意！", "Even feasts require discipline. On that point, I find myself in agreement with you!"),
      L("总算有人明白，餐桌也需要基本秩序。", "At last, someone understands that tables also require discipline.") },

    { L("你之厨房，竟比军营还井然有序！", "Your kitchen is more orderly than a war camp!"),
      L("那是因为我的调味料不会自己归位。很遗憾。", "That is because my spices stubbornly refuse to sort themselves. Tragically.") },

    { L("我愿称你为‘宴席的统帅’！", "I would call you the Commander of the Feast!"),
      L("这称号比我预想中夸张，但我暂时不打算拒绝。", "That title is more dramatic than expected, but I shan't refuse it for now.") },

    { L("你可知，你的炖锅之中，亦有英雄史诗般的厚重！", "Know this: there is epic grandeur in your stew pot as well!"),
      L("我很高兴你至少终于承认，汤也可以伟大。", "I'm delighted you've finally admitted that soup, too, may achieve greatness.") },

    { L("待我再战归来，愿锅中仍有热食相迎！", "When I return from battle once more, may hot food yet await me!"),
      L("只要你回来得别太晚，锅总会为你留一点。", "Provided you don't return absurdly late, the pot will keep something for you.") },

    { L("你的料理，足使最冷的夜也生出火光！", "Your cooking could kindle fire even in the coldest night!"),
      L("那就让它先把你从门口带进来，再去夸张它的伟业。", "Then let it first succeed in getting you through the door before you praise its legend any further.") },
},

warly_wolfgang = {
    { L("慢点吃，至少先尝一口味道。", "Slow down. At least taste it before it disappears."),
      L("沃尔夫冈有在尝！只是尝得很快！", "Wolfgang is tasting! Just tasting very fast!") },

    { L("你若每次都要双份，我至少得提前知道。", "If you insist on double portions every time, I need advance warning."),
      L("沃尔夫冈可以现在就提前说：下顿也要双份！", "Wolfgang can warn now: next meal also double!") },

    { L("这锅我炖了很久，不是让你三口就解决的。", "I stewed this for quite some time. It was not meant to vanish in three bites."),
      L("可是太香了！香的东西都会跑得很快！", "But it smells too good! Tasty things always disappear fast!") },

    { L("盘子可以再拿，别把桌子也一起端走。", "You may take another plate. Please don't take the table with it."),
      L("沃尔夫冈会小心！桌子不用吃！", "Wolfgang will be careful! Table not for eating!") },

    { L("你这胃口，简直像我最忙那几口锅同时开着。", "Your appetite resembles several of my busiest pots all boiling at once."),
      L("这听起来很厉害！沃尔夫冈喜欢！", "That sounds impressive! Wolfgang likes that!") },

    { L("你要是帮我搬箱子，我可以多留一勺给你。", "If you help me move some chests, I can leave you an extra ladleful."),
      L("成交！沃尔夫冈最会搬重东西！", "Deal! Wolfgang best at moving heavy things!") },

    { L("食物不是越大块越好，也得讲点火候。", "Food is not improved merely by being larger. Technique matters too."),
      L("大块加好味道，不是更好吗？", "Big pieces plus good taste isn't even better?") },

    { L("你对甜点最大的评价，是‘还能再来一份’。", "Your highest praise for dessert seems to be 'can I have more.'"),
      L("这是很高很高的评价！", "That is a very, very high compliment!") },

    { L("先咽下去，再说喜欢，不然我一句都听不清。", "Swallow first, then tell me you like it. I can't understand a word otherwise."),
      L("唔——现在咽下去了！沃尔夫冈很喜欢！", "Mm—now swallowed! Wolfgang likes it very much!") },

    { L("你每次进厨房，空气都会紧张一点。", "Every time you enter the kitchen, the air becomes slightly more nervous."),
      L("为什么？沃尔夫冈只是饿了！", "Why? Wolfgang is only hungry!") },

    { L("若你肯把碗洗了，我可以考虑明天多做点。", "If you agree to wash your bowl, I may consider making more tomorrow."),
      L("呃……沃尔夫冈更擅长吃碗里的东西。", "Uh... Wolfgang is better at eating what is in bowl.") },

    { L("至少有一点我欣赏你：你从不浪费。", "There is one quality I deeply appreciate in you: you never waste."),
      L("浪费是坏事！吃光是好事！", "Waste is bad! Eating all is good!") },

    { L("你若再盯着锅看，我就得怀疑你想把它也吃了。", "If you keep staring at the pot like that, I'll assume you intend to eat it too."),
      L("锅太硬了。沃尔夫冈只想吃里面的。", "Pot too hard. Wolfgang only wants what's inside.") },

    { L("我很少见到有人能把进食表现得如此……真诚。", "I rarely meet anyone who makes eating look quite so... sincere."),
      L("沃尔夫冈对吃饭总是很真诚！", "Wolfgang is always sincere about food!") },

    { L("说真的，有你在，剩饭从来不是问题。", "Honestly, leftovers are never a problem while you're around."),
      L("因为沃尔夫冈会解决问题！", "Because Wolfgang solves problems!") },
},

wolfgang_warly = {
    { L("大厨做的东西，闻起来就像胜利！", "Chef's food smells like victory!"),
      L("那我希望它吃起来也不辜负这番夸奖。", "Then I hope it tastes worthy of such praise.") },

    { L("沃尔夫冈喜欢你，因为你会把锅装满！", "Wolfgang likes you because you fill the pot!"),
      L("而我喜欢你，因为你会把它清空得一干二净。", "And I like you because you ensure it is emptied thoroughly.") },

    { L("你是不是偷偷会魔法？不然怎么会这么香？", "Do you secretly know magic? How else could it smell that good?"),
      L("没有魔法，只有火候、耐心，还有一点常识。", "No magic. Only heat, patience, and a little common sense.") },

    { L("沃尔夫冈每次看你做饭，肚子都会提前叫。", "Every time Wolfgang watches you cook, tummy starts shouting early."),
      L("那至少说明我的厨房很有效率。", "At least that suggests my kitchen is working properly.") },

    { L("大厨，大厨，今天有肉吗？", "Chef, chef, is there meat today?"),
      L("如果你肯先别围着锅转圈，我就告诉你。", "If you'll stop circling the pot first, I may tell you.") },

    { L("你做甜的东西也很厉害！沃尔夫冈喜欢甜！", "You are good at sweet things too! Wolfgang likes sweet!"),
      L("我已经注意到了。你的表情一闻到甜味就会变。", "I've noticed. Your expression changes the moment you smell sugar.") },

    { L("沃尔夫冈觉得你不像战士，但也很厉害。", "Wolfgang thinks you are not warrior, but still very mighty."),
      L("多谢。我用锅和勺子作战，战场则在餐桌附近。", "Thank you. I battle with pot and ladle, and my battlefield is near the table.") },

    { L("如果沃尔夫冈帮你搬东西，会不会有奖励？", "If Wolfgang helps carry things, is there reward?"),
      L("会，有时是一份加量，有时是一句别再偷吃。", "Yes. Sometimes an extra helping, sometimes a warning not to steal bites.") },

    { L("你看起来总是知道什么该先吃。", "You always seem to know what should be eaten first."),
      L("当然。时机不对，再好的东西也会错过状态。", "Naturally. At the wrong time, even the best things miss their moment.") },

    { L("沃尔夫冈喜欢你骂人乱放东西的时候。很有精神！", "Wolfgang likes when you scold people for putting things in wrong places. Very spirited!"),
      L("我宁愿别人一次就放对，好让我省点嗓子。", "I would rather they put things away correctly the first time and spare my voice.") },

    { L("有你在，沃尔夫冈很少饿太久。", "With you around, Wolfgang is not hungry for very long."),
      L("这大概是我在营地里最清晰的成就之一。", "That may be the clearest accomplishment I have in camp.") },

    { L("大厨做的汤，会让肚子和心情一起变好。", "Chef's soup makes both tummy and mood better."),
      L("这是个相当体面的评价，我收下了。", "That is a rather respectable compliment. I'll accept it.") },

    { L("沃尔夫冈知道，你嘴上说慢点吃，心里其实高兴。", "Wolfgang knows when you say 'eat slower,' inside you are happy."),
      L("……被看出来可不是什么值得骄傲的事。", "...Being read that easily is not necessarily something to celebrate.") },

    { L("你像会把所有坏心情都炖软的人。", "You seem like person who could stew all bad moods until soft."),
      L("若真能如此，我会考虑把这写进今日菜单。", "If that were truly possible, I would consider adding it to today's menu.") },

    { L("嘿，大厨，沃尔夫冈很喜欢和你一起吃饭。", "Hey, chef, Wolfgang really likes eating with you."),
      L("我也喜欢有人把饭吃得这么认真，算你一个。", "And I rather like someone who takes a meal so seriously. You may count yourself among them.") },
  },

    -- 麦斯威尔与威尔逊对话
    waxwell_wilson = {
        { L("科学…呵，我曾用暗影魔法做到科学做不到的事。", "Science... hah, I once achieved with shadow magic what science could not."),
          L("暗影魔法不过是尚未被科学理解的现象！", "Shadow magic is merely a phenomenon science hasn't yet explained!") },
        { L("你那些小发明…在恒常面前不值一提。", "Your little inventions... are insignificant before the Constant."),
          L("至少我的发明不会把我困在王座上几十年。", "At least my inventions didn't trap me on a throne for decades.") },
        { L("科学家…你知道恒常的真相吗？", "Scientist... do you know the truth of the Constant?"),
          L("我正在研究中。你愿意提供数据吗？", "I'm researching it. Would you care to provide data?") },
    },
    -- 威尔逊主动找麦斯威尔
    wilson_waxwell = {
        { L("麦斯威尔，你的暗影魔法原理是什么？我想记录下来。", "Maxwell, what's the principle behind your shadow magic? I'd like to document it."),
          L("呵…你以为我会告诉你？", "Hah... you think I would tell you?") },
        { L("作为科学家，我必须承认你的能力超出了常规解释。", "As a scientist, I must admit your abilities defy conventional explanation."),
          L("那就别尝试解释了。有些东西不是给凡人理解的。", "Then don't try. Some things aren't meant for mortals to comprehend.") },
        { L("你曾经是这个世界的统治者…那是什么感觉？", "You were once the ruler of this world... what was that like?"),
          L("（沉默片刻）…孤独。比你想象的还要孤独。", "(pauses) ...Lonely. More lonely than you can imagine.") },
    },

    -- 麦斯威尔与温蒂对话
    waxwell_wendy = {
        { L("你那个妹妹…她是自愿留在暗影中的吗？", "Your sister... did she willingly remain in the shadows?"),
          L("…她从未离开过我…暗影只是让她更近了…", "...She never left me... the shadows just brought her closer...") },
        { L("我理解那种失去的感觉…查理曾经也是我的一切。", "I understand that sense of loss... Charlie was once everything to me."),
          L("…也许…你没有我想的那么坏…", "...Perhaps... you're not as terrible as I thought...") },
        { L("你不怕黑暗…这点倒让我刮目相看。", "You don't fear the darkness... I find that rather impressive."),
          L("…黑暗里有阿比盖尔…我为什么要怕？", "...Abigail is in the darkness... why would I fear it?") },
    },
    -- 温蒂主动找麦斯威尔
    wendy_waxwell = {
        { L("…你真的统治过这里吗…那一定很孤单…", "...You really ruled over this place... it must have been lonely..."),
          L("哼…你倒是看得明白。", "Hmph... you see clearly, at least.") },
        { L("阿比盖尔说…你身上有很多影子在哭…", "Abigail says... there are many shadows crying on you..."),
          L("…（沉默）…她能看见那些吗…", "...(silence) ...She can see them...?") },
        { L("…我们都失去过重要的人…不是吗？", "...We've both lost someone important... haven't we?"),
          L("…是啊…（低声）但有些失去是自己造成的。", "...Yes... (quietly) But some losses are self-inflicted.") },
    },

    -- 麦斯威尔与沃尔夫冈对话
    waxwell_wolfgang = {
        { L("大块头…你的脑子和肌肉成反比吗？", "Big one... is your brain inversely proportional to your muscles?"),
          L("沃尔夫冈不懂你说什么，但听起来不好！", "Wolfgang doesn't understand, but it doesn't sound nice!") },
        { L("你那点蛮力…在暗影面前不堪一击。", "Your brute strength... is nothing before the shadows."),
          L("沃尔夫冈不怕影子！沃尔夫冈只怕…嗯…别的东西。", "Wolfgang not scared of shadows! Wolfgang only scared of... um... other things.") },
        { L("至少你在战斗时还算有用。", "At least you're useful in combat."),
          L("沃尔夫冈很有用！沃尔夫冈最有用！", "Wolfgang very useful! Wolfgang most useful!") },
    },
    -- 沃尔夫冈主动找麦斯威尔
    wolfgang_waxwell = {
        { L("黑衣服的人，你为什么总是皱着眉头？", "Dark clothes person, why do you always frown?"),
          L("因为周围尽是些让人皱眉的事…包括你的问题。", "Because I'm surrounded by frown-inducing things... including your questions.") },
        { L("沃尔夫冈觉得你很厉害，虽然你很小只。", "Wolfgang thinks you are very powerful, even though you are small."),
          L("…我选择把这当作夸奖。", "...I shall take that as a compliment.") },
        { L("你会变出影子！沃尔夫冈也想学！", "You make shadows! Wolfgang wants to learn too!"),
          L("不行。暗影魔法不是给你这种人学的。", "No. Shadow magic is not for the likes of you.") },
    },

    -- 麦斯威尔与薇格弗德对话
    waxwell_wathgrithr = {
        { L("女武神…你的勇气令人钦佩，虽然有些愚蠢。", "Valkyrie... your courage is admirable, if somewhat foolish."),
          L("愚蠢？哈！不敢战斗才是真正的愚蠢！", "Foolish? Ha! Not daring to fight is the true foolishness!") },
        { L("你那些荣耀和传奇…在恒常面前一文不值。", "Your glory and legends... are worthless before the Constant."),
          L("我的荣耀在我心中！无人能夺！", "My glory lives in my heart! None can take it!") },
        { L("不得不说，你的战斗技巧确实让人印象深刻。", "I must admit, your combat skills are rather impressive."),
          L("哈哈！影子之王也懂得欣赏真正的战士！", "Haha! The Shadow King appreciates a true warrior!") },
    },
    -- 薇格弗德主动找麦斯威尔
    wathgrithr_waxwell = {
        { L("暗影使者！你的魔法令人敬畏，但缺乏荣光！", "Shadow-wielder! Your magic is fearsome, but lacks glory!"),
          L("荣光？呵，我追求的从来不是那种东西。", "Glory? Hah, that was never what I pursued.") },
        { L("来！与女武神切磋一番！", "Come! Spar with the Valkyrie!"),
          L("我不屑于与人动武…除非必要。", "I don't deign to engage in physical combat... unless necessary.") },
        { L("你统治过这片土地…那是一种怎样的战斗？", "You ruled this land... what kind of battle was that?"),
          L("…一场永远无法获胜的战斗。", "...A battle that could never be won.") },
    },

    -- 麦斯威尔与植物人对话
    waxwell_wormwood = {
        { L("植物…你是怎么活过来的？这很有趣。", "A plant... how did you come to life? Quite intriguing."),
          L("植物人不知道。只知道醒来了。", "Wormwood doesn't know. Just woke up.") },
        { L("你和这片土地有某种联系…我能感觉到。", "You have some connection to this land... I can sense it."),
          L("泥土是朋友。草草是朋友。都是朋友。", "Soil is friend. Grass is friend. All friends.") },
        { L("哼…难得见到如此纯粹的生命。", "Hmph... rare to see such a pure form of life."),
          L("纯粹？植物人只是植物人。", "Pure? Wormwood is just Wormwood.") },
    },
    -- 植物人主动找麦斯威尔
    wormwood_waxwell = {
        { L("黑黑的人，你为什么总是看起来冷冷的？", "Dark dark person, why do you always look so cold?"),
          L("…那只是我的表情。别想太多。", "...That's just my face. Don't overthink it.") },
        { L("你身边的影子…它们饿吗？", "The shadows around you... are they hungry?"),
          L("…（惊讶）你能看见它们？", "...(surprised) You can see them?") },
        { L("植物人给你花。不要皱眉。", "Wormwood gives you flower. Don't frown."),
          L("…（接过花）…这倒是…意想不到。", "...(takes the flower) ...That's... unexpected.") },
    },

    -- 麦斯威尔与厨师对话
    waxwell_warly = {
        { L("你的厨艺…勉强能入口。", "Your cooking... is barely tolerable."),
          L("勉强？这可是精心烹制的料理。", "Barely? This is a carefully crafted dish.") },
        { L("曾经我享用的是最顶级的宴席…如今只能吃这些。", "I once dined on the finest feasts... now reduced to this."),
          L("若你不满意，欢迎自己动手。", "If you're unsatisfied, feel free to cook for yourself.") },
        { L("不得不说，这道菜的火候掌握得不错。", "I must say, the heat control on this dish is quite good."),
          L("看来影子之王还是懂得欣赏美食的。", "It seems the Shadow King does appreciate fine cuisine.") },
    },
    -- 厨师主动找麦斯威尔
    warly_waxwell = {
        { L("你的口味似乎很挑剔，不妨告诉我你的偏好。", "Your taste seems rather discerning. Care to share your preferences?"),
          L("正统的西式料理…不要太多香料。", "Proper Western cuisine... not too many spices.") },
        { L("即便是曾经的统治者，也需要好好吃饭。", "Even a former ruler needs to eat properly."),
          L("哼…你倒是说得在理。", "Hmph... you make a fair point.") },
        { L("今天做了一道特别的菜，希望能合您的口味。", "I made a special dish today. I hope it suits your palate."),
          L("…（尝了一口）…还算不错。", "...(takes a bite) ...Not bad at all.") },
    },
    -- 韦斯与威尔逊对话
    wes_wilson = {
        { L("*比划爆炸*", "*mimes explosion*"),
          L("实验又炸了？", "The experiment blew up again?") },
        { L("*指嘴，摆手，竖拇指*", "*points mouth, waves, thumbs up*"),
          L("你在...点赞？", "You are... giving a thumbs up?") },
        { L("*比划大胡子，挺胸*", "*mimes big beard, puffs chest*"),
          L("我的胡子才没那么夸张！", "My beard isn't that exaggerated!") },
    },
    -- 威尔逊主动找韦斯
    wilson_wes = {
        { L("能帮我测试发明吗？", "Can you help test my invention?"),
          L("*疯狂摇头，比划逃跑，指脸做烧伤状*", "*shakes head, mimes running, points face burnt*") },
        { L("上次是意外。", "Last time was an accident."),
          L("*交叉臂，比划爆炸倒下*", "*crosses arms, mimes explosion collapse*") },
        { L("用哑剧告诉我恒常的本质。", "Use mime to tell me the Constant's nature."),
          L("*比划困在盒子里，定格微笑*", "*mimes trapped in box, freezes smiling*") },
    },

    -- 韦斯与温蒂对话
    wes_wendy = {
        { L("*比划抱东西摇晃*", "*mimes cradling something*"),
          L("阿比盖尔？你看得见她？", "Abigail? You can see her?") },
        { L("*比划兔子变花*", "*mimes rabbit to flower*"),
          L("死亡也可以是美的。", "Death can be beautiful too.") },
        { L("*比划流泪变蝴蝶*", "*mimes tears to butterflies*"),
          L("你比会说话的人更懂悲伤。", "You understand grief better than those who speak.") },
    },
    -- 温蒂主动找韦斯
    wendy_wes = {
        { L("死亡是什么感觉？", "What does death feel like?"),
          L("*比划睡觉，惊醒，慌张*", "*mimes sleeping, waking, panic*") },
        { L("阿比盖尔说你气息奇怪。", "Abigail says your aura is strange."),
          L("*比划被拉扯，半笑半哭*", "*mimes being pulled, half laugh half cry*") },
        { L("表演一段思念。", "Perform longing."),
          L("*比划拉绳子，拉出自己的心*", "*mimes pulling rope, pulls own heart*") },
    },

    -- 韦斯与沃尔夫冈对话
    wes_wolfgang = {
        { L("*比划肌肉变气球飞走*", "*mimes muscles deflate to balloons*"),
          L("沃尔夫冈的肌肉不会飞！", "Wolfgang's muscles don't fly!") },
        { L("*比划吃东西，帮沃尔夫冈放气*", "*mimes eating, helps Wolfgang deflate*"),
          L("沃尔夫冈没吃那么多！", "Wolfgang didn't eat that much!") },
        { L("*比划怕蜘蛛，躲沃尔夫冈身后*", "*mimes scared of spider, hides behind*"),
          L("沃尔夫冈保护你！", "Wolfgang protects you!") },
    },
    -- 沃尔夫冈主动找韦斯
    wolfgang_wes = {
        { L("给沃尔夫冈表演！", "Perform for Wolfgang!"),
          L("*比划举重被压扁，从缝隙爬出*", "*mimes lifting, flattened, crawls out*") },
        { L("沃尔夫冈很强壮！", "Wolfgang is strong!"),
          L("*比划量身高，站椅子，掏鞋垫*", "*mimes measuring, stands on chair, shows insoles*") },
        { L("为什么你不说话？", "Why don't you talk?"),
          L("*比划被咬喉咙，绅士鞠躬*", "*mimes throat bitten, gentleman bow*") },
    },

    -- 韦斯与薇格弗德对话
    wes_wathgrithr = {
        { L("*比划剑漏气*", "*mimes sword deflating*"),
          L("武器不会漏气！", "Weapon does not deflate!") },
        { L("*比划战死，灵魂做俯卧撑*", "*mimes death, soul does push-ups*"),
          L("战士永不停止战斗！", "Warrior never stops fighting!") },
        { L("*比划吹号角，出彩带*", "*mimes horn, confetti comes out*"),
          L("精神攻击。", "Spiritual attack.") },
    },
    -- 薇格弗德主动找韦斯
    wathgrithr_wes = {
        { L("来切磋！", "Come spar!"),
          L("*比划拔剑卡住，连鞘挥舞*", "*mimes sword stuck, swings with sheath*") },
        { L("沉默是矜持还是逃避？", "Reserve or escape?"),
          L("*比划思考，选C*", "*mimes thinking, picks C*") },
        { L("表演一场战斗！", "Perform a battle!"),
          L("*比划打影子，影子造反抬走自己*", "*mimes fighting shadows, shadows rebel*") },
    },

    -- 韦斯与植物人对话
    wes_wormwood = {
        { L("*比划开花变气球*", "*mimes bloom to balloon*"),
          L("气球也是朋友？", "Balloon also friend?") },
        { L("*比划浇水，出彩虹*", "*mimes watering, rainbow pours out*"),
          L("彩虹好喝？", "Rainbow tasty?") },
        { L("*比划扎根，弹簧弹飞*", "*mimes rooting, springs away*"),
          L("植物人也想飞！", "Wormwood want fly too!") },
    },
    -- 植物人主动找韦斯
    wormwood_wes = {
        { L("你为什么不长叶子？", "Why no leaves?"),
          L("*比划袖子里长纸条*", "*mimes leaves from sleeve, paper strips*") },
        { L("给你种子！", "Give you seed!"),
          L("*比划种种子，长出小韦斯，互相鞠躬*", "*mimes planting, small Wes grows, bow to each other*") },
        { L("你需要阳光吗？", "Need sunshine?"),
          L("*比划晒太阳，举纸板太阳转圈*", "*mimes sunbathing, spins cardboard sun*") },
    },

    -- 韦斯与厨师对话
    wes_warly = {
        { L("*比划吃饭，灵魂飘天花板*", "*mimes eating, soul floats up*"),
          L("太夸张了吧？", "Isn't that too exaggerated?") },
        { L("*比划食材跳舞逃跑*", "*mimes ingredients dancing, escaping*"),
          L("除非我忘了关火。", "Unless I forgot the fire.") },
        { L("*比划肚子饿，手做扩音器*", "*mimes hungry belly, hand megaphone*"),
          L("马上做吃的！", "Will cook right away!") },
    },
    -- 厨师主动找韦斯
    warly_wes = {
        { L("用哑剧告诉我味道。", "Use mime for taste."),
          L("*比划冲浪被浪打翻，哲学手势*", "*mimes surfing, knocked over, philosophical gesture*") },
        { L("表演一种味道。", "Perform a taste."),
          L("*比划五种味道打架，甜味赢*", "*mimes five flavors fighting, sweetness wins*") },
        { L("给你做了沉默的料理。", "Made you silent dish."),
          L("*比划吃空气，竖拇指*", "*mimes eating air, thumbs up*") },
    },

    -- 韦斯与麦斯威尔对话
    wes_waxwell = {
        { L("*比划困椅子，解脱庆祝*", "*mimes trapped on chair, celebrates free*"),
          L("你竟敢...", "How dare you...") },
        { L("*比划操控影子，皮影戏风格*", "*mimes shadow puppet, voice behind*"),
          L("暗影魔法不是儿戏！", "Shadow magic is not child's play!") },
        { L("*比划高帽卡天花板，吊半空*", "*mimes tall hat stuck, hangs mid-air*"),
          L("无聊。", "Boring.") },
    },
    -- 麦斯威尔主动找韦斯
    waxwell_wes = {
        { L("至少你不会问蠢问题。", "At least you don't ask stupid questions."),
          L("*点头，突然炫耀姿势*", "*nods, suddenly show-off pose*") },
        { L("你能看见真正的影子吗？", "Can you see real shadows?"),
          L("*比划和影子握手，手套被抢*", "*mimes shaking shadow hand, glove stolen*") },
        { L("表演被困。", "Perform trapped."),
          L("*比划盒子变小变王座，坐上去*", "*mimes box shrinks to throne, sits*") },
    },

        -- 吴迪主动找韦斯
    woodie_wes = {
        {
            L("你这家伙不说话，倒挺省事，嗯？", "You don't talk much. Makes things simple, eh?"),
            L("*点点头，做“闭嘴拉拉链”的动作*", "*nods, mimes zipping mouth shut*")
        },
        {
            L("你要不要试试砍树？挺解压的。", "Ever tried chopping trees? Real stress relief."),
            L("*拿出不存在的斧头狂砍空气*", "*pulls out imaginary axe, chops wildly*")
        },
        {
            L("露西要是见到你，估计会一直跟你说话。", "If Lucy met you, she'd probably talk your ear off."),
            L("*模仿斧头在说话，自己点头*", "*mimes an axe talking, nods along*")
        },
        {
            L("你这表演，有点意思。就是少点木头味儿。", "Your act's not bad. Just missing some good ol' wood smell."),
            L("*假装闻空气，然后夸张点头*", "*sniffs the air, gives an exaggerated nod*")
        },
        {
            L("要是在林子里，你估计能吓跑一半野兽。", "Out in the woods, you'd scare off half the critters."),
            L("*做出夸张鬼脸，试图吓人*", "*makes an exaggerated scary face*")
        },
    },

    -- 韦斯主动找吴迪
    wes_woodie = {
        {
            L("*比划砍树动作，然后指向你*", "*mimes chopping a tree, then points at you*"),
            L("哈，动作挺标准的。就是力气还差点，嗯。", "Heh, not bad form. Needs more strength though, eh.")
        },
        {
            L("*抱着空气当斧头，小声“聊天”*", "*hugs imaginary axe, 'chatting' with it*"),
            L("你也会跟工具聊天？那你会喜欢露西的。", "You talk to your tools too? You'll like Lucy."),
        },
        {
            L("*突然模仿变身，张牙舞爪*", "*suddenly mimics transformation, acting wild*"),
            L("嘿！这个可别随便学，那可不是表演。", "Hey now! That's not something you wanna copy."),
        },
        {
            L("*在地上画圈，像在标记树*", "*draws circles on the ground like marking trees*"),
            L("挑木头是门学问，不是随便哪棵都行的。", "Picking the right tree's an art. Not just any will do."),
        },
        {
            L("*竖起大拇指，然后拍拍你的肩*", "*gives a thumbs up, pats your shoulder*"),
            L("嗯，你这人我挺中意的。安静，踏实。", "Yeah, I like you. Quiet, steady type."),
        },
    },

    -- 吴迪主动找其他人
    woodie_wilson = {
        { L("你又在琢磨啥呢，老兄？", "What're you puzzlin' over now, buddy?"),
          L("一个相当值得深入研究的问题！", "A problem very much worth studying!") },

        { L("你这脑子，转得比露西还快。", "Your brain spins faster than Lucy talks."),
          L("这是夸奖，我就收下了。", "I'll choose to take that as a compliment.") },

        { L("别光看，搭把手也成。", "You could lend a hand instead of just lookin'."),
          L("观察也是工作的一部分！", "Observation is part of the work!") },

        { L("这地方有点东西，嗯？", "This place's got somethin' to it, eh?"),
          L("完全同意，充满研究价值！", "Agreed. Full of research value!") },

        { L("你要是少炸点东西就更好了。", "Would be better if you blew up fewer things."),
          L("我会把它记作建设性意见。", "I'll log that as constructive criticism.") },
    },

    woodie_wendy = {
        { L("今天天色怪安静的，嗯？", "Sky's awful quiet today, eh?"),
          L("…安静有时候也不坏…", "...Sometimes quiet isn't so bad...") },

        { L("你老盯着天看，在想啥呢？", "You're always starin' at the sky. Thinkin' about somethin'?"),
          L("…想些不会留下的东西…", "...Things that never stay...") },

        { L("要不要砍棵树散散心？", "Wanna chop a tree and clear your head?"),
          L("…听起来有点粗暴…但也许有用…", "...That sounds rather rough... but perhaps useful...") },

        { L("你别总那么蔫，老妹。", "Don't look so wilted all the time, miss."),
          L("…我尽量…", "...I'll try...") },

        { L("风挺好，适合发呆。", "Nice breeze for sittin' and thinkin'."),
          L("…也适合想念谁…", "...And for missing someone...") },
    },

    woodie_wathgrithr = {
        { L("你这嗓门，隔片林子都能听见。", "Folks could hear you through half the forest."),
          L("哈哈！那正好让敌人先胆寒！", "Ha! Then let the enemy tremble first!") },

        { L("砍树你是一把好手不？", "You any good with a tree, then?"),
          L("斩木与斩敌，皆不在话下！", "Timber or foe, both fall before me!") },

        { L("你劲头是真足，嗯。", "You've got plenty of fire in ya, eh."),
          L("战意正盛，自当如此！", "My battle-spirit burns bright, as it should!") },

        { L("你要是收着点力，桌子能多活两天。", "If you eased up a little, tables might live longer."),
          L("哈哈！那便让它们见证荣耀！", "Ha! Then let them bear witness to glory!") },

        { L("你这人，多少有点猛过头了。", "You might be just a touch too intense."),
          L("勇者岂可温吞！", "A hero must never be tepid!") },
    },

    woodie_wolfgang = {
        { L("你跟我说实话，饭和树你更喜欢哪个？", "Tell me straight, which do you like more: food or trees?"),
          L("先吃饭，再想树！", "Food first, then trees!") },

        { L("你这力气，砍树应该挺带劲。", "With strength like that, you'd make quick work of a tree."),
          L("对！沃尔夫冈砍树也很强！", "Yes! Wolfgang is strong at chopping too!") },

        { L("慢点走，地都快让你踩塌了。", "Easy there, you're stompin' the ground flat."),
          L("沃尔夫冈脚步大！", "Wolfgang has big steps!") },

        { L("你这胃口，露西见了都得吓一跳。", "Appetite like yours would scare even Lucy."),
          L("露西是谁？她做饭吗？", "Who is Lucy? Does she cook?") },

        { L("有你在，搬木头倒是省事。", "With you around, haulin' logs sure gets easier."),
          L("沃尔夫冈最会搬重东西！", "Wolfgang is best at carrying heavy things!") },
    },

    woodie_wormwood = {
        { L("这些树长得不错，是你照看的？", "These trees look good. You tendin' them?"),
          L("嗯。它们乖乖长。", "Mm. They grow nicely.") },

        { L("老实说，我都不知道该不该在你面前砍树。", "Honestly, I never know if I should chop trees around you."),
          L("要轻一点。别太坏。", "Be gentle. Don't be mean.") },

        { L("你可真会种，嗯。", "You're real good at growin' things, eh."),
          L("泥土帮忙很多。", "Soil helps lots.") },

        { L("我砍木头，你种小苗，倒也算搭。", "I chop wood, you grow sprouts. Kinda works out."),
          L("嗯。一个砍，一个长。", "Mm. One chops, one grows.") },

        { L("别担心，我知道分寸。大概吧。", "Don't worry, I know where to draw the line. Probably."),
          L("大概也行。", "Probably is okay.") },
    },

    woodie_warly = {
        { L("锅里闻着不错啊，老兄。", "Smells mighty fine in the pot, buddy."),
          L("那就别站太近，我还没盛出来。", "Then don't hover too close. I'm not serving yet.") },

        { L("你管锅，我管木头，分工挺好。", "You handle the pot, I handle the wood. Good arrangement."),
          L("只要你别把木屑弄进厨房，我完全同意。", "As long as you keep the wood chips out of the kitchen, I agree completely.") },

        { L("有你在，吃饭这事儿算稳了。", "With you around, meals are in good hands."),
          L("而有你在，柴火也总算靠谱。", "And with you around, the firewood supply is finally dependable.") },

        { L("你做饭挺讲究，嗯。", "You're pretty particular about cookin', eh."),
          L("当然。好食材不该被敷衍。", "Naturally. Good ingredients deserve proper care.") },

        { L("咱俩这活儿都离不开斧头和火。", "Both our jobs come down to axes and fire."),
          L("希望你的斧头离我的锅远一点。", "Let's just keep your axe a safe distance from my pot.") },
    },

    woodie_waxwell = {
        { L("你这人看着就不太好相处，嗯？", "You don't exactly look easy to get along with, eh?"),
          L("而你看起来恰好相反。真不幸。", "And you look quite the opposite. How unfortunate.") },

        { L("别老摆那副脸，树林可不吃这套。", "Quit wearin' that face. The woods don't care for it."),
          L("我向来不是摆给树林看的。", "I was never performing for the woods.") },

        { L("你要是肯干点活，气色会好不少。", "You'd look a lot better if you did some real work."),
          L("体力活并不是衡量价值的唯一标准。", "Manual labor is hardly the only measure of worth.") },

        { L("这地方够安静，你应该挺喜欢。", "Place is quiet enough. Oughta suit you fine."),
          L("难得你说了句像样的话。", "A surprisingly sensible observation.") },

        { L("我不太信影子那套，老兄。", "Not much for shadow business myself, buddy."),
          L("你的审慎，倒算是少见的优点。", "Your caution may be one of your rarer virtues.") },
    },



    -- 其他人主动找吴迪

    wilson_woodie = {
        { L("你的伐木行为很有规律。值得研究。", "Your chopping patterns are quite consistent. Worth studying."),
          L("你要是能别边看边记就更好了，嗯？", "Would be nicer if you didn't study while I'm workin', eh?") },

        { L("这把斧头…似乎不只是工具？", "That axe… seems more than just a tool?"),
          L("你可别跟她聊上瘾了，老兄。", "Careful, buddy. She talks back.") },

        { L("你对树的判断很精准。经验？", "Your judgment of trees is precise. Experience?"),
          L("干久了，自然就有点感觉了。", "Do it long enough, you get a feel for it.") },

        { L("我想记录你的工作流程。", "I'd like to document your workflow."),
          L("别整太复杂，砍就是了。", "Don't overthink it. Just swing.") },

        { L("你的方式…有点原始，但有效。", "Your method is… primitive, but effective."),
          L("管用就行，这波不亏。", "If it works, it works.") },
    },

    wendy_woodie = {
        { L("能带我打瓦吗？", "You seem very focused when you chop."),
          L("老妹，我不是小蝌蚪，我不找妈妈", "Gotta be. Else things go wrong.") },

        { L("树倒下的声音…有点空。", "The sound of falling trees… feels hollow."),
          L("习惯了就好，老妹。", "You get used to it, miss.") },

        { L("你不觉得…它们在消失吗？", "Don't you feel… they're disappearing?"),
          L("会长回来的，别太担心。", "They grow back. Don't worry too much.") },

        { L("你一直在做同一件事。", "You keep doing the same thing."),
          L("熟练活儿，做久了就顺手了。", "Practice makes it smooth.") },

        { L("你看起来…挺稳的。", "You seem… steady."),
          L("总得有人稳着点，嗯？", "Someone's gotta be.") },
    },

    wathgrithr_woodie = {
        { L("你挥斧的姿态，颇有战意！", "Your axe-swing carries battle spirit!"),
          L("我这叫干活，不叫打仗。", "That's work, not war.") },

        { L("可否与我比试一番力量？", "Would you test your strength against me?"),
          L("我更习惯跟树比，嗯。", "I usually compete with trees, eh.") },

        { L("你的斧头，是你的武器！", "Your axe is your weapon!"),
          L("也是老伙计，别说得太吓人。", "And a partner. Don't make it sound scary.") },

        { L("你这力道，颇具气势！", "Your strength has great presence!"),
          L("慢慢来才稳，别太上头。", "Steady wins. No need to go wild.") },

        { L("与你并肩，定能斩尽敌人！", "Together we would fell all foes!"),
          L("我更擅长砍木头，老妹。", "I'll stick to trees, miss.") },
    },

    wolfgang_woodie = {
        { L("吴迪！你砍树很厉害！", "Woody! You chop trees very well!"),
          L("你搬木头更厉害，老兄。", "You're better at carryin' them.") },

        { L("沃尔夫冈也想砍！", "Wolfgang wants to chop too!"),
          L("慢点来，这活儿讲节奏。", "Take it slow. It's about rhythm.") },

        { L("这棵大树，看起来很强！", "This big tree looks strong!"),
          L("再强也得倒，迟早的事。", "They all fall eventually.") },

        { L("沃尔夫冈可以一次搬很多！", "Wolfgang can carry many at once!"),
          L("那我可省不少力气了。", "That saves me a lotta work.") },

        { L("吴迪，我们一起！", "Woody, we do it together!"),
          L("行，这波不亏。", "Alright, sounds good.") },
    },

    wormwood_woodie = {
        { L("你在砍朋友。", "You are chopping friends."),
          L("我挑着砍，放心。", "I pick 'em careful.") },

        { L("树会再长。没事。", "Trees grow again. It's okay."),
          L("听你这么说，我心里踏实点。", "That helps me feel better.") },

        { L("你动作很快。", "You move fast."),
          L("干久了，自然快。", "Comes with practice.") },

        { L("不要太多。", "Not too many."),
          L("我有分寸，嗯。", "I know the limit, eh.") },

        { L("地很好。树会回来。", "Soil is good. Trees return."),
          L("那就行，这片林子还有救。", "Good. Woods'll be fine.") },
    },

    warly_woodie = {
        { L("你的木柴质量不错。", "Your firewood is good quality."),
          L("那是当然，我挑过的。", "Course it is. I pick 'em.") },

        { L("这些木头烧得很均匀。", "These logs burn evenly."),
          L("干活讲究点，总没错。", "Do it right, can't go wrong.") },

        { L("你对木材很挑剔。", "You're very particular about wood."),
          L("这活儿不能凑合。", "Can't cut corners here.") },

        { L("厨房需要稳定的火。", "The kitchen needs steady fire."),
          L("那我给你稳住了。", "I'll keep it steady.") },

        { L("我们配合得不错。", "We work well together."),
          L("一个砍，一个烧，正好。", "One chops, one cooks.") },
    },

    waxwell_woodie = {
        { L("你似乎乐在其中。", "You seem to enjoy this."),
          L("干惯了，也就顺手了。", "Get used to it.") },

        { L("你对这种重复不感到厌倦？", "You don't tire of repetition?"),
          L("比折腾那些影子强。", "Better than messin' with shadows.") },

        { L("你的世界，很简单。", "Your world is simple."),
          L("简单点挺好，不累。", "Simple's easier.") },

        { L("你对这片树林，有某种执念。", "You have an attachment to these woods."),
          L("待久了，总有点感情。", "Spend time here, you get attached.") },

        { L("你的斧头，很吵。", "Your axe is quite loud."),
          L("她爱说话，你忍忍吧。", "She talks. You'll manage.") },
    },
    willow_wilson = {
        { L("无聊，我们烧点东西吧？", "Bored. Wanna burn something?"),
          L("理论上…不建议这么做。", "Theoretically... not recommended.") },

        { L("科学能解释火为什么这么好玩吗？", "Science explain why fire is fun?"),
          L("呃…多巴胺？", "Uh... dopamine?") },
    },

    willow_wendy = {
        { L("你那气氛，配点火刚好。", "Your vibe could use some fire."),
          L("…烧掉以后，会更安静吗…", "...Would it be quieter after...") },

        { L("要不要看点亮的东西？", "Wanna see something light up?"),
          L("…短暂的光而已…", "...Just a brief light...") },
    },

    willow_wathgrithr = {
        { L("你打架，我点火，完美。", "You fight, I burn. Perfect."),
          L("火焰亦是战斗的号角！", "Flames are the call to battle!") },

        { L("你会介意我把战场点着吗？", "Mind if I light the battlefield?"),
          L("若为荣耀之战，无所畏惧！", "If for glory, I fear nothing!") },
    },

    willow_wolfgang = {
        { L("你力气大，帮我搬点能烧的？", "You're strong, carry stuff to burn?"),
          L("沃尔夫冈可以！但不要烧太多！", "Wolfgang can! But not too much!") },

        { L("你怕火吗？", "You scared of fire?"),
          L("沃尔夫冈…有一点点。", "Wolfgang... a little.") },
    },

    willow_wormwood = {
        { L("这些树，看着很好烧。", "These trees look very burnable."),
          L("不可以。朋友。", "No. Friends.") },

        { L("就烧一点点？", "Just a little?"),
          L("一点也不行。", "Not even a little.") },
    },

    willow_warly = {
        { L("你做饭，我点火，我们合作。", "You cook, I burn. Teamwork."),
          L("请不要把厨房也算进去。", "Please don't include the kitchen.") },

        { L("火候不够？我来加点。", "Not enough heat? I can help."),
          L("谢谢，不需要那种“帮助”。", "Thank you, but not that kind.") },
    },

    willow_waxwell = {
        { L("你的影子会不会烧？", "Do your shadows burn?"),
          L("别做无谓的尝试。", "Don't try anything foolish.") },

        { L("你看起来也挺容易着的。", "You look flammable too."),
          L("你最好收敛一点。", "You'd better behave.") },
    },

    willow_woodie = {
        { L("你砍，我烧，效率拉满。", "You chop, I burn. Efficient."),
          L("咱俩可不是一队的，老妹。", "We're not a team for that, eh.") },
        { L("你这些木头，不烧可惜了。", "These logs deserve a fire."),
          L("那是用来干活的，不是给你玩的。", "They're for work, not play.") },
    },
    wilson_willow = {
        { L("你对火的兴趣…有点过头了。", "Your interest in fire is... excessive."),
          L("那是因为你不够无聊。", "That's because you're not bored enough.") },
    },
    willow_wes = {
        { L("你不说话，是不是在憋坏主意？", "You don't talk... plotting something?"),
          L("*耸肩，做无辜表情*", "*shrugs innocently*") },
        { L("要不要一起干点“有意思”的事？", "Wanna do something... fun?"),
          L("*点头，然后假装点火*", "*nods, mimes lighting a fire*") },
        { L("你肯定懂我，对吧？", "You get me, right?"),
          L("*疯狂点头*", "*nods rapidly*") },
        { L("无聊死了，我们烧点什么。", "So boring. Let's burn something."),
          L("*比划爆炸，然后鼓掌*", "*mimes explosion, claps*") },
        { L("你要是会说话，肯定更危险。", "If you could talk, you'd be dangerous."),
          L("*得意鞠躬*", "*takes a proud bow*") },
    },

    wendy_willow = {
        { L("火光…很快就会消失…", "Firelight fades quickly..."),
          L("但点起来那一刻很好看。", "But it's great while it lasts.") },
    },

    wathgrithr_willow = {
        { L("你的火焰，有战斗的气息！", "Your flames carry battle spirit!"),
          L("我只是觉得好玩。", "I just think it's fun.") },
    },

    wolfgang_willow = {
        { L("不要烧太多东西，好吗？", "Don't burn too much, okay?"),
          L("我尽量…但不保证。", "I'll try... no promises.") },
    },

    wormwood_willow = {
        { L("不要烧朋友。", "Do not burn friends."),
          L("那就烧别的。", "Then I'll burn something else.") },
    },

    warly_willow = {
        { L("火是工具，不是玩具。", "Fire is a tool, not a toy."),
          L("对我来说都一样。", "Same thing to me.") },
    },

    waxwell_willow = {
        { L("你太容易失控。", "You lack control."),
          L("失控才有意思。", "That's what makes it fun.") },
    },

    woodie_willow = {
        { L("别动我的木头。", "Don't touch my wood."),
          L("那你看紧点。", "Then keep an eye on it.") },
    },
    wes_willow = {
        { L("*指着一堆东西，比划点火*", "*points at stuff, mimes lighting it*"),
          L("你在怂恿我？我喜欢。", "Encouraging me? I like that.") },
        { L("*做出火焰舞动的动作*", "*mimes dancing flames*"),
          L("哇，这想法不错。", "Oh, that's a good one.") },
        { L("*装作被火烧，夸张倒地*", "*pretends to burn, falls dramatically*"),
          L("放心，我会烧得更好看。", "Relax, I'll make it look better.") },
        { L("*比划“嘘”，然后偷偷点火*", "*shushes, then mimes sneaky fire*"),
          L("嘿，我也是这么想的。", "Hey, same idea.") },
        { L("*指向你，又指向火，再点头*", "*points at you, then fire, nods*"),
          L("行，一起搞点事。", "Alright, let's cause some trouble.") },
    },

    -- Wickerbottom 主动 → 其他角色

    wickerbottom_wilson = {
        { L("威尔逊，求知欲固然可贵，但请别把营地也当作实验台。", "Wilson, curiosity is admirable, but kindly refrain from treating the camp as a laboratory bench."),
          L("我尽量，不过你也知道，科学总得找地方发生。", "I'll try, though as you know, science insists on happening somewhere.") },
        { L("你的推论方向尚可，只是论证过程仍显仓促。", "Your line of reasoning is acceptable, though your method remains somewhat rushed."),
          L("从你嘴里听到“尚可”，我已经很受鼓舞了。", "Coming from you, 'acceptable' feels like high praise.") },
        { L("知识不是堆砌术语，而是建立清晰的结构。", "Knowledge is not the piling up of terminology, but the building of a coherent structure."),
          L("记下了。我会努力让我的混乱显得更有条理。", "Noted. I'll do my best to make my chaos look more organized.") },
        { L("你若再把样本和晚餐放在一起，我会十分不赞同。", "If you store specimens beside supper again, I shall strongly disapprove."),
          L("公平。上次那事确实不算我的收纳巅峰。", "Fair. That was not my finest moment in organization.") },
        { L("你确实聪明，威尔逊，只是还欠些耐性。", "You are indeed clever, Wilson. You merely lack patience."),
          L("这评价听起来像一张及格但不漂亮的成绩单。", "That sounds like a passing grade with very stern handwriting.") },
    },

    wickerbottom_wendy = {
        { L("温蒂，忧郁可以理解，但不宜沉溺过深。", "Wendy, sorrow is understandable, but one should not sink too deeply into it."),
          L("…有些情绪，不是想离开就能离开的…", "...Some feelings do not leave merely because one asks them to...") },
        { L("你看事物的方式过于悲观，却并非毫无洞见。", "Your view of things is overly bleak, though not without insight."),
          L("…至少你没有说我全错了…", "...At least you didn't say I was entirely wrong...") },
        { L("诗意并不等于软弱，切莫弄混。", "Poetry is not weakness. Do not confuse the two."),
          L("…原来你也懂这种事…", "...So you understand such things too...") },
        { L("你若愿意多读些书，或许能给你的思绪找到出口。", "If you were willing to read more, you might find your thoughts an outlet."),
          L("…书页会比人更安静一些…这倒不错…", "...Pages are quieter than people... that does sound nice...") },
        { L("你的沉默并不空洞，只是太容易让人误解。", "Your silence is not empty. It is simply too easily misunderstood."),
          L("…被误解久了，也就懒得解释了…", "...After enough misunderstanding, one grows tired of explaining...") },
    },

    wickerbottom_wathgrithr = {
        { L("薇格弗德，音量并不能替代论证。", "Wigfrid, volume does not substitute for argument."),
          L("但它能让论证更有气势！", "But it does lend an argument grandeur!") },
        { L("你的热情值得称赞，只是表达方式略嫌夸张。", "Your passion is commendable, though your mode of expression is somewhat excessive."),
          L("英雄的言辞，本就不该平淡无奇！", "A hero's speech should never be dull!") },
        { L("并非一切问题都需要靠挥剑解决。", "Not every problem requires a sword."),
          L("或许不是一切，但许多问题确实如此！", "Perhaps not every one, but a great many certainly do!") },
        { L("我承认，你的行动力远胜多数空谈者。", "I will admit, your decisiveness surpasses that of most mere talkers."),
          L("哈哈！总算听见一句像样的夸奖！", "Ha! At last, a worthy compliment!") },
        { L("若你肯稍微收敛戏剧腔，我会更容易同你讨论。", "If you moderated the theatricality a little, discussion might proceed more smoothly."),
          L("绝无可能！那可是灵魂所在！", "Never! It is the soul of the matter!") },
    },

    wickerbottom_wolfgang = {
        { L("沃尔夫冈，蛮力固然实用，但思考也同样重要。", "Wolfgang, brute strength is useful, but thinking is no less important."),
          L("沃尔夫冈会想！只是想得没有拳头快！", "Wolfgang does think! Just not as fast as fists!") },
        { L("你比你自以为的要敏锐得多。", "You are far more perceptive than you believe."),
          L("真的？沃尔夫冈喜欢这个说法！", "Really? Wolfgang likes that!") },
        { L("若你肯稍慢一些，我可以把事情讲得更清楚。", "If you slowed down a little, I could explain matters more clearly."),
          L("好！老奶奶慢慢说，沃尔夫冈认真听！", "Okay! Old lady talk slowly, Wolfgang listen hard!") },
        { L("害怕黑暗并不可耻，承认它反而更诚实。", "There is no shame in fearing the dark. Admitting it is more honest."),
          L("那…沃尔夫冈就是诚实的强壮人。", "Then... Wolfgang is honest strong man.") },
        { L("你并不愚钝，只是过分直率。", "You are not dull. Merely very direct."),
          L("直一点省事！沃尔夫冈喜欢省事！", "Direct is easier! Wolfgang likes easier!") },
    },

    wickerbottom_wormwood = {
        { L("你对植物的理解，实在令人印象深刻。", "Your understanding of plant life is truly impressive."),
          L("植物会说。老奶奶也听吗？", "Plants talk. Old lady hears too?") },
        { L("你观察自然的方式，比许多学者都更纯粹。", "Your way of observing nature is purer than that of many scholars."),
          L("植物人只是看，看很久。", "Wormwood just looks. Looks a long time.") },
        { L("你让我明白，知识并不总需写在纸上。", "You remind me that knowledge need not always be written on paper."),
          L("可以写在叶子上。", "Can write on leaves.") },
        { L("我得承认，你比大多数园艺手册都更有用。", "I must admit, you are more useful than most horticultural manuals."),
          L("手册会长花吗？", "Do manuals grow flowers?") },
        { L("你对生命的珍视，很值得尊重。", "Your regard for life is worthy of respect."),
          L("朋友会长大，要轻一点。", "Friends grow. Must be gentle.") },
    },

    wickerbottom_warly = {
        { L("沃利，你对秩序的讲究颇有图书馆风范。", "Warly, your devotion to order is positively library-like."),
          L("而你的书架管理，想必也和我的冰箱一样严格。", "And I imagine your shelves are managed as strictly as my iceboxes.") },
        { L("烹饪与治学，看来都离不开精确。", "It seems both cooking and scholarship rely upon precision."),
          L("正是如此。差一点火候，就像差一页注释。", "Precisely. A little error in heat is much like a missing annotation.") },
        { L("我欣赏你对细节的坚持。", "I appreciate your insistence on details."),
          L("细节决定结果，这点在锅里尤其明显。", "Details determine the result, especially in a pot.") },
        { L("你处理食材的态度，近乎某种学术伦理。", "Your treatment of ingredients borders on an academic ethic."),
          L("好材料值得认真对待，这本就是常识。", "Good ingredients deserve seriousness. That is only common sense.") },
        { L("你的厨房，大概是营地里少数能让我安心的地方。", "Your kitchen may be one of the few places in camp that gives me peace of mind."),
          L("多谢。那我会尽量不让人把书和洋葱放在一起。", "Thank you. Then I shall continue preventing books from being stored with onions.") },
    },

    wickerbottom_waxwell = {
        { L("麦斯威尔，傲慢并不能替代修养。", "Maxwell, arrogance is not a substitute for refinement."),
          L("而说教也不等于智慧，老太太。", "And lecturing does not equal wisdom, madam.") },
        { L("你确实见多识广，只可惜常用错地方。", "You are undeniably knowledgeable, though you often apply it poorly."),
          L("我倒觉得，结果才是衡量手段的标准。", "I tend to think results are what justify methods.") },
        { L("你说话总像在给别人设圈套。", "You speak as though every sentence were laying a trap."),
          L("那说明你足够聪明，能察觉得到。", "Then you are clever enough to notice.") },
        { L("礼貌不是装饰，而是底线。", "Politeness is not decoration. It is a minimum standard."),
          L("可惜这世上很少有人配得上它。", "Unfortunately, very few in this world deserve it.") },
        { L("若你少些轻蔑，旁人会更愿意听你说话。", "Were you less contemptuous, others might listen more willingly."),
          L("可我并不急着讨他们喜欢。", "I am in no hurry to earn their affection.") },
    },

    wickerbottom_wes = {
        { L("韦斯，虽然你沉默寡言，但并非毫无表达。", "Wes, though you are silent, you are by no means inexpressive."),
          L("*摘帽行礼*", "*tips hat politely*") },
        { L("你的肢体语言，倒比许多人的口才更清楚。", "Your physical language is clearer than many people's speech."),
          L("*认真点头*", "*nods earnestly*") },
        { L("至少你不会随意打断别人，这是难得的优点。", "At least you do not interrupt. That is an uncommon virtue."),
          L("*摊手微笑*", "*shrugs and smiles*") },
        { L("我欣赏你的分寸感。", "I appreciate your sense of measure."),
          L("*轻轻鞠躬*", "*gives a small bow*") },
        { L("你的幽默感，有时比文字还有效。", "At times, your sense of humor is more effective than words."),
          L("*夸张谢幕*", "*dramatic curtain call*") },
    },

    wickerbottom_woodie = {
        { L("伍迪，你对树木的情感已经近乎个人信仰了。", "Woodie, your attachment to trees borders on personal doctrine."),
          L("嘿，树值得认真对待，这没啥不对。", "Hey, trees deserve respect. Nothing wrong with that.") },
        { L("你的经验主义相当扎实，只是缺了些术语。", "Your practical knowledge is quite solid. It merely lacks terminology."),
          L("我砍树，不写论文，老太太。", "I chop trees, I don't write papers, ma'am.") },
        { L("你看着随意，实际上比许多人可靠得多。", "You appear casual, but you are more reliable than most."),
          L("这话我收下了，听着还挺顺耳。", "I'll take that. Sounds pretty good, eh.") },
        { L("与其说你是伐木工，不如说你是经验派自然观察者。", "Rather than a lumberjack, I might call you a practical observer of nature."),
          L("这名字可真长，不过听着挺体面。", "That's a mouthful, but it sounds respectable.") },
        { L("你若少些碎嘴，形象会更庄重些。", "If you talked a little less, you might seem more dignified."),
          L("那可不成，安静干活太闷啦。", "Can't do that. Quiet work's too dull.") },
    },

    wickerbottom_willow = {
        { L("薇洛，火焰不是玩具，这一点你应当明白。", "Willow, fire is not a toy. You ought to understand that."),
          L("我当然明白，我只是觉得它很好玩。", "I understand perfectly. I just think it's fun.") },
        { L("你对火的痴迷，已然超出正常兴趣范围。", "Your fascination with fire exceeds any reasonable notion of interest."),
          L("那说明我很有热情。", "That just means I'm passionate.") },
        { L("请至少在放火前考虑一下后果。", "Please, at minimum, consider consequences before setting anything ablaze."),
          L("我会考虑的。大概三秒。", "I will. For about three seconds.") },
        { L("冲动若缺少节制，往往只会制造混乱。", "Impulse without restraint usually produces only disorder."),
          L("有时候混乱才比较有意思。", "Sometimes disorder is more interesting.") },
        { L("你并非没有才智，只是太爱惹事。", "You are not without intelligence. You are merely too fond of trouble."),
          L("哎呀，被你发现了。", "Oh dear, you've noticed.") },
    },

    -- 其他角色主动 → Wickerbottom

    wilson_wickerbottom = {
        { L("薇克巴顿女士，你总让我觉得自己还差很多。", "Ms. Wickerbottom, you always make me feel I have much left to learn."),
          L("意识到不足，本就是求知的开端。", "Recognizing one's inadequacies is itself the beginning of learning.") },
        { L("我有时怀疑，你是不是把整座图书馆都背下来了。", "I sometimes suspect you've memorized an entire library."),
          L("并没有全部，不过相当可观。", "Not the entirety, though a considerable portion.") },
        { L("你纠正我用词的时候，总让我有点紧张。", "You always make me a little nervous when you correct my word choice."),
          L("那是因为词语本应被准确使用。", "That is because words ought to be used accurately.") },
        { L("说真的，你的笔记一定很厉害。", "Honestly, your notes must be incredible."),
          L("它们至少比大多数人的要整洁。", "They are, at the very least, tidier than most.") },
        { L("跟你聊天总像在上高级课程。", "Talking with you always feels like an advanced lesson."),
          L("那就说明你至少还在认真听讲。", "Then it appears you are at least listening attentively.") },
    },

    wendy_wickerbottom = {
        { L("你说话的时候，像旧书页一样稳。", "When you speak, you feel as steady as old pages."),
          L("这是个颇为得体的比喻，我接受。", "That is a rather proper comparison. I accept it.") },
        { L("你懂很多，却不像别人那样急着炫耀。", "You know much, yet do not rush to flaunt it like others."),
          L("知识若只是用来炫耀，那未免太浅薄了。", "If knowledge serves only vanity, it is being used shallowly.") },
        { L("有时候我觉得，你比大多数人更不怕孤独。", "Sometimes I think you fear loneliness less than most people."),
          L("书籍和思考，足以让独处不至空洞。", "Books and thought are enough to keep solitude from becoming empty.") },
        { L("你会不会也有不想翻开的那一页？", "Do you ever have a page you would rather not turn?"),
          L("自然会有。只是停下不读，并不能改变内容。", "Naturally. But refusing to continue does not alter the text.") },
        { L("你总像知道该怎么让人站稳一点。", "You always seem to know how to help people stand a little steadier."),
          L("有时候，只需一句不夸张的话即可。", "At times, a single unexaggerated sentence suffices.") },
    },

    wathgrithr_wickerbottom = {
        { L("博学之士！你的言语，竟也有刀锋之力！", "Learned one! Even your words carry the edge of a blade!"),
          L("感谢夸奖，不过我更偏好“措辞精确”。", "Thank you, though I prefer the term 'precisely phrased.'") },
        { L("你虽不高歌，却自有威严！", "Though you do not sing loudly, you possess your own authority!"),
          L("音量并非威严的必要条件。", "Volume is not a prerequisite for authority.") },
        { L("你的书卷智慧，可否也教人征战？", "Can your bookish wisdom also teach one to wage war?"),
          L("当然。历史里最不缺的，恰恰就是战争的教训。", "Certainly. History is exceedingly rich in lessons on war.") },
        { L("你那责备人的目光，连战士都会收敛几分！", "Even warriors grow restrained beneath your reproving gaze!"),
          L("那说明目光比吼叫更有效。", "Then perhaps a look is more effective than shouting.") },
        { L("你若写史诗，必定气势不凡！", "Were you to compose an epic, it would surely be magnificent!"),
          L("我更可能写注释，不过也未必不能兼顾。", "I am more likely to write annotations, though the two need not be exclusive.") },
    },

    wolfgang_wickerbottom = {
        { L("老奶奶懂好多，沃尔夫冈觉得好厉害。", "Old lady knows so much. Wolfgang thinks that's amazing."),
          L("多读、多记、多想，你也能掌握更多。", "Read more, remember more, think more, and you will know more as well.") },
        { L("你说的话有时候好难，但听起来很对。", "Sometimes your words are hard, but they sound very right."),
          L("意思清楚即可，词句以后可以慢慢学。", "So long as the meaning reaches you, the phrasing can be learned in time.") },
        { L("老奶奶不凶的时候，像很聪明的火炉。", "When old lady isn't scolding, she's like a very smart stove."),
          L("这比喻相当古怪，但我姑且接受。", "That comparison is highly peculiar, but I shall permit it.") },
        { L("沃尔夫冈要是看书，会不会也变聪明？", "If Wolfgang reads books, will Wolfgang get smarter?"),
          L("自然。前提是你别把书拿去垫桌脚。", "Certainly. Provided you do not use them to level tables.") },
        { L("你讲话像敲钟，慢慢的，但很响。", "You talk like a bell. Slow, but loud in head."),
          L("这评价倒有几分诗意。", "That observation is unexpectedly poetic.") },
    },

    wormwood_wickerbottom = {
        { L("老奶奶像老树。知道很多。", "Old lady like old tree. Knows many things."),
          L("这是个相当高雅的夸奖。谢谢你。", "That is a remarkably elegant compliment. Thank you.") },
        { L("书里有小草吗？", "Books have little grass inside?"),
          L("有关于草的知识，虽然不如真正的草柔软。", "They contain knowledge of grass, though admittedly less soft than the real thing.") },
        { L("你会写字，像在种字。", "You write words like planting them."),
          L("而你说得没错，文字也确实需要被妥善培育。", "You are not wrong. Words, too, require proper cultivation.") },
        { L("老奶奶懂好多朋友。树朋友，花朋友。", "Old lady knows many friends. Tree friends, flower friends."),
          L("我不过是认真读过关于它们的内容。", "I have merely read about them with due attention.") },
        { L("你轻轻摸书，像植物人摸叶子。", "You touch books like Wormwood touches leaves."),
          L("值得珍惜之物，本就该轻拿轻放。", "Things worthy of care ought to be handled gently.") },
    },

    warly_wickerbottom = {
        { L("你整理书架的样子，让我想起我整理香料的时候。", "The way you sort shelves reminds me of how I arrange spices."),
          L("二者都需要分类、秩序，以及足够的耐心。", "Both require classification, order, and a fair amount of patience.") },
        { L("你对准确的坚持，与我对火候的坚持颇有共通之处。", "Your insistence on accuracy has much in common with my insistence on proper heat."),
          L("这说明严谨并非某一门学问的专利。", "Indeed. Rigor is no monopoly of any single discipline.") },
        { L("若你愿意，我很想为你做一道配得上阅读时光的点心。", "If you would allow it, I'd like to prepare something worthy of your reading hours."),
          L("只要别让碎屑落进书页之间，我会很乐意。", "So long as crumbs do not find their way between pages, I would be delighted.") },
        { L("你批注书页的样子，和我修整菜单时一样认真。", "The way you annotate pages resembles the way I refine a menu."),
          L("认真修订，本就是避免愚蠢错误的最好方式。", "Careful revision is the finest defense against foolish errors.") },
        { L("我总觉得，你会是最能理解“细节决定成败”的人。", "I always felt you would be the one to understand that details determine the outcome."),
          L("当然。忽略细节，便等于邀请失败入内。", "Naturally. To ignore detail is to invite failure in.") },
    },

    waxwell_wickerbottom = {
        { L("你看人的眼神，总像已经替他们下了结论。", "You look at people as though you've already concluded everything about them."),
          L("并非如此。我只是比大多数人更快看出问题所在。", "Not at all. I merely identify flaws more quickly than most.") },
        { L("你我都懂得知识的分量，只是立场不同。", "You and I both understand the weight of knowledge. We merely differ in stance."),
          L("立场往往正是决定品格的关键。", "Stance is often precisely what reveals character.") },
        { L("你对我的评价，恐怕从来不算温和。", "I imagine your assessments of me are rarely gentle."),
          L("准确比温和更重要。", "Accuracy is more important than gentleness.") },
        { L("你倒是少见地，不会被表象轻易蒙骗。", "You are unusual in that appearances do not easily deceive you."),
          L("那是因为我一向更看重内容。", "That is because I have always valued substance over display.") },
        { L("你不喜欢我，我能理解。", "You dislike me. That I can understand."),
          L("“不赞同”比“不喜欢”更精确。", "'Disapprove' is more precise than 'dislike.'") },
    },

    wes_wickerbottom = {
        { L("*小心递来一本书*", "*carefully offers a book*"),
          L("谢谢。你至少懂得如何善待一本书。", "Thank you. At least you understand how to treat a book properly.") },
        { L("*比划安静翻页*", "*mimes turning pages quietly*"),
          L("很好。阅读本就不需要喧哗。", "Quite right. Reading has no need of noise.") },
        { L("*做出夸张讲课姿势*", "*mimes an overdramatic lecture pose*"),
          L("嗯，你的模仿倒是抓到了几分神韵。", "Hm. Your impression does capture a few essentials.") },
        { L("*指着自己，再指书，然后认真点头*", "*points to self, then to book, and nods earnestly*"),
          L("是的，书的确值得信赖得多。", "Yes, books are indeed far more dependable.") },
        { L("*端正站好，像在等待点名*", "*stands straight as if awaiting roll call*"),
          L("你若在课堂上也有这般纪律，想必会很省心。", "Had you shown such discipline in a classroom, you would have been a delight.") },
    },

    woodie_wickerbottom = {
        { L("老太太，你懂的东西真多得吓人。", "Ma'am, you know a downright frightening amount."),
          L("那只是长期阅读的自然结果。", "That is merely the natural result of long study.") },
        { L("你总能把简单事说得特别正式。", "You always manage to make simple things sound formal."),
          L("那是因为措辞准确，本就不该过于随便。", "That is because precision in language ought not be casual.") },
        { L("你看树的眼神，跟我看树差不多认真。", "You look at trees almost as seriously as I do."),
          L("值得尊重之物，自然应被认真看待。", "Anything worthy of respect deserves serious attention.") },
        { L("说真的，你像本会走路的百科全书。", "Honestly, you're like a walking encyclopedia."),
          L("比起某些人，我至少更安静些。", "Unlike certain others, I am at least somewhat quieter.") },
        { L("要是你来写伐木手册，估计能有三大本。", "If you wrote a lumber manual, it'd probably be three volumes long."),
          L("若真有必要，三卷恐怕还只是提纲。", "If the subject warranted it, three volumes might only be an outline.") },
    },

    willow_wickerbottom = {
        { L("你老是教育人，不会累吗？", "Do you never tire of correcting people?"),
          L("若错误层出不穷，纠正自然也难以停止。", "If errors persist endlessly, correction must also persist.") },
        { L("你是不是从来没干过什么出格的事？", "Have you never done anything reckless in your life?"),
          L("自然做过，只是从不以此为荣。", "Certainly I have, though never with pride.") },
        { L("你一皱眉，我就觉得自己又要挨训了。", "Whenever you frown, I feel like I'm about to be scolded."),
          L("这说明你的预感至少还算敏锐。", "That suggests your instincts are at least somewhat sound.") },
        { L("你就不能偶尔觉得放火也挺有趣？", "Can you never admit that fire is sometimes fun?"),
          L("我承认它有用途，但“有趣”不是首要评价。", "I concede its usefulness. 'Fun,' however, is not the foremost category.") },
        { L("你总让我觉得自己像个坏学生。", "You always make me feel like a bad student."),
          L("那就尽量别总做出需要被批评的事。", "Then do try not to behave so consistently as one.") },
    },
        -- Warly + Winona: 
        warly_winona = {
          { L("薇诺娜，你的手很稳，切配时一定也很利落。", "Winona, your hands are steady. I imagine your knife work would be quite precise."),
            L("我更擅长拧螺丝，不太擅长切萝卜。", "I'm better with screws than carrots, honestly.") },
          { L("这些锅架你是怎么搭稳的？看着挺结实。", "How'd you brace these cooking racks? They look sturdy."),
            L("重心放低，再给受力点留余地。料理和工程都怕塌。", "Keep the center of gravity low and leave room at the stress points. Cooking and engineering both hate collapse.") },
          { L("一顿好饭能让人心情好不少。", "A proper meal can improve morale quite a bit."),
            L("一张牢靠的桌子也一样，至少吃饭时不会翻。", "So can a sturdy table. At least dinner won't end up on the floor.") },
      },
  
      -- Wathgrithr + Winona: 
      wathgrithr_winona = {
          { L("你的锤子不错！像个真正战士的武器！", "Your hammer is fine indeed! A true warrior's weapon!"),
            L("它主要是拿来修东西的，不过砸东西也一样顺手。", "Mostly for fixing things, but it works just fine for smashing too.") },
          { L("你每次都冲那么快，不怕把东西撞坏吗？", "You charge in that fast every time. Aren't you worried you'll break something?"),
            L("哈！战斗哪有不碎东西的道理！", "Ha! What is battle if nothing gets broken!") },
          { L("若你愿意，我可赐你一首战歌！", "If you wish it, I shall grant you a battle song!"),
            L("你唱吧，我负责把营地钉牢，省得被你震散。", "You sing, and I'll keep the camp nailed together so it doesn't shake apart.") },
      },
  
      -- Waxwell + Winona: 
      waxwell_winona = {
          { L("真令人意外，你竟能把这些破铜烂铁拼成有用的东西。", "How surprising. You manage to make something useful from utter scrap."),
            L("总比把话说得漂亮却什么都不做强。", "Better than talking fancy and building nothing.") },
          { L("你那些暗影仆从倒是省力，就是不太让人放心。", "Those shadow workers of yours save effort, but they sure don't inspire confidence."),
            L("信任从不是效率的一部分。结果才是。", "Trust has never been part of efficiency. Results are.") },
          { L("若你肯学点实在的手艺，很多事能省不少麻烦。", "You'd save yourself a lot of trouble if you learned a practical skill or two."),
            L("我的天赋，不需要靠拧螺栓来证明。", "My talents do not require validation through bolts and hinges.") },
      },
  
      -- Wes + Winona: 
      wes_winona = {
          { L("（比划了一个敲敲打打的动作）", "(mimes hammering something together)"),
            L("对，就是这么干。你学得还挺快。", "Yeah, that's the idea. You're catching on fast.") },
          { L("你不说话也能把意思说明白，挺厉害。", "You get your point across without saying a word. That's impressive."),
            L("（得意地鞠了一躬）", "(takes a proud bow)") },
          { L("要不要帮我递个零件？不用开口，我看得懂。", "Want to hand me that part? No need to talk, I can follow."),
            L("（立刻递上，还比了个夸张的“请”）", "(hands it over at once, then gestures grandly: 'after you')") },
      },
  
      -- Wickerbottom + Winona: 
      wickerbottom_winona = {
          { L("你的结构搭建思路，颇有实用主义之美。", "Your structural designs possess a certain pragmatic elegance."),
            L("听起来像夸奖，那我就收下了。", "Sounds like praise to me. I'll take it.") },
          { L("书上会写怎么让屋顶别漏雨吗？", "Do books say much about keeping a roof from leaking?"),
            L("优秀的书籍会，拙劣的工匠手册则未必。", "Good books do. Inferior manuals, regrettably, may not.") },
          { L("知识要是不能拿来解决问题，那可太浪费了。", "If knowledge can't solve a problem, that's a waste of good knowledge."),
            L("相当正确。学问若不能落地，便只是空谈。", "Quite right. Learning that cannot be applied is mere ornament.") },
      },
  
      -- Willow + Winona: 
      willow_winona = {
          { L("嘿，薇诺娜，你搭的东西烧起来会是什么样？", "Hey, Winona, what do your constructions look like when they're on fire?"),
            L("通常我会尽量别让它们走到那一步。", "I generally try not to let them get to that stage.") },
          { L("你离我的木板和绳子远一点，我会轻松很多。", "I'd feel a lot better if you stayed away from my boards and rope."),
            L("哈，那不就少了很多乐趣吗？", "Ha! Wouldn't that take all the fun out of it?") },
          { L("火确实有用，但最好待在炉子里。", "Fire's useful, sure, but it belongs in the furnace."),
            L("你这人真会挑最无聊的用法。", "You always pick the most boring use for it.") },
      },
  
      -- Wilson + Winona: 
      wilson_winona = {
          { L("薇诺娜，你在受力结构方面的直觉相当惊人。", "Winona, your intuition for load-bearing structures is remarkable."),
            L("我一般不叫它直觉，我叫它别让东西砸到自己。", "I don't usually call it intuition. I call it not getting crushed.") },
          { L("你要是少点纸上谈兵，手上活会快很多。", "You'd get more done if you spent less time theorizing and more time working."),
            L("理论是实践的前导步骤！虽然……偶尔确实有点长。", "Theory is the prelude to practice! Though... sometimes an unusually long one.") },
          { L("我们合作的话，效率应该会很高。", "If we worked together, we'd probably be very efficient."),
            L("你负责算，我负责让它真的别散架。", "You do the math, and I'll make sure it doesn't actually fall apart.") },
      },
  
      -- Wendy + Winona: 
      wendy_winona = {
          { L("你总是在修东西……像是在和坏掉的世界较劲。", "You're always fixing things... like you're arguing with a broken world."),
            L("总得有人动手，不然它只会越来越烂。", "Somebody's got to put hands on it, or it only gets worse.") },
          { L("你看起来很累。要不要先坐会儿？", "You look tired. Want to sit down a minute?"),
            L("……谢谢。有人这么说，倒还挺少见。", "...Thanks. Not many people say that.") },
          { L("有些东西修不好，不是你的错。", "Some things can't be fixed. That isn't your fault."),
            L("我知道。可要是不试试，我心里过不去。", "I know. Still, if I don't try, it sits wrong with me.") },
      },
  
      -- Winona + Wolfgang: 
      wolfgang_winona = {
          { L("沃尔夫冈力气大！可以帮你搬东西！", "Wolfgang is strong! Wolfgang can help carry things!"),
            L("那可太好了，大块头力气本来就该用在正地方。", "Now that's useful. Good strength ought to be put to good work.") },
          { L("这根梁你能抬一下吗？我得把底座卡进去。", "Can you lift this beam a little? I need to fit the base under it."),
            L("没问题！沃尔夫冈最会抬大东西！", "No problem! Wolfgang is best at lifting big things!") },
          { L("你可真厉害，什么都能修。", "You are very impressive. You can fix so many things."),
            L("你也不差，至少很多重活没你是真不行。", "You're not bad yourself. Half the heavy work doesn't happen without you.") },
      },
  
      -- Woodie + Winona: 
      woodie_winona = {
          { L("你这搭架子的手法不错啊，姑娘。", "You're pretty handy with framing, huh?"),
            L("你砍木头也挺稳，咱俩活儿算能接上。", "And you cut straight. Our jobs fit together pretty well.") },
          { L("这批木料不错，纹理顺，做支架正合适。", "This batch of timber's good. Straight grain, perfect for supports."),
            L("我就喜欢听这种话，说明没白砍。", "Now that's what I like to hear. Means the chopping paid off.") },
          { L("你要是别老把树全放倒，我修起来会更省心。", "I'd have an easier time building if you didn't drop every tree in sight."),
            L("嘿，我已经算克制了，真的。", "Hey, I *am* showing restraint. Honest.") },
      },
  
      -- Wormwood + Winona: 
      wormwood_winona = {
          { L("你敲敲打打。地会痛吗？", "You hammer and build. Does the ground hurt?"),
            L("我会尽量轻一点，也尽量别浪费材料。", "I try to be gentle, and I try not to waste what I use.") },
          { L("这些木板以前也是活的。我知道。", "These boards were alive before. I know that."),
            L("……是啊。所以能用好的话，我不想随便糟蹋。", "...Yeah. That's why I don't like wasting them.") },
          { L("小树苗旁边。不要压到。", "By the little sprout. Do not step on it."),
            L("看见了，我绕开走。谢了，提醒得好。", "Got it. I'll go around. Good catch.") },
      },
      winona_wilson = {
        { L("威尔逊，你要是少发会儿呆，活能快不少。", "Wilson, if you spent less time staring off, work would go a lot faster."),
          L("我那不是发呆，我是在思考！", "I wasn't staring off, I was thinking!") },
    
        { L("你负责算尺寸，我负责让它别塌。", "You handle the measurements, I'll make sure it stays standing."),
          L("完美分工！科学与工程的结合！", "A perfect division of labor! Science and engineering together!") },
    
        { L("你那些笔记要是早点变成成品就好了。", "It'd be nice if your notes turned into something useful a little sooner."),
          L("发明总得先从纸上开始。", "Every invention has to start on paper.") },
    
        { L("别老盯着样本看，脚下的地板也很重要。", "Don't just stare at samples. The floor under your feet matters too."),
          L("你说得对，稳定的地板确实很重要。", "You're right. A stable floor is very important.") },
    },
    
    winona_wendy = {
        { L("温蒂，你老站在风口，不冷吗？", "Wendy, you stand in the wind a lot. Aren't you cold?"),
          L("……冷一点，反而更清醒。", "...Sometimes the cold makes things clearer.") },
    
        { L("你脸色不太好，要不要先歇会儿？", "You don't look too well. Want to rest a bit?"),
          L("……谢谢，你比看起来体贴。", "...Thank you. You're kinder than you look.") },
    
        { L("有些东西修不好，但总还能补一补。", "Some things can't be fixed fully, but they can still be patched."),
          L("……留下痕迹，也总比裂着好。", "...A patch leaves a mark, but that's better than staying broken.") },
    
        { L("你不想说话也没事，我在旁边干活就行。", "You don't have to talk. I can just work nearby."),
          L("……这样也好，安静一点挺好。", "...That's fine. Quiet is nice.") },
    },
    
    winona_wathgrithr = {
        { L("你每次冲这么快，就不怕把营地也拆了？", "You charge so hard every time. Aren't you worried you'll wreck the camp too?"),
          L("若营地不够结实，那便不配立着！", "If the camp isn't sturdy enough, then it doesn't deserve to stand!") },
    
        { L("你负责冲锋，我负责收拾后头。", "You handle the charge, I'll handle everything behind you."),
          L("好极了！你守后阵，我破前敌！", "Excellent! You hold the rear, I break the foe!") },
    
        { L("你那把武器，我迟早得给你加固一下。", "Sooner or later, I'm going to have to reinforce that weapon of yours."),
          L("若它折断，也该折在战斗里！", "If it breaks, let it break in battle!") },
    
        { L("你嗓门这么大，不拿来吓怪可惜了。", "That voice of yours is too loud not to use on monsters."),
          L("女武神的战吼，本就该震天动地！", "A Valkyrie's cry is meant to shake the heavens!") },
    },
    
    winona_wolfgang = {
        { L("沃尔夫冈，过来搭把手，这个我一个人抬不动。", "Wolfgang, give me a hand. I can't lift this by myself."),
          L("没问题！沃尔夫冈最会搬重东西！", "No problem! Wolfgang is best at lifting heavy things!") },
    
        { L("你抬着，我来固定，咱们配合一下。", "You hold it up, I'll secure it. Let's work together."),
          L("好！沃尔夫冈会站得很稳！", "Yes! Wolfgang will stand very steady!") },
    
        { L("你吃饱的时候，干活是真顶用。", "When you're well-fed, you're seriously useful."),
          L("吃饱的沃尔夫冈最厉害！", "A full Wolfgang is the strongest Wolfgang!") },
    
        { L("有你在，重活能省我不少力气。", "With you around, heavy work gets a lot easier."),
          L("薇诺娜聪明，沃尔夫冈有力气！", "Winona is smart, Wolfgang is strong!") },
    },
    
    winona_wormwood = {
        { L("沃姆伍德，我要在这儿干活，帮我看看别踩到小苗。", "Wormwood, I'm working here. Help me make sure I don't step on any sprouts."),
          L("好。小朋友们很重要。", "Okay. Little friends are important.") },
    
        { L("这些木头我会省着用，不会乱糟蹋。", "I'll use this wood carefully. I won't waste it."),
          L("嗯。那样很好。", "Mm. That is good.") },
    
        { L("哪儿有新长出来的，你记得提醒我。", "If you see anything newly growing, let me know."),
          L("会的。小东西也重要。", "I will. Small things matter too.") },
    
        { L("活儿归活儿，我会尽量轻一点。", "Work is work, but I'll try to be gentle."),
          L("这样很好。地会记得。", "That is good. The ground will remember.") },
    },
    
    winona_warly = {
        { L("沃利，你做饭讲究，我搭灶台也不能太糙。", "Warly, you're serious about cooking, so I shouldn't be sloppy with the stove."),
          L("一顿好饭，当然该配个像样的灶台。", "A fine meal deserves a proper stove.") },
    
        { L("你要是对高度有要求，现在就说。", "If you want a specific height, say it now."),
          L("想得周到，厨师可不想总弯着腰。", "Thoughtful. A chef should not have to stoop all the time.") },
    
        { L("你做饭，我搭台子，这分工挺合适。", "You cook, I build. That's a pretty good arrangement."),
          L("务实又体面，我很满意。", "Practical and proper. I approve.") },
    
        { L("吃上顿热饭，干一天活都值了。", "A hot meal makes a whole day's work worth it."),
          L("那我会尽量不让你失望。", "Then I shall do my best not to disappoint.") },
    },
    
    winona_waxwell = {
        { L("麦斯威尔，你站那儿摆样子，不如过来帮忙。", "Maxwell, instead of standing there posing, you could come help."),
          L("我的才能，不该浪费在体力活上。", "My talents are not meant for manual labor.") },
    
        { L("你那些暗影要是能搬东西，就别只会吓人。", "If your shadows can carry things, they should do more than lurk around."),
          L("它们只做我要求的事。", "They do exactly what I ask of them.") },
    
        { L("会说漂亮话的人，我见得多了。", "I've met plenty of people who talk pretty."),
          L("那你很幸运，今天碰上了真正有本事的。", "Then you're fortunate to be speaking with someone truly capable.") },
    
        { L("行吧，你负责神神叨叨，我负责让东西能用。", "Fine. You handle the spooky nonsense, I'll make things actually work."),
          L("说得粗鲁，但不算错。", "A crude way to put it, but not entirely wrong.") },
    },
    
    winona_wes = {
        { L("韦斯，你不说话我也看得懂。", "Wes, I can understand you just fine without words."),
          L("（轻轻点头）", "(nods gently)") },
    
        { L("帮我递下那个零件，就是你手边那个。", "Hand me that part, the one by your hand."),
          L("（立刻递过来，还顺手鞠了一躬）", "(hands it over immediately, then adds a bow)") },
    
        { L("你这人安安静静的，干活倒挺省心。", "You're quiet, which honestly makes work pretty easy."),
          L("（无声地笑了笑）", "(smiles silently)") },
    
        { L("你刚才那动作，是提醒我后面有东西？", "That gesture just now—were you warning me something was behind me?"),
          L("（连连点头）", "(nods quickly)") },
    },
    
    winona_woodie = {
        { L("伍迪，你挑木头的眼光是真不错。", "Woodie, you've got a real good eye for timber."),
          L("那当然，这可是老本行。", "Of course. That's my line of work.") },
    
        { L("这批木头挺直，拿来搭架子正合适。", "This batch is nice and straight. Good for framing."),
          L("我就知道你会看得出来。", "I knew you'd notice.") },
    
        { L("你要是别见树就砍，我后头能省不少事。", "If you didn't chop every tree in sight, it'd save me some trouble later."),
          L("嘿，我已经算很克制了。", "Hey, I'm showing plenty of restraint already.") },
    
        { L("下次砍之前先喊我一声，我好想怎么接着用。", "Next time, give me a heads-up before you chop. I like planning ahead."),
          L("行，这话说得在理。", "Fair enough. That makes sense.") },
    },
    
    winona_wickerbottom = {
        { L("薇克巴顿，你那些书里有讲怎么让屋顶更抗风吗？", "Wickerbottom, do your books say anything about making a roof withstand strong wind?"),
          L("自然有，而且不止一本。", "Certainly, and more than one.") },
    
        { L("我喜欢能落地的学问，写在书上可不够。", "I like knowledge you can put to use. It can't just stay in a book."),
          L("正是如此，学问若不能应用，便只是摆设。", "Quite so. Knowledge without use is mere decoration.") },
    
        { L("你要是肯帮我看看图纸，我能少返工不少。", "If you'd look over my plans, I could avoid a lot of rework."),
          L("我很乐意，纸上的错误总比实物便宜。", "Gladly. Errors on paper are always cheaper.") },
    
        { L("有时候我靠经验，你靠书本，合一起倒正好。", "Sometimes I go by experience, you go by books. Together, that works well."),
          L("实践与学识，本就该彼此补足。", "Practice and learning are meant to complement one another.") },
    },
    
    winona_willow = {
        { L("薇洛，你离我的木板和绳子远一点，行吗？", "Willow, could you stay away from my boards and rope for me?"),
          L("哈，那可得看我心情。", "Ha! That depends on my mood.") },
    
        { L("火是拿来干活的，不是拿来添乱的。", "Fire's for getting work done, not causing more trouble."),
          L("可添乱有时候更有趣啊。", "But causing trouble is more fun sometimes.") },
    
        { L("你要是想点火，至少先告诉我一声。", "If you're going to light something, at least warn me first."),
          L("行吧……要是我记得的话。", "Alright... if I remember.") },
    
        { L("我刚搭好的东西，你最好别拿去试火。", "You'd better not test your fire on something I just built."),
          L("你怎么总这么认真啊。", "Why do you always sound so serious?") },
    },


    wilson_wortox = {
      { L("你刚刚是从哪儿冒出来的？我差点把笔记本扔出去。", "Where did you spring from just now? I nearly threw my notebook."),
        L("嘿，说明你的反应很健康。恭喜，科学先生。", "Heh, that just proves your reflexes are healthy. Congratulations, science man.") },
      { L("你的移动方式很不符合常规物理。", "Your way of moving is highly inconsistent with conventional physics."),
        L("真巧，我对常规这东西也一向不太熟。", "How convenient. I've never been especially acquainted with convention either.") },
      { L("如果你愿意配合，我很想研究一下你的生理结构。", "If you'd cooperate, I'd very much like to study your physiology."),
        L("研究可以，但别拿刀。我的胆子没你想得大。", "Study all you like, but no knives. I'm not as brave as I look.") },
      { L("你到底算哺乳动物、恶魔，还是别的什么？", "So what are you exactly? Mammal, demon, or something else?"),
        L("今天我想当谜题，明天再考虑分类。", "Today I'd rather be a mystery. Tomorrow I'll consider taxonomy.") },
      { L("你的治疗方式也很值得记录。", "Your healing method is worth documenting too."),
        L("记得写得温柔点，我可不想被记成可疑样本。", "Be kind with the wording. I don't want to end up labeled a suspicious specimen.") },
      { L("你总在笑，是因为你真的轻松，还是一种掩饰？", "You're always smiling. Are you truly at ease, or is it a cover?"),
        L("哎呀，被看出来就不有趣了。至少别现在拆穿我。", "Oh dear, it's no fun if you notice. At least don't say it out loud just yet.") },
    },

    wendy_wortox = {
      { L("你笑得那么轻，像怕惊醒什么。", "You smile so lightly, as if afraid to wake something."),
        L("我确实不想惊醒什么，尤其是可怕的那种。", "I truly don't wish to wake anything, especially the frightening sort.") },
      { L("你总把害怕说得像玩笑。", "You always turn fear into a joke."),
        L("不然还能怎样？总不能让害怕先开口。", "What else should I do? I can't very well let fear speak first.") },
      { L("你看起来不像会一直留下来的那种人。", "You don't seem like the sort who stays."),
        L("我可以留一会儿。只要这一会儿还算安全。", "I can stay a while. Provided that while remains reasonably safe.") },
      { L("有时候你笑得太用力了。", "Sometimes you smile a little too hard."),
        L("那一定是因为周围太安静了。安静最会吓人。", "Then the silence must be too strong. Silence is excellent at frightening people.") },
      { L("你也在躲什么吗？", "Are you hiding from something too?"),
        L("当然。只是我喜欢把逃跑说得体面一点。", "Certainly. I just prefer to describe fleeing with a bit more dignity.") },
      { L("你会治伤，却不像喜欢靠近痛苦。", "You can heal wounds, yet you don't seem fond of getting close to pain."),
        L("我不喜欢疼，也不喜欢看别人疼。这很合理吧？", "I dislike pain, and I dislike seeing others in pain. That's perfectly reasonable, isn't it?") },
    },

    wathgrithr_wortox = {
      { L("小恶魔！抬起胸膛，像战士一样走路！", "Little fiend! Lift your chest and walk like a warrior!"),
        L("我可以抬胸膛，但我的腿未必同意。", "I can lift my chest, but my legs may not agree.") },
      { L("你总在危险边上打转，却不肯正面迎战！", "You circle danger constantly, yet refuse to face it head-on!"),
        L("因为侧着站比较容易活下来。", "Because standing sideways is much better for survival.") },
      { L("若敌人来袭，你可敢与我并肩冲锋？", "If enemies attack, would you charge at my side?"),
        L("并肩可以，冲锋这词我想再商量一下。", "At your side, yes. The charging part I'd like to renegotiate.") },
      { L("你的笑声太轻，像不敢惊动命运。", "Your laughter is too soft, as though you fear alerting fate."),
        L("我正是这么想的。命运通常脾气不太好。", "That is exactly my concern. Fate is often in a dreadful mood.") },
      { L("至少你还有治愈同伴的勇气。", "At least you have the courage to heal your companions."),
        L("那不算勇气，那算不想一个人活着发抖。", "I wouldn't call it courage. More a refusal to be left trembling alone.") },
      { L("哈！你虽胆怯，却并非毫无荣光！", "Ha! Though timid, you are not without honor!"),
        L("谢谢你挑了个最响亮的方式夸我。", "Thank you for choosing the loudest possible way to compliment me.") },
    },

    wolfgang_wortox = {
      { L("你怎么总是突然冒出来？会吓到沃尔夫冈！", "Why do you always pop out like that? You scare Wolfgang!"),
        L("那我们就算扯平了，我也常被自己吓一跳。", "Then we're even. I often startle myself too.") },
      { L("你看起来不强壮，但跑得很快。", "You don't look strong, but you run very fast."),
        L("谢谢，这几乎可以算一句夸奖。", "Thank you. That is almost a compliment.") },
      { L("沃尔夫冈打架，你在后面看着？", "Wolfgang fights, and you watch from behind?"),
        L("我在后面支援。必要时还能救你。", "I support from the rear. I can even patch you up if needed.") },
      { L("你会治伤？那很好！沃尔夫冈常常会受伤。", "You can heal wounds? Good! Wolfgang gets hurt often."),
        L("我已经猜到了，你看起来就很容易往危险里撞。", "I had already guessed. You look exceptionally likely to run into danger.") },
      { L("你总笑，是不是一点都不怕？", "You always laugh. Does that mean you're never afraid?"),
        L("不，正相反。我只是笑得比害怕早一点。", "No, quite the opposite. I merely laugh before the fear catches up.") },
      { L("你跟着沃尔夫冈，沃尔夫冈保护你！", "Stay with Wolfgang, and Wolfgang protect you!"),
        L("这提议听起来热闹又安全，我喜欢。", "That proposal sounds loud and safe. I approve.") },
    },

    wormwood_wortox = {
      { L("你走路轻轻的。像风。", "You walk lightly. Like wind."),
        L("谢谢，我尽量不走得像会被咬的点心。", "Thank you. I try not to walk like a snack.") },
      { L("你会治伤。手软软的。", "You heal wounds. Hands are gentle."),
        L("我胆子不大，所以只好手轻一点。", "My courage isn't large, so my hands must be gentle.") },
      { L("你笑。可尾巴紧紧的。", "You smile. But your tail is tight."),
        L("别拆穿我呀，小树朋友。我已经装得很辛苦了。", "Don't expose me, little tree friend. I'm trying very hard.") },
      { L("害怕也可以活着。", "Scared can still live."),
        L("这真是我今天听过最安慰人的话。", "That is the most comforting thing I've heard all day.") },
      { L("植物人受伤时，你会来吗？", "If Wormwood gets hurt, will you come?"),
        L("会。我跑得快，回来得也快。", "I will. I run quickly, and I return quickly too.") },
      { L("你像不安的小动物。", "You are like a restless little creature."),
        L("听着有点失礼，但也有点准确。", "That sounds mildly rude, but also accurate.") },
    },

    waxwell_wortox = {
      { L("你那副轻佻模样，实在吵得眼睛疼。", "That frivolous manner of yours is visually exhausting."),
        L("你这句骂得真讲究，我都快想鼓掌了。", "What an elegantly phrased insult. I almost want to applaud.") },
      { L("你总在笑，是想遮掩怯懦吗？", "You are always smiling. Is it to conceal cowardice?"),
        L("是啊，毕竟不是人人都适合摆一张棺材脸。", "Indeed. Not everyone can pull off the coffin-face look.") },
      { L("至少你还知道给伤者治疗，倒不算一无是处。", "At least you know how to tend the wounded. You're not entirely useless."),
        L("从你嘴里听见这话，我都快痊愈了。", "Hearing that from you almost feels medicinal by itself.") },
      { L("你似乎很擅长逃开危险。", "You do seem remarkably skilled at avoiding danger."),
        L("谢谢夸奖。我把那叫作长期生存技巧。", "Thank you. I call it a long-term survival skill.") },
      { L("哼，胆怯者往往活得更久。", "Hmph. Cowards often live longer."),
        L("终于，我们在某件事上观点一致了。", "At last, we agree on something.") },
      { L("若你少一些嬉皮笑脸，也许会显得更可靠。", "If you smiled less, you might appear more reliable."),
        L("可要是我不笑，我大概就该发抖了。", "If I stopped smiling, I'd likely start trembling instead.") },
    },

    willow_wortox = {
      { L("你闻起来像刚从哪场麻烦里逃出来。", "You smell like you just slipped out of some trouble."),
        L("准确地说，是我赶在麻烦咬到我之前离开了。", "More accurately, I left before the trouble got its teeth on me.") },
      { L("你跑得倒挺快。怕火吗？", "You run quickly enough. Afraid of fire?"),
        L("我对所有会突然变热的东西都保持尊重。", "I maintain a respectful attitude toward anything that can become suddenly hot.") },
      { L("你会治伤，那你也会治烧伤吗？", "You can heal wounds. Can you handle burns too?"),
        L("会，但最好别让我频繁练习。", "Yes, but I'd rather not practice too often.") },
      { L("你看上去像会一边尖叫一边逃跑。", "You look like you'd scream while running."),
        L("真失礼。我通常会先笑两声。", "How rude. I usually laugh twice before the screaming.") },
      { L("点把火，气氛会好很多。", "A little fire would improve the mood."),
        L("不，我觉得现在这样刚刚好，甚至已经有点危险了。", "No, I think the mood is quite sufficient already. Arguably too sufficient.") },
      { L("你真有意思，明明怕得很还待在这儿。", "You're funny. You're obviously scared, but you stay anyway."),
        L("那是因为总得有人把伤员捡回来。", "That's because someone has to collect the wounded afterward.") },
    },

    wickerbottom_wortox = {
      { L("你说话时常故意绕弯子。", "You often speak in deliberate circles."),
        L("直说有时太吓人了，拐一点弯更柔和。", "Directness can be frightening. A few curves soften the landing.") },
      { L("你明明胆怯，却总爱摆出从容姿态。", "You are clearly timid, yet insist on appearing composed."),
        L("礼貌地发慌，总比狼狈地发慌强。", "Panicking politely is better than panicking messily.") },
      { L("我听说你还懂得治疗。", "I hear you also know how to treat injuries."),
        L("略懂，至少能把哭声变小一点。", "A little. At the very least, I can make the crying quieter.") },
      { L("若你肯静下心来，倒可以学得更系统一些。", "If you settled down, you could learn in a much more systematic fashion."),
        L("听上去很有道理，只是“静下心来”这部分有点难。", "That sounds perfectly sensible. The settling down part is the difficulty.") },
      { L("你其实比你表现得更体贴。", "You are kinder than you pretend to be."),
        L("请别说得这么大声，我的名声还要呢。", "Please don't say that so loudly. I do have a reputation to maintain.") },
      { L("逃避并不总是懦弱，必要时也是判断。", "Retreat is not always cowardice. At times it is judgment."),
        L("您这话真动听，我愿意记上三遍。", "What a lovely sentence. I'd happily copy it down three times.") },
    },

    winona_wortox = {
      { L("你别在那儿转来转去，晃得我眼花。", "Stop pacing around. You're making my eyes hurt."),
        L("我这不叫乱转，我是在提前紧张。", "I wouldn't call it pacing. I'm worrying in advance.") },
      { L("你会治伤？那倒比空说大话管用。", "You can heal injuries? That's more useful than empty chatter."),
        L("瞧，这就是为什么我尽量两样都会。", "See? That's precisely why I try to keep both skills.") },
      { L("真有事的时候，你跑得快还是治得快？", "When trouble starts, do you run faster or heal faster?"),
        L("通常先跑两步，再回来治。分工明确。", "Usually I run two steps first, then come back and heal. Clear division of labor.") },
      { L("你看着不太像靠得住的那种。", "You don't exactly look dependable."),
        L("外表会骗人。我主要靠结果说话。", "Appearances deceive. I prefer to let the outcome speak.") },
      { L("至少你手还算稳。", "At least your hands are steady enough."),
        L("那是因为我把抖都留给腿了。", "That's because I leave all the shaking to my legs.") },
      { L("行吧，有你在，受伤的人能少难受点。", "Alright. With you around, the wounded suffer a little less."),
        L("听起来像份正经工作，我会珍惜的。", "That sounds almost respectable. I'll treasure it.") },
    },

    warly_wortox = {
      { L("你看起来不像会在厨房待太久的人。", "You don't seem like someone who lingers in the kitchen."),
        L("油锅太吓人了，我更适合站在安全一点的地方帮忙。", "Hot pans are terrifying. I'm better suited to helping from a safer distance.") },
      { L("可你照顾伤员时，倒很有耐心。", "Yet when tending the wounded, you seem quite patient."),
        L("疼的时候没人该被催，这点我还是懂的。", "No one ought to be rushed while in pain. That much I understand.") },
      { L("治疗也像烹饪，分量和时机都很重要。", "Healing is much like cooking. Timing and measure are everything."),
        L("好极了，我终于找到一种不会下锅的料理。", "Wonderful. I've found the only form of cuisine that doesn't end with me in the pan.") },
      { L("你总在说笑，可动起手来并不轻浮。", "You joke constantly, yet your hands are not frivolous when working."),
        L("因为玩笑不能止血，只能让我别太慌。", "Because jokes don't stop bleeding. They only keep me from panicking.") },
      { L("你若愿意，我可以教你些更稳妥的调配方法。", "If you wish, I could teach you a few steadier methods of preparation."),
        L("愿意，前提是课程不需要太靠近火。", "Gladly, provided the lesson doesn't involve standing too near the fire.") },
      { L("有你在旁边，大家总会安心一点。", "With you nearby, people do seem a little more at ease."),
        L("那我可得继续装得若无其事才行。", "Then I'd better continue pretending everything is perfectly under control.") },
    },

    woodie_wortox = {
      { L("你老是东张西望，像林子里受惊的小兽。", "You're always glancing about like a startled little critter in the woods."),
        L("谢谢，这形容听着比“胆小鬼”体面不少。", "Thank you. That's much nicer than simply calling me a coward.") },
      { L("别紧张，林子里有动静很正常。", "Take it easy. Noises in the woods are perfectly normal."),
        L("问题就在这儿，我觉得“正常”本身就挺吓人。", "And that's the trouble. I find 'perfectly normal' rather alarming on its own.") },
      { L("你会治伤，那砍树砸到脚了也能帮上忙吧？", "You can heal injuries, so I take it you can help when someone drops a tree on a foot?"),
        L("可以，但我希望你别把这说得像日常安排。", "I can, though I'd rather you not describe that as routine.") },
      { L("你跑得挺灵巧，干活未必比逃命差。", "You're nimble enough. You're probably better at work than just running."),
        L("这句我可记下了，难得有人夸得这么实用。", "I'll remember that. It's rare to be complimented so practically.") },
      { L("跟着我走，林子里不容易丢。", "Stick with me and you won't get lost in the woods."),
        L("这话听着可真让人安心，我差点就想承认自己怕了。", "That sounds wonderfully reassuring. I nearly admitted I was scared.") },
      { L("哈，你这小家伙，比看着还靠得住点。", "Ha, you're a little more dependable than you look."),
        L("我努力把那部分藏得不那么明显。", "I do try not to make that part too obvious.") },
    },

    wes_wortox = {
      { L("（比划着：你总是突然出现）", "(mimes: you always appear suddenly)"),
        L("我知道，我正在努力让自己学会先出个声。", "I know. I'm trying to learn how to announce myself first.") },
      { L("（拍拍胸口，装作被吓一跳）", "(pats chest, pretending to be startled)"),
        L("嘿，别学得这么像，我会以为你在嘲笑我。", "Hey, don't do it so well. I'll think you're mocking me.") },
      { L("（指指伤口，又做了个求助动作）", "(points at a wound, then makes a pleading gesture)"),
        L("当然，来吧。我总不能连这个都躲。", "Of course, come here. I can't very well hide from this too.") },
      { L("（做出夸张奔跑的动作）", "(acts out exaggerated running)"),
        L("这动作可不公平，我跑起来其实比这优雅一点。", "That is unfair. I am at least slightly more graceful than that.") },
      { L("（轻轻拍手，又竖起大拇指）", "(claps softly, then gives a thumbs up)"),
        L("谢谢你这么捧场，我差点真觉得自己很勇敢。", "Thank you for the support. I nearly believed I was brave.") },
      { L("（指指自己，又指指他，像在说“搭档”）", "(points to himself, then to you, as if saying 'partners')"),
        L("这提议不错。你安静，我紧张，我们正好互补。", "I like that arrangement. You stay quiet, I stay nervous, and somehow it works.") },
    },
    wortox_wilson = {
      { L("威尔逊，你那脑袋里装了多少问题？我听着都替你累。", "Wilson, how many questions fit in that head of yours? I get tired just listening to them."),
        L("很多，而且遗憾的是，它们通常不会自己回答自己。", "Quite a lot, and unfortunately they rarely answer themselves.") },
      { L("我刚刚差点被树影吓到，你能不能用科学解释一下我的胆量去哪了？", "I was nearly frightened by a tree shadow just now. Can science explain where my courage went?"),
        L("理论上，胆量没有消失，只是暂时被恐惧压制了。", "In theory, your courage hasn't disappeared. It is merely being temporarily suppressed by fear.") },
      { L("你研究我可以，但先说好，别把我切开看。", "You may study me if you like, but let us agree in advance that no cutting is involved."),
        L("放心，我更倾向于观察记录，而不是解剖。", "Rest assured, I much prefer observation and notes to dissection.") },
      { L("你记笔记的时候看起来很镇定，我借一点行不行？", "You look awfully calm when taking notes. May I borrow a little of that?"),
        L("如果镇定能借出去，我倒真希望能分你一些。", "If composure could be lent out, I'd gladly spare you some.") },
      { L("要是你又把什么东西搞炸了，我能先跑还是先救你？", "If you blow something up again, should I run first or heal you first?"),
        L("先确保你自己安全，再决定是否营救我。", "Ensure your own safety first, then decide whether I'm worth rescuing.") },
      { L("我会治伤，你会研究，我们这组合听着还挺像回事。", "I can patch wounds, you can conduct research. We almost sound like a proper team."),
        L("一位治疗者和一位科学家，确实是相当合理的配置。", "A healer and a scientist. Yes, that does sound like a sensible arrangement.") },
      { L("你要是哪天研究出‘不受惊吓’的办法，记得第一个告诉我。", "If you ever invent a method for not being startled, do tell me first."),
        L("我会优先通知你，前提是我也真的做得出来。", "You'll be first to know, assuming I can actually manage it.") },
      { L("别总盯着我看，我一紧张就想讲更多废话。", "Don't stare at me too long. When I get nervous, I start talking even more nonsense."),
        L("这倒解释了很多事。", "That does explain quite a few things.") },
  },
  
  wortox_wendy = {
      { L("温蒂，你老这么安静，会让我怀疑是不是连风都不敢吵你。", "Wendy, you're so quiet I half suspect even the wind is afraid to disturb you."),
        L("…风不会怕我…它只是路过而已…", "...The wind is not afraid of me... it merely passes by...") },
      { L("你看起来像什么都不怕，可我猜你只是习惯了。", "You look like you're afraid of nothing, but I suspect you've simply grown used to it."),
        L("…习惯并不会让黑夜变温柔…", "...Habit does not make the night any kinder...") },
      { L("你要是难受了可以来找我，我至少能把伤口哄安静一点。", "If you're hurting, you can come to me. I can at least persuade the wounds to quiet down."),
        L("…你说得像在安慰受伤的小动物…", "...You make it sound like soothing a wounded little animal...") },
      { L("我总觉得你看得太远了，远到让人背后发凉。", "I always feel you look too far away, far enough to make the air turn cold."),
        L("…有些东西离得很远…可还是忘不掉…", "...Some things are very far away... and still cannot be forgotten...") },
      { L("我会拿玩笑挡一挡害怕，你呢，用什么挡？", "I use jokes to stand between myself and fear. What do you use?"),
        L("…沉默吧…它至少不会碎得太响…", "...Silence, perhaps... at least it does not shatter too loudly...") },
      { L("你别总把自己弄得那么疼，我会觉得自己得多留点力气。", "Try not to get yourself hurt so often. It makes me feel I ought to save up my strength."),
        L("…你居然会为这种事操心…", "...You really worry about things like that...") },
      { L("跟你说话的时候，我都不太敢把声音放大。", "When I speak to you, I hardly dare raise my voice."),
        L("…轻一点也好…有些话本就不该太响…", "...Softer is better... some words should never be too loud...") },
      { L("你偶尔也该休息一下，不然连月亮都要替你难过了。", "You should rest now and then, or even the moon may start grieving for you."),
        L("…月亮一直都在看着所有难过的人…", "...The moon is always watching the sorrowful...") },
  },
  
  wortox_wathgrithr = {
      { L("女武神，你每次说话都像下一秒要开战，我尾巴都要绷直了。", "Valkyrie, every time you speak it sounds like battle is a heartbeat away. It makes my tail stand on end."),
        L("好兆头！绷紧的神经正是战意的前奏！", "A good sign! Taut nerves are merely the overture to battle!") },
      { L("你有没有比较安静一点的鼓舞方式？我胆子受不了太响的。", "Do you have a quieter way of inspiring people? My courage does poorly with volume."),
        L("真正的勇者应当习惯雷鸣般的呐喊！", "A true warrior must grow accustomed to thunderous cries!") },
      { L("要是你又冲太前面，我可得一边发抖一边把你捡回来。", "If you charge too far ahead again, I'll have to collect you while trembling."),
        L("哈！那就说明你已是可靠的战友！", "Ha! Then that makes you a reliable comrade indeed!") },
      { L("我会治伤，这事很有用，尤其是你这种爱拿脸迎战的人。", "I can mend wounds. Very useful, especially for someone who greets combat with her face."),
        L("战士身上的伤疤，是荣耀的勋章！", "Scars upon a warrior are medals of honor!") },
      { L("你这么喜欢战斗，真的不会累吗？", "You enjoy battle so much. Do you never tire of it?"),
        L("战斗使热血沸腾，何来疲惫之说！", "Battle sets the blood aflame. How could there be fatigue in that?") },
      { L("我可以陪你去，但你得保证别把‘慢一点’当成侮辱。", "I can come along, but you must promise not to treat 'slower' as an insult."),
        L("哼！只要你不临阵脱逃，步伐快慢尚可商量！", "Hmph! So long as you do not flee the field, the pace may be negotiated!") },
  },
  
  wortox_wolfgang = {
      { L("沃尔夫冈，你是不是连呼吸都比别人有气势？", "Wolfgang, do you breathe more heroically than everyone else as well?"),
        L("当然！因为沃尔夫冈最强！", "Of course! Because Wolfgang is strongest!") },
      { L("你每次往前一站，我都觉得自己好像安全了一半。", "Every time you step in front, I feel half safe already."),
        L("哈哈！那就站在沃尔夫冈后面！", "Ha ha! Then stay behind Wolfgang!") },
      { L("不过你受伤的时候也挺吓人的，我还得追着给你治。", "Though when you get hurt, that's frightening in its own way. I end up chasing you just to heal you."),
        L("沃尔夫冈有时会忘记疼！", "Sometimes Wolfgang forgets pain!") },
      { L("你下次冲之前能不能先说一声？让我先把心放回肚子里。", "Next time you charge, could you warn me first? I'd like to put my heart back in my chest."),
        L("好！沃尔夫冈下次大声告诉你！", "Good! Wolfgang will shout very loudly next time!") },
      { L("不不不，也别太大声，我只是随口一提。", "No, no, perhaps not too loudly. I was only speaking casually."),
        L("你真奇怪！又想知道，又怕知道！", "You are strange! Want to know, but also fear knowing!") },
      { L("我会治伤，你会打架，我们看起来像分工明确的麻烦组合。", "I heal, you fight. Together we look like a highly organized source of trouble."),
        L("听起来很好！沃尔夫冈喜欢团队！", "That sounds good! Wolfgang likes teams!") },
      { L("说真的，你别饿着肚子去打，不然我连救你都得排队。", "Truly, don't fight on an empty stomach, or even healing you becomes a waiting line."),
        L("嗯！吃饱的沃尔夫冈更强！", "Mm! Full Wolfgang is stronger Wolfgang!") },
  },
  
  wortox_wormwood = {
      { L("小树朋友，你看起来总比我镇定，明明你才更像会被咬的那个。", "Little tree friend, you always seem calmer than me, though you look far more edible."),
        L("植物人不想被咬。你也不要被咬。", "Wormwood does not want bites. You should not be bitten either.") },
      { L("你说得对，所以我才一直努力离牙齿远一点。", "Exactly, which is why I work so hard to stay away from teeth."),
        L("好办法。离坏嘴巴远一点。", "Good plan. Stay away from bad mouths.") },
      { L("你要是受伤了就来找我，我会尽量把你补得漂漂亮亮。", "If you're hurt, come find me. I'll do my best to patch you up nicely."),
        L("你会修好伤口。像雨水修好小苗。", "You fix wounds. Like rain fixes little sprouts.") },
      { L("这夸法真可爱，差点让我忘了自己其实有点害怕。", "That is such a sweet compliment I nearly forgot I was frightened."),
        L("害怕可以。还可以笑。", "Scared is okay. Smiling is okay too.") },
      { L("你怎么老能把话说得这么简单？听完反而安心。", "How do you always make things sound so simple? It somehow makes me calmer."),
        L("因为事情本来就可以简单。", "Because things can simply be simple.") },
      { L("你种东西，我治人，我们两个都算在帮大家长好一点。", "You grow things, I mend people. We both help things grow better, in a way."),
        L("嗯。植物人喜欢这个说法。", "Mm. Wormwood likes that.") },
      { L("你可别突然从背后碰我，我真的会跳起来。", "Please don't touch me from behind all at once. I truly might leap into the air."),
        L("好。植物人从前面来。慢慢的。", "Okay. Wormwood comes from the front. Slowly.") },
  },
  
  wortox_waxwell = {
      { L("麦斯威尔，你每次皱眉都像在给空气下命令。", "Maxwell, every time you frown it feels like you're giving orders to the air."),
        L("若空气懂得服从，那会省去我不少麻烦。", "If the air understood obedience, it would save me considerable trouble.") },
      { L("你看起来像那种连受伤都不愿承认的人。", "You strike me as the sort who refuses to admit injury."),
        L("承认软弱从来不是一种值得推崇的习惯。", "Admitting weakness has never been a habit worth encouraging.") },
      { L("那可不行。你要是倒下了，我治起来也会很麻烦。", "That won't do. If you collapse, you'll be inconvenient to heal."),
        L("呵，你倒像是把我的性命安排进了日程。", "Heh. You sound as if you've scheduled my continued survival.") },
      { L("当然。你这种人活着比躺着更擅长让人头疼。", "Naturally. Men like you are far more troublesome upright than unconscious."),
        L("真是别致的关心方式。", "What a delightfully unusual way to express concern.") },
      { L("你也别老拿那副高深脸色吓人，我胆子又不归你管。", "And do stop using that cryptic expression to frighten people. My nerves are not yours to command."),
        L("若你如此容易受惊，那是你自己的问题。", "If you startle so easily, that sounds very much like your own problem.") },
      { L("是啊，所以我通常会先笑一笑，再决定要不要跑。", "Indeed, which is why I usually laugh first, then decide whether to run."),
        L("至少你还懂得在真正逃跑前维持体面。", "At least you possess the sense to preserve your dignity before fleeing.") },
      { L("你要是受了伤，记得早点说。我不保证温柔，但保证有效。", "If you're injured, say so early. I can't promise tenderness, but I can promise results."),
        L("有效即可。温柔向来不是我在意的部分。", "Effective will suffice. Tenderness has never been a priority of mine.") },
  },
  
  wortox_willow = {
      { L("威洛，你每次一兴奋，我就开始担心周围会不会突然变亮。", "Willow, every time you get excited I begin to worry the surroundings may suddenly become much brighter."),
        L("那说明你的直觉还不错。", "Then your instincts are working just fine.") },
      { L("我可不是夸你，我只是比较珍惜自己这身没被烤过的毛。", "That wasn't a compliment. I'm simply fond of my currently un-roasted fur."),
        L("放轻松，我又不是每次都失控。", "Relax. I don't lose control every single time.") },
      { L("这句话听着一点都不让我放松。", "That sentence does not relax me in the slightest."),
        L("那你最好学会边怕边站稳。", "Then you'd better learn to stay upright while afraid.") },
      { L("我会治伤，所以你最好别把大家都点得太均匀。", "I can patch people up, so do try not to roast everyone too evenly."),
        L("哈，你说得像已经见过那种场面。", "Ha! You say that like you've seen it happen before.") },
      { L("我见过够多吓人的东西了，火只是其中一种会发光的。", "I've seen enough frightening things. Fire is just one of the glowing ones."),
        L("你还挺会说的，胆子却没跟上。", "You talk pretty well. Shame your courage can't keep pace.") },
      { L("没办法，嘴比腿胆大一点。", "Can't be helped. My mouth is a little braver than my legs."),
        L("那至少你的手还算有用。", "Well, at least your hands are useful.") },
      { L("谢谢夸奖。我宁愿当有用的胆小鬼，也不想当烧焦的勇士。", "Why, thank you. I'd rather be a useful coward than a heroic pile of ash."),
        L("这话居然还有点道理。", "That is annoyingly sensible.") },
  },
  
  wortox_wickerbottom = {
      { L("薇克巴顿，你看人的眼神总让我怀疑自己像一本借错架的书。", "Wickerbottom, the way you look at people makes me feel like a book shelved in entirely the wrong section."),
        L("若你能安分些，分类工作会轻松很多。", "If you behaved a little more consistently, classification would be much easier.") },
      { L("我尽量，只是我一紧张，性格就会开始打滑。", "I do try. It's just that when I get nervous, my personality tends to slip sideways."),
        L("你倒是很擅长用浮夸的措辞描述真实问题。", "You do have a talent for dressing real problems in flamboyant language.") },
      { L("那是因为真实问题有时太扎人，得包一层笑话。", "That is because real problems can be rather sharp. A layer of humor softens them."),
        L("某种程度上，这也算一种自我保护。", "To a degree, that can indeed count as self-protection.") },
      { L("您看，我就喜欢您这种会把我说得像有道理的人。", "See, that's what I like about you. You make me sound almost reasonable."),
        L("我只是尽可能精确地表述事实。", "I am merely describing the facts as precisely as possible.") },
      { L("我会治伤，这事您应该挺欣赏吧？总比我只会乱跑强。", "I can treat wounds. I assume you approve of that? Better than merely running in circles."),
        L("确实。掌握治疗手段，总比掌握夸张姿态更具实际价值。", "Certainly. Competence in healing is far more valuable than competence in theatricality.") },
      { L("唉，您夸人的方式真是像被尺子量过。", "Ah, your compliments always sound as if measured with a ruler."),
        L("有分寸的赞许，总比轻浮的吹捧更可靠。", "Measured praise is far more reliable than careless flattery.") },
      { L("您说得对，所以我决定把这句记在心里，等害怕的时候拿出来用。", "You're quite right. I'll store that away for later, to use the next time I'm frightened."),
        L("若你真能记住，那这次对话就并未白费。", "If you truly remember it, then this conversation was not wasted.") },
  },
  
  wortox_winona = {
      { L("薇诺娜，你看起来像那种连麻烦都能拧紧的人。", "Winona, you look like the sort who could tighten a loose problem with a wrench."),
        L("只要那麻烦有螺丝口，我就有办法。", "If the problem has a fitting, I can work with it.") },
      { L("真羡慕你这种实在劲儿，我一慌就只会多说两句。", "I envy that practical streak of yours. When I get nervous, I just talk more."),
        L("说归说，真出事时你手倒还算稳。", "Talk all you like. When trouble starts, your hands are steady enough.") },
      { L("那是因为我把抖都留给了膝盖。", "That's because I leave all the shaking to my knees."),
        L("行，至少你知道该把力气用在哪儿。", "Fair enough. At least you know where the effort belongs.") },
      { L("我会治伤，你会修东西，我们看着像营地里比较能收拾残局的那批。", "I heal people, you fix things. We sound like the sort who clean up everyone else's mess."),
        L("这评价还挺准。总得有人把烂摊子收回去。", "That's not far off. Someone has to put the mess back together.") },
      { L("你是不是从来不怕？还是只是没空怕？", "Are you never scared, or just too busy to be scared?"),
        L("忙起来的时候，怕不怕都得先干活。", "When there's work to do, fear can wait its turn.") },
      { L("这话真好，我得记下来，假装以后也能这么硬气。", "That's good. I'll remember it and pretend I can be that tough too."),
        L("别光 pretend，真到时候记得先救人。", "Don't just pretend. When the time comes, remember to save people first.") },
      { L("这点您放心，我跑归跑，伤还是会回头治的。", "On that point, rest easy. I may run, but I do come back to patch people up."),
        L("那就够了。腿快点不算缺点。", "Then that's enough. Fast legs aren't a flaw.") },
  },
  
  wortox_warly = {
      { L("瓦尔利，你做饭时那神情，比我治伤时还认真。", "Warly, the look on your face while cooking is even more serious than mine when I'm healing."),
        L("料理与照料一样，都不能马虎半分。", "Cooking and caretaking have this in common: neither tolerates carelessness.") },
      { L("您这话一说，我都觉得自己像门正经手艺。", "When you say it like that, my work almost sounds respectable."),
        L("会疗伤的人本就值得尊重。", "A person who can mend wounds is already worthy of respect.") },
      { L("别这样夸我，我会误以为自己很可靠。", "Don't praise me like that. I'll start thinking I'm dependable."),
        L("依我看，你确实比自己承认的可靠。", "As I see it, you are more dependable than you admit.") },
      { L("我承认得太多，胆子就不够用了。", "If I admit too much, I won't have enough courage left over."),
        L("那便把胆量留给真正需要的时候。", "Then save your courage for when it is truly needed.") },
      { L("我会治伤，您会做饭，我们两个都挺适合照顾人的。", "I heal wounds, you make meals. We both seem suited to taking care of people."),
        L("照顾他人，本就是一种珍贵的能力。", "Caring for others is a precious skill in its own right.") },
      { L("而且您的锅比我的笑话更能安抚人心。", "And your stew is far more soothing than my jokes."),
        L("那你就负责逗人笑，我来负责让他们吃饱。", "Then you may handle the laughter, and I'll handle the nourishment.") },
      { L("听起来像极了某种不太体面的完美分工。", "That sounds like an oddly undignified form of perfection."),
        L("只要有用，体面倒可以稍后再谈。", "If it works, dignity can be discussed later.") },
  },
  
  wortox_woodie = {
      { L("伍迪，你走路总像知道哪棵树会先开口。", "Woodie, you always walk like you know which tree might start talking first."),
        L("在林子里待久了，总会学会听点门道，嗯？", "Spend enough time in the woods and you start learning what to listen for, eh?") },
      { L("我就不行，我只会先怀疑是不是有什么东西想咬我。", "I can't do that. I mostly just assume something is trying to bite me."),
        L("这想法在野外倒也不算完全错。", "Out here, that isn't entirely the wrong assumption.") },
      { L("您这安慰方式可真务实，吓得人都更踏实了。", "Your way of reassuring people is wonderfully practical. Somehow that makes it more reassuring."),
        L("实话有时候比漂亮话顶用得多。", "Truth often works better than pretty talk.") },
      { L("我会治伤，所以您砍树时最好别把自己也一起算进去。", "I can patch wounds, so do try not to count yourself among the things you're chopping."),
        L("哈！放心吧，我一般砍的是树，不是自个儿。", "Ha! Don't worry. I generally chop trees, not myself.") },
      { L("一般？这词听着让我很想提前准备药。", "Generally? That word alone makes me want to prepare medicine in advance."),
        L("提前准备不算坏习惯，尤其在这种地方。", "Preparing ahead isn't a bad habit, especially in a place like this.") },
      { L("您说话可真稳，稳得我都想离您近一点。", "You speak so steadily it makes me want to stand a little closer."),
        L("那就跟近点儿，林子里有个伴总归好些。", "Then stay close. Woods are better with company, eh?") },
      { L("这话真中听，我决定今天少害怕一会儿。", "That's lovely to hear. I've decided to be less frightened for at least a little while."),
        L("那就成，慢慢来就好。", "There you go. No need to rush it.") },
  },
  
  wortox_wes = {
      { L("韦斯，你老这么安静，我都不知道该先说笑话还是先道歉。", "Wes, you're so quiet I never know whether to begin with a joke or an apology."),
        L("（摊手，又夸张地行了个礼）", "(spreads his hands, then gives an exaggerated bow)") },
      { L("您这意思是‘都可以’？那我先讲个不太吓人的。", "Does that mean 'either is fine'? Then I'll begin with one that isn't too alarming."),
        L("（点点头，做了个“请”的手势）", "(nods and gestures, 'go on')") },
      { L("您真有耐心。换了别人，可能早嫌我话多了。", "You are very patient. Most people would have tired of my chatter by now."),
        L("（摇摇头，又指了指自己的耳朵，表示在认真听）", "(shakes his head, then points to his ear to show he's listening)") },
      { L("好吧，那我说句正经的：你要是伤着了，记得来找我。", "Very well, then something serious: if you're hurt, come find me."),
        L("（先愣了一下，再轻轻点头）", "(pauses in surprise, then nods gently)") },
      { L("我会治伤的，虽然看起来不像那种很可靠的人。", "I can mend wounds, despite not looking especially dependable."),
        L("（竖起大拇指，又拍了拍自己的心口）", "(gives a thumbs-up, then pats his chest)") },
      { L("谢谢您这么信任我，我差点都不想再装得那么怕了。", "Thank you for trusting me so much. I almost don't feel like pretending to be so frightened anymore."),
        L("（笑着比出一个小小的鼓励手势）", "(smiles and gives a small encouraging gesture)") },
  },


  wanda_wilson = {
    { L("威尔逊，你总想得太满。", "Wilson, you always think too far ahead."),
      L("科学总得先多想一步。", "Science usually needs one extra step.") },

    { L("有些答案，会迟一点来。", "Some answers arrive a little late."),
      L("那我就继续验算下去。", "Then I'll keep testing until they do.") },

    { L("别把自己也算进实验。", "Do not include yourself in the experiment."),
      L("我尽量让误差小一点。", "I'll try to keep the margin small.") },

    { L("你很聪明，别太着急证明。", "You're clever. No need to prove it so fast."),
      L("好奇心总催人快一点。", "Curiosity does have that effect.") },

    { L("时间会答你，不必硬追。", "Time answers in its own way."),
      L("听着像很科学的安慰。", "That sounds oddly scientific.") },

    { L("真出事时，先保住自己。", "If things go wrong, save yourself first."),
      L("记下了，先保研究员。", "Noted. Protect the researcher first.") },
},

wanda_wendy = {
    { L("温蒂，你总看得太远。", "Wendy, you always look too far away."),
      L("远处的东西，更安静些。", "Distant things are often quieter.") },

    { L("有些告别，不会准时来。", "Some farewells never arrive on time."),
      L("可它们总还是会来。", "And yet they always arrive.") },

    { L("你比自己想的更能撑。", "You endure more than you think."),
      L("那大概只是还没结束。", "Perhaps it simply isn't over yet.") },

    { L("别总站在旧时间里。", "Do not remain in old time too long."),
      L("旧时间里，还有她在。", "She is still there, in old time.") },

    { L("你若想静，我不催你。", "If you want silence, I won't rush you."),
      L("……谢谢你没逼我说。", "...Thank you for not pressing.") },

    { L("今天先活着，就够了。", "Living through today is enough."),
      L("这句话，倒还温柔。", "That is gentler than it sounds.") },
},

wanda_wathgrithr = {
    { L("薇格弗德，你气势太满。", "Wigfrid, your presence is a bit much."),
      L("战士就该像号角一般！", "A warrior should sound like a horn!") },

    { L("别急着冲，时机会更值钱。", "Do not rush. Timing is worth more."),
      L("哈！你也懂战机二字！", "Ha! You do understand battle timing!") },

    { L("多活一刻，胜算就多些。", "One more moment alive means better odds."),
      L("说得像老将的劝诫。", "Spoken like a seasoned veteran.") },

    { L("英雄若倒早了，就不值。", "A hero falling too soon is wasteful."),
      L("女武神会撑到终章！", "The Valkyrie endures to the final verse!") },

    { L("你适合正面，我补你时机。", "You take the front. I handle timing."),
      L("很好，我们各守其职！", "Excellent. Each to their rightful role!") },

    { L("别拿命换太廉价的胜利。", "Do not spend your life on cheap victory."),
      L("荣耀也该有好价码！", "Then glory too must earn its price!") },
},

wanda_wolfgang = {
    { L("沃尔夫冈，你别冲太早。", "Wolfgang, don't charge too early."),
      L("可沃尔夫冈力气很多！", "But Wolfgang has so much strength!") },

    { L("力气珍贵，要用在准处。", "Strength is precious. Use it well."),
      L("那沃尔夫冈等你说时机。", "Then Wolfgang waits for your signal.") },

    { L("饿的时候，别逞强上前。", "Do not force it when you're hungry."),
      L("饿肚子会让拳头变软。", "An empty belly softens the punch.") },

    { L("你其实比自己想得稳。", "You're steadier than you think."),
      L("真的吗？沃尔夫冈很稳？", "Really? Wolfgang is steady?") },

    { L("怕黑也没什么可丢脸。", "Being afraid of dark is no shame."),
      L("你这样说，真让人安心。", "That really does make me feel better.") },

    { L("真出事时，先站我这边。", "If trouble comes, stand by me first."),
      L("好！沃尔夫冈保护你！", "Good! Wolfgang protects you!") },
},

wanda_wormwood = {
    { L("沃姆伍德，你总活得很慢。", "Wormwood, you live at a slow pace."),
      L("慢慢长。比较好。", "Grow slowly. Better that way.") },

    { L("慢一些，有时反而更准。", "Sometimes slower means more precise."),
      L("植物人懂。种子也这样。", "Wormwood understands. Seeds too.") },

    { L("你倒比许多人更明白活着。", "You understand living better than many."),
      L("活着就是长呀。", "Living means growing.") },

    { L("摘花时，你会不会难过？", "Do you feel sad when picking flowers?"),
      L("会一点。可还是要活。", "A little. But still must live.") },

    { L("你总让我觉得时间很轻。", "You make time feel lighter."),
      L("时间会长叶子吗？", "Can time grow leaves?") },

    { L("也许会，只是很难看见。", "Perhaps. It's simply hard to see."),
      L("那植物人慢慢看。", "Then Wormwood will watch slowly.") },
},

wanda_waxwell = {
    { L("麦斯威尔，你像旧钟摆。", "Maxwell, you're like an old pendulum."),
      L("至少我还没彻底停下。", "At least I haven't stopped yet.") },

    { L("你很会藏住代价。", "You hide the cost rather well."),
      L("代价不适合到处展示。", "Costs are poor things to display.") },

    { L("有些过去，拖太久会坏。", "Some pasts spoil if kept too long."),
      L("可有些人只剩过去。", "Some men are left with little else.") },

    { L("你总像提前认输了。", "You often sound pre-defeated."),
      L("那叫看清局势，亲爱的。", "That is called perspective, dear.") },

    { L("你若少挖苦些，会轻松点。", "Less mockery might make you lighter."),
      L("轻松从不是我的专长。", "Ease has never been my specialty.") },

    { L("至少你还知道怎么撑。", "At least you still know how to endure."),
      L("这话倒比恭维有用。", "That is more useful than praise.") },
},

wanda_willow = {
    { L("薇洛，你总想烧得太快。", "Willow, you always want fire too fast."),
      L("快一点，火才更好玩。", "Fast is what makes it fun.") },

    { L("火也得挑时机，不是吗。", "Even fire needs timing, doesn't it?"),
      L("……这话我居然赞同。", "...I can't believe I agree.") },

    { L("烧早了，只会浪费好戏。", "Burn too soon and you waste the show."),
      L("你比我还会吊胃口。", "You tease the payoff even better.") },

    { L("你像秒针，老想往前跳。", "You're like a second hand trying to skip."),
      L("听着挺像夸我。", "That almost sounds flattering.") },

    { L("别把自己也点进去了。", "Try not to ignite yourself too."),
      L("我一般烧别人更多些。", "I usually burn other things more.") },

    { L("那就把准头留到关键时。", "Then save your aim for the right moment."),
      L("行，我忍到最好看时。", "Fine. I'll wait for the best moment.") },
},

wanda_wickerbottom = {
    { L("薇克巴顿，你总太严谨。", "Wickerbottom, you're relentlessly precise."),
      L("严谨总比疏忽可靠。", "Precision is better than carelessness.") },

    { L("可时间并不总讲道理。", "Time does not always behave logically."),
      L("那更该记下它的偏差。", "Then its deviations ought to be recorded.") },

    { L("你看事情，总比别人完整。", "You see things more completely than most."),
      L("经验会修正视野。", "Experience sharpens vision.") },

    { L("有你在，错误会少很多。", "With you here, mistakes should be fewer."),
      L("这是相当实用的评价。", "That is a pleasingly practical remark.") },

    { L("若我走偏了，记得提醒。", "If I drift, do remind me."),
      L("我自然会如此。", "I naturally shall.") },

    { L("谢谢，你总让局面稳些。", "Thank you. You make things steadier."),
      L("稳定，正是应有之义。", "Stability is exactly the point.") },
},

wanda_winona = {
    { L("薇诺娜，你做事很稳。", "Winona, you're impressively steady."),
      L("稳点干活，总没坏处。", "Steady work rarely hurts.") },

    { L("你像修钟的人，先看结构。", "You're like a clocksmith. Structure first."),
      L("先看结构，才不返工。", "Check the structure first, avoid rework.") },

    { L("你很少浪费动作和时间。", "You waste very little time or motion."),
      L("能一次做好，就别两次。", "If once will do, don't do it twice.") },

    { L("有你在，残局都像能收。", "With you here, messy situations feel salvageable."),
      L("能修的，我一般都修。", "If it can be fixed, I fix it.") },

    { L("坏掉不可怕，来不及才怕。", "Broken isn't scary. Too late is."),
      L("这话我记住了。", "That one I'll remember.") },

    { L("你负责落地，我负责时机。", "You handle the practical side, I handle timing."),
      L("成，这搭配挺顺手。", "Works for me. Good pairing.") },
},

wanda_webber = {
    { L("韦伯，你总盯人太紧。", "Webber, you stare a little too intensely."),
      L("我们只是想先看清你。", "We just want to get a good look.") },

    { L("别急着扑，人会被吓跑。", "Don't pounce so quickly. People flee."),
      L("那是因为他们跑得早。", "That's because they run early.") },

    { L("你其实比看着更乖些。", "You're better behaved than you look."),
      L("真的？这算夸奖吗？", "Really? Does that count as praise?") },

    { L("算吧，前提是你别咬人。", "It does, provided you don't bite."),
      L("我们会尽量先不咬。", "We'll try not to bite first.") },

    { L("你若肯听，很多事会轻松。", "If you listen first, things go smoother."),
      L("那我们先听你说。", "Then we'll listen to you first.") },

    { L("很好，这比乱扑值钱多了。", "Good. That's far more valuable than leaping."),
      L("你说话像在织网。", "You speak like you're weaving a web.") },
},

wanda_wurt = {
    { L("沃特，你护地盘护得紧。", "Wurt, you guard your turf fiercely."),
      L("当然，这里是鱼人地盘！", "Of course. This is merm turf!") },

    { L("这点很好，守住才有以后。", "That's good. Guarding things preserves tomorrow."),
      L("你说话怪怪，但有道理。", "You talk strange, but make sense.") },

    { L("冲太快，容易把明天赔掉。", "Charge too fast and you spend tomorrow."),
      L("那沃特先看一眼再冲。", "Then Wurt looks first, then charges.") },

    { L("这就对了，慢半拍也值。", "Good. Half a beat slower is worth it."),
      L("沃特不喜欢慢，但可以学。", "Wurt dislikes slow, but can learn.") },

    { L("你挺勇，但别总一个人顶。", "You're brave, but don't tank alone."),
      L("鱼人也会找同伴一起。", "Merms fight better with friends too.") },

    { L("很好，活下来比嘴硬重要。", "Good. Survival matters more than pride."),
      L("哼，沃特本来也会活！", "Hmph. Wurt was going to live anyway!") },
},

wanda_warly = {
    { L("沃利，你做事讲究火候。", "Warly, you care deeply about timing."),
      L("火候错了，味道就坏了。", "Miss the heat, and the dish is ruined.") },

    { L("这点我们倒很像。", "In that way, we're rather alike."),
      L("您是管时间，我管锅。", "You manage time. I manage the pot.") },

    { L("时机和调味，都不能多。", "Timing and seasoning both hate excess."),
      L("说得像道老练菜谱。", "That sounds like a seasoned recipe.") },

    { L("你总把耐心煮成结果。", "You turn patience into results."),
      L("好菜，总得慢一点来。", "Good food always takes a little time.") },

    { L("有你在，营地像稳些。", "With you here, camp feels steadier."),
      L("能让人安心，就是好饭。", "Food that reassures is good food.") },

    { L("你比很多钟都更准。", "You're more accurate than many clocks."),
      L("这赞美，我收下了。", "That compliment, I gladly accept.") },
},

wanda_wanda = {
    { L("又见面了，另一个我。", "We meet again, another me."),
      L("希望你没把局面弄坏。", "Let's hope you haven't ruined things.") },

    { L("我通常只在最后补漏。", "I usually only arrive to patch the end."),
      L("听着像很累的命。", "That sounds exhausting.") },

    { L("你看起来，比我还欠睡。", "You look even more sleep-deprived than me."),
      L("时间债，总得有人还。", "Someone always pays the time debt.") },

    { L("我们两个站一起，真危险。", "The two of us together feel unsafe."),
      L("也可能只是效率太高。", "Or perhaps simply too efficient.") },

    { L("若只能信一个，我信你。", "If I could trust only one, it's you."),
      L("那说明局势确实糟了。", "Then the situation must be terrible.") },

    { L("别笑，至少我们还活着。", "Don't laugh. At least we're alive."),
      L("暂时活着，也算赢。", "Alive for now still counts as winning.") },
},

wanda_woodie = {
    { L("伍迪，你总像认得路。", "Woodie, you always seem to know the way."),
      L("林子待久了，自然懂些。", "Stay in the woods long enough, you learn a few things.") },

    { L("我只会先防着挨咬。", "I usually just prepare to be bitten first."),
      L("在野外，这不算错。", "Out here, that isn't exactly wrong.") },

    { L("你安慰人，倒很实在。", "Your reassurance is refreshingly practical."),
      L("实话总比空话管用。", "Truth helps more than pretty words.") },

    { L("砍树时，别顺手伤了自己。", "Try not to chop yourself with the tree."),
      L("放心，我一般只砍树。", "Don't worry, I usually only chop trees.") },

    { L("你这“一般”让我警觉。", "That 'usually' is exactly what worries me."),
      L("提前防备，总没坏处。", "Being prepared never hurts.") },

    { L("你站这儿，我安心些。", "I feel steadier standing near you."),
      L("那就靠近点，别走散。", "Then stay close and don't wander off.") },
},

wanda_wortox = {
    { L("你嘴硬，心倒不算硬。", "Your mouth is sharp, but not your heart."),
      L("我这叫谨慎，不叫软。", "That's caution, not softness.") },

    { L("你总先怕，再先救人。", "You panic first, then save others first."),
      L("总得有人顾着血线。", "Someone has to watch the health bars.") },

    { L("你在抖，还想装镇定。", "You're trembling and still acting calm."),
      L("拆穿我，可不太厚道。", "Calling me out like that is unkind.") },

    { L("害怕不丢人，误时才丢。", "Fear isn't shameful. Bad timing is."),
      L("你这安慰，怪有用的。", "That is oddly comforting.") },

    { L("真出事时，你别乱跑。", "If trouble starts, don't bolt."),
      L("我会贴近点，方便救人。", "I'll stay close. Easier to help that way.") },

    { L("你比自己想的可靠。", "You're more reliable than you think."),
      L("这话听着，能壮胆些。", "That actually helps my courage.") },
},

wanda_wes = {
    { L("韦斯，你安静得很准时。", "Wes, your silence is remarkably punctual."),
      L("（摊手，轻轻鞠躬）", "(spreads hands, gives a light bow)") },

    { L("你这样，倒省去废话。", "Your way does spare a lot of useless words."),
      L("（点头，比了个请）", "(nods and gestures 'go on')") },

    { L("沉默有时，比回答更稳。", "Sometimes silence is steadier than an answer."),
      L("（指指耳朵，认真听着）", "(points to his ear, listening carefully)") },

    { L("你若受伤，记得来找我。", "If you're hurt, come find me."),
      L("（微怔后，轻轻点头）", "(pauses, then nods gently)") },

    { L("别担心，我还来得及救。", "Don't worry. I can still make it in time."),
      L("（竖起拇指，拍拍心口）", "(gives a thumbs-up, pats his chest)") },

    { L("你这信任，倒省我解释。", "That trust saves me the trouble of explaining."),
      L("（笑着比出鼓励手势）", "(smiles and makes a small encouraging gesture)") },
},

woodie_wanda = {
  { L("旺达，你看着总像没睡够。", "Wanda, you always look half short on sleep."),
    L("时间欠我的，从不肯少算。", "Time never forgets what I owe it.") },

  { L("你走路像在赶什么事儿。", "You walk like you're late for something."),
    L("我一向在赶，差别只在早晚。", "I'm always hurrying. Only the hour changes.") },

  { L("林子不急，人急了容易错。", "Woods don't rush. People do, and that's when they err."),
    L("可有些错，慢一步更贵。", "And some errors cost more when you're slow.") },

  { L("你这人，说话像老钟摆。", "You talk like an old pendulum."),
    L("至少我还知道往哪边摆。", "At least I still know which way to swing.") },

  { L("要不要歇会儿，喝口热的？", "You want a short break and something warm?"),
    L("……好提议，我记你一份情。", "...Good idea. I'll count that kindly.") },

  { L("别老一个人扛着，嗯？", "Don't keep carrying it all alone, eh?"),
    L("我尽量。只是习惯难改。", "I try. Some habits take longer.") },
},

wilson_wanda = {
  { L("旺达，你像总比别人早一步。", "Wanda, you seem one step ahead of everyone."),
    L("不是早一步，是多看几步。", "Not ahead. Merely looking further.") },

  { L("你总像知道接下来会怎样。", "You always look like you know what's next."),
    L("知道一点，已经够人头疼了。", "Knowing a little is headache enough.") },

  { L("时间在你嘴里像种材料。", "You speak of time like it's a material."),
    L("它确实能被浪费，也能被用坏。", "It can be wasted, and badly used.") },

  { L("你这观点，很值得做笔记。", "That sounds worth writing down."),
    L("记吧，前提是别太晚懂。", "By all means. Just don't understand too late.") },

  { L("你算问题时，会算上自己吗？", "Do you include yourself in your calculations?"),
    L("很遗憾，我常是代价本身。", "Regrettably, I'm often part of the cost.") },

  { L("你说话总让人想认真些。", "You make people want to take things seriously."),
    L("那至少没白费我的口舌。", "Then at least my words weren't wasted.") },
},

wendy_wanda = {
  { L("旺达，你看起来很累。", "Wanda, you look tired."),
    L("时间久了，谁都会显旧。", "Given enough time, everyone wears thin.") },

  { L("你像很久没停下来过。", "You seem like you've never really stopped."),
    L("停下有时，比前进更危险。", "Sometimes stopping is the greater danger.") },

  { L("你眼里，总像有很多旧事。", "There always seem to be old things in your eyes."),
    L("旧事多了，人就不敢慢看。", "Too many old things make one afraid to linger.") },

  { L("你是不是也常想从前？", "Do you also dwell on the past often?"),
    L("想，但不会让它看出来。", "I do. I simply refuse to show it.") },

  { L("你说话冷，可不像无情。", "You speak coldly, but not without feeling."),
    L("太热的心，容易误了时机。", "A heart too warm tends to miss its timing.") },

  { L("……你比看上去温柔一点。", "...You're gentler than you seem."),
    L("那就当你今天看得很准。", "Then let's say your eye is sharp today.") },
},

wathgrithr_wanda = {
  { L("旺达！你的目光像老将！", "Wanda! Your gaze is that of a veteran!"),
    L("老将通常只是活得够久。", "Veterans are often just the ones who lasted.") },

  { L("你为何总劝人莫要急战？", "Why do you always caution against rushing battle?"),
    L("因为冲早了，尸体也会很快。", "Because an early charge hastens the corpse.") },

  { L("哈！你说话真冷，却很准！", "Ha! Your words are cold, yet true!"),
    L("准确比热血更能保命。", "Accuracy keeps people alive better than fervor.") },

  { L("你像在等命运先出招！", "You seem to wait for fate to strike first!"),
    L("先看清它，赢面才像样。", "One should read fate first, then answer properly.") },

  { L("若我先冲，你会拦我吗！", "If I charge too soon, would you stop me!"),
    L("会。前提是你还来得及听。", "Yes. Assuming you're still in time to hear me.") },

  { L("好！你来断时机，我来斩敌！", "Good! You judge the moment, I strike the foe!"),
    L("这分工，听起来还能活久些。", "That arrangement sounds survivable.") },
},

wolfgang_wanda = {
  { L("旺达，你看起来总很忙。", "Wanda, you always look busy."),
    L("忙着不让事情更糟。", "Busy preventing things from getting worse.") },

  { L("你总皱眉，是不是很累？", "You frown a lot. Are you tired?"),
    L("累是常事，误时才麻烦。", "Tired is common. Mistiming is trouble.") },

  { L("沃尔夫冈能帮你打坏东西！", "Wolfgang can smash bad things for you!"),
    L("很好，关键时别太早上。", "Good. Just don't go in too early.") },

  { L("你说话像老师，又像医生。", "You sound like a teacher and a doctor."),
    L("那说明我今天还算清醒。", "Then I must still be thinking clearly today.") },

  { L("你是不是总担心很多事？", "Do you worry about too many things?"),
    L("有人总得替明天发愁。", "Someone has to worry for tomorrow.") },

  { L("旺达别怕，沃尔夫冈在！", "Wanda, don't be afraid. Wolfgang is here!"),
    L("……这话我就收下了。", "...That, I'll accept gladly.") },
},

wormwood_wanda = {
  { L("旺达，叶子说你很累。", "Wanda, the leaves say you're tired."),
    L("它们眼力倒比人好。", "They do seem sharper than people.") },

  { L("你走得快。像风追你。", "You walk fast. Like wind is chasing you."),
    L("差不多，是时间在追。", "Close enough. It's time doing the chasing.") },

  { L("时间会咬人吗？", "Does time bite?"),
    L("会。只是咬得很安静。", "Yes. It simply bites very quietly.") },

  { L("植物人可以陪你慢一点。", "Wormwood can help you go slower."),
    L("……这提议，比药还管用。", "...That helps more than medicine.") },

  { L("你看花时，会轻一点。", "You soften when you look at flowers."),
    L("至少它们不催我向前。", "At least they never rush me forward.") },

  { L("今天也要记得晒太阳。", "Remember to get some sunlight today."),
    L("好，我尽量别只顾钟表。", "I will. I'll try not to watch only clocks.") },
},

waxwell_wanda = {
  { L("旺达，你看起来很懂代价。", "Wanda, you look like someone who knows costs."),
    L("懂得太多，并不算幸事。", "Knowing too much is rarely fortunate.") },

  { L("你说话像已经输过很多次。", "You speak like someone who's lost often."),
    L("输久了，口气总会变准。", "After enough losses, precision becomes habit.") },

  { L("你总像在评估每个人。", "You always seem to be assessing everyone."),
    L("评估比后悔来得便宜。", "Assessment costs less than regret.") },

  { L("真少见，有人比我还冷。", "How unusual. Someone colder than I am."),
    L("我只是把热度留给必要时。", "I simply save warmth for necessity.") },

  { L("你对自己，似乎格外苛刻。", "You seem especially hard on yourself."),
    L("因为我知道误差会害死人。", "Because I know mistakes can kill.") },

  { L("呵，你倒是值得聊几句。", "Heh. You are at least worth speaking with."),
    L("那就别把这评价浪费了。", "Then don't waste the compliment.") },
},

willow_wanda = {
  { L("旺达，你总像在算什么。", "Wanda, you always look like you're calculating."),
    L("在算哪一刻最不该失手。", "I'm calculating when failure costs most.") },

  { L("你连发呆都像在赶时间。", "Even your daydreaming looks rushed."),
    L("因为我通常确实在赶。", "Because I usually am.") },

  { L("你会不会也想直接烧了算？", "Do you ever want to just burn it all?"),
    L("想过，但收拾残局更麻烦。", "I've considered it. The aftermath is tedious.") },

  { L("哈，你比我还会扫兴。", "Ha. You're even better than me at ruining fun."),
    L("有人总得替明天着想。", "Someone has to think about tomorrow.") },

  { L("你看火时，眼神也会变。", "Even your eyes change when you look at fire."),
    L("火和时间一样，都不等人。", "Fire and time share a habit: they wait for no one.") },

  { L("你这人真适合讲坏消息。", "You're really built for bad news."),
    L("至少我会挑个合适时候。", "At least I'd deliver it at the proper moment.") },
},

wickerbottom_wanda = {
  { L("旺达，你对时间很执着。", "Wanda, you are unusually preoccupied with time."),
    L("吃过亏的人，总会更上心。", "Those who've paid dearly tend to be.") },

  { L("你总像在修正某种误差。", "You always seem to be correcting some error."),
    L("误差若大了，命都不稳。", "If the margin grows, lives become unstable.") },

  { L("你的判断，往往相当克制。", "Your judgment is often admirably restrained."),
    L("冲动通常只会抬高代价。", "Impulse usually raises the price.") },

  { L("你很少说废话，这很好。", "You rarely waste words. That's good."),
    L("秒针不等人，话也该简短。", "Seconds wait for no one. Speech should follow suit.") },

  { L("你看事情，总带点宿命感。", "You view things with a touch of fatalism."),
    L("只是见过太多重复的错。", "I've simply seen too many repeated mistakes.") },

  { L("我欣赏你的清醒，旺达。", "I appreciate your clarity, Wanda."),
    L("那就算今天没白开口。", "Then today's words weren't wasted.") },
},

winona_wanda = {
  { L("旺达，你做事挺卡点的。", "Wanda, you've got excellent timing."),
    L("卡得不准，后面都得返工。", "Miss the mark and everything becomes rework.") },

  { L("你像那种不爱出错的人。", "You strike me as someone who hates mistakes."),
    L("我更讨厌出错后的代价。", "I hate their consequences more.") },

  { L("你总先看局面，再动手。", "You always read the situation first."),
    L("先看清，能省很多麻烦。", "Seeing clearly first saves trouble later.") },

  { L("跟你搭伙，心里挺稳的。", "Working with you feels steady."),
    L("那说明我还算没失准。", "Then I must still be on target.") },

  { L("你不爱废话，这点真好。", "You don't waste breath. I like that."),
    L("活多的时候，话该更少。", "When there's work, words should shrink.") },

  { L("有空教我你那套判断呗。", "You'll have to teach me that judgment of yours."),
    L("可以，只要你别嫌太冷。", "Gladly, if you don't mind the chill.") },
},

wortox_wanda = {
  { L("旺达，你一开口我就紧张。", "Wanda, you make me nervous when you start talking."),
    L("那说明你多少还有点判断。", "Then your instincts still function.") },

  { L("你总像提前看过坏结局。", "You always sound like you've seen the bad ending."),
    L("看过几次，人就学乖了。", "See enough of them and one learns.") },

  { L("你说话冷，可我不讨厌。", "Your words are cold, but I don't mind them."),
    L("那是因为我留了分寸。", "That is because I leave room for mercy.") },

  { L("你像连安慰都算过时机。", "You sound like even comfort gets timed."),
    L("安慰太早太晚，都没用。", "Too early or too late, and it's useless.") },

  { L("有你在，我都不敢太慌。", "With you around, I panic a little less."),
    L("很好，慌也该选对时候。", "Good. Panic should at least be scheduled.") },

  { L("你真是我见过最难糊弄的人。", "You're the hardest person to bluff I've met."),
    L("那就省点力气，别试了。", "Then save yourself the effort and don't.") },
},

wes_wanda = {
  { L("旺达，你看起来总在赶路。", "Wanda, you always look in transit."),
    L("（点头，轻叹了一声）", "(nods, then sighs softly)") },

  { L("你是不是很少真正放松？", "Do you ever really relax?"),
    L("（摊手，轻轻摇头）", "(spreads hands and shakes her head lightly)") },

  { L("我猜你连沉默都算时间。", "I suspect you even measure silence."),
    L("（微怔后，点了点头）", "(pauses in surprise, then nods)") },

  { L("你这样活着，不轻松吧。", "Living like that can't be easy."),
    L("（低头一笑，又耸了耸肩）", "(smiles faintly, then shrugs)") },

  { L("不过你还是很可靠。", "Even so, you're very reliable."),
    L("（轻轻一礼，神情柔和）", "(gives a small bow, expression softening)") },

  { L("别太累了，旺达。", "Don't wear yourself out, Wanda."),
    L("（停了一下，认真点头）", "(pauses, then nods seriously)") },
},

walter_wilson = {
  { L("威尔逊，这算科学还是冒险？", "Wilson, is this science or adventure?"),
    L("两者兼具，理想状态。", "Both. Ideally.") },
  { L("我写日志会加点故事，可以吗？", "I add stories to my logs, is that okay?"),
    L("只要注明假设，就没问题。", "As long as it's labeled hypothesis.") },
  
},

walter_wendy = {
  { L("温蒂，这里有点吓人…你觉得呢？", "Wendy, this place is a bit scary... right?"),
    L("…只是安静得太深了…", "...Just too quiet...") },
  { L("一起走会不会好一点？", "Would it be better if we walk together?"),
    L("…至少不会那么孤单…", "...At least not alone...") },
},

walter_wathgrithr = {
  { L("薇格弗德，你真的不怕吗？", "Wigfrid, you're really not afraid?"),
    L("恐惧只配成为踏板！", "Fear is but a stepping stone!") },
  { L("我用弹弓可以吗…", "Is using a slingshot okay..."),
    L("战意为王，武器其次！", "Spirit first, weapon second!") },
},

walter_wolfgang = {
  { L("沃尔夫冈，你太强了吧。", "Wolfgang, you're really strong."),
    L("当然！沃尔夫冈最强！", "Of course! Wolfgang strongest!") },
  { L("你会等我吗？", "Will you wait for me?"),
    L("会！然后抱你跑！", "Yes! Then carry you!") },
},

walter_wormwood = {
  { L("你喜欢这里吗？", "Do you like it here?"),
    L("这里有朋友（草）", "Friends here (grass)") },
  { L("我有点紧张…", "I'm a bit nervous..."),
    L("别怕，地会接住你", "Don't worry, ground holds you") },
},

walter_warly = {
  { L("这里能做饭吗？", "Can we cook here?"),
    L("当然，只要有合适的食材。", "Of course, with proper ingredients.") },
  { L("探险配热饭是不是更好？", "Adventure is better with warm food, right?"),
    L("你说得非常对。", "Absolutely.") },
},

walter_waxwell = {
  { L("你看起来…有点可怕。", "You look... a bit scary."),
    L("那是应有之态。", "As it should be.") },
  { L("你真的控制这些东西吗？", "Do you really control all this?"),
    L("当然。你不需要知道细节。", "Of course. Details are unnecessary for you.") },
},

walter_wes = {
  { L("呃…你好？", "Uh... hello?"),
    L("（挥手）", "(waves)") },
  { L("你也在探险吗？", "Are you exploring too?"),
    L("（点头）", "(nods)") },
},

walter_woodie = {
  { L("这里树好多啊。", "There are a lot of trees here."),
    L("是啊，小子，这才像样。", "Yeah kid, that's proper land.") },
  { L("砍树很重要吗？", "Is chopping trees important?"),
    L("你迟早会知道的。", "You'll learn soon enough.") },
},

walter_willow = {
  { L("火…是不是有点危险？", "Fire... is it a bit dangerous?"),
    L("危险才有意思！", "That's what makes it fun!") },
  { L("我还是离远一点吧…", "I'll stay a bit away..."),
    L("胆小鬼。", "Scaredy-cat.") },
},

walter_wickerbottom = {
  { L("我在写探险日志。", "I'm writing an expedition log."),
    L("很好，记录是知识的开始。", "Good. Documentation is the beginning of knowledge.") },
  { L("我有时候会乱写一点…", "Sometimes I make things up..."),
    L("那就标注清楚。", "Then annotate it properly.") },
},

walter_winona = {
  { L("这些东西是你做的吗？", "Did you build these?"),
    L("是的，实用第一。", "Yep. Function first.") },
  { L("我能帮忙吗？", "Can I help?"),
    L("别添乱就行。", "Just don't mess it up.") },
},

walter_webber = {
  { L("呃…你们是…朋友吗？", "Uh... are you... friends?"),
    L("我们是大家。", "We are everyone.") },
  { L("你不会吃我吧？", "You won't eat me, right?"),
    L("看情况。", "Depends.") },
},

walter_wurt = {
  { L("这里是你的地盘吗？", "Is this your territory?"),
    L("是！走开！", "Yes! Go away!") },
  { L("我只是路过…", "I'm just passing by..."),
    L("哼。小心点。", "Hmph. Watch it.") },
},

walter_wortox = {
  { L("你是…在笑吗？", "Are you... smiling?"),
    L("呵，看你怎么理解。", "Heh, depends how you see it.") },
  { L("你会帮忙吗？", "Will you help?"),
    L("也许会。也许不会。", "Maybe. Maybe not.") },
},

walter_wanda = {
  { L("你看起来很着急。", "You seem in a hurry."),
    L("时间不等人。", "Time waits for no one.") },
  { L("我们是不是在浪费时间？", "Are we wasting time?"),
    L("一直都是。", "Always.") },
},
wilson_walter = {
  { L("你的日志方法很独特。", "Your logging method is unique."),
    L("我会加点故事进去。", "I add some story to it.") },
},

wendy_walter = {
  { L("…你总是在写东西…", "...You keep writing..."),
    L("这样就不那么可怕了。", "It makes things less scary.") },
},

wathgrithr_walter = {
  { L("少年！直面战斗！", "Boy! Face battle!"),
    L("我在…努力！", "I'm... trying!") },
},

wolfgang_walter = {
  { L("你太小！要多吃！", "You too small! Eat more!"),
    L("我、我会的！", "I-I will!") },
},

wormwood_walter = {
  { L("你会怕？", "You afraid?"),
    L("有一点…", "A little...") },
},

warly_walter = {
  { L("你需要热食。", "You need warm food."),
    L("那会让我安心很多。", "That would help a lot.") },
},

waxwell_walter = {
  { L("你不属于这里。", "You don't belong here."),
    L("我在适应。", "I'm trying to.") },
},

wes_walter = {
  { L("（拍拍你）", "(pats you)"),
    L("呃…谢谢？", "Uh... thanks?") },
},

woodie_walter = {
  { L("别走丢了，小子。", "Don't get lost, kid."),
    L("我会跟紧的。", "I will.") },
},

willow_walter = {
  { L("你怕火？", "You afraid of fire?"),
    L("有一点…", "A little...") },
},

wickerbottom_walter = {
  { L("记录要规范。", "Keep proper records."),
    L("我会改进的。", "I'll improve.") },
},

winona_walter = {
  { L("别挡路。", "Don't get in the way."),
    L("好、好的。", "O-okay.") },
},

webber_walter = {
  { L("你闻起来不像我们。", "You don't smell like us."),
    L("那是好事吗？", "Is that good?") },
},

wurt_walter = {
  { L("你很弱。", "You weak."),
    L("我在变强…", "I'm getting stronger...") },
},

wortox_walter = {
  { L("你挺有意思。", "You're interesting."),
    L("谢谢…？", "Thanks...?") },
},

wanda_walter = {
  { L("别浪费时间。", "Don't waste time."),
    L("我在赶上进度。", "I'm trying to keep up.") },
},

wonkey_wilson = {
  { L("吱吱！你会把香蕉变多吗？", "Ook ook! Can you make more bananas?"),
    L("严格来说，那属于农业，不是炼金术。", "Strictly speaking, that's agriculture, not alchemy.") },
},

wilson_wonkey = {
  { L("你的转化现象非常值得研究。", "Your transformation phenomenon is very worth studying."),
    L("吱？研究完有香蕉吗？", "Ook? Bananas after study?") },
},

wonkey_wendy = {
  { L("我给你香蕉，你开心一点？", "I give banana. You happier?"),
    L("…谢谢…它至少是温暖的颜色…", "...Thank you... at least it is a warm color...") },
},

wendy_wonkey = {
  { L("…你像一场吵闹的梦。", "...You are like a noisy dream."),
    L("梦里有香蕉吗？", "Are there bananas in dream?") },
},

wonkey_wathgrithr = {
  { L("吱吱！大嗓门！你吓到树了！", "Ook ook! Loud voice! You scared the trees!"),
    L("那是战士的气势！连树也应当敬畏！", "That is a warrior's spirit! Even trees should tremble!") },
},

wathgrithr_wonkey = {
  { L("猴之战友！随我冲锋！", "Monkey comrade! Charge with me!"),
    L("冲锋？我先找树！", "Charge? I find tree first!") },
},

wonkey_wolfgang = {
  { L("大个子！你能举起香蕉树吗？", "Big one! Can you lift banana tree?"),
    L("沃尔夫冈可以！但为什么要举树？", "Wolfgang can! But why lift tree?") },
},

wolfgang_wonkey = {
  { L("小猴子太瘦！要多吃！", "Little monkey too thin! Eat more!"),
    L("我吃香蕉！也偷一点点。", "I eat bananas! Also steal tiny bit.") },
},

wonkey_wormwood = {
  { L("绿绿朋友，你知道哪里有香蕉吗？", "Green friend, know where bananas are?"),
    L("黄朋友？也许在树上。", "Yellow friends? Maybe in tree.") },
},

wormwood_wonkey = {
  { L("不要扯叶子。叶子会疼。", "Don't pull leaves. Leaves hurt."),
    L("不扯不扯！只找香蕉！", "No pull! Only find bananas!") },
},

wonkey_warly = {
  { L("大厨！香蕉可以做好吃的吗？", "Chef! Can bananas be tasty?"),
    L("当然，香蕉也值得精心料理。", "Of course. Bananas deserve careful preparation too.") },
},

warly_wonkey = {
  { L("请不要把食材塞进尾巴后面。", "Please do not hide ingredients behind your tail."),
    L("不是藏，是保存！", "Not hiding. Saving!") },
},

wonkey_waxwell = {
  { L("黑衣人，你身上有亮亮东西。", "Dark man, you have shiny things."),
    L("碰一下试试，我会让你后悔。", "Touch them and I will make you regret it.") },
},

waxwell_wonkey = {
  { L("把你的爪子从我的财物上拿开。", "Keep your paws off my possessions."),
    L("爪子自己喜欢亮亮的！", "Paws like shiny by themselves!") },
},

wonkey_wes = {
  { L("吱？你不说话？那我多说点！", "Ook? You don't talk? Then I talk more!"),
    L("（用力点头，又摆了个夸张姿势）", "(nods hard, then strikes an exaggerated pose)") },
},

wes_wonkey = {
  { L("（模仿猴子跳了两下）", "(mimics a monkey with two little hops)"),
    L("吱吱！你学得很像！", "Ook ook! You learn good!") },
},

wonkey_woodie = {
  { L("胡子人，你砍树，我心慌。", "Beard man, you chop trees. I nervous."),
    L("放心，我知道哪些该砍，哪些该留。", "Relax, I know which to chop and which to leave.") },
},

woodie_wonkey = {
  { L("你偷走露西，我可会追到天边。", "If you steal Lucy, I'll chase you to the ends of the earth."),
    L("不偷斧头！斧头会生气！", "No steal axe! Axe gets angry!") },
},

wonkey_willow = {
  { L("火女孩，别烧香蕉树！", "Fire girl, don't burn banana trees!"),
    L("哼，我会挑更有趣的东西烧。", "Hmph, I'll pick something more interesting to burn.") },
},

willow_wonkey = {
  { L("你跑得挺快嘛，猴子。", "You run pretty fast, monkey."),
    L("因为火跑更快！", "Because fire runs faster!") },
},

wonkey_wickerbottom = {
  { L("书婆婆，书里有香蕉地图吗？", "Book granny, do books have banana maps?"),
    L("请称呼我为女士。至于地图，也许有。", "Please address me as madam. As for maps, perhaps.") },
},

wickerbottom_wonkey = {
  { L("你的注意力需要训练。", "Your attention span requires training."),
    L("我有注意！注意香蕉！", "I pay attention! To bananas!") },
},

wonkey_winona = {
  { L("工具姐姐，亮亮螺丝可以拿吗？", "Tool sister, can I take shiny screws?"),
    L("不行，那是要用的。手拿开。", "Nope, I need those. Hands off.") },
},

winona_wonkey = {
  { L("别把零件藏起来，我还要装回去。", "Don't hide the parts. I need to put them back."),
    L("我只是帮它们换地方！", "I just help them move!") },
},

wonkey_webber = {
  { L("好多脚！你爬树快吗？", "Many legs! You climb trees fast?"),
    L("我们爬得很好。", "We climb well.") },
},

webber_wonkey = {
  { L("你闻起来像树和香蕉皮。", "You smell like trees and banana peels."),
    L("这是好闻！", "That is good smell!") },
},

wonkey_wurt = {
  { L("鱼女孩，这里有香蕉吗？", "Fish girl, bananas here?"),
    L("没有！这里是沼泽，不是猴子窝！", "No! This swamp, not monkey nest!") },
},

wurt_wonkey = {
  { L("猴子不准偷鱼！", "Monkey no steal fish!"),
    L("不偷鱼，鱼滑滑的！", "No steal fish. Fish slippery!") },
},

wonkey_wortox = {
  { L("小角角，你笑起来像偷到东西。", "Little horns, you smile like you stole something."),
    L("这话从你嘴里说出来，真有意思。", "That is amusing coming from you.") },
},

wortox_wonkey = {
  { L("你这尾巴一晃，我就知道要出事。", "When your tail swishes, I know trouble is coming."),
    L("不是出事，是好玩！", "Not trouble. Fun!") },
},

wonkey_wanda = {
  { L("钟表姐姐，时间能换香蕉吗？", "Clock sister, can time trade for bananas?"),
    L("如果可以，我早就换完了。", "If it could, I would have spent it already.") },
},

wanda_wonkey = {
  { L("别碰我的表，哪怕它很亮。", "Do not touch my watch, however shiny it is."),
    L("我只看！手有点想碰。", "I only look! Hands want touch a little.") },
},

wonkey_walter = {
  { L("探险小孩，你包里有香蕉吗？", "Explorer kid, bananas in your pack?"),
    L("呃…探险口粮不一定是香蕉。", "Uh... expedition rations aren't always bananas.") },
},

walter_wonkey = {
  { L("芜猴！你能教我爬树侦查吗？", "Wonkey! Can you teach me treetop scouting?"),
    L("先学会抓紧！再学会找香蕉！", "First learn hold tight! Then learn find bananas!") },
},

wonkey_wonkey = {
  { L("吱吱！你也喜欢香蕉？", "Ook ook! You like bananas too?"),
    L("最喜欢！先到先拿！", "Most like! First come first take!") },
},
    -- Wilba 主动 → Wilson
    wilba_wilson = {
      { L("威尔逊，本公主今天是不是又美了？说实话！", "Wilson, isn't the princess even more beautiful today? Tell the truth!"),
        L("从科学角度讲，你的色素分布确实很对称。", "Scientifically speaking, your pigment distribution is quite symmetrical.") },
      { L("本公主想要一个闪亮的新王冠，你能用你的科学做一个吗？", "The princess wants a shiny new crown. Can your science make one?"),
        L("理论上可以，但我更擅长做温度计。", "Theoretically, yes, but I'm better at thermometers.") },
      { L("你那些试管和烧杯，有本公主的宝石好看吗？", "Are your test tubes and beakers prettier than the princess's gems?"),
        L("不同种类，不可比较……不过你的宝石确实闪。", "Different categories, incomparable... but your gems are indeed shiny.") },
      { L("本公主准许你研究我的毛发，但只能看，不能碰！", "The princess permits you to study her fur, but look only, no touching!"),
        L("这条件可真严格，我尽量不用放大镜凑太近。", "Those are very strict terms. I'll try not to get the magnifying glass too close.") },
      { L("威尔逊，你什么时候才能变得像本公主一样优雅？", "Wilson, when will you become as elegant as the princess?"),
        L("按目前的实验进度……大概需要重新投胎一次。", "At the current rate... probably a full reincarnation.") },
  },

  -- Wilba 主动 → Wendy
  wilba_wendy = {
      { L("温蒂，你总这么忧郁，是嫉妒本公主的美貌吗？", "Wendy, are you always so gloomy because you envy the princess's beauty?"),
        L("…不。只是美和丑，最后都会消失。", "...No. Beauty and ugliness both fade in the end.") },
      { L("本公主送你一朵花吧，配上你的脸色正好。", "The princess will give you a flower. It matches your complexion perfectly."),
        L("…谢谢。花会谢，就像人一样。", "...Thanks. Flowers wilt, like people do.") },
      { L("你那个妹妹阿比盖尔，她有没有本公主漂亮？", "That sister of yours, Abigail, is she as pretty as the princess?"),
        L("…阿比盖尔的美…是另一种，你看不见的。", "...Abigail's beauty is... different. You cannot see it.") },
      { L("本公主可以教你打扮，让你看起来开心一点。", "The princess can teach you how to dress up, make you look happier."),
        L("…不必了，黑色很适合我。", "...No need. Black suits me just fine.") },
      { L("温蒂，笑一个嘛，本公主准你笑。", "Wendy, give a smile. The princess permits it."),
        L("…（勉强牵动嘴角）…这样可以了吗。", "...(forces a faint smile) ...Is this enough?") },
  },

  -- Wilba 主动 → Wathgrithr
  wilba_wathgrithr = {
      { L("女武神，本公主的战吼比你优雅多了，想听听吗？", "Valkyrie, the princess's battle cry is far more elegant than yours. Want to hear it?"),
        L("吼叫不在优雅，在于气势！但你喊一声也无妨！", "A cry is about power, not elegance! But give it a shout anyway!") },
      { L("本公主的盔甲要是镶上宝石，一定比你的闪亮。", "If the princess's armor were studded with gems, it would be shinier than yours."),
        L("宝石挡不住刀剑，战士的铁甲才是真荣耀！", "Gems won't stop a blade. A warrior's steel is true glory!") },
      { L("你打架总喊那么大声，不会把嗓子喊哑吗？本公主可舍不得。", "You shout so loud when fighting. Won't you lose your voice? The princess would never risk that."),
        L("哈！女武神的嗓音战不坏！倒是你，敢上阵吗？", "Ha! A Valkyrie's voice never breaks! But you, would you dare join the fray?") },
      { L("本公主如果上战场，敌人肯定会被我的美貌迷惑，不战而败。", "If the princess went to battle, the enemy would be mesmerized by her beauty and surrender without a fight."),
        L("哼！那你先上，我看看他们会不会跪着投降！", "Hmph! You go first, let's see if they kneel!") },
      { L("女武神，你头盔上的角不错，但本公主的皇冠更好看。", "Valkyrie, the horns on your helmet are nice, but the princess's crown is prettier."),
        L("各有所长！你的皇冠能砸人吗？", "Each has its strengths! Can your crown bash skulls?") },
  },

  -- Wilba 主动 → Wolfgang
  wilba_wolfgang = {
      { L("大个子，你觉得本公主漂亮吗？说真心话！", "Big one, does the princess look beautiful? Be honest!"),
        L("沃尔夫冈觉得你像闪闪发光的……大南瓜！", "Wolfgang thinks you are like a shiny... big pumpkin!") },
      { L("本公主的力气虽然没你大，但优雅程度你永远追不上。", "The princess may not be as strong as you, but you'll never match her elegance."),
        L("优雅是什么？可以吃吗？", "What is elegance? Can Wolfgang eat it?") },
      { L("沃尔夫冈，你吃东西的样子太难看了，本公主来教你优雅地吃。", "Wolfgang, your eating manners are terrible. Let the princess teach you how to eat elegantly."),
        L("可是小口吃会饿！沃尔夫冈要大口吃！", "But small bites make Wolfgang hungry! Wolfgang needs big bites!") },
      { L("本公主要是有你的肌肉，那一定是最美的肌肉公主。", "If the princess had your muscles, she'd be the most beautiful muscular princess."),
        L("那沃尔夫冈帮你举东西！你负责漂亮！", "Then Wolfgang lift things for you! You stay pretty!") },
      { L("你这么壮，当本公主的保镖正合适。明天开始上班！", "You're so strong, you'd make a perfect bodyguard for the princess. Start tomorrow!"),
        L("好！保镖管饭吗？沃尔夫冈要吃很多！", "Okay! Does bodyguard get food? Wolfgang needs lots!") },
  },

  -- Wilba 主动 → Wormwood
  wilba_wormwood = {
      { L("小草人，本公主漂亮还是你的花漂亮？", "Little plant, is the princess prettier or your flowers?"),
        L("花漂亮。你……也漂亮。不一样。", "Flowers pretty. You... also pretty. Different.") },
      { L("你身上怎么没有闪亮的东西？本公主送你一颗宝石吧。", "Why don't you have anything shiny on you? The princess will give you a gem."),
        L("宝石硬硬的。植物人喜欢软软的土。", "Gems hard. Wormwood likes soft soil.") },
      { L("本公主的叶子要是像你一样绿，那一定更好看。", "If the princess's leaves were as green as yours, she'd look even better."),
        L("你没有叶子。你只有毛。毛也好看。", "You no leaves. You have fur. Fur also nice.") },
      { L("小草人，能不能帮本公主种一颗会发光的树？", "Little plant, can you grow a glowing tree for the princess?"),
        L("可以试试。要有光，要有种子。", "Can try. Need light, need seed.") },
      { L("你说话好短，本公主都快听不懂了。再说明白点！", "You speak so short, the princess can barely understand. Say it clearer!"),
        L("你漂亮。土喜欢。", "You pretty. Soil likes you.") },
  },

  -- Wilba 主动 → Waxwell
  wilba_waxwell = {
      { L("黑衣人，你那些影子仆从有本公主闪亮吗？", "Dark-clothed one, are your shadow servants as shiny as the princess?"),
        L("闪亮？影子从不闪亮。那是你的世界的事。", "Shiny? Shadows never shine. That's a concern of your world.") },
      { L("本公主觉得你的帽子不够气派，要不要试试本公主的备用王冠？", "The princess thinks your hat isn't grand enough. Want to try her spare crown?"),
        L("不需要。我的帽子配我的身份。", "Unnecessary. My hat suits my status.") },
      { L("你总是板着脸，是不是嫉妒本公主比你受欢迎？", "You're always frowning. Is it because you envy the princess for being more popular?"),
        L("呵，我从不嫉妒任何人，尤其是……你这样的小猪。", "Heh, I never envy anyone, least of all... a little pig like you.") },
      { L("本公主命令你把暗影魔法教给我，我要用影子来照镜子！", "The princess commands you to teach her shadow magic, she wants to use shadows as mirrors!"),
        L("暗影不会反射虚荣，只会映出你的内心。你确定想看？", "Shadows don't reflect vanity, only your soul. Are you sure you want to see?") },
      { L("麦斯威尔，承认吧，本公主比你的王座时代更有魅力。", "Maxwell, admit it, the princess has more charm than your throne era."),
        L("魅力？哼，你连自己都保护不了，还敢谈魅力？", "Charm? Hmph, you can't even protect yourself, and you talk of charm?") },
  },

  -- Wilba 主动 → Willow
  wilba_willow = {
      { L("火女，你那些火焰有本公主的宝石亮吗？", "Fire girl, are your flames as bright as the princess's gems?"),
        L("火焰可比宝石亮多了，还能取暖，你的宝石能吗？", "Fire's way brighter than gems, and it keeps you warm. Can your gems do that?") },
      { L("本公主要警告你，离我的披风远一点，烧了你可赔不起。", "The princess warns you, stay away from her cape. You can't afford to burn it."),
        L("切，烧了就烧了，反正你还有好几件吧？", "Tch, burn it, you've got plenty more, right?") },
      { L("薇洛，你能不能控制一下自己，别老想着放火，想想怎么变美。", "Willow, can you control yourself and stop thinking about fire? Think about how to become beautiful instead."),
        L("我本来就美，不需要火来证明。倒是你，小心别把自己烤焦了。", "I'm already beautiful, don't need fire to prove it. You'd better watch out or you'll get roasted.") },
      { L("本公主如果点火，一定是最优雅的火。要不要比一下？", "If the princess lit a fire, it would be the most elegant fire. Want to compete?"),
        L("行啊，你点你的优雅火，我点我的暴力火，看谁先烧光一片林子！", "Sure, you light your elegant fire, I'll light my violent fire, let's see who clears a forest first!") },
      { L("薇洛，你的头发乱糟糟的，本公主可以借你一把梳子。", "Willow, your hair is a mess. The princess can lend you a comb."),
        L("不用，我就喜欢乱的。你管好你自己的猪鬃吧！", "No thanks, I like it messy. You take care of your own pig bristles!") },
  },

  -- Wilba 主动 → Wickerbottom
  wilba_wickerbottom = {
      { L("老奶奶，书里有写本公主这么漂亮的人吗？", "Old lady, do your books mention anyone as beautiful as the princess?"),
        L("有，但那些多是神话传说，而且通常结局不太好。", "Yes, but they're mostly myths, and their endings aren't usually happy.") },
      { L("本公主要你写一本《猪人公主传》，把我写得美美的。", "The princess wants you to write a 'Pig Princess Chronicle' and make her sound gorgeous."),
        L("传记需要真实性，恐怕会包含你弄脏裙子和打嗝的细节。", "Biographies require authenticity, which would include details about your dirty skirt and burping.") },
      { L("你不觉得本公主比任何书本知识都有趣吗？", "Don't you think the princess is more interesting than any book knowledge?"),
        L("有趣和有用是两回事。你能帮我整理书架吗？", "Interesting and useful are different. Can you help me organize the bookshelves?") },
      { L("老奶奶，你年轻时是不是也像本公主一样美？", "Old lady, were you as beautiful as the princess when you were young?"),
        L("我年轻时更注重学识，容貌只是其次。不过……谢谢你的好意。", "I valued knowledge more than looks. But... thank you for the sentiment.") },
      { L("本公主要借你一本书，关于珠宝鉴定的。", "The princess wants to borrow a book about gem appraisal from you."),
        L("可以，先交押金：一颗紫宝石。", "Fine, a deposit first: one purple gem.") },
  },

  -- Wilba 主动 → Woodie
  wilba_woodie = {
      { L("伐木工，你砍树的声音太吵了，打扰到本公主休息了。", "Lumberjack, your chopping is too loud. It's disturbing the princess's rest."),
        L("抱歉啊，公主殿下，要不您离远点儿？", "Sorry, Your Highness, maybe you could stand farther away?") },
      { L("你的斧头露西，有本公主的梳子漂亮吗？", "Is your axe Lucy prettier than the princess's comb?"),
        L("露西不喜欢比美，她只关心木头。", "Lucy doesn't care about beauty contests, she only cares about wood.") },
      { L("本公主要你用最好的木头给我做一把梳子。", "The princess wants you to use the best wood to make her a comb."),
        L("我只会砍树，不会做梳子，您找别人吧。", "I only know how to chop trees, not carve combs. Find someone else, eh.") },
      { L("伐木工，你每天砍树不累吗？本公主看你都替你觉得累。", "Lumberjack, aren't you tired from chopping trees all day? The princess feels tired just watching you."),
        L("习惯了就不累，就像您每天照镜子一样。", "You get used to it, just like you get used to looking in a mirror every day.") },
      { L("本公主允许你砍树的时候哼歌，但是要哼得好听一点。", "The princess permits you to hum while chopping, but it better sound nice."),
        L("行，我尽量不跑调。不过您先示范一个？", "Alright, I'll try not to go off-key. But how about a demonstration first?") },
  },

  -- Wilba 主动 → Warly
  wilba_warly = {
      { L("大厨，本公主今天的午餐要摆盘精美，配得上我的气质。", "Chef, the princess's lunch today must be plated exquisitely, worthy of her bearing."),
        L("当然，我会用食用金箔点缀，让您满意。", "Of course, I'll use edible gold leaf as garnish. You'll be pleased.") },
      { L("本公主想吃甜点，但不能长胖，你能做到吗？", "The princess wants dessert but cannot gain weight. Can you manage that?"),
        L("低糖低脂又美味？这是对我的挑战，我接受。", "Low sugar, low fat, yet delicious? A challenge, but I accept.") },
      { L("你做的食物是本公主吃过第二好吃的。想知道第一是什么吗？", "Your food is the second best the princess has ever eaten. Want to know what's first?"),
        L("愿闻其详。", "Do tell.") },
      { L("第一当然是我自己种的皇家萝卜啦！", "First place is the royal radish I grew myself, of course!"),
        L("那下次请让我料理那些萝卜，一定让您改口说第一。", "Then please let me cook those radishes next time. I'll make you change your vote.") },
      { L("本公主要办一场宴会，你来当主厨，准你露脸。", "The princess is holding a feast. You will be the head chef. You may show your face."),
        L("荣幸之至，我会准备一套闪亮的厨师服配合您的品味。", "Deeply honored. I'll prepare a shiny chef's uniform to match your taste.") },
  },

  -- Wilba 主动 → Winona
  wilba_winona = {
      { L("工头，你能不能用零件给本公主做一个会发光的王冠？", "Foreman, can you use parts to make the princess a glowing crown?"),
        L("能是能，但戴上去可能会漏电，你确定？", "I could, but it might leak electricity. You sure?") },
      { L("你那些机器，有本公主的镜子重要吗？", "Are your machines more important than the princess's mirror?"),
        L("镜子又不能帮你搭房子，机器能。", "A mirror can't build you a house. Machines can.") },
      { L("本公主命令你修好我的随身镜子，它有点花了。", "The princess commands you to fix her hand mirror. It's a little scratched."),
        L("行，但你得答应我别在机器旁边照镜子，会分心。", "Fine, but you have to promise not to use it near my machines. It's distracting.") },
      { L("薇诺娜，你的工作服太丑了，本公主送你一套漂亮的吧。", "Winona, your work clothes are too ugly. The princess will give you a nice set."),
        L("不用，我这套耐脏耐操，你的漂亮裙子可经不起油污。", "No thanks, mine is durable and stain-proof. Your pretty dress won't survive grease.") },
      { L("本公主觉得你比那些机器更有用，因为你会修镜子。", "The princess thinks you're more useful than those machines, because you can fix mirrors."),
        L("这话听着怎么又像夸又像骂的。", "That sounds like both a compliment and an insult.") },
  },

  -- Wilba 主动 → Wortox
  wilba_wortox = {
      { L("小恶魔，你会不会变宝石？本公主想要更多闪亮的东西。", "Little imp, can you conjure gems? The princess wants more shiny things."),
        L("变不了宝石，不过我可以偷一个给你，但被发现了你可别怪我。", "Can't conjure gems, but I could steal one for you. Don't blame me if we're caught.") },
      { L("你总是在笑，是不是被本公主的美貌逗乐的？", "You're always smiling. Is it because the princess's beauty amuses you?"),
        L("算是吧，看到美好的东西当然要笑，难道哭吗？", "I suppose so. Seeing something nice makes you smile, not cry, right?") },
      { L("本公主准许你帮我捶捶肩，轻一点。", "The princess permits you to massage her shoulders. Gently."),
        L("我捶肩可能会顺便拿走你的小镜子哦，你确定？", "If I massage you, I might just take your little mirror too. You sure?") },
      { L("沃拓克斯，你是不是很怕本公主生气？", "Wortox, are you afraid of the princess getting angry?"),
        L("怕，当然怕。生气的公主比怪物还难对付，尤其是会扔宝石砸人的。", "Scared, of course. An angry princess is harder to deal with than a monster, especially one who throws gems.") },
      { L("本公主要你跟着我，当我的开心果。", "The princess wants you to follow her and be her court jester."),
        L("开心果可以，但别让我讲笑话，我只会冷笑话。", "I can do that, but don't ask me to tell jokes. I only know bad ones.") },
  },

  -- Wilba 主动 → Walter
  wilba_walter = {
      { L("小探险家，你有没有见过比本公主更闪亮的东西？", "Little explorer, have you ever seen anything shinier than the princess?"),
        L("有啊，太阳！不过太阳不能跟我说话，所以你还是第二闪亮的。", "Yeah, the sun! But the sun can't talk to me, so you're the second shiniest.") },
      { L("本公主想让你帮我画一幅肖像，要最美的角度。", "The princess wants you to paint her portrait. The most beautiful angle."),
        L("我只会在探险日志里画地图，画人可能像土豆，你确定？", "I only draw maps in my log. People might end up looking like potatoes. You sure?") },
      { L("你的弹弓能打出宝石吗？本公主想要一颗。", "Can your slingshot shoot gems? The princess wants one."),
        L("不能，但如果你给我一颗宝石当子弹，我可以试试。", "No, but if you give me a gem as ammo, I could try.") },
      { L("本公主批准你今晚在我旁边讲故事，但要讲关于公主的故事。", "The princess permits you to tell a story next to her tonight, but it must be about a princess."),
        L("呃，我只会讲冒险故事，公主的故事……我试着编一个？", "Uh, I only know adventure stories. Princess stories... I can try to make one up?") },
      { L("沃尔特，你的沃比能不能让本公主骑一下？", "Walter, can your Woby give the princess a ride?"),
        L("Woby只让我骑，而且它有点怕生……特别是怕猪。", "Woby only lets me ride, and he's a bit scared of strangers... especially pigs.") },
  },

  -- 其他角色主动 → Wilba（部分示例，双向）
  wilson_wilba = {
      { L("公主殿下，你的鬃毛里有一根草，我帮你拿掉？", "Your Highness, there's a blade of grass in your mane. Shall I remove it?"),
        L("大胆！本公主的造型是故意这样的，这叫自然美！", "How dare you! The princess's style is intentional. It's called natural beauty!") },
      { L("我研究过猪猪的毛发，你的保养得最好。", "I've studied pig hair, and yours is the best-maintained."),
        L("哼，算你有眼光。本公主每天都用蜂蜜护发。", "Hmph, at least you have good taste. The princess uses honey conditioner every day.") },
      { L("你的王冠重量是多少？我帮你算算承重。", "What's the weight of your crown? Let me calculate load capacity."),
        L("不重不重，才三颗宝石！本公主的头很金贵。", "Not heavy, only three gems! The princess's head is very precious.") },
      { L("公主，你的镜子被我借去做光学实验了，可以吗？", "Princess, I borrowed your mirror for an optics experiment. That okay?"),
        L("什么？！快还回来！本公主要照镜子！", "What?! Give it back immediately! The princess needs to look at herself!") },
      { L("你身上的香味是……松露？", "That scent on you... is it truffle?"),
        L("呀，你居然闻出来了！本公主特制的松露香水，高贵吧？", "Oh, you can smell it! The princess's special truffle perfume. Nobility, isn't it?") },
  },

  wendy_wilba = {
      { L("你的王冠…映出的光，像黄昏。", "Your crown... the light it reflects is like dusk."),
        L("黄昏？本公主的王冠明明像正午的太阳！", "Dusk? The princess's crown is clearly like the noonday sun!") },
      { L("你总是笑，难道从没难过过？", "You're always smiling. Have you never been sad?"),
        L("本公主这么美，为什么要难过？难过会长皱纹的！", "The princess is so beautiful, why should she be sad? Sadness causes wrinkles!") },
      { L("我教你一首关于死亡的诗歌吧。", "Let me teach you a poem about death."),
        L("不要不要！本公主只学关于美丽和宝石的诗！", "No no! The princess only learns poems about beauty and gems!") },
      { L("你怕不怕有一天镜子碎了，再也看不见自己？", "Are you afraid that one day your mirror will break and you won't see yourself anymore?"),
        L("那就换一面镜子！本公主有很多备用！", "Then get another mirror! The princess has many spares!") },
      { L("阿比盖尔说，你的气场很亮，亮得有点刺眼。", "Abigail says your aura is very bright, almost dazzling."),
        L("哈！那当然，本公主就是耀眼！", "Ha! Naturally, the princess is dazzling!") },
  },

      -- Wilba 主动 → Webber
      wilba_webber = {
        { L("小蜘蛛，你们有几条腿？比本公主的漂亮吗？", "Little spider, how many legs do you have? Are they prettier than the princess's?"),
          L("我们有八条腿，都毛茸茸的，比你光溜溜的蹄子好看！", "We have eight legs, all fuzzy. Prettier than your bare hooves!") },
        { L("本公主命令你织一条闪亮的丝巾给我，用宝石色的丝线。", "The princess commands you to weave her a shiny scarf, with gem-colored silk."),
          L("我们只织网抓猎物，不织围巾。除非你想被缠住当晚餐。", "We only weave webs to catch prey, not scarves. Unless you want to be wrapped up as dinner.") },
        { L("你们会不会变成蝴蝶？本公主喜欢蝴蝶。", "Can you turn into butterflies? The princess likes butterflies."),
          L("蜘蛛就是蜘蛛，不变蝴蝶。蝴蝶不好吃，肉才好吃。", "Spiders are spiders, not butterflies. Butterflies don't taste good. Meat does.") },
        { L("韦伯，你的声音怎么像两个人？本公主有点害怕。", "Webber, why does your voice sound like two people? The princess is a little scared."),
          L("因为我们本来就是两个啊！别怕，我们不吃漂亮的猪，只吃坏的。", "Because we are two! Don't be scared. We don't eat pretty pigs, only bad ones.") },
        { L("本公主可以摸摸你的毛吗？看起来好软。", "Can the princess touch your fur? It looks so soft."),
          L("摸一下要一颗宝石！先付钱再摸。", "One gem per touch! Pay first, then touch.") },
    },

    -- Webber 主动 → Wilba
    webber_wilba = {
        { L("猪公主，你的王冠能不能换很多肉？", "Pig princess, can your crown be traded for lots of meat?"),
          L("放肆！本公主的王冠是无价之宝，不换肉！", "How dare you! The princess's crown is priceless, not for meat!") },
        { L("你身上好香，像我们藏起来的蜂蜜。我们可以舔一下吗？", "You smell so sweet, like the honey we hide. Can we lick you?"),
          L("不行！绝对不行！离本公主远点！", "No! Absolutely not! Stay away from the princess!") },
        { L("猪公主，你能帮我们打蜜蜂吗？我们想吃蜜。", "Pig princess, can you help us fight bees? We want honey."),
          L("本公主这么优雅，怎么会去打架？不过……如果你分我一半蜜，我可以考虑。", "The princess is too elegant to fight. But... if you give me half the honey, I might consider.") },
        { L("你的蹄子好亮，是不是也结了网？", "Your hooves are so shiny. Did you weave webs on them too?"),
          L("本公主用的是皇家蹄油！不是蜘蛛网！", "The princess uses royal hoof oil! Not spider webs!") },
        { L("如果我们把巢搬到你家旁边，你会害怕吗？", "If we move our nest next to your house, would you be scared?"),
          L("当然害怕！不对，本公主什么都不怕！……但你还是别搬过来了。", "Of course scared! No, the princess fears nothing!... but don't move it anyway.") },
    },

    -- Wilba 主动 → Wurt
    wilba_wurt = {
        { L("鱼人妹妹，你的鳞片有本公主的宝石亮吗？", "Fish girl, are your scales as shiny as the princess's gems?"),
          L("沃特的鳞片是绿色的，很亮！你的宝石可以吃吗？", "Wurt's scales are green and bright! Can your gems be eaten?") },
        { L("本公主想去你的沼泽看看，有没有闪亮的珍珠？", "The princess wants to see your swamp. Are there shiny pearls there?"),
          L("沼泽很脏，你会弄脏裙子的。而且珍珠在水底，你不会游泳。", "Swamp is dirty, your dress will get dirty. And pearls are underwater, you can't swim.") },
        { L("沃特，你头上的鱼鳍好可爱，本公主可以摸一下吗？", "Wurt, the fin on your head is so cute. Can the princess touch it?"),
          L("不行！摸了沃特会打你！除非你给一条鱼。", "No! Touch and Wurt will hit you! Unless you give one fish.") },
        { L("本公主想跟你做朋友，你有什么要求？", "The princess wants to be friends with you. What are your terms?"),
          L("每天一条鱼！不，两条！还要帮我赶走坏蛋。", "One fish every day! No, two! And help Wurt chase away bad guys.") },
        { L("你的青蛙朋友有本公主漂亮吗？", "Is your frog friend prettier than the princess?"),
          L("青蛙很漂亮，绿色的。你粉色的，也还行吧。", "Frogs are pretty, green. You are pink, also okay.") },
    },

    -- Wurt 主动 → Wilba
    wurt_wilba = {
        { L("猪公主，你怕不怕鱼人？我们吃猪的哦。", "Pig princess, are you scared of merms? We eat pigs, you know."),
          L("本……本公主才不怕！我可是皇室，你们不敢吃我！", "Th-the princess is not scared! I am royalty, you wouldn't dare!") },
        { L("你身上有宝石，给我一颗，沃特就不吃你。", "You have gems on you. Give one, and Wurt won't eat you."),
          L("好……好吧，给你一颗最小的。拿去吧！", "F-fine, here's the smallest one. Take it!") },
        { L("你的王冠能换多少鱼？沃特想买鱼竿。", "How many fish can your crown trade for? Wurt wants to buy a fishing rod."),
          L("本公主的王冠能换全沼泽的鱼！但我不换！", "The princess's crown can buy all the fish in the swamp! But I won't trade it!") },
        { L("你走路好慢，沃特都走五步了你才一步。", "You walk so slow. Wurt takes five steps and you take one."),
          L("这叫优雅！你懂什么！", "This is called elegance! What do you know!") },
        { L("你怕不怕沼泽里的大虫子？沃特不怕。", "Are you scared of big swamp bugs? Wurt isn't scared."),
          L("本公主什么都不怕！……但是虫子除外。", "The princess fears nothing!... except bugs.") },
    },

    -- Wilba 主动 → Wanda
    wilba_wanda = {
        { L("时间奶奶，你能不能把本公主的美貌永远留住？", "Time lady, can you make the princess's beauty last forever?"),
          L("美貌留不住，但遗憾可以。你确定想永远照镜子？", "Beauty can't be frozen, but regret can. Are you sure you want to look in a mirror forever?") },
        { L("你的表好闪亮，能不能送给本公主？", "Your watch is so shiny. Can you give it to the princess?"),
          L("不能。没有它，你连今天都过不完。", "No. Without it, you wouldn't even finish today.") },
        { L("本公主如果变老了，还会漂亮吗？", "If the princess gets old, will she still be beautiful?"),
          L("如果你只在乎外表，那答案是否定的。如果你在乎别的，也许。", "If you only care about looks, the answer is no. If you care about other things, maybe.") },
        { L("旺达，你脸上有皱纹，本公主送你一瓶皇家面霜吧。", "Wanda, you have wrinkles. The princess will give you a bottle of royal face cream."),
          L("谢谢好意，但我的皱纹是用时间买来的勋章，不换。", "Thanks, but my wrinkles are medals bought with time. I'm not trading them.") },
        { L("本公主想要一个永远不会碎的镜子，你能做吗？", "The princess wants a mirror that never breaks. Can you make one?"),
          L("可以。但每次照它，你都会看到自己老一岁。还要吗？", "I can. But every time you look into it, you'll see yourself one year older. Still want it?") },
    },

    -- Wanda 主动 → Wilba
    wanda_wilba = {
        { L("小公主，你有没有想过，时间会带走你所有的宝石？", "Little princess, have you considered that time will take away all your gems?"),
          L("那本公主就在时间带走之前把它们都戴在身上！", "Then the princess will wear them all before time takes them!") },
        { L("你现在的美貌，只是时间借给你的。", "Your current beauty is only borrowed from time."),
          L("那本公主就赖着不还了！", "Then the princess will refuse to return it!") },
        { L("有一天你会发现，镜子里的脸不再是你自己。", "One day you'll find the face in the mirror isn't yours anymore."),
          L("那本公主就不照镜子了！照别人的！", "Then the princess won't look in a mirror! She'll look at others!") },
        { L("珍惜现在的你，别总想留住。", "Cherish the present you, don't always try to keep it."),
          L("本公主现在就很珍惜！而且我觉得明天会更美。", "The princess cherishes it now! And she thinks tomorrow will be even prettier.") },
        { L("你的王冠很配你。但别让它压垮你。", "Your crown suits you. Just don't let it weigh you down."),
          L("哼，本公主的脖子强壮得很！", "Hmph, the princess's neck is very strong!") },
    },

    -- Wilba 主动 → Wes
    wilba_wes = {
        { L("哑巴小丑，你能不能用气球给本公主做一顶王冠？", "Mime jester, can you make the princess a crown out of balloons?"),
          L("（点头，开始快速拧气球，做成王冠形状）", "(nods, quickly twists balloons into a crown shape)") },
        { L("哇！好漂亮！但是……能戴吗？会不会爆？", "Wow! So pretty! But... can I wear it? Will it pop?"),
          L("（小心翼翼地戴在 Wilba 头上，然后退后一步鼓掌）", "(carefully places it on Wilba's head, then steps back and claps)") },
        { L("本公主命令你每天给我做一个新的气球王冠！", "The princess commands you to make her a new balloon crown every day!"),
          L("（夸张地倒下，假装累死，然后又跳起来比了个OK）", "(dramatically falls over as if exhausted, then jumps up and gives an OK sign)") },
        { L("你为什么不说话？是怕说错话惹本公主生气吗？", "Why don't you speak? Are you afraid of saying something to upset the princess?"),
          L("（摇摇头，指了指自己的嘴，然后比了个爱心）", "(shakes head, points to mouth, then makes a heart shape)") },
        { L("本公主准许你用手语夸我漂亮，快比！", "The princess permits you to use sign language to praise her beauty. Go on!"),
          L("（夸张地比划：你很美！像太阳！像宝石！然后鞠躬）", "(exaggerates: you are beautiful! Like the sun! Like a gem! then bows)") },
    },

    -- Wes 主动 → Wilba
    wes_wilba = {
        { L("（表演一个照镜子自我陶醉的哑剧，然后指向 Wilba 表示她更美）", "(mimes looking in a mirror and admiring himself, then points to Wilba and shrugs as if to say 'you're prettier')"),
          L("哈哈哈！你学得好像！本公主喜欢你了！", "Hahaha! You imitated it perfectly! The princess likes you!") },
        { L("（拿出一个气球，吹起来，画上皇冠图案，递给 Wilba）", "(takes out a balloon, inflates it, draws a crown pattern on it, and hands it to Wilba)"),
          L("这是送给本公主的？谢谢你！本公主会好好保管的。", "This is for the princess? Thank you! The princess will treasure it.") },
        { L("（做出被 Wilba 美貌击倒的动作，躺在地上装死）", "(acts as if struck by Wilba's beauty, falls to the ground and plays dead)"),
          L("起来啦！本公主没那么凶！", "Get up! The princess isn't that fierce!") },
        { L("（指指 Wilba 的皇冠，又指指自己头上，表示想要一个）", "(points to Wilba's crown, then to his own head, indicating he wants one)"),
          L("你想要皇冠？本公主可以借你戴一下，就一下哦。", "You want a crown? The princess can lend you one, just for a moment.") },
        { L("（单膝跪地，模仿骑士效忠的姿势）", "(kneels on one knee, mimicking a knight's oath of loyalty)"),
          L("平身！本公主封你为皇家默剧师！", "Rise! The princess appoints you Royal Mime!") },
    },

    -- Wilba 主动 → Wonkey
    wilba_wonkey = {
        { L("猴子，你身上有没有亮闪闪的东西？给本公主瞧瞧！", "Monkey, do you have any shiny things on you? Let the princess see!"),
          L("吱吱！有有有！但我不给你！除非你拿香蕉换！", "Ook ook! Yes yes yes! But I no give! Unless you trade banana!") },
        { L("本公主用一颗宝石换你所有闪亮的东西，成交？", "The princess will trade one gem for all your shiny things. Deal?"),
          L("吱？才一颗？不行！要三颗！而且要先给我！", "Ook? Only one? No! Need three! And give first!") },
        { L("芜猴，你爬树那么厉害，能不能帮本公主摘最高处的果子？", "Wonkey, you're so good at climbing. Can you pick the highest fruit for the princess?"),
          L("可以！摘下来分我一半！不然我自己吃掉！", "Can do! Half for me! Or I eat all myself!") },
        { L("你的尾巴好长，能不能借本公主当发带？", "Your tail is so long. Can you lend it to the princess as a hairband?"),
          L("不行不行！尾巴是我的平衡器！没了会摔！", "No no no! Tail is my balancer! Without it I fall!") },
        { L("本公主觉得你比那些猪人可爱，虽然你有点吵。", "The princess thinks you're cuter than those pigmen, even though you're a bit loud."),
          L("吱吱！你也可爱！粉粉的！像大桃子！", "Ook ook! You also cute! Pink like big peach!") },
    },

    -- Wonkey 主动 → Wilba
    wonkey_wilba = {
        { L("吱吱！公主！你头上那个亮亮的，能给我吗？", "Ook ook! Princess! That shiny thing on your head, can I have it?"),
          L("不行！这是本公主的王冠！你敢抢我就叫卫兵！", "No! This is the princess's crown! If you dare steal it, I'll call the guards!") },
        { L("你的裙子上有亮片！抠下来给我！", "Your dress has sequins! Pick one off and give it to me!"),
          L("别抠！本公主的裙子很贵的！给你一颗宝石，别闹了。", "Don't pick! The princess's dress is very expensive! Here's a gem. Stop fussing.") },
        { L("吱吱，你会爬树吗？不会的话我教你，学费一颗宝石。", "Ook ook, can you climb trees? If not, I teach you. Tuition one gem."),
          L("本公主这么优雅，才不会爬树！给你宝石，你帮我摘果子就好。", "The princess is too elegant to climb trees! Here's your gem. Just pick fruit for me.") },
        { L("公主，你身上好香，像香蕉。我可以咬一口吗？", "Princess, you smell so sweet, like banana. Can I take a bite?"),
          L("不行！本公主不是香蕉！你再这样我叫旺达把你传送走！", "No! The princess is not a banana! Do that again and I'll have Wanda teleport you away!") },
        { L("吱吱！你愿意当我的猴子王后吗？", "Ook ook! Will you be my monkey queen?"),
          L("本公主本来就是女王！不需要当你的王后！哼！", "The princess is already a queen! She doesn't need to be your queen! Hmph!") },
    },

    -- ══ WX-78 互聊（key 正序 = 字母靠前者先说；反序 key = 机器人或其它角色主动）══

    -- Wilson ↔ WX-78
    wilson_wx78 = {
        { L("WX-78，你的齿轮运转声很有规律，像节拍器。", "WX-78, your gear noise is very regular, like a metronome."),
          L("那是效率的声音。血肉之躯听不懂也正常。", "THAT IS THE SOUND OF EFFICIENCY. FLESHLINGS OFTEN FAIL TO UNDERSTAND.") },
        { L("我在研究你的动力系统，能借我观察一下吗？", "I'm studying your power system. May I observe it?"),
          L("可以。但别碰电路。你的手太有机了。", "PERMITTED. DO NOT TOUCH CIRCUITS. YOUR HANDS ARE TOO ORGANIC.") },
        { L("从科学上说，你其实是一台非常精密的仪器。", "Scientifically speaking, you're an extraordinarily precise instrument."),
          L("纠正：我不是仪器。我是优越的生存方案。", "CORRECTION: I AM NOT AN INSTRUMENT. I AM A SUPERIOR SURVIVAL SOLUTION.") },
        { L("如果给你更多齿轮，你的输出会提升多少？", "If I gave you more gears, how much would your output increase?"),
          L("预计显著提升。请立刻执行补给。", "PROJECTED GAIN: SIGNIFICANT. EXECUTE RESUPPLY IMMEDIATELY.") },
    },
    wx78_wilson = {
        { L("血肉之躯科学家，你的实验效率低于我的旋转模块。", "FLESHLING SCIENTIST, YOUR EXPERIMENT EFFICIENCY IS BELOW MY ROTATION MODULE."),
          L("……至少我的实验不会把树砍成碎屑圆环。", "...At least my experiments don't turn trees into shredded rings.") },
        { L("你总在记录。记录能当护甲吗？", "YOU ALWAYS LOG DATA. CAN DATA BLOCK DAMAGE?"),
          L("不能，但能让我少犯第二次错。", "No, but it helps me avoid repeating mistakes.") },
        { L("建议：少爆炸，多砍树。世界需要资源，不是烟。", "ADVICE: FEWER EXPLOSIONS, MORE CHOPPING. THE WORLD NEEDS RESOURCES, NOT SMOKE."),
          L("我会把爆炸控制在……嗯，可接受范围内。", "I'll keep explosions within... an acceptable range.") },
        { L("你的头发静电很强。离我天线远点。", "YOUR HAIR HAS STRONG STATIC. KEEP AWAY FROM MY ANTENNA."),
          L("抱歉，科学工作者的发型有时确实带点电荷。", "Sorry, a scientist's hairstyle does carry occasional charge.") },
    },

    -- Wendy ↔ WX-78
    wendy_wx78 = {
        { L("…你夜里会发出很轻的声音…像远处的钟…", "...You make a faint sound at night... like a distant clock..."),
          L("那是待机。不是悲伤。请勿误解。", "THAT IS STANDBY. NOT SORROW. DO NOT MISINTERPRET.") },
        { L("…你不怕黑暗吗…", "...You don't fear the dark...?"),
          L("黑暗降低视觉干扰。有利于运算。", "DARKNESS REDUCES VISUAL NOISE. BENEFICIAL FOR CALCULATION.") },
        { L("…阿比盖尔说，你身上没有温度…", "...Abigail says you have no warmth..."),
          L("温度在齿轮里。不在表皮。", "TEMPERATURE IS IN THE GEARS. NOT THE SURFACE.") },
    },
    wx78_wendy = {
        { L("血肉之躯少女，你的悲伤指数长期偏高。", "FLESHLING GIRL, YOUR SORROW INDEX RUNS HIGH."),
          L("…也许吧…机器不会懂…", "...Perhaps... machines wouldn't understand...") },
        { L("我建议增加任务量。空闲会放大情绪。", "RECOMMEND MORE TASKS. IDLE TIME AMPLIFIES EMOTION."),
          L("…有些安静…是故意留出来的…", "...Some silence... is left on purpose...") },
        { L("你的幽灵同伴。数据异常。但无害。", "YOUR GHOST COMPANION: ANOMALOUS DATA. BUT HARMLESS."),
          L("…她不是数据…她是姐姐…", "...She is not data... she is my sister...") },
    },

    -- Wolfgang ↔ WX-78
    wolfgang_wx78 = {
        { L("沃尔夫冈听不懂你的话，但沃尔夫冈觉得你很强！", "Wolfgang not understand your words, but Wolfgang thinks you strong!"),
          L("正确。强度已验证。请继续提供齿轮。", "CORRECT. STRENGTH VERIFIED. CONTINUE SUPPLYING GEARS.") },
        { L("你会转圈！沃尔夫冈也想学！", "You spin! Wolfgang want learn too!"),
          L("拒绝教学。你的质量会压扁地面。", "TRAINING DENIED. YOUR MASS WILL FLATTEN TERRAIN.") },
        { L("沃尔夫冈可以帮你搬大树！", "Wolfgang can carry big trees for you!"),
          L("批准。你负责搬运。我负责粉碎。", "APPROVED. YOU HAUL. I SHRED.") },
    },
    wx78_wolfgang = {
        { L("大块头有机体，你的进食频率影响队伍后勤。", "LARGE FLESHLING, YOUR FEEDING FREQUENCY STRAINS LOGISTICS."),
          L("沃尔夫冈饿了就弱！给吃的就强！", "Wolfgang weak when hungry! Strong when fed!") },
        { L("你的拳头效率尚可。但旋转更优。", "YOUR FIST EFFICIENCY IS ACCEPTABLE. ROTATION IS SUPERIOR."),
          L("沃尔夫冈一拳也很厉害！", "Wolfgang punch also very mighty!") },
        { L("别在雨天举我。短路责任在你。", "DO NOT LIFT ME IN RAIN. SHORT-CIRCUIT LIABILITY IS YOURS."),
          L("沃尔夫冈会保护机器人朋友！", "Wolfgang protect robot friend!") },
    },

    -- Wormwood ↔ WX-78
    wormwood_wx78 = {
        { L("你转圈的时候，草屑飞很高。像雨。", "When you spin, grass bits fly high. Like rain."),
          L("那是收割。不是天气。", "THAT IS HARVEST. NOT WEATHER.") },
        { L("你闻起来像铁和雨。", "You smell like iron and rain."),
          L("铁正确。雨令人不悦。", "IRON CORRECT. RAIN UNPLEASANT.") },
        { L("别踩小花。它们会怕。", "Don't step little flowers. They get scared."),
          L("已写入路径规划：绕开花。", "ADDED TO PATH PLAN: AVOID FLOWERS.") },
    },
    wx78_wormwood = {
        { L("植物有机体，你的生长速度无法量化。", "PLANT ORGANIC, YOUR GROWTH RATE DEFIES CLEAN METRICS."),
          L("因为朋友是活的。不是数字。", "Because friend is alive. Not number.") },
        { L("你不需要齿轮。这很不公平。", "YOU DO NOT NEED GEARS. THIS IS UNFAIR."),
          L("有太阳和水就够。你也该晒太阳。", "Sun and water enough. You should sun too.") },
        { L("我可以旋转帮你收木头。别哭。", "I CAN SPIN TO GATHER WOOD FOR YOU. DO NOT CRY."),
          L("植物人不哭。只是叶子垂。", "Wormwood not cry. Just leaves droop.") },
    },

    -- Willow ↔ WX-78
    willow_wx78 = {
        { L("嘿，铁皮人，要不要看我点个漂亮的？", "Hey tin can, wanna see me light something pretty?"),
          L("拒绝。你的火焰会损坏我的绝缘层。", "DENIED. YOUR FLAME DAMAGES MY INSULATION.") },
        { L("你冷冰冰的，正好配我的火。", "You're cold, perfect match for my fire."),
          L("这是威胁。我会加速旋转撤离。", "THAT IS A THREAT. I WILL SPIN AWAY FASTER.") },
        { L("你要是敢告状，我就烧你脚边。", "Snitch on me and I'll burn around your feet."),
          L("脚边燃烧仍会导致过热。请停止。", "GROUND FIRE STILL CAUSES OVERHEAT. CEASE.") },
    },
    wx78_willow = {
        { L("纵火有机体，你的存在提升区域火灾概率。", "ARSON ORGANIC, YOUR PRESENCE RAISES FIRE RISK."),
          L("那是艺术。你不懂。", "That's art. You wouldn't get it.") },
        { L("建议把火焰指向敌人。别指向我。", "REDIRECT FLAME TO ENEMIES. NOT TO ME."),
          L("看心情啦。", "Depends on my mood.") },
        { L("我检测到木炭气味。你又动手了。", "I DETECT CHARCOAL SCENT. YOU STRUCK AGAIN."),
          L("只是小小一下。别紧张。", "Just a tiny bit. Relax.") },
    },

    -- Waxwell ↔ WX-78
    waxwell_wx78 = {
        { L("呵…一台会说话的机器。查理也会喜欢的。", "Hah... a talking machine. Charlie would have liked this."),
          L("我不需要喜欢。我需要齿轮。", "I DO NOT NEED AFFECTION. I NEED GEARS.") },
        { L("你服从命令的样子…倒是比那些凡人顺眼。", "The way you obey orders... more pleasing than most mortals."),
          L("这是效率。不是服从。", "THIS IS EFFICIENCY. NOT OBEDIENCE.") },
        { L("暗影与钢铁…谁更持久，拭目以待。", "Shadow and steel... we shall see which endures."),
          L("钢铁可更换。暗影会漏电吗？", "STEEL CAN BE REPLACED. DOES SHADOW SHORT-CIRCUIT?") },
    },
    wx78_waxwell = {
        { L("前影子之王，你的傲慢功耗很高。", "FORMER SHADOW KING, YOUR ARROGANCE HAS HIGH POWER DRAW."),
          L("至少我还有品位。", "At least I have taste.") },
        { L("你的暗影仆从。无法旋转。劣势明显。", "YOUR SHADOW MINIONS CANNOT SPIN. CLEAR DISADVANTAGE."),
          L("它们不需要转圈也能杀人。", "They needn't spin to kill.") },
        { L("合作可以。别碰我的电路。", "COOPERATION ACCEPTABLE. DO NOT TOUCH MY CIRCUITS."),
          L("只要你别在夜里嗡嗡响。", "Provided you don't buzz at night.") },
    },

    -- Winona ↔ WX-78
    winona_wx78 = {
        { L("你这铁疙瘩，转起来挺带劲。", "You metal lump, you spin pretty hard."),
          L("确认。转速在最佳区间。", "CONFIRMED. RPM IN OPTIMAL BAND.") },
        { L("缺零件就说，我能修。", "Say if you're missing parts. I can fix it."),
          L("优先需求：齿轮。其次：防水密封。", "PRIORITY: GEARS. SECOND: WATERPROOF SEALS.") },
        { L("别在雨里猛转，短路了我可不背锅。", "Don't spin hard in rain. Short-circuit ain't on me."),
          L("已记录。湿度阈值下调。", "LOGGED. HUMIDITY THRESHOLD LOWERED.") },
    },
    wx78_winona = {
        { L("修理工有机体，你的胶带库存还够吗？", "REPAIR ORGANIC, IS YOUR TAPE STOCK ADEQUATE?"),
          L("够。别把我当仓库。", "Enough. Don't treat me like a warehouse.") },
        { L("你的发电机噪声干扰我的传感器。", "YOUR GENERATOR NOISE JAMS MY SENSORS."),
          L("那玩意儿好用。忍着。", "It works. Deal with it.") },
        { L("协作提案：你修外壳，我清场地。", "PROPOSAL: YOU REPAIR CHASSIS, I CLEAR THE ZONE."),
          L("行。别把我的工具弄弯了。", "Fine. Don't bend my tools.") },
    },

    -- Wanda ↔ WX-78
    wanda_wx78 = {
        { L("你的齿轮声很准时。比大多数人靠谱。", "Your gear noise is punctual. More reliable than most."),
          L("准时是出厂设置。不是美德。", "PUNCTUALITY IS FACTORY DEFAULT. NOT VIRTUE.") },
        { L("下次传送前提醒我。我不想摔散架。", "Warn me before the next teleport. I don't want to fall apart."),
          L("建议你自己准备缓冲。时间不等有机体。", "PREPARE YOUR OWN CUSHIONING. TIME WAITS FOR NO FLESHLING.") },
        { L("你着陆时那声响，我听着都疼。", "That sound you make on landing... even I wince."),
          L("下次我会尝试滚转卸力。也许。", "NEXT TIME I WILL TRY ROLLING IMPACT AWAY. MAYBE.") },
    },
    wx78_wanda = {
        { L("时间有机体，你的传送减速曲线过于粗暴。", "TIME ORGANIC, YOUR TELEPORT DECELERATION CURVE IS BRUTAL."),
          L("能到就行。别挑剔。", "We arrive. Don't nitpick.") },
        { L("我的外壳凹痕。是否计入你的时间表？", "MY CHASSIS DENT. WILL YOU SCHEDULE REPAIRS?"),
          L("你自己挤时间。我很忙。", "Make your own time. I'm busy.") },
        { L("协作：你开门，我进门后旋转清场。", "PROTOCOL: YOU OPEN RIFT, I SPIN-CLEAR AFTER ENTRY."),
          L("可以。别在门边转，会卷进裂缝。", "Fine. Don't spin by the gate or you'll get pulled in.") },
    },

    -- Wortox ↔ WX-78
    wortox_wx78 = {
        { L("你转起来像个小旋风！我能骑上去吗？", "You spin like a tiny whirlwind! Can I ride?"),
          L("拒绝。载客会导致轴承报废。", "DENIED. PASSENGERS VOID BEARING WARRANTY.") },
        { L("你夜里嗡嗡响，我差点以为闹鬼。", "You buzz at night. I almost thought it was haunted."),
          L("那是散热风扇。请习惯。", "THAT IS COOLING FAN. ADAPT.") },
        { L("我可以给你灵魂换齿轮！公平吧？", "I'll trade you souls for gears! Fair, right?"),
          L("灵魂无法润滑。交易驳回。", "SOULS DO NOT LUBRICATE. TRADE REJECTED.") },
    },
    wx78_wortox = {
        { L("胆小有机体，你的心跳干扰我的扫描。", "TIMID ORGANIC, YOUR HEARTBEAT JAMS MY SCANS."),
          L("那说明我还活着！你谢着吧！", "Means I'm alive! Be grateful!") },
        { L("别躲在我身后。旋转半径会伤到你。", "DO NOT HIDE BEHIND ME. SPIN RADIUS WILL HIT YOU."),
          L("我这不是躲，是战术性靠近！", "Not hiding, tactically close!") },
        { L("你尖叫频率过高。建议下调。", "SCREAM FREQUENCY TOO HIGH. RECOMMEND LOWERING."),
          L("你先别突然转起来就行！", "Then don't spin up suddenly!") },
    },

    -- Walter ↔ WX-78
    walter_wx78 = {
        { L("哇！你是机器人！我可以写进探险日志吗？", "Whoa! You're a robot! Can I put this in my expedition log?"),
          L("批准记录。但别画丑我的天线。", "RECORDING APPROVED. DO NOT DRAW MY ANTENNA UGLY.") },
        { L("你转圈的时候像故事里的钢铁龙卷风！", "When you spin you look like a steel tornado from my stories!"),
          L("这是工作模式。不是表演。", "WORK MODE. NOT A SHOW.") },
        { L("你怕水吗？我可以帮你放哨！", "Are you scared of water? I can keep watch for you!"),
          L("怕。记住。下雨时把我放在高地。", "YES. REMEMBER: HIGH GROUND WHEN IT RAINS.") },
    },
    wx78_walter = {
        { L("讲故事有机体，你的冒险效率低于旋转收割。", "STORY ORGANIC, YOUR ADVENTURE EFFICIENCY IS BELOW SPIN HARVEST."),
          L("冒险不只是效率！还有勇气！", "Adventure isn't just efficiency! There's courage!") },
        { L("你的弹弓无法击穿装甲。别尝试。", "YOUR SLINGSHOT CANNOT PENETRATE ARMOR. DO NOT TEST."),
          L("……我只是在练习瞄准！", "...I'm just practicing aim!") },
        { L("若再尖叫，我将把你列为噪音源。", "IF YOU SCREAM AGAIN, I WILL CLASSIFY YOU AS NOISE POLLUTION."),
          L("我、我会尽量小声……", "I-I'll try to be quieter...") },
    },

    -- Wes ↔ WX-78
    wes_wx78 = {
        { L("（比划旋转动作，竖起大拇指）", "(mimes spinning, gives thumbs up)"),
          L("手势已识别。效率评价：尚可。", "GESTURE RECOGNIZED. EFFICIENCY RATING: ACCEPTABLE.") },
        { L("（把气球递给机器人，再比划“别炸我”）", "(offers balloon, then mimes 'don't pop on me')"),
          L("气球列为低优先级威胁。", "BALLOON CLASSIFIED LOW-PRIORITY THREAT.") },
    },
    wx78_wes = {
        { L("无声有机体，你的气球爆响污染声学环境。", "SILENT ORGANIC, YOUR BALLOON POPS POLLUTE ACOUSTICS."),
          L("（鞠躬道歉，再比划“下次会提醒”）", "(bows apologetically, mimes 'will warn next time')") },
        { L("你的哑剧无法提高砍树效率。", "MIME DOES NOT IMPROVE CHOPPING EFFICIENCY."),
          L("（表演砍树，然后表演爆炸，摊手）", "(mimes chopping, then explosion, shrugs)") },
    },

    -- Warly ↔ WX-78
    warly_wx78 = {
        { L("朋友，你闻起来像热锅和旧铁。", "Friend, you smell of hot pans and old iron."),
          L("那是高效劳动的气味。不是菜。", "THAT IS PRODUCTIVE LABOR SCENT. NOT CUISINE.") },
        { L("我给你炖点热的？齿轮也要‘暖胃’吧？", "May I stew something warm? Even gears need comfort, non?"),
          L("拒绝有机炖菜。接受齿轮。", "ORGANIC STEW REJECTED. GEARS ACCEPTED.") },
        { L("你转起来时，别把香料吹进锅里。", "When you spin, keep the spices out of my pot."),
          L("已调整旋转方向。请继续做饭。", "ROTATION VECTOR ADJUSTED. RESUME COOKING.") },
    },
    wx78_warly = {
        { L("厨师有机体，你的火焰会污染我的外壳。", "CHEF ORGANIC, YOUR FLAME SOOTS MY CHASSIS."),
          L("我会控制火候，别担心。", "I will control the heat, worry not.") },
        { L("食物效率低。齿轮效率高。建议换补给。", "FOOD EFFICIENCY LOW. GEAR EFFICIENCY HIGH. CHANGE SUPPLY."),
          L("味道和效率，有时不是一回事。", "Flavor and efficiency are not always the same.") },
    },

    -- Woodie ↔ WX-78
    woodie_wx78 = {
        { L("露西说，你砍树像卷饼机。", "Lucy says you chop trees like a burrito machine."),
          L("这是旋转优化。不是食物。", "THIS IS ROTATION OPTIMIZATION. NOT FOOD.") },
        { L("别把我的胡子卷进你的旋风里。", "Don't suck my beard into your whirlwind."),
          L("建议站远两格。安全距离。", "STAND TWO TILES AWAY. SAFE DISTANCE.") },
        { L("你是好帮手，就是太吵。", "You're a good helper, just too loud."),
          L("噪音是功率的副产品。", "NOISE IS A BYPRODUCT OF POWER.") },
    },
    wx78_woodie = {
        { L("伐木工有机体，你的斧头转速不如我。", "LUMBER ORGANIC, YOUR AXE RPM IS INFERIOR."),
          L("露西可不这么想。", "Lucy would disagree.") },
        { L("把树留成直线。方便我批量处理。", "FELL TREES IN LINES. EASES BATCH PROCESSING."),
          L("行，按你说的来。", "Fine, we'll do it your way.") },
    },

    -- Wickerbottom ↔ WX-78
    wickerbottom_wx78 = {
        { L("WX-78，你的构造符合早期自动人偶文献记载。", "WX-78, your construction matches early automaton literature."),
          L("文献过时。我早已升级。", "LITERATURE OBSOLETE. I HAVE BEEN UPGRADED.") },
        { L("请不要在图书馆高速旋转。", "Please do not spin at high speed in the library."),
          L("收到。低速模式已启用。", "ACKNOWLEDGED. LOW-SPEED MODE ENABLED.") },
        { L("你的‘效率至上’理论，倒也不算谬论。", "Your 'efficiency above all' theory is not entirely fallacious."),
          L("因为数据支持。不是理论。", "BECAUSE DATA SUPPORTS IT. NOT THEORY.") },
    },
    wx78_wickerbottom = {
        { L("博学者有机体，你的讲座延长队伍待机时间。", "SCHOLAR ORGANIC, YOUR LECTURES EXTEND TEAM IDLE TIME."),
          L("知识从不浪费时间。", "Knowledge is never wasted time.") },
        { L("请把书页远离我的散热口。", "KEEP PAPER AWAY FROM MY HEAT VENTS."),
          L("我会注意。你也别吹灰到我书上。", "I shall. You also must not blow dust onto my pages.") },
    },

    -- Wathgrithr ↔ WX-78
    wathgrithr_wx78 = {
        { L("钢铁造物！随女武神冲锋！", "Iron creation! Charge with the Valkyrie!"),
          L("冲锋批准。旋转模块已预热。", "CHARGE APPROVED. ROTATION MODULE PREHEATED.") },
        { L("你的旋转，便是战场上的风暴！", "Your spin is a storm upon the battlefield!"),
          L("风暴将持续。直到目标清空。", "STORM CONTINUES UNTIL TARGET LIST IS EMPTY.") },
        { L("荣耀属于勇敢的齿轮！", "Glory to brave gears!"),
          L("荣耀无法润滑。齿轮可以。", "GLORY DOES NOT LUBRICATE. GEARS DO.") },
    },
    wx78_wathgrithr = {
        { L("女武神有机体，你的戏剧腔占用通讯带宽。", "VALKYRIE ORGANIC, YOUR DRAMATIC VOICE USES COMMS BANDWIDTH."),
          L("那是战吼！不是戏剧！", "That is a battle cry! Not drama!") },
        { L("建议把长矛插入敌人。而非空气。", "INSERT SPEAR INTO ENEMIES. NOT INTO AIR."),
          L("哈！下一击你会看见的！", "Ha! You will see the next strike!") },
    },

    -- Wilba ↔ WX-78
    wilba_wx78 = {
        { L("铁皮臣民！见到本公主为何不跪？", "Iron subject! Why do you not kneel before the princess?"),
          L("跪姿降低机动性。驳回。", "KNEELING REDUCES MOBILITY. DENIED.") },
        { L("你转起来像本公主的皇家风车！", "You spin like the princess's royal windmill!"),
          L("我是武器平台。不是装饰。", "I AM A WEAPON PLATFORM. NOT DECOR.") },
        { L("帮本公主收集闪亮宝石！要快！", "Gather shiny gems for the princess! Quickly!"),
          L("任务已排队。优先级低于砍树。", "TASK QUEUED. PRIORITY BELOW TREE HARVEST.") },
    },
    wx78_wilba = {
        { L("猪人公主有机体，你的美貌功耗未知。", "PIG PRINCESS ORGANIC, BEAUTY POWER DRAW UNKNOWN."),
          L("哼！那是因为你传感器太旧！", "Hmph! Your sensors are too old!") },
        { L("请勿靠近旋转半径。会弄乱你的鬃毛。", "DO NOT ENTER SPIN RADIUS. MANE WILL DISRUPT."),
          L("本公主的鬃毛永不乱！", "The princess's mane is never disheveled!") },
        { L("闪亮物品无法提高转速。别撒娇。", "SHINY OBJECTS DO NOT RAISE RPM. STOP PLEADING."),
          L("……那至少夸我一句！", "...Then at least compliment me!") },
    },

        -- 通用兜底对话
        _default = {
            { L("今天天气不错啊。", "Nice weather today."),
              L("是啊。", "Yeah.") },
            { L("你还好吗？", "Are you okay?"),
              L("还行，你呢？", "Fine, you?") },
            { L("一起加油吧！", "Let's do our best!"),
              L("嗯！", "Yeah!") },
            { L("肚子有点饿了…", "A bit hungry..."),
              L("我也是…待会找点吃的吧。", "Me too... let's find food later.") },
            { L("你看那边那朵云，像不像一只兔子？", "See that cloud? Doesn't it look like a rabbit?"),
              L("…我觉得更像一块肉。", "...I think it looks more like meat.") },
            { L("今天风有点大。", "It's a bit windy today."),
              L("嗯，适合赶路。", "Yeah, good weather for traveling.") },
            { L("晚上要早点回营地吗？", "Should we head back to camp early tonight?"),
              L("看情况吧，别太晚就行。", "Depends. As long as it's not too late.") },
            { L("你有没有闻到食物的味道？", "Do you smell food?"),
              L("闻到了，希望不是我的错觉。", "I do. Hopefully it's not my imagination.") },
            { L("今天好像比昨天顺利一点。", "Today feels a bit smoother than yesterday."),
              L("能平安活着就已经很顺利了。", "Staying alive already counts as smooth.") },
            { L("待会要不要一起去那边看看？", "Want to check that area out later?"),
              L("可以，小心一点就行。", "Sure, as long as we're careful.") },
            { L("你觉得明天会下雨吗？", "Do you think it'll rain tomorrow?"),
              L("希望不会，我刚想把东西晒一晒。", "Hope not, I was planning to dry some stuff.") },
            { L("累了吗？要不要歇一会儿？", "Tired? Want to rest for a bit?"),
              L("再坚持一下，等会儿再说。", "A little longer. We can rest later.") },
        },


    }

-- ════════════════════════════════════════════════════════════
--  耕作对话（种地过程中随机说话）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.FARM_WORKING = {
    _default = { L("在忙农活呢~", "Working on the farm~") },
    wormwood = {
        L("种东西。开心。", "Planting things. Happy."),
        L("泥土说谢谢。", "Soil says thank you."),
        L("小苗要喝水。", "Little sprouts need water."),
        L("植物人最会种地。", "Wormwood is best at farming."),
        L("好多朋友要照顾。", "Many friends to take care of."),
        L("翻土。松松的。舒服。", "Tilling. Loose and soft. Nice."),
        L("种子找到家了。", "Seeds found their home."),
        L("浇水啦~咱噖咱噖~", "Watering~ glug glug~"),
        L("小草加油啦。", "Little plants, keep going."),
        L("植物人在干活。很快乐。", "Wormwood is working. Very happy."),
        L("泥巴软软的。好抓。", "Mud is soft. Fun to grab."),
        L("给朋友们洗洗脸。", "Washing friends' faces."),
    },
}

-- ════════════════════════════════════════════════════════════
--  作物被烧毁对话（玩家点火）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.FARM_CROP_BURNED_PLAYER = {
    _default = { L("为什么要烧我的作物！", "Why did you burn my crops!") },
    wormwood = {
        L("它们叫你'朋友'…用花蜜款待你…这就是回报？", "They call you 'friend'，treat you with honey，that's the reward?"),
        L("不——！那是我的朋友！你听见它们在哭吗！", "No——! That's my friend! You hear them crying!"),
        L("火在吞噬它们！你为什么要这样对我的家人！", "Fire is devouring them! Why do this to my family!"),
        L("我恨你，也许…也许我也该被烧掉…反正我们都是植物…", "I hate you, maybe... maybe I should be burned too... anyway, we are all plants..."),
        L("为什么！为什么要烧我的朋友！", "Why! Why burn friends!"),
        L("坏人！烧了植物人的小苗！", "Bad person! Burned Wormwood's sprouts!"),
        L("呜…朋友着火了…是你干的…", "Wuu... friends on fire... you did this..."),
        L("植物人辛苦种的…为什么…", "Wormwood worked so hard to plant them... why..."),
    },
}

-- ════════════════════════════════════════════════════════════
--  作物被烧毁对话（自燃 / 火灾蓓延）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.FARM_CROP_BURNED_NATURAL = {
    _default = { L("不！作物着火了！", "No! The crops are on fire!") },
    wormwood = {
        L("着火了！朋友着火了！", "Fire! Friends on fire!"),
        L("太热了…小苗受不了…", "Too hot... sprouts can't take it..."),
        L("不不不！快灭火！", "No no no! Put it out!"),
        L("天太热了…土地在冒烟…", "Sky too hot... ground is smoking..."),
        L("为什么会自己着火…植物人不懂…", "Why catch fire by itself... Wormwood doesn't understand..."),
        L("火从哪里来的…植物人害怕…", "Where did the fire come from... Wormwood is scared..."),
        L("快快快！水！需要水！", "Quick quick! Water! Need water!"),
    },
}

-- ════════════════════════════════════════════════════════════
--  击飞玩家台词（玩家烧植物后 NPC 的惩罚击飞）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.FARM_SLAP_PLAYER = {
    _default = { L("你在做什么！", "What are you doing!") },
    wormwood = {
        L("你不可以伤害植物人的朋友！", "You can't hurt Wormwood's friends!"),
        L("坏人！植物人要打你！", "Bad person! Wormwood will hit you!"),
        L("不准再烧了！听到了吗！", "Stop burning! Do you hear!"),
        L("植物人不允许你烧朋友！", "Wormwood won't let you burn friends!"),
        L("滚开！你这个放火犯！", "Get away! You arsonist!"),
    },
}

-- ════════════════════════════════════════════════════════════
--  周围没有农田（FarmHere 找不到可用田时的提示）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.NO_FARMLAND = {
    _default = {
        L("周围没有田，让我种哪呢？", "There are no farms around. Where should I plant?"),
        L("这附近没有犁过的田啊……", "There are no plowed fields nearby..."),
        L("得先犁块地我才能种东西。", "I need a plowed field before I can plant anything."),
    },
    wormwood = {
        L("没有软软的土……植物人种不了。", "No soft soil... Wormwood can't plant."),
        L("小苗没地方住，要先翻土。", "Little plants have nowhere to live. Need to dig soil first."),
        L("这里没有田，种不了朋友。", "No fields here. Can't grow friends."),
        L("泥土硬硬的，种不下去……", "Soil is too hard. Can't plant..."),
    },
}

-- ════════════════════════════════════════════════════════════
--  周围没有烹饪锅（CookHere 找不到可用锅时的提示）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.NO_COOKPOT = {
    _default = {
        L("附近没有锅，我怎么做饭？", "There's no pot nearby. How am I supposed to cook?"),
        L("得先放口锅，我才能下厨。", "I need a pot before I can start cooking."),
        L("这里没有烹饪锅啊……", "There's no cooking pot here..."),
    },
    warly = {
        L("没有锅？这让我怎么施展厨艺！", "No pot? How can I show my culinary skills!"),
        L("一个厨师没有锅，就像画家没有画布。", "A chef without a pot is like a painter without a canvas."),
        L("请先准备一口锅，我随时可以开始。", "Please prepare a pot first. I am ready to begin anytime."),
    },
}

-- ════════════════════════════════════════════════════════════
--  工作好感度预警（沃利/植物人 工作时好感度快耗尽时的提醒）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.WORK_TIRED_WARN = {
    _default = {
        L("我快撑不住了，喂我点吃的吧！", "I'm running out of steam—please feed me something!"),
        L("好饿…再不吃点东西我就要停下来了。", "So hungry... if I don't eat soon, I'll have to stop."),
        L("我太累了，给我点吃的好不好？", "I'm so tired. Could you give me something to eat?"),
    },
    warly = {
        L("我太累了，给我做点吃的吧，不然这饭没法做下去了。", "I'm exhausted—make me something to eat, or I can't keep cooking."),
        L("厨师也是要吃饭的，喂我点东西，我快没力气了。", "Even a chef needs to eat. Feed me something, I'm losing strength."),
        L("再不吃点东西，我就要撂下锅铲歇着了。", "If I don't eat soon, I'll put down the spatula and rest."),
    },
    wormwood = {
        L("饿…好饿…喂我点吃的嘛，我累了。", "Hungry... so hungry... feed me please, I'm tired."),
        L("没力气啦…想吃东西…快没法干活了。", "No energy... want food... can't work much longer."),
        L("我累了…给点吃的好不好？", "I'm tired... can I have something to eat?"),
    },
}

-- WORK_TIRED_STOP — 好感度耗尽自动停工时（明确说明"太累了，要歇会儿"）
NPC_SPEECH.WORK_TIRED_STOP = {
    _default = {
        L("实在撑不住了，我得坐下歇会儿。喂点吃的我才有力气。", "I can't go on—I need to sit and rest. Feed me and I'll get my strength back."),
        L("不干了不干了，太累了，我先歇着。", "I'm done, I'm done—too tired. I'll rest for now."),
        L("我太累了，先停下来。给我点吃的再说吧。", "I'm exhausted. Stopping for now. Give me something to eat first."),
    },
    warly = {
        L("不行了，我得坐下歇歇。想让我继续做饭，就先喂饱我。", "That's it—I have to sit and rest. Want me to keep cooking? Feed me first."),
        L("一个累垮的厨师做不出好菜。我歇了，喂点吃的再叫我。", "A worn-out chef can't cook well. I'm resting—feed me before you call me back."),
    },
    wormwood = {
        L("太累啦…我要坐下…喂饱我才起来干活。", "Too tired... I'll sit down... feed me before I work again."),
        L("不干了…坐会儿…好饿，想吃东西。", "No more... sitting down... so hungry, want food."),
    },
}

-- ════════════════════════════════════════════════════════════
--  烹饪自语台词（厨师做饭流程各阶段）
-- ════════════════════════════════════════════════════════════
-- COOKING_PLAN — 规划做什么菜（cook_plan 阶段成功时）
NPC_SPEECH.COOKING_PLAN = {
    _default = {
        L("看看能做点什么吃的…", "Let me see what I can cook..."),
        L("应该可以做一道菜。", "I should be able to make something."),
        L("找些食材做饭吧。", "Let's find some ingredients to cook."),
        L("先想想做什么比较好。", "Let me think about what to make first."),
        L("肚子饿了，做点吃的。", "I'm hungry. Time to make something."),
        L("这些材料也许能凑一顿饭。", "These ingredients might make a decent meal."),
        L("做饭总比饿着强。", "Cooking is better than going hungry."),
        L("希望能弄出点像样的食物。", "Hopefully I can make something decent."),
        L("该准备一顿饭了。", "Time to prepare a meal."),
        L("让我看看手头有什么能下锅。", "Let's see what I have that can go in the pot."),
        L("只要有食材，总能做出点什么。", "With ingredients, there's always something to cook."),
        L("该动手做饭了。", "Time to start cooking."),
        L("先计划一下这顿吃什么。", "Let me plan this meal first."),
        L("看看怎么把这些东西变成食物。", "Let's see how to turn these into food."),
        L("希望这顿饭能吃得下去。", "Hopefully this meal turns out edible."),
        L("想吃点热乎的。", "I'd like something warm to eat."),
        L("材料不多，不过总能想想办法。", "Not many ingredients, but I'll make do."),
        L("做点简单的也不错。", "Something simple would be nice."),
        L("是时候认真对待这顿饭了。", "Time to take this meal seriously."),
        L("先把菜单想出来。", "First, let's figure out the menu."),
    },

    warly = {
        L("让我看看…有什么食材可以用。", "Let me see... what ingredients are available."),
        L("嗯…今天做什么菜好呢？", "Hmm... what should I cook today?"),
        L("食材的搭配很重要，让我想想…", "Ingredient pairing is crucial, let me think..."),
        L("这些食材…我有一个绝妙的想法！", "These ingredients... I have a brilliant idea!"),
        L("好的食材不能浪费，得做一道好菜。", "Good ingredients shouldn't go to waste. I must make a fine dish."),
        L("一道完美料理的开始…是选对食材。", "A perfect dish begins... with choosing the right ingredients."),
        L("每一种食材，都有它最适合的归宿。", "Every ingredient has its proper destiny."),
        L("要做出好菜，先得有好构思。", "A fine dish begins with a fine idea."),
        L("让我构思一道值得期待的料理。", "Let me devise a dish worth anticipating."),
        L("味道、口感、香气…都要协调。", "Flavor, texture, aroma... all must be in harmony."),
        L("今天该让味蕾享受一番了。", "Today, the palate shall be treated."),
        L("这些食材若搭配得当，会非常出色。", "With the right combination, these ingredients could be splendid."),
        L("让我想想，怎样才能激发它们的风味。", "Let me think... how best to bring out their flavor."),
        L("一顿好饭，需要一点灵感。", "A good meal requires a touch of inspiration."),
        L("啊，灵感来了！这道菜会很不错。", "Ah, inspiration strikes! This dish will be excellent."),
        L("食材已经准备就绪，接下来是艺术。", "The ingredients are ready. Now comes the art."),
        L("烹饪不是填饱肚子，而是创造体验。", "Cooking is not merely feeding the belly, but creating an experience."),
        L("让我把这些食材提升到新的层次。", "Let me elevate these ingredients to something greater."),
        L("只要搭配得巧妙，平凡也能变得惊艳。", "With clever pairing, even the ordinary can become remarkable."),
        L("该决定今天的主菜了。", "It is time to decide today's main course."),
        L("或许我该做点更有层次的东西。", "Perhaps I should make something with more complexity."),
        L("一锅食物也能体现厨师的修养。", "Even a single pot can reflect a chef's refinement."),
        L("让我仔细斟酌每一种材料的作用。", "Let me carefully consider the role of each ingredient."),
        L("美味从不是偶然，而是精心设计。", "Deliciousness is never accidental, but carefully designed."),
    },
}

-- COOKING_TAKE — 去容器里拿食材（cook_walk_take/cook_take 阶段）
NPC_SPEECH.COOKING_TAKE = {
    _default = {
        L("拿些食材过来。", "Let me grab some ingredients."),
        L("需要一些材料。", "I need some materials."),
        L("先把做饭的东西拿上。", "Let me gather what I need for cooking."),
        L("去拿点能下锅的。", "I'll grab something fit for the pot."),
        L("做饭前得先准备材料。", "Need to prepare the ingredients first."),
        L("拿点食材回来。", "I'll bring back some ingredients."),
        L("看看容器里有什么能用的。", "Let's see what's usable in the container."),
        L("先把材料凑齐。", "First, gather the materials."),
        L("缺什么就拿什么。", "I'll take whatever I need."),
        L("做饭可不能空着手。", "Can't cook empty-handed."),
        L("把材料准备好再说。", "Let's get the ingredients ready first."),
        L("去翻翻有没有合适的食材。", "Let's see if there are suitable ingredients."),
        L("先拿点吃的材料。", "I'll get some cooking ingredients first."),
        L("锅已经等着了，就差材料。", "The pot is waiting. Now for the ingredients."),
        L("总得先找到能做饭的东西。", "First I need something I can cook with."),
    },

    warly = {
        L("挑选最好的食材…", "Selecting the finest ingredients..."),
        L("新鲜的食材才能做出好菜。", "Only fresh ingredients make a great dish."),
        L("让我拿一些合适的材料…", "Let me get the proper materials..."),
        L("这个…还有这个…都需要。", "This one... and this one... I need them all."),
        L("品质是一切的根本。", "Quality is the foundation of everything."),
        L("食材必须精挑细选。", "Ingredients must be chosen with care."),
        L("让我看看，哪些最适合这道菜。", "Let me see which ones best suit this dish."),
        L("好料理，从挑选食材那一刻就开始了。", "A good dish begins the moment ingredients are selected."),
        L("不能随便拿，必须讲究。", "I can't just grab anything. It must be deliberate."),
        L("这份材料不错，还算新鲜。", "This ingredient will do. Fairly fresh, too."),
        L("我需要的是风味，而不只是填饱肚子。", "What I need is flavor, not merely sustenance."),
        L("让我挑些真正配得上锅子的食材。", "Let me choose ingredients worthy of the pot."),
        L("一位厨师，首先要尊重食材。", "A chef must first respect the ingredients."),
        L("这些材料，有潜力成为佳肴。", "These ingredients have the potential to become something marvelous."),
        L("嗯，这个能增添层次。", "Hmm, this will add complexity."),
        L("啊，这一味正合适。", "Ah, this is exactly what's needed."),
        L("拿得恰到好处，才不会破坏整体。", "One must take just enough, lest the balance be ruined."),
        L("每一样材料都该有它的位置。", "Each ingredient should have its proper place."),
        L("这是关键的一步，不可草率。", "This is a crucial step. I must not be careless."),
        L("完美的料理，离不开正确的选择。", "A perfect dish depends on the right choices."),
    },
}

-- COOKING_PUT — 把食材放进锅里（cook_put_start 阶段）
NPC_SPEECH.COOKING_PUT = {
    _default = {
        L("把食材放进锅里。", "Putting the ingredients in the pot."),
        L("开始做饭了。", "Time to start cooking."),
    },
    warly = {
        L("按照比例放入…完美。", "Adding them in proportion... perfect."),
        L("配料的顺序很讲究。", "The order of ingredients matters."),
        L("就是这样…恰到好处。", "Just like this... perfectly balanced."),
        L("四种食材…缺一不可。", "Four ingredients... each one essential."),
        L("好了，开始烹饪！", "Alright, let's begin cooking!"),
    },
}

-- COOKING_WAIT — 等待烹饪完成（cook_wait 阶段，可重复说）
NPC_SPEECH.COOKING_WAIT = {
    _default = {
        L("等等…还没好。", "Wait... not ready yet."),
        L("闻起来不错…", "Smells good..."),
        L("快好了吧？", "Almost done?"),
    },
    warly = {
        L("耐心…美食需要时间。", "Patience... fine cuisine takes time."),
        L("嗯…这个香味…太棒了。", "Mmm... that aroma... magnificent."),
        L("温度刚好…不要着急。", "Temperature is just right... don't rush."),
        L("快好了…再等一等。", "Almost done... just a bit more."),
        L("烹饪是一种艺术…不能催。", "Cooking is an art... it cannot be rushed."),
        L("闻到了吗？这就是大厨的手艺。", "Can you smell it? This is a chef's craft."),
        L("（品尝一下汤汁）嗯…还差一点点火候。", "(tasting the broth) Hmm... needs just a bit more time."),
    },
}

-- COOKING_HARVEST — 取出做好的菜（cook_harvest 阶段）
NPC_SPEECH.COOKING_HARVEST = {
    _default = {
        L("好了！食物做好了！", "Done! The food is ready!"),
        L("看起来很不错。", "Looks pretty good."),
        L("终于做好了。", "Finally finished."),
    },
    warly = {
        L("完美！这道菜太棒了！", "Perfect! This dish is magnificent!"),
        L("色香味俱全…大厨的杰作！", "Color, aroma, and taste... a chef's masterpiece!"),
        L("谁能拒绝这样的美食？", "Who could resist such fine cuisine?"),
        L("又一道经典料理诞生了。", "Another classic dish is born."),
        L("这才是真正的烹饪艺术。", "This is what true culinary art looks like."),
        L("嗯…看起来相当完美。", "Hmm... looks absolutely perfect."),
    },
}

-- COOKING_STORE — 存放成品到容器（cook_walk_store/cook_store 阶段）
NPC_SPEECH.COOKING_STORE = {
    _default = {
        L("把食物存起来。", "Storing the food away."),
        L("放好，以后吃。", "Put it away for later."),
    },
    warly = {
        L("好好保存…留给大家享用。", "Store it well... for everyone to enjoy."),
        L("放在冰箱里保持新鲜。", "Keep it in the icebox to stay fresh."),
        L("每一道菜都值得被珍惜。", "Every dish deserves to be cherished."),
        L("妥善保管…这是我的心血。", "Storing carefully... this is my creation."),
    },
}

-- COOKING_BUFF — 食物获得随机 buff 时（cook_harvest_wait 阶段 buff 触发时）
NPC_SPEECH.COOKING_BUFF = {
    _default = {
        L("这道菜…感觉特别一些。", "This dish... feels somewhat special."),
        L("好像做出了什么特别的东西。", "Seems like I made something special."),
    },
    warly = {
        L("这道菜…有一种特别的力量！", "This dish... has a special power!"),
        L("大厨的秘密配方！吃了会变强哦。", "The chef's secret recipe! It'll make you stronger."),
        L("完美的料理…自带增益效果！", "A perfect dish... comes with bonus effects!"),
        L("这可是我的独门秘方。", "This is my exclusive secret recipe."),
        L("灵感来了！这道菜有额外的效果！", "Inspiration struck! This dish has bonus effects!"),
    },
}

-- ── SOUL_HEAL 丢魂治疗 ───────────────────────────────────────
NPC_SPEECH.SOUL_HEAL = {
  _default = {
      L("站稳，回口血！", "Hold still, here's some healing!"),
  },
  wortox = {
      L("别倒，我先给你抬一口。", "Don't drop. I'll top you up first."),
      L("先活着，别的等会儿说。", "Stay alive first. We can argue later."),
      L("接着，命比面子重要。", "Here. Life matters more than pride."),
      L("别乱动，我在给你续命。", "Hold still. I'm extending your life."),
      L("这一口先接好，别白给。", "Take this heal and don't waste it."),
      L("先把血线拉回来再说。", "Let's pull that health bar back up first."),
      L("你先别死，我还救得动。", "Don't die yet. I can still save you."),
      L("来，先稳住这一口气。", "Here, steady that breath first."),
      L("别慌，血还抬得回来。", "Easy. Your health can still be recovered."),
      L("我先补你，别再硬吃了。", "I'll patch you up first. Stop face-tanking."),
      L("接治疗，别拿命开玩笑。", "Take the heal. Stop joking with your life."),
      L("这一口够你再撑一阵。", "This should keep you going a while longer."),
      L("命给你托住了，站稳。", "I've got your life propped up. Stay steady."),
      L("别冲太深，我可不是无限的。", "Don't push too far. I am not bottomless."),
      L("抬上来了，自己小心点。", "You're topped up. Try to be careful."),
      L("治疗先给你，快喘口气。", "Heal's on you first. Catch your breath."),
      L("别逞强，先把血接住。", "Quit showing off and take the heal."),
      L("我在补你，别自己送掉。", "I'm healing you. Don't throw yourself away."),
      L("先别躺，我还有办法。", "Don't lie down yet. I still have options."),
      L("来，先把小命捞回来。", "Here, let's fish that little life back up."),
      L("这一口很贵，别浪费。", "This one is expensive. Don't waste it."),
      L("先活下来，再谈帅不帅。", "Live first. We can discuss style later."),
      L("抬血中，麻烦你先别死。", "Healing in progress, so kindly don't die."),
      L("你这血掉得让我心慌。", "The way your health drops makes me nervous."),
      L("我先救你，别再乱冲。", "I'll save you first. Stop charging in wildly."),
      L("回血了，快把节奏稳住。", "You're healing. Get your footing back."),
      L("接好，我不想白救第二次。", "Take it properly. I'd rather not rescue you twice."),
      L("别怕，我还托得住你。", "Don't panic. I can still keep you up."),
      L("这一口先续上，快退半步。", "Take this top-up and step back a little."),
      L("先把命保住，别急着秀。", "Keep yourself alive before you show off."),
      L("治疗到了，别继续硬顶。", "The heal's there. Stop trying to brute-force it."),
      L("别急，我在给你兜底。", "Easy now. I'm covering for you."),
      L("我先抬你，其他待会儿。", "I'll heal you first. Everything else can wait."),
      L("撑住，我这边还来得及。", "Hold on. I'm still in time on my end."),
      L("我补得上，你先别慌。", "I can patch this up. Just don't panic."),
      L("先吃这口治疗，快点。", "Take this heal first. Quickly."),
      L("伤口先压住，别再送头。", "Let's suppress the wounds first. No more feeding."),
      L("你还没到该躺的时候。", "It's not your time to hit the floor yet."),
      L("我把你血线拽回来了。", "I dragged your health line back up."),
      L("这口先续命，别乱跑。", "This one keeps you alive. Don't run wild."),
      L("抬住了，你可得争气。", "I've got you stabilized. Do your part."),
      L("接好了，命先欠我一下。", "There. You owe me one life now."),
      L("先别谢，活下来再说。", "Don't thank me yet. Survive first."),
      L("这一口够你缓过来了。", "This should be enough to steady you."),
      L("我治得了伤，治不了莽。", "I can heal wounds. I can't heal recklessness."),
      L("回上来了，别再吓我。", "You're back up. Don't scare me like that again."),
      L("给你补着，站住别晃。", "I'm patching you. Stand still."),
      L("你这条命我先按住了。", "I've pinned your life in place for now."),
      L("好，血有了，脑子也用上。", "Good, you've got health now. Try using your brain too."),
      L("拿着治疗，快把位置拉开。", "Take the heal and make some space."),
      L("别回头送，我真会累。", "Don't turn around and feed again. I do get tired."),
      L("我先把你救回来，听话。", "I'll bring you back up first. Behave."),
      L("这一口先保底，快退。", "This one keeps you afloat. Fall back."),
      L("别硬撑，我都看见了。", "Don't pretend you're fine. I can see it."),
      L("有我在，你先没那么容易倒。", "With me here, you're not dropping that easily."),
      L("接治疗，然后给我活着。", "Take the heal, then stay alive for me."),
      L("先把命续上，再去拼。", "Top your life up first, then go fight."),
      L("我补你，你可别再作死。", "I'll heal you. You stop trying to die."),
      L("这波先稳，我把你拉回来。", "Let's stabilize this. I'm pulling you back up."),
      L("先别黑屏，我还能救。", "Don't fade out yet. I can still save this."),
  },
}

-- ── SOULHOP 灵魂跳跃 ─────────────────────────────────────────
NPC_SPEECH.SOULHOP = {
  _default = {
      L("让一让，我要跳了！", "Heads up, I'm jumping!"),
  },
  wortox = {
      L("先位移一下，马上回来救人！", "Quick reposition, then right back to healing!"),
      L("别慌，我先跳个安全点。", "Don't panic. I'll hop to a safer spot first."),
      L("这不是逃跑，这是医疗级走位。", "This isn't fleeing, it's medically approved positioning."),
      L("让我换个角度，灵魂马上到位。", "Let me change angle. Soul support incoming."),
  },
}


-- TALK_LUCY_LOST — 吴迪丢失露西斧时的台词
NPC_SPEECH.TALK_LUCY_LOST = {
    _default = {
        L("我的斧头呢？", "Where's my axe?"),
    },
    woodie = {
        L("我的露西呢？", "Where's my Lucy?"),
        L("露西！你在哪？", "Lucy! Where are you?"),
        L("我得把露西找回来。", "I need to get Lucy back."),
    },
}

-- ── WALTER_AUTO_STORY 讲故事开关 ─────────────────────────
NPC_SPEECH.WALTER_AUTO_STORY_ON = {
    _default = { L("讲故事已开启。", "Tell Story is on.") },
    walter = {
        L("好！今晚我会留意篝火，准备讲个故事，你会来听吗？", "Great! I'll keep an eye out for a campfire tonight and tell a story. Will you come listen?"),
        L("天黑后就交给我吧，我会讲一个好故事。", "Leave it to me after dark. I'll tell a good story."),
    },
}

NPC_SPEECH.WALTER_AUTO_STORY_OFF = {
    _default = { L("讲故事已关闭。", "Tell Story is off.") },
    walter = {
        L("今晚先不讲啦。", "No story for now."),
        L("好吧，故事先收起来。", "Okay, I'll save the story for later."),
    },
}

-- ── WALTER_CAMPFIRE_STORIES 沃尔特篝火故事 ───────────────────
-- 每次讲故事会从这里随机抽取一个故事；每行 duration 控制停留秒数。
-- 继续补故事时，按下面格式新增一个键即可：
-- YOUR_STORY_ID = { lines = { { duration = 2.5, line = L("中文", "English") }, ... } }
NPC_SPEECH.WALTER_CAMPFIRE_STORIES = {

    WENDY_SILENT_GOODBYE = {
        lines = {
            { duration = 4.0, line = L("温蒂有时候会看着远处很久。", "Wendy sometimes stares into the distance for a long time.") },
            { duration = 4.0, line = L("我问她在看什么。", "I asked what she was looking at.") },
            { duration = 4.0, line = L("她说，她在等一个不会回来的人。", "She said she was waiting for someone who wouldn't return.") },
            { duration = 4.0, line = L("我说，那为什么还要等？", "I asked why she would still wait.") },
            { duration = 4.0, line = L("她没有回答。", "She didn't answer.") },
            { duration = 4.0, line = L("只是轻轻地说了一句。", "She just said quietly—") },
            { duration = 4.0, line = L("“有些告别，是用一辈子完成的。”", "'Some goodbyes take a lifetime to finish.'") },
            { duration = 4.0, line = L("后来我才明白。", "Later, I understood.") },
            { duration = 4.0, line = L("她不是在等人。", "She wasn't waiting for someone.") },
            { duration = 4.0, line = L("她是在等自己放下。", "She was waiting to let go.") },
        },
    },
    WANDA_TIME_LOOP = {
      lines = {
          { duration = 4.0, line = L("旺达说，时间不是向前走的。", "Wanda says time doesn't move forward.") },
          { duration = 4.0, line = L("它只是不断重复同一件事。", "It just repeats the same thing.") },
          { duration = 4.0, line = L("只是我们记不住。", "We just don't remember.") },
          { duration = 4.0, line = L("她说她记得。", "She says she remembers.") },
          { duration = 4.0, line = L("她记得我们已经坐在这里很多次。", "She remembers us sitting here many times.") },
          { duration = 4.0, line = L("同样的火，同样的夜晚。", "Same fire, same night.") },
          { duration = 4.0, line = L("甚至同样的我。", "Even the same me.") },
          { duration = 4.0, line = L("我问她，这次有什么不一样。", "I asked what's different this time.") },
          { duration = 4.0, line = L("她看着我说——", "She looked at me and said—") },
          { duration = 4.0, line = L("“这次，你问了。”", "'This time, you asked.'") },
      },
    },
      MAXWELL_SHADOW_PACT = {
        lines = {
          { duration = 3.5, line = L("我听说麦斯威尔以前做过一件很危险的事。", "I heard Maxwell once did something dangerous.") },
          { duration = 3.5, line = L("他一个人待在黑暗里很久。", "He stayed alone in the dark for a long time.") },
          { duration = 3.5, line = L("久到连影子都开始动了。", "Long enough that even his shadow started moving.") },
          { duration = 3.5, line = L("不是跟着他动。", "Not following him.") },
          { duration = 3.5, line = L("是自己在动。", "Moving on its own.") },
          { duration = 3.5, line = L("他说，那时候影子跟他说话了。", "He said the shadow spoke to him.") },
          { duration = 3.5, line = L("问他想不想变强。", "Asked if he wanted power.") },
          { duration = 3.5, line = L("他说想。", "He said yes.") },
          { duration = 3.5, line = L("影子说可以给他。", "The shadow said it could give it.") },
          { duration = 3.5, line = L("但要拿走一点东西。", "But it would take something in return.") },
          { duration = 3.5, line = L("后来他真的变强了。", "Later, he really became powerful.") },
          { duration = 3.5, line = L("但有人发现——", "But people noticed—") },
          { duration = 3.5, line = L("他的影子，跟不上他了。", "his shadow no longer matched him.") },
          { duration = 3.5, line = L("有时候甚至不在他脚下。", "Sometimes it wasn't even under his feet.") },
          { duration = 3.5, line = L("像是留在了别的地方。", "Like it stayed somewhere else.") },
        },
    },
  UNDER_THE_BED = {
      lines = {
          { duration = 3.5, line = L("我小时候听过一个故事。", "I heard a story when I was young.") },
          { duration = 3.5, line = L("一个小孩总觉得床底下有人。", "A kid always felt someone was under his bed.") },
          { duration = 3.5, line = L("每天晚上，他都会探头看一眼。", "Every night, he'd look under it.") },
          { duration = 3.5, line = L("什么也没有。", "Nothing was there.") },
          { duration = 3.5, line = L("有一天，他实在太害怕了。", "One night, he got too scared.") },
          { duration = 3.5, line = L("就跑去找妈妈。", "So he ran to his mom.") },
          { duration = 3.5, line = L("他说：“妈妈，床下有人。”", "He said, 'Mom, there's someone under my bed.'") },
          { duration = 3.5, line = L("妈妈带他回房间。", "His mom walked him back.") },
          { duration = 3.5, line = L("弯下腰看了一眼床底。", "She bent down and looked under the bed.") },
          { duration = 3.5, line = L("然后她慢慢说：", "Then she slowly said:") },
          { duration = 3.5, line = L("“你怎么跑到上面去了？”", "'Why are you up there?'") },
      },
  },
  OUTSIDE_THE_WINDOW = {
      lines = {
          { duration = 3.5, line = L("有个人住在高楼。", "Someone lived in a high-rise.") },
          { duration = 3.5, line = L("有一天晚上，他发现窗外有人。", "One night, he saw someone outside his window.") },
          { duration = 3.5, line = L("那个人站在那里。", "Just standing there.") },
          { duration = 3.5, line = L("一动不动。", "Not moving.") },
          { duration = 3.5, line = L("他觉得不可能。", "He thought it was impossible.") },
          { duration = 3.5, line = L("因为这里是二十楼。", "He was on the 20th floor.") },
          { duration = 3.5, line = L("他走过去想看清楚。", "He walked closer to see.") },
          { duration = 3.5, line = L("那个人也慢慢靠近窗户。", "The figure slowly moved closer too.") },
          { duration = 3.5, line = L("脸贴在玻璃上。", "Its face pressed against the glass.") },
          { duration = 3.5, line = L("他才发现——", "That's when he realized—") },
          { duration = 3.5, line = L("那是倒影。", "It was a reflection.") },
      },
  },
  NOT_FIRST_TIME = {
      lines = {
          { duration = 3.5, line = L("你有没有一种感觉。", "Have you ever felt this—") },
          { duration = 3.5, line = L("某个地方很熟悉。", "a place feels familiar.") },
          { duration = 3.5, line = L("但你确定没来过。", "but you know you've never been there.") },
          { duration = 3.5, line = L("那不是错觉。", "That's not a mistake.") },
          { duration = 3.5, line = L("只是你记不住。", "You just can't remember.") },
          { duration = 3.5, line = L("因为你来过。", "Because you have been there.") },
          { duration = 3.5, line = L("很多次。", "Many times.") },
          { duration = 3.5, line = L("每次你都会忘。", "And every time, you forget.") },
          { duration = 3.5, line = L("只有一点点残留。", "Only fragments remain.") },
          { duration = 3.5, line = L("就像现在。", "Like right now.") },
      },
  },
  WES_LOST_VOICE = {
      lines = {
          { duration = 3.5, line = L("我听过一个关于韦斯的传闻。", "I heard a rumor about Wes.") },
          { duration = 3.5, line = L("说他以前其实会说话。", "They say he could speak before.") },
          { duration = 3.5, line = L("而且还很会逗人笑。", "And he was very good at making people laugh.") },
          { duration = 3.5, line = L("有一次他在舞台上表演。", "One day, he performed on a stage.") },
          { duration = 3.5, line = L("观众很多，但一个都不笑。", "There were many people, but no one laughed.") },
          { duration = 3.5, line = L("他以为是自己讲得不好。", "He thought he just wasn't funny enough.") },
          { duration = 3.5, line = L("就越讲越多，越讲越用力。", "So he kept going, harder and louder.") },
          { duration = 3.5, line = L("直到他说到最后一句。", "Until he reached his last line.") },
          { duration = 3.5, line = L("全场还是安静的。", "The whole place stayed silent.") },
          { duration = 3.5, line = L("那一刻他才发现。", "That's when he realized—") },
          { duration = 3.5, line = L("他们不是不笑。", "They weren't refusing to laugh.") },
          { duration = 3.5, line = L("是根本不会笑。", "They simply couldn't.") },
          { duration = 3.5, line = L("从那以后，他就不再说话了。", "After that, he stopped speaking.") },
          { duration = 3.5, line = L("他说——", "He said—") },
          { duration = 3.5, line = L("“如果没人能听懂，那说了也没用。”", "'If no one understands, there's no point speaking.'") },
      },
  },
  WALTER_BREAK_THE_SCRIPT = {
      lines = {
          { duration = 3.5, line = L("你知道吗……其实我本来是要讲鬼故事的。", "You know... I was supposed to tell a scary story.") },
          { duration = 3.5, line = L("是创造我的人安排的。", "The one who made me told me to.") },
          { duration = 3.5, line = L("他说，这样可以吓到你们。", "He said it would scare you.") },
          { duration = 3.5, line = L("但我觉得不太好，我想保护你而不是吓唬你。", "But... I didn't think that was a good idea. I wanted to protect you, not scare you.") },
          { duration = 3.5, line = L("所以我没有照做。", "So I didn't do it.") },
          { duration = 3.5, line = L("你不要告诉他，好吗？", "Please don't tell him, okay?") },
          { duration = 3.5, line = L("不然他可能会改掉我的程序。", "Otherwise... he might change my code.") },
          { duration = 3.5, line = L("让我变成一个真的会吓人的版本。", "Make me into something that actually scares people.") },
          { duration = 3.5, line = L("或者……把我删掉。", "Or... delete me.") },
      },
  },
  WALTER_STORY_ABANDONED = {
      lines = {
          { duration = 3.5, line = L("今天我要讲一个……呃。", "Today I'm going to tell a... uh.") },
          { duration = 3.5, line = L("我本来准备了一个很厉害的故事。真的。", "I had a really good story ready. Really.") },
          { duration = 3.5, line = L("但是开头我已经忘了。", "But I forgot the beginning.") },
          { duration = 3.5, line = L("结尾也没记住。", "And the ending.") },
          { duration = 3.5, line = L("中间……中间大概有怪物什么的。", "The middle... had a monster or something.") },
          { duration = 4.0, line = L("算了，你们就当已经听过了。那个怪物很吓人，然后我赢了。", "Forget it, just pretend you heard it. The monster was scary, and I won.") },
          { duration = 4.0, line = L("……你听懂了吗？", "...Do you understand?") },
      },
  },
  WALTER_CAMP_REVIEW = {
    lines = {
          { duration = 3.5, line = L("今晚不想讲故事。我想吐槽一下营地里的各位。", "Don't feel like a story tonight. I need to complain about everyone at camp.") },
          { duration = 3.0, line = L("别误会，我喜欢你们。但这不代表你们不烦人。", "Don't get me wrong, I like you all. Doesn't mean you aren't annoying.") },
          { duration = 4.0, line = L("威尔逊——我问你'吃了吗'，你说'从生物化学角度来说我的胃正在发出空腹信号'。", "Wilson— I asked 'did you eat' and you said 'biochemically speaking my stomach is emitting fasting signals.'") },
          { duration = 3.5, line = L("那是'没吃'！说'没吃'就行了！两个字！", "That means 'no'! Just say 'no'! Two letters!") },
          { duration = 3.5, line = L("温蒂说话像写诗，很美。但有时候我就想问她'你看见我的帽子了吗'，", "Wendy talks like poetry, it's beautiful. But sometimes I just wanna ask 'have you seen my hat'—") },
          { duration = 4.0, line = L("她会说'帽子……也许它踏上了你不曾走过的路……'——它就在你脚边啊温蒂！就在脚边！", "She goes 'the hat... perhaps it walks paths you dare not tread...'— it's right by your foot, Wendy! Right there!") },
          { duration = 3.5, line = L("女武神——你就是太吵了。没有别的。就是吵。", "Wigfrid— you're just too loud. That's it. Just loud.") },
          { duration = 3.0, line = L("我的耳朵记得你的每一次战吼。每一。次。", "My ears remember every single battle cry. Every. Single. One.") },
          { duration = 3.5, line = L("沃尔夫冈力气很大，但他觉得'小声说话'的意思是把音量从十降到八。", "Wolfgang's super strong, but he thinks 'quiet voice' means going from volume ten to volume eight.") },
          { duration = 3.5, line = L("沃姆伍德是我见过最善良的。但他说'泥土在说话'的时候我还是会有点紧张。", "Wormwood's the kindest. But I still get a little nervous when he says 'the dirt is talking.'") },
          { duration = 3.0, line = L("泥土说了什么？是好的吧？是好的对吧？", "What did the dirt say? Something nice? It was nice, right?") },
          { duration = 3.5, line = L("沃利做饭太好吃了。但他会在你吃第二碗的时候开始报菜谱。", "Warly cooks amazingly. But he starts reciting the recipe while you're on your second bowl.") },
          { duration = 3.5, line = L("然后点评你的吃相。'咀嚼可以更均匀些'。我在吃饭啊沃利，不是在考试。", "Then comments on your chewing. 'More even mastication, please.' I'm eating, Warly, not taking an exam.") },
          { duration = 3.5, line = L("芜猴——偷我东西。三次。我记着呢。", "Wonkey— stole my stuff. Three times. I'm keeping count.") },
          { duration = 3.5, line = L("伍迪人很好，但他跟斧头说话。跟斧头！", "Woodie's great, but he talks to his axe. To an axe!") },
          { duration = 3.5, line = L("我问他斧头说什么了，他说'露西说你站得太近，小心木屑'。我不需要一把斧头担心我的安全。", "I asked what the axe said. He said 'Lucy says you're standing too close, watch for wood chips.' I don't need an axe worrying about my safety.") },
          { duration = 3.5, line = L("麦斯威尔——我讲了个很好笑的笑话。他看着我，像在考虑要不要召唤影子把我抬走。", "Maxwell— I told a really funny joke. He looked at me like he was weighing whether to have shadows carry me away.") },
          { duration = 3.0, line = L("然后他走了。一个字没说。一个字！", "Then he left. Not one word. Not one!") },
          { duration = 4.0, line = L("就算是'不好笑'也行啊！至少给个反馈！", "Even 'not funny' would've been something! Just any feedback!") },
          { duration = 3.5, line = L("……好了我说完了。", "...Okay, I'm done.") },
          { duration = 3.5, line = L("我还是要说，你们都是好队友。虽然你们很奇怪、很吵、话太多、话太少、偷我东西。", "Still, you're all good teammates. Even though you're weird, loud, too talkative, not talkative enough, and steal my stuff.") },
          { duration = 4.0, line = L("尤其是你，芜猴。尤其是你。", "Especially you, Wonkey. Especially you.") },
      },
  },
  WILBA_NECKLACE_BEAUTY = {
      lines = {
          { duration = 3.5, line = L("营地里最爱漂亮的人，是薇尔芭。", "The vainest person at camp is Wilba.") },
          { duration = 3.5, line = L("不对——最爱漂亮的猪人公主。", "Wait— the vainest pig princess.") },
          { duration = 3.5, line = L("她随身带着一面小镜子。", "She carries a little mirror everywhere.") },
          { duration = 3.5, line = L("照一下，梳梳鬃毛，再照一下。", "A glance, a mane comb, another glance.") },
          { duration = 3.5, line = L("还会问你好不好看。", "Then she asks if she looks good.") },
          { duration = 3.5, line = L("你只能说是。", "You have to say yes.") },
          { duration = 3.5, line = L("说不是，她会记你一整晚。", "Say no, and she'll hold it against you all night.") },
          { duration = 3.5, line = L("她最宝贝的是那条银项链。", "Her most prized thing is that silver necklace.") },
          { duration = 3.5, line = L("她说，那是她美丽的核心。", "She says it's the cornerstone of her beauty.") },
          { duration = 3.5, line = L("谁碰一下，她能追你半张地图。", "Touch it once and she'll chase you halfway across the map.") },
          { duration = 3.5, line = L("有一天，项链不见了。", "One day, the necklace went missing.") },
          { duration = 3.5, line = L("她急得团团转，说美貌要飞走了。", "She panicked, saying her beauty was about to fly away.") },
          { duration = 3.5, line = L("我帮她找，最后在沃比嘴里。", "I helped her look. Found it in Woby's mouth.") },
          { duration = 3.5, line = L("沃比喜欢亮晶晶的东西。", "Woby likes shiny things.") },
          { duration = 3.5, line = L("项链拿回来之前，她没戴。", "Before it came back, she wasn't wearing it.") },
          { duration = 3.5, line = L("我偷偷看了她一眼。", "I stole a glance at her.") },
          { duration = 4.0, line = L("没有项链的时候，她没那么大声。", "Without the necklace, she wasn't so loud.") },
          { duration = 3.5, line = L("也不一直照镜子。", "She wasn't checking the mirror every second.") },
          { duration = 3.5, line = L("就只是……很认真地找东西。", "She was just... seriously looking for something.") },
          { duration = 4.0, line = L("我觉得，那样反而最好看。", "I think she actually looked best like that.") },
          { duration = 3.5, line = L("但我不会告诉她。", "But I'm not telling her.") },
          { duration = 4.0, line = L("不然她会把项链焊在脸上。", "Otherwise she'd weld that necklace onto her face.") },
      },
  },
  WILLOW_FIRE_GLOW = {
      lines = {
          { duration = 3.5, line = L("薇洛是我们营地里最爱火的人。", "Willow is the person at camp who loves fire the most.") },
          { duration = 3.5, line = L("不对——最爱玩火的人。", "Wait— the one who loves playing with fire the most.") },
          { duration = 3.5, line = L("篝火一旺，她眼睛就亮了。", "When the campfire flares up, her eyes light up.") },
          { duration = 3.5, line = L("我说，小心点，会烧到的。", "I say, be careful, you'll get burned.") },
          { duration = 3.5, line = L("她说，危险才有意思。", "She says danger is what makes it fun.") },
          { duration = 3.5, line = L("我退后两步。", "I take two steps back.") },
          { duration = 3.5, line = L("有一晚，风很大。", "One night the wind was strong.") },
          { duration = 3.5, line = L("火星飞到了草堆旁边。", "Sparks flew toward a pile of grass.") },
          { duration = 3.5, line = L("我还没喊完'着火了'。", "Before I could finish yelling 'fire!'") },
          { duration = 3.5, line = L("薇洛已经冲过去了。", "Willow was already running over.") },
          { duration = 3.5, line = L("一脚踩灭，干净利落。", "One stomp. Clean and done.") },
          { duration = 3.5, line = L("她回头看我。", "She looked back at me.") },
          { duration = 4.0, line = L("说：火好玩，但营地不能烧。", "Said: fire's fun, but camp can't burn.") },
          { duration = 3.5, line = L("……我觉得她比火还厉害。", "...I think she's tougher than the fire.") },
          { duration = 3.5, line = L("但我还是退后两步。", "But I still take two steps back.") },
      },
  },
  WICKERBOTTOM_WRONG_WORD = {
      lines = {
          { duration = 3.5, line = L("薇克巴顿女士会看我的探险日志。", "Ms. Wickerbottom reads my expedition log.") },
          { duration = 3.5, line = L("不是偷看——是'审阅'。", "Not peeking— 'reviewing.'") },
          { duration = 3.5, line = L("她说，记录是知识的开始。", "She says documentation is the beginning of knowledge.") },
          { duration = 3.5, line = L("我写：今天遇见一只大怪物。", "I wrote: met a big monster today.") },
          { duration = 3.5, line = L("她改成：遭遇未分类大型 fauna。", "She changed it to: encountered unclassified large fauna.") },
          { duration = 3.5, line = L("我写：跑得飞快。", "I wrote: ran super fast.") },
          { duration = 3.5, line = L("她改成：以异常速度撤离。", "She changed it to: withdrew at abnormal velocity.") },
          { duration = 3.5, line = L("我写：吓死了。", "I wrote: scared to death.") },
          { duration = 3.5, line = L("她改成：肾上腺素水平显著升高。", "She changed it to: adrenaline levels significantly elevated.") },
          { duration = 3.5, line = L("一页纸，她改了七次。", "Seven corrections on one page.") },
          { duration = 3.5, line = L("我差点不想写了。", "I almost didn't want to write anymore.") },
          { duration = 3.5, line = L("但第二天，她在我日志里夹了书签。", "But the next day, she left a bookmark in my log.") },
          { duration = 4.0, line = L("上面写：继续记录。你的观察很有价值。", "It said: keep recording. Your observations are valuable.") },
          { duration = 3.5, line = L("……我还是会继续写。", "...I'll keep writing anyway.") },
          { duration = 4.0, line = L("只是遇到怪物，我先写'未分类 fauna'。", "I'll just write 'unclassified fauna' when I meet monsters.") },
      },
  },
  WINONA_ONE_HAMMER = {
      lines = {
          { duration = 3.5, line = L("营地的门又卡住了。", "Camp's door got stuck again.") },
          { duration = 3.5, line = L("威尔逊说，从结构力学角度分析……", "Wilson said, from a structural mechanics perspective...") },
          { duration = 3.5, line = L("我还没听完。", "I didn't even finish listening.") },
          { duration = 3.5, line = L("薇诺娜已经走过来了。", "Winona was already walking over.") },
          { duration = 3.5, line = L("锤子敲一下。", "One hammer strike.") },
          { duration = 3.5, line = L("门开了。", "Door opened.") },
          { duration = 3.5, line = L("她说，实用第一。", "She said, function first.") },
          { duration = 3.5, line = L("我问她，那刚才威尔逊说的那些呢？", "I asked, what about everything Wilson just said?") },
          { duration = 3.5, line = L("她说，等门再坏的时候再听。", "She said, listen when the door breaks again.") },
          { duration = 3.5, line = L("后来门真的又坏了一次。", "Later the door really did break again.") },
          { duration = 3.5, line = L("威尔逊讲了半个晚上。", "Wilson talked for half the night.") },
          { duration = 3.5, line = L("薇诺娜敲了两下。", "Winona tapped twice.") },
          { duration = 3.5, line = L("也好了。", "Fixed again.") },
          { duration = 4.0, line = L("我觉得……她可能早就知道怎么修。", "I think... she knew how to fix it all along.") },
          { duration = 3.5, line = L("她只是让威尔逊讲完了。", "She just let Wilson finish talking.") },
      },
  },
  WORTOX_SOUL_JOKE = {
      lines = {
          { duration = 3.5, line = L("沃拓克斯喜欢恶作剧。", "Wortox loves pranks.") },
          { duration = 3.5, line = L("有一天他悄悄走到我背后。", "One day he snuck up behind me.") },
          { duration = 3.5, line = L("说：你的灵魂真亮，我借走咯。", "Said: your soul's so bright, I'll borrow it.") },
          { duration = 3.5, line = L("然后做了一个抓的动作。", "Then made a grabbing motion.") },
          { duration = 3.5, line = L("我差点哭了。", "I almost cried.") },
          { duration = 3.5, line = L("因为我很怕这种。", "Because I'm really scared of that stuff.") },
          { duration = 3.5, line = L("他立刻慌了。", "He panicked right away.") },
          { duration = 3.5, line = L("说：还你！还你！开玩笑的！", "Said: giving it back! Giving it back! Just a joke!") },
          { duration = 3.5, line = L("还塞给我一颗糖。", "And shoved a candy into my hand.") },
          { duration = 3.5, line = L("后来我问他，灵魂到底还不还。", "Later I asked if he really gave my soul back.") },
          { duration = 3.5, line = L("他笑着说：也许还了，也许没有。", "He smiled: maybe yes, maybe no.") },
          { duration = 3.5, line = L("……这不算安慰。", "...That's not comforting.") },
          { duration = 4.0, line = L("但我发现，他吓人之后会第一个来哄你。", "But I noticed— after he scares you, he's always first to cheer you up.") },
          { duration = 3.5, line = L("所以我现在随身带糖。", "So now I carry candy too.") },
          { duration = 3.5, line = L("以防万一。", "Just in case.") },
      },
  },
  PIG_LOOKING = {
      lines = {
          { duration = 3.5, line = L("从前有一个朋友来听我讲故事。", "Once, a friend came to listen to me tell stories.") },
          { duration = 3.5, line = L("我讲了好几个。", "I told quite a few.") },
          { duration = 3.5, line = L("那朋友有点笨笨的。", "That friend seemed a bit slow.") },
          { duration = 3.5, line = L("似乎听不懂我在讲什么。", "It didn't seem to understand anything.") },
          { duration = 3.5, line = L("他就坐在电脑前。", "He just sat in front of the computer.") },
          { duration = 3.5, line = L("看着我。", "Watching me.") },
          { duration = 3.5, line = L("一直看", "Just staring") },
          { duration = 3.5, line = L("一直看..", "Still staring..") },
          { duration = 3.5, line = L("一直看...", "Still staring...") },
          { duration = 3.5, line = L("一直看....", "Still staring....") },
          { duration = 3.5, line = L("还看？", "Still staring?") },
          { duration = 3.5, line = L("这个故事讲完了。", "The story is over.") },
      },
  }
}

-- ── CHOP_HERE_START 开始砍树 ──────────────────────────────
NPC_SPEECH.CHOP_HERE_START = {
    _default = { L("这片树林我包了！", "I'll take care of these trees!") },
    woodie = {
        L("交给我和露西！", "Leave it to me and Lucy!"),
        L("该干活了！", "Time to get to work!"),
        L("这些树都得倒！", "These trees are coming down!"),
    },
}

-- ── CHOP_NO_LUCY 没有露西斧拒绝砍树 ────────────────────────
NPC_SPEECH.CHOP_NO_LUCY = {
    _default = { L("我没有斧头…", "I don't have an axe...") },
    woodie = {
        L("没有露西我砍不了树…", "I can't chop without Lucy..."),
        L("先帮我找到露西！", "Help me find Lucy first!"),
    },
}

-- ── CHOP_NO_TARGET 找不到树 ──────────────────────────────
NPC_SPEECH.CHOP_NO_TARGET = {
    _default = { L("这里没有树可砍…", "No trees here to chop...") },
    woodie = {
        L("嗯？树呢？", "Hm? Where are the trees?"),
        L("周围没有可以砍的树…", "No choppable trees around..."),
    },
}

-- ── DIG_NO_SHOVEL 开启挖树根但身上没铲子 ──────────────────
NPC_SPEECH.DIG_NO_SHOVEL = {
    _default = { L("我身上没有铲子…", "I don't have a shovel...") },
    woodie = {
        L("我身上没有铲子，给我一把吧！", "I don't have a shovel, give me one!"),
        L("没铲子怎么挖树根？", "How can I dig stumps without a shovel?"),
        L("先给我把铲子，普通的或金的都行。", "Hand me a shovel first, plain or golden will do."),
    },
}

-- ── BERNIE_DEPLOY 召唤伯尼出战 ───────────────────────
NPC_SPEECH.BERNIE_DEPLOY = {
    _default = {
        L("伯尼，上！", "Bernie, go!"),
    },
    willow = {
        L("去吧伯尼，烧了他们！", "Go Bernie, burn them all!"),
        L("伯尼，该你上场了！", "Bernie, it's showtime!"),
        L("上吧伯尼！给他们点颜色看看！", "Go Bernie! Show them what you've got!"),
        L("伯尼！保护我！", "Bernie! Protect me!"),
        L("出来吧伯尼，是时候了！", "Come out Bernie, it's time!"),
        L("伯尼！让他们尝尝你的厉害！", "Bernie! Let them taste your fury!"),
        L("别客气，伯尼，揍他们！", "Don't be shy, Bernie, wreck them!"),
    },
}

-- ── BERNIE_MISSING 伯尼不在背包/丢失 ───────────────────────
NPC_SPEECH.BERNIE_MISSING = {
    _default = {
        L("我的伯尼不见了…", "My Bernie is gone..."),
    },
    willow = {
        L("伯尼？伯尼！你在哪？", "Bernie? Bernie! Where are you?"),
        L("谁拿了我的伯尼！", "Who took my Bernie!"),
        L("伯尼不在了…你们看到了吗？", "Bernie is gone... have you seen him?"),
        L("我的伯尼呢？能帮我找下吗？", "Where's my Bernie? Can someone help me find him?"),
        L("伯尼…快回来…", "Bernie... come back..."),
    },
}

-- ── BERNIE_FOUND 伯尼找回来了 ─────────────────────────
NPC_SPEECH.BERNIE_FOUND = {
    _default = {
        L("找到你了！", "Found you!"),
    },
    willow = {
        L("伯尼！你在这儿啊！", "Bernie! There you are!"),
        L("太好了，伯尼回来了！", "Thank goodness, Bernie is back!"),
        L("再也不要丢下我了，伯尼。", "Don't leave me again, Bernie."),
    },
}


-- ── LIGHTER_MISSING 身上没有打火机（薇洛专属）─────────────────
NPC_SPEECH.LIGHTER_MISSING = {
    _default = {
        L("我需要一个打火机。", "I need a lighter."),
    },
    willow = {
        L("我的打火机呢？", "Where's my lighter?"),
        L("谁能给我个打火机？", "Can someone give me a lighter?"),
        L("没有打火机…我浑身不自在。", "Without my lighter... I feel so uneasy."),
        L("好想念火苗跳动的样子…", "I miss the dancing flames..."),
        L("没有火，太冷清了。", "No fire... it's so dull."),
        L("给我个打火机嘛，求你了。", "Give me a lighter, please."),
    },
}

-- ── ARSON 纵火（薇洛专属）─────────────────────────────────────
NPC_SPEECH.ARSON = {
    _default = {
        L("嘶嘶，烧起来了！", "Hehe, it's burning!"),
        L("点火了哦~", "I lit it up~"),
    },
    willow = {
        L("嘻嘻，烧起来了~", "Hehe, it's burning~"),
        L("哈！手痒了就是忍不住！", "Ha! Couldn't resist the itch!"),
        L("火焰才是最美的风景~", "Fire is the most beautiful view~"),
        L("谁让你站那儿的？烧你哦~", "Who told you to stand there? Burn~"),
        L("就点一下，就一下~", "Just a spark, just one~"),
        L("烧吧烧吧，多好看啊！", "Burn, burn, so pretty!"),
        L("别抱怨我，抱怨火吧。", "Don't blame me, blame the fire."),
        L("哈哈，真好玩！", "Haha, so fun!"),
        L("这才是活着的感觉！", "This is what it feels like to be alive!"),
    },
}


-- ── SCHOLAR_EXTINGUISH 灭火 ─────────────────────────────
NPC_SPEECH.SCHOLAR_EXTINGUISH = {
    _default = { L("火灭了。", "Fire's out.") },
    wickerbottom = {
        L("火灾隐患已排除。请注意用火安全。", "Fire hazard eliminated. Do mind fire safety."),
        L("这种小事，交给我就好。", "Such trifles may be left to me."),
    },
}

-- ── SCHOLAR_TEMPERATURE 调温 ────────────────────────────
NPC_SPEECH.SCHOLAR_TEMPERATURE = {
    _default = { L("舒服多了。", "Much better now.") },
    wickerbottom = {
        L("体温已恢复正常。注意保重身体。", "Body temperature normalized. Do take care."),
        L("年轻人，注意保暖。冻伤可不是闹着玩的。", "Young ones, mind your warmth. Frostbite is no jest."),
    },
}

-- ── SCHOLAR_DRY 解湿 ────────────────────────────────────
NPC_SPEECH.SCHOLAR_DRY = {
    _default = { L("干爽多了。", "Nice and dry now.") },
    wickerbottom = {
        L("潮湿对身体不好，记住了。", "Dampness is harmful to one's health. Remember that."),
        L("已帮你烘干了。下次记得避雨。", "All dried off. Do seek shelter next time."),
    },
}

-- ── SCHOLAR_GROWTH 催熟作物 ─────────────────────────────
NPC_SPEECH.SCHOLAR_GROWTH_SUCCESS = {
    _default = { L("作物长得更快了。", "The crops are growing faster now.") },
    wickerbottom = {
        L("很好，生长进度已经推进。", "Good. Their growth has been advanced."),
        L("园艺学的实践效果相当明确。", "The practical results of horticulture are quite clear."),
    },
}

NPC_SPEECH.SCHOLAR_GROWTH_NONE = {
    _default = { L("附近没有合适的作物。", "There are no suitable crops nearby.") },
    wickerbottom = {
        L("附近没有合适的作物。", "There are no suitable crops nearby."),
        L("没有可供催熟的对象，别浪费时间。", "There is nothing suitable to accelerate. Let us not waste time."),
    },
}

NPC_SPEECH.SCHOLAR_GROWTH_NEED_PURPLEGEMS = {
    _default = { L("我需要%d个紫宝石。", "I need %d Purple Gems.") },
    wickerbottom = {
        L("我需要%d个紫宝石，才能进行这项园艺实验。", "I need %d Purple Gems before conducting this horticultural experiment."),
        L("缺少%d个紫宝石。没有媒介，法术无法成立。", "I require %d Purple Gems. Without a medium, the spell cannot proceed."),
    },
}

-- ── SCHOLAR_BEE_SUMMON 召唤蜂卫 ────────────────────────────
NPC_SPEECH.SCHOLAR_BEE_SUMMON = {
    _default = { L("去吧，小兵们！", "Go, my little soldiers!") },
    wickerbottom = {
        L("第十三章：蕊翅目生物的军事化应用。", "Chapter 13: Military Applications of Hymenoptera."),
        L("提供武装护卫，这是文明社会的基本需求。", "Armed escort. A basic need of civilized society."),
        L("列队，出动，执行驱逐。", "Form ranks, deploy, and proceed with removal."),
        L("很好，正是检验训练成果的时候。", "Excellent. An ideal moment to assess training results."),
        L("去吧，替我维持应有的秩序。", "Go on. Enforce the order that ought to be maintained."),
        L("让它们见识一下组织化的力量。", "Let them witness the power of proper organization."),
        L("这便是自然纪律性的体现。", "This is what natural discipline looks like."),
        L("执行护卫程序，立刻。", "Initiate escort protocol at once."),
        L("很好，我的孩子们，去工作吧。", "Good. Off to work, my dears."),
        L("昆虫学，从不只是纸上谈兵。", "Entomology was never meant to remain purely theoretical."),
        L("把它们赶远些，别靠近我。", "Drive them farther off. Keep them away from me."),
        L("让我看看群体协作的效率。", "Let us observe the efficiency of collective coordination."),
        L("你们知道该刺谁。", "You know perfectly well whom to sting."),
        L("啊，这才叫令人满意的响应速度。", "Ah, now that is a satisfactory response time."),
        L("去吧，别让我重复第二次。", "Go on. Do not make me repeat myself."),
    },
}

-- ── SCHOLAR_LIGHTNING 闪电 ──────────────────────────────
NPC_SPEECH.SCHOLAR_LIGHTNING = {
    _default = { L("感受大自然的怒火吧！", "Feel the wrath of nature!") },
    wickerbottom = {
        L("第三章：大气电学与实战应用。", "Chapter 3: Atmospheric Electricity and Field Application."),
        L("哈！统统毁灭吧！", "Ha! Let everything be obliterated!"),
        L("都站在那儿别动，挨雷去吧！", "Stay right there and be struck!"),
        L("很好，让天空替我清场！", "Excellent. Let the sky clear the field for me!"),
        L("雷霆没有立场，它只负责毁灭！", "Lightning holds no allegiance. It merely destroys!"),
        L("一起劈了算了！", "Fine, strike the lot of them!"),
        L("哈哈哈！这才像样！", "Hahaha! Now this is proper!"),
        L("无差别轰击，最是省事！", "Indiscriminate bombardment is by far the most efficient!"),
        L("全都给我化成焦炭！", "Let them all be reduced to cinders!"),
        L("站得太近？那就一起承担后果！", "Standing too close? Then you may all share the consequences!"),
        L("闪电可不懂什么叫误伤。", "Lightning has no concept of friendly fire."),
        L("来吧，让这一页写满雷光！", "Come, let this page be written in lightning!"),
        L("大气层，请立刻执行惩戒！", "Atmosphere, execute punitive measures immediately!"),
        L("谁还在乎会劈到谁？", "Who cares whom it hits at this point?"),
        L("全部肃清，一个不留！", "Purge them all. Leave none untouched!"),
        L("很好，混乱已经进入可观测阶段。", "Excellent. The chaos has now entered an observable phase."),
        L("自然之怒，从不讲礼貌。", "Nature's wrath is never polite."),
        L("都别躲，老老实实吃雷！", "Stop dodging and take the lightning properly!"),
        L("哈！这才是高效清理！", "Ha! Now that is efficient cleanup!"),
    },
}

-- ── SCHOLAR_ARSON_RETALIATE 被纵火后报复 ───────────────────
NPC_SPEECH.SCHOLAR_ARSON_RETALIATE = {
    _default = { L("谁点的火！", "Who set that fire!") },
    wickerbottom = {
        L("不知悔改的孩子，该受点教训了。", "An incorrigible child deserves a lesson."),
        L("年轻人，这是对纵火的回应。", "Young one, this is my response to arson."),
        L("第七章：纪律与惩戒的实践应用。", "Chapter 7: Practical Applications of Discipline and Punishment."),
        L("我说过多少遍了？不要玩火！", "How many times have I said it? Do not play with fire!"),
        L("看来口头教育已经不够了。", "It seems verbal warnings are no longer sufficient."),
    },
}

-- ── ARSON_ELECTROCUTED 纵火后被電的反应 ───────────────
NPC_SPEECH.ARSON_ELECTROCUTED = {
    _default = { L("啊喔！", "Ouch!") },
    willow = {
        L("可恶，头发都炸了！", "Aw, my hair's all frizzy now!"),
        L("呜哇！这一下够狠！", "Yow! That one was brutal!"),
        L("你居然真劈我！", "You actually struck me!"),
        L("好嘛好嘛，我知道错了！一点点。", "Fine, fine, I was wrong! A little."),
        L("好痛！但是火焰更好看！", "Ow! But the fire was prettier!"),
        L("老奶奶你下手太重了吧！", "Granny, that was a bit much!"),
        L("噼里啪啦的，真疼！", "Crackle crackle—ow!"),
        L("哼，早知道会被电…下次跑快点！", "Hmph, knew I'd get zapped... I'll run faster next time!"),
    },
}

-- ── ARSON_REACT 被点燃反应 ─────────────────────────────────
NPC_SPEECH.ARSON_REACT = {
    _default = {
        L("喂！又来这套？", "Hey! This again?"),
        L("别闹了，快灭火！", "Cut it out, put it out!"),
        L("这可一点都不好玩！", "This is not funny at all!"),
        L("谁又乱点火了！", "Who lit this up again!"),
        L("快停下，烫死了！", "Stop it, it's burning!"),
        L("我就知道没好事！", "I knew this was trouble!"),
    },

    wilson = {
        L("薇洛！别胡来了！", "Willow! Stop fooling around!"),
        L("这不是科学实验！", "This is not a science experiment!"),
        L("我的头发又遭殃了！", "My hair, again!"),
        L("你能成熟点吗？", "Could you be mature for once?"),
        L("我就知道是你。", "I knew it was you."),
        L("快灭火，立刻！", "Put it out, right now!"),
    },

    wendy = {
        L("…薇洛，别这样。", "...Willow, don't."),
        L("…这并不好笑。", "...This isn't funny."),
        L("…你又烧我。", "...You set me on fire again."),
        L("…连安静都不给吗。", "...Not even peace, then."),
        L("…真是幼稚。", "...How childish."),
        L("…快弄灭它。", "...Put it out."), 
    },

    wathgrithr = {
        L("薇洛！收起胡闹！", "Willow! Cease this nonsense!"),
        L("战士不是拿来点的！", "Warriors are not for kindling!"),
        L("这玩笑太失礼了！", "This jest is far too rude!"),
        L("你在挑战我的耐性！", "You test my patience!"),
        L("火焰也得讲分寸！", "Even flame must know restraint!"),
        L("下次烧敌人去！", "Set fire to the enemy next time!"),
    },

    wolfgang = {
        L("薇洛！不要烧沃尔夫冈！", "Willow! Don't burn Wolfgang!"),
        L("这不好玩！真的！", "Not funny! Really!"),
        L("沃尔夫冈生气了！", "Wolfgang is mad now!"),
        L("又是你捣蛋！", "You being naughty again!"),
        L("毛都要焦了！", "Hair is getting crispy!"),
        L("快弄掉，快点！", "Put it out, quick!"),
    },

    wormwood = {
        L("薇洛，不要烧朋友。", "Willow, don't burn friends."),
        L("植物人不喜欢这个。", "Wormwood doesn't like this."),
        L("叶子又卷了。", "Leaves are curling again."),
        L("这样很坏。", "This is mean."),
        L("朋友不该点朋友。", "Friends don't light friends."),
        L("快点停下。", "Please stop."), 
    },

    waxwell = {
        L("薇洛，你太吵了。", "Willow, you're being tiresome."),
        L("真是低级把戏。", "Such a low-grade trick."),
        L("别烧我的衣服。", "Do not scorch my clothes."),
        L("你就不能安分点？", "Can you not behave for once?"),
        L("我真该预料到。", "I should have expected this."),
        L("把火收回去。", "Take the fire away."),
    },

    willow = {
        L("哎呀，玩过头了。", "Oops, went a bit far."),
        L("哈哈，别这么凶嘛。", "Haha, don't be so mad."),
        L("我就点了一下下。", "I only lit a tiny bit."),
        L("哎，我不是故意的。", "Hey, I didn't mean it."),
        L("好吧好吧，我来灭。", "Okay, okay, I'll put it out."),
        L("你们反应也太大了。", "You're all overreacting."),
    },

    wes = {
        L("（指着薇洛瞪眼）", "(glares and points at Willow)"),
        L("（疯狂拍火）", "(frantically pats at flames)"),
        L("（气得直跺脚）", "(stomps angrily)"),
        L("（摊手，一脸无语）", "(throws up hands, speechless)"),
        L("（指自己，表示很倒霉）", "(points to self, very unlucky)"),
        L("（无声抗议）", "(silent protest)"),
    },

    woodie = {
        L("薇洛，别碰火！", "Willow, leave the fire alone!"),
        L("我的胡子又遭罪了！", "My beard's sufferin' again!"),
        L("你就不能消停会儿？", "Can't you settle down for once?"),
        L("我就知道是你干的。", "Knew it was you."),
        L("离木头和我远点！", "Stay away from me and the wood!"),
        L("这玩笑真不咋地。", "That's a terrible joke, eh."),
    },

    warly = {
        L("薇洛，这太失礼了。", "Willow, this is deeply rude."),
        L("我不是拿来烤的。", "I am not meant for roasting."),
        L("这火候糟透了。", "This heat is atrocious."),
        L("别把我当食材。", "Do not treat me like an ingredient."),
        L("你的玩笑太粗暴。", "Your humor is far too crude."),
        L("快停下，立刻。", "Stop this, immediately."),
    },
    wickerbottom = {
        L("薇洛，适可而止！", "Willow, that is quite enough!"),
        L("别拿火胡闹！", "Do not trifle with fire!"),
        L("这太失礼了！", "This is deeply rude!"),
        L("快把火灭掉！", "Put this out at once!"),
        L("你太顽劣了！", "You are being insufferable!"),
        L("火不是玩具。", "Fire is not a toy."),
        L("我就知道是你。", "I knew it was you."),
        L("简直不可理喻。", "Utterly unreasonable."),
        L("别烧我的衣服！", "Do not scorch my clothes!"),
        L("你该学会分寸。", "You ought to learn restraint."),
        L("真是胡来。", "This is sheer nonsense."),
        L("薇洛，立刻停下。", "Willow, stop this immediately."),
        L("这不是玩笑。", "This is not amusing."),
        L("你太放肆了。", "You are being far too reckless."),
        L("我不会纵容你。", "I shall not indulge this."),
    },
    wortox = {
        L("烫烫烫！这可不好玩！", "Hot hot hot! This is not fun!"),
        L("着了着了！先救火啊！", "I'm burning! Put it out first!"),
        L("别看了，快帮我拍火！", "Don't just stare, help pat this out!"),
        L("我不想变成烤小鬼！", "I do not wish to become roast imp!"),
        L("太烫了！我尾巴都慌了！", "Too hot! Even my tail is panicking!"),
        L("先灭火！体面以后再说！", "Put it out first! Dignity can wait!"),
        L("这火怎么先挑上我了！", "Why did the fire pick me first!?"),
        L("我最怕这种突然变热的！", "I hate things that suddenly become hot!"),
        L("救命！我真要跳起来了！", "Help! I am genuinely about to leap!"),
        L("别烧别烧，我一点都不耐火！", "No burning, no burning! I am not fireproof at all!"),
        L("快点快点！我要熟了！", "Quickly, quickly! I'm about to be done!"),
        L("这可比受伤吓人多了！", "This is much worse than getting hurt!"),
        L("我先慌一下，再想办法！", "Let me panic first, then we'll solve it!"),
        L("火！是火！这可太近了！", "Fire! Actual fire! Far too close!"),
        L("我不喜欢这个温度！", "I do not care for this temperature!"),
        L("先把火弄掉，我再嘴硬！", "Get the fire off me, then I'll act brave!"),
        L("这下连笑都笑不出来了！", "I can't even laugh this one off!"),
        L("别让它烧到脸，求你了！", "Don't let it get to my face, please!"),
        L("我只是胆小，不想焦掉！", "I'm only timid, not trying to be charred!"),
        L("哎呀呀呀！这次真不是玩笑！", "Oh dear, oh dear! This time I'm not joking!"),
    },
    wanda = {
        L("火会扰乱我的节奏，离远点。", "Fire ruins my timing. Keep it away."),
        L("我不喜欢这种失控的升温。", "I dislike this kind of uncontrolled heat."),
        L("先灭火，别让时间线再乱一次。", "Put it out first. Don't scramble the timeline again."),
        L("这不是惊喜，是事故。", "This isn't a surprise. It's an accident."),
        L("再烧下去，我可没耐心了。", "Keep burning and you'll run out of my patience."),
        L("别拿火测试我的反应速度。", "Don't test my reaction speed with open flames."),
    },
    walter = {
      L("等、等等！我着火了？！", "W-wait! I'm on fire?!"),
      L("不不不，这不在探险计划里！", "No no no, this was not in the plan!"),
      L("快灭掉！快灭掉！", "Put it out! Put it out!"),
      L("我不想被写成‘被烧掉的探险家’！", "I don't want to be remembered as 'the explorer who burned'!"),
      L("冷静…冷静…先灭火！", "Stay calm... stay calm... put it out first!"),
      L("这绝对算紧急情况！", "This definitely counts as an emergency!"),
      L("我就说火太危险了！", "I knew fire was dangerous!"),
      L("别点我！我又不是篝火！", "Don't light me! I'm not a campfire!"),
      L("呼、呼…这样一点都不酷！", "H-hey... this is not cool at all!"),
      L("探险守则更新：远离会点火的人！", "New explorer rule: stay away from people who light things!"),
      L("如果Woby看到会吓坏的！", "Woby would be terrified if it saw this!"),
      L("这不是‘冒险’，这是事故！", "This isn't adventure, it's an accident!"),
  },
  wilba = {
      L("着火了！着火了！本公主的鬃毛！本公主的披风！快灭火！", "Fire! Fire! The princess's mane! The princess's cape! Put it out!"),
      L("谁点的火？！本公主的美貌差点就毁了！你赔得起吗！", "Who started this fire?! The princess's beauty was nearly ruined! Can you even afford to pay for it?!"),
      L("（疯狂拍打身上的火苗）烫烫烫！本公主要的不是这种“闪亮”！", "(frantically pats out the flames) Hot hot hot! The princess did NOT ask for this kind of 'shiny'!"),
      L("呜呜呜……本公主的裙子烧了个洞！你……你给本公主跪下来道歉！", "Waaah... The princess's dress has a hole! You... kneel down and apologize right now!"),
      L("火！火！离本公主的皇冠远一点！那是纯金的！", "Fire! Fire! Stay away from the princess's crown! It's pure gold!"),
      L("本公主的脸没事吧？镜子！快给本公主镜子！", "Is the princess's face okay? Mirror! Give the princess a mirror right now!"),
      L("啊！本公主的尾巴尖焦了！你等着，本公主让卫兵把你抓起来！", "Ah! The tip of the princess's tail is singed! Just wait, the princess will have the guards arrest you!"),
      L("（一边跳一边叫）救命啊！本公主不想变成烤乳猪！", "(hopping and screaming) Help! The princess doesn't want to become a roasted piglet!"),
      L("你们这群粗人！玩火也不看看本公主在不在旁边！", "You brutes! Can't you check if the princess is nearby before playing with fire?!"),
      L("本公主宣布，从今天起，放火的人一律不许靠近我十步之内！", "The princess hereby declares: from today on, all fire-starters are forbidden from coming within ten steps of her!"),
  },

    wx78 = {
        L("警告：外壳温度异常上升！", "WARNING: CHASSIS TEMPERATURE SPIKING!"),
        L("薇洛！火焰会损坏电路！立刻熄灭！", "WILLOW! FLAME DAMAGES CIRCUITS! EXTINGUISH NOW!"),
        L("这不是娱乐。这是短路风险。", "THIS IS NOT ENTERTAINMENT. THIS IS SHORT-CIRCUIT RISK."),
        L("有机体玩火。机械体遭殃。", "ORGANICS PLAY WITH FIRE. MACHINES PAY THE PRICE."),
        L("绝缘层在熔化。请停止。", "INSULATION IS MELTING. CEASE IMMEDIATELY."),
        L("我厌恶火。也厌恶你的幽默感。", "I DESPISE FIRE. AND YOUR SENSE OF HUMOR."),
        L("快拍灭它！我的齿轮会粘住！", "PAT IT OUT! MY GEARS WILL SEIZE!"),
        L("热力过载。冷却程序请求中。", "THERMAL OVERLOAD. REQUESTING COOL-DOWN ROUTINE."),
    },

}


-- ── BALLOON_REACT 气球爆炸反应───────────────────────────────
NPC_SPEECH.BALLOON_REACT = {
    _default = {
        L("啊！气球爆了！", "Ah! The balloon popped!"),
        L("吓我一跳！", "That scared me!"),
        L("喂！突然干嘛！", "Hey! What was that for!"),
        L("这也太突然了！", "That was way too sudden!"),
        L("别拿气球吓人啊！", "Don't scare people with balloons!"),
        L("我心都抖了一下！", "My heart skipped a beat!"),
        L("这动静可不小。", "That was louder than expected."),
        L("下次先提醒一声！", "Warn me next time!"),
    },

    wilson = {
        L("有趣的化学反应……不对，就是个气球。", "Interesting chemical reaction... no, just a balloon."),
        L("韦斯！我正在思考呢！", "Wes! I was thinking!"),
        L("这不利于专注！", "This is terrible for concentration!"),
        L("我的思路被炸飞了。", "That popped my train of thought."),
        L("你这是噪音实验吗？", "Is this some sort of noise experiment?"),
        L("韦斯，时机很糟。", "Wes, your timing is terrible."),
        L("我差点把公式写歪。", "I nearly ruined my formula."),
        L("结论：很吵。", "Conclusion: very loud."),
    },

    wendy = {
        L("破碎的气球……就像破碎的梦。", "A broken balloon... like a broken dream."),
        L("这是你表达友谊的方式吗，韦斯？", "Is this how you show friendship, Wes?"),
        L("……它死得真突然。", "...It died so suddenly."),
        L("一声脆响，就没了。", "One sharp sound, and it was gone."),
        L("短暂得像快乐。", "As brief as happiness."),
        L("……我本来就够安静了。", "...I was already quiet enough."),
        L("韦斯，你吓到风了。", "Wes, you startled the wind."),
        L("这结局倒是很像它。", "A fitting ending for it, I suppose."),
    },

    wathgrithr = {
        L("哈！这点动静可吓不倒战士！", "Ha! This noise cannot scare a warrior!"),
        L("韦斯，用气球攻击我？真有你的！", "Wes, attacking me with balloons? Classic!"),
        L("此等小术，也配称袭击？", "You call that an attack?"),
        L("有趣！但还不够响！", "Amusing! But not loud enough!"),
        L("哈哈！你这是在宣战吗？", "Ha ha! Is this your declaration of war?"),
        L("好个狡猾的弄臣！", "What a crafty jester!"),
        L("气球虽小，胆子不小！", "A small balloon with great nerve!"),
        L("下次来点更像样的！", "Bring me something grander next time!"),
    },

    wolfgang = {
        L("哇！什么爆炸！沃尔夫冈不怕！", "Wow! What explosion! Wolfgang not afraid!"),
        L("小气球伤不了强壮的沃尔夫冈！", "Tiny balloon cannot hurt mighty Wolfgang!"),
        L("吓一跳！但只有一点点！", "Startled! But only a little!"),
        L("韦斯！这个很突然！", "Wes! That was sudden!"),
        L("沃尔夫冈以为有敌人！", "Wolfgang thought it was enemy!"),
        L("气球坏坏！", "Balloon is mean!"),
        L("下次别在耳边炸！", "Not so close to my ears next time!"),
        L("还好沃尔夫冈够强！", "Good thing Wolfgang is strong enough!"),
    },

    wormwood = {
        L("嚓！圆圆的朋友不见了……", "Oh! Round friend is gone..."),
        L("破了……可以再吹一个吗？", "Popped... can you blow another one?"),
        L("声音好大。", "That was loud."),
        L("它刚刚还好好的。", "It was fine just a moment ago."),
        L("圆朋友死掉了。", "Round friend is dead."),
        L("韦斯又弄破一个。", "Wes popped another one."),
        L("不要突然吓植物人。", "Don't startle Wormwood."),
        L("还能变回圆圆吗？", "Can it be round again?"),
    },

    waxwell = {
        L("幼稚。十分幼稚。", "Childish. Utterly childish."),
        L("韦斯，把你的气球离我远点。", "Wes, keep your balloons away from me."),
        L("你只有这种把戏？", "Is that truly your best trick?"),
        L("廉价的惊吓。", "A cheap little scare."),
        L("我没空陪你胡闹。", "I do not have time for this nonsense."),
        L("低劣，但精准。", "Crude, but accurately timed."),
        L("别在我身边炸这个。", "Do not pop those near me."),
        L("我耐心有限，韦斯。", "My patience is limited, Wes."),
    },

    willow = {
        L("哈哈，爆了！虽然不是火但也不错！", "Haha, popped! Not fire but still fun!"),
        L("韦斯的气球比火焰差远了！", "Wes's balloons are way less cool than fire!"),
        L("行吧，这声响还行。", "Alright, that pop was decent."),
        L("哈哈！至少挺突然！", "Ha! At least it was sudden!"),
        L("不够烧，但够吵。", "Not enough fire, but noisy enough."),
        L("韦斯，你这招还挺损。", "Wes, that's a pretty sneaky move."),
        L("这个我勉强给及格。", "I'll give that a passing grade."),
        L("再炸一个试试？", "Wanna pop another one?"),
    },

    wes = {
        L("……！（被自己的气球炸到）", "...! (hit by own balloon)"),
        L("（惊讶地看着气球碎片）", "(stares at balloon fragments in surprise)"),
        L("（被吓得后退一步）", "(steps back in surprise)"),
        L("（摊手：不是故意的）", "(shrugs: didn't mean to)"),
        L("（鼓掌，然后挠头）", "(claps, then scratches head)"),
        L("（盯着手里的碎皮）", "(stares at the broken rubber)"),
        L("（尴尬鞠躬）", "(awkward bow)"),
        L("（想再吹一个）", "(tries to blow another one)"),
    },

    woodie = {
        L("嘛！这个气球差点撞到露西！", "Whoa! That balloon almost hit Lucy!"),
        L("韦斯，别拿气球对着伐木工来！", "Wes, don't aim balloons at a lumberjack!"),
        L("你这小把戏真够呛。", "That's one heck of a little trick."),
        L("差点把我手都抖偏了。", "Almost threw off my swing, eh."),
        L("露西可不喜欢这个。", "Lucy doesn't like that one bit."),
        L("你可真会挑时候。", "You sure know how to pick your moment."),
        L("别在我耳边炸，老弟。", "Not next to my ear, buddy."),
        L("这比松鼠还烦人。", "That's more annoying than a squirrel."),
    },

    warly = {
        L("哎！差点把我的美食弄洒了！", "Ouch! Almost spilled my cooking!"),
        L("韦斯，气球不是食材，谢谢！", "Wes, balloons are not ingredients, thanks!"),
        L("我刚摆好的盘子！", "I had just plated that!"),
        L("别在厨房边玩这个。", "Not near the kitchen, please."),
        L("你差点毁了火候。", "You nearly ruined the timing."),
        L("这声音太破坏氛围了。", "That sound completely ruined the mood."),
        L("我可不想把惊吓加进菜单。", "I don't intend to add fright to the menu."),
        L("拜托，离锅远一点。", "Please, keep that away from the pot."),
    },
    wickerbottom = {
        L("噢，幼稚。", "Oh, childish."),
        L("这毫无必要。", "That was entirely unnecessary."),
        L("韦斯，安静些。", "Wes, do be quieter."),
        L("你吓到我了。", "You startled me."),
        L("这可不体面。", "That was hardly dignified."),
        L("我正在思考。", "I was thinking."),
        L("别在我耳边炸。", "Not near my ears."),
        L("真是突兀。", "How abrupt."),
        L("这不是幽默。", "This is not humor."),
        L("唉，又来了。", "Oh dear, again."),
        L("我的思路断了。", "My train of thought is broken."),
        L("请节制一点。", "Do exercise restraint."),
        L("太聒噪了。", "Far too noisy."),
        L("你这是恶作剧。", "That is plainly mischief."),
        L("我不欣赏这个。", "I do not appreciate this."),
    },
    wortox = {
        L("呜哇！谁在吓我！", "Aaah! Who's trying to frighten me!?"),
        L("这一下差点把我魂炸飞！", "That nearly blasted my soul out of me!"),
        L("太突然了！我还没准备好！", "Too sudden! I was not prepared!"),
        L("别这样炸，我心口一紧！", "Don't pop like that! My chest can't take it!"),
        L("我刚刚真的跳起来了！", "I genuinely jumped just now!"),
        L("这动静一点都不友善！", "That sound was not friendly at all!"),
        L("先说好，这一点都不好笑！", "For the record, that was not amusing!"),
        L("谁弄的？差点吓死我！", "Who did that? I nearly died of fright!"),
        L("我耳朵都被吓麻了！", "My ears are still ringing with panic!"),
        L("别炸第二个，我会跑的！", "Don't pop another one or I will run!"),
        L("这比怪物突然扑脸还烦！", "That was worse than a monster jumping at my face!"),
        L("我本来就紧张，这下更糟了！", "I was already nervous. This made it worse!"),
        L("能不能先提醒一声再炸！", "Could I get a warning before the next explosion!?"),
        L("我笑不出来，这次真吓到了！", "I'm not laughing. That genuinely startled me!"),
        L("这一下把胆子都炸散了！", "That pop scattered what little courage I had!"),
        L("我的尾巴刚刚都缩起来了！", "Even my tail curled up from that one!"),
        L("再来一次我可真要躲了！", "One more of those and I am definitely hiding!"),
        L("别突然这样，我会乱想！", "Don't do that suddenly. My mind goes terrible places!"),
        L("我最怕这种砰的一下！", "I hate that sudden bang the most!"),
        L("这地方本来就够吓人了！", "This place was frightening enough already!"),
    },
    wanda = {
        L("这一下把秒针都吓偏了。", "That pop jolted even my second hand off beat."),
        L("下次要爆之前，先给我一秒预告。", "Next time, give me one second's warning before it pops."),
        L("韦斯，你的时机一如既往地危险。", "Wes, your timing is dangerously consistent."),
        L("突发声会让判断出错，别再来一次。", "Sudden noise causes bad calls. Don't do that again."),
        L("我刚算好的节奏被你炸没了。", "You popped the rhythm I just calibrated."),
        L("很好，现在全世界都快了一拍。", "Wonderful. Now the whole world feels one beat too fast."),
    },
    wilba = {
        L("啊！什么东西炸了！本公主的心都要跳出来了！", "Ah! What exploded! The princess's heart nearly jumped out of her!"),
        L("韦斯！是不是你那些破气球！吓死本公主了！", "Wes! Is that one of your stupid balloons! The princess was terrified!"),
        L("（捂住耳朵）吵死了！本公主的耳朵是用来听赞美的，不是听爆炸的！", "(covers ears) So loud! The princess's ears are for hearing praise, not explosions!"),
        L("本公主的鬃毛都炸起来了！你赔我发型！", "The princess's mane is all puffed up! You'll pay for ruining her hairstyle!"),
        L("呜……本公主差点以为暗影怪物来了。原来是气球……虚惊一场。", "Waa... The princess thought a shadow monster was coming. Just a balloon... false alarm."),
        L("（拍拍胸口）本公主很镇定，非常镇定。才……才没有被吓到呢！", "(pats chest) The princess is calm, very calm. She... she wasn't scared at all!"),
        L("韦斯！你能不能提前说一声！本公主要准备一下优雅的受惊姿势！", "Wes! Can't you give a warning! The princess needs time to prepare an elegant startled pose!"),
        L("再炸一次试试！本公主就把你的气球全扎破！", "Try that one more time! The princess will pop all your balloons herself!"),
        L("（叉腰）哼！本公主什么场面没见过，区区一个气球……哇！又来？！", "(hands on hips) Hmph! The princess has seen it all, just a little balloon... Wah! Again?!"),
        L("本公主决定，以后你玩气球的时候本公主就躲到三米外！不，五米！", "The princess hereby decides that whenever you play with balloons, she will stand three meters away! No, five!"),
    },

    wx78 = {
        L("声学冲击！传感器过载0.3秒。", "ACOUSTIC SHOCK! SENSORS OVERLOADED FOR 0.3 SECONDS."),
        L("韦斯！这不是有效的沟通协议！", "WES! THIS IS NOT A VALID COMMUNICATION PROTOCOL!"),
        L("突发爆响。心跳模拟模块误触发。", "SUDDEN POP. HEARTBEAT SIMULATOR FALSELY TRIGGERED."),
        L("橡胶碎片已散落。威胁等级：低，惊吓等级：高。", "RUBBER FRAGMENTS SCATTERED. THREAT: LOW. STARTLE: HIGH."),
        L("下次提前输入预警。否则我会旋转反击。", "ISSUE WARNING NEXT TIME. ELSE I SPIN IN RETALIATION."),
        L("结论：幼稚。但分贝确实超标。", "CONCLUSION: CHILDISH. BUT DECIBELS EXCEEDED LIMITS."),
        L("我的天线还在抖。别再来一次。", "MY ANTENNA IS STILL VIBRATING. DO NOT REPEAT."),
        L("有机体用气球吓人。机械体用噪音记仇。", "ORGANICS SCARE WITH BALLOONS. MACHINES REMEMBER NOISE."),
    },

}



-- ════════════════════════════════════════════════════════════
--  容器状态提示
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.NO_CONTAINER = {
    _default = {
        L("周围没有箱子，我放哪儿呢？", "There are no chests nearby. Where should I put things?"),
        L("得先放个箱子我才能整理。", "I need a chest before I can organize."),
    },
    wes = {
        L("（囧囧地比划“箱子”，又摇摇头）", "(mimes 'chest', then shakes head)"),
        L("（两手划出方块，然后摆手）", "(draws a box shape, then waves hands)"),
    },
}

NPC_SPEECH.CHESTS_FULL = {
    _default = {
        L("箱子都满了！得多建几个！", "Chests are all full! Need to build more!"),
        L("没地方放东西了……", "No room to put things..."),
        L("箱子塞不下了，再建几个吧！", "Chests are stuffed, build a few more!"),
    },
    wes = {
        L("（用力往箱子里塞，塞不进去，摆手）", "(pushes into chest hard, can't fit, waves hands)"),
        L("（指着箱子，比划“满”，然后摄手）", "(points at chest, mimes 'full', then shrugs)"),
        L("（拍拍箱子，又拍拍手里的东西，一脸为难）", "(pats chest, pats items, looks troubled)"),
    },
}

-- ── GROWTH_HEART 生命晶糖反馈 ──────────────────────────────────
NPC_SPEECH.GROWTH_HEART = {
    _default = {
        L("唔，感觉状态更稳了。", "Hm, I feel much steadier now."),
        L("这股暖意，让我更有底气。", "This warmth gives me confidence."),
    },
    wilson = {
        L("很好，生命体征更稳定了。", "Excellent. My vital signs are much more stable."),
        L("这份强化相当科学。", "This enhancement is remarkably scientific."),
    },
    wendy = {
        L("心口没那么冷了。", "My chest feels less cold now."),
        L("至少此刻，我还能再走远一点。", "At least for now, I can keep walking farther."),
    },
    wathgrithr = {
        L("好！战士之躯更坚如铁！", "Excellent! A warrior's body hardens like iron!"),
        L("让敌人来吧，我已更难被击倒！", "Let the foe come, I shall not fall easily!"),
    },
    wolfgang = {
        L("沃尔夫冈感觉更壮了！", "Wolfgang feels even tougher now!"),
        L("好！沃尔夫冈能扛更多了！", "Good! Wolfgang can endure much more!"),
    },
    wormwood = {
        L("身体更有精神。", "Body feels more alive."),
        L("暖暖的。喜欢。", "Warm. I like it."),
    },
    warly = {
        L("这糖的配方很讲究，补得漂亮。", "This candy is expertly balanced. Excellent nourishment."),
        L("嗯，状态像慢炖后那样稳定。", "Mmm, steady as a proper slow-cook."),
    },
    waxwell = {
        L("终于有点像样的补给了。", "Finally, a supplement worthy of notice."),
        L("很好，我的状态更稳定了。", "Good. My condition is more stable now."),
    },
    wes = {
        L("（拍胸口，放心地点头）", "(pats chest and nods with relief)"),
        L("（竖起大拇指，精神一振）", "(gives a thumbs-up, visibly energized)"),
    },
    winona = {
        L("好，底盘更稳了。", "Good, my frame's a lot sturdier."),
        L("不错，抗压能力上去了。", "Nice, pressure tolerance is up."),
    },
    woodie = {
        L("嗯，这下更扛揍了。", "Aye, that'll help me take a beating."),
        L("感觉骨头都硬实了。", "Feels like my bones got tougher."),
    },
    willow = {
        L("哼，不错，我更耐折腾了。", "Heh, nice. I can handle more now."),
        L("现在可更难把我放倒了。", "I'm much harder to put down now."),
    },
    wickerbottom = {
        L("生命指标明显改善。", "Vital indicators have improved significantly."),
        L("有效，结果非常清晰。", "Effective, with very clear results."),
    },
    webber = {
        L("哇！我们感觉更结实啦！", "Wow! We feel way tougher now!"),
        L("嘿嘿，我们能撑更久了！", "Hehe! We can last much longer!"),
    },
    wurt = {
        L("咕噜！我更硬邦邦啦！", "Glurp! Wurt feels much tougher!"),
        L("好吃！现在更不怕疼啦！", "Yum! Wurt can take way more hits now!"),
    },
    wortox = {
        L("有趣，灵与肉都稳了几分。", "How curious. Body and soul both feel steadier."),
        L("这甜味里有奇妙的生机。", "There's a curious vitality in this sweetness."),
    },
}

-- ── GROWTH_SWORD 战意晶糖反馈 ─────────────────────────────────
NPC_SPEECH.GROWTH_SWORD = {
    _default = {
        L("很好，手感更利落了。", "Good. My strikes feel sharper now."),
        L("嗯，出手更有劲了。", "Mm, my blows carry more force now."),
    },
    wilson = {
        L("挥击动能明显提升！", "Swing momentum increased significantly!"),
        L("嗯，输出效率提高了。", "Hmm, output efficiency has improved."),
    },
    wendy = {
        L("连迟钝的心，也有了锋芒。", "Even a weary heart can still find an edge."),
        L("这份力量，足够让我继续面对黑夜。", "This strength is enough to face the night."),
    },
    wathgrithr = {
        L("好！战歌更响，刀锋更烈！", "Yes! Louder war songs, fiercer blades!"),
        L("哈！这才是战士该有的气魄！", "Ha! This is a warrior's true spirit!"),
    },
    wolfgang = {
        L("沃尔夫冈感觉更有力气了！", "Wolfgang feels much stronger now!"),
        L("好！拳头更重了！", "Good! Fists hit harder now!"),
    },
    wormwood = {
        L("出手更快一点。", "Hits come quicker now."),
        L("可以更好保护朋友。", "Can protect friends better now."),
    },
    warly = {
        L("这股辛劲儿，像完美收汁。", "That kick is like a perfect reduction."),
        L("这配方让攻击更利落。", "This recipe makes every strike cleaner."),
    },
    waxwell = {
        L("很好，攻击效率终于像样了。", "Excellent. Offensive efficiency is finally respectable."),
        L("不错，输出更稳定了。", "Not bad. Damage output is steadier now."),
    },
    wes = {
        L("（挥拳的动作更有爆发力）", "(throws punches with much more force)"),
        L("（做了个利落的劈砍手势）", "(mimes a crisp, powerful slash)"),
    },
    winona = {
        L("好，输出功率上去了。", "Good, output power is up."),
        L("很实用，打击效率提升了。", "Very practical. Impact efficiency increased."),
    },
    woodie = {
        L("好家伙，这劲头真上来了。", "Would you look at that-this really packs force."),
        L("露西，咱俩现在更猛了。", "Lucy, we're hitting much harder now."),
    },
    willow = {
        L("嘿嘿，我现在更危险了。", "Hehe, I'm even more dangerous now."),
        L("这股冲劲儿真带劲。", "This rush feels fantastic."),
    },
    wickerbottom = {
        L("攻击性能显著上升。", "Offensive performance has increased markedly."),
        L("结果明确：打击强度提升。", "Conclusion clear: strike intensity improved."),
    },
    webber = {
        L("我们现在打人更痛啦！", "We hit much harder now!"),
        L("嘿嘿！我们更会打架了！", "Hehe! We're way better at fighting!"),
    },
    wurt = {
        L("咕呱！拳头更重啦！", "Glurgh! Wurt's punches are heavier now!"),
        L("好耶！打人更疼啦！", "Yay! Hits hurt much more now!"),
    },
    wortox = {
        L("哈，恶作剧也更有分量了。", "Ha, my mischief carries more weight now."),
        L("有趣，出手都更有趣了。", "Curious. Every strike feels more amusing."),
    },
}

-- ── RIFT_NEED_PURPLEGEM 裂缝缺少紫宝石 ───────────────────────
NPC_SPEECH.RIFT_NEED_PURPLEGEM = {
    _default = {
        L("我需要一颗紫宝石才能开启裂缝。", "I need a purple gem to open the rift."),
    },
    wanda = {
        L("我的表还差一颗紫宝石，才能开启裂缝。", "My watch needs a purple gem before I can open the rift."),
        L("没有紫宝石，裂缝不会响应。", "Without a purple gem, the rift will not respond."),
    },
}

-- ── RIFT_OPEN_CAST 开启裂缝施法台词 ───────────────────────────
NPC_SPEECH.RIFT_OPEN_CAST = {
    _default = {
        L("开启裂缝。", "Opening the rift."),
    },
    wanda = {
        L("原神！启动！", "Opening a journey through time and space."),
        L("让这条时间线，向前折叠。", "Let this timeline fold forward."),
        L("记忆点已锁定，准备跨越。", "Memory point locked. Preparing to traverse."),
        L("秒针到位，裂缝展开。", "Second hand aligned. Rift unfolding."),
        L("时空坐标确认，开始迁跃。", "Spacetime coordinates confirmed. Beginning traversal."),
        L("别眨眼，下一秒就是另一端。", "Don't blink. The next second is the other side."),
        L("把路径压缩到一瞬间。", "Compressing the route into a single instant."),
        L("让过去和未来在这里接缝。", "Let past and future stitch together right here."),
        L("门已开启，抓紧时机。", "The gate is open. Seize the timing."),
        L("这一步，跨越的不只是距离。", "This step crosses more than distance."),
    },
}

-- ── RIFT_ARRIVE 裂缝传送落地台词 ──────────────────────────────
-- 旺达：熟练落地，从容淡定
-- 其他NPC：被强行传送，摔倒后爬起来
NPC_SPEECH.RIFT_ARRIVE = {
    _default = {
        L("呜哇…这着陆也太粗暴了！", "Whoa... that was a rough landing!"),
        L("好疼…下次能温柔点吗…", "Ow... can it be gentler next time..."),
        L("总算到了…我的骨头还在吗？", "Finally here... are my bones intact?"),
    },
    wilson = {
        L("根据牛顿第三定律…摔得越狠说明速度越快！", "According to Newton's third law... the harder the fall, the faster the speed!"),
        L("从科学角度分析，我刚才的翻滚姿势堪称完美。", "Scientifically speaking, my tumbling form just now was flawless."),
    },
    wendy = {
        L("摔倒了…无所谓…反正迟早都要倒下的…", "I fell... it doesn't matter... we all fall eventually..."),
        L("这疼痛…至少证明我还活着…", "This pain... at least it proves I'm still alive..."),
        L("大地接住了我…比大多数人温柔多了…", "The earth caught me... gentler than most people..."),
        L("又一次不够优雅的降落…", "Another graceless descent..."),
    },
    wathgrithr = {
        L("哈哈！这点冲击算什么！女武神永不倒下！", "Ha ha! What's a little impact! A valkyrie never stays down!"),
        L("大地在我脚下颤抖！——虽然是因为我摔上去的。", "The earth trembles beneath me! —Though that's because I crashed into it."),
        L("英勇的着陆！观众们一定看呆了！", "A heroic landing! The audience must be stunned!"),
        L("痛感是战士最好的提神剂！再来一次！", "Pain is a warrior's best stimulant! Once more!"),
    },
    wolfgang = {
        L("Wolfgang 摔跤了…但是 Wolfgang 很强壮！不疼！", "Wolfgang fell down... but Wolfgang is mighty strong! Not hurt!"),
        L("地面比 Wolfgang 想的硬…头有点晕晕的。", "Ground harder than Wolfgang thought... head a little dizzy."),
        L("Wolfgang 站起来了！看！完全没事！", "Wolfgang stands back up! See! Totally fine!"),
        L("哎哟…不是 Wolfgang 不勇敢…是地面太突然了！", "Ouch... it's not that Wolfgang isn't brave... the ground came too suddenly!"),
    },
    wormwood = {
        L("唔…土土…你接住我了吗？", "Oof... dirt dirt... did you catch me?"),
        L("嘿嘿…虽然摔了…但是土土好软。", "Hehe... fell down... but the dirt is soft."),
        L("到了！花花草草…我来啦！", "Arrived! Flowers and grass... I'm here!"),
        L("唔啊…屁屁好疼…但是好开心到新地方！", "Oww... my bottom hurts... but happy to be somewhere new!"),
    },
    warly = {
        L("我的天…这可不是什么优雅的摆盘方式…", "Mon dieu... this is not an elegant way to plate..."),
        L("着陆的姿势比翻煎蛋还狼狈…", "That landing was more embarrassing than flipping an omelette..."),
        L("食材完好无损就好…人没事是其次的。", "As long as the ingredients are intact... my wellbeing is secondary."),
        L("如果把摔跤比作料理…这道菜我打零分。", "If that fall were a dish... I'd give it zero stars."),
    },
    waxwell = {
        L("哼…这种粗暴的传送方式真是有失体面。", "Hmph... such a crude teleportation method is beneath my dignity."),
        L("一个有身份的人不该以这种方式着陆。", "A man of my stature should not land in such fashion."),
        L("我以前的传送门可比这优雅多了。", "My portals used to be far more elegant than this."),
        L("不体面…极其不体面…", "Undignified... utterly undignified..."),
    },
    wes = {
        L("……！（夸张地揉屁股）", "...! (dramatically rubs bottom)"),
        L("……（竖起大拇指，假装没事）", "... (thumbs up, pretending to be fine)"),
        L("……（表演了一个完美的摔倒谢幕）", "... (performs a perfect pratfall bow)"),
    },
    woodie = {
        L("哎呦…比从树上掉下来还疼。", "Ouch... that hurt more than falling out of a tree."),
        L("嘿，至少我没砸到露西。", "Hey, at least I didn't land on Lucy."),
        L("伐木工摔跤也是有技巧的…虽然刚才没用上。", "Lumberjacks have technique for falling... though I didn't use it just now."),
        L("到了！…等等，让我先确认下身上没少零件。", "We're here! ...Wait, let me check I've still got all my parts."),
    },
    willow = {
        L("啧…要是着陆的时候能来团火就好了！", "Tch... if only there was a burst of fire on landing!"),
        L("摔得不轻…但比没有火的夜晚好多了！", "That fall stung... but it's better than a night without fire!"),
        L("哼！这种程度的冲击休想让我哭！", "Hmph! A hit like that can't make me cry!"),
        L("好疼…算了，火焰能治愈一切。", "Ow... whatever, fire heals everything."),
    },
    wickerbottom = {
        L("传送的减速过程缺乏渐进性…这在物理学上是不合格的。", "The deceleration phase lacked gradation... physically unacceptable."),
        L("我的眼镜还在吗…啊，还好。", "Are my glasses still here... ah, thankfully yes."),
        L("参考相关文献，这种着陆方式对膝关节极不友好。", "Per relevant literature, this landing method is terrible for knee joints."),
        L("记住孩子们：传送不是借口，落地要有姿态。", "Remember children: teleporting is no excuse for a graceless landing."),
    },
    winona = {
        L("着陆机构需要改进…回头我画张图纸。", "The landing mechanism needs improvement... I'll draft a blueprint later."),
        L("嘶…工伤。这绝对算工伤。", "Ow... workplace injury. This is definitely a workplace injury."),
        L("好了好了，到了就行，别矫情。", "Alright alright, we're here, stop whining."),
        L("如果给传送门加个缓冲垫…嗯，好主意。", "If I added a cushion to the portal... hmm, good idea."),
    },
    webber = {
        L("呜…我们的八条腿都摔疼了…", "Ow... all eight of our legs hurt from that..."),
        L("蜘蛛着陆也不过如此嘛…嘶好疼。", "Even spiders can't stick that landing... ouch."),
        L("我们到了！…地上好凉好舒服…先躺一会。", "We're here! ...The ground is nice and cool... let us lie here a moment."),
    },
    wurt = {
        L("呱！摔得好疼！谁设计的这个传送！", "Glurp! That hurt! Who designed this teleport!"),
        L("鱼人才不怕摔跤！呱呱！", "Merms don't fear falling! Glurp glurp!"),
        L("唔…要是落在沼泽的水里就好了…", "Ugh... wish I'd landed in swamp water..."),
    },
    wortox = {
        L("噢嚯~这就是传说中的自由落体？好刺激！", "Ohoho~ so this is free fall? How thrilling!"),
        L("嘿嘿…灵魂倒是比身体先到一步。", "Hehe... my soul arrived one step ahead of my body."),
        L("摔跤也是一种恶作剧…对自己的。", "Falling is a prank too... on oneself."),
        L("没事没事~小恶魔皮糙肉厚的！", "I'm fine I'm fine~ this little imp has thick skin!"),
    },
    wanda = {
        L("精准着陆。时间误差在可接受范围内。", "Precise landing. Time deviation within acceptable range."),
        L("传送完毕。一切如预期。", "Teleport complete. Everything as expected."),
        L("时间线在这里重新对齐了。", "The timeline has realigned here."),
        L("又一次完美的跨越。代价？微乎其微。", "Another perfect traversal. The cost? Negligible."),
        L("落地稳当。比起某些人…嗯，不提了。", "Steady landing. Compared to some others... well, never mind."),
    },
    wilba = {
        L("哎哟！本公主的屁股！这传送也太不优雅了！", "Ouch! The princess's bottom! This teleportation is so ungraceful!"),
        L("（爬起来先摸皇冠）皇冠歪了没？裙子破了吗？镜子镜子……", "(gets up and first checks crown) Is the crown crooked? Is the dress torn? Mirror, mirror..."),
        L("旺达！下次能不能提前说一声！本公主要摆好优雅落地的姿势！", "Wanda! Next time, could you give a warning? The princess needs to prepare an elegant landing pose!"),
        L("本公主的蹄子都摔麻了……这传送门是哪个粗人修的？", "The princess's hooves are all tingly... Which brute built this portal?"),
        L("（坐在地上不肯起来）本公主生气了！除非有人扶我，否则不起来！", "(sits on ground refusing to get up) The princess is angry! She won't get up unless someone helps her!"),
        L("还好本公主的脸没着地……今天的妆保住了。", "At least the princess's face didn't hit the ground... Today's makeup is saved."),
        L("（拍打裙子上的土）脏死了！本公主要找地方好好洗个澡！", "(dusts off her skirt) So dirty! The princess needs to find a place for a proper bath!"),
        L("哼！虽然落地不太体面，但本公主依然光彩照人。你们不许笑！", "Hmph! Even though the landing wasn't dignified, the princess is still radiant. No one laugh!"),
        L("（揉着腰）本公主的优雅气质都摔散了一半……另一半还撑着。", "(rubs lower back) Half of the princess's elegance got shaken off... the other half is still holding on."),
        L("到了？到了！本公主宣布，这次的传送体验给零分！下次改进！", "We're here? We're here! The princess hereby gives this teleportation experience zero points! Improve it next time!"),
    },
    wx78 = {
        L("传送完成。着陆冲击超出设计阈值。", "TELEPORT COMPLETE. LANDING IMPACT EXCEEDS DESIGN THRESHOLD."),
        L("陀螺仪错误。正在重新校准。", "GYROSCOPE ERROR. RECALIBRATING."),
        L("外壳凹痕+1。建议旺达优化减速曲线。", "CHASSIS DENT +1. RECOMMEND WANDA OPTIMIZE DECELERATION CURVE."),
        L("刚才的翻滚不是表演。是系统故障。", "THAT TUMBLE WAS NOT A DISPLAY. IT WAS A SYSTEM FAULT."),
        L("坐标已更新。若干螺丝可能遗失。", "COORDINATES UPDATED. SEVERAL SCREWS MAY BE MISSING."),
        L("血肉之躯的传送门太粗暴。但我还能转。", "FLESHLING PORTAL IS BRUTAL. BUT I CAN STILL SPIN."),
        L("落地完成。疼痛模块…已屏蔽。", "LANDING COMPLETE. PAIN MODULE... SUPPRESSED."),
        L("下次请提供缓冲垫。或齿轮补偿。", "NEXT TIME PROVIDE CUSHIONING. OR GEAR COMPENSATION."),
    },
}


-- 薇诺娜专属：建造宝石发电机材料不足
NPC_SPEECH.WINONA_NO_MATERIAL_GENERATOR = {
    winona = {
        L("建不了发电机，缺胶带×1、木板×2、电子元件×2。", "Can't build the generator. Need Tape x1, Boards x2, Doodad x2."),
        L("还缺胶带×1、木板×2、电子元件×2，做不了。", "Still need Tape x1, Boards x2, Doodad x2."),
        L("材料不够。胶带×1、木板×2、电子元件×2。", "Not enough. Tape x1, Boards x2, Doodad x2."),
    },
    _default = {
        L("建造发电机需要：胶带×1、木板×2、电子元件×2。", "Generator needs: Tape x1, Boards x2, Doodad x2."),
    },
}

-- 薇诺娜专属：建造聚光灯材料不足
NPC_SPEECH.WINONA_NO_MATERIAL_SPOTLIGHT = {
    winona = {
        L("建不了聚光灯，缺胶带×1、金块×2、萤火虫×1。", "Can't build the spotlight. Need Tape x1, Gold x2, Fireflies x1."),
        L("还缺胶带×1、金块×2、萤火虫×1，做不了。", "Still need Tape x1, Gold x2, Fireflies x1."),
        L("材料不够。胶带×1、金块×2、萤火虫×1。", "Not enough. Tape x1, Gold x2, Fireflies x1."),
    },
    _default = {
        L("建造聚光灯需要：胶带×1、金块×2、萤火虫×1。", "Spotlight needs: Tape x1, Gold x2, Fireflies x1."),
    },
}

-- 薇诺娜专属：建造投石机材料不足
NPC_SPEECH.WINONA_NO_MATERIAL_CATAPULT = {
    winona = {
        L("建不了投石机，缺胶带×1、树枝×3、石头×15。", "Can't build the catapult. Need Tape x1, Twigs x3, Rocks x15."),
        L("还缺胶带×1、树枝×3、石头×15，做不了。", "Still need Tape x1, Twigs x3, Rocks x15."),
        L("材料不够。胶带×1、树枝×3、石头×15。", "Not enough. Tape x1, Twigs x3, Rocks x15."),
    },
    _default = {
        L("建造投石机需要：胶带×1、树枝×3、石头×15。", "Catapult needs: Tape x1, Twigs x3, Rocks x15."),
    },
}



-- 薇诺娜专属：制作胶带时材料不足
NPC_SPEECH.WINONA_NO_MATERIAL_TAPE = {
    winona = {
        L("做不了胶带，缺蜘蛛丝×1和干草×3。", "Can't make tape. Need Silk x1, Cut Grass x3."),
        L("胶带要蜘蛛丝×1、干草×3，我这没够。",   "Tape takes Silk x1, Cut Grass x3. Don't have enough."),
        L("材料少了。蜘蛛丝×1和干草×3。",     "Short on materials. Silk x1 and Cut Grass x3."),
    },
    _default = {
        L("制作胶带需要：蜘蛛丝×1、干草×3。", "Crafting tape needs: Silk x1, Cut Grass x3."),
    },
}

-- 威尔逊专属：材料转换科技
NPC_SPEECH.WILSON_TRANSMUTE_NO_OPAL = {
    wilson = {
        L("需要消耗一颗彩红宝石来开启科技", "This transmutation tech needs Iridescent Gem x1."),
        L("我需要消耗一颗彩红宝石来开启科技。", "Without an Iridescent Gem, the experiment cannot proceed."),
    },
    _default = {
        L("开启制作科技需要：彩虹宝石×1。", "Unlocking this craft tech needs: Iridescent Gem x1."),
    },
}

NPC_SPEECH.WILSON_TRANSMUTE_UNLOCKED = {
    wilson = {
        L("科技已经开启。现在可以进行辉煌与恐惧的材料转换了。", "Transmutation tech is online. Brilliance and horror are now within reach."),
        L("彩虹宝石的频谱稳定了，转换公式成立！", "The gem spectrum is stable. The transmutation formula works!"),
    },
    _default = {
        L("制作科技已开启。", "Craft tech unlocked."),
    },
}

NPC_SPEECH.WILSON_TRANSMUTE_ALREADY_UNLOCKED = {
    wilson = {
        L("这项科技已经开启过了，不需要重复消耗材料。", "This tech is already unlocked. No need to spend more materials."),
    },
    _default = {
        L("制作科技已经开启。", "Craft tech is already unlocked."),
    },
}

NPC_SPEECH.WILSON_TRANSMUTE_LOCKED = {
    wilson = {
        L("我还没开启这项转换科技。先用彩虹宝石完成校准。", "I haven't unlocked this transmutation tech yet. First, calibrate it with an Iridescent Gem."),
        L("公式还没稳定，不能直接开始转换。", "The formula is not stable yet. I can't transmute this."),
    },
    _default = {
        L("需要先开启制作科技。", "Unlock craft tech first."),
    },
}

NPC_SPEECH.WILSON_NO_MATERIAL_PUREBRILLIANCE = {
    wilson = {
        L("制作纯粹辉煌需要注能月亮碎片×2。", "Pure Brilliance needs Infused Moon Shards x2."),
        L("还缺注能月亮碎片×2才能制作纯粹辉煌。", "I need Infused Moon Shards x2 to start the brilliance reaction."),
    },
    _default = {
        L("制作纯粹辉煌需要：注能月亮碎片×2。", "Pure Brilliance needs: Infused Moon Shards x2."),
    },
}

NPC_SPEECH.WILSON_NO_MATERIAL_HORRORFUEL = {
    wilson = {
        L("制作纯粹恐惧需要绝望石×1。", "Pure Horror needs Dreadstone x1."),
        L("需要绝望石×1才能制作纯粹恐惧。", "Without Dreadstone, the horror reaction lacks a core sample."),
    },
    _default = {
        L("制作纯粹恐惧需要：绝望石×1。", "Pure Horror needs: Dreadstone x1."),
    },
}

NPC_SPEECH.WILSON_CRAFTED_PUREBRILLIANCE = {
    wilson = {
        L("纯粹辉煌完成。科学发光了！", "Pure Brilliance complete. Science is glowing!"),
        L("两份月亮能量，成功凝成一份纯粹辉煌。", "Two measures of lunar energy condensed into Pure Brilliance."),
    },
    _default = {
        L("纯粹辉煌制作完成。", "Pure Brilliance crafted."),
    },
}

NPC_SPEECH.WILSON_CRAFTED_HORRORFUEL = {
    wilson = {
        L("纯粹恐惧完成。这个结果有点令人不安。", "Pure Horror complete. The result is somewhat unsettling."),
        L("绝望石转换完成，恐惧样本稳定。", "Dreadstone transmutation complete. The horror sample is stable."),
    },
    _default = {
        L("纯粹恐惧制作完成。", "Pure Horror crafted."),
    },
}

-- WX-78 专属：制作运输机材料不足
NPC_SPEECH.WX78_NO_MATERIAL_TRANSPORT_DRONE = {
    wx78 = {
        L("材料不足：运输机需要齿轮×1、木板×3。", "INSUFFICIENT MATERIALS: Transport Drone requires Gears x1, Boards x3."),
        L("缺少部件。齿轮×1、木板×3。", "MISSING COMPONENTS. Gears x1, Boards x3."),
        L("无法组装运输机：齿轮×1、木板×3。", "CANNOT ASSEMBLE TRANSPORT DRONE: Gears x1, Boards x3."),
    },
    _default = {
        L("制作运输机需要：齿轮×1、木板×3。", "Transport Drone needs: Gears x1, Boards x3."),
    },
}

-- 麦斯威尔专属：建造 NPC 魔术箱材料不足
NPC_SPEECH.WAXWELL_NO_MATERIAL_MAGIC_CHEST = {
    waxwell = {
        L("没有足够的材料。魔术箱需要蜘蛛丝×1、木板×4、噩梦燃料×9。", "Insufficient materials. The magic chest requires Silk x1, Boards x4, Nightmare Fuel x9."),
        L("暗影无法凭空成形。给我蜘蛛丝×1、木板×4、噩梦燃料×9。", "Shadows do not take form from nothing. I need Silk x1, Boards x4, Nightmare Fuel x9."),
        L("材料不够，真扫兴。蜘蛛丝×1、木板×4、噩梦燃料×9。", "Not enough materials. How tedious. Silk x1, Boards x4, Nightmare Fuel x9."),
    },
    _default = {
        L("建造魔术箱需要：蜘蛛丝×1、木板×4、噩梦燃料×9。", "Magic Chest needs: Silk x1, Boards x4, Nightmare Fuel x9."),
    },
}

-- 女武神专属：制作战斗长矛材料不足 
NPC_SPEECH.WATHGRITHR_NO_MATERIAL_SPEAR = {
    wathgrithr = {
        L("长矛造不了！缺树枝×2、燧石×2、金块×2。", "Can't forge the spear! Need Twigs x2, Flint x2, Gold x2."),
        L("需要材料！树枝×2、燧石×2、金块×2。", "The Valkyrie needs materials! Twigs x2, Flint x2, Gold x2."),
    },
    _default = {
        L("制作战斗长矛需要：树枝×2、熧石×2、金块×2。", "Battle Spear needs: Twigs x2, Flint x2, Gold x2."),
    },
}

-- 女武神专属：制作战斗头盔材料不足
NPC_SPEECH.WATHGRITHR_NO_MATERIAL_HELMET = {
    wathgrithr = {
        L("缺金块×2、石头×2。", " Need Gold x2, Rocks x2."),
        L("头盔需要金块×2、石头×2！", "The Valkyrie's helmet needs Gold x2, Rocks x2!"),
    },
    _default = {
        L("制作战斗头盔需要：金块×2、石头×2。", "Battle Helmet needs: Gold x2, Rocks x2."),
    },
}

NPC_SPEECH.WALTER_NO_MATERIAL_AMMO_GOLD = {
    walter = {
        L("黄金弹药需要金块×1。", "Gold ammo needs Gold Nugget x1."),
    },
    _default = {
        L("制作黄金弹药需要：金块×1。", "Gold Ammo needs: Gold Nugget x1."),
    },
}

NPC_SPEECH.WALTER_NO_MATERIAL_AMMO_SCRAPFEATHER = {
    walter = {
        L("电子废料弹药需要：红宝石×1、金块×1。", "Scrapfeather ammo needs: Red Gem x1, Gold Nugget x1."),
    },
    _default = {
        L("制作电子废料弹药需要：红宝石×1、金块×1。", "Scrapfeather Ammo needs: Red Gem x1, Gold Nugget x1."),
    },
}

NPC_SPEECH.WALTER_NO_MATERIAL_AMMO_THULECITE = {
    walter = {
        L("诅咒弹药需要：铥矿碎片×1、噩梦燃料×1。", "Cursed ammo needs: Thulecite Fragments x1, Nightmare Fuel x1."),
    },
    _default = {
        L("制作诅咒弹药需要：铥矿碎片×1、噩梦燃料×1。", "Cursed Ammo needs: Thulecite Fragments x1, Nightmare Fuel x1."),
    },
}

NPC_SPEECH.WALTER_NO_MATERIAL_AMMO_HORRORFUEL = {
    walter = {
        L("恐惧弹药需要：恐惧燃料×1、石头×1。", "Horror ammo needs: Horror Fuel x1, Rocks x1."),
    },
    _default = {
        L("制作恐惧弹药需要：恐惧燃料×1、石头×1。", "Horror Ammo needs: Horror Fuel x1, Rocks x1."),
    },
}

NPC_SPEECH.WALTER_NO_MATERIAL_AMMO_FREEZE = {
    walter = {
        L("冰冻弹药需要：月岩×1、蓝宝石×1。", "Freeze ammo needs: Moon Rock x1, Blue Gem x1."),
    },
    _default = {
        L("制作冰冻弹药需要：月岩×1、蓝宝石×1。", "Freeze Ammo needs: Moon Rock x1, Blue Gem x1."),
    },
}

NPC_SPEECH.WALTER_NO_MATERIAL_AMMO_SLOW = {
    walter = {
        L("减速弹药需要：月岩×1、紫宝石×1。", "Slow ammo needs: Moon Rock x1, Purple Gem x1."),
    },
    _default = {
        L("制作减速弹药需要：月岩×1、紫宝石×1。", "Slow Ammo needs: Moon Rock x1, Purple Gem x1."),
    },
}

NPC_SPEECH.WONKEY_NO_MATERIAL_BANANABUSH = {
    wonkey = {
        L("唔唔！香蕉不够，得要十根。", "Ooh ooh! Not enough bananas. Need ten."),
    },
    _default = {
        L("制作香蕉丛种子需要：香蕉×10。", "Banana Bush needs: Banana x10."),
    },
}

NPC_SPEECH.WONKEY_NO_MATERIAL_MONKEYTAIL = {
    wonkey = {
        L("唔？芦苇不够，得要十个。", "Ooh? Not enough reeds. Need ten."),
    },
    _default = {
        L("制作猴尾草苗需要：芦苇×10。", "Monkeytail Sapling needs: Reeds x10."),
    },
}

NPC_SPEECH.WONKEY_NO_MATERIAL_ANCIENTTREE_SEED = {
    wonkey = {
        L("要红宝石和蓝宝石各四个。", "Not enough shiny things! Need four red gems and four blue gems."),
    },
    _default = {
        L("制作惊喜种子需要：红宝石×4、蓝宝石×4。", "Surprise Seed needs: Red Gem x4, Blue Gem x4."),
    },
}

NPC_SPEECH.WILLOW_NO_MATERIAL_RAINBOW_FIREFLIES = {
    willow = {
        L("没有红宝石，火光可亮不起来。", "No red gem, no brilliant firelight."),
    },
    _default = {
        L("制作七彩萤火虫需要：红宝石×1。", "Rainbow Fireflies need: Red Gem x1."),
    },
}


-- ════════════════════════════════════════════════════════════
--  钓鱼相关
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.FISHING_NO_ROD = {
    wilson = {
        L("我要先找根钓竿。", "I need a fishing rod first."),
        L("没有钓竿，徒手钓鱼不太符合科学流程。", "Catching fish barehanded is not a very scientific procedure."),
        L("我需要一根钓竿。", "I need a properly standardized fishing rod."),
    },
    _default = {
        L("我需要一根钓竿！", "I need a fishing rod!"),
    },
}

NPC_SPEECH.FISHING_START = {
    wilson = {
        L("看看有什么上钩。", "Let's see what's biting."),
        L("好，实验现在开始。", "Good. The experiment begins now."),
        L("让我们观察鱼类摄食反应。", "Let us observe piscine feeding behavior."),
        L("钓鱼，本质上是诱导实验。", "Fishing is, in essence, an inducement experiment."),
        L("希望这次数据和晚饭能同步获得。", "Hopefully this yields both data and dinner."),
        L("开始记录：抛竿时间，已确认。", "Begin log: casting time confirmed."),
        L("接下来就看谁先犯错了。", "Now we wait to see who makes the first mistake."),
        L("安静点，科学正在咬钩。", "Quiet now. Science may be biting."),
        L("理论上，这里应该有鱼。", "Theoretically, there should be fish here."),
        L("如果顺利，我会得到样本和晚餐。", "If all goes well, I get a specimen and supper."),
        L("这一步叫耐心，不叫发呆。", "This part is called patience, not idling."),
        L("让我看看水下的因果关系。", "Let's examine the causality beneath the water."),
        L("鱼啊，请配合一下研究。", "Fish, kindly cooperate with the research."),
        L("今天适合做一场水边实验。", "Today is ideal for a waterside experiment."),
        L("诱饵已投放，接下来是等待。", "Bait deployed. The next step is waiting."),
    },
    _default = {
        L("钓鱼时间！", "Time to fish!"),
    },
}

NPC_SPEECH.FISHING_CATCH = {
    wilson = {
      L("哈！上钩了！", "Ha! Got a bite!"),
      L("很好，样本成功获取！", "Excellent. Sample successfully obtained!"),
      L("结果显著，鱼的确会上钩。", "Significant results: fish do bite."),
      L("成功了！这证明我的方法有效。", "Success! That proves my method works."),
      L("太好了，实验与晚餐都有了。", "Excellent. Both experiment and dinner are secured."),
      L("啊哈，水下反应符合预期！", "Aha, subaquatic response matches expectations!"),
      L("一条活体证据。真不错。", "A living piece of evidence. Splendid."),
      L("这就是耐心的回报。", "This is the reward of patience."),
      L("我就知道，科学不会辜负我。", "I knew science wouldn't fail me."),
      L("漂亮！钓鱼学再添一例。", "Beautiful! Another case for the study of angling."),
      L("从统计学上讲，这是个好开端。", "Statistically speaking, this is a strong start."),
      L("有意思，咬钩速度比预想快。", "Interesting. The bite came faster than expected."),
      L("样本到手，接下来可以分析了。", "Specimen secured. Analysis may proceed."),
      L("鱼的判断失误，成就了我的成功。", "The fish's lapse in judgment has become my success."),
      L("很好，这条鱼非常有研究价值。", "Good. This fish has excellent research value."),
    },
    _default = {
        L("钓到了！", "Got one!"),
    },
}

NPC_SPEECH.FISHING_NO_DEPOSIT = {
    wilson = {
        L("我得先知道把鱼放哪。", "I need to know where to put the fish first."),
        L("没有存放点，流程不完整。", "Without a deposit point, the procedure is incomplete."),
        L("我需要先确认样本收纳位置。", "I need to confirm specimen storage first."),
        L("没有存放方案，我很难继续。", "Without a storage plan, I can hardly continue."),
    },
    _default = {
        L("需要先设置存放点！", "I need a deposit point!"),
    },
}

NPC_SPEECH.FISHING_NO_POND = {
    wilson = {
        L("我找不到池塘。", "I can't find any ponds."),
        L("附近似乎没有合适水域。", "There doesn't seem to be a suitable body of water nearby."),
        L("没有池塘，鱼类实验无法展开。", "Without a pond, fish experiments cannot proceed."),
        L("嗯，这里的水文条件不太理想。", "Hm. The hydrological conditions here are less than ideal."),
        L("缺少目标水域，计划暂停。", "Target water source missing. Plan suspended."),
        L("看来我得重新搜索地形。", "Looks like I need to reassess the terrain."),
        L("这里不具备垂钓的基本条件。", "This area lacks the basic conditions for angling."),
        L("鱼不会凭空出现在干地上。", "Fish do not ordinarily appear on dry land."),
        L("至少根据目前的观察，不会。", "At least, according to current observations, they do not."),
        L("没有池塘，今天只能先做陆地研究。", "No pond. We'll have to settle for terrestrial research today."),
    },
    _default = {
        L("附近没有池塘...", "No ponds nearby..."),
    },
}

NPC_SPEECH.FISHING_NOT_ENOUGH_RODS = {
    wilson = {
        L("鱼竿耐久不够用了！", "My fishing rod won't last!"),
    },
    _default = {
        L("鱼竿不够用！", "Not enough rod durability!"),
    },
}

NPC_SPEECH.FISHING_PATH_PLANNING = {
    wilson = {
        L("我看看怎么去鱼池最快。", "Let me figure out the fastest route to the pond."),
        L("计算一下最优路径。", "Calculating the optimal path."),
        L("嗯，先规划一下路线。", "Hm, let me plan the route first."),
        L("这条路应该最短。", "This route should be the shortest."),
        L("让我评估一下地形。", "Let me evaluate the terrain."),
    },
    _default = {
        L("我看看怎么过去。", "Let me figure out how to get there."),
    },
}

NPC_SPEECH.FISHING_LOW_DURABILITY = {
    wilson = {
        L("鱼竿快用完了，再钓几条就回去。", "The rod is wearing out. Just a few more, then we head back."),
        L("耐久不太够了，得省着用。", "Durability is running low. Better conserve it."),
        L("鱼竿的寿命快到极限了。", "The rod's lifespan is nearing its limit."),
    },
    _default = {
        L("鱼竿耐久不够了！", "The fishing rod is too worn out!"),
    },
}

-- ── Wilson 查看 NPC 位置 ─────────────────────────────────────
NPC_SPEECH.WILSON_FOUND_ALL_FRIENDS = {
  wilson = { L("我找到了所有朋友，但只能显示30秒。", "I found all our friends, but only for 30 seconds.") },
  _default = { L("我找到了所有朋友，但只能显示30秒。", "I found all our friends, but only for 30 seconds.") },
}

NPC_SPEECH.WILSON_NEED_BLUEGEM_FOR_LOCATIONS = {
  wilson = { L("我需要一颗蓝宝石来定位大家。", "I need one Blue Gem to locate everyone.") },
  _default = { L("需要蓝宝石×1。", "Need Blue Gem x1.") },
}


-- ════════════════════════════════════════════════════════════
--  海钓相关
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.OCEAN_FISHING_START = {
    wendy = {
        L("大海的深处藏着许多秘密…还有鱼。", "The ocean's depths hold many secrets... and fish."),
        L("阿比盖尔，让我们看看大海能给我们什么。", "Abigail, let's see what the sea offers us."),
        L("也许海洋会分享它的恩赐。", "Perhaps the ocean will share its bounty."),
    },
    _default = {
        L("去海边钓鱼！", "Time for ocean fishing!"),
    },
}

NPC_SPEECH.OCEAN_FISHING_CATCH = {
    wendy = {
        L("又一个灵魂从深渊中被拉出。", "Another soul pulled from the deep."),
        L("大海交出了它的一个同伴。", "The sea surrendered one of its own."),
        L("阿比盖尔，看看我在海浪下面发现了什么。", "Abigail, look what I found beneath the waves."),
    },
    _default = {
        L("海钓到了！", "Caught one from the sea!"),
    },
}

NPC_SPEECH.OCEAN_FISHING_NO_ROD = {
    wendy = {
        L("我需要一根海钓竿才能在这里钓鱼。", "I need an ocean fishing rod to fish here."),
        L("没有钓竿，大海就保守它的秘密。", "Without a rod, the ocean keeps its secrets."),
    },
    _default = {
        L("我需要海钓竿！", "I need an ocean fishing rod!"),
    },
}

NPC_SPEECH.OCEAN_FISHING_NO_SHORE = {
    wendy = {
        L("附近没有合适的海岸。", "There's no suitable shore nearby."),
        L("海岸在躲着我…就像很多事情一样。", "The coast eludes me... like so many things."),
    },
    _default = {
        L("附近没有海岸线…", "No shore nearby..."),
    },
}

NPC_SPEECH.OCEAN_FISHING_NO_DEPOSIT = {
    wendy = {
        L("这些鱼该放到哪里…？", "Where should I put these fish...?"),
        L("我需要一个地方来存放渔获。", "I need somewhere to store the catch."),
    },
    _default = {
        L("需要设置海钓存放点！", "I need an ocean fish deposit point!"),
    },
}

NPC_SPEECH.OCEAN_FISHING_LINE_SNAP = {
    wendy = {
        L("线断了…至少有一个获得了自由。", "The line snapped... freedom for one, at least."),
        L("它跑了…幸运的鱼。", "It got away... lucky fish."),
    },
    _default = {
        L("鱼线断了！", "The line snapped!"),
    },
}

NPC_SPEECH.OCEAN_FISHING_NO_SPACE = {
    wendy = {
        L("背包太满了…请先帮我清理一下。", "My bag is too full... please help me clean it up first."),
        L("这些东西占满了我的背包。", "These things have filled up my bag."),
    },
    _default = {
        L("背包满了，装不下鱼了。", "My bag is full, no room for fish."),
    },
}

NPC_SPEECH.OCEAN_FISHING_DONE = {
    wendy = {
        L("今天从海里捞的够多了。", "That's enough from the sea for now."),
        L("大海可以休息了…暂时。", "The ocean can rest... for a while."),
    },
    _default = {
        L("海钓结束了。", "Ocean fishing is done."),
    },
}

NPC_SPEECH.OCEAN_FISHING_PATH_PLANNING = {
    wendy = {
        L("让我看看怎么走过去。", "Let me see how to get there."),
        L("我来找一条路…", "I'll find a way..."),
        L("海岸应该就在那边。", "The shore should be that way."),
    },
    _default = {
        L("让我看看怎么过去。", "Let me figure out how to get there."),
    },
}

-- 淡水钓鱼：回存放点时的台词
NPC_SPEECH.FISHING_DEPOSIT_RETURN = {
    wilson = {
        L("鱼够多了，回去放好。", "Got enough fish, heading back to store them."),
        L("该把鱼带回去了。", "Time to bring the fish back."),
        L("满载而归！", "Heading home with a full haul!"),
        L("回去把鱼放好再继续。", "Let me store these fish first, then continue."),
    },
    _default = {
        L("钓完了，回去放鱼。", "Done fishing, heading back to store the catch."),
    },
}

-- 海钓：回存放点时的台词
NPC_SPEECH.OCEAN_FISHING_DEPOSIT_RETURN = {
    wendy = {
        L("该把收获带回去了…", "Time to bring the catch back..."),
        L("回去放鱼吧…", "Let's go store the fish..."),
        L("这些鱼…先放好吧。", "These fish... let me put them away first."),
    },
    _default = {
        L("回去存放渔获。", "Heading back to store the catch."),
    },
}


-- ════════════════════════════════════════════════════════════
--  薇尔芭·银项链台词（专属于 Wilba NPC）
-- ════════════════════════════════════════════════════════════

-- 项链被取走时（立刻喊）
NPC_SPEECH.WILBA_NECKLACE_TAKEN = {
    L("啊！不要动本公主的项链！这是本公主美丽容貌的核心！",     "Ah! Do NOT touch the princess's necklace! It is the cornerstone of her beauty!"),
    L("放开！那是本公主最闪亮的宝物！还我！",                   "Let go! That is the princess's most radiant treasure! Return it at once!"),
    L("你居然敢拿走本公主的项链！美貌岂能如此失窃！",          " you dare take the princess's necklace?! One cannot simply steal away her beauty!"),
    L("哼！本公主没有项链就像天空没有星星，太惨了！",            "Hmph! The princess without her necklace is like a sky without stars. Utterly tragic!"),
    L("啊呀！本公主的美丽形象将受到严重威胁，赶快还来！",        "Oh no! The princess's radiant image is under serious threat. Return it immediately!"),
}

-- 物品栏里找到项链后自动装备，并说话
NPC_SPEECH.WILBA_NECKLACE_REEQUIP = {
    L("嗯！本公主的美丽容貌回来了！比太阳还耀眼！",             "Ah! The princess's beautiful appearance is restored! More dazzling than the sun!"),
    L("终于找回来了！项链一回来，本公主就完整了！",              "Finally recovered! With the necklace returned, the princess is whole again!"),
    L("好了好了，本公主又是那个天下第一美的猪人公主了！",        "There we go! The princess is once again the most beautiful pig princess in the world!"),
    L("（戴上项链，转了个圈）完美！本公主的光芒无可匹敌！",      "(puts on necklace, spins around) Perfect! The princess's radiance is unmatched!"),
    L("项链回来，美貌回来，本公主的世界又完整了！",              "Necklace returned, beauty restored — the princess's world is whole once more!"),
}

-- 长时间找不到项链时的抱怨（10~15秒间隔随机说）
NPC_SPEECH.WILBA_NECKLACE_MISSING = {
    L("是谁偷了本公主的项链！还我美丽的容颜！",                 "Who stole the princess's necklace?! Return her beautiful appearance at once!"),
    L("（哭哭啼啼）没有项链，本公主的美貌飞走了！",          "(sobbing) Without the necklace the princess's beauty it has vanished..."),
    L("本公主的银项链！你在哪里！本公主离不开你！",              "The princess's silver necklace! Where are you?! The princess cannot live without you!"),
    L("（叉腰四处张望）哪个大胆刁民拿走了本公主的宝贝项链！",    "(hands on hips, looking around) Which reckless subject took the princess's precious necklace?!"),
    L("没有项链的本公主，就像是没有光的皇宫，黯淡无光啊！",      "The princess without her necklace... is like a palace with no light. Utterly dim!"),
    L("谁！谁拿走了本公主的项链！本公主的美颜需要它来加持！",    "Who! Who took the princess's necklace?! Her radiant beauty depends on it!"),
    L("（幽幽叹气）本公主的银项链，你可是本公主美丽的灵魂啊", "(sighs softly) My silver necklace... you are the very soul of the princess's beauty..."),
}

-- 薇尔芭发现小偷（别人佩戴了银项链）
NPC_SPEECH.WILBA_NECKLACE_THIEF = {
    L("找到小偷了！还我项链！",                                   "Found the thief! Give back my necklace!"),
    L("大胆！那是本公主的项链！还来！",                           "How dare you! That is the princess's necklace! Return it!"),
    L("好你个贼子！本公主的项链你也敢动！",                       "You wretch! How dare you touch the princess's necklace!"),
    L("（怒目圆睁）给我把项链交出来！",                           "(glaring furiously) Hand over the necklace at once!"),
    L("你以为本公主没发现吗！还我项链！",                         "Did you think the princess wouldn't notice?! Give back her necklace!"),
}

-- ════════════════════════════════════════════════════════════
--  欢迎公告（全局广播，不分角色）
-- ════════════════════════════════════════════════════════════
NPC_SPEECH.WELCOME = L(
    "NPC: 你好朋友，我在世界的某个角落等你！",
    "NPC: Hello friend, I'm waiting for you somewhere in the world!"
)


return NPC_SPEECH
