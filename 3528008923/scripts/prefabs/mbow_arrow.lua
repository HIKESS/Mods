local assets =
{
    Asset("ANIM", "anim/mbow_arrow.zip"),
    Asset("ANIM", "anim/mbow_arrow2.zip"),
	
	Asset("ATLAS", "images/inventoryimages/mbow_arrow.xml"),
    Asset("IMAGE", "images/inventoryimages/mbow_arrow.tex"),
	
	Asset("ATLAS", "images/inventoryimages/mbow_arrow2.xml"),
    Asset("IMAGE", "images/inventoryimages/mbow_arrow2.tex"),
}

local WEIGHTED_TAIL_FXS =
{
    ["tail_5_8"] = 1,
    ["tail_5_9"] = .5,
}

local LAUNCH_OFFSET_Y = 0.75

local function Projectile_CreateTailFx(inst)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation(weighted_random_choice(WEIGHTED_TAIL_FXS))
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

    inst.AnimState:SetLightOverride(0.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetAddColour(1, 1, 1, 0)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function Projectile_UpdateTail(inst)
    local c = (not inst.entity:IsVisible() and 0) or 1
    local target = inst._target:value()

    -- Does not spawn the tail if it is close to the target (visual bug).
    if c > 0 and not (target ~= nil and target:IsValid() and inst:IsNear(target, 1.5)) then
        local tail = inst:CreateTailFx()
        tail.Transform:SetPosition(inst.Transform:GetWorldPosition())
        tail.Transform:SetRotation(inst.Transform:GetRotation())
        if c < 1 then
            tail.AnimState:SetTime(c * tail.AnimState:GetCurrentAnimationLength())
        end

        return tail -- Mods.
    end
end

local function Projectile_SpawnImpactFx(inst, attacker, target)
    if target ~= nil and attacker ~= nil and target:IsValid() and attacker:IsValid() then
        local impactfx = SpawnPrefab("hitsparks_piercing_fx")
        impactfx:Setup(attacker, target, inst, nil, true, LAUNCH_OFFSET_Y)

        return impactfx -- Mods.
    end
end

-- NOTE(DiogoW): Using OnPreHit to be able to check health:IsDead().
local function Projectile_OnPreHitfx(inst, attacker, target)
    if  target ~= nil      and
        target:IsValid()   and
        attacker ~= nil    and
        attacker:IsValid() and
        (target.components.health == nil or not target.components.health:IsDead())
    then
        inst:SpawnImpactFx(attacker, target)
    end
end

----------------------------------------------------------------------------------------------------------------------------

local AOE_TARGET_MUST_TAGS     = { "_combat", "_health" }
local AOE_TARGET_CANT_TAGS     = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "companion", "player", "wall" }
local AOE_TARGET_CANT_TAGS_PVP = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }

local function OnMiss(inst, owner, target)
	
	inst:Remove()
end

local function no_aggro(attacker, target)
	local targets_target = target.components.combat ~= nil and target.components.combat.target or nil
	return targets_target ~= nil and targets_target:IsValid() and targets_target ~= attacker and attacker ~= nil and attacker:IsValid()
			and (GetTime() - target.components.combat.lastwasattackedbytargettime) < 4
			and (targets_target.components.health ~= nil and not targets_target.components.health:IsDead())
end

local function ImpactFx(inst, attacker, target)
    if target ~= nil and target:IsValid() then
		local impactfx = SpawnPrefab("slingshotammo_hitfx_rock")
		impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function OnAttack(inst, attacker, target)
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
		ImpactFx(inst, attacker, target)
	end
end

local function OnPreHit(inst, attacker, target)	
    if target ~= nil and target:IsValid() and target.components.combat ~= nil and no_aggro(attacker, target) then
        target.components.combat:SetShouldAvoidAggro(attacker)
	end
	
	Projectile_OnPreHitfx(inst, attacker, target)
end

