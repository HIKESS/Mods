-- 寄居蟹老奶奶只读状态：只外挂到 DstAdmin，不修改原版 prefab 文件。

local M = {}

local function SafeText(value)
    return tostring(value or ""):gsub("[|,]", " ")
end

local function IsHermit(inst)
    return inst ~= nil and inst:IsValid() and inst.prefab == "hermitcrab" and inst:HasTag("hermitcrab")
end

function M.FindHermitByGUID(guid)
    local id = GLOBAL.tonumber(guid)
    local inst = id ~= nil and GLOBAL.Ents ~= nil and GLOBAL.Ents[id] or nil
    return IsHermit(inst) and inst or nil
end

local function CountTasks(friendlevels)
    local completed, total = 0, 0
    if friendlevels ~= nil and friendlevels.friendlytasks ~= nil then
        for _, task in pairs(friendlevels.friendlytasks) do
            total = total + 1
            if task ~= nil and task.complete then
                completed = completed + 1
            end
        end
    end
    return completed, total
end

local function GetFriendStage(inst)
    local stage = "LOW"
    GLOBAL.pcall(function()
        if inst.getgeneralfriendlevel ~= nil then
            stage = inst.getgeneralfriendlevel(inst)
        elseif inst.components.friendlevels ~= nil then
            local level = inst.components.friendlevels.level or 0
            stage = level > 7 and "HIGH" or (level > 3 and "MED" or "LOW")
        end
    end)
    return stage
end

local function GetDisplayName(inst)
    local name = nil
    GLOBAL.pcall(function()
        if inst.GetDisplayName ~= nil then
            name = inst:GetDisplayName()
        elseif inst.displaynamefn ~= nil then
            name = inst.displaynamefn(inst)
        end
    end)
    if name == nil or name == "" then
        name = GLOBAL.STRINGS and GLOBAL.STRINGS.NAMES and GLOBAL.STRINGS.NAMES.HERMITCRAB or "Hermit Crab"
    end
    return name
end

function M.CollectStatus(inst)
    if not IsHermit(inst) then return "" end

    local level, max_level = 0, 0
    local completed_tasks, total_tasks = 0, 0
    GLOBAL.pcall(function()
        local friendlevels = inst.components.friendlevels
        if friendlevels ~= nil then
            level = friendlevels:GetLevel() or friendlevels.level or 0
            max_level = friendlevels:GetMaxLevel() or 0
            completed_tasks, total_tasks = CountTasks(friendlevels)
        end
    end)

    local data = {
        tostring(inst.GUID or 0),
        SafeText(GetDisplayName(inst)),
        tostring(level),
        tostring(max_level),
        SafeText(GetFriendStage(inst)),
        tostring(completed_tasks),
        tostring(total_tasks),
        tostring(inst._shop_level or 0),
        inst.pearlgiven and "1" or "0",
        inst.gotcrackedpearl and "1" or "0",
        inst:HasTag("highfriendlevel") and "1" or "0",
    }
    return table.concat(data, "|")
end

GLOBAL.rawset(GLOBAL, "DSTADMIN_HERMITCRAB_STATUS", M)

return M
