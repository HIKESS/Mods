GLOBAL["setmetatable"](env, {
    __index = function(t, k)
        return GLOBAL["rawget"](GLOBAL, k)
    end
})
GLOBAL.setmetatable(env, {
    __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end
})

modimport "main/gwen_str"
modimport "main/gwen_containers"
modimport "main/gwen_hook"
modimport "main/gwen_sg"
modimport "main/gwen_peifang"
modimport "main/gwen_jiandao"
modimport "main/gwen_action"
modimport "main/gwen_level"
modimport "main/gwen_foods"
modimport "main/gwen_fuel"
modimport "main/gwen_emotes"
modimport "main/briar_repel"
modimport "main/gwen_skilltree"


PrefabFiles = {
	"gwen",  --人物代码文件
    "gwen_jiandao",--剪刀	
	"gwen_beibao",--背包
	"feizhen",
	"shengaifx",
	"feizhen_projectile",
	"gw_hundeng",
	"gw_repair",
	"gw_duoluo",
	"gw_muhun",
	"gw_tasui",
	"gw_sjmz",
	"gw_guajian",
	"gw_refactor",----重构器
	"gw_alchemy",----炼金试剂
	"gw_fuzhuang_fx",
	"gw_fuzhuang_nvpu",----女仆装
	"gw_fuzhuang_dachu",----大厨装
	"gw_fuzhuang_yuanding",----园丁装
	"gw_fuzhuang_zhandou",----战斗装
	"gw_fuzhuang_zhandou2",
	"gw_fuzhuang_shengdan",----圣诞服
	"gw_foods",
	"gwen_gold_tools",-----金铲铲和金锅锅
	"gwen_box",
	"gw_shadow",
	"gw_mojing",
	"gw_soul_ball",
	"gw_zhizhen",
	"gwen_haojiao",	----极地号角
	"gwen_backpack",----旅行背包
	"gw_grave",----坟墓堆
	"gw_luoyang",
	"gw_pocheng",
	"gwen_wawa_buff",
	"gwen_spike"
}
Assets =
{
	Asset("ANIM", "anim/status_lasting.zip"),
	Asset("ANIM", "anim/gwen_shengai.zip"),	
	Asset("ANIM", "anim/gwen_shengai.zip"),	
	Asset("ANIM", "anim/gwen_fly.zip"),	
	Asset("ANIM", "anim/gw_refactor.zip"),
	Asset("ANIM", "anim/gw_alchemy.zip"),	
	Asset("ANIM", "anim/gw_refactor_3.zip"),	
	Asset("ANIM", "anim/gw_refactor_0.zip"),	
	Asset("ANIM", "anim/gw_maozi_badge.zip"),	
	Asset("ANIM", "anim/gw_zhizhen.zip"),
	Asset("ANIM", "anim/gw_zhizhen1.zip"),	

	Asset("ANIM", "anim/ui_krampusbag_2x10.zip"),	
	Asset("ANIM", "anim/spell_icons_gwen_haojiao.zip"),	

	Asset("ATLAS", "images/inventoryimages/gwen_shengai.xml"),
	Asset("IMAGE", "images/inventoryimages/gwen_shengai.tex"),	

	Asset("ATLAS", "images/inventoryimages/gw_lock.xml"),
	Asset("IMAGE", "images/inventoryimages/gw_lock.tex"),	

	Asset("ATLAS", "images/inventoryimages/w.xml"),
	Asset("IMAGE", "images/inventoryimages/w.tex"),	
	Asset("ATLAS", "images/inventoryimages/e.xml"),
	Asset("IMAGE", "images/inventoryimages/e.tex"),	
	Asset("ATLAS", "images/inventoryimages/r.xml"),
	Asset("IMAGE", "images/inventoryimages/r.tex"),	
	Asset("ATLAS", "images/inventoryimages/q.xml"),
	Asset("ATLAS", "images/inventoryimages/q.xml"),
	Asset("IMAGE", "images/inventoryimages/q.tex"),	
	Asset("ATLAS", "images/inventoryimages/gw_fly.xml"),
	Asset("IMAGE", "images/inventoryimages/gw_fly.tex"),	

	Asset("ATLAS", "images/inventoryimages/UIswitch.xml"),
	Asset("IMAGE", "images/inventoryimages/UIswitch.tex"),


	Asset("ATLAS", "images/gwen_background.xml"),
	Asset("IMAGE", "images/gwen_background.tex"),

	Asset("ATLAS", "images/inventoryimages/skill_switch_off.xml"),
	Asset("IMAGE", "images/inventoryimages/skill_switch_off.tex"),	
	Asset("ATLAS", "images/inventoryimages/skill_switch_on.xml"),
	Asset("IMAGE", "images/inventoryimages/skill_switch_on.tex"),

	Asset("ATLAS", "images/inventoryimages/cengshu.xml"),
	Asset("IMAGE", "images/inventoryimages/cengshu.tex"),


	Asset("ATLAS", "images/inventoryimages/gwen_wawa.xml"),
	Asset("IMAGE", "images/inventoryimages/gwen_wawa.tex"),

	Asset("ATLAS", "images/inventoryimages/gwen_siwang.xml"),
	Asset("IMAGE", "images/inventoryimages/gwen_siwang.tex"),

	Asset("ATLAS", "images/inventoryimages/shengai_1.xml"),
	Asset("IMAGE", "images/inventoryimages/shengai_1.tex"),	
	Asset("ATLAS", "images/inventoryimages/shengai_2.xml"),
	Asset("IMAGE", "images/inventoryimages/shengai_2.tex"),	
	Asset("ATLAS", "images/inventoryimages/shengai_3.xml"),
	Asset("IMAGE", "images/inventoryimages/shengai_3.tex"),	

	Asset("ATLAS", "images/inventoryimages/gw_shaobing.xml"),
	Asset("IMAGE", "images/inventoryimages/gw_shaobing.tex"),	
	Asset("ATLAS", "images/inventoryimages/gw_heiwu.xml"),
	Asset("IMAGE", "images/inventoryimages/gw_heiwu.tex"),	

	Asset("ATLAS", "images/inventoryimages/OffGwen_equip.xml"),
	Asset("IMAGE", "images/inventoryimages/OffGwen_equip.tex"),	
	Asset("ATLAS", "images/inventoryimages/OnGwen_equip.xml"),
	Asset("IMAGE", "images/inventoryimages/OnGwen_equip.tex"),	

	----各种装备
    Asset("ATLAS","images/inventoryimages/gwen_jiandao.xml"),
	Asset("IMAGE","images/inventoryimages/gwen_jiandao.tex"),	
    Asset("ATLAS","images/inventoryimages/gwen_beibao.xml"),
	Asset("IMAGE","images/inventoryimages/gwen_beibao.tex"),	
    Asset("ATLAS","images/inventoryimages/gw_duoluo.xml"),
	Asset("IMAGE","images/inventoryimages/gw_duoluo.tex"),	
    Asset("ATLAS","images/inventoryimages/gw_hundeng.xml"),
	Asset("IMAGE","images/inventoryimages/gw_hundeng.tex"),
    Asset("ATLAS","images/inventoryimages/gw_muhun.xml"),
	Asset("IMAGE","images/inventoryimages/gw_muhun.tex"),
    Asset("ATLAS","images/inventoryimages/gw_sjmz.xml"),
	Asset("IMAGE","images/inventoryimages/gw_sjmz.tex"),
    Asset("ATLAS","images/inventoryimages/gw_tasui.xml"),
	Asset("IMAGE","images/inventoryimages/gw_tasui.tex"),	

	----挂件
    Asset("ATLAS","images/inventoryimages/gw_gj_xingguang1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xingguang1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xingguang2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xingguang2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xingguang3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xingguang3.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xuehua1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xuehua1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xuehua2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xuehua2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_xuehua3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_xuehua3.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_shaobing1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_shaobing1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_shaobing2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_shaobing2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_shaobing3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_shaobing3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_gj_yumao1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_yumao1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_yumao2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_yumao2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_yumao3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_yumao3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_gj_zhihui1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_zhihui1.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_zhihui2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_zhihui2.tex"),
    Asset("ATLAS","images/inventoryimages/gw_gj_zhihui3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gj_zhihui3.tex"),

	----重构器
    Asset("ATLAS","images/inventoryimages/gw_refactor_1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_1.tex"),
	Asset("ATLAS","images/inventoryimages/gw_refactor_2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_2.tex"),
	Asset("ATLAS","images/inventoryimages/gw_refactor_3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_refactor_0.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor_0.tex"),
    Asset("ATLAS","images/inventoryimages/gw_refactor1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor1.tex"),
	Asset("ATLAS","images/inventoryimages/gw_refactor2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor2.tex"),
	Asset("ATLAS","images/inventoryimages/gw_refactor3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_refactor3.tex"),

	----炼金试剂
    Asset("ATLAS","images/inventoryimages/gw_alchemy_1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_1.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy_2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_2.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy_3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy_4.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy_4.tex"),
    Asset("ATLAS","images/inventoryimages/gw_alchemy1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy1.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy2.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy2.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy3.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy3.tex"),
	Asset("ATLAS","images/inventoryimages/gw_alchemy4.xml"),
	Asset("IMAGE","images/inventoryimages/gw_alchemy4.tex"),

	----修补
    Asset("ATLAS","images/inventoryimages/gw_repair.xml"),
	Asset("IMAGE","images/inventoryimages/gw_repair.tex"),

	----礼盒
	Asset("ATLAS","images/inventoryimages/gw_gift.xml"),
	Asset("IMAGE","images/inventoryimages/gw_gift.tex"),	

	----食物
	Asset("ANIM", "anim/gw_foods.zip"),
	Asset("IMAGE", "images/inventoryimages/gw_dangao.tex"),
	Asset("ATLAS", "images/inventoryimages/gw_dangao.xml"),
	Asset("ATLAS","images/inventoryimages/gw_level_up.xml"),
	Asset("IMAGE","images/inventoryimages/gw_level_up.tex"),
	Asset("ATLAS","images/inventoryimages/gw_level_down.xml"),
	Asset("IMAGE","images/inventoryimages/gw_level_down.tex"),
	Asset("ATLAS","images/inventoryimages/gw_candy.xml"),
	Asset("IMAGE","images/inventoryimages/gw_candy.tex"),

	----时光沙漏
	Asset("ATLAS","images/inventoryimages/gw_time_0.xml"),
	Asset("IMAGE","images/inventoryimages/gw_time_0.tex"),
	Asset("ATLAS","images/inventoryimages/gw_time_1.xml"),
	Asset("IMAGE","images/inventoryimages/gw_time_1.tex"),

	----幽魂
	Asset("ATLAS","images/inventoryimages/gw_soul_ball.xml"),
	Asset("IMAGE","images/inventoryimages/gw_soul_ball.tex"),

	Asset("SOUNDPACKAGE", "sound/Gwen_sound.fev"),
    Asset("SOUND", "sound/Gwen_sound.fsb"),

	Asset("SOUNDPACKAGE", "sound/man.fev"),
    Asset("SOUND", "sound/man.fsb"),


	Asset('ANIM', 'anim/gw_emotes.zip'),

    Asset('ANIM', 'anim/swap_feizhen.zip'),


	Asset("ATLAS", "images/saveslot_portraits/gwen.xml"),
	Asset("IMAGE", "images/saveslot_portraits/gwen.tex"),
	
	----服装
	----女仆
	Asset("ATLAS","images/inventoryimages/gw_yifu_nvpu.xml"),
	Asset("IMAGE","images/inventoryimages/gw_yifu_nvpu.tex"),
	Asset("ATLAS","images/inventoryimages/gw_maozi_nvpu.xml"),
	Asset("IMAGE","images/inventoryimages/gw_maozi_nvpu.tex"),

	----战斗
	Asset("ATLAS", "images/inventoryimages/gw_maozi_zhandou.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_maozi_zhandou.tex"),
	Asset("ATLAS", "images/inventoryimages/gw_yifu_zhandou.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_yifu_zhandou.tex"),

	Asset("ATLAS", "images/inventoryimages/gw_maozi_zhandou2.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_maozi_zhandou2.tex"),
	Asset("ATLAS", "images/inventoryimages/gw_yifu_zhandou2.xml"),
    Asset("IMAGE", "images/inventoryimages/gw_yifu_zhandou2.tex"),
	
	----大厨
	Asset("ATLAS","images/inventoryimages/gw_yifu_dachu.xml"),
	Asset("IMAGE","images/inventoryimages/gw_yifu_dachu.tex"),
	Asset("ATLAS","images/inventoryimages/gw_maozi_dachu.xml"),
	Asset("IMAGE","images/inventoryimages/gw_maozi_dachu.tex"),

	----园丁
	Asset("ATLAS","images/inventoryimages/gw_yifu_yuanding.xml"),
	Asset("IMAGE","images/inventoryimages/gw_yifu_yuanding.tex"),
	Asset("ATLAS","images/inventoryimages/gw_maozi_yuanding.xml"),
	Asset("IMAGE","images/inventoryimages/gw_maozi_yuanding.tex"),

	----金铲铲金锅锅
	Asset("ATLAS","images/inventoryimages/gwen_golden_spatula.xml"),
	Asset("IMAGE","images/inventoryimages/gwen_golden_spatula.tex"),
	Asset("ATLAS","images/inventoryimages/gwen_golden_pot.xml"),
	Asset("IMAGE","images/inventoryimages/gwen_golden_pot.tex"),
}