local function OnHit(inst, attacker, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
		target.components.combat:RemoveShouldAvoidAggro(attacker)
	end
	
	if target ~= nil and target:IsValid() then        
		if math.random() < .6 then   
			local x,y,z = target.Transform:GetWorldPosition()
			local arrow
			if inst:HasTag("blackarrow") then
				arrow = SpawnPrefab("mbow_arrow")
			else
				arrow = SpawnPrefab("mbow_arrow2")
			end
			arrow.Transform:SetPosition(x,y,z)
			LaunchAt(arrow, target, attacker or inst, 1, 2)
		end
	end
	
    inst:Remove()
	
end

local function OnUpdateSkillshot(inst)
	--can go invalid from projectile onupdate. (doesn't get immediately cancelled onremove like tasks do.)
	if not (inst.components.projectile.owner and inst:IsValid()) then
        return
    end

    local attacker = inst._attacker

    if not (attacker ~= nil and attacker.components.combat ~= nil and attacker:IsValid()) then
        return
    end

	local x, y, z = inst.Transform:GetWorldPosition()

    for i, v in ipairs(TheSim:FindEntities(x, 0, z, 4, AOE_TARGET_MUST_TAGS, TheNet:GetPVPEnabled() and AOE_TARGET_CANT_TAGS_PVP or AOE_TARGET_CANT_TAGS)) do
        local range = v:GetPhysicsRadius(.5) + inst.components.projectile.hitdist

        if v:GetDistanceSqToPoint(x, y, z) < range * range and
            attacker.components.combat:CanTarget(v) and
            v.components.combat:CanBeAttacked(attacker) and
            not attacker.components.combat:IsAlly(v)
        then
            inst.components.projectile:Hit(v)

            break
        end
    end
end

local function OnThrown(inst, owner, target, attacker)
    
	inst._target:set(target)
	
    if not target:HasTag("CLASSIFIED") then
        return -- Not a fake target.
    end

    inst._attacker = attacker
    inst.components.projectile:SetHitDist(.7)
	inst.components.updatelooper:AddOnWallUpdateFn(OnUpdateSkillshot)
end

local function SetChargedMultiplier(inst, mult)
	local damagemult = 1 + (TUNING.SLINGSHOT_MAX_CHARGE_DAMAGE_MULT - 1) * mult
	local speedmult = 1 + (TUNING.SLINGSHOT_MAX_CHARGE_SPEED_MULT - 1) * mult

	local dmg = inst.components.weapon.damage
	if dmg and dmg > 0 then
		inst.components.weapon:SetDamage(dmg * damagemult)
	end
	if inst.components.planardamage then
		inst.components.planardamage:AddMultiplier(inst, damagemult, "chargedattack")
	end

	inst.components.projectile:SetSpeed(inst.components.projectile.speed * speedmult)

end


local function projectile_fn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.Light:SetFalloff(0.6)
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(0.4)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(false)

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("blow_dart")
    inst.AnimState:SetBuild("blow_dart")
    inst.AnimState:PlayAnimation("dart_houndstooth", true)
	
	inst.AnimState:SetMultColour(0.3, 0.3, 0.3, 0.8)

    inst.AnimState:SetLightOverride(0.2)

    inst.AnimState:SetSymbolBloom("flametail")
    inst.AnimState:SetSymbolLightOverride("flametail", 0.5)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	
	inst:AddTag("weapon")
    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

	inst:AddComponent("updatelooper")

    if not TheNet:IsDedicated() then
        inst.CreateTailFx  = Projectile_CreateTailFx
        inst.UpdateTail    = Projectile_UpdateTail

        inst:DoPeriodicTask(0, inst.UpdateTail)
    end

    inst._target = net_entity(inst.GUID, "houndstooth_proj._target")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SpawnImpactFx = Projectile_SpawnImpactFx

	inst.SetChargedMultiplier = SetChargedMultiplier	
    inst.persists = false

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(50)
	--inst.components.weapon:SetOnAttack(OnAttack)
		
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(42)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnPreHitFn(OnPreHit)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile:SetLaunchOffset(Vector3(2.5, LAUNCH_OFFSET_Y, 2.5))
    inst.components.projectile.range = 30
	inst.components.projectile.has_damage_set = true

    return inst
end

-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mbow_arrow")
    inst.AnimState:SetBuild("mbow_arrow")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("hamayumi_arrow")
    inst:AddTag("reloaditem_ammo") -- Action string.

    inst.pickupsound = "wood"
	
    MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
	inst:AddTag("selfstacker")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("reloaditem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
	
	local selfstacker = inst:AddComponent("selfstacker")
    selfstacker:SetIgnoreMovingFast(true)
	
	inst.components.inventoryitem.imagename = "mbow_arrow"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mbow_arrow.xml"
	
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)		
	MakeSmallPropagator(inst)
	
    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mbow_arrow2")
    inst.AnimState:SetBuild("mbow_arrow2")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("hamayumi_arrow")
    inst:AddTag("reloaditem_ammo") -- Action string.

    inst.pickupsound = "wood"
	
    MakeInventoryFloatable(inst)
	inst.components.floater:SetSize("small")
    inst.components.floater:SetVerticalOffset(0.1)
	
	inst:AddTag("selfstacker")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("reloaditem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
	
	local selfstacker = inst:AddComponent("selfstacker")
    selfstacker:SetIgnoreMovingFast(true)
	
	inst.components.inventoryitem.imagename = "mbow_arrow2"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mbow_arrow2.xml"
	
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)		
	MakeSmallPropagator(inst)
	
    return inst
end

return Prefab("mbow_arrow", fn, assets),
		Prefab("mbow_arrow2", fn2, assets),
		Prefab("marrow_proj", projectile_fn, assets)