-- scripts/behaviours/npc_fishing_behavior.lua
-- NPC 钓鱼行为模块：FishHere 按钮触发后自动前往池塘钓鱼
-- ────────────────────────────────────────────────────────────
-- 阶段流程：
--   idle → find_pond → approach → equip_rod → fishing → pickup_fish → murder_fish
--   → (未达上限且池塘有鱼? → fishing 继续钓 : → deposit_fish)
--   deposit_fish → deposit_approach → deposit_storing → (还有鱼? → deposit_approach : done)
--   deposit_fish → deposit_drop → done  (无容器时)
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")

local ACTIONS        = ACTIONS
local BufferedAction = BufferedAction
local EQUIPSLOTS     = EQUIPSLOTS
local GetTime        = GetTime
local Vector3        = Vector3
local PathRecovery   = require("npc/npc_path_recovery")
local InvUtil        = require("npc/npc_inventory_util")





local FISHING_SEE_DIST      = NPC_TUNING.FISHING_SEE_DIST      or 9999
local FISHING_APPROACH_DIST = NPC_TUNING.FISHING_APPROACH_DIST  or 3
local FISHING_MIN_FISH      = NPC_TUNING.FISHING_MIN_FISH       or 2
local FISHING_SCAN_INTERVAL = NPC_TUNING.FISHING_SCAN_INTERVAL  or 2
local APPROACH_WAYPOINT_STEP_SQ = NPC_TUNING.FISHING_APPROACH_WAYPOINT_STEP_SQ or 36
local DEPOSIT_WAYPOINT_STEP_SQ  = NPC_TUNING.FISHING_DEPOSIT_WAYPOINT_STEP_SQ or 25
local DEPOSIT_ARRIVE_DIST       = NPC_TUNING.FISHING_DEPOSIT_ARRIVE_DIST or 6


local EXCLUDE_TAGS = { "INLIMBO", "NOCLICK", "burnt" }


local DEFAULT_SAY_COOLDOWN = 15


local function _dbg(...) if NPC_TUNING.DEBUG_FISHING then print("[NPC_FISHING]", ...) end end



local function FindNearestReachableLandPoint(target_x, target_z, max_radius)
    local map = TheWorld and TheWorld.Map
    if not map then
        return target_x, target_z
    end
    if map:IsPassableAtPoint(target_x, 0, target_z) and not map:IsOceanAtPoint(target_x, 0, target_z) then
        return target_x, target_z
    end

    local radius_limit = max_radius or 24
    for r = 2, radius_limit, 2 do
        for deg = 0, 345, 15 do
            local rad = deg * DEGREES
            local x = target_x + math.cos(rad) * r
            local z = target_z + math.sin(rad) * r
            if map:IsPassableAtPoint(x, 0, z) and not map:IsOceanAtPoint(x, 0, z) then
                return x, z
            end
        end
    end
    return target_x, target_z
end

local function BuildReachableLandCandidates(target_x, target_z, max_radius)
    local map = TheWorld and TheWorld.Map
    local candidates = {}
    local seen = {}
    local function add_point(x, z)
        local key = string.format("%.1f,%.1f", x, z)
        if seen[key] then
            return
        end
        seen[key] = true
        table.insert(candidates, { x = x, z = z })
    end

    add_point(target_x, target_z)
    if not map then
        return candidates
    end

    local radius_limit = max_radius or 24
    for r = 3, radius_limit, 3 do
        for deg = 0, 345, 15 do
            local rad = deg * DEGREES
            local x = target_x + math.cos(rad) * r
            local z = target_z + math.sin(rad) * r
            if map:IsPassableAtPoint(x, 0, z) and not map:IsOceanAtPoint(x, 0, z) then
                add_point(x, z)
            end
        end
    end
    return candidates
end





local function CheckStuckAndRetry(self, inst, key_prefix, config)
    return PathRecovery.CheckStuckAndRetry(self, inst, key_prefix, config, _dbg)
end


local function ResetStuckCheck(self, key_prefix)
    PathRecovery.ResetStuckCheck(self, key_prefix)
end





local function IsPathClearBetween(map, x1, z1, x2, z2)
    local dx = x2 - x1
    local dz = z2 - z1
    local seg_dist = math.sqrt(dx * dx + dz * dz)
    local num_samples = math.max(5, math.min(30, math.ceil(seg_dist / 3)))

    for step = 1, num_samples do
        local t = step / (num_samples + 1)
        local sx = x1 + dx * t
        local sz = z1 + dz * t
        if map:IsOceanAtPoint(sx, 0, sz) then
            return false
        end
    end
    return true
end






local function PlanPathToTarget(inst, target_x, target_z)
    local map = TheWorld and TheWorld.Map
    local ax, _, az = inst.Transform:GetWorldPosition()

    _dbg(string.format("PlanPath: 从 (%.1f,%.1f) 到 (%.1f,%.1f)", ax, az, target_x, target_z))

    
    local direct_clear = true
    if map then
        if not IsPathClearBetween(map, ax, az, target_x, target_z) then
            direct_clear = false
            _dbg("PlanPath: 直线被水面阻挡")
        end
    end

    if direct_clear then
        _dbg("PlanPath: 直线路径畅通")
        return { { x = target_x, z = target_z } }
    end

    
    _dbg("PlanPath: 搜索绕路中间点...")
    local base_angle = math.atan2(target_z - az, target_x - ax)
    local try_offsets = { 0.5, -0.5, 1.0, -1.0, 1.5, -1.5, 2.0, -2.0, 2.5, -2.5 }
    local try_dists = { 10, 15, 20, 25, 8 }

    for _, angle_offset in ipairs(try_offsets) do
        local angle = base_angle + angle_offset
        for _, try_dist in ipairs(try_dists) do
            local wx = ax + math.cos(angle) * try_dist
            local wz = az + math.sin(angle) * try_dist

            if map and not map:IsOceanAtPoint(wx, 0, wz) and map:IsPassableAtPoint(wx, 0, wz) then
                if IsPathClearBetween(map, ax, az, wx, wz)
                   and IsPathClearBetween(map, wx, wz, target_x, target_z) then
                    _dbg(string.format("PlanPath: 找到中间点 (%.1f,%.1f) angle_offset=%.1f dist=%.0f",
                        wx, wz, angle_offset, try_dist))
                    return {
                        { x = wx, z = wz },
                        { x = target_x, z = target_z },
                    }
                end
            end
        end
    end

    
    _dbg("PlanPath: 单跳失败，尝试双跳...")
    for _, offset1 in ipairs({ 1.0, -1.0, 1.5, -1.5, 2.0, -2.0 }) do
        local angle1 = base_angle + offset1
        for _, dist1 in ipairs({ 10, 15, 20 }) do
            local w1x = ax + math.cos(angle1) * dist1
            local w1z = az + math.sin(angle1) * dist1

            if map and not map:IsOceanAtPoint(w1x, 0, w1z) and map:IsPassableAtPoint(w1x, 0, w1z)
               and IsPathClearBetween(map, ax, az, w1x, w1z) then
                local base_angle2 = math.atan2(target_z - w1z, target_x - w1x)
                for _, offset2 in ipairs({ 0.5, -0.5, 1.0, -1.0 }) do
                    local angle2 = base_angle2 + offset2
                    for _, dist2 in ipairs({ 10, 15 }) do
                        local w2x = w1x + math.cos(angle2) * dist2
                        local w2z = w1z + math.sin(angle2) * dist2

                        if map and not map:IsOceanAtPoint(w2x, 0, w2z) and map:IsPassableAtPoint(w2x, 0, w2z)
                           and IsPathClearBetween(map, w1x, w1z, w2x, w2z)
                           and IsPathClearBetween(map, w2x, w2z, target_x, target_z) then
                            _dbg(string.format("PlanPath: 双跳路线 → (%.1f,%.1f) → (%.1f,%.1f) → 目标",
                                w1x, w1z, w2x, w2z))
                            return {
                                { x = w1x, z = w1z },
                                { x = w2x, z = w2z },
                                { x = target_x, z = target_z },
                            }
                        end
                    end
                end
            end
        end
    end

    _dbg("PlanPath: 无法找到任何可行路径")
    return nil
