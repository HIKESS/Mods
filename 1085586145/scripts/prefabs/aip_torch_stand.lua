

local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local additional_building=aipGetModConfig("additional_building")
if additional_building~="open" then return nil end

local language=aipGetModConfig("language")

local LANG_MAP={
english={
NAME="Moonlight Torch",
DESC="It longs to be illuminated by the warm and cold firelight",
NAME_MAIN="Guarded Moonlight Torch",
NAME_PILLAR="Shaded Moonlight Torch",
NAME_CRAB="Clawed Moonlight Torch",
NAME_PORTAL="Jungle Moonlight Torch",
NAME_CRITTER="Hidden Moonlight Torch",
WIN_TALK="Go back to the Bumblebee",
TORCH_BUFF_NAME="Igniter",
},
chinese={
NAME="月光火柱",
DESC="它渴望被即温暖又寒冷的火光照亮",
NAME_MAIN="受看管的月光柱",
NAME_PILLAR="荫蔽的月光柱",
NAME_CRAB="巨钳的月光柱",
NAME_PORTAL="丛林的月光柱",
NAME_CRITTER="躲藏的月光柱",
WIN_TALK="赶紧去找熊蜂吧",
TORCH_BUFF_NAME="点火者",
}
}

local LANG=LANG_MAP[language] or LANG_MAP.english

local assets={
Asset("ANIM","anim/aip_torch_stand.zip"),
}

local list={
{
name="main",
postFn=function(inst)

inst.components.aipc_type_fire.forever=true


inst:DoTaskInTime(1,function()
local bee=aipSpawnPrefab(inst,"aip_nectar_bee")
bee.aipHome=inst:GetPosition()
end)
end,
devKeep=true,
},
{
name="critter",
target="critterlab",
devKeep=true,
},
{
name="pillar",
target="watertree_pillar",
ocean=true,
devKeep=true,
},
{
name="crab",
target=dev_mode and "not-exist" or "crabking",
fallbackPoint="ocean",
ocean=true,
devKeep=true,
},
{
name="portal",
target="monkeyisland_portal",

min=5,
max=25,
devKeep=true,
},
}

if dev_mode then
list=aipFilterTable(list,function(data)
return data.devKeep
end)
end




aipBufferRegister("aip_torch_warm",{
name=LANG.TORCH_BUFF_NAME,
showFX=false,
})


local function onhammered(inst,worker)
inst.components.lootdropper:DropLoot()
local x,y,z=inst.Transform:GetWorldPosition()
local fx=SpawnPrefab("collapse_small")
fx.Transform:SetPosition(x,y,z)
fx:SetMaterial("stone")
inst:Remove()
end

local function onhit(inst,worker)
inst.AnimState:PlayAnimation("hit")
inst.AnimState:PushAnimation("idle")
end


local function postTypeFire(inst,fx,type)
if fx.components.firefx then
fx.components.firefx:SetLevel(2)
end

fx:AddTag("aip_rubik_fire")
fx:AddTag("aip_rubik_fire_"..type)





inst.AnimState:PlayAnimation("idle",false)

end


local function onToggleFire(inst,type)
if inst.components.activatable~=nil then
inst.components.activatable.inactive=type=="mix"
end


if type=="mix" and inst.components.talker~=nil then
inst:DoTaskInTime(1,function()
inst.components.talker:Say(LANG.WIN_TALK)
end)

local nearPlayers=aipFindNearPlayers(inst,3)
for _,player in ipairs(nearPlayers) do
aipBufferPatch(inst,player,"aip_torch_warm",60*15)
end
end
end



local function toggleActive(inst,doer)
inst.components.activatable.inactive=true

if doer.player_classified==nil then
return
end


local nextInfo=list[inst.aipIndex+1]
if nextInfo==nil then
return
end


local nextName="aip_torch_stand_"..nextInfo.name
local nextPrefab=TheSim:FindFirstEntityWithTag(nextName)


