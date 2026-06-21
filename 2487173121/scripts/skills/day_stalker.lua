local KodiUtils = require("kodi_utils")
local DayStalker = {}
DayStalker.POUNCE_MULT = TUNING.KODI_DAY_STALKER_POUNCE_MULT
DayStalker.SPEED_MULT = TUNING.KODI_DAY_STALKER_SPEED_MULT
DayStalker.ALPHA = TUNING.KODI_DAY_STALKER_ALPHA
DayStalker.FADE_TIME = TUNING.KODI_DAY_STALKER_FADE_TIME
DayStalker.DETECTION_RANGE = TUNING.KODI_DAY_STALKER_DETECTION_RANGE
DayStalker.DANGER_RANGE = TUNING.KODI_DAY_STALKER_DANGER_RANGE
DayStalker.LEAP_RANGE = TUNING.KODI_DAY_STALKER_LEAP_RANGE
DayStalker.LEAP_SPEED = TUNING.KODI_DAY_STALKER_LEAP_SPEED
DayStalker.LEAP_HEIGHT = TUNING.KODI_DAY_STALKER_LEAP_HEIGHT
DayStalker.HIDE_TIMEOUT = TUNING.KODI_DAY_STALKER_HIDE_TIMEOUT
function DayStalker.ClearIndicators(inst)
    for ent, indicator in pairs(inst._day_stalker_indicators or {}) do
        if indicator and indicator:IsValid() then
            indicator:Remove()
        end
    end
    inst._day_stalker_indicators = {}
end
function DayStalker.GetCreatureDetectionStatus(inst, creature)
    if not creature or not creature:IsValid() then return nil end
    if creature:HasTag("player") then return nil end
    if creature:HasTag("FX") or creature:HasTag("NOCLICK") or creature:HasTag("DECOR") then return nil end
    if creature:HasTag("wall") or creature:HasTag("structure") then return nil end
    local is_prey = creature:HasTag("bird") or creature:HasTag("rabbit") or creature:HasTag("prey")
    local is_hostile = creature:HasTag("monster") or creature:HasTag("hostile") or
                       (creature.components.combat and creature.components.combat.target == inst)
    local is_animal = creature:HasTag("animal") or creature.brain or creature.components.locomotor
    if not (is_prey or is_hostile or is_animal) then return nil end
    local px, py, pz = inst.Transform:GetWorldPosition()
    local cx, cy, cz = creature.Transform:GetWorldPosition()
    local dist = math.sqrt((cx - px)^2 + (cz - pz)^2)
    if dist > DayStalker.DETECTION_RANGE + 3 then
        return nil
    end
    if creature.components.combat and creature.components.combat.target == inst then
        return "alert"
    end
    if is_prey then
        if dist < 4 then
            return "alert"
        elseif dist < 6 then
            return "danger"
        elseif dist < 9 then
            return "caution"
        end
        return nil
    end
    if creature:HasTag("hunting") or creature:HasTag("chasing") then
        return "danger"
    end
    if creature.components.locomotor then
        local dest = creature.components.locomotor.dest
        if dest then
            local dx, dy, dz = dest:GetPoint()
            local dest_dist_to_player = math.sqrt((dx - px)^2 + (dz - pz)^2)
            if dest_dist_to_player < 3 then
                return "danger"
            end
        end
    end
    if creature.Transform and dist < DayStalker.DETECTION_RANGE then
        local creature_rot = creature.Transform:GetRotation() * DEGREES
        local angle_to_player = math.atan2(pz - cz, px - cx)
        local angle_diff = math.abs(creature_rot - angle_to_player)
        if angle_diff > math.pi then angle_diff = 2 * math.pi - angle_diff end
        local is_facing = angle_diff < math.pi / 3
        if is_facing then
            local visibility = inst._day_stalker_alpha_current or 1.0
            if dist < DayStalker.DANGER_RANGE then
                return visibility > 0.6 and "danger" or "caution"
            elseif visibility > 0.5 then
                return "caution"
            end
        end
    end
    if dist < DayStalker.DANGER_RANGE * 0.7 then
        return "caution"
    end
    return nil
