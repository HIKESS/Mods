local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_lightning_gauntlet.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_lightning_gauntlet.tex"),

    Asset("IMAGE", "images/map_icons/sdf_lightning_gauntlet_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_lightning_gauntlet_mm.xml"),

    Asset("ANIM", "anim/sdf_lightning_gauntlet.zip"),
    Asset("ANIM", "anim/swap_sdf_lightning_gauntlet.zip"),
    Asset("ANIM", "anim/swap_sdf_lightning_gauntlet_charged.zip"),
    Asset("ANIM", "anim/swap_sdf_lightning_gauntlet_transfer.zip"),

    Asset("IMAGE", "images/inv_slot/inv_slot_lightning.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_lightning.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_goodlightning.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_goodlightning.xml"),
}

prefabs = {
}

local function CapacitorWidgetHUDPositionFn(self, doer)
  if not TheNet:IsDedicated() then
    local hudscaleadjust = Profile:GetHUDSize()*2
    local qs_pos = INVINFO.EQUIPSLOT_hands:GetWorldPosition()

    if doer and doer.HUD and doer.HUD.controls then		
      if doer.HUD.controls.containers[self.inst].CapacitorHasAnchor == nil then
        doer.HUD.controls.containers[self.inst].CapacitorHasAnchor = true

        doer.HUD.controls.containers[self.inst]:SetVAnchor(ANCHOR_BOTTOM)
        doer.HUD.controls.containers[self.inst]:SetHAnchor(ANCHOR_LEFT)
      end

      if doer.HUD.controls.containers[self.inst] then
        doer.HUD.controls.containers[self.inst]:UpdatePosition(qs_pos.x, (qs_pos.y+60+hudscaleadjust))	
      end
    end
  end
end

local CAPACITOR_FIRST_OPEN = false --Use for first time capacitor slot opens


local function onfinished(inst)
    inst.components.container:DropEverything()
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        local brokentool = SpawnPrefab("brokentool")
        brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
end

local function ReticuleTargetFn()
    for m=7,0,-.25 do Vector3().x,Vector3().y,Vector3().z = ThePlayer.entity:LocalToWorldSpace(m,0,0)
	if TheWorld.Map:IsPassableAtPoint(Vector3():Get()) and not TheWorld.Map:IsGroundTargetBlocked(Vector3()) then 
	    return Vector3()
	end
    end
    return Vector3()
end

local function learnPunchSpell(inst,doer,pos)
end

local LIGHTNING_CHARGED_NOTAGS_VANILLA = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"abigail", "companion", "shadowminion", "player"
}
local LIGHTNING_CHARGED_NOTAGS_PVP = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"playerghost", "corpse"
}

local function learnLightningSpell(inst,doer,pos)
    --Bolt Anim
    local boltFX = SpawnPrefab("sdf_lightning_charged_bolt_fx")
    boltFX.Transform:SetPosition(pos.x, pos.y, pos.z)

    --Impact Anim
    inst:DoTaskInTime(0.2, function()
    local crackleFX = SpawnPrefab("sdf_lightning_charged_crackle_fx")
    crackleFX.Transform:SetPosition(pos.x, pos.y, pos.z)
    end)

    --AOE Anim and Damage
    inst:DoTaskInTime(0.3, function()
	local cracklebaseFX = SpawnPrefab("sdf_lightning_charged_cracklebase_fx")
	cracklebaseFX.Transform:SetPosition(pos.x, pos.y, pos.z)
	cracklebaseFX.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/hammer")

	--AOE Damage
	for _, ent in pairs(TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_AOE_RADIUS, nil, 
	TheNet:GetPVPEnabled() and LIGHTNING_CHARGED_NOTAGS_PVP or LIGHTNING_CHARGED_NOTAGS_VANILLA)) do
		
	    if ent:IsValid() and (not ent:IsInLimbo()) and ent.components.combat then
		local targetrange = TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_AOE_RADIUS + ent:GetPhysicsRadius(0.5)
		if ent:GetDistanceSqToPoint(pos) < targetrange * targetrange then
		    if doer.components.combat:CanTarget(ent) and not doer.components.combat:IsAlly(ent) then
			--Deal Damage
			doer.components.combat.ignorehitrange = true
			doer.components.combat:DoAttack(ent, cracklebaseFX, cracklebaseFX)
			doer.components.combat.ignorehitrange = false
		    end
		end
	    end 
	end
    end)

    --Deal damage to gauntlet and ammo
    inst.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_USAGE)
    if inst.components.container ~= nil then
	local itemSlot1 = inst.components.container:GetItemInSlot(1)
	if (inst.ModeState == "LIGHTNING") and itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then
	    itemSlot1.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_CONSUME)
	end
    end

    --Cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_COOLDOWN)
