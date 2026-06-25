local prefabs =
{

}

    local assets =
    {
	Asset("ANIM", "anim/william_gadget.zip"),

    }


local function spark(inst)
                SpawnPrefab("sparks").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.sparktask = inst:DoTaskInTime(2 + math.random(), spark)
end

local function ondropped(inst)
    if inst.sparktask ~= nil then
        inst.sparktask:Cancel()
    end
    inst.sparktask = inst:DoTaskInTime(2 + math.random(), spark)
end

local function onpickup(inst)
    if inst.sparktask ~= nil then
        inst.sparktask:Cancel()
        inst.sparktask = nil
    end
end

local function OnHeal(inst, target, doer)
    if target and target:IsValid() then
        if target.SoundEmitter then
            target.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/gear_mending")
        end
        target:PushEvent("attacked", {})
    end
end

    local function fn(inst)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()


        MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("shadowheart")
    inst.AnimState:SetBuild("william_gadget")
    inst.AnimState:PlayAnimation("idle", true)
    --inst.AnimState:SetMultColour(1, 1, 1, 0.5)
    	inst.Transform:SetScale(0.85, 0.85, 0.85)	
    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst:AddTag("williamhealer")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end


    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)
    inst.components.inventoryitem.atlasname = "images/inventoryimages/williamgadget.xml"
    inst:AddComponent("inspectable")

    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(400)
    inst.components.healer:SetOnHealFn(OnHeal)

    MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("williamgadget", fn, assets, prefabs)



--------------------------------------------------------------------------
