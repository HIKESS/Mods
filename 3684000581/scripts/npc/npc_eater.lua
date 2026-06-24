-- scripts/npc/npc_eater.lua
-- NPC 喂食系统：玩家右键拿食物点击 NPC → 恢复血量 / 招募
-- 使用 eater 组件 + handfed/fedbyall 标签，走 ACTIONS.FEED 路径

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")
local npc_utils  = require("npc/npc_utils")
local npc_affinity = require("npc/npc_affinity")

local UpdateHoverInfo = npc_utils.UpdateHoverInfo

local npc_eater = {}

local function ShouldHaveFeedTags(inst)
    if not inst or not inst:IsValid() then return false end
    if inst:HasTag("npc_hostile") then return false end
    return true
end

local function RepairStaleGhostFlagIfNeeded(inst)
    if not inst or not inst._is_ghost_mode then
        return
    end
    local invincible = inst.components
        and inst.components.health
        and inst.components.health.invincible == true
    if not inst:HasTag("ghost") and not inst:HasTag("noattack") and not invincible then
        -- 运行时时序异常自愈：视觉和战斗都已是活体，但幽灵标记位残留
        inst._is_ghost_mode = false
    end
end

local function EnsureFeedTags(inst)
    if not ShouldHaveFeedTags(inst) then return end
    if inst._is_ghost_mode then return end
    if inst.components and inst.components.health and inst.components.health:IsDead() then return end
    if not inst:HasTag("handfed") then inst:AddTag("handfed") end
    if not inst:HasTag("fedbyall") then inst:AddTag("fedbyall") end
    if not inst:HasTag("OMNI_eater") then inst:AddTag("OMNI_eater") end
end

