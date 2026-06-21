local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_jack_of_the_green_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_jack_of_the_green_mm.tex"),

    Asset("ANIM", "anim/sdf_jack_of_the_green.zip"),
}

prefabs = {
}

--Do not Touch
local sdf_jack_of_the_green_riddle_book_of_gallowmere_riddle ={
{1,"lightbulb"},{2,"seeds"},{3,"foliage"},{4,"cutlichen"},{5,"cutgrass"},{6,"petals"},{7,"petals_evil"},{8,"cactus_flower"},
{9,"red_cap"},{10,"green_cap"},{11,"blue_cap"},{12,"moon_cap"},{13,"monstermeat"},{14,"batwing"},{15,"spidergland"},{16,"plantmeat"},
{17,"cactus_meat"},{18,"firenettles"},{19,"cave_banana"},{20,"pomegranate"},{21,"wormlight_lesser"},{22,"garlic"},{23,"onion"},{24,"potato"},
{25,"pumpkin"},{26,"butter"},{27,"honey"},{28,"egg"},{29,"rottenegg"},{30,"spoiled_food"},{31,"honeycomb"},{32,"waxpaper"},
{33,"papyrus"},{34,"butterfly"},{35,"mosquito"},{36,"bee"},{37,"killerbee"},{38,"fireflies"},{39,"pondfish"},{40,"mole"},
{41,"rabbit"},{42,"feather_crow"},{44,"feather_robin"},{44,"feather_robin_winter"},{45,"feather_canary"},{46,"beefalowool"},
{47,"silk"},{48,"ice"},{49,"charcoal"},{50,"nitre"},{51,"moonrocknugget"},{52,"flint"},{53,"goldnugget"},{54,"thulecite_pieces"},
{55,"heatrock"},{56,"reviver"}
}

local sdf_jack_of_the_green_riddle_book_of_gallowmereloots ={
"sdf_silver_shield","sdf_energyvial","sdf_chicken_drumstick","sdf_spear","sdf_magical_arrows","trinket_6","thulecite_pieces",
"moonrocknugget","thulecite","moonglass","gears","pigskin","coontail","livinglog","nightmarefuel","tentaclespots","beardhair",
"silk","glommerfuel","marblebean","goose_feather","houndstooth","slurtleslime","wormlight_lesser","lifeinjector","redgem","bluegem",
"orangegem","yellowgem","greengem","purplegem","goldnugget"
}


local sdf_jack_of_the_green_riddle_book_of_gallowmereloots_rare ={
"sdf_shop_gargoyle","deerclops_eyeball","steelwool","trunk_summer","bearger_fur","dragon_scales","opalpreciousgem","lightninggoathorn",
"townportaltalisman","minotaurhorn","walrus_tusk","malbatross_beak","malbatross_feather","shadowheart","fossil_piece","klaussackkey",
"krampus_sack","pig_token","lureplantbulb","spidereggsack","tallbirdegg","mandrake_active","lavae_egg","milkywhites","royal_jelly",
"barnacle","wormlight","dragonfruit_seeds", "purebrilliance", "lunarplant_husk", "horrorfuel", "voidcloth", "bootleg"
}

local JACK_ON = false --Use for jack glow

local function talkingFX(inst)
    if inst.talkingtask ~= nil then
	inst.talked = false
	inst.talkingtask:Cancel()
    end
end

local function starttalking(inst, talkingtime)
    inst.talkingtask = inst:DoTaskInTime(talkingtime, talkingFX)
end

