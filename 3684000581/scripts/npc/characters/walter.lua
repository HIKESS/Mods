-- scripts/npc/characters/walter.lua
-- 沃尔特：基础 NPC 接入与弹弓战斗支持。

local M = {}

local NPC_TUNING = require("npc_tuning")
local NPC_SPEECH = require("npc_speech")
local WobyRide = require("npc/npc_woby_ride")

local SLINGSHOT_AMMO_PREFIX = "^slingshotammo_"

local function WalterLog(...)
    if NPC_TUNING and NPC_TUNING.DEBUG_WALTER then
        print("[沃尔特调试]", ...)
    end
end

local function WalterLogCooldown(inst, key, interval, ...)
    if not (NPC_TUNING and NPC_TUNING.DEBUG_WALTER) then
        return
    end
    if inst == nil then
        WalterLog(...)
        return
    end
    inst._walter_log_cooldowns = inst._walter_log_cooldowns or {}
    local now = GetTime()
    local next_time = inst._walter_log_cooldowns[key] or 0
    if now >= next_time then
        inst._walter_log_cooldowns[key] = now + (interval or 5)
        WalterLog(...)
    end
end

local function EntityName(ent)
    if ent == nil then
        return "nil"
    end
    return tostring(ent.prefab or ent.GUID or ent)
end

local function IsWalter(inst)
    return inst ~= nil and inst.npc_character_type == "walter"
end

local function StoryTellingDone(inst, story)
    if inst.components ~= nil and inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("npc_walter_story")
    end
    if inst._walter_auto_story_enabled == true and TheWorld.state.isnight then
        inst._npc_walter_story_lock_mount = true
        inst._npc_walter_story_lock_until = GetTime() + 1.5
    else
        inst._npc_walter_story_lock_mount = nil
        inst._npc_walter_story_lock_until = nil
    end
    if inst._npc_walter_story_proxy ~= nil and inst._npc_walter_story_proxy:IsValid() then
        inst._npc_walter_story_proxy:Remove()
    end
    inst._npc_walter_story_proxy = nil
    if inst.sg ~= nil and inst.sg.currentstate ~= nil and inst.sg.currentstate.name == "dostorytelling" then
        inst.sg.statemem.started = true
    end
end

local function StoryToTellFn(inst, story_prop)
    if not TheWorld.state.isnight then
        return "还没到晚上，故事要等天黑才有气氛。"
    end
    local fueled = story_prop ~= nil and story_prop.components ~= nil and story_prop.components.fueled or nil
    if fueled == nil or not story_prop:HasTag("campfire") then
        return nil
    end
    if fueled:IsEmpty() then
        return "篝火灭了，故事讲不下去了。"
    end
    local campfire_stories = NPC_SPEECH.WALTER_CAMPFIRE_STORIES
    local story_id = campfire_stories ~= nil and GetRandomKey(campfire_stories) or nil
    if story_id == nil then
        campfire_stories = STRINGS.STORYTELLER ~= nil
        and STRINGS.STORYTELLER.WALTER ~= nil
        and STRINGS.STORYTELLER.WALTER.CAMPFIRE
        or nil
        story_id = campfire_stories ~= nil and GetRandomKey(campfire_stories) or nil
    end
    if story_id == nil or campfire_stories[story_id] == nil then
        return nil
    end
    if inst.components ~= nil and inst.components.talker ~= nil then
        -- 防止普通闲聊/战斗喊话 CancelSay()，提前触发 donetalking 中断整段故事。
        inst.components.talker:IgnoreAll("npc_walter_story")
    end
    if inst._npc_walter_story_proxy ~= nil and inst._npc_walter_story_proxy:IsValid() then
        inst._npc_walter_story_proxy:Remove()
    end
    inst._npc_walter_story_proxy = SpawnPrefab("npc_walter_story_proxy")
    if inst._npc_walter_story_proxy ~= nil then
        inst._npc_walter_story_proxy:Setup(inst, story_prop)
    end
    return { style = "CAMPFIRE", id = story_id, lines = campfire_stories[story_id].lines }
end

local function IsSlingshotAmmo(item)
    return item ~= nil
        and item.prefab ~= nil
        and string.match(item.prefab, SLINGSHOT_AMMO_PREFIX) ~= nil
