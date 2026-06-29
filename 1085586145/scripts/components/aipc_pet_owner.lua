local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local petConfig=require("configurations/aip_pet")
local petPrefabs=require("configurations/aip_pet_prefabs")

local language=aipGetModConfig("language")

local MAX_PET_COUNT=5
local MAX_UP_QUALITY_VALUE=dev_mode and 5 or 3


local LANG_MAP={
english={
PLAY_BUFF_NAME="play",
MUDDY_BUFF_NAME="muddy",
FULL_FUDGE="It ate too much fudge",
NO_FUDGE="No skill need raise quality",
},
chinese={
PLAY_BUFF_NAME="嬉闹",
MUDDY_BUFF_NAME="泥泞",
FULL_FUDGE="它吃了太多软糖",
NO_FUDGE="它没有要提升品质的技能",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_PET_FULL_FUDGE=LANG.FULL_FUDGE
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_PET_NO_FUDGE=LANG.NO_FUDGE



aipBufferRegister("aip_pet_play",{
name=LANG.PLAY_BUFF_NAME,

startFn=function(source,inst,info)
if source~=nil and source.components.aipc_pet_owner~=nil then
local skillInfo,skillLv=source.components.aipc_pet_owner:GetSkillInfo("play")
if skillInfo~=nil then
local desc=skillInfo.weak*skillLv
info.data.desc=math.min(1,math.max(info.data.desc or 0,desc))
end
end
end,

showFX=true,
})


aipBufferRegister("aip_pet_muddy",{
name=LANG.MUDDY_BUFF_NAME,

startFn=function(source,inst,info)
if
source~=nil and source.components.aipc_pet_owner~=nil and
inst~=nil and inst.components.locomotor~=nil
then
local skillInfo,skillLv=source.components.aipc_pet_owner:GetSkillInfo("muddy")
if skillInfo~=nil then
local slowPTG=math.max(0.1,1-skillInfo.multi*skillLv)

inst.components.locomotor:SetExternalSpeedMultiplier(
inst,"aipc_pet_muddy_speed",slowPTG
)
end
end
end,

endFn=function(source,inst)
if
inst~=nil and inst.components.locomotor~=nil
then
inst.components.locomotor:RemoveExternalSpeedMultiplier(
inst,"aipc_pet_muddy_speed"
)
end
end,

showFX=true,
})


local function OnAttack(inst,data)
if inst~=nil and inst.components.aipc_pet_owner~=nil and data~=nil and data.target~=nil then
inst.components.aipc_pet_owner:Attack(data.target)
end
end

local function OnAttacked(inst,data)
if inst~=nil and inst.components.aipc_pet_owner~=nil then
inst.components.aipc_pet_owner:Attacked(data)
end
end

local function StopSpeed(inst)
if inst.components.locomotor then
inst.components.locomotor:RemoveExternalSpeedMultiplier(
inst,"aipc_pet_owner_speed"
)
end
end

local function OnTimerDone(inst,data)
data=data or {}

if not inst.components.aipc_pet_owner then
return
end


local pet=inst.components.aipc_pet_owner.showPet


if data.name=="aipc_pet_owner_distance" and pet then
inst.components.aipc_pet_owner:StartDistanceCheck()
end


if data.name=="aipc_pet_owner_speed" then
StopSpeed(inst)
end


if data.name=="aipc_pet_owner_shedding" and pet then

local lootTbl=petPrefabs.SHEDDING_LOOT[pet._aipPetPrefab]

lootTbl=aipCloneTable(lootTbl or {})
lootTbl.seeds=0.5
lootTbl.ash=0.5

local lootPrefab=aipRandomLoot(lootTbl)
aipFlingItem(aipSpawnPrefab(pet,lootPrefab))
inst.components.aipc_pet_owner:StartShedding()
end


if data.name=="aipc_pet_owner_cure" and pet then
inst.components.aipc_pet_owner:StartCure(true)
end


if data.name=="aipc_pet_owner_blasphemy" and pet then
inst.components.aipc_pet_owner:StartBlasphemy(true)
end


if data.name=="aipc_pet_owner_drink" and pet then
inst.components.aipc_pet_owner:StartDrink(true)
end
end


local function OnStartCooking(inst,data)
local cookpot=aipGet(data,"cookpot")
inst._aipLastCookpot=cookpot


local skillInfo,skillLv=inst.components.aipc_pet_owner:GetSkillInfo("cooker")
if skillInfo~=nil and cookpot~=nil and cookpot.components.stewer~=nil then
local multi=math.max(0,1-skillInfo.multi*skillLv)


local oriCooktimemult=cookpot.components.stewer.cooktimemult
cookpot.components.stewer.cooktimemult=multi


cookpot:DoTaskInTime(0,function()
cookpot.components.stewer.cooktimemult=oriCooktimemult
end)
end
end


local function OnPhase(inst,phase)
if not inst.components.aipc_pet_owner then
return
end

local pet=inst.components.aipc_pet_owner.showPet


if phase~="day" then
if inst then
for _,petData in ipairs(inst.components.aipc_pet_owner.pets) do
petData.upgradeEffect=1


if petData.skills.d4c~=nil then
petData.skills.d4c.done=nil
end
end
end
end


if phase=="dusk" then
local skillInfo,skillLv=inst.components.aipc_pet_owner:GetSkillInfo("dig")

if skillInfo~=nil and inst._aipLastCookpot~=nil and inst._aipLastCookpot:IsValid() then
local src=aipSpawnPrefab(pet,"wormhole_limited_1")
local tgt=aipSpawnPrefab(inst._aipLastCookpot,"wormhole_limited_1")
src.persists=false
tgt.persists=false

src.components.teleporter:Target(tgt)
tgt.components.teleporter:Target(src)

aipSpawnPrefab(src,"aip_shadow_wrapper").DoShow()


tgt.AnimState:OverrideMultColour(0,0,0,0)
tgt.Transform:SetScale(0.1,0.1,0.1)


local rmTime=skillInfo.duration+skillInfo.durationUnit*skillLv
src:DoTaskInTime(rmTime,function(inst)
if src:IsAsleep() then
src:Remove()
else
src.sg:GoToState("death")
end
end)
tgt:DoTaskInTime(rmTime,tgt.Remove)
end
end
end


local function OnWormholeTravel(inst)
if inst and inst.components.aipc_pet_owner then
local skillInfo,skillLv,skill=inst.components.aipc_pet_owner:GetSkillInfo("d4c")

if skillInfo~=nil and skill.done==nil and inst.components.health~=nil then
inst.components.health:SetPercent(1)
skill.done=true


local fx=SpawnPrefab("shadow_shield2")
fx.entity:SetParent(inst.entity)
end
end
end


local function OnPick(inst,data)
data=data or {}

if not inst.components.aipc_pet_owner then
return
end


local skillInfo,skillLv=inst.components.aipc_pet_owner:GetSkillInfo("ge")


local loot=data.loot or {}
loot=loot[1] or loot
loot=loot[1] or loot

if skillInfo~=nil and data.object~=nil and loot~=nil then

local seedName=loot.prefab.."_seeds"
if not PrefabExists(seedName) then
return
end

local chance=skillInfo.ptg*skillLv
local pt=data.object:GetPosition()

if math.random() < chance then
inst:DoTaskInTime(0.1,function()
local ents=TheSim:FindEntities(pt.x,0,pt.z,0.1)
local farm_soil=aipFilterTable(ents,function(ent)
return ent.prefab=="farm_soil"
end)[1]

if farm_soil~=nil then
local soil=aipReplacePrefab(farm_soil,"farm_soil")
local seed=SpawnPrefab(seedName)
seed.components.farmplantable:Plant(soil,inst)
end
end)
end
end
end


local function OnMissAttack(inst)
if inst.components.aipc_pet_owner==nil then
return
end


local skillInfo,skillLv,skill=inst.components.aipc_pet_owner:GetSkillInfo("migao")

if skillInfo~=nil then

aipSpawnPrefab(inst,"farm_plant_happy")


skill._multi=math.min(
(skill._multi or 0)+1,
skillLv
)
end
end


local function OnBurnt(inst)
if inst.components.aipc_pet_owner==nil then
return
end
end



local PetOwner=Class(function(self,inst)
self.inst=inst
self.pets={}

self.showPet=nil
self.petData=nil

self.inst:ListenForEvent("onhitother",OnAttack)
self.inst:ListenForEvent("attacked",OnAttacked)
self.inst:ListenForEvent("timerdone",OnTimerDone)
self.inst:ListenForEvent("wormholespit",OnWormholeTravel)
self.inst:ListenForEvent("aipStartCooking",OnStartCooking)
self.inst:ListenForEvent("picksomething",OnPick)
self.inst:ListenForEvent("aipMissAttack",OnMissAttack)
self.inst:ListenForEvent("burnt",OnBurnt)

self.inst:WatchWorldState("phase",OnPhase)
end)


function PetOwner:FillInfo()
self.pets=self.pets or {}

for i,petData in ipairs(self.pets) do
petData.id=petData.id or (os.time()+i)


petData.upgradeEffect=petData.upgradeEffect or 1


petData.skills=petData.skills or {}
for skillName,skillData in pairs(petData.skills) do
skillData.lv=skillData.lv or 1
skillData.quality=math.max(1,skillData.quality or 1)
end
end
end


function PetOwner:TogglePet(petId,showEffect)
self:FillInfo()

if
self.showPet~=nil and
self.showPet.components.aipc_petable:GetInfo().id==petId
then
return
else

local index=aipTableIndex(self.pets,function(v)
return v.id==petId
end)

if index~=nil then
return self:ShowPet(index,showEffect)
end
end
end

function PetOwner:Count()
return #self.pets
end

function PetOwner:AddPetByInfo(data)
table.insert(self.pets,data)

return self:ShowPet(#self.pets)
end


function PetOwner:AddPet(pet,qualityOffset)
if self:IsFull() then
return
end

if pet and pet.components.aipc_petable~=nil then
if qualityOffset and qualityOffset~=0 then
pet.components.aipc_petable:DeltaQuality(qualityOffset)
end

local data=pet.components.aipc_petable:GetInfo(self.inst)

return self:AddPetByInfo(data)
end
end


function PetOwner:RemovePet(id)

if self.showPet~=nil and self.showPet.components.aipc_petable:GetInfo().id==id then
self:HidePet()
end


local originLen=#self.pets
self.pets=aipFilterTable(self.pets,function(v)
return v.id~=id
end)

return originLen~=#self.pets
end


function PetOwner:HidePet(showEffect)
if self.showPet~=nil then
if showEffect==false then
aipRemove(self.showPet)
else
aipReplacePrefab(self.showPet,"aip_shadow_wrapper").DoShow()
end
self.showPet=nil
end

self.petData=nil
self:EnsureTimer()


self.inst.components.timer:StopTimer("aipc_pet_owner_distance")


StopSpeed(self.inst)


self.inst.components.timer:StopTimer("aipc_pet_owner_shedding")


self.inst.components.timer:StopTimer("aipc_pet_owner_cure")


self.inst.components.timer:StopTimer("aipc_pet_owner_drink")


self:StopJohnWick()


if self.inst.components.aipc_grave_cloak~=nil then
self.inst.components.aipc_grave_cloak:Stop()
end
end


function PetOwner:ShowPet(index,showEffect)
self:FillInfo()

self:HidePet()

local petData=self.pets[index or 1]
self.petData=petData

if petData~=nil then
local fullname=petData.prefab..(petData.subPrefab or "")
local petPrefab="aip_pet_"..fullname
local pet=aipSpawnPrefab(self.inst,petPrefab)
pet._aipPetPrefab=fullname
pet.components.aipc_petable:SetInfo(petData,self.inst)

if showEffect~=false then
aipSpawnPrefab(pet,"aip_shadow_wrapper").DoShow()
end
self.showPet=pet


self:StartDistanceCheck()


self:StartShedding()


self:StartAura()


self:StartHeater()


self:StartCure()


self:StartDrink()


self:StartJohnWick()


self:StartGraveCloak()


self:StartBlasphemy()


self:StartBubble()

return pet
end
end


function PetOwner:GetSkillInfo(skillName)
local skill=aipGet(self.petData,"skills|"..skillName)

if skill~=nil then
local skillLv=skill.lv
return petConfig.SKILL_CONSTANT[skillName] or {},skillLv,skill
end

return nil
end


function PetOwner:RefreshPet(id)
if self.showPet and self.showPet.components.aipc_petable:GetInfo().id==id then
local pt=self.showPet:GetPosition()
self:HidePet(false)
local nextPet=self:TogglePet(id,false)

if nextPet then
nextPet.Transform:SetPosition(pt:Get())
aipSpawnPrefab(nextPet,"farm_plant_happy")
end
end
end


function PetOwner:UpgradePet(id,inst)
local petData=aipFilterTable(self.pets,function(v)
return v.id==id
end)[1]

if petData~=nil then

if inst.prefab=="aip_pet_fudge_bug" then
local MAX_QUALITY=5

petData.quality=MAX_QUALITY

for skillName,skillData in pairs(petData.skills) do
skillData.quality=MAX_QUALITY
end


petData.skills.blasphemy={
lv=1,
quality=MAX_QUALITY,
}

self:RefreshPet(id)
return
end

if inst:HasTag("aip_pet_fudge") then

local quality=petData.quality
petData.upgradeQuality=petData.upgradeQuality or 0

local isFish=inst.prefab=="aip_pet_fudge_fish"
local qualityValue=isFish and 3 or 1

if petData.upgradeQuality+qualityValue <=MAX_UP_QUALITY_VALUE then
petData.upgradeQuality=petData.upgradeQuality+qualityValue


local canUpgradeSkillNames={}
local lowestSkillQuality=999
local lowestSkillName=nil

for skillName,skillData in pairs(petData.skills) do
local skillQuality=skillData.quality

if skillQuality < quality then
table.insert(canUpgradeSkillNames,skillName)

if skillQuality < lowestSkillQuality then
lowestSkillQuality=skillQuality
lowestSkillName=skillName
end
end
end

local upgradeSkillName=aipRandomEnt(canUpgradeSkillNames)

if not isFish then

for skillName,skillData in pairs(petData.skills) do
if skillName==upgradeSkillName then
skillData.quality=skillData.quality+1
break
end
end
elseif lowestSkillName~=nil then

petData.skills[lowestSkillName].quality=math.min(
petData.skills[lowestSkillName].quality+2,
quality
)
end


if not upgradeSkillName and not lowestSkillName then
aipFlingItem(aipSpawnPrefab(self.showPet,inst.prefab))

if self.inst.components.talker~=nil then
self.inst.components.talker:Say(
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_PET_NO_FUDGE
)
end

return
end


self:RefreshPet(id)


else
aipFlingItem(aipSpawnPrefab(self.showPet,inst.prefab))

if self.inst.components.talker~=nil then
self.inst.components.talker:Say(
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_PET_FULL_FUDGE
)
end
end
else

local upgradeEffect=petData.upgradeEffect or 1


local canUpgradeSkillNames={}
for skillName,skillData in pairs(petData.skills) do
local maxLevel=petConfig.SKILL_MAX_LEVEL[skillName] or {}
local maxLv=maxLevel[skillData.quality] or 1

if skillData.lv < maxLv then
table.insert(canUpgradeSkillNames,skillName)
end
end


local upgradeSkillName=aipRandomEnt(canUpgradeSkillNames)
for skillName,skillData in pairs(petData.skills) do
if skillName==upgradeSkillName then
local maxLevel=petConfig.SKILL_MAX_LEVEL[skillName] or {}


skillData.lv=skillData.lv+upgradeEffect
skillData.lv=math.min(skillData.lv,maxLevel[skillData.quality] or 1)
break
end
end


self:RefreshPet(id)


petData.upgradeEffect=dev_mode and 0.9 or 0.1
end
end
end


function PetOwner:EnsureTimer()
if not self.inst.components.timer then
self.inst:AddComponent("timer")
end
end


function PetOwner:Attack(target)

local skillInfo,skillLv=self:GetSkillInfo("play")

if skillInfo~=nil then
aipBufferPatch(self.inst,target,"aip_pet_play",skillInfo.duration*skillLv)
end


local muddyInfo,muddyLv=self:GetSkillInfo("muddy")

if muddyInfo~=nil then
aipBufferPatch(self.inst,target,"aip_pet_muddy",muddyInfo.duration)
end


local hotSkillInfo,hotSkillLv=self:GetSkillInfo("hotDog")
if hotSkillInfo~=nil then

if target.prefab=="hound" or target.prefab=="moonhound" then
local hpPtg=target.components.health:GetPercent()
aipReplacePrefab(target,"firehound").components.health:SetPercent(hpPtg)


elseif target.prefab=="firehound" then
local delta=hotSkillInfo.atk*hotSkillLv
local hp=target.components.health.maxhealth
target.components.health:DoDelta(-delta*hp,nil,self.inst.prefab,nil,self.inst)
end
end


local coldSkillInfo,coldSkillLv=self:GetSkillInfo("coldDog")
if coldSkillInfo~=nil then

if target.prefab=="hound" or target.prefab=="moonhound" then
local hpPtg=target.components.health:GetPercent()
aipReplacePrefab(target,"icehound").components.health:SetPercent(hpPtg)


elseif target.prefab=="icehound" then
local delta=coldSkillInfo.atk*coldSkillLv
local hp=target.components.health.maxhealth
target.components.health:DoDelta(-delta*hp,nil,self.inst.prefab,nil,self.inst)
end
end
end


function PetOwner:Attacked(data)
self:EnsureTimer()

local attacker=aipGet(data,'attacker')


local skillInfo,skillLv=self:GetSkillInfo("cowardly")
if skillInfo~=nil and self.inst.components.locomotor~=nil then
local multi=1+skillInfo.multi*skillLv


self.inst.components.timer:StopTimer("aipc_pet_owner_speed")
self.inst.components.timer:StartTimer("aipc_pet_owner_speed",skillInfo.duration)


self.inst.components.locomotor:RemoveExternalSpeedMultiplier(
self.inst,"aipc_pet_owner_speed"
)
self.inst.components.locomotor:SetExternalSpeedMultiplier(
self.inst,"aipc_pet_owner_speed",multi
)
end


local hypnosisInfo,hypnosisLv=self:GetSkillInfo("hypnosis")
if hypnosisInfo~=nil and attacker~=nil then
local multi=hypnosisInfo.multi*hypnosisLv


local SLEEP_TIME=TUNING.PANFLUTE_SLEEPTIME/4

if math.random() < multi then
if attacker.components.sleeper~=nil then
attacker.components.sleeper:AddSleepiness(10,SLEEP_TIME)
elseif attacker.components.grogginess~=nil then
attacker.components.grogginess:AddGrogginess(10,SLEEP_TIME)
else
attacker:PushEvent("knockedout")
end
end
end
end


function PetOwner:StartDistanceCheck()
if self.showPet then
local playerPT=self.inst:GetPosition()
local petPT=self.showPet:GetPosition()
local dist=aipDist(playerPT,petPT)
local MAX_DIST=30


if dist > MAX_DIST then
local angle=aipGetAngle(playerPT,petPT)
local nextPetPT=aipAngleDist(playerPT,angle,MAX_DIST)

self.showPet.Transform:SetPosition(nextPetPT:Get())
end

self:EnsureTimer()
self.inst.components.timer:StartTimer("aipc_pet_owner_distance",5)
end
end


function PetOwner:StartShedding()
local skillInfo,skillLv=self:GetSkillInfo("shedding")

if skillInfo~=nil then
self:EnsureTimer()
local timeout=skillInfo.base-skillInfo.multi*skillLv
timeout=math.max(timeout,10)
self.inst.components.timer:StartTimer("aipc_pet_owner_shedding",timeout)
end
end


function PetOwner:StartAura()
local skillInfo,skillLv=self:GetSkillInfo("accompany")

if skillInfo~=nil and self.showPet~=nil then
if self.showPet.components.sanityaura==nil then
self.showPet:AddComponent("sanityaura")
end


self.showPet.components.sanityaura.aura=skillInfo.unit*skillLv
end
end


function PetOwner:StartHeater()
local coolSkillInfo,coolSkillLv=self:GetSkillInfo("cool")
local hotSkillInfo,hotSkillLv=self:GetSkillInfo("hot")

local skillInfo=coolSkillInfo or hotSkillInfo
local skillLv=coolSkillLv or hotSkillLv

if skillInfo~=nil and self.showPet~=nil then
if self.showPet.components.heater==nil then
self.showPet:AddComponent("heater")
end


local heat=skillInfo.heat*skillLv
self.showPet.components.heater.heat=heat
if heat < 0 then
self.showPet.components.heater:SetThermics(false,true)
end
end
end


function PetOwner:StartCure(doCure)
local skillInfo,skillLv=self:GetSkillInfo("cure")

if skillInfo~=nil and self.inst.components.health~=nil then
local ptg=self.inst.components.health:GetPercent()
local maxPtg=skillInfo.max+skillInfo.maxMulti*skillLv


if
doCure and ptg < maxPtg and
self.showPet and self.showPet:IsValid() and
not self.inst.components.health:IsDead()
then
local delta=skillInfo.multi*skillLv

local proj=aipSpawnPrefab(self.showPet,"aip_projectile")
proj.components.aipc_info_client:SetByteArray(
"aip_projectile_color",{ 0,10,3,5 }
)

proj.components.aipc_projectile:GoToTarget(self.inst,function()
if
self.inst.components.health~=nil and
not self.inst.components.health:IsDead() and
self.inst:IsValid() and not self.inst:IsInLimbo()
then
self.inst.components.health:DoDelta(delta)
end
end)
end

self:EnsureTimer()
self.inst.components.timer:StartTimer("aipc_pet_owner_cure",skillInfo.interval)
end
end


function PetOwner:StartDrink(doCure)
local skillInfo,skillLv=self:GetSkillInfo("sponge")

if skillInfo~=nil and self.inst.components.moisture~=nil then
local moisture=self.inst.components.moisture:GetMoisture()
moisture=math.min(moisture,skillInfo.multi*skillLv)


if doCure and moisture > 0 then
self.inst.components.moisture:DoDelta(-moisture)

if self.inst.components.hunger~=nil then
self.inst.components.hunger:DoDelta(moisture)
end
end

self:EnsureTimer()
self.inst.components.timer:StartTimer("aipc_pet_owner_drink",skillInfo.interval)
end
end


function PetOwner:StartJohnWick()
self:StopJohnWick()

local skillInfo,skillLv=self:GetSkillInfo("johnWick")
if skillInfo~=nil then
local pets={}
if self.inst.components.petleash~=nil then
pets=self.inst.components.petleash:GetPets() or {}
end

local existDog=false

for k,pet in pairs(pets) do
if pet.prefab=="critter_puppy" then
existDog=true
end
end


self._johnWichAura=self.inst:SpawnChild(
existDog and "aip_aura_john_wick" or "aip_aura_john_wick_single"
)
end
end



function PetOwner:StartBlasphemy(doDelta)
local skillInfo,skillLv=self:GetSkillInfo("blasphemy")

if
skillInfo~=nil and
self.showPet and
self.showPet:IsValid() and
self.inst.components.health~=nil
then
if
self.inst.components.health.currenthealth > 1 and
doDelta
then
self.inst.components.health:DoDelta(-1,true)
end

self:EnsureTimer()
self.inst.components.timer:StartTimer("aipc_pet_owner_blasphemy",1)
end
end


function PetOwner:StartBubble()
local skillInfo,skillLv=self:GetSkillInfo("bubble")

if skillInfo~=nil and self.showPet~=nil then
local radius=skillInfo.base+skillInfo.multi*skillLv

if not self.showPet.Light then
self.showPet.entity:AddLight()
end

self.showPet.Light:SetFalloff(0.5)
self.showPet.Light:SetIntensity(.9)
self.showPet.Light:SetColour(237/255,237/255,209/255)
self.showPet.Light:SetRadius(radius)
self.showPet.Light:Enable(true)
end
end

function PetOwner:StopJohnWick()
if self._johnWichAura~=nil then
self._johnWichAura:Remove()
self._johnWichAura=nil
end
end


function PetOwner:StartGraveCloak()
local skillInfo,skillLv,skill=self:GetSkillInfo("graveCloak")

if skillInfo~=nil then
if self.inst.components.aipc_grave_cloak==nil then
self.inst:AddComponent("aipc_grave_cloak")
end

self.inst.components.aipc_grave_cloak.interval=skillInfo.interval
self.inst.components.aipc_grave_cloak.count=skillInfo.count

self.inst.components.aipc_grave_cloak:Start()
end
end

function PetOwner:IsFull()
return #self.pets >=MAX_PET_COUNT
end

function PetOwner:IsEmpty()
return #self.pets <=0
end


function PetOwner:GetInfos()
self:FillInfo()
return self.pets or {}
end


function PetOwner:OnSave()
local data={
pets=self.pets,
id=self.showPet~=nil and self.showPet.components.aipc_petable:GetInfo().id or false,
}

return data
end

function PetOwner:OnLoad(data)
local id=false
if data~=nil then
self.pets=data.pets or {}
end

self:FillInfo()


if data~=nil then
id=data.id
if data.id==nil then
id=self.pets[1]~=nil and self.pets[1].id or false
end
end

if id~=false then
self.inst:DoTaskInTime(1,function()
self:TogglePet(id,true)
end)
end
end

function PetOwner:OnRemoveEntity()
self:HidePet()
self.inst:RemoveEventCallback("onhitother",OnAttack)
self.inst:RemoveEventCallback("attacked",OnAttacked)
self.inst:RemoveEventCallback("timerdone",OnTimerDone)
self.inst:RemoveEventCallback("wormholespit",OnWormholeTravel)
self.inst:RemoveEventCallback("aipStartCooking",OnStartCooking)
self.inst:RemoveEventCallback("picksomething",OnPick)
self.inst:RemoveEventCallback("aipMissAttack",OnMissAttack)
self.inst:RemoveEventCallback("burnt",OnBurnt)
end

PetOwner.OnRemoveFromEntity=PetOwner.OnRemoveEntity

return PetOwner