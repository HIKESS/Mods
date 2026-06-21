--V2C: ughh, needs some serious refactoring, but won't bother now.
--     whatever you do, do NOT base any new files off of this one.

local function generatefreepositions(max)
    local pos_table = {}
    for num = 1, max do
        table.insert(pos_table, num)
    end
    return pos_table
end

local function _startnextspawn(inst, self)
    self:StartNextSpawn()
end

local POS_MODIFIER = 2.4 --2.4 

local DEFAULT_VALID_TILE_TYPES =
{
    [WORLD_TILES.ROAD] = true,
    [WORLD_TILES.ROCKY] = true,
    [WORLD_TILES.DIRT] = true,
    [WORLD_TILES.SAVANNA] = true,
    [WORLD_TILES.GRASS] = true,
    [WORLD_TILES.FOREST] = true,
    [WORLD_TILES.MARSH] = true,
    [WORLD_TILES.WOODFLOOR] = true,
    [WORLD_TILES.CARPET] = true,
    [WORLD_TILES.CHECKER] = true,
    [WORLD_TILES.QUAGMIRE_SOIL] = true,

    -- CAVES
    [WORLD_TILES.CAVE] = true,
    [WORLD_TILES.FUNGUS] = true,
    [WORLD_TILES.SINKHOLE] = true,
    [WORLD_TILES.UNDERROCK] = true,
    [WORLD_TILES.MUD] = true,
}

local SDFPumpking_Gourd_Vine_Spawner = Class(function(self, inst)
    self.inst = inst
    self.miniontype = "sdf_pumpking_gourd_vine"
    self.maxminions = 4
    self.maxminionspool = 8
    self.minionspawntime = { min = 5, max = 10 }
    self.minions = {}
    self.numminions = 0
    self.distancemodifier = 6
    self.onspawnminionfn = nil
    self.onlostminionfn = nil
    self.onminionattacked = nil
    self.onminionattack = nil
    self.spawninprogress = false
    self.nextspawninfo = {}
    self.canspawn = true
    self.shouldspawn = true
    self.spawntime = 0
    self.minionpositions = nil
    self.validtiletypes = DEFAULT_VALID_TILE_TYPES
    self.freepositions = generatefreepositions(self.maxminionspool * POS_MODIFIER)
    self.inst:DoTaskInTime(1, _startnextspawn, self)

    self._onminionattacked = function(minion) self.onminionattacked(self.inst) end
    self._onminionattack = function(minion) self.onminionattack(self.inst) end
    self._onminiondeath = function(minion)
        minion:PushEvent("attacked")
        self:OnLostMinion(minion)
    end
    self._onminionremoved = function(minion)
        self:OnLostMinion(minion)
    end
end)

function SDFPumpking_Gourd_Vine_Spawner:SetMinionType(minionType)
    self.miniontype = minionType
end 

function SDFPumpking_Gourd_Vine_Spawner:SetMaxMinion(num)
    self.maxminions = num
end 

function SDFPumpking_Gourd_Vine_Spawner:SetMaxMinionPool(num)
    self.maxminionspool = num
end 

function SDFPumpking_Gourd_Vine_Spawner:SetDistanceModifier(num)
    self.distancemodifier = num
end 

function SDFPumpking_Gourd_Vine_Spawner:SetSpawnTime(num)
    self.spawntime = num
end 

function SDFPumpking_Gourd_Vine_Spawner:SetCanSpawn(boolen)
    self.canspawn = boolen
end 

function SDFPumpking_Gourd_Vine_Spawner:SetMinionSpawnTime(num)
    self.minionspawntime = num
end 

function SDFPumpking_Gourd_Vine_Spawner:GetDebugString()
    return string.format(
        "Num Minions: %d, Spawn In Progress: %s, Time For Spawn: %2.2f, Should Spawn: %s",
        self.numminions,
        tostring(self.spawninprogress),
        self.nextspawninfo.time or -1,
        tostring(self.shouldspawn)
    )
end

function SDFPumpking_Gourd_Vine_Spawner:RemovePosition(num)
    for i, v in ipairs(self.freepositions) do
        if v == num then
            table.remove(self.freepositions, i)
            return
        end
    end
end

function SDFPumpking_Gourd_Vine_Spawner:AddPosition(num, tbl)
    tbl = tbl or self.freepositions
    for i, v in ipairs(tbl) do
        if v == num then
            return
        elseif v < num then
            table.insert(tbl, i, num)
            return
        end
    end
end

local function SerializePositions(tbl)
    local ret = {}
    for i, v in ipairs(tbl) do
        table.insert(ret, { x = v.x, z = v.z })
    end
    return ret
end

local function DeserializePositions(data)
    local ret = {}
    for i, v in ipairs(data) do
        table.insert(ret, Vector3(v.x, 0, v.z))
    end
    return ret
