local assets =
{
    Asset("ATLAS", "images/inventoryimages/sdf_asgard_golem_giants_ocarina.xml"),
    Asset("IMAGE", "images/inventoryimages/sdf_asgard_golem_giants_ocarina.tex"),

    Asset("ATLAS", "images/map_icons/sdf_asgard_golem_giants_ocarina_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_asgard_golem_giants_ocarina_mm.tex"),

    Asset("ANIM", "anim/sdf_asgard_golem_giants_ocarina.zip"),
    Asset("ANIM", "anim/swap_sdf_axe.zip"),

}

local function ReticuleTargetFn()
    for m=7,0,-.25 do Vector3().x,Vector3().y,Vector3().z = ThePlayer.entity:LocalToWorldSpace(m,0,0)
	if TheWorld.Map:IsPassableAtPoint(Vector3():Get()) and not TheWorld.Map:IsGroundTargetBlocked(Vector3()) then 
	    return Vector3()
	end
    end
    return Vector3()
end

local function getOcarinaAsgardGolem(inst)
    local followers = inst.components.leader:GetFollowersByTag("sdf_asgard_golem")
    for i, v in ipairs(followers) do
        if v ~= nil then
	    if inst.asgardGolem_ID == v.asgardGolem_ID then
		return v
	    end
        end
    end
    return nil
end

local function getPlayerAsgardGolem(inst, owner)
    local followers = owner.components.leader:GetFollowersByTag("sdf_asgard_golem")
    for i, v in ipairs(followers) do
        if v ~= nil then
	    if inst.asgardGolem_ID == v.asgardGolem_ID then
		return v
	    end
        end
    end
    return nil
end

local function checkOcarinaHasAsgardGolem(inst)
    local followers = inst.components.leader:GetFollowersByTag("sdf_asgard_golem")
    for i, v in ipairs(followers) do
        if v ~= nil then
	    if inst.asgardGolem_ID == v.asgardGolem_ID then
		return true
	    end
        end
    end
    return false
end

local function checkPlayerHasAsgardGolem(inst, owner)
    local followers = owner.components.leader:GetFollowersByTag("sdf_asgard_golem")
    for i, v in ipairs(followers) do
        if v ~= nil then
	    if inst.asgardGolem_ID == v.asgardGolem_ID then
		return true
	    end
        end
    end
    return false
end

local function OnPutInInventory(inst, owner)
    --save owner
    inst.oldSummoner = owner

    --give Asgard Golem Leadership to player
    local asgardGolem = getOcarinaAsgardGolem(inst)
    if asgardGolem ~= nil then
	asgardGolem:RemoveComponent("sdf_gallowmere_knight_unteleportable")
	asgardGolem.components.sdf_asgard_golem_tactics:TurnOn(owner)
	asgardGolem:RemoveTag("sdf_asgard_golem_command_stay")
	asgardGolem:AddTag("sdf_asgard_golem_command_follow")
    end
end

local function OnDropped(inst)
    if inst.oldSummoner ~= nil then
	local asgardGolem = getPlayerAsgardGolem(inst, inst.oldSummoner)
	if asgardGolem ~= nil then
	    asgardGolem:RemoveComponent("sdf_gallowmere_knight_unteleportable")
	    asgardGolem.components.sdf_asgard_golem_tactics:TurnOn(inst)
	    asgardGolem:RemoveTag("sdf_asgard_golem_command_stay")
	    asgardGolem:AddTag("sdf_asgard_golem_command_follow")

	    inst.oldSummoner = nil
	end
    end
end

local SHAKE_MAX_DIST_SQ = 140*140
local QUAKE_TIME = 3
local function StartShakeFX(inst)
    for i, v in ipairs(AllPlayers) do
	local distSq = v:GetDistanceSqToInst(inst)
	local k = math.max(0, math.min(1, distSq / SHAKE_MAX_DIST_SQ))
	local intensity = -(k-1)*(k-1)*(k-1)

	if intensity > 0 then
	    v:ShakeCamera(CAMERASHAKE.FULL, QUAKE_TIME, .02, intensity / 3)
	end
    end
end

