-- npc_shadow_worker_brain.lua
-- NPC 暗影工人的行为树（通用工人：砍树/挖矿/挖掘）
-- 行为优先级：工作 → 卡住绕行 → 跟随主人 → 朝向主人 → 漫游

require("behaviours/follow")
require("behaviours/wander")
require("behaviours/faceentity")
require("behaviours/npc_stuck_recovery")

local NPC_TUNING = require("npc_tuning")

local NpcShadowWorkerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)




local MIN_FOLLOW_DIST  = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST  = 12
local SEE_WORK_DIST    = NPC_TUNING.SHADOW_WORKER_SEE_DIST or 12   
local KEEP_WORKING_DIST = NPC_TUNING.SHADOW_WORKER_KEEP_DIST or 16  

local TOWORK_CANT_TAGS = { "fire", "smolder", "event_trigger", "waxedplant", "INLIMBO", "NOCLICK", "carnivalgame_part" }
local TOWORK_MUSTONE_TAGS = { "CHOP_workable", "MINE_workable", "DIG_workable" }
local DIG_TAGS = { "stump", "grave", "farm_debris" }

-- 不同工作动作对应的手持工具贴图
local TOOL_SWAP_BY_ACTION = {
    [ACTIONS.MINE] = "swap_pickaxe",
    [ACTIONS.CHOP] = "swap_axe",
    [ACTIONS.DIG]  = "swap_shovel",
}

local function SetWorkerTool(inst, action)
    local swap = TOOL_SWAP_BY_ACTION[action]
    if swap == nil or inst._worker_cur_tool == swap then
        return
    end
    inst._worker_cur_tool = swap
    inst.AnimState:OverrideSymbol("swap_object", swap, swap)
end




local function GetLeader(inst)
    return inst.components.follower and inst.components.follower:GetLeader()
end

local function GetLeaderPos(inst)
    local leader = GetLeader(inst)
    if leader then return leader:GetPosition() end
    return inst:GetPosition()
end

local function GetFaceLeaderFn(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader.entity:IsVisible() and inst:IsNear(leader, 6) and leader or nil
end

local function KeepFaceLeaderFn(inst, target)
    return target.entity:IsVisible() and inst:IsNear(target, 10)
end




local function IsValidWorkTarget(target)
    local workable = target.components.workable
    if workable == nil or not workable:CanBeWorked() then
        return false
    end
    local burnable = target.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return false
    end
    local action = workable:GetWorkAction()
    if action == ACTIONS.CHOP or action == ACTIONS.MINE then
        return true
    end
    if action == ACTIONS.DIG then
        local dig_grave = NPC_TUNING.SHADOW_WORKER_DIG_GRAVE ~= false
        for _, tag in ipairs(DIG_TAGS) do
            if target:HasTag(tag) and (tag ~= "grave" or dig_grave) then
                return true
            end
        end
    end
    return false
end

local function FindWorkTarget(inst)
    local leader = GetLeader(inst)
    if leader == nil then return nil end

    local target = FindEntity(leader, SEE_WORK_DIST, IsValidWorkTarget,
        nil, TOWORK_CANT_TAGS, TOWORK_MUSTONE_TAGS)

    if target ~= nil then
        local action = target.components.workable:GetWorkAction()
        SetWorkerTool(inst, action)
        return BufferedAction(inst, target, action)
    end
    return nil
end

local function ShouldKeepWorking(inst)
    local leader = GetLeader(inst)
    if leader == nil then return false end
    return inst:IsNear(leader, KEEP_WORKING_DIST)
end




function NpcShadowWorkerBrain:OnStart()
    local root = PriorityNode({
        
        WhileNode(
            function() return ShouldKeepWorking(self.inst) end,
            "DoWork",
            LoopNode{
                DoAction(self.inst, function() return FindWorkTarget(self.inst) end, "work", true),
            }
        ),
        
        NPCStuckRecovery(self.inst),
        
        Follow(self.inst, function() return GetLeader(self.inst) end,
            MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, true),
        
        FaceEntity(self.inst,
            function() return GetFaceLeaderFn(self.inst) end,
            function(inst, target) return KeepFaceLeaderFn(inst, target) end),
        
        Wander(self.inst, function() return GetLeaderPos(self.inst) end, 6),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return NpcShadowWorkerBrain
