local language=aipGetModConfig("language")
local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local aip_nectar_config=require("prefabs/aip_nectar_config")
local NEC_COLORS=aip_nectar_config.QUALITY_COLORS


local QUALITY_COLORS={

{ 255,255,255 },

NEC_COLORS.quality_2,

NEC_COLORS.quality_3,

NEC_COLORS.quality_4,

NEC_COLORS.quality_5,
}

local QUALITY_LANG={
english={
"Normal",
"Nice",
"Great",
"Outstanding",
"Perfect",
},
chinese={
"普通的",
"优秀的",
"精良的",
"杰出的",
"完美的",
},
}

























































local SKILL_LANG={
english={
shedding="Picker",
aggressive="Aggressive",
conservative="Conservative",
cowardly="Cautious",
accompany="Accompany",
alone="Long Wolf",
eloquence="Eloquence",
insight="Insight",
cool="Ice-Cold",
hot="Fiery",
cure="Cure",
winterSwim="Winter-Swimer",
acupuncture="Acupuncture",
taster="Cast-Iron Stomach",
luna="Luna",
hypnosis="Hypnosis",
sponge="Sponge",
dancer="Dancer",
d4c="D4C",
dig="Digger",
ge="Gold Experience",
play="Play Rough",
migao="Migao",
johnWick="John Wick",
graveCloak="Gravekeeper's Cloak",
cooker="Cooker",
giants="Giants",
lucky="Rabbit Foot",
blasphemy="Blasphemy",
muddy="Muddy",
bubble="Lighten Bubble",
shrimp="Shrimp Punch",
resonance="Resonance",
rainbow="Rainbow",
balrog="Balrog",
hotDog="Hot Dog",
coldDog="Cold Dog",
steal="Steal",
defend="Shatter Armor",
brightshadeKiller="Brightshade Killer",
},
chinese={
shedding="捡拾",
aggressive="好斗",
conservative="保守",
cowardly="谨慎",
accompany="陪伴",
alone="孤狼",
eloquence="游说",
insight="伯乐",
cool="冰凉",
hot="炙热",
cure="治愈",
winterSwim="泷泓",
acupuncture="针灸",
taster="铁胃",
luna="逐月",
hypnosis="催眠",
sponge="海绵",
dancer="蝶舞",
d4c="恶行易施",
dig="掘地",
ge="茸茸",
play="嬉闹",
migao="米糕",
johnWick="杀神",
graveCloak="陵卫斗篷",
cooker="厨神",
giants="巨兽",
lucky="兔脚",
blasphemy="亵渎",
muddy="泥泞",
bubble="光媒",
shrimp="虾拳",
resonance="执念",
rainbow="淋雨声",
balrog="青尘",
hotDog="炎之雀跃",
coldDog="霜之哀伤",
steal="偷窃",
defend="碎甲",
brightshadeKiller="亮茄杀手",
},
}


local SKILL_MAX_LEVEL={
shedding={ 1,2,3,4,5 },
aggressive={ 5,10,15,20,25 },
conservative={ 4,8,12,16,20 },
cowardly={ 2,4,6,8,10 },
accompany={ 5,6,7,8,10 },
alone={ 1,2,3,4,5 },
eloquence={ 2,4,6,8,10 },
insight={ 5,10,15,20,25 },
cool={ 1,1,1,1,1 },
hot={ 1,1,1,1,1 },
cure={ 1,2,3,4,5 },
winterSwim={ 1,1,1,1,1 },
acupuncture={ 10,20,30,40,50 },
taster={ 1,1,1,1,1 },
luna={ 1,1,1,1,1 },
hypnosis={ 5,10,15,20,25 },
sponge={ 5,6,7,8,10 },
dancer={ 5,6,7,8,10 },
d4c={ 1,1,1,1,1 },
dig={ 1,2,3,4,5 },
ge={ 6,7,8,9,10 },
play={ 1,2,3,4,5 },
migao={ 2,4,6,8,10 },
johnWick={ 5,6,7,8,10 },
graveCloak={ 1,2,3,4,5 },
cooker={ 5,6,7,8,9 },
giants={ 1,2,3,4,5 },
lucky={ 1,1,2,2,3 },
blasphemy={ 1,1,1,1,1 },
muddy={ 5,6,7,8,10 },
bubble={ 1,2,3,4,5 },
shrimp={ 10,12,14,16,20 },
resonance={ 1,2,3,4,5 },
rainbow={ 1,1,1,1,1 },
balrog={ 4,5,6,7,8 },
hotDog={ 1,2,3,4,5 },
coldDog={ 1,2,3,4,5 },
steal={ 1,2,3,4,5 },
defend={ 6,7,8,9,10 },
brightshadeKiller={ 2,4,6,8,10 },
}

