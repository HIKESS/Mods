local assets=
{      
    Asset("ANIM", "anim/m_katana.zip"),    
    Asset("ANIM", "anim/swap_m_katana.zip"),
    Asset("ANIM", "anim/swap_sm_katana.zip"),
			
	Asset("ANIM", "anim/sc_m_katana.zip"),
	
    Asset("ATLAS", "images/inventoryimages/m_katana.xml"),
    Asset("IMAGE", "images/inventoryimages/m_katana.tex"),
		
}
local prefabs = {}

local function bodycheckfn(inst)
local owner = inst.components.inventoryitem.owner
	if owner and owner:HasTag("player") then 
		local body = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)	
		if body and body.AnimState:BuildHasSymbol("swap_body_tall") then 
			return true
		end
	end
end
	
local function Firstmode(inst)
	local owner = inst.components.inventoryitem.owner
	if owner then
		owner.AnimState:OverrideSymbol("swap_object", "swap_sm_katana", "swap_sobject")
	end
	inst.components.weapon:SetRange(1,1.5)	

	inst.katanamode = 1 --Iai
	inst:RemoveTag("mtachi")
	
	inst:RemoveTag("throw_line")
	inst:AddTag("parryweapon")

	inst:AddTag("miai")
	
	if owner and not bodycheckfn(inst) then owner.AnimState:ClearOverrideSymbol("swap_body_tall")end --owner.prefab == "mevileyes" and 
end

local function Secondmode(inst)
	local owner = inst.components.inventoryitem.owner	
	
	if owner then
		owner.AnimState:OverrideSymbol("swap_object", "swap_m_katana", "swap_object")		
		if not bodycheckfn(inst) then owner.AnimState:OverrideSymbol("swap_body_tall", "sc_m_katana", "tail")end --owner.prefab == "mevileyes" and 
	end
	
	inst.components.weapon:SetRange(.4,1)
	inst.katanamode = 2 --noiai	
	inst:RemoveTag("miai")
	inst:RemoveTag("parryweapon")	
	inst:AddTag("throw_line")
	
	if owner and owner.katanauser and not inst:HasTag("mtachi") then inst:AddTag("mtachi") end
end

local MAX_USES = TUNING.MEVILEYES.KATANAUSE
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
	
	if inst.katanamode == 1 then Firstmode(inst) else  Secondmode(inst) end	
	
	inst.components.aoetargeting:SetEnabled(false)
	if owner and owner.katanauser then  inst.components.rechargeable:Discharge(inst._cooldown)			
		--inst.repairtask = inst:DoPeriodicTask(20, function() TryRepair(inst) end)
	end
		
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		owner.components.locomotor:SetExternalSpeedMultiplier(inst, "mevileyes_katana_mobility", 1.1)
	end
	
	if owner and owner.unlockdeathaura and inst.components.planardamage == nil then	
		inst:AddComponent("planardamage")
		inst.components.planardamage:SetBaseDamage(5)
	end
end
  
local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	inst.components.aoetargeting:SetEnabled(false)
	
	if inst.components.planardamage ~= nil then	
		inst:RemoveComponent("planardamage")		
	end
	
	--if inst.repairtask then inst.repairtask:Cancel() inst.repairtask = nil end
	
	if owner and owner.katanauser and inst:HasTag("mtachi") then inst:RemoveTag("mtachi") end
	if owner and not bodycheckfn(inst) then owner.AnimState:ClearOverrideSymbol("swap_body_tall")end --owner.prefab == "mevileyes" and 
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		owner.components.locomotor:RemoveExternalSpeedMultiplier(inst, "mevileyes_katana_mobility")
	end
end

local function onSave(inst, data)   
    data.katanamode = inst.katanamode 
end

local function onLoad(inst, data)
    if data then
		inst.katanamode = data.katanamode or 1		
	end
end

local function SpawnIaislash(owner, target, black)	
	local x,y,z = target.Transform:GetWorldPosition()	
	local fx = SpawnPrefab("mevileyes_iaislash_fx")
	
	owner.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak") 	
	fx.Transform:SetPosition(x,1,z)			
	fx.Transform:SetRotation(owner.Transform:GetRotation())
end

