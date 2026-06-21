require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/standstill"
require "behaviours/leash"
require "behaviours/runaway"

local MIN_BUDDY_DIST = 0
local TARGET_BUDDY_DIST = 4
local MAX_BUDDY_DIST = 18

local BrainCommon = require("brains/braincommon")

local GWShadowBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 8

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 8

local KEEP_WORKING_DIST = 14
local SEE_WORK_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local AVOID_EXPLOSIVE_DIST = 5

local DIG_TAGS = { "stump", "grave", "farm_debris" }

local WANDER_TIMING = {minwaittime = 6, randwaittime = 6}

local function Unignore(inst, sometarget, ignorethese)
    ignorethese[sometarget] = nil
end

local function IgnoreThis(sometarget, ignorethese, leader, worker)
    if ignorethese[sometarget] ~= nil and ignorethese[sometarget].task ~= nil then
        ignorethese[sometarget].task:Cancel()
        ignorethese[sometarget].task = nil
    else
        ignorethese[sometarget] = {worker = worker,}
    end
    ignorethese[sometarget].task = leader:DoTaskInTime(5, Unignore, sometarget, ignorethese)
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function GetFaceLeaderFn(inst)
	local target = GetLeader(inst)
	return target ~= nil and target.entity:IsVisible() and inst:IsNear(target, START_FACE_DIST) and target or nil
end

local function KeepFaceLeaderFn(inst, target)
	return target.entity:IsVisible() and inst:IsNear(target, KEEP_FACE_DIST)
end

local function IsNearLeader(inst, dist)
    local leader = GetLeader(inst)
    return leader ~= nil and inst:IsNear(leader, dist)
end

local TOWORK_CANT_TAGS = { "fire", "smolder", "event_trigger", "waxedplant", "INLIMBO", "NOCLICK", "carnivalgame_part" }
local function FindEntityToWorkAction(inst, action, addtltags) -- DEPRECATED, use FindAnyEntityToWorkActionsOn.
    local leader = GetLeader(inst)
    if leader ~= nil then
        --Keep existing target?
        local target = inst.sg.statemem.target
        if target ~= nil and
            target:IsValid() and
            not (target:IsInLimbo() or
                target:HasTag("NOCLICK") or
                target:HasTag("event_trigger")) and
            target:IsOnValidGround() and
            target.components.workable ~= nil and
            target.components.workable:CanBeWorked() and
            target.components.workable:GetWorkAction() == action and
            not (target.components.burnable ~= nil
                and (target.components.burnable:IsBurning() or
                    target.components.burnable:IsSmoldering())) and
            target.entity:IsVisible() and
            target:IsNear(leader, KEEP_WORKING_DIST) then

            if addtltags ~= nil then
                for i, v in ipairs(addtltags) do
                    if target:HasTag(v) then
                        return BufferedAction(inst, target, action)
                    end
                end
            else
                return BufferedAction(inst, target, action)
            end
        end

        --Find new target
        target = FindEntity(leader, SEE_WORK_DIST, nil, { action.id.."_workable" }, TOWORK_CANT_TAGS, addtltags)
        return target ~= nil and BufferedAction(inst, target, action) or nil
    end
end

local ANY_TOWORK_ACTIONS = {ACTIONS.CHOP, ACTIONS.MINE, ACTIONS.DIG}
local ANY_TOWORK_MUSTONE_TAGS = {"CHOP_workable", "MINE_workable", "DIG_workable"}
local function PickValidActionFrom(target)
    if target.components.workable == nil then
        return nil
    end

    local desiredact = target.components.workable:GetWorkAction()
    for _, act in ipairs(ANY_TOWORK_ACTIONS) do
        if desiredact == act then
            return act
        end
    end
    return nil
end

local function FilterAnyWorkableTargets(targets, ignorethese, leader, worker)
    for _, sometarget in ipairs(targets) do
        if ignorethese[sometarget] ~= nil and ignorethese[sometarget].worker ~= worker then
            -- Ignore me!
        elseif sometarget.components.burnable == nil or (not sometarget.components.burnable:IsBurning() and not sometarget.components.burnable:IsSmoldering()) then
            if sometarget:HasTag("DIG_workable") then
                for _, tag in ipairs(DIG_TAGS) do
                    if sometarget:HasTag(tag) then
                        if sometarget.components.workable:GetWorkLeft() == 1 then
                            IgnoreThis(sometarget, ignorethese, leader, worker)
                        end
                        return sometarget
                    end
                end
            else -- CHOP_workable and MINE_workable has no special cases to handle.
                if sometarget.components.workable:GetWorkLeft() == 1 then
                    IgnoreThis(sometarget, ignorethese, leader, worker)
                end
                return sometarget
            end
        end
    end
    return nil
end

local function GetLeaderPoint(inst)
    local leader = GetLeader(inst)
    if leader == nil then return nil end 
    local x,y,z = leader.Transform:GetWorldPosition()
	return leader ~= nil and Vector3(x,0,z) or nil
end

