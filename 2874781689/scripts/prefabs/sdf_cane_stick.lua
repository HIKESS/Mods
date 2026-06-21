local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_empty.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_red.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_red.tex"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_blue.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_blue.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_purple.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_purple.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_yellow.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_yellow.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_green.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_green.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_orange.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_orange.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_cane_stick_opal.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_cane_stick_opal.xml"),

    Asset("ANIM", "anim/sdf_cane_stick.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_empty.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_red.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_blue.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_purple.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_yellow.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_green.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_orange.zip"),
    Asset("ANIM", "anim/swap_sdf_cane_stick_opal.zip"),
}

prefabs = {
}

--Effects  +sanity aura with suit
--Red = fire/burn
--Blue = ice/freeze
--Purple = life steal
--Yellow = electric
--Green = sleep
--Orange = item slot repair
--Opal = random effect

local GEM_NAMES ={
    {"red","redgem", "fire"},
    {"blue","bluegem", "cold"},
    {"purple","purplegem","shadow"},
    {"yellow","yellowgem", "electric"},
    {"green","greengem", "nature"},
    {"orange","orangegem", nil},
    {"opal","opalpreciousgem", nil}
}

local function OnSpecialUse(inst)
    --Start cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_CANE_STICK_COOLDOWN)

    --Special Usage
    if inst.components.finiteuses then
	inst.components.finiteuses:Use(TUNING.SDF_CANE_STICK_USAGE)
    end
end

local function CanElectrocuteTarget(target)
    if target:GetIsWet() then
	return true
    elseif target:HasTag("electricdamageimmune") or target.components.inventory ~= nil and target.components.inventory:IsInsulated() then
	return false
    end
    return true
end

local function HasAnyEquipment(owner)
    if owner ~= nil then
	local equipmentShield = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	local equipmentBody = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	local equipmentBody1 = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1)
	local equipmentBody2 = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY2)
	local equipmentBody3 = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY3)
	local equipmentHead = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	local equipmentNeck = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK or EQUIPSLOTS.AMULET)
	if equipmentShield ~= nil or equipmentBody ~= nil or equipmentBody1 ~= nil or equipmentBody2 ~= nil or equipmentBody3 ~= nil or
	    equipmentHead ~= nil or equipmentNeck ~= nil then
	    return true
	end
    end
    return false
end

local function CanRepairItemSlot(item)
    if item.components.armor then
	local currentArmorPercent = item.components.armor:GetPercent()
	item.components.armor:SetPercent(currentArmorPercent + TUNING.SDF_CANE_STICK_ORANGE_REPAIR_PERCENT_AMOUNT)
    elseif item.components.fueled then
	local currentFuelPercent = item.components.fueled:GetPercent()
	item.components.fueled:SetPercent(currentFuelPercent + TUNING.SDF_CANE_STICK_ORANGE_REPAIR_PERCENT_AMOUNT)
    elseif item.components.finiteuses then
	local currentFiniteusesPercent = item.components.finiteuses:GetPercent()
	item.components.finiteuses:SetPercent(currentFiniteusesPercent + TUNING.SDF_CANE_STICK_ORANGE_REPAIR_PERCENT_AMOUNT)
    end
end

