-- npc_ui_modes.lua
local POOL_CONFIG = require("npc/npc_pool_config")
local NPC_TUNING = require("npc_tuning")
local Widget
local Image

local UiModes = {}

local function _GetTuning(key, default)
    local v = NPC_TUNING and NPC_TUNING[key]
    return (type(v) == "number" and v > 0) and v or default
end

local StopPoolPlacementMode
local StopFishDepositMode
local StopOceanFishDepositMode
local StopWormwoodCropDepositMode
local StopWormwoodTrashDepositMode
local StopWinonaPlacementMode
local StopWaxwellMagicChestPlacementMode
local StopEquipBackpackMode

local _npc_location_markers = {
    points = {},
    clear_task = nil,
    expire_time = 0,
}

local function RefreshOpenMapLocationOverlay()
    if _G.TheFrontEnd == nil then return end
    local screen = _G.TheFrontEnd:GetOpenScreenOfType("MapScreen")
    if screen ~= nil and screen._npcfriends_rebuild_location_overlay ~= nil then
        screen:_npcfriends_rebuild_location_overlay()
    end
end

local function ClearNPCLocationMarkers()
    if _npc_location_markers.clear_task ~= nil then
        _npc_location_markers.clear_task:Cancel()
        _npc_location_markers.clear_task = nil
    end
    _npc_location_markers.points = {}
    _npc_location_markers.expire_time = 0
    RefreshOpenMapLocationOverlay()
end

local function GetNPCAvatar(char)
    if char == nil or char == "" then
        return "avatar_unknown.tex"
    end
    return "avatar_" .. tostring(char) .. ".tex"
end

local function ShowNPCLocationMarkers(payload)
    ClearNPCLocationMarkers()
    if type(payload) ~= "string" or payload == "" then return end

    for entry in payload:gmatch("[^;]+") do
        local char, x_s, z_s = entry:match("^([^,]+),([^,]+),([^,]+)$")
        local x = _G.tonumber(x_s)
        local z = _G.tonumber(z_s)
        if char ~= nil and x ~= nil and z ~= nil then
            _npc_location_markers.points[#_npc_location_markers.points + 1] = {
                char = char,
                x = x,
                z = z,
            }
        end
    end

    _npc_location_markers.expire_time = (_G.GetTime and _G.GetTime() or 0) + 30
    RefreshOpenMapLocationOverlay()
    local owner = _G.ThePlayer or _G.TheWorld
    if owner ~= nil then
        _npc_location_markers.clear_task = owner:DoTaskInTime(30, ClearNPCLocationMarkers)
    end
end

local function InstallNPCLocationMapOverlay(env)
    if env.AddClassPostConstruct == nil then return end
    Widget = Widget or require("widgets/widget")
    Image = Image or require("widgets/image")

    env.AddClassPostConstruct("screens/mapscreen", function(self)
        if self.minimap == nil then return end

        self._npcfriends_location_root = self.minimap:AddChild(Widget("npcfriends_location_root"))
        self._npcfriends_location_root:SetHAnchor(_G.ANCHOR_MIDDLE)
        self._npcfriends_location_root:SetVAnchor(_G.ANCHOR_MIDDLE)
        self._npcfriends_location_widgets = {}

        function self:_npcfriends_rebuild_location_overlay()
            if self._npcfriends_location_root == nil then return end
            self._npcfriends_location_root:KillAllChildren()
            self._npcfriends_location_widgets = {}

            local now = _G.GetTime and _G.GetTime() or 0
            if _npc_location_markers.expire_time <= now or #_npc_location_markers.points <= 0 then
                return
            end

            for _, point in ipairs(_npc_location_markers.points) do
                local holder = self._npcfriends_location_root:AddChild(Widget("npc_location_icon"))
                holder.bg = holder:AddChild(Image("images/avatars.xml", "avatar_bg.tex"))
                holder.head = holder:AddChild(Image("images/avatars.xml", GetNPCAvatar(point.char), "avatar_unknown.tex"))
                holder.frame = holder:AddChild(Image("images/avatars.xml", "avatar_frame_white.tex"))
                holder.bg:SetScale(0.45, 0.45, 1)
                holder.head:SetScale(0.45, 0.45, 1)
                holder.frame:SetScale(0.45, 0.45, 1)
                self._npcfriends_location_widgets[#self._npcfriends_location_widgets + 1] = {
                    widget = holder,
                    point = point,
                }
            end
        end

        function self:_npcfriends_update_location_overlay()
            local now = _G.GetTime and _G.GetTime() or 0
            if _npc_location_markers.expire_time > 0 and _npc_location_markers.expire_time <= now then
                ClearNPCLocationMarkers()
                return
            end

            if #_npc_location_markers.points ~= #self._npcfriends_location_widgets then
                self:_npcfriends_rebuild_location_overlay()
            end

            if #self._npcfriends_location_widgets <= 0 then return end

            local zoomscale = 0.75 / self.minimap:GetZoom()
            local w, h = _G.TheSim:GetScreenSize()
            w, h = w * 0.5, h * 0.5
            local scale = math.clamp(zoomscale, 0.25, 0.75)
            for _, entry in ipairs(self._npcfriends_location_widgets) do
                local x, y = self.minimap:WorldPosToMapPos(entry.point.x, entry.point.z, 0)
                entry.widget:SetPosition(x * w, y * h)
                entry.widget:SetScale(scale, scale, 1)
            end
        end

        local _OnUpdate = self.OnUpdate
        self.OnUpdate = function(s, dt)
            if _OnUpdate ~= nil then
                _OnUpdate(s, dt)
            end
            if s._npcfriends_update_location_overlay ~= nil then
                s:_npcfriends_update_location_overlay()
            end
        end

        self:_npcfriends_rebuild_location_overlay()
        self:_npcfriends_update_location_overlay()
    end)
end

--------------------------------------------------------------------------
-- 池塘放置模式
--------------------------------------------------------------------------

