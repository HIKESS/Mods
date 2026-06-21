local assets =
{
    Asset("ANIM", "anim/sdf_shadow_demonette.zip"),
}

local prefabs =
{

}

local brain = require("brains/sdf_shadow_demonettebrain")

SetSharedLootTable("sdf_shadow_demonette_loot",
{
	{ "horrorfuel",		1.00 },
	{ "horrorfuel",		0.33 },
	{ "nightmarefuel",	1.00 },
	{ "nightmarefuel",	0.67 },
})

local SHADOW_DEMONETTE_AGGRO_RANGE = 12
local SHADOW_DEMONETTE_DEAGGRO_RANGE = 40

local function RetargetFn(inst)
    if inst.sg:HasStateTag("appearing") or inst.sg:HasStateTag("invisible") then
	return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local target = inst.components.combat.target
    if target ~= nil then
	local range = TUNING.SDF_SHADOW_DEMONETTE_ATTACK_RANGE + target:GetPhysicsRadius(0)
	if target:HasTag("player") and target:GetDistanceSqToPoint(x, y, z) < range * range then
	    --Keep target
	    return
	end
    end

    --V2C: WARNING: FindClosestPlayerInRange returns 2 values, which
    --              we don't want to return as our 2nd return value.  
    local player--[[, rangesq]] = FindClosestPlayerInRange(x, y, z, SHADOW_DEMONETTE_AGGRO_RANGE, true)
    return player
end

local function KeepTargetFn(inst, target)
    if not inst.components.combat:CanTarget(target) then
	return false
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local rangesq = SHADOW_DEMONETTE_DEAGGRO_RANGE * SHADOW_DEMONETTE_DEAGGRO_RANGE
    if target:GetDistanceSqToPoint(x, y, z) < rangesq then
	return true
    end

    if inst.prefab == "sdf_shadow_demonette_penumbra" then
	local umbra = inst.components.entitytracker:GetEntity("sdf_shadow_demonette_umbra")
	if umbra ~= nil and umbra:GetDistanceSqToPoint(x, y, z) < rangesq then
	    return true
	end
    elseif inst.prefab == "sdf_shadow_demonette_umbra" then
	local penumbra = inst.components.entitytracker:GetEntity("sdf_shadow_demonette_penumbra")
	if penumbra ~= nil and penumbra:GetDistanceSqToPoint(x, y, z) < rangesq then
	    return true
	end
    end

    return false
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
	local target = inst.components.combat.target
	if not (target ~= nil and target:HasTag("player") and inst:IsNear(target, TUNING.SDF_SHADOW_DEMONETTE_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
	    inst.components.combat:SetTarget(data.attacker)
	end
    end
end

local function OnNewCombatTarget(inst, data)
    if data ~= nil and data.oldtarget == nil then

	if inst.prefab == "sdf_shadow_demonette_penumbra" then
	    local umbra = inst.components.entitytracker:GetEntity("sdf_shadow_demonette_umbra")
	    if umbra ~= nil and umbra.components.combat ~= nil then
		umbra.components.combat:SuggestTarget(data.target)
	    end
	elseif inst.prefab == "sdf_shadow_demonette_umbra" then
	    local penumbra = inst.components.entitytracker:GetEntity("sdf_shadow_demonette_penumbra")
	    if penumbra ~= nil and penumbra.components.combat ~= nil then
		penumbra.components.combat:SuggestTarget(data.target)
	    end
	end

    end
end

local function OnLoadPostPass(inst)
    if inst.sg.mem.lastattack == nil then
	local team = { inst }

	if inst.prefab == "sdf_shadow_demonette_penumbra" then
	    local umbra = inst.components.entitytracker:GetEntity("sdf_shadow_demonette_umbra")
	    if umbra ~= nil and umbra.sg ~= nil then
		table.insert(team, umbra)
	    end
	elseif inst.prefab == "sdf_shadow_demonette_umbra" then
	    local penumbra = inst.components.entitytracker:GetEntity("sdf_shadow_demonette_penumbra")
	    if penumbra ~= nil and penumbra.sg ~= nil then
		table.insert(team, penumbra)
	    end
	end

	local t = GetTime()
	for i = 1, #team do
	    local v = table.remove(team, math.random(#team))
	    v.sg.mem.lastattack = t - i
	end
    end
end
--------------------------------------------------------------------------

local function CreateFlameFx()
    local inst = CreateEntity()

    inst:AddTag("FX")

    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
	inst.entity:SetCanSleep(false)
    end

    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("sdf_shadow_demonette")
    inst.AnimState:SetBuild("sdf_shadow_demonette")
    inst.AnimState:PlayAnimation("fx_flame", true)
    inst.AnimState:SetSymbolLightOverride("fx_flame_red", 1)
    inst.AnimState:SetSymbolLightOverride("fx_red", 1)
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()))

    return inst
end

local function CreateFabricFx()
    local inst = CreateEntity()

    inst:AddTag("FX")

    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
	inst.entity:SetCanSleep(false)
    end

    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("sdf_shadow_demonette")
    inst.AnimState:SetBuild("sdf_shadow_demonette")
    inst.AnimState:PlayAnimation("fx_fabric", true)
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()))

    return inst
end

local function CreateCapeFx()
    local inst = CreateEntity()

    inst:AddTag("FX")

    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
	inst.entity:SetCanSleep(false)
    end

    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("sdf_shadow_demonette")
    inst.AnimState:SetBuild("sdf_shadow_demonette")
    inst.AnimState:PlayAnimation("fx_cape_front", true)
    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()))

    return inst
