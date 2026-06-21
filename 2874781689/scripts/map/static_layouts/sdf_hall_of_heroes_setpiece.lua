return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 7,
  height = 7,
  tilewidth = 64,
  tileheight = 64,
  nextlayerid = 3,
  nextobjectid = 98,
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
      width = 7,
      height = 7,
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
        0, 0, 2, 2, 2, 0, 0,
        0, 2, 2, 9, 2, 2, 0,
        0, 2, 9, 9, 9, 2, 0,
        0, 2, 9, 9, 9, 2, 0,
        0, 2, 2, 9, 2, 2, 0,
        0, 0, 2, 3, 2, 0, 0,
        0, 0, 2, 2, 2, 0, 0
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
          name = "Bloodmonath Skull Cleaver",
          type = "sdf_statue",
          shape = "rectangle",
          x = 304,
          y = 176,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Bloodmonath Skull Cleaver",
            ["data.typeid"] = "7"
          }
        },
        {
          id = 2,
          name = "Canny Tim",
          type = "sdf_statue",
          shape = "rectangle",
          x = 144,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Canny Tim",
            ["data.typeid"] = "2"
          }
        },
        {
          id = 3,
          name = "Imanzi Shongama",
          type = "sdf_statue",
          shape = "rectangle",
          x = 176,
          y = 144,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Imanzi Shongama",
            ["data.typeid"] = "5"
          }
        },
        {
          id = 4,
          name = "Dirk Steadfast",
          type = "sdf_statue",
          shape = "rectangle",
          x = 272,
          y = 144,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Dirk Steadfast",
            ["data.typeid"] = "9"
          }
        },
        {
          id = 5,
          name = "Chalice Hall of Heroes",
          type = "sdf_chalice_hall_of_heroes",
          shape = "rectangle",
          x = 224,
          y = 178,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "Karl Sturnguard",
          type = "sdf_statue",
          shape = "rectangle",
          x = 144,
          y = 175,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Karl Sturnguard",
            ["data.typeid"] = "8"
          }
        },
        {
          id = 7,
          name = "Megwynne Stormbinder",
          type = "sdf_statue",
          shape = "rectangle",
          x = 224,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Megwynne Stormbinder",
            ["data.typeid"] = "10"
          }
        },
        {
          id = 8,
          name = "RavenHooves the Archer",
          type = "sdf_statue",
          shape = "rectangle",
          x = 224,
          y = 288,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "RavenHooves the Archer",
            ["data.typeid"] = "6"
          }
        },
        {
          id = 9,
          name = "Stanyer Iron Hewer",
          type = "sdf_statue",
          shape = "rectangle",
          x = 304,
          y = 208,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Stanyner Iron Hewer",
            ["data.typeid"] = "3"
          }
        },
        {
          id = 10,
          name = "Woden the Mighty",
          type = "sdf_statue",
          shape = "rectangle",
          x = 144,
          y = 208,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Woden the Mighty",
            ["data.typeid"] = "4"
          }
        },
        {
          id = 11,
          name = "Sir Daniel Fortesque",
          type = "sdf_statue",
          shape = "rectangle",
          x = 304,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.setname"] = "Sir Daniel Fortesque",
            ["data.typeid"] = "1"
          }
        },
        {
          id = 12,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 328,
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
          id = 13,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 120,
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
          id = 14,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 120,
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
          id = 15,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 328,
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
          id = 16,
          name = "wall",
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
          id = 17,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 280,
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
          id = 18,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 280,
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
          id = 19,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
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
          id = 20,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 184,
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
          id = 21,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 184,
          y = 56,
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
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 184,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 23,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 184,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 24,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
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
          id = 25,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
          y = 56,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          id = 26,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
          y = 88,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 27,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 28,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 200,
          y = 56,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 29,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 216,
          y = 56,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 30,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 232,
          y = 56,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 31,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 248,
          y = 56,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 32,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 184,
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
          id = 33,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
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
          id = 34,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 200,
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
          id = 35,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 248,
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
          id = 36,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
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
          id = 37,
          name = "wall 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".50"
          }
        },
        {
          id = 38,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 168,
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
          id = 39,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 280,
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
          id = 40,
          name = "wall 50",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 280,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".50"
          }
        },
        {
          id = 41,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 280,
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
          id = 42,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 136,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 43,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 152,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 44,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 168,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 45,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 280,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 46,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 296,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 47,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 312,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 48,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 49,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 152,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 50,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 51,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 52,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 53,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 216,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 54,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 232,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 55,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 120,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 56,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 136,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 57,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 152,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 58,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 168,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 59,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 184,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 60,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 61,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 216,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 62,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 232,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 63,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 328,
          y = 248,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 64,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 136,
          y = 264,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 65,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 152,
          y = 264,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 66,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 296,
          y = 264,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 67,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 312,
          y = 264,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 68,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 168,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 69,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 168,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 70,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 168,
          y = 312,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 71,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 280,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 72,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 280,
          y = 296,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 73,
          name = "wall",
          type = "sdf_wall_wood",
          shape = "rectangle",
          x = 280,
          y = 312,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".5"
          }
        },
        {
          id = 74,
          name = "light",
          type = "fireflies",
          shape = "rectangle",
          x = 224,
          y = 178,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 75,
          name = "plant",
          type = "marsh_plant",
          shape = "rectangle",
          x = 184,
          y = 408,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 76,
          name = "plant",
          type = "marsh_plant",
          shape = "rectangle",
          x = 264,
          y = 408,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 77,
          name = "plant",
          type = "grass",
          shape = "rectangle",
          x = 168,
          y = 392,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 78,
          name = "plant",
          type = "grass",
          shape = "rectangle",
          x = 280,
          y = 392,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 79,
          name = "bush",
          type = "marsh_bush",
          shape = "rectangle",
          x = 152,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 80,
          name = "bush",
          type = "marsh_bush",
          shape = "rectangle",
          x = 296,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 81,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 168,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 82,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 280,
          y = 104,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 83,
          name = "grass",
          type = "grass",
          shape = "rectangle",
          x = 200,
          y = 40,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 84,
          name = "grass",
          type = "grass",
          shape = "rectangle",
          x = 248,
          y = 40,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 85,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 184,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 86,
          name = "wall 75",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
          y = 72,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = ".75"
          }
        },
        {
          id = 87,
          name = "IGarg",
          type = "sdf_information_gargoyle",
          shape = "rectangle",
          x = 192,
          y = 344,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "1"
          }
        },
        {
          id = 88,
          name = "MGarg",
          type = "sdf_merchant_gargoyle",
          shape = "rectangle",
          x = 256,
          y = 344,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 89,
          name = "Runestone",
          type = "sdf_chalice_runestone",
          shape = "rectangle",
          x = 224,
          y = 216,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 90,
          name = "Chest Runestone",
          type = "sdf_chest_runestone",
          shape = "rectangle",
          x = 296,
          y = 142,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 91,
          name = "Chest Runestone",
          type = "sdf_chest_runestone",
          shape = "rectangle",
          x = 152,
          y = 142,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 92,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 184,
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
          id = 93,
          name = "wall",
          type = "sdf_wall_stone",
          shape = "rectangle",
          x = 264,
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
          id = 94,
          name = "HoH Time Rune",
          type = "sdf_time_rune_hall_of_heroes",
          shape = "rectangle",
          x = 224,
          y = 368,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 95,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 128,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 96,
          name = "tree",
          type = "marsh_tree",
          shape = "rectangle",
          x = 320,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 97,
          name = "Professors Lab",
          type = "sdf_professors_lab",
          shape = "rectangle",
          x = 224,
          y = 40,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["data.typeid"] = "1"
          }
        }
      }
    }
  }
}
