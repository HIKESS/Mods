local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_rune_holder.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_rune_holder.tex"),

    Asset("ANIM", "anim/sdf_rune_holder.zip"),

    Asset("IMAGE", "images/inv_slot/inv_slot_time_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_time_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_moon_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_moon_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_earth_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_earth_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_star_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_star_rune.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_chaos_rune.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_chaos_rune.xml"),
}

prefabs = {
}

local RuneHolderWidgetParams =
{
    widget =
    {
	slotpos = {
	    Vector3(0, -208, 0), ---222
	    Vector3(0, -132, 0), ---146
	    Vector3(0, -54, 0), ---70
	    Vector3(0, 20, 0), --6
	    Vector3(0, 96, 0), --82
	},
        slotbg =
        {
            { image = "inv_slot_time_rune.tex", atlas = "images/inv_slot/inv_slot_time_rune.xml" },
            { image = "inv_slot_moon_rune.tex", atlas = "images/inv_slot/inv_slot_moon_rune.xml" },
            { image = "inv_slot_earth_rune.tex", atlas = "images/inv_slot/inv_slot_earth_rune.xml" },
            { image = "inv_slot_star_rune.tex", atlas = "images/inv_slot/inv_slot_star_rune.xml" },
            { image = "inv_slot_chaos_rune.tex", atlas = "images/inv_slot/inv_slot_chaos_rune.xml" },
        },
	animbank = "ui_sdf_rune_holder",
	animbuild = "ui_sdf_rune_holder",
	pos = Vector3(0, 0, 0)
    },
    issidewidget = false,
    type = "sdf_rune_holder",
}

local function RuneHolderWidgetHUDPositionFn(self, doer)
  if not TheNet:IsDedicated() then
    local hudscaleadjust = Profile:GetHUDSize() *2
    local qs_pos = INVINFO.EQUIPSLOT_rune:GetWorldPosition()

    if doer and doer.HUD and doer.HUD.controls then		
      if doer.HUD.controls.containers[self.inst].RuneHolderHasAnchor == nil then
        doer.HUD.controls.containers[self.inst].RuneHolderHasAnchor = true

        doer.HUD.controls.containers[self.inst]:SetVAnchor(ANCHOR_BOTTOM)
        doer.HUD.controls.containers[self.inst]:SetHAnchor(ANCHOR_LEFT)
      end

      if doer.HUD.controls.containers[self.inst] then
        doer.HUD.controls.containers[self.inst]:UpdatePosition(qs_pos.x, (qs_pos.y+180+hudscaleadjust))
      end
    end
  end
end

function RuneHolderWidgetParams.itemtestfn(container, item, slot)
    if slot == 1 and item:HasTag("sdf_time_rune") then
	return true
    elseif slot == 2 and item:HasTag("sdf_moon_rune") then
	return true
    elseif slot == 3 and item:HasTag("sdf_earth_rune") then
	return true
    elseif slot == 4 and item:HasTag("sdf_star_rune") then
	return true
    elseif slot == 5 and item:HasTag("sdf_chaos_rune") then
	return true
    else
	return false
    end
end

local RUNE_HOLDER_FIRST_OPEN = false --Use for first time rune holder slot opens

local function OnPutInInventory(inst, owner)
    if owner.prefab == "sdf" then
	local runeHolder = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.RUNE)
	if runeHolder ~= nil and runeHolder.prefab == "sdf_rune_holder" then
	    inst:DoTaskInTime(0.1, function(inst)
		local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
		if holder ~= nil then
		    holder:DropItem(inst)
		    if owner.components.talker then
			owner.components.talker:Say(GetString(owner, "ANNOUNCE_SDF_NO_EQUIP_DOUBLE"))
		    end
		end
	    end)
	elseif owner.components.inventory:Has("sdf_rune_holder", 2, true) then
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

--Special Trait Time Animation
local function TimeRuneTintFX(inst, val)
    local r = 255
    local g = 255
    local b = 255
    if val > 0 then
        inst.components.colouradder:PushColour("portaltint", r / 255 * val, g / 255 * val, b / 255 * val, 0)
        val = 1 - val
        inst.AnimState:SetMultColour(val, val, val, 1)
    else
        inst.components.colouradder:PopColour("portaltint")
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
end
local function OnDodgeAttack(owner)
    if owner then
	owner._sdf_time_rune_dodgeFX = SpawnPrefab("sdf_time_rune_gears_fx")
	owner._sdf_time_rune_dodgeFX.entity:SetParent(owner.entity)
	TimeRuneTintFX(owner, 1)

	owner.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post", nil, .7)
	owner.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)

	owner:DoTaskInTime(0.5, function()
	    TimeRuneTintFX(owner, 0)

	    owner.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out") 
	end)
    end
