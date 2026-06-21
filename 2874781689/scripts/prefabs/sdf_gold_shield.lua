local assets =
{
    Asset("ATLAS", "images/inventoryimages/sdf_gold_shield.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_gold_shield.tex"),

    Asset("ATLAS", "images/map_icons/sdf_gold_shield_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_gold_shield_mm.tex"),

    Asset("ANIM", "anim/sdf_gold_shield.zip"),
    Asset("ANIM", "anim/swap_sdf_gold_shield.zip"),
}

local prefabs =
{
    "reticulearc",
    "reticulearcping",
}

------------------------------------------------------------------------------------------------------------------------
--Shield Blocking
local SHIELD_DURATION = 10 * FRAMES * 2
local RESISTANCES =
{
    "_combat",
    "explosive",
    "quakedebris",
    "caveindebris",
    "trapdamage",
}
------------------------------------------------------------------------------------------------------------------------

local function ReticuleTargetFn()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleMouseTargetFn(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 6.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end

local function EnableReticule(inst, enable)
    if enable then
        if inst.components.reticule == nil then
            inst:AddComponent("reticule")
            inst.components.reticule.reticuleprefab = "reticulearc"
	    inst.components.reticule.pingprefab = "reticulearcping"
            inst.components.reticule.targetfn = ReticuleTargetFn
	    inst.components.reticule.mousetargetfn = ReticuleMouseTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
	    inst.components.reticule.validcolour = { 1, .75, 0, 1 }
	    inst.components.reticule.invalidcolour = { .5, 0, 0, 1 }
	    inst.components.reticule.ease = true
	    inst.components.reticule.mouseenabled = true
	    inst.components.reticule.ispassableatallpoints = true
            if inst.components.playercontroller ~= nil and inst == ThePlayer then
                inst.components.playercontroller:RefreshReticule()
            end
        end
    elseif inst.components.reticule ~= nil then
        inst:RemoveComponent("reticule")
        if inst.components.playercontroller ~= nil and inst == ThePlayer then
            inst.components.playercontroller:RefreshReticule()
        end
    end
end

------------------------------------------------------------------------------------------------------------------------

local function SpellFn(inst, doer, pos)
    --Parry Animation
    inst.components.parryweapon:EnterParryState(doer, doer:GetAngleToPoint(pos), TUNING.SDF_SHIELD_PARRY_DURATION)
    inst.components.rechargeable:Discharge(TUNING.SDF_SHIELD_COOLDOWN)
end

local function onCancelParry(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner then

	inst.components.aoetargeting:StopTargeting()

	--Remove Bonus Armor
	inst.BonusArmor = 0

	--stop parry
	owner:SDF_ShieldParryRemoveFn()
	owner:SDF_ShieldParryDisableFn()

	--start talking
	if owner.components.talker then
	    owner.components.talker:StopIgnoringAll()
	end

	--animation restore
	owner.AnimState:ClearOverrideSymbol("lantern_overlay")
	owner.AnimState:ClearOverrideSymbol("swap_shield")
	owner.AnimState:Hide("LANTERN_OVERLAY")
	owner.AnimState:ShowSymbol("swap_object")

	--Switch back to hand
	local handsItem =  owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsItem then
	    handsItem.components.equippable.onequipfn(handsItem,  owner)
	else
	    owner.AnimState:Hide("ARM_carry")
	    owner.AnimState:Show("ARM_normal")
	end

	--Add torch like effects back to sdf_club
	if handsItem and handsItem.prefab == "sdf_club" and handsItem.components.burnable:IsBurning() then
	    owner.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
	    if handsItem.fires == nil then
		handsItem.fires = {}

		local fx = SpawnPrefab("torchfire")
		fx.entity:SetParent(owner.entity)
		fx.entity:AddFollower()
		fx.Follower:FollowSymbol(owner.GUID, "swap_object", 10, -200, 0)
		fx:AttachLightTo(owner)

		table.insert(handsItem.fires, fx)
	    end
	end
    end
end

local function OnParry(inst, doer, attacker, damage)
    doer:ShakeCamera(CAMERASHAKE.SIDE, 0.1, 0.03, 0.3)

    --Broken
    if inst.components.armor.condition <= 0 and damage > 0 then

	--Parry Reduction
	if inst.components.rechargeable:GetPercent() < TUNING.SDF_SHIELD_COOLDOWN_ONPARRY_REDUCTION then
	    inst.components.rechargeable:SetPercent(TUNING.SDF_SHIELD_COOLDOWN_ONPARRY_REDUCTION)
	end

	--Damage to User
	inst:DoTaskInTime(0.1, function()
	    local damageTotal = (damage * TUNING.SDF_SHIELD_BROKEN_PROTECTION)
	    doer.components.combat:GetAttacked(attacker, damageTotal)
	end)
	doer.sg:GoToState("sdf_shield_parry_knockback")
    else

	--Stun Attacker
	if attacker ~= nil and attacker:IsValid() and attacker.components.combat ~= nil and not
	    (attacker:HasTag("player") or attacker:HasTag("playerghost") or attacker:HasTag("INLIMBO") or attacker:HasTag("epic")) then
	    --Stun effect
	    attacker.components.combat:BlankOutAttacks(TUNING.SDF_SHIELD_PARRY_STUN_DEBUFF_DURATION)
	end

	--Damage to Shield
	local damagetotal = (damage * (TUNING.SDF_SHIELD_PROTECTION - inst.BonusArmor))
	inst.components.armor:TakeDamage(damagetotal)

	--Parry Reduction
	if inst.components.rechargeable:GetPercent() < TUNING.SDF_SHIELD_COOLDOWN_ONPARRY_REDUCTION then
	    inst.components.rechargeable:SetPercent(TUNING.SDF_SHIELD_COOLDOWN_ONPARRY_REDUCTION)
	end

	--Parry Damage Bonus
	inst._lastparrytime = GetTime()

	local tuning = TUNING.SDF_SHIELD_PARRY_BONUS_DAMAGE
	local scale =  TUNING.SDF_SHIELD_PARRY_BONUS_DAMAGE_SCALE

	inst._bonusdamage = math.clamp(damage * scale, tuning.min, tuning.max)

	--Remove Parry Daring Dash Bonus Damage
	if inst._parry_bonus_damage_duration_bufftask ~= nil then
	    inst._parry_bonus_damage_duration_bufftask = nil
	end
	inst._parry_bonus_damage_duration_bufftask = inst:DoTaskInTime(TUNING.SDF_SHIELD_PARRY_BONUS_DAMAGE_DURATION, function(i)
	    i._bonusdamage = nil
	    i._parry_bonus_damage_duration_bufftask = nil
	end)

	--animation restore
	doer:DoTaskInTime(0.7, function()
	    onCancelParry(inst)
	end)
    end
end

local function DamageFn(inst)
    --Parry Bonus Damage for Daring Dash
    if inst._lastparrytime ~= nil and (inst._lastparrytime + TUNING.SDF_SHIELD_PARRY_BONUS_DAMAGE_DURATION) >= GetTime() then
        return TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE + (inst._bonusdamage or 0)
    end

    return TUNING.SDF_SKILLSET_BACKBONE_DARING_DASH_ATTACK_DAMAGE
end

local function OnAttackFn(inst, attacker, target)
    inst._lastparrytime = nil
    inst._bonusdamage = nil
end

local function OnDischarged(inst)
    inst:RemoveTag("sdf_shield_daring_dash_ready")
    inst:RemoveTag("sdf_shield_parry")
    inst.components.aoetargeting:SetEnabled(false)
end

local function OnCharged(inst)
    inst:AddTag("sdf_shield_daring_dash_ready")
    inst:AddTag("sdf_shield_parry")
    inst.components.aoetargeting:SetEnabled(true)
end

------------------------------------------------------------------------------------------------------------------------
local function OnBreak(owner, data)
    if owner ~= nil then
	local shield = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.SHIELD)
	if data.armor == shield then

	    if owner:HasTag("sdf_shield_parry_action_active") then
		owner:RemoveTag("sdf_shield_parry_action_active")
	    end

	    --can drop shield
	    owner:RemoveTag("nosteal")
	    owner:RemoveTag("stickygrip")

	    --Skill Tree Daring Dash
	    if owner.prefab == "sdf" and owner.components.skilltreeupdater:IsActivated("sdf_backbone_1") then
		if owner:HasTag("sdf_daring_dash_action_active") then
		    owner:RemoveTag("sdf_daring_dash_action_active")
		end
	    else
		owner.sg:GoToState("hit")
	    end
	end
    end
end

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("anim")
end

local function OnEquip(inst, owner)
    --Ding Sound
    if owner.SoundEmitter then
	owner.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl1_ding")
    end


    --Check Hands slot
    local owner_Inventory = owner.components.inventory
    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if owner:HasTag("sdf_thrown_arm") then
	--Can't equip shield
	if owner.components.talker then
	    owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_SHIELD_NO_UNEQUIP"))
	end
	inst:DoTaskInTime(0.1, function()
	    owner_Inventory:DropItem(inst)
	    owner_Inventory:GiveItem(inst)
	end)
    else
	--Start cooldown
	if inst.components.rechargeable:GetTimeToCharge() < TUNING.SDF_SHIELD_COOLDOWN_ONEQUIP then
	    inst.components.rechargeable:Discharge(TUNING.SDF_SHIELD_COOLDOWN_ONEQUIP)
	end
	inst:ListenForEvent("armorbroke", OnBreak, owner)
    end
end

local function OnUnequip(inst, owner)
    --Remove Shield
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:ClearOverrideSymbol("swap_shield")
    owner.AnimState:Hide("lantern_overlay")
    owner.AnimState:ShowSymbol("swap_object")

    --Skill Tree Daring Dash
    if owner.prefab == "sdf" and owner.components.skilltreeupdater:IsActivated("sdf_backbone_1") then
	owner:SkilltreeDaringDashRemoveFn()
	owner:SkilltreeDaringDashDisableFn()
    end

    --Switch back to hand
    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if handsSlot then
	handsSlot.components.equippable.onequipfn(handsSlot, owner)
    else
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
    end

    --Start cooldown
    if inst.components.rechargeable:GetTimeToCharge() < TUNING.SDF_SHIELD_COOLDOWN_ONEQUIP then
	inst.components.rechargeable:Discharge(TUNING.SDF_SHIELD_COOLDOWN_ONEQUIP)
    end

    inst.components.aoetargeting:StopTargeting()
    inst:RemoveEventCallback("armorbroke", OnBreak, owner)
    inst.BonusArmor = 0
end

------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_gold_shield_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_gold_shield")
    inst.AnimState:SetBuild("sdf_gold_shield")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("toolpunch")
    inst:AddTag("weapon")
    inst:AddTag("parryweapon")
    inst:AddTag("sdf_shield")
    inst:AddTag("shield")
    inst:AddTag("rechargeable")

    inst:AddTag("sdf_shield_parry")
    inst:AddTag("sdf_shield_daring_dash")
    inst:AddTag("sdf_shield_daring_dash_ready")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulearc"
    inst.components.aoetargeting.reticule.pingprefab = "reticulearcping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting:SetAllowRiding(false)

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_gold_shield"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_gold_shield.xml"

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(DamageFn)
    inst.components.weapon:SetOnAttack(OnAttackFn)

    inst:AddComponent("armor")
    inst.DaringDashArmor = 0 --SDF Skill Tree Daring Dash
    inst.BonusArmor = 0 --SDF Skill Tree Steadfast
    inst.components.armor:InitCondition(TUNING.SDF_GOLD_SHIELD_DURABILITY, 0)
    inst.components.armor.TakeDamage = function(self,damage_amount)

	if inst.DaringDashArmor == 0 then
	    self:SetCondition(self.condition - damage_amount)
	else
	    self:SetCondition(self.condition - (damage_amount* self.inst.DaringDashArmor))
	end
	if self.ontakedamage ~= nil then
	    self.ontakedamage(self.inst, damage_amount)
	end
	self.inst:PushEvent("armordamaged", damage_amount)
    end

    inst.components.armor.SetCondition = function(self,amount)
	self.condition = math.min(amount, self.maxcondition)
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
    end

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.SHIELD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("parryweapon")
    inst.components.parryweapon:SetParryArc(TUNING.SDF_SHIELD_PARRY_ARC)
    inst.components.parryweapon:SetOnParryFn(OnParry)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst.daring_dash_bonus_damage = 0

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("sdf_gold_shield", fn, assets, prefabs)