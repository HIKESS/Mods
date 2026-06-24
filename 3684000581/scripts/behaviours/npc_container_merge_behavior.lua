-- scripts/behaviours/npc_container_merge_behavior.lua
-- 跨容器堆叠合并行为：走近源容器 → 取出 1 组 → 走近目标容器 → 放入（并入未满堆叠）。
-- 每次合并周期只搬运「一个槽位上的一摞」（一组），多组需多周期。
-- 配置与 NPCCollectBehavior 一致：get_iceboxes_fn、get_chests_fn（由挂载方提供，例：_wes_iceboxes/_wes_chests）。
-- 依赖：npc_container_merge（规划）、InvUtil（空间/背包）、access_container 状态（sg_npc_common）。

local NPC_TUNING    = require "npc_tuning"
local InvUtil       = require "npc/npc_inventory_util"
local ContainerMerge = require "npc/npc_container_merge"

local function _merge_dbg(...)
    if NPC_TUNING.DEBUG_CONTAINER_MERGE or NPC_TUNING.DEBUG_BEHAVIOR then
        print(...)
    end
end

local WALK_STUCK_TIMEOUT = 8

NPCContainerMergeBehavior = Class(BehaviourNode, function(self, inst, config)
    BehaviourNode._ctor(self, "NPCContainerMergeBehavior")
    self.inst   = inst
    self.config = config or {}
    self._phase = "idle"
    self._last_scan = 0
    self._walk_start_time = nil
    self._walk_start_distsq = nil
    self._pending = nil 
end)

function NPCContainerMergeBehavior:DBString()
    return string.format("Merge (phase=%s)", tostring(self._phase))
end

function NPCContainerMergeBehavior:_ApproachDistSq()
    local d = self.config.approach_dist or 1.5
    return d * d
end

function NPCContainerMergeBehavior:_ScanInterval()
    return self.config.scan_interval or NPC_TUNING.CONTAINER_MERGE_INTERVAL or 10
end

function NPCContainerMergeBehavior:_GetIceboxes()
    if self.config.get_iceboxes_fn then
        return self.config.get_iceboxes_fn(self.inst) or {}
    end
    return {}
end

function NPCContainerMergeBehavior:_GetChests()
    if self.config.get_chests_fn then
        return self.config.get_chests_fn(self.inst) or {}
    end
    return {}
end

function NPCContainerMergeBehavior:_ClearWalkTrack()
    self._walk_start_time = nil
    self._walk_start_distsq = nil
end

