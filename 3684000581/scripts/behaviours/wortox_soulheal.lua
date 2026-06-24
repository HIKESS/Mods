-- scripts/behaviours/wortox_soulheal.lua
-- Wortox 自动丢魂治疗（优先级：低于恐慌，高于战斗）

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")
local soulhop = require("npc/wortox_soulhop")

local function GetParam(key, fallback)
    local v = NPC_TUNING[key]
    if v == nil then
        return fallback
    end
    return v
end

local function DebugOn()
    return GetParam("WORTOX_NPC_SOUL_DEBUG", true) == true
end

local function Dbg(inst, fmt, ...)
    if not DebugOn() then
        return
    end
    local ok, msg = pcall(string.format, fmt, ...)
    if not ok then
        msg = tostring(fmt)
    end
    local ctype = inst and inst.npc_character_type or "unknown"
    local guid = inst and inst.GUID or -1
    print(string.format("[NPCFriends][WortoxSoul][%s][%s] %s", tostring(guid), tostring(ctype), msg))
end

local function IsInvalidOrGhost(ent)
    if not (ent and ent:IsValid()) then return true end
    if ent:HasTag("playerghost") then return true end
    if ent._is_ghost_mode then return true end
    if ent.components and ent.components.health and ent.components.health:IsDead() then return true end
    return false
end

local function IsFriendlyHealTarget(ent)
    if IsInvalidOrGhost(ent) then return false end
    if not (ent.components and ent.components.health) then return false end
    if not ent.components.health:IsHurt() then return false end
    if ent:HasTag("health_as_oldage") then return false end
    if ent:HasTag("npc_hostile") then return false end
    return true
end

local THREAT_MUST_TAGS = { "_combat" }
local THREAT_CANT_TAGS = { "INLIMBO", "playerghost", "notarget", "noattack" }

