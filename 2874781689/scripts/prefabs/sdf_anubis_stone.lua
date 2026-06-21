local assets=
{
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_anubis_stone_empty.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_anubis_stone_empty.xml"),

    Asset("IMAGE", "images/map_icons/sdf_anubis_stone_empty_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_anubis_stone_empty_mm.xml"),

    Asset("ANIM", "anim/sdf_anubis_stone.zip"),
    Asset("ANIM", "anim/swap_sdf_anubis_stone.zip"),
    Asset("ANIM", "anim/swap_sdf_anubis_stone_empty.zip"),

    Asset("IMAGE", "images/inv_slot/inv_slot_soul_helmet.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_soul_helmet.xml"),
}

prefabs = {
}

local function SoulkeeperWidgetHUDPositionFn(self, doer)
  if not TheNet:IsDedicated() then
    local hudscaleadjust = Profile:GetHUDSize()*2
    local qs_pos = INVINFO.EQUIPSLOT_body:GetWorldPosition()

    if doer and doer.HUD and doer.HUD.controls then		
      if doer.HUD.controls.containers[self.inst].SoulkeeperHasAnchor == nil then
        doer.HUD.controls.containers[self.inst].SoulkeeperHasAnchor = true

        doer.HUD.controls.containers[self.inst]:SetVAnchor(ANCHOR_BOTTOM)
        doer.HUD.controls.containers[self.inst]:SetHAnchor(ANCHOR_LEFT)
      end

      if doer.HUD.controls.containers[self.inst] then
        doer.HUD.controls.containers[self.inst]:UpdatePosition(qs_pos.x, (qs_pos.y+150+hudscaleadjust)) --60 120
      end
    end
  end
end

local SOULKEEPER_FIRST_OPEN = false --Use for first time soulkeeper slot opens

local function OnTakeDamage(inst, damage_amount)
    inst.components.armor:Repair(damage_amount)
end

local function OnBlocked(owner, data, inst) 
    if inst.components.container:Has("sdf_soul_helmet", 1) then
	owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_nightarmour")
    else
	owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
    end
end

local function updatePlanarDef(inst)
    local updateedPlanarDef = 0

    if inst.components.container:Has("sdf_soul_helmet", 8) then
	updateedPlanarDef = 8
    elseif inst.components.container:Has("sdf_soul_helmet", 7) then
	updateedPlanarDef = 7
    elseif inst.components.container:Has("sdf_soul_helmet", 6) then
	updateedPlanarDef = 6
    elseif inst.components.container:Has("sdf_soul_helmet", 5) then
	updateedPlanarDef = 5
    elseif inst.components.container:Has("sdf_soul_helmet", 4) then
	updateedPlanarDef = 4
    elseif inst.components.container:Has("sdf_soul_helmet", 3) then
	updateedPlanarDef = 3
    elseif inst.components.container:Has("sdf_soul_helmet", 2) then
	updateedPlanarDef = 2
    elseif inst.components.container:Has("sdf_soul_helmet", 1) then
	updateedPlanarDef = 1
    end

    --update Planar Def
    inst.components.planardefense:SetBaseDefense(updateedPlanarDef * TUNING.SDF_ANUBIS_STONE_ARMOR_PLANAR_DEF)
end

local function firstGlow(inst, owner)
    --Has ammo
    if inst.components.container:Has("sdf_soul_helmet", 1) then
	inst.components.bloomer:PushBloom("Soulkeeper", "shaders/anim.ksh", 50)
    else
	inst.components.bloomer:PopBloom("Soulkeeper")
    end
end

local function OnPickupFn(inst, pickupguy)

    --Has ammo
    if inst.components.container:Has("sdf_soul_helmet", 1) then
	inst.AnimState:PlayAnimation("idle",true)
	inst.components.inventoryitem.imagename = "sdf_anubis_stone"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone.xml"

	updatePlanarDef(inst)
    else
	inst.AnimState:PlayAnimation("empty",true)
	inst.components.inventoryitem.imagename = "sdf_anubis_stone_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_empty.xml"
    end
end

local function anubisStoneRegen(inst)
    local currentDurability = inst.components.armor:GetPercent()
    if currentDurability < 1 then
	inst.components.armor:Repair(TUNING.SDF_ANUBIS_STONE_REGEN)
    end
end

