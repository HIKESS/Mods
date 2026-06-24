-- Woodie: 砍树高手，自带露西斧

local NPC_SPEECH = require("npc_speech")
local NPC_TUNING = require("npc_tuning")
local npc_utils  = require("npc/npc_utils")

-- 战斗调试日志
local function CombatLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_COMBAT then print(...) end
end

-- ────────────────────────────────────────────────────────────
-- 检查NPC是否在任意位置持有Lucy（装备栏 + 背包 + overflow）
-- ────────────────────────────────────────────────────────────
local function HasLucyAnywhere(inst)
    local inv = inst.components.inventory
    if not inv then return false end
    
    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand and hand.prefab == "lucy" then
        return true
    end
    
    return inv:FindItem(function(item) return item.prefab == "lucy" end) ~= nil
end

-- ────────────────────────────────────────────────────────────
-- 启动露西斧搜索定时器
-- ────────────────────────────────────────────────────────────
local function StartLucySearch(inst)
    if inst._lucy_search_task then
        inst._lucy_search_task:Cancel()
        inst._lucy_search_task = nil
    end
    
    inst._lucy_search_task = inst:DoPeriodicTask(3, function(i)
        if not i:IsValid() or not i._is_woodie then return end
        
        if i._is_ghost_mode then return end
        
        if HasLucyAnywhere(i) then
            i._target_lucy = nil
            return
        end
        
        if i._target_lucy and i._target_lucy:IsValid() 
           and not i._target_lucy:IsInLimbo()
           and i._target_lucy.components.inventoryitem
           and not i._target_lucy.components.inventoryitem:IsHeld() then
            return
        end
        i._target_lucy = nil
        
        local x, y, z = i.Transform:GetWorldPosition()
        local items = TheSim:FindEntities(x, y, z, 20, nil, {"INLIMBO", "NOCLICK"})
        for _, item in ipairs(items) do
            if item.prefab == "lucy"
               and item:IsValid()
               and not item:IsInLimbo()
               and item.components.inventoryitem
               and not item.components.inventoryitem:IsHeld() then
                i._target_lucy = item
                break
            end
        end
        
        if not i._target_lucy then
            local now = GetTime()
            if not i._lucy_lost_speak_time or (now - i._lucy_lost_speak_time) >= 30 then
                i._lucy_lost_speak_time = now
                if i.components.talker then
                    local line = NPC_SPEECH.GetLine(NPC_SPEECH.TALK_LUCY_LOST, i.npc_character_type)
                    if line then
                        i.components.talker:Say(line)
                    end
                end
            end
        end
    end)
end

-- ────────────────────────────────────────────────────────────
-- 停止露西斧搜索定时器
-- ────────────────────────────────────────────────────────────
local function StopLucySearch(inst)
    if inst._lucy_search_task then
        inst._lucy_search_task:Cancel()
        inst._lucy_search_task = nil
    end
    inst._target_lucy = nil
end

-- ════════════════════════════════════════════════════════════
--  鹿人变身系统（战斗触发）
-- ════════════════════════════════════════════════════════════

local function CancelRevertTask(inst)
    if inst._weremoose_revert_task then
        inst._weremoose_revert_task:Cancel()
        inst._weremoose_revert_task = nil
    end
end

-- ────────────────────────────────────────────────────────────
-- 变身为鹿人
-- ────────────────────────────────────────────────────────────
local function BecomeWeremoose(inst)
    if inst._is_weremoose then return end
    if inst._is_ghost_mode then return end
    inst._is_weremoose = true

    local app = npc_utils.APPEARANCE[inst.npc_character_type] or npc_utils.APPEARANCE.npcfriend
    inst._normal_bank  = app.bank
    inst._normal_build = app.build

    inst._normal_damage     = inst.components.combat.defaultdamage
    inst._normal_absorption = inst.components.health and inst.components.health.absorb or 0
    inst._normal_runspeed   = inst.components.locomotor.runspeed
    inst._normal_walkspeed  = inst.components.locomotor.walkspeed

    inst:AddTag("weremoose")

    inst.components.combat:SetDefaultDamage(NPC_TUNING.WEREMOOSE_DAMAGE)
    if inst.components.health then
        inst.components.health:SetAbsorptionAmount(NPC_TUNING.WEREMOOSE_ABSORPTION)
    end
    inst.components.locomotor.runspeed  = NPC_TUNING.WEREMOOSE_RUN_SPEED
    inst.components.locomotor.walkspeed = NPC_TUNING.WEREMOOSE_RUN_SPEED

    if inst.sg then
        inst.sg:GoToState("weremoose_transform")
    end

    CombatLog("[NPC_WOODIE] 变身鹿人! damage=" .. NPC_TUNING.WEREMOOSE_DAMAGE
          .. " absorption=" .. NPC_TUNING.WEREMOOSE_ABSORPTION
          .. " speed=" .. NPC_TUNING.WEREMOOSE_RUN_SPEED)
