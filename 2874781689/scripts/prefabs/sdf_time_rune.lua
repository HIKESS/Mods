local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_time_rune.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_time_rune.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_time_rune_temp.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_time_rune_temp.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_time_rune_broken.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_time_rune_broken.tex"),

    Asset("ATLAS", "images/map_icons/sdf_time_rune_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_time_rune_mm.tex"),

    Asset("ANIM", "anim/sdf_time_rune.zip"),
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

local function getFloorSpawnPoint(HoHTarget, dist)
    local theta = math.random() * 2 * PI
    local radius = 8
    local offset = FindWalkableOffset(HoHTarget, theta, dist or radius, 12, true)
    if offset then
        local pos = HoHTarget + offset
        if TheWorld.Map:IsPassableAtPoint(pos.x, pos.y, pos.z) then return pos end
    end
    return nil
end

local function teleportEnd(inst, caster, HoHpos)

    --Animation
    local time_runeFX = SpawnPrefab("sdf_time_rune_clock_fx")
    time_runeFX.Transform:SetPosition(caster.Transform:GetWorldPosition())
    time_runeFX.AnimState:PlayAnimation("idle", true)

    caster.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition")
    caster.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out") 

    --Wake up
    time_runeFX:DoTaskInTime(1, function()
	SpawnPrefab("sdf_time_rune_gears_fx").Transform:SetPosition(caster.Transform:GetWorldPosition())
	TimeRuneTintFX(caster, 0)
    end)

    time_runeFX:DoTaskInTime(1.5, function()
	time_runeFX:goAwayFn()

    end)

    --State
    if caster:HasTag("player") then
	caster.sg.statemem.teleport_task = nil
	caster.sg:GoToState(caster:HasTag("playerghost") and "appear" or "wakeup")
    end
end

local function teleportContinue(inst, caster, HoHpos)
    if caster.Physics ~= nil then
	if TheWorld:HasTag("cave") then --Cave
	    local caveexit = FindEntity(caster, 15000, nil, { "migrator" }, nil)
	    if caveexit ~= nil and caveexit.prefab == "cave_exit" then
		local cavePos = getFloorSpawnPoint(Vector3(caveexit.Transform:GetWorldPosition()), 4) or Vector3(caveexit.Transform:GetWorldPosition())
		caster.Physics:Teleport(cavePos.x, 0, cavePos.z)

		--extra teleport
		local extraTeleport = inst.components.sdf_time_rune_epoch:GetExtraTeleport()
		if extraTeleport == false then
		    inst.components.sdf_time_rune_epoch:SetExtraTeleport(true)

		    --Apply Cooldown
		    inst.components.rechargeable:Discharge(TUNING.SDF_TIME_RUNE_TELEPORT_EXTRA_COOLDOWN)

		    --Name Change
		    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_TIME_RUNE_STATUS[3])
		else
		    --Apply Cooldown
		    inst.components.rechargeable:SetPercent(0.99)
		end
	    end
	else --Overworld
	    local HoHTargetPos = HoHpos
	    caster.Physics:Teleport(HoHTargetPos.x, 0, HoHTargetPos.z)

	    --Apply Cooldown
	    inst.components.rechargeable:SetPercent(0.99)
	end
    else
	if TheWorld:HasTag("cave") then --Cave
	    local caveexit = FindEntity(caster, 15000, nil, { "migrator" }, nil)
	    if caveexit ~= nil and caveexit.prefab == "cave_exit" then
		local cavePos = getFloorSpawnPoint(Vector3(caveexit.Transform:GetWorldPosition()), 4) or Vector3(caveexit.Transform:GetWorldPosition())
		caster.Transform:SetPosition(cavePos.x, 0, cavePos.z)

		--extra teleport
		local extraTeleport = inst.components.sdf_time_rune_epoch:GetExtraTeleport()
		if extraTeleport == false then
		    inst.components.sdf_time_rune_epoch:SetExtraTeleport(true)

		    --Apply Cooldown
		    inst.components.rechargeable:Discharge(TUNING.SDF_TIME_RUNE_TELEPORT_EXTRA_COOLDOWN)

		    --Name Change
		    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_TIME_RUNE_STATUS[3])
		else
		    --Apply Cooldown
		    inst.components.rechargeable:SetPercent(0.99)
		end
	    end
	else --Overworld
	    local HoHTargetPos = HoHpos
	    caster.Transform:SetPosition(HoHTargetPos.x, 0, HoHTargetPos.z)

	    --Apply Cooldown
	    inst.components.rechargeable:SetPercent(0.99)
	end
    end

    if caster:HasTag("player") then
	caster:SnapCamera()
	caster:ScreenFade(true, 1)
	caster.sg.statemem.teleport_task = caster:DoTaskInTime(1, teleportEnd(inst, caster, HoHpos))
    else
	return
    end
end

