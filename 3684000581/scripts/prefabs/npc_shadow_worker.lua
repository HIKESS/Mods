-- npc_shadow_worker.lua
-- NPC 暗影工人：Maxwell 检测到玩家挖矿时召唤，自动帮忙挖矿
-- 与暗影保护者共享召唤 CD

local NPC_TUNING = require("npc_tuning")
local brain = require("brains/npc_shadow_worker_brain")

local assets = {
    Asset("ANIM", "anim/waxwell_minion_spawn.zip"),
    Asset("ANIM", "anim/waxwell_minion_appear.zip"),
    Asset("ANIM", "anim/waxwell_minion_idle.zip"),
    Asset("ANIM", "anim/swap_pickaxe.zip"),
    Asset("ANIM", "anim/swap_axe.zip"),
    Asset("ANIM", "anim/swap_shovel.zip"),
    Asset("ANIM", "anim/splash_weregoose_fx.zip"),
    Asset("ANIM", "anim/splash_water_drop.zip"),
    Asset("SOUND", "sound/maxwell.fsb"),
}

local prefabs = {
    "shadow_despawn",
    "statue_transition_2",
}




local function NotifyLeaderOnRemove(inst)
    local leader = inst._leader
    if not leader or not leader:IsValid() then return end

    if leader._shadow_workers then
        for i = #leader._shadow_workers, 1, -1 do
            if leader._shadow_workers[i] == inst then
                table.remove(leader._shadow_workers, i)
                print("[npc_shadow_worker] 从 _shadow_workers 数组移除引用 (剩余: " .. #leader._shadow_workers .. ")")
                break
            end
        end
    end
end




local function DoDespawn(inst)
    if not inst:IsValid() then return end
    local fx = SpawnPrefab("statue_transition_2")
    if fx then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    inst:Remove()
end




local function SetLeader(inst, leader)
    if inst.components.follower then
        inst.components.follower:SetLeader(leader)
    end
    inst._leader = leader
    inst:ListenForEvent("onremove", NotifyLeaderOnRemove)
end




local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    
    inst:SetPhysicsRadiusOverride(0.5)
    MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)
    inst.Transform:SetFourFaced(inst)

    
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("waxwell")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:OverrideSymbol("swap_object", "swap_pickaxe", "swap_pickaxe")
    inst.AnimState:PlayAnimation("minion_spawn")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(0, 0, 0, 0.5)
    inst.AnimState:UsePointFiltering(true)

    inst.AnimState:AddOverrideBuild("waxwell_minion_spawn")
    inst.AnimState:AddOverrideBuild("waxwell_minion_appear")

    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")

    
    inst:AddTag("companion")
    inst:AddTag("shadow_aligned")
    inst:AddTag("shadowminion")
    inst:AddTag("scarytoprey")
    inst:AddTag("NOBLOCK")
    inst:AddTag("npcfriend_companion")

    inst:SetPrefabNameOverride("shadowworker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    
    
    

    
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 6
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor:SetSlowMultiplier(0.6)

    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(NPC_TUNING.SHADOW_WORKER_HEALTH or 30)
    inst.components.health.nofadeout = true

    
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)

    
    inst:AddComponent("worker")
    inst.components.worker:SetAction(ACTIONS.MINE, 1)
    inst.components.worker:SetAction(ACTIONS.CHOP, 1)
    inst.components.worker:SetAction(ACTIONS.DIG, 1)

    
    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = false
    inst.components.follower.keepleaderduringminigame = true

    inst:SetStateGraph("SGshadowwaxwell")
    inst:SetBrain(brain)

    inst.isworker = true

    
    inst.DropAggro = function() end

    
    inst:ListenForEvent("death", function()
        NotifyLeaderOnRemove(inst)
        local fx = SpawnPrefab("shadow_despawn")
        if fx then fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) end
    end)

    
    local lifetime = NPC_TUNING.SHADOW_WORKER_LIFETIME or 120
    inst._lifetime_task = inst:DoTaskInTime(lifetime, DoDespawn)

    inst.SetLeader = SetLeader

    inst.persists = false  

    return inst
end

return Prefab("npc_shadow_worker", fn, assets, prefabs)
