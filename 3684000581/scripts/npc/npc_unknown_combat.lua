-- scripts/npc/npc_unknown_combat.lua
-- Runtime dodge model for creatures missing explicit combat data.

local NPC_TUNING = require("npc_tuning")
local CustomCombat = require("npc/npc_custom_combat")

local M = {}

local actual_hits_by_prefab = {}
local transitions_by_prefab = {}
local next_debug_by_key = {}
local next_session_id = 0

local function Now()
    return (_G.GetTime ~= nil and _G.GetTime()) or 0
end

local function IsValidThreat(ent)
    return ent ~= nil
        and ent.IsValid ~= nil
        and ent:IsValid()
        and ent.components ~= nil
        and ent.components.combat ~= nil
        and ent.Transform ~= nil
end

local function IsAttackState(ent)
    return ent ~= nil
        and ent.sg ~= nil
        and ent.sg.HasStateTag ~= nil
        and ent.sg:HasStateTag("attack")
end

local function GetStateName(ent)
    return ent ~= nil
        and ent.sg ~= nil
        and ent.sg.currentstate ~= nil
        and ent.sg.currentstate.name
        or nil
end

local function GetTimeInState(ent)
    if ent ~= nil and ent.sg ~= nil and ent.sg.GetTimeInState ~= nil then
        return ent.sg:GetTimeInState()
    end
    return nil
end

local function DebugLog(key, fmt, ...)
    if not (NPC_TUNING and NPC_TUNING.UNKNOWN_CREATURE_DEBUG) then
        return
    end
    local now = Now()
    key = tostring(key or "unknown")
    local next_time = next_debug_by_key[key] or 0
    if now < next_time then
        return
    end
    next_debug_by_key[key] = now + (NPC_TUNING.UNKNOWN_CREATURE_DEBUG_INTERVAL or 2.5)
    print("[NPCFriends][UnknownCombat] " .. string.format(fmt, ...))
end

local function SessionLog(session_id, fmt, ...)
    if not (NPC_TUNING and NPC_TUNING.UNKNOWN_CREATURE_DEBUG) then
        return
    end
    print("[NPCFriends][UnknownCombat] " .. string.format("sid=%s ", tostring(session_id or "?")) .. string.format(fmt, ...))
end

local function GetDistance(inst, ent)
    if inst == nil or ent == nil or inst.GetDistanceSqToInst == nil then
        return math.huge
    end
    return math.sqrt(inst:GetDistanceSqToInst(ent))
end

local function GetRunSpeed(inst)
    local loco = inst ~= nil and inst.components ~= nil and inst.components.locomotor or nil
    if loco ~= nil and loco.GetRunSpeed ~= nil then
        return tonumber(loco:GetRunSpeed()) or 0
    end
    if loco ~= nil and loco.runspeed ~= nil then
        return tonumber(loco.runspeed) or 0
    end
    return 0
end

local function IsUnknown(ent, creature_data)
    return ent ~= nil
        and ent.prefab ~= nil
        and (creature_data == nil or creature_data[ent.prefab] == nil)
end

function M.IsUnknown(ent, creature_data)
    return IsUnknown(ent, creature_data)
end

local function GetLearningDodgeSetting(inst)
    local value = CustomCombat.GetValue("unknown_creature_learning_dodge", inst)
    local source = "custom"
    if value == nil then
        value = NPC_TUNING.UNKNOWN_CREATURE_LEARNING_DODGE
        source = "tuning"
    end
    return value == true, source, value
end

local function IsLearningDodgeEnabled(inst)
    local enabled = GetLearningDodgeSetting(inst)
    return enabled == true
end

local function IsFacingInst(ent, inst)
    if ent == nil or inst == nil or ent.GetAngleToPoint == nil or ent.Transform == nil or inst.Transform == nil then
        return false
    end
    local x, _, z = inst.Transform:GetWorldPosition()
    local angle_to = ent:GetAngleToPoint(x, 0, z)
    local facing = ent.Transform:GetRotation()
    local diff = (angle_to - facing) % 360
    if diff > 180 then diff = 360 - diff end
    return diff <= (NPC_TUNING.UNKNOWN_CREATURE_RUSH_FACING_DEG or 70)
