--- 威尔顿模组的字符串与音效配置表。
-- 负责角色名片、物品名称与配方描述、技能树说明，以及角色语音事件的音效重映射。
-- 行为逻辑在其他脚本中实现，这里仅提供显示与声音资源的映射，便于本地化维护。

STRINGS.CHARACTER_TITLES.wiltonmod = "诅咒遗骸" 
STRINGS.CHARACTER_NAMES.wiltonmod = "威尔顿" 
STRINGS.CHARACTER_DESCRIPTIONS.wiltonmod = "*是一具被诅咒的骷髅。\n*被怪物视作同类。\n*不畏惧黑暗和幽灵。\n*死人不会再死一次。\n*掌握死灵法术，拥有自己的骷髅大军。"
STRINGS.CHARACTER_QUOTES.wiltonmod = "\"Aaaaaaaa…\""

STRINGS.NAMES.wiltonmod = "威尔顿"
STRINGS.SKIN_NAMES.wiltonmod_none = "威尔顿" 

STRINGS.SKIN_NAMES.wiltonmod_skin1_none = "凋零骷髅"
STRINGS.SKIN_QUOTES['wiltonmod_skin1_none'] = "\"咔，咔，咔…\""
STRINGS.SKIN_DESCRIPTIONS.wiltonmod_skin1_none = "威尔顿是一个黑色骷髅战士。"

STRINGS.SKIN_NAMES.wiltonmod_scarecrow_none = "复活稻草人"
STRINGS.SKIN_QUOTES['wiltonmod_scarecrow_none'] = "\"呃……啊……\""
STRINGS.SKIN_DESCRIPTIONS.wiltonmod_scarecrow_none = "威尔顿化身成一个被诅咒的稻草人。"

STRINGS.CHARACTERS.WILTONMOD = require "speech_wiltonmod" 
STRINGS.CHARACTER_SURVIVABILITY.wiltonmod = "无"

STRINGS.ACTIONS.CASTAOE.WILTONMOD_STAFF1 = "死者苏生"
STRINGS.ACTIONS.CASTAOE.WILTONMOD_STAFF2 = "骨刺囚笼"
-- 针对骨杖技能 recover 的通用 CASTAOE 文本，用于跨法杖显示“死者复生”
STRINGS.ACTIONS.CASTAOE.WILTONMOD_STAFF_RECOVER = "死者复生"
--STRINGS.ACTIONS.CASTAOE.WILTONMOD_STAFF3 = "死者苏生"

STRINGS.NAMES.WILTONMOD_PET = "骷髅兵"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_PET = "令人毛骨悚然。"

STRINGS.RECIPE_DESC.BONESHARD = "记得给自己留一点。"
STRINGS.RECIPE_DESC.FOSSIL_PIECE = "骨代的化石。"
STRINGS.RECIPE_DESC.SKELETON = "只是一具骷髅，和其他的一样。"

STRINGS.NAMES.WILTON_RESURRECTIONGRAVE = "复生墓碑"
STRINGS.RECIPE_DESC.WILTON_RESURRECTIONGRAVE = "亡者的墓志铭，附带一些陪葬品。"

STRINGS.NAMES.WILTON_DUG_GRAVESTONE = "复生墓碑"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTON_DUG_GRAVESTONE = "可以重新立起一座复生墓碑。"

-- 骨架配方皮肤：稻草人（scarecrow2）在合成界面中的显示名称。
STRINGS.SKIN_NAMES.scarecrow2 = "稻草人"
-- 稻草人实体在世界中的检查名称，统一显示为“稻草人”。
STRINGS.NAMES.SCARECROW2 = "稻草人"

STRINGS.NAMES.WILTONMOD_PACK = "死人宝箱"
STRINGS.RECIPE_DESC.WILTONMOD_PACK = "死者的陪葬品。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_PACK = "听说拿走它的金币会受到诅咒。"

