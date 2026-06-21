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

local SDFSuperarmor = Class(function (self,inst)
    self.inst=inst
    self.max = TUNING.SDF_SUPERARMOR_MAX
    self.current= self.max
    self.gold_armor_id = 0
    local period = 1
    self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, 0)
end,
nil,
{
    max = onmax,
    current = oncurrent,
})

function SDFSuperarmor:OnSave()
	return {
		current = self.current,
		max = self.max,
		gold_armor_id=self.gold_armor_id,
	}
end

function SDFSuperarmor:OnLoad(data)
    if data.current ~= nil and self.current ~= data.current then
	self.current = data.current
	self.max = data.max
        self:DoDelta(0)
    end
    if data.gold_armor_id ~= nil and self.gold_armor_id ~= data.gold_armor_id then
	self.gold_armor_id = data.gold_armor_id or 0
    end
end

function SDFSuperarmor:GetPercent()
    return self.current / self.max
end

function SDFSuperarmor:GetCurrent()
    return self.current
end

function SDFSuperarmor:SetPercent(p, overtime)
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("sdf_superarmor_delta", { oldpercent = old / self.max, newpercent = p, overtime = overtime })
end

function SDFSuperarmor:DoDelta(delta, overtime)
    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)
    self.inst:PushEvent("sdf_superarmor_delta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime, delta = self.current-old })
end

function SDFSuperarmor:CheckGoldArmorId()
    return self.gold_armor_id
end

function SDFSuperarmor:SetGoldArmorId(val)
    self.gold_armor_id = val
end

return SDFSuperarmor