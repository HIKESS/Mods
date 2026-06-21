local ThePlayer = GLOBAL.ThePlayer
local TheInput = GLOBAL.TheInput
local SpawnPrefab = GLOBAL.SpawnPrefab

GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----

----水果蛋糕配方
local gw_dangao = {
    test = function(cooker, names, tags)
        return names.honey and names.honey >= 2 and tags.fruit and tags.fruit >= 2
    end,
    name = "gw_dangao",
    weight = 100, -- 食谱权重
    priority = 999, -- 食谱优先级
	perishtime = TUNING.PERISH_PRESERVED,
	maxstacksize = TUNING.STACK_SIZE_MEDITEM, -- 堆叠上限
	health = 20,
	hunger = 40,
	sanity = 10,
	stacksize = 1, --产生数量
    perishtime = nil, --腐烂时间
    cooktime = .9, --烹饪时间
    potlevel = "high",
    cookbook_tex = "gw_dangao.tex",
    cookbook_atlas = "images/inventoryimages/gw_dangao.xml",
    floater = {"med", nil, 0.55},
    cookbook_category = "cookpot",
    overridebuild = "gw_foods",
    overridesymbolname = "gw_dangao",
}
----AddCookerRecipe("cookpot", gw_dangao) -- 将食谱添加进普通锅
AddCookerRecipe("portablecookpot", gw_dangao) -- 将食谱添加进便携锅

----食谱显示
RegisterInventoryItemAtlas("images/inventoryimages/gw_dangao.xml", "gw_dangao.tex")----水果蛋糕
