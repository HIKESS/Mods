local assets =
{
    Asset("ANIM", "anim/sdf_pumpkin_king_rotten.zip"),
}

local prefabs =
{

}

local builds =
{
    sdf_pumpking_gourd_plant = {
        build = "sdf_pumpkin_king_rotten",
        bank = "sdf_pumpkin_king_rotten",
    },
}

local chance_loot =
{
	sdf_pumpkin_gourd_seeds = 33,
	sdf_pumpkin_bomb_seeds = 33,
	sdf_pumpkin_creeper_seeds = 33,
}

local function pumpkingFliesFX(inst)
    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 2 --2
    local pumpkingCorpseFX = SpawnPrefab("disease_puff")
    pumpkingCorpseFX.Transform:SetPosition(x,_,z)
    pumpkingCorpseFX.Transform:SetScale(s,s,s)
end

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local MUST_HAVE_TAGS = {"player"}
local CANT_HAVE_TAGS = {"INLIMBO", "companion", "ghost"}
local AOE_RADIUS = 8

local function aoeAnubisStonePartCheck(inst)
    local tx, ty, tz = inst.Transform:GetWorldPosition()

    local affected_entity = TheSim:FindEntities(tx, ty, tz, AOE_RADIUS, MUST_HAVE_TAGS, CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find sdf
	if v ~= nil then
	    if v.prefab == "sdf" then
		local hasAnubisStonePart2 = v.components.sdf_anubis_stone_quest:GetAnubisStonePart2FoundStatus()
		if hasAnubisStonePart2 == false then

		    --set anubis stone part 2 found
		    v.components.sdf_anubis_stone_quest:SetAnubisStonePart2FoundStatus()

		    --create anubis stone part 2
		    inst:DoTaskInTime(0.1,function()
			local x, y, z = inst.Transform:GetWorldPosition()
			y = 1.5

			local angle
			if v ~= nil and v:IsValid() then
			    angle = 180 - v:GetAngleToPoint(x, 0, z)
			else
			    local down = TheCamera:GetDownVec()
			    angle = math.atan2(down.z, down.x) / DEGREES
			end

			local anubisStonePart2 = SpawnPrefab("sdf_anubis_stone_part2")
			anubisStonePart2.Transform:SetPosition(x, y, z)
			launchitem(anubisStonePart2, angle)
		    end)
		end
	    end
	end
    end
end

local function onhit(inst)
    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 2 --2
    local pumpkingCorpseFX = SpawnPrefab("treegrowthsolution_use_fx")
    pumpkingCorpseFX.Transform:SetPosition(x,_,z)
    pumpkingCorpseFX.Transform:SetScale(s,s,s)

end

local function onhammered(inst, worker)
    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 2 --2
    local pumpkinDeathFX = SpawnPrefab("pumpkincarving_shatter_fx")
    pumpkinDeathFX.Transform:SetPosition(x,_,z)
    pumpkinDeathFX.Transform:SetScale(s,s,s)
    local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
    pumpkinDeath2FX.Transform:SetPosition(x,_,z)

    if inst.components.growable:GetStage() == 1 then

	--disable work
	if inst.components.workable then
	     inst:RemoveComponent("workable")
	end

	--check for sdf on anubis stone quest
	aoeAnubisStonePartCheck(inst)

	--drop loot
	inst.components.lootdropper:DropLoot()
	inst.components.lootdropper:SpawnLootPrefab(weighted_random_choice(chance_loot))

	--start regrow king
	inst:regrowKing()
    end
end

local function regrowKing(inst)
    inst.lootReady = false

    --remove flies FX
    if inst.pumpkingFliesTask ~= nil then
	inst.pumpkingFliesTask:Cancel()
	inst.pumpkingFliesTask = nil
    end

    inst.components.growable:SetStage(2)
    if TheWorld.state.isday and not TheWorld.state.iswinter then
	inst.components.growable:StartGrowing()
    end
end

local function corpseKing(inst)
    inst.spawnedKing = false
    inst.lootReady = true

    --remove well vine
    local followerGorgeWell = inst.components.leader:GetFollowersByTag("sdf_pumpkin_gorge_well")
    for i, v in ipairs(followerGorgeWell) do

	--find well vine
	if v ~= nil then
	    v:KillVine()
	end
    end

    inst:DoTaskInTime(2, function()
	inst.components.growable:SetStage(1)

	--add flies FX
	inst.pumpkingFliesTask = inst:DoPeriodicTask(15, function()  pumpkingFliesFX(inst) end)

	--allow work
	if not inst.components.workable then
	    inst:AddComponent("workable")
	    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	    inst.components.workable:SetWorkLeft(10)
	    inst.components.workable:SetOnFinishCallback(onhammered)
	    inst.components.workable:SetOnWorkCallback(onhit)
	end
    end)
end

local function pumpkingHuskRegen(inst)
    local numSeedPod = inst.components.leader:CountFollowers("sdf_pumpking_seed_pod")
    local numActiveSeedPod = inst.components.leader:CountFollowers("sdf_pumpking_seed_pod_ripe")
    local numActiveSeedPodWinter = inst.components.leader:CountFollowers("sdf_pumpking_seed_pod_ripe_winter")

    --regen based on active seed pods
    if (numActiveSeedPod + numActiveSeedPodWinter) >= 1 then
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then
		if v.components.health ~= nil and not v.components.health:IsDead() then
		    local totalAdjustHeal = (TUNING.SDF_PUMPKIN_KING_HEALTH * TUNING.SDF_PUMPKIN_KING_HUSK_REGEN_PERCENT) * numActiveSeedPod

		    --winter healing
		    if v.winterMode == true then
			totalAdjustHeal = (TUNING.SDF_PUMPKIN_KING_HEALTH * TUNING.SDF_PUMPKIN_KING_HUSK_WINTER_REGEN_PERCENT)
		    end

		    v.components.health:DoDelta(totalAdjustHeal, false, "pumpking husk")

		    --check needs reset
		    inst:DoTaskInTime(0, function()
			if v.activeBattle == true and v.winterMode == false then
			    if v.components.health ~= nil and not v.components.health:IsDead() then
				if v.components.health:GetPercent() >= 1 and inst.pumpkingResetTask == nil then

				    inst.pumpkingResetTask = inst:DoTaskInTime(TUNING.SDF_PUMPKIN_KING_RESET_TIME, function(i)
					--Remove reset cooldown timer
					i.pumpkingResetTask:Cancel()
					i.pumpkingResetTask = nil

					--reset pumpkinKing
					i:reActivateSeedPodsReset()
				    end)
				end
			    end
			end
		    end)

		    --animation
		    local x,_,z=inst.Transform:GetWorldPosition()
		    local s = 2 --2
		    local huskRegenFX = SpawnPrefab("abigail_rising_twinkles_fx")
		    huskRegenFX.Transform:SetPosition(x,_,z)
		    huskRegenFX.Transform:SetScale(s,s,s)
		end
	    end
	end
    end

    --no active seed pods
    if (numActiveSeedPod + numActiveSeedPodWinter) <= 0 then

	--Remove reset cooldown timer
	if inst.pumpkingResetTask ~= nil then
	    inst.pumpkingResetTask:Cancel()
	    inst.pumpkingResetTask = nil
	end

	--stop husk regen
	if inst.pumpkingHuskRegenTask ~= nil then
	    inst.pumpkingHuskRegenTask:Cancel()
	    inst.pumpkingHuskRegenTask = nil
	end

	--kill husk
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then

		--start battle
		v.activeBattle = true

		--check player in area
		if v.DeadheadingTask ~= nil then
		    v.DeadheadingTask:Cancel()
		    v.DeadheadingTask = nil
		end
		v.DeadheadingTask = v:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_DEADHEADING_TIME, function()  v:DoDeadheading() end)

		--kill husk
		v:killhusk()
	    end
	end
    end
