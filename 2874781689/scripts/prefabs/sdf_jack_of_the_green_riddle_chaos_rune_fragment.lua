local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_jack_of_the_green_riddle_chaos_rune_fragment.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_jack_of_the_green_riddle_chaos_rune_fragment.tex"),

    Asset("ANIM", "anim/sdf_jack_of_the_green_riddle_chaos_rune_fragment.zip"),
    Asset("ANIM", "anim/swap_sdf_jack_of_the_green_riddle_chaos_rune_fragment.zip"),
}

prefabs = {
}

local function OnPickupFn(inst, picker)
    if picker.prefab == "sdf_jack_of_the_green_riddle_moleworm" then
	--Heal
	picker.components.health:DoDelta(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_MOLEWORM_HEALTH, true, "chaos rune fragment")

	--Check if koalefant is close
	picker:ScareKoalefant()

	--Remove Runes
	inst:DoTaskInTime(2, function()
	    inst:Remove()
	end)
    end
end

local function onperish(inst)
    inst:Remove()
end

local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 8.5, 6.5, -.25 do
	pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
	if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
	    return pos
	end
    end
    return pos
end

----------------------------------------------------------------------------------------------------------
local MUST_HAVE_TAGS_PLAYER = {"player"}
local CANT_HAVE_TAGS_PLAYER = {"playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS_PLAYER = 10

local function aoeShakePlayerCheck(target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS_PLAYER, MUST_HAVE_TAGS_PLAYER, CANT_HAVE_TAGS_PLAYER)
    for i, v in ipairs(affected_entity) do

	--find players
	if v ~= nil then
	    v:ShakeCamera(CAMERASHAKE.SIDE, 6, 0.03, 0.3) --0.1
	end
    end
end

local function aoeSanityDrainPlayerCheck(target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS_PLAYER, MUST_HAVE_TAGS_PLAYER, CANT_HAVE_TAGS_PLAYER)
    for i, v in ipairs(affected_entity) do

	--find players
	if v ~= nil then
	    local pt = v:GetPosition()
	    SpawnPrefab("sanity_lower").Transform:SetPosition(pt.x, pt.y, pt.z)
	    if v.components.sanity then
		v.components.sanity:DoDelta(-TUNING.SDF_CHAOS_ROCK2_SANITY_DRAIN)
	    end
	end
    end
end

local function aoeKnockbackPlayerCheck(target)
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS_PLAYER, MUST_HAVE_TAGS_PLAYER, CANT_HAVE_TAGS_PLAYER)
    for i, v in ipairs(affected_entity) do

	--find players
	if v ~= nil then
	    if v.components.sanity then
		v.components.sanity:DoDelta(TUNING.SDF_CHAOS_ROCK2_SANITY_DRAIN * 2)
	    end
	    v.sg:GoToState("sdf_chaos_rock_knockback")
	    v.AnimState:SetHaunted(true)

	    v:DoTaskInTime(1, function()
		v.AnimState:SetHaunted(false)
	    end)
	end
    end
end

local function CheckChaosRock(fragment, target)
    if target.typeid == 1 then
	--Remove chaos rune fragment
	fragment:Remove()

	--create chaos rock
	aoeShakePlayerCheck(target)

	local x,_,z = target.Transform:GetWorldPosition()
	local aoeFX = SpawnPrefab("fused_shadeling_spawn_fx")
	aoeFX.Transform:SetPosition(x,_,z)
	local scale = 3
	aoeFX.Transform:SetScale(scale, scale, scale)

	--Drain Santiy
	target:DoTaskInTime(0.2, function()
	    aoeSanityDrainPlayerCheck(target)
	end)

	target:DoTaskInTime(0.7, function()
	    local pt = target:GetPosition()
	    SpawnPrefab("sanity_raise").Transform:SetPosition(pt.x, pt.y, pt.z)
	end)


	--become med
	target:DoTaskInTime(1.4, function()
	    local pt = target:GetPosition()
	    SpawnPrefab("dreadstone_spawn_fx").Transform:SetPosition(pt.x, pt.y, pt.z)
	    target.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/nightmare_FX")
	    target.AnimState:PlayAnimation("med")
	    target.AnimState:SetHaunted(true)
	end)

	target:DoTaskInTime(3, function()
	    local x,_,z = target.Transform:GetWorldPosition()
	    local aoeFX = SpawnPrefab("fused_shadeling_spawn_fx")
	    aoeFX.Transform:SetPosition(x,_,z)
	    local scale = 3
	    aoeFX.Transform:SetScale(scale, scale, scale)
	    target.AnimState:SetHaunted(false)
	end)

	--Drain Santiy
	target:DoTaskInTime(3.2, function()
	    aoeSanityDrainPlayerCheck(target)
	end)

	target:DoTaskInTime(3.7, function()
	    local pt = target:GetPosition()
	    SpawnPrefab("sanity_raise").Transform:SetPosition(pt.x, pt.y, pt.z)
	end)


	--become full
	target:DoTaskInTime(4.4, function()
	    local pt = target:GetPosition()
	    SpawnPrefab("dreadstone_spawn_fx").Transform:SetPosition(pt.x, pt.y, pt.z)
	    target.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/nightmare_FX")
	    target.AnimState:PlayAnimation("full")
	    target.AnimState:SetHaunted(true)
	end)

	target:DoTaskInTime(6, function()
	    local x,_,z = target.Transform:GetWorldPosition()
	    local aoeFX = SpawnPrefab("willow_shadow_fire_explode")
	    aoeFX.Transform:SetPosition(x,_,z)
	    local scale = 10
	    aoeFX.Transform:SetScale(scale, scale, scale)
	    target.SoundEmitter:PlaySound("meta2/wormwood/animation_dropdown")
	    target.AnimState:SetHaunted(false)

	    --Knockdown Players
	    aoeKnockbackPlayerCheck(target)

	    --create Chaos Rock
	    local chaosRock = SpawnPrefab("sdf_chaos_rock")
	    chaosRock.Transform:SetPosition(target.Transform:GetWorldPosition())
	    chaosRock.typeid = 1
	    target:Remove()
	end)
    end
