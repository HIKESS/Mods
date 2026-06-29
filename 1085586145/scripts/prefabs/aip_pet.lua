local language=aipGetModConfig("language")

local brain=require("brains/aip_pet_brain")
local petConfig=require("configurations/aip_pet")
local petPrefabs=require("configurations/aip_pet_prefabs")


local LANG_MAP={
english={
REMOVE="It's gone!",
},
chinese={
REMOVE="它被气走了！",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_PET_REMOVE=LANG.REMOVE



local function syncPetInfo(inst)
if inst.components.aipc_petable and inst.components.aipc_info_client then
local quality=inst.components.aipc_petable:GetQuality()
inst.components.aipc_info_client:SetString("aip_info",petConfig.QUALITY_LANG[quality])
inst.components.aipc_info_client:SetByteArray("aip_info_color",petConfig.QUALITY_COLORS[quality])
end
end


local function onSelect(inst,viewer)
if
viewer~=nil and inst~=nil and
inst.components.aipc_petable~=nil and
inst.components.aipc_petable.owner~=nil and
viewer.components.aipc_pet_owner~=nil
then

local petInfo=inst.components.aipc_petable:GetInfo()
local msgData={
current=1,
petInfos={ petInfo },
}



if inst.components.aipc_petable.owner==viewer then
msgData.owner=true
msgData.petInfos=viewer.components.aipc_pet_owner:GetInfos()
msgData.current=aipTableIndex(msgData.petInfos,function(v)
return v.id==petInfo.id
end)
aipPrint("Current pet index: "..msgData.current)
end


local dataStr=json.encode(msgData)
viewer.player_classified.aip_pet_info:set(tostring(os.time()).."|"..dataStr)
end
end

local function OnNamedByWriteable(inst,new_name,writer)
if inst.components.named~=nil then
inst.components.named:SetName(new_name,writer~=nil and writer.userid or nil)
end
end


local function ShouldAcceptItem(inst,item)
return item and (item.components.edible~=nil or item:HasTag("aip_pet_fudge"))
end


local function OnGetItemFromPlayer(inst,giver,item)
if ShouldAcceptItem(inst,item) then

aipRemove(item)

if giver and giver.components.aipc_pet_owner then
local petId=inst.components.aipc_petable:GetInfo().id


if item.prefab=="durian_sugar" then
local ret=giver.components.aipc_pet_owner:RemovePet(petId)

if ret and giver.components.talker then
giver.components.talker:Say(
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_PET_REMOVE
)
end


else
local aipc_pet_owner=aipGet(inst,"components|aipc_petable|owner|components|aipc_pet_owner")
aipc_pet_owner:UpgradePet(petId,item)
end
end
end
end


local function createPet(name,info)
local upperCase=string.upper(name)
local upperOrigin=string.upper(info.origin)

STRINGS.NAMES[upperCase]=STRINGS.NAMES[upperOrigin]
STRINGS.CHARACTERS.GENERIC.DESCRIBE[upperCase]=STRINGS.CHARACTERS.GENERIC.DESCRIBE[upperOrigin]

local scale=info.scale or 0.75

local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
if not info.noShadow then
inst.entity:AddDynamicShadow()
end
inst.entity:AddNetwork()

MakeFlyingCharacterPhysics(inst,1,.5)

if not info.noShadow then
inst.DynamicShadow:SetSize(1,.75)
end

if info.face==2 then
inst.Transform:SetTwoFaced()
elseif info.face==6 then
inst.Transform:SetSixFaced()
else
inst.Transform:SetFourFaced()
end

if info.bb then
inst.AnimState:SetRayTestOnBB(true)
end

inst.Transform:SetScale(scale,scale,scale)

inst.AnimState:SetBank(info.bank)
inst.AnimState:SetBuild(info.build)
inst.AnimState:PlayAnimation(info.anim)

inst:AddComponent("aipc_petable")

inst:AddComponent("aipc_info_client")
inst.components.aipc_info_client:SetString("aip_info","")
inst.components.aipc_info_client:SetByteArray("aip_info_color",{})

inst:AddTag("_named")
inst:AddTag("NOBLOCK")


if info.tags~=nil then
for _,tag in ipairs(info.tags) do
inst:AddTag(tag)
end
end

if info.preInit~=nil then
info.preInit(inst)
end

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:RemoveTag("_named")


inst:AddComponent("named")
inst:AddComponent("inspectable")
inst.components.inspectable.descriptionfn=onSelect




inst.sounds=info.sounds


inst:AddComponent("health")
inst.components.health:SetMaxHealth(1)
inst.components.health:SetInvincible(true)

inst:AddComponent("locomotor")
inst.components.locomotor.runspeed=TUNING.WILSON_RUN_SPEED
inst.components.locomotor.walkspeed=TUNING.WILSON_WALK_SPEED


inst.components.locomotor.pathcaps={ ignorecreep=true,allowocean=true }


inst:AddComponent("trader")
inst.components.trader:SetAcceptTest(ShouldAcceptItem)
inst.components.trader.onaccept=OnGetItemFromPlayer
inst.components.trader.deleteitemonaccept=false

if info.postInit~=nil then
info.postInit(inst)
end

inst:SetStateGraph(info.sg)
inst:SetBrain(brain)

inst.persists=false

inst:DoTaskInTime(.1,syncPetInfo)

return inst
end

return fn
end



local prefabs={}

for name,info in pairs(petPrefabs.PREFABS) do
local prefabName="aip_pet_"..name
local prefab=Prefab(prefabName,createPet(prefabName,info),{})
table.insert(prefabs,prefab)
end

return unpack(prefabs)
