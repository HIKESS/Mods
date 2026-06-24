-- brains/npc_woby_brain.lua
-- NPC 沃尔特专用的轻量沃比脑子，和原版沃比系统分离。

require("behaviours/follow")
require("behaviours/wander")
require("behaviours/faceentity")

local NPC_TUNING = require("npc_tuning")

local NpcWobyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
end

local function GetLeaderPos(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader:GetPosition() or inst:GetPosition()
end

local function GetFaceLeader(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader:IsValid() and inst:IsNear(leader, 6) and leader or nil
end

local function KeepFaceLeader(inst, target)
    return target ~= nil and target:IsValid() and inst:IsNear(target, 10)
end

function NpcWobyBrain:OnStart()
    local root = PriorityNode({
        Follow(self.inst, function() return GetLeader(self.inst) end,
            NPC_TUNING.WALTER_NPC_WOBY_FOLLOW_MIN_DIST or 2,
            NPC_TUNING.WALTER_NPC_WOBY_FOLLOW_TARGET_DIST or 4,
            NPC_TUNING.WALTER_NPC_WOBY_FOLLOW_MAX_DIST or 8,
            true),
        FaceEntity(self.inst,
            function() return GetFaceLeader(self.inst) end,
            function(inst, target) return KeepFaceLeader(inst, target) end),
        Wander(self.inst, function() return GetLeaderPos(self.inst) end, 4),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return NpcWobyBrain
