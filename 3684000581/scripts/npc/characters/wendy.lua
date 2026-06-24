-- scripts/npc/characters/wendy.lua

local NPC_SPEECH = require("npc_speech")

-- ────────────────────────────────────────────────────────────
-- 启用永久激怒状态（Aura光环 + 视觉效果）
-- ────────────────────────────────────────────────────────────
local function EnablePermanentRage(abigail)
    if not abigail:IsValid() then return end

    abigail.attack_level = abigail.attack_level or 3

    abigail.is_defensive = false

    if abigail.components.aura then
        abigail.components.aura:Enable(true)

        local exclude = abigail.components.aura.auraexcludetags or {}
        local friendly_exclude_tags = { "npcfriend", "companion", "npcfriend_companion", "npc_bernie" }
        for _, friendly_tag in ipairs(friendly_exclude_tags) do
            local has_tag = false
            for _, tag in ipairs(exclude) do
                if tag == friendly_tag then
                    has_tag = true
                    break
                end
            end
            if not has_tag then
                table.insert(exclude, friendly_tag)
            end
        end
        abigail.components.aura.auraexcludetags = exclude

        function abigail.components.aura:OnTick()
            if self.pretickfn then
                self.pretickfn(self.inst)
            end
            if self.inst.components.combat then
                self.inst.components.combat:DoAreaAttack(
                    self.inst, self.radius, nil,
                    self.auratestfn and self._fn or nil,
                    nil, self.auraexcludetags
                )
            end
            if not self.applying then
                self.inst:PushEvent("startaura")
                self.applying = true
            end
        end

        local aura = abigail.components.aura
        local _orig_Enable = aura.Enable
        function aura:Enable(val)
            if val == false then
                return
            end
            _orig_Enable(self, val)
        end

        abigail.components.aura.applying = true
        abigail:PushEvent("startaura")
    end
end

