local ShadowMinionPool = {}
ShadowMinionPool.MODNAME = nil
ShadowMinionPool.CREATURES = {
    spider = {
        prefab = "spider",
        name_key = "SPIDER",
        required_item = "monstermeat",
        category = "spiders",
    },
    spider_warrior = {
        prefab = "spider_warrior",
        name_key = "SPIDER_WARRIOR",
        required_item = "monstermeat",
        category = "spiders",
    },
    spider_hider = {
        prefab = "spider_hider",
        name_key = "SPIDER_HIDER",
        required_item = "monstermeat",
        category = "spiders",
    },
    spider_spitter = {
        prefab = "spider_spitter",
        name_key = "SPIDER_SPITTER",
        required_item = "monstermeat",
        category = "spiders",
    },
    spider_dropper = {
        prefab = "spider_dropper",
        name_key = "SPIDER_DROPPER",
        required_item = "monstermeat",
        category = "spiders",
    },
    spider_healer = {
        prefab = "spider_healer",
        name_key = "SPIDER_HEALER",
        required_item = "monstermeat",
        category = "spiders",
    },
    spider_water = {
        prefab = "spider_water",
        name_key = "SPIDER_WATER",
        required_item = "monstermeat",
        category = "spiders",
    },
    hound = {
        prefab = "hound",
        name_key = "HOUND",
        required_item = "monstermeat",
        category = "beasts",
    },
    mutatedhound = {
        prefab = "mutatedhound",
        name_key = "MUTATEDHOUND",
        required_item = "monstermeat",
        category = "beasts",
    },
    bat = {
        prefab = "bat",
        name_key = "BAT",
        required_item = "batwing",
        category = "beasts",
    },
    frog = {
        prefab = "frog",
        name_key = "FROG",
        required_item = "froglegs",
        category = "beasts",
    },
    pigman = {
        prefab = "pigman",
        name_key = "PIGMAN",
        required_item = "meat",
        category = "humanoids",
    },
    pigguard = {
        prefab = "pigguard",
        name_key = "PIGGUARD",
        required_item = "meat",
        category = "humanoids",
    },
    bunnyman = {
        prefab = "bunnyman",
        name_key = "BUNNYMAN",
        required_item = "carrot",
        category = "humanoids",
    },
    merm = {
        prefab = "merm",
        name_key = "MERM",
        required_item = "froglegs",
        category = "humanoids",
    },
    beeguard = {
        prefab = "beeguard",
        name_key = "BEEGUARD",
        required_item = "stinger",
        category = "insects",
    },
    mutated_penguin = {
        prefab = "mutated_penguin",
        name_key = "MUTATED_PENGUIN",
        required_item = "monstermeat",
        category = "beasts",
    },
    squid = {
        prefab = "squid",
        name_key = "SQUID",
        required_item = "monstermeat",
        category = "ocean",
    },
}
ShadowMinionPool.CREATURE_ORDER = {
    "spider",
    "spider_warrior",
    "spider_hider",
    "spider_spitter",
    "spider_dropper",
    "spider_healer",
    "spider_water",
    "hound",
    "mutatedhound",
    "bat",
    "frog",
    "pigman",
    "pigguard",
    "bunnyman",
    "merm",
    "beeguard",
    "mutated_penguin",
    "squid",
}
ShadowMinionPool.MAX_MINIONS = 3
ShadowMinionPool.ITEM_SEARCH_RADIUS = 8
local function GetDefaultPoolData()
    return {
        unlocked = {},
        favorite = nil,
        active_minions = {},
        pending_summons = 0,
    }
end
function ShadowMinionPool.SetupPlayer(inst)
    inst._shadow_pool = GetDefaultPoolData()
    inst:ListenForEvent("killed", function(player, data)
        if data and data.victim then
            ShadowMinionPool.OnKill(inst, data.victim)
        else
        end
    end)
    inst:ListenForEvent("death", function()
        ShadowMinionPool.DespawnAllMinions(inst)
    end)
    inst:ListenForEvent("onremove", function()
        ShadowMinionPool.DespawnAllMinions(inst)
    end)
    inst:ListenForEvent("ms_playerdespawn", function()
        ShadowMinionPool.DespawnAllMinions(inst)
    end)
    inst:ListenForEvent("ms_playerreroll", function()
        ShadowMinionPool.DespawnAllMinions(inst)
    end)