end

local function reActivateSeedPods(inst)
    local hasSeedPod = false
    local hasPumpkinKing = false
    local PumpkinKingPhase = 0

    local checkPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
    for i, v in ipairs(checkPumpkinKing) do

	 --find pumpkin king
	if v ~= nil then

	    --get Phase Count
	    PumpkinKingPhase = v.phaseCount
	end
    end

    local followerSeedPods = inst.components.leader:GetFollowersByTag("sdf_pumpking_seed_pod")
    for i, v in ipairs(followerSeedPods) do

	--find Seed Pods
	if v ~= nil then

	    --make sure withered seed pods
	    if v:HasTag("sdf_pumpking_seed_pod_withered") then

		--ripen based on phase
		if PumpkinKingPhase == 2 and v.typeid == 3 then
		    hasSeedPod = true
		    v:OnRipen()
		elseif PumpkinKingPhase == 1 and v.typeid == 2 then
		    hasSeedPod = true
		    v:OnRipen()
		elseif PumpkinKingPhase == 0 and v.typeid == 1 then
		    hasSeedPod = true
		    v:OnRipen()
		end
	    end
	end
    end

    if hasSeedPod == true then
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then
		hasPumpkinKing = true

		--make new husk
		v:createHusk()
	    end
	end
    end
 
    --start husk regen
    if hasSeedPod == true and hasPumpkinKing == true then

	--stop husk regen
	if inst.pumpkingHuskRegenTask ~= nil then
	    inst.pumpkingHuskRegenTask:Cancel()
	    inst.pumpkingHuskRegenTask = nil
	end

	inst.pumpkingHuskRegenTask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_HUSK_REGEN_TICK, function()  pumpkingHuskRegen(inst) end)
    end
