-- scripts/npc/npc_path_recovery.lua
-- NPC 共享路径恢复工具：卡住检测 + 行为树重置后的安全恢复

local GetTime = GetTime
local Vector3 = Vector3

local path_recovery = {}

--- 卡住检测与重试（纯双状态）
-- @param self       行为实例（状态存储在 self 上）
-- @param inst       NPC 实例
-- @param key_prefix 字符串前缀，区分不同阶段（如 "_approach" / "_deposit"）
-- @param config     配置表 { check_interval, min_move_dist }
-- @param dbg_fn     可选调试输出函数
-- @return "ok" | "retry"
function path_recovery.CheckStuckAndRetry(self, inst, key_prefix, config, dbg_fn)
    local now = GetTime()
    local check_time_key = key_prefix .. "_check_time"
    local check_x_key = key_prefix .. "_check_x"
    local check_z_key = key_prefix .. "_check_z"

    if not self[check_time_key] then
        local ax, _, az = inst.Transform:GetWorldPosition()
        self[check_time_key] = now
        self[check_x_key] = ax
        self[check_z_key] = az
        return "ok"
    end

    if now - self[check_time_key] < (config.check_interval or 6) then
        return "ok"
    end

    local ax, _, az = inst.Transform:GetWorldPosition()
    local dx = ax - self[check_x_key]
    local dz = az - self[check_z_key]
    local moved = math.sqrt(dx * dx + dz * dz)

    self[check_time_key] = now
    self[check_x_key] = ax
    self[check_z_key] = az

    if moved >= (config.min_move_dist or 2) then
        return "ok"
    end

    if dbg_fn then
        dbg_fn(string.format("CheckStuck[%s]: 卡住! moved=%.1f", key_prefix, moved))
    end
    return "retry"
end

--- 重置卡住检测状态
function path_recovery.ResetStuckCheck(self, key_prefix)
    self[key_prefix .. "_check_time"] = nil
    self[key_prefix .. "_check_x"] = nil
    self[key_prefix .. "_check_z"] = nil
end

--- 行为树重置后恢复 GoToPoint（不重置卡住计时）
-- @param self       行为实例
-- @param inst       NPC 实例
-- @param opts       { bt_flag_key, goto_issued_key, target_x, target_z, dist, dbg_fn, log_prefix }
-- @return boolean   true 表示已处理（包括仅消费 bt_flag）
function path_recovery.ResumeGoToAfterBTReset(self, inst, opts)
    local bt_flag_key = (opts and opts.bt_flag_key) or "_bt_just_reset"
    if not self[bt_flag_key] then
        return false
    end

    self[bt_flag_key] = nil

    local loco = inst.components.locomotor
    if not loco then
        return true
    end

    if loco.dest then
        return true
    end

    local tx = opts and opts.target_x
    local tz = opts and opts.target_z
    if tx == nil or tz == nil then
        return true
    end

    loco:GoToPoint(Vector3(tx, 0, tz), nil, true)
    if opts and opts.goto_issued_key then
        self[opts.goto_issued_key] = true
    end

    if opts and opts.dbg_fn then
        local dist = opts.dist or 0
        local prefix = opts.log_prefix or "PathRecovery"
        opts.dbg_fn(string.format("%s: 行为树重置后重发 GoToPoint (%.1f,%.1f) dist=%.1f", prefix, tx, tz, dist))
    end

    return true
end

return path_recovery