end
function ShadowMinionPool.CleanupOrphanedMinions()
    local x, y, z = 0, 0, 0
    if TheWorld and TheWorld.Map then
        local width, height = TheWorld.Map:GetSize()
        x = (width or 0) * 2
        z = (height or 0) * 2
        y = 0
    end
    local minions = TheSim:FindEntities(x, y, z, 10000, {"kodi_summoned_minion"})
    for _, minion in ipairs(minions) do
        if minion:IsValid() and not minion:HasTag("player") then
            local owner = minion._shadow_owner
            if not owner or not owner:IsValid() then
                minion:Remove()
            end
        end
    end
end
function ShadowMinionPool.OnKill(player, victim)
    if not victim then
        return
    end
    if not victim.prefab then
        return
    end
    local victim_prefab = victim.prefab
    for id, data in pairs(ShadowMinionPool.CREATURES) do
        if data.prefab == victim_prefab then
            ShadowMinionPool.UnlockCreature(player, id)
            break
        end
    end
end
function ShadowMinionPool.UnlockCreature(player, creature_id)
    if not player._shadow_pool then
        return
    end
    if player._shadow_pool.unlocked[creature_id] then
        return false
    end
    player._shadow_pool.unlocked[creature_id] = true
    local creature_data = ShadowMinionPool.CREATURES[creature_id]
    if creature_data and player.components.talker then
        local name = STRINGS.SHADOW_MINION_POOL and
                     STRINGS.SHADOW_MINION_POOL.CREATURES and
                     STRINGS.SHADOW_MINION_POOL.CREATURES[creature_data.name_key] or
                     creature_id
        local msg = STRINGS.SHADOW_MINION_POOL and
                    STRINGS.SHADOW_MINION_POOL.UNLOCKED or
                    "*shadow of %s unlocked*"
        player.components.talker:Say(string.format(msg, name), 2.5, true)
    end
    return true
end
function ShadowMinionPool.IsUnlocked(player, creature_id)
    if not player._shadow_pool then return false end
    return player._shadow_pool.unlocked[creature_id] or false
end
function ShadowMinionPool.GetUnlockedCreatures(player)
    if not player._shadow_pool then return {} end
    local unlocked = {}
    for _, id in ipairs(ShadowMinionPool.CREATURE_ORDER) do
        if player._shadow_pool.unlocked[id] then
            table.insert(unlocked, id)
        end
    end
    return unlocked
end
function ShadowMinionPool.SetFavorite(player, creature_id)
    if not player._shadow_pool then return end
    if creature_id and not ShadowMinionPool.IsUnlocked(player, creature_id) then
        return false
    end
    player._shadow_pool.favorite = creature_id
    return true
end
function ShadowMinionPool.GetFavorite(player)
    if not player._shadow_pool then return nil end
    return player._shadow_pool.favorite
end
function ShadowMinionPool.ToggleFavorite(player, creature_id)
    if not player._shadow_pool then return end
    if player._shadow_pool.favorite == creature_id then
        player._shadow_pool.favorite = nil
    else
        ShadowMinionPool.SetFavorite(player, creature_id)
    end
end
function ShadowMinionPool.FindRequiredItems(player, creature_id)
    local creature_data = ShadowMinionPool.CREATURES[creature_id]
    if not creature_data then return {}, 0 end
    local required_item = creature_data.required_item
    local x, y, z = player.Transform:GetWorldPosition()
    local items = TheSim:FindEntities(x, y, z, ShadowMinionPool.ITEM_SEARCH_RADIUS,
        nil,
        {"INLIMBO", "FX", "player", "structure"})
    local found_items = {}
    for _, item in ipairs(items) do
        if item.prefab == required_item and
           item.components.inventoryitem and
           not item.components.inventoryitem:IsHeld() and
           not item:HasTag("kodi_claimed_for_summon") then
            table.insert(found_items, item)
        end
    end
    return found_items, #found_items
end
function ShadowMinionPool.GetRequiredItemName(creature_id)
    local creature_data = ShadowMinionPool.CREATURES[creature_id]
    if not creature_data then return "?" end
    local item_prefab = creature_data.required_item
    if STRINGS.NAMES and STRINGS.NAMES[string.upper(item_prefab)] then
        return STRINGS.NAMES[string.upper(item_prefab)]
    end
    return item_prefab