---对比老版本 主要是增加了names图片 人物检查图标 还有人物的手臂修复（增加了上臂）
--人物动画里面有个SWAP_ICON 里面的图片是在检查时候人物头像那里显示用的


----2019.05.08 修复了 人物大图显示错误和检查图标显示错误
--2020.05.31  新加人物选人界面的属性显示信息
-- Assets = {
    
-- }
--[[---注意事项
1、目前官方自从熔炉之后人物的界面显示用的都是那个椭圆的图
2、官方人物目前的图片跟名字是分开的 
3、names_esctemplate 和 esctemplate_none 这两个文件需要特别注意！！！
这两文件每一次重新转换之后！需要到对应的xml里面改对应的名字 否则游戏里面无法显示
具体为：
降names_esctemplatxml 里面的 Element name="esctemplate.tex" （也就是去掉names——）
将esctemplate_none.xml 里面的 Element name="esctemplate_none_oval" 也就是后面要加  _oval
（注意看修改的名字！不是两个都需要修改）
	]]


local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- GLOBAL.PREFAB_SKINS["GWEN"] = {   --修复人物大图显示
-- 	"esctemplate_none",
-- }

-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.gwen = "灵罗娃娃"
STRINGS.CHARACTER_NAMES.gwen = "格温"
STRINGS.CHARACTER_DESCRIPTIONS.gwen = "从前有一个裁缝，她做了一个可爱的小布娃娃。\n布娃娃很爱她的主人，但一场悲剧将她们分离，\n布娃娃沉入大海深处，整日与悲伤为伴。\n几百年过去了，但布娃娃仍未放弃，\n她知道，爱的力量总有一天会找到她。"
STRINGS.CHARACTER_QUOTES.gwen = "\"一切挣扎，都是值得的。\""

-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.GWEN = require "speech_wilson"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.GWEN = "格温"
STRINGS.SKIN_NAMES.gwen_none = "格温"  --检查界面显示的名字

AddMinimapAtlas("images/map_icons/gwen.xml")  --增加小地图图标

--增加人物到mod人物列表的里面 性别为女性（MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
AddModCharacter("gwen", "FEMALE") 

--选人界面人物三维显示
TUNING.GWEN_HEALTH = 100
TUNING.GWEN_HUNGER = 120
TUNING.GWEN_SANITY = 100

--生存几率
STRINGS.CHARACTER_SURVIVABILITY.gwen = "轻松"

--选人界面初始物品显示
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.GWEN = {"gwen_beibao","gwen_jiandao","gw_gift"}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["gwen_jiandao"] = {
	atlas = "images/inventoryimages/gwen_jiandao.xml",
	image = "gwen_jiandao.tex",
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["gwen_beibao"] = {
	atlas = "images/inventoryimages/gwen_beibao.xml",
	image = "gwen_beibao.tex",
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["gw_gift"] = {
	atlas = "images/inventoryimages/gw_gift.xml",
	image = "gw_gift.tex",
}

TUNING.GWEN_JIANDAODAMAGE = GetModConfigData("Gwen_jiandaodamage")
TUNING.BAIFENBISHANGHAI = GetModConfigData("baifenbishanghai")
TUNING.FEIZHENSHULIANG = GetModConfigData("feizhenshuliang")
TUNING.GEIBUGEILVBAOSHI = GetModConfigData("geibugeilvbaoshi")
TUNING.XIUBUXIUCHAIJIEJIANZAO = GetModConfigData("xiubuxiuchaijiejianzao")
TUNING.BEIBAOXIULI = GetModConfigData("gewenxiuli")
TUNING.BEIBAOFANXIANMA = GetModConfigData("beibaofanxianma")
TUNING.GWEN_CHAIJIEZHI = GetModConfigData("gewenchaijie")
TUNING.SHENGAIJIANMIAN = GetModConfigData("shengaijianshang")
TUNING.Q_CD = GetModConfigData("Qcd")
TUNING.DASH_MAN = GetModConfigData("dash_man")
STRINGS.NAMES.GWEN_BEIBAO = "格温的背包"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GWEN_BEIBAO = "格温的背包"
TUNING.TERRAPRISMA_CIRCLEFY = true--飞针环绕
TUNING.GW_LENGCAIJIACHENG = GetModConfigData("gw_lengcaijiacheng")--棱彩加成

local Gwen_UI_Key = GetModConfigData("Gwen_UI_Key")
local Gwen_Q_Key = GetModConfigData("Gwen_Q_Key")
local Gwen_W_Key = GetModConfigData("Gwen_W_Key")
local Gwen_E_Key = GetModConfigData("Gwen_E_Key")
local Gwen_R_Key = GetModConfigData("Gwen_R_Key")
local Gwen_N_Key = GetModConfigData("Gwen_N_Key")


--[[如果你的初始物品是mod物品需要定义mod物品的图片路径 比如物品是 abc

]]

GLOBAL.E_CONTAIN = { "_health","_combat" }
GLOBAL.E_EXCLUDE = { "player","ghost","ownerghost","companion","abigail","glommer","chester","hutch","wall","boat","INLIMBO","shadowminion","mermguard","structure","notarget","balloom","echester"}

GLOBAL.Gwen_key_name = {
	[97]="A",[98]="B",[99]="C",[100]="D",[101]="E",[102]="F",[103]="G",
	[104]="H",[105]="I",[106]="J",[107]="K",[108]="L",[109]="M",[110]="N",
	[111]="O",[112]="P",[113]="Q",[114]="R",[115]="S",[116]="T",
	[117]="U",[118]="V",[119]="W",[120]="X",[121]="Y",[122]="Z",[123]="无",

	[282]="F1",[283]="F2",[284]="F3",[285]="F4",[286]="F5",[287]="F6",
	[288]="F7",[289]="F8",[290]="F9",[291]="F10",[292]="F11",[293]="F12",

	[256]="Num_0",[257]="Num_1",[258]="Num_2",[259]="Num_3",[260]="Num_4",
	[261]="Num_5",[262]="Num_6",[263]="Num_7",[264]="Num_8",[265]="Num_9",
	[266]="Num_.",[267]="Num_/",[268]="Num_*",[269]="Num_-",[270]="Num_+",

	[1002]="\238\132\130",[1005]="\238\132\132",[1006]="\238\132\131"
}

----等级数据
local gw_Level_Info_list = {
	{gw_Up_Level = 18, gw_Up_ExpDemand = 2000 },
	{gw_Up_Level = 17, gw_Up_ExpDemand = 1090 },
	{gw_Up_Level = 16, gw_Up_ExpDemand = 1000 },
	{gw_Up_Level = 15, gw_Up_ExpDemand = 780  },
	{gw_Up_Level = 14, gw_Up_ExpDemand = 690  },
	{gw_Up_Level = 13, gw_Up_ExpDemand = 600  },
	{gw_Up_Level = 12, gw_Up_ExpDemand = 510  },
	{gw_Up_Level = 11, gw_Up_ExpDemand = 420  },
	{gw_Up_Level = 10, gw_Up_ExpDemand = 360  },
	{gw_Up_Level = 9,  gw_Up_ExpDemand = 320  },
	{gw_Up_Level = 8,  gw_Up_ExpDemand = 260  },
	{gw_Up_Level = 7,  gw_Up_ExpDemand = 200  },
	{gw_Up_Level = 6,  gw_Up_ExpDemand = 170  },
	{gw_Up_Level = 5,  gw_Up_ExpDemand = 140  },
	{gw_Up_Level = 4,  gw_Up_ExpDemand = 110  },
	{gw_Up_Level = 3,  gw_Up_ExpDemand = 80   },
	{gw_Up_Level = 2,  gw_Up_ExpDemand = 50   },
	{gw_Up_Level = 1,  gw_Up_ExpDemand = 20   },
}
local function gw_Level_Info(inst_level, gw_Level_Info_name)
	for _, v in pairs(gw_Level_Info_list) do
		if inst_level >= v.gw_Up_Level then
			return v[gw_Level_Info_name] 
		end
	end
end
 

--带有Replica 的组件需要注册一下  如果你不用replica的话直接弄个net给任务也是可以的  无非就是要把数据传给客户端刷新界面显示用而已
AddReplicableComponent("gwen_shengai")
AddReplicableComponent("gwen_competence")
AddReplicableComponent("gwen_equip")
AddReplicableComponent("gwen_refactor")
AddReplicableComponent("gwen_moon")

--界面部分
local GwenShengaiBadge = require("widgets/gwenshengaibadge")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")
local Image = require ("widgets/image")
local TextButton = require("widgets/textbutton")
local Widget = require("widgets/widget")
local width,_ =  TheSim:GetScreenSize()
local scale = width / 2000
local PopupDialogScreen = require "screens/redux/popupdialog"

local function Add_gwen_shengai(self) 
	if self.owner and self.owner.prefab == "gwen" then

		self.gwen_shengai_1 = self:AddChild(Image("images/inventoryimages/shengai_1.xml", "shengai_1.tex"))
		self.gwen_shengai_3 = self:AddChild(Image("images/inventoryimages/shengai_3.xml", "shengai_3.tex"))
		self.gwen_shengai_2 = self:AddChild(Image("images/inventoryimages/shengai_2.xml", "shengai_2.tex"))

		-- **设置技能图标大小**
		self.gwen_shengai_1:SetScale(.46, .46)
		self.gwen_shengai_3:SetScale(.46, .46)
		self.gwen_shengai_2:SetScale(.46, .46)

		self.gwen_shengai = self:AddChild(GwenShengaiBadge(self.owner))
		self.gwen_shengai:SetPosition(-240, 20, 0)

		--关于坐标这个  我习惯延迟一点 然后放到 饥饿的左边
		self.owner:DoTaskInTime(0.5, function()
			local x1 ,y1 ,z1 = self.stomach:GetPosition():Get()
			local x2 ,y2 ,z2 = self.brain:GetPosition():Get()		
			local x3 ,y3 ,z3 = self.heart:GetPosition():Get()		
			if y2 == y1 or  y2 == y3 then --开了三维mod
				self.gwen_shengai:SetPosition(self.stomach:GetPosition() + Vector3(x1-x2, 0, 0))
				self.gwen_shengai_1:SetPosition(self.stomach:GetPosition() + Vector3(x1-x2, -6.4, 0))
				self.gwen_shengai_3:SetPosition(self.stomach:GetPosition() + Vector3(x1-x2, .8, 0))
				self.gwen_shengai_2:SetPosition(self.stomach:GetPosition() + Vector3(x1-x2, .8, 0))
			else
				self.gwen_shengai:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3, 0, 0))
				self.gwen_shengai_1:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3, -6.4, 0))
				self.gwen_shengai_3:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3, .8, 0))
				self.gwen_shengai_2:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3, .8, 0))
			end
		end)
		
		local width, hieght = self.gwen_shengai_2:GetSize()
		local width3, hieght3 = self.gwen_shengai_3:GetSize()

		--监听事件 刷新数据
		self.inst:ListenForEvent("gwenshengaidelta", function(inst,data)
			self.gwen_shengai:SetPercent(data, self.owner.replica.gwen_shengai:Max())
			self.gwen_shengai_3:SetScissor(-width3*.5, -hieght3*.5, math.max(0, width3), math.max(0, hieght3*(1-self.owner.currentgwen_chengfa:value()/5)))
			self.gwen_shengai_2:SetScissor(-width*.5, -hieght*.5, math.max(0, width), math.max(0, hieght*self.owner.replica.gwen_shengai:GetPercent()))
		end,self.owner)

		----死亡时候的隐藏
		local old_SetGhostMode = self.SetGhostMode
		function self:SetGhostMode(ghostmode,...)
			old_SetGhostMode(self,ghostmode,...)
			if ghostmode then		
				if self.gwen_shengai ~= nil then 
					self.gwen_shengai:Hide()
				end
				if self.gwen_shengai_1 ~= nil then 
					self.gwen_shengai_1:Hide()
				end	
				if self.gwen_shengai_2 ~= nil then 
					self.gwen_shengai_2:Hide()
				end	
				if self.gwen_shengai_3 ~= nil then 
					self.gwen_shengai_3:Hide()
				end	
			else
				if self.gwen_shengai ~= nil then
					self.gwen_shengai:Show()
				end
				if self.gwen_shengai_1 ~= nil then
					self.gwen_shengai_1:Show()
				end
				if self.gwen_shengai_2 ~= nil then
					self.gwen_shengai_2:Show()
				end
				if self.gwen_shengai_3 ~= nil then
					self.gwen_shengai_3:Show()
				end
			end
		end
	end
