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

local SDFLifebottle_4 = Class(function (self,inst)
    self.inst=inst
    self.max = TUNING.SDF_LIFEBOTTLE_HEALTH_MAX
    self.current= 0
    local period = 1
    self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, 0)
end,
nil,
{
    max = onmax,
    current = oncurrent,
})

function SDFLifebottle_4:OnSave()
	return {
		current = self.current,
		max = self.max,
	}
end

function SDFLifebottle_4:OnLoad(data)
        if data.current ~= nil and self.current ~= data.current then
		self.current = data.current
		self.max = data.max
        self:DoDelta(0)
    end
end

function SDFLifebottle_4:GetPercent()
    return self.current / self.max
end

function SDFLifebottle_4:GetCurrent()
    return self.current
end

function SDFLifebottle_4:SetPercent(p, overtime)
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("sdf_lifebottle_4_delta", { oldpercent = old / self.max, newpercent = p, overtime = overtime })
end

function SDFLifebottle_4:DoDelta(delta, overtime)
    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)
    self.inst:PushEvent("sdf_lifebottle_4_delta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime, delta = self.current-old })
end

return SDFLifebottle_4