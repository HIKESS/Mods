local RECHARGE_USES=10

local language=aipGetModConfig("language")

local assets={
Asset("ANIM","anim/aip_nightmare_package.zip"),
Asset("ATLAS","images/inventoryimages/aip_nightmare_package.xml"),
}


local LANG_MAP={
english={
NAME="Nightmare Soul",
DESC="Looks 'non-toxic'",
},
chinese={
NAME="噩梦之灵",
DESC="看起来是“无毒的”",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_NIGHTMARE_PACKAGE=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_NIGHTMARE_PACKAGE=LANG.DESC


local function onEaten(inst,eater)
if eater~=nil then

if eater.components.sanity~=nil then
local sanity=eater.components.sanity.current
local cnt=math.ceil(sanity/15)

for i=1,cnt do
inst.components.lootdropper:SpawnLootPrefab("nightmarefuel")
end

eater.components.sanity:DoDelta(-sanity)
end


if
eater.components.aipc_player_show~=nil and
eater.components.grue~=nil and
eater.components.grue:CheckForStart()
then
eater.components.aipc_player_show:CreateOldoneHand()
end
end
end

local function recharge(inst)
if inst.components.finiteuses~=nil then
inst.components.finiteuses:Use(-1)


if inst.components.finiteuses:GetPercent() > 1 then
inst.components.finiteuses:SetPercent(1)
end
end
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank("aip_nightmare_package")
inst.AnimState:SetBuild("aip_nightmare_package")
inst.AnimState:PlayAnimation("idle",true)
inst.AnimState:SetMultColour(1,1,1,0.5)
inst.AnimState:UsePointFiltering(true)

MakeInventoryFloatable(inst)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")


inst:AddComponent("fuel")
inst.components.fuel.fueltype=FUELTYPE.NIGHTMARE
inst.components.fuel.fuelvalue=TUNING.LARGE_FUEL*10


inst:AddComponent("finiteuses")
inst.components.finiteuses:SetMaxUses(RECHARGE_USES)
inst.components.finiteuses:SetUses(RECHARGE_USES)
inst.components.finiteuses:SetOnFinished(inst.Remove)


inst:AddComponent("sanityaura")
inst.components.sanityaura.aura=-TUNING.SANITYAURA_SMALL
inst.components.sanityaura.max_distsq=0.1


inst:AddComponent("edible")
inst.components.edible.hungervalue=0
inst.components.edible.healthvalue=0
inst.components.edible.foodtype=FOODTYPE.GOODIES
inst.components.edible:SetOnEatenFn(onEaten)


inst:AddComponent("lootdropper")

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_nightmare_package.xml"

MakeHauntableLaunch(inst)

inst:WatchWorldState("isnight",recharge)

return inst
end

return Prefab("aip_nightmare_package",fn,assets)