end
AddClassPostConstruct("widgets/statusdisplays", Add_gwen_shengai)

-- 设置技能冷却时间（秒）----【修改测试】
local SKILL_CD = {
	V = TUNING.Q_CD , -- 剪刀
	Z = 6,  -- 冲刺
    X = 30, -- 召唤圣蔼
    R = 32, --飞针
    N = 1, --飞行
}
local feizhenchixu = 12 -- 飞针持续时间

-- 初始化技能冷却状态
local function InitSkillCooldown(player)
    player.skill_cooldowns = player.skill_cooldowns or {}
end

-- 检查技能是否在冷却中
local function IsSkillOnCooldown(player, skill)
    return player.skill_cooldowns[skill] and player.skill_cooldowns[skill] > GLOBAL.GetTime()
end

-- 设置技能进入冷却
local function StartSkillCooldown(player, skill, duration)
    player.skill_cooldowns[skill] = GLOBAL.GetTime() + duration
end


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
local function cd(ti)
    local t = ti --保存时间间隔
    local last = -ti --上个调用的时间
    return function()
        local ct = GetTime() --获取当前时间
        if (ct - t) > last then --若距离上次调用的时间超过给定时间间隔
            last = ct --更新上次调用的时间
            return true
        end
        return false
    end
end

local function UpGradeMakeWidgetMovable(s, name, pos, data) -- 使UI可移动
    s.onikirimovable = {} --初始化表
    local m = s.onikirimovable
    m.nullfn = function() end
    m.name = name or "default" --存储位置名称，默认为"default"
    m.self = s --存储UI实体
    m.downtime = 0 --鼠标按下时间
    m.whiletime = 0.4 --触发拖动的时间阈值
    m.cd = cd(0.5) --创建一个内置cd，用于限制拖动频率
    m.dpos = pos or Vector3(0, 0, 0) --默认位置向量
    m.pos = pos or Vector3(0, 0, 0) --当前位置向量
    m.ha = data and data.ha or 1 --水平对其
    m.va = data and data.va or 2 --垂直对其

    --从存档中读取位置信息
    m.x, m.y = TheSim:GetScreenSize()
    TheSim:GetPersistentString(m.name, function(load_success, str)
        if load_success then
            local fn = loadstring(str) --将字符串转换为函数
            if type(fn) == "function" then
                m.pos = fn() --调用函数获取位置向量
                if not (type(m.pos) == "table" and m.pos.Get) then
                    m.pos = pos --如果位置不对，则使用默认位置
                end
            end
        end
    end)
    s:SetPosition(m.pos:Get()) --设置UI实体的位置为读取到的位置

    m.OnControl = s.OnControl or m.nullfn
    s.OnControl = function(self, control, down)
        if self.focus and control == CONTROL_ACCEPT then
            if down then
                if not m.down then
                    m.down = true
                    m.downtime = 0
                end
            else
                if m.down then
                    m.down = false
                    m.OnClick(self) --OnClick方法
                end
            end
        end
        return m.OnControl(self, control, down)
    end
    --重写UI实体的OnRawKey方法，实现快捷键操作
    m.OnRawKey = s.OnRawKey or m.nullfn
    s.OnRawKey = function(self, key, down, ...)
        if s.focus and key == KEY_SPACE and not down and not m.cd() then
            s:SetPosition(m.dpos:Get()) --位置重.置为默认位置
            TheSim:SetPersistentString(m.name, string.format(
                                           "return Vector3(%d,%d,%d)",
                                           m.dpos:Get()), false) --重.置后的位置存入存档
        end
        return m.OnRawKey(self, key, down, ...)
    end

    m.OnClick = function(self)
        m:StopFollowMouse()
        if m.downtime > m.whiletime then
            local newpos = self:GetPosition()
            if TUNING.FLDEBUGCOMMAND then
				--print(s, name, newpos:Get())
            end
            TheSim:SetPersistentString(m.name, string.format(
                                           "return Vector3(%f,%f,%f)",
                                           newpos:Get()), false)
        end
        if m.lastx and m.lasty and s.o_pos then
            s.o_pos = Vector3(m.lastx, m.lasty, 0)
        end
    end

    m.OnUpdate = s.OnUpdate or m.nullfn
    s.OnUpdate = function(self, dt)
        if m.down then if m.whiledown then m.whiledown(self) end end
        return m.OnUpdate(self, dt)
    end
    m.whiledown = function(self)
        m.downtime = m.downtime + 0.033
        if m.downtime > m.whiletime then m.FollowMouse(self) end
    end
    m.UpdatePosition = function(self, x, y)
        local sx, sy = s.parent.GetScale(s.parent):Get()
        local ox, oy = s.parent.GetWorldPosition(s.parent):Get()
        local nx = (x - ox) / sx
        if m.ha == 0 then
            x = x - m.x / 2
            nx = (x - ox) / sx
        elseif m.ha == 2 then
            x = x - m.x
            nx = (x - ox) / sx
        end
        local ny = (y - oy) / sy
        if m.va == 0 then
            y = y - m.y / 2
            ny = (y - oy) / sy
        elseif m.va == 1 then
            y = y - m.y
            ny = (y - oy) / sy
        end
        m.lastx = nx
        m.lasty = ny
        s.SetPosition(self, nx, ny, 0)
    end
    m.FollowMouse = function(self)
        if m.followhandler == nil then
            m.followhandler = TheInput:AddMoveHandler(
                                  function(x, y)
                    m.UpdatePosition(self, x, y)
                end)
            local spos = TheInput:GetScreenPosition()
            m.UpdatePosition(self, spos.x, spos.y)
            -- self:SetPosition()
        end
    end

    m.StopFollowMouse = function(self)
        if m.followhandler ~= nil then
            m.followhandler:Remove()
            m.followhandler = nil
        end
    end
    s:StartUpdating()
end


