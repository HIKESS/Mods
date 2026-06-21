local SDFShadow_Talisman_Buffs = Class(function(self, inst)
    self.inst = inst

    self.owner = nil
    self.nightvision_active = false
    self.nightvision_watching = false
    self.nightvision_task = nil
end)

function SDFShadow_Talisman_Buffs:SetOwner(owner)
    if owner ~= nil then
	self.owner = owner
    end
end

function SDFShadow_Talisman_Buffs:RemoveOwner()
    self.owner = nil
end

function SDFShadow_Talisman_Buffs:ApplyBuffs(active)
    if self.owner ~= nil then

	local damagebonus = self.owner.components.damagetypebonus
	local damageresist = self.owner.components.damagetyperesist

	--attack vs lunar
	if damagebonus then
	    if active then
		damagebonus:AddBonus("lunar_aligned", self.owner, TUNING.SDF_SHADOW_TALISMAN_BUFF_LUNAR_VS_BONUS, "sdf_shadow_talisman_attack")
	    else
		damagebonus:RemoveBonus("lunar_aligned", self.owner, "sdf_shadow_talisman_attack")
	    end
	end

	--defense vs lunar
	if damagebonus then
	    if active then
		damageresist:AddResist("lunar_aligned", self.owner, TUNING.SDF_SHADOW_TALISMAN_BUFF_LUNAR_RESIST_BONUS, "sdf_shadow_talisman_defense")
	    else
		damageresist:RemoveResist("lunar_aligned", self.owner, "sdf_shadow_talisman_defense")
	    end
	end

	self:NightVisionWatcher()
    end
end

function SDFShadow_Talisman_Buffs:RemoveBuffs()
    if self.owner ~= nil then
	local damagebonus = self.owner.components.damagetypebonus
	local damageresist = self.owner.components.damagetyperesist
    end

    local buff_removed = false
    
    if self.nightvision_active then
        self.nightvision_active = false
        self:UpdateNightVisionWatchers()
        buff_removed = true
    end
    
    if buff_removed then
        self:ApplyBuffs(false)
    end

    self:RemoveOwner()
end

function SDFShadow_Talisman_Buffs:InPocket(owner)
    self:SetOwner(owner)
    local success = false
    
    if self.nightvision_active == false then
        self.nightvision_active = true
        self:UpdateNightVisionWatchers()
        success = true
    end

    if success then
        self:ApplyBuffs(true)
    end
end

-- Night Vision Helpers
function SDFShadow_Talisman_Buffs:SetNightVision(active)
    if self.owner ~= nil then
	if not self.owner.components then
	    return
	end

	local playervision = self.owner.components.playervision
	local grue = self.owner.components.grue

	--adjust sanity cost
	self.inst.active = active

	--night vision
	if playervision then
	    if active then
		if not self.owner.sdf_shadowtalismanvision:value() then
		    self.owner.sdf_shadowtalismanvision:set(true)
		end
	    else
		self.owner.sdf_shadowtalismanvision:set(false)
	    end
	end

	--grue immunity
	if grue then
	    if active then
		grue:AddImmunity("sdf_shadow_talisman_nightvision")
	    else
		grue:RemoveImmunity("sdf_shadow_talisman_nightvision")
	    end
	end
    end
end

function SDFShadow_Talisman_Buffs:NightVisionFader(owner)
    if owner ~= nil then
	local isDark = false

	if owner.LightWatcher then
	    isDark = owner.LightWatcher:GetLightValue() < (0.1)
	end

	if isDark then
	    return true
	end
    end
    return false
end

function SDFShadow_Talisman_Buffs:NightVisionWatcher()
    if self.nightvision_active then
        if self.owner ~= nil and self.owner:HasTag("player") then
	    self:SetNightVision(self:NightVisionFader(self.owner))
	else
	    self:SetNightVision(false)
	end
    else
        self:SetNightVision(false)
    end
end

function SDFShadow_Talisman_Buffs:UpdateNightVisionWatchers()
    if self.nightvision_active and self.nightvision_task == nil then
	if self.owner ~= nil then
	    self.nightvision_task = self.owner:DoPeriodicTask(0.5, function() self:NightVisionWatcher() end)
	end
    elseif not self.nightvision_active and self.nightvision_task ~= nil then
	self.nightvision_task:Cancel()
	self.nightvision_task = nil
    end
    self:NightVisionWatcher()
end

return SDFShadow_Talisman_Buffs