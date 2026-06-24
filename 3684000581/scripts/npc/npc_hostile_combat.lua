-- scripts/npc/npc_hostile_combat.lua
-- 敌对NPC专用战斗增强：受击僵直 + 受击后侧闪 + 反打
-- 仅给带 npc_hostile 标签的单位启用，不影响普通 NPC

local NPC_TUNING = require("npc_tuning")
local WurtCombat = require("npc/characters/wurt_combat")
local M = {}

local function _CanRun(inst)
    if not inst or not inst:IsValid() then return false end
    if not inst:HasTag("npc_hostile") then return false end
    if inst._is_ghost_mode then return false end
    if not inst.components or not inst.components.locomotor or not inst.components.combat then return false end
    if inst.components.health and inst.components.health:IsDead() then return false end
    if inst.sg and (inst.sg:HasStateTag("dead") or inst.sg:HasStateTag("frozen")) then
        return false
    end
    return true
end

local function _GetParam(name, fallback)
    local v = NPC_TUNING and NPC_TUNING[name] or nil
    if v == nil then return fallback end
    return v
end

local function _GetHostileParam(inst, webber_key, wurt_key, fallback)
    if inst and inst._is_wurt then
        local v = _GetParam(wurt_key, nil)
        if v ~= nil then return v end
    end
    if inst and inst._is_webber then
        local v = _GetParam(webber_key, nil)
        if v ~= nil then return v end
    end
    return fallback
end

local function _GetLeash(inst)
    return _GetHostileParam(inst, "HOSTILE_WEBBER_CHASE_RANGE", "HOSTILE_WURT_CHASE_RANGE", _GetParam("CHASE_RANGE", 20))
end

local function _GetHomePos(inst)
    local hx = inst and (inst._webber_home_x or inst._wurt_home_x) or nil
    local hz = inst and (inst._webber_home_z or inst._wurt_home_z) or nil
    return hx, hz
end

local function _HomeDistSq(inst, x, z)
    local hx, hz = _GetHomePos(inst)
    if not hx or not hz then return nil end
    local dx = x - hx
    local dz = z - hz
    return dx * dx + dz * dz
end

local function _IsOutsideHomeLeash(inst, x, z, extra)
    local d2 = _HomeDistSq(inst, x, z)
    if d2 == nil then return false end
    local r = _GetLeash(inst) + (extra or 0)
    return d2 > r * r
end

local function _FindOrangeStaff(inst)
    local inv = inst.components and inst.components.inventory or nil
    if not inv then return nil end
    local hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hands and hands.prefab == "orangestaff" then return hands end
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and item.prefab == "orangestaff" then
            return item
        end
    end
    return nil
end

local function _IsPointSafe(inst, x, z)
    if not (TheWorld and TheWorld.Map) then return false end
    return TheWorld.Map:IsPassableAtPoint(x, 0, z)
        and not TheWorld.Map:IsPointNearHole(Vector3(x, 0, z))
end

local function _HasSnareSpikeNear(x, z, radius)
    local r = radius or 1.6
    local spikes = _G.TheSim:FindEntities(x, 0, z, r, { "fossilspike" })
    if spikes and #spikes > 0 then
        return true
    end
    local gspikes = _G.TheSim:FindEntities(x, 0, z, r, { "groundspike" })
    return gspikes and #gspikes > 0
end

local function _HasShadowPillarNear(x, z, radius)
    local r = radius or 1.8
    local pillars = _G.TheSim:FindEntities(x, 0, z, r, { "shadow_pillar" })
    return pillars and #pillars > 0
end

local function _IsActuallyRootedByTrap(inst)
    if not inst then return false end
    if inst:HasTag("rooted") then return true end
    return inst.components ~= nil and inst.components.rooted ~= nil
end

local function _PostTeleportClearRooted(inst)
    if not inst then return end
    -- 兼容 shadow_pillar_target 的解除路径：主动广播传送与解除事件
    inst:PushEvent("teleported")
    inst:PushEvent("remove_shadow_pillars")
    inst:PushEvent("dispell_shadow_pillars")
end

local function _IsSnaredNow(inst)
    if not inst then return false end
    local now = GetTime and GetTime() or 0
    return (inst._hostile_snare_escape_pending == true)
        or (inst._hostile_snared_until ~= nil and now < inst._hostile_snared_until)
end

local function _SnareDbg(inst, fmt, ...)
    return
end

