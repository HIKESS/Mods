local foldername=KnownModIndex:GetModActualName(TUNING.ZOMBIEJ_ADDTIONAL_PACKAGE)



local additional_building=aipGetModConfig("additional_building")
if additional_building~="open" then
return nil
end

local language=aipGetModConfig("language")

local aip_nectar_config=require("prefabs/aip_nectar_config")

local QUALITY_COLORS=aip_nectar_config.QUALITY_COLORS
local LANG_MAP=aip_nectar_config.LANG_MAP
local LANG_VALUE_MAP=aip_nectar_config.LANG_VALUE_MAP
local VALUE_WEIGHT=aip_nectar_config.VALUE_WEIGHT
local VALUE_EAT_BONUS=aip_nectar_config.VALUE_EAT_BONUS

local LANG=LANG_MAP[language] or LANG_MAP.english
local LANG_VALUE=LANG_VALUE_MAP[language] or LANG_VALUE_MAP.english


local LANG_BUFFER_MAP={
english={
DRUNK_BUFF_NAME="Drunk",
},
chinese={
DRUNK_BUFF_NAME="醉酒",
},
}
local LANG_BUFFER=LANG_BUFFER_MAP[language] or LANG_BUFFER_MAP.english


STRINGS.NAMES.AIP_NECTAR=LANG.NAME
STRINGS.RECIPE_DESC.AIP_NECTAR=LANG.DESC


local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local STEP_HP=5
local STEP_SAN=3
local STEP_BLOOD=dev_mode and 100 or 5
local STEP_DAMAGE=dev_mode and 50 or 5

local BASE_COLOR=.25
local GENERATION_AFFECT=.95


local assets=
{
Asset("ANIM","anim/aip_nectar.zip"),
Asset("ATLAS","images/inventoryimages/aip_nectar_0.xml"),
Asset("ATLAS","images/inventoryimages/aip_nectar_1.xml"),
Asset("ATLAS","images/inventoryimages/aip_nectar_2.xml"),
Asset("ATLAS","images/inventoryimages/aip_nectar_3.xml"),
Asset("ATLAS","images/inventoryimages/aip_nectar_4.xml"),
Asset("ATLAS","images/inventoryimages/aip_nectar_5.xml"),
Asset("ATLAS","images/inventoryimages/aip_nectar_wine.xml"),
}

local prefabs={}


local function onVampireAttackOther(inst,data)
local target=data.target
if target~=nil and inst.components.health then
inst.components.health:DoDelta(STEP_BLOOD)
end
end

local function onDamageAttackOther(inst,data)
local target=data.target
if target~=nil and target.components.health then
target.components.health:DoDelta(-STEP_DAMAGE,true,"nectar")
end
end


local function bufferDrunkFn(source,eater,info)
local interval=info.interval
local passTime=info.passTime

local speedMulti=1+(math.floor(passTime) % 2==0 and 1 or-1)*TUNING.NECTAR_DRUNK_SPEED_MULT

eater.components.locomotor:SetExternalSpeedMultiplier(
eater,"aip_nectar_drunk",speedMulti
)
end

local function bufferDrunkEndFn(source,eater,info)
eater.components.locomotor:RemoveExternalSpeedMultiplier(eater,"aip_nectar_drunk")
end

aipBufferRegister("aip_nectar_drunk",{
name=LANG_BUFFER.DRUNK_BUFF_NAME,
fn=bufferDrunkFn,
endFn=bufferDrunkEndFn,
showFX=true,
})


local function onEaten(inst,eater)
if not inst.nectarContinueValues or not eater.components.aipc_timer then
return
end

local health=inst.nectarContinueValues.health or 0
local sanity=inst.nectarContinueValues.sanity or 0
local speedTime=inst.nectarContinueValues.speedTime or 0
local vampireTime=inst.nectarContinueValues.vampireTime or 0
local damageTime=inst.nectarContinueValues.damageTime or 0
local drunkTime=inst.nectarContinueValues.drunkTime or 0


if health and sanity then
eater.components.aipc_timer:Interval(1,function()
if not eater.components.health or eater.components.health:IsDead() then
return false
end

local recoverHealth=math.min(health,STEP_HP)
local recoverSanity=math.min(sanity,STEP_SAN)

health=health-recoverHealth
sanity=sanity-recoverSanity

if health==0 and sanity==0 then
return false
end


eater.components.health:DoDelta(recoverHealth)


if eater.components.sanity then
eater.components.sanity:DoDelta(recoverSanity)
end
end)
end