end

local function GetInventory(inst)
    return inst ~= nil and inst.components ~= nil and inst.components.inventory or nil
end

function M.FindSlingshot(inst)
    local inv = GetInventory(inst)
    if inv == nil then return nil end

    local hand = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if hand ~= nil and hand.prefab == "slingshot" then
        return hand
    end

    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item ~= nil and item.prefab == "slingshot" then
            return item
        end
    end
    return nil
end

local function SlingshotHasAmmo(slingshot)
    local container = slingshot ~= nil and slingshot.components ~= nil and slingshot.components.container or nil
    return container ~= nil and container:GetItemInSlot(1) ~= nil
end

local function GetLoadedAmmo(slingshot)
    local container = slingshot ~= nil and slingshot.components ~= nil and slingshot.components.container or nil
    return container ~= nil and container:GetItemInSlot(1) or nil
end

local function GiveAmmoToSlingshot(inst, slingshot, ammo, leftover_slot)
    local container = slingshot ~= nil and slingshot.components ~= nil and slingshot.components.container or nil
    if container == nil or ammo == nil then
        return false
    end

    local expected_prefab = ammo.prefab
    local current = GetLoadedAmmo(slingshot)
    if current ~= nil then
        if current.prefab == expected_prefab then
            return true
        end
        WalterLog("装弹前弹弓槽未清空", "current=" .. tostring(current.prefab), "next=" .. tostring(expected_prefab))
        return false
    end

    if IsWalter(inst) then
        container.slots[1] = ammo
        ammo.components.inventoryitem:OnPutInInventory(slingshot)
        slingshot:PushEvent("itemget", { slot = 1, item = ammo })
        return true
    end

    local required_skill = ammo.REQUIRED_SKILL
    if IsWalter(inst) and required_skill ~= nil then
        -- 玩家弹药技能限制由弹弓容器处理。
        -- NPC 沃尔特没有技能树组件，只允许自己的自动装弹逻辑临时绕过。
        ammo.REQUIRED_SKILL = nil
    end
    local ok = container:GiveItem(ammo, 1, nil, false)
    if ammo:IsValid() then
        ammo.REQUIRED_SKILL = required_skill
    end
    local loaded = GetLoadedAmmo(slingshot)
    if loaded == nil or loaded.prefab ~= expected_prefab then
        WalterLog("装弹检查失败",
            "prefab=" .. tostring(expected_prefab),
            "required_skill=" .. tostring(required_skill),
            "give_ok=" .. tostring(ok),
            "loaded=" .. tostring(loaded and loaded.prefab or "nil"))
        return ok
    end
    if loaded.REQUIRED_SKILL == nil then
        loaded.REQUIRED_SKILL = required_skill
    end

    -- Slingshot containers load one ammo from a stack and return false because
    -- the whole stack was not moved. Treat the loaded slot as the real success.
    if not ok and ammo ~= loaded and ammo:IsValid()
        and ammo.components ~= nil
        and ammo.components.inventoryitem ~= nil
        and ammo.components.inventoryitem.owner == nil then
        local inv = GetInventory(inst)
        if inv ~= nil and not inv:GiveItem(ammo, leftover_slot) then
            inv:GiveItem(ammo)
        end
    end
    return true
end

local function RemoveLoadedAmmoWhole(slingshot)
    local container = slingshot ~= nil and slingshot.components ~= nil and slingshot.components.container or nil
    if container == nil then
        return nil, false, nil
    end

    local loaded = container:GetItemInSlot(1)
    if loaded == nil then
        return nil, true, nil
    end

    local removed = container:RemoveItem(loaded, true)
    local remaining = container:GetItemInSlot(1)
    return removed, remaining == nil, remaining
end

local function GetInventoryAmmoSlots(inst)
    local inv = GetInventory(inst)
    local slots = {}
    if inv == nil then return slots end

    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if IsSlingshotAmmo(item) then
            table.insert(slots, { slot = i, item = item })
        end
    end
    return slots
end

local function FormatAmmoSlots(slots)
    local parts = {}
    for _, entry in ipairs(slots) do
        table.insert(parts, tostring(entry.slot) .. ":" .. tostring(entry.item and entry.item.prefab or "nil"))
    end
    return table.concat(parts, ",")