end

-- RangeModel: never reads CREATURE_ATTACK_DATA; it uses entity combat range plus physics radius.
local function BuildRangeModel(ent)
    local combat = ent ~= nil and ent.components ~= nil and ent.components.combat or nil
    local raw = combat ~= nil and combat.GetAttackRange ~= nil and combat:GetAttackRange() or nil
    local source = tonumber(raw) ~= nil and "entity" or "fallback"
    raw = tonumber(raw) or NPC_TUNING.UNKNOWN_CREATURE_ATTACK_RANGE_FALLBACK or 3
    local physics = 0
    if ent ~= nil and ent.GetPhysicsRadius ~= nil then
        physics = tonumber(ent:GetPhysicsRadius(0)) or 0
    end
    local attack_range = raw + physics
    local danger_dist = attack_range + (NPC_TUNING.UNKNOWN_CREATURE_DANGER_MARGIN or 1.5)
    local safe_dist = math.max(NPC_TUNING.UNKNOWN_CREATURE_SAFE_DIST_MIN or 3.5,
        danger_dist + (NPC_TUNING.UNKNOWN_CREATURE_SAFE_MARGIN or 0))
    return {
        raw_range = raw,
        physics_radius = physics,
        range_source = source,
        attack_range = attack_range,
        danger_dist = danger_dist,
        safe_dist = safe_dist,
    }
end

local function UpdateAverage(record, value, max_samples)
    local count = math.min((record.count or 0) + 1, max_samples or NPC_TUNING.UNKNOWN_CREATURE_LEARN_MAX_SAMPLES or 8)
    local prev_weight = math.max(count - 1, 0)
    record.avg_hit_time = ((record.avg_hit_time or value) * prev_weight + value) / math.max(count, 1)
    record.count = count
    return record
end

local function GetActualRecord(prefab, state)
    local by_state = actual_hits_by_prefab[prefab]
    return by_state ~= nil and by_state[state] or nil
end

local function GetTransitionRecord(prefab, state)
    local by_state = transitions_by_prefab[prefab]
    return by_state ~= nil and by_state[state] or nil
end

local function GetTimingRecord(prefab, state, allow_attack_fallback)
    local actual = GetActualRecord(prefab, state)
    if actual ~= nil and (actual.count or 0) > 0 then
        return actual, state
    end
    local transition = GetTransitionRecord(prefab, state)
    if transition ~= nil and (transition.count or 0) > 0 then
        return transition, state
    end
    if allow_attack_fallback and state ~= "attack" then
        actual = GetActualRecord(prefab, "attack")
        if actual ~= nil and (actual.count or 0) > 0 then
            return actual, "attack"
        end
        transition = GetTransitionRecord(prefab, "attack")
        if transition ~= nil and (transition.count or 0) > 0 then
            return transition, "attack"
        end
    end
    return nil, nil
end

local function LearnActualHit(self, ent, state, hit_t, range_model)
    if ent == nil or ent.prefab == nil or state == nil or hit_t == nil then
        return nil
    end
    local prefab = ent.prefab
    actual_hits_by_prefab[prefab] = actual_hits_by_prefab[prefab] or {}
    local record = actual_hits_by_prefab[prefab][state] or {
        count = 0,
        avg_hit_time = hit_t,
        attack_range = range_model and range_model.attack_range or BuildRangeModel(ent).attack_range,
        source = "actual_hit",
    }
    UpdateAverage(record, hit_t)
    record.attack_range = math.max(record.attack_range or 0, range_model and range_model.attack_range or BuildRangeModel(ent).attack_range)
    record.source = "actual_hit"
    actual_hits_by_prefab[prefab][state] = record
    DebugLog("learn|actual|" .. tostring(prefab) .. "|" .. tostring(state),
        "learn source=actual_hit prefab=%s state=%s hit_t=%.2f avg=%.2f count=%d range=%.2f npc=%s",
        tostring(prefab), tostring(state), tonumber(hit_t) or 0,
        tonumber(record.avg_hit_time) or 0, tonumber(record.count) or 0,
        tonumber(record.attack_range) or 0, tostring(self and self.inst and self.inst.prefab or "?"))
    return record