local function FindNearestThreatTargetingMe(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = _G.TheSim:FindEntities(x, y, z, radius, THREAT_MUST_TAGS, THREAT_CANT_TAGS)
    local best, best_dsq = nil, nil
    for _, e in ipairs(ents) do
        if e ~= inst and e:IsValid() and e.components and e.components.combat and e.components.combat.target == inst then
            local dsq = inst:GetDistanceSqToInst(e)
            if best_dsq == nil or dsq < best_dsq then
                best, best_dsq = e, dsq
            end
        end
    end
    return best, best_dsq
end

local function FindNearestHurtTargetInRange(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rangesq = radius * radius
    local best, best_dsq = nil, nil

    local function Try(ent)
        if IsFriendlyHealTarget(ent) then
            local dsq = ent:GetDistanceSqToPoint(x, y, z)
            if dsq <= rangesq and (best_dsq == nil or dsq < best_dsq) then
                best, best_dsq = ent, dsq
            end
        end
    end

    for _, p in ipairs(AllPlayers) do
        Try(p)
    end
    local npcs = _G.TheSim:FindEntities(x, y, z, radius, { "npcfriend", "_health" }, { "INLIMBO", "playerghost", "npc_hostile" })
    for _, n in ipairs(npcs) do
        if n ~= inst then
            Try(n)
        end
    end
    Try(inst)

    return best, best_dsq
end

local function CollectHurtTargetsInRange(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rangesq = radius * radius
    local ret = {}

    for _, p in ipairs(AllPlayers) do
        if IsFriendlyHealTarget(p) and p:GetDistanceSqToPoint(x, y, z) <= rangesq then
            ret[#ret + 1] = p
        end
    end

    local npcs = _G.TheSim:FindEntities(x, y, z, radius, { "npcfriend", "_health" }, { "INLIMBO", "playerghost", "npc_hostile" })
    for _, n in ipairs(npcs) do
        if n ~= inst and IsFriendlyHealTarget(n) then
            ret[#ret + 1] = n
        end
    end

    if IsFriendlyHealTarget(inst) then
        ret[#ret + 1] = inst
    end

    return ret
end

local function CountHurtTargetsInRange(inst, radius)
    local targets = CollectHurtTargetsInRange(inst, radius)
    return #targets
end

local function GetHealAmount(target_count)
    local base = GetParam("WORTOX_NPC_SOUL_HEAL_BASE", 20)
    local loss = GetParam("WORTOX_NPC_SOUL_HEAL_LOSS_PER_TARGET", 2)
    local min_heal = GetParam("WORTOX_NPC_SOUL_HEAL_MIN", 5)
    local n = math.max(1, math.floor(target_count or 1))
    return math.max(min_heal, base - loss * (n - 1))
end

local function SpawnHealFX(target)
    local fx = SpawnPrefab("wortox_soul_heal_fx")
    if not fx then return end
    if target.components and target.components.combat then
        fx.entity:AddFollower():FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, -50, 0)
    else
        local x, y, z = target.Transform:GetWorldPosition()
        fx.Transform:SetPosition(x, y, z)
    end
    if fx.Setup then
        fx:Setup(target)
    end
end

local function DoSoulHealNow(inst, heal_range)
    local targets = CollectHurtTargetsInRange(inst, heal_range)
    if #targets <= 0 then
        return 0
    end
    local amount = GetHealAmount(#targets)
    local healed = 0
    for _, t in ipairs(targets) do
        if IsFriendlyHealTarget(t) then
            t.components.health:DoDelta(amount, nil, "wortox_npc_soul")
            SpawnHealFX(t)
            healed = healed + 1
        end
    end
    return healed
end

local function SaySoulHealLine(inst)
    if not (inst and inst.components and inst.components.talker) then
        return
    end
    local line = NPC_SPEECH.GetLine(NPC_SPEECH.SOUL_HEAL, inst.npc_character_type)
    if line then
        inst.components.talker:Say(line)
    end
end

local function ResolveDeferredSoulHeal(inst, visual, heal_range)
    if visual and visual:IsValid() then
        if visual._npc_drop_task then
            visual._npc_drop_task:Cancel()
            visual._npc_drop_task = nil
        end
        visual.AnimState:PlayAnimation("idle_pst")
        visual:ListenForEvent("animover", visual.Remove)
    end

    local healed = DoSoulHealNow(inst, heal_range)
    if healed > 0 then
        Dbg(inst, "deferred_heal_done healed=%d", healed)
        SaySoulHealLine(inst)
    else
        Dbg(inst, "deferred_heal_done healed=0 reason=no_hurt_target_when_resolve")
    end
end

local function SpawnGroundSoulVisual(inst)
    local soul = SpawnPrefab("wortox_soul")
    if not soul then
        return nil
    end
    local spawn_fx = SpawnPrefab("wortox_soul_spawn_fx")
    local x, y, z = inst.Transform:GetWorldPosition()
    if spawn_fx then
        spawn_fx.Transform:SetPosition(x, y, z)
    end

    soul.Transform:SetPosition(x, y, z)

    local start_y = y + 1.0
    local end_y = y
    local drop_time = 0.18
    local t0 = GetTime()
    soul.Transform:SetPosition(x, start_y, z)
    soul._npc_drop_task = soul:DoPeriodicTask(0, function(s)
        if not (s and s:IsValid()) then
            return
        end
        local k = (GetTime() - t0) / drop_time
        if k >= 1 then
            s.Transform:SetPosition(x, end_y, z)
            if s._npc_drop_task then
                s._npc_drop_task:Cancel()
                s._npc_drop_task = nil
            end
            return
        end
        local cy = start_y + (end_y - start_y) * k
        s.Transform:SetPosition(x, cy, z)
    end)

    if soul._task then
        soul._task:Cancel()
        soul._task = nil
    end
    return soul
end

WortoxSoulHeal = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "WortoxSoulHeal")
    self.inst = inst
    self.phase = nil 
    self.target = nil
    self.follow_deadline = nil
    self.cast_ready_time = nil
    self.cast_deadline = nil
    self.cast_anim_done = false
    self.cast_listener = nil
    self.cast_visual = nil
    self.hop_token = nil
end)

function WortoxSoulHeal:_ClearCastListener()
    if self.cast_listener then
        self.inst:RemoveEventCallback("animqueueover", self.cast_listener)
        self.cast_listener = nil
    end
end

function WortoxSoulHeal:_CleanupVisual()
    if self.cast_visual and self.cast_visual:IsValid() then
        if self.cast_visual._npc_drop_task then
            self.cast_visual._npc_drop_task:Cancel()
            self.cast_visual._npc_drop_task = nil
        end
        self.cast_visual:Remove()
    end
    self.cast_visual = nil
end

function WortoxSoulHeal:_Reset()
    self:_ClearCastListener()
    self:_CleanupVisual()
    self.phase = nil
    self.target = nil
    self.follow_deadline = nil
    self.cast_ready_time = nil
    self.cast_deadline = nil
    self.cast_anim_done = false
    self.cast_heal_scheduled = false
    self.hop_token = nil
end

function WortoxSoulHeal:_StartCast(now)
    local inst = self.inst
    self.phase = "cast"
    self.cast_anim_done = false
    self.cast_heal_scheduled = false
    self.cast_ready_time = now + GetParam("WORTOX_NPC_SOUL_HEAL_DELAY", 1)
    self.cast_deadline = now + math.max(1.5, GetParam("WORTOX_NPC_SOUL_HEAL_DELAY", 1) + 1.2)
    inst.components.locomotor:Stop()

    if inst.sg then
        inst.sg:GoToState("wortox_soulcast")
    end
    self.cast_listener = function(i)
        if i and i:IsValid() then
            self.cast_anim_done = true
        end
    end
    inst:ListenForEvent("animqueueover", self.cast_listener)
    self.cast_visual = SpawnGroundSoulVisual(inst)
    local check_interval = GetParam("WORTOX_NPC_SOUL_CHECK_INTERVAL", 10)
    inst._wortox_soulheal_cd_until = now + check_interval
    Dbg(inst, "start_cast combat=%s delay=%.2f", tostring(inst.components.combat and inst.components.combat.target ~= nil), (self.cast_ready_time or now) - now)
end

function WortoxSoulHeal:Visit()
    local inst = self.inst
    local now = GetTime()

    if not inst._is_wortox or IsInvalidOrGhost(inst) then
        Dbg(inst, "skip reason=not_wortox_or_invalid ghost=%s", tostring(inst._is_ghost_mode == true))
        self:_Reset()
        self.status = FAILED
        return
    end

    local check_interval = GetParam("WORTOX_NPC_SOUL_CHECK_INTERVAL", 10)
    local search_radius = GetParam("WORTOX_NPC_SOUL_SEARCH_RADIUS", 20)
    local heal_range = GetParam("WORTOX_NPC_SOUL_HEAL_RANGE", 15)
    local follow_timeout = GetParam("WORTOX_NPC_SOUL_FOLLOW_TIMEOUT", 6)
    local threat_check_radius = GetParam("WORTOX_NPC_SOULHOP_COMBAT_THREAT_CHECK", 22)

    if self.status == READY then
        if inst._wortox_soulheal_cd_until then
            local remain_raw = inst._wortox_soulheal_cd_until - now
            local sane_max = math.max(30, check_interval * 3)
            if remain_raw > sane_max then
                Dbg(inst, "cooldown_sanitize old_remain=%.2f max=%.2f -> clear", remain_raw, sane_max)
                inst._wortox_soulheal_cd_until = nil
            end
        end
        if inst._wortox_soulheal_cd_until and now < inst._wortox_soulheal_cd_until then
            local remain = (inst._wortox_soulheal_cd_until - now)
            if not self._next_cd_log_time or now >= self._next_cd_log_time then
                self._next_cd_log_time = now + 1
                local hurt_cnt = CountHurtTargetsInRange(inst, search_radius)
                Dbg(inst, "ready_block reason=cooldown remain=%.2f in_combat=%s search_hurt=%d", remain, tostring(inst.components.combat and inst.components.combat.target ~= nil), hurt_cnt)
            end
            self.status = FAILED
            return
        end
        local target, dsq = FindNearestHurtTargetInRange(inst, search_radius)
        if not target then
            if not self._next_notarget_log_time or now >= self._next_notarget_log_time then
                self._next_notarget_log_time = now + 1
                Dbg(inst, "ready_block reason=no_hurt_target in_combat=%s", tostring(inst.components.combat and inst.components.combat.target ~= nil))
            end
            self.status = FAILED
            return
        end
        self.target = target
        if dsq and dsq <= heal_range * heal_range then
            local threat = FindNearestThreatTargetingMe(inst, threat_check_radius)
            if threat and inst.components and inst.components.combat and inst.components.combat.target ~= nil then
                local ok, token = soulhop.StartSoulHopAwayFromThreatTowardTarget(inst, threat, target, {
                    hop_dist = GetParam("WORTOX_NPC_SOULHOP_COMBAT_AWAY_DIST", 10),
                })
                if ok then
                    self.phase = "hop_then_cast"
                    self.hop_token = token
                    Dbg(inst, "ready_ok action=hop_then_cast target=%s threat=%s", tostring(target.prefab), tostring(threat.prefab))
                    self.status = RUNNING
                    return
                end
            end
            Dbg(inst, "ready_ok action=cast target=%s dsq=%.2f heal_range=%.2f", tostring(target.prefab), dsq, heal_range * heal_range)
            self:_StartCast(now)
        else
            self.phase = "follow"
            self.follow_deadline = now + follow_timeout
            Dbg(inst, "ready_ok action=follow target=%s dsq=%.2f heal_range=%.2f timeout=%.2f", tostring(target.prefab), dsq or -1, heal_range * heal_range, follow_timeout)
        end
        self.status = RUNNING
        return
    end

    if self.status ~= RUNNING then
        self:_Reset()
        self.status = FAILED
        return
    end

    if self.phase == "hop_then_cast" then
        if self.hop_token and soulhop.IsSoulHopActive(inst, self.hop_token) then
            self.status = RUNNING
            return
        end
        if self.hop_token then
            local result = soulhop.GetSoulHopResult(inst, self.hop_token)
            self.hop_token = nil
            if result then
                Dbg(inst, "hop_then_cast done=ok -> cast_now")
                self:_StartCast(now)
                self.status = RUNNING
                return
            end
            Dbg(inst, "hop_then_cast done=fail -> fallback_cast")
            self:_StartCast(now)
            self.status = RUNNING
            return
        end
    end

    if self.phase == "follow" then
        local tgt = self.target
        if not (tgt and tgt:IsValid() and IsFriendlyHealTarget(tgt)) then
            Dbg(inst, "follow_stop reason=target_invalid")
            self:_Reset()
            self.status = FAILED
            return
        end
        if now >= (self.follow_deadline or 0) then
            Dbg(inst, "follow_stop reason=timeout")
            self:_Reset()
            self.status = FAILED
            return
        end

        local dsq = inst:GetDistanceSqToInst(tgt)
        if dsq <= heal_range * heal_range then
            local threat = FindNearestThreatTargetingMe(inst, threat_check_radius)
            if threat and inst.components and inst.components.combat and inst.components.combat.target ~= nil then
                local ok, token = soulhop.StartSoulHopAwayFromThreatTowardTarget(inst, threat, tgt, {
                    hop_dist = GetParam("WORTOX_NPC_SOULHOP_COMBAT_AWAY_DIST", 10),
                })
                if ok then
                    self.phase = "hop_then_cast"
                    self.hop_token = token
                    Dbg(inst, "follow_reach action=hop_then_cast target=%s threat=%s", tostring(tgt.prefab), tostring(threat.prefab))
                    self.status = RUNNING
                    return
                end
            end

            Dbg(inst, "follow_reach action=cast target=%s dsq=%.2f", tostring(tgt.prefab), dsq)
            self:_StartCast(now)
            self.status = RUNNING
            return
        end
        if not self._next_follow_log_time or now >= self._next_follow_log_time then
            self._next_follow_log_time = now + 1
            Dbg(inst, "follow_move target=%s dsq=%.2f in_combat=%s", tostring(tgt.prefab), dsq, tostring(inst.components.combat and inst.components.combat.target ~= nil))
        end
        inst.components.locomotor:GoToPoint(tgt:GetPosition(), nil, true)
        self.status = RUNNING
        return
    end

    if self.phase == "cast" then
        local anim_done = self.cast_anim_done or now >= (self.cast_deadline or 0)
        local delay_done = now >= (self.cast_ready_time or 0)
        if anim_done and not self.cast_heal_scheduled then
            local wait = math.max(0, (self.cast_ready_time or now) - now)
            local visual = self.cast_visual
            self.cast_visual = nil 
            self.cast_heal_scheduled = true
            inst:DoTaskInTime(wait, function(i)
                if i and i:IsValid() then
                    ResolveDeferredSoulHeal(i, visual, heal_range)
                elseif visual and visual:IsValid() then
                    visual:Remove()
                end
            end)
            Dbg(inst, "cast_release_to_next_action wait=%.2f delay_done=%s", wait, tostring(delay_done))
            self:_ClearCastListener()
            self.phase = nil
            self.status = SUCCESS
            return
        end
        self.status = RUNNING
        return
    end

    self:_Reset()
    self.status = FAILED
end

function WortoxSoulHeal:OnStop()
    self:_Reset()
end