local function MakeBookOfGallowmereChest(inst, flower, bonus)
    --play offering FX
    local x,_,z=flower.Transform:GetWorldPosition()
    SpawnPrefab("lavaarena_player_revive_from_corpse_fx").Transform:SetPosition(x,_,z)

    SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)

    --locate and spawn reward
    inst:DoTaskInTime(2.5, function()
	local jackReward =inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere_rewards
	local rewardInfo = {}

	if bonus == true then
	    --Book of Gallowmere Page x4
	    table.insert(rewardInfo, "sdf_book_of_gallowmere_restored_vellum")
	    table.insert(rewardInfo, "sdf_book_of_gallowmere_restored_vellum")
	    table.insert(rewardInfo, "sdf_book_of_gallowmere_restored_vellum")
	    table.insert(rewardInfo, "sdf_book_of_gallowmere_restored_vellum")

	    --Normal rewards
	    table.insert(rewardInfo, jackReward:GetReward(jackReward:GetRewardBank()))
	    table.insert(rewardInfo, jackReward:GetReward(jackReward:GetRewardBank()))
	    table.insert(rewardInfo, jackReward:GetReward(jackReward:GetRewardBank()))

	    --Bonus Reward
	    if TUNING.SDF_JACK_OF_THE_GREEN_4TH_RIDDLE_RARITY == true then
		table.insert(rewardInfo, jackReward:GetBonusReward(jackReward:GetBonusRewardBank()))
	    else
		table.insert(rewardInfo, jackReward:GetReward(jackReward:GetRewardBank()))
	    end

	    --Make Bonus Chest
	    local rewardChest = SpawnPrefab("sdf_chest_riddle")
	    rewardChest.Transform:SetPosition(x,_,z)
	    rewardChest.components.lootdropper:SetLoot(rewardInfo)
	    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
	    SpawnPrefab("green_leaves").Transform:SetPosition(x,_-1,z)

	else
	    --Book of Gallowmere Page x2
	    table.insert(rewardInfo, "sdf_book_of_gallowmere_restored_vellum")
	    table.insert(rewardInfo, "sdf_book_of_gallowmere_restored_vellum")

	    --Normal rewards
	    table.insert(rewardInfo, jackReward:GetReward(jackReward:GetRewardBank()))
	    table.insert(rewardInfo, jackReward:GetReward(jackReward:GetRewardBank()))
	    table.insert(rewardInfo, jackReward:GetReward(jackReward:GetRewardBank()))

	    --Make Chest
	    local rewardChest = SpawnPrefab("sdf_chest_riddle")
	    rewardChest.Transform:SetPosition(x,_,z)
	    rewardChest.components.lootdropper:SetLoot(rewardInfo)
	    SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
	    SpawnPrefab("green_leaves").Transform:SetPosition(x,_-1,z)
	end
    end)
end

local function MakeBookOfGallowmere(inst, flower)
    --play offering FX
    local x,_,z=flower.Transform:GetWorldPosition()
    SpawnPrefab("lavaarena_player_revive_from_corpse_fx").Transform:SetPosition(x,_,z)

    SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)

    --locate and spawn reward
    inst:DoTaskInTime(2.5, function()

	--Make book of gallowmere
	local rewardBookOfGallowmere = SpawnPrefab("sdf_book_of_gallowmere")
	rewardBookOfGallowmere:CreateNewBookFn()
	rewardBookOfGallowmere.Transform:SetPosition(x,_,z)

	--riddleflower float animation
	rewardBookOfGallowmere.AnimState:PlayAnimation("riddleflower", true)

	SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
	SpawnPrefab("green_leaves").Transform:SetPosition(x,_-1,z)
    end)
end

local function MakeLifebottle(inst, flower)
    --play offering FX
    local x,_,z=flower.Transform:GetWorldPosition()
    SpawnPrefab("lavaarena_player_revive_from_corpse_fx").Transform:SetPosition(x,_,z)

    SpawnPrefab("archive_lockbox_player_fx").Transform:SetPosition(x,_,z)

    --locate and spawn reward
    inst:DoTaskInTime(2.5, function()

	--Make lifebottle
	local rewardLifebottle = SpawnPrefab("sdf_lifebottle")
	rewardLifebottle.Transform:SetPosition(x,_,z)

	--runestone float animation
	rewardLifebottle.AnimState:PlayAnimation("runestone", true)

	SpawnPrefab("sleepbomb_burst").Transform:SetPosition(x,_,z)
	SpawnPrefab("green_leaves").Transform:SetPosition(x,_-1,z)
    end)
end

local MUST_HAVE_TAGS = {"sdf_jack_of_the_green_flower_chest"}
local CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 3

local function aoeFlowerChestSpotCheck(inst, bonus)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find flower chest spot
	if v ~= nil then
	    --make chest
	    MakeBookOfGallowmereChest(inst, v, bonus)
	end
    end
    return false
end

