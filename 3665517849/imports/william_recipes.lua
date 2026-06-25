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
	              Ingredient("transistor", 1),
	              Ingredient("cutstone", 1),
		          Ingredient("wagpunk_bits", 2)
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William", "images/inventoryimages/williamgadget.xml")

local williamgadget = Ingredient( "williamgadget", 1)
williamgadget.atlas = "images/inventoryimages/williamgadget.xml"

--------------------------------// BUTLER \\--------------------------------


AddRecipe("williambutler_builder",
	             {
	              williamgadget,
	              Ingredient("goldnugget", 3),
	              Ingredient("tophat", 1)
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William", "images/inventoryimages/williambutler_builder.xml")



--------------------------------// BUSTER \\--------------------------------

AddRecipe("williambuster_builder",
	             {
	              williamgadget,
	              Ingredient("cutstone", 2),
	              Ingredient("pigskin", 2)
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William", "images/inventoryimages/williambuster_builder.xml")



--------------------------------// BOUNCER \\--------------------------------


AddRecipe("williambrute_builder",
	             {
	              williamgadget,
	              Ingredient("armormarble", 1),
	              Ingredient("wagpunk_bits", 5),
				  Ingredient("cutstone", 2)
	             },
williamtab, TECH.NONE, "williambrute_placer", 1, nil, nil, "William", "images/inventoryimages/williambrute_builder.xml")



--------------------------------// BATTERY \\--------------------------------


AddRecipe("williamballistic_empty",
	             {
	              williamgadget,
	              Ingredient("goggleshat", 1),
	              Ingredient("nitre", 3)
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William", "images/inventoryimages/williamballistic_empty.xml")

--[[AddRecipe("chessjunk",
	             {
	              Ingredient("wagpunk_bits", 2),
	              Ingredient("gears", 1),
	              Ingredient("nightmarefuel", 1)
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William")]]

--[[AddRecipe("chessjunk1",
	             {
	              Ingredient("gears", 1),
	              Ingredient("nightmarefuel", 1),
				  Ingredient("wagpunk_bits", 1),
	             },
williamtab, TECH.NONE, nil, nil, nil, nil, "William")]]

