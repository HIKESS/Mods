local assets=
{
    Asset("ATLAS", "images/map_icons/sdf_healthfountain_mm.xml"),
    Asset("IMAGE", "images/map_icons/sdf_healthfountain_mm.tex"),

    Asset("ANIM", "anim/sdf_healthfountain.zip"),
}

prefabs = {
}

local HEALTHFOUNTAIN_ACTIVE = false --SDF is close
local HEALTHFOUNTAIN_RESTORED = false --Full Moon Restored
local HEALTHFOUNTAIN_MOONFILLING = false

local function lifeorbFX(inst)
    local x,_,z = inst.Transform:GetWorldPosition()
    local s = 0.5

    --LifeSplatter
    local lifeSplatter = SpawnPrefab("bile_puddle_water")--mushroomsprout_glow")
    lifeSplatter.Transform:SetPosition(x,_,z)
    lifeSplatter.Transform:SetScale(s,s,s)

    inst.lifeorbtask = inst:DoTaskInTime(0.8, lifeorbFX)
end

local function startlifeorb(inst)
    inst.lifeorbtask = inst:DoTaskInTime(math.random(2, 5), lifeorbFX)
end

local function healthfountainstatus(inst, healthpool)
    if healthpool ~= nil then
    	if healthpool > (TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX / 1.2) then--100
	    inst.AnimState:PushAnimation("idle_full",true)
	    if inst.lifeorbtask == nil then
		inst.lifeorbtask = inst:DoTaskInTime(0, startlifeorb)
	    end
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[7])
    	elseif healthpool > (TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX / 1.5) then--80
	    inst.AnimState:PushAnimation("idle_large",true)
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[6])
    	elseif healthpool > (TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX / 2) then--60
	    inst.AnimState:PushAnimation("idle_medium",true)
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[5])
    	elseif healthpool > (TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX / 3) then--40
	    inst.AnimState:PushAnimation("idle_half",true)
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[4])
    	elseif healthpool > (TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX / 6) then--20
	    inst.AnimState:PushAnimation("idle_small",true)
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[3])
	elseif healthpool > 0 then
	    inst.AnimState:PushAnimation("idle_tiny",true)
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[2])
    	else
	    inst.AnimState:PushAnimation("idle",true)
	    if inst.lifeorbtask ~= nil then
		inst.lifeorbtask:Cancel()
	    end
	    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[0])
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[1])
    	end
    end
end

local function rejuvenation(inst, player)
    local healthpool = inst.components.sdf_healthfountain_resource:GetCurrent()
    local refundAmount = 0
    local canheal = player.components.sdf_lifebottle_holder:CheckCanHeal(player)

    if healthpool > 0 and canheal == true then

	--Heal player
	if healthpool > TUNING.SDF_HEALTHFOUNTAIN_RECOVERY then
	    refundAmount = player.components.sdf_lifebottle_holder:HealFountainDoDelta(player, TUNING.SDF_HEALTHFOUNTAIN_RECOVERY)

	    --Skill Tree Guts
	    if player.components.skilltreeupdater:IsActivated("sdf_allegiance_shadow") then
		local gutsBonusHealing = 0
		gutsBonusHealing = player.components.sdf_lifebottle_holder:HealFountainDoDelta(player, (TUNING.SDF_HEALTHFOUNTAIN_RECOVERY * TUNING.SDF_SKILLSET_ALLEGIANCE_GUTS))
	    end

	    --effects and sound
	    local x,_,z=player.Transform:GetWorldPosition()
	    local fx = SpawnPrefab("spider_heal_target_fx")
	    fx.Transform:SetPosition(x,_,z)
	    player.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt")

	    --refund extra healthpool
	    local refund = refundAmount - TUNING.SDF_HEALTHFOUNTAIN_RECOVERY
	    if refund ~= 0 then
		inst.components.sdf_healthfountain_resource:DoDelta(refund, false, "healthfountain")
	    end
	else
	    refundAmount = player.components.sdf_lifebottle_holder:HealFountainDoDelta(player, healthpool)

	    --Skill Tree Guts
	    if player.components.skilltreeupdater:IsActivated("sdf_allegiance_shadow") then
		local gutsBonusHealing = 0
		gutsBonusHealing = player.components.sdf_lifebottle_holder:HealFountainDoDelta(player, (healthpool * TUNING.SDF_SKILLSET_ALLEGIANCE_GUTS))
	    end

	    --effects and sound
	    local x,_,z=player.Transform:GetWorldPosition()
	    local fx = SpawnPrefab("spider_heal_target_fx")
	    fx.Transform:SetPosition(x,_,z)
	    player.SoundEmitter:PlaySound("dontstarve/ghost/ghost_haunt")

	    --refund extra healthpool
	    local refund = refundAmount - healthpool
	    if refund ~= 0 then
		inst.components.sdf_healthfountain_resource:DoDelta(refund, false, "healthfountain")
	    end
	end

	--update status
	healthfountainstatus(inst, inst.components.sdf_healthfountain_resource:GetCurrent())

    else
	if inst.rejuvenationtask ~= nil then
	    inst.rejuvenationtask:Cancel()
	end
    end
