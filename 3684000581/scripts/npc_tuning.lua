-- mod/NPCFriends/scripts/npc_tuning.lua
-- NPC 伙伴角色属性配置表
-- ────────────────────────────────────────────────────────────

local npc_affinity = require("npc/npc_affinity")

local NPC_TUNING = {}

-- ═══════════════════════════════════════════════════════════════
--  基础物理 & 移动
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.RUN_SPEED     = 7       -- 移动速度
NPC_TUNING.PHYSICS_MASS  = 75      -- 碰撞体质量
NPC_TUNING.PHYSICS_RAD   = 0.5     -- 碰撞体半径

-- ═══════════════════════════════════════════════════════════════
--  角色定义 & 出生配置
-- ═══════════════════════════════════════════════════════════════
-- ────────────────────────────────────────────────────────────
--  各角色独立属性（key = DST prefab 名称）
-- ────────────────────────────────────────────────────────────
--  通用字段：
--    health / max_health    — 血量 / 最大血量
--    damage                 — 基础伤害
--    attack_range           — 攻击距离（格）
--  可选特化字段（省略则使用全局默认值）：
--    damage_mult            — 伤害倍率（默认 1）
--    absorption             — 固有减伤百分比（默认 0，独立于护甲叠加）
--    lifesteal              — 每次攻击命中回血量（默认 0）
--    inventory_slots        — 物品栏格数（默认 NPC_TUNING.INVENTORY_SLOTS）
--    pick_speed             — 采集速度倍率（默认 NPC_TUNING.PICK_SPEED，2=两倍速）
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.CHARACTER_STATS = {
    wilson       = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=16, pick_speed=2, ghost_regen=2 },  -- 16格背包 + 采集两倍速
    wendy        = { health=150, max_health=150, damage=5, attack_range=2, damage_mult=0.75, inventory_slots=12, ghost_regen=2 },  -- 12格背包 + 攻击减25%伤害
    wathgrithr   = { health=200, max_health=200, damage=5, attack_range=2, damage_mult=1.25, absorption=0.25, lifesteal=2, inventory_slots=8, diet="MEAT", ghost_regen=5 },  -- 8格背包 + 战斗特化 + 只吃肉
    wolfgang     = { health=200, max_health=200, damage=5, attack_range=2, inventory_slots=8, ghost_regen=2 },  -- 8格背包 + 饱食度三状态（虚弱/正常/威猛）
    wormwood     = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=16, ghost_regen=5 },  -- 12格背包，基础属性
    warly        = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=16, ghost_regen=2, cook_time_mult=0.5 },  -- 16格背包，烹饪速度2倍
    waxwell      = { health=75, max_health=75, damage=5, attack_range=2, inventory_slots=12, ghost_regen=2 },  -- 12格背包
    wes          = { health=113, max_health=113, damage=5, attack_range=2, damage_mult=0.75, inventory_slots=24, ghost_regen=2, mute=true },  -- 减25%伤害 + 哑巴 + 24格背包
    woodie       = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=12, ghost_regen=2 },  -- 12格背包 + 砍树特化
    willow       = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=12, ghost_regen=2 },  -- 12格背包 + 不怕火
    wickerbottom  = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=12, ghost_regen=2 },  -- 12格背包
    winona       = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=24, ghost_regen=2 },  -- 24格背包 + 整理特化
    walter       = { health=130, max_health=130, damage=5, attack_range=2, inventory_slots=12, ghost_regen=2 },  -- 12格背包 + 弹弓特化预留
    webber       = { health=275, max_health=275, damage=5, attack_range=2, inventory_slots=8, ghost_regen=1 },  -- 敌对韦伯
    wurt         = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=24, ghost_regen=1 },  -- 敌对沃特
    wx78         = { health=150, max_health=150, damage=5, attack_range=3, inventory_slots=12, ghost_regen=2 }, -- 12格背包 + 旋转电路战斗
    wortox       = { health=200, max_health=200, damage=5, attack_range=2, inventory_slots=8, ghost_regen=10 },
    wanda        = { health=60, max_health=60, damage=5, attack_range=2, inventory_slots=12, ghost_regen=2 },
    wonkey       = { health=125, max_health=125, damage=5, attack_range=2, inventory_slots=12, ghost_regen=2, sanity=100, hunger=175 },
    wilba        = { health=150, max_health=150, damage=5, attack_range=2, inventory_slots=24, ghost_regen=2 },  -- 猪人公主 (Hamlet DLC)
    -- 默认/未知角色：使用 Wilson 数值（不含特化字段，走全局默认）
    --npcfriend    = { health=150, max_health=150, damage=34, attack_range=2 },
}

-- ═══════════════════════════════════════════════════════════════
--  NPC 语音(TTS) 配置
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.TTS_VOLUME = {
    _default     = 0.50,
    wilson       = 0.50,
    wathgrithr   = 0.50,
    wendy        = 0.50,
    wolfgang     = 0.50,
    wormwood     = 0.50,
    warly        = 0.50,
    waxwell      = 0.50,
    wes          = 0.50,
    winona       = 0.50,
    woodie       = 0.50,
    willow       = 0.50,
    wickerbottom = 0.50,
    walter       = 0.50,
    webber       = 0.50,
    wurt         = 0.50,
    wx78         = 0.50,
    wortox       = 0.50,
    wanda        = 0.50,
    wonkey       = 0.50,
    wilba        = 0.50,
}

-- 每角色语音开关（运行时表）：由配置文件初始化、可被 DstAdmin 实时切换
NPC_TUNING.TTS_ENABLED = {}

-- NPC 出生角色列表（按数组顺序生成，允许重复角色）
-- 每个条目对应一个独立 NPC 实例（slot），重复角色拥有独立物品栏/血量/跟随关系
-- 角色名必须在 CHARACTER_STATS 中有对应条目（否则使用 wilson 默认值）
-- 格式：
--   { char, spawn="world" } → 世界随机位置（不含岛屿）
--   { char, enabled=false } → 禁用，不会生成（保留 slot 位置，方便随时开启）
-- 辅助函数：从 NPCFRIENDS 全局表读取角色开关（nil/无配置时默认 true）
-- 必须运行时查询，不能在模块加载时烘焙结果：
-- 若该模块被其它 require 链提前加载（例如 npc/npc_pool_config.lua 的转发），
-- 此时 _G.NPCFRIENDS 尚未赋值，会导致全部退化为 true，从而令 modconfig 的禁用选项失效。
function NPC_TUNING.IsCharEnabled(char_name)
    local config = rawget(_G, "NPCFRIENDS")
    if not config then return true end
    local key = "npc_" .. char_name
    if config[key] == nil then return true end
    return config[key] ~= false
end

-- 角色生成
NPC_TUNING.NPC_CHARACTERS  = {

    { char = "wilson" },
    { char = "wormwood" },
    { char = "warly" },
    { char = "wes" },
    --{ char = "willow" },
    --{ char = "woodie" },
    --{ char = "wurt" },
    --{ char = "webber" },
    --{ char = "wanda" },
    { char = "wickerbottom",spawn = "world" },
    { char = "willow",     spawn = "world" },
    { char = "waxwell",    spawn = "world" },
    { char = "woodie",     spawn = "world" },
    { char = "wendy",      spawn = "world" },
    { char = "wathgrithr", spawn = "world" },
    { char = "wolfgang",   spawn = "world" },
    { char = "winona",     spawn = "world" },
    { char = "wortox",     spawn = "world" },
    { char = "wanda",      spawn = "world" },
    { char = "walter",     spawn = "world" },
    { char = "wonkey",     spawn = "world" },
    { char = "wilba",      spawn = "world" },
    { char = "wx78",       spawn = "world" },
    
}

-- 每个玩家同时跟随的 NPC 上限（modinfo 配置项 max_followers，默认 2）
-- 同样使用 getter 避免加载顺序问题
function NPC_TUNING.GetMaxFollowers()
    local config = rawget(_G, "NPCFRIENDS")
    return (config and config.max_followers) or 2
end

-- 兼容旧读法：保留字段，但值在模块加载时可能尚未准确；推荐使用 GetMaxFollowers()
NPC_TUNING.MAX_NPC_FOLLOWERS = (rawget(_G, "NPCFRIENDS") and rawget(_G, "NPCFRIENDS").max_followers) or 2

-- 副本 NPC slot 起始值
-- c_spawnnpc / 未来 DstAdmin "生成指定角色" 入口生成的副本 NPC，
-- slot_index 从该值起递增，与正版配置 slot（1..#NPC_CHARACTERS）永不冲突，
-- 因此不会被 ReconcileWorldNPCs / RelinkNPCs / disabled_map 流程接管。
NPC_TUNING.DUPLICATE_SLOT_BASE = 10000

NPC_TUNING.STARTING_ITEMS  = { "spear" }           -- 每个 NPC 出生自带的默认物品

-- NPC 专属成长食物参数（永久叠加）
NPC_TUNING.NPC_HEART_PERM_MAX_HEALTH = 10 -- NPC_Heart：永久增加最大生命
NPC_TUNING.NPC_SWORD_PERM_DAMAGE = 2      -- NPC_Sword：永久增加基础伤害

-- 角色专属出生物品（覆盖 STARTING_ITEMS，未配置的角色使用默认值）
NPC_TUNING.CHARACTER_STARTING_ITEMS = {
    wilson     = { "spear","spear", "footballhat", "fishingrod", "strawhat" },
    wendy      = { "oceanfishingrod", "strawhat" },
    wathgrithr = { "spear_wathgrithr", "wathgrithrhat" },  -- 女武神：战斗长矛 + 战斗头盔
    wolfgang   = { "hambat", "footballhat" },               -- 沃尔夫冈：大肉棒 + 猪皮帽
    wormwood   = { "farm_plow_item", "farm_hoe", "shovel", "hammer" },   -- 植物人：长矛 + 犁地机 + 锄头 + 铲子 + 锤子（
    warly      = { "axe", "shovel" },               -- 厨师：长矛 + 锤子 + 斧头 + 铲子
    waxwell    = { "nightsword", "armor_sanity" },  -- 麦斯威尔：暗影刀 + 暗影甲
    wes        = { "strawhat" },          -- 韦斯：长矛 + 猪皮帽
    woodie     = { "lucy" },            -- 伍迪：露西斧
    willow     = { "bernie_inactive", "spear" },     -- 薇洛：伯尼 + 长矛
    walter     = { "slingshot", "spear" },            -- 沃尔特：专属弹弓 + 长矛
    wx78       = {  "axe", "pickaxe" }, 
    wonkey     = { "dug_bananabush", "dug_monkeytail", "palmcone_seed", "palmcone_seed", "palmcone_seed", "palmcone_seed", "palmcone_seed", "ancienttree_seed" },
    webber     = { "spear", "footballhat", "footballhat", "footballhat", "footballhat", "orangestaff" }, -- 韦伯（敌对）：长矛 + 双猪皮帽 + 懒人杖（小偷包改为生成后强制装备）
    wurt       = { 
        "ruins_bat","ruins_bat","ruins_bat","ruins_bat", 
        "ruinshat", "ruinshat", "ruinshat", "ruinshat","ruinshat", "ruinshat", "ruinshat", 
        "orangestaff","orangestaff","orangestaff", 
        "staff_tornado", "staff_tornado", "staff_tornado", "staff_tornado" 
    }, -- Wurt（敌对）：长矛 + 猪皮帽 + 懒人杖（传送）+ 风向标（龙卷风）
    wanda      = { "pocketwatch_weapon", "pocketwatch_heal" }, -- 旺达：专属武器 + 不老表
    wilba      = { "silvernecklace" }, -- 薇尔芭：银项链
}

-- “装备背包”圈选半径（格，圆圈显示与服务端检测共用）
NPC_TUNING.EQUIP_BACKPACK_PICKUP_RADIUS = 2

-- 工具无限耐久角色白名单（只有列出的角色的初始装备不消耗耐久）
NPC_TUNING.INFINITE_DURABILITY_CHARS = { "wormwood", "warly", "woodie", "webber" ,"wurt","wanda","wx78"}  -- 旺达怀表不消耗耐久（同时可通过测试配置允许拿取）

-- 防具无限耐久角色白名单（与工具分离；仅对 armor 生效）
NPC_TUNING.INFINITE_ARMOR_DURABILITY_CHARS = { "webber","wurt" }

-- NPC 不可拿取的专属工具（仅这些角色的这些物品在管理面板中不可拿取/交换）
-- 注意：bernie_inactive 和 lucy 已在 DSTAdmin 的 UNTAKEABLE_PREFABS 黑名单中，无需重复配置
NPC_TUNING.UNTAKEABLE_NPC_TOOLS = {
    wormwood = { "farm_plow_item", "farm_hoe", "shovel", "hammer" },
    wanda = { "pocketwatch_weapon", "pocketwatch_heal" },
    walter = { "slingshot"},
}

-- 调试开关：临时允许玩家拿走 NPC 的"不可拿取"工具
NPC_TUNING.DEBUG_ALLOW_TAKE_NPC_TOOLS = false

-- NPC 出生点与玩家的距离（格）
NPC_TUNING.SPAWN_OFFSET_MIN = 5    -- 最小距离
NPC_TUNING.SPAWN_OFFSET_MAX = 15   -- 最大距离



-- ═══════════════════════════════════════════════════════════════
--  角色专属系统
-- ═══════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────────────────────
--  灵魂系统
-- ──────────────────────────────────────────────────────────
NPC_TUNING.GHOST_REGEN_PER_SEC = 1                            -- 灵魂状态默认每秒回血量（可被 CHARACTER_STATS.ghost_regen 覆盖）
NPC_TUNING.GHOST_COLOUR        = { 0.8, 0.1, 0.1, 0.45 }     -- 灵魂颜色（半透明深红）