end
function DayStalker.UpdateIndicators(inst)
    if not inst._day_stalker_stealth then
        DayStalker.ClearIndicators(inst)
        return
    end
    local px, py, pz = inst.Transform:GetWorldPosition()
    local nearby = TheSim:FindEntities(px, py, pz, DayStalker.DETECTION_RANGE + 5, nil,
        {"player", "FX", "NOCLICK", "DECOR", "INLIMBO", "wall", "structure"},
        {"_combat", "monster", "hostile", "animal", "bird", "rabbit", "prey"})
    local processed = {}
    for _, creature in ipairs(nearby) do
        if creature ~= inst and creature:IsValid() then
            processed[creature] = true
            local status = DayStalker.GetCreatureDetectionStatus(inst, creature)
            local indicator = inst._day_stalker_indicators[creature]
            local old_status = indicator and indicator._detection_status
            if status then
                if not indicator or not indicator:IsValid() then
                    indicator = SpawnPrefab("detection_indicator")
                    if indicator then
                        indicator._follow_target = creature
                        indicator._follow_task = indicator:DoPeriodicTask(0, function()
                            if indicator._follow_target and indicator._follow_target:IsValid() then
                                local tx, ty, tz = indicator._follow_target.Transform:GetWorldPosition()
                                indicator.Transform:SetPosition(tx, ty + 2.5, tz)
                            end
                        end)
                        inst._day_stalker_indicators[creature] = indicator
                    end
                end
                if indicator and indicator:IsValid() and old_status ~= status then
                    indicator._detection_status = status
                    if indicator.SetStatus then
                        indicator:SetStatus(status)
                    end
                end
                if indicator and indicator._fading then
                    indicator._fading = false
                    indicator.AnimState:SetMultColour(1, 1, 1, 1)
                end
            else
                if indicator and indicator:IsValid() then
                    if not indicator._fading then
                        indicator._fading = true
                        indicator._fade_alpha = 1
                        indicator:DoPeriodicTask(0.05, function()
                            indicator._fade_alpha = (indicator._fade_alpha or 1) - 0.1
                            if indicator._fade_alpha <= 0 then
                                indicator:Remove()
                            else
                                indicator.AnimState:SetMultColour(1, 1, 1, indicator._fade_alpha)
                            end
                        end)
                    end
                    inst._day_stalker_indicators[creature] = nil
                end
            end
        end
    end
    for creature, indicator in pairs(inst._day_stalker_indicators) do
        if not processed[creature] then
            if indicator and indicator:IsValid() then
                indicator:Remove()
            end
            inst._day_stalker_indicators[creature] = nil
        end
    end
end
function DayStalker.EnterStealth(inst)
    if not inst:HasTag("kodi_day_stalker") then return false end
    if not inst:HasTag("NotDemon") then return false end
    if inst._day_stalker_stealth then return false end
    inst._day_stalker_stealth = true
    inst._day_stalker_pounce_ready = false
    inst._day_stalker_fade_start_time = GetTime()
    inst:AddTag("kodi_stealth")
    if inst.components.locomotor then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kodi_stealth_speed", DayStalker.SPEED_MULT)
    end
    inst:PushEvent("carefulwalking", { careful = true })
    inst._day_stalker_alpha_current = 1.0
    if inst._day_stalker_fade_task then
        inst._day_stalker_fade_task:Cancel()
    end
    local fade_steps = 30
    local fade_step_time = DayStalker.FADE_TIME / fade_steps
    local alpha_step = (1.0 - DayStalker.ALPHA) / fade_steps
    local step_count = 0
    inst._day_stalker_fade_task = inst:DoPeriodicTask(fade_step_time, function()
        if not inst._day_stalker_stealth then
            if inst._day_stalker_fade_task then
                inst._day_stalker_fade_task:Cancel()
                inst._day_stalker_fade_task = nil
            end
            return
        end
        step_count = step_count + 1
        inst._day_stalker_alpha_current = 1.0 - (alpha_step * step_count)
        if inst._day_stalker_alpha_current <= DayStalker.ALPHA then
            inst._day_stalker_alpha_current = DayStalker.ALPHA
            inst._day_stalker_pounce_ready = true
            inst:AddTag("kodi_pounce_ready")
            if inst._day_stalker_fade_task then
                inst._day_stalker_fade_task:Cancel()
                inst._day_stalker_fade_task = nil
            end
        end
        inst.AnimState:SetMultColour(1, 1, 1, inst._day_stalker_alpha_current)
    end)
    if inst._day_stalker_detection_task then
        inst._day_stalker_detection_task:Cancel()
    end
    inst._day_stalker_detection_task = inst:DoPeriodicTask(0.3, function()
        DayStalker.UpdateIndicators(inst)
    end)
    DayStalker.SpawnStealthEnterEffects(inst)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowhand_extinguish")
    inst.components.talker:Say(STRINGS.KODI_SPEECH.STEALTH_ENTER, 1.5, true)
    return true
