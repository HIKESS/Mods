local assets =
{
	Asset("ANIM", "anim/tf2wrench.zip"),
	Asset("ANIM", "anim/swap_tf2wrench.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_tf2wrench", "tf2wrench")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, attacker, target)
    if target and target.brain and target.epanic ~= true and target.components.hauntable ~= nil and math.random() < .1 then
    	local x, y, z = target.Transform:GetWorldPosition()
    	local fx = SpawnPrefab("impact")
    	fx.Transform:SetPosition(x, y, z)
        target.epanic = true
	    target.components.hauntable:Panic(7)
        target:DoTaskInTime(9, function()
	    target.epanic = false
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("tf2wrench")
    inst.AnimState:SetBuild("tf2wrench")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hammer")
    inst:AddTag("dull")

    MakeInventoryFloatable(inst, "small", 0.05, 0.7, false, -13, {sym_build = "swap_tf2wrench"})

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TF2WRENCH_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("tool")

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = ENGINEERITEMIMAGES
--    inst.components.inventoryitem.imagename = "tf2wrench"
--    inst.components.inventoryitem.atlasname = "images/inventoryimages/tf2wrench.xml"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TF2WRENCH_USES)
    inst.components.finiteuses:SetUses(TUNING.TF2WRENCH_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/tf2wrench", fn, assets)