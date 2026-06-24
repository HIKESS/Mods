-- scripts/npc/npc_farm_manager.lua
-- NPC 通用农场管理模块（模块化，任何角色可复用）
-- 职责：农场选址、犁地机部署、farm_soil 追踪、种植/收获/照料/除草执行逻辑
-- 通过 config 表接受角色专属参数
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")

-- ════════════════════════════════════════════════════════════
--  调试日志函数
-- ════════════════════════════════════════════════════════════
local function FarmLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        print("[种植调试]", ...)
    end
end

local SPACING   = NPC_TUNING.FARM_GRID_SPACING   or 1.3
local GRID_SIZE = NPC_TUNING.FARM_GRID_SIZE       or 3
local GRID_TOTAL = GRID_SIZE * GRID_SIZE  -- 网格总点数（2×2=4）
local CHECK_INT = NPC_TUNING.FARM_CHECK_INTERVAL  or 5

-- 缓存农场搜索参数
local MIN_SOIL_COUNT      = NPC_TUNING.FARM_MIN_SOIL_COUNT      or GRID_TOTAL
local SPOT_RADIUS         = NPC_TUNING.FARM_SPOT_RADIUS         or 0.8
local BLOCKER_RADIUS      = NPC_TUNING.FARM_BLOCKER_RADIUS      or 2
local ENTITY_RADIUS       = NPC_TUNING.FARM_WEED_CHECK_RANGE    or 6
-- 外部土壤搜索范围（动态读取，支持运行时调整）
local function EXTERNAL_SEARCH_DIST()
    return NPC_TUNING.FARM_WORK_RADIUS or 40
end

-- 流星雨安全距离（TUNING.METEOR_SHOWER_SPAWN_RADIUS = 60，额外留 10 格缓冲）
local METEOR_SAFE_DIST_SQ = (TUNING.METEOR_SHOWER_SPAWN_RADIUS + 10) ^ 2
local METEOR_SPAWNER_TAGS = { "CLASSIFIED" }  -- meteorspawner 只有此标签

-- 水域安全距离（远离池塘和海岸线 10 格）
local WATER_SAFE_DIST    = 10
local WATER_SAFE_DIST_SQ = WATER_SAFE_DIST * WATER_SAFE_DIST
local POND_TAGS          = { "pond" }

-- 检查位置是否可达（NPC 可以走到）
-- 水面、空洞等不可通行位置返回 false
local function IsReachablePosition(x, y, z)
    return TheWorld.Map:IsPassableAtPoint(x, 0, z)
end

-- ════════════════════════════════════════════════════════════
--  种植模块
-- ════════════════════════════════════════════════════════════

local FarmManager = Class(function(self, inst, config)
    self.inst = inst
    self.config = config or {}
    self.farm_center = nil        -- {x, z} 农场中心坐标
    self.farm_spots  = {}         -- {{x, z, soil, plant}, ...} 自建 NxN 农场
    self.all_spots = {}           -- 统一农场点列表（包含自建 + 外部扫描）
    self.state = "idle"           -- idle → searching → plowing → farming
    self.plow_ent = nil           -- 部署中的犁地机实体引用
    self.initialized = false
    self._last_plant = 0
    self._last_tend  = 0
    self._last_water = 0
    self._last_all_spots_scan = 0 -- all_spots 上次扫描时间
    self._post_plow_cleanup = false -- 犁地后清理中标记
    
    -- 【通用化】用户指定的农场中心和存储目标
    self._user_specified_center = false  -- 是否由外部 API 指定中心点
    self._search_radius = nil            -- 用户指定的搜索半径
    self._storage_target = nil           -- 搬运目标容器实体
    self._storage_point = nil            -- 搬运目标坐标点
    self._trash_drop_point = nil         -- 垃圾/重物丢弃目标坐标点
end)

-- ════════════════════════════════════════════════════════════
--  注入子模块方法
-- ════════════════════════════════════════════════════════════
require("npc/npc_farm_plower").AttachTo(FarmManager)
require("npc/npc_farm_harvester").AttachTo(FarmManager)
require("npc/npc_farm_tender").AttachTo(FarmManager)

