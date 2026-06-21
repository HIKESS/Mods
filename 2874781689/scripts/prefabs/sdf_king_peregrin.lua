local assets =
{
    Asset("ANIM", "anim/ghost_sdf_king_peregrin.zip"),

    Asset("SOUND", "sound/ghost.fsb"),
}

local prefabs = {

}

local sdf_king_peregrin_trade_gem_random ={
"bluegem", "redgem", "purplegem", "yellowgem", "greengem", "orangegem"
} --random gem

local sdf_king_peregrin_trade_gem_common ={
"redgem", "bluegem"
}

local sdf_king_peregrin_trade_gem_uncommon ={
"yellowgem", "greengem"
}

local sdf_king_peregrin_trade_gem_rare ={
"purplegem", "orangegem"
}

local sdf_king_peregrin_trade_gem_epic ={
"purplegem", "orangegem", "opalpreciousgem"
}

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function ShouldAcceptItem(inst, item, giver)

    --accept sdf
    if giver:HasTag("sdf") then

	--Asparagus
	if item.prefab == "asparagus" then
	    return true
	end

	--Asparagus Cooked
	if item.prefab == "asparagus_cooked" then
	    return true
	end

	--Asparagus Soup
	if item.prefab == "asparagussoup" then
	    return true
	end
	--Asparagus Soup
	if item.prefab == "asparagussoup_spice_sugar" then
	    return true
	end
	--Asparagus Soup
	if item.prefab == "asparagussoup_spice_chili" then
	    return true
	end
	--Asparagus Soup
	if item.prefab == "asparagussoup_spice_garlic" then
	    return true
	end
	--Asparagus Soup
	if item.prefab == "asparagussoup_spice_salt" then
	    return true
	end

	--Cabbage Rolls
	if item.prefab == "cabbagerolls" then
	    return true
	end

	--Trinkets
	if item:HasTag("cattoy") and (item.components.tradable and item.components.tradable.goldvalue > 0) then
	    return true
	end
    end

    --accept wendy
    if giver:HasTag("ghostlyfriend") then

	--Nightmare Fuel
	if item.prefab == "nightmarefuel" then
	    return true
	end

	--Pure Horror
	if item.prefab == "horrorfuel" then
	    return true
	end

	--Trinkets
	if item:HasTag("cattoy") and (item.components.tradable and item.components.tradable.goldvalue > 0) then
	    return true
	end

	--Ghostly Elixirs
	if item:HasTag("ghostlyelixir") then
	    return true
	end
    end

    --reject
    return false
end

