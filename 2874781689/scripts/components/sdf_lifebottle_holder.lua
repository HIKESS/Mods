local SDFLifebottle_Holder = Class(function (self,inst)
    self.inst=inst
    self.lifebottle_holder = {false, false, false, false, false, false, false, false, false}

    --Hidden Life Bottles
    self.pumpkin_gorge_lifebottle_found = false
    self.asylum_grounds_lifebottle_found = false
end)


function SDFLifebottle_Holder:ObtainLifebottle(lifebottles, lifebottles_slot)
    lifebottles[lifebottles_slot] = true
end

function SDFLifebottle_Holder:GetLifebottleHolder()
     return self.lifebottle_holder
end

function SDFLifebottle_Holder:CheckSlot(lifebottles, lifebottles_slot)
    return lifebottles[lifebottles_slot]
end

function SDFLifebottle_Holder:CheckSlots(lifebottles)
    for i, v in ipairs(lifebottles) do
	if v == false then
	    return false
	end
    end
    return true
end


function SDFLifebottle_Holder:GetLifebottle(sdf, lifebottles_slot)
    if lifebottles_slot == 1 then return sdf.components.sdf_lifebottle_1 end
    if lifebottles_slot == 2 then return sdf.components.sdf_lifebottle_2 end
    if lifebottles_slot == 3 then return sdf.components.sdf_lifebottle_3 end
    if lifebottles_slot == 4 then return sdf.components.sdf_lifebottle_4 end
    if lifebottles_slot == 5 then return sdf.components.sdf_lifebottle_5 end
    if lifebottles_slot == 6 then return sdf.components.sdf_lifebottle_6 end
    if lifebottles_slot == 7 then return sdf.components.sdf_lifebottle_7 end
    if lifebottles_slot == 8 then return sdf.components.sdf_lifebottle_8 end
    if lifebottles_slot == 9 then return sdf.components.sdf_lifebottle_9 end
end


function SDFLifebottle_Holder:GetLifebottleAmountPercent(sdf, lifebottle)
    return lifebottle:GetPercent()
end

function SDFLifebottle_Holder:GetLifebottleAmountCurrent(sdf, lifebottle)
    return lifebottle:GetCurrent()
end

function SDFLifebottle_Holder:SetLifebottleAmountPercent(sdf, lifebottle, amount)
    return lifebottle:SetPercent(amount)
end

function SDFLifebottle_Holder:SetLifebottleAmountDoDelta(sdf, lifebottle, amount)
    return lifebottle:DoDelta(amount)
end

function SDFLifebottle_Holder:HealLifebottleAmount(sdf, amount) --not used
    return sdf.components.health:SetPercent((math.ceil(amount * 60))/60, true, "lifebottle") --percent
end

function SDFLifebottle_Holder:HealLifebottleAmountDoDelta(sdf, amount)
    return sdf.components.health:DoDelta(amount, false, "lifebottle") --Delta
end

function SDFLifebottle_Holder:HealEnergyvialAmount(sdf, amount) --not used
    return sdf.components.health:SetPercent(math.ceil(amount * 60), true, "energyvial") --percent
end

function SDFLifebottle_Holder:HealEnergyvialAmountDoDelta(sdf, amount)
    return sdf.components.health:DoDelta(amount, false, "energyvial") --Delta
end

function SDFLifebottle_Holder:HealFountainAmountDoDelta(sdf, amount)
    return sdf.components.health:DoDelta(amount, false, "healthfountain") --Delta
end

function SDFLifebottle_Holder:CheckCanHeal(sdf)
    --Check player health
    local health = sdf.components.health:GetPercent()
    if health < 1 then
	return true
    end

    --Check lifebottle fills
    local lifebottles = sdf.components.sdf_lifebottle_holder:GetLifebottleHolder()
    local filledBottles = self:GetLifebottleFirstFilledSlot(sdf, lifebottles)
    if filledBottles > 0 then
	return true
    end
    return false
end

function SDFLifebottle_Holder:CheckOverHeal(currentAmount, healAmount)
    local overHeal = 0
    local canHeal = (TUNING.SDF_HEALTH_MAX - currentAmount)

    if (healAmount - canHeal) > 0 then
	overHeal = (healAmount - canHeal)
    end
    return overHeal
