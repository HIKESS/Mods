-- scripts/npc/npc_ghost.lua
-- NPC 灵魂系统：死亡 → 半透明灵魂状态 → 自动回血 → 复活
-- EnterGhostMode 被 death handler 和 OnLoad 共用

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")
local npc_utils  = require("npc/npc_utils")
local WobyRide   = require("npc/npc_woby_ride")
local CustomCombat = require("npc/npc_custom_combat")

local APPEARANCE = npc_utils.APPEARANCE

local npc_ghost = {}

local function WandaReviveDbg(inst, fmt, ...)
    if not (NPC_TUNING and NPC_TUNING.WANDA_REVIVE_DEBUG) then
        return
    end
    if not inst or inst.npc_character_type ~= "wanda" then
        return
    end
    local ok, msg = pcall(string.format, fmt, ...)
    if not ok then
        msg = tostring(fmt)
    end
    local build = (inst.AnimState and inst.AnimState.GetBuild and inst.AnimState:GetBuild()) or "?"
    local state = (inst.sg and inst.sg.currentstate and inst.sg.currentstate.name) or "?"
    print(string.format("[NPCFriends][WandaRevive][%s] %s | state=%s build=%s ghost=%s",
        tostring(inst.GUID), msg, tostring(state), tostring(build), tostring(inst._is_ghost_mode)))
end

local function SafeAnimValue(inst, method)
    if inst == nil or inst.AnimState == nil or inst.AnimState[method] == nil then
        return "?"
    end
    local ok, value = pcall(inst.AnimState[method], inst.AnimState)
    return ok and tostring(value) or "?"
end

local function WalterGhostDbg(inst, label, ...)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_WALTER) then
        return
    end
    if inst == nil or inst.npc_character_type ~= "walter" then
        return
    end
    local combat = inst.components ~= nil and inst.components.combat or nil
    local rider = inst.components ~= nil and inst.components.rider or nil
    local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
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
        "riding=" .. tostring(mount ~= nil),
        "mount=" .. tostring(mount ~= nil and mount.prefab or nil),
        ...)
end

