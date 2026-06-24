-- scripts/behaviours/npc_oceanfishing_behavior.lua
-- NPC 海钓行为模块：温蒂专属，在海岸边使用海钓竿钓鱼
-- ────────────────────────────────────────────────────────────
-- 阶段流程：
--   idle → find_shore → approach_shore → equip_rod → cast → wait_hook
--   → reel_loop → catch_fish → murder_fish → deposit_fish → done
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





local SHORE_SEARCH_DIST = NPC_TUNING.OCEAN_FISHING_SHORE_SEARCH_DIST or 30
local CAST_DIST_MIN     = NPC_TUNING.OCEAN_FISHING_CAST_DIST_MIN     or 6
local CAST_DIST_MAX     = NPC_TUNING.OCEAN_FISHING_CAST_DIST_MAX     or 12
local REEL_TIMEOUT      = NPC_TUNING.OCEAN_FISHING_REEL_TIMEOUT      or 60
local CAST_TIMEOUT      = NPC_TUNING.OCEAN_FISHING_CAST_TIMEOUT      or 10
local CAST_STUCK_TIMEOUT = NPC_TUNING.OCEAN_FISHING_CAST_STUCK_TIMEOUT or 2.0
local APPROACH_EQUIP_DIST = NPC_TUNING.OCEAN_FISHING_APPROACH_EQUIP_DIST or 1.0
local APPROACH_EQUIP_BUFFER = NPC_TUNING.OCEAN_FISHING_APPROACH_EQUIP_BUFFER or 0.15
local APPROACH_WAYPOINT_STEP_SQ = NPC_TUNING.OCEAN_FISHING_APPROACH_WAYPOINT_STEP_SQ or 36
local DEPOSIT_WAYPOINT_STEP_SQ  = NPC_TUNING.OCEAN_FISHING_DEPOSIT_WAYPOINT_STEP_SQ or 25
local DEPOSIT_ARRIVE_DIST       = NPC_TUNING.OCEAN_FISHING_DEPOSIT_ARRIVE_DIST or 6
local FISH_DETECT_RADIUS = NPC_TUNING.OCEAN_FISHING_FISH_DETECT_RADIUS or 20
local W_FISH             = NPC_TUNING.OCEAN_FISHING_FISH_WEIGHT or 10
local W_DIST             = NPC_TUNING.OCEAN_FISHING_DIST_WEIGHT or 1
local HOOK_TIMEOUT       = NPC_TUNING.OCEAN_FISHING_HOOK_TIMEOUT or 60
local CAST_SAFE_OFFSET   = NPC_TUNING.OCEAN_FISHING_CAST_SAFE_OFFSET or 6
local CAST_NEAR_WATER_REQUIRED_DIST = NPC_TUNING.OCEAN_FISHING_NEAR_WATER_REQUIRED_DIST or math.max(4, CAST_DIST_MIN)
local CAST_TARGET_MAX_DIST = NPC_TUNING.OCEAN_FISHING_CAST_TARGET_MAX_DIST or (CAST_DIST_MAX + 2)
local AUTO_CHUM_WAIT = NPC_TUNING.OCEAN_FISHING_AUTO_CHUM_WAIT or 2.5
local FORCE_SPAWN_FISH = (NPC_TUNING.OCEAN_FISHING_FORCE_SPAWN_FISH ~= false)
local FORCE_SPAWN_RADIUS = NPC_TUNING.OCEAN_FISHING_FORCE_SPAWN_RADIUS or 10
local FORCE_SPAWN_TARGET = NPC_TUNING.OCEAN_FISHING_FORCE_SPAWN_TARGET or 5
local FORCE_SPAWN_MAX = 5 
local FORCE_SPAWN_COOLDOWN = NPC_TUNING.OCEAN_FISHING_FORCE_SPAWN_COOLDOWN or 8
local FORCE_SPAWN_NEAR_HOOK_RADIUS = NPC_TUNING.OCEAN_FISHING_FORCE_SPAWN_NEAR_HOOK_RADIUS or 8
local SAFE_CAST_DIST = NPC_TUNING.OCEAN_FISHING_SAFE_CAST_DIST or 6
local SAFE_CAST_PATCH_RADIUS = NPC_TUNING.OCEAN_FISHING_SAFE_CAST_PATCH_RADIUS or 2.2
local FORCE_BITE_DELAY = NPC_TUNING.OCEAN_FISHING_FORCE_BITE_DELAY or 3.0
local FORCE_BITE_STRICT_DELAY = (NPC_TUNING.OCEAN_FISHING_FORCE_BITE_STRICT_DELAY == true)
local FORCE_BITE_STRICT_REEL_TICK = NPC_TUNING.OCEAN_FISHING_FORCE_BITE_STRICT_REEL_TICK or 1.0
local FORCE_BITE_RADIUS = NPC_TUNING.OCEAN_FISHING_FORCE_BITE_RADIUS or 10
local REEL_FORCE_CATCH_TIMEOUT = NPC_TUNING.OCEAN_FISHING_REEL_FORCE_CATCH_TIMEOUT or 25
local FORCE_FISH_APPROACH_RADIUS = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_RADIUS or 10
local FORCE_FISH_APPROACH_TICK = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_TICK or 0.25
local FORCE_FISH_APPROACH_STOP_DIST = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_STOP_DIST or 2
local FORCE_FISH_APPROACH_FREE_SWIM_DIST = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_FREE_SWIM_DIST or 5
local FORCE_FISH_APPROACH_REENGAGE_DIST = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_REENGAGE_DIST or 7
local FORCE_FISH_APPROACH_PER_FISH_CD = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_PER_FISH_CD or 2.2
local FORCE_FISH_APPROACH_CHANCE = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_CHANCE or 0.35
local FORCE_FISH_APPROACH_MAX_PER_TICK = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_MAX_PER_TICK or 3
local FORCE_FISH_APPROACH_INTEREST_BOOST = NPC_TUNING.OCEAN_FISHING_FORCE_FISH_APPROACH_INTEREST_BOOST or 1
local FORCE_CATCH_CLOSE_DIST = NPC_TUNING.OCEAN_FISHING_FORCE_CATCH_CLOSE_DIST or 2.2
local HOOKED_PULL_STEP = NPC_TUNING.OCEAN_FISHING_HOOKED_PULL_STEP or 0.12
local HOOKED_PULL_TICK = NPC_TUNING.OCEAN_FISHING_HOOKED_PULL_TICK or 0.45
local HOOKED_CATCH_MIN_TIME = NPC_TUNING.OCEAN_FISHING_HOOKED_CATCH_MIN_TIME or 3.0
local HOOKED_CATCH_MIN_REELS = NPC_TUNING.OCEAN_FISHING_HOOKED_CATCH_MIN_REELS or 5



local ROD_MAX_ANGLE_OFFSET_RAD = 40 * (math.pi / 180)  
local ROD_DIST_MIN_ACCURACY    = 0.70
local ROD_DIST_MAX_ACCURACY    = 1.30


local EXCLUDE_TAGS = { "INLIMBO", "NOCLICK", "burnt" }
local FISH_QUERY_EXCLUDE_TAGS = { "INLIMBO", "burnt" }


local DEFAULT_SAY_COOLDOWN = 15


local function _dbg(...) if NPC_TUNING.DEBUG_OCEAN_FISHING then print("[NPC_OCEAN_FISHING]", ...) end end



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





local function FindOceanPointAlongAngle(map, ox, oz, angle, min_dist, max_dist, step)
    local cos_a = math.cos(angle)
    local sin_a = math.sin(angle)
    step = step or 1
    for d = min_dist, max_dist, step do
        local x = ox + cos_a * d
        local z = oz + sin_a * d
        if map:IsOceanAtPoint(x, 0, z) then
            return x, z, d
        end
    end
    return nil
end

local function FindNearestOceanPointAround(map, ox, oz, min_radius, max_radius, radius_step, angle_step_deg)
    radius_step = radius_step or 1
    angle_step_deg = angle_step_deg or 15
    local best_x, best_z, best_d2 = nil, nil, nil
    for r = min_radius, max_radius, radius_step do
        for deg = 0, 359, angle_step_deg do
            local rad = deg * DEGREES
            local x = ox + math.cos(rad) * r
            local z = oz + math.sin(rad) * r
            if map:IsOceanAtPoint(x, 0, z) then
                local dx = x - ox
                local dz = z - oz
                local d2 = dx * dx + dz * dz
                if best_d2 == nil or d2 < best_d2 then
                    best_x, best_z, best_d2 = x, z, d2
                end
            end
        end
        if best_x then
            return best_x, best_z
        end
    end
    return nil
end

local function IsOceanPatchSafe(map, x, z, radius)
    if not map:IsOceanAtPoint(x, 0, z) then
        return false
    end
    local r = radius or SAFE_CAST_PATCH_RADIUS
    for deg = 0, 315, 45 do
        local rad = deg * DEGREES
        local sx = x + math.cos(rad) * r
        local sz = z + math.sin(rad) * r
        if not map:IsOceanAtPoint(sx, 0, sz) then
            return false
        end
    end
    return true
end

local function FindSafeCastPoint(map, spot, ax, az)
    local cos_a = math.cos(spot.angle)
    local sin_a = math.sin(spot.angle)

    
    for dist = SAFE_CAST_DIST, SAFE_CAST_DIST + 8, 0.5 do
        local x = spot.x + cos_a * dist
        local z = spot.z + sin_a * dist
        if IsOceanPatchSafe(map, x, z, SAFE_CAST_PATCH_RADIUS) then
            return x, z
        end
    end

    
    local x, z = FindOceanPointAlongAngle(map, spot.x, spot.z, spot.angle, 1, CAST_TARGET_MAX_DIST + 8, 0.5)
    if x and IsOceanPatchSafe(map, x, z, 1.2) then
        return x, z
    end

    
    x, z = FindNearestOceanPointAround(map, spot.x, spot.z, 1, CAST_TARGET_MAX_DIST + 10, 0.5, 15)
    if x and IsOceanPatchSafe(map, x, z, 1.0) then
        return x, z
    end
    x, z = FindNearestOceanPointAround(map, ax, az, 1, CAST_TARGET_MAX_DIST + 10, 0.5, 15)
    if x then
        return x, z
    end
    return nil
end

