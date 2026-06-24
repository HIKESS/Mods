-- prefabs/npc_woby.lua
-- NPC 沃尔特的独立沃比伙伴。骑乘状态统一由 npc_woby_ride.lua 管理；
-- 本 prefab 只提供可取消的外观变身原语。

local brain = require("brains/npc_woby_brain")

local assets =
{
    Asset("ANIM", "anim/pupington_basic.zip"),
    Asset("ANIM", "anim/pupington_emotes.zip"),
    Asset("ANIM", "anim/pupington_traits.zip"),
    Asset("ANIM", "anim/pupington_jump.zip"),
    Asset("ANIM", "anim/pupington_action.zip"),
    Asset("ANIM", "anim/pupington_woby_build.zip"),
    Asset("ANIM", "anim/pupington_transform.zip"),
    Asset("ANIM", "anim/woby_big_build.zip"),
    Asset("ANIM", "anim/woby_big_transform.zip"),
    Asset("ANIM", "anim/woby_big_travel.zip"),
    Asset("ANIM", "anim/woby_big_mount_travel.zip"),
    Asset("ANIM", "anim/woby_big_mount_basic.zip"),
    Asset("ANIM", "anim/woby_big_basic.zip"),
    Asset("ANIM", "anim/wilson_fx.zip"),
}

local TRANSFORM_SMALL_TO_BIG_TIME = 70 * FRAMES
local TRANSFORM_BIG_TO_SMALL_TIME = 70 * FRAMES

local function ClearWalterRef(inst)
    local leader = inst._npc_walter_leader
    if leader ~= nil and leader:IsValid() and leader._npc_woby == inst then
        leader._npc_woby = nil
    end
end

local function TeleportNearLeader(inst)
    if inst._npc_woby_big or inst._npc_woby_transforming then
        return
    end

    local leader = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
    if leader == nil or not leader:IsValid() then
        return
    end

    if inst:GetDistanceSqToInst(leader) > 25 * 25 then
        local theta = math.random() * TWOPI
        local radius = 2 + math.random() * 2
        local x, y, z = leader.Transform:GetWorldPosition()
        inst.Transform:SetPosition(x + math.cos(theta) * radius, y, z + math.sin(theta) * radius)
    end
end

local function SetLeader(inst, leader)
    if inst.components.follower ~= nil then
        inst.components.follower:SetLeader(leader)
    end
    inst._npc_walter_leader = leader
end

local function ApplyBuildOverrides(inst, animstate)
    animstate:AddOverrideBuild("woby_big_build")
end

local function ClearBuildOverrides(inst, animstate)
    animstate:ClearOverrideBuild("woby_big_build")
end

local function CancelTransformTask(inst)
    if inst._npc_woby_transform_task ~= nil then
        inst._npc_woby_transform_task:Cancel()
        inst._npc_woby_transform_task = nil
    end
end

