-- scripts/npc/npc_affinity.lua
-- NPC 好感度模块：每个 NPC 实例独立维护 0..MAX 好感度。

local npc_affinity = {}

npc_affinity.MAX_AFFINITY = 400

-- 好感度系统总开关：读 _G.NPCFRIENDS.affinity_enabled（lazy，避免 require 顺序问题）。
function npc_affinity.IsEnabled()
    local cfg = rawget(_G, "NPCFRIENDS")
    return cfg == nil or cfg.affinity_enabled ~= false
end

-- 死亡好感度惩罚
npc_affinity.DEATH_PENALTY = 10

npc_affinity.DEFAULT_FOOD_GAIN = 1

local DEFAULT_THRESHOLDS = {
    follow = 1,
}

local DEFAULT_COMMAND_KEYS = {
    Follow = "follow",
}

-- 角色好感度配置（key = 角色 prefab 名）
--   food_gain         : 指定食物 prefab → 好感度增量
--   default_food_gain : 其它可食用食物的默认增量
--   thresholds        : 各能力解锁门槛（语义键 → 当前好感度 >= 门槛 即解锁）
--   command_keys      : NPCCommand 命令名 → thresholds 里的语义键。
--                       用于"自动识别所有 NPC 的制作/技能命令好感度门槛"：
--                       配了映射的命令会在 UI 按键与命令派发处被统一门控，
--                       新增角色只需在此补配置，无需改动各能力 checker / 命令处理函数。
local AFFINITY_DEFS = {
    wilson = {
        food_gain = { baconeggs = 10 },
        default_food_gain = 1,
        thresholds = { follow = 0, show_locations = 10, fishing = 100, craft = 300 },
        command_keys = {
            WilsonShowNPCLocations    = "show_locations",
            FishHere                  = "fishing",
            WilsonCraftPureBrilliance = "craft",
            WilsonCraftHorrorfuel     = "craft",
        },
    },
    wathgrithr = {
        -- 只吃肉，专属食物：火鸡正餐 +10
        food_gain = { turkeydinner = 10 },
        default_food_gain = 1,
        thresholds = { follow = 1, craft_spear = 30, craft_helmet = 50, battle_song = 300 },
        command_keys = {
            WathgrithrCraftSpear  = "craft_spear",
            WathgrithrCraftHelmet = "craft_helmet",
        },
    },
    wortox = {
        -- 专属食物：石榴 / 熟石榴 +10
        food_gain = { pomegranate = 10, pomegranate_cooked = 10 },
        default_food_gain = 1,
        -- auto_heal：好感度 >= 100 才会自动灵魂回血
        thresholds = { follow = 1, auto_heal = 100 },
    },
    waxwell = {
        -- 专属食物：龙虾正餐 +10
        food_gain = { lobsterdinner = 10 },
        default_food_gain = 1,

        thresholds = { follow = 1, magic_chest = 30, shadow_protector = 50, shadow_pillar = 200 },
        command_keys = {
            BuildWaxwellMagicChest = "magic_chest",
        },
    },
    wickerbottom = {
        -- 专属食物：海鲜牛排 +10
        food_gain = { surfnturf = 10 },
        default_food_gain = 1,

        thresholds = { follow = 1, scholar_extinguish = 30, scholar_care = 50, grow_crops = 100 },
        command_keys = {
            WickerbottomGrowCrops = "grow_crops",
        },
    },

    -- 沃利：料理 +5，普通食材 +1；植物人：种子/烤种子 +3，其它食物 +1。
    -- 好感度 >=10 才能点"在此处工作"；开工后每分钟 -1，低于 10 自动停工（见 npc_commands 工作消耗逻辑）。
    warly = {
        default_food_gain = 1,
        initial = 0,  -- 【测试用】原值 100，测试完改回 100
        thresholds = { follow = 1, work_here = 6 },
        command_keys = { CookHere = "work_here" }, -- 在此处烹饪
    },
    wormwood = {
        default_food_gain = 1,
        initial = 0,  -- 【测试用】原值 100，测试完改回 100
        thresholds = { follow = 1, work_here = 6 },
        command_keys = { FarmHere = "work_here" }, -- 在此处种地
    },

    -- 以下角色仅配置专属熟食 +10；其余（默认喂食 +1、跟随门槛 1）走全局默认
    willow   = { food_gain = { hotchili         = 10 } }, -- 辣椒炖肉
    wx78     = { food_gain = { butterflymuffin = 10 }, thresholds = { follow = 1, leap = 10 } }, -- 蝴蝶松饼；好感度 >=10 解锁跳劈
    wolfgang = { food_gain = { potato_cooked    = 10 } }, -- 烤土豆
    wanda    = {
        food_gain = { taffy = 10 }, -- 太妃糖
        thresholds = { follow = 1, open_rift = 10 }, -- 好感度 >=10 开启裂隙
        command_keys = { OpenRift = "open_rift" },
    },
    wendy    = { food_gain = { bananapop = 10 }, thresholds = { follow = 1, fishing = 50 } }, -- 香蕉冻；好感度 >=50 解锁海钓
    winona   = {
        food_gain = { vegstinger = 10 }, -- 蔬菜鸡尾酒
        -- clean_here 好感度 >=1 激活"在此整理"；craft >=100 解锁制作专属栏
        thresholds = { follow = 1, clean_here = 1, craft = 100 },
        command_keys = {
            CleanHere       = "clean_here",
            WinonaCraftTape = "craft",
            PlaceGenerator  = "craft",
            PlaceSpotlight  = "craft",
            PlaceCatapult   = "craft",
        },
    },
    wes      = {
        food_gain = { freshfruitcrepes = 10 }, -- 鲜果可丽饼
        thresholds = { follow = 1, clean_here = 1 }, -- 好感度 >=1 激活"在此整理"
        command_keys = { CleanHere = "clean_here" },
    },
    walter   = {
        food_gain = { trailmix = 10 }, -- 什锦干果
        -- auto_story 好感度 >=1 开启自动讲故事；craft >=100 解锁制作弹药专属栏
        thresholds = { follow = 1, auto_story = 1, craft = 100 },
        command_keys = {
            ToggleWalterAutoStory       = "auto_story",
            WalterCraftGoldAmmo         = "craft",
            WalterCraftScrapfeatherAmmo = "craft",
            WalterCraftThuleciteAmmo    = "craft",
            WalterCraftHorrorfuelAmmo   = "craft",
            WalterCraftFreezeAmmo       = "craft",
            WalterCraftSlowAmmo         = "craft",
        },
    },
    woodie   = {
        food_gain = { honeynuggets = 10 }, -- 蜜汁卤肉
        thresholds = { follow = 1, chop_here = 10 }, -- 好感度 >=10 激活"在此处砍树"
        command_keys = { ChopHere = "chop_here" },
    },
    wonkey = {
        -- 专属食物：洞穴香蕉（生/熟）+10
        food_gain = { cave_banana = 10, cave_banana_cooked = 10 },
        -- craft_monkeytail ：好感度 >= 50 制作猴尾草苗
        -- craft_bananabush ：好感度 >= 100 制作香蕉树苗
        -- craft_ancienttree：好感度 >= 200 制作惊喜种子
        thresholds = { follow = 1, craft_monkeytail = 50, craft_bananabush = 100, craft_ancienttree = 200 },
        command_keys = {
            WonkeyCraftMonkeytail      = "craft_monkeytail",
            WonkeyCraftBananaBush      = "craft_bananabush",
            WonkeyCraftAncienttreeSeed = "craft_ancienttree",
        },
    },
    wilba    = {
        thresholds = { follow = 1, quest = 10 }, -- 好感度 >=10 开启任务按键
        command_keys = { OpenQuest = "quest" },
    },
}

