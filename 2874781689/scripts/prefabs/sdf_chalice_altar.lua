local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_chalice_altar_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_chalice_altar_mm.tex"),

    Asset("ANIM", "anim/sdf_chalice_altar.zip"),
}

prefabs = {
}


local function updateDescriptionEmpty(inst)
    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[6])
end

local function updateDescriptionChalice(inst, newChalice, keyID)
    local description = STRINGS.ANNOUNCE_SDF_CHALICE_OF_SOULS_DESC[2]
    local prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[4]
    if keyID == 0 then
	newChalice.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_CHALICE_OF_SOULS_DESC[0])
    else
	if keyID == 1 then
	    prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[1]
	elseif keyID == 2 then
	    prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[2]
	elseif keyID == 3 then
	    prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[3]
	end
	newChalice.components.inspectable:SetDescription(""..(description).."\n-"..(inst.keyID)..""..(prefex).."-")
    end
end

local function updateDescription(inst, keyID)
    local description = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[5]
    local prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[4]
    if keyID == 0 then
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[0])
	inst.AnimState:PlayAnimation("empty", true)
    else
	if keyID == 1 then
	    prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[1]
	elseif keyID == 2 then
	    prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[2]
	elseif keyID == 3 then
	    prefex = STRINGS.ANNOUNCE_SDF_CHALICE_ALTAR_DESC[3]
    	end
	inst.AnimState:PlayAnimation("idle",true)
	inst.components.inspectable:SetDescription(""..(description).."\n-"..(inst.keyID)..""..(prefex).."-")
    end
end

local function onload(inst, data)
    inst.keyID = inst.components.sdf_chalice_id_key:GetKey()
    if inst.keyID > 0 then
	updateDescription(inst, inst.keyID)
    end
end

local ALTAR_DISABLED = false
local ALTAR_CHALICEFILLED = false --Use for ready to fill
local ALTAR_CHALICEFULL = false --Use for full chalice

local function RechargeTimeRune(inst, owner)

    --Check Rune Holder
    local runeHolder = owner.components.inventory:GetEquippedItem(EQUIPSLOTS.RUNE)
    if runeHolder ~= nil then
	local timeRune = runeHolder.components.container:GetItemInSlot(1)
	if timeRune ~= nil then
	    --check for linked
	    if timeRune.components.sdf_time_rune_epoch and timeRune.components.sdf_time_rune_epoch:HasLocation() == true then

		--Activate Time Rune
		timeRune.components.rechargeable:Discharge(TUNING.SDF_TIME_RUNE_TELEPORT_COOLDOWN)
		return
	    end
	end
    end

    --Check Inventory
    local items = owner.components.inventory:GetItemsWithTag("sdf_time_rune")
    local timeRune = nil

    for k,v in pairs(items) do
	timeRune = v
    end

    if timeRune ~= nil then

	--check for linked
	if timeRune.components.sdf_time_rune_epoch and timeRune.components.sdf_time_rune_epoch:HasLocation() == true then

	    --Activate Time Rune
	    timeRune.components.rechargeable:Discharge(TUNING.SDF_TIME_RUNE_TELEPORT_COOLDOWN)
	    return
	end
    end
end

local function ongrow(inst)
end

local function onharvest(inst, picker, produce)
    if inst.components.harvestable then
	inst.components.harvestable:SetGrowTime(nil)
	inst.components.harvestable.pausetime = nil
	inst.components.harvestable:StopGrowing()

	--removed Filled Chalice
	if inst.ALTAR_CHALICEFULL == true then
	    --Give Chalice ID
	    local x,_,z = inst.Transform:GetWorldPosition()
	    local key = inst.components.sdf_chalice_id_key:GetKey()

    	    local newChalice = SpawnPrefab("sdf_chalice_of_souls")
	    newChalice.Transform:SetPosition(x,_,z)
	    newChalice.components.sdf_chalice_id_key:SetKey(key)
	    newChalice.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" ) --added

	    updateDescriptionChalice(inst, newChalice, key)

	    SpawnPrefab("moonpulse_fx").Transform:SetPosition(x,_,z)
	    inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/portal_player")
	    inst.ALTAR_CHALICEFULL = false
	    inst.ALTAR_DISABLED = true
	    inst.AnimState:PushAnimation("empty",true) --add check for idlock
	end

	--Create Filled Chalice
	if inst.ALTAR_CHALICEFILLED == true then

	    --do fx
	    local x,_,z = inst.Transform:GetWorldPosition()
	    SpawnPrefab("ghostlyelixir_slowregen_fx").Transform:SetPosition(x,_,z)

	    --Update player chalice souls
	    picker.components.sdf_souls:DoDelta(-100)

	    --Spawn chalice
	    inst:DoTaskInTime(0.8, function()
		local x,_,z = inst.Transform:GetWorldPosition()
		SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)
		inst.ALTAR_CHALICEFILLED = false
	    	inst.ALTAR_CHALICEFULL = true
	    	inst.AnimState:PushAnimation("full",true)
	    	inst.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)

		--Update Collected Chalices
		local maxChaliceCount = picker.components.sdf_chalice_counter:GetMaxChaliceCount()
		local collectedChaliceCount = picker.components.sdf_chalice_counter:GetCollectedChaliceCount()
		picker.components.sdf_chalice_counter:SetCollectedChaliceCount(collectedChaliceCount + 1)

		--update Chalice Id Lock
		local lock = picker.components.sdf_chalice_id_lock:GetAltarLock()
	    	local key = inst.components.sdf_chalice_id_key:GetKey()
		picker.components.sdf_chalice_id_lock:SetLock(lock, key)

		updateDescriptionEmpty(inst)

		--Skill Tree Time Dilation Runesmith
		if picker.components.skilltreeupdater:IsActivated("sdf_undeath_11") then
		    RechargeTimeRune(inst, picker)
		end
            end)
	end
    end
