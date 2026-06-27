local is_chinese = locale == "zh" or locale == "zht" or locale=="zhr"

name = is_chinese and "景熹家居" or "JingXi Furniture"
description = is_chinese and 
[[
让你的庇护所充满生活感！
专为喜欢丰富基地生活的你而设计。
模组内有多款实用复古家电和家具，
让硬核生存多一份居家的温暖与便利！
美术、策划：B站画画的景熹
代码贡献：驯猫糕手

小提示：更新后如遇物品栏贴图混乱情况，
可能需要重新启动游戏以刷新美术资源
]]
or [[
Makes your shelter feel more alive ~~
Designed for players who enjoy rich base life.
Adds practical vintage appliances and furniture,
bringing warmth and convenience to hardcore survival!

If you're confused about config options,
please leave a message on the Workshop.
The author will reply as soon as possible.
You can also ask how to use mod items.
In-game English text translated by tool,
and the wiki is only available in Chinese.
Sorry for the inconvenience.

Author: Jing Xi, Illustrator from bilibili.
Code contributor: XunCat(A Chinese university student.)
]]

author = "B站画画的景熹|驯猫糕手"
version = "26.06.01"
api_version = 10
dst_compatible = true
client_only_mod = false
all_clients_require_mod = true
icon_atlas = "images/modicon.xml"
icon = "modicon.tex"
server_filter_tags = is_chinese and { "景熹家居", } or { "JingXi Furniture", }

--修复汽车搭载乘客时出现的bug
--修复装备蛙蛙雨衣时，右键使用浆果丛帽时出现动画不正常
--饮料物品播放饮用音效的时机 与动画更加匹配
--增加角色在 饮料物品增益结束时 的提示台词，内容为“回味无穷...”
--“厨房洗碗池”可作水源
--摩托车头盔

local function AddTitle(title) return {label = title, name = "", hover = "", options = { { description = "", data = 0 } }, default = 0} end
local function AddConfig(label, name, options, default, hover) return {label = label, name = name, options = options, default = default, hover = hover or ""} end
local function AddOptions(data, ispercent, opposite_desc)
  local options = {}
  for i = 1, #data do
    local val = data[i]
    local decs_val = opposite_desc and (1 - val) or val
    local desc = ispercent and (decs_val * 100).."%" or decs_val..""
    options[i] = {description = desc, data = val}
  end
  return options
end

local switch_ch = { {description = "开启", data = true }, {description = "关闭", data = false} }
local boolean_ch = { {description = "是", data = true}, {description = "否", data = false} }
local str1 = "减缓食物腐烂的速率"
local str2 = "减缓潮湿度上涨的速率"
local str3 = "减缓温度上升的速率"
local str4 = "减缓温度下降的速率"
local str5 = "减少受到的物理攻击"
local str6 = "护甲分担多少伤害后损坏"
local str7 = "修改背包内总共有多少个格子，推荐8或12，因为UI可以被填满\n旧存档在修改该项之前请先进入世界清空背包，以防删除物品"
local str8 = "开启后其中物品可以无限堆叠，在游戏中途关闭该项时\n不会删除已经突破堆叠的物品，但无法继续增加其堆叠数量"
local str9 = "开启时，具有与保鲜背包类似的功能"
local str10 = "关闭后，放入光电池、启迪碎片、孢子等物品时，\n只显示屏幕画面，不产生范围照明"
local str11 = "用于调整使用次数，电话机作祟复活多少次后破碎"
local str12 = "电风扇降低玩家体温的效率变为原来的百分之多少"
local str13 = "修改容器的格子数，旧存档在修改之前请清空容器，以防删除物品"
local str14 = "开启后，配方材料变为与原版冰箱一致"
local str15 = "按下按钮后，制冰机需要多少秒来完成制冰"
local str16 = "开启后移除配方中的巨鹿眼球，但仍然需要冰鲷鱼。\n若启用岛屿冒险补丁，则巨鹿眼球替换为虎鲨之眼。"
local str17 = "调整烹饪速度比普通锅的快多少，0%即是普通锅的速率"
local str18 = "调整缝纫机在使用多少次后损坏"
local str19 = "默认每给予缝纫机一个蜘蛛丝回复一次使用次数\n禁用后缝纫机不再接收蜘蛛丝"
local str20 = "开启后，配方材料变为原来的两倍"
local str21 = "修改人台容器的格子数，包括哥特洛丽塔人台\n旧存档在修改之前请清空人台，以防删除物品"
local str22 = "禁用后，靠近时不再恢复理智值"
local str23 = "用于调整浴缸回复玩家生命值与理智值的速率\n默认为5点/秒，可在0~5/秒之间调节"
local str24 = "用于调整浴缸中玩家每秒上涨多少点潮湿度"
local str25 = "调整浴缸在使用多少次后损坏"
local str26 = "默认每给予浴缸一个石砖回复一次使用次数\n禁用后不能再使用石砖修复浴缸"
local str27 = "调整最大照明时间，单位为天，可以参考原版提灯0.975天"
local str28 = "调整德古拉伯爵提灯攻击命中敌人后回血这一效果的冷却，单位为秒"
local str29 = "调整圣剑攻击命中敌人后回血这一效果的冷却，单位为秒"
local str30 = "减少受到的位面伤害"
local str31 = "地窖起始50%保鲜，默认最大生效35格，对应100%保鲜\n每格盐晶增加约1.42%保鲜，详细请浏览维基"
local str32 = "扩大灭火器百分之多少的检测范围，\n三个选项分别对应最终半径5、6、7格地皮。"
local str33 = "用于修改平底锅平a出暴击的概率\n暴击实际效果为造成一次武器攻击力的AOE"
local str34 = "开启后，平底锅攻击力大幅削弱，降低至10点\n但无耐久度，可像手杖那样一直使用"
local str35 = "用于调整撞击生物时的物理伤害，100%表示不做修改"
local str36 = "用于修改汽车的最大生命值"
local str37 = "用于修改每次使用自动修理机为汽车回复的生命值"
local str38 = "用于修改每次使用齿轮为汽车回复的生命值"
local str39 = "开启后，移除汽车配方中的火花柜"
local str40 = "用于修改加装引擎后汽车的最大速度，可以参考行牛为8单位每秒"
local str41 = "用于修改电视机的照明半径，单位为码，每四码为一地皮长度"
local str42 = "用于修改鱼缸的理智光环，单位为 san/分钟"
local str43 = "完全禁用汽车，包括物品栏配方、汽车配件、汽车代码等\n适用于电脑运行内存不足或卡顿的情况，正常请勿开启"
local str44 = "开启时，装备圣剑会显示“屠龙秘术”按钮UI\n“屠龙秘术”效果可移步wiki查看"
local str45 = "用于修改鉴赏模式下，钢琴音乐的音量大小"
local str46 = "用于修改自由演奏时，按下琴键播放的音量大小"
local str47 = "用于修改圣剑被装备和被卸下时的音效音量"
local str48 = "修改野餐篮内有多少个格子"
local str49 = "开启后可以在原版制作栏分类下找到景熹家居物品\n推荐打开：设置-高级-制作预览，选择所有配方，以便于了解物品排序"
local str50 = "用于修改汽车行驶时的引擎噪音音量，100%即为原音量"
local str51 = "开启后，烹饪好的食物在拿取前不腐烂"
local str52 = "默认情况下，角色移动方向与手电筒光照方向一致时加速，\n关闭后该无加速"
local str53 = "开启“岛屿冒险”模组时可启用此开关，\n将联机版的部分特有材料替换为海难物品。"
local str54 = "调整便携帐篷的使用次数。"
local str55 = "调整装备的理智光环大小，单位san/分钟，可以参考贝雷帽6.6san/分钟。"
local str56 = "调整拆解机一次拆解需要多少时间，单位为秒。"
local str57 = "调整拆解机在工作时的噪音大小。"
local str58 = "调整罐头机每次制造罐头耗时，单位为秒。"
local str59 = "该锅具是否可以制作大厨料理。关闭后与普通锅食谱一致。"
local str60 = "关闭时，厨房洗碗池无清洗食材的功能。"

