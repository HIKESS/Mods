local assets=
{
    Asset("ANIM", "anim/sdf_lifebottle.zip"),
}

prefabs = {
}

local function OnPickupFn(inst, picker)
    inst.AnimState:PlayAnimation("idle")

    if picker.prefab == "sdf" then
	local lifebottle_holder = picker.components.sdf_lifebottle_holder:GetLifebottleHolder()
	local lifebottle_holder_full = picker.components.sdf_lifebottle_holder:CheckSlots(lifebottle_holder)
	if lifebottle_holder_full == false then
	    picker.components.sdf_lifebottle_holder:AddLifebottle(picker,lifebottle_holder)

	    local x,_,z=picker.Transform:GetWorldPosition()
	    local fx = SpawnPrefab("spider_heal_target_fx")
	    fx.Transform:SetPosition(x,_,z)
	    picker.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")

	    --Remove Lifebottle
	    inst:DoTaskInTime(0.3, function()
		inst:Remove()
	     end)
	else
	    picker.components.sdf_lifebottle_holder:HealLifebottleDoDelta(picker, TUNING.SDF_LIFEBOTTLE_RECOVERY)

	    local x,_,z=picker.Transform:GetWorldPosition()
	    local fx = SpawnPrefab("spider_heal_target_fx")
	    fx.Transform:SetPosition(x,_,z)
	    picker.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")

	    --Remove Lifebottle
	    inst:DoTaskInTime(0.3, function()
		inst:Remove()
	     end)
	end
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
    inst.Light:SetRadius(.25)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.3)
    inst.Light:SetColour(144/255,239/255,87/255)	

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_lifebottle")
    inst.AnimState:SetBuild("sdf_lifebottle")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	
    inst.AnimState:SetLightOverride(.3)

    inst:AddTag("irreplaceable")

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_lifebottle"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_lifebottle.xml"


    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_lifebottle", fn, assets)