-- ──────────────────────────────────────────────────────────
--  Wortox灵魂治疗参数
-- ──────────────────────────────────────────────────────────
NPC_TUNING.WORTOX_NPC_SOUL_CHECK_INTERVAL = 5      -- 每隔 N 秒检查一次治疗需求
NPC_TUNING.WORTOX_NPC_SOUL_SEARCH_RADIUS = 20       -- 检查半径（格）
NPC_TUNING.WORTOX_NPC_SOUL_HEAL_RANGE = 22          -- 群体治疗生效半径（格）
NPC_TUNING.WORTOX_NPC_SOUL_HEAL_BASE = 20           -- 基础治疗值
NPC_TUNING.WORTOX_NPC_SOUL_HEAL_LOSS_PER_TARGET = 1 -- 每多一个目标，治疗值减少
NPC_TUNING.WORTOX_NPC_SOUL_HEAL_MIN = 15            -- 最低治疗值下限
NPC_TUNING.WORTOX_NPC_SOUL_HEAL_DELAY = 1           -- 丢魂后到治疗结算延迟（秒）
NPC_TUNING.WORTOX_NPC_SOUL_FOLLOW_TIMEOUT = 6       -- 超出治疗范围时，追近目标的最长持续时间
NPC_TUNING.WORTOX_NPC_SOUL_FOLLOW_TICK = 0.25       -- 追近刷新周期（秒）
NPC_TUNING.WORTOX_NPC_SOULHOP_FOLLOW_TRIGGER = 16   -- 跟随时超出该距离（格）触发灵魂跳跃贴近领队
NPC_TUNING.WORTOX_NPC_SOULHOP_MIN_DIST = 2          -- 跳跃落点距目标最小距离（格）
NPC_TUNING.WORTOX_NPC_SOULHOP_MAX_DIST = 3          -- 跳跃落点距目标最大距离（格）
NPC_TUNING.WORTOX_NPC_SOULHOP_ATTEMPTS = 24         -- 落点采样次数（越大越稳）
NPC_TUNING.WORTOX_NPC_SOULHOP_COOLDOWN = 8          -- 跳跃冷却（秒）
NPC_TUNING.WORTOX_NPC_SOULHOP_COMBAT_THREAT_CHECK = 5 -- 战斗回血时，检测"仇恨小恶魔"的生物半径（格）
NPC_TUNING.WORTOX_NPC_SOULHOP_COMBAT_AWAY_DIST = 12    -- 战斗回血前跳脱距离（相对仇恨生物，格）
NPC_TUNING.WORTOX_NPC_SOUL_DEBUG = false            -- 调试日志：打印"回血施法"

-- ──────────────────────────────────────────────────────────
--  Wanda（时间系统）参数
-- ──────────────────────────────────────────────────────────
-- 说明：
--   1) 旺达的生命值即“时间刻度”（oldager 机制）
--   2) 受击后会按 oldager 规则持续掉"时间"
--   3) 三年龄阶段按生命百分比切换：young / normal / old
NPC_TUNING.WANDA_OLDAGER_BASE_RATE = 1 / 40 -- 每秒流逝"年刻度"（越大老化越快）
NPC_TUNING.WANDA_AGE_THRESHOLD_OLD = 0.25   -- <= 该阈值进入老年
NPC_TUNING.WANDA_AGE_THRESHOLD_YOUNG = 0.75 -- >= 该阈值进入年轻
NPC_TUNING.WANDA_START_HEALTH_PERCENT = 0.70 -- 初始生命为 42/60（按 20~80 映射约 38 岁）

-- 年龄阶段伤害倍率
NPC_TUNING.WANDA_REGULAR_DAMAGE_OLD = 0.5
NPC_TUNING.WANDA_REGULAR_DAMAGE_NORMAL = 1
NPC_TUNING.WANDA_REGULAR_DAMAGE_YOUNG = 1
NPC_TUNING.WANDA_SHADOW_DAMAGE_OLD = 1.75
NPC_TUNING.WANDA_SHADOW_DAMAGE_NORMAL = 1.2
NPC_TUNING.WANDA_SHADOW_DAMAGE_YOUNG = 1

-- 资源命名：wanda_NPC / wanda_young_NPC / wanda_old_NPC
NPC_TUNING.WANDA_BUILD_YOUNG = "wanda_young_NPC"
NPC_TUNING.WANDA_BUILD_NORMAL = "wanda_NPC"
NPC_TUNING.WANDA_BUILD_OLD = "wanda_old_NPC"

-- oldager 允许反向恢复时间的 cause
NPC_TUNING.WANDA_VALID_HEAL_CAUSES = { "pocketwatch_heal", "debug_key" }

-- 年龄映射（健康百分比 <-> 岁数）
NPC_TUNING.WANDA_MIN_YEARS_OLD = 20
NPC_TUNING.WANDA_MAX_YEARS_OLD = 80

-- 自动返老还童
NPC_TUNING.WANDA_REJUVENATE_TRIGGER_AGE = 74 -- 达到该年龄触发
NPC_TUNING.WANDA_REJUVENATE_RECOVER_YEARS = 60 -- 单次回退年龄
NPC_TUNING.WANDA_REJUVENATE_COOLDOWN = 90 -- 冷却（秒）
NPC_TUNING.WANDA_REVIVE_DEBUG = false -- 复活链路调试日志（死亡→幽灵→复活的bank/build/state）

-- 裂缝传送饱食度消耗（消耗玩家的饱食度）
NPC_TUNING.WANDA_RIFT_HUNGER_COST = 30          -- 同世界传送饱食度消耗
NPC_TUNING.WANDA_RIFT_HUNGER_COST_CROSSWORLD = 50  -- 跨世界传送饱食度消耗

-- ──────────────────────────────────────────────────────────
--  女武神战歌（心碎歌谣/攻击回血）参数
-- ──────────────────────────────────────────────────────────
NPC_TUNING.WATHGRITHR_BATTLESONG_DURATION = 8        -- 战歌持续时间（秒）：脱战后开始倒计时
NPC_TUNING.WATHGRITHR_BATTLESONG_RADIUS = 20          -- 生效半径（格）
NPC_TUNING.WATHGRITHR_BATTLESONG_REFRESH_PERIOD = 2 -- 刷新周期（秒）：周期重挂 battlesong_healthgain_buff
NPC_TUNING.WATHGRITHR_BATTLESONG_COMBAT_GRACE = 2     -- 战斗判定缓冲（秒）

-- ──────────────────────────────────────────────────────────
--  沃尔夫冈系统（饱食度驱动三状态：虚弱/正常/威猛）
-- ──────────────────────────────────────────────────────────
NPC_TUNING.WOLFGANG_MAX_HUNGER        = 300   -- 最大饱食度
NPC_TUNING.WOLFGANG_HUNGER_DRAIN      = 1     -- 每秒饱食度流失量
NPC_TUNING.WOLFGANG_WIMPY_THRESHOLD   = 100   -- 饱食度低于此值 → 虚弱
NPC_TUNING.WOLFGANG_MIGHTY_THRESHOLD  = 200   -- 饱食度高于等于此值 → 威猛
NPC_TUNING.WOLFGANG_AUTO_EAT_INTERVAL = 2     -- 自动进食冷却（秒）
NPC_TUNING.WOLFGANG_AUTO_EAT_FOODTYPES = {    -- 自动进食允许的食物类型
    VEGGIE = true,
    BERRY = true,
    MEAT = true,
    GENERIC = true,
    GOODIES = true,
}
NPC_TUNING.WOLFGANG_AUTO_EAT_BLACKLIST = {    -- 自动进食永不吃的 prefab（材料/工具/特殊物品）
    hambat = true,        -- 大肉棒
    gears = true,         -- 齿轮
    cutgrass = true,      -- 草是
    twigs = true,         -- 树枝
}

-- 三状态属性配置（饱食度驱动）
-- damage_mult: 伤害系数，最终伤害 = (基础伤害 + 武器伤害) × damage_mult
NPC_TUNING.WOLFGANG_STATE_CONFIG = {
    wimpy  = { damage_mult = 0.75, scale = 0.75,  attack_speed = 0.8 },  -- 虚弱
    normal = { damage_mult = 1.0,  scale = 1.0,   attack_speed = 1.2 },  -- 正常
    mighty = { damage_mult = 2.2,  scale = 1.2,   attack_speed = 1.5 },  -- 威猛
}

-- ──────────────────────────────────────────────────────────
--  韦斯待机状态
-- ──────────────────────────────────────────────────────────
NPC_TUNING.WES_BALLOON_INTERVAL     = 100      -- 韦斯待机吹气球间隔（秒）
NPC_TUNING.WES_BALLOON_POP_TIME     = 15      -- 气球自动爆炸时间（秒）
NPC_TUNING.WES_BALLOON_FLIGHT_SPEED = 3       -- 气球飞行速度（单位/秒）
NPC_TUNING.WES_BALLOON_APPROACH_DIST = 1      -- 靠近爆炸距离阈值
NPC_TUNING.WES_BALLOON_TARGET_RANGE = 15      -- 搜索目标半径（格）

-- ──────────────────────────────────────────────────────────
--  暗影保护者 & 暗影支柱系统（麦斯威尔专属）
-- ──────────────────────────────────────────────────────────
NPC_TUNING.SHADOW_PROTECTOR_HEALTH    = 75    -- 暗影保护者血量
NPC_TUNING.SHADOW_PROTECTOR_DAMAGE    = 25    -- 暗影保护者攻击力
NPC_TUNING.SHADOW_PROTECTOR_LIFETIME  = 180   -- 暗影保护者存活时间（秒）
NPC_TUNING.SHADOW_PROTECTOR_COOLDOWN  = 60   -- 召唤冷却时间（秒）
NPC_TUNING.SHADOW_PROTECTOR_LEASH     = 12    -- 暗影保护者跟随最大距离（格）
NPC_TUNING.SHADOW_PROTECTOR_MAX_COUNT = 3     -- 每次召唤同时生成的暗影保护者数量
NPC_TUNING.SHADOW_PILLAR_COOLDOWN     = 15    -- 暗影支柱技能冷却时间（秒）
NPC_TUNING.SHADOW_PILLAR_POLL_INTERVAL = 8    -- 暗影支柱兜底轮询间隔（秒）：主触发为闪避后反打，此轮询仅用于不会触发闪避的敌人

-- 暗影工人（通用工人：跟随玩家砍树/挖矿/挖掘时召唤，独立召唤CD）
NPC_TUNING.SHADOW_WORKER_HEALTH       = 30    -- 暗影工人血量
NPC_TUNING.SHADOW_WORKER_LIFETIME     = 180   -- 暗影工人存活时间（秒）= 3 分钟
NPC_TUNING.SHADOW_WORKER_COUNT        = 2     -- 每次召唤的暗影工人数量
NPC_TUNING.SHADOW_WORKER_SEE_DIST     = 17    -- 暗影工人搜索可工作目标半径（格）
NPC_TUNING.SHADOW_WORKER_KEEP_DIST    = 18    -- 暗影工人超出此距离放弃工作，回去跟随主人
NPC_TUNING.SHADOW_WORKER_COOLDOWN     = 10   -- 暗影工人独立召唤冷却（秒）
NPC_TUNING.SHADOW_WORKER_DIG_GRAVE    = true  -- 工人是否挖坟墓（false 则只挖树桩/农场杂物）
NPC_TUNING.WAXWELL_MAGIC_CHEST_MAX_DIST = 30  -- 麦斯威尔 NPC 魔术箱放置距离（格）

-- ──────────────────────────────────────────────────────────
--  薇诺娜建造系统
-- ──────────────────────────────────────────────────────────
NPC_TUNING.WINONA_BUILD_PLACE_MAX_DIST = 30    -- 薇诺娜设备放置距离（格）

-- ──────────────────────────────────────────────────────────
--  NPC吴迪鹿人变身（战斗时自动变身，结束后变回）
-- ──────────────────────────────────────────────────────────
NPC_TUNING.WEREMOOSE_DAMAGE        = 59.5  -- 鹿人伤害
NPC_TUNING.WEREMOOSE_ABSORPTION    = 0.9   -- 鹿人护甲（90%减伤）
NPC_TUNING.WEREMOOSE_RUN_SPEED     = 6     -- 鹿人移动速度
NPC_TUNING.WEREMOOSE_TACKLE_SPEED  = 14    -- 冲撞速度
NPC_TUNING.WEREMOOSE_TACKLE_LOOPS  = 4     -- 冲撒循环次数（NPC加倍；总距离≈速度×动画时长×(loops+1)）
NPC_TUNING.WEREMOOSE_TACKLE_DIST   = 6     -- 发起冲撞的最小距离（近距离不冲撞，用拳击）
NPC_TUNING.WEREMOOSE_TACKLE_MAX_DIST = 15    -- 发起冲撞的最大距离
NPC_TUNING.WEREMOOSE_TACKLE_CD     = 5     -- 冲撞冷却（秒）
NPC_TUNING.WEREMOOSE_TACKLE_DAMAGE = 101    -- 冲撞碰撞伤害
NPC_TUNING.WEREMOOSE_TACKLE_OVERRUN = 3    -- 穿过生物后继续冲撞的距离（格），超过则减速停止
NPC_TUNING.WEREMOOSE_REVERT_DELAY  = 3     -- 战斗结束后延迟变回（秒）

-- WX-78 旋转电路：用斧/镐类工具触发的范围攻击
NPC_TUNING.WX78_SPIN_RADIUS        = 3   -- 命中半径
NPC_TUNING.WX78_SPIN_START_RANGE   = 3     -- 起手距离（用于战斗接近判定）
NPC_TUNING.WX78_SPIN_ATTACK_PERIOD = 0.8   -- NPC 旋转攻击最小间隔
NPC_TUNING.WX78_SPIN_DODGE_HIT_PERIOD = 0.5 -- 闪避旋转期间范围攻击间隔
NPC_TUNING.WX78_SPIN_DODGE_MIN_TIME = 1.0  -- 闪避旋转最短持续时间（秒）

-- WX-78 跳劈
NPC_TUNING.WX78_LEAP_DAMAGE        = 401   -- 落地范围伤害
NPC_TUNING.WX78_LEAP_RADIUS        = 6     -- 落地范围伤害半径
NPC_TUNING.WX78_LEAP_COOLDOWN      = 7    -- 技能冷却/释放间隔（秒）
NPC_TUNING.WX78_LEAP_TRIGGER_RANGE = 15     -- 触发距离：敌人在此范围内才考虑释放（格）
NPC_TUNING.WX78_LEAP_MIN_DIST      = 0     -- 最小跳跃距离：目标太近则不跳（格）
NPC_TUNING.WX78_LEAP_MAX_DIST      = 15     -- 最大跳跃距离：超出则跳到该方向最远可达点（格）
NPC_TUNING.WX78_LEAP_FX_SCALE      = nil    -- 落地电流范围特效缩放；nil=按半径自动(半径×0.375，半径6≈2.25)


