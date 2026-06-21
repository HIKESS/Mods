local assets =
{ 
    Asset("ANIM", "anim/kitsune_mask.zip"),
	Asset("ANIM", "anim/swap_kitsune_mask.zip"),
    Asset("ATLAS", "images/inventoryimages/kitsune_mask.xml"),
    Asset("IMAGE", "images/inventoryimages/kitsune_mask.tex"),
}
local prefabs = 
{
	"groundpoundring_fx",
}
local SHIELD_DURATION = 10 * FRAMES
local SHIELD_VARIATIONS = 3
local MAIN_SHIELD_CD = 1.2
local RESISTANCES =
{
    "_combat",
    "quakedebris",
    "trapdamage",
}
for j = 0, 3, 3 do
    for i = 1, SHIELD_VARIATIONS do
        table.insert(prefabs, "shadow_shield"..tostring(j + i))
    end
end
local function PickShield(inst)
    local t = GetTime()
    local flipoffset = math.random() < .5 and SHIELD_VARIATIONS or 0
    local dt = t - inst.lastmainshield
    if dt >= MAIN_SHIELD_CD then
        inst.lastmainshield = t
        return flipoffset + 3
    end
    local rnd = math.random()
    if rnd < dt / MAIN_SHIELD_CD then
        inst.lastmainshield = t
        return flipoffset + 3
    end
    return flipoffset + (rnd < dt / (MAIN_SHIELD_CD * 2) + .5 and 2 or 1)
end
local function OnShieldOver(inst, OnResistDamage)
    inst.task = nil
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
end
local function OnResistDamage(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    local fx = SpawnPrefab("shadow_shield"..tostring(PickShield(inst)))
    fx.entity:SetParent(owner.entity)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(SHIELD_DURATION, OnShieldOver, OnResistDamage)
    inst.components.resistance:SetOnResistDamageFn(nil)
    inst.components.fueled:DoDelta(-TUNING.KITSUNE_MASK_DELTA_FEUL)
    if inst.components.cooldown.onchargedfn ~= nil then
        inst.components.cooldown:StartCharging()
    end
end
local function ShouldResistFn(inst)
    if not inst.components.equippable:IsEquipped() then
        return false
    end
    local owner = inst.components.inventoryitem.owner
    return owner ~= nil
        and not (owner.components.inventory ~= nil and
                owner.components.inventory:EquipHasTag("forcefield"))
end
local function OnChargedFn(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:AddResistance(v)
    end
end
local function nofuel(inst)
    inst.components.cooldown.onchargedfn = nil
    inst.components.cooldown:FinishCharging()
end
local function ontakefuel(inst)
    if inst.components.equippable:IsEquipped() and
        not inst.components.fueled:IsEmpty() and
        inst.components.cooldown.onchargedfn == nil then
        inst.components.cooldown.onchargedfn = OnChargedFn
        inst.components.cooldown:StartCharging(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN)
    end
end
local function freezeproc(owner)
 	local x, y, z = owner.Transform:GetWorldPosition()
	local fx = SpawnPrefab("groundpoundring_fx")
	fx.Transform:SetPosition(x, y, z)
	local x,y,z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, 5, {"freezable"}, {"FX", "NOCLICK", "DECOR","INLIMBO"}) 
            for i,v in pairs(ents) do
             if v and v.components.freezable then
			 if v:HasTag("player") or v:HasTag("epic") then
               else
                v.components.freezable:Freeze(0.1)
                v.components.freezable:SpawnShatterFX()
				v.components.freezable.coldness = 0
				v.components.freezable.wearofftime = TUNING.KITSUNE_MASK_FREEZE_TIME
				v.components.health:DoDelta(-TUNING.KITSUNE_MASK_DAMAGE_FREEZE)
end
end
end
end
local summonchancefr = TUNING.KITSUNE_MASK_FREEZE
local function OnBlocked(owner, data)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_scalemail")
	 if math.random() < summonchancefr then
	 freezeproc(owner)
 end
end
local function OnEquipMaks(inst, owner)
	owner.AnimState:OverrideSymbol("swap_hat", "swap_kitsune_mask", "swap_hat")
	owner.AnimState:Show("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	owner.sg:GoToState("hit_darkness")
	owner.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
	owner.components.hunger:DoDelta(-15)
    inst.lastmainshield = 0
    if not inst.components.fueled:IsEmpty() then
        inst.components.cooldown.onchargedfn = OnChargedFn
        inst.components.cooldown:StartCharging(math.max(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN, inst.components.cooldown:GetTimeToCharged()))
    end
	if not inst.share_item and owner and not owner:HasTag("kodi") and owner.components.inventory then
		owner.components.inventory:Unequip(EQUIPSLOTS.HANDS, true)
        owner:DoTaskInTime(0.1, function()  owner.components.inventory:DropItem(inst)
			if TUNING.KODI_LANGUAGE == "ENGLISH" then
				owner.components.talker:Say("It looks like some kind of magical power is preventing me from using this...")
			else
				owner.components.talker:Say("Схоже, що якась магічна сила забороняє мені цим користуватися...")
			end
		end)
	end
    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:SetModifier(inst, 0.5)
    end
	inst:ListenForEvent("attacked", OnBlocked, owner)
end
local function OnUnequipMak(inst, owner)
	owner.AnimState:Hide("HAT")
	owner.AnimState:Hide("HAT_HAIR")
	owner.AnimState:Show("HAIR_NOHAT")
	owner.AnimState:Show("HAIR")
	owner.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
	owner.sg:PushEvent("powerdown")
	SpawnPrefab("statue_transition_2").Transform:SetPosition(inst:GetPosition():Get())
	owner.components.health:DoDelta(-5)
    inst.components.cooldown.onchargedfn = nil
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end
    if owner.components.hunger ~= nil then
        owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
    end
	if owner:HasTag("player") then
		owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAIR")
	end
	inst:RemoveEventCallback("attacked", OnBlocked, owner)
end
local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	inst.AnimState:SetBank("kitsune_mask")
	inst.AnimState:SetBuild("kitsune_mask")
	inst.AnimState:PlayAnimation("idle")
	inst:AddTag("hat")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("inspectable")
	inst:AddComponent("tradable")
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
	inst.components.equippable:SetOnEquip(OnEquipMaks)
	inst.components.equippable:SetOnUnequip(OnUnequipMak)
    inst:AddComponent("resistance")
    inst.components.resistance:SetShouldResistFn(ShouldResistFn)
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
	inst.components.fueled:InitializeFuelLevel(TUNING.KITSUNE_MASK_MAX_FEUL)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled.accepting = true
    inst:AddComponent("cooldown")
	inst.components.cooldown.cooldown_duration = TUNING.KITSUNE_MASK_COOLDOWN
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/kitsune_mask.xml"
	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(.1)
    return inst
end
return Prefab( "common/inventory/kitsune_mask", fn, assets ) 