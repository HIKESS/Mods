
name = "小小格温 Gwen"  ---mod名字
description = ""  --mod描述
author = "芝士,音音,冷冷月,Voracious" --作者
version = "3.0.2" -- mod版本 上传mod需要两次的版本不一样

forumthread = ""

api_version = 10 --api版本

dst_compatible = true --兼容联机

dont_starve_compatible = false --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

all_clients_require_mod = true --所有人mod

icon_atlas = "modicon.xml" --mod图标
icon = "modicon.tex"

server_filter_tags = {  --服务器标签
"character","格温", "gwen"
}
priority = -100000

--[[
local gwen_Key_data = {}
local e_Key_List = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","无"}
local KEY_A = 97
for i = 1,#e_Key_List do
	gwen_Key_data[i] = {description = e_Key_List[i], data = i + KEY_A - 1}
end]]

local alpha = {"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"}
local alpha2 = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P",
                "Q","R","S","T","U","V","W","X","Y","Z","无"}
local alpha3 = {"Num 0","Num 1","Num 2","Num 3","Num 4","Num 5","Num 6","Num 7",
                "Num 8","Num 9","Num .","Num /","Num *","Num -","Num +"}
local offsets = {281, 96, 255}
local alphas = {alpha, alpha2, alpha3}
local gwen_Key_data = {}