end
 
local function reActivateSeedPodsRest(inst)
    local hasSeedPod = false
    local hasPumpkinKing = false

    local followerSeedPods = inst.components.leader:GetFollowersByTag("sdf_pumpking_seed_pod")
    for i, v in ipairs(followerSeedPods) do

	--find Seed Pods
	if v ~= nil then

	    --make sure withered seed pods
	    if v:HasTag("sdf_pumpking_seed_pod_withered") or v:HasTag("sdf_pumpking_seed_pod_ripe") then
		hasSeedPod = true
		v:OnRipen()
	    end
	end
    end

    if hasSeedPod == true then
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then
		hasPumpkinKing = true

		--make new husk
		--if v.winterMode == false then
		    v:createHuskRest()
		    v:killvines()
		--end
	    end
	end
    end
 
    --start husk regen
    if hasSeedPod == true and hasPumpkinKing == true then

	--stop husk regen
	if inst.pumpkingHuskRegenTask ~= nil then
	    inst.pumpkingHuskRegenTask:Cancel()
	    inst.pumpkingHuskRegenTask = nil
	end

	inst.pumpkingHuskRegenTask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_HUSK_REGEN_TICK, function()  pumpkingHuskRegen(inst) end)
    end
end

local function reActivateSeedPodsReset(inst)
    local hasSeedPod = false
    local hasPumpkinKing = false

    local followerSeedPods = inst.components.leader:GetFollowersByTag("sdf_pumpking_seed_pod")
    for i, v in ipairs(followerSeedPods) do

	--find Seed Pods
	if v ~= nil then

	    --make sure withered seed pods
	    if v:HasTag("sdf_pumpking_seed_pod_withered") or v:HasTag("sdf_pumpking_seed_pod_ripe") then
		hasSeedPod = true
		v:OnRipen()
	    end
	end
    end

    if hasSeedPod == true then
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then
		hasPumpkinKing = true

		--make new husk
		--if v.winterMode == false then
		    v:createHuskReset()
		    v:killvines()
		--end
	    end
	end
    end
 
    --start husk regen
    if hasSeedPod == true and hasPumpkinKing == true then

	--stop husk regen
	if inst.pumpkingHuskRegenTask ~= nil then
	    inst.pumpkingHuskRegenTask:Cancel()
	    inst.pumpkingHuskRegenTask = nil
	end

	inst.pumpkingHuskRegenTask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_HUSK_SPAWN_REGEN_TICK, function()  pumpkingHuskRegen(inst) end)
    end
end

