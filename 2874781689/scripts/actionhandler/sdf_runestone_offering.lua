GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_RUNESTONE_OFFERING"
local name = STRINGS.ACTIONHANDLER_SDF_RUNESTONE_OFFERING

local function chaliceCleanUp(act)
    local sdfReward =act.target.components.sdf_chalice_rewards
    local usedChaliceCount = act.doer.components.sdf_chalice_counter:GetUsedChaliceCount()
    local rewardQuote = usedChaliceCount + 1

    --Reward Quote
    --Skill Tree Valor
    if rewardQuote == TUNING.SDF_CHALICE_OF_SOUL_MAX and act.doer.components.skilltreeupdater:IsActivated("sdf_backbone_4") then
	--Collected all chalices
	act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS[TUNING.SDF_CHALICE_OF_SOUL_MAX], 8)
	act.target.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")

	act.target:DoTaskInTime(9, function()
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO[1], 6)
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	end)
	act.target:DoTaskInTime(18, function()
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO[2], 6)
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	end)
	act.target:DoTaskInTime(24, function()
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO[3], 5)
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.doer.components.sdf_chalice_id_lock:GiveGoodLightningSample()

	    --Reset all locks
	    local chaliceLock = act.doer.components.sdf_chalice_id_lock:GetLock()
	    local altarLock = act.doer.components.sdf_chalice_id_lock:GetAltarLock()
	    act.doer.components.sdf_chalice_id_lock:ResetLocks(chaliceLock)
	    act.doer.components.sdf_chalice_id_lock:ResetLocks(altarLock)
	end)

    elseif rewardQuote == TUNING.SDF_CHALICE_OF_SOUL_MAX then
	--Collected all chalices
	act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS[TUNING.SDF_CHALICE_OF_SOUL_MAX], 8)
	act.target.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")

	act.target:DoTaskInTime(9, function()
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO[1], 6)
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	end)
	act.target:DoTaskInTime(18, function()
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO[2], 6)
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	end)
	act.target:DoTaskInTime(24, function()
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO[3], 5)
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	end)
	act.target:DoTaskInTime(30, function()
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_HERO[4], 6)
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.doer.components.sdf_chalice_counter:SetUsedChaliceCount(usedChaliceCount + 1)
	    act.doer.components.sdf_chalice_id_lock:GiveGoodLightningSample()

	    --Skill Tree Valor Lock 3
	    if TheGenericKV:GetKV("sdf_all_chalices_collected") == "1" then
	    else
		SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, act.doer.userid, "sdf_all_chalices_collected")
	    end
	end)
    elseif usedChaliceCount > TUNING.SDF_CHALICE_OF_SOUL_MAX then
	--Bonus chalices
	act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_BONUS[math.random(#STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_BONUS)], 8)
	act.target.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")
    else
	--Progressive rewards
	act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS[rewardQuote], 8)
	act.target.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")
    end

    --Update player ChaliceCount and Chalice ID
    local lock = act.doer.components.sdf_chalice_id_lock:GetLock()
    local key = act.invobject.components.sdf_chalice_id_key:GetKey()
    act.doer.components.sdf_chalice_id_lock:SetLock(lock, key)

    if rewardQuote ~= TUNING.SDF_CHALICE_OF_SOUL_MAX then
	act.doer.components.sdf_chalice_counter:SetUsedChaliceCount(usedChaliceCount + 1)
    end

    --Skill Tree Time Dilation Runesmith
    local chaliceOverworldCount = act.doer.components.sdf_chalice_id_lock:GetOverworldCount()
    local chaliceCaveCount = act.doer.components.sdf_chalice_id_lock:GetCaveCount()

    --Overworld Chalice Counter
    if chaliceOverworldCount < TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_OVERWORLD_COUNT then
	if key > 0 and key <= 10 then
	    act.doer.components.sdf_chalice_id_lock:SetOverworldCount(chaliceOverworldCount + 1)
	end
	--Check if Overworld unlocked
	local chaliceOverworldCountNewTotal = act.doer.components.sdf_chalice_id_lock:GetOverworldCount()
	if chaliceOverworldCountNewTotal >= TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_OVERWORLD_COUNT then
	    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, act.doer.userid, "sdf_overworld_chalices_collected")
	end
    end

    --Cave Chalice Counter
    if chaliceCaveCount < TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_CAVE_COUNT then
	if key > 10 and key <= 20 then
	    act.doer.components.sdf_chalice_id_lock:SetCaveCount(chaliceCaveCount + 1)
	end
	--Check if Cave unlocked
	local chaliceCaveCountNewTotal = act.doer.components.sdf_chalice_id_lock:GetCaveCount()
	if chaliceCaveCountNewTotal >= TUNING.SDF_SKILLSET_UNDEATH_TIME_DILATION_RUNESMITH_CAVE_COUNT then
	    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, act.doer.userid, "sdf_cave_chalices_collected")
	end
    end

    --Turn off Runestone
    act.target.RUNESTONE_REWARDREADY = false
    act.target.RUNESTONE_ACTIVATE = false
    act.target.AnimState:PushAnimation("idle")

    --Remove Chalice
    act.invobject:Remove()

