-- scripts/npc/npc_combat.lua
-- NPC 战斗 AI：索敌 / 保持目标 / leader 联动 / 自动装备 / 战斗事件

local NPC_TUNING = require("npc_tuning")
local npc_utils  = require("npc/npc_utils")
local WalterCombat = require("npc/characters/walter")
local CustomCombat = require("npc/npc_custom_combat")

local npc_combat = {}

-- 战斗调试日志
local function CombatLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_COMBAT then print(...) end
end

local function SafeAnimValue(inst, method)
    if inst == nil or inst.AnimState == nil or inst.AnimState[method] == nil then
        return "?"
    end
    local ok, value = pcall(inst.AnimState[method], inst.AnimState)
    return ok and tostring(value) or "?"
end

local function WalterCombatDbg(inst, label, ...)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_WALTER) then
        return
    end
    if inst == nil or inst.npc_character_type ~= "walter" then
        return
    end
    local combat = inst.components ~= nil and inst.components.combat or nil
    local target = combat ~= nil and combat.target or nil
    print("[沃尔特调试]", label,
        "sg=" .. tostring(inst.sg ~= nil and inst.sg.currentstate ~= nil and inst.sg.currentstate.name or nil),
        "build=" .. SafeAnimValue(inst, "GetBuild"),
        "anim=" .. SafeAnimValue(inst, "GetCurrentAnimation"),
        "ghost=" .. tostring(inst._is_ghost_mode),
        "tag_ghost=" .. tostring(inst:HasTag("ghost")),
        "noattack=" .. tostring(inst:HasTag("noattack")),
        "reviving=" .. tostring(inst._npc_reviving_from_ghost),
        "woby_lock=" .. tostring(inst._npc_woby_ride_disabled),
        "canattack=" .. tostring(combat ~= nil and combat.canattack or nil),
        "target=" .. tostring(target ~= nil and (target.prefab or target.GUID) or nil),
        ...)
end

-- ── 常量 ──────────────────────────────────────────────────
local RETARGET_CANT_TAGS = {
    "player", "npcfriend", "playerghost",
    "FX", "DECOR", "INLIMBO", "wall", "notarget", "companion"
}

local function IsHostileNPC(ent)
    return ent ~= nil and ent:HasTag("npc_hostile")
end

local function IsFriendlyNPCOrCompanion(ent)
    if ent == nil then return false end
    if ent:HasTag("npcfriend_companion") or ent:HasTag("companion") then
        return true
    end
    if ent:HasTag("npcfriend") and not IsHostileNPC(ent) then
        return true
    end
    return false
end

local function IsGhostLike(ent)
    if ent == nil then return false end
    return ent:HasTag("ghost")
        or ent:HasTag("playerghost")
        or ent._is_ghost_mode == true
end

local function IsCombatSuppressed(ent)
    return ent == nil
        or ent._is_ghost_mode == true
        or ent._npc_reviving_from_ghost == true
        or ent:HasTag("ghost")
        or ent:HasTag("playerghost")
        or ent:HasTag("noattack")
end

local function IsSpiderLike(ent)
    return ent ~= nil and ent:HasTag("spider")
end

local function IsMermLike(ent)
    return ent ~= nil and ent:HasTag("merm")
end

local function GetHostileParam(inst, webber_key, wurt_key, fallback)
    if inst and inst._is_wurt then
        local v = NPC_TUNING[wurt_key]
        if v ~= nil then return v end
    end
    if inst and inst._is_webber then
        local v = NPC_TUNING[webber_key]
        if v ~= nil then return v end
    end
    return fallback
end

-- Boss 仆从数据
local BOSS_ALLIES      = NPC_TUNING.BOSS_ALLIES     or {}
local ALLY_TO_BOSS     = NPC_TUNING.ALLY_TO_BOSS    or {}
local BOSS_KILL_ORDER  = NPC_TUNING.BOSS_KILL_ORDER or {}
local BOSS_DETECTABLE  = NPC_TUNING.BOSS_DETECTABLE or {}