end
function DayStalker.ExitStealth(inst)
    if not inst._day_stalker_stealth then return end
    inst._day_stalker_stealth = false
    inst._day_stalker_pounce_ready = false
    inst:RemoveTag("kodi_stealth")
    inst:RemoveTag("kodi_pounce_ready")
    if inst._day_stalker_fade_task then
        inst._day_stalker_fade_task:Cancel()
        inst._day_stalker_fade_task = nil
    end
    if inst._day_stalker_detection_task then
        inst._day_stalker_detection_task:Cancel()
        inst._day_stalker_detection_task = nil
    end
    DayStalker.ClearIndicators(inst)
    if inst.components.locomotor then
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "kodi_stealth_speed")
    end
    inst._day_stalker_alpha_current = 1.0
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    inst:PushEvent("carefulwalking", { careful = false })
    local x, y, z = inst.Transform:GetWorldPosition()
    local disperse = SpawnPrefab("shadow_despawn")
    if disperse then
        disperse.Transform:SetPosition(x, y, z)
    end
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadow_hands_off")
end
function DayStalker.ToggleStealth(inst)
    if inst._day_stalker_stealth then
        DayStalker.ExitStealth(inst)
    else
        DayStalker.EnterStealth(inst)
    end
end
function DayStalker.EnterHide(inst, hide_object)
    if not inst:HasTag("kodi_day_stalker") then return false end
    if not inst:HasTag("NotDemon") then return false end
    if inst._kodi_hiding_behind_object then return false end
    if inst._day_stalker_stealth then return false end
    inst._kodi_hide_object = hide_object
    return true
end
function DayStalker.ExitHide(inst)
    if not inst._kodi_hiding_behind_object then return end
    inst._kodi_hiding_behind_object = false
    inst._kodi_hide_object = nil
    inst._day_stalker_pounce_ready = false
    inst:RemoveTag("kodi_hiding")
    inst:RemoveTag("kodi_pounce_ready")
    inst:RemoveTag("notarget")
    inst:Show()
    inst.DynamicShadow:Enable(true)
    if inst.sg and inst.sg:HasStateTag("kodi_hiding") then
        inst.sg:GoToState("idle")
    end