function UiModes.IsValidPoolPlacementAt(x, z)
    if not (_G.TheWorld and _G.TheWorld.Map and _G.TheSim) then return false end
    if type(x) ~= "number" or type(z) ~= "number" then return false end
    local map = _G.TheWorld.Map
    if not map:IsPassableAtPoint(x, 0, z) then return false end
    if map:IsOceanAtPoint(x, 0, z, true) then return false end
    if map.IsPointNearHole and map:IsPointNearHole(_G.Vector3(x, 0, z)) then return false end

    local min_dist = POOL_CONFIG.PLACE_MIN_DIST or 2
    local near = _G.TheSim:FindEntities(x, 0, z, min_dist, nil, {"INLIMBO"}, {"pond", "structure"})
    if near and #near > 0 then
        return false
    end
    return true
end

local _pool_place_state = {
    active = false,
    owner_param = nil,
    preview = nil,
    follow_task = nil,
    can_place = false,
    x = nil,
    z = nil,
}

StopPoolPlacementMode = function()
    _pool_place_state.active = false
    _pool_place_state.owner_param = nil
    _pool_place_state.can_place = false
    _pool_place_state.x, _pool_place_state.z = nil, nil
    if _pool_place_state.follow_task then
        _pool_place_state.follow_task:Cancel()
        _pool_place_state.follow_task = nil
    end
    if _pool_place_state.preview and _pool_place_state.preview:IsValid() then
        _pool_place_state.preview:Remove()
    end
    _pool_place_state.preview = nil
end

local function EnsurePoolPreview()
    if _pool_place_state.preview and _pool_place_state.preview:IsValid() then
        return _pool_place_state.preview
    end
    local inst = _G.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")
    local pool_build = POOL_CONFIG.BUILD or "moonglasspool_tile_big"
    local pool_bank = POOL_CONFIG.BANK or pool_build
    local pool_idle = POOL_CONFIG.IDLE_ANIM or "idle"
    inst.AnimState:SetBuild(pool_build)
    inst.AnimState:SetBank(pool_bank)
    inst.AnimState:PlayAnimation(pool_idle, true)
    inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(1)
    _pool_place_state.preview = inst
    return inst
end

local function StartPoolPlacementMode(owner_param)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    StopPoolPlacementMode()
    StopFishDepositMode()
    StopOceanFishDepositMode()
    StopWormwoodCropDepositMode()
    StopWormwoodTrashDepositMode()
    StopWaxwellMagicChestPlacementMode()
    StopEquipBackpackMode()
    _pool_place_state.active = true
    _pool_place_state.owner_param = owner_param
    local max_dist = POOL_CONFIG.PLACE_MAX_DIST or 20
    local max_dist_sq = max_dist * max_dist

    _pool_place_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _pool_place_state.active then return end
        local preview = EnsurePoolPreview()
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end
        preview.Transform:SetPosition(wx, 0, wz)

        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local in_dist = ((wx - px) * (wx - px) + (wz - pz) * (wz - pz)) <= max_dist_sq
        local valid = in_dist and UiModes.IsValidPoolPlacementAt(wx, wz)
        _pool_place_state.can_place = valid
        _pool_place_state.x, _pool_place_state.z = wx, wz
        if valid then
            preview.AnimState:SetMultColour(0.6, 1.0, 0.6, 0.8)
        else
            preview.AnimState:SetMultColour(1.0, 0.4, 0.4, 0.7)
        end
    end)
end

--------------------------------------------------------------------------
-- 钓鱼存放点放置模式
--------------------------------------------------------------------------

local _fish_deposit_state = {
    active = false,
    owner_param = nil,
    follow_task = nil,
    preview = nil,
    can_place = false,
    x = nil,
    z = nil,
}

local FISH_DEPOSIT_RADIUS = 12
local FISH_DEPOSIT_MAX_DIST = 40
local FISH_DEPOSIT_MAX_DIST_SQ = FISH_DEPOSIT_MAX_DIST * FISH_DEPOSIT_MAX_DIST

StopFishDepositMode = function()
    _fish_deposit_state.active = false
    _fish_deposit_state.owner_param = nil
    _fish_deposit_state.can_place = false
    _fish_deposit_state.x, _fish_deposit_state.z = nil, nil
    if _fish_deposit_state.follow_task then
        _fish_deposit_state.follow_task:Cancel()
        _fish_deposit_state.follow_task = nil
    end
    if _fish_deposit_state.preview and _fish_deposit_state.preview:IsValid() then
        _fish_deposit_state.preview:Remove()
    end
    _fish_deposit_state.preview = nil
end

local function EnsureFishDepositPreview()
    if _fish_deposit_state.preview and _fish_deposit_state.preview:IsValid() then
        return _fish_deposit_state.preview
    end
    local inst = _G.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")
    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("inner")
    inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(1)
    -- idle 动画对应半径约 9.7 格，缩放到 12 格
    local s = FISH_DEPOSIT_RADIUS / 9.7
    inst.AnimState:SetScale(s, s, s)
    _fish_deposit_state.preview = inst
    return inst
end

local function StartFishDepositMode(owner_param)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    StopFishDepositMode()
    StopPoolPlacementMode()
    StopOceanFishDepositMode()
    StopWormwoodCropDepositMode()
    StopWormwoodTrashDepositMode()
    StopWinonaPlacementMode()
    StopWaxwellMagicChestPlacementMode()
    StopEquipBackpackMode()
    _fish_deposit_state.active = true
    _fish_deposit_state.owner_param = owner_param

    _fish_deposit_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _fish_deposit_state.active then return end
        local preview = EnsureFishDepositPreview()
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end
        preview.Transform:SetPosition(wx, 0, wz)

        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local valid = ((wx - px) * (wx - px) + (wz - pz) * (wz - pz)) <= FISH_DEPOSIT_MAX_DIST_SQ
        _fish_deposit_state.can_place = valid
        _fish_deposit_state.x, _fish_deposit_state.z = wx, wz
        if valid then
            preview.AnimState:SetMultColour(0.6, 1.0, 0.6, 0.8)
        else
            preview.AnimState:SetMultColour(1.0, 0.4, 0.4, 0.7)
        end
    end)
