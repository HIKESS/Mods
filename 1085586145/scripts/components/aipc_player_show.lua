local dev_mode=aipGetModConfig("dev_mode")=="enabled"



local SHOW_RANGE=20

local function debugEffect(inst)
if dev_mode then
aipSpawnPrefab(inst,"aip_shadow_wrapper").DoShow()
end
end

local function isInOcean(tgtPT,range)
range=range or 3
local tgtPT_LT=Vector3(tgtPT.x-range,0,tgtPT.z-range)
local tgtPT_LB=Vector3(tgtPT.x-range,0,tgtPT.z+range)
local tgtPT_RT=Vector3(tgtPT.x+range,0,tgtPT.z-range)
local tgtPT_RB=Vector3(tgtPT.x+range,0,tgtPT.z+range)

if
TheWorld.Map:IsOceanAtPoint(tgtPT.x,tgtPT.y,tgtPT.z) and
TheWorld.Map:IsOceanAtPoint(tgtPT_LT.x,tgtPT_LT.y,tgtPT_LT.z) and
TheWorld.Map:IsOceanAtPoint(tgtPT_LB.x,tgtPT_LB.y,tgtPT_LB.z) and
TheWorld.Map:IsOceanAtPoint(tgtPT_RT.x,tgtPT_RT.y,tgtPT_RT.z) and
TheWorld.Map:IsOceanAtPoint(tgtPT_RB.x,tgtPT_RB.y,tgtPT_RB.z)
then
return true
end

return false
end


local function butterflyShow(pos)
local butterfly=TheSim:FindEntities(
pos.x,pos.y,pos.z,SHOW_RANGE,{ "butterfly" }
)[1]


if butterfly~=nil and butterfly.components.locomotor~=nil then
local wings=aipSpawnPrefab(butterfly,"butterflywings")
wings.AnimState:OverrideMultColour(0,0,0,0)

local butterflyPt=butterfly:GetPosition()
local bird=aipSpawnPrefab(butterfly,"robin")
bird.Physics:Teleport(butterflyPt.x,6,butterflyPt.z)

if bird.components.eater~=nil then
bird.components.eater:SetDiet({ FOODTYPE.VEGGIE },{ FOODTYPE.VEGGIE })
end
bird.bufferedaction=BufferedAction(bird,wings,ACTIONS.EAT)


butterfly.components.locomotor:Stop()
butterfly.components.locomotor:SetExternalSpeedMultiplier(
butterfly,"aip_lock_move",0
)

butterfly:DoTaskInTime(0.5,function()
wings.AnimState:OverrideMultColour(1,1,1,1)
aipFlingItem(wings)
butterfly:Remove()
end)

return true
end
end


local function grassShow(pos)
local grasses=TheSim:FindEntities(
pos.x,pos.y,pos.z,SHOW_RANGE,{ "plant","renewable" }
)

grasses=aipFilterTable(grasses,function(item)
return (
item.prefab=="grass" and
item.components.pickable~=nil and
item.components.pickable:CanBePicked()
)
end)

if #grasses >=2 then
local grass1=grasses[1]
local grass2=grasses[2]

local rabbit=aipSpawnPrefab(grass1,"rabbit")

if rabbit.components.homeseeker==nil then
rabbit:AddComponent("homeseeker")
end
rabbit.components.homeseeker.home=grass2

if rabbit.components.locomotor~=nil then
rabbit.components.locomotor:SetExternalSpeedMultiplier(
rabbit,"aip_lock_move",1.5
)
end

rabbit:DoTaskInTime(0.1,function()
rabbit:PushEvent("gohome")
rabbit.components.homeseeker:GoHome(true)
end)

return true
end
end


local function rabbitShow(pos)
local rabbit=TheSim:FindEntities(
pos.x,pos.y,pos.z,SHOW_RANGE,{ "rabbit" }
)[1]

if rabbit~=nil and rabbit.prefab=="rabbit" then
debugEffect(rabbit)

local buzzard=aipSpawnPrefab(rabbit,"buzzard",nil,30)
buzzard.sg:GoToState("glide")

buzzard:DoTaskInTime(3,function()
buzzard.components.locomotor:Stop()
debugEffect(rabbit)
buzzard.sg:GoToState("flyaway")
end)

return true
end
end


local function jellyfishShow(pos)
local chance=dev_mode and 1 or 0.05

if

not TheWorld.state.isnight or

not TheWorld.Map:IsOceanAtPoint(pos.x,pos.y,pos.z,true) or

math.random() > chance
then
return
end


local randomAngle=math.random()*2*PI
local dist=15

