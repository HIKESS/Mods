local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_guttedshoot.zip"),
    Asset("ANIM","anim/sdf_pumpking_gutted.zip"),
}


local prefabs =
{
}

local function OnHitGuts(inst, attacker, target)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    SpawnPrefab("sdf_pumpking_gutted_splash_fx").Transform:SetPosition(ix, iy, iz)
    inst.components.wateryprotection:SpreadProtection(inst)

    if inst:IsOnOcean() then
        SpawnPrefab("sdf_pumpking_gutted_puddle_water_fx").Transform:SetPosition(ix, iy, iz)
    else
        SpawnPrefab("sdf_pumpking_gutted_puddle_land_fx").Transform:SetPosition(ix, iy, iz)
    end

    --gutable blind effect
    local ents = TheSim:FindEntities(ix, iy, iz, 1)
    for _, ent in ipairs(ents) do
        if ent.components.inkable and ent.components.sdf_pumpking_gutable then
            ent.components.sdf_pumpking_gutable:Gutted()
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

    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:SetCollisionMask(COLLISION.GROUND)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetDontRemoveOnSleep(true) -- so the object can land and put out the fire, also an optimization due to how this moves through the world

    inst.AnimState:SetBank("sdf_pumpking_guttedshoot")
    inst.AnimState:SetBuild("sdf_pumpking_guttedshoot")
    inst.AnimState:PlayAnimation("spin_pre",false)
    inst.AnimState:PlayAnimation("spin_loop",true)

    inst:AddTag("NOCLICK")
    inst:AddTag("projectile")
    inst:AddTag("complexprojectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("wateryprotection")
    inst.components.wateryprotection.extinguishheatpercent = TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.temperaturereduction = TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_TEMP_REDUCTION
    inst.components.wateryprotection.witherprotectiontime = TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_PROTECTION_TIME
    --inst.components.wateryprotection.addcoldness = TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_ADD_COLDNESS
    inst.components.wateryprotection.addwetness = TUNING.SDF_PUMPKING_GUTTEDSPLAT_EXTINGUISH_ADD_WETNESS
    inst.components.wateryprotection:AddIgnoreTag("player")

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
    inst.components.complexprojectile:SetOnHit(OnHitGuts)

    inst.persists = false

    return inst
end

local function OnChangeFollowSymbol(inst, target, followsymbol, followoffset)
    inst.Follower:FollowSymbol(target.GUID, followsymbol, followoffset.x, followoffset.y, followoffset.z)
end

local function OnAttached(inst, target, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)
    inst.Follower:FollowSymbol(target.GUID, "headbase", 0,0,0)
    if inst._followtask ~= nil then
        inst._followtask:Cancel()
    end
end

local function OnDetached(inst)
    inst.AnimState:PlayAnimation("ink_pst")
    inst:ListenForEvent("animover", function()
        inst:Remove()
    end)
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("sdf_pumpking_gutted")
    inst.AnimState:SetBuild("sdf_pumpking_gutted")
    inst.AnimState:PlayAnimation("ink_pre")
    inst.AnimState:PushAnimation("ink_loop")
    inst.AnimState:SetFinalOffset(3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)

    return inst
end

return Prefab("sdf_pumpking_guttedsplat", fn, assets),
	Prefab("sdf_pumpking_gutted_player_fx", fn2, assets)