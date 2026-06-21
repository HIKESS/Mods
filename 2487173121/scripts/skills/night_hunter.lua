local KodiUtils = require("kodi_utils")
local NightHunter = {}
NightHunter.OnMarkRemovedCallback = nil
NightHunter.OnLeapCooldownCallback = nil
NightHunter.LEAP_MULT_DAY = TUNING.KODI_NIGHT_HUNTER_LEAP_MULT_DAY
NightHunter.LEAP_MULT_NIGHT = TUNING.KODI_NIGHT_HUNTER_LEAP_MULT_NIGHT
NightHunter.LEAP_RANGE_DAY = TUNING.KODI_NIGHT_HUNTER_LEAP_RANGE_DAY
NightHunter.LEAP_RANGE_NIGHT = TUNING.KODI_NIGHT_HUNTER_LEAP_RANGE_NIGHT
NightHunter.CHASE_SPEED = TUNING.KODI_NIGHT_HUNTER_CHASE_SPEED
NightHunter.MARK_DURATION = TUNING.KODI_NIGHT_HUNTER_MARK_DURATION
NightHunter.MAX_MARKS = TUNING.KODI_NIGHT_HUNTER_MAX_MARKS
NightHunter.LINKED_DAMAGE = TUNING.KODI_NIGHT_HUNTER_LINKED_DAMAGE
NightHunter.LEAP_COOLDOWN = TUNING.KODI_NIGHT_HUNTER_LEAP_COOLDOWN
NightHunter.VISION_ENERGY_DRAIN = TUNING.KODI_NIGHT_HUNTER_VISION_ENERGY_DRAIN
NightHunter.VISION_SANITY_DRAIN = TUNING.KODI_NIGHT_HUNTER_VISION_SANITY_DRAIN
NightHunter.COLOURCUBES = {
    day = "images/colour_cubes/purple_moon_cc.tex",
    dusk = "images/colour_cubes/purple_moon_cc.tex",
    night = "images/colour_cubes/purple_moon_cc.tex",
    full_moon = "images/colour_cubes/purple_moon_cc.tex",
}
function NightHunter.CanUseVision(inst)
    if not inst:HasTag("kodi_night_hunter") then return false end
    if inst:HasTag("NotDemon") then return true end
    if inst.components.inventory then
        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if hat and hat.prefab == "kitsune_mask" then
            return true
        end
    end
    return false
end
function NightHunter.ToggleVision(inst)
    if not inst:HasTag("kodi_night_hunter") then return false end
    if not NightHunter.CanUseVision(inst) then
        if inst.components.talker then
            inst.components.talker:Say("*Night vision needs the Kitsune mask in demon form*", 2, true)
        end
        return false
    end
    local is_night = KodiUtils.IsNight()
    local is_cave = KodiUtils.IsCave()
    if not (is_night or is_cave) then
        KodiUtils.CallComponent(inst, "talker", "Say", "*Night vision only works at night or in caves*", 2, true)
        return false
    end
    inst._night_hunter_vision_enabled = not inst._night_hunter_vision_enabled
    NightHunter.UpdateVision(inst)
    if inst._night_hunter_vision_enabled then
        if inst.components.talker then
            inst.components.talker:Say("*Night vision activated*", 1.5, true)
        end
    else
        if inst.components.talker then
            inst.components.talker:Say("*Night vision deactivated*", 1.5, true)
        end
    end
    return true
