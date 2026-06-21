local KodiGamepad = {}
local GLOBAL = nil
local TheInput = nil
local TUNING = nil
local KodiTransform = nil
local SendModRPCToServer = nil
local MOD_RPC = nil
local KODI_MODNAME = nil
function KodiGamepad.SetDependencies(deps)
    GLOBAL = deps.GLOBAL
    TheInput = deps.TheInput
    TUNING = deps.TUNING
    KodiTransform = deps.KodiTransform
    SendModRPCToServer = deps.SendModRPCToServer
    MOD_RPC = deps.MOD_RPC
    KODI_MODNAME = deps.KODI_MODNAME
end
local function GetLeftStickDirection()
    local x = TheInput:GetAnalogControlValue(GLOBAL.CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(GLOBAL.CONTROL_MOVE_LEFT)
    local z = TheInput:GetAnalogControlValue(GLOBAL.CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(GLOBAL.CONTROL_MOVE_DOWN)
    local magnitude = math.sqrt(x * x + z * z)
    if magnitude < 0.3 then
        return nil, nil, 0
    end
    return x / magnitude, z / magnitude, magnitude
end
local function GetMaxDashDistanceForEnergy(player)
    if not player.GetDemonicPercent then return TUNING.KODI_GAMEPAD_DASH_DISTANCE end
    local current_energy = player:GetDemonicPercent() * 100
    local available_energy = current_energy - TUNING.KODI_SHADOW_DASH_ENERGY_RESERVE
    if available_energy <= 0 then return 0 end
    local max_distance = (available_energy - TUNING.KODI_SHADOW_DASH_MIN_ENERGY) / TUNING.KODI_SHADOW_DASH_ENERGY_PER_TILE
    return math.max(0, max_distance)
end
local function FindNearestTarget(player, radius, filter_fn)
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, radius)
    local best_dist_sq = radius * radius
    local best_ent = nil
    for _, ent in ipairs(ents) do
        if ent ~= player and ent:IsValid() and filter_fn(ent) then
            local ex, ey, ez = ent.Transform:GetWorldPosition()
            local dx, dz = ex - x, ez - z
            local dist_sq = dx * dx + dz * dz
            if dist_sq < best_dist_sq then
                best_dist_sq = dist_sq
                best_ent = ent
            end
        end
    end
    return best_ent
end
local skill_activation_id = 0
local function ActivateFormSkill(player)
    if not player:IsValid() then return end
    if not GLOBAL.TheFrontEnd then return end
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    if not player.HUD or screen ~= player.HUD then return end
    local is_fox = player:HasTag("NotDemon")
    if is_fox then
        if player:HasTag("kodi_day_stalker") then
            if GLOBAL.TheNet:GetIsServer() then
                if player.ToggleDayStalkerStealth then
                    player:ToggleDayStalkerStealth()
                end
            else
                SendModRPCToServer(MOD_RPC[KODI_MODNAME]["DayStalkerStealth"])
            end
        elseif player:HasTag("kodi_night_hunter") then
            local target = FindNearestTarget(player, 15, function(ent)
                return ent.prefab and not ent:HasTag("player") and not ent:HasTag("wall")
                    and not ent:HasTag("structure") and not ent:HasTag("INLIMBO")
            end)
            if target then
                SendModRPCToServer(MOD_RPC[KODI_MODNAME]["NightHunterMark"], target)
            end
        end
    else
        if player:HasTag("kodi_shadow_eruption") then
            if player._kodi_eruption_cd_end then
                local now = GLOBAL.GetTime()
                if now < player._kodi_eruption_cd_end then
                    return
                end
            end
            player._kodi_eruption_cd_end = GLOBAL.GetTime() + TUNING.KODI_SHADOW_ERUPTION_COOLDOWN
            if GLOBAL.TheNet:GetIsServer() then
                if player.UseShadowEruption then
                    player:UseShadowEruption()
                end
            else
                SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowEruption"])
            end
        elseif player:HasTag("kodi_shadow_hands") then
            local target = FindNearestTarget(player, 15, function(ent)
                return ent:HasTag("_combat") and not ent:HasTag("player")
            end)
            if target then
                if GLOBAL.TheNet:GetIsServer() then
                    if player.StartShadowHands then
                        player:StartShadowHands(target)
                    end
                else
                    SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowHandsStart"], target)
                end
            end
        end
    end
end
local last_b_press_time = 0
local function OnGamepadControl(control, down)
    if not down then return false end
    if not TheInput:ControllerAttached() then return false end
    local is_b_button = (control == 30 or control == 32 or control == GLOBAL.CONTROL_CANCEL)
    if not is_b_button then return false end
    local player = GLOBAL.ThePlayer
    if not player then return false end
    if player.prefab ~= "kodi" then return false end
    if not GLOBAL.TheFrontEnd then return false end
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    if not player.HUD or screen ~= player.HUD then return false end
    if player.HUD:IsControllerCraftingOpen() or player.HUD:IsControllerInventoryOpen() then
        return false
    end
    if player.HUD.controls and player.HUD.controls.map and player.HUD.controls.map:IsVisible() then
        return false
    end
    if player:HasTag("kodi_channeling") and player:HasTag("kodi_shadow_hands") then
        if GLOBAL.TheNet:GetIsServer() then
            if player.StopShadowHands then
                player:StopShadowHands()
            end
        else
            SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowHandsStop"])
        end
        return true
    end
    skill_activation_id = skill_activation_id + 1
    local current_time = GLOBAL.GetTime()
    local time_since_last = current_time - last_b_press_time
    last_b_press_time = current_time
    if time_since_last < TUNING.KODI_DOUBLE_TAP_WINDOW then
        if GLOBAL.TheNet:GetIsServer() then
            KodiTransform(player)
        else
            SendModRPCToServer(MOD_RPC[KODI_MODNAME]["KodiTransform"])
        end
        return true
    end
    if not player:HasTag("NotDemon") and not player:HasTag("shadow_dash_cooldown") then
        local equipped = player.replica.inventory and player.replica.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
        local weapon_has_ability = equipped and equipped:HasTag("rechargeable")
        if not weapon_has_ability then
            local dir_x, dir_z, magnitude = GetLeftStickDirection()
            if dir_x and dir_z then
                local max_dist = GetMaxDashDistanceForEnergy(player)
                local dash_distance = math.min(TUNING.KODI_GAMEPAD_DASH_DISTANCE * magnitude, max_dist)
                if dash_distance > TUNING.KODI_SHADOW_DASH_MIN_DISTANCE then
                    local camera_right = GLOBAL.TheCamera:GetRightVec()
                    local camera_down = GLOBAL.TheCamera:GetDownVec()
                    local world_x = camera_right.x * dir_x - camera_down.x * dir_z
                    local world_z = camera_right.z * dir_x - camera_down.z * dir_z
                    local len = math.sqrt(world_x * world_x + world_z * world_z)
                    if len > 0 then
                        world_x = world_x / len
                        world_z = world_z / len
                    end
                    SendModRPCToServer(MOD_RPC[KODI_MODNAME]["ShadowDashDirection"], world_x, world_z, dash_distance)
                    return true
                end
            end
        end
    end
    local my_id = skill_activation_id
    player:DoTaskInTime(TUNING.KODI_DOUBLE_TAP_WINDOW, function()
        if skill_activation_id == my_id then
            ActivateFormSkill(player)
        end
    end)
    return false
end
function KodiGamepad.Register()
    TheInput:AddGeneralControlHandler(OnGamepadControl)
end
return KodiGamepad
