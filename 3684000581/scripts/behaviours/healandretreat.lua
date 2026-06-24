-- scripts/behaviours/healandretreat.lua
-- NPC 低血量自动撤退治疗行为
-- 战斗中血量 < 30% → 脱离战斗 → 向领队撤退 12 格 → 吃饺子回血到 90%
-- 吃饺子期间与敌人保持 5 格安全距离，敌人闯入则向外跑 12 格
-- 没有饺子时说一句话后恢复战斗

local NPC_TUNING = require("npc_tuning")
local InvUtil    = require("npc/npc_inventory_util")
local CustomCombat = require("npc/npc_custom_combat")


local function CombatLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_COMBAT then print(...) end
end


local LOW_THRESHOLD   = NPC_TUNING.HEAL_LOW_THRESHOLD  or 0.3
local FULL_THRESHOLD  = NPC_TUNING.HEAL_FULL_THRESHOLD or 0.9
local RETREAT_DIST    = NPC_TUNING.HEAL_RETREAT_DIST   or 12
local SAFE_DIST       = NPC_TUNING.HEAL_SAFE_DIST      or 7
local FLEE_DIST       = NPC_TUNING.HEAL_FLEE_DIST      or 12
local EAT_INTERVAL    = NPC_TUNING.HEAL_EAT_INTERVAL   or 0.5
local FOOD_PREFAB     = NPC_TUNING.HEAL_FOOD_PREFAB    or "perogies"
local TICK            = 2 * FRAMES  
local BLINK_RETREAT_DIST_STALKER = 5   
local BLINK_RETREAT_DIST_DEFAULT = 8   

local STALKER_PREFABS = { stalker_atrium = true, shadowchanneler = true, stalker_minion1 = true }



local function GetLeaderPos(inst)
    local f = inst.components.follower
    if f ~= nil and f.leader ~= nil and f.leader:IsValid() then
        return Point(f.leader.Transform:GetWorldPosition())
    end
    return nil
end

local function Normalize2D(dx, dz)
    local len = math.sqrt(dx * dx + dz * dz)
    if len > 0.01 then
        return dx / len, dz / len
    end
    return 0, 0
end


local function FindFood(inst)
    local inv = inst.components.inventory
    if inv == nil then return nil end
    local food_prefab = CustomCombat.GetString("heal_food_prefab", FOOD_PREFAB, inst)
    local found = nil
    InvUtil.ForEachCarriedItem(inst, function(item)
        if item.prefab == food_prefab then
            found = item
            return true
        end
    end)
    return found
end


local THREAT_CANT_TAGS = { "player", "companion", "npcfriend", "INLIMBO", "playerghost", "notarget" }


local function FindOrangeStaff(inst)
    return InvUtil.FindItemByPrefab(inst, "orangestaff")
end


local function FindBestWeapon(inst)
    return InvUtil.FindBestWeapon(inst)
end


local function BlinkRetreatEscape(inst, retreat_dir_x, retreat_dir_z, blink_dist)
    local staff = FindOrangeStaff(inst)
    if staff == nil then return false end

    local dist = blink_dist or BLINK_RETREAT_DIST_DEFAULT
    local x, _, z = inst.Transform:GetWorldPosition()
    local dx, dz = retreat_dir_x, retreat_dir_z
    if dx == 0 and dz == 0 then
        local angle = math.random() * TWOPI
        dx, dz = math.cos(angle), math.sin(angle)
    end

    local tx, tz = x + dx * dist, z + dz * dist

    local SPIKE_TAGS = { "fossilspike" }
    local function IsPointSafe(px, pz)
        return TheWorld.Map:IsPassableAtPoint(px, 0, pz)
           and #_G.TheSim:FindEntities(px, 0, pz, 1.5, SPIKE_TAGS) == 0
    end

    if not IsPointSafe(tx, tz) then
        local found = false
        for _, offset in ipairs({ math.pi / 4, -math.pi / 4, math.pi / 2, -math.pi / 2,
                                  math.pi * 3 / 4, -math.pi * 3 / 4, math.pi }) do
            local angle = math.atan2(dz, dx) + offset
            local nx, nz = x + math.cos(angle) * dist, z + math.sin(angle) * dist
            if IsPointSafe(nx, nz) then
                tx, tz = nx, nz
                found = true
                break
            end
        end
        if not found then return false end
    end

    local inv = inst.components.inventory
    local prev_hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if staff ~= prev_hands then
        inv:Equip(staff)
    end

    local blinkstaff = staff.components.blinkstaff
    if blinkstaff then
        blinkstaff:SpawnEffect(inst)
        if blinkstaff.presound and blinkstaff.presound ~= "" then
            inst.SoundEmitter:PlaySound(blinkstaff.presound)
        end
        inst.Physics:Teleport(tx, 0, tz)
        blinkstaff:SpawnEffect(inst)
        if blinkstaff.postsound and blinkstaff.postsound ~= "" then
            inst.SoundEmitter:PlaySound(blinkstaff.postsound)
        end
    else
        inst.Physics:Teleport(tx, 0, tz)
    end

    local best_weapon = FindBestWeapon(inst)
    if best_weapon ~= nil and best_weapon ~= staff then
        inv:Equip(best_weapon)
    end

    CombatLog(string.format("[NPC:%s][回血传送] 被卡住，用懒人魔杖传送到 (%.1f, %.1f) 距离=%.0f", inst.prefab, tx, tz, dist))
    return true
