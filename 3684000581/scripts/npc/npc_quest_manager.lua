-- scripts/npc/npc_quest_manager.lua
-- 猪人公主任务管理器（服务端）
-- 负责任务分配、进度追踪、提交验证、奖励发放
-- ════════════════════════════════════════════════════════════

local QuestData = require("npc/npc_quest_data")
local NPC_TUNING = require("npc_tuning")

local QuestManager = {}

-- 每天刷新4个新任务
local DAILY_QUEST_COUNT = 4
local function GetMaxAcceptedQuests()
    return NPC_TUNING.MAX_ACTIVE_QUESTS or 4
end

-- ── 特殊任务：薇洛打火机 ────────────────────────────────────
local WILLOW_LIGHTER_QUEST_ID = "quest_craft_lighter_for_willow"

-- 判断某 NPC 薇洛是否持有打火机（装备栏或物品栏任意格）
local function NPCWillowHasLighter(npc)
    local inv = npc.components and npc.components.inventory
    if not inv then return false end
    local eq = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if eq and eq.prefab == "lighter" then return true end
    for _, v in pairs(inv.itemslots) do
        if v and v.prefab == "lighter" then return true end
    end
    return false
end

-- 世界里是否存在"没有打火机"的 NPC 薇洛（有 → 任务可刷新；无薇洛 / 都有打火机 → 不刷新）
local function WorldHasWillowNeedingLighter()
    for _, ent in pairs(Ents) do
        if ent and ent:IsValid()
           and ent.prefab == "npcfriend"
           and ent.npc_character_type == "willow"
           and not ent._is_ghost_mode
           and not NPCWillowHasLighter(ent) then
            return true
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════════
--  存储结构（挂载在 TheWorld 上）
--  _npc_quests = {
--      [player.userid] = {
--          daily          = { quest_id, quest_id, quest_id, quest_id },  -- 当日刷出的4个任务ID
--          daily_random   = { [quest_id] = { {prefab,count,label}, ... } },  -- 每个任务的随机奖励
--          accepted       = {                                    -- 已接任务
--              [quest_id] = {
--                  progress       = { [obj_index] = count },    -- 各目标进度
--                  completed      = bool,                        -- 是否已完成
--                  random_rewards = { {prefab,count,label}, ... },  -- 该任务的随机奖励（接取时固化）
--              }
--          },
--          completed_ids  = { [quest_id] = true },               -- 已完成过的任务ID（防重复）
--          last_refresh_day = N,                                 -- 上次刷新天数
--      }
--  }
-- ════════════════════════════════════════════════════════════

--- 获取玩家的任务数据
local function GetPlayerQuestData(player)
    if not player or not player.userid then return nil end
    if not TheWorld._npc_quests then
        TheWorld._npc_quests = {}
    end
    if not TheWorld._npc_quests[player.userid] then
        TheWorld._npc_quests[player.userid] = {
            daily          = {},
            daily_random   = {},
            accepted       = {},
            completed_ids  = {},
            abandoned_ids  = {},
            last_refresh_day = 0,
        }
    end
    local data = TheWorld._npc_quests[player.userid]
    data.daily = data.daily or {}
    data.daily_random = data.daily_random or {}
    data.accepted = data.accepted or {}
    data.completed_ids = data.completed_ids or {}
    data.abandoned_ids = data.abandoned_ids or {}
    data.last_refresh_day = data.last_refresh_day or 0
    return data
end