STRINGS.NAMES.WILTONMOD_CHEST = "骷髅箱"
STRINGS.RECIPE_DESC.WILTONMOD_CHEST = "死者的宝箱。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_CHEST = "头骨显然不适合储存食物。"

STRINGS.NAMES.UNDEAD_ARMORY = "亡灵军械库"
STRINGS.RECIPE_DESC.UNDEAD_ARMORY = "亡者的武器库。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.UNDEAD_ARMORY = "这里存放着亡者的武器。"

STRINGS.NAMES.WILTONMOD_BONEHEART = "骨心"
STRINGS.RECIPE_DESC.WILTONMOD_BONEHEART = "刻骨铭心。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_BONEHEART = "我想它能够骨惑人心。"

STRINGS.NAMES.WILTONMOD_BONEHEART_SKIN = "稻草之心"
STRINGS.SKIN_NAMES.wiltonmod_boneheart_skin = "稻草之心" 
STRINGS.RECIPE_DESC.WILTONMOD_BONEHEART_SKIN = "还在跳动的骨制心脏。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_BONEHEART_SKIN = "看上去有点过于鲜活了。"

STRINGS.NAMES.WILTONMOD_BONEPASTE = "骨质修复液"
STRINGS.RECIPE_DESC.WILTONMOD_BONEPASTE = "骨生物技术。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_BONEPASTE = "让人脱胎换骨。"

STRINGS.NAMES.WILTONMOD_SHOOT = "投掷骨"
STRINGS.RECIPE_DESC.WILTONMOD_SHOOT = "最原始的远程攻击。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_SHOOT = "非常骨老的把戏。"

STRINGS.NAMES.WILTONMOD_SHOOT_SKIN = "骨头回旋镖"
STRINGS.SKIN_NAMES.wiltonmod_shoot_skin = "骨头回旋镖" 
STRINGS.RECIPE_DESC.WILTONMOD_SHOOT_SKIN = "最原始的远程攻击。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_SHOOT_SKIN = "非常骨老的把戏。"

STRINGS.NAMES.WILTONMOD_SHARPBONE = "尖骨头"
STRINGS.RECIPE_DESC.WILTONMOD_SHARPBONE = "用尖的那一端攻击。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_SHARPBONE = "“贱”骨头。"

STRINGS.NAMES.WILTONMOD_SHARPBONE_SKIN = "碎骨矛"
STRINGS.SKIN_NAMES.wiltonmod_sharpbone_skin = "碎骨矛" 
STRINGS.RECIPE_DESC.WILTONMOD_SHARPBONE_SKIN = "用折断的骨矛重新打磨出的武器。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_SHARPBONE_SKIN = "看起来比本体更适合捅人。"

STRINGS.NAMES.WILTONMOD_SHARPBONE_STONESWORD = "石剑"
STRINGS.SKIN_NAMES.wiltonmod_sharpbone_stonesword = "石剑" 
STRINGS.RECIPE_DESC.WILTONMOD_SHARPBONE_STONESWORD = "由碎骨与岩石拼合而成的沉重石剑。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_SHARPBONE_STONESWORD = "看起来比骨头更结实，也更适合砍劈。"

STRINGS.NAMES.WILTONMOD_BONEHAMMER = "大骨棒"
STRINGS.RECIPE_DESC.WILTONMOD_BONEHAMMER = "将你的敌人粉身碎骨。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_BONEHAMMER = "这棒子透露着一种原始感。"

STRINGS.NAMES.WILTONMOD_BONEHAMMER_SKIN = "化石骨棒"
STRINGS.SKIN_NAMES.wiltonmod_bonehammer_skin = "化石骨棒" 
STRINGS.RECIPE_DESC.WILTONMOD_BONEHAMMER_SKIN = "由化石骨架打造成的重型武器。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_BONEHAMMER_SKIN = "看起来比原版更适合砸碎一切。"

STRINGS.NAMES.WILTONMOD_ARMOR = "灵魂帷幕"
STRINGS.RECIPE_DESC.WILTONMOD_ARMOR = "生命在死亡的镜面中照见永恒。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_ARMOR = "让所有生命拥抱死亡。"

