local assets=
{
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_damaged.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_damaged.tex"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_inventory.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_inventory.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_friendlies.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_friendlies.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_enemies.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_enemies.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_entries_bosses.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_entries_bosses.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_book_of_gallowmere_restored_vellum.tex"),
    Asset("ATLAS", "images/inventoryimages/sdf_book_of_gallowmere_restored_vellum.xml"),

    Asset("IMAGE", "images/map_icons/sdf_book_of_gallowmere_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_book_of_gallowmere_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_book_of_gallowmere_damaged_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_book_of_gallowmere_damaged_mm.xml"),

    Asset("ANIM", "anim/sdf_book_of_gallowmere.zip"),

    Asset("IMAGE", "images/inv_slot/inv_slot_entries_inventory.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_inventory.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_entries_friendlies.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_friendlies.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_entries_enemies.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_enemies.xml"),
    Asset("IMAGE", "images/inv_slot/inv_slot_entries_bosses.tex"),
    Asset("ATLAS", "images/inv_slot/inv_slot_entries_bosses.xml"),
}

prefabs = {
}

local SpineWidgetParams =
{
    widget =
    {
	slotpos = {Vector3(126, -20, 0), Vector3(42, -20, 0), Vector3(-42, -20, 0), Vector3(-126, -20, 0)}, --{Vector3(0, -110, 0), Vector3(0, -34, 0), Vector3(0, 42, 0), Vector3(0, 118, 0)}, ---34,42,118
        slotbg =
        {
            { image = "inv_slot_entries_bosses.tex", atlas = "images/inv_slot/inv_slot_entries_bosses.xml" },
            { image = "inv_slot_entries_enemies.tex", atlas = "images/inv_slot/inv_slot_entries_enemies.xml" },
            { image = "inv_slot_entries_friendlies.tex", atlas = "images/inv_slot/inv_slot_entries_friendlies.xml" },
            { image = "inv_slot_entries_inventory.tex", atlas = "images/inv_slot/inv_slot_entries_inventory.xml" },
        },
	animbank = "ui_sdf_book_of_gallowmere_spine",
	animbuild = "ui_sdf_book_of_gallowmere_spine",
	pos = Vector3(0, -160, 0), --0,0,0

    },
    issidewidget = false,
    type = "sdf_book_of_gallowmere_spine",
}

local function SpineWidgetHUDPositionFn(self, doer)
  if not TheNet:IsDedicated() then
    local hudscaleadjust = Profile:GetHUDSize()*2
    local qs_pos = INVINFO.EQUIPSLOT_hands:GetWorldPosition() 

    if doer and doer.HUD and doer.HUD.controls then		
      if doer.HUD.controls.containers[self.inst].SpineHasAnchor == nil then
        doer.HUD.controls.containers[self.inst].SpineHasAnchor = true

        doer.HUD.controls.containers[self.inst]:SetVAnchor(ANCHOR_BOTTOM)
        doer.HUD.controls.containers[self.inst]:SetHAnchor(ANCHOR_LEFT)
      end

      if doer.HUD.controls.containers[self.inst] then
        doer.HUD.controls.containers[self.inst]:UpdatePosition(qs_pos.x, (qs_pos.y+125+hudscaleadjust))	--80
      end
    end
  end
end

function SpineWidgetParams.itemtestfn(container, item, slot)
    if slot == 1 and item:HasTag("sdf_book_of_gallowmere_entry_bosses") then
	return true
    elseif slot == 2 and item:HasTag("sdf_book_of_gallowmere_entry_enemies") then
	return true
    elseif slot == 3 and item:HasTag("sdf_book_of_gallowmere_entry_friendlies") then
	return true
    elseif slot == 4 and item:HasTag("sdf_book_of_gallowmere_entry_inventory") then
	return true
    else
	return false
    end
end

local SPINE_FIRST_OPEN = false --Use for first time spine slot opens

