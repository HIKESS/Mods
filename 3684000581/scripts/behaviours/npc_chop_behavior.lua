-- scripts/behaviours/npc_chop_behavior.lua
-- 吴迪专属砍树行为模块：ChopHere 按钮触发后自动砍树
-- ────────────────────────────────────────────────────────────
-- 可配置参数（通过 config 表传入）：
--   get_center_fn(inst)        → {x, z}  砍树中心点
--   get_filter_fn(inst)        → {small=bool, medium=bool, big=bool} 按树大小过滤
--                                stage 1=小树, 2=中树, stage>=3=大树（含老树 stage=4）
--                                多枝树(twiggytree)同样适用；须同时开启「砍多枝树」
--   should_dig_stump_fn(inst)  → bool 砍倒树后是否挖树根（默认关闭）
--                                需要 NPC 身上有 shovel 或 goldenshovel
--                                没铲子时静默回退到原逻辑（找下一棵树）
--   scan_radius                → number  搜索半径（默认 30）
--   scan_interval              → number  扫描间隔秒（默认 4）
--   approach_dist              → number  砍树接近距离（默认 2.5）
--   max_chop_time              → number  单棵树砍树/挖根超时（默认 5）
--   allowed_prefabs            → table   允许砍的树 prefab 列表
--
-- 阶段流程：
--   idle → walk_to_tree → chopping → [dig_stump] → cooldown → (循环)
--   dig_stump 仅在 should_dig_stump_fn 为 true 且身上有铲子时进入
-- ────────────────────────────────────────────────────────────

local NPC_TUNING = require("npc_tuning")


local ACTIONS      = ACTIONS
local EQUIPSLOTS   = EQUIPSLOTS
local GetTime      = GetTime
local BufferedAction = BufferedAction
local Vector3      = Vector3


local function _dbg(...) if NPC_TUNING.DEBUG_CHOP then print("[NPC_CHOP]", ...) end end





local DEFAULT_SCAN_RADIUS     = 30
local DEFAULT_SCAN_INTERVAL   = 4
local DEFAULT_APPROACH_DIST   = 2.5
local DEFAULT_MAX_CHOP_TIME   = 5
local DEFAULT_SAY_COOLDOWN    = 15

local DEFAULT_ALLOWED_PREFABS = {
    "evergreen",
    "evergreen_sparse",
    "deciduoustree",
    "twiggytree",   
}


local EXCLUDE_TAGS = { "burnt", "stump", "INLIMBO", "NOCLICK", "dead" }





NPCChopBehavior = Class(BehaviourNode, function(self, inst, config)
    BehaviourNode._ctor(self, "NPCChopBehavior")
    self.inst   = inst
    self.config = config or {}

    self._phase           = "idle"        
    self._target_tree     = nil
    self._target_stump    = nil
    self._last_scan       = 0
    self._chop_start_time = 0
    self._dig_start_time  = 0
    self._cooldown_start  = 0
end)

function NPCChopBehavior:DBString()
    return string.format("NPCChopBehavior(phase=%s, target=%s)",
        tostring(self._phase),
        self._target_tree and tostring(self._target_tree.prefab) or "nil")
end





function NPCChopBehavior:_GetCenter()
    if self.config.get_center_fn then
        return self.config.get_center_fn(self.inst)
    end
    return nil
end

function NPCChopBehavior:_ScanRadius()
    return self.config.scan_radius or DEFAULT_SCAN_RADIUS
end

function NPCChopBehavior:_ScanInterval()
    return self.config.scan_interval or DEFAULT_SCAN_INTERVAL
end

function NPCChopBehavior:_ApproachDist()
    return self.config.approach_dist or DEFAULT_APPROACH_DIST
end

function NPCChopBehavior:_MaxChopTime()
    return self.config.max_chop_time or DEFAULT_MAX_CHOP_TIME
end

function NPCChopBehavior:_AllowedPrefabs()
    return self.config.allowed_prefabs or DEFAULT_ALLOWED_PREFABS