end

function SDFLifebottle_Holder:GetLifebottleFirstFilledSlot(sdf, lifebottles)
    local lifebottleFilledFirstSlot = 0

    --Check for first Filled lifebottle
    for i, v in ipairs(lifebottles) do
	if v == true then
	    local tempLifebottle = self:GetLifebottle(sdf, i)
	    local tempLifebottleAmount = self:GetLifebottleAmountPercent(sdf, tempLifebottle)
	    if tempLifebottleAmount >= 0 and tempLifebottleAmount < 1 then
		lifebottleFilledFirstSlot = i
		return lifebottleFilledFirstSlot
	    end
	end
    end
    return lifebottleFilledFirstSlot
end

function SDFLifebottle_Holder:GetLifebottleLastFilledSlot(sdf, lifebottles)
    local lifebottleFilledLastSlot = 0

    --Check for last Filled lifebottle
    for i, v in ipairs(lifebottles) do
	if v == true then
	    local tempLifebottle = self:GetLifebottle(sdf, i)
	    local tempLifebottleAmount = self:GetLifebottleAmountPercent(sdf, tempLifebottle)
	    if tempLifebottleAmount > 0 and tempLifebottleAmount < 1 then
		lifebottleFilledLastSlot = i
	    end
	end
    end
    return lifebottleFilledLastSlot
end

function SDFLifebottle_Holder:GetLifebottleLastFullSlot(sdf, lifebottles)
    local lifebottleFullLastSlot = 0

    --Check for last full lifebottle
    for i, v in ipairs(lifebottles) do
	if v == true then
	    local tempLifebottle = self:GetLifebottle(sdf, i)
	    local tempLifebottleAmount = self:GetLifebottleAmountPercent(sdf, tempLifebottle)
	    if tempLifebottleAmount >= 1 then
		lifebottleFullLastSlot = i
	    end
	end
    end
    return lifebottleFullLastSlot
end

function SDFLifebottle_Holder:ActivateLifebottle(sdf, lifebottles) --Used for any filled bottle for rez
    local lifebottleLastFilledSlot = self:GetLifebottleLastFilledSlot(sdf, lifebottles)
    local lifebottleLastFullSlot = self:GetLifebottleLastFullSlot(sdf, lifebottles)

    if lifebottleLastFilledSlot > 0 or lifebottleLastFullSlot > 0 then
	sdf.components.health:SetMinHealth(1)
    else
	sdf.components.health:SetMinHealth(0)
    end
end

function SDFLifebottle_Holder:FillLifebottlesDoDelta(sdf, lifebottles, healAmount)

    local lifebottleFilledFirstSlot = self:GetLifebottleFirstFilledSlot(sdf, lifebottles)
    
    if lifebottleFilledFirstSlot ~= 0 then
	local lifebottleFilledFirst = self:GetLifebottle(sdf, lifebottleFilledFirstSlot)
    	local lifebottleFilledFirstAmountCurrent = self:GetLifebottleAmountCurrent(sdf, lifebottleFilledFirst)
        local overHeal = 0

	--Fill up first bottle
	if lifebottles[lifebottleFilledFirstSlot] == true then
	    if lifebottleFilledFirstAmountCurrent < TUNING.SDF_LIFEBOTTLE_HEALTH_MAX then
		overHeal = self:CheckOverHeal(lifebottleFilledFirstAmountCurrent, healAmount)
		self:SetLifebottleAmountDoDelta(sdf, lifebottleFilledFirst, healAmount)
	    end
	 end

	--OverHeal useage
	if overHeal > 0 then
	    if lifebottles[lifebottleFilledFirstSlot + 1] == true  then
		local tempLifebottle = self:GetLifebottle(sdf, lifebottleFilledFirstSlot + 1)
		self:SetLifebottleAmountDoDelta(sdf, tempLifebottle, overHeal)
	    end
	end
    end

    self:ActivateLifebottle(sdf, lifebottles)
end

