require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/dispenser.zip"),
    Asset("ANIM", "anim/dispenser_meter.zip"),
    Asset("ANIM", "anim/swap_engie_building.zip"),
    Asset("ANIM", "anim/esentry_item.zip"),
}

local prefabs =
{
    "collapse_small",
    "ehealfx",
    "scrap",
}

local fuel =
{
    twigs = 1,
    cutgrass = 1,
    log = 1,
    charcoal = .5,
}
local mineral =
{
    flint = 1,
    rocks = 1,
    nitre = .3,
    marble = .1,
}
local night =
{
    lightbulb = .2,
    wormlight = .1,
    nightmarefuel = .1,
}
local rare =
{
    goldnugget = 1,
    gunpowder = .5,
    gears = .3,
    livinglog = .1,
}

local function onbuilt(inst, builder)
    if builder and builder.engieID then
		print(builder.engieID)
		inst.dispenserID = builder.engieID
		builder:PushEvent("engiebuilding")
		if builder.components.talker ~= nil then
			builder.components.talker:Say(GetString(builder, "ANNOUNCE_DISPENSERBUILT"))
		end

		local new_name = subfmt("Dispenser built by {builder}", { builder = builder.name })
		inst.components.named:SetName(new_name)
		inst.components.entitytracker:TrackEntity("builder", builder)
    end

    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/lightning_rod_craft")
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() / 3, function()
	inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
    end)
end

local function upgrade(inst)
    if inst.upgradelevel == 30 or inst.upgradelevel == 70 then
	inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup", "sound")
        inst:DoTaskInTime(.75, function()
	    inst.SoundEmitter:KillSound("sound")
        end)
    end
    if inst.upgradelevel >= 30 and inst.upgradelevel < 70 then
	inst:AddTag("lvl2")
	inst:RemoveTag("lvl1")
		local builder = (inst.components.entitytracker and inst.components.entitytracker:GetEntity("builder")) or nil
	if builder then
		local new_name = subfmt("Dispenser built by {builder}\n ( Level 2 )", { builder = builder.name })
		inst.components.named:SetName(new_name)
	end
	inst.AnimState:PlayAnimation("upgrade2")
	inst.AnimState:PushAnimation("idle_2", true)
    end
    if inst.upgradelevel >= 70 then
	inst:AddTag("lvl3")
	inst:RemoveTag("lvl1")
	inst:RemoveTag("lvl2")
--	inst.components.named:SetName("Dispenser\n ( Level 3 )")
		local builder = (inst.components.entitytracker and inst.components.entitytracker:GetEntity("builder")) or nil
	if builder then
		local new_name = subfmt("Dispenser built by {builder}\n ( Level 3 )", { builder = builder.name })
		inst.components.named:SetName(new_name)
	end
	inst.AnimState:PlayAnimation("upgrade3")
	inst.AnimState:PushAnimation("idle_3", true)
	inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY
    end
end

local function setmeterlevl(inst)
    if inst.components.fueled.currentfuel == 0 then
	inst.AnimState:OverrideSymbol("placer", "dispenser_meter", "0")
    end
    if inst.components.fueled.currentfuel == 1 then
	inst.AnimState:OverrideSymbol("placer", "dispenser_meter", "25")
    end
    if inst.components.fueled.currentfuel == 2 then
	inst.AnimState:OverrideSymbol("placer", "dispenser_meter", "50")
    end
    if inst.components.fueled.currentfuel == 3 then
	inst.AnimState:OverrideSymbol("placer", "dispenser_meter", "75")
    end
    if inst.components.fueled.currentfuel == 4 then
	inst.AnimState:OverrideSymbol("placer", "dispenser_meter", "100")
    end
end

local function IsScrap(item)
    return item.prefab == "scrap"
end

local function workup(inst, worker)
    local scrapstack = worker.components.inventory:FindItem(IsScrap)
    if scrapstack ~= nil then
	worker.components.inventory:ConsumeByName("scrap", 1)
	inst.upgradelevel = inst.upgradelevel + 1
	if inst.upgradelevel == 30 or inst.upgradelevel == 70 then
	    upgrade(inst)
	end
    end
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
	if inst.healfx then
    inst.healfx:Remove()
	end
    for k,v in pairs(Ents) do
	if v and v.engieID == inst.dispenserID then
	    v:PushEvent("engiebuilding")
		if v.components.sanity ~= nil then
		v.components.sanity:DoDelta(-TUNING.ENGIE_BUILDINGLOSS)
		end
		if v.components.talker ~= nil then
        v.components.talker:Say(GetString(v, "ANNOUNCE_DISPENSER_DOWN"))
		end
	end
    end
