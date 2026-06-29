local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local language=aipGetModConfig("language")

local additional_survival=aipGetModConfig("additional_survival")=="open"

local WarnRange=8


local FueledTime=dev_mode and 8 or 40

local LANG_MAP={
english={
BROEKN_NAME="Wreckage",
BROEKN_DESC="Maybe we can fix this",
POWERLESS_NAME="Powerless Totem",
POWERLESS_DESC="Just one last dance!",
CAVE_NAME="IOT Symbol",
CAVE_DESC="It's powerless but still work",
NAME="IOT Totem",
DESC="Seems magic somewhere",
TALK_WELCOME="Are you ready?",
TALK_ANGER="'Thank you' for fuel me!",
TALK_FIRST="Start your challenge",
TOTEM_POS="First Place",
TOTEM_BALLOON="Ruo Guang",
TOTEM_RUBIK="The Matrix",
},
chinese={
BROEKN_NAME="一片残骸",
BROEKN_DESC="看起来可以修复它",
POWERLESS_NAME="失能的图腾",
POWERLESS_DESC="还差最后一步！",
CAVE_NAME="联结徽记",
CAVE_DESC="稍弱一些，但是还能工作",
NAME="联结图腾",
DESC="有一丝魔法气息",
TALK_WELCOME="想得到我的秘密，你做好准备了吗？",
TALK_ANGER="“感谢”你的馈赠",
TALK_FIRST="开始你的挑战！",
TOTEM_POS="伊始之地",
TOTEM_BALLOON="若光小驻",
TOTEM_RUBIK="薄暮矩阵",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.AIP_DOU_TOTEM_BROKEN=LANG.BROEKN_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_DOU_TOTEM_BROKEN=LANG.BROEKN_DESC
STRINGS.NAMES.AIP_DOU_TOTEM_POWERLESS=LANG.POWERLESS_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_DOU_TOTEM_POWERLESS=LANG.POWERLESS_DESC
STRINGS.NAMES.AIP_DOU_TOTEM_CAVE=LANG.CAVE_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_DOU_TOTEM_CAVE=LANG.CAVE_DESC
STRINGS.NAMES.AIP_DOU_TOTEM=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_DOU_TOTEM=LANG.DESC
STRINGS.AIP_DOU_TOTEM_TALK_WELCOME=LANG.TALK_WELCOME
STRINGS.AIP_DOU_TOTEM_TALK_FIRST=LANG.TALK_FIRST
STRINGS.AIP_DOU_TOTEM_TALK_ANGER=LANG.TALK_ANGER


local assets={
Asset("ANIM","anim/aip_dou_totem.zip"),
Asset("ATLAS","minimap/aip_dou_totem.xml"),
Asset("IMAGE","minimap/aip_dou_totem.tex"),
}

local prefabs={
"aip_dou_tooth",
}


CONSTRUCTION_PLANS["aip_dou_totem_broken"]={
Ingredient("moonrocknugget",10),
Ingredient("phlegm",1),
Ingredient("moonglass",5),
}


local aip_dou_totem_powerless_plans={
Ingredient("boneshard",1),
Ingredient("monstermeat",1),
}

if additional_survival then
table.insert(
aip_dou_totem_powerless_plans,
Ingredient("aip_blood_package",1,"images/inventoryimages/aip_blood_package.xml")
)
end

CONSTRUCTION_PLANS["aip_dou_totem_powerless"]=aip_dou_totem_powerless_plans


local function createFlyTotem(pt,name,markType)
if pt~=nil then
local flyTotem=aipSpawnPrefab(nil,"aip_fly_totem",pt.x,pt.y,pt.z)
aipSpawnPrefab(flyTotem,"collapse_small")
flyTotem.components.writeable:SetText(name)
flyTotem.markType=markType
end
end

local function createFlyTotems(inst)
local startTotem=false
local balloonTotem=false
local rubikTotem=false

for i,totem in ipairs(TheWorld.components.world_common_store.flyTotems) do
if totem.markType=="START" then
startTotem=true
elseif totem.markType=="BALLOON" then
balloonTotem=true
elseif totem.markType=="RUBIK" then
rubikTotem=true
end
end


if startTotem==false then
createFlyTotem(
aipGetSecretSpawnPoint(inst:GetPosition(),4,6,5),
LANG.TOTEM_POS,
"START"
)
end


if balloonTotem==false then
local pigking=aipFindEnt("pigking")
if pigking then
createFlyTotem(
aipGetSecretSpawnPoint(pigking:GetPosition(),50,100,5),
LANG.TOTEM_BALLOON,
"BALLOON"
)
end
end

if rubikTotem==false then
local rubik=TheSim:FindFirstEntityWithTag("aip_rubik")
if rubik then
createFlyTotem(
aipGetSecretSpawnPoint(rubik:GetPosition(),4,8,5),
LANG.TOTEM_RUBIK,
"RUBIK"
)
end
end
end


local function createChallenge()
aipGetTopologyPoint("lunacyarea","moon_fissure")
end


local function ontakefuel(inst)
inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
end

local function onupdatefueled(inst)
if inst.components.burnable~=nil then
inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(),inst.components.fueled:GetSectionPercent())
end


inst:RemoveTag("fire")
end

local function onfuelchange(newsection,oldsection,inst)
if newsection <=0 then
inst.components.burnable:Extinguish()
else
if not inst.components.burnable:IsBurning() then
inst.components.burnable:Ignite()
end

inst.components.burnable:SetFXLevel(newsection,inst.components.fueled:GetSectionPercent())
end


inst:RemoveTag("fire")
end



local function OnFullMoon(inst,isfullmoon)
if inst._aipAuraTrack~=nil then
inst._aipAuraTrack:Remove()
inst._aipAuraTrack=nil
end

if isfullmoon then
inst:DoTaskInTime(0.1,function()
inst._aipAuraTrack=aipSpawnPrefab(inst,"aip_aura_track")
end)
end
end


local function killTimer(inst)
if inst.aipGhostTimer~=nil then
inst.aipGhostTimer:Cancel()
end

inst.aipGhostTimer=nil
end


local function onNear(inst,player)
killTimer(inst)

inst.aipGhostTimer=inst:DoPeriodicTask(8,function()

if inst.components.fueled~=nil and not inst.components.fueled:IsEmpty() then
local players=aipFindNearPlayers(inst,WarnRange)
local player=aipRandomEnt(players)

if player~=nil then
local tentacle=aipSpawnPrefab(player,"shadowtentacle")
tentacle.components.combat:SetTarget(player)


if tentacle.components.sanityaura~=nil then
tentacle.components.sanityaura.aura=0
end

tentacle.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shadowTentacleAttack_1")
tentacle.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shadowTentacleAttack_2")


if inst.components.talker then
inst.components.talker:Say(STRINGS.AIP_DOU_TOTEM_TALK_ANGER)
end
end
end
end)
end


local function onFar(inst)
killTimer(inst)
end


local function makeTotemFn(name,animation,nextPrefab,nextPrefabAnimation,postFn)

local function OnConstructed(inst,doer)
local concluded=true
for i,v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
concluded=false
break
end
end

if concluded then
aipSpawnPrefab(inst,"collapse_big")
local next=ReplacePrefab(inst,nextPrefab)


if nextPrefabAnimation~=nil then
next.AnimState:PlayAnimation(nextPrefabAnimation.."_pre")
next.AnimState:PushAnimation(nextPrefabAnimation,true)
end


if next.components.talker~=nil then

next:DoTaskInTime(0.5,function()
next.components.talker:Say(STRINGS.AIP_DOU_TOTEM_TALK_WELCOME)
end)


next:DoTaskInTime(5,function()
next.components.talker:Say(STRINGS.AIP_DOU_TOTEM_TALK_FIRST)
end)
end
end
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddMiniMapEntity()
inst.entity:AddNetwork()

MakeObstaclePhysics(inst,.2)

inst.MiniMapEntity:SetIcon("aip_dou_totem.tex")
inst.MiniMapEntity:SetPriority(10)

inst.AnimState:SetBank("aip_dou_totem")
inst.AnimState:SetBuild("aip_dou_totem")
inst.AnimState:PlayAnimation(animation,true)

inst:AddTag("structure")


if nextPrefab==nil then
inst:AddTag("aip_dou_totem_final")


inst:AddComponent("talker")
inst.components.talker.fontsize=30
inst.components.talker.font=TALKINGFONT
inst.components.talker.colour=Vector3(.9,1,.9)
inst.components.talker.offset=Vector3(0,-500,0)
end

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end


if nextPrefab==nil then

inst:AddComponent("burnable")
inst.components.burnable:AddBurnFX("nightlight_flame",Vector3(0,0,0),"fire_marker_left")
inst.components.burnable:AddBurnFX("nightlight_flame",Vector3(0,0,0),"fire_marker_right")
inst.components.burnable.canlight=false


inst:AddComponent("fueled")
inst.components.fueled.maxfuel=FueledTime
inst.components.fueled.accepting=true
inst.components.fueled.fueltype=FUELTYPE.NIGHTMARE
inst.components.fueled:SetSections(3)
inst.components.fueled:SetTakeFuelFn(ontakefuel)
inst.components.fueled:SetUpdateFn(onupdatefueled)
inst.components.fueled:SetSectionCallback(onfuelchange)
inst.components.fueled:InitializeFuelLevel(0)

inst.components.fueled.rate=0
inst.components.fueled.bonusmult=(1/TUNING.LARGE_FUEL)*(FueledTime/4)


inst:AddComponent("playerprox")
inst.components.playerprox:SetDist(WarnRange,WarnRange)
inst.components.playerprox:SetOnPlayerNear(onNear)
inst.components.playerprox:SetOnPlayerFar(onFar)


if not TheWorld:HasTag("cave") then
inst:WatchWorldState("isfullmoon",OnFullMoon)
OnFullMoon(inst,TheWorld.state.isfullmoon)


inst:AddComponent("prototyper")
inst.components.prototyper.trees=TUNING.PROTOTYPER_TREES.AIP_DOU_TOTEM
end
end

inst:AddComponent("inspectable")

if nextPrefab~=nil then
inst:AddComponent("constructionsite")
inst.components.constructionsite:SetConstructionPrefab("construction_container")
inst.components.constructionsite:SetOnConstructedFn(OnConstructed)
elseif not TheWorld:HasTag("cave") then

inst:DoTaskInTime(3,createFlyTotems)
end

MakeSnowCovered(inst)

MakeHauntableWork(inst)

if postFn~=nil then
postFn(inst)
end

return inst
end

return Prefab(name,fn,assets,prefabs)
end


local function autoReplace(inst)
if TheWorld:HasTag("cave") then
inst:DoTaskInTime(0.1,function()
aipReplacePrefab(inst,"aip_dou_totem_cave")
end)
end
end

return makeTotemFn("aip_dou_totem_broken","broken","aip_dou_totem_powerless",nil,autoReplace),
makeTotemFn("aip_dou_totem_powerless","powerless","aip_dou_totem","idle",autoReplace),
makeTotemFn("aip_dou_totem","idle",nil,nil,autoReplace),
makeTotemFn("aip_dou_totem_cave","idle_cave")