local dt=TUNING.TOTAL_DAY_TIME
local dt_base=dt*3.5
local san=TUNING.DAPPERNESS_TINY/1.33


local SKILL_CONSTANT={
shedding={
base=dt_base,
multi=dev_mode and dt_base or (dt/2),
},
aggressive={
multi=0.01,
},
conservative={
multi=0.01,
},
cowardly={
multi=dev_mode and 1 or 0.01,
duration=6,
},
accompany={
unit=dev_mode and san*9 or san*.5,
},
alone={
multi=dev_mode and 10 or 0.3,
},
eloquence={
multi=dev_mode and 1 or 0.01,
},
insight={
multi=dev_mode and 1 or 0.01,
},
cool={
special=true,
heat=dev_mode and-1000 or-100,
},
hot={
special=true,
heat=dev_mode and 1000 or 100,
},
cure={
special=true,
multi=1,
interval=5,
max=dev_mode and 0.5 or 0.25,
maxMulti=0.05,
},
winterSwim={
special=true,
goldern=true,
},
acupuncture={
special=true,
multi=dev_mode and 1 or 0.01,
},
luna={
special=true,
goldern=true,
land=0.44,
full=0.58,
},
hypnosis={
special=true,
multi=dev_mode and 0.4 or 0.01,
},
sponge={
multi=1,
interval=5,
},
dancer={
special=true,
multi=dev_mode and 1 or 0.01,
},
d4c={
special=true,
goldern=true,
percent=dev_mode and 0.5 or 0.1,
},
dig={
special=true,
duration=25,
durationUnit=5,
},
ge={
special=true,
goldern=true,
ptg=dev_mode and 1 or 0.05,
},
play={
special=true,
weak=dev_mode and 1 or 0.05,
duration=10,
},
migao={
special=true,
goldern=true,
pain=.55,
multi=dev_mode and 0.5 or 0.1,
},
johnWick={
goldern=true,
multi=1,
},
graveCloak={
goldern=true,
interval=dev_mode and 3 or 6,
count=dev_mode and 3 or 5,
def=0.1,
defMulti=0.03,
},
cooker={
multi=dev_mode and 0.99 or 0.1,
},
giants={
hp=dev_mode and 50 or 2000,
multi=0.2,
},
lucky={
special=true,
multi=dev_mode and 100 or 1
},
blasphemy={
special=true,
goldern=true,
},
muddy={
special=true,
multi=dev_mode and 0.9 or 0.01,
duration=3,
},
bubble={
special=true,
base=2,
multi=0.2,
},
shrimp={
special=true,
multi=dev_mode and 0.5 or 0.1,
},
resonance={
special=true,
atk=dev_mode and 10 or 0.05,
def=dev_mode and 0.99 or 0.05,
},
rainbow={
goldern=true,
wet=dev_mode and 10 or 2,
},
balrog={
goldern=true,
atk=dev_mode and 100 or 5,
},
hotDog={
special=true,
atk=dev_mode and 0.8 or 0.2,
},
coldDog={
special=true,
atk=dev_mode and 0.8 or 0.2,
},
steal={
special=true,
multi=dev_mode and 1 or 0.01,
},
defend={
special=true,
multi=dev_mode and 1 or 0.08,
},
brightshadeKiller={
special=true,
ptg=dev_mode and 0.8 or 0.03,
},
}