local function aoeFlowerBookOfGallowmereSpotCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find flower chest spot
	if v ~= nil then
	    --make book of gallowmere
	    MakeBookOfGallowmere(inst, v)
	end
    end
    return false
end

local function aoeFlowerLifebottleSpotCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find flower chest spot
	if v ~= nil then
	    --make lifebottle
	    MakeLifebottle(inst, v)
	end
    end
    return false
end

local function ShouldAcceptItem(inst, item)
    --check if item is needed by riddle
    local bookOfGallowmereRiddleBank = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetRiddleBank()
    local currentBookOfGallowmereRiddleID = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetCurrentRiddle()
    local bookOfGallowmereRiddle = bookOfGallowmereRiddleBank[currentBookOfGallowmereRiddleID]

    --accept
    if bookOfGallowmereRiddle[2] == item.prefab then
	return true
    end

    --reject
    return false
end

local function OnGetItemFromPlayer(inst, giver, item)
    --Jack accepts item
    local bookOfGallowmereRiddleBank = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetRiddleBank()
    local currentBookOfGallowmereRiddleID = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetCurrentRiddle()

    --remove trades
    inst:RemoveComponent("trader")

    --Set Counter book of gallowmere riddle id
    local bookOfGallowmereRiddleCounter = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetRiddleCounter() + 1
    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:SetCounterRiddle(bookOfGallowmereRiddleCounter)

    --Set Previous book of gallowmere riddle id
    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:SetPreviousRiddle(currentBookOfGallowmereRiddleID)

    --Set current book of gallowmere riddle id
    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:SetCurrentRiddle(0)

    --Jack answers riddle
    inst.talked = true
    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_CORRECT[math.random(#STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_CORRECT)], 4)

    --Player sanity heal
    if giver and giver.components.sanity then
	giver.components.sanity:DoDelta(TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_SANITY_INSPIRE)
    end

    inst:DoTaskInTime(4, function()
	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_ANSWERS[currentBookOfGallowmereRiddleID], 6)
    end)
    inst:DoTaskInTime(10, function()
	if bookOfGallowmereRiddleCounter >= 4 then
	    --Set counter book of gallowmere riddle id
	    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:SetCounterRiddle(0)

	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_REWARD_BONUS[math.random(#STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_REWARD_BONUS)], 4)
	else
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_REWARD[math.random(#STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_REWARD)], 4)
	end
    end)
    inst:DoTaskInTime(12, function()
	--SDF book of gallowmere riddle counter
	if giver.prefab == "sdf" then
	    local bookOfGallowmereRiddleCounter = giver.components.sdf_jack_of_the_green_riddle_quest:GetBookOfGallowmereRiddleCounter()

	    --Increase riddle counter
	    giver.components.sdf_jack_of_the_green_riddle_quest:SetBookOfGallowmereRiddleCounter(bookOfGallowmereRiddleCounter + 1)

	    --Skill Tree Insight Lock 2
	    if TheGenericKV:GetKV("sdf_book_of_gallowmere_riddles_completed") == "1" then
	    else
		if (bookOfGallowmereRiddleCounter + 1) >= TUNING.SDF_SKILLSET_SKULL_INSIGHT_BOOK_OF_GALLOWMERE_RIDDLES then
		    SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, giver.userid, "sdf_book_of_gallowmere_riddles_completed")
		end
	    end
	end

	--Chest Reward
	if bookOfGallowmereRiddleCounter >= 4 then
	    --create bonus reward chest
	    aoeFlowerChestSpotCheck(inst, true)
	else
	    --create reward chest
	    aoeFlowerChestSpotCheck(inst, false)
	end
    end)

    inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,12))
end

local function OnRefuseItem(inst, giver, item)
    --Jack rejects item
    inst.talked = true
    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_WRONG[math.random(#STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_WRONG)], 4)

    --Player sanity drain
    if giver then
	if giver.components.sanity then
	    giver.components.sanity:DoDelta(-TUNING.SDF_JACK_OF_THE_GREEN_RIDDLE_SANITY_DESPAIR)
	end
    end

    inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,4))
end

local function repeatBookOfGallowmereRiddle(inst, bookofgallowmereriddleid)
    --Jack repeats riddle Pre
    inst.talked = true
    local bookOfGallowmereRiddleCounter = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetRiddleCounter()

    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_COUNTER_PRE[bookOfGallowmereRiddleCounter], 4)

    inst:DoTaskInTime(4, function()
	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES[bookofgallowmereriddleid], 8)
    end)
    inst:DoTaskInTime(12, function()
	--Say next is bonus reward
	if bookOfGallowmereRiddleCounter >= 3 then
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_BONUS_REMINDER, 4)
	end

	--Allow Jack to take Items
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(ShouldAcceptItem)
	inst.components.trader.onaccept = OnGetItemFromPlayer
	inst.components.trader.onrefuse = OnRefuseItem
	inst.components.trader.deleteitemonaccept = false
    end)

    --for bonus reward speech time
    if bookOfGallowmereRiddleCounter >= 3 then
	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,16))
    else
	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,12))
    end