STRINGS.NAMES.WILTONMOD_HAT = "无名王冠"
STRINGS.RECIPE_DESC.WILTONMOD_HAT = "死亡是一切生命的终点。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_HAT = "是生命就会死亡。"

STRINGS.NAMES.WILTONMOD_STAFF1 = "骨杖"
STRINGS.RECIPE_DESC.WILTONMOD_STAFF1 = "生命的起点与终点。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_STAFF1 = "生命将为我所用。"

STRINGS.NAMES.WILTONMOD_STAFF1_SKIN = "绝望石骨杖"
STRINGS.SKIN_NAMES.wiltonmod_staff1_skin = "绝望石骨杖" 
STRINGS.RECIPE_DESC.WILTONMOD_STAFF1_SKIN = "以绝望之石重塑的骨杖。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_STAFF1_SKIN = "看上去连光都不愿靠近。"

STRINGS.NAMES.WILTONMOD_STAFF2 = "死亡权杖"
STRINGS.RECIPE_DESC.WILTONMOD_STAFF2 = "死亡是生命的一部分。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_STAFF2 = "我感受到了死亡的权能。"

STRINGS.NAMES.WILTONMOD_STAFF2_SKIN = "绝望石权杖"
STRINGS.SKIN_NAMES.wiltonmod_staff2_skin = "绝望石权杖" 
STRINGS.RECIPE_DESC.WILTONMOD_STAFF2_SKIN = "由绝望之石强化的死亡权杖。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_STAFF2_SKIN = "就连影子都显得更沉重了。"

STRINGS.NAMES.WILTONMOD_STAFF3 = "苏生权杖"
STRINGS.RECIPE_DESC.WILTONMOD_STAFF3 = "活着的终局。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_STAFF3 = "和死亡完美融合的另一面。"

STRINGS.NAMES.WILTONMOD_STAFF3_SKIN = "死亡亮茄杖"
STRINGS.SKIN_NAMES.wiltonmod_staff3_skin = "死亡亮茄杖" 
STRINGS.RECIPE_DESC.WILTONMOD_STAFF3_SKIN = "被打磨用于庄严仪式的苏生权杖。"  
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WILTONMOD_STAFF3_SKIN = "比原本更像一件献祭用圣物。"

--- 威尔顿在角色选择界面等处使用的“咯咯”骨头语音占位文本。
-- 实际播放的是配套的音效，这里仅作为文本备用或调试显示。
TUNING.WILTONMOD_SAYINGS =
{
    "咯...咯...咯...",
    "咔...嗒...咔...嗒...",
    "锵...锵...",
    "呃...呃呃...",
    "锵...锵...",
    "咔…咔咔…"
}  

