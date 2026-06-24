-- scripts/behaviours/npc_collect_behavior.lua
-- 通用收集行为：扫描地面物品 → 拾取 → 按分类智能存入容器
-- ────────────────────────────────────────────────────────────
-- 可配置参数（通过 config 表传入）：
--   get_center_fn(inst)        → Vector3   扫描中心点
--   get_iceboxes_fn(inst)      → {entity}  冰箱实体列表
--   get_chests_fn(inst)        → {entity}  箱子实体列表
--   scan_radius                → number    扫描半径（默认 15）
--   scan_interval              → number    扫描间隔秒（默认 6）
--   approach_dist              → number    拾取接近距离（默认 2.5）
--   container_approach_dist    → number    容器接近距离（默认 2.5）
--
-- 阶段流程：
--   idle  →  walk_to_item  →  picking_up  →  (循环拾取)
--         →  walk_to_container  →  storing  →  (循环存储)
--         →  organize_plan  →  organize_walk  →  organize_access  →  (循环整理)
-- ────────────────────────────────────────────────────────────

local NPC_TUNING        = require("npc_tuning")
local InvUtil           = require("npc/npc_inventory_util")
local ItemClassify      = require("npc/npc_item_classify")
local StructureUtil     = require("npc/npc_structure_util")
local ContainerCleaner  = require("npc/npc_container_cleaner")


local DEBUG_BEHAVIOR = NPC_TUNING.DEBUG_BEHAVIOR
local function _dbg(...) if DEBUG_BEHAVIOR then print(...) end end


local function FarmLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        print("[种植调试]", ...)
    end
end





local DEFAULT_SCAN_RADIUS            = 15
local DEFAULT_SCAN_INTERVAL          = NPC_TUNING.COLLECT_DEFAULT_SCAN_INTERVAL
local DEFAULT_APPROACH_DIST          = 1.5
local DEFAULT_CONTAINER_APPROACH_DIST = 1.5
local NEARBY_CONTAINER_RADIUS = NPC_TUNING.NEARBY_CONTAINER_SCAN_RADIUS or 25


local function _SkipUnwantedItem(e, inst)
    local drop_cooldown = NPC_TUNING.NPC_DROP_COOLDOWN or 60
    if e._npc_dropped_time and (GetTime() - e._npc_dropped_time) < drop_cooldown then
        FarmLog("_SkipUnwantedItem: 跳过最近丢弃的物品", e.prefab,
                "冷却剩余:", math.ceil(drop_cooldown - (GetTime() - e._npc_dropped_time)), "秒")
        return true
    end
    local cat = ItemClassify.GetCategory(e, inst)
    local skip = (cat == "ground" or cat == "delete" or cat == "ignore")
    if DEBUG_BEHAVIOR then
        print("[NPC_DEBUG] _SkipUnwantedItem -", e.prefab or "?",
              "cat=", cat, "skip=", tostring(skip),
              "backpack=", tostring(e:HasTag("backpack")),
              "container=", tostring(e.components.container ~= nil))
    end
    return skip
end


local function _SkipNoStorage(e, inst, iceboxes_full, chests_full)
    
    local drop_cooldown = NPC_TUNING.NPC_DROP_COOLDOWN or 60
    if e._npc_dropped_time and (GetTime() - e._npc_dropped_time) < drop_cooldown then
        return true
    end
    local cat = ItemClassify.GetCategory(e, inst)
    local skip = false
    if cat == "ground" or cat == "delete" or cat == "ignore" then skip = true
    elseif cat == "icebox" then skip = iceboxes_full and chests_full
    elseif cat == "chest"  then skip = chests_full
    end
    if DEBUG_BEHAVIOR then
        print("[NPC_DEBUG] _SkipNoStorage -", e.prefab or "?",
              "cat=", cat, "skip=", tostring(skip),
              "ib_full=", tostring(iceboxes_full), "ch_full=", tostring(chests_full),
              "backpack=", tostring(e:HasTag("backpack")),
              "container=", tostring(e.components.container ~= nil))
    end
    return skip
end

local CAPACITY_CACHE_TTL = NPC_TUNING.CHEF_CAPACITY_CACHE_TTL or 10  
local WALK_STUCK_TIMEOUT = 8    
local UNREACHABLE_EXPIRE = 60  


local ORGANIZE_INTERVAL       = NPC_TUNING.WES_ORGANIZE_INTERVAL or 30   
local ORGANIZE_APPROACH_DIST  = 1.5  
local ORGANIZE_APPROACH_DISTSQ = ORGANIZE_APPROACH_DIST * ORGANIZE_APPROACH_DIST
local STORE_FAIL_THRESHOLD     = 3   
local FAILED_CONTAINER_EXPIRE  = 60  
local CHESTS_FULL_SAY_INTERVAL = 30 
local COLLECT_WORK_SAY_COOLDOWN = NPC_TUNING.COLLECT_WORK_SAY_COOLDOWN or 12
local COLLECT_WORK_SAY_CHANCE = NPC_TUNING.COLLECT_WORK_SAY_CHANCE or 0.35





NPCCollectBehavior = Class(BehaviourNode, function(self, inst, config)
    BehaviourNode._ctor(self, "NPCCollectBehavior")
    self.inst   = inst
    self.config = config or {}

    self._last_scan        = 0
    self._phase            = "idle"
    self._target_item      = nil
    self._target_container = nil
    self._failed_containers = {}  
    self._unreachable_items = {}  
    self._walk_start_time   = nil 
    self._walk_start_distsq = nil 

    
    self._last_organize_check = 0   
    self._organize_queue      = nil 
    self._organize_current    = nil 
    self._organize_substep    = nil 
    self._organize_walk_target = nil 
    self._organize_ctx        = nil 
    self._trip_delivery_index = nil 
    self._organize_consecutive_fails = 0  
    self._store_consecutive_fails = 0      
    self._last_chests_full_say = 0          
end)

function NPCCollectBehavior:DBString()
    return string.format("Collect (phase=%s)", tostring(self._phase))
end





function NPCCollectBehavior:_GetCenter()
    if self.config.get_center_fn then
        return self.config.get_center_fn(self.inst)
    end
    return nil
end

function NPCCollectBehavior:_GetIceboxes()
    if self.config.get_iceboxes_fn then
        return self.config.get_iceboxes_fn(self.inst) or {}
    end
    return {}
end

function NPCCollectBehavior:_GetChests()
    if self.config.get_chests_fn then
        return self.config.get_chests_fn(self.inst) or {}
    end
    return {}
end

function NPCCollectBehavior:_ScanRadius()
    local r = self.config.scan_radius
    return type(r) == "function" and r() or r or DEFAULT_SCAN_RADIUS
end