--- 设置农场中心和搜索半径（支持任意 NPC 在指定位置开始工作）
-- @param center_point  Vector3 或 {x=, z=} 或 {x, z} 格式
-- @param search_radius 搜索半径（格），nil 则用默认
-- @return true 设置成功，false 参数无效
function FarmManager:SetFarmCenter(center_point, search_radius)
    -- 允许传 nil 清空农场中心（供 StopWork / CancelFarm 复用）
    if center_point == nil then
        self.farm_center = nil
        self.farm_spots = {}
        self.all_spots = {}
        self._user_specified_center = false
        self.initialized = false
        self.state = "idle"
        self._last_all_spots_scan = 0
        FarmLog("SetFarmCenter: cleared")
        return true
    end

    if center_point then
        -- 灵活解析坐标格式
        local cx, cz
        if center_point.x ~= nil then
            -- {x=, z=} 或 Vector3 格式
            cx = center_point.x
            cz = center_point.z or center_point.y  -- Vector3 的 z 或兼容 y
        elseif center_point[1] ~= nil then
            -- {x, z} 数组格式
            cx = center_point[1]
            cz = center_point[2] or center_point[3]
        end
        
        if cx and cz then
            local map_snap = TheWorld.Map
            local snap_x, _, snap_z = map_snap:GetTileCenterPoint(cx, 0, cz)
            if snap_x and map_snap:GetTileAtPoint(snap_x, 0, snap_z) == WORLD_TILES.FARMING_SOIL then
                cx, cz = snap_x, snap_z
                FarmLog(string.format("SetFarmCenter: Snap到地砖中心 (%.1f, %.1f)", cx, cz))
            end

            self.farm_center = { x = cx, z = cz }
            self._user_specified_center = true
            self.initialized = true  -- 用户指定中心点，视为已初始化
            self.state = "farming"
            
            if search_radius then
                self._search_radius = search_radius
            end
            
            -- 刷新漫游锚点
            if self.inst.components.knownlocations then
                self.inst.components.knownlocations:RememberLocation("home",
                    Vector3(cx, 0, cz))
            end
            
            self:_BuildAllSpots(search_radius or self._search_radius)

            FarmLog(string.format("SetFarmCenter: (%.1f, %.1f) radius=%s spots=%d",
                cx, cz, tostring(search_radius or "default"), #self.farm_spots))

            -- 【清理干扰物】
            --   1) farm_soil 散落坑（距网格 > 0.6）：保留对齐的、删掉错位的
            --   2) farm_soil_debris 犁机碎屑：占 1.25 阻挡翻土，全部删除（无 soil 标签）
            if self.farm_spots and #self.farm_spots > 0 then
                local removed_soil, removed_debris = 0, 0
                for _, spot in ipairs(self.farm_spots) do
                    -- soil
                    local soil_ents = _G.TheSim:FindEntities(spot.x, 0, spot.z, 1.5, {"soil"})
                    for _, e in ipairs(soil_ents) do
                        if e:IsValid() and e.prefab == "farm_soil" then
                            local ex, _, ez = e.Transform:GetWorldPosition()
                            local ddx, ddz = ex - spot.x, ez - spot.z
                            if ddx * ddx + ddz * ddz > 0.6 * 0.6 then
                                e:Remove()
                                removed_soil = removed_soil + 1
                            end
                        end
                    end
                    -- debris
                    local debris_ents = _G.TheSim:FindEntities(spot.x, 0, spot.z, 1.5, {"farm_debris"})
                    for _, e in ipairs(debris_ents) do
                        if e:IsValid() and e.prefab == "farm_soil_debris" then
                            e:Remove()
                            removed_debris = removed_debris + 1
                        end
                    end
                end
                if removed_soil > 0 or removed_debris > 0 then
                    FarmLog(string.format("SetFarmCenter: 清理 farm_soil=%d, farm_soil_debris=%d",
                        removed_soil, removed_debris))
                end
            end

            -- 立即刷新农场状态
            self._last_all_spots_scan = 0  -- 重置冷却
            self:RefreshAllSpots(true)
            return true
        end
    end
    return false
end

--- 获取用户指定的搜索半径（未指定则返回 nil）
function FarmManager:GetSearchRadius()
    return self._search_radius
end

