local assets =
{
    Asset("ANIM", "anim/sdf_shadow_barrier.zip"),
}

local SLEEPREPEL_MUST_TAGS = { "locomotor" }
local SLEEPREPEL_CANT_TAGS = { "fossil", "shadow", "playerghost", "INLIMBO" }
local ABSORB_CANT_TAGS = {"player", "playerghost", "INLIMBO" }

local function StartRepel(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local creatures = {}

    --barrier pushback
    local REPEL_RADIUS = inst.repel_radius
    for i, v in ipairs(TheSim:FindEntities(x, y, z, REPEL_RADIUS, SLEEPREPEL_MUST_TAGS, SLEEPREPEL_CANT_TAGS)) do
        if v:IsValid() and v.entity:IsVisible() and not (v.components.health ~= nil and v.components.health:IsDead()) then
            if v:HasTag("player") then
		inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/shield")
                v:PushEvent("repelled", { repeller = inst, radius = REPEL_RADIUS })
            end
        end
    end

    --nightmare and horror fuel absorb
    local ABSORB_RADIUS = inst.absorb_radius
    for i, s in ipairs(TheSim:FindEntities(x, y, z, ABSORB_RADIUS, nil, ABSORB_CANT_TAGS)) do
        if s:IsValid() and s.entity:IsVisible() then
            if s:GetTimeAlive() >= 8 and (s.prefab == "nightmarefuel" or s.prefab == "horrorfuel") then
		local x,_,z=s.Transform:GetWorldPosition()
		local absorbFX = SpawnPrefab("fused_shadeling_spawn_fx")
		absorbFX.Transform:SetPosition(x,_,z)
		s:Remove()
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

    inst.AnimState:SetBank("sdf_shadow_barrier")
    inst.AnimState:SetBuild("sdf_shadow_barrier")

    inst.AnimState:PlayAnimation("idle"..tostring(math.random(1, 3)))

    inst.AnimState:SetFinalOffset(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    --inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/shield")

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)

    inst.repel_radius = 3
    inst.absorb_radius = 22

    inst:DoTaskInTime(2 * FRAMES, StartRepel)

    return inst
end

return Prefab("sdf_shadow_barrier", fn, assets)