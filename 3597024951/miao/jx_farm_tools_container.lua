local G = GLOBAL
local ACTIONS = G.ACTIONS

local dig = ACTIONS.DIG.id.."_tool"
local hammer = ACTIONS.HAMMER.id.."_tool"

AddPrefabPostInitAny(function(inst)
    if not G.TheWorld.ismastersim then return end
    if inst:HasAnyTag(dig, hammer, "wateringcan")
      or inst.components.farmtiller ~= nil
      or inst.components.fertilizer ~= nil
    then
      inst:AddTag("jx_farm_tools_container_valid")
    end
end)