end
function NightHunter.ApplyVisionCosts(inst)
    if not inst._night_hunter_vision_active then return end
    if not NightHunter.CanUseVision(inst) then
        inst._night_hunter_vision_enabled = false
        NightHunter.UpdateVision(inst)
        if inst.components.talker then
            inst.components.talker:Say("*Night vision deactivated*", 1.5, true)
        end
        return
    end
    if inst.demonic_energy then
        inst.demonic_energy = math.max(0, inst.demonic_energy - NightHunter.VISION_ENERGY_DRAIN)
        if inst.UpdateDemonicNetvar then
            inst:UpdateDemonicNetvar()
        end
        inst:PushEvent("demonic_energy_changed", {percent = inst:GetDemonicPercent()})
    end
    if inst.components.sanity then
        inst.components.sanity:DoDelta(-NightHunter.VISION_SANITY_DRAIN / 60)
    end
    local energy = inst.demonic_energy or 0
    if energy <= 0 then
        inst._night_hunter_vision_enabled = false
        NightHunter.UpdateVision(inst)
        if inst.components.talker then
            inst.components.talker:Say("*Night vision depleted*", 1.5, true)
        end
    end
end
function NightHunter.GetNightVisionTimeRemaining(inst)
    if not inst._night_hunter_vision_active then return 0 end
    local energy = inst.demonic_energy or 0
    return energy / NightHunter.VISION_ENERGY_DRAIN
end
function NightHunter.UpdateVision(inst)
    local can_use = NightHunter.CanUseVision(inst)
    local is_night = KodiUtils.IsNight()
    local is_cave = KodiUtils.IsCave()
    local is_enabled = inst._night_hunter_vision_enabled
    local should_be_active = can_use and (is_night or is_cave) and is_enabled
    if should_be_active then
        if not inst._night_hunter_vision_active then
            inst:AddTag("kodi_night_vision_on")
            inst._night_hunter_vision_active = true
            if inst.components.playervision then
                inst.components.playervision:PushForcedNightVision(inst, 2, NightHunter.COLOURCUBES, false)
            end
            if not inst._night_hunter_vision_task then
                inst._night_hunter_vision_task = inst:DoPeriodicTask(1, function()
                    NightHunter.ApplyVisionCosts(inst)
                end)
            end
        end
    else
        if inst._night_hunter_vision_active then
            inst:RemoveTag("kodi_night_vision_on")
            inst._night_hunter_vision_active = false
            if inst.components.playervision then
                inst.components.playervision:PopForcedNightVision(inst)
            end
            if inst._night_hunter_vision_task then
                inst._night_hunter_vision_task:Cancel()
                inst._night_hunter_vision_task = nil
            end
        end
        if not (is_night or is_cave) or not can_use then
            inst._night_hunter_vision_enabled = false
        end
    end
end
local function RemoveMarkFromTarget(inst, target)
    if not target then return end
    local removed_index = nil
    for i, t in ipairs(inst._night_hunter_marked_targets) do
        if t == target then
            removed_index = i
            table.remove(inst._night_hunter_marked_targets, i)
            break
        end
    end
    if inst._night_hunter_mark_tasks[target] then
        inst._night_hunter_mark_tasks[target]:Cancel()
        inst._night_hunter_mark_tasks[target] = nil
    end
    if inst._night_hunter_mark_times then
        inst._night_hunter_mark_times[target] = nil
    end
    if removed_index and inst.RemoveNightHunterMark then
        inst:RemoveNightHunterMark(removed_index)
    end
    if target:IsValid() then
        target:RemoveTag("kodi_marked")
        if target._kodi_mark_indicator then
            if target._kodi_mark_indicator.PlayEndAnimation then
                target._kodi_mark_indicator:PlayEndAnimation()
            else
                target._kodi_mark_indicator:Remove()
            end
            target._kodi_mark_indicator = nil
        end
        if NightHunter.OnMarkRemovedCallback then
            NightHunter.OnMarkRemovedCallback(inst, target)
        end
    end