-- ──────────────────────────────────────────────────────────
--  伯尼（Bernie）系统 — 薇洛专属战斗部署宠物
--  生命周期：背包(inactive) → 战斗丢出 → 大伯尼(big)战斗 → 缩小回收
-- ──────────────────────────────────────────────────────────
NPC_TUNING.BERNIE_DEPLOY_DELAY      = 2      -- 丢出后变大延迟（秒）
NPC_TUNING.BERNIE_DEACTIVATE_DELAY  = 32     -- 脱战后缩小延迟（秒）
NPC_TUNING.BERNIE_DEPLOY_COOLDOWN       = 30     -- 普通召回后重新部署冷却（秒）
NPC_TUNING.BERNIE_DEATH_DEPLOY_COOLDOWN = 480    -- 大伯尼死亡后重新部署冷却（秒8分钟）
NPC_TUNING.BERNIE_TELEPORT_DIST     = 40     -- 传送触发距离（格）
NPC_TUNING.BERNIE_TELEPORT_INTERVAL = 5      -- 传送检查频率（秒）
NPC_TUNING.BERNIE_TELEPORT_RADIUS   = 22     -- 传送落点半径（格）
NPC_TUNING.BERNIE_TAUNT_DIST        = 16     -- 嘲讽范围（格）
NPC_TUNING.BERNIE_TAUNT_PERIOD      = 2      -- 嘲讽周期（秒）
NPC_TUNING.BERNIE_RECOVERY_INTERVAL = 10     -- 背包无伯尼时，地面回收检查频率（秒）
NPC_TUNING.BERNIE_RECOVERY_DIST     = 50     -- 地面回收搜索范围（格）

-- 七彩萤火虫（薇洛制作）：玩家靠近不会熄灭
NPC_TUNING.RAINBOW_FIREFLIES_LIGHT_INTENSITY = 0.82 -- 不要太高，保留边缘渐变
NPC_TUNING.RAINBOW_FIREFLIES_LIGHT_RADIUS    = 2.8  -- 主光源范围，避免多个叠放后照亮整片环境
NPC_TUNING.RAINBOW_FIREFLIES_LIGHT_FALLOFF   = 0.75 -- 主光源衰减，数值越高边缘收得越快
NPC_TUNING.RAINBOW_FIREFLIES_FADEIN_TIME     = 1.5  -- 入夜淡入更慢，保留刚入夜的漂亮过渡
NPC_TUNING.RAINBOW_FIREFLIES_FADEOUT_TIME    = 0.8  -- 白天/收起后淡出时间（秒）
NPC_TUNING.RAINBOW_FIREFLIES_FUEL_VALUE      = TUNING.LARGE_FUEL -- 作为洞穴燃料的燃料值
NPC_TUNING.RAINBOW_FIREFLIES_RANDOM_COLOR = { -- 丢下时从 7 种高饱和、差异明显的颜色中随机固定一种
    { r = 1.00, g = 0.02, b = 0.00 }, -- 纯红
    { r = 0.00, g = 1.00, b = 1.00 }, -- 冰蓝
    { r = 1.00, g = 0.92, b = 0.00 }, -- 金黄
    { r = 0.00, g = 1.00, b = 0.02 }, -- 纯绿
    { r = 1.00, g = 0.18, b = 0.55 }, -- 粉
    { r = 0.55, g = 0.00, b = 1.00 }, -- 紫罗兰
    { r = 1.00, g = 0.00, b = 0.85 }, -- 品红
}

-- ──────────────────────────────────────────────────────────
--  薇洛纵火行为 — 空闲时随机点火
--  触发条件：游走/未跟随/无战斗时定期检查周围目标
--  目标优先级：NPC > 玩家 > 可燃物
-- ──────────────────────────────────────────────────────────
NPC_TUNING.ARSON_CHECK_INTERVAL  = 120    -- 检查间隔（秒）
NPC_TUNING.ARSON_SEARCH_RADIUS   = 12    -- 搜索半径（格）
NPC_TUNING.ARSON_CHASE_DIST      = 15    -- 追逐距离（格）
NPC_TUNING.ARSON_ACTION_RANGE    = 1.5   -- 点火执行距离（格）
NPC_TUNING.ARSON_FIRE_DURATION   = 3     -- 特殊火焰持续时间（秒）
NPC_TUNING.ARSON_COOLDOWN        = 120    -- 纵火冷却（秒）

-- ──────────────────────────────────────────────────────────
--  薇洛月焰（Lunar Fire）— 战斗中定期朝目标喷射月焰火浪
-- ──────────────────────────────────────────────────────────
NPC_TUNING.LUNARFIRE_COOLDOWN       = 18    -- 冷却（秒）
NPC_TUNING.LUNARFIRE_CHECK_INTERVAL = 1     -- 战斗中触发检查频率（秒）
NPC_TUNING.LUNARFIRE_TRIGGER_RANGE  = 6     -- 目标进入此范围即可喷射（格），无需贴身
NPC_TUNING.LUNARFIRE_RANGE          = 8     -- 喷火射程（格）
NPC_TUNING.LUNARFIRE_HALF_ANGLE     = 35    -- 喷火锥形半角（度），左右各此角度内命中
NPC_TUNING.LUNARFIRE_DURATION       = 5     -- 火焰喷射/伤害总时长（秒），火焰按此时长持续
NPC_TUNING.LUNARFIRE_CAST_TIME      = 2     -- 施法动画锁定时长（秒）：动画一结束即换回武器恢复战斗（应 ≤ DURATION）
NPC_TUNING.LUNARFIRE_TICK           = 0.5  -- 视觉/伤害结算间隔（秒）
NPC_TUNING.LUNARFIRE_DAMAGE         = TUNING.WILLOW_LUNAR_FIRE_DAMAGE or 20         -- 每跳普通伤害（默认）
NPC_TUNING.LUNARFIRE_PLANAR_DAMAGE  = TUNING.WILLOW_LUNAR_FIRE_PLANAR_DAMAGE or 30  -- 每跳位面伤害（默认）

-- 常驻火焰
NPC_TUNING.LUNARFIRE_BODY_SCALE     = 0.35  -- 火焰缩放
NPC_TUNING.LUNARFIRE_BODY_CHECK     = 2     -- 兜底检查频率（秒），事件未覆盖时自愈

-- 常驻火焰颜色自定义（默认深红）
--  BUILD：火焰贴图本体——"bernie_fire_fx"=橙黄(暖色,适合红/橙)；"bernie_fire_fx_lunar_build"=蓝色月焰
--  MULTCOLOUR：乘法染色 {r,g,b,a}，压暗/染色（第4位 a 为透明度，沿用 0.3）
--  ADDCOLOUR ：加法染色 {r,g,b,a}，叠加发光提亮某色（不需要可全 0）
--  LIGHT_*   ：投射光的颜色/半径/强度
NPC_TUNING.LUNARFIRE_BODY_BUILD        = "bernie_fire_fx"          -- 暖色底，便于染成红色
NPC_TUNING.LUNARFIRE_BODY_MULTCOLOUR   = { 0.6, 0.12, 0.08, 0.3 }  -- 深红（透明度 0.3 同原来）
NPC_TUNING.LUNARFIRE_BODY_ADDCOLOUR    = { 0.15, 0, 0, 0 }         -- 轻微加红，强化深红观感
NPC_TUNING.LUNARFIRE_BODY_LIGHT_COLOUR    = { 180 / 255, 25 / 255, 20 / 255 } -- 深红灯光
NPC_TUNING.LUNARFIRE_BODY_LIGHT_RADIUS    = 1.5
NPC_TUNING.LUNARFIRE_BODY_LIGHT_INTENSITY = 0.55

-- ──────────────────────────────────────────────────────────
--  薇克巴顿 — 被动光环
--  定期扫描周围：灭火、调温解湿
-- ──────────────────────────────────────────────────────────
NPC_TUNING.SCHOLAR_CARE_INTERVAL   = 5     -- 检查间隔（秒）
NPC_TUNING.SCHOLAR_CARE_RADIUS     = 20    -- 监视范围（格）
NPC_TUNING.SCHOLAR_GROWTH_RADIUS   = 20    -- 薇克巴顿催熟作物范围（格）
NPC_TUNING.SCHOLAR_GROWTH_STEPS    = 3     -- 每次读书推进的生长阶段数
NPC_TUNING.SCHOLAR_GROWTH_PURPLEGEM_BASE_COST = 1 -- 首次催熟消耗紫宝石数量
NPC_TUNING.SCHOLAR_GROWTH_PURPLEGEM_COST_STEP = 1 -- 每次成功催熟后，下次额外增加的紫宝石数量
NPC_TUNING.SCHOLAR_TEMP_TARGET     = 35    -- 体温归位目标值
NPC_TUNING.SCHOLAR_TEMP_THRESHOLD  = 20    -- 体温偏离阈值（与基准差值超此触发）
NPC_TUNING.SCHOLAR_MOISTURE_THRESHOLD = 30  -- 潮湿度阈值（超过此值才触发解湿，0~100）
NPC_TUNING.SCHOLAR_CARE_SAY_CD     = 2    -- 台词冷却（秒）

-- ──────────────────────────────────────────────────────────
--  薇克巴顿 — 战斗技能（蜂卫召唤 + 闪电轰击）
-- ──────────────────────────────────────────────────────────
NPC_TUNING.SCHOLAR_COMBAT_INTERVAL  = 15     -- 战斗检查间隔（秒）
NPC_TUNING.SCHOLAR_BEE_COUNT        = 4     -- 每次召唤蜂卫数量
NPC_TUNING.SCHOLAR_BEE_MAX          = 16    -- 蜂卫最大总数
NPC_TUNING.SCHOLAR_BEE_COOLDOWN     = 120   -- 蜂卫召唤冷却（秒）
NPC_TUNING.SCHOLAR_BEE_LIFETIME     = 120   -- 蜂卫存活时长（秒，超时自动死亡）
NPC_TUNING.SCHOLAR_LIGHTNING_COUNT   = 16    -- 闪电数量
NPC_TUNING.SCHOLAR_LIGHTNING_CD      = 90    -- 闪电冷却（秒）
NPC_TUNING.SCHOLAR_LIGHTNING_RADIUS  = 17    -- 闪电搜索半径（格）
NPC_TUNING.SCHOLAR_LIGHTNING_DAMAGE  = 101   -- 闪电对敌人基础伤害
NPC_TUNING.SCHOLAR_LIGHTNING_FRIENDLY_DMG = 0.1 -- 闪电对玩家/NPC的伤害
NPC_TUNING.SCHOLAR_LIGHTNING_HOSTILE_DMG = 10          -- 对敌对NPC（npc_hostile）的单次雷击伤害

-- ──────────────────────────────────────────────────────────
-- 沃尔特弹弓：目标超过最小距离时优先远程
-- ──────────────────────────────────────────────────────────
NPC_TUNING.DEBUG_WALTER = false                  -- 沃尔特行为调试开关（装弹、换弹、沃比生成等）
NPC_TUNING.WALTER_SLINGSHOT_MIN_DIST = 7         -- 弹弓最小远程距离（格，小于等于该距离改用近战）
NPC_TUNING.WALTER_SLINGSHOT_MAX_DIST = 14        -- 弹弓最远攻击距离（格，参考原版弹弓最大距离）
NPC_TUNING.WALTER_RANGED_RETREAT_DIST = 7        -- 沃尔特近距有弹药且无仇恨时，先退到该距离外再远程
NPC_TUNING.WALTER_RANGED_RETREAT_AGGRO_RADIUS = 7 -- 检测周围仇恨沃尔特的敌人范围
NPC_TUNING.WALTER_STORY_FIRE_SEARCH_RADIUS = 20  -- 沃尔特自动讲故事搜索篝火范围（格）
NPC_TUNING.WALTER_STORY_SANITY_RADIUS = 20        -- 沃尔特讲故事回 san 生效范围
NPC_TUNING.WALTER_STORY_SANITY_PER_MIN = 20      -- 沃尔特讲故事基础回 san
NPC_TUNING.WALTER_STORY_TALK_VOLUME = 0.4        -- 沃尔特讲故事语音循环音量
NPC_TUNING.WALTER_STORY_AUTO_REPEAT_PER_NIGHT = true -- 自动讲故事夜晚内是否重复触发；true=开关开启时讲到天亮
NPC_TUNING.WALTER_STORY_SELF_AUDIENCE_MULT = 1.5 -- 讲故事者本人有听众时的基础倍率
NPC_TUNING.WALTER_STORY_SELF_AUDIENCE_BONUS = 0.05 -- 每多一名额外听众增加的倍率
NPC_TUNING.WALTER_STORY_SELF_AUDIENCE_MAX_EXTRA = 5 -- 额外听众倍率最多计算人数
NPC_TUNING.WALTER_NPC_WOBY_FOLLOW_MIN_DIST = 2   -- NPC 沃比跟随最小距离（格）
NPC_TUNING.WALTER_NPC_WOBY_FOLLOW_TARGET_DIST = 4 -- NPC 沃比跟随目标距离（格）
NPC_TUNING.WALTER_NPC_WOBY_FOLLOW_MAX_DIST = 6   -- NPC 沃比跟随最大距离（格，超过后追赶）


-- ═══════════════════════════════════════════════════════════════
--  物品栏 & UI
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.INVENTORY_SLOTS      = 8    -- 物品栏格数（默认值，可被 CHARACTER_STATS.inventory_slots 覆盖）
NPC_TUNING.TALKER_FONT_SIZE     = 30    -- 对话气泡字号
NPC_TUNING.TALKER_LINE_DURATION = 8     -- 对话气泡停留时长（秒）
NPC_TUNING.HOVER_UPDATE_DELAY   = 0.5   -- 悬停信息防抖更新间隔（秒）
NPC_TUNING.RESKIN_COOLDOWN = 0.5   -- 对同一 NPC 连续换肤的冷却时间（秒）

-- ═══════════════════════════════════════════════════════════════
--  对话 & 社交
-- ═══════════════════════════════════════════════════════════════
-- ChattyNode 说话间隔（delay, rand_delay, enter_delay, enter_rand_delay）
--  delay + rand(rand_delay) = 两句话之间的间隔
--  enter_delay + rand(enter_rand_delay) = 进入该行为后首次说话的延迟
NPC_TUNING.CHAT_COMBAT  = { 40, 55, 0, 0 }       -- 战斗：30~40 秒一句
NPC_TUNING.CHAT_WORK    = { 40, 55, 5, 10 }      -- 工作：15~35 秒一句，进入延迟 5~15 秒
NPC_TUNING.CHAT_FOLLOW  = { 40, 55, 0, 0 }        -- 跟随：15~35 秒一句
NPC_TUNING.CHAT_IDLE    = { 45, 60, 15, 20 }      -- 闲逛：30~45 秒一句，进入延迟 15~35 秒
NPC_TUNING.CHAT_IDLE_UNRECRUITED = { 45, 60, 5, 10 }  -- 未招募闲逛：20~25 秒一句，进入延迟 5~15 秒

-- NPC 互聊参数
NPC_TUNING.NPC_CHAT_CHECK_INTERVAL = 20  -- 互聊检查周期（秒）
NPC_TUNING.NPC_CHAT_COOLDOWN       = 50  -- 互聊冷却时间（秒）
NPC_TUNING.NPC_CHAT_SEARCH_RANGE   = 8   -- 搜索附近 NPC 的范围（格）
NPC_TUNING.NPC_CHAT_LOCK_DURATION  = 6   -- 互聊锁持续时间（秒，期间抑制 ChattyNode）
NPC_TUNING.NPC_CHAT_REPLY_DELAY    = { 3, 2 }  -- B 回应延迟 = [3] + rand([2])（秒）