end

-- ────────────────────────────────────────────────────────────
-- 还原为普通形态
-- ────────────────────────────────────────────────────────────
local function RevertFromWeremoose(inst)
    if not inst._is_weremoose then return end

    if inst.sg and inst.sg:HasStateTag("nointerrupt") then
        CancelRevertTask(inst)
        inst._weremoose_revert_task = inst:DoTaskInTime(1, function(i)
            i._weremoose_revert_task = nil
            if i._is_weremoose
               and (not i.components.combat or not i.components.combat.target) then
                RevertFromWeremoose(i)
            end
        end)
        return
    end

    inst._is_weremoose = false

    inst:RemoveTag("weremoose")

    if inst._normal_damage then
        inst.components.combat:SetDefaultDamage(inst._normal_damage)
    end
    if inst.components.health and inst._normal_absorption ~= nil then
        inst.components.health:SetAbsorptionAmount(inst._normal_absorption)
    end
    if inst._normal_runspeed then
        inst.components.locomotor.runspeed  = inst._normal_runspeed
        inst.components.locomotor.walkspeed = inst._normal_walkspeed or inst._normal_runspeed
    end

    if inst.sg then
        inst.sg:GoToState("weremoose_revert")
    end

    CombatLog("[NPC_WOODIE] 还原普通形态")
end

-- ────────────────────────────────────────────────────────────
-- 战斗事件监听：获得新目标 → 变身
-- ────────────────────────────────────────────────────────────
local function OnNewCombatTarget(inst, data)
    if not inst._is_woodie then return end
    if inst._is_ghost_mode then return end
    if data and data.target then
        CancelRevertTask(inst)
        if not inst._is_weremoose then
            BecomeWeremoose(inst)
        end
    end
end

-- ────────────────────────────────────────────────────────────
-- 战斗事件监听：丢失/放弃目标 → 延迟变回
-- ────────────────────────────────────────────────────────────
local function OnLostCombatTarget(inst)
    if not inst._is_woodie then return end
    if not inst._is_weremoose then return end

    if inst.components.combat and inst.components.combat.target
       and inst.components.combat.target:IsValid() then
        return
    end

    CancelRevertTask(inst)
    inst._weremoose_revert_task = inst:DoTaskInTime(
        NPC_TUNING.WEREMOOSE_REVERT_DELAY or 3,
        function(i)
            i._weremoose_revert_task = nil
            if i.components.combat and i.components.combat.target == nil then
                RevertFromWeremoose(i)
            end
        end)
end

-- ────────────────────────────────────────────────────────────
-- 死亡/幽灵模式 → 立即还原
-- ────────────────────────────────────────────────────────────
local function OnWoodieDeath(inst)
    CancelRevertTask(inst)
    if inst._is_weremoose then
        inst._is_weremoose = false
        inst:RemoveTag("weremoose")
        if inst._normal_damage then
            inst.components.combat:SetDefaultDamage(inst._normal_damage)
        end
        if inst.components.health and inst._normal_absorption ~= nil then
            inst.components.health:SetAbsorptionAmount(inst._normal_absorption)
        end
        if inst._normal_runspeed then
            inst.components.locomotor.runspeed  = inst._normal_runspeed
            inst.components.locomotor.walkspeed = inst._normal_walkspeed or inst._normal_runspeed
        end
        -- 恢复外观
        if inst._normal_bank then
            inst.AnimState:SetBank(inst._normal_bank)
        end
        if inst._normal_build then
            inst.AnimState:SetBuild(inst._normal_build)
        end
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
end