end

--------------------------------------------------------------------------
-- 海钓存放点放置模式（温蒂专用）
--------------------------------------------------------------------------

local _ocean_fish_deposit_state = {
    active = false,
    owner_param = nil,
    follow_task = nil,
    preview = nil,
    can_place = false,
    x = nil,
    z = nil,
}

local OCEAN_FISH_DEPOSIT_RADIUS = 12
local OCEAN_FISH_DEPOSIT_MAX_DIST = 40
local OCEAN_FISH_DEPOSIT_MAX_DIST_SQ = OCEAN_FISH_DEPOSIT_MAX_DIST * OCEAN_FISH_DEPOSIT_MAX_DIST

StopOceanFishDepositMode = function()
    _ocean_fish_deposit_state.active = false
    _ocean_fish_deposit_state.owner_param = nil
    _ocean_fish_deposit_state.can_place = false
    _ocean_fish_deposit_state.x, _ocean_fish_deposit_state.z = nil, nil
    if _ocean_fish_deposit_state.follow_task then
        _ocean_fish_deposit_state.follow_task:Cancel()
        _ocean_fish_deposit_state.follow_task = nil
    end
    if _ocean_fish_deposit_state.preview and _ocean_fish_deposit_state.preview:IsValid() then
        _ocean_fish_deposit_state.preview:Remove()
    end
    _ocean_fish_deposit_state.preview = nil
end

local function EnsureOceanFishDepositPreview()
    if _ocean_fish_deposit_state.preview and _ocean_fish_deposit_state.preview:IsValid() then
        return _ocean_fish_deposit_state.preview
    end
    local inst = _G.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")
    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("inner")
    inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(1)
    -- idle 动画对应半径约 9.7 格，缩放到 OCEAN_FISH_DEPOSIT_RADIUS
    local s = OCEAN_FISH_DEPOSIT_RADIUS / 9.7
    inst.AnimState:SetScale(s, s, s)
    _ocean_fish_deposit_state.preview = inst
    return inst
end

local function StartOceanFishDepositMode(owner_param)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    StopOceanFishDepositMode()
    StopFishDepositMode()
    StopWormwoodCropDepositMode()
    StopWormwoodTrashDepositMode()
    StopPoolPlacementMode()
    StopWinonaPlacementMode()
    StopWaxwellMagicChestPlacementMode()
    StopEquipBackpackMode()
    _ocean_fish_deposit_state.active = true
    _ocean_fish_deposit_state.owner_param = owner_param

    _ocean_fish_deposit_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _ocean_fish_deposit_state.active then return end
        local preview = EnsureOceanFishDepositPreview()
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end
        preview.Transform:SetPosition(wx, 0, wz)

        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local valid = ((wx - px) * (wx - px) + (wz - pz) * (wz - pz)) <= OCEAN_FISH_DEPOSIT_MAX_DIST_SQ
        _ocean_fish_deposit_state.can_place = valid
        _ocean_fish_deposit_state.x, _ocean_fish_deposit_state.z = wx, wz
        if valid then
            preview.AnimState:SetMultColour(0.6, 1.0, 0.6, 0.8)
        else
            preview.AnimState:SetMultColour(1.0, 0.4, 0.4, 0.7)
        end
    end)
end

--------------------------------------------------------------------------
-- 植物人作物存放点放置模式
--------------------------------------------------------------------------

local _wormwood_crop_deposit_state = {
    active = false,
    owner_param = nil,
    follow_task = nil,
    preview = nil,
    can_place = false,
    x = nil,
    z = nil,
}

local WORMWOOD_CROP_DEPOSIT_RADIUS = _GetTuning("WORMWOOD_CROP_DEPOSIT_RADIUS", 12)
local WORMWOOD_CROP_DEPOSIT_MAX_DIST = 40
local WORMWOOD_CROP_DEPOSIT_MAX_DIST_SQ = WORMWOOD_CROP_DEPOSIT_MAX_DIST * WORMWOOD_CROP_DEPOSIT_MAX_DIST

StopWormwoodCropDepositMode = function()
    _wormwood_crop_deposit_state.active = false
    _wormwood_crop_deposit_state.owner_param = nil
    _wormwood_crop_deposit_state.can_place = false
    _wormwood_crop_deposit_state.x, _wormwood_crop_deposit_state.z = nil, nil
    if _wormwood_crop_deposit_state.follow_task then
        _wormwood_crop_deposit_state.follow_task:Cancel()
        _wormwood_crop_deposit_state.follow_task = nil
    end
    if _wormwood_crop_deposit_state.preview and _wormwood_crop_deposit_state.preview:IsValid() then
        _wormwood_crop_deposit_state.preview:Remove()
    end
    _wormwood_crop_deposit_state.preview = nil
end

local function EnsureWormwoodCropDepositPreview()
    if _wormwood_crop_deposit_state.preview and _wormwood_crop_deposit_state.preview:IsValid() then
        return _wormwood_crop_deposit_state.preview
    end
    local inst = _G.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")
    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("inner")
    inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(1)
    local s = WORMWOOD_CROP_DEPOSIT_RADIUS / 9.7
    inst.AnimState:SetScale(s, s, s)
    _wormwood_crop_deposit_state.preview = inst
    return inst
end

