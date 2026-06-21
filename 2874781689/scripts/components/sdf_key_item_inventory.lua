local SDFKey_Item_Inventory = Class(function (self,inst)
    self.inst=inst
    self.keyItem_Helmet = nil
    self.keyItem_BookOfGallowmereDamaged = nil
    self.keyItem_GoldArmor = nil
    self.keyItem_GoldShield = nil
    self.keyItem_DragonPotion = nil
    self.keyItem_DragonPotionEmpty = nil
    self.keyItem_AnubisStonePart1 = nil
    self.keyItem_AnubisStonePart2 = nil
    self.keyItem_AnubisStonePart3 = nil
    self.keyItem_AnubisStonePart4 = nil
    self.keyItem_KingPeregrinsCrownLost = nil
    self.keyItem_KingPeregrinsCrown = nil
    self.keyItem_ShadowTalisman = nil
end)

function SDFKey_Item_Inventory:GetKeyItem(type)
    if type == "sdf_helmet" then
	return self.keyItem_Helmet
    elseif type == "sdf_book_of_gallowmere_damaged" then
	return self.keyItem_BookOfGallowmereDamaged
    elseif type == "sdf_gold_armor" then
	return self.keyItem_GoldArmor
    elseif type == "sdf_gold_shield" then
	return self.keyItem_GoldShield
    elseif type == "sdf_dragon_potion" then
	return self.keyItem_DragonPotion
    elseif type == "sdf_dragon_potion_empty" then
	return self.keyItem_DragonPotionEmpty
    elseif type == "sdf_anubis_stone_part1" then
	return self.keyItem_AnubisStonePart1
    elseif type == "sdf_anubis_stone_part2" then
	return self.keyItem_AnubisStonePart2
    elseif type == "sdf_anubis_stone_part3" then
	return self.keyItem_AnubisStonePart3
    elseif type == "sdf_anubis_stone_part4" then
	return self.keyItem_AnubisStonePart4
    elseif type == "sdf_king_peregrins_crown_lost" then
	return self.keyItem_KingPeregrinsCrownLost
    elseif type == "sdf_king_peregrins_crown" then
	return self.keyItem_KingPeregrinsCrown
    elseif type == "sdf_shadow_talisman" then
	return self.keyItem_ShadowTalisman
    end
end

function SDFKey_Item_Inventory:SetKeyItem(item, owner)
    if item.prefab == "sdf_helmet" then
	self.keyItem_Helmet = item
    elseif item.prefab == "sdf_book_of_gallowmere_damaged" then
	self.keyItem_BookOfGallowmereDamaged = item
    elseif item.prefab == "sdf_gold_armor" then
	self.keyItem_GoldArmor = item
    elseif item.prefab == "sdf_gold_shield" then
	self.keyItem_GoldShield = item
    elseif item.prefab == "sdf_dragon_potion" then
	self.keyItem_DragonPotion = item
    elseif item.prefab == "sdf_dragon_potion_empty" then
	self.keyItem_DragonPotionEmpty = item
    elseif item.prefab == "sdf_anubis_stone_part1" then
	self.keyItem_AnubisStonePart1 = item
    elseif item.prefab == "sdf_anubis_stone_part2" then
	self.keyItem_AnubisStonePart2 = item
    elseif item.prefab == "sdf_anubis_stone_part3" then
	self.keyItem_AnubisStonePart3 = item
    elseif item.prefab == "sdf_anubis_stone_part4" then
	self.keyItem_AnubisStonePart4 = item
    elseif item.prefab == "sdf_king_peregrins_crown_lost" then
	self.keyItem_KingPeregrinsCrownLost = item
    elseif item.prefab == "sdf_king_peregrins_crown" then
	self.keyItem_KingPeregrinsCrown = item
    elseif item.prefab == "sdf_shadow_talisman" then
	self.ShadowTalisman = item
    end

    if item.components.sdf_key_item then
	item.components.sdf_key_item:SetKeyItemID(owner.userid)
    end
end

function SDFKey_Item_Inventory:RemoveKeyItem(item)
    if item ~= nil then
	item:Remove()
    end
end

function SDFKey_Item_Inventory:OnSave()
    return{
    }
end

function SDFKey_Item_Inventory:OnLoad(data)
end

return SDFKey_Item_Inventory