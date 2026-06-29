local ILN=Ingredient("aip_leaf_note",1,"images/inventoryimages/aip_leaf_note.xml")
local IL=Ingredient("log",1)

local inscriptions={

aip_dou_fire_inscription={ tag="FIRE",recipes={ ILN,IL,Ingredient("redgem",1) } },
aip_dou_ice_inscription={ tag="ICE",recipes={ ILN,IL,Ingredient("bluegem",1) } },
aip_dou_sand_inscription={ tag="SAND",recipes={ ILN,IL,Ingredient("townportaltalisman",1) } },
aip_dou_heal_inscription={ tag="HEAL",recipes={ ILN,IL,Ingredient("butterflywings",1) } },
aip_dou_dawn_inscription={ tag="DAWN",recipes={ ILN,IL,Ingredient("nightmarefuel",1) } },
aip_dou_cost_inscription={ tag="COST",recipes={ ILN,IL,Ingredient("reviver",1) } },


aip_dou_follow_inscription={ tag="FOLLOW",recipes={ ILN,IL,Ingredient("feather_canary",1) } },
aip_dou_through_inscription={ tag="THROUGH",recipes={ ILN,IL,Ingredient("feather_robin_winter",1) } },
aip_dou_area_inscription={ tag="AREA",recipes={ ILN,IL,Ingredient("feather_robin",1) } },


aip_dou_split_inscription={ tag="SPLIT",recipes={ ILN,IL,Ingredient("steelwool",1) } },
aip_dou_rock_inscription={ tag="ROCK",recipes={ ILN,IL,Ingredient("walrus_tusk",1) } },
}

local categories={
FIRE="element",
ICE="element",
SAND="element",
HEAL="element",
DAWN="element",
COST="element",
ROCK="guard",
FOLLOW="action",
THROUGH="action",
AREA="action",
SPLIT="split",
}

local damages={
FIRE=12,
ICE=18,
SAND=5,
HEAL=25,
DAWN=10,
COST=15,
ROCK=24,
PLANT=5,
FOLLOW=0.01,
THROUGH=15,
AREA=5,
SPLIT=0.01,
}

local defaultColor={ 0.6,0.6,0.6,0.1 }

local colors={
FIRE={ 1,0.8,0,1 },
ICE={ 0.6,0.7,0.8,1 },
SAND={ 0.8,0.7,0.5,1 },
DAWN={ 0,0,0,0.5 },
COST={ 0.2,0.14,0.14,1 },
ROCK={ 0.6,0.6,0.6,1 },
HEAL={ 0.4,0.7,0.4,0.5 },
PLANT={ 0,0.6,0.1,0.5 },

_default=defaultColor,
}

local function getType(item)
local type=categories[item._douTag]
return { name=item._douTag,type=type,prefab=item.prefab }
end

local function createGroup(prevGrp)
local prev=prevGrp or {}

return {

action=nil,

element=prev.element or nil,

elementCount=0,

damage=math.max((prev.damage or 0)*0.75,5),

color=prev.color or defaultColor,

split=0,

guard=0,

cost=0,

vampire=false,

lock=false,
}
end

function calculateProjectile(items,inst)
local projectileInfo={
action=nil,
uses=1,
queue={},
}






local flattenItems=aipFlattenTable(items)

if #flattenItems==0 then
projectileInfo.queue={ createGroup() }
else
local group=nil
local prevGroup=nil

for i,item in pairs(flattenItems) do
if group==nil then
group=createGroup(prevGroup)
end

if item~=nil then
local typeInfo=getType(item)
local slotDamage=damages[typeInfo.name] or 5


if typeInfo.type=="element" then

if group.element~=typeInfo.name then
group.elementCount=0
end

group.element=typeInfo.name
group.elementCount=group.elementCount+1
group.damage=group.damage+slotDamage
group.color=colors[typeInfo.name] or defaultColor


projectileInfo.uses=projectileInfo.uses+1


elseif typeInfo.type=="guard" then
group.guard=group.guard+1
group.damage=group.damage+slotDamage


projectileInfo.uses=projectileInfo.uses+1


elseif typeInfo.type=="split" then
group.split=group.split+1
group.damage=group.damage+slotDamage


projectileInfo.uses=projectileInfo.uses+1


elseif typeInfo.type=="action" then

group.action=typeInfo.name
group.damage=group.damage+slotDamage

table.insert(projectileInfo.queue,group)
prevGroup=group
group=nil


projectileInfo.uses=projectileInfo.uses+2

elseif
typeInfo.prefab=="nightmarefuel" or
typeInfo.prefab=="aip_nightmare_package"
then

end
end
end


if group~=nil then
table.insert(projectileInfo.queue,group)
end
end


projectileInfo.action=projectileInfo.queue[1].action or "LINE"


for i,task in ipairs(projectileInfo.queue) do
if task.elementCount >=1 then
task.damage=task.damage*math.pow(1.25,task.elementCount-1)
end
end


local emp=inst~=nil and inst._aip_empower

if emp=="SAVING" then
projectileInfo.uses=projectileInfo.uses/2
elseif emp=="POWER" then
for i,task in ipairs(projectileInfo.queue) do
task.damage=task.damage*1.55
end
elseif emp=="VAMPIRE" then
for i,task in ipairs(projectileInfo.queue) do
task.vampire=true
end
elseif emp=="LOCK" then
for i,task in ipairs(projectileInfo.queue) do
task.lock=true
end
end

return projectileInfo
end

return {
calculateProjectile=calculateProjectile,
inscriptions=inscriptions,
colors=colors,
}