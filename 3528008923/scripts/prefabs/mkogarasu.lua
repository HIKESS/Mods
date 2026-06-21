local assets=
{
    Asset("ANIM", "anim/mkogarasu.zip"),    
    Asset("ANIM", "anim/swap_mkogarasu.zip"),   
    Asset("ANIM", "anim/swap_smkogarasu.zip"),
    Asset("ANIM", "anim/sc_mkogarasu.zip"),
	
    Asset("ATLAS", "images/inventoryimages/mkogarasu.xml"),
    Asset("IMAGE", "images/inventoryimages/mkogarasu.tex"),
	
}
local prefabs = {}

local MAX_USES = TUNING.MEVILEYES.KATANAUSE
local function TryRepair(inst, amount)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	local skilltreepoint = 0
	if owner then
		local skilltreeupdater = owner.components.skilltreeupdater		
			if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_itemregen") then skilltreepoint = 3 end
	end
	
    if inst.components.finiteuses then
        local current = inst.components.finiteuses:GetUses()
        if current < MAX_USES then
            local missing = MAX_USES - current
            local repair_needed = math.min(amount, missing)
            inst.components.finiteuses:Repair(repair_needed  + skilltreepoint)           
        end
    end
end

local function RefreshAttunedSkills(inst, owner, prevowner)	
	inst.components.aoetargeting:SetEnabled(inst.components.rechargeable:IsCharged() or false)	
end

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
		owner.AnimState:OverrideSymbol("swap_object", "swap_smkogarasu", "swap_sobject")
	end	
	inst.components.weapon:SetRange(1,1.5)

	inst.katanamode = 1 --Iai
	inst:RemoveTag("mtachi")	
	
	inst:RemoveTag("throw_line")	
	inst:AddTag("parryweapon")
	
	inst:AddTag("miai")
	
	if owner and not bodycheckfn(inst) then owner.AnimState:ClearOverrideSymbol("swap_body_tall")end -- owner.prefab == "mevileyes" and
end

local function Secondmode(inst)
	local owner = inst.components.inventoryitem.owner
	if owner then	
		owner.AnimState:OverrideSymbol("swap_object", "swap_mkogarasu", "swap_object")
		if not bodycheckfn(inst) then owner.AnimState:OverrideSymbol("swap_body_tall", "sc_mkogarasu", "tail")end -- owner.prefab == "mevileyes" and 
	end
	inst.components.weapon:SetRange(.4,1)

	inst.katanamode = 2 --noiai	
	inst:RemoveTag("miai")
	inst:RemoveTag("parryweapon")	
	inst:AddTag("throw_line")
	
	if owner and owner.katanauser and not inst:HasTag("mtachi") then inst:AddTag("mtachi") end
end

local function OnEquip(inst, owner)	
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	
	RefreshAttunedSkills(inst, owner)
	if inst.katanamode == 1 then 
    Firstmode(inst)
	else  Secondmode(inst) end
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1.1 
	end
	
end
  
local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	if owner and owner.katanauser and inst:HasTag("mtachi") then inst:RemoveTag("mtachi") end
	if owner and not bodycheckfn(inst) then owner.AnimState:ClearOverrideSymbol("swap_body_tall")end -- owner.prefab == "mevileyes" and 
	RefreshAttunedSkills(inst, nil, owner)
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		inst.components.equippable.walkspeedmult = 1
	end
	
	if inst._chargefx then inst._chargefx:Cancel() end
	inst._chargefx = nil 
end

local function Lightning_SpellFn(inst, doer, pos)
    doer:PushEvent("evileyes_wp_dash", {targetpos = pos, weapon = inst})
	
end

local function Lightning_OnLunged(inst, doer, startingpos, targetpos)    
	Secondmode(inst)
	doer.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
	local fx = SpawnPrefab("spear_wathgrithr_lightning_lunge_fx")
    fx.Transform:SetPosition(targetpos:Get())
    fx.Transform:SetRotation(doer:GetRotation())
	
	local fx2 = SpawnPrefab("electricchargedfx")			
		fx2.entity:AddFollower():FollowSymbol(doer.GUID, "swap_body", 0, 0, 0)
		
    inst.components.rechargeable:Discharge(8)
	
	inst.components.weapon:SetElectric(1.5, 1.6)
	inst.components.weapon.stimuli = "electric"
	inst.electrohitfx = true
	
	inst._lunge_hit_count = nil
	
	inst._chargefx = inst:DoPeriodicTask(1, function()	
		local fx = SpawnPrefab("electricchargedfx")
			fx.Transform:SetScale(.5, .5, .5)
			fx.entity:AddFollower():FollowSymbol(doer.GUID, "swap_body", 0, 0, 0)
	end)
end

local function Lightning_OnLungedHit(inst, doer, target) 
	inst._lunge_hit_count = inst._lunge_hit_count or 0
	if inst._lunge_hit_count < 2 then
        TryRepair(inst, 10)      
        inst._lunge_hit_count = inst._lunge_hit_count + 1
    end    
end

local function PreLunged(inst, doer, startingpos, targetpos)	
	Secondmode(inst)
end

local function Lightning_OnDischarged(inst)
    inst.components.aoetargeting:SetEnabled(false)
end

