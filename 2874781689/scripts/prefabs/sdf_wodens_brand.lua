local assets =
{
    Asset("ATLAS", "images/inventoryimages/sdf_wodens_brand.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_wodens_brand.tex"),

    Asset("ATLAS", "images/map_icons/sdf_wodens_brand_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_wodens_brand_mm.tex"),

    Asset("ANIM", "anim/sdf_wodens_brand.zip"),
    Asset("ANIM", "anim/swap_sdf_wodens_brand.zip"),
}

local prefabs =
{
    "reticulearc",
    "reticulearcping",
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

------------------------------------------------------------------------------------------------------------------------
local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object","swap_sdf_wodens_brand","bustersword")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    --Adjust Combat stats
    if inst.components.armor.condition > 0 then
    	owner.components.combat:SetAttackPeriod(TUNING.SDF_WODENS_BRAND_ATTACK_SPEED)

	--Add Light
	inst.Light:Enable(true)
    else
	--Broken
    	owner.components.combat:SetAttackPeriod(TUNING.SDF_WODENS_BRAND_BROKEN_ATTACK_SPEED)

	--Remove special animation
	if inst:HasTag("sdf_propweapon") then
	    inst:RemoveTag("sdf_propweapon")
	end
    end
    owner.components.combat:SetAreaDamage(TUNING.SDF_WODENS_BRAND_AOE_RANGE, 0.33)


    --Check Body slot
    local owner_Inventory = owner.components.inventory
    local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if bodySlot then
	if bodySlot.prefab ~= "sdf_dragon_potion" then

	    --Start equip cooldown
	    if inst.components.rechargeable:GetTimeToCharge() < TUNING.SDF_WODENS_BRAND_COOLDOWN_ONEQUIP then
		inst.components.rechargeable:Discharge(TUNING.SDF_WODENS_BRAND_COOLDOWN_ONEQUIP)
	    end
	end
    else

	--Start equip cooldown
	if inst.components.rechargeable:GetTimeToCharge() < TUNING.SDF_WODENS_BRAND_COOLDOWN_ONEQUIP then
	    inst.components.rechargeable:Discharge(TUNING.SDF_WODENS_BRAND_COOLDOWN_ONEQUIP)
	end
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    --Remove Light
    inst.Light:Enable(false)
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    owner.components.combat.areahitrange = nil
end

------------------------------------------------------------------------------------------------------------------------

local function SpellFn(inst, doer, pos)

    --Add Absorb Damage
    if inst.components.armor.condition > 0 then
	inst.components.armor:SetAbsorption(1)
    end

    --Parry Animation
    inst.components.parryweapon:EnterParryState(doer, doer:GetAngleToPoint(pos), TUNING.SDF_WODENS_BRAND_PARRY_DURATION)
    inst.components.rechargeable:Discharge(TUNING.SDF_WODENS_BRAND_COOLDOWN)

    --Normal Animation
    doer:DoTaskInTime(TUNING.SDF_WODENS_BRAND_PARRY_DURATION + 0.6, function()

	--Remove Absorb Damage
	inst.components.armor:SetAbsorption(0)
    end)

end

local function OnParry(inst, doer, attacker, damage)
    doer:ShakeCamera(CAMERASHAKE.SIDE, 0.1, 0.03, 0.3)

    --Broken
    if inst.components.armor.condition <= 0 and damage > 0 then

	--Parry Reduction
	if inst.components.rechargeable:GetPercent() < TUNING.SDF_WODENS_BRAND_COOLDOWN_ONPARRY_REDUCTION then
	    inst.components.rechargeable:SetPercent(TUNING.SDF_WODENS_BRAND_COOLDOWN_ONPARRY_REDUCTION)
	end

	--Damage to User
	inst:DoTaskInTime(0.1, function()
	    local damageTotal = (damage * TUNING.SDF_WODENS_BRAND_BROKEN_PROTECTION)
	    doer.components.combat:GetAttacked(attacker, damageTotal)
	end)
	doer.sg:GoToState("sdf_wodens_brand_knockback")
    else
	--parryblockfx
	--"wortox_resist_fx"

	--Stun Attacker
	if attacker ~= nil and attacker:IsValid() and attacker.components.combat ~= nil and not
	    (attacker:HasTag("player") or attacker:HasTag("playerghost") or attacker:HasTag("INLIMBO") or attacker:HasTag("epic")) then
	    --Stun effect
	    attacker.components.combat:BlankOutAttacks(TUNING.SDF_WODENS_BRAND_PARRY_STUN_DEBUFF_DURATION)
	end

	--Damage to Weapon
	inst.components.armor:TakeDamage(damage)

	--Parry Reduction
	if inst.components.rechargeable:GetPercent() < TUNING.SDF_WODENS_BRAND_COOLDOWN_ONPARRY_REDUCTION then
	    inst.components.rechargeable:SetPercent(TUNING.SDF_WODENS_BRAND_COOLDOWN_ONPARRY_REDUCTION)
	end

	--Parry Damage Bonus
        inst._lastparrytime = GetTime()

        local tuning = TUNING.SDF_WODENS_BRAND_PARRY_BONUS_DAMAGE
        local scale =  TUNING.SDF_WODENS_BRAND_PARRY_BONUS_DAMAGE_SCALE

        inst._bonusdamage = math.clamp(damage * scale, tuning.min, tuning.max)
    end
end

local function DamageFn(inst)
    --Broken
    if inst.components.armor.condition <= 0 then
	inst.components.planardamage:SetBaseDamage(0)
	return TUNING.SDF_WODENS_BRAND_BROKEN_DAMAGE
    end

    --Parry Bonus Damage
    if inst._lastparrytime ~= nil and (inst._lastparrytime + TUNING.SDF_WODENS_BRAND_PARRY_BONUS_DAMAGE_DURATION) >= GetTime() then
        return TUNING.SDF_WODENS_BRAND_DAMAGE + (inst._bonusdamage or 0)
    end

    --Planar Damage
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_WODENS_BRAND_PLANAR_DAMAGE)

    return TUNING.SDF_WODENS_BRAND_DAMAGE