local SKILL_DESC_LANG={
english={
shedding="Drop items every DAY days",
aggressive="Increase your ATK% damage",
conservative="Reduce your getting damage PTC%",
cowardly="Increase your SPD% when attacked (DUR seconds)",
accompany="Recover SAN points/minute for nearby players",
alone="Increase work effect(chop,mine) WRK% when no other players nearby",
eloquence="Increase catch chance of pets by PTG%",
insight="Has PTG% chance to increase catch pet quality. Be 100% if this is your only pet",
cool="It's cool. Take care to not to close",
hot="It's hot. Take care to not to close",
cure="Cure HLT point health every ITV seconds when health is lower than PTG%",
winterSwim="Replace drowning punishment with freezing",
acupuncture="Increase the effect of acupuncture by PTG%",
taster="Food will not reduce your health",
luna="Increase your damage by LND% on the moon land and FUL% on full moon",
hypnosis="Has PTG% chance to hypnotize who attack you",
sponge="Convert PNT points moisture to hunger every ITV seconds",
dancer="Has PTG% chance to be immune to damage taken",
d4c="When health < PTG%,jump into wormhole will recover full health. One times per day",
dig="Dig a hole to the place you last use cookpot when dusk. Exist for DUR seconds",
ge="Have PTG% change to replant the seed when harvest",
play="Your attack will make target reduce PTG% damage for DUR seconds",
migao="Damage received increases PAN%. Every time you successfully dodge an attack,increase PTG% damage,up to TTL%. Reset when damaged",
johnWick="Raise ATK damage. If your pet is hound,player near you will also get this buff",
graveCloak="Get barrier per ITV sec (max CNT). Each barrier can reduce PTG% damage but will break one by one when get hurt",
cooker="Increase cooking speed by PTG%",
giants="Increase PTG% damage for the target whose current health > HP",
lucky="Lucky. Charlie can not harm you(just damage)",
blasphemy="Abandon fate! Your damage get double,but your health will continue hurted",
muddy="Reduce PTG% speed who you damage. Last DUR seconds",
bubble="Lighten up the night. Has DIST radius",
shrimp="Increase PTG% damage when no weapon equipped",
resonance="Increase ATK% damage and reduce DEF% damage taken when crazy",
rainbow="Increase WET% moisture speed and reduce damage taken by moisture",
balrog="Increase ATK point damage when burning",
hotDog="Increase ATK% max health damage to fire hound and turn hound to fire hound",
coldDog="Increase ATK% max health damage to ice hound and turn hound to ice hound",
steal="Has PTG% chance to steal item from enemy when attacking",
defend="Convert PTG% of received damage into armor durability loss",
brightshadeKiller="Deal PTG% max health normal damage to Brightshades",
},
chinese={
shedding="每隔DAY天会丢出捡到的物品",
aggressive="提升你的战斗伤害ATK%",
conservative="减免你受到的伤害PTC%",
cowardly="受到伤害时提升移动速度SPD%，持续DUR秒",
accompany="恢复附近玩家理智值SAN点/分",
alone="如果附近没有其他玩家，则提升砍伐、采矿工作效率WRK%",
eloquence="提升捕捉宠物概率PTG%",
insight="有PTG%概率提升捕捉宠物的品质，如果这是你唯一的宠物则为100%概率",
cool="散发着寒气，小心靠近被冻着哦",
hot="冒着热气，靠太近小心被烫伤哦",
cure="当生命值低于PTG%时，每隔ITV秒恢复HLT点生命值",
winterSwim="落水惩罚不再失去生命值与物品，转而变为被冰冻状态",
acupuncture="提升物品治疗效果PTG%",
taster="免疫食物造成的生命损失",
luna="在月岛地皮伤害提升LND%，满月伤害提升FUL%",
hypnosis="有PTG%概率让攻击你的生物睡着",
sponge="每隔ITV秒转化PNT点雨露值为饥饿值",
dancer="有PTG%概率免疫受到的伤害",
d4c="当生命值小于PTG%时跳入虫洞会恢复至满血，每天限1次",
dig="黄昏时会在玩家身边挖掘一个持续DUR秒的洞穴通向最后一次做饭的地方",
ge="收成植物时有PTG%概率重新种植",
play="被你攻击的目标会降低PTG%伤害，持续DUR秒",
migao="受到的伤害提升PAN%。每次成功闪避攻击，提升PTG%伤害，最多TTL%。受到伤害则重置",
johnWick="提升ATK点伤害，如果你的宠物是小猎犬，则身边伙伴也获得增伤效果",
graveCloak="每隔ITV秒获得一个屏障，最多CNT个。每个屏障减免PTG%伤害，受到伤害时会消耗一层屏障",
cooker="烹饪速度提升PTG%",
giants="攻击当前生命值大于HP的生物伤害提升PTG%",
lucky="运气不错，免疫查理造成的伤害(也仅仅是免疫而已)",
blasphemy="背弃命运！你的伤害翻倍，但是你的生命值会不断减少",
muddy="当你造成伤害时，会降低目标PTG%移动速度，持续DUR秒",
bubble="发出半径为DIST的光芒",
shrimp="徒手攻击时伤害提升PTG%",
resonance="在疯狂状态下伤害提升ATK%，受到伤害减免DEF%",
rainbow="潮湿速度提升WET%，受到的伤害会优先被雨露值抵消",
balrog="火焰即是力量。在被点燃时，攻击伤害提升ATK点",
hotDog="攻击会将猎犬转化为火猎犬，对火猎犬造成额外ATK%最大生命值的伤害",
coldDog="攻击会将猎犬转化为冰猎犬，对冰猎犬造成额外ATK%最大生命值的伤害",
steal="攻击时有PTG%概率从敌人身上偷取物品",
defend="将PTG%的受到伤害转化为护甲耐久度",
brightshadeKiller="对亮茄造成额外PTG%最大生命值的普通伤害",
},
}


