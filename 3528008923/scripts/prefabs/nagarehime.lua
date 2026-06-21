local assets=
{
    Asset("ANIM", "anim/nagarehime.zip"),   
    Asset("ANIM", "anim/swap_nagarehime.zip"),
    
    Asset("ATLAS", "images/inventoryimages/nagarehime.xml"),
    Asset("IMAGE", "images/inventoryimages/nagarehime.tex"),	
}


local MAX_USES = 150
local REPAIR_PER = 1
local function TryRepair(inst)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	local skilltreepoint = 0
	if owner then
		local skilltreeupdater = owner.components.skilltreeupdater		
			if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_itemregen") then skilltreepoint = 2 end
	end
	
    if inst.components.finiteuses then
        local current = inst.components.finiteuses:GetUses()
        if current < MAX_USES then
            local missing = MAX_USES - current
            local repair_needed = math.min(REPAIR_PER, missing)
            inst.components.finiteuses:Repair(repair_needed  + skilltreepoint)           
        end
    end
end

local function OnEquip(inst, owner)   
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("swap_object", "swap_nagarehime", "swap_object")
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1.1 
	end
	
	inst.components.aoetargeting:SetEnabled(false)
	
	if owner and owner.katanauser and not inst:HasTag("mtachi") then inst:AddTag("mtachi") inst.components.weapon:SetRange(1.5, 1.8)
		--inst.repairtask = inst:DoPeriodicTask(20, function() TryRepair(inst) end)
		--inst.components.aoetargeting:SetEnabled(inst.components.rechargeable:IsCharged() or false)
		inst.components.rechargeable:Discharge(inst._cooldown)
	end
	
	if owner and owner.unlockdeathaura and inst.components.planardamage == nil then	
		inst:AddComponent("planardamage")
		inst.components.planardamage:SetBaseDamage(10)
	end
end
  
local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	--if inst.repairtask then inst.repairtask:Cancel() inst.repairtask = nil end
	
	if inst.components.planardamage ~= nil then	
		inst:RemoveComponent("planardamage")		
	end
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1 
	end
		
	if owner and owner.katanauser and inst:HasTag("mtachi") then inst:RemoveTag("mtachi") inst.components.weapon:SetRange(1, 1.2) end
end

local function SpawnIaislash(owner, target)	
	local x,y,z = target.Transform:GetWorldPosition()	
	local fx = SpawnPrefab("mevileyes_iaislash_fx")
		
	fx.Transform:SetPosition(x,1,z)			
	fx.Transform:SetRotation(owner.Transform:GetRotation())
end

local function onattack(inst, owner, target)
	if owner.components.rider:IsRiding() then return end
			
	if not inst.hitfx and owner.katanauser then
		SpawnIaislash(owner, target) 
		inst.hitfx = inst:DoTaskInTime(0.2, function() inst.hitfx = nil end)
	end	
end

local function Onfinish(inst)	
	inst:Remove()
end
-----------------------------------------------------------------

local function SpellFn(inst, doer, pos)
    doer:PushEvent("combat_lunge", { targetpos = pos, weapon = inst })
end

local function OnLunged(inst, doer, startingpos, targetpos)
    doer.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak")
	local fx3 = SpawnPrefab("spear_wathgrithr_lightning_lunge_fx")
	fx3.AnimState:SetMultColour(0, 0, 0, 1)
	fx3.Light:Enable(false)
    fx3.Transform:SetPosition(targetpos:Get())
    fx3.Transform:SetRotation(doer:GetRotation())
	
    inst.components.rechargeable:Discharge(inst._cooldown)
end

local function OnLungedHit(inst, doer, target)
	TryRepair(inst)
    --inst.components.finiteuses:Repair(TUNING.SPEAR_WATHGRITHR_LIGHTNING_CHARGED_LUNGE_REPAIR_AMOUNT)       
end

local function OnDischarged(inst)
    inst.components.aoetargeting:SetEnabled(false)
end

local function OnCharged(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil and owner.katanauser then
        inst.components.aoetargeting:SetEnabled(true)
    end
end

------------------------------------------------------------------------------------------------------------------------

local function ReticuleTargetFn()
    --Cast range is 8, leave room for error (6.5 lunge)
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function  ReticuleMouseTargetFn(inst, mousepos)
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

local function CommonFn_Base(inst)
    -- aoeweapon_lunge (from aoeweapon_lunge component) added to pristine state for optimization.
    inst:AddTag("aoeweapon_lunge")

    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
end

local function PostInitFn_Base(inst)
       
    inst._cooldown = 6
   
    inst.components.aoetargeting:SetEnabled(false)

    inst:AddComponent("aoeweapon_lunge")
    inst.components.aoeweapon_lunge:SetDamage(55)
    inst.components.aoeweapon_lunge:SetSound("turnoftides/common/together/boat/jump")
    inst.components.aoeweapon_lunge:SetSideRange(1)
    inst.components.aoeweapon_lunge:SetOnLungedFn(OnLunged)
    inst.components.aoeweapon_lunge:SetOnHitFn(OnLungedHit)

    inst.components.aoeweapon_lunge:SetWorkActions()
    inst.components.aoeweapon_lunge:SetTags("_combat")

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(SpellFn)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)
end

local function fn()  
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()	
    
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("nagarehime.tex")
	
    MakeInventoryPhysics(inst)  
      
    inst.AnimState:SetBank("nagarehime")
    inst.AnimState:SetBuild("nagarehime")
    inst.AnimState:PlayAnimation("anim")
	
	inst:AddTag("sharp")
	inst:AddTag("netra_item")
	
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("med")
    inst.components.floater:SetVerticalOffset(0.1)
	
	inst.entity:SetPristine()
	
	CommonFn_Base(inst)
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("weapon")	
	inst.components.weapon:SetDamage(42)
	inst.components.weapon:SetRange(1, 1.2)
	inst.components.weapon:SetOnAttack(onattack)

	PostInitFn_Base(inst)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(150)
    inst.components.finiteuses:SetUses(150)
    inst.components.finiteuses:SetOnFinished(Onfinish)
	
	
    inst:AddComponent("inspectable")    
    inst:AddComponent("inventoryitem")
	
    inst.components.inventoryitem.imagename = "nagarehime"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/nagarehime.xml"	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	MakeHauntableLaunch(inst)		
    return inst
end

return  Prefab("common/inventory/nagarehime", fn, assets)