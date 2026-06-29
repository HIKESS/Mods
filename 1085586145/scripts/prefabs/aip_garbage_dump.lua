local language=aipGetModConfig("language")
local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local LANG_MAP={
english={
NAME="Garbage Dump",
REC_DESC="A garbage dump for garbage",
DESC="Stinky!",
DESC_FULL="It's full of garbage!",
BEZOAR="Bezoar",
BEZOAR_DESC="Just right after the fire treatment",

BEZOAR_CURSED="Cursed Bezoar",
BEZOAR_CURSED_DESC="It's digesting the curse",
BEZOAR_CURSED_REC_DESC="Absorb the curse,it will recover over time",
},
chinese={
NAME="垃圾堆",
REC_DESC="一个可以放置垃圾的垃圾堆",
DESC="臭气熏天！",
DESC_FULL="已经被塞得满满当当了！",
BEZOAR="粪石",
BEZOAR_DESC="火候处理的刚刚好",

BEZOAR_CURSED="诅咒的粪石",
BEZOAR_CURSED_DESC="它正在消化诅咒",
BEZOAR_CURSED_REC_DESC="使用粪石吸收诅咒，随着时间推移粪石会逐渐复原",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_GARBAGE_DUMP=LANG.NAME
STRINGS.RECIPE_DESC.AIP_GARBAGE_DUMP=LANG.REC_DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_GARBAGE_DUMP=LANG.DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_GARBAGE_DUMP_FULL=LANG.DESC_FULL

STRINGS.NAMES.AIP_BEZOAR=LANG.BEZOAR
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_BEZOAR=LANG.BEZOAR_DESC

STRINGS.NAMES.AIP_BEZOAR_CURSED=LANG.BEZOAR_CURSED
STRINGS.RECIPE_DESC.AIP_BEZOAR_CURSED=LANG.BEZOAR_CURSED_REC_DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_BEZOAR_CURSED=LANG.BEZOAR_CURSED_DESC


local assets={
Asset("ANIM","anim/aip_garbage_dump.zip"),
Asset("ATLAS","images/inventoryimages/aip_garbage_dump.xml"),
Asset("ATLAS","images/inventoryimages/aip_bezoar.xml"),
Asset("ATLAS","images/inventoryimages/aip_bezoar_cursed.xml"),
}


local function getLv(inst)
if inst.aipCount >=20 then
return 4
elseif inst.aipCount >=10 then
return 3
elseif inst.aipCount >=5 then
return 2
end

return 1
end

local function getDesc(inst)
local lv=getLv(inst)

if lv==4 then
return STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_GARBAGE_DUMP_FULL
end

return STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_GARBAGE_DUMP
end


local function refresh(inst)
local lv=getLv(inst)

inst.AnimState:PlayAnimation("g"..lv)
end


local function canBeGiveOn(inst,doer,item)
return item and not item:HasTag("irreplaceable")
end

local function onDoGiveAction(inst,doer,item)

if item~=nil then
local count=1

if item.components.stackable~=nil then
count=item.components.stackable:StackSize()
end

inst.aipCount=inst.aipCount+count

item:Remove()
end

refresh(inst)
end


local function onHammered(inst,worker)

local lv=getLv(inst)

for i=1,lv do
aipFlingItem(
aipSpawnPrefab(inst,"spoiled_food")
)
end

aipReplacePrefab(inst,"collapse_small"):SetMaterial("stone")
end


local function onIgnite(inst)
inst.aipTime=GetTime()
end


local burnTime=10
local function onExtinguish(inst)
local lv=getLv(inst)

if inst.aipTime~=nil and lv==4 then
local diff=GetTime()-inst.aipTime

if diff > burnTime-(dev_mode and 5 or 1) then
aipReplacePrefab(inst,"aip_bezoar")
return
end
end

aipReplacePrefab(inst,"ash")
end

local function onBuilt(inst)
inst.AnimState:PlayAnimation("place")
inst.AnimState:PushAnimation("g1",false)
end


local function onSave(inst,data)
data.aipCount=inst.aipCount
end

local function onLoad(inst,data)
if data~=nil then
inst.aipCount=data.aipCount
end

refresh(inst)
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()


MakeObstaclePhysics(inst,.1)

inst.AnimState:SetBank("aip_garbage_dump")
inst.AnimState:SetBuild("aip_garbage_dump")
inst.AnimState:PlayAnimation("g1")

inst.entity:SetPristine()

inst:AddComponent("aipc_action_client")
inst.components.aipc_action_client.canBeGiveOn=canBeGiveOn

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")
inst.components.inspectable.descriptionfn=getDesc


inst:AddComponent("aipc_action")
inst.components.aipc_action.onDoGiveAction=onDoGiveAction


inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
inst.components.workable:SetWorkLeft(4)
inst.components.workable:SetOnFinishCallback(onHammered)


MakeMediumBurnable(inst,burnTime)
inst.components.burnable:SetOnIgniteFn(onIgnite)
inst.components.burnable:SetOnExtinguishFn(onExtinguish)

inst:ListenForEvent("onbuilt",onBuilt)

MakeHauntableLaunch(inst)

inst.aipCount=1

inst.OnLoad=onLoad
inst.OnSave=onSave

return inst
end


local function bezoarFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank("aip_garbage_dump")
inst.AnimState:SetBuild("aip_garbage_dump")
inst.AnimState:PlayAnimation("bezoar")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_bezoar.xml"

inst:AddComponent("stackable")
inst.components.stackable.maxsize=TUNING.STACK_SIZE_LARGEITEM

inst:AddComponent("inspectable")

inst:AddComponent("tradable")
inst.components.tradable.goldvalue=6

MakeHauntableLaunch(inst)

return inst
end


local function bezoarCursedFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank("aip_garbage_dump")
inst.AnimState:SetBuild("aip_garbage_dump")
inst.AnimState:PlayAnimation("bezoar_cursed")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_bezoar_cursed.xml"

inst:AddComponent("stackable")
inst.components.stackable.maxsize=TUNING.STACK_SIZE_LARGEITEM

inst:AddComponent("inspectable")

inst:AddComponent("tradable")
inst.components.tradable.goldvalue=1


inst:AddComponent("perishable")
inst.components.perishable:SetPerishTime(dev_mode and 15 or TUNING.JELLYBEAN_DURATION)
inst.components.perishable:StartPerishing()
inst.components.perishable.onperishreplacement="aip_bezoar"

MakeHauntableLaunch(inst)

return inst
end

return Prefab("aip_garbage_dump",fn,assets),
MakePlacer("aip_garbage_dump_placer","aip_garbage_dump","aip_garbage_dump","g1"),
Prefab("aip_bezoar",bezoarFn,assets),
Prefab("aip_bezoar_cursed",bezoarCursedFn,assets)