end

local function LearnTransition(self, ent, from_state, to_state, hit_t, range_model)
    if ent == nil or ent.prefab == nil or from_state == nil or to_state == nil or hit_t == nil or from_state == to_state then
        return nil
    end
    local prefab = ent.prefab
    transitions_by_prefab[prefab] = transitions_by_prefab[prefab] or {}
    local record = transitions_by_prefab[prefab][from_state] or {
        count = 0,
        avg_hit_time = hit_t,
        attack_range = range_model and range_model.attack_range or BuildRangeModel(ent).attack_range,
        hit_state = to_state,
        source = "derived_transition",
    }
    UpdateAverage(record, hit_t)
    record.attack_range = math.max(record.attack_range or 0, range_model and range_model.attack_range or BuildRangeModel(ent).attack_range)
    record.hit_state = to_state
    record.source = "derived_transition"
    transitions_by_prefab[prefab][from_state] = record
    DebugLog("learn|transition|" .. tostring(prefab) .. "|" .. tostring(from_state),
        "learn source=derived_transition prefab=%s state=%s hit_state=%s hit_t=%.2f avg=%.2f count=%d range=%.2f npc=%s",
        tostring(prefab), tostring(from_state), tostring(to_state), tonumber(hit_t) or 0,
        tonumber(record.avg_hit_time) or 0, tonumber(record.count) or 0,
        tonumber(record.attack_range) or 0, tostring(self and self.inst and self.inst.prefab or "?"))
    return record
end

-- ThreatSnapshot: capture all changing game state once per decision.
local function BuildSnapshot(self, ent, creature_data, source)
    local inst = self ~= nil and self.inst or nil
    if inst == nil or not IsValidThreat(ent) or not IsUnknown(ent, creature_data) then
        return nil
    end
    if not IsLearningDodgeEnabled(inst) then
        return nil
    end
    local combat = ent.components.combat
    local range = BuildRangeModel(ent)
    local state = GetStateName(ent) or "_unknown"
    local dist = GetDistance(inst, ent)
    local run_speed = GetRunSpeed(inst)
    local target_speed = ent.Physics ~= nil and (ent.Physics:GetMotorVel() or 0) or 0
    local attack_tag = IsAttackState(ent)
    local timing, timing_state = GetTimingRecord(ent.prefab, state, not attack_tag)
    local targeting_npc = combat ~= nil and combat.target == inst
    local primary_threatening = source == "primary" and attack_tag and dist <= range.danger_dist
    local engaged = targeting_npc or source == "recent" or primary_threatening

    local learned_range = math.max(timing and timing.attack_range or 0, range.attack_range)
    local danger_dist = learned_range + (NPC_TUNING.UNKNOWN_CREATURE_DANGER_MARGIN or 1.5)
    local safe_dist = math.max(NPC_TUNING.UNKNOWN_CREATURE_SAFE_DIST_MIN or 3.5,
        danger_dist + (NPC_TUNING.UNKNOWN_CREATURE_SAFE_MARGIN or 0))

    return {
        inst = inst,
        behavior = self,
        ent = ent,
        guid = ent.GUID,
        prefab = ent.prefab,
        source = source or "direct",
        combat = combat,
        targeting_npc = targeting_npc,
        engaged = engaged,
        state = state,
        t = GetTimeInState(ent) or 0,
        attack_tag = attack_tag,
        dist = dist,
        raw_range = range.raw_range,
        physics_radius = range.physics_radius,
        range_source = range.range_source,
        attack_range = range.attack_range,
        danger_dist = danger_dist,
        safe_dist = safe_dist,
        run_speed = run_speed,
        target_speed = target_speed,
        facing_npc = IsFacingInst(ent, inst),
        timing = timing,
        timing_state = timing_state,
    }
