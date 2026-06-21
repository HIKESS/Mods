local SDFCane_Stick_Gem_Holder = Class(function (self,inst)
    self.inst=inst
    self.socketGem= nil
    self.socketType= "empty"
    self.socketStimuli= nil
end)


function SDFCane_Stick_Gem_Holder:SetSocket(gem, gemType, gemStimuli)
    self.socketGem=gem
    self.socketType=gemType
    self.socketStimuli=gemStimuli
end

function SDFCane_Stick_Gem_Holder:GetSocketGem()
     return self.socketGem
end

function SDFCane_Stick_Gem_Holder:GetSocketType()
     return self.socketType
end

function SDFCane_Stick_Gem_Holder:GetSocketStimuli()
     return self.socketStimuli
end

function SDFCane_Stick_Gem_Holder:OnSave()
    return{
	    socketGem=self.socketGem,
	    socketType=self.socketType,
	    socketStimuli=self.socketStimuli,
    }
end

function SDFCane_Stick_Gem_Holder:OnLoad(data)
    if data.socketGem ~= nil and self.socketGem ~= data.socketGem then
	self.socketGem = data.socketGem or nil
    end
    if data.socketType ~= nil and self.socketType ~= data.socketType then
	self.socketType = data.socketType or "empty"
    end
    if data.socketStimuli ~= nil and self.socketStimuli ~= data.socketStimuli then
	self.socketStimuli = data.socketStimuli or nil
    end
end

return SDFCane_Stick_Gem_Holder