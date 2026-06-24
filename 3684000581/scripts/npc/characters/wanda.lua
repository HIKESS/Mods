-- scripts/npc/characters/wanda.lua
-- Wanda: 时间制生命（oldager）+ 三年龄状态 + 年龄差异伤害


local NPC_TUNING = require("npc_tuning")
local npc_utils = require("npc/npc_utils")

local UpdateHoverInfo = npc_utils.UpdateHoverInfo
local UpdateAgeStateFromHealth

local function ReapplyWandaOverrides(inst)
    if inst == nil or inst.AnimState == nil then
        return
    end
    inst.AnimState:AddOverrideBuild("wanda_basics")
    inst.AnimState:AddOverrideBuild("wanda_attack")
    inst.AnimState:AddOverrideBuild("wanda_casting")
    inst.AnimState:AddOverrideBuild("player_idles_wanda")
end

local function EnsureWandaWatch(inst, equip_now)
    if not (inst and inst.components and inst.components.inventory) then
        return nil
    end
    local inv = inst.components.inventory
    local watch = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if not (watch and watch.prefab == "pocketwatch_weapon") then
        watch = nil
        for i = 1, inv.maxslots do
            local item = inv:GetItemInSlot(i)
            if item and item.prefab == "pocketwatch_weapon" then
                watch = item
                break
            end
        end
    end

    if watch == nil then
        watch = SpawnPrefab("pocketwatch_weapon")
        if watch ~= nil then
            inv:GiveItem(watch)
        end
    end

    if watch and watch.components and watch.components.fueled then
        watch.components.fueled:SetPercent(1)
    end
    if equip_now and watch ~= nil then
        inv:Equip(watch)
    end
    return watch
end

local function EnsureWandaHealWatch(inst)
    if not (inst and inst.components and inst.components.inventory) then
        return nil
    end
    local inv = inst.components.inventory
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and item.prefab == "pocketwatch_heal" then
            return item
        end
    end
    local item = SpawnPrefab("pocketwatch_heal")
    if item ~= nil then
        inv:GiveItem(item)
    end
    return item
end

local function MarkWandaPocketwatchUntakeable(inst)
    if not (inst and inst.components and inst.components.inventory) then
        return
    end
    local untakeable_cfg = NPC_TUNING.UNTAKEABLE_NPC_TOOLS
        and NPC_TUNING.UNTAKEABLE_NPC_TOOLS.wanda
        or nil
    local protect_watch = false
    if untakeable_cfg then
        for _, prefab in ipairs(untakeable_cfg) do
            if prefab == "pocketwatch_weapon" then
                protect_watch = true
                break
            end
        end
    end
    local inv = inst.components.inventory
    local function MarkItem(item)
        if item and item.prefab == "pocketwatch_weapon" then
            if protect_watch then
                item._npc_initial_tool = true
                if not item:HasTag("_npc_untakeable") then
                    item:AddTag("_npc_untakeable")
                end
            elseif item:HasTag("_npc_untakeable") then
                item:RemoveTag("_npc_untakeable")
            end
        end
    end
    for i = 1, inv.maxslots do
        MarkItem(inv:GetItemInSlot(i))
    end
    MarkItem(inv:GetEquippedItem(EQUIPSLOTS.HANDS))
end

local function SafeSetBuild(inst, wanted, fallback)
    fallback = fallback or NPC_TUNING.WANDA_BUILD_NORMAL or "wanda_NPC"
    if inst.AnimState == nil then
        return
    end
    if wanted ~= nil and wanted ~= "" then
        inst.AnimState:SetBuild(wanted)
        if inst.AnimState.GetBuild == nil or inst.AnimState:GetBuild() == wanted then
            return
        end
    end
    inst.AnimState:SetBuild(fallback)
end

local function GetAgeDamageMult(inst, weapon)
    local is_shadow = weapon ~= nil and weapon:HasTag("shadow_item")
    local state = inst._wanda_age_state or "normal"

    if is_shadow then
        if state == "old" then return NPC_TUNING.WANDA_SHADOW_DAMAGE_OLD or 1.75 end
        if state == "young" then return NPC_TUNING.WANDA_SHADOW_DAMAGE_YOUNG or 1 end
        return NPC_TUNING.WANDA_SHADOW_DAMAGE_NORMAL or 1.2
    end

    if state == "old" then return NPC_TUNING.WANDA_REGULAR_DAMAGE_OLD or 0.5 end
    if state == "young" then return NPC_TUNING.WANDA_REGULAR_DAMAGE_YOUNG or 1 end
    return NPC_TUNING.WANDA_REGULAR_DAMAGE_NORMAL or 1
end

local function GetCurrentAgeYears(inst)
    if inst == nil or inst.components.health == nil then
        return NPC_TUNING.WANDA_MIN_YEARS_OLD or 20
    end
    local min_age = NPC_TUNING.WANDA_MIN_YEARS_OLD or 20
    local max_age = NPC_TUNING.WANDA_MAX_YEARS_OLD or 80
    local pct = inst.components.health:GetPercent()
    local age = max_age - (max_age - min_age) * pct
    return age