-- ═══════════════════════════════════════════════════════════════
--  跟随 & 漫游
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.FOLLOW_MIN    = 0       -- 靠近领队后停步的最小距离（0=不后退）
NPC_TUNING.FOLLOW_TARGET = 3       -- 理想跟随距离（达到后停止追赶）
NPC_TUNING.FOLLOW_MAX    = 20      -- 超出此距离开始追赶
NPC_TUNING.WANDER_DIST      = 15        -- 闲逛最大半径（超出后跑回领队附近）
NPC_TUNING.WANDER_STEP_DIST = 4        -- 每次闲逛步距（越小每步走得越近）

-- 漫游子参数（控制闲逛节奏）
NPC_TUNING.WANDER_MIN_WALK_TIME  = 2    -- 每次闲逛最短步行时间（秒）
NPC_TUNING.WANDER_RAND_WALK_TIME = 2    -- 闲逛步行随机附加（秒）
NPC_TUNING.WANDER_MIN_WAIT_TIME  = 5    -- 闲逛原地等待最短时间（秒）
NPC_TUNING.WANDER_RAND_WAIT_TIME = 8    -- 闲逛等待随机附加（秒）

-- ═══════════════════════════════════════════════════════════════
--  卡住恢复参数
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.STUCK_CHECK_INTERVAL          = 0.5     -- 位移检测间隔（秒）
NPC_TUNING.STUCK_THRESHOLD               = 1.5     -- 从观测起点算N秒内无进展→判定卡住
NPC_TUNING.STUCK_PROGRESS_DIST_SQ        = 1.0     -- 判定为「有进展」的最小累积位移²
NPC_TUNING.STUCK_ESCAPE_DIST_SQ          = 2.25    -- 恢复成功的最小位移²
NPC_TUNING.STUCK_SIDESTEP_DIST           = 3       -- 侧向绕行基础距离（格）
NPC_TUNING.STUCK_HEAVY_STEP_DIST         = 1.5     -- 重物绕行基础距离（格）
NPC_TUNING.STUCK_SIDESTEP_TIMEOUT        = 2.0     -- 单侧尝试超时（秒）
NPC_TUNING.STUCK_GIVEUP_TIME             = 5.0     -- 总放弃时间（秒）

-- ═══════════════════════════════════════════════════════════════
--  战斗 AI
-- ═══════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────────────────────
--  追击 & 索敌
-- ──────────────────────────────────────────────────────────
NPC_TUNING.MAX_CHASE_TIME    = 10   -- 追击最长持续时间（秒）
NPC_TUNING.MAX_CHASE_DIST    = 20   -- 超出此距离放弃追击
NPC_TUNING.CHASE_RANGE       = 20   -- 索敌搜索半径
NPC_TUNING.NPC_ASSIST_RANGE  = 20   -- NPC 互助检测范围（格）
NPC_TUNING.RETARGET_INTERVAL = 0.5  -- 索敌检测间隔（秒）

-- ──────────────────────────────────────────────────────────
--  走位 Kiting（全部 KITE_* 参数）
-- ──────────────────────────────────────────────────────────
NPC_TUNING.KITE_DODGE_THRESHOLD = 0  -- 敌人冷却剩余低于此值时开始闪避（秒）
NPC_TUNING.KITE_DODGE_DIST      = 6    -- 默认闪避移动距离（格）
NPC_TUNING.KITE_SAFE_DIST       = 6    -- 默认安全距离（格）
NPC_TUNING.KITE_MAX_LEADER_DIST = 18   -- 闪避时与领队最大距离（超出则优先靠近领队）
NPC_TUNING.KITE_DODGE_TIMEOUT   = 2    -- 闪避最长时间（秒，防卡死）
NPC_TUNING.KITE_DODGE_DELAY     = 0    -- 默认延迟帧数
NPC_TUNING.KITE_COUNTER_DELAY   = 5    -- 默认收手延迟帧数
NPC_TUNING.KITE_OVERWHELM_COUNT = 5    -- 同时被 N 只以上怪物仇恨时放弃走位，站撸
NPC_TUNING.KITE_OVERWHELM_SAY_CD = 30  -- 站撸台词冷却（秒）
NPC_TUNING.KITE_ORBIT_TIMEOUT   = 6    -- 绕圈闪避最长持续时间（秒）
NPC_TUNING.KITE_ORBIT_COOLDOWN  = 4    -- 绕圈完成后冷却时间（秒），期间不再触发新 orbit
NPC_TUNING.KITE_SNARE_ESCAPE_DELAY       = 0.4     -- 被困后延迟多久开始逃脱（秒）
NPC_TUNING.KITE_NEED_SPEED_SAY_CD        = 60      -- "需要加速"台词冷却（秒）
NPC_TUNING.KITE_ORBIT_RADIUS             = 10      -- 绕圈闪避半径（格）
NPC_TUNING.KITE_FIRE_DETECT_RADIUS       = 8       -- 火焰检测半径（格）
NPC_TUNING.KITE_FIRE_SAFE_MARGIN         = 1.5     -- 火焰伤害范围外安全余量（格）
NPC_TUNING.KITE_FIRE_AVOID_WEIGHT        = 0.5     -- 火焰排斥在移动方向中的混合权重
NPC_TUNING.KITE_SNARE_ESCAPE_DIST        = 4       -- 传送到笼子外的距离（格）
NPC_TUNING.KITE_CAGE_AVOID_RADIUS        = 4.0     -- 月光尖刺排斥检测半径（格）
NPC_TUNING.KITE_CAGE_AVOID_WEIGHT        = 0.6     -- 尖刺绕行力在移动方向中的混合权重
NPC_TUNING.KITE_TRAP_DETECT_RADIUS       = 4.0     -- 陷阱检测半径（格）
NPC_TUNING.KITE_TRAP_AOE_RADIUS          = 3.0     -- 陷阱脉冲 AOE 半径（格）
NPC_TUNING.KITE_TRAP_AVOID_WEIGHT        = 0.65    -- 陷阱排斥在移动方向中的混合权重
NPC_TUNING.KITE_TRAP_SLOW_MULT           = 0.6     -- 进入陷阱 AOE 时的减速倍率
NPC_TUNING.KITE_TRAP_KO_PULSES           = 3       -- 累计脉冲次数阈值
NPC_TUNING.KITE_TRAP_PULSE_INTERVAL      = 0.8     -- 脉冲间隔（秒）
NPC_TUNING.KITE_TRAP_KO_TIME             = 3.0     -- 击倒持续时间（秒）

-- 未知生物保守闪避：默认关闭，避免运行时误判导致 NPC 乱跑。
NPC_TUNING.UNKNOWN_CREATURE_LEARNING_DODGE        = false  -- true=未知生物启用临时学习闪避
NPC_TUNING.UNKNOWN_CREATURE_DEBUG                 = false  -- 打印未知生物学习/闪避关键数据
NPC_TUNING.UNKNOWN_CREATURE_DEBUG_INTERVAL        = 2.5    -- 同类日志最短间隔（秒），防刷屏
NPC_TUNING.UNKNOWN_CREATURE_ATTACK_RANGE_FALLBACK = 3      -- 读不到攻击距离时的兜底
NPC_TUNING.UNKNOWN_CREATURE_DANGER_MARGIN         = 1.5    -- 攻击距离外额外危险余量
NPC_TUNING.UNKNOWN_CREATURE_SAFE_MARGIN           = 0      -- 在危险距离外额外多退多少；0=刚好退出攻击危险圈
NPC_TUNING.UNKNOWN_CREATURE_SAFE_DIST_MIN         = 3.5    -- 未知生物最小安全距离
NPC_TUNING.UNKNOWN_CREATURE_ATTACK_END_MARGIN     = 0.75   -- 攻击状态结束后，离攻击范围超过该值即可回头
NPC_TUNING.UNKNOWN_CREATURE_THREAT_SCAN_RADIUS    = 12     -- 多目标战斗中扫描未知远程威胁的半径
NPC_TUNING.UNKNOWN_CREATURE_RECENT_THREAT_TIME    = 6      -- 被未知生物打中后，持续关注它多久
NPC_TUNING.UNKNOWN_CREATURE_DODGE_DIST            = 4      -- 未知生物单次保守后撤距离
NPC_TUNING.UNKNOWN_CREATURE_DODGE_MIN_TIME        = 0.25   -- 至少移动多久，避免刚进闪避就退出
NPC_TUNING.UNKNOWN_CREATURE_DODGE_HOLD_TIME       = 0.75   -- 未达安全距离时最多维持多久
NPC_TUNING.UNKNOWN_CREATURE_DODGE_TIMEOUT         = 1.1    -- 防卡死超时
NPC_TUNING.UNKNOWN_CREATURE_ATTACK_REACT_DELAY    = 0.12   -- 看到 attack tag 后延迟响应，过滤瞬时误触
NPC_TUNING.UNKNOWN_CREATURE_LEARNED_LEAD_TIME     = 0.25   -- 学到命中时间后提前多少秒闪避
NPC_TUNING.UNKNOWN_CREATURE_LEARNED_LATE_GRACE    = 0.12   -- 已超过学习命中点多久后不再补闪，避免浪费反击窗口
NPC_TUNING.UNKNOWN_CREATURE_REACTION_BUFFER       = 0.08   -- 按移速反推闪避时间时额外预留反应时间
NPC_TUNING.UNKNOWN_CREATURE_PREDICT_WINDOW        = 0.2    -- 学习后基于攻击冷却的预判窗口
NPC_TUNING.UNKNOWN_CREATURE_LEARN_MAX_SAMPLES     = 8      -- 每个状态最多平滑多少次命中样本
NPC_TUNING.UNKNOWN_CREATURE_RUSH_SPEED            = 8      -- 未知冲锋速度阈值
NPC_TUNING.UNKNOWN_CREATURE_RUSH_EXTRA_RANGE      = 4      -- 冲锋额外检测距离
NPC_TUNING.UNKNOWN_CREATURE_RUSH_FACING_DEG       = 70     -- 朝向 NPC 的角度阈值

-- ──────────────────────────────────────────────────────────
--  低血量撤退治疗（战斗中自动吃饺子回血）
-- ──────────────────────────────────────────────────────────
NPC_TUNING.HEAL_LOW_THRESHOLD   = 0.3   -- 血量低于 30% 触发撤退
NPC_TUNING.HEAL_FULL_THRESHOLD  = 0.9   -- 血量恢复到 90% 以上回归战斗
NPC_TUNING.HEAL_RETREAT_DIST    = 12    -- 向领队方向撤退距离（格）
NPC_TUNING.HEAL_SAFE_DIST       = 5     -- 吃东西时与敌人保持的安全距离（格）
NPC_TUNING.HEAL_FLEE_DIST       = 12    -- 敌人闯入安全距离时逃跑距离（格）
NPC_TUNING.HEAL_EAT_INTERVAL    = 0.5   -- 每次吃饺子的间隔（秒）
NPC_TUNING.HEAL_FOOD_PREFAB     = "perogies"  -- 治疗用食物 prefab（饺子）

-- ──────────────────────────────────────────────────────────
--  敌对NPC（Webber）参数
-- ──────────────────────────────────────────────────────────
-- 基础战斗
NPC_TUNING.HOSTILE_WEBBER_RUN_SPEED        = 6      -- 移动速度
NPC_TUNING.HOSTILE_WEBBER_ATTACK_PERIOD    = 0.6    -- 攻击间隔（秒）
NPC_TUNING.HOSTILE_WEBBER_ATTACK_RANGE     = 3      -- 攻击距离（格）
NPC_TUNING.HOSTILE_WEBBER_HITSTUN_TIME     = 0      -- 受击僵直保护时长（秒）

-- 闪避与预判
NPC_TUNING.HOSTILE_WEBBER_DODGE_COOLDOWN   = 1.5    -- 闪避冷却（秒）
NPC_TUNING.HOSTILE_WEBBER_DODGE_DIST       = 4      -- 闪避位移距离（格）
NPC_TUNING.HOSTILE_WEBBER_DODGE_MELEE_ONLY = true   -- 仅闪近战，不闪远程
NPC_TUNING.HOSTILE_WEBBER_MELEE_THREAT_DIST = 3.5   -- 近战威胁判定距离（格）
NPC_TUNING.HOSTILE_WEBBER_PREDODGE_ENABLE  = true   -- 是否启用攻击前摇预判闪避
NPC_TUNING.HOSTILE_WEBBER_PREDODGE_RANGE   = 3      -- 预判扫描半径（格）
NPC_TUNING.HOSTILE_WEBBER_PREDODGE_PERIOD  = 0.02   -- 预判扫描周期（秒）
NPC_TUNING.HOSTILE_WEBBER_DODGE_STUCK_CHECK_1 = 0.05 -- 第一次移动检查时刻（秒）
NPC_TUNING.HOSTILE_WEBBER_DODGE_STUCK_CHECK_2 = 0.20 -- 第二次移动检查时刻（秒）

-- 追击与回圈
NPC_TUNING.HOSTILE_WEBBER_AGGRO_RANGE      = 12     -- 仇恨触发半径（格）
NPC_TUNING.HOSTILE_WEBBER_CHASE_RANGE      = 20     -- 追击范围（格）
NPC_TUNING.HOSTILE_WEBBER_RECHASE_LOCK     = 3      -- 超距放弃后再次索敌锁定时长（秒）
NPC_TUNING.HOSTILE_WEBBER_OVERLEASH_TELEPORT_DIST = 8   -- 越界后向中心点单次传送距离（格）
NPC_TUNING.HOSTILE_WEBBER_OVERLEASH_TELEPORT_CD   = 1.5 -- 越界传送冷却（秒）

-- 生成与死亡
NPC_TUNING.HOSTILE_WEBBER_GHOST_DESPAWN_DELAY = 8    -- 死亡成幽灵后自动消散时间（秒）
NPC_TUNING.HOSTILE_WEBBER_RESPAWN_CD          = 960  -- 死亡后再次可从蜘蛛巢刷新CD（秒）
NPC_TUNING.HOSTILE_WEBBER_DEN_SURFACE_ONLY    = true -- 仅地面蜘蛛巢可触发生成（地下不生成）
NPC_TUNING.HOSTILE_WEBBER_DEN_MIN_STAGE       = 2    -- 仅蜘蛛巢2级及以上可触发生成
NPC_TUNING.HOSTILE_WEBBER_DEN_MAX_STAGE       = 3    -- 蜘蛛巢最大触发等级
NPC_TUNING.HOSTILE_WEBBER_DEN_SPAWN_CHANCE    = 0.2  -- 攻击蜘蛛巢时刷出概率（0~1）