--- 技能树界面中，用于显示暗影/月亮阵营专精说明的提示文本。
-- 仅负责 UI 展示，具体伤害与减伤效果在 skilltree_wiltonmod.lua 中实现。
STRINGS.SKILLTREE.WILTON = {
   WILTON_ALLEGIANCE_SHADOW_DESC = "【暗影亲和】学会制作【死亡权杖】\n威尔顿对月亮生物造成额外10%伤害，受到暗影生物伤害-10%", 
   WILTON_ALLEGIANCE_LUNAR_DESC  = "【月亮亲和】学会制作【复生权杖】\n威尔顿对暗影生物造成额外10%伤害，受到月亮生物伤害-10%",
   PANEL_SKILL1_TITLE = "骨头特性",
   PANEL_SKILL2_TITLE = "不死族工艺",
   PANEL_SKILL3_TITLE = "死灵巫术",
   SKILL1_1_TITLE = "空心骨1级",
   SKILL1_1_DESC  = "威尔顿只剩一副骸骨，跑的比一般角色快一点，移动速度1.1。",
   SKILL1_2_TITLE = "空心骨2级",
   SKILL1_2_DESC  = "威尔顿跑的更快，移动速度1.25。",
   SKILL1_3_TITLE = "空心骨3级",
   SKILL1_3_DESC  = "威尔顿身体很轻，可以在水面上奔跑，但潮湿度会不断上涨，在潮湿度达到峰值时会落水。",
   SKILL1_4_TITLE = "骨质强化1级",
   SKILL1_4_DESC  = "骨头不会导电，威尔顿获得100%防雷能力。",
   SKILL1_5_TITLE = "骨质强化2级",
   SKILL1_5_DESC  = "威尔顿免疫潮湿掉理智影响，武器不会脱手。",
   SKILL1_6_TITLE = "骨质强化3级",
   SKILL1_6_DESC  = "温度对骨头的影响微乎其微，威尔顿免疫过冷过热，体温恒定30度。",
   SKILL1_LOCK1_DESC = "（学习3项骨头特性技能后解锁）",
   SKILL1_7_TITLE    = "钢筋铁骨",
   SKILL1_7_DESC     = "威尔顿的骨质更加坚硬，获得40%减伤，背重物不再掉血。",
   SKILL2_1_TITLE = "掘墓者",
   SKILL2_1_DESC  = "可以徒手挖坟，挖坟不会损失理智。",
   SKILL2_2_TITLE = "亡灵指挥家1级",
   SKILL2_2_DESC  = "学会制作【骨杖】，移速+20%，可以消耗理智一键复活大范围的骷髅。",
   SKILL2_5_TITLE = "亡灵指挥家2级",
   SKILL2_5_DESC  = "骨杖的【死者苏生】技能可以为范围内的骷髅兵回满生命值。",
   SKILL2_6_TITLE = "亡灵指挥家3级",
   SKILL2_6_DESC  = "骨杖可以打开技能轮盘，更精细的控制骷髅行为，拥有待机，跟随，战斗，工作等指令。",
   SKILL2_3_TITLE = "乱葬岗1级",
   SKILL2_3_DESC  = "学会制作【复生墓碑】可以制造等同于墓碑的复制品，每个墓碑都会附带一个坟墓，可以用铲子移动墓碑位置，坟墓也会跟着一起移动，但移动后会变为挖开状态。",
   SKILL2_7_TITLE = "乱葬岗2级",
   SKILL2_7_DESC  = "当世界中有学会此技能的威尔顿时，每逢满月会将世界上所有已挖开的坟墓重置为未挖状态，并重新刷新陪葬品。",
   SKILL2_8_TITLE = "乱葬岗3级",
   SKILL2_8_DESC  = "当世界中有学会此技能的威尔顿时，其他玩家的幽灵可以作祟未挖开的坟墓在原地复活，玩家可以作祟坟墓复活，恢复一半三维，但坟墓会变为挖开状态，不会掉落陪葬品。",
   SKILL2_4_TITLE  = "骷髅军团1级",
   SKILL2_4_DESC   = "学会制作【亡灵军械库】可以消耗木头和燧石自动为骷髅提供临时的长矛，木甲和橄榄球头盔。",
   SKILL2_9_TITLE  = "骷髅军团2级",
   SKILL2_9_DESC   = "亡灵军械库可以放入噩梦燃料，可以消耗6个噩梦燃料制作暗夜甲和高礼帽。",
   SKILL2_10_TITLE = "骷髅军团3级",
   SKILL2_10_DESC  = "亡灵军械库可以消耗4个噩梦燃料制作暗夜剑。",
   SKILL2_12_TITLE = "骷髅巫术1级",
   SKILL2_12_DESC  = "学会制作【无名王冠】拥有骨头头盔的所有功能，可以自由开关骨头头盔功能，90%防御，可以使用噩梦燃料修复。",
   SKILL2_13_TITLE = "骷髅巫术2级",
   SKILL2_13_DESC  = "无名王冠增加能力，穿戴时会使所有骷髅兵不会消耗装备耐久。",
   SKILL2_14_TITLE = "骷髅巫术3级",
   SKILL2_14_DESC  = "无名王冠增加能力，穿戴时会使所有骷髅兵拥有限伤的能力，骷髅兵单次受伤不会超过10点。",
   SKILL2_15_TITLE = "亡灵巫术1级",
   SKILL2_15_DESC  = "学会制作【灵魂帷幕】拥有骨头盔甲的所有功能，40位面防御，可以使用噩梦燃料修复。",
   SKILL2_16_TITLE = "亡灵巫术2级",
   SKILL2_16_DESC  = "灵魂帷幕增加能力，穿戴时会使所有骷髅兵获得每10秒一次的骨甲护盾。",
   SKILL2_17_TITLE = "亡灵巫术3级",
   SKILL2_17_DESC  = "灵魂帷幕增加能力，穿戴时会周期性为所有骷髅兵回复生命，每5秒回复5生命值。",
   SKILL2_18_TITLE = "灵魂出窍",
   SKILL2_18_DESC  = "让你的灵魂获得自由，右键自身可以灵魂出窍，在原地留下一副不会被摧毁的骷髅，可以像幽灵一样自由移动，作祟物体，再次右键自身可以返回骨架中。灵魂状态下被给予告密的心，作祟复活道具不会产生任何效果。",
   SKILL3_LOCK1_DESC = "（学习12项技能解锁）",
  }

