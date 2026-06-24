-- modmain.lua
-- NPCFriends Mod 主入口


-- ── 控制台调用 ──────────────────────────────────────────────
-- c_gonext("npcfriend") -- 切换到下一个 NPC（不分角色）
-- c_gonpc("wortox") -- 切换到指定角色 NPC（多只时按距离循环切换；不传参数则列出全部）
-- c_gonpc("woodie")
-- c_gonpc("wortox")
-- c_gonpc("wurt")
-- c_gonpc("wolfgang")
-- c_gonpc("wilba")


--c_spawnnpc()                  -- 看支持的角色列表
--c_spawnnpc("winona")
--c_spawnnpc("wendy")
--c_spawnnpc("wonkey")
--c_spawnnpc("wurt")
--c_spawnnpc("wilson")
--c_spawnnpc("wickerbottom")
--c_spawnnpc("wathgrithr")      -- 生成一个独立薇格弗德副本
--c_spawnnpc("wormwood")        -- 生成一个独立植物人副本
--npc_debug_dump()              -- 新副本，slot 是 10001/10002/...



-- ── 全局环境引用 ────────────────────────────────────────────
local _G = GLOBAL
local require = _G.require

local function IsChineseLanguage()
    local strings = _G.STRINGS
    local ui = strings ~= nil and strings.UI or nil
    local mainscreen = ui ~= nil and ui.MAINSCREEN or nil
    local play = mainscreen ~= nil and mainscreen.PLAY or nil
    return type(play) == "string" and play:match("[\228-\233]") ~= nil
end

_G.STRINGS = _G.STRINGS or {}
_G.STRINGS.NAMES = _G.STRINGS.NAMES or {}
_G.STRINGS.NAMES.NPC_RIFT_PORTAL = _G.STRINGS.NAMES.NPC_RIFT_PORTAL or "裂缝记忆点"
_G.STRINGS.NAMES.NPC_WAXWELL_MAGIC_CHEST = _G.STRINGS.NAMES.NPC_WAXWELL_MAGIC_CHEST or "麦斯威尔的魔术箱"
_G.STRINGS.NAMES.NPC_RAINBOW_FIREFLIES = _G.STRINGS.NAMES.NPC_RAINBOW_FIREFLIES
    or (IsChineseLanguage() and "七彩萤火虫" or "Rainbow Fireflies")
-- 任务按钮标签
_G.STRINGS.btn_wilba_quest = _G.STRINGS.btn_wilba_quest
    or (IsChineseLanguage() and "任务" or "Quests")
_G.STRINGS.CHARACTERS = _G.STRINGS.CHARACTERS or {}
_G.STRINGS.CHARACTERS.GENERIC = _G.STRINGS.CHARACTERS.GENERIC or {}
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE = _G.STRINGS.CHARACTERS.GENERIC.DESCRIBE or {}
_G.STRINGS.NAMES.SILVERNECKLACE = _G.STRINGS.NAMES.SILVERNECKLACE
    or (IsChineseLanguage() and "银项链" or "Silver Necklace")
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NPC_RAINBOW_FIREFLIES =
    _G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NPC_RAINBOW_FIREFLIES
    or (IsChineseLanguage() and "它的颜色每次都不一样。" or "Its color is different every time.")

-- ── 额外动画资源───────────────────────
Assets = {
    Asset("ANIM", "anim/weremoose_attacks.zip"),
    Asset("ANIM", "anim/weremoose_transform.zip"),
    Asset("ANIM", "anim/weremoose_poof_fx.zip"),   -- 变身/还原烟雾特效
    Asset("ANIM", "anim/round_puff_fx.zip"),
    Asset("ANIM", "anim/moonglasspool_tile_big.zip"), -- 池塘创建预览/实体资源
    Asset("ANIM", "anim/turf.zip"),                     -- 哈姆雷特地皮动画
    Asset("ANIM", "anim/turf_1.zip"),                   -- 哈姆雷特地皮动画(覆盖)
    Asset("ANIM", "anim/silvernecklace.zip"),         -- 薇尔芭银项链
    Asset("ANIM", "anim/torso_silvernecklace.zip"),   -- 薇尔芭银项链(身体换装)
    Asset("ANIM", "anim/werewilba.zip"),              -- 狼猪人外观 (bank/build)
    Asset("ANIM", "anim/werewilba_transform.zip"),    -- 狼猪人变身动画 (transform_pre/pst/reform)
    Asset("ANIM", "anim/bernie_fire_fx_lunar_build.zip"), -- 薇洛蓝色月焰
    Asset("ANIM", "anim/player_channelcast_basic.zip"),   -- 薇洛月焰施法动画（channelcast 持物版）

    -- 哈姆雷特物品 inv 图标 atlas（DLC0003/images/inventoryimages*.xml/tex 重命名后）
    -- hamlet_inv1: 含 jungleTreeSeed / teatree_nut / clawpalmtree_sapling 等种子图标
    -- hamlet_inv2: 含 turf_pigruins / turf_rainforest 等全部 13 种地皮图标
    Asset("ATLAS", "images/hamlet_inv1.xml"),
    Asset("IMAGE", "images/hamlet_inv1.tex"),
    Asset("ATLAS", "images/hamlet_inv2.xml"),
    Asset("IMAGE", "images/hamlet_inv2.tex"),

    -- 哈姆雷特4种树动画 (丛林树/雨林树/茶树/爪棕榈树)
    Asset("ANIM", "anim/tree_jungle_build.zip"),
    Asset("ANIM", "anim/tree_jungle_normal.zip"),
    Asset("ANIM", "anim/tree_jungle_short.zip"),
    Asset("ANIM", "anim/tree_jungle_tall.zip"),
    Asset("ANIM", "anim/jungletreeseed.zip"),
    Asset("ANIM", "anim/tree_rainforest_build.zip"),
    Asset("ANIM", "anim/tree_rainforest_normal.zip"),
    Asset("ANIM", "anim/tree_rainforest_short.zip"),
    Asset("ANIM", "anim/tree_rainforest_tall.zip"),
    Asset("ANIM", "anim/tree_rainforest_bloom_build.zip"),
    Asset("ANIM", "anim/tree_rainforest_gas_build.zip"),
    Asset("ANIM", "anim/tree_forest_rot_build.zip"),
    Asset("ANIM", "anim/tree_forest_bloom_build.zip"),
    Asset("ANIM", "anim/teatree_build.zip"),
    Asset("ANIM", "anim/teatree_trunk_build.zip"),
    Asset("ANIM", "anim/tree_leaf_short.zip"),
    Asset("ANIM", "anim/tree_leaf_normal.zip"),
    Asset("ANIM", "anim/tree_leaf_tall.zip"),
    Asset("ANIM", "anim/teatree_nut.zip"),
    Asset("ANIM", "anim/claw_tree_build.zip"),
    Asset("ANIM", "anim/claw_tree_normal.zip"),
    Asset("ANIM", "anim/claw_tree_short.zip"),
    Asset("ANIM", "anim/claw_tree_tall.zip"),
    Asset("ANIM", "anim/clawling.zip"),

    -- ── 哈姆雷特 13 种自定义 tile 的 ground/minimap 资源 ──────
    Asset("FILE",  "levels/tiles/hamlet_blocky.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_blocky.tex"),
    Asset("FILE",  "levels/tiles/hamlet_rain_forest.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_rain_forest.tex"),
    Asset("FILE",  "levels/tiles/hamlet_jungle_deep.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_jungle_deep.tex"),
    Asset("FILE",  "levels/tiles/hamlet_pebble.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_pebble.tex"),
    Asset("FILE",  "levels/tiles/hamlet_deciduous.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_deciduous.tex"),
    Asset("FILE",  "levels/tiles/hamlet_jungle.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_jungle.tex"),
    Asset("FILE",  "levels/tiles/hamlet_stoneroad.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_stoneroad.tex"),
    Asset("FILE",  "levels/tiles/hamlet_swamp.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_swamp.tex"),
    Asset("FILE",  "levels/tiles/hamlet_carpet.xml"),
    Asset("IMAGE", "levels/tiles/hamlet_carpet.tex"),
    -- 12 张 noise 贴图（与 atlas 配对，影响地面纹理细节）
    Asset("IMAGE", "levels/textures/hamlet_ground_ruins_slab.tex"),
    Asset("IMAGE", "levels/textures/hamlet_Ground_noise_rainforest.tex"),
    Asset("IMAGE", "levels/textures/hamlet_Ground_noise_jungle_deep.tex"),
    Asset("IMAGE", "levels/textures/hamlet_ground_noise_checkeredlawn.tex"),
    Asset("IMAGE", "levels/textures/hamlet_ground_noise_gas.tex"),
    Asset("IMAGE", "levels/textures/hamlet_noise_mossy_blossom.tex"),
    Asset("IMAGE", "levels/textures/hamlet_noise_farmland.tex"),
    Asset("IMAGE", "levels/textures/hamlet_noise_ruinsbrick_scaled.tex"),
    Asset("IMAGE", "levels/textures/hamlet_Ground_noise_cobbleroad.tex"),
    Asset("IMAGE", "levels/textures/hamlet_Ground_bog.tex"),
    Asset("IMAGE", "levels/textures/hamlet_Ground_plains.tex"),
    Asset("IMAGE", "levels/textures/hamlet_Ground_beard_hair.tex"),
}

-- ── NPC 语音(TTS)音频库 ──────────────────────────────────────
local TTS_AUDIO_CHARS = {
    "wilson",
    "wendy",
    "wathgrithr",
    "wolfgang",
    "wormwood",
    "warly",
    "wonkey",
    "wilba",
    "wanda",
    "waxwell",
    "winona",
    "woodie",
    "willow",
    "wickerbottom",
    "walter",
    "wx78",
    "wortox",
}
for _, _char in ipairs(TTS_AUDIO_CHARS) do
    table.insert(Assets, Asset("SOUNDPACKAGE", "sound/npc_" .. _char .. ".fev"))
    table.insert(Assets, Asset("SOUND", "sound/npc_" .. _char .. ".fsb"))
end


-- ════════════════════════════════════════════════════════════
--  哈姆雷特 13 种自定义地皮 tile 注册
-- ════════════════════════════════════════════════════════════

do
    -- short_name → tile 注册参数
    local HAMLET_TILES = {
        { short = "pigruins",                tile = "HAMLET_PIGRUINS",                ground_name = "Pig Ruins",                atlas = "hamlet_blocky",      noise = "hamlet_ground_ruins_slab",          sound = "dirt",      hard = true,  roadways = false },
        { short = "rainforest",              tile = "HAMLET_RAINFOREST",              ground_name = "Rainforest",               atlas = "hamlet_rain_forest", noise = "hamlet_Ground_noise_rainforest",    sound = "woods",     hard = false, roadways = false },
        { short = "deeprainforest",          tile = "HAMLET_DEEPRAINFOREST",          ground_name = "Deep Rainforest",          atlas = "hamlet_jungle_deep", noise = "hamlet_Ground_noise_jungle_deep",   sound = "woods",     hard = false, roadways = false },
        { short = "lawn",                    tile = "HAMLET_LAWN",                    ground_name = "Checkered Lawn",           atlas = "hamlet_pebble",      noise = "hamlet_ground_noise_checkeredlawn", sound = "grass",     hard = false, roadways = false },
        { short = "gasjungle",               tile = "HAMLET_GASJUNGLE",               ground_name = "Gas Jungle",               atlas = "hamlet_jungle_deep", noise = "hamlet_ground_noise_gas",           sound = "moss",      hard = false, roadways = false },
        { short = "moss",                    tile = "HAMLET_MOSS",                    ground_name = "Mossy Suburb",             atlas = "hamlet_deciduous",   noise = "hamlet_noise_mossy_blossom",        sound = "dirt",      hard = false, roadways = false },
        { short = "fields",                  tile = "HAMLET_FIELDS",                  ground_name = "Pig Fields",               atlas = "hamlet_jungle",      noise = "hamlet_noise_farmland",             sound = "woods",     hard = false, roadways = false },
        { short = "foundation",              tile = "HAMLET_FOUNDATION",              ground_name = "Pig Foundation",           atlas = "hamlet_blocky",      noise = "hamlet_noise_ruinsbrick_scaled",    sound = "slate",     hard = true,  roadways = false },
        { short = "cobbleroad",              tile = "HAMLET_COBBLEROAD",              ground_name = "Cobblestone Road",         atlas = "hamlet_stoneroad",   noise = "hamlet_Ground_noise_cobbleroad",    sound = "rock",      hard = true,  roadways = true  },
        { short = "painted",                 tile = "HAMLET_PAINTED",                 ground_name = "Painted Bog",              atlas = "hamlet_swamp",       noise = "hamlet_Ground_bog",                 sound = "sand",      hard = false, roadways = false },
        { short = "plains",                  tile = "HAMLET_PLAINS",                  ground_name = "Plains",                   atlas = "hamlet_jungle",      noise = "hamlet_Ground_plains",              sound = "tallgrass", hard = false, roadways = false },
        { short = "beard_hair",              tile = "HAMLET_BEARDRUG",                ground_name = "Beard Hair Rug",           atlas = "hamlet_carpet",      noise = "hamlet_Ground_beard_hair",          sound = "carpet",    hard = false, roadways = false },
        { short = "deeprainforest_nocanopy", tile = "HAMLET_DEEPRAINFOREST_NOCANOPY", ground_name = "Deep Rainforest No Canopy",atlas = "hamlet_jungle_deep", noise = "hamlet_Ground_noise_jungle_deep",   sound = "woods",     hard = false, roadways = false },
    }

    -- 移动音效预设（对应 vanilla 各种地面音）
    local SOUND_MAP = {
        dirt      = { run = "dontstarve/movement/run_dirt",      walk = "dontstarve/movement/walk_dirt",      snow = "dontstarve/movement/run_ice",  mud = "dontstarve/movement/run_mud" },
        woods     = { run = "dontstarve/movement/run_woods",     walk = "dontstarve/movement/walk_woods",     snow = "dontstarve/movement/run_snow", mud = "dontstarve/movement/run_mud" },
        grass     = { run = "dontstarve/movement/run_grass",     walk = "dontstarve/movement/walk_grass",     snow = "dontstarve/movement/run_snow", mud = "dontstarve/movement/run_mud" },
        tallgrass = { run = "dontstarve/movement/run_tallgrass", walk = "dontstarve/movement/walk_tallgrass", snow = "dontstarve/movement/run_snow", mud = "dontstarve/movement/run_mud" },
        moss      = { run = "dontstarve/movement/run_moss",      walk = "dontstarve/movement/walk_moss",      snow = "dontstarve/movement/run_ice",  mud = "dontstarve/movement/run_mud" },
        slate     = { run = "dontstarve/movement/run_slate",     walk = "dontstarve/movement/walk_slate",     snow = "dontstarve/movement/run_ice",  mud = "dontstarve/movement/run_mud" },
        rock      = { run = "dontstarve/movement/run_rock",      walk = "dontstarve/movement/walk_rock",      snow = "dontstarve/movement/run_ice",  mud = "dontstarve/movement/run_mud" },
        carpet    = { run = "dontstarve/movement/run_carpet",    walk = "dontstarve/movement/walk_carpet",    snow = "dontstarve/movement/run_snow", mud = "dontstarve/movement/run_mud" },
        sand      = { run = "dontstarve/movement/run_sand",      walk = "dontstarve/movement/walk_sand",      snow = "dontstarve/movement/run_snow", mud = "dontstarve/movement/run_sand" },
    }

    for _, def in ipairs(HAMLET_TILES) do
        local snd = SOUND_MAP[def.sound] or SOUND_MAP.dirt
        AddTile(
            def.tile,
            "LAND",
            { ground_name = def.ground_name },
            {
                name          = def.atlas,
                noise_texture = def.noise,
                runsound      = snd.run,
                walksound     = snd.walk,
                snowsound     = snd.snow,
                mudsound      = snd.mud,
                hard          = def.hard,
                roadways      = def.roadways,
            },
            {
                name          = "map_edge",
                noise_texture = def.noise,
            }
        )
    end
end


-- ── 读取配置并存入全局 ───────────────────────────────────────

local CreateConfig = require("npc_config")
_G.NPCFRIENDS = CreateConfig(GetModConfigData)


