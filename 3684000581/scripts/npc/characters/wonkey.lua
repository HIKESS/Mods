-- scripts/npc/characters/wonkey.lua

local M = {}

function M.on_apply(inst, stats)
    inst._is_wonkey = true
    inst:AddTag("wonkey")
    inst:AddTag("monkey")
    inst.talker_path_override = "monkeyisland/characters/"

    if inst.components.hunger ~= nil and stats ~= nil and stats.hunger ~= nil then
        inst.components.hunger:SetMax(stats.hunger)
        inst.components.hunger:SetPercent(1)
    end

    if inst.components.sanity ~= nil and stats ~= nil and stats.sanity ~= nil then
        inst.components.sanity:SetMax(stats.sanity)
        inst.components.sanity:SetPercent(1)
    end
end

return M
