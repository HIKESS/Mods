local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_club.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_club.tex"),

    Asset("ANIM", "anim/sdf_club.zip"),
    Asset("ANIM", "anim/swap_sdf_club.zip"),
}

prefabs = {
}

local function onpocket(inst, owner)
    if inst.components.burnable:IsBurning() then
	inst.components.burnable:Extinguish()
    end
end

local function setFireAction(inst, target, doer)
    if target ~= nil and
	target.components.burnable and target.components.fueled and target:HasTag("campfire") then
	if not target.components.burnable:IsBurning() then

	    --Fully fuels Riddle Firepit
	    if target.prefab == "sdf_jack_of_the_green_riddle_firepit" then
		local fuel = SpawnPrefab("cutgrass")
		if fuel then
		    fuel.components.fuel.fuelvalue = TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_FIREPIT_FUEL_MAX
		    target.components.fueled:TakeFuelItem(fuel)
		end
		--target.components.burnable:Ignite(true)

		--Deal damage to club
		inst.components.finiteuses:Use(TUNING.SDF_CLUB_ENFLAME_IGNITE_CONSUME)
	    else
		target.components.burnable:Ignite(true)
		target.components.fueled:DoDelta(TUNING.SDF_CLUB_ENFLAME_FUEL, doer)

		--Deal damage to club
		inst.components.finiteuses:Use(TUNING.SDF_CLUB_ENFLAME_IGNITE_CONSUME)
	    end
	end
    end

end

local function setFire(inst, target, owner)
    if target then
	if target.components.burnable and not target.components.burnable:IsBurning() then
	    if target.components.freezable and target.components.freezable:IsFrozen() then
		target.components.freezable:Unfreeze()
	    else
		target.components.burnable:Ignite(true)
	    end

	    if target.components.freezable then
		target.components.freezable:AddColdness(-1) --Does this break ice staff?
		if target.components.freezable:IsFrozen() then
		    target.components.freezable:Unfreeze()
		end
	    end

	    if target.components.sleeper and target.components.sleeper:IsAsleep() then
		target.components.sleeper:WakeUp()
	    end

	    if target.components.combat then
		target.components.combat:SuggestTarget(owner)
	    end
	    target:PushEvent("attacked", {attacker = owner, damage = 0})

	    --Deal damage to club
	    inst.components.finiteuses:Use(TUNING.SDF_CLUB_ENFLAME_COMBAT_CONSUME)
	end
    end
end

local function RemoveEnflame(inst, owner)

    if inst.components.tool then
	inst:RemoveComponent("tool")
    end
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.SDF_CLUB_WORK_MINE)
    inst.components.tool:SetAction(ACTIONS.HAMMER, TUNING.SDF_CLUB_WORK_HAMMER)

    inst:RemoveTag("waterproofer")
    if inst.components.waterproofer then
	inst:RemoveComponent("waterproofer")
    end

    inst:RemoveTag("lighter")
    if inst.components.lighter then
	inst:RemoveComponent("lighter")
    end

    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
        owner.SoundEmitter:PlaySound("dontstarve/common/fireOut")
    end

    if inst.components.burnable:IsBurning() then
	inst.components.burnable:Extinguish()
    end
end

local function AddEnflame(inst, owner)

    if inst.components.tool then
	inst:RemoveComponent("tool")
    end
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.SDF_CLUB_WORK_MINE)

    inst:AddTag("waterproofer")
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.SDF_CLUB_WET_RESIST)

    inst:AddTag("lighter")
    inst:AddComponent("lighter")

    owner.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")

    inst.components.burnable:Ignite()
    if inst.fires == nil then
	inst.fires = {}

	local fx = SpawnPrefab("torchfire")
	fx.entity:SetParent(owner.entity)
	fx.entity:AddFollower()
	fx.Follower:FollowSymbol(owner.GUID, "swap_object", 10, -200, 0)
	fx:AttachLightTo(owner)

	table.insert(inst.fires, fx)
    end

    --Deal damage to club
    inst.components.finiteuses:Use(TUNING.SDF_CLUB_ENFLAME_IGNITE_CONSUME)

    --Apply Cooldown
    inst.components.rechargeable:Discharge(TUNING.SDF_CLUB_ENFLAME_DURATION)
