--- 威尔顿角色模组的元信息配置文件。
 -- 本文件由游戏在模组列表与服务器设置界面读取，用于展示模组名称、简介等信息。
 -- 还在这里声明可在游戏内调整的配置项，运行时通过 GetModConfigData 读取。
 -- 经手了三位码师，三种不同的代码标准，反正我感觉挺难写的qwq，不过其实我也写的不是很规范的代码，如果还有其他人接收的话，那确实很累了
 name = "威尔顿 Wilton"
description = "*是一具被诅咒的骷髅。\n*被怪物视作同类。\n*不畏惧黑暗和幽灵。\n*掌握死灵法术，拥有自己的骷髅大军。\n*骨头脆弱，灵魂永生。\n\n*A skeleton cursed to walk again.\n*Monsters regard him as one of their own.\n*Unafraid of darkness and ghosts.\n*Commands his own skeletal army through necromancy.\n*Brittle bones, undying soul."
 author = "艾趣44，无敌小狗，割草机，醨、尹怨怨"
 version = "1.6.0"

forumthread = ""
api_version = 10
dst_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = true 

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
"character",
"wilton",
}

--- 构造仅用于分组展示标题的“伪配置项”。
-- 这类项没有实际配置值，只在模组设置界面里起到分组和标题说明的作用。
-- @param title string 标题文本，将显示在模组设置面板中
-- @return table Klei 要求格式的配置项表，用于 configuration_options
local function Title(title)
    return {
        name=title,
        hover = "",
        options={{description = "", data = 0}},
        default = 0,
        }
end

