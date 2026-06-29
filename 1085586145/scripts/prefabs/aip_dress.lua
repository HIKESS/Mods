local foldername=KnownModIndex:GetModActualName(TUNING.ZOMBIEJ_ADDTIONAL_PACKAGE)


local additional_dress=aipGetModConfig("additional_dress")
if additional_dress~="open" then
return nil
end

local prefabList={}


local dresses={
aip_horse_head={},
aip_som={},
aip_blue_glasses={},
aip_joker_face={},
aip_monkey_face={},
}

for name,data in pairs(dresses) do
local prefab=require("prefabs/"..name)

if prefab[1]~=nil and prefab[2]~=nil then

for k,v in pairs(prefab) do
table.insert(prefabList,v)
end
else

table.insert(prefabList,prefab)
end
end

return unpack(prefabList)