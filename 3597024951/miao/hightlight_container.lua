--兼容showme中文版的容器高亮显示workshop-2287303119 --服务器模组
local containers =
{
  "jx_chest",
  "jx_chest_2",
  "jx_icebox",
  "jx_icebox_2",
  "jx_icebox_big",
  "jx_wardrobe",
  "jx_basket",
  "jx_backpack",
  "jx_backpack_2",
  "jx_backpack_3",
  "jx_backpack_4",
  "jx_backpack_5",
  "jx_pack",
  "jx_rug_bag",
  "jx_icemaker",
  "jx_furnace",
  "jx_cookpot",
  "jx_cookpot_2",
  "jx_bookcase",
  "jx_dress_form_m",
  "jx_dress_form_w",
  "jx_fish_tank",
  "jx_pickling_barrel",
  "jx_cellar",
  "jx_hay_cart",
  "jx_handcart",
  "jx_wood_bin",
  "jx_rock_bin",
  "jx_car",
  "jx_flashlight",
  "jx_storage_basket",
  "jx_honey_box",
  "jx_portable_cook_pot",
  "jx_portable_cook_pot_2",
  "jx_charcoal_stove",
  "jx_canner",
  "jx_trash_can",
  "jx_bankatm",
  "jx_table_9",
  "jx_farm_tools_container",
}
for k, m in pairs(ModManager.mods) do
  if m and GLOBAL.rawget(m, "SHOWME_STRINGS") then
    if m.postinitfns and m.postinitfns.PrefabPostInit and m.postinitfns.PrefabPostInit.treasurechest then
      for _,v in ipairs(containers) do
        m.postinitfns.PrefabPostInit[v] = m.postinitfns.PrefabPostInit.treasurechest
      end
    end
    break
  end
end