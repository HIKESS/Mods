local STRINGS = GLOBAL.STRINGS
local require = GLOBAL.require
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
GetWorld = GLOBAL.GetWorld
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH


williamtab = AddRecipeTab("Toymaker", 999, "images/tabs/williamtab.xml", "williamtab.tex", "william")

--------------------------------// GADGET \\--------------------------------


AddRecipe("williamgadget",
	             {
	              Ingredient("transistor", 2),
	              Ingredient("cutstone", 1),
		      Ingredient("charcoal", 3),
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William", "images/inventoryimages/williamgadget.xml")

local williamgadget = Ingredient( "williamgadget", 1)
williamgadget.atlas = "images/inventoryimages/williamgadget.xml"

--------------------------------// BUTLER \\--------------------------------


AddRecipe("williambutler_builder",
	             {
	              williamgadget,
	              Ingredient("goldnugget", 1),
	              Ingredient("silk", 2)
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William", "images/inventoryimages/williambutler_builder.xml")



--------------------------------// BUSTER \\--------------------------------

AddRecipe("williambuster_builder",
	             {
	              williamgadget,
	              Ingredient("cutstone", 2),
	              Ingredient("pigskin", 2)
	             },
williamtab, TECH.SCIENCE_ONE, nil, nil, nil, nil, "William", "images/inventoryimages/williambuster_builder.xml")



--------------------------------// BOUNCER \\--------------------------------


AddRecipe("williambrute_builder",
	             {
	              williamgadget,
	              Ingredient("armorwood", 1),
	              Ingredient("cutreeds", 9)
	             },
williamtab, TECH.SCIENCE_ONE, "williambrute_placer", 1, nil, nil, "William", "images/inventoryimages/williambrute_builder.xml")



--------------------------------// BATTERY \\--------------------------------


AddRecipe("williamballistic_empty",
	             {
	              williamgadget,
	              Ingredient("goldnugget", 2),
	              Ingredient("nitre", 2)
	             },
williamtab, TECH.SCIENCE_TWO, nil, nil, nil, nil, "William", "images/inventoryimages/williamballistic_empty.xml")

