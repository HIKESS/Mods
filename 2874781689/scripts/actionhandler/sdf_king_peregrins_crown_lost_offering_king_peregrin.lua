GLOBAL.setmetatable(env,{__index=function(a,b)return GLOBAL.rawget(GLOBAL,b)end})

--Give Lost Crown
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler

local id = "SDF_KING_PEREGRINS_CROWN_LOST_OFFERING_KING_PEREGRIN"
local name = STRINGS.ACTIONHANDLER_SDF_KING_PEREGRINS_CROWN_LOST_OFFERING_KING_PEREGRIN


local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function ClearStatusAilments(doer)
    if doer.components.freezable ~= nil and doer.components.freezable:IsFrozen() then
        doer.components.freezable:Unfreeze()
    end
    if doer.components.pinnable ~= nil and doer.components.pinnable:IsStuck() then
        doer.components.pinnable:Unstick()
    end
end

local function ForceStopHeavyLifting(doer)
    if doer.components.inventory:IsHeavyLifting() then
        doer.components.inventory:DropItem(
            doer.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

local function zoomInCamera(doer, target)
    --player
    ClearStatusAilments(doer)
    ForceStopHeavyLifting(doer)
    doer:SetCameraDistance(20) --20
    doer.Physics:Stop()
    doer.components.locomotor:Stop()
    doer.components.inventory:Close(true) --true to keep activeitem over seamless player swap
    doer:PushEvent("ms_closepopups")
    doer.components.health:SetInvincible(true)
    if doer.components.playercontroller ~= nil then
	doer.components.playercontroller:Enable(false)
	doer.components.playercontroller:EnableMapControls(false)
    end

    --king
    target.Physics:Stop()
    target.components.locomotor:Stop()
    target.components.locomotor.walkspeed = 0
    target.components.locomotor.runspeed = 0
end

local function zoomOutCamera(doer, target)
    --player
    if doer.components.playercontroller ~= nil then
	doer.components.playercontroller:EnableMapControls(true)
	doer.components.playercontroller:Enable(true)
    end
    doer:SetCameraDistance()
    doer.components.health:SetInvincible(false)
    doer.components.inventory:Open(true)

    --king
    target.components.locomotor.walkspeed = TUNING.SDF_KING_PEREGRIN_GHOST_SPEED
    target.components.locomotor.runspeed = TUNING.SDF_KING_PEREGRIN_GHOST_SPEED * 3
end


local fn = function(act)

    if act.doer.prefab == "sdf" then
	if act.doer.components.sdf_king_peregrin_quest:GetCrownOfferedStatus() == true then
	    return false
	end

	--camera close up
	zoomInCamera(act.doer, act.target)

	--King talks
	act.target:AddTag("questing")
	act.target.talked_paused = true
	act.target.talked = true
	if act.target.talkingtask ~= nil then
	    act.target.talkingtask:Cancel()
	end

	act.target.sg:GoToState("quest_begin", true)
	act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/joy")
	act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[0], 8)

	act.target:DoTaskInTime(8, function()
	    act.target.sg:GoToState("idle_to_sad")
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[1], 10)
	end)

	act.target:DoTaskInTime(18, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[2], 6)
	end)

	act.target:DoTaskInTime(22, function()
	    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_SDF_KING_PEREGRIN_CROWN_LOST_OFFERING_JAW"))
	end)

	act.target:DoTaskInTime(26, function()
	    act.target.sg:GoToState("idle_to_sad")
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[3], 4)
	end)

	act.target:DoTaskInTime(30, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[4], 8)
	end)

	act.target:DoTaskInTime(38, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[5], 4)
	end)

	--give empowered crown
	act.target:DoTaskInTime(40, function()

	    --update Crown Offered Status
	    if act.doer.components.sdf_king_peregrin_quest:GetCrownOfferedStatus() == false then
		act.doer.components.sdf_king_peregrin_quest:SetCrownOfferedStatus()
	    end

	    --Remove Lost Crown
	    act.invobject:Remove()

	    --create king peregrins crown
	    local x, y, z = act.target.Transform:GetWorldPosition()
	    y = 4.5

	    local angle
	    if act.doer ~= nil and act.doer:IsValid() then
		angle = 180 - act.doer:GetAngleToPoint(x, 0, z)
	    else
		local down = TheCamera:GetDownVec()
		angle = math.atan2(down.z, down.x) / DEGREES
	    end

	    --Destory all old King Crown
	    local oldKingCrown = act.doer.components.sdf_key_item_inventory:GetKeyItem("sdf_king_peregrins_crown")
	    if oldKingCrown ~= nil then
		act.doer.components.sdf_key_item_inventory:RemoveKeyItem(oldKingCrown)
	    end

	    local kingPeregrinsCrown = SpawnPrefab("sdf_king_peregrins_crown")
	    kingPeregrinsCrown.Transform:SetPosition(x, y, z)
	    act.doer.components.sdf_key_item_inventory:SetKeyItem(kingPeregrinsCrown, act.doer)
	    launchitem(kingPeregrinsCrown, angle)
	end)

	act.target:DoTaskInTime(42, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[6], 6)
	end)

	act.target:DoTaskInTime(48, function()
	    act.target.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
	    act.target.components.talker:Say(STRINGS.ANNOUNCE_SDF_KING_PEREGRIN_OFFERED_CROWN_LOST_SDF[7], 8)
	end)

	--king takes leave
	act.target:DoTaskInTime(56, function()
	    --camera reset
	    zoomOutCamera(act.doer, act.target)

	    --act.target:RemoveTag("questing")
	    --act.target.talked_paused = false
	    --act.target.talked = false
	    act.target.sg:GoToState("quest_finished")
	end)

	return true
    end
    return false
end

AddAction(id,name,fn)

local type = "USEITEM"
local component = "sdf_king_peregrins_crown_lost_offering_king_peregrin"
local testfn = function(inst, doer, target, actions)
    if target:HasTag("sdf_king_peregrins_crown_lost_offering") and target:HasTag("sdf_king_peregrin") then
	table.insert(actions, ACTIONS.SDF_KING_PEREGRINS_CROWN_LOST_OFFERING_KING_PEREGRIN)
    end
end

AddComponentAction(type, component, testfn)

local state = "give"
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.SDF_KING_PEREGRINS_CROWN_LOST_OFFERING_KING_PEREGRIN, state))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.SDF_KING_PEREGRINS_CROWN_LOST_OFFERING_KING_PEREGRIN,state))