local SDFChest_Regeneration = Class(function (self,inst)
    self.inst=inst
    self.maxregenerationcount= 15
    self.regenerationcount=0
end)


function SDFChest_Regeneration:SetRegenerationCount(val)
    self.regenerationcount=val
end

function SDFChest_Regeneration:SetMaxRegenerationCount(val)
     self.maxregenerationcount=val
end

function SDFChest_Regeneration:GetMaxRegenerationCount()
     return self.maxregenerationcount
end

function SDFChest_Regeneration:GetRegenerationCount()
     return self.regenerationcount
end

function SDFChest_Regeneration:OnSave()
    return{
	    regenerationcount=self.regenerationcount,
    }
end

function SDFChest_Regeneration:OnLoad(data)
    if data.regenerationcount ~= nil and self.regenerationcount ~= data.regenerationcount then
	self.regenerationcount = data.regenerationcount or 0
    end
end

return SDFChest_Regeneration