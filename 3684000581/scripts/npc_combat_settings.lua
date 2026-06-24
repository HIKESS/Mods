-- scripts/npc_combat_settings.lua

local NPC_TUNING = require("npc_tuning")

local M = {}

M.PERSIST_KEY = "npcfriends_combat_settings"

M.GROUPS = {
    { id = "core",   label_zh = "核心开关", label_en = "Core" },
    { id = "target", label_zh = "索敌 / 追击", label_en = "Targeting / Chase" },
    { id = "follow", label_zh = "跟随 / 回队", label_en = "Follow / Return" },
    { id = "kite",   label_zh = "闪避 / 走位", label_en = "Dodge / Kiting" },
    { id = "heal",   label_zh = "低血量撤退", label_en = "Low Health Retreat" },
}

M.DEFS = {
    {
        key = "auto_combat_enabled",
        type = "bool",
        default = true,
        group = "core",
        always_visible = true,
        label_zh = "自动战斗",
        label_en = "Auto Combat",
        help_zh = "开启时使用原本自动战斗逻辑；关闭后显示并启用下方自定义参数。",
        help_en = "Use the original automatic combat logic. Turn it off to show and apply custom settings.",
    },
    {
        key = "stop_attack",
        type = "bool",
        default = false,
        group = "core",
        label_zh = "停止攻击",
        label_en = "Stop Attacking",
        help_zh = "清空友方 NPC 目标，并阻止它们主动索敌或跟随领队开战。\n本项是战斗总闸：ON 时下面所有战斗相关参数都会变灰。",
        help_en = "Clear friendly NPC targets and prevent automatic retargeting or leader combat assist.\nMaster combat switch: when ON, all combat-related options below are greyed out.",
    },
    {
        key = "assist_leader",
        type = "bool",
        default = false,
        group = "core",
        disabled_by_on = { "mirror_leader_combat", "stop_attack" },
        label_zh = "强制跟随玩家攻击",
        label_en = "Follow Player Attacks",
        help_zh = "开启后额外跟随玩家主动攻击/切换目标；关闭后仍保留 NPC 原本战斗逻辑，包括保护被攻击的领队。\n与「镜像跟随玩家攻击」互斥：本项 ON 时镜像不可用。",
        help_en = "Adds player attack/switch-target assist when enabled. Turning it off keeps normal NPC combat, including protecting an attacked leader.\nMutually exclusive with Mirror Player Combat: Mirror is disabled while this is ON.",
    },
    {
        key = "kite_enabled",
        type = "bool",
        default = true,
        group = "core",
        disabled_by_on = { "mirror_leader_combat", "stop_attack" },
        label_zh = "启用闪避走位",
        label_en = "Enable Kiting",
        help_zh = "关闭后 NPC 会更接近站撸，只保留追击攻击。\n关闭时下方闪避/绕圈相关参数也会一起变灰。",
        help_en = "Disable dodge decisions and keep basic chase/attack behavior.\nWhile OFF, dodge/orbit parameters below are also greyed out.",
    },
    {
        key = "mirror_leader_combat",
        type = "bool",
        default = false,
        group = "core",
        hidden = true,
        disabled_by_on = { "assist_leader", "stop_attack" },
        label_zh = "镜像跟随玩家攻击",
        label_en = "Mirror Player Combat",
        help_zh = "开启后 NPC 只攻击玩家正在打的目标，并始终站到玩家所在的一侧、用自己的攻击距离贴怪输出（多 NPC 自动错开角度）。\n玩家与目标超过「战斗回队距离」时 NPC 自动放弃目标回到跟随。\n开启时将忽略：启用闪避走位、强制跟随玩家攻击、NPC 互助、索敌/追击/绕圈所有参数。\n不影响：低血撤退、自动换装、各角色技能（万达返老/沃克斯丢魂/鹿人冲撞等）。\n与「强制跟随玩家攻击」「停止攻击」互斥。",
        help_en = "NPC only attacks the player's current target. It positions on the player's side of the enemy at its OWN attack range (multiple NPCs spread by GUID-based angle offset).\nNPC drops the target if leader-to-target distance exceeds Combat Return Distance.\nWhile enabled, the following are ignored: Enable Kiting, Follow Player Attacks, NPC Assist, all targeting/chase/orbit parameters.\nDoes NOT affect: Heal Retreat, Auto Equip, character skills (Wanda rejuvenate / Wortox soul heal / Weremoose tackle, etc.).\nMutually exclusive with Follow Player Attacks and Stop Attacking.",
    },
    {
        key = "assist_npcs",
        type = "bool",
        default = true,
        group = "core",
        disabled_by_on = { "mirror_leader_combat", "stop_attack" },
        label_zh = "NPC 互助",
        label_en = "NPC Assist",
        help_zh = "附近 NPC 或召唤物被攻击时，其他 NPC 会帮忙。",
        help_en = "Nearby NPCs help each other and their summons.",
    },
    {
        key = "auto_equip_combat",
        type = "bool",
        default = true,
        group = "core",
        hidden = true,
        label_zh = "战斗自动换装",
        label_en = "Auto Equip",
        help_zh = "进入战斗时自动装备更好的武器与护甲。",
        help_en = "Automatically equip better weapons and armor in combat.",
    },
    {
        key = "auto_heal_retreat",
        type = "bool",
        default = true,
        group = "core",
        label_zh = "低血撤退回血",
        label_en = "Heal Retreat",
        help_zh = "低血量时脱战撤退并尝试吃治疗食物。\n关闭时下方「低血量撤退」组的参数会一起变灰。",
        help_en = "Retreat and eat healing food when low on health.\nWhile OFF, parameters in Low Health Retreat group are greyed out.",
    },
    {
        key = "auto_revive_amulet_enabled",
        type = "bool",
        default = true,
        group = "core",
        label_zh = "检查生命项链复活",
        label_en = "Check Life Amulet Revive",
        help_zh = "幽灵 NPC 是否检查周围地面生命项链并自动走过去复活。范围以幽灵 NPC 为中心。",
        help_en = "Ghost NPCs check nearby life amulets on the ground and walk to revive. The range is centered on the ghost NPC.",
    },
    {
        key = "auto_revive_amulet_range",
        type = "number",
        default = 25,
        min = 5,
        max = 60,
        step = 1,
        group = "core",
        requires_on = "auto_revive_amulet_enabled",
        label_zh = "生命项链检查范围",
        label_en = "Life Amulet Check Range",
        help_zh = "幽灵 NPC 搜索地面生命项链的半径；实际以幽灵 NPC 自己为圆心。",
        help_en = "Search radius for life amulets on the ground. The circle is centered on the ghost NPC.",
    },
    {
        key = "show_advanced_settings",
        type = "bool",
        default = false,
        group = "core",
        ui_only = true,
        label_zh = "测试数据（不要修改）",
        label_en = "Test Data (Do Not Modify)",
        help_zh = "显示索敌、闪避、回血等测试参数；一般玩家不建议修改。",
        help_en = "Show test parameters for targeting, dodging, and healing. Not recommended for normal play.",
    },

    { key = "chase_range", type = "number", default = 20, min = 5, max = 40, step = 1, group = "target", tuning_key = "CHASE_RANGE", advanced = true, disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "主动找怪范围", label_en = "Target Search Range" },
    { key = "max_chase_dist", type = "number", default = 20, min = 5, max = 50, step = 1, group = "target", tuning_key = "MAX_CHASE_DIST", advanced = true, disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "追击放弃距离", label_en = "Chase Give-up Distance" },
    { key = "max_chase_time", type = "number", default = 10, min = 1, max = 60, step = 1, group = "target", tuning_key = "MAX_CHASE_TIME", advanced = true, disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "追击放弃时间", label_en = "Chase Give-up Time" },
    { key = "retarget_interval", type = "number", default = 0.5, min = 0.2, max = 3, step = 0.1, group = "target", tuning_key = "RETARGET_INTERVAL", advanced = true, disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "重新找怪间隔", label_en = "Retarget Interval" },
    { key = "npc_assist_range", type = "number", default = 20, min = 0, max = 40, step = 1, group = "target", tuning_key = "NPC_ASSIST_RANGE", advanced = true, requires_on = "assist_npcs", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "队友互助范围", label_en = "NPC Assist Range" },

    { key = "follow_min", type = "number", default = 0, min = 0, max = 10, step = 1, group = "follow", tuning_key = "FOLLOW_MIN", advanced = true, label_zh = "跟随最近距离", label_en = "Follow Min" },
    { key = "follow_target", type = "number", default = 3, min = 1, max = 15, step = 1, group = "follow", tuning_key = "FOLLOW_TARGET", advanced = true, label_zh = "跟随理想距离", label_en = "Follow Target" },
    { key = "follow_max", type = "number", default = 20, min = 5, max = 40, step = 1, group = "follow", tuning_key = "FOLLOW_MAX", advanced = true, label_zh = "跟随追赶距离", label_en = "Follow Catch-up Distance" },
    { key = "max_leader_dist_in_combat", type = "number", default = 18, min = 7, max = 40, step = 1, group = "follow", tuning_key = "KITE_MAX_LEADER_DIST", disabled_by_on = { "stop_attack" }, label_zh = "战斗回队距离", label_en = "Combat Return Distance" },
    { key = "force_follow_break_combat_dist", type = "number", default = 12, min = 3, max = 40, step = 1, group = "follow", hidden = true, label_zh = "强制跟随脱战距离", label_en = "Force Follow Break Dist" },

    { key = "dodge_dist", type = "number", default = 6, min = 1, max = 15, step = 1, group = "kite", tuning_key = "KITE_DODGE_DIST", advanced = true, requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "闪避位移", label_en = "Dodge Distance" },
    { key = "safe_dist", type = "number", default = 6, min = 1, max = 20, step = 1, group = "kite", tuning_key = "KITE_SAFE_DIST", advanced = true, requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "闪避安全距离", label_en = "Dodge Safe Distance" },
    { key = "dodge_timeout", type = "number", default = 2, min = 0.5, max = 8, step = 0.5, group = "kite", tuning_key = "KITE_DODGE_TIMEOUT", advanced = true, requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "闪避超时", label_en = "Dodge Timeout" },
    { key = "dodge_threshold", type = "number", default = 0, min = 0, max = 2, step = 0.1, group = "kite", tuning_key = "KITE_DODGE_THRESHOLD", advanced = true, requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "预判闪避阈值", label_en = "Dodge Threshold" },
    { key = "unknown_creature_learning_dodge", type = "bool", default = true, group = "kite", tuning_key = "UNKNOWN_CREATURE_LEARNING_DODGE", requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "未知生物学习闪避", label_en = "Unknown Learning Dodge", help_zh = "关闭时，未写入怪物数据表的生物按原逻辑近身攻击；开启后启用保守的临时学习闪避。", help_en = "When disabled, creatures missing combat data use normal close-range attacks. Enable to use conservative runtime learning dodge." },
    { key = "overwhelm_count", type = "number", default = 5, min = 1, max = 12, step = 1, group = "kite", tuning_key = "KITE_OVERWHELM_COUNT", advanced = true, requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "被围改站撸数量", label_en = "Overwhelm Count" },
    { key = "orbit_radius", type = "number", default = 10, min = 3, max = 20, step = 1, group = "kite", tuning_key = "KITE_ORBIT_RADIUS", advanced = true, requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "绕圈半径", label_en = "Orbit Radius" },
    { key = "orbit_timeout", type = "number", default = 6, min = 1, max = 15, step = 1, group = "kite", tuning_key = "KITE_ORBIT_TIMEOUT", advanced = true, requires_on = "kite_enabled", disabled_by_on = { "mirror_leader_combat", "stop_attack" }, label_zh = "绕圈超时", label_en = "Orbit Timeout" },

    { key = "heal_low_threshold", type = "number", default = 0.3, min = 0.05, max = 0.9, step = 0.05, group = "heal", tuning_key = "HEAL_LOW_THRESHOLD", percent = true, requires_on = "auto_heal_retreat", label_zh = "低血撤退血量", label_en = "Retreat Health" },
    { key = "heal_full_threshold", type = "number", default = 0.9, min = 0.1, max = 1, step = 0.05, group = "heal", tuning_key = "HEAL_FULL_THRESHOLD", percent = true, requires_on = "auto_heal_retreat", label_zh = "回血回战血量", label_en = "Return Health" },
    { key = "heal_retreat_dist", type = "number", default = 12, min = 3, max = 30, step = 1, group = "heal", tuning_key = "HEAL_RETREAT_DIST", requires_on = "auto_heal_retreat", label_zh = "低血撤退距离", label_en = "Retreat Distance" },
    { key = "heal_safe_dist", type = "number", default = 5, min = 1, max = 20, step = 1, group = "heal", tuning_key = "HEAL_SAFE_DIST", advanced = true, requires_on = "auto_heal_retreat", label_zh = "回血安全距离", label_en = "Heal Safe Distance" },
    {
        key = "heal_food_prefab",
        type = "enum",
        default = "perogies",
        options = {
            { value = "perogies", label_zh = "波兰水饺", label_en = "Pierogi" },
        },
        group = "heal",
        tuning_key = "HEAL_FOOD_PREFAB",
        requires_on = "auto_heal_retreat",
        label_zh = "治疗食物",
        label_en = "Healing Food",
    },
}

