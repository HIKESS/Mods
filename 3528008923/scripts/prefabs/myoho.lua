local assets=
{      
    Asset("ANIM", "anim/myoho.zip"),    
    Asset("ANIM", "anim/swap_myoho.zip"),
    Asset("ANIM", "anim/swap_myoho2.zip"),
    Asset("ANIM", "anim/swap_smyoho.zip"),
			
	Asset("ANIM", "anim/sc_myoho.zip"),
	
    Asset("ATLAS", "images/inventoryimages/myoho.xml"),
    Asset("IMAGE", "images/inventoryimages/myoho.tex"),
		
	Asset("IMAGE", "images/map_icons/myoho.tex"),
	Asset("ATLAS", "images/map_icons/myoho.xml"),	
}
local prefabs = {}

local function handcheckfn(inst)
local owner = inst.components.inventoryitem.owner
	if owner and owner:HasTag("player") then 
		local hand = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)	
		if hand and hand == inst then 
			return true
		end
	end
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
		owner.AnimState:OverrideSymbol("swap_object", "swap_smyoho", "swap_sobject")
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
		
		if not inst.blackblade then owner.AnimState:OverrideSymbol("swap_object", "swap_myoho", "swap_object")			
			else owner.AnimState:OverrideSymbol("swap_object", "swap_myoho2", "swap_object")
		end
		
		if not bodycheckfn(inst) then owner.AnimState:OverrideSymbol("swap_body_tall", "sc_myoho", "tail")end --owner.prefab == "mevileyes" and 
	end
	
	inst.components.weapon:SetRange(.4,1)
	inst.katanamode = 2 --noiai	
	inst:RemoveTag("miai")
	inst:RemoveTag("parryweapon")	
	inst:AddTag("throw_line")
	
	if owner and owner.katanauser and not inst:HasTag("mtachi") then inst:AddTag("mtachi") end
end

local function Isblackblade(inst)	
	if inst.katanamode == 2 then Secondmode(inst) end	
		if inst.blackblade ~= nil then 
			local outputdmg = inst.hidden_dmg + inst.blackblade_dmg
			inst.components.planardamage:SetBaseDamage(outputdmg)					
			inst:AddTag("nosteal")
			if inst._voice and inst._voice.talktask ~= nil then inst._voice.side = false inst._voice:ToggleTalking(true) end
		else
			inst.components.planardamage:SetBaseDamage(inst.hidden_dmg)					
			inst:RemoveTag("nosteal")
			if inst._voice and inst._voice.talktask ~= nil then inst._voice.side = true inst._voice:ToggleTalking(true) end
		end		
end