local function reActivateSeedPodsThaw(inst)
    local hasSeedPod = false
    local hasPumpkinKing = false

    local followerSeedPods = inst.components.leader:GetFollowersByTag("sdf_pumpking_seed_pod")
    for i, v in ipairs(followerSeedPods) do

	--find Seed Pods
	if v ~= nil then

	    --make sure withered seed pods
	    if v:HasTag("sdf_pumpking_seed_pod_withered") or v:HasTag("sdf_pumpking_seed_pod_ripe_winter") then
		hasSeedPod = true
		v:OnRipen()
	    end
	end
    end

    if hasSeedPod == true then
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then
		hasPumpkinKing = true
		v.winterMode = false
		v.sg:GoToState("spawn_thaw")
	    end
	end
    end
 
    --start husk regen
    if hasSeedPod == true and hasPumpkinKing == true then

	--stop husk regen
	if inst.pumpkingHuskRegenTask ~= nil then
	    inst.pumpkingHuskRegenTask:Cancel()
	    inst.pumpkingHuskRegenTask = nil
	end

	inst.pumpkingHuskRegenTask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_HUSK_REGEN_TICK, function()  pumpkingHuskRegen(inst) end)
    end
end

local function reActivateSeedPodsWinter(inst)
    local hasSeedPod = false
    local hasPumpkinKing = false

    local followerSeedPods = inst.components.leader:GetFollowersByTag("sdf_pumpking_seed_pod")
    for i, v in ipairs(followerSeedPods) do

	--find Seed Pods
	if v ~= nil then

	    --make sure withered seed pods
	    if v:HasTag("sdf_pumpking_seed_pod_withered") or v:HasTag("sdf_pumpking_seed_pod_ripe") then
		hasSeedPod = true
		v:OnRipenWinter()
	    end
	end
    end

    if hasSeedPod == true then
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then
		hasPumpkinKing = true

		--make new husk
		if v.winterMode == false then
		    v.winterMode = true
		    v:createHuskWinter()
		    v:killvines()
		end
	    end
	end
    end
 
    --start husk regen
    if hasSeedPod == true and hasPumpkinKing == true then

	--Remove reset cooldown timer
	if inst.pumpkingResetTask ~= nil then
	    inst.pumpkingResetTask:Cancel()
	    inst.pumpkingResetTask = nil
	end

	--stop husk regen
	if inst.pumpkingHuskRegenTask ~= nil then
	    inst.pumpkingHuskRegenTask:Cancel()
	    inst.pumpkingHuskRegenTask = nil
	end

	inst.pumpkingHuskRegenTask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_HUSK_SPAWN_REGEN_TICK, function()  pumpkingHuskRegen(inst) end)
    end
end

local PUMPKING_ASSET_MUST_HAVE_TAGS = {"sdf_pumpking_asset"}
local PUMPKING_ASSET_CANT_HAVE_TAGS = {"player", "playerghost", "INLIMBO", "companion", "ghost"}
local PUMPKING_ASSET_AOE_RADIUS = 60 --60

local function findSeedPods(inst)
    local hasSeedPod = false
    local hasPumpkinKing = false
    local isFrozen = false
    if inst.frozen ~= nil then
	isFrozen = inst.frozen
    end 

    local tx, ty, tz = inst.Transform:GetWorldPosition()
    local affected_entity = TheSim:FindEntities(tx, ty, tz, PUMPKING_ASSET_AOE_RADIUS, PUMPKING_ASSET_MUST_HAVE_TAGS, PUMPKING_ASSET_CANT_HAVE_TAGS)
    for i, v in ipairs(affected_entity) do

	--find Seed Pods
	if v ~= nil then

	    --find Seed Pods
	    if v:HasTag("sdf_pumpking_seed_pod") then
		--make sure offical seed pods
		if v.typeid ~= nil and v.typeid > 0 then
		    if v.components.follower ~= nil then
			hasSeedPod = true

			v.components.follower:SetLeader(inst)

			--Winter Check
			if isFrozen == true then
			    v:OnRipenWinter()
			else
			    v:OnRipen()
			end
		    end
		end
	    end

	    --find gorge well
	    if v:HasTag("sdf_pumpkin_gorge_well") then
		--make sure offical gorge well
		--if v.typeid ~= nil and v.typeid > 0 then
		    if v.components.follower ~= nil then
			v.components.follower:SetLeader(inst)

			--spawn vine
			v:CreateVine()
		    end
		--end
	    end
	end
    end

    if hasSeedPod == true then
	local followerPumpkinKing = inst.components.leader:GetFollowersByTag("sdf_pumpkin_king")
	for i, v in ipairs(followerPumpkinKing) do

	    --find pumpkin king
	    if v ~= nil then
		hasPumpkinKing = true

		--make new husk
		--Winter Check
		if isFrozen == true then
		    v.winterMode = true
		    v:createHuskWinter()
		else
		    v.winterMode = false
		    v:createHuskSpawn()
		end
	    end
	end
    end
 
    --start husk regen
    if hasSeedPod == true and hasPumpkinKing == true then

	--stop husk regen
	if inst.pumpkingHuskRegenTask ~= nil then
	    inst.pumpkingHuskRegenTask:Cancel()
	    inst.pumpkingHuskRegenTask = nil
	end

	inst.pumpkingHuskRegenTask = inst:DoPeriodicTask(TUNING.SDF_PUMPKIN_KING_HUSK_SPAWN_REGEN_TICK, function()  pumpkingHuskRegen(inst) end)
    end
