-- brains/npc_bernie_big_brain.lua
-- NPC 大伯尼专用 AI 大脑
-- 简化版：移除对 AllPlayers/sanity/skilltree 的依赖
-- 优先级：脱战缩小 → 战斗 → 跟随薇洛 → 朝向 → 漫游

require("behaviours/chaseandattack")
require("behaviours/follow")
require("behaviours/faceentity")
require("behaviours/wander")

local NpcBernieBigBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)





local MIN_ACTIVE_TIME = 4  

local function ShouldDeactivate(inst)
    if inst.sg and inst.sg:HasStateTag("busy") then
        return false
    end

    local leader = inst._npc_leader

    if not leader or not leader:IsValid() or leader._is_ghost_mode then
        return inst:GetTimeAlive() >= MIN_ACTIVE_TIME
    end

    if leader.components.combat and leader.components.combat.target then
        return false
    end

    local deactivate_delay = NPC_TUNING.BERNIE_DEACTIVATE_DELAY or 16
    local t = GetTime()
    if inst.components.combat then
        if inst.components.combat:GetLastAttackedTime() + deactivate_delay >= t then
            return false
        end
        if (inst.components.combat.lastdoattacktime or 0) + deactivate_delay >= t then
            return false
        end
    end

    return inst:GetTimeAlive() >= MIN_ACTIVE_TIME
end





function NpcBernieBigBrain:OnStart()
    local inst = self.inst

    local function GetLeader()
        return inst._npc_leader
    end

    local root = PriorityNode({
        
        IfNode(function() return ShouldDeactivate(inst) end, "Deactivate",
            ActionNode(function() inst.sg:GoToState("deactivate") end)),

        
        WhileNode(
            function()
                local target = inst.components.combat and inst.components.combat.target
                return target ~= nil and target:IsValid()
            end,
            "Combat",
            ChaseAndAttack(inst, nil, nil, nil, nil, true)),

        
        Follow(inst, GetLeader, 2, 5, 8),

        
        FaceEntity(inst, GetLeader, function(inst, leader)
            return leader:IsValid()
        end),

        
        Wander(inst),
    }, .2)

    self.bt = BT(inst, root)
end

return NpcBernieBigBrain