end

function SDFPumpking_Gourd_Vine_Spawner:OnSave()
    local data = {}
    --[[local guidtable = {}
    for k, v in pairs(self.minions) do
        table.insert(data, { GUID = v.GUID, NUMBER = v.minionnumber })
        table.insert(guidtable, v.GUID)
    end]]

    --[[if #data > 0 then
        data = { minions = data }
    end]]

    data.maxminions = self.maxminions

    --[[if self.minionpositions ~= nil then
        data.minionpositions = SerializePositions(self.minionpositions)
    end]]

    if self.spawninprogress then
        data.spawninprogress = self.spawninprogress
        data.timeuntilspawn = math.max(1, math.ceil(self.nextspawninfo.start + self.nextspawninfo.time - GetTime()))
    end

    return data --, guidtable
end

function SDFPumpking_Gourd_Vine_Spawner:OnLoad(data)
    if data.maxminions ~= nil then
        self.maxminions = data.maxminions
    end
    --[[if data.minionpositions ~= nil then
        self.minionpositions = DeserializePositions(data.minionpositions)
    end]]
    if data.spawninprogress then
        self:ResumeSpawn(data.timeuntilspawn)
    end
end

--[[function SDFPumpking_Gourd_Vine_Spawner:LoadPostPass(newents, savedata)
    if savedata.minions ~= nil then
        for i, v in ipairs(savedata.minions) do
            local minion = newents[v.GUID]
            if minion ~= nil then
                minion = minion.entity
                minion.minionnumber = v.NUMBER
                self:TakeOwnership(minion)
                local pos = self:GetSpawnLocation(minion.minionnumber)
                if pos ~= nil then
                    if minion.Physics ~= nil then
                        minion.Physics:Teleport(pos:Get())
                    else
                        minion.Transform:SetPosition(pos:Get())
                    end
                    self:RemovePosition(minion.minionnumber)
                end
            end
        end
    end
end]]

