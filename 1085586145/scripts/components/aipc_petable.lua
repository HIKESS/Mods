local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local VISIBLE_DURAION=dev_mode and 10 or 30

local petConfig=require("configurations/aip_pet")
local petPrefabs=require("configurations/aip_pet_prefabs")

local function syncClientAura(inst)
if inst.components.aipc_petable~=nil then
inst.components.aipc_petable:ShowAura()
end
end


local qualityChances={ 100,5,1,0.1,0 }
if dev_mode then
qualityChances={ 0,0,1,1,0 }
end

local function randomQuality()
return aipRandomLoot(qualityChances) or 1
end


local Petable=Class(function(self,inst)
self.inst=inst
self.aura=nil
self.auraTask=nil


self.data=nil

--主人，默认为空
self.owner=nil

self.inst:AddTag("aip_petable")

self.syncAura=net_event(inst.GUID,"aipc_petable.sync_aura")
self.quality=net_tinybyte(inst.GUID,"aipc_petable.quality","aipc_petable.quality_dirty")
if TheWorld.ismastersim then
self.quality:set(randomQuality())
end
if not TheNet:IsDedicated() then
inst:ListenForEvent("aipc_petable.sync_aura",syncClientAura)
end
end)

function Petable:GetQuality()
return self.quality:value()
end


function Petable:GetQualityChance()
if dev_mode then
return 0.8
end
local chances={ 1,0.6,0.3,0.1,0.01 }
return chances[self:GetQuality()] or 0
end

function Petable:SetQuality(val)
if TheWorld.ismastersim then
self.quality:set(val)
end
end

function Petable:DeltaQuality(delta)
self:SetQuality(self:GetQuality()+delta)
end

function Petable:CleanAura()
if self.aura~=nil then
aipRemove(self.aura)
self.aura=nil
end
if self.auraTask~=nil then
self.auraTask:Cancel()
self.auraTask=nil
end
end

function Petable:ShowClientAura()
self.syncAura:push()
end

function Petable:ShowAura()
if not TheNet:IsDedicated() then
if self.aura==nil then
local quality=self:GetQuality()
local color=petConfig.QUALITY_COLORS[quality]

if color~=nil then

self.aura=SpawnPrefab("aip_aura_buffer")
self.inst:AddChild(self.aura)

self.aura.AnimState:OverrideMultColour(color[1]/255,color[2]/255,color[3]/255,1)
else
aipPrint("MISS Color:",color,quality)
end
end

if self.auraTask~=nil then
self.auraTask:Cancel()
end

self.auraTask=self.inst:DoTaskInTime(VISIBLE_DURAION,function()
self:CleanAura()
end)
end
end

function Petable:ResetInfo()
self.data=nil
end


function Petable:GetInfo(seer)
if self.data~=nil then
return self.data
end

local quality=self:GetQuality()


local prefab,subPrefab=petPrefabs.getPrefab(self.inst,seer)

local data={
id=os.time(),
prefab=prefab,
subPrefab=subPrefab,
quality=quality,
skills={},
}


local petSkillList=petPrefabs.getSkills(prefab,subPrefab) or {}
local skillList=aipTableConcat(petConfig.SKILL_LIST,petSkillList)


local skillCnt=0


local maxSkillCnt=math.min(quality,4)
maxSkillCnt=math.max(2,maxSkillCnt)

for i=1,99 do
local rndSkill=aipRandomEnt(skillList)

if rndSkill~=nil and data.skills[rndSkill]==nil then
local skillQuality=math.max(1,math.random(quality-1,quality))

data.skills[rndSkill]={

quality=skillQuality,
lv=1,
}

skillCnt=skillCnt+1
end


if skillCnt >=maxSkillCnt then
break
end
end



self.data=data

return data
end


function Petable:SetInfo(data,owner)
self.owner=owner
self.data=data
self:SetQuality(data.quality)
end

function Petable:OnSave()
return {
quality=self:GetQuality(),
}
end

function Petable:OnLoad(data)
if data~=nil then
self:SetQuality(data.quality or 1)
end
end

return Petable