---------------------------------------------------------------------
local function readingRegen(inst, owner)
    if owner and owner.components.sanity then
	local totalSanityRegen = 0
	if inst.components.container:Has("sdf_book_of_gallowmere_entries_bosses", 1) then
	    local bossesSlot = inst.components.container:GetItemInSlot(1)
	    if bossesSlot then
		totalSanityRegen = totalSanityRegen + (TUNING.SDF_BOOK_OF_GALLOWMERE_SANITY_REGEN_AMOUNT * bossesSlot.components.finiteuses:GetPercent())
	    end
	end
	if inst.components.container:Has("sdf_book_of_gallowmere_entries_enemies", 1) then
	    local enemiesSlot = inst.components.container:GetItemInSlot(2)
	    if enemiesSlot then
		totalSanityRegen = totalSanityRegen + (TUNING.SDF_BOOK_OF_GALLOWMERE_SANITY_REGEN_AMOUNT * enemiesSlot.components.finiteuses:GetPercent())
	    end
	end
	if inst.components.container:Has("sdf_book_of_gallowmere_entries_friendlies", 1) then
	    local friendliesSlot = inst.components.container:GetItemInSlot(3)
	    if friendliesSlot then
		totalSanityRegen = totalSanityRegen + (TUNING.SDF_BOOK_OF_GALLOWMERE_SANITY_REGEN_AMOUNT * friendliesSlot.components.finiteuses:GetPercent())
	    end
	end
	if inst.components.container:Has("sdf_book_of_gallowmere_entries_inventory", 1) then
	    local inventorySlot = inst.components.container:GetItemInSlot(4)
	    if inventorySlot then
		totalSanityRegen = totalSanityRegen + (TUNING.SDF_BOOK_OF_GALLOWMERE_SANITY_REGEN_AMOUNT * inventorySlot.components.finiteuses:GetPercent())
	    end
	end

	--recover Sanity
	if totalSanityRegen > 0 then
	    owner.components.sanity:DoDelta(totalSanityRegen)
	end
    end
end

local function modeReadingStart(inst)
    --inst.components.equippable:SetPreventUnequipping(true)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
	inst.ReadingRegentask = inst:DoPeriodicTask(TUNING.SDF_BOOK_OF_GALLOWMERE_SANITY_REGEN_TICK, function() readingRegen(inst, owner) end)
    end
end

local function modeReadingEnd(inst)
    --inst.components.equippable:SetPreventUnequipping(false)
    if inst.ReadingRegentask ~= nil then
	inst.ReadingRegentask:Cancel()
	inst.ReadingRegentask = nil
    end
end
---------------------------------------------------------------------

local function OnPickupFn(inst, pickupguy)
    inst.AnimState:PlayAnimation("idle")
end

local function OnPutInInventoryClose(inst)
    if inst.components.container ~= nil then
	inst.components.container:Close()
    end
end

local function OnDroppedClose(inst)
    if inst.components.container ~= nil then
	inst.components.container:Close()
    end
end

local function AmmoLoaded(inst)
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_bosses", 1) then
	local bossesSlot = inst.components.container:GetItemInSlot(1)
	if bossesSlot then
	    bossesSlot:OnToggleFn()
	end
    end
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_enemies", 1) then
	local enemiesSlot = inst.components.container:GetItemInSlot(2)
	if enemiesSlot then
	    enemiesSlot:OnToggleFn()
	end
    end
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_friendlies", 1) then
	local friendliesSlot = inst.components.container:GetItemInSlot(3)
	if friendliesSlot then
	    friendliesSlot:OnToggleFn()
	end
    end
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_inventory", 1) then
	local inventorySlot = inst.components.container:GetItemInSlot(4)
	if inventorySlot then
	    inventorySlot:OnToggleFn()
	end
    end
end

local function AmmoUnloaded(inst)

end

local function OnAmmoLoaded(inst, data)
    if data ~= nil and data.item ~= nil then

	--Adds toggle
	AmmoLoaded(inst)

	data.item:PushEvent("ammoloaded", {sdf_book_of_gallowmere = inst})
    end
end

local function OnAmmoUnloaded(inst, data)

    --NA
    AmmoUnloaded(inst)

    if data ~= nil and data.prev_item ~= nil then
	data.prev_item:PushEvent("ammounloaded", {sdf_book_of_gallowmere = inst})
    end
