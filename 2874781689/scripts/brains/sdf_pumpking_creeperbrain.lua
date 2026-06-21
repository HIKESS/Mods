require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/attackwall"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/doaction"
require "behaviours/standstill"
local BrainCommon = require("brains/braincommon")

local SDFPumpking_CreeperBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self.reanimatetime = nil
end)

local SEE_DIST = 10 --30
local SEE_FOOD_DIST = 10
local GO_HOME_DSQ = 100 -- 10^2
local MAX_CHASE_TIME = 10 --10
local MAX_CHASE_DIST = 10 --30
local WANDER_DIST = 12 --12

local NOEAT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "outofreach" }
local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local target = FindEntity(
        inst,
        SEE_FOOD_DIST,
        function(item)
            return item:GetTimeAlive() >= 8
                and item:IsOnPassablePoint(true)
		and ((inst.prefab == "sdf_pumpking_creeper" and (item.prefab == "spoiled_food" or item.prefab == "spoiled_fish" or item.prefab == "spoiled_fish_small"
		    or item.prefab == "rocks" or item.prefab == "flint" or item.prefab == "nitre" or item.prefab == "twigs" or item:HasTag("birdfeather"))) 
		or (inst.prefab == "sdf_pumpkin_creeper" and (item.prefab == "spoiled_food" or item.prefab == "spoiled_fish" or item.prefab == "spoiled_fish_small")))
		and item:GetDistanceSqToPoint(ix, iy, iz) < GO_HOME_DSQ -- too far from home = bouncing
        end,
        nil,
        NOEAT_TAGS,
        inst.components.eater:GetEdibleTags()
    )
    return target ~= nil and BufferedAction(inst, target, ACTIONS.EAT) or nil
end

local TAKEBAIT_CANT_TAGS = { "outofreach", "INLIMBO", "fire" }

local function IsCreeperBait(item)
    return item:HasTag("birdfeather") or item.prefab == "twigs"
end

local function SelectedTargetTimeout(target)
    target.selectedasmoletarget = nil
end

local function TakeBaitAction(inst)
    --Don't look for bait if just spawned
    if inst.prefab == "sdf_pumpkin_creeper" then
        return
    elseif inst:GetTimeAlive() < 8 then
        return
    end

    local target = FindEntity(inst, SEE_FOOD_DIST, IsCreeperBait, nil, TAKEBAIT_CANT_TAGS)
    if target ~= nil and not target.selectedasmoletarget and target:IsOnValidGround() then
        target.selectedasmoletarget = true
        target:DoTaskInTime(5, SelectedTargetTimeout)
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function()
            return not (target.components.inventoryitem ~= nil and target.components.inventoryitem:IsHeld())
                and not (target.components.burnable ~= nil and target.components.burnable:IsBurning())
        end
        return act
    end
end

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or nil
end

local function GetHome(inst)
    return inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
end

local function GetHomePos(inst)
    local home = GetHome(inst)
    return home ~= nil and home:GetPosition() or nil
end

local function GetNoLeaderLeashPos(inst)
    return GetLeader(inst) == nil and GetHomePos(inst) or nil
end

local function getdirectionFn(inst)
    local r = math.random() * 2 - 1
return (inst.Transform:GetRotation() + r*r*r * 60) * DEGREES
end

local function shouldink(inst)
    if inst.components.combat.target and not inst.components.timer:TimerExists("ink_cooldown") then
        local act = BufferedAction(inst, inst.components.combat.target, ACTIONS.TOSS)
        return act
    end

    return nil
end

local FIND_WALL_TAGS = {"wall"}
local function findwall(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local walls = TheSim:FindEntities(x,y,z, 1, FIND_WALL_TAGS)
    return #walls > 0
end

local function GetSpawnPoint(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

function SDFPumpking_CreeperBrain:OnStart()
    local root = PriorityNode(
        {
            WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "NotJumpingBehaviour",
                PriorityNode({
		    BrainCommon.PanicTrigger(self.inst),
                    BrainCommon.ElectricFencePanicTrigger(self.inst),

                    IfNode(function() return findwall(self.inst) end, "nearwall", AttackWall(self.inst)),

                    WhileNode( function() return self.inst.components.combat.target end, "combat actions",
                        PriorityNode({
                            DoAction(self.inst, shouldink),
                            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
                        })
                    ),

		    DoAction(self.inst, EatFoodAction, "Find and Eat"),
		    DoAction(self.inst, TakeBaitAction, "Take Bait", false),
		    Wander(self.inst, GetSpawnPoint, WANDER_DIST),
                }, .5)
            ),
        }, .5 )

    self.bt = BT(self.inst, root)
end

function SDFPumpking_CreeperBrain:OnInitializationComplete()
    local pos = self.inst:GetPosition()
    pos.y = 0

    self.inst.components.knownlocations:RememberLocation("spawnpoint", pos, true)
end

return SDFPumpking_CreeperBrain
