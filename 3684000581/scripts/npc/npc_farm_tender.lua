-- scripts/npc/npc_farm_tender.lua
-- FarmManager 子模块：照料/除草/种植/翻土/工具管理/对话相关方法
-- 通过 AttachTo(FarmManager) 注入方法到主类
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")

local Tender = {}

-- ════════════════════════════════════════════════════════════
--  本模块所需常量（与主模块一致）
-- ════════════════════════════════════════════════════════════
local SPACING    = NPC_TUNING.FARM_GRID_SPACING    or 1.3
local GRID_SIZE  = NPC_TUNING.FARM_GRID_SIZE       or 3
local SPOT_RADIUS = NPC_TUNING.FARM_SPOT_RADIUS    or 0.8
local TILE_SCALE = 4

local function FarmLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        print("[种植调试]", ...)
    end
end

-- 检查位置是否可达
local function IsReachablePosition(x, y, z)
    return TheWorld.Map:IsPassableAtPoint(x, 0, z)
end

-- ════════════════════════════════════════════════════════════
--  AttachTo: 将照料/除草/种植方法注入 FarmManager
-- ════════════════════════════════════════════════════════════

function Tender.AttachTo(FarmManager)

    -- 获取一个需要清理的障碍物（杂草 / 犁地碎石）
    function FarmManager:GetWeed()
        if self._loading then return nil end
        if not self.farm_center then return nil end
        
        local range = NPC_TUNING.FARM_WEED_CHECK_RANGE or 10
        local cx, cz = self.farm_center.x, self.farm_center.z
        
        local weeds = _G.TheSim:FindEntities(cx, 0, cz, range, { "weed" })
        for _, w in ipairs(weeds) do
            if w:IsValid() and w.components.workable
               and w.components.workable:CanBeWorked() then
                local wx, wy, wz = w.Transform:GetWorldPosition()
                if IsReachablePosition(wx, wy, wz) then
                    return w
                end
            end
        end

        local debris = _G.TheSim:FindEntities(cx, 0, cz, range, { "farm_debris" })
        for _, d in ipairs(debris) do
            if d:IsValid() and d.components.workable
               and d.components.workable:CanBeWorked() then
                local dx, dy, dz = d.Transform:GetWorldPosition()
                if IsReachablePosition(dx, dy, dz) then
                    return d
                end
            end
        end

        return nil
    end

    -- 检查是否有作物需要浇水
    -- 植物人 force_oversized=true 永远长成巨大作物，缺水只产生 moisture stress 不影响 oversized，
    -- 且缺水不会 Pause 生长（UpdateGrowing 只看 burnable/dark），故永远跳过浇水
    -- 老档身上的浇水壶会留在背包里，受原有 _npc_initial_tool 标记保护，不会被丢弃
    function FarmManager:GetSpotNeedingWater()
        if self._loading then return nil end
        if not self.initialized then return nil end
        if self.inst.npc_character_type == "wormwood" then return nil end
        local now = GetTime()
        if now - self._last_water < (NPC_TUNING.FARM_WATER_COOLDOWN or 120) then return nil end
        for _, spot in ipairs(self.all_spots) do
            if spot.plant ~= nil and spot.plant:IsValid() then
                return spot
            end
        end
        return nil
    end

    -- 获取一个需要照料的植物
    function FarmManager:GetTendablePlant()
        if self._loading then return nil end
        if not self.initialized then return nil end
        local now = GetTime()
        if now - self._last_tend < (NPC_TUNING.FARM_TEND_COOLDOWN or 30) then return nil end

        self:RefreshSpots()
        for _, spot in ipairs(self.all_spots) do
            local p = spot.plant
            if p ~= nil and p:IsValid()
               and p.components.farmplanttendable ~= nil
               and p.components.farmplanttendable.tendable then
                return p, spot
            end
        end
        return nil
    end

    -- 获取一个正在燃烧或冒烟的农场植物
    function FarmManager:GetBurningPlant()
        if self._loading then return nil end
        if not self.initialized then return nil end
        self:RefreshSpots()
        
        local function _CheckBurning(spot)
            local p = spot.plant
            if p and p:IsValid() and not p:IsInLimbo() and p.components.burnable then
                if p.components.burnable:IsBurning() then
                    return p, spot, "burning"
                end
            end
            return nil
        end
        local function _CheckSmoldering(spot)
            local p = spot.plant
            if p and p:IsValid() and not p:IsInLimbo() and p.components.burnable then
                if p.components.burnable:IsSmoldering() then
                    return p, spot, "smoldering"
                end
            end
            return nil
        end
        
        for _, spot in ipairs(self.all_spots) do
            local p, s, state = _CheckBurning(spot)
            if p then return p, s, state end
        end
        
        for _, spot in ipairs(self.all_spots) do
            local p, s, state = _CheckSmoldering(spot)
            if p then return p, s, state end
        end
        
        return nil
    end

    -- 植物被点燃时的回调
    function FarmManager:_OnCropIgnited(plant, data)
        if not self.inst:IsValid() then return end

        self._fire_emergency = true

        local now = GetTime()
        if self._last_fire_speech and now - self._last_fire_speech < 5 then return end

        local char_type = self.inst._char_type or "wormwood"
        local category
        if data and data.doer and data.doer:HasTag("player") then
            category = NPC_SPEECH.FARM_CROP_BURNED_PLAYER
            if not self._slap_target then
                self._slap_target = data.doer
            end
        else
            category = NPC_SPEECH.FARM_CROP_BURNED_NATURAL
        end

        local line = NPC_SPEECH.GetLine(category, char_type)
        local talker = self.inst.components.talker
        if line and talker then
            talker:ShutUp()
            talker:Say(line, nil, nil, true)
            self._last_fire_speech = now
        end
    end

    -- 照料植物
    function FarmManager:DoTend(plant)
        if plant and plant:IsValid()
           and plant.components.farmplanttendable
           and plant.components.farmplanttendable.tendable then
            plant.components.farmplanttendable:TendTo(self.inst)
            self._last_tend = GetTime()
            return true
        end
        return false
    end

    -- 耕作时随机说一句话
    function FarmManager:SayFarmingSpeech()
        if self._last_fire_speech and GetTime() - self._last_fire_speech < 5 then return end
        if math.random() > 0.3 then return end
        local char_type = self.inst._char_type or "wormwood"
        local line = NPC_SPEECH.GetLine(NPC_SPEECH.FARM_WORKING, char_type)
        if line and self.inst.components.talker then
            self.inst.components.talker:Say(line)
        end
    end

    -- 【诊断】按地砖统计可翻土点情况（30秒冷却，防刷屏）
    function FarmManager:DiagnoseTillable()
        if not (NPC_TUNING and NPC_TUNING.DEBUG_FARMING) then return end
        if not self.farm_center then
            FarmLog("[诊断] 跳过：farm_center=nil")
            return
        end
        local now = GetTime()
        if self._last_diag and now - self._last_diag < 30 then return end
        self._last_diag = now

        local map = TheWorld.Map
        local cx, cz = self.farm_center.x, self.farm_center.z
        local search_dist = NPC_TUNING.FARM_WORK_RADIUS or 40
        local tile_range = math.ceil(search_dist / TILE_SCALE)
        local origin_x, _, origin_z = map:GetTileCenterPoint(cx, 0, cz)
        if not origin_x then origin_x, origin_z = cx, cz end
        local half = (GRID_SIZE - 1) / 2

        local tile_count = 0
        local sum_can, sum_soil, sum_plant, sum_cantill, sum_unreach = 0, 0, 0, 0, 0

        self.inst:AddTag("NOBLOCK")

        for dx = -tile_range, tile_range do
            for dz = -tile_range, tile_range do
                local tcx = origin_x + dx * TILE_SCALE
                local tcz = origin_z + dz * TILE_SCALE
                local ddx, ddz = tcx - cx, tcz - cz
                if ddx * ddx + ddz * ddz <= search_dist * search_dist
                   and map:GetTileAtPoint(tcx, 0, tcz) == WORLD_TILES.FARMING_SOIL then
                    tile_count = tile_count + 1
                    local t_can, t_soil, t_plant, t_cantill, t_unreach = 0, 0, 0, 0, 0
                    for row = -half, half do
                        for col = -half, half do
                            local gx = tcx + col * SPACING
                            local gz = tcz + row * SPACING
                            if not IsReachablePosition(gx, 0, gz) then
                                t_unreach = t_unreach + 1
                            else
                                local soil_ents = _G.TheSim:FindEntities(gx, 0, gz, SPOT_RADIUS, {"soil"}, {"NOBLOCK"})
                                local plant_ents = _G.TheSim:FindEntities(gx, 0, gz, SPOT_RADIUS, {"farm_plant"})
                                if #plant_ents > 0 then
                                    t_plant = t_plant + 1
                                elseif #soil_ents > 0 then
                                    t_soil = t_soil + 1
                                elseif not map:CanTillSoilAtPoint(gx, 0, gz, false) then
                                    t_cantill = t_cantill + 1
                                    local point_tile = map:GetTileAtPoint(gx, 0, gz)
                                    local is_farmable = (point_tile == WORLD_TILES.FARMING_SOIL)
                                    local tx_g, tz_g = map:GetTileCoordsAtPoint(gx, 0, gz)
                                    local reason
                                    if not is_farmable then
                                        reason = string.format("tile=%s(非耕地) @tile(%d,%d)",
                                            tostring(point_tile), tx_g or -999, tz_g or -999)
                                    else
                                        -- tile 是耕地 → 模拟 IsDeployPointClear，找出真正阻挡的实体
                                        -- 游戏内: ignore 标签 = NOBLOCK/player/FX/INLIMBO/DECOR/walkableplatform/walkableperipheral/isdead/soil/merm
                                        local IGNORE = { "NOBLOCK", "player", "FX", "INLIMBO", "DECOR",
                                                         "walkableplatform", "walkableperipheral", "isdead", "soil", "merm" }
                                        local SCAN_R = 3.0  -- 扫大点，覆盖 DEPLOY_EXTRA_SPACING
                                        local blockers = _G.TheSim:FindEntities(gx, 0, gz, SCAN_R, nil, IGNORE)
                                        local hits, seen_all = {}, {}
                                        for _, v in ipairs(blockers) do
                                            if v:IsValid() and v.entity:IsVisible()
                                               and v.components.placer == nil
                                               and v.entity:GetParent() == nil then
                                                -- 复刻 IsNearOther 的距离判定
                                                local min_spacing = 1.25
                                                if v.deploy_smart_radius then
                                                    min_spacing = v.deploy_smart_radius + 1.25 / 2
                                                elseif v.deploy_extra_spacing then
                                                    min_spacing = math.max(v.deploy_extra_spacing, 1.25)
                                                elseif v.replica and v.replica.inventoryitem then
                                                    local pr = v.GetPhysicsRadius and v:GetPhysicsRadius(0.5) or 0.5
                                                    min_spacing = pr + 1.25 / 2
                                                end
                                                local dsq = v:GetDistanceSqToPoint(gx, 0, gz)
                                                local d = math.sqrt(dsq)
                                                table.insert(seen_all, string.format("%s@%.2f", v.prefab or "?", d))
                                                if dsq < min_spacing * min_spacing then
                                                    table.insert(hits, string.format("%s@%.2f(挡<%.2f)",
                                                        v.prefab or "?", d, min_spacing))
                                                end
                                            end
                                        end
                                        if #hits > 0 then
                                            reason = "tile=耕地, 阻挡: " .. table.concat(hits, ", ")
                                        else
                                            reason = "tile=耕地, 无阻挡! 3格内实体=[" .. table.concat(seen_all, ", ") .. "]"
                                        end
                                    end
                                    FarmLog(string.format("[诊断]  └ 拒点(%.1f,%.1f) %s", gx, gz, reason))
                                else
                                    t_can = t_can + 1
                                end
                            end
                        end
                    end
                    FarmLog(string.format(
                        "[诊断]地砖#%d (%.1f,%.1f): 可翻=%d 已有坑=%d 已有植物=%d CanTill拒=%d 不可达=%d",
                        tile_count, tcx, tcz, t_can, t_soil, t_plant, t_cantill, t_unreach))
                    sum_can = sum_can + t_can
                    sum_soil = sum_soil + t_soil
                    sum_plant = sum_plant + t_plant
                    sum_cantill = sum_cantill + t_cantill
                    sum_unreach = sum_unreach + t_unreach
                end
            end
        end

        self.inst:RemoveTag("NOBLOCK")

        FarmLog(string.format(
            "[诊断] 中心(%.1f,%.1f) 半径=%d → 发现%d块地砖 共%d点: 可翻=%d 已有坑=%d 已有植物=%d CanTill拒=%d 不可达=%d",
            cx, cz, search_dist, tile_count, tile_count * 4,
            sum_can, sum_soil, sum_plant, sum_cantill, sum_unreach))
    end

    -- 获取一个未翻土的点
    function FarmManager:GetUntilledSpot()
        if self._loading then
            FarmLog("GetUntilledSpot: 跳过（loading）")
            return nil
        end
        if not self.initialized then
            FarmLog("GetUntilledSpot: 跳过（not initialized）")
            return nil
        end
        self:RefreshSpots()
        -- 调用一次诊断（带 30 秒冷却）
        self:DiagnoseTillable()
        local map = TheWorld.Map
        local inst = self.inst

        inst:AddTag("NOBLOCK")

        local result = nil
        local checked = 0
        local can_till = 0
        for _, spot in ipairs(self.all_spots) do
            checked = checked + 1
            if spot.plant ~= nil and not spot.plant:IsValid() then
                spot.plant = nil
            end
            if spot.soil ~= nil and (not spot.soil:IsValid() or spot.soil:HasTag("NOBLOCK")) then
                spot.soil = nil
            end
            if spot.soil == nil and spot.plant == nil then
                if map:CanTillSoilAtPoint(spot.x, 0, spot.z, false) then
                    can_till = can_till + 1
                    local nearby = _G.TheSim:FindEntities(spot.x, 0, spot.z, SPOT_RADIUS, {"soil"}, {"NOBLOCK"})
                    if #nearby > 0 then
                        spot.soil = nearby[1]
                    else
                        result = spot
                        FarmLog(string.format("GetUntilledSpot: 命中 all_spots 点 (%.1f, %.1f), checked=%d, can_till=%d",
                            spot.x, spot.z, checked, can_till))
                        break
                    end
                end
            end
        end

        -- 兜底：实时扫描可翻土点
        if result == nil and self.farm_center then
            local cx, cz = self.farm_center.x, self.farm_center.z
            local search_dist = NPC_TUNING.FARM_WORK_RADIUS or 40
            local tile_range = math.ceil(search_dist / TILE_SCALE)
            local center_tile_x = math.floor(cx / TILE_SCALE)
            local center_tile_z = math.floor(cz / TILE_SCALE)
            local half = (GRID_SIZE - 1) / 2

            for dx = -tile_range, tile_range do
                for dz = -tile_range, tile_range do
                    local tx = center_tile_x + dx
                    local tz = center_tile_z + dz
                    local tcx = tx * TILE_SCALE + TILE_SCALE / 2
                    local tcz = tz * TILE_SCALE + TILE_SCALE / 2

                    local ddx = tcx - cx
                    local ddz = tcz - cz
                    if ddx * ddx + ddz * ddz <= search_dist * search_dist then
                        local tile_type = map:GetTileAtPoint(tcx, 0, tcz)
                        if tile_type == WORLD_TILES.FARMING_SOIL then
                            for row = -half, half do
                                for col = -half, half do
                                    local gx = tcx + col * SPACING
                                    local gz = tcz + row * SPACING
                                    if map:CanTillSoilAtPoint(gx, 0, gz, false) then
                                        local nearby_soil = _G.TheSim:FindEntities(gx, 0, gz, SPOT_RADIUS, {"soil"}, {"NOBLOCK"})
                                        local nearby_plant = _G.TheSim:FindEntities(gx, 0, gz, SPOT_RADIUS, {"farm_plant"})
                                        if #nearby_soil == 0 and #nearby_plant == 0 then
                                            result = {
                                                x = gx,
                                                z = gz,
                                                soil = nil,
                                                plant = nil,
                                                needs_till = true,
                                                is_external = true,
                                            }
                                            FarmLog(string.format("GetUntilledSpot: 命中 fallback 点 (%.1f, %.1f)", gx, gz))
                                            break
                                        end
                                    end
                                end
                                if result ~= nil then break end
                            end
                        end
                    end
                    if result ~= nil then break end
                end
                if result ~= nil then break end
            end
        end

        if result == nil then
            FarmLog(string.format("GetUntilledSpot: 未找到可翻土点, checked=%d, can_till=%d", checked, can_till))
        end

        inst:RemoveTag("NOBLOCK")
        return result
    end

    -- 获取一个空的 farm_soil（有土壤但没植物，可种植）
    function FarmManager:GetEmptyFarmSoil()
        if self._loading then
            FarmLog("GetEmptyFarmSoil: 跳过（loading）")
            return nil
        end
        if not self.initialized then
            FarmLog("GetEmptyFarmSoil: 跳过（not initialized）")
            return nil
        end
        
        -- 播种冷却（保留但默认 0，由 npc_tuning.lua 控制）
        local cd = NPC_TUNING.FARM_PLANT_COOLDOWN or 0
        if cd > 0 then
            local now = GetTime()
            if now - self._last_plant < cd then
                return nil
            end
        end

        local inst = self.inst
        inst:AddTag("NOBLOCK")

        self:RefreshSpots()
        local result = nil
        local checked = 0
        local valid_soil = 0
        
        for _, spot in ipairs(self.all_spots) do
            checked = checked + 1
            if spot.plant ~= nil and not spot.plant:IsValid() then
                spot.plant = nil
            end
            if spot.soil ~= nil and not spot.soil:IsValid() then
                spot.soil = nil
            end
            if spot.soil and spot.soil:IsValid() and not spot.soil:HasTag("NOBLOCK")
               and not spot.plant
               and not spot.soil:HasTag("NOCLICK") then
                valid_soil = valid_soil + 1
                result = spot
                FarmLog(string.format("GetEmptyFarmSoil: 命中可播种点 (%.1f, %.1f), checked=%d, valid_soil=%d",
                    spot.x, spot.z, checked, valid_soil))
                break
            end
        end

        if result == nil then
            FarmLog(string.format("GetEmptyFarmSoil: 未找到可播种点, checked=%d, valid_soil=%d", checked, valid_soil))
        end

        inst:RemoveTag("NOBLOCK")
        return result
    end

    -- 模拟种植
    function FarmManager:DoPlant(spot)
        if not spot then return false end
        TheWorld.Map:CollapseSoilAtPoint(spot.x, 0, spot.z)
        local plant = SpawnPrefab("farm_plant_randomseed")
        if plant then
            plant.Transform:SetPosition(spot.x, 0, spot.z)
            plant:PushEvent("on_planted", { in_soil = true, doer = self.inst })
            spot.plant = plant
            spot.soil = nil
            self._last_plant = GetTime()

            if spot._seed_listener and spot._seed_entity and spot._seed_entity:IsValid() then
                spot._seed_entity:RemoveEventCallback("onremove", spot._seed_listener)
            end

            local config = self.config
            local all_spots = self.all_spots
            spot._seed_listener = function(seed)
                local actual = seed.grew_into
                if actual == nil or not actual:IsValid() then return end

                for _, s in ipairs(all_spots) do
                    if s.plant == seed then
                        s.plant = actual
                        s._ignite_listened = false
                        s._seed_listener = nil
                        s._seed_entity = nil
                        break
                    end
                end

                if config.force_oversized then
                    actual.force_oversized = true
                end

                if config.ignore_season and actual.plant_def then
                    local new_def = {}
                    for k, v in pairs(actual.plant_def) do new_def[k] = v end
                    new_def.good_seasons = { autumn = true, winter = true, spring = true, summer = true }
                    actual.plant_def = new_def
                end
            end
            spot._seed_entity = plant
            self.inst:ListenForEvent("onremove", spot._seed_listener, plant)

            return true
        end
        return false
    end

    -- 尝试装备能执行指定动作的工具
    function FarmManager:TryEquipForAction(action)
        local inv = self.inst.components.inventory
        if not inv then return false end

        local function CanItemDoAction(item)
            if not item then return false end
            if action == ACTIONS.TILL then
                return item.components.farmtiller ~= nil
            end
            if action == ACTIONS.POUR_WATER or action == ACTIONS.POUR_WATER_GROUNDTILE then
                return item:HasTag("wateringcan")
            end
            return item.components.tool ~= nil
               and item.components.tool:CanDoAction(action)
        end

        local equipped = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if CanItemDoAction(equipped) then
            return true
        end
        for i = 1, inv.maxslots do
            local item = inv:GetItemInSlot(i)
            if item and item.components.equippable
               and item.components.equippable.equipslot == EQUIPSLOTS.HANDS
               and CanItemDoAction(item) then
                inv:Equip(item)
                return true
            end
        end

        if action == ACTIONS.TILL then
            local hoe = SpawnPrefab("farm_hoe")
            if hoe then
                hoe:AddTag("_npc_tool")
                hoe._npc_tool = true
                inv:GiveItem(hoe)
                inv:Equip(hoe)
                FarmLog("自动生成锄头 farm_hoe")
                return true
            end
            return false
        end

        -- 找不到工具：按 action 类型对应播报缺工具台词（每个工具 60 秒冷却）
        local pool, key
        if action == ACTIONS.DIG then
            pool, key = NPC_SPEECH.NO_SHOVEL, "shovel"
        elseif action == ACTIONS.HAMMER then
            pool, key = NPC_SPEECH.NO_HAMMER, "hammer"
        elseif action == ACTIONS.POUR_WATER or action == ACTIONS.POUR_WATER_GROUNDTILE then
            pool, key = NPC_SPEECH.NO_WATERINGCAN, "wateringcan"
        end

        if pool and key then
            self._tool_say_cd = self._tool_say_cd or {}
            local now = GetTime()
            local last = self._tool_say_cd[key]
            if not last or now - last > 60 then
                self._tool_say_cd[key] = now
                local talker = self.inst.components.talker
                if talker then
                    local line = NPC_SPEECH.GetLine(pool, self.inst.npc_character_type)
                    if line then talker:Say(line) end
                end
            end
        end

        return false
    end

end -- Tender.AttachTo

return Tender
