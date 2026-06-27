local G = GLOBAL

local jx_baguette_trade = AddAction("JX_BAGUETTE_TRADE", G.STRINGS.ACTIONS.JX_BAGUETTE_TRADE, function(act)
    if act.target and act.target.ChangeToEdible then
      act.target:ChangeToEdible(nil, act.invobject)
    end
    if act.invobject then
      if act.invobject.components.stackable then
        act.invobject.components.stackable:Get():Remove()
      else
        act.invobject:Remove()
      end
    end
    return true
end)

AddComponentAction("USEITEM", "jx_baguette", function(inst, doer, target, actions, right)
    if target:HasTag("jx_baguette") and not target:HasTag("jx_baguette_edible")
      and (inst.prefab == "butter" or inst.prefab == "jammypreserves")
    then
      table.insert(actions, jx_baguette_trade)
    end
end)

AddStategraphActionHandler("wilson", G.ActionHandler(jx_baguette_trade, "dolongaction"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(jx_baguette_trade, "dolongaction"))

for _, v in ipairs({ "butter", "jammypreserves" }) do
  AddPrefabPostInit(v, function(inst)
      if not G.TheWorld.ismastersim then return end
      inst:AddComponent("jx_baguette")
  end)
end