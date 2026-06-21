local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_statue_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_statue_mm.tex"),

    Asset("ANIM", "anim/sdf_statue.zip"),
}

prefabs = {
}

local STATUE_ACTIVATE = false --Use for chalice exchange
local STATUE_ACTIVATOR = nil
local GOLDARMORREADY = false --use for learning Gold Armor

local function ongrow(inst)
end

local function onharvest(inst, picker, produce)
    if picker == nil or inst.STATUE_ACTIVATOR == nil or picker ~= inst.STATUE_ACTIVATOR then
	return
    end

    if inst.components.harvestable and inst.STATUE_ACTIVATE == true then
	inst.components.harvestable:SetGrowTime(nil)
	inst.components.harvestable.pausetime = nil
	inst.components.harvestable:StopGrowing()

	--Skill Tree Valor
	if inst.GOLDARMORREADY == true and picker.components.skilltreeupdater:IsActivated("sdf_backbone_4") then

	    --do fx
	    SpawnPrefab("fx_book_light_upgraded").Transform:SetPosition(inst.Transform:GetWorldPosition())
	    SpawnPrefab("fx_book_light_upgraded").Transform:SetPosition(picker.Transform:GetWorldPosition())

	    picker.sg:GoToState("sdf_hero_status")

	    --Gold Armor Reward for all chalices collected.
	    inst:DoTaskInTime(1.5, function()
		inst.GOLDARMORREADY = false
		inst:RemoveComponent("harvestable")

		inst.AnimState:PushAnimation("hero")
		inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_STATUE_QUOTES[11])

	    	local x,_,z = picker.Transform:GetWorldPosition()
		SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)

		inst:DoTaskInTime(0.4, function()
		    SpawnPrefab("spawn_fx_medium_static").Transform:SetPosition(x,_,z)

		    inst:DoTaskInTime(0.6, function()
			--Enable Hero Status and Equip Gold Armor
			picker.components.sdf_chalice_id_lock:EnableHeroStatus()
			picker:AddTag("sdf_hero")

			--unlock trade at vender
			picker.components.sdf_chalice_id_lock:EnableTrade("sdf_gold_armor")
			picker.components.sdf_chalice_id_lock:CreateTradeTags(picker)

			local picker_Inventory = picker.components.inventory
			local bodySlot = picker.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
			if bodySlot then
			    inst:DoTaskInTime(0.1, function()
				picker_Inventory:DropItem(bodySlot)
				picker_Inventory:GiveItem(bodySlot)

				local bodySlot = picker.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
				if bodySlot == nil then
				    local goldArmor_id = math.random()
				    local goldArmor = SpawnPrefab("sdf_gold_armor")
				    picker.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)
				    goldArmor.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)

				    --Destory all old Gold Armor
				    local oldGoldArmor = picker.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_armor")
				    if oldGoldArmor ~= nil then
					picker.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldArmor)
				    end

				    --create ID
				    picker.components.sdf_key_item_inventory:SetKeyItem(goldArmor, picker)
				    picker_Inventory:Equip(goldArmor)
				end
			    end)
			else
			    inst:DoTaskInTime(0.1, function()
				local goldArmor_id = math.random()
				local goldArmor = SpawnPrefab("sdf_gold_armor")
				picker.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)
				goldArmor.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)

				--Destory all old Gold Armor
				local oldGoldArmor = picker.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_armor")
				if oldGoldArmor ~= nil then
				    picker.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldArmor)
				end

				--create ID
				picker.components.sdf_key_item_inventory:SetKeyItem(goldArmor, picker)
				picker_Inventory:Equip(goldArmor)
			    end)
			end

			--Gold Armor Description
			inst:DoTaskInTime(2, function()
			    --picker.components.sdf_chalice_id_lock:GiveGoodLightningSample()
			    picker.components.talker:Say(GetString(picker, "ANNOUNCE_SDF_HERO_ENABLED"))
			end)
			inst:DoTaskInTime(6, function()
				picker.components.talker:Say(GetString(picker, "ANNOUNCE_SDF_HERO_ENABLED2"))
			end)
		    end)
		end)
            end)

	--Create Filled Chalice
	elseif inst.GOLDARMORREADY == true then

	    --do fx
	    SpawnPrefab("fx_book_light_upgraded").Transform:SetPosition(inst.Transform:GetWorldPosition())
	    SpawnPrefab("fx_book_light_upgraded").Transform:SetPosition(picker.Transform:GetWorldPosition())

	    picker.sg:GoToState("sdf_hero_status")

	    --Gold Armor Reward for all chalices collected.
	    inst:DoTaskInTime(1.5, function()
		inst.GOLDARMORREADY = false
		inst:RemoveComponent("harvestable")

		inst.AnimState:PushAnimation("hero")
		inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_STATUE_QUOTES[11])

	    	local x,_,z = picker.Transform:GetWorldPosition()
		SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)

		inst:DoTaskInTime(0.4, function()
		    SpawnPrefab("spawn_fx_medium_static").Transform:SetPosition(x,_,z)

		    inst:DoTaskInTime(0.6, function()
			--Enable Hero Status and Equip Gold Armor
			picker.components.sdf_chalice_id_lock:EnableHeroStatus()
			picker:AddTag("sdf_hero")

			--unlock trade at vender
			picker.components.sdf_chalice_id_lock:EnableTrade("sdf_gold_armor")
			picker.components.sdf_chalice_id_lock:CreateTradeTags(picker)

			local picker_Inventory = picker.components.inventory
			local bodySlot = picker.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
			if bodySlot then
			    inst:DoTaskInTime(0.1, function()
				picker_Inventory:DropItem(bodySlot)
				picker_Inventory:GiveItem(bodySlot)

				local bodySlot = picker.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
				if bodySlot == nil then
				    local goldArmor_id = math.random()
				    local goldArmor = SpawnPrefab("sdf_gold_armor")
				    picker.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)
				    goldArmor.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)

				    --Destory all old Gold Armor
				    local oldGoldArmor = picker.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_armor")
				    if oldGoldArmor ~= nil then
					picker.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldArmor)
				    end

				    --create ID
				    picker.components.sdf_key_item_inventory:SetKeyItem(goldArmor, picker)
				    picker_Inventory:Equip(goldArmor)
				end
			    end)
			else
			    inst:DoTaskInTime(0.1, function()
				local goldArmor_id = math.random()
				local goldArmor = SpawnPrefab("sdf_gold_armor")
				picker.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)
				goldArmor.components.sdf_superarmor:SetGoldArmorId(goldArmor_id)

				--Destory all old Gold Armor
				local oldGoldArmor = picker.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_armor")
				if oldGoldArmor ~= nil then
				    picker.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldArmor)
				end

				--create ID
				picker.components.sdf_key_item_inventory:SetKeyItem(goldArmor, picker)
				picker_Inventory:Equip(goldArmor)
			    end)
			end

			--Gold Armor Description
			inst:DoTaskInTime(2, function()
			    --picker.components.sdf_chalice_id_lock:GiveGoodLightningSample()
			    picker.components.talker:Say(GetString(picker, "ANNOUNCE_SDF_HERO_ENABLED"))
			end)
			inst:DoTaskInTime(6, function()
				picker.components.talker:Say(GetString(picker, "ANNOUNCE_SDF_HERO_ENABLED2"))
			end)
			--inst:DoTaskInTime(10, function()
			    --picker.components.talker:Say(GetString(picker, "ANNOUNCE_SDF_HERO_ENABLED3"))
			--end)

			--Reset all locks
			local chaliceLock = picker.components.sdf_chalice_id_lock:GetLock()
			local altarLock = picker.components.sdf_chalice_id_lock:GetAltarLock()
			picker.components.sdf_chalice_id_lock:ResetLocks(chaliceLock)
			picker.components.sdf_chalice_id_lock:ResetLocks(altarLock)

			--Skill Tree Valor Lock 2
			if TheGenericKV:GetKV("sdf_super_armour_collected") == "1" then
			else
			    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, picker.userid, "sdf_super_armour_collected")
			end
		    end)
		end)
            end)
	end
    end
