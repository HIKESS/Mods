require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/doaction"
require "behaviours/standstill"
require "behaviours/runaway"

-- 即时行为节点：用于在 AI 中执行一帧完成的逻辑（如从军械库取材料自造装备）
local InstantActionNode = Class(BehaviourNode, function(self, inst, actionfn)
    BehaviourNode._ctor(self, "InstantActionNode")
    self.inst = inst
    self.actionfn = actionfn
end)

function InstantActionNode:Visit()
    local ok = self.actionfn(self.inst)
    self.status = (ok == true) and SUCCESS or FAILED
end

local Wiltonmod_Pet_Brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self.reanimatetime = nil
end)

local SEE_DIST = 30

local MIN_FOLLOW_LEADER = 0
local MAX_FOLLOW_LEADER = 10
local TARGET_FOLLOW_LEADER = 7

local SEE_TREE_DIST = 15
local KEEP_CHOPPING_DIST = 10

local KEEP_WORKING_DIST = 14
local SEE_WORK_DIST = 10

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 40

local HOUSE_MAX_DIST = 40
local HOUSE_RETURN_DIST = 50

local SIT_BOY_DIST = 10
local SEE_BUSH_DIST = 24

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40

local RUN_START_DIST = 1.5
local RUN_STOP_DIST = 4

local SEE_TREE_DIST = 15
local KEEP_CHOPPING_DIST = 16

local KEEP_WORKING_DIST = 14
local SEE_WORK_DIST = 10

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or nil
end

local function GetHome(inst)
    return inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
end

local function ShouldRunAway(target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and (not target:HasTag("shadowcreature") or (target.components.combat ~= nil and target.components.combat:HasTarget()))
end

local function ShouldKite(target, inst)
    return inst.components.combat and inst.components.combat:TargetIs(target)
        and target.components.combat and target.components.health ~= nil
        and not target.components.health:IsDead()
end

local function GetHomePos(inst)
    local home = GetHome(inst)
    return home ~= nil and home:GetPosition() or nil
end

local function GetNoLeaderLeashPos(inst)
    return GetLeader(inst) == nil and GetHomePos(inst) or nil
end

local function ShouldStandStill(inst)
    -- 指挥：待机模式下无论是否有领主都原地待命
    if inst.command_state == "stop" then
        return true
    end
    return not GetLeader(inst) and (inst.components.combat == nil or (inst.components.combat and not inst.components.combat:HasTarget()))
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function GetLeaderForFollow(inst)
    -- 待机模式下不参与跟随逻辑
    if inst.command_state == "stop" then
        return nil
    end
    return GetLeader(inst)
end

local function GetStayPos(inst)
    return inst.components.followersitcommand.locations["currentstaylocation"]
end

local function GetWanderPoint(inst)
    if inst.components.followersitcommand and inst.components.followersitcommand:IsCurrentlyStaying() then
        return GetStayPos(inst)
    else
        local target = GetLeader(inst) or GetPlayer()
        if target then
            return target:GetPosition()
        end
    end
end

local function ShouldGoHome(inst)
    local homePos = inst.components.followersitcommand.locations["currentstaylocation"]
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) > 5*5)
end

local function GoHomeAction(inst)
    local homePos = inst.components.followersitcommand.locations["currentstaylocation"]
    if homePos then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, 0.2)
    end
end
----------------------------------------------

--=========================
local function IsDeciduousTreeMonster(guy)
    return guy.monster and guy.prefab == "deciduoustree"
end

local CHOP_MUST_TAGS = { "CHOP_workable" }
local function FindDeciduousTreeMonster(inst)
    return FindEntity(inst, SEE_TREE_DIST / 3, IsDeciduousTreeMonster, CHOP_MUST_TAGS)
end

local function HasAxe(inst)
    return inst.components.inventory:EquipHasTag("CHOP_tool")
end

local function KeepChoppingAction(inst)
    if inst.command_state == "work" then
        return HasAxe(inst)
            and (inst.tree_target ~= nil or FindDeciduousTreeMonster(inst) ~= nil or FindEntity(inst, SEE_TREE_DIST, nil, CHOP_MUST_TAGS) ~= nil)
            and not inst:HasTag("INLIMBO")
    end

    local leader = inst.components.follower.leader
    return HasAxe(inst) and FindDeciduousTreeMonster(inst) and leader and leader.sg and leader.sg:HasStateTag("chopping")
        and inst:IsNear(leader, KEEP_CHOPPING_DIST)
        and not inst:HasTag("INLIMBO")