-- ────────────────────────────────────────────────────────────
-- 从灵魂状态复活（回血满后调用）
-- ────────────────────────────────────────────────────────────
function npc_ghost.ReviveFromGhost(inst)
    if not inst._is_ghost_mode then return end
    WandaReviveDbg(inst, "ReviveFromGhost begin")
    WalterGhostDbg(inst, "ReviveFromGhost 开始")
    -- 银项链：复活的诊断日志
    if _G.NPCFRIENDS_SILVERNECKLACE_UTILS and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.DebugLog then
        local inv = inst.components and inst.components.inventory
        local body = inv and inv:GetEquippedItem(_G.EQUIPSLOTS.BODY) or nil
        local has_silv = body ~= nil and body.prefab == "silvernecklace"
        _G.NPCFRIENDS_SILVERNECKLACE_UTILS.DebugLog(
            "npc_ghost.ReviveFromGhost", inst,
            "silv_in_body=" .. tostring(has_silv))
    end
    inst._is_ghost_mode = false
    if inst.npc_character_type == "walter" then
        inst._npc_reviving_from_ghost = true
        WobyRide.DisableForDeath(inst)
        WalterGhostDbg(inst, "ReviveFromGhost 设置复活锁后")
    end
    if inst.AnimState ~= nil then
        inst.AnimState:SetBank("ghost")
        inst.AnimState:SetBuild("ghost_build")
        WalterGhostDbg(inst, "ReviveFromGhost 切 ghost build 后")
    end

    if inst._ghost_regen_task then
        inst._ghost_regen_task:Cancel()
        inst._ghost_regen_task = nil
    end

    if inst._amulet_search_task then
        inst._amulet_search_task:Cancel()
        inst._amulet_search_task = nil
    end
    inst._target_amulet = nil

    if inst.npc_character_type ~= "walter" then
        inst:RemoveTag("noattack")
    end
    inst:RemoveTag("ghost")
    inst:RemoveTag("fireimmune")  -- 恢复可被点燃
    -- 恢复喂食标签（敌对角色除外）
    if not inst:HasTag("npc_hostile") then
        inst:AddTag("handfed")
        inst:AddTag("fedbyall")
        inst:AddTag("OMNI_eater")
    end
    -- notarget 保留：复活后继续处于“不被索敌”状态，进入战斗时 newcombattarget 会自动移除

    -- 恢复战斗能力
    inst.components.health.invincible = false
    if inst.components.combat then
        inst.components.combat.canattack = true
    end
    if inst.npc_character_type == "walter" then
        inst:AddTag("noattack")
        inst:AddTag("notarget")
        if inst.components.combat then
            inst.components.combat.canattack = false
            inst.components.combat:SetTarget(nil)
            inst.components.combat:CancelAttack()
        end
        WalterGhostDbg(inst, "ReviveFromGhost 禁止战斗后")
    end

    -- 清除 health.is_corpsing 标记（death 时由引擎设置，阻止后续 DoDelta 生效）
    if inst.components.health then
        inst.components.health.is_corpsing = nil
        if inst.npc_character_type == "wanda" then
            -- 旺达复活流程：先以老年阈值血量复活，待复活动画稳定后再过渡到年轻态
            local old_th = NPC_TUNING.WANDA_AGE_THRESHOLD_OLD or 0.25
            local old_hp = math.max(1, math.floor(inst.components.health.maxhealth * old_th))
            inst._wanda_reviving = true
            inst.components.health:SetCurrentHealth(old_hp)
            inst:PushEvent("healthdelta", { oldpercent = 0, newpercent = inst.components.health:GetPercent() })
            WandaReviveDbg(inst, "revive set old hp=%d pct=%.3f", old_hp, inst.components.health:GetPercent())
            if inst._wanda_postrevive_task ~= nil then
                inst._wanda_postrevive_task:Cancel()
            end
            inst._wanda_postrevive_task = inst:DoTaskInTime(3, function(i)
                if not (i and i:IsValid()) or i._is_ghost_mode or i.components.health == nil then
                    return
                end
                i.components.health:SetCurrentHealth(i.components.health.maxhealth)
                i:PushEvent("healthdelta", { oldpercent = old_th, newpercent = 1 })
                i._wanda_reviving = nil
                WandaReviveDbg(i, "postrevive set full hp=%d pct=%.3f", i.components.health.maxhealth, i.components.health:GetPercent())
            end)
        else
            inst.components.health:SetCurrentHealth(inst.components.health.maxhealth)
            inst:PushEvent("healthdelta", { oldpercent = 0, newpercent = 1 })
        end
    end

    -- 移除幽灵模式的 trader 组件
    -- 必须 RemoveComponent 而非仅 Disable：ACTIONS.FEED.fn
    -- 采用 if trader / elseif eater 互斥分支，trader 存在时永远不会
    -- 走 eater:Eat() 路径，导致复活后喂食失败。
    -- 下次死亡时 EnterGhostMode 会重新 AddComponent("trader")。
    if inst.components.trader then
        inst.components.trader:Disable()
        inst:RemoveComponent("trader")
    end

    -- 唤醒大脑：灵魂模式中所有行为节点返回 FAILED → PriorityNode 返回 FAILED
    --   → GetSleepTime 返回 nil → BrainWrangler 将大脑休眠（Hibernate）。
    --   复活后必须显式唤醒，否则大脑永远不再被调度，NPC 会站在原地不动。
    if inst.brain then
        inst.brain:ForceUpdate()
        WalterGhostDbg(inst, "ReviveFromGhost 强制刷新 brain 后")
    end

    -- 通知状态图播放复活动画（dissipate → 切回角色 build → wakeup）
    if inst.sg then
        if inst.AnimState ~= nil then
            inst.AnimState:SetBank("ghost")
            inst.AnimState:SetBuild("ghost_build")
        end
        WandaReviveDbg(inst, "GoToState(revive_from_ghost)")
        WalterGhostDbg(inst, "ReviveFromGhost 进入 revive_from_ghost 前")
        inst.sg:GoToState("revive_from_ghost")
        WalterGhostDbg(inst, "ReviveFromGhost 进入 revive_from_ghost 后")
    end

    -- 复活台词（延迟到复活动画快结束时显示）
    inst:DoTaskInTime(2, function()
        if inst:IsValid() and not inst._is_ghost_mode and inst.components.talker then
            -- 温蒂使用专属复活台词，其他角色使用通用复活台词
            local speech_pool = (inst.npc_character_type == "wendy" and NPC_SPEECH.ABIGAIL_REVIVE)
                                or NPC_SPEECH.REVIVE
            local line = NPC_SPEECH.GetLine(speech_pool, inst.npc_character_type)
            if line then inst.components.talker:Say(line) end
        end
    end)

    inst:DoTaskInTime(4, function()
        if inst:IsValid() and not inst._is_ghost_mode
           and not inst._is_weremoose then  -- 鹿人形态有独立外观，不覆盖
            if inst.sg ~= nil
                and inst.sg.currentstate ~= nil
                and inst.sg.currentstate.name == "revive_from_ghost" then
                WalterGhostDbg(inst, "ReviveFromGhost 4秒外观恢复跳过：仍在复活动画")
                return
            end
            local app = APPEARANCE[inst.npc_character_type] or APPEARANCE.npcfriend
            inst.AnimState:SetBank(app.bank)
            inst.AnimState:SetBuild(app.build)
            WalterGhostDbg(inst, "ReviveFromGhost 4秒外观恢复执行", "bank=" .. tostring(app.bank), "build_target=" .. tostring(app.build))
            if inst.npc_character_type == "wanda" and inst._wanda_reapply_overrides ~= nil then
                inst._wanda_reapply_overrides(inst)
            end
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            if inst.npc_character_type == "wanda" and inst.components and inst.components.health then
                local p = inst.components.health:GetPercent()
                inst:PushEvent("healthdelta", { oldpercent = p, newpercent = p })
            end
            -- 银项链：复活后按当前装备状态恢复狼猪/原型。
            -- 此处刚把 AnimState 切回 app.build，相当于 NPC 形态被重置；
            -- 若死前是变身后的狼猪 + 项链仍在身上，ApplyFinalFormAfterLoad
            -- 会保存当前正确的外观快照并重新启动变身。
            -- 注意：_silvernecklace_were 此时可能仍是 true（死前的状态），需要先复位，
            -- 否则 ApplyFinalFormAfterLoad 的 is_were 判断会误以为已是狼猪、跳过变身。
            inst._silvernecklace_were = false
            inst._silvernecklace_transform_pending = false
            inst._silvernecklace_reform_pending = false
            inst._silvernecklace_queue_reform = false
            if _G.NPCFRIENDS_SILVERNECKLACE_UTILS
                and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad then
                _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad(inst)
            end
        end
    end)

    -- 银项链：6 秒兜底（若 4 秒任务因仍在 revive_from_ghost 动画而跳过，
    -- 这里再补一次同步；ApplyFinalFormAfterLoad 自身幂等）。
    inst:DoTaskInTime(6, function()
        if inst:IsValid() and not inst._is_ghost_mode and not inst._is_weremoose
            and _G.NPCFRIENDS_SILVERNECKLACE_UTILS
            and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad then
            _G.NPCFRIENDS_SILVERNECKLACE_UTILS.ApplyFinalFormAfterLoad(inst)
        end
    end)
    
    -- 复活后重启lucy搜索（仅限Woodie）
    if inst._is_woodie then
        local woodie_mod = require("npc/characters/woodie")
        if woodie_mod and woodie_mod.StartLucySearch then
            inst:DoTaskInTime(1, function()
                if inst:IsValid() and inst._is_woodie then
                    woodie_mod.StartLucySearch(inst)
                end
            end)
        end
    end

    -- 复活后重启伯尼定期任务（仅限Willow）
    if inst.npc_character_type == "willow" then
        local willow_mod = require("npc/characters/willow")
        if willow_mod and willow_mod.restart_bernie_tasks then
            inst:DoTaskInTime(1, function()
                if inst:IsValid() and not inst._is_ghost_mode then
                    willow_mod.restart_bernie_tasks(inst)
                end
            end)
        end
    end

    -- 复活后重启辅助效果定期任务（仅限Wickerbottom）
    if inst.npc_character_type == "wickerbottom" then
        local wb_mod = require("npc/characters/wickerbottom")
        if wb_mod and wb_mod.restart_scholar_tasks then
            inst:DoTaskInTime(1, function()
                if inst:IsValid() and not inst._is_ghost_mode then
                    wb_mod.restart_scholar_tasks(inst)
                end
            end)
        end
    end