--- 设置搬运目标（收获物品放哪里）
-- @param target  容器实体、坐标点 {x=,z=} 或 nil（清除）
function FarmManager:SetStorageTarget(target)
    if target == nil then
        self._storage_target = nil
        self._storage_point = nil
        FarmLog("SetStorageTarget: 已清除")
    elseif type(target) == "table" and target.IsValid and target:IsValid() then
        -- 实体（如 treasurechest）
        self._storage_target = target
        local tx, _, tz = target.Transform:GetWorldPosition()
        self._storage_point = { x = tx, z = tz }
        FarmLog("SetStorageTarget: 容器实体 " .. tostring(target.prefab))
    elseif type(target) == "table" then
        -- 坐标点（{x=,z=} 或 {x, z}）
        local px = target.x or target[1]
        local pz = target.z or target[2] or target[3]
        if px and pz then
            self._storage_point = { x = px, z = pz }
            self._storage_target = nil
            FarmLog(string.format("SetStorageTarget: 坐标点 (%.1f, %.1f)", px, pz))
        end
    end
end

--- 获取搬运目标坐标点
function FarmManager:GetStoragePoint()
    return self._storage_point
end

--- 获取搬运目标容器（如果是实体且仍有效）
function FarmManager:GetStorageContainer()
    if self._storage_target and self._storage_target:IsValid() then
        return self._storage_target
    end
    self._storage_target = nil
    return nil
end

--- 设置垃圾丢弃目标点（重物/垃圾丢弃优先使用）
-- @param point {x=,z=} / {x,z} / nil
function FarmManager:SetTrashDropPoint(point)
    if point == nil then
        self._trash_drop_point = nil
        FarmLog("SetTrashDropPoint: 已清除")
        return
    end

    if type(point) == "table" then
        local px = point.x or point[1]
        local pz = point.z or point[2] or point[3]
        if px and pz then
            self._trash_drop_point = { x = px, z = pz }
            FarmLog(string.format("SetTrashDropPoint: (%.1f, %.1f)", px, pz))
        end
    end
end

--- 获取垃圾丢弃目标点
function FarmManager:GetTrashDropPoint()
    return self._trash_drop_point
end

-- ════════════════════════════════════════════════════════════
-- 犁地/选址方法已提取到 npc_farm_plower.lua
-- （FindFarmArea, _BuildSpots, _IsNearWater, _IsInMeteorZone,
--  _IsTilePlowable, _CountBlockers, GetPlowItem, OnPlowFinished,
--  IsAreaPlowed, RelocateFarmCenter）
-- ════════════════════════════════════════════════════════════

-- 重新应用角色专属植物属性覆盖（存档恢复后丢失）
-- force_oversized: 强制巨大植物
-- ignore_season:   无季节限制（覆盖 good_seasons）
-- 跳过 randomseed（没有 plant_def，等替换为实际植物后再应用）
function FarmManager:_ApplyPlantOverrides(plant)
    if not plant or not plant:IsValid() then return end
    -- randomseed 没有 plant_def，跳过
    if not plant.plant_def then return end
    local config = self.config
    local changed = false
    -- 强制巨大植物
    if config.force_oversized and not plant.force_oversized then
        plant.force_oversized = true
        changed = true
    end
    -- 无季节限制：覆盖 good_seasons 为全季节
    -- 使用 _npc_all_seasons 标记避免每次 RefreshSpots 重复拷贝
    if config.ignore_season then
        local pd = plant.plant_def
        if pd.good_seasons and not pd._npc_all_seasons then
            local new_def = {}
            for k, v in pairs(pd) do new_def[k] = v end
            new_def.good_seasons = { autumn = true, winter = true, spring = true, summer = true }
            new_def._npc_all_seasons = true  -- 标记已覆盖，不影响季节检测逻辑
            plant.plant_def = new_def
            changed = true
        end
    end
end

-- （犁地机相关方法 GetPlowItem / OnPlowFinished 已移至 npc_farm_plower.lua）

-- ────────────────────────────────────────────────────────────
-- 刷新农场状态：统一扫描 NPC 周围所有 FARMING_SOIL 地砖
-- ────────────────────────────────────────────────────────────