end
function NightHunter.ClearAllMarks(inst)
    for _, target in ipairs(inst._night_hunter_marked_targets or {}) do
        if target and target:IsValid() then
            target:RemoveTag("kodi_marked")
            if target._kodi_mark_indicator then
                if target._kodi_mark_indicator.PlayEndAnimation then
                    target._kodi_mark_indicator:PlayEndAnimation()
                else
                    target._kodi_mark_indicator:Remove()
                end
                target._kodi_mark_indicator = nil
            end
        end
    end
    for target, task in pairs(inst._night_hunter_mark_tasks or {}) do
        if task then task:Cancel() end
    end
    inst._night_hunter_marked_targets = {}
    inst._night_hunter_mark_tasks = {}
    inst._night_hunter_mark_times = {}
    if inst.ClearNightHunterMarksUI then
        inst:ClearNightHunterMarksUI()
    end
end
function NightHunter.MarkTarget(inst, target)
    if not inst:HasTag("kodi_night_hunter") then return false end
    if not inst:HasTag("NotDemon") then return false end
    if not target or not target:IsValid() then return false end
    local has_health = target.components.health ~= nil
    local is_dead = has_health and target.components.health:IsDead()
    if not has_health then return false end
    if is_dead then return false end
    inst._night_hunter_marked_targets = inst._night_hunter_marked_targets or {}
    inst._night_hunter_mark_tasks = inst._night_hunter_mark_tasks or {}
    for _, t in ipairs(inst._night_hunter_marked_targets) do
        if t == target then
            RemoveMarkFromTarget(inst, target)
            inst.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
            return true
        end
    end
    if #inst._night_hunter_marked_targets >= NightHunter.MAX_MARKS then
        RemoveMarkFromTarget(inst, inst._night_hunter_marked_targets[1])
    end
    table.insert(inst._night_hunter_marked_targets, target)
    target:AddTag("kodi_marked")
    local mark_ind = SpawnPrefab("mark_indicator")
    if mark_ind then
        mark_ind._follow_target = target
        mark_ind._follow_task = mark_ind:DoPeriodicTask(0, function()
            if not mark_ind._follow_target or not mark_ind._follow_target:IsValid() then
                if mark_ind._follow_task then
                    mark_ind._follow_task:Cancel()
                    mark_ind._follow_task = nil
                end
                if mark_ind:IsValid() then
                    mark_ind:Remove()
                end
                return
            end
            local tx, ty, tz = mark_ind._follow_target.Transform:GetWorldPosition()
            mark_ind.Transform:SetPosition(tx, ty + 3, tz)
        end)
        target._kodi_mark_indicator = mark_ind
    end
    inst:ListenForEvent("death", function() RemoveMarkFromTarget(inst, target) end, target)
    inst:ListenForEvent("entitysleep", function() RemoveMarkFromTarget(inst, target) end, target)
    inst:ListenForEvent("onremove", function() RemoveMarkFromTarget(inst, target) end, target)
    inst:ListenForEvent("onpickup", function() RemoveMarkFromTarget(inst, target) end, target)
    inst._night_hunter_mark_times = inst._night_hunter_mark_times or {}
    inst._night_hunter_mark_times[target] = GetTime()
    inst._night_hunter_mark_tasks[target] = inst:DoTaskInTime(NightHunter.MARK_DURATION, function()
        if target and target:IsValid() then
            RemoveMarkFromTarget(inst, target)
        end
    end)
    inst.SoundEmitter:PlaySound("dontstarve/HUD/research_available")
    local mark_count = #inst._night_hunter_marked_targets
    inst.components.talker:Say("*" .. mark_count .. "/" .. NightHunter.MAX_MARKS .. " marked*", 1.5, true)
    if inst.AddNightHunterMark then
        inst:AddNightHunterMark()
    end
    return true
