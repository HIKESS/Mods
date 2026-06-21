require "behaviours/standstill"
require "behaviours/doaction"
require "behaviours/follow"
require "behaviours/chaseandattack"
require "behaviours/useshield"
local BrainCommon = require("brains/braincommon")

local START_FACE_DIST = 6 --0
local KEEP_FACE_DIST = 8 --12
local MIN_COMBAT_TARGET_DIST = 11
local MAX_COMBAT_TARGET_DIST = 14
local MIN_FOLLOW_DIST = 1
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 10
local TAUNT_DIST = 8

local SDFAsgard_GolemBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._targets = nil

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
	return not self.inst.components.health:IsDead() and self.inst._sdf_lava_pond_lavabathe_debufftask == nil
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

local function IsTauntable(inst, target)
    return target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
end

local SHADOWCREATURE_MUST_TAGS = { "hostile", "_combat", "locomotor" }
local SHADOWCREATURE_CANT_TAGS = { "INLIMBO", "notaunt" }
local function FindShadowCreatures(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TAUNT_DIST, SHADOWCREATURE_MUST_TAGS, SHADOWCREATURE_CANT_TAGS)
    for i = #ents, 1, -1 do
        if not IsTauntable(inst, ents[i]) then
            table.remove(ents, i)
        end
    end
    return #ents > 0 and ents or nil
end

local function TauntCreatures(self)
    local taunted = false
    if self._targets ~= nil then
        for i, v in ipairs(self._targets) do
            if IsTauntable(self.inst, v) then
                v.components.combat:SetTarget(self.inst)
                taunted = true
            end
        end
    end
    if taunted then
        self.inst.sg:GoToState("taunt")
    end
end

local function GetLeader(self)
    return self.inst.components.follower.leader
end

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

function SDFAsgard_GolemBrain:OnStart()

    local root = PriorityNode(
    {
        ParallelNode{
            UseShield(self.inst, self.inst.damageUntilShield, self.inst.shieldTime, self.inst.avoidProjectileAttacks),
        },

        --Get the attention of nearby sanity monsters.
        WhileNode(function()self._targets = not (self.inst.sg:HasStateTag("busy") or self.inst.components.timer:TimerExists("taunt_cd")) and FindShadowCreatures(self.inst) or nil return self._targets ~= nil end, "Can Taunt",
            ActionNode(function() TauntCreatures(self) end)),

        WhileNode(function() local target = self.inst.components.combat.target if target ~= nil and target:IsValid() then local leader = GetLeader(self) self._isincombat = leader == nil or leader:IsNear(target, self._isincombat and MAX_COMBAT_TARGET_DIST or MIN_COMBAT_TARGET_DIST) else self._isincombat = false end return self._isincombat end, "Combat",
            ChaseAndAttack(self.inst, nil, nil, nil, nil, true)),

        Follow(self.inst, function(inst) return inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        StandStill(self.inst),

    }, .25)

    self.bt = BT(self.inst, root)
end

return SDFAsgard_GolemBrain