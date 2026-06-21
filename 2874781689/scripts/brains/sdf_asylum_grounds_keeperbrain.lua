require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local BrainCommon = require "brains/braincommon"

local SEE_PLAYER_DIST     = 2 --2
local MAX_WANDER_DIST     = 12 --12
local MAX_CHASE_TIME      = 8 --8
local MAX_CHASE_DIST      = 8 --8
local RUN_AWAY_DIST       = 1 --1
local STOP_RUN_AWAY_DIST  = 2 --2

local FACETIME_BASE       = 2
local FACETIME_RAND       = 2

local AsylumGroundsKeeperBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    if inst.components.timer:TimerExists("dontfacetime") then
        return nil
    end
    local shouldface = FindClosestPlayerToInst(inst, SEE_PLAYER_DIST, true)
    if shouldface and not inst.components.timer:TimerExists("facetime") then
        inst.components.timer:StartTimer("facetime", FACETIME_BASE + math.random()*FACETIME_RAND)
    end
    return shouldface
end

local function KeepFaceTargetFn(inst, target)
    if inst.components.timer:TimerExists("dontfacetime") then
        return nil
    end
    local keepface = (target:IsValid() and inst:IsNear(target, SEE_PLAYER_DIST))
    if not keepface then
        inst.components.timer:StopTimer("facetime")
    end
    return keepface
end

-----------------------------------------------------------------------------------------------
local function GoHomeAction(inst)
    if inst.components.combat.target ~= nil then
        return
    end
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home ~= nil
        and home:IsValid()
        and BufferedAction(inst, home, ACTIONS.GOHOME)
        or nil
end

local function ShouldGoHome(inst)
    if not TheWorld.state.isday then
        return false
    end

    --one merm should stay outside
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home == nil
        or home.components.childspawner == nil
        or home.components.childspawner:CountChildrenOutside() > 1
end

local function GetNoLeaderHomePos(inst)
    return inst.components.knownlocations:GetLocation("home")
end

function AsylumGroundsKeeperBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
            ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST))),
        WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),

        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", true)),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST),
    }, .25)

    self.bt = BT(self.inst, root)
end

return AsylumGroundsKeeperBrain