end

local function statueturnoff(inst)
    if inst.STATUE_ACTIVATE == true then
	inst.STATUE_ACTIVATE = false
	inst.STATUE_ACTIVATOR = nil
	inst.GOLDARMORREADY = false
	inst:RemoveTag("sdf_witch_talisman_offering")
	if inst.components.harvestable then
	    inst:RemoveComponent("harvestable")
	end

	--Effect
    	local x,_,z = inst.Transform:GetWorldPosition()
    	SpawnPrefab("ghostflower_spirit1_fx").Transform:SetPosition(x,_,z)
	inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_STATUE_QUOTES[0])
	inst.AnimState:PlayAnimation("idle_1")
    end
end

local function statueturnon(inst, player)
    if player.prefab == "sdf" then

	--One time gold armor creation
	local heroEnabled = player.components.sdf_chalice_id_lock:CheckHeroStatus()
	local chaliceLock = player.components.sdf_chalice_id_lock:GetLock()
	local chaliceAllCollected = player.components.sdf_chalice_id_lock:CheckLocks(chaliceLock)

	--Skill Tree Valor
	if heroEnabled == false and player.components.skilltreeupdater:IsActivated("sdf_backbone_4") == true then
	    inst.STATUE_ACTIVATE = true
	    inst.GOLDARMORREADY = true
	    inst.STATUE_ACTIVATOR = player
	    inst:AddComponent("harvestable")
	    inst.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)

	    --Effect
	    local x,_,z = inst.Transform:GetWorldPosition()
	    SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)

	elseif heroEnabled == false and chaliceAllCollected == true then
	    inst.STATUE_ACTIVATE = true
	    inst.GOLDARMORREADY = true
	    inst.STATUE_ACTIVATOR = player
	    inst:AddComponent("harvestable")
	    inst.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)

	    --Effect
	    local x,_,z = inst.Transform:GetWorldPosition()
	    SpawnPrefab("farm_plant_happy").Transform:SetPosition(x,_,z)

	elseif heroEnabled == true then
	    inst.STATUE_ACTIVATE = true
	    inst:AddTag("sdf_witch_talisman_offering")

	    --Effect
	    local x,_,z = inst.Transform:GetWorldPosition()
	    SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(x,_,z)
	    inst.AnimState:PushAnimation("hero")
	end
    end