-- 调试
NPC_TUNING.HOSTILE_WEBBER_EQUIP_DEBUG = false  -- 初始装备调试（true=打印装备校正日志）
NPC_TUNING.HOSTILE_WEBBER_DODGE_DEBUG = false  -- 闪避关键帧调试日志（true=开启）

-- ──────────────────────────────────────────────────────────
--  敌对NPC（Wurt）参数
-- ──────────────────────────────────────────────────────────
-- 基础战斗
NPC_TUNING.HOSTILE_WURT_RUN_SPEED        = 6      -- 移动速度
NPC_TUNING.HOSTILE_WURT_ATTACK_PERIOD    = 0.6    -- 攻击间隔（秒）
NPC_TUNING.HOSTILE_WURT_ATTACK_RANGE     = 3      -- 攻击距离（格）
NPC_TUNING.HOSTILE_WURT_HITSTUN_TIME     = 0      -- 受击僵直保护时长（秒）

-- 闪避与预判
NPC_TUNING.HOSTILE_WURT_DODGE_COOLDOWN   = 1.5    -- 闪避冷却（秒）
NPC_TUNING.HOSTILE_WURT_DODGE_DIST       = 4      -- 闪避位移距离（格）
NPC_TUNING.HOSTILE_WURT_DODGE_MELEE_ONLY = true   -- 仅闪近战，不闪远程
NPC_TUNING.HOSTILE_WURT_MELEE_THREAT_DIST = 3.5   -- 近战威胁判定距离（格）
NPC_TUNING.HOSTILE_WURT_PREDODGE_ENABLE  = true   -- 是否启用攻击前摇预判闪避
NPC_TUNING.HOSTILE_WURT_PREDODGE_RANGE   = 3      -- 预判扫描半径（格）
NPC_TUNING.HOSTILE_WURT_PREDODGE_PERIOD  = 0.02   -- 预判扫描周期（秒）
NPC_TUNING.HOSTILE_WURT_DODGE_STUCK_CHECK_1 = 0.05 -- 第一次移动检查时刻（秒）
NPC_TUNING.HOSTILE_WURT_DODGE_STUCK_CHECK_2 = 0.20 -- 第二次移动检查时刻（秒）

-- 追击与回圈
NPC_TUNING.HOSTILE_WURT_AGGRO_RANGE      = 12     -- 仇恨触发半径（格）
NPC_TUNING.HOSTILE_WURT_CHASE_RANGE      = 25     -- 追击范围（格）
NPC_TUNING.HOSTILE_WURT_RECHASE_LOCK     = 3      -- 超距放弃后再次索敌锁定时长（秒）
NPC_TUNING.HOSTILE_WURT_OVERLEASH_TELEPORT_DIST = 8   -- 越界后向中心点单次传送距离（格）
NPC_TUNING.HOSTILE_WURT_OVERLEASH_TELEPORT_CD   = 1.5 -- 越界传送冷却（秒）

-- 生成与死亡
NPC_TUNING.HOSTILE_WURT_GHOST_DESPAWN_DELAY = 8   -- 死亡成幽灵后自动消散时间（秒）
NPC_TUNING.HOSTILE_WURT_RESPAWN_CD          = 960  -- 死亡后再次刷新CD（秒）
NPC_TUNING.HOSTILE_WURT_HOUSE_SPAWN_CHANCE  = 1   -- 自动刷新概率（0~1）

-- 调试
NPC_TUNING.HOSTILE_WURT_DODGE_DEBUG = false  -- 闪避关键帧调试日志（true=开启）

-- 沃特专属战斗技能
NPC_TUNING.HOSTILE_WURT_DODGE_TELEPORT_CHANCE = 0.3   -- 每次闪避时改为懒人法杖传送的概率（0~1）
NPC_TUNING.HOSTILE_WURT_DODGE_TELEPORT_DIST   = 7     -- 传送时朝 home 方向位移的距离（格）
NPC_TUNING.HOSTILE_WURT_SPECIAL_ACTIONS = {
    { action = "waterballoon", weight = 50 },  -- 丢水球（弄湿目标）
    { action = "tornado",      weight = 50 },  -- 风向标龙卷风
}
-- 连续打空触发：攻击被对方连续躲掉(onmissother) N 次后，下次攻击改为释放特殊技能
NPC_TUNING.HOSTILE_WURT_MISS_TRIGGER_COUNT = 3
NPC_TUNING.HOSTILE_WURT_TORNADO_CAST_DELAY = 0.5      -- （保留）即时兜底释放用
-- 风向标龙卷风分三段，全程行为树不介入(由 wurt_casting 状态标签保护)：
NPC_TUNING.HOSTILE_WURT_TORNADO_EQUIP_DELAY    = 0.5
NPC_TUNING.HOSTILE_WURT_TORNADO_SWAPBACK_DELAY = 0.4
NPC_TUNING.HOSTILE_WURT_WATERBALLOON_FREEZE_TIME   = 4    -- 命中后冰冻时长（秒）
NPC_TUNING.HOSTILE_WURT_WATERBALLOON_FREEZE_RADIUS = 4  -- 命中点冰冻波及范围（格）

-- ═══════════════════════════════════════════════════════════════
--  战斗数据
-- ═══════════════════════════════════════════════════════════════
local COMBAT_DATA = require("npc_combat_data")
NPC_TUNING.CREATURE_ATTACK_DATA = COMBAT_DATA.CREATURE_ATTACK_DATA
NPC_TUNING.BOSS_ALLIES          = COMBAT_DATA.BOSS_ALLIES
NPC_TUNING.BOSS_KILL_ORDER      = COMBAT_DATA.BOSS_KILL_ORDER
NPC_TUNING.ALLY_TO_BOSS         = COMBAT_DATA.ALLY_TO_BOSS
NPC_TUNING.BOSS_DETECTABLE      = COMBAT_DATA.BOSS_DETECTABLE
NPC_TUNING.DODGE_IMMUNE_PREFABS = COMBAT_DATA.DODGE_IMMUNE_PREFABS

-- ═══════════════════════════════════════════════════════════════
--  工作行为 — 砍树
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.CHOP_SEE_DIST          = 20     -- ChopHere搜索可砍树木的半径（格）
NPC_TUNING.CHOP_KEEP_DIST         = 20     -- 持续砍树的最大脱离距离（超出停止工作）
NPC_TUNING.CHOP_SCAN_INTERVAL     = 1      -- ChopHere扫描间隔（秒）
NPC_TUNING.CHOP_APPROACH_DIST     = 1.5    -- 砍树接近距离（格）
NPC_TUNING.CHOP_MAX_WAIT          = 15     -- 单棵树砍树超时（秒）
NPC_TUNING.CHOP_SAY_COOLDOWN      = 15     -- 砍树台词冷却（秒）
NPC_TUNING.CHOP_RESERVE_TIMEOUT   = 8      -- 多个可砍目标时的目标预留超时（秒）
NPC_TUNING.CHOP_DETECT_RANGE      = 15     -- 检测 leader 附近可砍目标的范围（触发砍树窗口）
NPC_TUNING.CHOP_WINDOW            = 20      -- 砍树跟随窗口持续时间（秒，玩家停手后续航并收敛）

-- ═══════════════════════════════════════════════════════════════
--  工作行为 — 挖矿
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.MINE_SEE_DIST  = 20     -- 搜索可挖矿石的半径
NPC_TUNING.MINE_KEEP_DIST = 20     -- 持续挖矿的最大脱离距离
NPC_TUNING.MINE_SPEED     = 1      -- 挖矿速度倍率
NPC_TUNING.MINE_RESERVE_TIMEOUT = 8 -- 多个可挖目标时的目标预留超时（秒）
NPC_TUNING.MINE_DETECT_RANGE  = 15 -- 检测 leader 附近可挖目标的范围（触发挖矿窗口）
NPC_TUNING.MINE_WINDOW        = 20  -- 挖矿跟随窗口持续时间（秒，玩家停手后续航并收敛）

-- ═══════════════════════════════════════════════════════════════
--  工作行为 — 采集
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.PICK_SEE_DIST       = 22    -- 搜索可采集物的半径
NPC_TUNING.PICK_KEEP_DIST      = 22    -- 持续采集的最大脱离距离
NPC_TUNING.PICK_DETECT_RANGE   = 15     -- 检测 leader 附近可采集物的范围（触发采集条件）
NPC_TUNING.PICK_WINDOW         = 15    -- 采集窗口持续时间（秒）
NPC_TUNING.PICK_ACTION_TIMEOUT = 1     -- 采集动作耗时（秒）
NPC_TUNING.PICK_SPEED          = 1     -- 采集速度倍率
NPC_TUNING.PICK_RESERVE_TIMEOUT = 5    -- 采集目标预留超时（秒），防止多个NPC走向同一目标

-- ═══════════════════════════════════════════════════════════════
--  工作行为 — 钓鱼
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.FISHING_SEE_DIST      = 9999    -- 搜索池塘距离
NPC_TUNING.FISHING_APPROACH_DIST = 3       -- 靠近池塘触发距离
NPC_TUNING.FISHING_WAIT_MIN      = 20       -- 等待咬钩最短秒数
NPC_TUNING.FISHING_WAIT_MAX      = 25       -- 等待咬钩最长秒数
NPC_TUNING.FISHING_MAX_CATCH     = 3       -- 行为最大上钩数
NPC_TUNING.FISHING_MAX_CATCH_MIN = 1       -- 最大钓鱼次数最小值（Spinner 下限）
NPC_TUNING.FISHING_MAX_CATCH_MAX = 9      -- 最大钓鱼次数最大值（Spinner 上限）
NPC_TUNING.FISHING_DEPOSIT_RADIUS = 12      -- 钓鱼存放点搜索半径（格）
NPC_TUNING.FISHING_DEPOSIT_POS = nil        -- {x=number, z=number}，由 RPC 动态设置
NPC_TUNING.FISHING_MIN_FISH      = 1       -- 池塘最少需要的鱼数
NPC_TUNING.FISHING_SCAN_INTERVAL = 2       -- 搜索池塘间隔秒数
NPC_TUNING.CHAT_FISHING          = {40, 55, 5, 10}  -- 钓鱼台词间隔参数

-- ═══════════════════════════════════════════════════════════════
--  工作行为 — 海钓
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.OCEAN_FISHING_SHORE_SEARCH_DIST = 30    -- 搜索岸边最大距离（格）
NPC_TUNING.OCEAN_FISHING_CAST_DIST_MIN     = 6     -- 投竿最小距离
NPC_TUNING.OCEAN_FISHING_CAST_DIST_MAX     = 12    -- 投竿最大距离
NPC_TUNING.OCEAN_FISHING_REEL_TIMEOUT      = 100    -- 单次收竿超时（秒）
NPC_TUNING.OCEAN_FISHING_CAST_TIMEOUT      = 10    -- 投竿后等待浮标着水超时（秒）
NPC_TUNING.OCEAN_FISHING_MAX_CATCH         = 3     -- 单次最大捕获数（默认值）
NPC_TUNING.OCEAN_FISHING_MURDER_FISH       = true  -- 是否杀鱼（默认开启）
NPC_TUNING.OCEAN_FISHING_MAX_CATCH_MIN     = 1     -- 最大钓鱼次数最小值（Spinner 下限）
NPC_TUNING.OCEAN_FISHING_MAX_CATCH_MAX     = 5     -- 最大钓鱼次数最大值（Spinner 上限）
NPC_TUNING.OCEAN_FISHING_DEPOSIT_RADIUS    = 12    -- 海钓存放点搜索半径（格）
NPC_TUNING.OCEAN_FISHING_DEPOSIT_POS       = nil   -- 存放点坐标，由 RPC 动态设置
NPC_TUNING.DEBUG_OCEAN_FISHING             = false   -- 海钓调试日志开关
NPC_TUNING.OCEAN_FISHING_CAST_STUCK_TIMEOUT = 2.0   -- cast 阶段若仍残留 npc_oceanfishing_idle 状态超过该秒数，强制清理（防打招呼/重连后卡在海钓动画）

-- 海钓空钩 NPC 专用增强倍率
-- 原始空钩: charm=0.1, 鱼类偏好=0.25, 最终=0.025（极低）
NPC_TUNING.OCEAN_FISHING_NPC_HOOK_CHARM_MULT = 3

-- 海钓岸边鱼群检测参数
NPC_TUNING.OCEAN_FISHING_FISH_DETECT_RADIUS = 20    -- 鱼群检测半径
NPC_TUNING.OCEAN_FISHING_FISH_WEIGHT = 10            -- 鱼群数量评分权重
NPC_TUNING.OCEAN_FISHING_DIST_WEIGHT = 1             -- 距离评分权重
NPC_TUNING.OCEAN_FISHING_HOOK_TIMEOUT = 100          -- 等待咬钩超时（秒）
NPC_TUNING.OCEAN_FISHING_CAST_SAFE_OFFSET = 6         -- 投竿目标从岸线外推安全距离（格）

NPC_TUNING.OCEAN_FISHING_SIMPLE_SHORE_ONLY = true   -- 只找岸边，不做鱼群评分
NPC_TUNING.OCEAN_FISHING_AUTO_CHUM = true           -- 到岸自动刷 chum_aoe
NPC_TUNING.OCEAN_FISHING_AUTO_CHUM_CD = 25          -- 自动刷鱼食冷却（秒）
NPC_TUNING.OCEAN_FISHING_AUTO_CHUM_DIST_MIN = 4     -- 鱼食点：朝海最小距离
NPC_TUNING.OCEAN_FISHING_AUTO_CHUM_DIST_MAX = 8     -- 鱼食点：朝海最大距离
NPC_TUNING.OCEAN_FISHING_CAST_RETRY_ON_BADCAST = 2  -- badcast 连续重试次数
NPC_TUNING.OCEAN_FISHING_FORCE_BITE_DELAY = 60       -- 强制上钩最短等待（秒）
NPC_TUNING.OCEAN_FISHING_FORCE_BITE_STRICT_DELAY = true -- 严格延迟：true=自然咬钩也要等到 FORCE_BITE_DELAY 后才收线
NPC_TUNING.OCEAN_FISHING_FORCE_BITE_STRICT_REEL_TICK = 1.0 -- 严格延迟期间保活收线间隔（秒，防 linetooloose）
NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_STOP_DIST = 2 -- 鱼靠近到该距离后停止强制牵引，转为自然游动
NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_FREE_SWIM_DIST = 5 -- 进入自由游动区（不再强制跟钩）
NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_REENGAGE_DIST = 7 -- 超出该距离才重新进行引导（形成自然缓冲带）
NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_PER_FISH_CD = 2.2 -- 同一条鱼两次引导的最小间隔（秒）
NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_CHANCE = 0.35 -- 每次刷新时触发引导概率（越小越自然）
NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_MAX_PER_TICK = 3 -- 每次最多引导鱼数量
NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_INTEREST_BOOST = 1 -- 每次兴趣提升次数（越小越自然）