function npc_eater.SetupEater(inst)
    if FOODTYPE.NPCFRIENDS_ONLY == nil then
        FOODTYPE.NPCFRIENDS_ONLY = "NPCFRIENDS_ONLY"
    end

    inst:AddComponent("eater")
    -- 统一允许常规食物，避免右键喂食在不同食物类型下被误拒绝
    if inst.components.eater then
        local diet = { FOODGROUP.OMNI, FOODTYPE.NPCFRIENDS_ONLY }
        inst.components.eater:SetDiet(diet, diet)
        inst.components.eater:SetCanEatRawMeat(true)
        inst.components.eater:SetCanEatHorrible(true)
        inst.components.eater:SetStrongStomach(true)
    end

    -- 阿比盖尔 / 灵魂 / 死亡 / 跟随上限 拒绝一切食物（包装 Eat，优先级最高）
    local _orig_eat_base = inst.components.eater.Eat
    inst.components.eater.Eat = function(self, food, feeder)
        RepairStaleGhostFlagIfNeeded(inst)
        EnsureFeedTags(inst)
        if inst:HasTag("npc_hostile") then
            return nil
        end
        if food and food:HasTag("npc_growth_food") then
            if feeder == nil or feeder == inst or not feeder:HasTag("player") then
                return nil
            end
        end

        if food and inst.npc_character_type == "wanda" and food.prefab == "npc_heart" then
            if inst.components.talker and NPC_SPEECH.WANDA_REFUSE_HEART then
                local line = NPC_SPEECH.GetLine(NPC_SPEECH.WANDA_REFUSE_HEART, inst.npc_character_type)
                if line then
                    inst.components.talker:Say(line)
                end
            end
            if inst.sg and not inst._is_ghost_mode then
                inst.sg:GoToState("refuseeat")
            end
            return nil
        end
        -- 灵魂模式：不可进食
        if inst._is_ghost_mode then
            return nil
        end
        -- 死亡瞬间
        if inst.components.health and inst.components.health:IsDead() then
            return nil
        end
        -- 只吃正向收益的食物：拒绝腐烂/有害（负血）或无收益（血与饱食都 <= 0）的食物。
        if food and food.components and food.components.edible
           and not food:HasTag("npc_growth_food") then
            local health_gain, hunger_gain = 0, 0
            local ok = pcall(function()
                health_gain = food.components.edible:GetHealth(inst) or 0
                hunger_gain = food.components.edible:GetHunger(inst) or 0
            end)
            if ok and (health_gain < 0 or (health_gain <= 0 and hunger_gain <= 0)) then
                if inst.components.talker and NPC_SPEECH.REFUSE_FOOD then
                    local lines = NPC_SPEECH.REFUSE_FOOD
                    inst.components.talker:Say(lines[math.random(#lines)])
                end
                if inst.sg and inst.sg:HasStateTag("idle") and not inst._is_ghost_mode then
                    inst.sg:GoToState("refuseeat")
                end
                return nil
            end
        end
        -- 跟随上限：无领队 + 喂食者是玩家 + 玩家已满员 → 拒绝进食
        local has_leader = inst.components.follower and inst.components.follower.leader ~= nil
        local owned_by_feeder = feeder and feeder.userid and inst._owner_userid == feeder.userid
        if feeder and feeder:HasTag("player")
           and not has_leader
           and not owned_by_feeder then
            local max_followers = NPC_TUNING.MAX_NPC_FOLLOWERS or 1
            local cur_count = 0
            if feeder.components.leader then
                cur_count = feeder.components.leader:CountFollowers("npcfriend")
            end
            if cur_count >= max_followers then
                if inst.components.talker and NPC_SPEECH.RECRUIT_FULL then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.RECRUIT_FULL, inst.npc_character_type)
                    if line then inst.components.talker:Say(line) end
                end
                if inst.sg and inst.sg:HasStateTag("idle") and not inst._is_ghost_mode then
                    inst.sg:GoToState("refuseeat")
                end
                return nil
            end
        end
        return _orig_eat_base(self, food, feeder)
    end

    -- 定期自愈喂食标签（仅可喂食角色）；防止死亡/复活后偶发状态漂移
    EnsureFeedTags(inst)
    if inst._npc_feedtag_sync_task then
        inst._npc_feedtag_sync_task:Cancel()
        inst._npc_feedtag_sync_task = nil
    end
    inst._npc_feedtag_sync_task = inst:DoPeriodicTask(1, function(i)
        RepairStaleGhostFlagIfNeeded(i)
        EnsureFeedTags(i)
    end)
    inst:ListenForEvent("onremove", function(i)
        if i._npc_feedtag_sync_task then
            i._npc_feedtag_sync_task:Cancel()
            i._npc_feedtag_sync_task = nil
        end
    end)

    -- oneat 回调：说台词 + 播放吃东西动画 + 喂食招募
    inst.components.eater:SetOnEatFn(function(i, food, feeder)
        if feeder and feeder ~= i and feeder:HasTag("player")
           and not (food and food:HasTag("npc_growth_food")) then
            local gain = npc_affinity.GetFoodGain(i.npc_character_type, food and food.prefab, food)
            if gain ~= 0 then
                npc_affinity.AddAffinity(i, gain)
            end
        end

        -- 喂食招募：无领队 + 喂食者是玩家 → 设为永久跟随
        if feeder and feeder:HasTag("player")
           and not (i.components.follower and i.components.follower.leader) then
            if feeder.components.leader == nil then
                feeder:AddComponent("leader")
            end
            i.components.follower:SetLeader(feeder)
            i._owner_userid = feeder.userid
            if i.owner_userid then
                i.owner_userid:set(feeder.userid or "")
            end
            if i.components.talker then
                i.components.talker:ShutUp()
                if NPC_SPEECH.RECRUIT then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.RECRUIT, i.npc_character_type)
                    if line then i.components.talker:Say(line) end
                end
            end
            if i.sg and i.sg:HasStateTag("idle") and not i._is_ghost_mode then
                i.sg:GoToState("eat")
            end
            UpdateHoverInfo(i)
            return
        end

        -- 自己吃（HealAndRetreat 撤退吃饺子）时不说台词
        if feeder == i then
            if i.sg and i.sg:HasStateTag("idle") and not i._is_ghost_mode then
                i.sg:GoToState("eat")
            end
            UpdateHoverInfo(i)
            return
        end

        if i.components.talker and NPC_SPEECH.EAT then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.EAT, i.npc_character_type)
            if line then i.components.talker:Say(line) end
        end
        if i.sg and i.sg:HasStateTag("idle") and not i._is_ghost_mode then
            i.sg:GoToState("eat")
        end
        UpdateHoverInfo(i)
    end)
end

return npc_eater
