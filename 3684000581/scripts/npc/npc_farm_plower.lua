-- scripts/npc/npc_farm_plower.lua
-- FarmManager 子模块：犁地/选址/区域管理相关方法
-- 通过 AttachTo(FarmManager) 注入方法到主类
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")

local Plower = {}

-- ════════════════════════════════════════════════════════════
--  本模块所需常量（与主模块一致）
-- ════════════════════════════════════════════════════════════
local SPACING   = NPC_TUNING.FARM_GRID_SPACING   or 1.3
local GRID_SIZE = NPC_TUNING.FARM_GRID_SIZE       or 3
local GRID_TOTAL = GRID_SIZE * GRID_SIZE
local MIN_SOIL_COUNT      = NPC_TUNING.FARM_MIN_SOIL_COUNT      or GRID_TOTAL
local SPOT_RADIUS         = NPC_TUNING.FARM_SPOT_RADIUS         or 0.8
local BLOCKER_RADIUS      = NPC_TUNING.FARM_BLOCKER_RADIUS      or 2
local ENTITY_RADIUS       = NPC_TUNING.FARM_WEED_CHECK_RANGE    or 6

-- 流星雨安全距离
local METEOR_SAFE_DIST_SQ = (TUNING.METEOR_SHOWER_SPAWN_RADIUS + 10) ^ 2
local METEOR_SPAWNER_TAGS = { "CLASSIFIED" }

-- 水域安全距离
local WATER_SAFE_DIST    = 10
local WATER_SAFE_DIST_SQ = WATER_SAFE_DIST * WATER_SAFE_DIST
local POND_TAGS          = { "pond" }

-- 阻挡物检查半径
local FARM_BLOCKER_CHECK_RADIUS = 15

local function FarmLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        print("[种植调试]", ...)
    end
end

-- ════════════════════════════════════════════════════════════
--  本模块私有辅助函数
-- ════════════════════════════════════════════════════════════

--- 判断实体是否为可移除的障碍物（可砍/可挖的植物等）
local function _IsRemovableObstacle(ent)
    if not ent or not ent:IsValid() then return false end

    local prefab = ent.prefab
    if prefab and (prefab == "cave_entrance" or prefab == "cave_entrance_open"
        or prefab:find("sinkhole") or prefab:find("wormhole")
        or prefab:find("cave_exit")) then
        return false
    end

    if prefab and (prefab:find("pond") or prefab == "oasis_pond") then
        return false
    end

    if ent.components.workable and ent.components.workable:CanBeWorked() then
        local work_action = ent.components.workable:GetWorkAction()
        if work_action == ACTIONS.CHOP or work_action == ACTIONS.DIG then
            return true
        end
    end

    if ent:HasTag("plant") then
        return true
    end

    if prefab then
        if prefab:find("tree") or
           prefab:find("grass") or
           prefab:find("sapling") or
           prefab:find("berrybush") or
           prefab:find("twiggytree") then
            return true
        end
    end

    return false
end

-- ════════════════════════════════════════════════════════════
--  AttachTo: 将犁地/选址方法注入 FarmManager
-- ════════════════════════════════════════════════════════════