end

local function IsRushingSnapshot(snapshot)
    if snapshot == nil then
        return false
    end
    if snapshot.target_speed < (NPC_TUNING.UNKNOWN_CREATURE_RUSH_SPEED or 8) then
        return false
    end
    if snapshot.dist > snapshot.danger_dist + (NPC_TUNING.UNKNOWN_CREATURE_RUSH_EXTRA_RANGE or 4) then
        return false
    end
    return snapshot.facing_npc
end

local function CalculateMove(snapshot)
    local speed = math.max(snapshot.run_speed or 0, 0.1)
    local move_need = math.max(0, (snapshot.safe_dist or 0) - (snapshot.dist or 0))
    return move_need, move_need / speed
end

local function GetAttackStateStart(snapshot)
    return Now() - (snapshot.t or 0)
end

local function HasDodgedCurrentAttack(snapshot)
    if snapshot == nil or not snapshot.attack_tag or snapshot.behavior == nil or snapshot.guid == nil then
        return false
    end
    local by_guid = snapshot.behavior._unknown_dodged_attack_by_guid
    local prev = by_guid ~= nil and by_guid[snapshot.guid] or nil
    if prev == nil or prev.state ~= snapshot.state then
        return false
    end
    return math.abs((prev.state_started_at or 0) - GetAttackStateStart(snapshot)) <= 0.15
end

local function BuildIntent(snapshot, reason, dodge_dir, trigger_t)
    next_session_id = next_session_id + 1
    local move_need, move_time = CalculateMove(snapshot)
    local base_timeout = NPC_TUNING.UNKNOWN_CREATURE_DODGE_TIMEOUT or 1.1
    local dynamic_timeout = move_time + (NPC_TUNING.UNKNOWN_CREATURE_REACTION_BUFFER or 0.08) + 0.15
    return {
        session_id = next_session_id,
        guid = snapshot.guid,
        prefab = snapshot.prefab,
        state = snapshot.state,
        source = snapshot.source,
        trigger_t = trigger_t or snapshot.t,
        reason = reason,
        dodge_dir = dodge_dir or "back",
        dodge_dist = NPC_TUNING.UNKNOWN_CREATURE_DODGE_DIST or 4,
        raw_range = snapshot.raw_range,
        range_source = snapshot.range_source,
        physics_radius = snapshot.physics_radius,
        attack_range = snapshot.attack_range,
        danger_dist = snapshot.danger_dist,
        safe_dist = snapshot.safe_dist,
        move_need = move_need,
        move_time = move_time,
        min_time = NPC_TUNING.UNKNOWN_CREATURE_DODGE_MIN_TIME or 0.25,
        hold_time = NPC_TUNING.UNKNOWN_CREATURE_DODGE_HOLD_TIME or 0.75,
        timeout = math.max(base_timeout, dynamic_timeout),
        started_at = Now(),
    }
end

local function MaybeIntent(snapshot, reason, dodge_dir, trigger_t, preview)
    if preview then
        return { reason = reason, dodge_dir = dodge_dir or "back", preview = true }
    end
    return BuildIntent(snapshot, reason, dodge_dir, trigger_t)
end

