-- scripts/npc/npc_inventory.lua
-- NPC 物品栏系统：装备视觉、武器伤害联动、自动换装

local NPC_TUNING = require("npc_tuning")
local npc_utils  = require("npc/npc_utils")

local UpdateHoverInfo = npc_utils.UpdateHoverInfo

local npc_inventory = {}

function npc_inventory.SetupInventorySystem(inst)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 32

    inst._orig_DropItem = inst.components.inventory.DropItem

    inst.components.inventory.DropItem = function(self, ...) return end
    inst.components.inventory.DropEverything = function(self, ...) return end
    inst.components.inventory.DropEverythingWithTag = function(self, ...) return end


    local _orig_Equip = inst.components.inventory.Equip
    inst.components.inventory.Equip = function(self, item, old_to_active, no_animation)
        if item ~= nil and item.components ~= nil and item.components.equippable ~= nil
           and item.components.equippable.equipslot == EQUIPSLOTS.BODY then
            local olditem = self.equipslots and self.equipslots[EQUIPSLOTS.BODY] or nil
            if olditem ~= nil and olditem ~= item then
                local oii = olditem.components and olditem.components.inventoryitem
                if oii ~= nil and not oii.cangoincontainer then
                    self:Unequip(EQUIPSLOTS.BODY)
                    if olditem:IsValid() and inst._orig_DropItem then
                        inst._orig_DropItem(self, olditem, true)
                        print("[背包调试][Equip覆盖] 旧背包=" .. tostring(olditem.prefab) .. "#" .. tostring(olditem.GUID)
                            .. " 已卸下并丢到 NPC 脚下, 准备装备新=" .. tostring(item.prefab) .. "#" .. tostring(item.GUID))
                    end
                end
            end
        end
        return _orig_Equip(self, item, old_to_active, no_animation)
    end

    inst.components.inventory.IsInsulated = function(self)
        for k, v in pairs(self.equipslots) do
            if v and v.components and v.components.equippable and v.components.equippable:IsInsulated() then
                return true
            end
        end
        return self.isexternallyinsulated:Get()
    end

    inst.components.inventory.GetNextAvailableSlot = function(self, item)
        local overflow = self:GetOverflowContainer()
        local prioritize_container = overflow and overflow:ShouldPrioritizeContainer(item)

        if item.components.stackable ~= nil then
            local prefabname = item.prefab
            local prefabskinname = item.skinname

            for k, v in pairs(self.equipslots) do
                if v and v.components and v.prefab == prefabname and v.skinname == prefabskinname and v.components.equippable and v.components.equippable.equipstack and v.components.stackable and not v.components.stackable:IsFull() then
                    return k, self.equipslots
                end
            end

            local inv_slot, inv_pref
            for k, v in pairs(self.itemslots) do
                if v.prefab == prefabname and v.skinname == prefabskinname and v.components.stackable and not v.components.stackable:IsFull() then
                    if prioritize_container then
                        inv_slot, inv_pref = k, self.itemslots
                        break
                    else
                        return k, self.itemslots
                    end
                end
            end

            if overflow ~= nil then
                if item.components.inventoryitem == nil or
                not item.components.inventoryitem.canonlygoinpocket and
                (not item.components.inventoryitem.canonlygoinpocketorpocketcontainers or overflow.inst.components.inventoryitem and overflow.inst.components.inventoryitem.canonlygoinpocket) then
                    for k, v in pairs(overflow.slots) do
                        if v.prefab == prefabname and v.skinname == prefabskinname and v.components.stackable and not v.components.stackable:IsFull() then
                            return k, overflow
                        end
                    end
                end
            end

            if prioritize_container and inv_slot and inv_pref then
                return inv_slot, inv_pref
            end
        end

        if prioritize_container then
            for k = 1, overflow:GetNumSlots() do
                if overflow:CanTakeItemInSlot(item, k) and not overflow.slots[k] then
                    return k, overflow
                end
            end
        end

        for k = 1, self.maxslots do
            if self:CanTakeItemInSlot(item, k) and not self.itemslots[k] then
                return k, self.itemslots
            end
        end
        return nil, self.itemslots
    end

    inst.components.inventory.CanAcceptCount = function(self, item, maxcount)
        local stacksize = math.max(maxcount or 0, item.components.stackable ~= nil and item.components.stackable.stacksize or 1)
        if stacksize <= 0 then
            return 0
        end

        local acceptcount = 0

        for k = 1, self.maxslots do
            local v = self.itemslots[k]
            if v ~= nil then
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            elseif self:CanTakeItemInSlot(item, k) then
                if self.acceptsstacks or stacksize <= 1 then
                    return stacksize
                end
                acceptcount = acceptcount + 1
                if acceptcount >= stacksize then
                    return stacksize
                end
            end
        end

        local overflow = self:GetOverflowContainer()
        if overflow ~= nil then
            if item.components.inventoryitem == nil or
            not item.components.inventoryitem.canonlygoinpocket and
            (not item.components.inventoryitem.canonlygoinpocketorpocketcontainers or overflow.inst.components.inventoryitem and overflow.inst.components.inventoryitem.canonlygoinpocket) then
                for k = 1, overflow.numslots do
                    local v = overflow.slots[k]
                    if v ~= nil then
                        if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                            acceptcount = acceptcount + v.components.stackable:RoomLeft()
                            if acceptcount >= stacksize then
                                return stacksize
                            end
                        end
                    elseif overflow:CanTakeItemInSlot(item, k) then
                        if overflow.acceptsstacks or stacksize <= 1 then
                            return stacksize
                        end
                        acceptcount = acceptcount + 1
                        if acceptcount >= stacksize then
                            return stacksize
                        end
                    end
                end
            end
        end

        if item.components.stackable ~= nil then
            for k, v in pairs(self.equipslots) do
                if v and v.components and v.prefab == item.prefab and v.skinname == item.skinname and v.components.equippable and v.components.equippable.equipstack and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            end
        end

        return acceptcount
    end

    -- 装备视觉：调用物品自身的 onequipfn/onunequipfn
    inst:ListenForEvent("equip", function(i, data)
        if data and data.item then
            local eq = data.item.components and data.item.components.equippable
            if eq then
                if eq.equipslot and data.eslot and eq.equipslot ~= data.eslot then
                    local inv = inst.components.inventory
                    if inv then
                        inv:Unequip(data.eslot)
                        inv:GiveItem(data.item)
                    end
                    return
                end
                eq:Equip(inst)
                if data.eslot == EQUIPSLOTS.HANDS then
                    local wc = data.item.components.weapon
                    if wc and inst.components.combat then
                        local base = inst.npc_base_damage or 0
                        local mult = inst.npc_damage_mult or 1
                        inst.components.combat:SetDefaultDamage((base + (wc:GetDamage(inst) or 0)) * mult)
                    end
                end
                local wsm = eq:GetWalkSpeedMult()
                if wsm > 1 and inst.components.locomotor then
                    inst.components.locomotor:SetExternalSpeedMultiplier(
                        inst, "equip_speed_" .. (data.eslot or "unknown"), wsm)
                end
                if data.item.components.fueled then
                    data.item:DoTaskInTime(0, function()
                        if data.item:IsValid() and data.item.components.fueled then
                            data.item.components.fueled:StopConsuming()
                        end
                    end)
                end
                UpdateHoverInfo(inst)
            end
        end
    end)

    inst:ListenForEvent("unequip", function(i, data)
        if data and data.item then
            local eq = data.item.components and data.item.components.equippable
            if eq then
                eq:Unequip(inst)
                if inst.components.locomotor then
                    inst.components.locomotor:RemoveExternalSpeedMultiplier(
                        inst, "equip_speed_" .. (data.eslot or "unknown"))
                end
                if data.eslot == EQUIPSLOTS.HANDS and inst.components.combat then
                    local base = inst.npc_base_damage or 0
                    local mult = inst.npc_damage_mult or 1
                    inst.components.combat:SetDefaultDamage(base * mult)
                end
                UpdateHoverInfo(inst)
            end
            local check_slot = data.eslot
            local check_item = data.item
            if check_slot == EQUIPSLOTS.HANDS
               or check_slot == EQUIPSLOTS.BODY
               or check_slot == EQUIPSLOTS.HEAD then
                inst:DoTaskInTime(0, function()
                    if not inst:IsValid() then return end
                    if check_item:IsValid() then return end  -- 手动脱装
                    local inv = inst.components.inventory
                    if inv and not inv:GetEquippedItem(check_slot) then
                        for slot_i = 1, inv.maxslots do
                            local candidate = inv:GetItemInSlot(slot_i)
                            if candidate and candidate.components.equippable
                               and candidate.components.equippable.equipslot == check_slot then
                                inv:Equip(candidate)
                                break
                            end
                        end
                    end
                end)
            end
        end
    end)


    inst:ListenForEvent("itemget", function(_, data)
        local item = data and data.item
        if not item or not item:IsValid() then return end
        if item._npc_tool or item._npc_initial_tool then
            if NPC_TUNING.DEBUG_FARMING and NPC_TUNING.IsUntakeableToolPrefab(inst.npc_character_type, item.prefab) then
                print(string.format("[种植调试][ItemGet] 收到已标记工具 %s GUID=%s (initial=%s tool=%s)",
                    item.prefab, tostring(item.GUID or "?"),
                    tostring(item._npc_initial_tool), tostring(item._npc_tool)))
            end
            return
        end
        if NPC_TUNING.IsUntakeableToolPrefab(inst.npc_character_type, item.prefab) then
            item._npc_tool = true
            item:AddTag("_npc_tool")
            if NPC_TUNING.DEBUG_FARMING then
                print(string.format("[种植调试][ItemGet] 玩家递入工具 %s GUID=%s → 已加 _npc_tool",
                    item.prefab, tostring(item.GUID or "?")))
            end
        end
    end)
end

return npc_inventory