end

function NPCChopBehavior:_IsAllowedTreePrefab(prefab)
    for _, p in ipairs(self:_AllowedPrefabs()) do
        if p == prefab then return true end
    end
    return false
end

-- growable.stage：1=小, 2=中, 3=大, 4=老（老归「砍大树」）
local function _StageAllowedByFilter(tree, filter)
    if filter == nil then return true end
    local g = tree.components.growable
    local stage = g and g.stage or 2
    if stage <= 1 then
        return filter.small ~= false
    elseif stage == 2 then
        return filter.medium ~= false
    else
        return filter.big ~= false
    end
end

function NPCChopBehavior:_IsChopTreeAllowed(tree, filter)
    if tree == nil or not self:_IsAllowedTreePrefab(tree.prefab) then
        return false
    end
    if tree.prefab == "twiggytree" and self.inst._woodie_chop_twiggy == false then
        return false
    end
    return _StageAllowedByFilter(tree, filter)
end

function NPCChopBehavior:_IsStumpAllowed(stump)
    if stump == nil or not self:_IsAllowedTreePrefab(stump.prefab) then
        return false
    end
    if stump.prefab == "twiggytree" and self.inst._woodie_chop_twiggy == false then
        return false
    end
    return true
end






function NPCChopBehavior:_HasLucy()
    local inst = self.inst
    local inv = inst.components.inventory
    if not inv then return false end

    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and hand.prefab == "lucy" then
        return true
    end

    local lucy_item = inv:FindItem(function(item)
        return item.prefab == "lucy"
    end)
    return lucy_item ~= nil
end

function NPCChopBehavior:_EnsureLucyEquipped()
    local inst = self.inst
    local inv = inst.components.inventory
    if not inv then return false end

    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and hand.prefab == "lucy" then
        return true
    end

    local lucy_item = inv:FindItem(function(item)
        return item.prefab == "lucy"
    end)
    if lucy_item and lucy_item.components.equippable then
        inv:Equip(lucy_item)
        _dbg("自动装备 Lucy 斧")
        return true
    end

    return false
end





local function _IsShovelItem(item)
    return item ~= nil
        and (item.prefab == "shovel" or item.prefab == "goldenshovel")
end

function NPCChopBehavior:_HasShovel()
    local inst = self.inst
    local inv = inst.components.inventory
    if not inv then return false end

    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if _IsShovelItem(hand) then
        return true
    end
    return inv:FindItem(_IsShovelItem) ~= nil
end



function NPCChopBehavior:_EnsureShovelEquipped()
    local inst = self.inst
    local inv = inst.components.inventory
    if not inv then return false end

    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if _IsShovelItem(hand) then
        return true
    end

    local item = inv:FindItem(function(it) return it.prefab == "goldenshovel" end)
    if item == nil then
        item = inv:FindItem(function(it) return it.prefab == "shovel" end)
    end
    if item and item.components.equippable then
        inv:Equip(item)
        _dbg("自动装备铲子: " .. tostring(item.prefab))
        return true
    end
    return false
end










function NPCChopBehavior:_GetFilter()
    if self.config.get_filter_fn then
        return self.config.get_filter_fn(self.inst)
    end
    return nil
end