end
function ShadowMinionPool.GetActiveMinionsCount(player)
    if not player._shadow_pool then return 0 end
    local valid_minions = {}
    local slot_count = 0
    for _, minion in ipairs(player._shadow_pool.active_minions) do
        if minion:IsValid() then
            table.insert(valid_minions, minion)
            slot_count = slot_count + (minion._pool_slot_count or 1)
        end
    end
    player._shadow_pool.active_minions = valid_minions
    return slot_count + (player._shadow_pool.pending_summons or 0)
end
function ShadowMinionPool.GetActiveSpiderWarriors(player)
    if not player._shadow_pool then return {} end
    local warriors = {}
    for _, minion in ipairs(player._shadow_pool.active_minions) do
        if minion:IsValid() and minion.prefab == "spider_warrior" then
            table.insert(warriors, minion)
        end
    end
    return warriors
end
function ShadowMinionPool.CanSummonMore(player)
    return ShadowMinionPool.GetActiveMinionsCount(player) < ShadowMinionPool.MAX_MINIONS
end
function ShadowMinionPool.RegisterMinion(player, minion)
    if not player._shadow_pool then return end
    table.insert(player._shadow_pool.active_minions, minion)
    minion:ListenForEvent("onremove", function()
        ShadowMinionPool.UnregisterMinion(player, minion)
    end)
    local ShadowMinion = require("skills/shadow_minion")
    if ShadowMinion.OnMinionPoolLifetimeSyncCallback then
        ShadowMinion.OnMinionPoolLifetimeSyncCallback(player)
    end
end
function ShadowMinionPool.UnregisterMinion(player, minion)
    if not player._shadow_pool then return end
    for i, m in ipairs(player._shadow_pool.active_minions) do
        if m == minion then
            table.remove(player._shadow_pool.active_minions, i)
            break
        end
    end
    local ShadowMinion = require("skills/shadow_minion")
    if ShadowMinion.OnMinionPoolLifetimeSyncCallback and player:IsValid() then
        ShadowMinion.OnMinionPoolLifetimeSyncCallback(player)
    end
end
function ShadowMinionPool.DespawnAllMinions(player)
    if not player._shadow_pool then return end
    for _, minion in ipairs(player._shadow_pool.active_minions) do
        if minion:IsValid() then
            if minion._owner_ref and minion._owner_ref:IsValid() then
                if minion._owner_attacked_listener then
                    minion._owner_ref:RemoveEventCallback("attacked", minion._owner_attacked_listener)
                end
                if minion._owner_attack_other_listener then
                    minion._owner_ref:RemoveEventCallback("onattackother", minion._owner_attack_other_listener)
                end
            end
            local x, y, z = minion.Transform:GetWorldPosition()
            local fx = SpawnPrefab("shadow_despawn")
            if fx then
                fx.Transform:SetPosition(x, y, z)
            end
            minion:Remove()
        end
    end
    player._shadow_pool.active_minions = {}
    player._shadow_pool.pending_summons = 0
    local ShadowMinion = require("skills/shadow_minion")
    if ShadowMinion.OnMinionPoolLifetimeSyncCallback then
        ShadowMinion.OnMinionPoolLifetimeSyncCallback(player)
    end
end
function ShadowMinionPool.TrySummon(player, creature_id)
    if not player:HasTag("kodi_shadow_minion") then
        return false, "NO_SKILL"
    end
    if not ShadowMinionPool.IsUnlocked(player, creature_id) then
        return false, "CREATURE_LOCKED"
    end
    if not ShadowMinionPool.CanSummonMore(player) then
        return false, "MAX_MINIONS"
    end
    local items, count = ShadowMinionPool.FindRequiredItems(player, creature_id)
    if count == 0 then
        return false, "NO_ITEMS"
    end
    local item_to_consume = items[1]
    local spawn_pos = item_to_consume:GetPosition()
    local creature_data = ShadowMinionPool.CREATURES[creature_id]
    local ShadowMinion = require("skills/shadow_minion")
    item_to_consume:AddTag("kodi_claimed_for_summon")
    player._shadow_pool.pending_summons = (player._shadow_pool.pending_summons or 0) + 1
    ShadowMinion.SpawnWithEffects(player, creature_data.prefab, spawn_pos, item_to_consume, function(minion)
        player._shadow_pool.pending_summons = math.max(0, (player._shadow_pool.pending_summons or 1) - 1)
        if minion then
            ShadowMinionPool.RegisterMinion(player, minion)
        end
    end)
    player:DoTaskInTime(3, function()
        if item_to_consume and item_to_consume:IsValid() then
            item_to_consume:RemoveTag("kodi_claimed_for_summon")
        end
    end)
    return true, "SUCCESS"
