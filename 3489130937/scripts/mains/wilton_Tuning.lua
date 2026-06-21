--- 威尔顿角色的基础数值与开局物品配置。
-- 所有与角色本体相关的数值都写入 TUNING，方便 prefab 等脚本统一读取，保证联机一致。
-- 注意：这里只负责声明数值，不包含任何行为逻辑。
 
-- 威尔顿的基础生命与理智上限。
TUNING.WILTONMOD_HEALTH = 100
TUNING.WILTONMOD_SANITY = 100

-- 为威尔顿在各种游戏模式下指定统一的开局物品列表。
-- 这里给的是骨心，用于绑定复活与角色特殊机制。
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WILTONMOD = {"wiltonmod_boneheart"}
-- 覆盖开局物品在物品栏中的图标资源，避免默认图集找不到贴图。
-- @field atlas string 图集 xml 路径
-- @field image string 贴图 tex 文件名
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["wiltonmod_boneheart"] = {
  atlas = "images/inventoryimages/wiltonmod_boneheart.xml",
  image = "wiltonmod_boneheart.tex",
}
