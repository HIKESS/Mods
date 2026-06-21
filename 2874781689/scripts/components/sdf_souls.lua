local function onmax(self, max)
end

local function oncurrent(self, current)
end

local function OnTaskTick(inst, self, period)
	self:DoDelta(period)
	if(self.current > self.max) then
		self.current = self.max
	end
end

local SDFSouls = Class(function (self,inst)
    self.inst=inst
    self.max = 100
    self.current= 0
    self.chaliceready = false
    local period = 1
    self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, 0)
end,
nil,
{
    max = onmax,
    current = oncurrent,
})

function SDFSouls:OnSave()
	return {
		current = self.current,
		max = self.max,
	}
end

function SDFSouls:OnLoad(data)
        if data.current ~= nil and self.current ~= data.current then
		self.current = data.current
		self.max = 100
        self:DoDelta(0)
    end
end

function SDFSouls:GetChaliceReady()
    return self.chaliceready
end

function SDFSouls:SetChaliceReady()
    self.chaliceready = true
end

function SDFSouls:GetPercent()
    return self.current / self.max
end

function SDFSouls:SetPercent(p, overtime)
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("sdf_soulsdelta", { oldpercent = old / self.max, newpercent = p, overtime = overtime })
end

function SDFSouls:DoDelta(delta, overtime)
    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)
    self.inst:PushEvent("sdf_soulsdelta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime, delta = self.current-old })
end

return SDFSouls