--- 刷新每日任务
function QuestManager.RefreshDailyQuests(player)
    local data = GetPlayerQuestData(player)
    if not data then return end

    local current_day = TheWorld.state.cycles or 0
    if data.daily and #data.daily > 0 and data.last_refresh_day == current_day then
        return data.daily  -- 今天已经刷过，不重复刷
    end

    data.last_refresh_day = current_day

    -- 新的一天清空已完成标记，让做过的任务重新进入随机池
    if data.completed_ids then
        for id in pairs(data.completed_ids) do
            data.completed_ids[id] = nil
        end
    end
    if data.abandoned_ids then
        for id in pairs(data.abandoned_ids) do
            data.abandoned_ids[id] = nil
        end
    end

    -- 排除已接但未完成的，避免每日列表重复显示
    local exclude = {}
    for id, _ in pairs(data.accepted) do
        exclude[#exclude + 1] = id
    end

    local quests = QuestData.GetRandomQuests(DAILY_QUEST_COUNT, exclude)
    data.daily = {}
    data.daily_random = {}
    for _, q in ipairs(quests) do
        data.daily[#data.daily + 1] = q.id
        -- 抽取随机奖励
        local random_count = q.random_count or 1
        if random_count > 0 then
            local rand_rwds = {}
            for i = 1, random_count do
                rand_rwds[#rand_rwds + 1] = QuestData.DrawRandomReward()
            end
            data.daily_random[q.id] = rand_rwds
        end
    end

    -- ── 特殊任务注入：薇洛打火机 ──
    local chance = NPC_TUNING.WILLOW_LIGHTER_QUEST_CHANCE or 0.5
    if not data.accepted[WILLOW_LIGHTER_QUEST_ID]
       and not data.completed_ids[WILLOW_LIGHTER_QUEST_ID]
       and math.random() < chance
       and WorldHasWillowNeedingLighter() then
        if #data.daily > 0 then
            data.daily[math.random(#data.daily)] = WILLOW_LIGHTER_QUEST_ID
        else
            data.daily[#data.daily + 1] = WILLOW_LIGHTER_QUEST_ID
        end
        data.daily_random[WILLOW_LIGHTER_QUEST_ID] = nil
    end

    return data.daily
end

--- 接受任务
function QuestManager.AcceptQuest(player, quest_id)
    local data = GetPlayerQuestData(player)
    if not data then return false, "no_data" end

    if data.accepted[quest_id] then
        return false, "already_accepted"
    end
    if data.abandoned_ids[quest_id] then
        return false, "abandoned_today"
    end

    if data.completed_ids[quest_id] then
        return false, "already_completed"
    end

    local in_daily = false
    for _, id in ipairs(data.daily) do
        if id == quest_id then
            in_daily = true
            break
        end
    end
    if not in_daily then
        return false, "not_in_daily"
    end

    local accepted_count = 0
    for _, _ in pairs(data.accepted) do
        accepted_count = accepted_count + 1
    end
    if accepted_count >= GetMaxAcceptedQuests() then
        return false, "too_many_accepted"
    end

    local def = QuestData.GetDef(quest_id)
    if not def then
        return false, "invalid_quest"
    end

    local rand_rwds = data.daily_random and data.daily_random[quest_id] or {}
    data.accepted[quest_id] = {
        progress       = {},
        completed      = false,
        random_rewards = rand_rwds,
    }
    for i = 1, #def.objectives do
        data.accepted[quest_id].progress[i] = 0
    end

    return true, "ok"
end

function QuestManager.OnItemCollected(player, prefab, count)
    return false
end

function QuestManager.OnKill(player, prefab, victim)
    if not player or not player.userid then return false end
    local data = GetPlayerQuestData(player)
    if not data then return false end

    local char_type = nil
    if victim and victim:IsValid() and prefab == "npcfriend" then
        char_type = victim.npc_character_type
    end

    local updated = false
    for quest_id, quest_state in pairs(data.accepted) do
        local def = QuestData.GetDef(quest_id)
        if def then
            for i, obj in ipairs(def.objectives) do
                if obj.is_kill then
                    local matched = false
                    if prefab == "npcfriend" and obj._npc_char_type then
                        matched = (char_type == obj._npc_char_type)
                    else
                        matched = (obj.prefab == prefab)
                    end
                    if matched then
                        quest_state.progress[i] = math.min(
                            (quest_state.progress[i] or 0) + 1,
                            obj.count
                        )
                        updated = true
                    end
                end
            end

            local all_done = true
            for i, obj in ipairs(def.objectives) do
                if (quest_state.progress[i] or 0) < obj.count then
                    all_done = false
                    break
                end
            end
            quest_state.completed = all_done
        end
    end

    return updated
end

--- 检查任务是否已完成（所有目标达成）
function QuestManager.IsQuestCompleted(player, quest_id)
    local data = GetPlayerQuestData(player)
    if not data or not data.accepted[quest_id] then
        return false
    end
    return data.accepted[quest_id].completed == true
end

--- 删除/放弃当前已接任务：只清掉本次接取状态和进度，不永久屏蔽任务
function QuestManager.AbandonQuest(player, quest_id)
    local data = GetPlayerQuestData(player)
    if not data then return false, "no_data" end
    if not data.accepted[quest_id] then
        return false, "not_accepted"
    end
    data.accepted[quest_id] = nil
    data.abandoned_ids[quest_id] = true
    return true, "ok"
end

local function _CountInContainer(cont, prefab)
    if not cont then return 0 end
    local total = 0
    for i = 1, (cont.numslots or 0) do
        local item = cont:GetItemInSlot(i)
        if item and item:IsValid() then
            if item.prefab == prefab then
                if item.components and item.components.stackable then
                    total = total + item.components.stackable:StackSize()
                else
                    total = total + 1
                end
            end
            if item.components and item.components.container then
                total = total + _CountInContainer(item.components.container, prefab)
            end
        end
    end
    return total
end

local function _CountInInventory(inv, prefab)
    if not inv then return 0 end
    local total = 0
    local items = inv:FindItems(function(item) return item.prefab == prefab end)
    for _, item in ipairs(items or {}) do
        if item.components and item.components.stackable then
            total = total + item.components.stackable:StackSize()
        else
            total = total + 1
        end
    end
    if inv.opencontainers then
        for _, container in ipairs(inv.opencontainers) do
            if container and container.components and container.components.container then
                total = total + _CountInContainer(container.components.container, prefab)
            end
        end
    end
    return total
end

function QuestManager.RecomputeFromWilba(player, wilba_npc)
    if not player or not player.userid then return false end
    local data = GetPlayerQuestData(player)
    if not data then return false end

    local changed = false
    local wilba_inv = wilba_npc and wilba_npc:IsValid() and wilba_npc.components and wilba_npc.components.inventory
    for quest_id, quest_state in pairs(data.accepted) do
        local def = QuestData.GetDef(quest_id)
        if def then
            for i, obj in ipairs(def.objectives) do
                if not obj.is_kill then
                    local new_progress = wilba_inv and _CountInInventory(wilba_inv, obj.prefab) or 0
                    new_progress = math.min(new_progress, obj.count)
                    if quest_state.progress[i] ~= new_progress then
                        quest_state.progress[i] = new_progress
                        changed = true
                    end
                end
            end

            local all_done = true
            for i, obj in ipairs(def.objectives) do
                if (quest_state.progress[i] or 0) < obj.count then
                    all_done = false
                    break
                end
            end
            if quest_state.completed ~= all_done then
                quest_state.completed = all_done
                changed = true
            end
        end
    end
    return changed
end

--- 提交任务（校验 Wilba 背包 + 扣除物品 + 发放奖励）
function QuestManager.SubmitQuest(player, quest_id, wilba_npc)
    local data = GetPlayerQuestData(player)
    if not data then return false, "no_data" end

    local quest_state = data.accepted[quest_id]
    if not quest_state then
        return false, "not_accepted"
    end

    QuestManager.RecomputeFromWilba(player, wilba_npc)
    quest_state = data.accepted[quest_id]
    if not quest_state.completed then
        return false, "not_completed"
    end

    local def = QuestData.GetDef(quest_id)
    if not def then
        return false, "invalid_quest"
    end

    local wilba_inv = wilba_npc and wilba_npc:IsValid() and wilba_npc.components and wilba_npc.components.inventory
    if not wilba_inv then
        return false, "no_wilba"
    end

    for _, obj in ipairs(def.objectives) do
        if not obj.is_kill then
            local needed = obj.count
            local items = wilba_inv:FindItems(function(item)
                return item.prefab == obj.prefab
            end)
            for _, item in ipairs(items or {}) do
                if needed <= 0 then break end
                if item.components and item.components.stackable then
                    local take = math.min(item.components.stackable:StackSize(), needed)
                    item.components.stackable:SetStackSize(
                        item.components.stackable:StackSize() - take
                    )
                    if item.components.stackable:StackSize() <= 0 then
                        item:Remove()
                    end
                    needed = needed - take
                else
                    item:Remove()
                    needed = needed - 1
                end
            end
        end
    end

    local function spawn_reward(rwd)
        local reward_item = SpawnPrefab(rwd.prefab)
        if reward_item then
            if reward_item.components.stackable and (rwd.count or 1) > 1 then
                reward_item.components.stackable:SetStackSize(rwd.count)
            end
            player.components.inventory:GiveItem(reward_item, nil, wilba_npc:GetPosition())
        end
    end

    for _, reward in ipairs(def.rewards or {}) do
        spawn_reward(reward)
    end
    for _, rwd in ipairs(quest_state.random_rewards or {}) do
        spawn_reward(rwd)
    end

    data.completed_ids[quest_id] = true
    data.accepted[quest_id] = nil

    return true, "ok"
end

function QuestManager.GetAcceptedQuests(player)
    local data = GetPlayerQuestData(player)
    if not data then return {} end

    local result = {}
    for quest_id, quest_state in pairs(data.accepted) do
        local def = QuestData.GetDef(quest_id)
        if def then
            result[#result + 1] = {
                id         = quest_id,
                name       = def.name,
                objectives = def.objectives,
                rewards    = def.rewards,
                random_rewards = quest_state.random_rewards or {},
                progress   = quest_state.progress,
                completed  = quest_state.completed,
            }
        end
    end
    return result
end

--- 获取当日任务列表（用于UI显示）
function QuestManager.GetDailyQuests(player)
    local data = GetPlayerQuestData(player)
    if not data then return {} end

    -- 确保已刷新
    if #data.daily == 0 then
        QuestManager.RefreshDailyQuests(player)
    end

    local result = {}
    for _, quest_id in ipairs(data.daily) do
        -- 跳过已接的任务
        if not data.accepted[quest_id] and not data.completed_ids[quest_id] and not data.abandoned_ids[quest_id] then
            local def = QuestData.GetDef(quest_id)
            if def then
                result[#result + 1] = {
                    id         = quest_id,
                    name       = def.name,
                }
            end
        end
    end
    return result
end

--- 获取玩家某每日任务的随机奖励
function QuestManager.GetDailyRandomRewards(player, quest_id)
    local data = GetPlayerQuestData(player)
    if not data or not data.daily_random then return {} end
    return data.daily_random[quest_id] or {}
end

--- 获取任务详情（供UI展示）
function QuestManager.GetQuestDetail(quest_id)
    local def = QuestData.GetDef(quest_id)
    if not def then return nil end
    return {
        id         = def.id,
        name       = def.name,
        desc       = def.desc,
        objectives = def.objectives,
        rewards    = def.rewards,
        random_count = def.random_count or 0,
    }
end

--- 序列化（用于存档）
function QuestManager.OnSave()
    if not TheWorld._npc_quests then return {} end
    local save_data = {}
    for uid, data in pairs(TheWorld._npc_quests) do
        save_data[uid] = {
            daily          = data.daily,
            daily_random   = data.daily_random and deepcopy(data.daily_random) or {},
            accepted       = {},
            completed_ids  = {},
            abandoned_ids  = {},
            last_refresh_day = data.last_refresh_day or 0,
        }
        for qid, qs in pairs(data.accepted) do
            save_data[uid].accepted[qid] = {
                progress        = qs.progress,
                completed       = qs.completed,
                random_rewards  = qs.random_rewards and deepcopy(qs.random_rewards) or {},
            }
        end
        for qid, _ in pairs(data.completed_ids) do
            save_data[uid].completed_ids[qid] = true
        end
        for qid, _ in pairs(data.abandoned_ids or {}) do
            save_data[uid].abandoned_ids[qid] = true
        end
    end
    return save_data
end

--- 反序列化（用于读档）
function QuestManager.OnLoad(save_data)
    if not save_data or type(save_data) ~= "table" then return end
    TheWorld._npc_quests = save_data
end

return QuestManager