end

local function onhit(inst, worker)
    if not (worker:HasTag("engie") or worker:HasTag("spy") or worker:HasTag("engie_pardner")) then
	inst.components.workable:SetWorkLeft(6)
--	return
    end
    setmeterlevl(inst)
    if inst:HasTag("lvl1") then
	inst.AnimState:PlayAnimation("hit")
    end
    if inst:HasTag("lvl2") then
	inst.AnimState:PlayAnimation("hit_2")
    end
    if inst:HasTag("lvl3") then
	inst.AnimState:PlayAnimation("hit_3")
    end
    if worker.replica.inventory ~= nil and worker.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and worker.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).prefab == "tf2wrench" then
	worker.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS).components.finiteuses:Use(1)
	inst.components.workable:SetWorkLeft(6)
	local scrapstack = worker.components.inventory:FindItem(IsScrap)
	if scrapstack ~= nil and inst.components.fueled.currentfuel ~= inst.components.fueled.maxfuel then
	    worker.components.inventory:ConsumeByName("scrap", 1)
	    if inst.components.fueled.currentfuel < inst.components.fueled.maxfuel then
		inst.SoundEmitter:PlaySound("dontstarve/common/birdcage_craft")
		inst.components.fueled.currentfuel = inst.components.fueled.currentfuel + 1
		setmeterlevl(inst)
		return
	    end
	end
	if not inst:HasTag("NOLEVEL") then
	    inst.tick = 0
            while inst.tick ~= 5 and not inst:HasTag("lvl3") do
                workup(inst, worker)
	            inst.tick = inst.tick + 1
            end
	end
    end
end

local function dispenseitem(inst, phase, cavephase)
    local item = nil
    if inst.components.fueled.currentfuel ~= 0 then
        inst:DoTaskInTime(5, function()
	    if inst:HasTag("lvl1") then
	        if TheWorld.state.isday then
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    item = weighted_random_choice(fuel)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    item = weighted_random_choice(mineral)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    if math.random() < .33 then
			inst.components.lootdropper:SpawnLootPrefab("scrap")
		    end
		    inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		    inst.components.fueled.currentfuel = inst.components.fueled.currentfuel - 1
		    inst.AnimState:PlayAnimation("hit")
		    setmeterlevl(inst)
    	        end
	    end
	    if inst:HasTag("lvl2") then
	        if TheWorld.state.isday then
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    item = weighted_random_choice(fuel)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    item = weighted_random_choice(mineral)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    if math.random() < .33 then
			inst.components.lootdropper:SpawnLootPrefab("scrap")
			inst.components.lootdropper:SpawnLootPrefab("scrap")
		    end
		    inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		    inst.components.fueled.currentfuel = inst.components.fueled.currentfuel - 1
		    inst.AnimState:PlayAnimation("hit_2")
		    setmeterlevl(inst)
    	        end
	        if TheWorld.state.isdusk then
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    item = weighted_random_choice(fuel)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    item = weighted_random_choice(mineral)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    if math.random() < .33 then
			inst.components.lootdropper:SpawnLootPrefab("scrap")
			inst.components.lootdropper:SpawnLootPrefab("scrap")
		    end
		    inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
	            inst.components.fueled.currentfuel = inst.components.fueled.currentfuel - 1
		    inst.AnimState:PlayAnimation("hit_2")
		    setmeterlevl(inst)
    	        end
	    end
	    if inst:HasTag("lvl3") then
	        if TheWorld.state.isday then
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    item = weighted_random_choice(fuel)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    item = weighted_random_choice(mineral)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    if math.random() < .33 then
		        item = weighted_random_choice(rare)
			inst.components.lootdropper:SpawnLootPrefab(item)
		    end
		    inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		    inst.components.fueled.currentfuel = inst.components.fueled.currentfuel - 1
		    inst.AnimState:PlayAnimation("hit_3")
		    setmeterlevl(inst)
    	        end
	        if TheWorld.state.isdusk then
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    item = weighted_random_choice(fuel)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    item = weighted_random_choice(mineral)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    if math.random() < .33 then
		        item = weighted_random_choice(rare)
			inst.components.lootdropper:SpawnLootPrefab(item)
		    end
		    inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		    inst.components.fueled.currentfuel = inst.components.fueled.currentfuel - 1
		    inst.AnimState:PlayAnimation("hit_3")
		    setmeterlevl(inst)
    	        end
	        if TheWorld.state.isnight then
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    inst.components.lootdropper:SpawnLootPrefab("scrap")
		    item = weighted_random_choice(fuel)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    item = weighted_random_choice(mineral)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    inst.components.lootdropper:SpawnLootPrefab(item)
		    if math.random() < .33 then
			item = weighted_random_choice(night)
			inst.components.lootdropper:SpawnLootPrefab(item)
			inst.components.lootdropper:SpawnLootPrefab(item)
		        item = weighted_random_choice(rare)
			inst.components.lootdropper:SpawnLootPrefab(item)
		    end
		    inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
		    inst.components.fueled.currentfuel = inst.components.fueled.currentfuel - 1
		    inst.AnimState:PlayAnimation("hit_3")
		    setmeterlevl(inst)
	        end
	    end
        end)
    end
