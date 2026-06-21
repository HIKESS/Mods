local assets =
{    
	Asset("ANIM", "anim/mhamayumi.zip"),
    Asset("ANIM", "anim/swap_mhamayumi.zip"),
	
	Asset("ATLAS", "images/inventoryimages/mhamayumi.xml"),
    Asset("IMAGE", "images/inventoryimages/mhamayumi.tex"),
}

local prefabs = {}

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

local function CreateTarget()
	local inst = CreateEntity()

	inst:AddTag("CLASSIFIED")
	--[[Non-networked entity]]
	inst.persists = false

	inst.entity:AddTransform()

	inst:DoTaskInTime(3, inst.Remove)

	return inst
end

local TARGET_RANGE = 30

--------------------------------------------------------------------------

local function slingshotex_RefreshChargeTicks(inst, reticule, ticks)
	if reticule.SetChargeScale then
		local scale = math.min(1, ticks * FRAMES / TUNING.SLINGSHOT_MAX_CHARGE_TIME)
		reticule:SetChargeScale(scale)
	end
end

local function slingshotex_common_postinit(inst)

	inst:AddComponent("aoecharging")
	inst.components.aoecharging.reticuleprefab = "reticulecharging"
	inst.components.aoecharging.pingprefab = "reticulelongping"
	inst.components.aoecharging:SetRefreshChargeTicksFn(slingshotex_RefreshChargeTicks)
end

local function slingshotex_OnChargedAttack(inst, doer, ticks)
	if inst.components.weapon.projectile then
		local x, y, z = doer.Transform:GetWorldPosition()
		local angle = doer.Transform:GetRotation() * DEGREES
		local target = CreateTarget()
		target.Transform:SetPosition(x + math.cos(angle) * TARGET_RANGE, 0, z - math.sin(angle) * TARGET_RANGE)

		--V2C: -stategraph forces at least 8 ticks held before allowing shot
		--     -adjusting charge value by 5 frames
		ticks = math.max(0, ticks - 5)
		local max_ticks = TUNING.SLINGSHOT_MAX_CHARGE_TIME / FRAMES - 5
		local k = math.min(1, ticks / max_ticks)
		inst.chargedmult = k * k
		inst.components.weapon:LaunchProjectile(doer, target)
		inst.chargedmult = nil
	end
end

local function slingshotex_RefreshAttunedSkills(inst, owner)
	if owner then
		inst.components.aoecharging:SetEnabled(inst.components.weapon.projectile ~= nil)
	else
		inst.components.aoecharging:SetEnabled(false)
	end
end

--NOTE: this runs separately from the common OnAmmoLoaded/OnAmmoUnloaded handlers
local function slingshotex_CheckChargeAmmo(inst, data)
	slingshotex_RefreshAttunedSkills(inst, inst._owner)
end

local function slingshotex_WatchSkillRefresh(inst, owner)
	if inst._owner then
		inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh, inst._owner)
		inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh, inst._owner)
		inst:RemoveEventCallback("itemget", slingshotex_CheckChargeAmmo)
		inst:RemoveEventCallback("itemlose", slingshotex_CheckChargeAmmo)
	end
	inst._owner = owner
	if owner then
		inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh, owner)
		inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh, owner)
		inst:ListenForEvent("itemget", slingshotex_CheckChargeAmmo)
		inst:ListenForEvent("itemlose", slingshotex_CheckChargeAmmo)
	end
end

local function slingshotex_OnEquipped(inst, data)
	local owner = data and data.owner or nil
	slingshotex_WatchSkillRefresh(inst, owner)
	slingshotex_RefreshAttunedSkills(inst, owner)
end

local function slingshotex_OnUnequipped(inst, data)
	slingshotex_WatchSkillRefresh(inst, nil)
	slingshotex_RefreshAttunedSkills(inst, nil)
end

