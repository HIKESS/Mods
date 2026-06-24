-- scripts/behaviours/mirrorleadercombat.lua
-- 镜像跟随玩家攻击：NPC 只攻击玩家正在打的目标，并按"玩家与目标的距离"镜像走位。
-- 设计参考自原版 DST WX-78 PossessedBody 的 brain（C:/temp/dst_scripts_new/scripts/brains/wx78_possessedbodybrain.lua）。
-- 本节点完全独立：只有在 brain 注册且 IsMirrorLeaderEnabled 为 true 时才会被 PriorityNode 执行。

local NPC_TUNING = require("npc_tuning")
local CustomCombat = require("npc/npc_custom_combat")


local MOVE_INTERVAL           = 0.2     
local MIRROR_OFFSET_THRESHOLD = 1.0     
local MIN_KITE_DIST           = 1
local DEFAULT_MAX_KITE_DIST   = 14      
local KEEP_LAST_TARGET_TIME   = 4       


local function MirrorDebug(inst, tag, msg)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_COMBAT) then return end
    print(string.format("[NPCFriends][Mirror][%s] %s npc=%s",
        tostring(tag),
        tostring(msg or ""),
        tostring(inst and (inst.prefab .. "#" .. tostring(inst.GUID)) or "?")))
end


local function FormatLeaderState(leader)
    if leader == nil or not leader:IsValid() then
        return "leader=nil"
    end
    local buf = leader.GetBufferedAction and leader:GetBufferedAction() or nil
    local sg_state = (leader.sg and leader.sg.currentstate and leader.sg.currentstate.name) or "?"
    local sg_act = leader.sg and leader.sg.statemem and leader.sg.statemem.action or nil
    local lcombat = leader.components.combat
    local ct_name = lcombat and lcombat.target and lcombat.target.prefab or "nil"
    local last_t = lcombat and lcombat.lasttargetGUID and _G.Ents and _G.Ents[lcombat.lasttargetGUID] or nil
    local last_name = last_t and last_t.prefab or "nil"
    local age = lcombat and lcombat.laststartattacktime
        and string.format("%.1f", GetTime() - lcombat.laststartattacktime) or "?"
    local buf_str = "nil"
    if type(buf) == "table" then
        buf_str = string.format("%s->%s",
            tostring(buf.action and buf.action.id or "?"),
            tostring(buf.target and buf.target.prefab or "nil"))
    end
    local sg_act_str = "nil"
    if type(sg_act) == "table" then
        sg_act_str = string.format("%s->%s",
            tostring(sg_act.action and sg_act.action.id or "?"),
            tostring(sg_act.target and sg_act.target.prefab or "nil"))
    end
    return string.format("buf=%s sg=%s/%s combat.t=%s last=%s(age%s)",
        buf_str, sg_state, sg_act_str, ct_name, last_name, age)
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader or nil
end

local function IsCombatBlocked(inst)
    if inst._is_ghost_mode == true then return true end
    if inst._npc_reviving_from_ghost == true then return true end
    if inst:HasTag("ghost") then return true end
    if inst:HasTag("playerghost") then return true end
    if inst:HasTag("noattack") then return true end
    return false
end


local function GetGuidAngleOffset(inst)
    local guid = (inst.GUID or 0) % 11
    
    return ((guid - 5) / 5) * (math.pi / 3)
end





local function GetLeaderAction(leader)
    if leader == nil then return nil, nil end
    local act = leader.GetBufferedAction and leader:GetBufferedAction() or nil
    if act == nil and leader.sg ~= nil and leader.sg.statemem ~= nil then
        act = leader.sg.statemem.action
    end
    if act ~= nil and type(act) == "table" then
        return act.action, act.target
    end
    return nil, nil
end





local function ResolveEnemy(inst, t)
    if t == nil or not t:IsValid() then return nil end
    if t:HasTag("INLIMBO") or t:HasTag("playerghost") then return nil end
    if t.components.health and t.components.health:IsDead() then return nil end
    if t:HasTag("player") or t:HasTag("npcfriend")
       or t:HasTag("npcfriend_companion") or t:HasTag("companion") then
        return nil
    end
    if not (inst.components.combat and inst.components.combat:CanTarget(t)) then return nil end
    return t