end

local function startNewBookOfGallowmereRiddle(inst, bookofgallowmereriddleid)
    local bookOfGallowmereRiddleBank = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetRiddleBank()
    local newBookOfGallowmereRiddle = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetRiddle(bookOfGallowmereRiddleBank)
    local previousBookOfGallowmereRiddleID = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetPreviousRiddle()

    --check if not repeated riddle
    if newBookOfGallowmereRiddle ~= nil then
	if newBookOfGallowmereRiddle[1] ~= 0 and newBookOfGallowmereRiddle[1] ~= bookofgallowmereriddleid and newBookOfGallowmereRiddle[1] ~= previousBookOfGallowmereRiddleID then

	    --Set riddle ID
	    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:SetCurrentRiddle(newBookOfGallowmereRiddle[1])

	    --set riddle counter
	    local bookOfGallowmereRiddleCounter = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetRiddleCounter()

	    --Jack says new riddle Pre
	    inst.talked = true
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_COUNTER_PRE[bookOfGallowmereRiddleCounter], 4)

	    inst:DoTaskInTime(4, function()
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES[newBookOfGallowmereRiddle[1]], 8)
	    end)
	    inst:DoTaskInTime(12, function()
		--Say next is bonus reward
		if bookOfGallowmereRiddleCounter >= 3 then
		    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_BONUS_REMINDER, 4)
		end

		 --Allow Jack to take Items
		inst:AddComponent("trader")
		inst.components.trader:SetAcceptTest(ShouldAcceptItem)
		inst.components.trader.onaccept = OnGetItemFromPlayer
		inst.components.trader.onrefuse = OnRefuseItem
		inst.components.trader.deleteitemonaccept = false

	    end)

	    --for bonus reward speech time
	    if bookOfGallowmereRiddleCounter >= 3 then
		inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,16))
	    else
		inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,12))
	    end
	else
	    --Set riddle ID
	    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:SetCurrentRiddle(0)

	    inst.talked = true
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RIDDLES_RESET, 4)

	    inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,4))
	end
    end
end

local function addSDFtags(inst, sdf, riddleNumber)
    sdf:AddTag("sdf_riddle_"..riddleNumber.."_active")
    inst:AddTag("sdf_riddle_"..riddleNumber.."_active")
end

local function removeSDFtags(inst, sdf, riddleNumber)
    if sdf:HasTag("sdf_riddle_"..riddleNumber.."_active") then
	sdf:RemoveTag("sdf_riddle_"..riddleNumber.."_active")
    end
    if inst:HasTag("sdf_riddle_"..riddleNumber.."_active") then
	inst:RemoveTag("sdf_riddle_"..riddleNumber.."_active")
    end
end

local function resetSDFsolved(inst, sdf, riddleNumber)
    local riddleSolvedIdLock = sdf.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLock()
    sdf.components.sdf_jack_of_the_green_riddle_quest:RemoveRiddleSolvedIdLock(riddleSolvedIdLock,riddleNumber)
end

local function riddleBankSDFFirst(inst, sdf, riddleNumber)

    if riddleNumber == 1 then
	--reset solved for fresh start
	resetSDFsolved(inst, sdf, riddleNumber)

	inst.talked = true	

	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF[0], 4)
	inst:DoTaskInTime(4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF[1], 4)
	end)
	inst:DoTaskInTime(8, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF[2], 4)
	end)
	inst:DoTaskInTime(12, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF[3], 6)
	    sdf.components.sdf_jack_of_the_green_riddle_quest:EnableMeetJack()
	end)
	inst:DoTaskInTime(18, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_ONE[0], 4)
	end)
	inst:DoTaskInTime(22, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_ONE[1], 6)

	    --Activate Riddle
	    addSDFtags(inst, sdf, riddleNumber)
	end)
	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,28))
    end