end

local function SpellFn(inst, doer, pos)
    doer:PushEvent("combat_lunge",{targetpos = pos,weapon = inst})
end

local function OnPreLunge(inst, doer, startingpos, targetpos)
    doer:AddTag("sdf_lunge_active")
end

local function OnLunged(inst, doer, startingpos, targetpos)

    if not startingpos or not targetpos or not doer or not doer.components.combat then
        return false
    end

    -- Hitting -----------------------------------------------------------------
    local doer_combat = doer.components.combat
    doer_combat:EnableAreaDamage(false)

    local p1 = { x = startingpos.x, y = startingpos.z }
    local p2 = { x = targetpos.x, y = targetpos.z }
    local dx, dy = p2.x - p1.x, p2.y - p1.y
    local dist = dx * dx + dy * dy
    local toskip = {}
    local pv = {}
    local r, cx, cy
    if dist > 0 then
        dist = math.sqrt(dist)
        r = (dist + doer_combat.hitrange * 0.5 + inst.components.aoeweapon_lunge.physicspadding) * 0.5
        dx, dy = dx / dist, dy / dist
        cx, cy = p1.x + dx * r, p1.y + dy * r

        doer_combat.ignorehitrange = true

        local c_hit_targets = TheSim:FindEntities(cx, 0, cy, r, nil, inst.components.aoeweapon_lunge.notags, {})
        for _, hit_target in ipairs(c_hit_targets) do
            toskip[hit_target] = true
            if hit_target ~= doer and hit_target:IsValid() and not hit_target:IsInLimbo() and
		(hit_target.components.burnable and hit_target.components.burnable:IsBurning()) then
                pv.x, pv._, pv.y = hit_target.Transform:GetWorldPosition()
                local vrange = inst.components.aoeweapon_lunge.siderange + hit_target:GetPhysicsRadius(0.5)
                if DistPointToSegmentXYSq(pv, p1, p2) < vrange * vrange then

		    --Enflame ON
		    AddEnflame(inst, doer)
                end
            elseif hit_target ~= doer and hit_target:IsValid() and not hit_target:IsInLimbo() and
		(hit_target.components.burnable and not hit_target.components.burnable:IsBurning()) then
                pv.x, pv._, pv.y = hit_target.Transform:GetWorldPosition()
                local vrange = inst.components.aoeweapon_lunge.siderange + hit_target:GetPhysicsRadius(0.5)
                if DistPointToSegmentXYSq(pv, p1, p2) < vrange * vrange then

		    --lite on Fire
		    if inst.components.burnable:IsBurning() then
			if hit_target.components.fueled and hit_target:HasTag("campfire") then
			    setFireAction(inst, hit_target, doer)
			else
			    setFire(inst, hit_target, doer)
			end
		    end
		end
	    end
        end

        doer_combat.ignorehitrange = false
    end

    local angle = (doer.Transform:GetRotation() + 90) * DEGREES
    local p3 = { x = p2.x + doer_combat.hitrange * math.sin(angle), y = p2.y + doer_combat.hitrange * math.cos(angle) }
    local p2_hit_targets = TheSim:FindEntities(p2.x, 0, p2.y, doer_combat.hitrange + inst.components.aoeweapon_lunge.physicspadding, nil, inst.components.aoeweapon_lunge.notags, {})
    for _, hit_target in ipairs(p2_hit_targets) do
        if not toskip[hit_target] and hit_target ~= doer and hit_target:IsValid() and not hit_target:IsInLimbo() and
	    (hit_target.components.burnable and hit_target.components.burnable:IsBurning()) then
            pv.x, pv._, pv.y = hit_target.Transform:GetWorldPosition()
            local vradius = hit_target:GetPhysicsRadius(0.5)
            local vrange = doer_combat.hitrange + vradius
            if distsq(pv.x, pv.y, p2.x, p2.y) < vrange * vrange then
                vrange = inst.components.aoeweapon_lunge.siderange + vradius
                if DistPointToSegmentXYSq(pv, p2, p3) < vrange * vrange then

		    --Enflame ON
		    AddEnflame(inst, doer)
                end
            end
        elseif not toskip[hit_target] and hit_target ~= doer and hit_target:IsValid() and not hit_target:IsInLimbo() and
	    (hit_target.components.burnable and not hit_target.components.burnable:IsBurning()) then
            pv.x, pv._, pv.y = hit_target.Transform:GetWorldPosition()
            local vradius = hit_target:GetPhysicsRadius(0.5)
            local vrange = doer_combat.hitrange + vradius
            if distsq(pv.x, pv.y, p2.x, p2.y) < vrange * vrange then
                vrange = inst.components.aoeweapon_lunge.siderange + vradius
                if DistPointToSegmentXYSq(pv, p2, p3) < vrange * vrange then

		    --lite on Fire
		    if inst.components.burnable:IsBurning() then
			if hit_target.components.fueled and hit_target:HasTag("campfire") then
			    setFireAction(inst, hit_target, doer)
			else
			    setFire(inst, hit_target, doer)
			end
		    end
                end
            end

	end
    end
    doer_combat:EnableAreaDamage(true)

    --Remove tag
    if doer:HasTag("sdf_lunge_active") then
	doer:RemoveTag("sdf_lunge_active")
    end