function SDFLifebottle_Holder:FillLifebottlesFountainDoDelta(sdf, lifebottles, healAmount)
    local lifebottleFilledFirstSlot = self:GetLifebottleFirstFilledSlot(sdf, lifebottles)
    local overHeal = healAmount

    if lifebottleFilledFirstSlot ~= 0 then
	local lifebottleFilledFirst = self:GetLifebottle(sdf, lifebottleFilledFirstSlot)
    	local lifebottleFilledFirstAmountCurrent = self:GetLifebottleAmountCurrent(sdf, lifebottleFilledFirst)

	--Fill up first bottle
	if lifebottles[lifebottleFilledFirstSlot] == true then
	    if lifebottleFilledFirstAmountCurrent < TUNING.SDF_LIFEBOTTLE_HEALTH_MAX then
		overHeal = self:CheckOverHeal(lifebottleFilledFirstAmountCurrent, healAmount)

		--Sound effect
		sdf.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")

		self:SetLifebottleAmountDoDelta(sdf, lifebottleFilledFirst, healAmount)
	    end
	 end
    end

    self:ActivateLifebottle(sdf, lifebottles)
    return overHeal --Refund extra amount back to fountain
end

function SDFLifebottle_Holder:HealFountainDoDelta(sdf, healAmount)
    local currentHealth = sdf.components.health.currenthealth
    local overHeal = healAmount

    --Heal sdf first
    if currentHealth < TUNING.SDF_HEALTH_MAX then
	overHeal = self:CheckOverHeal(currentHealth, healAmount)
	self:HealFountainAmountDoDelta(sdf, healAmount)
    end

    --OverHeal useage
    if overHeal > 0 then
	local lifebottles = sdf.components.sdf_lifebottle_holder:GetLifebottleHolder()
	if lifebottles ~= nil then
	    overHeal = self:FillLifebottlesFountainDoDelta(sdf, lifebottles, overHeal)
	end
    end
    return overHeal --Refund extra amount back to fountain
end

function SDFLifebottle_Holder:HealEnergyVialDoDelta(sdf, healAmount)
    local currentHealth = sdf.components.health.currenthealth
    local overHeal = healAmount

    --Heal sdf first
    if currentHealth < TUNING.SDF_HEALTH_MAX then
	overHeal = self:CheckOverHeal(currentHealth, healAmount)
	self:HealEnergyvialAmountDoDelta(sdf, healAmount)
    end

    --OverHeal useage
    if overHeal > 0 then
	local lifebottles = sdf.components.sdf_lifebottle_holder:GetLifebottleHolder()
	if lifebottles ~= nil then
	    self:FillLifebottlesDoDelta(sdf, lifebottles, overHeal)
	end
    end
end

function SDFLifebottle_Holder:HealLifebottleDoDelta(sdf, healAmount)
    local currentHealth = sdf.components.health.currenthealth

    --Heal sdf first
    if currentHealth < TUNING.SDF_HEALTH_MAX then
	self:HealLifebottleAmountDoDelta(sdf, healAmount)
    end

    --Lifebottle useage
    if healAmount > 0 then
	local lifebottles = sdf.components.sdf_lifebottle_holder:GetLifebottleHolder()
	if lifebottles ~= nil then
	    self:FillLifebottlesDoDelta(sdf, lifebottles, healAmount)
	end
    end
end

function SDFLifebottle_Holder:AddLifebottle(sdf, lifebottles)
    for i, v in ipairs(lifebottles) do
	if v == false then
	    self:ObtainLifebottle(lifebottles, i)
	    local lifebottle = self:GetLifebottle(sdf, i)
	    self:HealLifebottleDoDelta(sdf, TUNING.SDF_LIFEBOTTLE_RECOVERY)
	    sdf:AddTag("lifebottle_"..i.."_enabled")
	    if i == TUNING.SDF_LIFEBOTTLE_MAX then
		sdf.components.talker:Say(GetString(sdf, "ANNOUNCE_SDF_LIFEBOTTLE_OBTAINED_MAX"))
	    else
		sdf.components.talker:Say(GetString(sdf, "ANNOUNCE_SDF_LIFEBOTTLE_OBTAINED"))
	    end
	    return
	end
    end
end

