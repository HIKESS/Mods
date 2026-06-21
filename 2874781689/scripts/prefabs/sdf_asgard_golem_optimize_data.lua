local assets=
{
    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_optimize_data_damaged.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_optimize_data_damaged.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_a.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_a.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_c.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_optimize_data_type_c.xml"),

    Asset("ANIM", "anim/sdf_asgard_golem_optimize_data.zip"),
    Asset("ANIM", "anim/sdf_asgard_golem_optimize_data_type_b_fx.zip"),
}

prefabs = {
}

local function isWetDecay(inst)
    local iswet = inst.components.inventoryitem:IsWet()
    if iswet then
	if inst.isWetCheck == true then
	
	    --Spawns in inventory
	    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
	    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
	    local optimizeDataDamaged = SpawnPrefab("sdf_asgard_golem_optimize_data_damaged")
	    if holder ~= nil then
		local slot = holder:GetItemSlot(inst)
		inst:Remove()
		holder:GiveItem(optimizeDataDamaged, slot)
	    else
		optimizeDataDamaged.Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove()
	    end
	else
	    inst.isWetCheck = true
	end
    else
	inst.isWetCheck = false
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_asgard_golem_optimize_data")
    inst.AnimState:SetBuild("sdf_asgard_golem_optimize_data")
    inst.AnimState:PlayAnimation("type_a")

    MakeInventoryFloatable(inst, "small", 0.25)

    inst:AddTag("sdf_asgard_golem_optimize_data")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    --Allows installing Optimize Data into Asgard Golem
    inst:AddComponent("sdf_asgard_golem_optimize_data_install")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_asgard_golem_optimize_data_type_a"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_asgard_golem_optimize_data_type_a.xml"

    MakeHauntableLaunch(inst)

    inst.isWetCheck = false
    inst.isWetTask = inst:DoPeriodicTask(TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_DECAY_TICK, function() isWetDecay(inst) end)

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_asgard_golem_optimize_data")
    inst.AnimState:SetBuild("sdf_asgard_golem_optimize_data")
    inst.AnimState:PlayAnimation("type_c")

    MakeInventoryFloatable(inst, "small", 0.25)

    inst:AddTag("sdf_asgard_golem_optimize_data")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    --Allows installing Optimize Data into Asgard Golem
    inst:AddComponent("sdf_asgard_golem_optimize_data_install")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_asgard_golem_optimize_data_type_c"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_asgard_golem_optimize_data_type_c.xml"

    MakeHauntableLaunch(inst)

    inst.isWetCheck = false
    inst.isWetTask = inst:DoPeriodicTask(TUNING.SDF_ASGARD_GOLEM_OPTIMIZE_DATA_DECAY_TICK, function() isWetDecay(inst) end)

    return inst
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_asgard_golem_optimize_data")
    inst.AnimState:SetBuild("sdf_asgard_golem_optimize_data")
    inst.AnimState:PlayAnimation("damaged")

    MakeInventoryFloatable(inst, "small", 0.25)

    inst:AddTag("sdf_asgard_golem_optimize_data")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_asgard_golem_optimize_data_damaged"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_asgard_golem_optimize_data_damaged.xml"

    MakeHauntableLaunch(inst)

    return inst
end

local WAVE_FX_LEN = 0.5 --0.5
local function WaveFxOnUpdate(inst, dt)
    inst.t = inst.t + dt

    if inst.t < WAVE_FX_LEN then
	local k = 1 - inst.t / WAVE_FX_LEN
	k = k * k
	inst.AnimState:SetMultColour(1, 1, 1, k)
	k = (2 - 1.7 * k) * (inst.scalemult or 1)
	inst.AnimState:SetScale(k, k)
    else
	inst:Remove()
    end
end

local function CreateWaveFX()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("sdf_asgard_golem_optimize_data_type_b_fx")
    inst.AnimState:SetBuild("sdf_asgard_golem_optimize_data_type_b_fx")
    inst.AnimState:PlayAnimation("barrier_rim")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetAddColour(208/255, 216/255, 104/255, 1)

    inst.entity:SetPristine()

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.t = 0
    inst.scalemult = .75
    WaveFxOnUpdate(inst, 0)

    return inst
end

local function CreateDomeFX()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst:AddTag("FX")

    inst.AnimState:SetBank("sdf_asgard_golem_optimize_data_type_b_fx")
    inst.AnimState:SetBuild("sdf_asgard_golem_optimize_data_type_b_fx")
    inst.AnimState:PlayAnimation("barrier_dome")
    inst.AnimState:SetFinalOffset(7)

    inst.AnimState:SetAddColour(208/255, 216/255, 104/255, 1)

    inst.entity:SetPristine()

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.t = 0
    WaveFxOnUpdate(inst, 0)

    return inst
end

return  Prefab("common/inventory/sdf_asgard_golem_optimize_data_type_a", fn, assets),
	Prefab("common/inventory/sdf_asgard_golem_optimize_data_type_c", fn2, assets),
	Prefab("common/inventory/sdf_asgard_golem_optimize_data_damaged", fn3, assets),
	Prefab("sdf_asgard_golem_optimize_data_type_b_barrier_wave_fx", CreateWaveFX, assets),
	Prefab("sdf_asgard_golem_optimize_data_type_b_barrier_dome_fx", CreateDomeFX, assets)