end

local function OnAttackFn(inst, attacker, target)
    --Swingfx
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/swipe")

    --onHitfx
    --"wortox_soul_spawn_fx"

    --Random Animation
    local random=math.random()
    if random<0.2 then --jab
	if not inst:HasTag("sdf_jabweapon") then
	    inst:AddTag("sdf_jabweapon")
	end
	if inst:HasTag("sdf_propweapon") then
	    inst:RemoveTag("sdf_propweapon")
	end
    else --slash
	if not inst:HasTag("sdf_propweapon") then
	    inst:AddTag("sdf_propweapon")
	end
	if inst:HasTag("sdf_jabweapon") then
	    inst:RemoveTag("sdf_jabweapon")
	end
    end

    inst._lastparrytime = nil
    inst._bonusdamage = nil

    inst.components.armor:TakeDamage(TUNING.SDF_WODENS_BRAND_USEDAMAGE)
end

local function OnDischarged(inst)
    inst.components.aoetargeting:SetEnabled(false)
end

local function OnCharged(inst)
    inst.components.aoetargeting:SetEnabled(true)
end

local function ondropped(inst)
    if inst.components.armor and inst.components.armor.condition <= 0 then
	inst.Light:Enable(false)
    end
end

local function gorgeUpdate(inst)
    if inst.components.armor.condition > 0 then
	--Correct Damage
	inst.components.weapon:SetDamage(DamageFn)
	inst.components.planardamage:SetBaseDamage(TUNING.SDF_WODENS_BRAND_PLANAR_DAMAGE)

	--Correct Attack Speed
	local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
	if owner and owner.components.combat then
	    owner.components.combat:SetAttackPeriod(TUNING.SDF_WODENS_BRAND_ATTACK_SPEED)
	end

	--Add Light
	inst.Light:Enable(true)

	--Add special animation
	inst:AddTag("sdf_propweapon")
    end
end

local function OnLoad(inst, data)
    if inst.components.armor and inst.components.armor.condition <= 0 then
	inst.Light:Enable(false)

	--Remove special animation
	if inst:HasTag("sdf_propweapon") then
	    inst:RemoveTag("sdf_propweapon")
	end
    end
end

------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddLight()
    inst.Light:SetRadius(0.45)
    inst.Light:SetFalloff(1.0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(250/255,40/255,40/255)	

    inst.MiniMapEntity:SetIcon("sdf_wodens_brand_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_wodens_brand")
    inst.AnimState:SetBuild("sdf_wodens_brand")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("sdf_propweapon")
    inst:AddTag("weapon")
    inst:AddTag("parryweapon")
    inst:AddTag("rechargeable")
    inst:AddTag("sdf_wodens_brand_gorge")

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

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows to be healed by blood
    inst:AddComponent("sdf_wodens_brand_gorge")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_wodens_brand"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_wodens_brand.xml"

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(DamageFn)
    inst.components.weapon:SetOnAttack(OnAttackFn)

    inst:AddComponent("planardamage")

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.SDF_WODENS_BRAND_DURABILITY, 0)
    inst.components.armor.TakeDamage = function(self,damage_amount)

	self:SetCondition(self.condition - (damage_amount* (TUNING.SDF_WODENS_BRAND_PROTECTION)))
	if self.ontakedamage ~= nil then
	    self.ontakedamage(self.inst, damage_amount)
	end
	self.inst:PushEvent("armordamaged", damage_amount)
    end

    inst.components.armor.SetCondition = function(self,amount)
	self.condition = math.min(amount, self.maxcondition)
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	if self.condition <= 0 then
	    self:SetAbsorption(0)
	    local owner = self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner or nil
	    if owner and owner.components.combat then
		owner.components.combat:SetAttackPeriod(TUNING.SDF_WODENS_BRAND_BROKEN_ATTACK_SPEED)
	    end
	    self.inst.Light:Enable(false)

	    --Remove special animation
	    if self.inst:HasTag("sdf_propweapon") then
		 self.inst:RemoveTag("sdf_propweapon")
	    end
	end
    end

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable.restrictedtag = "sdf_wodens_brand_builder"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.SDF_WODENS_BRAND_SPEED_MULT

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(SpellFn)

    inst:AddComponent("parryweapon")
    inst.components.parryweapon:SetParryArc(TUNING.SDF_WODENS_BRAND_PARRY_ARC)
    inst.components.parryweapon:SetOnParryFn(OnParry)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst.GorgeUpdateFn = function() gorgeUpdate(inst) end

    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("sdf_wodens_brand", fn, assets, prefabs)