local function _TryTeleportOutOfSnare(inst, attacker)
    local staff = _FindOrangeStaff(inst)
    if not staff then
        _SnareDbg(inst, "ESCAPE_FAIL no orangestaff")
        return false
    end
    local ix, _, iz = inst.Transform:GetWorldPosition()

    local esc_dx, esc_dz = 1, 0
    if attacker and attacker.Transform then
        local ax, _, az = attacker.Transform:GetWorldPosition()
        local adx, adz = ix - ax, iz - az
        local al = math.sqrt(adx * adx + adz * adz)
        if al > 1e-6 then
            esc_dx, esc_dz = adx / al, adz / al
        end
    end

    local function _PickSafePoint(base_dx, base_dz)
        local base = math.atan2(base_dz, base_dx)
        local tries = {
            4.2, 4.8, 5.4, 6.0,
        }
        for _, d in ipairs(tries) do
            for _, off in ipairs({ 0, PI / 12, -PI / 12, PI / 6, -PI / 6, PI / 4, -PI / 4, PI / 3, -PI / 3, PI / 2, -PI / 2, PI }) do
                local a = base + off
                local tx, tz = ix + math.cos(a) * d, iz + math.sin(a) * d
                if _IsPointSafe(inst, tx, tz)
                    and not _HasSnareSpikeNear(tx, tz, 1.5)
                    and not _HasShadowPillarNear(tx, tz, 1.5) then
                    return tx, tz
                end
            end
        end
        return nil, nil
    end

    local tx, tz = _PickSafePoint(esc_dx, esc_dz)
    if not (tx and tz) then
        -- 攻击者方向失败时，做 360 度兜底，确保“优先脱笼”
        local rand_base = math.random() * (2 * PI)
        tx, tz = _PickSafePoint(math.cos(rand_base), math.sin(rand_base))
    end
    if not (tx and tz) then
        _SnareDbg(inst, "ESCAPE_FAIL no safe point outside snare")
        return false
    end
    _SnareDbg(inst, "ESCAPE_POINT picked (%.2f, %.2f)", tx, tz)

    local inv = inst.components and inst.components.inventory or nil
    if inv and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= staff then
        inv:Equip(staff)
    end
    local blinkstaff = staff.components and staff.components.blinkstaff or nil
    if blinkstaff then
        blinkstaff:SpawnEffect(inst)
        if blinkstaff.presound and blinkstaff.presound ~= "" then
            inst.SoundEmitter:PlaySound(blinkstaff.presound)
        end
        inst.Physics:Teleport(tx, 0, tz)
        _PostTeleportClearRooted(inst)
        blinkstaff:SpawnEffect(inst)
        if blinkstaff.postsound and blinkstaff.postsound ~= "" then
            inst.SoundEmitter:PlaySound(blinkstaff.postsound)
        end
    else
        inst.Physics:Teleport(tx, 0, tz)
        _PostTeleportClearRooted(inst)
    end
    _SnareDbg(inst, "ESCAPE_OK teleported to (%.2f, %.2f)", tx, tz)
    return true
end

local function _TryTeleportTowardHome(inst, attacker, dist_override)
    local hx, hz = _GetHomePos(inst)
    if not (inst and hx and hz) then
        _SnareDbg(inst, "HOME_TP_FAIL missing home anchor")
        return false
    end
    local staff = _FindOrangeStaff(inst)
    if not staff then
        _SnareDbg(inst, "HOME_TP_FAIL no orangestaff")
        return false
    end

    local ix, _, iz = inst.Transform:GetWorldPosition()
    local ddx, ddz = (hx - ix), (hz - iz)
    local ll = math.sqrt(ddx * ddx + ddz * ddz)
    local to_home_dx, to_home_dz = 0, 0
    if ll > 1e-6 then
        to_home_dx, to_home_dz = ddx / ll, ddz / ll
    end
    -- 若已贴近中心点，改用“远离攻击者”方向兜底，避免方向向量为 0 导致无法传送
    if to_home_dx == 0 and to_home_dz == 0 and attacker and attacker.Transform then
        local ax, _, az = attacker.Transform:GetWorldPosition()
        local adx, adz = ix - ax, iz - az
        local al = math.sqrt(adx * adx + adz * adz)
        if al > 1e-6 then
            to_home_dx, to_home_dz = adx / al, adz / al
        end
    end
    -- 仍无有效方向时，给一个固定兜底方向，保证 snared 时至少会尝试一次位移脱困
    if to_home_dx == 0 and to_home_dz == 0 then
        to_home_dx, to_home_dz = 1, 0
    end

    local tp_dist
    if dist_override ~= nil and tonumber(dist_override) ~= nil then
        tp_dist = math.max(1, tonumber(dist_override))
    else
        local tp_min = math.max(1, _GetHostileParam(inst, "HOSTILE_WEBBER_HOME_TP_MIN", "HOSTILE_WURT_HOME_TP_MIN", 6))
        local tp_max = math.max(tp_min, _GetHostileParam(inst, "HOSTILE_WEBBER_HOME_TP_MAX", "HOSTILE_WURT_HOME_TP_MAX", 8))
        tp_dist = tp_min + math.random() * (tp_max - tp_min)
    end
    local tx, tz = ix + to_home_dx * tp_dist, iz + to_home_dz * tp_dist
    if not _IsPointSafe(inst, tx, tz) then
        local base = math.atan2(to_home_dz, to_home_dx)
        for _, off in ipairs({ PI / 12, -PI / 12, PI / 6, -PI / 6, PI / 4, -PI / 4, PI / 3, -PI / 3 }) do
            local a = base + off
            local nx, nz = ix + math.cos(a) * tp_dist, iz + math.sin(a) * tp_dist
            if _IsPointSafe(inst, nx, nz) then
                tx, tz = nx, nz
                break
            end
        end
        if not _IsPointSafe(inst, tx, tz) then
            _SnareDbg(inst, "HOME_TP_FAIL no safe point")
            return false
        end
    end

    local inv = inst.components and inst.components.inventory or nil
    if inv and inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= staff then
        inv:Equip(staff)
    end
    local blinkstaff = staff.components and staff.components.blinkstaff or nil
    if blinkstaff then
        blinkstaff:SpawnEffect(inst)
        if blinkstaff.presound and blinkstaff.presound ~= "" then
            inst.SoundEmitter:PlaySound(blinkstaff.presound)
        end
        inst.Physics:Teleport(tx, 0, tz)
        _PostTeleportClearRooted(inst)
        blinkstaff:SpawnEffect(inst)
        if blinkstaff.postsound and blinkstaff.postsound ~= "" then
            inst.SoundEmitter:PlaySound(blinkstaff.postsound)
        end
    else
        inst.Physics:Teleport(tx, 0, tz)
        _PostTeleportClearRooted(inst)
    end
    _SnareDbg(inst, "HOME_TP_OK teleported to (%.2f, %.2f)", tx, tz)
    return true
end