-- 添加键盘按键
for index = 1, #alphas do
    local alphaSet = alphas[index]
    for i = 1, #alphaSet do
        local key = alphaSet[i]
        gwen_Key_data[#gwen_Key_data + 1] = {description = key, data = i + offsets[index]}
    end
end

-- 添加鼠标按键
local mouseButtons = {
    {description = "\238\132\130", data = 1002}, -- 鼠标中键
    {description = "\238\132\132", data = 1005}, -- 鼠标侧键4
    {description = "\238\132\131", data = 1006}, -- 鼠标侧键5
}

-- 将鼠标按键添加到键位选项
for i = 1, #mouseButtons do
    gwen_Key_data[#gwen_Key_data + 1] = mouseButtons[i]
end


configuration_options = {

	{name = "Gwen_UI_Key",
	label = "重置UI位置 Reset UI",
	hover = "重置UI位置\nReset UI",
	options = gwen_Key_data,
	default = 108,},

	{name = "",
	label = "技能快捷键 Skill shortcut keys",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},

	{name = "Gwen_Q_Key",
	label = "快刀剪乱 Q",
	hover = "快刀剪乱\nQ",
	options = gwen_Key_data,
	default = 118,},
	
	{name = "Gwen_E_Key",
	label = "断续疾走 E",
	hover = "断续疾走\nE",
	options = gwen_Key_data,
	default = 122,},
	
	{name = "Gwen_W_Key",
	label = "丝缕缠流 W",
	hover = "丝缕缠流\nW",
	options = gwen_Key_data,
	default = 120,},
	
	{name = "Gwen_R_Key",
	label = "引针簇射 R",
	hover = "引针簇射\nR",
	options = gwen_Key_data,
	default = 114,},
	
	{name = "Gwen_N_Key",
	label = "飞行模式 N",
	hover = "飞行模式\nN",
	options = gwen_Key_data,
	default = 110,},
	
	{name = "",
	label = "模组配置",
	hover = "",
	options = {
	{description = "", data = 0},
	},default = 0},
    {
        name = "gewenxiuli",
        label = "背包修理恢复的耐久 Repair",
        hover = "背包每次修理恢复的耐久\n(The durability of the backpack is restored every time it is repaired)",
        options = {		
            { description = "1%", data = 0.01 },	
            { description = "2%", data = 0.02 },	
            { description = "3%", data = 0.03 },	
            { description = "4%", data = 0.04 },	
            { description = "5%", data = 0.05 },	
        },
        default = .03
    },
    {
        name = "gewenchaijie",
        label = "拆解需要的物品耐久下限 disassembling",
        hover = "拆解物品时需要的物品耐久下限\n(The minimum durability required for items when disassembling them)",
        options = {		
            { description = "100%",data = 1 },	
            { description = "80%", data = 0.8 },	
            { description = "60%", data = 0.6 },	
            { description = "40%", data = 0.4 },	
            { description = "20%", data = 0.2 },	
            { description = "不需要耐久", data = 0 },	
        },
        default = 0.8
    },
    {
        name = "Gwen_jiandaodamage",
        label = "剪刀攻击力配置(Scissor attack power)",
        hover = "初始剪刀的攻击\n(Initial scissor attack)",
        options = {
            { description = "50%", data = .5 },
            { description = "80%", data = .8 },
            { description = "100%", data = 1 },
            { description = "130%", data = 1.3 },
            { description = "150%", data = 1.5 },
        },
        default = 1
    },
    {
        name = "feizhenshuliang",
        label = "可召唤的飞针数量(Number of flying needles)",
        hover = "使用剪刀可召唤的飞针数量\n(The number of flying needles that can be summoned using scissors)",
        options = {	
            { description = "2", data = 2 },
            { description = "3（默认）", data = 3 },
            { description = "4", data = 4 },
            { description = "5", data = 5 },
            { description = "6", data = 6 },
        },
        default = 3
    },	
    {
        name = "baifenbishanghai",
        label = "千疮百孔 in a disastrous state",
        hover = "攻击附带的百分比伤害\n(Percentage damage attached to the attack)",
        options = {		

            { description = "0.1%", data = 0.001 },		
            { description = "0.4%", data = 0.004 },
            { description = "0.6%（默认）", data = 0.006 },			
            { description = "1%", data = 0.01 },		
            { description = "1.5%", data = 0.015 },
            { description = "3%", data = 0.03 },
        },
        default = 0.006
    },
    {
        name = "shengaijianshang",
        label = "圣蔼抵御 defend with shengai",
        hover = "圣蔼能抵挡多少伤害\n(Percentage damage reduction effect)",
        options = {		

            { description = "50%默认）", data = 0.5 },		
            { description = "100%", data = 1 },
        },
        default = 0.5
    },
    {
        name = "Qcd",
        label = "快刀乱剪冷却 Q skill cooldown",
        hover = "快刀乱剪的冷却时间\n(Cooldown time for Q skill)",
        options = {		
            { description = "5秒", data = 5 },
            { description = "4秒", data = 4 },
            { description = "3秒（默认）", data = 3 },
            { description = "2秒", data = 2 },
            { description = "1秒", data = 1 },
        },
        default = 3
    },
    {
        name = "geibugeilvbaoshi",
        label = "拆解配置(Disassemble)",
        hover = "剪刀拆解物品是否返还绿宝石\n(Did the scissors dismantle the item and return the emerald)",
        options = {
            { description = "返还绿宝石 Yes", data = true },
            { description = "不返还绿宝石 No", data = false },			
        },
        default = false
    },
    {
        name = "xiubuxiuchaijiejianzao",
        label = "修补配置(Fix)",
        hover = "修补包是否修复建造护符和拆解法杖\n(Does the repair kit repair the construction talisman and disassembly wand)",
        options = {
            { description = "修复 Yes", data = true },
            { description = "不修复 No", data = false },			
        },
        default = false
    },	
    {
        name = "dash_man",
        label = "正义冲拳音效",
        hover = "正义冲拳是否附带特殊音效\n(Does Justice Punch come with special sound effects)",
        options = {
            { description = "开启 Yes", data = true },
            { description = "关闭 No", data = false },			
        },
        default = false
    },	
    --[[{
        name = "beibaofanxianma",
        label = "返鲜配置(Preservation)",
        hover = "修补包是否返鲜\n(Is the repair package returned fresh)",
        options = {
            { description = "返鲜（默认）Returning to Fresh", data = 3 },
            { description = "保鲜 Retain freshness", data = 2 },
            { description = "不返鲜和保鲜 No", data = 1 },			
        },
        default = 3
    },	]]	
    {
        name = "gw_lengcaijiacheng",
        label = "棱彩重构攻击加成 Edge color reconstruction attack bonus",
        hover = "棱彩重构攻击加成\n(Edge color reconstruction attack bonus)",
        options = {		

            { description = "20%（默认）", data = 1.2 },		
            { description = "40%", data = 1.4 },
            { description = "60%", data = 1.6 },
        },
        default = 1.2
    },
	
}	
--configuration_options = {} --mod设置