local function Lightning_OnCharged(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
   
	if inst.electrohitfx then
		inst.components.rechargeable:Discharge(inst._cooldown)
		inst.components.weapon.stimuli = nil
		inst.electrohitfx = nil
		if inst._chargefx then inst._chargefx:Cancel() end
		inst._chargefx = nil 
		return
	end
	
	if owner ~= nil then
        inst.components.aoetargeting:SetEnabled(true)
    end	
end

------------------------------------------------------------------------------------------------------------------------

local function Lightning_ReticuleTargetFn()    
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function Lightning_ReticuleMouseTargetFn(inst, mousepos)
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

local function Lightning_ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
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

local function LightningSpearCommonFn_Base(inst)   
    --inst:AddTag("parryweapon")
    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
    inst.components.aoetargeting.reticule.targetfn = Lightning_ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = Lightning_ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = Lightning_ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
end

local function LightningSpearPostInitFn_Base(inst)

    inst._cooldown = 2
	
    inst.components.aoetargeting:SetEnabled(false)

    inst:AddComponent("aoeweapon_lunge")
	inst:RemoveTag("aoeweapon_lunge")
    inst.components.aoeweapon_lunge:SetDamage(TUNING.SPEAR_WATHGRITHR_LIGHTNING_LUNGE_DAMAGE)
    inst.components.aoeweapon_lunge:SetSound("dontstarve/tentacle/tentacle_attack")
	--inst.components.aoeweapon_lunge:SetSound("meta3/wigfrid/spear_lighting_lunge_thunder")
    inst.components.aoeweapon_lunge:SetSideRange(1)
    inst.components.aoeweapon_lunge:SetOnLungedFn(Lightning_OnLunged)
    inst.components.aoeweapon_lunge:SetOnHitFn(Lightning_OnLungedHit)
	inst.components.aoeweapon_lunge:SetOnPreLungeFn(PreLunged)
    inst.components.aoeweapon_lunge:SetStimuli("electric")
    inst.components.aoeweapon_lunge:SetWorkActions()
    inst.components.aoeweapon_lunge:SetTags("_combat")

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(Lightning_SpellFn)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(Lightning_OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(Lightning_OnCharged)
end

local function onSave(inst, data)   
    data.katanamode = inst.katanamode     
end

local function onLoad(inst, data)
    if data then	
        inst.katanamode = data.katanamode or 1 		
    end	
end

local function SpawnIaislash(owner, target)	
	local x,y,z = target.Transform:GetWorldPosition()	
	local fx = SpawnPrefab("mevileyes_iaislash_fx")
		
	fx.Transform:SetPosition(x,1,z)			
	fx.Transform:SetRotation(owner.Transform:GetRotation())
end

local function onattack(inst, owner, target)
	if owner.components.rider:IsRiding() then return end
	
	if inst.katanamode == 1 then Secondmode(inst) end	
	if inst.electrohitfx then 
		SpawnElectricHitSparks(owner, target, true)
		owner.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_blue", "fx_lunge_streak")
	end
	
	if target.components.burnable ~= nil and target.components.burnable:IsBurning() then
		target.components.burnable:Extinguish()
	end
		
	if not inst.hitfx and owner.katanauser then
		SpawnIaislash(owner, target) 
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
	if inst.repairtask then inst.repairtask:Cancel()end
	inst.repairtask = nil 
	inst:Remove()	
end

local function fn()  
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("mkogarasu.tex")
	
    MakeInventoryPhysics(inst)   
      
    inst.AnimState:SetBank("mkogarasu")
    inst.AnimState:SetBuild("mkogarasu")
    inst.AnimState:PlayAnimation("anim")
	
	inst._onskillrefresh = function(owner) RefreshAttunedSkills(inst, owner) end
	inst:AddTag("aoeweapon_lunge")   
    inst:AddTag("rechargeable")
	
	--inst:AddTag("nosteal")    
	inst:AddTag("sharp")	
	inst:AddTag("netra_item")	
	
	inst.spelltype = "SCIENCE"   
    inst:AddTag("veryquickcast")
	
    inst:AddTag("katanaskill")
	
	inst.katanamode = 1 	 -- status
	   	    
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)

	LightningSpearCommonFn_Base(inst)
	
	inst.entity:SetPristine()   
    if not TheWorld.ismastersim then
        return inst
    end
	--------------------------------------------------
		
    inst:AddComponent("weapon")
	LightningSpearPostInitFn_Base(inst)

	inst.components.weapon:SetDamage(TUNING.MEVILEYES.KATANADMG)
	inst.components.weapon:SetOnAttack(onattack)
	
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(10)
	
	--------------------------------------------------
	
    inst:AddComponent("inspectable")
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.MEVILEYES.KATANAUSE)
    inst.components.finiteuses:SetUses(TUNING.MEVILEYES.KATANAUSE)
    inst.components.finiteuses:SetOnFinished(Onfinish)

	--------------------------------------------------
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mkogarasu"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mkogarasu.xml"
	--------------------------------------------------
	
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(castFn)
	inst.components.spellcaster.canusefrominventory = true
	inst.components.spellcaster.veryquickcast = true
	--------------------------------------------------
	
	inst:AddComponent("equippable")

	inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	inst.repairtask = inst:DoPeriodicTask(20, function() TryRepair(inst, 1) end)
		
    inst.OnSave = onSave
    inst.OnLoad = onLoad
		   
	MakeHauntableLaunch(inst)	
		
    return inst
end

return  Prefab("common/inventory/mkogarasu", fn, assets, prefabs) 