npc_affinity.AFFINITY_DEFS = AFFINITY_DEFS

local function GetDef(char_type)
    return AFFINITY_DEFS[char_type or ""]
end

function npc_affinity.GetMax()
    return npc_affinity.MAX_AFFINITY
end

-- 取角色初始好感度（未配置返回 0）
function npc_affinity.GetInitialAffinity(char_type)
    local def = GetDef(char_type)
    return (def and def.initial) or 0
end

function npc_affinity.GetAffinity(inst)
    if not inst then return 0 end
    return inst._npc_affinity or 0
end

-- 设置好感度（钳制 0..MAX），返回最终值
function npc_affinity.SetAffinity(inst, value)
    if not inst then return 0 end
    local maxv = npc_affinity.MAX_AFFINITY
    value = math.max(0, math.min(maxv, math.floor(value or 0)))
    inst._npc_affinity = value
    return value
end

-- 增加好感度（可为负），钳制后返回最终值
function npc_affinity.AddAffinity(inst, delta)
    if not inst or not delta or delta == 0 then
        return npc_affinity.GetAffinity(inst)
    end
    local value = npc_affinity.SetAffinity(inst, npc_affinity.GetAffinity(inst) + delta)
    -- "太累了坐地上"恢复：好感度回升到可工作门槛时，结束疲劳坐姿。
    if inst._npc_tired then
        local need = npc_affinity.GetThreshold(inst.npc_character_type, "work_here")
        if need == nil or value >= need then
            inst._npc_tired = false
            inst._npc_tired_sit_variant = nil
            if inst._npc_tired_talk_task then
                inst._npc_tired_talk_task:Cancel()
                inst._npc_tired_talk_task = nil
            end
            if inst.sg and inst.sg:HasStateTag("idle")
               and not inst._is_ghost_mode
               and not (inst.components.health and inst.components.health:IsDead()) then
                inst.sg:GoToState("idle")  -- 刷新 idle，结束坐地动画
            end
        end
    end
    return value
