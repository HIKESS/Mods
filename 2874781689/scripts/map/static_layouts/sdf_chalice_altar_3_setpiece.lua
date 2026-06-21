return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 1,
  height = 1,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ds-tiles-sw-dst",
      firstgid = 1,
      filename = "../../../../../../../../Program Files (x86)/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/ds-tiles-sw-dst.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../../../../Program Files (x86)/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/Tiled/dont_starve/ds-tiles-sw-dst.png",
      imagewidth = 512,
      imageheight = 448,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 1,
      height = 1,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "Chalice Altar",
          type = "sdf_chalice_altar",
          shape = "rectangle",
          x = 32,
          y = 32,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.sdf_chalice_id_key.chalice_id_key"] = "3"
          }
        }
      }
    }
  }
}