-- 统一的 spot 引用刷新
function FarmManager:_UpdateSpotReference(spot)
    if not spot then return end
    
    -- 刷新 soil 引用（失效或崩塌的 soil 视为 nil）
    if spot.soil and (not spot.soil:IsValid() or spot.soil:HasTag("NOBLOCK")) then
        spot.soil = nil
    end
    
    -- 刷新 plant 引用
    if spot.plant and not spot.plant:IsValid() then
        spot.plant = nil
    end
    
    -- 如果引用丢失，尝试从实际实体恢复
    if spot.soil == nil or spot.plant == nil then
        local ents = _G.TheSim:FindEntities(spot.x, 0, spot.z, SPOT_RADIUS)
        for _, e in ipairs(ents) do
            if e:IsValid() then
                -- 排除崩塌的 soil（带 NOBLOCK 标签），只接受正常 soil
                if spot.soil == nil and e:HasTag("soil") and not e:HasTag("NOBLOCK") then
                    spot.soil = e
                end
                if spot.plant == nil and e:HasTag("farm_plant") then
                    spot.plant = e
                    self:_ApplyPlantOverrides(e)
                end
            end
        end
    end
    
    -- needs_till 标记（外部 spot 用）
    if spot.is_external then
        spot.needs_till = (spot.soil == nil) and (spot.plant == nil)
    end
end

-- 地砖大小常量
local TILE_SCALE = 4

