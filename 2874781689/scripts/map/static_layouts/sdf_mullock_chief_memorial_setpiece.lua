return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 5,
  height = 5,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 32,
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
      width = 5,
      height = 5,
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
        0, 6, 3, 6, 0,
        6, 3, 3, 3, 6,
        3, 3, 6, 3, 3,
        6, 3, 3, 3, 6,
        0, 6, 3, 6, 0
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
          name = "wall Pillar 25 Ent Start TL",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 136,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 2,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 136,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 3,
          name = "marble pillar",
          type = "sdf_marble_pillar",
          shape = "rectangle",
          x = 120,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 104,
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
          id = 5,
          name = "wall Pillar 25 Ent End TL",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 72,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 6,
          name = "wall Pillar 25 Ent Start BL",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 72,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 7,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 104,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 8,
          name = "marble pillar",
          type = "sdf_marble_pillar",
          shape = "rectangle",
          x = 120,
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
          id = 9,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 136,
          y = 216,
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
          name = "wall Pillar 25 Ent End BL",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 136,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 11,
          name = "wall Pillar 25 Ent Start BR",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 184,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 12,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 184,
          y = 216,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 13,
          name = "marble pillar",
          type = "sdf_marble_pillar",
          shape = "rectangle",
          x = 200,
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
          id = 14,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 216,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 15,
          name = "wall Pillar 25 Ent End BR",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 248,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 16,
          name = "wall Pillar 25 Ent Start TR",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 248,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 17,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 216,
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
          id = 18,
          name = "marble pillar",
          type = "sdf_marble_pillar",
          shape = "rectangle",
          x = 200,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 19,
          name = "wall Pillar 75",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 184,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          id = 20,
          name = "wall Pillar 25 Ent End TR",
          type = "sdf_wall_stone_pillar",
          shape = "rectangle",
          x = 184,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          id = 21,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 72,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 22,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 72,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 23,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 248,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 24,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 248,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 25,
          name = "Mullock Chief Memorial",
          type = "sdf_mullock_chief_memorial",
          shape = "rectangle",
          x = 160,
          y = 160,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 26,
          name = "Mullock Chief Memorial Mound",
          type = "sdf_mullock_chief_memorial_mound",
          shape = "rectangle",
          x = 160,
          y = 160,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 27,
          name = "plant",
          type = "marsh_plant",
          shape = "rectangle",
          x = 112,
          y = 112,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 28,
          name = "plant",
          type = "marsh_plant",
          shape = "rectangle",
          x = 112,
          y = 208,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 29,
          name = "plant",
          type = "marsh_plant",
          shape = "rectangle",
          x = 208,
          y = 208,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 30,
          name = "plant",
          type = "marsh_plant",
          shape = "rectangle",
          x = 208,
          y = 112,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 31,
          name = "IGarg",
          type = "sdf_information_gargoyle",
          shape = "rectangle",
          x = 160,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "4"
          }
        }
      }
    }
  }
}
