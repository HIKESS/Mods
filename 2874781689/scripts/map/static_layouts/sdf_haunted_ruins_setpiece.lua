return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 13,
  height = 13,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 199,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../../../../../../Program Files (x86)/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/DST_Tile_Set.tsx"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 13,
      height = 13,
      id = 1,
      name = "BG_TILES",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 40, 40, 40, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 40, 40, 31, 40, 40, 0, 0, 0, 0,
        0, 0, 40, 40, 40, 31, 31, 31, 40, 40, 40, 0, 0,
        0, 0, 40, 3, 3, 31, 31, 31, 3, 3, 40, 0, 0,
        0, 40, 40, 3, 31, 31, 31, 31, 31, 3, 40, 40, 0,
        0, 40, 31, 31, 31, 31, 40, 31, 31, 31, 31, 40, 0,
        0, 40, 31, 31, 31, 40, 40, 40, 31, 31, 31, 40, 0,
        0, 40, 31, 31, 31, 31, 40, 31, 31, 31, 31, 40, 0,
        0, 40, 40, 3, 31, 31, 31, 31, 31, 3, 40, 40, 0,
        0, 0, 40, 3, 3, 31, 31, 31, 3, 3, 40, 0, 0,
        0, 0, 40, 40, 40, 31, 31, 31, 40, 40, 40, 0, 0,
        0, 0, 0, 0, 40, 40, 31, 40, 40, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 40, 40, 40, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "FG_OBJECTS",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "Chest Kingdom",
          type = "sdf_chest_kingdom",
          shape = "rectangle",
          x = 416,
          y = 416,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "wall Pillar 100 Ent Start",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 392,
          y = 760,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 3,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 376,
          y = 760,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 4,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 360,
          y = 744,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 5,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 344,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 6,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 328,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 7,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 8,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 712,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 9,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 696,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 10,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 680,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 11,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 12,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 328,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 13,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 296,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 14,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 280,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 15,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 16,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 248,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.50"
          }
        },
        {
          id = 17,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 232,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 18,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 216,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 19,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 200,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 20,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 184,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 21,
          name = "wall Stone 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 168,
          y = 648,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 22,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 632,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 23,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 616,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 24,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 600,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 25,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 584,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 26,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 568,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 27,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 552,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 28,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 29,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 152,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 30,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 136,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 31,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 120,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 32,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 104,
          y = 520,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 33,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 504,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 34,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 488,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 35,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 472,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 36,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 456,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 37,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 440,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 38,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 424,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 39,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 408,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 40,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 392,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 41,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 376,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 42,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 43,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 344,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 44,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 104,
          y = 328,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 45,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 104,
          y = 312,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 46,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 120,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 47,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 136,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 48,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 152,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 49,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 50,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 51,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 264,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 52,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 53,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 232,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 54,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 216,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 55,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 56,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 168,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 57,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 184,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 58,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 200,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 59,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 216,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 60,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 232,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 61,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 248,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 62,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 63,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 280,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 64,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 296,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 65,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 328,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 66,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 67,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 152,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 68,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 69,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 70,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 312,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 71,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 328,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 72,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 344,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 73,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 360,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 74,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 376,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 75,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 392,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 196,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 408,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 197,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 424,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 76,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 440,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 77,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 456,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 78,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 472,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 79,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 488,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 80,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 504,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 81,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 82,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 83,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 84,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 152,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 85,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 86,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 504,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 87,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 536,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 88,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 552,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 89,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 568,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 90,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 584,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 91,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 600,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 92,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 616,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 93,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 632,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 94,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 648,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 95,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 664,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 96,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 97,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 216,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 98,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 232,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 99,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 100,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 264,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 101,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 102,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 103,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 680,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 104,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 696,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 105,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 712,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 106,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 728,
          y = 312,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 107,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 328,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 108,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 344,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 109,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 110,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 376,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 111,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 392,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 112,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 408,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 113,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 424,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 114,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 440,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 115,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 456,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 116,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 472,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 117,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 488,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 118,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 728,
          y = 504,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 119,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 728,
          y = 520,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 120,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 712,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 121,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 696,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 122,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 680,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 123,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 536,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 124,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 552,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 125,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 568,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 126,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 584,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 127,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 600,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 128,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 616,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 129,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 664,
          y = 632,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 130,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 664,
          y = 648,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 131,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 648,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 132,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 632,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 133,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 616,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 134,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 600,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 135,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 584,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 136,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 568,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 137,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 552,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 138,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 536,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 139,
          name = "wall Pillar 100",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 504,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 140,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 664,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 141,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 680,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 142,
          name = "wall Stone 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 696,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 143,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 712,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 144,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 520,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 145,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 504,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 146,
          name = "wall Stone 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 488,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          id = 147,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 472,
          y = 744,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 148,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 456,
          y = 760,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 149,
          name = "wall Pillar 100 Ent End",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 440,
          y = 760,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 150,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 360,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 151,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 360,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 152,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 472,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 153,
          name = "wall Stone 100",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 472,
          y = 728,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 154,
          name = "lava Pond",
          type = "sdf_haunted_ruins_lava_pond",
          shape = "rectangle",
          x = 240,
          y = 592,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 155,
          name = "lava Pond",
          type = "sdf_haunted_ruins_lava_pond",
          shape = "rectangle",
          x = 240,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 156,
          name = "lava Pond",
          type = "sdf_haunted_ruins_lava_pond",
          shape = "rectangle",
          x = 592,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 157,
          name = "lava Pond",
          type = "sdf_haunted_ruins_lava_pond",
          shape = "rectangle",
          x = 592,
          y = 592,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 158,
          name = "support Stone Pillar",
          type = "sdf_support_stone_pillar",
          shape = "rectangle",
          x = 240,
          y = 592,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.reinforced"] = "2"
          }
        },
        {
          id = 159,
          name = "support Stone Pillar",
          type = "sdf_support_stone_pillar",
          shape = "rectangle",
          x = 240,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.reinforced"] = "1"
          }
        },
        {
          id = 160,
          name = "support Stone Pillar",
          type = "sdf_support_stone_pillar",
          shape = "rectangle",
          x = 592,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.reinforced"] = "2"
          }
        },
        {
          id = 161,
          name = "support Stone Pillar",
          type = "sdf_support_stone_pillar",
          shape = "rectangle",
          x = 592,
          y = 592,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.reinforced"] = "1"
          }
        },
        {
          id = 162,
          name = "wall Stone 75 LCCage Start",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 120,
          y = 456,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 163,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 136,
          y = 456,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 164,
          name = "stone Golem Armored Cradle",
          type = "sdf_stone_golem_armored_cradle",
          shape = "rectangle",
          x = 128,
          y = 416,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 165,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 136,
          y = 376,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 166,
          name = "wall Stone 75  LCCage End",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 120,
          y = 376,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 167,
          name = "wall Stone 75 RCCage Start",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 712,
          y = 456,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 168,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 696,
          y = 456,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 169,
          name = "stone Golem Core Cradle",
          type = "sdf_stone_golem_core_cradle",
          shape = "rectangle",
          x = 704,
          y = 416,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 170,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 696,
          y = 376,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 171,
          name = "wall Stone 75  RCCage End",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 712,
          y = 376,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 172,
          name = "lava Golem Cradle 1",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 288,
          y = 544,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "1"
          }
        },
        {
          id = 173,
          name = "lava Golem Cradle 1",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 288,
          y = 288,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "1"
          }
        },
        {
          id = 174,
          name = "lava Golem Cradle 1",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 544,
          y = 288,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "1"
          }
        },
        {
          id = 175,
          name = "lava Golem Cradle 1",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 544,
          y = 544,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "1"
          }
        },
        {
          id = 176,
          name = "lava Golem Cradle 2",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 224,
          y = 512,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "2"
          }
        },
        {
          id = 177,
          name = "lava Golem Cradle 2",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 224,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "2"
          }
        },
        {
          id = 178,
          name = "lava Golem Cradle 2",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 608,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "2"
          }
        },
        {
          id = 179,
          name = "lava Golem Cradle 2",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 608,
          y = 512,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "2"
          }
        },
        {
          id = 180,
          name = "lava Golem Cradle 3",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 320,
          y = 608,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "3"
          }
        },
        {
          id = 181,
          name = "lava Golem Cradle 3",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 320,
          y = 224,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "3"
          }
        },
        {
          id = 182,
          name = "lava Golem Cradle 3",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 512,
          y = 224,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "3"
          }
        },
        {
          id = 183,
          name = "lava Golem Cradle 3",
          type = "sdf_lava_golem_cradle",
          shape = "rectangle",
          x = 512,
          y = 608,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "3"
          }
        },
        {
          id = 184,
          name = "gate",
          type = "sdf_haunted_ruins_gate",
          shape = "rectangle",
          x = 424,
          y = 760,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 185,
          name = "gate",
          type = "sdf_haunted_ruins_gate",
          shape = "rectangle",
          x = 408,
          y = 760,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 188,
          name = "haunted Chest",
          type = "sdf_chest_haunted",
          shape = "rectangle",
          x = 328,
          y = 696,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 189,
          name = "haunted Chest",
          type = "sdf_chest_haunted",
          shape = "rectangle",
          x = 328,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 190,
          name = "haunted Chest",
          type = "sdf_chest_haunted",
          shape = "rectangle",
          x = 504,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 191,
          name = "haunted Chest",
          type = "sdf_chest_haunted",
          shape = "rectangle",
          x = 504,
          y = 696,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 198,
          name = "throne",
          type = "sdf_haunted_ruins_throne",
          shape = "rectangle",
          x = 416,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 193,
          name = "IGarg",
          type = "sdf_information_gargoyle",
          shape = "rectangle",
          x = 416,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "3"
          }
        }
      }
    }
  }
}
