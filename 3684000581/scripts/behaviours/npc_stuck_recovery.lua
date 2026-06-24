-- behaviours/npc_stuck_recovery.lua
-- NPC 卡住检测与侧向绕行恢复（通用，覆盖所有移动行为）
--
-- 检测原理：记录「观测起点」，检查 STUCK_THRESHOLD 秒内是否从起点
--           移动了足够远（> PROGRESS_DIST）。物理碰撞抖动每帧约 0.1~0.2
--           格，累积位移极小，不会骗过累积检测。
--
-- 绕行策略：
--   Phase 1 (0~2s): 找到最近阻挡物，根据其物理碰撞半径计算绕行距离，
--                    朝其侧面方向绕行
--   Phase 2 (2~4s): 换另一侧尝试
--   Phase 3 (>5s):  放弃，停在原地，等待 brain 重新调度
--
-- 重物适配：背负 heavy 物品时速度仅 0.15x，普通超时内无法到达绕行目标，
--   因此缩短绕行距离(1.5~2格)、延长单侧超时(6s)和总超时(15s)。
--
-- 行为树优先级位于 Combat 之下、Work/Farming/Follow/Wander 之上：
--   - 检测阶段返回 FAILED → 不干预正常移动
--   - 恢复阶段返回 RUNNING → 抢占所有低优先级行为，控制绕行
--   - 恢复完成返回 SUCCESS/FAILED → 释放控制，brain 重新调度
-- ────────────────────────────────────────────────────────────

-- ── 内部常量 ──
local NPC_TUNING = require("npc_tuning")
local CHECK_INTERVAL   = NPC_TUNING.STUCK_CHECK_INTERVAL or 0.5   
local STUCK_THRESHOLD  = NPC_TUNING.STUCK_THRESHOLD or 1.5   
local PROGRESS_DIST_SQ = NPC_TUNING.STUCK_PROGRESS_DIST_SQ or 1.0   
local ESCAPE_DIST_SQ   = NPC_TUNING.STUCK_ESCAPE_DIST_SQ or 2.25  
local SIDESTEP_DIST    = NPC_TUNING.STUCK_SIDESTEP_DIST or 3     
local HEAVY_STEP_DIST  = NPC_TUNING.STUCK_HEAVY_STEP_DIST or 1.5   
local SIDESTEP_TIMEOUT = NPC_TUNING.STUCK_SIDESTEP_TIMEOUT or 2.0   
local GIVEUP_TIME      = NPC_TUNING.STUCK_GIVEUP_TIME or 5.0   


local IGNORE_TAGS = {
    "NOBLOCK", "player", "FX", "INLIMBO", "DECOR",
    "locomotor", "_inventoryitem", "farm_plant", "soil",
}





NPCStuckRecovery = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "NPCStuckRecovery")
    self.inst = inst
    
    self._last_check = 0
    self._obs_x      = nil   
    self._obs_z      = nil   
    self._obs_start  = 0     
    
    self._recovering = false
    self._rec_start  = 0
    self._rec_x      = nil   
    self._rec_z      = nil
    self._side_tried = 0
    self._is_heavy   = false  
end)

function NPCStuckRecovery:DBString()
    local elapsed = self._obs_start > 0 and (GetTime() - self._obs_start) or 0
    return string.format("StuckRecovery obs=%.1fs rec=%s side=%d",
        elapsed, tostring(self._recovering), self._side_tried)
end

function NPCStuckRecovery:_Reset()
    self._obs_x      = nil
    self._obs_z      = nil
    self._obs_start  = 0
    self._recovering = false
    self._rec_start  = 0
    self._rec_x      = nil
    self._rec_z      = nil
    self._side_tried = 0
    self._is_heavy   = false
end


function NPCStuckRecovery:_IsCarryingHeavy()
    local inv = self.inst.components.inventory
    if inv then
        local body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
        return body ~= nil and body:HasTag("heavy")
    end
    return false
end