local function teleportStart(inst, caster, HoHpos)
    --Stop Moving
    if caster.components.locomotor ~= nil then
	caster.components.locomotor:StopMoving()
    end

    --Animation
    local time_runeFX = SpawnPrefab("sdf_time_rune_clock_fx")
    time_runeFX.Transform:SetPosition(caster.Transform:GetWorldPosition())

    caster.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition")
    caster.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post", nil, .7)
    caster.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)

    time_runeFX:DoTaskInTime(1.5, function()
	time_runeFX:goAwayFn()
	
	--Jump Animation
	SpawnPrefab("sdf_time_rune_gears_fx").Transform:SetPosition(caster.Transform:GetWorldPosition())
	TimeRuneTintFX(caster, 1)

	caster.AnimState:PlayAnimation("wortox_portal_jumpin")
    end)


    --teleport
    local isplayer = caster:HasTag("player")
    if isplayer then
	caster:DoTaskInTime(2, function()
	    caster.sg:GoToState("forcetele")
	    caster.sg.statemem.teleport_task = caster:DoTaskInTime(3, teleportContinue(inst, caster, HoHpos))
	end)
    end
end

local function teleportHallofHeroes(inst, target)
    local caster = inst.components.inventoryitem:GetGrandOwner()
    if caster == nil or caster.prefab ~= "sdf" then
        return
    end

    if caster.components.skilltreeupdater:IsActivated("sdf_undeath_11") then

	if caster.components.rider and caster.components.rider:IsRiding() then
	    return
	end

	--Start Teleport
	teleportStart(inst, caster, inst.components.sdf_time_rune_epoch:GetLocationPoint())

    else
	return
    end
end

local function updateStatus(inst)
    if inst.components.sdf_time_rune_epoch:HasLocation() == true then

	--linked
	if inst.components.rechargeable:IsCharged() then
	    --update Ground Animation
	    inst.AnimState:PlayAnimation("idle")
	    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh")

	    --update Inventory Icons
	    inst.components.inventoryitem.imagename = "sdf_time_rune"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_time_rune.xml"

	    --update Names
	    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_TIME_RUNE_STATUS[1])

	    inst.persists = true
	else
	    local extraTeleport = inst.components.sdf_time_rune_epoch:GetExtraTeleport()
	    if extraTeleport == true then

		--update Ground Animation
		inst.AnimState:PlayAnimation("temp")
		inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh")

		--update Inventory Icons
		inst.components.inventoryitem.imagename = "sdf_time_rune_temp"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_time_rune_temp.xml"

		--update Names
		inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_TIME_RUNE_STATUS[3])

		inst.persists = true
	    else
		--update Ground Animation
		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh")

		--update Inventory Icons
		inst.components.inventoryitem.imagename = "sdf_time_rune"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_time_rune.xml"

		--update Names
		inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_TIME_RUNE_STATUS[2])

		inst.persists = true
	    end
	end
    else

	--update Ground Animation
	inst.AnimState:PlayAnimation("broken")

	--update Inventory Icons
	inst.components.inventoryitem.imagename = "sdf_time_rune_broken"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_time_rune_broken.xml"

	--update Names
	inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_TIME_RUNE_STATUS[0])

	inst.persists = false
    end
end

local function OnCharged(inst)
    if inst.components.spellcaster then
	inst.components.spellcaster.canusefrominventory = false
    end
    inst.components.sdf_time_rune_epoch:SetExtraTeleport(false)
    updateStatus(inst)
end

local function OnDischarged(inst)
    if inst.components.spellcaster then
	inst.components.spellcaster.canusefrominventory = true
    end
    updateStatus(inst)
end

--Special Trait Animation
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
local function CanDodgeAttack(owner, attacker)
    local dodgeRng = math.random()
    if dodgeRng <= TUNING.SDF_TIME_RUNE_DODGE_CHANCE_NORMAL then
	return true
    end
    return false
end

--Special Trait Normal
local function addRuneTraitNormal(inst, owner)
    if owner.components.attackdodger == nil then
	owner:AddComponent("attackdodger")
	owner.components.attackdodger:SetOnDodgeFn(OnDodgeAttack)
	owner.components.attackdodger:SetCanDodgeFn(CanDodgeAttack)
    end
end

local function removeRuneTraitNormal(inst, owner)
    if owner.components.attackdodger then
	owner:RemoveComponent("attackdodger")
    end
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
    updateStatus(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_time_rune_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_time_rune")
    inst.AnimState:SetBuild("sdf_time_rune")
    inst.AnimState:PlayAnimation("broken")

    inst:AddTag("sdf_rune")
    inst:AddTag("sdf_time_rune")

    MakeInventoryFloatable(inst, "med", 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows to location saving.
    inst:AddComponent("sdf_time_rune_epoch")

    inst:AddComponent("named")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_time_rune_broken"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_time_rune_broken.xml"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(teleportHallofHeroes)
    inst.components.spellcaster.canusefrominventory = false

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.RUNE
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    inst.UpdateStatusFn = function() updateStatus(inst) end

    inst.persists = false

    return inst
end

return  Prefab("common/inventory/sdf_time_rune", fn, assets)