npc_combat.RETARGET_CANT_TAGS = RETARGET_CANT_TAGS
npc_combat.BOSS_ALLIES      = BOSS_ALLIES
npc_combat.ALLY_TO_BOSS     = ALLY_TO_BOSS
npc_combat.BOSS_KILL_ORDER  = BOSS_KILL_ORDER
npc_combat.BOSS_DETECTABLE  = BOSS_DETECTABLE

-- ── 辅助：Boss 实体是否已真正死亡 ──
local function IsBossTrulyDead(ent)
    if not ent.components.health or not ent.components.health:IsDead() then
        return false
    end
    if ent.prefab == "klaus" and ent.IsUnchained and not ent:IsUnchained() then
        return false
    end
    return true
end
npc_combat.IsBossTrulyDead = IsBossTrulyDead

-- ── 索敌 ──────────────────────────────────────────────────
-- 优先级：① leader 目标 → ② Boss 优先 → ③ 攻击 leader 的敌人
--         → ④ 仇恨 NPC 自己的敌人 → ⑤ NPC 互助
local function Retarget(inst)
    if IsCombatSuppressed(inst) or CustomCombat.ShouldSuppressCombat(inst) then return nil end

    if CustomCombat.IsMirrorLeaderEnabled(inst) then
        local leader = inst.components.follower and inst.components.follower.leader or nil
        if leader == nil or not leader:IsValid() then return nil end

        local lcombat = leader.components.combat
        local candidate = nil
        local act = leader.GetBufferedAction and leader:GetBufferedAction() or nil
        if act == nil and leader.sg ~= nil and leader.sg.statemem ~= nil then
            act = leader.sg.statemem.action
        end
        if type(act) == "table" and act.action == _G.ACTIONS.ATTACK and act.target ~= nil then
            candidate = act.target
        elseif lcombat ~= nil and lcombat.target ~= nil then
            candidate = lcombat.target
        elseif lcombat ~= nil and lcombat.lasttargetGUID ~= nil
               and (GetTime() - (lcombat.laststartattacktime or 0) < 4) then
            candidate = _G.Ents and _G.Ents[lcombat.lasttargetGUID] or nil
        end
        if candidate == nil or not candidate:IsValid() then return nil end
        if candidate.components.health and candidate.components.health:IsDead() then return nil end
        if candidate:HasTag("player") or IsFriendlyNPCOrCompanion(candidate) then return nil end
        if not inst.components.combat:CanTarget(candidate) then return nil end
        if not CustomCombat.CanEngageTarget(inst, candidate) then return nil end
        return candidate
    end
    if IsHostileNPC(inst) then
        if inst._is_webber or inst._is_wurt then
            local now = GetTime()
            if inst._hostile_retarget_lock_until and now < inst._hostile_retarget_lock_until then
                return nil
            end
            local leash = GetHostileParam(inst, "HOSTILE_WEBBER_CHASE_RANGE", "HOSTILE_WURT_CHASE_RANGE", CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst))
            local hx = inst._webber_home_x or inst._wurt_home_x
            local hz = inst._webber_home_z or inst._wurt_home_z
            if hx and hz then
                local x0, _, z0 = inst.Transform:GetWorldPosition()
                local dx = x0 - hx
                local dz = z0 - hz
                if dx * dx + dz * dz > leash * leash then
                    return nil
                end
            end
        end
        local default_chase = CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst)
        local chase_range = ((inst._is_webber or inst._is_wurt) and GetHostileParam(inst, "HOSTILE_WEBBER_AGGRO_RANGE", "HOSTILE_WURT_AGGRO_RANGE", GetHostileParam(inst, "HOSTILE_WEBBER_CHASE_RANGE", "HOSTILE_WURT_CHASE_RANGE", default_chase)))
            or default_chase
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = _G.TheSim:FindEntities(
            x, y, z, chase_range,
            { "_combat", "_health" },
            { "INLIMBO", "playerghost", "FX", "DECOR", "wall" }
        )
        local best = nil
        local best_score = -1
        local best_dist = 0
        for _, v in ipairs(ents) do
            if v ~= inst
               and v.components.health and not v.components.health:IsDead()
               and not IsGhostLike(v)
               and (v:HasTag("player") or v:HasTag("npcfriend") or v:HasTag("npcfriend_companion") or v:HasTag("companion")) then
                if v:HasTag("npcfriend") and v:HasTag("notarget")
                   and not IsCombatSuppressed(v)
                   and not CustomCombat.ShouldSuppressCombat(v) then
                    -- 仅对“活体且可战斗”的友方NPC移除 notarget。
                    -- 幽灵态依赖 notarget/noattack 保持不可被重新锁定。
                    v:RemoveTag("notarget")
                end
                if inst._is_wurt and IsMermLike(v) then
                    -- 敌对Wurt不主动攻击鱼人阵营（含玩家鱼人）
                elseif inst.components.combat:CanTarget(v) then
                    local score = v:HasTag("player") and 3
                        or (v:HasTag("npcfriend") and 2)
                        or 1
                    local d = inst:GetDistanceSqToInst(v)
                    if score > best_score or (score == best_score and (best == nil or d < best_dist)) then
                        best = v
                        best_score = score
                        best_dist = d
                    end
                end
            end
        end
        return best
    end
    local leader = inst.components.follower and inst.components.follower.leader

    if leader then
        local x, y, z = leader.Transform:GetWorldPosition()
        local ents = _G.TheSim:FindEntities(x, y, z, CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst), nil, RETARGET_CANT_TAGS)

        -- 预扫描：周围是否有 Boss级实体
        local boss_present = nil
        local best_order = -1
        for _, v in ipairs(ents) do
            if BOSS_DETECTABLE[v.prefab] and not IsBossTrulyDead(v)
               and CustomCombat.CanEngageTarget(inst, v) then
                local order = BOSS_KILL_ORDER[v.prefab] or 0
                if order > best_order then
                    boss_present = v.prefab
                    best_order = order
                end
            end
        end

        local function is_ally(prefab)
            return boss_present and BOSS_ALLIES[boss_present] and BOSS_ALLIES[boss_present][prefab]
        end

        -- ① leader 正在打的目标（跳过玩家）
        if CustomCombat.IsLeaderAssistEnabled(inst)
           and leader.components.combat and leader.components.combat.target then
            local t = leader.components.combat.target
            if t and not t:HasTag("player")
               and not IsFriendlyNPCOrCompanion(t)
               and inst.components.combat:CanTarget(t) and not is_ally(t.prefab)
               and CustomCombat.CanEngageTarget(inst, t) then
                return t
            end
        end

        -- ② Boss 在场 → 直接锁定 Boss
        if boss_present then
            for _, v in ipairs(ents) do
                if v.prefab == boss_present and inst.components.combat:CanTarget(v)
                   and CustomCombat.CanEngageTarget(inst, v) then
                    return v
                end
            end
        end

        -- ③ 正在打 leader 的敌人：这是原本保护领队逻辑，不受“强制跟随玩家攻击”开关影响
        for _, v in ipairs(ents) do
            if v.components.combat and v.components.combat.target == leader
               and inst.components.combat:CanTarget(v) and not is_ally(v.prefab)
               and CustomCombat.CanEngageTarget(inst, v) then
                return v
            end
        end

        -- ④ 有生物仇恨 NPC 自己
        local mx, my, mz = inst.Transform:GetWorldPosition()
        local nearby = _G.TheSim:FindEntities(mx, my, mz, CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst), nil, RETARGET_CANT_TAGS)
        for _, v in ipairs(nearby) do
            if v.components.combat and v.components.combat.target == inst
               and inst.components.combat:CanTarget(v) and not is_ally(v.prefab)
               and CustomCombat.CanEngageTarget(inst, v) then
                return v
            end
        end
    end

    -- ⑤ NPC 互助：20 格内其他 NPC 或召唤物被攻击或有仇恨目标 → 帮忙打
    local mx, my, mz = inst.Transform:GetWorldPosition()
    if CustomCombat.IsNPCAssistEnabled(inst) then
        local assist_range = CustomCombat.GetNumber("npc_assist_range", NPC_TUNING.NPC_ASSIST_RANGE, inst)
        -- 检查其他 NPC 的战斗目标
        local npcs = _G.TheSim:FindEntities(mx, my, mz, assist_range, { "npcfriend" })
        for _, npc in ipairs(npcs) do
            if npc ~= inst and npc:IsValid()
               and not IsCombatSuppressed(npc)
               and npc.components.combat then
                local npc_target = npc.components.combat.target
                if npc_target and npc_target:IsValid()
                   and not npc_target:HasTag("player")
                   and not IsFriendlyNPCOrCompanion(npc_target)
                   and not (npc_target.components.health and npc_target.components.health:IsDead())
                   and inst.components.combat:CanTarget(npc_target)
                   and CustomCombat.CanEngageTarget(inst, npc_target) then
                    return npc_target
                end
            end
        end
        -- 检查 NPC 召唤物（伯尼/蜂卫/暗影）的战斗目标
        local companions = _G.TheSim:FindEntities(mx, my, mz, assist_range, { "npcfriend_companion" })
        for _, comp in ipairs(companions) do
            if comp:IsValid() and comp.components.combat then
                local comp_target = comp.components.combat.target
                if comp_target and comp_target:IsValid()
                   and not comp_target:HasTag("player")
                   and not IsFriendlyNPCOrCompanion(comp_target)
                   and not (comp_target.components.health and comp_target.components.health:IsDead())
                   and inst.components.combat:CanTarget(comp_target)
                   and CustomCombat.CanEngageTarget(inst, comp_target) then
                    return comp_target
                end
            end
        end
        -- 检查是否有敌人正在攻击其他 NPC 或召唤物
        local threats = _G.TheSim:FindEntities(mx, my, mz, assist_range, { "_combat" }, RETARGET_CANT_TAGS)
        for _, ent in ipairs(threats) do
            if ent.components.combat then
                local tgt = ent.components.combat.target
                if tgt and (tgt:HasTag("npcfriend") or tgt:HasTag("npcfriend_companion"))
                   and tgt ~= inst
                   and not ent:HasTag("player")  -- 玩家攻击召唤物时不反击
                   and inst.components.combat:CanTarget(ent)
                   and CustomCombat.CanEngageTarget(inst, ent) then
                    return ent
                end
            end
        end
    end

    local hostile_npcs = _G.TheSim:FindEntities(mx, my, mz, CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst), { "npcfriend", "npc_hostile" }, { "INLIMBO", "playerghost" })
    for _, hn in ipairs(hostile_npcs) do
        if hn ~= inst and hn:IsValid()
           and hn.components.health and not hn.components.health:IsDead()
           and inst.components.combat:CanTarget(hn)
           and CustomCombat.CanEngageTarget(inst, hn) then
            return hn
        end
    end

    return nil
