-- scripts/brains/npc_bernie_brain.lua
-- NPC 薇洛专属伯尼的简易大脑
-- 行为优先级：跟随主人 → 在主人附近漫游

require("behaviours/follow")
require("behaviours/wander")

local NpcBernieBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function NpcBernieBrain:OnStart()
    local inst = self.inst

    local function GetLeader()
        return inst._npc_leader
    end

    local function GetLeaderPos()
        local leader = GetLeader()
        return leader ~= nil and leader:IsValid() and leader:GetPosition() or nil
    end

    local root = PriorityNode({
        
        Follow(inst, GetLeader, 2, 5, 8),
        
        Wander(inst, GetLeaderPos, 6),
    }, .25)

    self.bt = BT(inst, root)
end

return NpcBernieBrain