function NPCStuckRecovery:_CalcSidestepTarget(side, is_heavy)
    local inst = self.inst
    local x, _, z = inst.Transform:GetWorldPosition()

    local ents = _G.TheSim:FindEntities(x, 0, z, 4, nil, IGNORE_TAGS)
    local nearest, min_dsq = nil, math.huge
    for _, e in ipairs(ents) do
        if e ~= inst and e:IsValid() and not e:IsInLimbo()
           and e.entity:IsVisible() then
            local ex, _, ez = e.Transform:GetWorldPosition()
            local dsq = (x - ex) * (x - ex) + (z - ez) * (z - ez)
            if dsq < min_dsq then
                min_dsq = dsq
                nearest = e
            end
        end
    end

    local obs_radius = 0
    if nearest and nearest.Physics then
        obs_radius = nearest.Physics:GetRadius() or 0
    end
    local step_dist
    if is_heavy then
        
        
        step_dist = math.max(HEAVY_STEP_DIST, obs_radius + 0.5 + math.random() * 0.5)
    else
        step_dist = math.max(SIDESTEP_DIST, obs_radius + 1 + math.random())
    end

    local side_angle
    if nearest then
        local bx, _, bz = nearest.Transform:GetWorldPosition()
        local away = math.atan2(z - bz, x - bx)
        side_angle = away + (side == 1 and math.pi / 2 or -math.pi / 2)
    else
        local facing = inst.Transform:GetRotation() * DEGREES
        side_angle = facing + (side == 1 and math.pi / 2 or -math.pi / 2)
    end

    local map = TheWorld and TheWorld.Map
    if not map then return nil end
    for _, d in ipairs({ step_dist, step_dist * 0.5 }) do
        local tx = x + d * math.cos(side_angle)
        local tz = z + d * math.sin(side_angle)
        if map:IsPassableAtPoint(tx, 0, tz) and not map:IsOceanAtPoint(tx, 0, tz) then
            return Vector3(tx, 0, tz)
        end
    end
    return nil
end




function NPCStuckRecovery:Visit()
    local inst = self.inst
    local loco = inst.components.locomotor
    if not loco then
        self.status = FAILED
        return
    end

    
    
    
    if self._recovering then
        local elapsed = GetTime() - self._rec_start

        
        local giveup  = self._is_heavy and (GIVEUP_TIME * 3) or GIVEUP_TIME
        local side_to = self._is_heavy and (SIDESTEP_TIMEOUT * 3) or SIDESTEP_TIMEOUT

        if elapsed >= giveup then
            loco:Stop()
            self:_Reset()
            self.status = FAILED
            return
        end

        local x, _, z = inst.Transform:GetWorldPosition()
        if self._rec_x then
            local dx = x - self._rec_x
            local dz = z - self._rec_z
            if dx * dx + dz * dz > ESCAPE_DIST_SQ then
                loco:Stop()
                self:_Reset()
                self.status = SUCCESS
                return
            end
        end

        if not loco:WantsToMoveForward() then
            self:_Reset()
            self.status = SUCCESS
            return
        end

        if self._side_tried == 1 and elapsed >= side_to then
            self._side_tried = 2
            local target = self:_CalcSidestepTarget(2, self._is_heavy)
            if target then
                loco:GoToPoint(target, nil, true)
            end
        end

        self.status = RUNNING
        return
    end

    
    
    
    
    

    if not loco:WantsToMoveForward()
       or (inst.sg and inst.sg:HasStateTag("busy")) then
        self:_Reset()
        self.status = FAILED
        return
    end

    local now = GetTime()
    local dt  = now - self._last_check
    if dt < CHECK_INTERVAL then
        self.status = FAILED
        return
    end
    self._last_check = now

    local x, _, z = inst.Transform:GetWorldPosition()

    if not self._obs_x then
        self._obs_x     = x
        self._obs_z     = z
        self._obs_start = now
        self.status = FAILED
        return
    end

    local dx = x - self._obs_x
    local dz = z - self._obs_z
    local progress_sq = dx * dx + dz * dz
    local obs_elapsed = now - self._obs_start

    if progress_sq >= PROGRESS_DIST_SQ then
        self._obs_x     = x
        self._obs_z     = z
        self._obs_start = now
        self.status = FAILED
        return
    end

    
    if obs_elapsed >= STUCK_THRESHOLD then
        loco:Stop()
        self._recovering = true
        self._rec_start  = now
        self._rec_x      = x
        self._rec_z      = z
        self._side_tried = 1
        self._is_heavy   = self:_IsCarryingHeavy()

        local target = self:_CalcSidestepTarget(1, self._is_heavy)
        if target then
            loco:GoToPoint(target, nil, true)
        else
            self._side_tried = 2
            target = self:_CalcSidestepTarget(2, self._is_heavy)
            if target then
                loco:GoToPoint(target, nil, true)
            end
        end
        self.status = RUNNING
        return
    end

    self.status = FAILED
end

return NPCStuckRecovery
