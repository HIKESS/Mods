-- scripts/npc/characters/wilba.lua
-- Wilba: 薇尔芭
-- 专属行为：银项链监控
--   ▸ 项链被取走 → 立刻说台词
--   ▸ 每 5 秒检查物品栏：若物品栏里有项链但未装备 → 自动装备 + 说台词
--   ▸ 物品栏也没有时：每 10~15 秒随机说一句抱怨台词

local NPC_SPEECH = require("npc_speech")

local wilba = {}

local THIEF_DETECT_RANGE    = 20
local THIEF_DETECT_RANGE_SQ = THIEF_DETECT_RANGE * THIEF_DETECT_RANGE
local THIEF_SCAN_PERIOD     = 3   -- 秒

local function IsNecklaceEquipped(inst)
    local inv = inst.components and inst.components.inventory
    if not inv then return false end
    local body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
    return body ~= nil and body.prefab == "silvernecklace"
end

local function FindNecklaceInBag(inst)
    local inv = inst.components and inst.components.inventory
    if not inv then return nil end
    for i = 1, inv.maxslots do
        local item = inv.itemslots[i]
        if item and item.prefab == "silvernecklace" then
            return item
        end
    end
    return nil
end

local function SayLine(inst, category)
    if not (inst and inst:IsValid() and inst.components and inst.components.talker) then
        return
    end
    local line = NPC_SPEECH.GetLine(category, "wilba")
    if line then
        inst.components.talker:ShutUp()
        inst.components.talker:Say(line)
    end
end


local function IsWearingNecklace(entity, wilba_inst)
    if not (entity and entity:IsValid() and entity ~= wilba_inst) then return false end
    if entity:IsInLimbo() then return false end
    local inv = entity.components and entity.components.inventory
    if not inv then return false end
    local body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
    return body ~= nil and body.prefab == "silvernecklace"
end

local function StartThiefScan(inst)
    if inst._wilba_thief_scan_task then return end
    inst._wilba_thief_scan_task = inst:DoPeriodicTask(THIEF_SCAN_PERIOD, function(i)
        if not (i and i:IsValid()) then return end
        if i._is_ghost_mode then return end
        if i._wilba_necklace_thief
           or i._wilba_thief_pending
           or i._wilba_necklace_pickup_target then return end

        for _, player in ipairs(AllPlayers) do
            if player and player:IsValid()
               and i:GetDistanceSqToInst(player) <= THIEF_DETECT_RANGE_SQ
               and IsWearingNecklace(player, i) then
                i._wilba_necklace_thief = player
                return
            end
        end

        local x, y, z = i.Transform:GetWorldPosition()
        local nearby = TheSim:FindEntities(x, y, z, THIEF_DETECT_RANGE, {"npcfriend"})
        for _, npc in ipairs(nearby) do
            if IsWearingNecklace(npc, i) then
                i._wilba_necklace_thief = npc
                return
            end
        end
    end)
end

local function StopThiefScan(inst)
    if inst._wilba_thief_scan_task then
        inst._wilba_thief_scan_task:Cancel()
        inst._wilba_thief_scan_task = nil
    end
end


local function StartNecklaceWatch(inst)
    if inst._wilba_necklace_watch_task then return end  

    inst._wilba_necklace_watch_task = inst:DoPeriodicTask(5, function(i)
        if not (i and i:IsValid()) then return end
        if i._is_ghost_mode then return end

        if IsNecklaceEquipped(i) then
            i._wilba_necklace_missing_next = nil
            return
        end

        local necklace = FindNecklaceInBag(i)
        if necklace then
            local inv = i.components.inventory
            if inv then
                local cur_body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
                if cur_body and cur_body ~= necklace then
                    inv:Unequip(EQUIPSLOTS.BODY)
                end
                inv:Equip(necklace)
                SayLine(i, NPC_SPEECH.WILBA_NECKLACE_REEQUIP)
                i._wilba_necklace_missing_next = nil
            end
            return
        end

        local now = GetTime()
        if not i._wilba_necklace_missing_next then
            i._wilba_necklace_missing_next = now + 10 + math.random() * 5
        elseif now >= i._wilba_necklace_missing_next then
            SayLine(i, NPC_SPEECH.WILBA_NECKLACE_MISSING)
            i._wilba_necklace_missing_next = now + 10 + math.random() * 5
        end
    end)
end

local function StopNecklaceWatch(inst)
    if inst._wilba_necklace_watch_task then
        inst._wilba_necklace_watch_task:Cancel()
        inst._wilba_necklace_watch_task = nil
    end
    inst._wilba_necklace_missing_next = nil
end


local function OnBodyUnequip(inst, data)
    if not (data and data.item) then return end
    if data.item.prefab ~= "silvernecklace" then return end
    if inst._is_ghost_mode then return end
    inst:DoTaskInTime(0.1, function(i)
        if i and i:IsValid() then
            SayLine(i, NPC_SPEECH.WILBA_NECKLACE_TAKEN)
            StartNecklaceWatch(i)
        end
    end)
end

local function OnBodyEquip(inst, data)
    if not (data and data.item) then return end
    if data.item.prefab ~= "silvernecklace" then return end
    inst._wilba_necklace_missing_next = nil
end

function wilba.on_apply(inst, stats)
    StopNecklaceWatch(inst)
    StopThiefScan(inst)
    if inst._wilba_unequip_cb then
        inst:RemoveEventCallback("unequip", inst._wilba_unequip_cb)
        inst._wilba_unequip_cb = nil
    end
    if inst._wilba_equip_cb then
        inst:RemoveEventCallback("equip", inst._wilba_equip_cb)
        inst._wilba_equip_cb = nil
    end

    inst._wilba_unequip_cb = function(i, data) OnBodyUnequip(i, data) end
    inst._wilba_equip_cb   = function(i, data) OnBodyEquip(i, data) end
    inst:ListenForEvent("unequip", inst._wilba_unequip_cb)
    inst:ListenForEvent("equip",   inst._wilba_equip_cb)

    StartNecklaceWatch(inst)
    StartThiefScan(inst)
end

function wilba.on_load(inst, data)
    if not inst._wilba_necklace_watch_task then
        StartNecklaceWatch(inst)
    end
    if not inst._wilba_thief_scan_task then
        StartThiefScan(inst)
    end
end

function wilba.on_save(inst, data)
end


function wilba.DoNecklaceRetrieval(inst, target)
    if not (inst and inst:IsValid()) then return end
    if not (target and target:IsValid()) then return end

    local inv = target.components and target.components.inventory
    if not inv then return end

    local body = inv:GetEquippedItem(EQUIPSLOTS.BODY)
    if not (body and body.prefab == "silvernecklace") then return end

    local U = _G.NPCFRIENDS_SILVERNECKLACE_UTILS
    if U and U.DebugLog then
        U.DebugLog("DoNecklaceRetrieval.enter", target,
            "cur_state=" .. tostring(target.sg and target.sg.currentstate and target.sg.currentstate.name))
    end

    inv:Unequip(EQUIPSLOTS.BODY)

    if body and body:IsValid() then
        if target._orig_DropItem then
            target._orig_DropItem(inv, body)
        else
            inv:DropItem(body)
        end

        if body:IsValid() then
            inst._wilba_necklace_pickup_target = body
        end
    end
end

return wilba