end

local function riddleBankSDFStart(inst, sdf, riddleNumber)
    if riddleNumber == 1 then

	--reset solved for fresh start
	resetSDFsolved(inst, sdf, riddleNumber)

	inst.talked = true

	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_ONE[0], 4)

	inst:DoTaskInTime(4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_ONE[1], 6)

	    --Activate Riddle
	    addSDFtags(inst, sdf, riddleNumber)
	end)
	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,10))
    end

    if riddleNumber == 2 then
	inst.talked = true

	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_TWO, 6)

	--Activate Riddle
	addSDFtags(inst, sdf, riddleNumber)

	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,6))
    end

    if riddleNumber == 3 then
	inst.talked = true

	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_THREE, 8)

	--Activate Riddle
	addSDFtags(inst, sdf, riddleNumber)

	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,8))
    end

    if riddleNumber == 4 then
	inst.talked = true

	inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_FOUR, 10)

	--Activate Riddle
	addSDFtags(inst, sdf, riddleNumber)

	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,10))
    end
end

local function riddleBankSDFEnd(inst, sdf, riddleNumber)
    --Complete Riddle 1 Most likely to change just for the final riddle
    if riddleNumber == 4 then
	--Complete Riddle
	local riddleCompletedIdLock = sdf.components.sdf_jack_of_the_green_riddle_quest:GetRiddleCompletedIdLock()
	sdf.components.sdf_jack_of_the_green_riddle_quest:SetCompletedIdLock(riddleCompletedIdLock,riddleNumber)

	--reset tags
	removeSDFtags(inst, sdf, riddleNumber)

	--Activate Riddle Master
	sdf.components.sdf_jack_of_the_green_riddle_quest:EnableRiddleMaster()

	inst.talked = true

	--greet
	inst:DoTaskInTime(0, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_FREE_PASSAGE[0], 4)
	end)
	inst:DoTaskInTime(4, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_FREE_PASSAGE[1], 6)
	end)
	inst:DoTaskInTime(10, function()
	    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_SDF_RIDDLE_FREE_PASSAGE[2], 4)
	end)

	inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,14))
    else
	--Complete Riddle
	local riddleCompletedIdLock = sdf.components.sdf_jack_of_the_green_riddle_quest:GetRiddleCompletedIdLock()
	sdf.components.sdf_jack_of_the_green_riddle_quest:SetCompletedIdLock(riddleCompletedIdLock,riddleNumber)

	--reset tags
	removeSDFtags(inst, sdf, riddleNumber)

	--Activate Next Riddle
	riddleBankSDFStart(inst, sdf, riddleNumber + 1)
    end
end

local function riddleBankSDFReset(inst, sdf, riddleNumber)
    inst.talked = true
    inst:DoTaskInTime(4, function(inst)
	inst.talked = false
    end)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_RESET_SDF, 4)
    removeSDFtags(inst, sdf, riddleNumber)

    --reset solved
    resetSDFsolved(inst, sdf, riddleNumber)
end

local function checkSDFActiveTags(inst, sdf)
    if sdf:HasTag("sdf_riddle_1_active") then
	return 1
    elseif sdf:HasTag("sdf_riddle_2_active") then
	return 2
    elseif sdf:HasTag("sdf_riddle_3_active") then
	return 3
    elseif sdf:HasTag("sdf_riddle_4_active") then
	return 4
    end
	return 0
end

local function ongrow(inst)
end

