local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local language=aipGetModConfig("language")


local LANG_MAP={
english={
NAME="Magic Rubik",
DESC="We need reset it!",
DESC_HOT="I need a ice hound",
DESC_COLD="I need an fire hound",
DESC_MIX="Ask a Bumblebee for a match",
},
chinese={
NAME="魔力方阵",
DESC="我们需要重置它！",
DESC_HOT="我需要一只冰猎犬",
DESC_COLD="我需要一只火猎犬",
DESC_MIX="找熊蜂要根火柴吧",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_RUBIK=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_RUBIK=LANG.DESC


local assets={
Asset("ANIM","anim/aip_rubik.zip"),
}

local prefabs={
"aip_rubik_fire_blue",
"aip_rubik_fire_green",
"aip_rubik_fire_red",
}





local function onextinguish(inst)
if inst.components.fueled~=nil then
inst.components.fueled:InitializeFuelLevel(0)
end
inst:RemoveTag("shadow_fire")
inst.components.aipc_rubik:Stop()
end

local function onignite(inst)
inst:AddTag("shadow_fire")
inst.components.aipc_rubik:Start()
end


local function OnFullMoon(inst,isfullmoon)
if not isfullmoon then
return
end


local x,y,z=inst.Transform:GetWorldPosition()
local ents=TheSim:FindEntities(x,y,z,10,{"hound"})
if #ents > 0 then
return
end


local hound=aipSpawnPrefab(inst,"icehound")
hound.persists=false
hound.components.follower:SetLeader(inst)
end

local function syncFireFx(inst)

if inst.components.burnable:IsBurning() then
inst.components.aipc_type_fire:StopFire()
return
end


if inst.components.aipc_type_fire:IsBurning() then
inst.components.burnable:Extinguish()
return
end
end


local function syncFireByHound(inst,data)
if data.inst==nil or not inst:IsNear(data.inst,10) then
return
end


if data.inst.prefab=="firehound" then
inst.components.aipc_type_fire:StartFire("hot",nil,nil,true)
elseif data.inst.prefab=="icehound" then
inst.components.aipc_type_fire:StartFire("cold",nil,nil,true)
end

syncFireFx(inst)
end

local function postTypeFire(inst,fx,type)
fx:RemoveTag("aip_rubik_fire")

if fx.components.firefx then
fx.components.firefx:SetLevel(4)
end

fx:AddTag("aip_rubik_fire")
fx:AddTag("aip_rubik_fire_"..type)
end


local function ontakefuel(inst)
inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
end

local function onupdatefueled(inst)
if inst.components.burnable~=nil then
inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(),inst.components.fueled:GetSectionPercent())
end
end

local function onfuelchange(newsection,oldsection,inst)
if newsection <=0 then
inst.components.burnable:Extinguish()
else
if not inst.components.burnable:IsBurning() then
inst.components.burnable:Ignite()
end

inst.components.burnable:SetFXLevel(newsection,inst.components.fueled:GetSectionPercent())
end

syncFireFx(inst)
end



local function getDesc(inst)
local fireType=inst.components.aipc_type_fire:GetType()

if fireType=="hot" then
return LANG.DESC_HOT
elseif fireType=="cold" then
return LANG.DESC_COLD
elseif fireType=="mix" then
return LANG.DESC_MIX
end

return LANG.DESC
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddNetwork()

MakeObstaclePhysics(inst,.2)

inst.AnimState:SetBank("aip_rubik")
inst.AnimState:SetBuild("aip_rubik")
inst.AnimState:PlayAnimation("idle")

inst:AddTag("wildfireprotected")
inst:AddTag("aip_rubik")
inst:AddTag("aip_can_lighten")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")
inst.components.inspectable.descriptionfn=getDesc

inst:AddComponent("aipc_rubik")


inst:AddComponent("burnable")
inst.components.burnable:AddBurnFX("nightlight_flame",Vector3(0,0,0),"fire_marker")
inst.components.burnable.canlight=false
inst:ListenForEvent("onextinguish",onextinguish)
inst:ListenForEvent("onignite",onignite)


inst:AddComponent("aipc_type_fire")
inst.components.aipc_type_fire.canMix=true
inst.components.aipc_type_fire.hotPrefab="aip_hot_fire"
inst.components.aipc_type_fire.coldPrefab="coldfirefire"
inst.components.aipc_type_fire.mixPrefab="aip_mix_fire"
inst.components.aipc_type_fire.followSymbol="fire_marker"
inst.components.aipc_type_fire.followOffset=Vector3(0,0,0)
inst.components.aipc_type_fire.postFireFn=postTypeFire


inst:AddComponent("fueled")
inst.components.fueled.maxfuel=TUNING.NIGHTLIGHT_FUEL_MAX
inst.components.fueled.accepting=true
inst.components.fueled.fueltype=FUELTYPE.NIGHTMARE
inst.components.fueled:SetSections(4)
inst.components.fueled:SetTakeFuelFn(ontakefuel)
inst.components.fueled:SetUpdateFn(onupdatefueled)
inst.components.fueled:SetSectionCallback(onfuelchange)
inst.components.fueled:InitializeFuelLevel(0)

inst:WatchWorldState("isfullmoon",OnFullMoon)
OnFullMoon(inst,TheWorld.state.isfullmoon)


inst._onEntityDeath=function(src,data)
syncFireByHound(inst,data)
end
inst:ListenForEvent("entity_death",inst._onEntityDeath,TheWorld)

if dev_mode then
inst:DoTaskInTime(1,function()
inst.components.aipc_type_fire:StartFire("mix",nil,5)
end)
end

return inst
end

return Prefab("aip_rubik",fn,assets,prefabs)