local function ToRoman(num)
    local romans = {
        --{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
        --{100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
        --{10, "X"}, {9, "IX"},
		{5, "V"}, {4, "IV"}, {1, "I"}
    }
    local result = ""
    for _, v in ipairs(romans) do
        while num >= v[1] do
            result = result .. v[2]
            num = num - v[1]
        end
    end
    return result
end

local function DoUpgrade(inst)
	if inst.level > 1 then

		inst.components.named:SetName("Myoho Muramasa "..ToRoman(inst.level))
		
		local MAX_USES = TUNING.MEVILEYES.KATANAUSE + (50 * inst.level)
		inst.components.finiteuses:SetMaxUses(MAX_USES)
				
		inst._cooldown = 20 + (inst.level*4)
		inst.blackblade_dmg = 25 + (inst.level*2)
		inst.hidden_dmg = inst.level * 3
		inst.components.planardamage:SetBaseDamage(inst.hidden_dmg)
		
		inst.components.damagetypebonus:RemoveBonus("shadow_aligned", inst)
		inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, (1 + inst.level/5) )
		
		local shadow_level = math.min(4, inst.level)		
		inst.components.shadowlevel:SetDefaultLevel(shadow_level)
	end
	
	--if inst.level >= 3 then
	--	inst.components.equippable.walkspeedmult = 1.2
	--end
	
	if inst.level >= inst.maxlevel then
		inst.exp = 0
		inst.level = inst.maxlevel
		inst.components.named:SetName("Myoho Muramasa")
		inst._voice.components.talker:Say("I have awakened",3, true)
	end
end

local function expcheck(inst)
	if inst.exp >= (100 * inst.level) then 
		inst.exp = inst.exp - (100 * inst.level) 
		inst.level = inst.level + 1
		DoUpgrade(inst)
	end
end

local function TryRepair(inst)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	local skilltreepoint = 0
	if owner then
		local skilltreeupdater = owner.components.skilltreeupdater		
			if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_itemregen") then skilltreepoint = 3 end
	end
	
    if inst.components.finiteuses then
        local current = inst.components.finiteuses:GetUses()
		local maxuses = inst.components.finiteuses.total
        if current < maxuses then
            local missing = maxuses - current
            local repair_needed = math.min(2, missing)
            inst.components.finiteuses:Repair(repair_needed + skilltreepoint)           
        end
    end
end

local function OnEquip(inst, owner)	
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	
	if inst.katanamode == 1 then Firstmode(inst) else  Secondmode(inst) end	
	
	inst.components.aoetargeting:SetEnabled(false)
	
	if owner and owner.unlockdeathaura then		
		inst.canlevelup = true
		inst.components.aoetargeting:SetEnabled(inst.components.rechargeable:IsCharged() or false)
		if inst._voice and inst.level > 1 then
			inst._voice:ToggleTalking(true)
		end		
	end
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		owner.components.locomotor:SetExternalSpeedMultiplier(inst, "mevileyes_katana_mobility", 1.1)	
	end	
end
  
local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	inst.components.aoetargeting:SetEnabled(false)
	
	if inst._voice then 
		inst._voice:ToggleTalking(false)
	end
	if inst.canlevelup then inst.canlevelup = nil end
	if owner and owner.katanauser and inst:HasTag("mtachi") then inst:RemoveTag("mtachi") end
	if owner and not bodycheckfn(inst) then owner.AnimState:ClearOverrideSymbol("swap_body_tall")end --owner.prefab == "mevileyes" and 
	
	local skilltreeupdater = owner.components.skilltreeupdater
	if skilltreeupdater and owner.components.skilltreeupdater:IsActivated("mevileyes_katana_mobility") then 
		owner.components.locomotor:RemoveExternalSpeedMultiplier(inst, "mevileyes_katana_mobility")
	end
end

local function OnDischarged(inst) 
	local owner = inst.components.inventoryitem:GetGrandOwner()   
	if owner then	
		inst.blackblade = true
		if handcheckfn(inst) then Isblackblade(inst) end		  	
	end
	inst.components.aoetargeting:SetEnabled(false)
end

local function OnCharged(inst)	
   local owner = inst.components.inventoryitem:GetGrandOwner() 
		
	if inst.blackblade then 
		inst.components.rechargeable:Discharge(20) --20
		inst.blackblade = nil 
		if handcheckfn(inst) then Isblackblade(inst) end
		return 
	end
	
	if handcheckfn(inst) then Isblackblade(inst) end
	
	if owner ~= nil and owner.unlockdeathaura then
       inst.components.aoetargeting:SetEnabled(true)	 
    end
	
end

local function onSave(inst, data)   
    data.katanamode = inst.katanamode   
    data.level = inst.level
    data.exp = inst.exp
	if inst.components.finiteuses then
		data._use = inst.components.finiteuses:GetUses()
	end
end

local function onLoad(inst, data)
    if data then
		inst.katanamode = data.katanamode or 1
		inst.level = data.level or 1 
		inst.exp = data.exp or 0 
		
		DoUpgrade(inst)
		
		local itemuse =  data._use or TUNING.MEVILEYES.KATANAUSE		
		if inst.components.finiteuses then inst.components.finiteuses:SetUses(itemuse) end
	end
end

local hitsparks_fx_colouroverride = {1, 0, 0}
local function TryToSparkOn(target, attacker)
    if target ~= nil and target:IsValid() then
        local spark = SpawnPrefab("hitsparks_fx")
        spark:Setup(attacker, target, nil, hitsparks_fx_colouroverride)
        spark.black:set(true)
    end
end

local function SpawnIaislash(owner, target, black)	
	local x,y,z = target.Transform:GetWorldPosition()	
	local fx = SpawnPrefab("mevileyes_iaislash_fx")
	
	owner.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_basic", "fx_lunge_streak") 
	
	if black then fx.AnimState:SetMultColour(0, 0, 0, .8) 
			fx.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
			owner.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_black", "fx_lunge_streak")
	end
	
	fx.Transform:SetPosition(x,1,z)			
	fx.Transform:SetRotation(owner.Transform:GetRotation())
end

local function onattack(inst, owner, target)
	if owner.components.rider:IsRiding() then return end
	
	if inst:IsMarkedCreature(target) then
        inst:TrackTarget(target)
    end
	
	--if not inst.blackblade and inst.components.rechargeable:IsCharged() and owner.unlockdeathaura and owner._evilspeed_task then 
	--	inst.components.rechargeable:Discharge(inst._cooldown) 
	--end 
	
	if inst.katanamode == 1 then Secondmode(inst) end
		
	if target ~= nil and target:IsValid() and inst.blackblade then	
		TryToSparkOn(target, owner)
	end
	
	if not inst.hitfx and owner.katanauser then
		SpawnIaislash(owner, target, inst.blackblade) 
		inst.hitfx = inst:DoTaskInTime(0.2, function() inst.hitfx = nil end)		
	end	
	
	if target and inst:IsMarkedCreature(target) and inst.canlevelup and inst.level < inst.maxlevel then 
		inst.exp = inst.exp + 1	
		expcheck(inst)
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
	if inst._voice then inst._voice:Remove() end	
	inst:Remove()
end

local function SpellFn(inst, doer, pos)	
    doer:PushEvent("evileyes_wp_dash", {targetpos = pos, weapon = inst})
end

local function PreLunged(inst, doer, startingpos, targetpos)
	SpawnPrefab("shadow_teleport_in").Transform:SetPosition(startingpos:Get())	
	SpawnPrefab("shadow_bishop_fx").Transform:SetPosition(startingpos:Get())
	
	Secondmode(inst)	
end

local function OnLunged(inst, doer, startingpos, targetpos)
	SpawnPrefab("shadow_teleport_out").Transform:SetPosition(targetpos:Get())
	SpawnPrefab("abigail_shadow_buff_fx").Transform:SetPosition(startingpos:Get())
	
    doer.AnimState:OverrideSymbol("fx_lunge_streak", "player_lunge_black", "fx_lunge_streak")
	local fx3 = SpawnPrefab("spear_wathgrithr_lightning_lunge_fx")
	fx3.AnimState:SetMultColour(0, 0, 0, 1)
	fx3.Light:Enable(false)
    fx3.Transform:SetPosition(targetpos:Get())
    fx3.Transform:SetRotation(doer:GetRotation())
	
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
	
	--inst:AddTag("parryweapon")

    -- rechargeable (from rechargeable component) added to pristine state for optimization.
    inst:AddTag("rechargeable")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelineping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 0, 0, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
end
-----------------------------------------------------------------------

local function IsMarkedCreature(inst, target)
    return target:HasTag("shadow_aligned") or target:HasTag("lunar_aligned")
end

local function CheckForMarkedCreatureKilled(inst, target)
    if not inst:IsMarkedCreature(target) or not inst.canlevelup then
        return false
    end

    --True condition 
	if inst.level < inst.maxlevel then
		inst.exp = inst.exp + 5 --test def.2
		expcheck(inst)		
	end
	
	inst._voice:DoSmallTalk()
    return true
end

local function TrackTarget(inst, target)
    if inst._trackedentities[target] then
        inst._trackedentities[target] = GetTime()

        return
    end

    if not target:IsValid() then
        return
    end

    inst._trackedentities[target] = GetTime()

    inst:ListenForEvent("death", inst._ontargetdeath, target)
    inst:ListenForEvent("onremove", inst._ontargetremoved, target)
end

local function ForgetTarget(inst, target)
    if inst._trackedentities[target] then
        inst:RemoveEventCallback("death", inst._ontargetdeath, target)
        inst:RemoveEventCallback("onremove", inst._ontargetremoved, target)

        inst._trackedentities[target] = nil
    end
end

local function ForgetAllTargets(inst)
    for target, time in pairs(inst._trackedentities) do
        inst:ForgetTarget(target)
    end
end

--------------------------------------------------------------------
local function fn()  
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon( "myoho.tex" )
    
    MakeInventoryPhysics(inst)   
      
    inst.AnimState:SetBank("myoho")
    inst.AnimState:SetBuild("myoho")
    inst.AnimState:PlayAnimation("anim")
  
	inst:AddTag("sharp")
	inst:AddTag("netra_item")
	
	inst.spelltype = "SCIENCE"   
    inst:AddTag("veryquickcast")
	
    inst:AddTag("katanaskill")
	
	inst.katanamode = 1 -- status
	
	MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
	inst.entity:SetPristine()  
	
	CommonFn_Base(inst)
	
    if not TheWorld.ismastersim then
		return inst
    end 
	--------------------------------------------------
	inst._cooldown = 20	
	inst.blackblade_dmg = 25
	inst.hidden_dmg = 0
	inst.level = 1
	inst.maxlevel = 5
	inst.exp = 0
	
	inst._trackedentities = {}
	
	inst.CheckForMarkedCreatureKilled = CheckForMarkedCreatureKilled
	inst.IsMarkedCreature = IsMarkedCreature
	inst.TrackTarget = TrackTarget
    inst.ForgetTarget = ForgetTarget
    inst.ForgetAllTargets = ForgetAllTargets    
    inst._ontargetremoved = function(marked, data) inst:ForgetTarget(marked) end
    inst._ontargetdeath = function(marked, data)
        if inst._trackedentities[marked] ~= nil and
            (inst._trackedentities[marked] + TUNING.SHADOW_BATTLEAXE.RECENT_TARGET_TIME) >= GetTime()
        then
            inst:CheckForMarkedCreatureKilled(marked)
        end
    end

    inst:AddComponent("aoeweapon_lunge")
	inst:RemoveTag("aoeweapon_lunge")
    inst.components.aoeweapon_lunge:SetDamage(68)
	inst.components.aoeweapon_lunge:SetSound("dontstarve/tentacle/tentacle_attack")
    --inst.components.aoeweapon_lunge:SetSound("dontstarve/sanity/death_pop")
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
	
    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.MEVILEYES.KATANADMG)
	inst.components.weapon:SetOnAttack(onattack)
	
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(5)
	inst:AddComponent("shadowlevel")
	inst:AddComponent("damagetypebonus")
	--------------------------------------------------	
    inst:AddComponent("inspectable")	
	inst:AddComponent("named")
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.MEVILEYES.KATANAUSE)
    inst.components.finiteuses:SetUses(TUNING.MEVILEYES.KATANAUSE)
    inst.components.finiteuses:SetOnFinished(Onfinish)
		
	--------------------------------------------------	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "myoho"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/myoho.xml"
	
	--------------------------------------------------	
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(castFn)
	inst.components.spellcaster.canusefrominventory = true
	inst.components.spellcaster.veryquickcast = true
	
	--------------------------------------------------	
	inst:AddComponent("equippable")	
	inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	inst.repairtask = inst:DoPeriodicTask(20, function() TryRepair(inst) end)
	
	inst._voice = SpawnPrefab("mevileyes_whisper")
    inst._voice.entity:SetParent(inst.entity)
		
    inst.OnSave = onSave
    inst.OnLoad = onLoad
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return  Prefab("common/inventory/myoho", fn, assets, prefabs) 