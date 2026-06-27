local G = GLOBAL

local jx_refresh = AddAction("JX_REFRESH", G.STRINGS.ACTIONS.JX_REFRESH, function(act)
    if act.target and act.target:HasTag("jx_refresh_target_in_cd") then
      return false
    end
    if act.invobject and act.invobject.components.jx_refresh and act.invobject.components.jx_refresh.perrefreshpercent and
      act.invobject.components.perishable and act.invobject.components.perishable.perishtime
    then
      act.invobject.components.perishable:SetPercent(act.invobject.components.perishable:GetPercent() + act.invobject.components.jx_refresh.perrefreshpercent)
      if act.doer and act.doer.components.inventory then
        local item = act.doer.components.inventory:RemoveItem(act.invobject, true)
        act.doer.components.inventory:GiveItem(item)
      else
        if act.invobject.components.inventoryitem then
          act.invobject.components.inventoryitem:OnDropped(true)
        end
      end
      if act.target then
        --[[for _, v in pairs(G.Ents) do
          if v:HasTag("jx_refresh_target") and not v:HasTag("jx_refresh_target_in_cd") then
            v:AddTag("jx_refresh_target_in_cd")
            if v.components.timer == nil then
              v:AddComponent("timer")
            end
            v.components.timer:StartTimer("cd", 120)
          end
        end]]
        local x, y, z = act.target.Transform:GetWorldPosition()
        local ents = G.TheSim:FindEntities(x, y, z, 60, {"jx_refresh_target"}, {"jx_refresh_target_in_cd"})
        for _, v in ipairs(ents) do
          v:AddTag("jx_refresh_target_in_cd")
          if v.components.timer == nil then
            v:AddComponent("timer")
          end
          v.components.timer:StartTimer("cd", 120)
        end
      end
      return true
    end
    return false
end)
jx_refresh.rmb = true
jx_refresh.priority = 1

AddComponentAction("USEITEM", "jx_refresh", function(inst, doer, target, actions, right)
    if right and target:HasTag("jx_refresh_target") and not target:HasAnyTag("burnt", "jx_refresh_target_in_cd") then
      table.insert(actions, jx_refresh)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_refresh, "dolongaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_refresh, "dolongaction"))

AddPrefabPostInitAny(function(inst)
    if not G.TheWorld.ismastersim then return end
    if inst.components.perishable and inst.components.perishable.perishtime then
      inst:AddComponent("jx_refresh")
      inst.components.jx_refresh:SetPerRefrshPercent(.2)
    end
end)