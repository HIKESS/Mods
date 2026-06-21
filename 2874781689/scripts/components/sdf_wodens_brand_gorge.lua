local SDFWodens_Brand_Gorge = Class(function (self,inst)
    self.inst=inst
    self.consumeValue=0
end)

function SDFWodens_Brand_Gorge:SetConsumeValue(val)
    self.consumeValue=val
end

function SDFWodens_Brand_Gorge:GetConsumeValue(val)
    return self.consumeValue
end

function SDFWodens_Brand_Gorge:OnSave()
    return{consumeValue=self.consumeValue}
end

function SDFWodens_Brand_Gorge:OnLoad(data)
    self.consumeValue=data and data.consumeValue or 0
end

return SDFWodens_Brand_Gorge