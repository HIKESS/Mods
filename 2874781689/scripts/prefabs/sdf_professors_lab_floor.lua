local assets = {
    Asset("ANIM", "anim/sdf_professors_lab_floor.zip"),
}

local assets2 = {
    Asset("ANIM", "anim/sdf_professors_lab_wall.zip"),
}

local assets3 = {
    Asset("ANIM", "anim/sdf_professors_lab_pillar.zip"),
}

local assets4 = {
    Asset("ANIM", "anim/sdf_professors_lab_trackend.zip"),
}

local function isWet(inst)
    inst.GetIsWet = function(...)
        return false
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("sdf_professors_lab_floor")

    inst.AnimState:SetBank("sdf_professors_lab_floor")
    inst.AnimState:SetBuild("sdf_professors_lab_floor")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(2.26, 2, 1.8)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(0)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn2()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("sdf_professors_lab_wall")

    inst.entity:AddAnimState()

    inst.AnimState:SetBank("sdf_professors_lab_wall")
    inst.AnimState:SetBuild("sdf_professors_lab_wall")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(1)

    inst.Transform:SetScale(1.8, 1.7, 2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end


local function makePowered(inst)
    if inst.prefab == "sdf_professors_lab_wall_pillar" then
	inst.AnimState:PlayAnimation("idle_on")
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PILLAR_ON)
	inst._isPowered = true
    end
    if inst.prefab == "sdf_professors_lab_wall_pillar_in" then
	inst.AnimState:PlayAnimation("idle_inon")
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PILLAR_ON)
	inst._isPowered = true
    end
end

local function makeUnpowered(inst)
    if inst.prefab == "sdf_professors_lab_wall_pillar" then
	inst.AnimState:PlayAnimation("idle")
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PILLAR_OFF)
	inst._isPowered = false
    end
    if inst.prefab == "sdf_professors_lab_wall_pillar_in" then
	inst.AnimState:PlayAnimation("idle_in")
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_PILLAR_OFF)
	inst._isPowered = false
    end
end

local function setPowered(inst)
    if inst._isPowered == true then
	makePowered(inst)
    end
end

local function onsave3(inst, data)
    data.eastside = inst.eastside or nil
    data._isPowered = inst._isPowered
end

local function onload3(inst, data)
    if data and data.eastside ~= nil then
        inst.eastside = data.eastside
        inst.AnimState:SetScale(-1, 1, 1)
    end
    if data and data._isPowered ~= nil then
        inst._isPowered = data._isPowered
	setPowered(inst)
    end
end

local function makeWallPillar(prefabName, animType)
    local function fn3()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
        inst.entity:AddAnimState()

        MakeObstaclePhysics(inst, .7)

        inst.AnimState:SetBank("sdf_professors_lab_pillar")
        inst.AnimState:SetBuild("sdf_professors_lab_pillar")
        inst.AnimState:PlayAnimation(animType)

        inst.Transform:SetScale(1.4, 1.4, 1.4)

        isWet(inst)

        inst:AddTag("NOBLOCK")
        inst:AddTag("nonpackable")
        inst:AddTag("sdf_professors_lab_generator_powered")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

	inst._isPowered = false
	inst.SdfProfessorsLabPoweredFn = function() makePowered(inst) end
	inst.SdfProfessorsLabUnpoweredFn = function() makeUnpowered(inst) end

        inst.OnSave = onsave3
        inst.OnLoad = onload3

        return inst
    end
    return Prefab(prefabName, fn3, assets3)
end

local function fn4()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.Transform:SetScale(2.5, 2.5, 2.5)

    inst.AnimState:SetBank("sdf_professors_lab_trackend")
    inst.AnimState:SetBuild("sdf_professors_lab_trackend")
    inst.AnimState:PlayAnimation("idle")

    --inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst:AddTag("structure")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("sdf_professors_lab_floor", fn, assets), Prefab("sdf_professors_lab_wall", fn2, assets2), Prefab("sdf_professors_lab_trackend", fn4, assets4),
makeWallPillar("sdf_professors_lab_wall_pillar","idle"), makeWallPillar("sdf_professors_lab_wall_pillar_in", "idle_in")