local assets =
{
    Asset("ANIM", "anim/destructionpda.zip"),
}

local function CheckSpawnedLoot(loot)
    if loot.components.inventoryitem ~= nil then
        loot.components.inventoryitem:TryToSink()
    else
        local lootx, looty, lootz = loot.Transform:GetWorldPosition()
        if ShouldEntitySink(loot, true) or TheWorld.Map:IsPointNearHole(Vector3(lootx, 0, lootz)) then
            SinkEntity(loot)
        end
    end
end

local function SpawnLootPrefab(inst, lootprefab)
    if lootprefab == nil then
        return
    end

    local loot = SpawnPrefab(lootprefab)
    if loot == nil then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    if loot.Physics ~= nil then
        local angle = math.random() * 1.3 * PI
        loot.Physics:SetVel(1.5 * math.cos(angle), 2, 2 * math.sin(angle))

        if inst.Physics ~= nil then
            local len = loot:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0)
            x = x + math.cos(angle) * len
            z = z + math.sin(angle) * len
        end

        loot:DoTaskInTime(1, CheckSpawnedLoot)
    end

    loot.Transform:SetPosition(x, y, z)

	loot:PushEvent("on_loot_dropped", {dropper = inst})

    return loot
end

local function destroystructure(staff, target)
    local caster = staff.components.inventoryitem.owner

	if not target:HasTag("ebuild") then --target.components.engieworkable == nil or not
		if caster ~= nil and caster.components.talker ~= nil then
			caster.components.talker:Say(GetString(caster, "ANNOUNCE_NOTMACHINE"))
		end
        return
	end

    local recipe = AllRecipes[target.prefab]
    if recipe == nil or FunctionOrValue(recipe.no_deconstruction, target) then
        --Action filters should prevent us from reaching here normally
        return
    end

	if caster ~= nil then
	if target.turretID and target.turretID ~= caster.engieID then
		return
	elseif target.dispenserID and target.dispenserID ~= caster.engieID then
		return
	elseif target.telenterID and target.telenterID ~= caster.engieID then
		return
	elseif target.telexitID and target.telexitID ~= caster.engieID then
		return
	end
	end

    for i, v in ipairs(recipe.ingredients) do
        local amt = v.amount == 0 and 0 or math.max(1, math.ceil(v.amount * TUNING.PDA_AMOUNT))
        for n = 1, amt do
            SpawnLootPrefab(target, v.type)
        end
    end

   	target:PushEvent("ondeconstructstructure", caster)
	SpawnPrefab("explode_small").Transform:SetPosition(target.Transform:GetWorldPosition())

    if target.components.stackable ~= nil then
        --if it's stackable we only want to destroy one of them.
        target.components.stackable:Get():Remove()
    else
        target:Remove()
    end
end

local function can_cast_fn(doer, target, pos)
	local ebuild = target:HasTag("ebuild")-- target.components.engieworkable or 
	if target ~= nil and ebuild ~= nil then
		local attackerID = doer.engieID or nil
		if doer and target.turretID and target.turretID == doer.engieID then
			return true
		elseif doer and target.dispenserID and target.dispenserID == doer.engieID then
			return true
		elseif doer and target.telenterID and target.telenterID == doer.engieID then
			return true
		elseif doer and target.telexitID and target.telexitID == doer.engieID then
			return true
		end
	end

	return false
end

local function onequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
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

    inst.AnimState:SetBank("destructionpda")
    inst.AnimState:SetBuild("destructionpda")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("engiepda")
    inst:AddTag("punch")

    inst.spelltype = "ENGINEER"

	MakeInventoryFloatable(inst, "med", nil, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = ENGINEERITEMIMAGES
--	inst.components.inventoryitem.imagename = "destructionpda"
--	inst.components.inventoryitem.atlasname = "images/inventoryimages/destructionpda.xml"
	
    inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
--	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.restrictedtag = "engie"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseonworkable = true
--	inst.components.spellcaster.canusefrominventory  = true
    inst.components.spellcaster:SetSpellFn(destroystructure)
	inst.components.spellcaster:SetCanCastFn(can_cast_fn)

	MakeHauntableLaunch(inst)

    return inst
end

STRINGS.DESTRUCTIONPDA = "Destruction PDA"

return Prefab("common/inventory/destructionpda", fn, assets)