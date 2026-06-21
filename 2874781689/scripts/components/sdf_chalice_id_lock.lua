local SDFChalice_Id_Lock = Class(function (self,inst)
    self.inst=inst
    self.chalice_altar_id_lock = {false,false,false,false,false,false,false,false,false,false,
			    false,false,false,false,false,false,false,false,false,false}

    self.chalice_id_lock = {false,false,false,false,false,false,false,false,false,false,
			    false,false,false,false,false,false,false,false,false,false}
    --testing
    --self.chalice_altar_id_lock = {true,true,true,true,true,true,true,true,true,true,
			    --true,true,true,true,true,true,true,true,true,true}

    --self.chalice_id_lock = {true,true,true,true,true,true,true,true,true,true,
			    --true,true,true,true,true,true,true,true,true,true}

    --Skill Tree Time Dilation Runesmith
    self.chalice_overworld_count = 0
    self.chalice_cave_count = 0

    --Tag makers for shop
    self.enchanted_sword_enabled = false
    self.gold_shield_enabled = false
    self.gold_armor_enabled = false
    self.standard_bolts_enabled = false
    self.standard_arrows_enabled = false
    self.flaming_arrows_enabled = false
    self.magical_arrows_enabled = false
    self.spear_enabled = false
    self.lightning_enabled = false
    self.goodlightning_enabled = false

    self.flaming_bolts_enabled = false
    self.standard_bullets_enabled = false
    self.standard_buckshots_enabled = false
    self.bombs_enabled = false
    self.standard_munitions_enabled = false

    --Gold Armor and Free Good Lightning
    self.hero_enabled = false
    self.goodlightning_sample = false
    self.dragon_potion_found = false

end)

function SDFChalice_Id_Lock:GetOverworldCount()
    return self.chalice_overworld_count
end

function SDFChalice_Id_Lock:SetOverworldCount(val)
    self.chalice_overworld_count = val
end

function SDFChalice_Id_Lock:GetCaveCount()
    return self.chalice_cave_count
end

function SDFChalice_Id_Lock:SetCaveCount(val)
    self.chalice_cave_count = val
end

function SDFChalice_Id_Lock:EnableTrade(trade)
    if trade == "sdf_enchanted_sword" then
	self.enchanted_sword_enabled = true
    end
    if trade == "sdf_gold_shield" then
	self.gold_shield_enabled = true
    end
    if trade == "sdf_gold_armor" then
	self.gold_armor_enabled = true
    end
    if trade == "sdf_standard_bolts" then
	self.standard_bolts_enabled = true
    end
    if trade == "sdf_standard_arrows" then
	self.standard_arrows_enabled = true
    end
    if trade == "sdf_flaming_arrows" then
	self.flaming_arrows_enabled = true
    end
    if trade == "sdf_magical_arrows" then
	self.magical_arrows_enabled = true
    end
    if trade == "sdf_spear" then
	self.spear_enabled = true
    end
    if trade == "sdf_lightning" then
	self.lightning_enabled = true
    end
    if trade == "sdf_goodlightning" then
	self.goodlightning_enabled = true
    end

    if trade == "sdf_flaming_bolts" then
	self.flaming_bolts_enabled = true
    end
    if trade == "sdf_standard_bullets" then
	self.standard_bullets_enabled = true
    end
    if trade == "sdf_standard_buckshots" then
	self.standard_buckshots_enabled = true
    end
    if trade == "sdf_bombs" then
	self.bombs_enabled = true
    end
    if trade == "sdf_standard_munitions" then
	self.standard_munitions_enabled = true
    end
end

function SDFChalice_Id_Lock:CreateTradeTags(sdf)
    if self.enchanted_sword_enabled == true then
	sdf:AddTag("sdf_enchanted_sword_builder")
    end
    if self.gold_shield_enabled == true then
	sdf:AddTag("sdf_gold_shield_builder")
    end
    if self.gold_armor_enabled == true then
	sdf:AddTag("sdf_gold_armor_builder")
    end
    if self.standard_bolts_enabled == true then
	sdf:AddTag("sdf_standard_bolts_builder")
    end
    if self.standard_arrows_enabled == true then
	sdf:AddTag("sdf_standard_arrows_builder")
    end
    if self.flaming_arrows_enabled == true then
	sdf:AddTag("sdf_flaming_arrows_builder")
    end
    if self.magical_arrows_enabled == true then
	sdf:AddTag("sdf_magical_arrows_builder")
    end
    if self.spear_enabled == true then
	sdf:AddTag("sdf_spear_builder")
    end
    if self.lightning_enabled == true then
	sdf:AddTag("sdf_lightning_builder")
    end
    if self.goodlightning_enabled == true then
	sdf:AddTag("sdf_goodlightning_builder")
    end

    if self.flaming_bolts_enabled == true then
	sdf:AddTag("sdf_flaming_bolts_builder")
    end
    if self.standard_bullets_enabled == true then
	sdf:AddTag("sdf_standard_bullets_builder")
    end
    if self.standard_buckshots_enabled == true then
	sdf:AddTag("sdf_standard_buckshots_builder")
    end
    if self.bombs_enabled == true then
	sdf:AddTag("sdf_bombs_builder")
    end
    if self.standard_munitions_enabled == true then
	sdf:AddTag("sdf_standard_munitions_builder")
    end
end

function SDFChalice_Id_Lock:GetAltarLock()
    return self.chalice_altar_id_lock
end

function SDFChalice_Id_Lock:GetLock()
    return self.chalice_id_lock
end

function SDFChalice_Id_Lock:SetLock(lock,key)
    lock[key] = true
end

function SDFChalice_Id_Lock:RemoveLock(lock,key)
     lock[key] = false
end

function SDFChalice_Id_Lock:CheckLock(lock,key)
     return lock[key]
