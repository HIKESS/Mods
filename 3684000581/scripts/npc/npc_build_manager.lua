-- scripts/npc/npc_build_manager.lua
-- NPC 通用建造管理模块（模块化，任何角色可复用）
-- 职责：位置选择、光照检测、结构管理、火坑维护
-- 通过 config 表接受角色专属参数
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")

local FIREPIT_OFFSET      = NPC_TUNING.BUILD_FIREPIT_OFFSET      or 5
local FIREPIT_MIN_SPACING = NPC_TUNING.BUILD_FIREPIT_MIN_SPACING or 2.5
local FIREPIT_FUEL_ADD    = NPC_TUNING.BUILD_FIREPIT_FUEL_ADD    or 90
local FIREPIT_FUEL_LOW    = NPC_TUNING.BUILD_FIREPIT_FUEL_LOW    or 0.25
local LIGHT_CHECK_RADIUS  = NPC_TUNING.BUILD_LIGHT_CHECK_RADIUS  or 15

-- 8 方向 + 4 对角（共 12 个候选偏移），按距离排序
local function _MakeOffsets(dist)
    local d  = dist
    local d2 = dist * 0.707  -- cos(45°)
    return {
        { x =  0, z =  d },   -- N
        { x =  0, z = -d },   -- S
        { x =  d, z =  0 },   -- E
        { x = -d, z =  0 },   -- W
        { x =  d2, z =  d2 }, -- NE
        { x = -d2, z =  d2 }, -- NW
        { x =  d2, z = -d2 }, -- SE
        { x = -d2, z = -d2 }, -- SW
        -- 更远的候选位
        { x =  0, z =  d * 1.4 },
        { x =  0, z = -d * 1.4 },
        { x =  d * 1.4, z =  0 },
        { x = -d * 1.4, z =  0 },
    }
end