M.DEFS_BY_KEY = {}
for _, def in ipairs(M.DEFS) do
    M.DEFS_BY_KEY[def.key] = def
end

local function IsChineseLanguage()
    local strings = STRINGS
    local ui = strings ~= nil and strings.UI or nil
    local mainscreen = ui ~= nil and ui.MAINSCREEN or nil
    local play = mainscreen ~= nil and mainscreen.PLAY or nil
    return type(play) == "string" and play:match("[\228-\233]") ~= nil
end

function M.GetDefaultSettings()
    local values = {}
    for _, def in ipairs(M.DEFS) do
        values[def.key] = def.default
    end
    return values
end

local function ClampNumber(value, def)
    local n = tonumber(value)
    if n == nil then
        return def.default
    end
    if def.min ~= nil and n < def.min then n = def.min end
    if def.max ~= nil and n > def.max then n = def.max end
    if def.step ~= nil and def.step > 0 then
        n = math.floor((n / def.step) + 0.5) * def.step
    end
    if math.abs(n - math.floor(n + 0.5)) < 0.0001 then
        n = math.floor(n + 0.5)
    end
    return n
end

function M.NormalizeValue(key, value)
    local def = M.DEFS_BY_KEY[key]
    if def == nil then
        return nil
    end
    if def.type == "bool" then
        return value == true or value == "true" or value == "1" or value == 1
    elseif def.type == "number" then
        return ClampNumber(value, def)
    elseif def.type == "enum" then
        local s = tostring(value or def.default)
        for _, opt in ipairs(def.options or {}) do
            local opt_value = type(opt) == "table" and opt.value or opt
            if s == opt_value then return s end
        end
        return def.default
    end
    return value