local function onattack(inst, owner, target)
    --Swingfx
    inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/kick_whoosh")

    --Random Animation
    local random=math.random()
    if random<0.2 then --jab
	if not inst:HasTag("sdf_jabweapon") then
	    inst:AddTag("sdf_jabweapon")
	end
    else --normal
	if inst:HasTag("sdf_jabweapon") then
	    inst:RemoveTag("sdf_jabweapon")
	end
    end

    local socketType = inst.components.sdf_cane_stick_gem_holder:GetSocketType()

    if socketType == "empty" then
	return
    end

    --Special Attacks
    if inst.components.rechargeable then
	if inst.components.rechargeable:IsCharged() then
	    local randomEffect = 0

	    --Opal random effect
	    if socketType == "opal" then
		randomEffect = math.random(1,6)
	    end

	    --Red fire/burn
	    if socketType == "red" or randomEffect == 1 then
		if target.components.burnable ~= nil and not target.components.burnable:IsBurning() then
		    if target.components.freezable ~= nil and target.components.freezable:IsFrozen() then
			target.components.freezable:Unfreeze()

			--Usage
			OnSpecialUse(inst)
		    elseif target.components.burnable.canlight or target.components.combat ~= nil then
			target.components.burnable:Ignite(true, owner)

			--Usage
			OnSpecialUse(inst)
		    end
		elseif randomEffect == 1 then
		    onattack(inst, owner, target)
		end
	    end

	    --Blue ice/freeze
	    if socketType == "blue" or randomEffect == 2 then

		if target.components.burnable ~= nil then
		    if target.components.burnable:IsBurning() then
			target.components.burnable:Extinguish()
		    elseif target.components.burnable:IsSmoldering() then
			target.components.burnable:SmotherSmolder()
		    end
		end

		if target.components.freezable ~= nil and target:IsValid() then
		    if randomEffect == 2 then
			target.components.freezable:AddColdness(2) --Opal effect
		    else
			target.components.freezable:AddColdness(1) --Normal effect
		    end
		    target.components.freezable:SpawnShatterFX()

		    --Usage
		    OnSpecialUse(inst)
		elseif randomEffect == 2 then
		    onattack(inst, owner, target)
		end
	    end

	    --Purple life steal
	    if socketType == "purple" or randomEffect == 3 then
		if owner.components.health ~= nil and not (target:HasTag("wall") or target:HasTag("engineering")) then
		    owner.components.health:DoDelta(TUNING.SDF_CANE_STICK_PURPLE_DRAIN, false, "cane stick effect")

		    --Visual Effect
		    local x,_,z=target.Transform:GetWorldPosition()
		    SpawnPrefab("minotaur_blood3").Transform:SetPosition(x,_,z)

		    --Bonus Damage
		    target.components.combat:GetAttacked(owner, TUNING.SDF_CANE_STICK_PURPLE_DRAIN)

		    --Usage
		    OnSpecialUse(inst)
		elseif randomEffect == 3 then
		    onattack(inst, owner, target)
		end
	    end

	    --Yellow electric
	    if socketType == "yellow" or randomEffect == 4 then
		if target ~= nil and target:IsValid() and owner ~= nil and owner:IsValid() and CanElectrocuteTarget(target) then

		   --Visual Effect
		    SpawnPrefab("electrichitsparks"):AlignToTarget(target, owner, true)

		    --Bonus Damage
		    if target:GetIsWet() then
			target.components.combat:GetAttacked(owner, TUNING.SDF_CANE_STICK_YELLOW_ELETRIC_DAMAGE * TUNING.SDF_CANE_STICK_YELLOW_ELETRIC_DAMAGE_MULTI)
		    else
			target.components.combat:GetAttacked(owner, TUNING.SDF_CANE_STICK_YELLOW_ELETRIC_DAMAGE)
		    end

		    --Usage
		    OnSpecialUse(inst)
		elseif randomEffect == 4 then
		    onattack(inst, owner, target)
		end
	    end

	    --Green roots
	    if socketType == "green" or randomEffect == 5 then
		if target ~= nil and target:IsValid() and target.components.locomotor then
		    target:AddDebuff("sdf_cane_stick_green_debuff", "sdf_cane_stick_green_debuff")

		    --Usage
		    OnSpecialUse(inst)
		elseif randomEffect == 5 then
		    onattack(inst, owner, target)
		end
	    end

	    --Orange item repair
	    if socketType == "orange" or randomEffect == 6 then
		if owner ~= nil and owner:IsValid() and HasAnyEquipment(owner) and not (target:HasTag("wall") or target:HasTag("engineering")) then

		    --Visual Effect
		    owner._sdf_cane_stick_orange_fx = SpawnPrefab("spider_heal_target_fx")
		    owner._sdf_cane_stick_orange_fx.entity:SetParent(owner.entity)
		    owner:DoTaskInTime(1,function()
			if owner._sdf_cane_stick_orange_fx ~= nil then
			    owner._sdf_cane_stick_orange_fx = nil
			end
		    end)

		    --Repair Shield Item
		    local shield = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
		    if shield then
			CanRepairItemSlot(shield)
		    end
		    --Repair Body Item
		    local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		    if body then
			CanRepairItemSlot(body)
		    end
		    --Repair Body1 Item
		    local body1 = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1)
		    if body1 then
			CanRepairItemSlot(body1)
		    end
		    --Repair Body2 Item
		    local body2 = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY2)
		    if body2 then
			CanRepairItemSlot(body2)
		    end
		    --Repair Body3 Item
		    local body3 = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY3)
		    if body3 then
			CanRepairItemSlot(body3)
		    end
		    --Repair Head Item
		    local head = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
		    if head then
			CanRepairItemSlot(head)
		    end
		    --Repair Neck Item
		    local neck = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK or EQUIPSLOTS.AMULET)
		    if neck then
			CanRepairItemSlot(neck)
		    end

		    --Usage
		    OnSpecialUse(inst)
		elseif randomEffect == 6 then
		    onattack(inst, owner, target)
		end
	    end
	end
    end
