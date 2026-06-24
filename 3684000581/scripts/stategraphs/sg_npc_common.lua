-- scripts/stategraphs/sg_npc_common.lua
-- ════════════════════════════════════════════════════════════
-- NPC 通用状态图组件（模块化）
-- ════════════════════════════════════════════════════════════


local InvUtil = require("npc/npc_inventory_util")
local NPC_TUNING = require("npc_tuning")

local SGNPCCommon = {}

local DEBUG_BEHAVIOR = NPC_TUNING.DEBUG_BEHAVIOR


-- ════════════════════════════════════════════════════════════
-- 兼容性工作执行：ForceWork
-- ════════════════════════════════════════════════════════════
function SGNPCCommon.ForceWork(target, worker, numworks)
    if target == nil or not target:IsValid() or worker == nil then return false end
    local wk = target.components and target.components.workable
    if wk == nil or not wk:CanBeWorked() then return false end

    numworks = numworks or 1
    local before = wk.workleft

    -- 1) 正常路径
    wk:WorkedBy(worker, numworks)

    -- 2) 被拦截兜底（target 可能已在正常路径中被移除/完成）
    if target:IsValid()
       and target.components ~= nil
       and target.components.workable == wk
       and wk.workable
       and wk:CanBeWorked()
       and wk.workleft == before then

        if numworks > 0 then
            if wk.workleft <= 1 then
                wk.workleft = 0
            else
                wk.workleft = wk.workleft - numworks
                if wk.workleft < 0.01 then
                    wk.workleft = 0
                end
            end
        end

        wk.lastworktime = GetTime()
        wk.lastworker = worker

        worker:PushEvent("working", { target = target })
        target:PushEvent("worked", { worker = worker, workleft = wk.workleft })

        if wk.onwork ~= nil then
            wk.onwork(target, worker, wk.workleft, numworks)
        end

        if wk.workleft <= 0 then
            local isplant = target:HasTag("plant")
                and not target:HasTag("burnt")
                and not (target.components.diseaseable ~= nil and target.components.diseaseable:IsDiseased())
            local pos = isplant and target:GetPosition() or nil

            if wk.onfinish ~= nil then
                wk.onfinish(target, worker)
            end
            target:PushEvent("workfinished", { worker = worker })
            worker:PushEvent("finishedwork", { target = target, action = wk.action })
            if isplant then
                TheWorld:PushEvent("plantkilled", { doer = worker, pos = pos, workaction = wk.action })
            end
        end
    end

    return true
end





local HEAVY_WALK_MAP = {
    run_pre  = "heavy_walk_pre",
    run_loop = "heavy_walk",
    run_pst  = "heavy_walk_pst",
}

local HEAVY_SPEED_MULT = TUNING.HEAVY_SPEED_MULT or 0.15

function SGNPCCommon.GetHeavyWalkAnim(default_anim)
    return HEAVY_WALK_MAP[default_anim] or "heavy_walk"
end





function SGNPCCommon.SaveBodyEquip(inst)
    local inv = inst.components.inventory
    if not inv then return end
    local body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
    if body and not body:HasTag("heavy") then
        inst._saved_body_equip = body
    else
        inst._saved_body_equip = nil
    end
end

function SGNPCCommon.RestoreBodyEquip(inst)
    local saved = inst._saved_body_equip
    inst._saved_body_equip = nil
    if not saved or not saved:IsValid() then return end
    local inv = inst.components.inventory
    if not inv then return end
    for i = 1, inv.maxslots do
        if inv:GetItemInSlot(i) == saved then
            inv:Equip(saved)
            return
        end
    end
end





function SGNPCCommon.MakePickupHandler()
    return ActionHandler(ACTIONS.PICKUP, "dopickup")
end




