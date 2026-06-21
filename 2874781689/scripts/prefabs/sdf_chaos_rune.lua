local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_chaos_rune.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_chaos_rune.tex"),

    Asset("ATLAS", "images/map_icons/sdf_chaos_rune_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chaos_rune_mm.tex"),

    Asset("ANIM", "anim/sdf_chaos_rune.zip"),
}

prefabs = {
}

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
	    planar = attacker ~= nil and TUNING.SDF_MOON_RUNE_SHARD_DAMAGE_SDF,
	}
end

--Special Trait Normal
local function addRuneTraitNormal(inst, owner)
    --Time Rune
    if owner.components.attackdodger == nil then
	owner:AddComponent("attackdodger")
	owner.components.attackdodger:SetOnDodgeFn(OnDodgeAttack)
	owner.components.attackdodger:SetCanDodgeFn(CanDodgeAttackChaos)
    end

    --Moon Rune
    if inst.components.damagereflect == nil then
	inst:AddComponent("damagereflect")
	inst.components.damagereflect:SetReflectDamageFn(ReflectDamageChaosFn)
	inst:ListenForEvent("onreflectdamage", OnReflectDamage)
    end

    --Earth Rune
    inst.components.armor:SetAbsorption(TUNING.SDF_EARTH_RUNE_ARMOR_ABSORB_SDF)

    --Star Rune
    inst.components.planardefense:SetBaseDefense(TUNING.SDF_STAR_RUNE_PLANAR_DEF_SDF)
end

local function removeRuneTraitNormal(inst, owner)
    --Time Rune
    if owner.components.attackdodger then
	owner:RemoveComponent("attackdodger")
    end

    --Moon Rune
    if inst.components.damagereflect then
	inst:RemoveComponent("damagereflect")
    end

    --Earth Rune
    inst.components.armor:SetAbsorption(0)

    --Star Rune
    inst.components.planardefense:SetBaseDefense(0)
end

local function onequip(inst, owner)
    addRuneTraitNormal(inst, owner)
end

local function onunequip(inst, owner)
    removeRuneTraitNormal(inst, owner)
end

local function OnPickupFn(inst, pickupguy)
    if pickupguy.prefab == "sdf" then

	--Resets edible if off
	if inst.components.equippable then
	    inst:RemoveComponent("equippable")
	end
    else
	if inst.components.equippable == nil then
	    inst:AddComponent("equippable")
	    inst.components.equippable.equipslot = EQUIPSLOTS.RUNE
	    inst.components.equippable:SetOnEquip(onequip)
	    inst.components.equippable:SetOnUnequip(onunequip)
	end
    end
end

local function OnLoad(inst, data)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner and owner.prefab == "sdf" then
	inst:RemoveComponent("equippable")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chaos_rune_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_chaos_rune")
    inst.AnimState:SetBuild("sdf_chaos_rune")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh")

    inst:AddTag("hide_percentage")
    inst:AddTag("sdf_rune")
    inst:AddTag("sdf_chaos_rune")

    MakeInventoryFloatable(inst, "med", 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_chaos_rune"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_chaos_rune.xml"

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(0)

    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(0)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.RUNE
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_chaos_rune", fn, assets)