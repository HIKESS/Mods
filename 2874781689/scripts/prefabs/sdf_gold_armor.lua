local assets =
{
    Asset("ATLAS", "images/inventoryimages/sdf_gold_armor.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_gold_armor.tex"),

    Asset("ATLAS", "images/map_icons/sdf_gold_armor_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_gold_armor_mm.tex"),

    Asset("ANIM", "anim/sdf_gold_armor.zip"),
}

prefabs = {
}

local function OnTakeDamage(inst, damage_amount)

    --super armor adjustments
    local armor_superarmor = inst.components.sdf_superarmor:GetCurrent()
    if armor_superarmor > 0 then
	inst.components.armor:Repair(damage_amount)
	local reduceDamage_amount = math.ceil(damage_amount * TUNING.SDF_SUPERARMOR_PROTECTION)
	inst.components.sdf_superarmor:DoDelta(-reduceDamage_amount, false, "sdf_gold_armor")

	--Switch Absorb percent
	local check_superarmor = inst.components.sdf_superarmor:GetCurrent()
	if check_superarmor <= 0 then
	    inst.components.armor:SetAbsorption(TUNING.SDF_GOLD_ARMOR_ABSORB*TUNING.MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER)
	end
    end
end

local function OnBlocked(owner, data, inst) 

    --super armor adjustments
    local armor_superarmor = inst.components.sdf_superarmor:GetCurrent()
    local sdf_superarmor = owner.components.sdf_superarmor:GetCurrent()
    if armor_superarmor ~= nil and sdf_superarmor ~= nil then
	if sdf_superarmor > 0 then
	    local syncSuperarmor = armor_superarmor - sdf_superarmor
 	    owner.components.sdf_superarmor:DoDelta(syncSuperarmor, false, "sdf_gold_armor")
	    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_dreadstone")
	else
	    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
	end
    end
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "sdf_gold_armor", "swap_body")
    owner.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl1_ding")
    inst:ListenForEvent("blocked", inst._onblocked, owner)

    --Switches character model
    if owner.prefab == "sdf" then

	--only allow Hero status
	if not owner:HasTag("sdf_hero") then
	    inst:DoTaskInTime(0.1, function()
		local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
		if body then
		    if owner.components.talker then
			owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_GOLD_ARMOR_NO_EQUIP"))
		    end
		    local item = owner.components.inventory:Unequip(body.components.equippable.equipslot)
		    owner.components.inventory:GiveItem(item)
		end
	    end)
	    return
	end

	--Update Arm icon and texture
	local handItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handItem then

	    --Update Arm icon and texture
	    if handItem.prefab == "sdf_arm" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_gold_arm", "swap_sdf_gold_arm")

		handItem.AnimState:SetBank("sdf_gold_arm")
		handItem.AnimState:SetBuild("sdf_gold_arm")
		handItem.components.inventoryitem.imagename = "sdf_gold_arm"
		handItem.components.inventoryitem.atlasname = "images/inventoryimages/sdf_gold_arm.xml"
	    end
	end

	inst:DoTaskInTime(0.1, function()
	--Gold Armor ID
	local sdf_goldArmor_id = owner.components.sdf_superarmor:CheckGoldArmorId()
	local item_goldArmor_id = inst.components.sdf_superarmor:CheckGoldArmorId()

	if item_goldArmor_id == 0 or sdf_goldArmor_id == item_goldArmor_id then
	    local helmItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

	    --Skill Tree Eye of Amon Ra
	    if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		owner:MakeGoldArmorEye()
	    else
		owner:MakeGoldArmor()
	    end

	    --Check for helm
	    inst:DoTaskInTime(0.1, function()
		if helmItem then
		    if helmItem.prefab == "sdf_helmet" then
			helmItem.components.equippable.onequipfn(helmItem, owner)
		    end
		end
	    end)

	    --Sync up Super Armor
	    local armor_superarmor = inst.components.sdf_superarmor:GetCurrent()
	    local sdf_superarmor = owner.components.sdf_superarmor:GetCurrent()
	    if armor_superarmor ~= nil and sdf_superarmor ~= nil then
		local syncSuperarmor = armor_superarmor - sdf_superarmor
		owner.components.sdf_superarmor:DoDelta(syncSuperarmor, false, "sdf_gold_armor")
		    if armor_superarmor > 0 then
			SpawnPrefab("wolfgang_mighty_fx").Transform:SetPosition(owner.Transform:GetWorldPosition())
		    end
	    end
	else
	    --Not same ID
	    inst:DoTaskInTime(0.1, function()
		local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
		if body then
		    if owner.components.talker then
			owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_GOLD_ARMOR_NO_EQUIP_ID"))
		    end
		    local item = owner.components.inventory:Unequip(body.components.equippable.equipslot)
		    owner.components.inventory:GiveItem(item)
		end
	    end)
	    return
	end
	end)
    else

	--Stops others from wearing
	inst:DoTaskInTime(0.1, function()
	local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	    if body then
		if owner.components.talker then
		    owner.components.talker:Say(GetString(owner, "ANNOUNCE_NODANIELSUIT"))
		end
		local item = owner.components.inventory:Unequip(body.components.equippable.equipslot)
		owner.components.inventory:GiveItem(item)
	    end
	end)
    end
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", inst._onblocked, owner)

    --switches character model
    if owner.prefab == "sdf" then
	local helmItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

	--Update Arm icon and texture
	local handItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handItem then

	    --Update Arm icon and texture
	    if handItem.prefab == "sdf_arm" then
		owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_arm", "swap_sdf_arm")

		handItem.AnimState:SetBank("sdf_arm")
		handItem.AnimState:SetBuild("sdf_arm")
		handItem.components.inventoryitem.imagename = "sdf_arm"
		handItem.components.inventoryitem.atlasname = "images/inventoryimages/sdf_arm.xml"
	    end
	end

	--Skill Tree Eye of Amon Ra
	if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
	    owner:MakeNormalArmorEye()
	else
	    owner:MakeNormalArmor()
	end


	--Check for helm
	inst:DoTaskInTime(0.1, function()
	    if helmItem then
		if helmItem.prefab == "sdf_helmet" then
		    helmItem.components.equippable.onequipfn(helmItem, owner)
		end
	    end
	end)

	--Removes Super Armor
	local sdf_superarmor = owner.components.sdf_superarmor:GetCurrent()
	if sdf_superarmor ~= nil then
	    owner.components.sdf_superarmor:DoDelta(-TUNING.SDF_SUPERARMOR_MAX, false, "sdf_gold_armor")
	end
    end