end

local function CreateNewBook(inst)

    --create Entry Bosses
    local bossesSlot = inst.components.container:GetItemInSlot(1)
    if bossesSlot == nil then
	local createEntryBosses = SpawnPrefab("sdf_book_of_gallowmere_entries_bosses")
	--createEntryBosses.components.finiteuses:SetUses(0)
	inst.components.container:GiveItem(createEntryBosses, 1)

	inst:DoTaskInTime(0.1, function()
	    local bossesSlot = inst.components.container:GetItemInSlot(1)
	    if bossesSlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end

    --create Entry Enemies
    local enemiesSlot = inst.components.container:GetItemInSlot(2)
    if enemiesSlot == nil then
        local createEntryEnemies = SpawnPrefab("sdf_book_of_gallowmere_entries_enemies")
	--createEntryEnemies.components.finiteuses:SetUses(0)
	inst.components.container:GiveItem(createEntryEnemies, 2)

	inst:DoTaskInTime(0.1, function()
	    local enemiesSlot = inst.components.container:GetItemInSlot(2)
	    if enemiesSlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end

    --create Entry Allies
    local friendliesSlot = inst.components.container:GetItemInSlot(3)
    if friendliesSlot == nil then
	local createEntryAllies = SpawnPrefab("sdf_book_of_gallowmere_entries_friendlies")
	--createEntryAllies.components.finiteuses:SetUses(0)
	inst.components.container:GiveItem(createEntryAllies, 3)

	inst:DoTaskInTime(0.1, function()
	    local friendliesSlot = inst.components.container:GetItemInSlot(3)
	    if friendliesSlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end

    --create Entry Inventory
    local inventorySlot = inst.components.container:GetItemInSlot(4)
    if inventorySlot == nil then
	local createEntryInventory = SpawnPrefab("sdf_book_of_gallowmere_entries_inventory")
	--createEntryInventory.components.finiteuses:SetUses(0)
	inst.components.container:GiveItem(createEntryInventory, 4)

	inst:DoTaskInTime(0.1, function()
	    local inventorySlot = inst.components.container:GetItemInSlot(4)
	    if inventorySlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end
end

--Skill Tree Insight
local function CreateNewBookRestored(inst)

    --create Entry Bosses
    local bossesSlot = inst.components.container:GetItemInSlot(1)
    if bossesSlot == nil then
	local createEntryBosses = SpawnPrefab("sdf_book_of_gallowmere_entries_bosses")
	createEntryBosses.components.finiteuses:SetUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_BOSSES_TOTAL)
	inst.components.container:GiveItem(createEntryBosses, 1)

	inst:DoTaskInTime(0.1, function()
	    local bossesSlot = inst.components.container:GetItemInSlot(1)
	    if bossesSlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end

    --create Entry Enemies
    local enemiesSlot = inst.components.container:GetItemInSlot(2)
    if enemiesSlot == nil then
        local createEntryEnemies = SpawnPrefab("sdf_book_of_gallowmere_entries_enemies")
	createEntryEnemies.components.finiteuses:SetUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_ENEMIES_TOTAL)
	inst.components.container:GiveItem(createEntryEnemies, 2)

	inst:DoTaskInTime(0.1, function()
	    local enemiesSlot = inst.components.container:GetItemInSlot(2)
	    if enemiesSlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end

    --create Entry Allies
    local friendliesSlot = inst.components.container:GetItemInSlot(3)
    if friendliesSlot == nil then
	local createEntryAllies = SpawnPrefab("sdf_book_of_gallowmere_entries_friendlies")
	createEntryAllies.components.finiteuses:SetUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_FRIENDLIES_TOTAL)
	inst.components.container:GiveItem(createEntryAllies, 3)

	inst:DoTaskInTime(0.1, function()
	    local friendliesSlot = inst.components.container:GetItemInSlot(3)
	    if friendliesSlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end

    --create Entry Inventory
    local inventorySlot = inst.components.container:GetItemInSlot(4)
    if inventorySlot == nil then
	local createEntryInventory = SpawnPrefab("sdf_book_of_gallowmere_entries_inventory")
	createEntryInventory.components.finiteuses:SetUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_INVENTORY_TOTAL)
	inst.components.container:GiveItem(createEntryInventory, 4)

	inst:DoTaskInTime(0.1, function()
	    local inventorySlot = inst.components.container:GetItemInSlot(4)
	    if inventorySlot then
		--lightningSlot:OnToggleFn()
	    end
	end)
    end
end

local function onsave(inst, data)
    --data.newBook = inst.newBook
end

local function onload(inst, data)
    --Has ammo
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_bosses", 1) then
	local friendliesSlot = inst.components.container:GetItemInSlot(1)
	if friendliesSlot then
	    friendliesSlot:OnToggleFn()
	end
    end
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_enemies", 1) then
	local enemiesSlot = inst.components.container:GetItemInSlot(2)
	if enemiesSlot then
	    enemiesSlot:OnToggleFn()
	end
    end
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_friendlies", 1) then
	local friendliesSlot = inst.components.container:GetItemInSlot(3)
	if friendliesSlot then
	    friendliesSlot:OnToggleFn()
	end
    end
    if inst.components.container:Has("sdf_book_of_gallowmere_entries_inventory", 1) then
	local inventorySlot = inst.components.container:GetItemInSlot(4)
	if inventorySlot then
	    inventorySlot:OnToggleFn()
	end
    end

end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_book_of_gallowmere_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_book_of_gallowmere")
    inst.AnimState:SetBuild("sdf_book_of_gallowmere")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sdf_book_of_gallowmere")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.6, 0.58, 0.58, 0)
	inst.components.talker.offset = Vector3(0, -600, 0)
    end

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst:DoTaskInTime(0, function(inst)
	    inst.replica.container.WidgetSetup = SDF_BOOK_OF_GALLOWMERE_SPINEFUNCS.MyWidgetSetup_replica
	    inst.replica.container:WidgetSetup(inst.prefab, SpineWidgetParams)

	    local origReplicaOpen = inst.replica.container.Open
	    inst.replica.container.Open = function(self, doer)
		origReplicaOpen(self, doer)
		--SpineWidgetHUDPositionFn(self, doer)
	    end
	end)
        return inst
    end

    inst:AddComponent("container")
    inst.components.container.WidgetSetup = SDF_BOOK_OF_GALLOWMERE_SPINEFUNCS.MyWidgetSetup
    inst.replica.container.WidgetSetup = SDF_BOOK_OF_GALLOWMERE_SPINEFUNCS.MyWidgetSetup_replica
    inst.components.container:WidgetSetup(inst.prefab, SpineWidgetParams)
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    local origOpen = inst.components.container.Open
    inst.components.container.Open = function(self, doer)
	origOpen(self, doer)
	SpineWidgetHUDPositionFn(self, doer)
    end

    --Allows offer Book of Gallowmere
    inst:AddComponent("sdf_book_of_gallowmere_offering_jack_of_the_green")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem:SetOnPickupFn(OnPickupFn)
    inst.components.inventoryitem:SetOnDroppedFn(OnDroppedClose)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventoryClose)
    inst.components.inventoryitem.imagename = "sdf_book_of_gallowmere"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_book_of_gallowmere.xml"

    MakeHauntableLaunch(inst)

    inst.ReadingRegentask = nil

    inst.CreateNewBookFn = function() CreateNewBook(inst) end
    inst.CreateNewBookRestoredFn = function() CreateNewBookRestored(inst) end
    inst.ModeReadingStartFn = function() modeReadingStart(inst) end
    inst.ModeReadingEndFn = function() modeReadingEnd(inst) end

    --inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function OnPutInInventoryDamaged(inst, owner)
    inst:DoTaskInTime(0, function()
	if owner ~= nil then
	    if owner:HasTag("sdf") then
		if owner.components.sdf_key_item_inventory:GetKeyItem("sdf_book_of_gallowmere_damaged") == nil then
		    owner.components.sdf_key_item_inventory:SetKeyItem(inst, owner)
		end
	    end
	end
    end)
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_book_of_gallowmere_damaged_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_book_of_gallowmere")
    inst.AnimState:SetBuild("sdf_book_of_gallowmere")
    inst.AnimState:PlayAnimation("damaged")

    inst:AddTag("irreplaceable")

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.6, 0.58, 0.58, 0)
	inst.components.talker.offset = Vector3(0, -600, 0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --sdf Key Item
    inst:AddComponent("sdf_key_item")

    --Allows offer Book of Gallowmere Damaged
    inst:AddComponent("sdf_book_of_gallowmere_damaged_offering_jack_of_the_green")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventoryDamaged)
    inst.components.inventoryitem.imagename = "sdf_book_of_gallowmere_damaged"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_book_of_gallowmere_damaged.xml"

    MakeHauntableLaunch(inst)

    return inst
end

local function OnRead(inst, reader)
    local myContainer = inst.components.inventoryitem.owner
    if myContainer ~= nil then
	if inst.components.rechargeable:IsCharged() and myContainer.prefab == "sdf_book_of_gallowmere" then

	    --Add Book of Gallowmere data
	    if inst.prefab == "sdf_book_of_gallowmere_entries_inventory" then
		reader:AddTag("sdf_book_of_gallowmere_entries_inventory_read")
	    end
	    if inst.prefab == "sdf_book_of_gallowmere_entries_friendlies" then
		reader:AddTag("sdf_book_of_gallowmere_entries_friendlies_read")
	    end
	    if inst.prefab == "sdf_book_of_gallowmere_entries_enemies" then
		reader:AddTag("sdf_book_of_gallowmere_entries_enemies_read")
	    end
	    if inst.prefab == "sdf_book_of_gallowmere_entries_bosses" then
		reader:AddTag("sdf_book_of_gallowmere_entries_bosses_read")
	    end

	    if reader.components.sdf_book_of_gallowmere_entry then
		reader.components.sdf_book_of_gallowmere_entry:SetEntryTotal(inst.components.finiteuses:GetUses())
	    end

	    --Cooldown Animation
	    inst.components.rechargeable:Discharge(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_TOGGLE_COOLDOWN)

	    --Open Book of Gallowmere
	    reader:DoTaskInTime(0.1, function()
		reader:ShowPopUp(POPUPS.SDFBOOKOFGALLOWMERE, true)
	    end)
	end
    end
end

local function OnToggle(inst)
    inst:AddTag("sdf_book_of_gallowmere_restored_vellum_mend")

    if inst.components.simplebook then
	inst.components.simplebook.onreadfn = OnRead
    else
	inst:AddComponent("simplebook")
	inst.components.simplebook.onreadfn = OnRead
    end
end

local function OnPutInInventory(inst, owner)
    inst:DoTaskInTime(0.1, function()
	if owner ~= nil then

	    --removes toggle
	    if not owner:HasTag("sdf_book_of_gallowmere") then

		if inst:HasTag("sdf_book_of_gallowmere_restored_vellum_mend") then
		    inst:RemoveTag("sdf_book_of_gallowmere_restored_vellum_mend")
		end

		if inst.components.simplebook then
		    inst:RemoveComponent("simplebook")
		end
	   end
	else
	    if inst:HasTag("sdf_book_of_gallowmere_restored_vellum_mend") then
		inst:RemoveTag("sdf_book_of_gallowmere_restored_vellum_mend")
	    end

	    if inst.components.simplebook then
		inst:RemoveComponent("simplebook")
	    end
	end
    end)
end

local function fn3()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_book_of_gallowmere")
    inst.AnimState:SetBuild("sdf_book_of_gallowmere")
    inst.AnimState:PlayAnimation("inventory")

    inst:AddTag("book")
    inst:AddTag("sdf_book_of_gallowmere_entry_inventory")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_INVENTORY_TOTAL)
    inst.components.finiteuses:SetUses(0)
    inst.components.finiteuses.SetUses = function(self,val)
	self.current = val
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	if self.current <= 0 then
	end
    end
    inst.components.finiteuses.doesnotstartfull = true

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_book_of_gallowmere_entries_inventory"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_book_of_gallowmere_entries_inventory.xml"

    inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)

    inst.OnToggleFn = function() OnToggle(inst) end

    return inst
