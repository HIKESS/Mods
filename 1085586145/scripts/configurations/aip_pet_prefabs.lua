local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local function houndPostInit(bank,skipSwim)
return function(inst)

inst:AddComponent("follower")

if skipSwim~=true then
inst:AddComponent("amphibiouscreature")
inst.components.amphibiouscreature:SetBanks(bank,bank.."_water")
inst.components.amphibiouscreature:SetEnterWaterFn(function(inst)
inst.components.locomotor.hop_distance=4
end)
end
end
end

local houndSounds={
pant="dontstarve/creatures/hound/pant",
attack="dontstarve/creatures/hound/attack",
bite="dontstarve/creatures/hound/bite",
bark="dontstarve/creatures/hound/bark",
death="dontstarve/creatures/hound/death",
sleep="dontstarve/creatures/hound/sleep",
growl="dontstarve/creatures/hound/growl",
howl="dontstarve/creatures/together/clayhound/howl",
hurt="dontstarve/creatures/hound/hurt",
}


local function SpiderSoundPath(inst,event)
local creature="spider"
if inst:HasTag("spider_healer") then
return "webber1/creatures/spider_cannonfodder/" .. event
elseif inst:HasTag("spider_moon") then
return "turnoftides/creatures/together/spider_moon/" .. event
elseif inst:HasTag("spider_warrior") then
creature="spiderwarrior"
elseif inst:HasTag("spider_hider") or inst:HasTag("spider_spitter") then
creature="cavespider"
else
creature="spider"
end
return "dontstarve/creatures/" .. creature .. "/" .. event
end

local function spiderPostInit(inst)
inst.SoundPath=SpiderSoundPath
inst.incineratesound=SpiderSoundPath(inst,"die")
end

