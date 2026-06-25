
local easing = require("easing")

-- Just making sure it's not running on clients
return Class(function(self, inst)

assert(TheWorld.ismastersim, "TiddleStrangerspawner should not exist on client")

-- Change this one to your kind stranger

local STRANGER = "tiddlestranger_william"

-- Change this only if you want a separate timer.

local TIMERNAME = "tiddlestranger_timetospawn" 


local STRANGER_SPAWN_DIST = 6
--------------------------------

self.inst = inst

self._stranger = STRANGER 

self.isstrangerspawner = true

local _worldsettingstimer = TheWorld.components.worldsettingstimer

local _spawndelay = TUNING.TOTAL_DAY_TIME
local _targetplayer = nil

local _timetospawn

local _activeplayers = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function AllowedToSpawn()
    return  #_activeplayers > 0
end

local function IsEligible(player)
	local area = player.components.areaaware
	return TheWorld.Map:IsVisualGroundAtPoint(player.Transform:GetWorldPosition())
			and area:GetCurrentArea() ~= nil
end

local function PickStrangerTarget()
    _targetplayer = nil
    if #_activeplayers == 0 then
        return
    end

	local playerlist = {}
	for _, v in ipairs(_activeplayers) do
		if IsEligible(v) then
			table.insert(playerlist, v)
		end
	end
	shuffleArray(playerlist)
	if #playerlist == 0 then
		return
	end
	local player = playerlist[1]
	_targetplayer = player
end

local function PauseSpawn()
	_targetplayer = nil
    self.inst:StopUpdatingComponent(self)
    _worldsettingstimer:PauseTimer(TIMERNAME, true)
end



local function TryStartSpawn()
    if AllowedToSpawn() then
        if _worldsettingstimer:GetTimeLeft(TIMERNAME) == nil then
            _spawndelay = TUNING.TOTAL_DAY_TIME*GetRandomMinMax(1, 2)
            _worldsettingstimer:StartTimer(TIMERNAME, _spawndelay)
        end

        _worldsettingstimer:ResumeTimer(TIMERNAME)
        self.inst:StartUpdatingComponent(self)
        self:StopWatchingWorldState("cycles", TryStartSpawn)
        self.inst.watchingcycles = nil
    else
        PauseSpawn()
        if not self.inst.watchingcycles then
            self:WatchWorldState("cycles", TryStartSpawn)
            self.inst.watchingcycles = true
        end
    end
end

local function ResetSpawn()
    _worldsettingstimer:StopTimer(TIMERNAME)
    PauseSpawn()
    TryStartSpawn()
end

local function TargetLost()
    local timetospawn = _worldsettingstimer:GetTimeLeft(TIMERNAME)
    if timetospawn == nil then
        _worldsettingstimer:StartTimer(TIMERNAME, _spawndelay + 1)
    elseif (timetospawn < spawndelay) then
        _worldsettingstimer:SetTimeLeft(TIMERNAME, _spawndelay + 1)
    end

    PickStrangerTarget()
    if _targetplayer == nil then
        PauseSpawn()
    end
end

local function GetSpawnPoint(pt)
    if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
        pt = FindNearbyLand(pt, 1) or pt
    end
    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 6, 12, true)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end

local function ShouldSpawn()
    local stranger = TheSim:FindFirstEntityWithTag("tiddlestranger")
    local chance = 0.02
    return math.random() < chance and stranger == nil

end

local function ReleaseStranger(targetPlayer)
    assert(targetPlayer)
    if not ShouldSpawn() then
	print("Stranger spawn failed")
	return
    end

    local spawn_pt = GetSpawnPoint(targetPlayer:GetPosition())
    if spawn_pt ~= nil then

    	local strangers = {}
    	if self.inst ~= nil and self.inst.components ~= nil then
	    print("self isn't nil")
	    for k, v in pairs(inst.components) do
	    	if v.isstrangerspawner == true then
		    table.insert(strangers, v._stranger)
	    	end
 	    end
    	end

            local stranger = SpawnPrefab(strangers[math.random(#strangers)])

        if stranger ~= nil then
            stranger.Physics:Teleport(spawn_pt:Get())
            return stranger
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------


local function OnPlayerJoined(src,player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)

    TryStartSpawn()
end

local function OnPlayerLeft(src,player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            --
			-- if this was the activetarget...cease the attack
			if player == _targetplayer then
				TargetLost()
			end
            return
        end
    end
end

local function OnTiddleStrangerTimerDone(src, data)
    if _targetplayer == nil then
        PickStrangerTarget() -- In case a long update skipped the warning or something
    end
    if _targetplayer ~= nil then
        ReleaseStranger(_targetplayer)
        ResetSpawn()
    else
        TargetLost()
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------


function self:OnPostInit()
    if _worldsettingstimer:TimerExists(TIMERNAME) then
	return
    end
    _spawndelay = TUNING.TOTAL_DAY_TIME*GetRandomMinMax(1, 2)
    _worldsettingstimer:AddTimer(TIMERNAME, _spawndelay, true, OnTiddleStrangerTimerDone)
    print("William Stranger Timer")
    TryStartSpawn()
end

function self:OnUpdate(dt)
    local timetospawn = _worldsettingstimer:GetTimeLeft(TIMERNAME)
    if not timetospawn then
        ResetSpawn()
        return
    end
end

function self:LongUpdate(dt)
	self:OnUpdate(dt)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

self.inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
self.inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

end)