end

function M.HasLoadedOrInventoryAmmo(inst, slingshot)
    if SlingshotHasAmmo(slingshot) then
        return true
    end
    return #GetInventoryAmmoSlots(inst) > 0
end

local function ApplySlingshotRange(slingshot)
    local weapon = slingshot ~= nil and slingshot.components ~= nil and slingshot.components.weapon or nil
    if weapon == nil then return end

    local max_dist = NPC_TUNING.WALTER_SLINGSHOT_MAX_DIST or TUNING.SLINGSHOT_DISTANCE_MAX or 14
    local attack_dist = math.min(TUNING.SLINGSHOT_DISTANCE or 10, max_dist)
    weapon:SetRange(attack_dist, max_dist)
end

local function PickNextAmmoSlot(inst, slots)
    if #slots == 0 then return nil end

    local last_slot = inst._walter_last_ammo_slot or 0
    for _, entry in ipairs(slots) do
        if entry.slot > last_slot then
            return entry
        end
    end
    return slots[1]
end

function M.TryLoadAmmo(inst, slingshot)
    if slingshot == nil or slingshot.components == nil or slingshot.components.container == nil then
        return false
    end
    if SlingshotHasAmmo(slingshot) then
        return true
    end

    local inv = GetInventory(inst)
    if inv == nil then
        return false
    end

    local next_entry = PickNextAmmoSlot(inst, GetInventoryAmmoSlots(inst))
    if next_entry == nil or next_entry.item == nil then
        WalterLogCooldown(inst, "preload_no_ammo", 8, "预装弹失败：背包没有弹药")
        return false
    end

    local taken = inv:RemoveItem(next_entry.item, true)
    if taken == nil then
        WalterLog("预装弹失败：移除背包弹药失败", next_entry.slot, next_entry.item.prefab)
        return false
    end
    if GiveAmmoToSlingshot(inst, slingshot, taken, next_entry.slot) then
        inst._walter_loaded_ammo_slot = next_entry.slot
        inst._walter_preloaded_ammo = true
        WalterLog("预装弹", "slot=" .. tostring(next_entry.slot), "prefab=" .. tostring(taken.prefab))
        return true
    end

    inv:GiveItem(taken, next_entry.slot)
    WalterLog("预装弹失败：放入弹弓失败", tostring(taken.prefab))
    return false
end

