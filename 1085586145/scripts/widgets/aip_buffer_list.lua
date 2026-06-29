local Widget=require "widgets/widget"
local Text=require "widgets/text"
local BufferBadge=require "widgets/aip_buffer_badge"

local OFFSET=70

local BufferList=Class(Widget,function(self,owner)
Widget._ctor(self,"Inventory")
self.owner=owner

self.root=self:AddChild(Widget("root"))

self.buffers={}
self.keyStr=nil

self:StartUpdating()
end)


function BufferList:Refresh(bufferInfos)
local keys=aipTableKeys(bufferInfos)
keys=aipFilterTable(keys,function(key)
return not aipBufferFn(key,"hideBuffer")
end)
table.sort(keys)

local keyStr=aipJoin(
aipTableMap(keys,function(key)
local info=bufferInfos[key]
return key .. ":" .. info.endTime .. ":" .. (info.stack or 0)
end),
","
)


if self.keyStr==keyStr then
return
end

self.keyStr=keyStr


for _,buffer in ipairs(self.buffers) do
buffer:Kill()
end
self.buffers={}


local totalCount=#keys
local i=0

for i,bufferName in ipairs(keys) do
local info=bufferInfos[bufferName]

local buffer=self.root:AddChild(
BufferBadge(self.owner,bufferName,info.endTime,info.stack)
)
buffer:SetPosition(-OFFSET*(totalCount-1)/2+OFFSET*i,0)

table.insert(self.buffers,buffer)

i=i+1
end
end

function BufferList:OnUpdate(dt)
if TheNet:IsServerPaused() then
return
end

local bufferInfos=aipBufferInfos(self.owner)

self:Refresh(bufferInfos)

















end

return BufferList