end

local function IsPreparedFood(food)
    return food ~= nil and food.HasTag ~= nil and food:HasTag("preparedfood")
end

local function IsSeedFood(food_prefab)
    if food_prefab == nil then return false end
    return food_prefab == "seeds"
        or food_prefab == "seeds_cooked"
        or food_prefab:match("_seeds$") ~= nil
        or food_prefab:match("_seeds_cooked$") ~= nil
end

-- 取某食物对应的好感度增量。
-- 优先级：角色特殊规则 → 角色专属食物 → 角色默认增量 → 全局默认增量。
function npc_affinity.GetFoodGain(char_type, food_prefab, food)
    if char_type == "warly" then
        return IsPreparedFood(food) and 5 or 1
    elseif char_type == "wormwood" then
        return IsSeedFood(food_prefab) and 3 or 1
    end

    local def = GetDef(char_type)
    if def then
        if food_prefab and def.food_gain and def.food_gain[food_prefab] ~= nil then
            return def.food_gain[food_prefab]
        end
        if def.default_food_gain ~= nil then
            return def.default_food_gain
        end
    end
    return npc_affinity.DEFAULT_FOOD_GAIN or 0
end

-- 取某能力的解锁门槛。
-- 优先级：角色专属门槛 → 全局默认门槛（如 follow=1）；都没有返回 nil（表示不做门控）。
function npc_affinity.GetThreshold(char_type, key)
    local def = GetDef(char_type)
    if def and def.thresholds and def.thresholds[key] ~= nil then
        return def.thresholds[key]
    end
    return DEFAULT_THRESHOLDS[key]
end

-- 死亡好感度惩罚（所有 NPC 通用）：
--   · 好感度 >= 1：扣除 DEATH_PENALTY，但至少保留 1 点（不会被扣到 0）。
function npc_affinity.ApplyDeathPenalty(inst)
    local cur = npc_affinity.GetAffinity(inst)
    if cur <= 0 then
        return cur
    end
    local new = cur - (npc_affinity.DEATH_PENALTY or 0)
    if new < 1 then new = 1 end
    return npc_affinity.SetAffinity(inst, new)
end

-- 判断 NPC 当前好感度是否满足某能力门槛。
function npc_affinity.MeetsThreshold(inst, key)
    -- 关闭好感度系统时一律放行（所有能力无门槛 = 原始行为）
    if not npc_affinity.IsEnabled() then return true end
    if not inst then return false end
    local threshold = npc_affinity.GetThreshold(inst.npc_character_type, key)
    if threshold == nil then return true end
    return npc_affinity.GetAffinity(inst) >= threshold
end

-- 取某命令对应的门槛语义键。
-- 优先级：角色专属映射 → 全局默认映射（如 Follow→follow）；都没有返回 nil（不门控）。
function npc_affinity.GetCommandKey(char_type, command)
    local def = GetDef(char_type)
    if def and def.command_keys and def.command_keys[command] ~= nil then
        return def.command_keys[command]
    end
    return DEFAULT_COMMAND_KEYS[command]
end

-- 通用：判断某条 NPCCommand 命令当前是否解锁（好感度达标）。

function npc_affinity.CommandUnlocked(inst, command)
    if not npc_affinity.IsEnabled() then return true end
    if not inst then return false end
    local key = npc_affinity.GetCommandKey(inst.npc_character_type, command)
    if key == nil then return true end
    return npc_affinity.MeetsThreshold(inst, key)
end

return npc_affinity