end

local function OnCharged(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
	RemoveEnflame(inst, owner)
    end

    --inst.components.aoetargeting:SetEnabled(true)
end

local function OnDischarged(inst)
    --inst.components.aoetargeting:SetEnabled(false)
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
    inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/groundpound")

    --Groundfx
    if not owner:HasTag("sdf_lunge_active") then
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
    return Vector3(ThePlayer.entity:LocalToWorldSpace(TUNING.SDF_CLUB_ENFLAME_RANGE, 0, 0))
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
        l = TUNING.SDF_CLUB_ENFLAME_RANGE / math.sqrt(l)
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

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_club", "swap_sdf_club")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.SDF_CLUB_ATTACK_SPEED)
    owner.components.combat:SetAreaDamage(TUNING.SDF_CLUB_AOE_RADIUS, TUNING.SDF_CLUB_AOE_DAMAGE) --0.2
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    owner.components.combat.areahitrange = nil

    --Enflame remove cooldown
    if not inst.components.rechargeable:IsCharged() then
	--remove Cooldown
	inst.components.rechargeable:SetPercent(1)
    else
	--remove Enflame
	RemoveEnflame(inst, owner)
    end
end

local function onload(inst, data, newents)
    inst.components.rechargeable:SetPercent(1)
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_club")
    inst.AnimState:SetBuild("sdf_club")
    inst.AnimState:PlayAnimation("idle")


    inst:AddTag("hammer")
    inst:AddTag("weapon")
    inst:AddTag("tool")
    inst:AddTag("sdf_club")
    inst:AddTag("wildfireprotected")

    MakeInventoryFloatable(inst, "med", 0.25)

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleline"
    inst.components.aoetargeting.reticule.pingprefab="reticulelineping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetAllowRiding(false)
    inst.components.aoetargeting:SetRange(TUNING.SDF_CLUB_ENFLAME_RANGE)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("aoeweapon_lunge")
    inst.components.aoeweapon_lunge:SetDamage(0)
    inst.components.aoeweapon_lunge:SetSideRange(TUNING.SDF_CLUB_ENFLAME_RETICULE_SIDE_RANGE)
    inst.components.aoeweapon_lunge:SetWorkActions()
    inst.components.aoeweapon_lunge:SetOnPreLungeFn(OnPreLunge)
    inst.components.aoeweapon_lunge:SetOnLungedFn(OnLunged)
    inst.components.aoeweapon_lunge.OnHit = function(self, doer, target) end

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(SpellFn)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_CLUB_DAMAGE)
    inst.components.weapon.onattack = onattacked

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, TUNING.SDF_CLUB_WORK_MINE)
    inst.components.tool:SetAction(ACTIONS.HAMMER, TUNING.SDF_CLUB_WORK_HAMMER)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_CLUB_DURABILITY)
    inst.components.finiteuses:SetUses(TUNING.SDF_CLUB_DURABILITY)
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, TUNING.SDF_CLUB_WORK_CONSUME)
    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, TUNING.SDF_CLUB_WORK_CONSUME)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_club"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_club.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket(onpocket)
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload

    return inst
end

return  Prefab("common/inventory/sdf_club", fn, assets)