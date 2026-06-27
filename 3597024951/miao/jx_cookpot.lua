local G = GLOBAL

--[[local cooking = require("cooking")
local oldRegisterPrefabs = G.ModManager.RegisterPrefabs
G.ModManager.RegisterPrefabs = function(self,...)
  for k, v in pairs(cooking.recipes) do
    if k and v and k == "cookpot" then
      for _, i in pairs(v) do
        --if not (i.spice or i.platetype) then
          local newrecipe = shallowcopy(i)
          newrecipe.no_cookbook = true
          AddCookerRecipe("jx_cookpot", newrecipe)
				--end
			end
    end
  end
  oldRegisterPrefabs(self,...)
end]]
--[[local foods = require("preparedfoods")
for k, recipe in pairs(foods) do 
  AddCookerRecipe("jx_cookpot", recipe) 
end
local nonfoods = require("preparednonfoods")
for k, recipe in pairs(nonfoods) do 
  AddCookerRecipe("jx_cookpot", recipe)
end]]

--锅食谱
AddSimPostInit(function()
  local cooking = require("cooking")
  if cooking and cooking.recipes then
    for k, v in pairs(cooking.recipes) do
      if k and v then
        if k == "cookpot" then
          for _, i in pairs(v) do
            local newrecipe = shallowcopy(i)
            newrecipe.no_cookbook = true
            AddCookerRecipe("jx_cookpot", newrecipe)
            AddCookerRecipe("jx_cookpot_2", newrecipe)
            if G.TUNING.JX_TUNING.jx_portable_cook_pot_recipes == false then
              AddCookerRecipe("jx_portable_cook_pot", newrecipe)
            end
            if G.TUNING.JX_TUNING.jx_portable_cook_pot_2_recipes == false then
              AddCookerRecipe("jx_portable_cook_pot_2", newrecipe)
            end
          end
        elseif k == "portablecookpot" then
          for _, i in pairs(v) do
            local newrecipe = shallowcopy(i)
            newrecipe.no_cookbook = true
            if G.TUNING.JX_TUNING.jx_portable_cook_pot_recipes ~= false then
              AddCookerRecipe("jx_portable_cook_pot", newrecipe)
            end
            if G.TUNING.JX_TUNING.jx_portable_cook_pot_2_recipes ~= false then
              AddCookerRecipe("jx_portable_cook_pot_2", newrecipe)
            end
          end
  			end
      end
    end
  end
end)

----------
--兼容智能锅workshop-727774324 --本地模组
--函数在 workshop-727774324 的 scripts/cookingpots.lua 中被定义
if G.KnownModIndex:IsModEnabled("workshop-727774324") then
  G.AddCookingPot('jx_cookpot')
  G.AddCookingPot('jx_cookpot_2')
  G.AddCookingPot('jx_portable_cook_pot')
  G.AddCookingPot('jx_portable_cook_pot_2')
end

------------
--兼容自动做饭workshop-2033458869 --本地模组
local cookware_morphs =
{
  cookpot =
  {
    jx_cookpot = true,
    jx_cookpot_2 = true,
  },
  portablecookpot =
  {
    jx_portable_cook_pot = true,
    jx_portable_cook_pot_2 = true,
  }
}
local AUTO_COOKING_COOKWARES = G.rawget(G, "AUTO_COOKING_COOKWARES") or {}
G.AUTO_COOKING_COOKWARES = AUTO_COOKING_COOKWARES
for base, morphs in pairs(cookware_morphs) do
  AUTO_COOKING_COOKWARES[base] = shallowcopy(morphs, AUTO_COOKING_COOKWARES[base])
end