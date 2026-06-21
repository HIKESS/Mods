local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_victorian_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_victorian_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_gold_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_gold_helmet.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_helmet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_dragon_helmet.tex"),

    Asset("ATLAS", "images/map_icons/sdf_helmet_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_helmet_mm.tex"),

    Asset("ANIM", "anim/sdf_helmet.zip"),
}

prefabs = {
}

local function OnCharged(inst)
    --inst:AddTag("sdf_shield_daring_dash_ready")
end

local function OnDischarged(inst)
    --inst:RemoveTag("sdf_shield_daring_dash_ready")
end

local function checkifitemisleader(item)
	return item.components.leader ~= nil
end

local function FindFriendlyTargets(inst)
    -- if not pvp then collect all the players near by, including yourself. If pvp then only yourself is enough
    local x, y, z = inst.Transform:GetWorldPosition()
    local all_targets = not TheNet:GetPVPEnabled() and FindPlayersInRange(x, y, z, TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_RANGE, true) or {inst }

    for i = 1, #all_targets do -- this is done this way so that we don't keep iterating over the appeneded followers
	local player = all_targets[i]
	-- collect all the companions that are following each player
	if player.components.leader ~= nil then
	    for follower, _ in pairs(player.components.leader.followers) do
		if not follower:HasTag("critter") and (follower.components.health == nil or not follower.components.health:IsDead())
		    and (follower.components.combat == nil or follower.components.combat.target ~= inst)
		    and follower:GetDistanceSqToPoint(x, y, z) <= (TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_RANGE * TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_RANGE) then
		    table.insert(all_targets, follower)
		end
	    end
	end

	-- collect all creatures following an item the player has in their inventoryitem
	local leader_items = player.components.inventory and player.components.inventory:FindItems(checkifitemisleader) or {}
	for j = 1, #leader_items do
	    for follower, _ in pairs(leader_items[j].components.leader.followers) do
		if not follower:HasTag("critter") and (follower.components.health == nil or not follower.components.health:IsDead())
		    and (follower.components.combat == nil or follower.components.combat.target ~= inst)
		    and follower:GetDistanceSqToPoint(x, y, z) <= (TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_RANGE * TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_RANGE) then
		    table.insert(all_targets, follower)
		end
	    end
	end

	-- add any other per-player searching here
    end
    return all_targets
end

local function CheckValidAttackData(attacker, data)
    if data then
	if data.projectile and data.projectile.components.projectile and data.projectile.components.projectile:IsBounced() then
	    --bounced projectiles don't count
	    return false
	elseif data.weapon and data.weapon.components.inventoryitem == nil then
	    --fake "weapons" used for detached aoe dmg don't count (e.g. flamethrower_fx)
	    return false
	elseif data.target then
	    --damaging a non living target
	    if not (data.target.components.health and data.target.components.combat) or data.target:HasTag("wall") or data.target:HasTag("engineering") then
		return false
	    end
	end
    end
    return true
end

local function ApplyHonorOfGallowmere(inst, target)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil

    --Shout
    if owner ~= nil and target ~= owner and target:HasTag("character") and target.components.talker then
	target.sg:GoToState("talk")
	target.components.talker:Say(STRINGS.ANNOUNCE_SDF_HELMET_FOLLOWER_SHOUT, 4)
    end

    --Buffs
    if target._sdf_helmet_honor_of_gallowmere_FX == nil then
	--Buff Animation / Holder
	target._sdf_helmet_honor_of_gallowmere_FX = SpawnPrefab("sdf_helmet_honor_of_gallowmere_fx")
	target:AddChild(target._sdf_helmet_honor_of_gallowmere_FX)
	local scale = Remap(target:GetPhysicsRadius() or 0, 0, 5, 0.5, 8)
	target._sdf_helmet_honor_of_gallowmere_FX.Transform:SetScale(scale, scale, scale)
	target._sdf_helmet_honor_of_gallowmere_FX.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")

	--Buff Effects
	--Sanity Boost
	if owner ~= nil and owner ~= target and target.components.sanity then
	    target.components.sanity:DoDelta(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SANITY_BONUS)
	end

	--Movement Speed
	local buffkey = target._sdf_helmet_honor_of_gallowmere_FX.prefab
	if target.components.locomotor ~= nil then
	    target.components.locomotor:SetExternalSpeedMultiplier(target, buffkey, TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_MOVEMENT_SPEED_BONUS)
	end

	--Leech Health
	if target.components.health then
	    target._sdf_helmet_honor_of_gallowmere_FX:ListenForEvent("onattackother", function(attacker, data)
		if CheckValidAttackData(attacker, data) then
		    attacker.components.health:DoDelta(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_LEECH_BONUS)
		end
	    end, target)
	end

	--Attack vs Darkness
	if target.components.damagetypebonus ~= nil then
	    target.components.damagetypebonus:AddBonus("shadow_aligned", target, TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SHADOW_VS_BONUS, "sdf_skilltree_honor_to_gallowmere_attack")
	end

	--Defense vs Darkness
	if target.components.damagetyperesist ~= nil then
	    target.components.damagetyperesist:AddResist("shadow_aligned", target, TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_SHADOW_RESIST_BONUS, "sdf_skilltree_honor_to_gallowmere_defense")
	end

	--Buff Removal
	target:DoTaskInTime(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_BUFF_TIME, function()
	    --Remove Movement Speed
	    if target.components.locomotor ~= nil then
		target.components.locomotor:RemoveExternalSpeedMultiplier(target, buffkey)
	    end

	    --Remove Attack vs Darkness
            if target.components.damagetypebonus ~= nil then
                target.components.damagetypebonus:RemoveBonus("shadow_aligned", target, "sdf_skilltree_honor_to_gallowmere_attack")
            end

	    --Remove Defense vs Darkness
	    if target.components.damagetyperesist ~= nil then
                target.components.damagetyperesist:RemoveResist("shadow_aligned", target, "sdf_skilltree_honor_to_gallowmere_defense")
            end

	    --Remove Animation
	    target._sdf_helmet_honor_of_gallowmere_FX:goAwayFn()
	    target._sdf_helmet_honor_of_gallowmere_FX = nil
	end)
    end