local function CalcCastOceanSafetyScore(map, fx, fz, tx, tz)
    
    local vx = tx - fx
    local vz = tz - fz
    local base_len = math.sqrt(vx * vx + vz * vz)
    if base_len <= 0.1 then
        return 0
    end

    local base_theta = math.atan2(vz, vx)
    local total = 0
    local ocean = 0
    local angle_steps = { -1, -0.6, -0.3, 0, 0.3, 0.6, 1 }
    local dist_steps = { ROD_DIST_MIN_ACCURACY, 0.85, 1.0, 1.15, ROD_DIST_MAX_ACCURACY }

    for _, a in ipairs(angle_steps) do
        local theta = base_theta + a * ROD_MAX_ANGLE_OFFSET_RAD
        local cos_t = math.cos(theta)
        local sin_t = math.sin(theta)
        for _, m in ipairs(dist_steps) do
            total = total + 1
            local d = math.max(2, base_len * m)
            local sx = fx + cos_t * d
            local sz = fz + sin_t * d
            if map:IsOceanAtPoint(sx, 0, sz) then
                ocean = ocean + 1
            end
        end
    end
    return total > 0 and (ocean / total) or 0
end

local function FindBestCastPointBySafety(map, fx, fz, seed_x, seed_z)
    local best_x, best_z = seed_x, seed_z
    local best_score = CalcCastOceanSafetyScore(map, fx, fz, seed_x, seed_z)
    local search_radii = { 0, 1.5, 3, 4.5, 6, 8 }

    for _, r in ipairs(search_radii) do
        local step_deg = (r <= 1.5) and 45 or 30
        for deg = 0, 359, step_deg do
            local rad = deg * DEGREES
            local cx = seed_x + math.cos(rad) * r
            local cz = seed_z + math.sin(rad) * r
            if map:IsOceanAtPoint(cx, 0, cz) then
                local score = CalcCastOceanSafetyScore(map, fx, fz, cx, cz)
                if score > best_score then
                    best_score = score
                    best_x, best_z = cx, cz
                end
            end
        end
    end

    return best_x, best_z, best_score
end





local function TrySpawnAutoChum(self, inst, spot)
    if not NPC_TUNING.OCEAN_FISHING_AUTO_CHUM then
        return false
    end
    local now = GetTime()
    local cd = NPC_TUNING.OCEAN_FISHING_AUTO_CHUM_CD or 25
    if self._last_auto_chum_time and (now - self._last_auto_chum_time) < cd then
        return false
    end
    local map = TheWorld and TheWorld.Map
    if not map or not spot then
        return false
    end
    local ax, _, az = inst.Transform:GetWorldPosition()
    local x, z = FindOceanPointAlongAngle(
        map, ax, az, spot.angle,
        NPC_TUNING.OCEAN_FISHING_AUTO_CHUM_DIST_MIN or 4,
        NPC_TUNING.OCEAN_FISHING_AUTO_CHUM_DIST_MAX or 8,
        1
    )
    if not x then
        x, z = FindOceanPointAlongAngle(
            map, spot.x, spot.z, spot.angle, 2, 8, 1
        )
    end
    if x then
        local chum = SpawnPrefab("chum_aoe")
        if chum then
            chum.Transform:SetPosition(x, 0, z)
            self._last_auto_chum_time = now
            _dbg(string.format("_PhaseCast: 自动鱼食 chum_aoe at (%.1f, %.1f)", x, z))
            return true
        end
    end
    return false
end

local FORCE_SPAWN_PREFABS = {
    "oceanfish_small_1",
    "oceanfish_small_2",
    "oceanfish_small_3",
    "oceanfish_small_4",
    "oceanfish_small_5",
    "oceanfish_small_6",
    "oceanfish_small_7",
    "oceanfish_small_8",
    "oceanfish_small_9",
    
    "oceanfish_medium_1",
    "oceanfish_medium_2",
    "oceanfish_medium_3",
    "oceanfish_medium_4",
    "oceanfish_medium_5",
    "oceanfish_medium_6",
    "oceanfish_medium_7",
    "oceanfish_medium_8",
    "oceanfish_medium_9",
}