end


local function goodLightningAllyOnHit(inst, attacker, target)
    --Random Animation
    local electricutefx = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
    if electricutefx then
	if target:HasTag("largecreature") or target:HasTag("epic") then
	    inst.AnimState:SetScale(1.2,1.2)
	end

	local follower = electricutefx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	electricutefx:FacePoint(inst.Transform:GetWorldPosition())

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--electricute fx
	local goodlightningShockFX = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
	if goodlightningShockFX then
	    goodlightningShockFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
	local goodlightningHealFX = SpawnPrefab("spider_heal_target_fx")
	if goodlightningHealFX then
	    goodlightningHealFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end

	--Skill Tree Embalming
	if attacker.prefab == "sdf" then
	    if attacker.components.skilltreeupdater:IsActivated("sdf_undeath_3") then
		--Buff effect
		if  target.components.combat and (target.components.health and not target.components.health:IsDead()) then
		    --hot buff
		    if target._sdf_goodlightning_embalming_hot_bufftask ~= nil then
			target._sdf_goodlightning_embalming_hot_bufftask:Cancel()
		    end
		    --hot anim
		    if target._sdf_goodlightning_embalming_hot_buffFXtask ~= nil then
			target._sdf_goodlightning_embalming_hot_buffFXtask:Cancel()
		    end

		    --Remove buff and anim
		    target._sdf_goodlightning_embalming_hot_bufftask = target:DoTaskInTime(TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_DURATION, function(i)
			i._sdf_goodlightning_embalming_hot_buffFXtask:Cancel() i._sdf_goodlightning_embalming_hot_buffFXtask = nil
		    end)

		    --Add buff and anim
		    target._sdf_goodlightning_embalming_hot_buffFXtask = target:DoPeriodicTask(1, function(i)
			if target ~= nil and (target.components.health and not target.components.health:IsDead()) then
			    --Ally Heal
			    local totalAdjustHot = (TUNING.SDF_GOODLIGHTNING_CHARGED_HEAL * TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_PERCENT) / TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_HOT_BUFF_DURATION
			    if target:HasTag("sdf_undeath_healing") then
				--Heal
				target.components.health:DoDelta((totalAdjustHot * TUNING.SDF_GOODLIGHTNING_HEAL_UNDEATH_MULTI), false, "goodlightning")
			    else
				--Heal
				target.components.health:DoDelta(totalAdjustHot, false, "goodlightning")
			    end
			    target._sdf_goodlightning_embalming_hot_buffFX = SpawnPrefab("spider_heal_target_fx")
			    target._sdf_goodlightning_embalming_hot_buffFX.entity:SetParent(target.entity)

			    if target.SoundEmitter then
				target.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")
			    end
			end
		    end)
		end
	    end
	end
    end
end

