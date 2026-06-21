local SDFAsgard_Golem_Beckon = Class(function(self, inst)
    self.inst = inst
    self.gKnightList = {}
    self.gKnights = {}
    self:Setup()
end)

local function getFloorSpawnPoint(inst, dist)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local theta = math.random() * 2 * PI
    local radius = 8
    local offset = FindWalkableOffset(pt, theta, dist or radius, 12, true)
    if offset then
        local pos = pt + offset
        if TheWorld.Map:IsPassableAtPoint(pos.x, pos.y, pos.z) then return pos end
    end
    return nil
end

local function gatherAllTourist(inst)
    for follower,_ in pairs(inst.components.leader.followers) do
        for prefab,_ in pairs(inst.components.sdf_asgard_golem_beckon.gKnightList) do
            if follower.prefab == prefab then

		inst:DoTaskInTime(0.1, function()
                    inst.components.sdf_asgard_golem_beckon:GatherNearPlayer(inst, follower, 4)
                    follower:PushEvent("sdf_king_peregrins_crown_calltoarms")
		end)   
            end
        end
    end
end

function SDFAsgard_Golem_Beckon:Setup()
    local inst = self.inst

    --inst:ListenForEvent("sdf_king_peregrins_crown_calltoarms", gatherAllTourist)

    local old_OnSave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_OnSave then old_OnSave(inst, data) end
        inst.components.sdf_asgard_golem_beckon:inst_OnSave(inst, data)
    end 

    local old_OnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_OnLoad then old_OnLoad(inst, data) end
        inst.components.sdf_asgard_golem_beckon:inst_OnLoad(inst, data)
    end   

    local old_RemoveAllFollowers = inst.components.leader.RemoveAllFollowers
    function inst.components.leader:RemoveAllFollowers()
        self.inst.components.sdf_asgard_golem_beckon:BackupTourists(self.followers)
        old_RemoveAllFollowers(self)
    end
end

function SDFAsgard_Golem_Beckon:BackupTourists(followers)
    self.gKnights = {}
    for follower,valid in pairs(followers) do
        if valid then
            for prefab,_ in pairs(self.gKnightList) do
                if follower.prefab == prefab then
                    self.gKnights[follower] = true
                    break
                end
            end
        end
    end
end

function SDFAsgard_Golem_Beckon:AddPrefabToList(prefab)
    self.gKnightList[prefab] = true
end

function SDFAsgard_Golem_Beckon:SaveTourist(tourist, data)
    if data then
        data.gKnights = data.gKnights or {}
        local record = tourist:GetSaveRecord() or nil
        table.insert(data.gKnights, record)
    end
end

function SDFAsgard_Golem_Beckon:GatherNearPlayer(inst, tourist, dist)
    if not tourist then return end

    local pos = getFloorSpawnPoint(inst, dist) or Point(inst.Transform:GetWorldPosition())
    tourist.Physics:Teleport(pos.x, pos.y, pos.z) --x,y,z
end

function SDFAsgard_Golem_Beckon:LoadTourist(record)
    local inst = self.inst
    local tourist = SpawnSaveRecord(record) or nil
    if tourist and tourist:IsValid() then
        self.GatherNearPlayer(inst, tourist)
        inst.components.leader:AddFollower(tourist)
    end
end

function SDFAsgard_Golem_Beckon:inst_OnSave(inst, data)
    for tourist,_ in pairs(self.gKnights) do
        self:SaveTourist(tourist, data)
    end
end

function SDFAsgard_Golem_Beckon:inst_OnLoad(inst, data)
    if data and data.gKnights then
        for k,record in pairs(data.gKnights) do
            inst:DoTaskInTime(0.5, function() self:LoadTourist(record) end)
        end
    end
end

function SDFAsgard_Golem_Beckon:DespawnAllTourist()
    for tourist,_ in pairs(self.gKnights) do
        tourist:Remove()
    end
end

SDFAsgard_Golem_Beckon.OnRemoveEntity = SDFAsgard_Golem_Beckon.DespawnAllTourist

return SDFAsgard_Golem_Beckon