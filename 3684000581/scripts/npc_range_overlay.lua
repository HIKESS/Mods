-- scripts/npc_range_overlay.lua

local M = {}

local DEFAULT_ALPHA = 0.85
local SCALE_BASE_RADIUS = 9.7

local state = {
    circles = {},
    tasks = {},
    hide_tasks = {},
}

local function GetColor(name)
    if name == "blue" then
        return 0.25, 0.55, 1.0
    elseif name == "red" then
        return 0.95, 0.2, 0.2
    elseif name == "yellow" then
        return 1.0, 0.85, 0.2
    end
    return 0.2, 0.9, 0.2
end

local function ApplyCircleVisual(circle, radius, color_name, alpha)
    local anim = circle ~= nil and circle.AnimState or nil
    if anim == nil then return end
    local r, g, b = GetColor(color_name)
    anim:SetScale(radius / SCALE_BASE_RADIUS, radius / SCALE_BASE_RADIUS)
    anim:SetMultColour(r, g, b, alpha or DEFAULT_ALPHA)
    anim:SetAddColour(r, g, b, 0)
end

local function CreateCircle(x, z, radius, color_name, alpha)
    if not (x ~= nil and z ~= nil and radius ~= nil and radius > 0) then
        return nil
    end

    local circle = CreateEntity()
    circle.entity:AddTransform()
    circle.entity:AddAnimState()
    circle.entity:SetCanSleep(false)
    circle.persists = false
    circle:AddTag("FX")
    circle:AddTag("NOCLICK")
    circle:AddTag("CLASSIFIED")
    circle:AddTag("RANGE_INDICATOR")

    circle.Transform:SetPosition(x, 0, z)
    circle.AnimState:SetBank("winona_catapult_placement")
    circle.AnimState:SetBuild("winona_catapult_placement")
    circle.AnimState:PlayAnimation("idle")
    circle.AnimState:Hide("inner")
    circle.AnimState:SetLightOverride(1)
    circle.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    circle.AnimState:SetLayer(LAYER_BACKGROUND)
    circle.AnimState:SetSortOrder(1)
    ApplyCircleVisual(circle, radius, color_name, alpha)
    return circle
end

function M.Hide(key)
    if key == nil then return end
    local task = state.tasks[key]
    if task ~= nil then
        task:Cancel()
        state.tasks[key] = nil
    end
    local hide_task = state.hide_tasks[key]
    if hide_task ~= nil then
        hide_task:Cancel()
        state.hide_tasks[key] = nil
    end
    local circle = state.circles[key]
    if circle ~= nil and circle:IsValid() then
        circle:Remove()
    end
    state.circles[key] = nil
end

function M.Show(key, x, z, radius, color_name, alpha)
    if key == nil then return end
    if not (x ~= nil and z ~= nil and radius ~= nil and radius > 0) then
        M.Hide(key)
        return
    end

    local circle = state.circles[key]
    if circle ~= nil and circle:IsValid() then
        circle.Transform:SetPosition(x, 0, z)
        ApplyCircleVisual(circle, radius, color_name, alpha)
        return circle
    end

    circle = CreateCircle(x, z, radius, color_name, alpha)
    state.circles[key] = circle
    return circle
end

function M.ShowAroundPlayer(key, radius, duration, color_name, alpha)
    local player = ThePlayer
    if player == nil or not player:IsValid() then
        return
    end

    key = key or "npcfriends_player_range"
    duration = duration or 3
    color_name = color_name or "blue"

    local old_task = state.tasks[key]
    if old_task ~= nil then
        old_task:Cancel()
        state.tasks[key] = nil
    end
    local old_hide_task = state.hide_tasks[key]
    if old_hide_task ~= nil then
        old_hide_task:Cancel()
        state.hide_tasks[key] = nil
    end

    local function UpdatePosition()
        local p = ThePlayer
        if p == nil or not p:IsValid() then
            M.Hide(key)
            return
        end
        local x, _, z = p.Transform:GetWorldPosition()
        M.Show(key, x, z, radius, color_name, alpha)
    end

    UpdatePosition()
    state.tasks[key] = player:DoPeriodicTask(0.1, UpdatePosition)
    state.hide_tasks[key] = player:DoTaskInTime(duration, function()
        state.hide_tasks[key] = nil
        M.Hide(key)
    end)
end

local function FindNearestNPC(must_have_tag)
    local player = ThePlayer
    if player == nil or not player:IsValid() or TheSim == nil then
        return nil
    end
    local x, y, z = player.Transform:GetWorldPosition()
    local must_tags = must_have_tag ~= nil and { "npcfriend", must_have_tag } or { "npcfriend" }
    local ents = TheSim:FindEntities(x, y, z, 80, must_tags, { "INLIMBO" })
    local best_owned, best_owned_dsq = nil, math.huge
    local best_any, best_any_dsq = nil, math.huge
    for _, ent in ipairs(ents) do
        if ent ~= nil and ent:IsValid() then
            local dsq = player:GetDistanceSqToInst(ent)
            local owner_userid = ent.owner_userid ~= nil and ent.owner_userid:value() or nil
            local follower = ent.components ~= nil and ent.components.follower or nil
            local leader = follower ~= nil and follower.leader or nil
            local is_owned = (owner_userid ~= nil and owner_userid ~= "" and owner_userid == player.userid)
                or leader == player
            if is_owned and dsq < best_owned_dsq then
                best_owned = ent
                best_owned_dsq = dsq
            end
            if dsq < best_any_dsq then
                best_any = ent
                best_any_dsq = dsq
            end
        end
    end
    return best_owned or best_any
end

function M.ShowAroundNearestGhostNPC(key, radius, duration, color_name, alpha)
    local player = ThePlayer
    if player == nil or not player:IsValid() then
        return
    end

    key = key or "npcfriends_ghost_npc_range"
    duration = duration or 3
    color_name = color_name or "yellow"

    local old_task = state.tasks[key]
    if old_task ~= nil then
        old_task:Cancel()
        state.tasks[key] = nil
    end
    local old_hide_task = state.hide_tasks[key]
    if old_hide_task ~= nil then
        old_hide_task:Cancel()
        state.hide_tasks[key] = nil
    end

    local function UpdatePosition()
        local npc = FindNearestNPC("ghost") or FindNearestNPC(nil)
        if npc == nil then
            M.Hide(key)
            return
        end
        local x, _, z = npc.Transform:GetWorldPosition()
        M.Show(key, x, z, radius, color_name, alpha)
    end

    UpdatePosition()
    state.tasks[key] = player:DoPeriodicTask(0.1, UpdatePosition)
    state.hide_tasks[key] = player:DoTaskInTime(duration, function()
        state.hide_tasks[key] = nil
        M.Hide(key)
    end)
end

return M