local function _TrySnareEscapeToHome(inst, attacker)
    if not _CanRun(inst) then
        _SnareDbg(inst, "SNARE_ESCAPE_FAIL _CanRun=false")
        return false
    end
    -- 仅敌对韦伯/沃特启用骨刺笼逃脱
    if not (inst._is_webber or inst._is_wurt) then
        _SnareDbg(inst, "SNARE_ESCAPE_FAIL not webber/wurt")
        return false
    end
    if _FindOrangeStaff(inst) == nil then
        _SnareDbg(inst, "SNARE_ESCAPE_FAIL no orangestaff")
        return false
    end
    -- 优先按中心点方向传送（你的要求）
    local hx, hz = _GetHomePos(inst)
    if hx and hz then
        local ok = _TryTeleportTowardHome(inst, attacker)
        _SnareDbg(inst, "SNARE_ESCAPE_%s by home only", ok and "OK" or "FAIL")
        return ok
    end
    _SnareDbg(inst, "SNARE_ESCAPE_HOME_MISSING use out-of-snare fallback")
    -- 只有缺失中心点时，才用任意方向兜底脱困
    if _TryTeleportOutOfSnare(inst, attacker) then
        _SnareDbg(inst, "SNARE_ESCAPE_OK by out-of-snare fallback")
        return true
    end
    _SnareDbg(inst, "SNARE_ESCAPE_FAIL no home and fallback failed")
    return false
end

local function _ShouldReturnHome(inst)
    local hx, hz = _GetHomePos(inst)
    if not hx or not hz then return false end
    if inst._is_ghost_mode then return false end
    if not _CanRun(inst) then return false end
    -- 仅在无战斗目标时回圈，避免与追击/闪避流程抢控制
    if inst.components and inst.components.combat and inst.components.combat.target ~= nil then
        return false
    end
    local x, _, z = inst.Transform:GetWorldPosition()
    return _IsOutsideHomeLeash(inst, x, z, 0)
end

local function _StateName(inst)
    if not inst or not inst.sg or not inst.sg.currentstate then return "nil" end
    return inst.sg.currentstate.name or "nil"
end

local function _PosStr(inst)
    if not inst or not inst.Transform then return "(nil)" end
    local x, y, z = inst.Transform:GetWorldPosition()
    return string.format("(%.2f, %.2f, %.2f)", x or 0, y or 0, z or 0)
end

local function _DebugOn()
    return _GetParam("HOSTILE_WEBBER_DODGE_DEBUG", false) == true
        or _GetParam("HOSTILE_WURT_DODGE_DEBUG", false) == true
end

local function _Dbg(inst, fmt, ...)
    if not _DebugOn() then return end
    local guid = inst and inst.GUID or 0
    local t = GetTime and GetTime() or 0
    local prefix = string.format("[WEBBER_DODGE][%.3f][%s]", t, tostring(guid))
    if select("#", ...) > 0 then
        print(prefix .. " " .. string.format(fmt, ...))
    else
        print(prefix .. " " .. tostring(fmt))
    end
end

local function _TryHitStun(inst)
    -- 敌对韦伯关闭受击僵直动画（防止参数改动后被重新触发）
    if inst and (inst._is_webber or inst._is_wurt) then return end
    if not inst.sg or not inst.sg.currentstate then return end
    if inst.sg:HasStateTag("dead") or inst.sg:HasStateTag("frozen") then return end
    if inst.sg:HasStateTag("nointerrupt") then return end
    if inst.sg.currentstate.name ~= "hit" and inst.sg:HasState("hit") then
        inst.sg:GoToState("hit")
    end
end

local SPEED_PRIORITY = { orangestaff = 1, cane = 2 }

local function _FindSpeedItem(inst)
    local inv = inst.components and inst.components.inventory or nil
    if not inv then return nil end
    local best, best_pri, best_wsm = nil, 999, 0
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and item.components and item.components.equippable
           and item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
            local wsm = item.components.equippable:GetWalkSpeedMult()
            if wsm and wsm > 1 then
                local pri = SPEED_PRIORITY[item.prefab] or 99
                if pri < best_pri or (pri == best_pri and wsm > best_wsm) then
                    best, best_pri, best_wsm = item, pri, wsm
                end
            end
        end
    end
    return best
end

local function _FindBestWeapon(inst)
    local inv = inst.components and inst.components.inventory or nil
    if not inv then return nil end
    local best, best_dmg = nil, 0
    local equipped = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equipped and equipped.components and equipped.components.weapon then
        best = equipped
        best_dmg = equipped.components.weapon:GetDamage(inst) or 0
    end
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and item.components and item.components.weapon
           and item.components.equippable
           and item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
            local dmg = item.components.weapon:GetDamage(inst) or 0
            if dmg > best_dmg then
                best, best_dmg = item, dmg
            end
        end
    end
    return best
end

local function _SwapToSpeedItem(inst)
    if inst._hostile_speed_swap_active then return end
    local inv = inst.components and inst.components.inventory or nil
    if not inv then return end
    local hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hands and hands.components and hands.components.equippable
       and (hands.components.equippable:GetWalkSpeedMult() or 1) > 1 then
        inst._hostile_speed_swap_active = true
        return
    end
    local speed_item = _FindSpeedItem(inst)
    if speed_item then
        inv:Equip(speed_item)
        inst._hostile_speed_swap_active = true
    end
end

local function _SwapBackToWeapon(inst)
    if not inst._hostile_speed_swap_active then return end
    local inv = inst.components and inst.components.inventory or nil
    if not inv then
        inst._hostile_speed_swap_active = nil
        return
    end
    local weapon = _FindBestWeapon(inst)
    if weapon and weapon ~= inv:GetEquippedItem(EQUIPSLOTS.HANDS) then
        inv:Equip(weapon)
    end
    inst._hostile_speed_swap_active = nil
end

