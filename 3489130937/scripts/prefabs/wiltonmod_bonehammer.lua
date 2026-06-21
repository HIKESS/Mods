local assets =
{
    Asset("ANIM", "anim/swap_wiltonmod_bonehammer.zip"),
    Asset("ANIM", "anim/fossil_bone_rod.zip"),
    Asset("ANIM", "anim/fossil_bone_rod_swap.zip"),

    Asset("ATLAS", "images/inventoryimages/wiltonmod_bonehammer.xml"),
    Asset("ATLAS", "images/inventoryimages/wiltonmod_bonehammer_skin.xml"),
}

local GetUseTable = {
    boneshard = 100,
}

local function CanTakeItem(inst, ammo, giver)
    return GetUseTable[ammo.prefab] ~= nil and inst.components.finiteuses:GetPercent() < 1
end

local function OnGetItemFromPlayer(inst, giver, item)  
    if item and GetUseTable[item.prefab] ~= nil and inst.components.finiteuses:GetPercent() < 1 then
        local rapair_amount = GetUseTable[item.prefab] or 80
        inst.components.finiteuses:Repair(rapair_amount)

        inst.SoundEmitter:PlaySound("aqol/new_test/rock")    
    end      
end

--- fossil_bone_rod 皮肤：在装备时挂载 pocketwatch_weapon 的武器 FX
-- @param inst 武器实例
-- @param owner 持有者（可选）
local function bonehammer_skin_try_start_fx(inst, owner)
	if inst.components.equippable == nil or inst.components.inventoryitem == nil then
		return
	end

	owner = owner
		or (inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner)
		or nil

	if owner == nil then
		return
	end

	if inst._vfx_fx_inst ~= nil and inst._vfx_fx_inst.entity:GetParent() ~= owner then
		inst._vfx_fx_inst:Remove()
		inst._vfx_fx_inst = nil
	end

	if inst._vfx_fx_inst == nil then
		local fx = SpawnPrefab("pocketwatch_weapon_fx")
		if fx ~= nil then
			inst._vfx_fx_inst = fx
			fx.entity:AddFollower()
			fx.entity:SetParent(owner.entity)
			fx.Follower:FollowSymbol(owner.GUID, "swap_object", 15, 70, 0)
		end
	end
end

--- fossil_bone_rod 皮肤：卸下或物品被移除时，清理绑定的 pocketwatch_weapon FX
-- @param inst 武器实例
local function bonehammer_skin_stop_fx(inst)
	if inst._vfx_fx_inst ~= nil then
		inst._vfx_fx_inst:Remove()
		inst._vfx_fx_inst = nil
	end
end

--- fossil_bone_rod 皮肤：攻击时使用老年旺达的警钟攻击 FX 与音效
-- @param inst 武器实例
-- @param attacker 攻击者
-- @param target 目标
local function bonehammer_skin_onattack(inst, attacker, target)
	if target ~= nil and target:IsValid() then
		local fx = SpawnPrefab("wanda_attack_pocketwatch_old_fx")
		if fx ~= nil then
			local x, y, z = target.Transform:GetWorldPosition()

			if attacker ~= nil and attacker.Transform ~= nil and target.GetPhysicsRadius ~= nil then
				local radius = target:GetPhysicsRadius(.5)
				local angle = (attacker.Transform:GetRotation() - 90) * DEGREES
				fx.Transform:SetPosition(x + math.sin(angle) * radius, 0, z + math.cos(angle) * radius)
			else
				fx.Transform:SetPosition(x, 0, z)
			end
		end
	end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_wiltonmod_bonehammer", "swap_wiltonmod_bonehammer")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	bonehammer_skin_stop_fx(inst)
end

local function onequip_skin(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "fossil_bone_rod_swap", "fossil_bone_rod_swap")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	bonehammer_skin_try_start_fx(inst, owner)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("swap_wiltonmod_bonehammer")
    inst.AnimState:SetBuild("swap_wiltonmod_bonehammer")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("tool")
    inst:AddTag("hammer")
    inst:AddTag("wiltonmod_item")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    -- 大骨棒本体伤害从 TUNING 读取，支持配置调整。
    inst.components.weapon:SetDamage(TUNING.WILTON_BONEHAMMER_DAMAGE or 34)
    inst.components.weapon:SetRange(1.2)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(1200)
    inst.components.finiteuses:SetUses(1200)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_bonehammer"    
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_bonehammer.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER)

    MakeHauntableLaunch(inst)

    return inst
end

local function skin()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fossil_bone_rod")
    inst.AnimState:SetBuild("fossil_bone_rod")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("tool")
    inst:AddTag("hammer")
    inst:AddTag("wiltonmod_item")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    -- 皮肤版大骨棒同样共享可配置伤害。
    inst.components.weapon:SetDamage(TUNING.WILTON_BONEHAMMER_DAMAGE or 34)
    inst.components.weapon:SetRange(1.2)
    inst.components.weapon:SetOnAttack(bonehammer_skin_onattack)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(1200)
    inst.components.finiteuses:SetUses(1200)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_bonehammer_skin"    
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_bonehammer_skin.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip_skin)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wiltonmod_bonehammer", fn, assets),
       Prefab("wiltonmod_bonehammer_skin", skin, assets)