local function onattack(inst, owner, target)
	if owner.components.rider:IsRiding() then return end
	
	if inst.katanamode == 1 then Secondmode(inst) end
	
	if not inst.hitfx and owner.katanauser then
		SpawnIaislash(owner, target, inst.blackblade) 
		inst.hitfx = inst:DoTaskInTime(0.2, function() inst.hitfx = nil end)		
	end	
end

local function castFn(inst, target)	
    local owner = inst.components.inventoryitem.owner	
	if inst.katanamode == 1 then	
	Secondmode(inst)	
	else 		 
	Firstmode(inst)
	end
end 

local function Onfinish(inst)
	inst:Remove()
end

--------------------------------------------------------------------
local function OnDischarged(inst)
	inst.components.aoetargeting:SetEnabled(false)
end

local function OnCharged(inst)	
   local owner = inst.components.inventoryitem:GetGrandOwner() 

	if owner ~= nil and owner.katanauser then
       inst.components.aoetargeting:SetEnabled(true)	 
    end	
end

local function SpellFn(inst, doer, pos)	
    doer:PushEvent("evileyes_wp_dash", {targetpos = pos, weapon = inst})
end

local function PreLunged(inst, doer, startingpos, targetpos)
	Secondmode(inst)	
end

local function OnLunged(inst, doer, startingpos, targetpos)
	 
	local fx = SpawnPrefab("spear_wathgrithr_lightning_lunge_fx")
	fx.AnimState:SetMultColour(0, 0, 0, 1)
	fx.Light:Enable(false)
    fx.Transform:SetPosition(targetpos:Get())
    fx.Transform:SetRotation(doer:GetRotation())
	
    inst.components.rechargeable:Discharge(inst._cooldown)
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
	
	--inst:AddTag("aoeweapon_leap")
    -- rechargeable (from rechargeable component) added to pristine state for optimization.
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
-----------------------------------------------------------------------
--------------------------------------------------------------------
local function fn()  
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	    
    MakeInventoryPhysics(inst)   
      
    inst.AnimState:SetBank("m_katana")
    inst.AnimState:SetBuild("m_katana")
    inst.AnimState:PlayAnimation("anim")
  
	inst:AddTag("sharp")
	
	inst.spelltype = "SCIENCE"   
    inst:AddTag("veryquickcast")
	
    inst:AddTag("netra_item")
    inst:AddTag("katanaskill")
	
	inst.katanamode = 1 -- status
	
	inst._cooldown = 6
	
	CommonFn_Base(inst)
	
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
	inst.entity:SetPristine()  
	
    if not TheWorld.ismastersim then
		return inst
    end 
	
    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(45)
	inst.components.weapon:SetOnAttack(onattack)
	
	--------------------------------------------------	
	inst:AddComponent("aoeweapon_lunge")
	inst:RemoveTag("aoeweapon_lunge")
    inst.components.aoeweapon_lunge:SetDamage(68)
    inst.components.aoeweapon_lunge:SetSound("dontstarve/tentacle/tentacle_attack")
    inst.components.aoeweapon_lunge:SetSideRange(1)
    inst.components.aoeweapon_lunge:SetOnLungedFn(OnLunged)
    inst.components.aoeweapon_lunge:SetOnPreLungeFn(PreLunged)
    --inst.components.aoeweapon_lunge:SetOnHitFn(OnLungedHit)

    inst.components.aoeweapon_lunge:SetWorkActions()
    inst.components.aoeweapon_lunge:SetTags("_combat")

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(SpellFn)
	
    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)
	
	--------------------------------------------------	
    inst:AddComponent("inspectable")	
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.MEVILEYES.KATANAUSE)
    inst.components.finiteuses:SetUses(TUNING.MEVILEYES.KATANAUSE)
    inst.components.finiteuses:SetOnFinished(Onfinish)
		
	--------------------------------------------------	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "m_katana"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/m_katana.xml"
	
	--------------------------------------------------	
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(castFn)
	inst.components.spellcaster.canusefrominventory = true
	inst.components.spellcaster.veryquickcast = true
	
	--------------------------------------------------	
	inst:AddComponent("equippable")	
	inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
			
    inst.OnSave = onSave
    inst.OnLoad = onLoad
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return  Prefab("common/inventory/m_katana", fn, assets, prefabs) 