local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("blocker")

    local ZA = inst.entity:AddPhysics()
    ZA:SetMass(0)
    ZA:SetCollisionGroup(COLLISION.WORLD)
    ZA:ClearCollisionMask()
    for _IQQ, XpkjA in pairs(COLLISION) do
        if _IQQ ~= "SANITY" then
            ZA:CollidesWith(XpkjA)
        end
    end

    ZA:SetCapsule(0.5, 2)

    inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("birdblocker")
    inst:AddTag("wall")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("sdf_professors_lab_boundary", fn)