-- 统一扫描函数：替代原有的 RefreshSpots + RefreshExternalSoils
function FarmManager:RefreshAllSpots(force)
    local now = GetTime()
    if not force and now - self._last_all_spots_scan < CHECK_INT then return end
    self._last_all_spots_scan = now
    
    local inst = self.inst
    if not inst:IsValid() then return end
    
    -- 【统一中心点】所有空间扫描以 farm_center 为中心，保证移动中心点后立即生效
    local scan_x, scan_z
    if self.farm_center then
        scan_x, scan_z = self.farm_center.x, self.farm_center.z
    else
        -- 尚未建立农场，退化为 NPC 位置
        local px, _, pz = inst.Transform:GetWorldPosition()
        scan_x, scan_z = px, pz
    end
    local map = TheWorld.Map
    
    -- 步骤1：维护自建农场 farm_spots 的 soil/plant 有效性
    for _, spot in ipairs(self.farm_spots) do
        -- 统一引用刷新
        self:_UpdateSpotReference(spot)
        -- 监听植物被点燃事件
        if spot.plant ~= nil and spot.plant:IsValid() and not spot._ignite_listened then
            -- 清理旧监听（如果存在）
            if spot._ignite_listener and spot._ignite_plant and spot._ignite_plant:IsValid() then
                spot._ignite_plant:RemoveEventCallback("onignite", spot._ignite_listener)
            end
            -- 创建新监听函数
            spot._ignite_listener = function(plant, data)
                self:_OnCropIgnited(plant, data)
            end
            spot._ignite_plant = spot.plant
            spot._ignite_listened = true
            inst:ListenForEvent("onignite", spot._ignite_listener, spot.plant)
        end
        if spot.plant == nil then
            -- 植物消失，清理监听引用
            if spot._ignite_listener and spot._ignite_plant and spot._ignite_plant:IsValid() then
                spot._ignite_plant:RemoveEventCallback("onignite", spot._ignite_listener)
            end
            spot._ignite_listened = false
            spot._ignite_listener = nil
            spot._ignite_plant = nil
        end
    end
    
    -- 步骤2：扫描 farm_center 周围所有 FARMING_SOIL 地砖
    local search_dist = EXTERNAL_SEARCH_DIST()
    local tile_range = math.ceil(search_dist / TILE_SCALE)
    -- 用游戏 GetTileCenterPoint 拿真实 tile 中心（不能用 floor(x/4)*4+2，偏差2）
    local origin_x, _, origin_z = map:GetTileCenterPoint(scan_x, 0, scan_z)
    if not origin_x then origin_x, origin_z = scan_x, scan_z end
    
    local self_farm_keys = {}
    for _, spot in ipairs(self.farm_spots) do
        local key = string.format("%.1f_%.1f", spot.x, spot.z)
        self_farm_keys[key] = true
    end
    
    local old_spots = {}
    for _, spot in ipairs(self.all_spots) do
        local key = string.format("%.1f_%.1f", spot.x, spot.z)
        old_spots[key] = spot
    end
    
    -- 重建 all_spots
    self.all_spots = {}
    
    -- 获取网格参数
    local grid_spacing = SPACING
    local grid_size = GRID_SIZE
    local half = (grid_size - 1) / 2
    
    -- 统计信息
    local total_spots = 0
    local has_soil_count = 0
    local needs_till_count = 0
    
    -- 步骤3：扫描 farm_center 周围地砖，生成网格
    for dx = -tile_range, tile_range do
        for dz = -tile_range, tile_range do
            local tcx = origin_x + dx * TILE_SCALE
            local tcz = origin_z + dz * TILE_SCALE
            
            -- 检查距离是否在搜索范围内（以 farm_center 为圆心）
            local ddx = tcx - scan_x
            local ddz = tcz - scan_z
            if ddx * ddx + ddz * ddz <= search_dist * search_dist then
                -- 检查该地砖类型是否为 FARMING_SOIL
                local tile_type = map:GetTileAtPoint(tcx, 0, tcz)
                if tile_type == WORLD_TILES.FARMING_SOIL then
                    -- 生成 3x3 网格点
                    for row = -half, half do
                        for col = -half, half do
                            local gx = tcx + col * grid_spacing
                            local gz = tcz + row * grid_spacing
                            local key = string.format("%.1f_%.1f", gx, gz)
                            
                            if not self_farm_keys[key] then
                                -- 验证该网格点确实在 FARMING_SOIL 地砖上
                                local point_tile = map:GetTileAtPoint(gx, 0, gz)
                                if point_tile == WORLD_TILES.FARMING_SOIL then
                                    -- 检查位置可达性（水面过滤）
                                    if IsReachablePosition(gx, 0, gz) then
                                        -- 优先沿用旧 spot 的有效引用
                                        local old = old_spots[key]
                                        local spot = {
                                            x = gx,
                                            z = gz,
                                            soil = nil,
                                            plant = nil,
                                            needs_till = true,
                                            is_external = true,
                                            _ignite_listened = false,
                                        }
                                        
                                        -- 迁移旧引用
                                        -- 【修复死循环】不排除 NOBLOCK，breaksoil 状态的 soil 仍然有效
                                        if old and old.soil and old.soil:IsValid() and old.soil:HasTag("soil") then
                                            spot.soil = old.soil
                                            spot.needs_till = false
                                            spot._ignite_listened = old._ignite_listened
                                            
                                            -- 验证/搜索 plant 引用
                                            if old.plant and old.plant:IsValid() and old.plant:HasTag("farm_plant") then
                                                spot.plant = old.plant
                                            else
                                                local sx, _, sz = spot.soil.Transform:GetWorldPosition()
                                                local nearby_plants = _G.TheSim:FindEntities(sx, 0, sz, 0.8, {"farm_plant"})
                                                if #nearby_plants > 0 then
                                                    spot.plant = nearby_plants[1]
                                                    self:_ApplyPlantOverrides(spot.plant)
                                                end
                                            end
                                            has_soil_count = has_soil_count + 1
                                        else
                                            local nearby = _G.TheSim:FindEntities(gx, 0, gz, SPOT_RADIUS, {"soil"}, {"NOBLOCK"})
                                            if #nearby > 0 then
                                                FarmLog(string.format("RefreshAllSpots: 旧引用失效，找到新soil (%.1f,%.1f)", gx, gz))
                                                spot.soil = nearby[1]
                                                spot.needs_till = false
                                                -- 搜索该 soil 附近的植物
                                                local sx, _, sz = spot.soil.Transform:GetWorldPosition()
                                                local nearby_plants = _G.TheSim:FindEntities(sx, 0, sz, 0.8, {"farm_plant"})
                                                if #nearby_plants > 0 then
                                                    spot.plant = nearby_plants[1]
                                                    self:_ApplyPlantOverrides(spot.plant)
                                                end
                                                has_soil_count = has_soil_count + 1
                                            else
                                                local nearby_plants = _G.TheSim:FindEntities(gx, 0, gz, SPOT_RADIUS, {"farm_plant"})
                                                if #nearby_plants > 0 then
                                                    spot.plant = nearby_plants[1]
                                                    spot.needs_till = false  -- 有植物就不需要翻土
                                                    self:_ApplyPlantOverrides(spot.plant)
                                                    FarmLog(string.format("RefreshAllSpots: 无soil但找到plant %s (%.1f,%.1f)", spot.plant.prefab or "unknown", gx, gz))
                                                else
                                                    needs_till_count = needs_till_count + 1
                                                end
                                            end
                                        end
                                        
                                        table.insert(self.all_spots, spot)
                                        total_spots = total_spots + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- 步骤4：将自建农场 farm_spots 合并进 all_spots
    for _, spot in ipairs(self.farm_spots) do
        local key = string.format("%.1f_%.1f", spot.x, spot.z)
        -- 迁移引用（如果旧 all_spots 中有更新的引用）
        local old = old_spots[key]
        if old then
            if old.soil and old.soil:IsValid() and not spot.soil then
                spot.soil = old.soil
            end
            if old.plant and old.plant:IsValid() and not spot.plant then
                spot.plant = old.plant
            end
        end
        -- 添加到 all_spots（自建农场的 is_external = false 或 nil）
        table.insert(self.all_spots, spot)
        total_spots = total_spots + 1
        if spot.soil then has_soil_count = has_soil_count + 1
        else needs_till_count = needs_till_count + 1 end
    end
    
    -- 步骤5：为外部 spot 注册 onignite 事件
    for _, spot in ipairs(self.all_spots) do
        if spot.is_external and spot.plant and spot.plant:IsValid() and not spot._ignite_listened then
            -- 清理旧监听（如果存在）
            if spot._ignite_listener and spot._ignite_plant and spot._ignite_plant:IsValid() then
                spot._ignite_plant:RemoveEventCallback("onignite", spot._ignite_listener)
            end
            -- 创建新监听函数
            spot._ignite_listener = function(p, data)
                self:_OnCropIgnited(p, data)
            end
            spot._ignite_plant = spot.plant
            spot._ignite_listened = true
            inst:ListenForEvent("onignite", spot._ignite_listener, spot.plant)
        end
    end
    
    -- 输出汇总日志（受 DEBUG_FARMING 门控）
    if total_spots > #self.farm_spots then
        FarmLog(string.format("RefreshAllSpots: 总spots=%d (自建=%d, 外部=%d), 有soil=%d, 待翻土=%d",
            total_spots, #self.farm_spots, total_spots - #self.farm_spots, has_soil_count, needs_till_count))
        FarmLog("RefreshAllSpots: 外部农场搜索范围=" .. tostring(EXTERNAL_SEARCH_DIST()) .. "格")
    end

end

-- 兼容旧接口：RefreshSpots 现在调用 RefreshAllSpots
function FarmManager:RefreshSpots(force)
    self:RefreshAllSpots(force)
end

-- ════════════════════════════════════════════════════════════
-- 查询/执行方法已提取到子模块：
--   npc_farm_harvester.lua → 收获/清理/搬运
--   npc_farm_tender.lua    → 照料/除草/种植/翻土/工具/对话
-- ════════════════════════════════════════════════════════════




-- ────────────────────────────────────────────────────────────
-- 状态查询
-- ────────────────────────────────────────────────────────────

function FarmManager:IsNearFarm()
    if not self.farm_center then return true end
    local ix, _, iz = self.inst.Transform:GetWorldPosition()
    local dx = ix - self.farm_center.x
    local dz = iz - self.farm_center.z
    local max = NPC_TUNING.FARM_RETURN_DIST or 25
    return dx * dx + dz * dz < max * max
end

function FarmManager:GetFarmCenter()
    if self.farm_center then
        return Vector3(self.farm_center.x, 0, self.farm_center.z)
    end
    return nil
end

-- ────────────────────────────────────────────────────────────
-- 存档 / 加载
-- ────────────────────────────────────────────────────────────
function FarmManager:OnSave()
    local data = nil
    if self.farm_center then
        data = {
            cx = self.farm_center.x,
            cz = self.farm_center.z,
            state = self.state,
        }
        -- 【通用化】保存用户指定的中心点和搜索半径
        if self._user_specified_center then
            data.user_specified_center = true
        end
        if self._search_radius then
            data.search_radius = self._search_radius
        end
    end
    -- 【通用化】保存搬运/垃圾目标坐标点（容器实体无法序列化，只保存坐标）。
    -- 这两个点独立于 farm_center：停工会清空 farm_center，但存放点应保留，
    -- 因此即便没有 farm_center 也要单独存档。
    if self._storage_point or self._trash_drop_point then
        data = data or {}
        if self._storage_point then
            data.storage_point = self._storage_point
        end
        if self._trash_drop_point then
            data.trash_drop_point = self._trash_drop_point
        end
    end
    return data
end

function FarmManager:OnLoad(data)
    if data == nil then return end

    -- 搬运/垃圾存放点独立于 farm_center 恢复：即便停工清空了 farm_center 也要保留。
    if data.storage_point then
        self._storage_point = data.storage_point
    end
    if data.trash_drop_point then
        self._trash_drop_point = data.trash_drop_point
    end

    if data.cx and data.cz then
        self._loading = true  -- 标记加载中，阻止行为树访问未填充的 farm_spots
        self.farm_center = { x = data.cx, z = data.cz }
        -- 先恢复中心点类型/扫描半径，再重建坑位。
        -- 玩家指定中心点必须使用 _BuildAllSpots，和点击"在此处干活"时一致；
        -- 否则读档会退回 _BuildSpots 只建 4 个中心点，RefreshAllSpots 再把原地块当外部点补入，
        -- 造成 2 块地可能出现 10 个坑这类"缝隙补点"现象。
        if data.user_specified_center then
            self._user_specified_center = true
        end
        if data.search_radius then
            self._search_radius = data.search_radius
        end
        if self._user_specified_center and self._BuildAllSpots then
            self:_BuildAllSpots(self._search_radius)
            FarmLog(string.format("OnLoad: 玩家指定中心，使用 _BuildAllSpots 恢复坑位 spots=%d", #self.farm_spots))
        else
            self:_BuildSpots()
            FarmLog(string.format("OnLoad: 自动选址/旧数据，使用 _BuildSpots 恢复坑位 spots=%d", #self.farm_spots))
        end
        -- 犁地完成后加载 → 直接进入 farming 状态
        self.state = data.state or "farming"
        if self.state == "farming" or self.state == "plowing" then
            self.state = "farming"
            self.initialized = true
        end
        -- 延迟刷新实体引用 + 验证地面实际状态
        self._last_all_spots_scan = 0  -- 重置检查时间戳，确保首次 RefreshAllSpots 不被冷却拦截
        self.inst:DoTaskInTime(1, function()
            if self.inst:IsValid() then
                self:RefreshAllSpots(true)  -- 强制刷新，立即注册火焰监听
                -- 存档恢复后验证：仅在 NPC 靠近农场时验地（远处解除跟随时勿改成 searching）
                -- 验地：farming 状态但实际没翻土 → 通常是自动选址流程的中转状态，需走犁地
                -- 例外：_user_specified_center=true 表示玩家明确点了"在此处干活"，必须信任玩家选择，
                -- 不能让 NPC 自作主张回到 searching → 放犁地机（重现的下线再上线 bug）
                if self.state == "farming" and not self._user_specified_center
                   and not self:IsAreaPlowed() and self:IsNearFarm() then
                    local has_soil = false
                    for _, spot in ipairs(self.farm_spots) do
                        if spot.soil ~= nil and spot.soil:IsValid() then
                            has_soil = true
                            break
                        end
                    end
                    if not has_soil then
                        self.state = "searching"
                        self.initialized = false
                        FarmLog("OnLoad: 验地 has_soil=false → state=searching（自动选址流程）")
                    end
                elseif self._user_specified_center and NPC_TUNING.DEBUG_FARMING then
                    FarmLog(string.format(
                        "OnLoad: 玩家指定农场中心 (%.1f,%.1f)，跳过自动验地降级，state=%s",
                        self.farm_center.x, self.farm_center.z, tostring(self.state)))
                end
                self._loading = false  -- 加载完成，允许行为树访问
            end
        end)
    end
end

return FarmManager
