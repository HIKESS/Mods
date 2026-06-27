local G = GLOBAL
------------------
local jx_hanging_bed = AddAction("JX_HANGING_BED", G.STRINGS.ACTIONS.JX_HANGING_BED, function(act)
    if not act.target:HasTag("burnt") then
      local tx, ty, tz = act.target.Transform:GetWorldPosition()
      act.doer.Physics:Teleport(tx, ty, tz)
      return true
    end
    return false
end)

AddComponentAction("SCENE", "jx_hanging_bed", function(inst, doer, actions, right)
    if right and not (doer.replica.rider and doer.replica.rider:IsRiding()) then
      table.insert(actions, jx_hanging_bed)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_hanging_bed, "jx_hanging_bed"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_hanging_bed, "jx_hanging_bed"))