local function EvaluateTiming(snapshot, preview)
    if snapshot == nil or not snapshot.engaged then
        return nil, "not_engaged"
    end

    local move_need, move_time = CalculateMove(snapshot)
    if IsRushingSnapshot(snapshot) then
        return MaybeIntent(snapshot, "rush", "side", snapshot.t, preview), "rush"
    end
    if HasDodgedCurrentAttack(snapshot) then
        if not preview then
            DebugLog("skip|already_dodged_attack|" .. tostring(snapshot.prefab) .. "|" .. tostring(snapshot.state),
                "skip already_dodged_attack prefab=%s state=%s source=%s t=%.2f dist=%.2f danger=%.2f safe=%.2f",
                tostring(snapshot.prefab), tostring(snapshot.state), tostring(snapshot.source),
                snapshot.t, snapshot.dist, snapshot.danger_dist, snapshot.safe_dist)
        end
        return nil, "already_dodged_attack"
    end

    local timing = snapshot.timing
    if timing ~= nil and (timing.count or 0) > 0 then
        local hit_avg = timing.avg_hit_time or snapshot.t
        local lead = NPC_TUNING.UNKNOWN_CREATURE_LEARNED_LEAD_TIME or 0.25
        local mobility_lead = move_time + (NPC_TUNING.UNKNOWN_CREATURE_REACTION_BUFFER or 0.08)
        local effective_lead = math.max(lead, mobility_lead)
        local trigger_t = math.max(0, hit_avg - effective_lead)
        local late_grace = NPC_TUNING.UNKNOWN_CREATURE_LEARNED_LATE_GRACE or 0.12

        if snapshot.attack_tag and snapshot.t > hit_avg + late_grace then
            if not preview then
                DebugLog("skip|learned_late|" .. tostring(snapshot.prefab) .. "|" .. tostring(snapshot.state),
                "skip learned_late prefab=%s state=%s timing_state=%s source=%s t=%.2f hit_avg=%.2f late_grace=%.2f dist=%.2f danger=%.2f safe=%.2f npc_speed=%.2f count=%d learn_source=%s",
                    tostring(snapshot.prefab), tostring(snapshot.state), tostring(snapshot.timing_state or "?"), tostring(snapshot.source), snapshot.t,
                    tonumber(hit_avg) or 0, late_grace, snapshot.dist, snapshot.danger_dist, snapshot.safe_dist,
                    snapshot.run_speed, tonumber(timing.count) or 0, tostring(timing.source or "?"))
            end
            return nil, "learned_late"
        end

        if snapshot.attack_tag and snapshot.dist <= snapshot.danger_dist and snapshot.t >= trigger_t then
            local intent = MaybeIntent(snapshot, "learned", "back", snapshot.t, preview)
            intent.hit_avg = hit_avg
            intent.effective_lead = effective_lead
            intent.learn_source = timing.source
            return intent, "learned"
        end

        if not snapshot.attack_tag and snapshot.combat ~= nil
            and snapshot.combat.laststartattacktime ~= nil
            and snapshot.combat.min_attack_period ~= nil then
            local until_attack_start = snapshot.combat.min_attack_period - (Now() - snapshot.combat.laststartattacktime)
            local until_hit = until_attack_start + hit_avg
            if until_attack_start > 0
                and until_hit <= effective_lead
                and snapshot.dist <= snapshot.danger_dist then
                local intent = MaybeIntent(snapshot, "learned_cooldown", "back", snapshot.t, preview)
                intent.hit_avg = hit_avg
                intent.effective_lead = effective_lead
                intent.learn_source = timing.source
                intent.cooldown_remaining = until_attack_start
                return intent, "learned_cooldown"
            end
            if not preview then
                DebugLog("wait|learned_cooldown|" .. tostring(snapshot.prefab) .. "|" .. tostring(snapshot.state),
                    "wait learned_cooldown prefab=%s state=%s timing_state=%s source=%s until_attack=%.2f until_hit=%.2f lead=%.2f move_need=%.2f move_time=%.2f dist=%.2f danger=%.2f npc_speed=%.2f learn_source=%s",
                    tostring(snapshot.prefab), tostring(snapshot.state), tostring(snapshot.timing_state or "?"), tostring(snapshot.source),
                    until_attack_start, until_hit, effective_lead, move_need, move_time,
                    snapshot.dist, snapshot.danger_dist, snapshot.run_speed, tostring(timing.source or "?"))
            end
            return nil, "learned_cooldown_wait"
        end

        if not preview then
            DebugLog("wait|learned|" .. tostring(snapshot.prefab) .. "|" .. tostring(snapshot.state),
                "wait learned prefab=%s state=%s timing_state=%s source=%s t=%.2f hit_avg=%.2f trigger_t=%.2f move_need=%.2f move_time=%.2f dist=%.2f danger=%.2f npc_speed=%.2f attack_tag=%s learn_source=%s",
                tostring(snapshot.prefab), tostring(snapshot.state), tostring(snapshot.timing_state or "?"), tostring(snapshot.source), snapshot.t,
                tonumber(hit_avg) or 0, trigger_t, move_need, move_time, snapshot.dist,
                snapshot.danger_dist, snapshot.run_speed, tostring(snapshot.attack_tag), tostring(timing.source or "?"))
        end
        return nil, "learned_wait"
    end

    if snapshot.attack_tag
        and snapshot.dist <= snapshot.danger_dist
        and snapshot.t >= (NPC_TUNING.UNKNOWN_CREATURE_ATTACK_REACT_DELAY or 0.12) then
        return MaybeIntent(snapshot, "reactive", "back", snapshot.t, preview), "reactive"
    end

    return nil, "no_window"