local POOL_CONFIG = require("npc/npc_pool_config")
local NPCCombatSettings = require("npc_combat_settings")
local NPCCustomCombat = require("npc/npc_custom_combat")

-- ── 注册自定义 prefab（服务端+客户端都需要加载贴图/动画） ───
PrefabFiles = {
    "npcfriend",              -- scripts/prefabs/npcfriend.lua
    "npc_shadow_protector",   -- scripts/prefabs/npc_shadow_protector.lua (暗影保护者)
    "npc_shadow_worker",      -- scripts/prefabs/npc_shadow_worker.lua (暗影工人)
    "npc_work_pool_big",      -- scripts/prefabs/npc_work_pool_big.lua (可钓鱼大池塘)
    "npc_growth_foods",       -- scripts/prefabs/npc_growth_foods.lua (NPC专属成长食物)
    "npc_rift_portal",        -- scripts/prefabs/npc_rift_portal.lua (永久裂缝节点)
    "npc_waxwell_magic_chest", -- scripts/prefabs/npc_waxwell_magic_chest.lua (NPC麦斯威尔魔术箱)
    "npc_waxwell_magic_container", -- scripts/prefabs/npc_waxwell_magic_container.lua (魔术箱共享存储)
    "npc_woby",               -- scripts/prefabs/npc_woby.lua (NPC沃尔特专属沃比)
    "npc_walter_story_proxy",  -- scripts/prefabs/npc_walter_story_proxy.lua (NPC沃尔特讲故事回san光环)
    "npc_rainbow_fireflies",   -- scripts/prefabs/npc_rainbow_fireflies.lua (七彩萤火虫)
    "npc_hamlet_turfs",        -- scripts/prefabs/npc_hamlet_turfs.lua (哈姆雷特13种猪镇地皮)
    "npc_hamlet_trees",        -- scripts/prefabs/npc_hamlet_trees.lua (哈姆雷特4种树+种子)
    "silvernecklace",         -- scripts/prefabs/silvernecklace.lua (薇尔芭银项链)
    "npc_wx78_leap_fx",       -- scripts/prefabs/npc_wx78_leap_fx.lua (机器人跳劈贴地电流范围特效)
    "npc_wormwood_plant_fx",  -- scripts/prefabs/npc_wormwood_plant_fx.lua (植物人脚边小草，识别 NPC)
}

-- ── 月系锅物食谱 ─────────────────────────────────────────────
local MOON_DESSERT_MUSHROOMS = {
    red_cap = true, red_cap_cooked = true,
    green_cap = true, green_cap_cooked = true,
    blue_cap = true, blue_cap_cooked = true,
    moon_cap = true, moon_cap_cooked = true,
}

local MOON_DESSERT_BERRIES = {
    berries = true, berries_cooked = true,
    berries_juicy = true, berries_juicy_cooked = true,
}

local function HasAnyNamed(names, options)
    for prefab in pairs(options) do
        if names[prefab] ~= nil then
            return true
        end
    end
    return false
end

local function RegisterMoonDessertRecipes()
    local foods = {
        {
            name = "yotr_food2", -- Moon Cake / 月饼
            test = function(cooker, names, tags)
                return HasAnyNamed(names, MOON_DESSERT_MUSHROOMS) 
                    and HasAnyNamed(names, MOON_DESSERT_BERRIES)
                    and (names.honey or 0) >= 2
                    and not tags.frozen
                    and not tags.meat
                    and not tags.inedible
            end,
            priority = 60,
            weight = 1,
            foodtype = _G.FOODTYPE.GOODIES,
            cooktime = 1,
            no_cookbook = true,
        },
        {
            name = "yotr_food3", -- Moon Jelly / 月冻
            test = function(cooker, names, tags)
                return HasAnyNamed(names, MOON_DESSERT_MUSHROOMS)
                    and HasAnyNamed(names, MOON_DESSERT_BERRIES)
                    and names.honey
                    and names.ice
                    and not tags.meat
                    and not tags.inedible
            end,
            priority = 55,
            weight = 1,
            foodtype = _G.FOODTYPE.GOODIES,
            cooktime = 1,
            no_cookbook = true,
        },
    }

    for _, food in ipairs(foods) do
        AddCookerRecipe("cookpot", food)
        AddCookerRecipe("portablecookpot", food)
        AddCookerRecipe("archive_cookpot", food)
    end
end

RegisterMoonDessertRecipes()

-- ── 服务端逻辑 ──────────────────────────────────────────────

local CompanionSpawner = require("companion_spawner")

-- 古树生长解除原版地皮/季节限制：
-- 惊喜种子种下后的两个古树幼苗，以及成熟后的果实再生，都保持正常推进。
local ANCIENT_TREE_SAPLINGS = {
    "ancienttree_gem_sapling",
    "ancienttree_nightvision_sapling",
}

local ANCIENT_TREES = {
    "ancienttree_gem",
    "ancienttree_nightvision",
}

local function IsAncientGrowthPauseReason(reason)
    return reason == "WRONG_TILE" or reason == "WRONG_SEASON"
end

local function UnlockAncientGrowable(growable)
    if growable == nil then return end

    growable.pausereasons["WRONG_TILE"] = nil
    growable.pausereasons["WRONG_SEASON"] = nil

    if growable._npcfriends_ancient_growth_unlocked then
        return
    end
    growable._npcfriends_ancient_growth_unlocked = true

    local old_pause = growable.Pause
    growable.Pause = function(self, reason)
        if IsAncientGrowthPauseReason(reason) then
            self.pausereasons[reason] = nil
            return
        end
        return old_pause(self, reason)
    end
end

local function ForceAncientSaplingGrowth(inst)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end

    local old_check = inst.CheckGrowConstraints
    if old_check ~= nil then
        inst:StopWatchingWorldState("season", old_check)
    end

    if inst.components ~= nil then
        UnlockAncientGrowable(inst.components.growable)
    end

    inst.CheckGrowConstraints = function(sapling)
        if sapling.components ~= nil and sapling.components.growable ~= nil then
            local growable = sapling.components.growable
            UnlockAncientGrowable(growable)
            growable:Resume("WRONG_TILE")
            growable:Resume("WRONG_SEASON")
            if not growable:IsGrowing() and not growable:IsPaused() then
                growable:StartGrowing()
            end
        end
    end

    inst:WatchWorldState("season", inst.CheckGrowConstraints)
    inst:DoTaskInTime(0, inst.CheckGrowConstraints)
end

local function ForceAncientTreeFruitRegen(inst)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    inst.CanRegenFruits = function()
        return true
    end
end

for _, prefab in ipairs(ANCIENT_TREE_SAPLINGS) do
    AddPrefabPostInit(prefab, ForceAncientSaplingGrowth)
end

for _, prefab in ipairs(ANCIENT_TREES) do
    AddPrefabPostInit(prefab, ForceAncientTreeFruitRegen)
end

AddPlayerPostInit(function(player)

    if not _G.TheWorld or not _G.TheWorld.ismastersim then
        return
    end

    -- ── 银项链：加载窗口 ─────────────────────────────────────────
    player._silvernecklace_loading = true

    if _G.NPCFRIENDS_SILVERNECKLACE_UTILS and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.DebugLog then
        local DBG = _G.NPCFRIENDS_SILVERNECKLACE_UTILS.DebugLog
        player:ListenForEvent("death", function(p)
            DBG("Player.death", p)
        end)
        player:ListenForEvent("ms_respawnedfromghost", function(p)
            DBG("Player.ms_respawnedfromghost", p)
            p:DoTaskInTime(0.5, function(i)
                if i and i:IsValid()
                    and _G.NPCFRIENDS_SILVERNECKLACE_UTILS
                    and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad then
                    _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad(i)
                end
            end)
        end)
        player:ListenForEvent("respawnfromghost", function(p)
            DBG("Player.respawnfromghost", p)
            p:DoTaskInTime(0.5, function(i)
                if i and i:IsValid()
                    and _G.NPCFRIENDS_SILVERNECKLACE_UTILS
                    and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad then
                    _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad(i)
                end
            end)
        end)
    end

    CompanionSpawner.RegisterPlayer(player)

    local function _TryPlayRiftArrivalCompensation(inst, retry)
        if inst == nil or not inst:IsValid() then
            return
        end
        if inst._npc_rift_arrive_fx_pending == nil then
            return
        end
        if inst:HasTag("playerghost") then
            inst._npc_rift_arrive_fx_pending = nil
            return
        end

        local ready = inst.sg ~= nil
            and not inst:HasTag("playerghost")
            and not inst.sg:HasStateTag("busy")
            and not inst.sg:HasStateTag("dead")
            and not inst.sg:HasStateTag("jumping")

        if not ready then
            local n = (retry or 0) + 1
            if n <= 25 then
                inst:DoTaskInTime(0.2, function(i) _TryPlayRiftArrivalCompensation(i, n) end)
            else

                if inst._npc_rift_force_hide_task ~= nil then
                    inst._npc_rift_force_hide_task:Cancel()
                    inst._npc_rift_force_hide_task = nil
                end
                inst:Show()
                if inst.DynamicShadow ~= nil then
                    inst.DynamicShadow:Enable(true)
                end
                inst._npc_rift_arrive_fx_pending = nil
            end
            return
        end

        inst:DoTaskInTime(1, function(i)
            if i ~= nil and i:IsValid() and i.sg ~= nil then
                if i._npc_rift_force_hide_task ~= nil then
                    i._npc_rift_force_hide_task:Cancel()
                    i._npc_rift_force_hide_task = nil
                end
                i.sg:GoToState("pocketwatch_portal_land")
            end
            if i ~= nil then
                i._npc_rift_arrive_fx_pending = nil
            end
        end)
    end

    local _OnSave = player.OnSave
    player.OnSave = function(inst, data)
        if _OnSave ~= nil then
            _OnSave(inst, data)
        end
        if data ~= nil and inst._npc_rift_arrive_fx_pending ~= nil then
            data.npc_rift_arrive_fx_pending = inst._npc_rift_arrive_fx_pending
        end
    end

    local _OnLoad = player.OnLoad
    player.OnLoad = function(inst, data)
        if _OnLoad ~= nil then
            _OnLoad(inst, data)
        end
        if data ~= nil and data.npc_rift_arrive_fx_pending ~= nil then
            inst._npc_rift_arrive_fx_pending = data.npc_rift_arrive_fx_pending
        end
        if inst._npc_rift_arrive_fx_pending ~= nil then
            inst:Hide()
            if inst.DynamicShadow ~= nil then
                inst.DynamicShadow:Enable(false)
            end
            if inst._npc_rift_force_hide_task ~= nil then
                inst._npc_rift_force_hide_task:Cancel()
                inst._npc_rift_force_hide_task = nil
            end
            inst._npc_rift_force_hide_task = inst:DoPeriodicTask(0, function(i)
                if i == nil or not i:IsValid() then
                    return
                end
                if i._npc_rift_arrive_fx_pending == nil then
                    if i._npc_rift_force_hide_task ~= nil then
                        i._npc_rift_force_hide_task:Cancel()
                        i._npc_rift_force_hide_task = nil
                    end
                    return
                end
                i:Hide()
                if i.DynamicShadow ~= nil then
                    i.DynamicShadow:Enable(false)
                end
            end)
            inst:DoTaskInTime(0.8, function(i) _TryPlayRiftArrivalCompensation(i, 0) end)
        end
        inst:DoTaskInTime(0.5, function(i)
            if i ~= nil and i:IsValid()
                and _G.NPCFRIENDS_SILVERNECKLACE_UTILS ~= nil
                and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad ~= nil then
                _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad(i)
            end
            if i ~= nil and i:IsValid() then
                i._silvernecklace_loading = nil
            end
        end)
    end
end)

AddPlayerPostInit(function(player)
    if not _G.TheWorld or not _G.TheWorld.ismastersim then return end
    player:DoTaskInTime(0.6, function(i)
        if i and i:IsValid() then
            i._silvernecklace_loading = nil
        end
    end)
end)

-- ── 任务进度自动追踪：物品收集 + 击杀 ──────────────────────────
AddPlayerPostInit(function(player)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    player:DoTaskInTime(1, function(inst)
        if inst.components.inventory then
            local _orig_giveitem = inst.components.inventory.GiveItem
            inst.components.inventory.GiveItem = function(self, item, slot, src_pos, ...)
                local prefab = item and item.prefab
                local count = 1
                if item and item.components.stackable then
                    count = item.components.stackable:StackSize()
                end
                local ret = _orig_giveitem(self, item, slot, src_pos, ...)
                if prefab then
                    local QuestManager = require("npc/npc_quest_manager")
                    QuestManager.OnItemCollected(inst, prefab, count)
                end
                return ret
            end
        end
    end)
end)

-- 监听实体死亡，追踪击杀任务进度
AddPrefabPostInit("world", function(inst)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    inst:ListenForEvent("entity_death", function(world, data)
        if not data or not data.inst then return end
        local victim = data.inst
        if not victim:IsValid() then return end
        local cause = data.cause
        local killer = nil
        if cause and cause.IsValid and cause:IsValid() then
            if cause:HasTag("player") then
                killer = cause
            elseif cause.components and cause.components.follower then
                local leader = cause.components.follower.leader
                if leader and leader:IsValid() and leader:HasTag("player") then
                    killer = leader
                end
            end
        end
        if not killer then
            if victim.components.combat and victim.components.combat.lastattacker then
                local la = victim.components.combat.lastattacker
                if la and la:IsValid() and la:HasTag("player") then
                    killer = la
                elseif la and la:IsValid() and la.components and la.components.follower then
                    local leader = la.components.follower.leader
                    if leader and leader:IsValid() and leader:HasTag("player") then
                        killer = leader
                    end
                end
            end
        end
        if killer then
            local QuestManager = require("npc/npc_quest_manager")
            QuestManager.OnKill(killer, victim.prefab, victim)
        end
    end, _G.TheWorld)
end)

-- ── NPC 左键打招呼 ──────────────────────────────────────────────
local ORIGINAL_GREET_SOUNDS = {
    waxwell = "dontstarve/characters/maxwell/talk_LP",
    wathgrithr = "dontstarve_DLC001/characters/wathgrithr/talk_LP",
    webber = "dontstarve_DLC001/characters/webber/talk_LP",
    wormwood = "dontstarve/characters/wilson/talk_LP",
    wilba = "dontstarve/characters/willow/talk_LP",
    wanda = "wanda2/characters/wanda/talk_LP",
    wonkey = "monkeyisland/characters/wonkey/talk_LP",
}

local function PlayOriginalGreetSound(target)
    if not (target and target.SoundEmitter) then return end
    if IsChineseLanguage() and not (_G.NPCFRIENDS and _G.NPCFRIENDS.voice_mode == "original") then return end
    if target:HasTag("mime") then return end

    local handle = "npc_original_greet"
    local char = target.npc_character_type
    local sound = target.talksoundoverride or ORIGINAL_GREET_SOUNDS[char]
    if sound == nil then
        local sound_name = target.soundsname or char or target.prefab
        sound = (target.talker_path_override or "dontstarve/characters/") .. sound_name .. "/talk_LP"
    end

    target.SoundEmitter:KillSound(handle)
    target.SoundEmitter:PlaySound(sound, handle)
    target.SoundEmitter:SetVolume(handle, 0.6)

    if target._npc_original_greet_task then
        target._npc_original_greet_task:Cancel()
    end
    target._npc_original_greet_task = target:DoTaskInTime(1.8, function(inst)
        if inst.SoundEmitter then
            inst.SoundEmitter:KillSound(handle)
        end
        inst._npc_original_greet_task = nil
    end)
end

