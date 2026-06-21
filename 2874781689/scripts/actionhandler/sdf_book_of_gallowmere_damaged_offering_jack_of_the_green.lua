GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING_JACK_OF_THE_GREEN"
local name = STRINGS.ACTIONHANDLER_SDF_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING_JACK_OF_THE_GREEN


local fn = function(act)
    if act.doer.prefab == "sdf" and act.target.JACK_ON == true then

	--local owner = act.invobject.components.inventoryitem ~= nil and act.invobject.components.inventoryitem.owner or nil
	--local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil

	--Remove book of gallowmere damaged
	act.invobject:Remove()

	--Stops from repeated book of gallowmere damaged at once
	if act.target:HasTag("sdf_book_of_gallowmere_damaged_offering_jack_of_the_green") then
	    act.target:RemoveTag("sdf_book_of_gallowmere_damaged_offering_jack_of_the_green")
	end

	--Jack talks
	act.target.talked = true

	act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[0], 6)
	act.target:DoTaskInTime(6, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[1], 4)
	end)
	act.target:DoTaskInTime(10, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[2], 6)
	end)
	act.target:DoTaskInTime(16, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[3], 6)
	end)
	act.target:DoTaskInTime(22, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[4], 6)
	end)
	act.target:DoTaskInTime(24, function()
	    --learn recipe
	    act.doer.components.builder:UnlockRecipe("sdf_book_of_gallowmere")
	    act.doer:PushEvent("learnrecipe", { teacher = act.target, recipe = GetValidRecipe("sdf_book_of_gallowmere") })

	    --Enable Book of Gallowmere
	    act.doer.components.sdf_jack_of_the_green_riddle_quest:EnableBookOfGallowmere()
	    act.doer:AddTag("sdf_book_of_gallowmere_builder")

	    --spawns a Book of Gallowmere in flowers
	    act.target:AoeFlowerBookOfGallowmereSpotCheck()

	    --Skill Tree Insight Lock 2
	    --if TheGenericKV:GetKV("sdf_reclaim_book_of_gallowmere_damaged") == "1" then
	    --else
		--SendRPCToClient(CLIENT_RPC.UpdateAccomplishment, act.doer.userid, "sdf_reclaim_book_of_gallowmere_damaged")
	    --end
	end)
	act.target:DoTaskInTime(28, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[5], 4)
	end)
	act.target:DoTaskInTime(32, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[6], 4)
	end)
	act.target:DoTaskInTime(36, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[7], 6)
	end)
	act.target:DoTaskInTime(42, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_JACK_OF_THE_GREEN_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING[8], 6)

	    --Enables Book of Gallowmere riddles
	    act.target.components.sdf_jack_of_the_green_riddle_book_of_gallowmere:EnableBookOfGallowmere()
	end)
	act.target:DoTaskInTime(48, function()
	    if act.target.JACK_ON == true then
		act.target.JACK_ON = false
		act.target.components.harvestable:SetUp("", 0, nil, onharvest, ongrow)

		act.target.AnimState:PlayAnimation("jack_of_the_green_glow_end")
		act.target.AnimState:PushAnimation("idle")
	    end
	end)
	act.target:TalkedFn()

	return true
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_book_of_gallowmere_damaged_offering_jack_of_the_green"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_book_of_gallowmere_damaged_offering_jack_of_the_green") then
	table.insert(actions, ACTIONS.SDF_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING_JACK_OF_THE_GREEN)
    end
end

AddComponentAction(type, component, testfn)

local state = "dolongaction"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING_JACK_OF_THE_GREEN, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_BOOK_OF_GALLOWMERE_DAMAGED_OFFERING_JACK_OF_THE_GREEN,state))