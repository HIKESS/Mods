
local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local brain=require("brains/aip_oldone_thestral_brain")

local assets={
Asset("ANIM","anim/aip_oldone_thestral.zip"),
Asset("ANIM","anim/aip_oldone_thestral_full.zip"),
}


local language=aipGetModConfig("language")

local LANG_MAP={
english={
NAME="Sock Snake",
DESC="Hmmm,strange...",
SNAKE="Si si si...",
BEZOAR={
"'Trash is also treasure'",
"'After firing and cooling'",
"'There exists some special stones'",
"'The stone can activate the bulb'",
},
ROCK_HEAD={
"'Bring the marble head to me'",
"'It in the marsh'",
"'Annoying ball...'",
},
ROCK_HEAD_LOCK={
"'No More Annoying hahaha'",
"'Do not free it'",
"'Still want to go'",
},
},
chinese={
NAME="袜子蛇",
DESC="千人千面！",
SNAKE="嘶嘶嘶...",
BEZOAR={
"“垃圾堆也是宝贝”",
"“煅烧后冷却”",
"“有种特殊的石头”",
"“石头可以激活球茎”",
},
ROCK_HEAD={
"“把那个大理石带给我”",
"“沼泽有个聒噪的家伙”",
"“那个圆球好吵闹”",
},
ROCK_HEAD_LOCK={
"“聒噪的家伙终于安静了”",
"“不要再释放它了”",
"“虽然绑住了，看起来还是不消停”",
},
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english


STRINGS.NAMES.AIP_OLDONE_THESTRAL=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL=LANG.DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_SNAKE=LANG.SNAKE
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_BEZOAR=LANG.BEZOAR
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_ROCK_HEAD=LANG.ROCK_HEAD
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_ROCK_HEAD_LOCK=LANG.ROCK_HEAD_LOCK

local sounds={
attack="dontstarve/sanity/creature2/attack",
attack_grunt="dontstarve/sanity/creature2/attack_grunt",
death="dontstarve/sanity/creature2/die",
idle="dontstarve/sanity/creature2/idle",
taunt="dontstarve/sanity/creature2/taunt",
appear="dontstarve/sanity/creature2/appear",
disappear="dontstarve/sanity/creature2/dissappear",
}


local DIST_NEAR=10
local DIST_FAR=20
local TALK_DIFF=dev_mode and 3 or 12


local function onNear(inst,player)
inst.components.aipc_timer:NamedInterval("PlayerNear",1,function()

if inst.components.timer:TimerExists("aip_talk") then
return
end


local players=aipFilterTable(
aipFindNearPlayers(inst,DIST_NEAR),
function(player)
return aipBufferExist(player,"aip_see_eyes")
end
)

if #players > 0 then

local x,y,z=inst.Transform:GetWorldPosition()
local heads=TheSim:FindEntities(x,y,z,5,{ "aip_oldone_marble_head" })

local convertedHeads={}

if #heads > 0 then
for i,head in ipairs(heads) do
local owner=head.components.inventoryitem:GetGrandOwner()

if owner==nil then
aipSpawnPrefab(head,"aip_shadow_wrapper").DoShow()
local replaced=aipReplacePrefab(head,"aip_oldone_marble_head_lock")
table.insert(convertedHeads,replaced)
end
end
end


local head=aipFindEnt("aip_oldone_marble_head_lock")

for i,player in ipairs(players) do
if player.components.talker~=nil then
local talks=head
and STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_ROCK_HEAD_LOCK
or STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_ROCK_HEAD


if math.random() < 0.4 then
talks=STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_BEZOAR
end

player.components.talker:Say(
talks[math.random(#talks)]
)
end
end
end


inst.components.talker:Say(
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_THESTRAL_SNAKE
)
inst.components.timer:StartTimer("aip_talk",TALK_DIFF)
end)
end


local function onFar(inst)
inst.components.aipc_timer:KillName("PlayerNear")
end


local function onHealthDelta(inst,data)
local chance=dev_mode and 0.5 or 0.01
if inst~=nil and data~=nil and aipBufferExist(data.afflicter,"aip_see_eyes") then
data.amount=math.random() <=chance and-1 or 0
end
end


local function onDeath(inst,data)
local killer=data~=nil and data.afflicter or nil
if killer~=nil and aipBufferExist(killer,"aip_see_eyes") then
for i=1,3 do
inst.components.lootdropper:SpawnLootPrefab("aip_oldone_thestral_fur")
end

if killer.components.hunger~=nil then
killer.components.hunger:SetPercent(.001)
end
else
inst.components.lootdropper:SpawnLootPrefab("trinket_9")
end
end


local function ShouldAcceptItem(inst,item)
return item and item.prefab=="aip_bezoar"
end

local function OnGetItemFromPlayer(inst,giver,item)
if ShouldAcceptItem(inst,item) then

end
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()

MakeCharacterPhysics(inst,10,1.5)
RemovePhysicsColliders(inst)
inst.Physics:SetCollisionGroup(COLLISION.SANITY)
inst.Physics:CollidesWith(COLLISION.SANITY)

inst.Transform:SetTwoFaced()
inst.Transform:SetScale(0.8,0.8,0.8)

inst:AddTag("aip_oldone_thestral")

inst.AnimState:SetBank("aip_oldone_thestral")
inst.AnimState:SetBuild("aip_oldone_thestral")
inst.AnimState:PlayAnimation("idle_loop",true)

inst.AnimState:SetClientsideBuildOverride(
"aip_see_eyes",
"aip_oldone_thestral",
"aip_oldone_thestral_full"
)

inst.entity:SetPristine()

inst:AddComponent("talker")
inst.components.talker.fontsize=30
inst.components.talker.font=TALKINGFONT
inst.components.talker.colour=Vector3(1,.1,.1)
inst.components.talker.offset=Vector3(0,-300,0)

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("timer")

inst:AddComponent("inspectable")

inst:AddComponent("locomotor")
inst.components.locomotor.walkspeed=TUNING.CRAWLINGHORROR_SPEED

inst.sounds=sounds

inst:SetStateGraph("SGaip_oldone_thestral")
inst:SetBrain(brain)

inst:AddComponent("aipc_timer")


inst:AddComponent("playerprox")
inst.components.playerprox:SetDist(DIST_NEAR,DIST_FAR)
inst.components.playerprox:SetOnPlayerNear(onNear)
inst.components.playerprox:SetOnPlayerFar(onFar)

inst:AddComponent("sanityaura")

inst:AddComponent("health")
inst.components.health:SetMaxHealth(dev_mode and 6 or 66)

inst:AddComponent("combat")
inst.components.combat.hiteffectsymbol="body"
inst:ListenForEvent("aip_healthdelta",onHealthDelta)

inst:AddComponent("trader")
inst.components.trader:SetAcceptTest(ShouldAcceptItem)
inst.components.trader.onaccept=OnGetItemFromPlayer
inst.components.trader.deleteitemonaccept=false

inst:AddComponent("lootdropper")
inst:ListenForEvent("death",onDeath)


inst.aipSteps=0

return inst
end

return Prefab("aip_oldone_thestral",fn,assets)