end

local function YearsToHealthDelta(years)
    local min_age = NPC_TUNING.WANDA_MIN_YEARS_OLD or 20
    local max_age = NPC_TUNING.WANDA_MAX_YEARS_OLD or 80
    local span = math.max(1, max_age - min_age)
    local max_health = (NPC_TUNING.CHARACTER_STATS and NPC_TUNING.CHARACTER_STATS.wanda and NPC_TUNING.CHARACTER_STATS.wanda.max_health) or 60
    return years * (max_health / span)
end

local function ApplyRejuvenate(inst)
    if inst == nil or not inst:IsValid() or inst._is_ghost_mode then
        return
    end
    if inst.components.health == nil or inst.components.health:IsDead() then
        return
    end
    local years = NPC_TUNING.WANDA_REJUVENATE_RECOVER_YEARS or 40
    local hp_delta = YearsToHealthDelta(years)
    if hp_delta <= 0 then
        return
    end
    local h = inst.components.health
    local old_redirect = h.redirect
    local old_canheal = h.canheal
    h.redirect = nil
    h.canheal = true
    h:DoDelta(hp_delta, false, "npc_wanda_rejuvenate")
    h.canheal = old_canheal
    h.redirect = old_redirect

    UpdateAgeStateFromHealth(inst, inst._wanda_in_rejuvenate_cast == true)
end

UpdateAgeStateFromHealth = function(inst, silent)
    if inst == nil or not inst:IsValid() or inst._is_ghost_mode then
        return
    end
    if inst._wanda_reviving then
        return
    end
    if inst.sg ~= nil and inst.sg.currentstate ~= nil then
        local s = inst.sg.currentstate.name
        if s == "revive_from_ghost" or s == "death" or s == "ghost_idle" then
            return
        end
    end
    if inst.AnimState ~= nil then
        inst.AnimState:SetBank("wilson")
    end

    if inst.components.health == nil or inst.components.health:IsDead() then
        return
    end

    local hp = inst.components.health:GetPercent()
    local old_th = NPC_TUNING.WANDA_AGE_THRESHOLD_OLD or 0.25
    local young_th = NPC_TUNING.WANDA_AGE_THRESHOLD_YOUNG or 0.75

    local new_state = "normal"
    if hp <= old_th then
        new_state = "old"
    elseif hp >= young_th then
        new_state = "young"
    end

    local old_state = inst._wanda_age_state
    local state_changed = (old_state ~= new_state)
    inst._wanda_age_state = new_state
    inst.age_state = new_state

    -- 三年龄外观（独立于玩家 Wanda）
    if new_state == "old" then
        SafeSetBuild(inst, NPC_TUNING.WANDA_BUILD_OLD or "wanda_old", NPC_TUNING.WANDA_BUILD_NORMAL or "wanda")
        ReapplyWandaOverrides(inst)  -- SetBuild 会重置 OverrideBuild 栈，必须立即重加
        inst.talksoundoverride = "wanda2/characters/wanda/talk_old_LP"
        inst:AddTag("slowbuilder")
        if inst.components.inventory then
            inst.components.inventory.noheavylifting = true
        end
    elseif new_state == "young" then
        SafeSetBuild(inst, NPC_TUNING.WANDA_BUILD_YOUNG or "wanda_young", NPC_TUNING.WANDA_BUILD_NORMAL or "wanda")
        ReapplyWandaOverrides(inst)  -- SetBuild 会重置 OverrideBuild 栈，必须立即重加
        inst.talksoundoverride = "wanda2/characters/wanda/talk_young_LP"
        inst:RemoveTag("slowbuilder")
        if inst.components.inventory then
            inst.components.inventory.noheavylifting = false
        end
    else
        SafeSetBuild(inst, NPC_TUNING.WANDA_BUILD_NORMAL or "wanda", "wanda")
        ReapplyWandaOverrides(inst)  -- SetBuild 会重置 OverrideBuild 栈，必须立即重加
        inst.talksoundoverride = nil
        inst:RemoveTag("slowbuilder")
        if inst.components.inventory then
            inst.components.inventory.noheavylifting = false
        end
    end

    -- 强制年龄切换动画（非静默）
    if not silent and state_changed and inst.sg ~= nil then
        if old_state == "old" and (new_state == "normal" or new_state == "young") then
            inst.sg:GoToState("becomeyounger_wanda")
        elseif old_state == "young" and (new_state == "normal" or new_state == "old") then
            inst.sg:GoToState("becomeolder_wanda")
        elseif old_state == "normal" and new_state == "old" then
            inst.sg:GoToState("becomeolder_wanda")
        elseif old_state == "normal" and new_state == "young" then
            inst.sg:GoToState("becomeyounger_wanda")
        end
    end

    UpdateHoverInfo(inst)