end

-- ── 保持目标 ──────────────────────────────────────────────
-- Boss 在场时放弃仆从目标
local function KeepTarget(inst, target)
    if IsCombatSuppressed(inst) or CustomCombat.ShouldSuppressCombat(inst) then return false end

    -- 镜像模式：以"玩家是否仍在打这个目标"为唯一标准，
    -- 不走 NPC 离玩家距离的 ShouldBreakForCombatReturn 判断（NPC 镜像走位时本就会离玩家远）
    if CustomCombat.IsMirrorLeaderEnabled(inst) then
        if target == nil or not target:IsValid() then return false end
        if target.components.health and target.components.health:IsDead() then return false end
        if target:HasTag("player") or IsFriendlyNPCOrCompanion(target) then return false end
        local leader = inst.components.follower and inst.components.follower.leader or nil
        if leader == nil or not leader:IsValid() then return false end
        local lcombat = leader.components.combat
        if lcombat == nil then return false end
        if lcombat.target == target then return true end
        -- 玩家刚切走目标但仍在 KEEP_LAST_TARGET 缓冲内，让 MirrorLeaderCombat 接管新目标
        return false
    end

    if CustomCombat.ShouldBreakForCombatReturn(inst) then
        CustomCombat.ReturnToLeader(inst, "keep_target_npc_outside")
        return false
    end
    if not CustomCombat.CanEngageTarget(inst, target) then
        CustomCombat.ReturnToLeader(inst, "keep_target_target_outside", target)
        return false
    end
    if IsCombatSuppressed(target) then return false end
    if inst._is_webber and IsSpiderLike(target) then return false end
    if inst._is_wurt and IsMermLike(target) then return false end
    if not IsHostileNPC(inst) then
        if target:HasTag("player") then return false end
        if IsFriendlyNPCOrCompanion(target) then return false end
    end
    local boss_prefabs = ALLY_TO_BOSS[target.prefab]
    if boss_prefabs then
        local x, y, z = inst.Transform:GetWorldPosition()
        local nearby = _G.TheSim:FindEntities(x, y, z, CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst), nil, RETARGET_CANT_TAGS)
        for _, v in ipairs(nearby) do
            if boss_prefabs[v.prefab] and not IsBossTrulyDead(v) then
                return false
            end
        end
    end
    local default_keep = CustomCombat.GetNumber("max_chase_dist", NPC_TUNING.MAX_CHASE_DIST, inst)
    local keep_range = ((inst._is_webber or inst._is_wurt) and GetHostileParam(inst, "HOSTILE_WEBBER_CHASE_RANGE", "HOSTILE_WURT_CHASE_RANGE", default_keep))
        or default_keep
    local hx = inst._webber_home_x or inst._wurt_home_x
    local hz = inst._webber_home_z or inst._wurt_home_z
    if (inst._is_webber or inst._is_wurt) and hx and hz then
        local x0, _, z0 = inst.Transform:GetWorldPosition()
        local dx = x0 - hx
        local dz = z0 - hz
        if dx * dx + dz * dz > keep_range * keep_range then
            return false
        end
    end
    return target:IsValid()
        and not (target.components.health and target.components.health:IsDead())
        and inst:IsNear(target, keep_range)
