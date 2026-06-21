local KodiRecipes = {}
function KodiRecipes.Register(AddCharacterRecipe, Ingredient, TECH)
    AddCharacterRecipe("kitsune_mask",
        {
            Ingredient("thulecite", 5),
            Ingredient("fox_wool", 10, "images/inventoryimages/fox_wool.xml"),
            Ingredient("darkcrystal", 3, "images/inventoryimages/darkcrystal.xml")
        },
        TECH.MAGIC_THREE,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/kitsune_mask.xml",
            image = "kitsune_mask.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("Cursefox",
        {
            Ingredient("nightmarefuel", 8),
            Ingredient("darkcrystal", 3, "images/inventoryimages/darkcrystal.xml"),
            Ingredient("purplegem", 1),
            Ingredient("livinglog", 4)
        },
        TECH.SHADOW_MANIPULATOR,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/Cursefox.xml",
            image = "Cursefox.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("scythe_of_shadows",
        {
            Ingredient("nightmarefuel", 6),
            Ingredient("darkcrystal", 2, "images/inventoryimages/darkcrystal.xml"),
            Ingredient("purplegem", 1),
            Ingredient("livinglog", 4)
        },
        TECH.SHADOW_MANIPULATOR,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/scythe_of_shadows.xml",
            image = "scythe_of_shadows.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("kodisword",
        {
            Ingredient("twigs", 2),
            Ingredient("rope", 1),
            Ingredient("goldnugget", 2)
        },
        TECH.NONE,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/kodisword.xml",
            image = "kodisword.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("shlemys",
        {
            Ingredient("pigskin", 1),
            Ingredient("rope", 2),
            Ingredient("goldnugget", 3)
        },
        TECH.NONE,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/shlemys.xml",
            image = "shlemys.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("whitegem",
        {
            Ingredient("marble", 1),
            Ingredient("nightmarefuel", 2),
            Ingredient("purplegem", 1)
        },
        TECH.MAGIC_TWO,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/whitegem.xml",
            image = "whitegem.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("darkcrystal",
        {
            Ingredient("nightmarefuel", 15),
            Ingredient("purplegem", 1),
            Ingredient("fox_wool", 5, "images/inventoryimages/fox_wool.xml")
        },
        TECH.MAGIC_TWO,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/darkcrystal.xml",
            image = "darkcrystal.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("whiteamulet",
        {
            Ingredient("goldnugget", 5),
            Ingredient("nightmarefuel", 2),
            Ingredient("whitegem", 1, "images/inventoryimages/whitegem.xml")
        },
        TECH.MAGIC_TWO,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/whiteamulet.xml",
            image = "whiteamulet.tex"
        },
        {"CHARACTER"})
    AddCharacterRecipe("bedroll_fox_furry",
        {
            Ingredient("rope", 2),
            Ingredient("fox_wool", 8, "images/inventoryimages/fox_wool.xml")
        },
        TECH.NONE,
        {
            builder_tag = "kodi_builder",
            atlas = "images/inventoryimages/bedroll_fox_furry.xml",
            image = "bedroll_fox_furry.tex"
        },
        {"CHARACTER"})
end
return KodiRecipes
