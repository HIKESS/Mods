local _locale = locale or ""
local _is_chinese = _locale == "zh" or _locale == "zhs" or _locale == "zht"
                 or _locale == "schinese" or _locale == "tchinese"

name = _is_chinese and "橘子的NPC小伙伴" or "NPC Friends"

if _is_chinese then
description = [[
在饥荒世界中生成多位性格各异的 NPC 小伙伴。
部分守在大门附近，部分散布在世界各个角落——找到他们，喂一口食物，就能招募为永久同伴！
【招募系统】
喂食任意食物即可招募 NPC，从此忠诚跟随。
不想要了？右键解除跟随，他们会乖乖留在原地等待下一位冒险家。
【智能战斗 AI】
目前还是傻傻的，但希望能帮助到萌新。
NPC 拥有走位闪避系统，包括后退、侧移、绕圈等模式。
【灵魂系统】
NPC 死亡不会消失！变为半透明灵魂持续跟随，缓慢回血后自动复活。
温蒂则变身为阿比盖尔继续战斗。
【工作系统】
NPC 会跟着你一起砍树、挖矿、采集，看到你在干活就会自动帮忙。
【丰富对话】
NPC 在战斗、工作、闲逛、受伤等各种情况下都有对话，自动匹配游戏语言。
]]
else
description = [[
Multiple NPC companions are generated throughout the Don't Starve world.
Some wait near the portal, others are scattered across the world — find them, feed them any food, and recruit them as your permanent companions!
[Recruitment System]
Feed any food to recruit an NPC — they'll follow you loyally from then on.
Don't want them anymore? Right-click to dismiss, and they'll stay put, waiting for the next adventurer.
[Smart Combat AI]
Still a bit clumsy for now, but hopefully helpful for new players.
NPCs have a dodge system with backstep, sidestep, and orbit modes.
[Ghost System]
NPCs don't disappear on death! They become translucent ghosts that keep following you, slowly regenerating until they auto-revive.
Wendy transforms into Abigail and continues fighting.
[Work System]
NPCs will chop trees, mine rocks, and gather items alongside you — they start helping automatically when they see you working.
[Rich Dialogue]
NPCs have lines for combat, work, wandering, taking damage, and more — language is automatically matched to your game settings.
]]
end
author = "我给你们去买橘子♡"
version = "0.2.6"

api_version = 10
dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

icon_atlas = "modicon.xml"
icon = "modicon.tex"          

server_filter_tags = {"companion", "npcfriends"}

