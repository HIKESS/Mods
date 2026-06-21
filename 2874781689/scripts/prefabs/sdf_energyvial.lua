local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_energyvial.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_energyvial.tex"),

    Asset("ANIM", "anim/sdf_energyvial.zip"),
}

prefabs = {
}

local function OnEaten(inst, eater)
    if eater.prefab == "sdf" then
	eater.components.sdf_lifebottle_holder:HealEnergyVialDoDelta(eater, TUNING.SDF_ENERGYVIAL_RECOVERY)

	local x,_,z=eater.Transform:GetWorldPosition()
	local fx = SpawnPrefab("spider_heal_target_fx")
	fx.Transform:SetPosition(x,_,z)
	eater.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")
    end
end

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")

    if pickupguy.prefab == "sdf" then

	inst:AddTag("fooddrink")

	--Resets edible if off
	if inst.components.edible == nil then
	    inst:AddComponent("edible")
	end
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = 0
	inst.components.edible.sanityvalue = 0
	inst.components.edible.foodtype = FOODTYPE.GOODIES
	inst.components.edible.foodstate = "DRINK"
	inst.components.edible:SetOnEatenFn(OnEaten)
    else
	inst:RemoveTag("fooddrink")

	inst:RemoveComponent("edible")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(.2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.3)
    inst.Light:SetColour(144/255,239/255,87/255)	

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_energyvial")
    inst.AnimState:SetBuild("sdf_energyvial")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	
    inst.AnimState:SetLightOverride(.2)

    MakeInventoryFloatable(inst, "small", 0.25)

    inst:AddTag("fooddrink")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_energyvial"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_energyvial.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_ENERGYVIAL_MAXSTACKCOUNT

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.foodstate = "DRINK"
    inst.components.edible:SetOnEatenFn(OnEaten)

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_energyvial", fn, assets)