end

-- ────────────────────────────────────────────────────────────
-- 启动灵魂回血定时器
-- ────────────────────────────────────────────────────────────
function npc_ghost.StartGhostRegen(inst)
    if inst._ghost_regen_task then
        inst._ghost_regen_task:Cancel()
        inst._ghost_regen_task = nil
    end
    local char_stats = NPC_TUNING.CHARACTER_STATS[inst.npc_character_type]
    local regen_amount = (char_stats and char_stats.ghost_regen) or NPC_TUNING.GHOST_REGEN_PER_SEC
    inst._ghost_regen_task = inst:DoPeriodicTask(1, function(inst2)
        if not inst2:IsValid() or not inst2._is_ghost_mode then return end
        local h = inst2.components.health
        if h then
            h.currenthealth = math.min(h.currenthealth + regen_amount, h.maxhealth)
            inst2:PushEvent("healthdelta", { oldpercent = 0, newpercent = h:GetPercent() })
            if h.currenthealth >= h.maxhealth then
                npc_ghost.ReviveFromGhost(inst2)
            end
        end
    end)
end

-- ────────────────────────────────────────────────────────────
-- 进入灵魂模式（核心逻辑）
-- 被 death handler 和 OnLoad 共用
-- ────────────────────────────────────────────────────────────
function npc_ghost.EnterGhostMode(inst)
    WandaReviveDbg(inst, "EnterGhostMode begin")
    WalterGhostDbg(inst, "EnterGhostMode 开始")
    -- 银项链：死亡进入灵魂模式的诊断日志（确认项链是否仍在身上）
    if _G.NPCFRIENDS_SILVERNECKLACE_UTILS and _G.NPCFRIENDS_SILVERNECKLACE_UTILS.DebugLog then
        local inv = inst.components and inst.components.inventory
        local body = inv and inv:GetEquippedItem(_G.EQUIPSLOTS.BODY) or nil
        local has_silv = body ~= nil and body.prefab == "silvernecklace"
        _G.NPCFRIENDS_SILVERNECKLACE_UTILS.DebugLog(
            "npc_ghost.EnterGhostMode", inst,
            "silv_in_body=" .. tostring(has_silv))
    end
    if inst.npc_character_type == "walter" then
        WobyRide.DisableForDeath(inst)
        WalterGhostDbg(inst, "EnterGhostMode 禁用 Woby 后")
    end
    inst.components.health.currenthealth = 1
    inst.components.health.invincible    = true
    inst._is_ghost_mode = true
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:StopMoving()
        inst.components.locomotor:Stop()
    end

    if inst.components.burnable and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.components.freezable and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    inst:AddTag("fireimmune")

    inst:AddTag("notarget")
    inst:AddTag("noattack")
    inst:AddTag("ghost")
    inst:RemoveTag("handfed")
    inst:RemoveTag("fedbyall")
    WalterGhostDbg(inst, "EnterGhostMode 设置幽灵标签后")

    -- 配置 trader 组件：幽灵状态下接受 reviver 标签物品（告密的心）
    -- 仿照 player_common.lua 中玩家幽灵的 ShouldAcceptItem + OnGetItem 实现
    if not inst.components.trader then
        inst:AddComponent("trader")
    end
    inst.components.trader:Enable()
    inst.components.trader.acceptnontradable = true  -- 允许接受告密的心（非可交易物品）
    inst.components.trader.onaccept = function(trader_inst, giver, item)
        if item ~= nil and item:HasTag("reviver") and trader_inst._is_ghost_mode then
            if item.skin_sound and item.SoundEmitter then
                item.SoundEmitter:PlaySound(item.skin_sound)
            end
            
            item:Remove()
            
            -- 延迟到下一帧复活，确保 GIVE action 完全处理完毕后再切换状态图
            -- 否则 GoToState("revive_from_ghost") 会被后续 action 处理覆盖
            trader_inst:DoTaskInTime(0, function()
                if trader_inst:IsValid() and trader_inst._is_ghost_mode then
                    npc_ghost.ReviveFromGhost(trader_inst)
                end
            end)
        end
    end
    inst.components.trader.test = function(trader_inst, item, giver)
        return trader_inst._is_ghost_mode and item ~= nil and item:HasTag("reviver")
    end

    -- 保存原始角色 bank/build（复活时恢复）
    local app = APPEARANCE[inst.npc_character_type] or APPEARANCE.npcfriend
    inst._saved_bank = app.bank
    local actual_build = nil
    if inst.AnimState ~= nil and inst.AnimState.GetBuild ~= nil then
        actual_build = inst.AnimState:GetBuild()
    end
    inst._saved_build = (actual_build ~= nil and actual_build ~= "") and actual_build or app.build
    WandaReviveDbg(inst, "save bank=%s build=%s actual=%s", tostring(inst._saved_bank), tostring(inst._saved_build), tostring(actual_build))
    WalterGhostDbg(inst, "EnterGhostMode 保存外观", "saved_bank=" .. tostring(inst._saved_bank), "saved_build=" .. tostring(inst._saved_build), "actual_build=" .. tostring(actual_build))
    -- 切换到幽灵外观
    inst.AnimState:SetBank("ghost")
    inst.AnimState:SetBuild("ghost_build")
    local gc = NPC_TUNING.GHOST_COLOUR
    inst.AnimState:SetMultColour(gc[1], gc[2], gc[3], gc[4])
    WalterGhostDbg(inst, "EnterGhostMode 切 ghost build 后")

    -- 禁止战斗
    if inst.components.combat then
        inst.components.combat.canattack = false
        inst.components.combat:SetTarget(nil)
    end
    WalterGhostDbg(inst, "EnterGhostMode 禁止战斗后")

    -- 强制周围已锁定本 NPC 的实体脱锁
    local cx, cy, cz = inst.Transform:GetWorldPosition()
    for _, ent in ipairs(_G.TheSim:FindEntities(cx, cy, cz, 30)) do
        if ent ~= inst and ent.components.combat
           and ent.components.combat.target == inst then
            ent.components.combat:SetTarget(nil)
        end
    end

    -- 缓存领队（防止其他 death 监听清除 follower.leader）
    local saved_leader = inst.components.follower and inst.components.follower.leader
    if saved_leader then
        inst:DoTaskInTime(0, function()
            if inst:IsValid() and inst._is_ghost_mode and inst.components.follower
               and inst.components.follower.leader == nil then
                inst.components.follower:SetLeader(saved_leader)
            end
        end)
    end

    -- 每秒回血
    npc_ghost.StartGhostRegen(inst)

