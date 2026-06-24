-- scripts/npc/npc_farm_harvester.lua
-- FarmManager 子模块：收获/清理/搬运相关方法
-- 通过 AttachTo(FarmManager) 注入方法到主类
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")

local Harvester = {}

-- ════════════════════════════════════════════════════════════
--  本模块所需常量（与主模块一致）
-- ════════════════════════════════════════════════════════════
local SPOT_RADIUS    = NPC_TUNING.FARM_SPOT_RADIUS    or 0.8
local BLOCKER_RADIUS = NPC_TUNING.FARM_BLOCKER_RADIUS or 2
local ENTITY_RADIUS  = NPC_TUNING.FARM_WEED_CHECK_RANGE or 6

local function FarmLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        print("[种植调试]", ...)
    end
end

-- 检查位置是否可达（NPC 可以走到）
local function IsReachablePosition(x, y, z)
    return TheWorld.Map:IsPassableAtPoint(x, 0, z)
end

local function _IsInTrashDropExclusionZone(self, e, ex, ez)
    if not self or not e then
        return false
    end
    if not self.GetTrashDropPoint then
        return false
    end
    local tp = self:GetTrashDropPoint()
    if not (tp and tp.x and tp.z) then
        return false
    end
    local radius = NPC_TUNING.WORMWOOD_TRASH_DEPOSIT_RADIUS or 6
    if radius <= 0 then
        return false
    end
    local dx = ex - tp.x
    local dz = ez - tp.z
    return (dx * dx + dz * dz) <= (radius * radius)
end


local FARM_SOIL_TOLERANCE = NPC_TUNING.FARM_CLEANUP_SOIL_TOLERANCE or 2

local _FARM_SOIL_OFFSETS = {
    {  FARM_SOIL_TOLERANCE, 0 }, { -FARM_SOIL_TOLERANCE, 0 },
    { 0,  FARM_SOIL_TOLERANCE }, { 0, -FARM_SOIL_TOLERANCE },
    {  FARM_SOIL_TOLERANCE,  FARM_SOIL_TOLERANCE }, {  FARM_SOIL_TOLERANCE, -FARM_SOIL_TOLERANCE },
    { -FARM_SOIL_TOLERANCE,  FARM_SOIL_TOLERANCE }, { -FARM_SOIL_TOLERANCE, -FARM_SOIL_TOLERANCE },
}

local function _IsFarmSoilTileAt(x, z)
    local map = TheWorld and TheWorld.Map
    if map == nil then return false end
    if map:GetTileAtPoint(x, 0, z) == WORLD_TILES.FARMING_SOIL then
        return true
    end
    if FARM_SOIL_TOLERANCE and FARM_SOIL_TOLERANCE > 0 then
        for _, off in ipairs(_FARM_SOIL_OFFSETS) do
            if map:GetTileAtPoint(x + off[1], 0, z + off[2]) == WORLD_TILES.FARMING_SOIL then
                return true
            end
        end
    end
    return false
end

-- 瓦器人 / 薇机人 判定：storagerobot 标签 或 winona_storage_robot 预制
local function _IsStorageRobot(ent)
    return ent ~= nil
        and (ent:HasTag("storagerobot") or ent.prefab == "winona_storage_robot")
end

local function _IsCleanupGroundItem(ent)
    if ent == nil or not ent:IsValid() then return false end
    if ent:HasTag("NOCLICK") or _IsStorageRobot(ent) then return false end
    if ent.components == nil or ent.components.inventoryitem == nil then return false end
    if ent.components.inventoryitem.canbepickedup == false then return false end
    local owner = ent.components.inventoryitem.owner
    if owner ~= nil and owner.IsValid ~= nil and owner:IsValid() and _IsStorageRobot(owner) then return false end
    if ent.highlightparent ~= nil and ent.highlightparent.IsValid ~= nil
       and ent.highlightparent:IsValid() and _IsStorageRobot(ent.highlightparent) then
        return false
    end
    return true
end

local function _IsUsableFarmStorageContainer(ent)
    if ent == nil or not ent:IsValid() then return false end
    if _IsStorageRobot(ent) then return false end
    if ent.prefab == "gelblob_storage" then return false end
    if ent.components == nil or ent.components.container == nil then return false end
    if ent.components.incinerator ~= nil then return false end
    return true
end

-- ════════════════════════════════════════════════════════════
--  AttachTo: 将收获/清理方法注入 FarmManager
-- ════════════════════════════════════════════════════════════