local function goodLightningHostileOnHit(inst, attacker, target)
    --Random Animation
    local electricutefx = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
    if electricutefx then
	if target:HasTag("largecreature") or target:HasTag("epic") then
	    inst.AnimState:SetScale(1.2,1.2)
	end

	local follower = electricutefx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	electricutefx:FacePoint(inst.Transform:GetWorldPosition())

	if target.SoundEmitter then
	    target.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
	end

	--electricute fx
	local goodlightningShockFX = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
	if goodlightningShockFX then
	    goodlightningShockFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
	local goodlightningHealFX = SpawnPrefab("spider_heal_target_fx")
	if goodlightningHealFX then
	    goodlightningHealFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end

	--DeAggro effect
	if not target:HasTag("epic") then
	    local totalAdjustAggroDuration = 0

	    --Skill Tree Embalming
	    if attacker.prefab == "sdf" then
		if attacker.components.skilltreeupdater:IsActivated("sdf_undeath_3") then
		    totalAdjustAggroDuration = TUNING.SDF_SKILLSET_UNDEATH_EMBALMING_3_AGGRO_DEBUFF_DURATION
		end
	    end

	    --remove aggro debuff
	    if target.components.combat.target == attacker then
		target.components.combat:DropTarget()
	    end

	    if target._sdf_goodlightning_aggro_debufftask ~= nil then
		target._sdf_goodlightning_aggro_debufftask:Cancel()
	    end
	    --remove aggro anim
	    if target._sdf_goodlightning_aggro_debuffFXtask ~= nil then
		target._sdf_goodlightning_aggro_debuffFXtask:Cancel()
	    end

	    --Remove debuff and anim
	    target._sdf_goodlightning_aggro_debufftask = target:DoTaskInTime((TUNING.SDF_GOODLIGHTNING_CHARGED_AGGRO_DEBUFF_DURATION + totalAdjustAggroDuration), function(i)
		i.components.combat:RemoveShouldAvoidAggro(attacker) i._sdf_goodlightning_aggro_debufftask = nil
		i._sdf_goodlightning_aggro_debuffFXtask:Cancel() i._sdf_goodlightning_aggro_debuffFXtask = nil
	    end)

	    --Add debuff and anim
	    target.components.combat:SetShouldAvoidAggro(attacker)
	    target._sdf_goodlightning_aggro_debuffFXtask = target:DoPeriodicTask(1, function(i)
		if target ~= nil and not target.components.health:IsDead() then
		    target._sdf_goodlightning_aggro_debuffFX = SpawnPrefab("sdf_goodlightning_charged_electricute_fx")
		    target._sdf_goodlightning_aggro_debuffFX.entity:SetParent(target.entity)
		end
	    end)
	end
    end
end

local GOODLIGHTNING_CHARGED_NOTAGS_VANILLA = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible"
}
local GOODLIGHTNING_CHARGED_NOTAGS_PVP = {
	"INLIMBO", "NOCLICK", "FX", "notarget", "noattack", "flight", "invisible", 
	"playerghost", "corpse"
}

