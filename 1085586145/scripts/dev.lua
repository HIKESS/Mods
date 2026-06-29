local _G=GLOBAL
local dev_mode=_G.aipGetModConfig("dev_mode")=="enabled"

if not dev_mode then
return
end


_G.aipPrint("!!! 你正在使用《额外物品包》开发模式，如果是正式游玩请在设置中关闭该设置 !!!")


function _G.c_aip_pet()
if _G.TheWorld~=nil and not _G.TheWorld.ismastersim then
return _G.c_remote("c_aip_pet()")
end

local player=_G.ConsoleCommandPlayer()
if player==nil or player.components.aipc_pet_owner==nil then
return nil
end

if player.components.aipc_pet_owner:IsFull() then
if player.components.talker~=nil then
player.components.talker:Say("Pet list is full")
end
return nil
end

local rabbit=_G.SpawnPrefab("rabbit")
if rabbit==nil then
return nil
end

rabbit.Transform:SetPosition(player.Transform:GetWorldPosition())

if rabbit.components.aipc_petable==nil then
rabbit:AddComponent("aipc_petable")
end

local pet=player.components.aipc_pet_owner:AddPet(rabbit)
_G.aipRemove(rabbit)

return pet
end


local CHESTER_TEST_STATE_MAP={
normal="NORMAL",
chester="NORMAL",
snow="SNOW",
snowchester="SNOW",
ice="SNOW",
shadow="SHADOW",
shadowchester="SHADOW",
}

local HUTCH_TEST_FORM_MAP={
normal="NORMAL",
hutch="NORMAL",
fugu="FUGU",
puffer="FUGU",
pufferfish="FUGU",
music="MUSIC",
musicbox="MUSIC",
}

local function getDevPlayer()
return _G.ConsoleCommandPlayer() or _G.ThePlayer
end

local function sayDevMessage(msg)
local player=getDevPlayer()
if player~=nil and player.components.talker~=nil then
player.components.talker:Say(msg)
end
end

local function normalizeDevArg(value)
if value==nil or value=="" then
return nil
end

return string.lower(tostring(value))
end

local function formatDevArg(value)
return value==nil and "nil" or string.format("%q",tostring(value))
end

local function getSelectedDevTarget()
return _G.ConsoleWorldEntityUnderMouse()
end

local function findNearestDevTarget(tag)
local player=getDevPlayer()
if player==nil then
return nil
end

local x,y,z=player.Transform:GetWorldPosition()
local ents=_G.TheSim:FindEntities(x,y,z,80,{ tag },{ "INLIMBO" })
local target=nil
local targetDist=nil

for _,ent in ipairs(ents) do
if ent:IsValid() and (ent.components.health==nil or not ent.components.health:IsDead()) then
local dist=ent:GetDistanceSqToPoint(x,y,z)
if targetDist==nil or dist < targetDist then
target=ent
targetDist=dist
end
end
end

return target
end

local function getSelectedOrNearestDevTarget(kind)
local selected=getSelectedDevTarget()
if selected~=nil and selected:IsValid() and selected:HasTag(kind) then
return selected
end

return findNearestDevTarget(kind)
end

local function setChesterDevState(chester,state)
if state=="NORMAL" then
if chester._chesterstate~=nil then
chester._chesterstate:set(1)
end

if chester:HasTag("shadow_aligned") and chester.OnPreLoad~=nil then
chester:OnPreLoad({ ChesterState="SNOW" })
if chester._chesterstate~=nil then
chester._chesterstate:set(1)
end
end

chester:RemoveTag("fridge")
chester:RemoveTag("spoiler")
chester:RemoveTag("shadow_aligned")
chester.MiniMapEntity:SetIcon("chester.png")

if chester.components.maprevealable~=nil then
chester.components.maprevealable:SetIcon("chester.png")
end

if chester.sg~=nil then
chester.sg.mem.isshadow=nil
end

if chester.SetBuild~=nil then
chester:SetBuild()
end
elseif chester.OnPreLoad~=nil then
chester:OnPreLoad({ ChesterState=state })
elseif chester.DebugMorph~=nil then
chester:DebugMorph(state)
end

if chester.OnLoadPostPass~=nil then
chester:OnLoadPostPass()
end

return chester
end

local function setHutchDevForm(hutch,form)
if hutch.components.amorphous==nil then
return nil
end

local targetForm=hutch.components.amorphous:FindForm(form)
if targetForm==nil then
return nil
end

hutch.components.amorphous:MorphToForm(targetForm,true)
return hutch
end

function _G.c_aip_cozy_nest_guest(kind,form)
if _G.TheWorld~=nil and not _G.TheWorld.ismastersim then
return _G.c_remote(
"c_aip_cozy_nest_guest("..
formatDevArg(kind)..","..
formatDevArg(form)..
")"
)
end

kind=normalizeDevArg(kind)
form=normalizeDevArg(form)

if kind==nil then
sayDevMessage("Usage: c_aip_cozy_nest_guest('chester','snow')")
return nil
end

if form==nil then
local selected=getSelectedDevTarget()

if selected~=nil and selected:IsValid() and selected:HasTag("hutch") then
form=kind
kind="hutch"
else
form=kind
kind="chester"
end
end

if kind=="chester" then
local state=CHESTER_TEST_STATE_MAP[form]
local chester=getSelectedOrNearestDevTarget("chester")

if chester==nil or state==nil then
sayDevMessage("Missing Chester or state")
return nil
end

sayDevMessage("Chester-> "..state)
return setChesterDevState(chester,state)
end

if kind=="hutch" then
local hutchForm=HUTCH_TEST_FORM_MAP[form]
local hutch=getSelectedOrNearestDevTarget("hutch")

if hutch==nil or hutchForm==nil then
sayDevMessage("Missing Hutch or form")
return nil
end

sayDevMessage("Hutch-> "..hutchForm)
return setHutchDevForm(hutch,hutchForm)
end

sayDevMessage("Unknown cozy nest guest")
return nil
end


local function PlayerPrefabPostInit(inst)
if not _G.TheWorld.ismastersim then
return
end

if not inst.components.aipc_timer then
inst:AddComponent("aipc_timer")
end


inst:RemoveTag("insomniac")

inst.components.aipc_timer:Interval(0.3,function()
if not inst.components.health:IsDead() and inst.components.health.currenthealth < 50 then
inst.components.health:SetCurrentHealth(50)
end
if inst.components.sanity.current < 30 then
inst.components.sanity.current=30
inst.components.sanity:DoDelta(0)
end
end)


inst:DoTaskInTime(1,function()
if inst.components.drownable then
inst.components.drownable.enabled=false
end
end)






















end

AddPlayerPostInit(PlayerPrefabPostInit)




























































































