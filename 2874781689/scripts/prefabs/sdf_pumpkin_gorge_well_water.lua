--require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_gorge_well_water.zip"),
}


local prefabs =
{

}

local function SlipperyRate(inst, target)
    local speed = target.Physics and target.Physics:GetMotorSpeed() or 0
    if speed > TUNING.WILSON_RUN_SPEED then
        return 50
    end

    return 5
end

local function OnSnowLevel(inst, snowlevel)
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

local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local s = 1.95 --1.9
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBuild("sdf_pumpkin_gorge_well_water")
    inst.AnimState:SetBank("sdf_pumpkin_gorge_well_water")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

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

    inst.task = inst:DoTaskInTime(0, OnInit)

    return inst
end

return Prefab( "sdf_pumpkin_gorge_well_water", fn, assets, prefabs)