end

local function StartChoppingCondition(inst)
    -- 仅在默认/工作指令下参与伐木工作
    if inst.command_state ~= nil and inst.command_state ~= "work" then
        return false
    end

    if inst.command_state == "work" then
        return HasAxe(inst)
            and (inst.tree_target ~= nil or FindDeciduousTreeMonster(inst) ~= nil or FindEntity(inst, SEE_TREE_DIST, nil, CHOP_MUST_TAGS) ~= nil)
            and not inst:HasTag("INLIMBO")
    end

    local leader = inst.components.follower.leader
    return HasAxe(inst) and (inst.tree_target ~= nil or leader ~= nil or FindDeciduousTreeMonster(inst) ~= nil)
        and leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag("chopping")
        and not inst:HasTag("INLIMBO")
end

local function FindTreeToChopAction(inst)
    if inst.tree_target ~= nil and inst.tree_target:IsValid() and inst.tree_target:HasTag("CHOP_workable") then
        local target = inst.tree_target
        inst.tree_target = nil
        return BufferedAction(inst, target, ACTIONS.CHOP)
    end

    local target = FindEntity(inst, SEE_TREE_DIST, nil, CHOP_MUST_TAGS)
    if target ~= nil then
        target = FindDeciduousTreeMonster(inst) or target
        return BufferedAction(inst, target, ACTIONS.CHOP)
    end
end

----=============================

local MINE_MUST_TAGS = { "MINE_workable" }

local function HasMiner(inst)
    return inst.components.inventory:EquipHasTag("MINE_tool")
end

local function FindRockToMineAction(inst)
    local leader = inst.components.follower.leader
    if inst.tree_target ~= nil and inst.tree_target:IsValid() and inst.tree_target:HasTag("MINE_workable") then
        local target = inst.tree_target
        inst.tree_target = nil
        return BufferedAction(inst, target, ACTIONS.MINE)
    end

    local target = FindEntity(inst, SEE_TREE_DIST, nil, MINE_MUST_TAGS)
    if target ~= nil and (inst.command_state == "work" or (leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag("mining"))) then
        return BufferedAction(inst, target, ACTIONS.MINE)
    end
end

local function KeepMineingAction(inst)
    if inst.command_state == "work" then
        return HasMiner(inst)
            and (inst.tree_target ~= nil or FindEntity(inst, SEE_TREE_DIST, nil, MINE_MUST_TAGS) ~= nil)
            and not inst:HasTag("INLIMBO")
    end

    local leader = inst.components.follower.leader
    return HasMiner(inst) and FindRockToMineAction(inst) and leader and leader.sg and leader.sg:HasStateTag("mining")
        and inst:IsNear(leader, KEEP_CHOPPING_DIST)
        and not inst:HasTag("INLIMBO")
end

local function StartMineCondition(inst)
    -- 仅在默认/工作指令下参与挖矿工作
    if inst.command_state ~= nil and inst.command_state ~= "work" then
        return false
    end

    if inst.command_state == "work" then
        return HasMiner(inst)
            and (inst.tree_target ~= nil or FindEntity(inst, SEE_TREE_DIST, nil, MINE_MUST_TAGS) ~= nil)
            and not inst:HasTag("INLIMBO")
    end

    local leader = inst.components.follower.leader
    return HasMiner(inst) and leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag("mining")
        and not inst:HasTag("INLIMBO")
end

local DUG_MUST_TAGS = { "DIG_workable", "stump" }

local function HasDiger(inst)
    return inst.components.inventory:EquipHasTag("DIG_tool")  --print(c_findnext("wiltonmod_pet", 4).components.inventory:EquipHasTag("DUG_tool"))
end

local function KeepDUGingAction(inst)
    if inst.command_state == "work" then
        return HasDiger(inst) and (inst.tree_target ~= nil or FindEntity(inst, SEE_TREE_DIST, nil, DUG_MUST_TAGS) ~= nil)
    end
    return HasDiger(inst) and (inst.tree_target ~= nil or (inst.components.follower.leader ~= nil and inst:IsNear(inst.components.follower.leader, KEEP_CHOPPING_DIST)))