local function OnGetItemFromPlayer(inst, giver, item)

    --Sdf
    if giver:HasTag("sdf") then

	--Food for gems
	if item.prefab == "asparagus" or item.prefab == "asparagus_cooked" or item.prefab == "cabbagerolls" or item.prefab == "asparagussoup"
	    or item.prefab == "asparagussoup_spice_sugar" or item.prefab == "asparagussoup_spice_chili" or item.prefab == "asparagussoup_spice_garlic" or item.prefab == "asparagussoup_spice_salt" then

	    local gemReward = "goldnugget"

	    --Check food type
	    if item.prefab == "cabbagerolls" then
		--rare
		gemReward = sdf_king_peregrin_trade_gem_rare[math.random(#sdf_king_peregrin_trade_gem_rare)]
	    elseif item.prefab == "asparagussoup" or item.prefab == "asparagussoup_spice_sugar" or item.prefab == "asparagussoup_spice_chili" or item.prefab == "asparagussoup_spice_garlic" or item.prefab == "asparagussoup_spice_salt" then
		--random
		gemReward = sdf_king_peregrin_trade_gem_random[math.random(#sdf_king_peregrin_trade_gem_random)]
	    elseif item.prefab == "asparagus_cooked" then
		--uncommon
		gemReward = sdf_king_peregrin_trade_gem_uncommon[math.random(#sdf_king_peregrin_trade_gem_uncommon)]
	    elseif item.prefab == "asparagus" then
		--common
		gemReward = sdf_king_peregrin_trade_gem_common[math.random(#sdf_king_peregrin_trade_gem_common)]
	    end

	    --King talks
	    inst:AddTag("questing")
	    inst.talked_paused = true
	    inst.talked = true
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_FOOD_SDF[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_FOOD_SDF)], 5)
	    inst.sg:GoToState("quest_begin")

	    --spawn gems
	    inst:DoTaskInTime(2,function()
		local x, y, z = inst.Transform:GetWorldPosition()
		y = 4.5

		local angle
		if giver ~= nil and giver:IsValid() then
		    angle = 180 - giver:GetAngleToPoint(x, 0, z)
		else
		    local down = TheCamera:GetDownVec()
		    angle = math.atan2(down.z, down.x) / DEGREES
		end

		if gemReward ~= nil then
		    local gemItem = SpawnPrefab(gemReward)
		    gemItem.Transform:SetPosition(x, y, z)
		    launchitem(gemItem, angle)
		end
	    end)

	    inst:DoTaskInTime(4,function()
		--inst:RemoveTag("questing")
		--inst.talked_paused = false
		--inst.talked = false
		inst.sg:GoToState("quest_finished")
	    end)
	end

	 --Trinkets for gold nuggets
	if (item.components.tradable and item.components.tradable.goldvalue > 0) then
	    
	    local goldAmount = 1
	    goldAmount = item.components.tradable.goldvalue

	    --King talks
	    inst:AddTag("questing")
	    inst.talked_paused = true
	    inst.talked = true
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_TRINKET_SDF[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_TRINKET_SDF)], 6)
	    inst.sg:GoToState("quest_begin")

	    --spawn gold nuggets
	    inst:DoTaskInTime(2,function()
		local x, y, z = inst.Transform:GetWorldPosition()
		y = 4.5

		local angle
		if giver ~= nil and giver:IsValid() then
		    angle = 180 - giver:GetAngleToPoint(x, 0, z)
		else
		    local down = TheCamera:GetDownVec()
		    angle = math.atan2(down.z, down.x) / DEGREES
		end

		for k = 1, (goldAmount) do
		    local nug = SpawnPrefab("goldnugget")
		    nug.Transform:SetPosition(x, y, z)
		    launchitem(nug, angle)
		end
	    end)

	    inst:DoTaskInTime(5,function()
		inst:RemoveTag("questing")
		inst.talked_paused = false
		inst.talked = false
	    end)
	end
    end

    --Wendy
    if giver:HasTag("ghostlyfriend") then

	--Gold Nuggets for items
	if item.prefab == "nightmarefuel" or item.prefab == "horrorfuel" then

	    local goldAmount = 1

	    if item.prefab == "nightmarefuel" then
		goldAmount = TUNING.SDF_KING_PEREGRIN_GHOST_TRADE_NIGHTMAREFUEL_VALUE
	    elseif item.prefab == "horrorfuel" then
		goldAmount = TUNING.SDF_KING_PEREGRIN_GHOST_TRADE_HORRORFUEL_VALUE
	    end

	    --King talks
	    inst:AddTag("questing")
	    inst.talked_paused = true
	    inst.talked = true
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_WENDY[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_WENDY)], 5)
	    inst.sg:GoToState("quest_begin")

	    --spawn gold nuggets
	    inst:DoTaskInTime(2,function()
		local x, y, z = inst.Transform:GetWorldPosition()
		y = 4.5

		local angle
		if giver ~= nil and giver:IsValid() then
		    angle = 180 - giver:GetAngleToPoint(x, 0, z)
		else
		    local down = TheCamera:GetDownVec()
		    angle = math.atan2(down.z, down.x) / DEGREES
		end

		for k = 1, (goldAmount) do
		    local nug = SpawnPrefab("goldnugget")
		    nug.Transform:SetPosition(x, y, z)
		    launchitem(nug, angle)
		end
	    end)

	    inst:DoTaskInTime(5,function()
		inst:RemoveTag("questing")
		inst.talked_paused = false
		inst.talked = false
	    end)

	end

	 --Trinkets to Ghostflowers
	if (item.components.tradable and item.components.tradable.goldvalue > 0) then
	    
	    --King talks
	    inst:AddTag("questing")
	    inst.talked_paused = true
	    inst.talked = true
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_WENDY[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_WENDY)], 5)
	    inst.sg:GoToState("quest_begin")

	    --spawn flower
	    inst:DoTaskInTime(2,function()
		local x, y, z = inst.Transform:GetWorldPosition()
		y = 4.5

		local angle
		if giver ~= nil and giver:IsValid() then
		    angle = 180 - giver:GetAngleToPoint(x, 0, z)
		else
		    local down = TheCamera:GetDownVec()
		    angle = math.atan2(down.z, down.x) / DEGREES
		end

		local ghostFlower = SpawnPrefab("ghostflower")
		ghostFlower.Transform:SetPosition(x, y, z)
		launchitem(ghostFlower, angle)
	    end)

	    inst:DoTaskInTime(4,function()
		--inst:RemoveTag("questing")
		--inst.talked_paused = false
		--inst.talked = false
		inst.sg:GoToState("quest_finished")
	    end)

	--Gems
	elseif item:HasTag("ghostlyelixir") then
	    
	    local gemReward = "goldnugget"

	    --Check elixir type
	    if item:HasTag("super_elixir") then
		--epic
		gemReward = sdf_king_peregrin_trade_gem_epic[math.random(#sdf_king_peregrin_trade_gem_epic)]
	    elseif item.prefab == "ghostlyelixir_fastregen" or item.prefab == "ghostlyelixir_retaliation" or item.prefab == "ghostlyelixir_attack" then
		--rare
		gemReward = sdf_king_peregrin_trade_gem_rare[math.random(#sdf_king_peregrin_trade_gem_rare)]
	    elseif item.prefab == "ghostlyelixir_speed" then
		--uncommon
		gemReward = sdf_king_peregrin_trade_gem_uncommon[math.random(#sdf_king_peregrin_trade_gem_uncommon)]
	    elseif item.prefab == "ghostlyelixir_slowregen" or item.prefab == "ghostlyelixir_shield" then
		--common
		gemReward = sdf_king_peregrin_trade_gem_common[math.random(#sdf_king_peregrin_trade_gem_common)]
	    elseif item.prefab == "ghostlyelixir_revive" then
		--random
		gemReward = sdf_king_peregrin_trade_gem_random[math.random(#sdf_king_peregrin_trade_gem_random)]
	    end

	    --King talks
	    inst:AddTag("questing")
	    inst.talked_paused = true
	    inst.talked = true
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_WENDY[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_WENDY)], 5)
	    inst.sg:GoToState("quest_begin")

	    --Check elixir type
	    inst:DoTaskInTime(2,function()
		local x, y, z = inst.Transform:GetWorldPosition()
		y = 4.5

		local angle
		if giver ~= nil and giver:IsValid() then
		    angle = 180 - giver:GetAngleToPoint(x, 0, z)
		else
		    local down = TheCamera:GetDownVec()
		    angle = math.atan2(down.z, down.x) / DEGREES
		end

		if gemReward ~= nil then
		    local gemItem = SpawnPrefab(gemReward)
		    gemItem.Transform:SetPosition(x, y, z)
		    launchitem(gemItem, angle)
		end
	    end)

	    inst:DoTaskInTime(4,function()
		--inst:RemoveTag("questing")
		--inst.talked_paused = false
		--inst.talked = false
		inst.sg:GoToState("quest_finished")
	    end)
	end
    end
end

local function OnRefuseItem(inst, giver, item)

    --Sdf
    if giver:HasTag("sdf") then

	--King talks
	inst.talked_paused = true
	inst.talked = true
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_REFUSED[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_REFUSED)], 4)
	inst.sg:GoToState("quest_abandoned")

	inst:DoTaskInTime(4,function()
	    inst.talked_paused = false
	    inst.talked = false
	end)
    end

    --Wendy
    if giver:HasTag("ghostlyfriend") then

	--King talks
	inst.talked_paused = true
	inst.talked = true
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_REFUSED[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_TRADE_REFUSED)], 4)
	inst.sg:GoToState("quest_abandoned")

	inst:DoTaskInTime(4,function()
	    inst.talked_paused = false
	    inst.talked = false
	end)
    end
end

local function unlink_from_player(inst)
    if inst._playerlink ~= nil then
        if inst._playerlink.components.leader ~= nil then
            inst._playerlink.components.leader:RemoveFollower(inst)
        end
        inst._playerlink:RemoveEventCallback("onremove", unlink_from_player, inst)
        inst._playerlink:RemoveEventCallback("onremove", inst._on_leader_removed)

        inst:RemoveEventCallback("death", inst._on_leader_death, inst._playerlink)

        inst._playerlink.questghost = nil
        inst._playerlink = nil
    end
end

local function link_to_home(inst, home)
    inst.UnlinkFromGravestone = function()
	if home:IsValid() then
	    home:RemoveEventCallback("onremove", inst.UnlinkFromGravestone, inst)
	    home.ghost = nil
	end
        inst.UnlinkFromGravestone = nil
    end

    home:ListenForEvent("onremove", inst.UnlinkFromGravestone, inst)

    if not inst.components.playerprox:IsPlayerClose() then
        inst:RemoveFromScene()
    end

    inst.components.knownlocations:RememberLocation("home", inst:GetPosition(), true)
end

local KING_ON = false --Use for talking
local KING_ON_PRE = false --Use for talking

local function talkingFX(inst)
    if inst.KING_ON == true then
	if inst.talked == false and inst.talked_paused == false then
	    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_QUOTES[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_QUOTES)], 8)
	end
	inst.talkingtask = inst:DoTaskInTime(math.random(26, 30), talkingFX)
    elseif inst.KING_ON_PRE == true then	
	if inst.talked == false and inst.talked_paused == false then
	    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_QUOTES_PRE[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_QUOTES_PRE)], 5)
	end
	inst.talkingtask = inst:DoTaskInTime(math.random(26, 30), talkingFX)
    elseif inst.talkingtask ~= nil then
	inst.talkingtask:Cancel()
    end
