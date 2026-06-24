-- ========== NPC 工作范围虚线渲染==========

local G = GLOBAL
local DEFAULT_ALPHA = 1

DSTADMIN_RANGE_OVERLAY = DSTADMIN_RANGE_OVERLAY or {
    circles = {}, -- key -> entity
}

local function _GetColor(name)
    if name == "green" then
        return 0.2, 0.9, 0.2
    elseif name == "red" then
        return 0.95, 0.2, 0.2
    end
    return 0.2, 0.9, 0.2
end

local function _CreateCircleAt(x, z, radius, color_name, alpha)
    if not (x and z and radius and radius > 0) then return nil end
    local circle = G.CreateEntity()
    local tf = circle.entity:AddTransform()
    local as = circle.entity:AddAnimState()

    tf:SetPosition(x, 0, z)
    as:SetScale(radius / 9.7, radius / 9.7)

    local r, g, b = _GetColor(color_name)
    local a = alpha or DEFAULT_ALPHA
    as:SetMultColour(r, g, b, a)
    as:SetAddColour(r, g, b, 0)

    circle.entity:SetCanSleep(false)
    circle.persists = false
    circle:AddTag("CLASSIFIED")
    circle:AddTag("NOCLICK")
    circle:AddTag("RANGE_INDICATOR")
    as:SetBank("winona_catapult_placement")
    as:SetBuild("winona_catapult_placement")
    as:PlayAnimation("idle")
    as:Hide("inner")
    as:SetLightOverride(1)
    as:SetOrientation(G.ANIM_ORIENTATION.OnGround)
    as:SetLayer(G.LAYER_BACKGROUND)
    as:SetSortOrder(1)
    return circle
end

function DSTADMIN_RANGE_OVERLAY.Hide(key)
    if not key then return end
    local c = DSTADMIN_RANGE_OVERLAY.circles[key]
    if c and c:IsValid() then
        c:Remove()
    end
    DSTADMIN_RANGE_OVERLAY.circles[key] = nil
end

function DSTADMIN_RANGE_OVERLAY.Show(key, x, z, radius, color_name, alpha)
    if not key then return end
    local c = DSTADMIN_RANGE_OVERLAY.circles[key]
    if c and c:IsValid() then
        c.Transform:SetPosition(x, 0, z)
        local as = c.AnimState
        if as then
            as:SetScale(radius / 9.7, radius / 9.7)
            local r, g, b = _GetColor(color_name)
            local a = alpha or DEFAULT_ALPHA
            as:SetMultColour(r, g, b, a)
            as:SetAddColour(r, g, b, 0)
        end
        return
    end
    local created = _CreateCircleAt(x, z, radius, color_name, alpha)
    DSTADMIN_RANGE_OVERLAY.circles[key] = created
end

-- 仅更新中心点（避免频繁重建实体）
function DSTADMIN_RANGE_OVERLAY.Move(key, x, z)
    if not key then return end
    local c = DSTADMIN_RANGE_OVERLAY.circles[key]
    if c and c:IsValid() and x and z then
        c.Transform:SetPosition(x, 0, z)
    end
end

function DSTADMIN_RANGE_OVERLAY.ClearAll()
    for key, _ in pairs(DSTADMIN_RANGE_OVERLAY.circles) do
        DSTADMIN_RANGE_OVERLAY.Hide(key)
    end
end