local function StartWormwoodCropDepositMode(owner_param)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    StopWormwoodCropDepositMode()
    StopWormwoodTrashDepositMode()
    StopFishDepositMode()
    StopOceanFishDepositMode()
    StopPoolPlacementMode()
    StopWinonaPlacementMode()
    StopWaxwellMagicChestPlacementMode()
    StopEquipBackpackMode()
    _wormwood_crop_deposit_state.active = true
    _wormwood_crop_deposit_state.owner_param = owner_param

    _wormwood_crop_deposit_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _wormwood_crop_deposit_state.active then return end
        local preview = EnsureWormwoodCropDepositPreview()
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end
        preview.Transform:SetPosition(wx, 0, wz)

        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local valid = ((wx - px) * (wx - px) + (wz - pz) * (wz - pz)) <= WORMWOOD_CROP_DEPOSIT_MAX_DIST_SQ
        _wormwood_crop_deposit_state.can_place = valid
        _wormwood_crop_deposit_state.x, _wormwood_crop_deposit_state.z = wx, wz
        if valid then
            preview.AnimState:SetMultColour(0.6, 1.0, 0.6, 0.8)
        else
            preview.AnimState:SetMultColour(1.0, 0.4, 0.4, 0.7)
        end
    end)
end

--------------------------------------------------------------------------
-- 植物人垃圾存放点放置模式
--------------------------------------------------------------------------

local _wormwood_trash_deposit_state = {
    active = false,
    owner_param = nil,
    follow_task = nil,
    preview = nil,
    can_place = false,
    x = nil,
    z = nil,
}

local WORMWOOD_TRASH_DEPOSIT_RADIUS = _GetTuning("WORMWOOD_TRASH_DEPOSIT_RADIUS", 12)
local WORMWOOD_TRASH_DEPOSIT_MAX_DIST = 40
local WORMWOOD_TRASH_DEPOSIT_MAX_DIST_SQ = WORMWOOD_TRASH_DEPOSIT_MAX_DIST * WORMWOOD_TRASH_DEPOSIT_MAX_DIST

StopWormwoodTrashDepositMode = function()
    _wormwood_trash_deposit_state.active = false
    _wormwood_trash_deposit_state.owner_param = nil
    _wormwood_trash_deposit_state.can_place = false
    _wormwood_trash_deposit_state.x, _wormwood_trash_deposit_state.z = nil, nil
    if _wormwood_trash_deposit_state.follow_task then
        _wormwood_trash_deposit_state.follow_task:Cancel()
        _wormwood_trash_deposit_state.follow_task = nil
    end
    if _wormwood_trash_deposit_state.preview and _wormwood_trash_deposit_state.preview:IsValid() then
        _wormwood_trash_deposit_state.preview:Remove()
    end
    _wormwood_trash_deposit_state.preview = nil
end

local function EnsureWormwoodTrashDepositPreview()
    if _wormwood_trash_deposit_state.preview and _wormwood_trash_deposit_state.preview:IsValid() then
        return _wormwood_trash_deposit_state.preview
    end
    local inst = _G.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")
    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("inner")
    inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(1)
    local s = WORMWOOD_TRASH_DEPOSIT_RADIUS / 9.7
    inst.AnimState:SetScale(s, s, s)
    _wormwood_trash_deposit_state.preview = inst
    return inst
end

local function StartWormwoodTrashDepositMode(owner_param)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    StopWormwoodTrashDepositMode()
    StopWormwoodCropDepositMode()
    StopFishDepositMode()
    StopOceanFishDepositMode()
    StopPoolPlacementMode()
    StopWinonaPlacementMode()
    StopWaxwellMagicChestPlacementMode()
    StopEquipBackpackMode()
    _wormwood_trash_deposit_state.active = true
    _wormwood_trash_deposit_state.owner_param = owner_param

    _wormwood_trash_deposit_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _wormwood_trash_deposit_state.active then return end
        local preview = EnsureWormwoodTrashDepositPreview()
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end
        preview.Transform:SetPosition(wx, 0, wz)

        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local valid = ((wx - px) * (wx - px) + (wz - pz) * (wz - pz)) <= WORMWOOD_TRASH_DEPOSIT_MAX_DIST_SQ
        _wormwood_trash_deposit_state.can_place = valid
        _wormwood_trash_deposit_state.x, _wormwood_trash_deposit_state.z = wx, wz
        if valid then
            preview.AnimState:SetMultColour(0.6, 1.0, 0.6, 0.8)
        else
            preview.AnimState:SetMultColour(1.0, 0.4, 0.4, 0.7)
        end
    end)
end

--------------------------------------------------------------------------
-- 薇诺娜设备放置模式（宝石发电机 / 聚光灯 / 投石机）
--------------------------------------------------------------------------

local WINONA_DEVICE_CONFIGS = {
    generator = {
        bank  = "winona_battery_placement",
        build = "winona_battery_placement",
        idle  = "idle",
        prefab = "winona_battery_high",
    },
    spotlight = {
        bank  = "winona_spotlight_placement",
        build = "winona_spotlight_placement",
        idle  = "idle",
        prefab = "winona_spotlight",
    },
    catapult = {
        bank  = "winona_catapult_placement",
        build = "winona_catapult_placement",
        idle  = "idle_15",
        prefab = "winona_catapult",
    },
}

-- 每种设备的多层预览视觉（地面范围环 + 建筑阴影）
local WINONA_PREVIEW_LAYERS = {
    generator = {
        { bank = "winona_battery_placement", build = "winona_battery_placement", anim = "idle",        ground = true  },
        { bank = "winona_battery_high",      build = "winona_battery_high",      anim = "idle_placer", ground = false },
    },
    spotlight = {
        { bank = "winona_battery_placement",   build = "winona_battery_placement",   anim = "idle_small",  ground = true  },
        { bank = "winona_spotlight_placement", build = "winona_spotlight_placement", anim = "idle",        ground = true  },
        { bank = "winona_spotlight",           build = "winona_spotlight",           anim = "idle_placer", ground = false },
    },
    catapult = {
        { bank = "winona_catapult_placement", build = "winona_catapult_placement", anim = "idle_15",     ground = true  },
        { bank = "winona_battery_placement",  build = "winona_battery_placement",  anim = "idle_small",  ground = true  },
        { bank = "winona_catapult",           build = "winona_catapult",           anim = "idle_placer", ground = false },
    },
}

