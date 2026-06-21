local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_hammer.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_hammer.tex"),

    Asset("ANIM", "anim/sdf_hammer.zip"),
    Asset("ANIM", "anim/swap_sdf_hammer.zip"),
    Asset("ANIM", "anim/sdf_hammer_sinkhole.zip"),
}

prefabs = {
}

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
end

local function GetPoints(pt)
    local points = {}
    local radius = 0.5
    for i = 1, 2 do
        local theta = 0     
        local circ = 2*PI*radius
        local numPoints = math.ceil(circ * 0.25)
        for p = 1, numPoints do
            if not points[i] then
                points[i] = {}
            end
            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local point = pt + offset
            table.insert(points[i], point)
            theta = theta - (2*PI/numPoints)
        end
        radius = radius + 1.0 --1.5
    end
    return points
end

local function onattacked(inst, owner, target)
    --Swingfx
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")

    --Groundfx
    if not owner:HasTag("sdf_shockwave_active") then
	if target ~= nil then
	    local aoeRing = SpawnPrefab("groundpoundring_fx")
	    aoeRing.Transform:SetPosition(target.Transform:GetWorldPosition())
	    aoeRing.Transform:SetScale(0.3,0.3,0.3) --0.6
	    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
	    local points = GetPoints(target:GetPosition())
	    for k,v in ipairs(points) do
		for j,x in ipairs(v) do
		    inst:DoTaskInTime(0.2 * (k-1), function()
			local aoeGroundPound = SpawnPrefab("groundpound_fx")
			aoeGroundPound.Transform:SetPosition(x:Get())
			aoeGroundPound.Transform:SetScale(0.3,0.3,0.3) --0.4
		    end)
		end
	    end
	end
    end
end

local function ReticuleTargetFn()
    for m=7,0,-.25 do Vector3().x,Vector3().y,Vector3().z = ThePlayer.entity:LocalToWorldSpace(m,0,0)
	if TheWorld.Map:IsPassableAtPoint(Vector3():Get()) and not TheWorld.Map:IsGroundTargetBlocked(Vector3()) then 
	    return Vector3()
	end
    end
    return Vector3()
end

local function smashSpell(inst,doer,pos)
    doer:PushEvent("combat_leap",{targetpos=pos,weapon=inst})
end

local function onPreLeap(inst, doer, startingpos, targetpos)
    doer:AddTag("sdf_shockwave_active")
end

local function onLeapt(inst, doer, startingpos, targetpos)

    --Add Boost Work
    if inst.components.tool then
	inst:RemoveComponent("tool")
    end
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.SDF_HAMMER_SHOCKWAVE_WORK_MINE)
    inst.components.tool:SetAction(ACTIONS.HAMMER, TUNING.SDF_HAMMER_SHOCKWAVE_WORK_HAMMER)

    --Animation
    --Crater
    local newSinkhole = SpawnPrefab("sdf_hammer_sinkhole")
    newSinkhole.Transform:SetPosition(inst.Transform:GetWorldPosition())
    newSinkhole:DoCollapseFn()

    --Rubble
    local aoeRing = SpawnPrefab("groundpoundring_fx")
    aoeRing.Transform:SetPosition(doer.Transform:GetWorldPosition())
    aoeRing.Transform:SetScale(0.6,0.6,0.6)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")

    --Find Workable Targets
    local leap_targets = TheSim:FindEntities(targetpos.x, 0, targetpos.z, inst.components.aoeweapon_leap.aoeradius + inst.components.aoeweapon_leap.physicspadding, nil, inst.components.aoeweapon_leap.notags, ("mine_workable" or "hammer_workable" or "treeseed"))
    for _, leap_target in ipairs(leap_targets) do
	if leap_target ~= doer and leap_target:IsValid() and not leap_target:IsInLimbo()
	and not (leap_target.components.health and leap_target.components.health:IsDead()) then
	    local targetrange = inst.components.aoeweapon_leap.aoeradius + leap_target:GetPhysicsRadius(0.5)
	    if leap_target:GetDistanceSqToPoint(targetpos) < targetrange * targetrange then

		--Check for Work
		local targetworkable = false
		if leap_target and leap_target.components.workable and leap_target.components.workable:CanBeWorked() then
		    if inst.components.tool.actions[leap_target.components.workable:GetWorkAction()] ~= nil or leap_target:HasTag("stump") then
			local work_action = leap_target.components.workable:GetWorkAction()
			if (work_action and leap_target:HasTag("NPC_workable")) or 
			    (leap_target.components.workable:CanBeWorked() and (work_action ~= ACTIONS.DIG or (leap_target.components.spawner == nil and leap_target.components.childspawner == nil))) then
			    targetworkable = true
			end
		    end
		end

		--Do Work
		if targetworkable then
		    leap_target.components.workable:WorkedBy(doer, inst.components.tool.actions[leap_target.components.workable:GetWorkAction()])

		    if leap_target:IsValid() and leap_target:HasTag("stump") then
			leap_target:Remove()
		    end
		end

		--Create Scrap from Asgard Golem Optimize Data
		if leap_target:HasTag("sdf_asgard_golem_optimize_data") then
		    local scrap = SpawnPrefab("wagpunk_bits")
		    scrap.Transform:SetPosition(leap_target.Transform:GetWorldPosition())
		    scrap.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_pst")
		    leap_target:Remove()
		end

		--Create Cracked Birchnut from Birchnut
		if leap_target.prefab == "acorn" then
		    local newCrackedBirchnut = SpawnPrefab("sdf_acorn_cracked")
		    newCrackedBirchnut.Transform:SetPosition(leap_target.Transform:GetWorldPosition())
		    --newCrackedBirchnut.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_pop_large")
		    leap_target:Remove()
		end
	    end
	end
    end

    --Remove tag
    if doer:HasTag("sdf_shockwave_active") then
	doer:RemoveTag("sdf_shockwave_active")
    end

    --Remove Boost Work
    if inst.components.tool then
	inst:RemoveComponent("tool")
    end
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.SDF_HAMMER_WORK_MINE)
    inst.components.tool:SetAction(ACTIONS.HAMMER, TUNING.SDF_HAMMER_WORK_HAMMER)

    --Consume Cost
    inst.components.finiteuses:Use(TUNING.SDF_HAMMER_SHOCKWAVE_CONSUME)

    --Cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_HAMMER_SHOCKWAVE_COOLDOWN)