end

local function FindNearestThreat(inst)
    local mx, my, mz = inst.Transform:GetWorldPosition()
    local safe_dist = CustomCombat.GetNumber("heal_safe_dist", SAFE_DIST, inst)
    local search_r = safe_dist + 5
    local ents = _G.TheSim:FindEntities(mx, my, mz, search_r, { "_combat" }, THREAT_CANT_TAGS)
    local leader = inst.components.follower and inst.components.follower.leader
    local best, best_dsq = nil, math.huge
    for _, ent in ipairs(ents) do
        local ec = ent.components.combat
        if ec ~= nil then
            local tgt = ec.target
            if tgt == inst or tgt == leader then
                local dsq = inst:GetDistanceSqToInst(ent)
                if dsq < best_dsq then
                    best = ent
                    best_dsq = dsq
                end
            end
        end
    end
    return best, best_dsq
end


local function SayLine(inst, key)
    if inst.components.talker == nil then return end
    local base_key = "NPCFRIEND_TALK_" .. key
    local lines = nil
    if inst.npc_character_type then
        local char_key = base_key .. "_" .. string.upper(inst.npc_character_type)
        lines = STRINGS[char_key]
    end
    if lines == nil then
        lines = STRINGS[base_key]
    end
    if lines ~= nil and #lines > 0 then
        inst.components.talker:Say(lines[math.random(#lines)])
    end
end



HealAndRetreat = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "HealAndRetreat")
    self.inst = inst
    
    self.phase = nil
    self.next_eat_time = 0
    self.retreat_origin = nil  
    self.said_eat_line = false
    self.stuck_check_pos  = nil   
    self.stuck_check_time = nil   
end)

function HealAndRetreat:Visit()
    local inst = self.inst
    local health = inst.components.health

    
    if self.status == READY then
        if health ~= nil
           and not health:IsDead()
           and not inst._is_ghost_mode
           and CustomCombat.IsHealRetreatEnabled(inst)
           and inst.components.combat ~= nil
           and inst.components.combat.target ~= nil
           and health:GetPercent() < CustomCombat.GetNumber("heal_low_threshold", LOW_THRESHOLD, inst) then
            if FindFood(inst) == nil then
                if not inst._heal_no_food_cd or GetTime() > inst._heal_no_food_cd then
                    SayLine(inst, "HEAL_NO_FOOD")
                    inst._heal_no_food_cd = GetTime() + 30  
                end
                self.status = FAILED
                return
            end
            inst._heal_no_food_cd = nil
            local combat_target = inst.components.combat.target
            inst.components.combat:SetTarget(nil)
            
            
            inst:RemoveTag("notarget")
            inst.components.locomotor:Stop()

            local leader_pos = GetLeaderPos(inst)
            local cur = Point(inst.Transform:GetWorldPosition())
            local dir_x, dir_z = 0, 1
            if leader_pos ~= nil then
                dir_x, dir_z = Normalize2D(leader_pos.x - cur.x, leader_pos.z - cur.z)
            end
            local is_stalker_fight = combat_target ~= nil and STALKER_PREFABS[combat_target.prefab]
            local blink_dist = is_stalker_fight and BLINK_RETREAT_DIST_STALKER or BLINK_RETREAT_DIST_DEFAULT
            if BlinkRetreatEscape(inst, dir_x, dir_z, blink_dist) then
                self.phase = "eat"
            else
                self.phase = "retreat"
                self.retreat_origin = Point(inst.Transform:GetWorldPosition())
                self.retreat_target = nil
            end
            self.next_eat_time = 0
            self.said_eat_line = false
            self.stuck_check_pos  = nil
            self.stuck_check_time = nil
            self.status = RUNNING
        else
            self.status = FAILED
            return
        end
    end

    if self.status ~= RUNNING then return end

    
    if inst._is_ghost_mode
       or (health ~= nil and health:IsDead()) then
        inst.components.locomotor:Stop()
        self.phase = nil
        self.status = FAILED
        return
    end

    
    if health ~= nil and health:GetPercent() >= CustomCombat.GetNumber("heal_full_threshold", FULL_THRESHOLD, inst) then
        SayLine(inst, "HEAL_DONE")
        inst.components.locomotor:Stop()
        self.phase = nil
        self.status = SUCCESS
        return
    end

    local me = Point(inst.Transform:GetWorldPosition())

    
    
    
    if self.phase == "retreat" then
        if self.retreat_target == nil then
            local leader_pos = GetLeaderPos(inst)
            if leader_pos ~= nil then
                local dx, dz = Normalize2D(leader_pos.x - me.x, leader_pos.z - me.z)
                self.retreat_target = Point(
                    me.x + dx * CustomCombat.GetNumber("heal_retreat_dist", RETREAT_DIST, inst),
                    me.y,
                    me.z + dz * CustomCombat.GetNumber("heal_retreat_dist", RETREAT_DIST, inst)
                )
            else
                self.phase = "eat"
            end
        end

        if self.retreat_target ~= nil then
            local retreat_dist = CustomCombat.GetNumber("heal_retreat_dist", RETREAT_DIST, inst)
            local retreated = math.sqrt(distsq(me, self.retreat_origin))
            if retreated >= retreat_dist or distsq(me, self.retreat_target) < 2 * 2 then
                self.phase = "eat"
            else
                local now = GetTime()
                if self.stuck_check_pos == nil then
                    self.stuck_check_pos  = me
                    self.stuck_check_time = now
                elseif now - self.stuck_check_time >= 1 then
                    local moved = math.sqrt(distsq(me, self.stuck_check_pos))
                    if moved < 1 then
                        local dir_x, dir_z = 0, 0
                        if self.retreat_target then
                            dir_x, dir_z = Normalize2D(
                                self.retreat_target.x - me.x,
                                self.retreat_target.z - me.z)
                        end
                        if BlinkRetreatEscape(inst, dir_x, dir_z, BLINK_RETREAT_DIST_STALKER) then
                            self.retreat_origin = Point(inst.Transform:GetWorldPosition())
                            self.retreat_target = nil
                            self.stuck_check_pos = nil
                            self.stuck_check_time = nil
                        else
                            self.phase = "eat"
                        end
                    else
                        self.stuck_check_pos  = me
                        self.stuck_check_time = now
                    end
                end

                if self.phase == "retreat" then
                    inst.components.locomotor:GoToPoint(self.retreat_target, nil, true)
                    self:Sleep(TICK)
                    return
                end
            end
        end
    end

    
    
    
    if self.phase == "eat" then
        local threat, threat_dsq = FindNearestThreat(inst)
        local safe_dist = CustomCombat.GetNumber("heal_safe_dist", SAFE_DIST, inst)
        if threat ~= nil and threat_dsq < safe_dist * safe_dist then
            local tx, ty, tz = threat.Transform:GetWorldPosition()
            local dx, dz = Normalize2D(me.x - tx, me.z - tz)
            local flee_pt = Point(me.x + dx * FLEE_DIST, me.y, me.z + dz * FLEE_DIST)
            inst.components.locomotor:GoToPoint(flee_pt, nil, true)
            self:Sleep(TICK)
            return
        end

        inst.components.locomotor:Stop()

        if GetTime() >= self.next_eat_time then
            local food = FindFood(inst)
            if food ~= nil then
                if not self.said_eat_line then
                    SayLine(inst, "HEAL_EATING")
                    self.said_eat_line = true
                end

                local eaten = false
                if inst.components.eater ~= nil then
                    eaten = inst.components.eater:Eat(food, inst)
                end
                if eaten then
                elseif food.components.edible ~= nil then
                    local inv = inst.components.inventory
                    if inv ~= nil then
                        inv:RemoveItem(food)
                    end
                    local hp = food.components.edible:GetHealth(inst)
                    if hp ~= nil and health ~= nil then
                        health:DoDelta(hp)
                    end
                    food:Remove()
                end

                self.next_eat_time = GetTime() + EAT_INTERVAL

                if health ~= nil and health:GetPercent() >= CustomCombat.GetNumber("heal_full_threshold", FULL_THRESHOLD, inst) then
                    SayLine(inst, "HEAL_DONE")
                    inst.components.locomotor:Stop()
                    inst:RemoveTag("notarget")
                    self.phase = nil
                    self.status = SUCCESS
                    return
                end
            else
                if self.said_eat_line then
                    SayLine(inst, "HEAL_OUT_OF_FOOD")
                else
                    SayLine(inst, "HEAL_NO_FOOD")
                end
                inst:RemoveTag("notarget")
                self.phase = nil
                self.status = FAILED
                return
            end
        end

        self:Sleep(TICK)
    end
end