local function _Normalize2D(dx, dz)
    local l = math.sqrt(dx * dx + dz * dz)
    if l <= 1e-6 then return 0, 0 end
    return dx / l, dz / l
end

local function _ComputeDodgePoint(inst, attacker, dodge_dist)
    local ix, _, iz = inst.Transform:GetWorldPosition()
    local ax, _, az = attacker.Transform:GetWorldPosition()
    local origin = Vector3(ix, 0, iz)

    -- ① 基础后撤：远离攻击者（后退）
    local back_dx, back_dz = _Normalize2D(ix - ax, iz - az)
    if back_dx == 0 and back_dz == 0 then
        local rot = inst.Transform:GetRotation() * DEGREES
        back_dx, back_dz = math.cos(rot), -math.sin(rot)
    end

    -- ② 围绕出生中心点：向中心轻微回拉，形成“斜后撤”
    local dir_dx, dir_dz = back_dx, back_dz
    local hx, hz = _GetHomePos(inst)
    if hx and hz then
        local home_dx, home_dz = _Normalize2D(hx - ix, hz - iz)
        local leash = _GetLeash(inst)
        local dist_home = math.sqrt((ix - hx) * (ix - hx)
                                  + (iz - hz) * (iz - hz))
        local home_pull = (dist_home > leash * 0.7) and 0.45 or 0.25
        -- 闪避优先：以后撤为主，仅轻微向中心点偏移，避免与栓绳回圈冲突。
        dir_dx, dir_dz = _Normalize2D(back_dx * 1.0 + home_dx * home_pull, back_dz * 1.0 + home_dz * home_pull)
    end

    local base = math.atan2(dir_dz, dir_dx)
    -- 以后撤方向为主，按小角度扇形尝试可走点（可轻微斜后）
    local tries = { 0, PI / 12, -PI / 12, PI / 6, -PI / 6, PI / 4, -PI / 4, PI / 3, -PI / 3 }
    for _, off in ipairs(tries) do
        local angle = base + off
        local offset = FindWalkableOffset(origin, angle, dodge_dist, 8, false, true)
        if offset then
            return Vector3(ix + offset.x, 0, iz + offset.z)
        end
    end

    -- 兜底：侧向尝试，避免极端地形下原地不动
    local side = (math.random() < 0.5) and (base + PI * 0.5) or (base - PI * 0.5)
    local side_off = FindWalkableOffset(origin, side, dodge_dist, 8, false, true)
    if side_off then
        return Vector3(ix + side_off.x, 0, iz + side_off.z)
    end
    return nil
end

local function _IsMeleeThreat(attacker, target)
    if not attacker or not attacker:IsValid() or not target or not target:IsValid() then return false end
    if not _GetHostileParam(target, "HOSTILE_WEBBER_DODGE_MELEE_ONLY", "HOSTILE_WURT_DODGE_MELEE_ONLY", true) then return true end

    local max_dist = _GetHostileParam(target, "HOSTILE_WEBBER_MELEE_THREAT_DIST", "HOSTILE_WURT_MELEE_THREAT_DIST", 3.5)
    local dist_sq = attacker:GetDistanceSqToInst(target)
    if dist_sq > (max_dist * max_dist) then
        return false
    end

    local combat = attacker.components and attacker.components.combat or nil
    if combat and combat.attackrange and combat.attackrange > max_dist then
        return false
    end
    return true
end