if nextPrefab==nil then
local tgtPos=nil
local nextTarget=aipFindEnt(nextInfo.target)

if nextTarget then
tgtPos=nextTarget:GetPosition()
elseif nextInfo.fallbackPoint=="ocean" then
tgtPos=aipFindRandomPointInOcean(10)
end

if not tgtPos then
return
end

local rndPt=aipGetSecretSpawnPoint(
tgtPos,
nextInfo.min or 30,
nextInfo.max or 80,
nil,
nextInfo.ocean~=true
)
nextPrefab=aipSpawnPrefab(nil,nextName,rndPt)
end


local x,y,z=nextPrefab.Transform:GetWorldPosition()
doer.player_classified.revealmapspot_worldx:set(x)
doer.player_classified.revealmapspot_worldz:set(z)
doer.player_classified.revealmapspotevent:push()

doer:DoStaticTaskInTime(4*FRAMES,function()
doer.player_classified.MapExplorer:RevealArea(x,y,z,true,true)
end)
end


local function commonFn(hasNext,ocean)
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()


if ocean then
MakeWaterObstaclePhysics(inst,0.05,2,0.75)
MakeInventoryFloatable(inst,"med",nil,0.85)
inst.components.floater.bob_percent=0
else
MakeObstaclePhysics(inst,.05)
end


inst.AnimState:SetBank("aip_torch_stand")
inst.AnimState:SetBuild("aip_torch_stand")
inst.AnimState:PlayAnimation("idle",false)


inst:AddTag("structure")
inst:AddTag("aip_can_lighten")

if not hasNext then
inst:AddTag("aip_torch_stand_final_test")
end

inst.entity:SetPristine()

if not TheWorld.ismastersim then return inst end

if ocean then
local land_time=(POPULATING and math.random()*5*FRAMES) or 0
inst:DoTaskInTime(land_time,function(inst)
inst.components.floater:OnLandedServer()
end)
end


inst:AddComponent("lootdropper")


inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
inst.components.workable:SetWorkLeft(4)
inst.components.workable:SetOnFinishCallback(onhammered)
inst.components.workable:SetOnWorkCallback(onhit)


if hasNext then
inst:AddComponent("activatable")
inst.components.activatable.OnActivate=toggleActive
inst.components.activatable.quickaction=true
inst.components.activatable.inactive=false
else
inst:AddComponent("talker")
inst.components.talker.fontsize=30
inst.components.talker.font=TALKINGFONT
inst.components.talker.colour=Vector3(.9,1,.9)
inst.components.talker.offset=Vector3(0,-500,0)
end


inst:AddComponent("aipc_type_fire")
inst.components.aipc_type_fire.hotPrefab="aip_hot_fire"
inst.components.aipc_type_fire.coldPrefab="coldfirefire"
inst.components.aipc_type_fire.mixPrefab="aip_mix_fire"
inst.components.aipc_type_fire.followSymbol="firefx"
inst.components.aipc_type_fire.followOffset=Vector3(0,0,0)
inst.components.aipc_type_fire.postFireFn=postTypeFire
inst.components.aipc_type_fire.onToggle=onToggleFire


inst:AddComponent("inspectable")

return inst
end


local prefabList={}
for i,info in ipairs(list) do
local name="aip_torch_stand_"..info.name
local upName=string.upper(name)


STRINGS.NAMES[upName]=LANG["NAME_"..string.upper(info.name)]
STRINGS.CHARACTERS.GENERIC.DESCRIBE[upName]=LANG.DESC

local fn=function()
local inst=commonFn(i < #list,info.ocean)
inst:AddTag(name)

if not TheWorld.ismastersim then return inst end

if info.postFn then
info.postFn(inst)
end

inst.aipIndex=i

return inst
end

table.insert(prefabList,Prefab(name,fn,assets))
end

return unpack(prefabList)