end

local function GetLeaderAttackTarget(inst, leader)
    local act, act_target = GetLeaderAction(leader)
    if act == ACTIONS.ATTACK and act_target ~= nil then
        local resolved = ResolveEnemy(inst, act_target)
        if resolved ~= nil then return resolved, "buffered" end
    end

    local lcombat = leader.components.combat
    if lcombat == nil then return nil end

    if lcombat.target ~= nil then
        local resolved = ResolveEnemy(inst, lcombat.target)
        if resolved ~= nil then return resolved, "combat_target" end
    end

    if lcombat.lasttargetGUID ~= nil
       and (GetTime() - (lcombat.laststartattacktime or 0) < KEEP_LAST_TARGET_TIME) then
        local last = _G.Ents and _G.Ents[lcombat.lasttargetGUID] or nil
        local resolved = ResolveEnemy(inst, last)
        if resolved ~= nil then return resolved, "last_target" end
    end

    return nil
end



local function ComputeMirrorPoint(inst, leader, target, desired_dist)
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local lx, _, lz = leader.Transform:GetWorldPosition()
    local dx, dz = lx - tx, lz - tz
    local len = math.sqrt(dx * dx + dz * dz)
    if len < 0.01 then
        dx, dz = 1, 0
        len = 1
    end
    local nx, nz = dx / len, dz / len

    local off = GetGuidAngleOffset(inst)
    local cos_o, sin_o = math.cos(off), math.sin(off)
    local rx = nx * cos_o - nz * sin_o
    local rz = nx * sin_o + nz * cos_o

    return tx + rx * desired_dist, ty, tz + rz * desired_dist
end


MirrorLeaderCombat = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "MirrorLeaderCombat")
    self.inst = inst
    self._last_move_time = 0
    self._last_phase = nil    
    self._last_target_guid = nil
end)

function MirrorLeaderCombat:__tostring()
    local combat = self.inst.components.combat
    return string.format("target %s",
        tostring(combat and combat.target or nil))
end

function MirrorLeaderCombat:OnStop()
    self._last_move_time = 0
end


function MirrorLeaderCombat:_LogPhase(tag, target, msg)
    local guid = target and target.GUID or nil
    if self._last_phase == tag and self._last_target_guid == guid then
        return
    end
    self._last_phase = tag
    self._last_target_guid = guid
    MirrorDebug(self.inst, tag, msg or "")
end