local function DoNPCGreet(doer, target)
    if not doer or not target or not target:IsValid() then return false end
    if not _G.TheWorld.ismastersim then return false end
    if target.components.health and target.components.health:IsDead() then return true end
    local now = _G.GetTime()
    if target._npc_greet_cd and now - target._npc_greet_cd < 2 then return true end
    target._npc_greet_cd = now
    target:ForceFacePoint(doer.Transform:GetWorldPosition())
    local anims = {"emoteXL_waving1", "emoteXL_waving2", "emoteXL_waving3"}
    if target.sg and not target.sg:HasStateTag("busy") and not target.sg:HasStateTag("dead") then
        target.sg:GoToState("emote", { anim = anims[math.random(#anims)], fx = false })
    end
    if target.components.talker then
        target.components.talker:ShutUp()
        local NPC_SPEECH = require("npc_speech")
        if NPC_SPEECH.GREET then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.GREET, target.npc_character_type)
            if line and target.components.talker then
                target.components.talker:Say(line)
                PlayOriginalGreetSound(target)
            end
        end
    end
    return true
end

local _NPC_GREET = _G.Action({ distance = 20, instant = true })
_NPC_GREET.id  = "NPC_GREET"
_NPC_GREET.str = ""  -- 无左键提示文字
_NPC_GREET.fn  = function(act)
    local doer   = act.doer
    local target = act.target
    return DoNPCGreet(doer, target)
end
AddAction(_NPC_GREET)

AddPrefabPostInit("npcfriend", function(inst)
    inst.inherentsceneaction = _G.ACTIONS.NPC_GREET
end)

-- ════════════════════════════════════════════════════════════
--  NPC 语音(TTS)：NPC 说话时播放与文本对应的预录音频
--  · 音频命名/打包规则见 scripts/npc/npc_tts.lua 文件头注释
--  · 角色列表见上方 TTS_AUDIO_CHARS（新增角色只需改那里 + 放好 fev/fsb）
-- ════════════════════════════════════════════════════════════
local NPC_TTS = require("npc/npc_tts")
NPC_TTS.Init(TTS_AUDIO_CHARS, _G.NPCFRIENDS)
_G.NPCFRIENDS_TTS = NPC_TTS  -- 暴露给 DstAdmin：实时调音量/开关 (SetVolume/SetEnabled)

AddPrefabPostInit("npcfriend", function(inst)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    inst:DoTaskInTime(0, function()
        local talker = inst.components.talker
        if not talker or inst._npc_tts_hooked then return end
        inst._npc_tts_hooked = true
        local _Say = talker.Say
        talker.Say = function(self, msg, ...)
            NPC_TTS.OnSay(inst, msg)
            return _Say(self, msg, ...)
        end
    end)
end)

local _NPC_RIFT_UI = _G.Action({ distance = 2, instant = false, mount_valid = true })
_NPC_RIFT_UI.id = "NPC_RIFT_UI"
_NPC_RIFT_UI.str = ""
_NPC_RIFT_UI.fn = function(act)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        return true
    end
    local doer = act.doer
    local target = act.target
    if doer ~= nil and target ~= nil and target.components.npcriftportal ~= nil then
        target.components.npcriftportal:OpenTravelUI(doer)
        return true
    end
    return false
end
AddAction(_NPC_RIFT_UI)

local _NPC_RIFT_RENAME = _G.Action({ distance = 6, instant = true, mount_valid = true })
_NPC_RIFT_RENAME.id = "NPC_RIFT_RENAME"
do
    local zh = false
    local ok, val = _G.pcall(function() return _G.STRINGS.UI.MAINSCREEN.PLAY end)
    if ok and type(val) == "string" and val:match("[\228-\233]") then
        zh = true
    end
    _NPC_RIFT_RENAME.str = zh and "重命名裂缝" or "Rename Rift"
end
_NPC_RIFT_RENAME.fn = function(act)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        return true
    end
    local doer = act.doer
    local target = act.target
    if doer ~= nil and target ~= nil and target.components.writeable ~= nil and doer:HasTag("player") then
        if target.components.writeable:IsBeingWritten() then
            return false
        end
        target:DoTaskInTime(0.15, function(inst)
            if inst ~= nil and inst:IsValid() and doer ~= nil and doer:IsValid() and inst.components.writeable ~= nil then
                inst.components.writeable:SetWriteableDistance(8)
                inst.components.writeable:BeginWriting(doer)
            end
        end)
        return true
    end
    return false
end
AddAction(_NPC_RIFT_RENAME)

AddComponentAction("SCENE", "npcriftportal", function(inst, doer, actions, right)
    if inst ~= nil and inst:HasTag("npc_rift_portal") and doer ~= nil and doer:HasTag("player") then
        if right then
            table.insert(actions, _G.ACTIONS.NPC_RIFT_RENAME)
        else
            table.insert(actions, _G.ACTIONS.NPC_RIFT_UI)
        end
    end
end)

AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.NPC_RIFT_UI, "give"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.NPC_RIFT_UI, "give"))
AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.NPC_RIFT_RENAME, "doshortaction"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.NPC_RIFT_RENAME, "doshortaction"))

AddPrefabPostInit("npc_rift_portal", function(inst)
    inst.inherentsceneaction = _G.ACTIONS.NPC_RIFT_UI
end)

-- ── 敌对NPC生成逻辑已提取到 scripts/npc_hostile_spawn.lua ──────────────
local HostileSpawn = require("npc_hostile_spawn")

AddPrefabPostInit("spiderden", function(inst)
    if not _G.TheWorld.ismastersim then return end
    inst:ListenForEvent("attacked", function(den, data)
        HostileSpawn.TrySpawnWebberFromSpiderDen(den, data and data.attacker or nil)
    end)
    inst:ListenForEvent("worked", function(den, data)
        HostileSpawn.TrySpawnWebberFromSpiderDen(den, data and data.worker or nil)
    end)
end)

AddPrefabPostInit("world", function(inst)
    if not _G.TheWorld.ismastersim then return end
    inst:DoTaskInTime(2, HostileSpawn.EnsureSingleWurtAndRespawn)
    inst._wurt_respawn_watch_task = inst:DoPeriodicTask(5, HostileSpawn.EnsureSingleWurtAndRespawn)
    inst:ListenForEvent("onremove", function(i)
        if i._wurt_respawn_watch_task then
            i._wurt_respawn_watch_task:Cancel()
            i._wurt_respawn_watch_task = nil
        end
    end)
end)

-- 世界加载时从持久化存储恢复 COOK_SAME_DISH_MAX
AddPrefabPostInit("world", function(inst)
    if not _G.TheWorld.ismastersim then return end
    inst:DoTaskInTime(0.1, function()
        if not (_G.TheSim and _G.TheSim.GetPersistentString) then return end
        _G.TheSim:GetPersistentString("npcfriends_cook_same_dish_max", function(load_success, data)
            if load_success and data and data ~= "" then
                local val = _G.tonumber(data)
                if val and val >= 1 and val <= 99 then
                    val = math.floor(val)
                    local NPC_TUNING_REF = require("npc_tuning")
                    if NPC_TUNING_REF then
                        NPC_TUNING_REF.COOK_SAME_DISH_MAX = val
                    end
                end
            end
        end, false)
        _G.TheSim:GetPersistentString("npcfriends_fishing_max_catch", function(load_success, data)
            if load_success and data and data ~= "" then
                local val = _G.tonumber(data)
                if val and val >= 1 and val <= 99 then
                    val = math.floor(val)
                    local NPC_TUNING_REF = require("npc_tuning")
                    if NPC_TUNING_REF then
                        NPC_TUNING_REF.FISHING_MAX_CATCH = val
                    end
                end
            end
        end, false)
        local ORGANIZE_RANGE_KEYS_RESTORE = {
            wes    = { tuning_key = "WES_PATROL_RADIUS",    default = 30, max = 30 },
            winona = { tuning_key = "WINONA_PATROL_RADIUS", default = 50, max = 50 },
            warly  = { tuning_key = "FARM_WORK_RADIUS",     default = 17, max = 30 },
        }
        for char_type, cfg in pairs(ORGANIZE_RANGE_KEYS_RESTORE) do
            _G.TheSim:GetPersistentString(
                "npcfriends_organize_range_" .. char_type,
                function(load_success, data)
                    if load_success and data and data ~= "" then
                        local val = _G.tonumber(data)
                        if val and val >= 10 and val <= (cfg.max or 80) then
                            local NPC_TUNING_REF = require("npc_tuning")
                            if NPC_TUNING_REF then
                                NPC_TUNING_REF[cfg.tuning_key] = math.floor(val)
                            end
                        end
                    end
                end, false)
        end
        local NPC_TUNING_TTS_RESTORE = require("npc_tuning")
        if NPC_TUNING_TTS_RESTORE and type(NPC_TUNING_TTS_RESTORE.TTS_VOLUME) == "table" then
            for char_type, _ in pairs(NPC_TUNING_TTS_RESTORE.TTS_VOLUME) do
                if char_type ~= "_default" then
                    local restore_char = char_type
                    _G.TheSim:GetPersistentString(
                        "npcfriends_tts_volume_" .. restore_char,
                        function(load_success, data)
                            if load_success and data and data ~= "" then
                                local val = _G.tonumber(data)
                                if val and val >= 0 and val <= 1 then
                                    NPC_TUNING_TTS_RESTORE.TTS_VOLUME[restore_char] = math.floor(val / 0.05 + 0.5) * 0.05
                                end
                            end
                        end, false)
                end
            end
        end
        local session_id = _G.TheWorld and _G.TheWorld.meta and _G.TheWorld.meta.session_identifier
        if not session_id then
            print("[NPC_FISHING] WARN: 无法获取 session_identifier, 跳过恢复存放点")
        else
            local deposit_key = "npcfriends_fish_deposit_pos_" .. session_id
            _G.TheSim:GetPersistentString(deposit_key, function(load_success, data)
                if load_success and data and data ~= "" then
                    local sx, sz = data:match("^([%-%.%d]+)|([%-%.%d]+)$")
                    local rx, rz = _G.tonumber(sx), _G.tonumber(sz)
                    if rx and rz then
                        if math.abs(rx) < 0.01 and math.abs(rz) < 0.01 then
                            print("[NPC_FISHING] WARN: 恢复坐标为原点(0,0), 忽略")
                            return
                        end
                        if math.abs(rx) > 2000 or math.abs(rz) > 2000 then
                            print("[NPC_FISHING] WARN: 恢复坐标超范围, 忽略")
                            return
                        end
                        local NPC_TUNING_REF = require("npc_tuning")
                        if NPC_TUNING_REF then
                            NPC_TUNING_REF.FISHING_DEPOSIT_POS = {x = rx, z = rz}
                            print("[NPC_FISHING] Restored deposit pos (key=" .. deposit_key .. "): x=" .. tostring(rx) .. ", z=" .. tostring(rz))
                        end
                    end
                end
            end, false)
        end
        _G.TheSim:GetPersistentString("npcfriends_oceanfishing_max_catch", function(load_success, data)
            if load_success and data and data ~= "" then
                local val = _G.tonumber(data)
                if val and val >= 1 and val <= 99 then
                    val = math.floor(val)
                    local NPC_TUNING_REF = require("npc_tuning")
                    if NPC_TUNING_REF then
                        NPC_TUNING_REF.OCEAN_FISHING_MAX_CATCH = val
                    end
                end
            end
        end, false)
        _G.TheSim:GetPersistentString("npc_ocean_fishing_murder_fish", function(load_success, data)
            if load_success and data and data ~= "" then
                local NPC_TUNING_REF = require("npc_tuning")
                if NPC_TUNING_REF then
                    NPC_TUNING_REF.OCEAN_FISHING_MURDER_FISH = (data == "true")
                end
            end
        end, false)
        if session_id then
            local oceanfish_deposit_key = "npcfriends_oceanfish_deposit_pos_" .. session_id
            _G.TheSim:GetPersistentString(oceanfish_deposit_key, function(load_success, data)
                if load_success and data and data ~= "" then
                    local sx, sz = data:match("^([%-%.%d]+)|([%-%.%d]+)$")
                    local rx, rz = _G.tonumber(sx), _G.tonumber(sz)
                    if rx and rz then
                        if math.abs(rx) < 0.01 and math.abs(rz) < 0.01 then
                            print("[NPC_OCEAN_FISHING] WARN: 恢复坐标为原点(0,0), 忽略")
                            return
                        end
                        if math.abs(rx) > 2000 or math.abs(rz) > 2000 then
                            print("[NPC_OCEAN_FISHING] WARN: 恢复坐标超范围, 忽略")
                            return
                        end
                        local NPC_TUNING_REF = require("npc_tuning")
                        if NPC_TUNING_REF then
                            NPC_TUNING_REF.OCEAN_FISHING_DEPOSIT_POS = {x = rx, z = rz}
                            print("[NPC_OCEAN_FISHING] Restored deposit pos (key=" .. oceanfish_deposit_key .. "): x=" .. tostring(rx) .. ", z=" .. tostring(rz))
                        end
                    end
                end
            end, false)
        end
    end)
end)

AddPrefabPostInit("spider", HostileSpawn.HookSpiderWebberAssist)
AddPrefabPostInit("spider_warrior", HostileSpawn.HookSpiderWebberAssist)
AddPrefabPostInit("spider_spitter", HostileSpawn.HookSpiderWebberAssist)
AddPrefabPostInit("spider_hider", HostileSpawn.HookSpiderWebberAssist)
AddPrefabPostInit("spider_dropper", HostileSpawn.HookSpiderWebberAssist)
AddPrefabPostInit("spiderqueen", HostileSpawn.HookSpiderWebberAssist)

local function HookMermHouseWurtTornadoImmune(inst)
    if not _G.TheWorld.ismastersim then return end
    local workable = inst.components and inst.components.workable
    if workable == nil or workable._wurt_tornado_guard then return end
    workable._wurt_tornado_guard = true
    local old_WorkedBy = workable.WorkedBy
    workable.WorkedBy = function(self, worker, numworks)
        if worker ~= nil and worker.prefab == "tornado"
            and worker.WINDSTAFF_CASTER ~= nil
            and worker.WINDSTAFF_CASTER._is_wurt then
            return
        end
        return old_WorkedBy(self, worker, numworks)
    end
end
AddPrefabPostInit("mermhouse", HookMermHouseWurtTornadoImmune)
AddPrefabPostInit("mermhouse_crafted", HookMermHouseWurtTornadoImmune)

-- NPC死亡 → 设置重生冷却
AddPrefabPostInit("npcfriend", function(inst)
    if not _G.TheWorld.ismastersim then return end
    inst:ListenForEvent("death", function(i)
        HostileSpawn.OnNPCDeath(i)
    end)
end)

-- 世界存档/加载：持久化重生冷却
AddPrefabPostInit("world", function(inst)
    if not _G.TheWorld.ismastersim then return end
    local _orig_onsave = inst.OnSave
    inst.OnSave = function(self, data)
        if _orig_onsave then _orig_onsave(self, data) end
        data = data or {}
        HostileSpawn.OnWorldSave(self, data)
    end
    local _orig_onload = inst.OnLoad
    inst.OnLoad = function(self, data)
        if _orig_onload then _orig_onload(self, data) end
        HostileSpawn.OnWorldLoad(self, data)
    end
end)

-- 世界存档/加载：持久化任务数据
AddPrefabPostInit("world", function(inst)
    if not _G.TheWorld.ismastersim then return end
    local _quest_orig_onsave = inst.OnSave
    inst.OnSave = function(self, data)
        if _quest_orig_onsave then _quest_orig_onsave(self, data) end
        data = data or {}
        local QuestManager = require("npc/npc_quest_manager")
        local quest_save = QuestManager.OnSave()
        if quest_save ~= nil then
            data._npc_quests = quest_save
        end
    end
    local _quest_orig_onload = inst.OnLoad
    inst.OnLoad = function(self, data)
        if _quest_orig_onload then _quest_orig_onload(self, data) end
        if data and data._npc_quests then
            local QuestManager = require("npc/npc_quest_manager")
            QuestManager.OnLoad(data._npc_quests)
        end
    end
end)

