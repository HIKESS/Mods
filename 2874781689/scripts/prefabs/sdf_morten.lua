local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_morten.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_morten.tex"),

    Asset("ANIM", "anim/sdf_morten.zip"),
    Asset("ANIM", "anim/sdf_oceanfishing_lure_morten.zip"),
}

prefabs = {
}

local function OnDropped(inst)
    inst.components.inventoryitem.cangoincontainer = false

    inst:DoTaskInTime(0.5, function()
	inst.AnimState:PlayAnimation("squirm")
	inst.SoundEmitter:PlaySound("dontstarve/creatures/slurper/taunt")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_MORTEN_MAD, 1.5)
    end)
    inst:DoTaskInTime(1.0, function()
	inst.AnimState:PlayAnimation("squirm")
	inst.SoundEmitter:PlaySound("dontstarve/creatures/slurper/taunt")
    end)
    inst:DoTaskInTime(2, function()
	local x,_,z = inst.Transform:GetWorldPosition()
	SpawnPrefab("sand_puff").Transform:SetPosition(x,_,z)
	inst:Remove()
    end)
end

local function DropMorten(inst)
    local myContainer = inst.components.inventoryitem:GetContainer()
    if myContainer ~= nil then
	myContainer:DropItem(inst)
    else
	inst:Remove()
    end
end

local function OnPutInInventory(inst, owner)
    inst:DoTaskInTime(0.1, function()
	if owner ~= nil then

	    --Changes icon normal and baited
	    if owner:HasTag("accepts_oceanfishingtackle") then
		inst.components.inventoryitem.imagename = "sdf_morten_baited"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_morten_baited.xml"
	    else
		inst.components.inventoryitem.imagename = "sdf_morten"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_morten.xml"
	    end

	    --removes morten from fishingrod or Sdf No Skill Tree Skull or not Sdf
	    if owner.components.inventoryitem then
		local myOwner = owner.components.inventoryitem:GetGrandOwner()
		if myOwner.prefab == "sdf" then
		    if not myOwner.components.skilltreeupdater:IsActivated("sdf_skull_5") then
			DropMorten(inst)
		    end
		end
	    elseif owner.prefab == "sdf" then
		if not owner.components.skilltreeupdater:IsActivated("sdf_skull_5") then
		    DropMorten(inst)
		end
	    else
		DropMorten(inst)
	    end
	else
	    DropMorten(inst)
	end
    end)
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()


    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_morten")
    inst.AnimState:SetBuild("sdf_morten")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("oceanfishing_lure")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
        inst.components.talker.fontsize = 14
        inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.81, 0.31, 0.48, 0)
	inst.components.talker.offset = Vector3(0, -100, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_morten"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_morten.xml"

    inst:AddComponent("oceanfishingtackle")
    inst.components.oceanfishingtackle:SetupLure({build = "sdf_oceanfishing_lure_morten", symbol = "hook_morten", single_use = false, lure_data = TUNING.SDF_SKILLSET_SKULL_MORTEN_OCEANFISHING_LURE})

    inst:AddComponent("follower")
    inst.components.follower.keepdeadleader = true

    inst.persists = false

    return inst
end

return  Prefab("common/inventory/sdf_morten", fn, assets)