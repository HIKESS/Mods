require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/follow"
require "behaviours/chaseandattack"
require "behaviours/useshield"
local BrainCommon = require("brains/braincommon")

local START_FACE_DIST = 6 --6
local KEEP_FACE_DIST = 8 --8
local GO_HOME_DIST = 1 --1
local MAX_CHASE_TIME = 20 --20
local MAX_CHASE_DIST = 30 --30

local MIN_FOLLOW_DIST = 4
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 10

local SDFStone_Core_GolemBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)

    --Shields till fully healed
    UseShield.TimeToEmerge = function(self)
	if not self.inst.components.health:IsDead() and self.inst.components.health:GetPercent() >= 1 and (self.inst.prefab == "sdf_stone_golem_core") then
	    return true
	else
	    local t = GetTime()
	    return t - self.timelastattacked > self.shieldtime and t >= self.scareendtime
	end
    end

    UseShield.ShouldShield = function(self)
	if (self.inst.prefab == "sdf_stone_golem_armored" or self.inst.prefab == "sdf_asgard_golem") and self.projectileincoming then
	    if not self.inst:HasTag("sdf_stone_golem_shielded_projectile") then
		self.inst:AddTag("sdf_stone_golem_shielded_projectile")
	    end
	    return true
	end
	return not self.inst.components.health:IsDead() and self.inst._sdf_haunted_ruins_lava_pond_lavabathe_debufftask == nil
	    and (self.damagetaken > self.damageforshield
	    or (not self.dontshieldforfire and self.inst.components.health.takingfiredamage)
	    or self.projectileincoming
	    or GetTime() < self.scareendtime)
    end

    UseShield.Visit = function(self)
	local combat = self.inst.components.combat
    	local statename = self.inst.sg.currentstate.name

	if self.status == READY  then
	    if self:ShouldShield() or self.inst.sg:HasStateTag("shield") then

		--projectile shield
		if (self.inst.prefab == "sdf_stone_golem_armored") and self.inst:HasTag("sdf_stone_golem_shielded_projectile") then
		    self.projectileincoming = false

		--normal shield
		else
		    self.damagetaken = 0
		    self.projectileincoming = false
		end

		if self.dontupdatetimeonattack then
		    self.timelastattacked = GetTime()
		    if not self.inst.sg:HasStateTag("shield") then
			self.inst:PushEvent("entershield")
		    end
		else
		    self.inst:PushEvent("entershield")
		end

                self.status = RUNNING
	    else
		self.status = FAILED
	    end
	end

	if self.status == RUNNING then
	    if self.inst:HasTag("sdf_stone_golem_shielded_broken") then
		self.timelastattacked = self.shieldtime + 1
		self.inst:PushEvent("exitshield")
		self.status = SUCCESS
	    elseif (not self:TimeToEmerge() and not self.inst:HasTag("sdf_stone_golem_shielded_broken")) or (not self.dontshieldforfire and self.inst.components.health.takingfiredamage) then
		self.status = RUNNING
	    else
		self.inst:PushEvent("exitshield")
		self.status = SUCCESS
	    end
	end
    end
end)

local function GoHomeAction(inst)
    if inst.components.combat.target ~= nil then
        return
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, .2)
        or nil
end

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function ShouldGoHome(inst)
    if inst.components.follower ~= nil and inst.components.follower.leader ~= nil then
        return false
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil and inst:GetDistanceSqToPoint(homePos:Get()) > GO_HOME_DIST * GO_HOME_DIST
end

function SDFStone_Core_GolemBrain:OnStart()

    local root = PriorityNode(
    {
        ParallelNode{
            UseShield(self.inst, self.inst.damageUntilShield, self.inst.shieldTime, self.inst.avoidProjectileAttacks),
        },

        ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST)),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", true)),

        Follow(self.inst, function(inst) return inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        StandStill(self.inst),

    }, .25)

    self.bt = BT(self.inst, root)
end

return SDFStone_Core_GolemBrain