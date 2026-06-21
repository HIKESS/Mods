local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_seed.zip"),
}

local function OnProjectileHit(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Physics:SetActive(false)

    local seed = SpawnPrefab(inst.seedType)
    if seed ~= nil then
	seed.Transform:SetPosition(x, y, z)
	seed.summoned = true

	seed.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_land")
	local pumpkinKing = inst.components.entitytracker:GetEntity("sdf_pumpkin_king")
	if pumpkinKing ~= nil then
	    seed.components.entitytracker:TrackEntity("sdf_pumpkin_king", pumpkinKing)
	end
    end
    inst:Remove()
end

local function MakeMiasma(inst)
    if inst.seedType == "sdf_pumpking_miasma_small_telegraph" then
	inst.AnimState:PlayAnimation("invisible")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:SetCollisionMask(COLLISION.WORLD)
    inst.Physics:SetCapsule(.2, .2)

    inst.AnimState:SetBank("sdf_pumpking_seed")
    inst.AnimState:SetBuild("sdf_pumpking_seed")
    inst.AnimState:PlayAnimation("thrown", true)

    inst:AddTag("NOCLICK")
    inst:AddTag("projectile")
    inst:AddTag("complexprojectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
    inst.components.complexprojectile:SetOnHit(OnProjectileHit)

    inst:AddComponent("entitytracker")
    inst:AddComponent("follower")

    inst.seedType = "sdf_pumpking_gourd_plant"
    inst.seedLeader = nil

    inst.persists = false

    inst:DoTaskInTime(0, MakeMiasma)

    return inst
end

return Prefab("sdf_pumpking_seed", fn, assets)
