require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/follow"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/chaseandattack"

local SDFGallowmere_KnightBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MIN_FOLLOW_DIST = 1 --0.00001
local TARGET_FOLLOW_DIST = 5 --4
local MAX_FOLLOW_DIST = 6 --6

local START_FACE_DIST = 4 --6
local KEEP_FACE_DIST = 6 --8

local KEEP_LEADER_NEAR_DIST = 30

local function HasStateTags(inst, tags)
    for k,v in pairs(tags) do
        if inst.sg:HasStateTag(v) then
            return true
        end
    end
end

local function PlayerClose(inst)
    local player = GetClosestInstWithTag("player",inst,6)
    if player then
	return true
    else
	return false
    end
end

local function isPlayerNear(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_LEADER_NEAR_DIST*KEEP_LEADER_NEAR_DIST
end

local function KeepLookingAction(inst)
    return isPlayerNear(inst)
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetFaceTargetBlockFn(inst)
    return inst.components.combat.target
end

local function KeepFaceTargetBlockFn(inst, target)
    return inst.components.combat.target == target
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function GetStayPos(inst)
    return inst.components.sdf_gallowmere_knight_command.locations["currentstaylocation"]
end

local function GetWanderPoint(inst)
    if inst.components.sdf_gallowmere_knight_command and inst.components.sdf_gallowmere_knight_command:IsCurrentlyStaying() then
	return GetStayPos(inst)
    else
	local target = GetLeader(inst) or GetPlayer()
	if target then
	    return target:GetPosition()
	end
    end
end

local function ShouldGoHome(inst)
    local homePos = inst.components.sdf_gallowmere_knight_command.locations["currentstaylocation"]
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) > 5*5)
end

local function GoHomeAction(inst)
    local homePos = inst.components.sdf_gallowmere_knight_command.locations["currentstaylocation"]
    if homePos then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, 0.2)
    end
end


function SDFGallowmere_KnightBrain:OnStart()
    local root = PriorityNode(
    {	
	WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
	    ChaseAndAttack(self.inst, 12, 15)),	
	
	WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",

	FaceEntity(self.inst, GetFaceTargetBlockFn, KeepFaceTargetBlockFn )),

	IfNode(function() 
	    if self.inst.components.follower.leader ~= nil and self.inst.components.sdf_gallowmere_knight_command and self.inst.components.sdf_gallowmere_knight_command:IsCurrentlyStaying() == false then
		return true
	    elseif self.inst.components.follower.leader ~= nil and not self.inst.components.sdf_gallowmere_knight_command then
		return true
	    end
	end, "has leader",

	Follow(self.inst, GetLeader, 1, 4, 7)),		
	IfNode(function() 
	    if self.inst.components.sdf_gallowmere_knight_command and self.inst.components.sdf_gallowmere_knight_command:IsCurrentlyStaying() == true then
		return true
	    end
	end, "has leader",

	WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
	    DoAction(self.inst, GoHomeAction, "Go Home", true ))),  
	IfNode(function() return self.inst.components.follower.leader ~= nil end, "has leader",
	    FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),
    }, 1)
    self.bt = BT(self.inst, root)    
end

return SDFGallowmere_KnightBrain