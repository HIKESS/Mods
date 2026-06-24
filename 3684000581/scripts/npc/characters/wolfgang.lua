-- scripts/npc/characters/wolfgang.lua
-- Wolfgang: 饱食度驱动三状态系统（虚弱/正常/威猛）
-- 饱食度 < 100 → 虚弱（伤害 0.75x，体型 0.9x）
-- 饱食度 100~199 → 正常（伤害 1.0x，体型 1.0x）
-- 饱食度 >= 200 → 威猛（伤害 2.0x，体型 1.25x）

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")
local npc_utils  = require("npc/npc_utils")
local InvUtil    = require("npc/npc_inventory_util")

local UpdateHoverInfo = npc_utils.UpdateHoverInfo

-- ────────────────────────────────────────────────────────────
-- 状态配置（从 npc_tuning.lua 集中管理）
-- ────────────────────────────────────────────────────────────
local STATE_CONFIG = NPC_TUNING.WOLFGANG_STATE_CONFIG


local function RecalcDamage(inst)
    if not inst.components.combat then return end
    local config = STATE_CONFIG[inst._wolfgang_state or "normal"]
    if not config then return end
    inst.components.combat.damagemultiplier = config.damage_mult
    inst.npc_damage_mult = config.damage_mult
    inst.components.combat.customdamagemultfn = function(inst, target, weapon, multiplier, mount)
        local mult = inst.npc_damage_mult or 1
        if weapon ~= nil and weapon.components.weapon then
            local base = inst.npc_base_damage or 0
            local weapon_dmg = weapon.components.weapon:GetDamage(inst, target) or 0
            if weapon_dmg > 0 and base > 0 then
                return (base + weapon_dmg) / weapon_dmg
            end
            return 1
        else
            return (mult ~= 0) and (1 / mult) or 1
        end
    end

    local base = inst.npc_base_damage or 0
    local weapon_dmg = 0
    local inv = inst.components.inventory
    if inv then
        local weapon = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if weapon and weapon.components.weapon then
            weapon_dmg = weapon.components.weapon:GetDamage(inst) or weapon.components.weapon.damage or 0
        end
    end
    inst.components.combat:SetDefaultDamage((base + weapon_dmg) * config.damage_mult)
end

-- ────────────────────────────────────────────────────────────
-- 装备/卸装武器时重算伤害（在 npc_inventory 之后触发，覆盖其结果）
-- ────────────────────────────────────────────────────────────
local function SetupDamageRecalc(inst)
    inst:ListenForEvent("equip", function(i, data)
        if data and data.eslot == EQUIPSLOTS.HANDS then
            RecalcDamage(i)
        end
    end)
    inst:ListenForEvent("unequip", function(i, data)
        if data and data.eslot == EQUIPSLOTS.HANDS then
            RecalcDamage(i)
        end
    end)
end

-- ────────────────────────────────────────────────────────────
-- 饱食度 → 状态映射
-- ────────────────────────────────────────────────────────────
local function GetHungerState(hunger)
    if hunger < NPC_TUNING.WOLFGANG_WIMPY_THRESHOLD then
        return "wimpy"
    elseif hunger >= NPC_TUNING.WOLFGANG_MIGHTY_THRESHOLD then
        return "mighty"
    else
        return "normal"
    end
end