local switch_en = { {description = "Enable", data = true }, {description = "Disable", data = false} }
local boolean_en = { {description = "Yes", data = true}, {description = "No", data = false} }
local str1_en = "Slows food spoilage rate."
local str2_en = "Slows moisture increase rate."
local str3_en = "Slows temperature increase rate."
local str4_en = "Slows temperature decrease rate."
local str5_en = "Reduces physical damage taken."
local str6_en = "Armor breaks after absorbing X damage."
local str7_en = "Changes its slots. Recommended 8 or 12 to fill the UI. Before changing this in an existing save, empty your backpack in-world to prevent item loss."
local str8_en = "When enabled, items in it can stack infinitely."
local str9_en = "When enabled, functions similarly to the Insulated Pack."
local str10_en = "When disabled, placing it only shows screen visuals without producing area lighting."
local str11_en = "Adjusts how many haunt revives before breaking."
local str12_en = "Fan cooling efficiency on player body temperature as a percentage of original."
local str13_en = "Changes container slot count. Before changing in an existing save, empty the container to prevent item loss."
local str14_en = "When enabled, recipe materials match the vanilla fridge."
local str15_en = "Seconds required for the ice maker to finish after pressing the button."
local str16_en = "When enabled, removes Deerclops Eyeball but still requires Ice Bream."
local str17_en = "Adjusts cooking speed compared to a regular pot. 0% equals normal pot speed."
local str18_en = "Adjusts how many uses before the sewing machine breaks."
local str19_en = "Default: each silk given restores one use. When disabled, the sewing machine no longer accepts Spider Webs."
local str20_en = "When enabled, recipe materials are doubled."
local str21_en = "Changes dress form slot count. Before changing in an existing save, empty the dress form to prevent item loss."
local str22_en = "When disabled, no longer restores Sanity when nearby."
local str23_en = "Adjusts bathtub health and sanity recovery rate. Default: 5/sec, range: 0–5/sec."
local str24_en = "Adjusts how much moisture increases per second while in the bathtub."
local str25_en = "Adjusts how many uses before the bathtub breaks."
local str26_en = "Default: each stone brick given restores one use. When disabled, stone bricks can no longer repair the bathtub."
local str27_en = "Adjusts max light duration in days. Reference: vanilla lantern lasts 0.975 days."
local str28_en = "Adjusts cooldown for Dracula's Lantern's health-on-hit effect, in seconds."
local str29_en = "Adjusts cooldown for Holy Sword's health-on-hit effect, in seconds."
local str30_en = "Reduces planar damage taken."
local str31_en = "Cellar starts at 50% freshness. Each 'Slot' Salt Crystals adds 1.42% freshness. Default max 35 slots for 100% freshness."
local str32_en = "Increases flingomatic range by X%."
local str33_en = "Adjusts critical hit chance for the pan. Critical hits deal weapon damage in an AOE."
local str34_en = "When enabled, pan damage is greatly reduced to 10, but has no durability and can be used indefinitely like a cane."
local str35_en = "Adjusts physical damage when colliding with creatures. 100% means no change."
local str36_en = "Adjusts maximum vehicle health."
local str37_en = "Adjusts health restored to vehicle per use of the Auto-Mat-O-Chanic."
local str38_en = "Adjusts health restored to vehicle per use of the gears."
local str39_en = "When enabled, removes Spark Ark from vehicle recipe."
local str40_en = "Adjusts maximum vehicle speed after engine installation. Reference: Beefalo moves at 8 units per second."
local str41_en = "Adjusts TV light radius in yards. Every 4 yards equals one turf tile."
local str42_en = "Adjusts fish tank sanity aura in X san/minute."
local str43_en = "Completely disables vehicles, including recipes, parts, and code."
local str44_en = "When disabled, Holy Sword no longer shows the Button UI, disabling related functions."
local str45_en = "Adjusts piano music volume in appreciation mode."
local str46_en = "Adjusts key press volume in free play mode."
local str47_en = "Adjusts Holy Sword equip/unequip sound volume."
local str48_en = "Adjusts number of slots in the picnic basket."
local str49_en = "When enabled, mod items appear in vanilla crafting tabs."
local str50_en = "Adjusts vehicle engine noise volume while driving. 100% is original volume."
local str51_en = "When enabled, cooked food does not spoil until taken."
local str52_en = "Default: Speed boost when moving in the same direction as the flashlight; no boost when off."
local str53_en = "Activate together with the 'Island Adventure' mod.\nReplace the unique materials of DST with shipwreck items."
local str54_en = "Adjust the usage frequency of the portable tent."
local str55_en = "Adjust the size of the equipment's sanity aura, unit san/minute."
local str56_en = "How long does it take to disassemble the dismantling machine in seconds."
local str57_en = "Adjust the noise level of the machine during operation."
local str58_en = "Adjust the canning machine to take seconds to produce cans each time."
local str59_en = "If enabled, this cookware can use Warly's recipes."
local str60_en = "When closed, Kitchen Sink does not have the function of cleaning food."

