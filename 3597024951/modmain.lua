GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

modimport("miao/jx_tuning")--模组配置表

local locale = GLOBAL.LOC.GetLocaleCode()
if locale == "zh" or locale == "zht" or locale=="zhr" then
  modimport("scripts/jxlanguages/jx_ch")--中文文本
else
  modimport("scripts/jxlanguages/jx_en")--英文文本
end

PrefabFiles = {
    --"jx_decor",         --装饰位点
    "jx_light",         --通用光源
    "jx_potted",        --盆栽
    "jx_tent",          --圆顶床
    "jx_chest",         --箱子
    "jx_chest_2",       --箱子
    "jx_cookpot",       --电煮锅
    "jx_icebox_fx",     --冰箱特效
    "jx_icebox_fx_2",   --冰箱特效
    "jx_icebox",        --电冰箱
    "jx_icebox_2",      --电冰箱
    "jx_icebox_big",    --北极熊冰柜
    "jx_fish_tank",     --鱼缸柜
    "jx_tv",            --电视机
    "jx_phonograph",    --电话机
    "jx_tapeplayer",    --磁带录音机
    "jx_wateringcan",   --浇水壶
    "jx_sofa",          --沙发、椅子
    "jx_mushroom_light",--路灯
    "jx_lamp",          --床头灯
    "jx_table",         --沙发桌
    "jx_furnace",       --暖炉
    "jx_wardrobe",      --衣柜
    "jx_sewingmachine", --缝纫机
    "jx_oven",          --烤箱
    "jx_table_2",       --餐桌
    "jx_rug",           --地毯
    "jx_turfs",         --地皮
    "jx_backpack",      --兔子背包
    "jx_backpack_2",    --兔子背包
    "jx_backpack_3",    --猫猫背包
    "jx_backpack_4",    --浣熊背包
    "jx_backpack_5",    --小鸡背包
    "jx_pack",          --便当包
    "jx_mailbox",       --信箱
    "jx_bathtub",       --浴缸
    "jx_hats",          --帽子
    "jx_hat_reindeer_fx",--驯鹿帽特效
    "jx_pan",           --平底锅(武器)
    "jx_weapon",        --厨具武器
    "jx_fan",           --电风扇
    "jx_well",          --水井
    "jx_washer",        --洗衣机
    "jx_toilet_suction",--马桶吸
    "jx_toaster",       --烤面包机
    "jx_basket",        --手工菜篮
    "jx_bookcase",      --展示柜
    "jx_icemaker",      --制冰机
    "jx_lantern_playerfx",--提灯特效
    "jx_lantern",       --提灯
    "jx_car",           --甲壳虫车
    "jx_car_key",       --汽车钥匙
    "jx_car_physics_collision", --汽车物理碰撞辅助
    "jx_parts",         --汽车配件
    "jx_car_mark",      --车辙
    "jx_car_explosion", --汽车爆炸特效
    "jx_gasoline",      --汽油
    "jx_rug_bag",       --地毯包
    "jx_walls",         --墙体
    "jx_fence",         --栅栏
    "jx_chesspieces",   --雕塑
    "jx_piano",         --钢琴
    "jx_fountain",      --喷泉
    "jx_fireplug",      --消防栓
    "jx_dress_form",    --人台
    "jx_saxophone",     --萨克斯
    "jx_cello",         --大提琴
    "jx_harp",          --竖琴
    "jx_cellar",        --地窖
    "jx_hay_cart",      --干草车
    "jx_handcart",      --手推车
    "jx_pickling_barrel",--腌制桶
    "jx_holy_sword",    --圣剑
    "jx_wood_bin",      --木柴箱
    "jx_wiki_book",     --指南书
    "jx_war_hoe",       --战锄
    "jx_mantel_clock",  --座钟
    "jx_flashlight",    --手电筒
    "jx_battery",       --电池
    "jx_portabletent",  --便携帐篷
    "jx_hanging_bed",   --吊床
    "jx_storage_basket",--收纳篮
    "jx_rock_bin",      --石料箱
    "jx_honey_box",     --蜜箱
    "jx_disassembler",  --拆解机
    "jx_cabinet",       --白展示柜
    "jx_can",           --罐头
    "jx_canner",        --罐头机
    "jx_charcoal_stove",--炭炉
    "jx_chester_house", --切斯特狗屋
    "jx_glommer_house", --格鲁姆树屋
    "jx_cat_tree",      --猫爬架
    "jx_colchicum",     --藤编花篮秋水仙
    "jx_portable_cook_pot",--便携烹饪锅
    "jx_baguette",      --法棍面包
    "jx_kebab",         --烤肉串
    "jx_trash_can",     --垃圾桶
    "jx_vending_machine",--售卖机
    "jx_bankatm",       --提款机
    "jx_farm_tools_container",--农具架
    "jx_frog_raincoat", --雨衣
}