end
function NightHunter.LeapToTarget(inst, specific_target)
    if not inst:HasTag("kodi_night_hunter") then return false end
    if not inst:HasTag("NotDemon") then return false end
    inst._night_hunter_marked_targets = inst._night_hunter_marked_targets or {}
    local cooldown_remaining = (inst._night_hunter_leap_cooldown or 0) - GetTime()
    if cooldown_remaining > 0 then
        inst.components.talker:Say("*" .. math.ceil(cooldown_remaining) .. "s*", 1, true)
        return false
    end
    local target = specific_target
    if not target or not target:IsValid() then
        for _, t in ipairs(inst._night_hunter_marked_targets) do
            if t and t:IsValid() and t.components.health and not t.components.health:IsDead() then
                target = t
                break
            end
        end
    end
    if not target or not target:IsValid() then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.NO_TARGET_MARKED or "*no target*", 2, true)
        return false
    end
    if not target:HasTag("kodi_marked") then
        inst.components.talker:Say("*not marked*", 1.5, true)
        return false
    end
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local px, py, pz = inst.Transform:GetWorldPosition()
    local dist = math.sqrt((tx - px)^2 + (tz - pz)^2)
    local is_night = KodiUtils.IsNightOrDusk()
    local max_range = is_night and NightHunter.LEAP_RANGE_NIGHT or NightHunter.LEAP_RANGE_DAY
    if dist > max_range then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.TARGET_TOO_FAR or "*too far*", 2, true)
        return false
    end
    inst._night_hunter_leap_cooldown = GetTime() + NightHunter.LEAP_COOLDOWN
    if inst.SetNightHunterLeapCooldown then
        inst:SetNightHunterLeapCooldown(NightHunter.LEAP_COOLDOWN)
    end
    if NightHunter.OnLeapCooldownCallback then
        NightHunter.OnLeapCooldownCallback(inst, NightHunter.LEAP_COOLDOWN)
    end
    local angle = math.atan2(tz - pz, tx - px)
    local offset = 1.5
    local new_x = tx - math.cos(angle) * offset
    local new_z = tz - math.sin(angle) * offset
    NightHunter.SpawnLeapStartEffects(inst, px, py, pz, new_x, new_z, dist)
    inst:Hide()
    inst:DoTaskInTime(0.2, function()
        if not inst:IsValid() then return end
        inst.Physics:Teleport(new_x, 0, new_z)
        inst:Show()
        NightHunter.SpawnLeapEndEffects(inst, new_x, new_z)
        if ThePlayer == inst then
            TheCamera:Shake(CAMERASHAKE.FULL, 0.2, 0.02, 0.15)
        end
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")
        if inst.components.combat and target:IsValid() then
            inst.components.combat:SetTarget(target)
            inst._night_hunter_leap_attack = true
            if inst.components.combat.CanAttack and inst.components.combat:CanAttack(target) then
                inst.components.combat:DoAttack(target)
            else
                local act = BufferedAction(inst, target, ACTIONS.ATTACK)
                if inst.components.locomotor then
                    inst.components.locomotor:PushAction(act, true)
                end
            end
            inst:DoTaskInTime(0.1, function()
                inst._night_hunter_leap_attack = nil
            end)
        end
    end)
    return true
end
function NightHunter.ApplyLinkedDamage(inst, source_target, damage)
    for _, target in ipairs(inst._night_hunter_marked_targets or {}) do
        if target ~= source_target and target:IsValid() and target.components.health then
            local linked_damage = damage * NightHunter.LINKED_DAMAGE
            local tx, ty, tz = target.Transform:GetWorldPosition()
            local fx_slash = SpawnPrefab("shadowstrike_slash_fx")
            if fx_slash then fx_slash.Transform:SetPosition(tx, ty, tz) end
            local fx_tendril = SpawnPrefab("shadow_despawn")
            if fx_tendril then fx_tendril.Transform:SetPosition(tx, ty + 0.5, tz) end
            local fx_puff = SpawnPrefab("shadow_puff_large_front")
            if fx_puff then fx_puff.Transform:SetPosition(tx, ty, tz) end
            local sx, sy, sz = source_target.Transform:GetWorldPosition()
            local fx_glob = SpawnPrefab("shadow_glob_fx")
            if fx_glob then
                fx_glob.Transform:SetPosition((sx + tx) / 2, 0.5, (sz + tz) / 2)
            end
            if inst.SoundEmitter then
                inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack", nil, 0.5)
            end
            target.components.health:DoDelta(-linked_damage)
        end
    end