if is_chinese then
  configuration_options = 
  {
    AddTitle("-----------------------------------------"),
    AddTitle("小提示:模组默认配置仅作为维基配置"),
    AddTitle("玩家可以在此页面随意DIY喜欢的配置"),
    AddTitle("配置的顺序与维基列表顺序一一对应"),
    AddTitle("可对照维基描述和选项提示来斟酌修改"),
    AddTitle("如果需要其他选项，可在工坊留言添加"),
    AddTitle("-----------------------------------------"),
    
    AddTitle("制作栏配方分类"),
    AddConfig("融入原版制作分类", "jx_recipes_sort", switch_ch, false, str49),
    
    AddTitle("岛屿冒险补丁"),
    AddConfig("配方材料替换", "jx_island_switch", switch_ch, false, str53),
    
    AddTitle("手工编织野餐篮"),
    AddConfig("保鲜率", "jx_basket_preserver",       AddOptions({1,.95,.9,.85,.8,.75}, true, true), .85, str1),
    AddConfig("格子数量", "jx_basket_containerslot", AddOptions({4,9}),                             9,   str48),
    
    AddTitle("向日葵草帽"),
    AddConfig("防雨值", "jx_hat_sunflower_waterproofer", AddOptions({0,.1,.2,.3}, true), .3, str2),
    AddConfig("隔热值", "jx_hat_sunflower_insulator",    AddOptions({0,30,60,90,120}),   120, str3),
    
    AddTitle("墨西哥帽"),
    AddConfig("防雨值", "jx_hat_mexico_waterproofer", AddOptions({0,.1,.2,.3}, true),   .3,  str2),
    AddConfig("隔热值", "jx_hat_mexico_insulator",    AddOptions({0,30,60,90,120,150}), 150, str3),
    
    AddTitle("白玫瑰蕾丝礼帽"),
    AddConfig("防雨值", "jx_hat_white_rose_waterproofer",  AddOptions({0,.1,.2,.3}, true),       .3, str2),
    AddConfig("保暖值", "jx_hat_white_rose_insulator",     AddOptions({0,30,60,90,120}),         60,  str4),
    AddConfig("物理防御", "jx_hat_white_rose_armorabsorb", AddOptions({.6,.65,.7,.75,.8}, true), .8, str5),
    AddConfig("耐久度", "jx_hat_white_rose_armoramount",   AddOptions({225,270,315}),            315, str6),
    
    AddTitle("黑蔷薇格纹赫本帽"),
    AddConfig("防雨值", "jx_hat_hepburn_waterproofer", AddOptions({0,.1,.2,.3}, true), .3, str2),
    AddConfig("隔热值", "jx_hat_hepburn_insulator",    AddOptions({0,30,60,90,120}),   60, str3),
    
    AddTitle("驯鹿针织绒帽"),
    AddConfig("保暖值", "jx_hat_reindeer_insulator", AddOptions({30,60,90,120,150,180,210,240}), 240, str4),
    
    AddTitle("洛丽塔敏敏熊便当包"),
    AddConfig("保鲜率", "jx_pack_preserver", AddOptions({.5,.4,.3,.2}, true, true), .2, str1),
    
    AddTitle("洛丽塔野餐兔背包"),
    AddConfig("背包容量", "jx_backpack_containerslot", AddOptions({8,9,10,11,12}), 12,    str7),
    AddConfig("保暖值", "jx_backpack_insulator",       AddOptions({0,30,60}),      30,    str4),
    
    AddTitle("波奈特垂耳兔背包"),
    AddConfig("背包容量", "jx_backpack_2_containerslot", AddOptions({8,9,10,11,12}), 12,    str7),
    AddConfig("保暖值", "jx_backpack_2_insulator",       AddOptions({0,30,60}),      30,    str4),
    
    AddTitle("焦糖茶会猫背包"),
    AddConfig("背包容量", "jx_backpack_3_containerslot", AddOptions({8,9,10,11,12}), 8,    str7),
    AddConfig("保暖值", "jx_backpack_3_insulator",       AddOptions({0,30,60}),      30,   str4),
    AddConfig("超栈堆叠", "jx_backpack_3_stacksize",     switch_ch,                  true, str8),
    
    AddTitle("小浣熊有有玩偶包"),
    AddConfig("背包容量", "jx_backpack_4_containerslot", AddOptions({8,9,10,11,12}), 8,    str7),
    AddConfig("保暖值", "jx_backpack_4_insulator",       AddOptions({0,30,60}),      30,   str4),
    AddConfig("保鲜效果", "jx_backpack_4_preserver",     switch_ch,                  true, str9),
    
    AddTitle("荷包蛋小鸡背包"),
    AddConfig("背包容量", "jx_backpack_5_containerslot", AddOptions({8,9,10,11,12}), 8,    str7),
    
    AddTitle("波西米亚露营帐篷"),
    --AddConfig("使用次数", "jx_portabletent_uses", AddOptions({10,15,20}), 20, str54),
    AddConfig("使用次数", "jx_portabletent_uses", {{description="10",data=10},{description="15",data=15},{description="20",data=20},{description="无限",data=999}}, 20, str54),
    
    AddTitle("野营锅具"),
    AddConfig("可制作大厨料理", "jx_portable_cook_pot_recipes", boolean_ch, false, str59),
    
    AddTitle("狸猫陶土砂锅"),
    AddConfig("可制作大厨料理", "jx_portable_cook_pot_2_recipes", boolean_ch, false, str59),
    
    AddTitle("复古电视机"),
    AddConfig("允许照明", "jx_tv_lightenable", boolean_ch, true, str10),
    AddConfig("照明半径", "jx_tv_lightradius", AddOptions({2,3,5,7}), 5, str41),
    
    AddTitle("古典转盘电话机"),
    AddConfig("允许作祟复活", "jx_phonograph_hauntrez",   boolean_ch, true, nil),
    AddConfig("可作祟次数", "jx_phonograph_hauntrez_num", AddOptions({1,2,3}), 3, str11),
    
    AddTitle("复古传统电风扇"),
    AddConfig("降温效率", "jx_fan_cooling_efficiency", AddOptions({.2,.4,.6,.8,1,1.15}, true), 1, str12),
    
    AddTitle("磁带录音机"),
    AddConfig("照料农作物", "jx_tapeplayer_tend", switch_ch, true, nil),
    
    AddTitle("复古电冰箱"),
    AddConfig("冰箱容量", "jx_icebox_containerslot", AddOptions({9, 16}), 16, str13),
    AddConfig("配方简化", "jx_icebox_recipe",        switch_ch, false, str14),
    AddConfig("反鲜", "jx_icebox_reverse",           switch_ch, false, nil),
    
    AddTitle("沉睡熊小冰箱"),
    --AddConfig("保鲜率", "jx_icebox_2_preserver", AddOptions({.5,.4,.3}, true, true), .3, str1),
    AddConfig("配方简化", "jx_icebox_2_recipe",  switch_ch, false, str14),
    AddConfig("反鲜", "jx_icebox_2_reverse",     switch_ch, false, nil),
    
    AddTitle("北极熊冰柜"),
    AddConfig("反鲜", "jx_icebox_big_reverse", switch_ch, false, nil),
    
    AddTitle("欧罗巴制冰机"),
    AddConfig("制冰耗时", "jx_icemaker_worktime", AddOptions({5,30,480}), 5, str15),
    AddConfig("配方简化", "jx_icemaker_recipe",   switch_ch, false, str16),
    
    AddTitle("复古电煮锅"),
    AddConfig("烹饪加速", "jx_cookpot_cooktimemult", AddOptions({1,.95,.9,.85}, true, true), .85,   str17),
    AddConfig("收取前不腐烂", "jx_cookpot_spoil",    switch_ch,                              false, str51),
    
    AddTitle("复古橡木高压锅"),
    AddConfig("烹饪加速", "jx_cookpot_2_cooktimemult", AddOptions({1,.95,.9,.85, .8}, true, true), .8,    str17),
    AddConfig("收取前不腐烂", "jx_cookpot_2_spoil",    switch_ch,                                  false, str51),
    
    AddTitle("红宝石复古缝纫机"),
    AddConfig("使用次数", "jx_sewingmachine_finiteuses", AddOptions({5,10,30,60}), 60,   str18),
    AddConfig("蜘蛛丝修补", "jx_sewingmachine_silk",     boolean_ch,               true, str19),
    
    AddTitle("乌尔诺斯的拆解机"),
    AddConfig("使用次数", "jx_disassembler_finiteuses", AddOptions({3,5,10,20}), 5, nil),
    AddConfig("拆解耗时", "jx_disassembler_worktime",   AddOptions({5,30,480}),  5, str56),
    
    AddTitle("安德伍德罐头机"),
    AddConfig("制造耗时", "jx_canner_worktime", AddOptions({4,30,480}), 4, str58),
    
    AddTitle("复古枫叶木盒"),
    AddConfig("箱子容量", "jx_chest_containerslot", AddOptions({9,12}), 12, str13),
    AddConfig("造价翻倍", "jx_chest_recipe",        boolean_ch, false, str20),
    
    AddTitle("祖母绿宝石箱"),
    AddConfig("箱子容量", "jx_chest_2_containerslot", AddOptions({9,12}), 12, str13),
    AddConfig("造价翻倍", "jx_chest_2_recipe",        boolean_ch, false, str20),
    
    AddTitle("黑金燕尾服人台"),
    AddConfig("人台容量", "jx_dress_form_containerslot", AddOptions({1,9}), 9, str21),
    
    AddTitle("洛可可海缸柜"),
    AddConfig("理智光环", "jx_fish_tank_sanityaura", switch_ch, true, str22),
    AddConfig("光环大小", "jx_fish_tank_aurasize",   AddOptions({3,6,15,20}), 15, str42),
    
    AddTitle("巴洛克圆顶床"),
    AddConfig("无限次数", "jx_tent_uses", switch_ch, false, nil),
    
    AddTitle("巴洛克鎏金浴缸"), 
    AddConfig("回复速率", "jx_bathtub_efficiency", AddOptions({0,.2,.5,1,2,3,4,5}), 5,  str23),
    AddConfig("上涨潮湿度", "jx_bathtub_moisture", AddOptions({0,.2,.5,1,2,3,4,5}), 0,  str24),
    AddConfig("使用次数", "jx_bathtub_finiteuses", AddOptions({5,10,30,50}),        50, str25),
    AddConfig("石砖修补", "jx_bathtub_cutstone",   boolean_ch, true, str26),
    
    AddTitle("皇家贝希斯三角钢琴"),
    AddConfig("鉴赏模式音量", "jx_piano_volume1", AddOptions({.1,.2,.3,.4,.5,.6,.7,.8,.9,1}, true), 1,  str45),
    AddConfig("自由演奏音量", "jx_piano_volume2", AddOptions({.1,.2,.3,.4,.5,.6,.7,.8,.9,1}, true), .4, str46),
    
    AddTitle("恩利尔的战锄"),
    AddConfig("使用次数", "jx_war_hoe_finiteuses", AddOptions({100,150,200,249,300}), 300, nil),
    AddConfig("攻击力", "jx_war_hoe_planardamage", AddOptions({10,17,21,34}), 21, nil),
    
    AddTitle("复古亚历山大地窖"), 
    AddConfig("最大生效盐晶格数", "jx_cellar_maxsaltrock", AddOptions({6,12,18,24,30,35}), 35, str31),
    
    AddTitle("庄园琥珀蜜箱"), 
    AddConfig("保鲜率", "jx_honey_box_preserver", AddOptions({.5,.4,.35,.3,.25,.2}, true, true), .2, str1),
    
    AddTitle("复古室外消防栓"),
    AddConfig("扩大灭火器范围", "jx_fireplug_scale1", AddOptions({.34,.6,.87}, true), .34, str32),
    
    AddTitle("法式铸铁平底锅"),
    AddConfig("暴击概率", "jx_pan_aoe",      AddOptions({0,.2,.4,.6,.8,.9,.99,1}, true), .2, str33),
    AddConfig("坚硬无比", "jx_pan_eternity", switch_ch, false, str34),
    
    AddTitle("老式深厚的铁锅"),
    AddConfig("耐久度", "jx_hat_iron_pan_armoramount",   AddOptions({225,270,315}),            315, str6),
    AddConfig("物理防御", "jx_hat_iron_pan_armorabsorb", AddOptions({.6,.65,.7,.75,.8}, true), .8,  str5),
    AddConfig("防雨值", "jx_hat_iron_pan_waterproofer",  AddOptions({0,.1,.2,.3,.4,.5}, true), .5,  str2),
    
    AddTitle("刀叉勺铲"),
    AddConfig("使用次数", "jx_weapon_finiteuses", AddOptions({100,150,200,275}), 275, nil),
    AddConfig("攻击力", "jx_weapon_damage",       AddOptions({34,42,50,59}),     50,  nil),
    
    AddTitle("厨房洗碗池"),
    AddConfig("清洗食材", "jx_table_9_wash", switch_ch, true, str60),
    
    AddTitle("米勒的手电筒"), 
    AddConfig("前进加速", "jx_flashlight_fastspeed", switch_ch, true, str52),
    
    AddTitle("宝石玫瑰夜巡灯"), 
    AddConfig("照明时长", "jx_lantern_fuel", AddOptions({0.975,1,1.5,2.5,3.75}), 3.75, str27),
    
    AddTitle("古堡繁星提灯"), 
    AddConfig("照明时长", "jx_lantern_2_fuel", AddOptions({0.975,1,1.5,2.5,3.75}), 3.75, str27),
    
    AddTitle("德古拉伯爵提灯"), 
    AddConfig("照明时长", "jx_lantern_3_fuel",   AddOptions({0.975,1,1.5,2.5,3.75}), 3.75, str27),
    AddConfig("回复效果冷却", "jx_lantern_3_cd", AddOptions({10,15,20,30,50,120}),   10,   str28),
    
    AddTitle("齐格鲁德的圣剑"), 
    AddConfig("物理攻击力", "jx_holy_sword_weapondamage", AddOptions({17,34,42,51,68}),                       42,    nil),
    AddConfig("位面攻击力", "jx_holy_sword_planardamage", AddOptions({0,10,20,30}),                           30,    nil),
    AddConfig("使用次数", "jx_holy_sword_finiteuses",     AddOptions({75,100,150,180,200}),                   200,   nil),
    AddConfig("回复效果冷却", "jx_holy_sword_cd",         AddOptions({5,10,15,20,30,90}),                     5,     str29),
    AddConfig("圣剑UI", "jx_holy_sword_ui",               boolean_ch,                                         false, str44),
    AddConfig("装备音效音量", "jx_holy_sword_volume",     AddOptions({0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1}, true), 1,     str47),
    
    AddTitle("齐格鲁德的战盔"), 
    AddConfig("物理防御力", "jx_hat_sigurd_armorabsorb",   AddOptions({.8,.82,.85,.87,.9,.92,.95}, true), .95,  str5),
    AddConfig("位面防御力", "jx_hat_sigurd_planardefense", AddOptions({0,5,10}),                          5,    str30),
    AddConfig("耐久度", "jx_hat_sigurd_armoramount",       AddOptions({525,735,840,1050}),                1050, str6),
    AddConfig("防雨值", "jx_hat_sigurd_waterproofer",      AddOptions({0,.1,.2,.3}, true),                .2,   str2),
    
    AddTitle("复古甲壳虫汽车"),
    AddConfig("撞击伤害", "jx_car_damagemult",                AddOptions({.3,.5,.7,.9,1,1.1,1.2}, true), 1,     str35),
    AddConfig("汽车生命值", "jx_car_health",                  AddOptions({2000,3000,4000,5000,6000}),    4000,  str36),
    AddConfig("自动修理机修复量", "jx_wagpunkbitskit_repair", AddOptions({400,600,800,1000}),            1000,  str37),
    AddConfig("齿轮修复量", "jx_gears_repair",                AddOptions({100,200,400,600}),             400,   str38),
    AddConfig("配方简化", "jx_car_recipe",                    boolean_ch,                                false, str39),
    AddConfig("行驶噪音", "jx_car_drivenoise",                AddOptions({.3,.5,.7,.9,1,1.1,1.2}, true), 1,     str50),
    AddConfig("禁用汽车", "jx_car_disable",                   boolean_ch,                                false, str43),
    
    AddTitle("精密内燃机"),
    AddConfig("安装后速度", "jx_parts_engine", AddOptions({16,16.5,17,17.5,18,18.5,19,19.5,20,21,22,23,24,25,26}), 20, str40),
    
    AddTitle("游戏愉快~感谢赏玩"),
  }
