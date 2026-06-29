local dev_mode=aipGetModConfig("dev_mode")=="enabled"
local language=aipGetModConfig("language")


local LANG_MAP={
english={
TALK_DANGER="What is under the ground?",
},
chinese={
TALK_DANGER="有什么在地下？",
},
}

local LANG=LANG_MAP[language] or LANG_MAP.english

STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_BLACK_GAMER_TALK_DANGER=LANG.TALK_DANGER


local START_TIME=3
local INTERVAL=0.1
local CHAPTER_TIME=60

local CHAPTER_COUNT={ 10,8,6,4,2,1 }

local GIFTS={

{ "aip_oldone_meat" },

{ "aip_oldone_meat","aip_oldone_apple" },

{ "aip_oldone_meat","aip_oldone_apple","aip_pet_eyeofterror" },

{
"aip_oldone_meat","aip_oldone_apple",
"aip_oldone_apple","aip_pet_eyeofterror",
},

{
"aip_oldone_meat","aip_oldone_meat",
"aip_oldone_apple","aip_oldone_apple","aip_pet_eyeofterror",
},

{
"aip_oldone_meat","aip_oldone_meat","aip_pet_eyeofterror",
"aip_oldone_apple","aip_oldone_apple","aip_black_xuelong",
},
}

local function randomPosUnit(num)
return num+math.random()-0.5
end


local BlackholeGamer=Class(function(self,inst)
self.inst=inst

self.players={}
self.intervalTask=nil
end)

function BlackholeGamer:NearPlayer(player)
if aipBufferExist(player,"aip_black_immunity") then
aipBufferPatch(self.inst,player,"aip_black_portal",0.001)
return
end


self.players[player]=-START_TIME/INTERVAL
self:Start()


if player.components.talker~=nil then
player.components.talker:Say(
STRINGS.CHARACTERS.GENERIC.DESCRIBE.AIP_BLACK_GAMER_TALK_DANGER
)
end


aipBufferPatch(self.inst,player,"aip_black_count",9999999,function(info)
return info.stack~=nil and info.stack or 10
end)
end

function BlackholeGamer:FarPlayer(player)

self:SendAway(player)
end


function BlackholeGamer:HurtPlayer(player)
if aipBufferExist(player,"aip_black_count") then
aipBufferPatch(self.inst,player,"aip_black_count",9999999,function(info)
local nextStack=(info.stack or 1)-1

if nextStack <=0 then
aipBufferRemove(player,"aip_black_count")
aipBufferPatch(self.inst,player,"aip_black_immunity",60*10)

self:SendAway(player)
end

return nextStack
end)
end
end

local function getChapter(times)
local passTimes=times*INTERVAL
return math.ceil(passTimes/CHAPTER_TIME)
end


function BlackholeGamer:SendAway(player)
aipBufferPatch(self.inst,player,"aip_black_portal",0.001)


local chapters=getChapter(self.players[player] or 0)
local gifts=GIFTS[math.min(chapters,#GIFTS)] or {}

player:DoTaskInTime(2,function()
for _,gift in ipairs(gifts) do
aipFlingItem(
aipSpawnPrefab(player,gift)
)
end
end)



self.players[player]=nil

if aipCountTable(self.players)==0 then
self:End()
end
end


function BlackholeGamer:Start()
self:Stop()

self.intervalTask=self.inst:DoPeriodicTask(INTERVAL,function()

for player,time in pairs(self.players) do
local times=time+1
self.players[player]=times


local chapters=getChapter(times)

if chapters > 0 then

local handCount=CHAPTER_COUNT[math.min(chapters,#CHAPTER_COUNT)] or 1

if times % handCount==0 then
local pos=player:GetPosition()
local hand=aipSpawnPrefab(
player,"aip_oldone_black_hand",
randomPosUnit(pos.x),pos.y,randomPosUnit(pos.z)
)
hand._aipHead=self.inst
end
end
end
end,0)
end


function BlackholeGamer:End()
self:Stop()

local pos=self.inst:GetPosition()

local ents=TheSim:FindEntities(
pos.x,pos.y,pos.z,10,
nil,nil,{ "aip_aura_indicator","aip_oldone_black_group" })

aipReplacePrefab(self.inst,"aip_shadow_wrapper").DoShow()

for _,ent in ipairs(ents) do
ent:Remove()
end
end


function BlackholeGamer:Stop()
if self.intervalTask~=nil then
self.intervalTask:Cancel()
self.intervalTask=nil
end
end

return BlackholeGamer