-- scripts/behaviours/wortox_soulhop_follow.lua
-- Wortox 跟随状态下，距离领队过远时灵魂跳跃贴近

local NPC_TUNING = require("npc_tuning")
local soulhop = require("npc/wortox_soulhop")

WortoxSoulHopFollow = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "WortoxSoulHopFollow")
    self.inst = inst
end)

local function GetParam(key, fallback)
    local v = NPC_TUNING[key]
    if v == nil then
        return fallback
    end
    return v
end

function WortoxSoulHopFollow:Visit()
    local inst = self.inst
    local leader = (inst.components.follower and inst.components.follower.leader) or nil
    if not (inst._is_wortox and leader and leader:IsValid()) then
        self.status = FAILED
        return
    end
    if inst._is_ghost_mode then
        self.status = FAILED
        return
    end

    local now = GetTime()

    if self._hop_token and soulhop.IsSoulHopActive(inst, self._hop_token) then
        self.status = RUNNING
        return
    end
    if self._hop_token then
        local result = soulhop.GetSoulHopResult(inst, self._hop_token)
        self._hop_token = nil
        self.status = result and SUCCESS or FAILED
        return
    end

    if inst._wortox_soulhop_cd_until and now < inst._wortox_soulhop_cd_until then
        self.status = FAILED
        return
    end

    local trigger = GetParam("WORTOX_NPC_SOULHOP_FOLLOW_TRIGGER", 20)
    local dsq = inst:GetDistanceSqToInst(leader)
    if dsq <= trigger * trigger then
        self.status = FAILED
        return
    end

    local ok, token = soulhop.StartSoulHopToTarget(inst, leader, {
        min_dist = GetParam("WORTOX_NPC_SOULHOP_MIN_DIST", 2),
        max_dist = GetParam("WORTOX_NPC_SOULHOP_MAX_DIST", 4),
        attempts = GetParam("WORTOX_NPC_SOULHOP_ATTEMPTS", 12),
    })
    if ok then
        inst._wortox_soulhop_cd_until = now + GetParam("WORTOX_NPC_SOULHOP_COOLDOWN", 2)
        self._hop_token = token
        self.status = RUNNING
    else
        inst._wortox_soulhop_cd_until = now + 0.4
        self.status = FAILED
    end
end