local function onharvest(inst, picker, produce)
    if inst.components.harvestable then

	inst.components.harvestable:SetGrowTime(nil)
	inst.components.harvestable.pausetime = nil
	inst.components.harvestable:StopGrowing()

	--Remove pickable
	inst.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)

	--Jacks Logic
	--SDF
	if picker.prefab == "sdf" then
	    local riddleMaster = picker.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleMaster()

	    --check is  riddle master
	    if riddleMaster == true then
		local bookOfGallowmereEnabled = picker.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmere()
		local jackBookOfGallowmereEnabled = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:CheckBookOfGallowmere()

		--check if found book of gallowmere damaged
		if jackBookOfGallowmereEnabled == true then
		    --check if on book of gallowmere riddle
		    local currentBookOfGallowmereRiddleID = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetCurrentRiddle()

		    if currentBookOfGallowmereRiddleID > 0 then
			--repeat book of gallowmere riddle
			repeatBookOfGallowmereRiddle(inst, currentBookOfGallowmereRiddleID)
		    else
			--get new book of gallowmere riddle
			startNewBookOfGallowmereRiddle(inst, currentBookOfGallowmereRiddleID)
		    end
		else
		    inst.talked = true
		    --Thinking of riddles before book of gallowmere offering
		    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_THINKING[math.random(#STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_THINKING)], 6)

		    inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,6))
		end
	    else
		--check for active tags
		local activeRiddleSDF = checkSDFActiveTags(inst, picker)

		--SDF has active Riddle
		if activeRiddleSDF ~= 0 then
		    --check turn in
		    local riddleSolvedIdLock = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLock()
		    local activeRiddleSDFSolved = picker.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleSolvedIdLock(riddleSolvedIdLock,activeRiddleSDF)

		    --Turn in riddle
		    if activeRiddleSDFSolved == true then
			--turn in riddle, turn completed to true
			riddleBankSDFEnd(inst, picker, activeRiddleSDF)

		    --Re ask the riddle
		    else
			--Reset riddle for sdf
			removeSDFtags(inst, picker, activeRiddleSDF)
			riddleBankSDFStart(inst, picker, activeRiddleSDF)
		    end

		--SDF has no active Riddle   
		elseif activeRiddleSDF == 0 then

		    --Look to see if turning in a riddle
		    local riddleSolvedIdLock = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLock()
		    local riddleSolvedRiddle = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleSolvedIdLockNew(riddleSolvedIdLock)

		    --Look up riddle to start
		    local riddleCompletedIdLock = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleCompletedIdLock()
		    local newRiddle = picker.components.sdf_jack_of_the_green_riddle_quest:GetRiddleCompletedIdLockNew(riddleCompletedIdLock)

		    --Turn in riddle
		    if riddleSolvedRiddle > newRiddle or riddleSolvedRiddle == 0 and newRiddle ~= 0 then
			--Turn in quest
			riddleBankSDFEnd(inst, picker, newRiddle)

		    --Start new Riddle
		    else
			local meetingJack = picker.components.sdf_jack_of_the_green_riddle_quest:CheckMeetJack()

			--First time meeting Jack
			if meetingJack == false then
			    riddleBankSDFFirst(inst, picker, newRiddle)

			--Starting New Riddle
			else
			    riddleBankSDFStart(inst, picker, newRiddle)
			end
		    end
		end
	    end

	--normal player riddles
	else
	    local jackBookOfGallowmereEnabled = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:CheckBookOfGallowmere()

	    --check if book of gallowmere offered
	    if jackBookOfGallowmereEnabled == true then
		--check if on book of gallowmere riddle
		local currentBookOfGallowmereRiddleID = inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:GetCurrentRiddle()

		if currentBookOfGallowmereRiddleID > 0 then
		    --repeat book of gallowmere riddle
		    repeatBookOfGallowmereRiddle(inst, currentBookOfGallowmereRiddleID)
		else
		    --get new book of gallowmere riddle
		    startNewBookOfGallowmereRiddle(inst, currentBookOfGallowmereRiddleID)
		end
	    else
		inst.talked = true
		--Looking for SDF to solve riddles
		inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_COMMON_LOOKINGFORSDF[0], 4)
		inst:DoTaskInTime(4, function()
		    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_COMMON_LOOKINGFORSDF[1], 4)
		end)
		inst:DoTaskInTime(8, function()
		    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_GREETING_COMMON_LOOKINGFORSDF[2], 4)
		end)
		inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,12))
	    end
	end
    end
end

local function jackturnoff(inst)
    if inst.JACK_ON == true then
	inst.JACK_ON = false
	inst.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)

        inst.AnimState:PlayAnimation("jack_of_the_green_glow_end")
        inst.AnimState:PushAnimation("idle")
    end

    if inst:HasTag("sdf_book_of_gallowmere_offering_jack_of_the_green") then
	inst:RemoveTag("sdf_book_of_gallowmere_offering_jack_of_the_green")
    end
