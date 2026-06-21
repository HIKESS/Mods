require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"

local BrainCommon = require("brains/braincommon")

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5

local AVOID_PLAYER_DIST = 0
local AVOID_PLAYER_STOP = 2

local SEE_BAIT_DIST = 7
local MAX_WANDER_DIST = 10

local SDFJack_Of_The_Green_Riddle_MolewormBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function IsMoleBait(item)
    return item:HasTag("sdf_jack_of_the_green_riddle_molebait")
end

local function SelectedTargetTimeout(target)
    target.selectedasmoletarget = nil
end

local TAKEBAIT_MUST_TAGS = { "sdf_jack_of_the_green_riddle_molebait" }
local TAKEBAIT_CANT_TAGS = { "outofreach", "INLIMBO", "fire" }

local function TakeBaitAction(inst)
    -- Don't look for bait if just spawned, busy making a new home, or has full inventory
    if inst.sg:HasStateTag("busy") or (inst.components.inventory and inst.components.inventory:IsFull()) then
        return --inst:GetTimeAlive() < 3 or ShouldMakeHome(inst) or
    end

    local target = FindEntity(inst, SEE_BAIT_DIST, IsMoleBait, TAKEBAIT_MUST_TAGS, TAKEBAIT_CANT_TAGS)
    if target ~= nil and not target.selectedasmoletarget and target:IsOnValidGround() then
        target.selectedasmoletarget = true
        target:DoTaskInTime(5, SelectedTargetTimeout)
        local act = BufferedAction(inst, target, ACTIONS.PICKUP) --ACTIONS.STEALMOLEBAIT)
        act.validfn = function()
            return not (target.components.inventoryitem ~= nil and target.components.inventoryitem:IsHeld())
                and not (target.components.burnable ~= nil and target.components.burnable:IsBurning())
        end

        return act
    end
end

local function PeekAction(inst)
    return BufferedAction(inst, nil, ACTIONS.MOLEPEEK)
end

function SDFJack_Of_The_Green_Riddle_MolewormBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        WhileNode(function() return self.inst.flee == true end, "Flee",
            RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP)),
        WhileNode(function() return (GetTime() > (self.inst.last_above_time + self.inst.peek_interval) and not self.inst.sg:HasStateTag("busy")) end, "Peek", --check if no buffered action?
            DoAction(self.inst, PeekAction, "peek", false)),
        DoAction(self.inst, TakeBaitAction, "take bait", false),
    }, .25)
    self.bt = BT(self.inst, root)
end

return SDFJack_Of_The_Green_Riddle_MolewormBrain