local PREFABS={

rabbit={
bank="rabbit",
build="rabbit_build",
anim="idle",
sg="SGrabbit",
sounds={
scream="dontstarve/rabbit/scream",
hurt="dontstarve/rabbit/scream_short",
},
},
rabbit_winter={
bank="rabbit",
build="rabbit_winter_build",
anim="idle",
sg="SGrabbit",
sounds={
scream="dontstarve/rabbit/winterscream",
hurt="dontstarve/rabbit/winterscream_short",
},
origin="rabbit",
},
rabbit_crazy={
bank="rabbit",
build="beard_monster",
anim="idle",
sg="SGrabbit",
sounds={
scream="dontstarve/rabbit/scream",
hurt="dontstarve/rabbit/scream_short",
},
origin="rabbit",
},



spider={
bank="spider",
build="spider_build",
anim="idle",
sg="SGspider",
postInit=spiderPostInit,
},


spider_warrior={
bank="spider",
build="spider_warrior_build",
anim="idle",
sg="SGspider",
tags={ "spider_warrior" },
postInit=spiderPostInit,
},


spider_hider={
bank="spider_hider",
build="DS_spider_caves",
anim="idle",
sg="SGspider",
tags={ "spider_hider" },
postInit=spiderPostInit,
},


spider_healer={
bank="spider",
build="spider_wolf_build",
anim="idle",
sg="SGspider",
tags={ "spider_healer" },
postInit=spiderPostInit,
},


spider_spitter={
bank="spider_spitter",
build="DS_spider2_caves",
anim="idle",
sg="SGspider",
tags={ "spider_spitter" },
postInit=spiderPostInit,
},


spider_dropper={
bank="spider",
build="spider_white",
anim="idle",
sg="SGspider",
tags={ "spider_warrior" },
postInit=spiderPostInit,
},


spider_moon={
bank="spider_moon",
build="ds_spider_moon",
anim="idle",
sg="SGspider",
tags={ "spider_moon" },
postInit=spiderPostInit,
},


spider_water={
bank="spider_water",
build="spider_water",
anim="idle",
sg="SGspider_water",
tags={ "spider_water" },
postInit=function(inst)
inst.components.locomotor.hop_distance=4

inst:AddComponent("amphibiouscreature")
inst.components.amphibiouscreature:SetBanks("spider_water","spider_water_water")
inst.components.amphibiouscreature:SetEnterWaterFn(function(inst)
inst.AnimState:SetBuild("spider_water_water")
end)
inst.components.amphibiouscreature:SetExitWaterFn(function(inst)
inst.AnimState:SetBuild("spider_water")
end)

spiderPostInit(inst)
end,
},



hound={
bank="hound",
build="hound_ocean",
anim="idle",
sg="SGhound",
scale=0.6,
sounds=houndSounds,
postInit=houndPostInit("hound"),
},


firehound={
bank="hound",
build="hound_red_ocean",
anim="idle",
sg="SGhound",
scale=0.6,
sounds=houndSounds,
postInit=houndPostInit("hound"),
},


icehound={
bank="hound",
build="hound_ice_ocean",
anim="idle",
sg="SGhound",
scale=0.6,
sounds=houndSounds,
postInit=houndPostInit("hound"),
},


clayhound={
bank="clayhound",
build="clayhound",
anim="idle",
sg="SGhound",
scale=0.6,
sounds={
pant="dontstarve/creatures/together/clayhound/pant",
attack="dontstarve/creatures/together/clayhound/attack",
bite="dontstarve/creatures/together/clayhound/bite",
bark="dontstarve/creatures/together/clayhound/bark",
death="dontstarve/creatures/together/clayhound/death",
sleep="dontstarve/creatures/together/clayhound/sleep",
growl="dontstarve/creatures/together/clayhound/growl",
howl="dontstarve/creatures/together/clayhound/howl",
hurt="dontstarve/creatures/hound/hurt",
},
tags={ "clay" },
postInit=houndPostInit("hound",true),
},


mutatedhound={
bank="hound",
build="hound_mutated",
anim="idle",
sg="SGhound",
scale=0.6,
sounds=houndSounds,
postInit=houndPostInit("hound"),
},


hedgehound={
bank="hound",
build="hound_hedge_ocean",
anim="idle",
sg="SGhound",
scale=0.6,
sounds={
pant="dontstarve/creatures/hound/pant",
attack="dontstarve/creatures/hound/attack",
bite="dontstarve/creatures/hound/bite",
bark="dontstarve/creatures/hound/bark",
death="stageplay_set/briar_wolf/destroyed",
sleep="dontstarve/creatures/hound/sleep",
growl="dontstarve/creatures/hound/growl",
howl="dontstarve/creatures/together/clayhound/howl",
hurt="dontstarve/creatures/hound/hurt",
},
postInit=houndPostInit("hound"),
},



bee={
bank="bee",
build="bee_build",
anim="idle",
sg="SGbee",
scale=0.8,
sounds={
takeoff="dontstarve/bee/bee_takeoff",
attack="dontstarve/bee/bee_attack",
buzz="dontstarve/bee/bee_fly_LP",
hit="dontstarve/bee/bee_hurt",
death="dontstarve/bee/bee_death",
},
},


killerbee={
bank="bee",
build="bee_angry_build",
anim="idle",
sg="SGbee",
scale=0.8,
sounds={
takeoff="dontstarve/bee/killerbee_takeoff",
attack="dontstarve/bee/killerbee_attack",
buzz="dontstarve/bee/killerbee_fly_LP",
hit="dontstarve/bee/killerbee_hurt",
death="dontstarve/bee/killerbee_death",
},
},


beeguard={
bank="bee_guard",
build="bee_guard_build",
anim="idle",
sg="SGbeeguard",
scale=0.8,
sounds={
attack="dontstarve/bee/killerbee_attack",
buzz="dontstarve/bee/bee_fly_LP",
hit="dontstarve/creatures/together/bee_queen/beeguard/hurt",
death="dontstarve/creatures/together/bee_queen/beeguard/death",
},
face=6,
},


mandrake_active={
bank="mandrake",
build="mandrake",
anim="idle_loop",
sg="SGMandrake",
scale=0.9,
},


butterfly={
bank="butterfly",
build="butterfly_basic",
anim="idle",
sg="SGbutterfly",
scale=1,
face=2,
bb=true,
},



stalker_minion1={
bank="stalker_minion",
build="stalker_minion",
anim="idle",
sg="SGstalker_minion",
origin="stalker_minion",
scale=0.8,
face=6,
},


stalker_minion2={
bank="stalker_minion_2",
build="stalker_minion_2",
anim="idle",
sg="SGstalker_minion",
origin="stalker_minion",
scale=0.8,
face=6,
},



mole={
bank="mole",
build="mole_build",
anim="idle_under",
sg="SGmole",
postInit=function(inst)
inst._aipCanRun=false

inst.SetUnderPhysics=function()
inst.isunder=true
end
inst.SetAbovePhysics=function()
inst.isunder=false
end
end,
},



catcoon={
bank="catcoon",
build="catcoon_build",
anim="idle_loop",
sg="SGcatcoon",
},



slurper={
bank="slurper",
build="slurper_basic",
anim="idle_loop",
sg="SGslurper",
scale=0.6,
postInit=function(inst)
inst._light=SpawnPrefab("slurperlight")
inst._light.entity:SetParent(inst.entity)

inst._light.Light:SetRadius(0.5)
end,
},



slurtle={
bank="slurtle",
build="slurtle",
anim="idle",
sg="SGslurtle",
scale=0.8,
},


snurtle={
bank="slurtle",
build="slurtle",
anim="idle",
sg="SGslurtle",
scale=0.8,
postInit=function(inst)
inst.AnimState:OverrideSymbol("shell","slurtle_snaily","shell")
end,
},



aip_mud_crab={
bank="aip_mud_crab",
build="aip_mud_crab",
anim="idle_loop",
sg="SGaip_mud_crab",
scale=1,
face=2,
bb=true,
postInit=function(inst)
inst:DoTaskInTime(0,function()
inst.sg:GoToState("idle")
end)
end,
},



lightflier={
bank="lightflier",
build="lightflier",
anim="idle_loop",
sg="SGlightflier",
scale=1,
bb=true,

preInit=function(inst)
inst.entity:AddLight()
inst.Light:SetColour(1,0,0)
end,
},



wobster_sheller_land={
bank="lobster",
build="lobster_sheller",
anim="idle",
sg="SGwobsterland",
origin="wobster_sheller",
postInit=function(inst)
inst._hit_sound="hookline_2/creatures/wobster/hit"
end,
},


wobster_moonglass_land={
bank="lobster",
build="lobster_moonglass",
anim="idle",
sg="SGwobsterland",
origin="wobster_moonglass",
postInit=function(inst)
inst._hit_sound="hookline_2/creatures/wobster/hit"
end,
},



monkey={
bank="kiki",
build="kiki_basic",
anim="idle_loop",
sg="SGmonkey",
scale=0.8,
face=6,
postInit=function(inst)
inst:AddComponent("follower")
inst:AddComponent("amphibiouscreature")
inst.components.amphibiouscreature:SetBanks("kiki","kiki")
inst.soundtype=""

inst:AddComponent("combat")
inst.components.combat:SetAttackPeriod(TUNING.MONKEY_ATTACK_PERIOD)
inst.components.combat:SetRange(TUNING.MONKEY_MELEE_RANGE)
inst.components.combat:SetDefaultDamage(0)
end,
},


powder_monkey={
bank="monkey_small",
build="monkey_small",
anim="idle",
sg="SGpowdermonkey",
scale=0.8,
face=4,
postInit=function(inst)
inst:AddComponent("follower")
inst:AddComponent("amphibiouscreature")
inst.components.amphibiouscreature:SetBanks("monkey_small","monkey_small")
inst.soundtype=""

inst:AddComponent("combat")
inst.components.combat:SetAttackPeriod(TUNING.MONKEY_ATTACK_PERIOD)
inst.components.combat:SetRange(TUNING.MONKEY_MELEE_RANGE)
inst.components.combat:SetDefaultDamage(0)
end,
},


prime_mate={
bank="pigman",
build="monkeymen_build",
anim="idle_loop",
sg="SGprimemate",
scale=0.8,
face=4,
postInit=function(inst)
inst.AnimState:Hide("ARM_carry_up")

inst.soundtype=""

inst:AddComponent("combat")
inst.components.combat:SetAttackPeriod(TUNING.MONKEY_ATTACK_PERIOD)
inst.components.combat:SetRange(TUNING.MONKEY_MELEE_RANGE)
inst.components.combat:SetDefaultDamage(0)
end,
},



aip_slime_mold={
bank="aip_slime_mold",
build="aip_slime_mold",
anim="idle_loop",
sg="SGaip_slime_mold",
scale=0.8,
face=2,
bb=true,
},


eyeofterror={
bank="eyeofterror",
build="eyeofterror_basic",
anim="eye_idle",
sg="SGeyeofterror",
origin="eyeofterror",
scale=0.3,
face=6,
postInit=function(inst)
inst._soundpath="terraria1/eyeofterror/"
end,
},


gestalt={
bank="brightmare_gestalt",
build="brightmare_gestalt",
anim="idle",
sg="SGbrightmare_gestalt",
origin="gestalt",
scale=0.6,
face=4,
noShadow=true,
preInit=function(inst)
inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
inst.AnimState:Hide("mouseover")
end,
postInit=function(inst)
inst:AddComponent("gestaltcapturable")
inst.components.gestaltcapturable:SetLevel(1)

if not TheNet:IsDedicated() then
inst.blobhead=SpawnPrefab("gestalt_head")
inst.blobhead.entity:SetParent(inst.entity)
inst.blobhead.Follower:FollowSymbol(inst.GUID,"head_fx",0,0,0)
inst.blobhead.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
inst.highlightchildren={ inst.blobhead }
end
end,
},
}