function SGNPCCommon.AddInventoryStates(states)

    table.insert(states, State{
        name = "dopickup",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        timeline =
        {

            TimeEvent(6 * FRAMES, function(inst)
                if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
                    print("[种植调试] SG:dopickup 执行拾取")
                end
                local ba = inst.bufferedaction
                if ba ~= nil and ba.target ~= nil and ba.target:IsValid() then
                    if DEBUG_BEHAVIOR then
                        print("[NPC_DEBUG] dopickup - target:", ba.target.prefab or "?",
                              "backpack=", tostring(ba.target:HasTag("backpack")),
                              "container=", tostring(ba.target.components.container ~= nil),
                              "chest=", tostring(ba.target:HasTag("chest")),
                              "fridge=", tostring(ba.target:HasTag("fridge")),
                              "heavy=", tostring(ba.target:HasTag("heavy")),
                              "_inventoryitem=", tostring(ba.target:HasTag("_inventoryitem")))
                    end
                end
                if ba ~= nil and ba.action == ACTIONS.PICKUP
                   and ba.target ~= nil and ba.target:IsValid()
                   and ba.target:HasTag("heavy")
                   and ba.target.components.equippable ~= nil then
                    local target = ba.target
                    SGNPCCommon.SaveBodyEquip(inst)
                    inst.components.inventory:Equip(target)
                    inst:PushEvent("onpickupitem", { item = target })
                    inst.bufferedaction = nil
                    return
                end
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    })

    table.insert(states, State{
        name = "heavylifting_start",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("heavy_pickup_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })

    table.insert(states, State{
        name = "drop_cleanup_item",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
                    print("[种植调试] SG:drop_cleanup_item 执行丢弃垃圾")
                end
                local drop_pos = inst._cleanup_drop_point
                    or Vector3(inst.Transform:GetWorldPosition())
                InvUtil.DropTrashAt(inst, drop_pos)
                inst._cleanup_drop_point = nil
                inst._cleanup_drop_start = nil
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst._cleanup_drop_point = nil
            inst._cleanup_drop_start = nil
        end,
    })

    table.insert(states, State{
        name = "drop_fish_items",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                local inv = inst.components.inventory
                if inv then
                    local dropped = 0
                    local fish_items = inv:FindItems(function(item)
                        return item and item:IsValid() and item.prefab == "fishmeat_small"
                    end) or {}
                    for _, item in ipairs(fish_items) do
                        if item and item:IsValid() and item.prefab == "fishmeat_small" then
                            local taken = inv:RemoveItem(item, true)
                            if taken then
                                taken.Transform:SetPosition(inst.Transform:GetWorldPosition())
                                if taken.components.inventoryitem then
                                    taken.components.inventoryitem:OnDropped(true)
                                end
                                dropped = dropped + 1
                            end
                        end
                    end
                    if NPC_TUNING and NPC_TUNING.DEBUG_FISHING then
                        print("[NPC_FISHING]\t_PhaseDepositDrop: SG丢弃鱼块数量=" .. dropped)
                    end
                end
                inst._fishing_deposit_done = true
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    })

    table.insert(states, State{
        name = "heavy_drop",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("heavy_item_hat")
            inst.AnimState:PushAnimation("heavy_item_hat_pst", false)
            inst.sg:SetTimeout(12 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                if NPC_TUNING and NPC_TUNING.DEBUG_FARMING then
                    print("[种植调试] SG:heavy_drop 执行放下重物")
                end
                local drop_pos = inst._cleanup_drop_point
                    or Vector3(inst.Transform:GetWorldPosition())
                InvUtil.DropHeavyAt(inst, drop_pos)
                SGNPCCommon.RestoreBodyEquip(inst)
                inst._cleanup_drop_point = nil
                inst._cleanup_drop_start = nil
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst._cleanup_drop_point = nil
            inst._cleanup_drop_start = nil
        end,
    })

    table.insert(states, State{
        name = "heavylifting_stop",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
            inst.sg:SetTimeout(6 * FRAMES)
        end,

        ontimeout = function(inst)
            SGNPCCommon.RestoreBodyEquip(inst)
            inst.sg:GoToState("idle")
        end,
    })
end





function SGNPCCommon.HandleEquipHeavy(inst, data)
    if data and data.eslot == EQUIPSLOTS.BODY
       and data.item and data.item:HasTag("heavy") then
        if inst.components.locomotor then
            inst.components.locomotor:SetExternalSpeedMultiplier(
                inst, "heavy_lifting", HEAVY_SPEED_MULT)
        end
        inst.sg:GoToState("heavylifting_start")
        return true
    end
    return false
end


function SGNPCCommon.HandleUnequipHeavy(inst, data)
    if data and data.eslot == EQUIPSLOTS.BODY
       and data.item and data.item:HasTag("heavy") then
        if inst.components.locomotor then
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "heavy_lifting")
        end
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("heavylifting_stop")
        end
        return true
    end
    return false
end





function SGNPCCommon.AddFarmingStates(states)

    table.insert(states, State{
        name = "extinguish_fire",
        tags = { "doing", "busy", "extinguishing" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg.statemem.target = data and data.target
            inst.sg:SetTimeout(0.8)
        end,

        ontimeout = function(inst)
            local target = inst.sg.statemem.target
            if target and target:IsValid() and target.components.burnable then
                if target.components.burnable:IsBurning() then
                    target.components.burnable:Extinguish(true)
                elseif target.components.burnable:IsSmoldering() then
                    target.components.burnable:SmotherSmolder()
                end
            end
            inst.AnimState:PlayAnimation("build_pst")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end





function SGNPCCommon.AddBuildingStates(states)

    table.insert(states, State{
        name = "build_structure",
        tags = { "doing", "busy", "building" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg.statemem.on_done = data and data.on_done
            inst.sg:SetTimeout(1.2)
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.on_done then
                inst.sg.statemem.on_done(inst)
            end
            inst.AnimState:PlayAnimation("build_pst")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })


    table.insert(states, State{
        name = "fuel_fire",
        tags = { "doing", "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg.statemem.target = data and data.target
            inst.sg:SetTimeout(0.6)
        end,

        ontimeout = function(inst)
            if inst._builder then
                inst._builder:FuelFirepit()
            end
            inst.AnimState:PlayAnimation("build_pst")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end

function SGNPCCommon.UpdateHeavyLiftingSpeed(inst)
    local inv = inst.components.inventory
    local loco = inst.components.locomotor
    if not inv or not loco then return end
    if inv:IsHeavyLifting() then
        loco:SetExternalSpeedMultiplier(inst, "heavy_lifting", HEAVY_SPEED_MULT)
    else
        loco:RemoveExternalSpeedMultiplier(inst, "heavy_lifting")
    end
end





local function EquipToolFromInv(inst, tool_prefab)
    local inv = inst.components.inventory
    if not inv then return nil end
    local prev_hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item and item.prefab == tool_prefab then
            inv:Equip(item)
            return prev_hand
        end
    end
    return prev_hand
end


local function SafeRestoreWeapon(inst, prev_hand, tool_prefab)
    local inv = inst.components.inventory
    if not inv then return end
    if prev_hand and prev_hand:IsValid() then
        local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if not hand or hand.prefab == tool_prefab then
            inv:Equip(prev_hand)
        end
    else
        local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
        if hand and hand.prefab == tool_prefab then
            inv:Unequip(EQUIPSLOTS.HANDS)
            inv:GiveItem(hand)
        end
    end
end




function SGNPCCommon.AddHammerStates(states)

    table.insert(states, State{
        name = "hammer_item",
        tags = { "doing", "busy", "hammering", "working" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.sg.statemem.target  = data and data.target
            inst.sg.statemem.on_done = data and data.on_done
            inst.sg.statemem.prev_hand = EquipToolFromInv(inst, "hammer")

            inst.AnimState:PlayAnimation("pickaxe_pre")
            inst.AnimState:PushAnimation("pickaxe_loop", false)
            inst.sg:SetTimeout(1.0)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                local target = inst.sg.statemem.target
                if target and target:IsValid() and target.components.workable then
                    SGNPCCommon.ForceWork(target, inst, target.components.workable.workleft)
                end
                if inst.sg.statemem.on_done then
                    inst.sg.statemem.on_done(inst)
                end
            end),
        },

        ontimeout = function(inst)
            SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "hammer")
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "hammer")
        end,
    })
end





function SGNPCCommon.AddChopStates(states)

    table.insert(states, State{
        name = "chop_item",
        tags = { "doing", "busy", "prechop", "chopping", "working" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.sg.statemem.target    = data and data.target
            inst.sg.statemem.on_done   = data and data.on_done
            inst.sg.statemem.prev_hand = EquipToolFromInv(inst, "axe")

            local target = inst.sg.statemem.target
            if target and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end

            inst.AnimState:PlayAnimation("chop_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.chopping = true
                    inst.sg:GoToState("chop_item_loop", {
                        target    = inst.sg.statemem.target,
                        on_done   = inst.sg.statemem.on_done,
                        prev_hand = inst.sg.statemem.prev_hand,
                    })
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.chopping then
                SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "axe")
            end
        end,
    })

    table.insert(states, State{
        name = "chop_item_loop",
        tags = { "doing", "busy", "chopping", "working" },

        onenter = function(inst, data)
            inst.sg.statemem.target    = data and data.target
            inst.sg.statemem.on_done   = data and data.on_done
            inst.sg.statemem.prev_hand = data and data.prev_hand
            inst.AnimState:PlayAnimation("chop_loop")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if target and target:IsValid()
                   and target.components.workable
                   and target.components.workable:CanBeWorked()
                   and target.components.workable.action == ACTIONS.CHOP then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
                    local hand = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    local eff = (hand and hand.components.tool and hand.components.tool:GetEffectiveness(ACTIONS.CHOP)) or 1
                    SGNPCCommon.ForceWork(target, inst, eff)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local target = inst.sg.statemem.target
                    if target and target:IsValid()
                       and target.components.workable
                       and target.components.workable:CanBeWorked()
                       and target.components.workable.action == ACTIONS.CHOP then
                        inst.sg.statemem.looping = true
                        inst.sg:GoToState("chop_item_loop", {
                            target    = target,
                            on_done   = inst.sg.statemem.on_done,
                            prev_hand = inst.sg.statemem.prev_hand,
                        })
                    else
                        SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "axe")
                        if inst.sg.statemem.on_done then
                            inst.sg.statemem.on_done(inst)
                        end
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.looping then
                SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "axe")
            end
        end,
    })
end




function SGNPCCommon.AddDigStates(states)

    table.insert(states, State{
        name = "dig_item",
        tags = { "doing", "busy", "predig", "digging", "working" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.sg.statemem.target    = data and data.target
            inst.sg.statemem.on_done   = data and data.on_done
            inst.sg.statemem.prev_hand = EquipToolFromInv(inst, "shovel")

            local target = inst.sg.statemem.target
            if target and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end

            inst.AnimState:PlayAnimation("shovel_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.digging = true
                    inst.sg:GoToState("dig_item_loop", {
                        target    = inst.sg.statemem.target,
                        on_done   = inst.sg.statemem.on_done,
                        prev_hand = inst.sg.statemem.prev_hand,
                    })
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.digging then
                SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "shovel")
            end
        end,
    })

    table.insert(states, State{
        name = "dig_item_loop",
        tags = { "doing", "busy", "digging", "working" },

        onenter = function(inst, data)
            inst.sg.statemem.target    = data and data.target
            inst.sg.statemem.on_done   = data and data.on_done
            inst.sg.statemem.prev_hand = data and data.prev_hand
            inst.AnimState:PlayAnimation("shovel_loop")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if target and target:IsValid()
                   and target.components.workable
                   and target.components.workable:CanBeWorked() then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
                    SGNPCCommon.ForceWork(target, inst, 1)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local target = inst.sg.statemem.target
                    if target and target:IsValid()
                       and target.components.workable
                       and target.components.workable:CanBeWorked() then
                        inst.sg.statemem.looping = true
                        inst.sg:GoToState("dig_item_loop", {
                            target    = target,
                            on_done   = inst.sg.statemem.on_done,
                            prev_hand = inst.sg.statemem.prev_hand,
                        })
                    else
                        SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "shovel")
                        if inst.sg.statemem.on_done then
                            inst.sg.statemem.on_done(inst)
                        end
                        inst.AnimState:PlayAnimation("shovel_pst")
                        inst.sg:GoToState("idle", true)
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.looping then
                SafeRestoreWeapon(inst, inst.sg.statemem.prev_hand, "shovel")
            end
        end,
    })
end





function SGNPCCommon.AddContainerStates(states)
    table.insert(states, State{
        name = "access_container",
        tags = { "doing", "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.sg.statemem.container  = data and data.container
            inst.sg.statemem.action_fn  = data and data.action_fn
            inst.sg.statemem.on_done    = data and data.on_done

            local container = inst.sg.statemem.container
            if container and container:IsValid() then
                inst:ForceFacePoint(container.Transform:GetWorldPosition())
                if DEBUG_BEHAVIOR then
                    print("[NPC_DEBUG] access_container onenter - container:", container.prefab or "?",
                          "chest=", tostring(container:HasTag("chest")),
                          "fridge=", tostring(container:HasTag("fridge")),
                          "backpack=", tostring(container:HasTag("backpack")),
                          "_npc_structure=", tostring(container:HasTag("_npc_structure")),
                          "stewer=", tostring(container:HasTag("stewer")))
                end
            end

            local is_pot = container and container.components.stewer ~= nil
            inst.sg.statemem.is_pot = is_pot
            if container and container:IsValid() and container.components.container then
                container.components.container:Open(inst)
            end

            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("idle_loop", true)

            inst.sg:SetTimeout(4.0)   
        end,

        timeline = {
            TimeEvent(45 * FRAMES, function(inst)
                if inst.sg.statemem.action_fn then
                    if DEBUG_BEHAVIOR then
                        local c = inst.sg.statemem.container
                        print("[NPC_DEBUG] access_container action_fn - container:",
                              c and (c.prefab or "?") or "nil",
                              "action_fn=", tostring(inst.sg.statemem.action_fn))
                    end
                    inst.sg.statemem.action_fn(inst, inst.sg.statemem.container)
                end
            end),

            TimeEvent(80 * FRAMES, function(inst)
                inst.sg.statemem.closed = true
                local container = inst.sg.statemem.container
                if DEBUG_BEHAVIOR then
                    print("[NPC_DEBUG] access_container close - container:",
                          container and (container.prefab or "?") or "nil")
                end

                if inst.sg.statemem.is_pot then
                    if container and container:IsValid() and container.components.container
                       and container.components.container:IsOpenedBy(inst) then
                        container.components.container:Close(inst)
                    end
                    if inst.sg.statemem.on_done then
                        inst.sg.statemem.on_done(inst)
                    end
                    inst.sg:GoToState("idle")
                else
                    if container and container:IsValid() and container.components.container
                       and container.components.container:IsOpen() then
                        container.components.container:Close(inst)
                    end
                    inst.AnimState:PlayAnimation("pickup_pst")
                end
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.closed and inst.AnimState:AnimDone() then
                    if inst.sg.statemem.on_done then
                        inst.sg.statemem.on_done(inst)
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },

        ontimeout = function(inst)
            
            if not inst.sg.statemem.closed then
                local container = inst.sg.statemem.container
                if container and container:IsValid() and container.components.container
                   and container.components.container:IsOpen() then
                    container.components.container:Close(inst)
                end
            end
            if inst.sg.statemem.on_done then
                inst.sg.statemem.on_done(inst)
            end
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.closed then
                local container = inst.sg.statemem.container
                if container and container:IsValid() and container.components.container
                   and container.components.container:IsOpen() then
                    container.components.container:Close(inst)
                end
            end
        end,
    })
end





function SGNPCCommon.DoKnockback(target, knocker, strength)
    if not target or not target:IsValid() then return end
    strength = strength or 5
    if target.components.playercontroller then
        target:PushEvent("knockback", {
            knocker = knocker,
            radius  = strength,
        })
    else
    end
end

function SGNPCCommon.AddSlapStates(states)

    table.insert(states, State{
        name = "slap_leader",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            if target and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if target and target:IsValid() then
                    SGNPCCommon.DoKnockback(target, inst,
                        NPC_TUNING.SLAP_KNOCKBACK_RADIUS or 5)
                end
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    })
end




function SGNPCCommon.AddActionDigStates(states)
    table.insert(states, State{
        name = "dig_start",
        tags = { "doing", "busy", "predig" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("dig")
                end
            end),
        },
    })

    table.insert(states, State{
        name = "dig",
        tags = { "doing", "busy", "digging" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                if inst.SoundEmitter then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
                end
                -- 捕获 DIG 目标用于兼容兜底（PerformBufferedAction 会清空 bufferedaction）
                local ba = inst.bufferedaction
                local target = ba and ba.target or nil
                local wk = target and target.components and target.components.workable or nil
                local before = wk and wk.workleft or nil
                inst:PerformBufferedAction()
                -- 兼容：DIG 被第三方 mod 对 NPC 拦截时兜底（仅当工作量未变化）
                if target ~= nil and target:IsValid()
                   and wk ~= nil and target.components.workable == wk
                   and wk:CanBeWorked()
                   and wk:GetWorkAction() == ACTIONS.DIG
                   and before ~= nil and wk.workleft == before then
                    SGNPCCommon.ForceWork(target, inst, 1)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    })
end




function SGNPCCommon.AddActionPourStates(states)
    table.insert(states, State{
        name = "pour",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("water_pre")
            inst.AnimState:PushAnimation("water", false)
            inst.AnimState:Show("water")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                if inst.SoundEmitter then
                    inst.SoundEmitter:PlaySound("farming/common/watering_can/use")
                end
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    })
end




function SGNPCCommon.AddActionTillStates(states)
    table.insert(states, State{
        name = "till_start",
        tags = { "doing", "busy", "pretill" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("till_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("till")
                end
            end),
        },
    })

    table.insert(states, State{
        name = "till",
        tags = { "doing", "busy", "tilling" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("till_loop")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.SoundEmitter then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
                end
            end),
            TimeEvent(11 * FRAMES, function(inst)
                inst:AddTag("NOBLOCK")
                inst:PerformBufferedAction()
                inst:RemoveTag("NOBLOCK")
            end),
            TimeEvent(22 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("till_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    })
end




function SGNPCCommon.AddEquipAnimStates(states)

    table.insert(states, State{
        name = "item_out",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("item_out")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })

    table.insert(states, State{
        name = "item_in",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("item_in")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })

    table.insert(states, State{
        name = "item_hat",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("item_hat")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end




function SGNPCCommon.AddGiveState(states)

    table.insert(states, State{
        name = "give",
        tags = { "giving", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end




function SGNPCCommon.AddEatStates(states)

    table.insert(states, State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            if inst.SoundEmitter then
                inst.SoundEmitter:KillSound("eating")
            end
            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.SoundEmitter then
                inst.SoundEmitter:KillSound("eating")
            end
        end,
    })

    table.insert(states, State{
        name = "refuseeat",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("refuseeat")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end




function SGNPCCommon.AddPerformActionStates(states)

    table.insert(states, State{
        name = "doshortaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", false)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    })

    table.insert(states, State{
        name = "domediumaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    })

    table.insert(states, State{
        name = "dolongaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            local NPC_TUNING_LOCAL = require("npc_tuning")
            local speed = inst._pick_speed or NPC_TUNING_LOCAL.PICK_SPEED
            inst.AnimState:SetDeltaTimeMultiplier(speed)
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg:SetTimeout(NPC_TUNING_LOCAL.PICK_ACTION_TIMEOUT / speed)
        end,

        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
    })
end




function SGNPCCommon.AddMineStates(states)

    table.insert(states, State{
        name = "mine_start",
        tags = { "premine", "working" },

        onenter = function(inst)
            inst.Physics:Stop()
            local NPC_TUNING_LOCAL = require("npc_tuning")
            inst.AnimState:SetDeltaTimeMultiplier(NPC_TUNING_LOCAL.MINE_SPEED)
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk")
            else
                inst.AnimState:PlayAnimation("pickaxe_pre")
            end
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.mining = true
                    inst.sg:GoToState("mine")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.mining then
                inst:RemoveTag("premine")
            end
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
    })

    table.insert(states, State{
        name = "mine",
        tags = { "premine", "mining", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            local NPC_TUNING_LOCAL = require("npc_tuning")
            inst.AnimState:SetDeltaTimeMultiplier(NPC_TUNING_LOCAL.MINE_SPEED)
            if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk")
            else
                inst.AnimState:PlayAnimation("pickaxe_loop")
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    PlayMiningFX(inst, inst.sg.statemem.action.target)
                end
                inst:PerformBufferedAction()
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("premine")
                inst:RemoveTag("premine")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("premine")
            inst.AnimState:SetDeltaTimeMultiplier(1)
        end,
    })
end




function SGNPCCommon.AddOceanFishingStates(states)

    table.insert(states, State{
        name = "npc_oceanfishing_cast",
        tags = { "busy", "fishing", "npc_fishing" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.sg.statemem.target_pos = data and data.target_pos or nil
            inst.sg.statemem.hooklanded = false

            
            if inst.sg.statemem.target_pos then
                inst:ForceFacePoint(inst.sg.statemem.target_pos:Get())
            end

            inst.AnimState:PlayAnimation("fishing_ocean_pre")
            inst.AnimState:PushAnimation("fishing_ocean_cast", false)
            inst.AnimState:PushAnimation("fishing_ocean_cast_loop", true)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast")
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast_ocean")

                local inv = inst.components.inventory
                local rod = inv and inv:GetEquippedItem(EQUIPSLOTS.HANDS)
                if rod and rod.components.oceanfishingrod then
                    local target_pos = inst.sg.statemem.target_pos
                    if target_pos then
                        rod.components.oceanfishingrod:Cast(inst, target_pos)
                    end
                end
            end),
        },

        events =
        {
            EventHandler("newfishingtarget", function(inst, data)
                if data ~= nil and data.target ~= nil and not data.target:HasTag("projectile") then
                    inst.sg.statemem.hooklanded = true
                    inst.AnimState:PushAnimation("fishing_ocean_cast_pst", false)
                end
            end),

            EventHandler("animqueueover", function(inst)
                if inst.sg.statemem.hooklanded and inst.AnimState:AnimDone() then
                    inst.sg:GoToState("npc_oceanfishing_idle")
                end
            end),
        },
    })

    table.insert(states, State{
        name = "npc_oceanfishing_idle",
        tags = { "fishing", "npc_fishing", "canrotate" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            inst.AnimState:PlayAnimation("hooked_loose_idle", true)
        end,

        onupdate = function(inst)
            local rod = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            rod = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod or nil
            local target = rod ~= nil and rod.components.oceanfishingrod.target or nil
            if target ~= nil then
                if target.components.oceanfishinghook ~= nil then
                    if not inst.AnimState:IsCurrentAnimation("hooked_loose_idle") then
                        inst.AnimState:PlayAnimation("hooked_loose_idle", true)
                    end
                else
                    if rod.components.oceanfishingrod:IsLineTensionLow() then
                        if not inst.AnimState:IsCurrentAnimation("hooked_loose_idle") then
                            inst.AnimState:PlayAnimation("hooked_loose_idle", true)
                        end
                    elseif rod.components.oceanfishingrod:IsLineTensionGood() then
                        if not inst.AnimState:IsCurrentAnimation("hooked_good_idle") then
                            inst.AnimState:PlayAnimation("hooked_good_idle", true)
                        end
                    else
                        if not inst.AnimState:IsCurrentAnimation("hooked_tight_idle") then
                            inst.AnimState:PlayAnimation("hooked_tight_idle", true)
                        end
                    end
                end
            end
        end,

        onexit = function(inst)
            inst:RemoveTag("fishing_idle")
        end,
    })

    table.insert(states, State{
        name = "npc_oceanfishing_reel",
        tags = { "fishing", "npc_fishing", "doing", "reeling", "canrotate" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            inst.components.locomotor:Stop()

            local rod = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            rod = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod or nil

            if rod then
                rod.components.oceanfishingrod:Reel()

                if rod.components.oceanfishingrod:IsLineTensionLow() then
                    inst.AnimState:PlayAnimation("hooked_loose_reeling", true)
                elseif rod.components.oceanfishingrod:IsLineTensionGood() then
                    inst.AnimState:PlayAnimation("hooked_good_reeling", true)
                else
                    inst.AnimState:PlayAnimation("hooked_tight_reeling", true)
                end

                inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            else
                inst.sg:SetTimeout(0.5)
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("npc_oceanfishing_idle")
        end,

        onexit = function(inst)
            inst:RemoveTag("fishing_idle")
        end,
    })

    table.insert(states, State{
        name = "npc_oceanfishing_catch",
        tags = { "fishing", "npc_fishing", "catchfish", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("fishing_ocean_catch")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst._oceanfishing_catch_done = true
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
        end,
    })

    table.insert(states, State{
        name = "npc_oceanfishing_stop",
        tags = { "busy", "npc_fishing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_ocean_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })

    table.insert(states, State{
        name = "npc_oceanfishing_linesnapped",
        tags = { "busy", "npc_fishing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("line_snap")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_linebreak")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end




function SGNPCCommon.AddEmoteState(states)

    table.insert(states, State{
        name = "emote",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            if inst._is_ghost_mode then
                inst.sg:GoToState("ghost_idle")
                return
            end
            local anim = (data and data.anim) or "emoteXL_waving1"
            inst.AnimState:PlayAnimation(anim)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end





function SGNPCCommon.AddHopEventHandlers(events)
    table.insert(events, CommonHandlers.OnHop())
end


function SGNPCCommon.AddHopStates(states)
    CommonStates.AddHopStates(states, true, {
        pre  = "boat_jump_pre",
        loop = "boat_jump_loop",
        pst  = "boat_jump_pst",
    })
end

return SGNPCCommon
