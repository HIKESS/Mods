




local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local assets={
Asset("ANIM","anim/aip_buffer.zip")
}



local function onRegisterParent(inst)
local parent=inst.entity:GetParent()
if parent~=nil then
inst._aipParentGUID=parent.GUID
parent._aipBufferGUID=inst.GUID
end
end

local function onUnregisterParent(inst)
local parent=Ents[inst._aipParentGUID]
if parent~=nil then
parent._aipBufferGUID=nil
end
end


local interval=0.5

local function getParent(inst)
local parentEntity=inst.entity:GetParent()
return parentEntity and Ents[parentEntity.GUID] or nil
end


local function syncNames(inst)
local nameEndTimes={}

for key,info in pairs(inst._buffers) do
table.insert(nameEndTimes,key..":"..info.endTime..":"..info.stack)
end

inst._aipBufferNames:set(

aipJoin(nameEndTimes,",")
)
end


local function getBufferInfos(inst)
local bufferKeys=aipSplit(inst._aipBufferNames:value(),",")

local bufferInfos={}


for i,bufferNameEndTimeStack in ipairs(bufferKeys) do
local nameEndTimeStack=aipSplit(bufferNameEndTimeStack,":")
local bufferName=nameEndTimeStack[1]
local endTime=tonumber(nameEndTimeStack[2])
local stack=tonumber(nameEndTimeStack[3])

bufferInfos[bufferName]={
endTime=endTime,
stack=stack,
}
end

return bufferInfos
end


local function clientRefresh(inst)
local bufferInfos=getBufferInfos(inst)

for bufferName,info in pairs(bufferInfos) do
local clientFn=aipBufferFn(bufferName,"clientFn")
if clientFn~=nil then
clientFn(getParent(inst))
end
end














end















local function getSource(GUID)
return Ents[GUID]
end


local function serverRefresh(inst)
local allRemove=true
local rmNames={}
local nextShowFX=false

local now=GetTime()

for name,info in pairs(inst._buffers) do
info.tick=info.tick+1


local fnData={
interval=interval,
passTime=now-info.startTime,
tick=info.tick,
tickTime=info.tick*interval,
data=info.data,
}


local fn=aipBufferFn(name,"fn")
if fn~=nil then
fn(getSource(info.srcGUID),getParent(inst),fnData)
end

nextShowFX=aipBufferFn(name,"showFX") or nextShowFX



if info.endTime <=now then
table.insert(rmNames,name)
else
allRemove=false
end
end


if nextShowFX~=inst._aipShowFX then
inst._aipShowFX=nextShowFX

if inst._aipShowFX then
inst:Show()
else
inst:Hide()
end
end


for i,name in ipairs(rmNames) do
local info=inst._buffers[name]


local endFn=aipBufferFn(name,"endFn")
if endFn~=nil then
endFn(getSource(info.srcGUID),getParent(inst),{ data=info.data })
end


if info.fx~=nil then
inst:RemoveChild(info.fx)
end
end

inst._buffers=aipFilterKeysTable(inst._buffers,rmNames)
syncNames(inst)


if allRemove then
inst:Remove()
end
end


local function fn(data)
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

inst.AnimState:SetBank("aip_buffer")
inst.AnimState:SetBuild("aip_buffer")

inst.AnimState:PlayAnimation("idle",true)
inst.AnimState:SetMultColour(0.24,0.27,0.38,1)

inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
inst.AnimState:SetSortOrder(2)

inst:AddTag("NOCLICK")
inst:AddTag("fx")

inst.entity:SetPristine()


inst:DoTaskInTime(0.01,onRegisterParent)


inst.OnRemoveEntity=onUnregisterParent


if not TheNet:IsDedicated() then
inst:DoPeriodicTask(interval,clientRefresh,0.01)
end

inst._aipBufferNames=net_string(inst.GUID,"aipc_buffer","aipc_buffer_dirty")

inst._aipBufferInfos=getBufferInfos

if not TheWorld.ismastersim then
return inst
end

inst.persists=false

inst._buffers={}
inst._aipSyncNames=syncNames
inst._aipShowFX=nil

inst:DoPeriodicTask(interval,serverRefresh,0.01)

return inst
end


local function commonFn(anim)
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

inst.AnimState:SetBank("aip_buffer")
inst.AnimState:SetBuild("aip_buffer")

inst.AnimState:PlayAnimation(anim,true)

inst:AddTag("NOCLICK")
inst:AddTag("fx")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst.persists=false

return inst
end

local function paincFn()
return commonFn("panic")
end

return Prefab("aip_0_buffer",fn,assets),
Prefab("aip_buffer_panic",paincFn,assets)