configuration_options = {
    {
        name = "combat_hotkey",
        label = _is_chinese and "战斗面板快捷键" or "Combat Panel Hotkey",
        hover = _is_chinese and "打开/关闭 NPC 战斗设置面板的快捷键" or "Hotkey to toggle NPC combat settings panel",
        options = {
            { description = "R (默认 / Default)", data = "R" },
            { description = "F1",  data = "F1" },
            { description = "F2",  data = "F2" },
            { description = "F3",  data = "F3" },
            { description = "F4",  data = "F4" },
            { description = "F5",  data = "F5" },
            { description = "F6",  data = "F6" },
            { description = "F7",  data = "F7" },
            { description = "F8",  data = "F8" },
            { description = "F9",  data = "F9" },
            { description = "F10", data = "F10" },
            { description = "F11", data = "F11" },
            { description = "F12", data = "F12" },
        },
        default = "R",
    },

    {
        name = "max_followers",
        label = _is_chinese and "最大跟随人数" or "Max Followers",
        hover = _is_chinese and "每位玩家同时可携带的 NPC 伙伴上限" or "Max NPC companions per player",
        options = {
            { description = "1", data = 1 },
            { description = "2", data = 2 },
            { description = "3", data = 3 },
            { description = "4", data = 4 },
            { description = "5", data = 5 },
        },
        default = 2,
    },

    {
        name = "affinity_system",
        label = _is_chinese and "好感度系统" or "Affinity System",
        hover = _is_chinese and "关闭后所有 NPC 回到原始行为，不受好感度影响" or "When off, all NPCs behave as original, unaffected by affinity",
        options = {
            { description = _is_chinese and "开启" or "Enable",  data = true },
            { description = _is_chinese and "关闭" or "Disable", data = false },
        },
        default = true,
    },

    {
        name = "title_boss",
        label = _is_chinese and "启用/禁用 NPC 只在开新档生效" or "NPCs only applies when creating a new world",
        options = {
            {
                description = _is_chinese
                    and "━━━━━━━━━━━━━━━━━━"
                    or "━━━━━━━━━━━━━━━━━━",
                data = true,
            },
        },
        default = true,
    },
    -- 角色开关（大门附近生成）
    {
        name = "npc_wilson",
        label = _is_chinese and "威尔逊 (Wilson)" or "Wilson",
        hover = _is_chinese and "启用或禁用威尔逊 NPC" or "Enable or disable Wilson NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wormwood",
        label = _is_chinese and "沃姆伍德 (Wormwood)" or "Wormwood",
        hover = _is_chinese and "启用或禁用沃姆伍德 NPC" or "Enable or disable Wormwood NPC",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_warly",
        label = _is_chinese and "沃利 (Warly)" or "Warly",
        hover = _is_chinese and "启用或禁用沃利 NPC" or "Enable or disable Warly NPC",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_woodie",
        label = _is_chinese and "伍迪 (Woodie)" or "Woodie",
        hover = _is_chinese and "启用或禁用伍迪" or "Enable or disable Woodie NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wes",
        label = _is_chinese and "韦斯 (Wes)" or "Wes",
        hover = _is_chinese and "启用或禁用韦斯 NPC" or "Enable or disable Wes NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wortox",
        label = _is_chinese and "沃托克斯 (Wortox)" or "Wortox",
        hover = _is_chinese and "启用或禁用沃托克斯 NPC" or "Enable or disable Wortox NPC",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wendy",
        label = _is_chinese and "温蒂 (Wendy)" or "Wendy",
        hover = _is_chinese and "启用或禁用温蒂 NPC" or "Enable or disable Wendy NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wickerbottom",
        label = _is_chinese and "薇克巴顿 (Wickerbottom)" or "Wickerbottom",
        hover = _is_chinese and "启用或禁用薇克巴顿 NPC" or "Enable or disable Wickerbottom NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_willow",
        label = _is_chinese and "薇洛 (Willow)" or "Willow",
        hover = _is_chinese and "启用或禁用薇洛 NPC" or "Enable or disable Willow NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_waxwell",
        label = _is_chinese and "麦斯威尔 (Waxwell)" or "Waxwell",
        hover = _is_chinese and "启用或禁用麦斯威尔 NPC" or "Enable or disable Waxwell NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wathgrithr",
        label = _is_chinese and "薇格弗德 (Wathgrithr)" or "Wathgrithr",
        hover = _is_chinese and "启用或禁用薇格弗德 NPC" or "Enable or disable Wathgrithr NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wolfgang",
        label = _is_chinese and "沃尔夫冈 (Wolfgang)" or "Wolfgang",
        hover = _is_chinese and "启用或禁用沃尔夫冈 NPC" or "Enable or disable Wolfgang NPC",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_walter",
        label = _is_chinese and "沃尔特 (Walter)" or "Walter",
        hover = _is_chinese and "启用或禁用沃尔特 NPC" or "Enable or disable Walter NPC",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wx78",
        label = _is_chinese and "WX-78" or "WX-78",
        hover = _is_chinese and "启用或禁用 WX-78 NPC" or "Enable or disable WX-78 NPC",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_winona",
        label = _is_chinese and "薇诺娜 (Winona)" or "Winona",
        hover = _is_chinese and "启用或禁用薇诺娜 NPC" or "Enable or disable Winona NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wanda",
        label = _is_chinese and "旺达 (Wanda)" or "Wanda",
        hover = _is_chinese and "启用或禁用旺达 NPC" or "Enable or disable Wanda NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wonkey",
        label = _is_chinese and "芜猴 (Wonkey)" or "Wonkey",
        hover = _is_chinese and "启用或禁用芜猴 NPC" or "Enable or disable Wonkey NPC",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wilba",
        label = _is_chinese and "薇尔芭 (Wilba)" or "Wilba",
        hover = _is_chinese and "启用或禁用薇尔芭 NPC" or "Enable or disable Wilba NPC ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_webber",
        label = _is_chinese and "韦伯 (Webber)" or "Webber",
        hover = _is_chinese and "启用或禁用敌对韦伯" or "Enable or disable hostile Webber",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "npc_wurt",
        label = _is_chinese and "沃特 (Wurt)" or "Wurt",
        hover = _is_chinese and "启用或禁用敌对沃特" or "Enable or disable hostile Wurt ",
        options = {
            { description = _is_chinese and "启用" or "Enable", data = true },
            { description = _is_chinese and "禁用" or "Disable", data = false },
        },
        default = true,
    },
    {
        name = "title_boss_2",
        label = _is_chinese and "音效部分" or "━━━━━━",
        options = {
            {
                description = _is_chinese
                    and "━━━━━━━━━━━━━━━━━━"
                    or "━━━━━━━━━━━━━━━━━━",
                data = true,
            },
        },
        default = true,
    },
}




