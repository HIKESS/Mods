local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_dragon_potion_dragonbreath.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_dragon_potion_dragonbreath.tex"),
}

prefabs = {
}

local function resourceCost(inst, owner)
    local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)

    if bodySlot then
	if bodySlot.prefab == "sdf_dragon_potion" then
	    bodySlot.components.fueled:DoDelta(-TUNING.SDF_DRAGON_POTION_BREATHEFIRE_CONSUME_FUEL, owner)
	end
    end
end

local function EndDragonFire(fx, doer)
    if doer.components.channelcaster then
	doer.components.channelcaster:StopChanneling()
    end
end

local function TryDragonFire(inst, doer, pos)
    if doer.components.channelcaster and not doer.components.channelcaster:IsChanneling() then

	--Dragonfire
	local fx = SpawnPrefab("sdf_dragon_potion_dragonfire")
	fx.entity:SetParent(doer.entity)
	fx:SetBreathefireAttacker(doer)

	local endtask = fx:DoTaskInTime(TUNING.SDF_DRAGON_POTION_BREATHEFIRE_DURATION, EndDragonFire, doer)

	fx:ListenForEvent("stopchannelcast", function()
	if fx then
	    endtask:Cancel()
	    fx:KillFX()
	    fx = nil
	end
	end, doer)

	--Apply Cooldown Animation
	inst.components.rechargeable:Discharge(TUNING.SDF_DRAGON_POTION_BREATHEFIRE_DURATION)

	--Start Channeling
	if doer.components.channelcaster:StartChanneling() then
	    return true
	end

	--channelcast fail
	fx:Remove()
    end
    return false
end

local function DragonFireSpellFn(inst, doer, pos)

    if doer.components.rider and doer.components.rider:IsRiding() then
	return false, "CANT_SPELL_MOUNTED"
    elseif TryDragonFire(inst, doer, pos) then

	--Resource Cost
	resourceCost(inst, doer)

        return true
    end
    return false
end

local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

--------------------------------------------------------------------------------------

local function line_reticule_target_function(inst)
    if ThePlayer and ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller.isclientcontrollerattached then
        local inventoryitem = inst.components.inventoryitem
        local owner =  inventoryitem and inventoryitem:IsGrandOwner(ThePlayer) and ThePlayer
        if owner then
	    return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0, 0))
        end
    end
end

local function line_reticule_mouse_target_function(inst, mousepos)
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

local function line_reticule_update_position_function(inst, pos, reticule, ease, smoothing, dt)
    reticule.Transform:SetPosition(ThePlayer.Transform:GetWorldPosition())
    local rot1 = reticule:GetAngleToPoint(inst.components.reticule.targetpos)
	if ease and dt then
	    local rot = reticule.Transform:GetRotation()
	    local drot = ReduceAngle(rot1 - rot)
	    rot1 = Lerp(rot, rot + drot, dt * smoothing)
	end
    reticule.Transform:SetRotation(rot1)
end

--------------------------------------------------------------------------------------

local function onequip(inst, owner)
    if owner.prefab == "sdf" then
	inst.components.equippable:SetPreventUnequipping(true)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
    else
	inst:Remove()
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    --inst.AnimState:SetBank("sdf_axe")
    --inst.AnimState:SetBuild("sdf_axe")
    --inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("tool")
    inst:AddTag("willow_ember")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
    inst.components.aoetargeting.reticule.mousetargetfn = line_reticule_mouse_target_function
    inst.components.aoetargeting.reticule.targetfn = line_reticule_target_function
    inst.components.aoetargeting.reticule.updatepositionfn = line_reticule_update_position_function
    inst.components.aoetargeting:SetDeployRadius(0)
    inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
    inst.components.aoetargeting:SetTargetFX(nil)

    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.twinstickmode = 1
    inst.components.aoetargeting.reticule.twinstickrange = 8

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(DragonFireSpellFn)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_DAMAGE_UNARMED)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "sdf_dragon_potion_dragonbreath"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_dragon_potion_dragonbreath.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("rechargeable")

    inst.persists = false

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab( "sdf_dragon_potion_dragonbreath", fn, assets)