end

local function onHitLeap(inst, doer, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil and not
	(target:HasTag("player") or target:HasTag("playerghost") or target:HasTag("INLIMBO")) then
	--Stun effect
	target.components.combat:BlankOutAttacks(TUNING.SDF_HAMMER_SHOCKWAVE_STUN_DEBUFF_DURATION)
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_hammer", "swap_sdf_hammer")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_HAMMER_ATTACK_SPEED)
    owner.components.combat:SetAreaDamage(TUNING.SDF_HAMMER_AOE_RADIUS, TUNING.SDF_HAMMER_AOE_DAMAGE_MULTI) --0.2
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    owner.components.combat.areahitrange = nil
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_hammer")
    inst.AnimState:SetBuild("sdf_hammer")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hammer")
    inst:AddTag("weapon")
    inst:AddTag("tool")
    --inst:AddTag("sdf_two_handed")
    inst:AddTag("aoeweapon_leap")


    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.validcolour = {1,.75,0,1}
    inst.components.aoetargeting.reticule.invalidcolour = {.5,0,0,1}
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting:SetRange(TUNING.SDF_HAMMER_SHOCKWAVE_RANGE)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(smashSpell)

    inst:AddComponent("aoeweapon_leap")
    inst.components.aoeweapon_leap:SetDamage(TUNING.SDF_HAMMER_DAMAGE * TUNING.SDF_HAMMER_SHOCKWAVE_DAMAGE_MULTI)
    inst.components.aoeweapon_leap:SetAOERadius(TUNING.SDF_HAMMER_SHOCKWAVE_AOE_RADIUS)
    inst.components.aoeweapon_leap:SetWorkActions()
    inst.components.aoeweapon_leap:SetOnPreLeapFn(onPreLeap)
    inst.components.aoeweapon_leap:SetOnLeaptFn(onLeapt)
    inst.components.aoeweapon_leap:SetOnHitFn(onHitLeap)

    inst:AddComponent("sdf_reticule_spawner")
    inst.components.sdf_reticule_spawner:Setup(TUNING.SDF_HAMMER_SHOCKWAVE_RETICULE_RADIUS)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_HAMMER_DAMAGE)
    inst.components.weapon.onattack = onattacked

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.SDF_HAMMER_WORK_MINE)
    inst.components.tool:SetAction(ACTIONS.HAMMER, TUNING.SDF_HAMMER_WORK_HAMMER)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_HAMMER_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_HAMMER_DURABILITY)
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, TUNING.SDF_HAMMER_WORK_CONSUME)
    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, TUNING.SDF_HAMMER_WORK_CONSUME)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_hammer"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_hammer.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_HAMMER_SHOCKWAVE_COOLDOWN)
    inst.components.rechargeable:SetOnDischargedFn(function(inst)
	inst.components.aoetargeting:SetEnabled(false)
    end)
    inst.components.rechargeable:SetOnChargedFn(function(inst)
	inst.components.aoetargeting:SetEnabled(true)
    end)

    return inst
