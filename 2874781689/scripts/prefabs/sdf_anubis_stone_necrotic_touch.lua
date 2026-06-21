local assets=
{
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_necrotic_touch.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_necrotic_touch.xml"),

    Asset("ANIM", "anim/swap_sdf_anubis_stone.zip"),
    Asset("ANIM", "anim/swap_sdf_anubis_stone_necrotic_touch.zip"),
}

prefabs = {
	"sdf_lightning_gauntlet_goodlightning_fx",
}

local function ReticuleTargetFn()
    for m=7,0,-.25 do Vector3().x,Vector3().y,Vector3().z = ThePlayer.entity:LocalToWorldSpace(m,0,0)
	if TheWorld.Map:IsPassableAtPoint(Vector3():Get()) and not TheWorld.Map:IsGroundTargetBlocked(Vector3()) then 
	    return Vector3()
	end
    end
    return Vector3()
end

local function checkResourceCost(inst, owner, usage)
    local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)

    if bodySlot then
	if bodySlot.prefab == "sdf_anubis_stone" then
	    if (bodySlot.components.armor:GetPercent() * 100) >= usage then
		return true
	    end
	end
    end
    return false
end

local function resourceCost(inst, owner, usage)
    local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)

    if bodySlot then
	if bodySlot.prefab == "sdf_anubis_stone" then
	    bodySlot.components.armor:Repair(-usage)
	end
    end
end

local function checkHasSoulHelmet(inst, owner)
    local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)

    if bodySlot then
	if bodySlot.prefab == "sdf_anubis_stone" then
	    if bodySlot.components.container:Has("sdf_soul_helmet", 1) then
		return true
	    end
	end
    end
    return false
end

local function soulHelmetCost(inst, owner)
    local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)

    if bodySlot then
	if bodySlot.prefab == "sdf_anubis_stone" then
	    bodySlot.components.container:ConsumeByName("sdf_soul_helmet", 1)
	end
    end
end

local function OnCharged(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	if checkHasSoulHelmet(inst, owner) then
	    inst.components.aoetargeting:SetEnabled(true)
	end
    end
end

local function OnDischarged(inst)
    inst.components.aoetargeting:SetEnabled(false)
end

local function necroHealAllyOnHit(inst, attacker, target)
    --Random Animation
    local electricutefx = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
    if electricutefx then

	local follower = electricutefx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	electricutefx:FacePoint(inst.Transform:GetWorldPosition())

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--electricute fx
	local goodlightningShockFX = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
	if goodlightningShockFX then
	    goodlightningShockFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
	local goodlightningHealFX = SpawnPrefab("spider_heal_target_fx")
	if goodlightningHealFX then
	    goodlightningHealFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end

	--follow --fix this
	if target.prefab == "sdf_gallowmere_squire" then
	    target.components.sdf_gallowmere_knight_tactics:AnubisStoneTurnOn(attacker)
	end
    end
end

local function necroHealSpell(inst, target)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner == nil then
        return
    end

    if target ~= nil and target ~= owner then
	if target:HasTag("sdf_undeath_healing") then

	    --Check Energy
	    if checkResourceCost(inst, owner, TUNING.SDF_ANUBIS_STONE_NECRO_HEAL / 2) then

		--Consume Anubis Stone Energy
		resourceCost(inst, owner, TUNING.SDF_ANUBIS_STONE_NECRO_HEAL / 2)

		--Consume Player Life
		owner.components.health:DoDelta(-(TUNING.SDF_ANUBIS_STONE_NECRO_HEAL / 2), false, "anubis stone")

	    else
		--Consume Player Life
		owner.components.health:DoDelta(-(TUNING.SDF_ANUBIS_STONE_NECRO_HEAL), false, "anubis stone")
	    end

	    --Heal Ally
	    target.components.health:DoDelta((TUNING.SDF_ANUBIS_STONE_NECRO_HEAL * TUNING.SDF_ANUBIS_STONE_NECRO_HEAL_UNDEATH_MULTI), false, "anubis stone")
	    necroHealAllyOnHit(inst, owner, target)
	elseif target:HasTag("sdf_undeath_recharge") then

	    --Check Energy
	    if checkResourceCost(inst, owner, TUNING.SDF_ANUBIS_STONE_NECRO_HEAL / 2) then

		--Consume Anubis Stone Energy
		resourceCost(inst, owner, TUNING.SDF_ANUBIS_STONE_NECRO_HEAL / 2)

		--Consume Player Life
		owner.components.health:DoDelta(-(TUNING.SDF_ANUBIS_STONE_NECRO_HEAL / 2), false, "anubis stone")

	    else
		--Consume Player Life
		owner.components.health:DoDelta(-(TUNING.SDF_ANUBIS_STONE_NECRO_HEAL), false, "anubis stone")
	    end

	    --Recharge Shadow Talisman
	    target.components.fueled:DoDelta(TUNING.SDF_ANUBIS_STONE_NECRO_RECHARGE, false, "anubis stone")
	    target:onAddFuel()
	    necroHealAllyOnHit(inst, owner, target)
	else
	    if owner.components.talker then
		owner.components.talker:Say(GetString(owner, "ANNOUNCE_ANUBISSTONENOTARGET"))
	    end
	end
    end
end

local function learnReanimateSpell(inst,doer,pos)
    --Check Energy
    if not inst.components.rechargeable:IsCharged() or checkResourceCost(inst, doer, TUNING.SDF_ANUBIS_STONE_REANIMATE_USAGE) == false then
	if doer.components.talker then
	    doer.components.talker:Say(GetString(doer, "ANNOUNCE_ANUBISSTONENOENERGY"))
	end
	return
    end


    --Light Pillar Anim
    local lightPillarFX = SpawnPrefab("fx_book_light_upgraded")
    lightPillarFX.Transform:SetPosition(pos.x, pos.y - 0.1, pos.z)

    --Reanimate
    inst:DoTaskInTime(.5, function() --1.2

	--Reanimate Type
	if doer.prefab == "sdf" then
	    --Skill Tree Rites
	    if doer.components.skilltreeupdater:IsActivated("sdf_undeath_7") then
		--Spawn Gallowmere Knight
		local gallowmereKnightReanimate = SpawnPrefab("sdf_gallowmere_knight")
		gallowmereKnightReanimate.Transform:SetPosition(pos.x, pos.y, pos.z)
		gallowmereKnightReanimate.components.bloomer:PushBloom("Healthy", "shaders/anim.ksh", 50)

		--graveSpawn
		gallowmereKnightReanimate.AnimState:PlayAnimation("grave_spawn")

		--follow
		gallowmereKnightReanimate:DoTaskInTime(3.6, function()
		    if doer and not (doer.components.health and doer.components.health:IsDead()) then
			gallowmereKnightReanimate.components.sdf_gallowmere_knight_tactics:AnubisStoneTurnOn(doer)
		    end
		end)
	    else
		--Spawn Gallowmere Squire
		local gallowmereSquireReanimate = SpawnPrefab("sdf_gallowmere_squire")
		gallowmereSquireReanimate.Transform:SetPosition(pos.x, pos.y, pos.z)
		gallowmereSquireReanimate.components.bloomer:PushBloom("Healthy", "shaders/anim.ksh", 50)

		--graveSpawn
		gallowmereSquireReanimate.AnimState:PlayAnimation("grave_spawn")

		--follow
		gallowmereSquireReanimate:DoTaskInTime(3.6, function()
		    if doer and not (doer.components.health and doer.components.health:IsDead()) then
			gallowmereSquireReanimate.components.sdf_gallowmere_knight_tactics:AnubisStoneTurnOn(doer)
		    end
		end)
	    end
	else
	    --Spawn Gallowmere Squire
	    local gallowmereSquireReanimate = SpawnPrefab("sdf_gallowmere_squire")
	    gallowmereSquireReanimate.Transform:SetPosition(pos.x, pos.y, pos.z)
	    gallowmereSquireReanimate.components.bloomer:PushBloom("Healthy", "shaders/anim.ksh", 50)

	    --graveSpawn
	    gallowmereSquireReanimate.AnimState:PlayAnimation("grave_spawn")

	    --follow
	    gallowmereSquireReanimate:DoTaskInTime(3.6, function()
		if doer and not (doer.components.health and doer.components.health:IsDead()) then
		    gallowmereSquireReanimate.components.sdf_gallowmere_knight_tactics:AnubisStoneTurnOn(doer)
		end
	    end)
	end
    end)

    --Consume Anubis Stone Energy
    resourceCost(inst, doer, TUNING.SDF_ANUBIS_STONE_REANIMATE_USAGE)

    --Consume Anubis Stone Soul Helmet
    soulHelmetCost(inst, doer)

    --Cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_ANUBIS_STONE_REANIMATE_COOLDOWN)