-- 解析 owner_param: "owner_userid:char_type:slot_index" 或 "char_type"
local function ParseOwnerParam(owner_param)
    if type(owner_param) ~= "string" or owner_param == "" then
        return nil, nil, nil
    end
    local parts = {}
    for seg in owner_param:gmatch("[^:]+") do parts[#parts + 1] = seg end
    if #parts >= 2 then
        return parts[1], parts[2], _G.tonumber(parts[3])
    end
    return nil, parts[1], nil
end

local function FindNPCForOwnerParam(owner_param)
    local owner_userid, char_type, slot_index = ParseOwnerParam(owner_param)
    local owner_slot_match, owner_char_match = nil, nil
    local slot_char_match, slot_match, char_match = nil, nil, nil
    for _, ent in pairs(_G.Ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            local leader = ent.components.follower and ent.components.follower.leader
            local ent_owner = ent.owner_userid and ent.owner_userid:value()
            local owner_match = owner_userid and ((leader and leader.userid == owner_userid)
                or (ent_owner and ent_owner ~= "" and ent_owner == owner_userid))
            local slot_ok = slot_index and ent.npc_slot_index == slot_index
            local char_ok = char_type and ent.npc_character_type == char_type

            if owner_match and slot_ok then
                owner_slot_match = ent
                break
            end
            if owner_match and char_ok and owner_char_match == nil then
                owner_char_match = ent
            end
            if slot_ok and char_ok and slot_char_match == nil then
                slot_char_match = ent
            end
            if slot_ok and slot_match == nil then
                slot_match = ent
            end
            if char_ok and char_match == nil then
                char_match = ent
            end
        end
    end
    return owner_slot_match or owner_char_match or slot_char_match or slot_match or char_match
end

-- ── 客户端放置模式已提取到 scripts/npc_ui_modes.lua ──────────────
local UiModes = require("npc_ui_modes")
UiModes.Init(env)

-- ── NPC 战斗设置面板：HUD 注入 + R 键开关 + 客户端同步 ─────────────
do
    local combat_settings_payload = NPCCombatSettings.Encode(nil)

    local function InstallCombatSettingsClient()
        if env.AddClientModRPCHandler ~= nil then
            env.AddClientModRPCHandler("NPCFriends", "ReceiveCombatSettings", function(payload)
                combat_settings_payload = payload or ""
                local hud = _G.ThePlayer ~= nil and _G.ThePlayer.HUD or nil
                local screen = hud ~= nil and hud._npc_combat_settings_screen or nil
                if screen ~= nil and screen.ApplyPayload ~= nil then
                    screen:ApplyPayload(payload or "")
                end
            end)
        end

        if AddClassPostConstruct ~= nil then
            AddClassPostConstruct("screens/playerhud", function(self)
                function self:ShowNPCCombatSettingsScreen(payload)
                    if self._npc_combat_settings_screen ~= nil then
                        self._npc_combat_settings_screen:Close()
                    end
                    local CombatSettingsScreen = require("screens/npc_combat_settingsscreen")
                    local screen = CombatSettingsScreen(_G.ThePlayer, payload or combat_settings_payload)
                    screen._npcfriends_attached_to_hud = true
                    self._npc_combat_settings_screen = screen
                    self:AddChild(screen)
                    if _G.SendModRPCToServer ~= nil and _G.GetModRPC ~= nil then
                        _G.SendModRPCToServer(_G.GetModRPC("NPCFriends", "RequestCombatSettings"), "")
                    end
                end

                function self:ToggleNPCCombatSettingsScreen()
                    if self._npc_combat_settings_screen ~= nil then
                        self._npc_combat_settings_screen:Close()
                        return
                    end
                    self:ShowNPCCombatSettingsScreen()
                end
            end)
        end

        local hotkey_str = _G.NPCFRIENDS and _G.NPCFRIENDS.combat_hotkey or "R"
        local hotkey = _G["KEY_" .. hotkey_str]
        if _G.TheInput ~= nil and _G.TheInput.AddKeyDownHandler ~= nil and hotkey ~= nil then
            _G.TheInput:AddKeyDownHandler(hotkey, function()
                local hud = _G.ThePlayer ~= nil and _G.ThePlayer.HUD or nil
                if hud ~= nil and hud.ToggleNPCCombatSettingsScreen ~= nil then
                    hud:ToggleNPCCombatSettingsScreen()
                end
            end)
        end
    end

    InstallCombatSettingsClient()
end

-- ── 任务面板：HUD 注入 ──────────────────────────────────────────
do
    local function InstallQuestClient()
        if AddClassPostConstruct ~= nil then
            AddClassPostConstruct("screens/playerhud", function(self)
                function self:ShowNPCQuestScreen(payload)
                    if self._npc_quest_screen ~= nil then
                        self._npc_quest_screen:Close()
                    end
                    local NPCQuestScreen = require("screens/npc_quest_screen")
                    local screen = NPCQuestScreen(_G.ThePlayer, payload or "")
                    screen._npcfriends_attached_to_hud = true
                    self._npc_quest_screen = screen
                    self:AddChild(screen)
                end
            end)
        end
    end

    InstallQuestClient()
end

local MagicChestStore = require("npc/npc_magic_chest_store")
MagicChestStore.RegisterShardRPC(env)

AddPrefabPostInit("world", function(inst)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    local _magic_chest_onsave = inst.OnSave
    inst.OnSave = function(world, data)
        if _magic_chest_onsave then
            _magic_chest_onsave(world, data)
        end
        MagicChestStore.SaveLocal()
    end
    inst:DoTaskInTime(0, function()
        MagicChestStore.EnsureWorldContainer()
        MagicChestStore.LoadLocal(function()
            MagicChestStore.RequestPeerSync()
        end)
    end)
end)

-- 每个玩家单独恢复自己的战斗面板参数，NPC 会读取自己领队的参数。
AddPrefabPostInit("player", function(inst)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    inst:DoTaskInTime(0, function()
        NPCCustomCombat.LoadPersistent(inst)
    end)
end)

AddModRPCHandler("NPCFriends", "GreetNPC", function(player, owner_param)
    if not _G.TheWorld or not _G.TheWorld.ismastersim then return end
    if not player then return end
    local npc = FindNPCForOwnerParam(owner_param)
    if npc then
        DoNPCGreet(player, npc)
    end
end)

AddModRPCHandler("NPCFriends", "SetCombatSetting", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end
    local key, raw = payload:match("^([^|]+)|(.+)$")
    if key == nil then return end
    if NPCCustomCombat.SetValue(player, key, raw) then
        if key == "stop_attack" and NPCCustomCombat.IsEnabled("stop_attack", player) then
            NPCCustomCombat.StopAllFriendlyCombat(player)
        end
        NPCCustomCombat.SavePersistent(player)
        if SendModRPCToClient ~= nil and GetClientModRPC ~= nil then
            SendModRPCToClient(GetClientModRPC("NPCFriends", "ReceiveCombatSettings"), player.userid, NPCCustomCombat.Encode(player))
        end
    end
end)

AddModRPCHandler("NPCFriends", "ResetCombatSettings", function(player)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player then return end
    NPCCustomCombat.Reset(player)
    NPCCustomCombat.SavePersistent(player)
    if SendModRPCToClient ~= nil and GetClientModRPC ~= nil then
        SendModRPCToClient(GetClientModRPC("NPCFriends", "ReceiveCombatSettings"), player.userid, NPCCustomCombat.Encode(player))
    end
end)

AddModRPCHandler("NPCFriends", "RequestCombatSettings", function(player)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player then return end
    NPCCustomCombat.LoadPersistent(player, function()
        if SendModRPCToClient ~= nil and GetClientModRPC ~= nil then
            SendModRPCToClient(GetClientModRPC("NPCFriends", "ReceiveCombatSettings"), player.userid, NPCCustomCombat.Encode(player))
        end
    end)
end)

-- 整理范围共享映射表（韦斯 / 薇诺娜复用同一 RPC）
local ORGANIZE_RANGE_KEYS = {
    wes    = { tuning_key = "WES_PATROL_RADIUS",    default = 30, max = 30 },
    winona = { tuning_key = "WINONA_PATROL_RADIUS", default = 50, max = 50 },
    warly  = { tuning_key = "FARM_WORK_RADIUS",     default = 17, max = 30 },
}

local function NormalizeTTSVolume(val)
    val = _G.tonumber(val)
    if not val then return nil end
    val = math.max(0, math.min(1, val))
    return math.floor(val / 0.05 + 0.5) * 0.05
end

-- 供 DstAdmin 面板调整厨师最大同食物数量
AddModRPCHandler("NPCFriends", "SetCookSameDishMax", function(player, val_str)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player then return end
    local val = _G.tonumber(val_str)
    if not val or val < 1 or val > 99 then return end
    val = math.floor(val)
    local NPC_TUNING_REF = require("npc_tuning")
    if NPC_TUNING_REF then
        NPC_TUNING_REF.COOK_SAME_DISH_MAX = val
    end
    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    _G.pcall(function()
        _G.TheSim:SetPersistentString("npcfriends_cook_same_dish_max", tostring(val), false)
    end)
end)

-- 供 DstAdmin 面板调整钓鱼最大次数
AddModRPCHandler("NPCFriends", "SetFishingMaxCatch", function(player, val_str)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player then return end
    local val = _G.tonumber(val_str)
    local NPC_TUNING_REF = require("npc_tuning")
    local min_val = (NPC_TUNING_REF and NPC_TUNING_REF.FISHING_MAX_CATCH_MIN) or 1
    local max_val = (NPC_TUNING_REF and NPC_TUNING_REF.FISHING_MAX_CATCH_MAX) or 9
    if not val or val < min_val or val > max_val then return end
    val = math.floor(val)
    if NPC_TUNING_REF then
        NPC_TUNING_REF.FISHING_MAX_CATCH = val
        print("[NPC_FISHING] RPC: SetFishingMaxCatch, new value=" .. tostring(val) .. ", NPC_TUNING.FISHING_MAX_CATCH=" .. tostring(NPC_TUNING_REF.FISHING_MAX_CATCH))
    end
    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    _G.pcall(function()
        _G.TheSim:SetPersistentString("npcfriends_fishing_max_catch", tostring(val), false)
    end)
end)

-- 供 DstAdmin 面板调整 NPC TTS 音量（0.00~1.00，步进 0.05）
AddModRPCHandler("NPCFriends", "SetTTSVolume", function(player, param_str)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(param_str) ~= "string" then return end
    local char_type, val_str = param_str:match("^(%w+)|(.+)$")
    local NPC_TUNING_REF = require("npc_tuning")
    if not (char_type and NPC_TUNING_REF and type(NPC_TUNING_REF.TTS_VOLUME) == "table") then return end
    if NPC_TUNING_REF.TTS_VOLUME[char_type] == nil then return end
    local val = NormalizeTTSVolume(val_str)
    if val == nil then return end
    NPC_TTS.SetVolume(char_type, val)
    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    _G.pcall(function()
        _G.TheSim:SetPersistentString("npcfriends_tts_volume_" .. char_type, string.format("%.2f", val), false)
    end)
end)

-- 供 DstAdmin 面板调整整理范围（韦斯 / 薇诺娜共享）
AddModRPCHandler("NPCFriends", "SetOrganizeRange", function(player, param_str)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or not param_str then return end
    -- 解析 "char_type|value"
    local char_type, val_str = param_str:match("^(%w+)|(.+)$")
    local cfg = ORGANIZE_RANGE_KEYS[char_type]
    if not cfg then return end
    local val = _G.tonumber(val_str)
    local max_val = cfg.max or 80
    if not val or val < 10 or val > max_val then return end
    val = math.floor(val)
    -- 更新 NPC_TUNING
    local NPC_TUNING_REF = require("npc_tuning")
    if NPC_TUNING_REF then
        NPC_TUNING_REF[cfg.tuning_key] = val
    end
    -- 持久化
    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    _G.pcall(function()
        _G.TheSim:SetPersistentString(
            "npcfriends_organize_range_" .. char_type,
            tostring(val), false)
    end)
end)

-- 供 DstAdmin 面板设置钓鱼存放点
AddModRPCHandler("NPCFriends", "SetFishDepositPoint", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end

    -- 解析 payload: "owner_param|x|z"
    local owner_param, sx, sz = payload:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)$")
    if not owner_param then return end
    local x, z = _G.tonumber(sx), _G.tonumber(sz)
    if not x or not z then return end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc then return end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
    if not is_owner and not is_leader and not npc_is_free then
        return
    end

    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) * (x - px) + (z - pz) * (z - pz)) > 1600 then return end

    target_npc._fishing_deposit_pos = {x = x, z = z}

    local NPC_TUNING_REF = require("npc_tuning")
    if NPC_TUNING_REF then
        NPC_TUNING_REF.FISHING_DEPOSIT_POS = {x = x, z = z}
    end
    print("[NPC_FISHING] SetFishDepositPoint: x=" .. tostring(x) .. ", z=" .. tostring(z))

    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    local session_id = _G.TheWorld and _G.TheWorld.meta and _G.TheWorld.meta.session_identifier
    if session_id then
        local deposit_key = "npcfriends_fish_deposit_pos_" .. session_id
        _G.pcall(function()
            _G.TheSim:SetPersistentString(deposit_key, tostring(x) .. "|" .. tostring(z), false)
        end)
        print("[NPC_FISHING] Saved deposit pos (key=" .. deposit_key .. "): x=" .. tostring(x) .. ", z=" .. tostring(z))
    else
        print("[NPC_FISHING] WARN: 无法获取 session_identifier, 跳过保存存放点")
    end
end)

AddModRPCHandler("NPCFriends", "EquipBackpackAt", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end

    local owner_param, sx, sz = payload:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)$")
    if not owner_param then return end
    local x, z = _G.tonumber(sx), _G.tonumber(sz)
    if not x or not z then return end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc or not target_npc:IsValid() then return end
    if target_npc._is_ghost_mode then return end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
    if not is_owner and not is_leader and not npc_is_free then
        return
    end

    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) * (x - px) + (z - pz) * (z - pz)) > 1600 then return end

    local NPC_TUNING_BP = require("npc_tuning")
    local radius = NPC_TUNING_BP.EQUIP_BACKPACK_PICKUP_RADIUS or 2
    local ents = _G.TheSim:FindEntities(x, 0, z, radius, {"backpack"}, {"INLIMBO", "FX", "NOCLICK"})
    local found = nil
    for _, e in ipairs(ents) do
        if e and e:IsValid()
           and e.components.inventoryitem and not e.components.inventoryitem:IsHeld()
           and e.components.equippable then
            found = e  -- 多个时默认取第一个
            break
        end
    end
    if not found then return end

    -- 设置拾取目标，由行为树高优先级节点接管走位/拾取/装备
    target_npc._fetch_backpack_target = found
end)

-- 植物人：设置作物存放点（作为容器检索中心）
AddModRPCHandler("NPCFriends", "SetWormwoodCropDepositPos", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end

    local owner_param, sx, sz = payload:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)$")
    if not owner_param then return end
    local x, z = _G.tonumber(sx), _G.tonumber(sz)
    if not x or not z then return end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc or target_npc.npc_character_type ~= "wormwood" or not target_npc._farmer then
        return
    end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
    if not is_owner and not is_leader and not npc_is_free then
        return
    end

    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) * (x - px) + (z - pz) * (z - pz)) > 1600 then return end

    target_npc._farmer:SetStorageTarget({ x = x, z = z })
    print("[NPC_FARM] SetWormwoodCropDepositPos: x=" .. tostring(x) .. ", z=" .. tostring(z))
end)

-- 植物人：设置垃圾存放点（用于垃圾/重物丢弃）
AddModRPCHandler("NPCFriends", "SetWormwoodTrashDepositPos", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end

    local owner_param, sx, sz = payload:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)$")
    if not owner_param then return end
    local x, z = _G.tonumber(sx), _G.tonumber(sz)
    if not x or not z then return end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc or target_npc.npc_character_type ~= "wormwood" or not target_npc._farmer then
        return
    end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
    if not is_owner and not is_leader and not npc_is_free then
        return
    end

    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) * (x - px) + (z - pz) * (z - pz)) > 1600 then return end

    target_npc._farmer:SetTrashDropPoint({ x = x, z = z })
    print("[NPC_FARM] SetWormwoodTrashDepositPos: x=" .. tostring(x) .. ", z=" .. tostring(z))
end)