--- 模组可配置项列表。
-- 运行时通过 GetModConfigData("配置名") 读取，例如在 modmain.lua 中写入 TUNING。
configuration_options = {
    
    Title("人物设置 / Character Settings"),
    --- 界面语言。
    -- 默认跟随游戏语言，也可以在此强制指定为中文或英文。
    {
        name = "wilton_language",
        label = "语言 / Language",
        hover = "选择本模组的显示语言 / Choose the display language for this mod.",
        options =
        {
            {description = "默认(跟随游戏) / Default (follow game)", data = "default"},
            {description = "中文 / Chinese", data = "ch"},
            {description = "English", data = "en"},
        },
        default = "default",
    },

    --- 威尔顿与骷髅兵的生命值上限。
    -- 影响角色与骷髅随从的最大生命值，与 TUNING.WILTONMOD_HEALTH 联动。
    {
        name = "wilton_health",
        label = "生命值上限 / Max Health",
        hover = "威尔顿与骷髅兵的生命值上限 / Maximum health for Wilton and his skeleton minions.",
        options =
        {
            {description = "50", data = 50},
            {description = "75", data = 75},
            {description = "100", data = 100},
            {description = "125", data = 125},
            {description = "150", data = 150},
            {description = "200", data = 200},
            {description = "300", data = 300},
            {description = "500", data = 500},
            {description = "800", data = 800},
            {description = "1000", data = 1000},
            {description = "5000", data = 5000},
            {description = "10000", data = 10000},
        },
        default = 50,
    },

    --- 威尔顿与骷髅兵的理智值上限。
    -- 与 TUNING.WILTONMOD_SANITY 联动，用于控制角色基础理智池。
    {
        name = "wilton_sanity",
        label = "理智值上限 / Max Sanity",
        hover = "威尔顿与骷髅兵的理智值上限 / Maximum sanity for Wilton and his skeleton minions.",
        options =
        {
            {description = "50", data = 50},
            {description = "75", data = 75},
            {description = "100", data = 100},
            {description = "125", data = 125},
            {description = "150", data = 150},
            {description = "200", data = 200},
            {description = "300", data = 300},
            {description = "500", data = 500},
            {description = "800", data = 800},
            {description = "1000", data = 1000},
            {description = "5000", data = 5000},
            {description = "10000", data = 10000},
        },
        default = 50,
    },

    --- 技能树总开关。
    -- 关闭后威尔顿将不再拥有任何技能树效果，相关判定统一返回未解锁。
    {
        name = "wilton_skilltree",
        label = "技能树开关 / Skill Tree Toggle",
        hover = "关闭后威尔顿不会拥有技能树功能 / Disable to remove Wilton's skill tree entirely.",
        options =
        {
            {description = "关 / Off", data = false},
            {description = "开 / On", data = true},
        },
        default = true,
    },

    --- 威尔顿骨骼形态复活所需时间（秒）。
    -- 骷髅形态下每秒回复 1 点生命值，达到该数值后自动复活。
    {
        name = "wilton_revive_time",
        label = "复活时间 / Revive Time",
        hover = "威尔顿从骷髅形态恢复所需的时间（秒）/ Time (in seconds) for Wilton to recover from skeletal form.",
        options =
        {
            {description = "5", data = 5},
            {description = "10", data = 10},
            {description = "20", data = 20},
            {description = "30", data = 30},
            {description = "50", data = 50},
            {description = "100", data = 100},
        },
        default = 30,
    },

    --- 威尔顿与骷髅兵的攻击倍率。
    -- 作用于威尔顿自身伤害系数与骷髅宠物的基础伤害。
    {
        name = "wilton_attack_mult",
        label = "攻击倍率 / Damage Multiplier",
        hover = "威尔顿与骷髅兵的攻击倍率 / Damage multiplier for Wilton and his skeleton minions.",
        options =
        {
            {description = "0.5", data = 0.5},
            {description = "0.75", data = 0.75},
            {description = "1.0", data = 1.0},
        },
        default = 0.75,
    },

    --- 禁止威尔顿通过普通治疗手段回血。
    -- 开启后，除了骨质修复液以外的治疗道具均无法为威尔顿与骷髅兵回复生命。
    {
        name = "wilton_disable_heal",
        label = "禁止回血 / Disable Healing",
        hover = "仅骨质修复液可以为威尔顿与骷髅兵回复生命 / Only Bone Repair Fluid can heal Wilton and his skeleton minions.",
        options =
        {
            {description = "否 / No", data = false},
            {description = "是 / Yes", data = true},
        },
        default = false,
    },

    Title("骷髅兵设置 / Skeleton Settings"),

    --- 骷髅兵召唤数量上限。
    -- 数值越高，可同时存在的骷髅兵越多，战斗力更强，但可能略微增加服务器负担。
    {
        name = "wilton_skeleton_count",
        label = "骷髅兵召唤上限 / Skeleton Minion Limit",
        hover = "骷髅兵召唤上限 / Maximum number of skeleton minions.",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
            {description = "10", data = 10},
            {description = "无限 / Unlimited", data = 999999},
        },
        default = 5,
    },

    --- 骷髅兵移动速度倍率。
    -- 影响骷髅兵的追击、跟随效率，与 TUNING.WILTON_SKELETON_SPEED 联动。
    {
        name = "wilton_skeleton_speed",
        label = "骷髅兵移速 / Skeleton Minion Speed",
        hover = "骷髅兵移速 / Movement speed multiplier for skeleton minions.",
        options =
        {
            {description = "1", data = 1},
            {description = "1.25", data = 1.25},
            {description = "1.5", data = 1.5},
        },
        default = 1.25,
    },

    --- 骷髅兵无敌开关。
    -- 开启后骷髅兵将不会受到任何形式的伤害，仅建议用于娱乐或测试环境。
    {
        name = "wilton_skeleton_invincible",
        label = "骷髅兵无敌 / Skeleton Invincibility",
        hover = "开启后骷髅兵不会受到任何伤害 / Enable to make skeleton minions completely immune to damage.",
        options =
        {
            {description = "否 / No", data = false},
            {description = "是 / Yes", data = true},
        },
        default = false,
    },

    --- 骷髅兵是否消耗装备和武器的耐久。
    -- 关闭后由骷髅兵佩戴的护甲与武器在战斗中不会掉耐久。
    {
        name = "wilton_skeleton_durability",
        label = "骷髅兵消耗耐久 / Skeleton Durability Usage",
        hover = "关闭后骷髅兵将不会消耗装备和武器的耐久 / Disable to prevent skeletons from wearing down their equipment and weapons.",
        options =
        {
            {description = "是 / Yes", data = true},
            {description = "否 / No", data = false},
        },
        default = true,
    },

    Title("装备设置 / Equipment Settings"),

    --- 投掷骨攻击力设置 / Throwing Bone Damage.
    -- 同时作用于投掷骨本体 `wiltonmod_shoot` 及其皮肤 `wiltonmod_shoot_skin` 的 weapon 伤害。
    {
        name = "wilton_shoot_damage",
        label = "投掷骨攻击力 / Shoot Damage",
        hover = "设置投掷骨的基础攻击力，数值越高伤害越高（34/45/51/68）。",
        options =
        {
            {description = "34", data = 34},
            {description = "45", data = 45},
            {description = "51", data = 51},
            {description = "68", data = 68},
        },
        default = 34,
    },

    --- 尖骨头攻击力设置 / Sharp Bone Damage.
    -- 同步影响 `wiltonmod_sharpbone` 及其所有皮肤（包括 stonesword 皮肤）的 weapon 伤害。
    {
        name = "wilton_sharpbone_damage",
        label = "尖骨头攻击力 / Sharpbone Damage",
        hover = "设置尖骨头的基础攻击力，数值越高伤害越高（34/45/51/68）。",
        options =
        {
            {description = "34", data = 34},
            {description = "45", data = 45},
            {description = "51", data = 51},
            {description = "68", data = 68},
        },
        default = 45,
    },

    --- 大骨棒攻击力设置 / Bonehammer Damage.
    -- 同步影响 `wiltonmod_bonehammer` 及其皮肤的 weapon 伤害。
    {
        name = "wilton_bonehammer_damage",
        label = "大骨棒攻击力 / Bonehammer Damage",
        hover = "设置大骨棒的基础攻击力，数值越高伤害越高（34/45/51/68）。",
        options =
        {
            {description = "34", data = 34},
            {description = "45", data = 45},
            {description = "51", data = 51},
            {description = "68", data = 68},
        },
        default = 34,
    },

    --- 骨杖复活法阵理智消耗 / Bone Staff Sanity Cost.
    -- 影响威尔顿施放骨杖一技能（群体复活）时的理智消耗，0 为完全不消耗理智。
    {
        name = "wilton_staff1_sanitycost",
        label = "骨杖理智消耗 / Bone Staff Sanity Cost",
        hover = "施放骨杖复活技能时消耗的理智值（0/20/50/80/100）。/ Sanity cost for casting the [Bone Staff] revive spell.",
        options =
        {
            {description = "0", data = 0},
            {description = "20", data = 20},
            {description = "50", data = 50},
            {description = "80", data = 80},
            {description = "100", data = 100},
        },
        default = 20,
    },

    --- 骨杖复活法阵冷却时间 / Bone Staff Cooldown.
    -- 影响威尔顿施放骨杖一技能（群体复活）后的冷却时间，0 为无冷却。
    {
        name = "wilton_staff1_cooldown",
        label = "骨杖冷却时间 / Bone Staff Cooldown",
        hover = "施放骨杖复活技能后的冷却时间（无冷却/30/60/120 秒）。/ Cooldown for the [Bone Staff] revive spell (No CD/30/60/120 seconds).",
        options =
        {
            {description = "无冷却 / No Cooldown", data = 0},
            {description = "30 秒 / 30 s", data = 30},
            {description = "60 秒 / 60 s", data = 60},
            {description = "120 秒 / 120 s", data = 120},
        },
        default = 60,
    },

    --- 死亡权杖位面伤害 / Death Scepter Planar Damage.
    -- 控制死亡权杖及其皮肤的位面伤害强度（planardamage），不影响物理 10 点基础伤害。
    {
        name = "wilton_staff2_planardamage",
        label = "死亡权杖位面伤害 / Death Scepter Planar Damage",
        hover = "设置死亡权杖的位面伤害数值（40/50/60）。/ Planar damage for the [Death Scepter] (40/50/60).",
        options =
        {
            {description = "40", data = 40},
            {description = "50", data = 50},
            {description = "60", data = 60},
        },
        default = 40,
    },

    --- 苏生权杖位面伤害 / Resurrection Scepter Planar Damage.
    -- 控制苏生权杖及其皮肤的位面伤害强度（planardamage），不影响物理 10 点基础伤害。
    {
        name = "wilton_staff3_planardamage",
        label = "苏生权杖位面伤害 / Resurrection Scepter Planar Damage",
        hover = "设置苏生权杖的位面伤害数值（60/70/80）。/ Planar damage for the [Resurrection Scepter] (60/70/80).",
        options =
        {
            {description = "60", data = 60},
            {description = "70", data = 70},
            {description = "80", data = 80},
        },
        default = 60,
    },

    Title("其他设置 / Other Settings"),

    --- 玩家死亡后是否掉落人肉。
    -- 仅对本模组的死亡掉落逻辑生效，不影响游戏本体默认设置。
    {
        name = "wilton_drop_humanmeat",
        label = "掉落人肉 / Drop Human Meat",
        hover = "关闭后玩家死亡将不再掉落人肉 / Disable to prevent players from dropping human meat on death.",
        options =
        {
            {description = "关 / Off", data = false},
            {description = "开 / On", data = true},
        },
        default = true,
    },
}