end

local function goldNuggetsCleanUp(act)
    --Turn off Runestone
    act.target.RUNESTONE_ACTIVATE = false
    act.target.AnimState:PushAnimation("idle")

    --Remove Chalice
    act.invobject:Remove()
end

local function makeChest(act, lootbox)
    local x,_,z=act.target.Transform:GetWorldPosition()

    local rewardChest = SpawnPrefab("sdf_chest_runestone")
    rewardChest.Transform:SetPosition(x,_,z)
    rewardChest.components.lootdropper:SetLoot(lootbox)

    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
    chaliceCleanUp(act)
end

local function makeItem(act, rewardInfo)
    local x,_,z=act.target.Transform:GetWorldPosition()

    local rewardItem = SpawnPrefab(rewardInfo[2])
    rewardItem.Transform:SetPosition(x,_,z)

    --runestone float animation
    rewardItem.AnimState:PlayAnimation("runestone", true)

    --learn recipe
    act.doer.components.builder:UnlockRecipe(rewardInfo[2])
    act.doer:PushEvent("learnrecipe", { teacher = act.target, recipe = GetValidRecipe(rewardInfo[2]) })

    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
    chaliceCleanUp(act)
end

local function makeItemEnchanted(act, rewardInfo)
    local x,_,z=act.target.Transform:GetWorldPosition()

    local rewardItem = SpawnPrefab(rewardInfo[3])
    rewardItem.Transform:SetPosition(x,_,z)

    --runestone float animation
    rewardItem.AnimState:PlayAnimation("runestone", true)

    --learn recipe
    act.doer.components.builder:UnlockRecipe(rewardInfo[2])
    act.doer:PushEvent("learnrecipe", { teacher = act.target, recipe = GetValidRecipe(rewardInfo[2]) })

    --unlock trade at vender
    act.doer.components.sdf_chalice_id_lock:EnableTrade(rewardInfo[3])
    act.doer.components.sdf_chalice_id_lock:CreateTradeTags(act.doer)

    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
    chaliceCleanUp(act)
end

local function makeItemQuiver(act, rewardInfo)
    local x,_,z=act.target.Transform:GetWorldPosition()

    local rewardItem = SpawnPrefab(rewardInfo[2])
    rewardItem.Transform:SetPosition(x,_,z)

    --runestone float animation
    rewardItem.AnimState:PlayAnimation("runestone", true)

    local rewardItemAmmo = SpawnPrefab(rewardInfo[3])
    local rewardItemAmmoAmount = rewardInfo[4]

    --for bow and spear ammo
    if rewardItemAmmo.components.stackable then
	rewardItemAmmo.components.stackable:SetStackSize(rewardItemAmmoAmount)
    end
    rewardItem.components.container:GiveItem(rewardItemAmmo, 1)

    --learn recipe
    act.doer.components.builder:UnlockRecipe(rewardInfo[2])
    act.doer:PushEvent("learnrecipe", { teacher = act.target, recipe = GetValidRecipe(rewardInfo[2]) })

    --unlock trade at vender
    act.doer.components.sdf_chalice_id_lock:EnableTrade(rewardInfo[3])
    act.doer.components.sdf_chalice_id_lock:CreateTradeTags(act.doer)

    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
    chaliceCleanUp(act)
end

local function makeItemOnly(act, rewardInfo)
    local x,_,z=act.target.Transform:GetWorldPosition()

    local rewardItem = SpawnPrefab(rewardInfo[2])
    rewardItem.Transform:SetPosition(x,_,z)

    --runestone float animation
    rewardItem.AnimState:PlayAnimation("runestone", true)

    --amount
    if rewardItem.components.stackable then
	local rewardItemAmount = rewardInfo[3]
	rewardItem.components.stackable:SetStackSize(rewardItemAmount)
    end

    --unlock trade at vender
    act.doer.components.sdf_chalice_id_lock:EnableTrade(rewardInfo[2])
    act.doer.components.sdf_chalice_id_lock:CreateTradeTags(act.doer)

    --Gold Shield
    if rewardItem.prefab == "sdf_gold_shield" then
	--Destory all old Gold Shield
	local oldGoldShield = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_gold_shield")
	if oldGoldShield ~= nil then
	    act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldGoldShield)
	end

	--create ID
	act.doer.components.sdf_key_item_inventory:SetKeyItem(goldShield, act.doer)
    end

    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
    chaliceCleanUp(act)
end

local function makeGoldNuggets(act)
    local x,_,z=act.target.Transform:GetWorldPosition()

    local rewardItem = SpawnPrefab("goldnugget")
    rewardItem.Transform:SetPosition(x,_,z)

    rewardItem.components.stackable:SetStackSize(2)

    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
    goldNuggetsCleanUp(act)