function NPCCollectBehavior:_ScanInterval()
    return self.config.scan_interval or DEFAULT_SCAN_INTERVAL
end

function NPCCollectBehavior:_OrganizeInterval()
    return self.config.organize_interval or ORGANIZE_INTERVAL
end

function NPCCollectBehavior:_ApproachDistSq()
    local d = self.config.approach_dist or DEFAULT_APPROACH_DIST
    return d * d
end

function NPCCollectBehavior:_ContainerApproachDistSq()
    local d = self.config.container_approach_dist or DEFAULT_CONTAINER_APPROACH_DIST
    return d * d
end


function NPCCollectBehavior:_HasPendingRehomeItems(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and item._npc_collect_rehome then
            return true
        end
    end
    return false
end

function NPCCollectBehavior:_CountStorableItems(inst)
    local inv = inst.components.inventory
    if not inv then return 0 end
    local count = 0
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item then
            local cat = ItemClassify.GetCategory(item, inst)
            if cat ~= "tool" and (cat ~= "ignore" or item._npc_collect_rehome) then
                count = count + 1
            end
        end
    end
    return count
end

function NPCCollectBehavior:_HasStorableItems(inst)
    return self:_CountStorableItems(inst) > 0
end

function NPCCollectBehavior:_StorePendingRehomeToContainer(inst, container)
    local inv = inst.components.inventory
    local cont = container and container.components and container.components.container
    if not inv or not cont then return end
    for i = inv.maxslots, 1, -1 do
        local item = inv:GetItemInSlot(i)
        if item and item._npc_collect_rehome then
            local taken = inv:RemoveItem(item, true)
            if taken and taken:IsValid() then
                taken.prevcontainer = nil
                taken.prevslot = nil
                if cont:GiveItem(taken, nil, nil, false) then
                    taken._npc_collect_rehome = nil
                else
                    inv:GiveItem(taken)
                end
            end
        end
    end
end





function NPCCollectBehavior:_RefreshContainerCapacity()
    local now = GetTime()
    if self._cap_cache_time and now - self._cap_cache_time < CAPACITY_CACHE_TTL then

	local cache_valid = true
        if self._cached_iceboxes then
            for _, c in ipairs(self._cached_iceboxes) do
                if not c:IsValid() then
                    cache_valid = false
                    break
                end
            end
        end
        if cache_valid and self._cached_chests then
            for _, c in ipairs(self._cached_chests) do
                if not c:IsValid() then
                    cache_valid = false
                    break
                end
            end
        end
        if cache_valid then
            return self._iceboxes_full, self._chests_full
        end
        
        _dbg("[容量] 缓存容器失效，强制刷新")
    end
    self._cap_cache_time = now

    local iceboxes = self:_GetIceboxes()
    local chests = self:_GetChests()

    self._cached_iceboxes = iceboxes
    self._cached_chests = chests

    self._iceboxes_full = true
    for _, c in ipairs(iceboxes) do
        if InvUtil.ContainerHasSpace(c) then
            self._iceboxes_full = false
            break
        end
    end

    self._chests_full = true
    for _, c in ipairs(chests) do
        if InvUtil.ContainerHasSpace(c) then
            self._chests_full = false
            break
        end
    end

    if self._iceboxes_full ~= self._prev_ib_full or self._chests_full ~= self._prev_ch_full then
        self._prev_ib_full = self._iceboxes_full
        self._prev_ch_full = self._chests_full
        _dbg(string.format("[容量] 冰箱满=%s(%d个), 箱子满=%s(%d个)",
            tostring(self._iceboxes_full), #iceboxes,
            tostring(self._chests_full), #chests))
    end

    return self._iceboxes_full, self._chests_full
end





function NPCCollectBehavior:_FindGroundItem()
    local center = self:_GetCenter()
    if not center then return nil end
    local ib_full, ch_full = self:_RefreshContainerCapacity()
    if ib_full and ch_full then return nil end  

    
    local now = GetTime()
    for item, expire in pairs(self._unreachable_items) do
        if not item:IsValid() or now >= expire then
            self._unreachable_items[item] = nil
        end
    end

    
    local unreachable = self._unreachable_items
    local base_skip = (ib_full or ch_full)
        and function(e, i) return _SkipNoStorage(e, i, ib_full, ch_full) end
        or  _SkipUnwantedItem
    local skip_fn = function(e, i)
        if unreachable[e] then return true end
        return base_skip(e, i)
    end

    local item = StructureUtil.FindGroundItemInRadius(center, self.inst, self:_ScanRadius(), skip_fn)
    
    if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
        if item then
            local ix, _, iz = item.Transform:GetWorldPosition()
            print("[种植调试] CollectBehavior._FindGroundItem: 发现物品", item.prefab, 
                  string.format("位置(%.1f, %.1f)", ix, iz))
        end
    end
    if DEBUG_BEHAVIOR then
        if item then
            print("[NPC_DEBUG] _FindGroundItem - found:", item.prefab,
                  "backpack=", tostring(item:HasTag("backpack")),
                  "_inventoryitem=", tostring(item:HasTag("_inventoryitem")),
                  "container=", tostring(item.components.container ~= nil),
                  "chest=", tostring(item:HasTag("chest")),
                  "fridge=", tostring(item:HasTag("fridge")))
        else
            print("[NPC_DEBUG] _FindGroundItem - no item found, ib_full=", tostring(ib_full), "ch_full=", tostring(ch_full))
        end
    end
    return item
end






function NPCCollectBehavior:_FindNextStorageTarget()
    local inst = self.inst
    local inv  = inst.components.inventory
    if not inv then return nil end
    if DEBUG_BEHAVIOR then
        local iceboxes = self:_GetIceboxes()
        local chests = self:_GetChests()
        local ib_strs, ch_strs = {}, {}
        for _, c in ipairs(iceboxes) do table.insert(ib_strs, (c.prefab or "?") .. "(" .. tostring(c) .. ")") end
        for _, c in ipairs(chests) do table.insert(ch_strs, (c.prefab or "?") .. "(" .. tostring(c) .. ")") end
        print("[NPC_DEBUG] _FindNextStorageTarget - iceboxes:[", table.concat(ib_strs, ", "), "] chests:[", table.concat(ch_strs, ", "), "]")
    end

    
    local failed_map = self._failed_containers
    local function _FilterFailed(containers)
        if not failed_map or not next(failed_map) then return containers end
        local now = GetTime()
        local filtered = {}
        for _, c in ipairs(containers) do
            local expire = failed_map[c]
            if not expire or now >= expire then
                failed_map[c] = nil  
                table.insert(filtered, c)
            end
        end
        return #filtered > 0 and filtered or {}
    end

    local has_icebox, has_chest = false, false
    local icebox_prefabs, chest_prefabs = {}, {}
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item then
            local cat = ItemClassify.GetCategory(item, inst)
            if cat == "icebox" then
                
                if InvUtil.IsIceboxBlacklisted(inst, item.prefab) then
                    has_chest = true
                    chest_prefabs[item.prefab] = true
                else
                    has_icebox = true
                    icebox_prefabs[item.prefab] = true
                end
            elseif cat == "chest" then
                has_chest = true
                chest_prefabs[item.prefab] = true
            elseif item._npc_collect_rehome then
                
                has_chest = true
                chest_prefabs[item.prefab] = true
            end
        end
    end

    if has_icebox then
        local best = InvUtil.FindBestContainer(icebox_prefabs, _FilterFailed(self:_GetIceboxes()))
        if best then return best end
    end

    if has_icebox or has_chest then
        local all_prefabs = {}
        for k in pairs(icebox_prefabs) do all_prefabs[k] = true end
        for k in pairs(chest_prefabs) do all_prefabs[k] = true end
        local best = InvUtil.FindBestContainer(all_prefabs, _FilterFailed(self:_GetChests()))
        if best then return best end
    end

    local center = self:_GetCenter()
    if center then
        -- 兜底扫描半径必须受整理范围约束，避免范围内箱子满后跑去范围外存放
        local fallback_radius = math.min(NEARBY_CONTAINER_RADIUS, self:_ScanRadius())
        if has_icebox then
            local nearby_iceboxes = StructureUtil.FindNearbyIceboxes(center, self.inst, fallback_radius)
            if #nearby_iceboxes > 0 then
                local best = InvUtil.FindBestContainer(icebox_prefabs, _FilterFailed(nearby_iceboxes))
                if best then return best end
            end
        end
        if has_icebox or has_chest then
            local all_prefabs = {}
            for k in pairs(icebox_prefabs) do all_prefabs[k] = true end
            for k in pairs(chest_prefabs) do all_prefabs[k] = true end
            local nearby_chests = StructureUtil.FindNearbyChests(center, self.inst, fallback_radius)
            if #nearby_chests > 0 then
                local best = InvUtil.FindBestContainer(all_prefabs, _FilterFailed(nearby_chests))
                if best then return best end
            end
        end
    end

    return nil
end





function NPCCollectBehavior:_StartStore()
    local inst = self.inst

    if not self:_HasStorableItems(inst) then
        self.status = FAILED
        return
    end

    local target = self:_FindNextStorageTarget()
    if target then
        self._target_container = target
        self._phase = "walk_to_container"
        inst.components.locomotor:GoToPoint(target:GetPosition(), nil, true)
        self.status = RUNNING
    else
        self._store_consecutive_fails = (self._store_consecutive_fails or 0) + 1
        _dbg(string.format("[存储] 无可用容器, 连续失败=%d", self._store_consecutive_fails))
        
        self:_SayChestsFull()
        local cats = ItemClassify.CategorizeInventory(inst)
        InvUtil.HandleGroundAndDelete(inst, cats.ground, cats.delete)
        self.status = FAILED
    end
end


function NPCCollectBehavior:_SayChestsFull()
    local now = GetTime()
    if now - (self._last_chests_full_say or 0) < CHESTS_FULL_SAY_INTERVAL then return end
    self._last_chests_full_say = now
    local inst = self.inst
    if inst.components.talker then
        local ok, NPC_SPEECH = pcall(require, "npc_speech")
        if ok and NPC_SPEECH and NPC_SPEECH.CHESTS_FULL then
            local line = NPC_SPEECH.GetLine(NPC_SPEECH.CHESTS_FULL, inst.npc_character_type)
            if line then
                inst.components.talker:Say(line)
            end
        end
    end
end






function NPCCollectBehavior:_TrySayCollectWork(scene)
    local inst = self.inst
    if not inst or not inst.components or not inst.components.talker then return end
    if inst._is_wes then return end
    if not inst._is_winona then return end

    local now = GetTime()
    if inst._collect_work_say_cd and now < inst._collect_work_say_cd then
        return
    end
    inst._collect_work_say_cd = now + COLLECT_WORK_SAY_COOLDOWN

    local chance = math.max(0, math.min(1, COLLECT_WORK_SAY_CHANCE))
    if math.random() > chance then
        return
    end

    local ok, NPC_SPEECH = pcall(require, "npc_speech")
    if not ok or not NPC_SPEECH then return end
    local pool = nil
    if scene == "ground" then
        pool = NPC_SPEECH.CLEAN_GROUND
    elseif scene == "organize" then
        pool = NPC_SPEECH.ORGANIZE_CHEST
    end
    pool = pool or NPC_SPEECH.CLEAN_WORK
    if not pool then return end
    local line = NPC_SPEECH.GetLine(pool, inst.npc_character_type)
    if line then
        inst.components.talker:Say(line)
    end
end








function NPCCollectBehavior:_ResetOrganize(had_failure)
    self._organize_queue       = nil
    self._organize_current     = nil
    self._organize_substep     = nil
    self._organize_walk_target = nil
    self._organize_ctx         = nil
    self._trip_delivery_index  = nil
    self._store_consecutive_fails = 0
    self._failed_containers = {}
    if had_failure then
        self._organize_consecutive_fails = (self._organize_consecutive_fails or 0) + 1
        local organize_interval = self:_OrganizeInterval()
        
        local extra = organize_interval * math.min(self._organize_consecutive_fails, 1)
        self._last_organize_check = GetTime() + extra
        _dbg(string.format("[整理] 有失败, 连续失败=%d, 下次冷却 %.0fs",
            self._organize_consecutive_fails, organize_interval + extra))
    else
        self._organize_consecutive_fails = 0
        self._last_organize_check = GetTime()
    end
end



function NPCCollectBehavior:_PopNextOrganizeAction()
    
    if ContainerCleaner.IsPlanExpired(self._organize_ctx) then
        _dbg("[整理] 规划已过期, 清空行动队列")
        self:_ResetOrganize(true)
        self.status = FAILED
        return
    end

    local queue = self._organize_queue
    if not queue or #queue == 0 then
        _dbg("[整理] 行动队列已空, 整理完成")
        self:_ResetOrganize()
        if self:_HasStorableItems(self.inst) then
            self:_StartStore()
        else
            self.status = FAILED
        end
        return
    end

    local action = table.remove(queue, 1)
    self._organize_current = action
    _dbg(string.format("[整理] 弹出行动: type=%s, 剩余=%d", tostring(action.type), #queue))

    if action.type == "clean" then
        
        self._organize_substep = "clean"
        self._organize_walk_target = action.target
    elseif action.type == "move" then
        
        self._organize_substep = "take"
        self._organize_walk_target = action.src
    elseif action.type == "trip" then
        
        self._organize_substep = "take"
        self._organize_walk_target = action.src
    else
        _dbg("[整理] 未知行动类型: " .. tostring(action.type))
        self:_PopNextOrganizeAction()
        return
    end

    local target = self._organize_walk_target
    if not target or not target:IsValid() then
        _dbg("[整理] 目标容器无效, 跳过")
        self:_PopNextOrganizeAction()
        return
    end

    self._phase = "organize_walk"
    self._walk_start_time = nil
    self.inst.components.locomotor:GoToPoint(target:GetPosition(), nil, true)
    self.status = RUNNING
end









function NPCCollectBehavior:_PlanConsolidation(containers)
    if not containers or #containers < 2 then return nil end

    
    local item_map = {}       
    local container_free = {} 
    local container_num_slots = {} 

    for _, c in ipairs(containers) do
        if c:IsValid() and c.components.container then
            local cont = c.components.container
            local free = 0
            for i = 1, cont:GetNumSlots() do
                local item = cont:GetItemInSlot(i)
                if item and item:IsValid() then
                    local p = item.prefab
                    local stackable = item.components.stackable
                    local current  = stackable and stackable:StackSize() or 1
                    local maxsize  = stackable and stackable.maxsize     or 1

                    if not item_map[p] then item_map[p] = {} end
                    
                    local entry = nil
                    for _, e in ipairs(item_map[p]) do
                        if e.container == c then entry = e; break end
                    end
                    if not entry then
                        entry = {container = c, total = 0, stacks = 0, maxsize = maxsize, partial = 0}
                        table.insert(item_map[p], entry)
                    end
                    entry.total   = entry.total + current
                    entry.stacks  = entry.stacks + 1
                    if current < maxsize then
                        entry.partial = entry.partial + (maxsize - current)
                    end
                else
                    free = free + 1
                end
            end
            container_num_slots[c] = cont:GetNumSlots()
            container_free[c] = free
        end
    end

    
    
    local consolidation_primary = {} 
    for prefab_key, locations in pairs(item_map) do
        if #locations >= 2 then
            local best = locations[1]
            for _, loc in ipairs(locations) do
                if loc.total > best.total then best = loc end
            end
            consolidation_primary[prefab_key] = best.container
        end
    end
    
    
    local total_stacks = {}
    for prefab_key, locations in pairs(item_map) do
        local s = 0
        for _, loc in ipairs(locations) do s = s + loc.stacks end
        total_stacks[prefab_key] = s
    end

    
    
    
    
    local function calc_evictable(target_prefab, container)
        local target_total = total_stacks[target_prefab] or 0
        local evictable = 0
        for other_prefab, other_locs in pairs(item_map) do
            if other_prefab ~= target_prefab
               and consolidation_primary[other_prefab] ~= container
               and (total_stacks[other_prefab] or 0) < target_total then
                for _, loc in ipairs(other_locs) do
                    if loc.container == container then
                        evictable = evictable + loc.stacks
                        break
                    end
                end
            end
        end
        return evictable
    end

    
    local inv = self.inst.components.inventory
    local npc_free = 0
    if inv then
        for i = 1, (inv.maxslots or 0) do
            if not inv:GetItemInSlot(i) then npc_free = npc_free + 1 end
        end
    end
    if npc_free <= 0 then return nil end

    
    local moves = {} 
    local eviction_claimed = {} 

    for prefab, locations in pairs(item_map) do
        if #locations >= 2 then
            table.sort(locations, function(a, b) return a.total > b.total end)

            local primary = locations[1]
            local p_free = container_free[primary.container] or 0
            
            local p_evictable = eviction_claimed[primary.container] and 0
                                or calc_evictable(prefab, primary.container)
            local capacity = primary.partial
                           + (p_free + p_evictable) * primary.maxsize
            _dbg(string.format("[合并] %s: primary=%s, free=%d, evictable=%d, capacity=%d",
                prefab, tostring(primary.container), p_free, p_evictable, capacity))

            for i = 2, #locations do
                local source = locations[i]
                if npc_free <= 0 then break end

                if capacity <= 0 then
                    
                    primary  = source
                    p_free = container_free[primary.container] or 0
                    p_evictable = eviction_claimed[primary.container] and 0
                                  or calc_evictable(prefab, primary.container)
                    capacity = primary.partial
                             + (p_free + p_evictable) * primary.maxsize
                    _dbg(string.format("[合并] %s: 切换primary=%s, free=%d, evictable=%d, capacity=%d",
                        prefab, tostring(primary.container), p_free, p_evictable, capacity))
                end

            if capacity > 0 and source ~= primary then
                    local movable = math.min(source.total, capacity)
                    if movable > 0 then
                        local stk = math.min(source.stacks,
                                             math.ceil(movable / primary.maxsize),
                                             npc_free)
                        if stk > 0 then
                            
                            local free_cap = primary.partial + p_free * primary.maxsize
                            local needs_eviction = movable > free_cap
                            local safe_evict = nil
                            if needs_eviction then
                                eviction_claimed[primary.container] = true
                                safe_evict = {}
                                local target_total = total_stacks[prefab] or 0
                                for p2, locs2 in pairs(item_map) do
                                    if p2 ~= prefab
                                       and consolidation_primary[p2] ~= primary.container
                                       and (total_stacks[p2] or 0) < target_total then
                                        for _, loc in ipairs(locs2) do
                                            if loc.container == primary.container then
                                                safe_evict[p2] = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            table.insert(moves, {
                                src    = source.container,
                                dst    = primary.container,
                                prefab = prefab,
                                stacks = stk,
                                safe_evict = safe_evict,
                            })
                            npc_free = npc_free - stk
                            capacity = capacity - movable
                            
                            p_free = math.max(0, p_free - stk)
                            container_free[primary.container] = p_free
                            _dbg(string.format("[合并] 规划: %s x%d stacks 从 %s → %s%s",
                                prefab, stk, tostring(source.container), tostring(primary.container),
                                needs_eviction and " (需驱逐)" or ""))
                        end
                    end
                end
            end
        end
    end

    if #moves == 0 then return nil end

    
    local trips = {}
    for _, m in ipairs(moves) do
        local trip = nil
        for _, t in ipairs(trips) do
            if t.src == m.src then trip = t; break end
        end
        if not trip then
            trip = {type = "trip", src = m.src, consolidation = true, deliveries = {}}
            table.insert(trips, trip)
        end
        local delivery = nil
        for _, d in ipairs(trip.deliveries) do
            if d.dst == m.dst then delivery = d; break end
        end
        if not delivery then
            delivery = {dst = m.dst, items = {}, safe_evict = nil}
            table.insert(trip.deliveries, delivery)
        end
        delivery.items[m.prefab] = (delivery.items[m.prefab] or 0) + m.stacks
        if m.safe_evict then
            if not delivery.safe_evict then delivery.safe_evict = {} end
            for k in pairs(m.safe_evict) do delivery.safe_evict[k] = true end
        end
    end

    _dbg(string.format("[合并] 规划完成, %d 个 TRIP 行动", #trips))
    return trips
end



function NPCCollectBehavior:_TryStartOrganize()
    if self.inst ~= nil and self.inst._collect_organize_disabled == true then
        _dbg("[整理] 归类物品已关闭，跳过容器整理")
        return false
    end

    local now = GetTime()
    local organize_interval = self:_OrganizeInterval()
    local cd_remaining = organize_interval - (now - self._last_organize_check)
    if cd_remaining > 0 then
        _dbg(string.format("[整理] 冷却中, 剩余 %.1fs", cd_remaining))
        return false
    end
    self._last_organize_check = now

    local iceboxes = self:_GetIceboxes()
    local chests   = self:_GetChests()
    if not ContainerCleaner.NeedsWork(iceboxes, chests) then
        _dbg(string.format("[整理] NeedsWork=false (iceboxes=%d, chests=%d), 无需整理",
            #iceboxes, #chests))
        return false
    end

    _dbg(string.format("[整理] NeedsWork=true, 开始规划 (iceboxes=%d, chests=%d)",
        #iceboxes, #chests))

    local queue = ContainerCleaner.PlanOrganize(iceboxes, chests)
    if not queue or #queue == 0 then
        
        _dbg("[整理] PlanOrganize 为空, 尝试跨箱合并...")
        queue = self:_PlanConsolidation(chests)
        if not queue or #queue == 0 then
            queue = self:_PlanConsolidation(iceboxes)
        end
        if not queue or #queue == 0 then
            _dbg("[整理] 规划结果为空, 跳过")
            
            self._last_organize_check = now + organize_interval
            return false
        end
    end

    _dbg(string.format("[整理] 规划完成, actions=%d", #queue))
    self._organize_queue = queue
    self._organize_ctx = ContainerCleaner.CreateOrganizeContext()
    self:_PopNextOrganizeAction()
    return self.status == RUNNING
end





function NPCCollectBehavior:Visit()
    local inst = self.inst

    
    if not self._debug_visit_logged then
        self._debug_visit_logged = true
        FarmLog("CollectBehavior:Visit() 首次进入, phase=" .. tostring(self._phase))
    end

    if inst._is_ghost_mode then
        self.status = FAILED
        return
    end

    if inst._collect_organize_disabled == true and self._organize_queue ~= nil then
        _dbg("[整理] 归类物品关闭，终止当前整理流程")
        if inst.components.locomotor ~= nil then
            inst.components.locomotor:Stop()
        end
        self:_ResetOrganize(false)
        self.status = FAILED
        return
    end

    local approach_sq   = self:_ApproachDistSq()
    local container_sq  = self:_ContainerApproachDistSq()

    
    if self.status == RUNNING then

        
        if DEBUG_BEHAVIOR and self._phase then
            
            if self._phase ~= self._last_debug_phase then
                self._last_debug_phase = self._phase
                print("[NPC_DEBUG] Visit - phase:", self._phase,
                      "target_item=", self._target_item and (self._target_item.prefab or "?") or "nil",
                      "target_container=", self._target_container and (self._target_container.prefab or "?") or "nil")
            end
        end
        if self._phase == "walk_to_item" then
            local item = self._target_item
            if not item or not item:IsValid() or item:IsInLimbo() then
                self._walk_start_time = nil
                self._target_item = nil
                if self:_HasStorableItems(inst) then
                    self:_StartStore()
                else
                    self.status = FAILED
                end
                return
            end
            local distsq = inst:GetDistanceSqToPoint(item:GetPosition())
            if distsq <= approach_sq then
                self._walk_start_time = nil
                inst.components.locomotor:Stop()
                local inv_comp = inst.components.inventory
                if inv_comp and inv_comp:IsFull() then
                    _dbg("[收集] 到达物品但背包已满, 放弃捡取")
                    self._target_item = nil
                    if self:_HasStorableItems(inst) then
                        self:_StartStore()
                    else
                        self.status = FAILED
                    end
                    return
                end
                self._phase = "picking_up"
                inst.bufferedaction = BufferedAction(inst, item, ACTIONS.PICKUP)
                inst.sg:GoToState("dopickup")
                return
            end
            local now = GetTime()
            if not self._walk_start_time then
                self._walk_start_time = now
                self._walk_start_distsq = distsq
            elseif now - self._walk_start_time >= WALK_STUCK_TIMEOUT then
                
                if distsq >= self._walk_start_distsq - 9 then
                    _dbg(string.format("[收集] 行走卡住 %.0f秒无进展, 标记 %s 不可达",
                        now - self._walk_start_time, tostring(item.prefab)))
                    self._unreachable_items[item] = now + UNREACHABLE_EXPIRE
                    self._walk_start_time = nil
                    self._target_item = nil
                    inst.components.locomotor:Stop()
                    local next_item = self:_FindGroundItem()
                    if next_item then
                        self._target_item = next_item
                        self._phase = "walk_to_item"
                        inst.components.locomotor:GoToPoint(next_item:GetPosition(), nil, true)
                        return
                    end
                    if self:_HasStorableItems(inst) then
                        self:_StartStore()
                    else
                        self.status = FAILED
                    end
                    return
                else
                    self._walk_start_time = now
                    self._walk_start_distsq = distsq
                end
            end
            return
        end

        
        if self._phase == "picking_up" then
            if inst.sg and not inst.sg:HasStateTag("busy") then
                self._target_item = nil
                self._failed_containers = {}
                self._store_consecutive_fails = 0
                if not InvUtil.HasInventorySpace(inst) then
                    if self:_HasStorableItems(inst) then
                        self:_StartStore()
                    else
                        self.status = FAILED
                    end
                    return
                end
                local next_item = self:_FindGroundItem()
                if next_item then
                    self._target_item = next_item
                    self._phase = "walk_to_item"
                    inst.components.locomotor:GoToPoint(next_item:GetPosition(), nil, true)
                    return
                end
                if self:_HasStorableItems(inst) then
                    self:_StartStore()
                else
                    self.status = FAILED
                end
                return
            end
            return
        end

        
        if self._phase == "walk_to_container" then
            local container = self._target_container
            if not container or not container:IsValid() then
                self._walk_start_time = nil
                self._target_container = nil
                if self:_HasStorableItems(inst) then
                    self:_StartStore()
                else
                    self.status = FAILED
                end
                return
            end
            local cdistsq = inst:GetDistanceSqToPoint(container:GetPosition())
            local now = GetTime()
            if not self._walk_start_time then
                self._walk_start_time = now
                self._walk_start_distsq = cdistsq
            elseif now - self._walk_start_time >= WALK_STUCK_TIMEOUT then
                if cdistsq >= self._walk_start_distsq - 9 then
                    _dbg(string.format("[收集] 走向容器卡住 %.0f秒无进展, 跳过 %s",
                        now - self._walk_start_time, tostring(container)))
                    self._failed_containers[container] = GetTime() + FAILED_CONTAINER_EXPIRE
                    self._walk_start_time = nil
                    self._target_container = nil
                    inst.components.locomotor:Stop()
                    if self:_HasStorableItems(inst) then
                        self:_StartStore()
                    else
                        self.status = FAILED
                    end
                    return
                else
                    self._walk_start_time = now
                    self._walk_start_distsq = cdistsq
                end
            end
            if cdistsq <= container_sq then
                inst.components.locomotor:Stop()
                self._phase = "storing"

                local cont = container.components and container.components.container
                if not cont then
                    print("[存储] 容器组件无效, 跳过: " .. tostring(container))
                    self._target_container = nil
                    if self:_HasStorableItems(inst) then
                        self:_StartStore()
                    else
                        self.status = FAILED
                    end
                    return
                end

                
                
                self._pre_store_count = self:_CountStorableItems(inst)
                if DEBUG_BEHAVIOR then
                    print("[NPC_DEBUG] storing - access_container:", container.prefab or "?",
                          "tags: chest=", tostring(container:HasTag("chest")),
                          "fridge=", tostring(container:HasTag("fridge")),
                          "backpack=", tostring(container:HasTag("backpack")),
                          "_npc_structure=", tostring(container:HasTag("_npc_structure")))
                end
                inst.sg:GoToState("access_container", {
                    container = container,
                    action_fn = function(npc, c)

					if not c or not c:IsValid() then
                            print("[存储] 回调时容器已无效")
                            return
                        end
                        local cont_comp = c.components and c.components.container
                        if not cont_comp then
                            print("[存储] 回调时容器组件已无效")
                            return
                        end
                        InvUtil.SmartStoreInSingleContainer(npc, c)
                        self:_StorePendingRehomeToContainer(npc, c)
                    end,
                })
                return
            end
            return
        end

        
        if self._phase == "storing" then
            if inst.sg and not inst.sg:HasStateTag("busy") then
                local prev_container = self._target_container
                self._target_container = nil
                self._cap_cache_time = nil  
                if self:_HasStorableItems(inst) then
                    
                    local post_count = self:_CountStorableItems(inst)
                    if prev_container and self._pre_store_count
                       and post_count >= self._pre_store_count then
                        self._failed_containers[prev_container] = GetTime() + FAILED_CONTAINER_EXPIRE
                        _dbg(string.format("[存储] 容器 %s 存放无进展, 加入失败记录(%.0fs过期)",
                            tostring(prev_container), FAILED_CONTAINER_EXPIRE))
                    else
                        self._failed_containers = {}
                        self._store_consecutive_fails = 0
                    
                    end
                    self:_StartStore()
                else
                    if not self:_TryStartOrganize() then
                        self.status = FAILED
                    end
                end
                return
            end
            return
        end

        
        if self._phase == "organize_walk" then
            local target = self._organize_walk_target
            if not target or not target:IsValid() then
                self:_PopNextOrganizeAction()
                return
            end
            local distsq = inst:GetDistanceSqToPoint(target:GetPosition())
            
            local now = GetTime()
            if not self._walk_start_time then
                self._walk_start_time = now
                self._walk_start_distsq = distsq
            elseif now - self._walk_start_time >= WALK_STUCK_TIMEOUT then
                if distsq >= self._walk_start_distsq - 9 then
                    _dbg(string.format("[整理] 走向容器卡住, 跳过 %s", tostring(target)))
                    self._walk_start_time = nil
                    if ContainerCleaner.RecordFailure(self._organize_ctx) then
                        _dbg("[整理] 连续失败过多, 中止整理")
                        self:_ResetOrganize(true)
                        self.status = FAILED
                        return
                    end
                    self:_PopNextOrganizeAction()
                    return
                else
                    self._walk_start_time = now
                    self._walk_start_distsq = distsq
                end
            end
            if distsq <= ORGANIZE_APPROACH_DISTSQ then
                inst.components.locomotor:Stop()
                self._walk_start_time = nil
                self._phase = "organize_access"
                local substep = self._organize_substep
                local action  = self._organize_current

                if substep == "clean" then
                    local valid, reason = ContainerCleaner.ValidateCleanAction(target)
                    if not valid then
                        _dbg("[整理] CLEAN跳过: " .. (reason or "unknown"))
                        if ContainerCleaner.RecordFailure(self._organize_ctx) then
                            self:_ResetOrganize(true)
                            self.status = FAILED
                            return
                        end
                        self:_PopNextOrganizeAction()
                        return
                    end
                    ContainerCleaner.RecordSuccess(self._organize_ctx)
                    _dbg("[整理] CLEAN " .. tostring(target))
                    if DEBUG_BEHAVIOR then
                        print("[NPC_DEBUG] organize_clean - access_container:", target.prefab or "?",
                              "chest=", tostring(target:HasTag("chest")),
                              "fridge=", tostring(target:HasTag("fridge")))
                    end
                    inst.sg:GoToState("access_container", {
                        container = target,
                        action_fn = function(npc, c)
                            local n1 = ContainerCleaner.CleanContainer(c)
                            local n2 = ContainerCleaner.ConsolidateSingle(c)
                            _dbg(string.format("[整理]   cleaned %d, merged %d in %s", n1, n2, tostring(c)))
                        end,
                    })

                elseif substep == "take" then
                    
                    local items_to_take
                    if action.type == "trip" then
                        items_to_take = {}
                        for _, delivery in ipairs(action.deliveries or {}) do
                            for prefab, count in pairs(delivery.items or {}) do
                                items_to_take[prefab] = (items_to_take[prefab] or 0) + count
                            end
                        end
                    else
                        items_to_take = action.items or {}
                    end
                    local is_consolidation = action.consolidation
                    if not is_consolidation then
                        local valid, reason = ContainerCleaner.ValidateTakeAction(target)
                        if not valid then
                            _dbg("[整理] TAKE跳过: " .. (reason or "unknown"))
                            if ContainerCleaner.RecordFailure(self._organize_ctx) then
                                self:_ResetOrganize(true)
                                self.status = FAILED
                                return
                            end
                            self:_PopNextOrganizeAction()
                            return
                        end
                        
                        local has_any_item = false
                        for prefab, _ in pairs(items_to_take) do
                            local _, prefab_reason = ContainerCleaner.ValidateTakeAction(target, prefab)
                            if not prefab_reason then
                                has_any_item = true
                                break
                            end
                        end
                        if not has_any_item then
                            _dbg("[整理] TAKE跳过: 计划物品均已不在容器中")
                            if ContainerCleaner.RecordFailure(self._organize_ctx) then
                                self:_ResetOrganize(true)
                                self.status = FAILED
                                return
                            end
                            self:_PopNextOrganizeAction()
                            return
                        end
                    end
                    ContainerCleaner.RecordSuccess(self._organize_ctx)
                    _dbg("[整理] TAKE from " .. tostring(target))
                    if DEBUG_BEHAVIOR then
                        print("[NPC_DEBUG] organize_take - access_container:", target.prefab or "?",
                              "chest=", tostring(target:HasTag("chest")),
                              "fridge=", tostring(target:HasTag("fridge")))
                    end
                    local cached_items = items_to_take
                    inst.sg:GoToState("access_container", {
                        container = target,
                        action_fn = function(npc, c)
                            if not c or not c:IsValid() or not c.components.container then return end
                            local cont = c.components.container
                            local inv  = npc.components.inventory
                            if not inv then return end
                            local took = {}
                            for i = 1, cont:GetNumSlots() do
                                if not InvUtil.HasInventorySpace(npc) then break end
                                local slot_item = cont:GetItemInSlot(i)
                                if slot_item and slot_item:IsValid() then
                                    local p = slot_item.prefab
                                    if cached_items[p] and (cached_items[p] > (took[p] or 0)) then
                                        local taken = cont:RemoveItemBySlot(i)
                                        if taken and taken:IsValid() then
                                            taken.prevcontainer = nil
                                            taken.prevslot = nil
                                            inv:GiveItem(taken)
                                            took[p] = (took[p] or 0) + 1
                                        end
                                    end
                                end
                            end
                            local strs = {}
                            for p, n in pairs(took) do table.insert(strs, p .. "x" .. n) end
                            _dbg("[整理]   took: " .. (#strs > 0 and table.concat(strs, ", ") or "NOTHING"))
                        end,
                    })

                elseif substep == "put" then
                    
                    
                    if not target or not target:IsValid() or not target.components.container then
                        _dbg("[整理] PUT跳过: 容器实体无效")
                        if ContainerCleaner.RecordFailure(self._organize_ctx) then
                            self:_ResetOrganize(true)
                            self.status = FAILED
                            return
                        end
                        self:_PopNextOrganizeAction()
                        return
                    end
                    ContainerCleaner.RecordSuccess(self._organize_ctx)
                    _dbg("[整理] PUT into " .. tostring(target))
                    if DEBUG_BEHAVIOR then
                        print("[NPC_DEBUG] organize_put - access_container:", target.prefab or "?",
                              "chest=", tostring(target:HasTag("chest")),
                              "fridge=", tostring(target:HasTag("fridge")))
                    end
                    
                    local move_action = self._organize_current
                    local current_delivery_index = self._trip_delivery_index
                    inst.sg:GoToState("access_container", {
                        container = target,
                        action_fn = function(npc, c)
                            if not c or not c:IsValid() or not c.components.container then
                                _dbg("[整理]   put ABORT: container invalid")
                                return
                            end
                            local cont = c.components.container
                            local inv  = npc.components.inventory
                            if not inv then
                                _dbg("[整理]   put ABORT: no inventory")
                                return
                            end
                            
                            local items_to_put
                            local safe_evict_set = nil  
                            if move_action and move_action.type == "trip" then
                                local delivery = move_action.deliveries
                                    and move_action.deliveries[current_delivery_index]
                                items_to_put = delivery and delivery.items or {}
                                
                                safe_evict_set = delivery and delivery.safe_evict or nil
                                _dbg(string.format("[整理]   PUT delivery_idx=%s, delivery=%s",
                                    tostring(current_delivery_index),
                                    delivery and "found" or "NIL"))
                            else
                                items_to_put = move_action and move_action.items or {}
                            end
                            
                            local itp_strs = {}
                            for p, n in pairs(items_to_put) do table.insert(itp_strs, p.."="..n) end
                            _dbg("[整理]   items_to_put: " .. (#itp_strs > 0 and table.concat(itp_strs, ",") or "EMPTY"))
                            
                            local inv_dbg = {}
                            for ii = 1, (inv.maxslots or 0) do
                                local it = inv:GetItemInSlot(ii)
                                if it then
                                    local sz = it.components.stackable and it.components.stackable:StackSize() or 1
                                    table.insert(inv_dbg, string.format("[%d]%sx%d", ii, it.prefab, sz))
                                end
                            end
                            _dbg("[整理]   NPC背包(maxslots=" .. tostring(inv.maxslots) .. "): " .. (#inv_dbg > 0 and table.concat(inv_dbg, ", ") or "EMPTY"))
                            local put = {}
                            local put_count, evict_count = 0, 0
                            for i = inv.maxslots, 1, -1 do
                                local item = inv:GetItemInSlot(i)
                                if item and item:IsValid() then
                                    local need = (items_to_put[item.prefab] or 0) - (put[item.prefab] or 0)
                                    if need > 0 then
                                        local taken = inv:RemoveItem(item, true)  
                                        if taken then
                                            taken.prevcontainer = nil
                                            taken.prevslot = nil
                                            if cont:GiveItem(taken, nil, nil, false) then
                                                put[item.prefab] = (put[item.prefab] or 0) + 1
                                                put_count = put_count + 1
                                            else
                                                local placed = false
                                                for j = 1, cont:GetNumSlots() do
                                                    local slot_item = cont:GetItemInSlot(j)
                                                    if slot_item and slot_item:IsValid()
                                                       and slot_item.prefab ~= taken.prefab
                                                       and (not safe_evict_set or safe_evict_set[slot_item.prefab]) then
                                                        local evict_item = cont:RemoveItemBySlot(j)
                                                        if evict_item then
                                                            evict_item.prevcontainer = nil
                                                            evict_item.prevslot = nil
                                                            if cont:GiveItem(taken, nil, nil, false) then
                                                                _dbg(string.format("[整理]   evict %s, place %s%s",
                                                                    evict_item.prefab, taken.prefab,
                                                                    safe_evict_set and " (安全驱逐)" or ""))
                                                                evict_item._npc_collect_rehome = true
                                                                inv:GiveItem(evict_item)
                                                                placed = true
                                                                put[item.prefab] = (put[item.prefab] or 0) + 1
                                                                put_count = put_count + 1
                                                                evict_count = evict_count + 1
                                                            else
                                                                cont:GiveItem(evict_item, nil, nil, false)
                                                            end
                                                            break
                                                        end
                                                    end
                                                end
                                                if not placed and taken:IsValid() then
                                                    _dbg("[整理]   FAILED to place " .. taken.prefab)
                                                    inv:GiveItem(taken)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            local strs = {}
                            for p, n in pairs(put) do table.insert(strs, p .. "x" .. n) end
                            _dbg(string.format("[整理]   put %d, evicted %d: %s",
                                put_count, evict_count,
                                #strs > 0 and table.concat(strs, ", ") or "NOTHING"))
                        end,
                    })
                end
            end
            return
        end

        
        if self._phase == "organize_access" then
            if inst.sg and not inst.sg:HasStateTag("busy") then
                local action  = self._organize_current
                local substep = self._organize_substep

                if substep == "clean" then
                    _dbg("[整理] CLEAN完成, 弹出下一个行动")
                    self:_PopNextOrganizeAction()
                elseif substep == "take" then
                    _dbg("[整理] TAKE完成, 切换到PUT阶段")
                    if action.type == "trip" then
                        local deliveries = action.deliveries or {}
                        local idx = self._trip_delivery_index or 1
                        self._trip_delivery_index = idx  
                        if idx <= #deliveries then
                            local delivery = deliveries[idx]
                            _dbg(string.format("[整理] TRIP take→put 配送 %d/%d → %s",
                                idx, #deliveries, tostring(delivery.dst)))
                            
                            self._organize_substep = "put"
                            self._organize_walk_target = delivery.dst
                        else
                            self._trip_delivery_index = nil
                            self:_PopNextOrganizeAction()
                            return
                        end
                    else
                        self._organize_substep = "put"
                        self._organize_walk_target = action.dst
                    end
                    local next_target = self._organize_walk_target
                    if next_target and next_target:IsValid() then
                        self._phase = "organize_walk"
                        self._walk_start_time = nil
                        inst.components.locomotor:GoToPoint(next_target:GetPosition(), nil, true)
                    else
                        _dbg("[整理] PUT目标无效, 跳过")
                        self._trip_delivery_index = nil
                        self:_PopNextOrganizeAction()
                    end
                elseif substep == "put" then
                    _dbg("[整理] PUT完成")
                    if action.type == "trip" then
                        local deliveries = action.deliveries or {}
                        self._trip_delivery_index = (self._trip_delivery_index or 1) + 1
                        local idx = self._trip_delivery_index
                        if idx <= #deliveries then
                            local delivery = deliveries[idx]
                            _dbg(string.format("[整理] TRIP put→put 继续配送 %d/%d → %s",
                                idx, #deliveries, tostring(delivery.dst)))
                            self._organize_substep = "put"
                            self._organize_walk_target = delivery.dst
                            local next_target = delivery.dst
                            if next_target and next_target:IsValid() then
                                self._phase = "organize_walk"
                                self._walk_start_time = nil
                                inst.components.locomotor:GoToPoint(next_target:GetPosition(), nil, true)
                            else
                                self._trip_delivery_index = nil
                                self:_PopNextOrganizeAction()
                            end
                        else
                            self._trip_delivery_index = nil
                            self:_PopNextOrganizeAction()
                        end
                    else
                        self:_PopNextOrganizeAction()
                    end
                end
                return
            end
            return
        end

        return
    end

    

    if not InvUtil.HasInventorySpace(inst) and self:_HasStorableItems(inst) then
        if self._target_container and self._target_container:IsValid() then
            self._phase = "walk_to_container"
            inst.components.locomotor:GoToPoint(self._target_container:GetPosition(), nil, true)
            self.status = RUNNING
            return
        end
        self._target_container = nil
        self._target_item = nil
        self:_StartStore()
        return
    end

    if self._target_item and self._target_item:IsValid()
       and not self._target_item:IsInLimbo() then
        if self._unreachable_items[self._target_item] then
            self._target_item = nil
        else
            self._walk_start_time = nil
            self._phase = "walk_to_item"
            inst.components.locomotor:GoToPoint(self._target_item:GetPosition(), nil, true)
            self.status = RUNNING
            return
        end
    end
    self._target_item = nil

    if self._target_container and self._target_container:IsValid() then
        self._walk_start_time = nil
        self._phase = "walk_to_container"
        inst.components.locomotor:GoToPoint(self._target_container:GetPosition(), nil, true)
        self.status = RUNNING
        return
    end
    self._target_container = nil

    if self._organize_queue then
        if (self._phase == "organize_walk" or self._phase == "organize_access") then
            local target = self._organize_walk_target
            if target and target:IsValid() then
                _dbg("[整理] 被打断, 恢复走向 " .. tostring(target))
                self._phase = "organize_walk"
                self._walk_start_time = nil
                inst.components.locomotor:GoToPoint(target:GetPosition(), nil, true)
                self.status = RUNNING
                return
            end
        end
        _dbg("[整理] 恢复失败, 放弃当前整理流程")
        self:_ResetOrganize(true)
    end

    
    local now = GetTime()
    if now - self._last_scan < self:_ScanInterval() then
        self.status = FAILED
        return
    end
    self._last_scan = now

    if self:_HasStorableItems(inst) then
        local store_fails = self._store_consecutive_fails or 0
        if store_fails >= STORE_FAIL_THRESHOLD then
            
            
            self._store_consecutive_fails = 0
            _dbg(string.format("[存储] 连续失败 %d 次, 暂停存储尝试整理释放空间", store_fails))
            
        else
            self:_StartStore()
            return
        end
    else
        
        local inv_comp = inst.components.inventory
        if not inv_comp or inv_comp:IsFull() then
            _dbg("[收集] 背包已满, 跳过地面物品扫描")
            
        else
            local item = self:_FindGroundItem()
            if item then
                local ix, _, iz = item.Transform:GetWorldPosition()
                local center = self:_GetCenter()
                if center then
                    local dist_to_center = math.sqrt((ix - center.x)^2 + (iz - center.z)^2)
                    FarmLog("CollectBehavior: 发现地面物品 " .. tostring(item.prefab) .. 
                            ", 距中心=" .. string.format("%.1f", dist_to_center) .. "格")
                end
                self._target_item = item
                self._phase = "walk_to_item"
                inst.components.locomotor:GoToPoint(item:GetPosition(), nil, true)
                self:_TrySayCollectWork("ground")
                self.status = RUNNING
                return
            end
        end
    end

    _dbg("[整理] 空闲扫描, 尝试触发容器整理...")
    if self:_TryStartOrganize() then
        self:_TrySayCollectWork("organize")
        return
    end

    self.status = FAILED
end

return NPCCollectBehavior