end
function NightHunter.OnAttack(inst, data)
    if not inst:HasTag("kodi_night_hunter") or not data.target then return end
    local is_marked = false
    for _, t in ipairs(inst._night_hunter_marked_targets or {}) do
        if t == data.target then
            is_marked = true
            break
        end
    end
    if is_marked then
        local is_night = KodiUtils.IsNightOrDusk()
        local damage_mult = is_night and NightHunter.LEAP_MULT_NIGHT or NightHunter.LEAP_MULT_DAY
        local weapon = inst.components.combat:GetWeapon()
        local base_damage = inst.components.combat:CalcDamage(data.target, weapon)
        local bonus_damage = base_damage * (damage_mult - 1)
        if data.target.components.health and bonus_damage > 0 then
            data.target.components.health:DoDelta(-bonus_damage)
        end
        local x, y, z = data.target.Transform:GetWorldPosition()
        local fx = SpawnPrefab("shadowstrike_slash_fx")
        if fx then fx.Transform:SetPosition(x, y, z) end
        inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
        NightHunter.ApplyLinkedDamage(inst, data.target, base_damage + bonus_damage)
    end
end
function NightHunter.SpawnLeapStartEffects(inst, px, py, pz, new_x, new_z, dist)
    inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
    local fx_teleport = SpawnPrefab("shadow_teleport_out")
    if fx_teleport then fx_teleport.Transform:SetPosition(px, py, pz) end
    local fx_despawn = SpawnPrefab("shadow_despawn")
    if fx_despawn then fx_despawn.Transform:SetPosition(px, py, pz) end
    local trail_steps = math.floor(dist / 2)
    for i = 1, trail_steps do
        local t = i / trail_steps
        local trail_x = px + (new_x - px) * t
        local trail_z = pz + (new_z - pz) * t
        inst:DoTaskInTime(0.02 * i, function()
            local trail_fx = SpawnPrefab("shadow_glob_fx")
            if trail_fx then
                trail_fx.Transform:SetPosition(trail_x, 0.5, trail_z)
            end
        end)
    end
end
function NightHunter.SpawnLeapEndEffects(inst, new_x, new_z)
    local fx_land = SpawnPrefab("shadow_teleport_in")
    if fx_land then fx_land.Transform:SetPosition(new_x, 0, new_z) end
    local fx_ring = SpawnPrefab("groundpoundring_fx")
    if fx_ring then fx_ring.Transform:SetPosition(new_x, 0, new_z) end
end
function NightHunter.ValidateMarks(inst)
    if not inst._night_hunter_marked_targets then return end
    local to_remove = {}
    for i, target in ipairs(inst._night_hunter_marked_targets) do
        local should_remove = false
        if not target or not target:IsValid() then
            should_remove = true
        elseif target:IsInLimbo() then
            should_remove = true
        elseif target.components.inventoryitem and target.components.inventoryitem:IsHeld() then
            should_remove = true
        end
        if should_remove then
            table.insert(to_remove, target)
        end
    end
    for _, target in ipairs(to_remove) do
        RemoveMarkFromTarget(inst, target)
    end
end
function NightHunter.UpdateChaseSpeed(inst)
    if inst:HasTag("kodi_night_hunter") and inst.components.combat then
        local target = inst.components.combat.target
        if target and target:IsValid() and target.components.combat then
            local target_combat_target = target.components.combat.target
            if not target_combat_target or target_combat_target ~= inst then
                if inst.components.locomotor then
                    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_chase_speed", NightHunter.CHASE_SPEED)
                end
            else
                if inst.components.locomotor then
                    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_chase_speed")
                end
            end
        else
            if inst.components.locomotor then
                inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_chase_speed")
            end
        end
    end