end


local fn = function(act)

    if act.doer.prefab == "sdf" and act.target.RUNESTONE_REWARDREADY == true then
	local chaliceLock = act.doer.components.sdf_chalice_id_lock:GetLock()
	local altarLock = act.doer.components.sdf_chalice_id_lock:GetAltarLock()
	local key = act.invobject.components.sdf_chalice_id_key:GetKey()


	--Clearing useless Chalice of souls
	if key == 0 then
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_FAIL[1], 8)
	    act.target.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/valhalla")

	    --play offering FX
    	    local x,_,z=act.target.Transform:GetWorldPosition()
    	    SpawnPrefab("mining_moonglass_fx").Transform:SetPosition(x,_,z)

	    --Turn off Runestone
	    act.target.RUNESTONE_ACTIVATE = false
	    act.target.AnimState:PushAnimation("idle")

	    --Remove Chalice
	    act.doer.SoundEmitter:PlaySound("dontstarve/common/destroy_tool") --Tool noise
	    act.invobject:Remove()

	    return true
	end

	--Clearing already offered Chalice of souls
	if act.doer.components.sdf_chalice_id_lock:CheckLock(chaliceLock,key) == true then

	    --play offering FX
    	    local x,_,z=act.target.Transform:GetWorldPosition()
    	    SpawnPrefab("lavaarena_player_revive_from_corpse_fx").Transform:SetPosition(x,_,z)

	    SpawnPrefab("halloween_moonpuff").Transform:SetPosition(x,_,z)

	    --locate and spawn reward
    	    act.target:DoTaskInTime(2.5, function()
	    	if act.target.RUNESTONE_REWARDREADY == true then
		    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_CHALICE_RUNESTONE_REWARDS_FAIL[2], 8)
		    makeGoldNuggets(act)
		end
    	    end)

	    return true
	end


	--Chalice and Altar locking
	if act.doer.components.sdf_chalice_id_lock:CheckLock(chaliceLock,key) == false and act.doer.components.sdf_chalice_id_lock:CheckLock(altarLock,key) == true then

	    --play offering FX
    	    local x,_,z=act.target.Transform:GetWorldPosition()
    	    SpawnPrefab("lavaarena_player_revive_from_corpse_fx").Transform:SetPosition(x,_,z)
	
	    SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)

	    --locate and spawn reward
    	    act.target:DoTaskInTime(2.5, function()
	    	if act.target.RUNESTONE_REWARDREADY == true then

	    	    local sdfReward =act.target.components.sdf_chalice_rewards
	   	    local maxChaliceCount = act.doer.components.sdf_chalice_counter:GetMaxChaliceCount()
	    	    local usedChaliceCount = act.doer.components.sdf_chalice_counter:GetUsedChaliceCount()
	    	    local rewardInfo = {}


		    --master reset for repeatable questing
		    local hero_Enabled = act.doer.components.sdf_chalice_id_lock:CheckHeroStatus()
		    local chaliceLocks = act.doer.components.sdf_chalice_id_lock:GetLock()
		    local chaliceAllCollected = act.doer.components.sdf_chalice_id_lock:CheckLocks(chaliceLocks)

		    if hero_Enabled == true and chaliceAllCollected == true then
			local altarLocks = act.doer.components.sdf_chalice_id_lock:GetAltarLock()
	    		act.doer.components.sdf_chalice_id_lock:ResetLocks(chaliceLocks)
			act.doer.components.sdf_chalice_id_lock:ResetLocks(altarLocks)
		    end

		    --create the rewards
	    	    if usedChaliceCount > maxChaliceCount then
		    	--Make Bonus Chest rewards
		    	rewardInfo = sdfReward:GetBonusReward(sdfReward:GetBonusRewardBank())

		    	makeChest(act, rewardInfo)
	    	    else
		    	--Normal rewards
	    	    	rewardInfo = sdfReward:GetReward(sdfReward:GetRewardBank(),(usedChaliceCount + 1))

		    	if rewardInfo[1] == "C" then
			    --Create a chest reward
			    makeChest(act, rewardInfo[2])
		    	elseif rewardInfo[1] == "I" then
			    --Create an item learnable reward
			    makeItem(act, rewardInfo)
		    	elseif rewardInfo[1] == "IE" then
			    --Create an item enchanted reward
			    makeItemEnchanted(act, rewardInfo)
		    	elseif rewardInfo[1] == "IQ" then
			    --Create an item quiver reward
			    makeItemQuiver(act, rewardInfo)
		    	elseif rewardInfo[1] == "IO" then
			    --Create an item only reward
			    makeItemOnly(act, rewardInfo)
		    	end
	    	    end
	    	end
    	    end)
	    return true
	end
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_runestone_offering"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_runestone_offering") then
	table.insert(actions, ACTIONS.SDF_RUNESTONE_OFFERING)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_RUNESTONE_OFFERING, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_RUNESTONE_OFFERING,state))