-- 部署忽略的标签
local DEPLOY_IGNORE_TAGS = { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR", "WALKABLEPLATFORM" }

-- ── 保护 NPC 建造的火坑：只移除锤子，保留火焰功能 ──────────
local function ProtectFirepit(fp)
    if not fp or not fp:IsValid() then return end
    if fp.components.workable then fp:RemoveComponent("workable") end
    if fp.components.lootdropper then fp:RemoveComponent("lootdropper") end
    if fp.components.hauntable then fp:RemoveComponent("hauntable") end
    fp:AddTag("_npc_structure")
end

-- ════════════════════════════════════════════════════════════
--  BuildManager Class
-- ════════════════════════════════════════════════════════════

local BuildManager = Class(function(self, inst, config)
    self.inst = inst
    self.config = config or {}
    self.structures = {}  -- { firepit = <entity_ref>, ... } 按类型追踪
end)

-- ═══════════════════════════════════════════════════════════
--  位置选择
-- ═══════════════════════════════════════════════════════════

--- 验证某个位置是否可以放置建筑
function BuildManager:_IsValidBuildPoint(pt, min_spacing)
    local map = TheWorld and TheWorld.Map
    if not map then return false end

    -- 1. 地形可通行
    if not map:IsPassableAtPoint(pt.x, 0, pt.z) then return false end

    -- 2. 不在水上
    if map:IsOceanAtPoint(pt.x, 0, pt.z) then return false end

    -- 3. 无实体重叠
    local ents = TheSim:FindEntities(pt.x, 0, pt.z, min_spacing, nil, DEPLOY_IGNORE_TAGS)
    for _, e in ipairs(ents) do
        if e ~= self.inst
           and e:IsValid() and not e:IsInLimbo() and e.entity:IsVisible()
           and not e:HasTag("placer") then
            return false
        end
    end

    -- 4. 不在 farm_spots 3x3 网格范围内（避免挡住作物）
    local farmer = self.inst._farmer
    if farmer and farmer.farm_spots then
        for _, spot in ipairs(farmer.farm_spots) do
            local dx = pt.x - spot.x
            local dz = pt.z - spot.z
            if dx * dx + dz * dz < 2 * 2 then
                return false
            end
        end
    end

    return true
end

--- 在 near_pos 附近寻找可以放置建筑的位置
--- @param near_pos Vector3 参考中心点（通常是农场中心）
--- @param min_spacing number 最小间距
--- @return Vector3|nil 可用的位置或 nil
function BuildManager:FindBuildPosition(near_pos, min_spacing)
    if not near_pos then return nil end
    min_spacing = min_spacing or FIREPIT_MIN_SPACING

    local offsets = _MakeOffsets(FIREPIT_OFFSET)
    for _, off in ipairs(offsets) do
        local pt = Vector3(near_pos.x + off.x, 0, near_pos.z + off.z)
        if self:_IsValidBuildPoint(pt, min_spacing) then
            return pt
        end
    end

    return nil
end

-- ═══════════════════════════════════════════════════════════
--  光照检测
-- ═══════════════════════════════════════════════════════════

--- 检查指定位置是否有足够的光照
function BuildManager:HasNearbyLight(pos)
    if not pos then return true end  -- 无坐标时默认有光
    local light = TheSim:GetLightAtPoint(pos.x, 0, pos.z, 0.075)
    return light >= 0.075
end

-- ═══════════════════════════════════════════════════════════
--  建造结构
-- ═══════════════════════════════════════════════════════════

--- 在指定位置放置一个结构
--- @param prefab string 预制体名称
--- @param pos Vector3 放置位置
--- @return Entity|nil 生成的结构实体
function BuildManager:PlaceStructure(prefab, pos)
    if not prefab or not pos then return nil end

    local struct = SpawnPrefab(prefab)
    if not struct then
        return nil
    end

    struct.Transform:SetPosition(pos.x, 0, pos.z)
    struct:PushEvent("onbuilt")

    self.structures[prefab] = struct

    -- NPC 建造的火坑：不可被锤，保留点火功能
    if prefab == "firepit" then
        self._firepit_npc_built = true
        ProtectFirepit(struct)
    end

    -- 监听移除事件（清理引用）
    self.inst:ListenForEvent("onremove", function()
        if self.structures[prefab] == struct then
            self.structures[prefab] = nil
        end
    end, struct)

    return struct
end

-- ═══════════════════════════════════════════════════════════
--  火坑相关查询
-- ═══════════════════════════════════════════════════════════

--- 获取已建造的火坑实体
--- 优先返回已跟踪的引用，否则扫描农场附近是否有火坑（玩家放的）
--- @return Entity|nil
function BuildManager:GetFirepit()
    -- 1. 已跟踪的火坑仍有效 → 直接返回
    local fp = self.structures.firepit
    if fp and fp:IsValid() then
        return fp
    end
    self.structures.firepit = nil

    -- 2. 扫描农场附近是否有火坑（玩家/其他来源）
    local found = self:_FindNearbyFirepit()
    if found then
        self:_AdoptFirepit(found)
        return found
    end

    return nil
end

--- 扫描农场附近的火坑实体（不区分谁放的）
--- @return Entity|nil
function BuildManager:_FindNearbyFirepit()
    local farmer = self.inst._farmer
    local center = farmer and farmer:GetFarmCenter()
    if not center then return nil end

    local ents = TheSim:FindEntities(center.x, 0, center.z, LIGHT_CHECK_RADIUS)
    for _, e in ipairs(ents) do
        if e:IsValid() and e.prefab == "firepit" then
            return e
        end
    end
    return nil
end

--- 认领一个火坑（设为已跟踪 + 监听移除事件）
function BuildManager:_AdoptFirepit(fp)
    self.structures.firepit = fp
    self.inst:ListenForEvent("onremove", function()
        if self.structures.firepit == fp then
            self.structures.firepit = nil
        end
    end, fp)
end

--- 检查是否需要建造火坑
--- 条件：黄昏/夜晚 + 农场附近无任何火坑 + 无光照
function BuildManager:NeedsFirepit()
    if TheWorld.state.phase == "day" then return false end
    if self:GetFirepit() then return false end  -- 已自动扫描附近火坑

    local farmer = self.inst._farmer
    local farm_center = farmer and farmer:GetFarmCenter()
    if not farm_center then return false end

    return not self:HasNearbyLight(farm_center)
end

--- 检查火坑是否需要添加燃料
--- 条件：黄昏/夜晚 + 火坑存在 + 燃料低于阈值
function BuildManager:NeedsFuel()
    local fp = self:GetFirepit()
    if not fp or not fp.components.fueled then return false end
    if TheWorld.state.phase == "day" then return false end
    return fp.components.fueled:GetPercent() < FIREPIT_FUEL_LOW
end

--- 为火坑添加燃料（直接 DoDelta，不消耗物品）
--- 燃料足够后 fueled:onfuelchange 自动点燃 burnable
function BuildManager:FuelFirepit()
    local fp = self:GetFirepit()
    if fp and fp.components.fueled then
        fp.components.fueled:DoDelta(FIREPIT_FUEL_ADD)
    end
end

-- ═══════════════════════════════════════════════════════════
--  存档
-- ═══════════════════════════════════════════════════════════

function BuildManager:OnSave()
    local data = {}
    local fp = self:GetFirepit()
    if fp then
        local x, _, z = fp.Transform:GetWorldPosition()
        data.firepit_pos = { x = x, z = z }
        data.firepit_npc_built = self._firepit_npc_built or false
    end
    return next(data) and data or nil
end

function BuildManager:OnLoad(data)
    if not data then return end

    self._firepit_npc_built = data.firepit_npc_built

    if data.firepit_pos then
        -- 延迟扫描附近实体，恢复火坑引用
        self.inst:DoTaskInTime(2, function()
            if not self.inst:IsValid() then return end
            local pos = data.firepit_pos
            local ents = TheSim:FindEntities(pos.x, 0, pos.z, 2)
            for _, e in ipairs(ents) do
                if e:IsValid() and e.prefab == "firepit" then
                    self.structures.firepit = e
                    -- 重新监听移除事件
                    self.inst:ListenForEvent("onremove", function()
                        if self.structures.firepit == e then
                            self.structures.firepit = nil
                        end
                    end, e)
                    -- 重新应用保护（NPC 建造的火坑）
                    if self._firepit_npc_built then
                        ProtectFirepit(e)
                    end
                    break
                end
            end
        end)
    end
end

return BuildManager
