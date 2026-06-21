local assets =
{
    Asset("ANIM", "anim/sdf_pumpking_seed_pod_ripe.zip"),
    Asset("ANIM", "anim/sdf_pumpking_seed_pod_withered.zip"),

    Asset("SOUND", "sound/plant.fsb"),

    Asset("IMAGE", "images/map_icons/sdf_pumpking_seed_pod_mm.tex"),
    Asset("ATLAS", "images/map_icons/sdf_pumpking_seed_pod_mm.xml"),
}

local prefabs ={

}

local function FreshSpawn(inst)
    if inst:HasTag("sdf_pumpking_seed_pod_withered") then
	inst.AnimState:SetBank("sdf_pumpking_seed_pod_withered")
	inst.AnimState:SetBuild("sdf_pumpking_seed_pod_withered")
	inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_PUMPKING_SEED_POD_NAME[0])

	if inst:HasTag("hostile") then
	    inst:RemoveTag("hostile")
	end

	--remove frost
	inst.components.colouradder:PopColour("frost")

	inst.components.health:SetInvincible(true)

	inst.AnimState:PlayAnimation("idle", true)

    elseif inst:HasTag("sdf_pumpking_seed_pod_ripe") then
	inst.AnimState:SetBank("sdf_pumpking_seed_pod_ripe")
	inst.AnimState:SetBuild("sdf_pumpking_seed_pod_ripe")
	inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_PUMPKING_SEED_POD_NAME[1])

	inst:AddTag("hostile")

	--remove frost
	inst.components.colouradder:PopColour("frost")

	inst.components.health:SetInvincible(false)
	inst.components.health:SetPercent(1)

	inst.sg:GoToState("emerge")
    elseif inst:HasTag("sdf_pumpking_seed_pod_ripe_winter") then
	inst.AnimState:SetBank("sdf_pumpking_seed_pod_ripe")
	inst.AnimState:SetBuild("sdf_pumpking_seed_pod_ripe")
	inst.components.named:SetName(STRINGS.ANNOUNCE_SDF_PUMPKING_SEED_POD_NAME[2])

	if inst:HasTag("hostile") then
	    inst:RemoveTag("hostile")
	end

	--add frost
	inst.components.colouradder:PushColour("frost", 82 / 255, 115 / 255, 124 / 255, 0)

	inst.components.health:SetPercent(1)
	inst.components.health:SetInvincible(true)

	inst.sg:GoToState("emerge")
    end
end

local function OnHealthDelta(inst, data)
    if data.newpercent ~= nil then
	if inst:HasTag("sdf_pumpking_seed_pod_ripe") and data.newpercent < 0.02 and inst.components.health.minhealth > 0 then
  
	    --Create withered seed pod
	    local x,_,z=inst.Transform:GetWorldPosition()
	    local s = 1.5 --1.5
	    local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
	    pumpkinDeath2FX.Transform:SetPosition(x,_,z)

	    inst:DoTaskInTime(0.4, function()
		local x,_,z=inst.Transform:GetWorldPosition()
		local s = 1.5 --1.5
		local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
		pumpkinDeath2FX.Transform:SetPosition(x,_,z)

		inst:RemoveTag("sdf_pumpking_seed_pod_ripe")
		inst:RemoveTag("sdf_pumpking_seed_pod_ripe_winter")
		inst:AddTag("sdf_pumpking_seed_pod_withered")

		FreshSpawn(inst)
	    end)
	end
    end
end

local function OnRipen(inst)
    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 1.5 --1.5
    local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
    pumpkinDeath2FX.Transform:SetPosition(x,_,z)

    inst:DoTaskInTime(0.4, function()
	local x,_,z=inst.Transform:GetWorldPosition()
	local s = 1.5 --1.5
	local pumpkinDeath2FX = SpawnPrefab("treegrowthsolution_use_fx")
	pumpkinDeath2FX.Transform:SetPosition(x,_,z)

	inst:RemoveTag("sdf_pumpking_seed_pod_withered")
	inst:RemoveTag("sdf_pumpking_seed_pod_ripe_winter")
	inst:AddTag("sdf_pumpking_seed_pod_ripe")

	FreshSpawn(inst)
    end)
end

local function OnRipenWinter(inst)
    local x,_,z=inst.Transform:GetWorldPosition()
    local s = 1.5 --1.5
    local pumpkinDeath2FX = SpawnPrefab("mining_ice_fx")
    pumpkinDeath2FX.Transform:SetPosition(x,_,z)

    inst:DoTaskInTime(0.4, function()
	local x,_,z=inst.Transform:GetWorldPosition()
	local s = 1.5 --1.5
	local pumpkinDeath2FX = SpawnPrefab("mining_ice_fx")
	pumpkinDeath2FX.Transform:SetPosition(x,_,z)

	inst:RemoveTag("sdf_pumpking_seed_pod_withered")
	inst:RemoveTag("sdf_pumpking_seed_pod_ripe")
	inst:AddTag("sdf_pumpking_seed_pod_ripe_winter")

	FreshSpawn(inst)
    end)
end

local function onSave(inst, data)
    data.typeid = inst.typeid
end

local function OnLoad(inst, data)
    if data ~= nil and data.typeid ~= nil then
        inst.typeid = data.typeid
    end
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_central_idle", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnHaunt(inst)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sdf_pumpking_seed_pod_mm.tex")
    inst.MiniMapEntity:SetPriority(5)

    MakeObstaclePhysics(inst, .7)

    local s = 1.3 --1.3
    inst.Transform:SetScale(s,s,s)

    inst:AddTag("planted")
    inst:AddTag("veggie")
    inst:AddTag("elemental")
    inst:AddTag("soulless")
    inst:AddTag("friendlyStick")
    inst:AddTag("sdf_pumpking_asset")
    inst:AddTag("sdf_pumpking_friend")
    inst:AddTag("sdf_pumpking_seed_pod")
    inst:AddTag("sdf_pumpking_seed_pod_withered")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SDF_PUMPKING_SEED_POD_HEALTH)
    inst.components.health:SetMinHealth(1)

    inst:AddComponent("combat")
    inst:ListenForEvent("healthdelta", OnHealthDelta)

    inst:AddComponent("named")

    inst:AddComponent("inspectable")

    inst:AddComponent("follower")
    inst:AddComponent("colouradder")

    inst.typeid = 0

    inst:SetStateGraph("SGsdf_pumpking_seed_pod")

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnRipen = OnRipen
    inst.OnRipenWinter = OnRipenWinter

    inst.OnLoad = OnLoad
    inst.OnSave = onSave

    inst:DoTaskInTime(0, FreshSpawn)

    return inst
end

return Prefab("sdf_pumpking_seed_pod", fn, assets, prefabs)