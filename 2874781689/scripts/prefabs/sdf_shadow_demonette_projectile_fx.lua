local SpDamageUtil = require("components/spdamageutil")

local assets =
{
    Asset("ANIM", "anim/sdf_shadow_demonette_projectile_fx.zip"),
}

local assets2 =
{
    Asset("ANIM", "anim/sdf_dragon_potion_dragonfire_burntground_fx.zip"),
}

local prefabs =
{

}

local AOE_RANGE = 1
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "shadow_aligned" }

local function OnHit(inst)--, attacker, target)
    inst:RemoveComponent("complexprojectile")
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("projectile_impact")
    inst.DynamicShadow:Enable(false)
    local playsfx = true
    if inst.sfx ~= nil then
	if inst.sfx.played then
	    playsfx = false
	else
	    inst.sfx.played = true
	end
    end
    if playsfx then
	inst.SoundEmitter:PlaySound("rifts2/thrall_wings/projectile")
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, AOE_RANGE + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
	if not (inst.targets ~= nil and inst.targets[v]) and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) then
	    local range = AOE_RANGE + v:GetPhysicsRadius(0)
	    if v:GetDistanceSqToPoint(x, y, z) < range * range then
		local spdmg = SpDamageUtil.CollectSpDamage(inst)
		local attacker = inst.owner ~= nil and inst.owner:IsValid() and inst.owner or inst
		v.components.combat:GetAttacked(attacker, TUNING.SDF_SHADOW_DEMONETTE_DAMAGE, nil, nil, spdmg)
		if inst.targets ~= nil then
		    inst.targets[v] = true
		end
	    end
	end
    end

    local scorch = SpawnPrefab("sdf_shadow_demonette_projectile_scorch_fx")
    scorch.Transform:SetPosition(x, 0, z)
    scorch.Transform:SetScale(.9, .9, .9)
end

local function OnLaunch(inst, attacker)
    inst.owner = attacker
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(.8, .8)

    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:SetCollisionMask(COLLISION.GROUND)
    inst.Physics:SetCapsule(.2, .2)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("shadow_aligned")

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("sdf_shadow_demonette_projectile_fx")
    inst.AnimState:SetBuild("sdf_shadow_demonette_projectile_fx")
    inst.AnimState:PlayAnimation("projectile_pre")
    inst.AnimState:SetLightOverride(1)

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")
    inst:AddTag("complexprojectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst.AnimState:PushAnimation("projectile_loop")
    inst.AnimState:PushAnimation("idle_loop")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 3, 0))
    inst.components.complexprojectile:SetOnLaunch(OnLaunch)
    inst.components.complexprojectile:SetOnHit(OnHit)

    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(TUNING.SDF_SHADOW_DEMONETTE_PLANAR_DAMAGE)

    --inst.targets = nil
    --inst.sfx = nil
    inst.persists = false

    return inst
end

local SCORCH_DELAY_FRAMES = 30
local SCORCH_FADE_FRAMES = 10

local function Scorch_OnFadeDirty(inst)
    --V2C: hack alert: using SetHightlightColour to achieve something like OverrideAddColour
    --     (that function does not exist), because we know this FX can never be highlighted!
    if inst._fade:value() > SCORCH_FADE_FRAMES + SCORCH_DELAY_FRAMES then
        local k = (inst._fade:value() - SCORCH_FADE_FRAMES - SCORCH_DELAY_FRAMES)
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour(0, 0, k, 0)
    elseif inst._fade:value() >= SCORCH_FADE_FRAMES then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst.AnimState:SetHighlightColour()
    else
        local k = inst._fade:value() / SCORCH_FADE_FRAMES
        k = k * k
        inst.AnimState:OverrideMultColour(1, 1, 1, k)
        inst.AnimState:SetHighlightColour()
    end
end

local function Scorch_OnUpdateFade(inst)
    if inst._fade:value() > 1 then
        inst._fade:set_local(inst._fade:value() - 1)
        Scorch_OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    elseif inst._fade:value() > 0 then
        inst._fade:set_local(0)
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function scorchfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("sdf_dragon_potion_dragonfire_burntground_fx")
    inst.AnimState:SetBank("sdf_dragon_potion_dragonfire_burntground_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst._fade = net_byte(inst.GUID, "sdf_shadow_demonette_projectile_scorch_fx._fade", "fadedirty")
    inst._fade:set(SCORCH_DELAY_FRAMES + SCORCH_FADE_FRAMES)

    inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    Scorch_OnFadeDirty(inst)

    inst.Transform:SetScale(0.7, 0.7, 0.7)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", Scorch_OnFadeDirty)

        return inst
    end

    inst.Transform:SetRotation(math.random() * 360)
    inst.persists = false

    return inst
end

return Prefab("sdf_shadow_demonette_projectile_fx", fn, assets, prefabs),
	Prefab("sdf_shadow_demonette_projectile_scorch_fx", scorchfn, assets2)