end

local function setstatuetype(inst, typeid)
    typeid = typeid
    if typeid ~= inst.typeid then
        inst.typeid = typeid

	--Setup Model
        inst.AnimState:PlayAnimation("idle_"..typeid.."")

	--Setup Hero Statue
	if typeid == 1 then
	    inst:AddTag("sdf_statue_sdf")
	    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
	    inst:AddComponent("playerprox")
	    inst.components.playerprox:SetDist(1.6,1.8)
	    inst.components.playerprox:SetOnPlayerNear(statueturnon)
	    inst.components.playerprox:SetOnPlayerFar(statueturnoff)
	end
    end
end

local function onload(inst, data, newents)
    if data then
        if data.setname then
            --this handles custom name set in the tile editor
	    inst.components.named:SetName("'"..data.setname.."'")
            inst.setname = data.setname
        end
    end
    if data ~= nil and data.typeid ~= nil then
        setstatuetype(inst, data.typeid)
    end
end

local function onsave(inst, data)
    data.setname = inst.setname
    data.typeid = inst.typeid

    local ents = {}
    if inst.ghost ~= nil then
        data.ghost_id = inst.ghost.GUID
        table.insert(ents, data.ghost_id)
    end

    return ents
end

-- Ghosts on a quest (following someone) shouldn't block other ghost spawns!
local MUSTHAVE_GHOST_TAGS = {"sdf_king_peregrin"}
local function on_day_change(inst)
    if inst.ghost == nil or not inst.ghost:IsValid() and #AllPlayers > 0 then
        local ghost_spawn_chance = 0
        for _, v in ipairs(AllPlayers) do
	    --SDF spawn with crown
            if (v:HasTag("sdf") and (v.components.inventory and v.components.inventory:Has("sdf_king_peregrins_crown_lost", 1, true))) then
                ghost_spawn_chance = ghost_spawn_chance + 1
	    elseif (v:HasTag("sdf") and (v.components.inventory and v.components.inventory:Has("sdf_king_peregrins_crown", 1, true)) and (v.components.sdf_king_peregrin_quest and v.components.sdf_king_peregrin_quest:GetCrownOfferedStatus() == true)) then
                ghost_spawn_chance = ghost_spawn_chance + 1
	    elseif v:HasTag("ghostlyfriend") then
                ghost_spawn_chance = ghost_spawn_chance + (TUNING.SDF_KING_PEREGRIN_GHOST_CHANCE)

                if v.components.skilltreeupdater and v.components.skilltreeupdater:IsActivated("wendy_smallghost_1") then
                    ghost_spawn_chance = ghost_spawn_chance + TUNING.WENDYSKILL_SMALLGHOST_EXTRACHANCE
                end
            end
        end
        ghost_spawn_chance = math.max(ghost_spawn_chance, 0)

        if math.random() < ghost_spawn_chance then
            local gx, gy, gz = inst.Transform:GetWorldPosition()
            local nearby_ghosts = TheSim:FindEntities(gx, gy, gz, TUNING.SDF_KING_PEREGRIN_UNIQUE_GHOST_DISTANCE, MUSTHAVE_GHOST_TAGS, {})
            if #nearby_ghosts == 0 then
                inst.ghost = SpawnPrefab("sdf_king_peregrin")
                inst.ghost.Transform:SetPosition(gx + 0.3, gy, gz + 0.3)
                inst.ghost:LinkToHome(inst)
            end
        end
    end
