local SDFChalice_Counter = Class(function (self,inst)
    self.inst=inst
    self.maxchalicecount=TUNING.SDF_CHALICE_OF_SOUL_MAX
    self.usedchalicecount=0
    self.collectedchalicecount=0
end)


function SDFChalice_Counter:SetUsedChaliceCount(val)
    self.usedchalicecount=val
end

function SDFChalice_Counter:SetCollectedChaliceCount(val)
    self.collectedchalicecount=val
end

function SDFChalice_Counter:GetMaxChaliceCount()
     return self.maxchalicecount
end

function SDFChalice_Counter:GetUsedChaliceCount()
     return self.usedchalicecount
end

function SDFChalice_Counter:GetCollectedChaliceCount()
     return self.collectedchalicecount
end

function SDFChalice_Counter:OnSave()
    return{
	    usedchalicecount=self.usedchalicecount,
	    collectedchalicecount=self.collectedchalicecount,
    }
end

function SDFChalice_Counter:OnLoad(data)
    if data.usedchalicecount ~= nil and self.usedchalicecount ~= data.usedchalicecount then
	self.usedchalicecount = data.usedchalicecount or 0
    end
    if data.collectedchalicecount ~= nil and self.collectedchalicecount ~= data.collectedchalicecount then
	self.collectedchalicecount = data.collectedchalicecount or 0
    end
end

return SDFChalice_Counter