local assets =
{
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_potion.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_dragon_potion.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_potion_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_dragon_potion_empty.tex"),

    Asset("ATLAS", "images/map_icons/sdf_dragon_potion_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_dragon_potion_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_dragon_potion_empty_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_dragon_potion_empty_mm.tex"),

    Asset("ANIM", "anim/sdf_dragon_potion.zip"),
    Asset("ANIM", "anim/sdf_dragon_potion_empty.zip"),
}

prefabs = {

}

local function OnPutInInventory(inst, owner)
    inst:DoTaskInTime(0, function()
	if owner ~= nil then
	    if owner:HasTag("sdf") then
		if owner.components.sdf_key_item_inventory:GetKeyItem(inst.prefab) == nil then
		    owner.components.sdf_key_item_inventory:SetKeyItem(inst, owner)
		end
	    end
	end
    end)
end

local function OnPickupFn(inst, pickupguy)
    if pickupguy.prefab == "sdf" then

	--Resets
	if inst.components.equippable == nil then
	    inst:AddComponent("equippable")
	    inst.components.equippable.equipslot = EQUIPSLOTS.BODY --might change
	    inst.components.equippable:SetOnEquip(onequip)
	    inst.components.equippable:SetOnUnequip(onunequip)
	end
    else
	inst:RemoveComponent("equippable")
    end
end

local function onperish (inst, owner)
    --Spawns in inventory
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
    local dragonPotionEmpty = SpawnPrefab("sdf_dragon_potion_empty")

    dragonPotionEmpty.components.follower:SetLeader(owner)
    if holder ~= nil then
	local slot = holder:GetItemSlot(inst)
	inst:Remove()
	holder:GiveItem(dragonPotionEmpty, slot)
    end
end

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_scalemail")
end