end

local function onloadpostpass(inst, newents, savedata)
    inst.ghost = nil
    if savedata ~= nil then
        if savedata.ghost_id ~= nil and newents[savedata.ghost_id] ~= nil then
            inst.ghost = newents[savedata.ghost_id].entity
	    inst.ghost:LinkToHome(inst)
        end
    end
end

local function OnHaunt(inst)
    return true
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


    inst.MiniMapEntity:SetIcon("sdf_statue_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    local s = 1.0 --1.5
    inst.Transform:SetScale(s,s,s)
    
    MakeObstaclePhysics(inst, 0.66) --0.66
     
    inst.AnimState:SetBank("sdf_statue")
    inst.AnimState:SetBuild("sdf_statue")
    inst.AnimState:PlayAnimation("idle_0")

    inst:AddTag("sdf_statue")

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

    inst:AddComponent("named")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:WatchWorldState("cycles", on_day_change)

    inst.typeid = 0
    setstatuetype(inst, inst.typeid)

    inst:AddComponent("inspectable")
    local old_GetDescription = inst.components.inspectable.GetDescription
    inst.components.inspectable.GetDescription = function(self, viewer)
	if viewer.prefab == "sdf" then
	    if self.inst.typeid == 0 then
		return old_GetDescription(self, viewer)
	    elseif self.inst.typeid == 1 then
		local heroEnabled = viewer.components.sdf_chalice_id_lock:CheckHeroStatus()
		if heroEnabled == true then
		    self.inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_STATUE_QUOTES[11])
		else
		    self.inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_STATUE_QUOTES[1])
		end
		return old_GetDescription(self, viewer)
	    else
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")
		self.inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_STATUE_QUOTES[self.inst.typeid], 5)
	    end
	else
	    return old_GetDescription(self, viewer)
	end
    end

    inst.OnLoad = onload
    inst.OnSave = onsave
    inst.OnLoadPostPass = onloadpostpass

    inst.icon = nil
    inst:DoTaskInTime(0, showOnMap)

    return inst
end

return  Prefab("sdf_statue", fn, assets)