for name,info in pairs(PREFABS) do
if not info.origin then
info.origin=name
end
end


local SHEDDING_LOOT={

rabbit={
manrabbit_tail=dev_mode and 100 or 0.05
},
rabbit_winter={
manrabbit_tail=0.1
},
rabbit_crazy={
beardhair=0.1
},


spider={
silk=0.05
},
spider_warrior={
silk=0.1
},

spider_healer={
spidergland=0.1
},
spider_moon={
moonglass=0.1
},


hound={
houndstooth=0.05,
},
firehound={
houndstooth=0.05,
redgem=0.01,
},
icehound={
houndstooth=0.05,
bluegem=0.01,
},
clayhound={
redpouch=0.05,
},
mutatedhound={
houndstooth=0.1,
},
hedgehound={
petals=0.5,
},


bee={
honey=0.05,
},
killerbee={
stinger=0.05,
},


mandrake_active={
},


butterfly={
petals=0.5,
},


stalker_minion1={
nightmarefuel=.05,
},


mole={
rocks=0.5,
flint=0.2,
nitre=0.2,
goldnugget=0.05,
},


catcoon={
spoiled_food=0.5,
cutgrass=0.5,
feather_crow=0.1,
feather_robin=0.1,
feather_robin_winter=0.1,
feather_canary=0.05,
},


slurper={
beardhair=0.01,
},


slurtle={
rocks=0.1,
slurtle_shellpieces=0.05,
slurtleslime=0.05,
},


monkey={
cave_banana=0.05,
beardhair=0.02,
},


gestalt={
moonglass=0.05,
},
}