local SKILL_DESC_VARS={
shedding=function(info,lv)
return {
DAY=(info.base-info.multi*lv)/dt,
}
end,
aggressive=function(info,lv)
return {
ATK=info.multi*lv*100,
}
end,
conservative=function(info,lv)
return {
PTC=info.multi*lv*100,
}
end,
cowardly=function(info,lv)
return {
SPD=info.multi*lv*100,
DUR=info.duration,
}
end,
accompany=function(info,lv)
return {
SAN=info.unit*lv/san,
}
end,
alone=function(info,lv)
return {
WRK=info.multi*lv*100,
}
end,
eloquence=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
insight=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
cure=function(info,lv)
return {
PTG=(info.max+info.maxMulti*lv)*100,
ITV=info.interval,
HLT=info.multi*lv,
}
end,
acupuncture=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
luna=function(info,lv)
return {
LND=info.land*lv*100,
FUL=info.full*lv*100,
}
end,
hypnosis=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
sponge=function(info,lv)
return {
PNT=info.multi*lv,
ITV=info.interval,
}
end,
dancer=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
d4c=function(info,lv)
return {
PTG=info.percent*100,
}
end,
dig=function(info,lv)
return {
DUR=info.duration+info.durationUnit*lv,
}
end,
ge=function(info,lv)
return {
PTG=info.ptg*100,
}
end,
play=function(info,lv)
return {
PTG=info.weak*100,
DUR=info.duration,
}
end,
migao=function(info,lv)
return {
PAN=info.pain*100,
PTG=info.multi*100,
TTL=info.multi*lv*100,
}
end,
johnWick=function(info,lv)
return {
ATK=info.multi*lv,
}
end,
graveCloak=function(info,lv)
return {
ITV=info.interval,
CNT=info.count,
PTG=(info.def+info.defMulti*lv)*100,
}
end,
cooker=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
giants=function(info,lv)
return {
PTG=info.multi*lv*100,
HP=info.hp,
}
end,
muddy=function(info,lv)
return {
PTG=info.multi*lv*100,
DUR=info.duration,
}
end,
bubble=function(info,lv)
return {
DIST=info.base+info.multi*lv,
}
end,
shrimp=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
resonance=function(info,lv)
return {
ATK=info.atk*lv*100,
DEF=info.def*lv*100,
}
end,
rainbow=function(info,lv)
return {
WET=info.wet*lv*100,
}
end,
balrog=function(info,lv)
return {
ATK=info.atk*lv,
}
end,
hotDog=function(info,lv)
return {
ATK=info.atk*lv*100,
}
end,
coldDog=function(info,lv)
return {
ATK=info.atk*lv*100,
}
end,
steal=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
defend=function(info,lv)
return {
PTG=info.multi*lv*100,
}
end,
brightshadeKiller=function(info,lv)
return {
PTG=info.ptg*lv*100,
}
end,
}

local SKILL_LIST={}
for name,v in pairs(SKILL_CONSTANT) do
if not v.special then
table.insert(SKILL_LIST,name)
end
end


if dev_mode then
SKILL_LIST={

















"giants",
}
end

return {
QUALITY_COLORS=QUALITY_COLORS,
QUALITY_LANG=QUALITY_LANG[language] or QUALITY_LANG.english,
SKILL_LANG=SKILL_LANG[language] or SKILL_LANG.english,
SKILL_DESC_LANG=SKILL_DESC_LANG[language] or SKILL_DESC_LANG.english,
SKILL_DESC_VARS=SKILL_DESC_VARS,
SKILL_LIST=SKILL_LIST,
SKILL_MAX_LEVEL=SKILL_MAX_LEVEL,
SKILL_CONSTANT=SKILL_CONSTANT,
}