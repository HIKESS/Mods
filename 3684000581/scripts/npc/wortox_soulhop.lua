-- scripts/npc/wortox_soulhop.lua
-- Wortox 灵魂跳跃通用方法

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")

local M = {}

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
    local guid = inst and inst.GUID or -1
    print(string.format("[NPCFriends][WortoxHop][%s] %s", tostring(guid), msg))
end

local function SaySoulHopLine(inst)
    if not (inst and inst.components and inst.components.talker) then
        return
    end
    local now = GetTime()
    if inst._wortox_soulhop_talk_cd and now < inst._wortox_soulhop_talk_cd then
        return
    end
    local line = NPC_SPEECH.GetLine(NPC_SPEECH.SOULHOP, inst.npc_character_type)
    if line then
        inst.components.talker:Say(line)
    end
    inst._wortox_soulhop_talk_cd = now + 2
end

local function IsValidHopPoint(x, z)
    local map = TheWorld and TheWorld.Map or nil
    if map == nil then
        return false
    end
    if not map:IsPassableAtPoint(x, 0, z) then
        return false
    end
    if map:IsOceanAtPoint(x, 0, z) then
        return false
    end
    return true
end

local function FindPointNearTarget(target_pos, min_dist, max_dist, attempts)
    for i = 1, attempts do
        local angle = math.random() * TWOPI
        local dist = min_dist + math.random() * (max_dist - min_dist)
        local offset = FindWalkableOffset(target_pos, angle, dist, 12, false, true)
        if offset then
            local tx = target_pos.x + offset.x
            local tz = target_pos.z + offset.z
            if IsValidHopPoint(tx, tz) then
                return tx, tz
            end
        end
    end

    if IsValidHopPoint(target_pos.x, target_pos.z) then
        return target_pos.x, target_pos.z
    end
    return nil, nil
end

function M.IsSoulHopActive(inst, token)
    if not inst then
        return false
    end
    if token ~= nil then
        return inst._wortox_soulhop_active_token == token
    end
    return inst._wortox_soulhop_active_token ~= nil
end

function M.GetSoulHopResult(inst, token)
    if not inst then
        return nil
    end
    if token ~= nil and inst._wortox_soulhop_result_token ~= token then
        return nil
    end
    return inst._wortox_soulhop_result
end

function M.StartSoulHopToTarget(inst, target, opts)
    if not (inst and inst:IsValid() and target and target:IsValid()) then
        return false
    end
    if inst._is_ghost_mode then
        return false
    end
    if inst.sg and inst.sg:HasStateTag("busy") then
        return false
    end

    opts = opts or {}
    local min_dist = opts.min_dist or GetParam("WORTOX_NPC_SOULHOP_MIN_DIST", 2)
    local max_dist = opts.max_dist or GetParam("WORTOX_NPC_SOULHOP_MAX_DIST", 4)
    local attempts = opts.attempts or GetParam("WORTOX_NPC_SOULHOP_ATTEMPTS", 12)

    local tx0, ty0, tz0 = target.Transform:GetWorldPosition()
    local target_pos = Vector3(tx0, 0, tz0)
    local tx, tz = FindPointNearTarget(target_pos, min_dist, max_dist, attempts)
    if tx == nil then
        Dbg(inst, "hop_fail reason=no_valid_dst")
        return false
    end

    local token = (inst._wortox_soulhop_token or 0) + 1
    inst._wortox_soulhop_token = token
    inst._wortox_soulhop_active_token = token
    inst._wortox_soulhop_result = nil
    inst._wortox_soulhop_result_token = nil
    inst._wortox_soulhop_dest = Vector3(tx, 0, tz)

    SaySoulHopLine(inst)
    Dbg(inst, "hop_start token=%d dst=(%.1f, %.1f)", token, tx, tz)
    inst.sg:GoToState("wortox_soulhop_pre", {
        token = token,
        dest = inst._wortox_soulhop_dest,
    })
    return true, token
end

function M.StartSoulHopAwayFromThreatTowardTarget(inst, threat, toward_target, opts)
    if not (inst and inst:IsValid() and threat and threat:IsValid() and toward_target and toward_target:IsValid()) then
        return false
    end
    if inst._is_ghost_mode then
        return false
    end
    if inst.sg and inst.sg:HasStateTag("busy") then
        return false
    end

    opts = opts or {}
    local hop_dist = opts.hop_dist or GetParam("WORTOX_NPC_SOULHOP_COMBAT_AWAY_DIST", 10)

    local tx, _, tz = threat.Transform:GetWorldPosition()
    local hx, _, hz = toward_target.Transform:GetWorldPosition()
    local vx, vz = hx - tx, hz - tz
    local len = math.sqrt(vx * vx + vz * vz)
    if len < 0.01 then
        local ix, _, iz = inst.Transform:GetWorldPosition()
        vx, vz = ix - tx, iz - tz
        len = math.sqrt(vx * vx + vz * vz)
    end
    if len < 0.01 then
        vx, vz = 1, 0
        len = 1
    end
    vx, vz = vx / len, vz / len

    local base = math.atan2(vz, vx)
    local try_offsets = {
        0,
        math.rad(20), -math.rad(20),
        math.rad(40), -math.rad(40),
        math.rad(70), -math.rad(70),
        math.rad(100), -math.rad(100),
        math.rad(140), -math.rad(140),
        PI,
    }

    local best_x, best_z = nil, nil
    for _, off in ipairs(try_offsets) do
        local a = base + off
        local px = tx + math.cos(a) * hop_dist
        local pz = tz + math.sin(a) * hop_dist
        if IsValidHopPoint(px, pz) then
            best_x, best_z = px, pz
            break
        end
    end

    if best_x == nil then
        Dbg(inst, "hop_fail reason=no_valid_strategic_dst")
        return false
    end

    local token = (inst._wortox_soulhop_token or 0) + 1
    inst._wortox_soulhop_token = token
    inst._wortox_soulhop_active_token = token
    inst._wortox_soulhop_result = nil
    inst._wortox_soulhop_result_token = nil
    inst._wortox_soulhop_dest = Vector3(best_x, 0, best_z)

    SaySoulHopLine(inst)
    Dbg(inst, "hop_start_strategic token=%d threat=%s heal=%s dst=(%.1f, %.1f)", token, tostring(threat.prefab), tostring(toward_target.prefab), best_x, best_z)
    inst.sg:GoToState("wortox_soulhop_pre", {
        token = token,
        dest = inst._wortox_soulhop_dest,
    })
    return true, token
end

return M

