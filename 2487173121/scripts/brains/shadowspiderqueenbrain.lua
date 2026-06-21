require "behaviours/wander"
require "behaviours/follow"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/faceentity"
require "behaviours/leash"
local ShadowSpiderQueenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)
local MAX_CHASE_TIME = 20
local MAX_CHASE_DIST = 30
local RUN_AWAY_DIST = 4
local STOP_RUN_AWAY_DIST = 6
local MIN_FOLLOW_DIST = 4
local TARGET_FOLLOW_DIST = 8
local MAX_FOLLOW_DIST = 14
local LEASH_DIST = 20
local MAX_WANDER_DIST = 8
local WANDER_OFFSET = 6
local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end
local function GetLeaderPos(inst)
    local leader = GetLeader(inst)
    if leader and leader:IsValid() then
        return leader:GetPosition()
    end
    return inst:GetPosition()
end
local function GetWanderPos(inst)
    local leader = GetLeader(inst)
    if leader and leader:IsValid() then
        local lx, ly, lz = leader.Transform:GetWorldPosition()
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local dx = ix - lx
        local dz = iz - lz
        local angle = math.atan2(dz, dx)
        local dist = math.sqrt(dx * dx + dz * dz)
        if dist < 2 then
            angle = math.random() * 2 * math.pi
        end
        return Vector3(lx + math.cos(angle) * WANDER_OFFSET, 0, lz + math.sin(angle) * WANDER_OFFSET)
    end
    return inst:GetPosition()
end
local function GetFaceTargetFn(inst)
    return GetLeader(inst)
end
local function KeepFaceTargetFn(inst, target)
    return target and target:IsValid() and inst:IsNear(target, 10)
end
local function IsTooFarFromLeader(inst)
    local leader = GetLeader(inst)
    if leader and leader:IsValid() then
        return inst:GetDistanceSqToInst(leader) > LEASH_DIST * LEASH_DIST
    end
    return false
end
function ShadowSpiderQueenBrain:OnStart()
    local root = PriorityNode({
        WhileNode(function()
            return self.inst.components.combat.target ~= nil
        end, "HasTarget",
            PriorityNode({
                WhileNode(function()
                    return not self.inst.components.combat:InCooldown()
                end, "Attack",
                    ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
                RunAway(self.inst, function() return self.inst.components.combat.target end,
                    RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
            }, 0.1)),
        WhileNode(function() return IsTooFarFromLeader(self.inst) end, "Leash",
            Leash(self.inst, GetLeaderPos, LEASH_DIST, LEASH_DIST - 2, true)),
        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetWanderPos, MAX_WANDER_DIST),
    }, 0.25)
    self.bt = BT(self.inst, root)
end
return ShadowSpiderQueenBrain
