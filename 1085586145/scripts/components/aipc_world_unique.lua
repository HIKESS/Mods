local open_beta=aipGetModConfig("open_beta")=="open"

local dev_mode=aipGetModConfig("dev_mode")=="enabled"


local WorldUnique=Class(function(self,inst)
self.inst=inst

self.prefabs={}


self.aip_oldone_hand_kill=0


self:SetupEnv()
end)


function WorldUnique:RegisterPrefab(item)
self.prefabs[item.prefab]=item
end


function WorldUnique:GetPrefab(prefabName)
local prefab=self.prefabs[prefabName]

if prefab~=nil and prefab:IsValid() then
return prefab
end

self.prefabs[prefabName]=nil

return nil
end



function WorldUnique:EnsurePrefab(prefabName,findFn)
local tryFindPrefab=nil

findFn=findFn or prefabName

if type(findFn)=="function" then
tryFindPrefab=findFn()
elseif type(findFn)=="string" then
tryFindPrefab=TheSim:FindFirstEntityWithTag(findFn)
end

local needCreate=tryFindPrefab==nil

if needCreate then
self.prefabs[prefabName]=SpawnPrefab(prefabName)
else
self.prefabs[prefabName]=tryFindPrefab
end

return self.prefabs[prefabName],needCreate
end


function WorldUnique:SetupEnv()

self.inst:DoTaskInTime(3,function()
local junk_pile_big=TheSim:FindFirstEntityWithTag("junk_pile_big")

if junk_pile_big then
local torchStandMain,newCreate=self:EnsurePrefab("aip_torch_stand_main")


if newCreate then
local junkPt=junk_pile_big:GetPosition()
junkPt=aipGetSecretSpawnPoint(junkPt,60,100)
torchStandMain.Transform:SetPosition(junkPt.x,junkPt.y,junkPt.z)
end
end
end)
end



function WorldUnique:OldoneKillCount(count)
if count~=nil then
self.aip_oldone_hand_kill=count
end
return self.aip_oldone_hand_kill
end


function WorldUnique:OnSave()
return {
aip_oldone_hand_kill=self.aip_oldone_hand_kill,
}
end

function WorldUnique:OnLoad(data)
if data~=nil then
self.aip_oldone_hand_kill=data.aip_oldone_hand_kill or 0
end
end


return WorldUnique