---------------------------------------------------------------------------------------------------------------------------
local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil and data ~= nil and data.item ~= nil then
        inst.components.weapon:SetProjectile("marrow_proj")
        inst.components.weapon:SetRange(TUNING.HOUNDSTOOTH_BLOWPIPE_ATTACK_DIST, TUNING.HOUNDSTOOTH_BLOWPIPE_ATTACK_DIST_MAX)
        inst:AddTag("slingshot") -- For SG state.
		
		if inst:HasTag("blackshot") then inst:RemoveTag("blackshot") end
		if data.item.prefab == "mbow_arrow" then inst:AddTag("blackshot")end
		
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then
        inst.components.weapon:SetProjectile(nil)
        inst.components.weapon:SetRange(nil)
        inst:RemoveTag("slingshot") -- For SG state.      
    end
	
	--if inst:HasTag("blackshot") then inst:RemoveTag("blackshot") end		
end

local function OnEquip(inst, owner)    
    owner.AnimState:OverrideSymbol("swap_object", "swap_mhamayumi", "swap_bow_obj")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
		
	if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1.1 
	end	
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	if inst.components.container ~= nil then
        inst.components.container:Close()
    end
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1 
	end	
end

local function OnEquipToModel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end
--------------------------------------------------------------------------------------------------------------

local function OnProjectileLaunched(inst, attacker, target, proj)   
	if inst.components.container ~= nil then
        local ammo_stack = inst.components.container:GetItemInSlot(1)
        local item = inst.components.container:RemoveItem(ammo_stack, false)		
		
        if item ~= nil then
			
			if inst:HasTag("blackshot") then				
				proj:AddComponent("planardamage")
				proj.components.planardamage:SetBaseDamage(25)

				proj:AddComponent("damagetypebonus")
				proj.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.HOUNDSTOOTH_BLOWPIPE_VS_SHADOW_BONUS)
				
				--proj.components.weapon:SetDamage(prodmg)
				proj.AnimState:SetMultColour(0,0,0,.8)
				proj.Light:Enable(true)
				proj:AddTag("blackarrow")			
			end
			
			local prodmg = proj.components.weapon.damage						
			if inst.chargedmult and proj.SetChargedMultiplier then
				if attacker:HasTag("mevileyescraft") and inst.components.rechargeable:IsCharged() then
					inst.components.rechargeable:Discharge(12)				
					proj.components.weapon:SetDamage(prodmg*2)				
				end
				proj:SetChargedMultiplier(inst.chargedmult)
			end
            item:Remove()
        end
    end	
end

local function WeaponFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("mhamayumi.tex")
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mhamayumi")
    inst.AnimState:SetBuild("mhamayumi")
    inst.AnimState:PlayAnimation("idle")

    --weapon (from weapon component) added to pristine state for optimization.
    inst:AddTag("weapon")
	inst:AddTag("rangedweapon")
	
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
	slingshotex_common_postinit(inst)
	
    inst.entity:SetPristine()
		
    if not TheWorld.ismastersim then
		inst.OnEntityReplicated = function(inst)
			if inst.replica.container then inst.replica.container:WidgetSetup("mhamayumi") end
		end	
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")	
    inst.components.inventoryitem.imagename = "mhamayumi"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mhamayumi.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable:SetOnEquipToModel(OnEquipToModel)
	--inst.components.equippable.restrictedtag = "mevileyescraft"	
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(15)
	inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
	inst.components.weapon:SetProjectileOffset(-3)
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mhamayumi")
	inst.components.container.canbeopened = false
	inst.components.container.stay_open_on_hide = true
	
	inst:ListenForEvent("itemget", OnAmmoLoaded)
	inst:ListenForEvent("itemlose", OnAmmoUnloaded)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(10)
    inst.components.finiteuses:SetUses(10)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
	
	inst:AddComponent("rechargeable")
	
	inst.components.aoecharging:SetOnChargedAttackFn(slingshotex_OnChargedAttack)
	inst.components.aoecharging:SetEnabled(false)
	
	inst:ListenForEvent("equipped", slingshotex_OnEquipped)
	inst:ListenForEvent("unequipped", slingshotex_OnUnequipped)
	inst._onskillrefresh = function(owner) slingshotex_RefreshAttunedSkills(inst, owner) end
	
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/mhamayumi", WeaponFn, assets, prefabs) 
		