end

local function onequip(inst, owner)
    inst.components.equippable:SetPreventUnequipping(true)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_anubis_stone_necrotic_touch", "swap_sdf_anubis_stone_necrotic_touch")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    --Add Gauntlet FX
    if inst.fires == nil then
	inst.fires = {}

	local fx = SpawnPrefab("sdf_lightning_gauntlet_goodlightning_fx")
	fx.entity:SetParent(owner.entity)
	fx.entity:AddFollower()
	fx.Follower:FollowSymbol(owner.GUID, "swap_object", 20, 40, 0)

	table.insert(inst.fires, fx)
    end

    if checkHasSoulHelmet(inst, owner) then
	inst.components.aoetargeting:SetEnabled(true)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.fires ~= nil then
	for i, fx in ipairs(inst.fires) do
	    fx:Remove()
	end
	inst.fires = nil
    end

   -- inst.components.aoetargeting:SetEnabled(false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.spelltype = "SDF_ANUBIS_STONE_NECROHEAL"

    --inst.AnimState:SetBank("sdf_anubis_stone")
    --inst.AnimState:SetBuild("sdf_anubis_stone")
    --inst.AnimState:PlayAnimation("empty",true)

    MakeInventoryFloatable(inst, "med", 0.25)

    inst:AddTag"allow_action_on_impassable"

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoesummon"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoesummonping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = {1,.75,0,1}
    inst.components.aoetargeting.reticule.invalidcolour = {.5,0,0,1}
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting:SetRange(TUNING.SDF_ANUBIS_STONE_REANIMATE_RANGE)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.aoetargeting:SetEnabled(false)

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(learnReanimateSpell)

    inst:AddComponent("sdf_reticule_spawner")
    inst.components.sdf_reticule_spawner:Setup(TUNING.SDF_ANUBIS_STONE_REANIMATE_RETICULE_RADIUS)

    inst:AddComponent("spellcaster")
    --inst.components.spellcaster.veryquickcast = true
    inst.components.spellcaster:SetSpellFn(necroHealSpell)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseoncombat = true

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_DAMAGE_UNARMED)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_anubis_stone_necrotic_touch"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_necrotic_touch.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_ANUBIS_STONE_REANIMATE_COOLDOWN)
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst.persists = false

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_anubis_stone_necrotic_touch", fn, assets, prefabs)