end
local function CanDodgeAttackChaos(owner, attacker)
    local dodgeRng = math.random()
    if dodgeRng <= TUNING.SDF_TIME_RUNE_DODGE_CHANCE_SDF_CHAOS then
	return true
    end
    return false
end
local function CanDodgeAttack(owner, attacker)
    local dodgeRng = math.random()
    if dodgeRng <= TUNING.SDF_TIME_RUNE_DODGE_CHANCE_SDF then
	return true
    end
    return false
end

--Special Trait Moon Animation
local function OnReflectDamage(inst, data)
    if data ~= nil and data.attacker ~= nil and data.attacker:IsValid() then
	SpawnPrefab("hitsparks_reflect_fx"):Setup(inst.components.inventoryitem.owner or inst, data.attacker)
    end
end
local function ReflectDamageChaosFn(inst, attacker, damage, weapon, stimuli, spdamage)
    return 0,
	{
	    planar = attacker ~= nil and TUNING.SDF_MOON_RUNE_SHARD_DAMAGE_SDF_CHAOS,
	}
end
local function ReflectDamageFn(inst, attacker, damage, weapon, stimuli, spdamage)
    return 0,
	{
	    planar = attacker ~= nil and TUNING.SDF_MOON_RUNE_SHARD_DAMAGE_SDF,
	}
end

--Rune Traits
--Time
local function AddRuneTraitTime(inst, owner)
    if inst.components.container:Has("sdf_chaos_rune", 1) then
	--owner.components.talker:Say("Time Rune has been equipped with Chaos Rune.", 4)
	if owner.components.attackdodger == nil then
	    owner:AddComponent("attackdodger")
	    owner.components.attackdodger:SetOnDodgeFn(OnDodgeAttack)
	    owner.components.attackdodger:SetCanDodgeFn(CanDodgeAttackChaos)
	end
    else
	--owner.components.talker:Say("Time Rune has been equipped.", 4)
	if owner.components.attackdodger == nil then
	    owner:AddComponent("attackdodger")
	    owner.components.attackdodger:SetOnDodgeFn(OnDodgeAttack)
	    owner.components.attackdodger:SetCanDodgeFn(CanDodgeAttack)
	end
    end
end

local function RemoveRuneTraitTime(inst, owner)
    --owner.components.talker:Say("Time Rune has been unequipped.", 4)
    if owner.components.attackdodger then
	owner:RemoveComponent("attackdodger")
    end	
end

--Moon
local function AddRuneTraitMoon(inst, owner)
    if inst.components.container:Has("sdf_chaos_rune", 1) then
	--owner.components.talker:Say("Moon Rune has been equipped with Chaos Rune.", 4)
	if inst.components.damagereflect == nil then
	    inst:AddComponent("damagereflect")
	    inst.components.damagereflect:SetReflectDamageFn(ReflectDamageChaosFn)
	    inst:ListenForEvent("onreflectdamage", OnReflectDamage)
	end
    else
	--owner.components.talker:Say("Moon Rune has been equipped.", 4)
	if inst.components.damagereflect == nil then
	    inst:AddComponent("damagereflect")
	    inst.components.damagereflect:SetReflectDamageFn(ReflectDamageFn)
	    inst:ListenForEvent("onreflectdamage", OnReflectDamage)
	end
    end
end

local function RemoveRuneTraitMoon(inst, owner)
    --owner.components.talker:Say("Moon Rune has been unequipped.", 4)
    if inst.components.damagereflect then
	inst:RemoveComponent("damagereflect")
    end
end

--Earth
local function AddRuneTraitEarth(inst, owner)
    if inst.components.container:Has("sdf_chaos_rune", 1) then
	--owner.components.talker:Say("Earth Rune has been equipped with Chaos Rune.", 4)
	inst.components.armor:SetAbsorption(TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_SDF_CHAOS)
    else
	--owner.components.talker:Say("Earth Rune has been equipped.", 4)
	inst.components.armor:SetAbsorption(TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_SDF)
    end
end

