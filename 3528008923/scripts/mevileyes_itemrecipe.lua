-----------------------------------------------------------------------------
--My item
-----------------------------------------------------------------------------

AddRecipe2("yukishigure", 				
{Ingredient("flint", 2),Ingredient("log", 1),Ingredient("goldnugget", 1)},		
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/yukishigure.xml", image = "yukishigure.tex"},				
{"CHARACTER", "WEAPONS"})

AddRecipe2("nagarehime", 				
{Ingredient("flint", 2),Ingredient("rope", 1),Ingredient("log", 4),Ingredient("goldnugget", 2)},				
GLOBAL.TECH.NONE,				{ builder_tag="mevileyescraft" ,atlas = "images/inventoryimages/nagarehime.xml", image = "nagarehime.tex"},
{"CHARACTER", "WEAPONS"})

AddRecipe2("mbokken", 				
{Ingredient("boards", 1)},		
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/mbokken.xml", image = "mbokken.tex"},				
{"CHARACTER", "WEAPONS"})

-----------------------------------------------------------------------------
--KATANA
-----------------------------------------------------------------------------

AddRecipe2("m_katana", 				
{Ingredient("flint", 3),Ingredient("rope", 1),Ingredient("boards", 1)},		
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/m_katana.xml", image = "m_katana.tex"},				
{"CHARACTER", "WEAPONS"})

AddRecipe2("myoho", 				
{Ingredient("m_katana", 1, "images/inventoryimages/m_katana.xml"),Ingredient("nightmarefuel", 40),Ingredient("livinglog", 2),Ingredient("purplegem", 2),Ingredient("goldnugget", 4)},				
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/myoho.xml", image = "myoho.tex"},				
{"CHARACTER", "WEAPONS"})

AddRecipe2("mkogarasu", 				
{Ingredient("m_katana", 1, "images/inventoryimages/m_katana.xml"),Ingredient("horrorfuel", 4),Ingredient("dreadstone", 4),Ingredient("nightstick", 1)},				
GLOBAL.TECH.NONE,				{builder_skill="mevileyes_litlecrow", atlas = "images/inventoryimages/mkogarasu.xml", image = "mkogarasu.tex"}, --, builder_tag="mevileyescraft",	
{"CHARACTER", "WEAPONS"})

-----------------------------------------------------------------------------
--BOW
-----------------------------------------------------------------------------

AddRecipe2("mhamayumi", 				
{Ingredient("boards", 1),Ingredient("rope", 2),Ingredient("silk", 6),Ingredient("goldnugget", 1)},	
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/mhamayumi.xml", image = "mhamayumi.tex"},				
{"CHARACTER", "WEAPONS"})

AddRecipe2("mbow_arrow", 				
{Ingredient("mbow_arrow2", 5 ,"images/inventoryimages/mbow_arrow2.xml"),Ingredient("nightmarefuel", 2),Ingredient("goldnugget", 1)},	
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft",numtogive=5, atlas = "images/inventoryimages/mbow_arrow.xml", image = "mbow_arrow.tex"},				
{"CHARACTER", "WEAPONS"})

AddRecipe2("mbow_arrow2", 				
{Ingredient("twigs", 2),Ingredient("flint", 2)},	
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft",numtogive=10, atlas = "images/inventoryimages/mbow_arrow2.xml", image = "mbow_arrow2.tex"},				
{"CHARACTER", "WEAPONS"})


-----------------------------------------------------------------------------
--Other
-----------------------------------------------------------------------------

AddRecipe2("netrajournal", 				
{Ingredient("redgem", 1),Ingredient("goldnugget", 2),Ingredient("nightmarefuel", 6),Ingredient(CHARACTER_INGREDIENT.HEALTH, 50)},	
GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/netrajournal.xml", image = "netrajournal.tex"},				
{"CHARACTER", "MAGIC"})

AddRecipe2("mevileyes_helmet", 				
{Ingredient("footballhat", 1),Ingredient("nightmarefuel", 12),Ingredient("dreadstone", 4)},	
GLOBAL.TECH.NONE,				{builder_skill="mevileyes_samuraixxx", atlas = "images/inventoryimages/mevileyes_helmet.xml", image = "mevileyes_helmet.tex"},	 --builder_tag="mevileyescraft",			
{"CHARACTER", "ARMOUR"})

-----------------------------------------------------------------------------
-- Inner Armor
-----------------------------------------------------------------------------

--inner armor
--AddRecipe2("mevileyes_inner_armor", 				
--{Ingredient("nightmarefuel", 3)},				
--GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/mevileyes_inner_armor.xml", image = "mevileyes_inner_armor.tex"},	 			
--{"CHARACTER", "ARMOUR"})
--
--AddRecipe2("mevileyes_inner_head", 				
--{Ingredient("nightmarefuel", 2)},				
--GLOBAL.TECH.NONE,				{builder_tag="mevileyescraft", atlas = "images/inventoryimages/mevileyes_inner_head.xml", image = "mevileyes_inner_head.tex"},	 			
--{"CHARACTER", "ARMOUR"})