end

local function onsave(inst, data)
    data.upgradelevel = inst.upgradelevel
    data.dispenserID = inst.dispenserID
end

local function onload(inst, data)
    inst.upgradelevel = data.upgradelevel 
    upgrade(inst)
    setmeterlevl(inst)
    inst.dispenserID = data.dispenserID
end

local function oninit(inst)
    setmeterlevl(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    inst.healfx = SpawnPrefab("ehealfx")
    inst.healfx.Transform:SetPosition(x,1,z)
    inst.healfx:Hide()
	local follower = inst.healfx.entity:AddFollower()
    follower:FollowSymbol(inst.GUID, "placer", 205, 140, 1)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
	
	if TheWorld:HasTag("cave") then
	inst:WatchWorldState("cavephase", dispenseitem)
    end
    if not TheWorld:HasTag("cave") then
	inst:WatchWorldState("phase", dispenseitem)
    end

	if owner.components.talker ~= nil then
	owner.components.talker:Say(GetString(owner, "ANNOUNCE_REPLANTING"))
	end
    inst.SoundEmitter:PlaySound("dontstarve/common/lightning_rod_craft")

	if inst:HasTag("lvl1") then
	inst.AnimState:PlayAnimation("place")
    end
    if inst:HasTag("lvl2") then
	inst.AnimState:PlayAnimation("upgrade2")
    end
    if inst:HasTag("lvl3") then
	inst.AnimState:PlayAnimation("upgrade2")
	inst.AnimState:PlayAnimation("upgrade3", false)
    end
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "swap_engie_building", "swap_body")

    if TheWorld:HasTag("cave") then
	inst:StopWatchingWorldState("cavephase", dispenseitem)
    end
    if not TheWorld:HasTag("cave") then
	inst:StopWatchingWorldState("phase", dispenseitem)
    end

    if inst.healfx then
	inst.healfx:Hide()
	end
	inst.Light:Enable(false)

    if owner.components.health ~= nil and
    not owner.components.health:IsDead() then
	owner.components.talker:Say(GetString(owner, "ANNOUNCE_PACKINGUP"))
	end
end

local function onnear(inst, guy)
inst:DoPeriodicTask(1, function()
	local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TUNING.DISP_RANGE, true)
    for i,guy in ipairs(players)do
	if guy ~= nil and guy.player_classified ~= nil then

	if guy.replica.inventory ~= nil and guy.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY) ~= nil and guy.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY).prefab == "dispenser" then
        guy.player_classified.issleephealing:set(false)
	return
	else
		if (guy and guy:HasTag("player") and guy.components.health) then
			if guy.components.health.currenthealth ~= guy.components.health.maxhealth then
				inst.healfx:Show()
				inst.Light:Enable(true)
				guy.player_classified.issleephealing:set(true)
			else
				guy.player_classified.issleephealing:set(false)
			end
		end
	end

	end
	end
end)
end

local function onfar(inst, guy)
	local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TUNING.DISP_RANGE+2, true)
    for i,guy in ipairs(players)do

	if (guy and guy:HasTag("player") and guy.components.health) and not (guy:HasTag("hassleeper") or guy.components.debuffable:HasDebuff("wintersfeastbuff") or guy.replica.inventory:EquipHasTag("regen")) then
		if guy ~= nil and guy.player_classified ~= nil then
			guy.player_classified.issleephealing:set(false)
		end
	end

	end

	if inst.healfx then
		inst.healfx:Hide()
	end
	inst.Light:Enable(false)
