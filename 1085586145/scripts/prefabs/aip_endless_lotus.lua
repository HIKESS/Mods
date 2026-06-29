local language=aipGetModConfig("language")

require "prefabutil"

local skinUtil=require("utils/aip_skin_util")
local lotusConfig=require("configurations/skin/aip_endless_lotus")

local PREFAB="aip_endless_lotus"
local SEED_PREFAB="aip_endless_lotus_seed"
local FLOWER_PREFAB="aip_endless_lotus_flower"
local LEAF_PREFAB="aip_endless_lotus_leaf"
local ROOT_PREFAB="aip_endless_lotus_root"
local RIPPLE_PREFAB="aip_endless_lotus_ripple"
local BUILD="aip_endless_lotus"
local PLACER="aip_endless_lotus_placer"

local LANG_MAP={
english={
LOTUS_NAME="Endless Lotus",
LOTUS_DESC="It blooms between waves.",
SEED_NAME="Endless Lotus Seed",
SEED_DESC="It wants a quiet stretch of sea.",
FLOWER_NAME="Endless Lotus Bloom",
FLOWER_DESC="Tender enough to eat.",
LEAF_NAME="Endless Lotus Leaf",
LEAF_DESC="A quiet green sheet.",
ROOT_NAME="Endless Lotus Root",
ROOT_DESC="Crisp and hollow-hearted.",
},
chinese={
LOTUS_NAME="无尽之莲",
LOTUS_DESC="它在浪间静静绽放。",
SEED_NAME="无尽之莲子",
SEED_DESC="它想落在一片安静的海面上。",
FLOWER_NAME="无尽之莲花朵",
FLOWER_DESC="柔嫩得可以入口。",
LEAF_NAME="无尽之莲荷叶",
LEAF_DESC="一片安静的青绿。",
ROOT_NAME="无尽之莲藕",
ROOT_DESC="埋在水下的清脆根茎。",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_ENDLESS_LOTUS=LANG.LOTUS_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_ENDLESS_LOTUS=LANG.LOTUS_DESC
STRINGS.NAMES.AIP_ENDLESS_LOTUS_SEED=LANG.SEED_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_ENDLESS_LOTUS_SEED=LANG.SEED_DESC
STRINGS.NAMES.AIP_ENDLESS_LOTUS_FLOWER=LANG.FLOWER_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_ENDLESS_LOTUS_FLOWER=LANG.FLOWER_DESC
STRINGS.NAMES.AIP_ENDLESS_LOTUS_LEAF=LANG.LEAF_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_ENDLESS_LOTUS_LEAF=LANG.LEAF_DESC
STRINGS.NAMES.AIP_ENDLESS_LOTUS_ROOT=LANG.ROOT_NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_ENDLESS_LOTUS_ROOT=LANG.ROOT_DESC
skinUtil.RegisterBuildSkinConfig(lotusConfig,language,LANG.LOTUS_DESC)

local assets={
Asset("ANIM","anim/aip_endless_lotus.zip"),
Asset("ANIM","anim/aip_endless_lotus_root.zip"),
Asset("ATLAS","images/inventoryimages/aip_endless_lotus_seed.xml"),
Asset("ATLAS","images/inventoryimages/aip_endless_lotus_flower.xml"),
Asset("ATLAS","images/inventoryimages/aip_endless_lotus_leaf.xml"),
Asset("ATLAS","images/inventoryimages/aip_endless_lotus_root.xml"),
}

local rippleAssets={
Asset("ANIM","anim/oceanfishing_hook.zip"),
}

for _,asset in ipairs(lotusConfig.GetInventoryAtlasAssets(true)) do
table.insert(assets,asset)
end

local LOTUS_SKINS={ "style_1","style_2","style_3" }
local LOTUS_DEPLOY_RANGE_SPACING=DEPLOYSPACING.LARGE
local LOTUS_WATER_DEPLOY_RADIUS=DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT]
local LOTUS_RIPPLE_SCALE=2.85
local LOTUS_RIPPLE_Y_OFFSET=-0.15
local LOTUS_BLOOM_TIME=TUNING.TOTAL_DAY_TIME*3
local LOTUS_ROOT_GROW_TIME=TUNING.TOTAL_DAY_TIME*5
local LOTUS_ROOT_TIMER="aip_lotus_root_ready"
local LOTUS_PHYSICS_RADIUS=1
local LOTUS_PHYSICS_HEIGHT=1
local LOTUS_INTERACT_RADIUS=2.8
local LOTUS_DEPLOY_BLOCK_TAGS={ "aip_endless_lotus" }
local LOTUS_BUD_ANIMS={
style_1="bud_1",
style_2="bud_2",
style_3="bud_3",
}


local function getLotusAnim(inst,skin)
skin=lotusConfig.GetSkin(skin)

return inst._aipLotusBloomed~=nil and inst._aipLotusBloomed:value() and skin
or LOTUS_BUD_ANIMS[skin]
or LOTUS_BUD_ANIMS[lotusConfig.DEFAULT_SKIN]
end


local function playSkin(inst,skin)
inst.AnimState:PlayAnimation(getLotusAnim(inst,skin),true)
inst.AnimState:SetTime(math.random()*inst.AnimState:GetCurrentAnimationLength())
end

local skinner=skinUtil.CreatePrefabSkinner(lotusConfig,{
net_field="_aipEndlessLotusSkin",
current_field="_aipCurrentSkin",
dirty_event="aip_endless_lotus_skindirty",
set_fn_name="SetLotusSkin",
next_fn_name="NextLotusSkin",
play_fn=playSkin,
})


local function setLotusBloomed(inst,bloomed)
if inst._aipLotusBloomed~=nil then
inst._aipLotusBloomed:set(bloomed)
end

skinner.PlayCurrent(inst)
end


local function setRandomSkin(inst,allowSame)
local currentSkin=not allowSame and lotusConfig.GetSkin(inst._aipCurrentSkin) or nil
local nextSkin=LOTUS_SKINS[math.random(#LOTUS_SKINS)]

if currentSkin~=nil and #LOTUS_SKINS > 1 then
while nextSkin==currentSkin do
nextSkin=LOTUS_SKINS[math.random(#LOTUS_SKINS)]
end
end

inst:SetAipSkin(nextSkin)
end


local function setLotusRootReady(inst)
inst._aipLotusRootReady=true

if inst.components.timer~=nil and inst.components.timer:TimerExists(LOTUS_ROOT_TIMER) then
inst.components.timer:StopTimer(LOTUS_ROOT_TIMER)
end
end


local function startLotusRootTimer(inst)
inst._aipLotusRootReady=false

if inst.components.timer~=nil and not inst.components.timer:TimerExists(LOTUS_ROOT_TIMER) then
inst.components.timer:StartTimer(LOTUS_ROOT_TIMER,LOTUS_ROOT_GROW_TIME)
end
end


local function onTimerDone(inst,data)
if data~=nil and data.name==LOTUS_ROOT_TIMER then
setLotusRootReady(inst)
end
end


local function onDug(inst)
local loot={ LEAF_PREFAB }

if inst.components.pickable~=nil and inst.components.pickable:CanBePicked() then
table.insert(loot,FLOWER_PREFAB)
end

if inst._aipLotusRootReady then
table.insert(loot,ROOT_PREFAB)
end

inst.components.lootdropper:DropLoot(nil,loot)

local splash=SpawnPrefab("splash")
if splash~=nil then
splash.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

inst:Remove()
end


local function onBloomed(inst)
setLotusBloomed(inst,true)
end


local function onPicked(inst)
setLotusBloomed(inst,false)
end


local function makeEmpty(inst)
setLotusBloomed(inst,false)
end


local function onSave(inst,data)
skinner.OnSave(inst,data)
data.aipLotusRootReady=inst._aipLotusRootReady or nil
end


local function onLoad(inst,data)
skinner.OnLoad(inst,data)

if data~=nil and data.aipLotusRootReady then
inst._aipLotusRootReady=true
inst:DoTaskInTime(0,setLotusRootReady)
end
end


local function onDeploy(inst,pt,deployer)
inst=inst.components.stackable:Get()

local lotus=SpawnPrefab(PREFAB)
if lotus~=nil then
lotus.Transform:SetPosition(pt:Get())
lotus:RandomLotusSkin(true)
end

local splash=SpawnPrefab("splash")
if splash~=nil then
splash.Transform:SetPosition(pt:Get())
end

inst:Remove()
end


local function isNearOtherLotus(pt)
for _,lotus in ipairs(TheSim:FindEntities(pt.x,0,pt.z,LOTUS_INTERACT_RADIUS,LOTUS_DEPLOY_BLOCK_TAGS)) do
if lotus.entity:IsVisible() and lotus.entity:GetParent()==nil then
return true
end
end

return false
end


local function canDeployLotusSeed(inst,pt,mouseover)
return TheWorld.Map:CanDeployAtPointInWater(pt,inst,mouseover,{
land=0.2,
boat=0.2,
radius=LOTUS_WATER_DEPLOY_RADIUS,
}) and not isNearOtherLotus(pt)
end


local function addLotusPhysics(inst)

inst:SetPhysicsRadiusOverride(LOTUS_INTERACT_RADIUS)
inst:SetDeploySmartRadius(LOTUS_WATER_DEPLOY_RADIUS/2)

local phys=inst.entity:AddPhysics()
phys:SetMass(1)
phys:SetFriction(0)
phys:SetDamping(5)
phys:SetRestitution(0.1)
phys:SetCollisionGroup(COLLISION.ITEMS)
phys:SetCollisionMask(
COLLISION.WORLD,
COLLISION.OBSTACLES,
COLLISION.SMALLOBSTACLES,
COLLISION.ITEMS
)
phys:SetCapsule(LOTUS_PHYSICS_RADIUS,LOTUS_PHYSICS_HEIGHT)

return phys
end


local function rippleFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()

inst:AddTag("CLASSIFIED")
inst:AddTag("FX")
inst:AddTag("NOCLICK")

inst.AnimState:SetBank("oceanfishing_hook")
inst.AnimState:SetBuild("oceanfishing_hook")
inst.AnimState:PlayAnimation("fx_ripple_small",true)
inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)

inst.persists=false

return inst
end


local function addRippleFx(inst)
if not TheNet:IsDedicated() then
local ripple=SpawnPrefab(RIPPLE_PREFAB)

if ripple~=nil then
inst:AddChild(ripple)
ripple.Transform:SetPosition(0,LOTUS_RIPPLE_Y_OFFSET,0)
ripple.Transform:SetScale(LOTUS_RIPPLE_SCALE,LOTUS_RIPPLE_SCALE,LOTUS_RIPPLE_SCALE)
inst._aipRipple=ripple
end
end
end

local function lotusFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()

addLotusPhysics(inst)

inst:AddTag("plant")
inst:AddTag("aip_endless_lotus")
inst:AddTag("ignorewalkableplatforms")

inst:AddTag("walkableperipheral")

inst.AnimState:SetBank(BUILD)
inst.AnimState:SetBuild(BUILD)
inst.AnimState:SetFinalOffset(1)
inst.AnimState:SetRayTestOnBB(true)

inst._aipLotusBloomed=net_bool(inst.GUID,"aip_endless_lotus._aipLotusBloomed","aip_endless_lotus_bloomdirty")
inst:ListenForEvent("aip_endless_lotus_bloomdirty",function(inst)
skinner.PlayCurrent(inst)
end)

skinner.SetupNetwork(inst)
inst.scrapbook_anim=LOTUS_BUD_ANIMS[lotusConfig.DEFAULT_SKIN]
inst.RandomLotusSkin=setRandomSkin
inst.RandomAipSkin=setRandomSkin
addRippleFx(inst)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

skinner.SetupMaster(inst)

inst:AddComponent("inspectable")

inst:AddComponent("lootdropper")
inst.components.lootdropper:SetLoot({ LEAF_PREFAB })

inst:AddComponent("timer")
inst:ListenForEvent("timerdone",onTimerDone)
startLotusRootTimer(inst)

inst:AddComponent("pickable")
inst.components.pickable.picksound="dontstarve/wilson/harvest_berries"
inst.components.pickable:SetUp(FLOWER_PREFAB,LOTUS_BLOOM_TIME,1)
inst.components.pickable.onregenfn=onBloomed
inst.components.pickable.onpickedfn=onPicked
inst.components.pickable.makeemptyfn=makeEmpty
inst.components.pickable.makefullfn=onBloomed
inst.components.pickable:MakeEmpty()

inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.DIG)
inst.components.workable:SetWorkLeft(1)
inst.components.workable:SetOnFinishCallback(onDug)

inst.OnSave=onSave
inst.OnLoad=onLoad

MakeHauntableWork(inst)

return inst
end


local function flowerFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank(BUILD)
inst.AnimState:SetBuild(BUILD)
inst.AnimState:PlayAnimation("flower")

MakeInventoryFloatable(inst,"small",0.15,0.85)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_endless_lotus_flower.xml"
inst.components.inventoryitem.imagename=FLOWER_PREFAB

inst:AddComponent("edible")
inst.components.edible.hungervalue=TUNING.CALORIES_SMALL
inst.components.edible.healthvalue=TUNING.HEALING_MEDSMALL
inst.components.edible.sanityvalue=TUNING.SANITY_TINY
inst.components.edible.foodtype=FOODTYPE.VEGGIE

inst:AddComponent("perishable")
inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
inst.components.perishable:StartPerishing()
inst.components.perishable.onperishreplacement="spoiled_food"

inst:AddComponent("stackable")
inst.components.stackable.maxsize=TUNING.STACK_SIZE_SMALLITEM

inst:AddComponent("tradable")

MakeSmallBurnable(inst)
MakeSmallPropagator(inst)

MakeHauntableLaunchAndPerish(inst)

return inst
end


local function leafFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank(BUILD)
inst.AnimState:SetBuild(BUILD)
inst.AnimState:PlayAnimation("leaf")

MakeInventoryFloatable(inst,"med",0.12,{ 1.35,0.95,1.35 })

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_endless_lotus_leaf.xml"
inst.components.inventoryitem.imagename=LEAF_PREFAB

inst:AddComponent("stackable")
inst.components.stackable.maxsize=TUNING.STACK_SIZE_SMALLITEM

inst:AddComponent("fuel")
inst.components.fuel.fuelvalue=TUNING.MED_FUEL

MakeSmallBurnable(inst,TUNING.MED_BURNTIME)
MakeSmallPropagator(inst)

MakeHauntableLaunchAndIgnite(inst)

return inst
end


local function rootFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank(ROOT_PREFAB)
inst.AnimState:SetBuild(ROOT_PREFAB)
inst.AnimState:PlayAnimation("BUILD",false)

MakeInventoryFloatable(inst,"small",0.15,0.85)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_endless_lotus_root.xml"
inst.components.inventoryitem.imagename=ROOT_PREFAB

inst:AddComponent("edible")
inst.components.edible.hungervalue=2
inst.components.edible.healthvalue=0
inst.components.edible.sanityvalue=0
inst.components.edible.foodtype=FOODTYPE.VEGGIE


inst:AddComponent("perishable")
inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
inst.components.perishable:StartPerishing()
inst.components.perishable.onperishreplacement="spoiled_food"

inst:AddComponent("stackable")
inst.components.stackable.maxsize=TUNING.STACK_SIZE_SMALLITEM

inst:AddComponent("tradable")

MakeSmallBurnable(inst)
MakeSmallPropagator(inst)

MakeHauntableLaunch(inst)

return inst
end

local function seedFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank(BUILD)
inst.AnimState:SetBuild(BUILD)
inst.AnimState:PlayAnimation("seed")

inst:AddTag("deployedplant")

inst:AddTag("usedeployspacingasoffset")
inst._custom_candeploy_fn=canDeployLotusSeed

inst.scrapbook_specialinfo="PLANTABLE"
inst.overridedeployplacername=PLACER

MakeInventoryFloatable(inst,"med",0.2,0.75)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_endless_lotus_seed.xml"
inst.components.inventoryitem.imagename="aip_endless_lotus_seed"

inst:AddComponent("stackable")
inst.components.stackable.maxsize=TUNING.STACK_SIZE_SMALLITEM

inst:AddComponent("tradable")
inst.components.tradable.goldvalue=1

inst:AddComponent("deployable")
inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
inst.components.deployable:SetDeploySpacing(LOTUS_DEPLOY_RANGE_SPACING)
inst.components.deployable.ondeploy=onDeploy

MakeHauntableLaunch(inst)

return inst
end

local prefabs={
Prefab(PREFAB,lotusFn,assets,{ "splash",SEED_PREFAB,FLOWER_PREFAB,LEAF_PREFAB,ROOT_PREFAB,RIPPLE_PREFAB }),
Prefab(SEED_PREFAB,seedFn,assets,{ "splash",PREFAB }),
Prefab(FLOWER_PREFAB,flowerFn,assets,{ "spoiled_food" }),
Prefab(LEAF_PREFAB,leafFn,assets),
Prefab(ROOT_PREFAB,rootFn,assets,{ "spoiled_food" }),
Prefab(RIPPLE_PREFAB,rippleFn,rippleAssets),
MakePlacer(PLACER,BUILD,BUILD,LOTUS_BUD_ANIMS[lotusConfig.DEFAULT_SKIN]),
}

for _,skinPrefab in ipairs(skinner.CreatePrefabSkins()) do
table.insert(prefabs,skinPrefab)
end

return unpack(prefabs)