end

local MUST_HAVE_TAGS_CHAOSROCK = {"sdf_chaos_rock2", "sdf_chaos_rock_engraft"}
local AOE_RADIUS_CHAOSROCK = 1.5

local function aoeChaosRockCheck(fragment)
    local tx, ty, tz = fragment.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS_CHAOSROCK, MUST_HAVE_TAGS_CHAOSROCK, "")
    for i, v in ipairs(affected_entity) do

	--find players
	if v ~= nil then
	    CheckChaosRock(fragment, v)
	end
    end
end
----------------------------------------------------------------------------------------------------------
local function CheckJOTGMolewormHill(fragment, target)
    --Spawns Moleworm
    local x,_,z=target.Transform:GetWorldPosition()
    local moleworm= SpawnPrefab("sdf_jack_of_the_green_riddle_moleworm")
    moleworm.Transform:SetPosition(x,_,z)
end

local MUST_HAVE_TAGS_MOLEWORMHILL = {"sdf_jack_of_the_green_riddle_moleworm_hill"}
local AOE_RADIUS_MOLEWORMHILL = 1

local function aoeJOTGMolewormHillCheck(fragment)
    local tx, ty, tz = fragment.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS_MOLEWORMHILL, MUST_HAVE_TAGS_MOLEWORMHILL, "")
    for i, v in ipairs(affected_entity) do

	--find players
	if v ~= nil then
	    CheckJOTGMolewormHill(fragment, v)
	end
    end
end
----------------------------------------------------------------------------------------------------------

local function OnHit(inst, attacker, target)
    local chaosRuneFragment = SpawnPrefab("sdf_jack_of_the_green_riddle_chaos_rune_fragment")
    chaosRuneFragment.Transform:SetPosition(inst.Transform:GetWorldPosition())

    --pass perish time
    local perishPercent = inst.components.perishable:GetPercent()
    chaosRuneFragment.components.perishable:SetPercent(perishPercent)

    inst.SoundEmitter:PlaySound("dontstarve/common/dropwood")

    --Check for see if close to Jack of the green riddle moleworm hill
    if attacker and attacker:HasTag("sdf_riddle_3_active") then
	aoeJOTGMolewormHillCheck(chaosRuneFragment)
    end

    --Check for see if close to ChaosRock2
    if attacker and attacker:HasTag("sdf_chaos_rock_engraft") then
	aoeChaosRockCheck(chaosRuneFragment)
    end

    inst:Remove()
end

local function onthrown(inst)
    inst.AnimState:SetBank("swap_sdf_jack_of_the_green_riddle_chaos_rune_fragment")
    inst.AnimState:SetBuild("swap_sdf_jack_of_the_green_riddle_chaos_rune_fragment")
    inst.AnimState:PlayAnimation("thrown")
    inst:AddTag("NOCLICK")
    inst.persists = false

    inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sdf_jack_of_the_green_riddle_chaos_rune_fragment", "swap_sdf_jack_of_the_green_riddle_chaos_rune_fragment")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst:RemoveTag("special_action_toss")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.components.combat:SetAttackPeriod(0.4)

    inst:AddTag("special_action_toss")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("sdf_jack_of_the_green_riddle_chaos_rune_fragment")
    inst.AnimState:SetBuild("sdf_jack_of_the_green_riddle_chaos_rune_fragment")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    inst:AddTag("projectile")
    inst:AddTag("sdf_jack_of_the_green_riddle_molebait")
    inst:AddTag("show_spoilage")
    inst:AddTag("special_action_toss")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetAllowWaterFn
    inst.components.reticule.ease = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHit)

    inst:AddComponent("bait")

    --Allows it to rot
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT_DURATION)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.perishfn = onperish

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_CHAOS_RUNE_FRAGMENT_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetSinks(true)
    inst.components.inventoryitem.imagename = "sdf_jack_of_the_green_riddle_chaos_rune_fragment"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_jack_of_the_green_riddle_chaos_rune_fragment.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_jack_of_the_green_riddle_chaos_rune_fragment", fn, assets)