end

local function fn4()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_book_of_gallowmere")
    inst.AnimState:SetBuild("sdf_book_of_gallowmere")
    inst.AnimState:PlayAnimation("friendlies")

    inst:AddTag("book")
    inst:AddTag("sdf_book_of_gallowmere_entry_friendlies")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_FRIENDLIES_TOTAL)
    inst.components.finiteuses:SetUses(0)
    inst.components.finiteuses.SetUses = function(self,val)
	self.current = val
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	if self.current <= 0 then
	end
    end
    inst.components.finiteuses.doesnotstartfull = true


    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_book_of_gallowmere_entries_friendlies"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_book_of_gallowmere_entries_friendlies.xml"

    inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)

    inst.OnToggleFn = function() OnToggle(inst) end

    return inst
end

local function fn5()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_book_of_gallowmere")
    inst.AnimState:SetBuild("sdf_book_of_gallowmere")
    inst.AnimState:PlayAnimation("enemies")

    inst:AddTag("book")
    inst:AddTag("sdf_book_of_gallowmere_entry_enemies")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_ENEMIES_TOTAL)
    inst.components.finiteuses:SetUses(0)
    inst.components.finiteuses.SetUses = function(self,val)
	self.current = val
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	if self.current <= 0 then
	end
    end
    inst.components.finiteuses.doesnotstartfull = true

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_book_of_gallowmere_entries_enemies"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_book_of_gallowmere_entries_enemies.xml"

    inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)

    inst.OnToggleFn = function() OnToggle(inst) end

    return inst