end

local function onremoved(inst)
	for k,v in pairs(Ents) do
	if v and v.engieID == inst.dispenserID then
	    v:PushEvent("engiebuilding")
		onfar(inst, v)
	end
    end

	if inst.healfx then
    inst.healfx:Remove()
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.no_wet_prefix = true

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst.MiniMapEntity:SetIcon("dispenser.tex")

    inst:AddTag("structure")
    inst:AddTag("eyeturret")
    inst:AddTag("dispenser")
	inst:AddTag("ebuild_wrenchable")
    inst:AddTag("lvl1")
    inst:AddTag("ebuild")
	inst:AddTag("nonpotatable")
    inst:AddTag("heavy")

    inst.AnimState:SetBank("dispenser")
    inst.AnimState:SetBuild("dispenser")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("placer", "dispenser_meter", "100")

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("named")
	inst:AddComponent("entitytracker")-- This is for unique names, not IDs

    inst:AddComponent("engieworkable")
    inst.components.engieworkable:SetWorkAction(ACTIONS.ENGIEWORKABLE)
	
    inst.Light:Enable(false)
    inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,62/255,12/255)
	
    inst:AddComponent("sanityaura")
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.PIGTORCH
    inst.components.fueled:InitializeFuelLevel(4)
    inst.components.fueled.accepting = false

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
--    inst.components.workable:SetMaxWork(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

	inst:ListenForEvent("onremove", onremoved)

	inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("swap_engie_building", "swap_body")	

    inst.upgradelevel = 0

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnBuiltFn = onbuilt

	inst:DoTaskInTime(0, oninit)

	---------------------------------------
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = ENGINEERITEMIMAGES
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:SetSinks(true)
	inst.components.inventoryitem.imagename = "esentry_item"	
--	inst.components.inventoryitem.atlasname = "images/inventoryimages/esentry_item.xml"

	inst:AddComponent("heavyobstaclephysics")
    inst.components.heavyobstaclephysics:SetRadius(1)
    inst.components.heavyobstaclephysics:MakeSmallObstacle()

	inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.TOOLBOX_SPEED_MULT
	inst.components.equippable.restrictedtag = "engie"
    ---------------------------------------
	
	inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(TUNING.DISP_RANGE, TUNING.DISP_RANGE)
    inst.components.playerprox.onnear = onnear
    inst.components.playerprox.onfar = onfar
	inst.components.playerprox:SetPlayerAliveMode(true)

	inst:DoPeriodicTask(TUNING.DISP_HEALING, function()
    FindEntity(inst, TUNING.DISP_RANGE, function(guy)
	if guy.replica.inventory ~= nil and guy.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY) ~= nil and guy.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY).prefab == "dispenser" then
	return
	else
		if (guy and guy:HasTag("player") and guy.components.health) or (guy and guy.components.follower and guy.components.follower.leader ~= nil and guy.components.follower.leader:HasTag("player")) then
	    if guy.components.health ~= nil and guy.components.health.currenthealth ~= guy.components.health.maxhealth and not guy.components.health:IsDead() then
		    if inst:HasTag("lvl1") then
			guy.components.health:DoDelta(1, true, nil, true)
		    end
		    if inst:HasTag("lvl2") then
			guy.components.health:DoDelta(2, true, nil, true)
		    end
		    if inst:HasTag("lvl3") then
			guy.components.health:DoDelta(3, true, nil, true)
		    end
	    end
		end
	end
	end)
	end)

    if TheWorld:HasTag("cave") then
	inst:WatchWorldState("cavephase", dispenseitem)
    end
    if not TheWorld:HasTag("cave") then
	inst:WatchWorldState("phase", dispenseitem)
    end

    MakeHauntableFreeze(inst) 

    return inst
end

local function healfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.AnimState:SetBank("fireflies")
    inst.AnimState:SetBuild("fireflies")
    inst.AnimState:PlayAnimation("swarm_pre")
    inst.AnimState:PushAnimation("swarm_loop", true)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.AnimState:SetMultColour( 200/255, 50/255, 50/255, 1 )

    return inst
end

return Prefab("common/dispenser", fn, assets, prefabs),
	Prefab("ehealfx", healfxfn, assets)--,
--	MakePlacer("common/dispenser_placer", "esentry_item", "esentry_item", "idle")