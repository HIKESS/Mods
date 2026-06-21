local function a(self)
    for b,c in ipairs({"task","timeout_task"}) do 
	if self[c] then
	    self[c]:Cancel()
	    self[c] = nil
	end
    end
end

local function d(e,f)
    local self = e.components.sdf_reticule_spawner
    a(self)
    self.task = self.ping:DoTaskInTime(self.time or 2,function()
	self:KillRet()
	self.task = nil
    end)
end

local SDFReticule_Spawner = Class(function(self,inst)
    self.inst = inst
    self.time = 2
    self.type = "aoe"
    self.ping = nil
    self.task = nil
end)

function SDFReticule_Spawner:Setup(h,i)
    self.type = h or"aoe"self.time = i or 2
end

function SDFReticule_Spawner:Spawn(j)
    if self.task then
	self.task:Cancel()
	self.task = nil
	self:KillRet()
    end
    self.ping = SpawnAt("reticule"..self.type,j)
    self.inst:ListenForEvent("aoe_casted",d)
    self.timeout_task = self.inst:DoTaskInTime(4,function()print("ReticuleSpawner: Timeouted!")
	self:Interrupt()
    end)
end

function SDFReticule_Spawner:KillRet()
    if self.ping then
	self.ping:KillFX()
	self.ping = nil
    end
    self.inst:RemoveEventCallback("aoe_casted",d)
end

function SDFReticule_Spawner:Interrupt()
    a(self)
    self:KillRet()
end

return SDFReticule_Spawner