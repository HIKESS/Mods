local assets =
{
    Asset("ANIM", "anim/sdf_professors_lab_chalice.zip"),
}

prefabs = {
}

local function removeChargedMaxTask(inst)
    if inst.chargedmaxtask ~= nil then
	inst.chargedmaxtask:Cancel()
	inst.chargedmaxtask = nil
    end
end

local function chargedMaxFX(inst)
    local x,_,z = inst.Transform:GetWorldPosition()
    local chargeMaxSpark = SpawnPrefab("lightning_rod_fx")
    chargeMaxSpark.Transform:SetPosition(x,_,z)
    chargeMaxSpark.Transform:SetScale(2,0.5,0.5)
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")

    inst.chargedmaxtask = inst:DoTaskInTime(math.random(2, 5), chargedMaxFX)
end

local function chargingStatus(inst)
    --Update Charged Visual
    local currentCharge = inst.components.sdf_professors_lab_chalice_resource:GetCurrent()

    if currentCharge > 0 then
	inst.AnimState:OverrideSymbol("body", "sdf_professors_lab_tesla", "m"..tostring(currentCharge))
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_TESLA_STATUS[currentCharge])
    else
	inst.AnimState:ClearOverrideSymbol("body")
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_PROFESSORS_LAB_TESLA_STATUS[0])
    end

    --Adds Charged Max FX
    if currentCharge >= 5 then
	inst.charged = true
	--inst.chargedmaxtask = inst:DoTaskInTime(math.random(2, 5), chargedMaxFX)
    end
end


local function makePowered(inst)
    inst.AnimState:PlayAnimation("idle_on_loop", true)
    inst._isPowered = true
end

local function makeUnpowered(inst)
    inst.AnimState:PlayAnimation("idle_off")
    inst._isPowered = false
    --discharge(inst)
end

local function setPowered(inst)
    chargingStatus(inst)
    if inst._isPowered == true then
	makePowered(inst)
    end
end

local function onsave(inst, data)
    data.charged = inst.charged
    data._isPowered = inst._isPowered
end

local function onload(inst, data)
    if data and data._isPowered ~= nil then
        inst._isPowered = data._isPowered
	setPowered(inst)
    end
    if data ~= nil and data.charged ~= nil then
	inst.charged = data.charged
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local s = 1.3
    inst.Transform:SetScale(s,s,s)

    inst.AnimState:SetBank("sdf_professors_lab_chalice")
    inst.AnimState:SetBuild("sdf_professors_lab_chalice")
    inst.AnimState:PlayAnimation("idle_off")

    MakeObstaclePhysics(inst, .9)

    inst:AddTag("structure")
    inst:AddTag("nonpackable")
    inst:AddTag("sdf_professors_lab_generator_powered")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    --Energy Pool
    inst:AddComponent("sdf_professors_lab_chalice_resource")

    inst.charged = false
    inst._isPowered = false
    inst.SdfProfessorsLabPoweredFn = function() makePowered(inst) end
    inst.SdfProfessorsLabUnpoweredFn = function() makeUnpowered(inst) end

    inst.chargedmaxtask = nil

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("sdf_professors_lab_chalice", fn, assets)