function NPCChopBehavior:_FindNearestTree(center)
    local filter = self:_GetFilter()

    local inst = self.inst
    local ix, _, iz = inst.Transform:GetWorldPosition()
    
    local cx, cz = center.x, center.z
    local radius = self:_ScanRadius()

    _dbg(string.format("搜索树: center=(%.1f,%.1f) npc=(%.1f,%.1f) radius=%d",
        cx, cz, ix, iz, radius))

    local trees = _G.TheSim:FindEntities(cx, 0, cz, radius,
        { "CHOP_workable" },  
        EXCLUDE_TAGS          
    )

    _dbg("找到 CHOP_workable 实体数:", #trees)

    local best = nil
    local best_dist_sq = math.huge
    local valid_count = 0
    local skipped_by_size = 0

    for _, tree in ipairs(trees) do
        if tree:IsValid()
           and tree.components.workable
           and tree.components.workable:CanBeWorked() then
            if not self:_IsChopTreeAllowed(tree, filter) then
                skipped_by_size = skipped_by_size + 1
            else
                valid_count = valid_count + 1
                local tx, _, tz = tree.Transform:GetWorldPosition()
                local dsq = (tx - ix)^2 + (tz - iz)^2
                if dsq < best_dist_sq then
                    best = tree
                    best_dist_sq = dsq
                end
            end
        end
    end

    _dbg(string.format("有效树木数: %d (按尺寸过滤跳过: %d), 选中: %s, 距离: %.1f",
        valid_count, skipped_by_size,
        best and best.prefab or "nil", best and math.sqrt(best_dist_sq) or 0))

    return best
end



function NPCChopBehavior:_FindNearestStump(center)
    local inst = self.inst
    local ix, _, iz = inst.Transform:GetWorldPosition()
    local cx, cz = center.x, center.z
    local radius = self:_ScanRadius()

    
    local stumps = _G.TheSim:FindEntities(cx, 0, cz, radius,
        { "stump" },                          
        { "burnt", "INLIMBO", "NOCLICK" }     
    )

    local best = nil
    local best_dist_sq = math.huge
    local valid_count = 0

    for _, stump in ipairs(stumps) do
        if stump:IsValid() and self:_IsStumpAllowed(stump)
           and stump.components.workable
           and stump.components.workable:CanBeWorked()
           and stump.components.workable:GetWorkAction() == ACTIONS.DIG then
            valid_count = valid_count + 1
            local sx, _, sz = stump.Transform:GetWorldPosition()
            local dsq = (sx - ix)^2 + (sz - iz)^2
            if dsq < best_dist_sq then
                best = stump
                best_dist_sq = dsq
            end
        end
    end

    _dbg(string.format("搜索树根: %d 个候选, 选中: %s, 距离: %.1f",
        valid_count, best and best.prefab or "nil",
        best and math.sqrt(best_dist_sq) or 0))

    return best
end





function NPCChopBehavior:_SayLine(speech_key, cooldown)
    local inst = self.inst
    if not inst or not inst:IsValid() or not inst.components.talker then return end

    inst._chop_say_cd = inst._chop_say_cd or {}
    local now = GetTime()
    local cd = cooldown or DEFAULT_SAY_COOLDOWN

    if inst._chop_say_cd[speech_key] and (now - inst._chop_say_cd[speech_key]) < cd then
        return  
    end
    inst._chop_say_cd[speech_key] = now

    local ok, NPC_SPEECH = pcall(function() return require("npc_speech") end)
    if not ok or not NPC_SPEECH then return end

    local pool = NPC_SPEECH[speech_key]
    if not pool then return end

    local line = NPC_SPEECH.GetLine(pool, inst.npc_character_type)
    if line then
        inst.components.talker:Say(line)
    end
end





function NPCChopBehavior:Visit()
    local inst = self.inst

    if not inst:IsValid() or inst._is_ghost_mode then
        _dbg("Visit: NPC无效或幽灵模式, FAILED")
        self.status = FAILED
        return
    end

    local center = self:_GetCenter()
    if not center then
        _dbg("Visit: 无中心点, FAILED")
        self.status = FAILED
        return
    end

    if not self:_HasLucy() then
        
        _dbg("Visit: 无Lucy斧, FAILED (30秒台词冷却)")
        self:_SayLine("CHOP_NO_LUCY", 30)
        self.status = FAILED
        return
    end

    
    if self._phase ~= "dig_stump" then
        self:_EnsureLucyEquipped()
    end

    if self.status == READY then
        _dbg("Visit: 状态READY → RUNNING, phase=idle")
        self.status = RUNNING
        self._phase = "idle"
        self._last_scan = 0
    end

    if self.status == RUNNING then
        
        local sg_state = inst.sg and inst.sg.currentstate and inst.sg.currentstate.name or "nil"
        _dbg(string.format("Visit: phase=%s, sg=%s, target=%s, time_since_scan=%.1f",
            self._phase, sg_state,
            self._target_tree and self._target_tree.prefab or "nil",
            GetTime() - self._last_scan))
        self:_RunPhase(center)
    end
end

function NPCChopBehavior:_RunPhase(center)
    local inst = self.inst

    if self._phase == "idle" then
        self:_PhaseIdle(center)

    elseif self._phase == "walk_to_tree" then
        self:_PhaseWalkToTree()

    elseif self._phase == "chopping" then
        self:_PhaseChopping()

    elseif self._phase == "dig_stump" then
        self:_PhaseDigStump()

    elseif self._phase == "cooldown" then
        self:_PhaseCooldown()
    end
end





function NPCChopBehavior:_PhaseIdle(center)
    local inst = self.inst
    local now = GetTime()

    local time_since_scan = now - self._last_scan
    local scan_interval = self:_ScanInterval()
    
    if time_since_scan >= scan_interval then
        _dbg(string.format("_PhaseIdle: 开始扫描 (间隔%.1f秒已过)", time_since_scan))
        self._last_scan = now
        self._target_tree = self:_FindNearestTree(center)

        if self._target_tree then
            self._phase = "walk_to_tree"
            self._chop_start_time = now  
            inst.components.locomotor:Stop()
            _dbg("_PhaseIdle: 找到树，切换到 walk_to_tree, 目标:", self._target_tree.prefab)
            return
        end

        
        local dig_enabled = self.config.should_dig_stump_fn ~= nil
            and self.config.should_dig_stump_fn(inst) == true
        if dig_enabled and self:_HasShovel() then
            local stump = self:_FindNearestStump(center)
            if stump then
                self._target_stump = stump
                self._dig_start_time = now
                self._phase = "dig_stump"
                inst.components.locomotor:Stop()
                _dbg("_PhaseIdle: 没树可砍，找到旧树根 → dig_stump, 目标:", stump.prefab)
                return
            end
        end

        
        _dbg("_PhaseIdle: 未找到树/树根，等待下次扫描")
        self:_SayLine("CHOP_NO_TARGET", 30)
    end
end

function NPCChopBehavior:_PhaseWalkToTree()
    local inst = self.inst
    local tree = self._target_tree

    if not tree or not tree:IsValid()
       or not tree.components.workable
       or not tree.components.workable:CanBeWorked() then
        
        _dbg("_PhaseWalkToTree: 目标树无效，重新扫描")
        self._target_tree = nil
        self._phase = "idle"
        self._last_scan = 0  
        return
    end

    local tx, ty, tz = tree.Transform:GetWorldPosition()
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local dist = math.sqrt((tx - ix)^2 + (tz - iz)^2)
    local approach = self:_ApproachDist()

    if dist <= approach then
        inst.components.locomotor:Stop()
        self._phase = "chopping"
        self._chop_start_time = GetTime()
        _dbg(string.format("_PhaseWalkToTree: 到达树旁 (dist=%.1f), 切换到 chopping", dist))
    else
        inst.components.locomotor:GoToPoint(Vector3(tx, ty, tz), nil, true)
    end
end

function NPCChopBehavior:_PhaseChopping()
    local inst = self.inst
    local tree = self._target_tree

    local max_time = self:_MaxChopTime()
    local elapsed = GetTime() - self._chop_start_time
    if elapsed > max_time then
        _dbg(string.format("_PhaseChopping: 砍树超时 (%.1f > %d秒)，放弃当前目标", elapsed, max_time))
        self._target_tree = nil
        self._phase = "idle"
        self._last_scan = 0
        return
    end

    
    if not tree or not tree:IsValid()
       or not tree.components.workable
       or not tree.components.workable:CanBeWorked()
       or tree.components.workable:GetWorkAction() ~= ACTIONS.CHOP then
        _dbg("_PhaseChopping: 树已砍倒!")

        
        local dig_enabled = self.config.should_dig_stump_fn ~= nil
            and self.config.should_dig_stump_fn(inst) == true
        if dig_enabled
           and tree and tree:IsValid()
           and tree.components.workable
           and tree.components.workable:CanBeWorked()
           and tree.components.workable:GetWorkAction() == ACTIONS.DIG
           and self:_HasShovel() then
            self._target_stump = tree
            self._target_tree  = nil
            self._dig_start_time = GetTime()
            self._phase = "dig_stump"
            _dbg("_PhaseChopping: 切换到 dig_stump (挖树根)")
            return
        end

        
        self._target_tree = nil

        local center = self:_GetCenter()
        if not center then
            local x, _, z = inst.Transform:GetWorldPosition()
            center = { x = x, z = z }
        end

        local next_tree = self:_FindNearestTree(center)

        if next_tree then
            self._target_tree = next_tree
            self._phase = "walk_to_tree"
            self._chop_start_time = GetTime()  
            self._last_scan = GetTime()
            _dbg("_PhaseChopping: 立即找到下一棵:", next_tree.prefab, "→ walk_to_tree")
            return
        end

        _dbg("_PhaseChopping: 未找到下一棵树 → idle")
        self._phase = "idle"
        self._last_scan = 0
        return
    end

    if inst.sg and inst.bufferedaction == nil then
        
        if NPC_TUNING.DEBUG_CHOP then
            local action_name = tree.components.workable and tree.components.workable:GetWorkAction() and tree.components.workable:GetWorkAction().id or "nil"
            _dbg("_PhaseChopping: target workable action=" .. tostring(action_name))
        end
        local ba = BufferedAction(inst, tree, ACTIONS.CHOP,
            inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil)
        inst:PushBufferedAction(ba)
        _dbg("_PhaseChopping: 推送 CHOP 动作")
    end
end

function NPCChopBehavior:_PhaseDigStump()
    local inst = self.inst
    local stump = self._target_stump

    
    local max_time = self:_MaxChopTime()
    local elapsed = GetTime() - self._dig_start_time
    if elapsed > max_time then
        _dbg(string.format("_PhaseDigStump: 挖根超时 (%.1f > %d秒)，放弃当前树根", elapsed, max_time))
        self._target_stump = nil
        self._phase = "idle"
        self._last_scan = 0
        return
    end

    
    if not stump or not stump:IsValid()
       or not stump.components.workable
       or not stump.components.workable:CanBeWorked()
       or stump.components.workable:GetWorkAction() ~= ACTIONS.DIG then
        _dbg("_PhaseDigStump: 树根已挖掉 → idle")
        self._target_stump = nil
        self._phase = "idle"
        self._last_scan = 0
        return
    end

    
    if not self:_HasShovel() then
        _dbg("_PhaseDigStump: 铲子丢失 → idle")
        self._target_stump = nil
        self._phase = "idle"
        self._last_scan = 0
        return
    end

    
    local sx, sy, sz = stump.Transform:GetWorldPosition()
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local dist = math.sqrt((sx - ix)^2 + (sz - iz)^2)
    local approach = self:_ApproachDist()

    if dist > approach then
        inst.components.locomotor:GoToPoint(Vector3(sx, sy, sz), nil, true)
        return
    end

    inst.components.locomotor:Stop()

    
    if not self:_EnsureShovelEquipped() then
        _dbg("_PhaseDigStump: 装备铲子失败 → idle")
        self._target_stump = nil
        self._phase = "idle"
        return
    end

    
    if inst.sg and inst.bufferedaction == nil then
        local hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
        local ba = BufferedAction(inst, stump, ACTIONS.DIG, hand)
        inst:PushBufferedAction(ba)
        _dbg("_PhaseDigStump: 推送 DIG 动作")
    end
end

function NPCChopBehavior:_PhaseCooldown()
    _dbg("_PhaseCooldown: → idle (立即继续)")
    self._phase = "idle"
    self._last_scan = 0
end

return NPCChopBehavior