end

-- ── 自身被攻击 → 反击（玩家攻击时忽略仇恨）──────────────────
function npc_combat.OnAttacked(inst, data)
    if IsCombatSuppressed(inst) or CustomCombat.ShouldSuppressCombat(inst) then return end
    if data and data.attacker then
        local hp = inst.components.health and inst.components.health.currenthealth or 0
        local maxhp = inst.components.health and inst.components.health.maxhealth or 1
        local dmg = data.damage or 0
        local atk_state = (data.attacker.sg and data.attacker.sg.currentstate)
            and data.attacker.sg.currentstate.name or "?"
        CombatLog(string.format("[NPC][Hit] by %s state=%s dmg=%.0f hp=%.0f/%.0f",
            data.attacker.prefab, atk_state, dmg, hp, maxhp))

        -- 玩家（含其他玩家）攻击 NPC → 友方NPC不反击，说友好台词（5 秒冷却防刷屏）
        if (not IsHostileNPC(inst)) and data.attacker:HasTag("player") then
            local now = GetTime()
            if inst.components.talker
               and (inst._hit_by_player_cd == nil or now > inst._hit_by_player_cd) then
                local lines = STRINGS.NPCFRIEND_TALK_HIT_BY_PLAYER
                if lines then
                    inst.components.talker:Say(lines[math.random(#lines)])
                end
                inst._hit_by_player_cd = now + 5
            end
            return
        end
    end
    if data and data.attacker
       and inst.components.combat and inst.components.combat:CanTarget(data.attacker) then
        if IsGhostLike(data.attacker) then
            return
        end
        if inst._is_webber and IsSpiderLike(data.attacker) then
            return
        end
        if inst._is_wurt and IsMermLike(data.attacker) then
            return
        end
        -- 不反击友方单位（阿比盖尔、暗影护卫、其他 NPC）
        if (not IsHostileNPC(data.attacker))
           and (data.attacker:HasTag("npcfriend") or data.attacker:HasTag("npcfriend_companion")
                or data.attacker:HasTag("companion")) then
            return
        end
        local current = inst.components.combat.target
        -- 当前目标是 Boss 级实体 → 保护不切换
        if current ~= nil and BOSS_DETECTABLE[current.prefab] and not IsBossTrulyDead(current) then
            -- 攻击者是当前目标的仆从 → 不切换
            if BOSS_ALLIES[current.prefab] and BOSS_ALLIES[current.prefab][data.attacker.prefab] then
                return
            end
            -- 攻击者不是 Boss → 不切换（闪避系统会处理）
            if not BOSS_DETECTABLE[data.attacker.prefab] then
                return
            end
            -- 攻击者也是 Boss → 只在优先级更高时切换
            local cur_order = BOSS_KILL_ORDER[current.prefab] or 0
            local atk_order = BOSS_KILL_ORDER[data.attacker.prefab] or 0
            if atk_order <= cur_order then
                return
            end
        end
        -- 攻击者是仆从且 Boss 还活着 → 不切换到仆从
        local boss_prefabs = ALLY_TO_BOSS[data.attacker.prefab]
        if boss_prefabs then
            local x, y, z = inst.Transform:GetWorldPosition()
            local nearby = _G.TheSim:FindEntities(x, y, z, CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst), nil, RETARGET_CANT_TAGS)
            for _, v in ipairs(nearby) do
                if boss_prefabs[v.prefab] and not IsBossTrulyDead(v) then
                    return
                end
            end
        end
        if not CustomCombat.CanEngageTarget(inst, data.attacker) then
            CustomCombat.ReturnToLeader(inst, "on_attacked_attacker_outside", data.attacker)
            return
        end
        inst.components.combat:SetTarget(data.attacker)
    end
end


local function ForEachCarried(inv, fn)
    for i = 1, inv.maxslots do
        local it = inv:GetItemInSlot(i)
        if it ~= nil and fn(it) then return end
    end
    local overflow = inv.GetOverflowContainer and inv:GetOverflowContainer() or nil
    if overflow ~= nil and overflow.slots then
        for i = 1, (overflow.numslots or 0) do
            local it = overflow.slots[i]
            if it ~= nil and fn(it) then return end
        end
    end
end

-- ── 进入战斗时自动装备 ──────────────────────────────────────
function npc_combat.AutoEquipForCombat(inst)
    if not CustomCombat.IsAutoEquipEnabled(inst) then return end
    if inst._is_ghost_mode then return end
    if inst._is_weremoose then return end  -- 鹿人使用拳头，不装备武器/护甲
    local inv = inst.components.inventory
    if not inv then return end

    local target = inst.components.combat and inst.components.combat.target or nil
    if WalterCombat.TryEquipForTarget(inst, target) then
        return
    end

    -- HANDS 槽：始终选择伤害最高的武器（升级已装备的低伤武器）
    local current_hands = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    local upgrade_hands = true
    local hands_score = -1
    if current_hands ~= nil then
        local wc = current_hands.components.weapon
        if wc and not current_hands:HasTag("lighter") then
            -- 当前手持有武器属性（含斧/镐等工具武器）→ 用其伤害作为基准，允许升级到更高伤武器
            hands_score = wc:GetDamage(inst) or 0
        else
            -- 当前装备没有武器属性（照明物等）→ 不替换
            upgrade_hands = false
        end
    end
    if upgrade_hands then
        local best_hands = nil
        -- 含口袋 + 已装备背包内的武器
        ForEachCarried(inv, function(candidate)
            if candidate.components.equippable
               and candidate.components.equippable.equipslot == EQUIPSLOTS.HANDS then
                local wc = candidate.components.weapon
                if wc and not candidate.components.tool
                   and not candidate:HasTag("lighter")
                   and not (inst.npc_character_type == "walter" and candidate.prefab == "slingshot") then
                    local dmg = wc:GetDamage(inst) or 0
                    if dmg > hands_score then
                        hands_score = dmg
                        best_hands = candidate
                    end
                end
            end
        end)
        if best_hands then
            inv:Equip(best_hands)
        end
    end

    for _, eslot in ipairs({ EQUIPSLOTS.BODY, EQUIPSLOTS.HEAD }) do
        if not inv:GetEquippedItem(eslot) then
            local best_item = nil
            local best_score = -1
            ForEachCarried(inv, function(candidate)
                if candidate.components.equippable
                   and candidate.components.equippable.equipslot == eslot then
                    local ac = candidate.components.armor
                    if ac then
                        local absorb = ac.absorb_percent or 0
                        if absorb > best_score then
                            best_score = absorb
                            best_item = candidate
                        end
                    end
                end
            end)
            if best_item then
                inv:Equip(best_item)
            end
        end
    end
end

-- ── 开始跟随时绑定 leader 战斗事件 ──────────────────────────
function npc_combat.OnStartFollowing(inst)
    local leader = inst.components.follower and inst.components.follower.leader
    if not leader then return end

    local function IsBossAllyNearby(tgt)
        local boss_prefabs = ALLY_TO_BOSS[tgt.prefab]
        if not boss_prefabs then return false end
        local x, y, z = inst.Transform:GetWorldPosition()
        local nearby = _G.TheSim:FindEntities(x, y, z, CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, inst), nil, RETARGET_CANT_TAGS)
        for _, v in ipairs(nearby) do
            if boss_prefabs[v.prefab] and not IsBossTrulyDead(v) then return true end
        end
        return false
    end

    local function TrySetTarget(tgt, source, force_original)
        if not inst:IsValid() or IsCombatSuppressed(inst)
           or CustomCombat.ShouldSuppressCombat(inst) then
            return
        end
        if not force_original and not CustomCombat.IsLeaderAssistEnabled(inst) then
            return
        end
        if inst._is_webber and IsSpiderLike(tgt) then return end
        if inst._is_wurt and IsMermLike(tgt) then return end
        if not IsHostileNPC(inst) then
            if tgt:HasTag("player") then return end
            if IsFriendlyNPCOrCompanion(tgt) then return end
        end
        if not (inst.components.combat and inst.components.combat:CanTarget(tgt)) then
            return
        end
        if not CustomCombat.CanEngageTarget(inst, tgt) then
            CustomCombat.ReturnToLeader(inst, "leader_attack_target_outside", tgt)
            return
        end
        if IsBossAllyNearby(tgt) then
            WalterCombatDbg(inst, "leader 战斗联动跳过：Boss盟友附近")
            return
        end
        local cur = inst.components.combat.target
        if cur ~= nil and cur:IsValid()
           and cur.components.health and not cur.components.health:IsDead() then
            return
        end
        inst.components.combat:SetTarget(tgt)
        WalterCombatDbg(inst, "leader 战斗联动已设目标", "source=" .. tostring(source), "new_target=" .. tostring(tgt ~= nil and (tgt.prefab or tgt.GUID) or nil))
        npc_combat.AutoEquipForCombat(inst)
    end

    inst._onleaderattacked = function(ldr, data)
        if data and data.attacker then TrySetTarget(data.attacker, "leader_attacked", true) end
    end
    inst._onleaderattackother = function(ldr, data)
        if data and data.target then TrySetTarget(data.target, "leader_attackother") end
    end
    inst._onleadernewcombattarget = function(ldr, data)
        if data and data.target then TrySetTarget(data.target, "leader_newcombattarget") end
    end

    inst:ListenForEvent("attacked",       inst._onleaderattacked,        leader)
    inst:ListenForEvent("onattackother",   inst._onleaderattackother,     leader)
    inst:ListenForEvent("newcombattarget", inst._onleadernewcombattarget, leader)
end

-- ── 停止跟随时清理 leader 事件绑定 ──────────────────────────
function npc_combat.OnStopFollowing(inst, data)
    if data and data.leader then
        if inst._onleaderattacked then
            inst:RemoveEventCallback("attacked",       inst._onleaderattacked,        data.leader)
            inst._onleaderattacked = nil
        end
        if inst._onleaderattackother then
            inst:RemoveEventCallback("onattackother",   inst._onleaderattackother,     data.leader)
            inst._onleaderattackother = nil
        end
        if inst._onleadernewcombattarget then
            inst:RemoveEventCallback("newcombattarget", inst._onleadernewcombattarget, data.leader)
            inst._onleadernewcombattarget = nil
        end
    end
end

-- ── 初始化战斗组件 ──────────────────────────────────────────
function npc_combat.SetupCombat(inst)
    inst:AddComponent("combat")
    local STATS = NPC_TUNING.CHARACTER_STATS
    local DEFAULT_STATS = npc_utils.DEFAULT_STATS
    local stats = STATS.wilson or DEFAULT_STATS
    inst.npc_base_damage = stats.damage
    inst.components.combat:SetDefaultDamage(inst.npc_base_damage)
    inst.components.combat:SetRange(stats.attack_range)
    inst._npcfriends_retarget_fn = Retarget
    inst._npcfriends_keeptarget_fn = KeepTarget
    inst.components.combat:SetRetargetFunction(CustomCombat.GetNumber("retarget_interval", NPC_TUNING.RETARGET_INTERVAL, inst), Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
end

-- ── 注册战斗相关事件监听 ──────────────────────────────────────
function npc_combat.SetupCombatEvents(inst)
    inst:ListenForEvent("startfollowing", function(i) npc_combat.OnStartFollowing(i) end)
    inst:ListenForEvent("stopfollowing",  npc_combat.OnStopFollowing)
    inst:ListenForEvent("attacked",       npc_combat.OnAttacked)

    -- 进入战斗时自动装备 + 拦截 Boss 仆从锁定
    inst:ListenForEvent("newcombattarget", function(i, data)
        if IsCombatSuppressed(i) or CustomCombat.ShouldSuppressCombat(i) then
            if i.components.combat ~= nil then
                i.components.combat:SetTarget(nil)
                i.components.combat:CancelAttack()
            end
            if not i:HasTag("notarget") then
                i:AddTag("notarget")
            end
            WalterCombatDbg(i, "newcombattarget 被战斗锁定拦截")
            return
        end
        if data and data.target then
            local boss_prefabs = ALLY_TO_BOSS[data.target.prefab]
            if boss_prefabs then
                local x, y, z = i.Transform:GetWorldPosition()
                local nearby = _G.TheSim:FindEntities(x, y, z, CustomCombat.GetNumber("chase_range", NPC_TUNING.CHASE_RANGE, i), nil, RETARGET_CANT_TAGS)
                local best_boss, best_order = nil, -1
                for _, v in ipairs(nearby) do
                    if boss_prefabs[v.prefab] and not IsBossTrulyDead(v) and i.components.combat:CanTarget(v) then
                        local order = BOSS_KILL_ORDER[v.prefab] or 0
                        if order > best_order then
                            best_boss = v
                            best_order = order
                        end
                    end
                end
                if best_boss then
                    WalterCombatDbg(i, "newcombattarget 改锁 Boss", "boss=" .. tostring(best_boss.prefab or best_boss.GUID))
                    i.components.combat:SetTarget(best_boss)
                    return
                end
            end
        end

        npc_combat.AutoEquipForCombat(i)
        if (not i._is_ghost_mode)
           and (not IsGhostLike(i))
           and (not i:HasTag("noattack"))
           and (not CustomCombat.ShouldSuppressCombat(i))
           and i:HasTag("notarget") then
            i:RemoveTag("notarget")
        end
    end)

    -- 丢失目标 → 恢复 notarget（Boss 无敌期间重新锁定）
    inst:ListenForEvent("droppedtarget", function(i, data)
        if not i._is_ghost_mode and i.components.combat
           and i.components.combat.target == nil then
            local old = data and data.target
            if old and old:IsValid()
               and not (old.components.health and old.components.health:IsDead())
               and old:HasTag("noattack")
               and NPC_TUNING.CREATURE_ATTACK_DATA[old.prefab]
               and not (IsCombatSuppressed(i) or CustomCombat.ShouldSuppressCombat(i)) then
                i.components.combat:SetTarget(old)
                return
            end
            if not IsHostileNPC(i) then
                i:AddTag("notarget")
            end
        end
    end)

    inst:ListenForEvent("giveuptarget", function(i)
        if not i._is_ghost_mode and i.components.combat
           and i.components.combat.target == nil then
            if not IsHostileNPC(i) then
                i:AddTag("notarget")
            end
        end
    end)


    inst:ListenForEvent("onattackother", function(i, data)
        if not data or not data.target then return end
        local boss = data.target
        if not BOSS_DETECTABLE[boss.prefab] then return end
        if not boss.components.combat then return end
        if boss.components.health and boss.components.health:IsDead() then return end
        local cur = boss.components.combat.target
        if cur ~= i then
            boss.components.combat:SetTarget(i)
        end
    end)
end

return npc_combat