end

local function WatchSnapshot(snapshot)
    DebugLog("watch|" .. tostring(snapshot.prefab) .. "|" .. tostring(snapshot.state) .. "|" .. tostring(snapshot.source),
        "watch prefab=%s state=%s timing_state=%s source=%s t=%.2f dist=%.2f raw_range=%.2f phys=%.2f range_source=%s atk_range=%.2f danger=%.2f safe=%.2f move_need=%.2f move_time=%.2f npc_speed=%.2f target_speed=%.2f attack_tag=%s target_npc=%s learned=%s count=%s learn_source=%s",
        tostring(snapshot.prefab), tostring(snapshot.state), tostring(snapshot.timing_state or "?"), tostring(snapshot.source), snapshot.t,
        snapshot.dist, snapshot.raw_range, snapshot.physics_radius, tostring(snapshot.range_source),
        snapshot.attack_range, snapshot.danger_dist, snapshot.safe_dist,
        CalculateMove(snapshot), select(2, CalculateMove(snapshot)),
        snapshot.run_speed, snapshot.target_speed, tostring(snapshot.attack_tag),
        tostring(snapshot.targeting_npc), tostring(snapshot.timing ~= nil),
        tostring(snapshot.timing and snapshot.timing.count or 0),
        tostring(snapshot.timing and snapshot.timing.source or "?"))
end

local function ApplyIntent(self, snapshot, intent, log_fn)
    if self == nil or snapshot == nil or intent == nil then
        return false
    end
    self._unknown_combat_dodge = intent
    self.dodge_threat = snapshot.ent
    if snapshot.attack_tag and snapshot.guid ~= nil then
        self._unknown_dodged_attack_by_guid = self._unknown_dodged_attack_by_guid or {}
        self._unknown_dodged_attack_by_guid[snapshot.guid] = {
            state = snapshot.state,
            state_started_at = GetAttackStateStart(snapshot),
        }
    end
    SessionLog(intent.session_id,
        "dodge reason=%s prefab=%s state=%s timing_state=%s source=%s t=%.2f dist=%.2f raw_range=%.2f phys=%.2f range_source=%s danger=%.2f safe=%.2f move_need=%.2f move_time=%.2f npc_speed=%.2f target_speed=%.2f dir=%s timeout=%.2f learned_hit=%s lead=%s learn_source=%s",
        tostring(intent.reason), tostring(intent.prefab), tostring(intent.state), tostring(snapshot.timing_state or "?"), tostring(intent.source),
        snapshot.t, snapshot.dist, snapshot.raw_range, snapshot.physics_radius, tostring(snapshot.range_source),
        snapshot.danger_dist, snapshot.safe_dist, intent.move_need, intent.move_time,
        snapshot.run_speed, snapshot.target_speed, tostring(intent.dodge_dir), intent.timeout,
        tostring(intent.hit_avg or "-"), tostring(intent.effective_lead or "-"), tostring(intent.learn_source or "-"))
    if log_fn then
        log_fn(string.format("[NPC:%s][未知闪避] %s %s(%s) source=%s 距离=%.1f 安全=%.1f",
            tostring(snapshot.inst.prefab), tostring(intent.reason), tostring(snapshot.prefab),
            tostring(snapshot.state), tostring(snapshot.source), snapshot.dist, snapshot.safe_dist))
    end
    return true