end

function M.NormalizeSettings(values)
    local normalized = M.GetDefaultSettings()
    if type(values) == "table" then
        for _, def in ipairs(M.DEFS) do
            if values[def.key] ~= nil then
                normalized[def.key] = M.NormalizeValue(def.key, values[def.key])
            end
        end
    end
    if normalized.stop_attack == true then
        normalized.mirror_leader_combat = false
        normalized.assist_leader = false
    elseif normalized.mirror_leader_combat == true and normalized.assist_leader == true then
        normalized.assist_leader = false
    end
    return normalized
end

function M.IsVisibleInUI(def, values)
    if def == nil or def.hidden then
        return false
    end
    if def.key == "auto_combat_enabled" then
        return true
    end
    if values ~= nil and values.auto_combat_enabled == true then
        return false
    end
    if def.key == "show_advanced_settings" and values ~= nil and values.show_advanced_settings == true then
        return false
    end
    if def.advanced and not (values ~= nil and values.show_advanced_settings == true) then
        return false
    end
    return true
end


function M.IsControlEnabled(def, values)
    if def == nil or values == nil then
        return true
    end
    if def.requires_on and values[def.requires_on] ~= true then
        return false
    end
    if def.disabled_by_on then
        for _, other_key in ipairs(def.disabled_by_on) do
            if values[other_key] == true then
                return false
            end
        end
    end
    return true