local function AmmoLoaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if inst.components.container:Has("sdf_soul_helmet", 1) then
	    inst.components.inventoryitem.imagename = "sdf_anubis_stone"
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone.xml"
	    inst.AnimState:PlayAnimation("idle",true)
	    firstGlow(inst)

	    --update planar armor
	    updatePlanarDef(inst)

	if owner ~= nil then
	    if owner.components.bloomer then
		owner.components.bloomer:PushBloom("Soulkeeper", "shaders/anim.ksh", 50)
	    end

	    --enable Necro Energy
	    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if handsSlot then
		if handsSlot.prefab == "sdf_anubis_stone_necrotic_touch" then
		    handsSlot.components.aoetargeting:SetEnabled(true)
		end
	    end
	end
    end
end

local function AmmoUnloaded(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if inst.components.container:Has("sdf_soul_helmet", 1) then

	--update planar armor
	updatePlanarDef(inst)
	return
    else
	inst.components.inventoryitem.imagename = "sdf_anubis_stone_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_empty.xml"
	inst.AnimState:PlayAnimation("empty",true)
	firstGlow(inst)

	--update planar armor
	updatePlanarDef(inst)

	if owner ~= nil then
	    if owner.components.bloomer then
		owner.components.bloomer:PopBloom("Soulkeeper")
	    end

	    --disable Necro Energy
	    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	    if handsSlot then
		if handsSlot.prefab == "sdf_anubis_stone_necrotic_touch" then
		    handsSlot.components.aoetargeting:SetEnabled(false)
		end
	    end
	end
    end
end

local function OnAmmoLoaded(inst, data)
    --if inst.components.weapon ~= nil then
	if data ~= nil and data.item ~= nil then

	    --Add soulheal Anim and Attack Speed
	    AmmoLoaded(inst)

	    data.item:PushEvent("ammoloaded", {sdf_anubis_stone = inst})
	end
    --end
end

local function OnAmmoUnloaded(inst, data)
    --if inst.components.weapon ~= nil then

	--Remove soulheal Anim and Attack Speed
	AmmoUnloaded(inst)

	if data ~= nil and data.prev_item ~= nil then
	    data.prev_item:PushEvent("ammounloaded", {sdf_anubis_stone = inst})
	end
    --end
end

local function onequip(inst, owner)

    --Update Animation and AmmoLoad
    if inst.components.container:Has("sdf_soul_helmet", 1) then
	inst.AnimState:PlayAnimation("idle",true)
	inst.components.inventoryitem.imagename = "sdf_anubis_stone"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone.xml"

	--update planar armor
	updatePlanarDef(inst)

	if owner.components.bloomer then
	    owner.components.bloomer:PushBloom("Soulkeeper", "shaders/anim.ksh", 50)
	end

	--enable Necro Energy
	--Remove/Replace equiped hand and context slot
	local owner_Inventory = owner.components.inventory

	--Clear Hands slot
	local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsSlot then
	    if handsSlot.prefab ~= "sdf_anubis_stone_necrotic_touch" then
		inst:DoTaskInTime(0.1, function()

		    if handsSlot ~= nil then
		    if handsSlot.prefab == "sdf_dragon_potion_dragonbreath" then
			handsSlot:Remove()
		    else
		    owner_Inventory:DropItem(handsSlot)
		    owner_Inventory:GiveItem(handsSlot)
		    owner.AnimState:ClearOverrideSymbol("swap_object")
		    end
		    end

		    --Equip Necrotic Touch
		    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		    if handsSlot == nil then
			local anubisStoneNecroticTouch = SpawnPrefab("sdf_anubis_stone_necrotic_touch")
			owner_Inventory:Equip(anubisStoneNecroticTouch)
			anubisStoneNecroticTouch.components.aoetargeting:SetEnabled(true)
		    end
		end)
	    elseif handsSlot.prefab == "sdf_anubis_stone_necrotic_touch" then
		handsSlot.components.aoetargeting:SetEnabled(true)
	    end
	else
	    inst:DoTaskInTime(0.1, function()
		--Equip Necrotic Touch
		local anubisStoneNecroticTouch = SpawnPrefab("sdf_anubis_stone_necrotic_touch")
		owner_Inventory:Equip(anubisStoneNecroticTouch)
		anubisStoneNecroticTouch.components.aoetargeting:SetEnabled(true)
	    end)
	end
    else
	inst.AnimState:PlayAnimation("empty",true)
	inst.components.inventoryitem.imagename = "sdf_anubis_stone_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_empty.xml"

	--disable Necro Energy
	--Remove/Replace equiped hand and context slot
	local owner_Inventory = owner.components.inventory

	--Clear Hands slot
	local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if handsSlot then
	    if handsSlot.prefab ~= "sdf_anubis_stone_necrotic_touch" then
		inst:DoTaskInTime(0.1, function()

		    if handsSlot ~= nil then
		    if handsSlot.prefab == "sdf_dragon_potion_dragonbreath" then
			handsSlot:Remove()
		    else
			owner_Inventory:DropItem(handsSlot)
			owner_Inventory:GiveItem(handsSlot)
			owner.AnimState:ClearOverrideSymbol("swap_object")
		    end
		    end

		    --Equip Necrotic Touch
		    --inst:DoTaskInTime(0.1, function()
		    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		    if handsSlot == nil then
			local anubisStoneNecroticTouch = SpawnPrefab("sdf_anubis_stone_necrotic_touch")
			owner_Inventory:Equip(anubisStoneNecroticTouch)
			anubisStoneNecroticTouch.components.aoetargeting:SetEnabled(false)
		    end
		    --end)
		end)
	    elseif handsSlot.prefab == "sdf_anubis_stone_necrotic_touch" then
		handsSlot.components.aoetargeting:SetEnabled(false)
	    end
	else
	    --Equip Necrotic Touch
	    local anubisStoneNecroticTouch = SpawnPrefab("sdf_anubis_stone_necrotic_touch")
	    owner_Inventory:Equip(anubisStoneNecroticTouch)
	    anubisStoneNecroticTouch.components.aoetargeting:SetEnabled(false)
	end
    end
end

local function onunequip(inst, owner)
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    if owner.components.bloomer then
	owner.components.bloomer:PopBloom("Soulkeeper")
    end

    --Close Soulkeeper
    if inst.components.container ~= nil then
	inst.components.container:Close(owner)
    end

    --Remove necrotic touch
    local handsSlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if handsSlot and handsSlot.prefab == "sdf_anubis_stone_necrotic_touch" then
	inst:DoTaskInTime(0.1, function()
	    --check for dup anubis stone
	    local bodySlot = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.EXTRABODY1 or EQUIPSLOTS.EXTRABODY2 or EQUIPSLOTS.EXTRABODY3 or EQUIPSLOTS.BODY)
	    if bodySlot then
		if bodySlot.prefab == "sdf_anubis_stone" then
		    return
		end
	    end
	    if handsSlot ~= nil then
	    --handsSlot.components.equippable:SetPreventUnequipping(false)
	    handsSlot:Remove()
	    end
	    owner.AnimState:ClearOverrideSymbol("swap_object") --figure this out
	end)
    end
