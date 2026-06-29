local _G=GLOBAL
local language=_G.aipGetModConfig("language")
local dev_mode=_G.aipGetModConfig("dev_mode")=="enabled"


AddComponentPostInit("combat",function(self)



self._aipAddDamages={}


self._aipMultiDamages={}

self._aipAddDefenses={}


self._aipMultiDefenses={}


function self:aipAddDamages(name,val)
self._aipAddDamages[name]=ptg
end
function self:aipMultiDamages(name,ptg)
self._aipMultiDamages[name]=ptg
end
function self:aipAddDefenses(name,val)
self._aipAddDefenses[name]=val
end
function self:aipMultiDefenses(name,ptg)
self._aipMultiDefenses[name]=ptg
end




local originGetAttacked=self.GetAttacked

function self:GetAttacked(attacker,damage,weapon,stimuli,spdamage,...)

local data={ damage=damage,spdamage=spdamage }
self.inst:PushEvent("aipAttacked",data)

spdamage=data.spdamage
local dmg=data.damage

if dmg==nil then
return originGetAttacked(self,attacker,damage,weapon,stimuli,spdamage,...)
end


if stimuli=="darkness" and _G.aipBufferExist(self.inst,"veg_lohan") then
dmg=0
_G.aipBufferRemove(self.inst,"veg_lohan")
end


if _G.aipBufferExist(self.inst,"aip_food_cherry_meat") then
local ptg=dev_mode and 1 or 0.1
if _G.aipChance(ptg,self.inst) then
dmg=0
end
end


if dmg > 0 then
local lotusRootBoxInfo=_G.aipBufferInfo(self.inst,"aip_food_lotus_root_box")
if lotusRootBoxInfo~=nil and lotusRootBoxInfo.data~=nil then
local count=lotusRootBoxInfo.data.count or lotusRootBoxInfo.stack or 0
dmg=0

if count <=1 then
_G.aipBufferRemove(self.inst,"aip_food_lotus_root_box")
else
local nextCount=count-1
lotusRootBoxInfo.data.count=nextCount
_G.aipBufferSetStack(self.inst,"aip_food_lotus_root_box",nextCount)
end
end
end


if self.inst~=nil and self.inst.components.aipc_pet_owner~=nil then

local luckyInfo,luckyLv=self.inst.components.aipc_pet_owner:GetSkillInfo("lucky")
if luckyInfo~=nil and stimuli=="darkness" then
dmg=0
end


if dmg > 0 and self.inst.components.moisture~=nil then
local skillInfo,skillLv=self.inst.components.aipc_pet_owner:GetSkillInfo("rainbow")
local moisture=self.inst.components.moisture:GetMoisture()

if skillInfo~=nil and moisture > 0 then
local minVal=math.min(dmg,moisture)
dmg=dmg-minVal
self.inst.components.moisture:DoDelta(-minVal)

_G.aipSpawnPrefab(self.inst,"waterstreak_burst")
end
end


local resonanceInfo,resonanceLv=self.inst.components.aipc_pet_owner:GetSkillInfo("resonance")
if resonanceInfo~=nil and self.inst.components.sanity~=nil and self.inst.components.sanity:IsCrazy() then
dmg=dmg*(1-resonanceInfo.def*resonanceLv)
end
end


if attacker~=nil and attacker.components.aipc_pet_owner~=nil then
local petDmgMulti=0


local blasphemyInfo=attacker.components.aipc_pet_owner:GetSkillInfo("blasphemy")

if blasphemyInfo~=nil then
petDmgMulti=petDmgMulti+(dev_mode and 999 or 1)
end


local shrimpInfo,shrimpLv=attacker.components.aipc_pet_owner:GetSkillInfo("shrimp")

if shrimpInfo~=nil then
local inv=attacker.components.inventory
if inv==nil or inv:GetEquippedItem(_G.EQUIPSLOTS.HANDS)==nil then
petDmgMulti=petDmgMulti+shrimpInfo.multi*shrimpLv
end
end


local resonanceInfo,resonanceLv=attacker.components.aipc_pet_owner:GetSkillInfo("resonance")
if resonanceInfo~=nil and attacker.components.sanity~=nil and attacker.components.sanity:IsCrazy() then
petDmgMulti=petDmgMulti+resonanceInfo.atk*resonanceLv
end

dmg=dmg*(1+petDmgMulti)
end





local multiPtgPositives=0
local multiPtgNegatives=1
for name,ptg in pairs(self._aipMultiDefenses) do
if ptg~=nil then
if ptg > 0 then
multiPtgPositives=multiPtgPositives+ptg
else
multiPtgNegatives=multiPtgNegatives*(1+ptg)
end
end
end


local addSum=0
for name,val in pairs(self._aipAddDefenses) do
if val~=nil then
addSum=addSum+val
end
end


if dmg > 0 then
dmg=dmg*(1+multiPtgPositives)*multiPtgNegatives+addSum
if dmg < 0 then
dmg=0
end
end

return originGetAttacked(self,attacker,dmg,weapon,stimuli,spdamage,...)
end




local originCalcDamage=self.CalcDamage

function self:CalcDamage(target,weapon,multiplier,...)
local oriDmg,oriSpDmg=originCalcDamage(self,target,weapon,multiplier,...)
local dmg=oriDmg
local spDmg=oriSpDmg

local petDmgMulti=1
local petDmgPlus=0
local petDmgDiv=1


if
_G.aipBufferExist(
self.inst,
"aip_oldone_smiling_attack"
)
then
petDmgMulti=petDmgMulti+1
end


if
_G.aipBufferExist(
self.inst,
"aip_gourd_wugui"
)
then
petDmgPlus=petDmgPlus+10
end


local playBuffInfo=_G.aipBufferInfo(
self.inst,
"aip_pet_play"
)
if playBuffInfo~=nil and playBuffInfo.data~=nil then
local desc=playBuffInfo.data.desc or 0

petDmgDiv=petDmgDiv*(1-desc)
end


local johnWickInfo=_G.aipBufferInfo(
self.inst,
"aip_pet_johnWick"
)
if dmg~=0 and johnWickInfo~=nil and johnWickInfo.data~=nil then
local atk=johnWickInfo.data.dmg or 0

petDmgPlus=petDmgPlus+atk
end


if
_G.aipBufferExist(
self.inst,
"monster_salad"
)
then
dmg=dmg*(dev_mode and 999 or 1.05)
end


if self.inst.components.aipc_pet_owner~=nil then

local skillInfo,skillLv=self.inst.components.aipc_pet_owner:GetSkillInfo("aggressive")

if skillInfo~=nil then
local multi=skillInfo.multi*skillLv
petDmgMulti=petDmgMulti+multi
end


local lunaInfo,lunaLv=self.inst.components.aipc_pet_owner:GetSkillInfo("luna")
if lunaInfo~=nil then

local tile=_G.TheWorld.Map:GetTileAtPoint(
self.inst.Transform:GetWorldPosition()
)

if tile==_G.GROUND.METEOR then
petDmgMulti=petDmgMulti+lunaInfo.land*lunaLv
end


if _G.TheWorld.state.isfullmoon then
petDmgMulti=petDmgMulti+lunaInfo.full*lunaLv
end
end


local migaoInfo,migaoLv,migaoSkill=self.inst.components.aipc_pet_owner:GetSkillInfo("migao")

if migaoInfo~=nil then
petDmgMulti=petDmgMulti+(migaoSkill._multi or 0)*migaoInfo.multi
end


local giantsInfo,giantsLv=self.inst.components.aipc_pet_owner:GetSkillInfo("giants")
if giantsInfo~=nil then
if
target.components.health~=nil and
target.components.health.currenthealth >=giantsInfo.hp
then
local multi=giantsInfo.multi*giantsLv
petDmgMulti=petDmgMulti+multi
end
end


local brightshadeKillerInfo,brightshadeKillerLv=self.inst.components.aipc_pet_owner:GetSkillInfo("brightshadeKiller")
if brightshadeKillerInfo~=nil then
if target.components.health~=nil and (target.prefab=="lunarthrall_plant" or target.prefab=="lunarthrall_plant_vine_end" or target.prefab=="lunarthrall_plant_vine") then
local hpPercent=brightshadeKillerInfo.ptg*brightshadeKillerLv
local extraDmg=target.components.health.currenthealth*hpPercent
petDmgPlus=petDmgPlus+extraDmg
end
end


local stealInfo,stealLv=self.inst.components.aipc_pet_owner:GetSkillInfo("steal")
if stealInfo~=nil and target.components.lootdropper~=nil then
local stealChance=stealInfo.multi*stealLv
if _G.aipChance(stealChance,self.inst) then
if not target._aipPetStolen then
target.components.lootdropper:DropLoot()
target._aipPetStolen=true
end
end
end


local balrogInfo,balrogLv=self.inst.components.aipc_pet_owner:GetSkillInfo("balrog")
if
balrogInfo~=nil and (

(
self.inst.components.health~=nil and
self.inst.components.health.takingfiredamage==true
) or

_G.aipBufferExist(self.inst,"aip_balrog")
)

then
petDmgPlus=petDmgPlus+balrogInfo.atk*balrogLv
end
end


if target~=nil and target.components.aipc_pet_owner~=nil then

local skillInfo,skillLv=target.components.aipc_pet_owner:GetSkillInfo("conservative")

if skillInfo~=nil then


petDmgDiv=petDmgDiv*(1-skillInfo.multi*skillLv)
end


local dancerInfo,dancerLv=target.components.aipc_pet_owner:GetSkillInfo("dancer")

if dancerInfo~=nil then
if _G.aipChance(dancerInfo.multi*dancerLv,target) then
dmg=0


if target.SoundEmitter~=nil then
target.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
end


local fx=_G.SpawnPrefab("shadow_shield2")
fx.entity:SetParent(target.entity)
end
end


local migaoInfo,migaoLv,migaoSkill=target.components.aipc_pet_owner:GetSkillInfo("migao")

if migaoInfo~=nil then


petDmgMulti=petDmgMulti+migaoInfo.pain


migaoSkill._multi=0
end


local graveInfo,graveLv=target.components.aipc_pet_owner:GetSkillInfo("graveCloak")
if graveInfo~=nil and target.components.aipc_grave_cloak~=nil and dmg > 0 then
local cnt=target.components.aipc_grave_cloak:GetCurrent()
local diffPTG=cnt*(graveInfo.def+graveInfo.defMulti*graveLv)


petDmgDiv=petDmgDiv*math.max(0,1-diffPTG)


target.components.aipc_grave_cloak:Break()
end


local defendInfo,defendLv=target.components.aipc_pet_owner:GetSkillInfo("defend")
if defendInfo~=nil and target.components.inventory~=nil and dmg > 0 then
local equip=target.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.BODY)
if equip~=nil and equip.components.armor~=nil then
local armor=equip.components.armor
local convertPTG=math.min(1,defendInfo.multi*defendLv)
local convertDmg=math.min(dmg*convertPTG,armor.condition)
armor:TakeDamage(convertDmg)
petDmgDiv=petDmgDiv*(1-convertPTG)
end
end
end