SHEDDING_LOOT.spider_hider=SHEDDING_LOOT.spider_warrior
SHEDDING_LOOT.spider_spitter=SHEDDING_LOOT.spider_warrior
SHEDDING_LOOT.spider_dropper=SHEDDING_LOOT.spider
SHEDDING_LOOT.spider_water=SHEDDING_LOOT.spider_warrior

SHEDDING_LOOT.beeguard=SHEDDING_LOOT.bee

SHEDDING_LOOT.stalker_minion2=SHEDDING_LOOT.stalker_minion1

SHEDDING_LOOT.snurtle=SHEDDING_LOOT.slurtle

SHEDDING_LOOT.powder_monkey=SHEDDING_LOOT.monkey
SHEDDING_LOOT.prime_mate=SHEDDING_LOOT.monkey

local function getPrefab(inst,seer)
local prefab=inst.prefab
local subPrefab=nil


if prefab=="rabbit" then
if
inst.components.inventoryitem~=nil and
inst.components.inventoryitem.imagename=="rabbit_winter"
then
subPrefab="_winter"
end

if seer~=nil and seer.components.sanity~=nil then
local sanityVal=seer:HasTag("dappereffects") and TUNING.DAPPER_BEARDLING_SANITY or TUNING.BEARDLING_SANITY
local isinsane=seer.components.sanity:IsInsanityMode() and
seer.replica.sanity:GetPercent() <=sanityVal


