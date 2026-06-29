local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local language=aipGetModConfig("language")


local LANG_MAP={
english={
NAME="Rift Smiler",
DESC="Indescribable!",
THINK="Something is leaving me!",

GAZE_BUFF_NAME="Oldone Gaze",
AXE_BUFF_NAME="Axe Bonus",
ATTACK_BUFF_NAME="Attack Bonus",
MINE_BUFF_NAME="Mine Bonus",
},
chinese={
NAME="裂隙笑颜",
DESC="不可名状！",
THINK="我似乎有了一些变化",

GAZE_BUFF_NAME="古神凝视",
AXE_BUFF_NAME="砍伐加成",
ATTACK_BUFF_NAME="攻击加成",
MINE_BUFF_NAME="挖掘加成",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_OLDONE_SMILE=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_SMILE=LANG.DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_SMILE_THINK=LANG.THINK


local assets={
Asset("ANIM","anim/aip_oldone_smile.zip"),
}



aipBufferRegister("aip_oldone_smiling",{
name=LANG.GAZE_BUFF_NAME,














showFX=false,
fx="aip_aura_smiling",
})


aipBufferRegister("aip_oldone_smiling_axe",{
name=LANG.AXE_BUFF_NAME,
showFX=false,
fx="aip_aura_smiling_axe",
})


aipBufferRegister("aip_oldone_smiling_attack",{
name=LANG.ATTACK_BUFF_NAME,
showFX=false,
fx="aip_aura_smiling_attack",
})


aipBufferRegister("aip_oldone_smiling_mine",{
name=LANG.MINE_BUFF_NAME,
showFX=false,
fx="aip_aura_smiling_mine",
})


local function syncErosion(inst,alpha)
local tgtAlpha=math.min(1-alpha,1)
tgtAlpha=math.max(tgtAlpha,0)

inst.AnimState:SetErosionParams(tgtAlpha,-0.125,-1.0)
inst.AnimState:SetMultColour(1,1,1,alpha)
end

local PLAYER_DIST=20

local SPEED=dev_mode and 10 or TUNING.CRAWLINGHORROR_SPEED/3/2
local GHOST_RANGE=dev_mode and 20 or 5

local GHOST_REDUCE_HEALTH=dev_mode and 10 or 100
local GHOST_REDUCE_PLAYER=dev_mode and 10 or 25
local HEALTH_MULTIPLE=dev_mode and 1 or 25
local MAX_HEALTH=GHOST_REDUCE_HEALTH*HEALTH_MULTIPLE

local OLDONE_SEEN_TIME=dev_mode and 3 or 3
local OLDONE_SEEN_AURA_TIME=OLDONE_SEEN_TIME+(dev_mode and 10 or 10)
local OLDONE_AURA_EXIST_TIME=60*30


local BUFFS_GOOD={
"aip_oldone_smiling_axe",
"aip_oldone_smiling_attack",
"aip_oldone_smiling_mine",
}

local BUFFS_ALL=aipTableSlice(BUFFS_GOOD)
table.insert(BUFFS_ALL,"aip_oldone_smiling")

local function hasBuff(inst,buffs)
local existBuffs=aipFilterTable(buffs,function(buff)
return aipBufferExist(inst,buff)
end)

return #existBuffs > 0
end

local function doBrain(inst)
aipQueue({

function()
local pt=inst:GetPosition()
local watchers=TheSim:FindEntities(pt.x,pt.y,pt.z,50,{ "aip_oldone_smile_active" })

local tgtPT=nil


local closeWatcher=aipFindCloseEnt(inst,watchers)
if closeWatcher~=nil then
tgtPT=closeWatcher:GetPosition()
end


if tgtPT~=nil then
inst:ForceFacePoint(tgtPT.x,0,tgtPT.z)
inst.Physics:SetMotorVel(
SPEED,
0,
0
)


inst._aip_fade_cnt=math.min(1,inst._aip_fade_cnt+0.08)
syncErosion(inst,inst._aip_fade_cnt)


local players=aipFindNearPlayers(inst,PLAYER_DIST)

for i,player in ipairs(players) do
if aipDist(pt,player:GetPosition()) >=GHOST_RANGE then

if
player.components.timer~=nil and
not player.components.timer:TimerExists("aip_oldone_sading")
then
player.components.timer:StartTimer("aip_oldone_sading",3)

local ghost=aipSpawnPrefab(player,"aip_oldone_sad")
if ghost.components.homeseeker~=nil then
ghost.components.homeseeker:SetHome(inst)
end


local restValue=GHOST_REDUCE_PLAYER
ghost._aip_sanity=0
ghost._aip_hunger=0


if player.components.sanity~=nil then
local validSanity=math.min(GHOST_REDUCE_PLAYER,player.components.sanity.current)
player.components.sanity:DoDelta(-validSanity)
ghost._aip_sanity=validSanity
restValue=restValue-validSanity
end


restValue=restValue/2
if restValue > 0 and player.components.hunger~=nil then
local validHunger=math.min(restValue,player.components.hunger.current)
player.components.hunger:DoDelta(-validHunger)
ghost._aip_hunger=validHunger
end
end
else

aipBufferPatch(inst,player,"aip_see_eyes",OLDONE_SEEN_TIME)
if
not hasBuff(player,BUFFS_ALL)
then
aipBufferPatch(inst,player,"aip_oldone_smiling",OLDONE_SEEN_AURA_TIME)
end
end
end
else
inst.Physics:Stop()
end

return tgtPT~=nil
end,


function()
inst._aip_fade_cnt=math.max(0,inst._aip_fade_cnt-0.03)
syncErosion(inst,inst._aip_fade_cnt)

if inst._aip_fade_cnt <=0 then
if not inst.components.health:IsDead() then
aipCommonStore().smileLeftDays=0
end
aipRemove(inst)
end

return true
end,
})
end


local function eatSad(inst)
local pt=inst:GetPosition()
local sadList=TheSim:FindEntities(pt.x,pt.y,pt.z,2,{ "aip_oldone_sad" })

for i,sad in ipairs(sadList) do
if sad.components.health~=nil then
if not sad.components.health:IsDead() then
sad.components.health:Kill()


inst.components.health:DoDelta(-GHOST_REDUCE_HEALTH)
end
else
aipRemove(sad)
end
end
end


local function OnKilled(inst,data)
local players=aipFindNearPlayers(inst,PLAYER_DIST)
local afflicter=aipGet(data,"afflicter")

for i,player in ipairs(players) do
if player==afflicter or aipBufferExist(player,"aip_oldone_smiling") then
aipBufferRemove(player,"aip_oldone_smiling")
local buff=aipRandomEnt(BUFFS_GOOD)
buff=dev_mode and "aip_oldone_smiling_mine" or buff
aipBufferPatch(inst,player,buff,OLDONE_AURA_EXIST_TIME)
end
end


end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddDynamicShadow()
inst.entity:AddNetwork()

inst.DynamicShadow:SetSize(4,2)

MakeFlyingGiantCharacterPhysics(inst,500,1.4)

inst.AnimState:SetBank("aip_oldone_smile")
inst.AnimState:SetBuild("aip_oldone_smile")
inst.AnimState:PlayAnimation("idle",true)

inst:AddTag("aip_oldone_smile")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("sanityaura")

inst:AddComponent("inspectable")
inst:AddComponent("aipc_timer")

inst:AddComponent("locomotor")
inst.components.locomotor:EnableGroundSpeedMultiplier(false)
inst.components.locomotor:SetTriggersCreep(false)
inst.components.locomotor.pathcaps={ ignorewalls=true,allowocean=true }
inst.components.locomotor.walkspeed=TUNING.BEEQUEEN_SPEED

inst:AddComponent("health")
inst.components.health:SetMaxHealth(MAX_HEALTH)

inst:AddComponent("combat")
inst.components.combat.hiteffectsymbol="body"


syncErosion(inst,0)
inst._aip_fade_cnt=0
inst.components.aipc_timer:NamedInterval("doBrain",0.25,doBrain)
inst.components.aipc_timer:NamedInterval("eatSad",0.25,eatSad)

MakeHauntableLaunch(inst)

inst:ListenForEvent("death",OnKilled)

return inst
end

return Prefab("aip_oldone_smile",fn,assets)