modimport("scripts/jxmain/jx_assets")--美术资源
modimport("scripts/jxmain/jx_recipes")--制作栏配方
modimport("scripts/jxmain/jx_containers")--容器定义

modimport("scripts/stategraphs/SGjx_pan_for_wilson")--玩家状态机-平底锅
modimport("scripts/stategraphs/SGjx_car_for_wilson")--玩家状态机-汽车
modimport("scripts/stategraphs/SGjx_flashlight_for_wilson")--玩家状态机-手电筒
modimport("scripts/stategraphs/SGjx_bath_for_wilson")--玩家状态机-浴缸
modimport("scripts/stategraphs/SGjx_lamp_2_for_wilson")--玩家状态机-烛台
modimport("scripts/stategraphs/SGjx_hanging_bed_for_wilson")--玩家状态机-吊床
modimport("scripts/stategraphs/SGjx_drinks_for_wilson")--玩家状态机-饮料

modimport("miao/legion_pinkstaff")--棱镜幻化法杖兼容

modimport("miao/jx_turfs")--地皮定义
modimport("miao/jx_mailbox")--信箱
modimport("miao/jx_cookpot")--电煮锅食谱
modimport("miao/jx_chest")--兼容智能小木牌
modimport("miao/hightlight_container")--兼容showme中文版的容器高亮显示
modimport("miao/tradable")--可交易物品扩展
modimport("miao/jx_rug")--地毯相关
modimport("miao/fencerotator")--栅栏击剑旋转扩展
modimport("miao/action_strings")--动作加字符
modimport("miao/jx_bath")--浴缸相关
modimport("miao/jx_lamp_2")--烛台相关
modimport("miao/mandrake")--烤箱烹饪曼德拉草保护
modimport("miao/ice")--冰块加标签
modimport("miao/button")--按钮相关
modimport("miao/jx_car")--汽车的辅助文件
modimport("miao/jx_fireplug")--消防栓放置器辅助
modimport("miao/jx_piano")--钢琴的辅助文件
modimport("miao/jx_holy_sword")--圣剑的辅助文件
modimport("miao/jx_wiki_book")--指南书RPC
modimport("miao/antlionhat")--刮地皮头盔对超栈堆叠背包的兼容
modimport("miao/jx_flashlight")--手电筒的辅助文件
modimport("miao/jx_hanging_bed")--吊床的辅助文件
modimport("miao/jx_canner")--罐头机的辅助文件
modimport("miao/jx_icebox_big")--北极熊冰柜的辅助文件
modimport("miao/jx_backpack_5")--荷包蛋小鸡背包的辅助文件
modimport("miao/jx_baguette")--法棍面包的辅助文件
--modimport("miao/jx_trash_can")--垃圾桶的辅助文件
modimport("miao/jx_vending_machine_and_jx_drinks")--饮料售卖机和饮料的辅助文件
modimport("miao/jx_farm_tools_container")--农具架的辅助文件
modimport("miao/jx_refresh")--“清洗”组件
modimport("miao/jx_catcoin")--猫猫币辅助文件
modimport("miao/jx_frog_raincoat")--蛙蛙雨衣辅助文件