local GwenSkillWidget = Class(Widget, function(self, owner)
    Widget._ctor(self, "GwenSkillWidget")
	self.owner = owner
    self.owner:DoTaskInTime(0.5, function()
        if self.owner and self.owner:HasTag("player") and self.owner:HasTag("gwen") then
            InitSkillCooldown(self.owner) -- 确保冷却表初始化
			
			local at_cengshu = "images/inventoryimages/cengshu.xml"
			local image_cengshu = "cengshu.tex"
			local cengshu_image = self:AddChild(ImageButton(at_cengshu, image_cengshu, image_cengshu, image_cengshu))
			cengshu_image:SetPosition(42, 10, 0)
			-- **设置技能图标大小**
			cengshu_image:SetNormalScale(.23,.23,.23)
			-- **设置鼠标划过大小**
			cengshu_image:SetFocusScale(.23,.23,.23)
			-- **设置技能图标颜色**
			cengshu_image:SetImageNormalColour(1,1,1,.88)
			
			local at_Job_Skill_v = "images/inventoryimages/q.xml"
			local at_Job_Skill_z = "images/inventoryimages/e.xml"
			local at_Job_Skill_x = "images/inventoryimages/w.xml"
			local at_Job_Skill_r = "images/inventoryimages/r.xml"
			local at_Job_Skill_n = "images/inventoryimages/gw_fly.xml"

			local image_Job_Skill_v = "q.tex"
			local image_Job_Skill_z = "e.tex"
			local image_Job_Skill_x = "w.tex"
			local image_Job_Skill_r = "r.tex"
			local image_Job_Skill_n = "gw_fly.tex"

			-- **创建技能图标按钮**
			--local z = self.top_root:AddChild(ImageButton("images/inventoryimages/e.xml", "e.tex"))
			--local r = self.top_root:AddChild(ImageButton("images/inventoryimages/r.xml", "r.tex"))
			--local x = self.top_root:AddChild(ImageButton("images/inventoryimages/w.xml", "w.tex"))
			--local v = self.top_root:AddChild(ImageButton("images/inventoryimages/q.xml", "q.tex"))

			self.v = self:AddChild(ImageButton(at_Job_Skill_v, image_Job_Skill_v, image_Job_Skill_v, image_Job_Skill_v))
			self.z = self:AddChild(ImageButton(at_Job_Skill_z, image_Job_Skill_z, image_Job_Skill_z, image_Job_Skill_z))
			self.x = self:AddChild(ImageButton(at_Job_Skill_x, image_Job_Skill_x, image_Job_Skill_x, image_Job_Skill_x))
			self.r = self:AddChild(ImageButton(at_Job_Skill_r, image_Job_Skill_r, image_Job_Skill_r, image_Job_Skill_r))
			self.n = self:AddChild(ImageButton(at_Job_Skill_n, image_Job_Skill_n, image_Job_Skill_n, image_Job_Skill_n))
			
			local v = self.v
			local z = self.z
			local x = self.x
			local r = self.r
			local n = self.n

			-- **设置技能图标位置**
			v:SetPosition(42, 0, 0)
			z:SetPosition(92, 0, 0)
			x:SetPosition(142, 0, 0)
			r:SetPosition(192, 0, 0)
			n:SetPosition(242, 0, 0)

			-- **设置技能图标大小**
			v:SetNormalScale(.23,.23,.23)
			z:SetNormalScale(.23,.23,.23)
			x:SetNormalScale(.23,.23,.23)
			r:SetNormalScale(.23,.23,.23)
			n:SetNormalScale(.23,.23,.23)

			-- **设置鼠标划过大小**
			v:SetFocusScale(.34,.34,.34)
			z:SetFocusScale(.34,.34,.34)
			x:SetFocusScale(.34,.34,.34)
			r:SetFocusScale(.34,.34,.34)
			n:SetFocusScale(.34,.34,.34)

			-- **设置技能图标颜色**
			v:SetImageNormalColour(1,1,1,.88)
			z:SetImageNormalColour(1,1,1,.88)
			x:SetImageNormalColour(1,1,1,.88)
			r:SetImageNormalColour(1,1,1,.88)
			n:SetImageNormalColour(1,1,1,.88)

			-- **设置鼠标划过颜色**
			v:SetImageFocusColour(1,1,1,1)
			z:SetImageFocusColour(1,1,1,1)
			x:SetImageFocusColour(1,1,1,1)
			r:SetImageFocusColour(1,1,1,1)
			n:SetImageFocusColour(1,1,1,1)

			------------------------技能层数
			local cengshu = self:AddChild(Text(GLOBAL.NUMBERFONT, 16))
			cengshu:SetPosition(43.5, 30, 0)
			cengshu:SetColour(.6, .8, 1, 1)
			cengshu:Show()
			--cengshu:SetString("【1】")
			
			------------------------展开收起
			local at_UIswitch = "images/inventoryimages/UIswitch.xml"
			local image_UIswitch = "UIswitch.tex"
			local UIswitch = self:AddChild(ImageButton(at_UIswitch, image_UIswitch, image_UIswitch, image_UIswitch))
			UIswitch:Show()

			-- **设置技能图标位置**
			UIswitch:SetPosition(0, 0, 0)

			-- **设置技能图标大小**
			UIswitch:SetNormalScale(.23,.23,.23)

			-- **设置鼠标划过大小**
			UIswitch:SetFocusScale(.34,.34,.34)

			-- **设置技能图标颜色**
			UIswitch:SetImageNormalColour(1,1,1,.88)

			-- **设置鼠标划过颜色**
			UIswitch:SetImageFocusColour(1,1,1,1)

			UIswitch:SetOnClick(function()
                SendModRPCToServer(GetModRPC("gwenr", "UIswitch"))
			end)

			------------------------面向保持
			local at_Vkeepmianxiang = "images/inventoryimages/skill_switch_on.xml"
			local at_Zkeepmianxiang = "images/inventoryimages/skill_switch_on.xml"
			local at_Vnokeepmianxiang = "images/inventoryimages/skill_switch_off.xml"
			local at_Znokeepmianxiang = "images/inventoryimages/skill_switch_off.xml"

			local image_Vkeepmianxiang = "skill_switch_on.tex"
			local image_Zkeepmianxiang = "skill_switch_on.tex"
			local image_Vnokeepmianxiang = "skill_switch_off.tex"
			local image_Znokeepmianxiang = "skill_switch_off.tex"

			local Vkeepmianxiang = self:AddChild(ImageButton(at_Vkeepmianxiang, image_Vkeepmianxiang, image_Vkeepmianxiang, image_Vkeepmianxiang))
			local Zkeepmianxiang = self:AddChild(ImageButton(at_Zkeepmianxiang, image_Zkeepmianxiang, image_Zkeepmianxiang, image_Zkeepmianxiang))
			local Vnokeepmianxiang = self:AddChild(ImageButton(at_Vnokeepmianxiang, image_Vnokeepmianxiang, image_Vnokeepmianxiang, image_Vnokeepmianxiang))
			local Znokeepmianxiang = self:AddChild(ImageButton(at_Znokeepmianxiang, image_Znokeepmianxiang, image_Znokeepmianxiang, image_Znokeepmianxiang))

			-- **设置技能图标位置**
			Vkeepmianxiang:SetPosition(42, -32, 0)
			Zkeepmianxiang:SetPosition(92, -32, 0)
			Vnokeepmianxiang:SetPosition(42, -32, 0)
			Znokeepmianxiang:SetPosition(92, -32, 0)

			-- **设置技能图标大小**
			Vkeepmianxiang:SetNormalScale(.23,.23,.23)
			Zkeepmianxiang:SetNormalScale(.23,.23,.23)
			Vnokeepmianxiang:SetNormalScale(.23,.23,.23)
			Znokeepmianxiang:SetNormalScale(.23,.23,.23)

			-- **设置鼠标划过大小**
			Vkeepmianxiang:SetFocusScale(.28,.28,.28)
			Zkeepmianxiang:SetFocusScale(.28,.28,.28)
			Vnokeepmianxiang:SetFocusScale(.28,.28,.28)
			Znokeepmianxiang:SetFocusScale(.28,.28,.28)

			-- **设置技能图标颜色**
			Vkeepmianxiang:SetImageNormalColour(1,1,1,.96)
			Zkeepmianxiang:SetImageNormalColour(1,1,1,.96)
			Vnokeepmianxiang:SetImageNormalColour(1,1,1,.96)
			Znokeepmianxiang:SetImageNormalColour(1,1,1,.96)

			-- **设置鼠标划过颜色**
			Vkeepmianxiang:SetImageFocusColour(1,1,1,1)
			Zkeepmianxiang:SetImageFocusColour(1,1,1,1)
			Vnokeepmianxiang:SetImageFocusColour(1,1,1,1)
			Znokeepmianxiang:SetImageFocusColour(1,1,1,1)
			
			Vkeepmianxiang:SetHoverText("跟随鼠标施放技能\n(点击切换)")
			Zkeepmianxiang:SetHoverText("跟随鼠标施放技能\n(点击切换)")
			Vnokeepmianxiang:SetHoverText("保持面向施放技能\n(点击切换)")
			Znokeepmianxiang:SetHoverText("保持面向施放技能\n(点击切换)")
			
			Vkeepmianxiang:SetOnClick(function()
                SendModRPCToServer(GetModRPC("gwenr", "Vkeepmianxiang"))
			end)
			Vnokeepmianxiang:SetOnClick(function()
                SendModRPCToServer(GetModRPC("gwenr", "Vkeepmianxiang"))
			end)
			Zkeepmianxiang:SetOnClick(function()
                SendModRPCToServer(GetModRPC("gwenr", "Zkeepmianxiang"))
			end)
			Znokeepmianxiang:SetOnClick(function()
                SendModRPCToServer(GetModRPC("gwenr", "Zkeepmianxiang"))
			end)

			--[[ **禁用焦点放大**
			z.scale_on_focus = false
			r.scale_on_focus = false
			x.scale_on_focus = false
			v.scale_on_focus = false]]

            -- **创建冷却时间文本**
            local skill_cd_texts = {
                Z = z:AddChild(Text(GLOBAL.NUMBERFONT, 22)),
                R = r:AddChild(Text(GLOBAL.NUMBERFONT, 22)),
                X = x:AddChild(Text(GLOBAL.NUMBERFONT, 22)),
                V = v:AddChild(Text(GLOBAL.NUMBERFONT, 22)),
                N = n:AddChild(Text(GLOBAL.NUMBERFONT, 22)),
            }

            for _, text in pairs(skill_cd_texts) do
                text:SetColour(0, .6, 1, 1)  -- 黑色字体
                text:SetPosition(0, 0)  -- 居中
                text:Hide()
            end

			
			------------------------隐藏外甲
			local at_OffGwen_equip = "images/inventoryimages/OffGwen_equip.xml"
			local at_OnGwen_equip = "images/inventoryimages/OnGwen_equip.xml"
			local image_OffGwen_equip = "OffGwen_equip.tex"
			local image_OnGwen_equip = "OnGwen_equip.tex"
			local OffGwen_equip = self:AddChild(ImageButton(at_OffGwen_equip, image_OffGwen_equip, image_OffGwen_equip, image_OffGwen_equip))
			local OnGwen_equip = self:AddChild(ImageButton(at_OnGwen_equip, image_OnGwen_equip, image_OnGwen_equip, image_OnGwen_equip))

			-- **设置图标位置**
			OffGwen_equip:SetPosition(-52, 0, 0)
			OnGwen_equip:SetPosition(-52, 0, 0)

			-- **设置图标大小**
			OffGwen_equip:SetNormalScale(.38,.38,.38)
			OnGwen_equip:SetNormalScale(.38,.38,.38)

			-- **设置划过大小**
			OffGwen_equip:SetFocusScale(.44,.44,.44)
			OnGwen_equip:SetFocusScale(.44,.44,.44)

			-- **设置图标颜色**
			OffGwen_equip:SetImageNormalColour(1,1,1,.96)
			OnGwen_equip:SetImageNormalColour(1,1,1,.96)

			-- **设置划过颜色**
			OffGwen_equip:SetImageFocusColour(1,1,1,1)
			OnGwen_equip:SetImageFocusColour(1,1,1,1)

			OffGwen_equip:SetHoverText("显示外甲")
			OnGwen_equip:SetHoverText("隐藏外甲")
			OffGwen_equip:SetOnClick(function()
			   SendModRPCToServer(GetModRPC("gwenr", "UIyincang"))
			end)
			OnGwen_equip:SetOnClick(function()
			   SendModRPCToServer(GetModRPC("gwenr", "UIyincang"))
			end)
			
			------------------------死亡按钮
			local at_UIsiwang = "images/inventoryimages/gwen_siwang.xml"
			local image_UIsiwang = "gwen_siwang.tex"
			local UIsiwang = self:AddChild(ImageButton(at_UIsiwang, image_UIsiwang, image_UIsiwang, image_UIsiwang))

			-- **设置图标位置**
			UIsiwang:SetPosition(-102, 0, 0)

			-- **设置图标大小**
			UIsiwang:SetNormalScale(.24,.24,.24)

			-- **设置划过大小**
			UIsiwang:SetFocusScale(.26,.26,.26)

			-- **设置图标颜色**
			UIsiwang:SetImageNormalColour(1,1,1,.96)

			-- **设置划过颜色**
			UIsiwang:SetImageFocusColour(1,1,1,1)

			UIsiwang:SetOnClick(function()
				SendModRPCToServer(GetModRPC("gwenr", "UIsiwang"))
			end)

			UIsiwang:SetHoverText("娃娃化身\n化身成娃娃")

			------------------------复活按钮
			local fuhuonum = self:AddChild(Text(GLOBAL.NUMBERFONT, 19))
			fuhuonum:SetPosition(0, -26, 0)
			fuhuonum:SetColour(.77, .96, 1, 1)

			local at_UIfuhuo = "images/inventoryimages/gwen_wawa.xml"
			local image_UIfuhuo = "gwen_wawa.tex"
			local UIfuhuo = self:AddChild(ImageButton(at_UIfuhuo, image_UIfuhuo, image_UIfuhuo, image_UIfuhuo))

			-- **设置图标位置**
			UIfuhuo:SetPosition(0, 0, 0)

			-- **设置图标大小**
			UIfuhuo:SetNormalScale(.32,.32,.32)

			-- **设置划过大小**
			UIfuhuo:SetFocusScale(.39,.39,.39)

			-- **设置图标颜色**
			UIfuhuo:SetImageNormalColour(1,1,1,.96)

			-- **设置划过颜色**
			UIfuhuo:SetImageFocusColour(1,1,1,1)

			UIfuhuo:SetOnClick(function()
			   SendModRPCToServer(GetModRPC("gwenr", "UIfuhuo"))
			end)
			local fuhuo

			----有关等级部分
			local gwen_Level = self:AddChild(Text(GLOBAL.NUMBERFONT, 16))
			gwen_Level:SetPosition(0, 45, 0)
			gwen_Level:SetColour(.6, .8, 1, 1)
			gwen_Level:Show()
			local gwen_Exp = self:AddChild(Text(GLOBAL.NUMBERFONT, 16))
			gwen_Exp:SetPosition(0, 30, 0)
			gwen_Exp:SetColour(.6, .8, 1, 1)
			gwen_Exp:Show()


			-- 经验条背景（深色部分）
			-- self.exp_bar_bg = self:AddChild(Image("images/global_redux.xml", "button_carny_xlong_disabled.tex"))
			-- self.exp_bar_bg:SetPosition(150, 30, 0)
			-- self.exp_bar_bg:SetSize(150, 8)
			-- self.exp_bar_bg:SetTint(0.15, 0.15, 0.15, 0.7)  -- 深灰色半透明背景
			-- self.exp_bar_bg:MoveToBack()  -- 放到后面
			
			-- -- 经验条前景（进度部分）
			-- self.exp_bar_fg = self:AddChild(Image("images/global_redux.xml", "list_divider_bottom_1.tex"))
			-- self.exp_bar_fg:SetPosition(75, 30, 0)  -- 初始位置位于进度条最左侧
			-- self.exp_bar_fg:SetSize(0, 6)  -- 初始宽度为0
			-- self.exp_bar_fg:SetTint(0.1, 0.9, 0.3, 0.9)


			z:Hide()
			Zkeepmianxiang:Hide()
			Znokeepmianxiang:Hide()
			x:Hide()
			r:Hide()
			n:Hide()

            -- **定期更新冷却时间**
            local function UpdateSkillCooldowns()
				local gw_Level = self.owner.replica.gwen_competence and self.owner.replica.gwen_competence:Get_gwen_Level() or 1
				local gw_Exp = self.owner.replica.gwen_competence and self.owner.replica.gwen_competence:Get_gwen_Exp() or 0
				if gw_Level < 18 then
					gwen_Level:SetString("Lv."..gw_Level)
				else
					gwen_Level:SetString("Lv.Max")
				end
				local gw_ExpDemand = gw_Level_Info(gw_Level, "gw_Up_ExpDemand") or 0
				gwen_Exp:SetString("Exp."..gw_Exp.."/"..gw_ExpDemand)

				----##经验条的调整宽度##
				-- if self.exp_bar_bg and self.exp_bar_fg then
				-- 	local exp_percent = 0
				-- 	if gw_ExpDemand > 0 then
				-- 		exp_percent = math.min(gw_Exp / gw_ExpDemand, 1)
				-- 	end
					
				-- 	-- 更新经验条宽度（基于150像素的基础宽度）
				-- 	local exp_bar_width = exp_percent * 150
				-- 	self.exp_bar_fg:SetSize(exp_bar_width, 6)  -- 注意高度要保持6
				-- 	self.exp_bar_fg:SetPosition(75 + exp_bar_width/2, 30, 0)
				-- end

				v:SetOnClick(function()
						if IsSkillOnCooldown(self.owner, "V") then
							self.owner.components.talker:Say("技能冷却中 (" .. math.ceil(self.owner.skill_cooldowns["V"] - GLOBAL.GetTime()) .. "s)")
						else
							SendModRPCToServer(GetModRPC("gwenr", "mianxiang"))
							local x, y, z = GLOBAL.TheInput:GetWorldPosition():Get()
							SendModRPCToServer(MOD_RPC["gwenw"]["jiiandao"], x, y, z)
							StartSkillCooldown(self.owner, "V", SKILL_CD.V)
						end
				end)
				z:SetOnClick(function()
					if gw_Level >= 3 then
						if IsSkillOnCooldown(self.owner, "Z") then
							self.owner.components.talker:Say("断续疾走冷却中 (" .. math.ceil(self.owner.skill_cooldowns["Z"] - GLOBAL.GetTime()) .. "s)")
						else
							SendModRPCToServer(GetModRPC("gwenr", "mianxiang"))

							local x, y, z = GLOBAL.TheInput:GetWorldPosition():Get()
							SendModRPCToServer(MOD_RPC["corin"]["rush"], x, y, z)
							StartSkillCooldown(self.owner, "Z", SKILL_CD.Z)
						end
					else
						self.owner.components.talker:Say("技能尚未解锁")
					end
				end)
				x:SetOnClick(function()
					if gw_Level >= 5 then
						if IsSkillOnCooldown(self.owner, "X") then
							self.owner.components.talker:Say("丝缕缠流冷却中 (" .. math.ceil(self.owner.skill_cooldowns["X"] - GLOBAL.GetTime()) .. "s)")
						else
							SendModRPCToServer(MOD_RPC["gwenw"]["zhaohuanshengai"])
							StartSkillCooldown(self.owner, "X", SKILL_CD.X)
						end
					else
						self.owner.components.talker:Say("技能尚未解锁")
					end
				end)

				r:SetOnClick(function()
					if gw_Level >= 7 then
						if IsSkillOnCooldown(self.owner, "R") then
							self.owner.components.talker:Say("引针簇射冷却中 (" .. math.ceil(self.owner.skill_cooldowns["R"] - GLOBAL.GetTime()) .. "s)")
						else
							SendModRPCToServer(MOD_RPC["gwenr"]["zhaohuanfeizhen"])
							StartSkillCooldown(self.owner, "R", SKILL_CD.R)
						end
					else
						self.owner.components.talker:Say("技能尚未解锁")
					end
				end)
				n:SetOnClick(function()
					if gw_Level >= 9 then
						if IsSkillOnCooldown(self.owner, "N") then
							self.owner.components.talker:Say("切换模式冷却中 (" .. math.ceil(self.owner.skill_cooldowns["N"] - GLOBAL.GetTime()) .. "s)")
						else
							SendModRPCToServer(MOD_RPC["gwenr"]["gw_fly"])
							StartSkillCooldown(self.owner, "N", SKILL_CD.N)
						end
					else
						self.owner.components.talker:Say("技能尚未解锁")
					end
				end)


				local GetCurrent = (self.owner.replica.gwen_shengai and self.owner.replica.gwen_shengai:GetCurrent()) or 0
				local shengai_Current
				if gw_Level >= 1 then
					shengai_Current = 80
				end
				if gw_Level >= 10 then
					shengai_Current = 60
				end
				if gw_Level >= 16 then
					shengai_Current = 40
				end
				if GetCurrent < shengai_Current then
					fuhuo = "圣蔼大于"..shengai_Current.."可恢复人形"
				else
					fuhuo = "点击可恢复人形"
				end

				if not self.owner:HasTag("playerghost") then
					for skill, text_widget in pairs(skill_cd_texts) do
						if self.owner.skill_cooldowns[skill] then
							local time_left = math.ceil(self.owner.skill_cooldowns[skill] - GLOBAL.GetTime())
							if time_left > 0 then
								text_widget:SetString(tostring(time_left))
								text_widget:Show()
							else
								text_widget:Hide()
							end
						end
					end

					cengshu:SetString(self.owner.currentcengshu:value())

					if self.owner.current_UIswitch:value() == 0 then
						v:Show()
						z:Show()
						x:Show()
						r:Show()
						n:Show()

						v:SetHoverText("快刀剪乱【"..Gwen_key_name[GetModConfigData("Gwen_Q_Key")].."】键释放\n格温将剪刀快速地开合，\n对前方锥形范围内的敌人造成伤害。\n普通攻击将积累层数。")

						----3级解锁e
						if gw_Level >= 3 then
							z:SetImageNormalColour(1,1,1,.88)
							z:SetHoverText("断续疾走【"..Gwen_key_name[GetModConfigData("Gwen_E_Key")].."】键释放\n格温向前突进一小段距离（CD5秒，移动到海上就自动退回原位）。\n释放后持续2秒附加额外伤害。")
							if self.owner.currentZkeepmianxiang:value() == 1 then
								Zkeepmianxiang:Hide()
								Znokeepmianxiang:Show()
							else
								Zkeepmianxiang:Show()
								Znokeepmianxiang:Hide()
							end
						else
							z:SetImageNormalColour(.22,.22,.22,.92)
							z:SetHoverText("断续疾走【2级解锁】\n格温向前突进一小段距离。")
							Zkeepmianxiang:Hide()
							Znokeepmianxiang:Hide()
						end

						----5级解锁w
						if gw_Level >= 5 then
							x:SetImageNormalColour(1,1,1,.88)
							x:SetHoverText("丝缕缠流【"..Gwen_key_name[GetModConfigData("Gwen_W_Key")].."】键释放\n格温召唤圣霭，持续10秒（CD30秒）。\n她在雾霭中每秒回1点圣蕴，14级以上时有在范围内有40%几率免疫所有伤害，\n获得免疫（睡眠，沙尘暴，击飞，减速）。")
						else
							x:SetImageNormalColour(.22,.22,.22,.92)
							x:SetHoverText("丝缕缠流【4级解锁】\n格温召唤圣霭。")
						end

						----7级解锁r
						if gw_Level >= 7 then
							r:SetImageNormalColour(1,1,1,.88)
							r:SetHoverText("引针簇射【"..Gwen_key_name[GetModConfigData("Gwen_R_Key")].."】键释放\n召唤【"..TUNING.FEIZHENSHULIANG.."】枚飞针，持续12秒冷却32秒，\n持续期间飞针一直存在，右键或普攻生物会自动追击。")
						else
							r:SetImageNormalColour(.22,.22,.22,.92)
							r:SetHoverText("引针簇射【6级解锁】\n格温召唤枚飞针。")
						end

						----9级解锁飞行
						if gw_Level >= 9 then
							if not self.owner:HasTag("gwen_flying") then
								n:SetImageNormalColour(1,1,1,.88)
								n:SetHoverText("起飞~【"..Gwen_key_name[GetModConfigData("Gwen_N_Key")].."】键释放\n格温消耗20点圣蔼进入飞行模式，\n期间圣蔼持续流失、增加20%移速且无法进行战斗。")
							else
								n:SetImageNormalColour(.33,.33,.33,.88)
								n:SetHoverText("着陆~【"..Gwen_key_name[GetModConfigData("Gwen_N_Key")].."】键释放\n变为行走模式。\n圣蔼不足将自动切换为行走模式")
							end
						else
							n:SetImageNormalColour(.22,.22,.22,.92)
							n:SetHoverText("飞行模式【7级解锁】\n格温进入飞行模式。")
						end

						cengshu:Show()
						cengshu_image:Show()
						UIswitch:SetHoverText("【收起】左键拖动\n(快捷键【"..Gwen_key_name[GetModConfigData("Gwen_UI_Key")].."】恢复默认位置)")
						UIswitch:SetRotation(0)

						if self.owner.currentgwen_equip:value() >= 1 then
							OffGwen_equip:Show()
							OnGwen_equip:Hide()
						else
							OffGwen_equip:Hide()
							OnGwen_equip:Show()
						end


						if self.owner.currentgwen_chengfa:value() >= 4 then
							UIsiwang:Hide()
						else
							UIsiwang:Show()
						end

						if self.owner.currentVkeepmianxiang:value() == 1 then
							Vkeepmianxiang:Hide()
							Vnokeepmianxiang:Show()
						else
							Vkeepmianxiang:Show()
							Vnokeepmianxiang:Hide()
						end

					else
						v:Hide()
						z:Hide()
						x:Hide()
						r:Hide()
						n:Hide()

						cengshu:Hide()
						cengshu_image:Hide()	
						UIswitch:SetHoverText("【展开】左键拖动\n(快捷键【"..Gwen_key_name[GetModConfigData("Gwen_UI_Key")].."】恢复默认位置)")
						UIswitch:SetRotation(180)
						UIsiwang:Hide()
						OnGwen_equip:Hide()
						OffGwen_equip:Hide()

						Vkeepmianxiang:Hide()
						Zkeepmianxiang:Hide()
						Vnokeepmianxiang:Hide()
						Znokeepmianxiang:Hide()
					end

					UIswitch:Show()
					UIfuhuo:Hide()
					fuhuonum:Hide()

				else
					v:Hide()
					z:Hide()
					x:Hide()
					r:Hide()
					n:Hide()

					cengshu:Hide()
					cengshu_image:Hide()

					Vkeepmianxiang:Hide()
					Zkeepmianxiang:Hide()
					Vnokeepmianxiang:Hide()
					Znokeepmianxiang:Hide()

					UIsiwang:Hide()
					UIswitch:Hide()
					OnGwen_equip:Hide()
					OffGwen_equip:Hide()
					UIfuhuo:Show()
					UIfuhuo:SetHoverText(fuhuo)

					fuhuonum:SetString(GetCurrent)
					if GetCurrent >= shengai_Current then
						fuhuonum:Hide()
					else
						fuhuonum:Show()
					end
				end
			end

            -- **每 0.1 秒更新 UI**
            self.inst:DoPeriodicTask(0.1, UpdateSkillCooldowns)
        end
    end)
end)
	
	
AddClassPostConstruct("widgets/controls", function(self)
	self.inst:DoTaskInTime(.5,function ()
		self.GwenSkillWidget = self:AddChild(GwenSkillWidget(self.owner))
		self.GwenSkillWidget:SetScaleMode(SCALEMODE_PROPORTIONAL)
		UpGradeMakeWidgetMovable(self.GwenSkillWidget,"GwenSkillWidget",Vector3(198,198,0))
	end)
end)



