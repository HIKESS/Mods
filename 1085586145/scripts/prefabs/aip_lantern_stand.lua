local language=aipGetModConfig("language")

require "prefabutil"

local skinUtil=require("utils/aip_skin_util")
local standConfig=require("configurations/skin/aip_lantern_stand")

local PREFAB="aip_lantern_stand"
local BUILD="aip_lantern_stand"
local MIRROR_PREFAB="aip_lantern_body"
local SLOT_COUNT=3
local DISPLAY_SYMBOL_PREFIX="swap_lantern_"
local DISPLAY_SCALE=.9
local DISPLAY_FOLLOW_Z_OFFSET=.1
local DISPLAY_FOLLOW_Z_STEP=.25
local TASSLE_SYMBOL="Tassle"
local LIGHT_COLOUR=Vector3(200/255,100/255,100/255)
local LIGHT_RADIUS_BASE=1.05
local LIGHT_RADIUS_STEP=.55
local LIGHT_INTENSITY_BASE=.45
local LIGHT_INTENSITY_STEP=.12
local LIGHT_FALLOFF=.7
local DISPLAY_FUEL_RATE_MULT=.2
local DISPLAY_FUEL_RATE_KEY="aip_lantern_stand"

local LANG_MAP={
english={
NAME="Lantern Stand",
REC_DESC="Hang lanterns where the wind can find them",
DESC="The lanterns sway softly in the breeze.",
},
chinese={
NAME="灯笼架",
REC_DESC="把灯笼挂在风经过的地方",
DESC="灯笼在风里轻轻晃着。",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_LANTERN_STAND=LANG.NAME
STRINGS.RECIPE_DESC.AIP_LANTERN_STAND=LANG.REC_DESC
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_LANTERN_STAND=LANG.DESC
skinUtil.RegisterBuildSkinConfig(standConfig,language,LANG.DESC)

local assets={
Asset("ANIM","anim/aip_lantern_stand.zip"),
}

for _,asset in ipairs(standConfig.GetInventoryAtlasAssets(true)) do
table.insert(assets,asset)
end

local DEFAULT_SKIN=standConfig.DEFAULT_SKIN
local queueRefreshLanternDisplays


local function playSkin(inst,skin,hit)
skin=standConfig.GetSkin(skin)

if hit then
inst.AnimState:PlayAnimation(skin.."_hit")
inst.AnimState:PushAnimation(skin,true)
else
inst.AnimState:PlayAnimation(skin,true)

if TheWorld.ismastersim and queueRefreshLanternDisplays~=nil then
queueRefreshLanternDisplays(inst)
end
end
end

local skinner=skinUtil.CreatePrefabSkinner(standConfig,{
net_field="_aipLanternStandSkin",
current_field="_aipCurrentSkin",
dirty_event="aip_lantern_stand_skindirty",
set_fn_name="SetLanternStandSkin",
next_fn_name="NextLanternStandSkin",
play_fn=playSkin,
})


local function getDisplaySymbol(slot)
return DISPLAY_SYMBOL_PREFIX..slot
end


local function getDisplayZOffset(slot)
return DISPLAY_FOLLOW_Z_OFFSET+(SLOT_COUNT-slot)*DISPLAY_FOLLOW_Z_STEP
end


local function getDisplayFinalOffset(slot)
return SLOT_COUNT-slot+1
end


local function isLanternLit(item)
return item~=nil
and item.components.fueled~=nil
and not item.components.fueled:IsEmpty()
end


local function isStandTurnedOn(inst,override)
if override~=nil then
return override
end

return inst.components.machine~=nil and inst.components.machine:IsOn()
end


local function clearDisplayItemFuelRate(item,stand)
if item~=nil and item.components.fueled~=nil then
item.components.fueled.rate_modifiers:RemoveModifier(stand,DISPLAY_FUEL_RATE_KEY)
end
end


local function setDisplayItemFuelConsuming(item,stand,enabled)
if item~=nil and item.components.fueled~=nil then
local fueled=item.components.fueled

if enabled and not fueled:IsEmpty() then
fueled.rate_modifiers:SetModifier(stand,DISPLAY_FUEL_RATE_MULT,DISPLAY_FUEL_RATE_KEY)
fueled:StartConsuming()
else
clearDisplayItemFuelRate(item,stand)
fueled:StopConsuming()
end
end
end


local function setLightCount(inst,count)
if inst.Light==nil then
return
end

inst.Light:Enable(count > 0)

if count > 0 then
local level=math.min(count,SLOT_COUNT)

inst.Light:SetRadius(LIGHT_RADIUS_BASE+LIGHT_RADIUS_STEP*level)
inst.Light:SetIntensity(LIGHT_INTENSITY_BASE+LIGHT_INTENSITY_STEP*level)
inst.Light:SetFalloff(LIGHT_FALLOFF)
inst.Light:SetColour(LIGHT_COLOUR.x,LIGHT_COLOUR.y,LIGHT_COLOUR.z)
end
end


local function getDisplayRecord(inst,slot)
return inst._aipLanternStandDisplayItems~=nil and
inst._aipLanternStandDisplayItems[slot] or nil
end


local function getDisplayItem(record)
return record~=nil and record.item or nil
end


local function removeDisplayMirror(record)
local mirror=record~=nil and record.mirror or nil

if mirror~=nil and mirror:IsValid() then
mirror:Remove()
end

if record~=nil then
record.mirror=nil
end
end


local function ensureDisplayMirror(record)
if record.mirror==nil or not record.mirror:IsValid() then
record.mirror=SpawnPrefab(MIRROR_PREFAB)
end

return record.mirror
end


local function syncDisplayMirrorSkin(mirror,item,forceAnimationSync)
if item~=nil and mirror.SetLanternSkin~=nil then
local skin=item._aipCurrentSkin or item.skinname


if forceAnimationSync or
not mirror._aipLanternStandSkinInited or
mirror._aipLanternStandSkin~=skin then
mirror._aipLanternStandSkinInited=true
mirror._aipLanternStandSkin=skin
mirror:SetLanternSkin(skin)
end
end
end


local function syncDisplayMirror(inst,record,slot,lit,showTassle,forceAnimationSync)
local mirror=ensureDisplayMirror(record)

if mirror==nil then
return
end

syncDisplayMirrorSkin(mirror,record.item,forceAnimationSync)
mirror.Transform:SetPosition(inst.Transform:GetWorldPosition())
mirror.Transform:SetScale(DISPLAY_SCALE,DISPLAY_SCALE,DISPLAY_SCALE)
mirror.AnimState:SetFinalOffset(getDisplayFinalOffset(slot))

if lit then
mirror.AnimState:Show("LIGHT")
else
mirror.AnimState:Hide("LIGHT")
end

if showTassle then
mirror.AnimState:Show(TASSLE_SYMBOL)
else
mirror.AnimState:Hide(TASSLE_SYMBOL)
end

if mirror.Follower==nil then
mirror.entity:AddFollower()
end
mirror.Follower:FollowSymbol(
inst.GUID,
getDisplaySymbol(slot),
0,
0,
getDisplayZOffset(slot)
)

mirror._aipLanternStand=inst
mirror._aipLanternStandDisplaySlot=slot
record.lit=lit==true
record.showTassle=showTassle==true
end


local function getDisplaySlotForItem(inst,item)
if inst._aipLanternStandDisplayItems==nil then
return nil
end

for slot=1,SLOT_COUNT do
if getDisplayItem(inst._aipLanternStandDisplayItems[slot])==item then
return slot
end
end

return nil
end


local function onDisplayLanternFuelChanged(item)
local stand=item._aipLanternStand

if stand~=nil and stand:IsValid() and queueRefreshLanternDisplays~=nil then
local slot=item._aipLanternStandDisplaySlot
local record=slot~=nil and getDisplayRecord(stand,slot) or nil
local lit=isStandTurnedOn(stand) and isLanternLit(item)


if record==nil or record.lit~=lit then
queueRefreshLanternDisplays(stand)
end
end
end


local function unbindDisplaySlot(inst,slot,leaving)
local record=getDisplayRecord(inst,slot)
local item=getDisplayItem(record)

if record==nil then
return
end

inst._aipLanternStandDisplayItems[slot]=nil
removeDisplayMirror(record)

if item==nil or not item:IsValid() then
return
end

inst:RemoveEventCallback("percentusedchange",onDisplayLanternFuelChanged,item)
if leaving then
clearDisplayItemFuelRate(item,inst)
else
setDisplayItemFuelConsuming(item,inst,false)
end

if item._aipLanternStand==inst then
item._aipLanternStand=nil
item._aipLanternStandDisplaySlot=nil
end
end


local function unbindDisplayItem(inst,item,leaving)
local slot=getDisplaySlotForItem(inst,item)

if slot~=nil then
unbindDisplaySlot(inst,slot,leaving)
end
end


local function bindDisplayItem(inst,item,slot,showTassle,standOn,forceAnimationSync)
if item==nil or not item:IsValid() then
unbindDisplaySlot(inst,slot,false)
return false
end

local oldSlot=getDisplaySlotForItem(inst,item)
if oldSlot~=nil and oldSlot~=slot then
unbindDisplaySlot(inst,oldSlot,false)
end

local oldRecord=getDisplayRecord(inst,slot)
local oldItem=getDisplayItem(oldRecord)
if oldItem~=nil and oldItem~=item then
unbindDisplaySlot(inst,slot,false)
oldRecord=nil
end

local alreadyBound=item._aipLanternStand==inst and oldRecord~=nil
local record=oldRecord or { item=item }
record.item=item
inst._aipLanternStandDisplayItems[slot]=record

local lit=isStandTurnedOn(inst,standOn) and isLanternLit(item)
local displayTassle=showTassle==true


syncDisplayMirror(inst,record,slot,lit,displayTassle,forceAnimationSync)

item._aipLanternStand=inst
item._aipLanternStandDisplaySlot=slot

if not alreadyBound then
inst:RemoveEventCallback("percentusedchange",onDisplayLanternFuelChanged,item)
inst:ListenForEvent("percentusedchange",onDisplayLanternFuelChanged,item)
end

setDisplayItemFuelConsuming(item,inst,lit)

return true,lit
end


local function releaseDisplayItems(inst,leaving)
if inst._aipLanternStandDisplayItems==nil then
return
end

for slot=1,SLOT_COUNT do
unbindDisplaySlot(inst,slot,leaving)
end
end


local function refreshLanternDisplays(inst,standOn,forceAnimationSync)
if inst.components.container==nil then
return
end

local displaySlot=1
local lightCount=0
standOn=isStandTurnedOn(inst,standOn)
local displayItems={}


for slot=1,SLOT_COUNT do
local item=inst.components.container:GetItemInSlot(slot)

if item~=nil then
table.insert(displayItems,item)
end
end

for _,item in ipairs(displayItems) do
local bound,lit=bindDisplayItem(
inst,
item,
displaySlot,
displaySlot==#displayItems,
standOn,
forceAnimationSync
)

if bound and lit then
lightCount=lightCount+1
end

displaySlot=displaySlot+1
end

for slot=displaySlot,SLOT_COUNT do
unbindDisplaySlot(inst,slot,false)
end

setLightCount(inst,lightCount)
end


local function onTurnOn(inst)
refreshLanternDisplays(inst,true)
end


local function onTurnOff(inst)
refreshLanternDisplays(inst,false)
end


queueRefreshLanternDisplays=function(inst,forceAnimationSync)
if forceAnimationSync then
inst._aipLanternStandForceAnimationSync=true
end

if inst._aipLanternStandRefreshTask==nil then

inst._aipLanternStandRefreshTask=inst:DoTaskInTime(0,function(inst)
local shouldSyncAnimation=inst._aipLanternStandForceAnimationSync

inst._aipLanternStandRefreshTask=nil
inst._aipLanternStandForceAnimationSync=nil
refreshLanternDisplays(inst,nil,shouldSyncAnimation)
end)
end
end


local function dropLanterns(inst)
if inst.components.container~=nil then

inst.components.container:DropEverything()
end

setLightCount(inst,0)
end


local function onhammered(inst)
dropLanterns(inst)

inst.components.lootdropper:DropLoot()

local fx=SpawnPrefab("collapse_small")
fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
fx:SetMaterial("wood")

inst:Remove()
end


local function onhit(inst)
dropLanterns(inst)
skinner.PlayCurrent(inst,true)
end


local function onbuilt(inst)
skinner.PlayCurrent(inst)

if inst.SoundEmitter~=nil then
inst.SoundEmitter:PlaySound("dontstarve/common/place_structure_wood")
end
end


local function onload(inst,data)
skinner.OnLoad(inst,data)
queueRefreshLanternDisplays(inst)
end


local function onloadpostpass(inst)
queueRefreshLanternDisplays(inst)
end


local function onitemget(inst)
queueRefreshLanternDisplays(inst,true)
end


local function onitemlose(inst,data)
if data~=nil and data.prev_item~=nil then
unbindDisplayItem(inst,data.prev_item,true)
end

queueRefreshLanternDisplays(inst,true)
end


local function onremoveentity(inst)
releaseDisplayItems(inst,false)
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddLight()
inst.entity:AddNetwork()

inst:AddTag("structure")
inst:AddTag("chest")
inst:AddTag("aip_lantern_stand")

MakeObstaclePhysics(inst,.2)

inst.AnimState:SetBank(BUILD)
inst.AnimState:SetBuild(BUILD)

inst.Light:EnableClientModulation(true)
setLightCount(inst,0)
skinner.SetupNetwork(inst)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

skinner.SetupMaster(inst)
inst._aipLanternStandDisplayItems={}

inst:AddComponent("inspectable")

inst:AddComponent("container")
inst.components.container:WidgetSetup(PREFAB)

inst:AddComponent("machine")
inst.components.machine.turnonfn=onTurnOn
inst.components.machine.turnofffn=onTurnOff
inst.components.machine.cooldowntime=0
inst.components.machine:TurnOn()

inst:AddComponent("lootdropper")
inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
inst.components.workable:SetWorkLeft(2)
inst.components.workable:SetOnFinishCallback(onhammered)
inst.components.workable:SetOnWorkCallback(onhit)

inst.OnSave=skinner.OnSave
inst.OnLoad=onload
inst.OnLoadPostPass=onloadpostpass
inst.OnRemoveEntity=onremoveentity

inst:ListenForEvent("onbuilt",onbuilt)
inst:ListenForEvent("itemget",onitemget)
inst:ListenForEvent("itemlose",onitemlose)

MakeHauntableWork(inst)

return inst
end

local prefabs={
Prefab(PREFAB,fn,assets,{ "collapse_small",MIRROR_PREFAB }),
MakePlacer("aip_lantern_stand_placer",BUILD,BUILD,DEFAULT_SKIN),
}

for _,skinPrefab in ipairs(skinner.CreatePrefabSkins()) do
table.insert(prefabs,skinPrefab)
end

return unpack(prefabs)