function Harvester.AttachTo(FarmManager)

    -- 获取一个可采摘的成熟植物
    function FarmManager:GetHarvestablePlant()
        if self._loading then return nil end
        if not self.initialized then return nil end
        self:RefreshSpots()
        -- 优先采摘巨大植物
        for _, spot in ipairs(self.all_spots) do
            local p = spot.plant
            if p ~= nil and p:IsValid()
               and p.is_oversized
               and p.components.pickable ~= nil
               and p.components.pickable:CanBePicked() then
                return p, spot
            end
        end

        -- 再采摘普通成熟作物
        for _, spot in ipairs(self.all_spots) do
            local p = spot.plant
            if p ~= nil and p:IsValid()
               and p.components.pickable ~= nil
               and p.components.pickable:CanBePicked() then
                return p, spot
            end
        end

        -- 兜底：世界实体扫描
        if self.farm_center then
            local cx, cz = self.farm_center.x, self.farm_center.z
            local range = NPC_TUNING.FARM_WORK_RADIUS or 40
            local plants = _G.TheSim:FindEntities(cx, 0, cz, range, {"farm_plant"})
            local fallback = nil
            for _, p in ipairs(plants) do
                if p and p:IsValid()
                   and p.components.pickable ~= nil
                   and p.components.pickable:CanBePicked() then
                    if p.is_oversized then
                        return p, nil
                    end
                    if fallback == nil then
                        fallback = p
                    end
                end
            end
            if fallback ~= nil then
                return fallback, nil
            end
        end

        return nil
    end

    -- 检测附近的巨大作物（需要敲碎）
    function FarmManager:GetOversizedCrop()
        if self._loading then return nil end
        if not self.farm_center then return nil end

        local cx, cz = self.farm_center.x, self.farm_center.z
        local search_radius = NPC_TUNING.FARM_WORK_RADIUS or 40
        local ents = _G.TheSim:FindEntities(cx, 0, cz, search_radius, {"oversized_veggie"})

        local count = ents and #ents or 0
        if count == 0 then return nil end

        FarmLog(string.format("GetOversizedCrop: 找到 %d 个巨大作物候选", count))
        
        for i, ent in ipairs(ents) do
            local is_valid = ent:IsValid()
            local is_in_limbo = ent:IsInLimbo()
            
            FarmLog("GetOversizedCrop: 候选", i, "prefab=", ent.prefab, 
                    "IsValid=", tostring(is_valid), "IsInLimbo=", tostring(is_in_limbo))
            
            if is_valid and not is_in_limbo then
                local ex, _, ez = ent.Transform:GetWorldPosition()
                local dist_to_center = math.sqrt((ex - cx)^2 + (ez - cz)^2)
                local passable = TheWorld.Map:IsPassableAtPoint(ex, 0, ez)
                local has_workable = ent.components.workable ~= nil
                local can_work = has_workable and ent.components.workable:CanBeWorked()
                local work_left = has_workable and ent.components.workable.workleft or 0
                
                FarmLog("GetOversizedCrop: 候选", i, "=", ent.prefab, 
                        "位置=(", string.format("%.1f", ex), ",", string.format("%.1f", ez), ")",
                        "距中心=", string.format("%.1f", dist_to_center), "格",
                        "可通行=", tostring(passable), 
                        "有workable=", tostring(has_workable),
                        "可工作=", tostring(can_work),
                        "剩余工作量=", work_left)
                
                if passable and can_work then
                    if ent._npc_dropped_time then
                        ent._npc_dropped_time = nil
                        FarmLog("GetOversizedCrop: 清除巨大作物的冷却标记", ent.prefab)
                    end
                    FarmLog("GetOversizedCrop: 返回目标=", ent.prefab)
                    return ent
                elseif not passable then
                    FarmLog("GetOversizedCrop: 候选", i, "被跳过：位置不可通行（可能在水面或深渊）")
                elseif not has_workable then
                    FarmLog("GetOversizedCrop: 候选", i, "被跳过：没有 workable 组件")
                elseif not can_work then
                    FarmLog("GetOversizedCrop: 候选", i, "被跳过：CanBeWorked() 返回 false（剩余工作量=", work_left, ")")
                end
            elseif not is_valid then
                FarmLog("GetOversizedCrop: 候选", i, "被跳过：实体无效（IsValid=false）")
            elseif is_in_limbo then
                FarmLog("GetOversizedCrop: 候选", i, "被跳过：在 Limbo 中（正被其他实体持有）")
            end
        end
        
        FarmLog("GetOversizedCrop: 所有候选都不可工作或不可达")
        return nil
    end

    -- 获取一个真正死亡的植物（需要 DIG 清理）
    function FarmManager:GetDeadPlant()
        if self._loading then return nil end
        if not self.initialized then return nil end
        self:RefreshSpots()
        
        local function _CheckDeadPlant(spot)
            local p = spot.plant
            if p and p:IsValid() then
                if not p:HasTag("planted_seed") then
                    local can_pick = p.components.pickable and p.components.pickable:CanBePicked()
                    if not can_pick then
                        local growable = p.components.growable
                        local is_growing = growable and growable:IsGrowing()
                        if not is_growing then
                            local is_withered = p:HasTag("withered")
                            local stage = growable and growable.stage or 0
                            local num_stages = growable and growable.numstages or 6
                            local at_final = stage >= num_stages
                            if is_withered or at_final then
                                return p, spot
                            end
                        end
                    end
                end
            end
            return nil
        end
        
        for _, spot in ipairs(self.all_spots) do
            local p, s = _CheckDeadPlant(spot)
            if p then return p, s end
        end
        return nil
    end

    -- 获取地上掉落的犁地机物品
    function FarmManager:GetDroppedPlowItem()
        if not self.farm_center then return nil end
        if self:GetPlowItem() then return nil end
        local ents = _G.TheSim:FindEntities(self.farm_center.x, 0, self.farm_center.z, ENTITY_RADIUS)
        for _, e in ipairs(ents) do
            if e:IsValid() and not e:IsInLimbo()
               and e.prefab == "farm_plow_item"
               and e.components.inventoryitem
               and e.components.inventoryitem.canbepickedup then
                return e
            end
        end
        return nil
    end

    -- 检测农场范围内的地面物品
    function FarmManager:GetGroundItem()
        if not self.farm_center then return nil end
        
        local range = NPC_TUNING.FARM_WEED_CHECK_RANGE or 10
        
        local function _SearchItemAtCenter(cx, cz, heavy_only)
            local ents = _G.TheSim:FindEntities(cx, 0, cz, range, { "_inventoryitem" }, { "INLIMBO", "NOCLICK" })
            for _, e in ipairs(ents) do
                if _IsCleanupGroundItem(e) then
                    local ex, ey, ez = e.Transform:GetWorldPosition()
                    if IsReachablePosition(ex, ey, ez) and _IsFarmSoilTileAt(ex, ez) then
                        if e:HasTag("oversized_veggie") then
                            FarmLog("GetGroundItem: 跳过巨大作物 " .. tostring(e.prefab) .. "（由1.6阶段处理）")
                        else
                            local dominated = e:HasTag("soil") or e:HasTag("farm_plant")
                                or e:HasTag("weed") or e:HasTag("farm_debris")
                                or e.prefab == "farm_plow_item"
                                or e.prefab == "balloon"
                                or e.prefab == "phonograph"
                                or e:HasTag("backpack")
                            local is_npc_tool = e:HasTag("_npc_tool")
                            local is_creature = e.components.locomotor ~= nil
                            if not dominated and not is_npc_tool and not is_creature then
                                if _IsInTrashDropExclusionZone(self, e, ex, ez) then
                                    FarmLog("GetGroundItem: 跳过垃圾存放点范围内物品", e.prefab)
                                else
                                local drop_cooldown = NPC_TUNING.NPC_DROP_COOLDOWN or 60
                                if e._npc_dropped_time and (GetTime() - e._npc_dropped_time) < drop_cooldown then
                                    FarmLog("GetGroundItem: 跳过最近丢弃的物品", e.prefab, 
                                            "冷却剩余:", math.ceil(drop_cooldown - (GetTime() - e._npc_dropped_time)), "秒")
                                else
                                    local is_heavy = e:HasTag("heavy")
                                    if heavy_only and not is_heavy then
                                        -- 继续下一个
                                    else
                                        local dist_to_center = math.sqrt((ex - self.farm_center.x)^2 + (ez - self.farm_center.z)^2)
                                        FarmLog("GetGroundItem: 发现物品 " .. tostring(e.prefab) .. 
                                                ", 距中心=" .. string.format("%.1f", dist_to_center) ..
                                                "格, 检测范围=" .. range)
                                        return e, is_heavy
                                    end
                                end
                                end
                            end
                        end
                    elseif NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
                        FarmLog("GetGroundItem: 跳过非农田地皮物品 " .. tostring(e.prefab))
                    end
                end
            end
            return nil
        end
        
        local item, is_heavy = _SearchItemAtCenter(self.farm_center.x, self.farm_center.z, false)
        if item then
            FarmLog("GetGroundItem: 在农场中心附近发现物品", item.prefab)
            return item, is_heavy
        end
        return nil
    end

    -- 获取指定中心点附近的冰箱和箱子列表（默认农场中心）
    function FarmManager:GetNearbyContainers(center_point)
        if not self.farm_center and not center_point then return {}, {} end
        local radius = NPC_TUNING.FARM_CONTAINER_SCAN_RADIUS or 30
        local cp = center_point or self.farm_center
        local cx, cz  = cp.x, cp.z
        local iceboxes, chests = {}, {}

        local fridge_ents = _G.TheSim:FindEntities(cx, 0, cz, radius, {"fridge"}, {"INLIMBO"})
        for _, e in ipairs(fridge_ents) do
            if _IsUsableFarmStorageContainer(e)
               and not e:HasTag("backpack") then
                table.insert(iceboxes, e)
            end
        end

        local struct_ents = _G.TheSim:FindEntities(cx, 0, cz, radius, {"structure"}, {"INLIMBO", "fridge", "lamp", "stewer"})
        for _, e in ipairs(struct_ents) do
            if _IsUsableFarmStorageContainer(e) then
                table.insert(chests, e)
            end
        end

        FarmLog(string.format("GetNearbyContainers: 冰箱%d个 箱子%d个 (半径=%.0f格)",
            #iceboxes, #chests, radius))
        return iceboxes, chests
    end

    -- 找安全丢弃点
    function FarmManager:FindDropPoint(dist_min, dist_max)
        if not self.farm_center then return nil end

        local weed_range = NPC_TUNING.FARM_WEED_CHECK_RANGE or 6
        local min_safe = weed_range + 5
        dist_min = math.max(dist_min, min_safe)
        dist_max = math.max(dist_max, min_safe)

        FarmLog("FindDropPoint: 入口参数 dist_min=" .. dist_min .. ", dist_max=" .. dist_max .. ", min_safe=" .. min_safe)

        local cx, cz = self.farm_center.x, self.farm_center.z
        local map = TheWorld.Map

        local function ScanRange(dmin, dmax, num_dirs, step)
            num_dirs = num_dirs or 25
            step     = step or -0.5
            for i = 0, num_dirs - 1 do
                local angle = i * (2 * math.pi / num_dirs)
                for d = dmax, dmin, step do
                    local tx = cx + d * math.cos(angle)
                    local tz = cz + d * math.sin(angle)
                    if map:IsPassableAtPoint(tx, 0, tz)
                       and not map:IsOceanAtPoint(tx, 0, tz) then
                        local blockers = _G.TheSim:FindEntities(tx, 0, tz, BLOCKER_RADIUS, { "blocker" })
                        if #blockers == 0 then
                            return Vector3(tx, 0, tz)
                        end
                    end
                end
            end
            return nil
        end

        local pt = ScanRange(dist_min, dist_max, 25, -0.5)
        if pt then
            local dist_to_center = math.sqrt((pt.x - cx)^2 + (pt.z - cz)^2)
            FarmLog("FindDropPoint: 成功(阶段1), 距中心=" .. string.format("%.1f", dist_to_center) .. "格, 检测范围=" .. weed_range)
            return pt
        end

        local expand_max = math.max(dist_max + 5, 10)
        pt = ScanRange(dist_max + 0.5, expand_max, 36, -0.5)
        if pt then
            local dist_to_center = math.sqrt((pt.x - cx)^2 + (pt.z - cz)^2)
            FarmLog("FindDropPoint: 成功(阶段2扩展), 距中心=" .. string.format("%.1f", dist_to_center) .. "格, 检测范围=" .. weed_range)
            return pt
        end

        local fx, _, fz = self.inst.Transform:GetWorldPosition()
        local ddx, ddz = fx - cx, fz - cz
        local len = math.sqrt(ddx * ddx + ddz * ddz)
        if len < 0.01 then ddx, ddz = 1, 0 else ddx, ddz = ddx / len, ddz / len end
        local fallback_pt = Vector3(cx + ddx * expand_max, 0, cz + ddz * expand_max)
        local dist_to_center = math.sqrt((fallback_pt.x - cx)^2 + (fallback_pt.z - cz)^2)
        FarmLog("FindDropPoint: 回退(阶段3), 距中心=" .. string.format("%.1f", dist_to_center) .. "格, 检测范围=" .. weed_range)
        return fallback_pt
    end

    -- 检查 NPC 是否正在背负重物
    function FarmManager:IsCarryingCleanupItem()
        local inv = self.inst.components.inventory
        if not inv then return false end
        local body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
        return body ~= nil and body:HasTag("heavy")
    end

end -- Harvester.AttachTo

return Harvester