local tgtPT=pos+Vector3(math.cos(randomAngle)*dist,0,math.sin(randomAngle)*dist)
local tgtPT_LT=Vector3(tgtPT.x-3,0,tgtPT.z-3)
local tgtPT_LB=Vector3(tgtPT.x-3,0,tgtPT.z+3)
local tgtPT_RT=Vector3(tgtPT.x+3,0,tgtPT.z-3)
local tgtPT_RB=Vector3(tgtPT.x+3,0,tgtPT.z+3)

if isInOcean(tgtPT,5) then
local jellyfishGrp=aipSpawnPrefab(nil,"aip_ocean_jellyfish_group",tgtPT.x,0,tgtPT.z)

debugEffect(jellyfishGrp)
return true
end
end


local function blinkFlowerShow(pos)
local chance=dev_mode and 1 or 0.05

if

not TheWorld.state.isnight or

not TheWorld.Map:IsLandTileAtPoint(pos.x,pos.y,pos.z) or

math.random() > chance
then
return
end


local randomAngle=math.random()*2*PI
local dist=15

local tgtPT=pos+Vector3(math.cos(randomAngle)*dist,0,math.sin(randomAngle)*dist)


if TheWorld.Map:IsLandTileAtPoint(tgtPT.x,tgtPT.y,tgtPT.z) then
local flowerGrp=aipSpawnPrefab(nil,"aip_blink_flower_group",tgtPT.x,0,tgtPT.z)

debugEffect(flowerGrp)
return true
end
end


local function vortexShow(pos)
local chance=dev_mode and 1 or 0.05

if

TheWorld.state.isnight or

not TheWorld.Map:IsOceanAtPoint(pos.x,pos.y,pos.z,true) or

math.random() > chance
then
return
end


local randomAngle=math.random()*2*PI
local dist=15

local tgtPT=pos+Vector3(math.cos(randomAngle)*dist,0,math.sin(randomAngle)*dist)

if isInOcean(tgtPT,10) then
local vortex=aipSpawnPrefab(nil,"aip_ocean_vortex",tgtPT.x,0,tgtPT.z)

debugEffect(vortex)
return true
end
end


local function turnMushroomShow(pos)
local chance=dev_mode and 1 or 0.05

if

TheWorld.state.isnight or

TheWorld.Map:IsOceanAtPoint(pos.x,pos.y,pos.z,false) or

math.random() > chance
then
return
end


local newPT=aipGetSpawnPoint(pos,dev_mode and 5 or 20)
if newPT~=nil then
aipSpawnPrefab(nil,"aip_turn_mushroom",newPT.x,0,newPT.z)

return true
end
end


local function graveyardWispShow(pos)
local chance=dev_mode and 1 or 0.05

if

not TheWorld.state.isnight or

math.random() > chance
then
return
end


local gravestone=aipFindNearEnts(pos,{ "gravestone","mound" },20)[1]

if gravestone~=nil then
local wisp=aipSpawnPrefab(gravestone,"aip_graveyard_wisp")
wisp.components.knownlocations:RememberLocation("home",gravestone:GetPosition())

return true
end
end


local function fishRainShow(pos,player)
local chance=dev_mode and 1 or 0.05

if

not TheWorld.state.israining or

not TheWorld.Map:IsOceanTileAtPoint(pos.x,pos.y,pos.z) or

math.random() > chance
then
return
end


local times=0
player._aipFishTask=player:DoPeriodicTask(2,function()
local playerPos=player:GetPosition()

local tgtPos=aipAngleDist(
playerPos,
math.random(0,360),
3+math.random()*8
)
local loots={
oceanfish_small_1_inv=1,
oceanfish_small_2_inv=1,
oceanfish_small_3_inv=1,
oceanfish_small_4_inv=1,
oceanfish_small_5_inv=1,
oceanfish_small_6_inv=1,
oceanfish_small_7_inv=1,
oceanfish_small_8_inv=1,
oceanfish_small_9_inv=1,
}
local randomFish=aipRandomLoot(loots)

local fish=SpawnPrefab(randomFish)
fish.Physics:Teleport(tgtPos.x,35,tgtPos.z)

times=times+1
if times >=30 then
player._aipFishTask:Cancel()
player._aipFishTask=nil
end
end)

return true
end


local function dirtPileShow(pos)
local chance=dev_mode and 1 or 0.05

if

TheWorld.state.isnight or

TheWorld.Map:IsOceanAtPoint(pos.x,pos.y,pos.z,false) or

math.random() > chance
then
return
end


local newPT=aipGetSpawnPoint(pos,dev_mode and 5 or 20)
if newPT~=nil then
aipSpawnPrefab(nil,"aip_dirtpile",newPT.x,0,newPT.z)

return true
end
end


