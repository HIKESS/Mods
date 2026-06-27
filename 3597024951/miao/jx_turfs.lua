--复古棋盘浴室瓷砖
AddTile("JX_BATH", "LAND", {},
  {
    name = "levels/tiles/blocky.tex",
    noise_texture = "noise_jx_bath",
    runsound = "dontstarve/movement/run_dirt",
    walksound = "dontstarve/movement/walk_dirt",
    snowsound = "dontstarve/movement/run_ice",
    mudsound = "dontstarve/movement/run_mud",
    hard = true,
  },
  {
    name = "map_edge",
    noise_texture = "mini_noise_jx_bath"
  },
  {
    name = "bath",
    anim = "jx_turf_bath",
    bank_build = "jx_turfs"
  }
)

--花岗岩拼花瓷砖
AddTile("GRANITE", "LAND", {ground_name = "Granite"},--?
  {
    name = "levels/tiles/carpet.tex",
    noise_texture = "noise_jx_granite",
    runsound = "dontstarve/movement/run_carpet",
    walksound = "dontstarve/movement/walk_carpet",
    snowsound = "dontstarve/movement/run_snow",
    mudsound = "dontstarve/movement/run_mud",
    flooring = true,
    hard = true,
  },
  {
    name = "map_edge",
    noise_texture = "mini_noise_jx_granite"
  },
  {
    name = "granite",
    pickupsound = "cloth",
    anim = "jx_turf_granite",
    bank_build = "jx_turfs"
  }
)

--复古几何纹红棕地毯
AddTile("REDDISH_BROWN", "LAND", {},
  {
    name = "levels/tiles/carpet.tex",
    noise_texture = "noise_jx_reddish_brown",
    runsound = "dontstarve/movement/run_carpet",
    walksound = "dontstarve/movement/walk_carpet",
    snowsound = "dontstarve/movement/run_snow",
    mudsound = "dontstarve/movement/run_mud",
    flooring = true,
    hard = true,
  },
  {
    name = "map_edge",
    noise_texture = "mini_noise_jx_reddish_brown"
  },
  {
    name = "reddish_brown",
    pickupsound = "cloth",
    anim = "jx_turf_reddish_brown",
    bank_build = "jx_turfs"
  }
)

--棕韵织章回廊地毯
AddTile("CORRIDOR", "LAND", {},
  {
    name = "levels/tiles/carpet.tex",
    noise_texture = "noise_jx_corridor",
    runsound = "dontstarve/movement/run_carpet",
    walksound = "dontstarve/movement/walk_carpet",
    snowsound = "dontstarve/movement/run_snow",
    mudsound = "dontstarve/movement/run_mud",
    flooring = true,
    hard = true,
  },
  {
    name = "map_edge",
    noise_texture = "mini_noise_jx_corridor"
  },
  {
    name = "corridor",
    pickupsound = "cloth",
    anim = "jx_turf_corridor",
    bank_build = "jx_turfs"
  }
)

--庭院步道方砖
AddTile("JX_COURTYARD", "LAND", {},
  {
    name = "levels/tiles/jx_stoneroad.tex",
    noise_texture = "noise_jx_courtyard",
    runsound = "dontstarve/movement/run_dirt",
    walksound = "dontstarve/movement/walk_dirt",
    snowsound = "dontstarve/movement/run_ice",
    mudsound = "dontstarve/movement/run_mud",
    hard = true,
    roadways = true,
  },
  {
    name = "map_edge",
    noise_texture = "mini_noise_jx_courtyard"
  },
  {
    name = "jx_courtyard",
    anim = "jx_turf_courtyard",
    bank_build = "jx_turfs"
  }
)

--宫廷实木地板
AddTile("JX_WOOD", "LAND", {},
  {
    name = "levels/tiles/jx_stoneroad.tex",
    noise_texture = "noise_jx_wood",
    runsound = "dontstarve/movement/run_wood",
    walksound = "dontstarve/movement/walk_wood",
    snowsound = "dontstarve/movement/run_ice",
    mudsound = "dontstarve/movement/run_mud",
    flooring = true,
    hard = true,
  },
  {
    name = "map_edge",
    noise_texture = "mini_noise_jx_wood"
  },
  {
    name = "jx_wood",
    pickupsound = "wood",
    anim = "jx_turf_wood",
    bank_build = "jx_turfs"
  }
)