end
function DayStalker.Leap(inst, target)
    local isInStealth = inst._day_stalker_stealth
    local isHiding = inst.sg and inst.sg:HasStateTag("kodi_hiding")
    if not isInStealth and not isHiding then
        return false
    end
    if not inst._day_stalker_pounce_ready then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.STEALTH_NOT_READY, 1.5, true)
        return false
    end
    if inst._day_stalker_leaping then
        return false
    end
    if not target or not target:IsValid() then
        return false
    end
    local px, py, pz = inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local dist = math.sqrt((tx - px)^2 + (tz - pz)^2)
    if dist > DayStalker.LEAP_RANGE then
        inst.components.talker:Say(STRINGS.KODI_SPEECH.STEALTH_TOO_FAR, 1.5, true)
        return false
    end
    inst._day_stalker_leaping = true
    inst._day_stalker_leap_target = target
    DayStalker.FreezeTarget(target, inst)
    if inst._day_stalker_fade_task then
        inst._day_stalker_fade_task:Cancel()
        inst._day_stalker_fade_task = nil
    end
    inst.AnimState:SetMultColour(1, 1, 1, 1.0)
    if inst.components.playercontroller then
        inst.components.playercontroller:Enable(false)
    end
    if inst.components.talker then
        inst._talker_was_enabled = true
        inst.components.talker:ShutUp()
        inst._old_talker_say = inst.components.talker.Say
        inst.components.talker.Say = function() end
    end
    if inst.components.locomotor then
        inst.components.locomotor:Stop()
    end
    inst:ForceFacePoint(tx, ty, tz)
    inst.AnimState:PlayAnimation("run_pre")
    inst.AnimState:PushAnimation("run_loop", true)
    local start_fx = SpawnPrefab("shadow_teleport_out")
    if start_fx then
        start_fx.Transform:SetPosition(px, py, pz)
    end
    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
    local leap_duration = dist / DayStalker.LEAP_SPEED
    local elapsed = 0
    local start_x, start_z = px, pz
    local leap_task
    local target_lost = false
    leap_task = inst:DoPeriodicTask(FRAMES, function()
        if not inst._day_stalker_leaping then
            if leap_task then leap_task:Cancel() end
            return
        end
        elapsed = elapsed + FRAMES
        local target_x, target_y, target_z = tx, ty, tz
        if target and target:IsValid() then
            target_x, target_y, target_z = target.Transform:GetWorldPosition()
            tx, ty, tz = target_x, target_y, target_z
        else
            target_lost = true
        end
        local progress = math.min(elapsed / leap_duration, 1)
        local new_x = start_x + (target_x - start_x) * progress
        local new_z = start_z + (target_z - start_z) * progress
        local arc_height = DayStalker.LEAP_HEIGHT * 4 * progress * (1 - progress)
        inst.Transform:SetPosition(new_x, arc_height, new_z)
        if math.random() < 0.3 then
            local trail = SpawnPrefab("shadow_puff")
            if trail then
                trail.Transform:SetPosition(new_x, 0, new_z)
            end
        end
        if progress >= 1 then
            if leap_task then leap_task:Cancel() end
            DayStalker.OnLeapLand(inst, target, target_x, target_z)
        end
    end)
    return true
end
function DayStalker.FreezeTarget(target, inst)
    if target.components.locomotor then
        target.components.locomotor:Stop()
        target._kodi_leap_frozen = true
        target.components.locomotor:SetExternalSpeedMultiplier(target, "kodi_leap_freeze", 0)
    end
    if target.components.combat then
        target._kodi_old_target = target.components.combat.target
        target.components.combat:SetTarget(nil)
    end
    if target.brain then
        target:StopBrain()
        target._kodi_brain_stopped = true
    end
end
function DayStalker.UnfreezeTarget(target)
    if target._kodi_leap_frozen and target.components.locomotor then
        target.components.locomotor:RemoveExternalSpeedMultiplier(target, "kodi_leap_freeze")
        target._kodi_leap_frozen = nil
    end
    if target._kodi_brain_stopped and target.brain then
        target:RestartBrain()
        target._kodi_brain_stopped = nil
    end
end
function DayStalker.OnLeapLand(inst, target, target_x, target_z)
    inst.Transform:SetPosition(target_x, 0, target_z)
    inst:Show()
    inst.DynamicShadow:Enable(true)
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    if target and target:IsValid() then
        inst:ForceFacePoint(target:GetPosition():Get())
    else
        inst:ForceFacePoint(target_x, 0, target_z)
    end
    inst.AnimState:PlayAnimation("atk")
    inst.AnimState:PushAnimation("idle", true)
    DayStalker.SpawnLeapLandEffects(inst, target_x, target_z)
    ShakeAllCameras(CAMERASHAKE.FULL, 0.2, 0.02, 0.1, inst, 15)
    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
    if inst.components.playercontroller then
        inst.components.playercontroller:Enable(true)
    end
    if inst._old_talker_say and inst.components.talker then
        inst.components.talker.Say = inst._old_talker_say
        inst._old_talker_say = nil
    end
    inst:DoTaskInTime(0.1, function()
        if target:IsValid() then
            DayStalker.UnfreezeTarget(target)
        end
        inst._day_stalker_leaping = false
        inst.AnimState:SetMultColour(1, 1, 1, 1)
        if target:IsValid() and inst.components.combat then
            inst.components.combat:SetTarget(target)
            if inst.components.combat.CanAttack and inst.components.combat:CanAttack(target) then
                inst.components.combat:DoAttack(target)
            else
                local act = BufferedAction(inst, target, ACTIONS.ATTACK)
                if inst.components.locomotor then
                    inst.components.locomotor:PushAction(act, true)
                end
            end
        end
        inst:DoTaskInTime(0.2, function()
            if inst._day_stalker_stealth then
                DayStalker.ExitStealth(inst)
            end
            if inst._kodi_hiding_behind_object then
                DayStalker.ExitHide(inst)
            end
        end)
    end)
