--兼容智能小木牌workshop-1595631294 --服务器模组
if GLOBAL.KnownModIndex:IsModEnabled("workshop-1595631294") then
  AddPrefabPostInit("jx_chest", function(inst)
      if not TheWorld.ismastersim then return end
      inst:AddComponent("smart_minisign")
  end)
  AddPrefabPostInit("jx_chest_2", function(inst)
      if not TheWorld.ismastersim then return end
      inst:AddComponent("smart_minisign")
  end)
end