-- scripts/npc/characters/waxwell.lua
-- Waxwell: 麦斯威尔，战斗时召唤暗影保护者，跟随玩家挖矿时召唤暗影工人
-- 低血量（75）、低背包（12格）
-- 死亡模式：与 Wilson 相同

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")
local npc_affinity = require("npc/npc_affinity")

local function CombatLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_COMBAT then print(...) end
end

-- ══════════════════════════════════
-- 暗影保护者召唤系统
-- ══════════════════════════════════

local function CleanupProtectors(inst)
    if not inst._shadow_protectors then
        inst._shadow_protectors = {}
    end
    local valid = {}
    for _, p in ipairs(inst._shadow_protectors) do
        if p and p:IsValid() then
            table.insert(valid, p)
        end
    end
    inst._shadow_protectors = valid
    return #valid
end

local function DismissShadowProtector(inst)
    if inst._shadow_protector and inst._shadow_protector:IsValid() then
        local fx = SpawnPrefab("statue_transition_2")
        if fx then
            fx.Transform:SetPosition(inst._shadow_protector.Transform:GetWorldPosition())
        end
        inst._shadow_protector:Remove()
        inst._shadow_protector = nil
    end

    if inst._shadow_protectors then
        for _, protector in ipairs(inst._shadow_protectors) do
            if protector and protector:IsValid() then
                local fx = SpawnPrefab("statue_transition_2")
                if fx then
                    fx.Transform:SetPosition(protector.Transform:GetWorldPosition())
                end
                protector:Remove()
            end
        end
        inst._shadow_protectors = {}
    end
end

local function IsFriendlyTarget(target)
    return target:HasTag("npcfriend")
        or target:HasTag("npcfriend_companion")
        or target:HasTag("player")
end