end


local function altarturnoff(inst)
    local key = inst.components.sdf_chalice_id_key:GetKey()
    updateDescription(inst, key)

    --Drops full chalice on ground
    if inst.ALTAR_CHALICEFULL == true then
	inst.ALTAR_CHALICEFULL = false
	local x,_,z = inst.Transform:GetWorldPosition()
	local key = inst.components.sdf_chalice_id_key:GetKey()

    	local newChalice = SpawnPrefab("sdf_chalice_of_souls")
	newChalice.Transform:SetPosition(x,_,z)
	newChalice.components.sdf_chalice_id_key:SetKey(key)
	newChalice.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" ) --added
	updateDescriptionChalice(inst, newChalice, key)

	SpawnPrefab("moonpulse_fx").Transform:SetPosition(x,_,z)
	inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/portal_player")

	inst.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)
	inst.AnimState:PushAnimation("idle",true)
    end

    if inst.ALTAR_DISABLED == true then
	inst.ALTAR_DISABLED = false
	inst.AnimState:PushAnimation("idle",true)
    end

    if inst.ALTAR_CHALICEFILLED == true then
	inst.ALTAR_CHALICEFILLED = false
	inst.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)
    	local x,_,z = inst.Transform:GetWorldPosition()
    	SpawnPrefab("attune_ghost_in_fx").Transform:SetPosition(x,_,z)
        inst.AnimState:PushAnimation("idle",true)
    end
end

local function altarturnon(inst, player)
    if player.prefab == "sdf" then
	local x,_,z = inst.Transform:GetWorldPosition()

	--chalice already collected
	local lock = player.components.sdf_chalice_id_lock:GetAltarLock()
	local key = inst.components.sdf_chalice_id_key:GetKey()

	if player.components.sdf_chalice_id_lock:CheckLock(lock, key) == true then
	    inst.ALTAR_DISABLED = true
	    inst.AnimState:PushAnimation("empty", true)

	    --inspect collected update
	   updateDescriptionEmpty(inst)

	    return
	elseif key > 0 then

	    --chalice filled effect
	    local chaliceFilledPercent = player.components.sdf_souls:GetPercent()
	    if chaliceFilledPercent >= 1 then
		inst.ALTAR_CHALICEFILLED = true
		inst.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)
		inst.AnimState:PushAnimation("filled", true)
		SpawnPrefab("attune_out_fx").Transform:SetPosition(x,_,z)
	    end
	end
    end
end

local function showOnMap(inst)
    if inst.icon == nil then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon:TrackEntity(inst)
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_chalice_altar_mm.tex")
    --inst.MiniMapEntity:SetCanUseCache(false)
    --inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    local s = 1.3 --1.5
    inst.Transform:SetScale(s,s,s)
    
    MakeObstaclePhysics(inst, 1.1) --1.2

    inst.AnimState:SetBank("sdf_chalice_altar")
    inst.AnimState:SetBuild("sdf_chalice_altar")
    inst.AnimState:PlayAnimation("idle",true)

    inst:AddTag("structure")
    inst:AddTag("sdf_witch_talisman_offering")
    inst:AddTag("sdf_chalice_altar")

    --if not TheNet:IsDedicated() then
        --inst:AddComponent("pointofinterest")
        --inst.components.pointofinterest:SetHeight(200)
    --end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Assigns unlocking key for chalice collecting
    inst:AddComponent("sdf_chalice_id_key")
    inst.keyID = inst.components.sdf_chalice_id_key:GetKey()

    inst:AddComponent("harvestable")

    inst:AddComponent("named")

    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(3,3.2)
    inst.components.playerprox:SetOnPlayerNear(altarturnon)
    inst.components.playerprox:SetOnPlayerFar(altarturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnLoad = onload
    updateDescription(inst, inst.keyID)

    inst.icon = nil
    --inst:DoTaskInTime(0, showOnMap)

    return inst
end

return  Prefab("sdf_chalice_altar", fn, assets, prefabs)