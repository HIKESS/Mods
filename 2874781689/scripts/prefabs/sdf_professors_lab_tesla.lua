local assets =
{
    Asset("ANIM", "anim/sdf_professors_lab_tesla.zip"),
}

prefabs = {
}

local function removeChargedMaxTask(inst)
    if inst.chargedmaxtask ~= nil then
	inst.chargedmaxtask:Cancel()
	inst.chargedmaxtask = nil
    end
end

local function removeChargingTask(inst)
    if inst.chargingtask ~= nil then
	inst.chargingtask:Cancel()
	inst.chargingtask = nil
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
    local currentCharge = inst.components.sdf_professors_lab_tesla_resource:GetCurrent()

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
	inst.components.machine.enabled = true
	inst.components.machine.ison = false
	inst.chargedmaxtask = inst:DoTaskInTime(math.random(2, 5), chargedMaxFX)
    end
end



local function charging(inst)
    --Gain a Charge
    local currentCharge = inst.components.sdf_professors_lab_tesla_resource:GetCurrent()
    if currentCharge < TUNING.SDF_PROFESSORS_LAB_TESLA_RESOURCE_MAX then
	inst.components.sdf_professors_lab_tesla_resource:DoDelta(1, false, "gaincharge")
	inst.SoundEmitter:PlaySound("rifts3/wagpunk_armor/upgrade")
	chargingStatus(inst)
	inst.chargingtask = inst:DoTaskInTime(TUNING.SDF_PROFESSORS_LAB_TESLA_CHARGE_RATE, charging)
    else
	--Remove Charging Task
	removeChargingTask(inst)
    end

    --local x,_,z = inst.Transform:GetWorldPosition()
    --local s = 0.5
    --local chargeSpark = SpawnPrefab("mushroomsprout_glow")
    --lifeOrbs.Transform:SetPosition(x,_,z)
    --lifeOrbs.Transform:SetScale(s,s,s)

end

local function startcharging(inst)
    inst.chargingtask = inst:DoTaskInTime(TUNING.SDF_PROFESSORS_LAB_TESLA_CHARGE_RATE, charging)
end

local function Discharge(inst)

    --Remove Charged Max task
    removeChargedMaxTask(inst)

    --Remove Charing Task
    if inst._isPowered == false then
	inst.AnimState:PlayAnimation("hit_off")
	inst.AnimState:PushAnimation("idle")
	removeChargingTask(inst)
    else
	inst.AnimState:PlayAnimation("hit_on")
	inst.AnimState:PushAnimation("work_loop", true)
	inst.chargingtask = inst:DoTaskInTime(0, startcharging)
    end

    --Remove charges
    local currentCharge = inst.components.sdf_professors_lab_tesla_resource:GetCurrent()
    if currentCharge > 0 then
	inst.components.sdf_professors_lab_tesla_resource:DoDelta(-currentCharge, false, "discharge")
    end

    --Remove charge
    inst.charged = false

    --Remove Switch
    if inst.components.machine.enabled == true then
	inst.components.machine.ison = false
	inst.components.machine.enabled = false
    end

    chargingStatus(inst)
end

local function TurnOn(inst)
    --Make this shock gallow
    Discharge(inst)
end

local function makePowered(inst)
    inst.AnimState:PlayAnimation("work_loop", true)
    inst._isPowered = true
    inst.chargingtask = inst:DoTaskInTime(0, startcharging)
end

local function makeUnpowered(inst)
    inst.AnimState:PlayAnimation("idle")
    inst._isPowered = false
    removeChargingTask(inst)
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

    MakeObstaclePhysics(inst, .9)

    inst.AnimState:SetBank("sdf_professors_lab_tesla")
    inst.AnimState:SetBuild("sdf_professors_lab_tesla")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("lightningrod")
    inst:AddTag("nonpackable")
    inst:AddTag("sdf_professors_lab_generator_powered")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    --Energy Pool
    inst:AddComponent("sdf_professors_lab_tesla_resource")

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.cooldowntime = 0
    inst.components.machine.ison = false
    inst.components.machine.enabled = false

    inst.charged = false
    inst._isPowered = false
    inst.SdfProfessorsLabPoweredFn = function() makePowered(inst) end
    inst.SdfProfessorsLabUnpoweredFn = function() makeUnpowered(inst) end
    inst.SdfProfessorsLabDischargeFn = function() Discharge(inst) end

    inst.chargingtask = nil
    inst.chargedmaxtask = nil

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("sdf_professors_lab_tesla", fn, assets)