local function learnGoodlightningSpell(inst,doer,pos)
    --Bolt Anim
    local boltFX = SpawnPrefab("sdf_goodlightning_charged_bolt_fx")
    boltFX.Transform:SetPosition(pos.x, pos.y, pos.z)

    --Impact Anim
    inst:DoTaskInTime(0.2, function()
    local crackleFX = SpawnPrefab("sdf_goodlightning_charged_crackle_fx")
    crackleFX.Transform:SetPosition(pos.x, pos.y, pos.z)
    end)

    --AOE Anim
    inst:DoTaskInTime(0.3, function()
	local cracklebaseFX = SpawnPrefab("sdf_goodlightning_charged_cracklebase_fx")
	cracklebaseFX.Transform:SetPosition(pos.x, pos.y, pos.z)
	cracklebaseFX.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/hammer")

	--Ally Counter
	local allyCounter = 0

	--AOE Damage
	for _, ent in pairs(TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_AOE_RADIUS, nil, 
	TheNet:GetPVPEnabled() and GOODLIGHTNING_CHARGED_NOTAGS_PVP or GOODLIGHTNING_CHARGED_NOTAGS_VANILLA)) do

	    if ent:IsValid() and (not ent:IsInLimbo()) and ent.components.combat then
		local targetrange = TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_AOE_RADIUS + ent:GetPhysicsRadius(0.5)
		if ent:GetDistanceSqToPoint(pos) < targetrange * targetrange then

		    --Check for Allies
		    if ent ~= doer and  (doer.components.combat:IsAlly(ent) or ent:HasTag("player"))then
			--Ally Counter
			allyCounter = allyCounter + 1

			--Ally Heal
			if ent:HasTag("sdf_undeath_healing") then
			    --Heal
			    ent.components.health:DoDelta((TUNING.SDF_GOODLIGHTNING_CHARGED_HEAL * TUNING.SDF_GOODLIGHTNING_HEAL_UNDEATH_MULTI), false, "goodlightning")
			else
			    --Heal
			    ent.components.health:DoDelta(TUNING.SDF_GOODLIGHTNING_CHARGED_HEAL, false, "goodlightning")

			    --Sanity Heal
			    if ent.components.sanity then
				ent.components.sanity:DoDelta(TUNING.SDF_GOODLIGHTNING_CHARGED_SANITY_HEAL)
			    end
			end
			goodLightningAllyOnHit(inst, doer, ent)
		    end
		end
	    end
	end

	--Check Hostile Heal
	if allyCounter == 0 then
	    for _, ent in pairs(TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_AOE_RADIUS, nil, 
	    TheNet:GetPVPEnabled() and GOODLIGHTNING_CHARGED_NOTAGS_PVP or GOODLIGHTNING_CHARGED_NOTAGS_VANILLA)) do

		if ent:IsValid() and (not ent:IsInLimbo()) and ent.components.combat then
		    local targetrange = TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_AOE_RADIUS + ent:GetPhysicsRadius(0.5)
		    if ent:GetDistanceSqToPoint(pos) < targetrange * targetrange then

			--Check for Non Allies
			if (ent ~= doer and not doer.components.combat:IsAlly(ent)) or (ent ~= doer and not ent:HasTag("player")) then

			    --Non Ally Heal and Deaggro
			    ent.components.health:DoDelta(TUNING.SDF_GOODLIGHTNING_CHARGED_HEAL, false, "goodlightning")
			    goodLightningHostileOnHit(inst, doer, ent)
			end
		    end
		end
	    end
	end
    end)

    --Damage Caster
    if doer.components.combat and doer.components.health and not doer.components.health:IsDead() then
	doer.components.health:DoDelta(-TUNING.SDF_GOODLIGHTNING_CHARGED_HEAL, false, "goodlightning")
    end

    --Deal damage to gauntlet and ammo
    inst.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_USAGE)
    if inst.components.container ~= nil then
	local itemSlot2 = inst.components.container:GetItemInSlot(2)
	if (inst.ModeState == "GOODLIGHTNING") and itemSlot2 ~= nil and itemSlot2.prefab == "sdf_goodlightning" then
	    itemSlot2.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_CONSUME)
	end
    end

    --Cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_COOLDOWN)
end

local function removeGauntletFX(inst)
    if inst:HasTag("sdf_lightning_gauntlet_zap") then
	inst:RemoveTag("sdf_lightning_gauntlet_zap")
    end
    if inst:HasTag("sdf_lightning_gauntlet_mend") then
	inst:RemoveTag("sdf_lightning_gauntlet_mend")
    end

    if inst.fires ~= nil then
	for i, fx in ipairs(inst.fires) do
	    fx:Remove()
	end
	inst.fires = nil
	--owner.SoundEmitter:PlaySound("dontstarve/common/fireOut")
    end
end