-- ────────────────────────────────────────────────────────────
-- 恢复鹿人状态（加载存档时使用，不播放变身动画）
-- ────────────────────────────────────────────────────────────
local function RestoreWeremooseSilent(inst)
    if inst._is_weremoose then return end
    if inst._is_ghost_mode then return end
    inst._is_weremoose = true

    local app = npc_utils.APPEARANCE[inst.npc_character_type] or npc_utils.APPEARANCE.npcfriend
    inst._normal_bank  = app.bank
    inst._normal_build = app.build

    inst._normal_damage     = inst.components.combat.defaultdamage
    inst._normal_absorption = inst.components.health and inst.components.health.absorb or 0
    inst._normal_runspeed   = inst.components.locomotor.runspeed
    inst._normal_walkspeed  = inst.components.locomotor.walkspeed

    inst:AddTag("weremoose")
    inst.components.combat:SetDefaultDamage(NPC_TUNING.WEREMOOSE_DAMAGE)
    if inst.components.health then
        inst.components.health:SetAbsorptionAmount(NPC_TUNING.WEREMOOSE_ABSORPTION)
    end
    inst.components.locomotor.runspeed  = NPC_TUNING.WEREMOOSE_RUN_SPEED
    inst.components.locomotor.walkspeed = NPC_TUNING.WEREMOOSE_RUN_SPEED

    inst.AnimState:SetBank("weremoose")
    inst.AnimState:SetBuild("weremoose_build")
    inst.AnimState:SetMultColour(0.8, 0.7, 0.8, 1)

    CombatLog("[NPC_WOODIE] 存档恢复鹿人状态")
end

-- ────────────────────────────────────────────────────────────
-- 初始化鹿人战斗系统
-- ────────────────────────────────────────────────────────────
local function SetupWeremooseSystem(inst)
    inst._is_weremoose = false
    inst._weremoose_revert_task = nil

    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    inst:ListenForEvent("droppedtarget", OnLostCombatTarget)
    inst:ListenForEvent("losttarget", OnLostCombatTarget)

    inst:ListenForEvent("death", OnWoodieDeath)
    inst:ListenForEvent("enterghost", OnWoodieDeath)

    if inst._load_as_weremoose then
        inst._load_as_weremoose = nil
        RestoreWeremooseSilent(inst)
        if not inst.components.combat.target then
            OnLostCombatTarget(inst)
        end
    end
end

return {
    on_death = function(inst)
        OnWoodieDeath(inst)
        return false  -- 返回 false → npcfriend.lua 继续执行 EnterGhostMode
    end,

    on_apply = function(inst, stats)
        inst._is_woodie = true  -- 标记为伐木工（行为树识别用）
        inst:AddTag("woodcutter")  -- 砍树状态机识别用（第8帧快速重启、专属动画）

        if inst._woodie_chop_filter == nil then
            inst._woodie_chop_filter = { small = true, medium = true, big = true }
        end

        if inst._woodie_dig_stump == nil then
            inst._woodie_dig_stump = false
        end

        if inst._woodie_chop_twiggy == nil then
            inst._woodie_chop_twiggy = true
        end
        
        if inst.components.inventory then
            inst:DoTaskInTime(0.5, function()
                if inst:IsValid() and inst.components.inventory then
                    local lucy = inst.components.inventory:FindItem(function(item)
                        return item.prefab == "lucy"
                    end)
                    if lucy and lucy.components.equippable then
                        inst.components.inventory:Equip(lucy)
                    end
                end
            end)
        end
        
        inst:DoTaskInTime(1, function()
            if inst:IsValid() and inst._is_woodie then
                StartLucySearch(inst)
            end
        end)

        inst:DoTaskInTime(1.5, function()
            if inst:IsValid() and inst._is_woodie then
                SetupWeremooseSystem(inst)
            end
        end)
    end,

    on_save = function(inst, data)
        data.is_weremoose = inst._is_weremoose or false
        if inst._woodie_chop_filter then
            data.chop_filter = {
                small  = inst._woodie_chop_filter.small  ~= false,
                medium = inst._woodie_chop_filter.medium ~= false,
                big    = inst._woodie_chop_filter.big    ~= false,
            }
        end
        data.dig_stump = inst._woodie_dig_stump == true
        data.chop_twiggy = inst._woodie_chop_twiggy ~= false
    end,

    on_load = function(inst, data)
        if data and data.is_weremoose then
            inst._load_as_weremoose = true
        end
        if data and data.chop_filter then
            inst._woodie_chop_filter = {
                small  = data.chop_filter.small  ~= false,
                medium = data.chop_filter.medium ~= false,
                big    = data.chop_filter.big    ~= false,
            }
        end
        if data and data.dig_stump ~= nil then
            inst._woodie_dig_stump = data.dig_stump == true
        end
        if data and data.chop_twiggy ~= nil then
            inst._woodie_chop_twiggy = data.chop_twiggy ~= false
        end
    end,
    
    StartLucySearch = StartLucySearch,
    StopLucySearch = StopLucySearch,
    BecomeWeremoose = BecomeWeremoose,
    RevertFromWeremoose = RevertFromWeremoose,
}