end

function M.ObserveAttacked(self, attacker, creature_data, damage)
    if self == nil or self.inst == nil or not IsValidThreat(attacker) then
        return
    end
    if not IsUnknown(attacker, creature_data) then
        return
    end
    local enabled, setting_source, raw_value = GetLearningDodgeSetting(self.inst)
    if not enabled then
        DebugLog("observe_disabled|" .. tostring(attacker.prefab),
            "observe_disabled prefab=%s state=%s setting_source=%s raw_value=%s npc=%s",
            tostring(attacker.prefab), tostring(GetStateName(attacker) or "?"),
            tostring(setting_source), tostring(raw_value), tostring(self.inst.prefab or "?"))
        return
    end
    self._unknown_recent_threat = attacker
    self._unknown_recent_threat_until = Now() + (NPC_TUNING.UNKNOWN_CREATURE_RECENT_THREAT_TIME or 6)
    local state = GetStateName(attacker)
    local t = GetTimeInState(attacker)
    if state == nil or t == nil then
        return
    end

    local range_model = BuildRangeModel(attacker)
    local active = self._unknown_combat_dodge
    if active ~= nil and active.guid == attacker.GUID then
        local elapsed = Now() - (active.started_at or Now())
        SessionLog(active.session_id,
            "hit_during_dodge prefab=%s state=%s hit_t=%.2f dodge_reason=%s elapsed=%.2f dist=%.2f safe=%.2f damage=%s npc=%s",
            tostring(attacker.prefab), tostring(state), tonumber(t) or 0,
            tostring(active.reason or "?"), elapsed, GetDistance(self.inst, attacker),
            tonumber(active.safe_dist) or 0, tostring(damage or "?"), tostring(self.inst.prefab or "?"))
        if active.state ~= nil and active.trigger_t ~= nil and active.state ~= state then
            LearnTransition(self, attacker, active.state, state, active.trigger_t + elapsed, range_model)
        end
    end
    LearnActualHit(self, attacker, state, t, range_model)
end

function M.GetRecentThreat(self, creature_data)
    if self == nil or self._unknown_recent_threat_until == nil or Now() > self._unknown_recent_threat_until then
        return nil
    end
    local ent = self._unknown_recent_threat
    if IsValidThreat(ent) and IsUnknown(ent, creature_data) then
        return ent
    end
    return nil
end

function M.GetThreatScore(self, target, creature_data, source)
    local snapshot = BuildSnapshot(self, target, creature_data, source)
    if snapshot == nil or not snapshot.engaged then
        return nil
    end
    local intent, reason = EvaluateTiming(snapshot, true)
    if intent == nil then
        DebugLog("scan_no_intent|" .. tostring(snapshot.prefab) .. "|" .. tostring(snapshot.state) .. "|" .. tostring(source),
            "scan_no_intent prefab=%s state=%s timing_state=%s source=%s reason=%s t=%.2f dist=%.2f danger=%.2f safe=%.2f npc_speed=%.2f target_speed=%.2f attack_tag=%s target_npc=%s learned=%s count=%s learn_source=%s",
            tostring(snapshot.prefab), tostring(snapshot.state), tostring(snapshot.timing_state or "?"), tostring(source), tostring(reason),
            snapshot.t, snapshot.dist, snapshot.danger_dist, snapshot.safe_dist,
            snapshot.run_speed, snapshot.target_speed, tostring(snapshot.attack_tag),
            tostring(snapshot.targeting_npc), tostring(snapshot.timing ~= nil),
            tostring(snapshot.timing and snapshot.timing.count or 0),
            tostring(snapshot.timing and snapshot.timing.source or "?"))
        return nil
    end
    local urgency = math.max(0, snapshot.danger_dist - snapshot.dist) * 20
    local source_bonus = source == "primary" and 30 or source == "recent" and 20 or 0
    local reason_bonus = reason == "rush" and 1000
        or reason == "learned" and 800
        or reason == "learned_cooldown" and 780
        or reason == "reactive" and 700
        or 0
    return reason_bonus + urgency + snapshot.attack_range + source_bonus