local function FindAnyEntityToWorkActionsOn(inst, ignorethese) -- This is similar to FindEntityToWorkAction, but to be very mod safe FindEntityToWorkAction has been deprecated.
	if inst.sg:HasStateTag("busy") then
		return nil
	end
    local leader = GetLeader(inst)
    if leader == nil then -- There is no purpose for a puppet without strings attached.
        return nil
    end

    local target = inst.sg.statemem.target
    local action = nil
    if target ~= nil and target:IsValid() and not (target:IsInLimbo() or target:HasTag("NOCLICK") or target:HasTag("event_trigger") or target:HasTag("waxedplant")) and
        target:IsOnValidGround() and target.components.workable ~= nil and target.components.workable:CanBeWorked() and
        not (target.components.burnable ~= nil and (target.components.burnable:IsBurning() or target.components.burnable:IsSmoldering())) and
        target.entity:IsVisible() then
        -- Check if action is the one desired still.
        action = PickValidActionFrom(target)

        if action ~= nil and ignorethese[target] == nil then
            if target.components.workable:GetWorkLeft() == 1 then
                IgnoreThis(target, ignorethese, leader, inst)
            end
            return BufferedAction(inst, target, action)
        end
    end
    -- 'target' is invalid at this point, find a new one.

    local spawn = GetLeaderPoint(inst)
    if spawn == nil then
        return nil
    end

    local px, py, pz = inst.Transform:GetWorldPosition()
    local target = FilterAnyWorkableTargets(TheSim:FindEntities(px, py, pz, TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS), ignorethese, leader, inst)
    if target ~= nil then
        local maxdist = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS + TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL
        local dx, dz = px - spawn.x, pz - spawn.z
        if dx * dx + dz * dz > maxdist * maxdist then
            target = nil
        end
    end
    if target == nil then
        target = FilterAnyWorkableTargets(TheSim:FindEntities(spawn.x, spawn.y, spawn.z, TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS), ignorethese, leader, inst)
    end
    action = target ~= nil and PickValidActionFrom(target) or nil
    return action ~= nil and BufferedAction(inst, target, action) or nil
end

local function ShouldAvoidExplosive(target)
    return target.components.explosive == nil
        or target.components.burnable == nil
        or target.components.burnable:IsBurning()
end

local function ShouldRunAway(target, inst)
	if target.components.health ~= nil and target.components.health:IsDead() then
		return false
	elseif target:HasAnyTag("shadowcreature", "nightmarecreature") then
		if target.HostileToPlayerTest ~= nil then
			local leader = GetLeader(inst)
			return leader ~= nil and target:HostileToPlayerTest(leader)
		end
		return false
	elseif target:HasTag("stalker") then
		return target.atriumstalker
			or (target.canfight and target.components.combat ~= nil and target.components.combat:HasTarget())
	end
	return true
end

function GWShadowBrain:OnStart()
    local avoid_explosions = RunAway(self.inst, { fn = ShouldAvoidExplosive, tags = { "explosive" }, notags = { "INLIMBO" } }, AVOID_EXPLOSIVE_DIST, AVOID_EXPLOSIVE_DIST)
    local avoid_danger = RunAway(self.inst, { fn = ShouldRunAway, oneoftags = { "monster", "hostile" }, notags = { "player", "INLIMBO", "companion", "spiderden" } }, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)

    local face_player = WhileNode(function() return GetLeader(self.inst) ~= nil end, "Face Player",
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn))

    local face_leader = FaceEntity(self.inst, GetFaceLeaderFn, KeepFaceLeaderFn)

    local leader = GetLeader(self.inst)
    local ignorethese = nil
    if leader ~= nil then
        ignorethese = leader._brain_pickup_ignorethese or {}
        leader._brain_pickup_ignorethese = ignorethese
    end

    local function ShouldPickup() return not self.inst.sg:HasStateTag("phasing") end
    local function ShouldDeliver() return GetLeader(self.inst) ~= nil end

    local pickupparams = {
        cond = ShouldPickup,
        range = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS,
        range_local = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL,
        give_cond = ShouldDeliver,
        give_range = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS,
        furthestfirst = false,
        positionoverride = GetLeaderPoint,
        ignorethese = ignorethese,
        wholestacks = true,
        allowpickables = true,
    }

    local root = PriorityNode({
        avoid_explosions,
        avoid_danger,
        
        Follow(self.inst, function()
            return self.inst.components.follower and self.inst.components.follower.leader or nil
        end, MIN_BUDDY_DIST, TARGET_BUDDY_DIST, MAX_BUDDY_DIST, true),
        
		WhileNode(
			function()
				return not (self.inst.sg:HasStateTag("phasing") or
							self.inst.sg:HasStateTag("recoil"))
			end,
			"<busy state guard>",
			PriorityNode({
				WhileNode(
					function()
						self.keepworking = false
						return self.inst.shouldwork
					end,
					"Keep Working",
					DoAction(self.inst, function()
						local act = FindAnyEntityToWorkActionsOn(self.inst, pickupparams.ignorethese)
						if act then
							if self.inst.sg:HasStateTag("pre"..string.lower(act.action.id)) then
								self.keepworking = true
							else
								return act
							end
						end
					end)),
				
				FailIfSuccessDecorator(ConditionWaitNode(
					function() return not self.keepworking end, "Repeating action")),

				BrainCommon.NodeAssistLeaderPickUps(self, pickupparams),

				face_leader,

                face_player,

                Wander(self.inst, GetLeaderPoint, MAX_BUDDY_DIST, WANDER_TIMING),
			}, 0.25)),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

function GWShadowBrain:OnInitializationComplete()
	if self.inst.SaveSpawnPoint ~= nil then
		self.inst:SaveSpawnPoint(true)
	end
end

return GWShadowBrain