local function SummonShadowProtector(inst)
    if not npc_affinity.MeetsThreshold(inst, "shadow_protector") then
        return false
    end
    local now = GetTime()
    local cd = NPC_TUNING.SHADOW_PROTECTOR_COOLDOWN or 180
    if inst._shadow_summon_time and (now - inst._shadow_summon_time) < cd then
        return false
    end
    
    CleanupProtectors(inst)
    if #inst._shadow_protectors > 0 then
        return false
    end
    
    inst._shadow_summon_time = now
    
    local function DoSummon(inst)
        local count = NPC_TUNING.SHADOW_PROTECTOR_MAX_COUNT or 1
        local x, y, z = inst.Transform:GetWorldPosition()
        
        for i = 1, count do
            local protector = SpawnPrefab("npc_shadow_protector")
            if protector then
                local angle = (i - 1) * (2 * math.pi / count) + math.random() * 0.5
                protector.Transform:SetPosition(x + math.cos(angle) * 2, y, z + math.sin(angle) * 2)
                
                table.insert(inst._shadow_protectors, protector)
                
                local leader = inst
                protector:DoTaskInTime(0, function()
                    if protector:IsValid() and leader:IsValid() then
                        if protector.SetLeader then
                            protector:SetLeader(leader)
                        end
                        if leader.components.combat and leader.components.combat.target then
                            local target = leader.components.combat.target
                            if target:IsValid() and protector.components.combat
                               and not IsFriendlyTarget(target) then
                                protector.components.combat:SetTarget(target)
                            end
                        end
                    end
                end)
            end
        end
        
        if inst.components.talker then
            local speech = NPC_SPEECH and NPC_SPEECH.SHADOW_SUMMON
            if speech then
                local line = speech[math.random(#speech)]
                inst.components.talker:Say(line, nil, nil, true)
            end
        end
        
        CombatLog("[Waxwell] 召唤了 " .. #inst._shadow_protectors .. " 个暗影保护者")
        inst._on_book_action = nil  -- 清理回调
    end
    
    inst._on_book_action = DoSummon
    
    if inst.sg then
        inst.sg:GoToState("npc_book")
    else
        DoSummon(inst)
    end
    
    return true
end

local function CombatSummonCheck(inst)
    if inst._is_ghost_mode then return end
    if not inst._shadow_summon_enabled then return end
    if inst.components.combat and inst.components.combat:HasTarget() then
        CleanupProtectors(inst)
        if #inst._shadow_protectors == 0 then
            SummonShadowProtector(inst)
        end
    end
end

-- ══════════════════════════════════
-- 暗影支柱系统（群控技能）
-- ══════════════════════════════════

local function CastShadowPillars(inst)
    if not npc_affinity.MeetsThreshold(inst, "shadow_pillar") then
        return false
    end
    local now = GetTime()
    local cd = NPC_TUNING.SHADOW_PILLAR_COOLDOWN or 30
    
    if inst._shadow_pillar_time and (now - inst._shadow_pillar_time) < cd then
        return false
    end
    
    local target = inst.components.combat and inst.components.combat.target
    if not target or not target:IsValid() then
        return false
    end
    
    if inst._on_book_action then
        return false
    end
    
    inst._shadow_pillar_time = now
    
    inst._on_book_action = function(inst)
        if target:IsValid() then
            local x, y, z = target.Transform:GetWorldPosition()
            local spell = SpawnPrefab("shadow_pillar_spell")
            if spell then
                local platform = TheWorld.Map:GetPlatformAtPoint(x, z)
                if platform ~= nil then
                    spell.entity:SetParent(platform.entity)
                    spell.Transform:SetPosition(platform.entity:WorldToLocalSpace(x, y, z))
                else
                    spell.Transform:SetPosition(x, y, z)
                end
                spell.caster = inst
            end

            local function DispelFriendlyNPCs()
                local ents = TheSim:FindEntities(x, 0, z, 6, nil, nil, { "npcfriend", "npcfriend_companion" })
                for _, ent in ipairs(ents) do
                    if ent ~= target and ent:IsValid() then
                        ent:PushEvent("dispell_shadow_pillars")
                    end
                end
            end
            for i = 1, 6 do
                inst:DoTaskInTime(0.25 * i, DispelFriendlyNPCs)
            end
        end
        
        if inst.components.talker then
            local speech = NPC_SPEECH and NPC_SPEECH.SHADOW_PILLAR
            if speech then
                local line = speech[math.random(#speech)]
                inst.components.talker:Say(line, nil, nil, true)
            end
        end
        
        CombatLog("[Waxwell] 释放暗影支柱!")
        inst._on_book_action = nil
    end
    
    if inst.sg then
        inst.sg:GoToState("npc_book")
    else
        inst._on_book_action(inst)
    end
    
    return true
end

local function CombatPillarCheck(inst)
    if inst._is_ghost_mode then return end
    if not inst._shadow_summon_enabled then return end
    if inst.components.combat and inst.components.combat:HasTarget() then
        CastShadowPillars(inst)
    end
end

local function OnKiteReengage(inst)
    CombatPillarCheck(inst)
end

-- ══════════════════════════════════
-- 暗影工人召唤系统（挖矿辅助）
-- ══════════════════════════════════

local function CleanupWorkers(inst)
    if not inst._shadow_workers then
        inst._shadow_workers = {}
    end
    local valid = {}
    for _, w in ipairs(inst._shadow_workers) do
        if w and w:IsValid() then
            table.insert(valid, w)
        end
    end
    inst._shadow_workers = valid
    return #valid
end

local function DismissShadowWorkers(inst)
    if inst._shadow_workers then
        for _, worker in ipairs(inst._shadow_workers) do
            if worker and worker:IsValid() then
                local fx = SpawnPrefab("statue_transition_2")
                if fx then
                    fx.Transform:SetPosition(worker.Transform:GetWorldPosition())
                end
                worker:Remove()
            end
        end
        inst._shadow_workers = {}
    end
end

local function SummonShadowWorker(inst)
    local now = GetTime()
    local cd = NPC_TUNING.SHADOW_WORKER_COOLDOWN or 180
    if inst._shadow_worker_summon_time and (now - inst._shadow_worker_summon_time) < cd then
        return false
    end

    CleanupWorkers(inst)
    if #inst._shadow_workers > 0 then
        return false
    end

    inst._shadow_worker_summon_time = now

    local function DoSummon(inst)
        local count = NPC_TUNING.SHADOW_WORKER_COUNT or 1
        local x, y, z = inst.Transform:GetWorldPosition()

        for i = 1, count do
            local worker = SpawnPrefab("npc_shadow_worker")
            if worker then
                local angle = (i - 1) * (2 * math.pi / count) + math.random() * 0.5
                worker.Transform:SetPosition(x + math.cos(angle) * 2, y, z + math.sin(angle) * 2)
                table.insert(inst._shadow_workers, worker)

                local leader = inst
                worker:DoTaskInTime(0, function()
                    if worker:IsValid() and leader:IsValid() then
                        if worker.SetLeader then
                            worker:SetLeader(leader)
                        end
                    end
                end)
            end
        end

        if inst.components.talker then
            local speech = NPC_SPEECH and NPC_SPEECH.SHADOW_SUMMON
            if speech then
                local line = speech[math.random(#speech)]
                inst.components.talker:Say(line, nil, nil, true)
            end
        end

        CombatLog("[Waxwell] 召唤了 " .. #inst._shadow_workers .. " 个暗影工人")
        inst._on_book_action = nil
    end

    if inst._on_book_action then
        return false
    end

    inst._on_book_action = DoSummon
    if inst.sg then
        inst.sg:GoToState("npc_book")
    else
        DoSummon(inst)
    end

    return true
end

local function FollowMineCheck(inst)
    if inst._is_ghost_mode then return end
    if not inst._shadow_summon_enabled then return end

    local leader = inst.components.follower and inst.components.follower:GetLeader()
    if not leader or not leader.sg then return end

    if leader.sg:HasStateTag("mining")
        or leader.sg:HasStateTag("chopping")
        or leader.sg:HasStateTag("digging") then
        CleanupWorkers(inst)
        if #inst._shadow_workers == 0 then
            SummonShadowWorker(inst)
        end
    end
end

local function OnAttacked(inst, data)
    if inst._is_ghost_mode then return end
    if not inst._shadow_summon_enabled then return end
    if data and data.attacker and data.attacker:IsValid()
       and not IsFriendlyTarget(data.attacker) then
        SummonShadowProtector(inst)
        if inst._shadow_protectors then
            for _, p in ipairs(inst._shadow_protectors) do
                if p:IsValid() and p.components.combat then
                    p.components.combat:SetTarget(data.attacker)
                end
            end
        end
    end
end

local function OnNewCombatTarget(inst, data)
    if inst._is_ghost_mode then return end
    if not inst._shadow_summon_enabled then return end
    if data and data.target and not IsFriendlyTarget(data.target) then
        SummonShadowProtector(inst)
        for _, p in ipairs(inst._shadow_protectors) do
            if p:IsValid() and p.components.combat then
                p.components.combat:SetTarget(data.target)
            end
        end
    end
end

local function OnDeath(inst)
    inst._on_book_action = nil
    if inst._combat_summon_task then
        inst._combat_summon_task:Cancel()
        inst._combat_summon_task = nil
    end
    if inst._combat_pillar_task then
        inst._combat_pillar_task:Cancel()
        inst._combat_pillar_task = nil
    end
    if inst._follow_mine_task then
        inst._follow_mine_task:Cancel()
        inst._follow_mine_task = nil
    end
    DismissShadowProtector(inst)
    DismissShadowWorkers(inst)
end

local function OnGhostMode(inst)
    inst._on_book_action = nil
    if inst._combat_summon_task then
        inst._combat_summon_task:Cancel()
        inst._combat_summon_task = nil
    end
    if inst._combat_pillar_task then
        inst._combat_pillar_task:Cancel()
        inst._combat_pillar_task = nil
    end
    if inst._follow_mine_task then
        inst._follow_mine_task:Cancel()
        inst._follow_mine_task = nil
    end
    DismissShadowProtector(inst)
    DismissShadowWorkers(inst)
end

local function SetupShadowSystem(inst)
    inst._shadow_protectors = {}   -- 保护者数组
    inst._shadow_protector = nil    -- 兼容旧存档
    inst._shadow_workers = {}      -- 工人数组
    inst._shadow_summon_time = nil
    inst._shadow_pillar_time = nil  -- 暗影支柱 CD
    inst._shadow_summon_enabled = true
    
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("enterghost", OnGhostMode)
    inst:ListenForEvent("npc_kite_reengage", OnKiteReengage)
    
    inst._combat_summon_task = inst:DoPeriodicTask(5, CombatSummonCheck)
    local pillar_poll = NPC_TUNING.SHADOW_PILLAR_POLL_INTERVAL or 8
    inst._combat_pillar_task = inst:DoPeriodicTask(pillar_poll, CombatPillarCheck)
    inst._follow_mine_task = inst:DoPeriodicTask(3, FollowMineCheck)
end

-- ══════════════════════════════════

return {
    on_apply = function(inst, stats)
        inst._is_waxwell = true
        
        if not inst._waxwell_systems_setup then
            inst._waxwell_systems_setup = true
            SetupShadowSystem(inst)
        end
    end,
    
    on_save = function(inst, data)
        if inst._shadow_summon_time then
            local cd = NPC_TUNING.SHADOW_PROTECTOR_COOLDOWN or 180
            local elapsed = GetTime() - inst._shadow_summon_time
            if elapsed < cd then
                data.shadow_cd_remaining = cd - elapsed
            end
        end
        if inst._shadow_pillar_time then
            local pillar_cd = NPC_TUNING.SHADOW_PILLAR_COOLDOWN or 30
            local elapsed = GetTime() - inst._shadow_pillar_time
            if elapsed < pillar_cd then
                data.pillar_cd_remaining = pillar_cd - elapsed
            end
        end
        if inst._shadow_worker_summon_time then
            local worker_cd = NPC_TUNING.SHADOW_WORKER_COOLDOWN or 180
            local elapsed = GetTime() - inst._shadow_worker_summon_time
            if elapsed < worker_cd then
                data.worker_cd_remaining = worker_cd - elapsed
            end
        end
    end,
    
    on_load = function(inst, data)
        if not inst._shadow_protectors then
            inst._shadow_protectors = {}
        end
        if inst._shadow_protector and inst._shadow_protector:IsValid() then
            table.insert(inst._shadow_protectors, inst._shadow_protector)
            inst._shadow_protector = nil
        end
        
        if data and data.shadow_cd_remaining then
            inst._shadow_summon_time = GetTime() - ((NPC_TUNING.SHADOW_PROTECTOR_COOLDOWN or 180) - data.shadow_cd_remaining)
        end
        if data and data.pillar_cd_remaining then
            inst._shadow_pillar_time = GetTime() - ((NPC_TUNING.SHADOW_PILLAR_COOLDOWN or 30) - data.pillar_cd_remaining)
        end
        if data and data.worker_cd_remaining then
            inst._shadow_worker_summon_time = GetTime() - ((NPC_TUNING.SHADOW_WORKER_COOLDOWN or 180) - data.worker_cd_remaining)
        end
    end,
}