local function RemoveRuneTraitEarth(inst, owner)
    --owner.components.talker:Say("Earth Rune has been unequipped.", 4)
    inst.components.armor:SetAbsorption(0)
end

--Star
local function AddRuneTraitStar(inst, owner)
    if inst.components.container:Has("sdf_chaos_rune", 1) then
	--owner.components.talker:Say("Star Rune has been equipped with Chaos Rune.", 4)
	inst.components.planardefense:SetBaseDefense(TUNING.SDF_STAR_RUNE_PLANAR_DEF_SDF_CHAOS)
    else
	--owner.components.talker:Say("Star Rune has been equipped.", 4)
	inst.components.planardefense:SetBaseDefense(TUNING.SDF_STAR_RUNE_PLANAR_DEF_SDF)
    end
end

local function RemoveRuneTraitStar(inst, owner)
    --owner.components.talker:Say("Star Rune has been unequipped.", 4)
    inst.components.planardefense:SetBaseDefense(0)
end

--Chaos
local function AddRuneTraitChaos(inst, owner)
    --Time Rune
    if inst.components.container:Has("sdf_time_rune", 1) then
	if owner.components.attackdodger ~= nil then
	    --owner.components.talker:Say("Chaos Rune equipped and linked with Time Rune.", 4)
	    owner.components.attackdodger:SetCanDodgeFn(CanDodgeAttackChaos)
	end
    end

    --Moon Rune
    if inst.components.container:Has("sdf_moon_rune", 1) then
	--owner.components.talker:Say("Chaos Rune equipped and linked with Moon Rune.", 4)
	if inst.components.damagereflect ~= nil then
	    inst.components.damagereflect:SetReflectDamageFn(ReflectDamageChaosFn)
	end
    end

    --Earth Rune
    if inst.components.container:Has("sdf_earth_rune", 1) then
	--owner.components.talker:Say("Chaos Rune equipped and linked with Earth Rune.", 4)
	inst.components.armor:SetAbsorption(TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_SDF_CHAOS)
    end

    --Star Rune
    if inst.components.container:Has("sdf_star_rune", 1) then
	--owner.components.talker:Say("Chaos Rune equipped and linked with Star Rune.", 4)
	inst.components.planardefense:SetBaseDefense(TUNING.SDF_STAR_RUNE_PLANAR_DEF_SDF_CHAOS)
    end
end

local function RemoveRuneTraitChaos(inst, owner)
    --Time Rune
    if inst.components.container:Has("sdf_time_rune", 1) then
	if owner.components.attackdodger ~= nil then
	    --owner.components.talker:Say("Chaos Rune unequipped and unlinked with Time Rune.", 4)
	    owner.components.attackdodger:SetCanDodgeFn(CanDodgeAttack)
	end
    end

    --Moon Rune
    if inst.components.container:Has("sdf_moon_rune", 1) then
	--owner.components.talker:Say("Chaos Rune unequipped and unlinked with Moon Rune.", 4)
	if inst.components.damagereflect ~= nil then
	    inst.components.damagereflect:SetReflectDamageFn(ReflectDamageFn)
	end
    end

    --Earth Rune
    if inst.components.container:Has("sdf_earth_rune", 1) then
	--owner.components.talker:Say("Chaos Rune unequipped and unlinked with Earth Rune.", 4)
	inst.components.armor:SetAbsorption(TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_SDF)
    end

    --Star Rune
    if inst.components.container:Has("sdf_star_rune", 1) then
	--owner.components.talker:Say("Chaos Rune unequipped and unlinked with Star Rune.", 4)
	inst.components.planardefense:SetBaseDefense(TUNING.SDF_STAR_RUNE_PLANAR_DEF_SDF)
    end
end

--Rune Holder Container
local function RuneLoaded(inst, rune)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil and owner.prefab == "sdf" then

	if rune.prefab == "sdf_chaos_rune" then
	    AddRuneTraitChaos(inst, owner)
	else
	    if rune.prefab == "sdf_time_rune" then
		AddRuneTraitTime(inst, owner)
	    end
	    if rune.prefab == "sdf_moon_rune" then
		AddRuneTraitMoon(inst, owner)
	    end
	    if rune.prefab == "sdf_earth_rune" then
		AddRuneTraitEarth(inst, owner)
	    end
	    if rune.prefab == "sdf_star_rune" then
		AddRuneTraitStar(inst, owner)
	    end
	end
    end
end