-- ──────────────────────────────────────────────────────────
--  工作行为 — 通用
-- ──────────────────────────────────────────────────────────
NPC_TUNING.NO_TOOL_SAY_COOLDOWN = 30   -- "没有工具"提示冷却时间（秒）

-- ═══════════════════════════════════════════════════════════════
--  种植/农场参数 — 核心参数
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.FARM_WORK_RADIUS        = 17    -- 工作范围（种植/采集/清理/外部农场搜索 共用，格）
NPC_TUNING.FARM_WORK_RADIUS_DISPLAY = NPC_TUNING.FARM_WORK_RADIUS -- UI显示半径（不参与自动修正）
NPC_TUNING.WORMWOOD_CROP_DEPOSIT_RADIUS = 8   -- 植物人作物存放点范围显示半径（格）
NPC_TUNING.WORMWOOD_TRASH_DEPOSIT_RADIUS = 6  -- 植物人垃圾存放点范围显示半径（格）
NPC_TUNING.FARM_CLEANUP_THROW_DIST = 16    -- 杂物丢弃距离（格）
NPC_TUNING.FARM_WEED_CHECK_RANGE   = 15    -- 杂草/地面物品检测范围（格）
NPC_TUNING.FARM_CLEANUP_SOIL_TOLERANCE = 1.5 -- 清理垃圾时农田地皮判定外扩距离（格）
NPC_TUNING.NPC_DROP_COOLDOWN       = 60    -- 丢弃后冷却时间（秒，防捡丢循环）
NPC_TUNING.FARM_GRID_SPACING       = 1.7   -- 种植点间距（格）
NPC_TUNING.FARM_GRID_SIZE          = 2     -- 网格大小（2x2）
NPC_TUNING.FARM_CONTAINER_SCAN_RADIUS = 30  -- 收获物存储：农场范围内容器搜索半径（格）

-- ═══════════════════════════════════════════════════════════════
--  种植/农场参数 — 自动推导参数
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.FARM_OVERSIZED_SCAN_RADIUS  = NPC_TUNING.FARM_WORK_RADIUS        -- 巨大作物扫描范围 = 工作范围
NPC_TUNING.FARM_ENTITY_RADIUS          = NPC_TUNING.FARM_WEED_CHECK_RANGE   -- 犁地机/掉落物搜索 = 检测范围
NPC_TUNING.FARM_RETURN_DIST            = math.ceil(NPC_TUNING.FARM_WORK_RADIUS * 0.7)  -- 返回农场距离
NPC_TUNING.FARM_CLEANUP_CARRY_MIN      = math.ceil(NPC_TUNING.FARM_CLEANUP_THROW_DIST * 0.5) -- 重物最小搬运距离
NPC_TUNING.FARM_CLEANUP_CARRY_MAX      = NPC_TUNING.FARM_CLEANUP_THROW_DIST -- 重物最大搬运距离

-- ═══════════════════════════════════════════════════════════════
--  种植/农场参数 — 内部固定参数
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.FARM_SEARCH_MIN_DIST    = 15    -- 选址最近距离
NPC_TUNING.FARM_SEARCH_MAX_DIST    = 200   -- 选址最远距离
NPC_TUNING.FARM_SEARCH_ATTEMPTS    = 100   -- 选址搜索方向数
NPC_TUNING.FARM_PLOW_WAIT_MAX      = 40    -- 犁地机超时
NPC_TUNING.FARM_PLANT_COOLDOWN     = 1     -- 播种冷却
NPC_TUNING.FARM_TEND_COOLDOWN      = 30    -- 照料冷却
NPC_TUNING.FARM_CHECK_INTERVAL     = 5     -- 刷新间隔
NPC_TUNING.FARM_WATER_COOLDOWN     = 120   -- 浇水冷却
NPC_TUNING.FARM_ACTION_DIST        = 1.5   -- 通用到达距离
NPC_TUNING.FARM_DROP_DIST          = 2.0   -- 丢弃到位距离
NPC_TUNING.FARM_MIN_SOIL_COUNT     = NPC_TUNING.FARM_GRID_SIZE * NPC_TUNING.FARM_GRID_SIZE  -- 选址最低可种植点（=网格总点数）
NPC_TUNING.FARM_SPOT_RADIUS        = 0.8   -- 种植点搜索半径
NPC_TUNING.FARM_BLOCKER_RADIUS     = 3     -- 阻挡物检测半径
NPC_TUNING.FARM_SOIL_CLEANUP_RADIUS = 4    -- 犁后清理范围（从8降为4）
NPC_TUNING.FARM_SLAP_CHASE_RANGE    = 15   -- 击飞追击范围（距farm_center，格）
NPC_TUNING.SLAP_KNOCKBACK_RADIUS    = 8    -- 击飞击退力度
NPC_TUNING.SLAP_CHASE_SPEED_BONUS   = 5    -- 击飞追击临时加速（平加运动速度）

-- ═══════════════════════════════════════════════════════════════
--  种植/农场参数 — 行为距离与超时
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.FARM_CENTER_DIST              = 3.0     -- 中心到达距离（格）
NPC_TUNING.FARM_PLANT_DIST               = 1.5     -- 播种到位距离（格）
NPC_TUNING.FARM_CONTAINER_DIST           = 2.0     -- 容器接近距离（格）
NPC_TUNING.FARM_HEAVY_TIMEOUT            = 15      -- 重物搬运超时（秒）
NPC_TUNING.FARM_TRASH_TIMEOUT            = 8       -- 垃圾丢弃超时（秒）
NPC_TUNING.FARM_NO_TOOL_IDLE             = 10      -- 缺工具冷却（秒）
NPC_TUNING.FARM_IDLE_WAIT                = 5       -- 无事可做冷却（秒）

-- NPC 建造系统（农场配套）
NPC_TUNING.BUILD_LIGHT_CHECK_RADIUS  = 15    -- 检查照明的半径（格）
NPC_TUNING.BUILD_FIREPIT_OFFSET      = 5     -- 火坑距农场中心的偏移距离（格）
NPC_TUNING.BUILD_FIREPIT_MIN_SPACING = 2.5   -- 火坑最小间距
NPC_TUNING.BUILD_FIREPIT_FUEL_ADD    = 90    -- 每次加燃料值（≈ MED_FUEL*2，对齐 bonusmult=2）
NPC_TUNING.BUILD_FIREPIT_FUEL_LOW    = 0.25  -- 燃料低于此比例时补充

-- ═══════════════════════════════════════════════════════════════
--  烹饪 & 大厨系统
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.COOK_LEASH_RETURN_DIST = 5   -- 栓绳回位触发距离（格）
NPC_TUNING.COOK_INTERVAL         = 2   --  两次做饭最小间隔（秒）
NPC_TUNING.COOK_SAME_DISH_MAX    = 3   --  同菜超此数量降权
NPC_TUNING.COOK_APPROACH_DIST    = 1.5  -- 接近锅/容器距离（格）
NPC_TUNING.COOK_MAX_WAIT         = 120  -- 等锅最长时间（秒，超时放弃）
NPC_TUNING.COOK_BUFF_CHANCE      = 0.2  -- 出锅食物获得随机buff的概率（20%）
NPC_TUNING.COOKING_SAY_COOLDOWN  = 15   -- 烹饪台词默认冷却时间（秒）
NPC_TUNING.COOK_RANGE_MIN        = 10    -- 厨师工作范围最小值（格）
NPC_TUNING.COOK_RANGE_MAX        = 30   -- 厨师工作范围最大值（格）

-- 烹饪黑名单统一配置（维护入口）
-- 1) COOK_INGREDIENT_BLACKLIST: 不会被当作烹饪食材扫描
-- 2) COOK_RECIPE_BLACKLIST: 即使可做也不会进入做菜计划；若锅里已有此类成品会被吃掉而不是入库
NPC_TUNING.COOK_INGREDIENT_BLACKLIST = {
    mandrake = true,          -- 曼德拉草
    glommerfuel = true,       -- 格罗姆粘液
    log = true,               -- 木头
    rot = true,               -- 腐烂物
    spoiled_food = true,      -- 腐烂的食物
    spoiled_fish = true,      -- 腐烂的鱼
    spoiled_fish_small = true,-- 腐烂的小鱼
    rottenegg = true,         -- 臭蛋
    wetgoop = true,           -- 失败料理
    monsterlasagna = true,    -- 有害料理
    gears = true,             -- 齿轮
}

NPC_TUNING.COOK_RECIPE_BLACKLIST = {
    wetgoop = true,         -- 失败
    monsterlasagna = true,  -- 负面效果
    powcake = true,         -- -3血 0饱食
    monstertartare = true,  -- 负面效果
    shroombait = true,      -- 负面效果：-8血 -15理智，催眠
    beefalofeed = true,     
    beefalotreat = true,    
    jammypreserves = true,  -- 果酱：低价值食物
    ratatouille = true,     -- 蔬菜杂烩：低价值食物
}

-- 大厨前往农场行为
NPC_TUNING.CHEF_FARM_SEARCH_INTERVAL = 5    -- 搜索间隔（秒）
NPC_TUNING.CHEF_FARM_SEARCH_RANGE    = 100  -- 搜索范围（格）
NPC_TUNING.CHEF_FARM_NEAR_MIN        = 9    -- 目标距农场最近（格）
NPC_TUNING.CHEF_FARM_NEAR_MAX        = 11   -- 目标距农场最远（格）
NPC_TUNING.CHEF_STRUCT_SPACING       = 1.5  -- 大厨工作站结构间距（格）
NPC_TUNING.CHEF_CROP_SCAN_RANGE      = 35   -- 巨大作物搜索范围（格，以农场为中心）
NPC_TUNING.CHEF_CROP_SCAN_INTERVAL   = 8    -- 巨大作物搜索间隔（秒）
NPC_TUNING.CHEF_CLEAR_OBSTACLE_RADIUS = 15  -- 清障扫描半径（格，以工作站中心为圆心）
NPC_TUNING.CHEF_OBSTACLE_APPROACH_DIST = 1 -- 砍树/挖掘接近距离（格）
NPC_TUNING.CHEF_PATROL_RADIUS        = 40   -- 建成后定期巡逻捡物半径（格）
NPC_TUNING.CHEF_PATROL_INTERVAL      = 10    -- 巡逻捡物间隔（秒）
NPC_TUNING.CHEF_CONTAINER_APPROACH_DIST = 1 -- NPC 接近箱子/冰箱的到达距离（格）
NPC_TUNING.CHEF_NPC_DROP_COOLDOWN       = 60    -- NPC 丢弃物品冷却（秒），防止捡-丢循环
NPC_TUNING.CHEF_EMPTY_PLAN_COOLDOWN     = 300   -- 空计划冷却（秒），防止反复空转
NPC_TUNING.CHEF_CAPACITY_CACHE_TTL      = 3     -- 容器容量缓存有效期（秒）
NPC_TUNING.CHEF_STORE_RETRY_INTERVAL    = 30    -- 容器全满时重试存放间隔（秒）

-- ═══════════════════════════════════════════════════════════════
--  整理/清洁参数
-- ═══════════════════════════════════════════════════════════════

-- 韦斯清洁工行为
NPC_TUNING.WES_RANGE_MIN        = 10   -- 韦斯工作范围最小值（格）
NPC_TUNING.WES_RANGE_MAX        = 30   -- 韦斯工作范围最大值（格）
NPC_TUNING.WES_PATROL_RADIUS    = 30   -- 韦斯清理巡逻半径（格，基于farm_center）
NPC_TUNING.WES_PATROL_INTERVAL  = 6    -- 巡逻扫描间隔（秒）
NPC_TUNING.WES_FARM_SEARCH_INTERVAL = 10 -- 搜索植物人农场中心的间隔（秒）
NPC_TUNING.WES_ORGANIZE_INTERVAL = 15 -- 韦斯容器整理检测间隔（秒）

-- 薇诺娜清洁工行为
NPC_TUNING.WINONA_RANGE_MIN     = 10   -- 薇诺娜工作范围最小值（格）
NPC_TUNING.WINONA_RANGE_MAX     = 50   -- 薇诺娜工作范围最大值（格）
NPC_TUNING.WINONA_PATROL_RADIUS    = 50   -- 薇诺娜清理巡逻半径（格，基于farm_center）
NPC_TUNING.WINONA_PATROL_INTERVAL  = 6    -- 巡逻扫描间隔（秒）
NPC_TUNING.WINONA_FARM_SEARCH_INTERVAL = 10 -- 搜索植物人农场中心的间隔（秒）
NPC_TUNING.WINONA_ORGANIZE_INTERVAL = 15 -- 薇诺娜容器整理检测间隔（秒）
NPC_TUNING.WINONA_AUTO_FIND_FARM_CENTER = false -- false=不自动接管工作，仅手动点"在此整理"后工作

-- ═══════════════════════════════════════════════════════════════
--  容器 & 物品管理
-- ═══════════════════════════════════════════════════════════════
-- 容器清理（定期清除冰箱/箱子中的腐烂物品）
NPC_TUNING.CONTAINER_CLEAN_INTERVAL = 30  -- 容器清理扫描间隔（秒）
NPC_TUNING.SPOILED_FOOD_MAX_STACKS  = 5   -- 腐烂物保留上限（组数），超过则删除

-- 周边容器扫描（使用世界中玩家放置的冰箱/箱子作为额外存储）
NPC_TUNING.NEARBY_CONTAINER_SCAN_RADIUS = 40  -- 周边容器搜索半径（格）

-- 冰箱存储失败容错
NPC_TUNING.ICEBOX_STORE_FAIL_MAX = 3   -- 同一 prefab 连续存冰箱失败 N 次后自动转存箱子

-- 捡物行为参数
NPC_TUNING.COLLECT_DEFAULT_SCAN_INTERVAL = 6  -- 捡物检查默认间隔（秒）
NPC_TUNING.COLLECT_WORK_SAY_COOLDOWN = 20     -- 清理/整理工作语音冷却（秒）
NPC_TUNING.COLLECT_WORK_SAY_CHANCE   = 0.35   -- 清理/整理工作语音触发概率（0~1）

-- ═══════════════════════════════════════════════════════════════
--  工具判断（tag + prefab 双重检测）
-- ═══════════════════════════════════════════════════════════════
--- 判断物品是否是 NPC 自带的初始工具
--- 仅通过 _npc_tool 标签/属性 或 _npc_initial_tool 属性判断
--- 不再按 prefab 名自动标记，避免玩家给的/地上捡的同类工具被误判
--- @param item   物品实体
--- @param npc    NPC 实体（保留参数以兼容调用方）
--- @return boolean
function NPC_TUNING.IsNPCTool(item, npc)
    if not item or not item:IsValid() then return false end
    if item._npc_excess then return false end
    if item:HasTag("_npc_tool") or item._npc_tool or item._npc_initial_tool then return true end
    return false