end


local function onmoonphasechanged(inst, phase)

    if TheWorld.state.moonphase == "full" and HEALTHFOUNTAIN_RESTORED == false then
	HEALTHFOUNTAIN_MOONFILLING = true
	local healthpool = inst.components.sdf_healthfountain_resource:GetCurrent()
	if healthpool <= 0 then
	    inst.AnimState:PlayAnimation("refill")
	end

	--Restored healthpool
	inst:DoTaskInTime(3, function()
	    HEALTHFOUNTAIN_RESTORED = true
	    HEALTHFOUNTAIN_MOONFILLING = false
	    inst.components.sdf_healthfountain_resource:DoDelta(TUNING.SDF_HEALTHFOUNTAIN_RESOURCE_MAX, false, "moonphase")
	    inst.AnimState:PushAnimation("idle_full",true)
	    inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[8])
	    inst.components.inspectable:SetDescription(STRINGS.ANNOUNCE_SDF_HEALTHFOUNTAIN_STATUS[7])
	end)

    elseif TheWorld.state.moonphase ~= "full" and HEALTHFOUNTAIN_RESTORED == true then
	HEALTHFOUNTAIN_RESTORED = false
    end
end

local function onload(inst, data)
    --Add fountain resouce and name based on vaule
    local healthpool = inst.components.sdf_healthfountain_resource:GetCurrent()
    healthfountainstatus(inst,healthpool)
end

local function healthfountainturnoff(inst)
    if inst.rejuvenationtask ~= nil then
        inst.rejuvenationtask:Cancel()
    end
end

local function healthfountainturnon(inst, player)
    if player.prefab == "sdf" and not player:HasTag("playerghost") and HEALTHFOUNTAIN_MOONFILLING == false then
	local healthpool = inst.components.sdf_healthfountain_resource:GetCurrent()
	local canheal = player.components.sdf_lifebottle_holder:CheckCanHeal(player)
	if healthpool > 0 and canheal == true then
	    inst.rejuvenationtask = inst:DoPeriodicTask(1, function() rejuvenation(inst, player) end)
	end
    end
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("sdf_healthfountain_mm.tex")
    inst.MiniMapEntity:SetPriority(3)

    local s = 1.3 --1.3
    inst.Transform:SetScale(s,s,s)
    

    inst.AnimState:SetBank("sdf_healthfountain")
    inst.AnimState:SetBuild("sdf_healthfountain")
    inst.AnimState:PlayAnimation("refill")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )	

    inst:AddTag("structure")
    inst:AddTag("prototyper")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("named")

    inst:AddComponent("inspectable")

    --Health Pool
    inst:AddComponent("sdf_healthfountain_resource")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(0.5,0.9)
    inst.components.playerprox:SetOnPlayerNear(healthfountainturnon)
    inst.components.playerprox:SetOnPlayerFar(healthfountainturnoff)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("moonphase", onmoonphasechanged)


    inst.OnLoad = onload

    inst.rejuvenationtask = nil
    inst.lifeorbtask = inst:DoTaskInTime(0, startlifeorb)

    healthfountainstatus(inst,inst.components.sdf_healthfountain_resource:GetCurrent())

    return inst
end

return  Prefab("sdf_healthfountain", fn, assets)

