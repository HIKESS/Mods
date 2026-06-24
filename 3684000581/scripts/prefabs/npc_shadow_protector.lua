-- npc_shadow_protector.lua
-- NPC 暗影保护者：Maxwell 召唤的暗影分身，跟随主人并保护其免受攻击

local NPC_TUNING = require("npc_tuning")
local brain = require("brains/npc_shadow_protector_brain")

local assets = {
    Asset("ANIM", "anim/waxwell_minion_spawn.zip"),
    Asset("ANIM", "anim/waxwell_minion_appear.zip"),
    Asset("ANIM", "anim/waxwell_minion_idle.zip"),
    Asset("ANIM", "anim/lavaarena_shadow_lunge.zip"),
    Asset("ANIM", "anim/splash_weregoose_fx.zip"),
    Asset("ANIM", "anim/splash_water_drop.zip"),
    Asset("SOUND", "sound/maxwell.fsb"),
}

local prefabs = {
    "shadow_despawn",
    "statue_transition_2",
}




local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "playerghost", "INLIMBO", "npcfriend_companion", "player" }

local function IsFriendlyNPC(target)
    return target and target:HasTag("npcfriend") and not target:HasTag("npc_hostile")
end

local function RetargetFn(inst)
    local leader = inst.components.follower and inst.components.follower:GetLeader()
    if leader then
        if leader.components.combat then
            local target = leader.components.combat.target
            if target and target:IsValid() 
                and not IsFriendlyNPC(target)
                and not target:HasTag("npcfriend_companion")
                and inst.components.combat:CanTarget(target) then
                return target
            end
        end
        local x, y, z = leader.Transform:GetWorldPosition()
        local leash = NPC_TUNING.SHADOW_PROTECTOR_LEASH or 12
        local ents = _G.TheSim:FindEntities(x, y, z, leash, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS)
        for _, ent in ipairs(ents) do
            if ent ~= inst and ent.components.combat
                and (ent.components.combat:TargetIs(leader) or ent.components.combat:TargetIs(inst))
                and inst.components.combat:CanTarget(ent) then
                return ent
            end
        end
    end
    return nil
end

local function KeepTargetFn(inst, target)
    local leader = inst.components.follower and inst.components.follower:GetLeader()
    if not leader then
        return false
    end
    local leash = NPC_TUNING.SHADOW_PROTECTOR_LEASH or 12
    return inst.components.combat:CanTarget(target)
        and inst:IsNear(leader, leash + 5)
        and not IsFriendlyNPC(target)
        and not target:HasTag("npcfriend_companion")
        and not target:HasTag("player")
end




local function NotifyLeaderOnRemove(inst)
    local leader = inst._leader
    if not leader or not leader:IsValid() then
        return
    end
    
    
    if leader._shadow_protector == inst then
        leader._shadow_protector = nil
        print("[npc_shadow_protector] 通知主人清理 _shadow_protector 引用")
    end
    
    if leader._shadow_protectors then
        for i = #leader._shadow_protectors, 1, -1 do
            if leader._shadow_protectors[i] == inst then
                table.remove(leader._shadow_protectors, i)
                print("[npc_shadow_protector] 从 _shadow_protectors 数组移除引用 (剩余: " .. #leader._shadow_protectors .. ")")
                break
            end
        end
    end
end




local function OnAttacked(inst, data)
    if data.attacker ~= nil and data.attacker.components.combat ~= nil then
        if not IsFriendlyNPC(data.attacker)
            and not data.attacker:HasTag("npcfriend_companion")
            and not data.attacker:HasTag("player") then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end




local function OnDeath(inst)
    NotifyLeaderOnRemove(inst)
    
    local fx = SpawnPrefab("shadow_despawn")
    if fx then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
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
    inst.AnimState:OverrideSymbol("swap_object", "swap_nightmaresword_shadow", "swap_nightmaresword_shadow")
    inst.AnimState:PlayAnimation("minion_spawn")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(0, 0, 0, 0.5)
    inst.AnimState:UsePointFiltering(true)
    
    inst.AnimState:AddOverrideBuild("waxwell_minion_spawn")
    inst.AnimState:AddOverrideBuild("waxwell_minion_appear")
    inst.AnimState:AddOverrideBuild("lavaarena_shadow_lunge")
    
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    

    inst:AddTag("companion")
    inst:AddTag("shadow_aligned")  
    inst:AddTag("shadowminion")
    inst:AddTag("scarytoprey")
    inst:AddTag("NOBLOCK")
    inst:AddTag("npcfriend_companion")
    
    inst:SetPrefabNameOverride("shadowprotector")
    
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
    local max_hp = NPC_TUNING.SHADOW_PROTECTOR_HEALTH or 75
    inst.components.health:SetMaxHealth(max_hp)
    inst.components.health.nofadeout = true
    
    inst.components.health:SetMaxDamageTakenPerHit(15)
    
    
    local function UpdateHealthClamp(inst)
        local cap = math.abs(inst.components.health.maxdamagetakenperhit or 15)
        cap = cap + 5
        cap = math.min(cap, math.max(1, inst.components.health.maxhealth - 1))
        inst.components.health:SetMaxDamageTakenPerHit(cap)
    end
    
    local function OnProtectorAttacked(inst, data)
        inst.components.health:SetMaxDamageTakenPerHit(15)
        if inst._clamp_task then 
            inst._clamp_task:Cancel() 
            inst._clamp_task = nil
        end
        
        inst._clamp_task = inst:DoPeriodicTask(2.5, UpdateHealthClamp, 5)
    end
    
    
    inst:AddComponent("combat")
    local damage = NPC_TUNING.SHADOW_PROTECTOR_DAMAGE or 25
    inst.components.combat:SetDefaultDamage(damage)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRange(2)
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    
    
    inst.DropAggro = function(inst)
        if inst.components.combat then
            if inst.components.combat.DropTarget then
                inst.components.combat:DropTarget()
            else
                inst.components.combat:SetTarget(nil)
            end
        end
    end
    
    
    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = false
    inst.components.follower.keepleaderduringminigame = true
    
    
    inst:AddComponent("timer")
    
    inst:SetStateGraph("SGshadowwaxwell")
    
    inst:SetBrain(brain)
    
    inst.isprotector = true
    
    
    inst:ListenForEvent("attacked", function(inst, data)
        OnProtectorAttacked(inst, data)
        OnAttacked(inst, data)
    end)
    inst:ListenForEvent("death", OnDeath)
    
    
    local lifetime = NPC_TUNING.SHADOW_PROTECTOR_LIFETIME or 120
    inst._lifetime_task = inst:DoTaskInTime(lifetime, DoDespawn)
    
    inst.SetLeader = SetLeader
    
    inst.persists = false  
    
    return inst
end

return Prefab("npc_shadow_protector", fn, assets, prefabs)