-- 每4秒搜索附近的重生护符（范围以幽灵 NPC 自己为中心）
    npc_ghost.StartAmuletSearch(inst)
    
    -- 进入幽灵模式时停止lucy搜索
    if inst._lucy_search_task then
        inst._lucy_search_task:Cancel()
        inst._lucy_search_task = nil
    end
    inst._target_lucy = nil
end

-- ────────────────────────────────────────────────────────────
-- 启动护符搜索定时器
-- 幽灵状态下每4秒搜索周围地面上的重生护符
-- 搜索中心是幽灵 NPC 自己，不是领队玩家。
-- ────────────────────────────────────────────────────────────
function npc_ghost.StartAmuletSearch(inst)
    if inst._amulet_search_task then
        inst._amulet_search_task:Cancel()
        inst._amulet_search_task = nil
    end
    inst._target_amulet = nil

    if not CustomCombat.IsEnabled("auto_revive_amulet_enabled", inst) then
        return
    end
    
    inst._amulet_search_task = inst:DoPeriodicTask(4, function(i)
        if not i:IsValid() or not i._is_ghost_mode then
            -- 已复活或无效，取消搜索
            if i._amulet_search_task then
                i._amulet_search_task:Cancel()
                i._amulet_search_task = nil
            end
            return
        end
        
        -- 如果已经有有效的目标护符，不重复搜索
        if i._target_amulet and i._target_amulet:IsValid() then
            -- 验证护符仍然可用（未被拾取、未进入Limbo）
            if i._target_amulet.components.inventoryitem 
               and not i._target_amulet.components.inventoryitem:IsHeld()
               and not i._target_amulet:IsInLimbo() then
                return
            else
                -- 护符已不可用，清除目标
                i._target_amulet = nil
            end
        end
        
        if not CustomCombat.IsEnabled("auto_revive_amulet_enabled", i) then
            i._target_amulet = nil
            if i._amulet_search_task then
                i._amulet_search_task:Cancel()
                i._amulet_search_task = nil
            end
            return
        end

        -- 搜索地面上的重生护符，中心点是幽灵 NPC 自己
        local x, y, z = i.Transform:GetWorldPosition()
        local search_range = CustomCombat.GetNumber("auto_revive_amulet_range", 25, i)
        local amulets = _G.TheSim:FindEntities(x, y, z, search_range, {"resurrector"}, {"INLIMBO", "NOCLICK"})
        for _, amulet in ipairs(amulets) do
            if amulet:IsValid() and amulet.prefab == "amulet" 
               and not amulet:IsInLimbo()
               and amulet.components.inventoryitem 
               and not amulet.components.inventoryitem:IsHeld()
               -- 过滤掉船上的护符（避免幽灵走向水面）
               and amulet:GetCurrentPlatform() == nil then
                i._target_amulet = amulet
                break
            end
        end
    end)
end

return npc_ghost