end

local function fn6()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_book_of_gallowmere")
    inst.AnimState:SetBuild("sdf_book_of_gallowmere")
    inst.AnimState:PlayAnimation("bosses")

    inst:AddTag("book")
    inst:AddTag("sdf_book_of_gallowmere_entry_bosses")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SDF_BOOK_OF_GALLOWMERE_ENTRIES_BOSSES_TOTAL)
    inst.components.finiteuses:SetUses(0)
    inst.components.finiteuses.SetUses = function(self,val)
	self.current = val
    	self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
	if self.current <= 0 then
	end
    end
    inst.components.finiteuses.doesnotstartfull = true

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "sdf_book_of_gallowmere_entries_bosses"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_book_of_gallowmere_entries_bosses.xml"

    inst:AddComponent("rechargeable")

    MakeHauntableLaunch(inst)

    inst.OnToggleFn = function() OnToggle(inst) end

    return inst
end

local function fn7()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
     
    inst.AnimState:SetBank("sdf_book_of_gallowmere")
    inst.AnimState:SetBuild("sdf_book_of_gallowmere")
    inst.AnimState:PlayAnimation("vellum")

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Allows offer Book of Gallowmere Entries
    inst:AddComponent("sdf_book_of_gallowmere_restored_vellum_mend")

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.SDF_BOOK_OF_GALLOWMERE_RESTORED_VELLUM_MAXSTACKCOUNT

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sdf_book_of_gallowmere_restored_vellum"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_book_of_gallowmere_restored_vellum.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return  Prefab("common/inventory/sdf_book_of_gallowmere", fn, assets),
	Prefab("common/inventory/sdf_book_of_gallowmere_damaged", fn2, assets),
	Prefab("common/inventory/sdf_book_of_gallowmere_entries_inventory", fn3, assets),
	Prefab("common/inventory/sdf_book_of_gallowmere_entries_friendlies", fn4, assets),
	Prefab("common/inventory/sdf_book_of_gallowmere_entries_enemies", fn5, assets),
	Prefab("common/inventory/sdf_book_of_gallowmere_entries_bosses", fn6, assets),
	Prefab("common/inventory/sdf_book_of_gallowmere_restored_vellum", fn7, assets)