if isinsane then
subPrefab="_crazy"
end
end
end


if prefab=="moonhound" then
prefab="hound"
end


if prefab=="bee" then
if
inst.components.inventoryitem~=nil and
inst.components.inventoryitem.imagename=="killerbee"
then
prefab="killerbee"
end
end


if prefab=="aip_pet_eyeofterror" then
prefab="eyeofterror"
end


if prefab=="aip_pet_gestalt" then
prefab="gestalt"
end

return prefab,subPrefab
end


local function getSkills(prefab,subPrefab)

if prefab=="rabbit" then
local skills={
"lucky",
}

if subPrefab=="_winter" then
table.insert(skills,"cool")
end

return skills
end


if prefab=="spider_healer" then
return {
"cure",
}
elseif prefab=="spider_water" then
return {
"winterSwim",
}
elseif prefab=="spider_moon" then
return {
"luna",
}
end


if prefab=="icehound" then
return {
"cool",
"coldDog",
}
elseif prefab=="firehound" then
return {
"hot",
"hotDog",
}
end


if prefab=="bee" or prefab=="killerbee" or prefab=="beeguard" then
local list={
"acupuncture",
}

if prefab=="beeguard" then
table.insert(list,"ge")
end

return list
end


if prefab=="mandrake_active" then
return {
"hypnosis",
}
end


if prefab=="butterfly" then
return {
"dancer",
}
end


if prefab=="stalker_minion1" or prefab=="stalker_minion2" then
return {
"d4c",
}
end


if prefab=="mole" then
return {
"dig",
}
end


if prefab=="catcoon" then
return {
"play",
}
end


if prefab=="slurper" then
return {
"migao",
}
end


if prefab=="slurtle" or prefab=="snurtle" then
return {
"defend",
}
end


if prefab=="aip_mud_crab" then
return {
"muddy",
}
end


if prefab=="lightflier" then
return {
"bubble",
}
end


if prefab=="wobster_sheller_land" or prefab=="wobster_moonglass_land" then
return {
"shrimp",
}
end


if prefab=="monkey" or prefab=="powder_monkey" or prefab=="prime_mate" then
return {
"steal",
}
end


if prefab=="aip_slime_mold" then
return {
"resonance",
}
end


if prefab=="gestalt" then
return {
"brightshadeKiller",
}
end
end

return {
PREFABS=PREFABS,
getPrefab=getPrefab,
getSkills=getSkills,
SHEDDING_LOOT=SHEDDING_LOOT,
}