function NPCContainerMergeBehavior:Visit()
    local inst = self.inst
    if inst._is_ghost_mode then
        self.status = FAILED
        return
    end

    local approach_sq = self:_ApproachDistSq()

    if self.status == RUNNING then
        if self._phase == "walk_to_src" then
            local src = self._pending and self._pending.src
            if not src or not src:IsValid() or not src.components.container then
                self:_ClearWalkTrack()
                self._pending = nil
                self._phase = "idle"
                self.status = FAILED
                return
            end
            local distsq = inst:GetDistanceSqToPoint(src:GetPosition())
            if distsq <= approach_sq then
                self:_ClearWalkTrack()
                inst.components.locomotor:Stop()
                self._phase = "taking"
                local slot = self._pending.slot
                local take_prefab = self._pending.prefab
                inst.sg:GoToState("access_container", {
                    container = src,
                    action_fn = function(npc, c)
                        if not c or not c:IsValid() or not c.components.container then return end
                        local cont = c.components.container
                        local inv = npc.components.inventory
                        if not inv then return end
                        local it = cont:GetItemInSlot(slot)
                        if not it or not it:IsValid() then
                            _merge_dbg(string.format(
                                "[Merge] take skip: slot %d empty or invalid (src=%s)",
                                slot, tostring(c.prefab)))
                            return
                        end
                        local taken = cont:RemoveItemBySlot(slot)
                        if taken then
                            taken.prevcontainer = nil
                            taken.prevslot = nil
                            if not inv:GiveItem(taken) then
                                _merge_dbg("[Merge] take WARN: GiveItem to NPC inv failed, dropping?", tostring(take_prefab))
                            end
                        end
                    end,
                })
                return
            end
            local now = GetTime()
            if not self._walk_start_time then
                self._walk_start_time = now
                self._walk_start_distsq = distsq
            elseif now - self._walk_start_time >= WALK_STUCK_TIMEOUT then
                if distsq >= self._walk_start_distsq - 9 then
                    _merge_dbg("[Merge] stuck walking to src, abort")
                    self:_ClearWalkTrack()
                    self._pending = nil
                    self._phase = "idle"
                    inst.components.locomotor:Stop()
                    self.status = FAILED
                    return
                end
                self._walk_start_time = now
                self._walk_start_distsq = distsq
            end
            return
        end

        if self._phase == "taking" then
            if inst.sg and not inst.sg:HasStateTag("busy") then
                
                
                local pf = self._pending and self._pending.prefab
                if not pf or not InvUtil.InventoryHasPrefab(inst, pf) then
                    _merge_dbg(string.format(
                        "[Merge] after take: no stack of prefab=%s in inventory (abort put phase)",
                        tostring(pf)))
                    self._pending = nil
                    self._phase = "idle"
                    self.status = FAILED
                    return
                end
                _merge_dbg(string.format(
                    "[Merge] after take OK: prefab=%s → walk to dst %s",
                    tostring(pf), tostring(self._pending.dst and self._pending.dst.prefab)))
                local dst = self._pending and self._pending.dst
                if not dst or not dst:IsValid() then
                    self._pending = nil
                    self._phase = "idle"
                    self.status = FAILED
                    return
                end
                self._phase = "walk_to_dst"
                inst.components.locomotor:GoToPoint(dst:GetPosition(), nil, true)
                return
            end
            return
        end

        if self._phase == "walk_to_dst" then
            local dst = self._pending and self._pending.dst
            if not dst or not dst:IsValid() or not dst.components.container then
                self:_ClearWalkTrack()
                self._pending = nil
                self._phase = "idle"
                self.status = FAILED
                return
            end
            local distsq = inst:GetDistanceSqToPoint(dst:GetPosition())
            if distsq <= approach_sq then
                self:_ClearWalkTrack()
                inst.components.locomotor:Stop()
                local prefab = self._pending.prefab
                self._phase = "putting"
                inst.sg:GoToState("access_container", {
                    container = dst,
                    action_fn = function(npc, c)
                        if not c or not c:IsValid() or not c.components.container then return end
                        local cont = c.components.container
                        local inv = npc.components.inventory
                        if not inv then return end
                        for i = inv.maxslots, 1, -1 do
                            local item = inv:GetItemInSlot(i)
                            if item and item:IsValid() and item.prefab == prefab then
                                local taken = inv:RemoveItem(item)
                                if taken then
                                    taken.prevcontainer = nil
                                    taken.prevslot = nil
                                    if cont:GiveItem(taken, nil, nil, false) then
                                        _merge_dbg(string.format(
                                            "[Merge] put OK: prefab=%s → dst=%s",
                                            prefab, tostring(c.prefab)))
                                    else
                                        if taken:IsValid() then
                                            inv:GiveItem(taken)
                                        end
                                        _merge_dbg(string.format(
                                            "[Merge] put FAIL: GiveItem rejected prefab=%s dst=%s full=%s",
                                            prefab, tostring(c.prefab), tostring(cont:IsFull())))
                                    end
                                end
                                break
                            end
                        end
                    end,
                })
                return
            end
            local now = GetTime()
            if not self._walk_start_time then
                self._walk_start_time = now
                self._walk_start_distsq = distsq
            elseif now - self._walk_start_time >= WALK_STUCK_TIMEOUT then
                if distsq >= self._walk_start_distsq - 9 then
                    _merge_dbg("[Merge] stuck walking to dst, abort (cargo may stay in inventory)")
                    self:_ClearWalkTrack()
                    self._pending = nil
                    self._phase = "idle"
                    inst.components.locomotor:Stop()
                    self.status = FAILED
                    return
                end
                self._walk_start_time = now
                self._walk_start_distsq = distsq
            end
            return
        end

        if self._phase == "putting" then
            if inst.sg and not inst.sg:HasStateTag("busy") then
                local pf = self._pending and self._pending.prefab
                if pf and InvUtil.InventoryHasPrefab(inst, pf) then
                    _merge_dbg(string.format(
                        "[Merge] after put: prefab=%s STILL in inventory (GiveItem likely failed last frame)",
                        tostring(pf)))
                end
                self._pending = nil
                self._phase = "idle"
                self.status = FAILED
                return
            end
            return
        end

        return
    end

    
    if self._phase == "walk_to_src" and self._pending and self._pending.src
       and self._pending.src:IsValid() then
        self:_ClearWalkTrack()
        inst.components.locomotor:GoToPoint(self._pending.src:GetPosition(), nil, true)
        self.status = RUNNING
        return
    end
    if self._phase == "walk_to_dst" and self._pending and self._pending.dst
       and self._pending.dst:IsValid() then
        self:_ClearWalkTrack()
        inst.components.locomotor:GoToPoint(self._pending.dst:GetPosition(), nil, true)
        self.status = RUNNING
        return
    end
    self._pending = nil
    self._phase = "idle"

    local now = GetTime()
    if now - self._last_scan < self:_ScanInterval() then
        self.status = FAILED
        return
    end
    self._last_scan = now

    if not InvUtil.HasInventorySpace(inst) then
        self.status = FAILED
        return
    end

    local move = ContainerMerge.FindNextMergeMove(
        self:_GetIceboxes(), self:_GetChests(), inst)
    if not move then
        self.status = FAILED
        return
    end

    _merge_dbg(string.format(
        "[Merge] plan: prefab=%s slot=%d src=%s dst=%s",
        tostring(move.prefab), move.slot, tostring(move.src and move.src.prefab),
        tostring(move.dst and move.dst.prefab)))

    self._pending = move
    self._phase = "walk_to_src"
    self:_ClearWalkTrack()
    inst.components.locomotor:GoToPoint(move.src:GetPosition(), nil, true)
    self.status = RUNNING
end

return NPCContainerMergeBehavior
