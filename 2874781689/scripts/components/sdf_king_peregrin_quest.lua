local SDFKing_Peregrin_Quest = Class(function (self,inst)
    self.inst=inst
    self.crown_found = false
    self.crown_offered = false
    self.shadow_artefact_offered = false
    self.shadow_talisman_found = false
    self.shadow_talisman_offered = false
end)

function SDFKing_Peregrin_Quest:GetCrownFoundStatus()
    return self.crown_found
end

function SDFKing_Peregrin_Quest:GetCrownOfferedStatus()
    return self.crown_offered
end

function SDFKing_Peregrin_Quest:GetShadowArtefactOfferedStatus()
    return self.shadow_artefact_offered
end

function SDFKing_Peregrin_Quest:GetShadowTalismanFoundStatus()
    return self.shadow_talisman_found
end

function SDFKing_Peregrin_Quest:GetShadowTalismanOfferedStatus()
    return self.shadow_talisman_offered
end


function SDFKing_Peregrin_Quest:SetCrownFoundStatus()
    self.crown_found = true
end

function SDFKing_Peregrin_Quest:SetCrownOfferedStatus()
    self.crown_offered = true
end

function SDFKing_Peregrin_Quest:SetShadowArtefactOfferedStatus()
    self.shadow_artefact_offered = true
end

function SDFKing_Peregrin_Quest:SetShadowTalismanFoundStatus()
    self.shadow_talisman_found = true
end

function SDFKing_Peregrin_Quest:SetShadowTalismanOfferedStatus()
    self.shadow_talisman_offered = true
end


function SDFKing_Peregrin_Quest:OnSave()
    return{
	    crown_found=self.crown_found,
	    crown_offered=self.crown_offered,
	    shadow_artefact_offered=self.shadow_artefact_offered,
	    shadow_talisman_offered=self.shadow_talisman_found,
	    shadow_talisman_offered=self.shadow_talisman_offered,
    }
end

function SDFKing_Peregrin_Quest:OnLoad(data)
    if data.crown_found ~= nil and self.crown_found ~= data.crown_found then
	self.crown_found = data.crown_found or false
    end
    if data.crown_offered ~= nil and self.crown_offered ~= data.crown_offered then
	self.crown_offered = data.crown_offered or false
    end
    if data.shadow_artefact_offered ~= nil and self.shadow_artefact_offered ~= data.shadow_artefact_offered then
	self.shadow_artefact_offered = data.shadow_artefact_offered or false
    end
    if data.shadow_talisman_found ~= nil and self.shadow_talisman_found ~= data.shadow_talisman_found then
	self.shadow_talisman_found = data.shadow_talisman_found or false
    end
    if data.shadow_talisman_offered ~= nil and self.shadow_talisman_offered ~= data.shadow_talisman_offered then
	self.shadow_talisman_offered = data.shadow_talisman_offered or false
    end
end

return SDFKing_Peregrin_Quest