end






local function HasFishingRod(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and (hand.prefab == "fishingrod" or hand:HasTag("fishingrod")) then
        return true
    end
    return inv:FindItem(function(item)
        return item.prefab == "fishingrod" or item:HasTag("fishingrod")
    end) ~= nil
end


local function CountFishingRods(inst)
    local inv = inst.components.inventory
    if not inv then return 0, 0 end
    local count = 0      
    local total_uses = 0  
    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and (hand.prefab == "fishingrod" or hand:HasTag("fishingrod")) then
        count = count + 1
        if hand.components.finiteuses then
            total_uses = total_uses + hand.components.finiteuses:GetUses()
        end
    end
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and (item.prefab == "fishingrod" or item:HasTag("fishingrod")) then
            count = count + 1
            if item.components.finiteuses then
                total_uses = total_uses + item.components.finiteuses:GetUses()
            end
        end
    end
    return count, total_uses
end


local function GetFishingRod(inst)
    local inv = inst.components.inventory
    if not inv then return nil end
    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and (hand.prefab == "fishingrod" or hand:HasTag("fishingrod")) then
        return hand
    end
    return inv:FindItem(function(item)
        return item.prefab == "fishingrod" or item:HasTag("fishingrod")
    end)
end


local function EquipFishingRod(inst)
    local inv = inst.components.inventory
    if not inv then return nil end
    local prev_hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if prev_hand and (prev_hand.prefab == "fishingrod" or prev_hand:HasTag("fishingrod")) then
        return nil  
    end
    local rod = inv:FindItem(function(item)
        return item.prefab == "fishingrod" or item:HasTag("fishingrod")
    end)
    if rod then
        inv:Equip(rod)
        _dbg("装备钓竿，保存之前手持:", prev_hand and prev_hand.prefab or "nil")
        return prev_hand
    end
    return prev_hand
end


local function SafeRestoreWeapon(inst, prev_hand)
    local inv = inst.components.inventory
    if not inv then return end
    if prev_hand and prev_hand:IsValid() then
        local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if not hand or hand.prefab == "fishingrod" or hand:HasTag("fishingrod") then
            inv:Equip(prev_hand)
            _dbg("恢复武器:", prev_hand.prefab)
        end
    else
        local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if hand and (hand.prefab == "fishingrod" or hand:HasTag("fishingrod")) then
            inv:Unequip(EQUIPSLOTS.HANDS)
            inv:GiveItem(hand)
            _dbg("钓竿收回背包")
        end
    end
end




local function FindNearestFishablePond(inst, blocked_ponds)
    local x, y, z = inst.Transform:GetWorldPosition()
    
    local ents = TheSim:FindEntities(x, y, z, FISHING_SEE_DIST,
        { "pond" },      
        EXCLUDE_TAGS      
    )

    local best = nil
    local best_dist_sq = math.huge

    for _, ent in ipairs(ents) do
        if ent:IsValid()
           and ent.components.fishable
           and not ent.components.fishable:IsFrozenOver()
           and ent.components.fishable.fishleft
           and ent.components.fishable.fishleft >= FISHING_MIN_FISH then

            
            if blocked_ponds and blocked_ponds[ent] then
                if NPC_TUNING.DEBUG_FISHING then
                    print("[NPC_FISHING]\tFindPond: 跳过已标记不可达池塘 " .. tostring(ent))
                end
            else
                
                local dist_sq = inst:GetDistanceSqToInst(ent)
                if dist_sq < best_dist_sq then
                    best = ent
                    best_dist_sq = dist_sq
                end
            end
        end
    end

    _dbg(string.format("搜索池塘: 范围=%d, 候选=%d, 选中=%s, 距离=%.1f",
        FISHING_SEE_DIST, #ents,
        best and tostring(best) or "nil",
        best and math.sqrt(best_dist_sq) or 0))

    return best
end





NPCFishingBehavior = Class(BehaviourNode, function(self, inst, config)
    BehaviourNode._ctor(self, "NPCFishingBehavior")
    self.inst   = inst
    self.config = config or {}

    
    self._phase          = "idle"    
    self._target_pond    = nil       
    self._last_scan_time = 0         
    self._prev_hand      = nil       
    
end)

function NPCFishingBehavior:DBString()
    return string.format("NPCFishingBehavior(phase=%s, pond=%s, catch=%d/%d)",
        tostring(self._phase),
        self._target_pond and tostring(self._target_pond) or "nil",
        self.inst._fishing_catch_count or 0,
        NPC_TUNING.FISHING_MAX_CATCH)
end





function NPCFishingBehavior:_SayLine(speech_key, cooldown)
    local inst = self.inst
    if not inst or not inst:IsValid() or not inst.components.talker then return end

    inst._fishing_say_cd = inst._fishing_say_cd or {}
    local now = GetTime()
    local cd = cooldown or DEFAULT_SAY_COOLDOWN

    if inst._fishing_say_cd[speech_key] and (now - inst._fishing_say_cd[speech_key]) < cd then
        return  
    end
    inst._fishing_say_cd[speech_key] = now

    local ok, NPC_SPEECH = pcall(function() return require("npc_speech") end)
    if not ok or not NPC_SPEECH then return end

    local pool = NPC_SPEECH[speech_key]
    if not pool then return end

    local line = NPC_SPEECH.GetLine(pool, inst.npc_character_type)
    if line then
        inst.components.talker:Say(line)
    end
end





function NPCFishingBehavior:_Reset()
    self._phase          = "idle"
    self._target_pond    = nil
    self._last_scan_time = 0
    
    self._murder_started = nil
    self._murder_delay_start = nil
    self._pickup_started = nil
    self._start_pos      = nil
    self._bt_just_reset = nil
    ResetStuckCheck(self, "_approach")
    self._approach_goto_issued = nil
    self._blocked_ponds = nil
    self._waypoints = nil
    self._waypoint_idx = nil
    self._last_deposit_log = nil
    self._deposit_phase_entered = nil
    self._deposit_drop_started = nil
    self._deposit_goto_issued = nil
    self._deposit_waypoints = nil
    self._deposit_wp_idx = nil
    self._deposit_route_candidates = nil
    self._deposit_route_try_idx = nil
    ResetStuckCheck(self, "_deposit")
    if self._path_search_handle then
        TheWorld.Pathfinder:KillSearch(self._path_search_handle)
        self._path_search_handle = nil
    end
    if self._deposit_search_handle then
        TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
        self._deposit_search_handle = nil
    end
    
    self._deposit_target_container = nil
    self._deposit_containers       = nil
    self._deposit_container_idx    = nil
    self._deposit_done             = nil
    
    if self.inst then
        self.inst._fishing_caught_fish = nil
        self.inst._fishing_caught_fish_item = nil
        self.inst._fishing_deposit_done = nil
    end
end

local function EnterDepositPhase(self, reason)
    if reason then _dbg(reason) end
    self._deposit_goto_issued = nil
    if self._deposit_search_handle then
        TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
        self._deposit_search_handle = nil
    end
    self._deposit_waypoints = nil
    self._deposit_wp_idx = nil
    self._deposit_phase_entered = nil
    ResetStuckCheck(self, "_deposit")
    self._phase = "deposit_fish"
end





function NPCFishingBehavior:Visit()
    local inst = self.inst

    if not inst:IsValid() or inst._is_ghost_mode then
        _dbg("Visit: NPC 无效或幽灵模式, FAILED")
        self.status = FAILED
        return
    end

    if not inst._fishing_active then
        if self._phase ~= "idle" then
            _dbg("Visit: 钓鱼被取消, phase=" .. tostring(self._phase) .. ", 恢复装备")
            SafeRestoreWeapon(inst, self._prev_hand)
            self._prev_hand = nil
        end
        self:_Reset()
        self.status = FAILED
        return
    end

    if self.status == READY then
        self.status = RUNNING
        
        
        if self._phase == nil or self._phase == "idle" or self._phase == "done" then
            self._phase = "idle"
            self._last_scan_time = 0
            
            if not inst._fishing_active then
                inst._fishing_catch_count = 0
            end
            _dbg("Visit: READY → RUNNING (全新开始), fishing_active=" .. tostring(inst._fishing_active)
                .. ", catch_count=" .. tostring(inst._fishing_catch_count))
        else
            
            self._bt_just_reset = true
            _dbg("Visit: READY → RUNNING (恢复), phase=" .. tostring(self._phase)
                .. ", catch_count=" .. tostring(inst._fishing_catch_count))
        end
    end

    if self.status == RUNNING then
        local sg_state = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name or "nil"
        local _throttle_phases = { approach = true, fishing = true, pickup_fish = true, murder_fish = true, deposit_fish = true, deposit_approach = true, deposit_storing = true, deposit_drop = true }
        if _throttle_phases[self._phase] then
            if not self._last_visit_log or GetTime() - self._last_visit_log > 2 then
                self._last_visit_log = GetTime()
                _dbg(string.format("Visit: phase=%s, sg=%s, pond=%s",
                    self._phase, sg_state,
                    self._target_pond and tostring(self._target_pond) or "nil"))
            end
        else
            self._last_visit_log = nil
            _dbg(string.format("Visit: phase=%s, sg=%s, pond=%s",
                self._phase, sg_state,
                self._target_pond and tostring(self._target_pond) or "nil"))
        end
        self:_RunPhase()
    end
end

function NPCFishingBehavior:_RunPhase()
    if self._phase == "idle" then
        self:_PhaseIdle()
    elseif self._phase == "find_pond" then
        self:_PhaseFindPond()
    elseif self._phase == "approach" then
        self:_PhaseApproach()
    elseif self._phase == "equip_rod" then
        self:_PhaseEquipRod()
    elseif self._phase == "fishing" then
        self:_PhaseFishing()
    elseif self._phase == "pickup_fish" then
        self:_PhasePickup()
    elseif self._phase == "murder_fish" then
        self:_PhaseMurderFish()
    elseif self._phase == "deposit_fish" then
        self:_PhaseDepositFish()
    elseif self._phase == "deposit_approach" then
        self:_PhaseDepositApproach()
    elseif self._phase == "deposit_storing" then
        self:_PhaseDepositStoring()
    elseif self._phase == "deposit_drop" then
        self:_PhaseDepositDrop()
    elseif self._phase == "done" then
        self:_PhaseDone()
    end
end





function NPCFishingBehavior:_PhaseIdle()
    local inst = self.inst
    _dbg("_PhaseIdle: fishing_active=" .. tostring(inst._fishing_active)
        .. ", catch_count=" .. tostring(inst._fishing_catch_count))
    self._start_pos = inst:GetPosition()
    _dbg(string.format("_PhaseIdle: 记录起始位置 (%.1f, %.1f)", self._start_pos.x, self._start_pos.z))
    self._phase = "find_pond"
    self._last_scan_time = 0
    _dbg("_PhaseIdle: → find_pond")
end

function NPCFishingBehavior:_PhaseFindPond()
    local inst = self.inst
    local now = GetTime()

    if now - self._last_scan_time < FISHING_SCAN_INTERVAL then
        return  
    end
    self._last_scan_time = now

    if not HasFishingRod(inst) then
        self:_SayLine("FISHING_NO_ROD", 30)
        _dbg("_PhaseFindPond: 无钓竿, FAILED")
        inst._fishing_active = false
        self:_Reset()
        self.status = FAILED
        return
    end

    local rod_count, total_uses = CountFishingRods(inst)
    local max_catch = NPC_TUNING.FISHING_MAX_CATCH or 3
    local current_count = inst._fishing_catch_count or 0
    local remaining_needed = max_catch - current_count
    if remaining_needed <= 0 then remaining_needed = 1 end

    if total_uses < remaining_needed then
        if current_count == 0 then
            self:_SayLine("FISHING_LOW_DURABILITY", 30)
            _dbg("_PhaseFindPond: 鱼竿耐久不足(首次), 需要" .. remaining_needed .. "点, 有" .. total_uses .. "点")
            inst._fishing_active = false
            self:_Reset()
            self.status = FAILED
            return
        else
            _dbg("_PhaseFindPond: 鱼竿耐久不足(换塘), 需要" .. remaining_needed .. "点, 有" .. total_uses .. "点, 已钓" .. current_count .. " → deposit_fish")
            
            self._deposit_goto_issued = nil
            if self._deposit_search_handle then
                TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
                self._deposit_search_handle = nil
            end
            self._deposit_waypoints = nil
            self._deposit_wp_idx = nil
            self._deposit_phase_entered = nil
            ResetStuckCheck(self, "_deposit")
            self._phase = "deposit_fish"
            return
        end
    end

    local deposit_pos = NPC_TUNING.FISHING_DEPOSIT_POS or inst._fishing_deposit_pos
    if not deposit_pos then
        _dbg("_PhaseFindPond: 未设置存放点, 提示玩家")
        self:_SayLine("FISHING_NO_DEPOSIT", 10)
        inst._fishing_active = false
        self.status = FAILED
        self:_Reset()
        return
    end

    self._target_pond = FindNearestFishablePond(inst, self._blocked_ponds)
    if not self._target_pond then
        self:_SayLine("FISHING_NO_POND", 30)
        _dbg("_PhaseFindPond: 未找到池塘, FAILED")
        inst._fishing_active = false
        self:_Reset()
        self.status = FAILED
        return
    end

    if (inst._fishing_catch_count or 0) == 0 then
        self:_SayLine("FISHING_START", 30)
    end

    self._phase = "approach"
    _dbg("_PhaseFindPond: 找到池塘 → approach")
end

function NPCFishingBehavior:_PhaseApproach()
    local inst = self.inst
    local pond = self._target_pond

    if not pond or not pond:IsValid() then
        _dbg("_PhaseApproach: 池塘无效 → find_pond")
        self._target_pond = nil
        
        self._approach_goto_issued = nil
        if self._path_search_handle then
            TheWorld.Pathfinder:KillSearch(self._path_search_handle)
            self._path_search_handle = nil
        end
        self._waypoints = nil
        self._waypoint_idx = nil
        ResetStuckCheck(self, "_approach")
        self._phase = "find_pond"
        return
    end

    
    if self._path_search_handle then
        local status = TheWorld.Pathfinder:GetSearchStatus(self._path_search_handle)
        if status == 1 then  
            local result = TheWorld.Pathfinder:GetSearchResult(self._path_search_handle)
            self._path_search_handle = nil
            if result and result.steps and #result.steps >= 2 then
                
                self._waypoints = {}
                local last_x, last_z = nil, nil
                for i = 2, #result.steps do
                    local step = result.steps[i]
                    if not last_x or ((step.x - last_x)^2 + (step.z - last_z)^2) >= APPROACH_WAYPOINT_STEP_SQ then
                        table.insert(self._waypoints, { x = step.x, z = step.z })
                        last_x, last_z = step.x, step.z
                    end
                end
                
                local final = result.steps[#result.steps]
                if #self._waypoints == 0 or
                   ((self._waypoints[#self._waypoints].x - final.x)^2 + (self._waypoints[#self._waypoints].z - final.z)^2) > 1 then
                    table.insert(self._waypoints, { x = final.x, z = final.z })
                end
                self._waypoint_idx = 1
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproach: 原生 A* 找到路径 (%d 个路径点)", #self._waypoints))
            else
                _dbg("_PhaseApproach: 原生 A* 返回无效路径，标记池塘不可达")
                self._blocked_ponds = self._blocked_ponds or {}
                self._blocked_ponds[pond] = true
                self._target_pond = nil
                self._phase = "find_pond"
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
            end
            return
        elseif status == 2 then  
            TheWorld.Pathfinder:KillSearch(self._path_search_handle)
            self._path_search_handle = nil
            local tx, _, tz = pond.Transform:GetWorldPosition()
            local fallback_path = PlanPathToTarget(inst, tx, tz)
            if fallback_path and #fallback_path > 0 then
                self._waypoints = fallback_path
                self._waypoint_idx = 1
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproach: 原生 A* 无路径，使用本地绕路方案 (%d 个路径点)", #fallback_path))
            else
                _dbg("_PhaseApproach: 原生 A* 未找到路径且本地绕路失败，标记池塘不可达")
                self._blocked_ponds = self._blocked_ponds or {}
                self._blocked_ponds[pond] = true
                self._target_pond = nil
                self._phase = "find_pond"
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
            end
            return
        end
        
        return
    end

    
    local dist_sq = inst:GetDistanceSqToInst(pond)
    if dist_sq <= FISHING_APPROACH_DIST * FISHING_APPROACH_DIST then
        inst.components.locomotor:Stop()
        self._phase = "equip_rod"
        self._waypoints = nil
        self._waypoint_idx = nil
        ResetStuckCheck(self, "_approach")
        _dbg(string.format("_PhaseApproach: 到达池塘 (dist=%.1f) → equip_rod", math.sqrt(dist_sq)))
        return
    end

    
    if self._waypoints then
        local wp = self._waypoints[self._waypoint_idx]
        if not wp then
            
            self._waypoints = nil
            self._waypoint_idx = nil
            self._approach_goto_issued = false
            return
        end

        local ax, _, az = inst.Transform:GetWorldPosition()
        local wp_dist = math.sqrt((ax - wp.x)^2 + (az - wp.z)^2)

        if wp_dist <= 3 then
            _dbg(string.format("_PhaseApproach: 到达路径点 %d/%d", self._waypoint_idx, #self._waypoints))
            self._waypoint_idx = self._waypoint_idx + 1
            self._approach_goto_issued = false
            ResetStuckCheck(self, "_approach")
            return
        end

        
        local stuck = CheckStuckAndRetry(self, inst, "_approach", { check_interval = 4, min_move_dist = 2 })
        if stuck == "retry" then
            _dbg("_PhaseApproach: waypoint 阶段卡住，标记池塘不可达")
            inst.components.locomotor:Stop()
            self._blocked_ponds = self._blocked_ponds or {}
            self._blocked_ponds[pond] = true
            self._target_pond = nil
            self._phase = "find_pond"
            self._waypoints = nil
            self._waypoint_idx = nil
            self._approach_goto_issued = false
            ResetStuckCheck(self, "_approach")
            return
        end

        
        local loco = inst.components.locomotor
        if not self._approach_goto_issued or not loco.dest then
            loco:GoToPoint(Vector3(wp.x, 0, wp.z), nil, true)
            self._approach_goto_issued = true
            _dbg(string.format("_PhaseApproach: GoToPoint → 路径点 %d/%d (%.1f,%.1f) dist=%.1f",
                self._waypoint_idx, #self._waypoints, wp.x, wp.z, wp_dist))
        end
        return
    end

    

    
    if not self._approach_goto_issued then
        local ax, _, az = inst.Transform:GetWorldPosition()
        local tx, _, tz = pond.Transform:GetWorldPosition()
        self:_SayLine("FISHING_PATH_PLANNING", 25)
        local search_pathcaps = {
            allowocean = false,
            ignoreLand = false,
            ignorecreep = true,
            ignorewalls = false,
        }
        local handle = TheWorld.Pathfinder:SubmitSearch(ax, 0, az, tx, 0, tz, search_pathcaps)
        if handle then
            self._path_search_handle = handle
            self._approach_goto_issued = true
            _dbg(string.format("_PhaseApproach: 预先提交原生 A* 搜索 从(%.1f,%.1f)到(%.1f,%.1f)", ax, az, tx, tz))
            return
        else
            local fallback_path = PlanPathToTarget(inst, tx, tz)
            if fallback_path and #fallback_path > 0 then
                self._waypoints = fallback_path
                self._waypoint_idx = 1
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproach: 预搜索提交失败，改用本地绕路方案 (%d 个路径点)", #fallback_path))
                return
            end
        end
    end

    
    local stuck_result = CheckStuckAndRetry(self, inst, "_approach", {
        check_interval = 6,  
        min_move_dist = 2,
    })
    if stuck_result == "retry" then
        inst.components.locomotor:Stop()
        self._approach_goto_issued = true  

        local ax, _, az = inst.Transform:GetWorldPosition()
        local tx, _, tz = pond.Transform:GetWorldPosition()
        
        local search_pathcaps = {
            allowocean = false,
            ignoreLand = false,
            ignorecreep = true,
            ignorewalls = false,
        }
        local handle = TheWorld.Pathfinder:SubmitSearch(ax, 0, az, tx, 0, tz, search_pathcaps)
        if handle then
            self._path_search_handle = handle
            _dbg(string.format("_PhaseApproach: 卡住! 提交原生 A* 搜索 从(%.1f,%.1f)到(%.1f,%.1f)", ax, az, tx, tz))
        else
            local fallback_path = PlanPathToTarget(inst, tx, tz)
            if fallback_path and #fallback_path > 0 then
                self._waypoints = fallback_path
                self._waypoint_idx = 1
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproach: SubmitSearch 失败，改用本地绕路方案 (%d 个路径点)", #fallback_path))
            else
                _dbg("_PhaseApproach: SubmitSearch 失败且本地绕路失败，标记池塘不可达")
                self._blocked_ponds = self._blocked_ponds or {}
                self._blocked_ponds[pond] = true
                self._target_pond = nil
                self._phase = "find_pond"
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
            end
        end
        return
    end

    
    if not self._approach_goto_issued then
        local loco = inst.components.locomotor
        local tx, ty, tz = pond.Transform:GetWorldPosition()
        loco:GoToPoint(Vector3(tx, ty, tz), nil, true)
        self._approach_goto_issued = true
        _dbg(string.format("_PhaseApproach: GoToPoint → 池塘 (%.1f,%.1f) dist=%.1f (A* 寻路)",
            tx, tz, math.sqrt(dist_sq)))
    elseif self._bt_just_reset then
        local tx, _, tz = pond.Transform:GetWorldPosition()
        PathRecovery.ResumeGoToAfterBTReset(self, inst, {
            goto_issued_key = "_approach_goto_issued",
            target_x = tx,
            target_z = tz,
            dist = math.sqrt(dist_sq),
            dbg_fn = _dbg,
            log_prefix = "_PhaseApproach",
        })
    end
end

function NPCFishingBehavior:_PhaseEquipRod()
    local inst = self.inst

    self._prev_hand = EquipFishingRod(inst)

    local hand = inst.components.inventory
        and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if not hand or (hand.prefab ~= "fishingrod" and not hand:HasTag("fishingrod")) then
        _dbg("_PhaseEquipRod: 装备钓竿失败 → FAILED")
        self:_SayLine("FISHING_NO_ROD", 30)
        inst._fishing_active = false
        self:_Reset()
        self.status = FAILED
        return
    end

    local inv = inst.components.inventory
    if inv then
        local current_head = inv:GetEquippedItem(EQUIPSLOTS.HEAD)
        if not current_head or current_head.prefab ~= "strawhat" then
            local hat = inv:FindItem(function(item)
                return item.prefab == "strawhat"
            end)
            if hat then
                inv:Equip(hat)
                _dbg("_PhaseEquipRod: 装备草帽（钓鱼结束后保留）")
            end
        end
    end

    self._phase = "fishing"
    _dbg("_PhaseEquipRod: 钓竿已装备 → fishing")
end

function NPCFishingBehavior:_PhaseFishing()
    local inst = self.inst

    if not InvUtil.HasInventorySpace(inst) then
        EnterDepositPhase(self, "_PhaseFishing: 口袋和已装备背包都已满 → deposit_fish")
        return
    end

    local current_hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local hand_is_rod = current_hand and (current_hand.prefab == "fishingrod" or current_hand:HasTag("fishingrod"))
    if not hand_is_rod then
        _dbg("_PhaseFishing: 手持不是鱼竿 (current=" .. (current_hand and current_hand.prefab or "nil") .. "), 尝试装备")
        if HasFishingRod(inst) then
            local rod = GetFishingRod(inst)
            if rod then
                inst.components.inventory:Equip(rod)
                _dbg("_PhaseFishing: 重新装备鱼竿 " .. tostring(rod.prefab))
            end
        else
            _dbg("_PhaseFishing: 无鱼竿可用 → deposit_fish")
            
            self._deposit_goto_issued = nil
            if self._deposit_search_handle then
                TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
                self._deposit_search_handle = nil
            end
            self._deposit_waypoints = nil
            self._deposit_wp_idx = nil
            self._deposit_phase_entered = nil
            ResetStuckCheck(self, "_deposit")
            self._phase = "deposit_fish"
            return
        end
    end

    if inst._fishing_catch_done then
        inst._fishing_catch_done = false
        inst._fishing_catch_count = (inst._fishing_catch_count or 0) + 1

        self:_SayLine("FISHING_CATCH", 5)
        _dbg(string.format("_PhaseFishing: 钓到一条! count=%d/%d",
            inst._fishing_catch_count, NPC_TUNING.FISHING_MAX_CATCH))

        self._phase = "pickup_fish"
        _dbg("_PhaseFishing: 上钩 → pickup_fish")
        return
    end

    if not inst.sg:HasStateTag("fishing") and not inst.sg:HasStateTag("prefish") then
        local pond = self._target_pond
        local pond_has_fish = pond and pond:IsValid()
            and pond.components.fishable
            and not pond.components.fishable:IsFrozenOver()
            and pond.components.fishable.fishleft
            and pond.components.fishable.fishleft > 0

        if pond_has_fish then
            _dbg("_PhaseFishing: 驱动进入 npc_fishing_pre")
            inst.sg:GoToState("npc_fishing_pre", { target = pond })
        else
            _dbg("_PhaseFishing: 池塘无效或无鱼 → find_pond")
            self._target_pond = nil
            
            self._approach_goto_issued = nil
            if self._path_search_handle then
                TheWorld.Pathfinder:KillSearch(self._path_search_handle)
                self._path_search_handle = nil
            end
            self._waypoints = nil
            self._waypoint_idx = nil
            ResetStuckCheck(self, "_approach")
            self._phase = "find_pond"
            self._last_scan_time = 0
        end
    end
end





local PICKUP_DIST = 2  

function NPCFishingBehavior:_PhasePickup()
    local inst = self.inst
    local fish = inst._fishing_caught_fish

    if not fish or not fish:IsValid() then
        _dbg("_PhasePickup: 鱼实体无效, 跳过 → murder_fish")
        inst._fishing_caught_fish = nil
        self._pickup_started = nil
        self._phase = "murder_fish"
        return
    end

    if not self._pickup_started then
        local dist_sq = inst:GetDistanceSqToInst(fish)
        if dist_sq > PICKUP_DIST * PICKUP_DIST then
            local fx, fy, fz = fish.Transform:GetWorldPosition()
            inst.components.locomotor:GoToPoint(Vector3(fx, fy, fz), nil, true)
            _dbg(string.format("_PhasePickup: 走向鱼, dist=%.1f", math.sqrt(dist_sq)))
            return
        end

        inst.components.locomotor:Stop()
        self._pickup_started = true
        local buffaction = BufferedAction(inst, fish, ACTIONS.PICKUP)
        inst:PushBufferedAction(buffaction)
        _dbg("_PhasePickup: 推送 PICKUP 动作, target=" .. tostring(fish.prefab))
        return
    end

    local sg_name = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name or ""
    if sg_name == "idle" or sg_name == "" then
        local fish_prefab = fish:IsValid() and fish.prefab or "pondfish"
        local inventory = inst.components.inventory
        if inventory then
            local items = inventory:FindItems(function(item)
                return item.prefab == fish_prefab
            end)
            if items and #items > 0 then
                inst._fishing_caught_fish_item = items[#items]  
                _dbg("_PhasePickup: 成功捡起鱼 " .. tostring(inst._fishing_caught_fish_item.prefab))
            else
                _dbg("_PhasePickup: 背包中未找到鱼，可能背包满")
            end
        end

        inst._fishing_caught_fish = nil
        self._pickup_started = nil
        self._phase = "murder_fish"
        _dbg("_PhasePickup: → murder_fish")
    end
end





function NPCFishingBehavior:_PhaseMurderFish()
    local inst = self.inst

    if self._murder_started then
        local sg_name = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name or ""
        if sg_name == "idle" or sg_name == "" then
            inst._fishing_caught_fish_item = nil
            self._murder_started = nil
            self._murder_delay_start = nil

            _dbg(string.format("_PhaseMurderFish: 循环判断 count=%d/%d, pond_valid=%s, fishleft=%s",
                inst._fishing_catch_count or 0,
                NPC_TUNING.FISHING_MAX_CATCH,
                tostring(self._target_pond and self._target_pond:IsValid()),
                tostring(self._target_pond and self._target_pond.components.fishable and self._target_pond.components.fishable.fishleft or "nil")))

            local hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if hand and hand.components.finiteuses then
                local uses_before = hand.components.finiteuses:GetUses()
                hand.components.finiteuses:Use(1)
                
                local rod_destroyed = not hand:IsValid()
                local uses_after = rod_destroyed and 0 or (hand.components.finiteuses:GetUses() or 0)
                _dbg("_PhaseMurderFish: 鱼竿耐久 -1, " .. uses_before .. "→" .. uses_after
                    .. (rod_destroyed and " [鱼竿已销毁!]" or ""))
            end

            local current_hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local hand_is_rod = current_hand and (current_hand.prefab == "fishingrod" or current_hand:HasTag("fishingrod"))

            if not hand_is_rod then
                _dbg("_PhaseMurderFish: 手持不是鱼竿 (current=" .. (current_hand and current_hand.prefab or "nil") .. "), 尝试重新装备")
                if HasFishingRod(inst) then
                    local rod = GetFishingRod(inst)
                    if rod then
                        inst.components.inventory:Equip(rod)
                        _dbg("_PhaseMurderFish: 重新装备备用鱼竿 " .. tostring(rod.prefab))
                    end
                else
                    _dbg("_PhaseMurderFish: 无备用鱼竿 → deposit_fish")
                    
                    self._deposit_goto_issued = nil
                    if self._deposit_search_handle then
                        TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
                        self._deposit_search_handle = nil
                    end
                    self._deposit_waypoints = nil
                    self._deposit_wp_idx = nil
                    self._deposit_phase_entered = nil
                    ResetStuckCheck(self, "_deposit")
                    self._phase = "deposit_fish"
                    return
                end
            end

            if (inst._fishing_catch_count or 0) < NPC_TUNING.FISHING_MAX_CATCH then
                if not HasFishingRod(inst) then
                    _dbg("_PhaseMurderFish: 鱼竿已耗尽 → deposit_fish")
                    
                    self._deposit_goto_issued = nil
                    if self._deposit_search_handle then
                        TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
                        self._deposit_search_handle = nil
                    end
                    self._deposit_waypoints = nil
                    self._deposit_wp_idx = nil
                    self._deposit_phase_entered = nil
                    ResetStuckCheck(self, "_deposit")
                    self._phase = "deposit_fish"
                    return
                end

                    if self._target_pond and self._target_pond:IsValid()
                   and self._target_pond.components.fishable
                   and not self._target_pond.components.fishable:IsFrozenOver()
                   and self._target_pond.components.fishable.fishleft > 0 then
                    inst._fishing_catch_done = false
                    inst._fishing_caught_fish = nil
                    inst._fishing_caught_fish_item = nil
                    _dbg(string.format("_PhaseMurderFish: 杀鱼完成, count=%d/%d, 池塘有鱼 → fishing 继续钓",
                        inst._fishing_catch_count or 0, NPC_TUNING.FISHING_MAX_CATCH))
                    self._phase = "fishing"
                else
                    _dbg(string.format("_PhaseMurderFish: 杀鱼完成, count=%d/%d, 当前池塘无鱼 → find_pond 搜索新池塘",
                        inst._fishing_catch_count or 0, NPC_TUNING.FISHING_MAX_CATCH))
                    inst._fishing_catch_done = false
                    inst._fishing_caught_fish = nil
                    inst._fishing_caught_fish_item = nil
                    self._target_pond = nil  
                    
                    self._approach_goto_issued = nil
                    if self._path_search_handle then
                        TheWorld.Pathfinder:KillSearch(self._path_search_handle)
                        self._path_search_handle = nil
                    end
                    self._waypoints = nil
                    self._waypoint_idx = nil
                    ResetStuckCheck(self, "_approach")
                    self._phase = "find_pond"  
                end
            else
                _dbg(string.format("_PhaseMurderFish: 杀鱼完成, 达到上限 %d/%d → deposit_fish",
                    inst._fishing_catch_count or 0, NPC_TUNING.FISHING_MAX_CATCH))
                
                self._deposit_goto_issued = nil
                if self._deposit_search_handle then
                    TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
                    self._deposit_search_handle = nil
                end
                self._deposit_waypoints = nil
                self._deposit_wp_idx = nil
                self._deposit_phase_entered = nil
                ResetStuckCheck(self, "_deposit")
                self._phase = "deposit_fish"
            end
        end
        return
    end

    local fish_item = inst._fishing_caught_fish_item
    if fish_item == nil or not fish_item:IsValid() then
        _dbg("_PhaseMurderFish: 无有效鱼物品, 跳过 → deposit_fish")
        
        self._deposit_goto_issued = nil
        if self._deposit_search_handle then
            TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
            self._deposit_search_handle = nil
        end
        self._deposit_waypoints = nil
        self._deposit_wp_idx = nil
        self._deposit_phase_entered = nil
        ResetStuckCheck(self, "_deposit")
        self._phase = "deposit_fish"
        return
    end

    if not self._murder_delay_start then
        self._murder_delay_start = GetTime()
        _dbg("_PhaseMurderFish: 等待 0.5 秒...")
        return
    end
    if GetTime() - self._murder_delay_start < 0.5 then
        return
    end

    self._murder_started = true
    self._murder_delay_start = nil
    local buffaction = BufferedAction(inst, nil, ACTIONS.MURDER, fish_item)
    inst:PushBufferedAction(buffaction)
    _dbg("_PhaseMurderFish: 推送 MURDER 动作, invobject=" .. tostring(fish_item.prefab))
end





function NPCFishingBehavior:_PhaseDepositFish()
    local inst = self.inst

    local deposit_pos = NPC_TUNING.FISHING_DEPOSIT_POS or inst._fishing_deposit_pos

    if not deposit_pos then
        _dbg("_PhaseDepositFish: 无存放点, 留在当前位置 → done")
        self._phase = "done"
        return
    end

    if not self._deposit_phase_entered then
        self._deposit_phase_entered = true
        _dbg("_PhaseDepositFish: 开始, deposit_pos=" .. tostring(deposit_pos))
    end

    local pos = inst:GetPosition()
    local dx = pos.x - deposit_pos.x
    local dz = pos.z - deposit_pos.z
    local dist = math.sqrt(dx * dx + dz * dz)
    local final_arrive_dist = math.max(DEPOSIT_ARRIVE_DIST, (NPC_TUNING.FISHING_DEPOSIT_RADIUS or 12) - 1)

    if dist > final_arrive_dist then
        if not self._deposit_route_candidates then
            local anchor_x, anchor_z = FindNearestReachableLandPoint(deposit_pos.x, deposit_pos.z, 24)
            self._deposit_route_candidates = BuildReachableLandCandidates(anchor_x, anchor_z, 21)
            self._deposit_route_try_idx = 1
        end
        local route_idx = self._deposit_route_try_idx or 1
        local route_target = self._deposit_route_candidates and self._deposit_route_candidates[route_idx]
        local deposit_route_x = route_target and route_target.x or deposit_pos.x
        local deposit_route_z = route_target and route_target.z or deposit_pos.z
        
        if self._deposit_search_handle then
            local d_status = TheWorld.Pathfinder:GetSearchStatus(self._deposit_search_handle)
            if d_status == 1 then  
                local result = TheWorld.Pathfinder:GetSearchResult(self._deposit_search_handle)
                self._deposit_search_handle = nil
                if result and result.steps and #result.steps >= 2 then
                    self._deposit_waypoints = {}
                    local last_x, last_z = nil, nil
                    for i = 2, #result.steps do
                        local step = result.steps[i]
                        if not last_x or ((step.x - last_x)^2 + (step.z - last_z)^2) >= DEPOSIT_WAYPOINT_STEP_SQ then
                            table.insert(self._deposit_waypoints, { x = step.x, z = step.z })
                            last_x, last_z = step.x, step.z
                        end
                    end
                    local final = result.steps[#result.steps]
                    if #self._deposit_waypoints == 0 or
                       ((self._deposit_waypoints[#self._deposit_waypoints].x - final.x)^2 + (self._deposit_waypoints[#self._deposit_waypoints].z - final.z)^2) > 1 then
                        table.insert(self._deposit_waypoints, { x = final.x, z = final.z })
                    end
                    self._deposit_wp_idx = 1
                    self._deposit_goto_issued = false
                    ResetStuckCheck(self, "_deposit")
                    _dbg(string.format("_PhaseDepositFish: 原生 A* 找到路径 (%d 个路径点)", #self._deposit_waypoints))
                else
                    _dbg("_PhaseDepositFish: 原生 A* 返回无效路径，丢鱼在地上")
                    self._phase = "deposit_drop"
                end
                return
            elseif d_status == 2 then  
                TheWorld.Pathfinder:KillSearch(self._deposit_search_handle)
                self._deposit_search_handle = nil
                if self._deposit_route_candidates and route_idx < #self._deposit_route_candidates then
                    self._deposit_route_try_idx = route_idx + 1
                    self._deposit_goto_issued = false
                    _dbg(string.format("_PhaseDepositFish: 目标点 %d 无路径，切换回程候选点 %d/%d",
                        route_idx, self._deposit_route_try_idx, #self._deposit_route_candidates))
                else
                    local fallback_path = PlanPathToTarget(inst, deposit_route_x, deposit_route_z)
                    if fallback_path and #fallback_path > 0 then
                        self._deposit_waypoints = fallback_path
                        self._deposit_wp_idx = 1
                        self._deposit_goto_issued = false
                        ResetStuckCheck(self, "_deposit")
                        _dbg(string.format("_PhaseDepositFish: 原生 A* 无路径，使用本地绕路方案 (%d 个路径点)", #fallback_path))
                    else
                        _dbg("_PhaseDepositFish: 原生 A* 未找到路径且本地绕路失败，丢鱼在地上")
                        self._phase = "deposit_drop"
                    end
                end
                return
            end
            
            return
        end

        
        if self._deposit_waypoints then
            local wp = self._deposit_waypoints[self._deposit_wp_idx]
            if not wp then
                self._deposit_waypoints = nil
                self._deposit_wp_idx = nil
                self._deposit_goto_issued = false
                return
            end

            local ax, _, az = inst.Transform:GetWorldPosition()
            local wp_dist = math.sqrt((ax - wp.x)^2 + (az - wp.z)^2)

            if wp_dist <= 3 then
                _dbg(string.format("_PhaseDepositFish: 到达路径点 %d/%d",
                    self._deposit_wp_idx, #self._deposit_waypoints))
                self._deposit_wp_idx = self._deposit_wp_idx + 1
                self._deposit_goto_issued = false
                ResetStuckCheck(self, "_deposit")
                return
            end

            local stuck = CheckStuckAndRetry(self, inst, "_deposit", { check_interval = 4, min_move_dist = 2 })
            if stuck == "retry" then
                _dbg("_PhaseDepositFish: waypoint 阶段卡住，丢鱼在地上")
                inst.components.locomotor:Stop()
                self._deposit_waypoints = nil
                self._deposit_wp_idx = nil
                ResetStuckCheck(self, "_deposit")
                self._phase = "deposit_drop"
                return
            end

            local loco_wp = inst.components.locomotor
            if not self._deposit_goto_issued or not loco_wp.dest then
                loco_wp:GoToPoint(Vector3(wp.x, 0, wp.z), nil, true)
                self._deposit_goto_issued = true
                _dbg(string.format("_PhaseDepositFish: GoToPoint → 路径点 %d/%d (%.1f,%.1f) dist=%.1f",
                    self._deposit_wp_idx, #self._deposit_waypoints, wp.x, wp.z, wp_dist))
            end
            return
        end

        
        if not self._deposit_goto_issued then
            self:_SayLine("FISHING_DEPOSIT_RETURN", 20)
            local search_pathcaps = {
                allowocean = false,
                ignoreLand = false,
                ignorecreep = true,
                ignorewalls = false,
            }
            local handle = TheWorld.Pathfinder:SubmitSearch(pos.x, 0, pos.z, deposit_route_x, 0, deposit_route_z, search_pathcaps)
            if handle then
                self._deposit_search_handle = handle
                self._deposit_goto_issued = true
                _dbg(string.format("_PhaseDepositFish: 预先提交原生 A* 搜索(%d/%d) 从(%.1f,%.1f)到(%.1f,%.1f)",
                    route_idx, self._deposit_route_candidates and #self._deposit_route_candidates or 1,
                    pos.x, pos.z, deposit_route_x, deposit_route_z))
                return
            else
                local fallback_path = PlanPathToTarget(inst, deposit_route_x, deposit_route_z)
                if fallback_path and #fallback_path > 0 then
                    self._deposit_waypoints = fallback_path
                    self._deposit_wp_idx = 1
                    self._deposit_goto_issued = false
                    ResetStuckCheck(self, "_deposit")
                    _dbg(string.format("_PhaseDepositFish: 预搜索提交失败，改用本地绕路方案 (%d 个路径点)", #fallback_path))
                    return
                end
            end
        end

        local stuck_result = CheckStuckAndRetry(self, inst, "_deposit", {
            check_interval = 6,
            min_move_dist = 2,
        })
        if stuck_result == "retry" then
            inst.components.locomotor:Stop()
            self._deposit_goto_issued = true  

            local ax, _, az = inst.Transform:GetWorldPosition()
            
            local search_pathcaps = {
                allowocean = false,
                ignoreLand = false,
                ignorecreep = true,
                ignorewalls = false,
            }
            local handle = TheWorld.Pathfinder:SubmitSearch(ax, 0, az, deposit_route_x, 0, deposit_route_z, search_pathcaps)
            if handle then
                self._deposit_search_handle = handle
                _dbg(string.format("_PhaseDepositFish: 卡住! 提交原生 A* 搜索 从(%.1f,%.1f)到(%.1f,%.1f)", ax, az, deposit_route_x, deposit_route_z))
            else
                local fallback_path = PlanPathToTarget(inst, deposit_route_x, deposit_route_z)
                if fallback_path and #fallback_path > 0 then
                    self._deposit_waypoints = fallback_path
                    self._deposit_wp_idx = 1
                    self._deposit_goto_issued = false
                    ResetStuckCheck(self, "_deposit")
                    _dbg(string.format("_PhaseDepositFish: SubmitSearch 失败，改用本地绕路方案 (%d 个路径点)", #fallback_path))
                else
                    _dbg("_PhaseDepositFish: SubmitSearch 失败且本地绕路失败，丢鱼在地上")
                    self._phase = "deposit_drop"
                end
            end
            return
        end

        if not self._deposit_goto_issued then
            local loco = inst.components.locomotor
            loco:GoToPoint(Vector3(deposit_pos.x, 0, deposit_pos.z), nil, true)
            self._deposit_goto_issued = true
            _dbg(string.format("_PhaseDepositFish: GoToPoint → 存放点 (%.1f,%.1f) dist=%.1f (A* 寻路)",
                deposit_pos.x, deposit_pos.z, dist))
        elseif self._bt_just_reset then
            PathRecovery.ResumeGoToAfterBTReset(self, inst, {
                goto_issued_key = "_deposit_goto_issued",
                target_x = deposit_pos.x,
                target_z = deposit_pos.z,
                dist = dist,
                dbg_fn = _dbg,
                log_prefix = "_PhaseDepositFish",
            })
        end
        return
    end

    inst.components.locomotor:Stop()
    self._deposit_route_candidates = nil
    self._deposit_route_try_idx = nil
    self._last_deposit_log = nil
    _dbg("_PhaseDepositFish: 到达存放点中心")

    local deposit_radius = NPC_TUNING.FISHING_DEPOSIT_RADIUS or 12
    local cx, cz = deposit_pos.x, deposit_pos.z

    local containers = {}
    local iceboxes = TheSim:FindEntities(cx, 0, cz, deposit_radius, { "fridge" })
    for _, ent in ipairs(iceboxes) do
        if ent and ent:IsValid() and ent.components and ent.components.container
           and not ent:HasTag("backpack")
           and not ent.components.container:IsFull() then
            table.insert(containers, ent)
        end
    end
    local chests = TheSim:FindEntities(cx, 0, cz, deposit_radius, { "chest" })
    for _, ent in ipairs(chests) do
        if ent and ent:IsValid() and ent.components and ent.components.container
           and not ent:HasTag("fridge")
           and not ent.components.container:IsFull() then
            table.insert(containers, ent)
        end
    end

    _dbg("_PhaseDepositFish: 找到容器数量=" .. #containers)

    if #containers > 0 then
        self._deposit_containers = containers
        self._deposit_container_idx = 1
        self._deposit_target_container = containers[1]
        self._phase = "deposit_approach"
        _dbg("_PhaseDepositFish: → deposit_approach, target=" .. tostring(containers[1]))
    else
        self._phase = "deposit_drop"
        _dbg("_PhaseDepositFish: 无可用容器 → deposit_drop")
    end
end





function NPCFishingBehavior:_PhaseDepositApproach()
    local inst = self.inst
    local container = self._deposit_target_container

    if not container or not container:IsValid()
       or not container.components or not container.components.container then
        _dbg("_PhaseDepositApproach: 容器无效, 尝试下一个")
        self:_AdvanceDepositContainer()
        return
    end

    local dist = math.sqrt(inst:GetDistanceSqToInst(container))

    if dist > 2 then
        local tx, ty, tz = container.Transform:GetWorldPosition()
        inst.components.locomotor:GoToPoint(Vector3(tx, ty, tz), nil, true)
        if not self._last_deposit_log or GetTime() - self._last_deposit_log > 2 then
            self._last_deposit_log = GetTime()
            _dbg(string.format("_PhaseDepositApproach: 走向容器 %s, dist=%.1f",
                tostring(container), dist))
        end
        return
    end

    inst.components.locomotor:Stop()
    self._last_deposit_log = nil
    inst._fishing_deposit_done = nil

    _dbg(string.format("_PhaseDepositApproach: 到达容器 %s, 触发 access_container", tostring(container)))

    inst.sg:GoToState("access_container", {
        container = container,
        action_fn = function(npc, cont)
            if not cont or not cont:IsValid() then
                _dbg("[deposit action_fn] 容器已无效")
                return
            end
            local cont_comp = cont.components and cont.components.container
            if not cont_comp then
                _dbg("[deposit action_fn] 容器组件已无效")
                return
            end
            local inv = npc.components.inventory
            if not inv then return end
            local stored = 0
            local fish_items = inv:FindItems(function(item)
                return item and item:IsValid() and item.prefab == "fishmeat_small"
            end) or {}
            for _, item in ipairs(fish_items) do
                if item and item:IsValid() and item.prefab == "fishmeat_small" then
                    if not cont_comp:IsFull() then
                        local taken = inv:RemoveItem(item, true)
                        if taken then
                            if cont_comp:GiveItem(taken) then
                                stored = stored + 1
                                _dbg("[deposit action_fn] 存入 " .. taken.prefab .. " → " .. cont.prefab)
                            else
                                inv:GiveItem(taken)
                                break  
                            end
                        end
                    else
                        break  
                    end
                end
            end
            _dbg("[deposit action_fn] 本次存入数量=" .. stored)
        end,
        on_done = function(npc)
            npc._fishing_deposit_done = true
            _dbg("[deposit on_done] access_container 完成")
        end,
    })

    self._phase = "deposit_storing"
end





function NPCFishingBehavior:_PhaseDepositStoring()
    local inst = self.inst

    if not inst._fishing_deposit_done then
        if inst.sg and not inst.sg:HasStateTag("busy") then
            _dbg("_PhaseDepositStoring: busy消失, 视为完成")
            inst._fishing_deposit_done = true
        else
            return  
        end
    end

    inst._fishing_deposit_done = nil
    _dbg("_PhaseDepositStoring: access_container 已完成")

    local inv = inst.components.inventory
    local has_fish = false
    if inv then
        InvUtil.ForEachCarriedItem(inst, function(item)
            if item and item:IsValid() and item.prefab == "fishmeat_small" then
                has_fish = true
                return true
            end
        end)
    end

    if not has_fish then
        _dbg("_PhaseDepositStoring: 背包无鱼块 → done")
        self._phase = "done"
        return
    end

    _dbg("_PhaseDepositStoring: 背包仍有鱼块, 尝试下一个容器")
    self:_AdvanceDepositContainer()
end





function NPCFishingBehavior:_PhaseDepositDrop()
    local inst = self.inst
    local inv = inst.components.inventory
    if not inv then
        self._phase = "done"
        return
    end

    if not self._deposit_drop_started then
        self._deposit_drop_started = true
        inst._fishing_deposit_done = nil

        inst.sg:GoToState("drop_fish_items")
        _dbg("_PhaseDepositDrop: 触发 drop_fish_items 动画")
        return
    end

    if inst._fishing_deposit_done then
        self._deposit_drop_started = nil
        inst._fishing_deposit_done = nil
        self._phase = "done"
        _dbg("_PhaseDepositDrop: 丢弃完成 → done")
    end
end





function NPCFishingBehavior:_AdvanceDepositContainer()
    local containers = self._deposit_containers
    local idx = (self._deposit_container_idx or 0) + 1

    while containers and idx <= #containers do
        local c = containers[idx]
        if c and c:IsValid() and c.components and c.components.container
           and not c.components.container:IsFull() then
            break
        end
        idx = idx + 1
    end

    if containers and idx <= #containers then
        self._deposit_container_idx = idx
        self._deposit_target_container = containers[idx]
        self._phase = "deposit_approach"
        _dbg("_AdvanceDepositContainer: 下一个容器 idx=" .. idx .. ", target=" .. tostring(containers[idx]))
    else
        self._phase = "deposit_drop"
        _dbg("_AdvanceDepositContainer: 无更多可用容器 → deposit_drop")
    end
end

function NPCFishingBehavior:_PhaseDone()
    local inst = self.inst
    _dbg("_PhaseDone: 钓鱼完成")

    self._prev_hand = nil

    
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.components.knownlocations then
        inst.components.knownlocations:RememberLocation("home", Vector3(x, y, z))
        _dbg(string.format("_PhaseDone: 更新 home point → (%.1f, %.1f)", x, z))
    end

    inst._fishing_active = false

    _dbg("_PhaseDone: 留在存放点, 行为完成")
    self:_Reset()
    self.status = SUCCESS
end

return NPCFishingBehavior