end
function NightHunter.SetupPlayer(inst)
    inst._night_hunter_marked_targets = {}
    inst._night_hunter_mark_tasks = {}
    inst._night_hunter_leap_cooldown = 0
    inst._night_hunter_vision_active = false
    inst._night_hunter_vision_enabled = false
    inst._night_hunter_vision_task = nil
    inst.ClearNightHunterMarks = function(self) return NightHunter.ClearAllMarks(self) end
    inst.MarkNightHunterTarget = function(self, target) return NightHunter.MarkTarget(self, target) end
    inst.LeapToMarkedTarget = function(self, target) return NightHunter.LeapToTarget(self, target) end
    inst.ToggleNightHunterVision = function(self) return NightHunter.ToggleVision(self) end
    inst.IsNightHunterVisionActive = function(self) return self._night_hunter_vision_active end
    inst.GetNightVisionTimeRemaining = function(self) return NightHunter.GetNightVisionTimeRemaining(self) end
    inst.GetNightHunterLeapCooldown = function(self)
        local remaining = (self._night_hunter_leap_cooldown or 0) - GetTime()
        return math.max(0, remaining)
    end
    inst.GetNightHunterMarkTimeRemaining = function(self)
        if not self._night_hunter_marked_targets or #self._night_hunter_marked_targets == 0 then
            return -1
        end
        if not self._night_hunter_mark_times then
            return NightHunter.MARK_DURATION
        end
        local first_target = self._night_hunter_marked_targets[1]
        if not first_target or not self._night_hunter_mark_times[first_target] then
            return -1
        end
        local elapsed = GetTime() - self._night_hunter_mark_times[first_target]
        return math.max(0, NightHunter.MARK_DURATION - elapsed)
    end
    inst.GetNightHunterMarkCount = function(self)
        return #(self._night_hunter_marked_targets or {})
    end
    inst:WatchWorldState("phase", function(inst, phase)
        NightHunter.UpdateVision(inst)
    end)
    inst:ListenForEvent("kodi_form_changed", function(inst)
        NightHunter.UpdateVision(inst)
    end)
    inst:DoTaskInTime(0, function()
        NightHunter.UpdateVision(inst)
    end)
    inst:DoTaskInTime(1, function()
        NightHunter.UpdateVision(inst)
    end)
    inst:DoTaskInTime(3, function()
        NightHunter.UpdateVision(inst)
    end)
    inst:ListenForEvent("ms_respawnedfromghost", function()
        inst:DoTaskInTime(0.5, function()
            NightHunter.UpdateVision(inst)
        end)
    end)
    inst:ListenForEvent("onremove", function()
        if inst._night_hunter_vision_active then
            inst.components.playervision:ForceNightVision(false)
            inst.components.playervision:SetCustomCCTable(nil)
            inst._night_hunter_vision_active = false
        end
    end)
    inst:ListenForEvent("onattackother", function(inst, data)
        NightHunter.OnAttack(inst, data)
    end)
    inst:DoPeriodicTask(0.5, function()
        NightHunter.ValidateMarks(inst)
    end)
    inst:DoPeriodicTask(1, function()
        NightHunter.UpdateChaseSpeed(inst)
    end)
end
function NightHunter.CreateLeapAction()
    local action = Action({
        priority = 15,
        rmb = true,
        distance = NightHunter.LEAP_RANGE_NIGHT,
        mount_valid = false,
        encumbered_valid = false
    })
    action.id = "NIGHT_HUNTER_LEAP"
    action.str = "Hunt"
    action.fn = function(act)
        if act.doer and act.target and act.doer.LeapToMarkedTarget then
            return act.doer:LeapToMarkedTarget(act.target)
        end
        return false
    end
    return action
end
function NightHunter.CanLeap(doer, target)
    return doer.prefab == "kodi" and
           doer:HasTag("kodi_night_hunter") and
           doer:HasTag("NotDemon") and
           target:HasTag("kodi_marked")
end
return NightHunter