end

require("stategraphs/commonstates")
local NUM_CRACKING_STAGES = 1
local COLLAPSE_STAGE_DURATION = 1
local OBJECT_SCALE = 0.8 --0.8
local NUM_FX = 7
local FX_THETA_DELTA = TWOPI / NUM_FX
local FX_RADIUS = 1.6

local function SpawnFx(inst, scale, pos)
    local theta = math.random() * PI * 2

    pos = pos or inst:GetPosition()

    --Spawn an fx at the middle of the sinkhole.
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(pos:Get())

    --Spawn an fx around the edges of the sinkhole circle.
    for i = 1, NUM_FX do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))

        dust.Transform:SetPosition(
            pos.x + math.cos(theta) * FX_RADIUS * (1 + math.random() * .1),
            0,
            pos.z - math.sin(theta) * FX_RADIUS * (1 + math.random() * .1)
        )

        local s = scale + math.random() * .2
        local x_scale = (i % 2 == 0 and -s) or s
        dust.Transform:SetScale(x_scale, s, s)

        theta = theta + FX_THETA_DELTA
    end

    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 2 })
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "repair" then
        if not inst:IsAsleep() then
	    SpawnFx(inst, inst.scale / 2)
        end

        inst.components.unevenground:Disable()
        inst.persists = false
        ErodeAway(inst)
    end
end

local function SnareAOE(inst)
    local debuffkey = inst.prefab
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3)
    for i, v in ipairs(ents) do
	if v ~= nil and v:IsValid() and v.components.locomotor ~= nil and not (v:HasTag("epic") 
	    or v:HasTag("player") or v:HasTag("playerghost") or v:HasTag("INLIMBO")) then
	    --slowing effect
	    if v._sdf_hammer_sinkhole_movespeed_debufftask ~= nil then
		v._sdf_hammer_sinkhole_movespeed_debufftask:Cancel()
	    end
	    v._sdf_hammer_sinkhole_movespeed_debufftask = v:DoTaskInTime(TUNING.SDF_HAMMER_SINKHOLE_MOVESPEED_DEBUFF_DURATION, function(i) i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_hammer_sinkhole_movespeed_debufftask = nil end)

	    v.components.locomotor:SetExternalSpeedMultiplier(v, debuffkey, TUNING.SDF_HAMMER_SINKHOLE_MOVESPEED_DEBUFF)
	end
    end
end

local function DoCollapse(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .03, .15, inst, inst.radius * 6)

    inst.components.unevenground:Enable()

    local pos = inst:GetPosition()
    SpawnFx(inst, inst.scale, pos)

    inst.components.timer:StartTimer("repair", TUNING.SDF_HAMMER_SINKHOLE_DURATION)
end

local function OnLoad(inst)--, data)
    if inst.components.timer:TimerExists("repair") then
        inst.components.unevenground:Enable()
    end
end

local function OnLoadPostPass(inst)--, newents, data)
    if inst.persists and not inst.components.timer:TimerExists("repair") then
	--backup, in case sinkholes got spawned and never started collapsing
	inst:Remove()
    end
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sdf_hammer_sinkhole")
    inst.AnimState:SetBuild("sdf_hammer_sinkhole")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.AnimState:SetScale(OBJECT_SCALE, OBJECT_SCALE)

    inst.Transform:SetEightFaced()

    inst:AddTag("antlion_sinkhole")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NOCLICK")

    inst:SetDeployExtraSpacing(4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst.radius = TUNING.SDF_HAMMER_SINKHOLE_RADIUS
    inst.scale = OBJECT_SCALE
    inst.maxwork = false

    inst:AddComponent("aura")
    inst.components.aura.pretickfn = SnareAOE
    inst.components.aura.radius = TUNING.SDF_HAMMER_SINKHOLE_RADIUS + 1
    inst.components.aura.tickperiod = TUNING.SDF_HAMMER_SINKHOLE_TICK
    inst.components.aura:Enable(true)

    inst:AddComponent("timer")

    inst:AddComponent("unevenground")
    inst.components.unevenground.radius = TUNING.SDF_HAMMER_SINKHOLE_RADIUS

    inst.DoCollapseFn = function() DoCollapse(inst) end

    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("common/inventory/sdf_hammer", fn, assets),
	Prefab("sdf_hammer_sinkhole", fn2, assets)