end

function M.Encode(values)
    local normalized = M.NormalizeSettings(values)
    local parts = {}
    for _, def in ipairs(M.DEFS) do
        local v = normalized[def.key]
        if def.type == "bool" then
            v = v and "true" or "false"
        else
            v = tostring(v)
        end
        parts[#parts + 1] = def.key .. "=" .. v
    end
    return table.concat(parts, ";")
end

function M.Decode(data)
    local values = {}
    local has_return_dist = false
    if type(data) == "string" then
        for entry in data:gmatch("[^;]+") do
            local key, raw = entry:match("^([^=]+)=(.*)$")
            if key ~= nil and M.DEFS_BY_KEY[key] ~= nil then
                values[key] = M.NormalizeValue(key, raw)
                if key == "max_leader_dist_in_combat" then
                    has_return_dist = true
                end
            end
        end
    end
    if not has_return_dist and values.force_follow_break_combat_dist ~= nil then
        values.max_leader_dist_in_combat = values.force_follow_break_combat_dist
    end
    return M.NormalizeSettings(values)
end

function M.GetLabel(def)
    return (IsChineseLanguage() and def.label_zh) or def.label_en or def.key
end

function M.GetHelp(def)
    return (IsChineseLanguage() and def.help_zh) or def.help_en or ""
end

function M.GetOptionValue(option)
    return type(option) == "table" and option.value or option
end

function M.GetOptionLabel(def, value)
    if def == nil or def.type ~= "enum" then
        return tostring(value or "")
    end
    local s = tostring(value or def.default)
    for _, option in ipairs(def.options or {}) do
        local opt_value = M.GetOptionValue(option)
        if s == opt_value then
            if type(option) == "table" then
                return (IsChineseLanguage() and option.label_zh) or option.label_en or opt_value
            end
            return tostring(opt_value or "")
        end
    end
    return s
end

return M