local function _TryDodge(inst, attacker, reason)
    if not _CanRun(inst) then return end
    if _IsSnaredNow(inst) then
        _SnareDbg(inst, "DODGE_BLOCKED reason=%s during snared window", tostring(reason or "unknown"))
        _Dbg(inst, "TRY_DODGE reason=%s blocked: snared window active", tostring(reason or "unknown"))
        return
    end
    if not attacker or not attacker:IsValid() then
        _Dbg(inst, "TRY_DODGE reason=%s blocked: attacker invalid", tostring(reason or "unknown"))
        return
    end
    if not _IsMeleeThreat(attacker, inst) then
        _Dbg(inst, "TRY_DODGE reason=%s blocked: not melee threat attacker=%s", tostring(reason or "unknown"), tostring(attacker.prefab))
        return
    end

    local dodge_cd = _GetHostileParam(inst, "HOSTILE_WEBBER_DODGE_COOLDOWN", "HOSTILE_WURT_DODGE_COOLDOWN", 0.9)
    local dodge_dist = _GetHostileParam(inst, "HOSTILE_WEBBER_DODGE_DIST", "HOSTILE_WURT_DODGE_DIST", 3.0)
    local run_spd = (inst.components and inst.components.locomotor and (inst.components.locomotor.runspeed or inst.components.locomotor.walkspeed)) or _GetHostileParam(inst, "HOSTILE_WEBBER_RUN_SPEED", "HOSTILE_WURT_RUN_SPEED", 7)
    local dodge_reach_ratio = _GetHostileParam(inst, "HOSTILE_WEBBER_DODGE_REACH_RATIO", "HOSTILE_WURT_DODGE_REACH_RATIO", 0.85)
    local dodge_max_time = math.max(0.35, (dodge_dist / math.max(0.1, run_spd)) + 0.25) 
    _Dbg(inst, "TRY_DODGE reason=%s state=%s pos=%s attacker=%s attacker_pos=%s",
        tostring(reason or "unknown"), _StateName(inst), _PosStr(inst), tostring(attacker.prefab), _PosStr(attacker))

    local now = GetTime()
    if inst._hostile_dodge_lock_until and now < inst._hostile_dodge_lock_until then
        _Dbg(inst, "TRY_DODGE blocked by lock remain=%.3f", inst._hostile_dodge_lock_until - now)
        return
    end
    if inst._hostile_dodge_cd and now < inst._hostile_dodge_cd then
        _Dbg(inst, "TRY_DODGE blocked by cooldown remain=%.3f", inst._hostile_dodge_cd - now)
        return
    end

    if inst._is_wurt and _FindOrangeStaff(inst) ~= nil then
        local tp_chance = NPC_TUNING.HOSTILE_WURT_DODGE_TELEPORT_CHANCE
        if tp_chance == nil then tp_chance = 0.3 end
        if math.random() < tp_chance then
            local tp_dist = NPC_TUNING.HOSTILE_WURT_DODGE_TELEPORT_DIST or 7
            if _TryTeleportTowardHome(inst, attacker, tp_dist) then
                inst._hostile_dodge_cd = now + dodge_cd
                if inst.components and inst.components.locomotor then
                    inst.components.locomotor:Stop()
                end
                if inst.sg and inst.sg:HasState("idle")
                   and not inst.sg:HasStateTag("dead") and not inst.sg:HasStateTag("frozen") then
                    inst.sg:GoToState("idle")
                end
                WurtCombat.DoWeightedSpecial(inst, attacker)
                _Dbg(inst, "WURT_TELEPORT_DODGE dist=%.1f", tp_dist)
                return
            end
        end
    end

    inst._hostile_dodge_cd = now + dodge_cd
    inst._hostile_dodge_lock_until = now + dodge_max_time
    inst._hostile_external_dodge_until = now + dodge_max_time

    local dst = _ComputeDodgePoint(inst, attacker, dodge_dist)
    if not dst then
        _Dbg(inst, "DODGE_SELECT_POINT failed (no walkable offset)")
        return
    end
    _Dbg(inst, "DODGE_SELECT_POINT ok dst=(%.2f, %.2f, %.2f)", dst.x or 0, dst.y or 0, dst.z or 0)

    if inst.sg and not inst.sg:HasStateTag("dead") and not inst.sg:HasStateTag("frozen") then
        if inst.sg:HasState("idle") then
            inst.sg:GoToState("idle")
            _Dbg(inst, "DODGE_GOTO_IDLE from_state=%s", _StateName(inst))
        end
    end

    if inst.ClearBufferedAction then
        inst:ClearBufferedAction()
    end
    local sx, sy, sz = inst.Transform:GetWorldPosition()
    _SwapToSpeedItem(inst)
    inst.components.locomotor:Stop()
    inst.components.locomotor:GoToPoint(dst, nil, true)
    _Dbg(inst, "DODGE_MOVE_START state=%s from=(%.2f, %.2f, %.2f) to=(%.2f, %.2f, %.2f)",
        _StateName(inst), sx or 0, sy or 0, sz or 0, dst.x or 0, dst.y or 0, dst.z or 0)

    local c1 = _GetHostileParam(inst, "HOSTILE_WEBBER_DODGE_STUCK_CHECK_1", "HOSTILE_WURT_DODGE_STUCK_CHECK_1", 0.05)
    local c2 = _GetHostileParam(inst, "HOSTILE_WEBBER_DODGE_STUCK_CHECK_2", "HOSTILE_WURT_DODGE_STUCK_CHECK_2", 0.20)
    inst:DoTaskInTime(c1, function()
        if not inst or not inst:IsValid() then return end
        local x1, y1, z1 = inst.Transform:GetWorldPosition()
        local dx1, dz1 = (x1 - sx), (z1 - sz)
        local moved_sq = dx1 * dx1 + dz1 * dz1
        _Dbg(inst, "DODGE_MOVE_CHECK_1 t=%.2f moved=%.3f state=%s pos=(%.2f, %.2f, %.2f)",
            c1, math.sqrt(moved_sq or 0), _StateName(inst), x1 or 0, y1 or 0, z1 or 0)
        if (moved_sq or 0) < 0.01 then
            if inst.sg and inst.sg:HasState("idle") then
                inst.sg:GoToState("idle")
            end
            inst.components.locomotor:Stop()
            inst.components.locomotor:GoToPoint(dst, nil, true)
            _Dbg(inst, "DODGE_RETRY_GOTOPOINT dst=(%.2f, %.2f, %.2f) state=%s", dst.x or 0, dst.y or 0, dst.z or 0, _StateName(inst))
        end
    end)
    inst:DoTaskInTime(c2, function()
        if not inst or not inst:IsValid() then return end
        local x2, y2, z2 = inst.Transform:GetWorldPosition()
        local dx2, dz2 = (x2 - sx), (z2 - sz)
        local moved_sq = dx2 * dx2 + dz2 * dz2
        _Dbg(inst, "DODGE_MOVE_CHECK_2 t=%.2f moved=%.3f state=%s pos=(%.2f, %.2f, %.2f)%s",
            c2, math.sqrt(moved_sq or 0), _StateName(inst), x2 or 0, y2 or 0, z2 or 0,
            (moved_sq or 0) < 0.04 and " [POSSIBLE_STUCK]" or "")
    end)

    if inst._hostile_dodge_watch_task then
        inst._hostile_dodge_watch_task:Cancel()
        inst._hostile_dodge_watch_task = nil
    end
    if inst._hostile_retarget_task then
        inst._hostile_retarget_task:Cancel()
        inst._hostile_retarget_task = nil
    end

    local reach_sq = (dodge_dist * dodge_reach_ratio) * (dodge_dist * dodge_reach_ratio)
    local finished = false
    local function _FinishDodge(end_reason)
        if finished then return end
        finished = true
        inst._hostile_external_dodge_until = nil
        if inst._hostile_dodge_watch_task then
            inst._hostile_dodge_watch_task:Cancel()
            inst._hostile_dodge_watch_task = nil
        end
        if inst._hostile_retarget_task then
            inst._hostile_retarget_task:Cancel()
            inst._hostile_retarget_task = nil
        end
        if not _CanRun(inst) then return end
        inst.components.locomotor:Stop()
        _SwapBackToWeapon(inst)
        _Dbg(inst, "DODGE_MOVE_END reason=%s state=%s pos=%s", tostring(end_reason), _StateName(inst), _PosStr(inst))
        local chase_r = _GetLeash(inst)
        local can_react_now = false
        if attacker and attacker:IsValid() and inst.components.combat:CanTarget(attacker) then
            local dsq = inst:GetDistanceSqToInst(attacker)
            can_react_now = dsq <= (chase_r * chase_r)
            if can_react_now then
                inst._hostile_dodge_lock_until = nil
                inst.components.combat:SetTarget(attacker)
                _Dbg(inst, "DODGE_RETARGET attacker=%s", tostring(attacker.prefab))
            end
        end
        if not can_react_now and inst.components and inst.components.combat then
            inst.components.combat:GiveUp()
            _Dbg(inst, "DODGE_RETARGET skipped: attacker out of range")
        end
    end

    inst._hostile_dodge_watch_task = inst:DoPeriodicTask(0.03, function()
        if not inst or not inst:IsValid() then return end
        local cx, _, cz = inst.Transform:GetWorldPosition()
        local leash = _GetLeash(inst)
        if _IsOutsideHomeLeash(inst, cx, cz, 0) then
            local now = GetTime()
            local cd = math.max(0.2, _GetHostileParam(inst, "HOSTILE_WEBBER_OVERLEASH_TELEPORT_CD", "HOSTILE_WURT_OVERLEASH_TELEPORT_CD", 1.5))
            if not inst._webber_overleash_tp_cd or now >= inst._webber_overleash_tp_cd then
                if _TryTeleportTowardHome(inst) then
                    inst._webber_overleash_tp_cd = now + cd
                    _Dbg(inst, "DODGE_TELEPORT over leash=%.2f", leash)
                    _FinishDodge("over_leash_teleport")
                    return
                end
            end
        end
        local dx, dz = (cx - sx), (cz - sz)
        local moved_sq = dx * dx + dz * dz
        if moved_sq >= reach_sq then
            _Dbg(inst, "DODGE_REACH_OK moved=%.3f need=%.3f", math.sqrt(moved_sq), math.sqrt(reach_sq))
            _FinishDodge("reach_dist")
        end
    end)

    inst._hostile_retarget_task = inst:DoTaskInTime(dodge_max_time, function()
        _FinishDodge("timeout")
    end)
