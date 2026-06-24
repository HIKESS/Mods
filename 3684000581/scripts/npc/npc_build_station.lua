-- scripts/npc/npc_build_station.lua
-- NPC 工作站建造管理器
-- 提供通用的建造序列管理、位置计算、结构生成功能，供多角色/行为共享
-- ────────────────────────────────────────────────────────────

local StructureUtil = require("npc/npc_structure_util")

-- 共享工具函数快捷引用
local ProtectStructure = StructureUtil.ProtectStructure
local IsValidBuildPos  = StructureUtil.IsValidBuildPos

-- ════════════════════════════════════════════════════════════
--  BuildStationManager 类
-- ════════════════════════════════════════════════════════════

local BuildStationManager = Class(function(self, inst, config)
    self.inst = inst
    -- config 参数
    self._build_sequence = config.build_sequence       -- 建造序列表 [{key, prefab, r, f}, ...]
    self._struct_spacing = config.struct_spacing or 2  -- 结构间距（默认 2）
    self._build_dist = config.build_dist or 1.5        -- 建造距离阈值
    self._build_dist_sq = self._build_dist * self._build_dist
    self._station_ref = config.station_ref             -- 工作站容器引用（如 inst._chef_station）
    
    -- 可选回调
    self._on_structure_spawned = config.on_structure_spawned  -- function(ent, entry, pos)
    self._on_all_complete = config.on_all_complete            -- function()
    
    -- 内部缓存：从 build_sequence 提取的 key 列表
    self._structure_keys = {}
    for _, entry in ipairs(self._build_sequence) do
        table.insert(self._structure_keys, entry.key)
    end
end)

-- ════════════════════════════════════════════════════════════
--  位置计算
-- ════════════════════════════════════════════════════════════

--- 计算所有结构的建造位置（三层回退机制）
--- @param farm_center Vector3 农场中心（或参考中心点）
--- @param target_pos Vector3 目标方向参考点（工作站中心位置）
--- @return table {key → Vector3} 每个结构的位置
function BuildStationManager:CalcPositions(farm_center, target_pos)
    -- 计算 farm_center → target_pos 方向的单位向量
    local dx = target_pos.x - farm_center.x
    local dz = target_pos.z - farm_center.z
    local len = math.sqrt(dx * dx + dz * dz)
    if len < 0.1 then dx, dz = 1, 0 else dx, dz = dx / len, dz / len end
    
    -- forward 向量（从 farm_center 指向 target_pos）
    local fx, fz = dx, dz
    -- right 向量（forward 顺时针旋转 90°）
    local rx, rz = -dz, dx
    local S = self._struct_spacing
    local cx, cz = target_pos.x, target_pos.z
    
    -- 根据 build_sequence 的 r/f 偏移计算初始位置
    local positions = {}
    for _, entry in ipairs(self._build_sequence) do
        local off_r = entry.r * S
        local off_f = entry.f * S
        positions[entry.key] = Vector3(cx + rx * off_r + fx * off_f, 0, cz + rz * off_r + fz * off_f)
    end
    
    -- 防碰撞最小间距的平方
    local MIN_GAP_SQ = (S * 0.8) * (S * 0.8)
    
    -- 检查某位置是否与已确认位置过近
    local function TooCloseToConfirmed(pos, confirmed)
        for _, cpos in pairs(confirmed) do
            local ddx = pos.x - cpos.x
            local ddz = pos.z - cpos.z
            if ddx * ddx + ddz * ddz < MIN_GAP_SQ then return true end
        end
        return false
    end
    
    -- 逐个验证位置，带三层回退机制
    local confirmed = {}
    for _, entry in ipairs(self._build_sequence) do
        local pos = positions[entry.key]
        local ok = IsValidBuildPos(pos) and not TooCloseToConfirmed(pos, confirmed)
        
        if not ok then
            local found = false
            -- 第一层回退：8 方向偏移（间隔 45°）
            for a = 0, 7 do
                local angle = a * math.pi / 4
                local try = Vector3(pos.x + S * math.cos(angle), 0, pos.z + S * math.sin(angle))
                if IsValidBuildPos(try) and not TooCloseToConfirmed(try, confirmed) then
                    positions[entry.key] = try
                    found = true
                    break
                end
            end
            -- 第二层回退：12 方向偏移（间隔 30°，距离 1.5 倍）
            if not found then
                for a = 0, 11 do
                    local angle = a * math.pi / 6
                    local try = Vector3(pos.x + S * 1.5 * math.cos(angle), 0, pos.z + S * 1.5 * math.sin(angle))
                    if IsValidBuildPos(try) and not TooCloseToConfirmed(try, confirmed) then
                        positions[entry.key] = try
                        found = true
                        break
                    end
                end
            end
            -- 第三层：所有回退位置均失败 → 标记无效，跳过此建筑
            if not found then
                positions[entry.key] = nil
            end
        end

        -- 只有有效位置才加入已确认列表（防止后续结构也被迫偏移）
        if positions[entry.key] then
            confirmed[entry.key] = positions[entry.key]
        end
    end

    local valid_count = 0
    local total_count = #self._build_sequence
    for _, entry in ipairs(self._build_sequence) do
        if positions[entry.key] then
            valid_count = valid_count + 1
        end
    end
    self._valid_position_count = valid_count
    if valid_count < total_count then
        print(string.format("[BuildStation] 位置计算: 有效=%d/%d, 无法定位的结构将被跳过", valid_count, total_count))
        if valid_count < math.ceil(total_count / 2) then
            print("[BuildStation] 警告: 有效位置数不足一半，请检查建造环境")
        end
    end

    if self._station_ref then
        self._station_ref.positions = positions
    end

    return positions