end

local function onload(inst, data)
    --Has ammo
    if inst.components.container:Has("sdf_soul_helmet", 1) then
	inst.AnimState:PlayAnimation("idle",true)
	inst.components.inventoryitem.imagename = "sdf_anubis_stone"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone.xml"
    else
	inst.AnimState:PlayAnimation("empty",true)
	inst.components.inventoryitem.imagename = "sdf_anubis_stone_empty"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_empty.xml"
    end

    --Close Soulkeeper
    if inst.components.container ~= nil then
	inst.components.container:Close()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_anubis_stone_empty_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sdf_anubis_stone")
    inst.AnimState:SetBuild("sdf_anubis_stone")
    inst.AnimState:PlayAnimation("empty",true)

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:DoTaskInTime(0, function(inst)
	    local origReplicaOpen = inst.replica.container.Open
	    inst.replica.container.Open = function(self, doer)
		origReplicaOpen(self, doer)
		SoulkeeperWidgetHUDPositionFn(self, doer)
	    end
	end)
        return inst
    end

    inst:AddComponent("bloomer")
    inst:DoTaskInTime(0.1, function(inst) firstGlow(inst) end)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sdf_anubis_stone")
    --inst.components.container.stay_open_on_hide = true
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    local origOpen = inst.components.container.Open
    inst.components.container.Open = function(self, doer)
	origOpen(self, doer)
	SoulkeeperWidgetHUDPositionFn(self, doer)
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem.imagename = "sdf_anubis_stone_empty"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_anubis_stone_empty.xml"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.SDF_ANUBIS_STONE_DURABILITY, TUNING.SDF_ANUBIS_STONE_ARMOR_DEF) --900 durability
    inst.components.armor:IsIndestructible()
    inst.components.armor.ontakedamage = OnTakeDamage
    inst.components.armor.SetCondition = function(self,amount)
	self.condition = math.min(amount, self.maxcondition)
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	if self.condition <= 0 then
	end
    end

    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(0)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst._onblocked = function(owner, data) OnBlocked(owner, data, inst) end

    inst.anubisStoneRegentask = inst:DoPeriodicTask(TUNING.SDF_ANUBIS_STONE_REGEN_TICK, function() anubisStoneRegen(inst) end)

    inst.OnLoad = onload

    return inst
end

return  Prefab("common/inventory/sdf_anubis_stone", fn, assets, prefabs)