end

local function _IsAttackingTarget(attacker, target)
    if not attacker or not attacker:IsValid() or not target or not target:IsValid() then return false end
    if attacker.components and attacker.components.combat then
        local t = attacker.components.combat.target
        if t == target then return true end
    end
    return false
end

local function _LooksLikeAttackWindup(attacker, target)
    if not _IsAttackingTarget(attacker, target) then return false end
    if not _IsMeleeThreat(attacker, target) then return false end
    if not attacker.sg or not attacker.sg.currentstate then return false end
    local state = attacker.sg.currentstate
    local name = state.name or ""
    if state.tags and (state.tags.attack or state.tags.prehit or state.tags.abouttoattack) then
        return true
    end
    name = string.lower(name)
    if string.find(name, "attack", 1, true) or string.find(name, "pre", 1, true) then
        return true
    end
    return false
end

local function _StartPredodgeWatcher(inst)
    if inst._hostile_predodge_task then
        inst._hostile_predodge_task:Cancel()
        inst._hostile_predodge_task = nil
    end
    if not _GetHostileParam(inst, "HOSTILE_WEBBER_PREDODGE_ENABLE", "HOSTILE_WURT_PREDODGE_ENABLE", true) then
        return
    end
    local r = _GetHostileParam(inst, "HOSTILE_WEBBER_PREDODGE_RANGE", "HOSTILE_WURT_PREDODGE_RANGE", 6)
    local p = _GetHostileParam(inst, "HOSTILE_WEBBER_PREDODGE_PERIOD", "HOSTILE_WURT_PREDODGE_PERIOD", 0.05)
    inst._hostile_predodge_task = inst:DoPeriodicTask(p, function()
        if not _CanRun(inst) then return end
        if _IsSnaredNow(inst) then return end
        local now = GetTime()
        if inst._hostile_dodge_lock_until and now < inst._hostile_dodge_lock_until then
            return
        end
        local x, y, z = inst.Transform:GetWorldPosition()
        local threats = _G.TheSim:FindEntities(
            x, y, z, r,
            { "_combat" },
            { "INLIMBO", "playerghost", "FX", "DECOR", "wall" }
        )
        for _, e in ipairs(threats) do
            if e ~= inst and _LooksLikeAttackWindup(e, inst) then
                _Dbg(inst, "PREDODGE_DETECT attacker=%s attacker_state=%s", tostring(e.prefab), _StateName(e))
                _TryDodge(inst, e, "predodge")
                return
            end
        end
    end)
end