end
function DayStalker.OnAttack(inst, data)
    local isHiding = inst.sg and inst.sg:HasStateTag("kodi_hiding")
    if inst._day_stalker_pounce_ready and (inst._day_stalker_stealth or isHiding or inst._kodi_hiding_behind_object) and data.target then
        local weapon = inst.components.combat:GetWeapon()
        local base_damage = inst.components.combat:CalcDamage(data.target, weapon)
        local bonus_damage = base_damage * (DayStalker.POUNCE_MULT - 1)
        if data.target.components.health and bonus_damage > 0 then
            data.target.components.health:DoDelta(-bonus_damage)
        end
        DayStalker.SpawnPounceEffects(inst, data.target)
        inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacle_attack")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/attack")
        ShakeAllCameras(CAMERASHAKE.FULL, 0.3, 0.02, 0.15, inst, 20)
        if inst._day_stalker_stealth then
            DayStalker.ExitStealth(inst)
        end
        if inst._kodi_hiding_behind_object then
            DayStalker.ExitHide(inst)
        end
        inst._day_stalker_pounce_ready = false
        inst:RemoveTag("kodi_pounce_ready")
    end
end
function DayStalker.SpawnStealthEnterEffects(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local sink_fx = SpawnPrefab("statue_transition_2")
    if sink_fx then
        sink_fx.Transform:SetPosition(x, y, z)
        sink_fx.Transform:SetScale(0.8, 0.8, 0.8)
    end
    for i = 1, 6 do
        local angle = (i / 6) * 2 * math.pi
        local radius = 1.2
        inst:DoTaskInTime(i * 0.05, function()
            local wisp = SpawnPrefab("shadow_puff")
            if wisp then
                wisp.Transform:SetPosition(x + math.cos(angle) * radius, y, z + math.sin(angle) * radius)
            end
        end)
    end
    local glob = SpawnPrefab("shadow_glob_fx")
    if glob then
        glob.Transform:SetPosition(x, y, z)
    end
end
function DayStalker.SpawnLeapLandEffects(inst, target_x, target_z)
    local land_fx = SpawnPrefab("shadow_teleport_in")
    if land_fx then
        land_fx.Transform:SetPosition(target_x, 0, target_z)
    end
    local ring = SpawnPrefab("groundpoundring_fx")
    if ring then
        ring.Transform:SetPosition(target_x, 0, target_z)
    end
end
function DayStalker.SpawnPounceEffects(inst, target)
    local px, py, pz = inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local dist = math.sqrt((tx - px)^2 + (tz - pz)^2)
    local steps = math.floor(dist / 0.8)
    for i = 1, steps do
        local t = i / steps
        local trail_x = px + (tx - px) * t
        local trail_z = pz + (tz - pz) * t
        inst:DoTaskInTime(i * 0.02, function()
            local trail = SpawnPrefab("shadow_puff")
            if trail then
                trail.Transform:SetPosition(trail_x, 0, trail_z)
            end
        end)
    end
    local strike = SpawnPrefab("shadow_despawn")
    if strike then
        strike.Transform:SetPosition(tx, ty, tz)
    end
    for i = 1, 3 do
        inst:DoTaskInTime(i * 0.08, function()
            if target:IsValid() then
                local claw = SpawnPrefab("shadow_shield" .. math.random(1, 3))
                if claw then
                    claw.entity:SetParent(target.entity)
                end
            end
        end)
    end
    local ring = SpawnPrefab("groundpoundring_fx")
    if ring then
        ring.Transform:SetPosition(tx, 0, tz)
    end
    for i = 1, 5 do
        local angle = (i / 5) * 2 * math.pi
        local puff = SpawnPrefab("shadow_puff_large_front")
        if puff then
            puff.Transform:SetPosition(tx + math.cos(angle) * 1.5, ty, tz + math.sin(angle) * 1.5)
        end
    end
end
function DayStalker.SetupPlayer(inst)
    inst._day_stalker_stealth = false
    inst._day_stalker_pounce_ready = false
    inst._day_stalker_alpha_current = 1.0
    inst._day_stalker_fade_task = nil
    inst._day_stalker_detection_task = nil
    inst._day_stalker_indicators = {}
    inst._day_stalker_leaping = false
    inst._day_stalker_leap_target = nil
    inst._kodi_hiding_behind_object = false
    inst._kodi_hide_object = nil
    local _orig_IsCarefulWalking = inst.IsCarefulWalking
    inst.IsCarefulWalking = function(self)
        if self._day_stalker_stealth then
            return true
        end
        return _orig_IsCarefulWalking and _orig_IsCarefulWalking(self) or false
    end
    inst.EnterDayStalkerStealth = function(self) return DayStalker.EnterStealth(self) end
    inst.ExitDayStalkerStealth = function(self) return DayStalker.ExitStealth(self) end
    inst.ToggleDayStalkerStealth = function(self) return DayStalker.ToggleStealth(self) end
    inst.EnterKodiHide = function(self, obj) return DayStalker.EnterHide(self, obj) end
    inst.ExitKodiHide = function(self) return DayStalker.ExitHide(self) end
    inst.DayStalkerLeap = function(self, target) return DayStalker.Leap(self, target) end
    inst:ListenForEvent("onattackother", function(inst, data)
        DayStalker.OnAttack(inst, data)
    end)
    inst:ListenForEvent("attacked", function(inst, data)
        if inst._day_stalker_stealth then
            DayStalker.ExitStealth(inst)
        end
        if inst._kodi_hiding_behind_object then
            DayStalker.ExitHide(inst)
        end
    end)
    if inst.components.playeractionpicker then
        local old_GetLeftClickActions = inst.components.playeractionpicker.GetLeftClickActions
        inst.components.playeractionpicker.GetLeftClickActions = function(self, position, target)
            local actions = old_GetLeftClickActions(self, position, target)
            if inst._day_stalker_stealth and actions then
                local filtered = {}
                for _, action in ipairs(actions) do
                    if action.action ~= ACTIONS.LOOKAT then
                        table.insert(filtered, action)
                    end
                end
                return filtered
            end
            return actions
        end
    end
end
function DayStalker.CreateLeapAction()
    local action = Action({
        priority = 15,
        rmb = true,
        distance = DayStalker.LEAP_RANGE,
        mount_valid = false,
        encumbered_valid = false
    })
    action.id = "DAY_STALKER_LEAP"
    action.str = "Jump"
    action.fn = function(act)
        if act.doer and act.target and act.doer.DayStalkerLeap then
            return act.doer:DayStalkerLeap(act.target)
        end
        return false
    end
    return action
end
function DayStalker.CreateHideAction()
    local action = Action({
        priority = 10,
        rmb = true,
        distance = 3,
        mount_valid = false,
        encumbered_valid = false
    })
    action.id = "KODI_HIDE"
    action.str = "Hide"
    action.fn = function(act)
        if act.doer and act.target then
            act.doer._kodi_hide_object = act.target
            return true
        end
        return false
    end
    return action
end
function DayStalker.CreateHideState()
    return State {
        name = "kodi_hide",
        tags = { "hiding", "notalking", "notarget", "nomorph", "busy", "nopredict", "kodi_hiding" },
        onenter = function(inst)
            local isNearDanger = FindEntity(inst, 10,
                function(target)
                    return (target.components.combat ~= nil and target.components.combat.target == inst)
                        or (target:HasTag("monster") and not target:HasTag("player"))
                end,
                nil, nil, { "monster", "_combat" }) ~= nil
            if isNearDanger then
                if inst.components.talker then
                    inst.components.talker:Say(STRINGS.KODI_SPEECH.STEALTH_STILL_SEE)
                end
                inst.sg:GoToState("idle", true)
            end
            if not isNearDanger then
                inst:AddTag("notarget")
                if KodiUtils.IsMasterSim() then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x, y, z, 40, { "_combat" })
                    for _, ent in ipairs(ents) do
                        if ent.components.combat and ent.components.combat.target == inst then
                            ent.components.combat:SetTarget(nil)
                        end
                    end
                end
            end
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/movement/foley/hidebush")
            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(DayStalker.HIDE_TIMEOUT)
            if not KodiUtils.IsMasterSim() then
                inst:PerformPreviewBufferedAction()
            end
        end,
        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                if KodiUtils.IsMasterSim() then
                    inst:PerformBufferedAction()
                end
                inst:Hide()
                inst.DynamicShadow:Enable(false)
                inst:AddTag("kodi_hiding")
                inst:AddTag("kodi_pounce_ready")
                inst._kodi_hiding_behind_object = true
                inst._day_stalker_pounce_ready = true
                inst._kodi_hide_start_time = GetTime()
                local fx = SpawnPrefab("statue_transition_2")
                if fx then
                    local x, y, z = inst.Transform:GetWorldPosition()
                    fx.Transform:SetPosition(x, y, z)
                end
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nopredict")
                inst.sg:AddStateTag("idle")
            end),
        },
        events = {
            EventHandler("ontalk", function(inst)
                inst.AnimState:PushAnimation("hide_idle", false)
            end),
        },
        onexit = function(inst)
            inst:Show()
            inst.DynamicShadow:Enable(true)
            inst:RemoveTag("kodi_hiding")
            inst:RemoveTag("notarget")
            inst._kodi_hiding_behind_object = false
            if not inst._day_stalker_stealth then
                inst:RemoveTag("kodi_pounce_ready")
                inst._day_stalker_pounce_ready = false
            end
            inst.AnimState:PlayAnimation("run_pst")
            inst.SoundEmitter:PlaySound("dontstarve/movement/foley/hidebush")
            local fx = SpawnPrefab("shadow_despawn")
            if fx then
                local x, y, z = inst.Transform:GetWorldPosition()
                fx.Transform:SetPosition(x, y, z)
            end
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
            inst.sg.statemem.action = nil
        end,
        ontimeout = function(inst)
            inst:Show()
            inst.DynamicShadow:Enable(true)
            inst:RemoveTag("kodi_hiding")
            inst:RemoveTag("notarget")
            inst._kodi_hiding_behind_object = false
            if not inst._day_stalker_stealth then
                inst:RemoveTag("kodi_pounce_ready")
                inst._day_stalker_pounce_ready = false
            end
            inst.AnimState:PlayAnimation("run_pst")
            inst.SoundEmitter:PlaySound("dontstarve/movement/foley/hidebush")
            if not KodiUtils.IsMasterSim() then
                inst:ClearBufferedAction()
            end
            inst.sg:GoToState("idle")
        end,
    }
end
function DayStalker.CanLeap(doer, target)
    return doer.prefab == "kodi"
        and doer:HasTag("kodi_day_stalker")
        and doer:HasTag("NotDemon")
        and (doer:HasTag("kodi_stealth") or doer:HasTag("kodi_hiding"))
        and doer:HasTag("kodi_pounce_ready")
        and target:HasTag("_combat")
end
function DayStalker.CanHide(doer, target)
    if doer.prefab ~= "kodi" then return false end
    if not doer:HasTag("kodi_day_stalker") then return false end
    if not doer:HasTag("NotDemon") then return false end
    if doer:HasTag("kodi_hiding") then return false end
    local validHideSpot = target:HasTag("tree") or target:HasTag("boulder") or
                          target:HasTag("structure") or target:HasTag("wall")
    if not validHideSpot and target.prefab then
        validHideSpot = target.prefab:find("rock") or target.prefab:find("tree") or
                        target.prefab:find("evergreen") or target.prefab:find("deciduous")
    end
    return validHideSpot
end
return DayStalker