end

local function GrowRot(inst)
    inst.AnimState:PushAnimation("rotten_med")
end

local function SetRot(inst)
    inst.Physics:SetActive(true)
    inst.AnimState:PlayAnimation("rotten_med")
end

local function GrowSeed(inst)
    inst.AnimState:PushAnimation("invisible")
end

local function SetSeed(inst)
    inst.Physics:SetActive(false)
    inst.AnimState:PlayAnimation("invisible")
end

local function GrowPlant(inst)
    inst.AnimState:PushAnimation("invisible")
end

local function SetPlant(inst)
    inst.Physics:SetActive(false)
    inst.AnimState:PlayAnimation("invisible")
end

local function GrowHarvest(inst)
    inst.AnimState:PlayAnimation("invisible")
end

local function SetHarvest(inst)
    inst.Physics:SetActive(false)
    inst.AnimState:PlayAnimation("invisible")

    --spawn pumpkin King
    if inst.spawnedKing == false then
	inst.spawnedKing = true
	local pumpkinKing = SpawnPrefab("sdf_pumpkin_king")
	if pumpkinKing ~= nil then
	    pumpkinKing.Transform:SetPosition(inst.Transform:GetWorldPosition())
	    pumpkinKing.components.follower:SetLeader(inst)
	    pumpkinKing.typeid = 1

	    pumpkinKing:playSpawnAnimation()

	    --find seed pods and spawn husk
	    inst:DoTaskInTime(0, function()
		findSeedPods(inst)
	    end)
	end
    end
end

local growth_stages = {}
for build, data in pairs(builds) do
    growth_stages[build] =
    {
        {
            name = "rot",
            time = function(inst) return (TUNING.SDF_PUMPKIN_KING_PLANT_GROWTH_TIME*TUNING.TOTAL_DAY_TIME) end,
            fn = SetRot,
            growfn = GrowRot,
        },
        {
            name = "seed",
            time = function(inst) return (TUNING.SDF_PUMPKIN_KING_PLANT_GROWTH_TIME*TUNING.TOTAL_DAY_TIME) end,
            fn = SetSeed,
            growfn = GrowSeed,
        },
        {
            name = "plant",
            time = function(inst) return 5 end,
            fn = SetPlant,
            growfn = GrowPlant,
        },
        {
            name = "harvest",
            time = function(inst) return 5 end,
            fn = SetHarvest,
            growfn = GrowHarvest,
        },
    }
end

local function OnSave(inst, data)
    data.typeid = inst.typeid
    data.lootReady = inst.lootReady
    data.spawnedKing = inst.spawnedKing
end

