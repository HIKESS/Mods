local SDFTime_Rune_Epoch = Class(function (self,inst)
    self.inst = inst
    self.targetHoHRune = nil
    self.extraTeleport = false
end)

function SDFTime_Rune_Epoch:RecordingLocation(target)
    self.targetHoHRune = Vector3(target.Transform:GetWorldPosition())
end

function SDFTime_Rune_Epoch:HasLocation()
    if self.targetHoHRune ~= nil then
        return true
    end

    return false
end

function SDFTime_Rune_Epoch:GetLocationPoint()
    return self.targetHoHRune
end

function SDFTime_Rune_Epoch:SetExtraTeleport(boolen)
    self.extraTeleport = boolen
end

function SDFTime_Rune_Epoch:GetExtraTeleport()
    return self.extraTeleport
end

function SDFTime_Rune_Epoch:OnSave()
    return{
        targetHoHRune = self.targetHoHRune,
	extraTeleport = self.extraTeleport,
    }
end

function SDFTime_Rune_Epoch:OnLoad(data)
    if data.targetHoHRune ~= nil then
        self.targetHoHRune = data.targetHoHRune
    end
    if data.extraTeleport ~= nil then
        self.extraTeleport = data.extraTeleport
    end
end

return SDFTime_Rune_Epoch