end

local function OnHealthDelta(inst)
    if inst._wanda_reviving then
        return
    end
    if inst.sg ~= nil and inst.sg.currentstate ~= nil then
        local s = inst.sg.currentstate.name
        if s == "revive_from_ghost" or s == "death" or s == "ghost_idle" then
            return
        end
    end
    UpdateAgeStateFromHealth(inst, false)
end

local function RedirectToOldager(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    return inst.components.oldager ~= nil
        and inst.components.oldager:OnTakeDamage(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
end

return {
    on_apply = function(inst, stats)
        inst._is_wanda = true
        inst:AddTag("clockmaker")
        inst:AddTag("pocketwatchcaster")
        inst:AddTag("health_as_oldage")
        inst.customidleanim = "idle_wanda"

        if inst.AnimState ~= nil then
            ReapplyWandaOverrides(inst)
        end
        inst._wanda_reapply_overrides = ReapplyWandaOverrides
        inst._wanda_ensure_watch = function(i, equip_now)
            return EnsureWandaWatch(i, equip_now)
        end
        inst._wanda_ensure_heal_watch = function(i)
            return EnsureWandaHealWatch(i)
        end

        if inst.components.oldager == nil then
            inst:AddComponent("oldager")
        end
        inst.components.oldager.base_rate = NPC_TUNING.WANDA_OLDAGER_BASE_RATE or (1 / 40)

        local valid_heal_causes = NPC_TUNING.WANDA_VALID_HEAL_CAUSES or { "pocketwatch_heal", "debug_key" }
        for _, cause in ipairs(valid_heal_causes) do
            inst.components.oldager:AddValidHealingCause(cause)
        end

        if inst.components.health ~= nil then
            inst.components.health.redirect = RedirectToOldager
            inst.components.health.canheal = false
            inst.components.health.disable_penalty = true
        end

        if inst.components.combat ~= nil then
            local base_fn = inst.components.combat.customdamagemultfn
            inst.components.combat.customdamagemultfn = function(i, target, weapon, multiplier, mount)
                local base_mult = base_fn ~= nil and base_fn(i, target, weapon, multiplier, mount) or 1
                return base_mult * GetAgeDamageMult(i, weapon)
            end
        end

        if not inst._wanda_health_listener_added then
            inst._wanda_health_listener_added = true
            inst:ListenForEvent("healthdelta", OnHealthDelta)
            inst:ListenForEvent("wanda_rejuvenate_apply", function(i)
                ApplyRejuvenate(i)
            end)
            inst:ListenForEvent("wanda_refresh_age_visual", function(i)
                UpdateAgeStateFromHealth(i, true)
            end)
        end

        if not inst._wanda_initialized then
            inst._wanda_initialized = true
            if inst.components.health ~= nil then
                inst.components.health:SetPercent(NPC_TUNING.WANDA_START_HEALTH_PERCENT or 0.70)
            end
        end

        UpdateAgeStateFromHealth(inst, true)
        if inst._wanda_age_sync_task == nil then
            inst._wanda_age_sync_task = inst:DoPeriodicTask(1, function(i)
                if i._wanda_reviving then
                    return
                end
                if i.sg ~= nil and i.sg.currentstate ~= nil then
                    local s = i.sg.currentstate.name
                    if s == "revive_from_ghost" or s == "death" or s == "ghost_idle" then
                        return
                    end
                end
                UpdateAgeStateFromHealth(i, false)
            end)
        end
        inst:DoTaskInTime(0, function(i)
            MarkWandaPocketwatchUntakeable(i)
        end)
        if inst._wanda_rejuvenate_task ~= nil then
            inst._wanda_rejuvenate_task:Cancel()
            inst._wanda_rejuvenate_task = nil
        end
    end,

    on_save = function(inst, data)
        data.wanda_age_state = inst._wanda_age_state
        if inst.components.health ~= nil then
            data.wanda_health_percent = inst.components.health:GetPercent()
        end
        if inst._wanda_rejuvenate_next_time ~= nil then
            data.wanda_rejuvenate_cd_remaining = math.max(0, inst._wanda_rejuvenate_next_time - GetTime())
        end
    end,

    on_load = function(inst, data)
        if data ~= nil and data.wanda_rejuvenate_cd_remaining ~= nil then
            inst._wanda_rejuvenate_next_time = GetTime() + math.max(0, data.wanda_rejuvenate_cd_remaining)
        end
        inst:DoTaskInTime(0, function()
            if not inst:IsValid() or inst._is_ghost_mode or inst.components.health == nil then
                return
            end
            if data ~= nil and data.wanda_health_percent ~= nil then
                inst.components.health:SetPercent(data.wanda_health_percent)
            end
            EnsureWandaWatch(inst, false)
            EnsureWandaHealWatch(inst)
            UpdateAgeStateFromHealth(inst, true)
            MarkWandaPocketwatchUntakeable(inst)
        end)
    end,
}
