

local _G=GLOBAL

local globalBuffers={}


function _G.aipBufferRegister(name,info)
globalBuffers[name]=info
end


function _G.aipBufferFn(name,fnName)
return (globalBuffers[name] or {})[fnName]
end


function _G.aipBufferInfos(inst)
if inst==nil or inst._aipBufferGUID==nil then
return {}
end


local buffer=_G.Ents[inst._aipBufferGUID]

return (
buffer~=nil and
buffer:IsValid() and
buffer._aipBufferInfos~=nil and
buffer._aipBufferInfos(buffer)
)
end


function _G.aipBufferExist(inst,name)
local bufferInfos=_G.aipBufferInfos(inst) or {}

return bufferInfos[name]~=nil














end


function _G.aipBufferRemove(inst,name)
if _G.aipBufferExist(inst,name) then

local buffer=_G.Ents[inst._aipBufferGUID]
buffer._buffers[name].endTime=_G.GetTime()-1
if buffer._aipSyncNames~=nil then
buffer._aipSyncNames(buffer)
end
end
end


local function getBuffInst(inst)
local buffer=nil

local children=inst.children or {}
for child,exist in pairs(children) do
if exist and child:IsValid() and child.prefab=="aip_0_buffer" then
buffer=child
break
end
end

return buffer
end


function _G.aipBufferInfo(inst,name)
local buffer=getBuffInst(inst)

if buffer~=nil and buffer._buffers[name]~=nil then
return buffer._buffers[name]
end
end


function _G.aipBufferSetStack(inst,name,stack)
local buffer=getBuffInst(inst)

if buffer~=nil and buffer._buffers[name]~=nil and buffer._aipSyncNames~=nil then
buffer._buffers[name].stack=stack or 0
buffer._aipSyncNames(buffer)
end
end


function _G.aipBufferPatch(source,inst,name,duration,stack)


local buffer=getBuffInst(inst)


if buffer==nil then
buffer=inst:SpawnChild("aip_0_buffer")
end

if buffer==nil then
_G.aipPrint("Buffer 创建失败！",name,inst.prefab)
return
end


if buffer._buffers[name]==nil then

local info={
startTime=_G.GetTime(),
data={},
tick=0,
}
buffer._buffers[name]=info


local startFn=_G.aipBufferFn(name,"startFn")
if startFn~=nil then
startFn(source,inst,{ data=info.data })
end


local fxName=_G.aipBufferFn(name,"fx")
if fxName~=nil then
local fx=_G.SpawnPrefab(fxName)
inst:AddChild(fx)
info.fx=fx
end
end

buffer._buffers[name].srcGUID=source~=nil and source.GUID


local now=_G.GetTime()
local endTime=now+(duration or 2)

if buffer._buffers[name].endTime~=nil then
endTime=math.max(endTime,buffer._buffers[name].endTime)
end

buffer._buffers[name].endTime=endTime


if type(stack)=="function" then
local stackCount=stack(buffer._buffers[name])
buffer._buffers[name].stack=stackCount
end


buffer._buffers[name].stack=buffer._buffers[name].stack or 0



buffer._aipSyncNames(buffer)
end




local InventoryBar=require("widgets/inventorybar")
local BufferList=require("widgets/aip_buffer_list")
local UIFONT=_G.UIFONT

local originRebuild=InventoryBar.Rebuild

function InventoryBar:Rebuild()

local ret=originRebuild(self)


if self._aipBufferList~=nil then
self._aipBufferList:Kill()
self._aipBufferList=nil
end


local bufferList=self.toprow:AddChild(BufferList(self.owner))
bufferList:SetPosition(0,90)

self._aipBufferList=bufferList

return ret
end