local function modeStateLightningToggle(inst)
    if inst.components.container ~= nil then
	local itemSlot1 = inst.components.container:GetItemInSlot(1)
	if (inst.ModeState == "PUNCH" or inst.ModeState == "GOODLIGHTNING") and itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then
	    inst.ModeState = "LIGHTNING"

	    --Learn Spell
	    inst.components.aoespell:SetSpellFn(learnLightningSpell)
	    if inst.components.rechargeable:IsCharged() then
		inst.components.aoetargeting:SetEnabled(true)
	    end

	    --Update Mode Attack and FX
	    local owner = inst.components.inventoryitem:GetGrandOwner()
	    if owner ~= nil then
		owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_transfer", "swap_sdf_lightning_gauntlet_transfer")

		--Learn Static Attack
		inst.components.weapon:SetProjectile(itemSlot1.prefab)
		inst.components.weapon:SetRange(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_RANGE, TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_RANGE + 4)
		owner.components.combat:SetAttackPeriod(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_ATTACK_SPEED)

		--Add Gauntlet FX
		removeGauntletFX(inst)
		if inst.fires == nil then
		    inst.fires = {}

		    local fx = SpawnPrefab("sdf_lightning_gauntlet_lightning_fx")
		    fx.entity:SetParent(owner.entity)
		    fx.entity:AddFollower()
		    fx.Follower:FollowSymbol(owner.GUID, "swap_object", 40, 10, 0)

		    table.insert(inst.fires, fx)
		end

	    end

	    if not inst:HasTag("sdf_lightning_gauntlet_zap") then
		inst.SoundEmitter:PlaySound("WX_rework/module/insert")
	    end

	    inst:AddTag("sdf_lightning_gauntlet_zap")

	    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet_lightning"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet_lightning.xml"
	    return
	else
	    inst.ModeState = "PUNCH"

	    --Learn Spell
	    inst.components.aoespell:SetSpellFn(learnPunchSpell)
	    inst.components.aoetargeting:SetEnabled(false)

	    --Update Mode Attack and FX
	    local owner = inst.components.inventoryitem:GetGrandOwner()
	    if owner ~= nil then
		owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet", "swap_shield")

		--Remove Static Attack
		inst.components.weapon:SetProjectile(nil)
		inst.components.weapon:SetRange(0)
		owner.components.combat:SetAttackPeriod(TUNING.SDF_LIGHTNING_GAUNTLET_ATTACK_SPEED)

		if inst:HasTag("sdf_lightning_gauntlet_zap") then
		    inst:RemoveTag("sdf_lightning_gauntlet_zap")
		end
		if inst:HasTag("sdf_lightning_gauntlet_mend") then
		    inst:RemoveTag("sdf_lightning_gauntlet_mend")
		end

		--Remove Gauntlet FX
		removeGauntletFX(inst)
	    end
	    inst.SoundEmitter:PlaySound("WX_rework/module/remove")

	    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet.xml"

	    if itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then
	    end
	    return
	end
    end
end

local function modeStateGoodlightningToggle(inst)
    if inst.components.container ~= nil then
	local itemSlot2 = inst.components.container:GetItemInSlot(2)
	if (inst.ModeState == "PUNCH" or inst.ModeState == "LIGHTNING") and itemSlot2 ~= nil and itemSlot2.prefab == "sdf_goodlightning" then
	    inst.ModeState = "GOODLIGHTNING"

	    --Learn Spell
	    inst.components.aoespell:SetSpellFn(learnGoodlightningSpell)
	    if inst.components.rechargeable:IsCharged() then
		inst.components.aoetargeting:SetEnabled(true)
	    end

	    --Update Mode FX
	    local owner = inst.components.inventoryitem:GetGrandOwner()
	    if owner ~= nil then
		owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_transfer", "swap_sdf_lightning_gauntlet_transfer")

		--Learn Static Attack
		inst.components.weapon:SetProjectile(itemSlot2.prefab)
		inst.components.weapon:SetRange(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_RANGE, TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_RANGE + 4)
		owner.components.combat:SetAttackPeriod(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_ATTACK_SPEED)

		--Add Gauntlet FX
		removeGauntletFX(inst)
		if inst.fires == nil then
		    inst.fires = {}

		    local fx = SpawnPrefab("sdf_lightning_gauntlet_goodlightning_fx")
		    fx.entity:SetParent(owner.entity)
		    fx.entity:AddFollower()
		    fx.Follower:FollowSymbol(owner.GUID, "swap_object", 40, 10, 0)

		    table.insert(inst.fires, fx)
		end

	    end

	    if not inst:HasTag("sdf_lightning_gauntlet_zap") then
		inst.SoundEmitter:PlaySound("meta4/winbot/poweron")
	    end

	    inst:AddTag("sdf_lightning_gauntlet_mend")

	    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet_goodlightning"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet_goodlightning.xml"
	    return
	else
	    inst.ModeState = "PUNCH"

	    --Learn Spell
	    inst.components.aoespell:SetSpellFn(learnPunchSpell)
	    inst.components.aoetargeting:SetEnabled(false)

	    --Update Mode FX
	    local owner = inst.components.inventoryitem:GetGrandOwner()
	    if owner ~= nil then
		owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet", "swap_shield")

		--Remove Static Attack
		inst.components.weapon:SetProjectile(nil)
		inst.components.weapon:SetRange(0)
		owner.components.combat:SetAttackPeriod(TUNING.SDF_LIGHTNING_GAUNTLET_ATTACK_SPEED)

		--Remove Gauntlet FX
		removeGauntletFX(inst)
	    end

	    inst.SoundEmitter:PlaySound("WX_rework/module/remove")

	    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet.xml"
	    return
	end
    end