end

-- 扫描背包，对 UNTAKEABLE_NPC_TOOLS 列表里的工具，每种 prefab 只保留 2 把
-- 多余的标记 _npc_excess（IsNPCTool 会返回 false，整理逻辑会丢掉）
-- 优先级：_npc_initial_tool > _npc_tool > 无标记
-- 应在 HasTrash/GetTrashItems 调用前执行
function NPC_TUNING.MarkExcessTools(inst)
    if not inst or not inst.npc_character_type then return end
    local untakeable = (NPC_TUNING.UNTAKEABLE_NPC_TOOLS or {})[inst.npc_character_type]
    if not untakeable or #untakeable == 0 then return end
    local inv = inst.components.inventory
    if not inv then return end

    local groups = {}
    local watched = {}
    local seen_guid = {}  -- 防止同一实体被装备槽和物品栏同时扫到
    for _, prefab in ipairs(untakeable) do
        groups[prefab] = {}
        watched[prefab] = true
    end

    local function scan(item, from)
        if item and item:IsValid() and watched[item.prefab] then
            local g = item.GUID or tostring(item)
            if seen_guid[g] then
                if NPC_TUNING.DEBUG_FARMING then
                    print("[种植调试][Excess] !!! 同一实体重复扫描", item.prefab, "from=", from, "GUID=", g)
                end
                return
            end
            seen_guid[g] = true
            if not item._npc_tool and not item._npc_initial_tool then
                item._npc_tool = true
                item:AddTag("_npc_tool")
                if NPC_TUNING.DEBUG_FARMING then
                    print(string.format("[种植调试][Excess] 兜底补标记 %s GUID=%s (from=%s)",
                        item.prefab, tostring(g), from))
                end
            end
            table.insert(groups[item.prefab], item)
            item._npc_excess = nil
        end
    end

    for i = 1, inv.maxslots do scan(inv:GetItemInSlot(i), "slot"..i) end
    for slot_name, slot in pairs(EQUIPSLOTS) do
        scan(inv:GetEquippedItem(slot), "equip:"..tostring(slot_name))
    end


    for prefab, items in pairs(groups) do
        if NPC_TUNING.DEBUG_FARMING and #items > 0 then
            local detail = {}
            for k, it in ipairs(items) do
                local pri = (it._npc_initial_tool and "initial") or (it._npc_tool and "tool") or "none"
                table.insert(detail, string.format("[%d]GUID=%s pri=%s", k, tostring(it.GUID or "?"), pri))
            end
            print(string.format("[种植调试][Excess] %s 共 %d 把: %s", prefab, #items, table.concat(detail, ", ")))
        end
        if #items > 2 then
            table.sort(items, function(a, b)
                local pa = (a._npc_initial_tool and 2) or (a._npc_tool and 1) or 0
                local pb = (b._npc_initial_tool and 2) or (b._npc_tool and 1) or 0
                return pa > pb
            end)
            for k = 3, #items do
                items[k]._npc_excess = true
                if NPC_TUNING.DEBUG_FARMING then
                    print(string.format("[种植调试][Excess] !!! 标记多余: %s GUID=%s (第%d把，>2)", prefab, tostring(items[k].GUID or "?"), k))
                end
            end
        end
    end
end

-- 检查指定 prefab 是否在某角色的 UNTAKEABLE 列表里
-- 用于 inventory:onitemget 监听，给玩家递入的工具自动加 _npc_tool 标记
function NPC_TUNING.IsUntakeableToolPrefab(char_type, prefab)
    if not char_type or not prefab then return false end
    local list = (NPC_TUNING.UNTAKEABLE_NPC_TOOLS or {})[char_type]
    if not list then return false end
    for _, p in ipairs(list) do
        if p == prefab then return true end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════
--  幽灵掉落配置
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.GHOST_LOOT_CONFIG = {
    webber = {
        MODE = "group_chance",
        GROUP_ROLLS = {
            {
                id = "npc_growth_candy", -- 100% 随机掉落一个成长糖
                chance = 1,
                pick = 1,
                items = {
                    { prefab = "npc_heart", weight = 1 }, 
                    { prefab = "npc_sword", weight = 1 }, 
                },
            },
            {
                id = "gems",
                chance = 1, -- 100% 概率触发宝石掉落
                pick = 1,
                items = {
                    { prefab = "redgem",    weight = 3 },
                    { prefab = "bluegem",   weight = 3 },
                    { prefab = "purplegem", weight = 2 },
                    { prefab = "orangegem", weight = 1 },
                    { prefab = "yellowgem", weight = 1 },
                    { prefab = "greengem",  weight = 1 },
                },
            },
            {
                id = "spider_drops", -- 蜘蛛掉落
                chance = 1, -- 100% 概率触发材料掉落
                pick = 3,
                items = {
                    { prefab = "silk",          weight = 5 }, -- 蛛丝
                    { prefab = "spidergland",   weight = 5 }, -- 蜘蛛腺体
                    { prefab = "monstermeat",   weight = 5 }, -- 怪物肉

                },
            },
            {
                id = "common_materials", -- 常规材料掉落
                chance = 1, -- 100% 概率触发
                pick = 2,
                items = {
                    { prefab = "rocks",      weight = 5 }, -- 石头
                    { prefab = "goldnugget", weight = 4 }, -- 金子
                    { prefab = "trinket_6",  weight = 2 }, -- 烂电线
                    { prefab = "jellybean", weight = 1 },  -- 彩虹糖豆
                    { prefab = "dreadstone", weight = 1 }, -- 绝望石
                },
            },
            {
                id = "krampus_sack_drop", -- 小偷包掉落
                chance = 0.05, -- 5%
                pick = 1,
                items = {
                    { prefab = "krampus_sack", weight = 1 }, -- 小偷包
                   
                },
            },
            {
                id = "walrus_tusk_drop", -- 海象牙掉落
                chance = 0.10, -- 10%
                pick = 1,
                items = {
                    { prefab = "orangestaff", weight = 1 }, -- 懒人杖
                },
            },
            {
                id = "armor_drop", -- 装备掉落
                chance = 0.6, -- 60%
                pick = 1,
                items = {
                    { prefab = "armorgrass",  weight = 5 }, -- 草甲
                    { prefab = "spiderhat",  weight = 5 },  -- 蜘蛛帽
                    { prefab = "armorwood",   weight = 4 }, -- 木甲
                    { prefab = "footballhat", weight = 3 }, -- 猪皮帽
                    { prefab = "armorruins",  weight = 1 }, -- 铥矿甲
                },
            },
            {
                id = "food_drop", -- 食物掉落
                chance = 1, -- 100% 概率触发
                pick = 2,
                items = {
                    { prefab = "glowberrymousse",  weight = 1 },
                    { prefab = "voltgoatjelly",    weight = 1 },
                    { prefab = "moqueca",          weight = 1 },
                    { prefab = "freshfruitcrepes", weight = 1 },
                    { prefab = "gazpacho",         weight = 1 },
                    { prefab = "dragonchilisalad", weight = 1 },
                },
            },
        },
        ITEMS = {
            { prefab = "silk",        weight = 8 },
            { prefab = "spidergland", weight = 6 },
            { prefab = "monstermeat", weight = 5 },
            { prefab = "stinger",     weight = 3 },
        },
    },
    wurt = {
        MODE = "group_chance",
        GROUP_ROLLS = {
            {
                id = "npc_growth_candy", -- 100% 随机掉落二个成长糖
                chance = 1, -- 100%
                pick = 2,
                items = {
                    { prefab = "npc_heart", weight = 1 }, -- 生命
                    { prefab = "npc_sword", weight = 1 }, -- 战意
                },
            },
            {
                id = "gems",
                chance = 1, -- 100% 概率触发宝石掉落
                pick = 1,
                items = {
                    { prefab = "purplegem", weight = 1 },
                    { prefab = "orangegem", weight = 1 },
                    { prefab = "yellowgem", weight = 1 },
                    { prefab = "greengem",  weight = 1 },
                },
            },
            {
                id = "common_materials", -- 常规材料掉落
                chance = 1, -- 100% 概率触发
                pick = 2,
                items = {
                    { prefab = "trinket_6",  weight = 2 }, -- 烂电线
                    { prefab = "jellybean", weight = 1 },  -- 彩虹糖豆
                    { prefab = "dreadstone", weight = 1 }, -- 绝望石
                },
            },
            {
                id = "armor_drop", -- 装备掉落
                chance = 1, -- 100%
                pick = 1,
                items = {
                    { prefab = "armorwood",   weight = 3 }, -- 木甲
                    { prefab = "footballhat", weight = 2 }, -- 猪皮帽
                    { prefab = "armorruins",  weight = 1 }, -- 铥矿甲
                },
            },
            {
                id = "fishmeat_small_fixed",
                chance = 1, -- 100%
                pick = 5,  -- 固定掉 5 个
                items = {
                    { prefab = "fishmeat_small", weight = 1 },
                },
            },
            {
                id = "fishmeat_fixed",
                chance = 1, -- 100%
                pick = 5,  -- 固定掉 5 个
                items = {
                    { prefab = "fishmeat", weight = 1 },
                },
            },
            {
                id = "icepack_drop",
                chance = 0.1, -- 10%
                pick = 1,
                items = {
                    { prefab = "icepack", weight = 1 }, -- 熊皮背包
                },
            },
            {
                id = "orangestaff_drop",
                chance = 0.10, -- 10%
                pick = 1,
                items = {
                    { prefab = "orangestaff", weight = 1 }, -- 懒人杖
                },
            },
        },
        ITEMS = {},
    },
}

-- ═══════════════════════════════════════════════════════════════
--  池塘配置
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.POOL_CONFIG = {
    PLACE_MIN_DIST = 2.0,                         -- 池塘放置最小安全间距（格）
    PLACE_MAX_DIST = 20.0,                        -- 池塘放置离玩家最大距离（格）
    ANIM_ZIP = "anim/moonglasspool_tile_big.zip", -- 池塘动画包路径（本 mod）
    BUILD = "moonglasspool_tile_big",             -- 池塘 Build
    BANK = "moonglasspool_tile_big",              -- 池塘 Bank
    IDLE_ANIM = "idle",                           -- 池塘待机动画
}

-- ═══════════════════════════════════════════════════════════════
--  制作配方
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.CRAFT_RECIPES = {
    winona_tape = {
        product = "sewing_tape",
        materials = {
            { name = "silk",     count = 1 },
            { name = "cutgrass", count = 3 },
        },
    },
    winona_generator = {
        product = "winona_battery_high",
        materials = {
            { name = "sewing_tape", count = 1 },
            { name = "boards",      count = 2 },
            { name = "transistor",  count = 2 },
        },
    },
    winona_spotlight = {
        product = "winona_spotlight",
        materials = {
            { name = "sewing_tape", count = 1 },
            { name = "goldnugget",  count = 2 },
            { name = "fireflies",   count = 1 },
        },
    },
    winona_catapult = {
        product = "winona_catapult",
        materials = {
            { name = "sewing_tape", count = 1 },
            { name = "twigs",       count = 3 },
            { name = "rocks",       count = 15 },
        },
    },
    willow_rainbow_fireflies = {
        product = "npc_rainbow_fireflies",
        materials = {
            { name = "redgem", count = 1 },
        },
    },
    wilson_purebrilliance = {
        product = "purebrilliance",
        materials = {
            { name = "moonglass_charged", count = 2 },
        },
    },
    wilson_horrorfuel = {
        product = "horrorfuel",
        materials = {
            { name = "dreadstone", count = 1 },
        },
    },
    waxwell_magic_chest = {
        product = "npc_waxwell_magic_chest",
        materials = {
            { name = "silk",          count = 1 },
            { name = "boards",        count = 4 },
            { name = "nightmarefuel", count = 9 },
        },
    },
    -- 女武神
    wathgrithr_spear = {
        product = "spear_wathgrithr",
        materials = {
            { name = "twigs",      count = 2 },
            { name = "flint",      count = 2 },
            { name = "goldnugget", count = 2 },
        },
    },
    wathgrithr_helmet = {
        product = "wathgrithrhat",
        materials = {
            { name = "goldnugget", count = 2 },
            { name = "rocks",      count = 2 },
        },
    },
    walter_ammo_gold = {
        product = "slingshotammo_gold",
        count = 20,
        materials = {
            { name = "goldnugget", count = 1 },
        },
    },
    walter_ammo_scrapfeather = {
        product = "slingshotammo_scrapfeather",
        count = 20,
        materials = {
            { name = "redgem",     count = 1 },
            { name = "goldnugget", count = 1 },
        },
    },
    walter_ammo_thulecite = {
        product = "slingshotammo_thulecite",
        count = 20,
        materials = {
            { name = "thulecite_pieces", count = 1 },
            { name = "nightmarefuel",    count = 1 },
        },
    },
    walter_ammo_horrorfuel = {
        product = "slingshotammo_horrorfuel",
        count = 20,
        materials = {
            { name = "horrorfuel", count = 1 },
            { name = "rocks",      count = 1 },
        },
    },
    walter_ammo_freeze = {
        product = "slingshotammo_freeze",
        count = 20,
        materials = {
            { name = "moonrocknugget", count = 1 },
            { name = "bluegem",        count = 1 },
        },
    },
    walter_ammo_slow = {
        product = "slingshotammo_slow",
        count = 20,
        materials = {
            { name = "moonrocknugget", count = 1 },
            { name = "purplegem",      count = 1 },
        },
    },
    wonkey_bananabush = {
        product = "dug_bananabush",
        materials = {
            { name = "cave_banana", count = 10 },
        },
    },
    wonkey_monkeytail = {
        product = "dug_monkeytail",
        materials = {
            { name = "cutreeds", count = 10 },
        },
    },
    wonkey_ancienttree_seed = {
        product = "ancienttree_seed",
        materials = {
            { name = "redgem",  count = 4 },
            { name = "bluegem", count = 4 },
        },
    },
    -- WX-78 运输机（便携储存单元）：直接部署成可用结构，无 product
    wx78_transport_drone = {
        materials = {
            { name = "gears",  count = 1 },
            { name = "boards", count = 3 },
        },
    },
}

-- ═══════════════════════════════════════════════════════════════
--  角色能力配置（供 DstAdmin NPC 状态面板使用）
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.CHARACTER_ABILITIES = {
    wilson = {
        { id = "FishHere", label_key = "NPCFRIEND_ABILITY_FISH", command = "FishHere" },
        { id = "stop_work", label_key = "btn_stop_work", command = "StopWork" },
        { id = "wilson_show_npc_locations", label_key = "btn_wilson_show_npc_locations", command = "WilsonShowNPCLocations" },
        { id = "wilson_unlock_transmute", label_key = "btn_wilson_unlock_transmute", command = "UnlockWilsonTransmuteTech" },
        { id = "wilson_craft_purebrilliance", label_key = "btn_wilson_purebrilliance", command = "WilsonCraftPureBrilliance" },
        { id = "wilson_craft_horrorfuel", label_key = "btn_wilson_horrorfuel", command = "WilsonCraftHorrorfuel" },
    },
    wendy = {
        { id = "ocean_fish_here",     label_key = "btn_ocean_fish_here",     command = "OceanFishHere" },
        { id = "stop_work",           label_key = "btn_stop_work",           command = "StopWork" },
    },
    -- wilson = {
    --     { id = "create_pool", label_key = "btn_create_pool", command = "CreatePool" },
    -- },
    wormwood = {
        { id = "farm_here",   label_key = "btn_farm_here",   command = "FarmHere" },
        { id = "stop_work",   label_key = "btn_stop_work",   command = "StopWork" },
    },
    warly = {
        { id = "cook_here", label_key = "btn_cook_here", command = "CookHere" },
        { id = "stop_work", label_key = "btn_stop_work", command = "StopWork" },
    },
    wes = {
        { id = "clean_here", label_key = "btn_clean_here", command = "CleanHere" },
        { id = "stop_work", label_key = "btn_stop_work", command = "StopWork" },
    },
    willow = {
        { id = "craft_rainbow_fireflies", label_key = "btn_willow_rainbow_fireflies", command = "WillowCraftRainbowFireflies" },
    },
    wickerbottom = {
        { id = "wickerbottom_grow_crops", label_key = "btn_wickerbottom_grow_crops", command = "WickerbottomGrowCrops" },
    },
    winona = {
        { id = "clean_here",      label_key = "btn_clean_here",      command = "CleanHere" },
        { id = "stop_work",       label_key = "btn_stop_work",       command = "StopWork" },
        { id = "craft_tape",      label_key = "btn_winona_tape",      command = "WinonaCraftTape" },
        { id = "place_generator", label_key = "btn_winona_generator", command = "PlaceGenerator" },
        { id = "place_spotlight", label_key = "btn_winona_spotlight", command = "PlaceSpotlight" },
        { id = "place_catapult",  label_key = "btn_winona_catapult",  command = "PlaceCatapult" },
    },
    wilba = {
        { id = "open_quest",         label_key = "btn_wilba_quest",         command = "OpenQuest" },
    },
    woodie = {
        { id = "chop_here", label_key = "btn_chop_here", command = "ChopHere" },
        { id = "stop_work", label_key = "btn_stop_work", command = "StopWork" },
    },
    wathgrithr = {
        { id = "craft_spear",  label_key = "btn_wathgrithr_spear",  command = "WathgrithrCraftSpear" },
        { id = "craft_helmet", label_key = "btn_wathgrithr_helmet", command = "WathgrithrCraftHelmet" },
    },
    waxwell = {
        { id = "build_magic_chest", label_key = "btn_waxwell_magic_chest", command = "BuildWaxwellMagicChest" },
    },
    walter = {
        { id = "walter_auto_story",    label_key = "btn_walter_auto_story_off",  command = "ToggleWalterAutoStory" },
        { id = "craft_ammo_gold",         label_key = "btn_walter_ammo_gold",         command = "WalterCraftGoldAmmo" },
        { id = "craft_ammo_scrapfeather", label_key = "btn_walter_ammo_scrapfeather", command = "WalterCraftScrapfeatherAmmo" },
        { id = "craft_ammo_thulecite",    label_key = "btn_walter_ammo_thulecite",    command = "WalterCraftThuleciteAmmo" },
        { id = "craft_ammo_horrorfuel",   label_key = "btn_walter_ammo_horrorfuel",   command = "WalterCraftHorrorfuelAmmo" },
        { id = "craft_ammo_freeze",       label_key = "btn_walter_ammo_freeze",       command = "WalterCraftFreezeAmmo" },
        { id = "craft_ammo_slow",         label_key = "btn_walter_ammo_slow",         command = "WalterCraftSlowAmmo" },
    },
    wanda = {
        { id = "open_rift", label_key = "btn_open_rift", command = "OpenRift" },
    },
    wonkey = {
        { id = "craft_bananabush",        label_key = "btn_wonkey_bananabush",        command = "WonkeyCraftBananaBush" },
        { id = "craft_monkeytail",        label_key = "btn_wonkey_monkeytail",        command = "WonkeyCraftMonkeytail" },
        { id = "craft_ancienttree_seed",  label_key = "btn_wonkey_ancienttree_seed",  command = "WonkeyCraftAncienttreeSeed" },
    },
    wx78 = {
        { id = "wx78_craft_transport_drone", label_key = "btn_wx78_transport_drone", command = "WX78CraftTransportDrone" },
    },
}

NPC_TUNING.ABILITY_STATE_CHECKERS = {
    create_pool = function(npc)
        return npc ~= nil and npc.npc_character_type == "wilson"
    end,
    farm_here = function(npc)
        return npc._is_wormwood == true
            and npc._farmer ~= nil
            and (npc._farmer.farm_center == nil or npc._work_paused == true)
    end,
    cook_here = function(npc)
        return npc._is_warly == true
            and npc._cooking_center == nil
    end,
    clean_here = function(npc)
        if npc._is_wes == true then
            return npc._wes_farm_center == nil
        end
        if npc._is_winona == true then
            return npc._winona_farm_center == nil
        end
        return false
    end,
    wilson_show_npc_locations = function(npc)
        return npc ~= nil
            and npc.npc_character_type == "wilson"
            and not npc._is_ghost_mode
            and not (npc.components.health and npc.components.health:IsDead())
            and npc_affinity.MeetsThreshold(npc, "show_locations")
    end,
    FishHere = function(npc)
        if npc == nil or npc._is_ghost_mode then
            return false
        end
        return npc._fishing_active ~= true
            and npc_affinity.MeetsThreshold(npc, "fishing")
    end,
    wilson_unlock_transmute = function(npc)
        return npc ~= nil
            and npc.npc_character_type == "wilson"
            and not npc._is_ghost_mode
            and not (npc.components.health and npc.components.health:IsDead())
            and npc._wilson_transmute_unlocked ~= true
            and npc_affinity.MeetsThreshold(npc, "craft")
    end,
    wilson_craft_purebrilliance = function(npc)
        if npc == nil or npc.npc_character_type ~= "wilson" then return false end
        if npc._is_ghost_mode then return false end
        if npc.components.health and npc.components.health:IsDead() then return false end
        if npc._wilson_transmute_unlocked == true then return true end
        return npc_affinity.IsEnabled() and npc_affinity.MeetsThreshold(npc, "craft")
    end,
    wilson_craft_horrorfuel = function(npc)
        if npc == nil or npc.npc_character_type ~= "wilson" then return false end
        if npc._is_ghost_mode then return false end
        if npc.components.health and npc.components.health:IsDead() then return false end
        if npc._wilson_transmute_unlocked == true then return true end
        return npc_affinity.IsEnabled() and npc_affinity.MeetsThreshold(npc, "craft")
    end,
    chop_here = function(npc)
        return npc._is_woodie == true
            and npc._woodie_chop_center == nil
    end,
    open_rift = function(npc)
        if npc == nil or npc.npc_character_type ~= "wanda" then
            return false
        end
        if npc._is_ghost_mode then
            return false
        end
        if npc.components.health and npc.components.health:IsDead() then
            return false
        end
        return true
    end,
    wickerbottom_grow_crops = function(npc)
        return npc ~= nil
            and npc.npc_character_type == "wickerbottom"
            and not npc._is_ghost_mode
            and not (npc.components.health and npc.components.health:IsDead())
    end,
    build_magic_chest = function(npc)
        return npc ~= nil
            and npc.npc_character_type == "waxwell"
            and not npc._is_ghost_mode
            and not (npc.components.health and npc.components.health:IsDead())
    end,
    ocean_fish_here = function(npc)
        if npc == nil or npc._is_ghost_mode then return false end
        if npc.npc_character_type ~= "wendy" then return false end
        return npc._oceanfishing_active ~= true
            and npc_affinity.MeetsThreshold(npc, "fishing")
    end,
    stop_work = function(npc)
        if npc._work_paused then return false end
        if npc._is_wormwood and npc._farmer and npc._farmer.farm_center then
            return true
        end
        if npc._is_warly and npc._cooking_center ~= nil then
            return true
        end
        if npc._is_wes and npc._wes_farm_center ~= nil then
            return true
        end
        if npc._is_winona and npc._winona_farm_center ~= nil then
            return true
        end
        if npc._is_woodie and npc._woodie_chop_center ~= nil then
            return true
        end
        if npc._fishing_active == true then
            return true
        end
        if npc._oceanfishing_active == true then
            return true
        end
        return false
    end,
}

-- ═══════════════════════════════════════════════════════════════
--  任务系统（猪人公主 Wilba）
-- ═══════════════════════════════════════════════════════════════
-- 击杀类任务的"分享半径"：击杀发生时，半径内（且接了同任务）的玩家共同加进度。
-- · 不区分杀手身份：玩家本人 / 招募 NPC / 野生 NPC / 其他玩家 / 环境伤害（火/雷/淹死）
--   全部按击杀点周围"谁在场"判定。
-- · 离线玩家不参与计算（无法判位置）；他们再次上线后看到的进度只来自他们当时在场的击杀。
NPC_TUNING.QUEST_KILL_SHARE_RADIUS = 30

NPC_TUNING.MAX_ACTIVE_QUESTS = 4

-- 特殊任务"给薇洛制作个打火机"的每日刷新概率（0~1）
-- 仅当世界里存在"没有打火机"的 NPC 薇洛时才会按此概率刷出；薇洛已有打火机则永不刷新
NPC_TUNING.WILLOW_LIGHTER_QUEST_CHANCE = 0.5

-- ═══════════════════════════════════════════════════════════════
--  调试开关
-- ═══════════════════════════════════════════════════════════════
NPC_TUNING.DEBUG_BEHAVIOR = false   -- 行为/整理/存放日志开关
NPC_TUNING.DEBUG_COMBAT   = false   -- 战斗/闪避/技能日志开关
NPC_TUNING.DEBUG_COOKING  = false   -- 烹饪模块日志开关
NPC_TUNING.DEBUG_FARMING  = false   -- 种地系统调试日志开关
NPC_TUNING.DEBUG_CHOP     = false  -- 砍树模块日志开关
NPC_TUNING.DEBUG_FISHING  = false   -- 钓鱼模块日志开关
NPC_TUNING.DEBUG_OCEAN_FISHING_DUP = false  -- (保留兼容，主开关为 DEBUG_OCEAN_FISHING)
NPC_TUNING.DEBUG_PLATFORM_HOP = false   -- 平台跟随/上船跳船诊断日志开关（仅状态变化打印，自带限流）
NPC_TUNING.DEBUG_RESKIN = false   -- NPC 换肤诊断日志开关（临时打开排查换肤失效）
-- ────────────────────────────────────────────────────────────
-- NPC "消失"诊断开关：跟随玩家时定期采样 build/bank/可见性/分片等关键状态，
-- 只在状态变化时打印（自带冷却），用于排查贴图变白/隐身/换 build/跨分片丢失/掉 limbo 等问题。
-- 排查完成后请关闭，避免日志噪声。
-- ────────────────────────────────────────────────────────────
NPC_TUNING.DEBUG_VISIBILITY = false
NPC_TUNING.DEBUG_VISIBILITY_TICK = 3.0    -- 采样间隔（秒），过小会刷屏
NPC_TUNING.DEBUG_VISIBILITY_FAR_DIST = 60 -- 距离 leader 多远算"可能在视野外"

-- ═══════════════════════════════════════════════════════════════
--  参数安全校验（防止用户误配置导致逻辑 bug）
-- ═══════════════════════════════════════════════════════════════
local function ValidateAndCorrect()
    local weed_range = NPC_TUNING.FARM_WEED_CHECK_RANGE or 6
    local throw_dist = NPC_TUNING.FARM_CLEANUP_THROW_DIST or 16
    local work_radius = NPC_TUNING.FARM_WORK_RADIUS or 40

    -- 丢弃距离必须 >= 检测范围 + 安全边距(1)
    if throw_dist < weed_range + 1 then
        NPC_TUNING.FARM_CLEANUP_THROW_DIST = weed_range + 1
        if NPC_TUNING.DEBUG_FARMING then
            print("[NPC_TUNING] 自动修正 FARM_CLEANUP_THROW_DIST → " .. NPC_TUNING.FARM_CLEANUP_THROW_DIST)
        end
    end

    -- 工作范围必须 > 丢弃距离
    if work_radius <= throw_dist then
        NPC_TUNING.FARM_WORK_RADIUS = throw_dist + 2
        if NPC_TUNING.DEBUG_FARMING then
            print("[NPC_TUNING] 自动修正 FARM_WORK_RADIUS → " .. NPC_TUNING.FARM_WORK_RADIUS)
        end
    end

    -- MIN_SOIL_COUNT 必须 <= GRID_SIZE^2
    local grid_total = NPC_TUNING.FARM_GRID_SIZE * NPC_TUNING.FARM_GRID_SIZE
    if NPC_TUNING.FARM_MIN_SOIL_COUNT > grid_total then
        NPC_TUNING.FARM_MIN_SOIL_COUNT = grid_total
        if NPC_TUNING.DEBUG_FARMING then
            print("[NPC_TUNING] 自动修正 FARM_MIN_SOIL_COUNT → " .. grid_total .. " (GRID_SIZE=" .. NPC_TUNING.FARM_GRID_SIZE .. ")")
        end
    end

    NPC_TUNING.FARM_OVERSIZED_SCAN_RADIUS = NPC_TUNING.FARM_WORK_RADIUS
    NPC_TUNING.FARM_ENTITY_RADIUS = NPC_TUNING.FARM_WEED_CHECK_RANGE
    NPC_TUNING.FARM_RETURN_DIST = math.ceil(NPC_TUNING.FARM_WORK_RADIUS * 0.7)
    NPC_TUNING.FARM_CLEANUP_CARRY_MIN = math.ceil(NPC_TUNING.FARM_CLEANUP_THROW_DIST * 0.5)
    NPC_TUNING.FARM_CLEANUP_CARRY_MAX = NPC_TUNING.FARM_CLEANUP_THROW_DIST
end

ValidateAndCorrect()

return NPC_TUNING
