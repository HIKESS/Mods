--可交易物品扩展
local list =
{
  "bernie_inactive",--物品形态伯尼
  "armorslurper",   --饥饿腰带
  "reflectivevest", --清凉夏装
}

for _, v in pairs(list) do
  AddPrefabPostInit(v, function(inst)
      if not TheWorld.ismastersim then return end
      inst:AddComponent("tradable")
  end)
end