end

local function updateSocket(inst, owner)
    local socketType = inst.components.sdf_cane_stick_gem_holder:GetSocketType()
    local socketStimuli = inst.components.sdf_cane_stick_gem_holder:GetSocketStimuli()

    --Weapon Stimuli
    inst.components.weapon.stimuli = socketStimuli

    --update Ground Animation
    inst.AnimState:PlayAnimation(socketType)

    --update Held Animation
    if owner ~= nil and inst.components.equippable:IsEquipped() then
	owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_cane_stick_"..socketType.."", "swap_sdf_cane_stick")

	--check Set Bonus Gentleman SDF Only
	if socketType ~= "empty" then
	    if owner.prefab == "sdf" then
		local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
		if body then
		    if body.prefab == "sdf_victorian_suit" then
			inst:SetBonusGentlemanActivateFn()
		    end
		end
	    end
	end
    end

    --update Inventory Icons
    inst.components.inventoryitem.imagename = "sdf_cane_stick_"..socketType..""
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_cane_stick_"..socketType..".xml"

    --update Names needs updated
    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_CANE_STICK_NAME[socketType])
    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_CANE_STICK_DESC[socketType])
end

local function setBonusGentlemanSanityAura(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = TheSim:FindEntities(x, y, z, TUNING.SDF_CANE_STICK_AURA_RANGE, {"player"})
	for i,v in ipairs(players) do
	    if v.components.sanity then
		v.components.sanity:DoDelta(TUNING.SDF_CANE_STICK_AURA_RECOVERY)
	    end
        end
end

local function setBonusGentlemanActivate(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local socketType = inst.components.sdf_cane_stick_gem_holder:GetSocketType()

    if owner ~= nil and socketType ~= "empty" then
	if inst._gemSparkleFX == nil then
	    --FX
	    local gemSparkleScale = 0.5
	    inst._gemSparkleFX = SpawnPrefab("carnival_sparkle_bush")
	    inst._gemSparkleFX.entity:SetParent(owner.entity)
	    inst._gemSparkleFX.entity:AddFollower()
	    inst._gemSparkleFX.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -100, 0)
	    inst._gemSparkleFX.Transform:SetScale(gemSparkleScale, gemSparkleScale, gemSparkleScale)
	end

	if inst._gemSanityAuraTask == nil then
	    inst:AddTag("sdf_cane_stick_gentleman")
	    inst._gemSanityAuraTask = inst:DoPeriodicTask(TUNING.SDF_CANE_STICK_AURA_RATE, function(inst) setBonusGentlemanSanityAura(inst) end)
	end
    end
end

local function setBonusGentlemanDeactivate(inst)
    if inst._gemSparkleFX ~= nil then
	inst._gemSparkleFX:Remove()
	inst._gemSparkleFX = nil
    end

    if inst._gemSanityAuraTask ~= nil then
	if inst:HasTag("sdf_cane_stick_gentleman") then
	    inst:RemoveTag("sdf_cane_stick_gentleman")
	end
	inst._gemSanityAuraTask:Cancel()
	inst._gemSanityAuraTask = nil
    end
end

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    else
	for i, v in ipairs(GEM_NAMES) do
	    if item.prefab == v[2] then
		return true
	    end
	end
    end
    return false
end

local function OnGemGiven(inst, giver, item)
    local socketType = inst.components.sdf_cane_stick_gem_holder:GetSocketType()

    --Add gem to socket. Reset or new
    if socketType == "empty" then
	--Find type by Gem set
	for i, v in ipairs(GEM_NAMES) do
	    if item.prefab == v[2] then
		--socket new gem
		inst.components.sdf_cane_stick_gem_holder:SetSocket(v[2], v[1], v[3])
	    end
	end

	--Socket Sound
	inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")

	--Update Cane Stick
	updateSocket(inst, giver)
    else
	--Find type by Gem set
	for i, v in ipairs(GEM_NAMES) do
	    if item.prefab == v[2] then
		--break old gem
		local gemShatterScale = 0.5

		--equipped or not
		if inst.components.equippable:IsEquipped() then
		    inst._gemShatterFX = SpawnPrefab("winona_battery_high_shatterfx")
		    local gemShatter = ""..socketType.."gem_shatter"
		    inst._gemShatterFX.entity:SetParent(giver.entity)
		    inst._gemShatterFX.entity:AddFollower()
		    inst._gemShatterFX.Follower:FollowSymbol(giver.GUID, "swap_object", 0, -100, 0)
		    inst._gemShatterFX.Transform:SetScale(gemShatterScale, gemShatterScale, gemShatterScale)

		    giver.AnimState:OverrideSymbol("swap_object", "swap_sdf_cane_stick_empty", "swap_sdf_cane_stick")
		    inst._gemShatterFX.AnimState:PlayAnimation(gemShatter)
		    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
		else
		    local gemShatterFX = SpawnPrefab("winona_battery_high_shatterfx")
		    local gemShatter = ""..socketType.."gem_shatter"
		    local x, y, z = inst.Transform:GetWorldPosition()
		    gemShatterFX.Transform:SetPosition(x,y+1.6,z)
		    gemShatterFX.Transform:SetScale(gemShatterScale, gemShatterScale, gemShatterScale)

		    inst.AnimState:PlayAnimation("empty")
		    gemShatterFX.AnimState:PlayAnimation(gemShatter)
		    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
		end

		--socket new gem
		inst.components.sdf_cane_stick_gem_holder:SetSocket(v[2], v[1], v[3])
	    end
	end

	--Delay
	inst:DoTaskInTime(0.3, function()
	    --Socket Sound
	    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")

	    --Update Cane Stick
	    updateSocket(inst, giver)
	end)
    end
end

local function onfinished(inst, owner)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        local brokentool = SpawnPrefab("brokentool")
        brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
end

local function onequip(inst, owner)
    local socketType = inst.components.sdf_cane_stick_gem_holder:GetSocketType()
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_cane_stick_"..socketType.."", "swap_sdf_cane_stick")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_CANE_STICK_ATTACK_SPEED)

    --Set Bonus Gentleman SDF Only
    if owner.prefab == "sdf" then
	local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)

	if body then
	    if body.prefab == "sdf_victorian_suit" then
		inst:SetBonusGentlemanActivateFn()
	    end
	end
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)

    --Remove Sparkling
    inst:SetBonusGentlemanDeactivateFn()
end

local function OnLoad(inst, data)
    updateSocket(inst)
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_cane_stick")
    inst.AnimState:SetBuild("sdf_cane_stick")
    inst.AnimState:PlayAnimation("empty")


    inst:AddTag("weapon")
    inst:AddTag("gemsocket")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Adding Sockets
    inst:AddComponent("sdf_cane_stick_gem_holder")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_CANE_STICK_DAMAGE)
    inst.components.weapon.stimuli = nil
    inst.components.weapon.onattack = onattack

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_CANE_STICK_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_CANE_STICK_DURABILITY)
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("named")

    inst:AddComponent("inspectable")

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven

    inst:AddComponent("rechargeable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_cane_stick_empty"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_cane_stick_empty.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.SDF_CANE_STICK_SPEED_MULT

    inst.SetBonusGentlemanActivateFn = function() setBonusGentlemanActivate(inst) end
    inst.SetBonusGentlemanDeactivateFn = function() setBonusGentlemanDeactivate(inst) end

    inst._gemSparkleFX = nil
    inst._gemSanityAuraTask = nil

    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_cane_stick", fn, assets)