function SDFPumpking_Gourd_Vine_Spawner:TakeOwnership(minion)
    if self.minions[minion] ~= nil then
        return
    end

    self.minions[minion] = minion
    self.numminions = self.numminions + 1
    minion.minionlord = self.inst
    if minion.minionnumber == nil then
        minion.minionnumber = self.freepositions[math.random(#self.freepositions)]
    end

    if self.onminionattacked ~= nil then
        self.inst:ListenForEvent("attacked", self._onminionattacked, minion)
    end
    if self.onminionattack ~= nil then
        self.inst:ListenForEvent("onattackother", self._onminionattack, minion)
    end
    self.inst:ListenForEvent("death", self._onminiondeath, minion)
    self.inst:ListenForEvent("onremove", self._onminionremoved, minion)

    self.inst:PushEvent("minionchange")
end

--NOTE: tbl is cached because freepositions may be regenerated
local function OnRecyclePosition(inst, self, num, tbl)
    self:AddPosition(num, tbl)

    if self.numminions == 0 then
	self.freepositions = generatefreepositions(self.maxminionspool * POS_MODIFIER)
	self.shouldspawn = true
	self.spawninprogress = false
    end

    if self.shouldspawn and self.canspawn and not self:MaxedMinions() then
	self.shouldspawn = true
        self:StartNextSpawn()
   end
end

function SDFPumpking_Gourd_Vine_Spawner:OnLostMinion(minion)
    if self.minions[minion] == nil then
        return
    end

    self.minions[minion] = nil
    self.numminions = self.numminions - 1

    self.inst:RemoveEventCallback("attacked", self._onminionattacked, minion)
    self.inst:RemoveEventCallback("onattackother", self._onminionattack, minion)
    self.inst:RemoveEventCallback("death", self._onminiondeath, minion)
    self.inst:RemoveEventCallback("onremove", self._onminionremoved, minion)

    self.inst:DoTaskInTime(3, OnRecyclePosition, self, minion.minionnumber, self.freepositions)

    self.inst:PushEvent("minionchange")
end

function SDFPumpking_Gourd_Vine_Spawner:MakeMinion()
    if self.miniontype ~= nil and not self:MaxedMinions() then
	return SpawnPrefab(self.miniontype)
    end
end

function SDFPumpking_Gourd_Vine_Spawner:CheckTileCompatibility(tile)
    return self.validtiletypes[tile]
end

local MINION_TAGS = { "sdf_pumpking_friend" }
function SDFPumpking_Gourd_Vine_Spawner:MakeSpawnLocations()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ground = TheWorld
    local maxpositions = self.maxminionspool * POS_MODIFIER
    local useablepositions = {}
    for i = 1, 100 do
        local s = i / 32--(num/2) -- 32.0
        local a = math.sqrt(s * 512)
        local b = math.sqrt(s) * self.distancemodifier
        local pos = Vector3(x + math.sin(a) * b, 0, z + math.cos(a) * b)
        if ground.Map:IsAboveGroundAtPoint(pos:Get()) and
            self:CheckTileCompatibility(ground.Map:GetTileAtPoint(pos:Get())) and
            ground.Pathfinder:IsClear(x, 0, z, pos.x, 0, pos.z, { ignorewalls = true }) and
            #TheSim:FindEntities(pos.x, pos.y, pos.z, 2.5, MINION_TAGS) <= 0 and
            #TheSim:FindEntities(pos.x, pos.y, pos.z, 1) <= 0 and
            not ground.Map:IsPointNearHole(pos) then
            table.insert(useablepositions, pos)
            if #useablepositions >= maxpositions then
                return useablepositions
            end
        end
    end

    --if it couldn't find enough spots for minions.
    if not self:MaxedMinions() then
	self.freepositions = generatefreepositions(self.maxminionspool)
    end

    return #useablepositions > 0 and useablepositions or nil
end

function SDFPumpking_Gourd_Vine_Spawner:GetSpawnLocation(num)
    if self.minionpositions == nil then
        return
    end

    local pos = self.minionpositions[num]
    return pos ~= nil
        and self:CheckTileCompatibility(TheWorld.Map:GetTileAtPoint(pos:Get()))
        and pos
        or nil
end

function SDFPumpking_Gourd_Vine_Spawner:GetNextSpawnTime()
    return GetRandomMinMax(self.minionspawntime.min, self.minionspawntime.max)
end

local function OnKillMinion(inst, minion)
    if minion:IsValid() and not minion.components.health:IsDead() then
        minion.components.health:Kill()
    end
end

function SDFPumpking_Gourd_Vine_Spawner:KillAllMinions()
    self.spawninprogress = false
    for k, v in pairs(self.minions) do
        self.inst:DoTaskInTime(math.random(), OnKillMinion, v)
    end
end

function SDFPumpking_Gourd_Vine_Spawner:SpawnNewMinion()
    if self.minionpositions == nil then
        self.minionpositions = self:MakeSpawnLocations()
        if self.minionpositions == nil then
            return
        end
    end

    if self.shouldspawn and self.canspawn and not self:MaxedMinions() and #self.freepositions > 0 then
        self.spawninprogress = false

        local num = self.freepositions[math.random(#self.freepositions)]
        local pos = self:GetSpawnLocation(num)
        if pos ~= nil and not self:MaxedMinions() then
            local minion = self:MakeMinion()
            if minion ~= nil then

                --minion.sg:GoToState("spawn")
                minion.minionnumber = num
                self:TakeOwnership(minion)
                minion.Transform:SetPosition(pos:Get())
                self:RemovePosition(num)

                if self.onspawnminionfn ~= nil then
                    self.onspawnminionfn(self.inst, minion)
                end
            end
        elseif self.miniontype ~= nil and not self:MaxedMinions() then
            self.minionpositions = self:MakeSpawnLocations()
        end

        if self.shouldspawn and self.canspawn and not self:MaxedMinions() then
            self:StartNextSpawn()
        end
    end
end

function SDFPumpking_Gourd_Vine_Spawner:MaxedMinions()
    return self.numminions >= self.maxminions
end

function SDFPumpking_Gourd_Vine_Spawner:SetSpawnInfo(time)
    self.nextspawninfo = { start = GetTime(), time = time }
    return time
end

local function OnSpawnNewMinion(inst, self)
    self:SpawnNewMinion()
end

function SDFPumpking_Gourd_Vine_Spawner:StartNextSpawn()
    if self.shouldspawn and self.canspawn and not (self.spawninprogress or self:MaxedMinions()) then
        self.spawninprogress = true
        self.task = self.inst:DoTaskInTime(self:SetSpawnInfo(self:GetNextSpawnTime()), OnSpawnNewMinion, self)
    end
end

function SDFPumpking_Gourd_Vine_Spawner:ResumeSpawn(time)
    self.spawninprogress = true
    self.task = self.inst:DoTaskInTime(self:SetSpawnInfo(math.max(1, time)), OnSpawnNewMinion, self)
end

local function useuptime(self, time)
    local iterations = 0
    while time > 0 do
        time = time - self:GetNextSpawnTime()
        iterations = iterations + 1
    end
    return iterations
end

function SDFPumpking_Gourd_Vine_Spawner:LongUpdate(dt)
    if self.spawninprogress and self.shouldspawn and self.canspawn then
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end

        local possiblespawns = useuptime(self, dt)
        for i = 1, possiblespawns do
            if self.task ~= nil then
                self.task:Cancel()
                self.task = nil
            end
            self:SpawnNewMinion()
        end
    end
end

return SDFPumpking_Gourd_Vine_Spawner