-- 供 DstAdmin 面板设置海钓存放点
AddModRPCHandler("NPCFriends", "SetOceanFishDepositPos", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end

    -- 解析 payload: "owner_param|x|z"
    local owner_param, sx, sz = payload:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)$")
    if not owner_param then return end
    local x, z = _G.tonumber(sx), _G.tonumber(sz)
    if not x or not z then return end

    -- 安全校验：不接受超范围坐标
    if math.abs(x) > 2000 or math.abs(z) > 2000 then return end

    -- 权限校验：参考 SetFishDepositPoint 逻辑
    local target_npc = FindNPCForOwnerParam(owner_param)
    if target_npc then
        local leader = target_npc.components.follower and target_npc.components.follower.leader
        local actual_owner = target_npc._owner_userid
            or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
            or nil
        local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
        local is_leader  = leader and leader.userid == player.userid
        local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
        if not is_owner and not is_leader and not npc_is_free then
            return
        end
    end

    -- 距离校验：玩家 40 格以内
    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) * (x - px) + (z - pz) * (z - pz)) > 1600 then return end

    local NPC_TUNING_REF = require("npc_tuning")
    if NPC_TUNING_REF then
        NPC_TUNING_REF.OCEAN_FISHING_DEPOSIT_POS = { x = x, z = z }
        print("[NPC_OCEAN_FISHING] RPC: SetOceanFishDepositPos, x=" .. tostring(x) .. ", z=" .. tostring(z))
    end

    -- 持久化（绑定 session_identifier 隔离不同存档）
    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    local session_id = _G.TheWorld and _G.TheWorld.meta and _G.TheWorld.meta.session_identifier
    if session_id then
        local deposit_key = "npcfriends_oceanfish_deposit_pos_" .. session_id
        _G.pcall(function()
            _G.TheSim:SetPersistentString(deposit_key, tostring(x) .. "|" .. tostring(z), false)
        end)
        print("[NPC_OCEAN_FISHING] Saved deposit pos (key=" .. deposit_key .. "): x=" .. tostring(x) .. ", z=" .. tostring(z))
    end
end)

-- 供 DstAdmin 面板调整海钓最大次数
AddModRPCHandler("NPCFriends", "SetOceanFishingMaxCatch", function(player, val_str)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player then return end
    local val = _G.tonumber(val_str)
    local NPC_TUNING_REF = require("npc_tuning")
    local min_val = (NPC_TUNING_REF and NPC_TUNING_REF.OCEAN_FISHING_MAX_CATCH_MIN) or 1
    local max_val = (NPC_TUNING_REF and NPC_TUNING_REF.OCEAN_FISHING_MAX_CATCH_MAX) or 99
    if not val or val < min_val or val > max_val then return end
    val = math.floor(val)
    if NPC_TUNING_REF then
        NPC_TUNING_REF.OCEAN_FISHING_MAX_CATCH = val
        print("[NPC_OCEAN_FISHING] RPC: SetOceanFishingMaxCatch, new value=" .. tostring(val))
    end
    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    _G.pcall(function()
        _G.TheSim:SetPersistentString("npcfriends_oceanfishing_max_catch", tostring(val), false)
    end)
end)

-- 海钓杀鱼开关
AddModRPCHandler("NPCFriends", "SetOceanFishMurderEnabled", function(player, enabled_str)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player then return end
    local NPC_TUNING_REF = require("npc_tuning")
    if NPC_TUNING_REF then
        local enabled = (enabled_str == "true")
        NPC_TUNING_REF.OCEAN_FISHING_MURDER_FISH = enabled
        print("[NPC_OCEAN_FISHING] RPC: SetOceanFishMurderEnabled, enabled=" .. tostring(enabled))
    end
    if not (_G.TheSim and _G.TheSim.SetPersistentString) then return end
    _G.pcall(function()
        _G.TheSim:SetPersistentString("npc_ocean_fishing_murder_fish", tostring(enabled_str == "true"), false)
    end)
end)

AddModRPCHandler("NPCFriends", "PlacePoolAt", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end
    local owner_param, sx, sz = payload:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)$")
    if not owner_param then return end
    local x, z = _G.tonumber(sx), _G.tonumber(sz)
    if not x or not z then return end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc or target_npc.npc_character_type ~= "wilson" then
        return
    end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
    if not is_owner and not is_leader and not npc_is_free then
        return
    end

    local max_dist = POOL_CONFIG.PLACE_MAX_DIST or 20
    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) * (x - px) + (z - pz) * (z - pz)) > (max_dist * max_dist) then
        return
    end
    if not UiModes.IsValidPoolPlacementAt(x, z) then
        return
    end

    local pool = _G.SpawnPrefab("npc_work_pool_big")
    if pool then
        pool.Transform:SetPosition(x, 0, z)
    end
end)