end

local function jackturnon(inst, player)
    --jack glow on
    inst.JACK_ON = true
    inst.AnimState:PlayAnimation("jack_of_the_green_glow_start")
    inst.AnimState:PushAnimation("jack_of_the_green_glow")

    --greet
    inst:DoTaskInTime(0.3,function()
	--Check is Sdf and has Book of Gallowmere Damaged
	if player.prefab == "sdf" then
	    local riddleMaster = player.components.sdf_jack_of_the_green_riddle_quest:CheckRiddleMaster()
	    local bookOfGallowmereEnabled = player.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmere()
	    if riddleMaster == true and bookOfGallowmereEnabled == false and player.components.inventory:Has("sdf_book_of_gallowmere_damaged", 1, true) then
		if inst.talked == false then
		    inst.talked = true
		    --Jack asks for Book of Gallowmere
		    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_FOUND[0], 6)

		    inst:DoTaskInTime(6, function()
			inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
			inst.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_FOUND[1], 4)
		    end)
		    inst:DoTaskInTime(10, function()
			inst:AddTag("sdf_book_of_gallowmere_damaged_offering_jack_of_the_green")
		    end)

		    inst.talkingtask = inst:DoTaskInTime(0, starttalking(inst,10))
	        end
	    else
		if riddleMaster == true then
		    local handsItem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		    if player.components.inventory:Has("sdf_book_of_gallowmere", 1, true) or (handsItem and handsItem.prefab == "sdf_book_of_gallowmere") then
			inst:AddTag("sdf_book_of_gallowmere_offering_jack_of_the_green")
		    end
		end

		if inst.talked == false then
		    inst.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)
		end
	    end
	else
	    if inst.talked == false then
		inst.components.harvestable:SetUp("", 1, 1, onharvest, ongrow)
	    end
	end
    end)
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

    inst.MiniMapEntity:SetIcon("sdf_jack_of_the_green_mm.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    local s = 1.4
    inst.Transform:SetScale(s,s,s)
     
    inst.AnimState:SetBank("sdf_jack_of_the_green")
    inst.AnimState:SetBuild("sdf_jack_of_the_green")
    inst.AnimState:PlayAnimation("idle")

    MakeObstaclePhysics(inst, 1.3)

    inst:AddTag("structure")
    inst:AddTag("prototyper")
    inst:AddTag("sdf_jack_of_the_green")
    inst:AddTag("sdf_witch_talisman_offering")

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

    --Adding Book of Gallowmere Riddles
    inst:AddComponent("sdf_jack_of_the_green_riddle_book_of_gallowmere")
    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:SetRiddleBank(sdf_jack_of_the_green_riddle_book_of_gallowmere_riddle)

    --Adding RewardsBank
    inst:AddComponent("sdf_jack_of_the_green_riddle_book_of_gallowmere_rewards")
    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere_rewards:SetRewardBank(sdf_jack_of_the_green_riddle_book_of_gallowmereloots)
    inst.components.sdf_jack_of_the_green_riddle_book_of_gallowmere_rewards:SetBonusRewardBank(sdf_jack_of_the_green_riddle_book_of_gallowmereloots_rare)

    inst:AddComponent("harvestable")

    inst:AddComponent("inspectable")
 
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2.1,2.3)
    inst.components.playerprox:SetOnPlayerNear(jackturnon)
    inst.components.playerprox:SetOnPlayerFar(jackturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.talked = false
    inst.talkingtask = nil
    inst.TalkedFn = function() starttalking(inst, 48) end
    inst.TalkedWitchTalismanFn = function() starttalking(inst, 6) end
    inst.AoeFlowerBookOfGallowmereSpotCheck = function() aoeFlowerBookOfGallowmereSpotCheck(inst) end
    inst.AoeFlowerLifebottleSpotCheck = function() aoeFlowerLifebottleSpotCheck(inst) end

    inst.icon = nil
    inst:DoTaskInTime(0, showOnMap)

    return inst
end

return  Prefab("sdf_jack_of_the_green", fn, assets)