function M.Attach(inst)
    if not inst or not inst:IsValid() then return end
    if not inst:HasTag("npc_hostile") then return end
    if inst._hostile_dodge_installed then return end
    inst._hostile_dodge_installed = true

    -- 独立参数：移速/攻击间隔（仅 hostile 生效）
    local run_spd = _GetHostileParam(inst, "HOSTILE_WEBBER_RUN_SPEED", "HOSTILE_WURT_RUN_SPEED", 7)
    local atk_period = _GetHostileParam(inst, "HOSTILE_WEBBER_ATTACK_PERIOD", "HOSTILE_WURT_ATTACK_PERIOD", 0.65)
    local atk_range = _GetHostileParam(inst, "HOSTILE_WEBBER_ATTACK_RANGE", "HOSTILE_WURT_ATTACK_RANGE", 2)
    if inst.components and inst.components.locomotor then
        inst.components.locomotor.walkspeed = run_spd
        inst.components.locomotor.runspeed = run_spd
    end
    if inst.components and inst.components.combat then
        inst.components.combat:SetAttackPeriod(atk_period)
        inst.components.combat:SetRange(atk_range)
    end

    local hitstun_time = _GetHostileParam(inst, "HOSTILE_WEBBER_HITSTUN_TIME", "HOSTILE_WURT_HITSTUN_TIME", 0.16)
    inst._hostile_on_attacked = function(_, data)
        local attacker = data and data.attacker or nil
        _Dbg(inst, "ON_ATTACKED attacker=%s attacker_state=%s self_state=%s self_pos=%s",
            tostring(attacker and attacker.prefab or "nil"),
            _StateName(attacker),
            _StateName(inst),
            _PosStr(inst))
        if inst._is_wurt and attacker ~= nil and attacker:IsValid()
            and inst.components.combat ~= nil and inst.components.combat:CanTarget(attacker) then
            local dist = TUNING.MERM_SHARE_TARGET_DIST or 30
            local maxshares = TUNING.MERM_MAX_TARGET_SHARES or 8
            inst.components.combat:ShareTarget(attacker, dist, function(dude)
                return dude ~= inst and not dude.isplayer and dude:HasTag("merm")
                    and dude.components.health ~= nil and not dude.components.health:IsDead()
            end, maxshares)
        end
        if hitstun_time > 0 then
            _TryHitStun(inst)
            inst:DoTaskInTime(hitstun_time, function()
                _TryDodge(inst, attacker, "attacked_after_hitstun")
            end)
        else
            _TryDodge(inst, attacker, "attacked_immediate")
        end
    end
    inst:ListenForEvent("attacked", inst._hostile_on_attacked)

    if inst._is_wurt then
        inst._wurt_miss_streak = 0
        inst._wurt_on_attackother = function(i)
            i._wurt_miss_streak = 0
        end
        inst._wurt_on_missother = function(i)
            i._wurt_miss_streak = (i._wurt_miss_streak or 0) + 1
            local need = NPC_TUNING.HOSTILE_WURT_MISS_TRIGGER_COUNT or 3
            if i._wurt_miss_streak >= need then
                i._wurt_miss_streak = 0
                i._wurt_skill_pending = true
            end
        end
        inst:ListenForEvent("onattackother", inst._wurt_on_attackother)
        inst:ListenForEvent("onmissother", inst._wurt_on_missother)
    end

    -- 被远古织影者骨刺笼困住时：延迟后向中心点方向传送脱困
    inst._hostile_snare_escape_pending = false
    local function _TriggerSnareEscape(i, attacker, source)
        if _IsActuallyRootedByTrap(i) and i._hostile_rooted_escape_done then
            _SnareDbg(i, "%s_IGNORED rooted escape already done for this rooted cycle", tostring(source or "SNARE"))
            return
        end
        if i._hostile_snare_escape_pending then
            _SnareDbg(i, "%s_IGNORED pending=true", tostring(source or "SNARE"))
            return
        end
        if not (i._is_webber or i._is_wurt) then
            _SnareDbg(i, "%s_IGNORED not webber/wurt", tostring(source or "SNARE"))
            return
        end
        if _FindOrangeStaff(i) == nil then
            _SnareDbg(i, "%s_IGNORED no orangestaff", tostring(source or "SNARE"))
            return
        end
        _SnareDbg(i, "%s_EVENT attacker=%s pos=%s", tostring(source or "SNARE"), tostring(attacker and attacker.prefab or "nil"), _PosStr(i))
        i._hostile_snared_until = (GetTime and GetTime() or 0) + 2.5
        -- 被困后先停下当前闪避位移，避免继续撞笼抢控制
        if i.components and i.components.locomotor then
            i.components.locomotor:Stop()
        end
        i._hostile_dodge_lock_until = nil
        i._hostile_external_dodge_until = nil
        if i._hostile_dodge_watch_task then
            i._hostile_dodge_watch_task:Cancel()
            i._hostile_dodge_watch_task = nil
        end
        if i._hostile_retarget_task then
            i._hostile_retarget_task:Cancel()
            i._hostile_retarget_task = nil
        end
        i._hostile_snare_escape_pending = true
        i:DoTaskInTime(1.0, function(i2)
            if not (i2 and i2:IsValid()) then return end
            i2._hostile_snare_escape_pending = false
            _SnareDbg(i2, "%s_TRY_ESCAPE delay=1.0", tostring(source or "SNARE"))
            if _TrySnareEscapeToHome(i2, attacker) then
                if _IsActuallyRootedByTrap(i2) then
                    i2._hostile_rooted_escape_done = true
                end
                if i2.sg and (i2.sg:HasStateTag("busy") or i2.sg:HasStateTag("attack")) and i2.sg:HasState("idle") then
                    i2.sg:GoToState("idle")
                end
            else
                _SnareDbg(i2, "%s_ESCAPE_RESULT fail", tostring(source or "SNARE"))
            end
            i2._hostile_snared_until = nil
        end)
    end
    inst._hostile_on_snared = function(i, data)
        local attacker = data and data.attacker or nil
        _TriggerSnareEscape(i, attacker, "SNARED")
    end
    inst:ListenForEvent("snared", inst._hostile_on_snared)
    -- 兜底：麦斯威尔暗影牢笼会给目标加 rooted；直接监听 rooted 事件触发脱困
    inst._hostile_on_rooted = function(i)
        i._hostile_rooted_escape_done = false
        _TriggerSnareEscape(i, nil, "ROOTED")
    end
    inst:ListenForEvent("rooted", inst._hostile_on_rooted)
    inst._hostile_on_unrooted = function(i)
        i._hostile_rooted_escape_done = nil
        _SnareDbg(i, "UNROOTED clear rooted escape lock")
    end
    inst:ListenForEvent("unrooted", inst._hostile_on_unrooted)
    -- 兜底：若事件投递异常，则轮询 rooted 状态强制触发脱困
    if inst._hostile_snare_probe_task then
        inst._hostile_snare_probe_task:Cancel()
        inst._hostile_snare_probe_task = nil
    end
    inst._hostile_snare_probe_task = inst:DoPeriodicTask(0.2, function(i)
        if not _CanRun(i) then return end
        if not (i._is_webber or i._is_wurt) then return end
        if i._hostile_snare_escape_pending then return end
        if i._hostile_rooted_escape_done then return end
        if _FindOrangeStaff(i) == nil then return end
        if not _IsActuallyRootedByTrap(i) then return end
        _SnareDbg(i, "ROOTED_PROBE_TRIGGER rooted without event")
        _TriggerSnareEscape(i, nil, "ROOTED_PROBE")
    end)
    _StartPredodgeWatcher(inst)

    if inst._hostile_home_return_task then
        inst._hostile_home_return_task:Cancel()
        inst._hostile_home_return_task = nil
    end
    inst._hostile_home_return_task = inst:DoPeriodicTask(0.15, function()
        if not _ShouldReturnHome(inst) then return end
        local hx, hz = _GetHomePos(inst)
        if not hx or not hz then return end
        local dst = Vector3(hx, 0, hz)
        _SwapToSpeedItem(inst)
        inst.components.locomotor:GoToPoint(dst, nil, true)
        if inst:GetDistanceSqToPoint(dst) <= 2.5 * 2.5 then
            _SwapBackToWeapon(inst)
        end
    end)

    if not inst._hostile_onremove_cleanup_added then
        inst._hostile_onremove_cleanup_added = true
        inst:ListenForEvent("onremove", function(i)
            if i._hostile_home_return_task then
                i._hostile_home_return_task:Cancel()
                i._hostile_home_return_task = nil
            end
            if i._hostile_predodge_task then
                i._hostile_predodge_task:Cancel()
                i._hostile_predodge_task = nil
            end
            if i._hostile_dodge_watch_task then
                i._hostile_dodge_watch_task:Cancel()
                i._hostile_dodge_watch_task = nil
            end
            if i._hostile_retarget_task then
                i._hostile_retarget_task:Cancel()
                i._hostile_retarget_task = nil
            end
            if i._hostile_snare_probe_task then
                i._hostile_snare_probe_task:Cancel()
                i._hostile_snare_probe_task = nil
            end
            if i._hostile_on_snared then
                i:RemoveEventCallback("snared", i._hostile_on_snared)
                i._hostile_on_snared = nil
            end
            if i._hostile_on_rooted then
                i:RemoveEventCallback("rooted", i._hostile_on_rooted)
                i._hostile_on_rooted = nil
            end
            if i._hostile_on_unrooted then
                i:RemoveEventCallback("unrooted", i._hostile_on_unrooted)
                i._hostile_on_unrooted = nil
            end
            if i._wurt_on_attackother then
                i:RemoveEventCallback("onattackother", i._wurt_on_attackother)
                i._wurt_on_attackother = nil
            end
            if i._wurt_on_missother then
                i:RemoveEventCallback("onmissother", i._wurt_on_missother)
                i._wurt_on_missother = nil
            end
            i._wurt_miss_streak = nil
            i._wurt_skill_pending = nil
            i._hostile_snare_escape_pending = nil
            i._hostile_snared_until = nil
            i._hostile_rooted_escape_done = nil
        end)
    end