-- ── 每角色语音(TTS)开关（默认开启，关闭后该角色不播放语音）──────────
local _voice_chars = {
    { "wilson",       _is_chinese and "威尔逊 (Wilson)"        or "Wilson" },
    { "wormwood",     _is_chinese and "沃姆伍德 (Wormwood)"    or "Wormwood" },
    { "warly",        _is_chinese and "沃利 (Warly)"           or "Warly" },
    { "woodie",       _is_chinese and "伍迪 (Woodie)"          or "Woodie" },
    { "wes",          _is_chinese and "韦斯 (Wes)"             or "Wes" },
    { "winona",       _is_chinese and "薇诺娜 (Winona)"        or "Winona" },
    { "wendy",        _is_chinese and "温蒂 (Wendy)"           or "Wendy" },
    { "wickerbottom", _is_chinese and "薇克巴顿 (Wickerbottom)" or "Wickerbottom" },
    { "willow",       _is_chinese and "薇洛 (Willow)"          or "Willow" },
    { "waxwell",      _is_chinese and "麦斯威尔 (Waxwell)"     or "Waxwell" },
    { "wathgrithr",   _is_chinese and "薇格弗德 (Wathgrithr)"  or "Wathgrithr" },
    { "wolfgang",     _is_chinese and "沃尔夫冈 (Wolfgang)"    or "Wolfgang" },
    { "walter",       _is_chinese and "沃尔特 (Walter)"        or "Walter" },
    { "wortox",       _is_chinese and "沃托克斯 (Wortox)"      or "Wortox" },
    { "wanda",        _is_chinese and "旺达 (Wanda)"           or "Wanda" },
    { "webber",       _is_chinese and "韦伯 (Webber)"          or "Webber" },
    { "wurt",         _is_chinese and "沃特 (Wurt)"            or "Wurt" },
    { "wx78",         "WX-78" },
    { "wonkey",       _is_chinese and "芜猴 (Wonkey)"          or "Wonkey" },
    { "wilba",        _is_chinese and "薇尔芭 (Wilba)"         or "Wilba" },
}
if _is_chinese then
    configuration_options[#configuration_options + 1] = {
        name = "voice_mode",
        label = "声音模式",
        hover = "选择 NPC 说话时使用原版角色音效，或播放当前抽象版配音",
        options = {
            { description = "抽象版", data = "abstract" },
            { description = "原版", data = "original" },
        },
        default = "original",
    }

    for _i = 1, #_voice_chars do
        local _vc = _voice_chars[_i]
        configuration_options[#configuration_options + 1] = {
            name = "voice_" .. _vc[1],
            label = "语音：" .. _vc[2],
            hover = "开启/关闭该角色的语音播放",
            options = {
                { description = "开启", data = true },
                { description = "关闭", data = false },
            },
            default = true,
        }
    end
end
