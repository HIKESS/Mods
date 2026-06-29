local open_beta=aipGetModConfig("open_beta")=="open"

local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local function findFarAwayOcean(pos)
local ocean_pos=nil
local longestDist=-1

for i=1,30 do
local rndPos=aipFindRandomPointInOcean(20,4)

local dist=(rndPos~=nil and pos~=nil) and aipDist(rndPos,pos) or 0


if dist >=longestDist then
longestDist=dist
ocean_pos=rndPos
end
end


if ocean_pos==nil then
ocean_pos=FindNearbyOcean(Vector3(0,0,0))


else
local ents=aipFindNearEnts(
ocean_pos,
{"seastack","messagebottle","driftwood_log"},
dev_mode and 20 or 5
)
for i,ent in ipairs(ents) do
if ent:IsValid() then
ent:Remove()
end
end
end

return ocean_pos
end

local function onFishShoalAdded(inst)
if TheWorld.components.world_common_store~=nil then
table.insert(
TheWorld.components.world_common_store.fishShoals,
inst
)
end
end


local function OnSendLightningStrike(inst,pos)
local pt=aipGetSpawnPoint(pos,10)
if pt~=nil then

local exists=TheSim:FindEntities(
pt.x,pt.y,pt.z,
TUNING.MUSHSPORE_MAX_DENSITY_RAD,{"aip_particles"}
)

if #exists < 9 then
aipSpawnPrefab(inst,"aip_particles",pt.x,pt.y,pt.z)
end
end
end

local CommonStore=Class(function(self,inst)
self.inst=inst
self.shadow_follower_count=0


self.chestOpened=false

self.holderChest=nil

self.chests={}


self.douTotem=nil


self.flyTotems={}
self.flyTotemMarked=nil


self.fishShoals={}


self.storyBook=false


self.particles={}


self:PostWorld()

self.inst:ListenForEvent("ms_registerfishshoal",onFishShoalAdded)


self.smileLeftDays=0
inst:WatchWorldState("isnight",function(_,isnight)
if isnight then
self.smileLeftDays=math.min(self.smileLeftDays-1)
end
end)

inst:ListenForEvent("ms_sendlightningstrike",OnSendLightningStrike,TheWorld)
end)

function CommonStore:CleanTotem()
if self.flyTotemMarked~=nil then
aipRemove(self.flyTotemMarked._aip_trigger_aura)
self.flyTotemMarked=nil
end

if self.flyTotemMarkTask~=nil then
self.flyTotemMarkTask:Cancel()
self.flyTotemMarkTask=nil
end
end

function CommonStore:MarkTotem(totem)
if totem~=nil then
self:CleanTotem()
end

if totem==false then
self.flyTotemMarked=nil
elseif totem~=nil then
self.flyTotemMarked=totem


local aura=SpawnPrefab("aip_aura_trigger")
totem:AddChild(aura)
totem._aip_trigger_aura=aura


self.flyTotemMarkTask=self.inst:DoTaskInTime(5,function()
self:CleanTotem()
end)
end

return self.flyTotemMarked
end

function CommonStore:OnSave()
return {
storyBook=self.storyBook,
}
end

function CommonStore:OnLoad(data)
if data~=nil then
self.storyBook=data.storyBook
end
end

function CommonStore:isShadowFollowing()
return self.shadow_follower_count > 0
end


function CommonStore:CreateCoookieKing(pos)

if not TheWorld:HasTag("forest") then
return
end


local ent=TheSim:FindFirstEntityWithTag("aip_cookiecutter_king")
if ent~=nil and pos==nil then
return ent
end

local ocean_pos=findFarAwayOcean(pos)

if ocean_pos~=nil then
return aipSpawnPrefab(nil,"aip_cookiecutter_king",ocean_pos.x,ocean_pos.y,ocean_pos.z)
end

return nil
end


function CommonStore:FindDouTotem()
if not self.douTotem then
self.douTotem=TheSim:FindFirstEntityWithTag("aip_dou_totem_final")
end
return self.douTotem
end


function CommonStore:CreateRubik()

if not TheWorld:HasTag("forest") then
return
end


local ent=TheSim:FindFirstEntityWithTag("aip_rubik")
if ent~=nil then
return ent
end


local grave=TheSim:FindFirstEntityWithTag("grave")
local pos=nil
if grave~=nil then
pos=grave:GetPosition()
end

if not pos then
pos=aipGetSecretSpawnPoint(Vector3(0,0,0),0,1000)
end

pos=aipGetSecretSpawnPoint(pos,0,50,5)

if pos==nil then
return nil
end

local rubik=aipSpawnPrefab(nil,"aip_rubik",pos.x,pos.y,pos.z)
rubik.components.fueled:MakeEmpty()