--- 威尔顿通用提示文本，供多处逻辑复用。
STRINGS.WILTONMOD_MESSAGES = STRINGS.WILTONMOD_MESSAGES or {}
STRINGS.WILTONMOD_MESSAGES.DENY_SLEEP = "绝对不行！！"
STRINGS.WILTONMOD_MESSAGES.SANITY_NOT_ENOUGH = "精神不足"
STRINGS.WILTONMOD_MESSAGES.SKILL_COOLDOWN = "技能正在CD中"

--- 自定义动作的中文显示文本。
STRINGS.ACTIONS.PICK_WILTON_PET = "捡起骷髅宠物"
STRINGS.ACTIONS.RUMMAGE_WILTON = STRINGS.ACTIONS.RUMMAGE

-- 覆写 USESPELLBOOK 动作的通用提示，将默认的“阅读”改为“技能”，用于骨杖技能轮盘。
STRINGS.ACTIONS.USESPELLBOOK = STRINGS.ACTIONS.USESPELLBOOK or {}
STRINGS.ACTIONS.USESPELLBOOK.GENERIC = "技能"

--[[
local oldGetDescription = GLOBAL.GetDescription
GLOBAL.GetDescription = function(inst, item, modifier)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    if character and character == "wiltonmod" and item and item:HasTag("player") then
		return "123"
	else
		return oldGetDescription(inst, item, modifier)
	end
end
]]

--- 将角色的语音事件重定向到自定义音效包。
-- 通过 RemapSoundEvent 把 Klei 默认路径映射到模组自带的 .fev/.fsb 声音资源。
RemapSoundEvent( "dontstarve/characters/wiltonmod/talk_LP", "wiltonmod/characters/wiltonmod/talk_LP" )
RemapSoundEvent( "dontstarve/characters/wiltonmod/hurt", "wiltonmod/characters/wiltonmod/hurt" )
RemapSoundEvent( "dontstarve/characters/wiltonmod/death_voice", "wiltonmod/characters/wiltonmod/death_voice") 
	
RemapSoundEvent( "dontstarve/characters/wiltonmod/emote", "wilton_sound/wilton_sound/emote" )
RemapSoundEvent( "dontstarve/characters/wiltonmod/yawn", "wiltonmod/characters/wiltonmod/yawn" )
--RemapSoundEvent( "dontstarve/characters/wiltonmod/pose", "wiltonmod/characters/wiltonmod/pose" )
RemapSoundEvent( "dontstarve/characters/wiltonmod/pose", "wilton_sound/wilton_sound/emote" )
RemapSoundEvent( "dontstarve/characters/wiltonmod/carol", "wilton_sound/wilton_sound/carol" )
