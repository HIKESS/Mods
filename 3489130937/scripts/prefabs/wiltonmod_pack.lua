local assets =
{
	Asset("ANIM", "anim/swap_pirate_booty_bag.zip"),
	Asset("ATLAS", "images/inventoryimages/wiltonmod_pack.xml"),
}

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_pirate_booty_bag", "backpack")
	owner.AnimState:OverrideSymbol("swap_body", "swap_pirate_booty_bag", "swap_body")

    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
	owner.AnimState:ClearOverrideSymbol("backpack")

    inst.components.container:Close(owner)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("backpack")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.AnimState:SetBank("pirate_booty_bag")
    inst.AnimState:SetBuild("swap_pirate_booty_bag")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "dontstarve/creatures/together/deer/chain_idle"

    inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		--inst.OnEntityReplicated = function(inst) 
			--inst.replica.container:WidgetSetup("piggyback") 
		--end
		return inst
	end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wiltonmod_pack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/wiltonmod_pack.xml"
    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem:EnableMoisture(false)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "wiltonmod"

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("wiltonmod_pack")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("wiltonmod_equippable")

    inst:AddComponent("lootdropper")

    inst:WatchWorldState("cycles", function(inst)
        local owner = inst.components.inventoryitem.owner
        if owner and owner:HasTag("player") and inst.components.equippable:IsEquipped() then  
        inst.components.lootdropper:SpawnLootPrefab("goldnugget")
        end    
    end)
--[[
    local OldOnDropped = inst.components.inventoryitem.OnDropped
    inst.components.inventoryitem.OnDropped = function(self, randomdir, speedmult, ...)
        --if self.owner and inst.components.container:IsOpenedBy(self.owner) then
        inst.components.container:Close()
        --end 
        return OldOnDropped(self, randomdir, speedmult, ...) 
    end
]]

    inst:ListenForEvent("ondropped", function(inst)
    inst.components.container:Close()
    end)

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("wiltonmod_pack", fn, assets)