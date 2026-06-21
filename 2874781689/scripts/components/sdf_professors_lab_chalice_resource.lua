local function onmax(self, max)
end

local SDFProfessorsLabChalice_Resource = Class(function (self,inst)
    self.inst=inst
    self.max = TUNING.SDF_PROFESSORS_LAB_CHALICE_RESOURCE_MAX
    self.current= 0
    local period = 1
end)

function SDFProfessorsLabChalice_Resource:OnSave()
	return {
		current = self.current,
		max = self.max,
	}
end

function SDFProfessorsLabChalice_Resource:OnLoad(data)
        if data.current ~= nil and self.current ~= data.current then
		self.current = data.current
		self.max = data.max
        self:DoDelta(0)
    end
end

function SDFProfessorsLabChalice_Resource:GetPercent()
    return self.current / self.max
end

function SDFProfessorsLabChalice_Resource:GetCurrent()
    return self.current
end

function SDFProfessorsLabChalice_Resource:SetPercent(p, overtime)
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("sdf_professors_lab_chalice_resource_delta", { oldpercent = old / self.max, newpercent = p, overtime = overtime })
end

function SDFProfessorsLabChalice_Resource:DoDelta(delta, overtime)
    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)
    self.inst:PushEvent("sdf_professors_lab_chalice_resource_delta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime, delta = self.current-old })
end

return SDFProfessorsLabChalice_Resource