end

local function modeStateLightningDaringDashPst(inst)
    if inst.components.container ~= nil then
	local itemSlot1 = inst.components.container:GetItemInSlot(1)
	if inst.ModeState == "LIGHTNING" and itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then

	    --Update Mode Attack and FX
	    local owner = inst.components.inventoryitem:GetGrandOwner()
	    if owner ~= nil then
		owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_transfer", "swap_sdf_lightning_gauntlet_transfer")

		--Add Gauntlet FX
		if inst.fires == nil then
		    inst.fires = {}

		    local fx = SpawnPrefab("sdf_lightning_gauntlet_lightning_fx")
		    fx.entity:SetParent(owner.entity)
		    fx.entity:AddFollower()
		    fx.Follower:FollowSymbol(owner.GUID, "swap_object", 40, 10, 0)

		    table.insert(inst.fires, fx)
		end
	    end

	    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet_lightning"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet_lightning.xml"
	end
    end
end

local function modeStateGoodlightningDaringDashPst(inst)
    if inst.components.container ~= nil then
	local itemSlot2 = inst.components.container:GetItemInSlot(2)
	if inst.ModeState == "GOODLIGHTNING" and itemSlot2 ~= nil and itemSlot2.prefab == "sdf_goodlightning" then

	    --Update Mode FX
	    local owner = inst.components.inventoryitem:GetGrandOwner()
	    if owner ~= nil then
		owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet_transfer", "swap_sdf_lightning_gauntlet_transfer")

		--Add Gauntlet FX
		if inst.fires == nil then
		    inst.fires = {}

		    local fx = SpawnPrefab("sdf_lightning_gauntlet_goodlightning_fx")
		    fx.entity:SetParent(owner.entity)
		    fx.entity:AddFollower()
		    fx.Follower:FollowSymbol(owner.GUID, "swap_object", 40, 10, 0)

		    table.insert(inst.fires, fx)
		end
	    end

	    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet_goodlightning"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet_goodlightning.xml"
	end
    end
end

local function OnProjectileLaunched(inst, attacker, target)
    if inst.components.container ~= nil then
	local itemSlot1 = inst.components.container:GetItemInSlot(1)
	if (inst.ModeState == "LIGHTNING") and itemSlot1 ~= nil and itemSlot1.prefab == "sdf_lightning" then
	    itemSlot1.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_CONSUME)
	end
	local itemSlot2 = inst.components.container:GetItemInSlot(2)
	if (inst.ModeState == "GOODLIGHTNING") and itemSlot2 ~= nil and itemSlot2.prefab == "sdf_goodlightning" then
	    itemSlot2.components.finiteuses:Use(TUNING.SDF_LIGHTNING_GAUNTLET_STATIC_CONSUME)
	end
    end
end

