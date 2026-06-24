-- scripts/behaviours/wanda_rejuvenate.lua
-- NPC 旺达自动返老还童行为（优先级：低于恐慌，高于战斗）

local NPC_TUNING = require("npc_tuning")

WandaRejuvenate = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "WandaRejuvenate")
    self.inst = inst
end)

local function CanRun(inst)
    if inst == nil or not inst:IsValid() then
        return false
    end
    if inst.npc_character_type ~= "wanda" or inst._is_ghost_mode then
        return false
    end
    if inst.components.health == nil or inst.components.health:IsDead() then
        return false
    end
    return true
end

local function GetCurrentAgeYears(inst)
    local min_age = NPC_TUNING.WANDA_MIN_YEARS_OLD or 20
    local max_age = NPC_TUNING.WANDA_MAX_YEARS_OLD or 80
    local pct = inst.components.health:GetPercent()
    return max_age - (max_age - min_age) * pct
end

function WandaRejuvenate:Visit()
    local inst = self.inst
    if not CanRun(inst) then
        self.status = FAILED
        return
    end

    if inst.sg ~= nil and inst.sg:HasStateTag("busy") and inst.sg.currentstate ~= nil and inst.sg.currentstate.name == "wanda_rejuvenate" then
        self.status = RUNNING
        return
    end

    local now = GetTime()
    local next_t = inst._wanda_rejuvenate_next_time or 0
    if now < next_t then
        self.status = FAILED
        return
    end

    local trigger_age = NPC_TUNING.WANDA_REJUVENATE_TRIGGER_AGE or 55
    if GetCurrentAgeYears(inst) < trigger_age then
        self.status = FAILED
        return
    end

    inst._wanda_rejuvenate_next_time = now + (NPC_TUNING.WANDA_REJUVENATE_COOLDOWN or 30)
    if inst.sg ~= nil then
        inst.sg:GoToState("wanda_rejuvenate")
        self.status = RUNNING
    else
        inst:PushEvent("wanda_rejuvenate_apply")
        self.status = SUCCESS
    end
end

return WandaRejuvenate