-- 服务端 RPC：手动给 NPC 换肤
AddModRPCHandler("NPCFriends", "SetNPCClothing", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end

    -- 按 '|' 切分并保留空段（owner_param 内只含 ':'，不含 '|'）
    local seg = {}
    for s in (payload .. "|"):gmatch("([^|]*)|") do seg[#seg + 1] = s end
    if #seg < 6 then return end

    local owner_param = seg[1]
    if not owner_param or owner_param == "" then return end

    local _reskin_dbg = require("npc_tuning").DEBUG_RESKIN
    if _reskin_dbg then
        print(string.format(
            "[NPC_RESKIN] 衣柜RPC收到: owner_param=%s userid=%s payload_segs=%d base=%s body=%s hand=%s legs=%s feet=%s",
            tostring(owner_param), tostring(player.userid), #seg,
            tostring(seg[2]), tostring(seg[3]), tostring(seg[4]), tostring(seg[5]), tostring(seg[6])))
    end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc or not target_npc.ApplyNPCClothing then
        if _reskin_dbg then
            print("[NPC_RESKIN] 衣柜RPC: 未找到目标NPC 或 NPC无ApplyNPCClothing，target="
                .. tostring(target_npc))
        end
        return
    end

    local clothing = {
        base = seg[2] or "",
        body = seg[3] or "",
        hand = seg[4] or "",
        legs = seg[5] or "",
        feet = seg[6] or "",
    }
    target_npc:ApplyNPCClothing(clothing, player.userid)
end)

AddModRPCHandler("NPCFriends", "PlaceWinonaDevice", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end
    -- payload = "owner_param|device_type|x|z"
    local parts = {}
    for seg in payload:gmatch("[^|]+") do parts[#parts + 1] = seg end
    -- owner_param 可能包含 ':' ，所以取后三个分段为 device_type/x/z
    if #parts < 4 then return end
    local device_type = parts[#parts - 2]
    local x = _G.tonumber(parts[#parts - 1])
    local z = _G.tonumber(parts[#parts])
    local owner_param_parts = {}
    for i = 1, #parts - 3 do owner_param_parts[#owner_param_parts + 1] = parts[i] end
    local owner_param = table.concat(owner_param_parts, "|")
    if not x or not z or owner_param == "" then return end

    local DEVICE_PREFABS = {
        generator = "winona_battery_high",
        spotlight = "winona_spotlight",
        catapult  = "winona_catapult",
    }
    local prefab = DEVICE_PREFABS[device_type]
    if not prefab then return end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc or target_npc.npc_character_type ~= "winona" then return end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
    if not is_owner and not is_leader and not npc_is_free then return end

    local NPC_TUNING_REF = require("npc_tuning")
    local DEVICE_RECIPES = {
        generator = NPC_TUNING_REF.CRAFT_RECIPES.winona_generator.materials,
        spotlight = NPC_TUNING_REF.CRAFT_RECIPES.winona_spotlight.materials,
        catapult  = NPC_TUNING_REF.CRAFT_RECIPES.winona_catapult.materials,
    }
    local recipe = DEVICE_RECIPES[device_type]
    if recipe and target_npc.components.inventory then
        local inv = target_npc.components.inventory
        local NPC_SR = require("npc_speech")
        local missing = false
        for _, item in ipairs(recipe) do
            if not inv:Has(item.name, item.count) then missing = true; break end
        end
        if missing then
            local char_type = target_npc.npc_character_type or "_default"
            local speech_key = {
                generator = "WINONA_NO_MATERIAL_GENERATOR",
                spotlight = "WINONA_NO_MATERIAL_SPOTLIGHT",
                catapult  = "WINONA_NO_MATERIAL_CATAPULT",
            }
            local key = speech_key[device_type]
            local msg = (key and NPC_SR.GetLine(NPC_SR[key], char_type))
                     or (key and NPC_SR.GetLine(NPC_SR[key], "_default"))
                     or (NPC_SR._is_chinese and "材料不足。" or "Not enough materials.")
            if target_npc.components.talker then
                target_npc.components.talker:Say(msg)
            end
            return
        end
        for _, item in ipairs(recipe) do
            inv:ConsumeByName(item.name, item.count)
        end
    end

    local max_dist = NPC_TUNING_REF.WINONA_BUILD_PLACE_MAX_DIST or 30
    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) ^ 2 + (z - pz) ^ 2) > max_dist * max_dist then return end

    if _G.TheWorld.Map then
        if not _G.TheWorld.Map:IsPassableAtPoint(x, 0, z) then return end
        if _G.TheWorld.Map:IsOceanAtPoint(x, 0, z, false) then return end
    end

    if target_npc.components.locomotor then
        target_npc.components.locomotor:GoToPoint(_G.Vector3(x, 0, z))
    end

    if target_npc._winona_build_task then
        target_npc._winona_build_task:Cancel()
        target_npc._winona_build_task = nil
    end

    local check_count = 0
    local build_done  = false
    target_npc._winona_build_task = target_npc:DoPeriodicTask(0.1, function(npc)
        if build_done then return end
        if npc == nil or not npc:IsValid() then
            build_done = true
            return
        end
        check_count = check_count + 1
        local nx, _, nz = npc.Transform:GetWorldPosition()
        local dist_sq = (nx - x) ^ 2 + (nz - z) ^ 2
        if dist_sq <= 1.5 ^ 2 or check_count >= 50 then
            build_done = true
            if npc._winona_build_task then
                npc._winona_build_task:Cancel()
                npc._winona_build_task = nil
            end
            if npc.components.locomotor then
                npc.components.locomotor:Stop()
            end
            npc._winona_building = true
            npc.sg:GoToState("winona_place_device", { prefab = prefab, x = x, z = z })
        end
    end)
end)

AddModRPCHandler("NPCFriends", "PlaceWaxwellMagicChest", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(payload) ~= "string" then return end

    local owner_param, sx, sz = payload:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)$")
    if not owner_param then return end
    local x = _G.tonumber(sx)
    local z = _G.tonumber(sz)
    if not x or not z then return end

    local target_npc = FindNPCForOwnerParam(owner_param)
    if not target_npc or target_npc.npc_character_type ~= "waxwell" then return end

    local leader = target_npc.components.follower and target_npc.components.follower.leader
    local actual_owner = target_npc._owner_userid
        or (target_npc.owner_userid and target_npc.owner_userid:value() ~= "" and target_npc.owner_userid:value())
        or nil
    local is_owner   = actual_owner and actual_owner ~= "" and actual_owner == player.userid
    local is_leader  = leader and leader.userid == player.userid
    local npc_is_free = (actual_owner == nil or actual_owner == "") and leader == nil
    if not is_owner and not is_leader and not npc_is_free then return end

    local NPC_TUNING_REF = require("npc_tuning")
    local recipe = NPC_TUNING_REF.CRAFT_RECIPES and NPC_TUNING_REF.CRAFT_RECIPES.waxwell_magic_chest
    local inv = target_npc.components.inventory
    if not (recipe and inv) then return end

    local has_all = true
    for _, item in ipairs(recipe.materials) do
        if not inv:Has(item.name, item.count) then
            has_all = false
            break
        end
    end
    if not has_all then
        local NPC_SR = require("npc_speech")
        local msg = NPC_SR.GetLine(NPC_SR.WAXWELL_NO_MATERIAL_MAGIC_CHEST, "waxwell")
            or NPC_SR.GetLine(NPC_SR.WAXWELL_NO_MATERIAL_MAGIC_CHEST, "_default")
            or "材料不足。"
        if target_npc.components.talker then
            target_npc.components.talker:Say(msg)
        end
        return
    end

    local max_dist = NPC_TUNING_REF.WAXWELL_MAGIC_CHEST_MAX_DIST or 30
    local px, _, pz = player.Transform:GetWorldPosition()
    if ((x - px) ^ 2 + (z - pz) ^ 2) > max_dist * max_dist then return end
    if not UiModes.IsValidWaxwellMagicChestPlacementAt(x, z) then return end

    for _, item in ipairs(recipe.materials) do
        inv:ConsumeByName(item.name, item.count)
    end

    if target_npc.components.locomotor then
        target_npc.components.locomotor:GoToPoint(_G.Vector3(x, 0, z))
    end

    if target_npc._waxwell_magic_chest_build_task then
        target_npc._waxwell_magic_chest_build_task:Cancel()
        target_npc._waxwell_magic_chest_build_task = nil
    end

    local check_count = 0
    local build_done = false
    target_npc._waxwell_magic_chest_build_task = target_npc:DoPeriodicTask(0.1, function(npc)
        if build_done then return end
        if npc == nil or not npc:IsValid() then
            build_done = true
            return
        end
        check_count = check_count + 1
        local nx, _, nz = npc.Transform:GetWorldPosition()
        local dist_sq = (nx - x) ^ 2 + (nz - z) ^ 2
        if dist_sq <= 1.5 ^ 2 or check_count >= 50 then
            build_done = true
            if npc._waxwell_magic_chest_build_task then
                npc._waxwell_magic_chest_build_task:Cancel()
                npc._waxwell_magic_chest_build_task = nil
            end
            if npc.components.locomotor then
                npc.components.locomotor:Stop()
            end
            npc.sg:GoToState("winona_place_device", { prefab = "npc_waxwell_magic_chest", x = x, z = z })
        end
    end)
end)

AddModRPCHandler("NPCFriends", "RiftTeleport", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        return
    end
    if player == nil or type(payload) ~= "string" then
        return
    end
    local source_guid_s, worldid, x_s, z_s = payload:match("^(%d+)|([^|]+)|([%-%.%d]+)|([%-%.%d]+)$")
    if source_guid_s == nil or worldid == nil or x_s == nil or z_s == nil then
        return
    end
    local source = _G.Ents[_G.tonumber(source_guid_s)]
    if source == nil or not source:IsValid() or source.components.npcriftportal == nil then
        return
    end
    source.components.npcriftportal:TeleportPlayerTo(player, worldid, _G.tonumber(x_s), _G.tonumber(z_s))
end)

AddModRPCHandler("NPCFriends", "RiftDeleteCurrent", function(player, payload)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        return
    end
    if player == nil then
        return
    end
    local guid = _G.tonumber(payload)
    if guid == nil then
        return
    end
    local source = _G.Ents[guid]
    if source == nil or not source:IsValid() or not source:HasTag("npc_rift_portal") then
        return
    end
    local px, _, pz = player.Transform:GetWorldPosition()
    local sx, _, sz = source.Transform:GetWorldPosition()
    local dx = px - sx
    local dz = pz - sz
    if (dx * dx + dz * dz) > (12 * 12) then
        return
    end
    source:Remove()
end)

-- ── 任务系统服务端 RPC ──────────────────────────────────────────
AddModRPCHandler("NPCFriends", "RequestQuestDetail", function(player, quest_id)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(quest_id) ~= "string" or quest_id == "" then return end
    local QuestManager = require("npc/npc_quest_manager")
    local wilba_npc = nil
    for _, ent in pairs(_G.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") and ent.npc_character_type == "wilba" then
            wilba_npc = ent
            break
        end
    end
    QuestManager.RecomputeFromWilba(player, wilba_npc)
    local daily = QuestManager.GetDailyQuests(player)
    local accepted = QuestManager.GetAcceptedQuests(player)
    local daily_parts = {}
    for _, q in ipairs(daily) do
        daily_parts[#daily_parts + 1] = q.id .. "|" .. (q.name or q.id)
    end
    local accepted_parts = {}
    for _, q in ipairs(accepted) do
        local progress_str = ""
        if q.progress then
            local prog_parts = {}
            for _, v in pairs(q.progress) do
                prog_parts[#prog_parts + 1] = tostring(v)
            end
            progress_str = table.concat(prog_parts, ",")
        end
        accepted_parts[#accepted_parts + 1] = q.id .. "|" .. (q.name or q.id) .. "|" .. progress_str .. "|" .. tostring(q.completed == true)
    end
    _G.SendModRPCToClient(
        _G.GetClientModRPC("NPCFriends", "RefreshQuestScreen"),
        player.userid,
        table.concat(daily_parts, ";") .. "\n" .. table.concat(accepted_parts, ";")
            .. "\nmax_active=" .. tostring((require("npc_tuning").MAX_ACTIVE_QUESTS or 4))
    )
    local detail = QuestManager.GetQuestDetail(quest_id)
    if not detail then return end
    -- 构建 payload: id|name|desc|obj_prefab|obj_count|obj_label|...|rwd_prefab|rwd_count|rwd_label|...
    local parts = {
        detail.id,
        detail.name or "",
        detail.desc or "",
    }
    for _, obj in ipairs(detail.objectives or {}) do
        parts[#parts + 1] = obj.prefab or ""
        parts[#parts + 1] = tostring(obj.count or 0)
        parts[#parts + 1] = obj.label or obj.prefab or ""
    end
    for _, rwd in ipairs(detail.rewards or {}) do
        parts[#parts + 1] = "rwd:" .. (rwd.prefab or "")
        parts[#parts + 1] = tostring(rwd.count or 0)
        parts[#parts + 1] = rwd.label or rwd.prefab or ""
    end
    -- 追加随机奖励位：只告诉客户端数量，不泄露具体奖励
    local rnd_count = detail.random_count or 0
    if rnd_count > 0 then
        parts[#parts + 1] = "rnd:" .. tostring(rnd_count)
    end
    local payload = table.concat(parts, "|")
    _G.SendModRPCToClient(
        _G.GetClientModRPC("NPCFriends", "ReceiveQuestDetail"),
        player.userid,
        payload
    )
end)

AddModRPCHandler("NPCFriends", "AcceptQuest", function(player, quest_id)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(quest_id) ~= "string" or quest_id == "" then return end
    local QuestManager = require("npc/npc_quest_manager")
    local ok, _ = QuestManager.AcceptQuest(player, quest_id)
    if not ok then return end
    -- 接取后立即用 Wilba 物品栏重算一次，已有物品能立刻显示进度。
    local wilba_npc = nil
    for _, ent in pairs(_G.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") and ent.npc_character_type == "wilba" then
            wilba_npc = ent
            break
        end
    end
    QuestManager.RecomputeFromWilba(player, wilba_npc)
    -- 发送刷新信号给客户端
    local daily = QuestManager.GetDailyQuests(player)
    local accepted = QuestManager.GetAcceptedQuests(player)
    local daily_parts = {}
    for _, q in ipairs(daily) do
        daily_parts[#daily_parts + 1] = q.id .. "|" .. (q.name or q.id)
    end
    local accepted_parts = {}
    for _, q in ipairs(accepted) do
        local progress_str = ""
        if q.progress then
            local prog_parts = {}
            for _, v in pairs(q.progress) do
                prog_parts[#prog_parts + 1] = tostring(v)
            end
            progress_str = table.concat(prog_parts, ",")
        end
        accepted_parts[#accepted_parts + 1] = q.id .. "|" .. (q.name or q.id) .. "|" .. progress_str .. "|" .. tostring(q.completed == true)
    end
    local payload = table.concat(daily_parts, ";") .. "\n" .. table.concat(accepted_parts, ";")
        .. "\nmax_active=" .. tostring((require("npc_tuning").MAX_ACTIVE_QUESTS or 4))
    _G.SendModRPCToClient(
        _G.GetClientModRPC("NPCFriends", "RefreshQuestScreen"),
        player.userid,
        payload
    )
end)

AddModRPCHandler("NPCFriends", "AbandonQuest", function(player, quest_id)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(quest_id) ~= "string" or quest_id == "" then return end
    local QuestManager = require("npc/npc_quest_manager")
    local ok, _ = QuestManager.AbandonQuest(player, quest_id)
    if not ok then return end

    local daily = QuestManager.GetDailyQuests(player)
    local accepted = QuestManager.GetAcceptedQuests(player)
    local daily_parts = {}
    for _, q in ipairs(daily) do
        daily_parts[#daily_parts + 1] = q.id .. "|" .. (q.name or q.id)
    end
    local accepted_parts = {}
    for _, q in ipairs(accepted) do
        local progress_str = ""
        if q.progress then
            local prog_parts = {}
            for _, v in pairs(q.progress) do
                prog_parts[#prog_parts + 1] = tostring(v)
            end
            progress_str = table.concat(prog_parts, ",")
        end
        accepted_parts[#accepted_parts + 1] = q.id .. "|" .. (q.name or q.id) .. "|" .. progress_str .. "|" .. tostring(q.completed == true)
    end
    local payload = table.concat(daily_parts, ";") .. "\n" .. table.concat(accepted_parts, ";")
        .. "\nmax_active=" .. tostring((require("npc_tuning").MAX_ACTIVE_QUESTS or 4))
    _G.SendModRPCToClient(
        _G.GetClientModRPC("NPCFriends", "RefreshQuestScreen"),
        player.userid,
        payload
    )
end)

AddModRPCHandler("NPCFriends", "SubmitQuest", function(player, quest_id)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then return end
    if not player or type(quest_id) ~= "string" or quest_id == "" then return end
    local QuestManager = require("npc/npc_quest_manager")
    -- 找 Wilba NPC
    local wilba_npc = nil
    for _, ent in pairs(_G.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") and ent.npc_character_type == "wilba" then
            wilba_npc = ent
            break
        end
    end
    local ok, err = QuestManager.SubmitQuest(player, quest_id, wilba_npc)
    -- 无论成功失败都发送刷新信号；失败时 RecomputeFromWilba 已更新进度。
    local daily = QuestManager.GetDailyQuests(player)
    local accepted = QuestManager.GetAcceptedQuests(player)
    local daily_parts = {}
    for _, q in ipairs(daily) do
        daily_parts[#daily_parts + 1] = q.id .. "|" .. (q.name or q.id)
    end
    local accepted_parts = {}
    for _, q in ipairs(accepted) do
        local progress_str = ""
        if q.progress then
            local prog_parts = {}
            for _, v in pairs(q.progress) do
                prog_parts[#prog_parts + 1] = tostring(v)
            end
            progress_str = table.concat(prog_parts, ",")
        end
        accepted_parts[#accepted_parts + 1] = q.id .. "|" .. (q.name or q.id) .. "|" .. progress_str .. "|" .. tostring(q.completed == true)
    end
    local payload = table.concat(daily_parts, ";") .. "\n" .. table.concat(accepted_parts, ";")
        .. "\nmax_active=" .. tostring((require("npc_tuning").MAX_ACTIVE_QUESTS or 4))
    _G.SendModRPCToClient(
        _G.GetClientModRPC("NPCFriends", "RefreshQuestScreen"),
        player.userid,
        payload
    )
    -- 失败时回到任务详情页，显示当前进度和神秘随机奖励占位。
    if not ok then
        local detail = QuestManager.GetQuestDetail(quest_id)
        if detail then
            local parts = {
                detail.id or quest_id,
                detail.name or "",
                detail.desc or "",
            }
            for _, obj in ipairs(detail.objectives or {}) do
                parts[#parts + 1] = obj.prefab or ""
                parts[#parts + 1] = tostring(obj.count or 0)
                parts[#parts + 1] = obj.label or obj.prefab or ""
            end
            for _, rwd in ipairs(detail.rewards or {}) do
                parts[#parts + 1] = "rwd:" .. (rwd.prefab or "")
                parts[#parts + 1] = tostring(rwd.count or 0)
                parts[#parts + 1] = rwd.label or rwd.prefab or ""
            end
            local rnd_count = detail.random_count or 0
            if rnd_count > 0 then
                parts[#parts + 1] = "rnd:" .. tostring(rnd_count)
            end
            _G.SendModRPCToClient(
                _G.GetClientModRPC("NPCFriends", "ReceiveQuestDetail"),
                player.userid,
                table.concat(parts, "|")
            )
        end
    end
end)

local _NPC_RIFT_LIST_PENDING = {}

local function _BuildLocalRiftRows()
    local worldid = (_G.TheShard and _G.TheShard.GetShardId and _G.TheShard:GetShardId()) or "unknown"
    local worldlabel = (_G.TheWorld and _G.TheWorld.HasTag and _G.TheWorld:HasTag("cave")) and "caves" or "master"
    local rows = {}
    for _, ent in pairs(_G.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("npc_rift_portal") then
            local x, _, z = ent.Transform:GetWorldPosition()
            local name = "未命名记忆点"
            if ent.components and ent.components.writeable then
                local txt = ent.components.writeable:GetText()
                if txt and txt ~= "" then
                    name = string.gsub(txt, "[\r\n\t|]", " ")
                end
            end
            table.insert(rows, string.format("%s\t%s\t%s\t%.2f\t%.2f", tostring(worldid), tostring(worldlabel), tostring(name), x or 0, z or 0))
        end
    end
    return rows
end

_G.NPCFRIENDS_RIFT_RequestRemoteRows = function(player, source_guid, local_rows_blob)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        return
    end
    if player == nil or player.userid == nil then
        return
    end
    local reqid = tostring(_G.math.floor((_G.GetTime() or 0) * 1000)) .. "_" .. tostring(_G.math.random(10000, 99999))
    local pending = {
        userid = player.userid,
        source_guid = _G.tonumber(source_guid) or 0,
        rows = {},
        set = {},
    }
    _NPC_RIFT_LIST_PENDING[reqid] = pending
    for line in tostring(local_rows_blob or ""):gmatch("[^\n]+") do
        if not pending.set[line] then
            pending.set[line] = true
            pending.rows[#pending.rows + 1] = line
        end
    end

    local query = reqid .. "|" .. tostring(player.userid)
    _G.pcall(function()
        SendModRPCToShard(GetShardModRPC("NPCFriends", "RiftListQuery"), nil, query)
    end)

    _G.TheWorld:DoTaskInTime(0.35, function()
        local p = _NPC_RIFT_LIST_PENDING[reqid]
        if p == nil then return end
        _NPC_RIFT_LIST_PENDING[reqid] = nil
        local payload = table.concat(p.rows, "\n")
        SendModRPCToClient(GetClientModRPC("NPCFriends", "ReceiveRiftList"), p.userid, string.format("%d|%s", p.source_guid, payload))
    end)
end

AddShardModRPCHandler("NPCFriends", "RiftListQuery", function(src_shard_id, data)
    local reqid, userid = tostring(data or ""):match("^([^|]+)|(.+)$")
    if reqid == nil or userid == nil then
        return
    end
    local rows = _BuildLocalRiftRows()
    local blob = table.concat(rows, "\n")
    local resp = reqid .. "|" .. blob
    _G.pcall(function()
        SendModRPCToShard(GetShardModRPC("NPCFriends", "RiftListReply"), src_shard_id, resp)
    end)
end)

AddShardModRPCHandler("NPCFriends", "RiftListReply", function(src_shard_id, data)
    local reqid, blob = tostring(data or ""):match("^([^|]+)|?(.*)$")
    if reqid == nil then
        return
    end
    local pending = _NPC_RIFT_LIST_PENDING[reqid]
    if pending == nil then
        return
    end
    for line in tostring(blob or ""):gmatch("[^\n]+") do
        if not pending.set[line] then
            pending.set[line] = true
            pending.rows[#pending.rows + 1] = line
        end
    end
end)

-- NPC 伯尼持久化标签：存档后仍可识别为 NPC 薇洛的伯尼
AddPrefabPostInit("bernie_inactive", function(inst)
    if not _G.TheWorld.ismastersim then return end
    local _orig_onsave = inst.OnSave
    inst.OnSave = function(self, data)
        if _orig_onsave then _orig_onsave(self, data) end
        if self._is_npc_bernie then
            data.is_npc_bernie = true
        end
    end
    local _orig_onload = inst.OnLoad
    inst.OnLoad = function(self, data)
        if _orig_onload then _orig_onload(self, data) end
        if data and data.is_npc_bernie then
            self._is_npc_bernie = true
            self:AddTag("npc_bernie")
        end
    end
end)


-- WX-78 运输机：被 NPC 部署并打上 "npcfriend_publicdrone" 标记后，
local function NPCFriendPublicDronePostInit(inst)
    local _orig_canmapdeliver = inst.canmapdeliver
    inst.canmapdeliver = function(self, doer)
        if self:HasTag("npcfriend_publicdrone") then
            return doer ~= nil and self.isempty ~= nil and not self.isempty:value()
        end
        return _orig_canmapdeliver == nil or _orig_canmapdeliver(self, doer)
    end

    if not _G.TheWorld.ismastersim then return end

    local mapdeliverable = inst.components.mapdeliverable
    if mapdeliverable ~= nil then
        local _orig_startmapaction = mapdeliverable.onstartmapactionfn
        mapdeliverable:SetOnStartMapActionFn(function(self, doer)
            if self:HasTag("npcfriend_publicdrone") then
                if doer == nil or self._nointeract then return false end
                if self.isempty:value() then return false, "EMPTY" end
                return true
            end
            if _orig_startmapaction ~= nil then
                return _orig_startmapaction(self, doer)
            end
            return true
        end)
    end

    local _orig_onsave = inst.OnSave
    
    inst.OnSave = function(self, data)
        if _orig_onsave then _orig_onsave(self, data) end
        if self:HasTag("npcfriend_publicdrone") then
            data.npcfriend_publicdrone = true
        end
    end
    local _orig_onload = inst.OnLoad
    inst.OnLoad = function(self, data)
        if _orig_onload then _orig_onload(self, data) end
        if data and data.npcfriend_publicdrone then
            self:AddTag("npcfriend_publicdrone")
        end
    end
end
AddPrefabPostInit("wx78_drone_delivery", NPCFriendPublicDronePostInit)
AddPrefabPostInit("wx78_drone_delivery_small", NPCFriendPublicDronePostInit)


-- 服务端 RPC：解除 NPC 跟随
-- owner_param 格式: "KU_xxx:char_type:slot_index" 或旧格式 "char_type"
AddModRPCHandler("NPCFriends", "DismissNPC", function(player, owner_param)
    if not player or not _G.TheWorld.ismastersim then return end
    if type(owner_param) ~= "string" or owner_param == "" then return end
    local NPC_SPEECH = require("npc_speech")

    local parts = {}
    for seg in owner_param:gmatch("[^:]+") do parts[#parts + 1] = seg end
    local owner_userid = #parts >= 2 and parts[1] or nil
    local char_type    = #parts >= 2 and parts[2] or parts[1]
    local slot_index   = _G.tonumber(parts[3])

    for _, ent in pairs(_G.Ents) do
        if ent:IsValid() and ent:HasTag("npcfriend")
           and ent.npc_character_type == char_type then
            local leader = ent.components.follower and ent.components.follower.leader
            if leader and leader.userid == player.userid then
                -- 有 slot_index 时精确匹配，避免解除同角色的其他 NPC
                if slot_index and ent.npc_slot_index ~= slot_index then
                else
                    ent.components.follower:SetLeader(nil)
                    ent._work_paused = true
                    ent._owner_userid = nil
                    if ent.owner_userid then
                        ent.owner_userid:set("")
                    end
                    if ent.components.knownlocations then
                        ent.components.knownlocations:RememberLocation("home", ent:GetPosition())
                    end
                    if ent._update_hoverinfo then ent._update_hoverinfo() end
                    if ent.components.talker then
                        ent.components.talker:ShutUp()
                        if NPC_SPEECH.DISMISS then
                            local line = NPC_SPEECH.GetLine(NPC_SPEECH.DISMISS, ent.npc_character_type)
                            if line then ent.components.talker:Say(line) end
                        end
                    end
                    return
                end
            end
        end
    end
end)

--------------------------------------------------------------------------
-- NPC 命令 RPC（供 DstAdmin NPC 状态面板调用）
-- 命令处理逻辑已提取到 scripts/npc_commands.lua
--------------------------------------------------------------------------
local NpcCommands = require("npc_commands")
AddModRPCHandler("NPCFriends", "NPCCommand", function(player, params_str)
    NpcCommands.HandleCommand(player, params_str, {
        SendModRPCToClient = SendModRPCToClient,
        GetClientModRPC = GetClientModRPC,
    })
end)

-- ── 喂食 NPC 时玩家播放动画 ─────────────────────────
local function WrapFeedHandler(sg)
    local handler = sg.actionhandlers[_G.ACTIONS.FEED]
    if handler then
        local orig = handler.deststate
        handler.deststate = function(inst, action)
            if action.target and action.target:HasTag("npcfriend") then
                return "give"
            end
            return type(orig) == "function" and orig(inst, action) or orig
        end
    end
end
AddStategraphPostInit("wilson", WrapFeedHandler)
AddStategraphPostInit("wilson_client", WrapFeedHandler)

-- ══════════════════════════════════════════════════════════════════════════════
--  银项链：为 wilson 玩家添加独立的变身/还原状态
--  silvernecklace.lua 在玩家身上 DoTaskInTime 后会直接调用：
--      owner.sg:GoToState("silvernecklace_transform", data)
--      owner.sg:GoToState("silvernecklace_reform",    data)
-- ══════════════════════════════════════════════════════════════════════════════
do
    local State        = _G.State
    local EventHandler = _G.EventHandler

    local function GetUtils()  return _G.NPCFRIENDS_SILVERNECKLACE_UTILS or {}  end
    local function GetParams() return _G.NPCFRIENDS_SILVERNECKLACE_PARAMS or {} end

    local function LockPlayer(inst, locked)
        if inst.components.playercontroller then
            inst.components.playercontroller:Enable(not locked)
        end
        if locked and inst.components.locomotor then
            inst.components.locomotor:Stop()
        end
        if inst.Physics then
            inst.Physics:Stop()
        end
        if inst.components.health then
            inst.components.health:SetInvincible(locked)
        end
    end

    AddStategraphState("wilson", State{
        name = "silvernecklace_transform",
        tags = { "busy", "pausepredict", "nointerrupt", "nomorph", "transform" },

        onenter = function(inst, data)
            local P = GetParams()
            local U = GetUtils()
            inst._silvernecklace_transform_pending = true
            if U.DebugLog then U.DebugLog("SGwilson.silvernecklace_transform.onenter", inst) end
            LockPlayer(inst, true)

            inst.SoundEmitter:PlaySound(P.sound_to_were or "dontstarve/creatures/werepig/transformToWere")

            if not inst.Light then
                inst:AddComponent("light")
            end
            if inst.Light then
                inst.Light:Enable(true)
                inst.Light:SetColour(1, 0.2, 0.2)
                inst.Light:SetRadius(4)
                inst.Light:SetIntensity(0.6)
                inst.Light:SetFalloff(0.5)
            end
            if _G.TheWorld and _G.TheWorld.components.colourcubemanager then
                _G.TheWorld.components.colourcubemanager:SetOverrideColourCube(P.colour_cube or "images/colour_cubes/beaver_vision_cc.tex")
            end

            inst.sg.statemem.pst_build = (data and data.transform_build) or P.transform_build or "werewilba"
            inst.sg.statemem.pst_bank  = (data and data.transform_bank)  or P.transform_bank  or "wilson"

            inst.AnimState:AddOverrideBuild(P.override_build or "werewilba_transform")
            inst.AnimState:PlayAnimation(P.anim_pre or "transform_pre")
        end,

        events = {
            EventHandler("animover", function(inst)
                local P = GetParams()
                local U = GetUtils()
                if inst.sg.statemem.phase2 then
                    inst.AnimState:ClearOverrideBuild(P.override_build or "werewilba_transform")
                    inst._silvernecklace_were = true
                    inst._silvernecklace_transform_pending = false
                    if U.DebugLog then U.DebugLog("SGwilson.silvernecklace_transform.complete", inst) end
                    if U.ReconcileAfterTransform and U.ReconcileAfterTransform(inst) then
                        return
                    end
                    LockPlayer(inst, false)
                    if U.StartWerewilbaSounds then
                        U.StartWerewilbaSounds(inst)
                    end
                    inst.sg:GoToState("idle")
                else
                    if U.DebugLog then U.DebugLog("SGwilson.silvernecklace_transform.phase2", inst) end
                    if U.SpawnPuff then U.SpawnPuff(inst) end
                    inst.AnimState:SetBank(inst.sg.statemem.pst_bank)
                    inst.AnimState:SetBuild(inst.sg.statemem.pst_build)
                    inst.AnimState:PlayAnimation(P.anim_pst or "transform_pst")
                    inst.sg.statemem.phase2 = true
                end
            end),
        },

        onexit = function(inst)
            -- 成功路径：animover phase2 把 tpend 置 false 后才走到 onexit → interrupted=false。
            -- 中断路径（如被 knockback / 死亡 抢断）：animover 未跑完 → tpend 仍为 true → interrupted=true。
            -- 旧实现 `if not statemem.phase2 then ...` 在 phase2 中断时不重置 tpend，
            -- 会导致随后的 onunequip 一直走 defer_to_reconcile 分支，玩家卡在猪狼形态。
            local U = _G.NPCFRIENDS_SILVERNECKLACE_UTILS
            local interrupted = (inst._silvernecklace_transform_pending == true)
            inst._silvernecklace_transform_pending = false
            LockPlayer(inst, false)

            if interrupted then
                if U and U.DebugLog then
                    U.DebugLog("SGwilson.silvernecklace_transform.onexit.interrupted", inst)
                end
                local P = _G.NPCFRIENDS_SILVERNECKLACE_PARAMS or {}
                local override = P.override_build or "werewilba_transform"
                if inst.AnimState then
                    inst.AnimState:ClearOverrideBuild(override)
                end
                if inst.Light then inst.Light:Enable(false) end
                if _G.TheWorld and _G.TheWorld.components.colourcubemanager then
                    _G.TheWorld.components.colourcubemanager:SetOverrideColourCube(nil)
                end
                -- 形态可能停在 phase1（原 build）或 phase2 中（已 SetBuild=werewilba），
                -- 让 ApplyFinalFormAfterLoad 根据当前装备状态再补一次。
                if U and U.ApplyFinalFormAfterLoad then
                    inst:DoTaskInTime(0.1, function(i)
                        if i and i:IsValid() then
                            U.ApplyFinalFormAfterLoad(i)
                        end
                    end)
                end
            end
        end,
    })

    AddStategraphState("wilson", State{
        name = "silvernecklace_reform",
        tags = { "busy", "pausepredict", "nointerrupt", "nomorph", "transform" },

        onenter = function(inst, data)
            local P = GetParams()
            local U = GetUtils()
            inst._silvernecklace_reform_pending = true
            if U.DebugLog then U.DebugLog("SGwilson.silvernecklace_reform.onenter", inst) end
            LockPlayer(inst, true)

            if U.StopWerewilbaSounds then U.StopWerewilbaSounds(inst) end
            if inst.Light then inst.Light:Enable(false) end

            inst.SoundEmitter:PlaySound(P.sound_to_human or "dontstarve/creatures/werepig/transformToPig")

            -- 烟雾掩护下还原玩家外观（皮肤）
            if U.SpawnPuff then U.SpawnPuff(inst) end
            if U.RestoreAppearance then
                U.RestoreAppearance(inst)
            end

            inst.AnimState:AddOverrideBuild(P.override_build or "werewilba_transform")
            inst.AnimState:PlayAnimation(P.anim_reform or "reform")
        end,

        events = {
            EventHandler("animover", function(inst)
                local P = GetParams()
                local U = GetUtils()
                inst.AnimState:ClearOverrideBuild(P.override_build or "werewilba_transform")
                if _G.TheWorld and _G.TheWorld.components.colourcubemanager then
                    _G.TheWorld.components.colourcubemanager:SetOverrideColourCube(nil)
                end
                if U.DebugLog then U.DebugLog("SGwilson.silvernecklace_reform.complete", inst) end
                inst._silvernecklace_were = false
                inst._silvernecklace_transform_pending = false
                inst._silvernecklace_reform_pending = false
                inst._silvernecklace_queue_reform = false
                if U.ReconcileAfterReform and U.ReconcileAfterReform(inst) then
                    return
                end
                if U.ClearSavedAppearance then U.ClearSavedAppearance(inst) end
                LockPlayer(inst, false)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            -- 动画播完时 animover 已把 _silvernecklace_were 置 false；
            -- 若 onexit 时它仍为 true，说明 reform 被中断（knockback / 死亡 / 其它）。
            -- 无论是否被中断都强制清除，避免下次 onequip 因残留标志拒绝变身。
            local U = _G.NPCFRIENDS_SILVERNECKLACE_UTILS
            local interrupted = (inst._silvernecklace_were == true)
            LockPlayer(inst, false)
            inst._silvernecklace_were = false
            inst._silvernecklace_transform_pending = false
            inst._silvernecklace_reform_pending = false
            inst._silvernecklace_queue_reform = false
            if interrupted then
                if U and U.DebugLog then
                    U.DebugLog("SGwilson.silvernecklace_reform.onexit.interrupted", inst)
                end
                -- 中断后形态可能仍是猪狼外观 → 延一帧补一次形态同步
                if U and U.ApplyFinalFormAfterLoad then
                    inst:DoTaskInTime(0.1, function(i)
                        if i and i:IsValid() then
                            U.ApplyFinalFormAfterLoad(i)
                        end
                    end)
                end
            end
        end,
    })
end

-- ── Boss 攻击扩展：让仅遍历 AllPlayers / 仅瞄准 combat.target 的召唤攻击也能命中 NPC ───
do
    local DEGREES_VAL = _G.DEGREES
    local FRAMES_VAL  = _G.FRAMES

    -- ── 通用辅助：在 NPC 周围生成投射物 ──
    local function SpawnProjectileAtNPC(inst, npc, prefab)
        local px, py, pz = npc.Transform:GetWorldPosition()
        local proj = _G.SpawnPrefab(prefab)
        local radius = _G.GetRandomMinMax(3, 5)
        local angle  = (inst:GetAngleToPoint(px, py, pz)
            + _G.GetRandomMinMax(-90, 90)) * DEGREES_VAL
        proj.Transform:SetPosition(
            px + radius * math.cos(angle), py,
            pz + radius * -math.sin(angle))
        proj:ForceFacePoint(px, py, pz)
        proj:SetTargetPosition(_G.Vector3(px, py, pz))
    end

    local function FindAliveNPCs(ix, iz, range)
        local npcs = _G.TheSim:FindEntities(ix, 0, iz, range,
            {"npcfriend"}, {"INLIMBO", "playerghost"})
        local alive = {}
        for _, npc in ipairs(npcs) do
            if npc.components.health and not npc.components.health:IsDead()
                and not npc._is_ghost_mode then
                alive[#alive + 1] = npc
            end
        end
        return alive
    end

    local P1_MIN_GESTALTS, P1_MAX_GESTALTS = 3, 5
    local P1_EXTRA_BYHEALTH = 6
    local function SpawnP1GestaltsAtNPCs(inst)
        if not inst:IsValid() then return end
        local ix, _, iz = inst.Transform:GetWorldPosition()
        local npcs = FindAliveNPCs(ix, iz, 12)
        if #npcs == 0 then return end
        local hp_pct = inst.components.health and inst.components.health:GetPercent() or 1
        local num = math.ceil(_G.GetRandomMinMax(P1_MIN_GESTALTS, P1_MAX_GESTALTS)
            + (1 - hp_pct) * P1_EXTRA_BYHEALTH)
        for _, npc in ipairs(npcs) do
            for i = 1, num do
                inst:DoTaskInTime(2.0 + i * 4 * FRAMES_VAL, function(inst2)
                    if inst2:IsValid() and npc:IsValid()
                        and not npc.components.health:IsDead() then
                        SpawnProjectileAtNPC(inst2, npc, "gestalt_alterguardian_projectile")
                    end
                end)
            end
        end
    end

    local function HookP1GestaltSummon(inst)
        if not _G.TheWorld.ismastersim then return end
        local orig_enter = inst.EnterShield
        inst.EnterShield = function(inst2)
            local had_cd = inst2.components.timer:TimerExists("summon_cooldown")
            orig_enter(inst2)
            if not had_cd then
                SpawnP1GestaltsAtNPCs(inst2)
            end
        end
        inst:ListenForEvent("timerdone", function(inst, data)
            if data and data.name == "summon_cooldown" and inst._is_shielding then
                SpawnP1GestaltsAtNPCs(inst)
            end
        end)
    end
    AddPrefabPostInit("alterguardian_phase1", HookP1GestaltSummon)
    AddPrefabPostInit("alterguardian_phase1_lunarrift", HookP1GestaltSummon)


    local function SpawnGestaltsAtNPCs(inst)
        if not inst:IsValid() or inst.sg == nil
            or inst.sg.currentstate == nil
            or inst.sg.currentstate.name ~= "atk_summon_loop" then
            return
        end
        local ix, _, iz = inst.Transform:GetWorldPosition()
        local range = math.sqrt(_G.TUNING.ALTERGUARDIAN_PHASE3_SUMMONRSQ)
        local npcs = FindAliveNPCs(ix, iz, range)
        for _, npc in ipairs(npcs) do
            local prefab = (math.random() < 0.4 and "largeguard_alterguardian_projectile")
                or "gestalt_alterguardian_projectile"
            SpawnProjectileAtNPC(inst, npc, prefab)
        end
    end

    AddPrefabPostInit("alterguardian_phase3", function(inst)
        if not _G.TheWorld.ismastersim then return end
        inst:ListenForEvent("newstate", function(inst, data)
            if data and data.statename == "atk_summon_loop" then
                inst:DoTaskInTime(8  * FRAMES_VAL, SpawnGestaltsAtNPCs)
                inst:DoTaskInTime(16 * FRAMES_VAL, SpawnGestaltsAtNPCs)
            end
        end)
    end)


    AddPrefabPostInit("npcfriend", function(inst)
        if not _G.TheWorld.ismastersim then return end
        inst:ListenForEvent("attacked", function(inst, data)
            if data and data.damage == 0
                and data.attacker and data.attacker:IsValid()
                and data.attacker.prefab == "gestalt_alterguardian_projectile"
                and inst.components.health and not inst.components.health:IsDead()
                and not inst._is_ghost_mode then
                inst.components.health:DoDelta(-1)
                inst:PushEvent("knockedout")
            end
        end)
    end)
end

-- ── 清洁扫把换肤：右键 NPC 随机更换服装皮肤 ──────────────────────

do
    local NPC_TUNING_RES = require("npc_tuning")
    _G.NPC_TUNING = NPC_TUNING_RES  -- 导出到全局，供其他 mod（DstAdmin）访问
    _G.NPC_AFFINITY = require("npc/npc_affinity")  -- 导出好感度模块，供 DstAdmin 读取上限等
    AddPrefabPostInit("reskin_tool", function(inst)
        if not _G.TheWorld.ismastersim then return end

        inst:DoTaskInTime(0, function()
            if not inst:IsValid() then return end
            local sc = inst.components.spellcaster
            if not sc then return end

            local orig_cancast = sc.can_cast_fn
            sc:SetCanCastFn(function(doer, target, pos, tool)
                if target == nil or not target:HasTag("npcfriend") then
                    return orig_cancast and orig_cancast(doer, target, pos, tool) or false
                end
                if target.components.health and target.components.health:IsDead() then
                    return false
                end
                if target._is_ghost_mode then
                    return false
                end
                local cd = NPC_TUNING_RES.RESKIN_COOLDOWN or 3
                if target._npc_reskin_cd and (_G.GetTime() - target._npc_reskin_cd) < cd then
                    return false
                end
                return true
            end)

            local orig_spell = sc.spell
            sc:SetSpellFn(function(tool, target, pos, caster)
                if target and target:HasTag("npcfriend") and target.RandomizeNPCClothing then
                    if NPC_TUNING_RES.DEBUG_RESKIN then
                        print("[NPC_RESKIN] spellfn: NPC target, caster=", caster, " userid=", caster and caster.userid or "nil")
                    end
                    target._npc_reskin_cd = _G.GetTime()
                    local fx = _G.SpawnPrefab("explode_reskin")
                    if fx then
                        local tx, ty, tz = target.Transform:GetWorldPosition()
                        fx.Transform:SetPosition(tx, ty + 1.3, tz)
                        fx.Transform:SetScale(1.3, 1.3, 1.3)
                    end
                    target:RandomizeNPCClothing(caster)
                    return
                end
                if orig_spell then
                    orig_spell(tool, target, pos, caster)
                end
            end)
        end)
    end)
end

-- ── DSTAdmin Mod 依赖检测 ─────────────────────────────────────────
-- 进入世界 3 秒后检测 DSTAdmin 是否已加载（通过其注册的 ADMIN_VIEWNPC 动作判定）
-- 未安装时：每 30 秒所有 NPC 强制喊话提醒，且覆盖一切 NPC 语音
do
    -- 语言检测：与 DSTAdmin i18n 同逻辑
    local function _IsChineseLang()
        local ok, val = _G.pcall(function() return _G.STRINGS.UI.MAINSCREEN.PLAY end)
        if ok and val and val:match("[\228-\233]") then return true end
        local ok2, lt = _G.pcall(function() return _G.LanguageTranslator end)
        if ok2 and lt and lt.defaultlanguage then
            local l = tostring(lt.defaultlanguage)
            if l:find("zh") or l == "schinese" or l == "tchinese" then return true end
        end
        return false
    end
    local WARNING_MSG = _IsChineseLang()
        and "请安装DSTAdmin Mod，否则打不开我的物品栏"
        or  "Please install DSTAdmin Mod , nto open NPC inventory"

    local function HookNPCTalker(inst)
        if inst._dstadmin_warn_hooked then return end
        local talker = inst.components.talker
        if not talker then return end
        inst._dstadmin_warn_hooked = true
        local _orig_Say = talker.Say
        talker.Say = function(self, msg, ...)
            return _orig_Say(self, WARNING_MSG, ...)
        end
    end

    AddPrefabPostInit("world", function(inst)
        if not _G.TheWorld.ismastersim then return end
        inst:DoTaskInTime(3, function()
            -- DSTAdmin 加载后会注册 ADMIN_VIEWNPC 动作，以此判定是否已安装
            if _G.ACTIONS.ADMIN_VIEWNPC then return end

            _G.NPCFRIENDS._dstadmin_missing = true
            print("[NPCFriends] 警告: DSTAdmin Mod 未检测到，NPC 物品栏功能不可用")

            local function WarnAllNPCs()
                for _, ent in pairs(_G.Ents) do
                    if ent:IsValid() and ent:HasTag("npcfriend") then
                        HookNPCTalker(ent)
                        if ent.components.talker then
                            ent.components.talker:ShutUp()
                            ent.components.talker:Say(WARNING_MSG)
                        end
                    end
                end
            end
            WarnAllNPCs()
            inst:DoPeriodicTask(30, WarnAllNPCs)
        end)
    end)

    AddPrefabPostInit("npcfriend", function(inst)
        if not _G.TheWorld.ismastersim then return end
        inst:DoTaskInTime(4, function()
            if not inst:IsValid() or not _G.NPCFRIENDS._dstadmin_missing then return end
            HookNPCTalker(inst)
        end)
    end)
end

-- ════════════════════════════════════════════════════════════
--  远古大门地刺 / 柱子：NPC伙伴靠近时自动取消角色碰撞
-- ════════════════════════════════════════════════════════════

local ATRIUM_NPC_NEAR_SQ = 7 * 7   -- NPC 靠近距离（平方）
local ATRIUM_NPC_FAR_SQ  = 8 * 8   -- NPC 远离距离（平方）

--- 检测附近是否有NPC伙伴
local function IsAnyNPCInRangeSq(x, y, z, rangesq)
    local r = math.sqrt(rangesq)
    local ents = _G.TheSim:FindEntities(x, y, z, r, {"npcfriend"}, {"INLIMBO", "playerghost"})
    return #ents > 0
end

-- 地刺（atrium_fence）：NPC靠近时也触发缩回
AddPrefabPostInit("atrium_fence", function(inst)
    if not _G.TheWorld.ismastersim then return end
    inst._npc_opened = false
    inst:DoPeriodicTask(0.2, function(i)
        local x, y, z = i.Transform:GetWorldPosition()
        local npc_near = IsAnyNPCInRangeSq(x, y, z, ATRIUM_NPC_NEAR_SQ)
        if npc_near then
            i._npc_opened = true
            i.Physics:ClearCollidesWith(_G.COLLISION.CHARACTERS)
        elseif i._npc_opened then
            i._npc_opened = false
            if i.closed then
                i.Physics:CollidesWith(_G.COLLISION.CHARACTERS)
            end
        end
    end, math.random() * 0.2)
end)

-- 柱子（pillar_atrium）：NPC靠近时取消角色碰撞
AddPrefabPostInit("pillar_atrium", function(inst)
    if not _G.TheWorld.ismastersim then return end
    -- 柱子没有动态碰撞切换，但保持与地刺一致的持续清除模式
    inst._npc_opened = false
    inst:DoPeriodicTask(0.2, function(i)
        local x, y, z = i.Transform:GetWorldPosition()
        local npc_near = IsAnyNPCInRangeSq(x, y, z, ATRIUM_NPC_NEAR_SQ)
        if npc_near then
            i._npc_opened = true
            i.Physics:ClearCollidesWith(_G.COLLISION.CHARACTERS)
        elseif i._npc_opened then
            i._npc_opened = false
            i.Physics:CollidesWith(_G.COLLISION.CHARACTERS)
        end
    end, math.random() * 0.2)
end)

-- ════════════════════════════════════════════════════════════
--  火把攻击修复：NPC 没有 skilltreeupdater 组件，原版 onattack
-- ════════════════════════════════════════════════════════════
AddPrefabPostInit("torch", function(inst)
    if not _G.TheWorld.ismastersim then return end
    if inst.components.weapon then
        local orig_onattack = inst.components.weapon.onattack
        if orig_onattack then
            inst.components.weapon:SetOnAttack(function(weapon, attacker, target)
                if attacker.components.skilltreeupdater == nil then
                    if target ~= nil and target:IsValid() and target.components.burnable ~= nil
                        and math.random() < _G.TUNING.TORCH_ATTACK_IGNITE_PERCENT * target.components.burnable.flammability then
                        target.components.burnable:Ignite(nil, attacker)
                    end
                else
                    orig_onattack(weapon, attacker, target)
                end
            end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════
--  海钓增强：NPC 空钩 charm 倍率提升
-- ════════════════════════════════════════════════════════════
AddComponentPostInit("oceanfishinghook", function(self, inst)
    if not _G.TheNet:GetIsServer() then return end

    local _orig_SetLureData = self.SetLureData
    if _orig_SetLureData then
        function self:SetLureData(lure_data, lure_fns)
            if lure_data and lure_data.style == "hook" then
                -- 通过 oceanfishable → rod → fisher 链获取使用者
                local rod = inst.components.oceanfishable and inst.components.oceanfishable:GetRod()
                local rod_comp = rod and rod.components.oceanfishingrod
                local fisher = rod_comp and rod_comp.fisher
                local is_npc = fisher and fisher.npc_character_type ~= nil

                if is_npc then
                    -- 仅对 NPC 空钩应用 charm 倍率增强
                    local NPC_TUNING_HOOK = require("npc_tuning")
                    if not lure_fns then lure_fns = {} end
                    local mult = NPC_TUNING_HOOK.OCEAN_FISHING_NPC_HOOK_CHARM_MULT or 2.5
                    local _old_charm_mod = lure_fns.charm_mod_fn
                    lure_fns.charm_mod_fn = function(fish)
                        return (_old_charm_mod and _old_charm_mod(fish) or 1) * mult
                    end
                end
            end
            return _orig_SetLureData(self, lure_data, lure_fns)
        end
    end
end)

-- ════════════════════════════════════════════════════════════
--  DEBUG: NPC 位置与缺失检测（控制台可直接调用）
--  用法：
--    npc_debug_dump()              -- 打印全部 NPC
--    npc_debug_dump("wormwood")    -- 仅打印植物人
--    npc_debug_missing()           -- 打印配置中缺失的角色/slot
-- ════════════════════════════════════════════════════════════
local function _NpcDebugDump(filter_char)
    local total = 0
    local by_char = {}
    local ents = _G.Ents or {}
    for _, ent in pairs(ents) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            local char = ent.npc_character_type or "nil"
            if filter_char == nil or filter_char == char then
                total = total + 1
                by_char[char] = (by_char[char] or 0) + 1
                local x, y, z = ent.Transform:GetWorldPosition()
                local leader = ent.components.follower and ent.components.follower.leader
                local leader_uid = leader and leader.userid or "-"
                local owner_uid = (ent.owner_userid and ent.owner_userid:value()) or (ent._owner_userid or "-")
                local ghost = ent._is_ghost_mode and "1" or "0"
                local farm_center = (ent._farmer and ent._farmer.farm_center) and
                    string.format("%.1f,%.1f", ent._farmer.farm_center.x, ent._farmer.farm_center.z) or "-"
                local cook_center = ent._cooking_center and string.format("%.1f,%.1f", ent._cooking_center.x, ent._cooking_center.z) or "-"
                local wes_center = ent._wes_farm_center and string.format("%.1f,%.1f", ent._wes_farm_center.x, ent._wes_farm_center.z) or "-"
                local winona_center = ent._winona_farm_center and string.format("%.1f,%.1f", ent._winona_farm_center.x, ent._winona_farm_center.z) or "-"
                print(string.format(
                    "[NPC_DEBUG] GUID=%s char=%s slot=%s ghost=%s pos=(%.1f,%.1f,%.1f) owner=%s leader=%s farm=%s cook=%s wes=%s winona=%s",
                    tostring(ent.GUID), char, tostring(ent.npc_slot_index or "-"), ghost, x, y, z,
                    tostring(owner_uid), tostring(leader_uid), farm_center, cook_center, wes_center, winona_center
                ))
            end
        end
    end
    print(string.format("[NPC_DEBUG] total=%d filter=%s", total, tostring(filter_char)))
    for char, cnt in pairs(by_char) do
        print(string.format("[NPC_DEBUG] count %s = %d", char, cnt))
    end
end

local function _NpcDebugMissing()
    local NPC_TUNING = require("npc_tuning")
    local expected = {}
    for i, entry in ipairs(NPC_TUNING.NPC_CHARACTERS or {}) do
        local char_name, enabled
        if type(entry) == "table" then
            char_name = entry.char or "wilson"
            enabled = (entry.enabled == nil) and true or entry.enabled
        else
            char_name = entry
            enabled = true
        end
        if enabled then
            expected[i] = char_name
        end
    end

    local found = {}
    for _, ent in pairs(_G.Ents or {}) do
        if ent and ent:IsValid() and ent:HasTag("npcfriend") then
            local slot = ent.npc_slot_index
            if slot ~= nil then
                found[slot] = ent.npc_character_type or "nil"
            end
        end
    end

    for slot, exp_char in pairs(expected) do
        local got = found[slot]
        if got == nil then
            print(string.format("[NPC_DEBUG] MISSING slot=%d expected=%s", slot, tostring(exp_char)))
        elseif got ~= exp_char then
            print(string.format("[NPC_DEBUG] MISMATCH slot=%d expected=%s actual=%s", slot, tostring(exp_char), tostring(got)))
        end
    end
    print("[NPC_DEBUG] missing check done")
end

_G.npc_debug_dump = _NpcDebugDump
_G.npc_debug_missing = _NpcDebugMissing

-- ════════════════════════════════════════════════════════════
--  c_spawnnpc("char_name")
--    在执行者附近生成一个独立副本 NPC。
--    * 自动分配唯一 slot（>= DUPLICATE_SLOT_BASE，与正版配置 slot 不冲突）
--    * 自动派发初始装备（与 companion_spawner 相同的一套）
-- ════════════════════════════════════════════════════════════
local NPCDuplicateSpawn = require("npc_duplicate_spawn")

_G.c_spawnnpc = function(char_name)
    if not (_G.TheWorld and _G.TheWorld.ismastersim) then
        print("[c_spawnnpc] 必须在服务端 / 单机控制台执行（master sim 端）")
        return nil
    end
    if type(char_name) ~= "string" or char_name == "" then
        print("[c_spawnnpc] 用法: c_spawnnpc(\"wathgrithr\")")
        print("[c_spawnnpc] 可用角色: " ..
            table.concat(NPCDuplicateSpawn.GetSupportedCharacters(), ", "))
        return nil
    end
    if not NPCDuplicateSpawn.IsValidCharacter(char_name) then
        print(string.format("[c_spawnnpc] 角色名无效: %s", tostring(char_name)))
        print("[c_spawnnpc] 可用角色: " ..
            table.concat(NPCDuplicateSpawn.GetSupportedCharacters(), ", "))
        return nil
    end

    -- 优先用控制台选中的玩家（c_select 选中的）做参照点，没有则取第一个在线玩家
    local ref_player = (_G.ConsoleCommandPlayer and _G.ConsoleCommandPlayer())
                       or (_G.AllPlayers and _G.AllPlayers[1])
                       or nil

    local npc, err = NPCDuplicateSpawn.SpawnDuplicate(char_name, {
        near_player = ref_player,
    })
    if not npc then
        print(string.format("[c_spawnnpc] 生成失败: %s", tostring(err)))
        return nil
    end

    print(string.format("[c_spawnnpc] OK char=%s slot=%s GUID=%s",
        char_name, tostring(npc.npc_slot_index), tostring(npc.GUID)))
    return npc
end

-- ════════════════════════════════════════════════════════════
--  c_gonpc("char_name")  -- 切换到指定角色的 NPC
-- ════════════════════════════════════════════════════════════
do
    local _cycle_cursor = {}  -- char_name -> 上次跳过的 GUID

    local function _DistTo(player, ent)
        if not (player and player.Transform and ent and ent.Transform) then
            return 0
        end
        local px, _, pz = player.Transform:GetWorldPosition()
        local ex, _, ez = ent.Transform:GetWorldPosition()
        local dx, dz = ex - px, ez - pz
        return math.sqrt(dx * dx + dz * dz)
    end

    local function _CallerPlayer()
        return (_G.ConsoleCommandPlayer and _G.ConsoleCommandPlayer())
            or (_G.AllPlayers and _G.AllPlayers[1])
            or nil
    end

    _G.c_gonpc = function(char_name)
        if not (_G.TheWorld and _G.TheWorld.ismastersim) then
            print("[c_gonpc] 必须在服务端 / 单机控制台执行（master sim 端）")
            return nil
        end

        local caller = _CallerPlayer()
        if not caller then
            print("[c_gonpc] 未找到执行玩家")
            return nil
        end

        -- ── 不传参数：列出所有 NPC ──
        if char_name == nil then
            local list = {}
            for _, ent in pairs(_G.Ents or {}) do
                if ent and ent:IsValid() and ent:HasTag("npcfriend") then
                    table.insert(list, {
                        char = ent.npc_character_type or "?",
                        slot = ent.npc_slot_index or "-",
                        guid = ent.GUID,
                        dist = _DistTo(caller, ent),
                    })
                end
            end
            table.sort(list, function(a, b) return a.dist < b.dist end)
            print(string.format("[c_gonpc] 当前世界 NPC 共 %d 只（按距离排序）：", #list))
            for _, n in ipairs(list) do
                print(string.format("  char=%-14s slot=%-6s GUID=%-8s dist=%.1f",
                    tostring(n.char), tostring(n.slot), tostring(n.guid), n.dist))
            end
            print("[c_gonpc] 用法: c_gonpc(\"wathgrithr\") 切到该角色（多只时循环切换）")
            return nil
        end

        if type(char_name) ~= "string" or char_name == "" then
            print("[c_gonpc] 用法: c_gonpc(\"wathgrithr\")")
            return nil
        end

        -- ── 收集匹配的 NPC，按距离排序 ──
        local matches = {}
        for _, ent in pairs(_G.Ents or {}) do
            if ent and ent:IsValid() and ent:HasTag("npcfriend")
               and ent.npc_character_type == char_name then
                table.insert(matches, ent)
            end
        end

        if #matches == 0 then
            print(string.format("[c_gonpc] 世界中未找到角色为 %s 的 NPC", char_name))
            return nil
        end

        table.sort(matches, function(a, b)
            return _DistTo(caller, a) < _DistTo(caller, b)
        end)

        -- ── 循环游标：上次跳到的 GUID 之后那一只；否则跳到最近一只 ──
        local target = nil
        local last_guid = _cycle_cursor[char_name]
        if last_guid then
            for i, ent in ipairs(matches) do
                if ent.GUID == last_guid then
                    target = matches[(i % #matches) + 1]
                    break
                end
            end
        end
        target = target or matches[1]
        _cycle_cursor[char_name] = target.GUID

        if _G.c_goto then
            _G.c_goto(target)
        else
            local tx, ty, tz = target.Transform:GetWorldPosition()
            caller.Transform:SetPosition(tx, ty, tz)
        end

        print(string.format("[c_gonpc] 跳到 char=%s slot=%s GUID=%s （该角色共 %d 只）",
            char_name, tostring(target.npc_slot_index or "-"),
            tostring(target.GUID), #matches))
        return target
    end
end
