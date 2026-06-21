if GLOBAL.FUELTYPE then
    GLOBAL.FUELTYPE["GW_SOUL_BALL"] = "GW_SOUL_BALL"
else
    GLOBAL.FUELTYPE =
    {
        BURNABLE = "BURNABLE",
        USAGE = "USAGE",
        MAGIC = "MAGIC", --V2C: use this one if u don't want there to be any associated fuel
        CAVE = "CAVE",
        NIGHTMARE = "NIGHTMARE",
        ONEMANBAND = "ONEMANBAND",
        PIGTORCH = "PIGTORCH",
        CHEMICAL = "CHEMICAL",
        WORMLIGHT = "WORMLIGHT",
        LIGHTER = "LIGHTER",
        GW_SOUL_BALL = "GW_SOUL_BALL", 
    }
end