end

local function CastHonorOfGallowmere(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil

    --use Helm
    if inst.components.rechargeable and inst.components.rechargeable:IsCharged() then
	if owner ~= nil then
	    --Shout
	    owner.components.talker:Say(STRINGS.ANNOUNCE_SDF_HELMET_LEADER_SHOUT, 4)

	    --AOE Buff
	    inst:DoTaskInTime(1, function()
		--Appy buff
		local targets = FindFriendlyTargets(inst)
		for _, target in ipairs(targets) do
		    ApplyHonorOfGallowmere(inst, target)
		end
	    end)

	    --Start Cooldown
	    if inst.components.rechargeable then
	        inst.components.rechargeable:Discharge(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_COOLDOWN_NORMAL)
	    end
	end
    else
	if owner ~= nil then
	    owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_HELMET_COOLDOWN"))
	end
    end

    inst.components.useableitem:StopUsingItem()
    return false
end

local function OnPutInInventory(inst, owner)
    if owner.prefab == "sdf" then

	if TUNING.SDF_FATES_ARROW == true then
	    local helm = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	    if helm ~= nil and helm.prefab == "sdf_helmet" then
		inst:DoTaskInTime(0.1, function(inst)
		    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
		    if holder ~= nil then
			holder:DropItem(inst)
			if owner.components.talker then
			    owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_NO_EQUIP_DOUBLE"))
			end
		    end
		end)
	    elseif owner.components.inventory:Has("sdf_helmet", 2, true) then
		inst:DoTaskInTime(0.1, function(inst)
		    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
		    if holder ~= nil then
			holder:DropItem(inst)
			if owner.components.talker then
			    owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_NO_EQUIP_DOUBLE"))
			end
		    end
		end)
	    end
	end
    end
end

local function onequip(inst, owner, symbol_override)
    --Switches character model
    if owner.prefab == "sdf" then

	--locks helm for Fates Arrow Mode
	if TUNING.SDF_FATES_ARROW == true then
	    inst.components.equippable:SetPreventUnequipping(true)
	end

	--Check for Skill buff
	--SkillTree Honor of Gallowmere
	if owner.components.skilltreeupdater:IsActivated("sdf_undeath_10") then

	    --Set Honor of Gallowmere
	    inst:AddComponent("useableitem")
	    inst.components.useableitem:SetOnUseFn(CastHonorOfGallowmere)

	    --Start cooldown
	    if TUNING.SDF_FATES_ARROW == false then
		if inst.components.rechargeable and inst.components.rechargeable:IsCharged() then
		    inst.components.rechargeable:Discharge(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_COOLDOWN_SHORT)
		end
	    end
	end

	--animation
	local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	if body then
	    if body.prefab == "sdf_victorian_suit" then
		--Skill Tree Eye of Amon Ra
		if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    owner:MakeVictorianHelmetEye()
		else
		    owner:MakeVictorianHelmet()
		end
		inst.components.inventoryitem.imagename = "sdf_victorian_helmet"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_victorian_helmet.xml"

	    elseif body.prefab == "sdf_gold_armor" then
		--Skill Tree Eye of Amon Ra
		if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    owner:MakeGoldHelmetEye()
		else
		    owner:MakeGoldHelmet()
		end
		inst.components.inventoryitem.imagename = "sdf_gold_helmet"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_gold_helmet.xml"
	    elseif body.prefab == "sdf_dragon_potion" then
		--Skill Tree Eye of Amon Ra
		if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    owner:MakeDragonHelmetEye()
		else
		    owner:MakeDragonHelmet()
		end
		inst.components.inventoryitem.imagename = "sdf_dragon_helmet"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_dragon_helmet.xml"
	    else
		--Skill Tree Eye of Amon Ra
		if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    owner:MakeNormalHelmetEye()
		else
		    owner:MakeNormalHelmet()
		end
		inst.components.inventoryitem.imagename = "sdf_helmet"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_helmet.xml"
	    end
	else
	    --Skill Tree Eye of Amon Ra
	    if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		owner:MakeNormalHelmetEye()
	    else
		owner:MakeNormalHelmet()
	    end
	    inst.components.inventoryitem.imagename = "sdf_helmet"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_helmet.xml"
	end

	owner.AnimState:Hide("HEAD")
	owner.AnimState:Show("HEAD_HAT")

	--Take extra damage when worn
	owner.components.combat.externaldamagetakenmultipliers:SetModifier(owner, TUNING.SDF_HELMET_BONUS_DAMAGE_TAKEN, "sdf_helmet")
    else

	--Stops others from wearing
	inst:DoTaskInTime(0.1, function()
	local head = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	    if head then
		if owner.components.talker then
		    owner.components.talker:Say(GetString(owner, "ANNOUNCE_NODANIELHELMET"))
		end
		local item = owner.components.inventory:Unequip(EQUIPSLOTS.HEAD)
		owner.components.inventory:GiveItem(item)
	    end
	end)
    end

end

local function onunequip(inst, owner)
    --switches character model
    if owner.prefab == "sdf" then

	--[[if TUNING.SDF_FATES_ARROW == true and not owner.components.health:IsDead() then
	    --Keeps helmet equipped during fates arrow
	    inst:DoTaskInTime(0.1, function()
		local owner_Inventory = owner.components.inventory
		owner_Inventory:Equip(inst)
		if owner.components.talker then
		    owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_HELMET_NO_UNEQUIP"))
		end
    	    end)
	else]]

	    --Check for Skill buff
	    --SkillTree Honor of Gallowmere
	    if owner.components.skilltreeupdater:IsActivated("sdf_undeath_10") then

		--Start cooldown
		if TUNING.SDF_FATES_ARROW == false then

		    --Remove Honor of Gallowmere
		    inst:RemoveComponent("useableitem")

		    --Apply Long Cooldown
		    if inst.components.rechargeable then
			inst.components.rechargeable:Discharge(TUNING.SDF_SKILLSET_UNDEATH_HONOR_OF_GALLOWMERE_COOLDOWN_LONG)
		    end
		end

	    end

	    local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	    if body then
		if body.prefab == "sdf_victorian_suit" then
		    if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
			owner:MakeVictorianSuitEye()
		    else
			owner:MakeVictorianSuit()
		    end
		elseif body.prefab == "sdf_gold_armor" then
		    if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
			owner:MakeGoldArmorEye()
		    else
			owner:MakeGoldArmor()
		    end
		elseif body.prefab == "sdf_dragon_potion" then
		    if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
			owner:MakeDragonArmorEye()
		    else
			owner:MakeDragonArmor()
		    end
		end
	    else
		if owner.components.skilltreeupdater:IsActivated("sdf_skull_1") then
		    owner:MakeNormalArmorEye()
		else
		    owner:MakeNormalArmor()
		end
	    end
	    inst.components.inventoryitem.imagename = "sdf_helmet"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_helmet.xml"

	    owner.AnimState:Show("HEAD")
	    owner.AnimState:Hide("HEAD_HAT")

	    --Return to normal damage taken

	    owner.components.combat.externaldamagetakenmultipliers:RemoveModifier(owner, "sdf_helmet")
	--end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_helmet_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_helmet")
    inst.AnimState:SetBuild("sdf_helmet")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    inst:AddComponent("inspectable")

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_helmet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_helmet.xml"

    --inst:AddComponent("armor")
    --inst.components.armor:InitCondition(0) --0 durability
    --inst.components.armor.ontakedamage = OnTakeDamage
    --inst.components.armor.SetCondition = function(self,amount)
	--self.condition = math.min(amount, self.maxcondition)
    	--self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	--self:SetAbsorption(0)
    --end

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_helmet", fn, assets)