function M.PrepareRangedAttack(inst, slingshot)
    slingshot = slingshot or M.FindSlingshot(inst)
    if slingshot == nil or slingshot.components == nil or slingshot.components.container == nil then
        return false
    end
    ApplySlingshotRange(slingshot)

    local inv = GetInventory(inst)
    if inv == nil then return false end

    local loaded = GetLoadedAmmo(slingshot)
    if loaded ~= nil then
        local slots = GetInventoryAmmoSlots(inst)
        if inst._walter_preloaded_ammo or #slots == 0 then
            inst._walter_preloaded_ammo = nil
            inst._walter_last_ammo_slot = inst._walter_loaded_ammo_slot or inst._walter_last_ammo_slot or 0
            WalterLog("使用已装弹药", "slot=" .. tostring(inst._walter_loaded_ammo_slot), "prefab=" .. tostring(loaded.prefab), "背包弹药=" .. FormatAmmoSlots(slots))
            return slingshot.components.weapon ~= nil
                and slingshot.components.weapon.projectile ~= nil
        end

        local next_entry = PickNextAmmoSlot(inst, slots)
        if next_entry == nil or next_entry.item == nil then
            return slingshot.components.weapon ~= nil
                and slingshot.components.weapon.projectile ~= nil
        end

        local next_ammo = inv:RemoveItem(next_entry.item, true)
        if next_ammo == nil then
            WalterLog("换弹失败：移除下一组弹药失败", next_entry.slot, next_entry.item.prefab)
            return slingshot.components.weapon ~= nil
                and slingshot.components.weapon.projectile ~= nil
        end

        local old_slot = inst._walter_loaded_ammo_slot
        local old_ammo, cleared, remaining = RemoveLoadedAmmoWhole(slingshot)
        if not cleared then
            inv:GiveItem(next_ammo, next_entry.slot)
            WalterLog("换弹失败：弹弓旧弹药未整组移除",
                "old=" .. tostring(old_ammo and old_ammo.prefab or "nil"),
                "remaining=" .. tostring(remaining and remaining.prefab or "nil"))
            return slingshot.components.weapon ~= nil
                and slingshot.components.weapon.projectile ~= nil
        end
        if old_ammo ~= nil then
            -- 取出的弹药会保留 prevcontainer=slingshot。
            -- Inventory:GiveItem 可能把旧弹药自动退回手上弹弓，所以先清理回退目标。
            -- 然后再把旧弹药整组放回沃尔特背包。
            old_ammo.prevcontainer = nil
            old_ammo.prevslot = old_slot
            local returned = old_slot ~= nil and inv:GiveItem(old_ammo, old_slot) or false
            if not returned then
                returned = inv:GiveItem(old_ammo)
            end
            if not returned then
                GiveAmmoToSlingshot(inst, slingshot, old_ammo, old_slot)
                inv:GiveItem(next_ammo)
                WalterLog("换弹失败：旧弹药无法回背包", tostring(old_ammo.prefab))
                return slingshot.components.weapon ~= nil
                    and slingshot.components.weapon.projectile ~= nil
            end
        end

        if not GiveAmmoToSlingshot(inst, slingshot, next_ammo, next_entry.slot) then
            inv:GiveItem(next_ammo, next_entry.slot)
            WalterLog("换弹失败：新弹药无法装入弹弓", tostring(next_ammo.prefab))
            return old_ammo ~= nil
                and slingshot.components.weapon ~= nil
                and slingshot.components.weapon.projectile ~= nil
        end

        inst._walter_last_ammo_slot = next_entry.slot
        inst._walter_loaded_ammo_slot = next_entry.slot
        inst._walter_preloaded_ammo = nil
        WalterLog("攻击前换弹", "old=" .. tostring(old_ammo and old_ammo.prefab or "nil") .. "@" .. tostring(old_slot), "new=" .. tostring(next_ammo.prefab) .. "@" .. tostring(next_entry.slot), "背包弹药=" .. FormatAmmoSlots(GetInventoryAmmoSlots(inst)))
        return slingshot.components.weapon ~= nil
            and slingshot.components.weapon.projectile ~= nil
    end

    local slots = GetInventoryAmmoSlots(inst)
    local next_entry = PickNextAmmoSlot(inst, slots)
    if next_entry == nil or next_entry.item == nil then
        WalterLogCooldown(inst, "attack_no_ammo", 8, "攻击前装弹失败：背包无弹药", "last_slot=" .. tostring(inst._walter_last_ammo_slot))
        return false
    end

    local next_ammo = inv:RemoveItem(next_entry.item, true)
    if next_ammo == nil then
        WalterLog("攻击前装弹失败：移除弹药失败", next_entry.slot, next_entry.item.prefab)
        return false
    end

    if not GiveAmmoToSlingshot(inst, slingshot, next_ammo, next_entry.slot) then
        inv:GiveItem(next_ammo, next_entry.slot)
        WalterLog("攻击前装弹失败：放入弹弓失败", tostring(next_ammo.prefab))
        return false
    end

    inst._walter_last_ammo_slot = next_entry.slot
    inst._walter_loaded_ammo_slot = next_entry.slot
    inst._walter_preloaded_ammo = nil
    WalterLog("攻击前装弹", "slot=" .. tostring(next_entry.slot), "prefab=" .. tostring(next_ammo.prefab), "背包弹药=" .. FormatAmmoSlots(slots))
    return slingshot.components.weapon ~= nil
        and slingshot.components.weapon.projectile ~= nil
end

local function EquipBestMelee(inst)
    local inv = GetInventory(inst)
    if inv == nil then return false end

    local current = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if current ~= nil and current.prefab ~= "slingshot" then
        return true
    end

    local best, best_dmg = nil, -1
    for i = 1, inv.maxslots do
        local item = inv:GetItemInSlot(i)
        if item ~= nil
            and item.prefab ~= "slingshot"
            and item.components ~= nil
            and item.components.weapon ~= nil
            and item.components.equippable ~= nil
            and item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
            local dmg = item.components.weapon:GetDamage(inst) or 0
            if dmg > best_dmg then
                best = item
                best_dmg = dmg
            end
        end
    end

    if best ~= nil then
        inv:Equip(best)
        return true
    end
    return false