if _G.aipBufferExist(self.inst,"aip_balrog") then
petDmgPlus=petDmgPlus+10
_G.aipBufferRemove(self.inst,"aip_balrog")
end


dmg=(dmg*petDmgMulti+petDmgPlus)*petDmgDiv


if dmg==0 and dmg~=oriDmg then
spDmg=nil
end





local multiPtgPositives=0
local multiPtgNegatives=1
for name,ptg in pairs(self._aipMultiDamages) do
if ptg~=nil then
if ptg > 0 then
multiPtgPositives=multiPtgPositives+ptg
else
multiPtgNegatives=multiPtgNegatives*(1+ptg)
end
end
end


local addSum=0
for name,val in pairs(self._aipAddDamages) do
if val~=nil then
addSum=addSum+val
end
end


if dmg > 0 then
dmg=dmg*(1+multiPtgPositives)*multiPtgNegatives+addSum
if dmg < 0 then
dmg=0
end
end

return dmg,spDmg
end


local originDoAttack=self.DoAttack

function self:DoAttack(targ,weapon,projectile,stimuli,instancemult,instrangeoverride,instpos,...)

if targ~=nil and (not self:CanHitTarget(targ,weapon) or self.AOEarc) then
targ:PushEvent("aipMissAttack",{ source=self.inst,weapon=weapon })
end

return originDoAttack(self,targ,weapon,projectile,stimuli,instancemult,instrangeoverride,instpos,...)
end
end)