function SDFLifebottle_Holder:UpdateLifebottleDeath(sdf, lifebottles)
    local lifebottleFilledLastSlot = self:GetLifebottleLastFilledSlot(sdf, lifebottles)
    local lifebottleFilledLast = self:GetLifebottle(sdf, lifebottleFilledLastSlot)

    local lifebottleFullLastSlot = self:GetLifebottleLastFullSlot(sdf, lifebottles)
    local lifebottleFullLast = self:GetLifebottle(sdf, lifebottleFullLastSlot)

    --drains, Fills, Shifts Lifebottles, Full Bottles
    if lifebottleFullLastSlot > 0 then
	local fillLifebottle = 0 --Drains Lifebottle or fills

	--drain full lifebottle, max lifebottle
	if lifebottleFullLastSlot == TUNING.SDF_LIFEBOTTLE_MAX then
	    self:SetLifebottleAmountPercent(sdf, lifebottleFullLast, 0)
	    self:HealLifebottleAmountDoDelta(sdf, TUNING.SDF_LIFEBOTTLE_RECOVERY)
	    return

	--rollover last filled Lifebottle
	elseif lifebottles[lifebottleFullLastSlot + 1] == true  then
	    local tempLifebottle = self:GetLifebottle(sdf, lifebottleFullLastSlot + 1)
	    local tempLifebottleAmount = self:GetLifebottleAmountPercent(sdf, tempLifebottle)
	    if tempLifebottleAmount > 0 then
		fillLifebottle = tempLifebottleAmount
		self:SetLifebottleAmountPercent(sdf, tempLifebottle, 0)
	    end
	    self:SetLifebottleAmountPercent(sdf, lifebottleFullLast, fillLifebottle)
	    self:HealLifebottleAmountDoDelta(sdf, TUNING.SDF_LIFEBOTTLE_RECOVERY)
	    return

	--drain last full lifebottle
	else
	    self:SetLifebottleAmountPercent(sdf, lifebottleFullLast, 0) --addeddelta
	    self:HealLifebottleAmountDoDelta(sdf, TUNING.SDF_LIFEBOTTLE_RECOVERY)
	    return
	end

    --drain Half filled lifebottle
    elseif lifebottleFilledLastSlot > 0 then
	local lifebottleHeal = self:GetLifebottleAmountCurrent(sdf, lifebottleFilledLast)

	--drain filled lifebottle
	self:SetLifebottleAmountPercent(sdf, lifebottleFilledLast, 0)
	self:HealLifebottleAmountDoDelta(sdf, lifebottleHeal)
	return
    end
end

---
function SDFLifebottle_Holder:GetLifebottleFoundStatusPumpkinGorge()
    return self.pumpkin_gorge_lifebottle_found
end

function SDFLifebottle_Holder:SetLifebottleFoundStatusPumpkinGorge()
    self.pumpkin_gorge_lifebottle_found = true
end

function SDFLifebottle_Holder:GetLifebottleFoundStatusAsylumGrounds()
    return self.asylum_grounds_lifebottle_found
end

function SDFLifebottle_Holder:SetLifebottleFoundStatusAsylumGrounds()
    self.asylum_grounds_lifebottle_found = true
end
---

function SDFLifebottle_Holder:OnSave()
    return{
	    lifebottle_holder=self.lifebottle_holder,
	    pumpkin_gorge_lifebottle_found=self.pumpkin_gorge_lifebottle_found,
	    asylum_grounds_lifebottle_found=self.asylum_grounds_lifebottle_found,
    }
end

function SDFLifebottle_Holder:OnLoad(data)
    if data.lifebottle_holder ~= nil and self.lifebottle_holder ~= data.lifebottle_holder then
	self.lifebottle_holder = data.lifebottle_holder or {false, false, false, false, false, false, false, false, false}
    end

    if data.pumpkin_gorge_lifebottle_found ~= nil and self.pumpkin_gorge_lifebottle_found ~= data.pumpkin_gorge_lifebottle_found then
	self.pumpkin_gorge_lifebottle_found = data.pumpkin_gorge_lifebottle_found or false
    end

    if data.asylum_grounds_lifebottle_found ~= nil and self.asylum_grounds_lifebottle_found ~= data.asylum_grounds_lifebottle_found then
	self.asylum_grounds_lifebottle_found = data.asylum_grounds_lifebottle_found or false
    end
end

return SDFLifebottle_Holder