end

local function StartDUGCondition(inst)
    -- 仅在默认/工作指令下参与挖掘工作
    if inst.command_state ~= nil and inst.command_state ~= "work" then
        return false
    end
    if inst.command_state == "work" then
        return HasDiger(inst) and (inst.tree_target ~= nil or FindEntity(inst, SEE_TREE_DIST, nil, DUG_MUST_TAGS) ~= nil)
    end
    return HasDiger(inst) and (inst.tree_target ~= nil or inst.components.follower.leader ~= nil)
end

local function FindRockToDUGAction(inst)
    if inst.tree_target ~= nil and inst.tree_target:IsValid() and (inst.tree_target:HasTag("DIG_workable") or inst.tree_target:HasTag("stump")) then
        local target = inst.tree_target
        inst.tree_target = nil
        return BufferedAction(inst, target, ACTIONS.DIG)
    end

    local target = FindEntity(inst, SEE_TREE_DIST, nil, DUG_MUST_TAGS)
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.DIG)
    end
end    

local function FindNearbyUndeadArmory(inst)
    return FindEntity(inst, 20, function(guy)
        return guy.prefab == "undead_armory"
            and guy.components.container ~= nil
            and not guy:HasTag("burnt")
            and not guy:HasTag("INLIMBO")
    end)
end

local function CountItemInContainer(container, prefab)
    local count = 0
    for i = 1, container.numslots do
        local item = container:GetItemInSlot(i)
        if item ~= nil and item.prefab == prefab then
            count = count + (item.components.stackable ~= nil and item.components.stackable:StackSize() or 1)
        end
    end
    return count
end

local function ConsumeItemsFromContainer(container, prefab, amount)
    local remaining = amount
    while remaining > 0 do
        local item = container:FindItem(function(i) return i.prefab == prefab end)
        if item == nil then
            return false
        end
        local stacksize = item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
        if stacksize <= remaining then
            container:RemoveItem(item):Remove()
            remaining = remaining - stacksize
        else
            item.components.stackable:Get(remaining):Remove()
            remaining = 0
        end
    end
    return true
end

local function HasSkill(inst, name)
    return inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated(name)
end

-- 将骷髅兵从军械库获取的装备标记为临时物品：不可掉落、不可被玩家拾取、仅限骷髅兵装备
local function SetupTempGear(item)
    if item == nil then
        return
    end
    item:AddTag("wilton_temp_gear")
    item:AddTag("irreplaceable")

    if item.components.inventoryitem ~= nil then
        item.components.inventoryitem.cangoincontainer = false
        item.components.inventoryitem.canbepickedup = false
    end

    if item.components.equippable ~= nil then
        item.components.equippable.restrictedtag = "wiltonmod_pet"
    end

    item:ListenForEvent("ondropped", function(inst)
        inst:Remove()
    end)
end

local function NeedsArmoryGear(inst)
    -- 待机模式下不执行
    if inst.command_state == "stop" then
        return false
    end

    local hands = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local body  = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    local head  = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

    -- 全身装备齐全则不需要
    if hands ~= nil and body ~= nil and head ~= nil then
        return false
    end

    local armory = FindNearbyUndeadArmory(inst)
    if armory == nil then
        return false
    end

    local container = armory.components.container
    local leader = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil

    -- 顶级装备：骷髅军团3级（最优先判定）
    if leader ~= nil and HasSkill(leader, "wiltonmod_skill2_10") then
        if hands == nil and CountItemInContainer(container, "nightmarefuel") >= 4 then
            return true
        end
    end

    -- 高级装备：骷髅军团2级
    if leader ~= nil and HasSkill(leader, "wiltonmod_skill2_9") then
        if body == nil and head == nil and CountItemInContainer(container, "nightmarefuel") >= 6 then
            return true
        end
    end

    local flint_need = (hands == nil) and 1 or 0
    local log_need = 0
    if body == nil then log_need = log_need + 4 end
    if head == nil then log_need = log_need + 4 end

    return CountItemInContainer(container, "flint") >= flint_need
       and CountItemInContainer(container, "log") >= log_need
end