local function ForceSpawnOceanFishAround(self, cx, cz, opts)
    if not FORCE_SPAWN_FISH then
        return
    end
    opts = opts or {}
    local radius = opts.radius or FORCE_SPAWN_RADIUS
    local ignore_cd = opts.ignore_cooldown == true
    local now = GetTime()
    if (not ignore_cd) and self._last_force_spawn_time and (now - self._last_force_spawn_time) < FORCE_SPAWN_COOLDOWN then
        return
    end
    local map = TheWorld and TheWorld.Map
    if not map then
        return
    end

    local existing = TheSim:FindEntities(cx, 0, cz, radius, {"oceanfish"}, FISH_QUERY_EXCLUDE_TAGS)
    local target_cap = math.min(FORCE_SPAWN_MAX, math.max(1, FORCE_SPAWN_TARGET))
    local need = math.max(0, target_cap - #existing)
    if need <= 0 then
        _dbg(string.format("_PhaseCast: 强刷跳过，范围内已有 %d/%d 条 (center=%.1f,%.1f,r=%.1f)", #existing, target_cap, cx, cz, radius))
        return
    end

    local spawned = 0
    local attempts = 0
    local max_attempts = need * 10
    while spawned < need and attempts < max_attempts do
        attempts = attempts + 1
        local theta = math.random() * 2 * math.pi
        local r = 1 + math.random() * (radius - 1)
        local sx = cx + math.cos(theta) * r
        local sz = cz + math.sin(theta) * r
        if map:IsOceanAtPoint(sx, 0, sz) then
            local prefab = FORCE_SPAWN_PREFABS[math.random(#FORCE_SPAWN_PREFABS)]
            local fish = SpawnPrefab(prefab)
            if fish then
                fish.Transform:SetPosition(sx, 0, sz)
                spawned = spawned + 1
            end
        end
    end

    if spawned > 0 then
        self._last_force_spawn_time = now
        _dbg(string.format("_PhaseCast: 强制刷新海鱼 %d 条 (existing=%d,target=%d,center=%.1f,%.1f,r=%.1f)", spawned, #existing, target_cap, cx, cz, radius))
    end
end

local function TryForceHookFish(self, inst, hook_target, rod)
    if self._force_hook_done then
        return false
    end
    if hook_target == nil or not hook_target:IsValid() then
        return false
    end
    if rod == nil or not rod:IsValid() or rod.components.oceanfishingrod == nil then
        return false
    end

    local hx, _, hz = hook_target.Transform:GetWorldPosition()
    local fishes = TheSim:FindEntities(hx, 0, hz, FORCE_BITE_RADIUS, {"oceanfish"}, FISH_QUERY_EXCLUDE_TAGS)
    local best, best_d2 = nil, nil
    for _, fish in ipairs(fishes) do
        if fish:IsValid()
            and fish.components.oceanfishable ~= nil
            and fish.components.oceanfishable:GetRod() == nil then
            local fx, _, fz = fish.Transform:GetWorldPosition()
            local dx, dz = fx - hx, fz - hz
            local d2 = dx * dx + dz * dz
            if best_d2 == nil or d2 < best_d2 then
                best = fish
                best_d2 = d2
            end
        end
    end

    if best ~= nil then
        
        best.components.oceanfishable:SetRod(rod)
        self._force_hook_done = true
        _dbg(string.format("_PhaseReelLoop: 强制上钩 %s (dist=%.1f)", tostring(best.prefab), math.sqrt(best_d2 or 0)))
        return true
    end
    return false
end

local function NudgeNearbyFishTowardHook(self, hook_target)
    if hook_target == nil or not hook_target:IsValid() then
        return
    end
    local now = GetTime()
    if self._last_force_approach_time and (now - self._last_force_approach_time) < FORCE_FISH_APPROACH_TICK then
        return
    end
    self._last_force_approach_time = now

    local hx, _, hz = hook_target.Transform:GetWorldPosition()
    local fishes = TheSim:FindEntities(hx, 0, hz, FORCE_FISH_APPROACH_RADIUS, {"oceanfish"}, FISH_QUERY_EXCLUDE_TAGS)
    local nudged = 0
    self._fish_approach_cd = self._fish_approach_cd or {}
    local stop_d2 = FORCE_FISH_APPROACH_STOP_DIST * FORCE_FISH_APPROACH_STOP_DIST
    local free_swim_d2 = FORCE_FISH_APPROACH_FREE_SWIM_DIST * FORCE_FISH_APPROACH_FREE_SWIM_DIST
    local reengage_d2 = FORCE_FISH_APPROACH_REENGAGE_DIST * FORCE_FISH_APPROACH_REENGAGE_DIST
    local hook_comp = hook_target.components.oceanfishinghook
    if hook_comp ~= nil then
        
        hook_comp.lure_data = hook_comp.lure_data or {}
        hook_comp.lure_data.radius = math.max(hook_comp.lure_data.radius or 1, FORCE_FISH_APPROACH_STOP_DIST)
    end
    for _, fish in ipairs(fishes) do
        if fish:IsValid()
            and fish.components.oceanfishable ~= nil
            and fish.components.oceanfishable:GetRod() == nil
            and fish.components.locomotor ~= nil then
            local fx, _, fz = fish.Transform:GetWorldPosition()
            local dx = fx - hx
            local dz = fz - hz
            local d2 = dx * dx + dz * dz

            
            if d2 <= free_swim_d2 then
                if fish.food_target == hook_target then
                    fish.food_target = nil
                    
                    if fish.components.locomotor ~= nil then
                        fish.components.locomotor:SetShouldRun(false)
                    end
                end
            else
                
                local can_nudge = true
                if d2 < reengage_d2 then
                    if fish.food_target == hook_target then
                        fish.food_target = nil
                        if fish.components.locomotor ~= nil then
                            fish.components.locomotor:SetShouldRun(false)
                        end
                    end
                    can_nudge = false
                end
                if can_nudge then
                    local last = self._fish_approach_cd[fish.GUID]
                    if last ~= nil and (now - last) < FORCE_FISH_APPROACH_PER_FISH_CD then
                        can_nudge = false
                    end
                    if can_nudge and math.random() > FORCE_FISH_APPROACH_CHANCE then
                        can_nudge = false
                    end
                end

                if can_nudge then
                    self._fish_approach_cd[fish.GUID] = now
                    
                    fish.food_target = hook_target
                    fish.num_nibbles = fish.num_nibbles or 1
                    if hook_comp ~= nil then
                        
                        for _ = 1, FORCE_FISH_APPROACH_INTEREST_BOOST do
                            hook_comp:UpdateInterestForFishable(fish)
                        end
                    end
                    
                    local ring_r = FORCE_FISH_APPROACH_FREE_SWIM_DIST + (math.random() * 1.2)
                    local ring_a = math.random() * 2 * math.pi
                    local tx = hx + math.cos(ring_a) * ring_r
                    local tz = hz + math.sin(ring_a) * ring_r
                    fish.components.locomotor:GoToPoint(Vector3(tx, 0, tz), nil, false)
                    nudged = nudged + 1
                    if nudged >= FORCE_FISH_APPROACH_MAX_PER_TICK then
                        break
                    end
                end
            end
        end
    end
end

local function IsFishCloseEnoughForCatch(inst, fish)
    if inst == nil or fish == nil or not fish:IsValid() then
        return false
    end
    local fx, _, fz = fish.Transform:GetWorldPosition()
    local ix, _, iz = inst.Transform:GetWorldPosition()
    local dx = fx - ix
    local dz = fz - iz
    local d2 = dx * dx + dz * dz
    return d2 <= (FORCE_CATCH_CLOSE_DIST * FORCE_CATCH_CLOSE_DIST)
end

local function TightenCatchDistanceForNPC(fish)
    if fish == nil or not fish:IsValid() or fish.components.oceanfishable == nil then
        return
    end
    local fishable = fish.components.oceanfishable
    fishable.catch_distance = math.min(fishable.catch_distance or 4, FORCE_CATCH_CLOSE_DIST)
end

local function IsInventoryFullForCatch(inst)
    -- 口袋和已装备背包都没空位时，才认为不能继续接鱼。
    return not InvUtil.HasInventorySpace(inst)
end

local function IsDepositableOceanCatchItem(item)
    return item and item:IsValid()
        and (item:HasTag("oceanfish")
            or item:HasTag("edible_MEAT")
            or item.prefab == "ice"
            or item:HasTag("edible_VEGGIE")
            or item.prefab == "corn_cooked")
end

local function PullHookedFishTowardPlayer(self, inst, fish)
    if inst == nil or fish == nil or not fish:IsValid() then
        return
    end
    local now = GetTime()
    if self._last_hooked_pull_time and (now - self._last_hooked_pull_time) < HOOKED_PULL_TICK then
        return
    end
    self._last_hooked_pull_time = now
    local fishable = fish.components.oceanfishable
    if fishable == nil or fishable:GetRod() == nil then
        return
    end
    local map = TheWorld and TheWorld.Map
    local fx, _, fz = fish.Transform:GetWorldPosition()
    local ix, _, iz = inst.Transform:GetWorldPosition()
    local dx = ix - fx
    local dz = iz - fz
    local dist = math.sqrt(dx * dx + dz * dz)
    if dist <= FORCE_CATCH_CLOSE_DIST then
        return
    end

    if dist > 0.01 then
        local nx = dx / dist
        local nz = dz / dist
        local step = math.max(0.05, HOOKED_PULL_STEP)
        local tx = fx + nx * step
        local tz = fz + nz * step
        if map == nil or map:IsOceanAtPoint(tx, 0, tz) then
            fish.Transform:SetPosition(tx, 0, tz)
        end
    end

    if fish.components.locomotor ~= nil then
        fish.components.locomotor:GoToPoint(Vector3(ix, 0, iz), nil, true)
    end
end

local function IsHookedCatchMature(self)
    if self._hooked_fish_start_time == nil then
        return false
    end
    local hooked_time_ok = (GetTime() - self._hooked_fish_start_time) >= HOOKED_CATCH_MIN_TIME
    local reel_count_ok = (self._hooked_reel_count or 0) >= HOOKED_CATCH_MIN_REELS
    return hooked_time_ok and reel_count_ok
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






local function HasOceanFishingRod(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and hand.prefab == "oceanfishingrod" then
        return true
    end
    return inv:FindItem(function(item)
        return item.prefab == "oceanfishingrod"
    end) ~= nil
end


local function GetOceanFishingRod(inst)
    local inv = inst.components.inventory
    if not inv then return nil end
    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and hand.prefab == "oceanfishingrod" then
        return hand
    end
    return inv:FindItem(function(item)
        return item.prefab == "oceanfishingrod"
    end)
end


local function EquipOceanFishingRod(inst)
    local inv = inst.components.inventory
    if not inv then return nil end
    local prev_hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if prev_hand and prev_hand.prefab == "oceanfishingrod" then
        return nil  
    end
    local rod = inv:FindItem(function(item)
        return item.prefab == "oceanfishingrod"
    end)
    if rod then
        inv:Equip(rod)
        _dbg("装备海钓竿，保存之前手持:", prev_hand and prev_hand.prefab or "nil")
        return prev_hand
    end
    return prev_hand
end


local function SafeRestoreWeapon(inst, prev_hand)
    local inv = inst.components.inventory
    if not inv then return end
    if prev_hand and prev_hand:IsValid() then
        local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if not hand or hand.prefab == "oceanfishingrod" then
            inv:Equip(prev_hand)
            _dbg("恢复武器:", prev_hand.prefab)
        end
    else
        local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if hand and hand.prefab == "oceanfishingrod" then
            inv:Unequip(EQUIPSLOTS.HANDS)
            inv:GiveItem(hand)
            _dbg("海钓竿收回背包")
        end
    end
end





local NPCOceanFishingBehavior = Class(BehaviourNode, function(self, inst, config)
    BehaviourNode._ctor(self, "NPCOceanFishingBehavior")
    self.inst   = inst
    self.config = config or {}

    
    self._phase          = "idle"
    self._shore_spot     = nil       
    self._last_scan_time = 0
    self._prev_hand      = nil

    
    self._blocked_shores = {}

    
    self._on_fishcaught     = nil
    self._on_stoppedfishing = nil
    self._on_newfishingtarget = nil
end)

function NPCOceanFishingBehavior:DBString()
    return string.format("NPCOceanFishingBehavior(phase=%s, catch=%d/%d)",
        tostring(self._phase),
        self.inst._oceanfishing_catch_count or 0,
        NPC_TUNING.OCEAN_FISHING_MAX_CATCH)
end





function NPCOceanFishingBehavior:_SayLine(speech_key, cooldown)
    local inst = self.inst
    if not inst or not inst:IsValid() or not inst.components.talker then return end

    inst._oceanfishing_say_cd = inst._oceanfishing_say_cd or {}
    local now = GetTime()
    local cd = cooldown or DEFAULT_SAY_COOLDOWN

    if inst._oceanfishing_say_cd[speech_key] and (now - inst._oceanfishing_say_cd[speech_key]) < cd then
        return
    end
    inst._oceanfishing_say_cd[speech_key] = now

    local ok, NPC_SPEECH = pcall(function() return require("npc_speech") end)
    if not ok or not NPC_SPEECH then return end

    local pool = NPC_SPEECH[speech_key]
    if not pool then return end

    local line = NPC_SPEECH.GetLine(pool, inst.npc_character_type)
    if line then
        inst.components.talker:Say(line)
    end
end





function NPCOceanFishingBehavior:_ListenForEvents()
    local inst = self.inst
    if self._on_fishcaught then return end  

    self._on_fishcaught = function(i, data)
        _dbg("事件: fishcaught")
        self._fish_caught = true
    end
    inst:ListenForEvent("fishcaught", self._on_fishcaught)

    self._on_stoppedfishing = function(i, data)
        local reason = data and data.reason or "unknown"
        _dbg("事件: oceanfishing_stoppedfishing, reason=" .. tostring(reason))
        self._fishing_stopped = true
        self._fishing_stopped_reason = reason
    end
    inst:ListenForEvent("oceanfishing_stoppedfishing", self._on_stoppedfishing)

    self._on_newfishingtarget = function(i, data)
        local target = data and data.target or nil
        
        if target ~= nil and target:IsValid() and not target:HasTag("projectile") then
            _dbg("事件: newfishingtarget")
            self._hook_landed = true
        else
            _dbg("事件: newfishingtarget (projectile, 忽略)")
        end
    end
    inst:ListenForEvent("newfishingtarget", self._on_newfishingtarget)
end

function NPCOceanFishingBehavior:_StopListeningForEvents()
    local inst = self.inst
    if self._on_fishcaught then
        inst:RemoveEventCallback("fishcaught", self._on_fishcaught)
        self._on_fishcaught = nil
    end
    if self._on_stoppedfishing then
        inst:RemoveEventCallback("oceanfishing_stoppedfishing", self._on_stoppedfishing)
        self._on_stoppedfishing = nil
    end
    if self._on_newfishingtarget then
        inst:RemoveEventCallback("newfishingtarget", self._on_newfishingtarget)
        self._on_newfishingtarget = nil
    end
end





function NPCOceanFishingBehavior:_Reset()
    _dbg(string.format("_Reset: phase=%s, catch_count=%d",
        tostring(self._phase), self.inst and self.inst._oceanfishing_catch_count or 0))
    self:_StopListeningForEvents()
    self._phase          = "idle"
    self._shore_spot     = nil
    self._last_scan_time = 0

    self._hook_landed    = nil
    self._fish_caught    = nil
    self._fishing_stopped = nil
    self._fishing_stopped_reason = nil
    self._cast_time      = nil
    self._cast_wait_sg_start = nil
    self._hook_wait_start_time = nil
    self._reel_start_time = nil
    self._last_reel_time  = nil
    self._last_close_wait_log_time = nil
    self._last_mature_wait_log_time = nil
    self._last_force_bite_wait_log_time = nil
    self._last_strict_reel_time = nil
    self._early_bite_logged = nil
    self._last_hooked_pull_time = nil
    self._hooked_fish_guid = nil
    self._hooked_fish_start_time = nil
    self._hooked_reel_count = nil
    self._pickup_wait_until = nil
    self._pickup_target = nil
    self._pickup_started_time = nil
    self._pickup_goto_issued = nil
    self._pickup_action_time = nil
    self._fish_approach_cd = nil
    self._murder_started  = nil
    self._murder_delay_start = nil
    self._bt_just_reset = nil
    self._badcast_retry = nil
    ResetStuckCheck(self, "_approach")
    self._approach_goto_issued = nil
    self._last_visit_log  = nil
    self._last_deposit_log = nil
    self._deposit_phase_entered = nil
    self._deposit_drop_started = nil
    self._deposit_goto_issued = nil
    self._waypoints = nil
    self._waypoint_idx = nil
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
        self.inst._oceanfishing_catch_done = nil
        self.inst._oceanfishing_deposit_done = nil
    end
end





function NPCOceanFishingBehavior:Visit()
    local inst = self.inst

    if not inst:IsValid() or inst._is_ghost_mode then
        _dbg("Visit: NPC 无效或幽灵模式, FAILED")
        self.status = FAILED
        return
    end

    if not inst._oceanfishing_active then
        if self._phase ~= "idle" then
            _dbg("Visit: 海钓被取消, phase=" .. tostring(self._phase))
            local rod = GetOceanFishingRod(inst)
            if rod and rod.components.oceanfishingrod then
                rod.components.oceanfishingrod:StopFishing("cancelled")
            end
            if inst.sg and inst.sg:HasStateTag("fishing") then
                inst.sg:GoToState("npc_oceanfishing_stop")
            end
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
            if not inst._oceanfishing_active then
                inst._oceanfishing_catch_count = 0
            end
            self:_ListenForEvents()
            _dbg("Visit: READY → RUNNING (全新开始), catch_count=" .. tostring(inst._oceanfishing_catch_count))
        else
            self:_ListenForEvents()
            
            self._bt_just_reset = true
            _dbg("Visit: READY → RUNNING (恢复), phase=" .. tostring(self._phase)
                .. ", catch_count=" .. tostring(inst._oceanfishing_catch_count))
        end
    end

    if self.status == RUNNING then
        local sg_name = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name or "?"
        local log_key = self._phase .. "|" .. sg_name
        if log_key ~= self._last_visit_log then
            self._last_visit_log = log_key
            _dbg(string.format("Visit: RUNNING phase=%s, sg=%s", tostring(self._phase), sg_name))
        end
        self:_RunPhase()
    end
end

function NPCOceanFishingBehavior:_RunPhase()
    if self._phase == "idle" then
        self:_PhaseIdle()
    elseif self._phase == "find_shore" then
        self:_PhaseFindShore()
    elseif self._phase == "approach_shore" then
        self:_PhaseApproachShore()
    elseif self._phase == "equip_rod" then
        self:_PhaseEquipRod()
    elseif self._phase == "cast" then
        self:_PhaseCast()
    elseif self._phase == "wait_hook" then
        self:_PhaseWaitHook()
    elseif self._phase == "reel_loop" then
        self:_PhaseReelLoop()
    elseif self._phase == "catch_fish" then
        self:_PhaseCatchFish()
    elseif self._phase == "pickup_catch_fish" then
        self:_PhasePickupCatchFish()
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





function NPCOceanFishingBehavior:_PhaseIdle()
    local inst = self.inst
    _dbg("_PhaseIdle: oceanfishing_active=" .. tostring(inst._oceanfishing_active)
        .. ", catch_count=" .. tostring(inst._oceanfishing_catch_count))
    self._phase = "find_shore"
    self._last_scan_time = 0
    _dbg("_PhaseIdle: → find_shore")
end






local SHORE_SEARCH_DISTS = {30, 50, 80, 120}


local function _ScanForCandidates(inst, map, search_dist, blocked_shores)
    local ax, _, az = inst.Transform:GetWorldPosition()
    local candidates = {}
    local num_dirs = 36
    local step_size = 1.5

    
    local land_passable_ok = 0
    local has_ocean_ok = 0
    local blocked_skip = 0

    for dir_idx = 0, num_dirs - 1 do
        local angle = (dir_idx / num_dirs) * 2 * math.pi
        local cos_a = math.cos(angle)
        local sin_a = math.sin(angle)

        local max_steps = math.floor(search_dist / step_size)
        for step = 1, max_steps do
            local dist = step * step_size
            local tx = ax + cos_a * dist
            local tz = az + sin_a * dist

            
            if not map:IsOceanAtPoint(tx, 0, tz) and map:IsPassableAtPoint(tx, 0, tz) then
                land_passable_ok = land_passable_ok + 1
                
                local has_ocean = false
                local ocean_x, ocean_z = nil, nil
                local ocean_probe = nil
                for probe = 1, 15 do
                    local ox = tx + cos_a * probe
                    local oz = tz + sin_a * probe
                    if map:IsOceanAtPoint(ox, 0, oz) then
                        has_ocean = true
                        ocean_x, ocean_z = ox, oz
                        ocean_probe = probe
                        break
                    end
                end

                if has_ocean then
                    has_ocean_ok = has_ocean_ok + 1
                    local key = math.floor(tx / 4) .. "_" .. math.floor(tz / 4)
                    if blocked_shores and blocked_shores[key] then
                        blocked_skip = blocked_skip + 1
                        _dbg("FindShore: 跳过已标记失败岸边 " .. key)
                    else
                        
                        
                        local shore_x, shore_z = tx, tz
                        if ocean_probe then
                            for back = ocean_probe - 0.5, 0, -0.5 do
                                local lx = tx + cos_a * back
                                local lz = tz + sin_a * back
                                if map:IsPassableAtPoint(lx, 0, lz) and not map:IsOceanAtPoint(lx, 0, lz) then
                                    shore_x, shore_z = lx, lz
                                    break
                                end
                            end
                        end

                        
                        local cast_x, cast_z = nil, nil
                        for sea_probe = 0.5, 4, 0.5 do
                            local sx = shore_x + cos_a * sea_probe
                            local sz = shore_z + sin_a * sea_probe
                            if map:IsOceanAtPoint(sx, 0, sz) then
                                cast_x, cast_z = sx, sz
                                break
                            end
                        end
                        if not cast_x then
                            cast_x, cast_z = ocean_x, ocean_z
                        end

                        local ddx = shore_x - ax
                        local ddz = shore_z - az
                        local d_sq = ddx * ddx + ddz * ddz
                        table.insert(candidates, {
                            x = shore_x, z = shore_z, angle = angle,
                            dist_sq = d_sq, key = key,
                            cast_x = cast_x, cast_z = cast_z,
                        })
                    end
                    break  
                end
            end
        end
    end

    _dbg(string.format("FindShore: 诊断 land_ok=%d, ocean_ok=%d, blocked_skip=%d, candidates=%d",
        land_passable_ok, has_ocean_ok, blocked_skip, #candidates))

    return candidates
end

function NPCOceanFishingBehavior:_PhaseFindShore()
    local inst = self.inst
    local now = GetTime()

    if now - self._last_scan_time < 2 then
        return
    end
    self._last_scan_time = now

    if not HasOceanFishingRod(inst) then
        self:_SayLine("OCEAN_FISHING_NO_ROD", 30)
        _dbg("_PhaseFindShore: 无海钓竿, FAILED")
        inst._oceanfishing_active = false
        self:_Reset()
        self.status = FAILED
        return
    end

    local deposit_pos = NPC_TUNING.OCEAN_FISHING_DEPOSIT_POS or inst._oceanfishing_deposit_pos
    if not deposit_pos then
        _dbg("_PhaseFindShore: 未设置存放点, 提示玩家")
        self:_SayLine("OCEAN_FISHING_NO_DEPOSIT", 10)
        inst._oceanfishing_active = false
        self:_Reset()
        self.status = FAILED
        return
    end

    local ax, ay, az = inst.Transform:GetWorldPosition()
    local map = TheWorld and TheWorld.Map
    if not map then
        _dbg("_PhaseFindShore: 无法获取地图, FAILED")
        inst._oceanfishing_active = false
        self:_Reset()
        self.status = FAILED
        return
    end

    
    local candidates = {}
    for _, search_dist in ipairs(SHORE_SEARCH_DISTS) do
        _dbg(string.format("_PhaseFindShore: 搜索中, NPC pos=(%.1f,%.1f), search_dist=%d", ax, az, search_dist))
        candidates = _ScanForCandidates(inst, map, search_dist, self._blocked_shores)
        if #candidates > 0 then
            break
        end
    end

    
    if #candidates == 0 and self._blocked_shores and next(self._blocked_shores) then
        _dbg("FindShore: 0候选且有黑名单，清空黑名单重试")
        self._blocked_shores = {}
        candidates = _ScanForCandidates(inst, map, SHORE_SEARCH_DISTS[#SHORE_SEARCH_DISTS], nil)
    end

    _dbg(string.format("_PhaseFindShore: 扫描完成, 候选岸边点数量=%d", #candidates))

    
    if #candidates > 0 then
        if NPC_TUNING.OCEAN_FISHING_SIMPLE_SHORE_ONLY then
            
            table.sort(candidates, function(a, b) return a.dist_sq < b.dist_sq end)
            local best = candidates[1]
            self._shore_spot = { x = best.x, z = best.z, angle = best.angle, cast_x = best.cast_x, cast_z = best.cast_z }
            self._hook_wait_start_time = nil
            self._phase = "approach_shore"
            _dbg(string.format("FindOceanFishingSpot: 岸边优先 x=%.1f z=%.1f angle=%.2f",
                best.x, best.z, best.angle))
        else
            
            local has_any_fish = false
            for _, c in ipairs(candidates) do
                local c_cos_a = math.cos(c.angle)
                local c_sin_a = math.sin(c.angle)
                local sample_x = c.x + c_cos_a * 10
                local sample_z = c.z + c_sin_a * 10
                local fish = TheSim:FindEntities(sample_x, 0, sample_z, FISH_DETECT_RADIUS, {"oceanfish"})
                c.fish_count = #fish
                if c.fish_count > 0 then has_any_fish = true end
            end

            if has_any_fish then
                
                for _, c in ipairs(candidates) do
                    local score = c.fish_count * W_FISH - math.sqrt(c.dist_sq) * W_DIST
                    _dbg(string.format("_PhaseFindShore: 候选(%.1f,%.1f) fish=%d dist=%.1f score=%.1f",
                        c.x, c.z, c.fish_count, math.sqrt(c.dist_sq), score))
                end
                table.sort(candidates, function(a, b)
                    local sa = a.fish_count * W_FISH - math.sqrt(a.dist_sq) * W_DIST
                    local sb = b.fish_count * W_FISH - math.sqrt(b.dist_sq) * W_DIST
                    return sa > sb
                end)
            else
                
                table.sort(candidates, function(a, b) return a.dist_sq < b.dist_sq end)
                _dbg("FindShore: 所有候选点均无检测到鱼群，降级为距离优先")
            end

            local best = candidates[1]
            self._shore_spot = { x = best.x, z = best.z, angle = best.angle, cast_x = best.cast_x, cast_z = best.cast_z }
            self._hook_wait_start_time = nil  
            self._phase = "approach_shore"
            _dbg(string.format("FindOceanFishingSpot: 找到岸边点 x=%.1f z=%.1f angle=%.2f(%.0f°) fish=%d",
                best.x, best.z, best.angle, math.deg(best.angle), best.fish_count or 0))
        end
        _dbg(string.format("_PhaseFindShore: 找到岸边点 (%.1f, %.1f), angle=%.2f, dist=%.1f → approach_shore",
            candidates[1].x, candidates[1].z, candidates[1].angle, math.sqrt(candidates[1].dist_sq)))
    else
        self:_SayLine("OCEAN_FISHING_NO_SHORE", 30)
        _dbg("_PhaseFindShore: 未找到合适岸边, FAILED")
        inst._oceanfishing_active = false
        self:_Reset()
        self.status = FAILED
    end
end





function NPCOceanFishingBehavior:_PhaseApproachShore()
    local inst = self.inst
    local spot = self._shore_spot

    if not spot then
        _dbg("_PhaseApproachShore: 无岸边点 → find_shore")
        self._phase = "find_shore"
        self._waypoints = nil
        self._waypoint_idx = nil
        return
    end

    local ax, ay, az = inst.Transform:GetWorldPosition()

    
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
                _dbg(string.format("_PhaseApproachShore: 原生 A* 找到路径 (%d 个路径点)", #self._waypoints))
            else
                
                local near_dx = ax - spot.x
                local near_dz = az - spot.z
                local near_dist_sq = near_dx * near_dx + near_dz * near_dz
                local near_ok = near_dist_sq <= APPROACH_EQUIP_DIST * APPROACH_EQUIP_DIST
                if near_ok then
                    _dbg(string.format("_PhaseApproachShore: A*无效但已足够近 (dist=%.1f) → equip_rod", math.sqrt(near_dist_sq)))
                    self._phase = "equip_rod"
                    self._waypoints = nil
                    self._waypoint_idx = nil
                    self._approach_goto_issued = false
                    ResetStuckCheck(self, "_approach")
                else
                    _dbg("_PhaseApproachShore: 原生 A* 返回无效路径，重新搜索岸边")
                    self._shore_spot = nil
                    self._phase = "find_shore"
                    self._approach_goto_issued = false
                    ResetStuckCheck(self, "_approach")
                end
            end
            return
        elseif status == 2 then  
            TheWorld.Pathfinder:KillSearch(self._path_search_handle)
            self._path_search_handle = nil
            local fallback_path = PlanPathToTarget(inst, spot.x, spot.z)
            if fallback_path and #fallback_path > 0 then
                self._waypoints = fallback_path
                self._waypoint_idx = 1
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproachShore: 原生 A* 无路径，使用本地绕路方案 (%d 个路径点)", #fallback_path))
            else
                _dbg("_PhaseApproachShore: 原生 A* 未找到路径且本地绕路失败，重新搜索岸边")
                self._shore_spot = nil
                self._phase = "find_shore"
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
            end
            return
        end
        
        return
    end

    local dx = ax - spot.x
    local dz = az - spot.z
    local dist_sq = dx * dx + dz * dz

    if dist_sq <= APPROACH_EQUIP_DIST * APPROACH_EQUIP_DIST then
        inst.components.locomotor:Stop()
        self._phase = "equip_rod"
        self._waypoints = nil
        self._waypoint_idx = nil
        ResetStuckCheck(self, "_approach")
        _dbg(string.format("_PhaseApproachShore: 到达岸边 (dist=%.1f) → equip_rod", math.sqrt(dist_sq)))
        return
    end

    
    if self._waypoints then
        local wp = self._waypoints[self._waypoint_idx]
        if not wp then
            if dist_sq <= (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) * (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) then
                inst.components.locomotor:Stop()
                self._phase = "equip_rod"
                self._waypoints = nil
                self._waypoint_idx = nil
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproachShore: 路径点完成且已接近岸边 (dist=%.1f) → equip_rod", math.sqrt(dist_sq)))
                return
            end
            
            self._waypoints = nil
            self._waypoint_idx = nil
            if dist_sq > (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) * (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) then
                inst.components.locomotor:GoToPoint(Vector3(spot.x, 0, spot.z), nil, true)
                self._approach_goto_issued = true  
                _dbg(string.format("_PhaseApproachShore: waypoints耗尽但距离%.1f>%.1f, 直接GoToPoint到目标", math.sqrt(dist_sq), APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER))
            else
                self._approach_goto_issued = false
            end
            return
        end

        local wp_dist = math.sqrt((ax - wp.x)^2 + (az - wp.z)^2)

        if wp_dist <= 3 then
            _dbg(string.format("_PhaseApproachShore: 到达路径点 %d/%d", self._waypoint_idx, #self._waypoints))
            self._waypoint_idx = self._waypoint_idx + 1
            self._approach_goto_issued = false
            ResetStuckCheck(self, "_approach")
            if self._waypoint_idx > #self._waypoints and dist_sq <= (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) * (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) then
                inst.components.locomotor:Stop()
                self._phase = "equip_rod"
                self._waypoints = nil
                self._waypoint_idx = nil
                _dbg(string.format("_PhaseApproachShore: 最后路径点后已接近岸边 (dist=%.1f) → equip_rod", math.sqrt(dist_sq)))
            end
            return
        end

        local stuck = CheckStuckAndRetry(self, inst, "_approach", { check_interval = 4, min_move_dist = 2 })
        if stuck == "retry" then
            _dbg("_PhaseApproachShore: waypoint 阶段卡住，重新搜索岸边")
            inst.components.locomotor:Stop()
            self._shore_spot = nil
            self._phase = "find_shore"
            self._waypoints = nil
            self._waypoint_idx = nil
            self._approach_goto_issued = false
            ResetStuckCheck(self, "_approach")
            return
        end

        if not self._approach_goto_issued then
            local loco = inst.components.locomotor
            loco:GoToPoint(Vector3(wp.x, 0, wp.z), nil, true)
            self._approach_goto_issued = true
            _dbg(string.format("_PhaseApproachShore: GoToPoint → 路径点 %d/%d (%.1f,%.1f) dist=%.1f",
                self._waypoint_idx, #self._waypoints, wp.x, wp.z, wp_dist))
        end
        return
    end

    
    if not self._approach_goto_issued then
        if dist_sq <= (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) * (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) then
            inst.components.locomotor:Stop()
            self._phase = "equip_rod"
            self._waypoints = nil
            self._waypoint_idx = nil
            ResetStuckCheck(self, "_approach")
            _dbg(string.format("_PhaseApproachShore: 近距离避免重复提交A* (dist=%.1f) → equip_rod", math.sqrt(dist_sq)))
            return
        end
        self:_SayLine("OCEAN_FISHING_PATH_PLANNING", 25)
        local search_pathcaps = {
            allowocean = false,
            ignoreLand = false,
            ignorecreep = true,
            ignorewalls = false,
        }
        local handle = TheWorld.Pathfinder:SubmitSearch(ax, 0, az, spot.x, 0, spot.z, search_pathcaps)
        if handle then
            self._path_search_handle = handle
            self._approach_goto_issued = true
            _dbg(string.format("_PhaseApproachShore: 预先提交原生 A* 搜索 从(%.1f,%.1f)到(%.1f,%.1f)", ax, az, spot.x, spot.z))
            return
        else
            local fallback_path = PlanPathToTarget(inst, spot.x, spot.z)
            if fallback_path and #fallback_path > 0 then
                self._waypoints = fallback_path
                self._waypoint_idx = 1
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproachShore: 预搜索提交失败，改用本地绕路方案 (%d 个路径点)", #fallback_path))
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

        local s_ax, _, s_az = inst.Transform:GetWorldPosition()
        
        local search_pathcaps = {
            allowocean = false,
            ignoreLand = false,
            ignorecreep = true,
            ignorewalls = false,
        }
        local handle = TheWorld.Pathfinder:SubmitSearch(s_ax, 0, s_az, spot.x, 0, spot.z, search_pathcaps)
        if handle then
            self._path_search_handle = handle
            _dbg(string.format("_PhaseApproachShore: 卡住! 提交原生 A* 搜索 从(%.1f,%.1f)到(%.1f,%.1f)", s_ax, s_az, spot.x, spot.z))
        else
            local fallback_path = PlanPathToTarget(inst, spot.x, spot.z)
            if fallback_path and #fallback_path > 0 then
                self._waypoints = fallback_path
                self._waypoint_idx = 1
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
                _dbg(string.format("_PhaseApproachShore: SubmitSearch 失败，改用本地绕路方案 (%d 个路径点)", #fallback_path))
            else
                _dbg("_PhaseApproachShore: SubmitSearch 失败且本地绕路失败，重新搜索岸边")
                self._shore_spot = nil
                self._phase = "find_shore"
                self._approach_goto_issued = false
                ResetStuckCheck(self, "_approach")
            end
        end
        return
    end

    
    if not self._approach_goto_issued then
        local loco = inst.components.locomotor
        loco:GoToPoint(Vector3(spot.x, 0, spot.z), nil, true)
        self._approach_goto_issued = true
        _dbg(string.format("_PhaseApproachShore: GoToPoint → 岸边 (%.1f,%.1f) dist=%.1f (A* 寻路)",
            spot.x, spot.z, math.sqrt(dist_sq)))
    elseif self._bt_just_reset then
        PathRecovery.ResumeGoToAfterBTReset(self, inst, {
            goto_issued_key = "_approach_goto_issued",
            target_x = spot.x,
            target_z = spot.z,
            dist = math.sqrt(dist_sq),
            dbg_fn = _dbg,
            log_prefix = "_PhaseApproachShore",
        })
    end
end





function NPCOceanFishingBehavior:_PhaseEquipRod()
    local inst = self.inst

    self._prev_hand = EquipOceanFishingRod(inst)

    local hand = inst.components.inventory
        and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if not hand or hand.prefab ~= "oceanfishingrod" then
        _dbg("_PhaseEquipRod: 装备海钓竿失败 → FAILED")
        self:_SayLine("OCEAN_FISHING_NO_ROD", 30)
        inst._oceanfishing_active = false
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
                _dbg("_PhaseEquipRod: 装备草帽")
            end
        end
    end

    self._phase = "cast"
    _dbg("_PhaseEquipRod: 海钓竿已装备 → cast")
end





function NPCOceanFishingBehavior:_PhaseCast()
    local inst = self.inst
    local spot = self._shore_spot

    if not spot then
        _dbg("_PhaseCast: 无岸边点 → find_shore")
        
        self._approach_goto_issued = nil
        if self._path_search_handle then
            TheWorld.Pathfinder:KillSearch(self._path_search_handle)
            self._path_search_handle = nil
        end
        self._waypoints = nil
        self._waypoint_idx = nil
        ResetStuckCheck(self, "_approach")
        self._phase = "find_shore"
        return
    end

    local ax, _, az = inst.Transform:GetWorldPosition()
    local sdx = ax - spot.x
    local sdz = az - spot.z
    local shore_dist_sq = sdx * sdx + sdz * sdz
    local must_near_sq = (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER) * (APPROACH_EQUIP_DIST + APPROACH_EQUIP_BUFFER)
    if shore_dist_sq > must_near_sq then
        _dbg(string.format("_PhaseCast: 站位离岸偏远 (dist=%.1f)，先贴岸再投竿", math.sqrt(shore_dist_sq)))
        self._phase = "approach_shore"
        self._approach_goto_issued = nil
        self._waypoints = nil
        self._waypoint_idx = nil
        ResetStuckCheck(self, "_approach")
        return
    end

    
    if inst.sg:HasStateTag("fishing") or inst.sg:HasStateTag("busy") then
        local sgname = inst.sg.currentstate and inst.sg.currentstate.name or "?"
        -- npc_oceanfishing_idle 状态本身没有任何超时/事件出口, 完全依赖本行为驱动。
        -- 一旦行为已经回到 cast 阶段却仍停留在该状态(打招呼被打断、下线再上线导致状态机与
        -- 行为失步时最常见), 状态机会永远循环海钓动画 → 表现为"卡在海钓动画长时间不动"。
        -- 这里加一个看门狗: 卡住超过阈值就强制停竿并回到 idle, 让 cast 能正常重新投竿。
        if sgname == "npc_oceanfishing_idle" then
            if not self._cast_wait_sg_start then
                self._cast_wait_sg_start = GetTime()
                _dbg("_PhaseCast: cast 阶段检测到残留 npc_oceanfishing_idle, 开始看门狗计时")
            elseif GetTime() - self._cast_wait_sg_start > CAST_STUCK_TIMEOUT then
                _dbg(string.format("_PhaseCast: 残留海钓动画超时 %.1fs, 强制清理状态机 (失步恢复)",
                    GetTime() - self._cast_wait_sg_start))
                local rod_stuck = GetOceanFishingRod(inst)
                if rod_stuck and rod_stuck.components.oceanfishingrod then
                    rod_stuck.components.oceanfishingrod:StopFishing("cast_desync_recover")
                end
                inst.sg:GoToState("idle")
                self._cast_wait_sg_start = nil
            end
        else
            self._cast_wait_sg_start = nil
        end
        return
    end
    self._cast_wait_sg_start = nil

    if not FORCE_SPAWN_FISH then
        local spawned_chum = TrySpawnAutoChum(self, inst, spot)
        if spawned_chum then
            self._cast_delay_until = GetTime() + AUTO_CHUM_WAIT
        end
        if self._cast_delay_until and GetTime() < self._cast_delay_until then
            _dbg(string.format("_PhaseCast: 等待鱼食生效 %.1fs", self._cast_delay_until - GetTime()))
            return
        end
        self._cast_delay_until = nil
    else
        
        self._cast_delay_until = nil
    end
    local map = TheWorld and TheWorld.Map
    local tx, tz = nil, nil
    if map then
        tx, tz = FindSafeCastPoint(map, spot, ax, az)
        if tx then
            local bx, bz, score = FindBestCastPointBySafety(map, ax, az, tx, tz)
            tx, tz = bx, bz
            _dbg(string.format("_PhaseCast: 投点安全评分=%.2f", score))
            if score < 0.72 then
                _dbg("_PhaseCast: 投点安全评分过低，重新找岸边")
                self._shore_spot = nil
                self._phase = "find_shore"
                return
            end
        end
    end
    if not tx then
        _dbg("_PhaseCast: 沿岸线找不到海面投点 → find_shore")
        self._shore_spot = nil
        self._phase = "find_shore"
        return
    end

    
    ForceSpawnOceanFishAround(self, tx, tz)

    self._hook_landed = nil
    self._fish_caught = nil
    self._fishing_stopped = nil
    self._force_hook_done = nil
    self._last_force_bite_wait_log_time = nil
    self._last_strict_reel_time = nil
    self._early_bite_logged = nil
    inst.sg:GoToState("npc_oceanfishing_cast", { target_pos = Vector3(tx, 0, tz) })
    self._cast_time = GetTime()
    
    self._hook_wait_start_time = GetTime()
    self._phase = "wait_hook"
    self._badcast_retry = nil
    _dbg(string.format("_PhaseCast: 强制上钩延迟=%.1fs", FORCE_BITE_DELAY))
    _dbg(string.format("_PhaseCast: 投竿到 (%.1f, %.1f) → wait_hook", tx, tz))
end





function NPCOceanFishingBehavior:_PhaseWaitHook()
    local inst = self.inst

    if self._hook_landed then
        self._hook_landed = nil
        self._reel_start_time = GetTime()
        self._last_reel_time = 0
        self._phase = "reel_loop"
        _dbg("_PhaseWaitHook: 鱼钩落水 → reel_loop")
        return
    end

    
    if self._hook_wait_start_time and (GetTime() - self._hook_wait_start_time > HOOK_TIMEOUT) then
        _dbg("_PhaseWaitHook: 咬钩总超时")
        if self._shore_spot then
            local key = math.floor(self._shore_spot.x / 4) .. "_" .. math.floor(self._shore_spot.z / 4)
            if not self._blocked_shores then self._blocked_shores = {} end
            self._blocked_shores[key] = true
            _dbg("WaitHook: 超时无咬钩，标记岸边为失败: " .. key)
        end
        
        local rod2 = GetOceanFishingRod(inst)
        if rod2 and rod2.components.oceanfishingrod then
            rod2.components.oceanfishingrod:StopFishing()
        end
        if inst.sg:HasStateTag("fishing") then
            inst.sg:GoToState("npc_oceanfishing_stop")
        end
        self._shore_spot = nil
        self._hook_wait_start_time = nil
        self._cast_time = nil
        
        self._approach_goto_issued = nil
        if self._path_search_handle then
            TheWorld.Pathfinder:KillSearch(self._path_search_handle)
            self._path_search_handle = nil
        end
        self._waypoints = nil
        self._waypoint_idx = nil
        ResetStuckCheck(self, "_approach")
        self._phase = "find_shore"
        return
    end

    
    if self._cast_time and (GetTime() - self._cast_time > CAST_TIMEOUT) then
        _dbg("_PhaseWaitHook: 投竿超时 → 重试 cast")
        
        local rod = GetOceanFishingRod(inst)
        if rod and rod.components.oceanfishingrod then
            rod.components.oceanfishingrod:StopFishing()
        end
        if inst.sg:HasStateTag("fishing") then
            inst.sg:GoToState("npc_oceanfishing_stop")
        end
        self._phase = "cast"
        self._cast_time = nil
        return
    end

    
    if self._fishing_stopped then
        _dbg("_PhaseWaitHook: 钓鱼被中断, reason=" .. tostring(self._fishing_stopped_reason))
        self._fishing_stopped = nil
        self._phase = "cast"
        return
    end
end





function NPCOceanFishingBehavior:_PhaseReelLoop()
    local inst = self.inst

    
    if self._fish_caught then
        self._fish_caught = nil
        _dbg("_PhaseReelLoop: fishcaught 事件 → catch_fish")
        inst.sg:GoToState("npc_oceanfishing_catch")
        self._phase = "catch_fish"
        return
    end

    
    if self._fishing_stopped then
        local reason = self._fishing_stopped_reason or "unknown"
        _dbg("_PhaseReelLoop: 钓鱼中断, reason=" .. reason)
        self._fishing_stopped = nil
        self._fishing_stopped_reason = nil
        if reason == "badcast" then
            self._badcast_retry = (self._badcast_retry or 0) + 1
            if self._badcast_retry <= (NPC_TUNING.OCEAN_FISHING_CAST_RETRY_ON_BADCAST or 2) then
                _dbg(string.format("_PhaseReelLoop: badcast 重试 %d", self._badcast_retry))
                local rod_retry = GetOceanFishingRod(inst)
                if rod_retry and rod_retry.components.oceanfishingrod then
                    rod_retry.components.oceanfishingrod:StopFishing("badcast_retry")
                end
                if inst.sg and (inst.sg:HasStateTag("fishing") or inst.sg:HasStateTag("busy")) then
                    inst.sg:GoToState("npc_oceanfishing_stop")
                end
                self._cast_time = nil
                self._phase = "cast"
                return
            end
            _dbg("_PhaseReelLoop: badcast 重试耗尽，换岸")
            self._badcast_retry = 0
            self._shore_spot = nil
            self._phase = "find_shore"
            return
        end
        if reason == "linesnapped" then
            inst.sg:GoToState("npc_oceanfishing_linesnapped")
        else
            inst.sg:GoToState("npc_oceanfishing_stop")
        end
        
        self._phase = "cast"
        return
    end

    
    if self._reel_start_time and (GetTime() - self._reel_start_time > REEL_TIMEOUT) then
        _dbg("_PhaseReelLoop: 收竿超时 → 放弃, 重试 cast")
        local rod = GetOceanFishingRod(inst)
        if rod and rod.components.oceanfishingrod then
            rod.components.oceanfishingrod:StopFishing()
        end
        if inst.sg:HasStateTag("fishing") then
            inst.sg:GoToState("npc_oceanfishing_stop")
        end
        self._phase = "cast"
        return
    end

    
    local rod = GetOceanFishingRod(inst)
    if not rod or not rod.components.oceanfishingrod then
        _dbg("_PhaseReelLoop: 海钓竿丢失 → FAILED")
        inst._oceanfishing_active = false
        self:_Reset()
        self.status = FAILED
        return
    end

    local rod_comp = rod.components.oceanfishingrod
    local target = rod_comp.target

    
    if target == nil then
        _dbg("_PhaseReelLoop: target 为 nil, 等待事件...")
        return
    end

    local is_hook_target = target:HasTag("fishinghook") or (target.components.oceanfishinghook ~= nil)
    local elapsed = self._reel_start_time and (GetTime() - self._reel_start_time) or 0

    
    if FORCE_BITE_STRICT_DELAY and elapsed < FORCE_BITE_DELAY then
        if is_hook_target and not target:HasTag("partiallyhooked") then
            
            NudgeNearbyFishTowardHook(self, target)
        end
        if not is_hook_target then
            
            
            rod_comp.line_dist = (target:GetPosition() - rod:GetPosition()):Length()
            rod_comp:UpdateTensionRating()
        end
        local now_wait = GetTime()
        if not self._last_force_bite_wait_log_time or (now_wait - self._last_force_bite_wait_log_time) > 2 then
            self._last_force_bite_wait_log_time = now_wait
            _dbg(string.format("_PhaseReelLoop: 严格上钩延迟中 %.1f/%.1fs (剩余%.1fs)", elapsed, FORCE_BITE_DELAY, FORCE_BITE_DELAY - elapsed))
        end
        return
    end

    if not is_hook_target then
        if IsInventoryFullForCatch(inst) then
            _dbg("_PhaseReelLoop: 鱼已上钩但背包已满 → 结束海钓")
            if rod_comp and rod_comp.target ~= nil then
                rod_comp:StopFishing("inventoryfull")
            end
            if inst.sg and (inst.sg:HasStateTag("fishing") or inst.sg:HasStateTag("busy")) then
                inst.sg:GoToState("npc_oceanfishing_stop")
            end
            self._phase = "done"
            return
        end
        if self._reel_start_time and elapsed < FORCE_BITE_DELAY and not self._early_bite_logged then
            self._early_bite_logged = true
            _dbg(string.format("_PhaseReelLoop: 检测到提前上钩(%.1fs < %.1fs)，这是自然咬钩", elapsed, FORCE_BITE_DELAY))
        end
        if self._hooked_fish_guid ~= target.GUID then
            self._hooked_fish_guid = target.GUID
            self._hooked_fish_start_time = GetTime()
            self._hooked_reel_count = 0
            self._last_hooked_pull_time = nil
        end
        TightenCatchDistanceForNPC(target)
        PullHookedFishTowardPlayer(self, inst, target)
    else
        self._hooked_fish_guid = nil
        self._hooked_fish_start_time = nil
        self._hooked_reel_count = nil
        self._last_hooked_pull_time = nil
    end

    
    
    if (not is_hook_target) and target:HasTag("oceanfishing_catchable") and IsFishCloseEnoughForCatch(inst, target) and IsHookedCatchMature(self) then
        _dbg("_PhaseReelLoop: 目标已拉近，执行 CatchFish")
        rod_comp:CatchFish()
        return
    end

    
    if (not is_hook_target) and self._reel_start_time and (GetTime() - self._reel_start_time) > REEL_FORCE_CATCH_TIMEOUT and IsFishCloseEnoughForCatch(inst, target) and IsHookedCatchMature(self) then
        _dbg("_PhaseReelLoop: 收线超时且已拉近，强制 CatchFish")
        rod_comp:CatchFish()
        return
    end
    if (not is_hook_target) and target:HasTag("oceanfishing_catchable") and not IsFishCloseEnoughForCatch(inst, target) then
        local now2 = GetTime()
        if not self._last_close_wait_log_time or (now2 - self._last_close_wait_log_time) > 2 then
            self._last_close_wait_log_time = now2
            _dbg("_PhaseReelLoop: 已可捕获但距离仍偏远，继续拉近后再甩鱼")
        end
    end
    if (not is_hook_target) and target:HasTag("oceanfishing_catchable") and IsFishCloseEnoughForCatch(inst, target) and not IsHookedCatchMature(self) then
        local now3 = GetTime()
        if not self._last_mature_wait_log_time or (now3 - self._last_mature_wait_log_time) > 2 then
            self._last_mature_wait_log_time = now3
            _dbg(string.format("_PhaseReelLoop: 鱼已到近距离，继续慢收 (hooked=%.1fs, reel=%d/%d)",
                now3 - (self._hooked_fish_start_time or now3), self._hooked_reel_count or 0, HOOKED_CATCH_MIN_REELS))
        end
    end

    
    if is_hook_target and not target:HasTag("partiallyhooked") then
        if elapsed < FORCE_BITE_DELAY then
            local now_wait = GetTime()
            if not self._last_force_bite_wait_log_time or (now_wait - self._last_force_bite_wait_log_time) > 2 then
                self._last_force_bite_wait_log_time = now_wait
                _dbg(string.format("_PhaseReelLoop: 等待上钩冷却 %.1f/%.1fs (剩余%.1fs)", elapsed, FORCE_BITE_DELAY, FORCE_BITE_DELAY - elapsed))
            end
            return
        end
        NudgeNearbyFishTowardHook(self, target)
        if self._reel_start_time and (GetTime() - self._reel_start_time) >= FORCE_BITE_DELAY then
            TryForceHookFish(self, inst, target, rod)
        end
        return
    end

    
    local tension = rod_comp:GetTensionRating()
    local reel_interval = 0.8  
    if target:HasTag("partiallyhooked") then
        
        reel_interval = 0.2
    elseif tension < 0.10 then
        reel_interval = 0.4  
    elseif tension >= 0.10 and tension < 0.70 then
        reel_interval = 0.8  
    elseif tension >= 0.70 and tension < 0.82 then
        reel_interval = 1.6  
    else
        
        return
    end

    local now = GetTime()
    if now - (self._last_reel_time or 0) < reel_interval then
        return
    end
    self._last_reel_time = now

    
    if not inst.sg:HasStateTag("reeling") and not inst.sg:HasStateTag("busy") then
        inst.sg:GoToState("npc_oceanfishing_reel")
        if not is_hook_target then
            self._hooked_reel_count = (self._hooked_reel_count or 0) + 1
        end
        _dbg(string.format("_PhaseReelLoop: Reel! tension=%.2f, interval=%.1f", tension, reel_interval))
    end
end





function NPCOceanFishingBehavior:_PhaseCatchFish()
    local inst = self.inst

    if inst._oceanfishing_catch_done then
        inst._oceanfishing_catch_done = nil
        inst._oceanfishing_catch_count = (inst._oceanfishing_catch_count or 0) + 1

        self:_SayLine("OCEAN_FISHING_CATCH", 5)
        _dbg(string.format("_PhaseCatchFish: 捕获! count=%d/%d",
            inst._oceanfishing_catch_count, NPC_TUNING.OCEAN_FISHING_MAX_CATCH))

        
        if IsInventoryFullForCatch(inst) then
            _dbg("_PhaseCatchFish: 背包已满 → murder_fish")
            self._phase = "murder_fish"
        else
            self._pickup_wait_until = GetTime() + 0.35 
            self._pickup_started_time = GetTime()
            self._pickup_target = nil
            self._pickup_goto_issued = nil
            self._pickup_action_time = nil
            self._phase = "pickup_catch_fish"
            _dbg("_PhaseCatchFish: → pickup_catch_fish")
        end
        return
    end

    
    if not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("catchfish") then
        
        inst._oceanfishing_catch_done = nil
        inst._oceanfishing_catch_count = (inst._oceanfishing_catch_count or 0) + 1
        if IsInventoryFullForCatch(inst) then
            _dbg("_PhaseCatchFish: 动画结束(兜底)+背包已满 → murder_fish")
            self._phase = "murder_fish"
        else
            self._pickup_wait_until = GetTime() + 0.35
            self._pickup_started_time = GetTime()
            self._pickup_target = nil
            self._pickup_goto_issued = nil
            self._pickup_action_time = nil
            self._phase = "pickup_catch_fish"
            _dbg("_PhaseCatchFish: 动画结束(兜底) → pickup_catch_fish")
        end
    end
end

function NPCOceanFishingBehavior:_PhasePickupCatchFish()
    local inst = self.inst
    local inv = inst.components.inventory
    if inv == nil then
        self._phase = "done"
        return
    end
    if IsInventoryFullForCatch(inst) then
        _dbg("_PhasePickupCatchFish: 背包已满 → murder_fish")
        self._phase = "murder_fish"
        return
    end

    local now = GetTime()
    if self._pickup_wait_until and now < self._pickup_wait_until then
        return
    end

    local function FindNearestCatchItem()
        local x, _, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, 0, z, 8, { "oceanfish" }, { "INLIMBO", "NOCLICK" })
        local best, best_d2 = nil, nil
        for _, e in ipairs(ents) do
            if e:IsValid()
                and e.components.inventoryitem ~= nil
                and e.components.inventoryitem.canbepickedup
                and e.components.inventoryitem:GetGrandOwner() == nil then
                local ex, _, ez = e.Transform:GetWorldPosition()
                local dx, dz = ex - x, ez - z
                local d2 = dx * dx + dz * dz
                if best_d2 == nil or d2 < best_d2 then
                    best = e
                    best_d2 = d2
                end
            end
        end
        return best, best_d2
    end

    if self._pickup_target == nil or not self._pickup_target:IsValid()
        or self._pickup_target.components.inventoryitem == nil
        or self._pickup_target.components.inventoryitem:GetGrandOwner() ~= nil then
        self._pickup_target = nil
        self._pickup_goto_issued = nil
        self._pickup_action_time = nil
    end

    if self._pickup_target == nil then
        local target = FindNearestCatchItem()
        if target ~= nil then
            self._pickup_target = target
            self._pickup_goto_issued = nil
            _dbg("_PhasePickupCatchFish: 找到甩上岸鱼，开始拾取")
        end
    end

    if self._pickup_target == nil then
        
        if self._pickup_started_time and (now - self._pickup_started_time) > 2.5 then
            if (inst._oceanfishing_catch_count or 0) >= NPC_TUNING.OCEAN_FISHING_MAX_CATCH then
                _dbg("_PhasePickupCatchFish: 未找到可拾取鱼且达到上限 → murder_fish")
                self._phase = "murder_fish"
            else
                _dbg("_PhasePickupCatchFish: 未找到可拾取鱼(超时) → murder_fish")
                self._phase = "murder_fish"
            end
        end
        return
    end

    local tx, _, tz = self._pickup_target.Transform:GetWorldPosition()
    local x, _, z = inst.Transform:GetWorldPosition()
    local dx, dz = tx - x, tz - z
    local d2 = dx * dx + dz * dz
    if d2 <= (1.8 * 1.8) then
        if self._pickup_target.components.inventoryitem:GetGrandOwner() ~= nil or not self._pickup_target:IsValid() then
            if (inst._oceanfishing_catch_count or 0) >= NPC_TUNING.OCEAN_FISHING_MAX_CATCH then
                _dbg("_PhasePickupCatchFish: 已拾取并达到上限 → murder_fish")
                self._phase = "murder_fish"
            else
                _dbg("_PhasePickupCatchFish: 已拾取 → murder_fish")
                self._phase = "murder_fish"
            end
            return
        end
        if self._pickup_action_time == nil or (now - self._pickup_action_time) > 0.9 then
            self._pickup_action_time = now
            local ba = BufferedAction(inst, self._pickup_target, ACTIONS.PICKUP)
            inst:PushBufferedAction(ba)
            self._pickup_goto_issued = nil
        end
    else
        if not self._pickup_goto_issued then
            inst.components.locomotor:GoToPoint(Vector3(tx, 0, tz), nil, true)
            self._pickup_goto_issued = true
        end
    end
end





function NPCOceanFishingBehavior:_PhaseMurderFish()
    _dbg(string.format("_PhaseMurderFish: ENTER, murder_enabled=%s (type=%s)", 
        tostring(NPC_TUNING.OCEAN_FISHING_MURDER_FISH), type(NPC_TUNING.OCEAN_FISHING_MURDER_FISH)))
    local inst = self.inst

    
    if not NPC_TUNING.OCEAN_FISHING_MURDER_FISH then
        _dbg("_PhaseMurderFish: 杀鱼开关关闭，跳过 → deposit_fish")
        self._phase = "deposit_fish"
        return
    end

    if self._murder_started then
        local sg_name = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name or ""
        if sg_name == "idle" or sg_name == "" then
            self._murder_started = nil
            self._murder_delay_start = nil

            _dbg(string.format("_PhaseMurderFish: 完成, count=%d/%d",
                inst._oceanfishing_catch_count or 0, NPC_TUNING.OCEAN_FISHING_MAX_CATCH))

            if (inst._oceanfishing_catch_count or 0) >= NPC_TUNING.OCEAN_FISHING_MAX_CATCH then
                _dbg("_PhaseMurderFish: 达到上限 → deposit_fish")
                
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
            else
                
                self._fish_caught = nil
                self._fishing_stopped = nil
                self._hook_landed = nil
                self._phase = "cast"
                _dbg("_PhaseMurderFish: 未达上限 → cast 继续钓")
            end
        end
        return
    end

    
    local inv = inst.components.inventory
    if not inv then
        
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

    local fish_item = inv:FindItem(function(item)
        return item:IsValid() and item:HasTag("oceanfish")
    end)

    if not fish_item then
        _dbg("_PhaseMurderFish: 背包中无oceanfish标签物品")
        
        if (inst._oceanfishing_catch_count or 0) >= NPC_TUNING.OCEAN_FISHING_MAX_CATCH then
            
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
        else
            self._phase = "cast"
        end
        _dbg("_PhaseMurderFish: 无活鱼, → " .. self._phase)
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





function NPCOceanFishingBehavior:_PhaseDepositFish()
    local inst = self.inst

    local deposit_pos = NPC_TUNING.OCEAN_FISHING_DEPOSIT_POS or inst._oceanfishing_deposit_pos

    if not deposit_pos then
        _dbg("_PhaseDepositFish: 无存放点 → done")
        self._phase = "done"
        return
    end

    if not self._deposit_phase_entered then
        self._deposit_phase_entered = true
        _dbg("_PhaseDepositFish: 开始, deposit_pos=" .. tostring(deposit_pos))
    end

    
    local rod = GetOceanFishingRod(inst)
    if rod and rod.components.oceanfishingrod and rod.components.oceanfishingrod.target then
        rod.components.oceanfishingrod:StopFishing()
    end
    if inst.sg:HasStateTag("fishing") or inst.sg:HasStateTag("npc_fishing") then
        inst.sg:GoToState("npc_oceanfishing_stop")
    end

    
    SafeRestoreWeapon(inst, self._prev_hand)
    self._prev_hand = nil

    local pos_x, pos_y, pos_z = inst.Transform:GetWorldPosition()
    local dx = pos_x - deposit_pos.x
    local dz = pos_z - deposit_pos.z
    local dist = math.sqrt(dx * dx + dz * dz)
    local final_arrive_dist = math.max(DEPOSIT_ARRIVE_DIST, (NPC_TUNING.OCEAN_FISHING_DEPOSIT_RADIUS or 12) - 1)

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
                if dist > final_arrive_dist then
                    local loco_final = inst.components.locomotor
                    loco_final:GoToPoint(Vector3(deposit_route_x, 0, deposit_route_z), nil, true)
                    self._deposit_goto_issued = true  
                    _dbg(string.format("_PhaseDepositFish: waypoints耗尽但距离%.1f>%.1f, 直接GoToPoint到目标", dist, final_arrive_dist))
                else
                    self._deposit_goto_issued = false
                end
                return
            end

            local wp_dx = pos_x - wp.x
            local wp_dz = pos_z - wp.z
            local wp_dist = math.sqrt(wp_dx * wp_dx + wp_dz * wp_dz)

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
            self:_SayLine("OCEAN_FISHING_DEPOSIT_RETURN", 20)
            local search_pathcaps = {
                allowocean = false,
                ignoreLand = false,
                ignorecreep = true,
                ignorewalls = false,
            }
            local handle = TheWorld.Pathfinder:SubmitSearch(pos_x, 0, pos_z, deposit_route_x, 0, deposit_route_z, search_pathcaps)
            if handle then
                self._deposit_search_handle = handle
                self._deposit_goto_issued = true
                _dbg(string.format("_PhaseDepositFish: 预先提交原生 A* 搜索(%d/%d) 从(%.1f,%.1f)到(%.1f,%.1f)",
                    route_idx, self._deposit_route_candidates and #self._deposit_route_candidates or 1,
                    pos_x, pos_z, deposit_route_x, deposit_route_z))
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

            local d_ax, _, d_az = inst.Transform:GetWorldPosition()
            
            local search_pathcaps = {
                allowocean = false,
                ignoreLand = false,
                ignorecreep = true,
                ignorewalls = false,
            }
            local handle = TheWorld.Pathfinder:SubmitSearch(d_ax, 0, d_az, deposit_route_x, 0, deposit_route_z, search_pathcaps)
            if handle then
                self._deposit_search_handle = handle
                _dbg(string.format("_PhaseDepositFish: 卡住! 提交原生 A* 搜索 从(%.1f,%.1f)到(%.1f,%.1f)", d_ax, d_az, deposit_route_x, deposit_route_z))
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
    _dbg("_PhaseDepositFish: 到达存放点中心")

    local deposit_radius = NPC_TUNING.OCEAN_FISHING_DEPOSIT_RADIUS or 12
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
    else
        self._phase = "deposit_drop"
        _dbg("_PhaseDepositFish: 无可用容器 → deposit_drop")
    end
end





function NPCOceanFishingBehavior:_PhaseDepositApproach()
    local inst = self.inst
    local container = self._deposit_target_container

    if not container or not container:IsValid()
       or not container.components or not container.components.container then
        _dbg("_PhaseDepositApproach: 容器无效, 尝试下一个")
        self:_AdvanceDepositContainer()
        return
    end

    local dist = math.sqrt(inst:GetDistanceSqToInst(container))
    local dep_log_key = string.format("%s|%.0f", tostring(container), dist)
    if dep_log_key ~= self._last_deposit_log then
        self._last_deposit_log = dep_log_key
        _dbg(string.format("_PhaseDepositApproach: 走向容器 %s, dist=%.1f", tostring(container.prefab or container), dist))
    end

    if dist > 2 then
        local tx, ty, tz = container.Transform:GetWorldPosition()
        inst.components.locomotor:GoToPoint(Vector3(tx, ty, tz), nil, true)
        return
    end

    inst.components.locomotor:Stop()
    inst._oceanfishing_deposit_done = nil

    _dbg(string.format("_PhaseDepositApproach: 到达容器 %s, 触发 access_container", tostring(container)))

    inst.sg:GoToState("access_container", {
        container = container,
        action_fn = function(npc, cont)
            if not cont or not cont:IsValid() then return end
            local cont_comp = cont.components and cont.components.container
            if not cont_comp then return end
            local ninv = npc.components.inventory
            if not ninv then return end
            local stored = 0
            local catch_items = ninv:FindItems(IsDepositableOceanCatchItem) or {}
            for _, item in ipairs(catch_items) do
                if IsDepositableOceanCatchItem(item) then
                    if not cont_comp:IsFull() then
                        local taken = ninv:RemoveItem(item, true)
                        if taken then
                            if cont_comp:GiveItem(taken) then
                                stored = stored + 1
                                _dbg("[deposit action_fn] 存入 " .. taken.prefab .. " → " .. cont.prefab)
                            else
                                ninv:GiveItem(taken)
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
            npc._oceanfishing_deposit_done = true
            _dbg("[deposit on_done] access_container 完成")
        end,
    })

    self._phase = "deposit_storing"
end





function NPCOceanFishingBehavior:_PhaseDepositStoring()
    local inst = self.inst

    if not inst._oceanfishing_deposit_done then
        if inst.sg and not inst.sg:HasStateTag("busy") then
            inst._oceanfishing_deposit_done = true
        else
            return
        end
    end

    inst._oceanfishing_deposit_done = nil
    _dbg("_PhaseDepositStoring: access_container 已完成")

    
    local inv = inst.components.inventory
    local has_fish = false
    if inv then
        InvUtil.ForEachCarriedItem(inst, function(item)
            if IsDepositableOceanCatchItem(item) then
                has_fish = true
                return true
            end
        end)
    end

    if not has_fish then
        _dbg("_PhaseDepositStoring: 背包无鱼 → done")
        self._phase = "done"
        return
    end

    _dbg("_PhaseDepositStoring: 背包仍有鱼, 尝试下一个容器")
    self:_AdvanceDepositContainer()
end





function NPCOceanFishingBehavior:_PhaseDepositDrop()
    local inst = self.inst
    local inv = inst.components.inventory
    if not inv then
        self._phase = "done"
        return
    end

    if not self._deposit_drop_started then
        self._deposit_drop_started = true
        inst._oceanfishing_deposit_done = nil

        
        local dropped = 0
        local catch_items = inv:FindItems(IsDepositableOceanCatchItem) or {}
        for _, item in ipairs(catch_items) do
            if IsDepositableOceanCatchItem(item) then
                local taken = inv:RemoveItem(item, true)
                if taken then
                    taken.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    if taken.components.inventoryitem then
                        taken.components.inventoryitem:OnDropped(true)
                    end
                    dropped = dropped + 1
                end
            end
        end
        _dbg("_PhaseDepositDrop: 丢弃鱼数量=" .. dropped)

        self._deposit_drop_started = nil
        self._phase = "done"
        _dbg("_PhaseDepositDrop: → done")
    end
end





function NPCOceanFishingBehavior:_AdvanceDepositContainer()
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
        _dbg("_AdvanceDepositContainer: 下一个容器 idx=" .. idx)
    else
        self._phase = "deposit_drop"
        _dbg("_AdvanceDepositContainer: 无更多可用容器 → deposit_drop")
    end
end

function NPCOceanFishingBehavior:_PhaseDone()
    local inst = self.inst
    _dbg("_PhaseDone: 海钓完成")

    
    SafeRestoreWeapon(inst, self._prev_hand)
    self._prev_hand = nil

    
    local hx, hy, hz = inst.Transform:GetWorldPosition()
    if inst.components.knownlocations then
        inst.components.knownlocations:RememberLocation("home", Vector3(hx, hy, hz))
        _dbg(string.format("_PhaseDone: 更新 home point → (%.1f, %.1f)", hx, hz))
    end

    inst._oceanfishing_active = false

    _dbg("_PhaseDone: 行为完成")
    self:_Reset()
    self.status = SUCCESS
end

return NPCOceanFishingBehavior
