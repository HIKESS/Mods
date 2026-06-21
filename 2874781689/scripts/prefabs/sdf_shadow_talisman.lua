local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_shadow_talisman.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_shadow_talisman.tex"),

    Asset("ATLAS", "images/map_icons/sdf_shadow_talisman_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_shadow_talisman_mm.tex"),

    Asset("ANIM", "anim/sdf_shadow_talisman.zip"),
}

prefabs = {
}

local function OnPutInInventory(inst, owner)
    inst:DoTaskInTime(0, function()
	if owner ~= nil then

	    if owner:HasTag("player") then
		--set shadow talisman buff
		inst.components.sdf_shadow_talisman_buffs:InPocket(owner)

		--start using fuel
		if inst.components.fueled:GetPercent() > 0 then
		    inst.components.fueled:StartConsuming()
		end
	    else
		--remove shadow talisman buff
		inst.components.sdf_shadow_talisman_buffs:RemoveBuffs()

		--stop using fuel
		if inst.components.fueled:GetPercent() > 0 then
		    inst.components.fueled:StopConsuming()
		 end
	    end
	end
    end)
end

local function OnDropped(inst)

    --remove shadow talisman buff
    inst.components.sdf_shadow_talisman_buffs:RemoveBuffs()

    --stop using fuel
    if inst.components.fueled:GetPercent() > 0 then
	inst.components.fueled:StopConsuming()
    end
end

local function makeHappy(inst)
    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_SHADOW_TALISMAN_NAME[1])

    inst:RemoveTag("sdf_shadow_talisman_angry")
    inst:AddTag("sdf_shadow_talisman_happy")

    inst.components.sanityaura.aura = -TUNING.SDF_SHADOW_TALISMAN_SANITY_AURA
end

local function makeAngry(inst)
    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_SHADOW_TALISMAN_NAME[0])

    inst:RemoveTag("sdf_shadow_talisman_happy")
    inst:AddTag("sdf_shadow_talisman_angry")

    inst.components.sanityaura.aura = -TUNING.SDF_SHADOW_TALISMAN_IRE_SANITY_AURA
end

local function onAddFuel(inst)
    if inst:HasTag("sdf_shadow_talisman_angry") then
	makeHappy(inst)
    end
end

local function onperish (inst, owner)
    makeAngry(inst)
end

local function sanityDrain(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
	if owner:HasTag("player") and not owner:HasTag("playerghost") then
	    if owner.components.sanity then
		if inst.active == true then
		    if inst:HasTag("sdf_shadow_talisman_happy") then
			owner.components.sanity:DoDelta(-TUNING.SDF_SHADOW_TALISMAN_SANITY_ACTIVE_DRAIN)
		    else
			owner.components.sanity:DoDelta(-TUNING.SDF_SHADOW_TALISMAN_IRE_SANITY_ACTIVE_DRAIN)
		    end
		else
		    if inst:HasTag("sdf_shadow_talisman_happy") then
			owner.components.sanity:DoDelta(-TUNING.SDF_SHADOW_TALISMAN_SANITY_ACTIVE_DRAIN)
		    else
			owner.components.sanity:DoDelta(-TUNING.SDF_SHADOW_TALISMAN_IRE_SANITY_ACTIVE_DRAIN)
		    end
		end
	    end
	end
    end
end

local function OnInit(inst)
    inst.task = nil
    if inst.components.fueled:GetPercent() > 0 then
	makeHappy(inst)
    else
	makeAngry(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddLight()
    inst.Light:SetRadius(0.25)
    inst.Light:SetFalloff(1.0)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(40/255,40/255,250/255)	

    inst.MiniMapEntity:SetIcon("sdf_shadow_talisman_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_shadow_talisman")
    inst.AnimState:SetBuild("sdf_shadow_talisman")
    inst.AnimState:PlayAnimation("idle",true)

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst:AddTag("companion")	
    inst:AddTag("soulless")
    inst:AddTag("friendlyStick")
    inst:AddTag("sdf_undeath_recharge")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    --Allows offer Shadow Talisman
    inst:AddComponent("sdf_shadow_talisman_offering_king_peregrin")

    --Allows buffs Shadow Talisman
    inst:AddComponent("sdf_shadow_talisman_buffs")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)
    inst.components.health:SetMinHealth(1)
    inst.components.health:SetInvincible(true)
    inst.components.health.canheal = false
    inst.components.health.canmurder = false

    inst:AddComponent("combat")

    inst:AddComponent("named")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst.components.inventoryitem.imagename = "sdf_shadow_talisman"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_shadow_talisman.xml"

    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.SDF_SHADOW_TALISMAN_DURATION
    inst.components.fueled:InitializeFuelLevel(0)
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:SetDepletedFn(onperish)

    inst:AddComponent("sanityaura")

    MakeHauntableLaunch(inst)

    inst.active = false
    inst.makeHappy = makeHappy
    inst.makeAngry = makeAngry
    inst.onAddFuel = onAddFuel

    inst.sanityDraintask = inst:DoPeriodicTask(TUNING.SDF_SHADOW_TALISMAN_SANITY_DRAIN_TICK, function() sanityDrain(inst) end)

    inst.task = inst:DoTaskInTime(0, OnInit)

    return inst
end

return  Prefab("common/inventory/sdf_shadow_talisman", fn, assets)