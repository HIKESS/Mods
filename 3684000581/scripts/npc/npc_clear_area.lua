-- scripts/npc/npc_clear_area.lua
-- 清障管理器：提供通用的障碍物/地面物品搜索功能
-- 从 ChefFarmBehavior 提取，供多种 NPC 行为复用
-- ────────────────────────────────────────────────────────────
-- 支持两种搜索模式：
--   1. 中心点搜索（单点圆形范围）— 适用于工作站周边巡逻
--   2. 位置列表搜索（多点周围）— 适用于需要清理多个建造位置的场景
-- ────────────────────────────────────────────────────────────

local StructureUtil = require("npc/npc_structure_util")

-- ════════════════════════════════════════════════════════════
--  ClearAreaManager 类
-- ════════════════════════════════════════════════════════════

--- 清障管理器
--- @param inst       entity   NPC 实体
--- @param config     table    配置参数：
---   - radius          number   清障搜索半径（默认 10）
---   - approach_dist   number   接近距离（默认 2.5）
---   - get_center_fn   function(inst) → Vector3|nil  获取搜索中心点
---   - get_positions_fn function(inst) → {key→Vector3}|nil  获取位置列表
---   - item_filter_fn  function(entity, inst) → boolean  物品过滤（返回 true 跳过）
local ClearAreaManager = Class(function(self, inst, config)
    self.inst = inst
    config = config or {}
    
    -- 搜索半径
    self._radius = config.radius or 10
    
    -- 接近距离
    self._approach_dist = config.approach_dist or 2.5
    
    -- 搜索模式1：基于中心点（单点搜索）
    -- function(inst) → Vector3 | nil
    self._get_center_fn = config.get_center_fn
    
    -- 搜索模式2：基于位置列表（多点搜索，如建造位置）
    -- function(inst) → {key→Vector3} | nil
    self._get_positions_fn = config.get_positions_fn
    
    -- 可选：地面物品过滤函数
    -- function(entity, inst) → true 表示跳过该物品
    self._item_filter_fn = config.item_filter_fn
end)

-- ════════════════════════════════════════════════════════════
--  公共 API
-- ════════════════════════════════════════════════════════════

--- 搜索下一个需要清除的障碍物或地面物品
--- @return entity|nil, string|nil  目标实体, 动作类型 ("chop"/"dig"/"pickup")
function ClearAreaManager:FindNextObstacle()
    local inst = self.inst
    
    -- 模式1：使用位置列表搜索（优先）
    if self._get_positions_fn then
        local positions = self._get_positions_fn(inst)
        if positions then
            -- 先搜索障碍物（可砍/可挖）
            local entity, action = StructureUtil.FindObstacleNearPositions(
                positions, inst, self._radius)
            if entity then
                return entity, action
            end
            -- 再搜索地面物品
            local item = StructureUtil.FindGroundItemNearPositions(
                positions, inst, self._radius)
            if item then
                return item, "pickup"
            end
        end
    end
    
    -- 模式2：使用中心点搜索
    if self._get_center_fn then
        local center = self._get_center_fn(inst)
        if center then
            -- 先搜索障碍物（可砍/可挖）
            local entity, action = StructureUtil.FindObstacleInRadius(
                center, inst, self._radius)
            if entity then
                return entity, action
            end
            -- 再搜索地面物品（带可选过滤函数）
            local item = StructureUtil.FindGroundItemInRadius(
                center, inst, self._radius, self._item_filter_fn)
            if item then
                return item, "pickup"
            end
        end
    end
    
    return nil, nil
end

--- 获取清障接近距离
--- @return number
function ClearAreaManager:GetApproachDist()
    return self._approach_dist
end

--- 获取清障接近距离的平方（用于距离比较，避免开方运算）
--- @return number
function ClearAreaManager:GetApproachDistSq()
    return self._approach_dist * self._approach_dist
end

--- 更新搜索半径
--- @param radius number 新的搜索半径
function ClearAreaManager:SetRadius(radius)
    self._radius = radius or self._radius
end

--- 更新接近距离
--- @param dist number 新的接近距离
function ClearAreaManager:SetApproachDist(dist)
    self._approach_dist = dist or self._approach_dist
end

--- 更新物品过滤函数
--- @param filter_fn function(entity, inst) → boolean
function ClearAreaManager:SetItemFilter(filter_fn)
    self._item_filter_fn = filter_fn
end

return ClearAreaManager
