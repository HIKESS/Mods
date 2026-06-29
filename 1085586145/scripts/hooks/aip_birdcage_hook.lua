local _G=GLOBAL
local Prefabs=_G.Prefabs



local function getSeedPrefab(item)
if item==nil or item.prefab==nil then
return nil
end

local seedPrefab=string.lower(item.prefab.."_seeds")
return Prefabs[seedPrefab]~=nil and seedPrefab or nil
end



local function pushPendingSeed(inst,prefab,quality)
inst.aipPendingBirdSeeds=inst.aipPendingBirdSeeds or {}

table.insert(inst.aipPendingBirdSeeds,{
prefab=prefab,
quality=quality,
})
end

local function clearPendingSeeds(inst)
inst.aipPendingBirdSeeds=nil
end

AddPrefabPostInit("birdcage",function(inst)
if not _G.TheWorld.ismastersim then
return
end


inst:ListenForEvent("trade",function(inst,data)
local item=data~=nil and data.item or nil
local quality=item~=nil and item.components.aipc_quality or nil
local seedPrefab=getSeedPrefab(item)

if quality~=nil and seedPrefab~=nil then
pushPendingSeed(inst,seedPrefab,quality:GetVal())
end
end)


inst:ListenForEvent("loot_prefab_spawned",function(inst,data)
local pendingSeeds=inst.aipPendingBirdSeeds
if pendingSeeds==nil or #pendingSeeds <=0 then
return
end

local loot=data~=nil and data.loot or nil
local pending=pendingSeeds[1]

if loot~=nil and loot.prefab==pending.prefab then
if loot.components.aipc_quality~=nil then
loot.components.aipc_quality:SetVal(pending.quality)
end

table.remove(pendingSeeds,1)
if #pendingSeeds <=0 then
clearPendingSeeds(inst)
end
else
clearPendingSeeds(inst)
end
end)
end)