-- ────────────────────────────────────────────────────────────
-- 说台词工具函数
-- ────────────────────────────────────────────────────────────
local function SayRandomLine(inst, category)
    if not inst.components.talker then return end
    local lines = category and category.wendy
    if lines and #lines > 0 then
        inst.components.talker:Say(lines[math.random(#lines)])
    end
end

-- ────────────────────────────────────────────────────────────
-- 实际执行召唤阿比盖尔的逻辑（由状态图动画回调调用）
-- ────────────────────────────────────────────────────────────
local function DoSpawnAbigail(inst)
    if inst._abigail and inst._abigail:IsValid() then return end
    
    local x, y, z = inst.Transform:GetWorldPosition()
    local abigail = SpawnPrefab("abigail")
    if abigail then
        abigail.Transform:SetPosition(x, y, z)
        abigail.persists = false  -- 不保存到存档
        
        abigail._playerlink = inst
        
        if abigail.components.follower then
            abigail.components.follower:SetLeader(inst)
        end
        
        abigail:AddTag("notarget")    -- 不可被锁定为目标
        abigail:AddTag("noattack")    -- 不可被攻击
        abigail:AddTag("NOCLICK")     -- 不可被点击
        
        if abigail.components.health then
            abigail.components.health:SetInvincible(true)
            local orig_DoDelta = abigail.components.health.DoDelta
            abigail.components.health.DoDelta = function(self, amount, ...)
                local result = orig_DoDelta(self, amount, ...)
                if self.currenthealth < 1 then
                    self.currenthealth = 1
                end
                return result
            end
        end
        
        inst._abigail = abigail
        
        if abigail.sg then
            abigail.sg:GoToState("appear")
        end
        
        abigail:DoTaskInTime(1.5, function()
            EnablePermanentRage(abigail)
        end)
        
        inst:ListenForEvent("onremove", function()
            if inst._abigail == abigail then
                inst._abigail = nil
            end
        end, abigail)

        SayRandomLine(inst, NPC_SPEECH.SUMMON_ABIGAIL)
        
        if inst.components.combat and inst.components.combat.target then
            abigail:DoTaskInTime(0.5, function()
                if abigail:IsValid() and abigail.components.combat 
                   and inst:IsValid() and inst.components.combat and inst.components.combat.target then
                    abigail.components.combat:SetTarget(inst.components.combat.target)
                end
            end)
        end
    end
end

-- ────────────────────────────────────────────────────────────
-- 召唤阿比盖尔（战斗时）- 先播放动画，在动画回调中实际spawn
-- ────────────────────────────────────────────────────────────
local function SummonAbigail(inst)
    if inst._abigail and inst._abigail:IsValid() then return end
    if inst._is_ghost_mode then return end
    if inst._abigail_cd then return end  -- 冷却中
    
    inst._abigail_cd = true
    inst:DoTaskInTime(3, function() inst._abigail_cd = nil end)
    
    inst._summon_abigail_fn = function(i)
        if i._abigail and i._abigail:IsValid() then return end
        if i._is_ghost_mode then return end
        DoSpawnAbigail(i)
        i._abigail_deployed = true
        i._summon_abigail_fn = nil
    end
    
    if inst.sg then
        inst.sg:GoToState("npc_summon_abigail")
    else
        DoSpawnAbigail(inst)
        inst._abigail_deployed = true
        inst._summon_abigail_fn = nil
    end
end

-- ────────────────────────────────────────────────────────────
-- 实际执行收回阿比盖尔的逻辑（由状态图动画回调调用）
-- ────────────────────────────────────────────────────────────
local function DoDismissAbigail(inst)
    if not inst._abigail or not inst._abigail:IsValid() then
        inst._abigail = nil
        return
    end
    
    SayRandomLine(inst, NPC_SPEECH.UNSUMMON_ABIGAIL)
    
    local abigail = inst._abigail
    inst._abigail = nil  -- 先清引用防止重复操作
    
    if abigail.components.combat then
        abigail.components.combat:SetTarget(nil)
    end
    
    if abigail.sg then
        abigail.sg:GoToState("dissipate")
        abigail:DoTaskInTime(1.5, function()
            if abigail:IsValid() then
                abigail:Remove()
            end
        end)
    else
        abigail:Remove()
    end
end

-- ────────────────────────────────────────────────────────────
-- 收起阿比盖尔（脱离战斗后）- 先播放动画，在动画回调中实际收回
-- ────────────────────────────────────────────────────────────
local function DismissAbigail(inst)
    if not inst._abigail or not inst._abigail:IsValid() then
        inst._abigail = nil
        inst._abigail_deployed = false
        return
    end
    if inst._abigail_cd then return end
    
    inst._abigail_cd = true
    inst:DoTaskInTime(3, function() inst._abigail_cd = nil end)
    
    inst._unsummon_abigail_fn = function(i)
        DoDismissAbigail(i)
        i._abigail_deployed = false
        i._unsummon_abigail_fn = nil
    end
    
    if inst.sg then
        inst.sg:GoToState("npc_unsummon_abigail")
    else
        DoDismissAbigail(inst)
        inst._abigail_deployed = false
        inst._unsummon_abigail_fn = nil
    end
end

-- ────────────────────────────────────────────────────────────
-- 强制移除阿比盖尔（死亡时播放消散动画）
-- ────────────────────────────────────────────────────────────
local function ForceRemoveAbigail(inst)
    inst._abigail_deployed = false
    
    if inst._abigail and inst._abigail:IsValid() then
        local abigail = inst._abigail
        inst._abigail = nil
        
        if abigail.components.combat then
            abigail.components.combat:SetTarget(nil)
        end
        
        if abigail.sg then
            abigail.sg:GoToState("dissipate")
            abigail:DoTaskInTime(1.5, function()
                if abigail:IsValid() then
                    abigail:Remove()
                end
            end)
        else
            abigail:Remove()
        end
    else
        inst._abigail = nil
    end
end

-- ────────────────────────────────────────────────────────────
-- 配置阿比盖尔实体（加载时静默召唤用）
-- ────────────────────────────────────────────────────────────
local function ConfigureAbigail(inst, abigail)
    abigail.persists = false
    abigail._playerlink = inst
    
    if abigail.components.follower then
        abigail.components.follower:SetLeader(inst)
    end
    
    abigail:AddTag("notarget")
    abigail:AddTag("noattack")
    abigail:AddTag("NOCLICK")
    
    if abigail.components.health then
        abigail.components.health:SetInvincible(true)
        local orig_DoDelta = abigail.components.health.DoDelta
        abigail.components.health.DoDelta = function(self, amount, ...)
            local result = orig_DoDelta(self, amount, ...)
            if self.currenthealth < 1 then
                self.currenthealth = 1
            end
            return result
        end
    end
    
    inst._abigail = abigail
    
    inst:ListenForEvent("onremove", function()
        if inst._abigail == abigail then
            inst._abigail = nil
        end
    end, abigail)
    
    abigail:DoTaskInTime(0, function()
        EnablePermanentRage(abigail)
    end)
end

-- ────────────────────────────────────────────────────────────
-- 导出角色模块钩子
-- ────────────────────────────────────────────────────────────
return {
    on_apply = function(inst, stats)
        inst._abigail = nil
        inst._abigail_cd = nil
        inst._abigail_deployed = false  
        
        if not inst.components.ghostlybond then
            inst.components.ghostlybond = {
                bondlevel = 3,
                ghost = nil,
                SummonComplete = function() end,
                RecallComplete = function() end,
                Recall = function() end,
            }
        end
        
        inst:ListenForEvent("newcombattarget", function(i, data)
            if not i._is_ghost_mode and data and data.target then
                if not i._abigail_deployed then
                    SummonAbigail(i)
                end
                if i._abigail and i._abigail:IsValid() and i._abigail.components.combat then
                    i._abigail.components.combat:SetTarget(data.target)
                end
            end
        end)
        
        inst:ListenForEvent("attacked", function(i, data)
            if not i._is_ghost_mode and data and data.attacker then
                if not i._abigail_deployed then
                    SummonAbigail(i)
                end
                if i._abigail and i._abigail:IsValid() and i._abigail.components.combat then
                    local target = (i.components.combat and i.components.combat.target) or data.attacker
                    if target and target:IsValid() and not target:HasTag("player") then
                        i._abigail.components.combat:SetTarget(target)
                    end
                end
            end
        end)
        
        inst._abigail_sync_task = inst:DoPeriodicTask(1, function(i)
            if i._abigail and i._abigail:IsValid() and i._abigail.components.combat then
                if i.components.combat and i.components.combat.target then
                    local target = i.components.combat.target
                    if not i._abigail.components.combat.target 
                       or i._abigail.components.combat.target ~= target then
                        i._abigail.components.combat:SetTarget(target)
                    end
                end
            end
        end)
        
        inst._combat_version = 0
        
        local function TryDismissAbigail(i, saved_version)
            i:DoTaskInTime(5, function()
                if not i:IsValid() or i._is_ghost_mode then return end
                if i._combat_version ~= saved_version then return end
                if i.components.combat and i.components.combat.target then return end
                if not i._abigail_deployed then return end
                if not i._abigail or not i._abigail:IsValid() then
                    i._abigail_deployed = false
                    return
                end
                DismissAbigail(i)
            end)
        end
        
        inst:ListenForEvent("droppedtarget", function(i, data)
            TryDismissAbigail(i, i._combat_version)
        end)
        
        inst:ListenForEvent("giveuptarget", function(i, data)
            TryDismissAbigail(i, i._combat_version)
        end)
        
        inst:ListenForEvent("newcombattarget", function(i, data)
            i._combat_version = (i._combat_version or 0) + 1
        end)
       inst:ListenForEvent("attacked", function(i, data)
            i._combat_version = (i._combat_version or 0) + 1
        end)
        
        inst:ListenForEvent("npc_pre_migration", function(i)
            if i._abigail_sync_task then
                i._abigail_sync_task:Cancel()
                i._abigail_sync_task = nil
            end
            if i._abigail and i._abigail:IsValid() then
                local abigail = i._abigail
                i._abigail = nil
                if abigail.components.combat then
                    abigail.components.combat:SetTarget(nil)
                end
                abigail:Remove()
            end
        end)
    end,
    
    on_death = function(inst)
        if inst._abigail_sync_task then
            inst._abigail_sync_task:Cancel()
            inst._abigail_sync_task = nil
        end
        ForceRemoveAbigail(inst)
        return false
    end,
    
    on_save = function(inst, data)
        if inst._abigail_deployed then
            data.abigail_deployed = true
        end
    end,
    
    on_load = function(inst, data)
        if data and data.is_abigail_mode then
            inst:DoTaskInTime(0.5, function()
                if inst:IsValid() and inst.components.health then
                    inst.components.health.currenthealth = inst.components.health.maxhealth
                    inst:PushEvent("healthdelta", {
                        oldpercent = 0,
                        newpercent = 1,
                    })
                end
            end)
        end
        
        local should_deploy = (data and data.abigail_deployed) or (data and data.has_abigail)
        if should_deploy then
            inst:DoTaskInTime(1, function()
                if inst:IsValid() and not inst._is_ghost_mode then
                    inst._abigail_deployed = true
                    if not inst._abigail or not inst._abigail:IsValid() then
                        local x, y, z = inst.Transform:GetWorldPosition()
                        local abigail = SpawnPrefab("abigail")
                        if abigail then
                            abigail.Transform:SetPosition(x, y, z)
                            ConfigureAbigail(inst, abigail)
                        end
                    end
                    inst:DoTaskInTime(5, function()
                        if inst:IsValid() and not inst._is_ghost_mode
                           and inst._abigail_deployed
                           and (not inst.components.combat or not inst.components.combat.target)
                           and inst._abigail and inst._abigail:IsValid() then
                            DismissAbigail(inst)
                        end
                    end)
                end
            end)
        end
    end,
}
