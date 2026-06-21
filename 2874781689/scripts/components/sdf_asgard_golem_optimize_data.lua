local SDFAsgard_Optimize_Data = Class(function (self,inst)
    self.inst=inst
    self.od_typeA = false
    self.od_typeC = false
end)

function SDFAsgard_Optimize_Data:GetODTypeAInstalled()
    return self.od_typeA
end

function SDFAsgard_Optimize_Data:GetODTypeCInstalled()
    return self.od_typeC
end

function SDFAsgard_Optimize_Data:SetODTypeAInstalled()
    self.od_typeA = true
end

function SDFAsgard_Optimize_Data:SetODTypeCInstalled()
    self.od_typeC = true
end

function SDFAsgard_Optimize_Data:OnSave()
    return{
	    od_typeA=self.od_typeA,
	    od_typeC=self.od_typeC,
    }
end

function SDFAsgard_Optimize_Data:OnLoad(data)
    if data.od_typeA ~= nil and self.od_typeA ~= data.od_typeA then
	self.od_typeA = data.od_typeA or false
    end
    if data.od_typeC ~= nil and self.od_typeC ~= data.od_typeC then
	self.od_typeC = data.od_typeC or false
    end
end

return SDFAsgard_Optimize_Data