else
  configuration_options = 
  {
    AddTitle("Recipes"),
    AddConfig("Integrated", "jx_recipes_sort", switch_en, false, str49_en),
    
    AddTitle("Island Adventure Patch"),
    AddConfig("Replace recipes materials", "jx_island_switch", switch_en, false, str53_en),
    
    AddTitle("Hand Woven Basket"),
    AddConfig("Preservation rate", "jx_basket_preserver", AddOptions({1,.95,.9,.85,.8,.75}, true, true), .85, str1_en),
    AddConfig("Slot count", "jx_basket_containerslot",    AddOptions({4,9}),                             9,   str48_en),
    
    AddTitle("Sunflower Straw Hat"),
    AddConfig("Rain resistance", "jx_hat_sunflower_waterproofer", AddOptions({0,.1,.2,.3}, true), .3, str2_en),
    AddConfig("Insulation value", "jx_hat_sunflower_insulator",   AddOptions({0,30,60,90,120}),   120, str3_en),
    
    AddTitle("Mexican Hat"),
    AddConfig("Rain resistance", "jx_hat_mexico_waterproofer", AddOptions({0,.1,.2,.3}, true),   .3,  str2_en),
    AddConfig("Insulation value", "jx_hat_mexico_insulator",   AddOptions({0,30,60,90,120,150}), 150, str3_en),
    
    AddTitle("White Rose Lace Top Hat"),
    AddConfig("Rain resistance", "jx_hat_white_rose_waterproofer", AddOptions({0,.1,.2,.3}, true),       .3, str2_en),
    AddConfig("Warmth value", "jx_hat_white_rose_insulator",       AddOptions({0,30,60,90,120}),         60,  str4_en),
    AddConfig("Physical defense", "jx_hat_white_rose_armorabsorb", AddOptions({.6,.65,.7,.75,.8}, true), .8, str5_en),
    AddConfig("Durability", "jx_hat_white_rose_armoramount",       AddOptions({225,270,315}),            315, str6_en),
    
    AddTitle("Black Rose Hepburn Hat"),
    AddConfig("Rain resistance", "jx_hat_hepburn_waterproofer", AddOptions({0,.1,.2,.3}, true), .3, str2_en),
    AddConfig("Insulation value", "jx_hat_hepburn_insulator",       AddOptions({0,30,60,90,120}),   60, str3_en),
    
    AddTitle("Reindeer Knitted"),
    AddTitle("Velvet Hat"),
    AddConfig("Warmth value", "jx_hat_reindeer_insulator", AddOptions({30,60,90,120,150,180,210,240}), 240, str4_en),
    
    AddTitle("Lolita Minmin"),
    AddTitle("Bear Bento Bag"),
    AddConfig("Preservation rate", "jx_pack_preserver", AddOptions({.5,.4,.3,.2}, true, true), .2, str1_en),
    
    AddTitle("Lolita Picnic"),
    AddTitle("Rabbit Backpack"),
    AddConfig("Backpack capacity", "jx_backpack_containerslot", AddOptions({8,9,10,11,12}), 12,    str7_en),
    AddConfig("Warmth value", "jx_backpack_insulator",          AddOptions({0,30,60}),      30,    str4_en),
    
    AddTitle("Bonnet Ear"),
    AddTitle("Rabbit Backpack"),
    AddConfig("Backpack capacity", "jx_backpack_2_containerslot", AddOptions({8,9,10,11,12}), 12,    str7_en),
    AddConfig("Warmth value", "jx_backpack_2_insulator",          AddOptions({0,30,60}),      30,    str4_en),
    
    AddTitle("Caramel Tea Party"),
    AddTitle("Cat Backpack"),
    AddConfig("Backpack capacity", "jx_backpack_3_containerslot", AddOptions({8,9,10,11,12}), 8,    str7_en),
    AddConfig("Warmth value", "jx_backpack_3_insulator",          AddOptions({0,30,60}),      30,   str4_en),
    AddConfig("Overstack", "jx_backpack_3_stacksize",             switch_en,                  true, str8_en),
    
    AddTitle("Little Raccoon"),
    AddTitle("YoYo Doll Backpack"),
    AddConfig("Backpack capacity", "jx_backpack_4_containerslot", AddOptions({8,9,10,11,12}), 8,    str7_en),
    AddConfig("Warmth value", "jx_backpack_4_insulator",          AddOptions({0,30,60}),      30,   str4_en),
    AddConfig("Preservation effect", "jx_backpack_4_preserver",   switch_en,                  true, str9_en),
    
    AddTitle("Pouch Egg Chicken Backpack"),
    AddConfig("Backpack capacity", "jx_backpack_5_containerslot", AddOptions({8,9,10,11,12}), 8,    str7_en),
    
    AddTitle("Bohemian Camping Tent"),
    AddConfig("Uses", "jx_portabletent_uses", AddOptions({10,15,20}), 20, str54_en),
    
    AddTitle("Camping Cookware"),
    AddConfig("Use Warly's recipe", "jx_portable_cook_pot_recipes", boolean_en, false, str59_en),
    
    AddTitle("Tanuki Pottery Clay Pot"),
    AddConfig("Use Warly's recipe", "jx_portable_cook_pot_2_recipes", boolean_en, false, str59_en),
    
    AddTitle("Vintage Television"),
    AddConfig("Allows lighting", "jx_tv_lightenable", boolean_en, true, str10_en),
    AddConfig("Light radius", "jx_tv_lightradius",    AddOptions({2,3,5,7}), 5, str41_en),
    
    AddTitle("Classical Rotary"),
    AddTitle("Dial Telephone"),
    AddConfig("Haunt to revive", "jx_phonograph_hauntrez",   boolean_en, true, nil),
    AddConfig("Haunt charges", "jx_phonograph_hauntrez_num", AddOptions({1,2,3}), 3, str11_en),
    
    AddTitle("Retro Electric Fan"),
    AddConfig("Cooling efficiency", "jx_fan_cooling_efficiency", AddOptions({.2,.4,.6,.8,1,1.15}, true), 1, str12_en),
    
    AddTitle("Tape Recorder"),
    AddConfig("Tends crops", "jx_tapeplayer_tend", switch_en, true, nil),
    
    AddTitle("Vintage Refrigerator"),
    AddConfig("Fridge capacity", "jx_icebox_containerslot", AddOptions({9, 16}), 16, str13_en),
    AddConfig("Recipe simplification", "jx_icebox_recipe",  switch_en, false, str14_en),
    AddConfig("Restore freshness", "jx_icebox_reverse",     switch_en, false, nil),
    
    AddTitle("Sleeping Bear Mini Fridge"),
    --AddConfig("Preservation rate", "jx_icebox_2_preserver",  AddOptions({.5,.4,.3}, true, true), .3, str1_en),
    AddConfig("Recipe simplification", "jx_icebox_2_recipe", switch_en, false, str14_en),
    AddConfig("Restore freshness", "jx_icebox_2_reverse",    switch_en, false, nil),
    
    AddTitle("Polar Bear Freezer"),
    AddConfig("Restore freshness", "jx_icebox_big_reverse", switch_en, false, nil),
    
    AddTitle("Europa Ice Maker"),
    AddConfig("Ice making time", "jx_icemaker_worktime",     AddOptions({5,30,480}), 5, str15_en),
    AddConfig("Recipe simplification", "jx_icemaker_recipe", switch_en, false, str16_en),
    
    AddTitle("Vintage Electric Hot Pot"),
    AddConfig("Cooking speed", "jx_cookpot_cooktimemult", AddOptions({1,.95,.9,.85}, true, true), .85,   str17_en),
    AddConfig("No spoil until taken", "jx_cookpot_spoil", switch_en,                              false, str51_en),
    
    AddTitle("Vintage Oak Rressure Pot"),
    AddConfig("Cooking speed", "jx_cookpot_2_cooktimemult", AddOptions({1,.95,.9,.85, .8}, true, true), .8,    str17_en),
    AddConfig("No spoil until taken", "jx_cookpot_2_spoil", switch_en,                                  false, str51_en),
    
    AddTitle("VintageSewingMachine"),
    AddConfig("Uses", "jx_sewingmachine_finiteuses",         AddOptions({5, 10, 30, 60}), 60, str18_en),
    AddConfig("Spider silk repair", "jx_sewingmachine_silk", boolean_en, true, str19_en),
    
    AddTitle("Uranus Disassembler"),
    AddConfig("Uses", "jx_disassembler_finiteuses",           AddOptions({3,5,10, 20}), 5, nil),
    AddConfig("Disassembly time", "jx_disassembler_worktime", AddOptions({5,30,480}),   5, str56_en),
    
    AddTitle("Underwood Canning Machine"),
    AddConfig("Production time", "jx_canner_worktime", AddOptions({4,30,480}), 4, str58_en),
    
    AddTitle("Vintage Maple Leaf"),
    AddTitle("Wooden Box"),
    AddConfig("Chest capacity", "jx_chest_containerslot", AddOptions({9,12}), 12, str13_en),
    AddConfig("Doubled cost", "jx_chest_recipe",          boolean_en, false, str20_en),
    
    AddTitle("Emerald Gem Chest"),
    AddConfig("Chest capacity", "jx_chest_2_containerslot", AddOptions({9,12}), 12, str13_en),
    AddConfig("Doubled cost", "jx_chest_2_recipe",          boolean_en, false, str20_en),
    
    AddTitle("Black Gold Tuxedo"),
    AddTitle("Dress Form"),
    AddConfig("Dress form capacity", "jx_dress_form_containerslot", AddOptions({1,9}), 9, str21_en),
    
    AddTitle("Rococo Fish Tank Cabinet"),
    AddConfig("Sanity aura", "jx_fish_tank_sanityaura", switch_en, true, str22_en),
    AddConfig("Aura value", "jx_fish_tank_aurasize",    AddOptions({3,6,15,20}), 15, str42_en),
    
    AddTitle("Baroque Dome Bed"),
    AddConfig("Unlimited Uses", "jx_tent_uses", switch_en, false, nil),
    
    AddTitle("Baroque Gilded Bathtub"), 
    AddConfig("Recovery rate", "jx_bathtub_efficiency",    AddOptions({0,.2,.5,1,2,3,4,5}), 5,  str23_en),
    AddConfig("Increases moisture", "jx_bathtub_moisture", AddOptions({0,.2,.5,1,2,3,4,5}), 0,  str24_en),
    AddConfig("Uses", "jx_bathtub_finiteuses",             AddOptions({5, 10, 30, 50}),     50, str25_en),
    AddConfig("Stone brick repair", "jx_bathtub_cutstone", boolean_en, true, str26_en),
    
    AddTitle("Royal Bechstein Grand Piano"),
    AddConfig("Volume of appreciation mode", "jx_piano_volume1", AddOptions({.1,.2,.3,.4,.5,.6,.7,.8,.9,1}, true), 1,  str45_en),
    AddConfig("Volume of free play mode", "jx_piano_volume2",    AddOptions({.1,.2,.3,.4,.5,.6,.7,.8,.9,1}, true), .4, str46_en),
    
    AddTitle("Enlil's War Hoe"),
    AddConfig("Uses", "jx_war_hoe_finiteuses",            AddOptions({100,150,200,249,300}), 300, nil),
    AddConfig("Attack damage", "jx_war_hoe_planardamage", AddOptions({10,17,21,34}), 21, nil),
    
    AddTitle("Vintage Alexander Cellar"), 
    AddConfig("Max Active Salt Crystals Slots", "jx_cellar_maxsaltrock", AddOptions({6,12,18,24,30,35}), 35, str31_en),
    
    AddTitle("Manor Amber Honey Box"), 
    AddConfig("Preservation rate", "jx_honey_box_preserver", AddOptions({.5,.4,.35,.3,.25,.2}, true, true), .2, str1_en),
    
    AddTitle("Outdoor Fireplug"),
    AddConfig("Extends flingomatic range", "jx_fireplug_scale1", AddOptions({.34,.6,.87}, true), .34, str32_en),
    
    AddTitle("French Cast Iron Pan"),
    AddConfig("Critical hit chance", "jx_pan_aoe", AddOptions({0,.2,.4,.6,.8,.9,.99,1}, true), .2, str33_en),
    AddConfig("Extremely hard", "jx_pan_eternity", switch_en, false, str34_en),
    
    AddTitle("OldStyle Iron Pot"),
    AddConfig("Durability", "jx_hat_iron_pan_armoramount",       AddOptions({225,270,315}),            315, str6_en),
    AddConfig("Physical defense", "jx_hat_iron_pan_armorabsorb", AddOptions({.6,.65,.7,.75,.8}, true), .8,  str5_en),
    AddConfig("Rain resistance", "jx_hat_iron_pan_waterproofer", AddOptions({0,.1,.2,.3,.4,.5}, true), .5,  str2_en),
    
    AddTitle("Fork Knife Spoon Wine"),
    AddConfig("Uses", "jx_weapon_finiteuses",      AddOptions({100,150,200,275}), 275, nil),
    AddConfig("Attack damage", "jx_weapon_damage", AddOptions({34,42,50,59}),     50,  nil),
    
    AddTitle("Kitchen Sink"),
    AddConfig("Wash food", "jx_table_9_wash", switch_en, true, str60_en),
    
    AddTitle("Miller's Flashlight"), 
    AddConfig("Forward acceleration", "jx_flashlight_fastspeed", switch_en, true, str52_en),
    
    AddTitle("Gemstone Rose Night"), 
    AddTitle("Patrol Light"), 
    AddConfig("Light duration", "jx_lantern_fuel", AddOptions({0.975,1,1.5,2.5,3.75}), 3.75, str27_en),
    
    AddTitle("Ancient Castle Stars Lantern"), 
    AddConfig("Light duration", "jx_lantern_2_fuel", AddOptions({0.975,1,1.5,2.5,3.75}), 3.75, str27_en),
    
    AddTitle("Count Dracula's Lantern"), 
    AddConfig("Light duration", "jx_lantern_3_fuel", AddOptions({0.975,1,1.5,2.5,3.75}), 3.75, str27_en),
    AddConfig("Heal cooldown", "jx_lantern_3_cd",    AddOptions({10,15,20,30,50,120}),   10,   str28_en),
    
    AddTitle("The Holy Sword of Sigurd"), 
    AddConfig("Physical attack", "jx_holy_sword_weapondamage",  AddOptions({17,34,42,51,68}),                       42,    nil),
    AddConfig("Planar attack", "jx_holy_sword_planardamage",    AddOptions({0,10,20,30}),                           30,    nil),
    AddConfig("Uses", "jx_holy_sword_finiteuses",               AddOptions({75,100,150,180,200}),                   200,   nil),
    AddConfig("Heal cooldown", "jx_holy_sword_cd",              AddOptions({5,10,15,20,30,90}),                     5,     str29_en),
    AddConfig("UI", "jx_holy_sword_ui",                         boolean_en,                                         false, str44_en),
    AddConfig("Equipment sound volume", "jx_holy_sword_volume", AddOptions({0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1}, true), 1,     str47_en),
    
    AddTitle("Sigurd's BattleHelmet"), 
    AddConfig("Physical defense", "jx_hat_sigurd_armorabsorb", AddOptions({.8,.82,.85,.87,.9,.92,.95}, true), .95,  str5_en),
    AddConfig("Planar defense", "jx_hat_sigurd_planardefense", AddOptions({0,5,10}),                          5,    str30_en),
    AddConfig("Durability", "jx_hat_sigurd_armoramount",       AddOptions({525,735,840,1050}),                1050, str6_en),
    AddConfig("Rain resistance", "jx_hat_sigurd_waterproofer", AddOptions({0,.1,.2,.3}, true),                .2,   str2_en),
    
    AddTitle("Retro Beetle Car"),
    AddConfig("Impact damage", "jx_car_damagemult",                       AddOptions({.3,.5,.7,.9,1,1.1,1.2}, true), 1,     str35_en),
    AddConfig("Vehicle health", "jx_car_health",                          AddOptions({2000,3000,4000,5000,6000}),    4000,  str36_en),
    AddConfig("Gear repair amount", "jx_gears_repair",                    AddOptions({100,200,400,600}),             400,   str38_en),
    AddConfig("AutoMatOChanic repair amount", "jx_wagpunkbitskit_repair", AddOptions({400,600,800,1000}),            1000,  str37_en),
    AddConfig("Recipe simplification", "jx_car_recipe",                   boolean_en,                                false, str39_en),
    AddConfig("Engine noise", "jx_car_drivenoise",                        AddOptions({.3,.5,.7,.9,1,1.1,1.2}, true), 1,     str50_en),
    AddConfig("Disable vehicle", "jx_car_disable",                        boolean_en,                                false, str43_en),
    
    AddTitle("Precision Combustion"),
    AddTitle("Engine"),
    AddConfig("Installed speed", "jx_parts_engine", AddOptions({16,16.5,17,17.5,18,18.5,19,19.5,20,21,22,23,24,25,26}), 20, str40_en),
    
    AddTitle("Thanks for playing~"),
    AddTitle("With your friendly"),
    AddTitle("support, no amount of"),
    AddTitle("work is too much."),
  }
end