function Plower.AttachTo(FarmManager)

    -- 根据 farm_center 生成 NxN 网格种植点列表（居中对称）
    -- 保留旧接口，供 FindFarmArea 自动选址路径使用
    function FarmManager:_BuildSpots()
        local half = (GRID_SIZE - 1) / 2
        self.farm_spots = {}
        for row = -half, half do
            for col = -half, half do
                local sx = self.farm_center.x + col * SPACING
                local sz = self.farm_center.z + row * SPACING
                table.insert(self.farm_spots, {
                    x = sx, z = sz,
                    soil = nil,
                    plant = nil,
                })
            end
        end
    end

    -- 扫描范围内所有 FARMING_SOIL 地砖，逐砖生成 2×2 坑位
    -- 供 SetFarmCenter 手动指定种地路径使用，支持多块地砖并排
    function FarmManager:_BuildAllSpots(scan_radius)
        self.farm_spots = {}
        local map = TheWorld.Map
        local cx, cz = self.farm_center.x, self.farm_center.z
        local radius = scan_radius or (NPC_TUNING.FARM_WORK_RADIUS or 40)
        local tile_range = math.ceil(radius / TILE_SCALE)
        -- 关键：用游戏的 GetTileCenterPoint 拿到 farm_center 所在 tile 的真实中心
        -- 之前用 floor(x/4)*4+2 错了，游戏 tile 中心是 4k 不是 4k+2
        local origin_x, _, origin_z = map:GetTileCenterPoint(cx, 0, cz)
        if not origin_x then origin_x, origin_z = cx, cz end
        local half = (GRID_SIZE - 1) / 2
        local seen = {}
        local tile_count = 0
        local tile_centers = {}

        for dx = -tile_range, tile_range do
            for dz = -tile_range, tile_range do
                local tcx = origin_x + dx * TILE_SCALE
                local tcz = origin_z + dz * TILE_SCALE
                local ddx, ddz = tcx - cx, tcz - cz
                if ddx * ddx + ddz * ddz <= radius * radius then
                    if map:GetTileAtPoint(tcx, 0, tcz) == WORLD_TILES.FARMING_SOIL then
                        tile_count = tile_count + 1
                        table.insert(tile_centers, string.format("(%.0f,%.0f)", tcx, tcz))
                        for row = -half, half do
                            for col = -half, half do
                                local sx = tcx + col * SPACING
                                local sz = tcz + row * SPACING
                                local key = string.format("%.1f_%.1f", sx, sz)
                                if not seen[key] then
                                    seen[key] = true
                                    table.insert(self.farm_spots, {
                                        x = sx, z = sz,
                                        soil = nil,
                                        plant = nil,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end

        FarmLog(string.format("_BuildAllSpots: 扫描半径=%.0f 格, 找到 %d 块FARMING_SOIL地砖 [%s], 共 %d 坑",
            radius, tile_count, table.concat(tile_centers, " "), #self.farm_spots))
    end

    -- 检查候选位置是否靠近水域
    function FarmManager:_IsNearWater(x, z)
        local ponds = _G.TheSim:FindEntities(x, 0, z, WATER_SAFE_DIST, POND_TAGS)
        if #ponds > 0 then
            return true
        end
        local map = TheWorld.Map
        for i = 0, 7 do
            local angle = i * (math.pi / 4)
            local sx = x + WATER_SAFE_DIST * math.cos(angle)
            local sz = z + WATER_SAFE_DIST * math.sin(angle)
            if map:IsOceanAtPoint(sx, 0, sz) then
                return true
            end
        end
        return false
    end

    -- 检查候选位置是否在流星雨落点范围内
    function FarmManager:_IsInMeteorZone(x, z)
        local ents = _G.TheSim:FindEntities(x, 0, z, TUNING.METEOR_SHOWER_SPAWN_RADIUS + 10, METEOR_SPAWNER_TAGS)
        for _, ent in ipairs(ents) do
            if ent.prefab == "meteorspawner" and ent.components.meteorshower then
                local ex, _, ez = ent.Transform:GetWorldPosition()
                local dx, dz = x - ex, z - ez
                if dx * dx + dz * dz < METEOR_SAFE_DIST_SQ then
                    return true
                end
            end
        end
        return false
    end

    -- 严格检查指定位置的地砖是否可犁地
    function FarmManager:_IsTilePlowable(x, z)
        local map = TheWorld.Map
        if not map:CanPlantAtPoint(x, 0, z) then return false end
        if map:GetTileAtPoint(x, 0, z) == WORLD_TILES.FARMING_SOIL then return false end
        local ents = map:GetEntitiesOnTileAtPoint(x, 0, z)
        for _, ent in ipairs(ents) do
            if ent ~= self.inst
               and not (ent:HasTag("NOBLOCK") or ent:HasTag("locomotor")
                        or ent:HasTag("NOCLICK") or ent:HasTag("FX")
                        or ent:HasTag("DECOR")) then
                return false
            end
        end
        return true
    end

    -- 检查指定位置附近的阻挡实体数量
    function FarmManager:_CountBlockers(x, z, radius)
        radius = radius or FARM_BLOCKER_CHECK_RADIUS
        local ents = _G.TheSim:FindEntities(x, 0, z, radius)
        local real_blockers = 0
        local removable_count = 0
        for _, ent in ipairs(ents) do
            if ent ~= self.inst
               and not ent:IsInLimbo()
               and not (ent:HasTag("NOBLOCK") or ent:HasTag("locomotor")
                        or ent:HasTag("NOCLICK") or ent:HasTag("FX")
                        or ent:HasTag("DECOR")  or ent:HasTag("_inventoryitem")) then
                if _IsRemovableObstacle(ent) then
                    removable_count = removable_count + 1
                else
                    real_blockers = real_blockers + 1
                end
            end
        end
        return real_blockers, removable_count
    end

    -- 寻找农场位置
    function FarmManager:FindFarmArea()
        if self.initialized then return true end
        if self._user_specified_center then return true end

        local inst = self.inst
        if not inst:IsValid() then return false end
        local ix, _, iz = inst.Transform:GetWorldPosition()
        local map = TheWorld.Map

        -- 【优先】检查附近是否已有 FARMING_SOIL 地皮
        local search_dist = self.config.search_max or NPC_TUNING.FARM_SEARCH_MAX_DIST or 200

        local farm_soils = _G.TheSim:FindEntities(ix, 0, iz, search_dist, {"soil"})
        if #farm_soils > 0 then
            local sx, _, sz = farm_soils[1].Transform:GetWorldPosition()
            local snap_x, _, snap_z = map:GetTileCenterPoint(sx, 0, sz)
            if snap_x then
                local tile = map:GetTileAtPoint(snap_x, 0, snap_z)
                if tile == WORLD_TILES.FARMING_SOIL then
                    self.farm_center = { x = snap_x, z = snap_z }
                    self:_BuildSpots()
                    self.initialized = true
                    self._post_plow_cleanup = true
                    self.state = "farming"
                    if self.inst.components.knownlocations then
                        self.inst.components.knownlocations:RememberLocation("home",
                            Vector3(snap_x, 0, snap_z))
                    end
                    local cleanup_radius = NPC_TUNING.FARM_SOIL_CLEANUP_RADIUS or 4
                    self.inst:DoTaskInTime(2, function()
                        if not self.inst:IsValid() or not self.farm_center then return end
                        local ccx, ccz = self.farm_center.x, self.farm_center.z
                        local cleanup_ents = _G.TheSim:FindEntities(ccx, 0, ccz, cleanup_radius)
                        local rm_count = 0
                        for _, e in ipairs(cleanup_ents) do
                            if e:IsValid() and e.prefab == "farm_soil" then
                                e:Remove()
                                rm_count = rm_count + 1
                            end
                        end
                        FarmLog(string.format("FindFarmArea: 清理了 %d 个犁地机随机 farm_soil", rm_count))
                        for _, sp in ipairs(self.farm_spots) do
                            sp.soil = nil
                            sp.plant = nil
                        end
                        self._last_all_spots_scan = 0
                        self._post_plow_cleanup = false
                    end)
                    FarmLog(string.format("FindFarmArea: 发现现有 FARMING_SOIL，在 (%.1f, %.1f) 建立农场，清理随机soil中", snap_x, snap_z))
                    return true
                end
            end
        end

        -- 方式2：搜索 FARMING_SOIL 地砖
        for dist = 1, search_dist, 4 do
            for a = 1, 12 do
                local angle = (a - 1) * (2 * math.pi / 12)
                local cx = ix + dist * math.cos(angle)
                local cz = iz + dist * math.sin(angle)
                local snap_x2, _, snap_z2 = map:GetTileCenterPoint(cx, 0, cz)
                if snap_x2 then
                    local tile = map:GetTileAtPoint(snap_x2, 0, snap_z2)
                    if tile == WORLD_TILES.FARMING_SOIL then
                        self.farm_center = { x = snap_x2, z = snap_z2 }
                        self:_BuildSpots()
                        self.initialized = true
                        self._post_plow_cleanup = true
                        self.state = "farming"
                        if self.inst.components.knownlocations then
                            self.inst.components.knownlocations:RememberLocation("home",
                                Vector3(snap_x2, 0, snap_z2))
                        end
                        local cleanup_radius2 = NPC_TUNING.FARM_SOIL_CLEANUP_RADIUS or 4
                        self.inst:DoTaskInTime(2, function()
                            if not self.inst:IsValid() or not self.farm_center then return end
                            local ccx2, ccz2 = self.farm_center.x, self.farm_center.z
                            local cleanup_ents2 = _G.TheSim:FindEntities(ccx2, 0, ccz2, cleanup_radius2)
                            local rm_count2 = 0
                            for _, e in ipairs(cleanup_ents2) do
                                if e:IsValid() and e.prefab == "farm_soil" then
                                    e:Remove()
                                    rm_count2 = rm_count2 + 1
                                end
                            end
                            FarmLog(string.format("FindFarmArea: 清理了 %d 个犁地机随机 farm_soil", rm_count2))
                            for _, sp in ipairs(self.farm_spots) do
                                sp.soil = nil
                                sp.plant = nil
                            end
                            self._last_all_spots_scan = 0
                            self._post_plow_cleanup = false
                        end)
                        FarmLog(string.format("FindFarmArea: 发现 FARMING_SOIL 地砖，直接在 (%.1f, %.1f) 建立农场", snap_x2, snap_z2))
                        return true
                    end
                end
            end
        end

        -- 搜索可犁地的区域
        local half = (GRID_SIZE - 1) / 2
        local min_dist = self.config.search_min or NPC_TUNING.FARM_SEARCH_MIN_DIST or 15
        local max_dist = self.config.search_max or NPC_TUNING.FARM_SEARCH_MAX_DIST or 30
        local attempts = NPC_TUNING.FARM_SEARCH_ATTEMPTS or 12

        local best_center = nil
        local best_count = 0
        local best_blockers = 999
        local MAX_REAL_BLOCKERS = 2

        for a = 1, attempts do
            local angle = (a - 1) * (2 * math.pi / attempts)
            for _, dist in ipairs({
                min_dist + math.random() * (max_dist - min_dist),
                min_dist,
                min_dist + (max_dist - min_dist) * 0.5,
            }) do
                local cx = ix + dist * math.cos(angle)
                local cz = iz + dist * math.sin(angle)

                local snap_x, _, snap_z = map:GetTileCenterPoint(cx, 0, cz)
                if snap_x then cx, cz = snap_x, snap_z end

                if not self:_IsTilePlowable(cx, cz) or self:_IsInMeteorZone(cx, cz) or self:_IsNearWater(cx, cz) then
                    -- skip
                else

                local count = 0
                for row = -half, half do
                    for col = -half, half do
                        local sx = cx + col * SPACING
                        local sz = cz + row * SPACING
                        if map:CanPlantAtPoint(sx, 0, sz) then
                            count = count + 1
                        end
                    end
                end

                if count >= MIN_SOIL_COUNT then
                    local real_blockers, removable = self:_CountBlockers(cx, cz)
                    if count > best_count or (count == best_count and real_blockers < best_blockers) then
                        best_count = count
                        best_center = { x = cx, z = cz }
                        best_blockers = real_blockers
                    end
                    if count >= GRID_SIZE * GRID_SIZE and real_blockers <= MAX_REAL_BLOCKERS then
                        break
                    end
                end

                end -- _IsTilePlowable guard
            end
            if best_count >= GRID_SIZE * GRID_SIZE and best_blockers <= MAX_REAL_BLOCKERS then break end
        end

        if best_center and best_count >= MIN_SOIL_COUNT then
            self.farm_center = best_center
            self:_BuildSpots()
            self.state = "searching"
            return true
        end

        -- 降级：以当前位置为中心
        local snapped_ix, _, snapped_iz = TheWorld.Map:GetTileCenterPoint(ix, 0, iz)
        local fb_x = snapped_ix or ix
        local fb_z = snapped_iz or iz
        if self:_IsTilePlowable(fb_x, fb_z) and not self:_IsInMeteorZone(fb_x, fb_z) and not self:_IsNearWater(fb_x, fb_z) then
        local fallback_count = 0
        for row = -half, half do
            for col = -half, half do
                local sx = fb_x + col * SPACING
                local sz = fb_z + row * SPACING
                if map:CanPlantAtPoint(sx, 0, sz) then
                    fallback_count = fallback_count + 1
                end
            end
        end
        if fallback_count >= math.max(GRID_TOTAL - 1, 1) then
            self.farm_center = { x = fb_x, z = fb_z }
            self:_BuildSpots()
            self.state = "searching"
            return true
        end
        end -- _IsTilePlowable fallback guard

        return false
    end

    -- 从背包获取犁地机物品
    function FarmManager:GetPlowItem()
        local inv = self.inst.components.inventory
        if not inv then return nil end
        for i = 1, inv.maxslots do
            local item = inv:GetItemInSlot(i)
            if item and item.prefab == "farm_plow_item" then
                return item
            end
        end
        return nil
    end

    -- 犁地完成回调
    function FarmManager:OnPlowFinished()
        self.plow_ent = nil
        self.initialized = true
        self._post_plow_cleanup = true
        self.state = "farming"
        if self.inst.components.knownlocations and self.farm_center then
            self.inst.components.knownlocations:RememberLocation("home",
                Vector3(self.farm_center.x, 0, self.farm_center.z))
        end
        local SOIL_CLEANUP_RADIUS = NPC_TUNING.FARM_SOIL_CLEANUP_RADIUS or 4
        self.inst:DoTaskInTime(2, function()
            if not self.inst:IsValid() or not self.farm_center then return end
            local cx, cz = self.farm_center.x, self.farm_center.z
            local ents = _G.TheSim:FindEntities(cx, 0, cz, SOIL_CLEANUP_RADIUS)
            local count = 0
            for _, e in ipairs(ents) do
                if e:IsValid() and e.prefab == "farm_soil" then
                    e:Remove()
                    count = count + 1
                end
            end
            FarmLog(string.format("OnPlowFinished: 清理了 %d 个犁地机 farm_soil", count))
            for _, spot in ipairs(self.farm_spots) do
                spot.soil = nil
                spot.plant = nil
            end
            self._last_all_spots_scan = 0
            self._post_plow_cleanup = false
        end)
    end

    -- 检查农场区域是否已被犁过
    function FarmManager:IsAreaPlowed()
        if not self.farm_center then return false end
        local map = TheWorld.Map
        local half = (GRID_SIZE - 1) / 2
        local plowed = 0
        for row = -half, half do
            for col = -half, half do
                local sx = self.farm_center.x + col * SPACING
                local sz = self.farm_center.z + row * SPACING
                if map:IsFarmableSoilAtPoint(sx, 0, sz) then
                    plowed = plowed + 1
                end
            end
        end
        local result = plowed >= GRID_TOTAL
        return result
    end

    -- 重新选址
    function FarmManager:RelocateFarmCenter()
        if not self.farm_center then return false end
        local map = TheWorld.Map
        local half = (GRID_SIZE - 1) / 2
        local cx, cz = self.farm_center.x, self.farm_center.z
        for _, dist in ipairs({4, 8}) do
            for i = 0, 7 do
                local angle = i * (math.pi / 4)
                local nx = cx + dist * math.cos(angle)
                local nz = cz + dist * math.sin(angle)
                local count = 0
                for row = -half, half do
                    for col = -half, half do
                        local sx = nx + col * SPACING
                        local sz = nz + row * SPACING
                        if map:CanPlantAtPoint(sx, 0, sz) then
                            count = count + 1
                        end
                    end
                end
                if count >= MIN_SOIL_COUNT then
                    if self:_IsInMeteorZone(nx, nz) or self:_IsNearWater(nx, nz) then
                        count = 0
                    end
                end
                if count >= MIN_SOIL_COUNT then
                    local real_blockers, _ = self:_CountBlockers(nx, nz)
                    if real_blockers > 2 then
                        count = 0
                    end
                end
                if count >= MIN_SOIL_COUNT then
                    local snapped_x, _, snapped_z = map:GetTileCenterPoint(nx, 0, nz)
                    if snapped_x then
                        self.farm_center = { x = snapped_x, z = snapped_z }
                    else
                        self.farm_center = { x = nx, z = nz }
                    end
                    self:_BuildSpots()
                    return true
                end
            end
        end
        return false
    end

end -- Plower.AttachTo

return Plower