end

function SDFChalice_Id_Lock:CheckLocks(lock)
    for i, v in ipairs(lock) do
	if v == false then
	    return false
	end
    end
    return true
end

function SDFChalice_Id_Lock:ResetLocks(lock)
    for i, v in ipairs(lock) do
	self:RemoveLock(lock,i)
    end
end

function SDFChalice_Id_Lock:CheckHeroStatus()
    return self.hero_enabled
end

function SDFChalice_Id_Lock:EnableHeroStatus()
    self.hero_enabled = true
end

function SDFChalice_Id_Lock:HasGoodLightningSample()
    return self.goodlightning_sample
end

function SDFChalice_Id_Lock:GiveGoodLightningSample()
    self.goodlightning_sample = true
end

function SDFChalice_Id_Lock:RemoveGoodLightningSample()
    self.goodlightning_sample = false
end

function SDFChalice_Id_Lock:GetDragonPotionFoundStatus()
    return self.dragon_potion_found
end

function SDFChalice_Id_Lock:SetDragonPotionFoundStatus()
    self.dragon_potion_found = true
end
---

function SDFChalice_Id_Lock:OnSave()
    return{
	    chalice_altar_id_lock=self.chalice_altar_id_lock,
	    chalice_id_lock=self.chalice_id_lock,

	    chalice_overworld_count=self.chalice_overworld_count,
	    chalice_cave_count=self.chalice_cave_count,

	    enchanted_sword_enabled=self.enchanted_sword_enabled,
	    gold_shield_enabled=self.gold_shield_enabled,
	    gold_armor_enabled=self.gold_armor_enabled,
	    standard_bolts_enabled=self.standard_bolts_enabled,
	    standard_arrows_enabled=self.standard_arrows_enabled,
	    flaming_arrows_enabled=self.flaming_arrows_enabled,
	    magical_arrows_enabled=self.magical_arrows_enabled,
	    spear_enabled=self.spear_enabled,
	    lightning_enabled=self.lightning_enabled,
	    goodlightning_enabled=self.goodlightning_enabled,

	    hero_enabled=self.hero_enabled,
	    goodlightning_sample=self.goodlightning_sample,
	    dragon_potion_found=self.dragon_potion_found,
    }
end

function SDFChalice_Id_Lock:OnLoad(data)
    if data.chalice_altar_id_lock ~= nil and self.chalice_altar_id_lock ~= data.chalice_altar_id_lock then
	self.chalice_altar_id_lock = data.chalice_altar_id_lock or 
	{false,false,false,false,false,false,false,false,false,false,
	false,false,false,false,false,false,false,false,false,false}
    end

    if data.chalice_id_lock ~= nil and self.chalice_id_lock ~= data.chalice_id_lock then
	self.chalice_id_lock = data.chalice_id_lock or 
	{false,false,false,false,false,false,false,false,false,false,
	false,false,false,false,false,false,false,false,false,false}
    end

    if data.chalice_overworld_count ~= nil and self.chalice_overworld_count ~= data.chalice_overworld_count then
	self.chalice_overworld_count = data.chalice_overworld_count or 0
    end

    if data.chalice_cave_count ~= nil and self.chalice_cave_count ~= data.chalice_cave_count then
	self.chalice_cave_count = data.chalice_cave_count or 0
    end

    if data.enchanted_sword_enabled ~= nil and self.enchanted_sword_enabled ~= data.enchanted_sword_enabled then
	self.enchanted_sword_enabled = data.enchanted_sword_enabled or false
    end
    if data.gold_shield_enabled ~= nil and self.gold_shield_enabled ~= data.gold_shield_enabled then
	self.gold_shield_enabled = data.gold_shield_enabled or false
    end
    if data.gold_armor_enabled ~= nil and self.gold_armor_enabled ~= data.gold_armor_enabled then
	self.gold_armor_enabled = data.gold_armor_enabled or false
    end
    if data.standard_bolts_enabled ~= nil and self.standard_bolts_enabled ~= data.standard_bolts_enabled then
	self.standard_bolts_enabled = data.standard_bolts_enabled or false
    end
    if data.standard_arrows_enabled ~= nil and self.standard_arrows_enabled ~= data.standard_arrows_enabled then
	self.standard_arrows_enabled = data.standard_arrows_enabled or false
    end
    if data.standard_arrows_enabled ~= nil and self.standard_arrows_enabled ~= data.standard_arrows_enabled then
	self.standard_arrows_enabled = data.standard_arrows_enabled or false
    end
    if data.magical_arrows_enabled ~= nil and self.magical_arrows_enabled ~= data.magical_arrows_enabled then
	self.magical_arrows_enabled = data.magical_arrows_enabled or false
    end
    if data.spear_enabled ~= nil and self.spear_enabled ~= data.spear_enabled then
	self.spear_enabled = data.spear_enabled or false
    end
    if data.lightning_enabled ~= nil and self.lightning_enabled ~= data.lightning_enabled then
	self.lightning_enabled = data.lightning_enabled or false
    end
    if data.goodlightning_enabled ~= nil and self.goodlightning_enabled ~= data.goodlightning_enabled then
	self.goodlightning_enabled = data.goodlightning_enabled or false
    end

    if data.hero_enabled ~= nil and self.hero_enabled ~= data.hero_enabled then
	self.hero_enabled = data.hero_enabled or false
    end

    if data.goodlightning_sample ~= nil and self.goodlightning_sample ~= data.goodlightning_sample then
	self.goodlightning_sample = data.goodlightning_sample or false
    end

    if data.dragon_potion_found ~= nil and self.dragon_potion_found ~= data.dragon_potion_found then
	self.dragon_potion_found = data.dragon_potion_found or false
    end
end

return SDFChalice_Id_Lock