local function DoEquipFromArmory(inst)
    local armory = FindNearbyUndeadArmory(inst)
    if armory == nil then
        return
    end

    local container = armory.components.container
    local hands = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local body  = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    local head  = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    local leader = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil

    -- 顶级装备：骷髅军团3级（最优先消耗噩梦燃料制作）
    if leader ~= nil and HasSkill(leader, "wiltonmod_skill2_10") then
        if hands == nil and CountItemInContainer(container, "nightmarefuel") >= 4 then
            if ConsumeItemsFromContainer(container, "nightmarefuel", 4) then
                local sword = SpawnPrefab("nightsword")
                SetupTempGear(sword)
                inst.components.inventory:Equip(sword)
                return
            end
        end
    end

    -- 高级装备：骷髅军团2级
    if leader ~= nil and HasSkill(leader, "wiltonmod_skill2_9") then
        if body == nil and head == nil and CountItemInContainer(container, "nightmarefuel") >= 6 then
            if ConsumeItemsFromContainer(container, "nightmarefuel", 6) then
                local armor = SpawnPrefab("armor_sanity")
                SetupTempGear(armor)
                inst.components.inventory:Equip(armor)
                local hat = SpawnPrefab("tophat")
                SetupTempGear(hat)
                inst.components.inventory:Equip(hat)
                return
            end
        end
    end

    -- 基础装备：消耗 1 燧石制作长矛
    if hands == nil then
        if ConsumeItemsFromContainer(container, "flint", 1) then
            local spear = SpawnPrefab("spear")
            SetupTempGear(spear)
            inst.components.inventory:Equip(spear)
        end
    end

    -- 基础装备：消耗木头制作木甲和猪皮头盔
    local log_need = 0
    if body == nil then log_need = log_need + 4 end
    if head == nil then log_need = log_need + 4 end

    if log_need > 0 and ConsumeItemsFromContainer(container, "log", log_need) then
        if body == nil then
            local armor = SpawnPrefab("armorwood")
            SetupTempGear(armor)
            inst.components.inventory:Equip(armor)
        end
        if head == nil then
            local hat = SpawnPrefab("footballhat")
            SetupTempGear(hat)
            inst.components.inventory:Equip(hat)
        end
    end
end

function Wiltonmod_Pet_Brain:OnStart()
    local root = PriorityNode(
        {
            -- 最优先：检测附近军械库并自取材料制作装备
            InstantActionNode(self.inst, function(inst)
                if NeedsArmoryGear(inst) then
                    DoEquipFromArmory(inst)
                    return true
                end
                return false
            end),

            IfThenDoWhileNode(function() return StartChoppingCondition(self.inst) end, function() return KeepChoppingAction(self.inst) end, "chop",
                LoopNode{
                    ChattyNode(self.inst, "CHOP_WOOD",
                        DoAction(self.inst, FindTreeToChopAction ))}),

            IfThenDoWhileNode(function() return StartMineCondition(self.inst) end, function() return KeepMineingAction(self.inst) end, "mine",
                LoopNode{
                    ChattyNode(self.inst, "MINE_ROCK",
                        DoAction(self.inst, FindRockToMineAction ))}),

            IfThenDoWhileNode(function() return StartDUGCondition(self.inst) end, function() return KeepDUGingAction(self.inst) end, "dug",
                LoopNode{
                    ChattyNode(self.inst, "DUG_ROCK",
                        DoAction(self.inst, FindRockToDUGAction ))}),

            WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "NotJumpingBehaviour",
                PriorityNode({
                    WhileNode(function() return GetLeader(self.inst) == nil end, "NoLeader", AttackWall(self.inst)),
                        RunAway(self.inst, ShouldKite, RUN_START_DIST, RUN_STOP_DIST),    
                        ChaseAndAttack(self.inst, MAX_CHASE_TIME, 20),

                    Leash(self.inst, GetNoLeaderLeashPos, HOUSE_MAX_DIST, HOUSE_RETURN_DIST),

                    Follow(self.inst, GetLeaderForFollow, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
                    FaceEntity(self.inst, GetLeader, GetLeader),

                    StandStill(self.inst, ShouldStandStill),
                }, .25)
            ),
        }, .25 )

    self.bt = BT(self.inst, root)
end

return Wiltonmod_Pet_Brain