if eater.components.locomotor and speedTime then
eater.components.locomotor:SetExternalSpeedMultiplier(eater,"aip_nectar",TUNING.NECTAR_SPEED_MULT)

eater.components.aipc_timer:Timeout(speedTime,function()
eater.components.locomotor:RemoveExternalSpeedMultiplier(eater,"aip_nectar")
end)
end


if vampireTime then
eater:ListenForEvent("onattackother",onVampireAttackOther)

eater.components.aipc_timer:Timeout(vampireTime,function()
eater:RemoveEventCallback("onattackother",onVampireAttackOther)
end)
end


if damageTime then
eater:ListenForEvent("onattackother",onDamageAttackOther)

eater.components.aipc_timer:Timeout(damageTime,function()
eater:RemoveEventCallback("onattackother",onDamageAttackOther)
end)
end


if drunkTime then
aipBufferPatch(eater,eater,"aip_nectar_drunk",drunkTime)
end
end


local function onRefreshName(inst)
local changeColor=1-BASE_COLOR

local name=LANG.NAME
local nectarValues=inst.nectarValues or {}


local nectarR=0
local nectarG=0
local nectarB=0
local nectarA=0


local health=0
local hunger=0
local sanity=0
local temperature=0
local temperatureduration=0



if nectarValues.purity~=nil then
inst:RemoveComponent("burnable")
end


local topTag="tasteless"
local topTagVal=0
local totalTagVal=0
local totalTagCount=0
local tagBalance=false

for tag,tagVal in pairs (nectarValues) do
if tag~="exquisite" and tag~="generation" and tag~="purity" and tag~="baseline" then
totalTagVal=totalTagVal+tagVal
totalTagCount=totalTagCount+1


if topTagVal==tagVal then
tagBalance=true

elseif topTagVal < tagVal and LANG_VALUE[tag]~=nil then
topTag=tag
topTagVal=tagVal
tagBalance=false
end


local color=VALUE_WEIGHT[tag] or {1,1,1,1}
nectarR=nectarR+color[1]*tagVal
nectarG=nectarG+color[2]*tagVal
nectarB=nectarB+color[3]*tagVal
nectarA=nectarA+color[4]*tagVal


local eatBonus=VALUE_EAT_BONUS[tag] or {}
health=health+(eatBonus.health or 0)*tagVal
hunger=hunger+(eatBonus.hunger or 0)*tagVal
sanity=sanity+(eatBonus.sanity or 0)*tagVal
temperatureduration=temperatureduration+(eatBonus.temperatureduration or 0)

if eatBonus.temperature then
temperature=eatBonus.temperature
end
end
end

inst.AnimState:SetMultColour(
BASE_COLOR+nectarR/totalTagVal*changeColor,
BASE_COLOR+nectarG/totalTagVal*changeColor,
BASE_COLOR+nectarB/totalTagVal*changeColor,
BASE_COLOR+nectarA/totalTagVal*changeColor
)


name=LANG_VALUE[topTag]..name


if nectarValues.exquisite then
name=LANG_VALUE.exquisite..name
end


if tagBalance then
name=LANG_VALUE.balance..name
end


if nectarValues.generation > 1 then
name=name..tostring(nectarValues.generation)..LANG_VALUE.generation
end

if inst.components.aipc_info_client then
inst.components.aipc_info_client:SetString("named",name)
end



local aipInfo=""
local mergedTopTagVal=topTagVal+(nectarValues.purity or 0)
local purePTG=mergedTopTagVal/totalTagVal
if purePTG > 0.99 then
aipInfo=aipInfo..LANG_VALUE.absolute
elseif purePTG < 0.5 then
aipInfo=aipInfo..LANG_VALUE.impurity
else
aipInfo=math.ceil(purePTG*100).."%"
end


local currentQuality=1
local minQuality=0
local maxQuality=1

--> 随着世代增加，最高品质也会增加（但是之后会慢慢下降上限）
if nectarValues.generation <=1 then
minQuality=0
maxQuality=2
elseif nectarValues.generation <=2 then
minQuality=0
maxQuality=3
elseif nectarValues.generation <=3 then
minQuality=0
maxQuality=4
elseif nectarValues.generation <=4 then
minQuality=0
maxQuality=5
elseif nectarValues.generation <=5 then
minQuality=0
maxQuality=4
elseif nectarValues.generation <=6 then
minQuality=0
maxQuality=3
elseif nectarValues.generation <=7 then
minQuality=0
maxQuality=2
end