end
function ShadowMinionPool.TrySummonFavorite(player)
    local favorite = ShadowMinionPool.GetFavorite(player)
    if not favorite then
        return false, "NO_FAVORITE"
    end
    return ShadowMinionPool.TrySummon(player, favorite)
end
function ShadowMinionPool.OnSave(player)
    if not player._shadow_pool then
        return nil
    end
    return {
        unlocked = player._shadow_pool.unlocked,
        favorite = player._shadow_pool.favorite,
    }
end
function ShadowMinionPool.OnLoad(player, data)
    if not player._shadow_pool then
        player._shadow_pool = GetDefaultPoolData()
    end
    if data then
        if data.unlocked then
            player._shadow_pool.unlocked = data.unlocked
        end
        if data.favorite then
            if ShadowMinionPool.CREATURES[data.favorite] then
                player._shadow_pool.favorite = data.favorite
            else
            end
        end
    else
    end
end
function ShadowMinionPool.GetCreatureDisplayName(creature_id)
    local creature_data = ShadowMinionPool.CREATURES[creature_id]
    if not creature_data then return creature_id end
    if STRINGS.SHADOW_MINION_POOL and
       STRINGS.SHADOW_MINION_POOL.CREATURES and
       STRINGS.SHADOW_MINION_POOL.CREATURES[creature_data.name_key] then
        return STRINGS.SHADOW_MINION_POOL.CREATURES[creature_data.name_key]
    end
    if STRINGS.NAMES and STRINGS.NAMES[string.upper(creature_data.prefab)] then
        return STRINGS.NAMES[string.upper(creature_data.prefab)]
    end
    return creature_id
end
function ShadowMinionPool.GetAllCreaturesForUI(player)
    local result = {}
    for _, id in ipairs(ShadowMinionPool.CREATURE_ORDER) do
        local creature_data = ShadowMinionPool.CREATURES[id]
        if creature_data then
            table.insert(result, {
                id = id,
                name = ShadowMinionPool.GetCreatureDisplayName(id),
                unlocked = ShadowMinionPool.IsUnlocked(player, id),
                is_favorite = (ShadowMinionPool.GetFavorite(player) == id),
                required_item = creature_data.required_item,
                required_item_name = ShadowMinionPool.GetRequiredItemName(id),
            })
        end
    end
    return result
end
function ShadowMinionPool.SerializeForClient(player)
    if not player._shadow_pool then return "" end
    local parts = {}
    for id, _ in pairs(player._shadow_pool.unlocked) do
        table.insert(parts, "u:" .. id)
    end
    if player._shadow_pool.favorite then
        table.insert(parts, "f:" .. player._shadow_pool.favorite)
    end
    local count = ShadowMinionPool.GetActiveMinionsCount(player)
    table.insert(parts, "c:" .. count)
    return table.concat(parts, "|")
end
function ShadowMinionPool.DeserializeOnClient(player, data_str)
    if not data_str or data_str == "" then
        player._shadow_pool_client = {
            unlocked = {},
            favorite = nil,
            active_count = 0,
        }
        return
    end
    local result = {
        unlocked = {},
        favorite = nil,
        active_count = 0,
    }
    for part in string.gmatch(data_str, "[^|]+") do
        local prefix, value = string.match(part, "^(%a):(.+)$")
        if prefix == "u" then
            result.unlocked[value] = true
        elseif prefix == "f" then
            result.favorite = value
        elseif prefix == "c" then
            result.active_count = tonumber(value) or 0
        end
    end
    player._shadow_pool_client = result
end
function ShadowMinionPool.GetAllCreaturesForUIClient(player)
    local pool_data = player._shadow_pool_client or { unlocked = {}, favorite = nil }
    local result = {}
    for _, id in ipairs(ShadowMinionPool.CREATURE_ORDER) do
        local creature_data = ShadowMinionPool.CREATURES[id]
        if creature_data then
            table.insert(result, {
                id = id,
                name = ShadowMinionPool.GetCreatureDisplayName(id),
                unlocked = pool_data.unlocked[id] or false,
                is_favorite = (pool_data.favorite == id),
                required_item = creature_data.required_item,
                required_item_name = ShadowMinionPool.GetRequiredItemName(id),
            })
        end
    end
    return result
end
function ShadowMinionPool.GetActiveMinionsCountClient(player)
    if player._shadow_pool_client then
        return player._shadow_pool_client.active_count or 0
    end
    return 0
end
return ShadowMinionPool
