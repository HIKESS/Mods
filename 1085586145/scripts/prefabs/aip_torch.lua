
local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local additional_weapon=aipGetModConfig("additional_weapon")
if additional_weapon~="open" then
return nil
end

local weapon_uses=aipGetModConfig("weapon_uses")
local weapon_damage=aipGetModConfig("weapon_damage")
local language=aipGetModConfig("language")


local DAMAGE_MAP={
less=TUNING.NIGHTSWORD_DAMAGE/68*100,
normal=TUNING.NIGHTSWORD_DAMAGE/68*500,
large=TUNING.NIGHTSWORD_DAMAGE/68*1000,
}

local FIRE_TIME=dev_mode and 60 or TUNING.CAMPFIRE_FUEL_MAX

local LANG_MAP={
english={
NAME="Radish Match",
NAME_MIX="Radish Match (DEBUG)",
REC_DESC="Take away the flame of the bonfire",
DESC="Take away the flame of the bonfire",

NAME_BUILDING="Standing Radish Match",
DESC_BUILDING="Can be temporarily used for ignition",
},
chinese={
NAME="大根火柴",
NAME_MIX="大根火柴(调试)",
REC_DESC="可以带走篝火的火焰",
DESC="带走篝火的火焰",

NAME_BUILDING="矗立的大根火柴",
DESC_BUILDING="可以临时用于引火",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

TUNING.AIP_TORCH_DAMAGE=DAMAGE_MAP[weapon_damage]


local assets={
Asset("ATLAS","images/inventoryimages/aip_torch.xml"),
Asset("ANIM","anim/aip_torch.zip"),
Asset("ANIM","anim/aip_torch_swap.zip"),
}


STRINGS.NAMES.AIP_TORCH=LANG.NAME
STRINGS.NAMES.AIP_TORCH_MIXED=LANG.NAME_MIX
STRINGS.RECIPE_DESC.AIP_TORCH=LANG.REC_DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_TORCH=LANG.DESC

STRINGS.NAMES.AIP_TORCH_BUILDING=LANG.NAME_BUILDING
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_TORCH_BUILDING=LANG.DESC_BUILDING



local function getFire(owner)
local x,y,z=owner.Transform:GetWorldPosition()


local rubikFireEnts=TheSim:FindEntities(x,y,z,5,{ "aip_rubik_fire" })
rubikFireEnts=aipFilterTable(rubikFireEnts,function(ent)

local nearDist=ent:HasTag("aip_rubik_fire_small") and 1.5 or 2.5
local near=ent:IsNear(owner,nearDist)
return near
end)


if #rubikFireEnts > 0 then
local hotPrefab=nil
local coldPrefab=nil
local mixPrefab=nil

for _,ent in pairs(rubikFireEnts) do
if ent:HasTag("aip_rubik_fire_hot") then
hotPrefab=ent
elseif ent:HasTag("aip_rubik_fire_cold") then
coldPrefab=ent
elseif ent:HasTag("aip_rubik_fire_mix") then
mixPrefab=ent
end
end

if mixPrefab then
return "mix"
end

if hotPrefab then
return "hot"
end

if coldPrefab then
return "cold"
end
end

local ents=TheSim:FindEntities(x,y,z,2,{ "fire" })


for _,ent in pairs(ents) do
if
ent.components.burnable and
ent.components.burnable:IsBurning() and
ent.components.burnable.fxchildren
then
for _,fx in pairs(ent.components.burnable.fxchildren) do
if fx and fx:IsValid() and fx.components.heater then
return fx
end
end
end
end
end

local function syncFire(inst,owner)

local fireFX=getFire(owner)


if inst.components.aipc_type_fire:IsBurning() then
return


elseif fireFX=="mix" or fireFX=="hot" or fireFX=="cold" then
inst.components.aipc_type_fire:StartFire(fireFX,owner)


elseif fireFX and inst.components.aipc_type_fire:GetType()~="mix" then
local heat=fireFX.components.heater:GetHeat(owner)

inst.components.aipc_type_fire:StartFire(heat > 0 and "hot" or "cold",owner)
end
end

local function onToggleFire(inst,fireType)
if inst.components.aipc_lighter then
inst.components.aipc_lighter:Enabled(fireType)
end
end



local function checkFireExtinguish(inst,owner)
local post=owner:GetPosition()

if inst._aipLastPos then
local dist=inst._aipLastPos:Dist(post)
if dist > 8 then
inst.components.aipc_type_fire:StopFire()
end
end

inst._aipLastPos=post
end


local function onequip(inst,owner)
owner.AnimState:OverrideSymbol("swap_object","aip_torch_swap","aip_torch_swap")
owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
owner.AnimState:Show("ARM_carry")
owner.AnimState:Hide("ARM_normal")

if owner.components.aipc_timer then
owner.components.aipc_timer:NamedInterval("syncFire",0.8,function()
syncFire(inst,owner)
checkFireExtinguish(inst,owner)
end)
end


inst.components.aipc_type_fire:StopFire()
inst.aipLastFireType=nil
end

local function onunequip(inst,owner)
owner.AnimState:ClearOverrideSymbol("swap_object")
owner.AnimState:Hide("ARM_carry")
owner.AnimState:Show("ARM_normal")

if owner.components.aipc_timer then
owner.components.aipc_timer:KillName("syncFire")
end

inst.aipLastFireType=inst.components.aipc_type_fire:GetType()
inst.components.aipc_type_fire:StopFire()

inst:DoTaskInTime(.5,function()
inst.aipLastFireType=nil
end)
end

local function ondeploy(inst,pt)
local building=aipSpawnPrefab(inst,"aip_torch_building",pt)
building.components.aipc_type_fire:StartFire(
inst.aipLastFireType
)
aipRemove(inst)
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeInventoryPhysics(inst)

inst.AnimState:SetBank("aip_torch")
inst.AnimState:SetBuild("aip_torch")
inst.AnimState:PlayAnimation("idle")

MakeInventoryFloatable(inst,"small",0.15,0.9)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("aipc_lighter")

inst:AddComponent("finiteuses")
inst.components.finiteuses:SetMaxUses(1)
inst.components.finiteuses:SetUses(1)
inst.components.finiteuses:SetOnFinished(inst.Remove)

inst:AddComponent("weapon")
inst.components.weapon:SetDamage(TUNING.AIP_TORCH_DAMAGE)

inst:AddComponent("inspectable")

inst:AddComponent("aipc_timer")


inst:AddComponent("aipc_type_fire")
inst.components.aipc_type_fire.hotPrefab="aip_hot_torchfire"
inst.components.aipc_type_fire.coldPrefab="aip_cold_torchfire"
inst.components.aipc_type_fire.mixPrefab="aip_mix_torchfire"
inst.components.aipc_type_fire.followSymbol="swap_object"
inst.components.aipc_type_fire.followOffset=Vector3(0,-140,0)
inst.components.aipc_type_fire.onToggle=onToggleFire

inst:AddComponent("inventoryitem")
inst.components.inventoryitem.atlasname="images/inventoryimages/aip_torch.xml"

MakeHauntable(inst)

inst:AddComponent("equippable")
inst.components.equippable:SetOnEquip(onequip)
inst.components.equippable:SetOnUnequip(onunequip)


inst:AddComponent("deployable")
inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
inst.components.deployable.ondeploy=ondeploy

inst._aipFirePrefab=nil
inst._aipFireFX=nil
inst._aipLastPos=nil

return inst
end


local function mixFn()
local inst=fn()

if not TheWorld.ismastersim then
return inst
end

inst.components.inventoryitem.atlasname="images/inventoryimages/aip_torch.xml"
inst.components.inventoryitem.imagename="aip_torch"

inst.components.equippable:SetOnEquip(function(inst,owner)
onequip(inst,owner)

inst:DoTaskInTime(0.5,function()
inst.components.aipc_type_fire:StartFire("mix",owner)
end)
end)

return inst
end


local function syncPickable(inst)
inst.components.pickable.canbepicked=not inst.components.aipc_type_fire:IsBurning()
end

local function onToggleBuildFire(inst,fireType)
if fireType then
inst.components.fueled:StartConsuming()
end

syncPickable(inst)
end

local function onfuelchange(newsection,oldsection,inst)
if newsection <=0 then
aipRemove(inst)
else
inst.AnimState:PlayAnimation("stand"..newsection)
end
end


local function postTypeFire(inst,fx,type)
fx:AddTag("aip_rubik_fire")
fx:AddTag("aip_rubik_fire_"..type)
fx:AddTag("aip_rubik_fire_small")
end


local function buildFn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

inst.AnimState:SetBank("aip_torch")
inst.AnimState:SetBuild("aip_torch")
inst.AnimState:PlayAnimation("stand4")
inst.AnimState:SetRayTestOnBB(true)

inst:AddTag("aip_can_lighten")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")


inst:AddComponent("aipc_type_fire")
inst.components.aipc_type_fire.hotPrefab="aip_hot_torchfire"
inst.components.aipc_type_fire.coldPrefab="aip_cold_torchfire"
inst.components.aipc_type_fire.mixPrefab="aip_mix_torchfire"
inst.components.aipc_type_fire.followSymbol="firefx"
inst.components.aipc_type_fire.followOffset=Vector3(0,0,0)
inst.components.aipc_type_fire.forever=true
inst.components.aipc_type_fire.postFireFn=postTypeFire
inst.components.aipc_type_fire.onToggle=onToggleBuildFire


inst:AddComponent("fueled")
inst.components.fueled.maxfuel=FIRE_TIME
inst.components.fueled.accepting=false
inst.components.fueled:SetSections(4)
inst.components.fueled:InitializeFuelLevel(FIRE_TIME)
inst.components.fueled:SetSectionCallback(onfuelchange)


inst:AddComponent("pickable")
inst.components.pickable:SetUp("aip_torch",10)
inst.components.pickable.remove_when_picked=true
inst.components.pickable.quickpick=true
inst.components.pickable.canbepicked=false

inst:DoTaskInTime(0.1,function()
syncPickable(inst)
end)

return inst
end

return Prefab("aip_torch",fn,assets),
Prefab("aip_torch_mixed",mixFn,assets),
Prefab("aip_torch_building",buildFn,assets),
MakePlacer("aip_torch_placer","aip_torch","aip_torch","stand4")