local baseline=nectarValues.baseline or 0
if baseline > 0 then
local baselineQuality=math.min(5,math.floor(baseline/math.pow(6,(nectarValues.generation or 1))))
if baselineQuality > minQuality then
minQuality=baselineQuality
end
if baselineQuality > maxQuality then
maxQuality=baselineQuality
end
end


--> 纯度
if purePTG <=0.3 then
currentQuality=currentQuality-0.3
elseif purePTG <=0.4 then
currentQuality=currentQuality-0.2
elseif purePTG <=0.5 then
currentQuality=currentQuality-0.1
elseif purePTG >=0.95 then
currentQuality=currentQuality+Remap(purePTG,.95,1,.7,1.2)
elseif purePTG >=0.9 then
currentQuality=currentQuality+0.5
elseif purePTG >=0.8 then
currentQuality=currentQuality+0.3
end

--> 种类
currentQuality=currentQuality+math.min(1.5,totalTagCount*0.2)

--> 精酿
if nectarValues.exquisite then
currentQuality=currentQuality+1
end

--> 属性加成
currentQuality=currentQuality+math.min(1,totalTagVal*0.03)

--> 世代
currentQuality=currentQuality+math.min(1.5,(nectarValues.generation or 1)*0.15)

--> 花蜜
if nectarValues.nectar then
if nectarValues.nectar <=5 then
currentQuality=currentQuality+nectarValues.nectar*0.1
else
currentQuality=currentQuality-math.min(1,(nectarValues.nectar or 0)*0.1)
end
end

--> 可怕
currentQuality=currentQuality-(nectarValues.terrible or 0)

local realQuality=currentQuality
currentQuality=math.min(maxQuality,currentQuality)
currentQuality=math.max(minQuality,currentQuality)
currentQuality=math.floor(currentQuality)

local qualityName="quality_"..currentQuality


inst.currentQuality=currentQuality

if inst.components.aipc_info_client then
inst.components.aipc_info_client:SetString("aip_info",aipInfo.."-"..LANG_VALUE[qualityName])
inst.components.aipc_info_client:SetByteArray("aip_info_color",QUALITY_COLORS[qualityName])
end


if nectarValues.wine then
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_nectar_wine.xml"
inst.components.inventoryitem:ChangeImageName("aip_nectar_wine")
inst.AnimState:PlayAnimation("wine")
else
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_nectar_"..currentQuality..".xml"
inst.components.inventoryitem:ChangeImageName("aip_nectar_"..currentQuality)
inst.AnimState:PlayAnimation("q"..currentQuality)
end


local continueRecover=currentQuality >=3

health=health*math.pow(GENERATION_AFFECT,(nectarValues.generation or 1)-1)
hunger=hunger*math.pow(GENERATION_AFFECT,(nectarValues.generation or 1)-1)
sanity=sanity*math.pow(GENERATION_AFFECT,(nectarValues.generation or 1)-1)


if currentQuality==0 then
sanity=-20
end


if continueRecover then
inst.nectarContinueValues=inst.nectarContinueValues or {}
health=health/2
sanity=sanity/2

inst.nectarContinueValues.health=health
inst.nectarContinueValues.sanity=sanity
end


if nectarValues.light then
inst.nectarContinueValues=inst.nectarContinueValues or {}
inst.nectarContinueValues.speedTime=math.min(9+nectarValues.light*1,30)
end


if nectarValues.vampire then
inst.nectarContinueValues=inst.nectarContinueValues or {}
inst.nectarContinueValues.vampireTime=math.min(9+nectarValues.vampire*1,30)
end


if nectarValues.damage then
inst.nectarContinueValues=inst.nectarContinueValues or {}
inst.nectarContinueValues.damageTime=math.min(9+nectarValues.damage*1,30)
end


if nectarValues.wine then
inst.nectarContinueValues=inst.nectarContinueValues or {}
inst.nectarContinueValues.drunkTime=math.min(9+nectarValues.wine*1,30)
end

if inst.components.edible then
inst.components.edible.healthvalue=health
inst.components.edible.hungervalue=hunger
inst.components.edible.sanityvalue=sanity
inst.components.edible.temperaturedelta=temperature
inst.components.edible.temperatureduration=temperatureduration
inst.components.edible:SetOnEatenFn(onEaten)
end


local topEatName="health"
local topEatValue=health
local eatData={
["health"]=health,
["hunger"]=hunger,
["sanity"]=sanity,
}
for eatName,eatValue in pairs(eatData) do
if eatValue > topEatValue then
topEatName=eatName
topEatValue=eatValue
end
end