-- ────────────────────────────────────────────────────────────
-- 更新威猛状态（伤害倍率 + 体型缩放）
-- force: 强制刷新（忽略状态未变检测）
-- ────────────────────────────────────────────────────────────
local function UpdateMightyState(inst, force)
    if not inst._wolfgang_hunger then return end
    if inst._is_ghost_mode then return end
    if inst.components.health and inst.components.health:IsDead() then return end

    local new_state = GetHungerState(inst._wolfgang_hunger)
    local old_state = inst._wolfgang_state
    if new_state == old_state and not force then return end

    inst._wolfgang_state = new_state
    local config = STATE_CONFIG[new_state]

    RecalcDamage(inst)

    inst.Transform:SetScale(config.scale, config.scale, config.scale)

    inst._attack_speed_mult = config.attack_speed

    UpdateHoverInfo(inst)

    if old_state ~= nil and old_state ~= new_state then
        local speech = NPC_SPEECH.WOLFGANG_STATE_CHANGE
        if speech and speech[new_state] then
            local lines = speech[new_state]
            if inst.components.talker then
                inst.components.talker:Say(lines[math.random(#lines)])
            end
        end
    end
end

-- ────────────────────────────────────────────────────────────
-- 饱食度增减
-- ────────────────────────────────────────────────────────────
local function DeltaHunger(inst, delta)
    if not inst._wolfgang_hunger then return end
    local max_hunger = inst._wolfgang_max_hunger or NPC_TUNING.WOLFGANG_MAX_HUNGER
    inst._wolfgang_hunger = math.max(0, math.min(max_hunger, inst._wolfgang_hunger + delta))
    UpdateMightyState(inst)
end

-- ────────────────────────────────────────────────────────────
-- 智能进食：从背包中选择最优食物吃掉
-- ────────────────────────────────────────────────────────────
local function TryAutoEat(inst)
    if not inst._wolfgang_hunger then return false end
    if inst._is_ghost_mode then return false end
    if inst.components.health and inst.components.health:IsDead() then return false end
    if inst._wolfgang_hunger >= NPC_TUNING.WOLFGANG_MIGHTY_THRESHOLD then return false end

    local now = GetTime()
    if inst._wolfgang_eat_cd and now < inst._wolfgang_eat_cd then return false end

    local inv = inst.components.inventory
    if not inv then return false end

    local food_list = {}
    InvUtil.ForEachCarriedItem(inst, function(item)
        if item and item.components.edible then
            local hunger_val = item.components.edible:GetHunger(inst) or 0
            local health_val = item.components.edible:GetHealth(inst) or 0
            local foodtype = item.components.edible.foodtype
            local allowed_foodtypes = NPC_TUNING.WOLFGANG_AUTO_EAT_FOODTYPES or {}
            local blacklist = NPC_TUNING.WOLFGANG_AUTO_EAT_BLACKLIST or {}

            if not blacklist[item.prefab]
               and foodtype and allowed_foodtypes[foodtype]
               and hunger_val > 0
               and health_val >= 0 then
                table.insert(food_list, {
                    item = item,
                    hunger = hunger_val,
                    health = health_val,
                })
            end
        end
    end)

    if #food_list == 0 then return false end

    table.sort(food_list, function(a, b) return a.hunger > b.hunger end)

    local best = food_list[1]
    local food = best.item

    local food_to_eat
    if food.components.stackable and food.components.stackable:StackSize() > 1 then
        food_to_eat = food.components.stackable:Get()
    else
        inv:RemoveItem(food)
        food_to_eat = food
    end

    DeltaHunger(inst, best.hunger)

    if best.health > 0 and inst.components.health
       and not inst.components.health:IsDead() then
        inst.components.health:DoDelta(best.health, false, "food")
    end

    if food_to_eat:IsValid() then
        food_to_eat:Remove()
    end

    inst._wolfgang_eat_cd = now + (NPC_TUNING.WOLFGANG_AUTO_EAT_INTERVAL or 3)

    if inst.sg and not (inst.components.health and inst.components.health:IsDead()) then
        inst.sg:GoToState("eat")
    end

    return true
end

-- ────────────────────────────────────────────────────────────
-- 大肉棒腐烂减速：在沃尔夫冈物品栏/装备栏时腐烂速度减半
-- ────────────────────────────────────────────────────────────
local HAMBAT_PERISH_MULT = 0.5

local function SetHambatPerish(item, mult)
    if item and item.prefab == "hambat" and item.components.perishable then
        item.components.perishable.localPerishMultiplyer = mult
    end
end

local function SetupHambatPerishSystem(inst)
    inst:ListenForEvent("itemget", function(i, data)
        if data and data.item then SetHambatPerish(data.item, HAMBAT_PERISH_MULT) end
    end)
    inst:ListenForEvent("equip", function(i, data)
        if data and data.item then SetHambatPerish(data.item, HAMBAT_PERISH_MULT) end
    end)
    inst:ListenForEvent("itemlose", function(i, data)
        if data and data.item and data.item.prefab == "hambat" then
            i:DoTaskInTime(0, function()
                if not i:IsValid() then return end
                local item = data.item
                if not item:IsValid() then return end
                if item.components.inventoryitem and item.components.inventoryitem.owner == i then
                    return
                end
                SetHambatPerish(item, 1)
            end)
        end
    end)
    local inv = inst.components.inventory
    if inv then
        for slot_i = 1, inv.maxslots do
            SetHambatPerish(inv:GetItemInSlot(slot_i), HAMBAT_PERISH_MULT)
        end
        if EQUIPSLOTS then
            for _, eslot in pairs(EQUIPSLOTS) do
                SetHambatPerish(inv:GetEquippedItem(eslot), HAMBAT_PERISH_MULT)
            end
        end
    end
end

-- ────────────────────────────────────────────────────────────
-- 收到食物后立即检查自动进食（玩家喂食/物品入库后即时响应）
-- ────────────────────────────────────────────────────────────
local function SetupAutoEatOnReceive(inst)
    inst:ListenForEvent("itemget", function(i, data)
        if not data or not data.item then return end
        if not data.item.components.edible then return end
        if i._wolfgang_hunger and i._wolfgang_hunger < NPC_TUNING.WOLFGANG_MIGHTY_THRESHOLD then
            i:DoTaskInTime(0.1, function()
                if i:IsValid() and not i._is_ghost_mode then
                    TryAutoEat(i)
                end
            end)
        end
    end)
end

-- ────────────────────────────────────────────────────────────
-- 喂食恢复饱食度（监听 "oneat" 事件，玩家喂食/HealAndRetreat 吃饺子均触发）
-- ────────────────────────────────────────────────────────────
local function SetupFeedingHunger(inst)
    inst:ListenForEvent("oneat", function(i, data)
        if not i._wolfgang_hunger then return end
        if i._is_ghost_mode then return end
        if not data or not data.food then return end

        local food = data.food
        if food:IsValid() and food.components.edible then
            local hunger_val = food.components.edible:GetHunger(i) or 0
            if hunger_val ~= 0 then
                DeltaHunger(i, hunger_val)
            end
        end

        if i._wolfgang_hunger < NPC_TUNING.WOLFGANG_MIGHTY_THRESHOLD then
            i:DoTaskInTime(0.5, function()
                if i:IsValid() and not i._is_ghost_mode then
                    TryAutoEat(i)
                end
            end)
        end
    end)
end

-- ────────────────────────────────────────────────────────────
-- 启动饱食度流失 & 自动进食定时器
-- ────────────────────────────────────────────────────────────
local function StartHungerSystem(inst)
    if inst._wolfgang_hunger_task then
        inst._wolfgang_hunger_task:Cancel()
        inst._wolfgang_hunger_task = nil
    end

    local drain_rate = NPC_TUNING.WOLFGANG_HUNGER_DRAIN or 0.5

    inst._wolfgang_hunger_task = inst:DoPeriodicTask(1, function()
        if not inst:IsValid() then return end

        if inst._is_ghost_mode then
            if not inst._wolfgang_ghost_scale_done then
                inst._wolfgang_ghost_scale_done = true
                inst.Transform:SetScale(1, 1, 1)
            end
            inst._wolfgang_was_ghost = true
            return
        end

        if inst._wolfgang_was_ghost then
            inst._wolfgang_was_ghost = nil
            inst._wolfgang_ghost_scale_done = nil
            inst._wolfgang_state = nil  
            UpdateMightyState(inst, true)
            inst:DoTaskInTime(5, function()
                if inst:IsValid() and not inst._is_ghost_mode then
                    inst._wolfgang_state = nil
                    UpdateMightyState(inst, true)
                end
            end)
        end

        DeltaHunger(inst, -drain_rate)

        if inst._wolfgang_hunger < NPC_TUNING.WOLFGANG_MIGHTY_THRESHOLD then
            TryAutoEat(inst)
        end

        inst._wolfgang_hover_tick = (inst._wolfgang_hover_tick or 0) + 1
        if inst._wolfgang_hover_tick >= 5 then
            inst._wolfgang_hover_tick = 0
            UpdateHoverInfo(inst)
        end
    end)
end

-- ────────────────────────────────────────────────────────────
-- 导出角色模块钩子
-- ────────────────────────────────────────────────────────────
return {
    on_apply = function(inst, stats)
        inst._wolfgang_max_hunger = NPC_TUNING.WOLFGANG_MAX_HUNGER
        inst._wolfgang_hunger = inst._wolfgang_max_hunger
        inst._wolfgang_state = nil  -- 由 UpdateMightyState 设置

        if not inst._wolfgang_systems_setup then
            inst._wolfgang_systems_setup = true
            SetupHambatPerishSystem(inst)
            SetupAutoEatOnReceive(inst)
            SetupFeedingHunger(inst)    -- 喂食/吃饺子 → 恢复饱食度
            SetupDamageRecalc(inst)     -- 装备/卸装 → 重算伤害
        end

        UpdateMightyState(inst, true)

        StartHungerSystem(inst)
    end,

    on_save = function(inst, data)
        data.wolfgang_hunger = inst._wolfgang_hunger
        data.wolfgang_state = inst._wolfgang_state
    end,

    on_load = function(inst, data)
        if data and data.wolfgang_hunger then
            inst._wolfgang_hunger = data.wolfgang_hunger
            inst._wolfgang_state = nil  -- 强制重新计算
            inst:DoTaskInTime(0, function()
                if not inst:IsValid() then return end
                UpdateMightyState(inst, true)
                StartHungerSystem(inst)
            end)
        end
    end,
}