local function StopMovementHard(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:StopMoving()
        inst.components.locomotor:Stop()
    end
    if inst.ClearBufferedAction ~= nil then
        inst:ClearBufferedAction()
    end
    if inst.Physics ~= nil then
        inst.Physics:Stop()
    end
end

local function CancelTransformMoveLock(inst)
    if inst._npc_woby_transform_move_task ~= nil then
        inst._npc_woby_transform_move_task:Cancel()
        inst._npc_woby_transform_move_task = nil
    end
end

local function LockMovementForTransform(inst)
    StopMovementHard(inst)
    CancelTransformMoveLock(inst)
    inst._npc_woby_transform_move_task = inst:DoPeriodicTask(FRAMES, StopMovementHard)
end

local function StopBrainAndSG(inst)
    StopMovementHard(inst)
    if inst.brain ~= nil and not inst._npc_woby_brain_paused then
        inst.brain:Stop()
        inst._npc_woby_brain_paused = true
    end
    if inst.sg ~= nil and not inst.sg.stopped then
        inst.sg:Stop()
    end
end

local function RestartSmallBrainAndSG(inst)
    if inst.sg ~= nil then
        if inst.sg.stopped then
            inst.sg:Start()
        end
        if inst.sg.currentstate == nil or inst.sg.currentstate.name ~= "idle" then
            inst.sg:GoToState("idle")
        end
    end
    if inst._npc_woby_brain_paused and inst.brain ~= nil then
        inst.brain:Start()
        inst._npc_woby_brain_paused = nil
    end
end

local function SetSmallVisual(inst)
    CancelTransformMoveLock(inst)
    inst._npc_woby_big = false
    inst._npc_woby_transforming = nil
    inst._npc_woby_transform_mode = nil
    inst._npc_woby_shrinking = nil
    inst:SetPrefabNameOverride("wobysmall")
    inst.MiniMapEntity:SetIcon("wobysmall.png")
    inst.DynamicShadow:SetSize(1.75, 1)
    inst.Transform:SetFourFaced()
    inst.AnimState:SetBank("pupington")
    inst.AnimState:SetBuild("pupington_woby_build")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst:RemoveTag("woby")
    inst:RemoveTag("dogrider_only")
    inst:RemoveTag("peacefulmount")
    if inst.components.locomotor ~= nil then
        inst.components.locomotor.walkspeed = TUNING.CRITTER_WALK_SPEED or 3
        inst.components.locomotor.runspeed = (TUNING.CRITTER_WALK_SPEED or 3) * 1.2
    end
    if inst.components.rideable ~= nil then
        inst.components.rideable.canride = false
    end
end

local function SetBigVisual(inst)
    CancelTransformMoveLock(inst)
    inst._npc_woby_big = true
    inst._npc_woby_transforming = nil
    inst._npc_woby_transform_mode = nil
    inst:SetPrefabNameOverride("wobybig")
    inst.MiniMapEntity:SetIcon("wobybig.png")
    inst.DynamicShadow:SetSize(5, 2)
    inst.Transform:SetSixFaced()
    inst.AnimState:SetBank("wobybig")
    inst.AnimState:SetBuild("woby_big_build")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst:AddTag("woby")
    inst:AddTag("dogrider_only")
    inst:AddTag("peacefulmount")
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:Stop()
        inst.components.locomotor.walkspeed = TUNING.WOBY_BIG_SPEED ~= nil and TUNING.WOBY_BIG_SPEED.SLOW or 6
        inst.components.locomotor.runspeed = TUNING.WOBY_BIG_SPEED ~= nil and TUNING.WOBY_BIG_SPEED.FAST or 9
    end
    if inst.components.rideable ~= nil then
        inst.components.rideable.canride = true
    end
end

local function NextTransformToken(inst, mode)
    CancelTransformTask(inst)
    inst._npc_woby_transform_token = (inst._npc_woby_transform_token or 0) + 1
    inst._npc_woby_transforming = true
    inst._npc_woby_transform_mode = mode
    return inst._npc_woby_transform_token
end

local function ForceBig(inst, on_done)
    if inst._npc_woby_mount_disabled then
        return false
    end
    if inst._npc_woby_big and not inst._npc_woby_transforming then
        StopBrainAndSG(inst)
        if on_done ~= nil then on_done(inst) end
        return true
    end
    if inst._npc_woby_transforming then
        return false
    end

    local token = NextTransformToken(inst, "big")
    StopBrainAndSG(inst)
    LockMovementForTransform(inst)
    inst.AnimState:SetBank("pupington")
    inst.AnimState:SetBuild("pupington_woby_build")
    inst.AnimState:AddOverrideBuild("woby_big_build")
    inst.AnimState:PlayAnimation("transform_small_to_big")
    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/transform_small_to_big")
    inst._npc_woby_transform_task = inst:DoTaskInTime(TRANSFORM_SMALL_TO_BIG_TIME, function(woby)
        woby._npc_woby_transform_task = nil
        if woby._npc_woby_transform_token ~= token or woby._npc_woby_transform_mode ~= "big" then
            return
        end
        if woby._npc_woby_mount_disabled then
            SetSmallVisual(woby)
            RestartSmallBrainAndSG(woby)
            return
        end
        SetBigVisual(woby)
        StopBrainAndSG(woby)
        woby.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/roar")
        if on_done ~= nil then on_done(woby) end
    end)
    return true
end

local function ForceSmall(inst, on_done)
    if inst._npc_woby_transforming then
        local mode = inst._npc_woby_transform_mode
        if mode == "small" then
            return true
        end
        CancelTransformTask(inst)
        inst._npc_woby_transform_token = (inst._npc_woby_transform_token or 0) + 1
        inst._npc_woby_transforming = nil
        inst._npc_woby_transform_mode = nil
        if mode == "big" or not inst._npc_woby_big then
            SetSmallVisual(inst)
            RestartSmallBrainAndSG(inst)
            if on_done ~= nil then on_done(inst) end
            return true
        end
    end

    if not inst._npc_woby_big then
        SetSmallVisual(inst)
        RestartSmallBrainAndSG(inst)
        if on_done ~= nil then on_done(inst) end
        return true
    end

    local token = NextTransformToken(inst, "small")
    inst._npc_woby_shrinking = true
    StopBrainAndSG(inst)
    LockMovementForTransform(inst)
    inst.AnimState:SetBank("wobybig")
    inst.AnimState:SetBuild("woby_big_build")
    inst.AnimState:AddOverrideBuild("pupington_woby_build")
    inst.AnimState:PlayAnimation("transform_big_to_small")
    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/transform_big_to_small")
    inst._npc_woby_transform_task = inst:DoTaskInTime(TRANSFORM_BIG_TO_SMALL_TIME, function(woby)
        woby._npc_woby_transform_task = nil
        if woby._npc_woby_transform_token ~= token or woby._npc_woby_transform_mode ~= "small" then
            return
        end
        SetSmallVisual(woby)
        RestartSmallBrainAndSG(woby)
        if on_done ~= nil then on_done(woby) end
    end)
    return true
end

local function FinishTransformation(inst)
    
    
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("wobysmall.png")
    inst.DynamicShadow:SetSize(1.75, 1)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("pupington")
    inst.AnimState:SetBuild("pupington_woby_build")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:PlayAnimation("idle_loop", true)

    MakeCharacterPhysics(inst, 1, .5)
    inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("companion")
    inst:AddTag("npcfriend_companion")
    inst:AddTag("npc_woby")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("noabandon")
    inst:AddTag("NOBLOCK")

    inst:SetPrefabNameOverride("wobysmall")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(true)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.softstop = true
    inst.components.locomotor.walkspeed = TUNING.CRITTER_WALK_SPEED or 3
    inst.components.locomotor.runspeed = (TUNING.CRITTER_WALK_SPEED or 3) * 1.2
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:AddComponent("rideable")
    inst.components.rideable:SetShouldSave(false)
    inst.components.rideable.canride = false
    inst.components.rideable:SetCustomRiderTest(function(woby, rider)
        return rider ~= nil and rider.npc_character_type == "walter"
    end)

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("timer")
    inst:AddComponent("crittertraits")

    
    inst.GetPeepChance = function() return 0 end
    inst.IsAffectionate = function() return false end
    inst.IsSuperCute = function() return false end
    inst.IsPlayful = function() return false end

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwobysmall")

    inst.SetLeader = SetLeader
    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides
    inst.ForceBig = ForceBig
    inst.ForceSmall = ForceSmall
    inst.SetBigVisual = SetBigVisual
    inst.SetSmallVisual = SetSmallVisual
    inst.ApplyBigBuildOverrides = function(woby) woby.AnimState:AddOverrideBuild("woby_big_build") end
    inst.FinishTransformation = FinishTransformation
    inst:ListenForEvent("onremove", ClearWalterRef)

    inst._npc_woby_teleport_task = inst:DoPeriodicTask(5, TeleportNearLeader)
    inst.persists = false
    SetSmallVisual(inst)

    return inst
end

return Prefab("npc_woby", fn, assets)
