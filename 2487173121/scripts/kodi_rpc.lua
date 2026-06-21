local KodiRPC = {}
local GLOBAL = nil
local TUNING = nil
local ShadowDash = nil
local DayStalker = nil
local NightHunter = nil
local ShadowHands = nil
local ShadowEruption = nil
local ShadowCache = nil
local ShadowSummon = nil
local ShadowMinionPool = nil
local KodiTransform = nil
function KodiRPC.SetDependencies(deps)
    GLOBAL = deps.GLOBAL
    TUNING = deps.TUNING
    ShadowDash = deps.ShadowDash
    DayStalker = deps.DayStalker
    NightHunter = deps.NightHunter
    ShadowHands = deps.ShadowHands
    ShadowEruption = deps.ShadowEruption
    ShadowCache = deps.ShadowCache
    ShadowSummon = deps.ShadowSummon
    ShadowMinionPool = deps.ShadowMinionPool
    KodiTransform = deps.KodiTransform
end
function KodiRPC.GetServerHandlers()
    return {
        KodiTransform = function(player)
            if player and player.prefab == "kodi" then
                KodiTransform(player)
            end
        end,
        ShadowDash = function(player, target_x, target_z)
            if player and player.prefab == "kodi" and ShadowDash then
                ShadowDash.Execute(player, target_x, target_z)
            end
        end,
        ShadowDashDirection = function(player, dir_x, dir_z, distance)
            if player and player.prefab == "kodi" and ShadowDash then
                local px, py, pz = player.Transform:GetWorldPosition()
                local target_x = px + dir_x * distance
                local target_z = pz + dir_z * distance
                ShadowDash.Execute(player, target_x, target_z)
            end
        end,
        DayStalkerStealth = function(player)
            if player and player.prefab == "kodi" and DayStalker then
                DayStalker.ToggleStealth(player)
            end
        end,
        DayStalkerLeap = function(player, target_x, target_z)
            if player and player.prefab == "kodi" and DayStalker then
                DayStalker.ExecuteLeap(player, target_x, target_z)
            end
        end,
        NightHunterMark = function(player, target_guid)
            if player and player.prefab == "kodi" and NightHunter then
                local target = GLOBAL.Ents[target_guid]
                if target then
                    NightHunter.MarkTarget(player, target)
                end
            end
        end,
        NightHunterLeap = function(player, target_guid)
            if player and player.prefab == "kodi" and NightHunter then
                local target = GLOBAL.Ents[target_guid]
                if target then
                    NightHunter.ExecuteLeap(player, target)
                end
            end
        end,
        NightHunterVision = function(player)
            if player and player.prefab == "kodi" and NightHunter then
                NightHunter.ToggleVision(player)
            end
        end,
        ShadowHandsStart = function(player)
            if player and player.prefab == "kodi" and ShadowHands then
                ShadowHands.Start(player)
            end
        end,
        ShadowHandsStop = function(player)
            if player and player.prefab == "kodi" and ShadowHands then
                ShadowHands.Stop(player)
            end
        end,
        ShadowEruption = function(player)
            if player and player.prefab == "kodi" and ShadowEruption then
                ShadowEruption.Execute(player)
            end
        end,
        ShadowCacheOpen = function(player)
            if player and player.prefab == "kodi" and ShadowCache then
                ShadowCache.Open(player)
            end
        end,
        ShadowSummon = function(player, corpse_guid)
            if player and player.prefab == "kodi" and ShadowSummon then
                local corpse = corpse_guid and GLOBAL.Ents[corpse_guid]
                ShadowSummon.Execute(player, corpse)
            end
        end,
        ShadowPoolSync = function(player)
            if player and player.prefab == "kodi" and ShadowMinionPool then
                ShadowMinionPool.SyncToClient(player)
            end
        end,
        ShadowPoolSummon = function(player, prefab_name)
            if player and player.prefab == "kodi" and ShadowMinionPool then
                ShadowMinionPool.SummonPrefab(player, prefab_name)
            end
        end,
        ShadowPoolSetFavorite = function(player, prefab_name)
            if player and player.prefab == "kodi" and ShadowMinionPool then
                ShadowMinionPool.SetFavorite(player, prefab_name)
            end
        end,
    }
end
function KodiRPC.GetClientHandlers()
    return {
        ShadowSummonCooldownSync = function(player, duration)
            if player and player.SetShadowSummonCooldown then
                player:SetShadowSummonCooldown(duration)
            end
        end,
        NightHunterLeapCooldownSync = function(player, duration)
            if player and player.SetNightHunterLeapCooldown then
                player:SetNightHunterLeapCooldown(duration)
            end
        end,
        NightHunterMarkSync = function(player, count)
            if player and player.SetNightHunterMarkInfo then
                player:SetNightHunterMarkInfo(count, nil)
            end
        end,
        NightHunterMarkAdd = function(player)
            if player and player.AddNightHunterMark then
                player:AddNightHunterMark()
            end
        end,
        NightHunterMarkRemove = function(player, index)
            if player and player.RemoveNightHunterMark then
                player:RemoveNightHunterMark(index)
            end
        end,
        NightHunterMarksClear = function(player)
            if player and player.ClearNightHunterMarksUI then
                player:ClearNightHunterMarksUI()
            end
        end,
        ShadowPoolData = function(player, data_str)
            if player and player._shadow_minion_menu then
                local data = GLOBAL.json.decode(data_str)
                if data then
                    player._shadow_pool_unlocked = data.unlocked or {}
                    player._shadow_pool_favorite = data.favorite
                    player._shadow_minion_menu:RefreshData()
                end
            end
        end,
        DayStalkerFadeStart = function(player)
            if player then
                player._day_stalker_fade_start_time = GLOBAL.GetTime()
            end
        end,
        HideStart = function(player)
            if player then
                player._kodi_hide_start_time = GLOBAL.GetTime()
            end
        end,
    }
end
function KodiRPC.Register(modname, AddModRPCHandler, AddClientModRPCHandler)
    local server_handlers = KodiRPC.GetServerHandlers()
    for name, handler in pairs(server_handlers) do
        AddModRPCHandler(modname, name, handler)
    end
    local client_handlers = KodiRPC.GetClientHandlers()
    for name, handler in pairs(client_handlers) do
        AddClientModRPCHandler(modname, name, handler)
    end
end
return KodiRPC