local checkStatus=""
if topEatValue <=10 then
checkStatus=LANG.littleOf
elseif topEatValue <=30 then
checkStatus=LANG.contains
elseif topEatValue <=60 then
checkStatus=LANG.lotsOf
else
checkStatus=LANG.fullOf
end

local statusStr=checkStatus.." "..LANG[topEatName]
if nectarValues.frozen then
statusStr=statusStr.."\n"..LANG.frozen
end

if continueRecover then
statusStr=statusStr.."\n"..LANG.continueRecover
end

if nectarValues.light then
statusStr=statusStr.."\n"..LANG.speedMulti
end

if nectarValues.vampire then
statusStr=statusStr.."\n"..LANG.suckBlook
end

if nectarValues.damage then
statusStr=statusStr.."\n"..LANG.damageMulti
end

inst.components.inspectable:SetDescription(statusStr)


if nectarValues.light then
inst.Light:Enable(true)
inst.Light:SetRadius(0.3)
inst.Light:SetIntensity(0.7)
inst.Light:SetFalloff(0.7)
inst.Light:SetColour(169/255,231/255,245/255)
else
inst.Light:Enable(false)
end

return {
topTagVal=topTagVal,
totalTagVal=totalTagVal,
currentQuality=currentQuality,
realQuality=realQuality,
maxQuality=maxQuality,
minQuality=minQuality,
generation=nectarValues.generation,
}
end



local function onPerish(inst)
local nectarValues=inst.nectarValues or {}

if nectarValues.starch then
nectarValues.wine=(nectarValues.wine or 0)+1
nectarValues.wine=math.min(nectarValues.wine,99)

inst.components.perishable.onperishreplacement=nil


inst:DoTaskInTime(0,function()
inst.components.perishable:SetPercent(1)
inst.components.perishable:StartPerishing()

onRefreshName(inst)
end)
end
end


local function onBurnt(inst)
local data=onRefreshName(inst)

local nectarValues=inst.nectarValues or {}
local restVal=data.totalTagVal-data.topTagVal


restVal=restVal*math.random(3,10)/10
nectarValues.purity=restVal

local nextData=onRefreshName(inst)
end


local function onSave(inst,data)
data.nectarValues=inst.nectarValues
end

local function onLoad(inst,data)
if data~=nil and data.nectarValues then
inst.nectarValues=data.nectarValues
end
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()
inst.entity:AddLight()
inst.Light:Enable(false)
inst.Light:EnableClientModulation(true)

MakeInventoryPhysics(inst)

MakeInventoryFloatable(inst,"small",0.15,0.9)

inst.AnimState:SetBank("aip_nectar")
inst.AnimState:SetBuild("aip_nectar")
inst.AnimState:PlayAnimation("q0")

inst:AddTag("aip_nectar")
inst:AddTag("aip_nectar_material")

inst.entity:SetPristine()


inst:AddComponent("aipc_info_client")

--> 初始化
inst.components.aipc_info_client:SetString("named",nil,true)
inst.components.aipc_info_client:SetString("aip_info",nil,true)
inst.components.aipc_info_client:SetByteArray("aip_info_color",nil,true)


inst:AddComponent("aipc_fuel")


inst.components.aipc_info_client:ListenForEvent("named",function(inst,newName)
inst.name=newName
end)

if not TheWorld.ismastersim then
return inst
end


inst.nectarValues={}


inst:AddComponent("inspectable")

inst:AddComponent("tradable")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_nectar_0.xml"
inst.components.inventoryitem.imagename="aip_nectar_0"


inst:AddComponent("edible")
inst.components.edible.foodtype=FOODTYPE.GOODIES
inst.components.edible.healthvalue=0
inst.components.edible.hungervalue=0
inst.components.edible.sanityvalue=0


inst:AddComponent("perishable")
inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
inst.components.perishable:StartPerishing()
inst.components.perishable.perishfn=onPerish
inst.components.perishable.onperishreplacement="spoiled_food"


MakeSmallBurnable(inst,dev_mode and 3 or 30)
inst.components.burnable:SetOnBurntFn(onBurnt)


MakeHauntableLaunch(inst)

inst.OnSave=onSave
inst.OnLoad=onLoad

inst:DoTaskInTime(0.1,onRefreshName)

return inst
end


local function winFn()
local inst=fn()

if not TheWorld.ismastersim then
return inst
end

inst:DoTaskInTime(0.01,function()
local next=aipReplacePrefab(inst,"aip_nectar")
next.nectarValues.wine=1
next.nectarValues.generation=1
end)

return inst
end

return Prefab("aip_nectar",fn,assets),Prefab("aip_nectar_debug_wine",winFn,assets)