local _winona_place_state = {
    active      = false,
    device_type = nil,
    owner_param = nil,
    previews    = {},
    follow_task = nil,
    can_place   = false,
    x = nil,
    z = nil,
}


StopWinonaPlacementMode = function()
    _winona_place_state.active      = false
    _winona_place_state.device_type = nil
    _winona_place_state.owner_param = nil
    _winona_place_state.can_place   = false
    _winona_place_state.x, _winona_place_state.z = nil, nil
    if _winona_place_state.follow_task then
        _winona_place_state.follow_task:Cancel()
        _winona_place_state.follow_task = nil
    end
    for _, prev in ipairs(_winona_place_state.previews or {}) do
        if prev and prev:IsValid() then prev:Remove() end
    end
    _winona_place_state.previews = {}
end

local function EnsureWinonaPreviewAll(device_type)
    local layers = WINONA_PREVIEW_LAYERS[device_type]
    if not layers then return end
    local previews = _winona_place_state.previews
    if previews and #previews > 0 then
        local all_valid = true
        for _, prev in ipairs(previews) do
            if not prev or not prev:IsValid() then all_valid = false; break end
        end
        if all_valid then return end
    end
    for _, prev in ipairs(_winona_place_state.previews or {}) do
        if prev and prev:IsValid() then prev:Remove() end
    end
    _winona_place_state.previews = {}
    for _, layer in ipairs(layers) do
        local inst = _G.CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:SetCanSleep(false)
        inst.persists = false
        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst:AddTag("CLASSIFIED")
        inst.AnimState:SetBank(layer.bank)
        inst.AnimState:SetBuild(layer.build)
        inst.AnimState:PlayAnimation(layer.anim, true)
        if layer.ground then
            inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
            inst.AnimState:SetSortOrder(3)
        end
        inst.AnimState:SetLightOverride(1)
        table.insert(_winona_place_state.previews, inst)
    end
end

-- 各设备的物理碰撞半径
local WINONA_DEVICE_PHYSICS_RADIUS = {
    generator = 2,  -- winona_battery_high
    spotlight  = 2,  -- winona_spotlight
    catapult   = 2,  -- winona_catapult
}

function UiModes.IsValidWinonaPlacementAt(x, z, device_type)
    if not (_G.TheWorld and _G.TheWorld.Map) then return false end
    local map = _G.TheWorld.Map
    if not map:IsPassableAtPoint(x, 0, z) then return false end
    if map:IsOceanAtPoint(x, 0, z, false) then return false end
    if _G.TheSim then
        local radius = (WINONA_DEVICE_PHYSICS_RADIUS[device_type] or 0.5) + 0.1
        local ents = _G.TheSim:FindEntities(x, 0, z, radius, nil,
            { "INLIMBO", "FX", "NOCLICK", "player", "playerghost",
              "creature", "monster", "smallcreature", "flying" })
        for _, ent in ipairs(ents) do
            if ent.Physics and (
                ent:HasTag("structure") or ent:HasTag("obstacle") or
                ent:HasTag("wall")      or ent:HasTag("boulder")  or
                ent:HasTag("tree")) then
                return false
            end
        end
    end
    return true
end

local _waxwell_magic_chest_state = {
    active = false,
    owner_param = nil,
    preview = nil,
    follow_task = nil,
    can_place = false,
    x = nil,
    z = nil,
}

StopWaxwellMagicChestPlacementMode = function()
    _waxwell_magic_chest_state.active = false
    _waxwell_magic_chest_state.owner_param = nil
    _waxwell_magic_chest_state.can_place = false
    _waxwell_magic_chest_state.x, _waxwell_magic_chest_state.z = nil, nil
    if _waxwell_magic_chest_state.follow_task then
        _waxwell_magic_chest_state.follow_task:Cancel()
        _waxwell_magic_chest_state.follow_task = nil
    end
    if _waxwell_magic_chest_state.preview and _waxwell_magic_chest_state.preview:IsValid() then
        _waxwell_magic_chest_state.preview:Remove()
    end
    _waxwell_magic_chest_state.preview = nil
end

local function EnsureWaxwellMagicChestPreview()
    local prev = _waxwell_magic_chest_state.preview
    if prev and prev:IsValid() then return prev end
    prev = _G.CreateEntity()
    prev.entity:AddTransform()
    prev.entity:AddAnimState()
    prev.entity:SetCanSleep(false)
    prev.persists = false
    prev:AddTag("FX")
    prev:AddTag("NOCLICK")
    prev:AddTag("CLASSIFIED")
    prev.AnimState:SetBank("magician_chest")
    prev.AnimState:SetBuild("magician_chest")
    prev.AnimState:PlayAnimation("closed")
    prev.AnimState:SetLightOverride(1)
    _waxwell_magic_chest_state.preview = prev
    return prev
end

function UiModes.IsValidWaxwellMagicChestPlacementAt(x, z)
    if not (_G.TheWorld and _G.TheWorld.Map) then return false end
    local map = _G.TheWorld.Map
    if not map:IsPassableAtPoint(x, 0, z) then return false end
    if map:IsOceanAtPoint(x, 0, z, true) then return false end
    if map.IsPointNearHole and map:IsPointNearHole(_G.Vector3(x, 0, z)) then return false end
    if _G.TheSim then
        local radius = 0.75
        local ents = _G.TheSim:FindEntities(x, 0, z, radius, nil,
            { "INLIMBO", "FX", "NOCLICK", "player", "playerghost",
              "creature", "monster", "smallcreature", "flying" })
        for _, ent in ipairs(ents) do
            if ent.Physics and (
                ent:HasTag("structure") or ent:HasTag("obstacle") or
                ent:HasTag("wall")      or ent:HasTag("boulder")  or
                ent:HasTag("tree")) then
                return false
            end
        end
    end
    return true
