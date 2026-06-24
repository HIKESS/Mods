-- npc_shadow_protector_brain.lua
-- NPC 暗影保护者的行为树（必须继承自 Brain 类）
-- 行为优先级：追击攻击 → 卡住绕行 → 跟随 → 朝向 → 漫游

require("behaviours/chaseandattack")
require("behaviours/follow")
require("behaviours/wander")
require("behaviours/leash")
require("behaviours/faceentity")
require("behaviours/npc_stuck_recovery")  

local NPC_TUNING = require("npc_tuning")

local NpcShadowProtectorBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)





local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower:GetLeader()
end

local function GetLeaderPos(inst)
    local leader = GetLeader(inst)
    if leader then
        return leader:GetPosition()
    end
    return inst:GetPosition()
end

local function GetFaceLeaderFn(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader.entity:IsVisible() and inst:IsNear(leader, 6) and leader or nil
end

local function KeepFaceLeaderFn(inst, target)
    return target.entity:IsVisible() and inst:IsNear(target, 10)
end





function NpcShadowProtectorBrain:OnStart()
    local MAX_FOLLOW_DIST = NPC_TUNING.SHADOW_PROTECTOR_LEASH or 12
    
    local root = PriorityNode({
        
        ChaseAndAttack(self.inst, 20, 25),
        
        NPCStuckRecovery(self.inst),
        Follow(self.inst, function() return GetLeader(self.inst) end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, true),
        
        FaceEntity(self.inst, function() return GetFaceLeaderFn(self.inst) end, function(inst, target) return KeepFaceLeaderFn(inst, target) end),
        
        Wander(self.inst, function() return GetLeaderPos(self.inst) end, 6),
    }, 0.25)
    
    self.bt = BT(self.inst, root)
end

return NpcShadowProtectorBrain