end

local function UnequipEmptySlingshotForBareHands(inst, slingshot)
    local inv = GetInventory(inst)
    if inv == nil or slingshot == nil or M.HasLoadedOrInventoryAmmo(inst, slingshot) then
        return false
    end

    local current = inv:GetEquippedItem(EQUIPSLOTS.HANDS)
    if current ~= slingshot then
        return false
    end

    inv:Unequip(EQUIPSLOTS.HANDS)
    if current:IsValid() then
        inv:GiveItem(current)
    end
    WalterLogCooldown(inst, "empty_slingshot_bare_hands", 8, "空弹弓无弹药且无近战武器，改为空手近战")
    WobyRide.SyncMountedMeleeDamage(inst)
    return true
end

local function CheckNearbyAggro(inst, radius)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, { "_combat" }, { "INLIMBO", "notarget", "noattack", "playerghost" })
    local details = {}
    local aggro_count = 0
    for _, ent in ipairs(ents) do
        if ent ~= inst and ent:IsValid() then
            local combat = ent.components ~= nil and ent.components.combat or nil
            local ent_target = combat ~= nil and combat.target or nil
            local dead = ent.components ~= nil
                and ent.components.health ~= nil
                and ent.components.health:IsDead()
            local is_aggro = combat ~= nil and ent_target == inst and not dead
            if is_aggro then
                aggro_count = aggro_count + 1
            end
            if #details < 6 then
                table.insert(details, EntityName(ent)
                    .. "->" .. EntityName(ent_target)
                    .. (dead and "(dead)" or "")
                    .. (is_aggro and "(aggro)" or ""))
            end
        end
    end
    return aggro_count > 0, table.concat(details, ","), #ents, aggro_count
end

local function LogRangedRetreatCheck(inst, reason, target, dist, min_dist, slingshot, has_ammo, riding, aggro_count, scan_count, aggro_details)
    WalterLogCooldown(inst, "ranged_retreat_check_" .. tostring(reason), 2,
        "远程后撤检查",
        "result=" .. tostring(reason),
        "target=" .. EntityName(target),
        "dist=" .. string.format("%.1f", dist or -1),
        "need_dist=" .. tostring(min_dist),
        "slingshot=" .. EntityName(slingshot),
        "has_ammo=" .. tostring(has_ammo),
        "riding=" .. tostring(riding),
        "scan=" .. tostring(scan_count or 0),
        "aggro=" .. tostring(aggro_count or 0),
        "nearby=" .. tostring(aggro_details or ""))
end