end

-- ════════════════════════════════════════════════════════════
--  掉落工具函数（从 webber.lua / wurt.lua 提取）
-- ════════════════════════════════════════════════════════════

--- 按权重随机选取一个 prefab
--- @param items table  {{ prefab = string, weight = number }, ...}
--- @return string|nil
function M.PickWeightedPrefab(items)
    if type(items) ~= "table" then return nil end
    local total = 0
    for _, v in ipairs(items) do
        local w = (type(v) == "table" and tonumber(v.weight)) or 0
        if w and w > 0 and type(v.prefab) == "string" and v.prefab ~= "" then
            total = total + w
        end
    end
    if total <= 0 then return nil end

    local r = math.random() * total
    local acc = 0
    for _, v in ipairs(items) do
        local w = (type(v) == "table" and tonumber(v.weight)) or 0
        if w and w > 0 and type(v.prefab) == "string" and v.prefab ~= "" then
            acc = acc + w
            if r <= acc then
                return v.prefab
            end
        end
    end
    return nil
end

--- 在实体位置生成一个掉落物并赋予随机弹射速度
--- @param inst   entity 参照实体（取坐标）
--- @param prefab string 要生成的 prefab 名称
--- @return boolean 是否成功生成
function M.SpawnLootAt(inst, prefab)
    if not inst or not inst:IsValid() then return false end
    if type(prefab) ~= "string" or prefab == "" then return false end
    local loot = SpawnPrefab(prefab)
    if not loot then return false end
    if not inst:IsValid() then
        -- inst may have been removed during SpawnPrefab; drop loot at origin
        loot:Remove()
        return false
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    loot.Transform:SetPosition(x, y, z)
    if loot.Physics then
        local theta = math.random() * 2 * math.pi
        local speed = 1 + math.random() * 1.5
        loot.Physics:SetVel(math.cos(theta) * speed, 2 + math.random(), math.sin(theta) * speed)
    end
    return true
end

return M