function MirrorLeaderCombat:Visit()
    local inst = self.inst
    local combat = inst.components.combat
    local loco = inst.components.locomotor
    if combat == nil or loco == nil then
        self.status = FAILED
        return
    end

    if IsCombatBlocked(inst) or CustomCombat.ShouldSuppressCombat(inst) then
        self:_LogPhase("blocked", nil, "combat blocked")
        self.status = FAILED
        return
    end

    local leader = GetLeader(inst)
    if leader == nil or not leader:IsValid() then
        self:_LogPhase("no_leader", nil, "")
        self.status = FAILED
        return
    end

    local target, source = GetLeaderAttackTarget(inst, leader)
    if target == nil then
        
        
        self:_LogPhase("idle", nil, "leader: " .. FormatLeaderState(leader))
        self.status = FAILED
        return
    end

    
    local return_dist = CustomCombat.GetNumber(
        "max_leader_dist_in_combat",
        NPC_TUNING.KITE_MAX_LEADER_DIST or DEFAULT_MAX_KITE_DIST,
        inst)
    local leader_target_dsq = leader:GetDistanceSqToInst(target)
    if leader_target_dsq >= return_dist * return_dist then
        if combat.target == target then
            combat:GiveUp()  
        end
        self:_LogPhase("drop_far", target,
            string.format("dist=%.1f limit=%.1f", math.sqrt(leader_target_dsq), return_dist))
        self.status = FAILED
        return
    end

    
    if combat.target ~= target then
        if not combat:CanTarget(target) then
            self:_LogPhase("cant_target", target, target.prefab)
            self.status = FAILED
            return
        end
        combat:SetTarget(target)
        
        if combat.target ~= target then
            self:_LogPhase("set_target_failed", target,
                string.format("source=%s prefab=%s", tostring(source), target.prefab))
            self.status = FAILED
            return
        end
        if inst:HasTag("notarget") then
            inst:RemoveTag("notarget")
        end
        local ok, npc_combat = pcall(require, "npc/npc_combat")
        if ok and npc_combat ~= nil and npc_combat.AutoEquipForCombat ~= nil then
            npc_combat.AutoEquipForCombat(inst)
        end
    end

    
    
    
    
    
    
    local attack_range = combat:GetAttackRange() or 2
    if attack_range < MIN_KITE_DIST then attack_range = MIN_KITE_DIST end
    local target_radius = (target.GetPhysicsRadius and target:GetPhysicsRadius(0)) or 0
    local hit_range = attack_range + target_radius  
    
    local approach_dist = math.max(attack_range * 0.8 + target_radius, MIN_KITE_DIST)

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local tx, _, tz = target.Transform:GetWorldPosition()
    local dx, dz = ix - tx, iz - tz
    local cur_dist_sq = dx * dx + dz * dz
    local cur_dist_to_target = math.sqrt(cur_dist_sq)
    
    local range_sq
    if combat.CalcAttackRangeSq ~= nil then
        range_sq = combat:CalcAttackRangeSq(target)
    else
        range_sq = hit_range * hit_range
    end
    local in_attack_range = cur_dist_sq <= range_sq

    
    local npc_busy = inst.sg and inst.sg:HasStateTag("busy") or false
    local npc_state = (inst.sg and inst.sg.currentstate and inst.sg.currentstate.name) or "?"
    if in_attack_range then
        if not npc_busy then
            loco:Stop()
            local attacked = combat:TryAttack()
            self:_LogPhase("engage", target,
                string.format("target=%s dist=%.1f range=%.1f src=%s try=%s sg=%s | %s",
                    target.prefab, cur_dist_to_target, hit_range, tostring(source),
                    tostring(attacked), npc_state, FormatLeaderState(leader)))
        else
            
            self:_LogPhase("engage_busy", target,
                string.format("target=%s dist=%.1f sg=%s (waiting anim) | %s",
                    target.prefab, cur_dist_to_target, npc_state, FormatLeaderState(leader)))
        end
        self:Sleep(0.125)
        self.status = RUNNING
        return
    end

    
    local mx, my, mz = ComputeMirrorPoint(inst, leader, target, approach_dist)
    local mirror_offset = math.sqrt((mx - ix) * (mx - ix) + (mz - iz) * (mz - iz))

    local now = GetTime()
    if mirror_offset > MIRROR_OFFSET_THRESHOLD and not npc_busy then
        if (self._last_move_time or 0) + MOVE_INTERVAL <= now then
            local point = (_G.Point ~= nil and _G.Point(mx, iy, mz))
                or (_G.Vector3 ~= nil and _G.Vector3(mx, iy, mz))
                or nil
            if point ~= nil then
                loco:GoToPoint(point, nil, true)
                self._last_move_time = now
                self:_LogPhase("chase", target,
                    string.format("target=%s cur_to_t=%.1f leader_t=%.1f mirror_off=%.1f src=%s sg=%s | %s",
                        target.prefab, cur_dist_to_target, math.sqrt(leader_target_dsq),
                        mirror_offset, tostring(source), npc_state, FormatLeaderState(leader)))
            end
        end
    elseif npc_busy then
        
        self:_LogPhase("chase_busy", target,
            string.format("target=%s cur_to_t=%.1f sg=%s (cant move)",
                target.prefab, cur_dist_to_target, npc_state))
    elseif mirror_offset <= MIRROR_OFFSET_THRESHOLD then
        
        self:_LogPhase("chase_idle_at_mirror", target,
            string.format("target=%s cur_to_t=%.1f mirror_off=%.1f hit_range=%.1f approach=%.1f",
                target.prefab, cur_dist_to_target, mirror_offset, hit_range, approach_dist))
    end

    self:Sleep(0.125)
    self.status = RUNNING
end

return MirrorLeaderCombat