local function GetPoints(pt)
    local points = {}
    local radius = 0.5
    for i = 1, 2 do
        local theta = 0     
        local circ = 2*PI*radius
        local numPoints = math.ceil(circ * 0.25)
        for p = 1, numPoints do
            if not points[i] then
                points[i] = {}
            end
            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local point = pt + offset
            table.insert(points[i], point)
            theta = theta - (2*PI/numPoints)
        end
        radius = radius + 1.0 --1.5
    end
    return points
end



local function GetSummonableLand(inst, musician)
    local x, y, z = musician.Transform:GetWorldPosition()
    local spawn_radius = TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_RADIUS
    local offset = (FindWalkableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + musician:GetPhysicsRadius(0), 8, false, true, NoHoles, false, true))
    if not offset then
        return nil
    end
    return offset
end

local function SummonAsgardGolem(inst, musician, x, y, z, offset)

    --Check cooldown
    if not inst.components.rechargeable:IsCharged() and checkPlayerHasAsgardGolem(inst, musician) == true then
	if musician.components.talker then
	    musician.components.talker:Say(GetString(musician, "ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONTELEPORTCOOLDOWN")) --on teleport cooldown
	end
	return
    elseif not inst.components.rechargeable:IsCharged() and checkPlayerHasAsgardGolem(inst, musician) == false then
	if musician.components.talker then
	    musician.components.talker:Say(GetString(musician, "ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONSPAWNCOOLDOWN")) --on spawn cooldown
	end
	return
    elseif offset == nil then
	if musician.components.talker then
	    musician.components.talker:Say(GetString(musician, "ANNOUNCE_ASGARDGOLEMGIANTSOCARINAINVALIDLAND")) --no valid land
	end

	--Cooldown
	inst.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_GENERAL_COOLDOWN)

	return

    --Type_B Command and Teleport Asgard Golem
    elseif checkPlayerHasAsgardGolem(inst, musician) == true then
	local asgardGolem = getPlayerAsgardGolem(inst, musician)
	if asgardGolem ~= nil then
	    
	    --Asgard Asleep
	    if asgardGolem.components.sleeper:IsAsleep() then
		if musician.components.talker then
		    musician.components.talker:Say(GetString(musician, "ANNOUNCE_ASGARDGOLEMGIANTSOCARINAONSLEEPING")) --on sleeping
		end

		--Cooldown
		inst.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_GENERAL_COOLDOWN)

		return
	    end


	    --Asgard In combat Mode Change and Optimize Data Type B
	    if asgardGolem.components.combat:HasTarget() == true or asgardGolem.components.combat:InCooldown() == true then

		--Optimize Data Type B
		local leaderHealthPercent = asgardGolem.components.follower.leader.components.health:GetPercentWithPenalty()
		if leaderHealthPercent <= TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_OPTIMIZE_DATA_TYPE_B_ACTIVATE_HEALTH_PERCENT then
		    --Cooldown
		    inst.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_OPTIMIZE_DATA_TYPE_B_COOLDOWN)
		    asgardGolem:HighPoweredBarrierStartFn()

		--Mode Change
		else
		    --Cooldown
		    inst.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_MODE_CHANGE_COOLDOWN)
		    asgardGolem:ModeChangeFn()
		end
		return
	    end


	    --Asgard Teleport
	    asgardGolem.components.talker:Say(STRINGS.ANNOUNCE_SDF_ASGARD_GOLEM_ACTIVATE_TELEPORT, 2)

	    --Cooldown
	    inst.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_TELEPORT_COOLDOWN)

	    --Asgard Hide
	    asgardGolem.components.health:SetInvincible(true)
	    asgardGolem.components.locomotor:Stop()
	    asgardGolem.AnimState:PlayAnimation("hide")
	    asgardGolem:DoTaskInTime(0.2, function()
		asgardGolem.AnimState:PlayAnimation("hit_shield", true)
		asgardGolem:DoTaskInTime(0.1, function()
		    asgardGolem.AnimState:Pause()
		end)
	    end)

	    --earthquake 1
	    local Ax, Ay, Az = asgardGolem.Transform:GetWorldPosition()
	    StartShakeFX(inst)
	    for i = 1, QUAKE_TIME, 1 do
		inst:DoTaskInTime(0.4 + (i * 0.4), function()
		    local aoeRing = SpawnPrefab("groundpoundring_fx")
		    aoeRing.Transform:SetPosition(Ax, 0, Az)
		    aoeRing.Transform:SetScale(0.6,0.6,0.6)
		    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")

		    local points = GetPoints(aoeRing:GetPosition())
		    for k,v in ipairs(points) do
			for j,x in ipairs(v) do
			    inst:DoTaskInTime(0.2 * (k-1), function()
				local aoeGroundPound = SpawnPrefab("groundpound_fx")
				aoeGroundPound.Transform:SetPosition(x:Get())
				aoeGroundPound.Transform:SetScale(0.6,0.6,0.6)
			    end)
			end
		    end
		end)
	    end

	    --Teleport Pre
	    inst:DoTaskInTime(2, function()

		--Asgard Golem invisable
		asgardGolem.AnimState:PlayAnimation("underground")
		asgardGolem.DynamicShadow:SetSize(0.01, 0.01)

		--earthquake 2
		StartShakeFX(inst)
		for i = 1, QUAKE_TIME, 1 do
		    inst:DoTaskInTime(0.4 + (i * 0.4), function()
			local aoeRing = SpawnPrefab("groundpoundring_fx")
			aoeRing.Transform:SetPosition(x + offset.x, 0, z + offset.z)
			aoeRing.Transform:SetScale(0.6,0.6,0.6)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")

			local points = GetPoints(aoeRing:GetPosition())
			for k,v in ipairs(points) do
			    for j,x in ipairs(v) do
				inst:DoTaskInTime(0.2 * (k-1), function()
				    local aoeGroundPound = SpawnPrefab("groundpound_fx")
				    aoeGroundPound.Transform:SetPosition(x:Get())
				    aoeGroundPound.Transform:SetScale(0.6,0.6,0.6)
				end)
			    end
			end
		    end)
		end
	    end)

	    --Teleport
	    inst:DoTaskInTime(3, function()

		--come from ground
		asgardGolem.Transform:SetPosition(x + offset.x, 0, z + offset.z)
		asgardGolem:DoTaskInTime(0.2, function()
		    asgardGolem.components.locomotor:Stop()
		    asgardGolem.AnimState:Resume()
		    asgardGolem.AnimState:PlayAnimation("unhide")
		    asgardGolem.DynamicShadow:SetSize(1.75, 1.75)
		end)

		--follow player
		inst:DoTaskInTime(2, function()
		    asgardGolem.components.health:SetInvincible(false)

		    --leader is player
		    local soulbound = asgardGolem.components.follower.leader
		    if soulbound ~= nil then
			if soulbound:HasTag("player") then
			    asgardGolem:RemoveComponent("sdf_gallowmere_knight_unteleportable")
			    asgardGolem.components.sdf_asgard_golem_tactics:TurnOn(musician)
			    asgardGolem:RemoveTag("sdf_asgard_golem_command_stay")
			    asgardGolem:AddTag("sdf_asgard_golem_command_follow")
			end
		    end
		end)
	    end)
	end

    --Summon Asgard Golem
    else
	--Cooldown
	inst.components.rechargeable:Discharge(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_SPAWN_COOLDOWN)

	--Light Pillar Anim
	local lightPillarFX = SpawnPrefab("fx_book_light_upgraded")
	lightPillarFX.Transform:SetPosition(x + offset.x, y - 0.1, z + offset.z)

	--earthquake
	StartShakeFX(inst)
	for i = 1, QUAKE_TIME, 1 do
	    inst:DoTaskInTime(0.4 + (i * 0.4), function()
		local aoeRing = SpawnPrefab("groundpoundring_fx")
		aoeRing.Transform:SetPosition(x + offset.x, 0, z + offset.z)
		aoeRing.Transform:SetScale(0.6,0.6,0.6)
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")

		local points = GetPoints(aoeRing:GetPosition())
		for k,v in ipairs(points) do
		    for j,x in ipairs(v) do
			inst:DoTaskInTime(0.2 * (k-1), function()
			    local aoeGroundPound = SpawnPrefab("groundpound_fx")
			    aoeGroundPound.Transform:SetPosition(x:Get())
			    aoeGroundPound.Transform:SetScale(0.6,0.6,0.6)
			end)
		    end
		end
	    end)
	end

	--Summon
	inst:DoTaskInTime(1.5, function()

	    --Spawn Asgard Golem
	    local asgardGolemSummon = SpawnPrefab("sdf_asgard_golem")
	    if asgardGolemSummon ~= nil and asgardGolemSummon.components.sdf_asgard_golem_command then

		--assign IDs
		asgardGolemSummon.asgardGolem_ID = inst.asgardGolem_ID
		inst.oldSummoner = musician

		--come from ground
		asgardGolemSummon.Transform:SetPosition(x + offset.x, 0, z + offset.z)
		asgardGolemSummon.components.locomotor:Stop()
		asgardGolemSummon.AnimState:PlayAnimation("unhide")

		--follow player
		inst:DoTaskInTime(2, function()

		    --leader is player
		    if inst.components.inventoryitem:IsHeld() == true then
			asgardGolemSummon:RemoveComponent("sdf_gallowmere_knight_unteleportable")
			asgardGolemSummon.components.sdf_asgard_golem_tactics:TurnOn(musician)
			asgardGolemSummon:RemoveTag("sdf_asgard_golem_command_stay")
			asgardGolemSummon:AddTag("sdf_asgard_golem_command_follow")

		    --leader is ocarina
		    else
			asgardGolemSummon:RemoveComponent("sdf_gallowmere_knight_unteleportable")
			asgardGolemSummon.components.sdf_asgard_golem_tactics:TurnOn(inst)
			asgardGolemSummon:RemoveTag("sdf_asgard_golem_command_stay")
			asgardGolemSummon:AddTag("sdf_asgard_golem_command_follow")
		    end
		end)
            end
	end)
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function DoAsgardGolemSummon(inst, musician)
    local x, y, z = musician.Transform:GetWorldPosition()
    local spawn_radius = TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_RADIUS
    local offset = (FindWalkableOffset(Vector3(x, 0, z), math.random() * TWOPI, spawn_radius + musician:GetPhysicsRadius(0), 8, false, true, NoHoles, false, true))
    musician:DoTaskInTime(0.1 + math.random() * 0.05, SummonAsgardGolem(inst, musician, x, y, z, offset)) --, x + dx, y, z + dz))