local function OnLoad(inst, data)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end
    if data ~= nil and data.lootReady ~= nil then
	inst.lootReady = data.lootReady
    end

    if data ~= nil and data.spawnedKing ~= nil then
	inst.spawnedKing = data.spawnedKing
    end

    if inst.components.growable:GetStage() == 1 then
	inst.Physics:SetActive(true)
    end
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel >= .03 then
        if not inst.frozen then
            inst.frozen = true
            inst.components.growable:StopGrowing()

	    --winter growing
	    if inst.components.growable:GetStage() == 4 and inst.spawnedKing == true and inst.lootReady == false then
		inst:DoTaskInTime(0, function()
		    reActivateSeedPodsWinter(inst)
		end)
	    end
	elseif inst.frozen and inst.firstFrost == false then
	    inst.firstFrost =  true
            inst.components.growable:StopGrowing()

	    --winter growing
	    if inst.components.growable:GetStage() == 4 and inst.spawnedKing == true and inst.lootReady == false then
		inst:DoTaskInTime(0, function()
		    reActivateSeedPodsWinter(inst)
		end)
	    end
        end
    elseif inst.frozen then
        inst.frozen = false

	--winter thaw
	if inst.components.growable:GetStage() == 4 and inst.spawnedKing == true and inst.lootReady == false then
	    inst:DoTaskInTime(0, function()
		reActivateSeedPodsThaw(inst)
	    end)
	elseif inst.spawnedKing == false and inst.lootReady == false then
	    inst.components.growable:StartGrowing()
	end
    elseif inst.frozen == nil then
        inst.frozen = false

	if inst.spawnedKing == false and inst.lootReady == false then
	    inst.components.growable:StartGrowing()
	end
    end
end

local function OnIsDay(inst, isday)
    if isday ~= inst.dayspawn then
	inst.components.growable:StopGrowing()
    elseif not TheWorld.state.iswinter then
	if inst.spawnedKing == false and inst.lootReady == false then
	    inst.components.growable:StartGrowing()
	end
    end
end

local function OnInit(inst)
    if inst.typeid == 0 then
	inst:Remove()
    else
	inst.task = nil
	inst:WatchWorldState("isday", OnIsDay)
	inst:WatchWorldState("snowlevel", OnSnowLevel)
	OnIsDay(inst, TheWorld.state.isday)
	OnSnowLevel(inst, TheWorld.state.snowlevel)
	if inst.lootReady == true then
	    if not inst.components.workable then
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(10)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit)
	    end

	    --add flies FX
	    if inst.pumpkingFliesTask == nil then
		inst.pumpkingFliesTask = inst:DoPeriodicTask(15, function()  pumpkingFliesFX(inst) end)
	    end
	end
    end
end

local function GetGrowthStages(inst)
    return growth_stages[inst.build] or growth_stages["sdf_pumpking_gourd_plant"]
end

local function GetBuild(inst)
    return builds[inst.build] or builds["sdf_pumpking_gourd_plant"]
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.build = "sdf_pumpking_gourd_plant"

    MakeObstaclePhysics(inst, .8)
    inst.Physics:SetActive(false)

    local scale = 1.5
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBuild(GetBuild(inst).build)
    inst.AnimState:SetBank(GetBuild(inst).bank)

    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpkin_king_plant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	return inst
    end

    inst:AddComponent("growable")
    inst.components.growable.growoffscreen = true
    inst.components.growable.stages = GetGrowthStages(inst)
    inst.components.growable:SetStage(3) --2
    inst.components.growable.loopstages = false
    --inst.components.growable:StartGrowing()

    inst.lootchest = {"pumpkin_seeds", "pumpkin_seeds", "spoiled_food", "spoiled_food", "spoiled_food", "spoiled_food", "spoiled_food", "spoiled_food"}
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(inst.lootchest)

    inst:AddComponent("leader")

    inst:AddComponent("inspectable")

    inst.typeid = 0
    inst.dayspawn = true
    inst.lootReady = false
    inst.spawnedKing = false
    inst.firstFrost = false

    inst.corpseKing = corpseKing
    inst.regrowKing = regrowKing
    inst.reActivateSeedPods = reActivateSeedPods
    inst.reActivateSeedPodsRest = reActivateSeedPodsRest
    inst.reActivateSeedPodsReset = reActivateSeedPodsReset
    inst.pumpkingFliesTask = nil

    inst.task = inst:DoTaskInTime(0, OnInit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("sdf_pumpkin_king_plant", fn, assets, prefabs)