end

local function StartWinonaPlacementMode(owner_param, device_type)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    if not WINONA_PREVIEW_LAYERS[device_type] then return end
    StopWinonaPlacementMode()
    StopFishDepositMode()
    StopOceanFishDepositMode()
    StopWormwoodCropDepositMode()
    StopWormwoodTrashDepositMode()
    StopWaxwellMagicChestPlacementMode()
    StopEquipBackpackMode()
    _winona_place_state.active      = true
    _winona_place_state.device_type = device_type
    _winona_place_state.owner_param = owner_param
    local max_dist_sq = _GetTuning("WINONA_BUILD_PLACE_MAX_DIST", 30) ^ 2
    _winona_place_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _winona_place_state.active then return end
        EnsureWinonaPreviewAll(device_type)
        local previews = _winona_place_state.previews
        if not previews or #previews == 0 then return end
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end
        for _, prev in ipairs(previews) do
            if prev and prev:IsValid() then
                prev.Transform:SetPosition(wx, 0, wz)
            end
        end
        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local in_dist = ((wx - px) ^ 2 + (wz - pz) ^ 2) <= max_dist_sq
        local valid = in_dist and UiModes.IsValidWinonaPlacementAt(wx, wz, device_type)
        _winona_place_state.can_place = valid
        _winona_place_state.x, _winona_place_state.z = wx, wz
        local r = valid and 0.6 or 1.0
        local g = valid and 1.0 or 0.4
        local b = valid and 0.6 or 0.4
        local a = valid and 0.8 or 0.7
        for _, prev in ipairs(previews) do
            if prev and prev:IsValid() then
                prev.AnimState:SetMultColour(r, g, b, a)
            end
        end
    end)
end

local function StartWaxwellMagicChestPlacementMode(owner_param)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    StopWinonaPlacementMode()
    StopFishDepositMode()
    StopOceanFishDepositMode()
    StopWormwoodCropDepositMode()
    StopWormwoodTrashDepositMode()
    StopWaxwellMagicChestPlacementMode()
    StopEquipBackpackMode()

    _waxwell_magic_chest_state.active = true
    _waxwell_magic_chest_state.owner_param = owner_param
    local max_dist_sq = _GetTuning("WAXWELL_MAGIC_CHEST_MAX_DIST", 30) ^ 2
    _waxwell_magic_chest_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _waxwell_magic_chest_state.active then return end
        local prev = EnsureWaxwellMagicChestPreview()
        if not (prev and prev:IsValid()) then return end
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end
        prev.Transform:SetPosition(wx, 0, wz)

        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local in_dist = ((wx - px) ^ 2 + (wz - pz) ^ 2) <= max_dist_sq
        local valid = in_dist and UiModes.IsValidWaxwellMagicChestPlacementAt(wx, wz)
        _waxwell_magic_chest_state.can_place = valid
        _waxwell_magic_chest_state.x, _waxwell_magic_chest_state.z = wx, wz
        prev.AnimState:SetMultColour(valid and 0.6 or 1.0, valid and 1.0 or 0.4, valid and 0.6 or 0.4, valid and 0.8 or 0.7)
    end)
end

--------------------------------------------------------------------------
-- 装备背包圈选模式（任意 NPC）：在地面圈选范围内拾取背包并装备
--------------------------------------------------------------------------

local _equip_backpack_state = {
    active = false,
    owner_param = nil,
    follow_task = nil,
    preview = nil,
    can_place = false,
    x = nil,
    z = nil,
}

local EQUIP_BACKPACK_RADIUS = _GetTuning("EQUIP_BACKPACK_PICKUP_RADIUS", 2)
local EQUIP_BACKPACK_MAX_DIST = 40
local EQUIP_BACKPACK_MAX_DIST_SQ = EQUIP_BACKPACK_MAX_DIST * EQUIP_BACKPACK_MAX_DIST
-- 多层同心圆环：外圈半径仍是 2 格，往内叠几层让虚线看起来更粗
local EQUIP_BACKPACK_RING_SCALES = { 1.0, 0.95, 0.90 }

StopEquipBackpackMode = function()
    _equip_backpack_state.active = false
    _equip_backpack_state.owner_param = nil
    _equip_backpack_state.can_place = false
    _equip_backpack_state.x, _equip_backpack_state.z = nil, nil
    if _equip_backpack_state.follow_task then
        _equip_backpack_state.follow_task:Cancel()
        _equip_backpack_state.follow_task = nil
    end
    if _equip_backpack_state.previews then
        for _, p in ipairs(_equip_backpack_state.previews) do
            if p and p:IsValid() then p:Remove() end
        end
    end
    _equip_backpack_state.previews = nil
    _equip_backpack_state.preview = nil
end