end

local function OnLoad(inst,data)
    --set Absorb Percent
    local armor_superarmor = inst.components.sdf_superarmor:GetCurrent()
    local armor_durability = inst.components.armor.condition
    if armor_superarmor ~= nil and armor_durability ~= nil then
	if armor_superarmor > 0 then
	    inst.components.armor:SetAbsorption(1*TUNING.MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER)
	elseif armor_durability > 0 then
	    inst.components.armor:SetAbsorption(TUNING.SDF_GOLD_ARMOR_ABSORB*TUNING.MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER)
	else
	    inst.components.armor:SetAbsorption(0)
	end
    end
end


local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_gold_armor_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
    	
    inst.AnimState:SetBank("sdf_gold_armor")
    inst.AnimState:SetBuild("sdf_gold_armor")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("metal")
    inst:AddTag("armor")

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    --Super Armor
    inst:AddComponent("sdf_superarmor")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/metalarmour"
    inst.components.inventoryitem.imagename = "sdf_gold_armor"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_gold_armor.xml"			
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.SDF_GOLD_ARMOR_DURABILITY*TUNING.MULTIPLAYER_ARMOR_DURABILITY_MODIFIER, 1*TUNING.MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER) --900 durability
    inst.components.armor.ontakedamage = OnTakeDamage
    inst.components.armor.SetCondition = function(self,amount)
	self.condition = math.min(amount, self.maxcondition)
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	local armor_superarmor = self.inst.components.sdf_superarmor:GetCurrent()
	if armor_superarmor ~= nil then
	    if armor_superarmor <= 0 then
		if self.condition <= 0 then
		    self:SetAbsorption(0)
		else
		    self:SetAbsorption(TUNING.SDF_GOLD_ARMOR_ABSORB)
		end
	    end
	end
    end

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(TUNING.SDF_GOLD_ARMOR_PLANAR_DEF)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst._onblocked = function(owner, data) OnBlocked(owner, data, inst) end

    inst.OnLoad = OnLoad

    return inst
end

return Prefab( "common/inventory/sdf_gold_armor", fn, assets) 