end

local function OnFinishedPlaying(inst, musician)
    musician:DoTaskInTime(52 * FRAMES, DoAsgardGolemSummon(inst, musician))
end

local function OnSave(inst, data)
    data.asgardGolem_ID = inst.asgardGolem_ID
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.asgardGolem_ID then
        inst.asgardGolem_ID = data.asgardGolem_ID
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_asgard_golem_giants_ocarina_mm.tex")
    inst.MiniMapEntity:SetPriority(7)

    MakeInventoryPhysics(inst)

    inst.spelltype = "SDF_ASGARD_GOLEM_GIANTS_OCARINA"

    inst:AddTag("sdf_asgard_golem_gaints_ocarina")
    inst:AddTag"allow_action_on_impassable"
    inst:AddTag("tool")
    inst:AddTag("flute")

    inst.AnimState:SetBank("sdf_asgard_golem_giants_ocarina")
    inst.AnimState:SetBuild("sdf_asgard_golem_giants_ocarina")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("leader")

    inst:AddComponent("inspectable")

    inst:AddComponent("instrument")
    inst.components.instrument:SetRange(1)
    --inst.components.instrument:SetOnPlayedFn(OnPlayed)
    --inst.components.instrument:SetOnHeardFn(HearPanFlute)
    inst.components.instrument:SetOnFinishedPlayingFn(OnFinishedPlaying)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem.imagename = "sdf_asgard_golem_giants_ocarina"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sdf_asgard_golem_giants_ocarina.xml"

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(TUNING.SDF_ASGARD_GOLEM_GIANTS_OCARINA_SUMMON_TELEPORT_COOLDOWN)

    MakeHauntableLaunch(inst)

    inst.oldSummoner = nil
    inst.asgardGolem_ID = math.random()

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    return inst
end

return Prefab("sdf_asgard_golem_giants_ocarina", fn, assets)