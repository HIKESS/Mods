GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_BOOK_OF_GALLOWMERE_OFFERING_JACK_OF_THE_GREEN"
local name = STRINGS.ACTIONHANDLER_SDF_BOOK_OF_GALLOWMERE_OFFERING_JACK_OF_THE_GREEN


local fn = function(act)
    if act.doer.prefab == "sdf" and act.target.JACK_ON == true then

	--Stops from repeated book of gallowmere damaged at once
	if act.target:HasTag("sdf_book_of_gallowmere_damaged_offering_jack_of_the_green") then
	    act.target:RemoveTag("sdf_book_of_gallowmere_damaged_offering_jack_of_the_green")
	end
	if act.target:HasTag("sdf_book_of_gallowmere_offering_jack_of_the_green") then
	    act.target:RemoveTag("sdf_book_of_gallowmere_offering_jack_of_the_green")
	end

	--already completed book of gallowmere quest
	if act.doer.components.sdf_jack_of_the_green_riddle_quest:CheckBookOfGallowmereRestored() == true then
	    --Jack talks
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_REOFFERING[math.random(#STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_REOFFERING)], 5)

	    act.target:TalkedFn()
	    return true
	end

	--check if book of gallowmere is restored
	local totalBookOfGallowmereRestored = 0
	if act.invobject.components.container:Has("sdf_book_of_gallowmere_entries_bosses", 1) then
	    local bossesSlot = act.invobject.components.container:GetItemInSlot(1)
	    if bossesSlot then
		totalBookOfGallowmereRestored = (totalBookOfGallowmereRestored + bossesSlot.components.finiteuses:GetPercent())
	    end
	end
	if act.invobject.components.container:Has("sdf_book_of_gallowmere_entries_enemies", 1) then
	    local enemiesSlot = act.invobject.components.container:GetItemInSlot(2)
	    if enemiesSlot then
		totalBookOfGallowmereRestored = (totalBookOfGallowmereRestored + enemiesSlot.components.finiteuses:GetPercent())
	    end
	end
	if act.invobject.components.container:Has("sdf_book_of_gallowmere_entries_friendlies", 1) then
	    local friendliesSlot = act.invobject.components.container:GetItemInSlot(3)
	    if friendliesSlot then
		totalBookOfGallowmereRestored = (totalBookOfGallowmereRestored + friendliesSlot.components.finiteuses:GetPercent())
	    end
	end
	if act.invobject.components.container:Has("sdf_book_of_gallowmere_entries_inventory", 1) then
	    local inventorySlot = act.invobject.components.container:GetItemInSlot(4)
	    if inventorySlot then
		totalBookOfGallowmereRestored = (totalBookOfGallowmereRestored + inventorySlot.components.finiteuses:GetPercent())
	    end
	end

	if totalBookOfGallowmereRestored >= 4 then
	    --book of gallowmere is restored

	    --Enable Restored Book of Gallowmere
	    act.doer.components.sdf_jack_of_the_green_riddle_quest:EnableBookOfGallowmereRestored()
	    act.doer:AddTag("sdf_book_of_gallowmere_builder")

	    --Skill Tree Insight Lock 3
	    if TheGenericKV:GetKV("sdf_book_of_gallowmere_restored") == "1" then
	    else
		SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, act.doer.userid, "sdf_book_of_gallowmere_restored")
	    end

	    --Jack talks
	    act.target.talked = true

	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[0], 6)
	    act.target:DoTaskInTime(7, function()
		act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[1], 6)
	    end)
	    act.target:DoTaskInTime(14, function()
		act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[2], 6)
	    end)
	    act.target:DoTaskInTime(21, function()
		act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[3], 6)
	    end)
	    act.target:DoTaskInTime(27, function()
		act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[4], 6)
	    end)
	    act.target:DoTaskInTime(29, function()
		--spawns a Life Bottle in flowers
		act.target:AoeFlowerLifebottleSpotCheck()

		--Enable Restored Book of Gallowmere
		--act.doer.components.sdf_jack_of_the_green_riddle_quest:EnableBookOfGallowmereRestored()
		--act.doer:AddTag("sdf_book_of_gallowmere_builder")

		--Skill Tree Insight Lock 3
		--if TheGenericKV:GetKV("sdf_book_of_gallowmere_restored") == "1" then
		--else
		    --SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, act.doer.userid, "sdf_book_of_gallowmere_restored")
		--end
	    end)

	    --Skill Tree Insight
	    if act.doer.components.skilltreeupdater:IsActivated("sdf_skull_4") then
		act.target:DoTaskInTime(34, function()
		    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[6], 6)
		end)
		act.target:DoTaskInTime(41, function()
		    if act.target.JACK_ON == true then
			act.target.JACK_ON = false
			act.target.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)

			act.target.AnimState:PlayAnimation("jack_of_the_green_glow_end")
			act.target.AnimState:PushAnimation("idle")
		    end
		end)
	    else
		act.target:DoTaskInTime(34, function()
		    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[5], 6)
		end)
		act.target:DoTaskInTime(40, function()
		    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
		    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_RESTORED_OFFERING[6], 6)
		end)
		act.target:DoTaskInTime(47, function()
		    if act.target.JACK_ON == true then
			act.target.JACK_ON = false
			act.target.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)

			act.target.AnimState:PlayAnimation("jack_of_the_green_glow_end")
			act.target.AnimState:PushAnimation("idle")
		    end
		end)
	    end
	else
	    --book of gallowmere in progress
	    --Jack talks
	    act.target.talked = true

	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_OFFERING[math.random(#STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_OFFERING)], 5)

	    act.target:DoTaskInTime(6, function()
		if act.target.JACK_ON == true then
		    act.target.JACK_ON = false
		    act.target.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)

		    act.target.AnimState:PlayAnimation("jack_of_the_green_glow_end")
		    act.target.AnimState:PushAnimation("idle")
		end
	    end)
	end

	act.target:TalkedFn()
	return true
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_book_of_gallowmere_offering_jack_of_the_green"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_book_of_gallowmere_offering_jack_of_the_green") then
	table.insert(actions, ACTIONS.SDF_BOOK_OF_GALLOWMERE_OFFERING_JACK_OF_THE_GREEN)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_BOOK_OF_GALLOWMERE_OFFERING_JACK_OF_THE_GREEN, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_BOOK_OF_GALLOWMERE_OFFERING_JACK_OF_THE_GREEN,state))