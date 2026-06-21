local SDF_LIFEBOTTLE_BOSS_DROPS = GetModConfigData("sdf_lifebottle_boss_drops") --true
local soul_helmet_droprate = 1
local soul_helmet_player_droprate = 0.5
local carnival_token_droprate = 0.1

--Boss Drops
    AddPrefabPostInit("alterguardian_phase3", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("antlion", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)

    AddPrefabPostInit("beequeen", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("crabking", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("daywalker", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("dragonfly", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    inst.components.lootdropper:AddChanceLoot("sdf_dragon_potion", 1) --Dragon Potion Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("klaus", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("malbatross", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    inst.components.lootdropper:AddChanceLoot("sdf_chicken_drumstick", 1) --Chicken Drumstick Drop
	    inst.components.lootdropper:AddChanceLoot("sdf_chicken_drumstick", 1) --Chicken Drumstick Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("minotaur", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("moose", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    inst.components.lootdropper:AddChanceLoot("sdf_chicken_drumstick", 1) --Chicken Drumstick Drop
	    inst.components.lootdropper:AddChanceLoot("sdf_chicken_drumstick", 1) --Chicken Drumstick Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("mossling", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    inst.components.lootdropper:AddChanceLoot("sdf_chicken_drumstick", 1) --Chicken Drumstick Drop
	    inst.components.lootdropper:AddChanceLoot("sdf_chicken_drumstick", 1) --Chicken Drumstick Drop
        end
    end)
    AddPrefabPostInit("shadow_knight", function(inst)
        if inst.components.lootdropper ~= nil then
	    if inst.level == 3 then
		inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
		if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		    inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1) --add small chance for shadow artefact
		end
	    end
        end
    end)
    AddPrefabPostInit("shadow_bishop", function(inst)
        if inst.components.lootdropper ~= nil then
	    if inst.level == 3 then
		inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
		if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		    inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1) --add small chance for shadow artefact
		end
	    end
        end
    end)
    AddPrefabPostInit("shadow_rook", function(inst)
        if inst.components.lootdropper ~= nil then
	    if inst.level == 3 then
		inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
		if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		    inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1) --add small chance for shadow artefact
		end
	    end
        end
    end)
    AddPrefabPostInit("spiderqueen", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("stalker_forest", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("stalker", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("stalker_atrium", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("toadstool", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("toadstool_dark", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("worm_boss", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)

--[[local function OnDead(inst,data) --not needed
    trackattackers(inst,data)
    for ID, data in pairs(inst.attackerUSERIDs) do
        for i, player in ipairs(AllPlayers) do
            if player.userid == ID then 
                SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, player.userid, "celestialchampion_killed")
                break
            end
        end
    end
end]]

--Skill Tree Boss Fights
    AddPrefabPostInit("eyeofterror", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
	inst.attackerUSERIDs = {}
    end)
    AddPrefabPostInit("twinofterror1", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)
    AddPrefabPostInit("twinofterror2", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
	inst.attackerUSERIDs = {}
    end)
    AddPrefabPostInit("deerclops", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
	inst.attackerUSERIDs = {}
    end)
    AddPrefabPostInit("mutateddeerclops", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
        end
    end)
    AddPrefabPostInit("warg", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)
    AddPrefabPostInit("mutatedwarg", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)
    AddPrefabPostInit("gingerbreadwarg", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)
    AddPrefabPostInit("claywarg", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)
    AddPrefabPostInit("bearger", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)
    AddPrefabPostInit("mutatedbearger", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", 1) --Carnival Token
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)
    AddPrefabPostInit("daywalker2", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_carnival_token", carnival_token_droprate) --Carnival Token Drop
	    if SDF_LIFEBOTTLE_BOSS_DROPS == true then
		inst.components.lootdropper:AddChanceLoot("sdf_lifebottle", 1)
	    end
	inst.attackerUSERIDs = {}
        end
    end)

--Allows Soul Helmet to drop from Skeleton Bodies
    AddPrefabPostInit("skeleton", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_soul_helmet", soul_helmet_droprate) --Soul Helmet Drop
        end
    end)

    AddPrefabPostInit("skeleton_player", function(inst)
        if inst.components.lootdropper ~= nil then
	    inst.components.lootdropper:AddChanceLoot("sdf_soul_helmet", soul_helmet_player_droprate) --Soul Helmet Drop
        end
    end)


--Allows Sir Dan to eat Pumpkin Pie
local function OnPickupSdfFn(inst, picker)
    if picker.prefab == "sdf" then
	if inst.components.edible == nil then
	    inst:AddComponent("edible")
	    if inst.components.finiteuses ~= nil then
		local pumpkinPiePercent = inst.components.finiteuses:GetPercent()
		inst.components.edible.healthvalue = TUNING.SDF_PUMPKINPIE_HEALTH * pumpkinPiePercent
		inst.components.edible.hungervalue = TUNING.SDF_PUMPKINPIE_HUNGER * pumpkinPiePercent
		inst.components.edible.sanityvalue = TUNING.SDF_PUMPKINPIE_SANITY * pumpkinPiePercent
		inst.components.edible.foodtype = FOODTYPE.VEGGIE
	    else
		inst.components.edible.healthvalue = TUNING.SDF_PUMPKINPIE_HEALTH
		inst.components.edible.hungervalue = TUNING.SDF_PUMPKINPIE_HUNGER
		inst.components.edible.sanityvalue = TUNING.SDF_PUMPKINPIE_SANITY
		inst.components.edible.foodtype = FOODTYPE.VEGGIE
	    end
	end
    else
	if inst.components.edible ~= nil then
	    inst:RemoveComponent("edible")
	end
    end
end
local function OnDroppedSdfFn(inst)
    if inst.components.edible ~= nil then
	inst:RemoveComponent("edible")
    end
end
AddPrefabPostInit("pumpkinpie", function(inst)
    if inst.components.inventoryitem ~= nil then
	inst.components.inventoryitem:SetOnPickupFn(OnPickupSdfFn)
	inst.components.inventoryitem:SetOnDroppedFn(OnDroppedSdfFn)
    end
end)