local function dropLeafShow(pos)
local chance=dev_mode and 1 or 0.05
if math.random() > chance then
return
end


local trees=TheSim:FindEntities(
pos.x,pos.y,pos.z,10,{ "petrifiable","plant","tree" }
)

local matchTree=aipFilterTable(trees,function(item)
if
(item.prefab=="evergreen" or item.prefab=="evergreen_sparse") and
item.components.growable and item.components.growable:GetStage()==3
then
return true
end
end)[1]

if matchTree then
local treePos=matchTree:GetPosition()
local prefabName=PrefabExists("aip_leaf_note") and "aip_leaf_note" or "pinecone"
local dropItem=aipSpawnPrefab(matchTree,prefabName)

dropItem.Physics:Teleport(treePos.x+1,3,treePos.z)
return true
end
end


local function dropStarShow(pos)
local chance=dev_mode and 1 or 0.04

if

not TheWorld.state.isnight or

math.random() > chance
then
return
end


local newPT=aipGetSpawnPoint(pos,dev_mode and 5 or 10)
if newPT~=nil then
local star=aipSpawnPrefab(nil,"aip_star_fragment")
star.Physics:Teleport(newPT.x,35,newPT.z)
star.persists=false

if star.RandomColor then
star.RandomColor(star,false)
end

return true
end
end


local function skeletonShow(pos)
local chance=dev_mode and 1 or 0.04

if

not TheWorld.state.isnight or

math.random() > chance
then
return
end


local newPT=aipGetSpawnPoint(pos,dev_mode and 5 or 20)
if newPT~=nil then
local star=aipSpawnPrefab(nil,"aip_wither_skeleton",newPT.x,newPT.y,newPT.z)

return true
end
end


local function createIfPossible(inst,prefab,tag)
local oldoneHand=TheSim:FindFirstEntityWithTag(tag)


if oldoneHand~=nil and oldoneHand.prefab~=prefab then
return
end

local target=nil
local newItem=false

if oldoneHand==nil then
target=aipSpawnPrefab(inst,prefab)
newItem=true
elseif oldoneHand.components.inventoryitem:GetGrandOwner()==nil then
target=oldoneHand

aipSpawnPrefab(oldoneHand,"aip_shadow_wrapper").DoShow()


local ptg=target.components.finiteuses:GetPercent()+.25
target.components.finiteuses:SetPercent(
math.min(1,ptg)
)
end

if target~=nil then
aipFlingItem(target,inst:GetPosition())
end

return target,newItem
end



local function OnGrueAttacked(inst)

local chance=dev_mode and 1 or 0.05

if TheWorld:HasTag("forest") and math.random() <=chance then
inst.components.aipc_player_show:CreateOldoneHand()
end
end


local function OnFinishedWork(inst,data)
local chance=dev_mode and 1 or 0.05

if data~=nil and data.target~=nil then
if data.target.prefab=="moonglass_rock" and math.random() <=chance then
inst.components.aipc_player_show:CreateLivingFriendship()
end
end
end


local PlayerShow=Class(function(self,inst)
self.inst=inst

self.showTask=nil

self.inst:ListenForEvent("attackedbygrue",OnGrueAttacked)

self.inst:ListenForEvent("finishedwork",OnFinishedWork)

self.inst:WatchWorldState("isnight",function(_,isnight)
local chance=dev_mode and 1 or 0.1

if isnight and math.random() < chance then
self:StartShow()
end
end)

if dev_mode then
self.inst:DoTaskInTime(5,function()
self:StartShow()
end)
end
end)



function PlayerShow:StopShow()
if self.showTask then
self.showTask:Cancel()
self.showTask=nil
end
end

function PlayerShow:StartShow()
self:StopShow()

self.showTask=self.inst:DoPeriodicTask(1,function()
local pos=self.inst:GetPosition()

local funcList={
grassShow,
butterflyShow,
rabbitShow,
jellyfishShow,
blinkFlowerShow,
vortexShow,
turnMushroomShow,
graveyardWispShow,
fishRainShow,
dirtPileShow,
dropLeafShow,
dropStarShow,
skeletonShow,
}

local randomFunc=dev_mode and skeletonShow or aipRandomEnt(funcList)


if randomFunc(pos,self.inst) then
self:StopShow()
end
end)
end



function PlayerShow:CreateOldoneHand()
self:StopShow()
local item,newItem=createIfPossible(self.inst,"aip_oldone_hand","aip_DivineRapier_bad")

if item and newItem and aipUnique() then
item._aipKillerCount=aipUnique():OldoneKillCount()
end
end


function PlayerShow:CreateLivingFriendship()
self:StopShow()
createIfPossible(self.inst,"aip_living_friendship","aip_DivineRapier_good")
end

return PlayerShow