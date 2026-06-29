local dev_mode=aipGetModConfig("dev_mode")=="enabled"
local language=aipGetModConfig("language")


local LANG_MAP={
english={
NAME="Fusious Deer Stone",
DESC="It looks like smoked",
},
chinese={
NAME="漆黑的鹿",
DESC="看起来有被烟熏的痕迹",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_OLDONE_DEER=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_OLDONE_DEER=LANG.DESC


local assets={
Asset("ANIM","anim/aip_oldone_deer.zip"),
}


local function syncStatus(inst)
local animName="idle"

if inst._aipLevel==2 then
animName="full"
elseif inst._aipLevel==1 then
animName="half"
end

if not inst.AnimState:IsCurrentAnimation(animName) then
inst.AnimState:PlayAnimation(animName)
end
end

local function spawnEye(inst)
if inst._aipLevel < 2 then
inst._aipSpawnDuration=0
return
end

inst._aipSpawnDuration=inst._aipSpawnDuration+1
if inst._aipSpawnDuration <=1 then
return
end

inst._aipSpawnDuration=0
local x,y,z=inst.Transform:GetWorldPosition()


local d=math.random(1,3)
local dist=d*3+1
local count=4+d*3
local startI=math.random(1,count)

for i=1,count do
local angle=(i+startI)/count*2*PI+PI/4*d
local tgtX=x+math.cos(angle)*dist
local tgtZ=z+math.sin(angle)*dist


if TheWorld.Map:IsAboveGroundAtPoint(tgtX,0,tgtZ) then
local ents=TheSim:FindEntities(tgtX,0,tgtZ,0.5)

if #ents==0 then
aipSpawnPrefab(nil,"aip_oldone_deer_eye",tgtX,0,tgtZ)
return
end
end
end
end

local function onNear(inst,player)
inst.components.aipc_timer:NamedInterval("PlayerNear",3,function()

spawnEye(inst)


local x,y,z=inst.Transform:GetWorldPosition()
local fires=TheSim:FindEntities(x,y,z,5,{ "fire" })
fires=aipFilterTable(fires,function(fire)
return fire.components.burnable~=nil and fire.components.burnable:IsBurning()
end)


local firing=#fires > 0
local temperature=inst.components.temperature:GetCurrent()
local offset=firing and 1 or-1

inst._aipLevel=math.max(0,inst._aipLevel+offset)
inst._aipLevel=math.min(2,inst._aipLevel)

if temperature < 70 then
inst._aipLevel=math.min(1,inst._aipLevel)
end

if temperature < 50 then
inst._aipLevel=0
end

syncStatus(inst)


if inst._aipLevel==0 then
local eyes=TheSim:FindEntities(x,y,z,15,{ "aip_oldone_deer_eye" })
local eye=aipRandomEnt(eyes)

if eye~=nil then
eye:ListenForEvent("animover",inst.Remove)
eye.AnimState:PlayAnimation("dead")
end
end
end)
end

local function onFar(inst)
inst.components.aipc_timer:KillName("PlayerNear")
end



local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddNetwork()

MakeObstaclePhysics(inst,1)

inst.AnimState:SetBank("aip_oldone_deer")
inst.AnimState:SetBuild("aip_oldone_deer")
inst.AnimState:PlayAnimation("idle")

inst:AddTag("aip_oldone_deer")

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("playerprox")
inst.components.playerprox:SetDist(20,30)
inst.components.playerprox:SetOnPlayerNear(onNear)
inst.components.playerprox:SetOnPlayerFar(onFar)

inst:AddComponent("aipc_timer")

inst:AddComponent("temperature")
inst.components.temperature.current=TheWorld.state.temperature
inst.components.temperature.inherentinsulation=0--TUNING.INSULATION_MED
inst.components.temperature.inherentsummerinsulation=0

MakeHauntableLaunch(inst)

inst._aipLevel=0
inst._aipSpawnDuration=0

return inst
end

return Prefab("aip_oldone_deer",fn,assets)
