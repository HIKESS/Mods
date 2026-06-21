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

local SDFHealthfountain_Resource = Class(function (self,inst)
    self.inst=inst
    self.max = TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX
    self.current= self.max
    local period = 1
    self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, 0)
end,
nil,
{
    max = onmax,
    current = oncurrent,
})

function SDFHealthfountain_Resource:OnSave()
	return {
		current = self.current,
		max = self.max,
	}
end

function SDFHealthfountain_Resource:OnLoad(data)
        if data.current ~= nil and self.current ~= data.current then
		self.current = data.current
		self.max = data.max
        self:DoDelta(0)
    end
end

function SDFHealthfountain_Resource:GetPercent()
    return self.current / self.max
end

function SDFHealthfountain_Resource:GetCurrent()
    return self.current
end

function SDFHealthfountain_Resource:SetPercent(p, overtime)
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("sdf_healthfountain_resource_delta", { oldpercent = old / self.max, newpercent = p, overtime = overtime })
end

function SDFHealthfountain_Resource:DoDelta(delta, overtime)
    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)
    self.inst:PushEvent("sdf_healthfountain_resource_delta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime, delta = self.current-old })
end

return SDFHealthfountain_Resource