end

--- 获取已计算的位置表
--- @return table|nil {key → Vector3}
function BuildStationManager:GetPositions()
    if self._station_ref then
        return self._station_ref.positions
    end
    return nil
end

--- 获取有效位置数量
--- @return number 有效位置数（CalcPositions 后可用）
function BuildStationManager:GetValidPositionCount()
    return self._valid_position_count or 0
end

-- ════════════════════════════════════════════════════════════
--  建造条目管理
-- ════════════════════════════════════════════════════════════

--- 获取下一个需要建造的条目
--- @return table|nil  {key, prefab, r, f} 或 nil（全部建成）
function BuildStationManager:GetNextBuildEntry()
    local station = self._station_ref
    if not station or not station.positions then return nil end

    for _, entry in ipairs(self._build_sequence) do
        -- 跳过无有效位置的结构（CalcPositions 回退失败时标记为 nil）
        local pos = station.positions[entry.key]
        if pos and (not station[entry.key] or not station[entry.key]:IsValid()) then
            return entry
        end
    end
    return nil
end

--- 检查工作站是否全部建成
--- 注意：当有效位置为 0 时也返回 true（无可建位置等同于"完成"）
--- 调用者应使用 GetValidPositionCount() 区分"全部建成"和"无可用位置"
--- @return boolean true=所有有效位置的结构已建成（或无有效位置）
function BuildStationManager:IsComplete()
    local station = self._station_ref
    if not station or not station.positions then return false end

    for _, entry in ipairs(self._build_sequence) do
        local pos = station.positions[entry.key]
        if pos and (not station[entry.key] or not station[entry.key]:IsValid()) then
            return false
        end
    end
    return true
end

-- ════════════════════════════════════════════════════════════
--  结构生成
-- ════════════════════════════════════════════════════════════

--- 在指定位置生成结构实体
--- @param entry table 建造条目 {key, prefab, r, f}
--- @param pos Vector3 建造位置
--- @return entity|nil 生成的实体
function BuildStationManager:SpawnStructure(entry, pos)
    local inst = self.inst
    local station = self._station_ref
    if not station then return nil end

    -- 生成前校验：位置是否仍然可用
    if not pos or not IsValidBuildPos(pos) then
        return nil
    end

    local ent = SpawnPrefab(entry.prefab)
    if not ent then return nil end

    ent.Transform:SetPosition(pos.x, 0, pos.z)
    ent:PushEvent("onbuilt")

    -- 不再保护结构：允许玩家锤/烧/拆/作祟
    -- （结构被毁后 NPC 会自动在原位置重建）

    station[entry.key] = ent

    inst:ListenForEvent("onremove", function()
        if station[entry.key] == ent then
            station[entry.key] = nil
            -- 结构被毁后不再重建
        end
    end, ent)
    
    if self._on_structure_spawned then
        self._on_structure_spawned(ent, entry, pos)
    end
    
    if self:IsComplete() and self._on_all_complete then
        self._on_all_complete()
    end
    
    return ent
end

-- ════════════════════════════════════════════════════════════
--  工具方法
-- ════════════════════════════════════════════════════════════

--- 获取建造距离阈值
function BuildStationManager:GetBuildDist()
    return self._build_dist
end

--- 获取建造距离阈值的平方
function BuildStationManager:GetBuildDistSq()
    return self._build_dist_sq
end

--- 获取结构键列表
function BuildStationManager:GetStructureKeys()
    return self._structure_keys
end

--- 获取结构间距
function BuildStationManager:GetStructSpacing()
    return self._struct_spacing
end

--- 获取建造序列
function BuildStationManager:GetBuildSequence()
    return self._build_sequence
end

-- ════════════════════════════════════════════════════════════
--  默认建造序列
-- ════════════════════════════════════════════════════════════

--- 获取默认的厨师工作站建造序列
--- 布局示意（俯视图，forward 向上）：
---   [I1]    [C]    [C1][C2]
--- @return table 建造序列表
function BuildStationManager.GetDefaultChefSequence()
    return {
        { key = "cookpot",   prefab = "portablecookpot", r =  0,  f =  0 },
        -- 冰箱 1 个（左侧）
        { key = "icebox_1",  prefab = "icebox",          r = -3,  f =  0 },
        -- 箱子 2 个（右侧）
        { key = "chest_1",   prefab = "treasurechest",   r =  2,  f =  0 },
        { key = "chest_2",   prefab = "treasurechest",   r =  3,  f =  0 },
    }
end

--- 获取默认厨师工作站的冰箱 key 列表
function BuildStationManager.GetDefaultChefIceboxKeys()
    return { "icebox_1" }
end

--- 获取默认厨师工作站的箱子 key 列表
function BuildStationManager.GetDefaultChefChestKeys()
    return { "chest_1", "chest_2" }
end

return BuildStationManager