local function RuneUnloaded(inst, rune)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then

	if rune.prefab == "sdf_chaos_rune" then
	    RemoveRuneTraitChaos(inst, owner)
	else
	    if rune.prefab == "sdf_time_rune" then
		RemoveRuneTraitTime(inst, owner)
	    end
	    if rune.prefab == "sdf_moon_rune" then
		RemoveRuneTraitMoon(inst, owner)
	    end
	    if rune.prefab == "sdf_earth_rune" then
		RemoveRuneTraitEarth(inst, owner)
	    end
	    if rune.prefab == "sdf_star_rune" then
		RemoveRuneTraitStar(inst, owner)
	    end
	end
    end
end

local function OnRuneLoaded(inst, data)
    if data ~= nil and data.item ~= nil then
	--Add Rune Traits
	RuneLoaded(inst, data.item)

	data.item:PushEvent("RuneLoaded", {sdf_rune_holder = inst})
    end
end

local function OnRuneUnloaded(inst, data)
    if data ~= nil and data.prev_item ~= nil then
	--Remove Rune Traits
	RuneUnloaded(inst, data.prev_item)

	data.prev_item:PushEvent("RuneUnloaded", {sdf_rune_holder = inst})
    end
end

local function onequip(inst, owner)
    if owner.prefab == "sdf" then
	inst.components.equippable:SetPreventUnequipping(true)
    else
	--Stops others from wearing
	inst:DoTaskInTime(0.1, function()
	    local runeHolder = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.RUNE)
	    if runeHolder then
		if owner.components.talker then
		    owner.components.talker:Say(GetString(owner, "ANNOUNCE_NORUNEHOLDER"))
		end
		local item = owner.components.inventory:Unequip(EQUIPSLOTS.RUNE)
		owner.components.inventory:GiveItem(item)
	    end
	end)
    end
end

local function onunequip(inst, owner)

end

local function onload(inst, data)
    --Check Runes
    inst:DoTaskInTime(0.1, function()
	local owner = inst.components.inventoryitem:GetGrandOwner()
	if owner ~= nil and owner.prefab == "sdf" then

	    --Remove Equippable
	    for k, v in pairs(inst.components.container.slots) do
		if v ~= nil then
		    if v.components.equippable then
			v:RemoveComponent("equippable")
		    end
		end
	    end

	    --Time Rune
	    if inst.components.container:Has("sdf_time_rune", 1) then
		AddRuneTraitTime(inst, owner)
	    end

	    --Moon Rune
	    if inst.components.container:Has("sdf_moon_rune", 1) then
		AddRuneTraitMoon(inst, owner)
	    end

	    --Earth Rune
	    if inst.components.container:Has("sdf_earth_rune", 1) then
		AddRuneTraitEarth(inst, owner)
	    end

	    --Star Rune
	    if inst.components.container:Has("sdf_star_rune", 1) then
		AddRuneTraitStar(inst, owner)
	    end
	end
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_rune_holder")
    inst.AnimState:SetBuild("sdf_rune_holder")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hide_percentage")
    inst:AddTag("sdf_rune_holder")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:DoTaskInTime(0, function(inst)
	    inst.replica.container.WidgetSetup = SDF_RUNE_HOLDERFUNCS.MyWidgetSetup_replica
	    inst.replica.container:WidgetSetup(inst.prefab, RuneHolderWidgetParams)

	    local origReplicaOpen = inst.replica.container.Open
	    inst.replica.container.Open = function(self, doer)
		origReplicaOpen(self, doer)
		RuneHolderWidgetHUDPositionFn(self, doer)
	    end
	end)
        return inst
    end

    inst:AddComponent("container")
    inst.components.container.WidgetSetup = SDF_RUNE_HOLDERFUNCS.MyWidgetSetup
    inst.replica.container.WidgetSetup = SDF_RUNE_HOLDERFUNCS.MyWidgetSetup_replica
    inst.components.container:WidgetSetup(inst.prefab, RuneHolderWidgetParams)
    inst:ListenForEvent("itemget", OnRuneLoaded)
    inst:ListenForEvent("itemlose", OnRuneUnloaded)

    local origOpen = inst.components.container.Open
    inst.components.container.Open = function(self, doer)
	origOpen(self, doer)
	RuneHolderWidgetHUDPositionFn(self, doer)
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_rune_holder"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_rune_holder.xml"

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(0)

    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(0)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.RUNE
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload

    return inst
end

return  Prefab("common/inventory/sdf_rune_holder", fn, assets)