end

local function OnColourChanged(inst, r, g, b, a)
    for i, v in ipairs(inst.highlightchildren) do
	v.AnimState:SetAddColour(r, g, b, a)
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.5)
    MakeGhostPhysics(inst, 25, inst.physicsradiusoverride)
    inst.DynamicShadow:SetSize(1.7, .9)
    inst.Transform:SetFourFaced()

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")
    inst:AddTag("shadow_aligned")
    inst:AddTag("sdf_shadow_demonette")

    inst.AnimState:SetBank("sdf_shadow_demonette")
    inst.AnimState:SetBuild("sdf_shadow_demonette")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetSymbolLightOverride("fx_red", 1)
    inst.AnimState:SetSymbolLightOverride("fx_red_particle", 1)
    inst.AnimState:SetSymbolLightOverride("wingend_red", 1)

    inst:AddComponent("colouraddersync")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
	local flames = CreateFlameFx()
	flames.entity:SetParent(inst.entity)
	flames.Follower:FollowSymbol(inst.GUID, "fx_flame_swap", nil, nil, nil, true)

	local fabric = CreateFabricFx()
	fabric.entity:SetParent(inst.entity)
	fabric.Follower:FollowSymbol(inst.GUID, "fx_fabric_swap", nil, nil, nil, true)

	local cape = CreateCapeFx()
	cape.entity:SetParent(inst.entity)
	cape.Follower:FollowSymbol(inst.GUID, "cape_front_swap", nil, nil, nil, true)

	inst.highlightchildren = { flames, fabric, cape }

	inst.components.colouraddersync:SetColourChangedFn(OnColourChanged)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("inspectable")

    --inst:AddComponent("sanityaura")
    --inst.components.sanityaura.aura = -TUNING.SDF_SHADOW_DEMONETTE_SANITY_AURA

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.SDF_SHADOW_DEMONETTE_WALKSPEED

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_SHADOW_DEMONETTE_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_SHADOW_DEMONETTE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_SHADOW_DEMONETTE_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SDF_SHADOW_DEMONETTE_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.forcefacing = false
    inst.components.combat.hiteffectsymbol = "shad"
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)

    inst:AddComponent("planarentity")
    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_SHADOW_DEMONETTE_PLANAR_DAMAGE)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("sdf_shadow_demonette_loot")
    inst.components.lootdropper.y_speed = 4
    inst.components.lootdropper.y_speed_variance = 3
    inst.components.lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("colouradder")
    inst:AddComponent("knownlocations")
    inst:AddComponent("entitytracker")

    inst:SetStateGraph("SGsdf_shadow_demonette")
    inst:SetBrain(brain)

    inst.OnLoadPostPass = OnLoadPostPass

    inst.persists = false

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.5)
    MakeGhostPhysics(inst, 25, inst.physicsradiusoverride)
    inst.DynamicShadow:SetSize(1.7, .9)
    inst.Transform:SetFourFaced()

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")
    inst:AddTag("shadow_aligned")
    inst:AddTag("sdf_shadow_demonette")

    inst.AnimState:SetBank("sdf_shadow_demonette")
    inst.AnimState:SetBuild("sdf_shadow_demonette")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetSymbolLightOverride("fx_red", 1)
    inst.AnimState:SetSymbolLightOverride("fx_red_particle", 1)
    inst.AnimState:SetSymbolLightOverride("wingend_red", 1)

    inst:AddComponent("colouraddersync")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
	local flames = CreateFlameFx()
	flames.entity:SetParent(inst.entity)
	flames.Follower:FollowSymbol(inst.GUID, "fx_flame_swap", nil, nil, nil, true)

	local fabric = CreateFabricFx()
	fabric.entity:SetParent(inst.entity)
	fabric.Follower:FollowSymbol(inst.GUID, "fx_fabric_swap", nil, nil, nil, true)

	local cape = CreateCapeFx()
	cape.entity:SetParent(inst.entity)
	cape.Follower:FollowSymbol(inst.GUID, "cape_front_swap", nil, nil, nil, true)

	inst.highlightchildren = { flames, fabric, cape }

	inst.components.colouraddersync:SetColourChangedFn(OnColourChanged)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("inspectable")

    --inst:AddComponent("sanityaura")
    --inst.components.sanityaura.aura = -TUNING.SDF_SHADOW_DEMONETTE_SANITY_AURA

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.SDF_SHADOW_DEMONETTE_WALKSPEED

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_SHADOW_DEMONETTE_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SDF_SHADOW_DEMONETTE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SDF_SHADOW_DEMONETTE_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SDF_SHADOW_DEMONETTE_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.forcefacing = false
    inst.components.combat.hiteffectsymbol = "shad"
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)

    inst:AddComponent("planarentity")
    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_SHADOW_DEMONETTE_PLANAR_DAMAGE)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("sdf_shadow_demonette_loot")
    inst.components.lootdropper.y_speed = 4
    inst.components.lootdropper.y_speed_variance = 3
    inst.components.lootdropper.spawn_loot_inside_prefab = true

    inst:AddComponent("colouradder")
    inst:AddComponent("knownlocations")
    inst:AddComponent("entitytracker")

    inst:SetStateGraph("SGsdf_shadow_demonette")
    inst:SetBrain(brain)

    inst.OnLoadPostPass = OnLoadPostPass

    inst.persists = false

    return inst
end

return Prefab("sdf_shadow_demonette_penumbra", fn, assets, prefabs),
	Prefab("sdf_shadow_demonette_umbra", fn2, assets, prefabs)
