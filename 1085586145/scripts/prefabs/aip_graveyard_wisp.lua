local dev_mode=aipGetModConfig("dev_mode")=="enabled"

local language=aipGetModConfig("language")


local LANG_MAP={
english={
NAME="Wispy",
DESC="Where is my bug net?",
KNOW_RECIPE="I learned it!",
},
chinese={
NAME="鬼火",
DESC="我的捕虫网呢？",
KNOW_RECIPE="我学会了！",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.NAMES.AIP_GRAVEYARD_WISP=LANG.NAME
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_GRAVEYARD_WISP=LANG.DESC


local assets={}


local function onworked(inst,worker)
if worker.components.inventory~=nil then
worker.components.inventory:GiveItem(aipReplacePrefab(inst,"nightmarefuel"))
worker.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")
end


if worker.components.builder and not worker.components.builder:KnowsRecipe("aip_ghost_fire") then
worker.components.builder:UnlockRecipe("aip_ghost_fire")

if worker.components.talker then
worker.components.talker:Say(LANG.KNOW_RECIPE)
end
end
end

local function randomNextPos(inst)
if inst._home==nil or not inst._home:IsValid() then

if dev_mode then
local players=aipFindNearPlayers(inst,20)
inst._home=players[1]
inst:DoTaskInTime(1,randomNextPos)
end

return
end


local oriPT=inst._home:GetPosition()
local distance=5
local angle=math.random()*360

local tgtPT=aipAngleDist(oriPT,angle,distance)

inst.components.aipc_float:MoveToPoint(tgtPT)


local nextTime=math.random()*3+3
inst:DoTaskInTime(nextTime,randomNextPos)
end


local function fn()
local inst=CreateEntity()

inst.entity:AddTransform()
inst.entity:AddAnimState()
inst.entity:AddSoundEmitter()
inst.entity:AddLight()
inst.entity:AddNetwork()

MakeProjectilePhysics(inst,1,.25)

inst.AnimState:SetBank("coldfire_fire")
inst.AnimState:SetBuild("coldfire_fire")
inst.AnimState:PlayAnimation("level1",true)
inst.AnimState:OverrideMultColour(1,.6,1,1)

inst.Light:SetColour(111/255,111/255,227/255)
inst.Light:SetIntensity(0.75)
inst.Light:SetFalloff(0.5)
inst.Light:SetRadius(2)
inst.Light:Enable(true)

inst.entity:SetPristine()

if not TheWorld.ismastersim then
return inst
end

inst:AddComponent("inspectable")

inst:AddComponent("knownlocations")

inst:AddComponent("aipc_float")
inst.components.aipc_float.speed=0.5

inst:AddComponent("workable")
inst.components.workable:SetWorkAction(ACTIONS.NET)
inst.components.workable:SetWorkLeft(1)
inst.components.workable:SetOnFinishCallback(onworked)

inst:AddComponent("perishable")
inst.components.perishable:SetPerishTime(TUNING.SEG_TIME*3)
inst.components.perishable:StartPerishing()
inst.components.perishable:SetOnPerishFn(inst.Remove)

randomNextPos(inst)

inst.persists=false


inst:WatchWorldState("isnight",function(_,isnight)
if not isnight then
inst:Remove()
end
end)

return inst
end

return Prefab("aip_graveyard_wisp",fn,assets)
