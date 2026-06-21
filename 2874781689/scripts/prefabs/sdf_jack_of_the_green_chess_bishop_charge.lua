local assets=
{
    Asset("ANIM", "anim/sdf_jack_of_the_green_chess_bishop_charge.zip"),
}

prefabs = {
}

local function OnHit(inst, owner, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx then
	local follower = impactfx.entity:AddFollower()
	follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	impactfx:FacePoint(inst.Transform:GetWorldPosition())

	--electrocute fx
	local shockFX = SpawnPrefab("sdf_lightning_shock_fx")

	if shockFX then
	    shockFX.Transform:SetPosition(target.Transform:GetWorldPosition())
	end
        if target:HasTag("player") and not target.sg:HasStateTag("dead") then
	    target.sg:GoToState("electrocute")
	end

	--debuff effect
	local debuffkey = inst.prefab
	if target ~= nil and target:IsValid() and target.components.locomotor ~= nil then
	    --slowing effect
	    if target._sdf_jack_of_the_green_chess_bishop_charge_movespeed_debufftask ~= nil then
		target._sdf_jack_of_the_green_chess_bishop_charge_movespeed_debufftask:Cancel()
	    end
	    target._sdf_jack_of_the_green_chess_bishop_charge_movespeed_debufftask = target:DoTaskInTime(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_PROJECTILE_MOVESPEED_DEBUFF_DURATION, function(i) i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._sdf_jack_of_the_green_chess_bishop_charge_movespeed_debufftask = nil end)

	    target.components.locomotor:SetExternalSpeedMultiplier(target, debuffkey, TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_PROJECTILE_MOVESPEED_DEBUFF)
	end
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("sdf_jack_of_the_green_chess_bishop_charge")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_chess_bishop_charge")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    inst:AddTag("weapon")
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_ATTACK_DAMAGE)
    inst.components.weapon:SetElectric()

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.SDF_JACK_OF_THE_GREEN_CHESS_BISHOP_PROJECTILE_SPEED)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(0.3)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile.has_damage_set = true

    inst.persists = false
    inst:DoTaskInTime(1.5, inst.Remove)

    return inst
end

return  Prefab("sdf_jack_of_the_green_chess_bishop_charge", fn, assets)