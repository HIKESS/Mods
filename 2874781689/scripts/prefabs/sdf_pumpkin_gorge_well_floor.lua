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
    inst:AddTag("sdf_pumpkin_gorge_well_floor")

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

local function SlipperyRate(inst, target)
    local speed = target.Physics and target.Physics:GetMotorSpeed() or 0
    if speed > TUNING.WILSON_RUN_SPEED then
        return 50
    end

    return 5
end

local function OnSnowLevelWater(inst, snowlevel)
    if snowlevel >= .04 then
        if not inst.frozen then
            inst.frozen = true

            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/winter/pondfreeze")

            inst.components.watersource.available = false
            local slipperyfeettarget = inst:AddComponent("slipperyfeettarget")
            slipperyfeettarget:SetSlipperyRate(SlipperyRate)
        end
    elseif inst.frozen then
        inst.frozen = false

        inst.AnimState:PlayAnimation("idle", true)

        inst.components.watersource.available = true
        inst:RemoveComponent("slipperyfeettarget")
    elseif inst.frozen == nil then
        inst.frozen = false

        inst.AnimState:PlayAnimation("idle", true)

        inst.components.watersource.available = true
        inst:RemoveComponent("slipperyfeettarget")
    elseif inst.frozen == false then

        inst.AnimState:PlayAnimation("idle", true)

        inst.components.watersource.available = true
        inst:RemoveComponent("slipperyfeettarget")
    end
end

local function OnInitWater(inst)
    inst.task = nil
    inst:WatchWorldState("snowlevel", OnSnowLevelWater)
    OnSnowLevelWater(inst, TheWorld.state.snowlevel)
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

    inst.task = inst:DoTaskInTime(0, OnInitWater)

    return inst
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .01 then
        if not inst.frozen then
            inst.frozen = true

	    --add frost
	    inst.components.colouradder:PushColour("frost", 82 / 255, 115 / 255, 124 / 255, 0)
        end
    elseif inst.frozen then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")
    elseif inst.frozen == nil then
        inst.frozen = false

	--remove frost
	inst.components.colouradder:PopColour("frost")
    elseif inst.frozen == false then

	--remove frost
	inst.components.colouradder:PopColour("frost")
    end
end

local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
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

	inst:AddComponent("colouradder")

	inst.task = inst:DoTaskInTime(0, OnInit)

        return inst
    end
    return Prefab(prefabName, fn4, assets4)
end

return Prefab("sdf_pumpkin_gorge_well_floor", fn, assets),
	Prefab("sdf_pumpkin_gorge_well_wall", fn2, assets2),
	Prefab("sdf_pumpkin_gorge_well_water", fn3, assets3),

makeDecor("sdf_pumpkin_gorge_well_decor1","decor_1", 1, 1.5, 1, true), makeDecor("sdf_pumpkin_gorge_well_decor2","decor_2", 1.3, 1.3, 1.3, false), makeDecor("sdf_pumpkin_gorge_well_decor3","decor_3", 1.2, 1.2, 1.2, true),
makeDecor("sdf_pumpkin_gorge_well_decor4","decor_4", 1.5, 1.5, 1.5, true), makeDecor("sdf_pumpkin_gorge_well_decor5","decor_5", 1, 1, 1, true), makeDecor("sdf_pumpkin_gorge_well_decor6","decor_6", 1, 1, 1, false),
makeDecor("sdf_pumpkin_gorge_well_decor7","decor_7", 1, 1, 1, false)