local function dragonPotionBuff(inst, player)
    if player.components.temperature then

	local currentTemp = player.components.temperature:GetCurrent()
	local maxTemp = player.components.temperature.maxtemp
	local minTemp = player.components.temperature.mintemp
	local naturalTemp = ((maxTemp + minTemp)/2)

	if currentTemp ~= naturalTemp then
	    local adjustmentMaxTemp = naturalTemp + 15
	    local adjustmentMinTemp = naturalTemp - 15
	    if currentTemp >= adjustmentMaxTemp then player.components.temperature:SetTemperature(adjustmentMaxTemp) end
	    if currentTemp <= adjustmentMinTemp then player.components.temperature:SetTemperature(adjustmentMinTemp) end
	end
    else
	if inst.dragonPotionBufftask ~= nil then
	    inst.dragonPotionBufftask:Cancel()
	end
    end
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "sdf_dragon_potion", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)

    --Switches character model
    if owner.prefab == "sdf" then
	local helmItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

	--Skill Tree Eye of Amon Ra
	if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
	    owner:MakeDragonArmorEye()
	else
	    owner:MakeDragonArmor()
	end

	--Check for helm
	inst:DoTaskInTime(0.1, function()
	    if helmItem then
		if helmItem.prefab == "sdf_helmet" then
		    helmItem.components.equippable.onequipfn(helmItem, owner)
		end
	    end
	end)

	--Activate Dragon Potion
	local x,_,z=owner.Transform:GetWorldPosition()
	SpawnPrefab("tauntfire_fx").Transform:SetPosition(x,_,z)
	owner.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")

	if inst.components.fueled then
	    inst.components.fueled:StartConsuming()
	end

	--Fire Proof
	owner:AddTag("heatresistant") --less overheat damage

	if owner.components.health ~= nil then
	    owner.components.health.externalfiredamagemultipliers:SetModifier(inst, 1 - TUNING.SDF_DRAGON_POTION_FIRE_RESIST)
	end

	--Heat Proof
	if owner.components.temperature then
	    owner.components.temperature:SetFreezingHurtRate(0)
	    owner.components.temperature:SetOverheatHurtRate(0)
	    inst.dragonPotionBufftask = inst:DoPeriodicTask(10, function() dragonPotionBuff(inst, owner) end)
	end

	--Remove/Replace equiped hand and context slot
	local owner_Inventory = owner.components.inventory

	--Clear Hands slot
	local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsSlot then
	    if handsSlot.prefab ~= "sdf_dragon_potion_dragonbreath" then
		inst:DoTaskInTime(0.1, function()

		    if handsSlot ~= nil then
		    if handsSlot.prefab == "sdf_anubis_stone_necrotic_touch" then
			handsSlot:Remove()
		    else
			owner_Inventory:DropItem(handsSlot)
			owner_Inventory:GiveItem(handsSlot)
			owner.AnimState:ClearOverrideSymbol("swap_object")
		    end
		    end

		    --Equip Dragon Potion Dragonbreath
		    --inst:DoTaskInTime(0.1, function()
		    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		    if handsSlot == nil then
			local dragonPotionDragonbreath = SpawnPrefab("sdf_dragon_potion_dragonbreath")
			owner_Inventory:Equip(dragonPotionDragonbreath)
		    end
		    --end)
		end)
	    end
	else
	    --Equip Dragon Potin Dragonbreath
	    local dragonPotionDragonbreath = SpawnPrefab("sdf_dragon_potion_dragonbreath")
	    owner_Inventory:Equip(dragonPotionDragonbreath)
	end

    else
	--Stops others from wearing
	inst:DoTaskInTime(0.1, function()

	    local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	    if body then
		if body.prefab == "sdf_dragon_potion" then
		    if owner.components.talker then
			owner.components.talker:Say(GetString(owner, "ANNOUNCE_NODANIELSUIT"))
		    end
		    local item = owner.components.inventory:Unequip(body.components.equippable.equipslot)
		    owner.components.inventory:GiveItem(item)
		end
	    end
	end)
    end
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)

    --switches character model
    if owner.prefab == "sdf" then
	local helmItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

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

	--Deactivate Dragon Potion
	if inst.components.fueled then
	    inst.components.fueled:StopConsuming()
	end

	--Remove Fire Proof
	if owner:HasTag("heatresistant") then
	    owner:RemoveTag("heatresistant") --less overheat damage
	end

	if owner.components.health ~= nil then
	    owner.components.health.externalfiredamagemultipliers:RemoveModifier(inst)
	end

	--Remove Heat Proof
	if inst.dragonPotionBufftask ~= nil then
	    if owner.components.temperature then
		owner.components.temperature:SetFreezingHurtRate(TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME)
		owner.components.temperature:SetOverheatHurtRate(TUNING.WILSON_HEALTH / TUNING.FREEZING_KILL_TIME)
	    end
	    inst.dragonPotionBufftask:Cancel()
	end

	--Stop Dragonbreath
	if owner.components.channelcaster then
	    owner.components.channelcaster:StopChanneling()
	end

	--Remove dragon potion dragonbreath
	local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsSlot and handsSlot.prefab == "sdf_dragon_potion_dragonbreath" then
	    inst:DoTaskInTime(0.1, function()
		--check for dup dragon potion
		local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
		if bodySlot then
		    if bodySlot.prefab == "sdf_dragon_potion" then
			return
		    end
		end
		if handsSlot ~= nil then
		--handsSlot.components.equippable:SetPreventUnequipping(false)
		handsSlot:Remove()
		end
		owner.AnimState:ClearOverrideSymbol("swap_object")
	    end)
	end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_dragon_potion_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_dragon_potion")
    inst.AnimState:SetBuild("sdf_dragon_potion")
    inst.AnimState:PlayAnimation("anim")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    inst:AddTag("armor")
    inst:AddTag("waterproofer")

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    --Allows refilling Dragon Potion
    inst:AddComponent("sdf_dragon_potion_imbue")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/shellarmour"
    inst.components.inventoryitem.imagename = "sdf_dragon_potion"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_dragon_potion.xml"			

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.SDF_DRAGON_POTION_WET_RESIST)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.SDF_DRAGON_POTION_DURATION * 1.3)
    inst.components.fueled:SetDepletedFn(onperish)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.dragonPotionBufftask = nil

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_dragon_potion_empty_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_dragon_potion_empty")
    inst.AnimState:SetBuild("sdf_dragon_potion_empty")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    --Allows refilling Dragon Potion
    inst:AddComponent("sdf_dragon_potion_imbue")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_dragon_potion_empty"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_dragon_potion_empty.xml"	

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab( "common/inventory/sdf_dragon_potion", fn, assets),
	Prefab("common/inventory/sdf_dragon_potion_empty", fn2, assets)