end

function M.ShouldDodge(self, target, creature_data, log_fn, source)
    local snapshot = BuildSnapshot(self, target, creature_data, source)
    if snapshot == nil then
        return false
    end
    WatchSnapshot(snapshot)
    local intent = EvaluateTiming(snapshot)
    if intent == nil then
        return false
    end
    return ApplyIntent(self, snapshot, intent, log_fn)
end

function M.GetDodgeParams(self, ent)
    local params = self ~= nil and self._unknown_combat_dodge or nil
    if params == nil or ent == nil or ent.GUID ~= params.guid then
        return nil
    end
    return params
end

function M.GetDodgeComplete(self, ent, elapsed)
    local params = M.GetDodgeParams(self, ent)
    if params == nil then
        return nil
    end
    elapsed = elapsed or 0
    if elapsed < (params.min_time or 0.25) then
        return false
    end
    local inst = self ~= nil and self.inst or nil
    local dist = GetDistance(inst, ent)
    if dist >= (params.safe_dist or 5) then
        SessionLog(params.session_id,
            "dodge_end reason=safe prefab=%s state=%s dodge_reason=%s elapsed=%.2f dist=%.2f safe=%.2f attack_active=%s",
            tostring(params.prefab), tostring(params.state), tostring(params.reason),
            elapsed, dist, tonumber(params.safe_dist) or 0, tostring(IsAttackState(ent)))
        return true
    end
    if not IsAttackState(ent) then
        local end_dist = (params.attack_range or 0) + (NPC_TUNING.UNKNOWN_CREATURE_ATTACK_END_MARGIN or 0.75)
        if dist >= end_dist then
            SessionLog(params.session_id,
                "dodge_end reason=attack_end prefab=%s state=%s dodge_reason=%s elapsed=%.2f dist=%.2f end_dist=%.2f safe=%.2f attack_active=false",
                tostring(params.prefab), tostring(params.state), tostring(params.reason),
                elapsed, dist, end_dist, tonumber(params.safe_dist) or 0)
            return true
        end
    end
    if elapsed >= (params.hold_time or 0.75) then
        if IsAttackState(ent) and dist < (params.safe_dist or 5) then
            SessionLog(params.session_id,
                "dodge_hold reason=attack_active prefab=%s state=%s dodge_reason=%s elapsed=%.2f dist=%.2f safe=%.2f timeout=%.2f",
                tostring(params.prefab), tostring(params.state), tostring(params.reason),
                elapsed, dist, tonumber(params.safe_dist) or 0, tonumber(params.timeout) or 0)
            return false
        end
        SessionLog(params.session_id,
            "dodge_end reason=hold prefab=%s state=%s dodge_reason=%s elapsed=%.2f dist=%.2f safe=%.2f attack_active=%s",
            tostring(params.prefab), tostring(params.state), tostring(params.reason),
            elapsed, dist, tonumber(params.safe_dist) or 0, tostring(IsAttackState(ent)))
        return true
    end
    return false
end

function M.ClearDodge(self)
    if self ~= nil then
        self._unknown_combat_dodge = nil
    end
end

return M