local function AmmoLoaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	if inst.components.container:Has("sdf_lightning", 1) then
	    local lightningSlot = inst.components.container:GetItemInSlot(1)
	    if lightningSlot then
		lightningSlot:OnToggleFn()
	    end
	end
	if inst.components.container:Has("sdf_goodlightning", 1) then
	    local goodlightningSlot = inst.components.container:GetItemInSlot(2)
	    if goodlightningSlot then
		goodlightningSlot:OnToggleFn()
	    end
	end
    end
end

local function AmmoUnloaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	if inst.ModeState == "LIGHTNING" and inst.components.container:Has("sdf_lightning", 1) then
	    return
	elseif inst.ModeState == "GOODLIGHTNING" and inst.components.container:Has("sdf_goodlightning", 1) then
	    return
	elseif inst.ModeState ~= "PUNCH" then
	    inst.ModeState = "PUNCH"

	    --Learn Spell
	    inst.components.aoespell:SetSpellFn(learnPunchSpell)
	    inst.components.aoetargeting:SetEnabled(false)

	    --Remove Static Attack
	    inst.components.weapon:SetProjectile(nil)
	    inst.components.weapon:SetRange(0)
	    owner.components.combat:SetAttackPeriod(TUNING.SDF_LIGHTNING_GAUNTLET_ATTACK_SPEED)

	    --Update Mode FX
	    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet", "swap_shield")
	    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet.xml"

	    --Remove Gauntlet FX
	    removeGauntletFX(inst)

	    return
	end
    end
end

local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil then
	if data ~= nil and data.item ~= nil then

	    --Add lightning Anim and Attack Speed
	    AmmoLoaded(inst)

	    data.item:PushEvent("ammoloaded", {sdf_lightning_gauntlet = inst})
	end
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then

	--Remove lightning Anim and Attack Speed
	AmmoUnloaded(inst)

	if data ~= nil and data.prev_item ~= nil then
	    data.prev_item:PushEvent("ammounloaded", {sdf_lightning_gauntlet = inst})
	end
    end
end

local function onequip(inst, owner)
if inst:HasTag("sdf_lightning_gauntlet_zap") then
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Show("lantern_overlay")
	owner.AnimState:Hide("ARM_normal")
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:HideSymbol("swap_object")

	modeStateLightningDaringDashPst(inst)

elseif inst:HasTag("sdf_lightning_gauntlet_mend") then
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Show("lantern_overlay")
	owner.AnimState:Hide("ARM_normal")
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:HideSymbol("swap_object")

	modeStateGoodlightningDaringDashPst(inst)
else
    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet.xml"

    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet", "swap_shield")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Show("lantern_overlay")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:HideSymbol("swap_object")

    inst.components.weapon:SetProjectile(nil)
    inst.components.weapon:SetRange(0)
    owner.components.combat:SetAttackPeriod(TUNING.SDF_LIGHTNING_GAUNTLET_ATTACK_SPEED)

    --Add Transfer Ability
    owner:AddTag("sdf_lightning_gauntlet_transfer")

    --Open Capacitor
    local hasDragonPotion = false
    local armorItem = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if armorItem and armorItem.prefab == "sdf_dragon_potion" then hasDragonPotion = true end
    if not inst.components.container:IsOpen() and CAPACITOR_FIRST_OPEN == false and hasDragonPotion == false then
	inst:DoTaskInTime(0.1, function(inst) 
	    inst.components.container:Open(owner)
	    CAPACITOR_FIRST_OPEN = true
	end)
    end
end
end

local function onunequip(inst, owner)

    if inst.ModeState ~= "PUNCH" then
	inst.ModeState = "PUNCH"

	--Learn Spell
	inst.components.aoetargeting:SetEnabled(false)
	inst.components.aoespell:SetSpellFn(learnPunchSpell)

	--Update Mode FX
	owner.AnimState:OverrideSymbol("lantern_overlay", "swap_sdf_lightning_gauntlet", "swap_shield")
	inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet.xml"

	--Remove Gauntlet FX
	removeGauntletFX(inst)
    end
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:Hide("LANTERN_OVERLAY")
    owner.AnimState:ShowSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst.components.weapon:SetProjectile(nil)
    inst.components.weapon:SetRange(0)
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)

    --Remove Transfer Ability
    if owner:HasTag("sdf_lightning_gauntlet_transfer") then
	owner:RemoveTag("sdf_lightning_gauntlet_transfer")
    end

    --Close Capacitor
    if inst.components.container ~= nil then
	inst.components.container:Close(owner)
	CAPACITOR_FIRST_OPEN = false
    end
