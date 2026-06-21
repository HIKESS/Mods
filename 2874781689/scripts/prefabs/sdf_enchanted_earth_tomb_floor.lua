local assets = {
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_floor.zip"),
}

local assets2 = {
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_wall.zip"),
}

local assets3 = {
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_water.zip"),
}

local assets4 = {
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_decor.zip"),
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
    inst:AddTag("sdf_enchanted_earth_tomb_floor")

    inst.AnimState:SetBank("sdf_pumpkin_gorge_well_floor")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_floor")
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

    inst.AnimState:SetBank("sdf_pumpkin_gorge_well_wall")
    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_wall")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    --inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(2)

    inst.Transform:SetScale(1.8, 1.7, 2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local s = 1.6 --1.9
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_water")
    inst.AnimState:SetBank("sdf_pumpkin_gorge_well_water")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)

    -- From watersource component
    inst:AddTag("watersource")
    inst:AddTag("pond")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")
    inst:AddTag("sdf_pumpkin_gorge_well_water")

    inst.no_wet_prefix = true

    inst:SetDeploySmartRadius(4)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst:AddComponent("inspectable")

    inst:AddComponent("watersource")

    return inst
end


local function OnInit(inst)
    inst.task = nil
end

local function makeDecor(prefabName, animType, xScale, yScale, zScale, sortOrder)
    local function fn4()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

        --MakeObstaclePhysics(inst, .7)

        inst.Transform:SetScale(xScale, yScale, zScale)

        inst.AnimState:SetBank("sdf_pumpkin_gorge_well_decor")
        inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_decor")
        inst.AnimState:PlayAnimation(animType)

	if sortOrder == true then
	    inst.AnimState:SetSortOrder(3)
	end

	inst:AddTag("DECOR")
	inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")
        inst:AddTag("nonpackable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        return inst
    end
    return Prefab(prefabName, fn4, assets4)
end

return Prefab("sdf_enchanted_earth_tomb_floor", fn, assets),
	Prefab("sdf_enchanted_earth_tomb_wall", fn2, assets2)
	--Prefab("sdf_pumpkin_gorge_well_water", fn3, assets3),

--[[makeDecor("sdf_pumpkin_gorge_well_decor1","decor_1", 1, 1.5, 1, true), makeDecor("sdf_pumpkin_gorge_well_decor2","decor_2", 1.3, 1.3, 1.3, false), makeDecor("sdf_pumpkin_gorge_well_decor3","decor_3", 1.2, 1.2, 1.2, true),
makeDecor("sdf_pumpkin_gorge_well_decor4","decor_4", 1.5, 1.5, 1.5, true), makeDecor("sdf_pumpkin_gorge_well_decor5","decor_5", 1, 1, 1, true), makeDecor("sdf_pumpkin_gorge_well_decor6","decor_6", 1, 1, 1, false),
makeDecor("sdf_pumpkin_gorge_well_decor7","decor_7", 1, 1, 1, false)]]