----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----技能部分
----快刀剪乱
AddModRPCHandler("gwenw", "jiiandao", function(player, x, y, z)
	if player and player:IsValid() and not player:HasTag("playerghost") then

		local hand_item = player and player.components.inventory and player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        -- **检查是否持有武器**
        if hand_item ~= nil and hand_item.prefab == "gwen_jiandao" then
			local targetpos = Vector3(x, y, z)
			--[[if player.components.gwen_competence:Get_mianxiang() == 0 and player.components.gwen_competence:Get_Vkeepmianxiang() ~= 1 then
				player:ForceFacePoint(targetpos:Get())
			end
			player.components.gwen_competence:mianxiang_0()]]
			
			local pt = player:GetPosition()
			local Gwen_jiandaoAtk = (player.components.gwen_competence and player.components.gwen_competence:Get_cengshu()) or 1
			local fx


			--- 炼金线修改为技能树判定
			-- if hand_item.components.gwen_equip:Getgw_alchemy() ~= 0 then

			if player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_cut_shadow_1") then
				fx = SpawnPrefab("gwen_canying")
				if player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_cut_shadow_2") then
					fx.Transform:SetPosition(targetpos:Get())
				else
					fx.Transform:SetPosition(pt:Get())
				end
				if player.components.gwen_competence:Get_mianxiang() == 0 and player.components.gwen_competence:Get_Vkeepmianxiang() ~= 1 
				and not (player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_cut_shadow_2") ) then
					fx:ForceFacePoint(targetpos:Get())
				else
					fx.Transform:SetRotation(player.Transform:GetRotation())
				end
				fx:SetOwner(player, Gwen_jiandaoAtk)
				fx.AnimState:PlayAnimation("cut_pre")
				fx.AnimState:PushAnimation("cut_loop",false)
			end

			-- 进入剪刀状态
			if Gwen_jiandaoAtk <= 1 then
				if not (player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_cut_shadow_1") )then
					if player.sg and player.sg:HasState("hit") and not player.sg:HasStateTag("noouthit") and not player.sg:HasStateTag("flight") and player.components.health and not player.components.health:IsDead() and not player:HasTag("playerghost") then
						player.sg:GoToState("gwenw_jiiandao_start",targetpos)
					end
				else
					if player and player:IsValid() then
						player:DoTaskInTime(.3,function()
							if not( player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_cut_shadow_2"))then
								player.gwen_jiandaofx = SpawnPrefab("gwen_jiandaofx")
								if player.gwen_jiandaofx then
									player.gwen_jiandaofx:SetOwner(player)
									player.gwen_jiandaofx.Transform:SetPosition(pt.x,pt.y+1,pt.z)
									player.gwen_jiandaofx.Transform:SetRotation(fx.Transform:GetRotation())
									-- player.gwen_jiandaofx.components.colouradder:PushColour("helmsplitter", 1, .1, 1, .1)
								end
								player.gwen_jiandaofx1 = SpawnPrefab("gwen_jiandaofx")
								if player.gwen_jiandaofx1 then
									player.gwen_jiandaofx1.AnimState:SetMultColour(0, 0, 0, .3)
									player.gwen_jiandaofx1:AddTag("fly_yingzi")
									player.gwen_jiandaofx1:SetOwner(player)
									player.gwen_jiandaofx1.Transform:SetPosition(pt.x,pt.y,pt.z)
									player.gwen_jiandaofx1.Transform:SetRotation(fx.Transform:GetRotation())
								end
							else
								player.gwen_jiandaofx = SpawnPrefab("gwen_jiandaofx")
								if player.gwen_jiandaofx then
									player.gwen_jiandaofx:SetOwner(player)
									player.gwen_jiandaofx.Transform:SetPosition(targetpos:Get())
									player.gwen_jiandaofx.Transform:SetRotation(fx.Transform:GetRotation())
									-- player.gwen_jiandaofx.components.colouradder:PushColour("helmsplitter", 1, .1, 1, .1)
								end
							end
						end)
					end
				end
			else
				for i = 1 , Gwen_jiandaoAtk do
					player:DoTaskInTime(i *.16,function()
						if not( player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_cut_shadow_1") )then
							if player.sg and player.sg:HasState("hit") and not player.sg:HasStateTag("noouthit") and not player.sg:HasStateTag("flight") and player.components.health and not player.components.health:IsDead() and not player:HasTag("playerghost") then
								player.sg:GoToState("gwenw_jiiandao",targetpos)
							end
						else
							fx.AnimState:PlayAnimation("cut_loop",false)
							if player and player:IsValid() then
								if not( player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_cut_shadow_2"))then
									player.gwen_jiandaofx = SpawnPrefab("gwen_jiandaofx")
									if player.gwen_jiandaofx then
										player.gwen_jiandaofx:SetOwner(player)
										player.gwen_jiandaofx.Transform:SetPosition(pt.x,pt.y+1,pt.z)
										player.gwen_jiandaofx.Transform:SetRotation(fx.Transform:GetRotation())
										-- player.gwen_jiandaofx.components.colouradder:PushColour("helmsplitter", 1, .1, 1, .1)
									end
									player.gwen_jiandaofx1 = SpawnPrefab("gwen_jiandaofx")
									if player.gwen_jiandaofx1 then
										player.gwen_jiandaofx1.AnimState:SetMultColour(0, 0, 0, .3)
										player.gwen_jiandaofx1:AddTag("fly_yingzi")
										player.gwen_jiandaofx1:SetOwner(player)
										player.gwen_jiandaofx1.Transform:SetPosition(pt.x,pt.y,pt.z)
										player.gwen_jiandaofx1.Transform:SetRotation(fx.Transform:GetRotation())
									end
								else
									---学习技能后变为远程
									player.gwen_jiandaofx = SpawnPrefab("gwen_jiandaofx")
									if player.gwen_jiandaofx then
										player.gwen_jiandaofx:SetOwner(player)
										player.gwen_jiandaofx.Transform:SetPosition(targetpos:Get())
										player.gwen_jiandaofx.Transform:SetRotation(fx.Transform:GetRotation())
										-- player.gwen_jiandaofx.components.colouradder:PushColour("helmsplitter", 1, .1, 1, .1)
									end
								end
							end
						end
					end)
				end
			end
			player.components.gwen_competence:mianxiang_0()
		else
            player.components.talker:Say("我必须拿着我的剪刀！") -- **提示信息**
		end
    end
end)

----断续疾走
AddModRPCHandler("corin", "rush", function(player, x, y, z)
    if player and player:IsValid() and not player:HasTag("playerghost") then

		local targetpos = Vector3(x, y, z)

        -- 限制冲刺最大距离为 3
        local px, py, pz = player.Transform:GetWorldPosition()
        local direction = (targetpos - Vector3(px, py, pz)):GetNormalized()
        local max_distance = 3
        targetpos = Vector3(px + direction.x * max_distance, py, pz + direction.z * max_distance)

        -- 进入冲刺状态
		if player.sg and player.sg:HasState("hit") and not player.sg:HasStateTag("noouthit") and not player.sg:HasStateTag("flight") and player.components.health and not player.components.health:IsDead() 
		and not player:HasTag("playerghost")
		then
			if player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_dash_radiance_1")  then
				player.sg:GoToState("gwen_collision", targetpos)
			else
				player.sg:GoToState("corin_rush", targetpos)
			end
		end

        -- **赋予强化 buff**
		local gw_Level = player.components.gwen_competence and player.components.gwen_competence:Get_gwen_Level() or 1
		if gw_Level >= 3 then
			player.gwen_buff = 1
		end
        player:DoTaskInTime(3, function()
            player.gwen_buff = nil -- **3 秒后移除 buff**
        end)
    end
end)


----丝缕缠流
AddModRPCHandler("gwenw", "zhaohuanshengai", function(player)
    if player and player:IsValid() then
		if player.components.gwen_competence and player.components.gwen_competence:Get_gwen_Level() < 4 then
			player.components.talker:Say("技能尚未解锁！")
			return
		end

		if player and player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_shengai_shadow_1") then
			local fx = SpawnPrefab("gwen_laolong")
			if fx then
				fx.Transform:SetPosition(player.Transform:GetWorldPosition())
				fx:SetOwner(player)
			end
		else
			if player and player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_shengai_radiance_1") then
				local fx = SpawnPrefab("shengaifx")
				if fx then
					fx.Transform:SetPosition(player.Transform:GetWorldPosition())
					fx.entity:SetParent(player.entity)
					fx.entity:AddFollower()
					fx.Follower:FollowSymbol(player.GUID,"swap_body",nil, nil,nil, false, nil)
					fx:SetOwner(player)
				end
			else
				local fx = SpawnPrefab("shengaifx")
				if fx then
					fx.Transform:SetPosition(player.Transform:GetWorldPosition())
				end
			end
		end
    end
end)

----引针簇射
AddModRPCHandler("gwenr", "zhaohuanfeizhen", function(player)
    if player and player:IsValid() and player.components.gwen_competence then

		local hand_item = player and player.components.inventory and player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local gw_Level = (player.components.gwen_competence and player.components.gwen_competence:Get_gwen_Level()) or 1
		local feizhennum
		if gw_Level >= 1 then
			feizhennum = TUNING.FEIZHENSHULIANG
		end
		if gw_Level >= 12 then
			feizhennum = TUNING.FEIZHENSHULIANG + 1
		end
		if gw_Level >= 17 then
			feizhennum = TUNING.FEIZHENSHULIANG + 2
		end

        -- **检查是否持有武器**
        if hand_item ~= nil and hand_item.prefab == "gwen_jiandao" then
            -- **如果之前召唤的飞针仍然存在，清理旧飞针**
            if hand_item.summonsfy ~= nil then
                for index, value in ipairs(hand_item.summonsfy) do
                    if value and value:IsValid() then
                        value:Remove() -- **移除上次召唤的飞针**
                    end
                end
            end

            -- **初始化新飞针**
            hand_item.summonsfy = {}
            for i = 1, feizhennum do
                player.feizhen = SpawnPrefab("feizhen")
				player.feizhen:SetOwner(player)
                if player.feizhen then
                    hand_item.summonsfy[i] = player.feizhen
                    player.feizhen.components.summon_controllergw:Init(player, -0.5 + 0.25 * i, hand_item, i)
                end
            end
			
			----【【新增效果，12秒内持续召唤飞针，cd32秒
			player.chixufeizhen = player:DoPeriodicTask(0.3,function()
				local hand_item = player and player.components.inventory and player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
				if player and player:IsValid() 
				and (player.components.health and not player.components.health:IsDead() and not player:HasTag("playerghost"))
				and hand_item ~= nil and hand_item.prefab == "gwen_jiandao"
				then
					player.components.gwen_competence:feizhen_1()
					for index, value in ipairs(hand_item.summonsfy) do
						if value and value:IsValid() then
							return
						else
							for i = 1, feizhennum do
								player.feizhen = SpawnPrefab("feizhen")
								player.feizhen:SetOwner(player)
								if player.feizhen then
									hand_item.summonsfy[i] = player.feizhen
									player.feizhen.components.summon_controllergw:Init(player, -0.5 + 0.25 * i, hand_item, i)
								end
							end
						end
					end

				else
					player.components.gwen_competence:feizhen_0()
					if player.chixufeizhen then
						player.chixufeizhen:Cancel()
						player.chixufeizhen = nil
					end
				end
			end)

			player:DoTaskInTime(feizhenchixu,function()
				if hand_item ~= nil and hand_item.prefab == "gwen_jiandao" then
					if hand_item.summonsfy ~= nil then
						for index, value in ipairs(hand_item.summonsfy) do
							if value and value:IsValid() then
								value:Remove() -- **移除上次召唤的飞针**
							end
						end
					end
				end
				player.components.gwen_competence:feizhen_0()
				if player.chixufeizhen ~= nil then
					player.chixufeizhen:Cancel()
					player.chixufeizhen = nil
				end
			end)
			----------------】】

        else
            player.components.talker:Say("我必须拿着我的剪刀！") -- **提示信息**
        end
    end
end)

----飞行
AddModRPCHandler("gwenr", "gw_fly", function(player)
	if player and player:IsValid() and player.components.health and not player.components.health:IsDead() then

		if player.components.rider and player.components.rider:IsRiding() then
			player.components.talker:Say("骑乘状态无法飞行！")
		end
		if player.components.rider and not player.components.rider:IsRiding() then
			if not player:HasTag("gwen_flying") then 
				if player.components.gwen_shengai then
					if player.components.gwen_shengai.current >= 20 then
						player.components.gwen_shengai:DoDelta(-20)
						player:PushEvent("gw_fly")
						player.components.talker:Say("我也会飞啦~")
					else
						player.components.talker:Say("圣蔼不足没法起飞嗷~")
					end
				end
			else
				local x, y, z = player.Transform:GetWorldPosition()
				local local_passable = TheWorld.Map:IsPassableAtPoint(x, 0, z)
				if not local_passable then
					player.components.talker:Say("我可不想掉进海里喂鱼！")
				else
					player:PushEvent("gw_fly")
				end
			end
		end
	end
end)

----ui隐藏
AddModRPCHandler("gwenr", "UIswitch", function(player)
    if player and player:IsValid() then
		if player.components.gwen_competence:Get_UIswitch() == 0 then
			player.components.gwen_competence:UIswitch_1()
		else
			player.components.gwen_competence:UIswitch_0()
		end
    end
end)


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----复活
AddModRPCHandler("gwenr", "querenfuhuo", function(player)
    if player and player:IsValid() then
		if player:HasTag("playerghost")and player.components.gwen_shengai then
			local x, y, z = player.Transform:GetWorldPosition()
			local local_passable = TheWorld.Map:IsPassableAtPoint(x, 0, z)
			if local_passable then
				player:PushEvent("respawnfromghost", { source = player })
				player.components.gwen_shengai:DoDelta(-player.components.gwen_shengai.max)
				player.components.gwen_competence:Set_gwen_chengfa(player.components.gwen_competence:Get_gwen_chengfa())
				if player.gwen_wawa ~= nil then
					player.gwen_wawa:Remove()
					player.gwen_wawa = nil
				end
			else
				player:PushEvent("wawa_tiao")
				player.components.talker:Say("这里没法站稳啊啊啊啊！")
			end
		end
    end
end)

AddModRPCHandler("gwenr", "quxiaofuhuo", function(player)
    if player and player:IsValid() then
		if player:HasTag("playerghost")and player.components.gwen_shengai then
			player:PushEvent("wawa_tiao")
			player.components.talker:Say("那就蹦蹦吧")
		end
    end
end)

function UIfuhuo(inst)
	TheFrontEnd:PushScreen(PopupDialogScreen("", "要恢复人形吗，复活了哟\n　",{
	{text = "要！", cb =  function()
		TheFrontEnd:PopScreen()
		SendModRPCToServer(GetModRPC("gwenr", "querenfuhuo"))
	end},
	{text = "先不啦", cb =  function()
		TheFrontEnd:PopScreen()
		SendModRPCToServer(GetModRPC("gwenr", "quxiaofuhuo"))
	end},
}))end

AddClientModRPCHandler("gwenr", "fuhuofuhuo", function(inst) ----客户端触发
	UIfuhuo(inst)
end)

AddModRPCHandler("gwenr", "UIfuhuo", function(player)
    if player and player:IsValid() then
		if player:HasTag("playerghost")
		and player.components.gwen_shengai and player.components.gwen_competence
		then
			local x, y, z = player.Transform:GetWorldPosition()
			local local_passable = TheWorld.Map:IsPassableAtPoint(x, 0, z)

			local gw_Level = (player.components.gwen_competence and player.components.gwen_competence:Get_gwen_Level()) or 1
			local GetCurrent = (player.components.gwen_shengai and player.components.gwen_shengai:GetCurrent()) or 0
			local shengai_Current
			if gw_Level >= 1 then
				shengai_Current = 80
			end
			if gw_Level >= 10 then
				shengai_Current = 60
			end
			if gw_Level >= 16 then
				shengai_Current = 40
			end

			if GetCurrent >= shengai_Current then
				SendModRPCToClient(CLIENT_MOD_RPC["gwenr"]["fuhuofuhuo"],player.userid) ----客户端发送
			else
				player:PushEvent("wawa_tiao")
				player.components.talker:Say("圣蔼不足没法维持人形啊啊啊！")
			end
		end
    end
end)
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----死亡
AddModRPCHandler("gwenr", "querensiwang", function(player)
    if player and player:IsValid() then
		if player.components.health and player.components.gwen_shengai and not player:HasTag("playerghost") then
			player.components.gwen_shengai:DoDelta(-player.components.gwen_shengai.max)
			player.components.health:SetPercent(0)
			player.components.health:DoDelta(-player.components.health.maxhealth-1,nil,nil,true,nil,true)
			player.components.gwen_competence:Incr_gwen_chengfa(1)
		end
    end
end)

function UIsiwang(inst)
	TheFrontEnd:PushScreen(PopupDialogScreen("", "要变成娃娃吗，会死的哟~\n　",{
	{text = "要！", cb =  function()
		TheFrontEnd:PopScreen()
		SendModRPCToServer(GetModRPC("gwenr", "querensiwang"))
	end},
	{text = "别了吧", cb =  function()
		TheFrontEnd:PopScreen()
	end},
}))end

AddClientModRPCHandler("gwenr", "siwangsiwang", function(inst) ----客户端触发
	UIsiwang(inst)
end)

AddModRPCHandler("gwenr", "UIsiwang", function(player)
    if player and player:IsValid() and player.components.health and not player.components.health:IsDead() then
		SendModRPCToClient(CLIENT_MOD_RPC["gwenr"]["siwangsiwang"],player.userid) ----客户端发送
    end
end)
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----面向
AddModRPCHandler("gwenr", "Vkeepmianxiang", function(player)
    if player and player:IsValid() then
		if player.components.gwen_competence:Get_Vkeepmianxiang() == 0 then
			player.components.gwen_competence:Vkeepmianxiang_1()
		else
			player.components.gwen_competence:Vkeepmianxiang_0()
		end
    end
end)

AddModRPCHandler("gwenr", "Zkeepmianxiang", function(player)
    if player and player:IsValid() then
		if player.components.gwen_competence:Get_Zkeepmianxiang() == 0 then
			player.components.gwen_competence:Zkeepmianxiang_1()
		else
			player.components.gwen_competence:Zkeepmianxiang_0()
		end
    end
end)

AddModRPCHandler("gwenr", "mianxiang", function(player)
    if player and player:IsValid() then
		player.components.gwen_competence:mianxiang_1()
    end
end)
----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----隐藏外甲
AddModRPCHandler("gwenr", "UIyincang", function(player)
	if player and player:IsValid() then
		if player.components.gwen_competence:Get_gwen_equip() == 0 then
			player.components.gwen_competence:OnGwen_equip()
			player:PushEvent("OnGwen_equip")
		else
			player.components.gwen_competence:OffGwen_equip()
			player:PushEvent("OffGwen_equip")
		end
	end
end)

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
----背包修复
local function stop_gw_xiufu(player)
	player:RemoveTag("gw_xiufu")
	if player.gw_xiufu then
		player.gw_xiufu:Cancel()
		player.gw_xiufu = nil
	end
end

local gwxiufutiem = .33
local xiaohao = -5
local dohealth = 0

local function start_gwxiufu(player)
	player.AnimState:PlayAnimation("build_loop", true)

    local repair_ratio = TUNING.BEIBAOXIULI
    if player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_xiubu_1") then
        xiaohao = -4
        repair_ratio = repair_ratio * 1.2
    end

	if player.components.skilltreeupdater and player.components.skilltreeupdater:IsActivated("gwen_xiubu_2") then
		dohealth = player.components.health.maxhealth * 0.02
    end

	for k,v in pairs(player.components.inventory.opencontainers) do
		if k and k:HasTag("gwen_backpack") and k.components.container then
			for i = 1, 2 do
				local item = k.components.container:GetItemInSlot(i)
				if item ~= nil then
					-- 如果设置了不修建造拆解物品，且物品为greenstaff或greenamulet，则不进行修复
					if TUNING.XIUBUXIUCHAIJIEJIANZAO == false and (item.prefab == "greenstaff" or item.prefab == "greenamulet") then
						player.components.talker:Say("此物品不许修理喵")
						stop_gw_xiufu(player)
						return
					end

					if (item.components.finiteuses and item.components.finiteuses:GetPercent() >= 1)
					or (item.components.armor and item.components.armor:GetPercent() >= 1)
					or (item.components.fueled and item.components.fueled:GetPercent() >= 1)
					then
						player.components.talker:Say("物品不用修理哟")
						stop_gw_xiufu(player)

					elseif (item.components.finiteuses and item.components.finiteuses:GetPercent() == 0)
					or (item.components.armor and item.components.armor:GetPercent() == 0)
					or (item.components.ed and item.components.fueled:GetPercent() == 0)
					then
						player.components.talker:Say("此物品没法修理了喵")
						stop_gw_xiufu(player)

					elseif not (item.components.finiteuses or item.components.armor or item.components.fueled)
					then
						player.components.talker:Say("物品无法修理哟")
						stop_gw_xiufu(player)
					else
						if item.components.finiteuses then
							-- 如果物品有finiteuses组件，增加其使用次数
							player.components.gwen_shengai:DoDelta(xiaohao)
							
							player.components.health:DoDelta(dohealth)
							item:AddTag("start_gwxiufu")
							item:DoTaskInTime(gwxiufutiem, function()
								if item ~= nil then
									local uses = item.components.finiteuses:GetUses()
									local max_uses = item.components.finiteuses.total
									item.components.finiteuses:SetUses(math.min(uses + max_uses * repair_ratio, max_uses))
									item:RemoveTag("start_gwxiufu")
								end
							end)
						elseif item.components.armor then
							-- 如果物品有armor组件，增加其耐久百分比

							player.components.gwen_shengai:DoDelta(xiaohao)

							player.components.health:DoDelta(dohealth)
							item:AddTag("start_gwxiufu")
							item:DoTaskInTime(gwxiufutiem, function()
								if item ~= nil then
									local armor = item.components.armor:GetPercent()
									item.components.armor:SetPercent(math.min(armor + repair_ratio, 1))
									item:RemoveTag("start_gwxiufu")
								end
							end)
						elseif item.components.fueled then
							-- 如果物品有fueled组件，增加其燃料百分比

							player.components.gwen_shengai:DoDelta(xiaohao)

							player.components.health:DoDelta(dohealth)
							item:AddTag("start_gwxiufu")
							item:DoTaskInTime(gwxiufutiem, function()
								if item ~= nil then
									local fuel = item.components.fueled:GetPercent()
									item.components.fueled:SetPercent(math.min(fuel + repair_ratio, 1))
									item:RemoveTag("start_gwxiufu")
								end
							end)
						end
						player:DoTaskInTime(gwxiufutiem, function()
							local battlesong_fx = {
								battlesong_durability_fx = .25,
								battlesong_healthgain_fx = .25,
								battlesong_sanitygain_fx = .25,
								battlesong_sanityaura_fx = .25,
								battlesong_fireresistance_fx = .25,
							}
							local fx = SpawnPrefab(weighted_random_choice(battlesong_fx))
							fx.entity:SetParent(player.entity)
							fx.Transform:SetPosition(0, 0, 0)
							--fx.Transform:SetScale(.3,.3,.3)
							fx:ListenForEvent("animover", fx.Remove)
						end)
						SendModRPCToClient(CLIENT_MOD_RPC["LegionMsg"]["gw_UiRefresh"],player.userid) ----客户端发送
					end
				end
			end
		end
	end
end


----背包修复
AddModRPCHandler("gwenr", "gw_xiufu", function(player)
    if player and player:IsValid() and player.components.gwen_shengai and not player:HasTag("playerghost") and player:HasTag("gwen") then
		stop_gw_xiufu(player)
		if player.components.gwen_shengai.current < 5 then
			player.components.talker:Say("圣霭不足喵~")
			return
		else
			player:AddTag("gw_xiufu")
			if player.gw_xiufu == nil then
				player.AnimState:PlayAnimation("build_pre")
				player.AnimState:PushAnimation("build_loop",true)
				player.gw_xiufu = player:DoPeriodicTask(1,function()
					if player.components.inventory and player.components.inventory.opencontainers then
						start_gwxiufu(player)
					end
					if player.components.gwen_shengai.current < 5 then
						player.components.talker:Say("圣霭不足喵~")
						stop_gw_xiufu(player)
						return
					end
					if not player:HasTag("gw_xiufu") then
						stop_gw_xiufu(player)
						return
					end
				end)
			end
		end
    end
end)


--[[
AddModRPCHandler("gwenr", "gw_xiufu", function(player)
	if player and player:IsValid() and player.components.gwen_shengai and not player:HasTag("playerghost") and player:HasTag("gwen") then
		if player.components.gwen_shengai.current < 20 then
			player.components.talker:Say("圣霭不足喵~")
		else
			for k,v in pairs(player.components.inventory.opencontainers) do
				if k and k:HasTag("gwen_backpack") and k.components.container then
					for i = 1, 2 do
						local item = k.components.container:GetItemInSlot(i)
						if item ~= nil then
							-- 如果设置了不修建造拆解物品，且物品为greenstaff或greenamulet，则不进行修复
							if TUNING.XIUBUXIUCHAIJIEJIANZAO == false and (item.prefab == "greenstaff" or item.prefab == "greenamulet") then
								player.components.talker:Say("此物品不许修理喵")
								return
							end

							if (item.components.finiteuses and item.components.finiteuses:GetPercent() >= 1)
							or (item.components.armor and item.components.armor:GetPercent() >= 1)
							or (item.components.fueled and item.components.fueled:GetPercent() >= 1)
							then
								player.components.talker:Say("物品不用修理哟")

							elseif (item.components.finiteuses and item.components.finiteuses:GetPercent() == 0)
							or (item.components.armor and item.components.armor:GetPercent() == 0)
							or (item.components.ed and item.components.fueled:GetPercent() == 0)
							then
								player.components.talker:Say("此物品没法修理了喵")

							elseif not (item.components.finiteuses or item.components.armor or item.components.fueled)
							then
								player.components.talker:Say("物品无法修理哟")

							else
								if player.sg 
								and player.sg:HasState("hit") 
								and not player.sg:HasStateTag("noouthit") 
								and not player.sg:HasStateTag("flight")
								and not player.sg:HasStateTag("attack")
								and not player.sg:HasStateTag("moving")
								and not player.sg:HasStateTag("running")
								and player.components.health and not player.components.health:IsDead() and not player:HasTag("playerghost")
								then
									player.sg:GoToState("gwenw_xiuli")
									if item.components.finiteuses then
										-- 如果物品有finiteuses组件，增加其使用次数
										local uses = item.components.finiteuses:GetUses()
										local max_uses = item.components.finiteuses.total
										item.components.finiteuses:SetUses(math.min(uses + max_uses * TUNING.BEIBAOXIULI, max_uses))
										player.components.gwen_shengai:DoDelta(-20)
									elseif item.components.armor then
										-- 如果物品有armor组件，增加其耐久百分比
										local armor = item.components.armor:GetPercent()
										item.components.armor:SetPercent(math.min(armor + TUNING.BEIBAOXIULI, 1))
										player.components.gwen_shengai:DoDelta(-20)
									elseif item.components.fueled then
										-- 如果物品有fueled组件，增加其燃料百分比
										local fuel = item.components.fueled:GetPercent()
										item.components.fueled:SetPercent(math.min(fuel + TUNING.BEIBAOXIULI, 1))
										player.components.gwen_shengai:DoDelta(-20)
									end
								end
							end
						end
					end
				end
			end
		end
    end
end)
]]


----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----

-- **监听按键释放技能**
GLOBAL.TheInput:AddKeyHandler(function(key, down)
    if down then
        local player = GLOBAL.ThePlayer
        if player and player:IsValid() and not player:HasTag("playerghost") and player:HasTag("gwen")
		and player.replica.gwen_competence
		then
            InitSkillCooldown(player)  -- 确保冷却表初始化
			local gw_Level = player.replica.gwen_competence and player.replica.gwen_competence:Get_gwen_Level() or 1

            -- **检查冷却并执行技能**
			if key == Gwen_Q_Key and gw_Level >= 1 and Gwen_Q_Key < 1000 then
                if IsSkillOnCooldown(player, "V") then
                    player.components.talker:Say("快刀剪乱冷却中 (" .. math.ceil(player.skill_cooldowns["V"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 剪刀动作
					local x, y, z = GLOBAL.TheInput:GetWorldPosition():Get()
                    SendModRPCToServer(MOD_RPC["gwenw"]["jiiandao"], x, y, z)
                    StartSkillCooldown(player, "V", SKILL_CD.V)
                end

            elseif key == Gwen_E_Key and gw_Level >= 3 and Gwen_E_Key < 1000 then
                if IsSkillOnCooldown(player, "Z") then
                    player.components.talker:Say("断续疾走冷却中 (" .. math.ceil(player.skill_cooldowns["Z"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 冲刺技能
                    local x, y, z = GLOBAL.TheInput:GetWorldPosition():Get()
                    SendModRPCToServer(MOD_RPC["corin"]["rush"], x, y, z)
                    StartSkillCooldown(player, "Z", SKILL_CD.Z)
                end

            elseif key == Gwen_W_Key and gw_Level >= 5 and Gwen_W_Key < 1000 then
                if IsSkillOnCooldown(player, "X") then
                    player.components.talker:Say("丝缕缠流冷却中 (" .. math.ceil(player.skill_cooldowns["X"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 召唤圣蔼领域
                    SendModRPCToServer(MOD_RPC["gwenw"]["zhaohuanshengai"])
                    StartSkillCooldown(player, "X", SKILL_CD.X)
                end

            elseif key == Gwen_R_Key and gw_Level >= 7 and Gwen_R_Key < 1000 then
                if IsSkillOnCooldown(player, "R") then
                    player.components.talker:Say("引针簇射冷却中 (" .. math.ceil(player.skill_cooldowns["R"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 飞针大招
                    SendModRPCToServer(MOD_RPC["gwenr"]["zhaohuanfeizhen"])
                    StartSkillCooldown(player, "R", SKILL_CD.R)
                end

            elseif key == Gwen_N_Key and gw_Level >= 9 and Gwen_N_Key < 1000 then
                if IsSkillOnCooldown(player, "N") then
                    player.components.talker:Say("切换模式冷却中 (" .. math.ceil(player.skill_cooldowns["N"] - GLOBAL.GetTime()) .. "s)")
                else
					SendModRPCToServer(MOD_RPC["gwenr"]["gw_fly"])
                    StartSkillCooldown(player, "N", SKILL_CD.N)
                end
            end
        end
    end
end)

-- **监听按键释放技能**
GLOBAL.TheInput:AddMouseButtonHandler(function(button, down)
    if not down then
        local player = GLOBAL.ThePlayer
        if player and player:IsValid() and not player:HasTag("playerghost") and player:HasTag("gwen")
		and player.replica.gwen_competence
		then
            InitSkillCooldown(player)  -- 确保冷却表初始化
			local gw_Level = player.replica.gwen_competence and player.replica.gwen_competence:Get_gwen_Level() or 1

            -- **检查冷却并执行技能**
            if button == Gwen_Q_Key and gw_Level >= 1 and Gwen_Q_Key > 1000 then
                if IsSkillOnCooldown(player, "V") then
                    player.components.talker:Say("快刀剪乱冷却中 (" .. math.ceil(player.skill_cooldowns["V"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 剪刀动作
					local x, y, z = GLOBAL.TheInput:GetWorldPosition():Get()
                    SendModRPCToServer(MOD_RPC["gwenw"]["jiiandao"], x, y, z)
                    StartSkillCooldown(player, "V", SKILL_CD.V)
                end

            elseif button == Gwen_E_Key and gw_Level >= 3 and Gwen_E_Key > 1000 then
                if IsSkillOnCooldown(player, "Z") then
                    player.components.talker:Say("断续疾走冷却中 (" .. math.ceil(player.skill_cooldowns["Z"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 冲刺技能
                    local x, y, z = GLOBAL.TheInput:GetWorldPosition():Get()
                    SendModRPCToServer(MOD_RPC["corin"]["rush"], x, y, z)
                    StartSkillCooldown(player, "Z", SKILL_CD.Z)
                end

            elseif button == Gwen_W_Key and gw_Level >= 5 and Gwen_W_Key > 1000 then
                if IsSkillOnCooldown(player, "X") then
                    player.components.talker:Say("丝缕缠流冷却中 (" .. math.ceil(player.skill_cooldowns["X"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 召唤圣蔼领域
                    SendModRPCToServer(MOD_RPC["gwenw"]["zhaohuanshengai"])
                    StartSkillCooldown(player, "X", SKILL_CD.X)
                end

            elseif button == Gwen_R_Key and gw_Level >= 7 and Gwen_R_Key > 1000 then
                if IsSkillOnCooldown(player, "R") then
                    player.components.talker:Say("引针簇射冷却中 (" .. math.ceil(player.skill_cooldowns["R"] - GLOBAL.GetTime()) .. "s)")
                else
                    -- 飞针大招
                    SendModRPCToServer(MOD_RPC["gwenr"]["zhaohuanfeizhen"])
                    StartSkillCooldown(player, "R", SKILL_CD.R)
                end

            elseif button == Gwen_N_Key and gw_Level >= 9 and Gwen_N_Key > 1000 then
                if IsSkillOnCooldown(player, "N") then
                    player.components.talker:Say("切换模式冷却中 (" .. math.ceil(player.skill_cooldowns["N"] - GLOBAL.GetTime()) .. "s)")
                else
					SendModRPCToServer(MOD_RPC["gwenr"]["gw_fly"])
                    StartSkillCooldown(player, "N", SKILL_CD.N)
                end
            end
        end
    end
end)



local Gwen_InputKey = {}
AddPlayerPostInit(function(inst)
	inst:DoTaskInTime(0, function()
		if inst == GLOBAL.ThePlayer then
			if inst.prefab ~= nil then 
				Gwen_InputKey[0] = TheInput:AddKeyUpHandler(Gwen_UI_Key, function()
					local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
            		local IsHUDActive = screen and screen.name == "HUD"
            		if inst:IsValid() and IsHUDActive then
						if inst.HUD ~= nil and inst.HUD.controls ~= nil and inst.HUD.controls.GwenSkillWidget ~= nil then
							inst.HUD.controls.GwenSkillWidget:SetPosition(198, 198)
						end
					end
				end)
			else
				Gwen_InputKey[0] = nil
			end
		end
	end)
end)

----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----[]----
---开局重置技能树部分
local function ResetSkillTree(player)
    if not (player and player.prefab == "gwen") then
        return
    end
    local updater = player.components.skilltreeupdater
    if not updater then
        return
    end
    updater:SetSkipValidation(true)
    local activated = updater:GetActivatedSkills()
    if activated then
        for skill, _ in pairs(activated) do
            updater:DeactivateSkill(skill)
        end
    end
    updater:SetSkipValidation(false)
    SendModRPCToClient(CLIENT_MOD_RPC["gwen_skill"]["removedianshu"], player.userid)
    if player.components.gwen_competence then
        player.components.gwen_competence.level_up_granted = 0
    end
end

AddModRPCHandler("gwen_skill", "confirm_reset", function(player)
    if player and player.prefab == "gwen" then
        local gw_Level = (player.components.gwen_competence and player.components.gwen_competence:Get_gwen_Level()) or 1
        if gw_Level == 1 then
            ResetSkillTree(player)
        end
    end
end)

AddClientModRPCHandler("gwen_skill", "show_reset_dialog", function(userid)
    local player = GLOBAL.ThePlayer
    if player and player.prefab == "gwen" then
        TheFrontEnd:PushScreen(PopupDialogScreen(
            "格温开启了新的旅途",
            "你需要重置你的技能树",
            {
                {
                text = "我选择重置",
                cb = function()
                    TheFrontEnd:PopScreen()
                    SendModRPCToServer(GetModRPC("gwen_skill", "confirm_reset"))
                end
                }
            }
        ))
    end
end)

local function OnNewGwenSpawn(world, player)
    if player.prefab == "gwen" then
        local gw_Level = (player.components.gwen_competence and player.components.gwen_competence:Get_gwen_Level()) or 1
        if gw_Level == 1 then
            SendModRPCToClient(CLIENT_MOD_RPC["gwen_skill"]["show_reset_dialog"], player.userid)
        end
    end
end

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then return end
    TheWorld:ListenForEvent("ms_playerjoined", OnNewGwenSpawn)
end)


AddClientModRPCHandler("gwen_skill", "removedianshu", function(userid, data)
    local player = ThePlayer
    if player and player.prefab == "gwen" then
        local updater = player.components.skilltreeupdater
        if updater then
            updater.skilltree.skillxp["gwen"] = 0
            updater.skilltree:UpdateSaveState("gwen")
        end
    end
end)