end

local function onload(inst, data)
    --Has ammo
    if inst.components.container:Has("sdf_lightning", 1) then
	local lightningSlot = inst.components.container:GetItemInSlot(1)
	if lightningSlot then
	    lightningSlot:OnToggleFn()
	end
    end
    if inst.components.container:Has("sdf_goodlightning", 1) then
	local goodlightningSlot = inst.components.container:GetItemInSlot(2)
	if goodlightningSlot then
	    goodlightningSlot:OnToggleFn()
	end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_lightning_gauntlet_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_lightning_gauntlet")
    inst.AnimState:SetBuild("sdf_lightning_gauntlet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("rangedweapon")
    inst:AddTag("weapon")
    inst:AddTag"allow_action_on_impassable"
    inst:AddTag("sdf_toolpunch")
    inst:AddTag("sdf_lightning_gauntlet")


    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = {1,.75,0,1}
    inst.components.aoetargeting.reticule.invalidcolour = {.5,0,0,1}
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting:SetAllowRiding(true)
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting:SetRange(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_RANGE)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:DoTaskInTime(0, function(inst)
	    local origReplicaOpen = inst.replica.container.Open
	    inst.replica.container.Open = function(self, doer)
		origReplicaOpen(self, doer)
		CapacitorWidgetHUDPositionFn(self, doer)
	    end
	end)
        return inst
    end

    inst.components.aoetargeting:SetEnabled(false)

    inst:AddComponent("aoespell")

    inst:AddComponent("sdf_reticule_spawner")
    inst.components.sdf_reticule_spawner:Setup(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_RETICULE_RADIUS)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_LIGHTNING_GAUNTLET_DAMAGE)
    inst.components.weapon:SetRange(0)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_LIGHTNING_GAUNTLET_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_LIGHTNING_GAUNTLET_DURABILITY)
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sdf_lightning_gauntlet")
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    local origOpen = inst.components.container.Open
    inst.components.container.Open = function(self, doer)
	origOpen(self, doer)
	CapacitorWidgetHUDPositionFn(self, doer)
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_lightning_gauntlet"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lightning_gauntlet.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_LIGHTNING_GAUNTLET_CHARGED_COOLDOWN)
    inst.components.rechargeable:SetOnDischargedFn(function(inst)
	inst.components.aoetargeting:SetEnabled(false)

	local myOwner = inst.components.inventoryitem:GetGrandOwner()
	if myOwner ~= nil and myOwner.prefab == "sdf" then
	    if myOwner:HasTag("sdf_lightning_gauntlet_transfer") then
		myOwner:RemoveTag("sdf_lightning_gauntlet_transfer")
	    end
	end
    end)
    inst.components.rechargeable:SetOnChargedFn(function(inst)
	if inst.ModeState == "LIGHTNING" or inst.ModeState == "GOODLIGHTNING" then
	    inst.components.aoetargeting:SetEnabled(true)
	end

	local myOwner = inst.components.inventoryitem:GetGrandOwner()
	if myOwner ~= nil and myOwner.prefab == "sdf" then
	    myOwner:AddTag("sdf_lightning_gauntlet_transfer")
	end
    end)

    MakeHauntableLaunch(inst)

    inst.ModeState = "PUNCH"
    inst.ModeStateLightningToggleFn = function() modeStateLightningToggle(inst) end
    inst.ModeStateGoodlightningToggleFn = function() modeStateGoodlightningToggle(inst) end

    inst.OnLoad = onload

    return inst
end

return  Prefab("common/inventory/sdf_lightning_gauntlet", fn, assets)