local function MakeEquipBackpackRing(scale_mult)
    local inst = _G.CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("CLASSIFIED")
    inst.AnimState:SetBank("winona_catapult_placement")
    inst.AnimState:SetBuild("winona_catapult_placement")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("inner")  -- 与其它模式一致：隐藏内圈，否则会多出一个大圆
    inst.AnimState:SetOrientation(_G.ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(_G.LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetLightOverride(1)
    -- idle 动画对应半径约 9.7 格，缩放到 EQUIP_BACKPACK_RADIUS
    local s = (EQUIP_BACKPACK_RADIUS / 9.7) * scale_mult
    inst.AnimState:SetScale(s, s, s)
    return inst
end

local function EnsureEquipBackpackPreview()
    local list = _equip_backpack_state.previews
    if list and list[1] and list[1]:IsValid() then
        return list
    end
    list = {}
    for _, m in ipairs(EQUIP_BACKPACK_RING_SCALES) do
        list[#list + 1] = MakeEquipBackpackRing(m)
    end
    _equip_backpack_state.previews = list
    _equip_backpack_state.preview = list[1]
    return list
end

local function StartEquipBackpackMode(owner_param)
    if not (_G.TheInput and _G.ThePlayer and _G.ThePlayer.HUD) then return end
    StopEquipBackpackMode()
    StopFishDepositMode()
    StopOceanFishDepositMode()
    StopWormwoodCropDepositMode()
    StopWormwoodTrashDepositMode()
    StopPoolPlacementMode()
    StopWinonaPlacementMode()
    StopWaxwellMagicChestPlacementMode()
    _equip_backpack_state.active = true
    _equip_backpack_state.owner_param = owner_param

    _equip_backpack_state.follow_task = _G.ThePlayer:DoPeriodicTask(0.03, function()
        if not _equip_backpack_state.active then return end
        local previews = EnsureEquipBackpackPreview()
        local wx, _, wz = _G.TheInput:GetWorldPosition():Get()
        if wx == nil or wz == nil then return end

        local px, _, pz = _G.ThePlayer.Transform:GetWorldPosition()
        local valid = ((wx - px) * (wx - px) + (wz - pz) * (wz - pz)) <= EQUIP_BACKPACK_MAX_DIST_SQ
        _equip_backpack_state.can_place = valid
        _equip_backpack_state.x, _equip_backpack_state.z = wx, wz
        for _, preview in ipairs(previews) do
            preview.Transform:SetPosition(wx, 0, wz)
            if valid then
                preview.AnimState:SetMultColour(0.3, 1.0, 0.3, 1.0)
                preview.AnimState:SetAddColour(0, 0.35, 0, 0)
            else
                preview.AnimState:SetMultColour(1.0, 0.25, 0.25, 1.0)
                preview.AnimState:SetAddColour(0.35, 0, 0, 0)
            end
        end
    end)
end

--------------------------------------------------------------------------
-- 初始化：注册客户端 RPC、鼠标事件、OnControl 拦截
-- 由 modmain 调用，传入 mod 环境中的注册函数
--------------------------------------------------------------------------

function UiModes.Init(env)
    InstallNPCLocationMapOverlay(env)

    if env.AddClientModRPCHandler ~= nil then
        env.AddClientModRPCHandler("NPCFriends", "StartPoolPlacement", function(owner_param)
            StartPoolPlacementMode(owner_param)
        end)
        env.AddClientModRPCHandler("NPCFriends", "StartWinonaPlacement", function(payload)
            -- payload = "owner_param|device_type"
            local sep = string.find(payload or "", "|", 1, true)
            if not sep then return end
            local op = string.sub(payload, 1, sep - 1)
            local dt = string.sub(payload, sep + 1)
            StartWinonaPlacementMode(op, dt)
        end)
        env.AddClientModRPCHandler("NPCFriends", "StartWaxwellMagicChestPlacement", function(owner_param)
            StartWaxwellMagicChestPlacementMode(owner_param)
        end)
        env.AddClientModRPCHandler("NPCFriends", "ShowNPCLocations", function(payload)
            ShowNPCLocationMarkers(payload)
        end)
        env.AddClientModRPCHandler("NPCFriends", "ReceiveRiftList", function(payload)
            if not (_G.ThePlayer and _G.ThePlayer.HUD) then
                return
            end
            local p1 = string.find(payload or "", "|", 1, true)
            if p1 == nil then
                return
            end
            local source_guid = string.sub(payload, 1, p1 - 1)
            local list_payload = string.sub(payload, p1 + 1)
            if _G.ThePlayer.HUD.ShowNPCRiftTravelScreen ~= nil then
                _G.ThePlayer.HUD:ShowNPCRiftTravelScreen(source_guid, list_payload)
            end
        end)
        env.AddClientModRPCHandler("NPCFriends", "ShowQuestScreen", function(payload)
            if not (_G.ThePlayer and _G.ThePlayer.HUD) then return end
            if _G.ThePlayer.HUD.ShowNPCQuestScreen ~= nil then
                _G.ThePlayer.HUD:ShowNPCQuestScreen(payload)
            end
        end)
        env.AddClientModRPCHandler("NPCFriends", "ReceiveQuestDetail", function(payload)
            if not (_G.ThePlayer and _G.ThePlayer.HUD) then return end
            if _G.ThePlayer.HUD._npc_quest_screen ~= nil then
                _G.ThePlayer.HUD._npc_quest_screen:ReceiveDetail(payload)
            end
        end)
        env.AddClientModRPCHandler("NPCFriends", "RefreshQuestScreen", function(payload)
            if not (_G.ThePlayer and _G.ThePlayer.HUD) then return end
            if _G.ThePlayer.HUD._npc_quest_screen ~= nil then
                _G.ThePlayer.HUD._npc_quest_screen:Refresh(payload)
            end
        end)
    end

    -- 鼠标事件：池塘放置模式
    if _G.TheInput then
        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _pool_place_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopPoolPlacementMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _pool_place_state.can_place and _pool_place_state.owner_param and _pool_place_state.x and _pool_place_state.z then
                    local payload = string.format("%s|%.2f|%.2f", _pool_place_state.owner_param, _pool_place_state.x, _pool_place_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "PlacePoolAt"), payload)
                    end)
                    StopPoolPlacementMode()
                    return true
                end
                return true
            end
            return false
        end)

        -- 鼠标事件：钓鱼存放点放置模式
        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _fish_deposit_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopFishDepositMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _fish_deposit_state.can_place and _fish_deposit_state.owner_param and _fish_deposit_state.x and _fish_deposit_state.z then
                    local payload = string.format("%s|%.2f|%.2f", _fish_deposit_state.owner_param, _fish_deposit_state.x, _fish_deposit_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "SetFishDepositPoint"), payload)
                    end)
                    StopFishDepositMode()
                    return true
                end
                return true
            end
            return false
        end)

        -- 鼠标事件：海钓存放点放置模式
        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _ocean_fish_deposit_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopOceanFishDepositMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _ocean_fish_deposit_state.can_place and _ocean_fish_deposit_state.owner_param and _ocean_fish_deposit_state.x and _ocean_fish_deposit_state.z then
                    local payload = string.format("%s|%.2f|%.2f", _ocean_fish_deposit_state.owner_param, _ocean_fish_deposit_state.x, _ocean_fish_deposit_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "SetOceanFishDepositPos"), payload)
                    end)
                    StopOceanFishDepositMode()
                    return true
                end
                return true
            end
            return false
        end)

        -- 鼠标事件：植物人作物存放点放置模式
        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _wormwood_crop_deposit_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopWormwoodCropDepositMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _wormwood_crop_deposit_state.can_place and _wormwood_crop_deposit_state.owner_param and _wormwood_crop_deposit_state.x and _wormwood_crop_deposit_state.z then
                    local payload = string.format("%s|%.2f|%.2f", _wormwood_crop_deposit_state.owner_param, _wormwood_crop_deposit_state.x, _wormwood_crop_deposit_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "SetWormwoodCropDepositPos"), payload)
                    end)
                    StopWormwoodCropDepositMode()
                    return true
                end
                return true
            end
            return false
        end)

        -- 鼠标事件：植物人垃圾存放点放置模式
        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _wormwood_trash_deposit_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopWormwoodTrashDepositMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _wormwood_trash_deposit_state.can_place and _wormwood_trash_deposit_state.owner_param and _wormwood_trash_deposit_state.x and _wormwood_trash_deposit_state.z then
                    local payload = string.format("%s|%.2f|%.2f", _wormwood_trash_deposit_state.owner_param, _wormwood_trash_deposit_state.x, _wormwood_trash_deposit_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "SetWormwoodTrashDepositPos"), payload)
                    end)
                    StopWormwoodTrashDepositMode()
                    return true
                end
                return true
            end
            return false
        end)

        -- 鼠标事件：薇诺娜设备放置模式
        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _winona_place_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopWinonaPlacementMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _winona_place_state.can_place
                   and _winona_place_state.owner_param
                   and _winona_place_state.device_type
                   and _winona_place_state.x and _winona_place_state.z then
                    local payload = string.format("%s|%s|%.2f|%.2f",
                        _winona_place_state.owner_param,
                        _winona_place_state.device_type,
                        _winona_place_state.x,
                        _winona_place_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "PlaceWinonaDevice"), payload)
                    end)
                    StopWinonaPlacementMode()
                    return true
                end
                return true
            end
            return false
        end)

        -- 鼠标事件：麦斯威尔 NPC 魔术箱放置模式
        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _waxwell_magic_chest_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopWaxwellMagicChestPlacementMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _waxwell_magic_chest_state.can_place
                   and _waxwell_magic_chest_state.owner_param
                   and _waxwell_magic_chest_state.x and _waxwell_magic_chest_state.z then
                    local payload = string.format("%s|%.2f|%.2f",
                        _waxwell_magic_chest_state.owner_param,
                        _waxwell_magic_chest_state.x,
                        _waxwell_magic_chest_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "PlaceWaxwellMagicChest"), payload)
                    end)
                    StopWaxwellMagicChestPlacementMode()
                    return true
                end
                return true
            end
            return false
        end)

        _G.TheInput:AddMouseButtonHandler(function(button, down, x, y)
            if not _equip_backpack_state.active or not down then return false end
            if button == _G.MOUSEBUTTON_RIGHT then
                StopEquipBackpackMode()
                return true
            end
            if button == _G.MOUSEBUTTON_LEFT then
                if _equip_backpack_state.can_place and _equip_backpack_state.owner_param
                   and _equip_backpack_state.x and _equip_backpack_state.z then
                    local payload = string.format("%s|%.2f|%.2f",
                        _equip_backpack_state.owner_param,
                        _equip_backpack_state.x,
                        _equip_backpack_state.z)
                    _G.pcall(function()
                        env.SendModRPCToServer(env.GetModRPC("NPCFriends", "EquipBackpackAt"), payload)
                    end)
                    StopEquipBackpackMode()
                    return true
                end
                return true
            end
            return false
        end)

        local _orig_input_OnControl = _G.TheInput.OnControl
        _G.TheInput.OnControl = function(self, control, digitalvalue, analogvalue)
            if control == 0 --[[CONTROL_PRIMARY]] and digitalvalue ~= 0
               and (_winona_place_state.active or _pool_place_state.active
                    or _fish_deposit_state.active or _ocean_fish_deposit_state.active
                    or _wormwood_crop_deposit_state.active or _wormwood_trash_deposit_state.active
                    or _waxwell_magic_chest_state.active or _equip_backpack_state.active) then
                return
            end
            return _orig_input_OnControl(self, control, digitalvalue, analogvalue)
        end
    end
end

UiModes.StartFishDepositMode = StartFishDepositMode
UiModes.StopFishDepositMode = StopFishDepositMode
UiModes.StartOceanFishDepositMode = StartOceanFishDepositMode
UiModes.StopOceanFishDepositMode = StopOceanFishDepositMode
UiModes.StartWormwoodCropDepositMode = StartWormwoodCropDepositMode
UiModes.StopWormwoodCropDepositMode = StopWormwoodCropDepositMode
UiModes.StartWormwoodTrashDepositMode = StartWormwoodTrashDepositMode
UiModes.StopWormwoodTrashDepositMode = StopWormwoodTrashDepositMode
UiModes.StartWaxwellMagicChestPlacementMode = StartWaxwellMagicChestPlacementMode
UiModes.StopWaxwellMagicChestPlacementMode = StopWaxwellMagicChestPlacementMode
UiModes.StartEquipBackpackMode = StartEquipBackpackMode
UiModes.StopEquipBackpackMode = StopEquipBackpackMode

return UiModes