return rubik
end


function CommonStore:CreateSpiderden()

if not TheWorld:HasTag("forest") then
return
end


local ent=TheSim:FindFirstEntityWithTag("aip_oldone_spiderden")
if ent~=nil then
return ent
end


local tentacle=aipFindRandomEnt("tentacle")
local pos=nil
if tentacle~=nil then
pos=tentacle:GetPosition()
end

if not pos then
pos=aipGetSecretSpawnPoint(Vector3(0,0,0),0,1000)
end

if pos then
pos=aipGetSecretSpawnPoint(pos,0,50,5)
end

if pos==nil then
return nil
end

local spiderden=aipSpawnPrefab(nil,"aip_oldone_spiderden",pos.x,pos.y,pos.z)

return spiderden
end


function CommonStore:CreateMarble()

if not TheWorld:HasTag("forest") then
return
end


local now=GetTime()


local marble=TheSim:FindFirstEntityWithTag("aip_oldone_marble")
if marble~=nil then
return marble
end


if marble==nil then
for i=1,10 do
local reeds=aipFindRandomEnt("pond_mos")

if reeds~=nil then
local rx,ry,rz=reeds.Transform:GetWorldPosition()

if TheWorld.Map:GetTileAtPoint(rx,ry,rz)==GROUND.MARSH then
local tgtPT=aipGetSecretSpawnPoint(reeds:GetPosition(),1,10,5)
if tgtPT~=nil then
marble=aipSpawnPrefab(nil,"aip_oldone_marble",tgtPT.x,tgtPT.y,tgtPT.z)
break
end
end
end
end
end


local diff=GetTime()-now

return marble
end



function CommonStore:CreateDeer()

if not TheWorld:HasTag("cave") then
return
end


if TheSim:FindFirstEntityWithTag("aip_oldone_deer")~=nil then
return
end

local rocky=TheSim:FindFirstEntityWithTag("rocky")
if rocky==nil then
return
end


local tgtPT=aipGetSecretSpawnPoint(rocky:GetPosition(),5,20,5)
if tgtPT~=nil then
aipSpawnPrefab(nil,"aip_oldone_deer",tgtPT.x,tgtPT.y,tgtPT.z)
end
end

function CommonStore:CreateSuWuMound(pos)

local ent=TheSim:FindFirstEntityWithTag("aip_suwu_mound")
if ent~=nil and pos==nil then
return ent
end

local ocean_pos=findFarAwayOcean(pos)

if ocean_pos~=nil then
return aipSpawnPrefab(nil,"aip_suwu_mound",ocean_pos.x,ocean_pos.y,ocean_pos.z)
end

return nil
end

function CommonStore:PostWorld()



self.inst:DoTaskInTime(1,function()
if self.storyBook~=true and TheWorld:HasTag("forest") then
local portal=TheSim:FindFirstEntityWithTag("multiplayer_portal")

if portal~=nil then
aipSpawnPrefab(portal,"aip_storybook")
self.storyBook=true
end
end
end)


self.inst:DoTaskInTime(5,function()
local dou_totem=aipFindEnt(
"aip_dou_totem_broken",
"aip_dou_totem_powerless",
"aip_dou_totem",
"aip_dou_totem_cave"
)

if dou_totem==nil then

local fissurePT=aipGetTopologyPoint("lunacyarea","moon_fissure")
if fissurePT then
local tgt=aipGetSecretSpawnPoint(fissurePT,0,50,5)
if tgt~=nil then
aipSpawnPrefab(nil,"aip_dou_totem_broken",tgt.x,tgt.y,tgt.z)
else
aipPrint("月岛图腾创建失败！")
end

else

local targetPrefab=aipFindRandomEnt("rabbithouse")
if targetPrefab~=nil then
local tgt=aipGetSecretSpawnPoint(targetPrefab:GetPosition(),0,50,5)
if tgt~=nil then
aipSpawnPrefab(nil,"aip_dou_totem_broken",tgt.x,tgt.y,tgt.z)
else
aipPrint("洞穴图腾创建失败！")
end
else
aipPrint("兜底图腾创建失败！")
end
end
end
end)


self.inst:DoTaskInTime(10,function()
self:CreateCoookieKing()
end)


self.inst:DoTaskInTime(5,function()
self:CreateRubik()
end)


self.inst:DoTaskInTime(7,function()
self:CreateSpiderden()
end)


self.inst:DoTaskInTime(3,function()
self:CreateMarble()
end)


self.inst:DoTaskInTime(1,function()
self:CreateDeer()
end)



if dev_mode then
self.inst:DoTaskInTime(5,function()



end)





end





































end

return CommonStore









