end

local function starttalking(inst)
    inst.talkingtask = inst:DoTaskInTime(math.random(26, 30), talkingFX)
end

local function kperegrinon(inst, player)
    if player.prefab == "sdf" then

	--Has found lost crown
	if (player.components.inventory and player.components.inventory:Has("sdf_king_peregrins_crown_lost", 1, true)) then

	    if inst:IsInLimbo() then
		inst:ReturnToScene()

		local home_position = inst.components.knownlocations:GetLocation("home")
		if home_position ~= nil then
		    inst.Transform:SetPosition(home_position.x + 0.3, home_position.y, home_position.z + 0.3)
		else
		    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
		end

		inst:DoTaskInTime(0, function(i) i.sg:GoToState("appear") end)
	    end

	    inst.KING_ON_PRE = true

	    --greet sdf
	    inst:DoTaskInTime(2,function()
		if inst.KING_ON == true or inst.KING_ON_PRE == true then	
		    inst.talkingtask = inst:DoTaskInTime(0, starttalking)
		end
	    end)

	--Has offered lost crown
	elseif (player.components.inventory and player.components.inventory:Has("sdf_king_peregrins_crown", 1, true) and (player.components.sdf_king_peregrin_quest and player.components.sdf_king_peregrin_quest:GetCrownOfferedStatus() == true)) then

	    --king has crown
	    if inst:IsInLimbo() then
		inst:ReturnToScene()

		local home_position = inst.components.knownlocations:GetLocation("home")
		if home_position ~= nil then
		    inst.Transform:SetPosition(home_position.x + 0.3, home_position.y, home_position.z + 0.3)
		else
		    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
		end

		inst:DoTaskInTime(0, function(i) i.sg:GoToState("appear") end)
	    end

	    inst.KING_ON = true

	    --enable trade
	    inst:DoTaskInTime(1,function()
		inst:AddComponent("trader")
		inst.components.trader:SetAcceptTest(ShouldAcceptItem)
		inst.components.trader.onaccept = OnGetItemFromPlayer
		inst.components.trader.onrefuse = OnRefuseItem
		inst.components.trader.acceptnontradable = true
	    end)

	    --greet sdf
	    inst:DoTaskInTime(2,function()
		if inst.talked == false then
		    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_GREETING_SDF[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_GREETING_SDF)], 5)
		    inst.talked = true
		    inst:DoTaskInTime(30, function(inst)
			inst.talked = false
		    end)
		end

		if inst.KING_ON == true or inst.KING_ON_PRE == true then	
		    inst.talkingtask = inst:DoTaskInTime(0, starttalking)
		end
	    end)
	end

    --Special Wendy spawn
    elseif player:HasTag("ghostlyfriend") then
	if inst:IsInLimbo() then
	    inst:ReturnToScene()

	    local home_position = inst.components.knownlocations:GetLocation("home")
	    if home_position ~= nil then
		inst.Transform:SetPosition(home_position.x + 0.3, home_position.y, home_position.z + 0.3)
	    else
		inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
	    end

	    inst:DoTaskInTime(0, function(i) i.sg:GoToState("appear") end)
	end

	inst.KING_ON_PRE = true

	--enable trade
	inst:DoTaskInTime(1,function()
	    inst:AddComponent("trader")
	    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
	    inst.components.trader.onaccept = OnGetItemFromPlayer
	    inst.components.trader.onrefuse = OnRefuseItem
	    inst.components.trader.acceptnontradable = true
	end)

	--greet wendy
	inst:DoTaskInTime(2,function()
	    if inst.talked == false then
		inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_GREETING_WENDY[math.random(#STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_GREETING_WENDY)], 5)
		inst.talked = true
		inst:DoTaskInTime(30, function(inst)
		    inst.talked = false
		end)
	    end

	    if inst.KING_ON == true or inst.KING_ON_PRE == true then	
		inst.talkingtask = inst:DoTaskInTime(0, starttalking)
	    end
	end)
    end
end

local function kperegrinoff(inst)
    if inst.KING_ON == true or inst.KING_ON_PRE == true then
	inst.KING_ON = false
	inst.KING_ON_PRE = false
	if inst.components.trader then
	    inst:RemoveComponent("trader")
	end
	if inst.talkingtask ~= nil then
	    inst.talkingtask:Cancel()
	end
    end

    -- If we have a leader, we have to follow them! Don't limbo out!
    if inst.components.follower:GetLeader() == nil then
        inst.sg:GoToState("disappear", function(ghost)
            ghost:DoTaskInTime(0, inst.RemoveFromScene)
        end)
    end
end

local SMALL_GHOST_TRANSPARENCY = 0.6

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeTinyGhostPhysics(inst, 1.5, 1.5) --0.5

    inst.DynamicShadow:SetSize(0.75, 0.75)

    inst.AnimState:SetBank("ghost_sdf_king_peregrin")
    inst.AnimState:SetBuild("ghost_sdf_king_peregrin")
    inst.AnimState:PlayAnimation("idle", true)

   inst.AnimState:SetBloomEffectHandle("shaders/anim_bloom_ghost.ksh")

    inst:AddTag("ghost")
    inst:AddTag("flying")
    inst:AddTag("noauradamage")
    inst:AddTag("NOBLOCK")
    inst:AddTag("sdf_king_peregrin")
    inst:AddTag("sdf_king_peregrins_crown_lost_offering")
    inst:AddTag("sdf_king_peregrins_crown_offering")
    inst:AddTag("sdf_shadow_artefact_offering")
    inst:AddTag("sdf_shadow_talisman_offering")
    inst:AddTag("sdf_witch_talisman_offering")

    inst:AddComponent("talker")
    if inst.components and inst.components.talker ~= nil then
	inst.components.talker.fontsize = 35
	inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(0.55, 0.53, 0.3, 0)
	inst.components.talker.offset = Vector3(0,-600,0)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGsdf_king_peregrin")
    local brain = require "brains/sdf_king_peregrinbrain"
    inst:SetBrain(brain)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.SDF_KING_PEREGRIN_GHOST_SPEED
    inst.components.locomotor.runspeed = TUNING.SDF_KING_PEREGRIN_GHOST_SPEED * 3
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("inspectable")

    -- For gravestone-spawned ghosts to maintain their point (and not dissipate when they have no target)
    inst:AddComponent("knownlocations")

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(11,14)
    inst.components.playerprox:SetOnPlayerNear(kperegrinon)
    inst.components.playerprox:SetOnPlayerFar(kperegrinoff)

    inst.talked = false
    inst.talked_paused = false
    inst.talkingtask = nil

    inst.LinkToHome = link_to_home

    inst._on_leader_removed = function(leader)
        if inst ~= nil and inst:IsValid() then
            if leader.migration ~= nil or leader:GetTimeAlive() < 0.01 then
                inst:Remove()
            else
                inst.sg:GoToState("dissipate")
            end
        end
    end

    inst._on_leader_death = function(leader)
        unlink_from_player(inst)
    end

    inst.starttalking = starttalking

    return inst
end

return Prefab("sdf_king_peregrin", fn, assets, prefabs)