function M.GetRangedRetreatPoint(inst, target)
    if not IsWalter(inst) or target == nil or not target:IsValid() then
        return nil
    end

    local slingshot = M.FindSlingshot(inst)
    local has_ammo = slingshot ~= nil and M.HasLoadedOrInventoryAmmo(inst, slingshot) or false
    local min_dist = NPC_TUNING.WALTER_SLINGSHOT_MIN_DIST or 7
    local dsq = inst:GetDistanceSqToInst(target)
    local dist = math.sqrt(dsq)
    local riding = inst.components ~= nil
        and inst.components.rider ~= nil
        and inst.components.rider:IsRiding()

    if slingshot == nil or not has_ammo then
        LogRangedRetreatCheck(inst, "no_ammo", target, dist, min_dist, slingshot, has_ammo, riding)
        return nil
    end

    if dsq >= min_dist * min_dist then
        LogRangedRetreatCheck(inst, "far_enough", target, dist, min_dist, slingshot, has_ammo, riding)
        return nil
    end

    local has_aggro, aggro_details, scan_count, aggro_count = CheckNearbyAggro(inst, NPC_TUNING.WALTER_RANGED_RETREAT_AGGRO_RADIUS or min_dist)
    if has_aggro then
        LogRangedRetreatCheck(inst, "blocked_aggro", target, dist, min_dist, slingshot, has_ammo, riding, aggro_count, scan_count, aggro_details)
        return nil
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local tx, _, tz = target.Transform:GetWorldPosition()
    local dx, dz = ix - tx, iz - tz
    local dist = math.sqrt(dx * dx + dz * dz)
    if dist > 0.01 then
        dx, dz = dx / dist, dz / dist
    else
        local angle = inst.Transform:GetRotation() * DEGREES
        dx, dz = math.cos(angle), -math.sin(angle)
    end

    local desired = (NPC_TUNING.WALTER_RANGED_RETREAT_DIST or min_dist) + 0.5
    local step = math.max(2, desired - dist)
    local base_angle = math.atan2(dz, dx)
    for _, offset in ipairs({ 0, math.pi / 6, -math.pi / 6, math.pi / 3, -math.pi / 3, math.pi / 2, -math.pi / 2 }) do
        local angle = base_angle + offset
        local px = ix + math.cos(angle) * step
        local pz = iz + math.sin(angle) * step
        local pt = Point(px, 0, pz)
        if TheWorld.Map:IsPassableAtPoint(px, 0, pz)
            and not TheWorld.Map:IsGroundTargetBlocked(pt) then
            LogRangedRetreatCheck(inst, "retreat", target, dist, min_dist, slingshot, has_ammo, riding, aggro_count, scan_count, aggro_details)
            return pt
        end
    end
    LogRangedRetreatCheck(inst, "no_path", target, dist, min_dist, slingshot, has_ammo, riding, aggro_count, scan_count, aggro_details)
    return nil
end

function M.TryEquipForTarget(inst, target)
    if not IsWalter(inst) or target == nil or not target:IsValid() then
        return false
    end

    local inv = GetInventory(inst)
    if inv == nil then return false end

    local min_dist = NPC_TUNING.WALTER_SLINGSHOT_MIN_DIST or 5
    local dsq = inst:GetDistanceSqToInst(target)
    if dsq <= min_dist * min_dist then
        if not EquipBestMelee(inst) then
            UnequipEmptySlingshotForBareHands(inst, M.FindSlingshot(inst))
        end
        WobyRide.SyncMountedMeleeDamage(inst)
        return false
    end

    local slingshot = M.FindSlingshot(inst)
    if slingshot == nil or not M.TryLoadAmmo(inst, slingshot) then
        if not EquipBestMelee(inst) then
            UnequipEmptySlingshotForBareHands(inst, slingshot)
        end
        return false
    end
    ApplySlingshotRange(slingshot)

    if inv:GetEquippedItem(EQUIPSLOTS.HANDS) ~= slingshot then
        inv:Equip(slingshot)
    end
    return inv:GetEquippedItem(EQUIPSLOTS.HANDS) == slingshot
        and slingshot.components.weapon ~= nil
        and slingshot.components.weapon.projectile ~= nil
end

function M.on_apply(inst)
    inst:AddTag("slingshot_sharpshooter")
    inst:AddTag("dogrider")
    if TheWorld.ismastersim then
        if inst.components.rider == nil then
            inst:AddComponent("rider")
        end
        if inst.components.pinnable == nil then
            inst:AddComponent("pinnable")
        end
        if inst.components.storyteller == nil then
            inst:AddComponent("storyteller")
        end
        inst.components.storyteller:SetStoryToTellFn(StoryToTellFn)
        inst.components.storyteller:SetOnStoryOverFn(StoryTellingDone)
        inst:DoTaskInTime(0, WobyRide.EnsureWoby)
        if inst._npc_woby_task == nil then
            inst._npc_woby_task = inst:DoPeriodicTask(10, WobyRide.EnsureWoby)
        end
        if inst._npc_woby_ride_task == nil then
            inst._npc_woby_ride_task = inst:DoPeriodicTask(0.5, WobyRide.UpdateFollowRide)
        end
        if not inst._npc_woby_remove_listener then
            inst._npc_woby_remove_listener = true
            inst:ListenForEvent("onremove", WobyRide.RemoveWoby)
        end
        if not inst._npc_walter_story_remove_listener then
            inst._npc_walter_story_remove_listener = true
            inst:ListenForEvent("onremove", function(i)
                StoryTellingDone(i)
            end)
        end
    end
end

return M
