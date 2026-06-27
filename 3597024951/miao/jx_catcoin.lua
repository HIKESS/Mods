local G = GLOBAL
-------------------------
-- 能力勋章 风花雪月充值
local JX_MEDALRECHARGE = AddAction("JX_MEDALRECHARGE", G.STRINGS.ACTIONS.JX_MEDALRECHARGE, function(act)
    if act.invobject and act.invobject:HasTag("jx_catcoin") and
      act.target and act.target.prefab == "medal_skin_staff" and
      act.target.components.finiteuses ~= nil and act.target.components.finiteuses:GetPercent() < 1
    then
      local stacksize = act.invobject.components.stackable ~= nil and act.invobject.components.stackable.stacksize or 1
      local uses_can_repair = stacksize * 10
      local uses_need_to_repair = act.target.components.finiteuses.total - act.target.components.finiteuses.current
      local uses_real_repair = uses_need_to_repair > uses_can_repair and uses_can_repair or math.ceil(uses_need_to_repair / 10) * 10
      if act.invobject.components.stackable then
        act.invobject.components.stackable:Get(uses_real_repair / 10):Remove()
      else
        act.invobject:Remove()
      end
      act.target.components.finiteuses:Repair(uses_real_repair)
      return true
    end
    return false
end)
JX_MEDALRECHARGE.mount_valid = true

AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    if doer:HasTag("player") and inst:HasTag("jx_catcoin") and target.prefab == "medal_skin_staff" then
      table.insert(actions, JX_MEDALRECHARGE)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(JX_MEDALRECHARGE, "dostandingaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(JX_MEDALRECHARGE, "dostandingaction"))