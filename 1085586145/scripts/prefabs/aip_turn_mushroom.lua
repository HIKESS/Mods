local dev_mode=aipGetModConfig("dev_mode")=="enabled"

require "prefabs/veggies"

local cooking=require("cooking")
local ingredients=cooking.ingredients

local language=aipGetModConfig("language")


local LANG_MAP={
english={
NAME="Transform Mushroom",
DESC="What can it do?",
},
chinese={
NAME="变形环蘑",
DESC="它能对什么起作用呢？",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_TURN_MUSHROOM=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_TURN_MUSHROOM=LANG.DESC


local assets={
Asset("ANIM","anim/aip_turn_mushroom.zip"),
}


local DIST=1.5


local seedsPool={
seeds=0,
}

for veggieName,veggieInfo in pairs(VEGGIES) do
if veggieInfo.seed_weight and veggieInfo.seed_weight > 0 then
seedsPool[veggieName.."_seeds"]=veggieInfo.seed_weight
end
end


local treeSeedsPool={
pinecone=1,
acorn=1,
twiggy_nut=1,
seeds=2,
palmcone_seed=0.1,
marblebean=0.5,
rock_avocado_fruit=1,
}


local gemsPool={
redgem=1,
bluegem=1,
purplegem=1,
orangegem=1,
yellowgem=1,
greengem=1,
opalpreciousgem=0.1,
}


local stonesPool={
thulecite_pieces=0.1,
rocks=1,
flint=1,
nitre=1,
goldnugget=1,
}


local reedsPool={
cutgrass=1,
cutreeds=1,
}


local woodsPool={
log=1,
driftwood_log=1,
livinglog=0.2,
twigs=
1,
}


local lightPool={
purebrilliance=0.5,
moonglass_charged=1,
moonglass=2,
horrorfuel=0.5,
dreadstone=1,
nightmarefuel=2,
}


local flowerPool={
petals=1,
petals_evil=1,
foliage=1,
kelp=1,
kelp_dried=1,
}


local meatPool={
meat=1,
cookedmeat=1,
meat_dried=1,

monstermeat=1,
cookedmonstermeat=1,
monstermeat_dried=1,

plantmeat=1,
plantmeat_cooked=1,

fishmeat=1,
fishmeat_cooked=1,

trunk_summer=1,
trunk_winter=1,
trunk_cooked=1,

aip_oldone_meat=1,
}


local smallMeatPool={
fishmeat_small=1,
fishmeat_small_cooked=1,

drumstick=1,
drumstick_cooked=1,

froglegs=1,
froglegs_cooked=1,

batwing=1,
batwing_cooked=1,

smallmeat=1,
cookedsmallmeat=1,
smallmeat_dried=1,

batnose=1,
batnose_cooked=1,

eel=1,
eel_cooked=1,

aip_oldone_meat=1,
}


local fruitsPool={
}

local randomPools={
seedsPool,
treeSeedsPool,
gemsPool,
stonesPool,
reedsPool,
woodsPool,
lightPool,
flowerPool,
meatPool,
smallMeatPool,
}


local function hidePrefab(inst)
inst:AddTag("NOCLICK")
inst:AddTag("FX")
inst.AnimState:PlayAnimation("empty")
end

local function onNear(inst,player)

if inst.components.aipc_timer==nil then
return
end


local allValidPrefabs={}
for i,pool in ipairs(randomPools) do
for prefabName,weight in pairs(pool) do
table.insert(allValidPrefabs,prefabName)
end
end


for prefabName,info in pairs(ingredients) do
table.insert(allValidPrefabs,prefabName)
end

inst.components.aipc_timer:NamedInterval("PlayerNear",1,function()

local prefabs=aipFindNearEnts(inst,allValidPrefabs,DIST-0.2,false)
if #prefabs <=0 then
return
end


local targetPrefab=aipRandomEnt(prefabs)
local targetPrefabName=targetPrefab.prefab


local targetPool=nil
for i,pool in ipairs(randomPools) do
if pool[targetPrefabName]~=nil then
targetPool=pool
break
end
end


if targetPool==nil and ingredients[targetPrefabName]~=nil then
local tags=ingredients[targetPrefabName].tags or {}
local filteredTags=aipFilterKeysTable(tags,{ "precook","dried" })


targetPool={}
for name,info in pairs(ingredients) do
local tgtTags=info.tags or {}


for tag,_ in pairs(filteredTags) do
if tgtTags[tag]~=nil then
targetPool[name]=math.max(targetPool[name] or 0,tgtTags[tag])
end
end
end

aipTypePrint("变形列表:",targetPool)
end

if targetPool==nil then
return
end


if player.components.builder and not player.components.builder:KnowsRecipe("aip_gholdengo") then
local chance=dev_mode and 1 or 0.25

if aipChance(chance,player,1) then
targetPool={ aip_gholdengo_blueprint=1 }
end
end


for i=1,20 do
local nextPrefab=aipRandomLoot(targetPool)
if nextPrefab and nextPrefab~=targetPrefabName and PrefabExists(nextPrefab) then
aipSpawnPrefab(targetPrefab,"aip_fx_splode").DoShow()
local nextItem=aipSpawnPrefab(targetPrefab,nextPrefab)

aipFlingItem(nextItem)
aipRemove(targetPrefab)

aipTypePrint("动态变形:",nextPrefab)


inst:Remove()
break
end
end

end)
end

local function onFar(inst)
if inst.components.aipc_timer~=nil then
inst.components.aipc_timer:KillName("PlayerNear")
end
end


local function initMatrix(inst)
if inst._aipMaster~=nil then
return
end

inst._aipStones={}


hidePrefab(inst)


local cx,cy,cz=inst.Transform:GetWorldPosition()
local min=6
local max=8
local count=math.random(min,max)

local startAngle=PI*2*math.random()

for i=1,count do
local angle=startAngle+PI*2*i/count

local stone=aipSpawnPrefab(
nil,"aip_turn_mushroom",
cx+math.cos(angle)*DIST,
cy,
cz+math.sin(angle)*DIST
)

stone._aipMaster=inst

table.insert(inst._aipStones,stone)
end


local playerDist=DIST+2
inst:AddComponent("playerprox")
inst.components.playerprox:SetDist(playerDist,playerDist)
inst.components.playerprox:SetOnPlayerNear(onNear)
inst.components.playerprox:SetOnPlayerFar(onFar)
end

local function OnRemoveEntity(inst)
if inst._aipStones~=nil then
for i,stone in ipairs(inst._aipStones) do
aipReplacePrefab(stone,"aip_shadow_wrapper").DoShow(0.2)
end
end
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

inst.AnimState:SetBank("aip_turn_mushroom")
inst.AnimState:SetBuild("aip_turn_mushroom")
inst.AnimState:PlayAnimation("m"..math.random(4))

local scale=0.4+math.random()*0.3
inst.Transform:SetScale(scale,scale,scale)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("aipc_timer")

inst:DoTaskInTime(0.1,initMatrix)

inst.persists=false

inst.OnRemoveEntity=OnRemoveEntity

return inst
end

return Prefab("aip_turn_mushroom",fn,assets)
